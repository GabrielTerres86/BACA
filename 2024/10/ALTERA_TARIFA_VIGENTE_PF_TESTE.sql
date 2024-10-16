BEGIN
  update cecred.crapfco t set t.flgvigen = 1, t.dtvigenc = TO_DATE('01/01/2024', 'DD/MM/YYYY'), t.dtdivulg = TO_DATE('01/01/2024', 'DD/MM/YYYY') where t.progress_recid = 207026;
  COMMIT;
END;
