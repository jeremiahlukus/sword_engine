# frozen_string_literal: true

module Api
  module V1
    class BooksController < ApplicationController
      def index
        books = Book.cached_books
        render json: { books: books }
      end

      def show
        book = Book.find_by!(abbreviation: params[:id])
        render json: { book: book }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Book not found' }, status: :not_found
      end
    end
  end
end 