CREATE OR REPLACE PROCEDURE CECRED.pc_processa_preposto(pr_dscritic  OUT VARCHAR2) IS          /* RETORNO DA CRITICA */
    
    /*********************************************************************
    **                                                                  **
    ** PROGRAMA: ROTINA PARA VALIDAR INFORMAÇÕES DOS PREPOSTOS E AJUSTAR**
    ** AUTOR: MÁRCIO (MOUTS)                                            **
    ** DATA CRIAÇÃO: 05/06/2019                                         **
    ** DATA MODIFICAÇÃO:                                                **
    ** SISTEMA: Ailos - Chamada via JOB                                 **
    **                                                                  **
    *********************************************************************/
    
    CURSOR PREPOSTO_A_INCLUIR IS
      SELECT 
             DISTINCT CRAPPOD.CDCOOPER,
                      CRAPPOD.NRCPFPRO,
                      CRAPPOD.NRDCONTA
        FROM 
             CRAPPOD
       WHERE 
             CRAPPOD.CDDPODER = 10 -- Poder de assinatura conjunta          
         AND CRAPPOD.FLGCONJU = 1 -- 'Poder em conjunto? Sim/Nao' = 1 - Sim
         -- Existe registro na tbcc_operad_aprov para outro preposto, ou seja, existe pendência de aprovação
         -- IMPORTANTE: Primeiro verifica se já existe registro na tabela tbcc_operad_aprov, pois pode ser que 
         -- nenum registro tenha sido inserido por se tratar do primeiro cadastramento (só irá ocorrer quando acessar o preposto IB e cadastrar o operador)
         -- e também precisamos dos dados dos registros existente para inserir o novo registro com os valores.
         AND EXISTS (SELECT
                           1
                      FROM 
                           TBCC_OPERAD_APROV T
                      WHERE
                           T.CDCOOPER = CRAPPOD.CDCOOPER
                       AND T.NRDCONTA = CRAPPOD.NRDCONTA
                       AND T.NRCPF_PREPOSTO <> CRAPPOD.NRCPFPRO) 
         -- Não existe registro na tbcc_operad_aprov para o preposto, ou seja, falta incluir o registro
         AND NOT EXISTS (SELECT
                               1
                           FROM 
                               TBCC_OPERAD_APROV T
                          WHERE
                               T.CDCOOPER = CRAPPOD.CDCOOPER
                           AND T.NRDCONTA = CRAPPOD.NRDCONTA
                           AND T.NRCPF_PREPOSTO = CRAPPOD.NRCPFPRO)
      ORDER BY CRAPPOD.CDCOOPER,CRAPPOD.NRCPFPRO,CRAPPOD.NRDCONTA;        

    CURSOR DADOS_OPERAD_APROV(PR_CDCOOPER IN NUMBER,
                              PR_NRDCONTA IN NUMBER,    
                              PR_NRCPFPRO IN NUMBER) IS
    SELECT
          DISTINCT 
                  T.CDCOOPER,
                  T.NRDCONTA,
                  T.NRCPF_OPERADOR,
                  PR_NRCPFPRO NRCPF_PREPOSTO,
                  0 FLGAPROVADO,
                  NULL DHAPROVACAO,
                  T.VLLIMITE_PAGTO,
                  T.VLLIMITE_TRANSF,
                  T.VLLIMITE_TED,
                  T.VLLIMITE_VRBOLETO,
                  T.VLLIMITE_FOLHA
      FROM 
          TBCC_OPERAD_APROV T
     WHERE
          T.CDCOOPER = PR_CDCOOPER
      AND T.NRDCONTA = PR_NRDCONTA
      AND T.NRCPF_PREPOSTO <> PR_NRCPFPRO
      -- E que o operador não exista na tabela de operadores de internet
      AND NOT EXISTS (SELECT
                            1
                        FROM
                            CRAPOPI
                       WHERE
                            CRAPOPI.CDCOOPER = T.CDCOOPER
                        AND CRAPOPI.NRDCONTA = T.NRDCONTA
                        AND CRAPOPI.NRCPFOPE = T.NRCPF_OPERADOR);
    
    CURSOR PREPOSTO_A_APROVAR IS
      SELECT
            T.CDCOOPER,
            T.NRDCONTA,
            T.NRCPF_PREPOSTO,
            T.NRCPF_OPERADOR,
            S.IDSEQTTL
        FROM 
            TBCC_OPERAD_APROV t,
            CRAPSNH S
      WHERE 
          -- Só irá retornar regiostros se todos os prepostos já aprovaram o operador
          NOT EXISTS (SELECT
                            1
                        FROM
                            TBCC_OPERAD_APROV T2
                       WHERE  
                             T2.CDCOOPER       = T.CDCOOPER
                         AND T2.NRDCONTA       = T.NRDCONTA
                         AND T2.NRCPF_OPERADOR = T.NRCPF_OPERADOR
                         AND T2.FLGAPROVADO    = 0)
          AND S.CDCOOPER = T.CDCOOPER
          AND S.NRDCONTA = T.NRDCONTA
          AND S.NRCPFCGC = T.NRCPF_PREPOSTO
          AND ROWNUM = 1
      order by 1,2,3,4;

    CURSOR cr_limites_temp(pr_cdcooper crapass.cdcooper%TYPE,
                           pr_nrdconta crapass.nrdconta%TYPE,
                           pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT t.vllimite_folha,
               t.vllimite_pagto,
               t.vllimite_ted,
               t.vllimite_transf,
               t.vllimite_vrboleto
        FROM CECRED.TBCC_OPERAD_APROV t
        WHERE t.cdcooper = pr_cdcooper       AND
              t.nrdconta = pr_nrdconta       AND
              t.nrcpf_operador = pr_nrcpfope AND
              t.flgaprovado = 1              AND
              ROWNUM = 1;
        rw_limites_temp cr_limites_temp%ROWTYPE;
      
    CURSOR cr_crapopi (pr_cdcooper crapopi.cdcooper%TYPE,
                       pr_nrdconta crapopi.nrdconta%TYPE,
                       pr_nrcpfope crapopi.nrcpfope%TYPE) IS
        SELECT
             c.nmoperad,
             c.nrcpfope,
             c.dsdcargo,
             c.flgsitop,
             c.dsdemail,
             c.vllbolet,
             c.vllimtrf,
             c.vllimted,
             c.vllimvrb,
             c.vllimflp
        FROM crapopi c
        WHERE c.cdcooper = pr_cdcooper AND
              c.nrdconta = pr_nrdconta AND
              c.nrcpfope = pr_nrcpfope;
        rw_crapopi cr_crapopi%ROWTYPE;

    CURSOR cr_preposto (pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_nrcpfope crapass.nrcpfcgc%TYPE) IS
        SELECT
          avt.nmdavali AS nmprepos,
          avt.nrcpfcgc AS nrcpfpre,
          t.dhaprovacao AS dtaprov,
          (SELECT ass.nmprimtl
           FROM crapass ass
           WHERE ass.cdcooper = t.cdcooper AND
                 ass.nrdconta = avt.nrdctato) nmprimtl,
          t.flgaprovado
        FROM
          TBCC_OPERAD_APROV t,
          crapavt avt,
          crapsnh snh
        WHERE
          t.cdcooper = pr_cdcooper          AND
          t.nrdconta = pr_nrdconta          AND
          t.nrcpf_operador = pr_nrcpfope    AND
          avt.cdcooper = t.cdcooper         AND
          avt.nrdconta = t.nrdconta         AND
          avt.nrcpfcgc = t.nrcpf_preposto   AND
          snh.cdcooper = avt.cdcooper       AND
          snh.nrdconta = avt.nrdconta       AND
          snh.nrcpfcgc = avt.nrcpfcgc       AND
          snh.tpdsenha = 1                  AND
          snh.cdsitsnh = 1;
        rw_preposto cr_preposto%ROWTYPE;

    CURSOR cr_crapdat (pr_cdcooper crapopi.cdcooper%TYPE) IS
        SELECT
             c.dtmvtolt,
             c.dtmvtocd
        FROM crapdat c
        WHERE c.cdcooper = pr_cdcooper;
        rw_crapdat cr_crapdat%ROWTYPE;
                           
    vr_exc_erro EXCEPTION;
    
    xml_operador VARCHAR2(4000);

    vr_dscritic VARCHAR2(350);

    
    BEGIN
      -- Verificar se algum preposto foi incluso na tela Atenda -> Internet -> Responsáveis Assinatura Conjunta
      -- e não existe na tabela tbcc_operad_aprov , se não existir, incluir
      FOR C1 IN PREPOSTO_A_INCLUIR LOOP
        -- Buscar os registros na tabela tbcc_operad_aprov (outro preposto), para inserir no novo preposto
        FOR C2 IN DADOS_OPERAD_APROV(C1.CDCOOPER,C1.NRDCONTA,C1.NRCPFPRO) LOOP
          BEGIN
            INSERT INTO TBCC_OPERAD_APROV
            (cdcooper,
             nrdconta,
             nrcpf_operador,
             nrcpf_preposto,
             flgaprovado,
             dhaprovacao,
             vllimite_pagto,
             vllimite_transf,
             vllimite_ted,
             vllimite_vrboleto,
             vllimite_folha
            )
            VALUES
            (c2.cdcooper,
             c2.nrdconta,
             c2.nrcpf_operador,
             c2.nrcpf_preposto,
             c2.flgaprovado,
             c2.dhaprovacao,
             c2.vllimite_pagto,
             c2.vllimite_transf,
             c2.vllimite_ted,
             c2.vllimite_vrboleto,
             c2.vllimite_folha
             );
          EXCEPTION
            WHEN OTHERS THEN
            vr_dscritic := 'Erro ao incluir registros da tabela TBCC_OPERAD_APROV.Cooper ='||c2.cdcooper||' Conta = '||c2.nrdconta||' Preposto ='||c2.nrcpf_preposto||' Operador ='||c2.nrcpf_operador ||' SQLCODE: ' || SQLCODE || ' ,ERROR: ' || SQLERRM;
            ROLLBACK;
            RAISE vr_exc_erro;
          END;
        END LOOP;
      END LOOP;
    
      -- Verificar se existe algum registro na tabela tbcc_operad_aprov e que o preposto 
      -- foi desmarcado na tela tela Atenda -> Internet -> Responsáveis Assinatura Conjunta,
      -- se existir, excluir desta tabela também.
      BEGIN
        DELETE
              TBCC_OPERAD_APROV  t
         WHERE
              NOT EXISTS(SELECT 
                                1
                           FROM
                                crappod 
                          WHERE 
                                crappod.cdcooper = t.cdcooper
                            AND crappod.nrdconta = t.nrdconta 
                            AND crappod.nrcpfpro = t.nrcpf_preposto 
                            AND crappod.cddpoder = 10 -- Poder de assinatura conjunta
                            AND crappod.flgconju = 1 -- 'Poder em conjunto? Sim/Nao' = 1 - Sim
                            );
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Erro ao excluir registros da tabela TBCC_OPERAD_APROV. SQLCODE: ' || SQLCODE || ' ,ERROR: ' || SQLERRM;
        ROLLBACK;
        RAISE vr_exc_erro;
      END;
        
      -- Após as inclusões e exclusões, verificar se existe algum operador que possua aprovação de todos
      -- os prepostos e caso positivo efetuar a provação completa
      FOR C3 IN PREPOSTO_A_APROVAR LOOP
                    OPEN cr_limites_temp(C3.cdcooper, C3.nrdconta, C3.NRCPF_OPERADOR);
                    FETCH cr_limites_temp INTO rw_limites_temp;
                    CLOSE cr_limites_temp;

                    /* Apos as validações, atualiza os Limites na tabela crapopi */
                    BEGIN
                        UPDATE crapopi SET
                            crapopi.vllbolet = rw_limites_temp.vllimite_pagto,
                            crapopi.vllimtrf = rw_limites_temp.vllimite_transf,
                            crapopi.vllimted = rw_limites_temp.vllimite_ted,
                            crapopi.vllimvrb = rw_limites_temp.vllimite_vrboleto,
                            crapopi.vllimflp = rw_limites_temp.vllimite_folha,
                            crapopi.flgsitop = 1
                         WHERE
                            crapopi.cdcooper = C3.cdcooper AND
                            crapopi.nrdconta = C3.nrdconta AND
                            crapopi.nrcpfope = C3.NRCPF_OPERADOR;

                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_dscritic := 'SQLCODE: ' || SQLCODE || ' ,ERROR: ' || SQLERRM;
                        RAISE vr_exc_erro;
                    END;

                    FOR rw_preposto IN cr_preposto(C3.cdcooper, C3.nrdconta, C3.NRCPF_OPERADOR) LOOP
                        BEGIN
                            /* DELETAR TODOS OS REGISTROS */
                            DELETE FROM CECRED.TBCC_OPERAD_APROV t
                            WHERE t.cdcooper       = C3.cdcooper      AND
                                  t.nrdconta       = C3.nrdconta      AND
                                  t.nrcpf_operador = C3.NRCPF_OPERADOR       AND
                                  t.nrcpf_preposto = rw_preposto.nrcpfpre;
                        EXCEPTION
                          WHEN OTHERS THEN
                            vr_dscritic := 'Erro no DELETE TBCC_OPERAD_APROV';
                            ROLLBACK;
                            RAISE vr_exc_erro;
                        END;
                    END LOOP;
      END LOOP;                                           
      
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := vr_dscritic;
        ROLLBACK;

END pc_processa_preposto;
/
