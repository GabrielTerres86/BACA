declare
  V_IDPRM_LIMITE pls_integer;
begin
  insert into tbcc_parametriza_limite (CDCOOPER, CDPRODUTO, FLGATIVO, QTDIAS_CARENCIA)
  values (0, 53, 1, 120)
  returning IDPRM_LIMITE into V_IDPRM_LIMITE;
  
  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,5000,3000);

  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,10000,5000);
                                      
  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,50000,10000);
                                      
  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,100000,20000);
                                      
  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,250000,25000);                                                                            

  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,500000,35000);                                                                            

  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,1000000,50000);                                                                            

  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,2000000,100000);                                                                            

  insert into tbcc_parametriza_faixa_limite (idprm_limite,vlfaixa_ate,vlaumento_permitido)
                                      values(V_IDPRM_LIMITE,999999999,150000);        

  commit;
									  
end;  


