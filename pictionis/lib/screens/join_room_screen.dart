import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../src/widgets.dart';
import 'game_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  static String routeName = '/join-room';
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gameIdController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Header('Join Room'),
                CustomTextField(
                    controller: _nameController, hintText: 'Enter your pseudo'),
                CustomTextField(
                    controller: _gameIdController, hintText: 'Enter Game ID'),
                StyledButton(
                    onPressed: () {
                      final name = _nameController.text;
                      final roomId = _gameIdController.text;
                      joinRoom(name, roomId);
                    },
                    child: const Text('Join')),
              ],
            )));
  }

  void joinRoom(String name, String roomId) async {
    if (name.isNotEmpty && roomId.isNotEmpty) {
      final docRef = FirebaseFirestore.instance.collection('rooms').doc(roomId);
      docRef.get().then(
        (DocumentSnapshot doc) {
          final room = doc.data() as Map<String, dynamic>;
          List players = room["players"];
          if (room["joinable"] = true) {
            final player = {
              "id": FirebaseAuth.instance.currentUser?.uid,
              "name": name,
            };
            players.add(player);
            room["players"] = players;
          }
          docRef.set(room);
          Provider.of<ApplicationState>(context, listen: false)
              .updateRoomData(room);
          Navigator.pushNamed(context, GameScreen.routeName,
              arguments: ScreenArguments(roomId));
        },
        onError: (e) => print("Error getting document: $e"),
      );
    }
  }
}
