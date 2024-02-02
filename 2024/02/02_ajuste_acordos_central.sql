DECLARE

  vr_dtrefere       DATE := to_date('31/01/2024', 'DD/MM/RRRR');
  
  vr_exc_erro       EXCEPTION;
  vr_dsdireto       VARCHAR2(2000);
  vr_nmarquiv       VARCHAR2(100);
  vr_dscritic       VARCHAR2(4000);
  vr_cdcritic       NUMBER;
  vr_ind_arquiv     utl_file.file_type;
  vr_ind_arqlog     utl_file.file_type;
  vr_dslinha        VARCHAR2(4000);
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);

  vr_dados_crapris  CLOB;
  vr_texto_crapris  VARCHAR2(32600);
  
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmarqris       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_dttransa       cecred.craplgm.dttransa%type;
  vr_hrtransa       cecred.craplgm.hrtransa%type;
  vr_nrdrowid       ROWID;
  vr_typ_saida      VARCHAR2(3);
  
  vr_vet_dados      cecred.gene0002.typ_split;

  vr_des_xml         CLOB;
  vr_texto_completo  VARCHAR2(32600);

  vr_tab_ris_acordo  GESTAODERISCO.tiposDadosRiscos.typ_tab_ris_resumida;
  vr_tab_vri_acordo  GESTAODERISCO.tiposDadosRiscos.typ_tab_crapvri;
  vr_idx_vri         VARCHAR2(100);
  vr_vlParcelas      cecred.crapris.vldivida%TYPE;
  vr_vlParcelasJ60   cecred.crapris.vldivida%TYPE;
  vr_nrdconta        cecred.crapass.nrdconta%TYPE;
  
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  
  CURSOR cr_acordo(pr_cdcooper IN cecred.crapcop.cdcooper%TYPE
                  ,pr_nrdconta IN cecred.tbrecup_acordo.nrdconta%TYPE
                  ,pr_nrctremp IN cecred.tbrecup_acordo_contrato.nrctremp%TYPE) IS
    SELECT a.nracordo
      FROM cecred.tbrecup_acordo           a
          ,cecred.tbrecup_acordo_contrato  c
     WHERE c.nracordo   = a.nracordo
       AND a.cdsituacao = 1
       AND a.cdcooper   = pr_cdcooper
       AND a.nrdconta   = pr_nrdconta
       AND c.nrctremp   = pr_nrctremp;
  rw_acordo cr_acordo%ROWTYPE;
  
  CURSOR cr_crapepr(pr_cdcooper IN cecred.crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN cecred.crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN cecred.crapepr.nrctremp%TYPE
                   ,pr_dtrefere IN cecred.crapris.dtrefere%TYPE) IS
    SELECT e.vlsdevat
          ,r.vljura60
          ,r.vljurantpp
          ,r.qtparcel
          ,r.cdmodali
          ,r.nrseqctr
          ,r.innivris
          ,r.vldiv060
          ,r.vldiv180
          ,r.vldiv360
          ,r.vldiv999
          ,r.vlvec180
          ,r.vlvec360
          ,r.vlvec999
          ,r.vldivida
          ,r.vlprxpar
          ,r.dtprxpar
      FROM cecred.crapepr e
          ,cecred.crapris r
     WHERE r.cdcooper = e.cdcooper
       AND r.nrdconta = e.nrdconta
       AND r.nrctremp = e.nrctremp
       AND e.cdcooper = pr_cdcooper
       AND e.nrdconta = pr_nrdconta
       AND e.nrctremp = pr_nrctremp
       AND r.dtrefere = pr_dtrefere;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  CURSOR cr_rollback(pr_condicao IN VARCHAR2
                    ,pr_tabela   IN VARCHAR2) IS
    SELECT 'INSERT INTO ' || table_name || ' (' ||
            RTRIM(XMLQUERY('for $i in ROW/* return concat(name($i),",")' PASSING
                           t.column_value.EXTRACT('ROW') RETURNING content),',') || 
            ') VALUES (' || UTL_I18N.UNESCAPE_REFERENCE(RTRIM(XMLQUERY('for $i in ROW/* return concat("''", $i, "''",",")' PASSING
                           t.column_value.EXTRACT('ROW') RETURNING content),
            ',')) || ');' query_insert
      FROM all_tables,
           XMLTABLE('ROW' PASSING DBMS_XMLGEN.GETXMLTYPE('SELECT * FROM ' || table_name || ' ' || pr_condicao).EXTRACT('ROWSET/ROW')) t
     WHERE UPPER(table_name) = UPPER(pr_tabela);
  rw_rollback cr_rollback%ROWTYPE;

  rw_crapdat cecred.btch0001.cr_crapdat%ROWTYPE;
