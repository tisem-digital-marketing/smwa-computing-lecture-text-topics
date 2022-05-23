#' topic_modelling.R
#' 
#' contributors: @lachlandeer
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

tidy_trump <- 
    tidy_trump %>% 
    anti_join(stop_words) %>%
    mutate(word_lemma = lemmatize_words(word))

# --- Establish a Vocab List --- #
# Keep any word that appears > 5 times
# Note: this is a little ad-hoc
# Should explore sensitivity to choice or use TF-IDF 

# set up what my vocab list will be
word_counts <- 
    tidy_trump %>%
    group_by(word) %>%
    count(sort = TRUE) %>%
    filter(n > 5)

# Keep only those words in data

# only keep words from my vocab list
tidy_trump <- 
    tidy_trump %>%
    filter(word %in% word_counts$word)

# --- Create Doc-Term-Matrix --- #
doc_word_counts <- 
    tidy_trump %>%
    count(id, word) %>%
    ungroup()

# cast this to a matrix
trump_dtm <- 
    doc_word_counts %>%
    cast_sparse(id, word, n)

# --- Model! --- #
# model
trump_topics <-
    stm(trump_dtm,
        # why 10 topics, why not, its an example
        K = 16,
        # seed fixes the random number draw
        # so we should all get the same results
        seed = 123456789)

# --- Explore Output --- #
labelTopics(trump_topics)

# top 10 words per topic visualized
td_beta <- tidy(trump_topics)

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
td_gamma <- 
    tidy(trump_topics, 
         matrix = "gamma",                    
         document_names = rownames(trump_dtm)
         ) %>%
    arrange(as.numeric(document), desc(gamma))
    

# give each tweet its most probably topic..
tweets_gamma <- 
    td_gamma %>%
    rename(id = document) %>%
    mutate(id = as.numeric(id)) %>%
    group_by(id) %>%
    slice_max(gamma) %>%
    select(-gamma)

tweets <- read_csv("data/tweets_cleaned.csv")

tweets <-
    tweets %>%
    inner_join(tweets_gamma, by = "id")

# --- Topic Trends --- #
topic_trends <- 
    tweets %>%
    group_by(cal_week, topic) %>%
    count() %>%
    ungroup()

topic_trends %>%
    #filter(topic %in% c(1, 2, 9, 10)) %>%
    ggplot(aes(
        x = cal_week, 
        y = n
    )
    ) +
    geom_line() + 
    facet_wrap(~topic) +
    theme_bw()


#--- Misc Extras --- #
# Time Dependent: Short Version in Instructor Notes
# See STM vignette for more details

# STM allows topics to be correlated, are they in this instance?
topicCorr(trump_topics, verbose = FALSE)
plot(topicCorr(trump_topics, verbose = FALSE))

# can the computer pick the "right" number of topics?
trump_topics_Kchosen <-
    stm(trump_dtm,
        # why 10 topics, why not, its an example
        K = 0,
        # seed fixes the random number draw
        # so we should all get the same results
        seed = 123456789)

topicCorr(trump_topics_Kchosen, verbose = FALSE)
plot(topicCorr(trump_topics_Kchosen, verbose = FALSE))

# Can we choose between our own guesses at the right topic number?
n_tops <- c(12,16,20,24,28,32,36,40)
set.seed(123456789)
topic_search <- searchK(trump_dtm, K = n_tops, 
                # N is the number of docs not included in estimation so that
                # can evaluate model on a "fresh" set of docs
                # we're using approx 10% of the rows
                N = floor(0.1*nrow(trump_dtm)))
plot(topic_search)
