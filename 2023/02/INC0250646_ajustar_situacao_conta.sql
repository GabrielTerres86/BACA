DECLARE
  
  CURSOR cr_crapass is
    SELECT t.cdcooper
         , t.nrdconta 
         , t.cdsitdct
      FROM cecred.CRAPASS t
     WHERE t.progress_recid = 819193;
  rg_crapass   cr_crapass%rowtype;
   
  vr_nrdrowid  ROWID;

BEGIN
  
  OPEN  cr_crapass;
  FETCH cr_crapass INTO rg_crapass;
  
  IF cr_crapass%NOTFOUND THEN
    CLOSE cr_crapass;
    RAISE_APPLICATION_ERROR(-20001,'Dados da conta não encontrados pelo progress_recid.');
  END IF;
  
  CLOSE cr_crapass;
  
  BEGIN
    UPDATE cecred.crapass a
       SET a.cdsitdct = 8
     WHERE a.cdcooper = rg_crapass.cdcooper
       AND a.nrdconta = rg_crapass.nrdconta;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002,'Erro ao atualizar situação da conta: '||SQLERRM);
  END;
   
  vr_nrdrowid := null;
    
  GENE0001.pc_gera_log(pr_cdcooper => rg_crapass.cdcooper,
                       pr_cdoperad => '1',
                       pr_dscritic => NULL,
                       pr_dsorigem => 'AIMARO',
                       pr_dstransa => 'Alteracao da situacao de conta por script - INC0250646',
                       pr_dttransa => TRUNC(SYSDATE),
                       pr_flgtrans => 1,
                       pr_hrtransa => GENE0002.fn_busca_time,
                       pr_idseqttl => 0,
                       pr_nmdatela => NULL,
                       pr_nrdconta => rg_crapass.nrdconta,
                       pr_nrdrowid => vr_nrdrowid);
  
  GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                            pr_nmdcampo => 'crapass.cdsitdct',
                            pr_dsdadant => rg_crapass.cdsitdct,
                            pr_dsdadatu => 8);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'ERRO SCRIPT: '||SQLERRM);
END;    
