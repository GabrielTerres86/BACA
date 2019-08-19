DECLARE
  -- DDLs Chamado DDL_Ch_REQ0026142_005
  -- 10/12/2018 - Ana - Envolti 
  -- Alteração do status da tela na CRAPTEL.flgtelbl para que seja incluída novamente no Menu em 01/2019
  --
  vr_existe    VARCHAR2(1);
  vr_exc_saida EXCEPTION;
  vr_cdcritic  INTEGER;
  vr_dscritic  VARCHAR2(4000);
  vr_idprglog  tbgen_prglog.idprglog%TYPE := 0;
    
BEGIN      -- INICIO
  -- Inclui nome do modulo logado
  GENE0001.pc_set_modulo(pr_module => 'BACA_REQ0026142_005' ,pr_action => NULL);
  
  BEGIN
    --Verifica se já existe o cadastro na CRAPTEL
    SELECT 1
    INTO   vr_existe
    FROM   craptel
    WHERE  nmdatela = 'CONLOG'
    AND    cdcooper = 3;

    IF vr_existe = 1 THEN
      BEGIN
        --Verifica se já existe o cadastro na CRAPTEL
        UPDATE craptel a
        SET    flgtelbl = 1 --Habilita
        WHERE  nmdatela = 'CONLOG'
        AND    cdcooper = 3;
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception(pr_cdcooper => 3);       

          vr_cdcritic := 1035;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'craptel:'||
          ' flgtelbl:'||'0'||
          ' com nmdatela:CONLOG'||
          ', cdcooper:'||'3'||
          '. '||sqlerrm;
            
          raise vr_exc_saida;
      END;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vr_cdcritic := 322;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

      raise vr_exc_saida;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception(pr_cdcooper => 3);       

      raise vr_exc_saida;
  END;
  
  COMMIT;  
EXCEPTION 
  WHEN vr_exc_saida THEN
    --
    CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                           pr_cdcooper      => 3, 
                           pr_tpocorrencia  => 1, 
                           pr_cdprograma    => 'BACA_REQ0026142_005', 
                           pr_tpexecucao    => 0, --Outros
                           pr_cdcriticidade => 1,
                           pr_cdmensagem    => vr_cdcritic, 
                           pr_dsmensagem    => vr_dscritic,               
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);

  WHEN OTHERS THEN
    -- No caso de erro de programa gravar tabela especifica de log  
    CECRED.pc_internal_exception(pr_cdcooper => 3);       

    vr_cdcritic := 9999;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'BACA_REQ0026142_005. '||sqlerrm;

    CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                           pr_cdcooper      => 3, 
                           pr_tpocorrencia  => 2, 
                           pr_cdprograma    => 'BACA_REQ0026142_005', 
                           pr_tpexecucao    => 0, --Outros
                           pr_cdcriticidade => 2,
                           pr_cdmensagem    => vr_cdcritic, 
                           pr_dsmensagem    => vr_dscritic,               
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);
END;
