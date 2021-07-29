DECLARE
    CURSOR cr_1 IS
      select y.idsimula
            ,x.cdcooper
            ,x.nrdconta
            ,y.idorigem
      from   crawepr x
            ,tbepr_renegociacao_simula y
      where  x.cdcooper = y.cdcooper
      and    x.nrdconta = y.nrdconta
      and    x.nrctremp = y.nrctremp
      and    x.cdorigem = y.idorigem
      and    x.cdcooper = 13
      and    x.nrdconta = 525340
      and    x.cdorigem = 10 
      and    x.insitapr = 2
      and    x.insitest = 3;
    --
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(1000);
    vr_xml       XMLType;
    vr_exc_saida EXCEPTION;
    --      
BEGIN
  FOR rw_1 IN cr_1 LOOP
    begin
      CREDITO.cancelarSimulacaoRenegociacao(pr_cdcooper => rw_1.cdcooper
                                           ,pr_nrdconta => rw_1.nrdconta
                                           ,pr_idsimula => rw_1.idsimula
                                           ,pr_idorigem => rw_1.idorigem
                                           -- OUT
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_retxml   => vr_xml);
                                           
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;  
                                             
    end;                                         
  END LOOP;
  COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      dbms_output.put_line('Erro ao executar: '|| vr_cdcritic || ': ' || vr_dscritic);
      ROLLBACK;      
END;
