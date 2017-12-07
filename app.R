# Load packages ----
library(shiny)
library(quantmod)

# Source helpers ----
source("helpers.R")

# User interface ----
ui <- fluidPage(
  titlePanel("stockVis"),
  
  sidebarLayout(
    sidebarPanel(
      
      #Title
      helpText("Select a stock to examine. Information will be collected from Google finance."),
      
      #Text input
      textInput("symb", "Symbol", "SPY"),
      
      #Date input
      dateRangeInput("dates", 
                     "Date range",
                     start = "2013-01-01", 
                     end = as.character(Sys.Date())),
      
      br(),
      br(),
      
      #Single Checkbox
      checkboxInput("log", "Plot y axis on log scale", 
                    value = FALSE),
      #Single Checbox
      checkboxInput("adjust", 
                    "Adjust prices for inflation", value = FALSE)
    ),
    
    mainPanel(plotOutput("plot"))
  
    )
)

# Server logic
server <- function(input, output) {
  
  #dataInput will check that the dates and symb widgets have not changed
  dataInput <- reactive({
    getSymbols(input$symb, src = "google", 
               from = input$dates[1],
               to = input$dates[2],
               auto.assign = FALSE)
  })
  
  finalInput <- reactive({
    #If adjust is not selected, finalInput will not be adjusted
    if (input$adjust==FALSE) return (dataInput())
    #If adjust is selected, finalInput will be dataInput adjusted
    adjust(dataInput())
  })
  
  
  
  output$plot <- renderPlot({
    
   
    chartSeries(dataInput(), theme = chartTheme("white"), 
                type = "line", log.scale = input$log, TA = NULL)
  })
  
}

# Run the app
shinyApp(ui, server)
