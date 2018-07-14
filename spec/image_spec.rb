ENV['RACK_ENV'] = 'test'

require './image'

require 'rspec'
require 'rack/test'

def app
  Sinatra::Application
end

describe "Upload and download" do
  include Rack::Test::Methods

  before(:each) do
    Dir.glob('./images/*').each { |f| File.unlink(f) }
  end

  it "can upload an image" do
    file = File.read(File.dirname(__FILE__) + '/fixtures/files/bacon.jpg')
    post "/images", file: file
    expect(last_response).to be_ok
  end

  it "can download an image that has been uploaded" do
    file = File.read(File.dirname(__FILE__) + '/fixtures/files/bacon.jpg')
    post "/images", file: file

    file_id = JSON.parse(last_response.body)["id"]

    get "/images/#{file_id}"
    expect(last_response).to be_ok
    expect(last_response.media_type).to eq('image/jpeg')
  end

  it "can choose which image to download" do
    first_file = File.read(File.dirname(__FILE__) + '/fixtures/files/bacon.jpg')
    post "/images", file: first_file
    first_file_id = JSON.parse(last_response.body)["id"]

    second_file = File.read(File.dirname(__FILE__) + '/fixtures/files/pancakes.jpg')
    post "/images", file: second_file
    second_file_id = JSON.parse(last_response.body)["id"]

    expect(first_file_id).not_to eq(second_file_id)

    get "/images/#{second_file_id}"
    expect(last_response).to be_ok
    expect(last_response.body).to eq(second_file)
    expect(last_response.body).not_to eq(first_file)
  end

  # stretch
  it "can return an image in a different format" do
    file = File.read(File.dirname(__FILE__) + '/fixtures/files/bacon.jpg')
    post "/images", file: file
    file_id = JSON.parse(last_response.body)["id"]

    get "/images/#{file_id}.png"
    expect(last_response).to be_ok
    expect(last_response.media_type).to eq('image/png')
    expect(last_response.body).not_to eq(file)
  end

  it "should return the correct default format for an uploaded image" do
    file = File.read(File.dirname(__FILE__) + '/fixtures/files/eggs.png')
    post "/images", file: file
    file_id = JSON.parse(last_response.body)["id"]

    get "/images/#{file_id}"
    expect(last_response).to be_ok
    expect(last_response.media_type).to eq('image/png')
  end

  it "can turn a jpg into a png and back again" do
    jpg_file = File.read(File.dirname(__FILE__) + '/fixtures/files/bacon.jpg')
    post "/images", file: jpg_file
    jpg_file_id = JSON.parse(last_response.body)["id"]

    get "/images/#{jpg_file_id}.png"
    expect(last_response).to be_ok
    png_file = last_response.body

    post "/images", file: png_file
    png_file_id = JSON.parse(last_response.body)["id"]

    get "/images/#{png_file_id}.jpg"
    expect(last_response).to be_ok
    expect(last_response.media_type).to eq('image/jpeg')
  end
end