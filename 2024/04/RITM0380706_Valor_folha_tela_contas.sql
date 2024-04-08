DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0380706_dados.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0380706_script_ROLLBACK.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0380706_relatorio_exec.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arquiv2        utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_msgalt             VARCHAR2(600);
  
  CURSOR cr_colaborador IS
    SELECT c.cdusured
      , t.cdcooper
      , c.cdcooper  coop_colaborador
      , t.nrdconta
      , t.nrcpfcgc
      , t.idseqttl
      , t.rowid       idregttl
      , t.vlsalari
      , a.flgrestr
    from CECRED.tbcadast_colaborador c
    join CECRED.crapass a on c.nrcpfcgc = a.nrcpfcgc
    join CECRED.crapttl t on a.cdcooper = t.cdcooper
                      and a.nrdconta = t.nrdconta
                      and a.nrcpfcgc = t.nrcpfcgc
    WHERE a.dtdemiss is null
      AND c.flgativo = 'A';
  
  rg_colab          cr_colaborador%ROWTYPE;
  
  
  CURSOR cr_crapalt ( pr_cdcooper IN CECRED.crapalt.CDCOOPER%TYPE
                    , pr_nrdconta IN CECRED.crapalt.NRDCONTA%TYPE
                    , pr_dtmvtolt IN CECRED.crapalt.DTALTERA%TYPE ) IS
    SELECT a.dsaltera
    FROM CECRED.crapalt a
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrdconta = pr_nrdconta
      AND a.dtaltera = pr_dtmvtolt;
  
  vr_dsaltera CECRED.crapalt.dsaltera%TYPE;
  
  CURSOR cr_dados(pr_dsxmlarq CLOB) IS
    WITH DATA AS (SELECT pr_dsxmlarq xml FROM dual)
    SELECT TotalLancMesRAuto
      , TotalLancMesRenAutoAnt
      , referencia
    FROM DATA
       , XMLTABLE(('/Root/RendaAutomatica')
                  PASSING XMLTYPE(xml)
                  COLUMNS TotalLancMesRAuto      VARCHAR2(500)   PATH 'TotalLancMesRenAuto'
                        , TotalLancMesRenAutoAnt VARCHAR2(500)   PATH 'TotalLancMesRenAutoAnt' 
                        , referencia             VARCHAR2(100)   PATH 'referencia');
    
  rw_dados  cr_dados%ROWTYPE;
  
  VR_COMMENT        VARCHAR2(2000);
  vr_base_log       VARCHAR2(2000);
  vr_retxml         XMLType;
  vr_ret            STRING(32767);
  vr_des_erro       VARCHAR2(4000);
  vr_nrdrowid       ROWID;
  vr_dscritic_out   VARCHAR2(2000);
  vr_cdcritic       PLS_INTEGER;
  vr_mesref         VARCHAR2(60);
  vr_vlref          CECRED.tbfolha_lanaut.VLRENDA%TYPE;
  vr_dtmvtolt       DATE := SISTEMA.datascooperativa(3).dtmvtolt;
  vr_hrtransa       CECRED.craplgm.HRTRANSA%TYPE;
  vr_exception      EXCEPTION;
  
