Feature: Test for the home page
    Background:
        Given url 'https://conduit-api.bondaracademy.com/api'

    Scenario: Get all tags
        Given path '/tags'
        When method get
        Then status 200

        #1. March de todo el array de tags
        And match response.tags == ['Test', 'Blog', 'Coding', 'YouTube', 'Git', 'Bondar Academy', 'Slack', 'Zoom', 'GitHub', 'Value-Focused']

        #2. Contiene un solo valor
        And match response.tags contains 'Test'

        #3. Contiene varios valores
        And match response.tags contains ['Test', 'Blog', 'Coding']

        # 4. Contiene SOLO estos valores y nada más (mismo set, orden libre)
        And match response.tags contains only ['Test', 'Blog', 'Coding', 'YouTube', 'Git', 'Bondar Academy', 'Slack', 'Zoom', 'GitHub', 'Value-Focused']

        # 5. Contiene al menos uno de estos valores
        And match response.tags contains any ['Test', 'Blog', 'Coding', 'YouTube', 'Git', 'Bondar Academy', 'GAAAA']

        # 6. NO contiene un valor
        And match response.tags !contains 'GAAAA'

        # 7. Tamaño del arreglo
        And match response.tags == '#[10]'

        # 8. Tipo de dato de la respuesta
        And match response.tags == '#array'
        And match response.tags == '#notnull'

        # 9. Cada elemento del arreglo es un string
        And match each response.tags == '#string'

        # 10. Validar la respuesta completa como objeto con schema marker
        And match response == { tags: '#array' }

        # 11. Karate JS embebido: verificar longitud con función
        * def tagCount = response.tags.length
        And match tagCount == 10

    Scenario: Get 10 articles from the page
        Given params { limit: 10, offset: 0 }
        Given path '/articles'
        When method get
        Then status 200

        # 1. Validar que 'articles' es un arreglo y 'articlesCount' es un número
        And match response.articles == '#array'
        And match response.articlesCount == '#number'

        # 2. Validación cruzada: que articlesCount sea igual a la longitud del arreglo articles
        And match response.articlesCount == response.articles.length

        # 3. Tamaño del arreglo articles
        And match response.articles == '#[10]'

        # 4. Schema por elemento con 'each' - valid que todos los artículos
        # tengan esta estructura, sin comprobar valores específicos
        And match each response.articles ==
        """
        {
            "slug": "#string",
            "title": "#string",
            "description": "#string",
            "body": "#string",
            "tagList": "#array",
            "createdAt": "#string",
            "updatedAt": "#string",
            "favorited": "#boolean",
            "favoritesCount": "#number",
            "author": {
                "username": "#string",
                "bio": "#null",
                "image": "#string",
                "following": "#boolean"
            }
        }
        """

        # 5. Validar formato fecha con regex embebido
        And match response.articles[0].createdAt == '#regex ^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$'

        # 6. Validar el primer artículo específico
        And match response.articles[0].title == 'Discover Bondar Academy: Your Gateway to Efficient Learning'
        And match response.articles[0].favorited == false
        And match response.articles[0].author.username == 'Artem Bondar'

        # 7. Validar que 'bio' es null para el primer artículo
        And match response.articles[0].author.bio == '#null'

        # 8. Validar contenido de un arreglo anidado de un artículo específico
        And match response.articles[0].tagList contains ['qa career', 'Bondar Academy']

        # 9. Extraer solo los slugs de todos los artículos y validar que no hay duplicados
        * def slugs = karate.jsonPath(response, '$.articles[*].slug')
        * def uniqueSlugs = karate.distinct(slugs)
        * def slugsCount = karate.sizeOf(slugs)
        * def uniqueSlugsCount = karate.sizeOf(uniqueSlugs)
        And match uniqueSlugsCount == slugsCount

        # 10. Lógica de negocio con JS embebido: los artículos vienen ordenados
        #     por favoritesCount de mayor a menor
        * def dates = karate.jsonPath(response, '$.articles[*].createdAt')
        * def isSortedByDate = dates.every((val, i, arr) => i === 0 || new Date(arr[i-1]) >= new Date(val))
        And match isSortedByDate == true

        # 11. Ningun artículo debe tener favoritesCount negativo
        * def counts = karate.jsonPath(response, '$.articles[*].favoritesCount')
        * def allPositive = counts.every(c => c >= 0)
        And match allPositive == true
