DECLARE

 Cursor c_snh is 
   select ass.cdcooper, ass.nrdconta, snh.cdsitsnh
     from crapsnh snh, crapass ass
    where ass.cdcooper = snh.cdcooper
      and ass.nrdconta= snh.nrdconta
      and ass.cdsitdct= 4
	  and ass.cdcooper = 1
      and cdsitsnh = 1
      and tpdsenha = 1;
 snh c_snh%rowtype;
   
 gr_dttransa cecred.craplgm.dttransa%type;
 gr_hrtransa cecred.craplgm.hrtransa%type;
 gr_nrdconta cecred.crapass.nrdconta%type;
 gr_cdcooper cecred.crapcop.cdcooper%type;
 gr_cdoperad cecred.craplgm.cdoperad%TYPE;
 vr_dscritic cecred.craplgm.dscritic%TYPE;
 vr_nrdrowid ROWID;
 v_erro      Varchar2(20000);


 vc_dstransaSensb  CONSTANT VARCHAR2(4000) := 'Encerramento de acesso Internet via Script - INC0326276';

BEGIN
  
  vr_nrdrowid := null;
  gr_dttransa := trunc(sysdate);
  gr_hrtransa := GENE0002.fn_busca_time;
  
  open c_snh;
  loop
     fetch c_snh into snh;
	 exit when c_snh%notfound;
	 
	 CECRED.GENE0001.pc_gera_log(pr_cdcooper => snh.cdcooper,
                                 pr_cdoperad => gr_cdoperad,
                                 pr_dscritic => v_erro,
                                 pr_dsorigem => 'AIMARO',
                                 pr_dstransa => vc_dstransaSensb,
                                 pr_dttransa => gr_dttransa,
                                 pr_flgtrans => 1,
                                 pr_hrtransa => gr_hrtransa,
                                 pr_idseqttl => 0,
                                 pr_nmdatela => NULL,
                                 pr_nrdconta => snh.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);

    if v_erro is null then
       
	   CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                        pr_nmdcampo => 'crapsnh.cdsitsnh',
                                        pr_dsdadant => snh.cdsitsnh,
                                        pr_dsdadatu => 3);
      
	   update cecred.crapsnh set cdsitsnh = 3
	    where cdcooper = snh.cdcooper
	      and nrdconta = snh.nrdconta;
     
  end if;
	 
  end loop;
  close c_snh;
  
  
  commit;

END;
/
