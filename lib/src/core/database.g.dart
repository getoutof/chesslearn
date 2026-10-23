// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SavedGamesTable extends SavedGames
    with TableInfo<$SavedGamesTable, SavedGame> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedGamesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _pgnMeta = const VerificationMeta('pgn');
  @override
  late final GeneratedColumn<String> pgn = GeneratedColumn<String>(
    'pgn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Map<String, String>, String>
  headers = GeneratedColumn<String>(
    'headers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<Map<String, String>>($SavedGamesTable.$converterheaders);
  static const VerificationMeta _plyMeta = const VerificationMeta('ply');
  @override
  late final GeneratedColumn<int> ply = GeneratedColumn<int>(
    'ply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moveCountMeta = const VerificationMeta(
    'moveCount',
  );
  @override
  late final GeneratedColumn<int> moveCount = GeneratedColumn<int>(
    'move_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pgn,
    headers,
    ply,
    moveCount,
    result,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_games';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedGame> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pgn')) {
      context.handle(
        _pgnMeta,
        pgn.isAcceptableOrUnknown(data['pgn']!, _pgnMeta),
      );
    } else if (isInserting) {
      context.missing(_pgnMeta);
    }
    if (data.containsKey('ply')) {
      context.handle(
        _plyMeta,
        ply.isAcceptableOrUnknown(data['ply']!, _plyMeta),
      );
    } else if (isInserting) {
      context.missing(_plyMeta);
    }
    if (data.containsKey('move_count')) {
      context.handle(
        _moveCountMeta,
        moveCount.isAcceptableOrUnknown(data['move_count']!, _moveCountMeta),
      );
    } else if (isInserting) {
      context.missing(_moveCountMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedGame map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedGame(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pgn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pgn'],
      )!,
      headers: $SavedGamesTable.$converterheaders.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}headers'],
        )!,
      ),
      ply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ply'],
      )!,
      moveCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move_count'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavedGamesTable createAlias(String alias) {
    return $SavedGamesTable(attachedDatabase, alias);
  }

  static TypeConverter<Map<String, String>, String> $converterheaders =
      const _HeadersConverter();
}

class SavedGame extends DataClass implements Insertable<SavedGame> {
  final int id;
  final String pgn;

  /// Заголовки PGN (JSON): у импортированных партий — имена игроков,
  /// турнир и т.п. При пересохранении партии они не теряются.
  final Map<String, String> headers;

  /// На каком ходу стоит доска — чтобы продолжить с того же места.
  final int ply;
  final int moveCount;

