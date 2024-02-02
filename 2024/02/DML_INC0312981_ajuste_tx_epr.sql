
DECLARE  

  vr_nrdrowid VARCHAR2(50);
  vr_txjuremp_nova NUMBER;
  
  CURSOR cr_crapepr IS    
    SELECT e.cdcooper
          ,e.nrdconta
          ,e.NRCTREMP
          ,e.TXJUREMP
          ,e.TXMENSAL
          ,e.TPEMPRST
          ,e.INPREJUZ
          ,e.VLSDEVED
          ,e.VLSDEVAT
          ,e.rowid
      FROM crapepr e
     WHERE e.TXMENSAL = e.TXJUREMP
       AND e.INLIQUID = 0
       AND e.TXMENSAL > 0
     ORDER BY e.CDCOOPER
             ,e.nrdconta;
BEGIN 
  
  dbms_output.put_line('cdcooper;nrdconta;TXJUREMP;txjuremp_nova');
  FOR rw_crapepr IN cr_crapepr LOOP
    
    GENE0001.pc_gera_log( pr_cdcooper => rw_crapepr.cdcooper
                         ,pr_cdoperad => 'PROCESSO'
                         ,pr_dscritic => NULL
                         ,pr_dsorigem => 'INTRANET'
                         ,pr_dstransa => 'INC0312981 - Alteracao na taxa diaria do contrato '||rw_crapepr.nrctremp
                         ,pr_dttransa => TRUNC(SYSDATE)
                         ,pr_flgtrans => 0
                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                         ,pr_idseqttl => 1
                         ,pr_nmdatela => 'processo'
                         ,pr_nrdconta => rw_crapepr.nrdconta
                         ,pr_nrdrowid => vr_nrdrowid); 
                         
    vr_txjuremp_nova := ROUND(ROUND( (100 * (POWER ((rw_crapepr.TXMENSAL / 100) + 1 , (1 / 30)) - 1)), 10),7);
    
    GENE0001.pc_gera_log_item( pr_nrdrowid => vr_nrdrowid,
                               pr_nmdcampo => 'CRAPEPR.NRCTREMP',
                               pr_dsdadant => rw_crapepr.nrctremp,
                               pr_dsdadatu => rw_crapepr.nrctremp);
                               
    GENE0001.pc_gera_log_item( pr_nrdrowid => vr_nrdrowid,
                               pr_nmdcampo => 'CRAPEPR.TXJUREMP',
                               pr_dsdadant => to_char(rw_crapepr.TXJUREMP,'FM999G999D9999999'),
                               pr_dsdadatu => to_char(vr_txjuremp_nova,'FM999G999D9999999'));                               
                          
  
    UPDATE crapepr e
       SET e.TXJUREMP = vr_txjuremp_nova 
     WHERE e.rowid = rw_crapepr.rowid;

    dbms_output.put_line(rw_crapepr.cdcooper||';'||rw_crapepr.nrdconta||';'||rw_crapepr.TXJUREMP||';'||vr_txjuremp_nova);
     
  END LOOP;  
  
  COMMIT;

END;
