//+------------------------------------------------------------------+
//|                                    SMC Master Pro EA v3.0 Enhanced |
//|                          Advanced Smart Money Concepts Trading    |
//|              All 27 SMC Concepts | Trading Hub Juka Method        |
//+------------------------------------------------------------------+
#property copyright "SMC Master Pro Enhanced"
#property link      "https://www.mql5.com"
#property version   "3.00"
#property strict
#property description "Professional SMC EA with complete 27 concepts"
#property description "Trading Hub Juka Method | Complete Market Analysis"

#include <Trade/Trade.mqh>
#include <Arrays/ArrayObj.mqh>
CTrade trade;

//==================== MASTER CONTROL ================================
input group "=== MASTER CONTROL PANEL ==="
input bool   TradingEnabled        = true;      // 🔑 Master Trading Switch
input bool   AutoTradingMode       = true;      // Auto Trading (vs Manual Signals)
input bool   EnableNewsFilter      = true;      // Enable News Filter
input bool   UseTradingHubJuka     = true;      // Use Trading Hub Juka Method

//==================== RISK & MONEY MANAGEMENT =======================
input group "=== RISK MANAGEMENT ==="
input double RiskPercentPerTrade   = 0.5;       // Risk Per Trade (%)
input double MaxDailyRiskPercent   = 2.0;       // Max Daily Risk (%)
input int    MaxDailyTrades        = 15;        // Max Daily Trades
input double MaxDrawdownPercent    = 5.0;       // Max Drawdown Limit (%)
input int    DefaultSLPips         = 50;        // Default SL (Pips)
input double DefaultRR             = 3.0;       // Default Risk:Reward
input bool   UseFixedLot           = false;     // Use Fixed Lot Size
input double FixedLotSize          = 0.01;      // Fixed Lot Size

//==================== MULTI-TIMEFRAME SETUP =========================
input group "=== MULTI-TIMEFRAME ANALYSIS ==="
input ENUM_TIMEFRAMES AnalysisTF1  = PERIOD_M15;  // Analysis TF 1 (Default M15)
input ENUM_TIMEFRAMES TradeTF1     = PERIOD_M1;   // Trade TF 1 (Default M1)
input ENUM_TIMEFRAMES AnalysisTF2  = PERIOD_H1;   // Analysis TF 2 (Default H1)
input ENUM_TIMEFRAMES TradeTF2     = PERIOD_M5;   // Trade TF 2 (Default M5)
input ENUM_TIMEFRAMES AnalysisTF3  = PERIOD_H4;   // Analysis TF 3 (Default H4)
input ENUM_TIMEFRAMES TradeTF3     = PERIOD_M15;  // Trade TF 3 (Default M15)
input ENUM_TIMEFRAMES AnalysisTF4  = PERIOD_D1;   // Analysis TF 4 (Default D1)
input ENUM_TIMEFRAMES TradeTF4     = PERIOD_H1;   // Trade TF 4 (Default H1)
input ENUM_TIMEFRAMES AnalysisTF5  = PERIOD_W1;   // Analysis TF 5 (Default W1)
input ENUM_TIMEFRAMES TradeTF5     = PERIOD_H4;   // Trade TF 5 (Default H4)
input bool   TradeOnM1   = true;   // Allow M1 execution

//==================== MARKET STRUCTURE SETTINGS =====================
input group "=== MARKET STRUCTURE ==="
input int    SwingDetectionBars    = 10;        // Swing Detection Lookback
input int    StructureDepth        = 100;       // Structure Analysis Depth
input double BOSMinPips            = 5;         // Min BOS Size (Pips)
input double CHoCHMinPips          = 5;         // Min CHoCH Size (Pips)
input bool   UseInducementZones    = true;      // Detect Inducement Zones
input int    InducementLookback    = 20;        // Inducement Lookback
input bool   UseBOS      = true;   // Enable Break of Structure
input bool   UseCHoCH    = true;   // Enable Change of Character

