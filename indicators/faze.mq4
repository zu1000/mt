//+------------------------------------------------------------------+
//|                                                         demo.mq4 |
//|                                            Copyright ?2012, Joe. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2012, Joe."
#property link      ""

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 Blue
#property indicator_color4 Green
#property indicator_color5 Olive
#property indicator_color6 DarkGoldenrod
#property indicator_color7 White
#property indicator_color8 Pink
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1

//---- input
extern int N1 = 20;
extern int N2 = 10;

//---- buffers
// The buffer for signals
double SigBuy[], SigSell[];
double SigStopBuyLoss[], SigStopBuyProfit[];
double SigStopSellLoss[], SigStopSellProfit[];
double mylowest[], myhighest[];

// The buffer for Period ATR
//double ATR[];

double min_value1[2], min_value2[2];
double max_value1[2], max_value2[2];

double SigBuyPrice = EMPTY_VALUE;
double SigSellPrice = EMPTY_VALUE;

double PriceBreakHighest = EMPTY_VALUE;
double PriceBreakLowest = EMPTY_VALUE;

double lowest_min_10 = EMPTY_VALUE;
double highest_max_10 = EMPTY_VALUE;

int last_counted_bars = EMPTY_VALUE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    //---- indicators
    string shortName;
    //Init the style of indicators
    shortName = "Buy";
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexBuffer(0,SigBuy);
    SetIndexArrow(0,141);
    SetIndexLabel(0, shortName);
    shortName = "Sell";
    SetIndexStyle(1,DRAW_ARROW);
    SetIndexBuffer(1,SigSell);
    SetIndexArrow(1,142);
    SetIndexLabel(1, shortName);
    shortName = "StopBuyLoss";
    SetIndexStyle(2,DRAW_ARROW);
    SetIndexBuffer(2,SigStopBuyLoss);
    SetIndexArrow(2,143);
    SetIndexLabel(2, shortName);
    shortName = "StopBuyProfit";
    SetIndexStyle(3,DRAW_ARROW);
    SetIndexBuffer(3,SigStopBuyProfit);
    SetIndexArrow(3,144);
    SetIndexLabel(3, shortName);
    shortName = "StopSellLoss";
    SetIndexStyle(4, DRAW_ARROW);
    SetIndexBuffer(4, SigStopSellLoss);
    SetIndexArrow(4, 145);
    SetIndexLabel(4, shortName);
    shortName = "StopSellProfit";
    SetIndexStyle(5, DRAW_ARROW);
    SetIndexBuffer(5, SigStopSellProfit);
    SetIndexArrow(5, 146);
    SetIndexLabel(5, shortName);

    SetIndexStyle(6, DRAW_LINE);
    SetIndexBuffer(6, myhighest);

    SetIndexStyle(7, DRAW_LINE);
    SetIndexBuffer(7, mylowest);

    min_value1[0] = EMPTY_VALUE;
    min_value1[1] = EMPTY_VALUE;
    max_value1[0] = EMPTY_VALUE;
    max_value1[1] = EMPTY_VALUE;
    min_value2[0] = EMPTY_VALUE;
    min_value2[1] = EMPTY_VALUE;
    max_value2[0] = EMPTY_VALUE;
    max_value2[1] = EMPTY_VALUE;
    //----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
    //----

    //----
    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
    int counted_bars = IndicatorCounted();
    int limit = Bars - counted_bars - 1;

    // it is aready calculated... don't do anything
    if (last_counted_bars == Bars)
        return (0);
    else
        last_counted_bars = Bars;

    // Init the buffer
    for (int j = 1; j < limit; j++)
    {
        SigBuy[j] = EMPTY_VALUE;
        SigSell[j] = EMPTY_VALUE;
        SigStopBuyLoss[j] = EMPTY_VALUE;
        SigStopBuyProfit[j] = EMPTY_VALUE;
        SigStopSellLoss[j] = EMPTY_VALUE;
        SigStopSellProfit[j] = EMPTY_VALUE;


        //myclose[j] = Close[j];
    }

    Print(limit);
    //----
    for (int i = limit; i >0; i--)
    {

        bool signaled = false;
        bool break_highest_10 = false;
        bool break_lowest_10 = false;
        bool up = false;
        bool down = false;

        // Calculate ATR
        double ATR = iATR(NULL, NULL, N1, i);
        //Print("ATR[", j, "]", DoubleToStr(ATR, 8));

        // Get the highest
        double highest = EMPTY_VALUE;
        double lowest = EMPTY_VALUE;
        double highest_10 = EMPTY_VALUE;
        double lowest_10 = EMPTY_VALUE;
        double ma_10 = EMPTY_VALUE;
        double min_value = EMPTY_VALUE;
        double max_value = EMPTY_VALUE;

        //if (Bars < N1)
        //{
        // get the last day's high/low prices
        //   highest = High[iHighest(NULL, PERIOD_D1, MODE_HIGH, 1, 0)];
        //   lowest = Low[iLowest(NULL, PERIOD_D1, MODE_LOW, 1, 0)];
        //}
        //else
        {
            highest = High[iHighest(NULL, 0, MODE_HIGH, N1, i+1)];
            lowest = Low[iLowest(NULL, 0, MODE_LOW, N1, i+1)];
        }

        //if (Bars < N2)
        //{
        //   highest_10 =iHighest(NULL, PERIOD_D1, MODE_HIGH, 1, 0)];
        //   lowest_10 = Low[iLowest(NULL, PERIOD_D1, MODE_LOW, 1, 0)];
        //}
        //else
        {
            highest_10 = High[iHighest(NULL, 0, MODE_HIGH, N2, i+1)];
            lowest_10 = Low[iLowest(NULL, 0, MODE_LOW, N2, i+1)];
        }

        {
            ma_10 = iMA(NULL, 0, N2, 0, MODE_SMA, PRICE_CLOSE, i+1);
        }

        myhighest[i] = highest;
        mylowest[i] = lowest;

        if (highest_max_10 == EMPTY_VALUE || highest_max_10 < highest_10)
        {
            if (highest_max_10 != EMPTY_VALUE)
                break_highest_10 = true;

            highest_max_10 = highest_10;
        }

        if (lowest_min_10 == EMPTY_VALUE || lowest_min_10 > lowest_10)
        {
            if (lowest_min_10 != EMPTY_VALUE)
                break_lowest_10 = true;

            lowest_min_10 = lowest_10;
        }

        up = Close[i] > Open[i];
        down = Close[i] < Open[i];

        // check if we need to signal buy
        if (crossUp(Close[i+1], Close[i], myhighest[i+1], myhighest[i]))
        {
            PriceBreakHighest = Close[i];
            if ((SigBuyPrice == EMPTY_VALUE) || (SigBuyPrice > Close[i]))
            {
                SigBuy[i] = Close[i] + Close[i]*0.001;
                SigBuyPrice = Close[i];
                SigSellPrice = EMPTY_VALUE;
                signaled = true;
            }
        }

        // check if we need to signal sell      
        if (!signaled && crossUp(mylowest[i+1], mylowest[i], Close[i+1], Close[i]))
        {
            PriceBreakLowest = Close[i];
            if ((SigSellPrice == EMPTY_VALUE) || (SigSellPrice < Close[i]))
            {
                SigSell[i] = Close[i] + Close[i]*0.001;
                SigSellPrice = Close[i];
                SigBuyPrice = EMPTY_VALUE;
                signaled = true;
            }
        }

        min_value1[0] = min_value1[1];      
        min_value1[1] = MathMin(ma_10, highest_10 - 2*ATR);
        max_value1[0] = max_value1[1];
        max_value1[1] = MathMax(ma_10, highest_10 - 2*ATR);

        max_value2[0] = max_value2[1];
        max_value2[1] = MathMax(ma_10, lowest_10 + 2*ATR);
        min_value2[0] = min_value2[1];
        min_value2[1] = MathMin(ma_10, lowest_10 + 2*ATR);

        // check if we need to stop buy loss or stop buy profit
        // when we stop loss and stop profit, reset the SigBuyPrice to
        // EMPTY_VALUE
        if (!signaled && SigBuyPrice != EMPTY_VALUE && Close[i] < highest)
        {
            // if the last close price indicate that price is down more than
            // 2 ATRs, we have to stop buy loss
            //if ((PriceBreakHighest - Close[i]) > 2*ATR[i])
            if (crossUp(min_value1[0], min_value1[1], Close[i+1], Close[i]))
            {
                // if the last close price indicate that price is down more than
                // 2 ATRs, we have to stop buy loss
                SigStopBuyLoss[i] = Close[i] - Close[i]*0.001;
                SigBuyPrice = EMPTY_VALUE;
                signaled = true;
            }
            else
            //if (break_highest_10)
            if (crossUp(max_value1[0], max_value1[1], Close[i+1], Close[i]))
            {
                //Print(DoubleToStr(max_value1[0], 8), ",", DoubleToStr(max_value1[1],8), ",", DoubleToStr(Close[i+1],8), ",", DoubleToStr(Close[i],8));
                //Print(DoubleToStr(ATR[i], 8), ",", DoubleToStr(highest_10, 8), ",", DoubleToStr(ma_10, 8));
                // if the last close price break the 10 highest,
                // we stop sell profit
                SigStopBuyProfit[i] = Close[i] + Close[i]*0.001;
                SigBuyPrice = EMPTY_VALUE;
                signaled = true;
            }
        }
        // check if we need to stop sell loss or stop sell profit
        // when we stop loss and stop profit, reset the SigSellPrice to
        // EMPTY_VALUE
        if (!signaled && SigSellPrice != EMPTY_VALUE && Close[i] > lowest)
        {
            //if ((Close[i] - PriceBreakLowest) > 2*ATR[i])
            if (crossUp(Close[i+1], Close[i], max_value2[0], max_value2[1]))
            {
                // if the last close price indicate that price is up more than
                // 2 ATRs, we have to stop sell loss
                SigStopSellLoss[i] = Close[i] + Close[i]*0.001;
                SigSellPrice = EMPTY_VALUE;
                signaled = true;
            }
            else
            //if (break_lowest_10)
            if (crossUp(Close[i+1], Close[i], min_value2[0], min_value2[1]))
            {
                // if the last close price break the 10 lowest,
                // we stop sell profit
                SigStopSellProfit[i] = Close[i] - Close[i]*0.001;
                SigSellPrice = EMPTY_VALUE;
                signaled = true;
            }
        }
    }
    //----
    return(0);
}

// line 1 cross up line 2
bool crossUp(double l1v0, double l1v1, double l2v0, double l2v1)
{
    return ((l1v0 <= l2v0) && (l1v1 > l2v1)); 
} 