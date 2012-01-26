/*
 * Montar a estrategia que foi comprado da Ingressos Digitales.
 * E testar nos varios periodos
 * This multi-currency Expert Advisor trades using the iTEMA indicator signals
 * A Principio o valor de retorno é no registrador de numero 4.
 * Mas esse valor é conforme o fechamento do valor anterior do Periodo.
 * - maPrincipal    =iMA(_Symbol,Period(),EMAMain,0,ModeMA,ApPrice);
 * - CopyBuffer(maPrincipal,0,0,5,dmaPrincipal);
 * - Print("IMAM: ", dmaPrincipal[4]);
 */

//+------------------------------------------------------------------+ 
//|                                               Crossover_2011.mq5 | 
//|                              Copyright © 2012,  Valdecir Neumann | 
//|                                             ramaniks79@gmail.com | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Valdecir Neumann"
#property link "ramaniks79@gmail.com" 
//---- indicator version
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Expert\Expert.mqh>
#include <Expert\ExpertSignal.mqh>
#include <Expert\Trailing\TrailingNone.mqh>
#include <Expert\Money\MoneyFixedLot.mqh>
//+-----------------------------------------------------------------+
//|                   Expert input parameters                       |
//+-----------------------------------------------------------------+
input string Inp_Expert_Title              = "Crossover_2011";
int          Expert_MagicNumber            = 791023;
bool         Expert_EveryTick              = false;
input bool   SenderOrder                   = false;
input bool   LogsStatus                    = false;
input ENUM_APPLIED_PRICE AppliedPrice      = PRICE_CLOSE;
input double Lot                           = 0.02; // Lots to trade
input int    EMA1                          = 5;//Linha de base
input int    EMA2                          = 13;//Primeiro Cruzamento
input int    EMA3                          = 50;//Segundo Cruzamento
input int    EMA4                          = 72;//Terceiro Cruzamento
input int    EMA5                          = 200;//Quarto Cruzamento
input int    EMA6                          = 800;//Grande Cruzamento
input int    EMAMain                       = 5;//Linha de base
input int    EMAPrim                       = 13;//Primeiro Cruzamento
input int    EMASec                        = 50;//Segundo Cruzamento
input int    EMA4_1                        = 72;//Terceiro Cruzamento
input int    EMATerc                       = 200;//Quarto Cruzamento
input int    EMAQuat                       = 800;//Grande Cruzamento
//--- inputs for money
input double Inp_Money_FixLot_Percent        =100.0;
input double Inp_Money_FixLot_Lots           =0.02;
//+---------------------------------------------------------------+
input string            Symb0 = "EURUSD";
input  bool            Trade0 = true;
input int                Per0 = 15;
input ENUM_APPLIED_PRICE ApPrice0=PRICE_CLOSE;
input ENUM_MA_METHOD ModeMA   = MODE_EMA;
input int             StLoss0 = 0;//1000
input int           TkProfit0 = 0;//2000
input double            Lots0 = 0.02;
input int           Slippage0 = 30;
//+---------------------------------------------------------------+
input string            Symb1 = "USDCHF";
input  bool            Trade1 = true;
input int                Per1 = 15;
input ENUM_APPLIED_PRICE ApPrice1=PRICE_CLOSE;
input int             StLoss1 = 0;
input int           TkProfit1 = 0;
input double            Lots1 = 0.02;
input int           Slippage1 = 30;
//+---------------------------------------------------------------+
input string            Symb2 = "USDJPY";
input  bool            Trade2 = true;
input int                Per2 = 15;
input ENUM_APPLIED_PRICE ApPrice2=PRICE_CLOSE;
input int             StLoss2 = 0;
input int           TkProfit2 = 0;
input double            Lots2 = 0.02;
input int           Slippage2 = 30;
//+---------------------------------------------------------------+
input string            Symb3 = "USDCAD";
input  bool            Trade3 = true;
input int                Per3 = 15;
input ENUM_APPLIED_PRICE ApPrice3=PRICE_CLOSE;
input int             StLoss3 = 0;
input int           TkProfit3 = 0;
input double            Lots3 = 0.02;
input int           Slippage3 = 30;
//+---------------------------------------------------------------+
input string            Symb4 = "AUDUSD";
input  bool            Trade4 = true;
input int                Per4 = 15;
input ENUM_APPLIED_PRICE ApPrice4=PRICE_CLOSE;
input int             StLoss4 = 0;
input int           TkProfit4 = 0;
input double            Lots4 = 0.02;
input int           Slippage4 = 30;
//+---------------------------------------------------------------+
input string            Symb5 = "GBPUSD";
input  bool            Trade5 = true;
input int                Per5 = 15;
input ENUM_APPLIED_PRICE ApPrice5=PRICE_CLOSE;
input int             StLoss5 = 0;
input int           TkProfit5 = 0;
input double            Lots5 = 0.02;
input int           Slippage5 = 30;
// handle for our Moving Average indicator
int maMain, maPrimario, maSecundario, maTerciario, maQuaternario;
// dynamic array to hold the values of Moving Average for each bars
double dmaMain[], dmaPrimario[], dmaSecundario[], dmaTerciario[], dmaQuaternario[];
//Tendencia of Moving Average
bool tendPrimario, tendSecundario, tendTerciario;

