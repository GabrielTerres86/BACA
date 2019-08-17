PL/SQL Developer Test script 3.0
31
declare 
  i integer;

  CURSOR cr_cop IS
    SELECT cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1
       ORDER BY cdcooper  
   ;
BEGIN
  
  FOR rw_cop IN cr_cop LOOP
    
    dbms_output.put_line(rw_cop.cdcooper || ' INSERT');
    INSERT INTO TBRISCO_CENTRAL_PARAMETROS 
            (cdcooper
            ,perc_liquid_sem_garantia
            ,perc_cobert_aplic_bloqueada
            ,inrisco_melhora_minimo
            ,dthr_alteracao
            ,cdoperador_alteracao)
     values (rw_cop.cdcooper -- Cooperativa
            , 20             -- perc_liquid_sem_garantia
            , 70             -- perc_cobert_aplic_bloqueada
            ,2               -- inrisco_melhora_minimo
            ,SYSDATE         -- dthr_alteracao
            ,'1');           -- cdoperador_alteracao

  END LOOP;
  COMMIT;
END;
0
0
