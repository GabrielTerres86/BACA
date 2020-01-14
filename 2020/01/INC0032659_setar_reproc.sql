--INC0032659 - Reenviar propostas para análise
--Ana Volles - 02/01/2020
DECLARE
  --Busca as propostas
  CURSOR cr_crawepr IS 
    SELECT a.cdcooper, a.nrdconta, a.nrctremp, a.dtmvtolt, a.insitest, a.qttentreenv, a.cdopeapr, a.insitapr, a.cdfinemp, a.cdoperad, a.cdagenci
    FROM  crawepr a, crapdat d
    WHERE a.cdfinemp = 77
    AND   a.insitapr = 0
    AND   a.insitest in (0, 1)
    AND   a.dtmvtolt >= '25/11/2019'
    AND   a.dtmvtolt < d.dtmvtolt  --teste x em D1 usar <=, em PROD e H6 usar <
    AND   a.cdcooper = d.cdcooper 
    AND   a.cdcooper = 1
    ORDER BY 4,2,3;

  rw_crawepr    cr_crawepr%ROWTYPE;
  vr_qtdupdate  NUMBER := 0;
  vr_qtdinsert  NUMBER := 0;
BEGIN
  FOR rw_crawepr IN cr_crawepr LOOP  

    dbms_output.put_line('Atualizado -> conta:'||rw_crawepr.nrdconta||', nrctremp:'||rw_crawepr.nrctremp||', dtmvtolt:'||rw_crawepr.dtmvtolt);

    BEGIN
      --Atualiza situação de envio e quantidade de reenvios para a esteira
      UPDATE crawepr w
      SET   w.insitest    = 0
           ,w.qttentreenv = 0
      WHERE w.cdfinemp = rw_crawepr.cdfinemp --77
      AND   w.insitapr = rw_crawepr.insitapr --0
      AND   w.insitest = rw_crawepr.insitest -- in (0, 1)
      AND   w.dtmvtolt = rw_crawepr.dtmvtolt -->= '25/11/2019'
      AND   w.nrctremp = rw_crawepr.nrctremp
      AND   w.nrdconta = rw_crawepr.nrdconta
      AND   w.cdcooper = rw_crawepr.cdcooper;

      vr_qtdupdate := vr_qtdupdate + 1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    BEGIN
      INSERT INTO tbepr_reenvio_analise
                  (dtinclus, --1
                   cdcooper, --2
                   nrdconta, --3 
                   nrctremp, --4
                   insitrnv, --5
                   dtagernv, --6
                   nrhragen, --7
                   cdagenci, --8
                   cdoperad) --9
                VALUES
                  (rw_crawepr.dtmvtolt,      --1
                   rw_crawepr.cdcooper,      --2
                   rw_crawepr.nrdconta,      --3
                   rw_crawepr.nrctremp,      --4
                   0,                        --5
                   rw_crawepr.dtmvtolt,      --6
                   to_char(sysdate,'sssss'), --7
                   rw_crawepr.cdagenci,      --8
                   rw_crawepr.cdoperad);     --9

      vr_qtdinsert := vr_qtdinsert + 1;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;

  dbms_output.put_line('Qtde crawepr Alterados:'||vr_qtdupdate||', Qtde tbepr_reenvio_analise Inseridos:'||vr_qtdinsert);

  COMMIT;  
  
end;

