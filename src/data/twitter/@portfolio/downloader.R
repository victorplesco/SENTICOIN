#################################################################################################################################################################################################################################################################################
## Setup Environment ############################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

require(devtools); load_all("./SENTICOIN/src/packages/racademic/"); 
token <- v2_create_token(token = "INSERT_NEW_KEY");

#################################################################################################################################################################################################################################################################################
## Data #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

coins = c("LTC", "ETH", "XRP", "ADA", "DOGE", "DOT", "SOL", "UNI", "AVAX");
start_time = "2021-08-30T00:00:01Z"; end_time = "2021-09-27T00:00:01Z";

#################################################################################################################################################################################################################################################################################
## Download Tweets for Cryptocurrency Portfolio #################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

home.path = paste0("./SENTICOIN/data/raw/twitter/@portfolio/rds"); for(i in coins) {dir.create(paste0(home.path, "/", i));  
  tweets <- v2_search_fullarchive(token = token, next_token = NULL, safe.dir = paste0(home.path, "/", i), 
                                  query = paste0("$", i, " -is:retweet -is:reply -is:quote lang:en"), max_results = 500, 
                                  start_time = start_time, end_time = end_time, since_id = NULL, until_id = NULL,
                                  tweet.fields = c("id", "text", "author_id", "conversation_id", "created_at", "reply_settings",
                                                   "public_metrics", "lang", "possibly_sensitive", "in_reply_to_user_id", "source"),
                                  user.fields = NULL, media.fields = NULL, place.fields = NULL, poll.fields = NULL, expansions = NULL); 
  cat("\n\n Coin : ", i, "\n\n");
}; rm(i, home.path, start_time, end_time, token, tweets); 

#################################################################################################################################################################################################################################################################################
## Merging racademic Files and Saving to .csv ###################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

{start_time <- Sys.time(); 
  home.path <- "./SENTICOIN/data/raw/twitter/@portfolio/rds/"; chunk.path = "./SENTICOIN/src/data/twitter/@portfolio/chunks/"; dir.create(chunk.path); 
  for(i in 1:length(coins)) {cat("Cryptocurrency: ", coins[i], "\n"); 
    
    temp_static_main = list(`data`= list(), 
                            `includes` = list(`tweets` = list(),
                                              `places` = list(),
                                              `users`  = list(), 
                                              `media`  = list(), 
                                              `polls`  = list()),
                            `errors` = list());
    
    racademic.files = list.files(paste0(home.path, coins[i], "/"));
    for(j in list.files(paste0(home.path, coins[i], "/", racademic.files, "/content/"))) {
      parsed.content = readRDS(paste0(home.path, coins[i], "/", racademic.files, "/content/", j));
      
      temp_static_main$data = append(temp_static_main$data, parsed.content$data);
      temp_static_main$includes$tweets = unique(append(temp_static_main$includes$tweets, parsed.content$includes$tweets));
      temp_static_main$includes$places = unique(append(temp_static_main$includes$places, parsed.content$includes$places));
      temp_static_main$includes$users  = unique(append(temp_static_main$includes$users,  parsed.content$includes$users));
      temp_static_main$includes$media  = unique(append(temp_static_main$includes$media,  parsed.content$includes$media));
      temp_static_main$includes$polls  = unique(append(temp_static_main$includes$polls,  parsed.content$includes$polls));
      temp_static_main$errors = append(temp_static_main$errors, parsed.content$errors);
    }; rm(j, parsed.content, racademic.files);
    
    saveRDS(data.frame(coin                = rep(coins[i], length(temp_static_main$data)),
                       tweet_id            = as.character(sapply(temp_static_main$data, "[[", "id")),
                       text                = sapply(temp_static_main$data, "[[", "text"), 
                       author_id           = sapply(temp_static_main$data, "[[", "author_id"), 
                       conversation_id     = sapply(temp_static_main$data, "[[", "conversation_id"), 
                       created_at          = sapply(temp_static_main$data, "[[", "created_at"), 
                       in_reply_to_user_id = as.character(as.matrix(sapply(temp_static_main$data, "[[", "in_reply_to_user_id"))),
                       lang                = sapply(temp_static_main$data, "[[", "lang"), 
                       possibly_sensitive  = sapply(temp_static_main$data, "[[", "possibly_sensitive"), 
                       retweet_count       = sapply(as.data.frame(t(sapply(temp_static_main$data, "[[", "public_metrics")))$retweet_count, "[[", 1),
                       reply_count         = sapply(as.data.frame(t(sapply(temp_static_main$data, "[[", "public_metrics")))$reply_count, "[[", 1),
                       like_count          = sapply(as.data.frame(t(sapply(temp_static_main$data, "[[", "public_metrics")))$like_count, "[[", 1),
                       quote_count         = sapply(as.data.frame(t(sapply(temp_static_main$data, "[[", "public_metrics")))$quote_count, "[[", 1),
                       reply_settings      = sapply(temp_static_main$data, "[[", "reply_settings"), 
                       source              = sapply(temp_static_main$data, "[[", "source")),
            paste0(chunk.path, coins[i], ".RDS")); # rm(temp_static_main);
    
    if(i == length(coins)) {temp_static_main = data.frame();
    for(k in list.files(chunk.path)) {temp_static_main = dplyr::bind_rows(temp_static_main, readRDS(paste0(chunk.path, k)));};}; rm(k);
    
  }; unlink(chunk.path, recursive = TRUE); rm(i, home.path, chunk.path);
}; end_time <- Sys.time(); end_time - start_time; rm(start_time, end_time);
# Time difference of 1.468574 mins;

#################################################################################################################################################################################################################################################################################
## Save #########################################################################################################################################################################################################################################################################
#################################################################################################################################################################################################################################################################################

write.csv(temp_static_main, "./SENTICOIN/data/raw/twitter/@portfolio/csv/tweets.csv", row.names = FALSE); rm(temp_static_main, coins); 