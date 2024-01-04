begin 
  
insert into cecred.craplau
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanaut, tpdvalor, insitlau, dtmvtopg, cdbccxpg, nrdctabb, cdcritic, dtdebito, nrcrcard,
   cdseqtel, cdcooper, hrtransa, dsorigem, dscedent)
values
  (TRUNC(SYSDATE), 1, 100, 6629, 97802212, 18422616, 48, 28.94, 1, 2, TRUNC(SYSDATE), 11, 97802212, 0, TRUNC(SYSDATE), 18422616,
   202405, 1, 0, 'DEBAUT', 'CASAN');
insert into cecred.craplau
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanaut, tpdvalor, insitlau, dtmvtopg, cdbccxpg, nrdctabb, cdcritic, dtdebito, nrcrcard,
   cdseqtel, cdcooper, hrtransa, dsorigem, dscedent)
values
  (TRUNC(SYSDATE), 1, 100, 6628, 97802212, 18422616, 48, 28.95, 1, 2, TRUNC(SYSDATE), 11, 97802212, 0, TRUNC(SYSDATE), 18422616,
   202406, 1, 0, 'DEBAUT', 'CASAN');
insert into cecred.craplcm
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanmto, nrdctabb, cdcooper)
values
  (TRUNC(SYSDATE), 1, 100, 10003, 97802212, 18422616, 48, 28.94, 97802212,1);
  
insert into cecred.craplcm
  (dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrdconta, nrdocmto, cdhistor, vllanmto, nrdctabb, cdcooper)
values
  (TRUNC(SYSDATE), 1, 100, 10004, 97802212, 18422616, 48, 28.95, 97802212,1);
commit;
end;
