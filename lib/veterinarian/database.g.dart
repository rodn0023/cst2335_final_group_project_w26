// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $VetDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $VetDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $VetDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<VetDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorVetDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $VetDatabaseBuilderContract databaseBuilder(String name) =>
      _$VetDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $VetDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$VetDatabaseBuilder(null);
}

class _$VetDatabaseBuilder implements $VetDatabaseBuilderContract {
  _$VetDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $VetDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $VetDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<VetDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$VetDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$VetDatabase extends VetDatabase {
  _$VetDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  VeterinarianDAO? _veterinarianDAOInstance;

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
            'CREATE TABLE IF NOT EXISTS `Veterinarian` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `birthday` TEXT NOT NULL, `address` TEXT NOT NULL, `university` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  VeterinarianDAO get veterinarianDAO {
    return _veterinarianDAOInstance ??=
        _$VeterinarianDAO(database, changeListener);
  }
}

class _$VeterinarianDAO extends VeterinarianDAO {
  _$VeterinarianDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _veterinarianInsertionAdapter = InsertionAdapter(
            database,
            'Veterinarian',
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                }),
        _veterinarianUpdateAdapter = UpdateAdapter(
            database,
            'Veterinarian',
            ['id'],
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                }),
        _veterinarianDeletionAdapter = DeletionAdapter(
            database,
            'Veterinarian',
            ['id'],
            (Veterinarian item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'address': item.address,
                  'university': item.university
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Veterinarian> _veterinarianInsertionAdapter;

  final UpdateAdapter<Veterinarian> _veterinarianUpdateAdapter;

  final DeletionAdapter<Veterinarian> _veterinarianDeletionAdapter;

  @override
  Future<List<Veterinarian>> findAllVeterinarians() async {
    return _queryAdapter.queryList('SELECT * FROM Veterinarian',
        mapper: (Map<String, Object?> row) => Veterinarian(
            row['id'] as int,
            row['name'] as String,
            row['birthday'] as String,
            row['address'] as String,
            row['university'] as String));
  }

  @override
  Future<void> insertVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianInsertionAdapter.insert(
        veterinarian, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianUpdateAdapter.update(
        veterinarian, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteVeterinarian(Veterinarian veterinarian) async {
    await _veterinarianDeletionAdapter.delete(veterinarian);
  }
}