//==================== FAIR VALUE GAP (FVG) ==========================
input group "=== FAIR VALUE GAP ==="
input bool   UseFVG                = true;      // Use FVG Filter
input double MinFVGPips            = 3;         // Min FVG Size (Pips)
input double MaxFVGPips            = 50;        // Max FVG Size (Pips)
input int    FVGLookback           = 50;        // FVG Detection Lookback
input bool   RequireFVGForEntry    = false;     // Require FVG for Entry
input double FVGFillPercent        = 50;        // FVG Fill % for Entry

//==================== ORDER BLOCK SETTINGS ==========================
input group "=== ORDER BLOCKS ==="
input bool   UseOrderBlocks        = true;      // Use Order Blocks
input int    OBLookback            = 100;       // OB Detection Lookback
input double MinOBStrength         = 10;        // Min OB Strength (Pips)
input bool   RequireOBForEntry     = false;     // Require OB for Entry
input int    MaxOBAge              = 50;        // Max OB Age (Bars)

//==================== LIQUIDITY SETTINGS ============================
input group "=== LIQUIDITY ==="
input bool   UseLiquidityGrab      = true;      // Detect Liquidity Grabs
input bool   UseSessionLiquidity   = true;      // Track Session Liquidity
input int    LiquidityLookback     = 50;        // Liquidity Detection Bars
input double MinLiquiditySweep     = 3;         // Min Sweep Size (Pips)
input bool   UseLiquiditySwipe     = true;      // Liquidity Swipe Detection

//==================== SUPPLY & DEMAND ZONES =========================
input group "=== SUPPLY & DEMAND ==="
input bool   UseSupplyDemand       = true;      // Use Supply/Demand Zones
input int    SDZoneLookback        = 100;       // Zone Detection Lookback
input double MinZoneStrength       = 15;        // Min Zone Strength (Pips)
input int    MaxZoneTouches        = 3;         // Max Zone Touches

//==================== TREND & PATTERN SETTINGS ======================
input group "=== TREND & PATTERNS ==="
input bool   UseTrendLines         = true;      // Auto Trend Lines
input bool   UseSupportResistance  = true;      // Support/Resistance Zones
input bool   UseChannels           = true;      // Detect Channels
input bool   UseQMLPattern         = true;      // QML Pattern Detection
input bool   UseDoubleTopBottom    = true;      // Double Top/Bottom
input bool   UseTriangles          = true;      // Triangle Patterns (Symmetric)
input int    PatternLookback       = 100;       // Pattern Detection Bars

//==================== IMPULSE & CORRECTION ==========================
input group "=== IMPULSE & CORRECTION ==="
input bool   UseImpulseCorrection  = true;      // Impulse/Correction Analysis
input int    ImpulseLookback       = 50;        // Impulse Detection Bars
input double MinImpulseStrength    = 20;        // Min Impulse Strength (Pips)
input double CorrectionMaxPercent  = 61.8;      // Max Correction % (Fib)

//==================== FIBONACCI SETTINGS ============================
input group "=== FIBONACCI ==="
input bool   UseFibonacci          = true;      // Use Fibonacci Levels
input double Fib_236               = 0.236;     // Fib 23.6%
input double Fib_382               = 0.382;     // Fib 38.2%
input double Fib_500               = 0.500;     // Fib 50%
input double Fib_618               = 0.618;     // Fib 61.8%
input double Fib_786               = 0.786;     // Fib 78.6%

//==================== ENTRY MODELS ==================================
input group "=== ENTRY MODELS ==="
input bool   UsePOI_Model1         = true;      // POI Entry Model 1
input bool   UsePOI_Model2         = true;      // POI Entry Model 2
input bool   UseSniperEntry        = true;      // Sniper Entry System
input bool   UseInsideCandle       = true;      // Inside Candle Breakout
input bool   UseReversalCandles    = true;      // Reversal Candles
input int    SniperConfirmBars     = 3;         // Sniper Confirmation Bars

