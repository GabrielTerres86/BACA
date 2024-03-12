begin
	UPDATE cecred.craptit t SET t.nrispbds = 2038232, t.flgenvio = 0 WHERE  t.progress_recid = 227352768;
	UPDATE cecred.craptit t SET t.nrispbds = 90400888, t.flgenvio = 0 WHERE  t.progress_recid = 227352858;
	UPDATE cecred.craptit t SET t.nrispbds = 360305, t.flgenvio = 0 WHERE  t.progress_recid = 227354922;
	UPDATE cecred.craptit t SET t.nrispbds = 60701190, t.flgenvio = 0 WHERE  t.progress_recid = 227355301;
	UPDATE cecred.craptit t SET t.nrispbds = 90400888, t.flgenvio = 0 WHERE  t.progress_recid = 227355471;
	UPDATE cecred.craptit t SET t.nrispbds = 60746948, t.flgenvio = 0 WHERE  t.progress_recid = 227357091;
	UPDATE cecred.craptit t SET t.nrispbds = 60701190, t.flgenvio = 0 WHERE  t.progress_recid = 227353842;
	UPDATE cecred.craptit t SET t.nrispbds = 90400888, t.flgenvio = 0 WHERE  t.progress_recid = 227356107;
	UPDATE cecred.craptit t SET t.nrispbds = 60701190, t.flgenvio = 0 WHERE  t.progress_recid = 227356536;
	commit;
exception
  when others then
    rollback;
end;