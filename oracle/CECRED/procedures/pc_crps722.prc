CREATE OR REPLACE PROCEDURE CECRED.pc_crps722 (pr_cdcritic  OUT PLS_INTEGER   -- Codigo da Critica
                                              ,pr_dscritic  OUT VARCHAR2) IS  -- Descricao da Critica
BEGIN
  /* .............................................................................

     Programa: pc_crps722
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Mauro (MOUTS)
     Data    : Julho/2017                     Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Geracao do Grupo Economico Novo

     Alteracoes: 

  ............................................................................ */

  DECLARE
    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);
    vr_idgrupo   tbcc_grupo_economico.idgrupo%TYPE;
    
    ------------------------------- CURSORES ---------------------------------
    -- Busca os contratos
    CURSOR cr_grupo_economico IS
        SELECT crapgrp.cdcooper
              ,crapgrp.nrdconta
              ,crapgrp.nrdgrupo          
              ,crapgrp.nrctasoc
              ,crapgrp.nrcpfcgc
              ,crapgrp.inpessoa
              ,crapavt.persocio
              ,CASE WHEN upper(dsproftl) LIKE '%SOCIO%' THEN 2
                    ELSE 7 
              END AS tpvinculo
              ,tbcc_grupo_economico.idgrupo
              ,ROW_NUMBER () OVER (PARTITION BY crapgrp.cdcooper, crapgrp.nrdconta, crapgrp.nrdgrupo ORDER BY crapgrp.cdcooper, crapgrp.nrdconta, crapgrp.nrdgrupo) nrseq
              ,COUNT(1)      OVER (PARTITION BY crapgrp.cdcooper, crapgrp.nrdconta, crapgrp.nrdgrupo ORDER BY crapgrp.cdcooper, crapgrp.nrdconta, crapgrp.nrdgrupo) qtreg
          FROM crapgrp
          JOIN crapdat
            ON crapdat.cdcooper = crapgrp.cdcooper
     left join crapavt                  
            on crapavt.cdcooper = crapgrp.cdcooper
           and crapavt.nrdconta = crapgrp.nrdconta
           and crapavt.nrdctato = crapgrp.nrctasoc
           AND crapavt.tpctrato = 6
     LEFT JOIN tbcc_grupo_economico
            on tbcc_grupo_economico.cdcooper = crapgrp.cdcooper
           and tbcc_grupo_economico.nrdconta = crapgrp.nrdconta
         WHERE crapgrp.nrdconta <> crapgrp.nrctasoc
           AND crapgrp.dtmvtolt = crapdat.dtmvtoan
           AND NOT EXISTS (SELECT 1
                             FROM tbcc_grupo_economico_integ
                             JOIN tbcc_grupo_economico grupo
                               ON grupo.idgrupo = tbcc_grupo_economico_integ.idgrupo
                                  -- Condicao do Integrante
                            WHERE tbcc_grupo_economico_integ.cdcooper = crapgrp.cdcooper
                              AND tbcc_grupo_economico_integ.nrdconta = crapgrp.nrctasoc
                              AND tbcc_grupo_economico_integ.dtexclusao IS NULL
                                  -- Condicao do Grupo
                              AND grupo.cdcooper = crapgrp.cdcooper
                              AND grupo.nrdconta = crapgrp.nrdconta)
      ORDER BY crapgrp.cdcooper, crapgrp.nrdconta, crapgrp.nrdgrupo;    
  BEGIN

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    FOR rw_grupo_economico IN cr_grupo_economico LOOP

      -- Condicao para verificar se o grupo jah foi criado
      IF rw_grupo_economico.idgrupo IS NULL THEN
        BEGIN
          INSERT INTO tbcc_grupo_economico
                      (cdcooper
                      ,nrdconta
                      ,nmgrupo
                      ,dtinclusao)
               VALUES (rw_grupo_economico.cdcooper
                      ,rw_grupo_economico.nrdconta
                      ,'Grupo Carga Manutencao'
                      ,TRUNC(SYSDATE))
                      RETURNING tbcc_grupo_economico.idgrupo INTO vr_idgrupo;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao gravar o grupo economico: '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      ELSE
        vr_idgrupo := rw_grupo_economico.idgrupo;
      END IF;

      -- Cadastro de Integrante
      BEGIN
        INSERT INTO tbcc_grupo_economico_integ
                    (idgrupo
                    ,nrcpfcgc
                    ,cdcooper
                    ,nrdconta
                    ,tppessoa
                    ,tpcarga
                    ,tpvinculo
                    ,peparticipacao
                    ,dtinclusao
                    ,cdoperad_inclusao)
             VALUES (vr_idgrupo
                    ,rw_grupo_economico.nrcpfcgc
                    ,rw_grupo_economico.cdcooper
                    ,rw_grupo_economico.nrctasoc
                    ,rw_grupo_economico.inpessoa
                    ,2 -- Carga JOB
                    ,rw_grupo_economico.tpvinculo
                    ,rw_grupo_economico.persocio
                    ,TRUNC(SYSDATE)
                    ,1);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao gravar o integrante do grupo economico: '||SQLERRM;
          RAISE vr_exc_saida;
      END;

    END LOOP; -- cr_grupo_economico

    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Efetuar rollback
      ROLLBACK;
      -- Retornar a Critica
      vr_cdcritic := NVL(vr_cdcritic, 0);
      IF vr_cdcritic > 0 THEN
        vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
      END IF;
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      -- Efetuar rollback
      ROLLBACK;
      -- Retornar a Critica
      pr_cdcritic := 0;
      pr_dscritic := SQLERRM;
  END;

END pc_crps722;
/
