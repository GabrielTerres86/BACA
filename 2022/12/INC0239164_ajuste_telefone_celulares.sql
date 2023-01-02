DECLARE

  vr_dtmvtolt DATE := SISTEMA.datascooperativa(3).dtmvtolt;
  
  CURSOR cr_telefo IS 
    SELECT a.cdcooper 
         , a.nrdconta 
         , a.nrcpfcgc
         , t.nrdddtfc 
         , t.nrtelefo
         , t.dtrefatu
         , t.prgqfalt
         , t.tptelefo
         , t.rowid dsdrowid 
      FROM cecred.crapcop c
         , cecred.crapass a
         , cecred.craptfc t
     WHERE c.cdcooper = a.cdcooper
       AND c.flgativo = 1
       AND a.cdcooper = t.cdcooper 
       AND a.nrdconta = t.nrdconta
       AND a.dtdemiss IS NULL
       AND t.tptelefo = 2 
       AND (LENGTH(t.nrtelefo) <> 9)
     ORDER BY t.cdcooper, t.nrdconta;
   
  CURSOR cr_altera(pr_cdcooper  NUMBER
                  ,pr_nrdconta  NUMBER) IS
    SELECT t.dsaltera
         , ROWID  dsdrowid
      FROM cecred.crapalt t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtaltera = vr_dtmvtolt;
  rg_altera  cr_altera%ROWTYPE;
  
  CURSOR cr_crapcyb(pr_cdcooper  NUMBER
                   ,pr_nrdconta  NUMBER) IS
    SELECT t.dtmancad
         , ROWID dsdrowid
      FROM cecred.crapcyb t
     WHERE t.cdcooper = pr_cdcooper
       AND t.nrdconta = pr_nrdconta
       AND t.dtdbaixa IS NULL; 
  
  TYPE vr_tpaltdel IS TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(50);
  TYPE vr_tpaltupd IS TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(50);
  TYPE vr_tpaltera IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
  
  TYPE vr_rcaltcyb IS RECORD (cdcooper NUMBER, nrdconta NUMBER);
  TYPE vr_tpaltcyb IS TABLE OF vr_rcaltcyb INDEX BY VARCHAR2(50);
  vr_tbaltdel    vr_tpaltdel;
  vr_tbaltupd    vr_tpaltupd;
  vr_tbfonalt    vr_tpaltera;
  vr_tbaltcyb    vr_tpaltcyb;
  
  vr_tptelefo    NUMBER;
  vr_idvalido    BOOLEAN;
  vr_nrtelefo    NUMBER;
  vr_lgrowid     ROWID;
  vr_contator    NUMBER := 0;
  vr_dscritic    VARCHAR2(1000);
  vr_exc_erro    EXCEPTION;
  vr_nrseqarq    NUMBER := 1;
  vr_rollback    CLOB;
  vr_buffer      VARCHAR2(2000);
  vr_dsindice    VARCHAR2(50);
  
  vr_arq_path    VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0239164'; 

  vr_nmarqrol    VARCHAR2(100);
  vr_nmarqlog    VARCHAR2(100) := 'INC0239164_telefones_processados.csv';  
  vr_nmarqcyb    VARCHAR2(100) := 'INC0239164_atualizar_cyber.csv';  

  vr_flarqrol    utl_file.file_type;
  vr_flarqlog    utl_file.file_type;
  vr_flarqcyb    utl_file.file_type;
  
  PROCEDURE pc_valida_telefone(pr_nrtelefo  IN NUMBER
                              ,pr_tptelefo OUT NUMBER
                              ,pr_idvalido OUT BOOLEAN) IS

  BEGIN
    
    IF LENGTH(pr_nrtelefo) = 9 AND SUBSTR(pr_nrtelefo,1,1) = '9' THEN
      pr_tptelefo := 2;
      pr_idvalido := TRUE;
      RETURN;
    ELSIF LENGTH(pr_nrtelefo) > 9 THEN
      pr_tptelefo := 0;
      pr_idvalido := FALSE;
      RETURN;
    ELSIF LENGTH(pr_nrtelefo) = 8 THEN
      IF SUBSTR(pr_nrtelefo,1,1) IN ('9','8') THEN
        pr_tptelefo := 2;
        pr_idvalido := FALSE;
        RETURN;
      ELSIF SUBSTR(pr_nrtelefo,1,1) = '7' THEN
        pr_tptelefo := 2;
        pr_idvalido := TRUE;
        RETURN;
      ELSE
        pr_tptelefo := 1;
        pr_idvalido := FALSE;
        RETURN;
      END IF;
    END IF;
    
    pr_tptelefo := 0;
    pr_idvalido := FALSE;
    
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20001,'Erro ao validar telefone: '||SQLERRM);
  END pc_valida_telefone;
  
  PROCEDURE pc_carrega_arquivo IS
    
  BEGIN
    
    IF vr_tbaltupd.count() > 0 THEN
      vr_dsindice := vr_tbaltupd.FIRST;
      LOOP
        vr_buffer := vr_tbaltupd(vr_dsindice)||CHR(10);
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
      EXIT WHEN vr_dsindice = vr_tbaltupd.LAST;
        vr_dsindice := vr_tbaltupd.NEXT(vr_dsindice);
      END LOOP;
    END IF;
    
    IF vr_tbaltdel.count() > 0 THEN
      vr_dsindice := vr_tbaltdel.FIRST;
      LOOP
        vr_buffer := vr_tbaltdel(vr_dsindice)||CHR(10);
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
      EXIT WHEN vr_dsindice = vr_tbaltdel.LAST;
        vr_dsindice := vr_tbaltdel.NEXT(vr_dsindice);
      END LOOP;
    END IF;
    
    vr_tbaltdel.DELETE();
    vr_tbaltupd.DELETE();
    
  END;
  
