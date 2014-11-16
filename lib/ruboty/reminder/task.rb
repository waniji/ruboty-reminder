module Ruboty
  module Reminder
    class Task
      NAMESPACE = 'reminder'

      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def start(robot)
        current_time = Time.now
        target = Time.new(current_time.year, current_time.month, current_time.day, hash[:hour], hash[:min], 0)

        wait_time =
          if target.to_i - current_time.to_i < 0
            (target + 24*60*60).to_i - current_time.to_i
          else
            target.to_i - current_time.to_i
          end

        Thread.start do
          sleep(wait_time)
          Message.new(
            hash.except(:id, :body, :hour, :min).merge(robot: robot)
          ).reply(hash[:body])
          robot.brain.data[NAMESPACE].delete(hash[:id])
        end
      end
    end
  end
end
