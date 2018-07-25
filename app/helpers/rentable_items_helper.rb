module RentableItemsHelper
  def static_map(mappable)
    latlng = mappable.latlng * ','
    base_url = "http://maps.googleapis.com/maps/api/staticmap"
    URI.encode("#{base_url}?center=#{latlng}&size=598x500&zoom=13&markers=color:red|#{latlng}")
  end

  def map_path(mappable)
    latlng = mappable.latlng * ','
    base_url = "http://maps.google.com"
    URI.encode("#{base_url}?q=#{latlng}")
  end
end
