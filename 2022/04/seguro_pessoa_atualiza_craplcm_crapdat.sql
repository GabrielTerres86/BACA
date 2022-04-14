begin
  for rw in (select l.rowid, l.*
               from craplcm l
              where l.cdhistor = 3852
                and l.dtmvtolt = '14/04/2022'
                and l.cdcooper = 14) loop
    delete from craplcm l where l.rowid = rw.rowid;
  
    insert into craplcm
      (dtmvtolt,
       cdagenci,
       cdbccxlt,
       nrdolote,
       nrdconta,
       nrdocmto,
       cdhistor,
       nrseqdig,
       vllanmto,
       nrdctabb,
       cdpesqbb,
       vldoipmf,
       nrautdoc,
       nrsequni,
       cdbanchq,
       cdcmpchq,
       cdagechq,
       nrctachq,
       nrlotchq,
       sqlotchq,
       dtrefere,
       hrtransa,
       cdoperad,
       dsidenti,
       cdcooper,
       nrdctitg,
       dscedent,
       cdcoptfn,
       cdagetfn,
       nrterfin,
       nrparepr,
       nrseqava,
       nraplica,
       cdorigem,
       idlautom,
       dttrans)
    values
      (to_date('31/03/2022','dd/mm/rrrr'),
       rw.cdagenci,
       rw.cdbccxlt,
       rw.nrdolote,
       rw.nrdconta,
       rw.nrdocmto,
       rw.cdhistor,
       rw.nrseqdig+10,
       rw.vllanmto,
       rw.nrdctabb,
       rw.cdpesqbb,
       rw.vldoipmf,
       rw.nrautdoc,
       rw.nrsequni,
       rw.cdbanchq,
       rw.cdcmpchq,
       rw.cdagechq,
       rw.nrctachq,
       rw.nrlotchq,
       rw.sqlotchq,
       rw.dtrefere,
       rw.hrtransa,
       rw.cdoperad,
       rw.dsidenti,
       rw.cdcooper,
       rw.nrdctitg,
       rw.dscedent,
       rw.cdcoptfn,
       rw.cdagetfn,
       rw.nrterfin,
       rw.nrparepr,
       rw.nrseqava,
       rw.nraplica,
       rw.cdorigem,
       rw.idlautom,
       rw.dttrans);
  end loop;
  commit;
end;
/
BEGIN
  UPDATE crapdat p
     SET p.dtmvtolt = TO_DATE('01/04/2022','DD/MM/RRRR')
        ,p.dtmvtoan = TO_DATE('31/03/2022','DD/MM/RRRR')
        ,p.dtmvtopr = TO_DATE('04/04/2022','DD/MM/RRRR')
        ,p.dtmvtocd = TO_DATE('01/04/2022','DD/MM/RRRR')
   WHERE p.cdcooper = 14;
  COMMIT;
END;
/
