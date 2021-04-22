-- Created on 04/05/2017 by F0030248 
declare 
  -- Local variables here
  i integer;
  vr_idreqleg NUMBER(20);
  vr_dthrrequisicao NUMBER(14);
begin
  
  FOR rw IN (

         select dscodbar from craptit where cdcooper = 1            and 
                                            dtmvtolt = '01/04/2021' and
                                            craptit.tpdocmto = 20   and
                                            craptit.intitcop = 0    and
                                            cdagenci = 90      
  ) LOOP         
              
    -- Test statements here
    vr_idreqleg := to_number(TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF4'));
    --vr_idreqleg := to_number(to_char(SYSDATE,'MMDD') || substr(rw.dscodbar,1,3) || substr(rw.dscodbar,20,12)
    vr_dthrrequisicao := to_number(to_char(SYSDATE,'YYYYMMDDHH24MISS'));
      
   
    
    INSERT INTO TBJDNPCRCBLEG_LG2JD_CONS@JDNPCBISQL
      (CDLEG,
       IDREQLEG,
       DTHRREQUISICAO,
       ISPBPRINCIPAL,
       ISPBADMINISTRADO,
       NUMCODBARRAS)
    VALUES
      ('LEG'
      ,vr_idreqleg
      ,vr_dthrrequisicao
      ,'5463212'
      ,'5463212'
      ,rw.dscodbar
      );
      
    INSERT INTO TBJDNPCRCBLEG_LG2JD_CTRL@jdnpcbisql (CdLeg, IdReqLeg, TPReq)
    VALUES ('LEG', vr_idreqleg, 'C'); -- C=Consulta;    
    
  
    
    
    
  END LOOP;
    
  COMMIT;    
  
end;
