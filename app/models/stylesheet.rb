class Stylesheet < ActiveRecord::Base
  serialize :variables, JSON

  belongs_to :themeable, polymorphic: true

  def to_less
    # Convert a hash of variables into SCSS
    variables.each_pair.map do |name, value|
      "@#{name}: #{value};"
    end.join("\n")
  end
end
