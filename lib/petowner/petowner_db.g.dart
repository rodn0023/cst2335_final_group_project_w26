// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'petowner_db.dart';



abstract class $PetOwnerDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $PetOwnerDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $PetOwnerDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<PetOwnerDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorPetOwnerDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $PetOwnerDatabaseBuilderContract databaseBuilder(String name) =>
      _$PetOwnerDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $PetOwnerDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$PetOwnerDatabaseBuilder(null);
}

class _$PetOwnerDatabaseBuilder implements $PetOwnerDatabaseBuilderContract {
  _$PetOwnerDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $PetOwnerDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $PetOwnerDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<PetOwnerDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$PetOwnerDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$PetOwnerDatabase extends PetOwnerDatabase {
  _$PetOwnerDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PetOwnerDAO? _petOwnerDAOInstance;

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
            'CREATE TABLE IF NOT EXISTS `PetOwner` (`id` INTEGER NOT NULL, `firstName` TEXT NOT NULL, `lastName` TEXT NOT NULL, `address` TEXT NOT NULL, `dateOfBirth` TEXT NOT NULL, `insuranceNumber` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PetOwnerDAO get petOwnerDAO {
    return _petOwnerDAOInstance ??= _$PetOwnerDAO(database, changeListener);
  }
}

class _$PetOwnerDAO extends PetOwnerDAO {
  _$PetOwnerDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _petOwnerInsertionAdapter = InsertionAdapter(
            database,
            'PetOwner',
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'insuranceNumber': item.insuranceNumber
                }),
        _petOwnerUpdateAdapter = UpdateAdapter(
            database,
            'PetOwner',
            ['id'],
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'insuranceNumber': item.insuranceNumber
                }),
        _petOwnerDeletionAdapter = DeletionAdapter(
            database,
            'PetOwner',
            ['id'],
            (PetOwner item) => <String, Object?>{
                  'id': item.id,
                  'firstName': item.firstName,
                  'lastName': item.lastName,
                  'address': item.address,
                  'dateOfBirth': item.dateOfBirth,
                  'insuranceNumber': item.insuranceNumber
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<PetOwner> _petOwnerInsertionAdapter;

  final UpdateAdapter<PetOwner> _petOwnerUpdateAdapter;

  final DeletionAdapter<PetOwner> _petOwnerDeletionAdapter;

  @override
  Future<List<PetOwner>> findAllPetOwners() async {
    return _queryAdapter.queryList('SELECT * FROM PetOwner',
        mapper: (Map<String, Object?> row) => PetOwner(
            row['id'] as int,
            row['firstName'] as String,
            row['lastName'] as String,
            row['address'] as String,
            row['dateOfBirth'] as String,
            row['insuranceNumber'] as String));
  }

  @override
  Future<void> insertPetOwner(PetOwner petOwner) async {
    await _petOwnerInsertionAdapter.insert(petOwner, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePetOwner(PetOwner petOwner) async {
    await _petOwnerUpdateAdapter.update(petOwner, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePetOwner(PetOwner petOwner) async {
    await _petOwnerDeletionAdapter.delete(petOwner);
  }
}
