PL/SQL Developer Test script 3.0
195
-- Created on 05/04/2021 by T0032717 
DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
   
  CURSOR cr_craplem(pr_cdcooper IN craplem.cdcooper%TYPE
                   ,pr_nrdconta IN craplem.nrdconta%TYPE
                   ,pr_nrctremp IN craplem.nrctremp%TYPE) IS
    SELECT SUM(
         DECODE(h.indebcre, 
               'D', craplem.vllanmto, 
               CASE craplem.cdhistor 
                 WHEN 2415 THEN craplem.vllanmto 
                 WHEN 2411 THEN craplem.vllanmto 
                 WHEN 1040 THEN craplem.vllanmto 
                 WHEN 1037 THEN craplem.vllanmto 
                 WHEN 1077 THEN craplem.vllanmto 
                 WHEN 1078 THEN craplem.vllanmto 
                 WHEN 1619 THEN craplem.vllanmto 
                 WHEN 1620 THEN craplem.vllanmto 
                 WHEN 1735 THEN craplem.vllanmto 
                 WHEN 1733 THEN craplem.vllanmto
                 ELSE (craplem.vllanmto * (-1)) 
               END))
           lancamento
     FROM craplem craplem, craphis h
    WHERE craplem.cdcooper = pr_cdcooper
      AND craplem.nrdconta = pr_nrdconta
      AND craplem.nrctremp = pr_nrctremp
      /* Desprezando historicos de concessao de credito com juros a apropriar e lancamendo para desconto + demais historicos que estao descontados ou adicionados a outros */    
      AND craplem.cdhistor NOT IN (1047,1077,1032,1033,1034,1035,1048,1049,2566,2567,
                                   2388,2473,2389,2390,2475,2392,2474,2393,2394,2476,
                                   2386,2388,2473,2389,2390,2475,2387,2392,2474,2393,
                                   2394,2476,1731,2396,2397,2381,2382,2385,2400,3356,
                                   3357,3358,3359,1734,1736,2382,2423,2416,2390,2475,
                                   2394,2476,2735,2471,2472,2358,2359,2878,2884,2885,
                                   2888,2405,2735,2311,2312,1076,1078)
      /*Historicos que nao vao compor o saldo, mas vao aparecer no relatorio*/
      AND craplem.cdhistor NOT IN (1048,1049,1050,1051,1717,1720,1708,1711,2566,2567,
                                   2423,2416,2390,2475,2394,2476,2735,
                                   --> Novos historicos de estorno de financiamento
                                   2784,2785,2786,2787,2882,2883,2887,2884,2886,2954,
                                   2955,2956,2953,2735
                                   --> Estorno IOF Comp. Consignado (P437)
                                   ,3013)
      AND h.cdcooper = craplem.cdcooper
      AND h.cdhistor = craplem.cdhistor;
  rw_craplem cr_craplem%ROWTYPE;
  
  CURSOR cr_crapepr IS
    SELECT a.cdcooper, a.nrdconta, a.nrctremp, a.vlsdprej 
      FROM (SELECT cdcooper, nrdconta, nrctremp, vlsdprej 
              FROM crapepr
             WHERE cdcooper = 12
             AND nrdconta= 133035
             AND nrctremp = 15529
             -- AND vlsdprej > 0    --no dia 30/08/2021 esse valor estava zerado na tabela         
      ) a;
  rw_crapepr cr_crapepr%ROWTYPE;
  
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

          -- Efetuar a cria��o do mesmo
          gene0001.pc_OSCommand_Shell(pr_des_comando => 'mkdir ' || pr_nmdireto || ' 1> /dev/null'
                                      ,pr_typ_saida  => vr_typ_saida
                                      ,pr_des_saida  => vr_des_saida);

          --Se ocorreu erro dar RAISE
          IF vr_typ_saida = 'ERR' THEN
             vr_dscritic := 'CRIAR DIRETORIO ARQUIVO --> Nao foi possivel criar o diretorio para gerar os arquivos. ' || vr_des_saida;
             RAISE vr_exc_erro;
          END IF;

          -- Adicionar permiss�o total na pasta
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
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas'
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  -- Depois criamos o diretorio do projeto
  pc_valida_direto(pr_nmdireto => vr_nmdireto || 'cpd/bacas/INC0096736'
                  ,pr_dscritic => vr_dscritic);
    
  IF TRIM(vr_dscritic) IS NOT NULL THEN
    RAISE vr_exc_erro;
  END IF;  
  
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0096736'; 
  vr_nmarqbkp  := 'ROLLBACK_INC0096736_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';
  
  FOR rw_crapepr IN cr_crapepr LOOP
    
    OPEN cr_craplem(pr_cdcooper => rw_crapepr.cdcooper
                   ,pr_nrdconta => rw_crapepr.nrdconta
                   ,pr_nrctremp => rw_crapepr.nrctremp);
    FETCH cr_craplem INTO rw_craplem;
    CLOSE cr_craplem;
    
 
   -- IF rw_crapepr.vlsdprej > rw_craplem.lancamento AND rw_craplem.lancamento > 0 AND rw_crapepr.vlsdprej > 0 THEN
      -- atualiza o valor apenas, linha anterior comentada pois nao contemplava essa condicao
      UPDATE crapepr 
         SET vlsdprej = rw_craplem.lancamento
       WHERE cdcooper = rw_crapepr.cdcooper
         AND nrdconta = rw_crapepr.nrdconta
         AND nrctremp = rw_crapepr.nrctremp;
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'UPDATE crapepr ' || chr(13) || 
                              '   SET vlsdprej = ' || REPLACE(rw_crapepr.vlsdprej, ',', '.') || chr(13) ||
                              ' WHERE cdcooper = ' || rw_crapepr.cdcooper || chr(13) ||
                              '   AND nrdconta = ' || rw_crapepr.nrdconta || chr(13) ||
                              '   AND nrctremp = ' || rw_crapepr.nrctremp || '; ' ||chr(13)||chr(13), FALSE); 
   -- END IF;
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
                                     ,pr_flg_impri => 'N'                           --> Chamar a impress�o (Imprim.p)
                                     ,pr_flg_gerar => 'S'                           --> Gerar o arquivo na hora
                                     ,pr_flgremarq => 'N'                           --> remover arquivo apos geracao
                                     ,pr_nrcopias  => 1                             --> N�mero de c�pias para impress�o
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
    raise_application_error(-20100, 'Erro ao atualizar contratos - ' || vr_dscritic);
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao atualizar contratos - ' || SQLERRM);
END;
0
3
rw_crapepr.vlsdprej
rw_craplem.lancamento
vr_nmdireto
