DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'contas.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'ROLLBACK_contas.sql';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_contlinha          INTEGER := 0;
  vr_ind_arquiv         utl_file.file_type;  
  
  CURSOR cr_crapttl (pr_cdcooper IN CECRED.Crapttl.CDCOOPER%TYPE
                   , pr_nrdconta IN CECRED.crapttl.NRDCONTA%TYPE
                   , pr_idseqttl IN CECRED.crapttl.IDSEQTTL%TYPE
                   , pr_nrcpfcgc IN CECRED.Crapttl.NRCPFCGC%TYPE) IS
    SELECT tt.cdturnos
      , tt.idorgexp
      , tt.cdufdttl
      , tt.grescola
      , tt.cdnatopc
    FROM CECRED.crapttl tt
    WHERE tt.cdcooper = pr_cdcooper
      AND tt.nrdconta = pr_nrdconta
      AND tt.idseqttl = pr_idseqttl
      AND tt.nrcpfcgc = pr_nrcpfcgc;
  
  rw_crapttl   cr_crapttl%ROWTYPE;
  
  CURSOR cr_crapcrl (pr_cdcooper IN CECRED.Crapttl.CDCOOPER%TYPE
                   , pr_nrdconta IN CECRED.crapttl.NRDCONTA%TYPE) IS
    SELECT rl.idorgexp
      , rl.cdufiden
      , rl.nrcpfcgc
    FROM CECRED.crapcrl rl
    WHERE rl.nrctamen = pr_nrdconta
      AND rl.cdcooper = pr_cdcooper;
  
  rw_crapcrl   cr_crapcrl%ROWTYPE;
  
  CURSOR cr_pes_atu (pr_nrdconta IN CECRED.crapttl.NRDCONTA%TYPE
                   , pr_cdcooper IN CECRED.Crapttl.CDCOOPER%TYPE) IS
    SELECT at.insit_atualiza
      , at.dhatualiza
      , at.dhprocessa
      , at.dhiniproc
      , at.dslogdetalhes
    FROM cecred.tbcadast_pessoa_atualiza at
    WHERE at.nrdconta = pr_nrdconta
      AND at.cdcooper = pr_cdcooper
      AND at.nmtabela = 'CRAPASS'
      AND at.insit_atualiza = 3;
  
  rw_pes_atu   cr_pes_atu%ROWTYPE;
  
  vr_conta     CECRED.Crapttl.NRDCONTA%TYPE;
  vr_cdcooper  CECRED.Crapttl.CDCOOPER%TYPE;
  vr_cpfcnpj   CECRED.Crapttl.NRCPFCGC%TYPE;
  vr_idseqttl  CECRED.Crapttl.IDSEQTTL%TYPE;
  vr_turno     CECRED.crapttl.CDTURNOS%TYPE;
  vr_orgexp    CECRED.crapttl.IDORGEXP%TYPE;
  vr_uforex    CECRED.crapttl.CDUFDTTL%TYPE;
  vr_gresco    CECRED.crapttl.GRESCOLA%TYPE;
  vr_natocp    CECRED.crapttl.CDNATOPC%TYPE;
  vr_dsaltera  VARCHAR2(50);
  
  vr_des_alt         CLOB := NULL;
  vr_des_ret         CLOB := NULL;
  vr_setlinha        VARCHAR2(10000);

  vr_dscritic        crapcri.dscritic%TYPE;
  vr_exception       EXCEPTION;

  PROCEDURE pc_escreve_alt(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_alt
                           ,vr_texto_completo
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 
  
  PROCEDURE pc_escreve_ret(pr_des_dados IN VARCHAR2
                          ,pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_ret
                           ,vr_texto_completo_ret
                           ,pr_des_dados
                           ,pr_fecha_xml);
  END; 
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0195905';
  
  gene0001.pc_abre_arquivo (pr_nmdireto => vr_nmdireto
                           ,pr_nmarquiv => vr_nmarquiv
                           ,pr_tipabert => 'R'
                           ,pr_utlfileh => vr_input_file
                           ,pr_des_erro => vr_dscritic);
  
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
    
  END IF;
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arquiv
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');

  vr_des_ret := NULL;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    vr_contlinha:= vr_contlinha + 1;
    
    vr_setlinha := REPLACE(REPLACE(vr_setlinha,CHR(10)),CHR(13));
    
    vr_cdcooper  := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(1,vr_setlinha,';')) );
    vr_conta     := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(2,vr_setlinha,';')) );
    vr_cpfcnpj   := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(3,vr_setlinha,';')) );
    vr_idseqttl  := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(4,vr_setlinha,';')) );
    vr_turno     := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(5,vr_setlinha,';')) );
    vr_orgexp    := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(6,vr_setlinha,';')) );
    vr_uforex    := TRIM(gene0002.fn_busca_entrada(7,vr_setlinha,';'));
    vr_gresco    := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(8,vr_setlinha,';')) );
    vr_natocp    := CECRED.gene0002.fn_char_para_number( TRIM(gene0002.fn_busca_entrada(9,vr_setlinha,';')) );
    vr_dsaltera  := TRIM( gene0002.fn_busca_entrada(10,vr_setlinha,';') );
    
    IF vr_dsaltera = 'CRIAR_PESSOA' THEN
      
      BEGIN
        
        OPEN cr_pes_atu(vr_conta, vr_cdcooper);
        FETCH cr_pes_atu INTO rw_pes_atu;
        CLOSE cr_pes_atu;
        
        UPDATE CECRED.Tbcadast_Pessoa_Atualiza a
          SET a.insit_atualiza = 1
            , a.dhatualiza = SYSDATE
            , a.dhprocessa = NULL
            , a.dhiniproc = NULL
            , a.dslogdetalhes = NULL
        WHERE a.nrdconta = vr_conta
          AND a.cdcooper = vr_cdcooper
          AND a.nmtabela in ( 'CRAPASS', 'CRAPTTL' )
          AND a.insit_atualiza = 3;
        
        
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv
            , ' UPDATE CECRED.Tbcadast_Pessoa_Atualiza a ' ||
                 'SET a.insit_atualiza = 3 ' ||
                  ' , a.dhatualiza = to_date(''' || rw_pes_atu.dhatualiza || ''', ''dd/mm/rrrr hh24:mi:ss'') ' ||
                  ' , a.dhprocessa = to_date(''' || rw_pes_atu.dhprocessa || ''', ''dd/mm/rrrr hh24:mi:ss'') ' ||
                  ' , a.dhiniproc = to_date(''' || rw_pes_atu.dhiniproc || ''', ''dd/mm/rrrr hh24:mi:ss'') ' ||
                  ' , a.dslogdetalhes = ''' || rw_pes_atu.dslogdetalhes || ''' ' ||
              ' WHERE a.cdcooper = ' || vr_cdcooper ||
                ' AND a.nrdconta = ' || vr_conta    ||
                ' AND a.nmtabela = ''CRAPASS'' ' ||
                ' AND a.insit_atualiza = 1 ' || ';'
          );
        
      EXCEPTION
        WHEN OTHERS THEN
          
          vr_dscritic := 'Erro ao forçar integração do cadastro de pessoa. Erro: ' || SQLERRM;
          RAISE vr_exception;
      END;
      
    ELSIF vr_dsaltera <> 'Resp_legal' THEN
      
      rw_crapttl := NULL;
      OPEN cr_crapttl (pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => vr_conta
                     , pr_idseqttl => vr_idseqttl
                     , pr_nrcpfcgc => vr_cpfcnpj);
      FETCH cr_crapttl INTO rw_crapttl;
      
      IF cr_crapttl%NOTFOUND THEN
        
        vr_dscritic := 'Dados do titular NÃO encontrados para a conta: ' || vr_conta 
                       || ' , Cooperativa: ' || vr_cdcooper
                       || ' , CPF: ' || vr_cpfcnpj
                       || ' , Seq. titular: ' || vr_idseqttl;
        
        CLOSE cr_crapttl;
        
        RAISE vr_exception;
        
      END IF;
      
      CLOSE cr_crapttl;
      
      BEGIN
        
        UPDATE CECRED.crapttl t
          SET t.cdturnos = CASE WHEN NVL(vr_turno, 0) > 0 THEN vr_turno ELSE t.cdturnos END
            , t.idorgexp = CASE WHEN NVL(vr_orgexp, 0) > 0 THEN vr_orgexp ELSE t.idorgexp END
            , t.cdufdttl = CASE WHEN NVL(vr_uforex, 'XX') <> 'XX' THEN vr_uforex ELSE t.cdufdttl END
            , t.grescola = CASE WHEN NVL(vr_gresco, -1) >= 0 THEN vr_gresco ELSE t.grescola END
            , t.cdnatopc = CASE WHEN NVL(vr_natocp, 0) > 0 THEN vr_natocp ELSE t.cdnatopc END
        WHERE t.cdcooper = vr_cdcooper
          AND t.nrdconta = vr_conta
          AND t.nrcpfcgc = vr_cpfcnpj
          AND t.idseqttl = vr_idseqttl;
        
      EXCEPTION
        WHEN OTHERS THEN
          
          vr_dscritic := 'Erro ao atualizar a CRAPTTL. Conta - Coop - CPF - Seq. Tit: ' 
                         || vr_conta || ' - ' || vr_cdcooper || ' - ' || vr_cpfcnpj || ' - ' || vr_idseqttl
                         || ' - SQLERRM: ' || sqlerrm;
          
          RAISE vr_exception;
          
      END;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv
        , ' UPDATE CECRED.crapttl t ' ||
             'SET t.cdturnos = ' || NVL( TO_CHAR(rw_crapttl.Cdturnos), 'NULL' ) ||
              ' , t.idorgexp = ' || rw_crapttl.Idorgexp ||
              ' , t.cdufdttl = ' || CASE WHEN rw_crapttl.Cdufdttl IS NULL THEN 'NULL' ELSE ' ''' || rw_crapttl.Cdufdttl || ''' ' END ||
              ' , t.grescola = ' || rw_crapttl.Grescola ||
              ' , t.cdnatopc = ' || rw_crapttl.Cdnatopc ||
          ' WHERE t.cdcooper = ' || vr_cdcooper ||
            ' AND t.nrdconta = ' || vr_conta    ||
            ' AND t.nrcpfcgc = ' || vr_cpfcnpj  ||
            ' AND t.idseqttl = ' || vr_idseqttl || ';'
      );
      
    ELSE
      
      OPEN cr_crapcrl (pr_cdcooper => vr_cdcooper
                     , pr_nrdconta => vr_conta );
      
      BEGIN
        
        LOOP
          FETCH cr_crapcrl INTO rw_crapcrl;
          EXIT WHEN cr_crapcrl%NOTFOUND;
          
          IF rw_crapcrl.idorgexp = 999 OR rw_crapcrl.cdufiden = 'NI' THEN
            
            UPDATE CECRED.Crapcrl r
              SET r.idorgexp = vr_orgexp
                , r.cdufiden = CASE WHEN rw_crapcrl.cdufiden = 'NI' THEN NULL ELSE rw_crapcrl.cdufiden END
            WHERE r.Nrctamen = vr_conta
              AND r.cdcooper = vr_cdcooper
              AND r.nrcpfcgc = rw_crapcrl.nrcpfcgc;
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arquiv
              , ' UPDATE CECRED.Crapcrl r ' ||
                   'SET r.idorgexp = ' || rw_crapcrl.idorgexp ||
                   '  , r.cdufiden = ' || CASE WHEN rw_crapcrl.cdufiden = 'NI' THEN '''NI''' ELSE 'r.cdufiden' END ||
                ' WHERE r.Nrctamen = ' || vr_conta ||
                  ' AND r.cdcooper = ' || vr_cdcooper ||
                  ' AND r.nrcpfcgc = ' || rw_crapcrl.nrcpfcgc || ';'
            );
            
          END IF;
          
          rw_crapcrl := NULL;
          
        END LOOP;
        
        CLOSE cr_crapcrl;
        
      EXCEPTION
        WHEN OTHERS THEN
          
          CLOSE cr_crapcrl;
          
          vr_dscritic := 'Erro ao atualizar dados do Responsável legal na CRAPCRL. Conta - Coop - CPF - Seq. Tit: ';
          RAISE vr_exception;
      END;
      
    END IF;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    COMMIT;
    
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
end;
