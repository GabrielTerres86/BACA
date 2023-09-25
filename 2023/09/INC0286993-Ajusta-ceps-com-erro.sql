DECLARE

  vr_nmdireto           VARCHAR2(100);
  vr_nmarquiv           VARCHAR2(50) := 'INC0286993_dados.csv';
  vr_input_file         UTL_FILE.FILE_TYPE;
  vr_nmarqbkp           VARCHAR2(50) := 'INC0286993_script_ROLLBACK';
  vr_ind_arquiv         utl_file.file_type;
  vr_nmarqlog           VARCHAR2(50) := 'INC0286993_relatorio_exec.txt';
  vr_ind_arqlog         utl_file.file_type;
  
  vr_texto_completo     VARCHAR2(32600) := NULL;
  vr_texto_completo_ret VARCHAR2(32600) := NULL;
  vr_setlinha           VARCHAR2(10000);
  vr_count              PLS_INTEGER;
  vr_count_file         PLS_INTEGER;
  vr_seq_file           NUMBER(2);
  
  vr_dtmvtolt           CECRED.crapalt.DTALTERA%TYPE;
  vr_hrtransa           CECRED.craplgm.HRTRANSA%TYPE;
  vr_nrdrowid           ROWID;
  vr_nrcpfcgc           CECRED.crapass.NRCPFCGC%TYPE;
  vr_nmrescop           CECRED.crapcop.NMRESCOP%TYPE;
  vr_cdcooper           CECRED.crapcop.CDCOOPER%TYPE;
  vr_nrdconta           CECRED.crapass.NRDCONTA%TYPE;
  vr_idseqttl           CECRED.crapttl.IDSEQTTL%TYPE;
  vr_dsbairro           CECRED.crapenc.NMBAIRRO%TYPE;
  vr_nrcepend           CECRED.crapenc.NRCEPEND%TYPE;
  vr_ufendere           CECRED.crapenc.CDUFENDE%TYPE;
  
  vr_comments           VARCHAR2(2000);
  vr_ttlencontrado      BOOLEAN;
  
  vr_dscritic           VARCHAR2(2000);
  vr_exception          EXCEPTION;
  
  CURSOR cr_crapcop (pr_nmrescop IN CECRED.crapcop.NMRESCOP%TYPE) IS
    SELECT c.cdcooper
    FROM CECRED.Crapcop c
    WHERE c.nmrescop = TRIM( UPPER( pr_nmrescop ) );
  
  CURSOR cr_validacep(pr_cepvalidar    IN NUMBER
                    , pr_bairro        IN CECRED.crapenc.NMBAIRRO%TYPE
                    , pr_ufvalidar     IN CECRED.crapenc.CDUFENDE%TYPE) IS
    SELECT LENGTH(e.nrceplog) tamanho_cep
      , count(1) OVER( PARTITION BY E.NRCEPLOG ) QTD
      , e.* 
    FROM CECRED.crapdne E
    WHERE e.nrceplog LIKE '%' || pr_cepvalidar || '%'
      AND ( 
        (
          E.NMRESBAI LIKE '%' || NVL(pr_bairro, '-------') || '%'
          OR E.NMEXTBAI LIKE '%' || NVL(pr_bairro, '-------') || '%'
        )
        OR
        (
          E.CDUFLOGR = NVL(pr_ufvalidar, 'xx')
        )
      )
    ORDER BY 1 desc;
  
  rg_validacep          cr_validacep%ROWTYPE;
  
  CURSOR cr_crapttl (pr_cooperativa  IN CECRED.crapass.CDCOOPER%TYPE
                   , pr_conta        IN CECRED.crapass.NRDCONTA%TYPE
                   , pr_cpf          IN CECRED.crapttl.NRCPFCGC%TYPE
                   , pr_idseq        IN CECRED.Crapttl.IDSEQTTL%TYPE
                   , pr_cep          IN CECRED.crapenc.NRCEPEND%TYPE) IS
    SELECT t.nrdconta
      , t.cdcooper
      , e.ROWID rowid_endereco
      , e.nrcepend
      , e.tpendass
      , COUNT(1) OVER( PARTITION BY t.nrdconta )                qtd_encs_cooperado
    FROM CECRED.crapttl T
    JOIN CECRED.Crapenc e on t.cdcooper = e.cdcooper
                             AND t.nrdconta = e.nrdconta
                             AND t.idseqttl = e.idseqttl
    WHERE t.cdcooper = pr_cooperativa
      AND t.nrdconta = pr_conta
      AND t.nrcpfcgc = pr_cpf
      AND t.idseqttl = pr_idseq
      AND e.nrcepend = pr_cep;
  
  rg_crapttl  cr_crapttl%ROWTYPE;
  
