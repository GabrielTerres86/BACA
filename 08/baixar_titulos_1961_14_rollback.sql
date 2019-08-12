DECLARE

  vr_dserro   VARCHAR2(100);
  vr_dscritic VARCHAR2(4000);
  vr_cdcritic NUMBER;

  exc_erro_1 EXCEPTION;

  CURSOR cr_crapcob IS
    SELECT cob.rowid
          ,cob.cdbandoc
          ,cob.nrdctabb
          ,cob.incobran
          ,cob.cdcooper
          ,cob.nrdconta
          ,cob.nrcnvcob
          ,cob.nrdocmto
          ,cob.dsdoccop
          ,cob.nrnosnum
     FROM crapcob cob
    WHERE cob.cdcooper = 14
      AND cob.cdbandoc = 1
      AND cob.nrdctabb = 1254979
      AND cob.nrcnvcob = 2287349
      AND cob.nrdconta = 1961
      AND (cob.nrdocmto = 192 OR cob.nrdocmto = 225);

  vr_tab_lat_consolidada PAGA0001.typ_tab_lat_consolidada;

BEGIN

  dbms_output.enable(NULL);
  dbms_output.put_line('Situacao (0=A, 3=B, 5=L) - Cooperativa - Conta - Convenio - Boleto - Documento - Nosso Numero');

  FOR rw IN cr_crapcob LOOP

    dbms_output.put_line(rw.incobran || ' - ' ||
                         rw.cdcooper || ' - ' ||
                         rw.nrdconta || ' - ' ||
                         rw.nrcnvcob || ' - ' ||
                         rw.nrdocmto || ' - ' ||
                         rw.dsdoccop || ' - ' ||
                         rw.nrnosnum);

    IF rw.incobran = 0 THEN

      UPDATE crapcob
         SET incobran = 0,
             dtdbaixa = TRUNC(SYSDATE)
       WHERE cdcooper = rw.cdcooper
         AND nrdconta = rw.nrdconta
         AND nrcnvcob = rw.nrcnvcob
         AND nrdocmto = rw.nrdocmto;
         
      IF SQL%ROWCOUNT = 1 THEN
        paga0001.pc_cria_log_cobranca(pr_idtabcob => rw.rowid
                                     ,pr_cdoperad => '1'
                                     ,pr_dtmvtolt => trunc(SYSDATE)
                                     ,pr_dsmensag => 'Titulo baixado manualmente'
                                     ,pr_des_erro => vr_dserro
                                     ,pr_dscritic => vr_dscritic);
        IF (TRIM(vr_dscritic) IS NOT NULL) THEN
          RAISE exc_erro_1;
        END IF;
        COMMIT;
      END IF;

    END IF;

  END LOOP;

EXCEPTION
  WHEN exc_erro_1 THEN
    IF (NVL(vr_cdcritic,0) > 0) AND (TRIM(vr_dscritic) IS NULL) THEN
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    dbms_output.put_line('ERRO_1: vr_cdcritic: ' || vr_cdcritic || ' - vr_dscritic: ' || vr_dscritic);
    ROLLBACK;
  WHEN OTHERS THEN
    cecred.pc_internal_exception;
    ROLLBACK;
END;