BEGIN

  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Rollback das informacoes'||chr(13), FALSE);

  vr_dados_crapris := NULL;
  dbms_lob.createtemporary(vr_dados_crapris, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_crapris, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_crapris, vr_texto_crapris, 'cdcooper;nrdconta;nrctremp;vldivida_antes;vldivida_depois'||chr(13), FALSE);
  
  vr_dsdireto := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto := vr_dsdireto||'cpd/bacas/RISCO/ACORDOS/'; 
  vr_nmarqbkp := 'ROLLBACK_ACORDOS_VRI_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  vr_nmarqris := 'ANTES_DEPOIS_RIS_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.csv';
  vr_nmarquiv := 'ACORDOS.csv';

  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv  
                          ,pr_tipabert => 'R'          
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                      
  IF vr_dscritic IS NOT NULL THEN
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, to_char(sysdate,'ddmmyyyy_hh24miss')||' Nao foi possivel ler o arquivo de entrada');  
    RAISE vr_exc_erro;
  END IF;
  
  vr_dttransa    := trunc(sysdate);
  vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
  
  BEGIN     

    LOOP
        
      IF utl_file.IS_OPEN(vr_ind_arquiv) THEN

        gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_ind_arquiv
                                    ,pr_des_text => vr_dslinha);

        vr_vet_dados := gene0002.fn_quebra_string(pr_string => vr_dslinha, pr_delimit => ';');
        
        OPEN  btch0001.cr_crapdat(pr_cdcooper => vr_vet_dados(1));
        FETCH btch0001.cr_crapdat INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;
        
        OPEN cr_crapass(pr_cdcooper => vr_vet_dados(1)
                       ,pr_progress => vr_vet_dados(4));
        FETCH cr_crapass INTO vr_nrdconta;
        CLOSE cr_crapass;
        
        OPEN cr_acordo(pr_cdcooper => vr_vet_dados(1)
                      ,pr_nrdconta => vr_nrdconta
                      ,pr_nrctremp => vr_vet_dados(3));
        FETCH cr_acordo INTO rw_acordo;
        IF cr_acordo%NOTFOUND THEN
          gene0002.pc_escreve_xml(vr_dados_rollback
                                ,vr_texto_rollback
                                ,'Acordo nao encontrado coop: ' || vr_vet_dados(1) || ' conta: ' || vr_nrdconta || ' contrato: ' || vr_vet_dados(3) ||
                                ';' ||chr(13)||chr(13), FALSE); 
          CLOSE cr_acordo;
          CONTINUE;
        ELSE
          CLOSE cr_acordo;
        END IF;
        
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'DELETE FROM cecred.crapvri WHERE cdcooper = ' || vr_vet_dados(1) || ' AND dtrefere = ''' || vr_dtrefere || '''' || ' AND nrdconta = ' || vr_nrdconta || ' AND nrctremp = ' || vr_vet_dados(3) || ';'
                               ||chr(13)||chr(13), FALSE); 
        FOR rw_rollback IN cr_rollback(pr_condicao => 'WHERE cdcooper = ' || vr_vet_dados(1) || ' AND dtrefere = ''' || vr_dtrefere || '''' || ' AND nrdconta = ' || vr_nrdconta || ' AND nrctremp = ' || vr_vet_dados(3)
                                      ,pr_tabela   => 'CRAPVRI') LOOP
          gene0002.pc_escreve_xml(vr_dados_rollback
                                 ,vr_texto_rollback
                                 ,rw_rollback.query_insert ||chr(13)||chr(13), FALSE); 
        END LOOP;
        
        BEGIN 
          DELETE FROM cecred.crapvri 
           WHERE cdcooper = vr_vet_dados(1) 
             AND dtrefere = vr_dtrefere 
             AND nrdconta = vr_nrdconta
             AND nrctremp = vr_vet_dados(3);
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20000, 'Erro ao excluir VRI da conta: ' || vr_nrdconta || ' - ' || SQLERRM);
        END;
        
        OPEN cr_crapepr(pr_cdcooper => vr_vet_dados(1) 
                       ,pr_nrdconta => vr_nrdconta
                       ,pr_nrctremp => vr_vet_dados(3)
                       ,pr_dtrefere => vr_dtrefere);
        FETCH cr_crapepr INTO rw_crapepr;
        CLOSE cr_crapepr;

        vr_vlParcelas := (rw_crapepr.vlsdevat - nvl(rw_crapepr.vljura60,0) - nvl(rw_crapepr.vljurantpp,0)) / greatest(rw_crapepr.qtparcel,1);

        vr_vlParcelasJ60 := (rw_crapepr.vlsdevat / greatest(rw_crapepr.qtparcel,1));
        
        vr_tab_ris_acordo.delete;
        vr_tab_vri_acordo.delete;
        GESTAODERISCO.gerarVencimentosRiscoAcordo(pr_cdcooper    => vr_vet_dados(1)
                                                 ,pr_nrdconta    => vr_nrdconta
                                                 ,pr_nrctremp    => vr_vet_dados(3)
                                                 ,pr_nracordo    => rw_acordo.nracordo
                                                 ,pr_cdmodali    => rw_crapepr.cdmodali
                                                 ,pr_dtrefere    => vr_dtrefere
                                                 ,pr_dtmvtolt    => vr_dtrefere
                                                 ,pr_nrseqctr    => rw_crapepr.nrseqctr
                                                 ,pr_vlrParcela  => vr_vlParcelas
                                                 ,pr_vlrParcelaJ60 => vr_vlParcelasJ60
                                                 ,pr_tab_ris_res => vr_tab_ris_acordo
                                                 ,pr_tab_crapvri => vr_tab_vri_acordo
                                                 ,pr_cdcritic    => vr_cdcritic
                                                 ,pr_dscritic    => vr_dscritic);

        vr_idx_vri := vr_tab_vri_acordo.FIRST;
        WHILE vr_idx_vri IS NOT NULL LOOP
          BEGIN
            INSERT INTO cecred.crapvri(nrdconta, dtrefere, innivris, cdmodali, nrctremp,
                                       nrseqctr, cdvencto, vldivida, cdcooper, vljura60, vlempres)
            VALUES(vr_tab_vri_acordo(vr_idx_vri).nrdconta
                  ,vr_dtrefere
                  ,rw_crapepr.innivris
                  ,rw_crapepr.cdmodali
                  ,vr_vet_dados(3)
                  ,rw_crapepr.nrseqctr
                  ,vr_tab_vri_acordo(vr_idx_vri).cdvencto
                  ,vr_tab_vri_acordo(vr_idx_vri).vldivida
                  ,vr_vet_dados(1)
                  ,0
                  ,vr_tab_vri_acordo(vr_idx_vri).vlempres);
            vr_idx_vri := vr_tab_vri_acordo.NEXT(vr_idx_vri);
          END;
        END LOOP;
        
        BEGIN 
          UPDATE cecred.crapris
             SET vldiv060 = vr_tab_ris_acordo(0).vldiv060
                ,vldiv180 = vr_tab_ris_acordo(0).vldiv180
                ,vldiv360 = vr_tab_ris_acordo(0).vldiv360
                ,vldiv999 = vr_tab_ris_acordo(0).vldiv999
                ,vlvec180 = vr_tab_ris_acordo(0).vlvec180
                ,vlvec360 = vr_tab_ris_acordo(0).vlvec360
                ,vlvec999 = vr_tab_ris_acordo(0).vlvec999
                ,vldivida = vr_tab_ris_acordo(0).vldivida
                ,vlprxpar = vr_tab_ris_acordo(0).vlprxpar
                ,dtprxpar = vr_tab_ris_acordo(0).dtprxpar
           WHERE cdcooper = vr_vet_dados(1)
             AND nrdconta = vr_nrdconta
             AND nrctremp = vr_vet_dados(3)
             AND dtrefere = vr_dtrefere;
        EXCEPTION
          WHEN OTHERS THEN
            raise_application_error(-20000, 'Erro ao atualizar RIS da conta: ' || vr_nrdconta || ' - ' || SQLERRM);
        END;
        
        gene0002.pc_escreve_xml(vr_dados_crapris
                               ,vr_texto_crapris
                               ,vr_vet_dados(1) || ';' || 
                                vr_nrdconta || ';' || 
                                vr_vet_dados(3) || ';' || 
                                rw_crapepr.vldivida || ';'|| 
                                vr_tab_ris_acordo(0).vldivida || chr(13)
                               ,FALSE);
        
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'UPDATE cecred.crapris r' || chr(13) || 
                                '   SET r.vldiv060 := ' || rw_crapepr.vldiv060 || '
                                       ,r.vldiv180 := ' || rw_crapepr.vldiv180 || '
                                       ,r.vldiv360 := ' || rw_crapepr.vldiv360 || '
                                       ,r.vldiv999 := ' || rw_crapepr.vldiv999 || '
                                       ,r.vlvec180 := ' || rw_crapepr.vlvec180 || '
                                       ,r.vlvec360 := ' || rw_crapepr.vlvec360 || '
                                       ,r.vlvec999 := ' || rw_crapepr.vlvec999 || '
                                       ,r.vldivida := ' || rw_crapepr.vldivida || '
                                       ,r.vlprxpar := ' || rw_crapepr.vlprxpar || '
                                       ,r.dtprxpar := ' || rw_crapepr.dtprxpar || 
                                ' WHERE w.cdcooper = ' || vr_vet_dados(1) || chr(13) || 
                                '   AND w.nrdconta = ' || vr_nrdconta || chr(13) || 
                                '   AND w.nrctremp = ' || vr_vet_dados(3) || 
                                ';' ||chr(13)||chr(13), FALSE); 
        
      END IF;        
    END LOOP;

  EXCEPTION
    WHEN no_data_found THEN        
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  END;   

  gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '|| vr_nmdireto||'/' || vr_nmarquiv || ' '
                                                     || vr_nmdireto||'/' || 'PROC_' || to_char(sysdate,'ddmmyyyy_hh24miss') || vr_nmarquiv
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
  IF NVL(vr_typ_saida,' ') = 'ERR' THEN
    RAISE vr_exc_erro;
  END IF;
          
  
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             
                                     ,pr_cdprogra  => 'ATENDA'                      
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                
                                     ,pr_dsxml     => vr_dados_rollback             
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp 
                                     ,pr_flg_impri => 'N'                           
                                     ,pr_flg_gerar => 'S'                           
                                     ,pr_flgremarq => 'N'                           
                                     ,pr_nrcopias  => 1                             
                                     ,pr_des_erro  => vr_dscritic);                 
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             
                                     ,pr_cdprogra  => 'ATENDA'                      
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                
                                     ,pr_dsxml     => vr_dados_crapris             
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqris 
                                     ,pr_flg_impri => 'N'                           
                                     ,pr_flg_gerar => 'S'                           
                                     ,pr_flgremarq => 'N'                           
                                     ,pr_nrcopias  => 1                             
                                     ,pr_des_erro  => vr_dscritic);                 
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 

  dbms_lob.close(vr_dados_crapris);
  dbms_lob.freetemporary(vr_dados_crapris); 

EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro: ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;
