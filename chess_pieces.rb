class Piece

  def initialize(pos,board,color)
    @pos = pos
    @board = board
    @moved = false
    @color = color # :w or :b
    @board[pos] = self
  end

  attr_reader :color, :board, :pos

  def moves
  end

  def add(pos1,pos2,dist=1)
    [(pos1[0]+dist*pos2[0]), (pos1[1]+dist*pos2[1])]
  end

  def moved?
    @moved
  end

  def match_color(piece)
    self.color == piece.color
  end
end

class SlidingPiece < Piece
  def moves
    possible_moves = []

    move_dirs.each do |dir|
      (1..7).each do |dist|
        new_pos = add(pos,dir,dist)
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
    valid_moves = possible_moves.map{ |move| add(move, pos)}
    valid_moves.select{|move| board.valid?(move) && empty_or_opponent(move) }
  end

  def possible_moves
  end

  def empty_or_opponent(pos)
    board[pos].nil? || !match_color(board[pos])
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

class Knight < SteppingPiece
  def possible_moves
    [[-2,-1],[-2,1],[-1,2],[-1,-2],[1,-2],[1,2],[2,-1],[2,1]]
  end
end

class King < SteppingPiece
  def possible_moves
    [-1,0,1].product([-1,0,1]) - [[0,0]]
  end
end


class Pawn < Piece
  def moves
    possible_moves = move_dirs.map { |dir| add(pos,dir)}

    valid_moves = possible_moves.select.each_with_index do |new_pos,i|
      case i
      when 0
        !board[new_pos] && board.valid?(new_pos)
      when 1
        !board[new_pos] && !moved?
      when 2 || 3
        board[new_pos] && !match_color(board[new_pos])
      when 3
        board[new_pos] && !match_color(board[new_pos])
      end
    end

    valid_moves

  end

  def move_dirs
    if color == :w
      [[0,1],[0,2],[-1,1],[1,1]]
    else
      [[0,-1],[0,-2],[-1,-1],[1,-1]]
    end
  end

end
