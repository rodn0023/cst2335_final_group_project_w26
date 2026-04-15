import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'Vaccine.dart';
import 'VaccineDao.dart';
import 'database.dart';

/// Displays the vaccine management interface, including form entry,
/// vaccine listing, responsive detail views, and CRUD operations.
class VaccinePage extends StatefulWidget {
  @override
  State<VaccinePage> createState() => VaccinePageState();
}

/// Manages the state, database access, form controllers,
/// and responsive vaccine UI behavior.
class VaccinePageState extends State<VaccinePage> {
  /// Controller for the vaccine name field.
  late TextEditingController nameController;

  /// Controller for the dosage field.
  late TextEditingController dosageController;

  /// Controller for the lot number field.
  late TextEditingController lotNumberController;

  /// Controller for the expiry date field.
  late TextEditingController expiryDateController;

  /// In-memory list of vaccine records loaded from the database.
  List<Vaccine> vaccineList = [];

  /// Floor database instance used for vaccine persistence.
  late AppDatabase database;

  /// Data access object for vaccine operations.
  late VaccineDao dao;

  /// Currently selected vaccine item for detail display and editing.
  Vaccine? selectedItem = null;

  /// Secure storage for persisting last entered vaccine data.
  final EncryptedSharedPreferences prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    dosageController = TextEditingController();
    lotNumberController = TextEditingController();
    expiryDateController = TextEditingController();

    loadData();
    loadSavedData();
  }

  /// Loads all vaccine records from the database and refreshes the UI.
  void loadData() async {
    database = await $FloorAppDatabase.databaseBuilder('vaccine.db').build();
    dao = database.vaccineDao;

    final list = await dao.findAllVaccines();

    setState(() {
      vaccineList = list;
    });
  }

  /// Loads previously saved vaccine entry from encrypted storage
  /// and populates the form fields if data exists.
  void loadSavedData() async {
    String name = await prefs.getString("name");
    String dosage = await prefs.getString("dosage");
    String lot = await prefs.getString("lot");
    String expiry = await prefs.getString("expiry");

    if (name != "" && dosage != "" && lot != "" && expiry != "") {
      nameController.text = name;
      dosageController.text = dosage;
      lotNumberController.text = lot;
      expiryDateController.text = expiry;

      /// Displays feedback that stored data has been loaded.
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Previous vaccine entry loaded")),
        );
      });
    }
  }

  /// Prompts the user to save or discard the entered vaccine data
  /// for reuse in future sessions.
  void showSaveDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Save Entry"),
          content: Text("Reuse this vaccine entry next time?"),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.clear();
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                await prefs.setString("name", nameController.text);
                await prefs.setString("dosage", dosageController.text);
                await prefs.setString("lot", lotNumberController.text);
                await prefs.setString("expiry", expiryDateController.text);
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  /// Updates the selected vaccine entry in the database using
  /// the current values entered in the form fields.
  void updateVaccine() async {
    if (selectedItem != null &&
        nameController.text.isNotEmpty &&
        dosageController.text.isNotEmpty &&
        lotNumberController.text.isNotEmpty &&
        expiryDateController.text.isNotEmpty) {

      final updatedVaccine = Vaccine(
        selectedItem!.id,
        nameController.text,
        dosageController.text,
        lotNumberController.text,
        expiryDateController.text,
      );

      await dao.updateVaccine(updatedVaccine);
      await loadData();

      setState(() {
        selectedItem = null;
        nameController.clear();
        dosageController.clear();
        lotNumberController.clear();
        expiryDateController.clear();
      });

      /// Snackbar confirming update action.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vaccine updated successfully")),
      );
    }
  }

  /// Displays a help dialog explaining how to use the interface.
  void showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("How to Use"),
          content: Text(
            "1. Enter vaccine details\n"
                "2. Click Save Vaccine\n"
                "3. Tap item to edit\n"
                "4. Long press to delete\n",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    lotNumberController.dispose();
    expiryDateController.dispose();
    super.dispose();
  }

  /// Returns a responsive layout that shows a side-by-side interface
  /// on wider screens and a single-page flow on smaller screens.
  Widget reactiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: 2, child: ListPage()),
          Expanded(flex: 3, child: DetailsPage()),
        ],
      );
    } else {
      return selectedItem == null ? ListPage() : DetailsPage();
    }
  }

  /// Displays the detail view for the selected vaccine item,
  /// along with delete and close actions.
  Widget DetailsPage() {
    if (selectedItem != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Vaccine Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Name: ${selectedItem!.name}"),
              Text("Dosage: ${selectedItem!.dosage}"),
              Text("Lot: ${selectedItem!.lotNumber}"),
              Text("Expiry: ${selectedItem!.expiryDate}"),

              /// Deletes the selected vaccine from database and UI.
              ElevatedButton(
                onPressed: () async {
                  await dao.deleteVaccine(selectedItem!);

                  setState(() {
                    vaccineList.remove(selectedItem!);
                    selectedItem = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vaccine removed")),
                  );
                },
                child: Text("Delete"),
              ),

              /// Closes the detail view without deleting.
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedItem = null;
                  });
                },
                child: Text("Close"),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(child: Text("Select a vaccine"));
    }
  }

  /// Builds the main vaccine form and vaccine list interface.
  Widget ListPage() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [

          /// Input fields for vaccine details.
          TextField(controller: nameController, decoration: InputDecoration(hintText: "Name")),
          TextField(controller: dosageController, decoration: InputDecoration(hintText: "Dosage")),
          TextField(controller: lotNumberController, decoration: InputDecoration(hintText: "Lot")),
          TextField(controller: expiryDateController, decoration: InputDecoration(hintText: "Expiry")),

          /// Handles both add and update modes depending on selection state.
          Padding(
            padding: EdgeInsets.all(10),
            child: selectedItem == null
                ? ElevatedButton(
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

                  /// Prompt user to save entry for reuse.
                  showSaveDialog();

                  setState(() {
                    vaccineList.add(newVaccine);
                  });

                  nameController.clear();
                  dosageController.clear();
                  lotNumberController.clear();
                  expiryDateController.clear();

                  /// Snackbar confirming save action.
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Vaccine saved successfully")),
                  );
                }
              },
              child: Text("Save Vaccine"),
            )
                : ElevatedButton(
              onPressed: updateVaccine,
              child: Text("Update Vaccine"),
            ),
          ),

          /// Displays all saved vaccine records in a scrollable list.
          Expanded(
            child: ListView.builder(
              itemCount: vaccineList.length,
              itemBuilder: (context, index) {
                final item = vaccineList[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedItem = item;
                      nameController.text = item.name;
                      dosageController.text = item.dosage;
                      lotNumberController.text = item.lotNumber;
                      expiryDateController.text = item.expiryDate;
                    });
                  },
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text("Dosage: ${item.dosage}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the vaccine page scaffold and displays the responsive layout.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vaccine Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: showHelpDialog,
          ),
        ],
      ),
      body: reactiveLayout(),
    );
  }
}