BEGIN
  
  DBMS_OUTPUT.disable;
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0380706';
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic_out);
                          
  IF vr_dscritic_out IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic_out);
                          
  IF vr_dscritic_out IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  
  vr_count := 0;
  
  OPEN cr_colaborador;
  LOOP
    FETCH cr_colaborador INTO rg_colab;
    EXIT WHEN cr_colaborador%NOTFOUND;
    
    vr_vlref  := 0;
    vr_mesref := '';
    vr_retxml := NULL;
    
    vr_base_log := rg_colab.cdcooper || ';' || 
        rg_colab.coop_colaborador    || ';' ||
        rg_colab.nrdconta            || ';' || 
        rg_colab.nrcpfcgc            || ';' ||
        rg_colab.idseqttl            || ';';
    
    BEGIN
      VR_COMMENT := ' *** chamar rotina que busca lancamentos automaticos';
      FOLH0001.pc_busca_rendas_aut_sub(pr_nrdconta => rg_colab.nrdconta,
                                       pr_cdcooper => rg_colab.cdcooper,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic_out,
                                       pr_retxml   => vr_retxml,
                                       pr_des_erro => vr_des_erro);
      
    EXCEPTION
      WHEN OTHERS THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
          vr_base_log ||
          to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
          vr_mesref                                      || ';' ||
          to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
          'ERRO Não tratado ao chamar a FOLH0001.pc_busca_rendas_aut_sub: ' || SQLERRM
        );
        
        CONTINUE;
    END;
    
    IF TRIM(vr_dscritic_out) IS NOT NULL THEN
      RAISE vr_exception;
    END IF;
    
    CASE WHEN vr_retxml IS NOT NULL THEN
      
      vr_ret := TRIM(vr_retxml.extract('/Root').getstringval());
      IF INSTR(vr_ret, 'ERRO') > 0 THEN
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
          vr_base_log ||
          to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
          vr_mesref                                      || ';' ||
          to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
          'ERRO a extrair xml da vr_retxml: ' ||  REPLACE( vr_ret, CHR(10), ' ' )
        );
        
        CONTINUE;
      END IF;
          
    ELSE
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
        vr_base_log ||
        to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
        vr_mesref                                      || ';' ||
        to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
        'Sem dados na vr_retxml. Retornou nulo da procedure pc_busca_rendas_aut_sub. '
      );
      
      CONTINUE;
      
    END CASE;
    
    VR_COMMENT := ' *** Devido a nova regra, o valor da renda automática já vem calculada no XML na tag TotalLancMesRAuto.';
    
    rw_dados := NULL;
    OPEN cr_dados( to_clob(vr_ret) );
    FETCH cr_dados INTO rw_dados;
        
    IF cr_dados%FOUND THEN
      
      vr_vlref  := CECRED.gene0002.fn_char_para_number(rw_dados.TotalLancMesRAuto);
      vr_mesref := rw_dados.referencia;
      
    ELSE
      
      vr_vlref    := 0;
      vr_mesref   := ' ';
      
    END IF;
          
    CLOSE cr_dados;
    
    IF NVL(vr_vlref, 0) > 0 AND NVL(vr_vlref, 0) > NVL(rg_colab.vlsalari, 0) THEN
      
      vr_dtmvtolt := SISTEMA.datascooperativa(rg_colab.cdcooper).dtmvtolt;
      
      BEGIN
        
        UPDATE CECRED.crapttl 
          SET vlsalari = vr_vlref 
        WHERE ROWID = rg_colab.idregttl;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'UPDATE CECRED.crapttl SET vlsalari = ' || REPLACE(rg_colab.vlsalari, ',', '.') || ' WHERE ROWID = ''' || rg_colab.idregttl || '''; ');
        
      EXCEPTION
        WHEN OTHERS THEN
          
          vr_dscritic_out := 'Erro ao atualizar a renda na TTL: ' || SQLERRM;
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
            vr_base_log ||
            to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
            vr_mesref                                      || ';' ||
            to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
            'ERRO: ' || vr_dscritic_out
          );
          
          VR_COMMENT := ' *** Encerra tratativa do registro atual e vai para o próximo.';
          CONTINUE;
          
      END;
      
      vr_hrtransa := gene0002.fn_busca_time;
      vr_nrdrowid := NULL;
      
      BEGIN
        
        VR_COMMENT := ' *** Criar registro do LOG guardando o Rowid.';
        INSERT INTO craplgm(cdcooper
          ,cdoperad
          ,dscritic
          ,dsorigem
          ,dstransa
          ,dttransa
          ,flgtrans
          ,hrtransa
          ,idseqttl
          ,nmdatela
          ,nrdconta)
        VALUES(rg_colab.cdcooper
          ,1
          ,NULL
          ,'Script'
          ,'RITM0380706 - Atualização do valor da renda conforme rendas automáticas.'
          ,vr_dtmvtolt
          ,1
          ,vr_hrtransa
          ,1
          ,substr('JOB',1,12)
          ,rg_colab.nrdconta)
        RETURNING ROWID INTO vr_nrdrowid;
        
      EXCEPTION
        WHEN OTHERS THEN
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
            vr_base_log ||
            to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
            vr_mesref                                      || ';' ||
            to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
            'ERRO Não tratado ao gerar VERLOG: ' || SQLERRM
          );
          
      END;
      
      IF vr_nrdrowid IS NOT NULL THEN
        
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                        ,pr_nmdcampo  => 'vlsalari'
                                        ,pr_dsdadant  => to_char(rg_colab.vlsalari, 'FM999G999G999D99')
                                        ,pr_dsdadatu  => to_char(vr_vlref, 'FM999G999G999D99')
                                        );
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    DELETE cecred.craplgi i '
                                                      || ' WHERE EXISTS '
                                                      || ' ( SELECT 1 FROM cecred.craplgm m '
                                                      || '   WHERE m.rowid = ''' || vr_nrdrowid || ''' ' 
                                                      || '     AND i.cdcooper = m.cdcooper '
                                                      || '     AND i.nrdconta = m.nrdconta '
                                                      || '     AND i.idseqttl = m.idseqttl '
                                                      || '     AND i.dttransa = m.dttransa '
                                                      || '     AND i.hrtransa = m.hrtransa '
                                                      || '     AND i.nrsequen = m.nrsequen);' );
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  DELETE cecred.craplgm WHERE rowid = ''' || vr_nrdrowid || '''; ' );
        
      END IF;
      
      OPEN cr_crapalt(rg_colab.cdcooper, rg_colab.nrdconta, vr_dtmvtolt);
      FETCH cr_crapalt INTO vr_dsaltera;
      
      vr_msgalt := 'RITM0380706 - carga renda principal com renda auto ' 
                   || rg_colab.idseqttl || '.ttl .crapttl,';
      
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
            rg_colab.nrdconta
            , vr_dtmvtolt
            , 1
            , vr_msgalt
            , 1
            , rg_colab.cdcooper
          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' DELETE cecred.crapalt '
                                                     || ' WHERE nrdconta = ' || rg_colab.nrdconta
                                                     || '   and cdcooper = ' || rg_colab.cdcooper
                                                     || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                     || '; ' );
          
        EXCEPTION
          WHEN OTHERS THEN
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
              vr_base_log ||
              to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
              vr_mesref                                      || ';' ||
              to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
              'ERRO ao inserir na CRAPALT: ' || SQLERRM
            );
            
        END;
        
      ELSE 
        
        BEGIN
          
          UPDATE CECRED.crapalt
            SET dsaltera = vr_dsaltera || vr_msgalt
              , tpaltera = 1
          WHERE nrdconta = rg_colab.nrdconta
            AND cdcooper = rg_colab.cdcooper
            AND dtaltera = vr_dtmvtolt;
            
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE cecred.crapalt '
                                                     || ' SET dsaltera = ''' || vr_dsaltera || ''' '
                                                     || ' WHERE nrdconta = ' || rg_colab.nrdconta
                                                     || '   and cdcooper = ' || rg_colab.cdcooper
                                                     || '   and dtaltera = to_date( ''' || to_char(vr_dtmvtolt, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'')'
                                                     || '; ');
          
        EXCEPTION
          WHEN OTHERS THEN
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
              vr_base_log ||
              to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
              vr_mesref                                      || ';' ||
              to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
              'ERRO ao atualizar CRAPALT: ' || SQLERRM
            );
                
        END;
        
      END IF;
      
      CLOSE cr_crapalt;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' ');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
        vr_base_log ||
        to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
        vr_mesref                                      || ';' ||
        to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
        'Rendimento atualizado'
      );
      
      vr_count := vr_count + 1;
      
    ELSE
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 
        vr_base_log ||
        to_char(rg_colab.vlsalari, 'FM999G999G999D99') || ';' ||
        vr_mesref                                      || ';' ||
        to_char(vr_vlref, 'FM999G999G999D99')          || ';' ||
        'Não elegível'
      );
      
    END IF;
    
    IF vr_count >= 500 THEN
      
      vr_count := 0;
      
      COMMIT;
      
    END IF;
    
  END LOOP;
  
  CLOSE cr_colaborador;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic_out );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic_out);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic_out);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
