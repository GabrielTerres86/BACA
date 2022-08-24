DECLARE
  vr_nmsistem cecred.crapprm.nmsistem%TYPE := 'CRED';
  vr_cdcooper cecred.crapprm.cdcooper%TYPE := 0;
  vr_cdacesso cecred.crapprm.cdacesso%TYPE := 'AUTBUR_SCRIPT_FTPS';
  vr_dstexprm cecred.crapprm.dstexprm%TYPE := 'Script para envio e recebimento dos arquivos via FTPS';
  vr_dsvlrprm cecred.crapprm.dsvlrprm%TYPE := '/usr/local/bin/exec_comando_oracle.sh perl_remoto /usr/local/cecred/bin/ftps_envia_recebe.pl';
BEGIN
  MERGE INTO cecred.crapprm a
  USING (SELECT vr_nmsistem nmsistem
               ,vr_cdcooper cdcooper
               ,vr_cdacesso cdacesso
           FROM dual) b
  ON (a.nmsistem = b.nmsistem 
  AND a.cdcooper = b.cdcooper 
  AND a.cdacesso = b.cdacesso)
  
  WHEN MATCHED THEN
    UPDATE
       SET dstexprm = vr_dstexprm
          ,dsvlrprm = vr_dsvlrprm
  WHEN NOT MATCHED THEN
    INSERT
      (nmsistem
      ,cdcooper
      ,cdacesso
      ,dstexprm
      ,dsvlrprm)
    VALUES
      (vr_nmsistem
      ,vr_cdcooper
      ,vr_cdacesso
      ,vr_dstexprm
      ,vr_dsvlrprm);

  UPDATE crapaca a
     SET a.lstparam = a.lstparam || ',pr_flcripto'
   WHERE UPPER(TRIM(a.nmpackag)) = UPPER('cybe0002')
     AND UPPER(TRIM(a.nmdeacao)) = UPPER('GPRMBUX')
     AND UPPER(TRIM(a.nmproced)) = UPPER('pc_grava_bureaux_prmrbc')
     AND UPPER(TRIM(a.lstparam)) NOT LIKE UPPER('%pr_flcripto%');

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
