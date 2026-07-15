Feature: Articles feature
    Background:
        Given url 'https://conduit-api.bondaracademy.com/api'

    Scenario: Create a new article
        Given path '/users/login'
        And request { user: { email: '#(userEmail)', password: '#(userPassword)' } }
        When method post
        Then status 200
        * def token = response.user.token

        Given header Authorization = 'Token ' + token
        Given path '/articles'
        And request { "article": { "title": "Article Title Test v3", "description": "This article is about sometinh, it's a test", "body": "Article Content Test","tagList":["tag1", "tag2", "tag3"]}}
        When method post
        Then status 201
        And match response.article.title == 'Article Title Test v3'
