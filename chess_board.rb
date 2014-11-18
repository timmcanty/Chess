require_relative 'chess_pieces.rb'

class Board

  attr_accessor :board

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

  def find_king(color)
    king = nil
    spaces.each { |space| king = space if space.class == King &&
      space.color == color }

    return king.pos unless king.nil?
    nil
  end

  def spaces
    @board.flatten
  end



  def in_check?(color)

    king_pos = find_king(color)

    spaces.each do |space|

      next unless space
      return true if space.color != color && space.moves.include?(king_pos)

    end

    false
  end

  def move(start_pos, end_pos)
    raise NoPieceAtLocationError unless self[start_pos]
    raise InvalidMoveError unless self[start_pos].moves.include?(end_pos)
    raise CannotMoveIntoCheckError if self[start_pos].move_into_check?(end_pos)

    move!(start_pos, end_pos)

  end

  def move!(start_pos, end_pos)

    piece = self[start_pos]
    piece.pos = end_pos
    piece.moved = true
    self[start_pos] = nil
    self[end_pos] = piece

  end

  def dup
    dup_board = Board.new

    dup_board.board.each_index do |row|
      dup_board.board.each_index do |col|
        if self[[row,col]]
          dup_board[[row,col]] = self[[row,col]].dup
          dup_board[[row,col]].board = dup_board
        end
      end
    end
    dup_board
  end
end

class NoPieceAtLocationError < StandardError
end

class InvalidMoveError < StandardError
end

class CannotMoveIntoCheckError < StandardError
end
