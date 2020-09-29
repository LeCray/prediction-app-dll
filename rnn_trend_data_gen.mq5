//+------------------------------------------------------------------+
//|                                           rnn_trend_data_gen.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CTrade          m_trade;
CSymbolInfo     m_symbol;
int             bars_before = 0;

//--- parameters for writing data to file
//input string    FeaturesInpFileName = "FeaturesBuyData.csv";      // File name
//input string    LabelsInpFileName = "LabelsBuyData.csv";      // File name
//input string    InpDirectoryName = "Data";     // Folder name

//input string       timeFrame = PERIOD_H4;
input int       stoploss = 3000;
input int       trailing_sl = 3000;
input int          volume = 10;

//input int    InpTakeProfit  = 50;  // TakeProfit (in pips)
//input int    InpStopLoss    = 30000;  // StopLoss (in pips)

int digits_adjust=1;

double stochastics_array[];
string latest_feature_sequence;

bool started = false;

string feature_label_array[];
string balanced_array[];

string label_array[];
string rsi_array[];
string ten_ma_array[];
string macd_array[];
string stoch_array[];

string latest_rsi_sequence;
string latest_ten_ma_sequence;
string latest_macd_sequence;
string latest_stoch_sequence;

int sequence_length = 100;

double rsi_sequence_array[];
double ten_ma_sequence_array[];
double macd_sequence_array[];
double stoch_sequence_array[];
int prev_bars_count;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    prev_bars_count = Bars(NULL, PERIOD_CURRENT);
    Print("Point: ", Point(), " ", "Digits: ", Digits());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }

void generateSequences() {

    int rsi_handle = iRSI(NULL,PERIOD_CURRENT,14,PRICE_CLOSE);
    int ten_ma_handle = iMA(NULL,PERIOD_CURRENT,10,0,MODE_LWMA,PRICE_CLOSE);
    int macd_ma_handle = iVolumes(NULL,PERIOD_CURRENT,VOLUME_TICK);//iMACD(NULL,NULL,12,26,9,PRICE_CLOSE);
    //int atr_handle = iATR(NULL,NULL,14)
    int stoch_ma_handle = iStochastic(NULL,PERIOD_CURRENT,5,3,3,MODE_SMA,STO_LOWHIGH);

    if (CopyBuffer(rsi_handle, 0, 0, sequence_length, rsi_sequence_array) < 0) {
      Print("CopyBufferStochs error =", GetLastError());
    }
    if (CopyBuffer(ten_ma_handle, 0, 0, sequence_length, ten_ma_sequence_array) < 0) {
      Print("CopyBufferStochs error =", GetLastError());
    }
    if (CopyBuffer(macd_ma_handle, 0, 0, sequence_length, macd_sequence_array) < 0) {
      Print("CopyBufferStochs error =", GetLastError());
    }
    if (CopyBuffer(stoch_ma_handle, 0, 0, sequence_length, stoch_sequence_array) < 0) {
      Print("CopyBufferStochs error =", GetLastError());
    }
    //Print("Min: ", ArrayMinimum(rsi_sequence_array));
    //Maybe not normalise?
    /*
    NormalizeRSI();
    NormalizeMA();
    NormalizeMACD();
    NormalizeSTOCH();
    */
    latest_rsi_sequence = ""; //Refreshing
    latest_ten_ma_sequence = ""; //Refreshing
    latest_macd_sequence = ""; //Refreshing
    latest_stoch_sequence = ""; //Refreshing

    for (int i=0; i<sequence_length-1; i++){
        latest_rsi_sequence += DoubleToString(rsi_sequence_array[i], 6);
        latest_rsi_sequence += ",";
        latest_ten_ma_sequence += DoubleToString(ten_ma_sequence_array[i], 6);
        latest_ten_ma_sequence += ",";
        latest_macd_sequence += DoubleToString(macd_sequence_array[i], 6);
        latest_macd_sequence += ",";
        latest_stoch_sequence += DoubleToString(stoch_sequence_array[i], 6);
        latest_stoch_sequence += ",";
    }
    //Print("Feature Seq: ", feature_sequence1);
}

