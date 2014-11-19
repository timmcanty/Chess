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
        # :kingside or :queenside

        if command == :kingside
          raise InvalidCastlingError unless @board.kingside?(turn.first.color)
          @board.kingside(turn.first.color)
          turn.rotate!
          next
        elsif command == :queenside
          raise InvalidCastlingError unless @board.queenside?(turn.first.color)
          @board.queenside(turn.first.color)
          turn.rotate!
          next
        end



        raise NotYourPieceError unless turn.first.color == @board[command[0]].color

        @board.move(*command)

        if !@board.pawns_with_promotion.empty?
          @board.render
          promotion = turn.first.pick_promotion
          @board.promote(promotion)
        end

      rescue ChessError => e
        puts e.message
        retry
      end


      @board.delete_tracers(turn.last.color)
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

  def pick_promotion
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
      input = gets.chomp
      return :kingside if input == "O-O"
      return :queenside if input == "O-O-O"
      move = input.downcase.split(',').each { |part| part.strip!}
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

  def pick_promotion
    valid = false

    until valid
      puts "Promote to which piece? ( Q, R, B, N)"
      input = gets.chomp.upcase
      valid = true if ['Q','R','B','N'].include?(input)
    end

    input
  end

end

class InvalidCastlingError < ChessError
end

class NotYourPieceError < ChessError
end
