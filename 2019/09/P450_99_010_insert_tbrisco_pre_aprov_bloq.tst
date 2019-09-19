PL/SQL Developer Test script 3.0
258
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
    
  --Cursor para buscar Crédito Pré-Aprovado
  CURSOR cr_crapcpa(pr_cdcooper IN crapcpa.cdcooper%TYPE
                   ,pr_dtmvtolt IN crapcpa.dtmvtolt%TYPE) IS  
    SELECT *
  FROM (SELECT cpa.cdcooper                                cdcooper          --Codigo que identifica a Cooperativa
              ,cpa.nrdconta                                nrdconta          --Numero da conta/dv do associado
              ,0                                           nrctremp          --Numero do contrato da operacao que gera rating
              ,68                                          tpctrato          --Tipo de contrato da operacao que gera rating
              ,NULL                                        inrisco_rating    --Indicador de risco (AA ate HH)
              ,Trunc(Nvl(cpa.dtcalc_rating,cpa.dtmvtolt))  dteftrat          --Data de efetivacao do rating
              ,'1'                                         cdoperad_rating   --Codigo do operador
              ,3                                           insituacao_rating --Situacao do rating (3-Vencido)
              ,NULL                                        inpontos_rating   --Nota atingida na soma dos itens do rating
              ,cpa.nrcpfcnpj_base                          nrcpfcnpj_base    --Numero do CPF/CNPJ Base do associado
              ,NULL                                        innivel_rating    --Nível de Risco 
              ,3                                           inorigem_rating   --Origem do Rating (3-Regra Aimaro)  
              ,1                                           flintegrar_sas    --Flag para indicar se o contrato deve integrar com o SAS
          from CECRED.CRAPCPA cpa, tbepr_carga_pre_aprv carga
         where cpa.cdcooper = carga.cdcooper
           AND cpa.iddcarga = carga.idcarga 
           AND carga.indsituacao_carga = 2 --Carga Liberada
           AND carga.flgcarga_bloqueada = 0 --Carga Não Bloqueada
           AND Nvl(carga.dtfinal_vigencia, Trunc(pr_dtmvtolt)) >= Trunc(pr_dtmvtolt) --Carga Vigente    
           and cpa.cdsituacao <> 'A'
           AND cpa.cdcooper = pr_cdcooper
        UNION    
        SELECT cpa.cdcooper                                cdcooper          --Codigo que identifica a Cooperativa
              ,cpa.nrdconta                                nrdconta          --Numero da conta/dv do associado
              ,0                                           nrctremp          --Numero do contrato da operacao que gera rating
              ,68                                          tpctrato          --Tipo de contrato da operacao que gera rating
              ,NULL                                        inrisco_rating    --Indicador de risco (AA ate HH)
              ,Trunc(Nvl(cpa.dtcalc_rating,cpa.dtmvtolt))  dteftrat          --Data de efetivacao do rating
              ,'1'                                         cdoperad_rating   --Codigo do operador
              ,3                                           insituacao_rating --Situacao do rating (3-Vencido)
              ,NULL                                        inpontos_rating   --Nota atingida na soma dos itens do rating
              ,cpa.nrcpfcnpj_base                          nrcpfcnpj_base    --Numero do CPF/CNPJ Base do associado
              ,NULL                                        innivel_rating    --Nível de Risco 
              ,3                                           inorigem_rating   --Origem do Rating (3-Regra Aimaro)  
              ,1                                           flintegrar_sas    --Flag para indicar se o contrato deve integrar com o SAS
          from CECRED.CRAPCPA cpa,
               tbepr_carga_pre_aprv carga,
               tbepr_motivo_nao_aprv mot
         where cpa.cdcooper = carga.cdcooper
           AND cpa.iddcarga = carga.idcarga 
           AND carga.indsituacao_carga = 2 --Carga Liberada
           AND carga.flgcarga_bloqueada = 0 --Carga Não Bloqueada
           AND Nvl(carga.dtfinal_vigencia, Trunc(pr_dtmvtolt)) >= Trunc(pr_dtmvtolt) --Carga Vigente    
           and cpa.cdsituacao = 'A'
           and mot.cdcooper = cpa.cdcooper
           and mot.tppessoa = cpa.tppessoa
           and mot.nrcpfcnpj_base = cpa.nrcpfcnpj_base
           and mot.idcarga = cpa.iddcarga
           and mot.dtregulariza IS NOT NULL
           AND cpa.cdcooper = pr_cdcooper) t
 WHERE NOT EXISTS (SELECT 1
                     FROM tbrisco_operacoes r
                    WHERE r.cdcooper = t.cdcooper
                      AND r.tpctrato = t.tpctrato
                      AND r.nrcpfcnpj_base = t.nrcpfcnpj_base);

  --------------------
  --    VARIAVEIS   --
  --------------------
  vr_exc_erro      EXCEPTION;
  vr_cdcritic      NUMBER;
  vr_dscritic      VARCHAR2(1000);
  vr_nrdconta      crapass.nrdconta%TYPE;
  vr_inpessoa      crapass.inpessoa%TYPE;
  vr_innivris      tbrisco_operacoes.inrisco_rating%TYPE;
    
