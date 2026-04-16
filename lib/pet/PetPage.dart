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
///
/// Manages the pet list, form input controllers, database access,
/// and encrypted local storage for the Pet section of the app.
class PetPageState extends State<PetPage> {

  /// The list of pets loaded from the database.
  List<Pet> petList = [];

  /// The currently selected pet from the list (null if none selected).
  Pet? selectedItem;

  /// Data access object for performing database operations on the Pet table.
  late PetDAO dao;

  /// Encrypted shared preferences object used to save and retrieve pet form data.
  ///
  /// As shown in the lab slides, the [EncryptedSharedPreferences] class encrypts
  /// all stored strings, satisfying data protection requirements (GDPR, PIPEDA).
  /// Only String values are supported, as per the prof's lab notes.
  /// Created with: EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
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
  ///
  /// Also initialises [Pet.ID] from the highest existing id so inserts
  /// never conflict on app restart.
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

  /// Initialises all [TextEditingController]s, the [EncryptedSharedPreferences]
  /// instance, and loads any previously saved values into the form fields.
  ///
  /// Following the prof's lab pattern:
  /// - Controllers are initialised here (promise fulfilled after late declaration).
  /// - Saved prefs are read here so the fields are pre-filled on app restart.
  /// - The database is loaded so the list is populated on start.
  @override
  void initState() {
    super.initState();

    // Initialise all controllers — fulfilling the late promise
    nameController     = TextEditingController();
    birthdayController = TextEditingController();
    speciesController  = TextEditingController();
    colourController   = TextEditingController();
    ownerIDController  = TextEditingController();

    // Create the EncryptedSharedPreferences object (lab slide pattern)
    prefs = EncryptedSharedPreferences();

    // Load previously saved values on app restart, following the prof's pattern:
    // "This is where you should be reading the values that were saved to disk"
    prefs.getString('pet_name').then((savedName) {
      if (savedName.isNotEmpty) nameController.text = savedName;
    });
    prefs.getString('pet_birthday').then((savedBirthday) {
      if (savedBirthday.isNotEmpty) birthdayController.text = savedBirthday;
    });
    prefs.getString('pet_species').then((savedSpecies) {
      if (savedSpecies.isNotEmpty) speciesController.text = savedSpecies;
    });
    prefs.getString('pet_colour').then((savedColour) {
      if (savedColour.isNotEmpty) colourController.text = savedColour;
    });
    prefs.getString('pet_ownerID').then((savedOwnerID) {
      if (savedOwnerID.isNotEmpty) ownerIDController.text = savedOwnerID;
    });

    // Load the database and populate the pet list
    loadDatabase();
  }

  /// Frees all [TextEditingController] resources when the widget is removed.
  ///
  /// Following the prof's lab pattern: always dispose controllers in dispose()
  /// to prevent memory leaks.
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
  ///
  /// Uses [EncryptedSharedPreferences.setString] as shown in the prof's lab:
  /// the first parameter is the key (variable name), the second is the value.
  /// Only String data is stored, as [EncryptedSharedPreferences] only supports Strings.
  void saveToPrefs() {
    prefs.setString('pet_name',     nameController.text);
    prefs.setString('pet_birthday', birthdayController.text);
    prefs.setString('pet_species',  speciesController.text);
    prefs.setString('pet_colour',   colourController.text);
    prefs.setString('pet_ownerID',  ownerIDController.text);
  }

  /// Loads previously saved pet form values from [EncryptedSharedPreferences]
  /// and populates the text fields.
  ///
  /// Uses [EncryptedSharedPreferences.getString] with the same keys used in [saveToPrefs].
  /// Checks [String.isNotEmpty] before assigning, since a missing key returns empty string.
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

  /// Shows an [AlertDialog] asking if the user wants to copy the previous pet's
  /// data from [EncryptedSharedPreferences] into the form fields.
  ///
  /// This follows the prof's lab requirement:
  /// "When a user adds a new pet, the user should have a choice to copy the
  /// fields from the previous pet or start with a blank page."
  ///
  /// - Pressing "Yes" calls [loadFromPrefs] to refill the fields.
  /// - Pressing "No" calls [clearForm] to start blank.
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
              // Load saved prefs back into the form fields
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
  ///
  /// - Pressing "Yes" deletes the pet from the database and removes it from [petList].
  /// - Pressing "Cancel" closes the dialog with no changes.
  /// - A [SnackBar] is shown after successful deletion.
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
  ///
  /// This satisfies Requirement 7: each activity must have an ActionBar
  /// with ActionItems that display an AlertDialog with usage instructions.
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
  ///   [ListPage] on the left (flex 2), [DetailsPage] on the right (flex 3).
  ///
  /// Narrow screen (phone / portrait):
  ///   Show [ListPage] when nothing is selected,
  ///   show [DetailsPage] full screen when an item is selected.
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
  ///
  /// Based directly on the prof's [ListPage] function pattern from the lab slides.
  /// Fields use [hintText] so the placeholder is visible before typing
  /// and disappears once the user starts typing.
  ///
  /// The Add button is shown when [selectedItem] is null.
  /// Update and Delete buttons are shown when a pet is selected.
  Widget ListPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        // Form section — vertical fields stacked with hintText
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

              // Owner ID field — stored as String in prefs, parsed to int for the Pet object
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
                    // Validate all fields have values before inserting
                    if (nameController.text.isEmpty ||
                        birthdayController.text.isEmpty ||
                        speciesController.text.isEmpty ||
                        colourController.text.isEmpty ||
                        ownerIDController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(translate(context, 'pet_fillFields'))),
                      );
                    } else {
                      // Save to EncryptedSharedPreferences before inserting
                      // (lab pattern: save when button is pressed)
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
                      // Ask if user wants to copy fields for next entry
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
                          // Update the selected pet's fields with the form values
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

        // Scrollable pet list — plain text rows, no cards or boxes.
        // Follows the prof's ListView.builder pattern from the lab slides.
        // onTap loads the item into the form; onLongPress triggers delete.
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
  ///
  /// Displays pet details as plain centered text, then three action buttons:
  /// - Update: saves the pre-filled form fields back to the database.
  /// - Delete: shows [deleteAlert] to confirm removal.
  /// - Close: deselects the item and returns to [ListPage].
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

              // Update button — saves form values to DB
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

              // Delete button (red) — triggers [deleteAlert]
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

              // Close button — deselects item and returns to [ListPage]
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
      // Shown on tablet when no pet is selected yet
      return Center(
        child: Text(
          translate(context, 'pet_selectPrompt'),
          style: const TextStyle(fontSize: 24),
        ),
      );
    }
  }

  /// Builds the main [Scaffold] with an [AppBar] containing:
  /// - Language switcher buttons (English / Gujarati).
  /// - A Help [IconButton] that shows [helpAlert] (Requirement 7).
  ///
  /// The body uses [reactiveLayout] to adapt to screen size.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'pet_pageTitle')),
        actions: [
          // English language button
          Padding(
            padding: const EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () =>
                  MyApp.setLocale(context, const Locale('en', 'CA')),
              child: const Text('English'),
            ),
          ),
          // Gujarati language button
          Padding(
            padding: const EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () =>
                  MyApp.setLocale(context, const Locale('gu', 'IN')),
              child: const Text('ગુજરાતી'),
            ),
          ),
          // Help ActionItem in the AppBar (Requirement 7)
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