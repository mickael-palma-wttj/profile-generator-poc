# frozen_string_literal: true

module ProfileGenerator
  module Interactors
    # Result object for interactor operations
    # Follows Command pattern and provides clear success/failure states
    class Result
      attr_reader :value, :error, :metadata

      def initialize(success:, value: nil, error: nil, metadata: {})
        @success = success
        @value = value
        @error = error
        @metadata = metadata
      end

      def success?
        @success
      end

      def failure?
        !success?
      end

      def self.success(value = nil, metadata = {})
        new(success: true, value: value, metadata: metadata)
      end

      def self.failure(error, metadata = {})
        new(success: false, error: error, metadata: metadata)
      end
    end
  end
end
