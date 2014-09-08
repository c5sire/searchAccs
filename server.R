
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinyBS)
library(exsic)

source("R/tools.R")
#source("R/constants.R")

td = tempdir()
of = file.path(td,"out.html")

shinyServer(function(input, output, session) {
  
  page = reactive({
    offset = 0
    try({
      offset = as.integer(input$offset) - 1
    })
    if(length(offset)==0) offset = 0
    offset
  })
  
  step = reactive({
    step = 10
    try({
      step = as.integer(input$pageSize)
    })
    if(length(step)==0) step=10
    step
  })
  
  opr = reactive({
    opr = "AND"
    try({
      opr = input$searchOperator
    })
    if(length(opr)==0) opr="AND"
    opr
  })
  
  elevOn = reactive({
    input$filterElevation
  })
  
  elev = reactive({
    elev = c(NA, NA)
    try({
      elev = input$elevRange  
    })
    
    elev
  })
  
  res = reactive({
    elev = c(NA, NA)
    if(elevOn()) elev = elev()
    
    
    res = esSearch(input$search, from = (selPage()-1) * step(), step = step(), 
                   oper=opr(), 
                   elev = elev)
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
    if(n > step()){
      max = round(n / step() + 0.5, 0)
    }
    list(p=p, max=max)
  })
  
  
  
  observe({
    input$search
    pm = pageMax()
    #print(res() )
    cntr = res()$aggregations$cntr_stats$buckets
    #print(length(specs))
    cntr = matrix(unlist(cntr),2)
    #print(xx[1,])
    #print(class(xx))
    xx=sort(paste(cntr[1,], " (", cntr[2,],")", sep=""))
    updateCheckboxGroupInput(session, "countrySel", label = xx, choices = cntr[2,])
    
    
    updateRadioButtons(session, "offset", choices = 1:pm$max, selected = pm$p)
  })
  
  

  output$results <- renderUI({
    n = as.integer(res()$hits$total)
    
    sp = selPage()
    #print(sp)
    #print(n)
    s = round(as.integer(res()$took)/1000, 2) 
    if(length(n)==0) n = 0
    tot = paste("Total results:", n, " (", s, " seconds)", br())
    if(elevOn()) tot = 
      paste(tot, "Within elevation range: ", elev()[1], "-", elev()[2], " masl", br())
    
    if(n>step()){
      rcsStart = (sp - 1) * step() +1
      rcsEnd   = rcsStart + step() -1
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
  
  output$countrySel <- renderUI({
    cntr = res()$aggregations$cntr_stats$buckets
    cntr = matrix(unlist(cntr),2)
    
    xx=sort(paste(cntr[1,], " (", cntr[2,],")", sep=""))
    #print(xx)
    {
    hr()
    checkboxGroupInput("country", "", label=xx, choices = cntr[1,])
    }
  })
  
  selPage <- reactive({
    x=as.integer(input$offsetNew)
    if(length(x) == 0) x=1
    x
  })

})
