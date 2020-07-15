//+------------------------------------------------------------------+
//|                                             rnn_buy_data_gen.mq5 |
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
input string    InpFileName = "SequenceBuyData.csv";      // File name
input string    InpDirectoryName = "Data";     // Folder name
input string    symbol = "EURUSD";
input int       timeFrame = 5;


input int    InpTakeProfit  =50;  // TakeProfit (in pips)
input int    InpStopLoss    =25;  // StopLoss (in pips)

int digits_adjust=1;

double stochastics_array[];
string latest_feature_sequence;

bool started = false;

string feature_label_array[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    bars_before = Bars(NULL, PERIOD_M5); //Symbol name, Timeframe
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    int size = ArraySize(feature_label_array);
/*
    for (int i=0; i<size-1; i++) {
        Print("Feature label array: ", feature_label_array[i]);
    }
*/
    //Open file
    int file_handle = FileOpen(InpDirectoryName+"//"+InpFileName,FILE_CSV|FILE_READ|FILE_WRITE,',');

    if (file_handle != INVALID_HANDLE) {
        PrintFormat("%s file is available for writing", InpFileName);

        for (int i=0; i < size-1; i++) {
            Print("Data being written: ", feature_label_array[i]);
            FileWrite(file_handle, feature_label_array[i]);
        }
        //--- close the file
        FileClose(file_handle);
        PrintFormat("Data is written, %s file is closed", InpFileName);
    } else {
        PrintFormat("Failed to open %s file, Error code = %d", InpFileName, GetLastError());
    }
}
string findLatestOutcome() {
    //Checking if the last deal was a win or a loss ===================================================================
    HistorySelect(TimeCurrent()-300, TimeCurrent()); // This history should contain the last deal that just closed
    //Print ("HistoryDealsTotal ", HistoryDealsTotal()); //i.e when PositionsTotal() == 0 again. Because it was just 1 a second ago before tp or sl hit

    int total_deals = HistoryDealsTotal(); // HistoryDealsTotal = 1 at this point

    if (total_deals < 1) {
        Print("Couldn't access HistoryDealsTotal()");
        return "-1";
    } else {
        //Last deal (should be an DEAL_ENTRY_OUT type)
        ulong last_deal_ticket = HistoryDealGetTicket(total_deals - 1);
        //Here we could check some validity factors of the position-closing deal (symbol, position ID, even MagicNumber)
        double last_trade_profit = HistoryDealGetDouble(last_deal_ticket, DEAL_PROFIT);

        if (last_trade_profit > 0){
            return "1";
        } else {
            return "0";
        }
    }
}
string generateStochSequence() {
    double stochastics_signal_sequence_array[];
    int stochastics_handle = iStochastic(NULL,PERIOD_M5,5,3,3,MODE_SMA,STO_LOWHIGH);

    if (CopyBuffer(stochastics_handle, 1, 0, 100, stochastics_signal_sequence_array) < 0) { //We're storing the signal!
        Print("CopyBufferStochs error =", GetLastError());                                 //Buffer number = 1 for signal
    }

    string stochastics_signal_sequence = "";

    for (int i=0; i<100; i++){
        stochastics_signal_sequence += DoubleToString(stochastics_signal_sequence_array[i], 2);
        stochastics_signal_sequence += ",";
    }

    return stochastics_signal_sequence;
}
bool placeBuy() {
    m_symbol.Name(Symbol());
    if (m_symbol.Digits()==3 || m_symbol.Digits()==5) digits_adjust=10;

    double m_adjusted_point = m_symbol.Point()*digits_adjust;
    double m_take_profit = InpTakeProfit*m_adjusted_point;
    double m_stop_loss = InpStopLoss*m_adjusted_point;

    double bid_price = SymbolInfoDouble(Symbol(),SYMBOL_BID);
    double ask_price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);

    double tp = bid_price + m_take_profit; //Take profit price
    double sl = ask_price - m_stop_loss;   //Stop loss price

    if (m_trade.Buy( 1, _Symbol, 0.0, sl, tp)) {
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
void addNewFeatureToFeatureLabelArray(string latest_feature_sequence) {
    int size = ArraySize(feature_label_array);
    ArrayResize(feature_label_array, size + 1); //Increasing size of array.
    feature_label_array[size] = latest_feature_sequence; //Updating last element.
}
void addLabelToFeatureLabelArray(string latest_outcome) {
    int size = ArraySize(feature_label_array);
    feature_label_array[size - 1] += latest_outcome;
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
    if (PositionsTotal() == 0) { //Only do something when not in an active trade.

        if (started){ //Do not try update outcome on initialization.
            string latest_outcome = findLatestOutcome();
            if (latest_outcome != "-1") {
                Print("Latest Outcome: ", latest_outcome);
                addLabelToFeatureLabelArray(latest_outcome);
            } else {
                Print("There was an error finding the latest outcome");
            }
        }

        string latest_feature_sequence = generateStochSequence();
        if (placeBuy()) {
            addNewFeatureToFeatureLabelArray(latest_feature_sequence);
            started = true;
        }
    }
}
//+------------------------------------------------------------------+
