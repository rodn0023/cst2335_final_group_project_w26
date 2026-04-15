import 'package:floor/floor.dart';

@Entity()
class Vaccine {
  @primaryKey
  final int id;

  final String name;
  final String dosage;
  final String lotNumber;
  final String expiryDate;

  static int globalID = 1;

  Vaccine(this.id, this.name, this.dosage, this.lotNumber, this.expiryDate){
    if (id >= globalID) {
      globalID = id + 1;
    }
  }
}