begin

insert into cecred.craplau 
  (cdcooper,nrdconta,idseqttl,dttransa,hrtransa,dtmvtolt,cdagenci,cdbccxlt,nrdolote,nrseqdig,nrdocmto,cdhistor,dsorigem
   ,insitlau,cdtiptra,dscedent,dscodbar,dslindig,dtmvtopg,vllanaut,dtvencto,cddbanco,cdageban,nrctadst,cdcoptfn,cdagetfn
   ,nrterfin,nrcpfope,nrcpfpre,nmprepos,idtitdda,tpdvalor,cdempres)
values (3,99999927,1,sysdate,null,to_date('22/07/2024','dd/mm/yyyy'),1,100,11900,22880,22880,3049,'CRPS391'
  ,1,5,'CRPS391','',' ',to_date('24/07/2024','dd/mm/yyyy'),151.18,null,85,101,9084800,0,0,0,0,0,'',0,2,263);
  
commit;
end;
