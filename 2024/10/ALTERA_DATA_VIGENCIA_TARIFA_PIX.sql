BEGIN
  update cecred.crapfco t set t.flgvigen = 1, t.dtvigenc = TRUNC('01/08/2024'), t.dtdivulg = TRUNC('01/08/2024') where t.progress_recid = 206975;
  COMMIT;
END;
