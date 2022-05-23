#' tidy_tweets.R
#' 
#' contributors: @lachlandeer
#'
#' What this file does"
#' - Tidies up Trump tweets to be a "tidy" text data frame ready for further analysis
#'

# --- Library --- #
library(readr)
library(dplyr)
library(tibble)
library(stringr)
library(tidytext)
library(tokenizers)
library(lubridate)

# --- read data --- #

tweets <- read_csv('data/trump_early_2020_tweets.csv')

# add calender week to data
tweets <-
    tweets %>%
    mutate(cal_week = week(date_est))

# --- Clean Twitter Junk --- #

tweets <-
    tweets %>%
    mutate(
        # remove links
        text = str_remove_all(text, "https\\S*"),
        text = str_remove_all(text, "http\\S*"),
        text = str_remove_all(text, "t.co*"),
        # remove mentions
        text = str_remove_all(text, "@\\S*"),
        # remove annoying html stuff
        text = str_remove_all(text, "amp"),
        text = str_remove_all(text, "&S*"),
        text = str_replace_all(text, "&#x27;|&quot;|&#x2F;", "'"),
        text = str_replace_all(text, "<a(.*?)>", " "),
        text = str_replace_all(text, "&gt;|&lt;|&amp;", " "),
        text = str_replace_all(text, "&#[:digit:]+;", " "),
        text = str_remove_all(text, "<[^>]*>"),
        # remove numbers
        text = str_remove_all(text, "[:digit:]"),
        # remove excess whitespace
        text = str_squish(text),
        text = str_trim(text),
        # remove RT for retweets -- keeping retweets in the data
        text = str_remove_all(text, "RT")
    ) %>%
    filter(count_words(text) > 1) %>%
    rownames_to_column("id") %>%
    select(-text_id)

write_csv(tweets, "data/tweets_cleaned.csv")

# --- Tweets to Tidy Tweets --- #

tidy_tweets <-
    tweets %>%
    unnest_tokens(word, text, token = "tweets")

# --- Save --- #
write_csv(tidy_tweets, "data/tidy_trump.csv")
