//+------------------------------------------------------------------+
//|                SMC Master Pro EA v3.0 - Part 2 (Continuation)     |
//|                     Add this to the main file above               |
//+------------------------------------------------------------------+

//==================== FAIR VALUE GAP DETECTION ======================
void DetectFairValueGaps(ENUM_TIMEFRAMES tf) {
   ArrayResize(g_FVGs, 0);
   
   double minGap = PipsToPrice(MinFVGPips);
   double maxGap = PipsToPrice(MaxFVGPips);
   
   for(int i = 1; i < FVGLookback - 2; i++) {
      double high0 = iHigh(_Symbol, tf, i);
      double low0 = iLow(_Symbol, tf, i);
      double high2 = iHigh(_Symbol, tf, i + 2);
      double low2 = iLow(_Symbol, tf, i + 2);
      
      // Bullish FVG
      double bullGap = low0 - high2;
      if(bullGap >= minGap && bullGap <= maxGap) {
         FairValueGap fvg;
         fvg.created = iTime(_Symbol, tf, i);
         fvg.topPrice = low0;
         fvg.bottomPrice = high2;
         fvg.midPrice = (fvg.topPrice + fvg.bottomPrice) / 2;
         fvg.isBullish = true;
         fvg.filled = false;
         fvg.barAge = i;
         
         double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(currentPrice <= fvg.topPrice && currentPrice >= fvg.bottomPrice) {
            double range = fvg.topPrice - fvg.bottomPrice;
            fvg.fillPercent = ((fvg.topPrice - currentPrice) / range) * 100;
         } else if(currentPrice < fvg.bottomPrice) {
            fvg.filled = true;
            fvg.fillPercent = 100;
         }
         
         int size = ArraySize(g_FVGs);
         ArrayResize(g_FVGs, size + 1);
         g_FVGs[size] = fvg;
      }
      
      // Bearish FVG
      double bearGap = low2 - high0;
      if(bearGap >= minGap && bearGap <= maxGap) {
         FairValueGap fvg;
         fvg.created = iTime(_Symbol, tf, i);
         fvg.topPrice = low2;
         fvg.bottomPrice = high0;
         fvg.midPrice = (fvg.topPrice + fvg.bottomPrice) / 2;
         fvg.isBullish = false;
         fvg.filled = false;
         fvg.barAge = i;
         
         double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(currentPrice >= fvg.bottomPrice && currentPrice <= fvg.topPrice) {
            double range = fvg.topPrice - fvg.bottomPrice;
            fvg.fillPercent = ((currentPrice - fvg.bottomPrice) / range) * 100;
         } else if(currentPrice > fvg.topPrice) {
            fvg.filled = true;
            fvg.fillPercent = 100;
         }
         
         int size = ArraySize(g_FVGs);
         ArrayResize(g_FVGs, size + 1);
         g_FVGs[size] = fvg;
      }
   }
}

