DECLARE

 gr_dttransa cecred.craplgm.dttransa%type;
 gr_hrtransa cecred.craplgm.hrtransa%type;
 gr_nrdconta cecred.crapass.nrdconta%type;
 gr_cdcooper cecred.crapcop.cdcooper%type;
 gr_cdoperad cecred.craplgm.cdoperad%TYPE;
 vr_dscritic cecred.craplgm.dscritic%TYPE;
 vr_nrdrowid ROWID;


 vc_dstransa CONSTANT VARCHAR2(4000) := 'Alteração da situação da conta - INC0294835';
 
 
 
 Cursor c_contas IS 
   select sld.cdcooper cdcooper, 
          sld.nrdconta nrdconta, 
		  ass.cdsitdct cdsitdct
     from cecred.crapsld sld, cecred.crapass ass
    where sld.cdcooper = ass.cdcooper
	  and sld.nrdconta = ass.nrdconta
	  and sld.progress_recid = 670112;
 contas c_contas%ROWTYPE;
 
BEGIN

  gr_dttransa := trunc(sysdate);
  gr_hrtransa := GENE0002.fn_busca_time;
  
  open c_contas;
  LOOP
     fetch c_contas into contas;
	 exit when c_contas%notfound;
	 
	 vr_nrdrowid := null;

     CECRED.GENE0001.pc_gera_log(pr_cdcooper => contas.cdcooper,
                                 pr_cdoperad => gr_cdoperad,
                                 pr_dscritic => vr_dscritic,
                                 pr_dsorigem => 'AIMARO',
                                 pr_dstransa => vc_dstransa,
                                 pr_dttransa => gr_dttransa,
                                 pr_flgtrans => 1,
                                 pr_hrtransa => gr_hrtransa,
                                 pr_idseqttl => 0,
                                 pr_nmdatela => NULL,
                                 pr_nrdconta => contas.nrdconta,
                                 pr_nrdrowid => vr_nrdrowid);
								 
	 if vr_dscritic is null then
	 
        CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                        pr_nmdcampo => 'crapass.cdsitdct',
                                        pr_dsdadant => contas.cdsitdct,
                                        pr_dsdadatu => 8);
		
		update cecred.crapass set cdsitdct = 8
         where cdcooper = contas.cdcooper
           and nrdconta = contas.nrdconta;

     end if;		   
  
  
  END LOOP;
  close c_contas;
  
  commit;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20000,
                               'Erro ao alterar situação da conta '|| sqlerrm);
END;
/
