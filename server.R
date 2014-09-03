
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyBS)

source("R/tools.R")

step = 10

shinyServer(function(input, output, session) {
  
  
  res = reactive({
    offset = as.integer(input$offset) - 1
    esSearch(input$search, from = offset)
  })
  
  
  observe({
    input$search
    p = as.integer(input$offset)
    n = res()$hits$total
    if(length(n)==0) n = 0
    max = 1
    if(n > step){
      max = round(n / step + 0.5, 0)
    }
    updateSelectInput(session, "offset", choices = 1:max, selected = p)
    
  })

  output$results <- renderUI({
    n = as.integer(res()$hits$total)
    #print(n)
    s = round(as.integer(res()$took)/1000, 2) + 1
    if(length(n)==0) n = 0
    tot = paste("Total results:", n, " (", s, " seconds)", br())
    
    if(n>step){
      rcsStart = (as.integer(input$offset) - 1) * step +1
      rcsEnd   = rcsStart + step -1
      if(rcsEnd > n) rcsEnd = n
      rcs = paste("Display records:", rcsStart, "-", rcsEnd, br(), hr())
    } else {
      rcs = paste(hr())
    }
    tot = paste(tot, rcs)
    
    if(n > 0) {
      for(i in 1:n){
        res = res()$hits$hits[i]
        rec = res[[1]][["_source"]]
        out = paste(rec, collapse = ", ")
        tot = paste(tot, out, br(), br(), sep="")
      }
      
    }
    HTML(tot)
    
  })



})
