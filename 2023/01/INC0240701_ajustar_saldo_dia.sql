DECLARE

  CURSOR cr_crapass is
    SELECT a.cdcooper
         , a.nrdconta
      FROM CECRED.crapass a
     WHERE a.progress_recid IN (1039442,1615744,1431762,1586249,969552,923517,897363,1089236);

  CURSOR cr_crapsda(pr_cdcooper CECRED.crapsda.cdcooper%TYPE
                   ,pr_nrdconta CECRED.crapsda.nrdconta%TYPE
                   ,pr_dtmvtolt CECRED.crapsda.dtmvtolt%TYPE) IS
    SELECT t.dtmvtolt
         , t.vlsddisp
         , ROWID dsdrowid
      FROM CECRED.crapsda t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtmvtolt >= pr_dtmvtolt
     ORDER BY t.dtmvtolt;
  
  CURSOR cr_craplcm(pr_cdcooper CECRED.craplcm.cdcooper%TYPE
                   ,pr_nrdconta CECRED.craplcm.nrdconta%TYPE
                   ,pr_dtmvtolt CECRED.craplcm.dtmvtolt%TYPE) IS
    SELECT h.inhistor
         , t.vllanmto
      FROM CECRED.craphis h
         , CECRED.craplcm t
     WHERE h.cdcooper = t.cdcooper
       AND h.cdhistor = t.cdhistor
       AND t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtmvtolt = pr_dtmvtolt;
    
  CURSOR cr_crapsld(pr_cdcooper CECRED.craplcm.cdcooper%TYPE
                   ,pr_nrdconta CECRED.craplcm.nrdconta%TYPE) IS
    SELECT t.vlsddisp
         , ROWID dsdrowid
      FROM CECRED.crapsld t 
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta;
  rg_crapsld   cr_crapsld%ROWTYPE;
  
  vr_arq_path    VARCHAR2(1000):= CECRED.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0240701'; 

  vr_nmarqrol    VARCHAR2(100) := 'INC0240701_script_rollback.sql';
  vr_nmarqlog    VARCHAR2(100) := 'INC0240701_script_log.txt';  

  vr_flarqrol    utl_file.file_type;
  vr_flarqlog    utl_file.file_type;
  
  vr_dsdrowid    VARCHAR2(50);
  vr_dtinicio    DATE := to_date('29/12/2022','dd/mm/yyyy');
  vr_vldsaldo    NUMBER;
  vr_vllamnto    NUMBER;
  vr_cdcritic    NUMBER;
  vr_dscritic    VARCHAR2(2000);
  vr_exc_erro    EXCEPTION;
  
  
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
                                       ,pr_des_text => 'Buscar contas a serem ajustadas'); 

  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'BEGIN'); 

  
  FOR conta IN cr_crapass LOOP
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => chr(10)||'#####################################################'||chr(10));
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Corrigindo saldo da coop/conta: '||conta.cdcooper||'/'||conta.nrdconta); 
  
    vr_vldsaldo := NULL;
  
    FOR saldo IN cr_crapsda(conta.cdcooper, conta.nrdconta, vr_dtinicio) LOOP
      
      IF vr_vldsaldo IS NULL THEN
        vr_vldsaldo := saldo.vlsddisp;
        CONTINUE;
      END IF;
      
      vr_vllamnto := 0;
      
      FOR lanc IN cr_craplcm(conta.cdcooper, conta.nrdconta, saldo.dtmvtolt) LOOP
        
        CASE lanc.inhistor
          WHEN 1 THEN 
            vr_vllamnto := Nvl(vr_vllamnto,0) + lanc.vllanmto;
          WHEN 11 THEN
            vr_vllamnto := Nvl(vr_vllamnto,0) - lanc.vllanmto;
          ELSE
            CONTINUE;
        END CASE;
      
      END LOOP;
      
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => '  DATA: '||to_char(saldo.dtmvtolt,'dd/mm/yyyy'));       
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => '      Saldo Antes: '||to_char(vr_vldsaldo,'FM9G999G999G999G990D00')); 
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => '      Lançamentos: '||to_char(vr_vllamnto,'FM9G999G999G999G990D00'));
      
      vr_vldsaldo := NVL(vr_vldsaldo,0) + vr_vllamnto;
      
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => '      Saldo Final: '||to_char(vr_vldsaldo,'FM9G999G999G999G990D00'));
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => '      Saldo Dia..: '||to_char(saldo.vlsddisp,'FM9G999G999G999G990D00'));
      
      IF vr_vldsaldo <> saldo.vlsddisp THEN
        
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => '    *** SALDO DIVERGENTE *** ');
      
        BEGIN 
          UPDATE CECRED.crapsda t 
             SET t.vlsddisp = vr_vldsaldo
           WHERE ROWID      = saldo.dsdrowid;
        
          CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                               ,pr_des_text => '  UPDATE cecred.crapsda SET vlsddisp = '||to_char(NVL(saldo.vlsddisp,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')
                                                            ||'  WHERE rowid = '''||saldo.dsdrowid||'''; ');
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar saldo dia: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => '  Correção de saldo da conta de '||to_char(saldo.vlsddisp,'FM9G999G999G999G990D00')||' para '||to_char(vr_vldsaldo,'FM9G999G999G999G990D00'));
        
      ELSE
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog,pr_des_text => '  *** SALDO CORRETO *** ');
      END IF;
    
    END LOOP;
    
    OPEN  cr_crapsld(conta.cdcooper, conta.nrdconta);
    FETCH cr_crapsld INTO rg_crapsld;
    CLOSE cr_crapsld;
    
    BEGIN
      
      UPDATE CECRED.crapsld t
         SET t.vlsddisp = vr_vldsaldo
       WHERE ROWID = rg_crapsld.dsdrowid;
    
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                           ,pr_des_text => '  UPDATE cecred.crapsld SET vlsddisp = '||to_char(NVL(rg_crapsld.vlsddisp,0),'FM9999999990d00','NLS_NUMERIC_CHARACTERS=''.,''')
                                                       ||'  WHERE rowid = '''||rg_crapsld.dsdrowid||'''; ');
    
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar saldo: '||SQLERRM;
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
