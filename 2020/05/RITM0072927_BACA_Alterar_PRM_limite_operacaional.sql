
BEGIN
  DECLARE
    CURSOR cr_crapcop IS 
       SELECT cdcooper
         FROM crapcop c;
  BEGIN
    DELETE FROM crapprm p WHERE p.cdacesso = 'CRD_LIMITE_OPERAC';
    
    FOR rw_cracop IN cr_crapcop LOOP
        BEGIN
          INSERT INTO crapprm (
                 cdacesso, 
                 cdcooper, 
                 dstexprm, 
                 dsvlrprm, 
                 nmsistem
          ) VALUES (
                 'CRD_LIMITE_OPERAC', 
                 rw_cracop.cdcooper, 
                 'Verifica limite operacional da cooperativa (1 = Verifica / 0 = Nao verifica)',
                 0,
                 'CRED'                
          );
        END;
    END LOOP;
    
    COMMIT;
  END; 
END;
