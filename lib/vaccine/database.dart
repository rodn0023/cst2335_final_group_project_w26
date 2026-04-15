import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'Vaccine.dart';
import 'VaccineDao.dart';

part 'database.g.dart';

@Database(version: 1, entities: [Vaccine])
abstract class AppDatabase extends FloorDatabase {
  VaccineDao get vaccineDao;
}
