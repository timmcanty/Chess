require_relative 'chess_board.rb'
require_relative 'chess_pieces.rb'
require_relative 'chess_sliding.rb'
require_relative 'chess_stepping.rb'
require_relative 'tree_node.rb'
require 'yaml'

class Game

  attr_accessor :board, :black

  def initialize(player1,player2)
    @white = player1
    player1.color = :w
    @black = player2
    player2.color = :b

    @board = Board.new.setup_board

    player1.board = @board if player1.is_a?(ComputerPlayer)
    player2.board = @board if player2.is_a?(ComputerPlayer)


  end



  def run(blacks_turn = false)

    turn = [@white, @black]
    turn.rotate! if blacks_turn

    until over?(turn.first.color)
      begin
        board.render

        command = turn.first.get_move

        if command == :save
          puts "Filename?"
          filename = gets.chomp
          f = File.open(filename, 'w')
          f.puts ([self,turn.first.color].to_yaml)
          f.close
          return
        end
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

        raise NoPieceAtStartPosError unless @board[command[0]]



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
    if @board.stalemate?(turn.last.color)
      puts "Stalemate! Nobody wins!"
      return
    end
    puts "Checkmate! White wins!" if winner == :w
    puts "Checkmate! Black wins!" if winner == :b


  end


  def over?(color)
    @board.stalemate?(color) || @board.checkmate?(color)
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
    begin
      name = "White" if self.color == :w
      name = "Black" if self.color == :b
      valid = false

      puts
      until valid
        puts "Make your Move, #{name}    ex: from, to"
        input = gets.chomp
        return :save if input == "save"
        return :kingside if input == "O-O"
        return :queenside if input == "O-O-O"
        move = input.downcase.split(',').each { |part| part.strip!}
        valid = move.all? { |pos| pos.match(/[a-h][1-8]/) }
      end

      start_pos = parse(move[0])


      end_pos = parse(move[1])



      return [start_pos,end_pos]
    rescue StandardError
      retry
    end
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

class ComputerPlayer < Player

  attr_accessor :board

  def random_move(pieces)

    moved_piece = pieces.sample

    [board[moved_piece.pos].pos, moved_piece.moves.sample ]
  end

end

class RandomComputer < ComputerPlayer


  def get_move
    our_pieces = @board.pieces.select do |piece|
      !piece.is_a?(EnPassantTracer) &&!piece.moves.empty? && piece.color == self.color
    end

    random_move(our_pieces)
  end

  def pick_promotion
    'Q'
  end
end

class CapturingComputer < ComputerPlayer

  def get_move
    our_pieces = @board.pieces.select do |piece|
      !piece.is_a?(EnPassantTracer) &&!piece.moves.empty? && piece.color == self.color
    end

    capturing_moves = []

    our_pieces.each do |piece|
      piece.moves.each do |move|

        capturing_moves << [ @board[piece.pos].pos, move ] if ( @board[move] &&
        !@board[move].is_a?(EnPassantTracer) )

      end
    end

    return random_move(our_pieces) if capturing_moves.empty?


    capturing_moves.sample
  end

  def pick_promotion
    'Q'
  end

end

class NoPieceAtStartPosError < ChessError
end

class InvalidCastlingError < ChessError
end

class NotYourPieceError < ChessError
end

if __FILE__ == $PROGRAM_NAME

  unless ARGV.empty?
    file = File.read(ARGV.shift)
    data = YAML.load(file)
    p data.class
    game = data[0] # game
    turn = data[1] # game
    blacks_turn = false
    blacks_turn = true if turn == :b
    game.run(blacks_turn)
  end

  game = Game.new(HumanPlayer.new, HumanPlayer.new)
  game.run
end
