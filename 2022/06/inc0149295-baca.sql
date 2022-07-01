DECLARE

  CURSOR cr_reneg IS
    SELECT e.cdcooper
          ,e.nrdconta
          ,e.nrctremp
          ,e.dtmvtolt
          ,w.nrctrliq##1
          ,w.nrctrliq##2
      FROM crapepr e
      JOIN crawepr w
        ON w.cdcooper = e.cdcooper
       AND w.nrdconta = e.nrdconta
       AND w.nrctremp = e.nrctremp
     WHERE e.inliquid = 0
       AND e.inprejuz = 0
       AND w.flgreneg = 1
       AND e.tpemprst = 1
       AND e.dtmvtolt >= to_date('30/06/2022','dd/mm/yyyy')
       AND e.nrctremp = w.nrctrliq##1;

BEGIN

  FOR rw_reneg IN cr_reneg LOOP
  
    UPDATE crawepr w
       SET w.nrctrliq##1  = 0
          ,w.nrctrliq##2  = 0
          ,w.nrctrliq##3  = 0
          ,w.nrctrliq##4  = 0
          ,w.nrctrliq##5  = 0
          ,w.nrctrliq##6  = 0
          ,w.nrctrliq##7  = 0
          ,w.nrctrliq##8  = 0
          ,w.nrctrliq##9  = 0
          ,w.nrctrliq##10 = 0
     WHERE cdcooper = rw_reneg.cdcooper
       AND nrdconta = rw_reneg.nrdconta
       AND nrctremp = rw_reneg.nrctremp;
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
