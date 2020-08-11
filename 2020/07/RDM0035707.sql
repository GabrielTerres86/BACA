declare 

  vr_dtmvtolt    crapdat.dtmvtolt%TYPE;
  vr_incrineg    INTEGER;  
  vr_tab_retorno LANC0001.typ_reg_retorno;  
  vr_nrseqdig    craplcm.nrseqdig%TYPE;  
  vr_dscritic    crapcri.dscritic%TYPE;
  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_nmdcampo    VARCHAR2(400);
  vr_des_erro    VARCHAR2(400);
    
  vr_nrdolote   INTEGER;
  vr_busca      VARCHAR2(400);
  vr_nrdocmto   INTEGER;
 

  CURSOR cr_contas IS
     SELECT *
     FROM (
          SELECT ass.cdcooper cooperativa
               , ass.nrdconta conta
               , ASS.INPESSOA
               , ass.cdagenci
               , sld.vlsddisp saldo_deposito_a_vista
               , COTAS.SALDO_COTAS
            FROM crapsld sld
               , crapass ass
               , ( SELECT COT.CDCOOPER AS CDCOOPER
                        , COT.NRDCONTA AS NRDCONTA
                        , COT.Vldcotas  AS SALDO_COTAS
                     FROM crapcot COT
                    WHERE COT.vldcotas > 0  ) COTAS
           WHERE ass.cdcooper = sld.cdcooper(+)
             AND ass.nrdconta = sld.nrdconta(+)
             AND ass.dtdemiss IS NOT NULL
             AND sld.vlsddisp(+) > 0
             AND cotas.cdcooper(+) = ass.cdcooper
             AND cotas.nrdconta(+) = ass.nrdconta
             AND ass.cdcooper = 9
             AND ass.nrdconta IN ( 973, 1007, 56251 )
         ) DADOS
     WHERE ( SALDO_COTAS > 0
        OR saldo_deposito_a_vista > 0 )
    ORDER BY 1, 2;
  
  rw_contas cr_contas%ROWTYPE;
  
begin
  
  FOR rw_contas IN cr_contas LOOP
    
     SELECT dtmvtolt
       INTO vr_dtmvtolt
       FROM crapdat
      WHERE cdcooper = rw_contas.cooperativa;
      
     
     -- devolucao de deposito a vista
     IF RW_CONTAS.SALDO_DEPOSITO_A_VISTA > 0 THEN

         BEGIN
           
             INSERT INTO TBCOTAS_DEVOLUCAO(  CDCOOPER
                                           , NRDCONTA
                                           , TPDEVOLUCAO
                                           , VLCAPITAL
                                           , VLPAGO )
                                    VALUES ( RW_CONTAS.COOPERATIVA
                                           , RW_CONTAS.CONTA
                                           , 4
                                           , RW_CONTAS.SALDO_DEPOSITO_A_VISTA
                                           , 0 );
         EXCEPTION
           WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE( 'ERRO TBCOTAS_DEVOLUCAO DE DEPOSITO A VISTA - ' || RW_CONTAS.COOPERATIVA || '/' || RW_CONTAS.CONTA );
             continue;
         END;

      
        vr_nrdolote := 600041;
          
        vr_busca := TRIM(to_char(rw_contas.cooperativa)) || ';' ||
                    TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                    TRIM(to_char(rw_contas.cdagenci)) || ';' ||
                    '100;' || --cdbccxlt
                    vr_nrdolote;
                       
        vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', vr_busca);    
              
        vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_contas.cooperativa||';'||
                                                        to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                        rw_contas.cdagenci||
                                                        ';100;'|| --cdbccxlt
                                                        vr_nrdolote); 
          BEGIN
        
              LANC0001.pc_gerar_lancamento_conta( pr_dtmvtolt    => vr_dtmvtolt,
                                                  pr_cdagenci    => rw_contas.cdagenci,
                                                  pr_cdbccxlt    => 100,
                                                  pr_nrdolote    => vr_nrdolote,
                                                  pr_nrdconta    => rw_contas.conta,
                                                  pr_nrdocmto    => vr_nrdocmto,
                                                  pr_cdhistor    => CASE WHEN RW_CONTAS.INPESSOA = 2 THEN '2062' ELSE '2061' END,
                                                  pr_nrseqdig    => vr_nrseqdig,
                                                  pr_vllanmto    => RW_CONTAS.SALDO_DEPOSITO_A_VISTA,
                                                  pr_nrdctabb    => rw_contas.conta,
                                                 -- pr_cdpesqbb    => 'DEVOLUCAO DEPOSITO A VISTA',
                                                  pr_dtrefere    => vr_dtmvtolt,
                                                  pr_hrtransa    => gene0002.fn_busca_time,
                                                  pr_cdoperad    => 1,
                                                  pr_cdcooper    => rw_contas.cooperativa,
                                                  pr_cdorigem    => 5,
                                                  pr_incrineg    => vr_incrineg,
                                                  pr_tab_retorno => vr_tab_retorno,
                                                  pr_cdcritic    => vr_cdcritic,
                                                  pr_dscritic    => vr_dscritic);
          EXCEPTION
            WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE( 'ERRO LANCAMENTO DE DEPOSITO A VISTA - ' || RW_CONTAS.COOPERATIVA || '/' || RW_CONTAS.CONTA );                                         
          END;
          
     END IF;
     
    -- devolucao de cota capital 
    IF RW_CONTAS.SALDO_COTAS > 0 THEN
    
        BEGIN
            cecred.cada0003.pc_gera_devolucao_capital(pr_cdcooper => RW_CONTAS.COOPERATIVA,
                                                      pr_nrdconta => RW_CONTAS.CONTA,
                                                      pr_vldcotas => RW_CONTAS.SALDO_COTAS,
                                                      pr_formadev => 1,
                                                      pr_qtdparce => 0,
                                                      pr_datadevo => vr_dtmvtolt,
                                                      pr_mtdemiss => 0,
                                                      pr_dtdemiss => vr_dtmvtolt,
                                                      pr_idorigem => 5,
                                                      pr_cdoperad => 1,
                                                      pr_nrdcaixa => 100,
                                                      pr_nmdatela => 'BACA',
                                                      pr_cdagenci => RW_CONTAS.Cdagenci,
                                                      pr_oporigem => 1,
                                                      pr_cdcritic => vr_cdcritic,
                                                      pr_dscritic => vr_dscritic,
                                                      pr_nmdcampo => vr_nmdcampo,
                                                      pr_des_erro => vr_des_erro);   
                                                      
        EXCEPTION
          WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE( 'ERRO LANCAMENTO DE COTA CAPITAL - ' || RW_CONTAS.COOPERATIVA || '/' || RW_CONTAS.CONTA || ' ' || vr_dscritic );                                         

        END;    
    
    
    
  
     END IF;     
     
     
          
  END LOOP;
  
  COMMIT;
                             
                                    
end;