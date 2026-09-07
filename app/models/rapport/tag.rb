module Rapport
  class Tag < ApplicationRecord
    has_many :taggings, dependent: :destroy
    has_many :contacts, through: :taggings

    normalizes :name, with: ->(n) { n.to_s.strip.downcase }

    validates :name, presence: true, uniqueness: true

    def self.named(name)
      find_or_create_by!(name: name.to_s.strip.downcase)
    end
  end
end
