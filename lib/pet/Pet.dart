import 'package:floor/floor.dart';

/// Represents a pet that is a patient of a veterinary clinic.
/// This class is a Floor database entity.
@entity
class Pet {
  /// Static auto-incrementing ID, must always be greater than any ID in the database.
  static int ID = 1;

  /// Creates a [Pet] with the given [id], [name], [birthday], [species], [colour], and [ownerID].
  /// Automatically keeps [ID] ahead of the highest existing ID.
  Pet(this.id, this.name, this.birthday, this.species, this.colour, this.ownerID) {
    if (this.id >= ID) {
      ID = this.id + 1;
    }
  }

  /// Primary key, unique identifier for each pet.
  @primaryKey
  final int id;

  /// The name of the pet.
  String name;

  /// The birthday of the pet (stored as a String, e.g. "2020-03-15").
  String birthday;

  /// The species of the pet (e.g. cat, dog, bird).
  String species;

  /// The colour of the pet.
  String colour;

  /// The ID of the owner of this pet.
  int ownerID;
}