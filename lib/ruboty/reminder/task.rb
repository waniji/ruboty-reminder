module Ruboty
  module Reminder
    class Task
      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def start(robot)
        wait_time = hash[:unixtime] - Time.now.to_i

        Thread.start do
          sleep(wait_time)
          Message.new(
            hash.except(:id, :body, :year, :month, :day, :hour, :min, :unixtime).merge(robot: robot)
          ).reply(hash[:body])
          robot.brain.data[NAMESPACE].delete(hash[:id])
        end
      end
    end
  end
end
