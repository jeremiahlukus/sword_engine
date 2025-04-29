class BibleController < ApplicationController
  def index
    @books = fetch_books
    @versions = fetch_versions
    Rails.logger.debug "Index action - Books: #{@books.inspect}"
    Rails.logger.debug "Index action - Versions: #{@versions.inspect}"
  rescue => e
    Rails.logger.error "Error in BibleController#index: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:error] = "Error loading Bible data. Please try again later."
    @books = []
    @versions = []
  end

  def show
    @book = params[:id]
    Rails.logger.debug "Show action - Book ID: #{@book}"
    @chapters = fetch_chapters(@book)
    Rails.logger.debug "Show action - Chapters: #{@chapters.inspect}"
    @chapter = params[:chapter]
    Rails.logger.debug "Show action - Selected Chapter: #{@chapter}"
    @verses = @chapter.present? ? fetch_verses(@book, @chapter) : []
    Rails.logger.debug "Show action - Verses: #{@verses.inspect}"
  rescue => e
    Rails.logger.error "Error in BibleController#show: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    flash.now[:error] = "Error loading chapters. Please try again later."
    @chapters = []
    @verses = []
  end

  private

  def fetch_books
    Rails.logger.debug "Fetching books..."
    books = BibleService.new.get_books
    Rails.logger.debug "Fetched books response: #{books.inspect}"
    books
  end

  def fetch_versions
    Rails.logger.debug "Fetching versions..."
    versions = BibleService.new.get_versions
    Rails.logger.debug "Fetched versions response: #{versions.inspect}"
    versions
  end

  def fetch_chapters(book_id)
    Rails.logger.debug "Fetching chapters for book: #{book_id}"
    chapters = BibleService.new.get_chapters(book_id)
    Rails.logger.debug "Fetched chapters response: #{chapters.inspect}"
    chapters
  end

  def fetch_verses(book_id, chapter_id)
    Rails.logger.debug "Fetching verses for book: #{book_id}, chapter: #{chapter_id}"
    verses = BibleService.new.get_verses(book_id, chapter_id)
    Rails.logger.debug "Fetched verses response: #{verses.inspect}"
    verses
  end
end 