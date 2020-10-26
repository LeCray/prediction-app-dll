//+------------------------------------------------------------------+
//|                                                        v1Buy.mqh |
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

void placeBuy(string symbol, int volume, ulong magic_number, int stoploss) {
    m_symbol.Name(symbol);
    if (m_symbol.Digits()==3 || m_symbol.Digits()==5) digits_adjust=10;

    double m_adjusted_point = m_symbol.Point()*digits_adjust;
    Print("m_adjusted_point: ", m_adjusted_point);
    //double m_take_profit = InpTakeProfit*m_adjusted_point;
    //double m_stop_loss = InpStopLoss*m_adjusted_point;

    double bid_price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double ask_price = SymbolInfoDouble(symbol, SYMBOL_ASK);

    //double tp = bid_price + m_take_profit; //Take profit price
    double sl = ask_price - stoploss*Point();//m_stop_loss;   //Stop loss price

    m_trade.SetExpertMagicNumber(magic_number); //It's magic baby

    if (m_trade.Buy( volume, symbol, 0.0, sl, 0.0)) { //Volume, symbole, execution price, sl, tp
        Print(symbol, "Buy Success. Return code: ", m_trade.ResultRetcode());
    } else {
        Print (
            symbol, "Buy Failure. Return code = ", m_trade.ResultRetcode(),
            ". Code description: ", m_trade.ResultRetcodeDescription()
        );
    }
}

bool buyAnalysis(
    double &ma1[], double &ma2[], double &ma3[],
    string symbol,
    ENUM_TIMEFRAMES period,
    int fast_ma,
    int slow_ma,
    int signal
) {
    //SPECIFYING BUYING MARKET CONDITIONS ======================================================================================
    double ask_price = SymbolInfoDouble(symbol, SYMBOL_ASK);
    //Price needs to be above all moving avgs
    bool buy_cond4 = ask_price > ma1[0] && ask_price > ma1[1] && ask_price > ma1[2];

    //ma1[0], ma1[1] & ma[2] need to all be above ma2 and ma3 (for 3 bars basically)
    bool buy_cond1 = ma1[0] > ma2[0] && ma2[0] > ma3[0];
    bool buy_cond2 = ma1[1] > ma2[1] && ma2[1] > ma3[1];
    bool buy_cond3 = ma1[2] > ma2[2] && ma2[2] > ma3[2];

    //The gradient of ma1 for the most recent 9 market session closes needs to be positive
    bool buy_cond5 = ma1[0] > ma1[1] && ma1[1] > ma1[2] && ma1[2] > ma1[3];

    bool buy_conditions = buy_cond1 && buy_cond2 && buy_cond3 && buy_cond4 && buy_cond5;

    double macd_main[];
    double macd_signal[];

    ArraySetAsSeries(macd_main, true); //So the latest value will be at index 0 i.e. the latest bars ma value. The most recent bar.
    ArraySetAsSeries(macd_signal, true); //So the latest value will be at index 0 i.e. the latest bars ma value. The most recent bar.
    int macd_ma_handle = iMACD(symbol, period, fast_ma, slow_ma, signal, PRICE_CLOSE);
    if (CopyBuffer(macd_ma_handle, 0, 0, 10, macd_main) < 0) {Print("CopyBufferMACD_Main error =", GetLastError());}
    if (CopyBuffer(macd_ma_handle, 1, 0, 10, macd_signal) < 0) {Print("CopyBufferMACD_Signal error =", GetLastError());}

    bool macd_cond1 = macd_main[0] > macd_signal[0];
    bool macd_cond2 = macd_main[0] < 0 && macd_signal[0] < 0;
    bool macd_conditions = macd_cond1 && macd_cond2;

    if (buy_conditions && macd_conditions) {
        if (PositionsTotal() == 0) { //Only do something when not in an active trade.
            return true;
        } else {
            return false;
        }
    } else {
        return false;
    }
}

void v1Buy(
    string symbol,
    ENUM_TIMEFRAMES period,
    int prev_bar_count,
    int volume,
    ulong magic_number,
    int stoploss,
    int ma_period1,
    int ma_period2,
    int ma_period3,
    int fast_ma,
    int slow_ma,
    int signal
) {

    if (PositionsTotal() > 0) { //Trailing Stoploss Logic
        double ask_price = SymbolInfoDouble(Symbol(),SYMBOL_ASK);
        double bid_price = SymbolInfoDouble(Symbol(),SYMBOL_BID);

        //Stoploss is a price! //Setting trailing sl price to 150 points below the Ask price. It's a price.
        //It needs to get rounded off to 5 decimeal places i.e. Digits()
        double buy_trailing_sl_price = ask_price - stoploss*Point();
        double sell_trailing_sl_price = bid_price + stoploss*Point();

        for (int i = PositionsTotal() - 1; i >= 0; i--) { //Backwards, forwards...what't the difference?
            string position_symbol = PositionGetSymbol(i); //SELECTING position i for further processing
            ulong position_magic_number = PositionGetInteger(POSITION_MAGIC);

            if (position_magic_number = magic_number) {
                //Print("MAGIC NUMBERS ARE EQUAL!!", symbol);
                ulong position_ticket = PositionGetInteger(POSITION_TICKET);
                int position_type = PositionGetInteger(POSITION_TYPE); //0 = Buy, 1 = Sell
                double current_sl_price = PositionGetDouble(POSITION_SL);

                if (position_type == 0) { //Buy position therefore increase sl
                    if (current_sl_price < buy_trailing_sl_price) {
                        m_trade.PositionModify(position_ticket, (current_sl_price + 10*Point()), 0); //Bumping up the sl price by 10 points.
                    }
                }
            }
        }




    }

    int current_bar_count = Bars(symbol, period);

    if (current_bar_count > prev_bar_count) { //Only do something on next bar instead of next tick.
        double ma1[], ma2[], ma3[];

        ArraySetAsSeries(ma1, true); //So the latest value will be at index 0 i.e. the latest bars ma value. The most recent bar.
        ArraySetAsSeries(ma2, true);
        ArraySetAsSeries(ma3, true);

        int ma_handle1 = iMA(symbol, period, ma_period1, 0, MODE_SMA,PRICE_CLOSE);
        int ma_handle2 = iMA(symbol, period, ma_period2, 0, MODE_SMA,PRICE_CLOSE);
        int ma_handle3 = iMA(symbol, period, ma_period3, 0, MODE_SMA,PRICE_CLOSE);

        if (CopyBuffer(ma_handle1,0,0,10,ma1) < 0) {Print("CopyBufferMA1 error =",GetLastError());}
        if (CopyBuffer(ma_handle2,0,0,10,ma2) < 0) {Print("CopyBufferMA2 error =",GetLastError());}
        if (CopyBuffer(ma_handle3,0,0,10,ma3) < 0) {Print("CopyBufferMA3 error =",GetLastError());}

        bool buy_analysis = buyAnalysis(ma1, ma2, ma3, symbol, period, fast_ma, slow_ma, signal);

        if (buy_analysis) {
            placeBuy(symbol, volume, magic_number, stoploss);
        }

        //sellAnalysis(ma1, ma2, ma3);
    }
}
