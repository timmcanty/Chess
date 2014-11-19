class Board

  attr_accessor :board

  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
  end

  def place_pieces( back_row = 0, pawn_row = 1, color = :w )

    [[0,back_row],[7,back_row]].each { |pos| Rook.new( pos,self,color)}
    [[1,back_row],[6,back_row]].each { |pos| Knight.new( pos,self,color)}
    [[2,back_row],[5,back_row]].each { |pos| Bishop.new( pos,self,color)}

    King.new( [4,back_row], self, color )
    Queen.new( [3,back_row], self, color )

    (0..7).each { |i| Pawn.new( [i,pawn_row], self, color )}

  end

  def setup_board
    place_pieces
    place_pieces( 7, 6, :b )

    self
  end

  def [](pos)
    @board[pos[0]][pos[1]]
  end

  def []=(pos,value)
     @board[pos[0]][pos[1]] = value
   end

  def valid?(pos)
    pos.all? { |value| value.between?(0,7) }
  end

  def find_king(color)
    king_index = pieces.find_index { |piece| piece.is_a?(King) && piece.color == color}

    return pieces[king_index].pos
  end

  def spaces
    @board.flatten
  end

  def pieces
    spaces.reject { |space| space.nil?}
  end



  def in_check?(color)

    king_pos = find_king(color)


    pieces.each do |piece|

      return true if piece.color != color && piece.moves.include?(king_pos)

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

    pieces.each do |piece|
      dup_board[piece.pos] = piece.dup
    end

    dup_board
  end



  def checkmate?(color)
    pieces.each do |piece|

      return false if piece.color == color && !piece.filtered_moves(piece.moves).empty?
    end
    true
  end

  def render
    7.downto(0).each do |row|
      print "  #{row+1}  | "
      (0..7).each do |col|
        print render_chars(self[[col,row]])
        print ' | '
      end
      puts
      print '     '
      8.times { print '+---' }
      print '+'
      puts
    end
    puts "     | a | b | c | d | e | f | g | h |"
  end

  def render_chars(space)
    return " " if space.nil?
    case space.class.to_s
    # when nil
    #   char =  " "
    when 'Pawn'
      char = (space.color == :w) ? '♙' : '♟'
    when 'King'
      char = (space.color == :w) ? "♔" : '♚'
    when 'Queen'
      char = (space.color == :w) ? '♕' : '♛'
    when 'Rook'
      char = (space.color == :w) ? '♖' : '♜'
    when 'Knight'
      char = (space.color == :w) ? '♘' : '♞'
    when 'Bishop'
      char = (space.color == :w) ? '♗' : '♝'
    end
    char
  end

end

class ChessError < StandardError
end

class NoPieceAtLocationError < ChessError
end

class InvalidMoveError < ChessError
end

class CannotMoveIntoCheckError < ChessError
end
