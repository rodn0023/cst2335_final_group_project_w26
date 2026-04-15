/*
 * AI Usage Disclaimer:
 *
 * Artificial Intelligence (AI) tools were used solely to assist in generating
 * and refining code comments and documentation within this file.
 *
 * All logic, implementation, and functionality were independently developed.
 * No AI assistance was used in writing the program logic, algorithms, or core features.
 */

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'Vaccine.dart';
import 'VaccineDao.dart';

/// Links this file to the generated Floor database implementation.
/// The generated code will be placed in 'database.g.dart'.
part 'database.g.dart';

/// Defines the main database configuration for the application.
///
/// - version: Specifies the database schema version.
/// - entities: Lists all tables (entities) included in the database.
@Database(version: 1, entities: [Vaccine])
abstract class AppDatabase extends FloorDatabase {

  /// Provides access to the VaccineDao, which contains
  /// all database operations related to the Vaccine entity
  /// (insert, delete, update, and query).
  VaccineDao get vaccineDao;
}