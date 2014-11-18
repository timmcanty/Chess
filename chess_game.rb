require_relative 'chess_board.rb'
require_relative 'chess_pieces.rb'

class Game

  attr_accessor :board

  def initialize(player1,player2)
    @white = player1
    @black = player2
    @board = Board.new
    place_pieces
    place_pieces( 7, 6, :b )
  end

  def place_pieces( back_row = 0, pawn_row = 1, color = :w )

    [[0,back_row],[7,back_row]].each { |pos| Rook.new( pos,board,color)}
    [[1,back_row],[6,back_row]].each { |pos| Knight.new( pos,board,color)}
    [[2,back_row],[5,back_row]].each { |pos| Bishop.new( pos,board,color)}

    King.new( [4,back_row], board, color )
    Queen.new( [3,back_row], board, color )

    (0..7).each { |i| Pawn.new( [i,pawn_row], board, color )}

  end

end

class Player
end

class HumanPlayer < Player
end
