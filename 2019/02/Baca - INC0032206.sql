declare
  CURSOR cr_crapass IS
    select *
 from crapass s 
where s.cdcooper = 1
  and s.nrdconta in (1526588, 6663435, 9915060);
  rw_crapass cr_crapass%ROWTYPE;
 
  pr_cdcritic PLS_INTEGER; --> Código da crítica
  pr_dscritic VARCHAR2(4000);
  pr_nmdcampo VARCHAR2(4000);
  pr_des_erro VARCHAR2(4000);
  
begin
 begin    
  DELETE tbcotas_devolucao t
   WHERE t.cdcooper = 1
     AND t.nrdconta in (1526588, 6663435, 9915060)
     and t.tpdevolucao = 1;   
 end;
             
  FOR rw_crapass IN cr_crapass LOOP
  -- Call the procedure
    cecred.cada0003.pc_efetuar_desligamento_bacen(pr_cdcooper  => rw_crapass.cdcooper
                                                 ,pr_nrdconta  => rw_crapass.nrdconta
                                                 ,pr_idorigem  => 1
                                                 ,pr_cdoperad  => 1
                                                 ,pr_nrdcaixa  => 999
                                                 ,pr_nmdatela  => 'BACA'
                                                 ,pr_cdagenci  => rw_crapass.cdagenci
                                                 ,pr_cdcritic  => pr_cdcritic
                                                 ,pr_dscritic  => pr_dscritic
                                                 ,pr_nmdcampo  => pr_nmdcampo
                                                 ,pr_des_erro  => pr_des_erro);
                                              
                                               
  IF NVL(PR_CDCRITIC, 0) > 0 THEN
    DBMS_OUTPUT.put_line('CDCRITIC = ' || PR_CDCRITIC || ' Número de conta = ' || rw_crapass.nrdconta);
  END IF;
  IF pr_dscritic IS NOT NULL THEN
    DBMS_OUTPUT.put_line('DSCRITIC = ' || pr_dscritic || ' Número de conta = ' || rw_crapass.nrdconta);
  END IF;
  IF pr_nmdcampo IS NOT NULL THEN
    DBMS_OUTPUT.put_line('NMDCAMPO = ' || pr_nmdcampo || ' Número de conta = ' || rw_crapass.nrdconta);
  END IF;
  IF pr_des_erro IS NOT NULL THEN
    DBMS_OUTPUT.put_line('DESERRO = ' || pr_des_erro || ' Número de conta = ' || rw_crapass.nrdconta);
  END IF;
  COMMIT;  
END LOOP;  

end;
