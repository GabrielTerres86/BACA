DECLARE

  CURSOR cr_crapass is
    SELECT a.cdcooper
         , a.nrdconta
         , a.cdagenci
         , ROWID dsdrowid
      FROM CECRED.CRAPASS a
     WHERE a.cdcooper = 13
       AND a.cdagenci = 11
       AND a.dtdemiss IS NULL;
  
  CURSOR cr_altera(pr_cdcooper  NUMBER
                  ,pr_nrdconta  NUMBER
                  ,pr_dtmvtolt  DATE) IS
    SELECT t.dsaltera
         , ROWID  dsdrowid
      FROM cecred.crapalt t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtaltera = pr_dtmvtolt;
  rg_altera  cr_altera%ROWTYPE;
  
  vr_arq_path    VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0249724'; 

  vr_nmarqrol    VARCHAR2(100) := 'INC0249724_script_rollback.sql';
  vr_nmarqlog    VARCHAR2(100) := 'INC0249724_script_log.txt';  

  vr_flarqrol    utl_file.file_type;
  vr_flarqlog    utl_file.file_type;
  
  TYPE vr_tpaltdel IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
  TYPE vr_tpaltupd IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
  
  vr_tbaltdel    vr_tpaltdel;
  vr_tbaltupd    vr_tpaltupd;
  vr_dsindice    VARCHAR2(50);
  vr_cdagenew    CONSTANT NUMBER := 1;
  vr_dtmvtolt    DATE := datascooperativa(13).dtmvtolt;
  vr_lgrowid     ROWID;
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
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                       ,pr_des_text => 'BEGIN'); 

  
  FOR conta IN cr_crapass LOOP
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                         ,pr_des_text => 'Alterando PA da conta: '||conta.nrdconta); 
  
    BEGIN 
      UPDATE CECRED.crapass t 
         SET t.cdagenci = vr_cdagenew
           , t.dtultalt = vr_dtmvtolt
       WHERE ROWID      = conta.dsdrowid;
        
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                           ,pr_des_text => '  UPDATE cecred.crapass SET cdagenci = '||to_char(conta.cdagenci)||'  WHERE rowid = '''||conta.dsdrowid||'''; ');
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar saldo dia: '||SQLERRM;
        RAISE vr_exc_erro;
    END;
    
    gene0001.pc_gera_log(pr_cdcooper => conta.cdcooper
                        ,pr_cdoperad => '1'
                        ,pr_dscritic => ' '
                        ,pr_dsorigem => 'AIMARO'
                        ,pr_dstransa => 'Altera dados da Conta Corrente'
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1
                        ,pr_hrtransa => gene0002.fn_busca_time
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => ''
                        ,pr_nrdconta => conta.nrdconta
                        ,pr_nrdrowid => vr_lgrowid);
      
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                             ,pr_nmdcampo => 'cdagenci'
                             ,pr_dsdadant => conta.cdagenci
                             ,pr_dsdadatu => vr_cdagenew);
  
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                             ,pr_nmdcampo => 'dtultalt'
                             ,pr_dsdadant => NULL
                             ,pr_dsdadatu => to_char(vr_dtmvtolt,'dd/mm/yyyy'));
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                         ,pr_des_text => '  DELETE cecred.craplgi i WHERE EXISTS (SELECT 1 FROM cecred.craplgm m WHERE m.rowid = '''||vr_lgrowid||''' '
                                                      || ' AND i.cdcooper = m.cdcooper AND i.nrdconta = m.nrdconta AND i.idseqttl = m.idseqttl AND '
                                                      || ' i.dttransa = m.dttransa AND i.hrtransa = m.hrtransa AND i.nrsequen = m.nrsequen);');
    
    CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol
                                         ,pr_des_text => '  DELETE cecred.craplgm WHERE rowid = '''||vr_lgrowid||'''; ');
    
    
    OPEN  cr_altera(conta.cdcooper,conta.nrdconta,vr_dtmvtolt);
    FETCH cr_altera INTO rg_altera;
      
    IF cr_altera%NOTFOUND THEN
        
      BEGIN
        INSERT INTO cecred.crapalt
                           (nrdconta
                           ,dtaltera
                           ,cdoperad
                           ,dsaltera
                           ,tpaltera
                           ,cdcooper)
                    VALUES (conta.nrdconta
                           ,vr_dtmvtolt
                           ,'1'
                           ,'PA '||conta.cdagenci||'-'||vr_cdagenew||','
                           ,2
                           ,conta.cdcooper) RETURNING ROWID INTO rg_altera.dsdrowid;
          
        IF NOT vr_tbaltdel.EXISTS(rg_altera.dsdrowid) THEN
          vr_tbaltdel(rg_altera.dsdrowid) := '  DELETE cecred.crapalt WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
        END IF;     
                      
      EXCEPTION
        WHEN OTHERS THEN
          raise_application_error(-20003,'Erro ao incluir registro na ALTERA: '||SQLERRM);
      END;
        
    ELSE
        
      BEGIN
        UPDATE cecred.crapalt
           SET dsaltera = rg_altera.dsaltera||'PA '||conta.cdagenci||'-'||vr_cdagenew||','
         WHERE ROWID    = rg_altera.dsdrowid;
          
          IF NOT vr_tbaltupd.EXISTS(rg_altera.dsdrowid) THEN
            vr_tbaltupd(rg_altera.dsdrowid) := '  UPDATE cecred.crapalt SET dsaltera = '''||rg_altera.dsaltera||''' WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
          END IF;
                           
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20004,'Erro ao atualizar registro na ALTERA: '||SQLERRM);
        END;
        
    END IF;
      
    CLOSE cr_altera;
    
  END LOOP;
  
  IF vr_tbaltupd.count() > 0 THEN
    vr_dsindice := vr_tbaltupd.FIRST;
    LOOP
      
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => vr_tbaltupd(vr_dsindice));
    
    EXIT WHEN vr_dsindice = vr_tbaltupd.LAST;
      vr_dsindice := vr_tbaltupd.NEXT(vr_dsindice);
    END LOOP;
  END IF;
    
  IF vr_tbaltdel.count() > 0 THEN
    vr_dsindice := vr_tbaltdel.FIRST;
    LOOP
      
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqrol, pr_des_text => vr_tbaltdel(vr_dsindice));
    
    EXIT WHEN vr_dsindice = vr_tbaltdel.LAST;
      vr_dsindice := vr_tbaltdel.NEXT(vr_dsindice);
    END LOOP;
  END IF;
  
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
