PL/SQL Developer Test script 3.0
80
declare

  vr_cdcritic             crapcri.cdcritic%TYPE;
  vr_dscritic             VARCHAR2(4000);
  vr_innivris             INTEGER;

  CURSOR cr_cop IS
    SELECT c.cdcooper, d.dtmvtolt
      FROM crapcop c, crapdat d
     WHERE c.flgativo = 1
       AND d.cdcooper = c.cdcooper
     ORDER BY c.cdcooper ;
  rw_cop  cr_cop%ROWTYPE;


  CURSOR cr_empr (pr_cdcooper IN  crapcop.cdcooper%TYPE) IS
    SELECT w.dtmvtolt
          ,w.cdcooper
          ,w.nrdconta
          ,w.nrctremp
          ,w.dsnivris risco_rating
          ,w.insitapr
          ,w.insitest
          ,a.nrcpfcnpj_base
          ,w.cdopeapr
      FROM crawepr w, crapass a
     WHERE a.cdcooper = w.cdcooper
       AND a.nrdconta = w.nrdconta
       AND NOT EXISTS (SELECT 1
                         FROM crapepr e
                        WHERE e.cdcooper = w.cdcooper
                          AND e.nrdconta = w.nrdconta
                          AND e.nrctremp = w.nrctremp)
       AND w.dtmvtolt >= '01/01/2019'
       AND w.dtexpira IS NULL
       AND w.cdcooper = pr_cdcooper
       AND ((w.insitest = 3 AND w.insitapr = 1) OR
            (w.insitest = 2 AND w.insitapr = 0) OR
            (w.insitapr = 2 AND upper(w.cdopeapr) IN ('MOTOR','ESTEIRA') AND w.dtenvest IS NULL))
       AND NOT EXISTS (SELECT 1
                         FROM tbrisco_operacoes o
                        WHERE o.cdcooper = w.cdcooper
                          AND o.nrdconta = w.nrdconta
                          AND o.nrctremp = w.nrctremp
                          AND TRIM(o.inrisco_rating_autom) IS NOT NULL);
  rw_empr  cr_empr%ROWTYPE;
  
BEGIN

  FOR rw_cop IN cr_cop LOOP
    
    FOR rw_empr IN cr_empr(rw_cop.cdcooper) LOOP

      vr_innivris := risc0004.fn_traduz_nivel_risco(rw_empr.risco_rating);

      rati0003.pc_grava_rating_operacao(pr_cdcooper          => rw_cop.cdcooper
                                       ,pr_nrdconta          => rw_empr.nrdconta
                                       ,pr_tpctrato          => 90
                                       ,pr_nrctrato          => rw_empr.nrctremp
                                       ,pr_ntrataut          => vr_innivris
                                       ,pr_dtrataut          => rw_cop.dtmvtolt
                                       ,pr_strating          => 2  -- ANALISADO
                                       --Variáveis para gravar o histórico
                                       ,pr_cdoperad          => '1'
                                       ,pr_dtmvtolt          => rw_cop.dtmvtolt
                                       ,pr_valor             => NULL
                                       ,pr_rating_sugerido   => NULL
                                       ,pr_justificativa     => 'CARGA INICIAL - PROPOSTAS ANALISADAS PENDENTES - 20/09/2019'
                                       ,pr_tpoperacao_rating => 1
                                       ,pr_nrcpfcnpj_base    => rw_empr.nrcpfcnpj_base
                                       --Variáveis de crítica
                                       ,pr_cdcritic          => vr_cdcritic
                                       ,pr_dscritic          => vr_dscritic);
    END LOOP;
    COMMIT;

  END LOOP;
  COMMIT;
  
end;
8
pr_cdcooper
0
-4
pr_nrdconta
0
-4
pr_dstextab_bacen
0
-5
pr_dtmvtolt
0
-12
pr_nivrisco
0
-5
pr_dtrefere
0
-12
pr_cdcritic
0
-4
pr_dscritic
0
-5
2
vr_dtultdma
pr_nrdconta
