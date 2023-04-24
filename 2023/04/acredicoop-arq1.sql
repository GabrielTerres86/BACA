DECLARE 

  vr_nmdireto    VARCHAR2(100);
  vr_nmarquiv    VARCHAR2(50) := 'acredicoop.csv';
  vr_input_file  UTL_FILE.FILE_TYPE;
  vr_setlinha    VARCHAR2(10000);
  vr_cdprograma   VARCHAR2(40) := 'BACA-ACREDI';

  vr_cdcooper NUMBER;
  vr_nrdconta NUMBER;
  vr_vllanmto NUMBER(8,2);
  rw_crapdat    btch0001.cr_crapdat%ROWTYPE;
  vr_qtd_commit INTEGER := 10000;
  vr_qtdregis   INTEGER := 0; 
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0; 
  pr_cdcritic   INTEGER;
  pr_dscritic   VARCHAR2(4000);
  vr_exc_saida  EXCEPTION;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_dslog VARCHAR2(4000) := '';      

  PROCEDURE pc_lancamento_capital(pr_cdcooper IN  craplct.cdcooper%TYPE 
                                 ,pr_nrdconta IN  craplct.nrdconta%TYPE  
                                 ,pr_vllanmto IN  craplct.vllanmto%TYPE 
                                 ,pr_dtmvtolt IN  crapdat.dtmvtolt%TYPE
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS                                         
  BEGIN    
    DECLARE
      vr_exc_erro     EXCEPTION;
      vr_nrdrowid     ROWID;
      vr_nrseqdig_lot craplot.nrseqdig%TYPE;
      vr_busca        VARCHAR2(100);
      vr_nrdocmto     craplct.nrdocmto%TYPE;
      vr_nrdolote     craplot.nrdolote%TYPE;
      vr_tab_retorno  LANC0001.typ_reg_retorno;
      vr_incrineg     INTEGER;

      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE)IS
        SELECT ass.nrdconta
              ,ass.cdagenci
          FROM cecred.crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
        rw_crapass cr_crapass%ROWTYPE;    
    
      CURSOR cr_crapcot(pr_cdcooper IN crapcot.cdcooper%TYPE
                       ,pr_nrdconta IN crapcot.nrdconta%TYPE)IS
        SELECT cot.vldcotas
          FROM cecred.crapcot cot
         WHERE cot.cdcooper = pr_cdcooper
           AND cot.nrdconta = pr_nrdconta;
        rw_crapcot cr_crapcot%ROWTYPE;

    BEGIN

      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
    
      FETCH cr_crapass INTO rw_crapass;

      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        vr_dscritic := 'Associado nao encontrado - '|| pr_cdcooper || ' Conta: ' || pr_nrdconta;
        RAISE vr_exc_erro;
      END IF;
    
      CLOSE cr_crapass;

      OPEN cr_crapcot(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
    
      FETCH cr_crapcot INTO rw_crapcot;
    
      IF cr_crapcot%NOTFOUND THEN
        CLOSE cr_crapcot;
        vr_dscritic := 'Nao encontrado conta em cotas - ' || pr_cdcooper || ' Conta: ' || pr_nrdconta;
        RAISE vr_exc_erro;
      END IF;
    
      CLOSE cr_crapcot;
    
      IF nvl(pr_vllanmto,0) = 0 THEN
        vr_dscritic := 'Nao possui valor para lancar: Cooperativa: ' ||  pr_cdcooper || ' Conta: ' || pr_nrdconta;
        RAISE vr_exc_erro;
      END IF;
    
      IF nvl(pr_vllanmto,0) > rw_crapcot.vldcotas THEN  
        vr_dscritic := 'Valor para saque maior que o saldo disponível: Cooperativa ' ||  pr_cdcooper || ' Conta: ' || pr_nrdconta;
        RAISE vr_exc_erro;
      END IF;
       
      IF (rw_crapcot.vldcotas - nvl(pr_vllanmto,0)) < 1 THEN
        
        vr_dscritic := 'Nao e possivel saque total, deve deixar pelo menos 1,00 em cotas: Cooperativa ' ||  pr_cdcooper || ' Conta: ' || pr_nrdconta;
        RAISE vr_exc_erro;
      END IF;
        
      vr_nrdolote := 900039;
    
      vr_busca := TRIM(to_char(pr_cdcooper)) || ';' ||
                  TRIM(to_char(pr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                  TRIM(to_char(rw_crapass.cdagenci)) || ';' ||
                  '100;' ||
                  vr_nrdolote || ';' || 
                  TRIM(to_char(pr_nrdconta));

      vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca); 
    
      vr_nrseqdig_lot := fn_sequence('CRAPLOT','NRSEQDIG',''||pr_cdcooper||';'||
                                     to_char(pr_dtmvtolt,'DD/MM/RRRR')||';'||
                                     rw_crapass.cdagenci||
                                     ';100;'||
                                     vr_nrdolote);      
      vr_dslog := 'UPDATE cecred.crapcot SET vldcotas = ' || replace(rw_crapcot.vldcotas, ',', '.') ||
                 ' WHERE CDCOOPER = ' ||pr_cdcooper ||
                   ' AND NRDCONTA = '|| pr_nrdconta ||';'; 
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                            ,pr_dsmensagem    => vr_dslog
                            ,pr_cdmensagem    => 111
                            ,pr_cdprograma    => vr_cdprograma
                            ,pr_cdcooper      => pr_cdcooper 
                            ,pr_idprglog      => vr_idprglog);
      vr_dslog := 'DELETE cecred.craplct ' ||
                  ' WHERE CDCOOPER = ' ||pr_cdcooper ||
                    ' AND NRDCONTA = '|| pr_nrdconta ||
                    ' AND NRDOLOTE = 900039 AND CDHISTOR = 2417 AND DTMVTOLT = ' || to_date(sysdate,'dd/mm/yyyy')||';'; 
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                             ,pr_dsmensagem    => vr_dslog
                             ,pr_cdmensagem    => 222
                             ,pr_cdprograma    => vr_cdprograma
                             ,pr_cdcooper      => pr_cdcooper 
                             ,pr_idprglog      => vr_idprglog);  

      vr_dslog := 'DELETE cecred.craplcm ' ||
                 ' WHERE CDCOOPER = ' ||pr_cdcooper ||
                   ' AND NRDCONTA = '|| pr_nrdconta ||
                   ' AND NRDOLOTE = 900039 AND CDHISTOR = 2418 AND DTMVTOLT = ' || to_date(sysdate,'dd/mm/yyyy')||';'; 
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                             ,pr_dsmensagem    => vr_dslog
                             ,pr_cdmensagem    => 333
                             ,pr_cdprograma    => vr_cdprograma
                             ,pr_cdcooper      => pr_cdcooper 
                             ,pr_idprglog      => vr_idprglog);                                                                                                              
      
      BEGIN
           
        INSERT INTO cecred.craplct(cdcooper
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
                           VALUES (pr_cdcooper
                                  ,rw_crapass.cdagenci
                                  ,100
                                  ,vr_nrdolote
                                  ,pr_dtmvtolt
                                  ,2417
                                  ,pr_nrdconta
                                  ,pr_nrdconta
                                  ,vr_nrdocmto
                                  ,vr_nrseqdig_lot
                                  ,pr_vllanmto);

        cecred.LANC0001.pc_gerar_lancamento_conta(pr_cdcooper =>pr_cdcooper           
                                                 ,pr_dtmvtolt =>pr_dtmvtolt 
                                                 ,pr_dtrefere =>pr_dtmvtolt    
                                                 ,pr_cdagenci =>rw_crapass.cdagenci 
                                                 ,pr_cdbccxlt =>100                                                                                                              
                                                 ,pr_nrdolote =>vr_nrdolote    
                                                 ,pr_nrdconta =>pr_nrdconta 
                                                 ,pr_nrdctabb => pr_nrdconta                                               
                                                 ,pr_nrdctitg => TO_CHAR(cecred.gene0002.fn_mask(pr_nrdconta,'99999999'))                                                 
                                                 ,pr_nrdocmto => vr_nrdocmto                                                 
                                                 ,pr_cdhistor => 2418 
                                                 ,pr_vllanmto =>pr_vllanmto      
                                                 ,pr_nrseqdig =>vr_nrseqdig_lot       
                                                 ,pr_tab_retorno => vr_tab_retorno
                                                 ,pr_incrineg => vr_incrineg
                                                 ,pr_cdcritic => vr_cdcritic
                                                 ,pr_dscritic => vr_dscritic);

        IF nvl(vr_cdcritic, 0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;                                                                        
                             
        UPDATE cecred.crapcot
           SET vldcotas = vldcotas - pr_vllanmto
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;               
                                
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Não foi possível efetuar o saque parcial.'|| SQLERRM;
          RAISE vr_exc_erro;
      END;    
               
      cecred.GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => 1
                                 ,pr_dscritic => NULL
                                 ,pr_dsorigem => 'Oficio BACEN'
                                 ,pr_dstransa => 'Saque Parcial de Cotas  Oficio Bacen'
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 1
                                 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                 ,pr_idseqttl => 1
                                 ,pr_nmdatela => 'SCRIPT'
                                 ,pr_nrdconta => rw_crapass.nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);

      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'vldcotas'
                               ,pr_dsdadant => 0
                               ,pr_dsdadatu => trim(to_char(pr_vllanmto,'fm999g999g990d00')) );



    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||  ' Cooperativa ' ||  pr_cdcooper || ' Conta: ' || pr_nrdconta;
        ELSE
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        END IF;
             
      WHEN OTHERS THEN                 
        pr_cdcritic := NULL;
        pr_dscritic := 'Erro na APLI0002.pc_efetua_resgate_online --> '|| SQLERRM;
               
    END;
  END pc_lancamento_capital;

