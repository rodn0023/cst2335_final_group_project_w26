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

/// Represents a Vaccine entity stored in the local database.
///
/// This class defines the structure of the Vaccine table
/// used by the Floor ORM framework.
@Entity()
class Vaccine {

  /// Unique identifier for each vaccine record.
  /// This is the primary key in the database table.
  @primaryKey
  final int id;

  /// Name of the vaccine (e.g., Pfizer, Moderna).
  final String name;

  /// Dosage information for the vaccine.
  final String dosage;

  /// Lot number associated with the vaccine batch.
  final String lotNumber;

  /// Expiry date of the vaccine.
  final String expiryDate;

  /// Static counter used to generate unique IDs
  /// when creating new vaccine records.
  static int globalID = 1;

  /// Constructor used to initialize a Vaccine object.
  ///
  /// Ensures that the globalID is always updated
  /// to remain higher than any existing ID, preventing duplicates.
  Vaccine(this.id, this.name, this.dosage, this.lotNumber, this.expiryDate) {
    if (id >= globalID) {
      globalID = id + 1;
    }
  }
}