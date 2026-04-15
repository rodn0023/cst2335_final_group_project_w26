import 'package:flutter/material.dart';
import 'Vaccine.dart';
import 'VaccineDao.dart';
import 'database.dart';

class VaccinePage extends StatefulWidget {

  @override
  State<VaccinePage> createState() => VaccinePageState();
}

class VaccinePageState extends State<VaccinePage> {

  // Controllers
  late TextEditingController nameController;
  late TextEditingController dosageController;
  late TextEditingController lotNumberController;
  late TextEditingController expiryDateController;

  // Data
  List<Vaccine> vaccineList = [];

  // Database
  late AppDatabase database;
  late VaccineDao dao;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    dosageController = TextEditingController();
    lotNumberController = TextEditingController();
    expiryDateController = TextEditingController();

    loadData();
  }

  void loadData() async {
    database = await $FloorAppDatabase.databaseBuilder('vaccine.db').build();

    dao = database.vaccineDao;

    final list = await dao.findAllVaccines();

    setState(() {
      vaccineList = list;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    lotNumberController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  Widget ListPage() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [

          // Title
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

          // Input Fields
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Vaccine Name",
              border: OutlineInputBorder(),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextField(
              controller: dosageController,
              decoration: InputDecoration(
                hintText: "Dosage",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextField(
              controller: lotNumberController,
              decoration: InputDecoration(
                hintText: "Lot Number",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 10),
            child: TextField(
              controller: expiryDateController,
              decoration: InputDecoration(
                hintText: "Expiry Date",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Add Button
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () async {
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

                  await dao.insertVaccine(newVaccine);

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

          // Empty Message
          if (vaccineList.isEmpty)
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "No vaccines have been added to the list yet.",
                style: TextStyle(fontSize: 16),
              ),
            ),

          // List View
          Expanded(
            child: ListView.builder(
              itemCount: vaccineList.length,
              itemBuilder: (context, rowNum) {

                final item = vaccineList[rowNum];

                return GestureDetector(

                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Remove Vaccine?"),
                          content: Text("Are you sure you want to delete this vaccine registration?"),
                          actions: [

                            TextButton(
                              child: Text("Yes"),
                              onPressed: () async {

                                await dao.deleteVaccine(item);

                                setState(() {
                                  vaccineList.removeAt(rowNum);
                                });

                                Navigator.pop(context);
                              },
                            ),

                            TextButton(
                              child: Text("No"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },

                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "${rowNum + 1}. ${item.name}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text("Dosage: ${item.dosage}"),
                          Text("Lot Number: ${item.lotNumber}"),
                          Text("Expiry Date: ${item.expiryDate}"),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vaccine Page"),
      ),
      body: ListPage(),
    );
  }
}