int contaPrimario, contaSecundario, contaTerciario;

//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| IsNewBar() function                                              |
//+------------------------------------------------------------------+
bool IsNewBar(int Number,string symbol,ENUM_TIMEFRAMES timeframe)
  {
//----
   static datetime Told[];
   datetime Tnew[1];
//---- declare variable to store sizes of variables arrays
   static int Size_=0;

//---- change size of variables arrays
   if(Number+1>Size_)
     {
      uint size=Number+1;
      //----
      if(ArrayResize(Told,size)==-1)
        {
         string word="";
         StringConcatenate(word,"IsNewBar( ",Number,
                           " ): Error!!! Failed to change sizes of arrays of variables!!!");
         Print(word);
         //----          
         int error=GetLastError();
         ResetLastError();
         if(error>4000)
           {
            StringConcatenate(word,"IsNewBar( ",Number," ): Error code ",error);
            Print(word);
           }
         //----                                                                                                                                                                                                  
         Size_=-2;
         return(false);
        }
     }

   CopyTime(symbol,timeframe,0,1,Tnew);
   if(Tnew[0]!=Told[Number])
     {
      Told[Number]=Tnew[0];
      return(true);
     }
//----
   return(false);
  }

//+------------------------------------------------------------------+
//| Custom TradeSignalCounter() function                             |
//+------------------------------------------------------------------+
bool TradeSignalCounter
(
 int Number,
 string Symbol_,
 bool Trade,
 int period,
 ENUM_APPLIED_PRICE ApPrice,
 bool &UpSignal[],
 bool &DnSignal[],
 bool &UpStop[],
 bool &DnStop[]
 )

  {
   //Signal of Moving Average
   bool sigPrimario, sigSecundario, sigTerciario, sigQuaternario;
   //String para logs
   string word="";
   //---- check if trade is prohibited
   if(!Trade)return(true);
   StringConcatenate(word,"L1: Trade:",Trade," return ",!Trade);
   if(LogsStatus==true) Print(word);

//---- declare variable to store final size of variables arrays
   //static int Size_=0;

//---- declare array to store handles of indicators as static variable
   //static int Handle[];
   if(IsNewBar(Number,Symbol_,0))
   {
      //--- fill the structure with parameters of the indicator
      maMain    =iMA(_Symbol,Period(),EMAMain,0,ModeMA,ApPrice);
      CopyBuffer(maMain,0,0,5,dmaMain);
      maPrimario     =iMA(_Symbol,Period(),EMAPrim,0,ModeMA,ApPrice);
      CopyBuffer(maPrimario,0,0,5,dmaPrimario);
      maSecundario   =iMA(_Symbol,Period(),EMASec,0,ModeMA,ApPrice);
      CopyBuffer(maSecundario,0,0,5,dmaSecundario);
      maTerciario    =iMA(_Symbol,Period(),EMATerc,0,ModeMA,ApPrice);
      CopyBuffer(maTerciario,0,0,5,dmaTerciario);
      maQuaternario  =iMA(_Symbol,Period(),EMAQuat,0,ModeMA,ApPrice);
      CopyBuffer(maQuaternario,0,0,5,dmaQuaternario);
      //Validações para entrada
      //Se o sinal rapido(Primario) for maior que o lento(Segundo) então Sinal de compra.
      //Se o sinal rapido(Primario) for menor que o lento(Segundo) então Sinal de venda.
      if(dmaMain[4] > dmaPrimario[4]) sigPrimario  = true; else sigPrimario = false;
      if(dmaPrimario[4] > dmaSecundario[4]) sigSecundario = true; else sigSecundario = false;
      if(dmaSecundario[4] > dmaTerciario[4]) sigTerciario = true; else sigTerciario = false;
      if(dmaTerciario[4] > dmaQuaternario[4]) sigQuaternario = true; else sigQuaternario = false;
      
      //Verificação para entradas compradas;
      //Se o Sinal primario for true, indica que pode estar ocorrendo uma iniciação de tendencia.
      if(sigPrimario == true) {
         UpSignal[Number] = true;
         tendPrimario = true;
      } 
      //Aqui também pode ser uma comparação para saida em cada de entrada vendida
      if(sigPrimario == sigSecundario) {
         UpSignal[Number] = true;
         tendSecundario = true;
      } 
      if(sigSecundario == sigTerciario) {
         UpSignal[Number] = true;
         tendTerciario = true;
      }
      if(sigTerciario == sigQuaternario) {
         UpSignal[Number] = true;
         tendTerciario = true; 
      }
      
      //Validações para entradas vendidas
      if(!sigPrimario == true) {
         DnSignal[Number] = true;
         tendPrimario = true;
      } 
      //Aqui também pode ser uma comparação para saida em cada de entrada comprada
      if(!sigPrimario == !sigSecundario) {
         DnSignal[Number] = true;
         tendSecundario = true;
      }
      if(!sigSecundario == !sigTerciario) {
         DnSignal[Number] = true;
         tendTerciario = true;
      }
      if(!sigTerciario == !sigQuaternario) {
         DnSignal[Number] = true;
         tendTerciario = true; 
      }
      
      if (sigPrimario == true) contaPrimario++;
      if (tendPrimario == true) contaSecundario++;
      if (tendSecundario == true) contaTerciario++;
      Print("Entrada - Primaria: ", contaPrimario, ", Secundaria: ", contaSecundario, ", Terciaria: ", contaTerciario);

   }  
      //Print("IMAM: ", dmaPrincipal[4]);
      //Print("IMAP: ", dmaPrimaria[4]);
      //Print("IMAS: ", dmaSecundaria[4]);
      //Print("IMAT: ", dmaTerciaria[4]);
      //Print("IMAQ: ", dmaQuaternaria[4]);
////Signal of Moving Average
//bool sigMain, sigPrimario, sigSecundario, sigTerciario, sigQuaternario;
//Tendencia of Moving Average
//bool tendMain, tendPrimario, tendSecundario, tendTerciario;
      
      //A Principio o valor de retorno é no registrador de numero 4.
      //Mas esse valor é conforme o fechamento do valor anterior do Periodo.
      //Print("IMA4-Igual linha: ", dmaPrincipal[4]);

   return(true);
  }
  
