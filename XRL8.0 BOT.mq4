//+------------------------------------------------------------------+
//|                                                   XRL8.0 BOT.mq4 |
//|                                   Copyright 2021, Gabriel Ferraz |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Gabriel Ferraz"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


extern int MAGIGMA = 1;
extern int periodo_menor = 8;
extern int periodo_maior = 20;
extern double loteEntrada = 1.00;
extern bool OperarSELL = true;
extern bool OperarBUY = true;
extern bool PararTrade = false;
extern int TakeProfit = 1000;
extern int StopLoss = 500;
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
     checkForOpen(MAGIGMA);
  }
//+------------------------------------------------------------------+

bool sinal_media_moveis(int BUY_SELL)
{
  bool retorno = false;
  double media_menor = iMA(NULL, 0,periodo_menor,0, MODE_SMA,PRICE_CLOSE,1); 
  double media_menor_ant = iMA(NULL, 0,periodo_menor,0, MODE_SMA,PRICE_CLOSE,2);
  double media_maior = iMA(NULL, 0,periodo_maior,0, MODE_SMA,PRICE_CLOSE,1);
  double media_maior_ant = iMA(NULL, 0,periodo_maior,0, MODE_SMA,PRICE_CLOSE,2);
  if( BUY_SELL == OP_SELL)
  {
     if((media_menor_ant > media_maior_ant)&&(media_menor < media_maior))
        retorno = true;
     else
        retorno = false;
  
  }
  else if(BUY_SELL == OP_BUY)
  {
  
  if((media_menor_ant < media_maior_ant)&&(media_menor > media_maior))
        retorno = true;
     else
        retorno = false;
  }
  
  
  return(retorno) ;
}

double total_ordem_aberta(int MAGIGMA_n, int BUY_SELL)
{

    int totalordens = OrdersTotal();
    int contador = 0;
    
    for(int i= 0;  i < totalordens; i++)
    {
       if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==false)
         break;
         
       if((OrderMagicNumber() == MAGIGMA_n) &&
         (OrderType() == BUY_SELL))
         
       contador++ ;
    
     }
     return(contador);
}

void checkForOpen( int MAGIGMA_n)
{
   int res;
   double total_de_ordem_venda = total_ordem_aberta(MAGIGMA_n, OP_SELL);
   double total_de_ordem_compra = total_ordem_aberta(MAGIGMA_n, OP_BUY);
   
   if (PararTrade == true)
   {
      if((total_de_ordem_venda ==0) &&(total_de_ordem_compra ==0))
         return;
   }
   
   if(Volume[0] > 3) return;
   
   if(IsTradeContextBusy()==true)
     return;
     
   RefreshRates();
   
   if(OperarSELL == true)
   {
      if((sinal_media_moveis(OP_SELL)== TRUE)&&(total_de_ordem_venda==0)&&(total_de_ordem_compra==0))
       {
         res=OrderSend(Symbol(),OP_SELL,loteEntrada,Bid,150,Bid + (StopLoss * Point), Bid -(TakeProfit * Point),"",MAGIGMA_n,0,clrRed);
       }
   }
   if(OperarBUY == true)
   {
      if((sinal_media_moveis(OP_BUY)== TRUE)&&(total_de_ordem_compra==0)&&(total_de_ordem_venda==0))
       {
         res=OrderSend(Symbol(),OP_BUY,loteEntrada,Ask,150,Ask - (StopLoss * Point), Ask +(TakeProfit * Point),"",MAGIGMA_n,0,clrRed);
       }
   }
   }