//==================== ORDER BLOCK DETECTION =========================
void DetectOrderBlocks(ENUM_TIMEFRAMES tf) {
   ArrayResize(g_OrderBlocks, 0);
   
   double minStrength = PipsToPrice(MinOBStrength);
   
   for(int i = 1; i < OBLookback - 1; i++) {
      double open = iOpen(_Symbol, tf, i);
      double close = iClose(_Symbol, tf, i);
      double high = iHigh(_Symbol, tf, i);
      double low = iLow(_Symbol, tf, i);
      
      double nextOpen = iOpen(_Symbol, tf, i - 1);
      double nextClose = iClose(_Symbol, tf, i - 1);
      double nextHigh = iHigh(_Symbol, tf, i - 1);
      
      double candleSize = MathAbs(close - open);
      
      // Bullish Order Block
      if(close < open && candleSize >= minStrength && 
         nextClose > nextOpen && nextClose > high) {
         
         OrderBlock ob;
         ob.created = iTime(_Symbol, tf, i);
         ob.highPrice = open;
         ob.lowPrice = close;
         ob.midPrice = (ob.highPrice + ob.lowPrice) / 2;
         ob.isBullish = true;
         ob.touched = false;
         ob.strength = (int)PriceToPips(candleSize);
         ob.barAge = i;
         ob.valid = true;
         
         int size = ArraySize(g_OrderBlocks);
         ArrayResize(g_OrderBlocks, size + 1);
         g_OrderBlocks[size] = ob;
      }
      
      // Bearish Order Block
      if(close > open && candleSize >= minStrength && 
         nextClose < nextOpen && nextClose < low) {
         
         OrderBlock ob;
         ob.created = iTime(_Symbol, tf, i);
         ob.highPrice = close;
         ob.lowPrice = open;
         ob.midPrice = (ob.highPrice + ob.lowPrice) / 2;
         ob.isBullish = false;
         ob.touched = false;
         ob.strength = (int)PriceToPips(candleSize);
         ob.barAge = i;
         ob.valid = true;
         
         int size = ArraySize(g_OrderBlocks);
         ArrayResize(g_OrderBlocks, size + 1);
         g_OrderBlocks[size] = ob;
      }
   }
   
   for(int i = 0; i < ArraySize(g_OrderBlocks); i++) {
      if(g_OrderBlocks[i].barAge > MaxOBAge) {
         g_OrderBlocks[i].valid = false;
      }
   }
}

//==================== SUPPLY & DEMAND ZONE DETECTION ================
void DetectSupplyDemandZones(ENUM_TIMEFRAMES tf) {
   if(!UseSupplyDemand) return;
   
   ArrayResize(g_SDZones, 0);
   
   double minStrength = PipsToPrice(MinZoneStrength);
   
   for(int i = 2; i < SDZoneLookback; i++) {
      double open = iOpen(_Symbol, tf, i);
      double close = iClose(_Symbol, tf, i);
      double high = iHigh(_Symbol, tf, i);
      double low = iLow(_Symbol, tf, i);
      
      // Supply Zone: Strong bearish move FROM this zone
      bool strongBearishMove = false;
      double moveSize = 0;
      
      for(int j = 1; j <= 5; j++) {
         if(i - j < 0) break;
         double nextLow = iLow(_Symbol, tf, i - j);
         moveSize = high - nextLow;
         if(moveSize >= minStrength) {
            strongBearishMove = true;
            break;
         }
      }
      
      if(strongBearishMove) {
         SupplyDemandZone zone;
         zone.created = iTime(_Symbol, tf, i);
         zone.topPrice = high;
         zone.bottomPrice = MathMax(open, close);
         zone.midPrice = (zone.topPrice + zone.bottomPrice) / 2;
         zone.isSupply = true;
         zone.touches = 0;
         zone.strength = moveSize;
         zone.valid = true;
         
         // Count touches
         for(int k = 0; k < i; k++) {
            double kHigh = iHigh(_Symbol, tf, k);
            if(kHigh >= zone.bottomPrice && kHigh <= zone.topPrice) {
               zone.touches++;
            }
         }
         
         if(zone.touches <= MaxZoneTouches) {
            int size = ArraySize(g_SDZones);
            ArrayResize(g_SDZones, size + 1);
            g_SDZones[size] = zone;
         }
      }
      
      // Demand Zone: Strong bullish move FROM this zone
      bool strongBullishMove = false;
      moveSize = 0;
      
      for(int j = 1; j <= 5; j++) {
         if(i - j < 0) break;
         double nextHigh = iHigh(_Symbol, tf, i - j);
         moveSize = nextHigh - low;
         if(moveSize >= minStrength) {
            strongBullishMove = true;
            break;
         }
      }
      
      if(strongBullishMove) {
         SupplyDemandZone zone;
         zone.created = iTime(_Symbol, tf, i);
         zone.topPrice = MathMin(open, close);
         zone.bottomPrice = low;
         zone.midPrice = (zone.topPrice + zone.bottomPrice) / 2;
         zone.isSupply = false;
         zone.touches = 0;
         zone.strength = moveSize;
         zone.valid = true;
         
         // Count touches
         for(int k = 0; k < i; k++) {
            double kLow = iLow(_Symbol, tf, k);
            if(kLow >= zone.bottomPrice && kLow <= zone.topPrice) {
               zone.touches++;
            }
         }
         
         if(zone.touches <= MaxZoneTouches) {
            int size = ArraySize(g_SDZones);
            ArrayResize(g_SDZones, size + 1);
            g_SDZones[size] = zone;
         }
      }
   }
   
   Print("🔷 Detected ", ArraySize(g_SDZones), " Supply/Demand Zones");
}

