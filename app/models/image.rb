class Image < ActiveRecord::Base
  include RankedModel

  belongs_to :attachable_image, :polymorphic => true

  ranks :presentation_order, with_same: [:attachable_image_id, :attachable_image_type]

  default_scope { rank(:presentation_order) }

  has_attached_file :image, :styles => { :large => "800x800>", :medium => "400x400>",
                                         :thumb => "100x100#", :mini => "50x50#" },
                          :url => "/images/:id?style=:style",
                          :path => "/var/www/rails/loomaweb/shared/system/images/:paperclip_id/:style/:filename"

  do_not_validate_attachment_file_type :image_file_name


  translates :title
  globalize_accessors locales: [:de, :en, :fr, :es, :it]

  def paperclip_id
    if self.attachable_image_type == "User"
      'user_' + self.id.to_s
    else
      self.id
    end
  end
end
