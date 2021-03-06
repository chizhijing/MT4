//+------------------------------------------------------------------+
//|                                                      czj_ea6.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double Poin;//平台最小报价
extern double TakeProfit= 50;   //止赢点数
extern double StopLoss = 20;    //止损点数
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

//持仓状态判断
   int orderNum=OrdersTotal();
   int marketInState=calMarketIn();

//空仓情况
   if(orderNum==0)
     {
      //多-空头入场条件判断,不满足入场条件直接返回
      if(marketInState==-1)//空头入场
        {
         OrderSend(Symbol(),OP_SELL,1,Bid,5,Bid+StopLoss*Poin,Bid-TakeProfit*Poin,"czjTestOrder",201610101,0,Green);
        }
      if(marketInState==1)//多头入场
        {
         OrderSend(Symbol(),OP_BUY,1,Ask,5,Ask-StopLoss*Poin,Ask+TakeProfit*Poin,"czjTestOrder",201610102,0,Yellow);
        }
      if(marketInState==0)//不入场
        {
         return;
        }

     }

//持仓情况
   if(orderNum>0)
     {
      //多单持仓情况，满足条件出场
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==TRUE && OrderType()==OP_BUY && marketInState==-1)
         OrderClose(OrderTicket(),OrderLots(),Bid,5,Red);

      //空单持仓情况，满足条件出场
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES)==TRUE && OrderType()==OP_SELL && marketInState==1)
         OrderClose(OrderTicket(),OrderLots(),Ask,5,Blue);
     }

  }
//+------------------------------------------------------------------+

//出入场条件判断函数
int calMarketIn()
  {
   bool blBuy=False;
   bool blSell=False;
//+------------------------------------------------------------------+
//| 进行blBuy和blSell的逻辑计算,后续基于该模块进行修改                                       |
//+------------------------------------------------------------------+
   int mypoint=15;
   blBuy=((iClose(NULL,0,0)-iOpen(NULL,0,0))/Point>mypoint) &&((iClose(NULL,0,1)-iOpen(NULL,0,1))/Point>mypoint)&&((iClose(NULL,0,2)-iOpen(NULL,0,2))/Point>mypoint);
   blSell=((iClose(NULL,0,0)-iOpen(NULL,0,0))/Point<-mypoint) &&((iClose(NULL,0,1)-iOpen(NULL,0,1))/Point<-mypoint)&&((iClose(NULL,0,2)-iOpen(NULL,0,2))/Point<-mypoint);    
   if(blBuy)
      return(1);//buy
   if(blSell)
      return(-1);//sell
   return(0);//hold

  }

//+------------------------------------------------------------------+
