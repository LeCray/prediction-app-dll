//+------------------------------------------------------------------+
//|                                                     v1_multi.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <v1\v1Buy.mqh>;

input int us100_volume  = 1;
input int us30_volume   = 1;
input int amzn_volume   = 1;
input int netflix_volume   = 1;

int us100_prev_bar_count;
int us30_prev_bar_count;
int amzn_prev_bar_count;
int netflix_prev_bar_count;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    EventSetTimer(1);

    us100_prev_bar_count    = Bars("US100Cash", PERIOD_H1);
    us30_prev_bar_count     = Bars("US30Cash", PERIOD_H1);
    amzn_prev_bar_count     = Bars("Amazon", PERIOD_M1);
    netflix_prev_bar_count     = Bars("Netflix", PERIOD_M5);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
    EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
    v1Buy(
        "US100Cash",            //symbol
        PERIOD_H1,              //period
        us100_prev_bar_count,   //prev_bar_count
        us100_volume,           //volume
        1,                      //magic number
        19400,                  //stoploss
        5,                      //ma_period1
        25,                     //ma_period2
        150,                    //ma_period3
        20,                     //fast_ma
        15,                     //slow_ma
        5                       //signal
    );
    v1Buy(
        "US30Cash",
        PERIOD_H1,
        us30_prev_bar_count,
        us30_volume,
        2,
        16500,
        20,
        85,
        300,
        20,
        15,
        7
    );
    v1Buy(
        "Amazon",            //symbol
        PERIOD_M1,              //period
        amzn_prev_bar_count,   //prev_bar_count
        amzn_volume,           //volume
        3,                      //magic number
        3900,                  //stoploss
        10,                      //ma_period1
        150,                     //ma_period2
        200,                    //ma_period3
        10,                     //fast_ma
        70,                     //slow_ma
        15                       //signal
    );
    /*
    v1Buy(
        "Netflix",            //symbol
        PERIOD_M5,              //period
        netflix_prev_bar_count,   //prev_bar_count
        netflix_volume,           //volume
        4,                      //magic number
        1050,                  //stoploss
        3,                      //ma_period1
        11,                     //ma_period2
        60,                    //ma_period3
        16,                     //fast_ma
        15,                     //slow_ma
        10                       //signal
    );

    /*
    v1Buy(
        string symbol           = "US30Cash",
        ENUM_TIMEFRAMES period  = PERIOD_H1,
        int prev_bar_count      = us100_prev_bar_count,
        int vol                 = us100_volume,
        int stoploss            = 19400,
        int ma_period1          = 5,
        int ma_period2          = 25,
        int ma_period3          = 150,
        int fast_ma             = 20,
        int slow_ma             = 15,
        int signal              = 5
    );
    */
  }
//+------------------------------------------------------------------+
