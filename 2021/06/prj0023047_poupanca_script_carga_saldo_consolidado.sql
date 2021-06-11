DECLARE
  --
  PROCEDURE pc_gera_saldo_consolidado_poup(pr_cdcooper IN tbcapt_saldo_consolidado.cdcooper%TYPE
                                          ,pr_cdprodut IN tbcapt_saldo_consolidado.cdprodut%TYPE
                                          ,pr_dtmvtolt IN tbcapt_saldo_consolidado.dtmvtolt%TYPE
                                          ,pr_vlsaldo  IN tbcapt_saldo_consolidado.vlsaldo%TYPE
                                          ,pr_cdcritic OUT PLS_INTEGER
                                          ,pr_dscritic OUT VARCHAR2) IS
    --
    --
  BEGIN
    --
    pr_cdcritic := 0;
    pr_dscritic := NULL;
    --
    BEGIN
      --
      INSERT INTO cecred.tbcapt_saldo_consolidado
        (cdcooper
        ,cdprodut
        ,dtmvtolt
        ,vlsaldo
        ,dtatualizacao)
      VALUES
        (pr_cdcooper --cdcooper
        ,pr_cdprodut --cdprodut
        ,trunc(pr_dtmvtolt) --dtmvtolt
        ,pr_vlsaldo --vlsaldo
        ,SYSDATE --dtatualizacao
         );
      --
    EXCEPTION
      --
      WHEN DUP_VAL_ON_INDEX THEN
        BEGIN
          --
          UPDATE cecred.tbcapt_saldo_consolidado tsc
             SET tsc.vlsaldo       = pr_vlsaldo
                ,tsc.dtatualizacao = SYSDATE
           WHERE tsc.dtmvtolt = trunc(pr_dtmvtolt)
             AND tsc.cdprodut = pr_cdprodut
             AND tsc.cdcooper = pr_cdcooper;
          --
        EXCEPTION
          WHEN OTHERS THEN
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                        ,pr_compleme => 'UPDATE tbcapt_saldo_consolidado:(' ||
                                                        pr_cdcooper || ',' || pr_cdprodut || ',' ||
                                                        trunc(pr_dtmvtolt) || ',' || pr_vlsaldo || ')');
            raise_application_error(-20001, 'UPDATE tbcapt_saldo_consolidado');
        END;
      WHEN OTHERS THEN
        BEGIN
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                      ,pr_compleme => 'INSERT tbcapt_saldo_consolidado:(' ||
                                                      pr_cdcooper || ',' || pr_cdprodut || ',' ||
                                                      trunc(pr_dtmvtolt) || ',' || pr_vlsaldo || ')');
          raise_application_error(-20001, 'INSERT tbcapt_saldo_consolidado');
        END;
        --
    END;
    --
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'pc_gera_saldo_consolidado_poup');
        pr_dscritic := 'Erro geral em pc_gera_saldo_consolidado_poup: ' || SQLERRM;
      END;
  END pc_gera_saldo_consolidado_poup;
  --
  PROCEDURE pc_script_saldo_consolidado(pr_cdcooper     IN crapcop.cdcooper%TYPE
                                       ,pr_dtreferencia IN DATE) IS
    --
    vr_cdcritic PLS_INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_pf_vltitulo_ativo NUMERIC(18,2);
    vr_pj_vltitulo_ativo NUMERIC(18,2);

    CURSOR cr_crapcpc IS
      SELECT cpc.cdprodut
        FROM crapcpc cpc
       WHERE cpc.cddindex = 6 /* Poupanca */
         AND cpc.idsitpro = 1; /* Ativo */
    rw_crapcpc cr_crapcpc%ROWTYPE;

    -- Busca aplicacoes ativas
    CURSOR cr_craprac(pr_cdcooper     IN crapcop.cdcooper%TYPE
                     ,pr_cdprodut     IN crapcpc.cdprodut%TYPE
                     ,pr_dtreferencia IN DATE) IS
      SELECT ass.inpessoa
            ,nvl((SELECT SUM(decode(his.indebcre, 'D', -1, 1) * lac.vllanmto) AS "Valor"
                    FROM craphis his
                        ,craplac lac
                  WHERE his.cdhistor = lac.cdhistor
                    AND his.cdcooper = lac.cdcooper
                    AND lac.dtmvtolt <= TRUNC(pr_dtreferencia) -- Lancamentos ate ultimo dia
                    AND lac.nraplica = rac.nraplica
                    AND lac.nrdconta = rac.nrdconta
                    AND lac.cdcooper = rac.cdcooper)
                 ,0) valor -- saldo ate dtultdma
        FROM crapass ass
            ,craprac rac
       WHERE ass.nrdconta = rac.nrdconta
         AND ass.cdcooper = rac.cdcooper
         /* Se a aplicacao esta sacada total e a ult. atualizacao de saldo foi antes do ultimo dia então desconsiderar */
         AND NOT (rac.idsaqtot = 1 AND rac.dtatlsld < trunc(pr_dtreferencia))
         AND rac.dtmvtolt <= TRUNC(pr_dtreferencia)
         AND rac.cdprodut = pr_cdprodut
         AND rac.cdcooper = pr_cdcooper;
    rw_craprac cr_craprac%ROWTYPE;
  
  BEGIN
    --
    /* Loop pelos produtos Poupanca */
    FOR rw_crapcpc IN cr_crapcpc
    LOOP
      --
      vr_pf_vltitulo_ativo := 0;
      vr_pj_vltitulo_ativo := 0;
      --
      FOR r_coop IN (
                     SELECT cop.cdcooper
                     FROM crapcop cop
                     WHERE cop.flgativo = 1
                       AND cop.cdcooper <> 3
                       AND (cop.cdcooper = pr_cdcooper OR pr_cdcooper = 3)
                     ORDER BY cop.cdcooper
                    )
      LOOP
        --
        FOR rw_craprac IN cr_craprac(pr_cdcooper     => r_coop.cdcooper
                                    ,pr_cdprodut     => rw_crapcpc.cdprodut
                                    ,pr_dtreferencia => pr_dtreferencia)
        LOOP
          -- SALDO TOTAL TITULOS ATIVOS
          IF rw_craprac.inpessoa = 1 THEN
            vr_pf_vltitulo_ativo := vr_pf_vltitulo_ativo + rw_craprac.valor;
          ELSE
            vr_pj_vltitulo_ativo := vr_pj_vltitulo_ativo + rw_craprac.valor;
          END IF;
          --
        END LOOP;
        --
      END LOOP;
      --
      pc_gera_saldo_consolidado_poup(pr_cdcooper => pr_cdcooper
                                    ,pr_cdprodut => rw_crapcpc.cdprodut
                                    ,pr_dtmvtolt => pr_dtreferencia
                                    ,pr_vlsaldo  => nvl(vr_pf_vltitulo_ativo,0)
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
      --
    END LOOP;
    --
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper,pr_compleme => 'pc_script_saldo_consolidado');
      ROLLBACK;
  END pc_script_saldo_consolidado;
  --
