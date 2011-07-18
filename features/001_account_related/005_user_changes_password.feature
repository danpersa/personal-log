Feature: 1.5 - The user changes the password
  As an user
  I want to change the password of my account
  So that I can protect my account from unauthorized access

  Scenario: The user successfully changes his password
    Given an user exists with an email of "brandon@example.com"
    And "brandon@example.com"'s the account is activated
    And the default privacies exist
    And I sign in with "brandon@example.com" and "foobar"
    When I go to the change password page
    And I fill in the following:
     | Old password       | foobar  |
     | New password       | qwerty  |
     | Confirmation       | qwerty  |
    And I press "Change password"
    Then I should see "Your password was successfully changed!"
    And "brandon@example.com"'s password should be "qwerty"
