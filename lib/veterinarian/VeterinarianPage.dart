import 'package:flutter/material.dart';

class VeterinarianPage extends StatefulWidget{
  @override
  State<VeterinarianPage> createState() => VeterinarianPageState();
}

class VeterinarianPageState extends State<VeterinarianPage>
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

    return Scaffold(appBar: AppBar(title: Text("Veterinarian Page")),
        body:
        Center(child: Text('Veterinarian Page')
        )
    );
  }

}