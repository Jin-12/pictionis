import 'dart:ffi';

class Room {
  final String host;
  final String hostName;
  final List players;
  final Int currentRound;
  final Bool joinable;
  final DateTime createdAt;
  final Int turn;

  const Room(this.host, this.hostName, this.players, this.currentRound,
      this.joinable, this.createdAt, this.turn);
}
