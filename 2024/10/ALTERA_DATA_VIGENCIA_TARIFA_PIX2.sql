BEGIN
  update cecred.crapfco t set t.flgvigen = 1, t.dtvigenc = TO_DATE('01/08/2024', 'DD/MM/YYYY'), t.dtdivulg = TO_DATE('01/08/2024', 'DD/MM/YYYY') where t.progress_recid = 206975;
  COMMIT;
END;
