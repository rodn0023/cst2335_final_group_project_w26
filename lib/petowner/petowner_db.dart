import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'petowner_dao.dart';
import 'pet_owner.dart';

part 'petowner_db.g.dart'; // the generated code will be there



@Database(version: 1, entities: [PetOwner])
abstract class PetOwnerDatabase extends FloorDatabase {

  PetOwnerDAO get petOwnerDAO;
}