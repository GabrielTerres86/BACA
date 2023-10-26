DECLARE
  vr_dtrefere DATE := to_date('30/09/2023', 'DD/MM/RRRR');
  
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
     ORDER BY c.cdcooper DESC;
  rw_crapcop cr_crapcop%ROWTYPE;
BEGIN

  FOR rw_crapcop IN cr_crapcop LOOP
    UPDATE gestaoderisco.tbrisco_crapris r 
       SET r.cdmodalidade_bacen = (SELECT h.cdmodalidade 
                                     FROM gestaoderisco.htrisco_central_retorno h
                                    WHERE h.cdcooper = r.cdcooper
                                      AND h.nrconta = r.nrdconta
                                      AND h.nrcontrato = r.nrctremp
                                      AND h.dtreferencia = r.dtrefere
                                      AND h.cdproduto = r.nrseqctr
                                      )
     WHERE r.cdcooper = rw_crapcop.cdcooper
       AND r.dtrefere = vr_dtrefere
       AND r.cdmodali IN (299,499);
    
    COMMIT;
    
  END LOOP;
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20000, SQLERRM);
END;