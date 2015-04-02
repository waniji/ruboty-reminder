module Ruboty
  module Handlers
    class Reminder < Base
      YEAR_RANGE = (2000..2100)
      MONTH_RANGE = (1..12)
      DAY_RANGE = (1..31)
      HOUR_RANGE = (0..23)
      MIN_RANGE = (0..59)

      on /add reminder( (?<year>\d{4})\/(?<month>\d{2})\/(?<day>\d{2}))? (?<hour>\d{2}):(?<min>\d{2}) (?<reminder>.+)/, name: 'add', description: 'Add a reminder'
      on /delete reminder (?<id>.+)/, name: 'delete', description: 'Delete a reminder'
      on /list reminders\z/, name: 'list', description: 'Show all reminders'

      def initialize(*args)
        super
        restart
      end

      def add(message)
        year, month, day =
          # [year, month, day] can be omitted.
          if message[:year] && message[:month] && message[:day]
            [message[:year].to_i, message[:month].to_i, message[:day].to_i]
          else
            now_time = Time.now
            [now_time.year, now_time.month, now_time.day]
          end
        hour = message[:hour].to_i
        min = message[:min].to_i

        unless valid_time?(year, month, day, hour, min)
          message.reply('Invalid time.')
          return
        end

        target_unixtime = Time.new(year, month, day, hour, min, 0).to_i

        if past?(target_unixtime)
          message.reply('Already past.')
          return
        end

        task = Ruboty::Reminder::Task.new(
          message.original.except(:robot).merge(
            id: generate_id,
            body: message[:reminder],
            year: year,
            month: month,
            day: day,
            hour: hour,
            min: min,
            unixtime: target_unixtime
          )
        )
        task.start(robot)
        message.reply("Reminder #{task.hash[:id]} is created.")

        reminders[task.hash[:id]] = task.hash
        running_tasks[task.hash[:id]] = task
      end

      def delete(message)
        id = message[:id].to_i
        if reminders.has_key?(id)
          running_tasks[id].thread.kill
          running_tasks.delete(id)
          reminders.delete(id)
          message.reply("Reminder #{id} is deleted.")
        else
          message.reply("Reminder #{id} is not found.")
        end
      end

      def list(message)
        if reminders.empty?
          message.reply("The reminder doesn't exist.")
        else
          sorted_reminders = reminders.sort_by {|_id, task| task[:unixtime]}

          reminder_list = sorted_reminders.map do |id, task|
            date = "#{task[:year]}/#{'%02d' % task[:month]}/#{'%02d' % task[:day]}"
            time = "#{'%02d' % task[:hour]}:#{'%02d' % task[:min]}"
            "#{id}: #{date} #{time} -> #{task[:body]}"
          end
          message.reply(reminder_list.join("\n"), code: true)
        end
      end

      def restart
        reminders.each do |id, task|
          new_task = Ruboty::Reminder::Task.new(task)
          running_tasks[id] = new_task
          new_task.start(robot)
        end
      end

      def running_tasks
        @running_tasks ||= {}
      end

      def reminders
        robot.brain.data[Ruboty::Reminder::NAMESPACE] ||= {}
      end

      def generate_id
        loop do
          id = rand(1000)
          return id unless reminders.has_key?(id)
        end
      end

      def valid_time?(year, month, day, hour, min)
        YEAR_RANGE.include?(year) &&\
          MONTH_RANGE.include?(month) &&\
          DAY_RANGE.include?(day) &&\
          HOUR_RANGE.include?(hour) &&\
          MIN_RANGE.include?(min)
      end

      def past?(unixtime)
        (unixtime - Time.now.to_i) < 0
      end
    end
  end
end

