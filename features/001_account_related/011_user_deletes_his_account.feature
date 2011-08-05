Feature: 1.11 - The user deletes his account
  As an user
  I want to delete my account
  So that if I don't want to use the application, all the information stored in there is deleted

Scenario: The user successfully deletes his account
    Given a logged user with email "brandon@example.com"
    And I am on the edit profile page of "brandon@example.com"
    When I follow "Delete your account" 
    Then I should be on the home page
    And I should see "Your account was successfully deleted!"