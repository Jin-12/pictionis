import 'package:flutter/material.dart';

import 'widgets.dart';

class AuthFunc extends StatelessWidget {
  const AuthFunc({
    super.key,
    required this.loggedIn,
    required this.signOut,
  });

  final bool loggedIn;
  final void Function() signOut;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: loggedIn,
          child:
              StyledButton(onPressed: () {}, child: const Text('Create Room')),
        ),
        Visibility(
          visible: loggedIn,
          child: StyledButton(onPressed: () {}, child: const Text('Join Room')),
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
