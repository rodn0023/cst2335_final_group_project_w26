import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../AppLocalizations.dart';
import '../main.dart';
import 'pet_owner.dart';
import 'petowner_dao.dart';
import 'petowner_db.dart';

///This is the main page for Pet Owners
class PetOwnerPage extends StatefulWidget {
  const PetOwnerPage({super.key});

  @override
  State<PetOwnerPage> createState() => _PetOwnerPageState();
}

class _PetOwnerPageState extends State<PetOwnerPage> {

  //List to store all pet owners from database
  List<PetOwner> owners = [];

  //This keeps track of which item is selected
  PetOwner? selectedItem;

  //Controllers = used to read text from input fields
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _dob = TextEditingController();
  TextEditingController _insurance = TextEditingController();

  // DAO = used to talk to database
  late var dao;

  // Shared preferences = used to save previous input
  late EncryptedSharedPreferences prefs;

  // Runs when page starts
  @override
  void initState() {
    super.initState();

    // initialize shared prefs
    prefs = EncryptedSharedPreferences();

    // load previously saved values into fields when page starts
    prefs.getString("po_firstName").then((savedValue) {
      if (savedValue.isNotEmpty) _firstName.text = savedValue;
    });
    prefs.getString("po_lastName").then((savedValue) {
      if (savedValue.isNotEmpty) _lastName.text = savedValue;
    });
    prefs.getString("po_address").then((savedValue) {
      if (savedValue.isNotEmpty) _address.text = savedValue;
    });
    prefs.getString("po_dob").then((savedValue) {
      if (savedValue.isNotEmpty) _dob.text = savedValue;
    });
    prefs.getString("po_insurance").then((savedValue) {
      if (savedValue.isNotEmpty) _insurance.text = savedValue;
    });

    // load data from database
    loadData();
  }

  //Loads all pet owners from database
  void loadData() async {

    //build database
    PetOwnerDatabase database = await $FloorPetOwnerDatabase
        .databaseBuilder('petowner_db.db')
        .build();

    //get DAO
    dao = database.petOwnerDAO;

    // get all records
    final list = await dao.findAllPetOwners();

    //update UI
    setState(() {
      owners = list;
    });
  }

