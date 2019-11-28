PL/SQL Developer Test script 3.0
319
declare 
  vr_tempo_parcial_i DATE;
  vr_tempo_parcial_f VARCHAR2(20);
  vr_tempo_total_i   DATE;
  vr_tempo_total_f   VARCHAR2(20);
 vr_contador  INTEGER;

  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
--       AND C.CDCOOPER = 16
       AND c.cdcooper <> 3
     ORDER BY c.cdcooper;
  RW_COP  CR_COP%ROWTYPE;

  CURSOR CR_DAT (pr_cdcooper  IN crapdat.cdcooper%TYPE) IS
    SELECT dtmvtolt
      FROM crapdat 
     WHERE cdcooper = pr_cdcooper;
  rw_dat  cr_dat%ROWTYPE;

  CURSOR cr_limites_sem_bordero (pr_cdcooper  IN crapcop.cdcooper%TYPE
                                ,pr_tpctrato  IN tbrisco_operacoes.tpctrato%TYPE) IS
    SELECT t.cdcooper, t.nrdconta, t.nrctremp, t.tpctrato
          ,t.nrcpfcnpj_base, w.insitlim
     FROM tbrisco_operacoes t
         , craplim w
     WHERE t.cdcooper       = pr_cdcooper
       AND t.tpctrato       = pr_tpctrato
       AND t.inrisco_rating_autom IS NULL
       AND t.tpctrato       = w.tpctrlim
       AND t.flintegrar_sas = 0
       AND t.flencerrado    = 0
       AND w.cdcooper = t.cdcooper
       AND w.nrdconta = t.nrdconta
       AND w.nrctrlim = t.nrctremp
       AND w.tpctrlim = t.tpctrato
       AND w.insitlim > 1
     ORDER BY t.cdcooper DESC,Insituacao_Rating
             ,t.nrdconta, nrctremp, tpctrato
             ;
   rw_limites_sem_bordero  cr_limites_sem_bordero%ROWTYPE;

  CURSOR cr_limites_sem_rating (pr_cdcooper  IN crapcop.cdcooper%TYPE
                               ,pr_tpctrato  IN tbrisco_operacoes.tpctrato%TYPE) IS
    SELECT l.cdcooper, l.nrdconta, l.nrctrlim nrctremp
          ,l.insitlim, l.tpctrlim tpctrato, o.inrisco_rating_autom, o.flintegrar_sas
      FROM craplim l, tbrisco_operacoes o
     WHERE l.cdcooper = pr_cdcooper
       AND l.tpctrlim = pr_tpctrato
       AND l.insitlim = 2          -- Limites ATIVOS
       -- QUE NAO TENHAM RATING
       AND o.cdcooper(+) = l.cdcooper
       AND o.nrdconta(+) = l.nrdconta
       AND o.nrctremp(+) = l.nrctrlim
       AND o.tpctrato(+) = l.tpctrlim
       AND o.inrisco_rating_autom IS NULL
       AND o.flintegrar_sas(+) = 0
    ;

  FUNCTION fn_valida_limite_chq_tit(pr_cdcooper IN tbrat_param_geral.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_tpctrato IN tbrisco_operacoes.tpctrato%TYPE
                                   ,pr_dtrefere IN crapdat.dtmvtolt%TYPE)
  /* .............................................................................

        Programa: fn_valida_limite
        Sistema : CRED
        Sigla   :
        Autor   : Guilherme/AMCOM
        Data    : Agosto/2019                 Ultima atualizacao: 04/11/2019


        Frequencia: Sempre que for chamado

        Objetivo  : Verificar se o contrato de limite que esteja cancelado
                   tem Borderos ativo
                   Retorno 1 - Com Bordero Ativo  / 0 - Apenas Bordero Encerrado

        Observacao: -----

        Alteracoes: 04/11/2019 - PJ450 - Bug 27689 - Rating Desc de Titulos/Cheques (estória 26619)
                    Verificar se existem Limite Desconto de Cheque e Título conforme regras
                    já existentes na Central de Risco.
                    (Marcelo Elias Gonçalves - AMcom).                
    ..............................................................................*/

   RETURN INTEGER IS

    --Verificar se existem Borderos de Cheque Ativos
    --04/11/2019 - PJ450 - Bug 27689 - Rating Desc de Cheques (estória 26619)
    CURSOR cr_bordero_chq IS
      SELECT Count(1)  qtd_borderos
        FROM crapbdc bdc
       WHERE bdc.cdcooper  = pr_cdcooper
         AND bdc.nrdconta  = pr_nrdconta
         AND bdc.nrctrlim  = pr_nrctremp
         -- Regra conforme já é feito na Central de Risco.
         AND bdc.dtlibbdc <= pr_dtrefere         
         AND bdc.insitbdc  = 3            
         -- Buscar apenas os borderos que possuem cheque com data liberacao maior que a data do sistema.
         AND EXISTS (SELECT 1
                     FROM   crapcdb cdb
                     WHERE  cdb.cdcooper = bdc.cdcooper
                     AND    cdb.nrborder = bdc.nrborder
                     AND    cdb.dtlibera > pr_dtrefere
                     AND    Nvl(cdb.dtdevolu,pr_dtrefere+1) > pr_dtrefere);                   
    rw_bordero_chq cr_bordero_chq%ROWTYPE;

    --Verificar se existem Borderos de Titulo Ativos
    --04/11/2019 - PJ450 - Bug 27689 - Rating Desc de Titulos (estória 26619)
    CURSOR cr_bordero_tit IS
      SELECT Count(1)  qtd_borderos
        FROM crapbdt bdt
            ,craptdb tdb
       WHERE bdt.cdcooper = pr_cdcooper
         AND bdt.nrdconta = pr_nrdconta
         AND bdt.nrctrlim = pr_nrctremp
         AND tdb.cdcooper = bdt.cdcooper
         AND tdb.nrdconta = bdt.nrdconta
         AND tdb.nrborder = bdt.nrborder
         -- Regra conforme já é feito na Central de Risco.
         -- Borderos Situação 4-Liquidado OU 3-Liberado com data inferior ou igual a de referencia.         
         AND (bdt.insitbdt = 4 OR (bdt.insitbdt = 3 AND bdt.dtlibbdt <= pr_dtrefere))
         -- Titulos Situação 4-Liberado OU 2-Processado com data igual a de processo
         AND (tdb.insittit = 4 OR (tdb.insittit = 2 AND tdb.dtdpagto = pr_dtrefere))
         AND (tdb.insitapr = 1 OR bdt.flverbor = 0);     
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
  
  FOR rw_cop IN cr_cop LOOP
    dbms_output.put_line(rw_cop.cdcooper);
    
    OPEN cr_dat (pr_cdcooper => rw_cop.cdcooper);
    FETCH cr_dat INTO rw_dat;
    CLOSE cr_dat;

    vr_contador := 0;
    vr_tempo_parcial_i := SYSDATE;
    vr_tempo_total_i   := SYSDATE;
    -- LIMITE CHEQUES
    FOR rw_limites_sem_bordero IN cr_limites_sem_bordero (pr_cdcooper => rw_cop.cdcooper
                                                         ,pr_tpctrato => 2) LOOP

      IF rw_limites_sem_bordero.insitlim = 3 THEN -- Limite Cancelado
        -- verificar se tem borderos ativos
        IF fn_valida_limite_chq_tit(pr_cdcooper => rw_limites_sem_bordero.cdcooper,
                                    pr_nrdconta => rw_limites_sem_bordero.nrdconta,
                                    pr_nrctremp => rw_limites_sem_bordero.nrctremp,
                                    pr_tpctrato => rw_limites_sem_bordero.tpctrato,
                                    pr_dtrefere => rw_dat.dtmvtolt) = 1 THEN
          -- se houver bordero ativo, marca para IntegrarSAS
          UPDATE tbrisco_operacoes t
             SET t.flintegrar_sas = 1
           WHERE t.cdcooper = rw_limites_sem_bordero.cdcooper
             AND t.nrdconta = rw_limites_sem_bordero.nrdconta
             AND t.nrctremp = rw_limites_sem_bordero.nrctremp
             AND t.tpctrato = rw_limites_sem_bordero.tpctrato;
