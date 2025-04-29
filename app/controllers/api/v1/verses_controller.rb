# frozen_string_literal: true

module Api
  module V1
    class VersesController < ApplicationController
      def index
        book = Book.find_by!(abbreviation: params[:book_id])
        chapter = Chapter.find_by!(book_id: book.id, number: params[:chapter_id])
        verses = Verse.cached_verses(book.id, chapter.id)
        render json: { verses: verses }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Book or chapter not found' }, status: :not_found
      end

      def show
        book = Book.find_by!(abbreviation: params[:book_id])
        chapter = Chapter.find_by!(book_id: book.id, number: params[:chapter_id])
        verse = Verse.find_by!(chapter_id: chapter.id, number: params[:id])
        render json: { verse: verse }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Verse not found' }, status: :not_found
      end
    end
  end
end 