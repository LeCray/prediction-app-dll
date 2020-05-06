//+------------------------------------------------------------------+
//|                                             pytorch_dll_test.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#property tester_library "Release/prediction-app.dll"
#property tester_library "Example/Release/example-app.dll"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
/*
#import "Mql5PytorchDllTest/x64/Release/Mql5PytorchDllTest.dll"
    int  test(int a, int b);
#import
*/

#import "Release/prediction-app.dll"
    int  prediction(double &a, double &b, double &c, double &d);
#import

#import "Example/Release/example-app.dll"
    int  fnCalculateSpeed(int &res1,double &res2);
#import

CTrade          m_trade;
CSymbolInfo     m_symbol;                       // symbol info object
int             bars_before = 0;

input int    InpTakeProfit    =50;  // Take Profit (in pips)
input int    InpStopLoss    =25;  // Take Profit (in pips)

int digits_adjust=1;
double m_adjusted_point;
double m_take_profit;
double m_stop_loss;

/*
#import "simple_metatrader_dll.dll"
    int  fnCalculateSpeed(int &res1,double &res2);

#import
*/
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//--- calling the function for calculations
   int    speed=0;
   int    res_int=20;
   double res_double=0.0;

   //speed = fnCalculateSpeed(res_int,res_double);
   //Print("Time ",speed," msec, int: ",res_int," double: ",res_double," ==================");

   double a = 1550;
   double b = 140;
   double c = 103;
   double d = 102;
   char x = 1;

  // int prediction = prediction(a, b, c, d);
  // Print("Prediction: ", prediction);

//---
    //Print("STARTED");

    bars_before = Bars(NULL, PERIOD_M5); //Symbol name, Timeframe

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---0
        if (PositionsTotal() == 0) {

            int bars_now = Bars(NULL, PERIOD_M5); //Symbol name, Timeframe
            bool perform_prediction = false;

            if (bars_now > bars_before) {
                perform_prediction = true;
                bars_before = bars_now;
            }

            if (perform_prediction) {

                Print("Performing prediction...");

                m_symbol.Name(Symbol());

                if(m_symbol.Digits()==3 || m_symbol.Digits()==5) digits_adjust=10;

                m_adjusted_point = m_symbol.Point()*digits_adjust;
                m_take_profit = InpTakeProfit*m_adjusted_point;
                m_stop_loss = InpStopLoss*m_adjusted_point;

                //double tp   = double Bid()+m_take_profit;
                double bid_price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
                double ask_price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
               //Print("Helo - Zenstep2222: ", bid);

                double tp = bid_price + m_take_profit;
                double sl = ask_price - m_stop_loss;

                //Print("TP and SL: ", tp, " ", sl);
                /*
                int rsi                 = iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE);
                int macd                = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE);
                double volume           = iVolume(NULL,PERIOD_M5,0);
                double stochastics      = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,STO_LOWHIGH);
                double close_price      = iClose(NULL,PERIOD_M5,0);
                double open_price       = iOpen(NULL,PERIOD_M5,0);
                */
                int rsi_handle = iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE);
                double rsi_temp_array[];
                if (CopyBuffer(rsi_handle, 0, 0, 1, rsi_temp_array) < 0) {Print("CopyBufferRSI error =", GetLastError());}

                int macd_handle = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE);
                double macd_temp_array[];
                if (CopyBuffer(macd_handle, 0, 0, 1, macd_temp_array) < 0) {Print("CopyBufferMacd error =", GetLastError());}

                int stochastics_handle = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,STO_LOWHIGH);
                double stochastics_temp_array[];
                if (CopyBuffer(stochastics_handle, 0, 0, 1, stochastics_temp_array) < 0) {Print("CopyBufferStochs error =", GetLastError());}

                double volume = iVolume(NULL,PERIOD_M5,0);

                int prediction = prediction(rsi_temp_array[0], macd_temp_array[0], stochastics_temp_array[0], volume);
                Print("Prediction: ", prediction);

                if (prediction == 1) {
                    if (m_trade.Buy( 1, _Symbol, 0.0, sl, tp)) {
                      //--- success message
                      Print( "The .Buy() method executed successfully. The return-code = ",m_trade.ResultRetcode()," ("
                             , m_trade.ResultRetcodeDescription(),")"
                      );
                    } else {
                        Print ( "The .Buy() method failed. The return-code = ",m_trade.ResultRetcode(),". Code description: "
                                , m_trade.ResultRetcodeDescription()
                        );
                    }
                }
            }
        }
    }


/*
    int rsi                 = iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE);
    int macd                = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE);
    double volume           = iVolume(NULL,PERIOD_M5,0);
    double stochastics      = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,STO_LOWHIGH);
    double close_price      = iClose(NULL,PERIOD_M5,0);
    double open_price       = iOpen(NULL,PERIOD_M5,0);

    int prediction = prediction(close_price, open_price, stochastics, volume);
    Print("Prediction: ", prediction);

    if (prediction == 1) {
        //BUY
        if(OrdersTotal() == 0) { //Making sure only 1 order is open at a time
                //--- declare and initialize the trade request and result of trade request
                //--- declare and initialize the trade request and result of trade request
             MqlTradeRequest request={0};
             MqlTradeResult  result={0};

             int minstoplevel = SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL);
             double risk = (minstoplevel + 10)*Point(); //Turning pips into point size i.e 2 pips = 0.0002 on price axis
            double reward = risk*8;

            double bid_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            //Rounding off SL and TP to charts required degree of accuracy
            double stoploss = NormalizeDouble(bid_price - risk, Digits());
            double takeprofit = NormalizeDouble(bid_price + reward, Digits());

          //--- parameters of request
             request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
             request.symbol   =Symbol();                              // symbol
             request.volume   =1;                                   // volume of 0.2 lot
             request.type     =ORDER_TYPE_BUY;                          // order type
             //request.type_filling = SYMBOL_FILLING_FOK;
             request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // price for opening
             request.sl = stoploss;
             request.tp = takeprofit;
             request.deviation=5;                                     // allowed deviation from the price
             request.magic    =123456   ;                          // MagicNumber of the order
          //--- send the request
             if(!OrderSend(request,result))
                PrintFormat("OrderSend error %d",GetLastError());     // if unable to send the request, output the error code
          //--- information about the operation
             PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);



        }
    }

  }
*/
//+------------------------------------------------------------------+