//==================== LIQUIDITY DETECTION ===========================
void DetectLiquidityZones(ENUM_TIMEFRAMES tf) {
   ArrayResize(g_LiquidityZones, 0);
   
   for(int i = 1; i < LiquidityLookback; i++) {
      double high = iHigh(_Symbol, tf, i);
      double low = iLow(_Symbol, tf, i);
      
      // Equal highs
      for(int j = i + 1; j < LiquidityLookback; j++) {
         double compareHigh = iHigh(_Symbol, tf, j);
         
         if(MathAbs(high - compareHigh) < PipsToPrice(2)) {
            LiquidityZone lz;
            lz.time = iTime(_Symbol, tf, i);
            lz.price = high;
            lz.isHigh = true;
            lz.swept = false;
            lz.touchCount = 2;
            lz.sessionHigh = false;
            lz.sessionLow = false;
            
            int size = ArraySize(g_LiquidityZones);
            ArrayResize(g_LiquidityZones, size + 1);
            g_LiquidityZones[size] = lz;
            break;
         }
      }
      
      // Equal lows
      for(int j = i + 1; j < LiquidityLookback; j++) {
         double compareLow = iLow(_Symbol, tf, j);
         
         if(MathAbs(low - compareLow) < PipsToPrice(2)) {
            LiquidityZone lz;
            lz.time = iTime(_Symbol, tf, i);
            lz.price = low;
            lz.isHigh = false;
            lz.swept = false;
            lz.touchCount = 2;
            lz.sessionHigh = false;
            lz.sessionLow = false;
            
            int size = ArraySize(g_LiquidityZones);
            ArrayResize(g_LiquidityZones, size + 1);
            g_LiquidityZones[size] = lz;
            break;
         }
      }
   }
}

bool CheckLiquiditySweep(bool isBuy) {
   if(!UseLiquidityGrab) return true;
   
   double currentPrice = isBuy ? 
      SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
      SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double sweepThreshold = PipsToPrice(MinLiquiditySweep);
   
   for(int i = 0; i < ArraySize(g_LiquidityZones); i++) {
      if(g_LiquidityZones[i].swept) continue;
      
      if(isBuy && !g_LiquidityZones[i].isHigh) {
         double lowBreach = g_LiquidityZones[i].price - iLow(_Symbol, PERIOD_CURRENT, 1);
         if(lowBreach > 0 && lowBreach < sweepThreshold && 
            currentPrice > g_LiquidityZones[i].price) {
            g_LiquidityZones[i].swept = true;
            Print("💧 Bullish Liquidity Sweep at ", g_LiquidityZones[i].price);
            return true;
         }
      }
      
      if(!isBuy && g_LiquidityZones[i].isHigh) {
         double highBreach = iHigh(_Symbol, PERIOD_CURRENT, 1) - g_LiquidityZones[i].price;
         if(highBreach > 0 && highBreach < sweepThreshold && 
            currentPrice < g_LiquidityZones[i].price) {
            g_LiquidityZones[i].swept = true;
            Print("💧 Bearish Liquidity Sweep at ", g_LiquidityZones[i].price);
            return true;
         }
      }
   }
   
   return false;
}

