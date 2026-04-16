import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:cst2335_final_group_project_w26/AppLocalizations.dart';
import 'package:cst2335_final_group_project_w26/main.dart';

import 'Pet.dart';
import 'PetDAO.dart';
import 'PetDatabase.dart';

/// Pet management page — add, view, update, and delete pets.
class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => PetPageState();
}

/// State for [PetPage].
class PetPageState extends State<PetPage> {

  /// List of all pets loaded from the database.
  List<Pet> petList = [];

  /// Currently selected pet — null if nothing is selected.
  Pet? selectedItem;

  /// DAO used to run database operations on the Pet table.
  late PetDAO dao;

  /// Encrypted storage for saving form values between sessions.
  late EncryptedSharedPreferences prefs;

  /// Controller for the name field.
  late TextEditingController nameController;

  /// Controller for the birthday field.
  late TextEditingController birthdayController;

  /// Controller for the species field.
  late TextEditingController speciesController;

  /// Controller for the colour field.
  late TextEditingController colourController;

  /// Controller for the owner ID field.
  late TextEditingController ownerIDController;

  /// Opens the database and loads all pets into [petList].
  Future<void> loadDatabase() async {
    final database = await $FloorPetDatabase
        .databaseBuilder('PetFile.db')
        .build();
    dao = database.petDAO;
    dao.getAllPets().then((list) {
      setState(() { petList = list; });
    });
  }

  /// Sets up controllers, prefs, loads saved field values, and opens the database.
  @override
  void initState() {
    super.initState();

    nameController     = TextEditingController();
    birthdayController = TextEditingController();
    speciesController  = TextEditingController();
    colourController   = TextEditingController();
    ownerIDController  = TextEditingController();

    prefs = EncryptedSharedPreferences();

    // Pre-fill fields with values saved from the last session
    prefs.getString('pet_name').then((val) {
      if (val.isNotEmpty) nameController.text = val;
    });
    prefs.getString('pet_birthday').then((val) {
      if (val.isNotEmpty) birthdayController.text = val;
    });
    prefs.getString('pet_species').then((val) {
      if (val.isNotEmpty) speciesController.text = val;
    });
    prefs.getString('pet_colour').then((val) {
      if (val.isNotEmpty) colourController.text = val;
    });
    prefs.getString('pet_ownerID').then((val) {
      if (val.isNotEmpty) ownerIDController.text = val;
    });

    loadDatabase();
  }

