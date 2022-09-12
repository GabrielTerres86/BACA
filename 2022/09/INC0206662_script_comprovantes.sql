DECLARE
  
  vr_dsinfor1     crappro.dsinform##1%TYPE;
  vr_dsinfor2     crappro.dsinform##1%TYPE;
  vr_dsinfor3     crappro.dsinform##1%TYPE;
  vr_dsprotoc     crappro.dsprotoc%TYPE;
  
  vr_dscritic     VARCHAR2(4000);
  vr_des_erro     VARCHAR2(4000);

  CURSOR cr_craplau IS
     SELECT lau.cdcooper,
            lau.nrdconta,
            lau.cdhistor,
            lau.nrdocmto,
            lau.vllanaut,
            lau.nrcpfope,
            lau.nrcpfpre,
            lau.nmprepos
       FROM cecred.craplau lau
      WHERE lau.cdcooper = 1
        AND lau.insitlau = 2
        AND lau.dsorigem = 'DEBAUT'
        AND lau.cdhistor = 3292
        AND lau.dtmvtopg = TO_DATE('16/08/2022', 'DD/MM/YYYY')
        AND lau.dtdebito = TO_DATE('16/08/2022', 'DD/MM/YYYY');
  rw_craplau cr_craplau%ROWTYPE;
  
  CURSOR cr_crapatr(pr_cdcooper IN crapatr.cdcooper%TYPE
                   ,pr_nrdconta IN crapatr.nrdconta%TYPE
                   ,pr_cdhistor IN crapatr.cdhistor%TYPE
                   ,pr_nrdocmto IN craplau.nrdocmto%TYPE) IS
    SELECT atr.cdrefere
          ,atr.cdempcon
          ,atr.cdsegmto
          ,atr.dshisext
      FROM cecred.crapatr atr
     WHERE atr.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
       AND atr.nrdconta = pr_nrdconta -- NUMERO DA CONTA
       AND atr.cdhistor = pr_cdhistor -- CODIGO DO HISTORICO
       AND atr.cdrefere = pr_nrdocmto; -- COD. REFERENCIA
  rw_crapatr cr_crapatr%ROWTYPE;
   
  CURSOR cr_crapcon(pr_cdcooper IN crapcon.cdcooper%TYPE
                   ,pr_cdempcon IN crapcon.cdempcon%TYPE
                   ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
       SELECT crapcon.nmextcon
         FROM cecred.crapcon
        WHERE crapcon.cdcooper = pr_cdcooper
          AND crapcon.cdempcon = pr_cdempcon
          AND crapcon.cdsegmto = pr_cdsegmto;
     rw_crapcon cr_crapcon%ROWTYPE;   

BEGIN   
   
    FOR rw_craplau IN cr_craplau LOOP
    
      OPEN cr_crapatr(pr_cdcooper => rw_craplau.cdcooper,
                      pr_nrdconta => rw_craplau.nrdconta,
                      pr_cdhistor => rw_craplau.cdhistor,
                      pr_nrdocmto => rw_craplau.nrdocmto);
      FETCH cr_crapatr INTO rw_crapatr;
      CLOSE cr_crapatr;
      
      OPEN cr_crapcon(pr_cdcooper => rw_craplau.cdcooper
                     ,pr_cdempcon => rw_crapatr.cdempcon
                     ,pr_cdsegmto => rw_crapatr.cdsegmto);
      FETCH cr_crapcon INTO rw_crapcon;
      CLOSE cr_crapcon;
      
      vr_dsinfor1 := 'Pagamento';
      vr_dsinfor2 := ' ';
      vr_dsinfor3 := 'Convênio: ' || rw_crapcon.nmextcon || '#Número Identificador:' ||
                     rw_crapatr.cdrefere || '#' || rw_crapatr.dshisext;
        
      GENE0006.pc_gera_protocolo(pr_cdcooper => rw_craplau.cdcooper
                                ,pr_dtmvtolt => TO_DATE('16/08/2022', 'DD/MM/YYYY')
                                ,pr_hrtransa => gene0002.fn_busca_time
                                ,pr_nrdconta => rw_craplau.nrdconta
                                ,pr_nrdocmto => rw_craplau.nrdocmto
                                ,pr_nrseqaut => 0
                                ,pr_vllanmto => rw_craplau.vllanaut
                                ,pr_nrdcaixa => 900
                                ,pr_gravapro => TRUE
                                ,pr_cdtippro => 15
                                ,pr_dsinfor1 => vr_dsinfor1
                                ,pr_dsinfor2 => vr_dsinfor2
                                ,pr_dsinfor3 => vr_dsinfor3
                                ,pr_dscedent => rw_crapcon.nmextcon
                                ,pr_flgagend => FALSE
                                ,pr_nrcpfope => rw_craplau.nrcpfope
                                ,pr_nrcpfpre => rw_craplau.nrcpfpre
                                ,pr_nmprepos => rw_craplau.nmprepos
                                ,pr_dsprotoc => vr_dsprotoc
                                ,pr_dscritic => vr_dscritic
                                ,pr_des_erro => vr_des_erro);
                                                               
      IF TRIM(vr_dscritic) IS NOT NULL THEN
         dbms_output.put_line(' Conta: ' || rw_craplau.nrdconta  || ' Critica: ' || vr_dscritic);
      END IF;
    
    END LOOP;
      
    COMMIT;
      
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLERRM);
END;
