BEGIN
DELETE from tbinss_notif_benef_sicredi c
where c.cdcooper=1
and c.nrdconta in(329,90264878,90267737,396,90267702,280,90168070,90169042,191,2114186,18580680);

COMMIT;
END;