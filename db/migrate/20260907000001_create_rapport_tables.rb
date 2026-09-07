class CreateRapportTables < ActiveRecord::Migration[8.0]
  def change
    create_table :rapport_companies do |t|
      t.string :name, null: false
      t.string :domain
      t.bigint :account_id
      t.string :source, null: false, default: "operator"
      t.timestamps
    end
    add_index :rapport_companies, :account_id, unique: true
    add_index :rapport_companies, :domain

    create_table :rapport_contacts do |t|
      t.string :name
      t.string :job_title
      t.string :phone
      t.string :avatar_url
      t.string :stage, null: false, default: "lead"
      t.string :manual_stage
      t.bigint :user_id
      t.references :company, foreign_key: { to_table: :rapport_companies }
      t.jsonb :custom_fields, null: false, default: {}
      t.datetime :last_touched_at
      t.integer :reminder_cadence_days
      t.datetime :last_entry_at
      t.string :source, null: false, default: "operator"
      t.timestamps
    end
    add_index :rapport_contacts, :user_id, unique: true
    add_index :rapport_contacts, :stage
    add_index :rapport_contacts, :last_entry_at

    create_table :rapport_email_addresses do |t|
      t.references :contact, null: false, foreign_key: { to_table: :rapport_contacts }
      t.string :address, null: false
      t.boolean :primary, null: false, default: false
      t.timestamps
    end
    add_index :rapport_email_addresses, :address, unique: true

    create_table :rapport_tags do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :rapport_tags, :name, unique: true

    create_table :rapport_taggings do |t|
      t.references :contact, null: false, foreign_key: { to_table: :rapport_contacts }
      t.references :tag, null: false, foreign_key: { to_table: :rapport_tags }
      t.timestamps
    end
    add_index :rapport_taggings, [ :contact_id, :tag_id ], unique: true

    create_table :rapport_notes do |t|
      t.references :contact, null: false, foreign_key: { to_table: :rapport_contacts }
      t.text :body, null: false
      t.timestamps
    end

    create_table :rapport_interactions do |t|
      t.string :kind, null: false
      t.datetime :occurred_at, null: false
      t.text :body
      t.timestamps
    end

    create_table :rapport_interaction_participants do |t|
      t.references :interaction, null: false, foreign_key: { to_table: :rapport_interactions }
      t.references :contact, null: false, foreign_key: { to_table: :rapport_contacts }
      t.timestamps
    end
    add_index :rapport_interaction_participants, [ :interaction_id, :contact_id ], unique: true, name: "index_rapport_participants_on_interaction_and_contact"

    create_table :rapport_timeline_entries do |t|
      t.references :contact, null: false, foreign_key: { to_table: :rapport_contacts }
      t.string :kind, null: false
      t.datetime :occurred_at, null: false
      t.string :title, null: false
      t.jsonb :payload, null: false, default: {}
      t.string :source_type, null: false
      t.string :source_id, null: false
      t.string :status
      t.timestamps
    end
    add_index :rapport_timeline_entries, [ :contact_id, :source_type, :source_id ], unique: true, name: "index_rapport_timeline_entries_on_contact_and_source"
    add_index :rapport_timeline_entries, [ :contact_id, :occurred_at ]
  end
end
