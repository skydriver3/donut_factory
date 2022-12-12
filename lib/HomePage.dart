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

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _commandController = TextEditingController(text: "1");
  int _donutNumber = 1;
  late int _donutsLeft = 1;
  bool loading = false;
  bool smallLoading = false;
  Future<Map<String, int>> get getData async {
    return DataPipeline.getData();
  }

  double price = 1.5;
  String? chosenPickupPoint = Pickup.MartinV;
  List<int> openHours = [];

  void Update(Map<String, int> value) {
    _donutsLeft = value["numbers_left"]!;
    openHours.clear();
    openHours.add(value["start"]!);
    openHours.add(value["end"]!);
  }

  void StateUpdate(Map<String, int> json) {
//    setState(() => Update(json));
    setState(
      () {
        _donutsLeft = json["numbers_left"]!;
        openHours.clear();
        openHours.add(json["start"]!);
        openHours.add(json["end"]!);
      },
    );
  }

  void AsyncUpdate() async {
    var json = await DataPipeline.getData();
    print("$json");
  }

  _initLoad(bool value) {
    setState(() {
      loading = value;
    });
  }

  _smallLoad(bool value) {
    if (value)
      _loadingDialog();
    else
      _orderCallback();
    setState(() {
      smallLoading = value;
    });
  }

  Future load(Function(bool) loadCallback) async {
    loadCallback(true);
    StateUpdate(await DataPipeline.getData());
    loadCallback(false);
  }

  @override
  void initState() {
    super.initState();
    load(_initLoad);
  }

  _commandRow() => Row(children: [
        Expanded(child: Container()),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: IconButton(
                onPressed: () {
                  setState(() => _commandController.text =
                      "${_donutNumber > 1 ? --_donutNumber : 1}");
                },
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
                onPressed: () => setState(() {
                      _commandController.text =
                          "${_donutNumber < _donutsLeft ? ++_donutNumber : _donutsLeft}";
                    }),
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
                    setState(() => _donutsLeft = _donutsLeft);
                  },
                  child: Text("OK"))
            ])),
      );

  Widget Function(BuildContext) _exceptionDialogWrapper(bool isTimeOut) =>
      (BuildContext context) => AlertDialog(
          title: Text("OOPS"),
          content: isTimeOut
              ? Text(
                  "Nous ne sommes actuellement pas en service.\nRegardez les heures d'ouvertures pour voire quand vous pouvez commander.",
                  style: TextStyle(fontFamily: "Calibri"))
              : Text(
                  "Il semblerait que la quantité commandée excède notre stock restant pour ce service.",
                  style: TextStyle(fontFamily: "Calibri")));

  _loadingDialog() => AlertDialog(
        content: Container(child: _loadingWidget(isOrder: true)),
      );

  _orderCallback() {
    var now = DateTime.now();
    var time = now.hour + (now.minute / 60);

    if (!(time > openHours[0] && time < openHours[1])) {
      Navigator.pop(context);
      showDialog(context: context, builder: _exceptionDialogWrapper(true));
    } else if (_donutNumber > _donutsLeft) {
      Navigator.pop(context);
      showDialog(context: context, builder: _exceptionDialogWrapper(false));
    } else {
      OrderForm form = OrderForm(chosenPickupPoint!, _donutNumber.toString(),
          "false", DateTime.now().toString(), "Dimitri");
      DataPipeline stream = DataPipeline();
      stream.submitForm(form, (String response) {
        Navigator.pop(context);
        if (response == DataPipeline.STATUS_SUCCESS)
          showDialog(context: context, builder: _successDialog);
        else
          showDialog(context: context, builder: _errorDialog);
      });
    }
  }

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
                  onPressed: () async {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) => _loadingDialog());
                    await load(_smallLoad);
                  },
                  child: Text("CONFIRMER"))
            ])),
      );

  _orderButton() => GestureDetector(
      onTap: () => showDialog(context: context, builder: _confirmationDialog),
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

  _mainPage() => Container(
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
              constraints: BoxConstraints(minHeight: 40, maxHeight: 60),
//              alignment: Alignment.center,
              child: Center(
                  child: Text("COMBIEN DE DONUTS VOULEZ-VOUS ?",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2))),
          Container(
              child: Center(
                  child: Text(
            openHours[0] > (DateTime.now().hour + DateTime.now().minute / 60) ||
                    openHours[1] <
                        (DateTime.now().hour + DateTime.now().minute / 60)
                ? "HEURES D'OUVERTURE : ${openHours[0]}h - ${openHours[1]}h"
                : "! ${_donutsLeft} RESTANTS CE SERVICE (${openHours[0]}h-${openHours[1]}h) !",
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
      ));

  double _turns = 2 * pi;
  _loadingWidget({bool isOrder = false}) => TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: _turns),
      duration: Duration(seconds: 2),
      builder: ((context, value, child) {
        return Transform.rotate(
          angle: value,
          child: child,
        );
      }),
      child: Container(
          height: 80, width: 80, child: Image.asset("assets/loading_logo.png")),
      onEnd: () {
        setState(() {
          _turns += 2 * pi;
        });
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: loading
            ? Container(
                color: Colors.amber,
                child: Center(child: _loadingWidget()),
              )
            : _mainPage());
  }
}
