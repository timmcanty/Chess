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


  def run

    turn = [:w, :b]

    until over?
      begin
        @board.render

        if turn.first == :w
          command = @white.get_move(:w)
        else
          command = @black.get_move(:b)
        end

        raise NotYourPieceError unless turn.first == @board[command[0]].color

        @board.move(*command)

      rescue NoPieceAtLocationError => e
        puts e.message
        retry
      rescue InvalidMoveError => e
        puts e.message
        retry
      rescue CannotMoveIntoCheckError => e
        puts e.message
        retry
      rescue NotYourPieceError => e
        puts e.message
        retry
      end

      turn.rotate!

    end

    @board.render
    puts "Checkmate! White wins!" if winner == :w
    puts "Checkmate! Black wins!" if winner == :b


  end


  def over?
    @board.checkmate?(:w) || @board.checkmate?(:b)
  end



  def winner
    :w if @board.checkmate?(:b)
    :b if @board.checkmate?(:w)
  end


end

class Player

  def get_move(color)
  end

end

class HumanPlayer < Player

  def get_move(color)
    name = "White" if color == :w
    name = "Black" if color == :b
    valid = false

    puts
    until valid
      puts "Make your Move, #{name}    ex: from, to" # "f2, f3"
      move = gets.chomp.downcase.split(',').each { |part| part.strip!}
      valid = move.all? { |pos| pos.match(/[a-h][1-8]/) }
    end

    start_pos = parse(move[0])


    end_pos = parse(move[1])



    [start_pos,end_pos]
  end

  def parse(string_cmd)
    col = string_cmd[0].ord - 97
    row = string_cmd[1].to_i - 1

    [col,row]
  end

end

class NotYourPieceError < StandardError
end
