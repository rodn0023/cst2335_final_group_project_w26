import 'package:flutter/material.dart';
import 'Veterinarian.dart';
import 'VeterinarianDAO.dart';
import 'database.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:cst2335_final_group_project_w26/main.dart';
import '../AppLocalizations.dart';

class VeterinarianPage extends StatefulWidget {
  const VeterinarianPage({super.key});

  @override
  State<VeterinarianPage> createState() => VeterinarianPageState();
}

class VeterinarianPageState extends State<VeterinarianPage> {

  /// Secure storage for saving user input between sessions.
  late EncryptedSharedPreferences prefs;

  /// Controller for the veterinarian name input field.
  late TextEditingController nameController;

  /// Controller for the veterinarian birthday input field.
  late TextEditingController birthdayController;

  /// Controller for the veterinarian address input field.
  late TextEditingController addressController;

  /// Controller for the veterinarian university input field.
  late TextEditingController universityController;

  /// Data access object for performing database operations for the Veterinarians table.
  late VeterinarianDAO dao;

  /// List of all veterinarians that are retrieved from the database.
  List<Veterinarian> veterinarianList = [];

  /// Currently selected veterinarian.
  Veterinarian? selectedItem;

  /// Loads the database and retrieves all veterinarians, updating the UI with the results.
  Future<void> loadDatabase() async {
    final database = await $FloorVetDatabase
        .databaseBuilder('vet_database.db')
        .build();

    dao = database.veterinarianDAO;

    dao.findAllVeterinarians().then((list) {
      setState(() {
        veterinarianList = list;
      });
    });
  }

