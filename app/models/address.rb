class Address < ApplicationRecord
belongs_to :addressable, polymorphic: true
enum name: [:billing, :shipping]

  def full_address
    return self.line_1 + self.line_2 + self.line_3
  end
end
