# Ruboty::Reminder

Ruboty handler to remind a task.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruboty-reminder'
```

## Usage

```
@ruboty add reminder yyyy/MM/dd HH:mm <reminder>
@ruboty delete reminder <id>
@ruboty list reminders <id>
```

## Example

```
> @ruboty add reminder 07:00 Hi,kaihara!
Reminder 270 is created.
Hi, kaihara!
> @ruboty add reminder 2015/01/01 00:00 Happy New Year!
Reminder 300 is created.
Happy New Year!
```
