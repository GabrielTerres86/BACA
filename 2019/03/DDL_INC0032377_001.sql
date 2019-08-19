DECLARE
  -- Chamado INC0032377 (Belli - Envolti - 26/03/2019)
  -- O sistema não gerou os dois lançamentos abaixo então será criado via baca
  -- a solução definitiva ficara a cargo de um novo chamado
  vr_nrseqdig  craplem.nrseqdig%TYPE := NULL;
  vr_dtmvtolt  craplem.dtmvtolt%TYPE := NULL;
  vr_cdagenci  craplem.cdagenci%TYPE := NULL;
  --
PROCEDURE PR_NRSEQDIG
IS
 BEGIN  
  SELECT   MAX(t.nrseqdig) 
  INTO     vr_nrseqdig
  FROM     craplem t 
  WHERE    t.cdcooper = 1
  AND      t.dtmvtolt = vr_dtmvtolt
  AND      t.cdagenci = vr_cdagenci
  AND      t.cdbccxlt = 100
  AND      t.nrdolote = 600005;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     vr_nrseqdig := 1; 
   WHEN OTHERS THEN
    CECRED.pc_internal_exception(pr_cdcooper => 0, pr_compleme => ' INC0032377 - vr_dtmvtolt:' || vr_dtmvtolt); 
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20001, ' - INC0032377 - vr_dtmvtolt:' || vr_dtmvtolt);
 END;
 ------
BEGIN
  vr_dtmvtolt := TO_DATE('10-01-2019', 'dd-mm-yyyy');
  vr_cdagenci := 1;
  PR_NRSEQDIG;
  
  BEGIN
    insert into CRAPLEM (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, NRCTREMP, VLLANMTO, 
    DTPAGEMP, TXJUREPR, VLPREEMP, NRAUTDOC, NRSEQUNI, CDCOOPER, NRPAREPR, PROGRESS_RECID, NRSEQAVA, DTESTORN, CDORIGEM, 
    DTHRTRAN, QTDIACAL, VLTAXPER, VLTAXPRD)
    values (vr_dtmvtolt, vr_cdagenci, 100, 600005, 7096763, (vr_nrseqdig+1), 1036, (vr_nrseqdig+1), 1389416, 1018.00, 
    vr_dtmvtolt, 0.0003500, 0.00, 0, 0, 1, 0, NULL, 0, null, 5, 
    SYSDATE, 0, 0.00000000, 0.00000000);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 0, pr_compleme => 'INC0032377 - vr_nrseqdig:' || vr_nrseqdig); 
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20002, ' - INC0032377 - vr_nrseqdig:' || vr_nrseqdig);
  END;
  
  vr_dtmvtolt := TO_DATE('08-03-2019', 'dd-mm-yyyy');
  vr_cdagenci := 9;
  PR_NRSEQDIG;
  
  BEGIN  
    insert into CRAPLEM (DTMVTOLT, CDAGENCI, CDBCCXLT, NRDOLOTE, NRDCONTA, NRDOCMTO, CDHISTOR, NRSEQDIG, NRCTREMP, VLLANMTO, 
    DTPAGEMP, TXJUREPR, VLPREEMP, NRAUTDOC, NRSEQUNI, CDCOOPER, NRPAREPR, PROGRESS_RECID, NRSEQAVA, DTESTORN, CDORIGEM, 
    DTHRTRAN, QTDIACAL, VLTAXPER, VLTAXPRD)
    values (vr_dtmvtolt, vr_cdagenci, 100, 600005, 8684570, (vr_nrseqdig+1), 1036, (vr_nrseqdig+1), 1448875, 37084.80,
    vr_dtmvtolt, 0.0005633, 0.00, 0, 0, 1, 0, NULL, 0, null, 5, 
    SYSDATE, 0, 0.00000000, 0.00000000);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => 0, pr_compleme => 'INC0032377 - vr_nrseqdig:' || vr_nrseqdig); 
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20003, ' - INC0032377 - vr_nrseqdig:' || vr_nrseqdig);
  END;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    CECRED.pc_internal_exception(pr_cdcooper => 0, pr_compleme => 'INC0032377 - vr_dtmvtolt:' || vr_dtmvtolt); 
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20004, ' INC0032377 - FIM' );
END;
