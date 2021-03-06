//+------------------------------------------------------------------+
//|                                                      czj_ea5.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#define MAGICMA 201610101022
extern int whichmethod = 1;   //1~4 种下单方式  1 仅开仓, 2 有止损无止赢, 3 有止赢无止损, 4 有止赢也有止损
extern double TakeProfit = 100;   //止赢点数
extern   double StopLoss = 20;    //止损点数
extern double MaximumRisk     = 0.3; //资金控制,控制下单量
extern double TrailingStop =25;     //跟踪止赢点数设置
extern   int maxOpen = 3;   //最多开仓次数限制
extern   int maxLots = 5;   //最多单仓持仓量限制
extern int bb = 0;       //非零就允许跟踪止赢
extern double MATrendPeriod=26;//使用26均线 开仓条件参数  本例子

int i, p2, xxx,p1, res;
double Lots;
datetime lasttime;       //时间控制, 仅当一个时间周期完成才检查条件
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Lots = 1;
   lasttime = NULL;
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
   CheckForOpen();    //开仓 平仓 条件检查 和操作
   if (bb>0)   CTP();   //跟踪止赢

  }
//+------------------------------------------------------------------+
//+------下面是各子程序--------------------------------------------+
double LotsOptimized()   //确定下单量，开仓调用 资金控制
   {
   double lot=Lots;
   int   orders=HistoryTotal();   // history orders total
   int   losses=0;             // number of losses orders without a break
   //MarketInfo(Symbol(),MODE_MINLOT);     相关信息
   //MarketInfo(Symbol(),MODE_MAXLOT);
   //MarketInfo(Symbol(),MODE_LOTSTEP);
   lot=NormalizeDouble(MaximumRisk * AccountBalance()/AccountLeverage(),1);     //开仓量计算
   if(lot<0.1) lot=0.1;
   if(lot>maxLots) lot=maxLots;
   return(lot);
   }
  
//平仓持有的买单
void CloseBuy()
   {
   if (OrdersTotal( ) > 0 )   
   {
     for(i=OrdersTotal()-1;i>=0;i--)
     {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        if(OrderType()==OP_BUY)
     {
       OrderClose(OrderTicket(),OrderLots(),Bid,3,White);
       Sleep(5000);
     }
     }
   }
}
//平仓持有的卖单
void CloseSell()
{
if (OrdersTotal( ) > 0 )   
{
  for(i=OrdersTotal()-1;i>=0;i--)
  {
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
  if(OrderType()==OP_SELL)
    {
    OrderClose(OrderTicket(),OrderLots(),Ask,3,White);
    Sleep(5000);
    }
  }
}
}
//判断是否买或卖或平仓
int buyorsell()   //在这个函数计算设置你的交易信号  这里使用MACD 和MA 做例子
   {
     double MacdCurrent, MacdPrevious, SignalCurrent;
     double SignalPrevious, MaCurrent, MaPrevious;
     MacdCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
     MacdPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
     SignalCurrent=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
     SignalPrevious=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
     MaCurrent=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,0);
     MaPrevious=iMA(NULL,0,MATrendPeriod,0,MODE_EMA,PRICE_CLOSE,1);
   if(MacdCurrent<0 && MacdCurrent>SignalCurrent && MacdPrevious<SignalPrevious
       && MaCurrent>MaPrevious)
     return (1); // 买 Ma在上升，Macd在0线上，并且两线上交叉
   if(MacdCurrent>0 && MacdCurrent<SignalCurrent && MacdPrevious>SignalPrevious
       && MaCurrent<MaPrevious)
     return (-1); // 卖
   return (0); //不交易
   }
   
int nowbuyorsell = 0;

void CheckForOpen()
   {
   if (Time[0] == lasttime ) return; //每时间周期检查一次  时间控制
   lasttime = Time[0];
   nowbuyorsell = buyorsell(); //获取买卖信号
   
   if (nowbuyorsell == 1) //买　先结束已卖的
     CloseSell();
   if (nowbuyorsell == -1) //卖　先结束已买的
     CloseBuy();
   if (TimeDayOfWeek(CurTime()) == 1)
     {
     if (TimeHour(CurTime()) < 3 ) return; //周一早8点前不做 具体决定于你的时区和服务器的时区  时间控制
     }
   if (TimeDayOfWeek(CurTime()) == 5)
     {
     if (TimeHour(CurTime()) > 19 ) return; //周五晚11点后不做
     }
   
   if (OrdersTotal( ) >= maxOpen) return ;   
   //如果已持有开仓次数达到最大，不做
   if (nowbuyorsell==0) return;   //不交易
   TradeOK();   //去下单交易
   }
   
void TradeOK()   //去下单交易
{
int error ;
if (nowbuyorsell == 1) //买
  {
    switch (whichmethod)
    {
    case 1:   res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);break;
    case 2:   res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask-StopLoss*Point,0,"",MAGICMA,0,Blue); break;
    case 3:   res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,Ask+TakeProfit*Point,"",MAGICMA,0,Blue);break;
    case 4:   res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,Ask-StopLoss*Point,Ask+TakeProfit*Point,"",MAGICMA,0,Blue);break;
    default : res=OrderSend(Symbol(),OP_BUY,LotsOptimized(),Ask,3,0,0,"",MAGICMA,0,Blue);break;
    }
    if (res <=0)
    {
    error=GetLastError();
    if(error==134)Print("Received 134 Error after OrderSend() !! ");         // not enough money
    if(error==135) RefreshRates();   // prices have changed
    }
    Sleep(5000);
    return ;   
  }
if (nowbuyorsell == -1) //卖
  {
    switch (whichmethod)
    {
    case 1:   res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red); break;
    case 2:   res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid+StopLoss*Point,0,"",MAGICMA,0,Red); break;
    case 3:   res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,Bid-TakeProfit*Point,"",MAGICMA,0,Red); break;
    case 4:   res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,Bid+StopLoss*Point,Bid-TakeProfit*Point,"",MAGICMA,0,Red); break;
    default : res=OrderSend(Symbol(),OP_SELL,LotsOptimized(),Bid,3,0,0,"",MAGICMA,0,Red); break;
    }
    if (res <=0)
    {
    error=GetLastError();
    if(error==134) Print("Received 134 Error after OrderSend() !! ");         // not enough money
    if(error==135) RefreshRates();   // prices have changed
    }
    Sleep(5000);
    return ;   
  }
}

void CTP()   //跟踪止赢
{
bool bs = false;
for (int i = 0; i < OrdersTotal(); i++)
{
  if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)     break;
  if (OrderType() == OP_BUY)
  {
    if ((Bid - OrderOpenPrice()) > (TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)))    //开仓价格 当前止损和当前价格比较判断是否要修改跟踪止赢设置
    {
    if (OrderStopLoss() < Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
    {
      bs = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(),0, Green);
    }
    }
  }
  else if (OrderType() == OP_SELL)
  {
    if ((OrderOpenPrice() - Ask) > (TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)))  //开仓价格 当前止损和当前价格比较判断是否要修改跟踪止赢设置

    {
    if ((OrderStopLoss()) > (Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)))
    {     
      bs = OrderModify(OrderTicket(), OrderOpenPrice(),
        Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(),0, Tan);
}
    }
  }
}
}