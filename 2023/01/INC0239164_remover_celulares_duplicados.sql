DECLARE

  vr_dtmvtolt DATE := SISTEMA.datascooperativa(3).dtmvtolt;
  
  CURSOR cr_telefo IS 
    SELECT t.cdcooper
         , t.nrdconta
         , t.idseqttl
         , t.cdseqtfc
         , t.cdopetfn
         , t.nrdddtfc
         , t.tptelefo
         , t.nmpescto
         , t.prgqfalt
         , t.nrtelefo
         , t.nrdramal
         , t.secpscto
         , t.idsittfc
         , t.idorigem
         , t.flgacsms
         , t.dtinsori
         , t.dtrefatu
         , t.inprincipal
         , t.inwhatsapp
         , t.rowid   dsdrowid 
         , a.nrcpfcgc
      FROM cecred.crapcop c
         , cecred.crapass a
         , cecred.craptfc t
     WHERE c.cdcooper = a.cdcooper
       AND c.flgativo = 1
       AND a.cdcooper = t.cdcooper 
       AND a.nrdconta = t.nrdconta 
       AND a.dtdemiss IS NULL
       AND t.idseqttl = 1
       AND t.tptelefo = 2 
       AND LENGTH(t.nrtelefo) = 8
       AND EXISTS (SELECT 1
                     FROM cecred.craptfc f
                    WHERE f.cdcooper = t.cdcooper
                      AND f.nrdconta = t.nrdconta
                      AND f.idseqttl = t.idseqttl
                      AND LENGTH(f.nrtelefo) = 9
                      AND to_char(f.nrtelefo) = '9'||to_char(t.nrtelefo))
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
  
  TYPE vr_tpaltdel IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
  TYPE vr_tpaltupd IS TABLE OF VARCHAR2(2000) INDEX BY VARCHAR2(50);
  TYPE vr_tpaltera IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
  
  TYPE vr_rcaltcyb IS RECORD (cdcooper NUMBER, nrdconta NUMBER);
  TYPE vr_tpaltcyb IS TABLE OF vr_rcaltcyb INDEX BY VARCHAR2(50);
  vr_tbaltdel    vr_tpaltdel;
  vr_tbaltupd    vr_tpaltupd;
  vr_tbfonalt    vr_tpaltera;
  vr_tbaltcyb    vr_tpaltcyb;
  vr_split       GENE0002.typ_split;
  
  vr_cdcooper    NUMBER;
  vr_nrdconta    NUMBER;
  vr_tptelefo    NUMBER;
  vr_idvalido    BOOLEAN;
  vr_nrtelefo    NUMBER;
  vr_lgrowid     ROWID;
  vr_contator    NUMBER := 0;
  vr_dscritic    VARCHAR2(1000);
  vr_dscriexp    VARCHAR2(1000);
  vr_exc_erro    EXCEPTION;
  vr_nrseqarq    NUMBER := 1;
  vr_rollback    CLOB;
  vr_buffer      VARCHAR2(2000);
  vr_dsdlinha    VARCHAR2(2000);
  vr_dsindice    VARCHAR2(50);
  
  vr_arq_path    VARCHAR2(1000):= cecred.gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS') || 'cpd/bacas/INC0239164'; 

  vr_nmarqrol    VARCHAR2(100);
  vr_nmarqlog    VARCHAR2(100) := 'INC0239164_2_telefones_removidos.csv';  
  vr_nmarqcyb    VARCHAR2(100) := 'INC0239164_2_altera_cyber_anterior.txt';  

  vr_flarqrol    utl_file.file_type;
  vr_flarqlog    utl_file.file_type;
  vr_flarqcyb    utl_file.file_type;
  
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
  
  vr_nmarqrol := 'INC0239164_2_ROLLBACK_EXCLUI_FONE_'||vr_nrseqarq||'.sql';
  
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
  
  CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog, pr_des_text => 'Coop;Conta;Tipo;Telefone;Status;');


  CECRED.gene0001.pc_abre_arquivo(pr_nmdireto => vr_arq_path   
                                 ,pr_nmarquiv => vr_nmarqcyb   
                                 ,pr_tipabert => 'R'           
                                 ,pr_utlfileh => vr_flarqcyb   
                                 ,pr_des_erro => vr_dscritic); 
                          
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na leitura do arquivo '||vr_nmarqcyb||' -> '||vr_dscritic;
    RAISE vr_exc_erro;
  END IF; 

  IF utl_file.IS_OPEN(vr_flarqcyb) THEN
    LOOP  
      
      BEGIN
        CECRED.gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_flarqcyb 
                                           ,pr_des_text => vr_dsdlinha); 
      EXCEPTION
        WHEN no_data_found THEN
          EXIT;
      END;
         
      IF LENGTH(vr_dsdlinha) <= 1 THEN 
        CONTINUE;
      END IF;
        
      vr_split := gene0002.fn_quebra_string(pr_string => vr_dsdlinha,pr_delimit => ';');
      vr_cdcooper := to_number(TRIM(vr_split(1)));
      vr_nrdconta := to_number(TRIM(vr_split(2)));
      
      vr_dsindice := LPAD(vr_cdcooper,5,'0')||LPAD(vr_nrdconta,10,'0');
      vr_tbaltcyb(vr_dsindice).cdcooper := vr_cdcooper;
      vr_tbaltcyb(vr_dsindice).nrdconta := vr_nrdconta;
      
    END LOOP;    
  END IF;
  
  CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqcyb);
  
  
  FOR telefo IN cr_telefo LOOP
    
    vr_dsindice := LPAD(telefo.nrcpfcgc,20,'0')||LPAD(telefo.nrtelefo,20,'0');
    IF vr_tbfonalt.EXISTS(vr_dsindice) THEN
      CONTINUE;
    ELSE
      vr_tbfonalt(vr_dsindice) := telefo.nrtelefo;
    END IF;
      
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
      vr_nmarqrol := 'INC0239164_2_ROLLBACK_EXCLUI_FONE_'||vr_nrseqarq||'.sql';
        
      dbms_lob.close(vr_rollback);
      dbms_lob.freetemporary(vr_rollback);
        
      dbms_lob.createtemporary(vr_rollback, TRUE);
      dbms_lob.open(vr_rollback, dbms_lob.lob_readwrite);
        
      vr_buffer := 'BEGIN'||CHR(10);
      dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
        
      vr_contator := 0;
    END IF;
    
    BEGIN
        
      DELETE cecred.craptfc t
       WHERE ROWID = telefo.dsdrowid;
        
      vr_buffer := 'INSERT INTO cecred.craptfc '
                || '(cdcooper,nrdconta,idseqttl,cdseqtfc,cdopetfn,nrdddtfc,tptelefo,nmpescto,prgqfalt,nrtelefo,nrdramal,secpscto,idsittfc,idorigem,flgacsms,dtinsori,dtrefatu,inprincipal,inwhatsapp) '
                || ' VALUES ('||to_char(telefo.cdcooper)
                || ', '||to_char(telefo.nrdconta)
                || ', '||to_char(telefo.idseqttl)
                || ', '||to_char(telefo.cdseqtfc)
                || ', '||CASE WHEN to_char(telefo.cdopetfn) IS NULL THEN 'NULL' ELSE to_char(telefo.cdopetfn) END
                || ', '||CASE WHEN to_char(telefo.nrdddtfc) IS NULL THEN 'NULL' ELSE to_char(telefo.nrdddtfc) END
                || ', '||CASE WHEN to_char(telefo.tptelefo) IS NULL THEN 'NULL' ELSE to_char(telefo.tptelefo) END
                || ', '||CASE WHEN telefo.nmpescto IS NULL THEN 'NULL' ELSE ''''||telefo.nmpescto||'''' END
                || ', '||CASE WHEN telefo.prgqfalt IS NULL THEN 'NULL' ELSE ''''||telefo.prgqfalt||'''' END
                || ', '||CASE WHEN to_char(telefo.nrtelefo) IS NULL THEN 'NULL' ELSE to_char(telefo.nrtelefo) END
                || ', '||CASE WHEN to_char(telefo.nrdramal) IS NULL THEN 'NULL' ELSE to_char(telefo.nrdramal) END
                || ', '||CASE WHEN telefo.secpscto IS NULL THEN 'NULL' ELSE telefo.secpscto END
                || ', '||to_char(telefo.idsittfc)
                || ', '||to_char(telefo.idorigem)
                || ', '||to_char(telefo.flgacsms)
                || ', '||CASE WHEN telefo.dtinsori IS NULL THEN 'NULL' ELSE 'to_date('''||to_char(telefo.dtinsori,'dd/mm/yyyy hh24:mi:ss')||''',''dd/mm/yyyy hh24:mi:ss'')' END
                || ', '||CASE WHEN telefo.dtrefatu IS NULL THEN 'NULL' ELSE 'to_date('''||to_char(telefo.dtrefatu,'dd/mm/yyyy hh24:mi:ss')||''',''dd/mm/yyyy hh24:mi:ss'')' END 
                || ', '||CASE WHEN to_char(telefo.inprincipal) IS NULL THEN 'NULL' ELSE to_char(telefo.inprincipal) END 
                || ', '||CASE WHEN to_char(telefo.inwhatsapp)  IS NULL THEN 'NULL' ELSE to_char(telefo.inwhatsapp) END ||'); '||CHR(10);
      
      dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
        
      CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                           ,pr_des_text => telefo.cdcooper||';'||telefo.nrdconta||';'||telefo.tptelefo||';'||telefo.nrtelefo||';EXCLUIDO;'); 
        
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_flarqlog
                                             ,pr_des_text => telefo.cdcooper||';'||telefo.nrdconta||';'||telefo.tptelefo||';'||telefo.nrtelefo||';ERRO AO EXCLUIR REGISTRO;'); 
        
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
                             ,pr_dsdadatu => ' ');
      
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
                           ,'Exc.Telef.'||telefo.nrtelefo||' 1.ttl,'
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
           SET dsaltera = rg_altera.dsaltera||'Exc.Telef.'||telefo.nrtelefo||' 1.ttl,'
         WHERE ROWID    = rg_altera.dsdrowid;
          
        IF NOT vr_tbaltupd.EXISTS(rg_altera.dsdrowid) THEN
          vr_tbaltupd(rg_altera.dsdrowid) := 'UPDATE cecred.crapalt SET dsaltera = '''||SUBSTR(rg_altera.dsaltera,1,1900)||''' WHERE rowid = '''||rg_altera.dsdrowid||'''; ';
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

  vr_nmarqrol := 'INC0239164_2_ROLLBACK_CYBER_FONE.sql';
        
  dbms_lob.close(vr_rollback);
  dbms_lob.freetemporary(vr_rollback);
        
  dbms_lob.createtemporary(vr_rollback, TRUE);
  dbms_lob.open(vr_rollback, dbms_lob.lob_readwrite);
        
  vr_buffer := 'BEGIN'||CHR(10);
  dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
  
  IF vr_tbaltcyb.count() > 0 THEN
  
    vr_dsindice := vr_tbaltcyb.FIRST;
    LOOP
      FOR cyber IN cr_crapcyb(vr_tbaltcyb(vr_dsindice).cdcooper,vr_tbaltcyb(vr_dsindice).nrdconta) LOOP
        BEGIN
          UPDATE cecred.crapcyb 
             SET dtmancad = vr_dtmvtolt 
           WHERE ROWID    = cyber.dsdrowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPCYB: '||SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        IF cyber.dtmancad IS NULL THEN
          vr_buffer := '  UPDATE CECRED.crapcyb SET dtmancad = NULL WHERE rowid = '''||cyber.dsdrowid||'''; '||CHR(10);
        ELSE
          vr_buffer := '  UPDATE CECRED.crapcyb SET dtmancad = to_date('''||to_char(cyber.dtmancad,'dd/mm/yyyy')||''',''dd/mm/yyyy'') WHERE rowid = '''||cyber.dsdrowid||'''; '||CHR(10);
        END IF;
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
        
      END LOOP;
    EXIT WHEN vr_dsindice = vr_tbaltcyb.LAST;
      vr_dsindice := vr_tbaltcyb.NEXT(vr_dsindice);
    END LOOP;
    
  END IF;
  
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
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
      
    pc_carrega_arquivo;
    
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback
                                 ,pr_caminho  => vr_arq_path
                                 ,pr_arquivo  => vr_nmarqrol
                                 ,pr_des_erro => vr_dscriexp);
          
    IF vr_dscritic IS NOT NULL THEN
      vr_dscriexp := 'Erro ao escrever arquivo '||vr_nmarqrol||' -> '||vr_dscriexp;
      RAISE vr_exc_erro;
    END IF; 
       
    dbms_lob.close(vr_rollback);
    dbms_lob.freetemporary(vr_rollback);
    
    CECRED.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_flarqlog);
    
    IF vr_dscriexp IS NULL THEN 
      raise_application_error(-20001, vr_dscritic);
    ELSE 
      raise_application_error(-20001, vr_dscritic||' '||vr_dscriexp);
    END IF;
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
