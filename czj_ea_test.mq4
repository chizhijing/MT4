//+------------------------------------------------------------------+
//|                                                  czj_ea_test.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //Print(MarketInfo(Symbol(),MODE_LOW)+MarketInfo(Symbol(),MODE_HIGH));
   //Print(AccountEquity()/MarketInfo(Symbol(),MODE_MARGINREQUIRED));
   //---Print(MarketInfo(Symbol(),MODE_MARGINREQUIRED));
   /*
   Print("货币存款单位："+AccountCurrency());
   Print("当前货币对的标准手数:"+MarketInfo(Symbol(),MODE_LOTSIZE));
   Print("交易杠杆值:"+AccountLeverage());
   Print("汇率-小数点总数："+MarketInfo(Symbol(),MODE_DIGITS));
   Print("点数-最小价格改变："+MarketInfo(Symbol(),MODE_POINT));
   Print("同样是获得当前货币对的点数"+MarketInfo(Symbol(),MODE_TICKSIZE));
   Print("货币存款中的价格点："+MarketInfo(Symbol(),MODE_TICKVALUE));
   Print("每个标准手的保证金："+MarketInfo(Symbol(),MODE_MARGINREQUIRED));
   */
   Print("账户余额："+AccountBalance());
   Print("账户净值："+AccountEquity());
  }
//+------------------------------------------------------------------+
