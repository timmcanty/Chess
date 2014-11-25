require_relative 'chess_pieces.rb'
class SlidingPiece < Piece
  def moves
    possible_moves = []

    move_dirs.each do |dir|
      (1..7).each do |dist|
        new_pos = Piece.add_pos(pos,dir,dist)
        next unless board.valid?(new_pos)

        if board[new_pos] && !board[new_pos].is_a?(EnPassantTracer)
          possible_moves << new_pos unless match_color(board[new_pos])
          break
        end
        possible_moves << new_pos
      end
    end

    possible_moves


  end

  def move_dirs
  end
end

class Bishop < SlidingPiece
  def move_dirs
    [-1,1].product([-1,1])
  end
end

class Rook < SlidingPiece
  def move_dirs
    [ [1,0],
      [0,1],
      [-1,0],
      [0,-1]
      ]
  end
end

class Queen < SlidingPiece
  def move_dirs
    [-1,0,1].product([-1,0,1]) - [[0,0]]
  end
end
