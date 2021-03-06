//+------------------------------------------------------------------+
//|                                                      czj_ea4.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double N=20;
extern double TakeProfit=50;//止盈点数
extern double StopLoss=20;//止损点数
extern double Lots=0.1;//交易手数
extern double Poin;//平台最小报价
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
   //int rand1,rand2;
   //rand1=MathRand();
   //rand2=MathRand();
   
   double rand1,rand2;
   rand1=iClose(NULL,0,0);
   rand2=iOpen(NULL,0,0);
   
   if(rand1>rand2*1.05)
   {
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_SELL)
         OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
      if(OrdersTotal()==0)
         OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-StopLoss*Poin,Ask+TakeProfit*Poin,"TFO_1",0,Green); 
   }
   
   if(rand1<rand2*0.95)
   {
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_BUY)
         OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);

      if(OrdersTotal()==0)
         OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+StopLoss*Poin,Bid-TakeProfit*Poin,"TFO_1",0,Red);
   }
   
  }
//+------------------------------------------------------------------+
