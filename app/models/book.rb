# frozen_string_literal: true

class Book < ApplicationRecord
  has_many :chapters, dependent: :destroy

  validates :name, presence: true
  validates :abbreviation, presence: true, uniqueness: true
  validates :number, presence: true, uniqueness: true

  # Cache SWORD Engine responses
  def self.cached_books
    Rails.cache.fetch('sword_engine_books', expires_in: 1.hour) do
      SwordEngineService.new.get_books
    end
  end
end 