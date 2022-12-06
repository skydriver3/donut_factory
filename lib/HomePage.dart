import 'dart:math';
import 'dart:ui';

import 'package:donut_factory/DataPipeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Pickup {
  static const MartinV = "Martin V";
  static const Carnoy = "Carnoy";
  static const Campanile = "Campanile";
  static const ChapelleChamps = "Clos Chapelle aux Champs";
  static const AuditoiresCentraux = "Auditoires Centraux";
  static const Bibli = "Bibliothèques";
  static const Meme = "Batiment mémé";
  static const Vecquee = "Vécquée";
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _commandController = TextEditingController(text: "1");
  int _donutNumber = 1;
  int _donutsLeft = 20;
  double price = 1.5;
  String? chosenPickupPoint;

  _commandRow() => Row(children: [
        Expanded(child: Container()),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
                onPressed: () => setState(() => _commandController.text =
                    "${_donutNumber > 1 ? --_donutNumber : 1}"),
                icon: Icon(Icons.remove))),
        Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3.0)),
            width: 50,
            child: TextFormField(
              textAlign: TextAlign.center,
              onEditingComplete: () {
                setState(() => _donutNumber =
                    min(_donutsLeft, int.parse(_commandController.text)));
                _commandController.text = _donutNumber.toString();
              },
              controller: _commandController,
              keyboardType: TextInputType.number,
            )),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
                //Make sure to refresh the donuts left when doing this and when sending the order
                onPressed: () => setState(() => _commandController.text =
                    "${_donutNumber < _donutsLeft ? ++_donutNumber : _donutsLeft}"),
                icon: Icon(Icons.add))),
        Expanded(
          child: Container(),
        )
      ]);

  TextEditingController _adressController = TextEditingController();
  _adressForm() => TextFormField(
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10),
        controller: _adressController,
      );

  Widget _successDialog(BuildContext context) => AlertDialog(
        title: Text("COMMANDE ACCEPTÉE"),
        content: Container(
            height: 80,
            child: Column(children: [
              Expanded(
                  child: Text(
                      "Vous pouvez allez chercher vos délicieux donuts au pickup point.",
                      style: TextStyle(fontSize: 20, fontFamily: "Calibri"))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"))
            ])),
      );

  Widget _errorDialog(BuildContext context) => AlertDialog(
        title: Text("DÉSOLÉ..."),
        content: Container(
            height: 80,
            child: Column(children: [
              Expanded(
                  child: Text(
                      "Il semble que nous expérimentons quelques problèmes techniques, nous travaillons dessus pour que vous puissiez avoir vos donuts le plus vite possible !",
                      style: TextStyle(fontSize: 20, fontFamily: "Calibri"))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"))
            ])),
      );

  Widget _confirmationDialog(BuildContext context) => AlertDialog(
        title: Text("VOTRE COMMANDE : ", style: TextStyle(fontSize: 16)),
        content: Container(
            height: 80,
            child: Column(children: [
              Expanded(
                  child: Text(
                      "${_donutNumber} Donuts : ${(price * _donutNumber).toStringAsFixed(2)}€ (liquide)",
                      style: TextStyle(fontSize: 20, fontFamily: "Calibri"))),
              ElevatedButton(
                  onPressed: () {
                    OrderForm form = OrderForm(
                        chosenPickupPoint!,
                        _donutNumber.toString(),
                        "false",
                        DateTime.now().toString(),
                        "Dimitri");
                    DataPipeline stream = DataPipeline();
                    stream.submitForm(form, (String response) {
                      Navigator.pop(context);
                      if (response == DataPipeline.STATUS_SUCCESS)
                        showDialog(context: context, builder: _successDialog);
                      else
                        showDialog(context: context, builder: _errorDialog);
                    });
                  },
                  child: Text("CONFIRMER"))
            ])),
      );

  _orderButton() => TextButton(
      onPressed: () =>
          showDialog(context: context, builder: _confirmationDialog),
      child: Stack(
        children: [
          Center(
              child: Image.asset(
            "assets/donut_button.png",
            fit: BoxFit.fill,
            width: 200,
          )),
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Text("COMMANDER",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2),
                Text("(${(price * _donutNumber).toStringAsFixed(2)}€)",
                    style: TextStyle(
                        fontFamily: "Calibri",
                        fontSize: 10,
                        color: Colors.black))
              ])),
        ],
      ));

  _imageGrid() => GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      children: List<Widget>.generate(
          8,
          (index) => Container(
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/Donuts_${index + 1}.jpg"),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(20)),
              )));

  _gradient() => LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(Colors.amber[400]!.value), Colors.transparent]);

  _dropDownItem(String title) => Text(title, style: TextStyle(fontSize: 12));
  _dropDownList() => <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(
            value: Pickup.MartinV, child: _dropDownItem("Martin V")),
        DropdownMenuItem<String>(
            value: Pickup.Carnoy, child: _dropDownItem("Carnoy")),
        DropdownMenuItem<String>(
            value: Pickup.Campanile, child: _dropDownItem("Campanile")),
        DropdownMenuItem<String>(
            value: Pickup.ChapelleChamps,
            child: _dropDownItem("Clos chapelle aux champs")),
        DropdownMenuItem<String>(
            value: Pickup.AuditoiresCentraux,
            child: _dropDownItem("Auditoires centraux")),
        DropdownMenuItem<String>(
            value: Pickup.Bibli, child: _dropDownItem("Bibliothèque")),
        DropdownMenuItem<String>(
            value: Pickup.Meme, child: _dropDownItem("Batiment mémé")),
        DropdownMenuItem<String>(
            value: Pickup.Vecquee, child: _dropDownItem("Vecquée")),
      ];

  _dropDown() => Container(
      width: 300,
      decoration:
          BoxDecoration(border: Border.all(width: 3, color: Colors.black)),
      child: DropdownButton(
          alignment: Alignment.center,
          value: chosenPickupPoint,
          items: _dropDownList(),
          onChanged: (String? value) =>
              setState(() => chosenPickupPoint = value)));

  _notAvailable() => Center(child: Text("Prochain service dans "));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.amber[400],
            child: ListView(
              children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/BackGround.png"),
                            fit: BoxFit.fill)),
                    height: 200,
                    child: Image.asset("assets/Logo_black_circle.png",
                        fit: BoxFit.contain)),
                Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Text("COMBIEN DE DONUTS VOULEZ-VOUS ?",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText2)),
                Container(
                    child: Center(
                        child: Text(
                  "! ${_donutsLeft} RESTANTS CE SERVICE !",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ))),
                Container(height: 60, child: _commandRow()),
                Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: Text("CHOISISSEZ UN PICK-UP POINT ",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText2)),
                Container(
                  height: 60,
                  child: Center(child: _dropDown()),
                  padding: EdgeInsets.symmetric(horizontal: 5),
                ),
                Container(height: 100, child: _orderButton()),
                _imageGrid()
              ],
            )));
  }
}
