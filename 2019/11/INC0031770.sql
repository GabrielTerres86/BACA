declare
  cursor c1 is
    SELECT c.cdcooper
         , x.dtmvtolt
      FROM crapdat x
         , crapcop c
     WHERE x.cdcooper = c.cdcooper
       AND c.flgativo = 1;

begin
  for r1 in c1 loop
    for i in 0..60 loop
      begin
        insert into craplot(dtmvtolt, cdagenci, cdbccxlt, nrdolote, nrseqdig, qtcompln, qtinfoln, tplotmov, vlcompcr, vlcompdb, vlinfodb, vlinfocr, tpdmoeda, cdbccxpg, qtinfocc, qtcompcc, vlinfocc, vlcompcc, qtcompcs, qtinfocs, vlcompcs, vlinfocs, qtcompci, qtinfoci, vlcompci, vlinfoci, nrautdoc, flgltsis, cdcooper,cdoperad,cdhistor,nrdcaixa,cdopecxa)
        values ((r1.dtmvtolt + i),1,100,7050,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,r1.cdcooper,null,null,null,null);
      exception
        when dup_val_on_index then
          null;
      end;
    end loop;
  end loop;
  
  commit;
end;