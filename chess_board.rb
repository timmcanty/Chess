require_relative 'chess_pieces.rb'

class Board

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end

  def []=(pos,value)  # board[pos] = something
     @board[pos[0]][pos[1]] = value
   end

  def valid?(pos)
    pos.all? { |value| value.between?(0,7) }
  end

end