//==================== CORRELATION & SMT =============================
input group "=== CORRELATION & SMT ==="
input bool   UseCorrelation        = true;      // Use Pair Correlation
input string CorrelatedPair        = "EURUSD";  // Correlated Pair
input bool   UseSMT                = true;      // SMT Divergence (Tool & Trap)
input int    SMTLookback           = 20;        // SMT Lookback Bars

//==================== ORDER FLOW ====================================
input group "=== ORDER FLOW ==="
input bool   UseOrderFlow          = true;      // Order Flow Analysis
input int    OrderFlowBars         = 20;        // Order Flow Lookback
input bool   UseIFC                = true;      // Institutional Funding Candle

//==================== NEWS FILTER ===================================
input group "=== NEWS FILTER ==="
input int    MinutesBeforeNews     = 30;        // Minutes Before News
input int    MinutesAfterNews      = 30;        // Minutes After News
input bool   TradeHighImpact       = false;     // Trade During High Impact News

//==================== VOLATILITY & FILTERS ==========================
input group "=== VOLATILITY FILTERS ==="
input int    ATR_Period            = 14;        // ATR Period
input double ATR_MinMultiple       = 0.8;       // Min ATR Multiple
input double ATR_MaxMultiple       = 3.0;       // Max ATR Multiple
input bool   UseConsolidationFilter= true;      // Filter Consolidation
input int    ConsolidationBars     = 20;        // Consolidation Detection

//==================== TRADE MANAGEMENT ==============================
input group "=== TRADE MANAGEMENT ==="
input bool   UseBreakEven          = true;      // Move to Break Even
input double BE_TriggerR           = 1.0;       // BE Trigger (R Multiple)
input bool   UseTrailingStop       = true;      // Trailing Stop
input double TrailStartR           = 1.5;       // Trail Start (R)
input double TrailStepR            = 0.5;       // Trail Step (R)
input bool   UsePartialClose       = true;      // Partial Close
input double PartialCloseR         = 2.0;       // Partial Close at R
input double PartialClosePercent   = 50;        // Partial Close %

//==================== TIME & SESSION FILTERS ========================
input group "=== TIME & SESSION ==="
input bool   TradeAsianSession     = false;     // Trade Asian Session
input bool   TradeLondonSession    = true;      // Trade London Session
input bool   TradeNYSession        = true;      // Trade NY Session
input int    StartHour             = 0;         // Start Hour (0=All Day)
input int    EndHour               = 24;        // End Hour
input bool   AvoidWeekendClose     = true;      // Avoid Weekend

//==================== TRADING HUB JUKA METHOD =======================
input group "=== TRADING HUB JUKA METHOD ==="
input bool   Juka_UseHTF_Confirmation = true;   // HTF Trend Confirmation
input bool   Juka_RequireAlignment    = true;   // Require Multi-TF Alignment
input int    Juka_MinAlignedTFs       = 3;      // Min Aligned Timeframes
input bool   Juka_UseSmartEntry       = true;   // Smart Entry Technique
input bool   Juka_ConfirmWithVolume   = false;  // Volume Confirmation

//==================== ENUMS & STRUCTURES ============================
enum TREND_STATE {
   TREND_BULLISH,
   TREND_BEARISH,
   TREND_RANGING
};

enum STRUCTURE_TYPE {
   STRUCTURE_HH,      // Higher High
   STRUCTURE_HL,      // Higher Low
   STRUCTURE_LH,      // Lower High
   STRUCTURE_LL,      // Lower Low
   STRUCTURE_EQUAL    // Equal High/Low
};

enum BIAS_TYPE {
   BIAS_STRONG_BULLISH,
   BIAS_BULLISH,
   BIAS_NEUTRAL,
   BIAS_BEARISH,
   BIAS_STRONG_BEARISH
};

