module Ruboty
  module Reminder
    class Task
      NAMESPACE = 'reminder'

      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def start(robot)
        current_time = Time.new.to_i
        target_time = Time.new(
          Time.now.year,
          Time.now.month,
          Time.now.day,
          hash[:hour],
          hash[:min],
          0
        ).to_i

        wait_time =
          if target_time - current_time < 0
            (target_time + 24*60*60) - current_time
          else
            target_time - current_time
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
