begin 
  
insert into cecred.craplau
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanaut, tpdvalor, insitlau, dtmvtopg, cdbccxpg, nrdctabb, cdcritic, dtdebito, nrcrcard,
   cdseqtel, cdcooper, hrtransa, dsorigem, dscedent)
values
  (TRUNC(SYSDATE)-1, 1, 100, 6630, 97802212, 18766218, 48, 18.94, 1, 2, TRUNC(SYSDATE), 11, 97802212, 0, TRUNC(SYSDATE), 18766218,
   202407, 1, 0, 'DEBAUT', 'CASAN');
insert into cecred.craplau
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanaut, tpdvalor, insitlau, dtmvtopg, cdbccxpg, nrdctabb, cdcritic, dtdebito, nrcrcard,
   cdseqtel, cdcooper, hrtransa, dsorigem, dscedent)
values
  (TRUNC(SYSDATE), 1, 100, 6631, 97802212, 187662180, 48, 18.95, 1, 2, TRUNC(SYSDATE), 11, 97802212, 0, TRUNC(SYSDATE), 18766218,
   202407, 1, 0, 'DEBAUT', 'CASAN');
insert into cecred.craplcm
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanmto, nrdctabb, cdcooper)
values
  (TRUNC(SYSDATE)-1, 1, 100, 10005, 97802212, 18766218, 48, 18.94, 97802212,1);
  
insert into cecred.craplcm
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanmto, nrdctabb, cdcooper)
values
  (TRUNC(SYSDATE), 1, 100, 10006, 97802212, 187662180, 48, 18.95, 97802212,1);
commit;
end;


