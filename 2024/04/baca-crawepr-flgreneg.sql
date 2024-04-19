DECLARE

  CURSOR cr_reneg IS
    SELECT w.cdcooper, w.nrdconta, w.nrctremp, e.dtmvtolt
      FROM cecred.crawepr w
      JOIN cecred.crapepr e
        ON e.cdcooper = w.cdcooper
       AND e.nrdconta = w.nrdconta
       AND e.nrctremp = w.nrctremp
     WHERE w.flgreneg = 1
       AND e.inliquid = 0
       AND NOT EXISTS (SELECT 1
              FROM cecred.tbepr_renegociacao_contrato trc
             WHERE trc.cdcooper = w.cdcooper
               AND trc.nrdconta = w.nrdconta
               AND ((trc.nrctrepr = w.nrctremp) OR
                   (trc.nrctremp_novo = w.nrctremp)));


BEGIN

  FOR rw_reneg IN cr_reneg LOOP
    UPDATE cecred.crawepr
       SET flgreneg = 0
     WHERE cdcooper = rw_reneg.cdcooper
       AND nrdconta = rw_reneg.nrdconta
       AND nrctremp = rw_reneg.nrctremp;
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
