PL/SQL Developer Test script 3.0
52

declare
  CURSOR cr_emprestimos IS
    SELECT w.rowid,w.* 
      from crawepr w
     where w.qttentreenv = 4 -- Mais tentativas do que o parametrizado, não entra mais nos reenvios
       and w.insitapr = 0    -- Em estudo
       and w.insitest = 0    -- Sem retorno de motor
       and w.cdfinemp = 77   -- Crédito Digital
       and w.cdorigem in (3,10) -- IB ou Mobile
       and w.dtmvtolt IN('03/05/2021','04/05/2021')
       AND NOT EXISTS (SELECT 1
                         FROM crapepr p
                        WHERE p.cdcooper = w.cdcooper
                          AND p.nrdconta = w.nrdconta
                          AND p.nrctremp = w.nrctremp);
 RW_EMPRESTIMO CR_EMPRESTIMOS%ROWTYPE; 

  i           integer := 0;
  vr_dscritic VARCHAR2(1000);
  vr_dsmensag VARCHAR2(4000);
  vr_cdcritic INTEGER;
  
begin
  dbms_output.enable(1000000);
  FOR RW_EMPRESTIMO IN cr_emprestimos LOOP
    i := i + 1;

    ESTE0001.pc_incluir_proposta_est(pr_cdcooper => RW_EMPRESTIMO.cdcooper--> Codigo da cooperativa
                                    ,pr_cdagenci => RW_EMPRESTIMO.cdagenci--> Codigo da agencia
                                    ,pr_cdoperad => RW_EMPRESTIMO.cdopeste--> codigo do operador
                                    ,pr_cdorigem => 5 --> Origem da operacao
                                    ,pr_nrdconta => RW_EMPRESTIMO.nrdconta --> Numero da conta do cooperado
                                    ,pr_nrctremp => RW_EMPRESTIMO.nrctremp --> Numero da proposta de emprestimo atual/antigo
                                    ,pr_dtmvtolt => trunc(sysdate) --> Data do movimento
                                    ,pr_nmarquiv => NULL
                                    ,pr_dsmensag => vr_dsmensag
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);

     IF vr_dscritic IS NOT NULL OR vr_cdcritic > 0 THEN
       DBMS_OUTPUT.put_line('Erro ao agendar envio ao motor: ' || RW_EMPRESTIMO.cdcooper || 
                         ' proposta:' || RW_EMPRESTIMO.nrctremp || 
                         ' conta: ' || RW_EMPRESTIMO.NRDCONTA); 
     END IF;


  END LOOP;
  commit;
  DBMS_OUTPUT.put_line('total de registros:' || i);

end;
0
0
