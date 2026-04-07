import 'package:flutter/material.dart';

class VaccinePage extends StatefulWidget{
  @override
  State<VaccinePage> createState() => VaccinePageState();
}

class VaccinePageState extends State<VaccinePage>
{
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  //this returns how this looks on the page
  @override
  Widget build(BuildContext context) {

    return Scaffold(appBar: AppBar(title: Text("Vaccine Page")),
        body:
        Center(child: Text('Vaccine Page')
        )
    );
  }

}