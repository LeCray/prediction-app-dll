//+------------------------------------------------------------------+
//|                                                 v1_BB_Engine.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CTrade          m_trade;
CSymbolInfo     m_symbol;

int digits_adjust=1;


//+------------------------------------------------------------------+
int performBBAnalysis(
    double &upper_band_array[],
    double &lower_band_array[],
    double &rsi_array[], 
    int rsi_buy_level,
    int rsi_sell_level,
    double &adx_array[], 
    int adx_level,
    string symbol,
    ENUM_TIMEFRAMES period,
    ulong magic_number
) {
    
    bool adx_condition = adx_array[0] < adx_level;

    if (true) {

        double closing_price = iClose(symbol, period, 0);

        if (closing_price < lower_band_array[0]) {
            bool rsi_condition = rsi_array[0] < rsi_buy_level;
            if (rsi_condition) {return 1;} else {return 0;} 
        }

        if (closing_price > upper_band_array[0]) {
            bool rsi_condition = rsi_array[0] > rsi_sell_level;        
            if (rsi_condition) {return 0;} else {return 0;}
        }
    }

    return 0;
    //0 = Do nothing, 1 = Buy and 2 = Sell. 
}

void placeOrder(
    int bb_analysis, 
    string symbol, 
    double volume, 
    ulong magic_number, 
    int takeprofit, 
    int stoploss
) {

    m_symbol.Name(symbol);
    if (m_symbol.Digits()==3 || m_symbol.Digits()==5) digits_adjust=10;

    double m_adjusted_point = m_symbol.Point()*digits_adjust;
    Print("m_adjusted_point: ", m_adjusted_point);
    //double m_take_profit = InpTakeProfit*m_adjusted_point;
    //double m_stop_loss = InpStopLoss*m_adjusted_point;

    double bid_price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double ask_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
    //You buy at the bid price, you sell at the ask price. Ask price is higher than Bid price

    if (bb_analysis == 1){ //BUY

        double tp = bid_price + takeprofit*Point(); //Take profit price
        double sl = ask_price - stoploss*Point();   //Stop loss price

        m_trade.SetExpertMagicNumber(magic_number); //It's magic baby

        if (m_trade.Buy( volume, symbol, 0.0, sl, tp)) { //volume (lot size), symbol, execution price, sl, tp
            Print(symbol, "Buy Success. Return code: ", m_trade.ResultRetcode());
        } else {
            Print (
                symbol, "Buy Failure. Return code = ", m_trade.ResultRetcode(),
                ". Code description: ", m_trade.ResultRetcodeDescription()
            );
        }

    } else { //SELL

        double tp = ask_price - takeprofit*Point(); //Take profit price
        double sl = bid_price + stoploss*Point();   //Stop loss price

        m_trade.SetExpertMagicNumber(magic_number); //It's magic baby

        if (m_trade.Sell( volume, symbol, 0.0, sl, tp)) { //volume (lot size), symbol, execution price, sl, tp
            Print(symbol, "Sell Success. Return code: ", m_trade.ResultRetcode());
        } else {
            Print (
                symbol, "Sell Failure. Return code = ", m_trade.ResultRetcode(),
                ". Code description: ", m_trade.ResultRetcodeDescription()
            );
        }

    }
    
}

bool inPosition(string symbol, int magic_number) {

    bool in_position = false;

    for (int i = PositionsTotal() - 1; i >= 0; i--) { //Backwards, forwards...what't the difference?

        //This logic sees if the current robot with its unique magic number is in a trade
        
        string position_symbol = PositionGetSymbol(i); //SELECTING position i for further processing
        ulong position_magic_number = PositionGetInteger(POSITION_MAGIC);

        if (position_magic_number == magic_number) {

            if (position_symbol == symbol) {
                in_position = true;
            }
        }
    }    

    return in_position;
}

void v1_BB(
    string symbol,
    ENUM_TIMEFRAMES period,
    int prev_bar_count,
    double volume,
    ulong magic_number,
    int takeprofit,
    int stoploss,
    int rsi_buy_level,
    int rsi_sell_level,
    int adx_level,
    int bands_period,
    int rsi_ma_period,
    int adx_period
){

    int current_bar_count = Bars(symbol, period);

    if (current_bar_count > prev_bar_count) { //Only do something on next bar instead of next tick.

        bool in_position = inPosition(symbol, magic_number);

        if (!in_position) { //If we're not in a position, do nice things.

            double upper_band_array[], lower_band_array[], rsi_array[], adx_array[]; //Initializing the arrays

            int bands_handle = iBands(symbol, period, bands_period, 0, 2, PRICE_CLOSE); //The 2 is the BB standard deviation.
            int rsi_handle   = iRSI(symbol, period, rsi_ma_period, PRICE_CLOSE);
            int adx_handle   = iADX(symbol, period, adx_period);                
            
            ArraySetAsSeries(upper_band_array, true); //The latest value at time t will be at index 0. t-1 will be at index 1 and so on.
            ArraySetAsSeries(lower_band_array, true);
            ArraySetAsSeries(rsi_array, true);
            ArraySetAsSeries(adx_array, true); 
            
            if (CopyBuffer(bands_handle, 1, 0, 10, upper_band_array) < 0) {Print("CopyBufferMA1 error =", GetLastError());}
            if (CopyBuffer(bands_handle, 2, 0, 10, lower_band_array) < 0) {Print("CopyBufferMA1 error =", GetLastError());}        
            if (CopyBuffer(rsi_handle, 0, 0, 10, rsi_array) < 0) {Print("CopyBufferMA1 error =", GetLastError());}
            if (CopyBuffer(adx_handle, 0, 0, 10, adx_array) < 0) {Print("CopyBufferMA1 error =", GetLastError());}

            int bb_analysis = performBBAnalysis(
                upper_band_array,
                lower_band_array, 
                rsi_array, 
                rsi_buy_level,
                rsi_sell_level, 
                adx_array, 
                adx_level, 
                symbol, 
                period, 
                magic_number
            );

            if (bb_analysis != 0) {
                placeOrder(bb_analysis, symbol, volume, magic_number, takeprofit, stoploss);
            }                                                
        }            
    }
}

