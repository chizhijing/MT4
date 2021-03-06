//+------------------------------------------------------------------+
//|                                                      czj_ea3.mq4 |
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
   //统一不同币种最小报价单位
   if(Point==0.00001) Poin=0.0001;
   else if(Point==0.001) Poin=0.01;
   else Poin=Point;
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
   //计算上线和下线
   double upLine=0;
   double downLine=1000000;
   for(int i=1;i<N;i++)
   {
      upLine=MathMax(upLine,iHigh(NULL,0,i));
      downLine=MathMin(downLine,iLow(NULL,0,i));
   }

   //股价高于上线,买入,平掉卖单
   if(iClose(NULL,0,0)>upLine)
   {
      MessageBox("买入");
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_SELL)
         OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
      if(OrdersTotal()==0)
         OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-StopLoss*Poin,Ask+TakeProfit*Poin,"TFO_1",0,Green);  
   }
   
   //股价低于下线,卖出，平掉买单
   if(iClose(NULL,0,0)<downLine)
   {
      MessageBox("卖出");
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_BUY)
         OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);

      if(OrdersTotal()==0)
         OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+StopLoss*Poin,Bid-TakeProfit*Poin,"TFO_1",0,Red);
   }
   
   
  }
//+------------------------------------------------------------------+
