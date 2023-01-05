DECLARE
  CURSOR cr_capacidade IS
    SELECT l.cdcooper,
           l.nrdconta,
           l.dttransa,
           i.dsdadant,
           i.dsdadatu,
           l.idseqttl,
           t.inhabmen,
           t.rowid ttlrowid
      FROM craplgm l, crapcop c, craplgi i, crapttl t
     WHERE l.cdcooper = c.cdcooper
       AND c.flgativo = 1
       AND l.dstransa =
           'Ajuste de dados cadastrais com dados da SERPRO via Foundation.'
       AND l.dttransa >= '01/12/2022'
       AND l.dsorigem = 'FOUNDATION'
       AND UPPER(l.nmdatela) = 'FOUNDATION'
       AND UPPER(l.cdoperad) = '1'
       AND i.cdcooper = l.cdcooper
       AND i.nrdconta = l.nrdconta
       AND i.idseqttl = l.idseqttl
       AND i.nrsequen = l.nrsequen
       AND i.dttransa = l.dttransa
       AND i.nmdcampo = 'Capacidade civil'
       AND i.dsdadatu = 2
       AND t.cdcooper = l.cdcooper
       AND t.nrdconta = l.nrdconta
       AND t.idseqttl = l.idseqttl
       --AND t.inhabmen = 2
       AND NOT EXISTS (SELECT 1
              FROM crapcrl c
             WHERE c.cdcooper = l.cdcooper
               AND c.nrctamen = l.nrdconta)
     ORDER BY l.cdcooper, l.nrdconta;
     
  CURSOR cr_crapalt ( pr_cdcooper IN CECRED.crapalt.CDCOOPER%TYPE
                    , pr_nrdconta IN CECRED.crapalt.NRDCONTA%TYPE
                    , pr_dtmvtolt IN CECRED.crapalt.DTALTERA%TYPE ) IS
    SELECT a.dsaltera
    FROM CECRED.crapalt a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta
      AND a.dtaltera = pr_dtmvtolt;
  
  vr_dsaltera CECRED.crapalt.dsaltera%TYPE;
  
  vr_dtmvtolt DATE := SISTEMA.datascooperativa(3).dtmvtolt;
  vr_msgalt   VARCHAR2(150);
  vr_lgrowid  ROWID;
  vr_dscritic VARCHAR2(1000);
  vr_exc_erro EXCEPTION;
  vr_nrseqarq NUMBER := 1;
  vr_rollback CLOB;
  vr_buffer   VARCHAR2(2000);
  vr_arq_path VARCHAR2(1000) := cecred.gene0001.fn_param_sistema('CRED',
                                                                 0,
                                                                 'ROOT_MICROS') ||
                                'cpd/bacas/INC0239692';

  vr_nmarqrol VARCHAR2(100);
  
