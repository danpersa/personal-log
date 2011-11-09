Feature: 4.6 - The user encourages other user's ideas using the Good idea button
  As an user
  I want to encourage other users
  So that they can feel supported in making their ideas come true

  @javascript
  Scenario: The user successfully encourages another user
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
    When I follow "Good idea"
    Then I should see "Good idea! (1)"