//
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'PetDAO.dart';
import 'Pet.dart';

part 'PetDatabase.g.dart';

/// Floor database for the Pet section. Version 1, entity is [Pet].
@Database(version: 1, entities: [Pet])
abstract class PetDatabase extends FloorDatabase {

  /// The DAO used to access pet data.
  PetDAO get petDAO;
}