BEGIN
  
  vr_nmarqrol := 'ROLLBACK_CAPAC_CIVIL_' || vr_nrseqarq || '.sql';
  dbms_lob.createtemporary(vr_rollback, TRUE);
  dbms_lob.open(vr_rollback, dbms_lob.lob_readwrite);
  vr_buffer := 'BEGIN' || CHR(10);
  dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
  
  FOR rw_capacidade IN cr_capacidade LOOP
    BEGIN
      UPDATE cecred.crapttl t
         SET t.inhabmen = rw_capacidade.dsdadant
       WHERE t.rowid = rw_capacidade.ttlrowid;
       
      vr_buffer := 'UPDATE cecred.crapttl SET inhabmen = ' ||
                   to_char(rw_capacidade.inhabmen) || ' WHERE rowid = ''' ||
                   rw_capacidade.ttlrowid || '''; ' || CHR(10);
      dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
      
    EXCEPTION
      WHEN OTHERS THEN
        raise_application_error(-20002,
                                'Erro ao atualizar capacidade: ' || SQLERRM);
    END;
    
    gene0001.pc_gera_log(pr_cdcooper => rw_capacidade.cdcooper,
                         pr_cdoperad => '1',
                         pr_dscritic => ' ',
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteracao da Capacidade civil',
                         pr_dttransa => TRUNC(SYSDATE),
                         pr_flgtrans => 1,
                         pr_hrtransa => gene0002.fn_busca_time,
                         pr_idseqttl => 1,
                         pr_nmdatela => 'CONTAS',
                         pr_nrdconta => rw_capacidade.nrdconta,
                         pr_nrdrowid => vr_lgrowid);
                         
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid,
                              pr_nmdcampo => 'inhabmen',
                              pr_dsdadant => rw_capacidade.inhabmen,
                              pr_dsdadatu => rw_capacidade.dsdadant);
                              
    vr_buffer := 'DELETE cecred.craplgi i WHERE EXISTS (SELECT 1 FROM cecred.craplgm m WHERE m.rowid = ''' ||
                 vr_lgrowid || ''' ' ||
                 ' AND i.cdcooper = m.cdcooper AND i.nrdconta = m.nrdconta AND i.idseqttl = m.idseqttl AND ' ||
                 ' i.dttransa = m.dttransa AND i.hrtransa = m.hrtransa AND i.nrsequen = m.nrsequen);' ||
                 CHR(10);
                 
    dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
    
    vr_buffer := 'DELETE cecred.craplgm WHERE rowid = ''' || vr_lgrowid ||
                 '''; ' || CHR(10);
    dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
    
    OPEN cr_crapalt(rw_capacidade.cdcooper, rw_capacidade.nrdconta, vr_dtmvtolt);
    FETCH cr_crapalt INTO vr_dsaltera;
    
    vr_msgalt := 'capacidade civil .crapttl,';
    
    IF cr_crapalt%NOTFOUND THEN
      
      BEGIN
          
        INSERT INTO CECRED.crapalt (
          nrdconta
          , dtaltera
          , cdoperad
          , dsaltera
          , tpaltera
          , cdcooper
        ) VALUES (
          rw_capacidade.nrdconta
          , vr_dtmvtolt
          , 1
          , vr_msgalt
          , 2
          , rw_capacidade.cdcooper
        );
        
        vr_buffer := 'DELETE cecred.crapalt WHERE nrdconta = ' || rw_capacidade.nrdconta
                     || ' and cdcooper = ' || rw_capacidade.cdcooper
                     || ' and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                     || '; ' || CHR(10);
        
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
          
      EXCEPTION
        WHEN OTHERS THEN
            
          vr_dscritic := 'Erro ao Inserir atualização cadastral para conta ' || rw_capacidade.nrdconta 
                         || ' - ' || SQLERRM;
          CLOSE cr_crapalt;
          RAISE vr_exc_erro;
            
      END;
      
    ELSE 
      
      BEGIN
            
        UPDATE CECRED.crapalt
          SET dsaltera = vr_dsaltera || vr_msgalt
        WHERE nrdconta = rw_capacidade.nrdconta
          AND cdcooper = rw_capacidade.cdcooper
          AND dtaltera = vr_dtmvtolt;
          
        
        vr_buffer := 'UPDATE cecred.crapalt '
                     || ' SET vr_dsaltera = ''' || vr_dsaltera || ''' '
                     || ' WHERE nrdconta = ' || rw_capacidade.nrdconta
                     || '   and cdcooper = ' || rw_capacidade.cdcooper
                     || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                     || '; ' || CHR(10);
        
        dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
          
          
      EXCEPTION
        WHEN OTHERS THEN
              
          vr_dscritic := 'Erro ao Complementar atualização cadastral para conta ' || rw_capacidade.nrdconta 
                         || ' - ' || SQLERRM;
          CLOSE cr_crapalt;
          RAISE vr_exc_erro;
              
      END;
      
    END IF;
    
    CLOSE cr_crapalt;
    
  END LOOP;
  
  vr_buffer := 'COMMIT; END;';
  dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
  
  gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback,
                                pr_caminho  => vr_arq_path,
                                pr_arquivo  => vr_nmarqrol,
                                pr_des_erro => vr_dscritic);
                                
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro ao escrever arquivo ' || vr_nmarqrol || ' -> ' ||
                   vr_dscritic;
    RAISE vr_exc_erro;
  END IF;
  
  dbms_lob.close(vr_rollback);
  dbms_lob.freetemporary(vr_rollback);
 
 COMMIT;
 
EXCEPTION
  WHEN vr_exc_erro THEN
    
    ROLLBACK;
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback,
                                  pr_caminho  => vr_arq_path,
                                  pr_arquivo  => vr_nmarqrol,
                                  pr_des_erro => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao escrever arquivo ' || vr_nmarqrol || ' -> ' ||
                     vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    dbms_lob.close(vr_rollback);
    dbms_lob.freetemporary(vr_rollback);
    raise_application_error(-20001, vr_dscritic);
    
  WHEN OTHERS THEN
    
    ROLLBACK;
    vr_buffer := 'COMMIT; END;';
    dbms_lob.writeappend(vr_rollback, length(vr_buffer), vr_buffer);
    gene0002.pc_clob_para_arquivo(pr_clob     => vr_rollback,
                                  pr_caminho  => vr_arq_path,
                                  pr_arquivo  => vr_nmarqrol,
                                  pr_des_erro => vr_dscritic);
                                  
    IF vr_dscritic IS NOT NULL THEN
      vr_dscritic := 'Erro ao escrever arquivo ' || vr_nmarqrol || ' -> ' ||
                     vr_dscritic;
      RAISE vr_exc_erro;
    END IF;
    
    dbms_lob.close(vr_rollback);
    dbms_lob.freetemporary(vr_rollback);
    raise_application_error(-20000, 'ERRO AO EXECUTAR SCRIPT: ' || SQLERRM);
    
END;
