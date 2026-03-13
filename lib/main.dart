import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const RvTossApp());
}

class RvTossApp extends StatelessWidget {
  const RvTossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RV TOSS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum Face { wheels, roof, driverSide, passengerSide, ladder, windshield }

class RollResult {
  final Face die1;
  final Face die2;
  final int pointsAdded;
  final bool endTurn;
  final bool resetTotal;
  final String message;

  const RollResult({
    required this.die1,
    required this.die2,
    required this.pointsAdded,
    required this.endTurn,
    required this.resetTotal,
    required this.message,
  });
}

class _GameScreenState extends State<GameScreen> {
  final Random rng = Random();

  final List<String> playerNames = ['JuliaC', 'MicheleD'];
  late List<int> totalScores;

  int currentPlayer = 0;
  int turnScore = 0;

  bool finalRound = false;
  int finalLeader = -1;
  int finalLeaderScore = 0;
  int finalTurnsRemaining = 0;

  bool gameOver = false;

  Face? lastDie1;
  Face? lastDie2;
  String lastMessage = 'Tap Roll to begin.';

  final List<MapEntry<Face, int>> weightedFaces = const [
    MapEntry(Face.wheels, 152),
    MapEntry(Face.roof, 134),
    MapEntry(Face.driverSide, 83),
    MapEntry(Face.passengerSide, 75),
    MapEntry(Face.ladder, 34),
    MapEntry(Face.windshield, 22),
  ];

  @override
  void initState() {
    super.initState();
    totalScores = List<int>.filled(playerNames.length, 0);
  }

  Face rollFace() {
    final int totalWeight = weightedFaces.fold(0, (sum, e) => sum + e.value);
    int roll = rng.nextInt(totalWeight);

    for (final entry in weightedFaces) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return Face.wheels;
  }

  int facePoints(Face f) {
    switch (f) {
      case Face.wheels:
        return 5;
      case Face.roof:
        return 0;
      case Face.driverSide:
      case Face.passengerSide:
        return 1;
      case Face.ladder:
      case Face.windshield:
        return 10;
    }
  }

  String faceLabel(Face f) {
    return f.name.toUpperCase().replaceAll('SIDE', ' SIDE');
  }

  RollResult scoreRoll(Face a, Face b) {
    if (a == Face.windshield && b == Face.windshield) {
      return RollResult(
        die1: a,
        die2: b,
        pointsAdded: 0,
        endTurn: true,
        resetTotal: true,
        message: 'HAIL-STORM! Total score reset to 0.',
      );
    }

    if (a == Face.roof && b == Face.roof) {
      return RollResult(
        die1: a,
        die2: b,
        pointsAdded: 0,
        endTurn: true,
        resetTotal: false,
        message: 'ROLL-OVER! Lose turn points.',
      );
    }

    if (a == Face.roof || b == Face.roof) {
      return RollResult(
        die1: a,
        die2: b,
        pointsAdded: 0,
        endTurn: true,
        resetTotal: false,
        message: 'ROOF! Turn ends, keep banked turn points.',
      );
    }

    int points = facePoints(a) + facePoints(b);
    int bonus = 0;

    if (a == Face.wheels && b == Face.wheels) bonus += 5;
    if ((a == Face.windshield && b == Face.ladder) ||
        (a == Face.ladder && b == Face.windshield)) {
      bonus += 10;
    }

    return RollResult(
      die1: a,
      die2: b,
      pointsAdded: points + bonus,
      endTurn: false,
      resetTotal: false,
      message: 'Scored ${points + bonus} points.',
    );
  }

  void startFinalRoundIfNeeded(int player) {
    if (finalRound) return;

    if (totalScores[player] >= 100) {
      finalRound = true;
      finalLeader = player;
      finalLeaderScore = totalScores[player];
      finalTurnsRemaining = playerNames.length - 1;
    }
  }

  void endTurn({bool bankTurnScore = false}) {
    if (bankTurnScore) {
      totalScores[currentPlayer] += turnScore;
    }

    if (finalRound && currentPlayer != finalLeader) {
      finalTurnsRemaining--;
      if (finalTurnsRemaining <= 0) {
        finishGame();
        return;
      }
    }

    turnScore = 0;
    currentPlayer = (currentPlayer + 1) % playerNames.length;
  }

  void finishGame() {
    gameOver = true;
    setState(() {});
  }

  void roll() {
    if (gameOver) return;

    final a = rollFace();
    final b = rollFace();
    final result = scoreRoll(a, b);

    setState(() {
      lastDie1 = a;
      lastDie2 = b;
      lastMessage = result.message;

      if (result.resetTotal) {
        totalScores[currentPlayer] = 0;
        turnScore = 0;
        endTurn();
        return;
      }

      if (result.endTurn) {
        endTurn(bankTurnScore: true);
        return;
      }

      turnScore += result.pointsAdded;
    });
  }

  void bankAndEndTurn() {
    if (gameOver) return;

    setState(() {
      totalScores[currentPlayer] += turnScore;
      startFinalRoundIfNeeded(currentPlayer);
      endTurn();
    });
  }

  Future<void> editPlayerName(int index) async {
    final controller = TextEditingController(text: playerNames[index]);

    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit player name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter a name'),
            maxLength: 12,
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      playerNames[index] = trimmed;
    });
  }

  void resetGame() {
    setState(() {
      totalScores = List<int>.filled(playerNames.length, 0);
      currentPlayer = 0;
      turnScore = 0;

      finalRound = false;
      finalLeader = -1;
      finalLeaderScore = 0;
      finalTurnsRemaining = 0;

      gameOver = false;

      lastDie1 = null;
      lastDie2 = null;
      lastMessage = 'Tap Roll to begin.';
    });
  }

  Future<void> confirmAndReset() async {
    final bool? shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset game?'),
          content: const Text('All scores and progress will be cleared.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      resetGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = finalRound ? Colors.red.shade50 : Colors.grey.shade50;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'RV TOSS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        backgroundColor: finalRound ? Colors.red.shade200 : null,
        actions: [
          IconButton(
            tooltip: 'Reset game',
            icon: const Icon(Icons.restart_alt, color: Colors.red),
            onPressed: confirmAndReset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              gameOver
                  ? 'Game Over'
                  : 'Current Player: ${playerNames[currentPlayer]}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ...List.generate(playerNames.length, (i) {
              return Card(
                color: i == currentPlayer
                    ? (finalRound
                          ? Colors.red.withValues(alpha: 0.08)
                          : Colors.teal.withValues(alpha: 0.08))
                    : null,
                // child: ListTile(
                //   title: Text(playerNames[i]),
                //   trailing: Text(
                //     totalScores[i].toString(),
                //     style: const TextStyle(fontSize: 18),
                //   ),
                //   onTap: () => editPlayerName(i),
                // ),
                child: ListTile(
                  title: Text(playerNames[i]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        totalScores[i].toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        tooltip: 'Edit name',
                        icon: const Icon(Icons.edit),
                        onPressed: gameOver ? null : () => editPlayerName(i),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),
            Text('Turn Score: $turnScore'),

            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      lastDie1 == null
                          ? '(no roll yet)'
                          : '${faceLabel(lastDie1!)} + ${faceLabel(lastDie2!)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(lastMessage),
                  ],
                ),
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: roll,
                    child: const Text('Roll'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: bankAndEndTurn,
                    child: const Text('Bank and End Turn'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
