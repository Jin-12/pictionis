import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../main.dart';
import 'package:pictionis/src/drawn_line.dart';
import 'package:pictionis/src/sketcher.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  static String routeName = '/game';
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class ScreenArguments {
  final String id;

  ScreenArguments(this.id);
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey _globalKey = GlobalKey();
  DrawnLine? line;
  List<DrawnLine> lines = <DrawnLine>[];
  Color selectedColor = Colors.black;
  double selectedWidth = 5.0;

/*   StreamController<QuerySnapshot> linesStreamController =
      StreamController.broadcast(); */

  StreamController<List<DrawnLine>> linesStreamController =
      StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController =
      StreamController<DrawnLine>.broadcast();

  Future<void> clear() async {
    setState(() {
      lines = [];
      line = null;
    });
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments?;
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(args!.id)
        .update({"lines": FieldValue.delete()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: SlidingUpPanel(
        backdropEnabled: true,
        panel: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 10, top: 10),
                height: 60,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Write message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    FloatingActionButton(
                      heroTag: null,
                      onPressed: () {},
                      backgroundColor: Colors.blue,
                      elevation: 0,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        collapsed: Container(
          color: Colors.blueGrey,
          child: const Center(
            child: Text(
              "CHAT",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ),
        body: Stack(
          children: [
            buildAllPaths(context),
            buildCurrentPath(context),
            buildColorToolbar(),
            buildStrokeToolbar(),
          ],
        ),
      ),
    );
  }

  GestureDetector buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return new Text('NO DATA BRUDDA');
              snapshot.data!.docs.map((DocumentSnapshot document) {
                return CustomPaint(
                  painter: Sketcher(lines: document['lines']),
                );
              });
              return Container(
                child: Text('Error'),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAllPaths(BuildContext context) {
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<List<DrawnLine>>(
          stream: linesStreamController.stream,
          builder: (context, snapshot) {
            return CustomPaint(
              painter: Sketcher(
                lines: lines,
              ),
            );
          },
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    print('User started drawing');
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
    currentLineStreamController.add(line!);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    final path = List<Offset?>.from(line!.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    currentLineStreamController.add(line!);
  }

  Future<void> onPanEnd(DragEndDetails details) async {
    lines = List.from(lines)..add(line!);
    linesStreamController.add(lines);

    var data = [
      {
        'color': line!.color.value,
        'width': line!.width,
        'points': [
          for (var offset in line!.path)
            {
              'offset': {
                'dx': offset!.dx,
                'dy': offset.dy,
              },
            }
        ],
      },
    ];
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments?;
    print(args!.id);
    //print(line!.path);
    /* for (var element in line!.path) {
      print('${element!.dx} and ${element.dy}');
    } */
    print(data);
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(args.id)
        .update({"lines": FieldValue.arrayUnion(data)})
        .then((value) => print("upload!"))
        .catchError((error) => print(error));
  }

  Widget buildStrokeToolbar() {
    return Positioned(
      bottom: 100.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStrokeButton(5.0),
          buildStrokeButton(10.0),
          buildStrokeButton(15.0),
        ],
      ),
    );
  }

  Widget buildStrokeButton(double strokeWidth) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWidth = strokeWidth;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          width: strokeWidth * 2,
          height: strokeWidth * 2,
          decoration: BoxDecoration(
              color: selectedColor, borderRadius: BorderRadius.circular(50.0)),
        ),
      ),
    );
  }

  Widget buildColorToolbar() {
    return Positioned(
      top: 40.0,
      right: 10.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildColorButton(Colors.red),
          buildColorButton(Colors.blueAccent),
          buildColorButton(Colors.deepOrange),
          buildColorButton(Colors.green),
          buildColorButton(Colors.lightBlue),
          buildColorButton(Colors.black),
          buildColorButton(Colors.white),
          const Divider(
            height: 50.0,
          ),
          buildClearButton(),
        ],
      ),
    );
  }

  Widget buildColorButton(Color color) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: FloatingActionButton(
        mini: true,
        backgroundColor: color,
        child: Container(),
        onPressed: () {
          setState(() {
            selectedColor = color;
          });
        },
      ),
    );
  }

  Widget buildClearButton() {
    return GestureDetector(
      onTap: clear,
      child: const CircleAvatar(
        child: Icon(
          Icons.delete,
          size: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
