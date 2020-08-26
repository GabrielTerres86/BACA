
declare 

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  --vr_nmdireto        VARCHAR2(4000) := vr_rootmicros;
  --vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'ramon';
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/RITM0087354';
  vr_nmarqimp        VARCHAR2(100)  := 'rollback_RDM0035881.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_excsaida        EXCEPTION;
  vr_dscritic        varchar2(5000) := ' ';

  vr_dtmvtolt    crapdat.dtmvtolt%TYPE;
  vr_incrineg    INTEGER;  
  vr_tab_retorno LANC0001.typ_reg_retorno;  
  vr_nrseqdig    craplcm.nrseqdig%TYPE;  
  vr_snrseqdig   VARCHAR2(400);  
  

  vr_cdcritic    crapcri.cdcritic%TYPE;
  vr_nmdcampo    VARCHAR2(400);
  vr_des_erro    VARCHAR2(400);
  
  vr_bkp_dep_vista_1 VARCHAR2(1000);
  vr_bkp_dep_vista_2 VARCHAR2(1000);
  
  vr_bkp_cotas_1 VARCHAR2(1000);
  vr_bkp_cotas_2 VARCHAR2(1000);
  vr_bkp_cotas_3 VARCHAR2(1000);
     
    
  vr_nrdolote   INTEGER;
  vr_busca      VARCHAR2(400);
  vr_sbusca     VARCHAR2(400);
  vr_nrdocmto   INTEGER;
  vr_snrdocmto  VARCHAR2(400);

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

         ) DADOS
     WHERE ( SALDO_COTAS > 0
        OR saldo_deposito_a_vista > 0 )
    ORDER BY 1, 2;
  
  rw_contas cr_contas%ROWTYPE;
  
