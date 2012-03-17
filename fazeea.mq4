//+------------------------------------------------------------------+
//|                                                      zhuliea.mq4 |
//|                       Copyright ?2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define MAGIC 20120224

extern int N1 = 20;
extern int N2 = 10;

int last_counted_bars = 0;

int last_signal_num = EMPTY_VALUE;
int last_signal_bar = EMPTY_VALUE;

double stop_loss_price = EMPTY_VALUE;

//+------------------------------------------------------------------+
//| expert initialization function                                   |  
//+------------------------------------------------------------------+
int init()
{
    //----

    //----
    return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
    //----
    //----
    return(0);
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
    //----
    if (Bars < 100 || !IsTradeAllowed()) return (0);

    // Check if we need to calculate the signal
    checkSignal();

    // Check if we need to open position
    if (canOpenBuyPosition())
    {
        openPosition(true);
        return (0);
    }

    if (canOpenSellPosition())
    {
        openPosition(false);
        return (0);
    }

    // Check if we need to close position
    if (canClosePosition())
    {
        closePosition();
        return (0);
    }

    //----
    return(0);
}

//+------------------------------------------------------------------+
//| check if we already have a buy/sell position                     |
//+------------------------------------------------------------------+
bool hasPosition(bool buy)
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;

        if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC)
        {
            if (buy && OrderType() == OP_BUY)
                return (true);

            if (!buy && OrderType() == OP_SELL)
                return (true);
        }
    }

    return (false);
}

//+------------------------------------------------------------------+
//| Check if we should open a buy position                          |
//+------------------------------------------------------------------+
bool canOpenBuyPosition()
{
    // If we already have a buy position, don't open new one
    if (hasPosition(true))
        return (false);

    // we have a potential buy position
    if ((last_signal_num == 2) &&
        (distance() == 2) &&
        (isPositive() || Close[1] > Close[2]))
    {
        return (true);
    }

    // we have another potential buy position
    if ((last_signal_num == 3) &&
        (distance() == 2) &&
        (isPositive() || Close[1] > Close[2]))
    {
        return (true);
    }

    return (false);
}

//+------------------------------------------------------------------+
//| Check if we should open a sell position                          |
//+------------------------------------------------------------------+
bool canOpenSellPosition()
{
    // If we already have a sell position, don't open new one
    if (hasPosition(false))
        return (false);

    // we have a potential buy position
    if ((last_signal_num == 2) &&
        (distance() == 2) &&
        (!isPositive() || Close[1] < Close[2]))
    {
        return (true);
    }

    // we have another potential buy position
    if ((last_signal_num == 3) &&
        (distance() == 2) &&
        (!isPositive() || Close[1] < Close[2]))
    {
        return (true);
    }
}

bool canClosePosition()
{
    if (hasPosition(true))
    {
        if ((stop_loss_price != EMPTY_VALUE) &&
            (Close[0] <= stop_loss_price))
            return (true);

        if ((last_signal_num == 4 || last_signal_num == 5) &&
            distance() == 2 &&
            (Close[1] < Close[2] || !isPositive()))
            return (true);
    }
    else
    if (hasPosition(false))
    {
        if ((stop_loss_price != EMPTY_VALUE) &&
            (Close[0] >= stop_loss_price))
            return (true);

        if ((last_signal_num == 6 || last_signal_num == 7) &&
            distance() == 2 &&
            (Close[1] > Close[2] || isPositive()))
            return (true);
    }

    return (false);
}

void closePosition()
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC)
        {

            if (OrderType() == OP_SELL)
            {
                if (!OrderClose(OrderTicket(),OrderLots(),Ask, 5, Gray))
                {
                    Print("Close Sell Order ", OrderTicket(), " failed (", GetLastError(), ")");
                }
            }
            else
            if (OrderType() == OP_BUY)
            {
                if (!OrderClose(OrderTicket(),OrderLots(),Bid, 5, Gray))
                {
                    Print("Close Buy Order ", OrderTicket(), " failed (", GetLastError(), ")");
                }
            }
        }
    }

    last_signal_num = EMPTY_VALUE;
    last_signal_bar = EMPTY_VALUE;
    stop_loss_price = EMPTY_VALUE;

}

void openPosition(bool buy)
{
    // First of all, close the position
    closePosition();

    if (buy)
    {
        if( OrderSend(Symbol(), OP_BUY, 1, Ask, 5, 0.0, 0.0, NULL, MAGIC) < 0)
        {
            Print("Open Buy failed(", GetLastError(), ")");
        }
        else
        {
            stop_loss_price = MathMin(Close[1], Close[2]) - 5*Point;
        }
    }
    else
    {
        if (OrderSend(Symbol(), OP_SELL, 1, Bid, 5, 0.0, 0.0, NULL, MAGIC) < 0)
        {
            Print("Open Sell failed(", GetLastError(), ")");
        }
        else
        {
            stop_loss_price = MathMax(Close[1], Close[2]) + 5*Point;
        }
    }
}

//+------------------------------------------------------------------+
//| calculate distance to last signaled bar                          |
//+------------------------------------------------------------------+
int distance()
{
    return (Bars - last_signal_bar);
}

//+------------------------------------------------------------------+
//| Check if the last bar positiv                                    |
//+------------------------------------------------------------------+
bool isPositive()
{
    return (Close[1] >= Open[1]);
}

//+------------------------------------------------------------------+
//| Check signals                                                    |
//+------------------------------------------------------------------+
void checkSignal()
{
    // Signal should be checked only once, when this is a new bar
    if (last_counted_bars == Bars)
        return (0);
    else
        last_counted_bars = Bars;

    //Point 2
    double SigBuy  = iCustom(0, 0, "faze", N1, N2, 1, 1);
    //Point 3
    double SigSell = iCustom(0, 0, "faze", N1, N2, 2, 1);
    //Point 4
    double SigStopBuyLoss = iCustom(0, 0, "faze", N1, N2, 3, 1);
    //Point 5
    double SigStopBuyProfit = iCustom(0, 0, "faze", N1, N2, 4, 1);
    //Point 6
    double SigStopSellLoss = iCustom(0, 0, "faze", N1, N2, 5, 1);
    //Point 7
    double SigStopSellProfit = iCustom(0, 0, "faze", N1, N2, 6, 1);

    if (SigBuy != EMPTY_VALUE)
    {
        last_signal_num = 2;
        last_signal_bar = Bars;
    }
    else
    if (SigSell != EMPTY_VALUE)
    {
        last_signal_num = 3;
        last_signal_bar = Bars;
    }
    else
    if (SigStopBuyLoss != EMPTY_VALUE)
    {
        last_signal_num = 4;
        last_signal_bar = Bars;
    }
    else
    if (SigStopBuyProfit != EMPTY_VALUE)
    {
        last_signal_num = 5;
        last_signal_bar = Bars;
    }
    else
    if (SigStopSellLoss != EMPTY_VALUE)
    {
        last_signal_num = 6;
        last_signal_bar = Bars;
    }
    else
    if (SigStopSellProfit != EMPTY_VALUE)
    {
        last_signal_num = 7;
        last_signal_bar = Bars;
    }
}

//+------------------------------------------------------------------+


