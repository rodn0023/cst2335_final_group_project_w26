//Dirgh
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PetDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $PetDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $PetDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $PetDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<PetDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorPetDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $PetDatabaseBuilderContract databaseBuilder(String name) =>
      _$PetDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $PetDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$PetDatabaseBuilder(null);
}

class _$PetDatabaseBuilder implements $PetDatabaseBuilderContract {
  _$PetDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $PetDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $PetDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<PetDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$PetDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$PetDatabase extends PetDatabase {
  _$PetDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PetDAO? _petDAOInstance;

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
            'CREATE TABLE IF NOT EXISTS `Pet` (`id` INTEGER NOT NULL, `name` TEXT NOT NULL, `birthday` TEXT NOT NULL, `species` TEXT NOT NULL, `colour` TEXT NOT NULL, `ownerID` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PetDAO get petDAO {
    return _petDAOInstance ??= _$PetDAO(database, changeListener);
  }
}

class _$PetDAO extends PetDAO {
  _$PetDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _petInsertionAdapter = InsertionAdapter(
            database,
            'Pet',
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerID': item.ownerID
                }),
        _petUpdateAdapter = UpdateAdapter(
            database,
            'Pet',
            ['id'],
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerID': item.ownerID
                }),
        _petDeletionAdapter = DeletionAdapter(
            database,
            'Pet',
            ['id'],
            (Pet item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'birthday': item.birthday,
                  'species': item.species,
                  'colour': item.colour,
                  'ownerID': item.ownerID
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Pet> _petInsertionAdapter;

  final UpdateAdapter<Pet> _petUpdateAdapter;

  final DeletionAdapter<Pet> _petDeletionAdapter;

  @override
  Future<List<Pet>> getAllPets() async {
    return _queryAdapter.queryList('SELECT * FROM Pet',
        mapper: (Map<String, Object?> row) => Pet(
            row['id'] as int,
            row['name'] as String,
            row['birthday'] as String,
            row['species'] as String,
            row['colour'] as String,
            row['ownerID'] as int));
  }

  @override
  Future<void> insertPet(Pet p) async {
    await _petInsertionAdapter.insert(p, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePet(Pet p) async {
    await _petUpdateAdapter.update(p, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePet(Pet p) async {
    await _petDeletionAdapter.delete(p);
  }
}
