
class Piece

  def self.add_pos(pos1,pos2,dist=1)
    [(pos1[0] + dist * pos2[0]), (pos1[1] + dist * pos2[1])]
  end

  def initialize(pos,board,color)
    @pos = pos
    @board = board
    @moved = false
    @color = color # :w or :b
    @board[pos] = self
  end

  attr_reader :color
  attr_accessor :moved, :pos, :board

  def dup
    self.class.new(pos.dup, Board.new, color)
  end

  def moves
  end

  def moved?
    moved
  end

  def match_color(piece)
    color == piece.color
  end

  def move_into_check?(end_pos)
    dup_board = board.dup
    dup_board.move!( pos , end_pos )

    dup_board.in_check?(color)
  end

  def filtered_moves(poss_moves)
    poss_moves.reject { |poss_move| move_into_check?(poss_move) }
  end

end

class Pawn < Piece
  def moves
    possible_moves = move_dirs.map { |dir| Piece.add_pos(pos,dir)}

    valid_moves = possible_moves.select.each_with_index do |new_pos,i|
      case i
      when 0
        single_move?(new_pos)
      when 1
        double_move?(new_pos)
      when 2
        capture?(new_pos)
      when 3
        capture?(new_pos)
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

  def single_move?(new_pos)
    board.valid?(new_pos) && !board[new_pos]
  end

  def double_move?(new_pos)
    board.valid?(new_pos) && !board[new_pos] && !moved?
  end

  def capture?(new_pos)
    board.valid?(new_pos) && board[new_pos] && !match_color(board[new_pos])
  end

end

class EnPassantTracer < Piece
  attr_accessor :color
end
