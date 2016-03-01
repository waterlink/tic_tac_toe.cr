module TicTacToe
  class Game
    alias Field = {Int32, Int32}

    N = 3

    WIN_CHECKS = [
      Column(Column::HORIZONTAL),
      Column(Column::VERTICAL),
      Diagonal(Diagonal::Main),
      Diagonal(Diagonal::Back),
    ]

    OUTCOMES = {
      first_won: "First player won",
      second_won: "Second player won",
      draw: "Draw",
    }

    protected getter fields, first, second
    def initialize(game : Array(String))
      initialize
      init_from_table!(game)
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

    private def _notice
      return over_notice if over?
      @notice
    end

    private def won?(taken)
      WIN_CHECKS
        .map(&.full?(taken))
        .any?
    end

    private def over_notice
      "Game over. #{OUTCOMES[outcome]}."
    end

    private def stack_by_hash
      @_stack_by ||= {
        '_' => fields,
        'x' => first,
        'o' => second,
      }
    end

    private def stack_by_default
      @_stack_by_default ||= empty
    end

    private def stack_by(char)
      stack_by_hash
        .fetch(char, stack_by_default)
    end

    private def init_from_table!(game)
      game.each_with_index do |line, i|
        line.each_char.each_with_index do |char, j|
          stack_by(char) << {i, j}
        end
      end
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

    class WinCheck
      private getter taken
      def initialize(@taken)
      end

      def self.full?(taken)
        new(taken).full?
      end

      def full?
        false
      end
    end

    class Column(A) < WinCheck
      VERTICAL = 1
      HORIZONTAL = 0

      def full?
        (0...N).reduce(false) do |result, i|
          result || taken
            .select(&.[A].== i)
            .size == N
        end
      end
    end

    class Diagonal(K) < WinCheck
      def full?
        taken
          .select { |f| K.call(f) }
          .size == N
      end

      class Main
        def self.call(f)
          f[0] == f[1]
        end
      end

      class Back
        def self.call(f)
          f[0] + f[1] == N - 1
        end
      end
    end
  end
end
