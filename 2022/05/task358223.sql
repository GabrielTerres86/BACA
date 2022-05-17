begin
  update cecred.crappep pep
     set pep.vlparepr = 127.06,
         pep.vlsdvpar = 127.06,
         pep.vlsdvsji = 127.06,
         pep.dtvencto = add_months(pep.dtvencto,2)
   where pep.cdcooper = 1
     and pep.nrdconta = 11866896
     and pep.nrctremp = 5223743;
     
  update cecred.CRAWEPR w
     set w.vlpreemp = 127.06,
         w.vlpreori = 127.06,
         w.txminima = 2.71,
         w.txbaspre = 2.71,
         w.txmensal = 2.71,
         w.txorigin = 2.71
   where w.cdcooper = 1
     and w.nrdconta = 11866896
     and w.nrctremp = 5223743;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 127.06,
         epr.txmensal = 2.71
   where epr.cdcooper = 1
     and epr.nrdconta = 11866896
     and epr.nrctremp = 5223743;

  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto,1)
   where pep.cdcooper = 1
     and pep.nrdconta = 14534606
     and pep.nrctremp = 5379655;
	 
  update cecred.crappep pep
     set pep.vlparepr = 958.95,
         pep.vlsdvpar = 958.95,
         pep.vlsdvsji = 958.95,
         pep.dtvencto = add_months(pep.dtvencto,3)
   where pep.cdcooper = 1
     and pep.nrdconta = 80145264
     and pep.nrctremp = 5206569;
     
  update cecred.CRAWEPR w
     set w.vlpreemp = 958.95,
         w.vlpreori = 958.95,
         w.txminima = 1.77,
         w.txbaspre = 1.77,
         w.txmensal = 1.77,
         w.txorigin = 1.77
   where w.cdcooper = 1
     and w.nrdconta = 80145264
     and w.nrctremp = 5206569;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 958.95,
         epr.txmensal = 1.77
   where epr.cdcooper = 1
     and epr.nrdconta = 80145264
     and epr.nrctremp = 5206569;
	 
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto,5)
   where pep.cdcooper = 1
     and pep.nrdconta = 7668732
     and pep.nrctremp = 4885568;

  update cecred.crappep pep
     set pep.vlparepr = 1265.45,
         pep.vlsdvpar = 1265.45,
         pep.vlsdvsji = 1265.45
   where pep.cdcooper = 1
     and pep.nrdconta = 80090842
     and pep.nrctremp = 5204912;
	 
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto,2)
   where pep.cdcooper = 7
     and pep.nrdconta = 14166313
     and pep.nrctremp = 75422;
	 
  update cecred.crappep pep
     set pep.vlparepr = 61.46,
         pep.vlsdvpar = 61.46,
         pep.vlsdvsji = 61.46,
         pep.dtvencto = add_months(pep.dtvencto,2)
   where pep.cdcooper = 7
     and pep.nrdconta = 14254395
     and pep.nrctremp = 74593;
     
  update cecred.CRAWEPR w
     set w.vlpreemp = 61.46,
         w.vlpreori = 61.46,
         w.txminima = 1.56,
         w.txbaspre = 1.56,
         w.txmensal = 1.56,
         w.txorigin = 1.56
   where w.cdcooper = 1
     and w.nrdconta = 80145264
     and w.nrctremp = 5206569;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 61.46,
         epr.txmensal = 1.56
   where epr.cdcooper = 1
     and epr.nrdconta = 80145264
     and epr.nrctremp = 5206569;

  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto,2)
   where pep.cdcooper = 7
     and pep.nrdconta = 14287048
     and pep.nrctremp = 74325;
	 
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto,1)
   where pep.cdcooper = 13
     and pep.nrdconta = 415189
     and pep.nrctremp = 188905;	 

  update cecred.crappep pep
     set pep.vlparepr = 214.76,
         pep.vlsdvpar = 214.76,
         pep.vlsdvsji = 214.76,
         pep.dtvencto = add_months(pep.dtvencto,2)
   where pep.cdcooper = 13
     and pep.nrdconta = 210960
     and pep.nrctremp = 180317;
     
  update cecred.CRAWEPR w
     set w.vlpreemp = 214.76,
         w.vlpreori = 214.76,
         w.txminima = 2.38,
         w.txbaspre = 2.38,
         w.txmensal = 2.38,
         w.txorigin = 2.38
   where w.cdcooper = 13
     and w.nrdconta = 210960
     and w.nrctremp = 180317;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 214.76,
         epr.txmensal = 2.38
   where epr.cdcooper = 13
     and epr.nrdconta = 210960
     and epr.nrctremp = 180317;	 

  update cecred.crappep pep
     set pep.vlparepr = 145.32,
         pep.vlsdvpar = 145.32,
         pep.vlsdvsji = 145.32,
         pep.dtvencto = add_months(pep.dtvencto,1)
   where pep.cdcooper = 13
     and pep.nrdconta = 184993
     and pep.nrctremp = 187699;
     
  update cecred.CRAWEPR w
     set w.vlpreemp = 145.32,
         w.vlpreori = 145.32,
         w.txminima = 1.51,
         w.txbaspre = 1.51,
         w.txmensal = 1.51,
         w.txorigin = 1.51
   where w.cdcooper = 13
     and w.nrdconta = 184993
     and w.nrctremp = 187699;
     
  update cecred.crapepr epr
     set epr.vlpreemp = 145.32,
         epr.txmensal = 1.51
   where epr.cdcooper = 13
     and epr.nrdconta = 184993
     and epr.nrctremp = 187699;	 

  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto,1)
   where pep.cdcooper = 13
     and pep.nrdconta = 415189
     and pep.nrctremp = 188905;	 
	 
  update cecred.crappep pep
     set pep.dtvencto = add_months(pep.dtvencto,3)
   where pep.cdcooper = 1
     and pep.nrdconta = 11035528
     and pep.nrctremp = 4777035;	 
	 
  commit;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20500, SQLERRM);
    ROLLBACK;
end;
