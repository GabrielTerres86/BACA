DECLARE
  CURSOR cr_crapfsf_cidade IS
    SELECT fsf.cdcidade cdcidade
      FROM CECRED.crapfsf fsf
     GROUP BY fsf.cdcidade
     ORDER BY fsf.cdcidade;
	 
BEGIN      
  
    FOR rw_crapfsf_cidade IN cr_crapfsf_cidade LOOP        
      BEGIN      
        INSERT INTO CECRED.crapfsf (
                    cdcidade,
                    dtferiad,
                    tpferiad,
                    dtmvtolt,
                    dtdbaixa)
        VALUES (
                rw_crapfsf_cidade.cdcidade,
                '30/12/2022',
                0,
                trunc(sysdate),
                null
                );
            
      EXCEPTION
        WHEN OTHERS THEN
          CONTINUE;
      END;      
            
    END LOOP;
      
    COMMIT;  

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, SQLERRM);
END;
