require 'clockwork'
require './config/boot'
require './config/environment'
module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(1.week, 'Make recipients', at: => 'Friday 00:00') {
    `rake tasks:recipients`
  }

  every(1.week, 'Make recipients', at: => 'Friday 12:00') {
    `rake tasks:payout`
  }
end