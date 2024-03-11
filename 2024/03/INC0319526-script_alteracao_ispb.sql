begin
	update cecred.craptit t set t.nrispbds = 60701190 WHERE  t.progress_recid = 227352627;
	update cecred.craptit t set t.nrispbds = 2038232 WHERE  t.progress_recid = 227353752;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227353815;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227353887;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227354647;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227354809;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227355147;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227355148;
	update cecred.craptit t set t.nrispbds = 58160789 WHERE  t.progress_recid = 227355337;
	update cecred.craptit t set t.nrispbds = 60701190 WHERE  t.progress_recid = 227356159;
	update cecred.craptit t set t.nrispbds = 60701190 WHERE  t.progress_recid = 227356195;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227357302;
	update cecred.craptit t set t.nrispbds = 2038232 WHERE  t.progress_recid = 227357332;
	update cecred.craptit t set t.nrispbds = 60701190 WHERE  t.progress_recid = 227357441;
	update cecred.craptit t set t.nrispbds = 90400888 WHERE  t.progress_recid = 227357540;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227352909;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227353578;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227355966;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227357108;
	update cecred.craptit t set t.nrispbds = 1181521 WHERE  t.progress_recid = 227353463;
	update cecred.craptit t set t.nrispbds = 90400888 WHERE  t.progress_recid = 227356084;
	update cecred.craptit t set t.nrispbds = 90400888 WHERE  t.progress_recid = 227353709;
	update cecred.craptit t set t.nrispbds = 1181521 WHERE  t.progress_recid = 227356121;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227357238;
	update cecred.craptit t set t.nrispbds = 90400888 WHERE  t.progress_recid = 227353630;
	update cecred.craptit t set t.nrispbds = 60746948 WHERE  t.progress_recid = 227355426;
	commit;
exception
  when others then
    rollback;
end;
