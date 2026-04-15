/*
 * AI Usage Disclaimer:
 *
 * Artificial Intelligence (AI) tools were used solely to assist in generating
 * and refining code comments and documentation within this file.
 *
 * All logic, implementation, and functionality were independently developed.
 * No AI assistance was used in writing the program logic, algorithms, or core features.
 */

import 'package:floor/floor.dart';
import 'Vaccine.dart';

/// Data Access Object (DAO) for the Vaccine entity.
///
/// This interface defines all database operations related to
/// the Vaccine table. Floor automatically generates the
/// implementation based on these method annotations.
@dao
abstract class VaccineDao {

  /// Retrieves all vaccine records from the database.
  ///
  /// Returns a Future containing a list of all Vaccine objects.
  @Query('SELECT * FROM Vaccine')
  Future<List<Vaccine>> findAllVaccines();

  /// Inserts a new vaccine record into the database.
  ///
  /// Accepts a Vaccine object and stores it in the table.
  @insert
  Future<void> insertVaccine(Vaccine vaccine);

  /// Deletes a specific vaccine record from the database.
  ///
  /// The record to be deleted is identified by the Vaccine object provided.
  @delete
  Future<void> deleteVaccine(Vaccine vaccine);

  /// Updates an existing vaccine record in the database.
  ///
  /// The record is matched based on its primary key (id).
  @update
  Future<void> updateVaccine(Vaccine vaccine);
}