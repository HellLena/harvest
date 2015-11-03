class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'application'
  require 'csv'

  def index

    @group_by_pollen = {}
    @group_by_day = {}
    @group_by_bees = {}

    csv_text = File.read('db/pollens.csv')
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      pollen_id = row['id']
      @group_by_pollen[pollen_id] = {}
      @group_by_pollen[pollen_id]['name'] = row['name']
      @group_by_pollen[pollen_id]['sugar_per_mg'] = row['sugar_per_mg'].to_i
    end

    csv_text = File.read('db/harvest.csv')
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      pollen_id = row['pollen_id']

      # prevent situation if there is no such pollen in pollens.csv
      @group_by_pollen[pollen_id] = {} if @group_by_pollen[pollen_id].nil?
      sugar_per_mg = @group_by_pollen[pollen_id]['sugar_per_mg']
      sugar_per_mg.nil? ? sugar = 0 : sugar = row['miligrams_harvested'].to_f * sugar_per_mg

      @group_by_pollen[pollen_id] = {} if @group_by_pollen[pollen_id].nil?
      @group_by_pollen[pollen_id]['sugar'] = 0 if @group_by_pollen[pollen_id]['sugar'].nil?
      @group_by_pollen[pollen_id]['sugar'] += sugar
      @group_by_pollen[pollen_id]['count'] = 0 if @group_by_pollen[pollen_id]['count'].nil?
      @group_by_pollen[pollen_id]['count'] += 1

      day = row['day']
      @group_by_day[day] = 0 if @group_by_day[day].nil?
      @group_by_day[day] += sugar

      bee = row['bee_id']
      @group_by_bees[bee] = 0 if @group_by_bees[bee].nil?
      @group_by_bees[bee] += sugar
    end

    days = @group_by_day.length
    @group_by_bees.each do |bee, sugar|
      @group_by_bees[bee] = sugar/days
    end

  end

end
