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

formatES <-function(index, entry, host = "http://localhost:9200"){
  url = paste(host, index, sep="/")
  format = '
{
  "mappings": {
   "specimen" : {
        "properties" : {
            "genus" : {"type" : "string", "null_value" : ""},
            "species" : {"type" : "string", "null_value" : ""},
            "collector" : {"type" : "string", "null_value" : ""},
            "number" : {"type" : "string", "null_value" : ""},
            "addcoll" : {"type" : "string", "null_value" : ""},
            "dups" : {"type" : "string", "null_value" : ""},
            "majorarea" : {"type" : "string", "null_value" : ""},
            "minorarea" : {"type" : "string", "null_value" : ""},
            "locnotes" : {"type" : "string", "null_value" : ""},
            "altitude" : {"type" : "string", "null_value" : ""},
            "colldate" : {"type" : "string", "null_value" : ""},
            "latitude" : {"type" : "string", "null_value" : ""},
            "longitude" : {"type" : "string", "null_value" : ""},
            "country" : {"type" : "string", "null_value" : ""},
            "collcite" : {"type" : "string", "null_value" : ""},
            "phenology" : {"type" : "string", "null_value" : ""},
            "elevation" : {"type" : "integer", "null_value": ""}
        }
    }
 }
}
'
  PUT(url, body=format)
  
}

rec2ES <- function(rec, index, entry, nr, host = "http://localhost:9200"){
  url = paste(host, index, entry, nr, sep="/")
  
  body = toJSON(rec)
  
  body = gsub('\\"NA\\"',"null", body)
  PUT(url, body=body)
}


loadPotato <- function(){
  elevation = str_replace(dat$altitude, " m","")
  #elevation = as.integer(elevation)
  dat = cbind(dat, elevation)
  dat$elevation = as.character(dat$elevation)
  dat$elevation = as.integer(dat$elevation)
  
  for(i in 1:nrow(dat)) {
    rec2ES(dat[i, ], "specimens", "specimen", i)  
  }
  dat
}

dat = loadPotato()


