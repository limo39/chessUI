import 'package:flutter/material.dart';
import 'package:mixui/colors.dart';
import 'package:mixui/piece.dart';
import 'package:mixui/square.dart';
import 'package:mixui/uti.dart';
import 'package:mixui/dead_piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;

  // default row & col index
  int selectedRow = -1;
  int selectedCol = -1;

  // valid moves
  List<List<int>> validMoves = [];

  // taken pieces
  List<ChessPiece> whitePiecesTaken = [];

  List<ChessPiece> blackPiecesTaken = [];

  // turns
  bool isWhiteTurn = true;

  // king's position
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  // initialize board
  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'images/BP.gif');

      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn, isWhite: true, imagePath: 'images/WP.gif');

      // Rooks
      newBoard[0][0] = ChessPiece(
          type: ChessPieceType.rook,
          isWhite: false,
          imagePath: 'images/BR.gif');
      newBoard[0][7] = ChessPiece(
          type: ChessPieceType.rook,
          isWhite: false,
          imagePath: 'images/BR.gif');
      newBoard[7][0] = ChessPiece(
          type: ChessPieceType.rook, isWhite: true, imagePath: 'images/WR.gif');
      newBoard[7][7] = ChessPiece(
          type: ChessPieceType.rook, isWhite: true, imagePath: 'images/WR.gif');

      // Knights
      newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'images/BN.gif',
      );
      newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'images/BN.gif',
      );
      newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'images/WN.gif',
      );
      newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'images/WN.gif',
      );
      // Bishop
      newBoard[0][2] = ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: false,
          imagePath: 'images/BB.gif');
      newBoard[0][5] = ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: false,
          imagePath: 'images/BB.gif');
      newBoard[7][2] = ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: true,
          imagePath: 'images/WB.gif');
      newBoard[7][5] = ChessPiece(
          type: ChessPieceType.bishop,
          isWhite: true,
          imagePath: 'images/WB.gif');

      // Queens
      newBoard[0][3] = ChessPiece(
          type: ChessPieceType.queen,
          isWhite: false,
          imagePath: 'images/BQ.gif');
      newBoard[7][4] = ChessPiece(
          type: ChessPieceType.queen,
          isWhite: true,
          imagePath: 'images/WQ.gif');

      // Kings
      newBoard[0][4] = ChessPiece(
          type: ChessPieceType.king,
          isWhite: false,
          imagePath: 'images/BK.gif');
      newBoard[7][3] = ChessPiece(
          type: ChessPieceType.king, isWhite: true, imagePath: 'images/WK.gif');
    }
    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

  // Calculate moves
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // pawn forward
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        //  steps forward
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // kill diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (board[newRow][newCol] != null) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col = move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // kill
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // kill
              }
              break;
            }
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // kill
              }
              break;
            }
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, 1],
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // kill
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }

        break;
      default:
    }
    return candidateMoves;
  }

  // Calculate real valid moves
  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    // filter out any that would result in a check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  // isInBoard Error
  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  // move piece
  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    // Check place king is being moved to
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // See if king is under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    // clear
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    // check if it's check mate
    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Check Mate!"),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: Text("Play Game Again"),
            ),
          ],
        ),
      );
    }

    // Change Turns
    isWhiteTurn = !isWhiteTurn;
  }

  // is king n check
  bool isKingInCheck(bool isWhiteKing) {
    List<int> KingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if enemy piece can attack the king
    for (int i = 0; i < 0; i++) {
      for (int j = 0; j < 0; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == KingPosition[0] && move[1] == KingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  // Simulate a future move to see it'safe for the king
  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? OriginalDestinationPiece = board[endRow][endCol];

    // if the piece is king, save it's current position and update
    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;

      // update king position
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }
    // simulated the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // Check if King is under attack
    bool kingInCheck = isKingInCheck(piece.isWhite);

    // restore board state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = OriginalDestinationPiece;

    // if the piece was the king, restore its original position
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingInCheck;
  }

  // Checkmate
  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[1][1] == null || board[1][1]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // white pieces taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: whitePiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          Text(checkStatus ? "Check!" : ""),

          // chess board
          Expanded(
            flex: 3,
            child: GridView.builder(
                itemCount: 8 * 8,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;

                  bool isSelected = selectedRow == row && selectedCol == col;

                  bool isValidMove = false;
                  for (var position in validMoves) {
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }
                  return Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row, col),
                  );
                }),
          ),

          // Black taken pieces
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackPiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class True {}
