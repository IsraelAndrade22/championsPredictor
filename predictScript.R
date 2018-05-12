
library(DBI)

db <- dbConnect(RSQLite::SQLite(),"./database.sqlite")

Country <- dbGetQuery(db,"Select * from Country")
Match <- dbGetQuery(db,"Select * from Match")
League <- dbGetQuery(db,"Select * from League")
Team <- dbGetQuery(db,"Select * from Team")

head(Match)

# replace all NAs with 0s
Match = replace(Match, is.na(Match), 0)
Team = replace(Team, is.na(Team), 0)

summary(Match)
summary(Team)
str(Match)

#Count the number of matches the particular team played at home
home_match = as.data.frame(table(Match$home_team_api_id))

#Count the number of matches the particular team played at home
away_match = as.data.frame(table(Match$away_team_api_id))

names(home_match)[names(home_match)=="Freq"] <- "home_matches_number"
names(away_match)[names(away_match)=="Freq"] <- "away_matches_number"

new_match_data <- as.data.frame(cbind(home_match,away_match))

new_match_data$total_matches =  new_match_data$home_matches_number + new_match_data$away_matches_number
new_match_data$wins = 0
new_match_data$win_percentage = 0
new_match_data$country = ""
new_match_data$team_name = ""

# delete duplicate column
new_match_data[3] = NULL
names(new_match_data)[names(new_match_data)=="Var1"] <- "home_team_api_id"
head(new_match_data)
for(row1 in rownames(new_match_data))
{
  home_indexes = which(Match$home_team_api_id == new_match_data$home_team_api_id[as.numeric(row1)])
  new_match_data$country[as.numeric(row1)] <- Country$name[Country$id==Match$country_id[as.numeric(home_indexes[1])]]
  new_match_data$team_name[as.numeric(row1)] <- Team$team_long_name[Team$team_api_id==new_match_data$home_team_api_id[as.numeric(row1)]]
}


