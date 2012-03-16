//+------------------------------------------------------------------+
//|                                                      zhuliea.mq4 |
//|                       Copyright ?2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define MAGIC 20120224

#define CrossNone 0
#define GoldenCross 1
#define DeadCross 2
#define ClosePosition 3

extern int N1 = 20;
extern int N2 = 10;

int last_counted_bars = 0;

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

    if (last_counted_bars == Bars)
        return (0);
    else
        last_counted_bars = Bars;

    double SigBuy  = iCustom(0, 0, "faze", N1, N2, 1, 1);
    double SigSell = iCustom(0, 0, "faze", N1, N2, 2, 1);
    double SigStopBuyLoss = iCustom(0, 0, "faze", N1, N2, 3, 1);
    double SigStopBuyProfit = iCustom(0, 0, "faze", N1, N2, 4, 1);
    double SigStopSellLoss = iCustom(0, 0, "faze", N1, N2, 5, 1);
    double SigStopSellProfit = iCustomer(0, 0, "faze", N1, N2, 6, 1);

    //----
    return(0);
}

//+------------------------------------------------------------------+
//| golden cross function                                 |
//+------------------------------------------------------------------+
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
                else
                    AskQty = AskQty - OrderLots();
            }
            else
                if (OrderType() == OP_BUY)
                {
                    if (!OrderClose(OrderTicket(),OrderLots(),Bid, 5, Gray))
                    {
                        Print("Close Buy Order ", OrderTicket(), " failed (", GetLastError(), ")");
                    }
                    else
                        BidQty = BidQty - OrderLots();
                }
        }
    }
}  

//+------------------------------------------------------------------+
//| golden cross function                                 |
//+------------------------------------------------------------------+
void goldenCrossed()
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC)
        {
            // Close sell orders, since we should buy now
            if (OrderType() == OP_SELL)
            {
                if (!OrderClose(OrderTicket(),OrderLots(),Ask, 5, Green))
                {
                    Print("Close Sell Order ", OrderTicket(), " failed (", GetLastError(), ")");
                }
                else
                    AskQty = AskQty - OrderLots();
            }
        }
    }

    //Print(LastOpenBars, ":", Bars);

    //if (LastOpenBars == Bars)
    //   return;

    //LastOpenBars = Bars;
    //Print("LastOpenBars:", LastOpenBars);

    if (BidQty > 0)
        return;

    if (OrderSend(Symbol(), OP_BUY, 1, Ask, 5, 0.0, 0.0, NULL, MAGIC) < 0)
    {
        Print("Open Buy failed(", GetLastError(), ")");
    }
    else
        BidQty = 1;
}

//+------------------------------------------------------------------+
//| dead cross function                                 |
//+------------------------------------------------------------------+
void deadCrossed()
{
    for(int i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC)
        {
            // Close sell orders, since we should buy now
            if (OrderType() == OP_BUY)
            {
                if (!OrderClose(OrderTicket(),OrderLots(),Bid, 5, Green))
                {
                    Print("Close Buy Order ", OrderTicket(), " failed (", GetLastError(), ")");
                }
                else
                    BidQty = BidQty - OrderLots();
            }
        }
    }

    //Print(LastOpenBars, ":", Bars);

    //if (LastOpenBars == Bars)
    //{
    //   return;
    //}
    //LastOpenBars = Bars;
    //Print("LastOpenBars:", LastOpenBars);

    if (AskQty > 0)
        return;

    if (OrderSend(Symbol(), OP_SELL, 1, Bid, 5, 0.0, 0.0, NULL, MAGIC) < 0)
    {
        Print("Open Sell failed(", GetLastError(), ")");
    }
    else
        AskQty = 1;
}

//+------------------------------------------------------------------+