--          COMMIT;
        END IF;
      ELSE
        -- Independente se tem bordero ativo, mas se o limite está ATIVO
        -- marca para IntegrarSAS
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_limites_sem_bordero.cdcooper
           AND t.nrdconta = rw_limites_sem_bordero.nrdconta
           AND t.nrctremp = rw_limites_sem_bordero.nrctremp
           AND t.tpctrato = rw_limites_sem_bordero.tpctrato;
--        COMMIT;
      END IF;
      vr_contador := vr_contador + 1;
    END LOOP;
    vr_tempo_parcial_f := LPAD(TRUNC(((SYSDATE - vr_tempo_parcial_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' Parte 1: ' ||vr_tempo_parcial_f );
    
    vr_tempo_parcial_i := SYSDATE;
    -- LIMITE TITULOS
    FOR rw_limites_sem_bordero IN cr_limites_sem_bordero (pr_cdcooper => rw_cop.cdcooper
                                                         ,pr_tpctrato => 3) LOOP
      IF rw_limites_sem_bordero.insitlim = 3 THEN -- Limite Cancelado
        -- verificar se tem borderos ativos
        IF fn_valida_limite_chq_tit(pr_cdcooper => rw_limites_sem_bordero.cdcooper,
                                    pr_nrdconta => rw_limites_sem_bordero.nrdconta,
                                    pr_nrctremp => rw_limites_sem_bordero.nrctremp,
                                    pr_tpctrato => rw_limites_sem_bordero.tpctrato,
                                    pr_dtrefere => rw_dat.dtmvtolt) = 1 THEN
          -- se houver bordero ativo, marca para IntegrarSAS
          UPDATE tbrisco_operacoes t
             SET t.flintegrar_sas = 1
           WHERE t.cdcooper = rw_limites_sem_bordero.cdcooper
             AND t.nrdconta = rw_limites_sem_bordero.nrdconta
             AND t.nrctremp = rw_limites_sem_bordero.nrctremp
             AND t.tpctrato = rw_limites_sem_bordero.tpctrato;
--          COMMIT;
        END IF;
      ELSE
        -- Independente se tem bordero ativo, mas se o limite está ATIVO
        -- marca para IntegrarSAS
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_limites_sem_bordero.cdcooper
           AND t.nrdconta = rw_limites_sem_bordero.nrdconta
           AND t.nrctremp = rw_limites_sem_bordero.nrctremp
           AND t.tpctrato = rw_limites_sem_bordero.tpctrato;
--        COMMIT;
      END IF;
      vr_contador := vr_contador + 1;
    END LOOP;
    vr_tempo_parcial_f := LPAD(TRUNC(((SYSDATE - vr_tempo_parcial_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' Parte 2: ' ||vr_tempo_parcial_f );

---------------------------------------



---------------------------------------
    vr_tempo_parcial_i := SYSDATE;
    FOR rw_limites_sem_rating IN cr_limites_sem_rating (pr_cdcooper => rw_cop.cdcooper
                                                       ,pr_tpctrato => 2) LOOP
      IF rw_limites_sem_rating.flintegrar_sas IS NULL
      OR rw_limites_sem_rating.flintegrar_sas = 0 THEN
        -- marca para IntegrarSAS
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_limites_sem_rating.cdcooper
           AND t.nrdconta = rw_limites_sem_rating.nrdconta
           AND t.nrctremp = rw_limites_sem_rating.nrctremp
           AND t.tpctrato = rw_limites_sem_rating.tpctrato;
      END IF;
--      COMMIT;
      vr_contador := vr_contador + 1;
    END LOOP;
    vr_tempo_parcial_f := LPAD(TRUNC(((SYSDATE - vr_tempo_parcial_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' Parte 3: ' ||vr_tempo_parcial_f );

    vr_tempo_parcial_i := SYSDATE;
    FOR rw_limites_sem_rating IN cr_limites_sem_rating (pr_cdcooper => rw_cop.cdcooper
                                                       ,pr_tpctrato => 3) LOOP
      IF rw_limites_sem_rating.flintegrar_sas IS NULL
      OR rw_limites_sem_rating.flintegrar_sas = 0 THEN
        -- marca para IntegrarSAS
        UPDATE tbrisco_operacoes t
           SET t.flintegrar_sas = 1
         WHERE t.cdcooper = rw_limites_sem_rating.cdcooper
           AND t.nrdconta = rw_limites_sem_rating.nrdconta
           AND t.nrctremp = rw_limites_sem_rating.nrctremp
           AND t.tpctrato = rw_limites_sem_rating.tpctrato;
      END IF;
--      COMMIT;
      vr_contador := vr_contador + 1;
    END LOOP;
    vr_tempo_parcial_f := LPAD(TRUNC(((SYSDATE - vr_tempo_parcial_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_parcial_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' Parte 4: ' ||vr_tempo_parcial_f );

    vr_tempo_total_f := LPAD(TRUNC(((SYSDATE - vr_tempo_total_i) * 86400 / 3600)), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD((SYSDATE - vr_tempo_total_i) * 86400, 3600) / 60), 2, '0') || ':' ||
                         LPAD(TRUNC(MOD(MOD((SYSDATE - vr_tempo_total_i) * 86400, 3600), 60)),
                              2,
                              '0');
    dbms_output.put_line(rw_cop.cdcooper || ' TEMPO TOTAL: ' ||vr_tempo_total_f || ' QTD: ' || vr_contador);
    
  END LOOP;

end;
0
0
