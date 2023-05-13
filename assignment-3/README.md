# Assignment3

Please download the dataset in this link

https://www.kaggle.com/datasets/xhlulu/covid19-vaccine-news-reddit-discussions?select=comments.csv

*NOTE*: 
- There are **NO** correct answers for this assignment. That is a feature of unsupervised tasks.
- Make sure you label the sections of your work clearly and include addequate documentation and explanation of your results. 

### 1. Word Embedding

#### 1.1 Use pre-trained embedding to find similar words (15%)
- find the top 5 similar words for each of the following word. You need to tell us the similar words, but also what pre-trained embedding model you have used (e.g., word2vec, GloVe, or even your own)
  - vaccine
  - sad

#### 2.2 Visualization (20%)

- Visualize the word embeddings using TSNE. 

Rubrics:
- A good visualization should allow you to find some patterns.
- If you cannot visulize all words, consider keep only the most frequent (like top 1000) or most relevant (like those related to vaccines and health and other COVID related words).

### 2. Topic Modeling

#### 2.1 LDA (25%)
- Run topic models on the `comment_body` column. What are the topics you picked up? 
- How many topics ($K$) you used? How did you make a decision on these variables?
- Other strategies you have considered and tried? Such as removing stop words? Remove infrequent words? Others?
  
#### 2.2 Sentiment (10%)
- Produce a sentiment score of the `comment_body` column. After Assignment 2 you should be familiar with this task. Freely use any method that you think is accurate. The sentiment scores can be either of:
   - binary (positive vs. negative)
   - categorical (e.g., positive, neutral, and negative)
   - continuous (a continuous score of sentiments)
- Present the distributions of sentiment scores (e.g., how many comments are positive and how many are negative? if you use continuous score, plot the probability distribution of sentiments)

#### 2.3 Adding covariates to topic modeling (30%)

- Fit topic models by sentiments; discuss how topics vary by the sentiment.
- If you use R, it would be easier to use the `STM` package and see the topic prevalance by sentiments.
- Note: There may not be a Python equivalent of the STM package. So if you do not know how to use R, it would be easier if run LDA for each subgroup (e.g., positive and negative comments) separately. It would be even better to compare R and Python's differences if you know both languages; they will probably return different results.
