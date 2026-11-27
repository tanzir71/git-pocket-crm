import 'package:drift/drift.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import 'app_database.dart';

/// Shared SQL query interface matching the subset of `sqflite.DatabaseExecutor`
/// used by legacy screens and helpers, backed by Drift's single SQLite connection.
class LegacyExecutor {
  LegacyExecutor(this._db);

  final AppDatabase _db;

  List<Variable<Object>> _toVars(List<Object?>? args) {
    if (args == null || args.isEmpty) return const [];
    return args.map((a) => Variable<Object>(a)).toList(growable: false);
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final rows = await _db.customSelect(sql, variables: _toVars(arguments)).get();
    return rows.map((r) => Map<String, Object?>.from(r.data)).toList();
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final buf = StringBuffer('SELECT ');
    if (distinct == true) buf.write('DISTINCT ');
    buf.write(columns == null || columns.isEmpty ? '*' : columns.join(', '));
    buf.write(' FROM $table');
    if (where != null && where.isNotEmpty) buf.write(' WHERE $where');
    if (groupBy != null && groupBy.isNotEmpty) buf.write(' GROUP BY $groupBy');
    if (having != null && having.isNotEmpty) buf.write(' HAVING $having');
    if (orderBy != null && orderBy.isNotEmpty) buf.write(' ORDER BY $orderBy');
    if (limit != null) buf.write(' LIMIT $limit');
    if (offset != null) buf.write(' OFFSET $offset');

    return rawQuery(buf.toString(), whereArgs);
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final conflictSql = switch (conflictAlgorithm) {
      ConflictAlgorithm.replace => ' OR REPLACE',
      ConflictAlgorithm.ignore => ' OR IGNORE',
      ConflictAlgorithm.abort => ' OR ABORT',
      ConflictAlgorithm.fail => ' OR FAIL',
      ConflictAlgorithm.rollback => ' OR ROLLBACK',
      null => '',
    };

    if (values.isEmpty) {
      return _db.customInsert('INSERT$conflictSql INTO $table DEFAULT VALUES');
    }

    final cols = values.keys.toList(growable: false);
    final placeholders = List.filled(cols.length, '?').join(', ');
    final args = cols.map((k) => values[k]).toList(growable: false);
    final sql = 'INSERT$conflictSql INTO $table (${cols.join(', ')}) VALUES ($placeholders)';
    return _db.customInsert(sql, variables: _toVars(args));
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (values.isEmpty) return 0;

    final conflictSql = switch (conflictAlgorithm) {
      ConflictAlgorithm.replace => ' OR REPLACE',
      ConflictAlgorithm.ignore => ' OR IGNORE',
      ConflictAlgorithm.abort => ' OR ABORT',
      ConflictAlgorithm.fail => ' OR FAIL',
      ConflictAlgorithm.rollback => ' OR ROLLBACK',
      null => '',
    };

    final setParts = <String>[];
    final args = <Object?>[];
    values.forEach((key, value) {
      setParts.add('$key = ?');
      args.add(value);
    });

    final buf = StringBuffer('UPDATE$conflictSql $table SET ${setParts.join(', ')}');
    if (where != null && where.isNotEmpty) {
      buf.write(' WHERE $where');
      if (whereArgs != null) args.addAll(whereArgs);
    }

    return _db.customUpdate(buf.toString(), variables: _toVars(args));
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final buf = StringBuffer('DELETE FROM $table');
    if (where != null && where.isNotEmpty) {
      buf.write(' WHERE $where');
    }
    return _db.customUpdate(buf.toString(), variables: _toVars(whereArgs));
  }

  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    await _db.customStatement(sql, arguments ?? const []);
  }
}

/// Legacy transaction wrapper used by `LegacyDb.transaction`.
class LegacyTransaction extends LegacyExecutor {
  LegacyTransaction(super.db);
}

/// Adapter exposing sqflite-like methods on top of the single Drift `AppDatabase`.
class LegacyDb extends LegacyExecutor {
  LegacyDb(super.db);

  AppDatabase get appDatabase => _db;

  Future<T> transaction<T>(
    Future<T> Function(LegacyTransaction txn) action, {
    bool? exclusive,
  }) {
    return _db.transaction(() => action(LegacyTransaction(_db)));
  }

  Future<void> close() => _db.close();
}

/// Drop-in replacement for `Sqflite.firstIntValue` that works on any raw query result.
int? firstIntValue(List<Map<String, Object?>> list) {
  if (list.isEmpty) return null;
  final firstRow = list.first;
  if (firstRow.isEmpty) return null;
  final firstVal = firstRow.values.first;
  if (firstVal is int) return firstVal;
  if (firstVal is num) return firstVal.toInt();
  if (firstVal is String) return int.tryParse(firstVal);
  return null;
}