enum WAVE_TYPE {
   WAVE_IMPULSE,
   WAVE_CORRECTION
};

enum SESSION_TYPE {
   SESSION_ASIAN,
   SESSION_LONDON,
   SESSION_NY,
   SESSION_OVERLAP
};

struct SwingPoint {
   datetime time;
   double   price;
   bool     isHigh;
   int      barIndex;
   int      strength;
};

struct FairValueGap {
   datetime created;
   double   topPrice;
   double   bottomPrice;
   double   midPrice;
   bool     isBullish;
   bool     filled;
   double   fillPercent;
   int      barAge;
};

struct OrderBlock {
   datetime created;
   double   highPrice;
   double   lowPrice;
   double   midPrice;
   bool     isBullish;
   bool     touched;
   int      strength;
   int      barAge;
   bool     valid;
};

struct LiquidityZone {
   datetime time;
   double   price;
   bool     isHigh;
   bool     swept;
   int      touchCount;
   bool     sessionHigh;
   bool     sessionLow;
};

struct SupplyDemandZone {
   datetime created;
   double   topPrice;
   double   bottomPrice;
   double   midPrice;
   bool     isSupply;
   int      touches;
   double   strength;
   bool     valid;
};

struct TrendLine {
   datetime start_time;
   datetime end_time;
   double   start_price;
   double   end_price;
   bool     isBullish;
   bool     broken;
   int      touchCount;
};

struct Channel {
   TrendLine upperLine;
   TrendLine lowerLine;
   double    width;
   bool      valid;
};

struct SupportResistance {
   double   price;
   int      touchCount;
   datetime lastTouch;
   bool     isSupport;
   double   strength;
};

struct ImpulseWave {
   datetime startTime;
   datetime endTime;
   double   startPrice;
   double   endPrice;
   bool     isBullish;
   double   strength;
   double   length;
};

struct CorrectionWave {
   datetime startTime;
   datetime endTime;
   double   startPrice;
   double   endPrice;
   double   correctionPercent;
   double   fibLevel;
};

struct MarketStructure {
   TREND_STATE     trend;
   BIAS_TYPE       bias;
   STRUCTURE_TYPE  lastStructure;
   bool            bosDetected;
   bool            chochDetected;
   datetime        lastBOS_Time;
   datetime        lastCHoCH_Time;
   double          lastHH;
   double          lastHL;
   double          lastLH;
   double          lastLL;
   bool            inducementDetected;
   double          inducementLevel;
   WAVE_TYPE       currentWave;
};

struct OrderFlowData {
   double   buyingPressure;
   double   sellingPressure;
   double   imbalance;
   bool     bullishFlow;
   datetime lastUpdate;
};

struct InstitutionalCandle {
   datetime time;
   double   open;
   double   high;
   double   low;
   double   close;
   double   volume;
   bool     isIFC;
   bool     isBullish;
};

struct SessionLiquidity {
   SESSION_TYPE session;
   double      sessionHigh;
   double      sessionLow;
   datetime    sessionStart;
   bool        highSwept;
   bool        lowSwept;
};

struct TradeSignal {
   bool     valid;
   bool     isBuy;
   double   entryPrice;
   double   stopLoss;
   double   takeProfit;
   int      confidence;
   string   reason;
   datetime signalTime;
   int      timeframeAlignment;
};

struct DailyStats {
   int      tradesCount;
   double   profitLoss;
   double   winRate;
   int      wins;
   int      losses;
   datetime date;
};

struct TradingHubJukaAnalysis {
   bool     htfBullish;
   bool     htfBearish;
   int      alignedTimeframes;
   double   trendStrength;
   bool     readyForEntry;
   string   setupQuality;
};

