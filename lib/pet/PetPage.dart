import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:cst2335_final_group_project_w26/AppLocalizations.dart';
import 'package:cst2335_final_group_project_w26/main.dart';

import 'Pet.dart';
import 'PetDAO.dart';
import 'PetDatabase.dart';

/// The Pet management page of the Veterinary application.
/// Allows users to add, view, update, and delete pets from the database.
class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => PetPageState();
}

/// State class for [PetPage].
class PetPageState extends State<PetPage> {

  /// The list of pets loaded from the database.
  List<Pet> petList = [];

  /// The currently selected pet from the list (null if none selected).
  Pet? selectedItem;

  /// Data access object for database operations.
  late PetDAO dao;

  /// Encrypted shared preferences for saving last-entered pet data.
  late EncryptedSharedPreferences prefs;

  /// Controller for the pet name input field.
  late TextEditingController nameController;

  /// Controller for the pet birthday input field.
  late TextEditingController birthdayController;

  /// Controller for the pet species input field.
  late TextEditingController speciesController;

  /// Controller for the pet colour input field.
  late TextEditingController colourController;

  /// Controller for the owner ID input field.
  late TextEditingController ownerIDController;

  /// Loads the Floor database and fetches all existing pets.
  /// Also initialises [Pet.ID] from the highest existing id so inserts never conflict on restart.
  Future<void> loadDatabase() async {
    final database = await $FloorPetDatabase
        .databaseBuilder('PetFile.db')
        .build();
    dao = database.petDAO;
    dao.getAllPets().then((list) {
      setState(() {
        petList = list;
        if (list.isNotEmpty) {
          Pet.ID = list.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    nameController     = TextEditingController();
    birthdayController = TextEditingController();
    speciesController  = TextEditingController();
    colourController   = TextEditingController();
    ownerIDController  = TextEditingController();
    prefs = EncryptedSharedPreferences();
    loadDatabase();
  }

  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    speciesController.dispose();
    colourController.dispose();
    ownerIDController.dispose();
    super.dispose();
  }

  /// Saves all current form field values to [EncryptedSharedPreferences].
  void saveToPrefs() {
    prefs.setString('pet_name',     nameController.text);
    prefs.setString('pet_birthday', birthdayController.text);
    prefs.setString('pet_species',  speciesController.text);
    prefs.setString('pet_colour',   colourController.text);
    prefs.setString('pet_ownerID',  ownerIDController.text);
  }

  /// Loads previously saved form values from [EncryptedSharedPreferences].
  Future<void> loadFromPrefs() async {
    final n = await prefs.getString('pet_name');
    final b = await prefs.getString('pet_birthday');
    final s = await prefs.getString('pet_species');
    final c = await prefs.getString('pet_colour');
    final o = await prefs.getString('pet_ownerID');
    setState(() {
      nameController.text     = n.isNotEmpty ? n : '';
      birthdayController.text = b.isNotEmpty ? b : '';
      speciesController.text  = s.isNotEmpty ? s : '';
      colourController.text   = c.isNotEmpty ? c : '';
      ownerIDController.text  = o.isNotEmpty ? o : '';
    });
  }

  /// Clears all form text fields.
  void clearForm() {
    nameController.clear();
    birthdayController.clear();
    speciesController.clear();
    colourController.clear();
    ownerIDController.clear();
  }

  /// Helper to translate a [key] using [AppLocalizations].
  String translate(BuildContext context, String key) {
    return AppLocalizations.of(context)?.translate(key) ?? key;
  }

  /// Shows an [AlertDialog] asking if the user wants to copy
  /// the previous pet's data from [EncryptedSharedPreferences].
  void copyAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(translate(context, 'pet_copyTitle')),
        content: Text(translate(context, 'pet_copyContent')),
        actions: [
          ElevatedButton(
            child: Text(translate(context, 'pet_yesButton')),
            onPressed: () async {
              Navigator.of(context).pop();
              await loadFromPrefs();
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

  /// Shows an [AlertDialog] asking the user to confirm deletion
  /// of the currently selected pet.
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

  /// Shows an [AlertDialog] with instructions on how to use the Pet page.
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

  /// Decides the layout based on screen size — following the prof's lab pattern.
  ///
  /// Wide screen (tablet/desktop, landscape > 720 px):
  ///   [ListPage] on the left (40%), [DetailsPage] on the right (60%).
  ///
  /// Narrow screen (phone / portrait):
  ///   Show [ListPage] when nothing is selected,
  ///   show [DetailsPage] when an item is selected (full screen).
  Widget reactiveLayout() {
    var size   = MediaQuery.of(context).size;
    var height = size.height;
    var width  = size.width;

    if ((width > height) && (width > 720)) {
      // Tablet — side by side, exactly like the prof's lab
      return Row(children: [
        Expanded(flex: 2, child: ListPage()),
        Expanded(flex: 3, child: DetailsPage()),
      ]);
    } else {
      // Phone — show list OR details full screen (prof's lab pattern)
      if (selectedItem == null) {
        return ListPage();
      } else {
        return DetailsPage();
      }
    }
  }

  /// The list page — form fields stacked vertically + scrollable pet list below.
  /// Based directly on the prof's [ListPage] function pattern from the lab slides.
  Widget ListPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        // Form section — vertical fields stacked, hintText shown before typing
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

              // Owner ID field
              TextField(
                controller: ownerIDController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_ownerIDHint'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // Add button — only shown when nothing is selected
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

              // Update + Delete buttons — only shown when a pet is selected
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
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
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

        // Scrollable pet list — plain text rows, no cards or boxes
        // Follows the prof's ListView.builder pattern from the lab slides
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
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
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

  /// The details page — shown on the right (tablet) or full screen (phone)
  /// when a pet is selected. Based on the prof's [DetailsPage] pattern.
  /// Shows pet details as plain centered text, then Update / Delete / Close buttons.
  Widget DetailsPage() {
    if (selectedItem != null) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 40),

              // Plain details text — centered, same style as prof's lab DetailsPage
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

              // Close button — goes back to list
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
      return Center(
        child: Text(
          translate(context, 'pet_selectPrompt'),
          style: const TextStyle(fontSize: 24),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'pet_pageTitle')),
        actions: [
          // Language switcher buttons
          Padding(
            padding: const EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () =>
                  MyApp.setLocale(context, const Locale('en', 'CA')),
              child: const Text('English'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () =>
                  MyApp.setLocale(context, const Locale('gu', 'IN')),
              child: const Text('ગુજરાતી'),
            ),
          ),
          // Help ActionItem (Req 7)
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: helpAlert,
          ),
        ],
      ),
      body: reactiveLayout(),
    );
  }
}