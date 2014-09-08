
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyBS)

shinyUI(fluidPage(

  # Application title
  titlePanel("Accession search"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      textInput("search", "Search", "*"),
      checkboxInput("more", "More search options ..."),
      
      conditionalPanel(
          condition = "input.more == true",
          checkboxInput("searchModifiers", "General search options"),
          checkboxInput("filterElevation", "Restrict by elevation"),
          checkboxInput("filterCountry", "Restrict by country"),
          checkboxInput("searchModifiers", "General search options")
      ),
      
      conditionalPanel(
        condition = "input.searchModifiers == true",  
          selectInput("searchOperator", "Search term operator", c("AND", "OR"), "AND"),
          selectInput("pageSize", "Results per page", c(10, 20, 50, 100), 10)
      ),
      
      conditionalPanel(
        condition = "input.filterElevation == true",
          htmlOutput("elevationSel"),
          sliderInput("elevRange", "Elevation range", -500, 8848, c(0,4000))
      ),
      conditionalPanel(
        
        condition = "input.filterCountry == true",
        htmlOutput("countrySel")
      )
      
    ),
    
    
    

    # Show a plot of the generated distribution
    mainPanel(
      htmlOutput("results"),
      htmlOutput("resultsNav")
      
    
    )
  )
))
