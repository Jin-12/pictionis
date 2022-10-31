import 'package:flutter/material.dart';

import '../src/widgets.dart';

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
                StyledButton(onPressed: () {}, child: const Text('Join')),
              ],
            )));
  }
}
