class FlexibleTextInput < SimpleForm::Inputs::Base
  def input_html_options
    super.merge(:class => "flexible-text-area")
  end
end