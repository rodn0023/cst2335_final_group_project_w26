import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:cst2335_final_group_project_w26/AppLocalizations.dart';
import 'package:cst2335_final_group_project_w26/main.dart';

import 'Pet.dart';
import 'PetDAO.dart';
import 'PetDatabase.dart';

class PetPage extends StatefulWidget {
  const PetPage({super.key});

  @override
  State<PetPage> createState() => PetPageState();
}

class PetPageState extends State<PetPage> {

  List<Pet> petList = [];
  Pet? selectedItem;

  late PetDAO dao;
  late EncryptedSharedPreferences prefs;

  late TextEditingController nameController;
  late TextEditingController birthdayController;
  late TextEditingController speciesController;
  late TextEditingController colourController;
  late TextEditingController ownerIDController;

  Future<void> loadDatabase() async {
    final database = await $FloorPetDatabase
        .databaseBuilder('PetFile.db')
        .build();
    dao = database.petDAO;
    dao.getAllPets().then((list) {
      setState(() { petList = list; });
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

  void saveToPrefs() {
    prefs.setString('pet_name',     nameController.text);
    prefs.setString('pet_birthday', birthdayController.text);
    prefs.setString('pet_species',  speciesController.text);
    prefs.setString('pet_colour',   colourController.text);
    prefs.setString('pet_ownerID',  ownerIDController.text);
  }

  Future<void> loadFromPrefs() async {
    final n = await prefs.getString('pet_name');
    final b = await prefs.getString('pet_birthday');
    final s = await prefs.getString('pet_species');
    final c = await prefs.getString('pet_colour');
    final o = await prefs.getString('pet_ownerID');
    setState(() {
      nameController.text     = n;
      birthdayController.text = b;
      speciesController.text  = s;
      colourController.text   = c;
      ownerIDController.text  = o;
    });
  }

  void clearForm() {
    nameController.clear();
    birthdayController.clear();
    speciesController.clear();
    colourController.clear();
    ownerIDController.clear();
  }

  String translate(BuildContext context, String key) {
    return AppLocalizations.of(context)?.translate(key) ?? key;
  }

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

  Widget reactiveLayout() {
    var size   = MediaQuery.of(context).size;
    var height = size.height;
    var width  = size.width;

    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: 3, child: formAndDetails()),
          Expanded(flex: 2, child: listSection()),
        ],
      );
    } else {
      return Column(
        children: [
          formAndDetails(),
          Expanded(child: listSection()),
        ],
      );
    }
  }

  Widget formAndDetails() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(translate(context, 'pet_pleaseEnter')),
          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_nameHint'),
                  border: OutlineInputBorder(),
                ),
              )),
              const SizedBox(width: 6),
              Expanded(child: TextField(
                controller: birthdayController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_birthdayHint'),
                  border: OutlineInputBorder(),
                ),
              )),
              const SizedBox(width: 6),
              Expanded(child: TextField(
                controller: speciesController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_speciesHint'),
                  border: OutlineInputBorder(),
                ),
              )),
              const SizedBox(width: 6),
              Expanded(child: TextField(
                controller: colourController,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_colourHint'),
                  border: OutlineInputBorder(),
                ),
              )),
              const SizedBox(width: 6),
              Expanded(child: TextField(
                controller: ownerIDController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: translate(context, 'pet_ownerIDHint'),
                  border: OutlineInputBorder(),
                ),
              )),
              const SizedBox(width: 6),

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

              if (selectedItem != null)
                Row(
                  children: [
                    ElevatedButton(
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
                    const SizedBox(width: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: deleteAlert,
                      child: Text(
                        translate(context, 'pet_deleteButton'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          if (selectedItem != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${translate(context, 'pet_nameHint')}: ${selectedItem!.name}'),
                  Text('${translate(context, 'pet_birthday')}: ${selectedItem!.birthday}'),
                  Text('${translate(context, 'pet_species')}: ${selectedItem!.species}'),
                  Text('${translate(context, 'pet_colour')}: ${selectedItem!.colour}'),
                  Text('${translate(context, 'pet_ownerID')}: ${selectedItem!.ownerID}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedItem = null;
                        clearForm();
                      });
                    },
                    child: Text(translate(context, 'pet_closeButton')),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget listSection() {
    if (petList.isEmpty) {
      return Center(child: Text(translate(context, 'pet_emptyList')));
    }
    return ListView.builder(
      itemCount: petList.length,
      itemBuilder: (context, rowNum) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedItem = petList[rowNum];
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
            children: [
              Text('${rowNum + 1}. ${petList[rowNum].name}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${translate(context, 'pet_birthday')}: ${petList[rowNum].birthday}'),
              Text('${translate(context, 'pet_species')}: ${petList[rowNum].species}'),
              Text('${translate(context, 'pet_colour')}: ${petList[rowNum].colour}'),
              Text('${translate(context, 'pet_ownerID')}: ${petList[rowNum].ownerID}'),
              Text(''),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate(context, 'pet_pageTitle')),
        actions: [
          Padding(
            padding: EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () {
                MyApp.setLocale(context, Locale('en', 'CA'));
              },
              child: Text('English'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: () {
                MyApp.setLocale(context, Locale('gu', 'IN'));
              },
              child: Text('ગુજરાતી'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
            child: OutlinedButton(
              onPressed: helpAlert,
              child: Text(translate(context, 'pet_helpButton')),
            ),
          ),
        ],
      ),
      body: reactiveLayout(),
    );
  }
}