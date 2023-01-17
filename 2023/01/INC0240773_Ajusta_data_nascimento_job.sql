DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0240773_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'INC0240773_dtnasc_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'INC0240773_dtnasc_relatorio.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  vr_cdcooper           CECRED.crapass.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_dtnasttl_new       CECRED.crapttl.DTNASTTL%TYPE;
  vr_dtnasttl_atu       CECRED.crapttl.DTNASTTL%TYPE;
  vr_dtmvtolt           DATE;
  vr_lgrowid            ROWID;
  vr_msgalt             VARCHAR2(150);
  
  CURSOR cr_dados IS 
    SELECT p.nrcpfcgc
      , t.cdcooper
      , t.nrdconta
      , t.idseqttl
      , t.inhabmen
      , t.dtnasttl
      , a.dtadmiss
      , a.dtdemiss
      , ch.nmcampo
      , ph.*
    FROM tbcadast_pessoa_historico ph
    join tbcadast_campo_historico ch on ph.idcampo = ch.idcampo
    join tbcadast_pessoa p on ph.idpessoa = p.idpessoa
    join crapttl t on p.nrcpfcgc = t.nrcpfcgc
    join crapass a on t.nrdconta = a.nrdconta
                      and t.cdcooper = a.cdcooper
    where ch.idcampo = 41
      and to_date(ph.dhalteracao, 'dd/mm/rrrr') >= to_date('18/12/2022', 'dd/mm/rrrr')
      and to_date( to_char(ph.dhalteracao, 'hh24:mi:ss'), 'hh24:mi:ss') between to_date('01:00:00', 'hh24:mi:ss')
                                                                            AND to_date('03:00:00', 'hh24:mi:ss')
    order by p.nrcpfcgc
      , ph.dhalteracao
    ;
  
  rg_dados  cr_dados%ROWTYPE;
  
  TYPE TP_UNIQUE IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(60);
  vr_unicos       TP_UNIQUE;
  vr_dtnasc_cpf   TP_UNIQUE;
  vr_chave        VARCHAR2(60);
  
  CURSOR cr_crapalt ( pr_cdcooper IN CECRED.crapalt.CDCOOPER%TYPE
                    , pr_nrdconta IN CECRED.crapalt.NRDCONTA%TYPE
                    , pr_dtmvtolt IN CECRED.crapalt.DTALTERA%TYPE ) IS
    SELECT a.dsaltera
    FROM CECRED.crapalt a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta
      AND a.dtaltera = pr_dtmvtolt;
  
  vr_dsaltera CECRED.crapalt.dsaltera%TYPE;
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0240773';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');

  vr_count := 0;
  
  OPEN cr_dados;
  LOOP
    
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    vr_cdcooper       := rg_dados.cdcooper;
    vr_nrdconta       := rg_dados.nrdconta;
    vr_nrcpfcgc       := rg_dados.nrcpfcgc;
    vr_dtnasttl_new   := to_date(rg_dados.dsvalor_anterior, 'DD/MM/RRRR');
    vr_dtnasttl_atu   := TO_DATE( to_char(rg_dados.dtnasttl, 'DD/MM/RRRR'), 'DD/MM/RRRR' );
    
    vr_dtmvtolt := SISTEMA.datascooperativa(vr_cdcooper).dtmvtolt;
    
    vr_chave    := vr_nrcpfcgc || '-' || vr_cdcooper || '-' || vr_nrdconta || '-' || TO_CHAR(rg_dados.dhalteracao, 'DD_MM_RRRR_HH24_MI_SS');
    
    IF vr_unicos.exists(vr_chave) THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                    || ';' || vr_nrdconta 
                                                    || ';' || vr_nrcpfcgc 
                                                    || ';ALERTA'
                                                    || ';Chave repetida para CPF x Cooper x Conta x Data do LOG'
                                                    || ';' || to_char(vr_dtnasttl_atu, 'DD/MM/RRRR') 
                                                    || ';' || to_char(vr_dtnasttl_new, 'DD/MM/RRRR') 
                                                    || ';' || to_char(rg_dados.dhalteracao, 'DD/MM/RRRR HH24:MI:SS')
                                                    || ';' || vr_chave);
      
      CONTINUE;
      
    END IF;
    
    vr_unicos(vr_chave) := to_char(vr_dtnasttl_new, 'DD/MM/RRRR');
    
    IF NOT vr_dtnasc_cpf.exists( to_char(vr_nrcpfcgc) ) THEN
      
      vr_dtnasc_cpf( to_char(vr_nrcpfcgc) ) := to_char(vr_dtnasttl_new, 'DD/MM/RRRR');
      
    END IF;
    
    IF TO_DATE( vr_dtnasc_cpf( to_char(vr_nrcpfcgc) ), 'DD/MM/RRRR') = vr_dtnasttl_atu THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                    || ';' || vr_nrdconta 
                                                    || ';' || vr_nrcpfcgc 
                                                    || ';ALERTA'
                                                    || ';Data Nasc. ATUAL e NOVA são iguais'
                                                    || ';' || to_char(vr_dtnasttl_atu, 'DD/MM/RRRR') 
                                                    || ';' || vr_dtnasc_cpf( to_char(vr_nrcpfcgc) )
                                                    || ';' || to_char(rg_dados.dhalteracao, 'DD/MM/RRRR HH24:MI:SS') );
      
    ELSE
    
      BEGIN
          
        UPDATE CECRED.Crapttl
          SET dtnasttl = to_date( vr_dtnasc_cpf( to_char(vr_nrcpfcgc) ), 'DD/MM/RRRR' )
        WHERE cdcooper = vr_cdcooper
          AND nrdconta = vr_nrdconta
          AND nrcpfcgc = vr_nrcpfcgc;
          
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.Crapttl '
                                                      || '   SET dtnasttl = ''' || TO_CHAR(vr_dtnasttl_atu, 'DD/MM/RRRR') || ''' '
                                                      || ' WHERE cdcooper = ' || vr_cdcooper
                                                      || '   AND nrdconta = ' || vr_nrdconta
                                                      || '   AND nrcpfcgc = ' || vr_nrcpfcgc || '; ' );
          
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                      || ';' || vr_nrdconta 
                                                      || ';' || vr_nrcpfcgc 
                                                      || ';SUCESSO'
                                                      || ';Alteração realizada com sucesso na CRAPTTL'
                                                      || ';' || to_char(vr_dtnasttl_atu, 'DD/MM/RRRR') 
                                                      || ';' || vr_dtnasc_cpf( to_char(vr_nrcpfcgc) )
                                                      || ';' || to_char(rg_dados.dhalteracao, 'DD/MM/RRRR HH24:MI:SS') );
          
      EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                        || ';' || vr_nrdconta 
                                                        || ';' || vr_nrcpfcgc 
                                                        || ';ERRO'
                                                        || ';Erro ao atualizar registro na CRAPTTL: ' || SQLERRM );
            
          vr_dscritic := 'Erro ao atualizar a CRAPTTL: ' || SQLERRM;
          
          RAISE vr_exception;
            
      END;
      
      BEGIN
        
        UPDATE CECRED.crapass
          SET dtnasctl = to_date( vr_dtnasc_cpf( to_char(vr_nrcpfcgc) ), 'DD/MM/RRRR' )
        WHERE cdcooper = vr_cdcooper
          AND nrdconta = vr_nrdconta
          AND nrcpfcgc = vr_nrcpfcgc;
        
        IF SQL%ROWCOUNT > 0 THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    UPDATE CECRED.crapass '
                                                        || '   SET dtnasctl = ''' || TO_CHAR(vr_dtnasttl_atu, 'DD/MM/RRRR') || ''' '
                                                        || ' WHERE cdcooper = ' || vr_cdcooper
                                                        || '   AND nrdconta = ' || vr_nrdconta
                                                        || '   AND nrcpfcgc = ' || vr_nrcpfcgc || '; ' );
            
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                        || ';' || vr_nrdconta 
                                                        || ';' || vr_nrcpfcgc 
                                                        || ';SUCESSO'
                                                        || ';Alteração realizada com sucesso na CRAPASS'
                                                        || ';' || to_char(vr_dtnasttl_atu, 'DD/MM/RRRR') 
                                                        || ';' || vr_dtnasc_cpf( to_char(vr_nrcpfcgc) )
                                                        || ';' || to_char(rg_dados.dhalteracao, 'DD/MM/RRRR HH24:MI:SS') );
          
        ELSE
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                        || ';' || vr_nrdconta 
                                                        || ';' || vr_nrcpfcgc 
                                                        || ';ALERTA'
                                                        || ';SEM ajuste na CRAPASS. Titular adicional da conta. Titularidade: ' || rg_dados.idseqttl
                                                        || ';' || to_char(vr_dtnasttl_atu, 'DD/MM/RRRR') 
                                                        || ';' || vr_dtnasc_cpf( to_char(vr_nrcpfcgc) )
                                                        || ';' || to_char(rg_dados.dhalteracao, 'DD/MM/RRRR HH24:MI:SS') );
          
        END IF;
        
      EXCEPTION
        WHEN OTHERS THEN
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_cdcooper 
                                                        || ';' || vr_nrdconta 
                                                        || ';' || vr_nrcpfcgc 
                                                        || ';ERRO'
                                                        || ';Erro ao atualizar registro na CRAPASS: ' || SQLERRM );
            
          vr_dscritic := 'Erro ao atualizar a CRAPASS: ' || SQLERRM;
          
          RAISE vr_exception;
            
      END;
      
      gene0001.pc_gera_log(pr_cdcooper => vr_cdcooper,
                           pr_cdoperad => '1',
                           pr_dscritic => ' ',
                           pr_dsorigem => 'AIMARO',
                           pr_dstransa => 'INC0240773 - Alteracao da Data de Nascimento',
                           pr_dttransa => vr_dtmvtolt,
                           pr_flgtrans => 1,
                           pr_hrtransa => gene0002.fn_busca_time,
                           pr_idseqttl => rg_dados.idseqttl,
                           pr_nmdatela => 'CONTAS',
                           pr_nrdconta => vr_nrdconta,
                           pr_nrdrowid => vr_lgrowid);
      
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_lgrowid,
                                pr_nmdcampo => 'dtnasttl',
                                pr_dsdadant => rg_dados.dtnasttl,
                                pr_dsdadatu => vr_dtnasc_cpf( to_char(vr_nrcpfcgc) ) );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE cecred.craplgi i '
                                                 || ' WHERE EXISTS (SELECT 1 '
                                                 || '               FROM cecred.craplgm m '
                                                 || '               WHERE m.rowid = ''' || vr_lgrowid || ''' ' 
                                                 || '                 AND i.cdcooper = m.cdcooper '
                                                 || '                 AND i.nrdconta = m.nrdconta '
                                                 || '                 AND i.idseqttl = m.idseqttl '
                                                 || '                 AND i.dttransa = m.dttransa '
                                                 || '                 AND i.hrtransa = m.hrtransa '
                                                 || '                 AND i.nrsequen = m.nrsequen);');

      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE cecred.craplgm WHERE rowid = ''' || vr_lgrowid || '''; ');
      
      OPEN cr_crapalt(vr_cdcooper, vr_nrdconta, vr_dtmvtolt);
      FETCH cr_crapalt INTO vr_dsaltera;
      
      vr_msgalt := 'data nascimento ' 
                   || rg_dados.idseqttl || '.ttl .crapttl '
                   || case when rg_dados.idseqttl > 1 then ',' else '.crapass,' end;
      
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
            vr_nrdconta
            , vr_dtmvtolt
            , 1
            , vr_msgalt
            , 2
            , vr_cdcooper
          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE cecred.crapalt '
                                                     || ' WHERE nrdconta = ' || vr_nrdconta
                                                     || '   and cdcooper = ' || vr_cdcooper
                                                     || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                     || '; ' );
          
        EXCEPTION
          WHEN OTHERS THEN
            
            vr_dscritic := 'Erro ao Inserir atualização cadastral para conta ' || vr_nrdconta || ' / ' || vr_cdcooper
                           || ' - ' || SQLERRM;
            
            CLOSE cr_crapalt;
            
            RAISE vr_exception;
            
        END;
        
      ELSE 
        
        BEGIN
              
          UPDATE CECRED.crapalt
            SET dsaltera = vr_dsaltera || vr_msgalt
          WHERE nrdconta = vr_nrdconta
            AND cdcooper = vr_cdcooper
            AND dtaltera = vr_dtmvtolt;
            
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE cecred.crapalt '
                                                     || ' SET dsaltera = ''' || vr_dsaltera || ''' '
                                                     || ' WHERE nrdconta = ' || vr_nrdconta
                                                     || '   and cdcooper = ' || vr_cdcooper
                                                     || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                     || '; ');
          
        EXCEPTION
          WHEN OTHERS THEN
                
            vr_dscritic := 'Erro ao Complementar atualização cadastral para conta ' || vr_nrdconta || ' / ' || vr_cdcooper
                           || ' - ' || SQLERRM;
            
            CLOSE cr_crapalt;
            RAISE vr_exception;
                
        END;
        
      END IF;
      
      CLOSE cr_crapalt;
      
    END IF;
    
    vr_count := vr_count + 1;
    
    IF vr_count >= 500 THEN
      
      vr_count := 0;
      COMMIT;
      
    END IF;
    
  END LOOP;
  
  CLOSE cr_dados;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION 
  
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;