//+------------------------------------------------------------------+
//| Custom TradePerformer() function                                 |
//+------------------------------------------------------------------+
bool TradePerformer(int    Number,
                    string Symbol_,
                    bool   Trade,
                    int    StLoss,
                    int    TkProfit,
                    double Lots,
                    int    Slippage,
                    bool  &UpSignal[],
                    bool  &DnSignal[],
                    bool  &UpStop[],
                    bool  &DnStop[])
  {
//---- check if trade is prohibited
   if(!Trade)return(true);

//---- close opened positions 
   if(UpStop[Number])BuyPositionClose(Symbol_,Slippage);
   if(DnStop[Number])SellPositionClose(Symbol_,Slippage);

//---- open new positions
   if(UpSignal[Number])
      if(BuyPositionOpen(Symbol_,Slippage,Lots,StLoss,TkProfit))
         UpSignal[Number]=false; // this trade signal will be no more on this bar!
//----  
   if(DnSignal[Number])
      if(SellPositionOpen(Symbol_,Slippage,Lots,StLoss,TkProfit))
         DnSignal[Number]=false; // this trade signal will be no more on this bar!
//----
   return(true);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- 
   contaPrimario = 0;
   contaSecundario = 0;
   contaTerciario = 0;
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(-1);
     }
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
   trailing.
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

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----

