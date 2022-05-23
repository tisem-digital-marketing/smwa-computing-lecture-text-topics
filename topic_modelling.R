#' topic_modelling.R
#' 
#' contributors: 
#'
#' What this file does"
#' - Explores the stm package for topic modelling as applied to tidied tweets from Trump in early 2020
#'

# --- Library --- #
library(readr)
library(dplyr)
library(tibble)
library(tidytext)
library(textstem)
library(stm)
library(ggplot2)

# --- load the data --- # 
tidy_trump <- read_csv('data/tidy_trump.csv')

# --- Data Cleaning --- #
# Need stop word removal
# And lemmatize


# --- Establish a Vocab List --- #
# Keep any word that appears > 5 times
# Note: this is a little ad-hoc
# Should explore sensitivity to choice or use TF-IDF 

# set up what my vocab list will be


# Keep only those words in data

# only keep words from my vocab list


# --- Create Doc-Term-Matrix --- #

# cast this to a matrix


# --- Model! --- #
# model


# --- Explore Output --- #

# top 10 words per topic visualized

td_beta %>%
    group_by(topic) %>%
    top_n(10, beta) %>%
    ungroup() %>%
    mutate(topic = paste0("Topic ", topic),
           term = reorder_within(term, beta, topic)) %>%
    ggplot(aes(term, beta, fill = as.factor(topic))) +
    geom_col(alpha = 0.8, show.legend = FALSE) +
    facet_wrap(~ topic, scales = "free_y") +
    coord_flip() +
    scale_x_reordered() +
    labs(x = NULL, y = expression(beta),
         title = "Highest word probabilities for each topic",
         subtitle = "Different words are associated with different topics")

# Suppose we want to assign human readable labels to topics:
td_beta <- 
    td_beta %>%
    mutate(topic_name = case_when(
        topic == 1 ~ "topic 1", # ie. name it something meaningful,
        topic == 2 ~ "topic 2",
        topic == 3 ~ "topic 3",
        topic == 4 ~ "topic 4",
        topic == 5 ~ "topic 5",
        topic == 6 ~ "topic 6",
        topic == 7 ~ "topic 7",
        topic == 8 ~ "topic 8",
        topic == 9 ~ "topic 9",
        topic == 10 ~ "topic 10",
        topic == 11 ~ "topic 11",
        TRUE ~ "topic 12"
        )
    )

# regraph!

# --- Assigning Topics to Tweets --- #
    

# give each tweet its most probably topic..
tweets_gamma <- 
    td_gamma %>%
    rename(id = document) %>%
    mutate(id = as.numeric(id)) %>%
    group_by(id) %>%
    slice_max(gamma) %>%
    select(-gamma)

# --- Topic Trends --- #
