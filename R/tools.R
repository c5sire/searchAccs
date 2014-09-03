library(httr)
library(rjson)
library(stringr)
library(shiny)

step=10

makeQuery <- function(terms=NULL, from=0){
  if(length(terms)==0 | is.null(terms) ){
    query = '{
   "query": {
      "match_all": {}
   }
  }' 
  } else {
    qu = '{
      "from": _F_,
      "query": {
        "query_string": {
          "query": "_Q_"
        }
      }
    }'
    query = str_replace(qu, "_Q_", terms)
    query = str_replace(query, "_F_", from * step)
    
  }
  
  query
}


esSearch <- function(query = NULL, url = "http://localhost", port = 9200, from = 0){
  url = paste(url, port, sep=":")
  url = paste(url,"_search", sep="/")
  
  query = makeQuery(query, from)
  
  x=POST(url, body = query)
  fromJSON(content(x, as="text"))
}


pasteSpec <- function(rec){
  
  rid = paste(rec$collector, ": ", rec$number, sep="")
  
  paste(a(rid,href="http://www.google.com"),  " ",
    rec$genus, " ", rec$species, ". ", rec$country, " - ", rec$colldate,
    sep="")
}
  
  