Feature: 4.7 -The user marks the ideas that he finished implementing using the I did this button
  As an user
  I want to mark the ideas I implemented
  So that I can keep track of them

  @javascript @focus
  Scenario: The user successfully marks an idea as done
    Given a logged user with email "brandon@example.com"
    And the following user exists:
    | Name          | Email              |
    | FirstUser     | first@example.com  |
    | SecondUser    | second@example.com |
    And "brandon@example.com" shares 1 idea
    And "first@example.com" shares the same idea
    And "second@example.com" shares the same idea
    And "brandon@example.com" has and idea list of name "TheIdeaList"
    And "brandon@example.com" has a display name of "TheUser"
    And "first@example.com" follows "brandon@example.com"
    And "second@example.com" follows "brandon@example.com"
    And "brandon@example.com" follows "second@example.com"
    And I go to the home page
    When I follow "I did this"
    Then I should see "I did this! (1)"
    And show me the page