BEGIN
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS') || 'cpd/bacas/INC0286993';
  
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
  
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_input_file
                          ,pr_des_erro => vr_dscritic);
                          
  IF vr_dscritic IS NOT NULL THEN
    
    RAISE vr_exception;
     
  END IF;
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'BEGIN');
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Início: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS') );
  vr_count := 0;
  
  LOOP
    
    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file
                                ,pr_des_text => vr_setlinha);
    
    vr_setlinha := REPLACE( REPLACE( vr_setlinha, CHR(10) ), CHR(13) );
    
    vr_comments := 'Cooperativa;tppessoa ;nrcpfcnpj   ;nrcc    ;nrtitular ;dstipoendereco ;nmlogradouro            ;nrlogradouro ;dscomplemento         ;nmbairro         ;dscidade  ;CEP     ;dsuf';
    vr_comments := 'VIACREDI   ;PF       ;10744032903 ;9639390 ;2         ;Residencial    ;RUA EMILIO MANKE JUNIOR ;108          ;CASA                  ;ILHA DA FIGUEIRA ;          ;8927000 ; ';
    vr_comments := 'VIACREDI   ;PF       ;10521158966 ;8543950 ;1         ;Residencial    ;AVENIDA RIO DE JANEIRO  ;329          ;                      ;MIRIM            ;GUARATUBA ;8328000 ;PR';
    
    vr_nmrescop := UPPER( TRIM( gene0002.fn_busca_entrada(1, vr_setlinha, ';') ) );
    vr_nrcpfcgc := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(3, vr_setlinha, ';') ) );
    vr_nrdconta := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(4, vr_setlinha, ';') ) );
    
    IF NVL(vr_nrdconta, 0) = 0 THEN
      
      vr_comments := ' Caso o CSV venha com cabeçalho, ignora o loop onde não tenha um número de conta ';
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta 1;' || ' Sem número de conta no arquivo de origem. ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop
      );
      CONTINUE;
      
    END IF;
    
    OPEN cr_crapcop(vr_nmrescop);
    FETCH cr_crapcop INTO vr_cdcooper;
    
    IF cr_crapcop%NOTFOUND THEN
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta 2;' || ' ERRO ao buscar código para a Cooperativa informada no arquivo de carga. ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop
      );
      
      CLOSE cr_crapcop;
      
      vr_comments := 'Se não encontrar a cooperativa, passa para o próximo registro registrando o alerta em Log';
      CONTINUE;
      
    END IF;
    
    CLOSE cr_crapcop;
    
    vr_idseqttl := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(5, vr_setlinha, ';') ) );
    vr_dsbairro := UPPER(                               TRIM( gene0002.fn_busca_entrada(10, vr_setlinha, ';') ) );
    vr_nrcepend := CECRED.gene0002.fn_char_para_number( TRIM( gene0002.fn_busca_entrada(12, vr_setlinha, ';') ) );
    vr_ufendere := UPPER(                               TRIM( gene0002.fn_busca_entrada(13, vr_setlinha, ';') ) );
    
    
    OPEN cr_validacep(vr_nrcepend, vr_dsbairro, vr_ufendere);
    FETCH cr_validacep INTO rg_validacep;
    
    IF cr_validacep%NOTFOUND THEN
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta 3;' || ' *** Não foi encontrado um CEP na DNE para a combinação de CEP, UF e Bairro. ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop || ' ; '
                                                    || vr_nrcepend || ' ; '
                                                    || vr_ufendere || ' ; '
                                                    || vr_dsbairro
      );
      
      CLOSE cr_validacep;
      vr_comments := 'Se não encontrar um registro de cep na CRAPDNE, passa para o próximo registro registrando o alerta em Log';
      
      CONTINUE;
      
    END IF;
    
    CLOSE cr_validacep;
    
    IF rg_validacep.tamanho_cep < 8 OR rg_validacep.tamanho_cep <= LENGTH(vr_nrcepend) THEN
      
      vr_comments := 'INDICA QUE O CEP FOI ENCONTRADO JÁ REDUZIDO NA DNE E QUE O QUE TEM A MAIOR QUANTIDADE DE DÍGITOS É ABAIXO DE 8.. GERAR LOG DISSO E PULAR PARA O PRÓXIMO REGISTRO.';
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta 4;' || ' Tamanho do maior cep na base já reduzido: (' || rg_validacep.tamanho_cep || ') dígitos - ' 
                                                    || rg_validacep.qtd || ' reg. encontrados na CRAPDNE - ' || rg_validacep.nrceplog || ' ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop || ' ; '
                                                    || vr_nrcepend || ' ; '
                                                    || vr_ufendere || ' ; '
                                                    || vr_dsbairro
      );
      
      CONTINUE;
      
    END IF;
    
    vr_ttlencontrado := FALSE;
    
    OPEN cr_crapttl(vr_cdcooper, vr_nrdconta, vr_nrcpfcgc, vr_idseqttl, vr_nrcepend);
    LOOP
      FETCH cr_crapttl INTO rg_crapttl;
      EXIT WHEN cr_crapttl%NOTFOUND;
      
      vr_ttlencontrado := TRUE;
      
      IF rg_validacep.tamanho_cep = 8 THEN
        
        BEGIN
          
          UPDATE CECRED.Crapenc 
            SET nrcepend = rg_validacep.nrceplog
          WHERE ROWID = rg_crapttl.rowid_endereco;
          
          vr_dtmvtolt := SISTEMA.datascooperativa(rg_crapttl.cdcooper).dtmvtolt;
          vr_hrtransa := gene0002.fn_busca_time;
          
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
          VALUES(rg_crapttl.cdcooper
           ,1
           ,null
           ,'Script'
           ,'INC0286993 - Ajuste de CEPs por script conforme solicitado no incidente.'
           ,vr_dtmvtolt
           ,1
           ,vr_hrtransa
           ,1
           ,'JOB'
           ,rg_crapttl.nrdconta)
          RETURNING ROWID INTO vr_nrdrowid;
              
          CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid  => vr_nrdrowid
                                          ,pr_nmdcampo  => 'Crapenc.nrceplog'
                                          ,pr_dsdadant  => rg_crapttl.nrcepend
                                          ,pr_dsdadatu  => rg_validacep.nrceplog
                                          );
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' UPDATE CECRED.Crapenc SET nrcepend = ' || rg_crapttl.nrcepend
                                                        || ' WHERE ROWID = ''' || rg_crapttl.rowid_endereco || ''' ;');
          
          gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'SUCESSO;' || ' Ajustado cep do cooperado (TP: ' || rg_crapttl.tpendass || ') para: (' || rg_validacep.tamanho_cep || ') dígitos - ' 
                                                        || 'DE: ' || rg_crapttl.nrcepend || ' - PARA: ' || rg_validacep.nrceplog || ' ;'
                                                        || vr_nrcpfcgc || ' ; '
                                                        || vr_nrdconta || ' ; '
                                                        || vr_nmrescop || ' ; '
                                                        || vr_nrcepend || ' ; '
                                                        || vr_ufendere || ' ; '
                                                        || vr_dsbairro
          );
          
        EXCEPTION
          WHEN OTHERS THEN
            
            CLOSE cr_crapttl;
            vr_dscritic := 'Erro ao atualizar crapenc: ' || SQLERRM;
            RAISE vr_exception;
            
        END;
        
      ELSE 
        
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta 5;' || ' Tamanho do CEP para atualização diferente de 8 (= ' || rg_validacep.tamanho_cep || '). Registro NÃO tualizado. vr_idseqttl: ' 
                                                      || vr_idseqttl || ' TPENDERECO: ' || rg_crapttl.tpendass || ';'
                                                      || vr_nrcpfcgc || ' ; '
                                                      || vr_nrdconta || ' ; '
                                                      || vr_nmrescop || ' (' || vr_cdcooper || ') ; '
                                                      || vr_nrcepend
        );
        
      END IF;
        
    END LOOP;
    
    CLOSE cr_crapttl;
    
    IF NOT vr_ttlencontrado THEN
      
      vr_comments := 'Se não encontrar um registro n TTL salva o alerta em Log';
      
      gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Alerta 6;' || ' *** Não foi encontrado registro de conta na TTL para atualização. vr_idseqttl: ' || vr_idseqttl || ' ;'
                                                    || vr_nrcpfcgc || ' ; '
                                                    || vr_nrdconta || ' ; '
                                                    || vr_nmrescop || ' (' || vr_cdcooper || ') ; '
                                                    || vr_nrcepend
      );
      
    END IF;
    
  END LOOP;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, ' COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
  
  COMMIT;
  
EXCEPTION
    WHEN no_data_found THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);

    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'COMMIT;');
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'EXCEPTION WHEN OTHERS THEN ROLLBACK; RAISE_APPLICATION_ERROR(-20000, SQLERRM); END;');
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'Final do script: ' || TO_CHAR(SYSDATE, 'DD/MM/RRRR HH24:MI:SS'));
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    COMMIT;
    
  WHEN vr_exception THEN
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || vr_dscritic );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, vr_dscritic);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20003, 'Erro: ' || vr_dscritic);
    
  WHEN OTHERS THEN
    
    cecred.pc_internal_exception;
    
    GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
    
    gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 'ERRO: ' || SQLERRM );
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
    
    gene0001.pc_escr_linha_arquivo(vr_ind_arqlog, 'ERRO NAO TRATADO: ' || SQLERRM);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
    
    ROLLBACK;
    
    RAISE_APPLICATION_ERROR(-20004, 'ERRO NÃO TRATADO: ' || SQLERRM);
    
END;
