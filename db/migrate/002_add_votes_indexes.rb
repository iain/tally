# frozen_string_literal: true

Sequel.migration do

  change do
    add_index :votes, [:term, :team]
  end

end
