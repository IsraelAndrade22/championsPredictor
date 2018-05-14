
library(DBI)

db <- dbConnect(RSQLite::SQLite(),"database.sqlite")

Country <- dbGetQuery(db,"Select * from Country")
Match <- dbGetQuery(db,"Select * from Match")
League <- dbGetQuery(db,"Select * from League")
Team <- dbGetQuery(db,"Select * from Team")
Team_Attributes <- dbGetQuery(db,"Select * from Team_Attributes")

head(Match)

head(Match$shoton, 10)
Match[12:78] = NULL
Match[19:48] = NULL           

#  convert columns 12 -18 to numeric
Match[, 12:18] <- sapply(Match[, 12:18], as.numeric)

#replace all NAs with 0s
Match = replace(Match, is.na(Match), 0)
Team = replace(Team, is.na(Team), 0)
summary(Match)
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

# rename duplicate column
names(new_match_data)[3]<-"away_team_api_id"
names(new_match_data)[names(new_match_data)=="Var1"] <- "home_team_api_id"
head(new_match_data)
for(row1 in rownames(new_match_data))
{
  home_indexes = which(Match$home_team_api_id == new_match_data$home_team_api_id[as.numeric(row1)])
  new_match_data$country[as.numeric(row1)] <- Country$name[Country$id==Match$country_id[as.numeric(home_indexes[1])]]
  new_match_data$team_name[as.numeric(row1)] <- Team$team_long_name[Team$team_api_id==new_match_data$home_team_api_id[as.numeric(row1)]]
}

#Iterate over all the teams ids
for(id in rownames(new_match_data))
{
  #win_count stores the number of wins if the current team has scored more goals than the opponent team.
  win_count = 0
  #Find all the records in main "Match" table which match the current team id
  home_indexes = which(Match$home_team_api_id == new_match_data$home_team_api_id[as.numeric(id)])
  away_indexes = which(Match$away_team_api_id == new_match_data$away_team_api_id[as.numeric(id)])

  for(i in home_indexes)
  {
    if(Match$home_team_goal[i]>Match$away_team_goal[i])
    {
      win_count = win_count +1
    }
  }
  for(i in away_indexes)
  {
    if(Match$away_team_goal[i]>Match$home_team_goal[i])
    {
      win_count = win_count + 1
    }
  }

  new_match_data$wins[as.numeric(id)] <- win_count
  new_match_data$win_percentage[as.numeric(id)] <- as.double(win_count/new_match_data$total_matches[as.numeric(id)]*100)
}

#Drop Away_team_id column and change home_team_api_id columns name to team_id
drop_columns <- c("away_team_api_id")
new_match_data <- new_match_data[ , !names(new_match_data) %in% drop_columns]
names(new_match_data)[names(new_match_data)=="home_team_api_id"]<-"team_id"

#Sort the teams based on the winning percentage
sorted_data <- new_match_data[order(-new_match_data$win_percentage),]
barplot(sorted_data[0:10,]$win_percentage, names.arg=sorted_data[0:10,]$team_name, ylab = "Winning Percentage", las = 2, col = "blue", main = "Top 10 winning percentages")


#Find Best teams in England's England Premier League
english_team <- sorted_data[sorted_data$country=="England",]
england <- english_team[order(-english_team$win_percentage),][1:10,]
barplot(england$win_percentage, names.arg=england$team_name, ylab = "Winning Percentage", las = 2, col = "blue", main = "Top 10 teams in Premier League")

#Find the top teams from spain league
spain_teams <- sorted_data[sorted_data$country=="Spain",]
spain <- spain_teams[order(-spain_teams$win_percentage),][1:10,]
barplot(spain$win_percentage, names.arg=spain$team_name, ylab = "Winning Percentage", las = 2, col = "blue", main = "Top 10 teams in Bundesliga League")
axis(1,cex.axis=1)
#Find top teams in Germany's l Bundesliga League
german_team <- sorted_data[sorted_data$country=="Germany",]
germany <- german_team[order(-german_team$win_percentage),][1:10,]
barplot(germany$win_percentage, names.arg=germany$team_name, ylab = "Winning Percentage", las = 2, col = "blue", main = "Top 10 teams in Bundesliga League")

