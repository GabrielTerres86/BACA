PL/SQL Developer Test script 3.0
134
-- Created on 05/04/2021 by T0032717 
-- Limpa capas de renegociação onde a crawepr não existe
DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
   
  CURSOR cr_tbepr_renegociacao IS
    SELECT * 
      FROM tbepr_renegociacao
     WHERE nrctremp = 0;
  rw_tbepr_renegociacao cr_tbepr_renegociacao%ROWTYPE;
  
  CURSOR cr_tbepr_renegociacao_contrato(pr_cdcooper IN craplem.cdcooper%TYPE
                                       ,pr_nrdconta IN craplem.nrdconta%TYPE) IS
    SELECT * 
      FROM tbepr_renegociacao_contrato
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = 0;
  rw_tbepr_renegociacao_contrato cr_tbepr_renegociacao_contrato%ROWTYPE;
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0096205'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0096205_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  FOR rw_tbepr_renegociacao IN cr_tbepr_renegociacao LOOP
    
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

    FOR rw_tbepr_renegociacao_contrato IN cr_tbepr_renegociacao_contrato(pr_cdcooper => rw_tbepr_renegociacao.CDCOOPER
                                                                        ,pr_nrdconta => rw_tbepr_renegociacao.NRDCONTA) LOOP
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'INSERT INTO tbepr_renegociacao_contrato (CDCOOPER, NRDCONTA, NRCTREMP, NRCTREPR, NRVERSAO, VLSDEVED, VLNVSDDE, VLNVPRES, TPEMPRST, NRCTROTR, CDFINEMP, CDLCREMP, DTDPAGTO, IDCARENC, DTCARENC, VLPRECAR, VLIOFEPR, VLTAREPR, IDQUALOP, NRDIAATR, CDLCREMP_ORIGEM, CDFINEMP_ORIGEM, VLEMPRST, VLFINANC, VLIOFADC, VLIOFPRI, PERCETOP, FLGIMUNE, TPCONTRATO_LIQUIDADO, INCANCELAR_PRODUTO, NRCTREMP_NOVO)
                               VALUES (' || rw_tbepr_renegociacao_contrato.CDCOOPER || ', 
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
                                       ' || rw_tbepr_renegociacao_contrato.NRCTREMP_NOVO || ');' ||chr(13)||chr(13), FALSE); 

    END LOOP;
    
    DELETE FROM tbepr_renegociacao_contrato WHERE cdcooper = rw_tbepr_renegociacao.CDCOOPER AND nrdconta = rw_tbepr_renegociacao.NRDCONTA AND nrctremp = 0;
    DELETE FROM tbepr_renegociacao WHERE cdcooper = rw_tbepr_renegociacao.CDCOOPER AND nrdconta = rw_tbepr_renegociacao.NRDCONTA AND nrctremp = 0;
    
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
  
  commit;
  
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
