Declare
  
  Cursor cr_lcm (p_nrdconta number)is
       select lcm.cdcooper, 
              lcm.dtmvtolt, 
              lcm.cdagenci,
              lcm.cdbccxlt, 
              lcm.nrdolote, 
        lcm.nrdconta,
             (select nvl(max(nrseqdig)+1,1) 
                from craplcm b 
               where b.cdcooper = lcm.cdcooper
                 and b.dtmvtolt = to_Date('31/07/2023','dd/mm/yyyy')
                 and b.cdagenci = lcm.cdagenci
                 and b.cdbccxlt = lcm.cdbccxlt
                 and b.nrdolote = lcm.nrdolote) NRSEQDIG
         from cecred.craplcm lcm
        where lcm.cdcooper = 1 
          and lcm.nrdconta = p_nrdconta
          and lcm.dtmvtolt = to_Date('01/08/2023','dd/mm/yyyy')
          and lcm.cdhistor = 2972;
  rg_lcm cr_lcm%rowtype;
  
  CURSOR cr_contas is
    SELECT contas.cdcooper, contas.nrdconta
        from (select 1 as cdcooper, 850004  as nrdconta from dual
              union all
              select 1 as cdcooper, 11613491  as nrdconta from dual
              union all
              select 1 as cdcooper, 11460555  as nrdconta from dual
              union all
              select 1 as cdcooper, 8579997  as nrdconta from dual
              union all
              select 1 as cdcooper, 10430210  as nrdconta from dual
              ) contas;
BEGIN
  
  for rg_contas in cr_contas LOOP
       
     open cr_lcm(rg_contas.nrdconta);
     fetch cr_lcm into rg_lcm;
	 if cr_lcm%found then
        if rg_lcm.nrdconta   = 11613491 THEN
           insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
             values (to_date('31/07/2023', 'dd/mm/yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 11613491, 1, 2972, rg_lcm.nrseqdig, 10250.02, 11613491, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30304, 'F0015969', ' ', 1, '11613491', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:25:04,000000');
	    
        
        elsif rg_lcm.nrdconta = 8579997 THEN
              insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
                values (to_date('31/07/2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 8579997, 1, 2972, rg_lcm.nrseqdig, 100410.37, 8579997, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30472, 'F0015969', ' ', 1, '08579997', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:27:52,000000');
	    
        
        elsif rg_lcm.nrdconta = 11460555 THEN
              insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
                values (to_date('31/07/2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 11460555, 1, 2972, rg_lcm.nrseqdig, 6332.16, 11460555, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30356, 'F0015969', ' ', 1, '11460555', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:25:56,000000');
	    
           
        elsif rg_lcm.nrdconta = 10430210 THEN
              insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
                values (to_date('31/07/2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 10430210, 1, 2972, rg_lcm.nrseqdig, 4849.03, 10430210, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30525, 'F0015969', ' ', 1, '10430210', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:28:45,000000');
	    
        elsif rg_lcm.nrdconta = 850004 THEN
              insert into cecred.craplcm (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, VLLANMTO, NRDCTABB, CDPESQBB, VLDOIPMF, NRAUTDOC, NRSEQUNI, CDBANCHQ, CDCMPCHQ, CDAGECHQ, NRCTACHQ, NRLOTCHQ, SQLOTCHQ, DTREFERE, HRTRANSA, CDOPERAD, DSIDENTI, CDCOOPER, NRDCTITG, DSCEDENT, CDCOPTFN, CDAGETFN, NRTERFIN, NRPAREPR, PROGRESS_RECID, NRSEQAVA, NRAPLICA, CDORIGEM, IDLAUTOM, DTTRANS)
                values (to_date('31/07/2023', 'dd-mm-yyyy'), rg_lcm.cdagenci, rg_lcm.cdbccxlt, rg_lcm.nrdolote, 850004, 2, 2972, rg_lcm.nrseqdig, 118973.65, 850004, '         0', 0.00, 0, 0, 0, 0, 0, 0, 0, 0, null, 30583, 'F0015969', ' ', 1, '00850004', ' ', 0, 0, 0, 0, null, 0, 0, 0, 0, '01/08/23 08:29:43,000000');
	    
        end if;
     end if;
     
     close cr_lcm;
   
   
   
   
   end loop;
  
   delete from cecred.craplcm lcm
   where lcm.nrdconta in (850004,11613491,11460555,8579997,10430210)
     and lcm.cdcooper = 1
     and lcm.dtmvtolt = to_Date('01/08/2023','dd/mm/yyyy')
     and lcm.cdhistor = 2972;


    commit;
END;