  /// Initializes controllers, loads saved preferences, sets default locale, and loads database data.
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      MyApp.setLocale(context, Locale("en"));
    });

    loadDatabase();

    nameController = TextEditingController();
    birthdayController = TextEditingController();
    addressController = TextEditingController();
    universityController = TextEditingController();

    // requirement 6a: initializing EncryptedSharedPreferences for use
    prefs = EncryptedSharedPreferences();

    prefs.getString("vet_name").then((savedName) {
      nameController.text = savedName;
    });

    prefs.getString("birthday").then((savedBirthday) {
      birthdayController.text = savedBirthday;
    });

    prefs.getString("address").then((savedAddress) {
      addressController.text = savedAddress;
    });

    prefs.getString("university").then((savedUniversity) {
      universityController.text = savedUniversity;
    });
  }

  /// Cleans up controllers when the widget is removed to prevent memory leaks.
  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    birthdayController.dispose();
    addressController.dispose();
    universityController.dispose();
  }

  /// Displays a dialog asking the user if they want to reuse previously entered form values.
  void addAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('VetAddAlertHead')!),
        content: Text(
          AppLocalizations.of(context)!.translate('VetAddAlertDesc')!,
        ),
        actions: [
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('VetNo')!),
            onPressed: () {
              prefs.clear();
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('VetYes')!),
            onPressed: () async {
              final savedName = await prefs.getString("name");
              final savedBirthday = await prefs.getString("birthday");
              final savedAddress = await prefs.getString("address");
              final savedUniversity = await prefs.getString("university");

              setState(() {
                nameController.text = savedName;
                birthdayController.text = savedBirthday;
                addressController.text = savedAddress;
                universityController.text = savedUniversity;
              });

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Displays a help dialog explaining how to properly use the veterinarian form.
  void helpAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('VetHelpAlertHead')!),
        content: Text(
            AppLocalizations.of(context)!.translate('VetHelpAlertDesc')!,
        ),
        actions: [
          ElevatedButton(
            child: Text(AppLocalizations.of(context)!.translate('VetClose')!),
            onPressed: () async {
                Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Builds a responsive layout depending on screen size and orientation.
  Widget reactiveLayout() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    // requirement 4c: details beside list view on desktop
    if ((width > height) && (width > 720)) {
      return Row(
        children: [
          Expanded(flex: 3, child: ListPage()),
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xFF006341),
              child: DetailsPageDesktop(),
            ),
          ),
        ],
      );
    } else {
      // requirement 4d: full mobile screen for details or list view
      if (selectedItem == null) {
        return ListPage();
      } else {
        return Container(color: Color(0xFF006341), child: DetailsPageMobile());
      }
    }
  }

  /// Builds an "Add" button for creating a new veterinarian entry.
  ///
  /// Validates that all required input fields are filled before inserting
  /// the record into the database. If validation fails, a SnackBar is shown.
  ///
  /// When successful, the method:
  /// - Saves the entered values to EncryptedSharedPreferences
  /// - Inserts the new veterinarian into the database
  /// - Updates the UI list
  /// - Clears all input fields
  /// - Displays an alert
  Widget addButton() {
    return Padding(
      padding: EdgeInsets.all(10),

      // requirement 2b: add button which insert into database / list
      child: ElevatedButton(
        onPressed: () async {
          if (nameController.text.isEmpty ||
              birthdayController.text.isEmpty ||
              addressController.text.isEmpty ||
              universityController.text.isEmpty) {
            // requirement 5a: snackbar message for failed submission
            var snackBar = SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.translate('VetFormFail')!
              ),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(snackBar);
          } else {

            // requirement 6b: saving text field info for EncryptedSharedPreferences
            prefs.setString("vet_name", nameController.text);
            prefs.setString("birthday", birthdayController.text);
            prefs.setString("address", addressController.text);
            prefs.setString("university", universityController.text);


            final veterinarian = Veterinarian(
              Veterinarian.ID++,
              nameController.text,
              birthdayController.text,
              addressController.text,
              universityController.text,
            );

            // requirement 3: database usage for list
            await dao.insertVeterinarian(veterinarian);
            setState(() {
              veterinarianList.add(veterinarian);
              nameController.clear();
              birthdayController.clear();
              addressController.clear();
              universityController.clear();
            });

            // requirement 5b: AlertDialog popup for copying fields
            addAlert();
          }
        },
        child: Text(
          AppLocalizations.of(context)!.translate('VetAdd')!,
          style: TextStyle(color: Color(0xFF06402B)),
        ),
      ),
    );
  }

  /// Builds Update and Delete buttons for modifying or removing a selected Veterinarian.
  ///
  /// The update button creates an updated Veterinarian object using the values
  /// from the input controllers, then updates the record in the database and refreshes
  /// the displayed list. After updating, the selected item is cleared and the input
  /// fields are reset.
  ///
  /// The delete button removes the selected Veterinarian from the database and
  /// updates the UI list accordingly. It also clears all input fields and
  /// deselects the current selection.
  Widget updateAndDeleteButtons() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final updatedVet = Veterinarian(
                selectedItem!.id,
                nameController.text,
                birthdayController.text,
                addressController.text,
                universityController.text,
              );

              await dao.updateVeterinarian(updatedVet);
              await loadDatabase();

              setState(() {
                nameController.clear();
                birthdayController.clear();
                addressController.clear();
                universityController.clear();

                selectedItem = null;
              });
            },
            child: Text(
              AppLocalizations.of(context)!.translate('VetUpdate')!,
              style: TextStyle(color: Color(0xFF06402B)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                AppLocalizations.of(context)!.translate('VetDelete')!,
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                await dao.deleteVeterinarian(selectedItem!);
                setState(() {
                  veterinarianList.remove(selectedItem);
                  nameController.clear();
                  birthdayController.clear();
                  addressController.clear();
                  universityController.clear();
                  selectedItem = null;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main input form and veterinarian list view.
  ///
  /// Adapts layout based on screen size and orientation.
  Widget ListPage() {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Text(AppLocalizations.of(context)!.translate('VetFormMessage')!),
          if (width > height && width > 720) Row(
                  children: [
                    Expanded(
                      // requirement 2a: Text Fields for saving info before insert
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetName')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: birthdayController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetBirthday')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetAddress')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: universityController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.translate('VetUniversity')!,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    if (selectedItem == null)
                      addButton(),
                    if (selectedItem != null)
                      updateAndDeleteButtons()
                  ],
                ) else Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetName')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: birthdayController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetBirthday')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetAddress')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      controller: universityController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate('VetUniversity')!,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (selectedItem == null)
                      addButton(),
                    if (selectedItem != null)
                      updateAndDeleteButtons()
                  ],
                ),

          if (veterinarianList.isEmpty) Text(AppLocalizations.of(context)!.translate('VetNoItems')!),
          Expanded(
            // requirement 1: List View with inserted items
            child: ListView.builder(
              itemCount: veterinarianList.length,
              itemBuilder: (context, rowNum) {
                return GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${rowNum + 1}. ${veterinarianList[rowNum].name}",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate('VetDetailsBirthdate')!}${veterinarianList[rowNum].birthday}",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate('VetAddress')!}: ${veterinarianList[rowNum].address}",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(
                        "${AppLocalizations.of(context)!.translate('VetUniversity')!}: ${veterinarianList[rowNum].university}",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Text(""),
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      // requirement 4a: selecting item from list
                      selectedItem = veterinarianList[rowNum];

                      nameController.text = selectedItem!.name;
                      birthdayController.text = selectedItem!.birthday;
                      addressController.text = selectedItem!.address;
                      universityController.text = selectedItem!.university;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Displays selected veterinarian details with desktop layout.
  Widget DetailsPageDesktop() {
    if (selectedItem != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // requirement 4b: details from selected item
            children: [
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsName')!}${selectedItem!.name}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsBirthdate')!}${selectedItem!.birthday}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsAddress')!}${selectedItem!.address}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsUniversity')!}${selectedItem!.university}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
              Text(
                "${AppLocalizations.of(context)!.translate('VetDetailsID')!}${selectedItem!.id}",
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    nameController.clear();
                    birthdayController.clear();
                    addressController.clear();
                    universityController.clear();
                    selectedItem = null;
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.translate('VetClose')!,
                  style: TextStyle(color: Color(0xFF06402B)),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('VetSelection')!,
          style: TextStyle(
            fontSize: 21.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  /// Displays selected veterinarian details with mobile layout, which includes text fields.
  Widget DetailsPageMobile() {
    if (selectedItem != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsName')!}${selectedItem!.name}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsBirthdate')!}${selectedItem!.birthday}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsAddress')!}${selectedItem!.address}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsUniversity')!}${selectedItem!.university}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),
            Text(
              "${AppLocalizations.of(context)!.translate('VetDetailsID')!}${selectedItem!.id}",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
            ),

            Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.translate('VetName')!,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                TextField(
                  controller: birthdayController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.translate('VetBirthday')!,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.translate('VetAddress')!,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                TextField(
                  controller: universityController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.translate('VetUniversity')!,
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                updateAndDeleteButtons()
              ],
            ),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  nameController.clear();
                  birthdayController.clear();
                  addressController.clear();
                  universityController.clear();
                  selectedItem = null;
                });
              },
              child: Text(AppLocalizations.of(context)!.translate('VetClose')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('VetSelection')!,
          style: TextStyle(
            fontSize: 21.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  /// Builds the main UI scaffold including app bar and localized controls while using the reactive layout as the body.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('VetPage')!),
        actions: [
          Padding(
            padding: EdgeInsets.all(10),
            child: OutlinedButton(
              onPressed: () {
                MyApp.setLocale(context, Locale("en", "CA"));
              },
              child: Text(AppLocalizations.of(context)!.translate('VetEnglish')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: OutlinedButton(
              onPressed: () {
                // requirement 8: localization with english and french
                MyApp.setLocale(context, Locale("fr"));
              },
              child: Text(AppLocalizations.of(context)!.translate('VetFrench')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ),

          // requirement 7: action bar with help alert dialog
          Padding(
            padding: EdgeInsets.all(10),
            child: OutlinedButton(
              onPressed: () {
                helpAlert();
              },
              child: Text(AppLocalizations.of(context)!.translate('VetHelp')!, style: TextStyle(color: Color(0xFF06402B))),
            ),
          ),
        ],
      ),
      body: reactiveLayout(),
    );
  }
}