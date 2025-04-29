require 'net/http'
require 'json'
require 'logger'

class BibleService
  def initialize
    @base_url = "http://#{ENV['SWORD_ENGINE_HOST']}:#{ENV['SWORD_ENGINE_PORT']}"
    Rails.logger.debug "BibleService initialized with base URL: #{@base_url}"
  end

  def get_books
    response = make_request('/books')
    Rails.logger.debug "Books response code: #{response.code}"
    Rails.logger.debug "Books response body: #{response.body}"
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      Rails.logger.debug "Parsed books response: #{parsed_response.inspect}"
      parsed_response['books']
    else
      Rails.logger.error "Failed to get books: #{response.code} - #{response.body}"
      []
    end
  end

  def get_versions
    response = make_request('/versions')
    Rails.logger.debug "Versions response code: #{response.code}"
    Rails.logger.debug "Versions response body: #{response.body}"
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      Rails.logger.debug "Parsed versions response: #{parsed_response.inspect}"
      parsed_response['versions']
    else
      Rails.logger.error "Failed to get versions: #{response.code} - #{response.body}"
      []
    end
  end

  def get_chapters(book_id)
    response = make_request("/books/#{book_id}/chapters")
    Rails.logger.debug "Chapters response code: #{response.code}"
    Rails.logger.debug "Chapters response body: #{response.body}"
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      Rails.logger.debug "Parsed chapters response: #{parsed_response.inspect}"
      parsed_response['chapters']
    else
      Rails.logger.error "Failed to get chapters: #{response.code} - #{response.body}"
      []
    end
  end

  def get_verses(book_id, chapter_id)
    response = make_request("/books/#{book_id}/chapters/#{chapter_id}/verses")
    Rails.logger.debug "Verses response code: #{response.code}"
    Rails.logger.debug "Verses response body: #{response.body}"
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)
      Rails.logger.debug "Parsed verses response: #{parsed_response.inspect}"
      parsed_response['verses']
    else
      Rails.logger.error "Failed to get verses: #{response.code} - #{response.body}"
      []
    end
  end

  private

  def make_request(path)
    uri = URI("#{@base_url}#{path}")
    Rails.logger.debug "Making request to: #{uri}"
    begin
      response = Net::HTTP.get_response(uri)
      Rails.logger.debug "Response from #{uri}: #{response.code} #{response.message}"
      response
    rescue => e
      Rails.logger.error "Request failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      OpenStruct.new(code: 500, body: e.message, is_a?: ->(_) { false })
    end
  end
end 