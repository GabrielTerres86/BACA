DECLARE

  CURSOR cr_crapass is
    SELECT a.nrdconta,
           a.cdcooper,
           a.cdsitdct,
           a.dtdemiss,
           a.cdmotdem,
           a.dtelimin,
           a.cdagenci
      FROM CECRED.CRAPASS a
     WHERE a.progress_recid = 591197;
  rg_crapass cr_crapass%ROWTYPE;
  
  CURSOR cr_devolucao(pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_tpdevolu NUMBER) IS
    SELECT ROWID dsdrowid
         , t.cdcooper
         , t.nrdconta
         , t.tpdevolucao
         , t.vlcapital
         , t.qtparcelas
         , t.dtinicio_credito
         , t.vlpago
      FROM cecred.tbcotas_devolucao t
     WHERE nrdconta    = pr_nrdconta
       AND cdcooper    = pr_cdcooper
       AND tpdevolucao = pr_tpdevolu;
  
  CURSOR cr_cotas(pr_cdcooper NUMBER
                 ,pr_nrdconta NUMBER) IS
    SELECT t.vldcotas
      FROM cecred.crapcot t
     WHERE nrdconta    = pr_nrdconta
       AND cdcooper    = pr_cdcooper;
  
  vr_arq_path    VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/RITM0272316'; 

  vr_nmarqrol    VARCHAR2(100) := 'RITM0272316_script_rollback.sql';
  vr_nmarqlog    VARCHAR2(100) := 'RITM0272316_script_log.txt';  

  vr_flarqrol    utl_file.file_type;
  vr_flarqlog    utl_file.file_type;
  
  vr_lgrowid     ROWID;
  vr_dstransa    VARCHAR2(100) := 'Alterada situacao de conta por script. RITM0272316.';
  vr_cdsitdct    NUMBER := 7;
  vr_vldcotas    NUMBER;
  vr_nrdocmto    NUMBER;
  vr_nrseqdig    NUMBER;
  vr_dtmvtolt    DATE;
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(2000);
  vr_exc_erro    EXCEPTION;
  vr_dsdrowid    VARCHAR2(50);
  vr_tab_retorno CECRED.LANC0001.typ_reg_retorno;
  vr_incrineg    INTEGER;
  
