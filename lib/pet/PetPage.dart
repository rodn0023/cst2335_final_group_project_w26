import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'Pet.dart';
import 'PetDAO.dart';
import 'PetDatabase.dart';

/// The main landing page for the Pet section.
/// Shows a responsive master-detail layout with a list of pets
/// and a detail / add-edit panel.
class PetPage extends StatefulWidget {
  /// Creates the [PetPage].
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

/// State for [PetPage].
class _PetPageState extends State<PetPage> {

  /// All pets loaded from the database.
  List<Pet> petList = [];

  /// The currently selected pet, or null if nothing is selected.
  Pet? selectedPet;

  /// Whether we are in "add new pet" mode.
  bool isAdding = false;

  /// The Floor DAO for pet operations.
  late PetDAO petDAO;

  /// Controller for the pet name field.
  late TextEditingController _nameController;

  /// Controller for the birthday field.
  late TextEditingController _birthdayController;

  /// Controller for the species field.
  late TextEditingController _speciesController;

  /// Controller for the colour field.
  late TextEditingController _colourController;

  /// Controller for the owner ID field.
  late TextEditingController _ownerIDController;

  /// Encrypted shared preferences instance.
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _nameController     = TextEditingController();
    _birthdayController = TextEditingController();
    _speciesController  = TextEditingController();
    _colourController   = TextEditingController();
    _ownerIDController  = TextEditingController();

