require_relative 'chess_pieces.rb'
class SteppingPiece < Piece

  def moves
    valid_moves = possible_moves.map{ |move| Piece.add_pos(move, pos)}
    valid_moves.select!{|move| empty_or_opponent?(move) }

    valid_moves
  end

  def possible_moves
  end

  def empty_or_opponent?(pos)
    board.valid?(pos) && (board[pos].nil? || !match_color(board[pos]) )
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
