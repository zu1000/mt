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

extern int N1 = 9;
extern int N2 = 5;
extern int N3 = 10;

extern int IgnoreDistance = 15;
extern int MaxDistance = 35;
extern int MinDistance = 20;

int LastOpenBars = 0;
int LastPotentialCrossType = CrossNone;
int LastCrossType = CrossNone;
int LastValidCrossBar = 0;
int Distance = 0;

int BidQty = 0;
int AskQty = 0;
bool ignored = false;
bool closeMe = false;
double LastGolden = 0;
double LastDead = 0;
double LastValidGolden = 0;
double LastValidDead = 0;

double LastDistance[2];

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
   LastDistance[0] = EMPTY_VALUE;
   LastDistance[1] = EMPTY_VALUE; 
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

   double zlgj = iCustom(0, 0, "zhuli", N1, N2, 1, 1);
   double mazl = iCustom(0, 0, "zhuli", N1, N2, 2, 1);
   double golden = iCustom(0, 0, "zhuli", N1, N2, 3, 1);
   double dead   = iCustom(0, 0, "zhuli", N1, N2, 4, 1);
   
   double delta = MathAbs(mazl-zlgj);
   
   if (LastOpenBars != Bars && (golden != EMPTY_VALUE || dead != EMPTY_VALUE))
   {
// Valid Golden Cross
// If GC < 0 && Abs(GC) >= N3 && (GC - LastValidDC) <= NegativeMaxDistance
// If LastValidCross == DeadCross && (GC - LastValidDC) <= NegativeMaxDistance
// If LastValidCross == DeadCross && GC > PositiveMinDistance && ABS(GC - LastValidGD) > IgnoreDistance

// Valid Dead Cross
// If DC > 0 && Abs(GC) >= N3 && (DC - LastGC) >= N3
// If LastValidCross == GoldenCross && (DC - LastValidGD) >= PositiveMaxDistance
// If LastValidCross == GoldenCross && DC < NegativeMinDistance && ABS(DC - LastValidGC) > IgnoreDistance 

// Close Position
// If Crossing Point consectively neare 0...
      string name;
      double distance = 0;
      bool valid = false;      
      if(golden != EMPTY_VALUE)
      {
         name = "golden";
         //distance = golden - LastDead;
         //ignored = (MathAbs(mazl) < N3 || MathAbs(distance) < 1.5*N3);
         ////ignored = MathAbs(distance) < N3;
         distance = MathAbs(golden);

         if ((golden <= -MaxDistance) && ((golden - LastDead) <= -MaxDistance))
         {
            Print("Buy Valid 1: ", golden, ", ", LastDead);
            valid = true;
         }
         else
         if ((LastCrossType == DeadCross) && ((golden - LastDead) <= -MaxDistance) && (MathAbs(golden) > IgnoreDistance))
         {
            Print("Buy Valid 2: ", golden, ", ", LastDead);
            valid = true;
         }
         else
         if ((LastCrossType == DeadCross) && (golden > MinDistance) && (MathAbs(golden - LastDead) < IgnoreDistance))
         {
            Print("Buy Valid 3: ", golden, ", ", LastDead);
            valid = true;
         }
         else
         if ((LastCrossType == DeadCross) && (LastValidDead > MinDistance) && (golden - LastValidDead > 0))
         {
            Print("Buy Valid 4: ", golden, ", ", LastValidDead);
            valid = true;
         }
         else
         if ((LastValidCrossBar != 0) && ((golden - LastDead) < -MaxDistance) && (MathAbs(Bars - LastOpenBars) < N2))
         {
            Print("Buy Valid 5: ", golden, ", ", LastDead, ", ", LastOpenBars, ", ", Bars);
            valid = true;
         }
         else
         if (((LastCrossType == CrossNone) || (LastCrossType == ClosePosition)) && (golden <= -MaxDistance))
         {
            Print("Buy Valid 6: ", golden);
            valid = true;
         }
         else
            Print("Buy Invalid: ", golden, ", ", LastDead, ", ", LastValidDead, ", ", LastOpenBars, ", ", Bars);
            
         ignored = !valid;
         
         LastGolden = golden;
         
         if (valid)
         {
            LastValidGolden = golden;
            LastValidCrossBar = Bars;
         }
      }
      else
      if(dead != EMPTY_VALUE)
      {
         name = "dead";
         //distance = dead - LastGolden;
         //ignored = (MathAbs(mazl) < N3 || MathAbs(distance) < 1.5*N3);
         ////ignored = MathAbs(distance) < N3;
         distance = MathAbs(dead);
         if ((dead >= MaxDistance) && ((dead - LastGolden) >= MaxDistance))
         {
            Print("Sell Valid1: ", dead, ", ", LastGolden);
            valid = true;
         }
         else
         if ((LastCrossType == GoldenCross) && ((dead - LastGolden) > MaxDistance) && (MathAbs(dead) > IgnoreDistance))
         {
            Print("Sell Valid2: ", dead, ", ", LastGolden);
            valid = true;
         }
         else
         if ((LastCrossType == GoldenCross) && (dead < -MinDistance) && (MathAbs(dead - LastGolden) < IgnoreDistance))
         {
            Print("Sell Valid3: ", dead, ", ", LastGolden);
            valid = true;
         }
         else
         if ((LastCrossType == GoldenCross) && (LastValidGolden < -MinDistance) && (dead - LastValidGolden < 0))
         {
            Print("Sell Valid4: ", dead, ", ", LastValidGolden);
            valid = true;
         }
         else
         if ((LastValidCrossBar != 0) && ((dead - LastGolden) > MaxDistance) && (MathAbs(Bars - LastOpenBars) < N2))
         {
            Print("Sell Valid5: ", dead, ", ", LastGolden, ", ", LastOpenBars, ", ", Bars);
            valid = true;
         }
         else
         if (((LastCrossType == CrossNone) || (LastCrossType == ClosePosition)) && (dead >= MaxDistance))
         {
            Print("Buy Valid 6: ", dead);
            valid = true;
         }
         else
         {
            Print("Sell Invalid: ", dead, ", ", LastGolden, ", ", LastValidGolden, ", ", LastOpenBars, ", ", Bars);
         }
            
         ignored = !valid;
         
         LastDead = dead;
         
         if (valid)
         {
            LastValidDead = dead;
            LastValidCrossBar = Bars;
         }
      }
      
      if (ignored)
      {
         if (LastDistance[1] != EMPTY_VALUE && MathAbs(distance) <IgnoreDistance && MathAbs(LastDistance[0]) < IgnoreDistance && MathAbs(LastDistance[1]) < IgnoreDistance)
         {
            Print("Close Valide: ", distance, ", ",  LastDistance[0], ", ", LastDistance[1]);
            closeMe = true;
         }
         if (closeMe)
         {
            LastDead = 0;
            LastGolden = 0;
            LastValidDead = 0;
            LastValidGolden = 0;
            LastValidCrossBar = 0;
            LastOpenBars = 0;
            Print(name, ": " , MathAbs(mazl), ",", N3, ",", distance, "(close....)");
         }
         else
            Print(name, ": " , MathAbs(mazl), ",", N3, ",", distance, "(Ignored....)");
         
         //Print(Bars, ", ", LastOpenBars, "(Ignored...)");
      }
      else
      {
         Print(name, ": ", MathAbs(mazl), ",", N3, ",", distance, "(Not Ignored....)");
         //Print(Bars, ", ", LastOpenBars, "(Not Ignored...)");
      }
      
      LastDistance[1] = LastDistance[0];
      LastDistance[0] = distance;
   }
   
   if (golden != EMPTY_VALUE)
   {
      //if (reverse)
      //   LastPotentialCrossType = DeadCross;
      //else
      if (closeMe)
         LastPotentialCrossType = ClosePosition;
      else
      if (!ignored)
         LastPotentialCrossType = GoldenCross;
      else
         LastPotentialCrossType = CrossNone;
      //goldenCrossed();
      //Print("Golden Cross: ", golden);
      LastOpenBars = Bars;
      //LastGolden = golden;
   }
   else
   if (dead != EMPTY_VALUE)
   {
      //if (reverse)
      //   LastPotentialCrossType = GoldenCross;
      //else
      if (closeMe)
         LastPotentialCrossType = ClosePosition;
      else
      if (!ignored)
         LastPotentialCrossType = DeadCross;
      else
         LastPotentialCrossType = CrossNone;
      //deadCrossed();
      //Print("Dead Cross: ", dead);
      LastOpenBars = Bars;
      //LastDead = dead;
   }
   //else
   if (LastPotentialCrossType == GoldenCross)
   {
      if (LastCrossType != GoldenCross)
      {
         //if (reverse)
         //   Print("GoldenCross (Reversed...)");
         //else
         //   Print("GoldenCross (Not Reversed...)");

         goldenCrossed();
         //deadCrossed();
         LastCrossType = GoldenCross;
         LastPotentialCrossType = CrossNone;
      }
   }
   else
   if (LastPotentialCrossType == DeadCross)
   {
      if (LastCrossType != DeadCross)
      {
         //if (reverse)
         //   Print("DeadCross (Reversed...)");
         //else
         //   Print("DeadCross (Not Reversed...)");
         deadCrossed();
         //goldenCrossed();
         LastCrossType = DeadCross;
         LastPotentialCrossType = CrossNone;
      }
   }
   else
   if (LastPotentialCrossType == ClosePosition)
   {
      closePosition();
      LastPotentialCrossType = CrossNone;
      LastCrossType = CrossNone;
      closeMe = false;
   }
   
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


