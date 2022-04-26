DECLARE 
  CURSOR cr_parc IS 
  SELECT p.cdcooper, p.nrdconta, p.nrctremp, MAX(p.dtdebitado) dtdebitado
    FROM credito.tbepr_parcelas_cred_imob p
   WHERE p.nrparcel > 0
     AND p.dtdebitado is not null
     AND p.idsituacao = 'D'
   GROUP BY p.cdcooper, p.nrdconta, p.nrctremp
   ORDER BY p.cdcooper, p.nrdconta, p.nrctremp;

BEGIN

  FOR rw_parc in cr_parc LOOP
    UPDATE credito.tbepr_contrato_imobiliario imob
       SET imob.dt_ultimo_pagamento = rw_parc.dtdebitado
     WHERE imob.cdcooper = rw_parc.cdcooper
       AND imob.nrdconta = rw_parc.nrdconta
       AND imob.nrctremp = rw_parc.nrctremp;
  END LOOP;
  COMMIT;
  
EXCEPTION
  WHEN others THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => 3);
END;