    // Open the Floor database and load all existing pets
    $FloorPetDatabase.databaseBuilder('PetFile.db').build().then((database) {
      petDAO = database.petDAO;
      petDAO.getAllPets().then((list) {
        setState(() {
          petList.addAll(list);
        });
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    _speciesController.dispose();
    _colourController.dispose();
    _ownerIDController.dispose();
    super.dispose();
  }

  // ── Shared Preferences helpers ─────────────────────────────────────────────

  /// Saves the current form values to [EncryptedSharedPreferences]
  /// so they can be restored the next time the user adds a pet.
  void _saveToPrefs() {
    _prefs.setString('pet_name',     _nameController.text);
    _prefs.setString('pet_birthday', _birthdayController.text);
    _prefs.setString('pet_species',  _speciesController.text);
    _prefs.setString('pet_colour',   _colourController.text);
    _prefs.setString('pet_ownerID',  _ownerIDController.text);
  }

  /// Loads the previously saved form values from [EncryptedSharedPreferences]
  /// into the text controllers.
  void _loadFromPrefs() {
    _prefs.getString('pet_name').then((v)     { setState(() { _nameController.text     = v; }); });
    _prefs.getString('pet_birthday').then((v) { setState(() { _birthdayController.text = v; }); });
    _prefs.getString('pet_species').then((v)  { setState(() { _speciesController.text  = v; }); });
    _prefs.getString('pet_colour').then((v)   { setState(() { _colourController.text   = v; }); });
    _prefs.getString('pet_ownerID').then((v)  { setState(() { _ownerIDController.text  = v; }); });
  }

  /// Clears all form text controllers.
  void _clearForm() {
    _nameController.clear();
    _birthdayController.clear();
    _speciesController.clear();
    _colourController.clear();
    _ownerIDController.clear();
  }

  // ── Business logic ─────────────────────────────────────────────────────────

  /// Validates all fields are filled, inserts a new [Pet] into the
  /// database and list, shows a [SnackBar], and saves to prefs.
  void _addPet() {
    if (_nameController.text.isEmpty     ||
        _birthdayController.text.isEmpty ||
        _speciesController.text.isEmpty  ||
        _colourController.text.isEmpty   ||
        _ownerIDController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields before adding a pet.')),
      );
      return;
    }

    final newPet = Pet(
      Pet.ID++,
      _nameController.text,
      _birthdayController.text,
      _speciesController.text,
      _colourController.text,
      int.tryParse(_ownerIDController.text) ?? 0,
    );

    petDAO.insertPet(newPet).then((_) {
      setState(() {
        petList.add(newPet);
        isAdding    = false;
        selectedPet = null;
      });
      _saveToPrefs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${newPet.name} has been added!')),
      );
      _clearForm();
    });
  }

  /// Updates the currently [selectedPet] in the database and list,
  /// then shows a [SnackBar].
  void _updatePet() {
    if (selectedPet == null) return;

    if (_nameController.text.isEmpty     ||
        _birthdayController.text.isEmpty ||
        _speciesController.text.isEmpty  ||
        _colourController.text.isEmpty   ||
        _ownerIDController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields before updating.')),
      );
      return;
    }

    selectedPet!.name     = _nameController.text;
    selectedPet!.birthday = _birthdayController.text;
    selectedPet!.species  = _speciesController.text;
    selectedPet!.colour   = _colourController.text;
    selectedPet!.ownerID  = int.tryParse(_ownerIDController.text) ?? 0;

    petDAO.updatePet(selectedPet!).then((_) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${selectedPet!.name} has been updated!')),
      );
    });
  }

  /// Shows an [AlertDialog] asking the user to confirm deletion,
  /// then deletes [selectedPet] from the database and list.
  void _confirmDelete() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete this pet?'),
        content: Text('Are you sure you want to delete ${selectedPet!.name}?'),
        actions: [
          FilledButton(
            child: const Text('Yes'),
            onPressed: () {
              petDAO.deletePet(selectedPet!).then((_) {
                setState(() {
                  petList.remove(selectedPet!);
                  selectedPet = null;
                  isAdding    = false;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pet has been deleted.')),
                );
              });
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Shows an [AlertDialog] with instructions for using the Pet page.
  void _showInstructions() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('How to use the Pet Page'),
        content: const Text(
          '1. Press "Add Pet" to create a new pet record.\n'
              '2. Fill in all fields: name, birthday, species, colour, and owner ID.\n'
              '3. Press "Submit" to save the pet to the database.\n'
              '4. Tap a pet in the list to view or edit its details.\n'
              '5. Use "Update" to save edits, or "Delete" to remove a pet.\n'
              '6. Long-press a pet in the list for a quick-delete option.\n'
              '7. When adding, you may load the previous pet\'s data using the copy option.',
        ),
        actions: [
          FilledButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Shows an [AlertDialog] asking whether to copy the previous pet's
  /// fields from [EncryptedSharedPreferences] or start with a blank form.
  void _startAddPet() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('New Pet'),
        content: const Text('Would you like to copy the fields from the previous pet?'),
        actions: [
          FilledButton(
            child: const Text('Copy previous'),
            onPressed: () {
              Navigator.pop(context);
              _loadFromPrefs();
              setState(() {
                isAdding    = true;
                selectedPet = null;
              });
            },
          ),
          FilledButton(
            child: const Text('Start blank'),
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
              setState(() {
                isAdding    = true;
                selectedPet = null;
              });
            },
          ),
        ],
      ),
    );
  }

  // ── Layout ─────────────────────────────────────────────────────────────────

  /// Chooses between tablet (Row) and phone (single page) layout
  /// based on screen dimensions, matching the professor's reactiveLayout style.
  Widget _reactiveLayout() {
    var size   = MediaQuery.of(context).size;
    var width  = size.width;
    var height = size.height;

    if ((width > height) && (width > 720)) {
      // Tablet landscape: list left, detail right
      return Row(children: [
        Expanded(flex: 2, child: _listPage()),
        Expanded(flex: 3, child: _detailPage()),
      ]);
    } else {
      // Phone portrait: show list OR detail
      if (selectedPet == null && !isAdding) {
        return _listPage();
      } else {
        return _detailPage();
      }
    }
  }

  // ── List page ──────────────────────────────────────────────────────────────

  /// Builds the list of all pets with an Add Pet button at the top.
  Widget _listPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: _startAddPet,
            child: const Text('Add Pet'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: petList.length,
            itemBuilder: (context, rowNum) {
              final pet = petList[rowNum];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPet              = pet;
                    isAdding                 = false;
                    _nameController.text     = pet.name;
                    _birthdayController.text = pet.birthday;
                    _speciesController.text  = pet.species;
                    _colourController.text   = pet.colour;
                    _ownerIDController.text  = pet.ownerID.toString();
                  });
                },
                onLongPress: () {
                  setState(() { selectedPet = pet; });
                  _confirmDelete();
                },
                child: ListTile(
                  title: Text(pet.name),
                  subtitle: Text('${pet.species} • Owner ID: ${pet.ownerID}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Detail page ────────────────────────────────────────────────────────────

  /// Builds the detail/form page for adding or editing a pet.
  /// Shows a placeholder message when nothing is selected.
  Widget _detailPage() {
    if (selectedPet == null && !isAdding) {
      return const Center(
        child: Text(
          'Please select a pet from the list\nor press "Add Pet".',
          style: TextStyle(fontSize: 24.0),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            isAdding ? 'Add New Pet' : 'Pet Details',
            style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _birthdayController,
            decoration: const InputDecoration(
              labelText: 'Birthday (YYYY-MM-DD)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _speciesController,
            decoration: const InputDecoration(
              labelText: 'Species (e.g. cat, dog, bird)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _colourController,
            decoration: const InputDecoration(
              labelText: 'Colour',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _ownerIDController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Owner ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons: Submit/Cancel when adding, Update/Delete/Close when viewing
          if (isAdding) ...[
            ElevatedButton(
              onPressed: _addPet,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  isAdding    = false;
                  selectedPet = null;
                });
                _clearForm();
              },
              child: const Text('Cancel'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: _updatePet,
              child: const Text('Update'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _confirmDelete,
              child: const Text('Delete'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  selectedPet = null;
                  isAdding    = false;
                });
                _clearForm();
              },
              child: const Text('Close'),
            ),
          ],
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Pet List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Instructions',
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: _reactiveLayout(),
    );
  }
}