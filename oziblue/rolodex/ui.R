library(shiny)

ui <- navbarPage(
  title = "Rolodex",
  
  # -------------------- PAGE 1: RECIPES --------------------
  tabPanel(
    "Recipe Rolodex",
    sidebarLayout(
      sidebarPanel(
        selectInput("course_filter", "Filter by Course",
                    choices = NULL, selected = "All"),
        selectInput("country_filter", "Filter by Country",
                    choices = NULL, selected = "All"),
        actionButton("random_recipe", "🎲 Pick a Random Recipe")
      ),
      mainPanel(
        h3("Selected Recipe"),
        textOutput("recipe_name"),
        textOutput("recipe_course"),
        textOutput("recipe_style"),
        textOutput("recipe_country"),
        textOutput("recipe_source"),
        textOutput("recipe_notes"),
        uiOutput("recipe_link")
      )
    )
  ),
  
  # -------------------- PAGE 2: CREATIVE --------------------
  tabPanel(
    "Creative Sampler",
    sidebarLayout(
      sidebarPanel(
        selectInput(
          "creative_mode",
          "Creative Mode",
          choices = c(
            "Random Image (Default)",
            "Random Unsplash Image",
            "Random Creative Idea",
            "Random Pantone Color"
          )
        ),
        actionButton("random_creative", "✨ Surprise Me")
      ),
      
      mainPanel(
        uiOutput("creative_output")
      )
    )
  )
)
