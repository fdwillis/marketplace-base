class HomeController < ApplicationController

  def home
    #Track For Admin
    Keen.publish("Homepage Visits", { 
      visitor_city: request.location.data["city"],
      visitor_state: request.location.data["region_name"],
      visitor_country: request.location.data["country_name"],
      date: DateTime.now.to_date.strftime("%A, %B #{DateTime.now.to_date.day.ordinalize}"),
      time: DateTime.now.strftime('%I:%M%p'),
    })
  end
end
