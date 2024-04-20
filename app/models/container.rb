class Container < ApplicationRecord
  # Validates docker container name: letters, numbers, hyphens, underscores
  validates :name, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_-]+\z/ }
  after_update { broadcast_update_to "containers" }

  def docker_container
    Docker::Container.get(name)
  rescue Docker::Error::NotFoundError
    nil
  end

  def docker_status
    info = docker_container&.info
    info&.dig("State", "Status")
  rescue Docker::Error::NotFoundError
    "missing"
  end

  def refresh_status
    update(status: docker_status)
  end

  def log_timestamp
    $redis.get("last_log_timestamp_#{id}").to_i
  end

  def set_log_timestamp
    $redis.set("last_log_timestamp_#{id}", Time.now.to_i)
  end

  def reset_log_timestamp
    $redis.del("last_log_timestamp_#{id}")
  end
end
