PL/SQL Developer Test script 3.0
287
-- Created on 19/07/2021 by T0032717 
DECLARE 
  CURSOR cr_principal IS
    SELECT * 
      FROM crawepr 
     WHERE cdcooper = 1
       AND nrdconta IN (10757414,  6854354, 11127538,   837172, 9304908, 11497394, 10755772,  6874584,  9277277,  8500231, 
                         9230599,  9775722,  6666434,  9304908, 7255438,  6444300, 10400729, 11337222, 10250751, 11136189, 
                        12681849, 11146508, 13037188, 11591960, 3232808,  9304908,   837172,  8535418, 12606022, 12077402, 
                         6666434,  6666434,  9961267,  8423679, 9230599,  9900020, 10147683,  9727469, 11490195, 11490195, 
                         9230599, 11794658, 11359684, 12569089, 6270395,  6666434,  8952400,  9508899, 12917893,   837172, 
                        10423281, 10742654,  3109518,  9794808)
       AND nrctremp IN (4231334, 4231362, 4231465, 4231540, 4231478, 4231480, 4231743, 4231306, 4231311, 4231314, 4231318, 
                        4231332, 4231373, 4231453, 4231552, 4231396, 4231495, 4231585, 4231619, 4231655, 4231612, 4231677, 
                        4231506, 4231304, 4231420, 4231471, 4231545, 4231573, 4231695, 4231749, 4231376, 4231378, 4231400, 
                        4231502, 4231313, 4231489, 4231590, 4231696, 4231526, 4231541, 4231317, 4231320, 4231324, 4231327, 
                        4231330, 4231381, 4231408, 4231718, 4231473, 4231533, 4231307, 4231326, 4231653, 4231623);
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_simula(pr_cdcooper IN crapcop.cdcooper%TYPE
                  ,pr_nrdconta IN crapass.nrdconta%TYPE
                  ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT *
      FROM credito.tbepr_renegociacao_simula s
     WHERE s.cdcooper = pr_cdcooper
       AND s.nrdconta = pr_nrdconta 
       AND s.nrctremp = pr_nrctremp;
  rw_simula cr_simula%ROWTYPE;  
  
  CURSOR cr_tbepr_renegociacao(pr_cdcooper IN tbepr_renegociacao_contrato.cdcooper%TYPE
                              ,pr_nrdconta IN tbepr_renegociacao_contrato.nrdconta%TYPE
                              ,pr_nrctremp IN tbepr_renegociacao_contrato.nrctremp%TYPE) IS
    SELECT * 
      FROM tbepr_renegociacao
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  rw_tbepr_renegociacao cr_tbepr_renegociacao%ROWTYPE;
  
  CURSOR cr_tbepr_renegociacao_contrato(pr_cdcooper IN tbepr_renegociacao_contrato.cdcooper%TYPE
                                       ,pr_nrdconta IN tbepr_renegociacao_contrato.nrdconta%TYPE
                                       ,pr_nrctremp IN tbepr_renegociacao_contrato.nrctremp%TYPE) IS
    SELECT * 
      FROM tbepr_renegociacao_contrato
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp;
  rw_tbepr_renegociacao_contrato cr_tbepr_renegociacao_contrato%ROWTYPE;
  
  vr_cdcritic  PLS_INTEGER;
  vr_dscritic  VARCHAR2(4000);
  vr_exc_erro  EXCEPTION;
  vr_retxml    XMLType;
  --
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  -- inserts
  vr_insert1   VARCHAR2(1000);
  vr_insert2   VARCHAR2(1000);
  vr_values    VARCHAR2(4000);
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0098265'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0098265_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => 1);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  FOR rw_principal IN cr_principal LOOP
    --
    OPEN cr_tbepr_renegociacao(pr_cdcooper => rw_principal.cdcooper
                              ,pr_nrdconta => rw_principal.nrdconta
                              ,pr_nrctremp => rw_principal.nrctremp);
    FETCH cr_tbepr_renegociacao INTO rw_tbepr_renegociacao;
    CLOSE cr_tbepr_renegociacao;
    -- grava rollback
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'INSERT INTO tbepr_renegociacao (CDCOOPER, NRDCONTA, NRCTREMP, FLGDOCJE, IDFINIOF, DTDPAGTO, QTPREEMP, VLEMPRST, VLPREEMP, DTLIBERA, IDFINTAR)
                             VALUES (' || rw_tbepr_renegociacao.CDCOOPER || ', 
                                     ' || rw_tbepr_renegociacao.NRDCONTA || ', 
                                     ' || rw_tbepr_renegociacao.NRCTREMP || ', 
                                     ' || rw_tbepr_renegociacao.FLGDOCJE || ', 
                                     ' || rw_tbepr_renegociacao.IDFINIOF || ', 
                           to_date(''' || rw_tbepr_renegociacao.DTDPAGTO || ''', ''dd-mm-yyyy''), 
                                     ' || rw_tbepr_renegociacao.QTPREEMP || ', 
                                     ' || REPLACE(rw_tbepr_renegociacao.VLEMPRST, ',', '.') || ', 
                                     ' || REPLACE(rw_tbepr_renegociacao.VLPREEMP, ',', '.') || ', 
                           to_date(''' || rw_tbepr_renegociacao.DTLIBERA || ''', ''dd-mm-yyyy''), 
                                     ' || rw_tbepr_renegociacao.IDFINTAR || ');' ||chr(13)||chr(13), FALSE); 
    
    OPEN cr_simula(pr_cdcooper => rw_principal.cdcooper
                  ,pr_nrdconta => rw_principal.nrdconta
                  ,pr_nrctremp => rw_principal.nrctremp);
    FETCH cr_simula INTO rw_simula;
    CLOSE cr_simula;
    -- grava rollback
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'INSERT INTO credito.tbepr_renegociacao_simula (IDSIMULA, CDCOOPER, NRDCONTA, NRCTREMP, FLGDOCJE, IDFINIOF, DTDPAGTO, QTPREEMP, VLEMPRST, VLPREEMP, DTLIBERA, IDFINTAR, idpessoa, nrseq_telefone, nrseq_email, idorigem, dtsimula, dtvalsim, idprphib)
                             VALUES (' || rw_simula.IDSIMULA || ', 
                                     ' || rw_simula.CDCOOPER || ', 
                                     ' || rw_simula.NRDCONTA || ', 
                                     ' || rw_simula.NRCTREMP || ', 
                                     ' || rw_simula.FLGDOCJE || ', 
                                     ' || rw_simula.IDFINIOF || ', 
                           to_date(''' || rw_simula.DTDPAGTO || ''', ''dd-mm-yyyy''), 
                                     ' || rw_simula.QTPREEMP || ', 
                                     ' || REPLACE(rw_simula.VLEMPRST, ',', '.') || ', 
                                     ' || REPLACE(rw_simula.VLPREEMP, ',', '.') || ', 
                           to_date(''' || rw_simula.DTLIBERA || ''', ''dd-mm-yyyy''), 
                                     ' || rw_simula.IDFINTAR || ', 
                                     ' || rw_simula.idpessoa || ', 
                                     ' || rw_simula.nrseq_telefone || ', 
                                     ' || rw_simula.nrseq_email || ', 
                                     ' || rw_simula.idorigem || ', 
                           to_date(''' || rw_simula.dtsimula || ''', ''dd-mm-yyyy''), 
                           to_date(''' || rw_simula.dtvalsim || ''', ''dd-mm-yyyy''), 
                                     ' || rw_simula.idprphib || ');' ||chr(13)||chr(13), FALSE); 
    
    FOR rw_tbepr_renegociacao_contrato IN cr_tbepr_renegociacao_contrato(pr_cdcooper => rw_principal.cdcooper
                                                                        ,pr_nrdconta => rw_principal.nrdconta
                                                                        ,pr_nrctremp => rw_principal.nrctremp) LOOP
      vr_insert1 := 'INSERT INTO tbepr_renegociacao_contrato (CDCOOPER, NRDCONTA, NRCTREMP, NRCTREPR, NRVERSAO, VLSDEVED, VLNVSDDE, VLNVPRES, TPEMPRST, NRCTROTR, CDFINEMP, CDLCREMP, DTDPAGTO, IDCARENC, DTCARENC, VLPRECAR, VLIOFEPR, VLTAREPR, IDQUALOP, NRDIAATR, CDLCREMP_ORIGEM, CDFINEMP_ORIGEM, VLEMPRST, VLFINANC, VLIOFADC, VLIOFPRI, PERCETOP, FLGIMUNE, TPCONTRATO_LIQUIDADO, INCANCELAR_PRODUTO, NRCTREMP_NOVO)';
      vr_insert2 := 'INSERT INTO credito.tbepr_renegociacao_contrato_simula (CDCOOPER, NRDCONTA, NRCTREMP, NRCTREPR, NRVERSAO, VLSDEVED, VLNVSDDE, VLNVPRES, TPEMPRST, NRCTROTR, CDFINEMP, CDLCREMP, DTDPAGTO, IDCARENC, DTCARENC, VLPRECAR, VLIOFEPR, VLTAREPR, IDQUALOP, NRDIAATR, CDLCREMP_ORIGEM, CDFINEMP_ORIGEM, VLEMPRST, VLFINANC, VLIOFADC, VLIOFPRI, PERCETOP, FLGIMUNE, TPCONTRATO_LIQUIDADO, INCANCELAR_PRODUTO, NRCTREMP_NOVO)';
      
      vr_values := 'VALUES (' || rw_tbepr_renegociacao_contrato.CDCOOPER || ', 
                                       ' || rw_tbepr_renegociacao_contrato.NRDCONTA || ', 
                                       ' || rw_tbepr_renegociacao_contrato.NRCTREMP || ', 
                                       ' || rw_tbepr_renegociacao_contrato.NRCTREPR || ', 
                                       ' || rw_tbepr_renegociacao_contrato.NRVERSAO || ', 
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLSDEVED, ',', '.') || ',
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLNVSDDE, ',', '.') || ', 
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLNVPRES, ',', '.') || ', 
                                       ' || rw_tbepr_renegociacao_contrato.TPEMPRST || ', 
                                       ' || rw_tbepr_renegociacao_contrato.NRCTROTR || ',
                                       ' || rw_tbepr_renegociacao_contrato.CDFINEMP || ',
                                       ' || rw_tbepr_renegociacao_contrato.CDLCREMP || ', 
                             to_date(''' || rw_tbepr_renegociacao_contrato.DTDPAGTO || ''', ''dd-mm-yyyy''), 
                                       ' || rw_tbepr_renegociacao_contrato.IDCARENC || ', 
                   ' || nvl('to_date(''' || rw_tbepr_renegociacao_contrato.DTCARENC || ''', ''dd-mm-yyyy''),', 'NULL') || '
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLPRECAR, ',', '.') || ', 
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLIOFEPR, ',', '.') || ', 
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLTAREPR, ',', '.') || ', 
                                       ' || rw_tbepr_renegociacao_contrato.IDQUALOP || ',
                                       ' || rw_tbepr_renegociacao_contrato.NRDIAATR || ', 
                                       ' || rw_tbepr_renegociacao_contrato.CDLCREMP_ORIGEM || ', 
                                       ' || rw_tbepr_renegociacao_contrato.CDFINEMP_ORIGEM || ', 
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLEMPRST, ',', '.') || ',
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLFINANC, ',', '.') || ',
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLIOFADC, ',', '.') || ', 
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.VLIOFPRI, ',', '.') || ', 
                                       ' || REPLACE(rw_tbepr_renegociacao_contrato.PERCETOP, ',', '.') || ', 
                                       ' || rw_tbepr_renegociacao_contrato.FLGIMUNE || ', 
                                       ' || rw_tbepr_renegociacao_contrato.TPCONTRATO_LIQUIDADO || ', 
                                       ' || rw_tbepr_renegociacao_contrato.INCANCELAR_PRODUTO || ', 
                                       ' || rw_tbepr_renegociacao_contrato.NRCTREMP_NOVO || ');' ||chr(13)||chr(13);
      
      
      -- grava rollback proposta
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , vr_insert1 || vr_values
                            , FALSE); 
      -- grava rollback simulacao
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , vr_insert2 || vr_values
                            , FALSE); 
    END LOOP;
    BEGIN 
      CREDITO.cancelarSimulacaoRenegociacao(pr_cdcooper => rw_principal.cdcooper,
                                            pr_nrdconta => rw_principal.nrdconta,
                                            pr_idsimula => rw_simula.idsimula,
                                            pr_idorigem => 5,
                                            pr_cdcritic => vr_cdcritic,
                                            pr_dscritic => vr_dscritic,
                                            pr_retxml   => vr_retxml);
      IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        dbms_output.put_line('Erro ao cancelar simulacao da renegociacao: ' || rw_principal.cdcooper || 
                             ' proposta:' || rw_principal.nrctremp || 
                             ' conta: ' || rw_principal.nrdconta || ' - ' || vr_dscritic);
        ROLLBACK;
        CONTINUE;
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao cancelar simulacao da renegociacao: ' || rw_principal.cdcooper || 
                             ' proposta:' || rw_principal.nrctremp || 
                             ' conta: ' || rw_principal.nrdconta || ' - ' || SQLERRM);
        ROLLBACK;
        CONTINUE;
    END;
    BEGIN
      ESTE0001.pc_interrompe_proposta_est(pr_cdcooper => rw_principal.cdcooper,
                                          pr_cdagenci => 1,
                                          pr_cdoperad => 1,
                                          pr_cdorigem => 5,
                                          pr_nrdconta => rw_principal.nrdconta,
                                          pr_nrctremp => rw_principal.nrctremp,
                                          pr_dtmvtolt => rw_crapdat.dtmvtolt,
                                          pr_cdcritic => vr_cdcritic,
                                          pr_dscritic => vr_dscritic);
                                          
      IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        dbms_output.put_line('Erro ao interromper proposta na esteira (simulacao da renegociacao): ' || rw_principal.cdcooper || 
                             ' proposta:' || rw_principal.nrctremp || 
                             ' conta: ' || rw_principal.nrdconta || ' - ' || vr_dscritic);
        ROLLBACK;
        CONTINUE;
      WHEN OTHERS THEN
        dbms_output.put_line('Erro ao interromper proposta na esteira (simulacao da renegociacao): ' || rw_principal.cdcooper || 
                             ' proposta:' || rw_principal.nrctremp || 
                             ' conta: ' || rw_principal.nrdconta || ' - ' || SQLERRM);
        ROLLBACK;
        CONTINUE;
    END;

    -- commit para cada cancelamento
    COMMIT;
    
    dbms_output.put_line('Cancelamento de simulacao da renegociacao com sucesso: ' || rw_principal.cdcooper || 
                         ' proposta:' || rw_principal.nrctremp || 
                         ' conta: ' || rw_principal.nrdconta);
  
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'UPDATE crawepr 
                                SET insitest = 0 
                              WHERE cdcooper = ' || rw_principal.CDCOOPER || ', 
                                AND nrdconta = ' || rw_principal.NRDCONTA || ', 
                                AND nrctremp = ' || rw_principal.NRCTREMP || ';' ||chr(13)||chr(13), FALSE); 
  END LOOP;
  
  -- Adiciona TAG de commit rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  -- Fecha o arquivo rollback
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE); 
             
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3                             --> Cooperativa conectada
                                     ,pr_cdprogra  => 'ATENDA'                      --> Programa chamador - utilizamos apenas um existente 
                                     ,pr_dtmvtolt  => trunc(SYSDATE)                --> Data do movimento atual
                                     ,pr_dsxml     => vr_dados_rollback             --> Arquivo XML de dados
                                     ,pr_dsarqsaid => vr_nmdireto||'/'||vr_nmarqbkp --> Path/Nome do arquivo PDF gerado
                                     ,pr_flg_impri => 'N'                           --> Chamar a impressão (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> Número de cópias para impressão
                                     ,pr_des_erro  => vr_dscritic);                 --> Retorno de Erro
        
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;   
  
  COMMIT;
  
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback); 
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao apagar contratos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao apagar contratos - ' || SQLERRM);
END;
0
0
