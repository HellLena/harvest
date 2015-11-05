require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get test_files" do
    post :test_files, {:pollens_file => fixture_file_upload('db/pollens.csv','text/csv'), :harvest_file => fixture_file_upload('db/harvest.csv','text/csv'), :format => 'js'}
    assert_response :success, "Fail upload success files"
    assert assigns(:file_error) == {}, "Unexpected flash message for success files"

    post :test_files, {:pollens_file => fixture_file_upload('db/harvest.csv','text/csv'), :harvest_file => fixture_file_upload('db/pollens.csv','text/csv'), :format => 'js'}
    assert_response :success, "Fail upload both corrupted files"
    assert assigns(:file_error) == {"isPollenFile" => false, "isHarvestFile" => false}, "Unexpected flash message for both corrupted files"

    post :test_files, {:pollens_file => fixture_file_upload('db/harvest.csv','text/csv'), :harvest_file => fixture_file_upload('db/harvest.csv','text/csv'), :format => 'js'}
    assert_response :success, "Fail upload pollens corrupted file"
    assert assigns(:file_error) == {"isPollenFile" => false, "isHarvestFile" => true}, "Unexpected flash message for pollens corrupted file"

    post :test_files, {:pollens_file => fixture_file_upload('db/pollens.csv','text/csv'), :harvest_file => fixture_file_upload('db/pollens.csv','text/csv'), :format => 'js'}
    assert_response :success, "Fail upload harvest corrupted file"
    assert assigns(:file_error) == {"isPollenFile" => true, "isHarvestFile" => false}, "Unexpected flash message for harvest corrupted file"

    post :test_files, {:format => 'js'}
    assert_response :success, "Fail upload nil files"
    assert assigns(:file_error) == {"isNotCSVFile" => true}, "Unexpected flash message for nil files"

    fixture_path = Rails.root.join("test", "fixtures")
    post :test_files, {:pollens_file => fixture_file_upload(fixture_path + 'pollens2.xlsx','text/csv'), :harvest_file => fixture_file_upload(fixture_path + 'harvest2.xlsx','text/csv'), :format => 'js'}
    assert_response :success, "Fail upload not .csv files"
    assert assigns(:file_error) == {"isNotCSVFile" => true}, "Unexpected flash message for not .csv files"
  end

end