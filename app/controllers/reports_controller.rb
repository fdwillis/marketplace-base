class ReportsController < ApplicationController
  before_filter :authenticate_user!
  def index
    if current_user.account_approved && !current_user.roles.nil? || current_user.admin? 
      #Column Chart
        #Data
          @donation_revenue = User.donation_revenue_this_year(current_user.id)
        #Chart
          @column = column_chart
      @bar = bar_chart
      @pie = pie_chart
      @area = area_chart
      @funnel = funnel_chart

    else
      redirect_to plans_path
      flash[:error] = "You dont have permission to access reports. You must signup"
      return
    end
  end

private

  def column_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Donation Revenue This Year")
      f.xAxis(:categories => Date::MONTHNAMES.slice(1..12))

      f.series(:name => "Revenue", :yAxis => 0, :data => @donation_revenue.map{|d| (d["value"].to_f / 100)})

      f.yAxis(title: {:text => "Dollars"} )

      f.chart(type: "column")
    end
  end
  
  def bar_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.title(:text => "Population vs GDP For 5 Big Countries [2009]")
      f.xAxis(:categories => ["United States", "Japan", "China", "Germany", "France"])

      f.series(:name => "GDP in Bill", :yAxis => 0, :data => [100, 90, 100, 100, 100])
      f.series(:name => "Pop in Mill", :yAxis => 0, :data => [110, 100, 95, 99, 97])

      f.yAxis(title: {:text => "View Count"} )

      f.chart(type: "bar")
    end
  end

  def pie_chart
    LazyHighCharts::HighChart.new('pie') do |f|
          f.chart({:defaultSeriesType=>"pie"} )
          series = {
                   :type=> 'pie',
                   :name=> 'Browser share',
                   :data=> [
                      ['Firefox',   45.0],
                      ['IE',       26.8],
                      {
                         :name=> 'Chrome',    
                         :y=> 12.8,
                         :sliced=> true,
                         :selected=> true
                      },
                      ['Safari',    8.5],
                      ['Opera',     6.2],
                      ['Others',   0.7]
                   ]
          }
          f.series(series)
          f.legend(:layout=> 'vertical',:style=> {:left=> 'auto', :bottom=> 'auto',:right=> '50px',:top=> '100px'}, allowPointSelect: true) 
    end
  end

  def area_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.chart(type: 'area')
      f.title(text: "Home Page Views This Week")
      f.series(name: "Bye",data: [
                ['Visits',   700],
                ['Downloads',       900],
            ])
      f.series(name: "Hi",data: [
                ['Visits',   900],
                ['Downloads',       700],
            ])
      f.series(name: "hi",data: [
                ['Visits',   700],
                ['Downloads', 200],
            ])
      f.yAxis(title: {text: "View Count"})
      f.xAxis(type: 'datetime', categories: @d)
      f.tooltip(shared: true)
      f.legend(enabled: false)
    end
  end

  def funnel_chart
    LazyHighCharts::HighChart.new('graph') do |f|
      f.chart(type: 'funnel', marginRight: 100)
      f.title(text: "Conversion/Campaign/Sales Funnel", x: -50)
      f.series({
            name: 'Unique users',
            data: [
                ['Visits',   15654],
                ['Downloads',       4064],
                ['Requested Price List', 1987],
                ['Invoice sent',    976],
                ['Finalized',    946]
            ]
        })
      f.plotOptions(
        series:{
          dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b> ({point.y:,.0f})',
                    softConnector: false
                },
                neckWidth: '30%',
                neckHeight: '25%'
          })
    end
  end
end