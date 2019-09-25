PL/SQL Developer Test script 3.0
195
declare 
  vr_contador integer;

  --> Buscar todas as cooperativas ativas
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND cop.cdcooper <> 3 -- Não deve rodar para a AILOS
     ORDER BY cop.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  
  CURSOR cr_limpaSAS (pr_cdcooper crapcop.cdcooper%TYPE) IS
    -- 90 - Empréstimos
    SELECT /*+ INDEX(erp CRAPEPR##CRAPEPR2) */
           epr.cdcooper    cdcooper
          ,epr.nrdconta    nrdconta
          ,epr.nrctremp    nrctrato
          ,opr.tpctrato    tpctrato
          ,epr.inliquid    tpsituacao -- Contrato ativo
          ,opr.flintegrar_sas
          ,opr.flencerrado
          ,opr.rowid       row_id
      FROM crapepr epr
          ,tbrisco_operacoes opr
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.cdcooper = opr.cdcooper
       AND epr.nrdconta = opr.nrdconta
       AND epr.nrctremp = opr.nrctremp
       AND opr.flintegrar_sas = 1
       AND epr.inliquid = 1
       AND opr.tpctrato = 90
       AND ((epr.cdfinemp = 68 AND epr.dtmvtolt < to_date('13/09/2019','DD/MM/yyyy') OR
             epr.cdfinemp <> 68)) -- Não pode trazer Empréstimo Pré-Aprovado (Finalidade 68) após a Data de Corte do Projeto Reformulação do Rating (23/08/2019 - Marcelo Gonçalves/AMcom)
    UNION ALL
    --  1-Limite de Credito
    --  2-Limite Desconto Cheque
    --  3-Desconto de Títulos
    SELECT /*+ INDEX(lim CRAPLIM##CRAPLIM1) */
           lim.cdcooper    cdcooper
          ,lim.nrdconta    nrdconta
          ,lim.nrctrlim    nrctrato
          ,opr.tpctrato    tpctrato
          ,lim.insitlim    tpsituacao
          ,opr.flintegrar_sas
          ,opr.flencerrado
          ,opr.rowid       row_id
      FROM craplim lim
          ,tbrisco_operacoes opr
     WHERE lim.cdcooper = pr_cdcooper
       AND lim.cdcooper = opr.cdcooper
       AND lim.nrdconta = opr.nrdconta
       AND lim.nrctrlim = opr.nrctremp
       AND opr.flintegrar_sas = 1
       AND opr.tpctrato IN (1,2,3) -- 1-Limite de Credito, 2-Limite Desconto Cheque, 3-Limite Desconto Titulo
       AND opr.flencerrado = 0 -- Contratos ativos
       AND lim.tpctrlim =  opr.tpctrato;
  rw_limpaSAS   cr_limpaSAS%ROWTYPE;

  FUNCTION fn_valida_limite_chq_tit(pr_cdcooper IN tbrat_param_geral.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_tpctrato IN tbrisco_operacoes.tpctrato%TYPE)
  /* .............................................................................

        Programa: fn_valida_limite
        Sistema : CRED
        Sigla   :
        Autor   : Guilherme/AMCOM
        Data    : Agosto/2019                 Ultima atualizacao: --


        Frequencia: Sempre que for chamado

        Objetivo  : Verificar se o contrato de limite que esteja cancelado
                   tem Borderos ativo
                   Retorno 1 - Com Bordero Ativo  / 0 - Apenas Bordero Encerrado

        Observacao: -----

        Alteracoes:

    ..............................................................................*/

   RETURN INTEGER IS

    -- Buscar PA do operador de envio da proposta
    CURSOR cr_bordero_chq IS
      SELECT COUNT(*) qtd_borderos
        FROM crapbdc bdc, crapcdb cdb
       WHERE bdc.cdcooper = pr_cdcooper
         AND bdc.nrdconta = pr_nrdconta
         AND bdc.nrctrlim = pr_nrctremp
         AND bdc.dtlibbdc IS NOT NULL
         AND bdc.insitbdc = 3
         AND cdb.cdcooper = bdc.cdcooper
         AND cdb.nrborder = bdc.nrborder
         AND cdb.nrdconta = bdc.nrdconta
         AND cdb.dtdevolu IS NULL
         AND cdb.dtlibbdc IS NULL
      --AND t.dtlibera > '10/08/2019'
      ;
    rw_bordero_chq cr_bordero_chq%ROWTYPE;

    CURSOR cr_bordero_tit IS
      SELECT COUNT(*) qtd_borderos
        FROM crapbdt bdt, craptdb tdb
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrctrlim = pr_nrctremp
         AND bdt.flverbor = 1
         AND bdt.dtlibbdt IS NOT NULL
         AND bdt.insitbdt = 3
         AND tdb.cdcooper = bdt.cdcooper
         AND tdb.nrdconta = bdt.nrdconta
         AND tdb.nrborder = bdt.nrborder
         AND tdb.vlsldtit > 0;
    rw_bordero_tit cr_bordero_tit%ROWTYPE;

    vr_qtd_borderos INTEGER := 0;
  BEGIN

    IF pr_tpctrato = 2 THEN
      -- Cheques
      OPEN cr_bordero_chq;
      FETCH cr_bordero_chq
        INTO vr_qtd_borderos;
      CLOSE cr_bordero_chq;
    ELSIF pr_tpctrato = 3 THEN
      -- Titulos
      OPEN cr_bordero_tit;
      FETCH cr_bordero_tit
        INTO vr_qtd_borderos;
      CLOSE cr_bordero_tit;
    ELSE
      RETURN 0; -- Encerrado
    END IF;

    IF vr_qtd_borderos > 0 THEN
      RETURN 1; -- 1 - Com Bordero Ativo
    ELSE
      RETURN 0; -- 0 - Apenas Bordero Encerrado
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END fn_valida_limite_chq_tit;




BEGIN


  FOR rw_crapcop IN cr_crapcop LOOP
    vr_contador := 0;
    FOR rw_limpaSAS IN cr_limpaSAS(pr_cdcooper => rw_crapcop.cdcooper) LOOP


      -- Para limite CHQ e TIT e que não estejam ativos, verificar se tem borderos ativos
      IF  rw_limpaSAS.tpctrato IN(2,3)
      AND rw_limpaSAS.tpsituacao NOT IN(1,2,3) THEN

        -- verificar se tem borderos ativos
        IF fn_valida_limite_chq_tit(pr_cdcooper => rw_limpaSAS.cdcooper,
                                             pr_nrdconta => rw_limpaSAS.nrdconta,
                                             pr_nrctremp => rw_limpaSAS.nrctrato,
                                             pr_tpctrato => rw_limpaSAS.tpctrato) = 0 THEN

          -- se nao houver bordero ativo, marca como Encerrado.
          vr_contador := vr_contador + 1;
          UPDATE tbrisco_operacoes t
             SET t.flencerrado    = 1
                ,t.flintegrar_sas = 0
           WHERE ROWID = rw_limpaSAS.row_id;
          COMMIT;
        END IF;
      END IF;
      -- contratos de emprestimo
      IF  rw_limpaSAS.tpctrato = 90 THEN
        UPDATE tbrisco_operacoes t
           SET t.flencerrado    = 1
              ,t.flintegrar_sas = 0
         WHERE ROWID = rw_limpaSAS.row_id;
        COMMIT;
        vr_contador := vr_contador + 1;
      END IF;
    END LOOP;
    dbms_output.put_line('COP: ' || rw_crapcop.cdcooper || ' - QTD: ' || vr_contador);
    vr_contador := 0;
  END LOOP;
  COMMIT;
end;
0
0
