DECLARE
  CURSOR cr_crapass(pr_cdcooper IN cecred.crapass.cdcooper%TYPE
                   ,pr_progress IN cecred.crapass.progress_recid%TYPE) IS
    SELECT a.nrdconta 
      FROM cecred.crapass a
     WHERE a.cdcooper = pr_cdcooper
       AND a.progress_recid = pr_progress;
  rw_crapass cr_crapass%ROWTYPE;
  
BEGIN
		
  OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 1099851);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 0.44
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 0.44
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  		
  
   OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 1099851);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 8.28
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 8.28
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  	
  
   OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 1160799);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 2.31
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 2.31
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  	
  
    OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 1537053);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 6.26
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 6.26
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  	
  
  OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 710450);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 5.48
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 5.48
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  
  
  OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 1099603);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 14.64
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 14.64
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  
  
  
  OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 1190236);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 0.97
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 0.97
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  
   
  
  OPEN cr_crapass(pr_cdcooper => 11
                 ,pr_progress => 1145496);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 11
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 4.79
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 4.79
     WHERE cdcooper = 11
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------  
   
  OPEN cr_crapass(pr_cdcooper => 14
                 ,pr_progress => 1127652);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 14
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2738
       and vllanmto = 0.88
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) + 0.88
     WHERE cdcooper = 14
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
   ------------------------------------------------------  
   
  
  OPEN cr_crapass(pr_cdcooper => 14
                 ,pr_progress => 902244);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 14
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2721
       and vllanmto = 0.31
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) + 0.31
     WHERE cdcooper = 14
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
     ------------------------------------------------------  
    
  OPEN cr_crapass(pr_cdcooper => 14
                 ,pr_progress => 1788498);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 14
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2722
       and vllanmto = 26.01
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 26.01
     WHERE cdcooper = 14
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
   ------------------------------------------------------  
   
  OPEN cr_crapass(pr_cdcooper => 5
                 ,pr_progress => 1050304);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 5
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 2.09
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 2.09
     WHERE cdcooper = 5
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
   ------------------------------------------------------  
   
  OPEN cr_crapass(pr_cdcooper => 5
                 ,pr_progress => 1109721);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 5
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 9.38
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 9.38
     WHERE cdcooper = 5
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 10
                 ,pr_progress => 1134811);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 10
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 0.06
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 0.06
     WHERE cdcooper = 10
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;

  
  ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 7
                 ,pr_progress => 741404);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 7
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 1050.00
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 1050.00
     WHERE cdcooper = 7
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
   ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 7
                 ,pr_progress => 921547);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 7
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 0.51
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 0.51
     WHERE cdcooper = 7
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  
   ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 7
                 ,pr_progress => 264199);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 7
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 5.50
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 5.50
     WHERE cdcooper = 7
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
   
  
   ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 1213715);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2721
       and vllanmto = 0.02
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) + 0.02
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
   ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 16
                 ,pr_progress => 917162);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 16
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2721
       and vllanmto = 34.06
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) + 34.06
     WHERE cdcooper = 16
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
  
  ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 6
                 ,pr_progress => 917162);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 6
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2408
       and vllanmto = 7.54
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 7.54
     WHERE cdcooper = 6
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;
          
  
   ------------------------------------------------------ 
  
   OPEN cr_crapass(pr_cdcooper => 1
                 ,pr_progress => 1673325);
  FETCH cr_crapass INTO rw_crapass;
  IF cr_crapass%FOUND THEN
    delete from tbcc_prejuizo_detalhe
     where cdcooper = 1
       and nrdconta = rw_crapass.nrdconta
       and cdhistor = 2721
       and vllanmto = 2349.90
       and dtmvtolt = to_date('', 'dd/mm/rrrr');
  
    UPDATE tbcc_prejuizo
       SET vlsdprej = Nvl(vlsdprej, 0) - 2349.90
     WHERE cdcooper = 1
       AND nrdconta = rw_crapass.nrdconta;
  END IF;
  CLOSE cr_crapass;	
  
  COMMIT;

END;
