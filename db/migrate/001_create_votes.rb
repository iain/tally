# frozen_string_literal: true

Sequel.migration do

  change do
    create_table :votes do
      primary_key :id
      String  :term,     null: false
      String  :team,     null: false
      String  :user,     null: false
      String  :channel,  null: false
      Time    :time,     null: false
      Integer :score,    null: false
    end
  end

end
