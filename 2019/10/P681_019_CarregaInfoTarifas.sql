DECLARE

  -- Buscar todas as tarifas a serem ajustadas
  CURSOR cr_craptar IS
    SELECT DISTINCT t.cdtarifa
      FROM craptar r
         , crapfvl t
     WHERE r.cdtarifa = t.cdtarifa 
       AND (t.cdhistor IN (1347,1348,1349,1350,1355,1356,1357,1358,2431,2432,1359,1360,1795
                          ,1798,1941,1944,1942,1945,1943,1946,1361,1362,1742,1760,1744,1932
                          ,1746,1933,1748,1936,2041,2042,2043,2044,2045,2046,2428,2072,2073
                          ,2200,2202,2204,2206,2211,2212,2213,2214,2609,2615,2610,2616,2611
                          ,2617,2612,2618,2613,2619,2695,2696,890,2015)
        OR t.cdhisest IN (1347,1348,1349,1350,1355,1356,1357,1358,2431,2432,1359,1360,1795
                          ,1798,1941,1944,1942,1945,1943,1946,1361,1362,1742,1760,1744,1932
                          ,1746,1933,1748,1936,2041,2042,2043,2044,2045,2046,2428,2072,2073
                          ,2200,2202,2204,2206,2211,2212,2213,2214,2609,2615,2610,2616,2611
                          ,2617,2612,2618,2613,2619,2695,2696,890,2015));
  
  -- Buscar os registros da FVL a serem atualizado
  CURSOR cr_crapfvl(pr_cdtarifa IN NUMBER) IS
    SELECT t.cdhistor
         , t.cdhisest
         , t.cdfaixav
         , ROWID dsrowid
         , t.cdhistep
         , t.cdhestep
      FROM crapfvl t
     WHERE t.cdtarifa = pr_cdtarifa;
  
  TYPE tp_tbdepara IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  vr_tbdepara tp_tbdepara;
  
BEGIN
  
  -- Configura o DE-PARA
  vr_tbdepara(890)  := 3061;
  vr_tbdepara(1347) := 3065;
  vr_tbdepara(1348) := 3066;
  vr_tbdepara(1349) := 3071;
  vr_tbdepara(1350) := 3072;
  vr_tbdepara(1355) := 3083;
  vr_tbdepara(1356) := 3084;
  vr_tbdepara(1357) := 3112;
  vr_tbdepara(1358) := 3113;
  vr_tbdepara(2431) := 3114;
  vr_tbdepara(2432) := 3115;
  vr_tbdepara(1359) := 3116;
  vr_tbdepara(1360) := 3117;
  vr_tbdepara(1795) := 3121;
  vr_tbdepara(1798) := 3122;
  vr_tbdepara(1941) := 3127;
  vr_tbdepara(1944) := 3128;
  vr_tbdepara(1942) := 3129;
  vr_tbdepara(1945) := 3130;
  vr_tbdepara(1943) := 3131;
  vr_tbdepara(1946) := 3132;
  vr_tbdepara(1361) := 3134;
  vr_tbdepara(1362) := 3135;
  vr_tbdepara(1742) := 3142;
  vr_tbdepara(1760) := 3143;
  vr_tbdepara(1744) := 3144;
  vr_tbdepara(1932) := 3145;
  vr_tbdepara(1746) := 3146;
  vr_tbdepara(1933) := 3147;
  vr_tbdepara(1748) := 3148;
  vr_tbdepara(1936) := 3149;
  vr_tbdepara(2015) := 3062;
  vr_tbdepara(2041) := 3150;
  vr_tbdepara(2042) := 3151;
  vr_tbdepara(2043) := 3152;
  vr_tbdepara(2044) := 3153;
  vr_tbdepara(2045) := 3154;
  vr_tbdepara(2046) := 3155;
  vr_tbdepara(2428) := 3158;
  vr_tbdepara(2072) := 3159;
  vr_tbdepara(2073) := 3160;
  vr_tbdepara(2200) := 3161;
  vr_tbdepara(2202) := 3162;
  vr_tbdepara(2204) := 3163;
  vr_tbdepara(2206) := 3164;
  vr_tbdepara(2211) := 3165;
  vr_tbdepara(2212) := 3166;
  vr_tbdepara(2213) := 3167;
  vr_tbdepara(2214) := 3168;
  vr_tbdepara(2609) := 3169;
  vr_tbdepara(2615) := 3170;
  vr_tbdepara(2610) := 3171;
  vr_tbdepara(2616) := 3172;
  vr_tbdepara(2611) := 3173;
  vr_tbdepara(2617) := 3174;
  vr_tbdepara(2612) := 3175;
  vr_tbdepara(2618) := 3176;
  vr_tbdepara(2613) := 3177;
  vr_tbdepara(2619) := 3178;
  vr_tbdepara(2695) := 3181;
  vr_tbdepara(2696) := 3182;

  -- Percorrer todas as tarifas que precisarão ser ajustadas
  FOR reg IN cr_craptar LOOP
    
    -- Setar o flag de configuração exclusiva para ente público
    UPDATE craptar t 
       SET t.flgcnfep = 1 -- Sim
     WHERE t.cdtarifa = reg.cdtarifa;
    
    -- Atribuir os históricos do Ente Público conforme DE-PARA
    FOR fvl IN cr_crapfvl(reg.cdtarifa) LOOP
      
      -- Verificar se existe o histórico no DE-PARA
      IF NOT vr_tbdepara.EXISTS(fvl.cdhistor) THEN
        dbms_output.put_line(reg.cdtarifa||' - Histórico lançamento sem de-para: '||fvl.cdhistor); 
        CONTINUE;
      END IF;
      
      IF NOT vr_tbdepara.EXISTS(fvl.cdhisest) THEN
        dbms_output.put_line(reg.cdtarifa||' - Histórico estorno sem de-para: '||fvl.cdhisest); 
        CONTINUE;
      END IF;
      
      fvl.cdhistep := vr_tbdepara(fvl.cdhistor);
      fvl.cdhestep := vr_tbdepara(fvl.cdhisest);
      
      -- Atualizar os históricos do registro
      UPDATE crapfvl 
         SET cdhistep = fvl.cdhistep
           , cdhestep = fvl.cdhestep
       WHERE ROWID = fvl.dsrowid;
    
      -- Atualizar os valores da tarifa
      UPDATE crapfco t
         SET t.vltariep = t.vltarifa
           , t.vlrepaep = t.vlrepass
           , t.vlpertep = t.vlpertar
           , t.vlmintep = t.vlmintar
           , t.vlmaxtep = t.vlmaxtar
       WHERE t.cdfaixav = fvl.cdfaixav;
    
    END LOOP;
    
  END LOOP;
  
  COMMIT;
  
END;
  
