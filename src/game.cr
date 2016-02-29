module TicTacToe
  class Game
    def initialize(fields = empty, first = empty, second = empty)
    end

    def over?
    end

    private def empty
      [] of {Int32, Int32}
    end
  end
end
