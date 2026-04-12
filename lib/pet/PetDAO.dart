import 'package:floor/floor.dart';
import 'Pet.dart';

@dao
abstract class PetDAO {

  @Query('SELECT * FROM Pet')
  Future<List<Pet>> getAllPets();

  @insert
  Future<void> insertPet(Pet p);

  @delete
  Future<void> deletePet(Pet p);

  @update
  Future<void> updatePet(Pet p);
}