//==================== LIQUIDITY SWIPE DETECTION =====================
bool DetectLiquiditySwipe(ENUM_TIMEFRAMES tf, bool isBuy) {
   if(!UseLiquiditySwipe) return true;
   
   // Liquidity swipe: False breakout that quickly reverses
   
   double prevHigh = iHigh(_Symbol, tf, 2);
   double prevLow = iLow(_Symbol, tf, 2);
   double currentHigh = iHigh(_Symbol, tf, 1);
   double currentLow = iLow(_Symbol, tf, 1);
   double currentClose = iClose(_Symbol, tf, 1);
   
   double swipeThreshold = PipsToPrice(MinLiquiditySweep);
   
   if(isBuy) {
      // Bullish swipe: Broke below previous low but closed back above
      if(currentLow < (prevLow - swipeThreshold) && currentClose > prevLow) {
         Print("🌊 Bullish Liquidity Swipe detected");
         return true;
      }
   } else {
      // Bearish swipe: Broke above previous high but closed back below
      if(currentHigh > (prevHigh + swipeThreshold) && currentClose < prevHigh) {
         Print("🌊 Bearish Liquidity Swipe detected");
         return true;
      }
   }
   
   return false;
}

//==================== SESSION LIQUIDITY =============================
void DetectSessionLiquidity() {
   if(!UseSessionLiquidity) return;
   
   ArrayResize(g_SessionData, 3);
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Asian Session (00:00 - 09:00 GMT)
   if(dt.hour >= 0 && dt.hour < 9) {
      UpdateSessionData(0, SESSION_ASIAN);
   }
   // London Session (08:00 - 17:00 GMT)
   else if(dt.hour >= 8 && dt.hour < 17) {
      UpdateSessionData(1, SESSION_LONDON);
   }
   // NY Session (13:00 - 22:00 GMT)
   else if(dt.hour >= 13 && dt.hour < 22) {
      UpdateSessionData(2, SESSION_NY);
   }
}

void UpdateSessionData(int index, SESSION_TYPE session) {
   double currentHigh = iHigh(_Symbol, PERIOD_H1, 0);
   double currentLow = iLow(_Symbol, PERIOD_H1, 0);
   
   if(g_SessionData[index].sessionStart != iTime(_Symbol, PERIOD_H1, 0)) {
      g_SessionData[index].session = session;
      g_SessionData[index].sessionHigh = currentHigh;
      g_SessionData[index].sessionLow = currentLow;
      g_SessionData[index].sessionStart = iTime(_Symbol, PERIOD_H1, 0);
      g_SessionData[index].highSwept = false;
      g_SessionData[index].lowSwept = false;
   } else {
      if(currentHigh > g_SessionData[index].sessionHigh) {
         g_SessionData[index].sessionHigh = currentHigh;
      }
      if(currentLow < g_SessionData[index].sessionLow) {
         g_SessionData[index].sessionLow = currentLow;
      }
   }
}

//==================== CHANNEL DETECTION =============================
void DetectChannels(ENUM_TIMEFRAMES tf) {
   if(!UseChannels) return;
   
   ArrayResize(g_Channels, 0);
   
   // Need at least 2 trend lines to form a channel
   if(ArraySize(g_TrendLines) < 2) return;
   
   for(int i = 0; i < ArraySize(g_TrendLines) - 1; i++) {
      for(int j = i + 1; j < ArraySize(g_TrendLines); j++) {
         TrendLine line1 = g_TrendLines[i];
         TrendLine line2 = g_TrendLines[j];
         
         // Check if lines are parallel (similar slopes)
         double slope1 = (line1.end_price - line1.start_price) / 
                        (line1.end_time - line1.start_time);
         double slope2 = (line2.end_price - line2.start_price) / 
                        (line2.end_time - line2.start_time);
         
         double slopeDiff = MathAbs(slope1 - slope2);
         
         if(slopeDiff < 0.0001) { // Lines are parallel
            Channel ch;
            ch.upperLine = (line1.start_price > line2.start_price) ? line1 : line2;
            ch.lowerLine = (line1.start_price < line2.start_price) ? line1 : line2;
            ch.width = ch.upperLine.start_price - ch.lowerLine.start_price;
            ch.valid = true;
            
            int size = ArraySize(g_Channels);
            ArrayResize(g_Channels, size + 1);
            g_Channels[size] = ch;
            
            Print("📊 Channel Detected - Width: ", PriceToPips(ch.width), " pips");
         }
      }
   }
}

