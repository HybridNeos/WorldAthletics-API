library(rvest)
library(RSelenium)
library(seleniumPipes)
library(lubridate)
#library(ggplot2)
#library(igraph)

# set it up
rd <- rsDriver(port=449L, browser="chrome", chromever="81.0.4044.138", verbose=FALSE)
rem_dr <- rd$client

# go to results
url <- "https://www.worldathletics.org/athletes/new-zealand/tomas-walsh-247664"
rem_dr$navigate(url)
rem_dr$findElement(using="xpath", value="//*/ul/li/a[contains(@href, '#results')]")$clickElement()

# select year and make by date
rem_dr$findElement(using="xpath", value="//*/select[@name='resultsByYear']/option[@value='2019']")$clickElement()
rem_dr$findElement(using="xpath", value="//*/select[@name='resultsByYearOrderBy']/option[@value='date']")$clickElement()

# find the html and turn it into a dataframe
elem <- rem_dr$findElement(using="xpath", value="//*/table[contains(@class, 'athletes-results-table')]")
raw <- elem$getElementAttribute("outerHTML")[[1]]
df <- minimal_html(raw) %>% html_node("table") %>% html_table()

# data cleaning
# --wind and remark can be additional columns
# --OC for olympic qualifier is a place
df$Date <- dmy(df$Date)
colnames(df)[which(names(df) == "Pl.")] <- "Place"
df$Place <- as.integer(df$Place)

# close
rem_dr$close()
rd$server$stop()