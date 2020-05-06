//+------------------------------------------------------------------+
//|                                           buy_data_generator.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

#import "Release/prediction-app.dll"
    int  prediction(double &a, double &b, double &c, double &d);
#import

int handle;
//--- parameters for writing data to file
input string    InpFileName = "BuyData.csv";      // File name
input string    InpDirectoryName = "Data";     // Folder name
input string    symbol = "EURUSD";
input int       timeFrame = 5;


datetime time_array[];
double open_price[];
double close_price[];
double stochastics_array[];
double volume_array[];
double outcome_array[];
double rsi_array[];
double macd_array[];

CTrade          m_trade;
CSymbolInfo     m_symbol;                       // symbol info object
int             bars_before = 0;

input int    InpTakeProfit    =50;  // Take Profit (in pips)
input int    InpStopLoss    =25;  // Take Profit (in pips)

int digits_adjust=1;
double m_adjusted_point;
double m_take_profit;
double m_stop_loss;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
/*
    double stochs_array[];
    //Print("STochs: ", iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,STO_LOWHIGH));
    int stochs = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,STO_LOWHIGH);
    if (CopyBuffer(stochs,0,0,1,stochs_array) < 0) {Print("CopyBufferM error =", GetLastError());}
    Print("SToch: ", stochs_array[0]);
*/
    bars_before = Bars(NULL, PERIOD_M5); //Symbol name, Timeframe
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---


        //Open file
        int file_handle = FileOpen(InpDirectoryName+"//"+InpFileName,FILE_CSV|FILE_READ|FILE_WRITE,',');

        if (file_handle != INVALID_HANDLE) {
            PrintFormat("%s file is available for writing", InpFileName);
            //--- first, write the number of signals
            //FileWrite(file_handle, "OPENING PRICE", "CLOSING PRICE", "STOCHASTICS", "VOLUME", "OUTCOME");
            //--- write the data to the file
            for (int i=0; i < ArraySize(outcome_array); i++) {
                Print("Data being written: ", rsi_array[i]," , ", macd_array[i]," , ", stochastics_array[i]," , ", volume_array[i]," , ", outcome_array[i]);
                FileWrite(file_handle, rsi_array[i], macd_array[i], stochastics_array[i], volume_array[i], outcome_array[i]);
            }
            //--- close the file
            FileClose(file_handle);
            PrintFormat("Data is written, %s file is closed", InpFileName);
        } else {
            PrintFormat("Failed to open %s file, Error code = %d", InpFileName, GetLastError());
        }

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

        //ArrayResize(time_array, ArraySize(time_array) + 1);
        //time_array[ArraySize(time_array) - 1] = iTime(NULL,PERIOD_M5,0);
        if (PositionsTotal() == 0) {

            HistorySelect(TimeCurrent()-300, TimeCurrent()); // This history should contain the last deal that just closed
            //Print ("HistoryDealsTotal ", HistoryDealsTotal()); //i.e when PositionsTotal() == 0 again. Because it was just 1 a second ago before tp or sl hit

            int total_deals = HistoryDealsTotal(); // HistoryDealsTotal = 1 at this point
            //if (all_deals < 1) Print("Some nasty shit error has occurred :s");
            ulong last_deal_ticket = HistoryDealGetTicket(total_deals - 1); // last deal (should be an DEAL_ENTRY_OUT type)
            // here check some validity factors of the position-closing deal (symbol, position ID, even MagicNumber if you care...)
            double last_trade_profit = HistoryDealGetDouble(last_deal_ticket, DEAL_PROFIT);

            Print("Last Trade Profit: ", last_trade_profit);

            ArrayResize(outcome_array, ArraySize(outcome_array) + 1); //Increasing the size of the outcome_array

            if (last_trade_profit > 0) {
                outcome_array[ArraySize(outcome_array) - 1] = 1; //If last trade made cash, new added element = 1
            } else {
                outcome_array[ArraySize(outcome_array) - 1] = 0; //If last trade fckd out, new added element = 0
            }
            //Print("Last Outcome: ", outcome_array[ArraySize(outcome_array) - 1]);


            int bars_now = Bars(NULL, PERIOD_M5); //Symbol name, Timeframe
            bool perform_prediction = false;

            if (bars_now > bars_before) {
                perform_prediction = true;
                bars_before = bars_now;
            }


            if (perform_prediction) {

                Print("Performing prediction.........................................");

                int rsi_handle = iRSI(NULL, PERIOD_M5,14,PRICE_CLOSE);
                double rsi_temp_array[];
                if (CopyBuffer(rsi_handle, 0, 0, 1, rsi_temp_array) < 0) {Print("CopyBufferRSI error =", GetLastError());}

                int macd_handle = iMACD(NULL,PERIOD_M5,12,26,9,PRICE_CLOSE);
                double macd_temp_array[];
                if (CopyBuffer(macd_handle, 0, 0, 1, macd_temp_array) < 0) {Print("CopyBufferMacd error =", GetLastError());}

                int stochastics_handle = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,STO_LOWHIGH);
                double stochastics_temp_array[];
                if (CopyBuffer(stochastics_handle, 0, 0, 1, stochastics_temp_array) < 0) {Print("CopyBufferStochs error =", GetLastError());}

                double volume           = iVolume(NULL,PERIOD_M5,0);
                double close_price      = iClose(NULL,PERIOD_M5,0);
                double open_price       = iOpen(NULL,PERIOD_M5,0);

                m_symbol.Name(Symbol());
                if (m_symbol.Digits()==3 || m_symbol.Digits()==5) digits_adjust=10;

                m_adjusted_point = m_symbol.Point()*digits_adjust;
                m_take_profit = InpTakeProfit*m_adjusted_point;
                m_stop_loss = InpStopLoss*m_adjusted_point;

                double bid_price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
                double ask_price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);

                double tp = bid_price + m_take_profit; //Take profit price
                double sl = ask_price - m_stop_loss;   //Stop loss price

                //Dummy prediction. It's here to try replicate real trading behaviour
                int prediction = prediction(rsi_temp_array[0], macd_temp_array[0], stochastics_temp_array[0], volume);
                //Print("Prediction: ", prediction);

                if (m_trade.Buy( 1, _Symbol, 0.0, sl, tp)) {
                    //--- success message
                    Print( "Buy Success. Retcode: ", m_trade.ResultRetcode());
                    /*
                    Print( "The .Buy() method executed successfully. The return-code = ",m_trade.ResultRetcode()," ("
                             , m_trade.ResultRetcodeDescription(),")"
                    );
                    */
                    //if (m_trade.ResultRetcode() == 10009) {

                        //If buy was a success, add the current market state vars to their arrays

                        //Making the arrays bigger to add the latest market state var
                        ArrayResize(rsi_array, ArraySize(rsi_array) + 1);
                        rsi_array[ArraySize(rsi_array) - 1] = NormalizeDouble(rsi_temp_array[0], 5); //Rounding off to 5 decimal places

                        ArrayResize(macd_array, ArraySize(macd_array) + 1);
                        macd_array[ArraySize(macd_array) - 1] = NormalizeDouble(macd_temp_array[0], 5); //Rounding off to 5 decimal places

                        ArrayResize(stochastics_array, ArraySize(stochastics_array) + 1);
                        stochastics_array[ArraySize(stochastics_array) - 1] = NormalizeDouble(stochastics_temp_array[0], 5); //Rounding off to 5 decimal places

                        ArrayResize(volume_array, ArraySize(volume_array) + 1);
                        volume_array[ArraySize(volume_array) - 1] = volume;

                        Print (
                            "RSI: ", rsi_array[ArraySize(rsi_array) - 1],
                            " macd: ", macd_array[ArraySize(macd_array) - 1],
                            " Stochs: ", stochastics_array[ArraySize(stochastics_array) - 1],
                            " volume: ", volume
                        );
                    //}

                } else {
                    Print ( "The .Buy() method failed. The return-code = ",m_trade.ResultRetcode(),". Code description: "
                            , m_trade.ResultRetcodeDescription()
                    );
                }
            }
        }



  }
//+------------------------------------------------------------------+
