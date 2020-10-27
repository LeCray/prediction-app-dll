//+------------------------------------------------------------------+
//|                                                     v1_multi.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <v1\v1Buy.mqh>;

input double us100_volume  = 1;
input double us30_volume   = 1;
input double amzn_volume   = 1;
input double netflix_volume   = 1;
input double fra40_volume   = 1;
input double ger30_volume   = 1;


int us100_prev_bar_count;
int us30_prev_bar_count;
int amzn_prev_bar_count;
int netflix_prev_bar_count;
int fra40_prev_bar_count;
int ger30_prev_bar_count;

ulong us100_magic_no = 1;
ulong us30_magic_no = 2;
ulong amzn_magic_no = 3;
ulong netflix_magic_no = 4;
ulong fra40_magic_no = 5;
ulong ger30_magic_no = 6;
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
    fra40_prev_bar_count     = Bars("FRA40Cash", PERIOD_M1);
    ger30_prev_bar_count     = Bars("GER30Cash", PERIOD_M1);
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

    v1Buy(
        "FRA40Cash",
        PERIOD_M1,
        fra40_prev_bar_count,
        fra40_volume,
        5,
        6540,
        51,
        59,
        277,
        45,
        83,
        21
    );
    v1Buy(
        "GER30Cash",
        PERIOD_M1,
        ger30_prev_bar_count,
        ger30_volume,
        6,
        9340,
        7,
        159,
        99,
        77,
        1,
        93
    );

  }
//+------------------------------------------------------------------+