BEGIN
  OPEN btch0001.cr_crapdat(pr_cdcooper => 2);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
    
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0295438/';
    
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto 
                           ,pr_nmarquiv => vr_nmarquiv 
                           ,pr_tipabert => 'R'  
                           ,pr_utlfileh => vr_input_file 
                           ,pr_des_erro => vr_dscritic); 
  IF vr_dscritic IS NOT NULL THEN
    RAISE vr_exc_saida;
  END IF;

  BEGIN
  LOOP

    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file 
                                ,pr_des_text => vr_setlinha);
    vr_cdcooper := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada( 1,vr_setlinha,';') ) );    
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada( 2,vr_setlinha,';') ) ); 
    vr_vllanmto := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada( 3,vr_setlinha,';') ) );

    vr_qtdregis := vr_qtdregis + 1;
    SAVEPOINT lacamento_copital;
    pc_lancamento_capital(pr_cdcooper => vr_cdcooper
                         ,pr_nrdconta => vr_nrdconta
                         ,pr_vllanmto => vr_vllanmto
                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);

    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_dsmensagem    => vr_dscritic 
                            ,pr_cdmensagem    => 444
                            ,pr_cdprograma    => vr_cdprograma
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_idprglog      => vr_idprglog);
      ROLLBACK TO SAVEPOINT lacamento_copital;
      CONTINUE;
    END IF;
        
    IF MOD(vr_qtdregis, vr_qtd_commit) = 0 THEN
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_dsmensagem    => 'Commit - ' || vr_qtdregis
                            ,pr_cdmensagem    => 555
                            ,pr_cdprograma    => vr_cdprograma
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_idprglog      => vr_idprglog);
      COMMIT;
    END IF;
                                         
  END LOOP;
  EXCEPTION 
    WHEN no_data_found THEN
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    WHEN OTHERS THEN
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
      RAISE vr_exc_saida;
    END;
  COMMIT;        

                                 
  EXCEPTION
    WHEN vr_exc_saida THEN

    IF vr_cdcritic <> 0 THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
    ELSE
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    END IF;
    ROLLBACK;
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                          ,pr_dsmensagem    => vr_dscritic
                          ,pr_cdmensagem    => 777
                          ,pr_cdprograma    => vr_cdprograma
                          ,pr_cdcooper      => vr_cdcooper
                          ,pr_idprglog      => vr_idprglog);
    WHEN OTHERS THEN

      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro nao tratado '||SQLERRM;
      GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
      ROLLBACK;
      CECRED.pc_log_programa(pr_dstiplog      => 'O' 
                            ,pr_dsmensagem    => vr_dscritic
                            ,pr_cdmensagem    => 888
                            ,pr_cdprograma    => vr_cdprograma
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_idprglog      => vr_idprglog);
END;
