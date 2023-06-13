message('Loading Packages')
library(rvest)
library(tidyverse)

message('Scraping Data')
url<-"https://yttrendz.com/youtube-trends/indonesia"
yttrends<-read_html(url)
yt<-yttrends %>% html_nodes(".feed-content") %>% html_text2() %>% str_split("\n")
urutan <- yttrends %>% html_nodes(".feed-count") %>% html_text2()
data<-data.frame(URUTAN=0,JUDUL=0,VIEWS=0,LIKES=0,COMMENTS=0,UPLOADBY=0,UPLOADTIME=0)
for (i in 1:10){
  data[i,1]<-as.numeric(urutan[i])
  data[i,2]<-yt[[i]][1]
  data[i,3]<-yt[[i]][2]
  data[i,4]<-yt[[i]][3]
  data[i,5]<-yt[[i]][4]
  data[i,6]<-yt[[i]][5]
  data[i,7]<-yt[[i]][7]
}

data$VIEWS<-gsub("Views", "", data$VIEWS)
data$VIEWS<-gsub("[^\\[\\]\\.[:^punct:]]", "", data$VIEWS, perl = TRUE)
data$VIEWS<-gsub("\\s", "", data$VIEWS)
data$VIEWS<-gsub("^+ Views", "\\1", data$VIEWS)

data$LIKES<-gsub("Likes", "", data$LIKES)
data$LIKES<-gsub("[^\\[\\]\\.[:^punct:]]", "", data$LIKES, perl = TRUE)
data$LIKES<-gsub("\\s", "", data$LIKES)
data$LIKES<-gsub("^+ Likes", "\\1", data$LIKES)

data$COMMENTS<-gsub("Comments", "", data$COMMENTS)
data$COMMENTS<-gsub("[^\\[\\]\\.[:^punct:]]", "", data$COMMENTS, perl = TRUE)
data$COMMENTS<-gsub("\\s", "", data$COMMENTS)
data$COMMENTS<-gsub("^Comments", "\\1", data$COMMENTS)

data$UPLOADTIME<-gsub(".*on","",data$UPLOADBY) 
data$UPLOADBY<-gsub("\\son.+$", "", data$UPLOADBY)
data$UPLOADBY<-gsub("Upload by : ", "\\1", data$UPLOADBY)
data$WAKTUSCRAPE<-Sys.time()

#MONGODB
message('Input Data to MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

atlas_conn$insert(data)
rm(atlas_conn)
