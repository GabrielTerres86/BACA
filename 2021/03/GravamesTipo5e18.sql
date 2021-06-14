begin
insert into craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) 
 SELECT nmsistem,
        tptabela,
        cdempres,
        cdacesso,
        5 tpregist,
        'AIMARO;0,00;89;0,00' dstextab,
        cdcooper
      FROM craptab 
     WHERE UPPER(craptab.nmsistem) = 'CRED'
       AND UPPER(craptab.tptabela) = 'GENERI'
       AND craptab.cdempres        = 0
       AND UPPER(craptab.cdacesso) = 'GRAVAMES'
       AND craptab.tpregist        = 112;
insert into craptab (nmsistem,tptabela,cdempres,cdacesso,tpregist,dstextab,cdcooper) 
 SELECT nmsistem,
        tptabela,
        cdempres,
        cdacesso,
        18 tpregist,
        'ADITIVO;0,00;102;0,00' dstextab,
        cdcooper
      FROM craptab 
     WHERE UPPER(craptab.nmsistem) = 'CRED'
       AND UPPER(craptab.tptabela) = 'GENERI'
       AND craptab.cdempres        = 0
       AND UPPER(craptab.cdacesso) = 'GRAVAMES'
       AND craptab.tpregist        = 112;       
Commit;       
exception
  when others then
   null;
end;       