//==================== GLOBAL VARIABLES ==============================
// Market Structure Arrays
SwingPoint         g_SwingHighs[];
SwingPoint         g_SwingLows[];
FairValueGap       g_FVGs[];
OrderBlock         g_OrderBlocks[];
LiquidityZone      g_LiquidityZones[];
SupplyDemandZone   g_SDZones[];
TrendLine          g_TrendLines[];
Channel            g_Channels[];
SupportResistance  g_SRLevels[];
ImpulseWave        g_ImpulseWaves[];
CorrectionWave     g_Corrections[];
InstitutionalCandle g_IFCs[];
SessionLiquidity   g_SessionData[];

// Multi-Timeframe Structures
MarketStructure    MS_HTF[];        // Higher TimeFrame
MarketStructure    MS_LTF[];        // Lower TimeFrame
TradeSignal        g_CurrentSignal;
DailyStats         g_DailyStats;
OrderFlowData      g_OrderFlow;
TradingHubJukaAnalysis g_JukaAnalysis;

// Trade Management
double      g_EntryPrice = 0;
double      g_InitialSL = 0;
double      g_InitialTP = 0;
bool        g_BE_Activated = false;
bool        g_PartialClosed = false;
datetime    g_LastTradeTime = 0;
datetime    g_CurrentDay = 0;

// Global Bias
BIAS_TYPE   g_GlobalBias = BIAS_NEUTRAL;
double      g_DailyBias = 0;  // Positive = Bullish, Negative = Bearish

//==================== INITIALIZATION ================================
int OnInit() {
   Print("╔════════════════════════════════════════════════════╗");
   Print("║   SMC Master Pro EA v3.0 Enhanced - Initialized   ║");
   Print("║          27 SMC Concepts + Trading Hub Juka        ║");
   Print("╚════════════════════════════════════════════════════╝");
   Print("Symbol: ", _Symbol);
   Print("Risk per trade: ", RiskPercentPerTrade, "%");
   Print("Max daily trades: ", MaxDailyTrades);
   Print("Trading Hub Juka Method: ", (UseTradingHubJuka ? "ENABLED" : "DISABLED"));
   
   // Initialize arrays
   ArrayResize(MS_HTF, 5);
   ArrayResize(MS_LTF, 5);
   ArrayResize(g_SwingHighs, 0);
   ArrayResize(g_SwingLows, 0);
   ArrayResize(g_FVGs, 0);
   ArrayResize(g_OrderBlocks, 0);
   ArrayResize(g_LiquidityZones, 0);
   ArrayResize(g_SDZones, 0);
   ArrayResize(g_TrendLines, 0);
   ArrayResize(g_Channels, 0);
   ArrayResize(g_SRLevels, 0);
   ArrayResize(g_ImpulseWaves, 0);
   ArrayResize(g_Corrections, 0);
   ArrayResize(g_IFCs, 0);
   ArrayResize(g_SessionData, 3);
   
   // Initialize current signal
   g_CurrentSignal.valid = false;
   
   // Initialize Order Flow
   g_OrderFlow.buyingPressure = 0;
   g_OrderFlow.sellingPressure = 0;
   g_OrderFlow.imbalance = 0;
   g_OrderFlow.bullishFlow = false;
   
   // Initialize Juka Analysis
   g_JukaAnalysis.htfBullish = false;
   g_JukaAnalysis.htfBearish = false;
   g_JukaAnalysis.alignedTimeframes = 0;
   g_JukaAnalysis.trendStrength = 0;
   g_JukaAnalysis.readyForEntry = false;
   
   // Reset daily stats
   ResetDailyStats();
   
   EventSetTimer(60); // Run OnTimer every 60 seconds
   
   return(INIT_SUCCEEDED);
}

//==================== DEINITIALIZATION ==============================
void OnDeinit(const int reason) {
   Print("SMC Master Pro EA v3.0 stopped. Reason code: ", reason);
   
   // Print final statistics
   Print("═══════════════════════════════════════");
   Print("Total trades today: ", g_DailyStats.tradesCount);
   Print("Wins: ", g_DailyStats.wins, " | Losses: ", g_DailyStats.losses);
   Print("Win Rate: ", (g_DailyStats.tradesCount > 0 ? 
         DoubleToString(g_DailyStats.winRate, 2) : "0"), "%");
   Print("P&L: $", DoubleToString(g_DailyStats.profitLoss, 2));
   Print("═══════════════════════════════════════");
   EventKillTimer();
}

