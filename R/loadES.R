library(exsic)
library(httr)
library(rjson)
library(stringr)

df = system.file("samples/exsic.csv", package="exsic")

dat = read.csv(df, stringsAsFactors = FALSE)


# PUT("http://localhost:9200/movies/movie/1", body= '
# {
#     "title": "The Godfather",
#     "director": "Francis Ford Coppola",
#     "year": 1972
#     }')

host = "http://localhost:9200"

rec2ES <- function(rec, index, entry, nr, host = "http://localhost:9200"){
  url = paste(host, index, entry, nr, sep="/")
  
  body = toJSON(rec)
  PUT(url, body=body)
}


loadPotato <- function(){
  elevation = str_replace(elevation, " m","")
  elevation = as.integer(elevation)
  dat = cbind(dat, elevation)
  
  
  for(i in 1:nrow(dat)) rec2ES(dat[i, ], "specimens", "specimen", i)  
}
