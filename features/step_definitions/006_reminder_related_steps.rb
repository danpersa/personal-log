

When /^I hover over the idea link$/ do
  idea_link = page.find(:css, '.popup') 
  idea_link.trigger(:hover)
end