//----   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---- declare variables arrays for trade signals  
//---- Deve possuir um registrador a mais que os sinais a serem computados.
   static bool UpSignal[6],DnSignal[6],UpStop[6],DnStop[6];

//---- get trade signals
   TradeSignalCounter(0,Symb0,Trade0,Per0,ApPrice0,UpSignal,DnSignal,UpStop,DnStop);
   //TradeSignalCounter(1,Symb1,Trade1,Per1,ApPrice1,UpSignal,DnSignal,UpStop,DnStop);
   //TradeSignalCounter(2,Symb2,Trade2,Per2,ApPrice2,UpSignal,DnSignal,UpStop,DnStop);
   //TradeSignalCounter(3,Symb3,Trade3,Per3,ApPrice3,UpSignal,DnSignal,UpStop,DnStop);
   //TradeSignalCounter(4,Symb4,Trade4,Per4,ApPrice4,UpSignal,DnSignal,UpStop,DnStop);
   //TradeSignalCounter(5,Symb5,Trade5,Per5,ApPrice5,UpSignal,DnSignal,UpStop,DnStop);

//---- perform trade operations
   TradePerformer(0,Symb0,Trade0,StLoss0,TkProfit0,Lots0,Slippage0,UpSignal,DnSignal,UpStop,DnStop);
   //TradePerformer(1,Symb1,Trade1,StLoss1,TkProfit1,Lots1,Slippage1,UpSignal,DnSignal,UpStop,DnStop);
   //TradePerformer(2,Symb2,Trade2,StLoss2,TkProfit2,Lots2,Slippage2,UpSignal,DnSignal,UpStop,DnStop);
   //TradePerformer(3,Symb3,Trade3,StLoss3,TkProfit3,Lots3,Slippage3,UpSignal,DnSignal,UpStop,DnStop);
   //TradePerformer(4,Symb4,Trade4,StLoss4,TkProfit4,Lots4,Slippage4,UpSignal,DnSignal,UpStop,DnStop);
   //TradePerformer(5,Symb5,Trade5,StLoss5,TkProfit5,Lots5,Slippage5,UpSignal,DnSignal,UpStop,DnStop);
//----   
  }


