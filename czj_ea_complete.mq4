//+------------------------------------------------------------------+
//|                                              czj_ea_complete.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
extern int stopLoss=20;
extern int takeProfit=50;
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
   //---this is a test!
   //---
   
   string state;//用于屏幕显示状态
   int marketInOrOut=calMarketIn();//---进出场状态
   switch(marketInOrOut)
      {
         case 1:
            state="Buy";
            iCloseOrders("Sell");
            Print(LotsOpt());
            iOpenOrders("Buy",LotsOpt(),stopLoss,takeProfit);
         case -1:
            state="Sell";
            iCloseOrders("Buy");
            Print(LotsOpt());
            iOpenOrders("Sell",LotsOpt(),stopLoss,takeProfit); 
         case 0:
            state="hold";
            iMoveStopLoss(stopLoss);
      }  
   iSetLable("LableName","当前状态:"+state,10,40,10,"Verdana",Yellow);  
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|函数：新单开仓；参数说明：myType 开仓类型：Buy 买入订单，Sell 卖出订单； myLots 开仓量  myLossStop 止损点数 myTakeProfit 止盈点数                                                             |
//+------------------------------------------------------------------+

void iOpenOrders(string myType,double myLots,int myLossStop,int myTakeProfit)
  {
   int mySPREAD=MarketInfo(Symbol(),MODE_SPREAD);//获取市场滑点
   double pointADJ=calPoint();
   double BuyLossStop=Ask-myLossStop*pointADJ;
   double SellLossStop=Bid+myLossStop*pointADJ;
   double BuyTakeProfit=Ask+myTakeProfit*pointADJ;
   double SellTakeProfit=Bid-myTakeProfit*pointADJ;
   
 
   if(myLossStop<=0)
     {
      BuyLossStop=0;
      SellLossStop=0;
     }
   if(myTakeProfit<=0)
     {
      BuyTakeProfit=0;
      SellTakeProfit=0;
     }

   if(myType=="Buy")
      OrderSend(Symbol(),OP_BUY,myLots,Ask,mySPREAD,BuyLossStop,BuyTakeProfit);
   if(myType=="Sell")
      OrderSend(Symbol(),OP_SELL,myLots,Bid,mySPREAD,SellLossStop,SellTakeProfit);

  }
//+------------------------------------------------------------------+
//|函数：持仓单平仓  Buy:多头订单；Sell:空头订单；Profit:盈利订单；Loss:亏损订单；All:全部订单                                                             |
//+------------------------------------------------------------------+
void iCloseOrders(string myType)
  {
      int CO_cnt;   
      if(myType=="Loss")
       {
         for(CO_cnt=OrdersTotal();CO_cnt>=0;CO_cnt--)
          {
            if(OrderSelect(CO_cnt,SELECT_BY_POS)==false) continue;
            else if(OrderProfit()<0) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
          }
       }
       
       if(myType=="Profit")
       {
         for(CO_cnt=OrdersTotal();CO_cnt>=0;CO_cnt--)
          {
            if(OrderSelect(CO_cnt,SELECT_BY_POS)==false) continue;
            else if(OrderProfit()>0) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
          }
       }
       
       if(myType=="Buy")
       {
         for(CO_cnt=OrdersTotal();CO_cnt>=0;CO_cnt--)
          {
            if(OrderSelect(CO_cnt,SELECT_BY_POS)==false) continue;
            else if(OrderType()==OP_BUY) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
          }
       }
       
       if(myType=="Sell")
       {
         for(CO_cnt=OrdersTotal();CO_cnt>=0;CO_cnt--)
          {
            if(OrderSelect(CO_cnt,SELECT_BY_POS)==false) continue;
            else if(OrderType()==OP_SELL) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
          }
       }
       
       if(myType=="All")
       {
         for(CO_cnt=OrdersTotal();CO_cnt>=0;CO_cnt--)
          {
            if(OrderSelect(CO_cnt,SELECT_BY_POS)==false) continue;
            else OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),0);
          }
       }
       
  }
//+------------------------------------------------------------------+
//| 函数：追踪止损  myStopLoss 预设止损点数; 遍历所有持仓订单，当持仓订单获利达到止损点数时候，修改止损价位                                                 |
//+------------------------------------------------------------------+
void iMoveStopLoss(int myStopLoss)
  {
   int MSLCnt;//订单计数器
   double pointADJ=calPoint();
   if(OrderSelect(OrdersTotal()-1,SELECT_BY_POS)==false) 
      return;
   if(OrdersTotal()>0)
     {
      for(MSLCnt=OrdersTotal();MSLCnt>=0;MSLCnt--)
        {
         if(OrderSelect(MSLCnt,SELECT_BY_POS)==false) continue;
         else
           {
            if(OrderProfit()>0 && OrderType()==OP_BUY && ((Close[0]-OrderStopLoss())>((2*myStopLoss)*pointADJ)))
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-pointADJ*myStopLoss,OrderTakeProfit(),0);
              }
            if(OrderProfit()>0 && OrderType()==OP_SELL && ((OrderStopLoss()-Close[0])>((2*myStopLoss)*pointADJ)))

              {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask-pointADJ*myStopLoss,OrderTakeProfit(),0);
              }
           }
        }
     }

  }

//+------------------------------------------------------------------+
//|             定时交易                                                     |
//+------------------------------------------------------------------+
bool EA_Valid=false;//需要在程序开始定义

bool iTimeControl(int myStartHour,int myStartMinute,int myStopHour,int myStopMinute)
 {
   if(Hour()==0 && Minute()==0)
      EA_Valid=false;
   if(Hour()==myStopHour && Minute()== myStopMinute+1) 
      EA_Valid=false;
   if(Hour()==myStartHour && Minute()==myStartMinute)
      EA_Valid=true;
   return(EA_Valid);      
 }
 
 //+------------------------------------------------------------------+
 //|     屏幕上显示文字                                                             |
 //+------------------------------------------------------------------+
 void iSetLable(string LableName,string LableDoc,int LableX,int LableY,int DocSize,string DocStyle,color DocColor)
  {
   ObjectCreate(LableName,OBJ_LABEL,0,0,0);
   ObjectSetText(LableName,LableDoc,DocSize,DocStyle,DocColor);
   ObjectSet(LableName,OBJPROP_XDISTANCE,LableX);
   ObjectSet(LableName,OBJPROP_YDISTANCE,LableY);
  }
  

 //+------------------------------------------------------------------+
 //|     出入场条件判断函数                                                             |
 //+------------------------------------------------------------------+
int calMarketIn()
  {
   bool blBuy=False;
   bool blSell=False;
   
// 进行blBuy和blSell的逻辑计算,后续基于该模块进行修改                                       |
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
//|    统一不同币种最小报价单位                                                              |
//+------------------------------------------------------------------+
double calPoint()
 {
   double Poin;
   if(Point==0.00001) Poin=0.0001;
   else if(Point==0.001) Poin=0.01;
   else Poin=Point;
   return(Poin);
 }

//+------------------------------------------------------------------+
//|        计算开仓量，开仓调用，资金控制                                                          |
//+------------------------------------------------------------------+
double LotsOpt()
 {
   double per=0.05;
   double myLots=NormalizeDouble(AccountEquity()/MarketInfo(Symbol(),MODE_MARGINREQUIRED)*per,2);
   return(myLots);
 }