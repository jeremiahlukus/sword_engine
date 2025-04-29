# frozen_string_literal: true

module Api
  module V1
    class HealthController < ApplicationController
      def index
        sword_engine = SwordEngineService.new
        status = {
          sword_engine: sword_engine.health_check,
          redis: redis_healthy?,
          database: database_healthy?
        }
        
        render json: { status: status }, status: status.values.all? ? :ok : :service_unavailable
      end

      private

      def redis_healthy?
        Redis.new(url: ENV['REDIS_URL']).ping == 'PONG'
      rescue StandardError
        false
      end

      def database_healthy?
        ActiveRecord::Base.connection.active?
      rescue StandardError
        false
      end
    end
  end
end 