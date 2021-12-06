DECLARE
  procedure CorrigeConta(pr_nrdcontacc IN cecred.crapass.nrdconta%type,
                         pr_cdcoopercc in cecred.crapass.cdcooper%type,
                         pr_sldadd   in cecred.crapsld.VLSDDISP%type,
                         pr_dtmvtoltcc in cecred.crapass.dtmvtolt%type) IS
  
    vr_dttransa cecred.craplgm.dttransa%type;
    vr_hrtransa cecred.craplgm.hrtransa%type;
    vr_cdoperad cecred.craplgm.cdoperad%TYPE;
    vr_dscritic cecred.craplgm.dscritic%TYPE;
  
    vr_nrdrowid ROWID;
  
    CURSOR cr_crapsld(pr_nrdconta IN cecred.crapass.nrdconta%type,
                      pr_cdcooper in cecred.crapass.cdcooper%type) is
      SELECT a.*
        from CECRED.crapsld a
       WHERE a.nrdconta = pr_nrdconta
         AND a.cdcooper = pr_cdcooper;
  
    rg_crapsld crapsld%rowtype;
  
    CURSOR cr_crapsda(pr_nrdconta IN cecred.crapass.nrdconta%type,
                      pr_cdcooper in cecred.crapass.cdcooper%type,
                      pr_dtmvtolt in cecred.crapass.dtmvtolt%type) is
      SELECT a.*
        from CECRED.crapsda a
       WHERE a.nrdconta = pr_nrdconta
         AND a.cdcooper = pr_cdcooper
         AND a.dtmvtolt BETWEEN pr_dtmvtolt AND TRUNC(SYSDATE);
  
    rg_crapsda crapsda%rowtype;
  
  begin
  
    open cr_crapsld(pr_nrdcontacc, pr_cdcoopercc);
    fetch cr_crapsld
      into rg_crapsld;
  
    vr_dttransa := trunc(sysdate);
    vr_hrtransa := GENE0002.fn_busca_time;
  
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcoopercc,
                         pr_cdoperad => vr_cdoperad,
                         pr_dscritic => vr_dscritic,
                         pr_dsorigem => 'AIMARO',
                         pr_dstransa => 'Alteracao da situacao de conta por script - INC0116412 - Conta - ' || pr_nrdcontacc || ' - ' || pr_cdcoopercc,
                         pr_dttransa => vr_dttransa,
                         pr_flgtrans => 1,
                         pr_hrtransa => vr_hrtransa,
                         pr_idseqttl => 1,
                         pr_nmdatela => 'Atenda',
                         pr_nrdconta => pr_nrdcontacc,
                         pr_nrdrowid => vr_nrdrowid);
  
    GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'crapsld.VLSDDISP',
                              pr_dsdadant => rg_crapsld.vlsddisp,
                              pr_dsdadatu => rg_crapsld.vlsddisp + pr_sldadd);
    UPDATE crapsld a
       SET a.VLSDDISP = a.vlsddisp + pr_sldadd
     WHERE a.nrdconta = pr_nrdcontacc
       AND a.cdcooper = pr_cdcoopercc;
  
    FOR rg_crapass IN cr_crapsda(pr_nrdcontacc, pr_cdcoopercc, pr_dtmvtoltcc) LOOP
    
      GENE0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                                pr_nmdcampo => 'crapsda.VLSDDISP',
                                pr_dsdadant => rg_crapass.vlsddisp,
                                pr_dsdadatu => rg_crapass.vlsddisp +
                                               pr_sldadd);
    end loop;
  
    UPDATE crapsda a
       SET a.VLSDDISP =
           (a.vlsddisp + pr_sldadd)
     WHERE a.nrdconta = pr_nrdcontacc
       AND a.cdcooper = pr_cdcoopercc
       AND a.dtmvtolt BETWEEN pr_dtmvtoltcc AND
           TRUNC(SYSDATE);
  
    close cr_crapsld;
    commit;
  end;

BEGIN

  CorrigeConta(pr_nrdcontacc => 11368764,
               pr_cdcoopercc => 1,
               pr_sldadd   => 1975.00,
               pr_dtmvtoltcc => TO_DATE('30/11/2021', 'dd/mm/yyyy'));

  CorrigeConta(pr_nrdcontacc => 7026773,
               pr_cdcoopercc => 1,
               pr_sldadd   => 250.00,
               pr_dtmvtoltcc => TO_DATE('30/11/2021', 'dd/mm/yyyy'));

  CorrigeConta(pr_nrdcontacc => 10778276,
               pr_cdcoopercc => 1,
               pr_sldadd   => 204.00,
               pr_dtmvtoltcc => TO_DATE('01/12/2021', 'dd/mm/yyyy'));

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao alterar situação cooperativa/conta ' ||
                            SQLERRM);
END;
