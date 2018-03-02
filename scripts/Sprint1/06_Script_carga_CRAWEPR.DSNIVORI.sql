declare
  conta  number(10) :=0;

  CURSOR cr_risco IS
  select t.cdcooper
       , t.nrdconta
       , t.nrctremp
       , t.dsnivris
    from CRAWEPR t ;
  rw_risco cr_risco%ROWTYPE;

begin

  open cr_risco;

  loop
    fetch cr_risco into rw_risco;
    exit when cr_risco%notfound;

--    conta := conta + 1;

--    dbms_output.put_line('Update '||conta);

    update CRAWEPR
       set DSNIVORI = rw_risco.DSNIVRIS
     where CDCOOPER = rw_risco.CDCOOPER
       and NRDCONTA = rw_risco.NRDCONTA
       and NRCTREMP = rw_risco.NRCTREMP;

  end loop;

  COMMIT;
  close cr_risco;
end;
