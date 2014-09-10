library(httr)
library(rjson)
library(stringr)
library(shiny)

source("R/constants.R")
#step=10


termsAsList <- function(words, field, operator = "or"){
  stopifnot(is.vector(words) & is.character(words))
  n = length(words)
  terms = character()
  for(i in 1:n){
    x = list(words[i])
    names(x) = field
    terms[[i]] = list(term = x)
  }
  list(or = list(filters = terms))
}

rangeAsList <- function(range, field){
  stopifnot(is.vector(range) & is.numeric(range))
  fld = list(gte = range[1], lte=range[2])
  y = list(x = fld)
  names(y) = field
  list(range = y)
}

toFilter <- function(z){
  toJSON(list(bool = list(must = as.array(z))))
}

makeQuery <- function(terms="*", from=0, step=10, oper="AND",
                      elev = c(NA, NA), cntr=NULL){
  #print(elev)
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
      "filtered": {
      "query": {
        "query_string": {
          "default_operator": "_O_",
          "query": "_Q_"
        }
      }
      _E_

}
},
      "aggs" : {
        "elev_stats" : { "stats" : { "field" : "elevation" } },
        "cntr_stats" : { "terms" : { "field" : "country" } },
        "spec_stats" : { "terms" : { "field" : "species" } }
      }
      
    } '
    query = str_replace(query, "_Q_", terms)
    query = str_replace(query, "_S_", step)
    query = str_replace(query, "_O_", oper)
    query = str_replace(query, "_F_", from)
    
    elevS = ""
    if(!is.na(elev[1]) | !is.null(cntr)){
#       elv = '
#       ,
#         "filter" : {
#             "range" : {
#                 "elevation" : {
#                     "gte": _E1_,
#                     "lte": _E2_
#                 }
#             }
#         } 
#       '
#       elevS = str_replace(elv, "_E1_", elev[1])
#       elevS = str_replace(elevS, "_E2_", elev[2])
#       print(elevS)
    elevS = ',
    "filter": _EF_
    '
    z = list()
    j = 0
    if(!is.null(cntr)){
      j = j+1
      z[[j]] = termsAsList(cntr, "country")    
    }
    
    if(!is.na(elev[1])){
      j = j+1
      z[[j]] = rangeAsList(elev, "elevation")  
    }
    
    
    zz = toFilter(z)
    elevS = str_replace(elevS, "_EF_", zz)
#     print(zz)
#     print(elevS)
  }
  query = str_replace(query, "_E_", elevS)
  }
  #print(query)
  #cat(query,file="query.txt")
  query
}


esSearch <- function(query = "*", 
                     url = "http://localhost", 
                     port = 9200, 
                     from = 0,
                     step = 10,
                     oper = "AND",
                     elev = c(NA, NA),
                     cntr =NULL
                     ){
  url = paste(url, port, sep=":")
  url = paste(url,"_search", sep="/")
  
  query = makeQuery(query, from, step, oper, elev, cntr)
  
  x=POST(url, body = query)
  fromJSON(content(x, as="text"))
}


pasteSpec <- function(rec){
  
  rid = paste(rec$collector, ": ", rec$number, sep="")
  
  paste(a(rid,href="profiles/profile.html"),  " ",
    rec$genus, " ", rec$species, ". ", rec$country, " - ", rec$colldate,
    sep="")
}
  
  