//==================== SYMMETRIC TRIANGLE DETECTION ==================
bool DetectSymmetricTriangle(ENUM_TIMEFRAMES tf) {
   if(!UseTriangles) return false;
   
   int highCount = ArraySize(g_SwingHighs);
   int lowCount = ArraySize(g_SwingLows);
   
   if(highCount < 2 || lowCount < 2) return false;
   
   // Symmetric triangle: Descending highs + Ascending lows converging
   bool descendingHighs = (g_SwingHighs[0].price < g_SwingHighs[1].price);
   bool ascendingLows = (g_SwingLows[0].price > g_SwingLows[1].price);
   
   if(descendingHighs && ascendingLows) {
      // Check if lines are converging
      double highRange = g_SwingHighs[1].price - g_SwingHighs[0].price;
      double lowRange = g_SwingLows[0].price - g_SwingLows[1].price;
      
      if(MathAbs(highRange - lowRange) < PipsToPrice(10)) {
         Print("🔺 Symmetric Triangle Pattern Detected");
         return true;
      }
   }
   
   return false;
}

//==================== IMPULSE & CORRECTION ANALYSIS =================
void DetectImpulseCorrection(ENUM_TIMEFRAMES tf) {
   if(!UseImpulseCorrection) return;
   
   ArrayResize(g_ImpulseWaves, 0);
   ArrayResize(g_Corrections, 0);
   
   double minImpulse = PipsToPrice(MinImpulseStrength);
   
   for(int i = 1; i < ImpulseLookback; i++) {
      double open = iOpen(_Symbol, tf, i);
      double close = iClose(_Symbol, tf, i);
      double high = iHigh(_Symbol, tf, i);
      double low = iLow(_Symbol, tf, i);
      
      double moveSize = MathAbs(close - open);
      
      // Detect strong impulse candles
      if(moveSize >= minImpulse) {
         ImpulseWave impulse;
         impulse.startTime = iTime(_Symbol, tf, i);
         impulse.endTime = iTime(_Symbol, tf, i);
         impulse.startPrice = open;
         impulse.endPrice = close;
         impulse.isBullish = (close > open);
         impulse.strength = moveSize;
         impulse.length = moveSize;
         
         int size = ArraySize(g_ImpulseWaves);
         ArrayResize(g_ImpulseWaves, size + 1);
         g_ImpulseWaves[size] = impulse;
         
         // Look for correction after impulse
         DetectCorrectionAfterImpulse(tf, impulse, i);
      }
   }
   
   Print("📈 Detected ", ArraySize(g_ImpulseWaves), " Impulse Waves");
   Print("📉 Detected ", ArraySize(g_Corrections), " Correction Waves");
}

void DetectCorrectionAfterImpulse(ENUM_TIMEFRAMES tf, ImpulseWave &impulse, int impulseIndex) {
   // Look for retracement after impulse
   for(int i = impulseIndex - 1; i >= MathMax(0, impulseIndex - 10); i--) {
      double close = iClose(_Symbol, tf, i);
      
      double retracement = 0;
      if(impulse.isBullish) {
         retracement = impulse.endPrice - close;
      } else {
         retracement = close - impulse.endPrice;
      }
      
      if(retracement > 0) {
         double correctionPercent = (retracement / impulse.length) * 100;
         
         if(correctionPercent >= 23.6 && correctionPercent <= CorrectionMaxPercent) {
            CorrectionWave correction;
            correction.startTime = impulse.endTime;
            correction.endTime = iTime(_Symbol, tf, i);
            correction.startPrice = impulse.endPrice;
            correction.endPrice = close;
            correction.correctionPercent = correctionPercent;
            
            // Determine Fibonacci level
            if(correctionPercent >= 23.6 && correctionPercent < 38.2)
               correction.fibLevel = Fib_236;
            else if(correctionPercent >= 38.2 && correctionPercent < 50.0)
               correction.fibLevel = Fib_382;
            else if(correctionPercent >= 50.0 && correctionPercent < 61.8)
               correction.fibLevel = Fib_500;
            else if(correctionPercent >= 61.8 && correctionPercent < 78.6)
               correction.fibLevel = Fib_618;
            else
               correction.fibLevel = Fib_786;
            
            int size = ArraySize(g_Corrections);
            ArrayResize(g_Corrections, size + 1);
            g_Corrections[size] = correction;
            
            break;
         }
      }
   }
}

