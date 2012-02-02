//+------------------------------------------------------------------+
//|                                               testesdiversos.mq5 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedRisk.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title         ="testesdiversos"; // Document name
ulong                    Expert_MagicNumber   =471;              // 
bool                     Expert_EveryTick     =false;            // 
//--- inputs for main signal
input int                Signal_ThresholdOpen =10;               // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose=10;               // Signal threshold value to close [0...100]
input double             Signal_PriceLevel    =0.0;              // Price level to execute a deal
input double             Signal_StopLevel     =50.0;             // Stop Loss level (in points)
input double             Signal_TakeLevel     =50.0;             // Take Profit level (in points)
input int                Signal_Expiration    =200;                // Expiration of pending orders (in bars)
input int                Signal_0_MA_PeriodMA =5;                // Moving Average(5,0,MODE_SMA,...) Period of averaging
input int                Signal_0_MA_Shift    =0;                // Moving Average(5,0,MODE_SMA,...) Time shift
input ENUM_MA_METHOD     Signal_0_MA_Method   =MODE_SMA;         // Moving Average(5,0,MODE_SMA,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_0_MA_Applied  =PRICE_CLOSE;      // Moving Average(5,0,MODE_SMA,...) Prices series
input double             Signal_0_MA_Weight   =1.0;              // Moving Average(5,0,MODE_SMA,...) Weight [0...1.0]
input int                Signal_1_MA_PeriodMA =12;               // Moving Average(12,0,...) Period of averaging
input int                Signal_1_MA_Shift    =0;                // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_1_MA_Method   =MODE_SMA;         // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_1_MA_Applied  =PRICE_CLOSE;      // Moving Average(12,0,...) Prices series
input double             Signal_1_MA_Weight   =1.0;              // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_2_MA_PeriodMA =50;               // Moving Average(50,0,...) Period of averaging
input int                Signal_2_MA_Shift    =0;                // Moving Average(50,0,...) Time shift
input ENUM_MA_METHOD     Signal_2_MA_Method   =MODE_SMA;         // Moving Average(50,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_2_MA_Applied  =PRICE_CLOSE;      // Moving Average(50,0,...) Prices series
input double             Signal_2_MA_Weight   =1.0;              // Moving Average(50,0,...) Weight [0...1.0]
input int                Signal_3_MA_PeriodMA =200;              // Moving Average(200,0,...) Period of averaging
input int                Signal_3_MA_Shift    =0;                // Moving Average(200,0,...) Time shift
input ENUM_MA_METHOD     Signal_3_MA_Method   =MODE_SMA;         // Moving Average(200,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_3_MA_Applied  =PRICE_CLOSE;      // Moving Average(200,0,...) Prices series
input double             Signal_3_MA_Weight   =1.0;              // Moving Average(200,0,...) Weight [0...1.0]
//input int                Signal_4_MA_PeriodMA =800;              // Moving Average(800,0,...) Period of averaging
//input int                Signal_4_MA_Shift    =0;                // Moving Average(800,0,...) Time shift
//input ENUM_MA_METHOD     Signal_4_MA_Method   =MODE_SMA;         // Moving Average(800,0,...) Method of averaging
//input ENUM_APPLIED_PRICE Signal_4_MA_Applied  =PRICE_CLOSE;      // Moving Average(800,0,...) Prices series
//input double             Signal_4_MA_Weight   =1.0;              // Moving Average(800,0,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_MA_Period   =200;               // Period of MA
input int                Trailing_MA_Shift    =0;                // Shift of MA
input ENUM_MA_METHOD     Trailing_MA_Method   =MODE_SMA;         // Method of averaging
input ENUM_APPLIED_PRICE Trailing_MA_Applied  =PRICE_CLOSE;      // Prices series
//--- inputs for money
input double             Money_FixRisk_Percent=30.0;             // Risk percentage
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(-1);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(-2);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalMA
   CSignalMA *filter0=new CSignalMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(-3);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_0_MA_PeriodMA);
   filter0.Shift(Signal_0_MA_Shift);
   filter0.Method(Signal_0_MA_Method);
   filter0.Applied(Signal_0_MA_Applied);
   filter0.Weight(Signal_0_MA_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter1=new CSignalMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(-4);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_1_MA_PeriodMA);
   filter1.Shift(Signal_1_MA_Shift);
   filter1.Method(Signal_1_MA_Method);
   filter1.Applied(Signal_1_MA_Applied);
   filter1.Weight(Signal_1_MA_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter2=new CSignalMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(-5);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_2_MA_PeriodMA);
   filter2.Shift(Signal_2_MA_Shift);
   filter2.Method(Signal_2_MA_Method);
   filter2.Applied(Signal_2_MA_Applied);
   filter2.Weight(Signal_2_MA_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter3=new CSignalMA;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(-6);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodMA(Signal_3_MA_PeriodMA);
   filter3.Shift(Signal_3_MA_Shift);
   filter3.Method(Signal_3_MA_Method);
   filter3.Applied(Signal_3_MA_Applied);
   filter3.Weight(Signal_3_MA_Weight);
//--- Creating filter CSignalMA
   //CSignalMA *filter4=new CSignalMA;
   //if(filter4==NULL)
     {
      //--- failed
      //printf(__FUNCTION__+": error creating filter4");
      //ExtExpert.Deinit();
      //return(-7);
     }
  // signal.AddFilter(filter4);
//--- Set filter parameters
   //filter4.PeriodMA(Signal_4_MA_PeriodMA);
   //filter4.Shift(Signal_4_MA_Shift);
   //filter4.Method(Signal_4_MA_Method);
   //filter4.Applied(Signal_4_MA_Applied);
   //filter4.Weight(Signal_4_MA_Weight);
//--- Creation of trailing object
   CTrailingMA *trailing=new CTrailingMA;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(-8);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(-9);
     }
//--- Set trailing parameters
   trailing.Period(Trailing_MA_Period);
   trailing.Shift(Trailing_MA_Shift);
   trailing.Method(Trailing_MA_Method);
   trailing.Applied(Trailing_MA_Applied);
//--- Creation of money object
   CMoneyFixedRisk *money=new CMoneyFixedRisk;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(-10);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(-11);
     }
//--- Set money parameters
   money.Percent(Money_FixRisk_Percent);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(-12);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(-13);
     }
//--- ok
   return(0);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
