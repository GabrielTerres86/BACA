PL/SQL Developer Test script 3.0
229
-- Created on 03/12/2020 by T0032717 
DECLARE 
    
  vr_dtcorte      craplem.dtmvtolt%TYPE;
  vr_vlctrato2409 craplem.vllanmto%TYPE;
  vr_vllanmto     craplem.vllanmto%TYPE;
  -- 
  vr_cdcritic       INTEGER:= 0; 
  vr_dscritic       crapcri.dscritic%TYPE;
  vr_nmdireto       VARCHAR2(4000); 
  vr_exc_erro       EXCEPTION;  
  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  
  CURSOR cr_crapcop IS
    SELECT cdcooper, nmrescop
      FROM crapcop
     WHERE flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  CURSOR cr_principal(pr_cdcooper IN craplem.cdcooper%TYPE) IS
    SELECT l.nrdconta, l.nrctremp 
      FROM craplem l, crapepr e
     WHERE l.cdcooper = pr_cdcooper
       AND l.cdhistor = 382
       AND l.dtmvtolt BETWEEN '01/06/2018' AND '20/08/2019'
       AND e.cdcooper = l.cdcooper
       AND e.nrdconta = l.nrdconta 
       AND e.nrctremp = l.nrctremp
       AND e.inliquid = 1
       AND e.inprejuz = 1
       AND e.vlsdprej > 0
       AND EXISTS (SELECT 1             -- teve lançamento do 2409 em até 30 dias antes do 382
                     FROM craplem lem 
                    WHERE lem.cdcooper = l.cdcooper 
                      AND lem.nrdconta = l.nrdconta 
                      AND lem.nrctremp = l.nrctremp
                      AND lem.cdhistor = 2409
                      AND lem.dtmvtolt BETWEEN l.dtmvtolt - 30 AND l.dtmvtolt)
     GROUP BY l.nrdconta, l.nrctremp;
  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_lancamentos(pr_cdcooper craplem.cdcooper%TYPE
                       ,pr_nrdconta craplem.nrdconta%TYPE
                       ,pr_nrctremp craplem.nrctremp%TYPE
                       ,pr_dtmvtolt craplem.dtmvtolt%TYPE) IS
    SELECT l.* 
      FROM craplem l
     WHERE l.cdcooper = pr_cdcooper
       AND l.nrdconta = pr_nrdconta
       AND l.nrctremp = pr_nrctremp
       AND l.cdhistor IN (2409, 382)
       AND l.dtmvtolt <= pr_dtmvtolt
     ORDER BY l.dtmvtolt ASC;
  rw_lancamentos cr_lancamentos%ROWTYPE;
  
  CURSOR cr_corte382(pr_cdcooper craplem.cdcooper%TYPE
                    ,pr_nrdconta crapepr.nrdconta%TYPE
                    ,pr_nrctremp craplem.nrctremp%TYPE) IS
    SELECT MAX(dtmvtolt) dtmvtolt
      FROM craplem 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND cdhistor = 382;
  
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
  dbms_output.enable(NULL);
  
  vr_dados_rollback := NULL;
    
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto  := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto  := vr_nmdireto||'cpd/bacas/PRB0042624'; 
  vr_nmarqbkp  := 'ROLLBACK_PRB0042624_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  -- Primeiro criamos o diretorio da RITM, dentro de um diretorio ja existente
  pc_valida_direto(pr_nmdireto => vr_nmdireto
                  ,pr_dscritic => vr_dscritic);
  
  IF TRIM(vr_dscritic) IS NOT NULL THEN
   RAISE vr_exc_erro;
  END IF;   
    
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_principal IN cr_principal(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      vr_vlctrato2409 := 0;
      -- busca data do ultimo lancamento do 382
      OPEN cr_corte382(pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_nrdconta => rw_principal.nrdconta
                      ,pr_nrctremp => rw_principal.nrctremp);
      FETCH cr_corte382 INTO vr_dtcorte;
      CLOSE cr_corte382;
      -- Verificar os lançamentos feitos 
      FOR rw_lancamentos IN cr_lancamentos(pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nrdconta => rw_principal.nrdconta
                                          ,pr_nrctremp => rw_principal.nrctremp
                                          ,pr_dtmvtolt => vr_dtcorte) LOOP
        IF rw_lancamentos.cdhistor = 2409 THEN
          -- totalizo sequencia de juros
          vr_vlctrato2409 := vr_vlctrato2409 + rw_lancamentos.vllanmto;
        ELSE -- se for um 382
          -- se tem juro anterior para deduzir, mantem a consistencia do lancamento sem fazer pagamento caso nao tenha um juro anterior
          IF vr_vlctrato2409 > 0 THEN
            -- se 382 é maior que o total de juros
            IF vr_vlctrato2409 < rw_lancamentos.vllanmto THEN
              -- lancamos só os juros
              vr_vllanmto := vr_vlctrato2409;
              vr_vlctrato2409 := 0;
            ELSE
              -- senao lancamos tudo e controlamos a sobra do 2409
              vr_vllanmto := rw_lancamentos.vllanmto;
              vr_vlctrato2409 := vr_vlctrato2409 - rw_lancamentos.vllanmto;
            END IF;
            gene0002.pc_escreve_xml(vr_dados_rollback
                                   , vr_texto_rollback
                                   , 'DELETE ' || chr(13) || 
                                     '  FROM craplem l '  || 
                                     ' WHERE l.cdcooper = ' || rw_crapcop.cdcooper     || chr(13) ||
                                     '   AND l.nrdconta = ' || rw_principal.nrdconta   || chr(13) ||
                                     '   AND l.nrctremp = ' || rw_principal.nrctremp   || chr(13) ||
                                     '   AND l.dtmvtolt = ' || rw_lancamentos.dtmvtolt || chr(13) ||
                                     '   AND l.cdhistor = 2389' || chr(13) ||
                                     '   AND l.vllanmto = ' || vr_vllanmto || '; ' ||chr(13)||chr(13), FALSE);   
            -- Pagamento com data do 382
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => rw_crapcop.cdcooper
                                           ,pr_dtmvtolt => rw_lancamentos.dtmvtolt
                                           ,pr_cdagenci => 1
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => 1
                                           ,pr_cdpactra => 1
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => rw_principal.nrdconta
                                           ,pr_cdhistor => 2389 -- juros atualizado
                                           ,pr_nrctremp => rw_principal.nrctremp
                                           ,pr_vllanmto => vr_vllanmto
                                           ,pr_dtpagemp => rw_lancamentos.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => 0
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
            COMMIT; -- lancamento
          END IF;
        END IF;
      END LOOP;
    END LOOP;
  END LOOP;
  -- Adiciona TAG de commit 
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, 'COMMIT;'||chr(13), FALSE);
  -- Fecha o arquivo
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
    
  dbms_lob.close(vr_dados_rollback);
  dbms_lob.freetemporary(vr_dados_rollback);   

  COMMIT;
  
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    raise_application_error(-20111, vr_dscritic);
END;
0
0
