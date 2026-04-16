import 'package:floor/floor.dart';

/// Represents a pet that is a patient of a veterinary clinic.
@entity
class Pet {

  /// Counter used to assign a unique ID to each new pet.
  static int ID = 1;

  /// Creates a [Pet] and keeps [ID] ahead of the highest existing database ID.
  Pet(this.id, this.name, this.birthday, this.species, this.colour, this.ownerID) {
    if (id >= ID) {
      ID = id + 1;
    }
  }

  /// Primary key — unique identifier for each pet.
  @primaryKey
  final int id;

  /// The name of the pet.
  String name;

  /// The birthday of the pet (e.g. 2020-03-15).
  String birthday;

  /// The species of the pet (e.g. cat, dog, bird).
  String species;

  /// The colour of the pet.
  String colour;

  /// The ID of the owner of this pet.
  int ownerID;
}