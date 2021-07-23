BEGIN
  
  UPDATE crapaca
  SET lstparam = 'pr_cdcooper,pr_periodoini, pr_periodofim, pr_nrdconta ,pr_cdsegmto,pr_nrconven, pr_flagbarr,pr_canalpagamento '
  WHERE nmdeacao = 'EXPORTAR_CONV_BLOQPAG'
    AND nmpackag = 'TELA_CONBLQ';  
    
  COMMIT;
  
END;
  
