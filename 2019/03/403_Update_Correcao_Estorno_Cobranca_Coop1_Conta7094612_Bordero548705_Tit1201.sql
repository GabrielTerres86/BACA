DECLARE
  vr_vlmtatit craptdb.vlmtatit%TYPE;
  vr_vlmratit craptdb.vlmratit%TYPE;
  vr_vlioftit craptdb.vliofcpl%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
BEGIN
  -- Titulo deve ficar liberado, foi pago no mesmo dia do vencimento mas depois foi estornado e não teve mais nenhum pagamento.
  -- Excluir o pagamento do extrato da operação
  -- Calcular os juros de atraso. 
  
  UPDATE craptdb tdb
     SET insittit = 4
        ,dtdpagto = NULL 
        ,vlsldtit = 695
        ,vliofcpl = 0
        ,vlmtatit = 0
        ,vlmratit = 0
        ,vlpagiof = 0
        ,vlpagmta = 0
        ,vlpagmra = 0
   WHERE tdb.cdcooper = 1
     AND tdb.nrdconta = 7094612
     AND tdb.nrborder = 548705
     AND tdb.nrdocmto = 1201
     AND tdb.cdbandoc = 85
     AND tdb.nrdctabb = 101070
     AND tdb.nrcnvcob = 101070;
     

  DELETE tbdsct_lancamento_bordero lcb
   WHERE lcb.cdcooper = 1
     AND lcb.nrdconta = 7094612
     AND lcb.nrborder = 548705
     AND lcb.nrdocmto = 1201
     AND lcb.cdbandoc = 85
     AND lcb.nrdctabb = 101070
     AND lcb.nrcnvcob = 101070
     AND lcb.cdhistor = 2673
     AND lcb.dtmvtolt = to_date('07/03/2019','DD/MM/RRRR');


  DSCT0003.pc_calcula_atraso_tit
                                (pr_cdcooper => 1    
                                ,pr_nrdconta => 7094612 
                                ,pr_nrborder => 548705
                                ,pr_cdbandoc => 85
                                ,pr_nrdctabb => 101070
                                ,pr_nrcnvcob => 101070
                                ,pr_nrdocmto => 1201
                                ,pr_dtmvtolt => to_date('13/03/2019','DD/MM/RRRR')
                                ,pr_vlmtatit => vr_vlmtatit    
                                ,pr_vlmratit => vr_vlmratit    
                                ,pr_vlioftit => vr_vlioftit    
                                ,pr_cdcritic => vr_cdcritic    
                                ,pr_dscritic => vr_dscritic);
        
  IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
    raise_application_error(-20001,'Erro no calculo de juros: '||vr_cdcritic||' '||vr_dscritic); 
  END IF;
  
  UPDATE craptdb tdb
     SET vliofcpl = vr_vlioftit
        ,vlmtatit = vr_vlmtatit
        ,vlmratit = vr_vlmratit
   WHERE tdb.cdcooper = 1
     AND tdb.nrdconta = 7094612
     AND tdb.nrborder = 548705
     AND tdb.nrdocmto = 1201
     AND tdb.cdbandoc = 85
     AND tdb.nrdctabb = 101070
     AND tdb.nrcnvcob = 101070;
     
  COMMIT;
END;
