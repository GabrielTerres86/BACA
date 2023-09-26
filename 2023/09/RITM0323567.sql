DECLARE

  gr_dttransa cecred.craplgm.dttransa%type;
  gr_hrtransa cecred.craplgm.hrtransa%type;
  gr_nrdconta cecred.crapass.nrdconta%type;
  gr_cdcooper cecred.crapcop.cdcooper%type;
  gr_cdoperad cecred.craplgm.cdoperad%TYPE;
  vr_dscritic cecred.craplgm.dscritic%TYPE;
  vr_nrdrowid ROWID;


  vc_dstransa CONSTANT VARCHAR2(4000) := 'Alteração da categoria da conta - RITM0323567';


 Cursor c_indv is
  SELECT a.cdcooper, a.nrdconta, a.cdcatego
    FROM (SELECT t.cdcooper
               , t.nrdconta
			   , t.cdcatego
               , (SELECT COUNT(1)
                    FROM cecred.crapttl x
                   WHERE x.cdcooper = t.cdcooper
                     AND x.nrdconta = t.nrdconta) qtdtitulares
            FROM cecred.crapass t
           WHERE t.inpessoa = 1
             AND t.cdcatego = 1 
             AND NVL(t.dtdemiss,TRUNC(SYSDATE)) > to_date('01/11/2020','DD/MM/YYYY')) a
   WHERE a.qtdtitulares > 1;
 indv c_indv%rowtype;
 


 Cursor c_conj is
  SELECT a.cdcooper, a.nrdconta, a.cdcatego
    FROM (SELECT t.cdcooper
               , t.nrdconta
			   , t.cdcatego
               , (SELECT COUNT(1)
                    FROM cecred.crapttl x
                   WHERE x.cdcooper = t.cdcooper
                     AND x.nrdconta = t.nrdconta) qtdtitulares
            FROM cecred.crapass t
           WHERE t.inpessoa = 1
             AND t.cdcatego > 1 
             AND NVL(t.dtdemiss,TRUNC(SYSDATE)) > to_date('01/11/2020','DD/MM/YYYY')) a
   WHERE a.qtdtitulares = 1;
 conj c_conj%rowtype;
 


BEGIN

 gr_dttransa := trunc(sysdate);
 gr_hrtransa := GENE0002.fn_busca_time;

 open c_indv;
 LOOP
    fetch c_indv into indv;
	exit when c_indv%notfound;
	
	vr_nrdrowid := null;

    CECRED.GENE0001.pc_gera_log(pr_cdcooper => indv.cdcooper,
                                pr_cdoperad => gr_cdoperad,
                                pr_dscritic => vr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransa,
                                pr_dttransa => gr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => gr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => indv.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
	
	if vr_dscritic is null then
	   CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                        pr_nmdcampo => 'crapass.CDCATEGO',
                                        pr_dsdadant => indv.cdcatego,
                                        pr_dsdadatu => 2);
	
	    update cecred.crapass set cdcatego = 2
	     where cdcooper = indv.cdcooper
	       and nrdconta = indv.nrdconta;
	end if;
 
 END LOOP;
 close c_indv;

 open c_conj;
 LOOP
    fetch c_conj into conj;
	exit when c_conj%notfound;
	
	vr_nrdrowid := null;

    CECRED.GENE0001.pc_gera_log(pr_cdcooper => conj.cdcooper,
                                pr_cdoperad => gr_cdoperad,
                                pr_dscritic => vr_dscritic,
                                pr_dsorigem => 'AIMARO',
                                pr_dstransa => vc_dstransa,
                                pr_dttransa => gr_dttransa,
                                pr_flgtrans => 1,
                                pr_hrtransa => gr_hrtransa,
                                pr_idseqttl => 0,
                                pr_nmdatela => NULL,
                                pr_nrdconta => conj.nrdconta,
                                pr_nrdrowid => vr_nrdrowid);
	
	
	if vr_dscritic is null then
	
	   CECRED.GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                        pr_nmdcampo => 'crapass.CDCATEGO',
                                        pr_dsdadant => conj.cdcatego,
                                        pr_dsdadatu => 1);
	
	   update cecred.crapass set cdcatego = 1
	    where cdcooper = conj.cdcooper
	      and nrdconta = conj.nrdconta;
	
	end if;
 
 END LOOP;
 close c_conj;

 Commit;

EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20000,
                               'Erro ao alterar tipo de contaa '|| sqlerrm);
END;
/