//+------------------------------------------------------------------+
//| Open buy position.                                               |
//| INPUT:  symbol    -symbol for fish,                              |
//|         deviation -deviation for price close.                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool BuyPositionOpen(const string symbol,
                     ulong deviation,
                     double volume,
                     int StopLoss,
                     int Takeprofit)
  {
//---- declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;

//---- check if there is opened position by exposure for deal
   if(PositionSelect(symbol))return(false);

   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   int stoplevel=int(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);

//---- determine distance to Stop Loss (in price chart units)
   if(StopLoss<stoplevel && StopLoss>0)StopLoss=stoplevel;
   double dStopLoss=StopLoss*point;

//---- determine distance to Take Profit (in price chart units)
   if(Takeprofit<stoplevel && Takeprofit>0)Takeprofit=stoplevel;
   double dTakeprofit=Takeprofit*point;

//---- initializing MqlTradeRequest structure to open a BUY position
   request.type   = ORDER_TYPE_BUY;
   request.price  = SymbolInfoDouble(symbol, SYMBOL_ASK);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
//----
   if(StopLoss   != 0) request.sl = NormalizeDouble(request.price - dStopLoss,   digit); else request.sl = 0.0;
   if(Takeprofit != 0) request.tp = NormalizeDouble(request.price + dTakeprofit, digit); else request.tp = 0.0;
//----
   request.deviation=(deviation==ULONG_MAX) ? deviation : deviation;
   request.type_filling=ORDER_FILLING_AON;
//----
   string word="";
   StringConcatenate(word,
                     "<<< ============ BuyPositionOpen():   Open Buy position at ",
                     symbol," ============ >>>");
   Print(word);

//--- open the BUY position and check the result of the trade request
//Colocar validação para enviar ou não a ordem para o broker.
   if(!OrderSend(request,result) || result.deal==0|| SenderOrder == true)
     {
      Print(ResultRetcodeDescription(result.retcode));
      return(false);
     }
//----
   return(true);
  }

