import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:pictionis/screens/game_screen.dart';
import 'package:pictionis/src/widgets.dart';

class CreateRoomScreen extends StatefulWidget {
  static String routeName = '/create-room';
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
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
                const Header('Create Room'),
                CustomTextField(
                    controller: _nameController, hintText: 'Enter your pseudo'),
                StyledButton(
                    onPressed: () {
                      final hostName = _nameController.text;
                      createRoom(hostName);
                    },
                    child: const Text('Create')),
              ],
            )));
  }

  void createRoom(String hostName) async {
    final user = FirebaseAuth.instance.currentUser;

    final room = {
      'host': user?.uid,
      'host_name': hostName,
      'players': [user?.uid],
      'current_round': 1,
      'joinable': true,
      'created_at': DateTime.now(),
      'turn': 0,
    };

    FirebaseFirestore.instance.collection('rooms').add(room).then(
        (DocumentReference doc) =>
            print('"DocumentSnapshot added with ID: ${doc.id}'));
    Navigator.pushNamed(context, GameScreen.routeName);
  }
}
