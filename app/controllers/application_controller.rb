class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  layout 'application'
  require 'csv'

  def index

    pollens_csv = File.read('db/pollens.csv')
    harvest_csv = File.read('db/harvest.csv')

    pollens_csv = CSV.parse(pollens_csv, :headers => true)
    harvest_csv = CSV.parse(harvest_csv, :headers => true)

    gather_data pollens_csv, harvest_csv

  end

  def test_files

    pollens_csv = get_data params['pollens_file']
    harvest_csv = get_data params['harvest_file']

    pollens_csv = CSV.parse(pollens_csv, :headers => true)
    harvest_csv = CSV.parse(harvest_csv, :headers => true)

    isPollenFile = isPollenFile(pollens_csv[0])
    isHarvestFile = isHarvestFile(harvest_csv[0])

    if isPollenFile && isHarvestFile
      gather_data pollens_csv, harvest_csv
      @file_error = {}
    else
      @file_error = {"isPollenFile" => isPollenFile, "isHarvestFile" => isHarvestFile}
    end

  end

  def isPollenFile pollens_row
    headers = ["id", "name", "sugar_per_mg"]
    row = strip_headers(pollens_row)
    headers.each do |header|
      return false unless row.has_key?(header)
    end
    true
  end

  def isHarvestFile harvest_row
    headers = ["bee_id", "day", "pollen_id", "miligrams_harvested"]
    row = strip_headers(harvest_row)
    headers.each do |header|
      return false unless row.has_key?(header)
    end
    true
  end

  def strip_headers unstriped_row
    row = {}
    unstriped_row.each{|k,v| row[k.strip] = v }
    row
  end

  def get_data file_data
    csv = nil
    if file_data.respond_to?(:read)
      csv = file_data.read
    elsif file_data.respond_to?(:path)
      csv = File.read(file_data.path)
    else
      logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
    end
    csv
  end

  def gather_data pollens_csv, harvest_csv
    @group_by_pollen = {}
    @group_by_harvest = {'days' => {}, 'bees' => {}}

    pollens_csv.each do |unstriped_row|
      row = strip_headers(unstriped_row)

      pollen_id = row['id']
      next if pollen_id.nil?

      @group_by_pollen[pollen_id] = {}
      @group_by_pollen[pollen_id]['name'] = row['name']
      @group_by_pollen[pollen_id]['sugar_per_mg'] = row['sugar_per_mg'].to_i
      # prevent situation if there is no such pollen in harvestcsv
      @group_by_pollen[pollen_id]['sugar'] = 0
      @group_by_pollen[pollen_id]['count'] = 0
    end

    harvest_csv.each do |unstriped_row|
      row = strip_headers(unstriped_row)

      pollen_id = row['pollen_id']
      next if pollen_id.nil?

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
      @group_by_harvest['days'][day] = 0 if @group_by_harvest['days'][day].nil?
      @group_by_harvest['days'][day] += sugar

      bee = row['bee_id'].to_i
      @group_by_harvest['bees'][bee] = 0 if @group_by_harvest['bees'][bee].nil?
      @group_by_harvest['bees'][bee] += sugar
    end

    days = @group_by_harvest['days'].length
    @group_by_harvest['bees'].each do |bee, sugar|
      @group_by_harvest['bees'][bee] = sugar/days
    end
  end

end
