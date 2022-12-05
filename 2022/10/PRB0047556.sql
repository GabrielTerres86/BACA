DECLARE
vr_programa cecred.crapprg.cdprogra%type;

BEGIN
  vr_programa := 'CRPS514';
  UPDATE CECRED.CRAPPRG P
     SET P.NRSOLICI = 99999
        ,P.INLIBPRG = 2
   WHERE P.CDCOOPER = 3
     AND P.CDPROGRA = vr_programa;

  vr_programa := 'CRPS513';
  UPDATE CECRED.CRAPPRG P
     SET P.NRSOLICI = 99999
        ,P.INLIBPRG = 2
   WHERE P.CDCOOPER = 3
     AND P.CDPROGRA = vr_programa;
     
  COMMIT;
    
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20002,
                            'Erro ao desativar programa ' || vr_programa || ' - ' ||
                            SQLERRM);
END;  
