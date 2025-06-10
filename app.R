library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)  # For interactive plots
library(tidyr)   # For the replace_na function
library(DT)      # For interactive tables


reviews <- read.csv("honeycomb_test_data.csv", stringsAsFactors = FALSE)


reviews$self_review <- as.logical(reviews$self_review)
reviews$completed_at <- as.Date(reviews$completed_at)


reviews$relationship <- ifelse(is.na(reviews$relationship), "Self", reviews$relationship)


ui <- fluidPage(
  titlePanel("Employee Review Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("population", "Filter by Population (reviewee):",
                         choices = unique(reviews$u.population_id)),
      uiOutput("user_selector"),
      uiOutput("relationship_selector")
    ),
    
    mainPanel(
      textOutput("hover_message"),  
      
      tabsetPanel(
        tabPanel("Plot", plotlyOutput("scorePlot")),  
        tabPanel("Data Table", DTOutput("scoreTable"))
      ),
      
      hr(),  
      
      h3("Summary of Findings"),
      
      h4("1. Self vs. Others Ratings"),
      p("Users consistently rate themselves higher than they are rated by their peers and managers, indicating a possible perception gap."),
      
      h4("2. Feedback-related Behaviour"),
      p("The behaviour ", em("\"Listens to feedback about their impact on others\""), 
        " received low ratings across many users, suggesting this is a common area for improvement."),
      
      h4("3. Duplicate Reviews and Score Aggregation"),
      p("Some users have participated in multiple review cycles, resulting in duplicate responses. In these cases, scores have been aggregated to avoid duplication and present a unified view of each individual's feedback.")
    )
  )
)


server <- function(input, output, session) {
  
 
  filtered_data <- reactive({
    req(input$population)  
    reviews %>%
      filter(u.population_id %in% input$population)
  })
  
 
  output$user_selector <- renderUI({
    req(filtered_data())  
    selectInput("user", "Select Employee (reviewee):",
                choices = filtered_data() %>%
                  pull(user_id) %>%
                  unique(),
                selected = filtered_data() %>%
                  pull(user_id) %>%
                  unique() %>%
                  .[1])  
  })
  
  
  output$relationship_selector <- renderUI({
    req(input$user)  
    
    
    user_reviews <- filtered_data() %>%
      filter(user_id == input$user)
    
   
    review_sources <- user_reviews %>%
      pull(relationship) %>%
      unique()
    
    checkboxGroupInput("relationship", "Select Review Sources:",
                       choices = review_sources, selected = review_sources)
  })
  
  
  output$hover_message <- renderText({
    "💡 Hover over the bars in the graph to see the behaviours."
  })
  
  
  aggregated_data <- reactive({
    req(input$user, input$relationship)  
    
    
    df <- filtered_data() %>%
      filter(user_id == input$user,
             relationship %in% input$relationship)
    
    
    df_aggregated <- df %>%
      mutate(value = as.numeric(replace_na(value, 0))) %>%
      group_by(behaviour_id, relationship) %>%
      summarise(aggregated_value = mean(value, na.rm = TRUE), .groups = 'drop')
    
    
    df_aggregated <- df_aggregated %>%
      left_join(
        df %>% select(behaviour_id, behaviour_title) %>% distinct(),
        by = "behaviour_id"
      )
    
    df_aggregated
  })
  
  
  output$scorePlot <- renderPlotly({
    df_aggregated <- aggregated_data()  
    
    if (nrow(df_aggregated) == 0) {
      return(NULL)  
    }
    
    
    p <- ggplot(df_aggregated, aes(x = factor(behaviour_id), y = aggregated_value, fill = relationship, text = behaviour_title)) +
      geom_bar(stat = "identity", position = position_dodge(width = 0.8)) +  
      labs(title = paste("Average Behavioural Scores for User:", input$user),
           x = "Behaviour ID", y = "Average Score") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))  
    
    
    ggplotly(p, tooltip = "text")  
  })
  
  
  output$scoreTable <- renderDT({
    df_aggregated <- aggregated_data()  
    
    if (nrow(df_aggregated) == 0) {
      return(NULL)  
    }
    
    
    datatable(df_aggregated, options = list(pageLength = 10, scrollX = TRUE))
  })
  
  
  observe({
    if (length(input$population) == 0) {
      showModal(modalDialog(
        title = "🔔 Select the Population ID to Continue",
        "Please select at least one population group from the checkbox above to continue.",
        easyClose = TRUE,
        footer = NULL
      ))
    }
  })
  
  
  observeEvent(input$population, {
    if (length(input$population) > 0) {
      removeModal()  
    }
  })
}


shinyApp(ui = ui, server = server)

