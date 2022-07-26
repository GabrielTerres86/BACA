BEGIN
    DELETE 
      FROM craplem cl 
     WHERE cl.nrdconta = 25364 
       AND cl.cdcooper = 8 
       AND cl.nrctremp = 10711 
       AND cl.dtmvtolt = to_date('14/07/2022','DD/MM/YYYY');

     UPDATE tbepr_consig_movimento_tmp tcm
        SET tcm.instatusproces = NULL
      WHERE tcm.cdcooper    = 8
        AND tcm.nrdconta    = 25364
        AND tcm.nrctremp    = 10711
        AND tcm.intplancamento = 7;
        
 COMMIT;

EXCEPTION
  
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
  
END;
