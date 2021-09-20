declare
  v_vldcotas number(10,2);
  v_vlcapmes##8 number(10,2); 
  
    cursor c_contas is   
    SELECT 13 cdcooper, 240036 nrdconta  from dual
      union all 
    SELECT 14 cdcooper, 12360 nrdconta from dual;
  
BEGIN 
   
   for r_contas in c_contas loop
     BEGIN 
        SELECT VLDCOTAS, VLCAPMES##8
             INTO v_vldcotas
                 ,v_vlcapmes##8
           FROM CRAPCOT 
          WHERE CDCOOPER = r_contas.cdcooper
          AND NRDCONTA = r_contas.nrdconta;        
        EXCEPTION
           WHEN OTHERS THEN 
              v_vldcotas := 0;
              v_vlcapmes##8 := 0;
         END;
              
         BEGIN
            UPDATE crapcot
             set vldcotas = 1
                ,vlcapmes##8 = 1
          WHERE CDCOOPER = r_contas.cdcooper
          AND NRDCONTA = r_contas.nrdconta;  
        EXCEPTION
           WHEN OTHERS THEN 
              BEGIN
                UPDATE crapcot
                 set vldcotas = v_vldcotas
                    ,vlcapmes##8 =v_vlcapmes##8
          WHERE CDCOOPER = r_contas.cdcooper
          AND NRDCONTA = r_contas.nrdconta;                
              END;
         END;
      end loop; 
    commit;    
END;      
/