BEGIN
  
  vr_tbaltdel.DELETE();
  vr_tbaltupd.DELETE();
  
  vr_nmarqrol := 'INC0239164_ROLLBACK_TELEFONES_'||vr_nrseqarq||'.sql';
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqlog   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqlog   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqlog||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  dbms_lob.createtemporary(vr_rollback, TRUE);
  dbms_lob.open(vr_rollback, dbms_lob.lob_readwrite);
  
  vr_buffer := 'BEGIN'||CHR(10);
  dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog, pr_des_text => 'Coop;Conta;Tipo;Cadastrado;Alterado;Ajustado;');


  FOR telefo IN cr_telefo LOOP
    
    vr_dsindice := LPAD(telefo.nrcpfcgc,20,'0')||LPAD(telefo.nrtelefo,20,'0');
    IF vr_tbfonalt.EXISTS(vr_dsindice) THEN
      CONTINUE;
    ELSE
      vr_tbfonalt(vr_dsindice) := telefo.nrtelefo;
    END IF;
    
    pc_valida_telefone(pr_nrtelefo => telefo.nrtelefo
                      ,pr_tptelefo => vr_tptelefo
                      ,pr_idvalido => vr_idvalido);
    
    IF vr_tptelefo = 2 AND NOT vr_idvalido THEN
      
      vr_contator := vr_contator + 1;
    
      IF vr_contator >= 4000 THEN
        COMMIT;
        pc_carrega_arquivo;
        
        vr_buffer := 'COMMIT; END;';
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
        
        gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback
                                     ,pr_caminho  => vr_arq_path
                                     ,pr_arquivo  => vr_nmarqrol
                                     ,pr_des_erro => vr_dscritic);
        
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Erro ao escrever arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
          RAISE vr_exc_erro;
        END IF; 
        
        vr_nrseqarq := vr_nrseqarq + 1;
        vr_nmarqrol := 'INC0239164_ROLLBACK_TELEFONES_'||vr_nrseqarq||'.sql';
        
        dbms_lob.close(vr_rollback);
        dbms_lob.freetemporary(vr_rollback);
        
        dbms_lob.createtemporary(vr_rollback, TRUE);
        dbms_lob.open(vr_rollback, dbms_lob.lob_readwrite);
        
        vr_buffer := 'BEGIN'||CHR(10);
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
        
        vr_contator := 0;
      END IF;
    
      BEGIN
        
        vr_nrtelefo := to_number('9'||to_char(telefo.nrtelefo));
      
        UPDATE cecred.craptfc t
           SET t.nrtelefo = vr_nrtelefo
             , t.dtrefatu = vr_dtmvtolt
             , t.prgqfalt = 'A'
         WHERE ROWID = telefo.dsdrowid;
        
        vr_buffer := 'UPDATE cecred.craptfc SET nrtelefo = '||to_char(telefo.nrtelefo)
                                                          || ', dtrefatu = to_date('''||to_char(telefo.dtrefatu,'dd/mm/yyyy')||''',''DD/MM/YYYY'')'
                                                          || ', prgqfalt = '''||to_char(telefo.prgqfalt)||''''
                                                          || ' WHERE rowid = '''||telefo.dsdrowid||'''; '||CHR(10);
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
        
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => telefo.cdcooper||';'||telefo.nrdconta||';'||telefo.tptelefo||';'||telefo.nrtelefo||';'||vr_nrtelefo||';CORRIGIDO;'); 
        
      EXCEPTION
        WHEN dup_val_on_index THEN
          CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                               ,pr_des_text => telefo.cdcooper||';'||telefo.nrdconta||';'||telefo.tptelefo||';'||telefo.nrtelefo||';'||vr_nrtelefo||';TELEFONE DUPLICADO;'); 
          CONTINUE;
        WHEN OTHERS THEN
          raise_application_error(-20002,'Erro ao atualizar telefone: '||SQLERRM);
      END;
      
      gene0001.pc_gera_log(pr_cdcooper => telefo.cdcooper
                          ,pr_cdoperad => '1'
                          ,pr_dscritic => ' '
                          ,pr_dsorigem => 'AIMARO'
                          ,pr_dstransa => 'Alteracao de Telefone'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'CONTAS'
                          ,pr_nrdconta => telefo.nrdconta
                          ,pr_nrdrowid => vr_lgrowid);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid
                               ,pr_nmdcampo => 'nrtelefo'
                               ,pr_dsdadant => telefo.nrtelefo
                               ,pr_dsdadatu => vr_nrtelefo);
      
      vr_buffer := 'DELETE cecred.craplgi i WHERE EXISTS (SELECT 1 FROM cecred.craplgm m WHERE m.rowid = '''||vr_lgrowid||''' '
                                                          || ' AND i.cdcooper = m.cdcooper AND i.nrdconta = m.nrdconta AND i.idseqttl = m.idseqttl AND '
                                                          || ' i.dttransa = m.dttransa AND i.hrtransa = m.hrtransa AND i.nrsequen = m.nrsequen);'||CHR(10);
      dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
      
      vr_buffer := 'DELETE cecred.craplgm WHERE rowid = '''||vr_lgrowid||'''; '||CHR(10);
      dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
      
      OPEN  cr_altera(telefo.cdcooper,telefo.nrdconta);
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
                      VALUES (telefo.nrdconta
                             ,vr_dtmvtolt
                             ,'1'
                             ,'Telef.'||telefo.nrtelefo||'-'||vr_nrtelefo||' 1.ttl,'
                             ,2
                             ,telefo.cdcooper) RETURNING ROWID INTO rg_altera.dsdrowid;
          
          IF NOT vr_tbaltdel.EXISTS(rg_altera.dsdrowid) THEN
            vr_tbaltdel(rg_altera.dsdrowid) := 'DELETE cecred.crapalt WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
          END IF;     
                      
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20003,'Erro ao incluir registro na ALTERA: '||SQLERRM);
        END;
        
      ELSE
        
        BEGIN
          UPDATE cecred.crapalt
             SET dsaltera = rg_altera.dsaltera||'Telef.'||telefo.nrtelefo||'-'||vr_nrtelefo||' 1.ttl,'
           WHERE ROWID    = rg_altera.dsdrowid;
          
          IF NOT vr_tbaltupd.EXISTS(rg_altera.dsdrowid) THEN
            vr_tbaltupd(rg_altera.dsdrowid) := 'UPDATE cecred.crapalt SET dsaltera = '''||rg_altera.dsaltera||''' WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
          END IF;
                           
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20004,'Erro ao atualizar registro na ALTERA: '||SQLERRM);
        END;
        
      END IF;
      
      CLOSE cr_altera;
      
      vr_dsindice := LPAD(telefo.cdcooper,5,'0')||LPAD(telefo.nrdconta,10,'0');
      vr_tbaltcyb(vr_dsindice).cdcooper := telefo.cdcooper;
      vr_tbaltcyb(vr_dsindice).nrdconta := telefo.nrdconta;
      
    ELSE
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                           ,pr_des_text => telefo.cdcooper||';'||telefo.nrdconta||';'||telefo.tptelefo||';'||telefo.nrtelefo||';;'||'NAO ALTERADO;'); 
    END IF;
    
  END LOOP;
  
  pc_carrega_arquivo;
  
  vr_buffer := 'COMMIT; END;';
  dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
  
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback
                               ,pr_caminho  => vr_arq_path
                               ,pr_arquivo  => vr_nmarqrol
                               ,pr_des_erro => vr_dscritic);
        
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao escrever arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
     
  dbms_lob.close(vr_rollback);
  dbms_lob.freetemporary(vr_rollback);
  
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
  
  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqcyb   
                                 ,pr_tipabert => 'W'           
                                 ,pr_utlfileh => vr_flarqcyb   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo '||vr_nmarqcyb||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqcyb, pr_des_text => 'DECLARE');
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqcyb, pr_des_text => '  vr_dtmvtolt DATE := SISTEMA.datascooperativa(3).dtmvtolt;');
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqcyb, pr_des_text => 'BEGIN');
  
  IF vr_tbaltcyb.count() > 0 THEN
  
    vr_dsindice := vr_tbaltcyb.FIRST;
    LOOP
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqcyb
                                           ,pr_des_text => '  UPDATE cecred.crapcyb SET dtmancad = vr_dtmvtolt WHERE cdcooper='||vr_tbaltcyb(vr_dsindice).cdcooper||' and nrdconta='||vr_tbaltcyb(vr_dsindice).nrdconta||' and dtdbaixa IS NULL;');

    EXIT WHEN vr_dsindice = vr_tbaltcyb.LAST;
      vr_dsindice := vr_tbaltcyb.NEXT(vr_dsindice);
    END LOOP;
    
  END IF;
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqcyb, pr_des_text => '  COMMIT;');
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqcyb, pr_des_text => 'END;');
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqcyb);
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
      
    pc_carrega_arquivo;
    
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => vr_nmarqrol
                                 ,pr_des_erro => vr_dscritic);
          
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao escrever arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
       
    dbms_lob.close(vr_rollback);
    dbms_lob.freetemporary(vr_rollback);
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    raise_application_error(-20001, vr_dscritic);
    
  WHEN OTHERS THEN
    ROLLBACK;
    
    pc_carrega_arquivo;
    
    vr_buffer := 'COMMIT; END;';
    dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
    
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => vr_nmarqrol
                                 ,pr_des_erro => vr_dscritic);
          
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao escrever arquivo '||vr_nmarqrol||' -> '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
       
    dbms_lob.close(vr_rollback);
    dbms_lob.freetemporary(vr_rollback);
  
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    raise_application_error(-20000,'ERRO AO EXECUTAR SCRIPT: '||SQLERRM);
END;