BEGIN
  /**********Créditos Pré-Aprovado**********/
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
    
    -- Para cada Crédito Pré-Aprovado
    FOR rw_crapcpa IN cr_crapcpa(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      IF Nvl(rw_crapcpa.nrdconta,0) = 0 THEN 
        --Busca uma Conta do CPF/CNPJ Base
        BEGIN
          SELECT ass.nrdconta, ass.inpessoa
          INTO   vr_nrdconta, vr_inpessoa
          FROM   crapass ass
          WHERE  ass.cdcooper       = rw_crapcpa.cdcooper
          AND    ass.nrcpfcnpj_base = rw_crapcpa.nrcpfcnpj_base
          AND    ROWNUM = 1; --Buscar Somente uma conta (Regra Definida com Guilherme para não estourar PK da tbrisco_operacao)
        EXCEPTION       
          WHEN No_Data_Found THEN
            vr_dscritic := 'Nenhuma Conta foi encontrada para o CPF/CNPJ Base. Cooperativa: '||rw_crapcpa.cdcooper||' | CPF/CNPJ Base: '||rw_crapcpa.nrcpfcnpj_base;
            RAISE vr_exc_erro; 
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao buscar uma Conta na CRAPASS. Cooperativa: '||rw_crapcpa.cdcooper||' | CPF/CNPJ Base: '||rw_crapcpa.nrcpfcnpj_base||'. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_exc_erro;
        END; 
      ELSE
        --Utiliza a Conta que veio do cursor (CRAPCPA)
        vr_nrdconta := rw_crapcpa.nrdconta;
      END IF;
      
      --Insere na tbrisco_operacoes
      BEGIN
        INSERT INTO tbrisco_operacoes
             (cdcooper
             ,nrdconta
             ,nrctremp
             ,tpctrato
             ,inrisco_inclusao
             ,inrisco_calculado
             ,inrisco_melhora
             ,dtrisco_melhora
             ,cdcritica_melhora
             ,inrisco_rating
             ,inrisco_rating_autom
             ,dtrisco_rating
             ,insituacao_rating
             ,inorigem_rating
             ,cdoperad_rating
             ,dtrisco_rating_autom
             ,innivel_rating
             ,nrcpfcnpj_base
             ,inpessoa
             ,inpontos_rating
             ,flintegrar_sas
             ,insegmento_rating
             ,inrisco_rat_inc
             ,innivel_rat_inc
             ,inpontos_rat_inc
             ,insegmento_rat_inc)
        VALUES 
             (rw_crapcpa.cdcooper                                                   -- CDCOOPER
             ,vr_nrdconta                                                           -- NRDCONTA
             ,rw_crapcpa.nrctremp                                                   -- NRCTREMP             (Sempre  0 no cursor)
             ,rw_crapcpa.tpctrato                                                   -- TPCTRATO             (Sempre 68 no cursor)
             ,NULL                                                                  -- INRISCO_INCLUSAO
             ,NULL                                                                  -- INRISCO_CALCULADO
             ,NULL                                                                  -- INRISCO_MELHORA
             ,NULL                                                                  -- DTRISCO_MELHORA
             ,NULL                                                                  -- CDCRITICA_MELHORA
             ,rw_crapcpa.inrisco_rating                                             -- INRISCO_RATING       (Sempre NULL no cursor)
             ,rw_crapcpa.inrisco_rating                                             -- INRISCO_RATING_AUTOM (Sempre NULL no cursor)
             ,Decode(rw_crapcpa.insituacao_rating,3,NULL,rw_crapcpa.dteftrat)       -- DTRISCO_RATING       (Nulo quando Vencido - insituacao_rating=3)
             ,rw_crapcpa.insituacao_rating                                          -- INSITUACAO_RATING    (Sempre 3 no cursor) --3=Vencido
             ,rw_crapcpa.inorigem_rating                                            -- INORIGEM_RATING      (Sempre 3 no cursor) --3=Regra Aimaro
             ,rw_crapcpa.cdoperad_rating                                            -- CDOPERAD_RATING      (Sempre 1 no cursor)
             ,rw_crapcpa.dteftrat                                                   -- DTRISCO_RATING_AUTOM
             ,rw_crapcpa.innivel_rating                                             -- INNIVEL_RATING       (Sempre NULL no cursor)
             ,rw_crapcpa.nrcpfcnpj_base                                             -- NRCPFCNPJ_BASE
             ,vr_inpessoa                                                           -- Tipo Pessoa
             ,rw_crapcpa.inpontos_rating                                            -- INPONTOS_RATING      (Sempre NULL no cursor)
             ,rw_crapcpa.flintegrar_sas                                             -- FLINTEGRAR_SAS       (Sempre 1 no cursor)
             ,NULL                                                                  -- INSEGMENTO_RATING
             ,NULL                                                                  -- INRISCO_RAT_INC
             ,NULL                                                                  -- INNIVEL_RAT_INC
             ,NULL                                                                  -- INPONTOS_RAT_INC
             ,NULL);                                                                -- INSEGMENTO_RAT_INC
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Inserir na TBRISCO_OPERACOES (Pre-Aprovado). Cooperativa: '||rw_crapcpa.cdcooper||' | Conta: '||rw_crapcpa.nrdconta||' | CPF/CNPJ Base: '||rw_crapcpa.nrcpfcnpj_base||' | Contrato: '||rw_crapcpa.nrctremp||' | Tipo: '||rw_crapcpa.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro;
      END;
      
      COMMIT;
      
      RATI0003.pc_busca_rat_contigencia(pr_cdcooper => rw_crapcpa.cdcooper,
                                        pr_nrcpfcgc => rw_crapcpa.nrcpfcnpj_base, --> CPFCNPJ BASE
                                        pr_innivris => vr_innivris,                           --> risco contingencia
                                        pr_cdcritic => vr_cdcritic,
                                        pr_dscritic => vr_dscritic);

      -- grava o rating
      RATI0003.pc_grava_rating_operacao(pr_cdcooper       => rw_crapcpa.cdcooper  --> Código da Cooperativa
                                       ,pr_nrdconta       => vr_nrdconta  --> Conta do associado
                                       ,pr_tpctrato       => rw_crapcpa.tpctrato  --> Tipo do contrato de rating
                                       ,pr_nrctrato       => rw_crapcpa.nrctremp  --> Número do contrato do rating
 
                                       ,pr_ntrating       => vr_innivris  --> Nivel de Risco Rating EFETIVO
                                       ,pr_ntrataut       => vr_innivris  --> Nivel de Risco Rating retornado do MOTOR
                                       ,pr_dtrataut       => rw_crapdat.dtmvtolt --> Data do Rating retornado do MOTOR
                                       ,pr_innivel_rating => 2 --> Classificacao do Nivel de Risco do Rating (1-Baixo/2-Medio/3-Alto)
                                       ,pr_inpontos_rating => 68  --> Pontuacao do Rating retornada do Motor
                                       ,pr_dtrating       => rw_crapdat.dtmvtolt --> Data de Efetivacao do Rating

                                       ,pr_strating       => 4   --> Identificador da Situacao Rating (Dominio: tbgen_dominio_campo)
                                       ,pr_orrating       => 3   --> Identificador da Origem do Rating Contingencia (Dominio: tbgen_dominio_campo)
                                       ,pr_cdoprrat       => '1' --> Codigo Operador que Efetivou o Rating
                                       ,pr_nrcpfcnpj_base => rw_crapcpa.nrcpfcnpj_base --> Numero do CPF/CNPJ Base do associado
                                       ,pr_cdoperad       => '1'
                                       ,pr_dtmvtolt       => rw_crapdat.dtmvtolt
                                       ,pr_cdcritic       => vr_cdcritic
                                       ,pr_dscritic       => vr_dscritic);
                                       
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := 'Erro ao Atualizar a TBRISCO_OPERACOES (Limite Pre-Aprovado). Cooperativa: '||rw_crapcpa.cdcooper||' | CPF/CNPJ Base: '||rw_crapcpa.nrcpfcnpj_base||' | Contrato: '||rw_crapcpa.nrctremp||' | Tipo: '||rw_crapcpa.tpctrato|| 'vr_dscritic: '||vr_dscritic||'. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_exc_erro;
      END IF;
      
      BEGIN
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_crapcpa.cdcooper
           AND t.nrdconta = rw_crapcpa.nrdconta
           AND t.nrctremp = rw_crapcpa.nrctremp
           AND t.tpctrato = rw_crapcpa.tpctrato
           AND t.nrcpfcnpj_base = rw_crapcpa.nrcpfcnpj_base;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Atualizar integrar SAS de limite Pre-Aprovado. Cooperativa: '||rw_crapcpa.cdcooper||' | CPF/CNPJ Base: '||rw_crapcpa.nrcpfcnpj_base||' | Contrato: '||rw_crapcpa.nrctremp||' | Tipo: '||rw_crapcpa.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro;
      END;      
    END LOOP; --Créditos Pré-Aprovado
    -- Salva (Por Cooperativa)
    COMMIT;
  END LOOP; -- Cooperativas
  --
EXCEPTION
  WHEN vr_exc_erro THEN
    ROLLBACK;
    dbms_output.put_line(vr_dscritic);
    Raise_Application_Error(-20000,vr_dscritic);
  WHEN OTHERS THEN    
    ROLLBACK;
    vr_dscritic:= 'Erro Geral na Carga Inicial. Erro: '||SubStr(SQLERRM,1,255);
    dbms_output.put_line(vr_dscritic);
    Raise_Application_Error(-20001,vr_dscritic);
END;
0
0
