class StreamContainerLogsJob < ApplicationJob
  queue_as :default

  def perform(container)
    last_timestamp = container.log_timestamp
    logs = []
    if last_timestamp.zero? || last_timestamp.nil?
      logs = container.docker_container&.streaming_logs(stdout: true, stderr: true, tail: 100)
    else
      logs = container.docker_container&.streaming_logs(stdout: true, stderr: true, since: last_timestamp, tail: 100)
    end

    unless logs&.empty? || logs.nil?
      logs_as_array = logs.split("\n")
      ActionCable.server.broadcast("container_logs_#{container.id}", { output: logs_as_array })
      container.set_log_timestamp
    end
  end
end
