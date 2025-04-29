# frozen_string_literal: true

class Chapter < ApplicationRecord
  belongs_to :book
  has_many :verses, dependent: :destroy

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :book_id, presence: true
  validates :number, uniqueness: { scope: :book_id }

  # Cache SWORD Engine responses
  def self.cached_chapters(book_id)
    Rails.cache.fetch("sword_engine_chapters_#{book_id}", expires_in: 1.hour) do
      SwordEngineService.new.get_chapters(book_id)
    end
  end
end 