//==================== ORDER FLOW ANALYSIS ===========================
void AnalyzeOrderFlow(ENUM_TIMEFRAMES tf) {
   if(!UseOrderFlow) return;
   
   double buyVolume = 0;
   double sellVolume = 0;
   
   for(int i = 0; i < OrderFlowBars; i++) {
      double open = iOpen(_Symbol, tf, i);
      double close = iClose(_Symbol, tf, i);
      double volume = iVolume(_Symbol, tf, i);
      
      if(close > open) {
         buyVolume += volume;
      } else if(close < open) {
         sellVolume += volume;
      }
   }
   
   double totalVolume = buyVolume + sellVolume;
   if(totalVolume > 0) {
      g_OrderFlow.buyingPressure = (buyVolume / totalVolume) * 100;
      g_OrderFlow.sellingPressure = (sellVolume / totalVolume) * 100;
      g_OrderFlow.imbalance = g_OrderFlow.buyingPressure - g_OrderFlow.sellingPressure;
      g_OrderFlow.bullishFlow = (g_OrderFlow.imbalance > 10);
      g_OrderFlow.lastUpdate = TimeCurrent();
      
      Print("📊 Order Flow - Buy: ", DoubleToString(g_OrderFlow.buyingPressure, 1), 
            "% | Sell: ", DoubleToString(g_OrderFlow.sellingPressure, 1), 
            "% | Imbalance: ", DoubleToString(g_OrderFlow.imbalance, 1), "%");
   }
}

//==================== INSTITUTIONAL FUNDING CANDLE (IFC) ============
void DetectInstitutionalCandles(ENUM_TIMEFRAMES tf) {
   if(!UseIFC) return;
   
   ArrayResize(g_IFCs, 0);
   
   // IFC characteristics:
   // 1. Large body (3x average)
   // 2. High volume
   // 3. Strong directional move
   // 4. Often occurs at key times
   
   double avgCandleSize = 0;
   for(int i = 1; i <= 20; i++) {
      avgCandleSize += MathAbs(iClose(_Symbol, tf, i) - iOpen(_Symbol, tf, i));
   }
   avgCandleSize /= 20;
   
   for(int i = 1; i < 50; i++) {
      double open = iOpen(_Symbol, tf, i);
      double close = iClose(_Symbol, tf, i);
      double high = iHigh(_Symbol, tf, i);
      double low = iLow(_Symbol, tf, i);
      long volume = iVolume(_Symbol, tf, i);
      
      double bodySize = MathAbs(close - open);
      double totalRange = high - low;
      
      // Check IFC criteria
      bool largeBody = (bodySize >= avgCandleSize * 3);
      bool dominantBody = (bodySize >= totalRange * 0.7);
      
      if(largeBody && dominantBody) {
         InstitutionalCandle ifc;
         ifc.time = iTime(_Symbol, tf, i);
         ifc.open = open;
         ifc.high = high;
         ifc.low = low;
         ifc.close = close;
         ifc.volume = (double)volume;
         ifc.isIFC = true;
         ifc.isBullish = (close > open);
         
         int size = ArraySize(g_IFCs);
         ArrayResize(g_IFCs, size + 1);
         g_IFCs[size] = ifc;
         
         Print("🏦 Institutional Funding Candle detected at ", TimeToString(ifc.time), 
               " | ", (ifc.isBullish ? "BULLISH" : "BEARISH"));
      }
   }
}

