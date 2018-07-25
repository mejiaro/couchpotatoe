class StylesheetsController < ApplicationController
  layout nil

  def show
    styles = Stylesheet.find(params[:id])
    base_stylesheet_path = Rails.root.join('app', 'assets', 'stylesheets', 'profile.css.less')

    @less = <<-LESS
#{styles.to_less}
      @import "#{base_stylesheet_path}";
    LESS

    # Cache for long time
    response.headers['Cache-Control'] = "public, max-age=#{1.year}"

    respond_to do |format|
      format.css
    end
  end
end
