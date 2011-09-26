Feature: 4.1 - The user shares an idea
  As an user
  I want to share my ideas
  So that I can receive feedback from other users

  Scenario: The user successfully shares an idea
    Given a logged user with email "brandon@example.com"
    And I am on the home page
    When I fill in "idea_content" with "go to school"
    And I fill in "new_reminder_reminder_date" with "05/05/2020"
    And I press "Post"
    Then I should see "wants to remind to go to school"
    And I should see "Idea created!"