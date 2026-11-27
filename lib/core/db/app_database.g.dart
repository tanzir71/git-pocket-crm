// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarColorMeta = const VerificationMeta(
    'avatarColor',
  );
  @override
  late final GeneratedColumn<String> avatarColor = GeneratedColumn<String>(
    'avatar_color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<int> isStarred = GeneratedColumn<int>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _facebookUrlMeta = const VerificationMeta(
    'facebookUrl',
  );
  @override
  late final GeneratedColumn<String> facebookUrl = GeneratedColumn<String>(
    'facebook_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _linkedinUrlMeta = const VerificationMeta(
    'linkedinUrl',
  );
  @override
  late final GeneratedColumn<String> linkedinUrl = GeneratedColumn<String>(
    'linkedin_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gmailAddressMeta = const VerificationMeta(
    'gmailAddress',
  );
  @override
  late final GeneratedColumn<String> gmailAddress = GeneratedColumn<String>(
    'gmail_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pinnedNoteMeta = const VerificationMeta(
    'pinnedNote',
  );
  @override
  late final GeneratedColumn<String> pinnedNote = GeneratedColumn<String>(
    'pinned_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncTimeMeta = const VerificationMeta(
    'lastSyncTime',
  );
  @override
  late final GeneratedColumn<int> lastSyncTime = GeneratedColumn<int>(
    'last_sync_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _companyMeta = const VerificationMeta(
    'company',
  );
  @override
  late final GeneratedColumn<String> company = GeneratedColumn<String>(
    'company',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<String> birthday = GeneratedColumn<String>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aboutMeta = const VerificationMeta('about');
  @override
  late final GeneratedColumn<String> about = GeneratedColumn<String>(
    'about',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceDaysMeta = const VerificationMeta(
    'cadenceDays',
  );
  @override
  late final GeneratedColumn<int> cadenceDays = GeneratedColumn<int>(
    'cadence_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cadenceSnoozedUntilMeta =
      const VerificationMeta('cadenceSnoozedUntil');
  @override
  late final GeneratedColumn<int> cadenceSnoozedUntil = GeneratedColumn<int>(
    'cadence_snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastInteractionAtMeta = const VerificationMeta(
    'lastInteractionAt',
  );
  @override
  late final GeneratedColumn<int> lastInteractionAt = GeneratedColumn<int>(
    'last_interaction_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doNotMessageMeta = const VerificationMeta(
    'doNotMessage',
  );
  @override
  late final GeneratedColumn<int> doNotMessage = GeneratedColumn<int>(
    'do_not_message',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deviceContactIdMeta = const VerificationMeta(
    'deviceContactId',
  );
  @override
  late final GeneratedColumn<String> deviceContactId = GeneratedColumn<String>(
    'device_contact_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('device'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    phoneNumber,
    displayName,
    avatarColor,
    isStarred,
    facebookUrl,
    linkedinUrl,
    gmailAddress,
    pinnedNote,
    lastSyncTime,
    company,
    role,
    city,
    email,
    birthday,
    about,
    cadenceDays,
    cadenceSnoozedUntil,
    lastInteractionAt,
    doNotMessage,
    deviceContactId,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('avatar_color')) {
      context.handle(
        _avatarColorMeta,
        avatarColor.isAcceptableOrUnknown(
          data['avatar_color']!,
          _avatarColorMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('facebook_url')) {
      context.handle(
        _facebookUrlMeta,
        facebookUrl.isAcceptableOrUnknown(
          data['facebook_url']!,
          _facebookUrlMeta,
        ),
      );
    }
    if (data.containsKey('linkedin_url')) {
      context.handle(
        _linkedinUrlMeta,
        linkedinUrl.isAcceptableOrUnknown(
          data['linkedin_url']!,
          _linkedinUrlMeta,
        ),
      );
    }
    if (data.containsKey('gmail_address')) {
      context.handle(
        _gmailAddressMeta,
        gmailAddress.isAcceptableOrUnknown(
          data['gmail_address']!,
          _gmailAddressMeta,
        ),
      );
    }
    if (data.containsKey('pinned_note')) {
      context.handle(
        _pinnedNoteMeta,
        pinnedNote.isAcceptableOrUnknown(data['pinned_note']!, _pinnedNoteMeta),
      );
    }
    if (data.containsKey('last_sync_time')) {
      context.handle(
        _lastSyncTimeMeta,
        lastSyncTime.isAcceptableOrUnknown(
          data['last_sync_time']!,
          _lastSyncTimeMeta,
        ),
      );
    }
    if (data.containsKey('company')) {
      context.handle(
        _companyMeta,
        company.isAcceptableOrUnknown(data['company']!, _companyMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('about')) {
      context.handle(
        _aboutMeta,
        about.isAcceptableOrUnknown(data['about']!, _aboutMeta),
      );
    }
    if (data.containsKey('cadence_days')) {
      context.handle(
        _cadenceDaysMeta,
        cadenceDays.isAcceptableOrUnknown(
          data['cadence_days']!,
          _cadenceDaysMeta,
        ),
      );
    }
    if (data.containsKey('cadence_snoozed_until')) {
      context.handle(
        _cadenceSnoozedUntilMeta,
        cadenceSnoozedUntil.isAcceptableOrUnknown(
          data['cadence_snoozed_until']!,
          _cadenceSnoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('last_interaction_at')) {
      context.handle(
        _lastInteractionAtMeta,
        lastInteractionAt.isAcceptableOrUnknown(
          data['last_interaction_at']!,
          _lastInteractionAtMeta,
        ),
      );
    }
    if (data.containsKey('do_not_message')) {
      context.handle(
        _doNotMessageMeta,
        doNotMessage.isAcceptableOrUnknown(
          data['do_not_message']!,
          _doNotMessageMeta,
        ),
      );
    }
    if (data.containsKey('device_contact_id')) {
      context.handle(
        _deviceContactIdMeta,
        deviceContactId.isAcceptableOrUnknown(
          data['device_contact_id']!,
          _deviceContactIdMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_color'],
      ),
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_starred'],
      )!,
      facebookUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facebook_url'],
      ),
      linkedinUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linkedin_url'],
      ),
      gmailAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gmail_address'],
      ),
      pinnedNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinned_note'],
      ),
      lastSyncTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_time'],
      )!,
      company: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}company'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birthday'],
      ),
      about: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}about'],
      ),
      cadenceDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence_days'],
      ),
      cadenceSnoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence_snoozed_until'],
      ),
      lastInteractionAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_interaction_at'],
      ),
      doNotMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}do_not_message'],
      )!,
      deviceContactId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_contact_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final int id;
  final String? phoneNumber;
  final String displayName;
  final String? avatarColor;
  final int isStarred;
  final String? facebookUrl;
  final String? linkedinUrl;
  final String? gmailAddress;
  final String? pinnedNote;
  final int lastSyncTime;
  final String? company;
  final String? role;
  final String? city;
  final String? email;
  final String? birthday;
  final String? about;
  final int? cadenceDays;
  final int? cadenceSnoozedUntil;
  final int? lastInteractionAt;
  final int doNotMessage;
  final String? deviceContactId;
  final String source;
  final int? createdAt;
  const Contact({
    required this.id,
    this.phoneNumber,
    required this.displayName,
    this.avatarColor,
    required this.isStarred,
    this.facebookUrl,
    this.linkedinUrl,
    this.gmailAddress,
    this.pinnedNote,
    required this.lastSyncTime,
    this.company,
    this.role,
    this.city,
    this.email,
    this.birthday,
    this.about,
    this.cadenceDays,
    this.cadenceSnoozedUntil,
    this.lastInteractionAt,
    required this.doNotMessage,
    this.deviceContactId,
    required this.source,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || avatarColor != null) {
      map['avatar_color'] = Variable<String>(avatarColor);
    }
    map['is_starred'] = Variable<int>(isStarred);
    if (!nullToAbsent || facebookUrl != null) {
      map['facebook_url'] = Variable<String>(facebookUrl);
    }
    if (!nullToAbsent || linkedinUrl != null) {
      map['linkedin_url'] = Variable<String>(linkedinUrl);
    }
    if (!nullToAbsent || gmailAddress != null) {
      map['gmail_address'] = Variable<String>(gmailAddress);
    }
    if (!nullToAbsent || pinnedNote != null) {
      map['pinned_note'] = Variable<String>(pinnedNote);
    }
    map['last_sync_time'] = Variable<int>(lastSyncTime);
    if (!nullToAbsent || company != null) {
      map['company'] = Variable<String>(company);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<String>(birthday);
    }
    if (!nullToAbsent || about != null) {
      map['about'] = Variable<String>(about);
    }
    if (!nullToAbsent || cadenceDays != null) {
      map['cadence_days'] = Variable<int>(cadenceDays);
    }
    if (!nullToAbsent || cadenceSnoozedUntil != null) {
      map['cadence_snoozed_until'] = Variable<int>(cadenceSnoozedUntil);
    }
    if (!nullToAbsent || lastInteractionAt != null) {
      map['last_interaction_at'] = Variable<int>(lastInteractionAt);
    }
    map['do_not_message'] = Variable<int>(doNotMessage);
    if (!nullToAbsent || deviceContactId != null) {
      map['device_contact_id'] = Variable<String>(deviceContactId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      displayName: Value(displayName),
      avatarColor: avatarColor == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarColor),
      isStarred: Value(isStarred),
      facebookUrl: facebookUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(facebookUrl),
      linkedinUrl: linkedinUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedinUrl),
      gmailAddress: gmailAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(gmailAddress),
      pinnedNote: pinnedNote == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedNote),
      lastSyncTime: Value(lastSyncTime),
      company: company == null && nullToAbsent
          ? const Value.absent()
          : Value(company),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      birthday: birthday == null && nullToAbsent
          ? const Value.absent()
          : Value(birthday),
      about: about == null && nullToAbsent
          ? const Value.absent()
          : Value(about),
      cadenceDays: cadenceDays == null && nullToAbsent
          ? const Value.absent()
          : Value(cadenceDays),
      cadenceSnoozedUntil: cadenceSnoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(cadenceSnoozedUntil),
      lastInteractionAt: lastInteractionAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInteractionAt),
      doNotMessage: Value(doNotMessage),
      deviceContactId: deviceContactId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceContactId),
      source: Value(source),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Contact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<int>(json['id']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarColor: serializer.fromJson<String?>(json['avatarColor']),
      isStarred: serializer.fromJson<int>(json['isStarred']),
      facebookUrl: serializer.fromJson<String?>(json['facebookUrl']),
      linkedinUrl: serializer.fromJson<String?>(json['linkedinUrl']),
      gmailAddress: serializer.fromJson<String?>(json['gmailAddress']),
      pinnedNote: serializer.fromJson<String?>(json['pinnedNote']),
      lastSyncTime: serializer.fromJson<int>(json['lastSyncTime']),
      company: serializer.fromJson<String?>(json['company']),
      role: serializer.fromJson<String?>(json['role']),
      city: serializer.fromJson<String?>(json['city']),
      email: serializer.fromJson<String?>(json['email']),
      birthday: serializer.fromJson<String?>(json['birthday']),
      about: serializer.fromJson<String?>(json['about']),
      cadenceDays: serializer.fromJson<int?>(json['cadenceDays']),
      cadenceSnoozedUntil: serializer.fromJson<int?>(
        json['cadenceSnoozedUntil'],
      ),
      lastInteractionAt: serializer.fromJson<int?>(json['lastInteractionAt']),
      doNotMessage: serializer.fromJson<int>(json['doNotMessage']),
      deviceContactId: serializer.fromJson<String?>(json['deviceContactId']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'displayName': serializer.toJson<String>(displayName),
      'avatarColor': serializer.toJson<String?>(avatarColor),
      'isStarred': serializer.toJson<int>(isStarred),
      'facebookUrl': serializer.toJson<String?>(facebookUrl),
      'linkedinUrl': serializer.toJson<String?>(linkedinUrl),
      'gmailAddress': serializer.toJson<String?>(gmailAddress),
      'pinnedNote': serializer.toJson<String?>(pinnedNote),
      'lastSyncTime': serializer.toJson<int>(lastSyncTime),
      'company': serializer.toJson<String?>(company),
      'role': serializer.toJson<String?>(role),
      'city': serializer.toJson<String?>(city),
      'email': serializer.toJson<String?>(email),
      'birthday': serializer.toJson<String?>(birthday),
      'about': serializer.toJson<String?>(about),
      'cadenceDays': serializer.toJson<int?>(cadenceDays),
      'cadenceSnoozedUntil': serializer.toJson<int?>(cadenceSnoozedUntil),
      'lastInteractionAt': serializer.toJson<int?>(lastInteractionAt),
      'doNotMessage': serializer.toJson<int>(doNotMessage),
      'deviceContactId': serializer.toJson<String?>(deviceContactId),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<int?>(createdAt),
    };
  }

  Contact copyWith({
    int? id,
    Value<String?> phoneNumber = const Value.absent(),
    String? displayName,
    Value<String?> avatarColor = const Value.absent(),
    int? isStarred,
    Value<String?> facebookUrl = const Value.absent(),
    Value<String?> linkedinUrl = const Value.absent(),
    Value<String?> gmailAddress = const Value.absent(),
    Value<String?> pinnedNote = const Value.absent(),
    int? lastSyncTime,
    Value<String?> company = const Value.absent(),
    Value<String?> role = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> birthday = const Value.absent(),
    Value<String?> about = const Value.absent(),
    Value<int?> cadenceDays = const Value.absent(),
    Value<int?> cadenceSnoozedUntil = const Value.absent(),
    Value<int?> lastInteractionAt = const Value.absent(),
    int? doNotMessage,
    Value<String?> deviceContactId = const Value.absent(),
    String? source,
    Value<int?> createdAt = const Value.absent(),
  }) => Contact(
    id: id ?? this.id,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
    displayName: displayName ?? this.displayName,
    avatarColor: avatarColor.present ? avatarColor.value : this.avatarColor,
    isStarred: isStarred ?? this.isStarred,
    facebookUrl: facebookUrl.present ? facebookUrl.value : this.facebookUrl,
    linkedinUrl: linkedinUrl.present ? linkedinUrl.value : this.linkedinUrl,
    gmailAddress: gmailAddress.present ? gmailAddress.value : this.gmailAddress,
    pinnedNote: pinnedNote.present ? pinnedNote.value : this.pinnedNote,
    lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    company: company.present ? company.value : this.company,
    role: role.present ? role.value : this.role,
    city: city.present ? city.value : this.city,
    email: email.present ? email.value : this.email,
    birthday: birthday.present ? birthday.value : this.birthday,
    about: about.present ? about.value : this.about,
    cadenceDays: cadenceDays.present ? cadenceDays.value : this.cadenceDays,
    cadenceSnoozedUntil: cadenceSnoozedUntil.present
        ? cadenceSnoozedUntil.value
        : this.cadenceSnoozedUntil,
    lastInteractionAt: lastInteractionAt.present
        ? lastInteractionAt.value
        : this.lastInteractionAt,
    doNotMessage: doNotMessage ?? this.doNotMessage,
    deviceContactId: deviceContactId.present
        ? deviceContactId.value
        : this.deviceContactId,
    source: source ?? this.source,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarColor: data.avatarColor.present
          ? data.avatarColor.value
          : this.avatarColor,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      facebookUrl: data.facebookUrl.present
          ? data.facebookUrl.value
          : this.facebookUrl,
      linkedinUrl: data.linkedinUrl.present
          ? data.linkedinUrl.value
          : this.linkedinUrl,
      gmailAddress: data.gmailAddress.present
          ? data.gmailAddress.value
          : this.gmailAddress,
      pinnedNote: data.pinnedNote.present
          ? data.pinnedNote.value
          : this.pinnedNote,
      lastSyncTime: data.lastSyncTime.present
          ? data.lastSyncTime.value
          : this.lastSyncTime,
      company: data.company.present ? data.company.value : this.company,
      role: data.role.present ? data.role.value : this.role,
      city: data.city.present ? data.city.value : this.city,
      email: data.email.present ? data.email.value : this.email,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      about: data.about.present ? data.about.value : this.about,
      cadenceDays: data.cadenceDays.present
          ? data.cadenceDays.value
          : this.cadenceDays,
      cadenceSnoozedUntil: data.cadenceSnoozedUntil.present
          ? data.cadenceSnoozedUntil.value
          : this.cadenceSnoozedUntil,
      lastInteractionAt: data.lastInteractionAt.present
          ? data.lastInteractionAt.value
          : this.lastInteractionAt,
      doNotMessage: data.doNotMessage.present
          ? data.doNotMessage.value
          : this.doNotMessage,
      deviceContactId: data.deviceContactId.present
          ? data.deviceContactId.value
          : this.deviceContactId,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('displayName: $displayName, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('isStarred: $isStarred, ')
          ..write('facebookUrl: $facebookUrl, ')
          ..write('linkedinUrl: $linkedinUrl, ')
          ..write('gmailAddress: $gmailAddress, ')
          ..write('pinnedNote: $pinnedNote, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('city: $city, ')
          ..write('email: $email, ')
          ..write('birthday: $birthday, ')
          ..write('about: $about, ')
          ..write('cadenceDays: $cadenceDays, ')
          ..write('cadenceSnoozedUntil: $cadenceSnoozedUntil, ')
          ..write('lastInteractionAt: $lastInteractionAt, ')
          ..write('doNotMessage: $doNotMessage, ')
          ..write('deviceContactId: $deviceContactId, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    phoneNumber,
    displayName,
    avatarColor,
    isStarred,
    facebookUrl,
    linkedinUrl,
    gmailAddress,
    pinnedNote,
    lastSyncTime,
    company,
    role,
    city,
    email,
    birthday,
    about,
    cadenceDays,
    cadenceSnoozedUntil,
    lastInteractionAt,
    doNotMessage,
    deviceContactId,
    source,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.phoneNumber == this.phoneNumber &&
          other.displayName == this.displayName &&
          other.avatarColor == this.avatarColor &&
          other.isStarred == this.isStarred &&
          other.facebookUrl == this.facebookUrl &&
          other.linkedinUrl == this.linkedinUrl &&
          other.gmailAddress == this.gmailAddress &&
          other.pinnedNote == this.pinnedNote &&
          other.lastSyncTime == this.lastSyncTime &&
          other.company == this.company &&
          other.role == this.role &&
          other.city == this.city &&
          other.email == this.email &&
          other.birthday == this.birthday &&
          other.about == this.about &&
          other.cadenceDays == this.cadenceDays &&
          other.cadenceSnoozedUntil == this.cadenceSnoozedUntil &&
          other.lastInteractionAt == this.lastInteractionAt &&
          other.doNotMessage == this.doNotMessage &&
          other.deviceContactId == this.deviceContactId &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<int> id;
  final Value<String?> phoneNumber;
  final Value<String> displayName;
  final Value<String?> avatarColor;
  final Value<int> isStarred;
  final Value<String?> facebookUrl;
  final Value<String?> linkedinUrl;
  final Value<String?> gmailAddress;
  final Value<String?> pinnedNote;
  final Value<int> lastSyncTime;
  final Value<String?> company;
  final Value<String?> role;
  final Value<String?> city;
  final Value<String?> email;
  final Value<String?> birthday;
  final Value<String?> about;
  final Value<int?> cadenceDays;
  final Value<int?> cadenceSnoozedUntil;
  final Value<int?> lastInteractionAt;
  final Value<int> doNotMessage;
  final Value<String?> deviceContactId;
  final Value<String> source;
  final Value<int?> createdAt;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarColor = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.facebookUrl = const Value.absent(),
    this.linkedinUrl = const Value.absent(),
    this.gmailAddress = const Value.absent(),
    this.pinnedNote = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.company = const Value.absent(),
    this.role = const Value.absent(),
    this.city = const Value.absent(),
    this.email = const Value.absent(),
    this.birthday = const Value.absent(),
    this.about = const Value.absent(),
    this.cadenceDays = const Value.absent(),
    this.cadenceSnoozedUntil = const Value.absent(),
    this.lastInteractionAt = const Value.absent(),
    this.doNotMessage = const Value.absent(),
    this.deviceContactId = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ContactsCompanion.insert({
    this.id = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    required String displayName,
    this.avatarColor = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.facebookUrl = const Value.absent(),
    this.linkedinUrl = const Value.absent(),
    this.gmailAddress = const Value.absent(),
    this.pinnedNote = const Value.absent(),
    this.lastSyncTime = const Value.absent(),
    this.company = const Value.absent(),
    this.role = const Value.absent(),
    this.city = const Value.absent(),
    this.email = const Value.absent(),
    this.birthday = const Value.absent(),
    this.about = const Value.absent(),
    this.cadenceDays = const Value.absent(),
    this.cadenceSnoozedUntil = const Value.absent(),
    this.lastInteractionAt = const Value.absent(),
    this.doNotMessage = const Value.absent(),
    this.deviceContactId = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : displayName = Value(displayName);
  static Insertable<Contact> custom({
    Expression<int>? id,
    Expression<String>? phoneNumber,
    Expression<String>? displayName,
    Expression<String>? avatarColor,
    Expression<int>? isStarred,
    Expression<String>? facebookUrl,
    Expression<String>? linkedinUrl,
    Expression<String>? gmailAddress,
    Expression<String>? pinnedNote,
    Expression<int>? lastSyncTime,
    Expression<String>? company,
    Expression<String>? role,
    Expression<String>? city,
    Expression<String>? email,
    Expression<String>? birthday,
    Expression<String>? about,
    Expression<int>? cadenceDays,
    Expression<int>? cadenceSnoozedUntil,
    Expression<int>? lastInteractionAt,
    Expression<int>? doNotMessage,
    Expression<String>? deviceContactId,
    Expression<String>? source,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (displayName != null) 'display_name': displayName,
      if (avatarColor != null) 'avatar_color': avatarColor,
      if (isStarred != null) 'is_starred': isStarred,
      if (facebookUrl != null) 'facebook_url': facebookUrl,
      if (linkedinUrl != null) 'linkedin_url': linkedinUrl,
      if (gmailAddress != null) 'gmail_address': gmailAddress,
      if (pinnedNote != null) 'pinned_note': pinnedNote,
      if (lastSyncTime != null) 'last_sync_time': lastSyncTime,
      if (company != null) 'company': company,
      if (role != null) 'role': role,
      if (city != null) 'city': city,
      if (email != null) 'email': email,
      if (birthday != null) 'birthday': birthday,
      if (about != null) 'about': about,
      if (cadenceDays != null) 'cadence_days': cadenceDays,
      if (cadenceSnoozedUntil != null)
        'cadence_snoozed_until': cadenceSnoozedUntil,
      if (lastInteractionAt != null) 'last_interaction_at': lastInteractionAt,
      if (doNotMessage != null) 'do_not_message': doNotMessage,
      if (deviceContactId != null) 'device_contact_id': deviceContactId,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ContactsCompanion copyWith({
    Value<int>? id,
    Value<String?>? phoneNumber,
    Value<String>? displayName,
    Value<String?>? avatarColor,
    Value<int>? isStarred,
    Value<String?>? facebookUrl,
    Value<String?>? linkedinUrl,
    Value<String?>? gmailAddress,
    Value<String?>? pinnedNote,
    Value<int>? lastSyncTime,
    Value<String?>? company,
    Value<String?>? role,
    Value<String?>? city,
    Value<String?>? email,
    Value<String?>? birthday,
    Value<String?>? about,
    Value<int?>? cadenceDays,
    Value<int?>? cadenceSnoozedUntil,
    Value<int?>? lastInteractionAt,
    Value<int>? doNotMessage,
    Value<String?>? deviceContactId,
    Value<String>? source,
    Value<int?>? createdAt,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      avatarColor: avatarColor ?? this.avatarColor,
      isStarred: isStarred ?? this.isStarred,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      gmailAddress: gmailAddress ?? this.gmailAddress,
      pinnedNote: pinnedNote ?? this.pinnedNote,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      company: company ?? this.company,
      role: role ?? this.role,
      city: city ?? this.city,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      about: about ?? this.about,
      cadenceDays: cadenceDays ?? this.cadenceDays,
      cadenceSnoozedUntil: cadenceSnoozedUntil ?? this.cadenceSnoozedUntil,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      doNotMessage: doNotMessage ?? this.doNotMessage,
      deviceContactId: deviceContactId ?? this.deviceContactId,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarColor.present) {
      map['avatar_color'] = Variable<String>(avatarColor.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<int>(isStarred.value);
    }
    if (facebookUrl.present) {
      map['facebook_url'] = Variable<String>(facebookUrl.value);
    }
    if (linkedinUrl.present) {
      map['linkedin_url'] = Variable<String>(linkedinUrl.value);
    }
    if (gmailAddress.present) {
      map['gmail_address'] = Variable<String>(gmailAddress.value);
    }
    if (pinnedNote.present) {
      map['pinned_note'] = Variable<String>(pinnedNote.value);
    }
    if (lastSyncTime.present) {
      map['last_sync_time'] = Variable<int>(lastSyncTime.value);
    }
    if (company.present) {
      map['company'] = Variable<String>(company.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<String>(birthday.value);
    }
    if (about.present) {
      map['about'] = Variable<String>(about.value);
    }
    if (cadenceDays.present) {
      map['cadence_days'] = Variable<int>(cadenceDays.value);
    }
    if (cadenceSnoozedUntil.present) {
      map['cadence_snoozed_until'] = Variable<int>(cadenceSnoozedUntil.value);
    }
    if (lastInteractionAt.present) {
      map['last_interaction_at'] = Variable<int>(lastInteractionAt.value);
    }
    if (doNotMessage.present) {
      map['do_not_message'] = Variable<int>(doNotMessage.value);
    }
    if (deviceContactId.present) {
      map['device_contact_id'] = Variable<String>(deviceContactId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('displayName: $displayName, ')
          ..write('avatarColor: $avatarColor, ')
          ..write('isStarred: $isStarred, ')
          ..write('facebookUrl: $facebookUrl, ')
          ..write('linkedinUrl: $linkedinUrl, ')
          ..write('gmailAddress: $gmailAddress, ')
          ..write('pinnedNote: $pinnedNote, ')
          ..write('lastSyncTime: $lastSyncTime, ')
          ..write('company: $company, ')
          ..write('role: $role, ')
          ..write('city: $city, ')
          ..write('email: $email, ')
          ..write('birthday: $birthday, ')
          ..write('about: $about, ')
          ..write('cadenceDays: $cadenceDays, ')
          ..write('cadenceSnoozedUntil: $cadenceSnoozedUntil, ')
          ..write('lastInteractionAt: $lastInteractionAt, ')
          ..write('doNotMessage: $doNotMessage, ')
          ..write('deviceContactId: $deviceContactId, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TimelineEntriesTable extends TimelineEntries
    with TableInfo<$TimelineEntriesTable, TimelineEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentPathMeta = const VerificationMeta(
    'attachmentPath',
  );
  @override
  late final GeneratedColumn<String> attachmentPath = GeneratedColumn<String>(
    'attachment_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nativeMessageIdMeta = const VerificationMeta(
    'nativeMessageId',
  );
  @override
  late final GeneratedColumn<String> nativeMessageId = GeneratedColumn<String>(
    'native_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<int> isPinned = GeneratedColumn<int>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeNameMeta = const VerificationMeta(
    'placeName',
  );
  @override
  late final GeneratedColumn<String> placeName = GeneratedColumn<String>(
    'place_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suggestedAmountMeta = const VerificationMeta(
    'suggestedAmount',
  );
  @override
  late final GeneratedColumn<double> suggestedAmount = GeneratedColumn<double>(
    'suggested_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suggestionStateMeta = const VerificationMeta(
    'suggestionState',
  );
  @override
  late final GeneratedColumn<String> suggestionState = GeneratedColumn<String>(
    'suggestion_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<int> hidden = GeneratedColumn<int>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outboxClientIdMeta = const VerificationMeta(
    'outboxClientId',
  );
  @override
  late final GeneratedColumn<String> outboxClientId = GeneratedColumn<String>(
    'outbox_client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<int> editedAt = GeneratedColumn<int>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    type,
    timestamp,
    content,
    amount,
    attachmentPath,
    nativeMessageId,
    isPinned,
    note,
    outcome,
    durationSeconds,
    placeName,
    lat,
    lng,
    currency,
    paymentStatus,
    suggestedAmount,
    suggestionState,
    reviewedAt,
    hidden,
    source,
    outboxClientId,
    editedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('attachment_path')) {
      context.handle(
        _attachmentPathMeta,
        attachmentPath.isAcceptableOrUnknown(
          data['attachment_path']!,
          _attachmentPathMeta,
        ),
      );
    }
    if (data.containsKey('native_message_id')) {
      context.handle(
        _nativeMessageIdMeta,
        nativeMessageId.isAcceptableOrUnknown(
          data['native_message_id']!,
          _nativeMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('place_name')) {
      context.handle(
        _placeNameMeta,
        placeName.isAcceptableOrUnknown(data['place_name']!, _placeNameMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    }
    if (data.containsKey('suggested_amount')) {
      context.handle(
        _suggestedAmountMeta,
        suggestedAmount.isAcceptableOrUnknown(
          data['suggested_amount']!,
          _suggestedAmountMeta,
        ),
      );
    }
    if (data.containsKey('suggestion_state')) {
      context.handle(
        _suggestionStateMeta,
        suggestionState.isAcceptableOrUnknown(
          data['suggestion_state']!,
          _suggestionStateMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('outbox_client_id')) {
      context.handle(
        _outboxClientIdMeta,
        outboxClientId.isAcceptableOrUnknown(
          data['outbox_client_id']!,
          _outboxClientIdMeta,
        ),
      );
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      attachmentPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_path'],
      ),
      nativeMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_message_id'],
      ),
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_pinned'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      placeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_name'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      ),
      suggestedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}suggested_amount'],
      ),
      suggestionState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggestion_state'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_at'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hidden'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      outboxClientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outbox_client_id'],
      ),
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edited_at'],
      ),
    );
  }

  @override
  $TimelineEntriesTable createAlias(String alias) {
    return $TimelineEntriesTable(attachedDatabase, alias);
  }
}

class TimelineEntry extends DataClass implements Insertable<TimelineEntry> {
  final int id;
  final int? contactId;
  final String type;
  final int timestamp;
  final String? content;
  final double? amount;
  final String? attachmentPath;
  final String? nativeMessageId;
  final int isPinned;
  final String? note;
  final String? outcome;
  final int? durationSeconds;
  final String? placeName;
  final double? lat;
  final double? lng;
  final String? currency;
  final String? paymentStatus;
  final double? suggestedAmount;
  final String? suggestionState;
  final int? reviewedAt;
  final int hidden;
  final String? source;
  final String? outboxClientId;
  final int? editedAt;
  const TimelineEntry({
    required this.id,
    this.contactId,
    required this.type,
    required this.timestamp,
    this.content,
    this.amount,
    this.attachmentPath,
    this.nativeMessageId,
    required this.isPinned,
    this.note,
    this.outcome,
    this.durationSeconds,
    this.placeName,
    this.lat,
    this.lng,
    this.currency,
    this.paymentStatus,
    this.suggestedAmount,
    this.suggestionState,
    this.reviewedAt,
    required this.hidden,
    this.source,
    this.outboxClientId,
    this.editedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    map['type'] = Variable<String>(type);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || attachmentPath != null) {
      map['attachment_path'] = Variable<String>(attachmentPath);
    }
    if (!nullToAbsent || nativeMessageId != null) {
      map['native_message_id'] = Variable<String>(nativeMessageId);
    }
    map['is_pinned'] = Variable<int>(isPinned);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || placeName != null) {
      map['place_name'] = Variable<String>(placeName);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || paymentStatus != null) {
      map['payment_status'] = Variable<String>(paymentStatus);
    }
    if (!nullToAbsent || suggestedAmount != null) {
      map['suggested_amount'] = Variable<double>(suggestedAmount);
    }
    if (!nullToAbsent || suggestionState != null) {
      map['suggestion_state'] = Variable<String>(suggestionState);
    }
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<int>(reviewedAt);
    }
    map['hidden'] = Variable<int>(hidden);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || outboxClientId != null) {
      map['outbox_client_id'] = Variable<String>(outboxClientId);
    }
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<int>(editedAt);
    }
    return map;
  }

  TimelineEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimelineEntriesCompanion(
      id: Value(id),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      type: Value(type),
      timestamp: Value(timestamp),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      attachmentPath: attachmentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentPath),
      nativeMessageId: nativeMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(nativeMessageId),
      isPinned: Value(isPinned),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      placeName: placeName == null && nullToAbsent
          ? const Value.absent()
          : Value(placeName),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      paymentStatus: paymentStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentStatus),
      suggestedAmount: suggestedAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedAmount),
      suggestionState: suggestionState == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestionState),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
      hidden: Value(hidden),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      outboxClientId: outboxClientId == null && nullToAbsent
          ? const Value.absent()
          : Value(outboxClientId),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
    );
  }

  factory TimelineEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineEntry(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      type: serializer.fromJson<String>(json['type']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      content: serializer.fromJson<String?>(json['content']),
      amount: serializer.fromJson<double?>(json['amount']),
      attachmentPath: serializer.fromJson<String?>(json['attachmentPath']),
      nativeMessageId: serializer.fromJson<String?>(json['nativeMessageId']),
      isPinned: serializer.fromJson<int>(json['isPinned']),
      note: serializer.fromJson<String?>(json['note']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      placeName: serializer.fromJson<String?>(json['placeName']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      currency: serializer.fromJson<String?>(json['currency']),
      paymentStatus: serializer.fromJson<String?>(json['paymentStatus']),
      suggestedAmount: serializer.fromJson<double?>(json['suggestedAmount']),
      suggestionState: serializer.fromJson<String?>(json['suggestionState']),
      reviewedAt: serializer.fromJson<int?>(json['reviewedAt']),
      hidden: serializer.fromJson<int>(json['hidden']),
      source: serializer.fromJson<String?>(json['source']),
      outboxClientId: serializer.fromJson<String?>(json['outboxClientId']),
      editedAt: serializer.fromJson<int?>(json['editedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int?>(contactId),
      'type': serializer.toJson<String>(type),
      'timestamp': serializer.toJson<int>(timestamp),
      'content': serializer.toJson<String?>(content),
      'amount': serializer.toJson<double?>(amount),
      'attachmentPath': serializer.toJson<String?>(attachmentPath),
      'nativeMessageId': serializer.toJson<String?>(nativeMessageId),
      'isPinned': serializer.toJson<int>(isPinned),
      'note': serializer.toJson<String?>(note),
      'outcome': serializer.toJson<String?>(outcome),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'placeName': serializer.toJson<String?>(placeName),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'currency': serializer.toJson<String?>(currency),
      'paymentStatus': serializer.toJson<String?>(paymentStatus),
      'suggestedAmount': serializer.toJson<double?>(suggestedAmount),
      'suggestionState': serializer.toJson<String?>(suggestionState),
      'reviewedAt': serializer.toJson<int?>(reviewedAt),
      'hidden': serializer.toJson<int>(hidden),
      'source': serializer.toJson<String?>(source),
      'outboxClientId': serializer.toJson<String?>(outboxClientId),
      'editedAt': serializer.toJson<int?>(editedAt),
    };
  }

  TimelineEntry copyWith({
    int? id,
    Value<int?> contactId = const Value.absent(),
    String? type,
    int? timestamp,
    Value<String?> content = const Value.absent(),
    Value<double?> amount = const Value.absent(),
    Value<String?> attachmentPath = const Value.absent(),
    Value<String?> nativeMessageId = const Value.absent(),
    int? isPinned,
    Value<String?> note = const Value.absent(),
    Value<String?> outcome = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<String?> placeName = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    Value<String?> paymentStatus = const Value.absent(),
    Value<double?> suggestedAmount = const Value.absent(),
    Value<String?> suggestionState = const Value.absent(),
    Value<int?> reviewedAt = const Value.absent(),
    int? hidden,
    Value<String?> source = const Value.absent(),
    Value<String?> outboxClientId = const Value.absent(),
    Value<int?> editedAt = const Value.absent(),
  }) => TimelineEntry(
    id: id ?? this.id,
    contactId: contactId.present ? contactId.value : this.contactId,
    type: type ?? this.type,
    timestamp: timestamp ?? this.timestamp,
    content: content.present ? content.value : this.content,
    amount: amount.present ? amount.value : this.amount,
    attachmentPath: attachmentPath.present
        ? attachmentPath.value
        : this.attachmentPath,
    nativeMessageId: nativeMessageId.present
        ? nativeMessageId.value
        : this.nativeMessageId,
    isPinned: isPinned ?? this.isPinned,
    note: note.present ? note.value : this.note,
    outcome: outcome.present ? outcome.value : this.outcome,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    placeName: placeName.present ? placeName.value : this.placeName,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    currency: currency.present ? currency.value : this.currency,
    paymentStatus: paymentStatus.present
        ? paymentStatus.value
        : this.paymentStatus,
    suggestedAmount: suggestedAmount.present
        ? suggestedAmount.value
        : this.suggestedAmount,
    suggestionState: suggestionState.present
        ? suggestionState.value
        : this.suggestionState,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
    hidden: hidden ?? this.hidden,
    source: source.present ? source.value : this.source,
    outboxClientId: outboxClientId.present
        ? outboxClientId.value
        : this.outboxClientId,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
  );
  TimelineEntry copyWithCompanion(TimelineEntriesCompanion data) {
    return TimelineEntry(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      type: data.type.present ? data.type.value : this.type,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      content: data.content.present ? data.content.value : this.content,
      amount: data.amount.present ? data.amount.value : this.amount,
      attachmentPath: data.attachmentPath.present
          ? data.attachmentPath.value
          : this.attachmentPath,
      nativeMessageId: data.nativeMessageId.present
          ? data.nativeMessageId.value
          : this.nativeMessageId,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      note: data.note.present ? data.note.value : this.note,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      placeName: data.placeName.present ? data.placeName.value : this.placeName,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      suggestedAmount: data.suggestedAmount.present
          ? data.suggestedAmount.value
          : this.suggestedAmount,
      suggestionState: data.suggestionState.present
          ? data.suggestionState.value
          : this.suggestionState,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      source: data.source.present ? data.source.value : this.source,
      outboxClientId: data.outboxClientId.present
          ? data.outboxClientId.value
          : this.outboxClientId,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEntry(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('content: $content, ')
          ..write('amount: $amount, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('nativeMessageId: $nativeMessageId, ')
          ..write('isPinned: $isPinned, ')
          ..write('note: $note, ')
          ..write('outcome: $outcome, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('placeName: $placeName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('currency: $currency, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('suggestedAmount: $suggestedAmount, ')
          ..write('suggestionState: $suggestionState, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('hidden: $hidden, ')
          ..write('source: $source, ')
          ..write('outboxClientId: $outboxClientId, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    contactId,
    type,
    timestamp,
    content,
    amount,
    attachmentPath,
    nativeMessageId,
    isPinned,
    note,
    outcome,
    durationSeconds,
    placeName,
    lat,
    lng,
    currency,
    paymentStatus,
    suggestedAmount,
    suggestionState,
    reviewedAt,
    hidden,
    source,
    outboxClientId,
    editedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineEntry &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.type == this.type &&
          other.timestamp == this.timestamp &&
          other.content == this.content &&
          other.amount == this.amount &&
          other.attachmentPath == this.attachmentPath &&
          other.nativeMessageId == this.nativeMessageId &&
          other.isPinned == this.isPinned &&
          other.note == this.note &&
          other.outcome == this.outcome &&
          other.durationSeconds == this.durationSeconds &&
          other.placeName == this.placeName &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.currency == this.currency &&
          other.paymentStatus == this.paymentStatus &&
          other.suggestedAmount == this.suggestedAmount &&
          other.suggestionState == this.suggestionState &&
          other.reviewedAt == this.reviewedAt &&
          other.hidden == this.hidden &&
          other.source == this.source &&
          other.outboxClientId == this.outboxClientId &&
          other.editedAt == this.editedAt);
}

class TimelineEntriesCompanion extends UpdateCompanion<TimelineEntry> {
  final Value<int> id;
  final Value<int?> contactId;
  final Value<String> type;
  final Value<int> timestamp;
  final Value<String?> content;
  final Value<double?> amount;
  final Value<String?> attachmentPath;
  final Value<String?> nativeMessageId;
  final Value<int> isPinned;
  final Value<String?> note;
  final Value<String?> outcome;
  final Value<int?> durationSeconds;
  final Value<String?> placeName;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String?> currency;
  final Value<String?> paymentStatus;
  final Value<double?> suggestedAmount;
  final Value<String?> suggestionState;
  final Value<int?> reviewedAt;
  final Value<int> hidden;
  final Value<String?> source;
  final Value<String?> outboxClientId;
  final Value<int?> editedAt;
  const TimelineEntriesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.type = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.content = const Value.absent(),
    this.amount = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.nativeMessageId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.note = const Value.absent(),
    this.outcome = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.placeName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.suggestedAmount = const Value.absent(),
    this.suggestionState = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.hidden = const Value.absent(),
    this.source = const Value.absent(),
    this.outboxClientId = const Value.absent(),
    this.editedAt = const Value.absent(),
  });
  TimelineEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    required String type,
    required int timestamp,
    this.content = const Value.absent(),
    this.amount = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.nativeMessageId = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.note = const Value.absent(),
    this.outcome = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.placeName = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.suggestedAmount = const Value.absent(),
    this.suggestionState = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.hidden = const Value.absent(),
    this.source = const Value.absent(),
    this.outboxClientId = const Value.absent(),
    this.editedAt = const Value.absent(),
  }) : type = Value(type),
       timestamp = Value(timestamp);
  static Insertable<TimelineEntry> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? type,
    Expression<int>? timestamp,
    Expression<String>? content,
    Expression<double>? amount,
    Expression<String>? attachmentPath,
    Expression<String>? nativeMessageId,
    Expression<int>? isPinned,
    Expression<String>? note,
    Expression<String>? outcome,
    Expression<int>? durationSeconds,
    Expression<String>? placeName,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? currency,
    Expression<String>? paymentStatus,
    Expression<double>? suggestedAmount,
    Expression<String>? suggestionState,
    Expression<int>? reviewedAt,
    Expression<int>? hidden,
    Expression<String>? source,
    Expression<String>? outboxClientId,
    Expression<int>? editedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (type != null) 'type': type,
      if (timestamp != null) 'timestamp': timestamp,
      if (content != null) 'content': content,
      if (amount != null) 'amount': amount,
      if (attachmentPath != null) 'attachment_path': attachmentPath,
      if (nativeMessageId != null) 'native_message_id': nativeMessageId,
      if (isPinned != null) 'is_pinned': isPinned,
      if (note != null) 'note': note,
      if (outcome != null) 'outcome': outcome,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (placeName != null) 'place_name': placeName,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (currency != null) 'currency': currency,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (suggestedAmount != null) 'suggested_amount': suggestedAmount,
      if (suggestionState != null) 'suggestion_state': suggestionState,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (hidden != null) 'hidden': hidden,
      if (source != null) 'source': source,
      if (outboxClientId != null) 'outbox_client_id': outboxClientId,
      if (editedAt != null) 'edited_at': editedAt,
    });
  }

  TimelineEntriesCompanion copyWith({
    Value<int>? id,
    Value<int?>? contactId,
    Value<String>? type,
    Value<int>? timestamp,
    Value<String?>? content,
    Value<double?>? amount,
    Value<String?>? attachmentPath,
    Value<String?>? nativeMessageId,
    Value<int>? isPinned,
    Value<String?>? note,
    Value<String?>? outcome,
    Value<int?>? durationSeconds,
    Value<String?>? placeName,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String?>? currency,
    Value<String?>? paymentStatus,
    Value<double?>? suggestedAmount,
    Value<String?>? suggestionState,
    Value<int?>? reviewedAt,
    Value<int>? hidden,
    Value<String?>? source,
    Value<String?>? outboxClientId,
    Value<int?>? editedAt,
  }) {
    return TimelineEntriesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      content: content ?? this.content,
      amount: amount ?? this.amount,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      nativeMessageId: nativeMessageId ?? this.nativeMessageId,
      isPinned: isPinned ?? this.isPinned,
      note: note ?? this.note,
      outcome: outcome ?? this.outcome,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      placeName: placeName ?? this.placeName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      currency: currency ?? this.currency,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      suggestedAmount: suggestedAmount ?? this.suggestedAmount,
      suggestionState: suggestionState ?? this.suggestionState,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      hidden: hidden ?? this.hidden,
      source: source ?? this.source,
      outboxClientId: outboxClientId ?? this.outboxClientId,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (attachmentPath.present) {
      map['attachment_path'] = Variable<String>(attachmentPath.value);
    }
    if (nativeMessageId.present) {
      map['native_message_id'] = Variable<String>(nativeMessageId.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<int>(isPinned.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (placeName.present) {
      map['place_name'] = Variable<String>(placeName.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (suggestedAmount.present) {
      map['suggested_amount'] = Variable<double>(suggestedAmount.value);
    }
    if (suggestionState.present) {
      map['suggestion_state'] = Variable<String>(suggestionState.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<int>(hidden.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (outboxClientId.present) {
      map['outbox_client_id'] = Variable<String>(outboxClientId.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<int>(editedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineEntriesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('type: $type, ')
          ..write('timestamp: $timestamp, ')
          ..write('content: $content, ')
          ..write('amount: $amount, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('nativeMessageId: $nativeMessageId, ')
          ..write('isPinned: $isPinned, ')
          ..write('note: $note, ')
          ..write('outcome: $outcome, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('placeName: $placeName, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('currency: $currency, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('suggestedAmount: $suggestedAmount, ')
          ..write('suggestionState: $suggestionState, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('hidden: $hidden, ')
          ..write('source: $source, ')
          ..write('outboxClientId: $outboxClientId, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }
}

class $ScheduledSmsEntriesTable extends ScheduledSmsEntries
    with TableInfo<$ScheduledSmsEntriesTable, ScheduledSmsEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledSmsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<int> scheduledTime = GeneratedColumn<int>(
    'scheduled_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSentMeta = const VerificationMeta('isSent');
  @override
  late final GeneratedColumn<int> isSent = GeneratedColumn<int>(
    'is_sent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bulkJobIdMeta = const VerificationMeta(
    'bulkJobId',
  );
  @override
  late final GeneratedColumn<int> bulkJobId = GeneratedColumn<int>(
    'bulk_job_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    phoneNumber,
    message,
    scheduledTime,
    isSent,
    bulkJobId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_sms';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduledSmsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('is_sent')) {
      context.handle(
        _isSentMeta,
        isSent.isAcceptableOrUnknown(data['is_sent']!, _isSentMeta),
      );
    }
    if (data.containsKey('bulk_job_id')) {
      context.handle(
        _bulkJobIdMeta,
        bulkJobId.isAcceptableOrUnknown(data['bulk_job_id']!, _bulkJobIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduledSmsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledSmsEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_time'],
      )!,
      isSent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_sent'],
      )!,
      bulkJobId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bulk_job_id'],
      ),
    );
  }

  @override
  $ScheduledSmsEntriesTable createAlias(String alias) {
    return $ScheduledSmsEntriesTable(attachedDatabase, alias);
  }
}

class ScheduledSmsEntry extends DataClass
    implements Insertable<ScheduledSmsEntry> {
  final int id;
  final int? contactId;
  final String phoneNumber;
  final String message;
  final int scheduledTime;
  final int isSent;
  final int? bulkJobId;
  const ScheduledSmsEntry({
    required this.id,
    this.contactId,
    required this.phoneNumber,
    required this.message,
    required this.scheduledTime,
    required this.isSent,
    this.bulkJobId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    map['phone_number'] = Variable<String>(phoneNumber);
    map['message'] = Variable<String>(message);
    map['scheduled_time'] = Variable<int>(scheduledTime);
    map['is_sent'] = Variable<int>(isSent);
    if (!nullToAbsent || bulkJobId != null) {
      map['bulk_job_id'] = Variable<int>(bulkJobId);
    }
    return map;
  }

  ScheduledSmsEntriesCompanion toCompanion(bool nullToAbsent) {
    return ScheduledSmsEntriesCompanion(
      id: Value(id),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      phoneNumber: Value(phoneNumber),
      message: Value(message),
      scheduledTime: Value(scheduledTime),
      isSent: Value(isSent),
      bulkJobId: bulkJobId == null && nullToAbsent
          ? const Value.absent()
          : Value(bulkJobId),
    );
  }

  factory ScheduledSmsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledSmsEntry(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      message: serializer.fromJson<String>(json['message']),
      scheduledTime: serializer.fromJson<int>(json['scheduledTime']),
      isSent: serializer.fromJson<int>(json['isSent']),
      bulkJobId: serializer.fromJson<int?>(json['bulkJobId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int?>(contactId),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'message': serializer.toJson<String>(message),
      'scheduledTime': serializer.toJson<int>(scheduledTime),
      'isSent': serializer.toJson<int>(isSent),
      'bulkJobId': serializer.toJson<int?>(bulkJobId),
    };
  }

  ScheduledSmsEntry copyWith({
    int? id,
    Value<int?> contactId = const Value.absent(),
    String? phoneNumber,
    String? message,
    int? scheduledTime,
    int? isSent,
    Value<int?> bulkJobId = const Value.absent(),
  }) => ScheduledSmsEntry(
    id: id ?? this.id,
    contactId: contactId.present ? contactId.value : this.contactId,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    message: message ?? this.message,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    isSent: isSent ?? this.isSent,
    bulkJobId: bulkJobId.present ? bulkJobId.value : this.bulkJobId,
  );
  ScheduledSmsEntry copyWithCompanion(ScheduledSmsEntriesCompanion data) {
    return ScheduledSmsEntry(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
      message: data.message.present ? data.message.value : this.message,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      isSent: data.isSent.present ? data.isSent.value : this.isSent,
      bulkJobId: data.bulkJobId.present ? data.bulkJobId.value : this.bulkJobId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledSmsEntry(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('message: $message, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('isSent: $isSent, ')
          ..write('bulkJobId: $bulkJobId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    phoneNumber,
    message,
    scheduledTime,
    isSent,
    bulkJobId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledSmsEntry &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.phoneNumber == this.phoneNumber &&
          other.message == this.message &&
          other.scheduledTime == this.scheduledTime &&
          other.isSent == this.isSent &&
          other.bulkJobId == this.bulkJobId);
}

class ScheduledSmsEntriesCompanion extends UpdateCompanion<ScheduledSmsEntry> {
  final Value<int> id;
  final Value<int?> contactId;
  final Value<String> phoneNumber;
  final Value<String> message;
  final Value<int> scheduledTime;
  final Value<int> isSent;
  final Value<int?> bulkJobId;
  const ScheduledSmsEntriesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.message = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.isSent = const Value.absent(),
    this.bulkJobId = const Value.absent(),
  });
  ScheduledSmsEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    required String phoneNumber,
    required String message,
    required int scheduledTime,
    this.isSent = const Value.absent(),
    this.bulkJobId = const Value.absent(),
  }) : phoneNumber = Value(phoneNumber),
       message = Value(message),
       scheduledTime = Value(scheduledTime);
  static Insertable<ScheduledSmsEntry> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? phoneNumber,
    Expression<String>? message,
    Expression<int>? scheduledTime,
    Expression<int>? isSent,
    Expression<int>? bulkJobId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (message != null) 'message': message,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (isSent != null) 'is_sent': isSent,
      if (bulkJobId != null) 'bulk_job_id': bulkJobId,
    });
  }

  ScheduledSmsEntriesCompanion copyWith({
    Value<int>? id,
    Value<int?>? contactId,
    Value<String>? phoneNumber,
    Value<String>? message,
    Value<int>? scheduledTime,
    Value<int>? isSent,
    Value<int?>? bulkJobId,
  }) {
    return ScheduledSmsEntriesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isSent: isSent ?? this.isSent,
      bulkJobId: bulkJobId ?? this.bulkJobId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<int>(scheduledTime.value);
    }
    if (isSent.present) {
      map['is_sent'] = Variable<int>(isSent.value);
    }
    if (bulkJobId.present) {
      map['bulk_job_id'] = Variable<int>(bulkJobId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledSmsEntriesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('message: $message, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('isSent: $isSent, ')
          ..write('bulkJobId: $bulkJobId')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<int> dueDate = GeneratedColumn<int>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<int> isCompleted = GeneratedColumn<int>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<int> reminderTime = GeneratedColumn<int>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceTimelineIdMeta = const VerificationMeta(
    'sourceTimelineId',
  );
  @override
  late final GeneratedColumn<int> sourceTimelineId = GeneratedColumn<int>(
    'source_timeline_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    title,
    dueDate,
    isCompleted,
    reminderTime,
    note,
    createdAt,
    completedAt,
    sourceTimelineId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('source_timeline_id')) {
      context.handle(
        _sourceTimelineIdMeta,
        sourceTimelineId.isAcceptableOrUnknown(
          data['source_timeline_id']!,
          _sourceTimelineIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_date'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_completed'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      sourceTimelineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_timeline_id'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final int? contactId;
  final String title;
  final int dueDate;
  final int isCompleted;
  final int? reminderTime;
  final String? note;
  final int? createdAt;
  final int? completedAt;
  final int? sourceTimelineId;
  const Task({
    required this.id,
    this.contactId,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
    this.reminderTime,
    this.note,
    this.createdAt,
    this.completedAt,
    this.sourceTimelineId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    map['title'] = Variable<String>(title);
    map['due_date'] = Variable<int>(dueDate);
    map['is_completed'] = Variable<int>(isCompleted);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<int>(reminderTime);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || sourceTimelineId != null) {
      map['source_timeline_id'] = Variable<int>(sourceTimelineId);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      title: Value(title),
      dueDate: Value(dueDate),
      isCompleted: Value(isCompleted),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      sourceTimelineId: sourceTimelineId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTimelineId),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      title: serializer.fromJson<String>(json['title']),
      dueDate: serializer.fromJson<int>(json['dueDate']),
      isCompleted: serializer.fromJson<int>(json['isCompleted']),
      reminderTime: serializer.fromJson<int?>(json['reminderTime']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      sourceTimelineId: serializer.fromJson<int?>(json['sourceTimelineId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int?>(contactId),
      'title': serializer.toJson<String>(title),
      'dueDate': serializer.toJson<int>(dueDate),
      'isCompleted': serializer.toJson<int>(isCompleted),
      'reminderTime': serializer.toJson<int?>(reminderTime),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int?>(createdAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'sourceTimelineId': serializer.toJson<int?>(sourceTimelineId),
    };
  }

  Task copyWith({
    int? id,
    Value<int?> contactId = const Value.absent(),
    String? title,
    int? dueDate,
    int? isCompleted,
    Value<int?> reminderTime = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    Value<int?> sourceTimelineId = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    contactId: contactId.present ? contactId.value : this.contactId,
    title: title ?? this.title,
    dueDate: dueDate ?? this.dueDate,
    isCompleted: isCompleted ?? this.isCompleted,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    note: note.present ? note.value : this.note,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    sourceTimelineId: sourceTimelineId.present
        ? sourceTimelineId.value
        : this.sourceTimelineId,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      title: data.title.present ? data.title.value : this.title,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      sourceTimelineId: data.sourceTimelineId.present
          ? data.sourceTimelineId.value
          : this.sourceTimelineId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('title: $title, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('sourceTimelineId: $sourceTimelineId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contactId,
    title,
    dueDate,
    isCompleted,
    reminderTime,
    note,
    createdAt,
    completedAt,
    sourceTimelineId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.title == this.title &&
          other.dueDate == this.dueDate &&
          other.isCompleted == this.isCompleted &&
          other.reminderTime == this.reminderTime &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.sourceTimelineId == this.sourceTimelineId);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int?> contactId;
  final Value<String> title;
  final Value<int> dueDate;
  final Value<int> isCompleted;
  final Value<int?> reminderTime;
  final Value<String?> note;
  final Value<int?> createdAt;
  final Value<int?> completedAt;
  final Value<int?> sourceTimelineId;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.title = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sourceTimelineId = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    required String title,
    required int dueDate,
    this.isCompleted = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sourceTimelineId = const Value.absent(),
  }) : title = Value(title),
       dueDate = Value(dueDate);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? title,
    Expression<int>? dueDate,
    Expression<int>? isCompleted,
    Expression<int>? reminderTime,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? completedAt,
    Expression<int>? sourceTimelineId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (title != null) 'title': title,
      if (dueDate != null) 'due_date': dueDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (sourceTimelineId != null) 'source_timeline_id': sourceTimelineId,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<int?>? contactId,
    Value<String>? title,
    Value<int>? dueDate,
    Value<int>? isCompleted,
    Value<int?>? reminderTime,
    Value<String?>? note,
    Value<int?>? createdAt,
    Value<int?>? completedAt,
    Value<int?>? sourceTimelineId,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderTime: reminderTime ?? this.reminderTime,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      sourceTimelineId: sourceTimelineId ?? this.sourceTimelineId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<int>(dueDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<int>(isCompleted.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<int>(reminderTime.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (sourceTimelineId.present) {
      map['source_timeline_id'] = Variable<int>(sourceTimelineId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('title: $title, ')
          ..write('dueDate: $dueDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('sourceTimelineId: $sourceTimelineId')
          ..write(')'))
        .toString();
  }
}

class $ContactListsTable extends ContactLists
    with TableInfo<$ContactListsTable, ContactList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _cadenceDaysMeta = const VerificationMeta(
    'cadenceDays',
  );
  @override
  late final GeneratedColumn<int> cadenceDays = GeneratedColumn<int>(
    'cadence_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, cadenceDays, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cadence_days')) {
      context.handle(
        _cadenceDaysMeta,
        cadenceDays.isAcceptableOrUnknown(
          data['cadence_days']!,
          _cadenceDaysMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cadenceDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cadence_days'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $ContactListsTable createAlias(String alias) {
    return $ContactListsTable(attachedDatabase, alias);
  }
}

class ContactList extends DataClass implements Insertable<ContactList> {
  final int id;
  final String name;
  final int? cadenceDays;
  final int? createdAt;
  const ContactList({
    required this.id,
    required this.name,
    this.cadenceDays,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || cadenceDays != null) {
      map['cadence_days'] = Variable<int>(cadenceDays);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    return map;
  }

  ContactListsCompanion toCompanion(bool nullToAbsent) {
    return ContactListsCompanion(
      id: Value(id),
      name: Value(name),
      cadenceDays: cadenceDays == null && nullToAbsent
          ? const Value.absent()
          : Value(cadenceDays),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory ContactList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cadenceDays: serializer.fromJson<int?>(json['cadenceDays']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cadenceDays': serializer.toJson<int?>(cadenceDays),
      'createdAt': serializer.toJson<int?>(createdAt),
    };
  }

  ContactList copyWith({
    int? id,
    String? name,
    Value<int?> cadenceDays = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
  }) => ContactList(
    id: id ?? this.id,
    name: name ?? this.name,
    cadenceDays: cadenceDays.present ? cadenceDays.value : this.cadenceDays,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  ContactList copyWithCompanion(ContactListsCompanion data) {
    return ContactList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cadenceDays: data.cadenceDays.present
          ? data.cadenceDays.value
          : this.cadenceDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cadenceDays: $cadenceDays, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cadenceDays, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactList &&
          other.id == this.id &&
          other.name == this.name &&
          other.cadenceDays == this.cadenceDays &&
          other.createdAt == this.createdAt);
}

class ContactListsCompanion extends UpdateCompanion<ContactList> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> cadenceDays;
  final Value<int?> createdAt;
  const ContactListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cadenceDays = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ContactListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.cadenceDays = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ContactList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? cadenceDays,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cadenceDays != null) 'cadence_days': cadenceDays,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ContactListsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? cadenceDays,
    Value<int?>? createdAt,
  }) {
    return ContactListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cadenceDays: cadenceDays ?? this.cadenceDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cadenceDays.present) {
      map['cadence_days'] = Variable<int>(cadenceDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cadenceDays: $cadenceDays, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ContactListMembersTable extends ContactListMembers
    with TableInfo<$ContactListMembersTable, ContactListMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactListMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contact_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, listId, contactId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_list_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactListMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {listId, contactId},
  ];
  @override
  ContactListMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactListMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      ),
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
    );
  }

  @override
  $ContactListMembersTable createAlias(String alias) {
    return $ContactListMembersTable(attachedDatabase, alias);
  }
}

class ContactListMember extends DataClass
    implements Insertable<ContactListMember> {
  final int id;
  final int? listId;
  final int? contactId;
  const ContactListMember({required this.id, this.listId, this.contactId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || listId != null) {
      map['list_id'] = Variable<int>(listId);
    }
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    return map;
  }

  ContactListMembersCompanion toCompanion(bool nullToAbsent) {
    return ContactListMembersCompanion(
      id: Value(id),
      listId: listId == null && nullToAbsent
          ? const Value.absent()
          : Value(listId),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
    );
  }

  factory ContactListMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactListMember(
      id: serializer.fromJson<int>(json['id']),
      listId: serializer.fromJson<int?>(json['listId']),
      contactId: serializer.fromJson<int?>(json['contactId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listId': serializer.toJson<int?>(listId),
      'contactId': serializer.toJson<int?>(contactId),
    };
  }

  ContactListMember copyWith({
    int? id,
    Value<int?> listId = const Value.absent(),
    Value<int?> contactId = const Value.absent(),
  }) => ContactListMember(
    id: id ?? this.id,
    listId: listId.present ? listId.value : this.listId,
    contactId: contactId.present ? contactId.value : this.contactId,
  );
  ContactListMember copyWithCompanion(ContactListMembersCompanion data) {
    return ContactListMember(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactListMember(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('contactId: $contactId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listId, contactId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactListMember &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.contactId == this.contactId);
}

class ContactListMembersCompanion extends UpdateCompanion<ContactListMember> {
  final Value<int> id;
  final Value<int?> listId;
  final Value<int?> contactId;
  const ContactListMembersCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.contactId = const Value.absent(),
  });
  ContactListMembersCompanion.insert({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.contactId = const Value.absent(),
  });
  static Insertable<ContactListMember> custom({
    Expression<int>? id,
    Expression<int>? listId,
    Expression<int>? contactId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (contactId != null) 'contact_id': contactId,
    });
  }

  ContactListMembersCompanion copyWith({
    Value<int>? id,
    Value<int?>? listId,
    Value<int?>? contactId,
  }) {
    return ContactListMembersCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      contactId: contactId ?? this.contactId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactListMembersCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('contactId: $contactId')
          ..write(')'))
        .toString();
  }
}

class $BulkSmsJobsTable extends BulkSmsJobs
    with TableInfo<$BulkSmsJobsTable, BulkSmsJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BulkSmsJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _listNameMeta = const VerificationMeta(
    'listName',
  );
  @override
  late final GeneratedColumn<String> listName = GeneratedColumn<String>(
    'list_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<int> scheduledTime = GeneratedColumn<int>(
    'scheduled_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSentMeta = const VerificationMeta('isSent');
  @override
  late final GeneratedColumn<int> isSent = GeneratedColumn<int>(
    'is_sent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listName,
    message,
    scheduledTime,
    isSent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bulk_sms_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BulkSmsJob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('list_name')) {
      context.handle(
        _listNameMeta,
        listName.isAcceptableOrUnknown(data['list_name']!, _listNameMeta),
      );
    } else if (isInserting) {
      context.missing(_listNameMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('is_sent')) {
      context.handle(
        _isSentMeta,
        isSent.isAcceptableOrUnknown(data['is_sent']!, _isSentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BulkSmsJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BulkSmsJob(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      listName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_name'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_time'],
      )!,
      isSent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_sent'],
      )!,
    );
  }

  @override
  $BulkSmsJobsTable createAlias(String alias) {
    return $BulkSmsJobsTable(attachedDatabase, alias);
  }
}

class BulkSmsJob extends DataClass implements Insertable<BulkSmsJob> {
  final int id;
  final String listName;
  final String message;
  final int scheduledTime;
  final int isSent;
  const BulkSmsJob({
    required this.id,
    required this.listName,
    required this.message,
    required this.scheduledTime,
    required this.isSent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['list_name'] = Variable<String>(listName);
    map['message'] = Variable<String>(message);
    map['scheduled_time'] = Variable<int>(scheduledTime);
    map['is_sent'] = Variable<int>(isSent);
    return map;
  }

  BulkSmsJobsCompanion toCompanion(bool nullToAbsent) {
    return BulkSmsJobsCompanion(
      id: Value(id),
      listName: Value(listName),
      message: Value(message),
      scheduledTime: Value(scheduledTime),
      isSent: Value(isSent),
    );
  }

  factory BulkSmsJob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BulkSmsJob(
      id: serializer.fromJson<int>(json['id']),
      listName: serializer.fromJson<String>(json['listName']),
      message: serializer.fromJson<String>(json['message']),
      scheduledTime: serializer.fromJson<int>(json['scheduledTime']),
      isSent: serializer.fromJson<int>(json['isSent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'listName': serializer.toJson<String>(listName),
      'message': serializer.toJson<String>(message),
      'scheduledTime': serializer.toJson<int>(scheduledTime),
      'isSent': serializer.toJson<int>(isSent),
    };
  }

  BulkSmsJob copyWith({
    int? id,
    String? listName,
    String? message,
    int? scheduledTime,
    int? isSent,
  }) => BulkSmsJob(
    id: id ?? this.id,
    listName: listName ?? this.listName,
    message: message ?? this.message,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    isSent: isSent ?? this.isSent,
  );
  BulkSmsJob copyWithCompanion(BulkSmsJobsCompanion data) {
    return BulkSmsJob(
      id: data.id.present ? data.id.value : this.id,
      listName: data.listName.present ? data.listName.value : this.listName,
      message: data.message.present ? data.message.value : this.message,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      isSent: data.isSent.present ? data.isSent.value : this.isSent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BulkSmsJob(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('message: $message, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('isSent: $isSent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listName, message, scheduledTime, isSent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BulkSmsJob &&
          other.id == this.id &&
          other.listName == this.listName &&
          other.message == this.message &&
          other.scheduledTime == this.scheduledTime &&
          other.isSent == this.isSent);
}

class BulkSmsJobsCompanion extends UpdateCompanion<BulkSmsJob> {
  final Value<int> id;
  final Value<String> listName;
  final Value<String> message;
  final Value<int> scheduledTime;
  final Value<int> isSent;
  const BulkSmsJobsCompanion({
    this.id = const Value.absent(),
    this.listName = const Value.absent(),
    this.message = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.isSent = const Value.absent(),
  });
  BulkSmsJobsCompanion.insert({
    this.id = const Value.absent(),
    required String listName,
    required String message,
    required int scheduledTime,
    this.isSent = const Value.absent(),
  }) : listName = Value(listName),
       message = Value(message),
       scheduledTime = Value(scheduledTime);
  static Insertable<BulkSmsJob> custom({
    Expression<int>? id,
    Expression<String>? listName,
    Expression<String>? message,
    Expression<int>? scheduledTime,
    Expression<int>? isSent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listName != null) 'list_name': listName,
      if (message != null) 'message': message,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (isSent != null) 'is_sent': isSent,
    });
  }

  BulkSmsJobsCompanion copyWith({
    Value<int>? id,
    Value<String>? listName,
    Value<String>? message,
    Value<int>? scheduledTime,
    Value<int>? isSent,
  }) {
    return BulkSmsJobsCompanion(
      id: id ?? this.id,
      listName: listName ?? this.listName,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isSent: isSent ?? this.isSent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (listName.present) {
      map['list_name'] = Variable<String>(listName.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<int>(scheduledTime.value);
    }
    if (isSent.present) {
      map['is_sent'] = Variable<int>(isSent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BulkSmsJobsCompanion(')
          ..write('id: $id, ')
          ..write('listName: $listName, ')
          ..write('message: $message, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('isSent: $isSent')
          ..write(')'))
        .toString();
  }
}

class $ContactPhonesTable extends ContactPhones
    with TableInfo<$ContactPhonesTable, ContactPhone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactPhonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _e164Meta = const VerificationMeta('e164');
  @override
  late final GeneratedColumn<String> e164 = GeneratedColumn<String>(
    'e164',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _rawMeta = const VerificationMeta('raw');
  @override
  late final GeneratedColumn<String> raw = GeneratedColumn<String>(
    'raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<int> isPrimary = GeneratedColumn<int>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMobileMeta = const VerificationMeta(
    'isMobile',
  );
  @override
  late final GeneratedColumn<int> isMobile = GeneratedColumn<int>(
    'is_mobile',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contactId,
    e164,
    raw,
    label,
    isPrimary,
    isMobile,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_phones';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactPhone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contactIdMeta);
    }
    if (data.containsKey('e164')) {
      context.handle(
        _e164Meta,
        e164.isAcceptableOrUnknown(data['e164']!, _e164Meta),
      );
    }
    if (data.containsKey('raw')) {
      context.handle(
        _rawMeta,
        raw.isAcceptableOrUnknown(data['raw']!, _rawMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('is_mobile')) {
      context.handle(
        _isMobileMeta,
        isMobile.isAcceptableOrUnknown(data['is_mobile']!, _isMobileMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactPhone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactPhone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      )!,
      e164: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}e164'],
      ),
      raw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_primary'],
      )!,
      isMobile: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_mobile'],
      )!,
    );
  }

  @override
  $ContactPhonesTable createAlias(String alias) {
    return $ContactPhonesTable(attachedDatabase, alias);
  }
}

class ContactPhone extends DataClass implements Insertable<ContactPhone> {
  final int id;
  final int contactId;
  final String? e164;
  final String? raw;
  final String? label;
  final int isPrimary;
  final int isMobile;
  const ContactPhone({
    required this.id,
    required this.contactId,
    this.e164,
    this.raw,
    this.label,
    required this.isPrimary,
    required this.isMobile,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['contact_id'] = Variable<int>(contactId);
    if (!nullToAbsent || e164 != null) {
      map['e164'] = Variable<String>(e164);
    }
    if (!nullToAbsent || raw != null) {
      map['raw'] = Variable<String>(raw);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['is_primary'] = Variable<int>(isPrimary);
    map['is_mobile'] = Variable<int>(isMobile);
    return map;
  }

  ContactPhonesCompanion toCompanion(bool nullToAbsent) {
    return ContactPhonesCompanion(
      id: Value(id),
      contactId: Value(contactId),
      e164: e164 == null && nullToAbsent ? const Value.absent() : Value(e164),
      raw: raw == null && nullToAbsent ? const Value.absent() : Value(raw),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      isPrimary: Value(isPrimary),
      isMobile: Value(isMobile),
    );
  }

  factory ContactPhone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactPhone(
      id: serializer.fromJson<int>(json['id']),
      contactId: serializer.fromJson<int>(json['contactId']),
      e164: serializer.fromJson<String?>(json['e164']),
      raw: serializer.fromJson<String?>(json['raw']),
      label: serializer.fromJson<String?>(json['label']),
      isPrimary: serializer.fromJson<int>(json['isPrimary']),
      isMobile: serializer.fromJson<int>(json['isMobile']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contactId': serializer.toJson<int>(contactId),
      'e164': serializer.toJson<String?>(e164),
      'raw': serializer.toJson<String?>(raw),
      'label': serializer.toJson<String?>(label),
      'isPrimary': serializer.toJson<int>(isPrimary),
      'isMobile': serializer.toJson<int>(isMobile),
    };
  }

  ContactPhone copyWith({
    int? id,
    int? contactId,
    Value<String?> e164 = const Value.absent(),
    Value<String?> raw = const Value.absent(),
    Value<String?> label = const Value.absent(),
    int? isPrimary,
    int? isMobile,
  }) => ContactPhone(
    id: id ?? this.id,
    contactId: contactId ?? this.contactId,
    e164: e164.present ? e164.value : this.e164,
    raw: raw.present ? raw.value : this.raw,
    label: label.present ? label.value : this.label,
    isPrimary: isPrimary ?? this.isPrimary,
    isMobile: isMobile ?? this.isMobile,
  );
  ContactPhone copyWithCompanion(ContactPhonesCompanion data) {
    return ContactPhone(
      id: data.id.present ? data.id.value : this.id,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      e164: data.e164.present ? data.e164.value : this.e164,
      raw: data.raw.present ? data.raw.value : this.raw,
      label: data.label.present ? data.label.value : this.label,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isMobile: data.isMobile.present ? data.isMobile.value : this.isMobile,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactPhone(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('e164: $e164, ')
          ..write('raw: $raw, ')
          ..write('label: $label, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isMobile: $isMobile')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, contactId, e164, raw, label, isPrimary, isMobile);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactPhone &&
          other.id == this.id &&
          other.contactId == this.contactId &&
          other.e164 == this.e164 &&
          other.raw == this.raw &&
          other.label == this.label &&
          other.isPrimary == this.isPrimary &&
          other.isMobile == this.isMobile);
}

class ContactPhonesCompanion extends UpdateCompanion<ContactPhone> {
  final Value<int> id;
  final Value<int> contactId;
  final Value<String?> e164;
  final Value<String?> raw;
  final Value<String?> label;
  final Value<int> isPrimary;
  final Value<int> isMobile;
  const ContactPhonesCompanion({
    this.id = const Value.absent(),
    this.contactId = const Value.absent(),
    this.e164 = const Value.absent(),
    this.raw = const Value.absent(),
    this.label = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isMobile = const Value.absent(),
  });
  ContactPhonesCompanion.insert({
    this.id = const Value.absent(),
    required int contactId,
    this.e164 = const Value.absent(),
    this.raw = const Value.absent(),
    this.label = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isMobile = const Value.absent(),
  }) : contactId = Value(contactId);
  static Insertable<ContactPhone> custom({
    Expression<int>? id,
    Expression<int>? contactId,
    Expression<String>? e164,
    Expression<String>? raw,
    Expression<String>? label,
    Expression<int>? isPrimary,
    Expression<int>? isMobile,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contactId != null) 'contact_id': contactId,
      if (e164 != null) 'e164': e164,
      if (raw != null) 'raw': raw,
      if (label != null) 'label': label,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isMobile != null) 'is_mobile': isMobile,
    });
  }

  ContactPhonesCompanion copyWith({
    Value<int>? id,
    Value<int>? contactId,
    Value<String?>? e164,
    Value<String?>? raw,
    Value<String?>? label,
    Value<int>? isPrimary,
    Value<int>? isMobile,
  }) {
    return ContactPhonesCompanion(
      id: id ?? this.id,
      contactId: contactId ?? this.contactId,
      e164: e164 ?? this.e164,
      raw: raw ?? this.raw,
      label: label ?? this.label,
      isPrimary: isPrimary ?? this.isPrimary,
      isMobile: isMobile ?? this.isMobile,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (e164.present) {
      map['e164'] = Variable<String>(e164.value);
    }
    if (raw.present) {
      map['raw'] = Variable<String>(raw.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<int>(isPrimary.value);
    }
    if (isMobile.present) {
      map['is_mobile'] = Variable<int>(isMobile.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactPhonesCompanion(')
          ..write('id: $id, ')
          ..write('contactId: $contactId, ')
          ..write('e164: $e164, ')
          ..write('raw: $raw, ')
          ..write('label: $label, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isMobile: $isMobile')
          ..write(')'))
        .toString();
  }
}

class $TimelineAttachmentsTable extends TimelineAttachments
    with TableInfo<$TimelineAttachmentsTable, TimelineAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timelineIdMeta = const VerificationMeta(
    'timelineId',
  );
  @override
  late final GeneratedColumn<int> timelineId = GeneratedColumn<int>(
    'timeline_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES timeline (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, timelineId, path, mime, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timeline_id')) {
      context.handle(
        _timelineIdMeta,
        timelineId.isAcceptableOrUnknown(data['timeline_id']!, _timelineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_timelineIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineAttachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timelineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeline_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $TimelineAttachmentsTable createAlias(String alias) {
    return $TimelineAttachmentsTable(attachedDatabase, alias);
  }
}

class TimelineAttachment extends DataClass
    implements Insertable<TimelineAttachment> {
  final int id;
  final int timelineId;
  final String path;
  final String? mime;
  final int? createdAt;
  const TimelineAttachment({
    required this.id,
    required this.timelineId,
    required this.path,
    this.mime,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timeline_id'] = Variable<int>(timelineId);
    map['path'] = Variable<String>(path);
    if (!nullToAbsent || mime != null) {
      map['mime'] = Variable<String>(mime);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    return map;
  }

  TimelineAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return TimelineAttachmentsCompanion(
      id: Value(id),
      timelineId: Value(timelineId),
      path: Value(path),
      mime: mime == null && nullToAbsent ? const Value.absent() : Value(mime),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory TimelineAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineAttachment(
      id: serializer.fromJson<int>(json['id']),
      timelineId: serializer.fromJson<int>(json['timelineId']),
      path: serializer.fromJson<String>(json['path']),
      mime: serializer.fromJson<String?>(json['mime']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timelineId': serializer.toJson<int>(timelineId),
      'path': serializer.toJson<String>(path),
      'mime': serializer.toJson<String?>(mime),
      'createdAt': serializer.toJson<int?>(createdAt),
    };
  }

  TimelineAttachment copyWith({
    int? id,
    int? timelineId,
    String? path,
    Value<String?> mime = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
  }) => TimelineAttachment(
    id: id ?? this.id,
    timelineId: timelineId ?? this.timelineId,
    path: path ?? this.path,
    mime: mime.present ? mime.value : this.mime,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  TimelineAttachment copyWithCompanion(TimelineAttachmentsCompanion data) {
    return TimelineAttachment(
      id: data.id.present ? data.id.value : this.id,
      timelineId: data.timelineId.present
          ? data.timelineId.value
          : this.timelineId,
      path: data.path.present ? data.path.value : this.path,
      mime: data.mime.present ? data.mime.value : this.mime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineAttachment(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('path: $path, ')
          ..write('mime: $mime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timelineId, path, mime, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineAttachment &&
          other.id == this.id &&
          other.timelineId == this.timelineId &&
          other.path == this.path &&
          other.mime == this.mime &&
          other.createdAt == this.createdAt);
}

class TimelineAttachmentsCompanion extends UpdateCompanion<TimelineAttachment> {
  final Value<int> id;
  final Value<int> timelineId;
  final Value<String> path;
  final Value<String?> mime;
  final Value<int?> createdAt;
  const TimelineAttachmentsCompanion({
    this.id = const Value.absent(),
    this.timelineId = const Value.absent(),
    this.path = const Value.absent(),
    this.mime = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TimelineAttachmentsCompanion.insert({
    this.id = const Value.absent(),
    required int timelineId,
    required String path,
    this.mime = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : timelineId = Value(timelineId),
       path = Value(path);
  static Insertable<TimelineAttachment> custom({
    Expression<int>? id,
    Expression<int>? timelineId,
    Expression<String>? path,
    Expression<String>? mime,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timelineId != null) 'timeline_id': timelineId,
      if (path != null) 'path': path,
      if (mime != null) 'mime': mime,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TimelineAttachmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? timelineId,
    Value<String>? path,
    Value<String?>? mime,
    Value<int?>? createdAt,
  }) {
    return TimelineAttachmentsCompanion(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      path: path ?? this.path,
      mime: mime ?? this.mime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timelineId.present) {
      map['timeline_id'] = Variable<int>(timelineId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineAttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('path: $path, ')
          ..write('mime: $mime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, Template> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, body, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Template> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Template map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Template(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class Template extends DataClass implements Insertable<Template> {
  final int id;
  final String name;
  final String body;
  final int? createdAt;
  final int? updatedAt;
  const Template({
    required this.id,
    required this.name,
    required this.body,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      id: Value(id),
      name: Value(name),
      body: Value(body),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Template.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Template(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<int?>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  Template copyWith({
    int? id,
    String? name,
    String? body,
    Value<int?> createdAt = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => Template(
    id: id ?? this.id,
    name: name ?? this.name,
    body: body ?? this.body,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Template copyWithCompanion(TemplatesCompanion data) {
    return Template(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Template(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, body, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Template &&
          other.id == this.id &&
          other.name == this.name &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TemplatesCompanion extends UpdateCompanion<Template> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> body;
  final Value<int?> createdAt;
  final Value<int?> updatedAt;
  const TemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String body,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       body = Value(body);
  static Insertable<Template> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? body,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? body,
    Value<int?>? createdAt,
    Value<int?>? updatedAt,
  }) {
    return TemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CampaignsTable extends Campaigns
    with TableInfo<$CampaignsTable, Campaign> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyTemplateMeta = const VerificationMeta(
    'bodyTemplate',
  );
  @override
  late final GeneratedColumn<String> bodyTemplate = GeneratedColumn<String>(
    'body_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subIdMeta = const VerificationMeta('subId');
  @override
  late final GeneratedColumn<int> subId = GeneratedColumn<int>(
    'sub_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paceSecondsMeta = const VerificationMeta(
    'paceSeconds',
  );
  @override
  late final GeneratedColumn<int> paceSeconds = GeneratedColumn<int>(
    'pace_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windowStartMinMeta = const VerificationMeta(
    'windowStartMin',
  );
  @override
  late final GeneratedColumn<int> windowStartMin = GeneratedColumn<int>(
    'window_start_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windowEndMinMeta = const VerificationMeta(
    'windowEndMin',
  );
  @override
  late final GeneratedColumn<int> windowEndMin = GeneratedColumn<int>(
    'window_end_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    bodyTemplate,
    scheduledAt,
    status,
    subId,
    paceSeconds,
    windowStartMin,
    windowEndMin,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Campaign> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('body_template')) {
      context.handle(
        _bodyTemplateMeta,
        bodyTemplate.isAcceptableOrUnknown(
          data['body_template']!,
          _bodyTemplateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bodyTemplateMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('sub_id')) {
      context.handle(
        _subIdMeta,
        subId.isAcceptableOrUnknown(data['sub_id']!, _subIdMeta),
      );
    }
    if (data.containsKey('pace_seconds')) {
      context.handle(
        _paceSecondsMeta,
        paceSeconds.isAcceptableOrUnknown(
          data['pace_seconds']!,
          _paceSecondsMeta,
        ),
      );
    }
    if (data.containsKey('window_start_min')) {
      context.handle(
        _windowStartMinMeta,
        windowStartMin.isAcceptableOrUnknown(
          data['window_start_min']!,
          _windowStartMinMeta,
        ),
      );
    }
    if (data.containsKey('window_end_min')) {
      context.handle(
        _windowEndMinMeta,
        windowEndMin.isAcceptableOrUnknown(
          data['window_end_min']!,
          _windowEndMinMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Campaign map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Campaign(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bodyTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_template'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      subId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sub_id'],
      ),
      paceSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pace_seconds'],
      ),
      windowStartMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}window_start_min'],
      ),
      windowEndMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}window_end_min'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
    );
  }

  @override
  $CampaignsTable createAlias(String alias) {
    return $CampaignsTable(attachedDatabase, alias);
  }
}

class Campaign extends DataClass implements Insertable<Campaign> {
  final String id;
  final String name;
  final String bodyTemplate;
  final int? scheduledAt;
  final String status;
  final int? subId;
  final int? paceSeconds;
  final int? windowStartMin;
  final int? windowEndMin;
  final int? createdAt;
  const Campaign({
    required this.id,
    required this.name,
    required this.bodyTemplate,
    this.scheduledAt,
    required this.status,
    this.subId,
    this.paceSeconds,
    this.windowStartMin,
    this.windowEndMin,
    this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['body_template'] = Variable<String>(bodyTemplate);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<int>(scheduledAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || subId != null) {
      map['sub_id'] = Variable<int>(subId);
    }
    if (!nullToAbsent || paceSeconds != null) {
      map['pace_seconds'] = Variable<int>(paceSeconds);
    }
    if (!nullToAbsent || windowStartMin != null) {
      map['window_start_min'] = Variable<int>(windowStartMin);
    }
    if (!nullToAbsent || windowEndMin != null) {
      map['window_end_min'] = Variable<int>(windowEndMin);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    return map;
  }

  CampaignsCompanion toCompanion(bool nullToAbsent) {
    return CampaignsCompanion(
      id: Value(id),
      name: Value(name),
      bodyTemplate: Value(bodyTemplate),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      status: Value(status),
      subId: subId == null && nullToAbsent
          ? const Value.absent()
          : Value(subId),
      paceSeconds: paceSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(paceSeconds),
      windowStartMin: windowStartMin == null && nullToAbsent
          ? const Value.absent()
          : Value(windowStartMin),
      windowEndMin: windowEndMin == null && nullToAbsent
          ? const Value.absent()
          : Value(windowEndMin),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory Campaign.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Campaign(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bodyTemplate: serializer.fromJson<String>(json['bodyTemplate']),
      scheduledAt: serializer.fromJson<int?>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      subId: serializer.fromJson<int?>(json['subId']),
      paceSeconds: serializer.fromJson<int?>(json['paceSeconds']),
      windowStartMin: serializer.fromJson<int?>(json['windowStartMin']),
      windowEndMin: serializer.fromJson<int?>(json['windowEndMin']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bodyTemplate': serializer.toJson<String>(bodyTemplate),
      'scheduledAt': serializer.toJson<int?>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'subId': serializer.toJson<int?>(subId),
      'paceSeconds': serializer.toJson<int?>(paceSeconds),
      'windowStartMin': serializer.toJson<int?>(windowStartMin),
      'windowEndMin': serializer.toJson<int?>(windowEndMin),
      'createdAt': serializer.toJson<int?>(createdAt),
    };
  }

  Campaign copyWith({
    String? id,
    String? name,
    String? bodyTemplate,
    Value<int?> scheduledAt = const Value.absent(),
    String? status,
    Value<int?> subId = const Value.absent(),
    Value<int?> paceSeconds = const Value.absent(),
    Value<int?> windowStartMin = const Value.absent(),
    Value<int?> windowEndMin = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
  }) => Campaign(
    id: id ?? this.id,
    name: name ?? this.name,
    bodyTemplate: bodyTemplate ?? this.bodyTemplate,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    status: status ?? this.status,
    subId: subId.present ? subId.value : this.subId,
    paceSeconds: paceSeconds.present ? paceSeconds.value : this.paceSeconds,
    windowStartMin: windowStartMin.present
        ? windowStartMin.value
        : this.windowStartMin,
    windowEndMin: windowEndMin.present ? windowEndMin.value : this.windowEndMin,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
  );
  Campaign copyWithCompanion(CampaignsCompanion data) {
    return Campaign(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bodyTemplate: data.bodyTemplate.present
          ? data.bodyTemplate.value
          : this.bodyTemplate,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      subId: data.subId.present ? data.subId.value : this.subId,
      paceSeconds: data.paceSeconds.present
          ? data.paceSeconds.value
          : this.paceSeconds,
      windowStartMin: data.windowStartMin.present
          ? data.windowStartMin.value
          : this.windowStartMin,
      windowEndMin: data.windowEndMin.present
          ? data.windowEndMin.value
          : this.windowEndMin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Campaign(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bodyTemplate: $bodyTemplate, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('subId: $subId, ')
          ..write('paceSeconds: $paceSeconds, ')
          ..write('windowStartMin: $windowStartMin, ')
          ..write('windowEndMin: $windowEndMin, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    bodyTemplate,
    scheduledAt,
    status,
    subId,
    paceSeconds,
    windowStartMin,
    windowEndMin,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Campaign &&
          other.id == this.id &&
          other.name == this.name &&
          other.bodyTemplate == this.bodyTemplate &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.subId == this.subId &&
          other.paceSeconds == this.paceSeconds &&
          other.windowStartMin == this.windowStartMin &&
          other.windowEndMin == this.windowEndMin &&
          other.createdAt == this.createdAt);
}

class CampaignsCompanion extends UpdateCompanion<Campaign> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bodyTemplate;
  final Value<int?> scheduledAt;
  final Value<String> status;
  final Value<int?> subId;
  final Value<int?> paceSeconds;
  final Value<int?> windowStartMin;
  final Value<int?> windowEndMin;
  final Value<int?> createdAt;
  final Value<int> rowid;
  const CampaignsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bodyTemplate = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.subId = const Value.absent(),
    this.paceSeconds = const Value.absent(),
    this.windowStartMin = const Value.absent(),
    this.windowEndMin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsCompanion.insert({
    required String id,
    required String name,
    required String bodyTemplate,
    this.scheduledAt = const Value.absent(),
    required String status,
    this.subId = const Value.absent(),
    this.paceSeconds = const Value.absent(),
    this.windowStartMin = const Value.absent(),
    this.windowEndMin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       bodyTemplate = Value(bodyTemplate),
       status = Value(status);
  static Insertable<Campaign> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bodyTemplate,
    Expression<int>? scheduledAt,
    Expression<String>? status,
    Expression<int>? subId,
    Expression<int>? paceSeconds,
    Expression<int>? windowStartMin,
    Expression<int>? windowEndMin,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bodyTemplate != null) 'body_template': bodyTemplate,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (subId != null) 'sub_id': subId,
      if (paceSeconds != null) 'pace_seconds': paceSeconds,
      if (windowStartMin != null) 'window_start_min': windowStartMin,
      if (windowEndMin != null) 'window_end_min': windowEndMin,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? bodyTemplate,
    Value<int?>? scheduledAt,
    Value<String>? status,
    Value<int?>? subId,
    Value<int?>? paceSeconds,
    Value<int?>? windowStartMin,
    Value<int?>? windowEndMin,
    Value<int?>? createdAt,
    Value<int>? rowid,
  }) {
    return CampaignsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bodyTemplate: bodyTemplate ?? this.bodyTemplate,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      subId: subId ?? this.subId,
      paceSeconds: paceSeconds ?? this.paceSeconds,
      windowStartMin: windowStartMin ?? this.windowStartMin,
      windowEndMin: windowEndMin ?? this.windowEndMin,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bodyTemplate.present) {
      map['body_template'] = Variable<String>(bodyTemplate.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (subId.present) {
      map['sub_id'] = Variable<int>(subId.value);
    }
    if (paceSeconds.present) {
      map['pace_seconds'] = Variable<int>(paceSeconds.value);
    }
    if (windowStartMin.present) {
      map['window_start_min'] = Variable<int>(windowStartMin.value);
    }
    if (windowEndMin.present) {
      map['window_end_min'] = Variable<int>(windowEndMin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bodyTemplate: $bodyTemplate, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('subId: $subId, ')
          ..write('paceSeconds: $paceSeconds, ')
          ..write('windowStartMin: $windowStartMin, ')
          ..write('windowEndMin: $windowEndMin, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxMessagesTable extends OutboxMessages
    with TableInfo<$OutboxMessagesTable, OutboxMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactIdMeta = const VerificationMeta(
    'contactId',
  );
  @override
  late final GeneratedColumn<int> contactId = GeneratedColumn<int>(
    'contact_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contacts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subIdMeta = const VerificationMeta('subId');
  @override
  late final GeneratedColumn<int> subId = GeneratedColumn<int>(
    'sub_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<int> errorCode = GeneratedColumn<int>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorLabelMeta = const VerificationMeta(
    'errorLabel',
  );
  @override
  late final GeneratedColumn<String> errorLabel = GeneratedColumn<String>(
    'error_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partsMeta = const VerificationMeta('parts');
  @override
  late final GeneratedColumn<int> parts = GeneratedColumn<int>(
    'parts',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<int> sentAt = GeneratedColumn<int>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta(
    'deliveredAt',
  );
  @override
  late final GeneratedColumn<int> deliveredAt = GeneratedColumn<int>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerSmsIdMeta = const VerificationMeta(
    'providerSmsId',
  );
  @override
  late final GeneratedColumn<String> providerSmsId = GeneratedColumn<String>(
    'provider_sms_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mergeSummaryMeta = const VerificationMeta(
    'mergeSummary',
  );
  @override
  late final GeneratedColumn<String> mergeSummary = GeneratedColumn<String>(
    'merge_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    contactId,
    campaignId,
    address,
    body,
    dueAt,
    subId,
    status,
    errorCode,
    errorLabel,
    parts,
    attempt,
    sentAt,
    deliveredAt,
    providerSmsId,
    mergeSummary,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('contact_id')) {
      context.handle(
        _contactIdMeta,
        contactId.isAcceptableOrUnknown(data['contact_id']!, _contactIdMeta),
      );
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    } else if (isInserting) {
      context.missing(_dueAtMeta);
    }
    if (data.containsKey('sub_id')) {
      context.handle(
        _subIdMeta,
        subId.isAcceptableOrUnknown(data['sub_id']!, _subIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    if (data.containsKey('error_label')) {
      context.handle(
        _errorLabelMeta,
        errorLabel.isAcceptableOrUnknown(data['error_label']!, _errorLabelMeta),
      );
    }
    if (data.containsKey('parts')) {
      context.handle(
        _partsMeta,
        parts.isAcceptableOrUnknown(data['parts']!, _partsMeta),
      );
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(
          data['delivered_at']!,
          _deliveredAtMeta,
        ),
      );
    }
    if (data.containsKey('provider_sms_id')) {
      context.handle(
        _providerSmsIdMeta,
        providerSmsId.isAcceptableOrUnknown(
          data['provider_sms_id']!,
          _providerSmsIdMeta,
        ),
      );
    }
    if (data.containsKey('merge_summary')) {
      context.handle(
        _mergeSummaryMeta,
        mergeSummary.isAcceptableOrUnknown(
          data['merge_summary']!,
          _mergeSummaryMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clientId};
  @override
  OutboxMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxMessage(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      contactId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}contact_id'],
      ),
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      )!,
      subId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sub_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_code'],
      ),
      errorLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_label'],
      ),
      parts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parts'],
      ),
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sent_at'],
      ),
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivered_at'],
      ),
      providerSmsId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_sms_id'],
      ),
      mergeSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merge_summary'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $OutboxMessagesTable createAlias(String alias) {
    return $OutboxMessagesTable(attachedDatabase, alias);
  }
}

class OutboxMessage extends DataClass implements Insertable<OutboxMessage> {
  final String clientId;
  final int? contactId;
  final String? campaignId;
  final String address;
  final String body;
  final int dueAt;
  final int? subId;
  final String status;
  final int? errorCode;
  final String? errorLabel;
  final int? parts;
  final int attempt;
  final int? sentAt;
  final int? deliveredAt;
  final String? providerSmsId;
  final String? mergeSummary;
  final int? createdAt;
  final int? updatedAt;
  const OutboxMessage({
    required this.clientId,
    this.contactId,
    this.campaignId,
    required this.address,
    required this.body,
    required this.dueAt,
    this.subId,
    required this.status,
    this.errorCode,
    this.errorLabel,
    this.parts,
    required this.attempt,
    this.sentAt,
    this.deliveredAt,
    this.providerSmsId,
    this.mergeSummary,
    this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || contactId != null) {
      map['contact_id'] = Variable<int>(contactId);
    }
    if (!nullToAbsent || campaignId != null) {
      map['campaign_id'] = Variable<String>(campaignId);
    }
    map['address'] = Variable<String>(address);
    map['body'] = Variable<String>(body);
    map['due_at'] = Variable<int>(dueAt);
    if (!nullToAbsent || subId != null) {
      map['sub_id'] = Variable<int>(subId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<int>(errorCode);
    }
    if (!nullToAbsent || errorLabel != null) {
      map['error_label'] = Variable<String>(errorLabel);
    }
    if (!nullToAbsent || parts != null) {
      map['parts'] = Variable<int>(parts);
    }
    map['attempt'] = Variable<int>(attempt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<int>(sentAt);
    }
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<int>(deliveredAt);
    }
    if (!nullToAbsent || providerSmsId != null) {
      map['provider_sms_id'] = Variable<String>(providerSmsId);
    }
    if (!nullToAbsent || mergeSummary != null) {
      map['merge_summary'] = Variable<String>(mergeSummary);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  OutboxMessagesCompanion toCompanion(bool nullToAbsent) {
    return OutboxMessagesCompanion(
      clientId: Value(clientId),
      contactId: contactId == null && nullToAbsent
          ? const Value.absent()
          : Value(contactId),
      campaignId: campaignId == null && nullToAbsent
          ? const Value.absent()
          : Value(campaignId),
      address: Value(address),
      body: Value(body),
      dueAt: Value(dueAt),
      subId: subId == null && nullToAbsent
          ? const Value.absent()
          : Value(subId),
      status: Value(status),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      errorLabel: errorLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(errorLabel),
      parts: parts == null && nullToAbsent
          ? const Value.absent()
          : Value(parts),
      attempt: Value(attempt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      deliveredAt: deliveredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveredAt),
      providerSmsId: providerSmsId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerSmsId),
      mergeSummary: mergeSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(mergeSummary),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory OutboxMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxMessage(
      clientId: serializer.fromJson<String>(json['clientId']),
      contactId: serializer.fromJson<int?>(json['contactId']),
      campaignId: serializer.fromJson<String?>(json['campaignId']),
      address: serializer.fromJson<String>(json['address']),
      body: serializer.fromJson<String>(json['body']),
      dueAt: serializer.fromJson<int>(json['dueAt']),
      subId: serializer.fromJson<int?>(json['subId']),
      status: serializer.fromJson<String>(json['status']),
      errorCode: serializer.fromJson<int?>(json['errorCode']),
      errorLabel: serializer.fromJson<String?>(json['errorLabel']),
      parts: serializer.fromJson<int?>(json['parts']),
      attempt: serializer.fromJson<int>(json['attempt']),
      sentAt: serializer.fromJson<int?>(json['sentAt']),
      deliveredAt: serializer.fromJson<int?>(json['deliveredAt']),
      providerSmsId: serializer.fromJson<String?>(json['providerSmsId']),
      mergeSummary: serializer.fromJson<String?>(json['mergeSummary']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'contactId': serializer.toJson<int?>(contactId),
      'campaignId': serializer.toJson<String?>(campaignId),
      'address': serializer.toJson<String>(address),
      'body': serializer.toJson<String>(body),
      'dueAt': serializer.toJson<int>(dueAt),
      'subId': serializer.toJson<int?>(subId),
      'status': serializer.toJson<String>(status),
      'errorCode': serializer.toJson<int?>(errorCode),
      'errorLabel': serializer.toJson<String?>(errorLabel),
      'parts': serializer.toJson<int?>(parts),
      'attempt': serializer.toJson<int>(attempt),
      'sentAt': serializer.toJson<int?>(sentAt),
      'deliveredAt': serializer.toJson<int?>(deliveredAt),
      'providerSmsId': serializer.toJson<String?>(providerSmsId),
      'mergeSummary': serializer.toJson<String?>(mergeSummary),
      'createdAt': serializer.toJson<int?>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  OutboxMessage copyWith({
    String? clientId,
    Value<int?> contactId = const Value.absent(),
    Value<String?> campaignId = const Value.absent(),
    String? address,
    String? body,
    int? dueAt,
    Value<int?> subId = const Value.absent(),
    String? status,
    Value<int?> errorCode = const Value.absent(),
    Value<String?> errorLabel = const Value.absent(),
    Value<int?> parts = const Value.absent(),
    int? attempt,
    Value<int?> sentAt = const Value.absent(),
    Value<int?> deliveredAt = const Value.absent(),
    Value<String?> providerSmsId = const Value.absent(),
    Value<String?> mergeSummary = const Value.absent(),
    Value<int?> createdAt = const Value.absent(),
    Value<int?> updatedAt = const Value.absent(),
  }) => OutboxMessage(
    clientId: clientId ?? this.clientId,
    contactId: contactId.present ? contactId.value : this.contactId,
    campaignId: campaignId.present ? campaignId.value : this.campaignId,
    address: address ?? this.address,
    body: body ?? this.body,
    dueAt: dueAt ?? this.dueAt,
    subId: subId.present ? subId.value : this.subId,
    status: status ?? this.status,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    errorLabel: errorLabel.present ? errorLabel.value : this.errorLabel,
    parts: parts.present ? parts.value : this.parts,
    attempt: attempt ?? this.attempt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
    providerSmsId: providerSmsId.present
        ? providerSmsId.value
        : this.providerSmsId,
    mergeSummary: mergeSummary.present ? mergeSummary.value : this.mergeSummary,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  OutboxMessage copyWithCompanion(OutboxMessagesCompanion data) {
    return OutboxMessage(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      contactId: data.contactId.present ? data.contactId.value : this.contactId,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      address: data.address.present ? data.address.value : this.address,
      body: data.body.present ? data.body.value : this.body,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      subId: data.subId.present ? data.subId.value : this.subId,
      status: data.status.present ? data.status.value : this.status,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      errorLabel: data.errorLabel.present
          ? data.errorLabel.value
          : this.errorLabel,
      parts: data.parts.present ? data.parts.value : this.parts,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      deliveredAt: data.deliveredAt.present
          ? data.deliveredAt.value
          : this.deliveredAt,
      providerSmsId: data.providerSmsId.present
          ? data.providerSmsId.value
          : this.providerSmsId,
      mergeSummary: data.mergeSummary.present
          ? data.mergeSummary.value
          : this.mergeSummary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxMessage(')
          ..write('clientId: $clientId, ')
          ..write('contactId: $contactId, ')
          ..write('campaignId: $campaignId, ')
          ..write('address: $address, ')
          ..write('body: $body, ')
          ..write('dueAt: $dueAt, ')
          ..write('subId: $subId, ')
          ..write('status: $status, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorLabel: $errorLabel, ')
          ..write('parts: $parts, ')
          ..write('attempt: $attempt, ')
          ..write('sentAt: $sentAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('providerSmsId: $providerSmsId, ')
          ..write('mergeSummary: $mergeSummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    contactId,
    campaignId,
    address,
    body,
    dueAt,
    subId,
    status,
    errorCode,
    errorLabel,
    parts,
    attempt,
    sentAt,
    deliveredAt,
    providerSmsId,
    mergeSummary,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxMessage &&
          other.clientId == this.clientId &&
          other.contactId == this.contactId &&
          other.campaignId == this.campaignId &&
          other.address == this.address &&
          other.body == this.body &&
          other.dueAt == this.dueAt &&
          other.subId == this.subId &&
          other.status == this.status &&
          other.errorCode == this.errorCode &&
          other.errorLabel == this.errorLabel &&
          other.parts == this.parts &&
          other.attempt == this.attempt &&
          other.sentAt == this.sentAt &&
          other.deliveredAt == this.deliveredAt &&
          other.providerSmsId == this.providerSmsId &&
          other.mergeSummary == this.mergeSummary &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OutboxMessagesCompanion extends UpdateCompanion<OutboxMessage> {
  final Value<String> clientId;
  final Value<int?> contactId;
  final Value<String?> campaignId;
  final Value<String> address;
  final Value<String> body;
  final Value<int> dueAt;
  final Value<int?> subId;
  final Value<String> status;
  final Value<int?> errorCode;
  final Value<String?> errorLabel;
  final Value<int?> parts;
  final Value<int> attempt;
  final Value<int?> sentAt;
  final Value<int?> deliveredAt;
  final Value<String?> providerSmsId;
  final Value<String?> mergeSummary;
  final Value<int?> createdAt;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const OutboxMessagesCompanion({
    this.clientId = const Value.absent(),
    this.contactId = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.address = const Value.absent(),
    this.body = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.subId = const Value.absent(),
    this.status = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.errorLabel = const Value.absent(),
    this.parts = const Value.absent(),
    this.attempt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.providerSmsId = const Value.absent(),
    this.mergeSummary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxMessagesCompanion.insert({
    required String clientId,
    this.contactId = const Value.absent(),
    this.campaignId = const Value.absent(),
    required String address,
    required String body,
    required int dueAt,
    this.subId = const Value.absent(),
    required String status,
    this.errorCode = const Value.absent(),
    this.errorLabel = const Value.absent(),
    this.parts = const Value.absent(),
    this.attempt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.providerSmsId = const Value.absent(),
    this.mergeSummary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       address = Value(address),
       body = Value(body),
       dueAt = Value(dueAt),
       status = Value(status);
  static Insertable<OutboxMessage> custom({
    Expression<String>? clientId,
    Expression<int>? contactId,
    Expression<String>? campaignId,
    Expression<String>? address,
    Expression<String>? body,
    Expression<int>? dueAt,
    Expression<int>? subId,
    Expression<String>? status,
    Expression<int>? errorCode,
    Expression<String>? errorLabel,
    Expression<int>? parts,
    Expression<int>? attempt,
    Expression<int>? sentAt,
    Expression<int>? deliveredAt,
    Expression<String>? providerSmsId,
    Expression<String>? mergeSummary,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (contactId != null) 'contact_id': contactId,
      if (campaignId != null) 'campaign_id': campaignId,
      if (address != null) 'address': address,
      if (body != null) 'body': body,
      if (dueAt != null) 'due_at': dueAt,
      if (subId != null) 'sub_id': subId,
      if (status != null) 'status': status,
      if (errorCode != null) 'error_code': errorCode,
      if (errorLabel != null) 'error_label': errorLabel,
      if (parts != null) 'parts': parts,
      if (attempt != null) 'attempt': attempt,
      if (sentAt != null) 'sent_at': sentAt,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (providerSmsId != null) 'provider_sms_id': providerSmsId,
      if (mergeSummary != null) 'merge_summary': mergeSummary,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxMessagesCompanion copyWith({
    Value<String>? clientId,
    Value<int?>? contactId,
    Value<String?>? campaignId,
    Value<String>? address,
    Value<String>? body,
    Value<int>? dueAt,
    Value<int?>? subId,
    Value<String>? status,
    Value<int?>? errorCode,
    Value<String?>? errorLabel,
    Value<int?>? parts,
    Value<int>? attempt,
    Value<int?>? sentAt,
    Value<int?>? deliveredAt,
    Value<String?>? providerSmsId,
    Value<String?>? mergeSummary,
    Value<int?>? createdAt,
    Value<int?>? updatedAt,
    Value<int>? rowid,
  }) {
    return OutboxMessagesCompanion(
      clientId: clientId ?? this.clientId,
      contactId: contactId ?? this.contactId,
      campaignId: campaignId ?? this.campaignId,
      address: address ?? this.address,
      body: body ?? this.body,
      dueAt: dueAt ?? this.dueAt,
      subId: subId ?? this.subId,
      status: status ?? this.status,
      errorCode: errorCode ?? this.errorCode,
      errorLabel: errorLabel ?? this.errorLabel,
      parts: parts ?? this.parts,
      attempt: attempt ?? this.attempt,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      providerSmsId: providerSmsId ?? this.providerSmsId,
      mergeSummary: mergeSummary ?? this.mergeSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (contactId.present) {
      map['contact_id'] = Variable<int>(contactId.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (subId.present) {
      map['sub_id'] = Variable<int>(subId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<int>(errorCode.value);
    }
    if (errorLabel.present) {
      map['error_label'] = Variable<String>(errorLabel.value);
    }
    if (parts.present) {
      map['parts'] = Variable<int>(parts.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<int>(sentAt.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<int>(deliveredAt.value);
    }
    if (providerSmsId.present) {
      map['provider_sms_id'] = Variable<String>(providerSmsId.value);
    }
    if (mergeSummary.present) {
      map['merge_summary'] = Variable<String>(mergeSummary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxMessagesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('contactId: $contactId, ')
          ..write('campaignId: $campaignId, ')
          ..write('address: $address, ')
          ..write('body: $body, ')
          ..write('dueAt: $dueAt, ')
          ..write('subId: $subId, ')
          ..write('status: $status, ')
          ..write('errorCode: $errorCode, ')
          ..write('errorLabel: $errorLabel, ')
          ..write('parts: $parts, ')
          ..write('attempt: $attempt, ')
          ..write('sentAt: $sentAt, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('providerSmsId: $providerSmsId, ')
          ..write('mergeSummary: $mergeSummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String? value;
  const Setting({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  Setting copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => Setting(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final String key;
  final String? value;
  const SyncState({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SyncState copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SyncState(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SyncState> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SyncStatesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $TimelineEntriesTable timelineEntries = $TimelineEntriesTable(
    this,
  );
  late final $ScheduledSmsEntriesTable scheduledSmsEntries =
      $ScheduledSmsEntriesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $ContactListsTable contactLists = $ContactListsTable(this);
  late final $ContactListMembersTable contactListMembers =
      $ContactListMembersTable(this);
  late final $BulkSmsJobsTable bulkSmsJobs = $BulkSmsJobsTable(this);
  late final $ContactPhonesTable contactPhones = $ContactPhonesTable(this);
  late final $TimelineAttachmentsTable timelineAttachments =
      $TimelineAttachmentsTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $OutboxMessagesTable outboxMessages = $OutboxMessagesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contacts,
    timelineEntries,
    scheduledSmsEntries,
    tasks,
    contactLists,
    contactListMembers,
    bulkSmsJobs,
    contactPhones,
    timelineAttachments,
    templates,
    campaigns,
    outboxMessages,
    settings,
    syncStates,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timeline', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('scheduled_sms', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contact_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_list_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_list_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('contact_phones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'timeline',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('timeline_attachments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'contacts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('outbox_messages', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      Value<String?> phoneNumber,
      required String displayName,
      Value<String?> avatarColor,
      Value<int> isStarred,
      Value<String?> facebookUrl,
      Value<String?> linkedinUrl,
      Value<String?> gmailAddress,
      Value<String?> pinnedNote,
      Value<int> lastSyncTime,
      Value<String?> company,
      Value<String?> role,
      Value<String?> city,
      Value<String?> email,
      Value<String?> birthday,
      Value<String?> about,
      Value<int?> cadenceDays,
      Value<int?> cadenceSnoozedUntil,
      Value<int?> lastInteractionAt,
      Value<int> doNotMessage,
      Value<String?> deviceContactId,
      Value<String> source,
      Value<int?> createdAt,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<int> id,
      Value<String?> phoneNumber,
      Value<String> displayName,
      Value<String?> avatarColor,
      Value<int> isStarred,
      Value<String?> facebookUrl,
      Value<String?> linkedinUrl,
      Value<String?> gmailAddress,
      Value<String?> pinnedNote,
      Value<int> lastSyncTime,
      Value<String?> company,
      Value<String?> role,
      Value<String?> city,
      Value<String?> email,
      Value<String?> birthday,
      Value<String?> about,
      Value<int?> cadenceDays,
      Value<int?> cadenceSnoozedUntil,
      Value<int?> lastInteractionAt,
      Value<int> doNotMessage,
      Value<String?> deviceContactId,
      Value<String> source,
      Value<int?> createdAt,
    });

final class $$ContactsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactsTable, Contact> {
  $$ContactsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimelineEntriesTable, List<TimelineEntry>>
  _timelineEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timelineEntries,
    aliasName: 'contacts__id__timeline__contact_id',
  );

  $$TimelineEntriesTableProcessedTableManager get timelineEntriesRefs {
    final manager = $$TimelineEntriesTableTableManager(
      $_db,
      $_db.timelineEntries,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timelineEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ScheduledSmsEntriesTable, List<ScheduledSmsEntry>>
  _scheduledSmsEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.scheduledSmsEntries,
        aliasName: 'contacts__id__scheduled_sms__contact_id',
      );

  $$ScheduledSmsEntriesTableProcessedTableManager get scheduledSmsEntriesRefs {
    final manager = $$ScheduledSmsEntriesTableTableManager(
      $_db,
      $_db.scheduledSmsEntries,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduledSmsEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'contacts__id__tasks__contact_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ContactListMembersTable, List<ContactListMember>>
  _contactListMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactListMembers,
        aliasName: 'contacts__id__contact_list_members__contact_id',
      );

  $$ContactListMembersTableProcessedTableManager get contactListMembersRefs {
    final manager = $$ContactListMembersTableTableManager(
      $_db,
      $_db.contactListMembers,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _contactListMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ContactPhonesTable, List<ContactPhone>>
  _contactPhonesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contactPhones,
    aliasName: 'contacts__id__contact_phones__contact_id',
  );

  $$ContactPhonesTableProcessedTableManager get contactPhonesRefs {
    final manager = $$ContactPhonesTableTableManager(
      $_db,
      $_db.contactPhones,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactPhonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OutboxMessagesTable, List<OutboxMessage>>
  _outboxMessagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.outboxMessages,
    aliasName: 'contacts__id__outbox_messages__contact_id',
  );

  $$OutboxMessagesTableProcessedTableManager get outboxMessagesRefs {
    final manager = $$OutboxMessagesTableTableManager(
      $_db,
      $_db.outboxMessages,
    ).filter((f) => f.contactId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_outboxMessagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facebookUrl => $composableBuilder(
    column: $table.facebookUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedinUrl => $composableBuilder(
    column: $table.linkedinUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gmailAddress => $composableBuilder(
    column: $table.gmailAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pinnedNote => $composableBuilder(
    column: $table.pinnedNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get about => $composableBuilder(
    column: $table.about,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadenceSnoozedUntil => $composableBuilder(
    column: $table.cadenceSnoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastInteractionAt => $composableBuilder(
    column: $table.lastInteractionAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doNotMessage => $composableBuilder(
    column: $table.doNotMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceContactId => $composableBuilder(
    column: $table.deviceContactId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timelineEntriesRefs(
    Expression<bool> Function($$TimelineEntriesTableFilterComposer f) f,
  ) {
    final $$TimelineEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timelineEntries,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timelineEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> scheduledSmsEntriesRefs(
    Expression<bool> Function($$ScheduledSmsEntriesTableFilterComposer f) f,
  ) {
    final $$ScheduledSmsEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduledSmsEntries,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduledSmsEntriesTableFilterComposer(
            $db: $db,
            $table: $db.scheduledSmsEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> contactListMembersRefs(
    Expression<bool> Function($$ContactListMembersTableFilterComposer f) f,
  ) {
    final $$ContactListMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactListMembers,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactListMembersTableFilterComposer(
            $db: $db,
            $table: $db.contactListMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> contactPhonesRefs(
    Expression<bool> Function($$ContactPhonesTableFilterComposer f) f,
  ) {
    final $$ContactPhonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactPhones,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactPhonesTableFilterComposer(
            $db: $db,
            $table: $db.contactPhones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> outboxMessagesRefs(
    Expression<bool> Function($$OutboxMessagesTableFilterComposer f) f,
  ) {
    final $$OutboxMessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outboxMessages,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutboxMessagesTableFilterComposer(
            $db: $db,
            $table: $db.outboxMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facebookUrl => $composableBuilder(
    column: $table.facebookUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedinUrl => $composableBuilder(
    column: $table.linkedinUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gmailAddress => $composableBuilder(
    column: $table.gmailAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinnedNote => $composableBuilder(
    column: $table.pinnedNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get company => $composableBuilder(
    column: $table.company,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get about => $composableBuilder(
    column: $table.about,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadenceSnoozedUntil => $composableBuilder(
    column: $table.cadenceSnoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastInteractionAt => $composableBuilder(
    column: $table.lastInteractionAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doNotMessage => $composableBuilder(
    column: $table.doNotMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceContactId => $composableBuilder(
    column: $table.deviceContactId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarColor => $composableBuilder(
    column: $table.avatarColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<String> get facebookUrl => $composableBuilder(
    column: $table.facebookUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedinUrl => $composableBuilder(
    column: $table.linkedinUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gmailAddress => $composableBuilder(
    column: $table.gmailAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pinnedNote => $composableBuilder(
    column: $table.pinnedNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncTime => $composableBuilder(
    column: $table.lastSyncTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get company =>
      $composableBuilder(column: $table.company, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<String> get about =>
      $composableBuilder(column: $table.about, builder: (column) => column);

  GeneratedColumn<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cadenceSnoozedUntil => $composableBuilder(
    column: $table.cadenceSnoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastInteractionAt => $composableBuilder(
    column: $table.lastInteractionAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get doNotMessage => $composableBuilder(
    column: $table.doNotMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceContactId => $composableBuilder(
    column: $table.deviceContactId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> timelineEntriesRefs<T extends Object>(
    Expression<T> Function($$TimelineEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimelineEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timelineEntries,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timelineEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> scheduledSmsEntriesRefs<T extends Object>(
    Expression<T> Function($$ScheduledSmsEntriesTableAnnotationComposer a) f,
  ) {
    final $$ScheduledSmsEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.scheduledSmsEntries,
          getReferencedColumn: (t) => t.contactId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ScheduledSmsEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.scheduledSmsEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> contactListMembersRefs<T extends Object>(
    Expression<T> Function($$ContactListMembersTableAnnotationComposer a) f,
  ) {
    final $$ContactListMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.contactListMembers,
          getReferencedColumn: (t) => t.contactId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactListMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.contactListMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> contactPhonesRefs<T extends Object>(
    Expression<T> Function($$ContactPhonesTableAnnotationComposer a) f,
  ) {
    final $$ContactPhonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactPhones,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactPhonesTableAnnotationComposer(
            $db: $db,
            $table: $db.contactPhones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> outboxMessagesRefs<T extends Object>(
    Expression<T> Function($$OutboxMessagesTableAnnotationComposer a) f,
  ) {
    final $$OutboxMessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.outboxMessages,
      getReferencedColumn: (t) => t.contactId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OutboxMessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.outboxMessages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          Contact,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (Contact, $$ContactsTableReferences),
          Contact,
          PrefetchHooks Function({
            bool timelineEntriesRefs,
            bool scheduledSmsEntriesRefs,
            bool tasksRefs,
            bool contactListMembersRefs,
            bool contactPhonesRefs,
            bool outboxMessagesRefs,
          })
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> avatarColor = const Value.absent(),
                Value<int> isStarred = const Value.absent(),
                Value<String?> facebookUrl = const Value.absent(),
                Value<String?> linkedinUrl = const Value.absent(),
                Value<String?> gmailAddress = const Value.absent(),
                Value<String?> pinnedNote = const Value.absent(),
                Value<int> lastSyncTime = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> birthday = const Value.absent(),
                Value<String?> about = const Value.absent(),
                Value<int?> cadenceDays = const Value.absent(),
                Value<int?> cadenceSnoozedUntil = const Value.absent(),
                Value<int?> lastInteractionAt = const Value.absent(),
                Value<int> doNotMessage = const Value.absent(),
                Value<String?> deviceContactId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                phoneNumber: phoneNumber,
                displayName: displayName,
                avatarColor: avatarColor,
                isStarred: isStarred,
                facebookUrl: facebookUrl,
                linkedinUrl: linkedinUrl,
                gmailAddress: gmailAddress,
                pinnedNote: pinnedNote,
                lastSyncTime: lastSyncTime,
                company: company,
                role: role,
                city: city,
                email: email,
                birthday: birthday,
                about: about,
                cadenceDays: cadenceDays,
                cadenceSnoozedUntil: cadenceSnoozedUntil,
                lastInteractionAt: lastInteractionAt,
                doNotMessage: doNotMessage,
                deviceContactId: deviceContactId,
                source: source,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                required String displayName,
                Value<String?> avatarColor = const Value.absent(),
                Value<int> isStarred = const Value.absent(),
                Value<String?> facebookUrl = const Value.absent(),
                Value<String?> linkedinUrl = const Value.absent(),
                Value<String?> gmailAddress = const Value.absent(),
                Value<String?> pinnedNote = const Value.absent(),
                Value<int> lastSyncTime = const Value.absent(),
                Value<String?> company = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> birthday = const Value.absent(),
                Value<String?> about = const Value.absent(),
                Value<int?> cadenceDays = const Value.absent(),
                Value<int?> cadenceSnoozedUntil = const Value.absent(),
                Value<int?> lastInteractionAt = const Value.absent(),
                Value<int> doNotMessage = const Value.absent(),
                Value<String?> deviceContactId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                phoneNumber: phoneNumber,
                displayName: displayName,
                avatarColor: avatarColor,
                isStarred: isStarred,
                facebookUrl: facebookUrl,
                linkedinUrl: linkedinUrl,
                gmailAddress: gmailAddress,
                pinnedNote: pinnedNote,
                lastSyncTime: lastSyncTime,
                company: company,
                role: role,
                city: city,
                email: email,
                birthday: birthday,
                about: about,
                cadenceDays: cadenceDays,
                cadenceSnoozedUntil: cadenceSnoozedUntil,
                lastInteractionAt: lastInteractionAt,
                doNotMessage: doNotMessage,
                deviceContactId: deviceContactId,
                source: source,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactsTable, Contact>(table),
                  $$ContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                timelineEntriesRefs = false,
                scheduledSmsEntriesRefs = false,
                tasksRefs = false,
                contactListMembersRefs = false,
                contactPhonesRefs = false,
                outboxMessagesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (timelineEntriesRefs) db.timelineEntries,
                    if (scheduledSmsEntriesRefs) db.scheduledSmsEntries,
                    if (tasksRefs) db.tasks,
                    if (contactListMembersRefs) db.contactListMembers,
                    if (contactPhonesRefs) db.contactPhones,
                    if (outboxMessagesRefs) db.outboxMessages,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (timelineEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Contact,
                          $ContactsTable,
                          TimelineEntry,
                          $TimelineEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._timelineEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).timelineEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'contact_id',
                          typedResults: items,
                        ),
                      if (scheduledSmsEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Contact,
                          $ContactsTable,
                          ScheduledSmsEntry,
                          $ScheduledSmsEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._scheduledSmsEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduledSmsEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'contact_id',
                          typedResults: items,
                        ),
                      if (tasksRefs)
                        await $_getPrefetchedDataByColumns<
                          Contact,
                          $ContactsTable,
                          Task,
                          $TasksTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._tasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).tasksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'contact_id',
                          typedResults: items,
                        ),
                      if (contactListMembersRefs)
                        await $_getPrefetchedDataByColumns<
                          Contact,
                          $ContactsTable,
                          ContactListMember,
                          $ContactListMembersTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._contactListMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactListMembersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'contact_id',
                          typedResults: items,
                        ),
                      if (contactPhonesRefs)
                        await $_getPrefetchedDataByColumns<
                          Contact,
                          $ContactsTable,
                          ContactPhone,
                          $ContactPhonesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._contactPhonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).contactPhonesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'contact_id',
                          typedResults: items,
                        ),
                      if (outboxMessagesRefs)
                        await $_getPrefetchedDataByColumns<
                          Contact,
                          $ContactsTable,
                          OutboxMessage,
                          $OutboxMessagesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ContactsTableReferences
                              ._outboxMessagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContactsTableReferences(
                                db,
                                table,
                                p0,
                              ).outboxMessagesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'contact_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      Contact,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (Contact, $$ContactsTableReferences),
      Contact,
      PrefetchHooks Function({
        bool timelineEntriesRefs,
        bool scheduledSmsEntriesRefs,
        bool tasksRefs,
        bool contactListMembersRefs,
        bool contactPhonesRefs,
        bool outboxMessagesRefs,
      })
    >;
typedef $$TimelineEntriesTableCreateCompanionBuilder =
    TimelineEntriesCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      required String type,
      required int timestamp,
      Value<String?> content,
      Value<double?> amount,
      Value<String?> attachmentPath,
      Value<String?> nativeMessageId,
      Value<int> isPinned,
      Value<String?> note,
      Value<String?> outcome,
      Value<int?> durationSeconds,
      Value<String?> placeName,
      Value<double?> lat,
      Value<double?> lng,
      Value<String?> currency,
      Value<String?> paymentStatus,
      Value<double?> suggestedAmount,
      Value<String?> suggestionState,
      Value<int?> reviewedAt,
      Value<int> hidden,
      Value<String?> source,
      Value<String?> outboxClientId,
      Value<int?> editedAt,
    });
typedef $$TimelineEntriesTableUpdateCompanionBuilder =
    TimelineEntriesCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      Value<String> type,
      Value<int> timestamp,
      Value<String?> content,
      Value<double?> amount,
      Value<String?> attachmentPath,
      Value<String?> nativeMessageId,
      Value<int> isPinned,
      Value<String?> note,
      Value<String?> outcome,
      Value<int?> durationSeconds,
      Value<String?> placeName,
      Value<double?> lat,
      Value<double?> lng,
      Value<String?> currency,
      Value<String?> paymentStatus,
      Value<double?> suggestedAmount,
      Value<String?> suggestionState,
      Value<int?> reviewedAt,
      Value<int> hidden,
      Value<String?> source,
      Value<String?> outboxClientId,
      Value<int?> editedAt,
    });

final class $$TimelineEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TimelineEntriesTable, TimelineEntry> {
  $$TimelineEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias('timeline__contact_id__contacts__id');

  $$ContactsTableProcessedTableManager? get contactId {
    final $_column = $_itemColumn<int>('contact_id');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $TimelineAttachmentsTable,
    List<TimelineAttachment>
  >
  _timelineAttachmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.timelineAttachments,
        aliasName: 'timeline__id__timeline_attachments__timeline_id',
      );

  $$TimelineAttachmentsTableProcessedTableManager get timelineAttachmentsRefs {
    final manager = $$TimelineAttachmentsTableTableManager(
      $_db,
      $_db.timelineAttachments,
    ).filter((f) => f.timelineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timelineAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimelineEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeMessageId => $composableBuilder(
    column: $table.nativeMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get suggestedAmount => $composableBuilder(
    column: $table.suggestedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestionState => $composableBuilder(
    column: $table.suggestionState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outboxClientId => $composableBuilder(
    column: $table.outboxClientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> timelineAttachmentsRefs(
    Expression<bool> Function($$TimelineAttachmentsTableFilterComposer f) f,
  ) {
    final $$TimelineAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timelineAttachments,
      getReferencedColumn: (t) => t.timelineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.timelineAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimelineEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeMessageId => $composableBuilder(
    column: $table.nativeMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeName => $composableBuilder(
    column: $table.placeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get suggestedAmount => $composableBuilder(
    column: $table.suggestedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestionState => $composableBuilder(
    column: $table.suggestionState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outboxClientId => $composableBuilder(
    column: $table.outboxClientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineEntriesTable> {
  $$TimelineEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeMessageId => $composableBuilder(
    column: $table.nativeMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placeName =>
      $composableBuilder(column: $table.placeName, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get suggestedAmount => $composableBuilder(
    column: $table.suggestedAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestionState => $composableBuilder(
    column: $table.suggestionState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get outboxClientId => $composableBuilder(
    column: $table.outboxClientId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> timelineAttachmentsRefs<T extends Object>(
    Expression<T> Function($$TimelineAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$TimelineAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.timelineAttachments,
          getReferencedColumn: (t) => t.timelineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TimelineAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.timelineAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TimelineEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineEntriesTable,
          TimelineEntry,
          $$TimelineEntriesTableFilterComposer,
          $$TimelineEntriesTableOrderingComposer,
          $$TimelineEntriesTableAnnotationComposer,
          $$TimelineEntriesTableCreateCompanionBuilder,
          $$TimelineEntriesTableUpdateCompanionBuilder,
          (TimelineEntry, $$TimelineEntriesTableReferences),
          TimelineEntry,
          PrefetchHooks Function({bool contactId, bool timelineAttachmentsRefs})
        > {
  $$TimelineEntriesTableTableManager(
    _$AppDatabase db,
    $TimelineEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<String?> nativeMessageId = const Value.absent(),
                Value<int> isPinned = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> placeName = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> paymentStatus = const Value.absent(),
                Value<double?> suggestedAmount = const Value.absent(),
                Value<String?> suggestionState = const Value.absent(),
                Value<int?> reviewedAt = const Value.absent(),
                Value<int> hidden = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> outboxClientId = const Value.absent(),
                Value<int?> editedAt = const Value.absent(),
              }) => TimelineEntriesCompanion(
                id: id,
                contactId: contactId,
                type: type,
                timestamp: timestamp,
                content: content,
                amount: amount,
                attachmentPath: attachmentPath,
                nativeMessageId: nativeMessageId,
                isPinned: isPinned,
                note: note,
                outcome: outcome,
                durationSeconds: durationSeconds,
                placeName: placeName,
                lat: lat,
                lng: lng,
                currency: currency,
                paymentStatus: paymentStatus,
                suggestedAmount: suggestedAmount,
                suggestionState: suggestionState,
                reviewedAt: reviewedAt,
                hidden: hidden,
                source: source,
                outboxClientId: outboxClientId,
                editedAt: editedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                required String type,
                required int timestamp,
                Value<String?> content = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<String?> nativeMessageId = const Value.absent(),
                Value<int> isPinned = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> placeName = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> paymentStatus = const Value.absent(),
                Value<double?> suggestedAmount = const Value.absent(),
                Value<String?> suggestionState = const Value.absent(),
                Value<int?> reviewedAt = const Value.absent(),
                Value<int> hidden = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<String?> outboxClientId = const Value.absent(),
                Value<int?> editedAt = const Value.absent(),
              }) => TimelineEntriesCompanion.insert(
                id: id,
                contactId: contactId,
                type: type,
                timestamp: timestamp,
                content: content,
                amount: amount,
                attachmentPath: attachmentPath,
                nativeMessageId: nativeMessageId,
                isPinned: isPinned,
                note: note,
                outcome: outcome,
                durationSeconds: durationSeconds,
                placeName: placeName,
                lat: lat,
                lng: lng,
                currency: currency,
                paymentStatus: paymentStatus,
                suggestedAmount: suggestedAmount,
                suggestionState: suggestionState,
                reviewedAt: reviewedAt,
                hidden: hidden,
                source: source,
                outboxClientId: outboxClientId,
                editedAt: editedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimelineEntriesTable, TimelineEntry>(table),
                  $$TimelineEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({contactId = false, timelineAttachmentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (timelineAttachmentsRefs) db.timelineAttachments,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contactId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contactId,
                                    referencedTable:
                                        $$TimelineEntriesTableReferences
                                            ._contactIdTable(db),
                                    referencedColumn:
                                        $$TimelineEntriesTableReferences
                                            ._contactIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (timelineAttachmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          TimelineEntry,
                          $TimelineEntriesTable,
                          TimelineAttachment,
                          $TimelineAttachmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$TimelineEntriesTableReferences
                              ._timelineAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TimelineEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).timelineAttachmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'timeline_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TimelineEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineEntriesTable,
      TimelineEntry,
      $$TimelineEntriesTableFilterComposer,
      $$TimelineEntriesTableOrderingComposer,
      $$TimelineEntriesTableAnnotationComposer,
      $$TimelineEntriesTableCreateCompanionBuilder,
      $$TimelineEntriesTableUpdateCompanionBuilder,
      (TimelineEntry, $$TimelineEntriesTableReferences),
      TimelineEntry,
      PrefetchHooks Function({bool contactId, bool timelineAttachmentsRefs})
    >;
typedef $$ScheduledSmsEntriesTableCreateCompanionBuilder =
    ScheduledSmsEntriesCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      required String phoneNumber,
      required String message,
      required int scheduledTime,
      Value<int> isSent,
      Value<int?> bulkJobId,
    });
typedef $$ScheduledSmsEntriesTableUpdateCompanionBuilder =
    ScheduledSmsEntriesCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      Value<String> phoneNumber,
      Value<String> message,
      Value<int> scheduledTime,
      Value<int> isSent,
      Value<int?> bulkJobId,
    });

final class $$ScheduledSmsEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ScheduledSmsEntriesTable,
          ScheduledSmsEntry
        > {
  $$ScheduledSmsEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias('scheduled_sms__contact_id__contacts__id');

  $$ContactsTableProcessedTableManager? get contactId {
    final $_column = $_itemColumn<int>('contact_id');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduledSmsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduledSmsEntriesTable> {
  $$ScheduledSmsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSent => $composableBuilder(
    column: $table.isSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bulkJobId => $composableBuilder(
    column: $table.bulkJobId,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledSmsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduledSmsEntriesTable> {
  $$ScheduledSmsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSent => $composableBuilder(
    column: $table.isSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bulkJobId => $composableBuilder(
    column: $table.bulkJobId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledSmsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduledSmsEntriesTable> {
  $$ScheduledSmsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSent =>
      $composableBuilder(column: $table.isSent, builder: (column) => column);

  GeneratedColumn<int> get bulkJobId =>
      $composableBuilder(column: $table.bulkJobId, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduledSmsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduledSmsEntriesTable,
          ScheduledSmsEntry,
          $$ScheduledSmsEntriesTableFilterComposer,
          $$ScheduledSmsEntriesTableOrderingComposer,
          $$ScheduledSmsEntriesTableAnnotationComposer,
          $$ScheduledSmsEntriesTableCreateCompanionBuilder,
          $$ScheduledSmsEntriesTableUpdateCompanionBuilder,
          (ScheduledSmsEntry, $$ScheduledSmsEntriesTableReferences),
          ScheduledSmsEntry,
          PrefetchHooks Function({bool contactId})
        > {
  $$ScheduledSmsEntriesTableTableManager(
    _$AppDatabase db,
    $ScheduledSmsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledSmsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduledSmsEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduledSmsEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<String> phoneNumber = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int> scheduledTime = const Value.absent(),
                Value<int> isSent = const Value.absent(),
                Value<int?> bulkJobId = const Value.absent(),
              }) => ScheduledSmsEntriesCompanion(
                id: id,
                contactId: contactId,
                phoneNumber: phoneNumber,
                message: message,
                scheduledTime: scheduledTime,
                isSent: isSent,
                bulkJobId: bulkJobId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                required String phoneNumber,
                required String message,
                required int scheduledTime,
                Value<int> isSent = const Value.absent(),
                Value<int?> bulkJobId = const Value.absent(),
              }) => ScheduledSmsEntriesCompanion.insert(
                id: id,
                contactId: contactId,
                phoneNumber: phoneNumber,
                message: message,
                scheduledTime: scheduledTime,
                isSent: isSent,
                bulkJobId: bulkJobId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduledSmsEntriesTable, ScheduledSmsEntry>(
                    table,
                  ),
                  $$ScheduledSmsEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable:
                                    $$ScheduledSmsEntriesTableReferences
                                        ._contactIdTable(db),
                                referencedColumn:
                                    $$ScheduledSmsEntriesTableReferences
                                        ._contactIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduledSmsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduledSmsEntriesTable,
      ScheduledSmsEntry,
      $$ScheduledSmsEntriesTableFilterComposer,
      $$ScheduledSmsEntriesTableOrderingComposer,
      $$ScheduledSmsEntriesTableAnnotationComposer,
      $$ScheduledSmsEntriesTableCreateCompanionBuilder,
      $$ScheduledSmsEntriesTableUpdateCompanionBuilder,
      (ScheduledSmsEntry, $$ScheduledSmsEntriesTableReferences),
      ScheduledSmsEntry,
      PrefetchHooks Function({bool contactId})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      required String title,
      required int dueDate,
      Value<int> isCompleted,
      Value<int?> reminderTime,
      Value<String?> note,
      Value<int?> createdAt,
      Value<int?> completedAt,
      Value<int?> sourceTimelineId,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int?> contactId,
      Value<String> title,
      Value<int> dueDate,
      Value<int> isCompleted,
      Value<int?> reminderTime,
      Value<String?> note,
      Value<int?> createdAt,
      Value<int?> completedAt,
      Value<int?> sourceTimelineId,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias('tasks__contact_id__contacts__id');

  $$ContactsTableProcessedTableManager? get contactId {
    final $_column = $_itemColumn<int>('contact_id');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceTimelineId => $composableBuilder(
    column: $table.sourceTimelineId,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceTimelineId => $composableBuilder(
    column: $table.sourceTimelineId,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceTimelineId => $composableBuilder(
    column: $table.sourceTimelineId,
    builder: (column) => column,
  );

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool contactId})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> dueDate = const Value.absent(),
                Value<int> isCompleted = const Value.absent(),
                Value<int?> reminderTime = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> sourceTimelineId = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                contactId: contactId,
                title: title,
                dueDate: dueDate,
                isCompleted: isCompleted,
                reminderTime: reminderTime,
                note: note,
                createdAt: createdAt,
                completedAt: completedAt,
                sourceTimelineId: sourceTimelineId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                required String title,
                required int dueDate,
                Value<int> isCompleted = const Value.absent(),
                Value<int?> reminderTime = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int?> sourceTimelineId = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                contactId: contactId,
                title: title,
                dueDate: dueDate,
                isCompleted: isCompleted,
                reminderTime: reminderTime,
                note: note,
                createdAt: createdAt,
                completedAt: completedAt,
                sourceTimelineId: sourceTimelineId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  $$TasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable: $$TasksTableReferences
                                    ._contactIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._contactIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool contactId})
    >;
typedef $$ContactListsTableCreateCompanionBuilder =
    ContactListsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> cadenceDays,
      Value<int?> createdAt,
    });
typedef $$ContactListsTableUpdateCompanionBuilder =
    ContactListsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> cadenceDays,
      Value<int?> createdAt,
    });

final class $$ContactListsTableReferences
    extends BaseReferences<_$AppDatabase, $ContactListsTable, ContactList> {
  $$ContactListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContactListMembersTable, List<ContactListMember>>
  _contactListMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.contactListMembers,
        aliasName: 'contact_lists__id__contact_list_members__list_id',
      );

  $$ContactListMembersTableProcessedTableManager get contactListMembersRefs {
    final manager = $$ContactListMembersTableTableManager(
      $_db,
      $_db.contactListMembers,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _contactListMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContactListsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactListsTable> {
  $$ContactListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contactListMembersRefs(
    Expression<bool> Function($$ContactListMembersTableFilterComposer f) f,
  ) {
    final $$ContactListMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contactListMembers,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactListMembersTableFilterComposer(
            $db: $db,
            $table: $db.contactListMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContactListsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactListsTable> {
  $$ContactListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactListsTable> {
  $$ContactListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get cadenceDays => $composableBuilder(
    column: $table.cadenceDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> contactListMembersRefs<T extends Object>(
    Expression<T> Function($$ContactListMembersTableAnnotationComposer a) f,
  ) {
    final $$ContactListMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.contactListMembers,
          getReferencedColumn: (t) => t.listId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ContactListMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.contactListMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContactListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactListsTable,
          ContactList,
          $$ContactListsTableFilterComposer,
          $$ContactListsTableOrderingComposer,
          $$ContactListsTableAnnotationComposer,
          $$ContactListsTableCreateCompanionBuilder,
          $$ContactListsTableUpdateCompanionBuilder,
          (ContactList, $$ContactListsTableReferences),
          ContactList,
          PrefetchHooks Function({bool contactListMembersRefs})
        > {
  $$ContactListsTableTableManager(_$AppDatabase db, $ContactListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> cadenceDays = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
              }) => ContactListsCompanion(
                id: id,
                name: name,
                cadenceDays: cadenceDays,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> cadenceDays = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
              }) => ContactListsCompanion.insert(
                id: id,
                name: name,
                cadenceDays: cadenceDays,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactListsTable, ContactList>(table),
                  $$ContactListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactListMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (contactListMembersRefs) db.contactListMembers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contactListMembersRefs)
                    await $_getPrefetchedDataByColumns<
                      ContactList,
                      $ContactListsTable,
                      ContactListMember,
                      $ContactListMembersTable
                    >(
                      currentTable: table,
                      referencedTable: $$ContactListsTableReferences
                          ._contactListMembersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ContactListsTableReferences(
                            db,
                            table,
                            p0,
                          ).contactListMembersRefs,
                      currentColumn: 'id',
                      referencedColumn: 'list_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ContactListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactListsTable,
      ContactList,
      $$ContactListsTableFilterComposer,
      $$ContactListsTableOrderingComposer,
      $$ContactListsTableAnnotationComposer,
      $$ContactListsTableCreateCompanionBuilder,
      $$ContactListsTableUpdateCompanionBuilder,
      (ContactList, $$ContactListsTableReferences),
      ContactList,
      PrefetchHooks Function({bool contactListMembersRefs})
    >;
typedef $$ContactListMembersTableCreateCompanionBuilder =
    ContactListMembersCompanion Function({
      Value<int> id,
      Value<int?> listId,
      Value<int?> contactId,
    });
typedef $$ContactListMembersTableUpdateCompanionBuilder =
    ContactListMembersCompanion Function({
      Value<int> id,
      Value<int?> listId,
      Value<int?> contactId,
    });

final class $$ContactListMembersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ContactListMembersTable,
          ContactListMember
        > {
  $$ContactListMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContactListsTable _listIdTable(_$AppDatabase db) => db.contactLists
      .createAlias('contact_list_members__list_id__contact_lists__id');

  $$ContactListsTableProcessedTableManager? get listId {
    final $_column = $_itemColumn<int>('list_id');
    if ($_column == null) return null;
    final manager = $$ContactListsTableTableManager(
      $_db,
      $_db.contactLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias('contact_list_members__contact_id__contacts__id');

  $$ContactsTableProcessedTableManager? get contactId {
    final $_column = $_itemColumn<int>('contact_id');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactListMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ContactListMembersTable> {
  $$ContactListMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactListsTableFilterComposer get listId {
    final $$ContactListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.contactLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactListsTableFilterComposer(
            $db: $db,
            $table: $db.contactLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactListMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactListMembersTable> {
  $$ContactListMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactListsTableOrderingComposer get listId {
    final $$ContactListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.contactLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactListsTableOrderingComposer(
            $db: $db,
            $table: $db.contactLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactListMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactListMembersTable> {
  $$ContactListMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  $$ContactListsTableAnnotationComposer get listId {
    final $$ContactListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.contactLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactListsTableAnnotationComposer(
            $db: $db,
            $table: $db.contactLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactListMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactListMembersTable,
          ContactListMember,
          $$ContactListMembersTableFilterComposer,
          $$ContactListMembersTableOrderingComposer,
          $$ContactListMembersTableAnnotationComposer,
          $$ContactListMembersTableCreateCompanionBuilder,
          $$ContactListMembersTableUpdateCompanionBuilder,
          (ContactListMember, $$ContactListMembersTableReferences),
          ContactListMember,
          PrefetchHooks Function({bool listId, bool contactId})
        > {
  $$ContactListMembersTableTableManager(
    _$AppDatabase db,
    $ContactListMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactListMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactListMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactListMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> listId = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
              }) => ContactListMembersCompanion(
                id: id,
                listId: listId,
                contactId: contactId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> listId = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
              }) => ContactListMembersCompanion.insert(
                id: id,
                listId: listId,
                contactId: contactId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactListMembersTable, ContactListMember>(
                    table,
                  ),
                  $$ContactListMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false, contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$ContactListMembersTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$ContactListMembersTableReferences
                                        ._listIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable:
                                    $$ContactListMembersTableReferences
                                        ._contactIdTable(db),
                                referencedColumn:
                                    $$ContactListMembersTableReferences
                                        ._contactIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ContactListMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactListMembersTable,
      ContactListMember,
      $$ContactListMembersTableFilterComposer,
      $$ContactListMembersTableOrderingComposer,
      $$ContactListMembersTableAnnotationComposer,
      $$ContactListMembersTableCreateCompanionBuilder,
      $$ContactListMembersTableUpdateCompanionBuilder,
      (ContactListMember, $$ContactListMembersTableReferences),
      ContactListMember,
      PrefetchHooks Function({bool listId, bool contactId})
    >;
typedef $$BulkSmsJobsTableCreateCompanionBuilder =
    BulkSmsJobsCompanion Function({
      Value<int> id,
      required String listName,
      required String message,
      required int scheduledTime,
      Value<int> isSent,
    });
typedef $$BulkSmsJobsTableUpdateCompanionBuilder =
    BulkSmsJobsCompanion Function({
      Value<int> id,
      Value<String> listName,
      Value<String> message,
      Value<int> scheduledTime,
      Value<int> isSent,
    });

class $$BulkSmsJobsTableFilterComposer
    extends Composer<_$AppDatabase, $BulkSmsJobsTable> {
  $$BulkSmsJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listName => $composableBuilder(
    column: $table.listName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSent => $composableBuilder(
    column: $table.isSent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BulkSmsJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $BulkSmsJobsTable> {
  $$BulkSmsJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listName => $composableBuilder(
    column: $table.listName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSent => $composableBuilder(
    column: $table.isSent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BulkSmsJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BulkSmsJobsTable> {
  $$BulkSmsJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listName =>
      $composableBuilder(column: $table.listName, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSent =>
      $composableBuilder(column: $table.isSent, builder: (column) => column);
}

class $$BulkSmsJobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BulkSmsJobsTable,
          BulkSmsJob,
          $$BulkSmsJobsTableFilterComposer,
          $$BulkSmsJobsTableOrderingComposer,
          $$BulkSmsJobsTableAnnotationComposer,
          $$BulkSmsJobsTableCreateCompanionBuilder,
          $$BulkSmsJobsTableUpdateCompanionBuilder,
          (
            BulkSmsJob,
            BaseReferences<_$AppDatabase, $BulkSmsJobsTable, BulkSmsJob>,
          ),
          BulkSmsJob,
          PrefetchHooks Function()
        > {
  $$BulkSmsJobsTableTableManager(_$AppDatabase db, $BulkSmsJobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BulkSmsJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BulkSmsJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BulkSmsJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> listName = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int> scheduledTime = const Value.absent(),
                Value<int> isSent = const Value.absent(),
              }) => BulkSmsJobsCompanion(
                id: id,
                listName: listName,
                message: message,
                scheduledTime: scheduledTime,
                isSent: isSent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String listName,
                required String message,
                required int scheduledTime,
                Value<int> isSent = const Value.absent(),
              }) => BulkSmsJobsCompanion.insert(
                id: id,
                listName: listName,
                message: message,
                scheduledTime: scheduledTime,
                isSent: isSent,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BulkSmsJobsTable, BulkSmsJob>(table),
                  BaseReferences<_$AppDatabase, $BulkSmsJobsTable, BulkSmsJob>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BulkSmsJobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BulkSmsJobsTable,
      BulkSmsJob,
      $$BulkSmsJobsTableFilterComposer,
      $$BulkSmsJobsTableOrderingComposer,
      $$BulkSmsJobsTableAnnotationComposer,
      $$BulkSmsJobsTableCreateCompanionBuilder,
      $$BulkSmsJobsTableUpdateCompanionBuilder,
      (
        BulkSmsJob,
        BaseReferences<_$AppDatabase, $BulkSmsJobsTable, BulkSmsJob>,
      ),
      BulkSmsJob,
      PrefetchHooks Function()
    >;
typedef $$ContactPhonesTableCreateCompanionBuilder =
    ContactPhonesCompanion Function({
      Value<int> id,
      required int contactId,
      Value<String?> e164,
      Value<String?> raw,
      Value<String?> label,
      Value<int> isPrimary,
      Value<int> isMobile,
    });
typedef $$ContactPhonesTableUpdateCompanionBuilder =
    ContactPhonesCompanion Function({
      Value<int> id,
      Value<int> contactId,
      Value<String?> e164,
      Value<String?> raw,
      Value<String?> label,
      Value<int> isPrimary,
      Value<int> isMobile,
    });

final class $$ContactPhonesTableReferences
    extends BaseReferences<_$AppDatabase, $ContactPhonesTable, ContactPhone> {
  $$ContactPhonesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias('contact_phones__contact_id__contacts__id');

  $$ContactsTableProcessedTableManager get contactId {
    final $_column = $_itemColumn<int>('contact_id')!;

    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ContactPhonesTableFilterComposer
    extends Composer<_$AppDatabase, $ContactPhonesTable> {
  $$ContactPhonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get e164 => $composableBuilder(
    column: $table.e164,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isMobile => $composableBuilder(
    column: $table.isMobile,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactPhonesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactPhonesTable> {
  $$ContactPhonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get e164 => $composableBuilder(
    column: $table.e164,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get raw => $composableBuilder(
    column: $table.raw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isMobile => $composableBuilder(
    column: $table.isMobile,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactPhonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactPhonesTable> {
  $$ContactPhonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get e164 =>
      $composableBuilder(column: $table.e164, builder: (column) => column);

  GeneratedColumn<String> get raw =>
      $composableBuilder(column: $table.raw, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<int> get isMobile =>
      $composableBuilder(column: $table.isMobile, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContactPhonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactPhonesTable,
          ContactPhone,
          $$ContactPhonesTableFilterComposer,
          $$ContactPhonesTableOrderingComposer,
          $$ContactPhonesTableAnnotationComposer,
          $$ContactPhonesTableCreateCompanionBuilder,
          $$ContactPhonesTableUpdateCompanionBuilder,
          (ContactPhone, $$ContactPhonesTableReferences),
          ContactPhone,
          PrefetchHooks Function({bool contactId})
        > {
  $$ContactPhonesTableTableManager(_$AppDatabase db, $ContactPhonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactPhonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactPhonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactPhonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> contactId = const Value.absent(),
                Value<String?> e164 = const Value.absent(),
                Value<String?> raw = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> isPrimary = const Value.absent(),
                Value<int> isMobile = const Value.absent(),
              }) => ContactPhonesCompanion(
                id: id,
                contactId: contactId,
                e164: e164,
                raw: raw,
                label: label,
                isPrimary: isPrimary,
                isMobile: isMobile,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int contactId,
                Value<String?> e164 = const Value.absent(),
                Value<String?> raw = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> isPrimary = const Value.absent(),
                Value<int> isMobile = const Value.absent(),
              }) => ContactPhonesCompanion.insert(
                id: id,
                contactId: contactId,
                e164: e164,
                raw: raw,
                label: label,
                isPrimary: isPrimary,
                isMobile: isMobile,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ContactPhonesTable, ContactPhone>(table),
                  $$ContactPhonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable: $$ContactPhonesTableReferences
                                    ._contactIdTable(db),
                                referencedColumn: $$ContactPhonesTableReferences
                                    ._contactIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ContactPhonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactPhonesTable,
      ContactPhone,
      $$ContactPhonesTableFilterComposer,
      $$ContactPhonesTableOrderingComposer,
      $$ContactPhonesTableAnnotationComposer,
      $$ContactPhonesTableCreateCompanionBuilder,
      $$ContactPhonesTableUpdateCompanionBuilder,
      (ContactPhone, $$ContactPhonesTableReferences),
      ContactPhone,
      PrefetchHooks Function({bool contactId})
    >;
typedef $$TimelineAttachmentsTableCreateCompanionBuilder =
    TimelineAttachmentsCompanion Function({
      Value<int> id,
      required int timelineId,
      required String path,
      Value<String?> mime,
      Value<int?> createdAt,
    });
typedef $$TimelineAttachmentsTableUpdateCompanionBuilder =
    TimelineAttachmentsCompanion Function({
      Value<int> id,
      Value<int> timelineId,
      Value<String> path,
      Value<String?> mime,
      Value<int?> createdAt,
    });

final class $$TimelineAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TimelineAttachmentsTable,
          TimelineAttachment
        > {
  $$TimelineAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TimelineEntriesTable _timelineIdTable(_$AppDatabase db) => db
      .timelineEntries
      .createAlias('timeline_attachments__timeline_id__timeline__id');

  $$TimelineEntriesTableProcessedTableManager get timelineId {
    final $_column = $_itemColumn<int>('timeline_id')!;

    final manager = $$TimelineEntriesTableTableManager(
      $_db,
      $_db.timelineEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_timelineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimelineAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineAttachmentsTable> {
  $$TimelineAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TimelineEntriesTableFilterComposer get timelineId {
    final $$TimelineEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timelineId,
      referencedTable: $db.timelineEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timelineEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineAttachmentsTable> {
  $$TimelineAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TimelineEntriesTableOrderingComposer get timelineId {
    final $$TimelineEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timelineId,
      referencedTable: $db.timelineEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.timelineEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineAttachmentsTable> {
  $$TimelineAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TimelineEntriesTableAnnotationComposer get timelineId {
    final $$TimelineEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.timelineId,
      referencedTable: $db.timelineEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimelineEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timelineEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimelineAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineAttachmentsTable,
          TimelineAttachment,
          $$TimelineAttachmentsTableFilterComposer,
          $$TimelineAttachmentsTableOrderingComposer,
          $$TimelineAttachmentsTableAnnotationComposer,
          $$TimelineAttachmentsTableCreateCompanionBuilder,
          $$TimelineAttachmentsTableUpdateCompanionBuilder,
          (TimelineAttachment, $$TimelineAttachmentsTableReferences),
          TimelineAttachment,
          PrefetchHooks Function({bool timelineId})
        > {
  $$TimelineAttachmentsTableTableManager(
    _$AppDatabase db,
    $TimelineAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineAttachmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TimelineAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> timelineId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
              }) => TimelineAttachmentsCompanion(
                id: id,
                timelineId: timelineId,
                path: path,
                mime: mime,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int timelineId,
                required String path,
                Value<String?> mime = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
              }) => TimelineAttachmentsCompanion.insert(
                id: id,
                timelineId: timelineId,
                path: path,
                mime: mime,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimelineAttachmentsTable, TimelineAttachment>(
                    table,
                  ),
                  $$TimelineAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timelineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (timelineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.timelineId,
                                referencedTable:
                                    $$TimelineAttachmentsTableReferences
                                        ._timelineIdTable(db),
                                referencedColumn:
                                    $$TimelineAttachmentsTableReferences
                                        ._timelineIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TimelineAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineAttachmentsTable,
      TimelineAttachment,
      $$TimelineAttachmentsTableFilterComposer,
      $$TimelineAttachmentsTableOrderingComposer,
      $$TimelineAttachmentsTableAnnotationComposer,
      $$TimelineAttachmentsTableCreateCompanionBuilder,
      $$TimelineAttachmentsTableUpdateCompanionBuilder,
      (TimelineAttachment, $$TimelineAttachmentsTableReferences),
      TimelineAttachment,
      PrefetchHooks Function({bool timelineId})
    >;
typedef $$TemplatesTableCreateCompanionBuilder =
    TemplatesCompanion Function({
      Value<int> id,
      required String name,
      required String body,
      Value<int?> createdAt,
      Value<int?> updatedAt,
    });
typedef $$TemplatesTableUpdateCompanionBuilder =
    TemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> body,
      Value<int?> createdAt,
      Value<int?> updatedAt,
    });

class $$TemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplatesTable,
          Template,
          $$TemplatesTableFilterComposer,
          $$TemplatesTableOrderingComposer,
          $$TemplatesTableAnnotationComposer,
          $$TemplatesTableCreateCompanionBuilder,
          $$TemplatesTableUpdateCompanionBuilder,
          (Template, BaseReferences<_$AppDatabase, $TemplatesTable, Template>),
          Template,
          PrefetchHooks Function()
        > {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => TemplatesCompanion(
                id: id,
                name: name,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String body,
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
              }) => TemplatesCompanion.insert(
                id: id,
                name: name,
                body: body,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TemplatesTable, Template>(table),
                  BaseReferences<_$AppDatabase, $TemplatesTable, Template>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplatesTable,
      Template,
      $$TemplatesTableFilterComposer,
      $$TemplatesTableOrderingComposer,
      $$TemplatesTableAnnotationComposer,
      $$TemplatesTableCreateCompanionBuilder,
      $$TemplatesTableUpdateCompanionBuilder,
      (Template, BaseReferences<_$AppDatabase, $TemplatesTable, Template>),
      Template,
      PrefetchHooks Function()
    >;
typedef $$CampaignsTableCreateCompanionBuilder =
    CampaignsCompanion Function({
      required String id,
      required String name,
      required String bodyTemplate,
      Value<int?> scheduledAt,
      required String status,
      Value<int?> subId,
      Value<int?> paceSeconds,
      Value<int?> windowStartMin,
      Value<int?> windowEndMin,
      Value<int?> createdAt,
      Value<int> rowid,
    });
typedef $$CampaignsTableUpdateCompanionBuilder =
    CampaignsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> bodyTemplate,
      Value<int?> scheduledAt,
      Value<String> status,
      Value<int?> subId,
      Value<int?> paceSeconds,
      Value<int?> windowStartMin,
      Value<int?> windowEndMin,
      Value<int?> createdAt,
      Value<int> rowid,
    });

class $$CampaignsTableFilterComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyTemplate => $composableBuilder(
    column: $table.bodyTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subId => $composableBuilder(
    column: $table.subId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paceSeconds => $composableBuilder(
    column: $table.paceSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windowStartMin => $composableBuilder(
    column: $table.windowStartMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windowEndMin => $composableBuilder(
    column: $table.windowEndMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyTemplate => $composableBuilder(
    column: $table.bodyTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subId => $composableBuilder(
    column: $table.subId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paceSeconds => $composableBuilder(
    column: $table.paceSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windowStartMin => $composableBuilder(
    column: $table.windowStartMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windowEndMin => $composableBuilder(
    column: $table.windowEndMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bodyTemplate => $composableBuilder(
    column: $table.bodyTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get subId =>
      $composableBuilder(column: $table.subId, builder: (column) => column);

  GeneratedColumn<int> get paceSeconds => $composableBuilder(
    column: $table.paceSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get windowStartMin => $composableBuilder(
    column: $table.windowStartMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get windowEndMin => $composableBuilder(
    column: $table.windowEndMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CampaignsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampaignsTable,
          Campaign,
          $$CampaignsTableFilterComposer,
          $$CampaignsTableOrderingComposer,
          $$CampaignsTableAnnotationComposer,
          $$CampaignsTableCreateCompanionBuilder,
          $$CampaignsTableUpdateCompanionBuilder,
          (Campaign, BaseReferences<_$AppDatabase, $CampaignsTable, Campaign>),
          Campaign,
          PrefetchHooks Function()
        > {
  $$CampaignsTableTableManager(_$AppDatabase db, $CampaignsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> bodyTemplate = const Value.absent(),
                Value<int?> scheduledAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> subId = const Value.absent(),
                Value<int?> paceSeconds = const Value.absent(),
                Value<int?> windowStartMin = const Value.absent(),
                Value<int?> windowEndMin = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion(
                id: id,
                name: name,
                bodyTemplate: bodyTemplate,
                scheduledAt: scheduledAt,
                status: status,
                subId: subId,
                paceSeconds: paceSeconds,
                windowStartMin: windowStartMin,
                windowEndMin: windowEndMin,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String bodyTemplate,
                Value<int?> scheduledAt = const Value.absent(),
                required String status,
                Value<int?> subId = const Value.absent(),
                Value<int?> paceSeconds = const Value.absent(),
                Value<int?> windowStartMin = const Value.absent(),
                Value<int?> windowEndMin = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion.insert(
                id: id,
                name: name,
                bodyTemplate: bodyTemplate,
                scheduledAt: scheduledAt,
                status: status,
                subId: subId,
                paceSeconds: paceSeconds,
                windowStartMin: windowStartMin,
                windowEndMin: windowEndMin,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CampaignsTable, Campaign>(table),
                  BaseReferences<_$AppDatabase, $CampaignsTable, Campaign>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampaignsTable,
      Campaign,
      $$CampaignsTableFilterComposer,
      $$CampaignsTableOrderingComposer,
      $$CampaignsTableAnnotationComposer,
      $$CampaignsTableCreateCompanionBuilder,
      $$CampaignsTableUpdateCompanionBuilder,
      (Campaign, BaseReferences<_$AppDatabase, $CampaignsTable, Campaign>),
      Campaign,
      PrefetchHooks Function()
    >;
typedef $$OutboxMessagesTableCreateCompanionBuilder =
    OutboxMessagesCompanion Function({
      required String clientId,
      Value<int?> contactId,
      Value<String?> campaignId,
      required String address,
      required String body,
      required int dueAt,
      Value<int?> subId,
      required String status,
      Value<int?> errorCode,
      Value<String?> errorLabel,
      Value<int?> parts,
      Value<int> attempt,
      Value<int?> sentAt,
      Value<int?> deliveredAt,
      Value<String?> providerSmsId,
      Value<String?> mergeSummary,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int> rowid,
    });
typedef $$OutboxMessagesTableUpdateCompanionBuilder =
    OutboxMessagesCompanion Function({
      Value<String> clientId,
      Value<int?> contactId,
      Value<String?> campaignId,
      Value<String> address,
      Value<String> body,
      Value<int> dueAt,
      Value<int?> subId,
      Value<String> status,
      Value<int?> errorCode,
      Value<String?> errorLabel,
      Value<int?> parts,
      Value<int> attempt,
      Value<int?> sentAt,
      Value<int?> deliveredAt,
      Value<String?> providerSmsId,
      Value<String?> mergeSummary,
      Value<int?> createdAt,
      Value<int?> updatedAt,
      Value<int> rowid,
    });

final class $$OutboxMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $OutboxMessagesTable, OutboxMessage> {
  $$OutboxMessagesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContactsTable _contactIdTable(_$AppDatabase db) =>
      db.contacts.createAlias('outbox_messages__contact_id__contacts__id');

  $$ContactsTableProcessedTableManager? get contactId {
    final $_column = $_itemColumn<int>('contact_id');
    if ($_column == null) return null;
    final manager = $$ContactsTableTableManager(
      $_db,
      $_db.contacts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contactIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OutboxMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxMessagesTable> {
  $$OutboxMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get subId => $composableBuilder(
    column: $table.subId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorLabel => $composableBuilder(
    column: $table.errorLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parts => $composableBuilder(
    column: $table.parts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerSmsId => $composableBuilder(
    column: $table.providerSmsId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mergeSummary => $composableBuilder(
    column: $table.mergeSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ContactsTableFilterComposer get contactId {
    final $$ContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableFilterComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutboxMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxMessagesTable> {
  $$OutboxMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get subId => $composableBuilder(
    column: $table.subId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorLabel => $composableBuilder(
    column: $table.errorLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parts => $composableBuilder(
    column: $table.parts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerSmsId => $composableBuilder(
    column: $table.providerSmsId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mergeSummary => $composableBuilder(
    column: $table.mergeSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContactsTableOrderingComposer get contactId {
    final $$ContactsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableOrderingComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutboxMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxMessagesTable> {
  $$OutboxMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get subId =>
      $composableBuilder(column: $table.subId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<String> get errorLabel => $composableBuilder(
    column: $table.errorLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parts =>
      $composableBuilder(column: $table.parts, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<int> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<int> get deliveredAt => $composableBuilder(
    column: $table.deliveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get providerSmsId => $composableBuilder(
    column: $table.providerSmsId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mergeSummary => $composableBuilder(
    column: $table.mergeSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ContactsTableAnnotationComposer get contactId {
    final $$ContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contactId,
      referencedTable: $db.contacts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.contacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OutboxMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxMessagesTable,
          OutboxMessage,
          $$OutboxMessagesTableFilterComposer,
          $$OutboxMessagesTableOrderingComposer,
          $$OutboxMessagesTableAnnotationComposer,
          $$OutboxMessagesTableCreateCompanionBuilder,
          $$OutboxMessagesTableUpdateCompanionBuilder,
          (OutboxMessage, $$OutboxMessagesTableReferences),
          OutboxMessage,
          PrefetchHooks Function({bool contactId})
        > {
  $$OutboxMessagesTableTableManager(
    _$AppDatabase db,
    $OutboxMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<int?> contactId = const Value.absent(),
                Value<String?> campaignId = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> dueAt = const Value.absent(),
                Value<int?> subId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> errorCode = const Value.absent(),
                Value<String?> errorLabel = const Value.absent(),
                Value<int?> parts = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<int?> sentAt = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<String?> providerSmsId = const Value.absent(),
                Value<String?> mergeSummary = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxMessagesCompanion(
                clientId: clientId,
                contactId: contactId,
                campaignId: campaignId,
                address: address,
                body: body,
                dueAt: dueAt,
                subId: subId,
                status: status,
                errorCode: errorCode,
                errorLabel: errorLabel,
                parts: parts,
                attempt: attempt,
                sentAt: sentAt,
                deliveredAt: deliveredAt,
                providerSmsId: providerSmsId,
                mergeSummary: mergeSummary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                Value<int?> contactId = const Value.absent(),
                Value<String?> campaignId = const Value.absent(),
                required String address,
                required String body,
                required int dueAt,
                Value<int?> subId = const Value.absent(),
                required String status,
                Value<int?> errorCode = const Value.absent(),
                Value<String?> errorLabel = const Value.absent(),
                Value<int?> parts = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<int?> sentAt = const Value.absent(),
                Value<int?> deliveredAt = const Value.absent(),
                Value<String?> providerSmsId = const Value.absent(),
                Value<String?> mergeSummary = const Value.absent(),
                Value<int?> createdAt = const Value.absent(),
                Value<int?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxMessagesCompanion.insert(
                clientId: clientId,
                contactId: contactId,
                campaignId: campaignId,
                address: address,
                body: body,
                dueAt: dueAt,
                subId: subId,
                status: status,
                errorCode: errorCode,
                errorLabel: errorLabel,
                parts: parts,
                attempt: attempt,
                sentAt: sentAt,
                deliveredAt: deliveredAt,
                providerSmsId: providerSmsId,
                mergeSummary: mergeSummary,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxMessagesTable, OutboxMessage>(table),
                  $$OutboxMessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contactId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contactId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contactId,
                                referencedTable: $$OutboxMessagesTableReferences
                                    ._contactIdTable(db),
                                referencedColumn:
                                    $$OutboxMessagesTableReferences
                                        ._contactIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OutboxMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxMessagesTable,
      OutboxMessage,
      $$OutboxMessagesTableFilterComposer,
      $$OutboxMessagesTableOrderingComposer,
      $$OutboxMessagesTableAnnotationComposer,
      $$OutboxMessagesTableCreateCompanionBuilder,
      $$OutboxMessagesTableUpdateCompanionBuilder,
      (OutboxMessage, $$OutboxMessagesTableReferences),
      OutboxMessage,
      PrefetchHooks Function({bool contactId})
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder =
    SyncStatesCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SyncStatesTableUpdateCompanionBuilder =
    SyncStatesCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStatesTable, SyncState>(table),
                  BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$TimelineEntriesTableTableManager get timelineEntries =>
      $$TimelineEntriesTableTableManager(_db, _db.timelineEntries);
  $$ScheduledSmsEntriesTableTableManager get scheduledSmsEntries =>
      $$ScheduledSmsEntriesTableTableManager(_db, _db.scheduledSmsEntries);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$ContactListsTableTableManager get contactLists =>
      $$ContactListsTableTableManager(_db, _db.contactLists);
  $$ContactListMembersTableTableManager get contactListMembers =>
      $$ContactListMembersTableTableManager(_db, _db.contactListMembers);
  $$BulkSmsJobsTableTableManager get bulkSmsJobs =>
      $$BulkSmsJobsTableTableManager(_db, _db.bulkSmsJobs);
  $$ContactPhonesTableTableManager get contactPhones =>
      $$ContactPhonesTableTableManager(_db, _db.contactPhones);
  $$TimelineAttachmentsTableTableManager get timelineAttachments =>
      $$TimelineAttachmentsTableTableManager(_db, _db.timelineAttachments);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$OutboxMessagesTableTableManager get outboxMessages =>
      $$OutboxMessagesTableTableManager(_db, _db.outboxMessages);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
