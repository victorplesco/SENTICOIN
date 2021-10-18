``` 
SENTICOIN/data/
├── external/    
│
├── interim/       
│
├── processed/
│   └── models/
│       ├── sentiment/
│       │   ├── BerTweet.csv 
│       │   ├── FinBERT.csv
│       │   └── VADER.csv
│       │
│       └── regression/ 
│           └── split/
│               └── XRP_lag.mins=60_test.split=0.2_val.split=0.1_FUN=default/
│                   └── ...
│
└── raw/
    ├── twitter/
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
        │   └── ...
        │
        └── @portfolio/
            └── ...
```
