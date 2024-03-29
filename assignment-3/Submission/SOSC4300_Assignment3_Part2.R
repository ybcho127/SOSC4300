library("quanteda")
library("quanteda.textplots")
library("stm")
library("dplyr")


# Set working directory, import dataset and remove unnecessary features.
getwd()
setwd('/Users/iancho/Desktop/pythontest/SOSC_4300/Assignment_3')

comments <- read.csv("comments.csv")

comments <- comments%>%select(-post_id,-post_author,-post_date,-post_title,-post_score,-post_permalink,
                              -post_url,-comment_parent_id, -comment_author, -comment_id)


# Change comments$comment_body into corpus, and convert it as dfm matrix.

test_corpus <- corpus(comments, text_field = 'comment_body')

dfm_data <- dfm(test_corpus, remove_punct = TRUE, stem = TRUE, tolower=TRUE, remove=c(
  stopwords("english"), "the", "t.co", "https", "rt", "amp", "http", "t.c", "can", "u", "<", ">", "br","____",
  '_20','_2466','_5fbcf15cc5b66bb88c615c22', '☺', '🤢', '🤷🏻‍♂', '🧡', '😅', '😆', '😔', '😞', '😳', '😷',
  '-94', '-94f', '®', '🌧', '👀', '👌', '💐', '💪🏻', '🤪', '🥳' ,  '=', '🙃', '1.4mm', '104', '130s', '15pm', '18-40', '1a', '2-3x', '2006', '2025', '_2', '_a','_14', '_50', '_bot','r','1c','`', '°', '£', '100m', '300', '91', '99','😎', '😩', '109k', '20s', '30-someth', '30s', '34k', '3am', '40s','1796', '1million', '40-50', '60m', '70000', '75-80', '99.998', '_5fb42aa3c5b6f79d601bb8ec',
  '_canada#ag', '_captur', '_casesper100klast7day'),remove_url=TRUE, verbose=TRUE) %>% dfm_trim(min_count = 100)


# Check if it's well converted, find 25 most frequently appeared words.
topfeatures(dfm_data, 25)

# Wordcloud plot of the dfm_data

textplot_wordcloud(dfm_data, rotation=0, min_size=2, max_size=10, max_words=100)

# Import positive negative words documents and create dictionary, 
# then dalculate the word cound ot positive words, negative words in sentences.

pos.words <- read.csv("positive-words.txt",
                      stringsAsFactors = FALSE, header = FALSE)$V1
neg.words <- read.csv("negative-words.txt",
                      stringsAsFactors = FALSE, header = FALSE)$V1
mydict <- dictionary(list(positive = pos.words,
                          negative = neg.words))
sent <- dfm(dfm_data, dictionary = mydict)

numerator <- as.numeric(sent[,1]) + -1 * as.numeric(sent[,2])
denominator <- ntoken(dfm_data) 
sent_continuous <- numerator/denominator


# Look at the sentiment distribution plot.
plot(density(sent_continuous[!is.na(sent_continuous)]))

# There's a high peak in the 0.0 part, it's because the nominator vale for the sentence is 0 
# (no positive or negative words). We'll see how many words are labeled as positive, negative, 
# or neutral(neither positive nor negative).

neutral <- length(which(sent_continuous == 0.0))
negative <- length(which(sent_continuous < 0.0))
positive <- length(which(sent_continuous > 0.0))

print(positive)
print(neutral)
print(negative)

# Although the size of neutral value is the biggest, still the size of positive or 
#negative values are still enough.

comments <- cbind(comments, sent_continuous)

# Do the same thing since we have modified the dataframe a bit.
test_corpus <- corpus(comments, text_field = 'comment_body')

dfm_data <- dfm(test_corpus, remove_punct = TRUE, stem = TRUE, tolower=TRUE, remove=c(
  stopwords("english"), "the", "t.co", "https", "rt", "amp", "http", "t.c", "can", "u", "<", ">", "br","____",
  '_20','_2466','_5fbcf15cc5b66bb88c615c22', '☺', '🤢', '🤷🏻‍♂', '🧡', '😅', '😆', '😔', '😞', '😳', '😷',
  '-94', '-94f', '®', '🌧', '👀', '👌', '💐', '💪🏻', '🤪', '🥳' ,  '=', '🙃', '1.4mm', '104', '130s', '15pm', 
  '18-40', '1a', '2-3x', '2006', '2025', '_2', '_a','_14', '_50', '_about_', '_air', '_always_', '_articl', 
  '_bot','r','1c','`', '°', '£', '100m', '300', '91', '99','😎', '😩', '109k', '20s', '30-someth', '30s', '34k', 
  '3am', '40s','1796', '1million', '40-50', '60m', '70000', '75-80', '99.998','_5fb42aa3c5b6f79d601bb8ec',
  '_canada#ag', '_captur', '_casesper100klast7day'),remove_url=TRUE, verbose=TRUE) %>% dfm_trim(min_count = 100)

dfm_out <- convert(dfm_data, to = 'stm', docvars = docvars(test_corpus))


# We have added the covariate sentiment in the stm model and run the model. 
# Since we have limited the topic to 4 in python model, we set the number of topics as 4 for comparison.
comments_4 <- stm(documents = dfm_out$documents,
                  vocab = dfm_out$vocab,
                  data = dfm_out$meta,
                  prevalence = ~ sent_continuous,
                  K = 4, verbose = TRUE)


#Explicity estimate effect of covariates on topic proportions
sc_4 <- estimateEffect(1:4 ~ sent_continuous, comments_4,
                       meta = dfm_out$meta)
summary(sc_4)


#Check the words in each topics
labelTopics(comments_4, n = 10)


#Plot the trend of the topics occurance based on the sentiment
plot(sc_4, covariate = "sent_continuous",  model = comments_4, method =  "continuous")
