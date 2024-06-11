declare 
  vr_exc_erro   EXCEPTION;
  vr_dscritic   VARCHAR2(4000);
  vr_idprglog   NUMBER;
  vr_dhrecebi   DATE;
  
  vr_jsonroot     cecred.pljson := pljson();
  vr_jsonrootgrp  cecred.pljson := pljson();
  vr_integrantes  cecred.pljson_list := pljson_list();
  vr_jsongrupos   cecred.pljson_list := pljson_list();
  vr_jsongrupo    cecred.pljson := pljson();
  vr_integrante   cecred.pljson := pljson();

  vr_nmdogrupo  VARCHAR2(255) DEFAULT ''; 
  vr_flgcontas  BOOLEAN;
  
  vr_idgrupo_economico GESTAODERISCO.tbrisco_grupo_economico_integrante.cdgrupo_economico%TYPE;
  vr_cdcooper          GESTAODERISCO.tbrisco_grupo_economico_integrante.cdcooper%TYPE;
  vr_nrcpfcgc          GESTAODERISCO.tbrisco_grupo_economico_integrante.nrcpfcnpj%TYPE;
  vr_dtinclus          DATE;

  vr_dsdireto       VARCHAR2(2000);
  vr_nmarquiv       VARCHAR2(100);
  vr_ind_arquiv     utl_file.file_type;
  vr_ind_arqlog     utl_file.file_type;
  vr_dslinha        VARCHAR2(4000);
  vr_dados_rollback CLOB;
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_dttransa       cecred.craplgm.dttransa%type;
  vr_hrtransa       cecred.craplgm.hrtransa%type;
  vr_nrdrowid       ROWID;
  vr_typ_saida      VARCHAR2(3);
  
  vr_arquivo_clob          CLOB;
  
  CURSOR cr_grupo_economico(pr_idgrupo_economico IN GESTAODERISCO.tbrisco_grupo_economico_integrante.cdgrupo_economico%TYPE) IS
    SELECT g.cdgrupo_economico
      FROM GESTAODERISCO.tbrisco_grupo_economico_integrante g
     WHERE g.cdgrupo_economico = pr_idgrupo_economico;
  rw_grupo_economico cr_grupo_economico%ROWTYPE;
  
  CURSOR cr_rollback(pr_idgrupo_economico IN GESTAODERISCO.tbrisco_grupo_economico_integrante.cdgrupo_economico%TYPE) IS
    SELECT g.*
      FROM GESTAODERISCO.tbrisco_grupo_economico_integrante g
     WHERE g.cdgrupo_economico = pr_idgrupo_economico;
  rw_rollback cr_rollback%ROWTYPE;
  
  CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
    SELECT a.nrdconta
      FROM crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.nrcpfcgc = pr_nrcpfcgc;
  rw_crapass cr_crapass%ROWTYPE;
  
  FUNCTION getListaJson(pr_json       IN cecred.pljson
                       ,pr_busca      IN VARCHAR2 
                       ,pr_msgretorno IN VARCHAR2 DEFAULT NULL) RETURN CECRED.PLJSON_LIST IS 
    vr_retorno  CECRED.PLJSON_LIST := pljson_list();
  BEGIN

   vr_retorno := pljson_list( pr_json.get(pr_busca) );
   return(vr_retorno);

  EXCEPTION
   WHEN OTHERS THEN
     IF TRIM(pr_msgretorno) IS NOT NULL THEN
       vr_dscritic := pr_msgretorno;
     ELSE
       vr_dscritic := 'Erro ao extrair dados do índice (' || pr_busca || ') no grupo (' || vr_nmdogrupo || ')';
     END IF;
     RAISE vr_exc_erro;
  END getListaJson;
  
  
  FUNCTION getObjetoJsonJs (pr_json     IN cecred.pljson
                            , pr_busca  IN VARCHAR2 
                            , pr_msgretorno IN VARCHAR2 DEFAULT NULL) RETURN CECRED.PLJSON IS 
    
    vr_retorno  CECRED.PLJSON := pljson();
    
  BEGIN
    
    vr_retorno := pljson( pr_json.get(pr_busca) );
    return(vr_retorno);
    
  EXCEPTION
    WHEN OTHERS THEN
      
      IF TRIM(pr_msgretorno) IS NOT NULL THEN
        vr_dscritic := pr_msgretorno;
      ELSE
        vr_dscritic := 'Erro ao extrair dados do índice (' || pr_busca || ') no grupo (' || vr_nmdogrupo || ')';
      END IF;
      
      RAISE vr_exc_erro;
      
  END getObjetoJsonJs;

  FUNCTION getObjetoJson(pr_json       IN cecred.pljson_list
                        ,pr_busca      IN VARCHAR2 
                        ,pr_msgretorno IN VARCHAR2 DEFAULT NULL) RETURN CECRED.PLJSON IS 
    vr_retorno  CECRED.PLJSON := pljson();
  BEGIN

    vr_retorno := pljson( pr_json.get(pr_busca) );
    return(vr_retorno);

  EXCEPTION
    WHEN OTHERS THEN
      IF pr_msgretorno IS NOT NULL THEN
        vr_dscritic := pr_msgretorno;
      ELSE
        vr_dscritic := 'Erro ao extrair dados do índice (' || pr_busca || ') no grupo (' || vr_nmdogrupo || ')';
      END IF;
      RAISE vr_exc_erro;
  END getObjetoJson;
  
  FUNCTION limpaTexto (pr_texto IN VARCHAR2) RETURN VARCHAR2 IS
    
    vr_tmp   VARCHAR2(1000);
    vr_txt   VARCHAR2(1000);
    
  BEGIN
    
    vr_tmp := regexp_replace(pr_texto, '"', '');
    vr_txt := TRIM( regexp_replace(vr_tmp
                                     , 'null'
                                     , ''
                                     , 1     
                                     , 0     
                                     , 'i'   
                                   )
                   );
    
    RETURN(vr_txt);
    
  END limpaTexto;
  
  PROCEDURE validaLimiteTamanho(pr_numero       IN NUMBER
                                , pr_tamanho    IN NUMBER
                                , pr_nmcampo    IN VARCHAR2) IS

  BEGIN
    
    IF LENGTH(pr_numero) > pr_tamanho THEN
      vr_dscritic := 'Valor inválido para o campo ' || pr_nmcampo || '. Esperado no máximo ' 
                     || pr_tamanho || ' dígitos e recebido o valor: ' || pr_numero;
      RAISE vr_exc_erro;
    END IF;
    
  END;
  
  FUNCTION getValor(pr_atributo      IN VARCHAR2
                   ,pr_json          IN cecred.pljson
                   ,pr_obrigatorio   IN BOOLEAN
                   ,pr_tipdado       IN VARCHAR2
                   ,pr_qtdchar       IN NUMBER DEFAULT NULL
                   ,pr_qtdchar_MAX   IN NUMBER DEFAULT NULL
                   ,pr_qtdnum_MAX    IN NUMBER DEFAULT NULL
                   ,pr_desc_atributo IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
    
    vr_retorno          VARCHAR2(1000);
    vr_erro_valida      BOOLEAN;
    vr_tpdado           VARCHAR2(50);
    vr_tipodado         VARCHAR2(50);
    vr_pos_erro         PLS_INTEGER;
    vr_criticcd         NUMBER;
    vr_criticds         VARCHAR2(2000);
    
  BEGIN
    
    vr_retorno      := '';
    vr_erro_valida  := FALSE;
    vr_tpdado       := UPPER(pr_tipdado);
    vr_tipodado     := '';
    
    BEGIN
      
      IF pr_json.get(pr_atributo).is_string() THEN
        vr_retorno := limpaTexto( pr_json.get(pr_atributo).get_string() );
      ELSIF pr_json.get(pr_atributo).is_number() THEN
        vr_retorno := limpaTexto( pr_json.get(pr_atributo).get_number() );
      ELSIF pr_json.get(pr_atributo).is_null() THEN
        vr_retorno := NULL;
      ELSE
        vr_retorno := limpaTexto( pr_json.get(pr_atributo).to_char() );
      END IF;
      
    EXCEPTION 
      WHEN OTHERS THEN
        IF pr_obrigatorio THEN
          
          vr_dscritic := 'O campo (' || NVL(pr_desc_atributo, pr_atributo) || ') do grupo (' || vr_nmdogrupo || ') não foi encontrado na estrutura de dados.';
          RAISE vr_exc_erro;
          
        ELSE
          vr_retorno := '';
        END IF;
    END;
     
    IF vr_tpdado IN ('MAIL', 'CHAR')
       AND TRIM(vr_retorno) IS NOT NULL
       AND LENGTH(TRIM(TRANSLATE(vr_retorno, ' 0123456789', ' '))) > 0 THEN
      
      vr_retorno := GENE0007.fn_caract_acento(pr_texto => vr_retorno);
      
      CONTACORRENTE.validaCaracteresTexto (
        pr_dstexto                => to_char( utl_raw.cast_to_raw(vr_retorno) )
        , pr_nmdomlib             => 'MAPA_CARACT_VALIDOS_NOVO_CORE'
        , pr_nmdomblq             => 'MAPA_CARACT_BLOQ_NOVO_CORE'
        , pr_nrdconta             => NULL
        , pr_cdcooper             => 3 
        , pr_poserror             => vr_pos_erro
        , pr_dscritic             => vr_criticds
        , pr_cdcritic             => vr_criticcd
        , pr_dstxtret             => vr_retorno
      );
      
      
      vr_retorno := TRIM( UPPER(vr_retorno) );
      
    END IF;
     
    
    IF LENGTH(vr_retorno) > 1 THEN
      IF vr_tpdado = 'DATA' THEN
        
        vr_retorno := SUBSTR(vr_retorno, 1, 10);
        
        IF CECRED.gene0002.fn_data(pr_vlrteste => vr_retorno, pr_formato => 'DD/MM/RRRR') = FALSE THEN
          vr_tipodado    := 'Data';
          vr_erro_valida := TRUE;
        END IF;
        
      ELSIF vr_tpdado = 'NUM' THEN
          
          IF LENGTH(TRIM(TRANSLATE(vr_retorno, ' +-.,0123456789', ' '))) > 0 THEN
            vr_tipodado    := 'Número';
            vr_erro_valida := TRUE;
          ELSIF pr_qtdnum_MAX IS NOT NULL AND pr_qtdnum_MAX > 0 THEN
            
            validaLimiteTamanho(pr_numero       => CECRED.gene0002.fn_char_para_number(vr_retorno)
                                , pr_tamanho    => pr_qtdnum_MAX
                                , pr_nmcampo    => NVL(pr_desc_atributo, pr_atributo) );
            
          END IF;
          
      ELSIF vr_tpdado =  'MAIL' THEN
        
        IF CECRED.gene0003.fn_valida_email(pr_dsdemail => vr_retorno) = 0 THEN
          vr_tipodado    := 'E-mail';
          vr_erro_valida := TRUE;
        END IF;
        
      END IF;
      
    END IF;
    
    IF vr_erro_valida THEN
      vr_dscritic := 'Tipo de dados incorretos. Esperado (' || vr_tipodado || ') e recebido (' 
                     || vr_retorno || ') no campo (' || NVL(pr_desc_atributo, pr_atributo) || ') '
                     || 'do grupo (' || vr_nmdogrupo || ')';
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_tpdado = 'NUM' AND LENGTH(TRIM(TRANSLATE(vr_retorno, ' +-.0123456789', ' '))) IS NULL THEN
      
      IF CECRED.gene0002.fn_char_para_number(vr_retorno) >= 0 THEN
        
         RETURN( vr_retorno );
      
      ELSE
        
        IF pr_obrigatorio THEN
          
          vr_erro_valida := TRUE;
          
        END IF;
        
      END IF;
      
    END IF;
    
    IF vr_tpdado <> 'NUM' AND LENGTH(vr_retorno) >= 1 THEN
      
      IF  NVL(pr_qtdchar_MAX, 0) > 0 AND LENGTH(vr_retorno) > pr_qtdchar_MAX THEN 
        
        vr_dscritic := 'Foi informado o campo ('|| NVL(pr_desc_atributo, pr_atributo) || ') com uma quantidade '
                       || 'de caracteres acima do permitido pelo sistema. Preencha a informação '
                       || 'do ('|| NVL(pr_desc_atributo, pr_atributo) || ') com no máximo (' || pr_qtdchar_MAX || ') caracteres.';
         
        RAISE vr_exc_erro;
        
      ELSIF NVL(pr_qtdchar, 0) > 0 AND LENGTH(vr_retorno) <> pr_qtdchar THEN
        
        vr_dscritic := 'Quantidade de caracteres incorreta para o campo (' 
                       || NVL(pr_desc_atributo, pr_atributo) || '). Esperado: ' || pr_qtdchar || ' e recebido: ' 
                       ||  LENGTH(vr_retorno) || '. Conteúdo: (' || vr_retorno || ')';
        RAISE vr_exc_erro;
        
      ELSE 
         RETURN(vr_retorno);
      END IF;
      
    ELSIF vr_tpdado <> 'NUM' THEN
      IF pr_obrigatorio THEN
        
        vr_erro_valida := TRUE;
        
      END IF;
    END IF;
    
    IF vr_erro_valida THEN
      
      IF NVL( LENGTH( TRIM(vr_retorno) ), 0 ) = 0 THEN
        vr_dscritic := 'O campo (' || NVL(pr_desc_atributo, pr_atributo) || ') do grupo (' || vr_nmdogrupo || ') é obrigatório.';
      ELSE
        vr_dscritic := 'O valor (' || vr_retorno || ') é incorreto para o campo (' || NVL(pr_desc_atributo, pr_atributo) || ') ';
      END IF;
      
      RAISE vr_exc_erro;
      
    END IF;
    
    RETURN(vr_retorno);
    
  END getValor;

BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'Rollback das informacoes'||chr(13), FALSE);

  vr_dsdireto := GENE0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto := vr_dsdireto||'cpd/bacas/RISCO/GRUPO'; 
  vr_nmarqbkp := 'ROLLBACK_GRUPOS_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  vr_nmarquiv := 'upd_grupo_1.json';

  BEGIN
    vr_arquivo_clob := gene0002.fn_arq_para_clob(vr_nmdireto, vr_nmarquiv);
  EXCEPTION
    WHEN OTHERS THEN
      vr_dscritic := 'Erro ao converter o JSON em CLOB '||SQLERRM;
      RAISE vr_exc_erro;
  END;
  
  BEGIN
    vr_jsonroot := pljson(vr_arquivo_clob);
  EXCEPTION
    WHEN no_data_found THEN
      vr_dscritic := 'O arquivo ' || vr_nmdireto || vr_nmarquiv || ' esta vazio ou em formato incorreto.';
      RAISE vr_exc_erro;
  END;
  
  vr_dhrecebi := SYSDATE;
  
  vr_jsongrupos := getListaJson(pr_json       => vr_jsonroot
                                ,pr_busca      => 'root'
                                ,pr_msgretorno => 'Dados para manutencao de grupo economico enviados incorretamente.');
  
  IF vr_jsongrupos.count > 0 THEN
    FOR j IN 1..vr_jsongrupos.count() LOOP
      vr_jsongrupo := getObjetoJson(pr_json       => vr_jsongrupos
                                   ,pr_busca      => TO_CHAR(j)
                                   ,pr_msgretorno => 'Não foram encontrados dados do grupo.');
      vr_jsonrootgrp := getObjetoJsonJs(pr_json       => vr_jsongrupo
                                       ,pr_busca      => 'GrupoEconomico'
                                       ,pr_msgretorno => 'Dados para manutencao de grupo economico enviados incorretamente.');
      vr_nmdogrupo := 'Dados do grupo';
      vr_idgrupo_economico := getValor('Grupo', vr_jsonrootgrp , TRUE, 'NUM', NULL, NULL, 10, 'Código do grupo');
      vr_cdcooper := getValor('Cooperativa', vr_jsonrootgrp , TRUE, 'NUM', NULL, NULL, 10, 'Código da cooperativa');
      
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                            ,pr_cdprograma    => 'carregarGrupoEconomico' 
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_tpexecucao    => 0
                            ,pr_tpocorrencia  => 4
                            ,pr_dsmensagem    => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - Importacao Iniciada - Grupo economico: ' || vr_idgrupo_economico) 
                            ,pr_idprglog      => vr_idprglog); 
      
      vr_integrantes := getListaJson(pr_json       => vr_jsonrootgrp
                                    ,pr_busca      => 'Integrantes'
                                    ,pr_msgretorno => 'Dados dos integrantes enviados incorretamente.');
      
      
      FOR rw_rollback IN cr_rollback(pr_idgrupo_economico =>vr_idgrupo_economico) LOOP
        gene0002.pc_escreve_xml(vr_dados_rollback
                               ,vr_texto_rollback
                               ,'INSERT INTO GESTAODERISCO.tbrisco_grupo_economico_integrante(cdgrupo_economico, cdcooper, nrdconta, nrcpfcnpj, dhregistro, dtinclusao)'||
                                ' VALUES ('||rw_rollback.cdgrupo_economico ||
                                ', '||rw_rollback.cdcooper||', '||rw_rollback.nrdconta||', '||rw_rollback.nrcpfcnpj||', sysdate, '''||rw_rollback.dtinclusao||''');'
                                ||chr(13)||chr(13), FALSE); 
      END LOOP;
      
      IF vr_integrantes.count() <= 0 THEN
        OPEN cr_grupo_economico(pr_idgrupo_economico => vr_idgrupo_economico);
        FETCH cr_grupo_economico INTO rw_grupo_economico;
        IF cr_grupo_economico%FOUND THEN
          BEGIN 
            DELETE FROM GESTAODERISCO.tbrisco_grupo_economico_integrante WHERE cdgrupo_economico = vr_idgrupo_economico;
          EXCEPTION
            WHEN OTHERS THEN
              CLOSE cr_grupo_economico;
              vr_dscritic := 'Erro ao excluir grupo economico: ' || vr_idgrupo_economico || ' - ' || SQLERRM;
              RAISE vr_exc_erro;
          END;
        END IF;
        CLOSE cr_grupo_economico;
      ELSE
        vr_nmdogrupo := 'Dados do integrante';
        
        BEGIN 
          DELETE FROM GESTAODERISCO.tbrisco_grupo_economico_integrante WHERE cdgrupo_economico = vr_idgrupo_economico;
        EXCEPTION
          WHEN OTHERS THEN
            CLOSE cr_grupo_economico;
            vr_dscritic := 'Erro ao preparar atualizacao do grupo economico: ' || vr_idgrupo_economico || ' - ' || SQLERRM;
            RAISE vr_exc_erro;
        END;
        
        FOR i IN 1..vr_integrantes.count() LOOP
          vr_integrante := getObjetoJson(pr_json       => vr_integrantes
                                        ,pr_busca      => TO_CHAR(i)
                                        ,pr_msgretorno => 'Não foram encontrados dados do integrante.');

          vr_nrcpfcgc := getValor('Documento', vr_integrante , TRUE, 'NUM', NULL, NULL, 15, 'Documento');
          vr_dtinclus := to_date(getValor('DataInclusao', vr_integrante, TRUE, 'DATA', NULL, NULL, NULL, 'Data de Inclusao'),'DD/MM/RRRR');
          
          OPEN cr_crapass(pr_cdcooper => vr_cdcooper
                         ,pr_nrcpfcgc => vr_nrcpfcgc);
          FETCH cr_crapass INTO rw_crapass;
          IF cr_crapass%NOTFOUND THEN
            vr_flgcontas := FALSE;
            
            BEGIN 
              INSERT INTO GESTAODERISCO.tbrisco_grupo_economico_integrante(cdgrupo_economico, cdcooper, nrdconta, nrcpfcnpj, dhregistro, dtinclusao)
              VALUES (vr_idgrupo_economico, vr_cdcooper, NULL, vr_nrcpfcgc, vr_dhrecebi, vr_dtinclus);
            EXCEPTION
              WHEN OTHERS THEN
                CLOSE cr_grupo_economico;
                vr_dscritic := 'Erro ao atualizar grupo economico: ' || vr_idgrupo_economico || ' - ' || SQLERRM;
                RAISE vr_exc_erro;
            END;
            CECRED.pc_log_programa(pr_dstiplog     => 'O'
                                  ,pr_cdprograma   => 'carregarGrupoEconomico' 
                                  ,pr_cdcooper     => vr_cdcooper
                                  ,pr_tpexecucao   => 0
                                  ,pr_tpocorrencia => 4 
                                  ,pr_dsmensagem   => TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - Documento Importado não existe no Aimaro - ' ||
                                                      'Grupo economico: ' || vr_idgrupo_economico || ' - ' ||
                                                      'Documento: '       || vr_nrcpfcgc
                                  ,pr_idprglog     => vr_idprglog);   
          ELSE
            vr_flgcontas := TRUE;
          END IF;
          CLOSE cr_crapass;

          IF vr_flgcontas THEN
            FOR rw_crapass IN cr_crapass(pr_cdcooper => vr_cdcooper
                                        ,pr_nrcpfcgc => vr_nrcpfcgc) LOOP
              BEGIN 
                INSERT INTO GESTAODERISCO.tbrisco_grupo_economico_integrante(cdgrupo_economico, cdcooper, nrdconta, nrcpfcnpj, dhregistro, dtinclusao)
                VALUES (vr_idgrupo_economico, vr_cdcooper, rw_crapass.nrdconta, vr_nrcpfcgc, vr_dhrecebi, vr_dtinclus);
              EXCEPTION
                WHEN OTHERS THEN
                  CLOSE cr_grupo_economico;
                  vr_dscritic := 'Erro ao atualizar grupo economico: ' || vr_idgrupo_economico || ' - ' || SQLERRM;
                  RAISE vr_exc_erro;
              END;
            END LOOP;
          END IF;
          
        END LOOP;
      END IF;
      CECRED.pc_log_programa(pr_dstiplog      => 'O'
                            ,pr_cdprograma    => 'carregarGrupoEconomico' 
                            ,pr_cdcooper      => vr_cdcooper
                            ,pr_tpexecucao    => 0
                            ,pr_tpocorrencia  => 4
                            ,pr_dsmensagem    => (TO_CHAR(SYSDATE,'DD/MM/RRRR HH24:MI:SS') || ' - Importacao Finalizada - Grupo economico: ' || vr_idgrupo_economico) 
                            ,pr_idprglog      => vr_idprglog); 
    END LOOP;
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
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
  
  COMMIT;
EXCEPTION
  WHEN vr_exc_erro THEN
    raise_application_error(-20000, SQLERRM || vr_dscritic);  
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM || vr_dscritic || dbms_utility.format_error_backtrace);
END;
