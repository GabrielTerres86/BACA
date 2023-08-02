Declare

 Cursor c_ass is
   select ass.cdcooper  cdcooper, 
          ass.nrdconta  nrdconta,
          ass.dtdemiss  dtdemiss,
		  ass.dtelimin  dtelimin
     from cecred.crapass ass 
    where ass.cdcooper = 9
	  and ass.nrdconta in (62448,459003);
 ass c_ass%rowtype;
 
 vc_dstransaStatusCC   CONSTANT VARCHAR2(4000) := 'Ajuste data de encerramento - INC0283579a';
 vr_dttransa           cecred.craplgm.dttransa%type;
 vr_hrtransa           cecred.craplgm.hrtransa%type;
 vr_nrdrowid           ROWID;
 vr_dscritic           cecred.crapcri.dscritic%TYPE;
 vr_cdoperad           cecred.craplgm.cdoperad%TYPE;
 	 
Begin 
 
 vr_dttransa    := trunc(sysdate);
 vr_hrtransa    := CECRED.GENE0002.fn_busca_time;
 
 
 
 open c_ass;
 LOOP
    fetch c_ass into ass;
 	exit when c_ass%notfound;
	
	vr_nrdrowid := null;
	
	CECRED.GENE0001.pc_gera_log(pr_cdcooper => ass.cdcooper,
                                pr_cdoperad => vr_cdoperad,
                                pr_dscritic => vr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransaStatusCC,
                                pr_dttransa => vr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => vr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => ass.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
								
	CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid   => vr_nrdrowid,
                                       pr_nmdcampo => 'crapass.dtelimin',
                                       pr_dsdadant => ass.dtelimin,
                                       pr_dsdadatu => ass.dtdemiss);							

 	Update cecred.crapass set dtelimin = ass.dtdemiss
 	 where cdcooper = ass.cdcooper
 	   and nrdconta = ass.nrdconta;
 
 end loop;
 close c_ass;
 
 commit;


exception
  when others THEN
       RAISE_APPLICATION_ERROR(-20003,
                            'Erro geral script -> cooperativa/conta (' ||SQLERRM);
end;
/