BEGIN
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de critica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;
  
  FOR rw_contas IN cr_contas LOOP
    
       SELECT dtmvtolt
         INTO vr_dtmvtolt
         FROM crapdat
        WHERE cdcooper = rw_contas.cooperativa;

       vr_bkp_dep_vista_1 := '';
       vr_bkp_dep_vista_2 := '';
    
       vr_bkp_cotas_1 := '';
       vr_bkp_cotas_2 := ''; 
       vr_bkp_cotas_3 := '';    
     
  
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
             
             vr_bkp_dep_vista_1 := 'DELETE FROM TBCOTAS_DEVOLUCAO WHERE CDCOOPER = ' || RW_CONTAS.COOPERATIVA || ' AND NRDCONTA = ' || RW_CONTAS.CONTA || ' AND TPDEVOLUCAO = 4;';                         
                                           
         EXCEPTION
           WHEN DUP_VAL_ON_INDEX THEN
              
              BEGIN 
                  UPDATE TBCOTAS_DEVOLUCAO
                     SET VLCAPITAL = VLCAPITAL + RW_CONTAS.SALDO_DEPOSITO_A_VISTA
                   WHERE CDCOOPER = RW_CONTAS.COOPERATIVA
                     AND NRDCONTA = RW_CONTAS.CONTA
                     AND TPDEVOLUCAO = 4;
                   
                 vr_bkp_dep_vista_1 := 'UPDATE TBCOTAS_DEVOLUCAO SET VLCAPITAL = VLCAPITAL - ' || replace( RW_CONTAS.SALDO_DEPOSITO_A_VISTA,',','.')  || ' WHERE CDCOOPER = ' || RW_CONTAS.COOPERATIVA || ' AND NRDCONTA = ' || RW_CONTAS.CONTA || ' AND TPDEVOLUCAO = 4 ;';                         

                     
              EXCEPTION
                WHEN OTHERS THEN 
                  DBMS_OUTPUT.PUT_LINE( 'ERRO TBCOTAS_DEVOLUCAO DE DEPOSITO A VISTA - ' || RW_CONTAS.COOPERATIVA || '/' || RW_CONTAS.CONTA ||SQLCODE||' -ERROR- '||SQLERRM );
                   rollback;
                   continue;                
              END;
           
           WHEN OTHERS THEN
             DBMS_OUTPUT.PUT_LINE( 'ERRO TBCOTAS_DEVOLUCAO DE DEPOSITO A VISTA - ' || RW_CONTAS.COOPERATIVA || '/' || RW_CONTAS.CONTA ||SQLCODE||' -ERROR- '||SQLERRM );
             rollback;
             continue;
         END;
                                                  
                                                        
          BEGIN
            
                vr_nrdolote := 600041;
                
                vr_busca := TRIM(to_char(rw_contas.cooperativa)) || ';' ||
                            TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                            TRIM(to_char(rw_contas.cdagenci)) || ';' ||
                            '100;' || 
                            vr_nrdolote;
                            
                vr_sbusca := '''' || rw_contas.cooperativa || ';'' || ';
                vr_sbusca := vr_sbusca || 'TRIM(to_char(( SELECT dtmvtolt FROM crapdat WHERE cdcooper =' || rw_contas.cooperativa || '),''DD/MM/RRRR'')) ';
                vr_sbusca := vr_sbusca || '||'';' || rw_contas.cdagenci || ';';
                vr_sbusca := vr_sbusca || '100;600041''';            
                               
                vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', vr_busca); 
                vr_snrdocmto := 'fn_sequence(''CRAPLAU'',''NRDOCMTO'', ' || vr_sbusca || ')';    
                
                      
                vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||rw_contas.cooperativa ||';'||
                                                                to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                                rw_contas.cdagenci||
                                                                ';100;'|| --cdbccxlt
                                                                vr_nrdolote); 

                vr_snrseqdig := 'fn_sequence(''CRAPLOT'',''NRSEQDIG'','''||rw_contas.cooperativa||';'' ||';
                vr_snrseqdig := vr_snrseqdig || 'to_char(( SELECT dtmvtolt FROM crapdat WHERE cdcooper =' || rw_contas.cooperativa || '),''DD/MM/RRRR'') || ';
                vr_snrseqdig := vr_snrseqdig || ''';' || rw_contas.cdagenci ||';100;600041'')';                                                         


          
        
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
                                                  pr_dtrefere    => vr_dtmvtolt,
                                                  pr_hrtransa    => gene0002.fn_busca_time,
                                                  pr_cdoperad    => 1,
                                                  pr_cdcooper    => rw_contas.cooperativa,
                                                  pr_cdorigem    => 5,
                                                  pr_incrineg    => vr_incrineg,
                                                  pr_tab_retorno => vr_tab_retorno,
                                                  pr_cdcritic    => vr_cdcritic,
                                                  pr_dscritic    => vr_dscritic);
                                                  
              vr_bkp_dep_vista_2 := ' INSERT INTO CRAPLCM ( dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor ';
              vr_bkp_dep_vista_2 := vr_bkp_dep_vista_2 || ', nrseqdig, vllanmto, dtrefere, cdoperad, cdcooper, cdorigem )';
              vr_bkp_dep_vista_2 := vr_bkp_dep_vista_2 || '  VALUES (  ( SELECT dtmvtolt FROM crapdat WHERE cdcooper = ' || rw_contas.cooperativa || ' )';
              vr_bkp_dep_vista_2 := vr_bkp_dep_vista_2 || ',' || rw_contas.cdagenci || ', ' || ' 100, ' || to_char( vr_nrdolote ) || ', ' || rw_contas.conta || ', ' || vr_snrdocmto;
              vr_bkp_dep_vista_2 := vr_bkp_dep_vista_2 || ',' || CASE WHEN RW_CONTAS.INPESSOA = 2 THEN '2521' ELSE '2520' END;
              vr_bkp_dep_vista_2 := vr_bkp_dep_vista_2 || ',' || vr_snrseqdig || ', ' || replace( to_char( RW_CONTAS.SALDO_DEPOSITO_A_VISTA ),',','.');
              vr_bkp_dep_vista_2 := vr_bkp_dep_vista_2 || ', ( SELECT dtmvtolt FROM crapdat WHERE cdcooper = ' || rw_contas.cooperativa || ' ), 1, ' || rw_contas.cooperativa || ', 5 );';
 


         EXCEPTION
            WHEN OTHERS THEN
               DBMS_OUTPUT.PUT_LINE( 'ERRO LANCAMENTO DE DEPOSITO A VISTA - ' || RW_CONTAS.COOPERATIVA || '/' || RW_CONTAS.CONTA );  
               rollback;
               continue; 
          END;
          
 
     END IF;
     
    -- devolucao de cota capital 
    IF RW_CONTAS.SALDO_COTAS > 0 THEN
    
        BEGIN
      
             BEGIN                                          
                  INSERT INTO TBCOTAS_DEVOLUCAO(cdcooper
                                               ,nrdconta
                                               ,tpdevolucao
                                               ,vlcapital)
                                        VALUES (rw_contas.cooperativa
                                               ,rw_contas.conta
                                               ,3
                                               ,rw_contas.saldo_cotas);   
                                               
             EXCEPTION
                 WHEN DUP_VAL_ON_INDEX THEN
                  
                      UPDATE TBCOTAS_DEVOLUCAO
                         SET VLCAPITAL = VLCAPITAL + RW_CONTAS.saldo_cotas
                       WHERE CDCOOPER = RW_CONTAS.COOPERATIVA
                         AND NRDCONTA = RW_CONTAS.CONTA
                         AND TPDEVOLUCAO = 3;
  
              END;                                
                                                                                           
                                                                                                           
                    UPDATE crapcot
                       SET vldcotas = vldcotas - RW_CONTAS.SALDO_COTAS
                     WHERE cdcooper = RW_CONTAS.Cooperativa
                       AND nrdconta = rw_contas.conta ;   
                
                   
                   
            vr_nrdolote := 600040;

            vr_busca := TRIM(to_char(RW_CONTAS.Cooperativa)) || ';' ||
                        TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                        TRIM(to_char(rw_contas.cdagenci)) || ';' ||
                        '100;' || --cdbccxlt
                        vr_nrdolote;

            vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);

            vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||RW_CONTAS.Cooperativa||';'||
                                                                to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                                rw_contas.cdagenci||
                                                                ';100;'|| --cdbccxlt
                                                                vr_nrdolote);
                                                                
            vr_sbusca := '''' || rw_contas.cooperativa || ';'' || ';
            vr_sbusca := vr_sbusca || 'TRIM(to_char(( SELECT dtmvtolt FROM crapdat WHERE cdcooper =' || rw_contas.cooperativa || '),''DD/MM/RRRR'')) ';
            vr_sbusca := vr_sbusca || '||'';' || rw_contas.cdagenci || ';';
            vr_sbusca := vr_sbusca || '100;600040''';            
                               
            vr_snrdocmto := 'fn_sequence(''CRAPLAU'',''NRDOCMTO'', ' || vr_sbusca || ')';                                                                                                                               

            vr_snrseqdig := 'fn_sequence(''CRAPLOT'',''NRSEQDIG'','''||rw_contas.cooperativa||';'' ||';
            vr_snrseqdig := vr_snrseqdig || 'to_char(( SELECT dtmvtolt FROM crapdat WHERE cdcooper =' || rw_contas.cooperativa || '),''DD/MM/RRRR'') || ';
            vr_snrseqdig := vr_snrseqdig || ''';' || rw_contas.cdagenci ||';100;600040'')'; 
           

              --Inserir registro de debito
              INSERT INTO craplct(cdcooper
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,dtmvtolt
                                 ,cdhistor
                                 ,nrctrpla
                                 ,nrdconta
                                 ,nrdocmto
                                 ,nrseqdig
                                 ,vllanmto)
                          VALUES (rw_contas.cooperativa
                                 ,rw_contas.cdagenci
                                 ,100
                                 ,vr_nrdolote
                                 ,vr_dtmvtolt
                                 ,decode(rw_contas.inpessoa,1,2079,2080)
                                 ,0
                                 ,rw_contas.conta
                                 ,vr_nrdocmto
                                 ,vr_nrseqdig
                                 ,rw_contas.saldo_cotas);                                            

  
              vr_bkp_cotas_1 := ' INSERT INTO craplct(cdcooper,cdagenci,cdbccxlt,nrdolote,dtmvtolt,cdhistor,nrctrpla,nrdconta,nrdocmto,nrseqdig,vllanmto) ';
              vr_bkp_cotas_1 := vr_bkp_cotas_1 || '  VALUES ( ' || rw_contas.cooperativa || ',' || rw_contas.cdagenci || ', 100, '|| to_char( vr_nrdolote );
              vr_bkp_cotas_1 := vr_bkp_cotas_1 || ', ( SELECT dtmvtolt FROM crapdat WHERE cdcooper = ' || rw_contas.cooperativa || ' )';
              vr_bkp_cotas_1 := vr_bkp_cotas_1 || ', 61,0,' || rw_contas.conta || ',' || vr_snrdocmto || ',' || vr_snrseqdig;                                          
              vr_bkp_cotas_1 := vr_bkp_cotas_1 || ', ' || replace( to_char( RW_CONTAS.SALDO_COTAS ),',','.') || ');';             
                                                      
              
              vr_bkp_cotas_2 := ' UPDATE crapcot SET vldcotas = vldcotas + ' || replace( to_char( RW_CONTAS.SALDO_COTAS ),',','.');
              vr_bkp_cotas_2 :=  vr_bkp_cotas_2 || ' WHERE cdcooper = ' || rw_contas.cooperativa  || ' AND nrdconta = ' || rw_contas.conta || ';';
                                                 
              vr_bkp_cotas_3 := 'UPDATE TBCOTAS_DEVOLUCAO SET VLCAPITAL = VLCAPITAL - ' || replace( RW_CONTAS.SALDO_COTAS,',','.')  || ' WHERE CDCOOPER = ' || RW_CONTAS.COOPERATIVA || ' AND NRDCONTA = ' || RW_CONTAS.CONTA || ' AND TPDEVOLUCAO = 3 ;';                         
                                                        
                                                      
        EXCEPTION
          WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE( 'ERRO LANCAMENTO DE COTA CAPITAL - ' || RW_CONTAS.COOPERATIVA || '/' || RW_CONTAS.CONTA || ' ' || sqlerrm );                                         
           rollback;
           continue;
       
        END;  
        

     END IF; 
   

     
     IF vr_bkp_dep_vista_1 IS NOT NULL THEN 
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_dep_vista_1); 
     END IF;
     
     IF vr_bkp_dep_vista_2 IS NOT NULL THEN 
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_dep_vista_2); 
     END IF;

     IF vr_bkp_cotas_1 IS NOT NULL THEN 
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_cotas_1); 
     END IF;
     
     IF vr_bkp_cotas_2 IS NOT NULL THEN 
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_cotas_2); 
     END IF;     
     
     IF vr_bkp_cotas_3 IS NOT NULL THEN 
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_bkp_cotas_3); 
     END IF;  
          
   
  END LOOP;
  
  commit; 
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');                            
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;      
  
  EXCEPTION 
     WHEN vr_excsaida then
          ROLLBACK;
          raise_application_error( -20001,vr_dscritic);         
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
  
                           
end;
