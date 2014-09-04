
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyBS)
library(exsic)

source("R/tools.R")
source("R/constants.R")

td = tempdir()
of = file.path(td,"out.html")

shinyServer(function(input, output, session) {
  
  page = reactive({
    offset = as.integer(input$offset) - 1
    offset
  })
  
  
  res = reactive({
    res = esSearch(input$search, from = (selPage()-1) * step)
    #print(selPage())
    res
  })
  
  
  pageMax = reactive({
    #p = page() + 1
    p = selPage()
    n = res()$hits$total
    #print(p)
    #print(n)
    if(length(n)==0) n = 0
    max = 1
    if(n > step){
      max = round(n / step + 0.5, 0)
    }
    list(p=p, max=max)
  })
  
  
  
  observe({
    input$search
    pm = pageMax()
    #print(pm)
    #updateSelectInput(session, "offset", choices = 1:pm$max, selected = pm$p)
    updateRadioButtons(session, "offset", choices = 1:pm$max, selected = pm$p)
  })
  
  

  output$results <- renderUI({
    n = as.integer(res()$hits$total)
    
    sp = selPage()
    #print(sp)
    #print(n)
    s = round(as.integer(res()$took)/1000, 2) + 1
    if(length(n)==0) n = 0
    tot = paste("Total results:", n, " (", s, " seconds)", br())
    
    if(n>step){
      rcsStart = (sp - 1) * step +1
      rcsEnd   = rcsStart + step -1
      if(rcsEnd > n) rcsEnd = n
      rcs = paste("Display records:", rcsStart, "-", rcsEnd, br(), hr())
    } else {
      rcs = paste(hr())
    }
    tot = paste(tot, rcs)
    out = ""
    try(
    if(n > 0) {
      ns = length(res()$hits$hits)
      #print(res())
      for(i in 1:ns){
        res = res()$hits$hits[[i]]
        rec = res[["_source"]]
        out = pasteSpec(rec)
        tot = paste(tot, out, br(), br(), sep="")
      }
     
    }
    )
    
    HTML(tot)
    
  })

  output$resultsNav <- renderUI({
    HTML(hr())
    mp = pageMax()
    if(mp$max>1) radioButtons("offsetNew","Select a results page:",1:mp$max, selected = mp$p,inline=TRUE)
  })
  
  selPage <- reactive({
    x=as.integer(input$offsetNew)
    if(length(x) == 0) x=1
    x
  })

})
