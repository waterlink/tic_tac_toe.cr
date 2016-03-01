require "./spec_helper"
require "../src/game"

macro game_over(g1, g2, g3, over)
  {% game = [g1, g2, g3] %}

  expect(Game.from({{game.argify}}).over?)
    .to eq({{over}})
end

macro game(g1, g2, g3, *expectations)
  {% game = [g1, g2, g3] %}
  game = Game.from({{game.argify}})

  {% for expectation in expectations %}
    {{expectation}}
  {% end %}
end

macro transform(g1, g2, g3, transformation, e1, e2, e3, expectation = nil)
  {% game = [g1, g2, g3] %}
  {% expected = [e1, e2, e3] %}

  game = Game.from({{game.argify}})
  %expected = Game.from({{expected.argify}})
  game = {{transformation}}

  expect(game).to eq(%expected)
  {{expectation}}
end

module TicTacToe
  Spec2.describe Game do
    let(empty) { [] of Game::Field }

    it "is possible to create game state with nice macro" do
      expect(
        Game.from(
          xxo,
          o_x,
          o__,
        )
      ).to eq(
        Game.new(
          fields: [{1, 1}, {2, 1}, {2, 2}],
          first: [{0, 0}, {0, 1}, {1, 2}],
          second: [{0, 2}, {1, 0}, {2, 0}],
        )
      )

      expect(
        Game.from(
          xxo,
          oox,
          xox,
        )
      ).to eq(
        Game.new(
          fields: empty,
          first: [{0, 0}, {0, 1}, {1, 2}, {2, 0}, {2, 2}],
          second: [{0, 2}, {1, 0}, {1, 1}, {2, 1}],
        )
      )
    end

    it "is over when all fields are taken" do
      game_over(
        xxo,
        oox,
        xox,
        true
      )
    end

    it "is not over when there are some fields left" do
      game_over(
        xxo,
        oox,
        xo_,
        false,
      )
    end

    it "is over when all fields in a column are taken by a player" do
      game_over(
        x_o,
        xo_,
        x__,
        true,
      )

      game_over(
        _xo,
        ox_,
        _x_,
        true,
      )

      game_over(
        _ox,
        o_x,
        __x,
        true,
      )

      game_over(
        o_x,
        ox_,
        o__,
        true,
      )

      game_over(
        _ox,
        xo_,
        _o_,
        true,
      )

      game_over(
        _xo,
        x_o,
        __o,
        true,
      )
    end

    it "is over when all fields in a row are taken by a player" do
      game_over(
        xxx,
        o_o,
        ___,
        true,
      )

      game_over(
        o_o,
        xxx,
        ___,
        true,
      )

      game_over(
        o_o,
        ___,
        xxx,
        true,
      )

      game_over(
        ooo,
        x_x,
        ___,
        true,
      )

      game_over(
        x_x,
        ooo,
        ___,
        true,
      )

      game_over(
        x_x,
        ___,
        ooo,
        true,
      )
    end

    it "is over when all fields in a diagonal are taken by a player" do
      game_over(
        x_o,
        _xo,
        __x,
        true,
      )

      game_over(
        o_x,
        ox_,
        x__,
        true,
      )

      game_over(
        o_x,
        _ox,
        __o,
        true,
      )

      game_over(
        x_o,
        xo_,
        o__,
        true,
      )
    end

    describe "a player" do
      it "can take a field if it is not taken" do
        transform(
          ___,
          ___,
          ___,

          game.take({0, 0}),

          x__,
          ___,
          ___,

          expect(game.notice).to eq(""),
        )

        transform(
          ___,
          ___,
          ___,

          game.take({1, 2}),

          ___,
          __x,
          ___,

          expect(game.notice).to eq(""),
        )

        transform(
          ___,
          ___,
          _x_,

          game.take({1, 2}),

          ___,
          __o,
          _x_,

          expect(game.notice).to eq(""),
        )

        transform(
          ___,
          o__,
          _x_,

          game.take({1, 2}),

          ___,
          o_x,
          _x_,

          expect(game.notice).to eq(""),
        )

        transform(
          ___,
          o_x,
          _x_,

          game.take({1, 1}),

          ___,
          oox,
          _x_,

          expect(game.notice).to eq(""),
        )
      end

      it "is not possible to take already taken field" do
        transform(
          ___,
          o_x,
          _x_,

          game.take({1, 0}),

          ___,
          o_x,
          _x_,

          expect(game.notice)
            .to eq("Field {1, 0} is already taken"),
        )
      end

      it "is not possible to take field when game is over" do
        transform(
          _x_,
          ooo,
          x_x,

          game.take({0, 2}),

          _x_,
          ooo,
          x_x,

          expect(game.notice)
            .to eq("Game over. Second player won."),
        )
      end
    end

    describe "#notice & #outcome" do
      it "shows game over and outcome message" do
        game(
          xxx,
          ___,
          o_o,

          expect(game.outcome).to(eq :first_won),
          expect(game.notice)
            .to eq("Game over. First player won."),
        )

        game(
          _x_,
          _x_,
          oxo,

          expect(game.outcome).to(eq :first_won),
          expect(game.notice)
            .to eq("Game over. First player won."),
        )

        game(
          xo_,
          _x_,
          o_x,

          expect(game.outcome).to(eq :first_won),
          expect(game.notice)
            .to eq("Game over. First player won."),
        )

        game(
          _ox,
          _x_,
          x_o,

          expect(game.outcome).to(eq :first_won),
          expect(game.notice)
            .to eq("Game over. First player won."),
        )

        game(
          x_x,
          ___,
          ooo,

          expect(game.outcome).to(eq :second_won),
          expect(game.notice)
            .to eq("Game over. Second player won."),
        )

        game(
          _o_,
          _o_,
          xox,

          expect(game.outcome).to(eq :second_won),
          expect(game.notice)
            .to eq("Game over. Second player won."),
        )

        game(
          ox_,
          _o_,
          x_o,

          expect(game.outcome).to(eq :second_won),
          expect(game.notice)
            .to eq("Game over. Second player won."),
        )

        game(
          _xo,
          _o_,
          o_x,

          expect(game.outcome).to(eq :second_won),
          expect(game.notice)
            .to eq("Game over. Second player won."),
        )

        game(
          oxx,
          xoo,
          xox,

          expect(game.outcome).to(eq :draw),
          expect(game.notice)
            .to eq("Game over. Draw."),
        )
      end

      it "does not show outcome when game is ongoing" do
        game(
          ___,
          _x_,
          o__,

          expect(game.outcome).to(eq :ongoing),
          expect(game.notice).to eq(""),
        )
      end
    end
  end
end
