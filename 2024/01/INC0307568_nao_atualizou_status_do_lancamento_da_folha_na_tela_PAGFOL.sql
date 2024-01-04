DECLARE 
  vr_nmprograma CECRED.tbgen_prglog.cdprograma%TYPE := 'Atualizar CTSAL - INC0307568';
  vr_cdcooper   CECRED.crapcop.cdcooper%TYPE := 7;
BEGIN
  UPDATE CECRED.craplfp lfp
     SET lfp.idsitlct = 'T'
        ,lfp.dsobslct = ''
   WHERE lfp.idtpcont = 'T'
     AND lfp.idsitlct = 'L'
     AND lfp.cdcooper = vr_cdcooper
     AND lfp.nrdconta = 478008
     AND lfp.nrcpfemp = 08234611909
     AND lfp.vllancto = 3336.53
     AND lfp.cdempres = 568;

  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
      CECRED.pc_internal_exception(pr_cdcooper => vr_cdcooper
                                  ,pr_compleme => ' Script: => ' || vr_nmprograma ); 

END;
