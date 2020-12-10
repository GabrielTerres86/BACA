PL/SQL Developer Test script 3.0
272
-- Created on 08/12/2020 by T0032717 
DECLARE

  vr_nmdireto   VARCHAR2(4000); 
  vr_nmarqbkp   VARCHAR2(100);
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_dscritic   crapcri.dscritic%TYPE;
  vr_exc_erro   EXCEPTION;
  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;
  
  CURSOR cr_principal IS
    SELECT r.nrdconta
          ,r.nrctremp
      FROM crapepr e
          ,crawepr w
          ,tbepr_renegociacao r
          ,tbepr_renegociacao_contrato c
     WHERE e.cdcooper = 1
       AND e.cdfinemp IN (62,63) 
       AND TRUNC(e.dtmvtolt,'MM') >= '01/11/2020'
       AND e.cdcooper = w.cdcooper
       AND e.nrdconta = w.nrdconta
       AND e.nrctremp = w.nrctremp
       AND c.cdcooper = e.cdcooper
       AND c.nrdconta = e.nrdconta
       AND c.nrctrepr = e.nrctremp
       AND r.cdcooper = c.cdcooper
       AND r.nrdconta = c.nrdconta
       AND r.nrctremp = c.nrctremp
       AND Nvl(w.flgreneg,0) = 1
       AND r.dtlibera IS NULL
     GROUP BY r.nrdconta
             ,r.nrctremp;
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_crappep(pr_cdcooper IN crappep.cdcooper%TYPE,
                    pr_nrdconta IN crappep.nrdconta%TYPE,
                    pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT vljura60
      FROM crappep p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp;
  rw_crappep cr_crappep%ROWTYPE;
  
  CURSOR cr_risoperacao(pr_cdcooper IN crappep.cdcooper%TYPE,
                        pr_nrdconta IN crappep.nrdconta%TYPE,
                        pr_nrctremp IN crappep.nrctremp%TYPE) IS
    SELECT p.inrisco_inclusao
      FROM TBRISCO_OPERACOES p
     WHERE p.cdcooper = pr_cdcooper
       AND p.nrdconta = pr_nrdconta
       AND p.nrctremp = pr_nrctremp;
  rw_risoperacao cr_risoperacao%ROWTYPE;
  
  CURSOR cr_contratos(pr_cdcooper tbepr_renegociacao_contrato.cdcooper%TYPE
                     ,pr_nrdconta tbepr_renegociacao_contrato.nrdconta%TYPE
                     ,pr_nrctremp tbepr_renegociacao_contrato.nrctremp%TYPE) IS
    SELECT trc.nrctrotr, trc.nrctrepr, trc.cdlcremp_origem, trc.tpcontrato_liquidado, trc.nrctremp_novo, trc.cdfinemp,trc.nrdconta
      FROM tbepr_renegociacao_contrato trc
     WHERE trc.cdcooper = pr_cdcooper
       AND trc.nrdconta = pr_nrdconta
       AND trc.nrctremp = pr_nrctremp;
  rw_contratos cr_contratos%ROWTYPE;
    
  PROCEDURE pc_efetiva_reneg(pr_cdcooper IN crapepr.cdcooper%TYPE
                            ,pr_nrdconta IN crapepr.nrdconta%TYPE
                            ,pr_nrctremp IN tbepr_renegociacao_contrato.nrctremp%TYPE) IS
  BEGIN
    DECLARE
      vr_xmllog    VARCHAR2(1000);
      vr_cdcritic  PLS_INTEGER;
      vr_dscritic  VARCHAR2(1000);    
      vr_retxml    xmltype;
      vr_nmdcampo  VARCHAR2(1000);
      vr_des_erro  VARCHAR2(1000);
    BEGIN 
      vr_retxml := xmltype('<?xml version="1.0" encoding="WINDOWS-1252"?>
                              <Root>
                                <Dados>
                                  <cdcooper>'|| pr_cdcooper ||'</cdcooper>
                                  <nrdconta>'|| pr_nrdconta ||'</nrdconta>
                                  <nrctremp>'|| pr_nrctremp ||'</nrctremp>
                                </Dados>
                                <params>
                                  <nmprogra>ATENDA</nmprogra>
                                  <nmeacao>EFETIVA_RENEG</nmeacao>
                                  <cdcooper>1</cdcooper>
                                  <cdagenci>0</cdagenci>
                                  <nrdcaixa>0</nrdcaixa>
                                  <idorigem>5</idorigem>
                                  <cdoperad>1</cdoperad>
                                  <filesphp>/var/www/ayllos/telas/atenda/emprestimos/renegociacao/alienacao_tr.php</filesphp>
                                </params>
                              </Root>');
      EMPR0021.pc_efetiva_renegociacao(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_nrctremp => pr_nrctremp,
                                       pr_xmllog   => vr_xmllog,
                                       pr_cdcritic => vr_cdcritic,
                                       pr_dscritic => vr_dscritic,
                                       pr_retxml   => vr_retxml,
                                       pr_nmdcampo => vr_nmdcampo,
                                       pr_des_erro => vr_des_erro);
    END;
  END;
  
  -- Validacao de diretorio
  PROCEDURE pc_valida_direto(pr_nmdireto IN VARCHAR2
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS
  BEGIN
    DECLARE
      vr_dscritic crapcri.dscritic%TYPE;
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(1000);      
    BEGIN
        -- Primeiro garantimos que o diretorio exista
        IF NOT gene0001.fn_exis_diretorio(pr_nmdireto) THEN

          -- Efetuar a criação do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

          -- Adicionar permissão total na pasta
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'chmod 777 ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'PERMISSAO NO DIRETORIO --> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

        END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
    END;    
  END;
BEGIN

  vr_dados_rollback := NULL;
    
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
    
  vr_nmdireto  := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  -- Depois criamos o diretorio da cooperativa
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas/INC0070696'
                   ,pr_dscritic => vr_dscritic);
      
  IF TRIM(vr_dscritic) IS NOT NULL THEN
     RAISE vr_exc_erro;
  END IF;       
          
  vr_nmdireto  := vr_nmdireto||'cpd/bacas/INC0070696'; 
  vr_nmarqbkp  := 'ROLLBACK_EFETIVA_RENEG_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  -- Busca data de movimento
  OPEN btch0001.cr_crapdat(1);
  FETCH btch0001.cr_crapdat into rw_crapdat;
  --Se nao encontrou
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar Cursor
    CLOSE btch0001.cr_crapdat;

    -- Levantar Excecao
    RAISE vr_exc_erro;
  ELSE
    -- apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  FOR rw_principal IN cr_principal LOOP
    -- verificar dados do rollback
    -- volta dtlibera
    gene0002.pc_escreve_xml(vr_dados_rollback
                          , vr_texto_rollback
                          , 'UPDATE tbepr_renegociacao r ' || chr(13) || 
                            '   SET r.dtlibera = NULL' ||
                            ' WHERE r.cdcooper = 1'||
                            '   AND r.nrdconta = ' || rw_principal.nrdconta  || chr(13) ||
                            '   AND r.nrctremp = ' || rw_principal.nrctremp  || '; ' ||chr(13)||chr(13), FALSE);   
    
    FOR rw_contratos IN cr_contratos(pr_cdcooper => 1 
                                    ,pr_nrdconta => rw_principal.nrdconta
                                    ,pr_nrctremp => rw_principal.nrctremp) LOOP
      OPEN cr_crappep(pr_cdcooper => 1,
                      pr_nrdconta => rw_contratos.nrdconta,
                      pr_nrctremp => rw_contratos.nrctrepr);
      FETCH cr_crappep INTO rw_crappep;
      CLOSE cr_crappep;
      -- volta juros60 da pep (pc_grava_59d_parcela)
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'UPDATE crappep r ' || chr(13) || 
                              '   SET r.vljura60 = ' || rw_crappep.vljura60 || chr(13) ||
                              ' WHERE r.cdcooper = 1'|| chr(13) ||
                              '   AND r.nrdconta = ' || rw_contratos.nrdconta  || chr(13) ||
                              '   AND r.nrctremp = ' || rw_contratos.nrctrepr  || '; ' ||chr(13)||chr(13), FALSE);  
      -- volta iof cc (pc_efetua_lancamento_iof_cc)
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'DELETE FROM tbgen_iof_lancamento r ' || chr(13) || 
                              ' WHERE r.cdcooper = 1'|| chr(13) ||
                              '   AND r.nrdconta = ' || rw_contratos.nrdconta  || chr(13) ||
                              '   AND r.nrctremp = ' || rw_contratos.nrctrepr  || chr(13) ||
                              '   AND r.dtmvtolt = ' || rw_crapdat.dtmvtolt  || '; ' ||chr(13)||chr(13), FALSE);  
      
      OPEN cr_risoperacao(pr_cdcooper => 1,
                          pr_nrdconta => rw_contratos.nrdconta,
                          pr_nrctremp => rw_contratos.nrctrepr);
      FETCH cr_risoperacao INTO rw_risoperacao;
      CLOSE cr_risoperacao;
      -- volta tbrisco_operacao
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'UPDATE TBRISCO_OPERACOES r ' || chr(13) || 
                              '   SET r.inrisco_inclusao = ' || rw_risoperacao.inrisco_inclusao || chr(13) ||
                              ' WHERE r.cdcooper = 1'|| chr(13) ||
                              '   AND r.nrdconta = ' || rw_contratos.nrdconta  || chr(13) ||
                              '   AND r.nrctremp = ' || rw_contratos.nrctrepr  || '; ' ||chr(13)||chr(13), FALSE);  
     
    
    END LOOP;
       
    pc_efetiva_reneg(pr_cdcooper => 1,
                     pr_nrdconta => rw_principal.nrdconta,
                     pr_nrctremp => rw_principal.nrctremp);
                     
    
  END LOOP;
  UPDATE tbepr_renegociacao SET dtlibera = '03/11/2020' WHERE cdcooper = 1 AND nrdconta = 8040338 AND nrctremp = 3082720;
  UPDATE tbepr_renegociacao SET dtlibera = '13/11/2020' WHERE cdcooper = 1 AND nrdconta = 753149 AND nrctremp = 3061678;
  UPDATE tbepr_renegociacao SET dtlibera = '17/11/2020' WHERE cdcooper = 1 AND nrdconta = 9359192 AND nrctremp = 3152263;

  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
        
  -- Fecha o arquivo          
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, chr(13), TRUE);
  -- Grava o arquivo de rollback
  GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 1                             --> Cooperativa conectada
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
                                                
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);  
  COMMIT;
END;
0
0
