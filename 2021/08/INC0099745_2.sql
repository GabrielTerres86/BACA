DECLARE
    CURSOR cr_Rejeitada_Manual IS
      select y.idsimula
            ,x.cdcooper
            ,x.nrdconta
            ,y.idorigem
      from   crawepr x
            ,tbepr_renegociacao_simula y
      where  x.cdcooper  = y.cdcooper
      and    x.nrdconta  = y.nrdconta
      and    x.nrctremp  = y.nrctremp
      and    x.cdorigem  = y.idorigem
      and    x.cdorigem  = 10 --Mobile
      and    x.dtmvtolt <= to_date('15/07/2021','dd/mm/yyyy')
      and    x.insitapr  = 2  --Situacao Aprovacao Nao aprovado
      and    x.insitest  = 3;--Situacao da proposta na Esteira Analise Finalizada
    --
    CURSOR cr_Anulada IS
      select y.idsimula
            ,x.cdcooper
            ,x.nrdconta
            ,x.nrctremp
      from   crawepr x
            ,tbepr_renegociacao_simula y
      where  x.cdcooper  = y.cdcooper
      and    x.nrdconta  = y.nrdconta
      and    x.nrctremp  = y.nrctremp
      and    x.cdorigem  = y.idorigem
      and    x.cdorigem  = 10 --Mobile
      and    x.dtmvtolt <= to_date('15/07/2021','dd/mm/yyyy')
      and    x.dtanulac <= to_date('15/07/2021','dd/mm/yyyy')
      and    x.insitest  = 6;--Situacao da proposta na Esteira Anulada    
    --
    vr_cdcritic  crapcri.cdcritic%TYPE;
    vr_dscritic  VARCHAR2(1000);
    vr_xml       XMLType;
    vr_exc_saida EXCEPTION;
    --      
BEGIN
  FOR rw_Rejeitada_Manual IN cr_Rejeitada_Manual LOOP
    begin
      CREDITO.cancelarSimulacaoRenegociacao(pr_cdcooper => rw_Rejeitada_Manual.cdcooper
                                           ,pr_nrdconta => rw_Rejeitada_Manual.nrdconta
                                           ,pr_idsimula => rw_Rejeitada_Manual.idsimula
                                           ,pr_idorigem => rw_Rejeitada_Manual.idorigem
                                           -- OUT
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic
                                           ,pr_retxml   => vr_xml);
                                           
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;  
                                             
    end;                                         
  END LOOP;
  --
  FOR rw_Anulada IN cr_Anulada LOOP
    DELETE FROM credito.tbepr_renegociacao_contrato_simula WHERE idsimula = rw_Anulada.idsimula;
    DELETE FROM credito.tbepr_renegociacao_simula          WHERE idsimula = rw_Anulada.idsimula;   
    DELETE FROM cecred.tbepr_renegociacao_contrato         WHERE cdcooper = rw_Anulada.cdcooper AND nrdconta = rw_Anulada.nrdconta AND nrctremp = rw_Anulada.nrctremp;
    DELETE FROM cecred.tbepr_renegociacao                  WHERE cdcooper = rw_Anulada.cdcooper AND nrdconta = rw_Anulada.nrdconta AND nrctremp = rw_Anulada.nrctremp;                               
  END LOOP;  
  --
  COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      dbms_output.put_line('Erro ao executar: '|| vr_cdcritic || ': ' || vr_dscritic);
      ROLLBACK;      
END;