//==================== NEWS FILTER ===================================
bool IsNewsTime() {
   if(!EnableNewsFilter) return false;
   
   // Simple news filter - avoid trading during typical news times
   // High impact news usually at: 8:30, 10:00, 14:00, 15:30 GMT
   
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   int newsHours[] = {8, 10, 14, 15};
   int newsMinutes[] = {30, 0, 0, 30};
   
   for(int i = 0; i < 4; i++) {
      int timeDiffMinutes = MathAbs((dt.hour * 60 + dt.min) - 
                                    (newsHours[i] * 60 + newsMinutes[i]));
      
      if(timeDiffMinutes <= MinutesBeforeNews || timeDiffMinutes <= MinutesAfterNews) {
         if(!TradeHighImpact) {
            Print("📰 News Time - Trading Paused");
            return true;
         }
      }
   }
   
   return false;
}

//==================== TRADING HUB JUKA METHOD =======================
void AnalyzeWithTradingHubJuka() {
   if(!UseTradingHubJuka) return;
   
   // Trading Hub Juka Method:
   // 1. Identify HTF trend (H4, D1, W1)
   // 2. Wait for multi-timeframe alignment
   // 3. Enter on LTF with HTF confirmation
   // 4. Use smart entry techniques (FVG, OB, POI)
   
   Print("═══════════════════════════════════════");
   Print("🎯 TRADING HUB JUKA METHOD ANALYSIS");
   Print("═══════════════════════════════════════");
   
   // Step 1: HTF Trend Analysis
   AnalyzeMarketStructure(PERIOD_D1, MS_HTF[0]);
   AnalyzeMarketStructure(PERIOD_H4, MS_HTF[1]);
   AnalyzeMarketStructure(PERIOD_H1, MS_HTF[2]);
   
   bool d1Bullish = (MS_HTF[0].trend == TREND_BULLISH);
   bool h4Bullish = (MS_HTF[1].trend == TREND_BULLISH);
   bool h1Bullish = (MS_HTF[2].trend == TREND_BULLISH);
   
   bool d1Bearish = (MS_HTF[0].trend == TREND_BEARISH);
   bool h4Bearish = (MS_HTF[1].trend == TREND_BEARISH);
   bool h1Bearish = (MS_HTF[2].trend == TREND_BEARISH);
   
   // Step 2: Count aligned timeframes
   int alignedBullish = 0;
   int alignedBearish = 0;
   
   if(d1Bullish) alignedBullish++;
   if(h4Bullish) alignedBullish++;
   if(h1Bullish) alignedBullish++;
   
   if(d1Bearish) alignedBearish++;
   if(h4Bearish) alignedBearish++;
   if(h1Bearish) alignedBearish++;
   
   g_JukaAnalysis.alignedTimeframes = MathMax(alignedBullish, alignedBearish);
   g_JukaAnalysis.htfBullish = (alignedBullish >= Juka_MinAlignedTFs);
   g_JukaAnalysis.htfBearish = (alignedBearish >= Juka_MinAlignedTFs);
   
   // Step 3: Calculate trend strength
   double strengthScore = 0;
   
   if(MS_HTF[0].bosDetected) strengthScore += 30;
   if(MS_HTF[1].bosDetected) strengthScore += 20;
   if(MS_HTF[0].bias == BIAS_STRONG_BULLISH || MS_HTF[0].bias == BIAS_STRONG_BEARISH) 
      strengthScore += 25;
   
   // Add FVG alignment
   int validFVGs = 0;
   for(int i = 0; i < ArraySize(g_FVGs); i++) {
      if(!g_FVGs[i].filled && g_FVGs[i].barAge < 20) validFVGs++;
   }
   if(validFVGs > 0) strengthScore += 10;
   
   // Add Order Block alignment
   int validOBs = 0;
   for(int i = 0; i < ArraySize(g_OrderBlocks); i++) {
      if(g_OrderBlocks[i].valid && !g_OrderBlocks[i].touched) validOBs++;
   }
   if(validOBs > 0) strengthScore += 15;
   
   g_JukaAnalysis.trendStrength = strengthScore;
   
   // Step 4: Determine if ready for entry
   bool hasAlignment = (g_JukaAnalysis.alignedTimeframes >= Juka_MinAlignedTFs);
   bool strongTrend = (strengthScore >= 50);
   
   if(Juka_RequireAlignment && !hasAlignment) {
      g_JukaAnalysis.readyForEntry = false;
      g_JukaAnalysis.setupQuality = "WEAK - Insufficient Alignment";
   } else if(strongTrend && hasAlignment) {
      g_JukaAnalysis.readyForEntry = true;
      g_JukaAnalysis.setupQuality = "EXCELLENT - Strong Multi-TF Alignment";
   } else if(hasAlignment) {
      g_JukaAnalysis.readyForEntry = true;
      g_JukaAnalysis.setupQuality = "GOOD - Aligned but Moderate Strength";
   } else {
      g_JukaAnalysis.readyForEntry = false;
      g_JukaAnalysis.setupQuality = "FAIR - Weak Setup";
   }
   
   // Print analysis
   Print("D1 Trend: ", (d1Bullish ? "BULLISH" : d1Bearish ? "BEARISH" : "RANGING"));
   Print("H4 Trend: ", (h4Bullish ? "BULLISH" : h4Bearish ? "BEARISH" : "RANGING"));
   Print("H1 Trend: ", (h1Bullish ? "BULLISH" : h1Bearish ? "BEARISH" : "RANGING"));
   Print("Aligned TFs: ", g_JukaAnalysis.alignedTimeframes, "/3");
   Print("Trend Strength: ", DoubleToString(g_JukaAnalysis.trendStrength, 1), "%");
   Print("Setup Quality: ", g_JukaAnalysis.setupQuality);
   Print("Ready for Entry: ", (g_JukaAnalysis.readyForEntry ? "YES ✅" : "NO ❌"));
   Print("═══════════════════════════════════════");
}

