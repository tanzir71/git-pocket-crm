import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Thrown when a passphrase does not authenticate a `PCRM1` encrypted backup.
class WrongPassphraseException implements Exception {
  const WrongPassphraseException();
  @override
  String toString() => 'WrongPassphraseException';
}

/// Thrown when a backup file is truncated, malformed, or unsupported.
class CorruptBackupException implements Exception {
  const CorruptBackupException(this.reason);
  final String reason;
  @override
  String toString() => 'CorruptBackupException: $reason';
}

/// Binary encryption format (`PCRM1`) for passphrase-protected `.pcrm` backups.
///
/// Layout:
/// - 5 bytes: ASCII magic `PCRM1`
/// - 1 byte: KDF id (`1` = Argon2id, `2` = PBKDF2-HMAC-SHA256 600,000 iters)
/// - 16 bytes: random salt
/// - 12 bytes: random AES-GCM nonce
/// - N bytes: ciphertext
/// - 16 bytes: AES-GCM 128-bit authentication tag
class BackupCrypto {
  BackupCrypto({
    this.kdfMethod = kdfArgon2id,
    this.argon2MemoryKiB = 19456,
    this.argon2Iterations = 2,
    this.argon2Parallelism = 1,
    this.pbkdf2Iterations = 600000,
    Random? random,
  }) : _random = random ?? Random.secure();

  static const List<int> magic = <int>[0x50, 0x43, 0x52, 0x4D, 0x31]; // "PCRM1"
  static const int kdfArgon2id = 1;
  static const int kdfPbkdf2Sha256 = 2;

  static const int saltLength = 16;
  static const int nonceLength = 12;
  static const int macLength = 16;
  static const int headerLength = 5 + 1 + saltLength + nonceLength; // 34 bytes
  static const int minEnvelopeLength = headerLength + macLength; // 50 bytes

  final int kdfMethod;
  final int argon2MemoryKiB;
  final int argon2Iterations;
  final int argon2Parallelism;
  final int pbkdf2Iterations;
  final Random _random;

  static bool isEncryptedBytes(Uint8List bytes) {
    if (bytes.length < magic.length) return false;
    for (var i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) return false;
    }
    return true;
  }

  static bool isZipBytes(Uint8List bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07);
  }

  static bool isJsonBytes(Uint8List bytes) {
    for (final b in bytes) {
      if (b == 0x20 || b == 0x09 || b == 0x0A || b == 0x0D) continue;
      return b == 0x7B; // '{'
    }
    return false;
  }

  Uint8List _randomBytes(int length) {
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = _random.nextInt(256);
    }
    return out;
  }

  Future<SecretKey> _deriveKey({
    required String passphrase,
    required Uint8List salt,
    required int method,
  }) async {
    if (method == kdfArgon2id) {
      final kdf = Argon2id(
        memory: argon2MemoryKiB,
        parallelism: argon2Parallelism,
        iterations: argon2Iterations,
        hashLength: 32,
      );
      return kdf.deriveKeyFromPassword(password: passphrase, nonce: salt);
    }
    if (method == kdfPbkdf2Sha256) {
      final kdf = Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: pbkdf2Iterations,
        bits: 256,
      );
      return kdf.deriveKeyFromPassword(password: passphrase, nonce: salt);
    }
    throw CorruptBackupException('Unsupported KDF method: $method');
  }

  Future<Uint8List> encrypt(Uint8List plainZip, String passphrase) async {
    final salt = _randomBytes(saltLength);
    final nonce = _randomBytes(nonceLength);
    final key = await _deriveKey(
      passphrase: passphrase,
      salt: salt,
      method: kdfMethod,
    );
    final algorithm = AesGcm.with256bits();
    final box = await algorithm.encrypt(
      plainZip,
      secretKey: key,
      nonce: nonce,
    );

    final out = BytesBuilder(copy: false)
      ..add(magic)
      ..addByte(kdfMethod)
      ..add(salt)
      ..add(nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return out.toBytes();
  }

  Future<Uint8List> decrypt(Uint8List blob, String passphrase) async {
    if (!isEncryptedBytes(blob)) {
      throw const CorruptBackupException('Missing PCRM1 header');
    }
    if (blob.length < minEnvelopeLength + 4) {
      throw const CorruptBackupException('Encrypted backup is truncated');
    }
    final method = blob[5];
    if (method != kdfArgon2id && method != kdfPbkdf2Sha256) {
      throw CorruptBackupException('Unknown KDF method: $method');
    }

    final salt = Uint8List.sublistView(blob, 6, 6 + saltLength);
    final nonce = Uint8List.sublistView(blob, 6 + saltLength, headerLength);
    final cipherEnd = blob.length - macLength;
    final cipherText = Uint8List.sublistView(blob, headerLength, cipherEnd);
    final macBytes = Uint8List.sublistView(blob, cipherEnd, blob.length);

    final key = await _deriveKey(
      passphrase: passphrase,
      salt: salt,
      method: method,
    );
    final algorithm = AesGcm.with256bits();
    final box = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

    try {
      final decrypted = await algorithm.decrypt(box, secretKey: key);
      final bytes = Uint8List.fromList(decrypted);
      if (!isZipBytes(bytes)) {
        throw const CorruptBackupException('Decrypted payload is not a valid archive');
      }
      return bytes;
    } on SecretBoxAuthenticationError {
      throw const WrongPassphraseException();
    }
  }
}
