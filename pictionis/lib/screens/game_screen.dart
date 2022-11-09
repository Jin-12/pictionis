import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments?;
    return GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: RepaintBoundary(
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(args!.id)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }
                  if (snapshot.hasData && !snapshot.hasError) {
                    String receivedData = snapshot.data.toString();
                    print(receivedData);
                  }

                  if (snapshot.hasData && !snapshot.data!.exists) {
                    return const Text("Document does not exist");
                  }

                  if (snapshot.connectionState == ConnectionState.active) {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    List<DrawnLine?> dataLines = [];
                    if (data['lines'] == null) {
                      return CustomPaint(
                        painter: Sketcher(lines: dataLines),
                      );
                    }
                    for (var dataLine in data['lines']) {
                      List<Offset?> offsetList = [];
                      for (var i in dataLine['path']) {
                        Offset offset =
                            Offset(i['offset']['dx'], i['offset']['dy']);
                        offsetList.add(offset);
                      }
                      Color color = Color(int.parse(dataLine['color']));
                      double width = dataLine['width'];
                      line = DrawnLine(offsetList, color, width);
                      dataLines.add(line);
                    }
                    return CustomPaint(
                      painter: Sketcher(lines: dataLines),
                    );
                  }
                  return const Text("loading");
                }),
          ),
        ));
  }

  Widget buildAllPaths(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments?;
    return RepaintBoundary(
      key: _globalKey,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rooms')
                .doc(args!.id)
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return const Text("Something went wrong");
              }

              if (snapshot.hasData && !snapshot.data!.exists) {
                return const Text("Document does not exist");
              }

              if (snapshot.connectionState == ConnectionState.active) {
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                List<DrawnLine?> dataLines = [];
                if (data['lines'] == null) {
                  return CustomPaint(
                    painter: Sketcher(lines: dataLines),
                  );
                }
                for (var dataLine in data['lines']) {
                  List<Offset?> offsetList = [];
                  for (var i in dataLine['path']) {
                    Offset offset =
                        Offset(i['offset']['dx'], i['offset']['dy']);
                    offsetList.add(offset);
                  }
                  Color color = Color(int.parse(dataLine['color']));
                  double width = dataLine['width'];
                  line = DrawnLine(offsetList, color, width);
                  dataLines.add(line);
                }
                return CustomPaint(
                  painter: Sketcher(lines: dataLines),
                );
              }
              return const Text("loading");
            }),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    print('User started drawing');
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    line = DrawnLine([point], selectedColor, selectedWidth);
    //currentLineStreamController.add(line!);
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    final path = List<Offset?>.from(line!.path)..add(point);
    line = DrawnLine(path, selectedColor, selectedWidth);
    //currentLineStreamController.add(line!);
  }

  Future<void> onPanEnd(DragEndDetails details) async {
    lines = List.from(lines)..add(line!);
    //linesStreamController.add(lines);

    var dataMap = lines.map((DrawnLine d) {
      return {
        'color': d.color.value.toString(),
        'width': d.width,
        'path': [
          for (var offset in line!.path)
            {
              'offset': {
                'dx': offset!.dx,
                'dy': offset.dy,
              },
            }
        ],
      };
    }).toList();
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments?;

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(args!.id)
        .update({"lines": FieldValue.arrayUnion(dataMap)})
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
        heroTag: null,
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
