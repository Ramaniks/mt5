//+------------------------------------------------------------------+
//|                                                     ThreeEMA.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Trailing\TrailingNone.mqh>
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Inp_Expert_Title                ="ThreeEMA";
int          Expert_MagicNumber              =31286;
bool         Expert_EveryTick                =false;
//--- inputs for signal
//input int    Inp_Signal_ThreeEMA_FastPeriod  =5;
//input int    Inp_Signal_ThreeEMA_MediumPeriod=12;
//input int    Inp_Signal_ThreeEMA_SlowPeriod  =24;
//input int    Inp_Signal_ThreeEMA_StopLoss    =400;
//input int    Inp_Signal_ThreeEMA_TakeProfit  =900;
//--- inputs for money
input double Inp_Money_FixLot_Percent        =10.0;
input double Inp_Money_FixLot_Lots           =0.01;
//input int      MA_Period=13;     // MA Period
// handle for our Moving Average indicator
int maPrincipal, maPrimaria, maSecundaria, maTerciaria, maQuaternaria;
// dynamic array to hold the values of Moving Average for each bars
double dmaPrincipal[], dmaPrimaria[], dmaSecundaria[], dmaTerciaria[], dmaQuaternaria[];
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
//--- Creation of signal object
   /*CSignalMA *signal=new CSignalMA;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(-2);
     }
//--- Add signal to expert (will be deleted automatically))
   if(!ExtExpert.InitSignal(signal))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing signal");
      ExtExpert.Deinit();
      return(-3);
     }
     
//--- Check signal parameters
   if(!signal.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error signal parameters");
      ExtExpert.Deinit();
      return(-4);
     }*/
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(-5);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(-6);
     }
//--- Set trailing parameters
//--- Check trailing parameters
   if(!trailing.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error trailing parameters");
      ExtExpert.Deinit();
      return(-7);
     }
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(-8);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(-9);
     }
//--- Set money parameters
   money.Percent(Inp_Money_FixLot_Percent);
   money.Lots(Inp_Money_FixLot_Lots);
//--- Check money parameters
   if(!money.ValidationSettings())
     {
      //--- failed
      printf(__FUNCTION__+": error money parameters");
      ExtExpert.Deinit();
      return(-10);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(-11);
     }
    //Print("LC: ",signal.LongCondition());
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
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
     //SetIndexBuffer(0,iMABuffer,INDICATOR_DATA);
     //handle=iMA(name,period,ma_period,ma_shift,ma_method,applied_price);
      //--- fill the structure with parameters of the indicator
      maPrincipal    =iMA(_Symbol,Period(),005,0,MODE_EMA,PRICE_CLOSE);
      CopyBuffer(maPrincipal,0,0,5,dmaPrincipal);
      maPrimaria     =iMA(_Symbol,Period(),012,0,MODE_EMA,PRICE_CLOSE);
      CopyBuffer(maPrimaria,0,0,5,dmaPrimaria);
      maSecundaria   =iMA(_Symbol,Period(),050,0,MODE_EMA,PRICE_CLOSE);
      CopyBuffer(maSecundaria,0,0,5,dmaSecundaria);
      maTerciaria    =iMA(_Symbol,Period(),200,0,MODE_EMA,PRICE_CLOSE);
      CopyBuffer(maTerciaria,0,0,5,dmaTerciaria);
      maQuaternaria  =iMA(_Symbol,Period(),800,0,MODE_EMA,PRICE_CLOSE);
      CopyBuffer(maQuaternaria,0,0,5,dmaQuaternaria);
      Print("IMAM: ", dmaPrincipal[4]);
      Print("IMAP: ", dmaPrimaria[4]);
      Print("IMAS: ", dmaSecundaria[4]);
      Print("IMAT: ", dmaTerciaria[4]);
      Print("IMAQ: ", dmaQuaternaria[4]);
      
      //A Principio o valor de retorno é no registrador de numero 4.
      //Mas esse valor é conforme o fechamento do valor anterior do Periodo.
      Print("IMA4-Igual linha: ", dmaPrincipal[4]);
  }
//+------------------------------------------------------------------+
//| Function-event handler "trade"                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| Function-event handler "timer"                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
