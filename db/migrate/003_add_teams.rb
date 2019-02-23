# frozen_string_literal: true

Sequel.migration do

  change do
    run %(
      CREATE OR REPLACE FUNCTION automatic_updated_at()
      RETURNS TRIGGER AS $$
      BEGIN
        NEW.updated_at = now();
        RETURN NEW;
      END;
      $$ language 'plpgsql';
    )

    create_table :teams do

      primary_key :id

      column :team_id,            "text",  null: false
      column :user_access_token,  "text",  null: false
      column :bot_user_id,        "text",  null: false
      column :bot_access_token,   "text",  null: false

      column :created_at, "timestamp without time zone", null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, "timestamp without time zone", null: false, default: Sequel::CURRENT_TIMESTAMP

      index [:team_id], unique: true
    end

    run %{CREATE TRIGGER teams_automatic_updated_at BEFORE UPDATE ON teams FOR EACH ROW EXECUTE PROCEDURE automatic_updated_at()}
  end

end
