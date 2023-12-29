DECLARE 
  vr_nrdrowid        ROWID;
  vr_nmprograma      CECRED.tbgen_prglog.cdprograma%TYPE := 'Atualizar historico - PRB0048645';
  vr_cdoperad        CECRED.craplgm.cdoperad%TYPE := 't0035324';
  vr_cdempres_novo   CECRED.crapemp.cdempres%TYPE := 445;
  vr_cdempres_antigo CECRED.crapemp.cdempres%TYPE := 441;
  vr_cdcooper        CECRED.crapemp.cdcooper%TYPE := 12;
  vr_nrdconta        CECRED.crapemp.nrdconta%TYPE := 144290;
  
  CURSOR cr_craplfp IS
   SELECT lfp.cdcooper
         ,lfp.cdempres
         ,lfp.nrseqpag
         ,lfp.nrseqlfp
         ,lfp.idtpcont
         ,lfp.nrdconta
         ,lfp.nrcpfemp
         ,lfp.vllancto
         ,lfp.idsitlct
         ,lfp.dsobslct
         ,lfp.cdorigem
         ,lfp.dsxmlenv
         ,lfp.dtrefenv
         ,lfp.cddocemp
     FROM CECRED.craplfp lfp
    WHERE lfp.cdcooper = vr_cdcooper
      AND lfp.cdempres = vr_cdempres_antigo;

  CURSOR cr_crappfp IS
    SELECT pfp.cdcooper
          ,pfp.cdempres
          ,pfp.nrseqpag
          ,pfp.idtppagt
          ,pfp.dtcredit
          ,pfp.idopdebi
          ,pfp.dtdebito
          ,pfp.qtlctpag
          ,pfp.vllctpag
          ,pfp.flgrvsal
          ,pfp.idsitapr
          ,pfp.dtsolest
          ,pfp.cdopeest
          ,pfp.dsjusest
          ,pfp.flsitdeb
          ,pfp.dthordeb
          ,pfp.flsitcre
          ,pfp.dthorcre
          ,pfp.flsittar
          ,pfp.dtmvtolt
          ,pfp.dsobsdeb
          ,pfp.dsobstar
          ,pfp.dsobscre
          ,pfp.vltarapr
          ,pfp.dthortar
          ,pfp.nrcpfapr
          ,pfp.qtregpag
      FROM CECRED.crappfp pfp
     WHERE pfp.cdcooper = vr_cdcooper
       AND pfp.cdempres = vr_cdempres_antigo;
BEGIN
  FOR rw_crappfp IN cr_crappfp LOOP
    INSERT INTO CECRED.crappfp
      (cdcooper
      ,cdempres
      ,nrseqpag
      ,idtppagt
      ,dtcredit
      ,idopdebi
      ,dtdebito
      ,qtlctpag
      ,vllctpag
      ,flgrvsal
      ,idsitapr
      ,dtsolest
      ,cdopeest
      ,dsjusest
      ,flsitdeb
      ,dthordeb
      ,flsitcre
      ,dthorcre
      ,flsittar
      ,dtmvtolt
      ,dsobsdeb
      ,dsobstar
      ,dsobscre
      ,vltarapr
      ,dthortar
      ,nrcpfapr
      ,qtregpag)
    VALUES
      (rw_crappfp.cdcooper
      ,vr_cdempres_novo
      ,rw_crappfp.nrseqpag
      ,rw_crappfp.idtppagt
      ,rw_crappfp.dtcredit
      ,rw_crappfp.idopdebi
      ,rw_crappfp.dtdebito
      ,rw_crappfp.qtlctpag
      ,rw_crappfp.vllctpag
      ,rw_crappfp.flgrvsal
      ,rw_crappfp.idsitapr
      ,rw_crappfp.dtsolest
      ,rw_crappfp.cdopeest
      ,rw_crappfp.dsjusest
      ,rw_crappfp.flsitdeb
      ,rw_crappfp.dthordeb
      ,rw_crappfp.flsitcre
      ,rw_crappfp.dthorcre
      ,rw_crappfp.flsittar
      ,rw_crappfp.dtmvtolt
      ,rw_crappfp.dsobsdeb
      ,rw_crappfp.dsobstar
      ,rw_crappfp.dsobscre
      ,rw_crappfp.vltarapr
      ,rw_crappfp.dthortar
      ,rw_crappfp.nrcpfapr
      ,rw_crappfp.qtregpag);
  END LOOP;
  
  FOR rw_craplfp IN cr_craplfp LOOP
    INSERT INTO CECRED.craplfp
      (cdcooper
      ,cdempres
      ,nrseqpag
      ,nrseqlfp
      ,idtpcont
      ,nrdconta
      ,nrcpfemp
      ,vllancto
      ,idsitlct
      ,dsobslct
      ,cdorigem
      ,dsxmlenv
      ,dtrefenv
      ,cddocemp)
    VALUES
      (rw_craplfp.cdcooper
      ,vr_cdempres_novo
      ,rw_craplfp.nrseqpag
      ,rw_craplfp.nrseqlfp
      ,rw_craplfp.idtpcont
      ,rw_craplfp.nrdconta
      ,rw_craplfp.nrcpfemp
      ,rw_craplfp.vllancto
      ,rw_craplfp.idsitlct
      ,rw_craplfp.dsobslct
      ,rw_craplfp.cdorigem
      ,rw_craplfp.dsxmlenv
      ,rw_craplfp.dtrefenv
      ,rw_craplfp.cddocemp);
  END LOOP;    
  COMMIT;  
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper
                                ,pr_compleme => ' Script: => ' || vr_nmprograma); 
END;
