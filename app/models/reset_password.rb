require 'validators/email_format_validator'

class ResetPassword
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email
  
  validates :email, :presence     => true,
                    :email_format => true
end