  /// Disposes all controllers to free memory.
  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    speciesController.dispose();
    colourController.dispose();
    ownerIDController.dispose();
    super.dispose();
  }

  /// Saves all form field values to encrypted shared preferences.
  void saveToPrefs() {
    prefs.setString('pet_name',     nameController.text);
    prefs.setString('pet_birthday', birthdayController.text);
    prefs.setString('pet_species',  speciesController.text);
    prefs.setString('pet_colour',   colourController.text);
    prefs.setString('pet_ownerID',  ownerIDController.text);
  }

  /// Clears all form fields.
  void clearForm() {
    nameController.clear();
    birthdayController.clear();
    speciesController.clear();
    colourController.clear();
    ownerIDController.clear();
  }

  /// Returns the translated string for the given [key].
  String translate(BuildContext context, String key) {
    return AppLocalizations.of(context)?.translate(key) ?? key;
  }

  /// Asks the user if they want to copy the previous pet's saved data into the form.
  void copyAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate(context, 'pet_copyTitle')),
        content: Text(translate(context, 'pet_copyContent')),
        actions: [
          ElevatedButton(
            child: Text(translate(context, 'pet_yesButton')),
            onPressed: () {
              Navigator.of(context).pop();
              // Reload each saved field value using .then()
              prefs.getString('pet_name').then((val) {
                if (val.isNotEmpty) setState(() => nameController.text = val);
              });
              prefs.getString('pet_birthday').then((val) {
                if (val.isNotEmpty) setState(() => birthdayController.text = val);
              });
              prefs.getString('pet_species').then((val) {
                if (val.isNotEmpty) setState(() => speciesController.text = val);
              });
              prefs.getString('pet_colour').then((val) {
                if (val.isNotEmpty) setState(() => colourController.text = val);
              });
              prefs.getString('pet_ownerID').then((val) {
                if (val.isNotEmpty) setState(() => ownerIDController.text = val);
              });
            },
          ),
          ElevatedButton(
            child: Text(translate(context, 'pet_noButton')),
            onPressed: () {
              clearForm();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Asks the user to confirm before deleting the selected pet.
  void deleteAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate(context, 'pet_deleteTitle')),
        content: Text(translate(context, 'pet_deleteContent')),
        actions: [
          ElevatedButton(
            child: Text(translate(context, 'pet_yesButton')),
            onPressed: () async {
              await dao.deletePet(selectedItem!);
              setState(() {
                petList.remove(selectedItem);
                selectedItem = null;
                clearForm();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(translate(context, 'pet_snackDeleted'))),
              );
            },
          ),
          ElevatedButton(
            child: Text(translate(context, 'pet_cancelButton')),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Shows instructions on how to use this page.
  void helpAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate(context, 'pet_helpTitle')),
        content: Text(translate(context, 'pet_helpContent')),
        actions: [
          ElevatedButton(
            child: Text(translate(context, 'pet_closeButton')),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Returns a tablet or phone layout depending on screen size.
  Widget reactiveLayout() {
    var size   = MediaQuery.of(context).size;
    var height = size.height;
    var width  = size.width;

    if ((width > height) && (width > 720)) {
      // Tablet — list on the left, details on the right
      return Row(children: [
        Expanded(flex: 2, child: ListPage()),
        Expanded(flex: 3, child: DetailsPage()),
      ]);
    } else {
      // Phone — show list or details full screen
      if (selectedItem == null) {
        return ListPage();
      } else {
        return DetailsPage();
      }
    }
  }

  /// Shows the input form at the top and the scrollable pet list below.
  Widget ListPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Text(translate(context, 'pet_pleaseEnter')),
              const SizedBox(height: 6),

              // Name field
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_nameHint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),

              // Birthday field
              TextField(
                controller: birthdayController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_birthdayHint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),

              // Species field
              TextField(
                controller: speciesController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_speciesHint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),

              // Colour field
              TextField(
                controller: colourController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_colourHint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6),

              // Owner ID — stored as String in prefs, parsed to int when creating Pet
              TextField(
                controller: ownerIDController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_ownerIDHint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // Add button — only visible when no pet is selected
              if (selectedItem == null)
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        birthdayController.text.isEmpty ||
                        speciesController.text.isEmpty ||
                        colourController.text.isEmpty ||
                        ownerIDController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(translate(context, 'pet_fillFields'))),
                      );
                    } else {
                      saveToPrefs();
                      final newPet = Pet(
                        Pet.ID++,
                        nameController.text,
                        birthdayController.text,
                        speciesController.text,
                        colourController.text,
                        int.tryParse(ownerIDController.text) ?? 0,
                      );
                      await dao.insertPet(newPet);
                      setState(() { petList.add(newPet); });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                            '${newPet.name} ${translate(context, 'pet_snackAdded')}')),
                      );
                      copyAlert();
                    }
                  },
                  child: Text(translate(context, 'pet_addButton')),
                ),

              // Update and Delete — only visible when a pet is selected
              if (selectedItem != null)
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isEmpty ||
                            birthdayController.text.isEmpty ||
                            speciesController.text.isEmpty ||
                            colourController.text.isEmpty ||
                            ownerIDController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                translate(context, 'pet_fillFieldsUpdate'))),
                          );
                        } else {
                          selectedItem!.name     = nameController.text;
                          selectedItem!.birthday = birthdayController.text;
                          selectedItem!.species  = speciesController.text;
                          selectedItem!.colour   = colourController.text;
                          selectedItem!.ownerID  =
                              int.tryParse(ownerIDController.text) ?? 0;
                          await dao.updatePet(selectedItem!);
                          await loadDatabase();
                          setState(() {
                            selectedItem = null;
                            clearForm();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(
                                translate(context, 'pet_snackUpdated'))),
                          );
                        }
                      },
                      child: Text(translate(context, 'pet_updateButton')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: deleteAlert,
                      child: Text(
                        translate(context, 'pet_deleteButton'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ]),
            ],
          ),
        ),

        // Scrollable list — tap to select, long press to delete
        Expanded(
          child: ListView.builder(
            itemCount: petList.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItem            = petList[rowNum];
                    nameController.text     = selectedItem!.name;
                    birthdayController.text = selectedItem!.birthday;
                    speciesController.text  = selectedItem!.species;
                    colourController.text   = selectedItem!.colour;
                    ownerIDController.text  = selectedItem!.ownerID.toString();
                  });
                },
                onLongPress: () {
                  setState(() { selectedItem = petList[rowNum]; });
                  deleteAlert();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${rowNum + 1}. ${petList[rowNum].name}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text('${translate(context, 'pet_birthday')}: ${petList[rowNum].birthday}'),
                    Text('${translate(context, 'pet_species')}: ${petList[rowNum].species}'),
                    Text('${translate(context, 'pet_colour')}: ${petList[rowNum].colour}'),
                    Text('${translate(context, 'pet_ownerID')}: ${petList[rowNum].ownerID}'),
                    const Text(''),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Shows the selected pet's details with Update, Delete, and Close buttons.
  Widget DetailsPage() {
    if (selectedItem != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 40),

              Text(
                '${translate(context, 'pet_nameHint')}: ${selectedItem!.name}',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${translate(context, 'pet_birthday')}: ${selectedItem!.birthday}',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${translate(context, 'pet_species')}: ${selectedItem!.species}',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${translate(context, 'pet_colour')}: ${selectedItem!.colour}',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${translate(context, 'pet_ownerID')}: ${selectedItem!.ownerID}',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Update button
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        birthdayController.text.isEmpty ||
                        speciesController.text.isEmpty ||
                        colourController.text.isEmpty ||
                        ownerIDController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(translate(context, 'pet_fillFieldsUpdate'))),
                      );
                    } else {
                      selectedItem!.name     = nameController.text;
                      selectedItem!.birthday = birthdayController.text;
                      selectedItem!.species  = speciesController.text;
                      selectedItem!.colour   = colourController.text;
                      selectedItem!.ownerID  = int.tryParse(ownerIDController.text) ?? 0;
                      await dao.updatePet(selectedItem!);
                      await loadDatabase();
                      setState(() {
                        selectedItem = null;
                        clearForm();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(translate(context, 'pet_snackUpdated'))),
                      );
                    }
                  },
                  child: Text(translate(context, 'pet_updateButton')),
                ),
              ),

              const SizedBox(height: 12),

              // Delete button (red)
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: deleteAlert,
                  child: Text(
                    translate(context, 'pet_deleteButton'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Close button — sets selectedItem to null and goes back to the list
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedItem = null;
                      clearForm();
                    });
                  },
                  child: Text(translate(context, 'pet_closeButton')),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    } else {
      // Shown on tablet when nothing is selected yet
      return Center(
        child: Text(
          translate(context, 'pet_selectPrompt'),
          style: const TextStyle(fontSize: 24),
        ),
      );
    }
  }

  /// Builds the Scaffold with the AppBar, language buttons, and help icon.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'pet_pageTitle')),
        actions: [

          // Switch to English
          Padding(
            padding: const EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () =>
                  MyApp.setLocale(context, const Locale('en', 'CA')),
              child: const Text('English'),
            ),
          ),

          // Switch to Gujarati
          Padding(
            padding: const EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () =>
                  MyApp.setLocale(context, const Locale('gu', 'IN')),
              child: const Text('ગુજરાતી'),
            ),
          ),

          // Help button — shows usage instructions
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: translate(context, 'pet_helpButton'),
            onPressed: helpAlert,
          ),
        ],
      ),
      body: reactiveLayout(),
    );
  }
}