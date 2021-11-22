begin
  for st_row in (select x.nrctremp, p.nrctrseg, p.cdcooper, p.nrdconta
                   FROM tbseg_prestamista p, craplau x
                  WHERE p.tpcustei = 0
                    AND p.tpregist <> 0
                    and p.nrdconta = x.nrdconta
                    and x.cdcooper = p.cdcooper
                    and x.insitlau in (1, 3)
                    and x.cdhistor = 3651) loop
  
    UPDATE craplau x
       SET x.nrctremp = st_row.nrctrseg
     WHERE x.nrdconta = st_row.nrdconta
       AND x.cdcooper = st_row.cdcooper;
  end loop;
  commit;
exception when others then
  rollback;
  dbms_output.put_line(sqlerrm);  
end;
/
