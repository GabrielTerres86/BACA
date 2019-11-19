DECLARE
  vr_existe_empresa number := 0;
  vr_existe  number := 0;
  vr_cdempres crapemp.cdempres%type := 9999;  
  
  cursor cr_coop is
    select cdcooper
      from crapcop t
     where flgativo = 1
     order by t.cdcooper; 
     
  cursor cr_emp(pr_cdcooper number) is 
    select 1
      from crapemp t
     where t.cdempres = vr_cdempres  
       and t.cdcooper = pr_cdcooper;
  
  CURSOR cr_craptab(pr_tptabela in varchar2,
                    pr_cempres  in number,
                    pr_cdacesso in varchar2,
                    pr_tpregist in number,
                    pr_dstextab in varchar2,
                    pr_cdcooper in number) IS  
    SELECT 1 
      FROM craptab
     WHERE upper(craptab.Nmsistem) = 'CRED'
       AND upper(craptab.tptabela) = pr_tptabela
       AND craptab.cdempres = pr_cempres
       AND upper(craptab.cdacesso) = pr_cdacesso
       AND craptab.tpregist = pr_tpregist
       AND craptab.dstextab = pr_dstextab
       AND craptab.cdcooper = pr_cdcooper;           
  
BEGIN
  FOR rw_coop IN cr_coop LOOP
    OPEN cr_emp(rw_coop.cdcooper);
    FETCH cr_emp into vr_existe_empresa; 
    IF cr_emp%NOTFOUND THEN
      
      insert into CECRED.CRAPEMP
        (CDEMPRES,
         NMEXTEMP,
         NMRESEMP,
         SGEMPRES,
         CDDESCTO##1,
         CDDESCTO##2,
         CDDESCTO##3,
         CDDESCTO##4,
         CDDESCTO##5,
         CDDESCTO##6,
         CDDESCTO##7,
         CDDESCTO##8,
         CDDESCTO##9,
         CDDESCTO##10,
         DTAVSCOT,
         DTAVSEMP,
         INAVSCOT,
         INAVSEMP,
         TPDEBCOT,
         TPDEBEMP,
         TPDEBDEN,
         INAVSDEN,
         DTAVSDEN,
         TPDEBPPR,
         INAVSPPR,
         DTAVSPPR,
         CDEMPFOL,
         FLGPAGTO,
         DTAVSSEG,
         INAVSSEG,
         TPDEBSEG,
         DTAVSSAU,
         INAVSSAU,
         TPDEBSAU,
         TPCONVEN,
         INDESCSG,
         DTFCHFOL,
         NRARQEPR,
         DSDEMAIL,
         CDUFDEMP,
         NRDOCNPJ,
         DSENDEMP,
         DSCOMPLE,
         NMBAIRRO,
         NRFONEMP,
         NMCIDADE,
         NRFAXEMP,
         NRCEPEND,
         NRENDEMP,
         CDCOOPER,
         FLGARQRT,
         FLGVLDDV,
         PROGRESS_RECID,
         CDCONTAR,
         NRDCONTA,
         IDTPEMPR,
         DTULTUFP,
         DTAVSUFP,
         FLGPGTIB,
         VLLIMFOL,
         NMCONTAT,
         FLGDGFIB,
         CDOPERAD,
         CDOPEORI,
         CDAGEORI,
         DTINSORI,
         DTLIMDEB,
         DTINCCAN,
         NRDDDEMP)
      values
        (vr_cdempres,
         'DESLIGADO CONSIGNADO',
         'DESLIG CONSIG',
         'F',
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         0,
         null,
         null,
         0,
         0,
         1,
         1,
         0,
         0,
         null,
         1,
         0,
         null,
         0,
         0,
         null,
         0,
         0,
         null,
         0,
         0,
         0,
         1,
         20,
         0,
         ' ',
         ' ',
         0,
         ' ',
         ' ',
         ' ',
         ' ',
         ' ',
         ' ',
         0,
         0,
         rw_coop.cdcooper,
         0,
         1,
         null,--PROGRESS_RECID
         0,
         0,
         'O',
         null,
         null,
         0,
         0.00,
         ' ',
         0,
         ' ',
         ' ',
         0,
         null,
         10,
         null,
         null);

      dbms_output.put_line('Cooperativa: '||rw_coop.cdcooper || ' empresa: '|| vr_cdempres );     
    END IF; 
    CLOSE cr_emp; 
    
    --'DIADOPAGTO'
    OPEN cr_craptab('GENERI',
                    0, 
                    'DIADOPAGTO',
                    vr_cdempres,
                    '10 01 01 270 0',
                    rw_coop.cdcooper); 
    FETCH cr_craptab into vr_existe; 
    IF cr_craptab%NOTFOUND THEN
      insert into craptab (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO, TPREGIST, DSTEXTAB, CDCOOPER)
      values ('CRED', 'GENERI', 0, 'DIADOPAGTO', vr_cdempres, '10 01 01 270 0', rw_coop.cdcooper);
      dbms_output.put_line('DIADOPAGTO: '||rw_coop.cdcooper  );     
    END IF; 
    CLOSE cr_craptab; 
    
    --'NUMLOTECOT'
    OPEN cr_craptab('GENERI',
                    0, 
                    'NUMLOTECOT',
                    vr_cdempres,
                    '809999',
                    rw_coop.cdcooper); 
    FETCH cr_craptab into vr_existe; 
    IF cr_craptab%NOTFOUND THEN
      insert into craptab (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO, TPREGIST, DSTEXTAB, CDCOOPER)
      values ('CRED', 'GENERI', 0, 'NUMLOTECOT', vr_cdempres, '809999', rw_coop.cdcooper);
      dbms_output.put_line('NUMLOTECOT: '||rw_coop.cdcooper  );     
    END IF; 
    CLOSE cr_craptab;
    
    --'NUMLOTEEMP'
    OPEN cr_craptab('GENERI',
                    0, 
                    'NUMLOTEEMP',
                    vr_cdempres,
                    '509999',
                    rw_coop.cdcooper); 
    FETCH cr_craptab into vr_existe; 
    IF cr_craptab%NOTFOUND THEN
      insert into craptab (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO, TPREGIST, DSTEXTAB, CDCOOPER)
      values ('CRED', 'GENERI', 0, 'NUMLOTEEMP', vr_cdempres, '509999', rw_coop.cdcooper);
      dbms_output.put_line('NUMLOTEEMP: '||rw_coop.cdcooper  );     
    END IF; 
    CLOSE cr_craptab;
    
    --'NUMLOTEFOL'
    OPEN cr_craptab('GENERI',
                    0, 
                    'NUMLOTEFOL',
                    vr_cdempres,
                    '909999',
                    rw_coop.cdcooper); 
    FETCH cr_craptab into vr_existe; 
    IF cr_craptab%NOTFOUND THEN
      insert into craptab (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO, TPREGIST, DSTEXTAB, CDCOOPER)
      values ('CRED', 'GENERI', 0, 'NUMLOTEFOL', vr_cdempres, '909999', rw_coop.cdcooper);
      dbms_output.put_line('NUMLOTEFOL: '||rw_coop.cdcooper  );     
    END IF; 
    CLOSE cr_craptab;
   
    --'VLTARIF008'
    OPEN cr_craptab('USUARI',
                    9999, 
                    'VLTARIF008',
                    1,
                    ',',
                    rw_coop.cdcooper); 
    FETCH cr_craptab into vr_existe; 
    IF cr_craptab%NOTFOUND THEN
      insert into craptab (NMSISTEM, TPTABELA, CDEMPRES, CDACESSO, TPREGIST, DSTEXTAB, CDCOOPER)
      values ('CRED', 'USUARI', 9999, 'VLTARIF008', 1, ',', rw_coop.cdcooper);
      dbms_output.put_line('VLTARIF008: '||rw_coop.cdcooper  );     
    END IF; 
    CLOSE cr_craptab;    
      
  END LOOP;
  
  COMMIT; 
  
END;
