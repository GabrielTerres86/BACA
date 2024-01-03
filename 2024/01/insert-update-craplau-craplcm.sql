
begin 
  
update CECRED.CRAPATR ATR set ATR.CDREFERE = 18187561
where ATR.PROGRESS_RECID = 2473084 AND ATR.CDHISTOR = 48 AND ATR.NRDCONTA = 97213543 ;

insert into cecred.craplau
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanaut, tpdvalor, insitlau, dtmvtopg, cdbccxpg, nrdctabb, cdcritic, dtdebito, nrcrcard,
   cdseqtel, cdcooper, hrtransa, dsorigem, dscedent)
values
  (TRUNC(SYSDATE), 1, 100, 6620, 97213543, 18187560, 48, 58.94, 1, 2, TRUNC(SYSDATE), 11, 97213543, 0, TRUNC(SYSDATE), 18187560,
   202401, 1, 0, 'DEBAUT', 'CASAN');

insert into cecred.craplau
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanaut, tpdvalor, insitlau, dtmvtopg, cdbccxpg, nrdctabb, cdcritic, dtdebito, nrcrcard,
   cdseqtel, cdcooper, hrtransa, dsorigem, dscedent)
values
  (TRUNC(SYSDATE), 1, 100, 6621, 97213543, 18187561, 48, 58.95, 1, 2, TRUNC(SYSDATE), 11, 97213543, 0, TRUNC(SYSDATE), 18187561,
   202402, 1, 0, 'DEBAUT', 'CASAN');

insert into cecred.craplcm
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanmto, nrdctabb)
values
  (TRUNC(SYSDATE), 1, 100, 10001, 97213543, 18187560, 48, 58.94, 97213543);
  
insert into cecred.craplcm
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanmto, nrdctabb)
values
  (TRUNC(SYSDATE), 1, 100, 10002, 97213543, 18187561, 48, 58.95, 97213543);

commit;
end;


