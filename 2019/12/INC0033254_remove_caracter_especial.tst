PL/SQL Developer Test script 3.0
48
DECLARE  

  vr_dsoberv VARCHAR2(4000);

  CURSOR cr_crapobs IS
    SELECT * 
      FROM crapobs a
     WHERE a.cdcooper = 1
       AND a.nrdconta IN (10954988 
                         ,10953140  
                         ,10939180  
                         ,10965483); 

BEGIN

  FOR rw_crapobs IN cr_crapobs LOOP
    
    IF rw_crapobs.nrdconta = 10965483 THEN
      vr_dsoberv := '****** ATENÇÃO ****** '||
                    'COOPERADO ADMITIDO ATRAVÉS DO PROCESSO DE ADMISSÃO DIGITAL NO APP SEJA AILOS. ALGUNS CAMPOS DO CADASTRO ESTÃO INCOMPLETOS DEVIDO A LIMITAÇÃO DE ENVIO DE INFORMAÇÕES. EM CASO DE MAIS ESCLARECIMENTOS, TRATAR COM (QUELEN PATRICIA GOMES TRINDADE) '|| 
                    '(QUELEN.TRINDADE@VIACREDI.COOP.BR) ';
    END IF;  

    IF rw_crapobs.nrdconta = 10939180 THEN
      vr_dsoberv := '****** ATENÇÃO ****** '|| 
                    'COOPERADO ADMITIDO ATRAVÉS DO PROCESSO DE ADMISSÃO DIGITAL NO APP SEJA AILOS. ALGUNS CAMPOS DO CADASTRO ESTÃO INCOMPLETOS DEVIDO A LIMITAÇÃO DE ENVIO DE INFORMAÇÕES. EM CASO DE MAIS ESCLARECIMENTOS, TRATAR COM FRANKLIN - FRANKLIN.MAYER@VIACREDI.COOP.BR';
    END IF;      
    
    IF rw_crapobs.nrdconta IN (10953140, 10954988) THEN
      vr_dsoberv := '****** ATENÇÃO ****** '|| 
                    'COOPERADO ADMITIDO ATRAVÉS DO PROCESSO DE ADMISSÃO DIGITAL NO APP SEJA AILOS. ALGUNS CAMPOS DO CADASTRO ESTÃO INCOMPLETOS DEVIDO A LIMITAÇÃO DE ENVIO DE INFORMAÇÕES. EM CASO DE MAIS ESCLARECIMENTOS, TRATAR COM CERAIMA FEITOSA LEHNER  CERAIMA.LEHNER@VIACREDI.COOP.BR';
    END IF;                
  
    BEGIN 
      UPDATE crapobs   
         SET crapobs.dsobserv = vr_dsoberv
       WHERE crapobs.cdcooper = rw_crapobs.cdcooper
         AND crapobs.nrdconta = rw_crapobs.nrdconta
         AND crapobs.nrseqdig = rw_crapobs.nrseqdig;
    EXCEPTION      
      WHEN OTHERS THEN
        NULL;
    END;
  
  END LOOP; -- FIM cr_crapobs

  COMMIT;
END;
0
0
