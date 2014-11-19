require_relative 'chess_board.rb'
require_relative 'chess_pieces.rb'

class Game

  attr_accessor :board

  def initialize(player1,player2)
    @white = player1
    player1.color = :w
    @black = player2
    player2.color = :b

    @board = Board.new.setup_board


  end



  def run

    turn = [@white, @black]

    until over?
      begin
        @board.render

        command = turn.first.get_move

        raise NotYourPieceError unless turn.first.color == @board[command[0]].color

        @board.move(*command)

      rescue ChessError => e
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

  attr_accessor :color

  def get_move
  end

end

class HumanPlayer < Player

  def get_move
    name = "White" if self.color == :w
    name = "Black" if self.color == :b
    valid = false

    puts
    until valid
      puts "Make your Move, #{name}    ex: from, to"
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

class NotYourPieceError < ChessError
end