//==================== UTILITY FUNCTIONS =============================
double GetPipValue() {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   if(digits == 3 || digits == 5)
      return point * 10;
   return point * 100;
}

double PipsToPrice(double pips) {
   return pips * GetPipValue();
}

double PriceToPips(double price) {
   return price / GetPipValue();
}

void ResetDailyStats() {
   datetime today = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(today, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime todayStart = StructToTime(dt);
   
   if(g_CurrentDay != todayStart) {
      g_CurrentDay = todayStart;
      g_DailyStats.tradesCount = 0;
      g_DailyStats.profitLoss = 0;
      g_DailyStats.wins = 0;
      g_DailyStats.losses = 0;
      g_DailyStats.winRate = 0;
      g_DailyStats.date = todayStart;
      
      Print("═══ New Trading Day ═══");
      Print("Date: ", TimeToString(todayStart, TIME_DATE));
   }
}

bool IsNewBar(ENUM_TIMEFRAMES tf) {
   static datetime lastBarTime[];
   static int arraySize = 0;
   
   if(arraySize == 0) {
      ArrayResize(lastBarTime, 10);
      arraySize = 10;
   }
   
   int tfIndex = 0;
   switch(tf) {
      case PERIOD_M1:  tfIndex = 0; break;
      case PERIOD_M5:  tfIndex = 1; break;
      case PERIOD_M15: tfIndex = 2; break;
      case PERIOD_H1:  tfIndex = 3; break;
      case PERIOD_H4:  tfIndex = 4; break;
      case PERIOD_D1:  tfIndex = 5; break;
      case PERIOD_W1:  tfIndex = 6; break;
      default: tfIndex = 7; break;
   }
   
   datetime currentBarTime = iTime(_Symbol, tf, 0);
   if(lastBarTime[tfIndex] != currentBarTime) {
      lastBarTime[tfIndex] = currentBarTime;
      return true;
   }
   return false;
}

double GetATR(ENUM_TIMEFRAMES tf, int period, int shift = 0) {
   int handle = iATR(_Symbol, tf, period);
   if(handle == INVALID_HANDLE) return 0;
   
   double buffer[];
   ArraySetAsSeries(buffer, true);
   
   if(CopyBuffer(handle, 0, shift, 1, buffer) <= 0) {
      IndicatorRelease(handle);
      return 0;
   }
   
   double result = buffer[0];
   IndicatorRelease(handle);
   return result;
}

//==================== LOT CALCULATION ===============================
double CalculateLotSize(double slPips) {
   if(UseFixedLot)
      return FixedLotSize;

   if(slPips <= 0) return 0;

   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   if(tickValue <= 0 || tickSize <= 0) {
      Print("❌ Invalid tick values");
      return 0;
   }

   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (RiskPercentPerTrade / 100.0);

   double slPrice = slPips * GetPipValue();
   if(slPrice <= 0) return 0;

   double costPerLot = (slPrice / tickSize) * tickValue;
   if(costPerLot <= 0) return 0;

   double lot = riskAmount / costPerLot;

   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);

   lot = MathFloor(lot / step) * step;
   lot = MathMax(minLot, MathMin(maxLot, lot));

   return NormalizeDouble(lot, 2);
}

//==================== SWING POINT DETECTION =========================
bool IsSwingHigh(ENUM_TIMEFRAMES tf, int index, int lookback) {
   if(index < 0) return false;
   
   double high = iHigh(_Symbol, tf, index);
   
   for(int i = 1; i <= lookback; i++) {
      if(index - i < 0) continue;
      if(iHigh(_Symbol, tf, index - i) >= high)
         return false;
   }
   
   for(int i = 1; i <= lookback; i++) {
      if(iHigh(_Symbol, tf, index + i) >= high)
         return false;
   }
   
   return true;
}

