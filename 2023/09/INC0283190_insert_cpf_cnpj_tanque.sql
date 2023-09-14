declare

  v_total number := 0;

BEGIN

  for c in (
            
            SELECT a.nrcpfcgc, 'L' tpcooperado, 1 cdstatus, 1 tpcalculadora
              FROM CECRED.crapass a, CECRED.tbcadast_pessoa x
             WHERE a.dtdemiss is null
               AND x.nrcpfcgc = a.nrcpfcgc
               and a.nrcpfcgc in (80194385990, 12181065900)
            union
            SELECT a.nrcpfcgc, 'L' tpcooperado, 1 cdstatus, 2 tpcalculadora
              FROM CECRED.crapass a, CECRED.tbcadast_pessoa x
             WHERE a.dtdemiss is null
               AND x.nrcpfcgc = a.nrcpfcgc
               and a.nrcpfcgc in (46971389000113))
  
   loop
  
    INSERT INTO CECRED.tbcalris_tanque
      (nrcpfcgc, tpcooperado, cdstatus, tpcalculadora)
    VALUES
      (c.nrcpfcgc, c.tpcooperado, c.cdstatus, c.tpcalculadora);
    COMMIT;
  
    v_total := v_total + 1;
  
    dbms_output.put_line('nrcpfcgc - ' || c.nrcpfcgc);
    dbms_output.put_line('tpcooperado - ' || c.tpcooperado);
    dbms_output.put_line('cdstatus - ' || c.cdstatus);
    dbms_output.put_line('tpcalculadora - ' || c.tpcalculadora);
    dbms_output.put_line('');
  
  end loop;
  dbms_output.put_line('v_total - ' || v_total);

END;
