import 'package:floor/floor.dart';

import 'Veterinarian.dart';

@dao
abstract class VeterinarianDAO {
  @Query('SELECT * FROM Veterinarian')
  Future<List<Veterinarian>> findAllVeterinarians();

  @delete
  Future<void> deleteVeterinarian(Veterinarian veterinarian);

  @insert
  Future<void> insertVeterinarian(Veterinarian veterinarian);

  @update
  Future<void> updateVeterinarian(Veterinarian veterinarian);

}