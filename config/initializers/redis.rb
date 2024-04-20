# Require the Redis gem
require 'redis'

# Set up a global Redis client
$redis = Redis.new(url: ENV['REDIS_URL'] || 'redis://localhost:6379')