BEGIN
  --
  DECLARE
    --
    --
  BEGIN
    --
    for r_coop in (
                   select rac.cdcooper
                         ,min(rac.dtmvtolt) dtmvtolt
                   from craprac rac --Registro de aplicacao da captacao
                   where rac.cdprodut = 1109
                   group by rac.cdcooper
                   union
                   select 3
                         ,min(rac.dtmvtolt) dtmvtolt
                   from craprac rac --Registro de aplicacao da captacao
                   where rac.cdprodut = 1109
                   order by 1,2
                  )
    loop
      --
      dbms_output.put_line('r_coop.cdcooper:' || r_coop.cdcooper);
      --
      for r_dat in (
                    select cal.dtreferencia
                    from (
                          select trunc(sysdate)-level dtreferencia
                          from dual
                          connect by level <= 150
                         ) cal
                    where cal.dtreferencia < sysdate
                      and cal.dtreferencia = gene0005.fn_valida_dia_util(pr_cdcooper => r_coop.cdcooper, pr_dtmvtolt => cal.dtreferencia)
                      and cal.dtreferencia >= r_coop.dtmvtolt
                    order by cal.dtreferencia
                   )
      loop
        --
        dbms_output.put_line('r_dat.dtreferencia:' || r_dat.dtreferencia);
        --
        pc_script_saldo_consolidado(pr_cdcooper     => r_coop.cdcooper
                                   ,pr_dtreferencia => r_dat.dtreferencia);
        --
      end loop;
      --
    end loop;
    --
    COMMIT;
    --
  END;
  --
END;
