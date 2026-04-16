import 'package:floor/floor.dart';
import 'Pet.dart';

/// Data Access Object for [Pet] database operations.
@dao
abstract class PetDAO {

  /// Returns all pets from the database.
  @Query('SELECT * FROM Pet')
  Future<List<Pet>> getAllPets();

  /// Inserts a new pet into the database.
  @insert
  Future<void> insertPet(Pet p);

  /// Deletes a pet from the database.
  @delete
  Future<void> deletePet(Pet p);

  /// Updates an existing pet in the database.
  @update
  Future<void> updatePet(Pet p);
}