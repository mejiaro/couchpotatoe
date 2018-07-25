class ImagesController < ActionController::Base
  def show
    i = Image.find(params[:id])
    if File.exist?(i.image.path)
      send_data File.read(i.image.path(params[:style] || :original))
    else
      render nothing: true
    end
  end
end
