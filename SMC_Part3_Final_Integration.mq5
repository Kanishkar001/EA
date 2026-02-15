//+------------------------------------------------------------------+
//|              SMC Master Pro EA v3.0 - Part 3 (Final Integration) |
//|          Complete Signal Generation with All 27 SMC Concepts     |
//+------------------------------------------------------------------+

// Add remaining functions from original code first, then enhanced signal generation

//==================== ENHANCED SIGNAL GENERATION WITH ALL CONCEPTS ==
TradeSignal GenerateEnhancedSignal(ENUM_TIMEFRAMES analysisTF, ENUM_TIMEFRAMES tradeTF) {
   TradeSignal signal;
   signal.valid = false;
   signal.confidence = 0;
   signal.reason = "";
   signal.signalTime = TimeCurrent();
   signal.timeframeAlignment = 0;
   
   Print("╔════════════════════════════════════════════╗");
   Print("║   COMPLETE SMC ANALYSIS - 27 CONCEPTS      ║");
   Print("╚════════════════════════════════════════════╝");
   
   // ========== CONCEPT 1-7: MARKET STRUCTURE ANALYSIS ==========
   Print("📊 Analyzing Market Structure...");
   AnalyzeMarketStructure(analysisTF, MS_HTF[0]);
   DetectFairValueGaps(analysisTF);
   DetectOrderBlocks(analysisTF);
   DetectLiquidityZones(analysisTF);
   DetectSupplyDemandZones(analysisTF);
   DetectTrendLines(analysisTF, MS_HTF[0]);
   DetectSupportResistance(analysisTF);
   
   // ========== CONCEPT 8-14: ADVANCED PATTERNS ==========
   Print("📈 Detecting Patterns...");
   DetectChannels(analysisTF);
   DetectImpulseCorrection(analysisTF);
   AnalyzeOrderFlow(analysisTF);
   DetectInstitutionalCandles(analysisTF);
   DetectSessionLiquidity();
   
   // ========== CONCEPT 15-21: ADDITIONAL ANALYSIS ==========
   Print("🔍 Additional Analysis...");
   bool hasQML = false;
   bool hasDoublePattern = false;
   bool hasTriangle = DetectSymmetricTriangle(analysisTF);
   
   // ========== CONCEPT 22-27: FINAL VALIDATIONS ==========
   Print("✅ Running Final Validations...");
   bool newsFilterPass = !IsNewsTime();
   if(!newsFilterPass) {
      Print("❌ News Filter: Trading paused");
      return signal;
   }
   
   // ========== TRADING HUB JUKA METHOD ==========
   if(UseTradingHubJuka) {
      Print("🎯 Running Trading Hub Juka Analysis...");
      AnalyzeWithTradingHubJuka();
   }
   
   // ========== DETERMINE TRADE DIRECTION ==========
   bool isBuy = false;
   int directionScore = 0;
   
   // Multi-timeframe bias
   if(g_GlobalBias == BIAS_STRONG_BULLISH) directionScore += 40;
   else if(g_GlobalBias == BIAS_BULLISH) directionScore += 25;
   else if(g_GlobalBias == BIAS_STRONG_BEARISH) directionScore -= 40;
   else if(g_GlobalBias == BIAS_BEARISH) directionScore -= 25;
   
   // Juka Method alignment
   if(UseTradingHubJuka && g_JukaAnalysis.readyForEntry) {
      if(g_JukaAnalysis.htfBullish) directionScore += 30;
      if(g_JukaAnalysis.htfBearish) directionScore -= 30;
   }
   
   // Market structure
   if(MS_HTF[0].trend == TREND_BULLISH) directionScore += 20;
   else if(MS_HTF[0].trend == TREND_BEARISH) directionScore -= 20;
   
   // Order Flow
   if(UseOrderFlow) {
      if(g_OrderFlow.bullishFlow) directionScore += 15;
      else directionScore -= 15;
   }
   
   // Determine direction
   if(directionScore >= 30) {
      isBuy = true;
   } else if(directionScore <= -30) {
      isBuy = false;
   } else {
      Print("⚠️ Neutral Bias - No clear direction");
      return signal;
   }
   
   signal.isBuy = isBuy;
   
   // ========== VALIDATE WITH JUKA METHOD ==========
   if(UseTradingHubJuka && !ValidateJukaEntry(isBuy)) {
      Print("❌ Failed Juka Method validation");
      return signal;
   }
   
   // ========== COLLECT CONFIRMATIONS (ALL 27 CONCEPTS) ==========
   int confirmations = 0;
   string reasons = "";
   
   // 1. MARKET STRUCTURE (HH, HL, LL, LH)
   if(isBuy && (MS_HTF[0].lastStructure == STRUCTURE_HH || MS_HTF[0].lastStructure == STRUCTURE_HL)) {
      confirmations += 15;
      reasons += "Bullish Structure (HH/HL) | ";
      signal.timeframeAlignment++;
   } else if(!isBuy && (MS_HTF[0].lastStructure == STRUCTURE_LL || MS_HTF[0].lastStructure == STRUCTURE_LH)) {
      confirmations += 15;
      reasons += "Bearish Structure (LL/LH) | ";
      signal.timeframeAlignment++;
   }
   
   // 2. BOS (Break of Structure)
   if(UseBOS && MS_HTF[0].bosDetected) {
      confirmations += 12;
      reasons += "BOS Confirmed | ";
   }
   
   // 3. CHoCH (Change of Character)
   if(UseCHoCH && MS_HTF[0].chochDetected) {
      confirmations += 10;
      reasons += "CHoCH Detected | ";
   }
   
   // 4. INDUCEMENT
   if(UseInducementZones && MS_HTF[0].inducementDetected) {
      confirmations += 8;
      reasons += "Inducement Zone | ";
   }
   
   // 5. FVG (Fair Value Gap)
   bool inFVG = false;
   int fvgQuality = 0;
   for(int i = 0; i < ArraySize(g_FVGs); i++) {
      if(g_FVGs[i].filled || g_FVGs[i].isBullish != isBuy) continue;
      
      double currentPrice = isBuy ? 
         SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
         SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(currentPrice >= g_FVGs[i].bottomPrice && 
         currentPrice <= g_FVGs[i].topPrice) {
         inFVG = true;
         
         // Quality based on fill percentage
         if(g_FVGs[i].fillPercent >= (FVGFillPercent - 10) && 
            g_FVGs[i].fillPercent <= (FVGFillPercent + 10)) {
            fvgQuality = 15;
            reasons += "Optimal FVG Entry | ";
         } else {
            fvgQuality = 8;
            reasons += "FVG Entry | ";
         }
         break;
      }
   }
   confirmations += fvgQuality;
   
   if(RequireFVGForEntry && !inFVG) {
      Print("❌ FVG required but not present");
      return signal;
   }
   
   // 6. ORDER BLOCK
   bool atOB = false;
   int obQuality = 0;
   for(int i = 0; i < ArraySize(g_OrderBlocks); i++) {
      if(!g_OrderBlocks[i].valid || g_OrderBlocks[i].touched) continue;
      if(g_OrderBlocks[i].isBullish != isBuy) continue;
      
      double currentPrice = isBuy ? 
         SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
         SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(currentPrice >= g_OrderBlocks[i].lowPrice && 
         currentPrice <= g_OrderBlocks[i].highPrice) {
         atOB = true;
         obQuality = MathMin(g_OrderBlocks[i].strength / 2, 15);
         reasons += "Order Block (" + IntegerToString(g_OrderBlocks[i].strength) + ") | ";
         g_OrderBlocks[i].touched = true;
         break;
      }
   }
   confirmations += obQuality;
   
   if(RequireOBForEntry && !atOB) {
      Print("❌ Order Block required but not present");
      return signal;
   }
   
   // 7. LIQUIDITY GRAB
   if(CheckLiquiditySweep(isBuy)) {
      confirmations += 12;
      reasons += "Liquidity Grabbed | ";
   }
   
   // 8. INSIDE CANDLE
   if(UseInsideCandle && IsInsideCandle(tradeTF)) {
      confirmations += 8;
      reasons += "Inside Candle | ";
   }
   
   // 9. CONSOLIDATION (avoid)
   if(IsMarketConsolidating(analysisTF)) {
      Print("❌ Market Consolidating");
      return signal;
   }
   
   // 10. TREND LINES
   if(CheckTrendLineBreakout(isBuy)) {
      confirmations += 10;
      reasons += "Trendline Break | ";
   }
   
   // 11. SUPPORT & RESISTANCE
   bool atSRLevel = false;
   for(int i = 0; i < ArraySize(g_SRLevels); i++) {
      double currentPrice = isBuy ? 
         SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
         SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(MathAbs(currentPrice - g_SRLevels[i].price) < PipsToPrice(5)) {
         if((isBuy && g_SRLevels[i].isSupport) || (!isBuy && !g_SRLevels[i].isSupport)) {
            confirmations += (int)(g_SRLevels[i].strength / 2);
            reasons += "S/R Level | ";
            atSRLevel = true;
            break;
         }
      }
   }
   
   // 12. SUPPLY & DEMAND
   bool atSDZone = false;
   for(int i = 0; i < ArraySize(g_SDZones); i++) {
      if(!g_SDZones[i].valid) continue;
      
      double currentPrice = isBuy ? 
         SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
         SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(currentPrice >= g_SDZones[i].bottomPrice && 
         currentPrice <= g_SDZones[i].topPrice) {
         
         if((isBuy && !g_SDZones[i].isSupply) || (!isBuy && g_SDZones[i].isSupply)) {
            confirmations += 12;
            reasons += "Supply/Demand Zone | ";
            atSDZone = true;
            break;
         }
      }
   }
   
   // 13. POI (Point of Interest) Models
   if(CheckPOI_Model1(analysisTF, tradeTF, isBuy)) {
      confirmations += 12;
      reasons += "POI Model 1 | ";
   }
   
   if(CheckPOI_Model2(analysisTF, tradeTF, isBuy)) {
      confirmations += 12;
      reasons += "POI Model 2 | ";
   }
   
   // 14. SMT (Smart Money Tool/Trap)
   if(CheckSMTDivergence(isBuy)) {
      confirmations += 10;
      reasons += "SMT Divergence | ";
   }
   
   // 15. IMPULSE & CORRECTION
   if(UseImpulseCorrection && ArraySize(g_Corrections) > 0) {
      CorrectionWave lastCorrection = g_Corrections[0];
      
      // Look for entries at 50-61.8% retracement
      if(lastCorrection.correctionPercent >= 50 && lastCorrection.correctionPercent <= 61.8) {
         confirmations += 10;
         reasons += "Fib Correction (" + DoubleToString(lastCorrection.correctionPercent, 1) + "%) | ";
      }
   }
   
   // 16. CORRELATED PAIR
   if(UseCorrelation && CorrelatedPair != "") {
      // Check if correlated pair confirms direction
      double corrClose = iClose(CorrelatedPair, analysisTF, 0);
      double corrPrevClose = iClose(CorrelatedPair, analysisTF, 1);
      
      bool corrBullish = (corrClose > corrPrevClose);
      
      if((isBuy && corrBullish) || (!isBuy && !corrBullish)) {
         confirmations += 8;
         reasons += "Correlation Confirmed | ";
      }
   }
   
   // 17. QML PATTERN
   if(DetectQMLPattern(analysisTF, isBuy)) {
      confirmations += 15;
      reasons += "QML Pattern | ";
      hasQML = true;
   }
   
   // 18. DOUBLE TOP/BOTTOM
   if(isBuy && DetectDoubleBottom(analysisTF)) {
      confirmations += 12;
      reasons += "Double Bottom | ";
      hasDoublePattern = true;
   } else if(!isBuy && DetectDoubleTop(analysisTF)) {
      confirmations += 12;
      reasons += "Double Top | ";
      hasDoublePattern = true;
   }
   
   // 19. CHANNEL
   if(UseChannels && ArraySize(g_Channels) > 0) {
      // Check if price is at channel boundary
      for(int i = 0; i < ArraySize(g_Channels); i++) {
         if(!g_Channels[i].valid) continue;
         
         double currentPrice = isBuy ? 
            SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
            SymbolInfoDouble(_Symbol, SYMBOL_BID);
         
         // Calculate current channel levels
         TrendLine upper = g_Channels[i].upperLine;
         TrendLine lower = g_Channels[i].lowerLine;
         
         double upperSlope = (upper.end_price - upper.start_price) / (upper.end_time - upper.start_time);
         double lowerSlope = (lower.end_price - lower.start_price) / (lower.end_time - lower.start_time);
         
         double currentUpper = upper.end_price + upperSlope * (TimeCurrent() - upper.end_time);
         double currentLower = lower.end_price + lowerSlope * (TimeCurrent() - lower.end_time);
         
         // Buy at lower channel, Sell at upper channel
         if(isBuy && MathAbs(currentPrice - currentLower) < PipsToPrice(5)) {
            confirmations += 10;
            reasons += "Channel Support | ";
            break;
         } else if(!isBuy && MathAbs(currentPrice - currentUpper) < PipsToPrice(5)) {
            confirmations += 10;
            reasons += "Channel Resistance | ";
            break;
         }
      }
   }
   
   // 20. SYMMETRIC TRIANGLE
   if(hasTriangle) {
      confirmations += 8;
      reasons += "Symmetric Triangle | ";
   }
   
   // 21. FIBONACCI LEVELS
   if(UseFibonacci && ArraySize(g_SwingHighs) > 0 && ArraySize(g_SwingLows) > 0) {
      double recentHigh = g_SwingHighs[0].price;
      double recentLow = g_SwingLows[0].price;
      
      if(IsAtFibLevel(isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                             SymbolInfoDouble(_Symbol, SYMBOL_BID), 
                      recentHigh, recentLow)) {
         confirmations += 10;
         reasons += "Fib Level | ";
      }
   }
   
   // 22. SNIPER ENTRY
   if(SniperEntryCheck(tradeTF, isBuy)) {
      confirmations += 12;
      reasons += "Sniper Entry | ";
   }
   
   // 23. LIQUIDITY SWIPE
   if(DetectLiquiditySwipe(tradeTF, isBuy)) {
      confirmations += 10;
      reasons += "Liquidity Swipe | ";
   }
   
   // 24. SESSION LIQUIDITY
   if(UseSessionLiquidity) {
      for(int i = 0; i < ArraySize(g_SessionData); i++) {
         double currentPrice = isBuy ? 
            SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
            SymbolInfoDouble(_Symbol, SYMBOL_BID);
         
         if(isBuy && !g_SessionData[i].lowSwept && 
            currentPrice <= g_SessionData[i].sessionLow + PipsToPrice(5)) {
            confirmations += 8;
            reasons += "Session Low Sweep | ";
            g_SessionData[i].lowSwept = true;
            break;
         } else if(!isBuy && !g_SessionData[i].highSwept && 
                   currentPrice >= g_SessionData[i].sessionHigh - PipsToPrice(5)) {
            confirmations += 8;
            reasons += "Session High Sweep | ";
            g_SessionData[i].highSwept = true;
            break;
         }
      }
   }
   
   // 25. ORDER FLOW
   if(UseOrderFlow) {
      if((isBuy && g_OrderFlow.bullishFlow) || (!isBuy && !g_OrderFlow.bullishFlow)) {
         confirmations += (int)(MathAbs(g_OrderFlow.imbalance) / 2);
         reasons += "Order Flow (" + DoubleToString(g_OrderFlow.imbalance, 1) + "%) | ";
      }
   }
   
   // 26. REVERSAL CANDLES
   if(isBuy && IsBullishReversalCandle(tradeTF)) {
      confirmations += 10;
      reasons += "Bullish Reversal | ";
   } else if(!isBuy && IsBearishReversalCandle(tradeTF)) {
      confirmations += 10;
      reasons += "Bearish Reversal | ";
   }
   
   // 27. IFC (Institutional Funding Candle)
   if(UseIFC && ArraySize(g_IFCs) > 0) {
      InstitutionalCandle lastIFC = g_IFCs[0];
      
      if((isBuy && lastIFC.isBullish) || (!isBuy && !lastIFC.isBullish)) {
         confirmations += 12;
         reasons += "IFC Confirmed | ";
      }
   }
   
   // ========== TRADING HUB JUKA BONUS ==========
   if(UseTradingHubJuka && g_JukaAnalysis.readyForEntry) {
      confirmations += (int)(g_JukaAnalysis.trendStrength / 5);
      reasons += "Juka Method (" + g_JukaAnalysis.setupQuality + ") | ";
   }
   
   // ========== VOLATILITY & FILTERS ==========
   if(!CheckVolatilityFilter(analysisTF)) {
      Print("❌ Volatility Filter Failed");
      return signal;
   }
   
   if(!IsWithinTradingHours()) {
      Print("❌ Outside Trading Hours");
      return signal;
   }
   
   if(!IsValidSession()) {
      Print("❌ Invalid Session");
      return signal;
   }
   
   // ========== MINIMUM CONFIDENCE CHECK ==========
   int minConfidence = 45;
   if(UseTradingHubJuka && Juka_RequireAlignment) {
      minConfidence = 55; // Higher standard with Juka
   }
   
   if(confirmations < minConfidence) {
      Print("⚠️ Low Confidence: ", confirmations, "% (Min: ", minConfidence, "%)");
      return signal;
   }
   
   // ========== CALCULATE ENTRY PARAMETERS ==========
   double currentPrice = isBuy ? 
      SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
      SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   signal.entryPrice = currentPrice;
   
   // Smart Stop Loss Placement
   double slDistance = 0;
   
   if(isBuy) {
      double nearestLow = 999999;
      
      // Use swing low
      if(ArraySize(g_SwingLows) > 0) {
         nearestLow = g_SwingLows[0].price;
      }
      
      // Use order block low if closer
      if(atOB) {
         for(int i = 0; i < ArraySize(g_OrderBlocks); i++) {
            if(g_OrderBlocks[i].valid && g_OrderBlocks[i].isBullish) {
               nearestLow = MathMin(nearestLow, g_OrderBlocks[i].lowPrice);
               break;
            }
         }
      }
      
      // Use demand zone if present
      if(atSDZone) {
         for(int i = 0; i < ArraySize(g_SDZones); i++) {
            if(g_SDZones[i].valid && !g_SDZones[i].isSupply) {
               nearestLow = MathMin(nearestLow, g_SDZones[i].bottomPrice);
               break;
            }
         }
      }
      
      if(nearestLow < 999999) {
         slDistance = signal.entryPrice - nearestLow - PipsToPrice(5);
      }
   } else {
      double nearestHigh = 0;
      
      // Use swing high
      if(ArraySize(g_SwingHighs) > 0) {
         nearestHigh = g_SwingHighs[0].price;
      }
      
      // Use order block high if closer
      if(atOB) {
         for(int i = 0; i < ArraySize(g_OrderBlocks); i++) {
            if(g_OrderBlocks[i].valid && !g_OrderBlocks[i].isBullish) {
               nearestHigh = MathMax(nearestHigh, g_OrderBlocks[i].highPrice);
               break;
            }
         }
      }
      
      // Use supply zone if present
      if(atSDZone) {
         for(int i = 0; i < ArraySize(g_SDZones); i++) {
            if(g_SDZones[i].valid && g_SDZones[i].isSupply) {
               nearestHigh = MathMax(nearestHigh, g_SDZones[i].topPrice);
               break;
            }
         }
      }
      
      if(nearestHigh > 0) {
         slDistance = nearestHigh - signal.entryPrice + PipsToPrice(5);
      }
   }
   
   // Validate SL
   double minSL = PipsToPrice(DefaultSLPips * 0.5);
   double maxSL = PipsToPrice(DefaultSLPips * 2);
   
   if(slDistance < minSL || slDistance > maxSL || slDistance == 0) {
      slDistance = PipsToPrice(DefaultSLPips);
   }
   
   signal.stopLoss = isBuy ? 
      signal.entryPrice - slDistance : 
      signal.entryPrice + slDistance;
   
   // Calculate TP
   signal.takeProfit = isBuy ? 
      signal.entryPrice + (slDistance * DefaultRR) : 
      signal.entryPrice - (slDistance * DefaultRR);
   
   signal.confidence = confirmations;
   signal.reason = reasons;
   signal.valid = true;
   
   // ========== FINAL SIGNAL REPORT ==========
   Print("╔════════════════════════════════════════════╗");
   Print("║     ✅ VALID TRADE SIGNAL GENERATED       ║");
   Print("╚════════════════════════════════════════════╝");
   Print("Direction: ", (isBuy ? "🟢 BUY" : "🔴 SELL"));
   Print("Entry: ", signal.entryPrice);
   Print("SL: ", signal.stopLoss, " (", DoubleToString(PriceToPips(slDistance), 1), " pips)");
   Print("TP: ", signal.takeProfit, " (R:", DefaultRR, ")");
   Print("Confidence: ", confirmations, "%");
   Print("TF Alignment: ", signal.timeframeAlignment);
   Print("Concepts Used: ", reasons);
   Print("╚════════════════════════════════════════════╝");
   
   return signal;
}

