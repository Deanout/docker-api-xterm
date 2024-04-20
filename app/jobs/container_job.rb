class ContainerJob < ApplicationJob
  queue_as :default

  def perform(container, action)
    container.docker_container.start if action == :start
    container.docker_container.stop if action == :stop
    container.refresh_status
  end
end
