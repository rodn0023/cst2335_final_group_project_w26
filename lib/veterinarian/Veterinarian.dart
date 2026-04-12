import 'package:floor/floor.dart';

@entity
class Veterinarian {
  @primaryKey
  final int id;

  final String name;

  final String birthday;

  final String address;

  final String university;

  Veterinarian(this.id, this.name, this.birthday, this.address, this.university) {
    if(id >= ID) {
      ID = id + 1;
    }
  }

  static int ID = 1;

}