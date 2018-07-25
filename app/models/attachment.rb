class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true

  validates :document, presence: true

  has_attached_file :document,
                    :path => "#{Rails.env.production? ? '/var/www/rails/couchpotatoe/shared' : Rails.root}/assets/:class/:id/:style_:basename.:extension",
                    :styles => {:medium => "400x400>"}

  do_not_validate_attachment_file_type :document

  before_post_process :convert?

  def convert?
    self.document_type == 'passport' || self.document_type == 'image'
  end

  def autosign(signature_position, signature_data, date_of_signature, digital_signature)
    original_path = self.document.path
    tmpfile = Tempfile.new(['verified_contract', '.pdf'])

    last_page = 1

    File.open(original_path, "rb") do |io|
      reader = PDF::Reader.new(io)
      last_page = reader.pages.count
    end

    Prawn::Document.generate(tmpfile.path, :skip_page_creation => true) do
      (1..(last_page - 1)).to_a.each do |page|
        start_new_page(:template => original_path, size: 'A4', layout: :portrait, template_page: page)
      end

      start_new_page(:template => original_path, size: 'A4', layout: :portrait, template_page: last_page)

      self.canvas do
        sig_box_top_left = [bounds.width * signature_position[0], bounds.height - (bounds.height * signature_position[1])]
        dig_sig_top_left = [sig_box_top_left[0], sig_box_top_left[1] + 20]

        bounding_box(dig_sig_top_left, width: 200) do
          text date_of_signature.to_s
          font("Courier", size: font_size / 2) do
            text digital_signature
          end
        end
        translate *sig_box_top_left do
          scale 0.4 do
            transparent(0.4, 0.94) do

              stroke do
                self.line_width = 2.5
                self.join_style = :round
                stroke_color "000738"

                JSON.parse(signature_data).each do |line_data|

                    move_to line_data['mx'].to_f, -line_data['my'].to_f
                    line_to line_data['lx'].to_f, -line_data['ly'].to_f
                  end
                end
              end
          end
        end
      end
    end

    self.attachable.attachments.build(document_type: 'signed_contract', document: tmpfile)
  end
end
