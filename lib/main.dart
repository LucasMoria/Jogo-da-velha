import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(JogoDaVelha());
}

class JogoDaVelha extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Velha',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EscolhaModo(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EscolhaModo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jogo da Velha - Escolha o Modo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(modoBot: false)),
                );
              },
              child: Text('Dois Jogadores'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EscolhaDificuldade()),
                );
              },
              child: Text('Contra o Bot'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

class EscolhaDificuldade extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escolha a Dificuldade')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(modoBot: true, dificuldade: "fácil"),
                  ),
                );
              },
              child: Text('Fácil'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(modoBot: true, dificuldade: "médio"),
                  ),
                );
              },
              child: Text('Médio'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(modoBot: true, dificuldade: "difícil"),
                  ),
                );
              },
              child: Text('Difícil'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool modoBot;
  final String? dificuldade;

  HomePage({required this.modoBot, this.dificuldade});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> board = List.filled(9, "");
  String currentPlayer = "X";
  String? winner;
  bool isGameOver = false;

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      winner = null;
      isGameOver = false;
    });
  }

  void playTurn(int index) {
    if (board[index] == "" && !isGameOver) {
      setState(() {
        board[index] = currentPlayer;
        if (checkWinner()) {
          winner = currentPlayer;
          isGameOver = true;
        } else if (!board.contains("")) {
          winner = "Empate";
          isGameOver = true;
        } else {
          currentPlayer = currentPlayer == "X" ? "O" : "X";
          if (widget.modoBot && currentPlayer == "O" && !isGameOver) {
            botPlay();
          }
        }
      });
    }
  }

  void botPlay() {
    int move;
    if (widget.dificuldade == "fácil") {
      move = getRandomMove();
    } else if (widget.dificuldade == "médio") {
      move = getMediumMove();
    } else {
      move = getBestMove();
    }
    playTurn(move);
  }

  int getRandomMove() {
    List<int> availableMoves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == "") availableMoves.add(i);
    }
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  int getMediumMove() {
    // Primeiro tenta ganhar
    for (int i = 0; i < board.length; i++) {
      if (board[i] == "") {
        board[i] = "O";
        if (checkWinnerForPlayer("O")) {
          board[i] = "";
          return i;
        }
        board[i] = "";
      }
    }
    // Depois tenta bloquear o jogador
    for (int i = 0; i < board.length; i++) {
      if (board[i] == "") {
        board[i] = "X";
        if (checkWinnerForPlayer("X")) {
          board[i] = "";
          return i;
        }
        board[i] = "";
      }
    }
    // Caso contrário, faz uma jogada aleatória
    return getRandomMove();
  }

  int getBestMove() {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < board.length; i++) {
      if (board[i] == "") {
        board[i] = "O";
        int score = minimax(0, false);
        board[i] = "";
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int minimax(int depth, bool isMaximizing) {
    if (checkWinnerForPlayer("O")) return 10 - depth;
    if (checkWinnerForPlayer("X")) return depth - 10;
    if (!board.contains("")) return 0;

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == "") {
          board[i] = "O";
          int score = minimax(depth + 1, false);
          board[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i] == "") {
          board[i] = "X";
          int score = minimax(depth + 1, true);
          board[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  bool checkWinnerForPlayer(String player) {
    const winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];

    for (var combination in winningCombinations) {
      if (board[combination[0]] == player &&
          board[combination[1]] == player &&
          board[combination[2]] == player) {
        return true;
      }
    }
    return false;
  }

  bool checkWinner() {
    return checkWinnerForPlayer(currentPlayer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.modoBot
            ? 'Bot (${widget.dificuldade})'
            : 'Dois Jogadores'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isGameOver
                ? (winner == "Empate" ? "Empate!" : "$winner venceu!")
                : "Jogador: $currentPlayer",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => playTurn(index),
                child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: resetGame,
            child: Text("Reiniciar Jogo"),
          ),
        ],
      ),
    );
  }
}
