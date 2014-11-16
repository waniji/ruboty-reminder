module Ruboty
  module Handlers
    class Reminder < Base
      NAMESPACE = 'reminder'

      on /add task (?<hh>\d{2}):(?<mm>\d{2}) (?<task>.+)/, name: 'add', description: 'Add a task'
      on /delete task (?<id>.+)/, name: 'delete', description: 'Delete a task'
      on /list tasks/, name: 'list', description: 'Show all reminders'

      def initialize(*args)
        super
        restart
      end

      def add(message)
        hour = message[:hh].to_i
        min = message[:mm].to_i

        # Validate
        unless hour >= 0 && hour <= 23 && min >= 0 && min <= 59
          message.reply('Invalid time format.')
          return
        end

        task = Ruboty::Reminder::Task.new(
          message.original.except(:robot).merge(
            id: generate_id,
            body: message[:task],
            hour: hour,
            min: min
          )
        )
        task.start(robot)
        message.reply("Task #{task.hash[:id]} created.")

        # Insert to the brain
        tasks[task.hash[:id]] = task.hash
      end

      def delete(message)
        if tasks.delete(message[:id].to_i)
          message.reply('Deleted.')
        else
          message.reply('Not found.')
        end
      end

      def list(message)
        body =
          if tasks.empty?
            'No task registered.'
          else
            tasks.map do |id, hash|
              "#{id}: #{hash[:hour]}:#{hash[:min]} -> #{hash[:body]}"
            end.join("\n")
          end

        message.reply(body)
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

