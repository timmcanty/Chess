class Piece

  def initialize(pos,board)
    @pos = pos
    @board = board
  end

  def moves
  end

  def add_distance(pos1,pos2,dist)
    [(pos1[0]+dist*pos2[0]), (pos1[1]+dist*pos2[1])]
  end
end

class SlidingPiece < Piece
  def moves
    possible_moves = []

    move_dirs.each do |dir|
      (1..7).each do |dist|
        new_pos = add_distance(pos,dir,dist)
        if !board.valid?(new_pos)
          break
        elsif board[new_pos]
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

class SteppingPiece < Piece

  def moves
    possible_moves.select{|move| board.valid?(move) && !match_color(board[move])}
  end

  def possible_moves
  end

end
class Pawn < Piece
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

class Knight < SteppingPiece
  def possible_moves
    [[-2,-1],[-2,1],[-1,2],[-1,-2],[1,-2],[1,2],[2,-1],[2,1]]
  end
end

class King < SteppingPiece
  def possible_moves
    [-1,0,1].product([-1,0,1]) - [[0,0]]
  end
