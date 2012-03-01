//+------------------------------------------------------------------+
//|                                                        zhuli.mq4 |
//|                       Copyright ?2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright ?2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window

#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Yellow
#property indicator_color3 Blue
#property indicator_color4 Gold
#property indicator_color5 White
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1

#define CrossNone 0
#define GoldenCross 1
#define DeadCross 2

//---- input
extern int N1 = 9;
extern int N2 = 5;

//---- buffers
double mtm[], zlgj[], mazl[], golden_cross[], deadly_cross[];
double last_ema_mtm, last_ema_ema_mtm;
double last_ema_abs_mtm, last_ema_ema_abs_mtm;
//----
int ExtCountedBars=0;

int LastCross = CrossNone;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   string name;
   
   name = "MTM";
   SetIndexBuffer(0, mtm);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexLabel(0, name);
   
   name = "ZLGJ";
   SetIndexBuffer(1, zlgj);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexLabel(1, name);
   
   name = "MAZL";
   SetIndexBuffer(2, mazl);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexLabel(2, name);
   
   name = "GOLD";
   SetIndexBuffer(3, golden_cross);
   SetIndexStyle(3, DRAW_ARROW);
   //SetIndexArrow(3, 141);
   SetIndexLabel(3, name);
   
   name = "DEAD";
   SetIndexBuffer(4, deadly_cross);
   SetIndexStyle(4, DRAW_ARROW);
   //SetIndexArrow(4, 142);
   SetIndexLabel(4, name);

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
   if (Bars < N1) return (0);
   
   int    counted_bars=IndicatorCounted();
   //ExtCountedBars = counted_bars;
//----
   calc();
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Exponential Moving Average                                       |
//+------------------------------------------------------------------+

void calc()
  {
   double ema_mtm, ema_ema_mtm, ema_abs_mtm, ema_ema_abs_mtm;
   double pr=NormalizeDouble(2.0/(N1+1), 8);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
//---- main calculation loop
   while(pos>0)
     {
      mtm[pos] = Close[pos] - Close[pos+1];
      
      //Print(DoubleToStr(mtm[pos], 8));
      if(pos==Bars-2)
      {
         //ExtMapBuffer[pos+1]=Close[pos+1];
         last_ema_mtm=mtm[pos+1];
         last_ema_ema_mtm = last_ema_mtm;
         last_ema_abs_mtm = MathAbs(mtm[pos+1]);
         last_ema_ema_abs_mtm = last_ema_abs_mtm;
         zlgj[pos+1] = mtm[pos+1];
      }
      
      //ExtMapBuffer[pos]=Close[pos]*pr+ExtMapBuffer[pos+1]*(1-pr);
      ema_mtm     = NormalizeDouble(mtm[pos]*pr, 8) + NormalizeDouble(last_ema_mtm*(1-pr), 8);
      ema_ema_mtm = ema_mtm + NormalizeDouble(last_ema_ema_mtm*(1-pr), 8);
      ema_abs_mtm = NormalizeDouble(MathAbs(mtm[pos])*pr, 8) + NormalizeDouble(last_ema_abs_mtm*(1-pr), 8);
      ema_ema_abs_mtm = ema_abs_mtm + NormalizeDouble(last_ema_ema_abs_mtm*(1-pr), 8);
      
      zlgj[pos] = NormalizeDouble(100 * ema_ema_mtm / ema_ema_abs_mtm, 8);
      
      last_ema_mtm = ema_mtm;
      last_ema_ema_mtm = ema_ema_mtm;
      last_ema_abs_mtm = ema_abs_mtm;
      last_ema_ema_abs_mtm = ema_ema_abs_mtm;
      
      int ma_loop_cnt = N2;
      int sum = 0;
      if ((Bars - pos) < N2)
      {
         ma_loop_cnt = Bars - pos;
      }
      
      //Print(ma_loop_cnt);
      for (int i = 0; i < ma_loop_cnt; i++)
      {
         //Print(zlgj[pos+i]);
         sum = sum + zlgj[pos+i];
      }
      
      //Print(sum, ",", ma_loop_cnt);
      
      mazl[pos] = NormalizeDouble(sum / ma_loop_cnt, 8);

      if (Bars - pos > 2)
      {
         if (crossUp(zlgj[pos+1], zlgj[pos], mazl[pos+1], mazl[pos]))
         {
            if (LastCross != GoldenCross)
               golden_cross[pos] = mazl[pos];
            //Print("GOLD:", zlgj[pos+1], ",", zlgj[pos], ",", mazl[pos+1], ",", mazl[pos], ",", golden_cross[pos]);
         }
         else
         if (crossUp(mazl[pos+1], mazl[pos], zlgj[pos+1], zlgj[pos]))
         {
            if (LastCross != DeadCross)
               deadly_cross[pos] = mazl[pos];
            //Print("Dead:", zlgj[pos+1], ",", zlgj[pos], ",", mazl[pos+1], ",", mazl[pos], ",", deadly_cross[pos]);
         }
      }

	   pos--;
     }
  }
  
  // line 1 cross up line 2
bool crossUp(double l1v0, double l1v1, double l2v0, double l2v1)
{
   return ((NormalizeDouble(l1v0, 8) <= NormalizeDouble(l2v0, 8)) && (NormalizeDouble(l1v1, 8) > NormalizeDouble(l2v1, 8))); 
}
 