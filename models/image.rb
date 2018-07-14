require 'mini_magick'

class Image
  attr_accessor :id

  def initialize(id)
    self.id = id
  end

  def content
    io = StringIO.new
    image.write(io)
    io.string
  end

  def format(fmt)
    image.format(fmt)
  end

  def content_type
    image.data['mimeType']
  end

  private

  def image
    @image ||= Image.get(id)
  end

  class << self
    def create(image_data)
      id = next_id
      File.write(image_path(id), image_data)
      new(id)
    end

    def get(id)
      MiniMagick::Image.open(image_path(id))
    end

    private

    def next_id
      Dir.glob(image_path('*')).length
    end

    def image_path(id)
      "#{File.dirname(__FILE__)}/../images/#{id}"
    end
  end

end