class HomeController < ApplicationController

  def home
    Keen.publish("Homepage Visits",
      { 
        visitor_city: request.location.data["city"],
        visitor_state: request.location.data["region_name"],
        visitor_country: request.location.data["country_name"],
        timestamp: DateTime.now.to_date,
        day: DateTime.now.to_date.strftime("%A, %B %d"),
        hour: DateTime.now.strftime('%H'),
      }
    )
  end
end