bool IsSwingLow(ENUM_TIMEFRAMES tf, int index, int lookback) {
   if(index < 0) return false;
   
   double low = iLow(_Symbol, tf, index);
   
   for(int i = 1; i <= lookback; i++) {
      if(index - i < 0) continue;
      if(iLow(_Symbol, tf, index - i) <= low)
         return false;
   }
   
   for(int i = 1; i <= lookback; i++) {
      if(iLow(_Symbol, tf, index + i) <= low)
         return false;
   }
   
   return true;
}

void DetectSwingPoints(ENUM_TIMEFRAMES tf) {
   ArrayResize(g_SwingHighs, 0);
   ArrayResize(g_SwingLows, 0);
   
   for(int i = SwingDetectionBars; i < StructureDepth; i++) {
      if(IsSwingHigh(tf, i, SwingDetectionBars)) {
         SwingPoint sp;
         sp.time = iTime(_Symbol, tf, i);
         sp.price = iHigh(_Symbol, tf, i);
         sp.isHigh = true;
         sp.barIndex = i;
         
         double avgHigh = 0;
         for(int j = 1; j <= 5; j++) {
            avgHigh += iHigh(_Symbol, tf, i + j);
         }
         avgHigh /= 5;
         sp.strength = (int)PriceToPips(sp.price - avgHigh);
         
         int size = ArraySize(g_SwingHighs);
         ArrayResize(g_SwingHighs, size + 1);
         g_SwingHighs[size] = sp;
      }
      
      if(IsSwingLow(tf, i, SwingDetectionBars)) {
         SwingPoint sp;
         sp.time = iTime(_Symbol, tf, i);
         sp.price = iLow(_Symbol, tf, i);
         sp.isHigh = false;
         sp.barIndex = i;
         
         double avgLow = 0;
         for(int j = 1; j <= 5; j++) {
            avgLow += iLow(_Symbol, tf, i + j);
         }
         avgLow /= 5;
         sp.strength = (int)PriceToPips(avgLow - sp.price);
         
         int size = ArraySize(g_SwingLows);
         ArrayResize(g_SwingLows, size + 1);
         g_SwingLows[size] = sp;
      }
   }
}

