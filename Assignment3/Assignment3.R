#install.packages('wordcloud')
#install.packages("tm")
install.packages("quanteda.textplots")

library("quanteda")
library("quanteda.textplots")
library("stm")
library("dplyr")

getwd()
setwd('/Users/iancho/Desktop/pythontest/SOSC_4300/Assignment_3')

comments <- read.csv("comments.csv")

comments <- comments%>%select(-post_id,-post_author,-post_date,-post_title,-post_score,-post_permalink,
                              -post_url,-comment_parent_id, -comment_author, -comment_id)

test_corpus <- corpus(comments, text_field = 'comment_body')

kwic(x = test_corpus, pattern = "like", window=5, separator = "|")[1:5,]

data <- dfm(test_corpus, stem = TRUE, tolower=TRUE, remove = stopwords('english'),
            remove_punct = TRUE, remove_url=TRUE, verbose=TRUE) %>% dfm_trim(min_count = 2)

dfm_data <- dfm(test_corpus, remove_punct = TRUE, stem = TRUE, tolower=TRUE, remove=c(
  stopwords("english"), "the", "t.co", "https", "rt", "amp", "http", "t.c", "can", "u", "<", ">", "br","____",
  '_20','_2466','_5fbcf15cc5b66bb88c615c22', '☺', '🤢', '🤷🏻‍♂', '🧡', '😅', '😆', '😔', '😞', '😳', '😷',
  '-94', '-94f', '®', '🌧', '👀', '👌', '💐', '💪🏻', '🤪', '🥳' ,  '=', '🙃', '1.4mm', '104', '130s', '15pm', 
  '18-40', '1a', '2-3x', '2006', '2025', '_2', '_a','_14', '_50', '_about_', '_air', '_always_', '_articl', 
  '_bot','r','1c','`', '°', '£', '100m', '300', '91', '99','😎', '😩', '109k', '20s', '30-someth', '30s', '34k', 
  '3am', '40s','1796', '1million', '40-50', '60m', '70000', '75-80', '99.998','_5fb42aa3c5b6f79d601bb8ec',
  '_canada#ag', '_captur', '_casesper100klast7day'),remove_url=TRUE, verbose=TRUE) %>% dfm_trim(min_count = 100)


topfeatures(data, 25)

textplot_wordcloud(data, rotation=0, min_size=2, max_size=10, max_words=100)

pos.words <- read.csv("positive-words.txt",
                      stringsAsFactors = FALSE, header = FALSE)$V1
head(pos.words)

neg.words <- read.csv("negative-words.txt",
                      stringsAsFactors = FALSE, header = FALSE)$V1
head(neg.words)

mydict <- dictionary(list(positive = pos.words,
                          negative = neg.words))

sent <- dfm(data, dictionary = mydict)
sent

numerator <- as.numeric(sent[,1]) + -1 * as.numeric(sent[,2])
denominator <- ntoken(data) # or use rowSums(); it's the same
sent_continuous <- numerator/denominator
plot(density(sent_continuous[!is.na(sent_continuous)]))

neutral <- length(which(sent_continuous == 0.0))
negative <- length(which(sent_continuous < 0.0))
positive <- length(which(sent_continuous > 0.0))

comments <- cbind(comments, sent_continuous)

test_corpus <- corpus(comments, text_field = 'comment_body')


dfm_data <- dfm(test_corpus, remove_punct = TRUE, stem = TRUE, tolower=TRUE, remove=c(
  stopwords("english"), "the", "t.co", "https", "rt", "amp", "http", "t.c", "can", "u", "<", ">", "br","____",
  '_20','_2466','_5fbcf15cc5b66bb88c615c22', '☺', '🤢', '🤷🏻‍♂', '🧡', '😅', '😆', '😔', '😞', '😳', '😷',
  '-94', '-94f', '®', '🌧', '👀', '👌', '💐', '💪🏻', '🤪', '🥳' ,  '=', '🙃', '1.4mm', '104', '130s', '15pm', 
  '18-40', '1a', '2-3x', '2006', '2025', '_2', '_a','_14', '_50', '_about_', '_air', '_always_', '_articl', 
  '_bot','r','1c','`', '°', '£', '100m', '300', '91', '99','😎', '😩', '109k', '20s', '30-someth', '30s', '34k', 
  '3am', '40s','1796', '1million', '40-50', '60m', '70000', '75-80', '99.998','_5fb42aa3c5b6f79d601bb8ec',
  '_canada#ag', '_captur', '_casesper100klast7day'),remove_url=TRUE, verbose=TRUE) %>% dfm_trim(min_count = 100)



dfm_out <- convert(dfm_data, to = 'stm')


comments_4 <- stm(documents = dfm_out$documents,
                  vocab = dfm_out$vocab,
                  data = dfm_out$meta,
                  prevalence = ~ sent_continuous,
                  K = 4, verbose = TRUE)
sc_4 <- estimateEffect(1:4 ~ sent_continuous, comments_4,
                         meta = dfm_out$meta)
summary(sc_4)

labelTopics(comments_4, n = 10)


plot(sc_4, covariate = "sent_continuous",  model = comments_3, method =  "continuous")

