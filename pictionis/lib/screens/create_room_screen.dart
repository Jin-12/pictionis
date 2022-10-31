import 'package:flutter/material.dart';
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
                StyledButton(onPressed: () {}, child: const Text('Create')),
              ],
            )));
  }
}
