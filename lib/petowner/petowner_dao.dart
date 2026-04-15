import 'package:floor/floor.dart';
import 'pet_owner.dart';

/// Data Access Object for [PetOwner] database operations.
/// Provides insert, query, update, and delete methods.
@dao
abstract class PetOwnerDAO {

  /// Returns all [PetOwner] records from the database.
  @Query('SELECT * FROM PetOwner')
  Future<List<PetOwner>> findAllPetOwners();

  /// Inserts a new [PetOwner] into the database.
  @insert
  Future<void> insertPetOwner(PetOwner petOwner);

  /// Updates an existing [PetOwner] record in the database.
  @update
  Future<void> updatePetOwner(PetOwner petOwner);

  /// Deletes a [PetOwner] record from the database.
  @delete
  Future<void> deletePetOwner(PetOwner petOwner);
}