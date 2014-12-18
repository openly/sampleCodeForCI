Feature: API Version
  As a user of API
  I want to see the API Version
  So that I can know which API version I am using

  Scenario: Check Version
    When I request the url '/'
    Then I should get the response with version number