class Board

  # def destroy_tracer(color)
      # pieces.each do  { |piece| board[piece.loc] = nil if piece.is_a?(EnPassantTracer)}
  #

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

  def pawns
    pieces.select { |piece| piece.is_a?(Pawn)}
  end


  def pawns_with_promotion
    pawns.select { |piece| piece.pos[1] == 0 || piece.pos[1] == 7}
  end

  def promote(promotion)
    raise "HORRIBLE MISTAKE!!!!" if pawns_with_promotion.size != 1
    promotion_pos = pawns_with_promotion[0].pos
    promotion_col = pawns_with_promotion[0].color

    case promotion
    when 'Q'
      self[promotion_pos] = Queen.new(promotion_pos, self, promotion_col)
    when 'R'
      self[promotion_pos] = Rook.new(promotion_pos, self, promotion_col)
    when 'B'
      self[promotion_pos] = Bishop.new(promotion_pos, self, promotion_col)
    when 'N'
      self[promotion_pos] = Knight.new(promotion_pos, self, promotion_col)
    end
  end

  def in_check?(color)

    king_pos = find_king(color)


    pieces.each do |piece|
      next if piece.is_a?(EnPassantTracer)

      return true if piece.color != color && piece.moves.include?(king_pos)

    end

    false
  end

  def move(start_pos, end_pos)
    raise NoPieceAtLocationError unless self[start_pos]
    raise InvalidMoveError unless self[start_pos].moves.include?(end_pos)
    raise CannotMoveIntoCheckError if self[start_pos].move_into_check?(end_pos)

    make_tracer(start_pos) if double_move_pawn(start_pos,end_pos)

    en_passant_capture(start_pos, end_pos) if en_passant?(start_pos, end_pos)

    move!(start_pos, end_pos)

  end

  def move!(start_pos, end_pos)

    # make_tracer(start_pos) if double_move_pawn(start_pos,end_pos)
    #
    # en_passant_capture(start_pos, end_pos) if en_passant?(start_pos, end_pos)

    piece = self[start_pos]
    piece.pos = end_pos
    piece.moved = true
    self[start_pos] = nil
    self[end_pos] = piece

  end

  def en_passant?(start_pos, end_pos)
    self[start_pos].is_a?(Pawn) && self[end_pos].is_a?(EnPassantTracer)
  end

  def en_passant_capture(start_pos, end_pos)
    self[ [ end_pos[0], start_pos[1] ] ] = nil
  end

  def kingside?(color)

    if color == :w
      row = 0
    else
      row = 7
    end


    return false if self[[5,row]]
    return false if self[[6,row]]
    return false if self[[4,row]].moved?
    return false if self[[7,row]].moved?
    return false if self.in_check?(color)
    return false if self[[4,row]].move_into_check?([6,row])
    return false if self[[4,row]].move_into_check?([5,row])

    true
  end

  def kingside(color)
    if color == :w
      row = 0
    else
      row = 7
    end

    self.move!([4,row], [6,row])
    self.move!([7,row], [5,row])
  end

  def queenside?(color)
    if color == :w
      row = 0
    else
      row = 7
    end

    return false if self[[1,row]]
    return false if self[[2,row]]
    return false if self[[3,row]]
    return false if self[[4,row]].moved?
    return false if self[[0,row]].moved?
    return false if self.in_check?(color)
    return false if self[[4,row]].move_into_check?([3,row])
    return false if self[[4,row]].move_into_check?([2,row])


    true
  end

  def queenside(color)
    if color == :w
      row = 0
    else
      row = 7
    end

    self.move!([4,row], [2,row])
    self.move!([0,row], [3,row])
  end

  def make_tracer(start_pos)
    color = self[start_pos].color
    self[ [start_pos[0],start_pos[1] + 1 ]] = EnPassantTracer.new([start_pos[0],start_pos[1] + 1 ], self, :w) if color == :w
    self[ [start_pos[0],start_pos[1] - 1 ]] = EnPassantTracer.new([start_pos[0],start_pos[1] - 1 ], self, :b) if color == :b
  end

  def delete_tracers(color)
    pieces.each do |piece|
      self[piece.pos] = nil if piece.is_a?(EnPassantTracer) && piece.color == color
    end
  end

  def double_move_pawn(start_pos,end_pos)
    self[start_pos].is_a?(Pawn) && ( (start_pos[1] - end_pos[1]).abs == 2)
  end

  def dup
    dup_board = Board.new

    pieces.each do |piece|
      dup_board[piece.pos] = piece.dup
      dup_board[piece.pos].board = dup_board
    end

    dup_board
  end



  def checkmate?(color)
    pieces.each do |piece|
      next if piece.is_a?(EnPassantTracer)

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
    return " " if space.nil? || space.is_a?(EnPassantTracer)
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
