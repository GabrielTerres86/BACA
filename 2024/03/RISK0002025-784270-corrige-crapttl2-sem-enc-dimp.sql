DECLARE
  
  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RISK0002025_ttl_sem_crapenc.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'RISK0002025_ttl_sem_crapenc_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'RISK0002025_ttl_sem_crapenc_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  vr_base_log           VARCHAR2(3000);
  
  vr_nrcpf              CECRED.crapass.NRCPFCGC%TYPE;
  vr_nrcnpj             CECRED.crapass.NRCPFCGC%TYPE;
  
  vr_comments           VARCHAR2(2000);
  vr_ttlencontrado      BOOLEAN;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_dados IS 
    SELECT T.NRCPFCGC
      , T.IDSEQTTL
      , T.CDCOOPER
      , T.NRDCONTA
      , A.DTADMISS
      , A.DTDEMISS
      , A.CDSITDCT
      , E.CDCOOPER     CDCOOPER_TTL_SEM_ENC
      , ETPR.ROWID     ROWID_END_RESIDENCIAL
      , ETP2.ROWID     ROWID_END_CORRESPONDENCIA
      , ETP3.ROWID     ROWID_END_COMPLEMENTAR
      , ETP4.ROWID     ROWID_END_COMERCIAL
    FROM CRAPTTL          T
    JOIN CRAPASS          A ON T.CDCOOPER = A.CDCOOPER
                               AND T.NRDCONTA = A.NRDCONTA
    LEFT JOIN CRAPENC     E ON  T.CDCOOPER = E.CDCOOPER           
                                AND T.NRDCONTA = E.NRDCONTA
                                AND T.IDSEQTTL = E.IDSEQTTL
    
    LEFT JOIN CRAPENC          ETPR ON T.CDCOOPER = ETPR.CDCOOPER
                                       AND T.NRDCONTA = ETPR.NRDCONTA
                                       AND ETPR.IDSEQTTL = 1
                                       AND ETPR.TPENDASS = 10
    
    LEFT JOIN CRAPENC          ETP2 ON T.CDCOOPER = ETP2.CDCOOPER
                                       AND T.NRDCONTA = ETP2.NRDCONTA
                                       AND ETP2.IDSEQTTL = 1
                                       AND ETP2.TPENDASS = 13
    
    LEFT JOIN CRAPENC          ETP3 ON T.CDCOOPER = ETP2.CDCOOPER
                                       AND T.NRDCONTA = ETP2.NRDCONTA
                                       AND ETP2.IDSEQTTL = 1
                                       AND ETP2.TPENDASS = 14
    
    LEFT JOIN CRAPENC          ETP4 ON T.CDCOOPER = ETP2.CDCOOPER
                                       AND T.NRDCONTA = ETP2.NRDCONTA
                                       AND ETP2.IDSEQTTL = 1
                                       AND ETP2.TPENDASS = 9
    WHERE E.CDCOOPER IS NULL
      AND (
        ETPR.ROWID IS NOT NULL OR
        ETP2.ROWID IS NOT NULL OR
        ETP3.ROWID IS NOT NULL OR
        ETP4.ROWID IS NOT NULL
      );
  
  rg_dados              cr_dados%ROWTYPE;
  
  CURSOR cr_crapenc (pr_rowid_enc   IN ROWID) IS 
    SELECT *
    FROM CECRED.CRAPENC E
    WHERE ROWID = pr_rowid_enc;
  
  rg_crapenc    cr_crapenc%ROWTYPE;
  
  CURSOR cr_crapenc_nextseq (pr_cdcooper IN CECRED.CRAPENC.CDCOOPER%TYPE
                           , pr_nrdconta IN CECRED.CRAPENC.NRDCONTA%TYPE) IS 
    SELECT ( NVL( MAX(E.CDSEQINC), 0 ) + 1 ) CDSEQINC
    FROM CECRED.CRAPENC E
    WHERE E.CDCOOPER = pr_cdcooper
      AND E.NRDCONTA = pr_nrdconta;
  
  vr_cdseqinc_nextseq    CECRED.CRAPENC.CDSEQINC%TYPE;
  vr_rowidenc            ROWID;
  vr_rowid_new_enc       ROWID;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RISK0002025';
  
  vr_count_file := 0;
  vr_seq_file   := 1;
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqbkp || LPAD(vr_seq_file, 3, '0') || '.sql'
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
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'CPF;COOPERATIVA;CONTA;SEQ. TITULAR;DATA ADMISS;DATA DEMIS;CD SIT. CTA;STATUS;DETALHES');
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  OPEN cr_dados;
  LOOP
    FETCH cr_dados INTO rg_dados;
    EXIT WHEN cr_dados%NOTFOUND;
    
    vr_base_log := rg_dados.NRCPFCGC || ';' ||
                   rg_dados.CDCOOPER || ';' ||
                   rg_dados.NRDCONTA || ';' ||
                   rg_dados.IDSEQTTL || ';' ||
                   TO_CHAR(rg_dados.DTADMISS, 'DD/MM/RRRR') || ';' ||
                   TO_CHAR(rg_dados.DTDEMISS, 'DD/MM/RRRR') || ';' ||
                   rg_dados.CDSITDCT || ';';
    
    vr_comments := ' Ordenação para busca dos tipos de endereços: 10 - Residencial, 13 - Correspondência, 14 - Complementar e 9 - Comercial ';
    vr_rowidenc := NVL( NVL( NVL(rg_dados.ROWID_END_RESIDENCIAL, rg_dados.ROWID_END_CORRESPONDENCIA), rg_dados.ROWID_END_COMPLEMENTAR), rg_dados.ROWID_END_COMERCIAL);
    
    IF vr_rowidenc IS NULL THEN
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ALERTA;Nenhum ROWID encontrado para copiar endereco do titular principal. Registro ignorado.');
      CONTINUE;
    END IF;
    
    OPEN cr_crapenc(vr_rowidenc);
    FETCH cr_crapenc INTO rg_crapenc;
    
    IF cr_crapenc%NOTFOUND THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ALERTA;Enereco NAO encontrado com o rowid (' || vr_rowidenc || ') para copiar endereco do titular principal. Registro ignorado.');
      
      CLOSE cr_crapenc;
      CONTINUE;
      
    END IF;
    
    CLOSE cr_crapenc;
    
    OPEN cr_crapenc_nextseq(rg_dados.CDCOOPER, rg_dados.NRDCONTA);
    FETCH cr_crapenc_nextseq INTO vr_cdseqinc_nextseq;
    CLOSE cr_crapenc_nextseq;
    
    BEGIN
      
      vr_comments := ' ## Laço em todos os cadastros de titulares adicionais que estão com erro de endereço para correção.';
      
      INSERT INTO CECRED.CRAPENC (
        cdcooper
        , nrdconta
        , idseqttl
        , tpendass
        , cdseqinc
        , dsendere
        , nrendere
        , complend
        , nmbairro
        , nmcidade
        , cdufende
        , nrcepend
        , incasprp
        , nranores
        , vlalugue
        , nrcxapst
        , dtaltenc
        , dtinires
        , nrdoapto
        , cddbloco
        , idorigem
      ) VALUES (
        rg_crapenc.cdcooper
        , rg_crapenc.nrdconta
        , rg_dados.idseqttl
        , rg_crapenc.tpendass
        , NVL(vr_cdseqinc_nextseq, 1)
        , rg_crapenc.dsendere
        , rg_crapenc.nrendere
        , rg_crapenc.complend
        , rg_crapenc.nmbairro
        , rg_crapenc.nmcidade
        , rg_crapenc.cdufende
        , rg_crapenc.nrcepend
        , rg_crapenc.incasprp
        , rg_crapenc.nranores
        , rg_crapenc.vlalugue
        , rg_crapenc.nrcxapst
        , rg_crapenc.dtaltenc
        , rg_crapenc.dtinires
        , rg_crapenc.nrdoapto
        , rg_crapenc.cddbloco
        , rg_crapenc.idorigem
      ) RETURNING ROWID INTO vr_rowid_new_enc;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'SUCESSO;Enereco incluido com sucesso para o cooperado.');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  DELETE CECRED.CRAPENC WHERE ROWID = ''' || vr_rowid_new_enc || '''; ');
      
      vr_count := vr_count + 1;
      
    EXCEPTION 
      WHEN OTHERS THEN 
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_base_log || 'ERRO;Erro nao tratado ao inserir CRAPENC.: ' || SQLERRM);
        
    END;
    
    IF vr_count >= 1000 THEN
      
      COMMIT;
      
      vr_count := 0;
      
    END IF;
    
  END LOOP;
  
  CLOSE cr_dados;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
  WHEN vr_exception THEN
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
