# frozen_string_literal: true

class Verse < ApplicationRecord
  belongs_to :chapter

  validates :number, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :text, presence: true
  validates :chapter_id, presence: true
  validates :number, uniqueness: { scope: :chapter_id }

  # Cache SWORD Engine responses
  def self.cached_verses(book_id, chapter_id)
    Rails.cache.fetch("sword_engine_verses_#{book_id}_#{chapter_id}", expires_in: 1.hour) do
      SwordEngineService.new.get_verses(book_id, chapter_id)
    end
  end
end 