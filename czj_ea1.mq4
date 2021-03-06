//+------------------------------------------------------------------+
//|                                                      czj_ea1.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//策略：5日均线上穿20日均线买入，5日均线下穿20日均线卖出，
//止盈50点，止损20点，每手交易0.1手

extern double TakeProfit=50;//止盈点数
extern double StopLoss=20;//止损点数
extern double Lots=0.1;//交易手数
extern double Poin;//平台最小报价
extern int MAPeriodSlow=20;//20日移动平均
extern int MAPeriodFast=5;//5日移动平均

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()//初始化函数：载入EA执行一次
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
void OnDeinit(const int reason)//关闭EA执行一次
  {
//---
 
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()//当每个价格到达时执行一次
  {
//---
   double myMAslow,myMAfast,myMAslow1,myMAfast1;
      int i=0;
      myMAslow=iMA(Symbol(),0,MAPeriodSlow,0,MODE_SMA,PRICE_CLOSE,0);
      myMAfast=iMA(Symbol(),0,MAPeriodFast,0,MODE_SMA,PRICE_CLOSE,0);
      
      myMAslow1=iMA(Symbol(),0,MAPeriodSlow,0,MODE_SMA,PRICE_CLOSE,1);
      myMAfast1=iMA(Symbol(),0,MAPeriodFast,0,MODE_SMA,PRICE_CLOSE,1);
      //MessageBox("Test");
      //上穿买入 平掉卖单
      if(myMAfast>myMAslow && myMAfast1<myMAslow1)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_SELL)
            OrderClose(OrderTicket(),OrderLots(),Ask,3,CLR_NONE);
         if(OrdersTotal()==0)
            OrderSend(Symbol(),OP_BUY,Lots,Ask,3,Ask-StopLoss*Poin,Ask+TakeProfit*Poin,"TFO_1",0,Green);   
      }
      //下穿卖出 平掉买单
      if(myMAfast<myMAslow && myMAfast1>myMAslow1)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_BUY)
            OrderClose(OrderTicket(),OrderLots(),Bid,3,CLR_NONE);
            
         if(OrdersTotal()==0)
            OrderSend(Symbol(),OP_SELL,Lots,Bid,3,Bid+StopLoss*Poin,Bid-TakeProfit*Poin,"TFO_1",0,Red);
               
      }
  }
//+------------------------------------------------------------------+
