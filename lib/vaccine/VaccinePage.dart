/*
 * AI Usage Disclaimer:
 *
 * Artificial Intelligence (AI) tools were used solely to assist in generating
 * and refining code comments and documentation within this file.
 *
 * AI tools were used for the implementation details of using localization for
 * translation of text within pages. Pattern and implementation details were
 * followed as was setup by project member.
 *
 * All logic, implementation, and functionality were independently developed.
 * No AI assistance was used in writing the program logic, algorithms, or core features.
 */

import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../AppLocalizations.dart';
import '../main.dart';
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
    var t = AppLocalizations.of(context)!;

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
          SnackBar(content: Text(t.translate("vaccine_snackbar_loaded")!)),
        );
      });
    }
  }

  /// Prompts the user to save or discard the entered vaccine data
  /// for reuse in future sessions.
  void showSaveDialog() async {
    var t = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.translate("vaccine_save_dialog_title")!),
          content: Text(t.translate("vaccine_save_dialog_message")!),
          actions: [
            TextButton(
              onPressed: () async {
                await prefs.clear();
                Navigator.pop(context);
              },
              child: Text(t.translate("vaccine_no")!),
            ),
            ElevatedButton(
              onPressed: () async {
                await prefs.setString("name", nameController.text);
                await prefs.setString("dosage", dosageController.text);
                await prefs.setString("lot", lotNumberController.text);
                await prefs.setString("expiry", expiryDateController.text);
                Navigator.pop(context);
              },
              child: Text(t.translate("vaccine_yes")!),
            ),
          ],
        );
      },
    );
  }

  /// Updates the selected vaccine entry in the database using
  /// the current values entered in the form fields.
  void updateVaccine() async {
    var t = AppLocalizations.of(context)!;

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
      loadData();

      setState(() {
        selectedItem = null;
        nameController.clear();
        dosageController.clear();
        lotNumberController.clear();
        expiryDateController.clear();
      });

      /// Snackbar confirming update action.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate("vaccine_snackbar_updated")!)),
      );
    }
  }

  /// Displays a help dialog explaining how to use the interface.
  void showHelpDialog() {
    var t = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.translate("vaccine_help_title")!),
          content: Text(t.translate("vaccine_help_text")!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.translate("vaccine_close")!),
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

    if ((size.width > size.height) && (size.width > 720)) {
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
    var t = AppLocalizations.of(context)!;

    if (selectedItem != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t.translate("vaccine_details")!),
              Text("${t.translate("vaccine_name")}: ${selectedItem!.name}"),
              Text("${t.translate("vaccine_dosage")}: ${selectedItem!.dosage}"),
              Text("${t.translate("vaccine_lot")}: ${selectedItem!.lotNumber}"),
              Text("${t.translate("vaccine_expiry")}: ${selectedItem!.expiryDate}"),

              /// Deletes the selected vaccine from database and UI.
              ElevatedButton(
                onPressed: () async {
                  await dao.deleteVaccine(selectedItem!);

                  setState(() {
                    vaccineList.remove(selectedItem!);
                    selectedItem = null;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.translate("vaccine_snackbar_deleted")!)),
                  );
                },
                child: Text(t.translate("vaccine_delete_title")!),
              ),

              /// Closes the detail view without deleting.
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedItem = null;
                  });
                },
                child: Text(t.translate("vaccine_close")!),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(child: Text(t.translate("vaccine_select_prompt")!));
    }
  }

  /// Builds the main vaccine form and vaccine list interface.
  Widget ListPage() {
    var t = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [

          /// Input fields for vaccine details.
          TextField(controller: nameController, decoration: InputDecoration(hintText: t.translate("vaccine_name"))),
          TextField(controller: dosageController, decoration: InputDecoration(hintText: t.translate("vaccine_dosage"))),
          TextField(controller: lotNumberController, decoration: InputDecoration(hintText: t.translate("vaccine_lot"))),
          TextField(controller: expiryDateController, decoration: InputDecoration(hintText: t.translate("vaccine_expiry"))),

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
                    SnackBar(content: Text(t.translate("vaccine_snackbar_saved")!)),
                  );
                }
              },
              child: Text(t.translate("vaccine_save")!),
            )
                : ElevatedButton(
              onPressed: updateVaccine,
              child: Text(t.translate("vaccine_update")!),
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
                    subtitle: Text("${t.translate("vaccine_dosage")}: ${item.dosage}"),
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
    var t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.translate("vaccine_page")!),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              Locale currentLocale = Localization.localOf(context);

              if (currentLocale.languageCode == "en") {
                MyApp.setLocale(context, Locale("es", "ES"));
              } else {
                MyApp.setLocale(context, Locale("en", "CA"));
              }
            },
          ),
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