
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
      textInput("search", "Search", "")
      #,
      #selectInput("offset", "Show results page:", 1)
    ),

    # Show a plot of the generated distribution
    mainPanel(
      htmlOutput("results"),
      htmlOutput("resultsNav")
      
    
    )
  )
))
