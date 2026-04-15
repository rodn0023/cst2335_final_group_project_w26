import 'package:floor/floor.dart';
import 'Vaccine.dart';

@dao
abstract class VaccineDao {

  @Query('SELECT * FROM Vaccine')
  Future<List<Vaccine>> findAllVaccines();

  @insert
  Future<void> insertVaccine(Vaccine vaccine);

  @delete
  Future<void> deleteVaccine(Vaccine vaccine);

  @update
  Future<void> updateVaccine(Vaccine vaccine);
}