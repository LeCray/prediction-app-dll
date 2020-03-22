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
#property tester_file "Example/Release/example-app.dll"

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

  //Print("WE HAVE LIFT OFF!!=====================");
//---
//--- calling the function for calculations
   int    speed=0;
   int    res_int=20;
   double res_double=0.0;

   speed = fnCalculateSpeed(res_int,res_double);
   Print("Time ",speed," msec, int: ",res_int," double: ",res_double," ==================");

   double a = 1550;
   double b = 140;
   double c = 103;
   double d = 102;
   char x = 1;

   //int prediction = prediction(a, b, c, d);
   //Print("Prediction: ", prediction);

//---
    //Print("STARTED");


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
//---
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
            MqlTradeRequest request = {0};
            MqlTradeResult  result = {0};
        //--- parameters of request
            request.action   = TRADE_ACTION_DEAL;                     // type of trade operation
            request.symbol   = Symbol();                              // symbol
            request.volume   = 0.1;                                   // volume of 0.1 lot
            request.type     = ORDER_TYPE_BUY;                        // order type
            request.price    = SymbolInfoDouble(Symbol(),SYMBOL_ASK); // price for opening
            request.deviation= 5;                                     // allowed deviation from the price
            request.magic    = 123456;                                // MagicNumber of the order
        //--- send the request
            if(!OrderSend(request,result))
                PrintFormat("OrderSend error %d",GetLastError());    // if unable to send the request, output the error code
        //--- information about the operation
            PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);

        }
    }
*/
  }
//+------------------------------------------------------------------+
