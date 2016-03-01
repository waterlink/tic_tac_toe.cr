module TicTacToe
  class Game
    alias Field = {Int32, Int32}

    N = 3

    VERTICAL = 1
    HORIZONTAL = 0
    ALIGNS = [VERTICAL, HORIZONTAL]

    MAIN = -> (f : Field) { f[0] == f[1] }
    BACK = -> (f : Field) { f[0] + f[1] == N - 1 }
    DIAGONALS = [MAIN, BACK]

    OUTCOMES = {
      first_won: "First player won",
      second_won: "Second player won",
      draw: "Draw",
    }

    protected getter fields, first, second
    def initialize(game : Array(String))
      initialize

      default = empty
      dispatch = {
        '_' => fields,
        'x' => first,
        'o' => second,
      }

      game.each_with_index do |line, i|
        line.each_char.each_with_index do |char, j|
          dispatch.fetch(char, default) << {i, j}
        end
      end
    end

    def initialize(@fields = empty : Array(Field), first = empty, second = empty, @notice = "")
      @first = first.sort
      @second = second.sort
    end

    macro from(*game)
      {% game_table = game.map(&.stringify) %}
      ::TicTacToe::Game.new({{game_table}})
    end

    def over?
      won?(first) ||
        won?(second) ||
        fields.empty?
    end

    def take(field)
      return self if over?

      Take
        .new(fields, first, second, field)
        .next_game
    end

    def notice
      @_notice ||= _notice
    end

    def outcome
      return :ongoing unless over?

      return :first_won if won?(first)
      return :second_won if won?(second)

      :draw
    end

    def ==(other : self)
      self.fields == other.fields &&
        self.first == other.first &&
        self.second == other.second
    end

    private def full_column?(column)
      (0...N).reduce(false) do |result, i|
        result || column.first
          .select(&.[column.last].== i)
          .size == N
      end
    end

    private def diagonal?(diag)
      diag.first
        .select(&diag.last)
        .size == N
    end

    private def _notice
      return over_notice if over?
      @notice
    end

    private def won?(taken)
      won_by_column?(taken) ||
        won_by_diagonal?(taken)
    end

    private def won_by_column?(taken)
      ALIGNS
        .map { |align| full_column?({taken, align}) }
        .any?
    end

    private def won_by_diagonal?(taken)
      DIAGONALS
        .map { |kind| diagonal?({taken, kind}) }
        .any?
    end

    private def over_notice
      "Game over. #{OUTCOMES[outcome]}."
    end

    private def empty
      [] of Field
    end

    private def self.empty
      [] of Field
    end

    class Take
      private getter fields, first, second, field
      def initialize(@fields, @first, @second, @field)
      end

      def next_game
        Game.new(
          fields: take_field,
          first: new_first,
          second: new_second,
          notice: new_notice,
        )
      end

      private def take_field
        @_take_field ||= fields.reject(&.== field)
      end

      private def new_first
        new_takens.first
      end

      private def new_second
        new_takens.last
      end

      private def new_notice
        return "" if field_present?
        "Field #{field} is already taken"
      end

      private def new_takens
        @_new_takens ||= _new_takens
      end

      private def _new_takens
        return nobody_taken unless field_present?
        return second_taken unless first_takes?
        first_taken
      end

      private def field_present?
        take_field.size < fields.size
      end

      private def nobody_taken
        {first, second}
      end

      private def first_taken
        {first + [field], second}
      end

      private def second_taken
        {first, second + [field]}
      end

      private def first_takes?
        first.size == second.size
      end
    end
  end
end
