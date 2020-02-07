PL/SQL Developer Test script 3.0
43
DECLARE  

  vr_dsoberv VARCHAR2(4000);

  CURSOR cr_crapobs IS
    SELECT * 
      FROM crapobs a
     WHERE a.cdcooper = 1
       AND a.nrdconta IN (10939385  
                         ,10939091
                         ,10938494
                         ,10939032
                         ,10941010
                         ,10941150
                         ,10938672
                         ,10939067
                         ,10939415
                         ,10940707
                         ,10941029); 

BEGIN

  FOR rw_crapobs IN cr_crapobs LOOP
    
    
    vr_dsoberv := '****** ATENÇÃO ****** ' ||
                  'COOPERADO ADMITIDO ATRAVÉS DO PROCESSO DE ADMISSÃO DIGITAL NO APP SEJA AILOS. ALGUNS CAMPOS DO CADASTRO ESTÃO INCOMPLETOS DEVIDO A LIMITAÇÃO DE ENVIO DE INFORMAÇÕES. EM CASO DE MAIS ESCLARECIMENTOS, TRATAR COM FRANKLIN  FRANKLIN.MAYER@VIACREDI.COOP.BR';
  
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
