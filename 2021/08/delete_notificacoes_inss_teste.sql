BEGIN
DELETE from tbinss_notif_benef_sicredi c
where c.cdcooper=1
and c.nrdconta=396;
 
COMMIT;
END;