import 'package:flutter/material.dart';
import 'Pet.dart';

/// Pet page for Step 1.
/// This version uses a local list only, following the Week 6 ListView lab style.
class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> {
  /// Controller for the pet name input.
  late TextEditingController nameController;

  /// Controller for the birthday input.
  late TextEditingController birthdayController;

  /// Controller for the species input.
  late TextEditingController speciesController;

  /// Controller for the colour input.
  late TextEditingController colourController;

  /// Controller for the owner id input.
  late TextEditingController ownerIdController;

  /// Local list of pets for Step 1.
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    birthdayController = TextEditingController();
    speciesController = TextEditingController();
    colourController = TextEditingController();
    ownerIdController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    birthdayController.dispose();
    speciesController.dispose();
    colourController.dispose();
    ownerIdController.dispose();
    super.dispose();
  }

  /// Adds a pet to the local list if all fields are filled in.
  void addPet() {
    String name = nameController.text.trim();
    String birthday = birthdayController.text.trim();
    String species = speciesController.text.trim();
    String colour = colourController.text.trim();
    String ownerId = ownerIdController.text.trim();

    if (name.isEmpty ||
        birthday.isEmpty ||
        species.isEmpty ||
        colour.isEmpty ||
        ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all pet fields'),
        ),
      );
      return;
    }

    setState(() {
      pets.add(Pet(name, birthday, species, colour, ownerId));

      nameController.clear();
      birthdayController.clear();
      speciesController.clear();
      colourController.clear();
      ownerIdController.clear();
    });
  }

  /// Shows a delete confirmation dialog for the selected pet.
  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Pet'),
          content: const Text('Do you want to delete this pet?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  pets.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  /// Builds the pet list section using the Week 6 lab pattern.
  Widget ListPage() {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
          ),
        ),
        TextField(
          controller: birthdayController,
          decoration: const InputDecoration(
            labelText: 'Birthday',
          ),
        ),
        TextField(
          controller: speciesController,
          decoration: const InputDecoration(
            labelText: 'Species',
          ),
        ),
        TextField(
          controller: colourController,
          decoration: const InputDecoration(
            labelText: 'Colour',
          ),
        ),
        TextField(
          controller: ownerIdController,
          decoration: const InputDecoration(
            labelText: 'Owner ID',
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: addPet,
          child: const Text('Add'),
        ),
        const SizedBox(height: 10),
        pets.isEmpty
            ? const Text('There are no pets in the list')
            : Expanded(
          child: ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                onLongPress: () {
                  confirmDelete(rowNum);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${rowNum + 1}. ${pets[rowNum].name}'),
                    Text(pets[rowNum].species),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListPage(),
      ),
    );
  }
}