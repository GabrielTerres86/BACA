DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'RITM0260409_Base_enriquecida_CNPJ_csv.csv';
  vr_nmarqbkp           VARCHAR2(50) := 'RITM0260409_ROLLBACK_PJ.sql';
  vr_nmarqlog           VARCHAR2(50) := 'RITM0260409_log_execucao_PJ.txt';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_ind_arquiv         utl_file.file_type;
  vr_ind_arqlog         utl_file.file_type;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  
  CURSOR cr_crapjur(pr_nrcpfcgc IN CECRED.CRAPTTL.NRCPFCGC%TYPE
                  , pr_cdcooper IN CECRED.CRAPTTL.CDCOOPER%TYPE) IS
    SELECT t.nrdconta
      , t.cdcooper
      , t.vlfatano
      , (SELECT count(*) 
         FROM cecred.crapjur t2
         JOIN cecred.crapass a2 on t2.nrdconta = a2.nrdconta
                                   and t2.cdcooper = a2.cdcooper
         WHERE a.nrcpfcgc = a2.nrcpfcgc
           AND a.nrdconta <> a2.nrdconta) qtd_contas
    FROM CECRED.CRAPJUR t
    JOIN CECRED.CRAPASS a on t.nrdconta = a.nrdconta
                             and t.cdcooper = a.cdcooper
    WHERE a.cdcooper = pr_cdcooper
      AND a.nrcpfcgc = pr_nrcpfcgc;

  rw_crapjur cr_crapjur%ROWTYPE;

  CURSOR cr_crapdat(pr_cdcooper IN CECRED.CRAPTTL.CDCOOPER%TYPE) IS
    SELECT d.dtmvtolt
    FROM CECRED.crapdat d
    WHERE d.cdcooper = pr_cdcooper;
    
  vr_dtmvtolt CECRED.crapdat.DTMVTOLT%TYPE;
  
  CURSOR cr_crapcem ( pr_cdcooper IN CECRED.crapttl.cdcooper%TYPE
                    , pr_nrdconta IN CECRED.crapttl.nrdconta%TYPE
                    , pr_idseqttl IN CECRED.crapttl.idseqttl%TYPE
                    , pr_dsemail  IN CECRED.crapcem.DSDEMAIL%TYPE) IS
    SELECT e.dsdemail
    FROM CECRED.crapcem e
    WHERE e.nrdconta = pr_nrdconta
      AND e.cdcooper = pr_cdcooper
      AND e.idseqttl = pr_idseqttl
      AND upper(e.dsdemail) = trim( upper(pr_dsemail) );
  
  rg_crapcem     cr_crapcem%ROWTYPE;
  
  CURSOR cr_craptfc_MAX( pr_cdcooper IN CECRED.crapttl.cdcooper%TYPE
                       , pr_nrdconta IN CECRED.crapttl.nrdconta%TYPE
                       , pr_idseqttl IN CECRED.crapttl.idseqttl%TYPE
                       ) IS
    SELECT ( NVL( MAX( t.cdseqtfc ), 0 ) + 1 ) cdseqtfc
    FROM CECRED.craptfc t
    WHERE t.nrdconta = pr_nrdconta
      AND t.cdcooper = pr_cdcooper
      AND t.idseqttl = pr_idseqttl;
  
  vr_cdseqtfc    CECRED.craptfc.CDSEQTFC%TYPE;
  
  CURSOR cr_craptfc( pr_cdcooper IN CECRED.crapttl.cdcooper%TYPE
                   , pr_nrdconta IN CECRED.crapttl.nrdconta%TYPE
                   , pr_idseqttl IN CECRED.crapttl.idseqttl%TYPE
                   , pr_nrdddtfc IN CECRED.craptfc.NRDDDTFC%TYPE
                   , pr_nrtelefo IN CECRED.craptfc.NRTELEFO%TYPE
                   ) IS
    SELECT t.nrtelefo
      , t.nrdddtfc
    FROM CECRED.craptfc t
    WHERE t.nrdconta = pr_nrdconta
      AND t.cdcooper = pr_cdcooper
      AND t.idseqttl = pr_idseqttl
      AND t.nrdddtfc = NVL(pr_nrdddtfc, 0)
      AND t.nrtelefo = NVL(pr_nrtelefo, 0);
      
  rg_craptfc     cr_craptfc%ROWTYPE;
  
  CURSOR cr_crapjfn ( pr_cdcooper IN CECRED.crapjfn.cdcooper%TYPE
                    , pr_nrdconta IN CECRED.crapjfn.nrdconta%TYPE
                    ) IS
    SELECT j.cdcooper,
      j.nrdconta,
      j.mesftbru##1,
      j.mesftbru##2,
      j.mesftbru##3,
      j.mesftbru##4,
      j.mesftbru##5,
      j.mesftbru##6,
      j.mesftbru##7,
      j.mesftbru##8,
      j.mesftbru##9,
      j.mesftbru##10,
      j.mesftbru##11,
      j.mesftbru##12,
      j.anoftbru##1,
      j.anoftbru##2,
      j.anoftbru##3,
      j.anoftbru##4,
      j.anoftbru##5,
      j.anoftbru##6,
      j.anoftbru##7,
      j.anoftbru##8,
      j.anoftbru##9,
      j.anoftbru##10,
      j.anoftbru##11,
      j.anoftbru##12,
      j.vlrftbru##1,
      j.vlrftbru##2,
      j.vlrftbru##3,
      j.vlrftbru##4,
      j.vlrftbru##5,
      j.vlrftbru##6,
      j.vlrftbru##7,
      j.vlrftbru##8,
      j.vlrftbru##9,
      j.vlrftbru##10,
      j.vlrftbru##11,
      j.vlrftbru##12,
      j.dtaltjfn##4,
      j.cdopejfn##4
    FROM CECRED.crapjfn j
    WHERE j.nrdconta = pr_nrdconta
      AND j.cdcooper = pr_cdcooper;
  
  rg_crapjfn     cr_crapjfn%ROWTYPE;
  
  TYPE           TP_ALT IS ARRAY(4) OF VARCHAR2(50);
  vt_msgalt      TP_ALT;
  vr_msgalt      CECRED.crapalt.DSALTERA%TYPE;
  
  vr_rollback    VARCHAR2(4000);
  vr_seprbk      VARCHAR2(3);
  
  vr_cdcooper    CECRED.CRAPCOP.CDCOOPER%TYPE;
  vr_nrdrowid    ROWID;
  vr_nrcpfcgc    CECRED.crapttl.NRCPFCGC%TYPE;
  vr_vldrendi    CECRED.Crapttl.VLDRENDI##1%TYPE;
  vr_ddd01       CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_fone01      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_ddd02       CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_fone02      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_ddd03       CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_fone03      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddcel01    CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_celu01      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddcel02    CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_celu02      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddcel03    CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_celu03      CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_email       CECRED.CRAPCEM.DSDEMAIL%TYPE;
  vr_dddctato01  CECRED.CRAPTFC.NRDDDTFC%TYPE; 
  vr_ctato01     CECRED.CRAPTFC.NRTELEFO%TYPE; 
  vr_dddctato02  CECRED.CRAPTFC.NRDDDTFC%TYPE; 
  vr_ctato02     CECRED.CRAPTFC.NRTELEFO%TYPE; 
  vr_dddctato03  CECRED.CRAPTFC.NRDDDTFC%TYPE; 
  vr_ctato03     CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddctatocel01  CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_ctatocel01     CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddctatocel02  CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_ctatocel02     CECRED.CRAPTFC.NRTELEFO%TYPE;
  vr_dddctatocel03  CECRED.CRAPTFC.NRDDDTFC%TYPE;
  vr_ctatocel03     CECRED.CRAPTFC.NRTELEFO%TYPE;
  
  vr_nmpessoa       CECRED.TBCADAST_PESSOA.NMPESSOA%TYPE;
  
  vr_resto       NUMBER;
  vr_parcela     CECRED.crapjfn.VLRFTBRU##1%TYPE;
  vr_tpaltera    NUMBER(1);
  vr_mes         NUMBER(2);
  vr_ano         NUMBER(4);
  
  vr_dscritic    VARCHAR2(2000);
  vr_exception   EXCEPTION;
  vr_exception2  EXCEPTION;
  
  FUNCTION getIdLogCabecalho RETURN ROWID IS
    
  BEGIN
    
    IF vr_nrdrowid IS NULL THEN
    
      CECRED.GENE0001.pc_gera_log( pr_cdcooper => rw_crapjur.cdcooper,
                                   pr_cdoperad => 1,
                                   pr_dscritic => null,
                                   pr_dsorigem => 'Aimaro',
                                   pr_dstransa => 'RITM0260409 - Enriquecimento de base Boa Vista, outubro de 2022.',
                                   pr_dttransa => vr_dtmvtolt,
                                   pr_flgtrans => 1,
                                   pr_hrtransa => gene0002.fn_busca_time,
                                   pr_idseqttl => 1,
                                   pr_nmdatela => 'JOB', 
                                   pr_nrdconta => rw_crapjur.nrdconta,
                                   pr_nrdrowid => vr_nrdrowid);
    
    END IF;
    
    RETURN(vr_nrdrowid);
    
  END;
  
  PROCEDURE cadastraTelefone(pr_nrdddtfc  IN CECRED.craptfc.NRDDDTFC%TYPE
                           , pr_nrtelefo  IN CECRED.craptfc.NRTELEFO%TYPE
                           , pr_tptelefo  IN CECRED.craptfc.TPTELEFO%TYPE
                           , pr_det_log   IN VARCHAR2) IS
    
  BEGIN
    
    IF NVL(pr_nrdddtfc, 0) > 0 OR NVL(pr_nrtelefo, 0) > 0 THEN
    
      OPEN cr_craptfc( rw_crapjur.cdcooper
                       , rw_crapjur.nrdconta
                       , 1
                       , NVL(pr_nrdddtfc, 0)
                       , NVL(pr_nrtelefo, 0)
                       );
        
      FETCH cr_craptfc INTO rg_craptfc;
        
      IF cr_craptfc%NOTFOUND THEN
      
        vr_cdseqtfc := NULL;
          
        OPEN cr_craptfc_MAX( rw_crapjur.cdcooper
                           , rw_crapjur.nrdconta
                           , 1
                           );
        FETCH cr_craptfc_MAX INTO vr_cdseqtfc;
        CLOSE cr_craptfc_MAX;
        
        BEGIN
          
          INSERT INTO CECRED.CRAPTFC (
            cdcooper
            , nrdconta
            , idseqttl
            , nrdddtfc
            , nrtelefo
            , cdseqtfc
            , tptelefo
            , idsittfc
            , idorigem
            , dtinsori
            , inprincipal
          ) VALUES (
            rw_crapjur.cdcooper
            , rw_crapjur.nrdconta
            , 1
            , NVL(pr_nrdddtfc, 0)
            , NVL(pr_nrtelefo, 0)
            , vr_cdseqtfc
            , pr_tptelefo
            , 1
            , 4
            , SYSDATE
            , 0
          );
          
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'DUPLICADO');
            
            gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '  ???? ' || vr_nrcpfcgc || '[' || rw_crapjur.cdcooper || '] ' || rw_crapjur.nrdconta 
                                                          || ' - Telefone repetido (' || NVL(pr_nrdddtfc, 0) || ') ' || NVL(pr_nrtelefo, 0) || ' - ' || sqlerrm );
            
          WHEN OTHERS THEN
            
            RAISE_APPLICATION_ERROR(-20000, 'Erro ao inserir telefone (' || NVL(pr_nrdddtfc, 0) || ').' || NVL(pr_nrtelefo, 0) || sqlerrm);
            
        END;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '    DELETE CECRED.CRAPTFC '
                                                      || ' WHERE nrdconta = ' || rw_crapjur.nrdconta
                                                      || '   AND cdcooper = ' || rw_crapjur.cdcooper
                                                      || '   AND idseqttl = ' || 1
                                                      || '   AND nrdddtfc = ' || NVL(pr_nrdddtfc, 0) 
                                                      || '   AND nrtelefo = ' || NVL(pr_nrtelefo, 0) || '; ' );
          
        vr_nrdrowid := getIdLogCabecalho();
            
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'Telefone'
                                        ,pr_dsdadant => ' '
                                        ,pr_dsdadatu => TRIM( to_char( pr_nrtelefo, '99999999999' ) ) ) ;
            
            
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'DDD'
                                        ,pr_dsdadant => ' '
                                        ,pr_dsdadatu => TRIM( to_char( pr_nrdddtfc, '99999999999' ) ) ) ;
        
        vr_msgalt := vr_msgalt || 'Add telef(' || pr_det_log || ').1.ttl,';
        
      END IF;
      
      CLOSE cr_craptfc;
    
    END IF;
    
  END;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/RITM0260409';
  vr_cdcooper := 1;
  
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
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqlog
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_ind_arqlog
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_exception;
  END IF;
  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');

  OPEN cr_crapdat(vr_cdcooper);
  FETCH cr_crapdat INTO vr_dtmvtolt;
  CLOSE cr_crapdat;
  
  vr_count := 0;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_nrdrowid := NULL;
    vr_msgalt   := NULL;
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(2,vr_setlinha,';') ) );
    
    vr_ddd01    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3,vr_setlinha,';') ) );
    vr_fone01   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(4,vr_setlinha,';') ) );
    vr_ddd02    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(5,vr_setlinha,';') ) );
    vr_fone02   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(6,vr_setlinha,';') ) );
    vr_ddd03    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(7,vr_setlinha,';') ) );
    vr_fone03   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(8,vr_setlinha,';') ) );
    
    vr_dddcel01 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(9,vr_setlinha,';') ) );
    vr_celu01   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(10,vr_setlinha,';') ) );
    vr_dddcel02 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(11,vr_setlinha,';') ) );
    vr_celu02   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(12,vr_setlinha,';') ) );
    vr_dddcel03 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(13,vr_setlinha,';') ) );
    vr_celu03   := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(14,vr_setlinha,';') ) );
    
    vr_dddctato01 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(15,vr_setlinha,';') ) );
    vr_ctato01    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(16,vr_setlinha,';') ) );
    vr_dddctato02 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(17,vr_setlinha,';') ) );
    vr_ctato02    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(18,vr_setlinha,';') ) );
    vr_dddctato03 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(19,vr_setlinha,';') ) );
    vr_ctato03    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(20,vr_setlinha,';') ) );
    
    vr_dddctatocel01 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(21,vr_setlinha,';') ) );
    vr_ctatocel01    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(22,vr_setlinha,';') ) );
    vr_dddctatocel02 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(23,vr_setlinha,';') ) );
    vr_ctatocel02    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(24,vr_setlinha,';') ) );
    vr_dddctatocel03 := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(25,vr_setlinha,';') ) );
    vr_ctatocel03    := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(26,vr_setlinha,';') ) );
    
    vr_email    := TRIM( gene0002.fn_busca_entrada(27,vr_setlinha,';') );
    vr_vldrendi := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(28,vr_setlinha,';') ) );
    vr_nmpessoa := TRIM( gene0002.fn_busca_entrada(29,vr_setlinha,';') );
  
    if vr_nrcpfcgc = 84683671000275 then
      
      begin
        
        UPDATE CECRED.Tbcadast_Pessoa
          SET NMPESSOA = vr_nmpessoa
        WHERE nrcpfcgc = vr_nrcpfcgc;
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  '    UPDATE CECRED.Tbcadast_Pessoa '
                                                       || '   SET NMPESSOA = ''WETZL SA'' '
                                                       || ' WHERE nrcpfcgc = ' || vr_nrcpfcgc || '; ' );
        
      exception
        when others then
        
          vr_dscritic := 'Erro ao Atualizar nmpessoa do cnpj ' || vr_nrcpfcgc || sqlerrm;
          RAISE vr_exception;
        
      end;
      
    end if;
    
    OPEN cr_crapjur(vr_nrcpfcgc, vr_cdcooper);
    FETCH cr_crapjur INTO rw_crapjur;
    
    IF cr_crapjur%NOTFOUND THEN
      
      CLOSE cr_crapjur;
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_nrcpfcgc || '     CPF Não encontrado na TTL.');
      
      CONTINUE;
      
    END IF;
    
    CLOSE cr_crapjur;
    
    vr_resto     := 0;
    vr_parcela   := 0;
    vr_tpaltera  := 2;
    
    IF vr_vldrendi > 1 THEN
      
      OPEN cr_crapjfn(pr_nrdconta => rw_crapjur.nrdconta
                    , pr_cdcooper => rw_crapjur.cdcooper);
      FETCH cr_crapjfn INTO rg_crapjfn;
      
      IF cr_crapjfn%NOTFOUND THEN
        
        INSERT INTO CECRED.crapjfn (
          cdcooper
          , nrdconta
        ) VALUES (
          rw_crapjur.cdcooper
          , rw_crapjur.nrdconta
        );
        
        CLOSE cr_crapjfn;
        
        OPEN cr_crapjfn(rw_crapjur.nrdconta
                      , rw_crapjur.cdcooper);
        FETCH cr_crapjfn INTO rg_crapjfn;
        
      END IF;
      
      CLOSE cr_crapjfn;
      
      vr_resto     := MOD(vr_vldrendi, 12);
      vr_parcela   := ( ( vr_vldrendi - vr_resto ) / 12 );
      vr_rollback  := ' ';
      vr_seprbk    := ' ';
      
      FOR i IN 1..12 LOOP
        
        IF i = 12 THEN
          
          vr_parcela := vr_parcela + vr_resto;
          
        END IF;
        
        CASE i
          WHEN 1 THEN
            
            vr_mes := 11;
            vr_ano := 2021;
            
            IF NVL(rg_crapjfn.vlrftbru##1 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##1 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##1 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##1 = vr_parcela
                  , mesftbru##1 = vr_mes
                  , anoftbru##1 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##1 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##1 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##1, ',', '.' ) ;
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##1 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##1 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt    := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##1;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##1, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##1 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt    := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##1;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 2 THEN
            
            vr_mes := 12;
            vr_ano := 2021;
            
            IF NVL(rg_crapjfn.vlrftbru##2 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##2 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##2 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##2 = vr_parcela
                  , mesftbru##2 = vr_mes
                  , anoftbru##2 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##2 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##2 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##2, ',', '.' );
                vr_seprbk    := ', ';

              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##2 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##2 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##2;
                vr_seprbk    := ', ';

              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##2, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##2 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##2;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 3 THEN
            
            vr_mes := 1;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##3 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##3 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##3 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##3 = vr_parcela
                  , mesftbru##3 = vr_mes
                  , anoftbru##3 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##3 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##3 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##3, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##3 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##3 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##3;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##3, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##3 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##3;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 4 THEN
            
            vr_mes := 2;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##4 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##4 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##4 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##4 = vr_parcela
                  , mesftbru##4 = vr_mes
                  , anoftbru##4 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##4 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##4 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##4, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##4 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##4 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##4;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##4, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##4 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##4;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 5 THEN
            
            vr_mes := 3;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##5 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##5 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##5 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##5 = vr_parcela
                  , mesftbru##5 = vr_mes
                  , anoftbru##5 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##5 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##5 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##5, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##5 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##5 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##5;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##5, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##5 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##5;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 6 THEN
            
            vr_mes := 4;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##6 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##6 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##6 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##6 = vr_parcela
                  , mesftbru##6 = vr_mes
                  , anoftbru##6 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##6 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##6 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##6, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##6 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##6 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##6;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##6, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##6 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##6;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 7 THEN
            
            vr_mes := 5;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##7 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##7 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##7 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##7 = vr_parcela
                  , mesftbru##7 = vr_mes
                  , anoftbru##7 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##7 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##7 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##7, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##7 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##7 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##7;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##7, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##7 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##7;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 8 THEN
            
            vr_mes := 6;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##8 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##8 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##8 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##8 = vr_parcela
                  , mesftbru##8 = vr_mes
                  , anoftbru##8 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##8 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##8 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##8, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##8 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##8 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##8;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##8, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##8 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##8;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 9 THEN
            
            vr_mes := 7;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##9 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##9 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##9 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##9 = vr_parcela
                  , mesftbru##9 = vr_mes
                  , anoftbru##9 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##9 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##9 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##9, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##9 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##9 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##9;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##9, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##9 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto0' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##9;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 10 THEN
            
            vr_mes := 8;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##10 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##10 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##10 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##10 = vr_parcela
                  , mesftbru##10 = vr_mes
                  , anoftbru##10 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##10 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##10 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##10, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##10 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##10 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##10;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##10, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##10 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##10;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 11 THEN
            
            vr_mes := 9;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##11 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##11 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##11 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##11 = vr_parcela
                  , mesftbru##11 = vr_mes
                  , anoftbru##11 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##11 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##11 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##11, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##11 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##11 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##11;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##11, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##11 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##11;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
          WHEN 12 THEN
            
            vr_mes := 10;
            vr_ano := 2022;
            
            IF NVL(rg_crapjfn.vlrftbru##12 , 0) <> vr_parcela
               OR NVL(rg_crapjfn.mesftbru##12 , 0) <> vr_mes
               OR NVL(rg_crapjfn.anoftbru##12 , 0) <> vr_ano THEN
            
              UPDATE CECRED.crapjfn 
                SET vlrftbru##12 = vr_parcela
                  , mesftbru##12 = vr_mes
                  , anoftbru##12 = vr_ano
                  , dtaltjfn##4 = vr_dtmvtolt
                  , cdopejfn##4 = 1
              WHERE cdcooper = rw_crapjur.cdcooper
                AND nrdconta = rw_crapjur.nrdconta;
              
              IF NVL(rg_crapjfn.vlrftbru##12 , 0) <> vr_parcela THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Valor faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.vlrftbru##12 , 0), '999999999D99' ) )
                                              ,pr_dsdadatu => TRIM( to_char( vr_parcela, '999999999D99' ) ) );
                
                vr_msgalt := vr_msgalt || 'vl.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' vlrftbru##' || i || ' = ' || replace( rg_crapjfn.vlrftbru##12, ',', '.' );
                vr_seprbk    := ', ';
              
              END IF;
            
              IF NVL(rg_crapjfn.mesftbru##12 , 0) <> vr_mes THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Mês do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.mesftbru##12 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_mes) );
              
                vr_msgalt := vr_msgalt || 'mes.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' mesftbru##' || i || ' = ' || rg_crapjfn.mesftbru##12;
                vr_seprbk    := ', ';
              
              END IF;
              
              IF NVL(rg_crapjfn.anoftbru##12, 0) <> vr_ano THEN
                
                vr_nrdrowid := getIdLogCabecalho();
                
                CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                              ,pr_nmdcampo => 'Ano do faturamento bruto ' || i
                                              ,pr_dsdadant => TRIM( to_char( NVL(rg_crapjfn.anoftbru##12 , 0), '999999999' ) )
                                              ,pr_dsdadatu => to_char(vr_ano) );
              
                vr_msgalt := vr_msgalt || 'ano.fat.bruto' || i || ',';
                
                vr_tpaltera  := 1;
                
                vr_rollback  := vr_rollback || vr_seprbk || ' anoftbru##' || i || ' = ' || rg_crapjfn.anoftbru##12;
                vr_seprbk    := ', ';
              
              END IF;
            
            END IF;
            
        END CASE;
        
      END LOOP;
      
      IF TRIM(vr_rollback) IS NOT NULL THEN
        
        BEGIN
          
          UPDATE CECRED.crapjur 
            SET vlfatano = vr_vldrendi
          WHERE nrdconta = rw_crapjur.nrdconta
            AND cdcooper = rw_crapjur.cdcooper;
          
        EXCEPTION
          WHEN OTHERS THEN
                
            vr_dscritic := vr_nrcpfcgc || ' - Erro ao atualizar faturamento total Ano ' || sqlerrm;
            RAISE vr_exception;
            
        END;
        
        vr_rollback := '    UPDATE CECRED.crapjfn SET ' || vr_rollback
                       || '   , dtaltjfn##4 = to_date(''' || to_date(rg_crapjfn.dtaltjfn##4, 'dd/mm/rrrr') || ''', ''dd/mm/rrrr'') '
                       || '   , cdopejfn##4 = ''' || rg_crapjfn.cdopejfn##4 || ''' '
                       || ' WHERE nrdconta = ' || rw_crapjur.nrdconta
                       || '   AND cdcooper = ' || rw_crapjur.cdcooper || '; ';
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_rollback );
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv,  '    UPDATE CECRED.crapjur '
                                                       || '   SET vlfatano = ' || replace(rw_crapjur.vlfatano, ',', '.')
                                                       || ' WHERE nrdconta = ' || rw_crapjur.nrdconta
                                                       || '   AND cdcooper = ' || rw_crapjur.cdcooper || '; ' );
        
      END IF;
      
    ELSE
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '  --- ' || vr_nrcpfcgc || ' | ' || rw_crapjur.nrdconta || ' | ' || rw_crapjur.cdcooper || ' Valor de Faturamento inferior a R$ 1,00. ' || TRIM( to_char( NVL(vr_vldrendi, 0), '999999999D99' ) ));
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
    END IF;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_ddd01
                     , pr_nrtelefo  => vr_fone01
                     , pr_tptelefo  => 3
                     , pr_det_log   => 'com.01'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_ddd01 || ') ' || vr_fone01 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_ddd02
                     , pr_nrtelefo  => vr_fone02
                     , pr_tptelefo  => 3
                     , pr_det_log   => 'com.02'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_ddd02 || ') ' || vr_fone02 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_ddd03
                     , pr_nrtelefo  => vr_fone03
                     , pr_tptelefo  => 3
                     , pr_det_log   => 'com.03'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_ddd03 || ') ' || vr_fone03 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddcel01
                     , pr_nrtelefo  => vr_celu01
                     , pr_tptelefo  => 2
                     , pr_det_log   => 'cel.01'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddcel01 || ') ' || vr_celu01 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddcel02
                     , pr_nrtelefo  => vr_celu02
                     , pr_tptelefo  => 2
                     , pr_det_log   => 'cel.02'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddcel02 || ') ' || vr_celu02 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddcel03
                     , pr_nrtelefo  => vr_celu03
                     , pr_tptelefo  => 2
                     , pr_det_log   => 'cel.03'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddcel03 || ') ' || vr_celu03 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddctato01
                     , pr_nrtelefo  => vr_ctato01
                     , pr_tptelefo  => 4
                     , pr_det_log   => 'cont.01'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddctato01 || ') ' || vr_ctato01 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddctato02
                     , pr_nrtelefo  => vr_ctato02
                     , pr_tptelefo  => 4
                     , pr_det_log   => 'cont.02'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddctato02 || ') ' || vr_ctato02 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddctato03
                     , pr_nrtelefo  => vr_ctato03
                     , pr_tptelefo  => 4
                     , pr_det_log   => 'cont.03'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddctato03 || ') ' || vr_ctato03 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddctatocel01
                     , pr_nrtelefo  => vr_ctatocel01
                     , pr_tptelefo  => 4
                     , pr_det_log   => 'cont-cel.01'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddctatocel01 || ') ' || vr_ctatocel01 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddctatocel02
                     , pr_nrtelefo  => vr_ctatocel02
                     , pr_tptelefo  => 4
                     , pr_det_log   => 'cont-cel.02'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddctatocel02 || ') ' || vr_ctatocel02 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    
    BEGIN
          
      cadastraTelefone(pr_nrdddtfc  => vr_dddctatocel03
                     , pr_nrtelefo  => vr_ctatocel03
                     , pr_tptelefo  => 4
                     , pr_det_log   => 'cont-cel.03'
                     );
          
    EXCEPTION
      WHEN OTHERS THEN
          
        IF cr_craptfc%ISOPEN THEN
          CLOSE cr_craptfc;
        END IF;
          
        vr_dscritic := vr_nrcpfcgc || ' - Erro ao cadastrar telefone (' || vr_dddctatocel03 || ') ' || vr_ctatocel03 || ' - ' || sqlerrm;
        RAISE vr_exception;
            
    END;
    
    IF TRIM(vr_email) IS NOT NULL THEN
      
      OPEN cr_crapcem ( rw_crapjur.cdcooper
                       , rw_crapjur.nrdconta
                       , 1
                       , vr_email);
      FETCH cr_crapcem INTO rg_crapcem;
      
      IF cr_crapcem%NOTFOUND THEN
        
        BEGIN
          
          INSERT INTO CECRED.crapcem (
            cdoperad
            , nrdconta
            , dsdemail
            , dtmvtolt
            , hrtransa
            , cdcooper
            , idseqttl
            , dtinsori
            , inprincipal
          ) VALUES (
            1
            , rw_crapjur.nrdconta
            , vr_email
            , vr_dtmvtolt
            , gene0002.fn_busca_time
            , rw_crapjur.cdcooper
            , 1
            , SYSDATE
            , 0
          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, '  DELETE CECRED.CRAPCEM '
                                                      || ' WHERE nrdconta = ' || rw_crapjur.nrdconta
                                                      || '   AND cdcooper = ' || rw_crapjur.cdcooper
                                                      || '   AND idseqttl = ' || 1
                                                      || '   AND dsdemail = ''' || vr_email || '''; ' );
          
          vr_nrdrowid := getIdLogCabecalho();
      
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                          ,pr_nmdcampo => 'E-mail'
                                          ,pr_dsdadant => ' '
                                          ,pr_dsdadatu => TRIM( vr_email ) );
          
          vr_msgalt := vr_msgalt || 'Add e-mail.1.ttl,';
          
        EXCEPTION
          WHEN OTHERS THEN
            
            CLOSE cr_crapcem;
            vr_dscritic := 'Erro ao cadastrar o e-mail: ' || vr_email || ' - ' || sqlerrm;
            RAISE vr_exception;
            
        END;
        
      END IF;
      
      CLOSE cr_crapcem;
    
    END IF;
    
    IF TRIM(vr_msgalt) IS NOT NULL THEN
      
      CADASTRO.registrarAlteracaoAssociado(pr_cdcooper => rw_crapjur.cdcooper
                                          ,pr_nrdconta => rw_crapjur.nrdconta
                                          ,pr_dtaltera => vr_dtmvtolt
                                          ,pr_cdoperad => 1
                                          ,pr_dsaltera => 'RITM0260409 - Enriquecimento de base Boa Vista, outubro de 2022. ' || vr_msgalt
                                          ,pr_tpaltera => vr_tpaltera
                                          ,pr_flgctitg => 3
                                          ,pr_dtmvtolt => vr_dtmvtolt);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_nrcpfcgc || ' | ' || rw_crapjur.nrdconta || ' | ' || rw_crapjur.cdcooper || ' - ' || vr_msgalt);
    
    ELSE
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '    ### ' || vr_nrcpfcgc || ' | ' || rw_crapjur.nrdconta || ' | ' || rw_crapjur.cdcooper || ' - CNPJ SEM ALTERAÇÕES NO ARQUIVO. ' );
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
    END IF;
    
    vr_count := vr_count + 1;
    
    if rw_crapjur.qtd_contas > 0 then
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, '  ****** ' || vr_nrcpfcgc || ' | ' || rw_crapjur.nrdconta || ' | ' || rw_crapjur.cdcooper || ' QTD outras contas: ' || rw_crapjur.qtd_contas);
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, ' ');
      
    end if;
    
    IF vr_count > 500 THEN
      
      vr_count := 0;
      
      COMMIT;
      
    END IF;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script.');
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    COMMIT;
    
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20000, vr_dscritic);
    
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);

    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;

    RAISE_APPLICATION_ERROR(-20000, SQLERRM);
    
END;

