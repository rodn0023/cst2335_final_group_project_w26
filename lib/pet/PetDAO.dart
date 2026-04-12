import 'package:floor/floor.dart';
import 'Pet.dart';

/// Data Access Object for [Pet] database operations.
@dao
abstract class PetDAO {

  /// Returns all [Pet] records from the database.
  @Query('SELECT * FROM Pet')
  Future<List<Pet>> getAllPets();

  /// Inserts a [Pet] into the database.
  @insert
  Future<void> insertPet(Pet p);

  /// Deletes a [Pet] from the database.
  @delete
  Future<void> deletePet(Pet p);

  /// Updates an existing [Pet] in the database.
  @update
  Future<void> updatePet(Pet p);
}