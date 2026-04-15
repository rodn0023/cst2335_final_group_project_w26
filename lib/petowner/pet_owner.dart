import 'package:floor/floor.dart';


@entity
class PetOwner {

  /// Primary key for the database record.
  @primaryKey
  final int id;

  /// Pet owner's first name.
  final String firstName;

  /// Pet owner's last name.
  final String lastName;

  /// Pet owner's home address.
  final String address;

  /// Pet owner's date of birth
  final String dateOfBirth;

  /// Optional pet insurance number. Empty string if none.
  final String insuranceNumber;

  /// Static counter used to assign unique IDs.
  /// Always stays ahead of the highest ID loaded from the database.
  static int ID = 1;


  PetOwner(this.id, this.firstName, this.lastName, this.address,
      this.dateOfBirth, this.insuranceNumber) {
    if (id >= ID) {
      ID = id + 1;
    }
  }
}