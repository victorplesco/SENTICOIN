``` 
SENTICOIN/data/    
│
├── processed/
│   └── models/
│       ├── sentiment/
│       │   ├── BerTweet.csv 
│       │   ├── FinBERT.csv
│       │   └── VADER.csv
│       │
│       └── regression/ 
│           └── loader/
│               ├── corpus/
│               │   └── u_tweets.csv
│               │
│               └── splits/
│                   └── ...
│
└── raw/
    ├── twitter/
    │   ├── cryptolist.csv
    │   │
    │   ├── @elonmusk/
    │   │   ├── csv/
    │   │   │   └── retweets.csv 
    │   │   │
    │   │   └── rds/
    │   │       ├── retweets/             
    │   │       │   └── ...
    │   │       │
    │   │       └── tweets/
    │   │           └── ...  
    │   │
    │   └── @portfolio/
    │       ├── csv/
    │       │   └── tweets.csv 
    │       │
    │       └── rds/
    │           └── ...  
    │
    └── crypto/
        ├── @elonmusk/
        │   └── DOGE.csv
        │
        └── @portfolio/
            └── ...
```
