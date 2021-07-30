BEGIN

  FOR i IN (SELECT ROWID
                  ,t.*
              FROM craptab t
             WHERE nmsistem = 'CRED'
               AND tptabela = 'GENERI'
               AND cdempres = 0
               AND cdacesso = 'DIGITALIZA'
               AND tpregist IN (92, 93)) LOOP
  
    IF i.tpregist = 92 THEN
    
      UPDATE craptab b
         SET b.dstextab = substr(i.dstextab, 1, 36) || '227;0,00'
       WHERE b.rowid = i.rowid;
    
    ELSIF i.tpregist = 93 THEN
    
      UPDATE craptab b
         SET b.dstextab = substr(i.dstextab, 1, 23) || '228;0,00'
       WHERE b.rowid = i.rowid;
    
    END IF;
  
  END LOOP;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
  
END;
