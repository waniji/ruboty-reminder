module Ruboty
  module Reminder
    class Task
      NAMESPACE = 'reminder'

      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def start(robot)
        time_now = Time.now

        current_unixtime = time_now.to_i
        target_unixtime = Time.new(
          time_now.year,
          time_now.month,
          time_now.day,
          hash[:hour],
          hash[:min],
          0
        ).to_i

        wait_time =
          if target_unixtime - current_unixtime < 0
            (target_unixtime + 24*60*60) - current_unixtime
          else
            target_unixtime - current_unixtime
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