BEGIN
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqlog   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqlog   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqlog||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqrol   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqrol   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 

  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                       ,pr_des_text => 'Inicio do script'); 
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                       ,pr_des_text => 'Buscar dados da conta'); 

  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'BEGIN'); 

  OPEN  cr_crapass;
  FETCH cr_crapass INTO rg_crapass;
  
  IF cr_crapass%NOTFOUND THEN
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Registro de conta nao encontrado'); 
    
    CLOSE cr_crapass;
    vr_dscritic := 'Registro de conta não encontrado.';
    RAISE vr_exc_erro;
  END IF;
  
  CLOSE cr_crapass;
  
  vr_dtmvtolt := sistema.datascooperativa(rg_crapass.cdcooper).dtmvtolt;
  
  BEGIN
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Alterar situacao da conta: '||rg_crapass.nrdconta); 
                                         
    UPDATE cecred.crapass
       SET cdsitdct = vr_cdsitdct
         , dtdemiss = NULL
         , dtelimin = NULL
         , cdmotdem = 0
     WHERE nrdconta = rg_crapass.nrdconta
       AND cdcooper = rg_crapass.cdcooper;
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => 'UPDATE CECRED.crapass '); 
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '   SET cdsitdct = '||rg_crapass.cdsitdct); 
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '     , dtdemiss = to_date('''||to_char(rg_crapass.dtdemiss,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'); 

    IF rg_crapass.dtelimin IS NULL THEN
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '     , dtelimin = NULL'); 
    ELSE
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '     , dtelimin = to_date('''||to_char(rg_crapass.dtelimin,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'); 
    END IF;
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '     , cdmotdem = '||NVL(rg_crapass.cdmotdem,0));
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => ' WHERE cdcooper = '||rg_crapass.cdcooper); 
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol ,pr_des_text => '   AND nrdconta = '||rg_crapass.nrdconta||';'); 
    
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                           ,pr_des_text => 'Erro ao atualizar registro da conta: '||SQLERRM); 
    
      vr_dscritic := 'Erro ao atualizar registro da conta: '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Gerar logs da conta'); 
  
  gene0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper
                      ,pr_cdoperad => '1'
                      ,pr_dscritic => ' '
                      ,pr_dsorigem => 'AIMARO'
                      ,pr_dstransa => vr_dstransa
                      ,pr_dttransa => TRUNC(SYSDATE)
                      ,pr_flgtrans => 1
                      ,pr_hrtransa => gene0002.fn_busca_time
                      ,pr_idseqttl => 1
                      ,pr_nmdatela => ''
                      ,pr_nrdconta => rg_crapass.nrdconta
                      ,pr_nrdrowid => vr_lgrowid);
      
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                           ,pr_nmdcampo => 'crapass.cdsitdct'
                           ,pr_dsdadant => rg_crapass.cdsitdct
                           ,pr_dsdadatu => vr_cdsitdct);
  
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                           ,pr_nmdcampo => 'crapass.dtdemiss'
                           ,pr_dsdadant => rg_crapass.dtdemiss
                           ,pr_dsdadatu => NULL);
  
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                           ,pr_nmdcampo => 'crapass.dtelimin'
                           ,pr_dsdadant => rg_crapass.dtelimin
                           ,pr_dsdadatu => NULL);
  
  gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                           ,pr_nmdcampo => 'crapass.cdmotdem'
                           ,pr_dsdadant => rg_crapass.cdmotdem
                           ,pr_dsdadatu => 0);

  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'DELETE cecred.craplgi i WHERE EXISTS (SELECT 1 FROM cecred.craplgm m WHERE m.rowid = '''||vr_lgrowid||''' '
                                                          || ' AND i.cdcooper = m.cdcooper AND i.nrdconta = m.nrdconta AND i.idseqttl = m.idseqttl AND '
                                                          || ' i.dttransa = m.dttransa AND i.hrtransa = m.hrtransa AND i.nrsequen = m.nrsequen);');
   
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'DELETE cecred.craplgm WHERE rowid = '''||vr_lgrowid||'''; ');   
  
  vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', rg_crapass.cdcooper || ';' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';'||rg_crapass.cdagenci||';100;600040');
  vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG', rg_crapass.cdcooper || ';' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';'||rg_crapass.cdagenci||';100;600040');   
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Verificando e estornando valores a devolver - Cotas'); 
  
  FOR valor IN cr_devolucao(rg_crapass.cdcooper, rg_crapass.nrdconta, 1) LOOP
    
    BEGIN
      INSERT INTO CECRED.craplct
                    (cdcooper
                    ,cdagenci
                    ,cdbccxlt
                    ,nrdolote
                    ,dtmvtolt
                    ,cdhistor
                    ,nrctrpla
                    ,nrdconta
                    ,nrdocmto
                    ,nrseqdig
                    ,vllanmto
                    ,cdopeori
                    ,dtinsori)
             VALUES (rg_crapass.cdcooper
                    ,rg_crapass.cdagenci
                    ,100
                    ,600040
                    ,vr_dtmvtolt
                    ,61
                    ,0
                    ,rg_crapass.nrdconta 
                    ,vr_nrdocmto
                    ,vr_nrseqdig
                    ,valor.vlcapital
                    ,1
                    ,SYSDATE) RETURN ROWID INTO vr_dsdrowid; 
    
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                               ,pr_nmdcampo => 'craplct.vllanmto'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => valor.vlcapital);
    
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                           ,pr_des_text => 'DELETE cecred.craplct WHERE rowid = '''||vr_dsdrowid||'''; ');   
    
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => 'Erro ao realizar lançamento de cota: '||SQLERRM); 
      
        vr_dscritic := 'Erro ao realizar lançamento de cota: '||SQLERRM;
        RAISE vr_exc_erro;
    END; 
  
    BEGIN
      vr_vldcotas := 0;
      
      OPEN  cr_cotas(rg_crapass.cdcooper, rg_crapass.nrdconta);
      FETCH cr_cotas INTO vr_vldcotas;
      CLOSE cr_cotas;
      
      UPDATE CECRED.crapcot
        SET vldcotas = ( NVL(vldcotas,0) + NVL(valor.vlcapital,0) )
      WHERE cdcooper = rg_crapass.cdcooper
        AND nrdconta = rg_crapass.nrdconta;
      
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                           ,pr_des_text => 'UPDATE cecred.crapcot SET vldcotas = '||to_char(NVL(vr_vldcotas,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||' WHERE cdcooper = '||rg_crapass.cdcooper||' AND nrdconta = '||rg_crapass.nrdconta||'; '); 
      
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => 'Erro ao atualizar valor de cota: '||SQLERRM); 
      
        vr_dscritic := 'Erro ao atualizar valor de cota: '||SQLERRM;
        RAISE vr_exc_erro;
    END; 
    
    BEGIN
      DELETE cecred.tbcotas_devolucao
       WHERE ROWID = valor.dsdrowid;
       
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => 'INSERT INTO cecred.tbcotas_devolucao '); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        (cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) '); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => ' VALUES ('||valor.cdcooper); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||valor.nrdconta); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||valor.tpdevolucao); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')); 
      
      IF valor.qtparcelas IS NULL THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,NULL'); 
      ELSE
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||valor.qtparcelas); 
      END IF;

      IF valor.dtinicio_credito IS NULL THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,NULL'); 
      ELSE
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,to_date('''||to_char(valor.dtinicio_credito,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'); 
      END IF;
      
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||to_char(valor.vlpago,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||');'); 
      
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => 'Erro ao excluir registro de devolução tipo 1: '||SQLERRM); 
      
        vr_dscritic := 'Erro ao excluir registro de devolução tipo 1: '||SQLERRM;
        RAISE vr_exc_erro;
    END; 
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Lançado em cotas o montande de: '||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')); 
    
  END LOOP;
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Verificando e estornando valores a devolver - Saldo'); 
  
  FOR valor IN cr_devolucao(rg_crapass.cdcooper, rg_crapass.nrdconta, 4) LOOP
    
    IF valor.vlcapital > 0 THEN
    
      cecred.Lanc0001.pc_gerar_lancamento_conta(pr_cdcooper    => rg_crapass.cdcooper
                                               ,pr_dtmvtolt    => vr_dtmvtolt
                                               ,pr_cdagenci    => rg_crapass.cdagenci
                                               ,pr_cdbccxlt    => 1
                                               ,pr_nrdolote    => 600040
                                               ,pr_nrdctabb    => rg_crapass.nrdconta
                                               ,pr_nrdocmto    => vr_nrdocmto
                                               ,pr_cdhistor    => 2520
                                               ,pr_vllanmto    => valor.vlcapital
                                               ,pr_nrdconta    => rg_crapass.nrdconta
                                               ,pr_hrtransa    => gene0002.fn_busca_time
                                               ,pr_cdorigem    => 0
                                               ,pr_inprolot    => 1
                                               ,pr_tab_retorno => vr_tab_retorno
                                               ,pr_incrineg    => vr_incrineg
                                               ,pr_cdcritic    => vr_cdcritic
                                               ,pr_dscritic    => vr_dscritic);
    
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        IF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;
      
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => 'Erro ao incluir lancamento em conta: '||vr_dscritic); 
      
        vr_dscritic := 'Erro ao incluir lancamento em conta: '||vr_dscritic;
        RAISE vr_exc_erro;
      END IF;
  
    
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                               ,pr_nmdcampo => 'craplcm.vllanmto'
                               ,pr_dsdadant => NULL
                               ,pr_dsdadatu => valor.vlcapital);

      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => 'DELETE cecred.craplcm ');
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => ' WHERE cdcooper = '||rg_crapass.cdcooper );
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '   AND nrdconta = '||rg_crapass.nrdconta );
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '   AND dtmvtolt = to_date('''||TO_CHAR(vr_dtmvtolt,'DD/MM/YYYY')||''',''DD/MM/YYYY'')');
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '   AND cdagenci = '||rg_crapass.cdagenci );
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '   AND cdbccxlt = 1 ' );
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '   AND nrdolote = 600040 ' );
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '   AND nrdocmto = '||vr_nrdocmto||';' );

      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                           ,pr_des_text => 'Lançado em saldo de conta o montande de: '||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')); 
 
    END IF;  
  
    BEGIN
      DELETE cecred.tbcotas_devolucao
       WHERE ROWID = valor.dsdrowid;
       
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => 'INSERT INTO cecred.tbcotas_devolucao '); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        (cdcooper,nrdconta,tpdevolucao,vlcapital,qtparcelas,dtinicio_credito,vlpago) '); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => ' VALUES ('||valor.cdcooper); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||valor.nrdconta); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||valor.tpdevolucao); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||to_char(valor.vlcapital,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')); 
      
      IF valor.qtparcelas IS NULL THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,NULL'); 
      ELSE
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||valor.qtparcelas); 
      END IF;

      IF valor.dtinicio_credito IS NULL THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,NULL'); 
      ELSE
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,to_date('''||to_char(valor.dtinicio_credito,'dd/mm/yyyy')||''',''dd/mm/yyyy'')'); 
      END IF;
      
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol,pr_des_text => '        ,'||to_char(valor.vlpago,'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')||');'); 
      
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => 'Erro ao excluir registro de devolução tipo 4: '||SQLERRM); 
      
        vr_dscritic := 'Erro ao excluir registro de devolução tipo 4: '||SQLERRM;
        RAISE vr_exc_erro;
    END; 
     
  END LOOP;
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => '  COMMIT;');
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => 'END;');
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog ,pr_des_text => 'Fim do script.'); 
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    raise_application_error(-20001, vr_dscritic);
    
  WHEN OTHERS THEN
    ROLLBACK;
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqrol);
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;
