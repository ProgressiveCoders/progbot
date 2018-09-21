Feature: Commenting

  As a user
  In order to document changes and have a discussion
  I want to store and view comments on a resource

  Background:
    Given a post with the title "Hello World" written by "Jane Doe" exists

  Scenario: View a resource with no comments
    Given a show configuration of:
      """
        ActiveAdmin.register Post
      """
    Then I should see "Comments (0)"
    And I should see "No comments yet."

  Scenario: Create a new comment
    Given a show configuration of:
      """
        ActiveAdmin.register Post
      """
    When I add a comment "Hello from Comment"
    Then I should see a flash with "Comment was successfully created"
    And I should be in the resource section for posts
    And I should see "Comments (1)"
    And I should see "Hello from Comment"
    And I should see a comment by "admin@example.com"

  Scenario: View resource with comments turned off
    Given a show configuration of:
    """
      ActiveAdmin.register Post do
        config.comments = false
      end
    """
    Then I should not see the element "div.comments.panel"

  Scenario: View a resource in a namespace that doesn't have comments
    Given a configuration of:
    """
      ActiveAdmin.application.namespace(:new_namespace).comments = false
      ActiveAdmin.register Post,      namespace: :new_namespace
      ActiveAdmin.register AdminUser, namespace: :new_namespace
    """
    Given I am logged in
    When I am on the index page for posts in the new_namespace namespace
    And I follow "View"
    Then I should not see "Comments"

  Scenario: Enable comments on per-resource basis
    Given a configuration of:
    """
      ActiveAdmin.application.namespace(:new_namespace).comments = false
      ActiveAdmin.register Post,      namespace: :new_namespace do
        config.comments = true
      end
      ActiveAdmin.register AdminUser, namespace: :new_namespace
    """
    Given I am logged in
    When I am on the index page for posts in the new_namespace namespace
    And I follow "View"
    Then I should see "Comments"

  Scenario: Creating a comment in one namespace does not create it in another
    Given a show configuration of:
    """
      ActiveAdmin.register Post
      ActiveAdmin.register Post,      namespace: :public
      ActiveAdmin.register AdminUser, namespace: :public
    """
    When I add a comment "Hello world in admin namespace"
    Then I should see "Hello world in admin namespace"

    When I am on the index page for posts in the public namespace
    And I follow "View"
    Then I should not see "Hello world in admin namespace"
    And I should see "Comments (0)"

    When I add a comment "Hello world in public namespace"
    Then I should see "Hello world in public namespace"
    When I am on the index page for posts in the admin namespace
    And I follow "View"
    Then I should not see "Hello world in public namespace"
    And I should see "Comments (1)"

  Scenario: Creating a comment on an aliased resource
    Given a configuration of:
    """
    ActiveAdmin.register Post, as: "Article"
    """
    Given I am logged in
    When I am on the index page for articles
    And I follow "View"
    When I add a comment "Hello from Comment"
    Then I should see a flash with "Comment was successfully created"
    And I should be in the resource section for articles

  Scenario: Create an empty comment
    Given a show configuration of:
      """
        ActiveAdmin.register Post
      """
    When I add a comment ""
    Then I should see a flash with "Comment wasn't saved, text was empty."
    And I should see "Comments (0)"

  Scenario: Viewing all comments for a namespace
    Given a show configuration of:
      """
        ActiveAdmin.register Post
      """
    When I add a comment "Hello from Comment"
    When I am on the index page for comments
    Then I should see a table header with "Body"
    And I should see "Hello from Comment"

  Scenario: Commenting on a STI superclass
    Given a configuration of:
    """
      ActiveAdmin.register User
    """
    Given I am logged in
    And a publisher named "Pragmatic Publishers" exists
    When I am on the index page for users
    And I follow "View"
    When I add a comment "Hello World"
    Then I should see a flash with "Comment was successfully created"
    And I should be in the resource section for users
    When I am on the index page for comments
    Then I should see the content "User"
    And I should see "Hello World"

  Scenario: Commenting on a STI subclass
    Given a configuration of:
    """
      ActiveAdmin.register Publisher
    """
    Given I am logged in
    And a publisher named "Pragmatic Publishers" exists
    When I am on the index page for publishers
    And I follow "View"
    When I add a comment "Hello World"
    Then I should see a flash with "Comment was successfully created"
    And I should be in the resource section for publishers
    And I should see "Hello World"

  Scenario: Commenting on an aliased resource with an existing non-aliased config
    Given a configuration of:
    """
      ActiveAdmin.register Post
      ActiveAdmin.register Post, as: 'Foo'
    """
    Given I am logged in
    When I am on the index page for foos
    And I follow "View"
    When I add a comment "Bar"
    Then I should be in the resource section for foos

  Scenario: View comments
    Given 70 comments added by admin with an email "admin@example.com"
    And a show configuration of:
      """
        ActiveAdmin.register Post
      """
    Then I should see "Comments (70)"
    And I should see "Displaying comments 1 - 25 of 70 in total"
    And I should see 25 comments
    And I should see pagination with 3 pages
    And I should see the pagination "Next" link
    Then I follow "2"
    And I should see "Displaying comments 26 - 50 of 70 in total"
    And I should see 25 comments
    And I should see the pagination "Next" link
    Then I follow "Next"
    And I should see 20 comments
    And I should see "Displaying comments 51 - 70 of 70 in total"
    And I should not see the pagination "Next" link
