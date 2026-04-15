import 'package:flutter/material.dart';
import 'Vaccine.dart';

class VaccinePage extends StatefulWidget{
  @override
  State<VaccinePage> createState() => VaccinePageState();
}

class VaccinePageState extends State<VaccinePage>
{
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late TextEditingController lotNumberController;
  late TextEditingController expiryDateController;

  List<Vaccine> vaccineList = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    dosageController = TextEditingController();
    lotNumberController = TextEditingController();
    expiryDateController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dosageController.dispose();
    lotNumberController.dispose();
    expiryDateController.dispose();
  }

  Widget ListPage() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            "Vaccine Registration",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Enter vaccine details below and save them to the list.",
              style: TextStyle(fontSize: 16),
            ),
          ),

          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Vaccine Name",
              border: OutlineInputBorder(),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top:10),
            child: TextField(
              controller: dosageController,
              decoration: InputDecoration(
                hintText: "Dosage",
                border: OutlineInputBorder(),
              ),
           ),
          ),

          Padding(
            padding: EdgeInsets.only(top:10),
            child: TextField(
              controller: lotNumberController,
              decoration: InputDecoration(
                hintText: "Lot Number",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top:10),
            child: TextField(
              controller: expiryDateController,
              decoration: InputDecoration(
                hintText: "Expiry Date",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    dosageController.text.isNotEmpty &&
                    lotNumberController.text.isNotEmpty &&
                    expiryDateController.text.isNotEmpty) {
                  final newVaccine = Vaccine(
                    Vaccine.globalID++,
                    nameController.text,
                    dosageController.text,
                    lotNumberController.text,
                    expiryDateController.text,
                  );

                  setState(() {
                    vaccineList.add(newVaccine);
                  });

                  nameController.clear();
                  dosageController.clear();
                  lotNumberController.clear();
                  expiryDateController.clear();
                }
              },

              child: Text("Save Vaccine"),
            ),
          ),

          if (vaccineList.isEmpty)
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "No vaccines have been added to the list yet.",
                style: TextStyle(fontSize: 16),
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: vaccineList.length,
              itemBuilder: (context, rowNum) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.gray),
                    ),
                    child: Column(
                      crossAxisAlignment: crossAxisAlignment.start,
                      children: [
                        Text(
                          "${rowNum + 1}. ${vaccineList[rowNum].name}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Dosage: ${vaccineList[rowNum].dosage}"),
                        Text("Lot Number: ${vaccineList[rowNum].lotNumber}"),
                        Text("Expiry Date: ${vaccineList[rowNum].expiryDate}"),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //this returns how this looks on the page
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text("Vaccine Page")
        ),
        body: ListPage(),
    );
  }
}