  /// Результат как в PGN: `1-0`, `0-1`, `1/2-1/2` или `*` — не закончена.
  final String result;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavedGame({
    required this.id,
    required this.pgn,
    required this.headers,
    required this.ply,
    required this.moveCount,
    required this.result,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pgn'] = Variable<String>(pgn);
    {
      map['headers'] = Variable<String>(
        $SavedGamesTable.$converterheaders.toSql(headers),
      );
    }
    map['ply'] = Variable<int>(ply);
    map['move_count'] = Variable<int>(moveCount);
    map['result'] = Variable<String>(result);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavedGamesCompanion toCompanion(bool nullToAbsent) {
    return SavedGamesCompanion(
      id: Value(id),
      pgn: Value(pgn),
      headers: Value(headers),
      ply: Value(ply),
      moveCount: Value(moveCount),
      result: Value(result),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavedGame.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedGame(
      id: serializer.fromJson<int>(json['id']),
      pgn: serializer.fromJson<String>(json['pgn']),
      headers: serializer.fromJson<Map<String, String>>(json['headers']),
      ply: serializer.fromJson<int>(json['ply']),
      moveCount: serializer.fromJson<int>(json['moveCount']),
      result: serializer.fromJson<String>(json['result']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pgn': serializer.toJson<String>(pgn),
      'headers': serializer.toJson<Map<String, String>>(headers),
      'ply': serializer.toJson<int>(ply),
      'moveCount': serializer.toJson<int>(moveCount),
      'result': serializer.toJson<String>(result),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavedGame copyWith({
    int? id,
    String? pgn,
    Map<String, String>? headers,
    int? ply,
    int? moveCount,
    String? result,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SavedGame(
    id: id ?? this.id,
    pgn: pgn ?? this.pgn,
    headers: headers ?? this.headers,
    ply: ply ?? this.ply,
    moveCount: moveCount ?? this.moveCount,
    result: result ?? this.result,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SavedGame copyWithCompanion(SavedGamesCompanion data) {
    return SavedGame(
      id: data.id.present ? data.id.value : this.id,
      pgn: data.pgn.present ? data.pgn.value : this.pgn,
      headers: data.headers.present ? data.headers.value : this.headers,
      ply: data.ply.present ? data.ply.value : this.ply,
      moveCount: data.moveCount.present ? data.moveCount.value : this.moveCount,
      result: data.result.present ? data.result.value : this.result,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedGame(')
          ..write('id: $id, ')
          ..write('pgn: $pgn, ')
          ..write('headers: $headers, ')
          ..write('ply: $ply, ')
          ..write('moveCount: $moveCount, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pgn,
    headers,
    ply,
    moveCount,
    result,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedGame &&
          other.id == this.id &&
          other.pgn == this.pgn &&
          other.headers == this.headers &&
          other.ply == this.ply &&
          other.moveCount == this.moveCount &&
          other.result == this.result &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavedGamesCompanion extends UpdateCompanion<SavedGame> {
  final Value<int> id;
  final Value<String> pgn;
  final Value<Map<String, String>> headers;
  final Value<int> ply;
  final Value<int> moveCount;
  final Value<String> result;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SavedGamesCompanion({
    this.id = const Value.absent(),
    this.pgn = const Value.absent(),
    this.headers = const Value.absent(),
    this.ply = const Value.absent(),
    this.moveCount = const Value.absent(),
    this.result = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SavedGamesCompanion.insert({
    this.id = const Value.absent(),
    required String pgn,
    required Map<String, String> headers,
    required int ply,
    required int moveCount,
    required String result,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : pgn = Value(pgn),
       headers = Value(headers),
       ply = Value(ply),
       moveCount = Value(moveCount),
       result = Value(result),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavedGame> custom({
    Expression<int>? id,
    Expression<String>? pgn,
    Expression<String>? headers,
    Expression<int>? ply,
    Expression<int>? moveCount,
    Expression<String>? result,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pgn != null) 'pgn': pgn,
      if (headers != null) 'headers': headers,
      if (ply != null) 'ply': ply,
      if (moveCount != null) 'move_count': moveCount,
      if (result != null) 'result': result,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SavedGamesCompanion copyWith({
    Value<int>? id,
    Value<String>? pgn,
    Value<Map<String, String>>? headers,
    Value<int>? ply,
    Value<int>? moveCount,
    Value<String>? result,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SavedGamesCompanion(
      id: id ?? this.id,
      pgn: pgn ?? this.pgn,
      headers: headers ?? this.headers,
      ply: ply ?? this.ply,
      moveCount: moveCount ?? this.moveCount,
      result: result ?? this.result,
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
    if (pgn.present) {
      map['pgn'] = Variable<String>(pgn.value);
    }
    if (headers.present) {
      map['headers'] = Variable<String>(
        $SavedGamesTable.$converterheaders.toSql(headers.value),
      );
    }
    if (ply.present) {
      map['ply'] = Variable<int>(ply.value);
    }
    if (moveCount.present) {
      map['move_count'] = Variable<int>(moveCount.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedGamesCompanion(')
          ..write('id: $id, ')
          ..write('pgn: $pgn, ')
          ..write('headers: $headers, ')
          ..write('ply: $ply, ')
          ..write('moveCount: $moveCount, ')
          ..write('result: $result, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SavedGamesTable savedGames = $SavedGamesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [savedGames];
}

typedef $$SavedGamesTableCreateCompanionBuilder = SavedGamesCompanion Function({
  Value<int> id,
  required String pgn,
  required Map<String, String> headers,
  required int ply,
  required int moveCount,
  required String result,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$SavedGamesTableUpdateCompanionBuilder = SavedGamesCompanion Function({
  Value<int> id,
  Value<String> pgn,
  Value<Map<String, String>> headers,
  Value<int> ply,
  Value<int> moveCount,
  Value<String> result,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$SavedGamesTableFilterComposer
    extends Composer<_$AppDatabase, $SavedGamesTable> {
  $$SavedGamesTableFilterComposer({
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

  ColumnFilters<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    Map<String, String>,
    Map<String, String>,
    String
  >
  get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get moveCount => $composableBuilder(
    column: $table.moveCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedGamesTableOrderingComposer
    extends Composer<_$AppDatabase, $SavedGamesTable> {
  $$SavedGamesTableOrderingComposer({
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

  ColumnOrderings<String> get pgn => $composableBuilder(
    column: $table.pgn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headers => $composableBuilder(
    column: $table.headers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ply => $composableBuilder(
    column: $table.ply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get moveCount => $composableBuilder(
    column: $table.moveCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedGamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavedGamesTable> {
  $$SavedGamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pgn =>
      $composableBuilder(column: $table.pgn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Map<String, String>, String> get headers =>
      $composableBuilder(column: $table.headers, builder: (column) => column);

  GeneratedColumn<int> get ply =>
      $composableBuilder(column: $table.ply, builder: (column) => column);

  GeneratedColumn<int> get moveCount =>
      $composableBuilder(column: $table.moveCount, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SavedGamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavedGamesTable,
          SavedGame,
          $$SavedGamesTableFilterComposer,
          $$SavedGamesTableOrderingComposer,
          $$SavedGamesTableAnnotationComposer,
          $$SavedGamesTableCreateCompanionBuilder,
          $$SavedGamesTableUpdateCompanionBuilder,
          (
            SavedGame,
            BaseReferences<_$AppDatabase, $SavedGamesTable, SavedGame>,
          ),
          SavedGame,
          PrefetchHooks Function()
        > {
  $$SavedGamesTableTableManager(_$AppDatabase db, $SavedGamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedGamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedGamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedGamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pgn = const Value.absent(),
                Value<Map<String, String>> headers = const Value.absent(),
                Value<int> ply = const Value.absent(),
                Value<int> moveCount = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SavedGamesCompanion(
                id: id,
                pgn: pgn,
                headers: headers,
                ply: ply,
                moveCount: moveCount,
                result: result,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pgn,
                required Map<String, String> headers,
                required int ply,
                required int moveCount,
                required String result,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => SavedGamesCompanion.insert(
                id: id,
                pgn: pgn,
                headers: headers,
                ply: ply,
                moveCount: moveCount,
                result: result,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedGamesTable, SavedGame>(table),
                  BaseReferences<_$AppDatabase, $SavedGamesTable, SavedGame>(
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

typedef $$SavedGamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavedGamesTable,
      SavedGame,
      $$SavedGamesTableFilterComposer,
      $$SavedGamesTableOrderingComposer,
      $$SavedGamesTableAnnotationComposer,
      $$SavedGamesTableCreateCompanionBuilder,
      $$SavedGamesTableUpdateCompanionBuilder,
      (SavedGame, BaseReferences<_$AppDatabase, $SavedGamesTable, SavedGame>),
      SavedGame,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SavedGamesTableTableManager get savedGames =>
      $$SavedGamesTableTableManager(_db, _db.savedGames);
}
