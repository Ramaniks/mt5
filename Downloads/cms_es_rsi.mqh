//+------------------------------------------------------------------+
//|                                                   CMS_ES_RSI.mqh |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//|                                              Revision 2011.03.25 |
//+------------------------------------------------------------------+
#include "CandlePatterns.mqh"
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals based on Morning/Evening Stars                     |
//| confirmed by RSI                                                 |
//| Type=Signal                                                      |
//| Name=CMS_ES_RSI                                                  |
//| Class=CMS_ES_RSI                                                 |
//| Page=                                                            |
//| Parameter=PeriodRSI,int,47                                       |
//| Parameter=AppliedRSI,ENUM_APPLIED_PRICE,PRICE_CLOSE              |
//| Parameter=MAPeriod,int,3                                         |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| CMS_ES_RSI Class.                                                |
//| Purpose: Trading signals class, based on                         |
//| the "Morning/Evening Stars"                                      |
//| Japanese Candlestick Patterns                                    |
//| with confirmation by RSI indicator                               |
//| Derived from CCandlePattern class.                               |
//+------------------------------------------------------------------+
class CMS_ES_RSI : public CCandlePattern
  {
protected:
   CiRSI             m_RSI;
   CiMA              m_app_price;
   //--- input parameters
   int               m_periodRSI;
   ENUM_APPLIED_PRICE m_appliedRSI;

public:
                     CMS_ES_RSI();

   void              PeriodRSI(int period)                  { m_periodRSI=period;      }
   void              AppliedRSI(ENUM_APPLIED_PRICE applied) { m_appliedRSI=applied;    }

   //--- methods initialize protected data
   virtual bool      ValidationSettings();
   virtual bool      InitIndicators(CIndicators *indicators);
   //---

   virtual bool      CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckCloseLong(double &price);
   virtual bool      CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckCloseShort(double &price);

protected:
   bool              InitRSI(CIndicators *indicators);
   bool              InitApplied(CIndicators *indicators);
   double            RSI(int ind)  const                    { return(m_RSI.Main(ind)); }
   //---
  };
//+------------------------------------------------------------------+
//| Constructor CMS_ES_RSI.                                          |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CMS_ES_RSI::CMS_ES_RSI()
  {
//--- set default inputs
   m_periodRSI =37;
   m_appliedRSI=PRICE_CLOSE;
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//| INPUT:  no.                                                      |
//| OUTPUT: true-if settings are correct, false otherwise.           |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::ValidationSettings()
  {
   if(!CCandlePattern::ValidationSettings()) return(false);
//--- initial data checks
   if(m_periodRSI<=0)
     {
      printf(__FUNCTION__+": period RSI must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::InitIndicators(CIndicators *indicators)
  {
//--- check
   if(indicators==NULL) return(false);
   if(!CCandlePattern::InitIndicators(indicators)) return(false);
//--- create and initialize RSI indicator
   if(!InitRSI(indicators)) return(false);
//--- create and initialize Price series
   if(!InitApplied(indicators)) return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of RSI indicator.                                 |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::InitRSI(CIndicators *indicators)
  {
//--- add RSI indicator to collection
   if(!indicators.Add(GetPointer(m_RSI)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize RSI indicator
   if(!m_RSI.Create(m_symbol.Name(),m_period,m_periodRSI,m_appliedRSI))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   m_RSI.BufferResize(50);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create Applied Price indicator.                                  |
//| INPUT:  indicators -pointer of indicator collection.             |
//| OUTPUT: true-if successful, false otherwise.                     |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::InitApplied(CIndicators *indicators)
  {
//--- add Price indicator to collection
   if(!indicators.Add(GetPointer(m_app_price)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize Price indicator
   if(!m_app_price.Create(m_symbol.Name(),m_period,1,0,MODE_SMA,m_appliedRSI))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   m_app_price.BufferResize(100);
   m_app_price.FullRelease(true);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position open.                         |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration)
  {
//--- check formation of Morning Star pattern
  if (!CheckCandlestickPattern(CANDLE_PATTERN_MORNING_STAR)) return(false);
//--- check RSI
  if (!(RSI(1)<40))                                          return(false);
//--- ok, use market orders
   price=0.0;
   sl   =0.0;
   tp   =0.0;
//--- set signal to open long position
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for long position close.                        |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::CheckCloseLong(double &price)
  {
//--- check conditions of long position closing
   if (!(((RSI(1)<70) && (RSI(2)>70)) ||
         ((RSI(1)<30) && (RSI(2)>30)))) return(false);
//--- ok, use market orders
   price=0.0;
//--- set signal to close long position
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position open.                        |
//| INPUT:  price      - refernce for price,                         |
//|         sl         - refernce for stop loss,                     |
//|         tp         - refernce for take profit,                   |
//|         expiration - refernce for expiration.                    |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration)
  {
//--- check formation of Evening Star pattern
  if (!CheckCandlestickPattern(CANDLE_PATTERN_EVENING_STAR)) return(false);
//--- check RSI
  if (!(RSI(1)>60))                                          return(false);
//--- ok, use market orders
   price=0.0;
   sl   =0.0;
   tp   =0.0;
//--- set signal to open short position
   return(true);
  }
//+------------------------------------------------------------------+
//| Check conditions for short position close.                       |
//| INPUT:  price - refernce for price.                              |
//| OUTPUT: true-if condition performed, false otherwise.            |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CMS_ES_RSI::CheckCloseShort(double &price)
  {
//--- check conditions of short position closing
   if (!(((RSI(1)>30) && (RSI(2)<30)) ||
         ((RSI(1)>70) && (RSI(2)<70)))) return(false);
//--- ok, use market orders
   price=0.0;
//--- set signal to close short position
   return(true);
  }
//+------------------------------------------------------------------+