bool ValidateJukaEntry(bool isBuy) {
   if(!UseTradingHubJuka) return true;
   
   // Juka Method Entry Validation
   if(!g_JukaAnalysis.readyForEntry) {
      Print("⚠️ Juka Method: Setup not ready");
      return false;
   }
   
   if(Juka_UseHTF_Confirmation) {
      bool htfAligned = (isBuy && g_JukaAnalysis.htfBullish) || 
                        (!isBuy && g_JukaAnalysis.htfBearish);
      
      if(!htfAligned) {
         Print("⚠️ Juka Method: HTF not aligned with trade direction");
         return false;
      }
   }
   
   if(Juka_UseSmartEntry) {
      // Must be at a smart entry point (FVG or OB)
      bool atSmartEntry = false;
      
      // Check FVG
      for(int i = 0; i < ArraySize(g_FVGs); i++) {
         if(g_FVGs[i].filled || g_FVGs[i].isBullish != isBuy) continue;
         
         double currentPrice = isBuy ? 
            SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
            SymbolInfoDouble(_Symbol, SYMBOL_BID);
         
         if(currentPrice >= g_FVGs[i].bottomPrice && 
            currentPrice <= g_FVGs[i].topPrice) {
            atSmartEntry = true;
            break;
         }
      }
      
      // Check Order Block
      if(!atSmartEntry) {
         for(int i = 0; i < ArraySize(g_OrderBlocks); i++) {
            if(!g_OrderBlocks[i].valid || g_OrderBlocks[i].isBullish != isBuy) continue;
            
            double currentPrice = isBuy ? 
               SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
               SymbolInfoDouble(_Symbol, SYMBOL_BID);
            
            if(currentPrice >= g_OrderBlocks[i].lowPrice && 
               currentPrice <= g_OrderBlocks[i].highPrice) {
               atSmartEntry = true;
               break;
            }
         }
      }
      
      if(!atSmartEntry) {
         Print("⚠️ Juka Method: Not at smart entry point (FVG/OB)");
         return false;
      }
   }
   
   Print("✅ Juka Method: All validations passed");
   return true;
}

// [Continue with remaining functions from original code...]
// Copy all remaining functions from the original file starting from:
// - DetectTrendLines
// - CheckTrendLineBreakout
// - DetectSupportResistance
// - Pattern Detection functions
// - Fibonacci functions
// - SMT Divergence
// - POI Models
// - Sniper Entry
// - Volatility Filters
// - Time Filters
// - Daily Bias
// - Signal Generation
// - Trade Execution
// - Trade Management
// - OnTick function

