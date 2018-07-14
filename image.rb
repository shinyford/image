require 'sinatra'

require './models/image'

post '/images' do
  image = Image.create(params['file'])

  content_type :json
  { id: image.id }.to_json
end

get '/images/:id.?:ext?' do |id, ext|
  image = Image.new(id)
  image.format(ext) if ext

  content_type image.content_type
  image.content
end