//==================== MARKET STRUCTURE ANALYSIS (CONTINUED) =========
void AnalyzeMarketStructure(ENUM_TIMEFRAMES tf, MarketStructure &ms) {
   DetectSwingPoints(tf);
   
   int highCount = ArraySize(g_SwingHighs);
   int lowCount = ArraySize(g_SwingLows);
   
   if(highCount < 2 || lowCount < 2) {
      ms.trend = TREND_RANGING;
      ms.bias = BIAS_NEUTRAL;
      return;
   }
   
   double lastHigh1 = g_SwingHighs[0].price;
   double lastHigh2 = g_SwingHighs[1].price;
   double lastLow1 = g_SwingLows[0].price;
   double lastLow2 = g_SwingLows[1].price;
   
   ms.lastHH = lastHigh1;
   ms.lastHL = lastLow1;
   ms.lastLH = lastHigh1;
   ms.lastLL = lastLow1;
   
   bool hasHH = lastHigh1 > lastHigh2;
   bool hasHL = lastLow1 > lastLow2;
   bool hasLH = lastHigh1 < lastHigh2;
   bool hasLL = lastLow1 < lastLow2;
   
   if(hasHH && hasHL) {
      ms.trend = TREND_BULLISH;
      ms.lastStructure = STRUCTURE_HH;
      ms.bias = BIAS_BULLISH;
      ms.currentWave = WAVE_IMPULSE;
      
      if(highCount >= 3 && g_SwingHighs[1].price > g_SwingHighs[2].price)
         ms.bias = BIAS_STRONG_BULLISH;
   }
   else if(hasLL && hasLH) {
      ms.trend = TREND_BEARISH;
      ms.lastStructure = STRUCTURE_LL;
      ms.bias = BIAS_BEARISH;
      ms.currentWave = WAVE_IMPULSE;
      
      if(lowCount >= 3 && g_SwingLows[1].price < g_SwingLows[2].price)
         ms.bias = BIAS_STRONG_BEARISH;
   }
   else {
      ms.trend = TREND_RANGING;
      ms.bias = BIAS_NEUTRAL;
      ms.currentWave = WAVE_CORRECTION;
   }
   
   // BOS Detection
   if(UseBOS) {
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double bosThreshold = PipsToPrice(BOSMinPips);
      
      if(ms.trend == TREND_BULLISH && highCount >= 2) {
         if(currentPrice > (lastHigh2 + bosThreshold)) {
            if(!ms.bosDetected || (TimeCurrent() - ms.lastBOS_Time) > PeriodSeconds(tf) * 10) {
               ms.bosDetected = true;
               ms.lastBOS_Time = TimeCurrent();
               Print("📊 BOS Detected (BULLISH) on ", EnumToString(tf));
            }
         }
      }
      else if(ms.trend == TREND_BEARISH && lowCount >= 2) {
         if(currentPrice < (lastLow2 - bosThreshold)) {
            if(!ms.bosDetected || (TimeCurrent() - ms.lastBOS_Time) > PeriodSeconds(tf) * 10) {
               ms.bosDetected = true;
               ms.lastBOS_Time = TimeCurrent();
               Print("📊 BOS Detected (BEARISH) on ", EnumToString(tf));
            }
         }
      }
   }
   
   // CHoCH Detection
   if(UseCHoCH) {
      double chochThreshold = PipsToPrice(CHoCHMinPips);
      
      if(ms.trend == TREND_BULLISH && hasLL) {
         if((lastLow2 - lastLow1) > chochThreshold) {
            ms.chochDetected = true;
            ms.lastCHoCH_Time = TimeCurrent();
            ms.trend = TREND_BEARISH;
            ms.bias = BIAS_BEARISH;
            Print("🔄 CHoCH Detected: BULLISH → BEARISH on ", EnumToString(tf));
         }
      }
      else if(ms.trend == TREND_BEARISH && hasHH) {
         if((lastHigh1 - lastHigh2) > chochThreshold) {
            ms.chochDetected = true;
            ms.lastCHoCH_Time = TimeCurrent();
            ms.trend = TREND_BULLISH;
            ms.bias = BIAS_BULLISH;
            Print("🔄 CHoCH Detected: BEARISH → BULLISH on ", EnumToString(tf));
         }
      }
   }
   
   if(UseInducementZones) {
      DetectInducement(tf, ms);
   }
}

void DetectInducement(ENUM_TIMEFRAMES tf, MarketStructure &ms) {
   int highCount = ArraySize(g_SwingHighs);
   int lowCount = ArraySize(g_SwingLows);
   
   if(highCount < 3 || lowCount < 3) return;
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   if(ms.trend == TREND_BULLISH) {
      double recentLow = g_SwingLows[0].price;
      
      if(iLow(_Symbol, tf, 1) < recentLow && currentPrice > recentLow) {
         ms.inducementDetected = true;
         ms.inducementLevel = recentLow;
         Print("💡 Bullish Inducement at ", recentLow);
      }
   }
   else if(ms.trend == TREND_BEARISH) {
      double recentHigh = g_SwingHighs[0].price;
      
      if(iHigh(_Symbol, tf, 1) > recentHigh && currentPrice < recentHigh) {
         ms.inducementDetected = true;
         ms.inducementLevel = recentHigh;
         Print("💡 Bearish Inducement at ", recentHigh);
      }
   }
}

// Continue with remaining 2000+ lines...
// Due to length, I'll create a second file for the continuation

