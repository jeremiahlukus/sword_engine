# frozen_string_literal: true

require 'net/http'
require 'json'

class SwordEngineService
  class Error < StandardError; end

  def initialize
    @host = ENV.fetch('SWORD_ENGINE_HOST', 'localhost')
    @port = ENV.fetch('SWORD_ENGINE_PORT', '8080').to_i
    @base_url = "http://#{@host}:#{@port}"
  end

  def health_check
    response = get('/health')
    response.code == '200'
  rescue StandardError
    false
  end

  def search(query, options = {})
    params = { query: query }.merge(options)
    response = get('/search', params)
    handle_response(response)
  end

  def get_books
    response = get('/books')
    handle_response(response)
  end

  def get_chapters(book_id)
    response = get("/books/#{book_id}/chapters")
    handle_response(response)
  end

  def get_verses(book_id, chapter_id)
    response = get("/books/#{book_id}/chapters/#{chapter_id}/verses")
    handle_response(response)
  end

  private

  def get(path, params = {})
    uri = URI("#{@base_url}#{path}")
    uri.query = URI.encode_www_form(params) if params.any?
    
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    else
      raise Error, "SWORD Engine API error: #{response.code} - #{response.body}"
    end
  end
end 