  //Clean up memory when page is destroyed
  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    _dob.dispose();
    _insurance.dispose();
    super.dispose();
  }

  // Main UI
  @override
  Widget build(BuildContext context) {

    // get translations
    var lang = AppLocalizations.of(context)!;

    return Scaffold(

      // Top bar
      appBar: AppBar(
        title: Text(lang.translate('POPage')!),

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        actions: [

          // Switch to English
          TextButton(
            onPressed: () => MyApp.setLocale(context, const Locale("en")),
            child: Text(lang.translate('POEnglish')!),
          ),

          //Switch to Hindi
          TextButton(
            onPressed: () => MyApp.setLocale(context, const Locale("hi")),
            child: Text(lang.translate('POHindi')!),
          ),

          //Help button
          TextButton(
            onPressed: helpDialog,
            child: Text(lang.translate('POHelp')!),
          ),
        ],
      ),

      // Body layout
      body: reactiveLayout(),
    );
  }

  //reactive layout
  Widget reactiveLayout() {
    var size = MediaQuery.of(context).size;

    if ((size.width > size.height) && (size.width > 720)) {
      return Row(children: [
        Expanded(flex: 2, child: listPage()),
        Expanded(flex: 3, child: detailsPage()),
      ]);
    } else {
      return selectedItem == null ? listPage() : detailsPage();
    }
  }

  //details page
  Widget detailsPage() {
    var lang = AppLocalizations.of(context)!;

    if (selectedItem != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Show all fields
            Text("${lang.translate('PODetailsFirstName')} ${selectedItem!.firstName}"),
            Text("${lang.translate('PODetailsLastName')} ${selectedItem!.lastName}"),
            Text("${lang.translate('PODetailsAddress')} ${selectedItem!.address}"),
            Text("${lang.translate('PODetailsDOB')} ${selectedItem!.dateOfBirth}"),

            Text(
              "${lang.translate('PODetailsInsurance')} "
                  "${selectedItem!.insuranceNumber.isEmpty
                  ? lang.translate('PONoInsurance')
                  : selectedItem!.insuranceNumber}",
            ),

            Text("${lang.translate('PODetailsID')} ${selectedItem!.id}"),

            const SizedBox(height: 20),

            // Delete button
            ElevatedButton(
              onPressed: () async {
                await dao.deletePetOwner(selectedItem!);

                setState(() {
                  owners.remove(selectedItem);
                  selectedItem = null;
                });
              },
              child: Text(lang.translate('PODelete')!),
            ),

            // Close details view
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedItem = null;
                });
              },
              child: Text(lang.translate('POClose')!),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(lang.translate('POSelection')!),
      );
    }
  }

  //list pages
  Widget listPage() {
    var lang = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(12),

      child: Column(
        children: [

          const SizedBox(height: 20),

          // Input fields
          Column(
            children: [

              TextField(
                controller: _firstName,
                decoration: InputDecoration(
                  labelText: lang.translate('POFirstName'),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _lastName,
                decoration: InputDecoration(
                  labelText: lang.translate('POLastName'),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _address,
                decoration: InputDecoration(
                  labelText: lang.translate('POAddress'),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _dob,
                decoration: InputDecoration(
                  labelText: lang.translate('PODateOfBirth'),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _insurance,
                decoration: InputDecoration(
                  labelText: lang.translate('POInsurance'),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 10),

              //Add button
              ElevatedButton(
                child: Text(lang.translate('POAdd')!),
                onPressed: () async {

                  //Check if required fields are filled
                  if (_firstName.text.isNotEmpty &&
                      _lastName.text.isNotEmpty &&
                      _address.text.isNotEmpty &&
                      _dob.text.isNotEmpty) {

                    // Save input to shared prefs
                    await prefs.setString("po_firstName", _firstName.text);
                    await prefs.setString("po_lastName", _lastName.text);
                    await prefs.setString("po_address", _address.text);
                    await prefs.setString("po_dob", _dob.text);
                    await prefs.setString("po_insurance", _insurance.text);

                    //Create new object
                    final newOwner = PetOwner(
                      PetOwner.ID++,
                      _firstName.text,
                      _lastName.text,
                      _address.text,
                      _dob.text,
                      _insurance.text,
                    );

                    //insert into database
                    await dao.insertPetOwner(newOwner);

                    setState(() {
                      owners.add(newOwner);
                    });

                    // Show message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${_firstName.text} ${lang.translate('POAdded')}")),
                    );

                    // Show copy dialog
                    copyDialog();

                  } else {

                    // If fields empty
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(lang.translate('POFormFail')!)),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 15),

          // List of items
          Expanded(
            child: owners.isEmpty
                ? Text(lang.translate('PONoItems')!)
                : ListView.builder(
              itemCount: owners.length,
              itemBuilder: (context, rowNum) {

                return GestureDetector(

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        "${rowNum + 1}. ${owners[rowNum].firstName} ${owners[rowNum].lastName}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      Text("${lang.translate('PODetailsAddress')} ${owners[rowNum].address}"),
                      Text("${lang.translate('PODetailsDOB')} ${owners[rowNum].dateOfBirth}"),

                      Text(
                          "${lang.translate('PODetailsInsurance')} "
                              "${owners[rowNum].insuranceNumber.isEmpty
                              ? lang.translate('PONoInsurance')
                              : owners[rowNum].insuranceNumber}"
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),

                  //Tap = show details
                  onTap: () {
                    setState(() {
                      selectedItem = owners[rowNum];
                    });
                  },

                  // long press = delete
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(lang.translate('PODeleteTitle')!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(lang.translate('PONo')!),
                          ),
                          TextButton(
                            onPressed: () async {
                              await dao.deletePetOwner(owners[rowNum]);

                              setState(() {
                                owners.removeAt(rowNum);
                              });

                              Navigator.pop(context);
                            },
                            child: Text(lang.translate('POYes')!),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // copy fields dialog
  void copyDialog() {
    var lang = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang.translate('POAddAlertHead')!),
        content: Text(lang.translate('POAddAlertDesc')!),

        actions: [

          // no = clear fields
          TextButton(
            onPressed: () {
              _firstName.clear();
              _lastName.clear();
              _address.clear();
              _dob.clear();
              _insurance.clear();
              Navigator.pop(context);
            },
            child: Text(lang.translate('PONo')!),
          ),

          // yes = load previous fields
          TextButton(
            onPressed: () async {
              _firstName.text  = await prefs.getString("po_firstName");
              _lastName.text   = await prefs.getString("po_lastName");
              _address.text    = await prefs.getString("po_address");
              _dob.text        = await prefs.getString("po_dob");
              _insurance.text  = await prefs.getString("po_insurance");
              Navigator.pop(context);
            },
            child: Text(lang.translate('POYes')!),
          ),
        ],
      ),
    );
  }

  //help dialog
  void helpDialog() {
    var lang = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(lang.translate('POHelpAlertHead')!),
        content: Text(lang.translate('POHelpAlertDesc')!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.translate('POClose')!),
          ),
        ],
      ),
    );
  }
}