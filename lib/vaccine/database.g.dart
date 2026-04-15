// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  VaccineDao? _vaccineDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Vaccine` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `dosage` TEXT NOT NULL, `lotNumber` TEXT NOT NULL, `expiryDate` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  VaccineDao get vaccineDao {
    return _vaccineDaoInstance ??= _$VaccineDao(database, changeListener);
  }
}

class _$VaccineDao extends VaccineDao {
  _$VaccineDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _vaccineInsertionAdapter = InsertionAdapter(
            database,
            'Vaccine',
            (Vaccine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'dosage': item.dosage,
                  'lotNumber': item.lotNumber,
                  'expiryDate': item.expiryDate
                }),
        _vaccineUpdateAdapter = UpdateAdapter(
            database,
            'Vaccine',
            ['id'],
            (Vaccine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'dosage': item.dosage,
                  'lotNumber': item.lotNumber,
                  'expiryDate': item.expiryDate
                }),
        _vaccineDeletionAdapter = DeletionAdapter(
            database,
            'Vaccine',
            ['id'],
            (Vaccine item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'dosage': item.dosage,
                  'lotNumber': item.lotNumber,
                  'expiryDate': item.expiryDate
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Vaccine> _vaccineInsertionAdapter;

  final UpdateAdapter<Vaccine> _vaccineUpdateAdapter;

  final DeletionAdapter<Vaccine> _vaccineDeletionAdapter;

  @override
  Future<List<Vaccine>> findAllVaccines() async {
    return _queryAdapter.queryList('SELECT * FROM Vaccine',
        mapper: (Map<String, Object?> row) => Vaccine(
            row['id'] as int,
            row['name'] as String,
            row['dosage'] as String,
            row['lotNumber'] as String,
            row['expiryDate'] as String));
  }

  @override
  Future<void> insertVaccine(Vaccine vaccine) async {
    await _vaccineInsertionAdapter.insert(vaccine, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVaccine(Vaccine vaccine) async {
    await _vaccineUpdateAdapter.update(vaccine, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVaccine(Vaccine vaccine) async {
    await _vaccineDeletionAdapter.delete(vaccine);
  }
}
