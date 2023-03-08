BEGIN

  DECLARE
  
    pr_cdcooper crapcop.cdcooper%TYPE := 3;
      
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS675';
    vr_dsdireto       VARCHAR2(2000);
    vr_direto_connect VARCHAR2(200);
    vr_nmrquivo       VARCHAR2(2000);
    vr_dsheader       VARCHAR2(2000);
    vr_dsdetarq       VARCHAR2(2000) := 0;
    vr_dstraile       VARCHAR2(2000);
    vr_comando        VARCHAR2(2000);
    vr_vlrtotdb       craplcm.vllanmto%TYPE := 0;
    vr_contador       PLS_INTEGER := 0;
    vr_ind_arquiv     utl_file.file_type;
    vr_nrseqarq       crapscb.nrseqarq%TYPE;
    
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    pr_cdcritic PLS_INTEGER;
    pr_dscritic VARCHAR2(4000);
  
    vr_nomdojob CONSTANT VARCHAR2(100) := 'jbcrd_bancoob_envia_deb_fat';
    vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  
    vr_dscomando VARCHAR2(4000);

    vr_typ_saida VARCHAR2(4000);
  
    vr_index PLS_INTEGER;
    vr_linha PLS_INTEGER;
  
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.cdagebcb
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
  
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
    vr_dtrefere crapdat.dtmvtolt%TYPE;
    vr_dtrefuti DATE;
  
    vr_tab_split_dias gene0002.typ_split;
    vr_idx_dia        NUMBER;
    vr_email_enviado  BOOLEAN := FALSE;
  
    CURSOR cr_dias_debito IS
      SELECT DISTINCT dsdias_debito dias
        FROM tbcrd_config_categoria con
            ,crapcop                cop
       WHERE con.cdcooper = cop.cdcooper
         AND cop.flgativo = 1
         AND con.cdcooper <> 3;
  
    CURSOR cr_pagamento_fatura(pr_dtpagamento IN tbcrd_pagamento_fatura.dtpagamento%TYPE) IS
      SELECT pag.vlpagamento
            ,pag.idfatura
            ,pag.rowid pagrowid
        FROM tbcrd_pagamento_fatura pag
       WHERE pag.dtpagamento = pr_dtpagamento
         AND pag.inenvarq = 0
         AND pag.vlpagamento > 0;
  
    CURSOR cr_fatura(pr_idfatura IN tbcrd_fatura.idfatura%TYPE) IS
      SELECT fat.nrconta_cartao
            ,ass.nrcpfcgc
            ,fat.nrdconta
        FROM tbcrd_fatura fat
       INNER JOIN crapass ass
          ON fat.cdcooper = ass.cdcooper
         AND fat.nrdconta = ass.nrdconta
       WHERE fat.idfatura = pr_idfatura;
    rw_fatura cr_fatura%ROWTYPE;
  
    TYPE typ_tab_linhas_totalizadas IS TABLE OF cr_pagamento_fatura%ROWTYPE INDEX BY PLS_INTEGER;
    vr_linhas_totalizadas typ_tab_linhas_totalizadas;
  
    TYPE typ_reg_pagamento_fatura IS RECORD(
      vlpagamento tbcrd_pagamento_fatura.vlpagamento%TYPE);
    TYPE typ_tab_pagamento_fatura IS TABLE OF typ_reg_pagamento_fatura INDEX BY PLS_INTEGER;
    vr_pagamento_fatura typ_tab_pagamento_fatura;
  
    CURSOR cr_crapscb IS
      SELECT crapscb.dsdirarq
            ,crapscb.nrseqarq
        FROM crapscb
       WHERE crapscb.tparquiv = 8;
    rw_crapscb cr_crapscb%ROWTYPE;
  
  BEGIN
  
    cecred.pc_log_programa(PR_DSTIPLOG   => 'I'
                          ,PR_CDPROGRAMA => vr_nomdojob
                          ,pr_tpexecucao => 2
                          ,PR_IDPRGLOG   => vr_idprglog);
  
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra, pr_action => NULL);
  
    OPEN cr_crapcop;
    FETCH cr_crapcop
      INTO rw_crapcop;
  
    IF cr_crapcop%NOTFOUND THEN

      CLOSE cr_crapcop;

      vr_cdcritic := 651;
      RAISE vr_exc_saida;
    ELSE

      CLOSE cr_crapcop;
    END IF;
  
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
      INTO rw_crapdat;
  
    IF btch0001.cr_crapdat%NOTFOUND THEN
      
      CLOSE btch0001.cr_crapdat;
      
      vr_cdcritic := 1;
      RAISE vr_exc_saida;
    ELSE
      
      CLOSE btch0001.cr_crapdat;
    END IF;
  
    vr_dtrefere := rw_crapdat.dtmvtoan;

    OPEN cr_crapscb;
    FETCH cr_crapscb
      INTO rw_crapscb;
    IF cr_crapscb%NOTFOUND THEN
      vr_dscritic := 'Registro crapscb não encontrado!';
      CLOSE cr_crapscb;

      RAISE vr_exc_saida;
    END IF;
    CLOSE cr_crapscb;
  
    vr_nrseqarq := NVL(rw_crapscb.nrseqarq, 0) + 1;
  
    vr_dsdireto       := rw_crapscb.dsdirarq;
    vr_direto_connect := vr_dsdireto;
  
    vr_nmrquivo := 'DAUR756.' || TO_CHAR(lpad(rw_crapcop.cdagebcb, 4, '0')) || '.' ||
                   TO_CHAR(vr_dtrefere, 'YYYYMMDD') || '.' || TO_CHAR(SYSDATE, 'HH24MISS') ||
                   '.CCB';
  
    gene0001.pc_abre_arquivo(pr_nmdireto => vr_direto_connect
                            ,pr_nmarquiv => 'TMP_' || vr_nmrquivo 
                            ,pr_tipabert => 'W'
                            ,pr_utlfileh => vr_ind_arquiv
                            ,pr_des_erro => vr_dscritic); 
							
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
  
    vr_linha := 0;

    FOR rw_pagamento_fatura IN cr_pagamento_fatura(pr_dtpagamento => vr_dtrefere) LOOP

      IF NOT vr_pagamento_fatura.EXISTS(rw_pagamento_fatura.idfatura) THEN
        vr_pagamento_fatura(rw_pagamento_fatura.idfatura).vlpagamento := 0;
      END IF;
      vr_pagamento_fatura(rw_pagamento_fatura.idfatura).vlpagamento := vr_pagamento_fatura(rw_pagamento_fatura.idfatura).vlpagamento +
                                                                        rw_pagamento_fatura.vlpagamento;

      vr_linha := vr_linha + 1;
      vr_linhas_totalizadas(vr_linha) := rw_pagamento_fatura;
    END LOOP;
  
    vr_contador := 1;
  
    vr_dsheader := 'DAUR' || '0' || '756' || TO_CHAR(lpad(rw_crapcop.cdagebcb, 4, '0')) ||
                   TO_CHAR(vr_dtrefere, 'DDMMYYYY') || lpad(vr_nrseqarq, 6, '0') || 
                   lpad(nvl(vr_contador, 0), 6, '0');
  
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsheader);
  
    vr_index := vr_pagamento_fatura.first;
    LOOP
      EXIT WHEN vr_index IS NULL;
      OPEN cr_fatura(pr_idfatura => vr_index);
      FETCH cr_fatura
        INTO rw_fatura;
      IF cr_fatura%FOUND THEN

        vr_contador := vr_contador + 1;
        
        vr_dsdetarq := ('DAUR'
                       || '1'
                       || lpad(rw_fatura.nrconta_cartao, 13, '0')
                       || lpad(nvl(rw_fatura.nrcpfcgc, 0), 11, '0') 
                       || '0000000' 
                       || lpad(rw_fatura.nrdconta, 12, '0') 
                       || '000000000' 
                       || '000000000000' 
                       || lpad(nvl((vr_pagamento_fatura(vr_index).vlpagamento * 100), 0), 12, '0') 
                       || TO_CHAR(vr_dtrefere, 'DDMMYYYY') 
                       || lpad(vr_contador, 6, '0') 
                       );
					   
        gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dsdetarq);

        vr_vlrtotdb := vr_vlrtotdb + vr_pagamento_fatura(vr_index).vlpagamento;
        
      END IF;
      
      CLOSE cr_fatura;
      
      vr_index := vr_pagamento_fatura.next(vr_index);
    END LOOP;
  
    
    vr_contador := vr_contador + 1;
  
    vr_dstraile := ('DAUR' 
                   || '9' 
                   || lpad('0', 16, '0') 
                   || lpad(nvl((vr_vlrtotdb * 100), 0), 16, '0') 
                   || lpad(nvl(vr_contador, 0), 6, '0') 
                   );
  
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, vr_dstraile);
  
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv);
  
    IF vr_contador <= 2 THEN
    
      vr_comando := 'rm ' || vr_direto_connect || '/TMP_' || vr_nmrquivo || ' 2> /dev/null';

      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
    
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_saida;
      END IF;
    
      vr_dscritic := 'Nenhum movimento encontrado para a data.';
      RAISE vr_exc_fimprg;
    END IF;
  
    vr_dscomando := 'ux2dos ' || vr_direto_connect || '/TMP_' || vr_nmrquivo || ' > ' ||
                    vr_direto_connect || '/envia/' || vr_nmrquivo || ' 2>/dev/null';
  
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
  
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_saida;
    END IF;
  
    vr_dscomando := 'rm ' || vr_direto_connect || '/TMP_' || vr_nmrquivo;
  
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomando
                         ,pr_typ_saida   => vr_typ_saida
                         ,pr_des_saida   => vr_dscritic);
  
    IF vr_typ_saida = 'ERR' THEN
      RAISE vr_exc_saida;
    END IF;
  
    BEGIN
      UPDATE crapscb
         SET nrseqarq = vr_nrseqarq
            ,dtultint = SYSDATE
       WHERE crapscb.tparquiv = 8; 
    
    EXCEPTION
      WHEN OTHERS THEN
        cecred.pc_internal_exception;

        vr_dscritic := 'Problema ao atualizar registro na tabela CRAPSCB: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
  
    BEGIN
      FORALL idx IN 1 .. vr_linhas_totalizadas.COUNT SAVE EXCEPTIONS
        UPDATE tbcrd_pagamento_fatura pag
           SET pag.inenvarq = 1
         WHERE ROWID = vr_linhas_totalizadas(idx).pagrowid;
    EXCEPTION
      WHEN OTHERS THEN
                
        FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          cecred.pc_log_programa(PR_DSTIPLOG => 'E'
                                ,PR_CDPROGRAMA => vr_cdprogra
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_dsmensagem => 'tbcrd_pagamento_fatura -' || 
                                                  ' pagrowid: ' || vr_linhas_totalizadas(SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX).pagrowid ||
                                                  ' Oracle error: ' || SQLERRM(-1 * SQL%BULK_EXCEPTIONS(indx).ERROR_CODE)
                                ,PR_IDPRGLOG => vr_idprglog);
        END LOOP;
      
        FOR idx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          pc_internal_exception(pr_compleme => 'CRPS675_FORALL vr_linhas_totalizadas - ' || SQL%BULK_EXCEPTIONS(idx).ERROR_INDEX || ': ' || SQL%BULK_EXCEPTIONS(idx).ERROR_CODE);
        END LOOP;
    END;
  
    COMMIT;
  
    cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                          ,PR_CDPROGRAMA => vr_nomdojob
                          ,PR_IDPRGLOG   => vr_idprglog);
  
  EXCEPTION
    WHEN vr_exc_fimprg THEN
    
      cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                            ,PR_CDPROGRAMA => vr_nomdojob
                            ,PR_IDPRGLOG   => vr_idprglog);
    
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
    
      IF vr_dscritic IS NOT NULL THEN

        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 
                                  ,pr_des_log      => to_char(SYSDATE, 'hh24:mi:ss') || ' - ' ||
                                                      vr_nomdojob || ' --> ' || vr_dscritic);
      END IF;
    
      IF gene0001.fn_param_sistema('CRED', 0, 'DAUT_MONITORAMENTO') = 1 THEN
        
        FOR rw_dias_debito IN cr_dias_debito LOOP
          
          IF vr_email_enviado THEN
            EXIT;
          END IF;
          
          vr_tab_split_dias := gene0002.fn_quebra_string(rw_dias_debito.dias, ',');
          vr_idx_dia        := vr_tab_split_dias.FIRST;
          
          WHILE vr_idx_dia IS NOT NULL LOOP
            
            vr_dtrefuti := gene0005.fn_valida_dia_util(pr_cdcooper => 3
                                                      ,pr_dtmvtolt => TO_DATE(vr_tab_split_dias(vr_idx_dia) ||
                                                                              TO_CHAR(vr_dtrefere
                                                                                     ,'/MM/RRRR')
                                                                             ,'DD/MM/RRRR'));
            IF vr_dtrefere = vr_dtrefuti
               OR vr_dtrefere =
               gene0005.fn_valida_dia_util(pr_cdcooper => 3 
                                             ,pr_dtmvtolt => vr_dtrefuti + 1) THEN
              gene0003.pc_solicita_email(pr_cdprogra    => vr_nomdojob
                                        ,pr_des_destino => gene0001.fn_param_sistema('CRED'
                                                                                    ,0
                                                                                    ,'CRD_MONITORAMENTO')
                                        ,pr_des_assunto => 'Monitoramento DAUR'
                                        ,pr_des_corpo   => 'Processamento do arquivo DAUR nao ocorreu. Programa ' ||
                                                           vr_nomdojob || '. ' || vr_dscritic
                                        ,pr_des_anexo   => NULL
                                        ,pr_flg_enviar  => 'S'
                                        ,pr_des_erro    => pr_dscritic);
              vr_email_enviado := TRUE;
              EXIT;
            END IF;
            vr_idx_dia := vr_tab_split_dias.NEXT(vr_idx_dia);
          END LOOP;
        END LOOP;
      END IF;
    
      COMMIT;
    
    WHEN vr_exc_saida THEN
    
      pr_cdcritic := NVL(vr_cdcritic, 0);
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      
      ROLLBACK;
    
      cecred.pc_log_programa(PR_DSTIPLOG      => 'E'
                            ,PR_CDPROGRAMA    => vr_nomdojob
                            ,pr_cdcriticidade => 2
                            ,pr_dsmensagem    => pr_dscritic
                            ,pr_flgsucesso    => 0
                            ,pr_tpocorrencia  => 1
                            , 
                             pr_tpexecucao    => 1
                            , 
                             PR_IDPRGLOG      => vr_idprglog);
    
      cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                            ,PR_CDPROGRAMA => vr_nomdojob
                            ,pr_flgsucesso => 0
                            ,PR_IDPRGLOG   => vr_idprglog);
    
      IF gene0001.fn_param_sistema('CRED', 0, 'DAUT_MONITORAMENTO') = 1 THEN
        
        gene0003.pc_solicita_email(pr_cdprogra    => vr_nomdojob
                                  ,pr_des_destino => gene0001.fn_param_sistema('CRED'
                                                                              ,0
                                                                              ,'CRD_MONITORAMENTO')
                                  ,pr_des_assunto => 'Monitoramento DAUR'
                                  ,pr_des_corpo   => 'Erro de negocio no processamento do arquivo DAUR. Programa ' ||
                                                     vr_nomdojob || '. ' || pr_dscritic
                                  ,pr_des_anexo   => NULL
                                  ,pr_flg_enviar  => 'S'
                                  ,pr_des_erro    => pr_dscritic);
      END IF;
    
    WHEN OTHERS THEN
    
      cecred.pc_internal_exception(3);
    
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
      
      ROLLBACK;
    
      cecred.pc_log_programa(PR_DSTIPLOG           => 'E'
                            ,PR_CDPROGRAMA         => vr_nomdojob
                            ,pr_cdcriticidade      => 2
                            ,pr_dsmensagem         => pr_dscritic
                            ,pr_flgsucesso         => 0
                            ,pr_tpocorrencia       => 2
                            , 
                             pr_tpexecucao         => 1
                            , 
                             pr_flabrechamado      => 1
                            , 
                             pr_texto_chamado      => ' Verificar execução do job ' || vr_nomdojob ||
                                                      ': Gerar arquivo de retorno de Débito em conta das faturas (Bancoob/CABAL). '
                            ,pr_destinatario_email => gene0001.fn_param_sistema('CRED'
                                                                               ,pr_cdcooper
                                                                               ,'CRD_RESPONSAVEL')
                            ,pr_flreincidente      => 1
                            , 
                             PR_IDPRGLOG           => vr_idprglog);
    
      cecred.pc_log_programa(PR_DSTIPLOG   => 'F'
                            ,PR_CDPROGRAMA => vr_nomdojob
                            ,pr_flgsucesso => 0
                            ,PR_IDPRGLOG   => vr_idprglog);
    
      IF gene0001.fn_param_sistema('CRED', 0, 'DAUT_MONITORAMENTO') = 1 THEN

        gene0003.pc_solicita_email(pr_cdprogra    => vr_nomdojob
                                  ,pr_des_destino => gene0001.fn_param_sistema('CRED'
                                                                              ,0
                                                                              ,'CRD_MONITORAMENTO')
                                  ,pr_des_assunto => 'Monitoramento DAUR'
                                  ,pr_des_corpo   => 'Erro nao previso no processamento do arquivo DAUR. Programa ' ||
                                                     vr_nomdojob || '. ' || pr_dscritic
                                  ,pr_des_anexo   => NULL
                                  ,pr_flg_enviar  => 'S'
                                  ,pr_des_erro    => pr_dscritic);
      END IF;
  END;
   commit;
END;