//+------------------------------------------------------------------+
//| Open sell position.                                              |
//| INPUT:  symbol    -symbol for fish,                              |
//|         deviation -deviation for price close.                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool SellPositionOpen(const string symbol,
                      ulong deviation,
                      double volume,
                      int StopLoss,
                      int Takeprofit)
  {
//---- declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;

//---- check if there is opened position by exposure for deal
   if(PositionSelect(symbol))return(false);

   int digit=int(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   int stoplevel=int(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
   double point = SymbolInfoDouble(symbol,SYMBOL_POINT);

//---- determine distance to Stop Loss (in price chart units)
   if(StopLoss<stoplevel && StopLoss>0)StopLoss=stoplevel;
   double dStopLoss=StopLoss*point;

//---- determine distance to Take Profit (in price chart units)
   if(Takeprofit<stoplevel && Takeprofit>0)Takeprofit=stoplevel;
   double dTakeprofit=Takeprofit*point;

//---- initializing the MqlTradeRequest structure to open SELL position
   request.type   = ORDER_TYPE_SELL;
   request.price  = SymbolInfoDouble(symbol, SYMBOL_BID);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
//----
   if(StopLoss   != 0) request.sl = NormalizeDouble(request.price + dStopLoss,   digit); else request.sl = 0.0;
   if(Takeprofit != 0) request.tp = NormalizeDouble(request.price - dTakeprofit, digit); else request.tp = 0.0;
//----
   request.deviation=(deviation==ULONG_MAX) ? deviation : deviation;
   request.type_filling=ORDER_FILLING_AON;

//----
   string word="";
   StringConcatenate(word,
                     "<<< ============ SellPositionOpen():   Open Sell position at ",
                     symbol," ============ >>>");
   Print(word);

//---- open the SELL position and check the result of the trade request
   if(!OrderSend(request,result) || result.deal==0||SenderOrder == true)
     {
      Print(ResultRetcodeDescription(result.retcode));
      return(false);
     }
//----
   return(true);
  }

//+------------------------------------------------------------------+
//| Close specified opened buy position.                             |
//| INPUT:  symbol    -symbol for fish,                              |
//|         deviation -deviation for price close.                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool BuyPositionClose(const string symbol,ulong deviation)
  {
//---- declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;

//---- check if there is a BUY position
   if(PositionSelect(symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_BUY) return(false);
     }
   else  return(false);

//---- initializing the MqlTradeRequest structure to close the BUY position
   request.type   = ORDER_TYPE_SELL;
   request.price  = SymbolInfoDouble(symbol, SYMBOL_BID);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = PositionGetDouble(POSITION_VOLUME);
   request.sl = 0.0;
   request.tp = 0.0;
   request.deviation=(deviation==ULONG_MAX) ? deviation : deviation;
   request.type_filling=ORDER_FILLING_AON;
//----
   string word="";
   StringConcatenate(word,
                     "<<< ============ BuyPositionClose():   Close Buy position at ",
                     symbol," ============ >>>");
   Print(word);

//---- send order to close position to trade server
   if(!OrderSend(request,result)||(SenderOrder == true))
     {
      Print(ResultRetcodeDescription(result.retcode));
      return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Close specified sell opened position.                            |
//| INPUT:  symbol    -symbol for fish,                              |
//|         deviation -deviation for price close.                    |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool SellPositionClose(const string symbol,ulong deviation)
  {
//---- declare structures of trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult result;

//---- check if there is a BUY position
   if(PositionSelect(symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_SELL)return(false);
     }
   else return(false);

//---- initializing the MqlTradeRequest structure to close the SELL position
   request.type   = ORDER_TYPE_BUY;
   request.price  = SymbolInfoDouble(symbol, SYMBOL_ASK);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = PositionGetDouble(POSITION_VOLUME);
   request.sl = 0.0;
   request.tp = 0.0;
   request.deviation=(deviation==ULONG_MAX) ? deviation : deviation;
   request.type_filling=ORDER_FILLING_AON;
//----
   string word="";
   StringConcatenate(word,
                     "<<< ============ SellPositionClose():   Close Sell position at ",
                     symbol," ============ >>>");
   Print(word);

//---- send order to close position to trade server
   if(!OrderSend(request,result)||(SenderOrder == true))
     {
      Print(ResultRetcodeDescription(result.retcode));
      return(false);
     }
//----
   return(true);
  }


//+------------------------------------------------------------------+
//| Get the retcode value as string.                                 |
//| INPUT:  no.                                                      |
//| OUTPUT: the retcode value as string.                             |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
string ResultRetcodeDescription(int retcode)
  {
   string str;
//----
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE:
         str="Requote";
         break;
      case TRADE_RETCODE_REJECT:
         str="Request rejected";
         break;
      case TRADE_RETCODE_CANCEL:
         str="Request cancelled by trader";
         break;
      case TRADE_RETCODE_PLACED:
         str="Order placed";
         break;
      case TRADE_RETCODE_DONE:
         str="Request done";
         break;
      case TRADE_RETCODE_DONE_PARTIAL:
         str="Request done partially";
         break;
      case TRADE_RETCODE_ERROR:
         str="Common error";
         break;
      case TRADE_RETCODE_TIMEOUT:
         str="Request cancelled by timeout";
         break;
      case TRADE_RETCODE_INVALID:
         str="Invalid request";
         break;
      case TRADE_RETCODE_INVALID_VOLUME:
         str="Invalid volume in request";
         break;
      case TRADE_RETCODE_INVALID_PRICE:
         str="Invalid price in request";
         break;
      case TRADE_RETCODE_INVALID_STOPS:
         str="Invalid stop(s) request";
         break;
      case TRADE_RETCODE_TRADE_DISABLED:
         str="Trade is disabled";
         break;
      case TRADE_RETCODE_MARKET_CLOSED:
         str="Market is closed";
         break;
      case TRADE_RETCODE_NO_MONEY:
         str="No enough money";
         break;
      case TRADE_RETCODE_PRICE_CHANGED:
         str="Price changed";
         break;
      case TRADE_RETCODE_PRICE_OFF:
         str="No quotes for query processing";
         break;
      case TRADE_RETCODE_INVALID_EXPIRATION:
         str="Invalid expiration time in request";
         break;
      case TRADE_RETCODE_ORDER_CHANGED:
         str="Order state changed";
         break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS:
         str="Too frequent requests";
         break;
      default:
         str="Unknown result";
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
