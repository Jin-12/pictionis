import 'dart:ffi';

import 'package:pictionis/src/drawn_line.dart';

class Room {
  final String host;
  final String hostName;
  final List players;
  final List<DrawnLine> lines;
  final Int currentRound;
  final Bool joinable;
  final DateTime createdAt;
  final Int turn;

  const Room(this.host, this.hostName, this.players, this.lines,
      this.currentRound, this.joinable, this.createdAt, this.turn);
}
