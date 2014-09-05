library(httr)
library(rjson)
library(stringr)
library(shiny)

source("R/constants.R")
#step=10

makeQuery <- function(terms=NULL, from=0, step=10, oper="AND"){
  if(length(terms)==0 | is.null(terms) ){
    query = '{
   "query": {
      "match_all": {}
   }
  }' 
  } else {
    query = '{

      "from": _F_,
      "size": _S_,
      "sort": [
              {"collector": "asc"},
              {"number": "asc"}
            ],
      "query": {
        "query_string": {
          "default_operator": "_O_",
          "query": "_Q_"
        }
        
      }
    }'
    query = str_replace(query, "_Q_", terms)
    query = str_replace(query, "_S_", step)
    query = str_replace(query, "_O_", oper)
    query = str_replace(query, "_F_", from)
    
  }
  
  query
}


esSearch <- function(query = NULL, 
                     url = "http://localhost", 
                     port = 9200, 
                     from = 0,
                     step = 10,
                     oper = "AND"
                     ){
  url = paste(url, port, sep=":")
  url = paste(url,"_search", sep="/")
  
  query = makeQuery(query, from, step, oper)
  
  x=POST(url, body = query)
  fromJSON(content(x, as="text"))
}


pasteSpec <- function(rec){
  
  rid = paste(rec$collector, ": ", rec$number, sep="")
  
  paste(a(rid,href="profiles/profile.html"),  " ",
    rec$genus, " ", rec$species, ". ", rec$country, " - ", rec$colldate,
    sep="")
}
  
  