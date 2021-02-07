//+------------------------------------------------------------------+
//|                                        v1_BB_Asset_Optimizer.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <v1_BB_Engine.mqh>;

//Global parameters to optimise for. Below are default values.
input double volume  = 1;
input int takeprofit        = 10000;
input int stoploss          = 10000;
input int rsi_buy_level     = 20;
input int rsi_sell_level    = 80;
input int adx_level         = 25;
input int bands_period      = 20;
input int rsi_ma_period     = 14;
input int adx_period        = 14;


int prev_bar_count;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

    EventSetTimer(1);
    prev_bar_count = Bars("US100Cash", PERIOD_H1);

    return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
    EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer()
  {
    v1_BB(
        "US100Cash",            //symbol
        PERIOD_H1,              //period
        prev_bar_count,  //prev_bar_count
        volume,          //volume
        1,                      //magic number
        takeprofit,             //takeprofit
        stoploss,               //stoploss
        rsi_buy_level,          //rsi_buy_level
        rsi_sell_level,         //rsi_sell_level
        adx_level,               //adx_level
        bands_period,
        rsi_ma_period,
        adx_period
    );
  }
//+------------------------------------------------------------------+
