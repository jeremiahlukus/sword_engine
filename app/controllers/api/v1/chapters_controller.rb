# frozen_string_literal: true

module Api
  module V1
    class ChaptersController < ApplicationController
      def index
        book = Book.find_by!(abbreviation: params[:book_id])
        chapters = Chapter.cached_chapters(book.id)
        render json: { chapters: chapters }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Book not found' }, status: :not_found
      end

      def show
        book = Book.find_by!(abbreviation: params[:book_id])
        chapter = Chapter.find_by!(book_id: book.id, number: params[:id])
        render json: { chapter: chapter }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Chapter not found' }, status: :not_found
      end
    end
  end
end 