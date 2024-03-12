begin
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227355312;
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227355369;
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227355552;
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227357455;
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227357621;
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227357327;
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227357051;
	UPDATE cecred.craptit t SET t.nrispbds = 5463212 WHERE  t.progress_recid = 227356506;
	commit;
exception
  when others then
    rollback;
end;