declare

  CURSOR cr_crapass IS
    select *
 from crapass s 
where s.cdcooper = 1
  and s.nrdconta in (7796498
                    ,9033050
                    ,7351771
                    ,7722150
                    ,8634289
                    ,2365430
                    ,8208786
                    ,7430477
                    ,9498230
                    ,10069798
                    ,7633734            
                    ,9981551
                    ,1526588
                    ,9697390
                    ,8425027
                    ,8525579
                    ,9253904
                    ,3725804
                    ,7355297
                    ,8665664
                    ,9396543
                    ,9070745
                    ,9926143
                    ,8296170
                    ,9913513
                    ,6641237
                    ,9154167
                    ,6663435
                    ,1526588);
  rw_crapass cr_crapass%ROWTYPE;
 
  pr_cdcritic PLS_INTEGER; --> C�digo da cr�tica
  pr_dscritic VARCHAR2(4000);
  pr_nmdcampo VARCHAR2(4000);
  pr_des_erro VARCHAR2(4000);
  
begin
      
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
    DBMS_OUTPUT.put_line('CDCRITIC = ' || PR_CDCRITIC || ' N�mero de conta = ' || rw_crapass.nrdconta);
  END IF;
  IF pr_dscritic IS NOT NULL THEN
    DBMS_OUTPUT.put_line('DSCRITIC = ' || pr_dscritic || ' N�mero de conta = ' || rw_crapass.nrdconta);
  END IF;
  IF pr_nmdcampo IS NOT NULL THEN
    DBMS_OUTPUT.put_line('NMDCAMPO = ' || pr_nmdcampo || ' N�mero de conta = ' || rw_crapass.nrdconta);
  END IF;
  IF pr_des_erro <> 'OK' THEN
    DBMS_OUTPUT.put_line('DESERRO = ' || pr_des_erro || ' N�mero de conta = ' || rw_crapass.nrdconta);
  END IF;
  COMMIT;
END LOOP; 
  
EXCEPTION
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION(pr_compleme => 'INC0030253' || pr_cdcritic || ' - '  || pr_dscritic || ' - '  || SQLERRM);
    ROLLBACK;  
end;
