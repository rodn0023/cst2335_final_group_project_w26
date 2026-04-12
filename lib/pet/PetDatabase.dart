import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'PetDAO.dart';
import 'Pet.dart';

part 'PetDatabase.g.dart';

@Database(version: 1, entities: [Pet])
abstract class PetDatabase extends FloorDatabase {
  PetDAO get petDAO;
}