bool placeBuy() {
    m_symbol.Name(Symbol());
    if (m_symbol.Digits()==3 || m_symbol.Digits()==5) digits_adjust=10;

    double m_adjusted_point = m_symbol.Point()*digits_adjust;
    Print("m_adjusted_point: ", m_adjusted_point);
    //double m_take_profit = InpTakeProfit*m_adjusted_point;
    //double m_stop_loss = InpStopLoss*m_adjusted_point;

    double bid_price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
    double ask_price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);

    //double tp = bid_price + m_take_profit; //Take profit price
    double sl = ask_price - stoploss*Point();//m_stop_loss;   //Stop loss price

    if (m_trade.Buy( volume, _Symbol, 0.0, sl, 0.0)) { //Volume, symbole, execution price, sl, tp
        Print( "Buy Success. Return code: ", m_trade.ResultRetcode());
        return true;
    } else {
        Print (
            "Buy Failure. Return code = ", m_trade.ResultRetcode(),
            ". Code description: ", m_trade.ResultRetcodeDescription()
        );
        return false;
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

    if (PositionsTotal() != 0) {
        double ask_price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);

        //Stoploss is a price! //Setting trailing sl price to 150 points below the Ask price. It's a price.
        //It needs to get rounded off to 5 decimeal places i.e. Digits()
        double trailing_sl_price = ask_price - trailing_sl*Point();
        string symbol = PositionGetSymbol(0); //Selecting the currently open position for GetInteger & GetDouble below
        ulong position_ticket = PositionGetInteger(POSITION_TICKET);
        double current_sl_price = PositionGetDouble(POSITION_SL);

        if (current_sl_price < trailing_sl_price) {
            m_trade.PositionModify(position_ticket, (current_sl_price + 10*Point()), 0); //Bumping up the sl price by 10 points.
        }
    }

    int current_bars_count = Bars(NULL, PERIOD_CURRENT);

    if (current_bars_count > prev_bars_count) { //Only do something on next bar instead of next tick.
        double ma1[], ma2[], ma3[];

        ArraySetAsSeries(ma1, true); //So the latest value will be at index 0 i.e. the latest bars ma value. The most recent bar.
        ArraySetAsSeries(ma2, true);
        ArraySetAsSeries(ma3, true);

        int ma_handle1 = iMA(NULL,PERIOD_CURRENT,10,0,MODE_SMA,PRICE_CLOSE);
        int ma_handle2 = iMA(NULL,PERIOD_CURRENT,50,0,MODE_SMA,PRICE_CLOSE);
        int ma_handle3 = iMA(NULL,PERIOD_CURRENT,200,0,MODE_SMA,PRICE_CLOSE);

        if (CopyBuffer(ma_handle1,0,0,10,ma1) < 0) {Print("CopyBufferMA1 error =",GetLastError());}
        if (CopyBuffer(ma_handle2,0,0,10,ma2) < 0) {Print("CopyBufferMA2 error =",GetLastError());}
        if (CopyBuffer(ma_handle3,0,0,10,ma3) < 0) {Print("CopyBufferMA3 error =",GetLastError());}

        //SPECIFYING BUYING MARKET CONDITIONS
        bool cond1 = ma1[0] > ma2[0] && ma2[0] > ma3[0];
        bool cond2 = ma1[1] > ma2[1] && ma2[1] > ma3[1];
        bool cond3 = ma1[2] > ma2[2] && ma2[2] > ma3[2];

        double ask_price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
        bool cond4 = ask_price > ma1[0] && ask_price > ma1[1] && ask_price > ma1[2];

        bool cond5 = ma1[0] > ma1[1] && ma1[1] > ma1[2] && ma1[2] > ma1[3];
        bool cond6 = ma1[3] > ma1[4] && ma1[4] > ma1[5] && ma1[5] > ma1[6];
        bool cond7 = ma1[6] > ma1[7] && ma1[7] > ma1[8] && ma1[8] > ma1[9];

        //bool cond8 = ma2[0] > ma2[1] && ma2[1] > ma2[2] && ma2[2] > ma2[3];
        //bool cond9 = ma2[3] > ma2[4] && ma2[4] > ma2[5] && ma2[5] > ma2[6];
        //bool cond10 = ma2[6] > ma2[7] && ma2[7] > ma2[8] && ma2[8] > ma2[9];

        bool conditions = cond1 && cond2 && cond3 && cond4 && cond5;// && cond6 && cond7;// && cond8 && cond9 && cond10;

        if (conditions ){
            if (PositionsTotal() == 0) { //Only do something when not in an active trade.

                if(placeBuy()) {
                    Print("Yasss");
                }
            }
        }
    }
/*
                if (started){ //Do not try update outcome on initialization.
                    string latest_outcome = findLatestOutcome();
                    if (latest_outcome != "-1") {
                        Print("Latest Outcome: ", latest_outcome);
                        addOutcomeToLabelArray(latest_outcome);
                    } else {
                        Print("There was an error finding the latest outcome");
                    }
                }

                generateSequences();

                if (placeBuy()) {
                    addNewSequenceToRSIArray();
                    addNewSequenceToMAArray();
                    addNewSequenceToMACDArray();
                    addNewSequenceToSTOCHArray();
                    started = true;
                }
            }

        }

        prev_bars_count = current_bars_count; //Updating prev_bars_count
    }
    /*

    */

}
//+------------------------------------------------------------------+
