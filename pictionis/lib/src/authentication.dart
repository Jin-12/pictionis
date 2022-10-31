import 'package:flutter/material.dart';
import 'package:pictionis/screens/create_room_screen.dart';
import 'package:pictionis/screens/join_room_screen.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    super.key,
    required this.loggedIn,
    required this.signOut,
  });

  final bool loggedIn;
  final void Function() signOut;

  void createRoom(BuildContext context) {
    Navigator.pushNamed(context, CreateRoomScreen.routeName);
  }

  void joinRoom(BuildContext context) {
    Navigator.pushNamed(context, JoinRoomScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: loggedIn,
          child: StyledButton(
              onPressed: () {
                createRoom(context);
              },
              child: const Text('Create Room')),
        ),
        Visibility(
          visible: loggedIn,
          child: StyledButton(
              onPressed: () {
                joinRoom(context);
              },
              child: const Text('Join Room')),
        ),
        Visibility(
          visible: loggedIn,
          child: StyledButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
              },
              child: const Text('Profile')),
        ),
        StyledButton(
            onPressed: () {
              !loggedIn
                  ? Navigator.of(context).pushNamed('/sign-in')
                  : signOut();
            },
            child: !loggedIn ? const Text('Sign In') : const Text('Logout')),
      ],
    );
  }
}
