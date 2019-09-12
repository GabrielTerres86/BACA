PL/SQL Developer Test script 3.0
139
/****************************************************************************************************************
Função: Carga Inicial TBRISCO_OPERACAO - Atualização dos Pré-Aprovados com Rating de Contingência.
Criação: Abril/2019
Alterações:

****************************************************************************************************************/     
DECLARE
  --------------------
  --    CURSORES    --
  --------------------
  --Buscar todas as cooperativas ativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3 --Não deve rodar para a Central AILOS
     ORDER BY cop.cdcooper;

  --Cursor genérico de calendário da Cooperativa
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt, dat.dtmvtopr, dat.dtmvtoan, dat.inproces
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
    
  --> Buscar Risco Operações(tbrisco_operacoes) de Limites de Crédito Pré-Aprovado
  CURSOR cr_limite_pre_aprovado(p_tpctrato IN tbrisco_operacoes.tpctrato%TYPE
                               ,p_cdcooper IN tbrisco_operacoes.cdcooper%TYPE) IS
    SELECT t.cdcooper
          ,t.nrdconta
          ,t.nrctremp
          ,t.tpctrato
          ,t.inrisco_rating
          ,t.inrisco_rating_autom
          ,t.dtrisco_rating
          ,t.dtrisco_rating_autom
          ,t.insituacao_rating
          ,t.inorigem_rating
          ,t.cdoperad_rating
          ,t.innivel_rating
          ,t.nrcpfcnpj_base
          ,t.inpontos_rating
          ,t.insegmento_rating
     FROM tbrisco_operacoes  t
    WHERE t.cdcooper       = p_cdcooper
      AND t.tpctrato       = p_tpctrato;
  rw_limite_pre_aprovado cr_limite_pre_aprovado%ROWTYPE;

  --------------------
  --    VARIAVEIS   --
  --------------------
  vr_exc_erro      EXCEPTION;
  vr_cdcritic      NUMBER;
  vr_dscritic      VARCHAR2(1000);
  --
  vr_innivris      tbrisco_operacoes.inrisco_rating%TYPE;
    
BEGIN
  --------------------
  --     INICIO     --
  --------------------
  --Buscar as cooperativas
  FOR rw_crapcop IN cr_crapcop LOOP
    OPEN  cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH cr_crapdat INTO rw_crapdat;

    IF cr_crapdat%NOTFOUND THEN
      CLOSE cr_crapdat;
      vr_dscritic := 'Data da Cooperativa: '||rw_crapcop.cdcooper||' não encontrada.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapdat;
    END IF;

    --Busca Risco Operações de Limites de Crédito Pré-Aprovado(Pai)
    FOR rw_limite_pre_aprovado IN cr_limite_pre_aprovado(p_tpctrato       => 68 --Pré-Aprovado
                                                        ,p_cdcooper       => rw_crapcop.cdcooper) LOOP

      RATI0003.pc_busca_rat_contigencia(pr_cdcooper => rw_limite_pre_aprovado.cdcooper,
                                        pr_nrcpfcgc => rw_limite_pre_aprovado.nrcpfcnpj_base, --> CPFCNPJ BASE
                                        pr_innivris => vr_innivris,                           --> risco contingencia
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);

      -- grava o rating
      RATI0003.pc_grava_rating_operacao(pr_cdcooper       => rw_limite_pre_aprovado.cdcooper  --> Código da Cooperativa
                                       ,pr_nrdconta       => rw_limite_pre_aprovado.nrdconta  --> Conta do associado
                                       ,pr_tpctrato       => rw_limite_pre_aprovado.tpctrato  --> Tipo do contrato de rating
                                       ,pr_nrctrato       => rw_limite_pre_aprovado.nrctremp  --> Número do contrato do rating
 
                                       ,pr_ntrating       => vr_innivris  --> Nivel de Risco Rating EFETIVO
                                       ,pr_ntrataut       => vr_innivris  --> Nivel de Risco Rating retornado do MOTOR
                                       ,pr_dtrataut       => rw_crapdat.dtmvtolt --> Data do Rating retornado do MOTOR
                                       ,pr_innivel_rating => 2 --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                       ,pr_inpontos_rating => 68  --> Pontuacao do Rating retornada do Motor
                                       ,pr_dtrating       => rw_crapdat.dtmvtolt --> Data de Efetivacao do Rating

                                       ,pr_strating       => 4   --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                       ,pr_orrating       => 3   --> Identificador da Origem do Rating Contingencia (Dominio: tbgen_dominio_campo)
                                       ,pr_cdoprrat       => '1' --> Codigo Operador que Efetivou o Rating
                                       ,pr_nrcpfcnpj_base => rw_limite_pre_aprovado.nrcpfcnpj_base --> Numero do CPF/CNPJ Base do associado
                                       ,pr_cdoperad       => '1'
                                       ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                       ,pr_cdcritic       => vr_cdcritic
                                       ,pr_dscritic       => vr_dscritic);
                                       
      IF NVL(vr_cdcritic,0) > 0 or TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := 'Erro ao Atualizar a TBRISCO_OPERACOES (Limite Pre-Aprovado). Cooperativa: '||rw_limite_pre_aprovado.cdcooper||' | CPF/CNPJ Base: '||rw_limite_pre_aprovado.nrcpfcnpj_base||' | Contrato: '||rw_limite_pre_aprovado.nrctremp||' | Tipo: '||rw_limite_pre_aprovado.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_limite_pre_aprovado.cdcooper
           AND t.nrdconta = rw_limite_pre_aprovado.nrdconta
           AND t.nrctremp = rw_limite_pre_aprovado.nrctremp
           AND t.tpctrato = rw_limite_pre_aprovado.tpctrato
           AND t.nrcpfcnpj_base = rw_limite_pre_aprovado.nrcpfcnpj_base;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar integrar SAS de limite Pre-Aprovado. Cooperativa: '||rw_limite_pre_aprovado.cdcooper||' | CPF/CNPJ Base: '||rw_limite_pre_aprovado.nrcpfcnpj_base||' | Contrato: '||rw_limite_pre_aprovado.nrctremp||' | Tipo: '||rw_limite_pre_aprovado.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro;
      END;
    END LOOP; -- Limites Pré-Aprovado
    -- Salva (Por Cooperativa)
    COMMIT;
  END LOOP; -- Cooperativas
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_output.put_line(vr_dscritic);
    Raise_Application_Error(-20000,vr_dscritic);
  WHEN OTHERS THEN    
    ROLLBACK;
    vr_dscritic:= 'Erro Geral na Carga Inicial - Atualizar Pré-Aprovados como contingência. Erro: '||SubStr(SQLERRM,1,255);
    dbms_output.put_line(vr_dscritic);
    Raise_Application_Error(-20001,vr_dscritic);
END;
0
0
