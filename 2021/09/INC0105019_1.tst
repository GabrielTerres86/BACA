PL/SQL Developer Test script 3.0
159
DECLARE
  vr_exc_erro EXCEPTION;
  vr_dscritic crapcri.dscritic%TYPE;

  vr_dados_rollback CLOB; -- Grava update de rollback
  vr_texto_rollback VARCHAR2(32600);
  vr_nmarqbkp       VARCHAR2(100);
  vr_nmdireto       VARCHAR2(4000); 
  vr_progress_recid craplcm.progress_recid%TYPE;
  
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
 
  CURSOR cr_principal IS
    SELECT epr.cdcooper
          ,epr.nrdconta
          ,epr.nrctremp
    FROM   crapepr epr 
    WHERE (epr.cdcooper = 10 AND epr.nrdconta = 39993  AND epr.nrctremp = 31608)
    OR    (epr.cdcooper = 13 AND epr.nrdconta = 512400 AND epr.nrctremp = 142238)
    OR    (epr.cdcooper =  7 AND epr.nrdconta = 112720 AND epr.nrctremp = 62032)
    OR    (epr.cdcooper = 13 AND epr.nrdconta = 396583 AND epr.nrctremp = 138127);
  rw_principal cr_principal%ROWTYPE;  
  --
  CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT decode(epr.idfiniof, 1, (epr.vlemprst - nvl(epr.vltarifa,0) - nvl(epr.vliofepr,0)), epr.vlemprst) vlemprst
      FROM crapepr epr 
     WHERE epr.cdcooper = pr_cdcooper 
       AND epr.nrdconta = pr_nrdconta
       AND epr.nrctremp = pr_nrctremp;
  rw_crapepr cr_crapepr%ROWTYPE;
  
  -- Cursor Capa do Lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                   ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                   ,pr_cdagenci IN craplot.cdagenci%TYPE
                   ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                   ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
  SELECT lot.dtmvtolt
        ,lot.cdagenci
        ,lot.cdbccxlt
        ,lot.nrdolote
        ,NVL(lot.nrseqdig,0) nrseqdig
        ,lot.cdcooper
        ,lot.tplotmov
        ,lot.vlinfodb
        ,lot.vlcompdb
        ,lot.qtinfoln
        ,lot.qtcompln
        ,lot.cdoperad
        ,lot.tpdmoeda
        ,lot.rowid
    FROM craplot lot
   WHERE lot.cdcooper = pr_cdcooper
     AND lot.dtmvtolt = pr_dtmvtolt
     AND lot.cdagenci = pr_cdagenci
     AND lot.cdbccxlt = pr_cdbccxlt
     AND lot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;  
  
BEGIN
  dbms_output.enable(NULL);
  vr_dados_rollback := NULL;
  dbms_lob.createtemporary(vr_dados_rollback, TRUE, dbms_lob.CALL);
  dbms_lob.open(vr_dados_rollback, dbms_lob.lob_readwrite);    
  gene0002.pc_escreve_xml(vr_dados_rollback, vr_texto_rollback, '-- Programa para rollback das informacoes'||chr(13), FALSE);
  
  vr_nmdireto := gene0001.fn_param_sistema('CRED',0,'ROOT_MICROS');
  vr_nmdireto := vr_nmdireto||'cpd/bacas/INC0105019'; 
  vr_nmarqbkp := 'ROLLBACK_INC0105019_'||to_char(sysdate,'ddmmyyyy_hh24miss')||'.sql';

  for rw_principal in cr_principal loop
    begin
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_principal.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;
      
      -- Lancamento para INC0102308
      OPEN cr_crapepr(pr_cdcooper => rw_principal.cdcooper
                     ,pr_nrdconta => rw_principal.nrdconta
                     ,pr_nrctremp => rw_principal.nrctremp);
      FETCH cr_crapepr INTO rw_crapepr;
      CLOSE cr_crapepr;
      
      OPEN cr_craplot(pr_cdcooper => rw_principal.cdcooper
                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                     ,pr_cdagenci => 1
                     ,pr_cdbccxlt => 100
                     ,pr_nrdolote => 8456);
      FETCH cr_craplot INTO rw_craplot;
      CLOSE cr_craplot;
      
      BEGIN
        INSERT INTO craplcm (cdcooper ,dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdctabb
           , nrdctitg
           , nrdocmto
           , cdhistor
           , nrseqdig
           , cdpesqbb
           , vllanmto)
        VALUES  
           (rw_principal.cdcooper, rw_craplot.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt, rw_craplot.nrdolote, rw_principal.nrdconta, rw_principal.nrdconta
           , GENE0002.fn_mask(rw_principal.nrdconta,'99999999')
           , GENE0002.fn_mask(rw_principal.nrctremp || TO_CHAR(sysdate,'SSSSS') || (nvl(rw_craplot.nrseqdig,0) + 1),'999999999999999') 
           , 15 -- CR.EMPRESTIMO
           , nvl(rw_craplot.nrseqdig,0) + 1
           , GENE0002.fn_mask(rw_principal.nrctremp,'99999999')
           , rw_crapepr.vlemprst) RETURNING progress_recid INTO vr_progress_recid;
      EXCEPTION
        WHEN OTHERS THEN
          cecred.pc_internal_exception;
          vr_dscritic := 'Erro ao inserir na tabela craplcm 1 - (15) . ' || SQLERRM;
         --Sair do programa
         RAISE vr_exc_erro;
      END;
      
      -- grava rollback
      gene0002.pc_escreve_xml(vr_dados_rollback
                            , vr_texto_rollback
                            , 'DELETE FROM craplcm WHERE cdcooper = '||rw_principal.cdcooper||' AND nrdconta = '||rw_principal.nrdconta||' AND cdhistor = 15 AND progress_recid = '||vr_progress_recid||';' || chr(13), FALSE); 
    end; 
  end loop;
 
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
end;
0
0
