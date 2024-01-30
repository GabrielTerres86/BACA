BEGIN
  UPDATE gestaoderisco.tbrisco_crapris r
     SET r.cdagenci = (SELECT a.cdagenci 
                         FROM cecred.crapass a 
                        WHERE a.cdcooper = r.cdcooper
                          AND a.nrdconta = r.nrdconta)
   WHERE r.dtrefere = to_date('31/12/2023', 'DD/MM/RRRR');

  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;