//==================== ENHANCED ONTICK WITH ALL CONCEPTS =============
void OnTick() {
   ResetDailyStats();
   UpdateDailyStats();
   
   if(!TradingEnabled) return;
   if(!CheckRiskLimits()) return;
   
   ManageOpenTrades();
   
   if(PositionSelect(_Symbol)) return;
   if((TimeCurrent() - g_LastTradeTime) < 120) return;
   
   // Calculate daily bias and run Juka analysis
   static datetime lastAnalysis = 0;
   if(TimeCurrent() - lastAnalysis >= 3600) {
      CalculateDailyBias();
      if(UseTradingHubJuka) {
         AnalyzeWithTradingHubJuka();
      }
      lastAnalysis = TimeCurrent();
   }
   
   // Generate signals using enhanced method with all 27 concepts
   TradeSignal signal;
   
   if(TradeOnM1 && IsNewBar(PERIOD_M1)) {
      signal = GenerateEnhancedSignal(AnalysisTF1, TradeTF1);
      if(signal.valid && signal.confidence >= 50) {
         if(ExecuteTrade(signal)) return;
      }
   }
   
   if(IsNewBar(PERIOD_M5)) {
      signal = GenerateEnhancedSignal(AnalysisTF2, TradeTF2);
      if(signal.valid && signal.confidence >= 55) {
         if(ExecuteTrade(signal)) return;
      }
   }
   
   if(IsNewBar(PERIOD_M15)) {
      signal = GenerateEnhancedSignal(AnalysisTF3, TradeTF3);
      if(signal.valid && signal.confidence >= 60) {
         if(ExecuteTrade(signal)) return;
      }
   }
   
   if(IsNewBar(PERIOD_H1)) {
      signal = GenerateEnhancedSignal(AnalysisTF4, TradeTF4);
      if(signal.valid && signal.confidence >= 65) {
         if(ExecuteTrade(signal)) return;
      }
   }
   
   if(IsNewBar(PERIOD_H4)) {
      signal = GenerateEnhancedSignal(AnalysisTF5, TradeTF5);
      if(signal.valid && signal.confidence >= 70) {
         if(ExecuteTrade(signal)) return;
      }
   }
}

