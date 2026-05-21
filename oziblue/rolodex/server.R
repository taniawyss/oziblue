library(shiny)
library(openxlsx2)
library(dplyr)
library(base64enc)

server <- function(input, output, session) {
  
  # -------------------- LOAD DATA --------------------
  recipes <- read_xlsx("data/liste_recettes.xlsx")
  ideas   <- read_xlsx("data/creative_ideas.xlsx")
  
  # -------------------- FILTERS --------------------
  updateSelectInput(session, "course_filter",
                    choices = c("All", sort(unique(recipes$Course))))
  updateSelectInput(session, "country_filter",
                    choices = c("All", sort(unique(recipes$Country))))
  
  filtered_recipes <- reactive({
    df <- recipes
    if (input$course_filter != "All")
      df <- df %>% filter(Course == input$course_filter)
    if (input$country_filter != "All")
      df <- df %>% filter(Country == input$country_filter)
    df
  })
  
  selected_recipe <- eventReactive(input$random_recipe, {
    filtered_recipes() %>% slice_sample(n = 1)
  })
  
  output$recipe_name    <- renderText(paste("Recipe:", selected_recipe()$Recettes))
  output$recipe_course  <- renderText(paste("Course:", selected_recipe()$Course))
  output$recipe_style   <- renderText(paste("Style:",  selected_recipe()$Style))
  output$recipe_country <- renderText(paste("Country:", selected_recipe()$Country))
  output$recipe_source  <- renderText(paste("Source:", selected_recipe()$Source))
  output$recipe_notes   <- renderText(paste("Notes:",  selected_recipe()$Notes))
  
  output$recipe_link <- renderUI({
    url <- selected_recipe()$Link
    if (!is.na(url) && nzchar(url)) {
      tags$a(href = url, url, target = "_blank")
    }
  })
  
  # -------------------- IMAGE SAMPLING --------------------
  get_image <- reactive({
    list.files(
      "www/images",
      pattern = "\\.(png|jpg|jpeg)$",
      full.names = TRUE,
      ignore.case = TRUE
    )
  })
  
  # -------------------- CREATIVE OUTPUT --------------------
  output$creative_output <- renderUI({
    req(input$random_creative)
    
    mode <- input$creative_mode
    
    if (mode == "Random Image (Default)") {
      
      imgs <- get_image()
      req(length(imgs) > 0)
      img <- sample(imgs, 1)
      
      ext  <- tolower(tools::file_ext(img))
      mime <- if (ext %in% c("jpg", "jpeg")) "image/jpeg" else "image/png"
      
      encoded <- dataURI(file = img, mime = mime)
      
      tagList(
        tags$img(src = encoded, style = "max-width:500px;"),
        tags$p(strong("File:"), basename(img))
      )
      
    } else if (mode == "Random Unsplash Image") {
      
      link <- paste0(
        "https://source.unsplash.com/featured/800x600?sig=",
        sample(1:10000, 1)
      )
      
      tagList(
        tags$img(src = link, style = "max-width:500px;"),
        tags$p(tags$a(href = link, "View on Unsplash", target = "_blank"))
      )
      
    } else if (mode == "Random Creative Idea") {
      
      idea <- ideas %>% slice_sample(n = 1)
      tagList(
        h3(idea$idea),
        p(paste("Type:", idea$type))
      )
      
    } else if (mode == "Random Pantone Color") {
      
      col <- rgb(runif(1), runif(1), runif(1))
      tagList(
        div(style = paste0(
          "width:200px;height:200px;",
          "background-color:", col, ";border-radius:10px;"
        )),
        h4(col)
      )
    }
  })
}
