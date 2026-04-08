import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'VeterinarianDAO.dart';
import 'Veterinarian.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [Veterinarian])
abstract class VetDatabase extends FloorDatabase {
  VeterinarianDAO get veterinarianDAO;
}