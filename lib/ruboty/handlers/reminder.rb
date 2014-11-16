module Ruboty
  module Handlers
    class Reminder < Base
      NAMESPACE = 'reminder'

      on /remind (?<hh>\d{2}):(?<mm>\d{2}) (?<task>.+)/, name: 'remind', description: 'Remind a task'

      def initialize(*args)
        super
        restart
      end

      def remind(message)
        task = Ruboty::Reminder::Task.new(
          message.original.except(:robot).merge(
            id: generate_id,
            body: message[:task],
            hour: message[:hh].to_i,
            min: message[:mm].to_i
          )
        )
        task.start(robot)
        message.reply("Task #{task.hash[:id]} created.")

        # Insert to the brain
        tasks[task.hash[:id]] = task.hash
      end

      def restart
        tasks.each do |id, hash|
          task = Ruboty::Reminder::Task.new(hash)
          task.start(robot)
        end
      end

      def tasks
        robot.brain.data[NAMESPACE] ||= {}
      end

      def generate_id
        loop do
          id = rand(1000)
          return id unless tasks.has_key?(id)
        end
      end
    end
  end
end

