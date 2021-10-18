splitter <- function(coins = NULL, lag.mins = 60, test.split = 0.2, val.split = 0.1, 
                     FUN = function(open, close, high, low) {(close - open)/open}) {
  
  require(dplyr);
  
  if(isTRUE(all.equal(test.split + val.split, 1))) {stop("Test and validation split sum to one!");};
  
  tweets = read.csv("./SENTICOIN/data/raw/twitter/@portfolio/csv/tweets.csv");
  tweets = left_join(tweets, {tweets %>% group_by(coin) %>% summarize(freq = n())}, by = "coin");
  tweets = tweets[order(tweets$tweet_id, -abs(tweets$freq)),][!duplicated(tweets$tweet_id),] %>% select(-freq);
  
  prices = data.frame(); 
  if(length(coins) != 0) { # Collect prices for specified coins;
    if(all(coins %in% gsub("\\..*", "", list.files("./SENTICOIN/data/raw/crypto/@portfolio/")))) {
      
      tweets = tweets[which(tweets$coin %in% coins), c("coin", "text", "created_at")];
      
      for(i in coins) {temp = read.csv(paste0("./SENTICOIN/data/raw/crypto/@portfolio/", i, ".csv"));
        temp = temp %>% mutate(coin = i) %>% select(coin, time, open, close, high, low); 
        prices = rbind(prices, temp); rm(temp);
      };
      
    } else {stop("Listed coin(s) are wrong or doesn't have prices!")};
  } else {
    
    tweets = tweets %>% select(coin, text, created_at);
    
    for(i in list.files("./SENTICOIN/data/raw/crypto/@portfolio/")) {
      temp = read.csv(paste0("./SENTICOIN/data/raw/crypto/@portfolio/", i));
      temp = temp %>% mutate(coin = gsub("\\..*", "", i)) %>% select(coin, time, open, close, high, low); 
      prices = rbind(prices, temp); rm(temp);
    };
  };
  
  # Labeling tweets with prices with a lag specified by "lag.mins";
  tweets$time = as.character(format(as.POSIXct(strptime(tweets$created_at, format = "%Y-%m-%dT%H:%M:%S.000Z", tz = "UTC")) + 60 * lag.mins, format = "%Y-%m-%d %H:00:00"));
  tweets = na.omit(left_join(tweets, prices, by = c("coin", "time")))[, -which(names(tweets) == "time")];
  
  # Defining the output;
  if(length(FUN) != 0) {
    tweets$y = FUN(tweets$open, tweets$close, tweets$high, tweets$low);
  } else {tweets$y = tweets$close}; tweets = tweets %>% select(-open, -close, -high, -low);
  tweets$y = (tweets$y - min(tweets$y)) / (max(tweets$y) - min(tweets$y));
  
  # Splitting into train, test and validation set;
  split = strptime(c("2021-08-30T00:00:00.000Z", "2021-09-27T00:00:00.000Z"), format = "%Y-%m-%dT%H:%M:%S.000Z", tz = "UTC");
  val.min  = split[2] - as.numeric(difftime(split[2], split[1], units = "hours")) * val.split * 60 * 60;
  test.min = val.min  - as.numeric(difftime(split[2], split[1], units = "hours")) * test.split * 60 * 60;
  tweets$created_at = strptime(tweets$created_at, format = "%Y-%m-%dT%H:%M:%S.000Z", tz = "UTC");
  
  return(list(`train` = tweets[which(tweets$created_at < test.min & tweets$created_at > split[1]),],
              `test`  = tweets[which(tweets$created_at < val.min  & tweets$created_at > test.min),],
              `val`   = tweets[which(tweets$created_at < split[2] & tweets$created_at > val.min),]));
};  

# Example of usage: 
# tweets <- splitter(coins = c("ADA", "XRP"), lag.mins = 150, test.split = 0.5, val.split = 0);
# train <- tweets$train; test <- tweets$test; val <- tweets$val;
# NOTE: a, b, c, and d stand for open, close, high and low.