
library(DBI)

db <- dbConnect(RSQLite::SQLite(),"./database.sqlite")

Country <- dbGetQuery(db,"Select * from Country")
Match <- dbGetQuery(db,"Select * from Match")
League <- dbGetQuery(db,"Select * from League")
Team <- dbGetQuery(db,"Select * from Team")

Team = Team[,colMeans(is.na(Team)) == 0] 
Match = Match[,colMeans(is.na(Match)) == 0] 

summary(Match)
summary(Team)

#Count the number of matches the particular team played at home
home_match = table(Match$home_team_api_id)
#Count the number of matches the particular team played at home
away_match = table(Match$away_team_api_id)

