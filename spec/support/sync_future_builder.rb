# frozen_string_literal: true

# A synchronous future builder for tests. It returns an object responding to `value`.
SyncFutureBuilder = lambda do |_pool, &block|
  Struct.new(:value).new(block.call)
end
