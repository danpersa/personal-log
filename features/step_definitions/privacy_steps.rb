Given /^the default privacies exist$/ do
  if Privacy.find_by_name("public").nil? or Privacy.find_by_name("public").empty? 
    Privacy.create!(:name => "public")
  end
  if Privacy.find_by_name("private").nil? or Privacy.find_by_name("private").empty?
    Privacy.create!(:name => "private")
  end
end
