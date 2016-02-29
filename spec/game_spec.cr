require "./spec_helper"
require "../src/game"

module TicTacToe
  Spec2.describe Game do
    let(empty) { [] of {Int32, Int32} }

    it "is over when all fields are taken" do
      # xxo
      # oox
      # xox
      game = Game.new(
        fields: empty,
        first: [{0, 0}, {0, 1}, {2, 0}, {1, 2}, {2, 2}],
        second: [{1, 1}, {0, 2}, {1, 0}, {2, 1}],
      )

      expect(game.over?).to eq(true)
    end

    # TODO: write more tests
  end
end
