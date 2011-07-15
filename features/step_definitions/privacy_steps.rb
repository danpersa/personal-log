Given /^the default privacies exist$/ do
  Privacy.create!(:name => "public")
  Privacy.create!(:name => "private")
end
