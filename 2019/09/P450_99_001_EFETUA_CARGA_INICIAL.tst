PL/SQL Developer Test script 3.0
986
/****************************************************************************************************************
Função: Carga Inicial TBRISCO_OPERACAO
Criação: Abril/2019
Alterações:
   08/05/2019 - Incluir todos os Registros da tabela CRANRC, foi desconsiderado situação de ativos 
                no cursor principal (AMcom - Mário).        

   17/05/2019 - Incluir os Registros de Bordero de Cheques e Titulos (AMcom - Mário). 
    
   08/08/2019 - Estoria 24429:Rating - Adicionar Historico Carga inicial (Heckmann - AMcom).
         
   14/08/2019 - Estoria 24459:Rating - Carga Inicial - Segregar por quantidade (Marcelo Gonçalves - AMcom).
         
   15/08/2019 - Tratamento de COMMIT, Tratamento de Erros e Melhorias nos Códigos (Marcelo Gonçalves - AMcom).
   
   21/08/2019 - Estoria 24442:Rating - Adicionar Pré-Aprovado na Carga inicial (Marcelo Gonçalves - AMcom).
   
   23/08/2019 - Estoria 24442:Rating - Adicionar Contratos Sem Rating na Carga inicial (Marcelo Gonçalves - AMcom).
   
   23/08/2019 - Estória 24442:Rating - Alterado a quantidade diária a segregar de 3.000 para 60.000 registros (Marcelo Gonçalves - AMcom).
   
   26/08/2019 - Estória 24442:Rating - Alterado para Buscar Nro do Contrato Limite de Desconto Titulo e Cheque na crapbdt e crapbdc p/Contratos Sem Rating) (Marcelo Gonçalves - AMcom).
   
   02/09/2019 - Adicionado INPESSOA em todas as operações de rating (Luiz - AMcom).
   
   04/09/2019 - Correção nome coluna errado INPESSA para INPESSOA (Marcelo Gonçalves - AMcom).
   
   04/09/2019 - Bug 25946 - Carga inicial - Marcar Rating Proposto para Integrar com SAS (Guilherme - AMcom).
   
   05/09/2019 - Retirar Segregação por quantidade diária (60.000), este controle será feito pela IBRATAN (Marcelo Gonçalves - AMcom).
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


  --Cursor para buscar CPF/CNPJ Base dos associados
  CURSOR cr_tbrisco_operacoes(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT opr.cdcooper
          ,opr.nrdconta
          ,ass.nrcpfcnpj_base
          ,ass.inpessoa
    FROM   tbrisco_operacoes  opr
          ,crapass            ass
    WHERE  opr.cdcooper = pr_cdcooper
    AND    ass.cdcooper = opr.cdcooper
    AND    ass.nrdconta = opr.nrdconta 
    AND    ass.nrcpfcnpj_base <> Nvl(opr.nrcpfcnpj_base,0);
    
    
  -- Cursor para Maior Sequência dos Históricos Rating   
  CURSOR cr_tbrating_historicos(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_nrctro   IN tbrating_historicos.nrctremp%TYPE
                               ,pr_tpctrato IN tbrating_historicos.tpctrato%TYPE) IS
    SELECT Nvl(Max(nrseq_operacao) + 1,1)
    FROM   tbrating_historicos
    WHERE  cdcooper = pr_cdcooper
    AND    nrdconta = pr_nrdconta    
    AND    nrctremp = pr_nrctro    
    AND    tpctrato = pr_tpctrato;  


  --Cursor para buscar Notas do rating por contrato
  CURSOR cr_crapnrc(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    -- Empréstimo
    SELECT nrc.cdcooper                            cdcooper          -- Codigo que identifica a Cooperativa.
          ,nrc.nrdconta                            nrdconta          -- Numero da conta/dv do associado.
          ,nrc.nrctrrat                            nrctremp          -- Numero do contrato da operacao que gera rating.
          ,nrc.tpctrrat                            tpctrato          -- Tipo de contrato da operacao que gera rating
          ,CASE WHEN nrc.indrisco = 'AA' THEN  1
                WHEN nrc.indrisco = 'A'  THEN  2
                WHEN nrc.indrisco = 'B'  THEN  3
                WHEN nrc.indrisco = 'C'  THEN  4
                WHEN nrc.indrisco = 'D'  THEN  5
                WHEN nrc.indrisco = 'E'  THEN  6
                WHEN nrc.indrisco = 'F'  THEN  7
                WHEN nrc.indrisco = 'G'  THEN  8
                WHEN nrc.indrisco = 'H'  THEN  9
                WHEN nrc.indrisco = 'HH' THEN 10
                ELSE                           2  
           END                                     inrisco_rating    -- Indicador de risco (A ate H)
          ,Nvl(nrc.dteftrat,nrc.dtmvtolt)          dteftrat          -- Data de efetivacao do rating.
          ,(Nvl(nrc.dteftrat,nrc.dtmvtolt) + 180)  dtvenc_rat        -- Data Vencimento Rating
          ,nrc.cdoperad                            cdoperad_rating   -- Codigo do operador
          ,Decode(nrc.insitrat,2,4,2)              insituacao_rating -- Situacao do rating INSITRAT (4-Efetivado)
          ,nrc.nrnotrat                            inpontos_rating   -- Nota atingida na soma dos itens do rating
          ,ass.nrcpfcnpj_base                      nrcpfcnpj_base    -- Numero do CPF/CNPJ Base do associado
          ,ass.inpessoa                            inpessoa          -- Tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
          ,2                                       innivel_rating    -- Nível de Risco (2-NIVEL MEDIO)
          ,nrc.insitrat                            insitrat          -- Situacao do rating (1-proposto 2-efetivo) 
    FROM   crapnrc  nrc
          ,crapass  ass
          ,crapepr  epr
    WHERE  epr.cdcooper = nrc.cdcooper
    AND    epr.nrdconta = nrc.nrdconta
    AND    epr.nrctremp = nrc.nrctrrat     
    AND   (epr.inliquid = 0 OR epr.vlsdprej > 0)
    AND    ass.cdcooper = epr.cdcooper
    AND    ass.nrdconta = epr.nrdconta       
    AND    nrc.tpctrrat = 90 --Empréstimo
    AND    nrc.cdcooper = pr_cdcooper
    UNION ALL
    -- Limite Credito, Desconto Titulo, Desconto Cheque
    SELECT nrc.cdcooper                            cdcooper          -- Codigo que identifica a Cooperativa.
          ,nrc.nrdconta                            nrdconta          -- Numero da conta/dv do associado.
          ,nrc.nrctrrat                            nrctremp          -- Numero do contrato da operacao que gera rating.
          ,nrc.tpctrrat                            tpctrato          -- Tipo de contrato da operacao que gera rating
          ,CASE WHEN nrc.indrisco = 'AA' THEN 1
                WHEN nrc.indrisco = 'A'  THEN  2
                WHEN nrc.indrisco = 'B'  THEN  3
                WHEN nrc.indrisco = 'C'  THEN  4
                WHEN nrc.indrisco = 'D'  THEN  5
                WHEN nrc.indrisco = 'E'  THEN  6
                WHEN nrc.indrisco = 'F'  THEN  7
                WHEN nrc.indrisco = 'G'  THEN  8
                WHEN nrc.indrisco = 'H'  THEN  9
                WHEN nrc.indrisco = 'HH' THEN 10
                ELSE                           2 
           END                                     inrisco_rating    -- Indicador de risco
          ,Nvl(nrc.dteftrat,nrc.dtmvtolt)          dteftrat          -- Data de efetivacao do rating.
          ,(Nvl(nrc.dteftrat,nrc.dtmvtolt) + 180)  dtvenc_rat        -- Data Vencimento Rating
          ,nrc.cdoperad                            cdoperad_rating   -- Codigo do operador
          ,Decode(nrc.insitrat,2,4,2)              insituacao_rating -- Situacao do rating (4-Efetivado)
          ,nrc.nrnotrat                            inpontos_rating   -- Nota atingida na soma dos itens do rating
          ,ass.nrcpfcnpj_base                      nrcpfcnpj_base    -- Numero do CPF/CNPJ Base do associado
          ,ass.inpessoa                            inpessoa          -- Tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
          ,2                                       innivel_rating    -- Nível de Risco (2-NIVEL MEDIO)
          ,nrc.insitrat                            insitrat          -- Situacao do rating (1-proposto 2-efetivo) 
    FROM   crapnrc  nrc
          ,crapass  ass
          ,craplim  lim
    WHERE  lim.cdcooper = nrc.cdcooper
    AND    lim.nrdconta = nrc.nrdconta
    AND    lim.nrctrlim = nrc.nrctrrat 
    AND    lim.tpctrlim = nrc.tpctrrat
    AND    ass.cdcooper = lim.cdcooper
    AND    ass.nrdconta = lim.nrdconta 
    -- Desconto de cheque e titulo ativo e cancelado
    AND  ((nrc.tpctrrat IN (2,3) AND lim.insitlim IN (2,3))
    -- Limite de crédito ativo
    OR    (nrc.tpctrrat = 1 AND lim.insitlim = 2))
    AND    nrc.cdcooper = pr_cdcooper;


  --Cursor para buscar Bordero do rating por contrato
  CURSOR cr_craplim(pr_cdcooper IN crapcop.cdcooper%TYPE) IS  
    -- Bordero de Cheques
    SELECT opr.cdcooper                    cdcooper          -- Codigo que identifica a Cooperativa.
          ,opr.nrdconta                    nrdconta          -- Numero da conta/dv do associado.
          ,bdc.nrborder                    nrctremp          -- Numero do contrato da operacao que gera rating.
          ,92                              tpctrato          -- Tipo de contrato da operacao que gera rating
          ,opr.inrisco_rating_autom        inrisco_rating    -- Indicador de risco
          ,Nvl(bdc.dtrefatu,bdc.dtmvtolt)  dteftrat          -- Data de efetivacao do rating.
          ,opr.cdoperad_rating             cdoperad_rating   -- Codigo do operador
          ,opr.insituacao_rating           insituacao_rating -- Situacao do rating (4-Efetivado)
          ,opr.inpontos_rating             inpontos_rating   -- Nota atingida na soma dos itens do rating
          ,ass.nrcpfcnpj_base              nrcpfcnpj_base    -- Numero do CPF/CNPJ Base do associado
          ,ass.inpessoa                    inpessoa          -- Tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
          ,2                               innivel_rating    -- Nível de Risco (2-NIVEL MEDIO)
    FROM   crapbdc            bdc
          ,tbrisco_operacoes  opr
          ,crapass            ass
          ,craplim            lim
    WHERE  lim.cdcooper = pr_cdcooper
    AND    lim.cdcooper = opr.cdcooper
    AND    lim.nrdconta = opr.nrdconta
    AND    lim.nrctrlim = opr.nrctremp
    AND    opr.tpctrato = 2   
    AND    lim.tpctrlim = opr.tpctrato
    AND    bdc.cdcooper = opr.cdcooper
    AND    bdc.nrdconta = opr.nrdconta
    AND    bdc.nrctrlim = lim.nrctrlim 
    AND    bdc.insitbdc <> 5 
    AND    bdc.dtrejeit IS NULL
    AND    bdc.cdcooper = ass.cdcooper
    AND    bdc.nrdconta = ass.nrdconta
    UNION
    -- Bordero de Titulos
    SELECT opr.cdcooper                    cdcooper          -- Codigo que identifica a Cooperativa.
          ,opr.nrdconta                    nrdconta          -- Numero da conta/dv do associado.
          ,bdt.nrborder                    nrctremp          -- Numero do contrato da operacao que gera rating.
          ,91                              tpctrato          -- Tipo de contrato da operacao que gera rating
          ,opr.inrisco_rating_autom        inrisco_rating    -- Indicador de risco
          ,nvl(bdt.dtrefatu,bdt.dtmvtolt)  dteftrat          -- Data de efetivacao do rating.
          ,opr.cdoperad_rating             cdoperad_rating   -- Codigo do operador
          ,opr.insituacao_rating           insituacao_rating -- Situacao do rating (4-Efetivado)
          ,opr.inpontos_rating             inpontos_rating   -- Nota atingida na soma dos itens do rating
          ,ass.nrcpfcnpj_base              nrcpfcnpj_base    -- Numero do CPF/CNPJ Base do associado
          ,ass.inpessoa                    inpessoa          -- Tipo de pessoa (1 - fisica, 2 - juridica, 3 - cheque adm.).
          ,2                               innivel_rating    -- Nível de Risco (2-NIVEL MEDIO)
    FROM   crapbdt bdt
          ,tbrisco_operacoes opr
          ,crapass ass
          ,craplim lim
    WHERE  lim.cdcooper = pr_cdcooper
    AND    lim.cdcooper = opr.cdcooper
    AND    lim.nrdconta = opr.nrdconta
    AND    lim.nrctrlim = opr.nrctremp
    AND    opr.tpctrato = 3   
    AND    lim.tpctrlim = opr.tpctrato
    AND    bdt.cdcooper = opr.cdcooper
    AND    bdt.nrdconta = opr.nrdconta
    AND    bdt.nrctrlim = lim.nrctrlim
    AND    bdt.insitbdt <> 5 
    AND    bdt.dtrejeit IS NULL
    AND    bdt.cdcooper = ass.cdcooper
    AND    bdt.nrdconta = ass.nrdconta;
    
    
  --Cursor para buscar Crédito Pré-Aprovado
  CURSOR cr_crapcpa(pr_cdcooper IN crapcpa.cdcooper%TYPE
                   ,pr_dtmvtolt IN crapcpa.dtmvtolt%TYPE) IS  
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
    FROM   crapcpa               cpa
          ,tbepr_carga_pre_aprv  carga
    WHERE  cpa.cdcooper             = carga.cdcooper
    AND    cpa.iddcarga             = carga.idcarga
    AND    carga.indsituacao_carga  = 2   --Carga Liberada
    AND    carga.flgcarga_bloqueada = 0   --Carga Não Bloqueada
    AND    Nvl(carga.dtfinal_vigencia,Trunc(SYSDATE)) >= Trunc(pr_dtmvtolt) --Carga Vigente
    AND    cpa.cdsituacao           = 'A' --Aceita  
    AND    cpa.cdcooper             = pr_cdcooper;
    
    
  --Cursor para buscar Limite Crédito, Desconto Cheque, Desconto Título e Empréstimo Sem Rating
  CURSOR cr_crapris(pr_cdcooper IN crapris.cdcooper%TYPE
                   ,pr_dtmvtoan IN crapris.dtrefere%TYPE) IS  
    SELECT r.cdcooper                  cdcooper          --Codigo que identifica a Cooperativa
          ,r.nrdconta                  nrdconta          --Numero da conta/dv do associado
          ,r.nrctremp                  nrctremp          --Numero do contrato da operacao que gera rating
          ,Decode(r.cdmodali,1901, 1  
                            , 302, 2
                            , 301, 3
                            , 499,90
                            , 299,90)  tpctrato          --Tipo de contrato da operacao que gera rating
          ,NULL                        inrisco_rating    --Indicador de risco (AA ate HH)
          ,r.dtrefere                  dteftrat          --Data de efetivacao do rating
          ,'1'                         cdoperad_rating   --Codigo do operador
          ,3                           insituacao_rating --Situacao do rating (3-Vencido)
          ,NULL                        inpontos_rating   --Nota atingida na soma dos itens do rating
          ,a.nrcpfcnpj_base            nrcpfcnpj_base    --Numero do CPF/CNPJ Base do associado
          ,a.inpessoa                  inpessoa          --Tipo Pessoa
          ,NULL                        innivel_rating    --Nível de Risco
          ,3                           inorigem_rating   --Origem do Rating (3-Regra Aimaro)
          ,1                           flintegrar_sas    --Flag para indicar se o contrato deve integrar com o SAS
    FROM   crapris  r
          ,crapass  a    
    WHERE  r.cdcooper = a.cdcooper
    AND    r.nrdconta = a.nrdconta
    AND    r.cdmodali IN (1901,302,301,499,299) --Limite Crédito(1901), Desconto Cheque(302), Desconto Título(301) e Empréstimo(499,299)
    AND    NOT EXISTS (SELECT 1
                       FROM   crapnrc  n
                       WHERE  n.cdcooper = r.cdcooper
                       AND    n.nrdconta = r.nrdconta
                       AND    n.nrctrrat = r.nrctremp
                       AND    n.tpctrrat = Decode(r.cdmodali,1901, 1  
                                                  , 302, 2
                                                  , 301, 3
                                                  , 499,90
                                                  , 299,90)) --Limite Crédito(1), Desconto Cheque(2), Desconto Título(3) e Empréstimo(90)
    AND    r.dtrefere = pr_dtmvtoan
    AND    r.cdcooper = pr_cdcooper;

  --------------------
  --    VARIAVEIS   --
  --------------------
  vr_qtregsalva    NUMBER(6) := 1000; --Qtde de registros para salvar
  --
  vr_exc_erro      EXCEPTION;
  vr_dscritic      VARCHAR2(1000);
  vr_insituacao    crapnrc.insitrat%TYPE := 0;
  vr_sequencia     tbrating_historicos.nrseq_operacao%TYPE;
  vr_integrar_sas  NUMBER := 0;
  vr_qtde_reg      NUMBER := 0;
  vr_insert        VARCHAR2(1) := 'N';
  vr_update        VARCHAR2(1) := 'N'; 
  vr_nrdconta      crapass.nrdconta%TYPE;
  vr_nrctremp      crapris.nrctremp%TYPE;
  vr_inpessoa      crapass.inpessoa%TYPE;   
    
BEGIN
  --------------------
  --     INICIO     --
  --------------------

  /**********Atualização CPF/CNPJ**********/
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
        
    vr_qtde_reg := 0;
    -- Buscar todos os registros tbrisco_operacoes
    FOR rw_tbrisco_operacoes IN cr_tbrisco_operacoes(pr_cdcooper => rw_crapcop.cdcooper) LOOP  
      --Incrementa Qtde de Registros a serem salvos
      vr_qtde_reg := Nvl(vr_qtde_reg,0) + 1; 
       
      --Atualizar CPF/CNPJ 
      BEGIN
        UPDATE tbrisco_operacoes  opr
           SET opr.nrcpfcnpj_base = rw_tbrisco_operacoes.nrcpfcnpj_base
              ,opr.inpessoa       = rw_tbrisco_operacoes.inpessoa
         WHERE opr.cdcooper       = rw_tbrisco_operacoes.cdcooper
           AND opr.nrdconta       = rw_tbrisco_operacoes.nrdconta;
      EXCEPTION
        WHEN OTHERS THEN         
          vr_dscritic := 'Erro ao Atualizar CPF/CNPJ Base na TBRISCO_OPERACOES. Cooperativa: '||rw_tbrisco_operacoes.cdcooper||' | Conta: '||rw_tbrisco_operacoes.nrdconta||' | CPF/CNPJ Base: '||rw_tbrisco_operacoes.nrcpfcnpj_base||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro; 
      END;
      
      -- Salva a cada (X) qtde de registros
      IF Nvl(vr_qtde_reg,0) = Nvl(vr_qtregsalva,0) THEN
        vr_qtde_reg := 0;
        --Salva
        COMMIT;
      END IF;
    END LOOP;
    
    -- Salva (Por Cooperativa)
    COMMIT;
  END LOOP;
  --
  --
  --
  /**********Empréstimos, Limite Credito, Desconto Titulo, Desconto Cheque**********/
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
    
    vr_qtde_reg := 0;    
    -- Para cada registro da CRAPNCR
    FOR rw_crapnrc IN cr_crapnrc(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      --Incrementa Qtde de Registros a serem salvos
      vr_qtde_reg := Nvl(vr_qtde_reg,0) + 1; 
      
      -- Data de Vencimento menor que data do Dia
      IF rw_crapnrc.dtvenc_rat < rw_crapdat.dtmvtopr AND rw_crapnrc.insituacao_rating = 4 THEN
        -- Rating está vencido
        vr_insituacao := 3; -- 3-Vencido/Expirado
      ELSE
        vr_insituacao := rw_crapnrc.insituacao_rating;
      END IF;
      
      -- Se PROPOSTO, vai no 1o lote, se nao, vai qundo vencer (Guilherme/AMcom)
      IF rw_crapnrc.insituacao_rating = 2 THEN
        vr_integrar_sas := 1;
      ELSE
        vr_integrar_sas := 0;
      END IF;
      
      --Insere na tbrisco_operacoes
      vr_insert := 'N';
      vr_update := 'N';
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
             ,insegmento_rating
             ,inrisco_rat_inc
             ,innivel_rat_inc
             ,inpontos_rat_inc
             ,insegmento_rat_inc
             ,flintegrar_sas)
        VALUES 
             (rw_crapnrc.cdcooper                                                   -- CDCOOPER
             ,rw_crapnrc.nrdconta                                                   -- NRDCONTA
             ,rw_crapnrc.nrctremp                                                   -- NRCTREMP
             ,rw_crapnrc.tpctrato                                                   -- TPCTRATO
             ,NULL                                                                  -- INRISCO_INCLUSAO
             ,NULL                                                                  -- INRISCO_CALCULADO
             ,NULL                                                                  -- INRISCO_MELHORA
             ,NULL                                                                  -- DTRISCO_MELHORA
             ,NULL                                                                  -- CDCRITICA_MELHORA
             ,Decode(rw_crapnrc.insituacao_rating,2,NULL,rw_crapnrc.inrisco_rating) -- INRISCO_RATING
             ,rw_crapnrc.inrisco_rating                                             -- INRISCO_RATING_AUTOM
             ,Decode(rw_crapnrc.insituacao_rating,2,NULL,rw_crapnrc.dteftrat)       -- DTRISCO_RATING 
             ,vr_insituacao                                                         -- INSITUACAO_RATING  2-Proposto, 3-Vencido/Expirado, 4-Efetivado
             ,3                                                                     -- INORIGEM_RATING    3-Regra Aimaro
             ,rw_crapnrc.cdoperad_rating                                            -- CDOPERAD_RATING
             ,rw_crapnrc.dteftrat                                                   -- DTRISCO_RATING_AUTOM
             ,rw_crapnrc.innivel_rating                                             -- INNIVEL_RATING
             ,rw_crapnrc.nrcpfcnpj_base                                             -- NRCPFCNPJ_BASE
             ,rw_crapnrc.inpessoa                                                   -- INPESSOA
             ,rw_crapnrc.inpontos_rating                                            -- INPONTOS_RATING
             ,NULL                                                                  -- INSEGMENTO_RATING
             ,NULL                                                                  -- INRISCO_RAT_INC
             ,NULL                                                                  -- INNIVEL_RAT_INC
             ,NULL                                                                  -- INPONTOS_RAT_INC
             ,NULL                                                                  -- INSEGMENTO_RAT_INC
             ,vr_integrar_sas) ;                                                    -- Indicar se integra SAS (conforme definicao, quem for PROPOSTO deve ir na primeira carga do lote, por isso, "1" nesse campo quando PROPOSTO - Guilherme/AMcom)        
        IF SQL%ROWCOUNT > 0 THEN           
          vr_insert     := 'S';
        END IF;         
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          BEGIN
            UPDATE tbrisco_operacoes opr
            SET    opr.insituacao_rating    = vr_insituacao
                  ,opr.cdoperad_rating      = rw_crapnrc.cdoperad_rating
                  ,opr.inrisco_rating       = Decode(rw_crapnrc.insituacao_rating,2,NULL,rw_crapnrc.inrisco_rating)
                  ,opr.inrisco_rating_autom = rw_crapnrc.inrisco_rating
                  ,opr.dtrisco_rating       = Decode(rw_crapnrc.insituacao_rating,2,NULL,rw_crapnrc.dteftrat)
                  ,opr.dtrisco_rating_autom = rw_crapnrc.dteftrat
                  ,opr.innivel_rating       = rw_crapnrc.innivel_rating
                  ,opr.nrcpfcnpj_base       = rw_crapnrc.nrcpfcnpj_base
                  ,opr.inpessoa             = rw_crapnrc.inpessoa
                  ,opr.inpontos_rating      = rw_crapnrc.inpontos_rating
                  ,opr.flintegrar_sas       = vr_integrar_sas  
            WHERE  opr.cdcooper             = rw_crapnrc.cdcooper
            AND    opr.nrdconta             = rw_crapnrc.nrdconta
            AND    opr.nrctremp             = rw_crapnrc.nrctremp
            AND    opr.tpctrato             = rw_crapnrc.tpctrato;
            IF SQL%ROWCOUNT > 0 THEN
              vr_update := 'S';
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao Atualizar a TBRISCO_OPERACOES (Emprestimo/Limite/Desconto). Cooperativa: '||rw_crapnrc.cdcooper||' | Conta: '||rw_crapnrc.nrdconta||' | Contrato: '||rw_crapnrc.nrctremp||' | Tipo: '||rw_crapnrc.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Inserir na TBRISCO_OPERACOES (Emprestimo/Limite/Desconto). Cooperativa: '||rw_crapnrc.cdcooper||' | Conta: '||rw_crapnrc.nrdconta||' | Contrato: '||rw_crapnrc.nrctremp||' | Tipo: '||rw_crapnrc.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro;
      END;
     
             
      -- Se fez INSERT ou UPDATE para os contratos de Empréstimo
      IF (Nvl(vr_insert,'N') = 'S' OR Nvl(vr_update,'N') = 'S') 
        AND rw_crapnrc.tpctrato = 90 THEN
        
        -- Busca Novo Sequencial
        OPEN cr_tbrating_historicos(pr_cdcooper => rw_crapnrc.cdcooper
                                   ,pr_nrdconta => rw_crapnrc.nrdconta
                                   ,pr_nrctro   => rw_crapnrc.nrctremp
                                   ,pr_tpctrato => rw_crapnrc.tpctrato);
        FETCH cr_tbrating_historicos
        INTO vr_sequencia;
        CLOSE cr_tbrating_historicos;
          
        -- Insere o Histórico do Rating
        BEGIN
          INSERT INTO tbrating_historicos
              (cdcooper
              ,nrdconta
              ,nrctremp
              ,tpctrato
              ,nrseq_operacao
              ,dthr_operacao
              ,cdoperador_operacao
              ,tpoperacao_rating
              ,vloperacao
              ,inrisco_rating
              ,dtrisco_rating
              ,inrisco_rating_autom
              ,dtrisco_rating_autom
              ,inrisco_rating_novo
              ,dtrisco_rating_novo
              ,dsxml_param_rating
              ,ds_justificativa
              ,flefetivacao)
          VALUES
              (rw_crapnrc.cdcooper        -- cdcooper
              ,rw_crapnrc.nrdconta        -- nrdconta
              ,rw_crapnrc.nrctremp        -- nrctremp
              ,rw_crapnrc.tpctrato        -- tpctrato
              ,vr_sequencia               -- nrseq_operacao
              ,rw_crapdat.dtmvtolt        -- dthr_operacao
              ,rw_crapnrc.cdoperad_rating -- cdoperador_operacao
              ,0                          -- tpoperacao_rating  0--> carga inicial / 1--> alteração do rating / 2 efetivação rating
              ,NULL                       -- vloperacao
              ,Decode(rw_crapnrc.insituacao_rating,2,NULL,rw_crapnrc.inrisco_rating) -- inrisco_rating
              ,Decode(rw_crapnrc.insituacao_rating,2,NULL,rw_crapnrc.dteftrat)       -- dtrisco_rating
              ,rw_crapnrc.inrisco_rating  -- inrisco_rating_autom
              ,rw_crapnrc.dteftrat        -- dtrisco_rating_autom
              ,NULL                       -- inrisco_rating_novo 
              ,NULL                       -- dtrisco_rating_novo
              ,NULL                       -- dsxml_param_rating
              ,'Carga Inicial:'  ||
                ' CPF/CNPJ: '    || rw_crapnrc.nrcpfcnpj_base ||
                ' Integra SAS: ' || Decode(rw_crapnrc.insituacao_rating,2,'SIM','NAO')            -- ds_justificativa  
              ,rw_crapnrc.insitrat);      -- flefetivacao
        EXCEPTION
          WHEN OTHERS THEN          
            vr_dscritic := 'Erro ao Inserir na TBRATING_HISTORICOS (Emprestimo). Cooperativa: '||rw_crapnrc.cdcooper||' | Conta: '||rw_crapnrc.nrdconta||' | Contrato: '||rw_crapnrc.nrctremp||' | Tipo: '||rw_crapnrc.tpctrato||' | Seq.Operacao: '||vr_sequencia||'. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_exc_erro;   
        END;
      END IF;
      
      -- Salva a cada (X) qtde de registros
      IF Nvl(vr_qtde_reg,0) = Nvl(vr_qtregsalva,0) THEN
        vr_qtde_reg := 0;
        --Salva
        COMMIT;
      END IF;
    END LOOP; --Loop CRAPNCR  
    
    -- Salva (Por Cooperativa)
    COMMIT;
  END LOOP; 
  --
  --
  --
  /**********Bordero de Cheque e Bordero de Títulos**********/
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
    
    vr_qtde_reg := 0;    
    -- Buscar todos os registros
    FOR rw_craplim IN cr_craplim(pr_cdcooper => rw_crapcop.cdcooper) LOOP
      --Incrementa Qtde de Registros a serem salvos
      vr_qtde_reg := Nvl(vr_qtde_reg,0) + 1; 
    
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
             ,insegmento_rating
             ,inrisco_rat_inc
             ,innivel_rat_inc
             ,inpontos_rat_inc
             ,insegmento_rat_inc)
        VALUES 
             (rw_craplim.cdcooper          -- CDCOOPER
             ,rw_craplim.nrdconta          -- NRDCONTA
             ,rw_craplim.nrctremp          -- NRCTREMP
             ,rw_craplim.tpctrato          -- TPCTRATO
             ,NULL                         -- INRISCO_INCLUSAO
             ,NULL                         -- INRISCO_CALCULADO
             ,NULL                         -- INRISCO_MELHORA
             ,NULL                         -- DTRISCO_MELHORA
             ,NULL                         -- CDCRITICA_MELHORA
             ,rw_craplim.inrisco_rating    -- INRISCO_RATING
             ,rw_craplim.inrisco_rating    -- INRISCO_RATING_AUTOM
             ,rw_craplim.dteftrat          -- DTRISCO_RATING
             ,rw_craplim.insituacao_rating -- INSITUACAO_RATING 2-Proposto, 4-Efetivado
             ,3                            -- INORIGEM_RATING 3-Regra Aimaro
             ,rw_craplim.cdoperad_rating   -- CDOPERAD_RATING
             ,rw_craplim.dteftrat          -- DTRISCO_RATING_AUTOM
             ,rw_craplim.innivel_rating    -- INNIVEL_RATING
             ,rw_craplim.nrcpfcnpj_base    -- NRCPFCNPJ_BASE
             ,rw_craplim.inpessoa          -- INPESSOA
             ,rw_craplim.inpontos_rating   -- INPONTOS_RATING
             ,NULL                         -- INSEGMENTO_RATING
             ,NULL                         -- INRISCO_RAT_INC
             ,NULL                         -- INNIVEL_RAT_INC
             ,NULL                         -- INPONTOS_RAT_INC
             ,NULL);                       -- INSEGMENTO_RAT_INC
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          BEGIN
            UPDATE tbrisco_operacoes opr
            SET    opr.insituacao_rating    = rw_craplim.insituacao_rating  -- 2-proposto, 4-efetivado
                  ,opr.cdoperad_rating      = rw_craplim.cdoperad_rating
                  ,opr.inrisco_rating       = rw_craplim.inrisco_rating
                  ,opr.inrisco_rating_autom = rw_craplim.inrisco_rating
                  ,opr.dtrisco_rating       = rw_craplim.dteftrat
                  ,opr.dtrisco_rating_autom = rw_craplim.dteftrat
                  ,opr.innivel_rating       = rw_craplim.innivel_rating
                  ,opr.nrcpfcnpj_base       = rw_craplim.nrcpfcnpj_base
                  ,opr.inpessoa             = rw_craplim.inpessoa
                  ,opr.inpontos_rating      = rw_craplim.inpontos_rating
            WHERE  opr.cdcooper             = rw_craplim.cdcooper
            AND    opr.nrdconta             = rw_craplim.nrdconta
            AND    opr.nrctremp             = rw_craplim.nrctremp
            AND    opr.tpctrato             = rw_craplim.tpctrato;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao Atualizar a TBRISCO_OPERACOES (Bordero). Cooperativa: '||rw_craplim.cdcooper||' | Conta: '||rw_craplim.nrdconta||' | Contrato: '||rw_craplim.nrctremp||' | Tipo: '||rw_craplim.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Inserir na TBRISCO_OPERACOES (Bordero). Cooperativa: '||rw_craplim.cdcooper||' | Conta: '||rw_craplim.nrdconta||' | Contrato: '||rw_craplim.nrctremp||' | Tipo: '||rw_craplim.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro;
      END;
      
      -- Salva a cada (X) qtde de registros
      IF Nvl(vr_qtde_reg,0) = Nvl(vr_qtregsalva,0) THEN
        vr_qtde_reg := 0;
        --Salva
        COMMIT;
      END IF;
    END LOOP;
    
    -- Salva (Por Cooperativa)
    COMMIT;
  END LOOP;
  --
  --
  --
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
    
    vr_qtde_reg := 0;    
    -- Para cada Crédito Pré-Aprovado
    FOR rw_crapcpa IN cr_crapcpa(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
      --Incrementa Qtde de Registros a serem salvos
      vr_qtde_reg := Nvl(vr_qtde_reg,0) + 1;
      
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
          BEGIN
            UPDATE tbrisco_operacoes opr
            SET    opr.insituacao_rating    = rw_crapcpa.insituacao_rating
                  ,opr.cdoperad_rating      = rw_crapcpa.cdoperad_rating
                  ,opr.inrisco_rating       = rw_crapcpa.inrisco_rating
                  ,opr.inrisco_rating_autom = rw_crapcpa.inrisco_rating
                  ,opr.dtrisco_rating       = Decode(rw_crapcpa.insituacao_rating,3,NULL,rw_crapcpa.dteftrat)
                  ,opr.dtrisco_rating_autom = rw_crapcpa.dteftrat
                  ,opr.innivel_rating       = rw_crapcpa.innivel_rating
                  ,opr.nrcpfcnpj_base       = rw_crapcpa.nrcpfcnpj_base
                  ,opr.inpessoa             = vr_inpessoa
                  ,opr.inpontos_rating      = rw_crapcpa.inpontos_rating
                  ,opr.flintegrar_sas       = rw_crapcpa.flintegrar_sas
            WHERE  opr.cdcooper             = rw_crapcpa.cdcooper
            AND    opr.nrcpfcnpj_base       = rw_crapcpa.nrcpfcnpj_base --Pre-Aprovado é por CNPJ Base e não por Conta
            AND    opr.nrctremp             = rw_crapcpa.nrctremp
            AND    opr.tpctrato             = rw_crapcpa.tpctrato;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao Atualizar a TBRISCO_OPERACOES (Pre-Aprovado). Cooperativa: '||rw_crapcpa.cdcooper||' | CPF/CNPJ Base: '||rw_crapcpa.nrcpfcnpj_base||' | Contrato: '||rw_crapcpa.nrctremp||' | Tipo: '||rw_crapcpa.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Inserir na TBRISCO_OPERACOES (Pre-Aprovado). Cooperativa: '||rw_crapcpa.cdcooper||' | Conta: '||rw_crapcpa.nrdconta||' | CPF/CNPJ Base: '||rw_crapcpa.nrcpfcnpj_base||' | Contrato: '||rw_crapcpa.nrctremp||' | Tipo: '||rw_crapcpa.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro;
      END;      
    
      -- Salva a cada (X) qtde de registros
      IF Nvl(vr_qtde_reg,0) = Nvl(vr_qtregsalva,0) THEN
        vr_qtde_reg := 0;
        --Salva
        COMMIT;
      END IF;
    END LOOP; --Créditos Pré-Aprovado
  
    -- Salva (Por Cooperativa)
    COMMIT;
  END LOOP; -- Cooperativas
  --
  --
  --
  /**********(SEM RATING) Limite Crédito, Desconto Cheque, Desconto Título e Empréstimo (SEM RATING)**********/
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
    
    vr_qtde_reg := 0;    
    -- Para cada Limite Crédito, Desconto Cheque, Desconto Título e Empréstimo Sem Rating
    FOR rw_crapris IN cr_crapris(pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_dtmvtoan => rw_crapdat.dtmvtoan) LOOP
      --Incrementa Qtde de Registros a serem salvos
      vr_qtde_reg := Nvl(vr_qtde_reg,0) + 1; 
      
      --26/08/2019 - Marcelo Elias Gonçalves/AMcom     
      --Quando Desconto de Titulo e Desconto de Cheque, buscar o Contrato do Limite
      IF rw_crapris.tpctrato = 3 THEN --Desconto Titulo(301)
        BEGIN
          SELECT a.nrctrlim
          INTO   vr_nrctremp
          FROM   crapbdt  a 
          WHERE  a.cdcooper = rw_crapris.cdcooper
          AND    a.nrborder = rw_crapris.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao Buscar Nro Contrato Limite - Desconto Titulo (Contratos Sem Rating). Cooperativa: '||rw_crapris.cdcooper||' | Bordero: '||rw_crapris.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_exc_erro; 
        END;    
      ELSIF rw_crapris.tpctrato = 2 THEN --Desconto Cheque(302)
        BEGIN
          SELECT a.nrctrlim
          INTO   vr_nrctremp
          FROM   crapbdc  a
          WHERE  a.cdcooper = rw_crapris.cdcooper
          AND    a.nrborder = rw_crapris.nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao Buscar Nro Contrato Limite - Desconto Cheque (Contratos Sem Rating). Cooperativa: '||rw_crapris.cdcooper||' | Bordero: '||rw_crapris.nrctremp||'. Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_exc_erro; 
        END;
      ELSE --Limite de Crédito(1901) e Empréstimo(499,299)
        vr_nrctremp := rw_crapris.nrctremp;
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
             (rw_crapris.cdcooper                                             -- CDCOOPER
             ,rw_crapris.nrdconta                                             -- NRDCONTA
             ,vr_nrctremp                                                     -- NRCTREMP
             ,rw_crapris.tpctrato                                             -- TPCTRATO
             ,NULL                                                            -- INRISCO_INCLUSAO
             ,NULL                                                            -- INRISCO_CALCULADO
             ,NULL                                                            -- INRISCO_MELHORA
             ,NULL                                                            -- DTRISCO_MELHORA
             ,NULL                                                            -- CDCRITICA_MELHORA
             ,rw_crapris.inrisco_rating                                       -- INRISCO_RATING       (Sempre NULL no cursor)
             ,rw_crapris.inrisco_rating                                       -- INRISCO_RATING_AUTOM (Sempre NULL no cursor)
             ,Decode(rw_crapris.insituacao_rating,3,NULL,rw_crapris.dteftrat) -- DTRISCO_RATING       (Nulo quando Vencido - insituacao_rating=3)
             ,rw_crapris.insituacao_rating                                    -- INSITUACAO_RATING    (Sempre 3 no cursor) --3=Vencido
             ,rw_crapris.inorigem_rating                                      -- INORIGEM_RATING      (Sempre 3 no cursor) --3=Regra Aimaro
             ,rw_crapris.cdoperad_rating                                      -- CDOPERAD_RATING      (Sempre 1 no cursor)
             ,rw_crapris.dteftrat                                             -- DTRISCO_RATING_AUTOM
             ,rw_crapris.innivel_rating                                       -- INNIVEL_RATING       (Sempre NULL no cursor)
             ,rw_crapris.nrcpfcnpj_base                                       -- NRCPFCNPJ_BASE
             ,rw_crapris.inpessoa                                             -- Tipo Pessoa
             ,rw_crapris.inpontos_rating                                      -- INPONTOS_RATING      (Sempre NULL no cursor)
             ,rw_crapris.flintegrar_sas                                       -- FLINTEGRAR_SAS       (Sempre 1 no cursor)
             ,NULL                                                            -- INSEGMENTO_RATING
             ,NULL                                                            -- INRISCO_RAT_INC
             ,NULL                                                            -- INNIVEL_RAT_INC
             ,NULL                                                            -- INPONTOS_RAT_INC
             ,NULL);                                                          -- INSEGMENTO_RAT_INC
      EXCEPTION
        WHEN Dup_Val_On_Index THEN
          BEGIN
            UPDATE tbrisco_operacoes opr
            SET    opr.insituacao_rating    = rw_crapris.insituacao_rating
                  ,opr.cdoperad_rating      = rw_crapris.cdoperad_rating
                  ,opr.inrisco_rating       = rw_crapris.inrisco_rating
                  ,opr.inrisco_rating_autom = rw_crapris.inrisco_rating
                  ,opr.dtrisco_rating       = Decode(rw_crapris.insituacao_rating,3,NULL,rw_crapris.dteftrat)
                  ,opr.dtrisco_rating_autom = rw_crapris.dteftrat
                  ,opr.innivel_rating       = rw_crapris.innivel_rating
                  ,opr.nrcpfcnpj_base       = rw_crapris.nrcpfcnpj_base
                  ,opr.inpessoa             = rw_crapris.inpessoa
                  ,opr.inpontos_rating      = rw_crapris.inpontos_rating
                  ,opr.flintegrar_sas       = rw_crapris.flintegrar_sas
            WHERE  opr.cdcooper             = rw_crapris.cdcooper
            AND    opr.nrdconta             = rw_crapris.nrdconta
            AND    opr.nrctremp             = vr_nrctremp
            AND    opr.tpctrato             = rw_crapris.tpctrato;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao Atualizar a TBRISCO_OPERACOES (Contratos Sem Rating). Cooperativa: '||rw_crapris.cdcooper||' | Conta: '||rw_crapris.nrdconta||' | Contrato: '||rw_crapris.nrctremp||' | Tipo: '||rw_crapris.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
              RAISE vr_exc_erro;
          END;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao Inserir na TBRISCO_OPERACOES (Contratos Sem Rating). Cooperativa: '||rw_crapris.cdcooper||' | Conta: '||rw_crapris.nrdconta||' | Contrato: '||rw_crapris.nrctremp||' | Tipo: '||rw_crapris.tpctrato||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_exc_erro;
      END;    
    
      -- Salva a cada (X) qtde de registros
      IF Nvl(vr_qtde_reg,0) = Nvl(vr_qtregsalva,0) THEN
        vr_qtde_reg := 0;
        --Salva
        COMMIT;
      END IF;
    END LOOP; --Contratos Sem Rating

    -- Salva (Por Cooperativa)
    COMMIT;
  END LOOP; -- Cooperativas
  --
  --
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
