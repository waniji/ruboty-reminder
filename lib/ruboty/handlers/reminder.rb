module Ruboty
  module Handlers
    class Reminder < Base
      NAMESPACE = 'reminder'

      on /add reminder (?<hh>\d{2}):(?<mm>\d{2}) (?<reminder>.+)/, name: 'add', description: 'Add a reminder'
      on /delete reminder (?<id>.+)/, name: 'delete', description: 'Delete a reminder'
      on /list reminders\z/, name: 'list', description: 'Show all reminders'

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
            body: message[:reminder],
            hour: hour,
            min: min
          )
        )
        task.start(robot)
        message.reply("Reminder #{task.hash[:id]} is created.")

        # Insert to the brain
        reminders[task.hash[:id]] = task.hash
      end

      def delete(message)
        if reminders.delete(message[:id].to_i)
          message.reply("Reminder #{message[:id]} is deleted.")
        else
          message.reply("Reminder #{message[:id]} is not found.")
        end
      end

      def list(message)
        if reminders.empty?
          message.reply("The reminder doesn't exist.")
        else
          reminder_list = reminders.map do |id, hash|
            "#{id}: #{'%02d' % hash[:hour]}:#{'%02d' % hash[:min]} -> #{hash[:body]}"
          end.join("\n")
          message.reply(reminder_list, code: true)
        end
      end

      def restart
        reminders.each do |id, hash|
          task = Ruboty::Reminder::Task.new(hash)
          task.start(robot)
        end
      end

      def reminders
        robot.brain.data[NAMESPACE] ||= {}
      end

      def generate_id
        loop do
          id = rand(1000)
          return id unless reminders.has_key?(id)
        end
      end
    end
  end
end

