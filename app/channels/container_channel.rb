class ContainerChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "container_logs_#{params[:id]}"
    puts "Subscribed to container logs channel for container #{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def fetch_logs(data)
    container = Container.find(data['id'])
    StreamContainerLogsJob.perform_later(container)
  end

  def receive(data)
    puts "############################################"
    puts "Received data: #{data}"
    # ActionCable.server.broadcast("container_logs_#{params[:id]}", { data: data })
  end
end
