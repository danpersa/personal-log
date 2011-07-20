Feature: 6.3 - The user sees a popup when puts his mouse over a reminder from the calendar
  As an user
  I want to see the details of a reminder from the calendar, without changing the page
  So that I can be able to manage my reminders faster

  @focus @javascript
  Scenario: The user successfully sees sees the popup with the reminder's details
    Given a logged user with email "brandon@example.com"
    And "brandon@example.com" shares one idea on "10/10/2012"
    And I am on the calendar page on "2012-10"
    # does not work with Selenium
    #When I hover over the idea link 
    #Then I should see "brandon@example.com"'s ideas content
    
    