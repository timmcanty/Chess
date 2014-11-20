class Board

  def piece_count
    piece_count = Hash.new(0)

    pieces.each do |piece|
      piece_count[ [piece.class,piece.color]] +=1
    end

    piece_count
  end

  def piece_score
    types = [ Bishop, Pawn, King, Queen, Rook, Knight]
    scores = [ 3, 1 , 200 , 9 , 5 , 3]
    white_score = 0
    black_score = 0

    types.each_index do |type|
      white_score += piece_count[ [types[type], :w]] *  scores[type]
      black_score += piece_count[ [types[type], :b]] * scores[type]
    end

    white_score - black_score
  end

  def mobility_score
    white_score = 0
    black_score = 0

    pieces.each do |piece|
      next if piece.is_a?(EnPassantTracer)

      if piece.color == :w
        white_score += piece.moves.size
      else piece.color == :b
        black_score += piece.moves.size
      end

    end

    white_score - black_score
  end


end
