declare 
  i integer;
  CURSOR cr_contas is
      SELECT * 
      FROM CRAPASS A
     WHERE A.DTDEMISS IS NOT NULL
       AND A.CDCOOPER = 1
       AND A.DTDEMISS <= TO_DATE('01/01/2000','DD/MM/YYYY')
       AND ROWNUM <= 1000; 
          
begin

    for rw_contas in cr_contas loop
       begin
         
         UPDATE CRAPASS A SET A.dtdemiss = a.dtdemiss + 1 WHERE A.CDCOOPER  = rw_contas.cdcooper and a.nrdconta = rw_contas.nrdconta;
         UPDATE CRAPASS A SET A.dtcnscpf = a.dtcnscpf + 1 WHERE A.CDCOOPER  = rw_contas.cdcooper and a.nrdconta = rw_contas.nrdconta;
            
         UPDATE CRAPBEM B SET B.dtmvtolt = nvl(B.dtmvtolt,trunc(sysdate) ) + 1 WHERE B.CDCOOPER  = rw_contas.cdcooper and B.nrdconta = rw_contas.nrdconta and b.idseqttl = 1; 
         UPDATE CRAPBEM B SET B.dtaltbem = nvl(B.dtaltbem,trunc(sysdate) ) + 1 WHERE B.CDCOOPER  = rw_contas.cdcooper and B.nrdconta = rw_contas.nrdconta and b.idseqttl = 1; 
               

         UPDATE CRAPENC E SET e.dtaltenc = nvl(E.dtaltenc,trunc(sysdate) )  + 1 WHERE E.CDCOOPER  = rw_contas.cdcooper and E.nrdconta = rw_contas.nrdconta and E.idseqttl = 1; 
         UPDATE CRAPENC E SET E.dtinires = nvl(E.dtinires,trunc(sysdate) )  + 1 WHERE E.CDCOOPER  = rw_contas.cdcooper and E.nrdconta = rw_contas.nrdconta and E.idseqttl = 1; 
          
         UPDATE CRAPJFN J SET j.dtaltjfn##1 = nvl(j.dtaltjfn##1,trunc(sysdate) )  + 1 WHERE J.CDCOOPER  = rw_contas.cdcooper and J.nrdconta = rw_contas.nrdconta ; 
         UPDATE CRAPJFN J SET J.dtaltjfn##2 = nvl(j.dtaltjfn##2,trunc(sysdate) )  + 1 WHERE j.CDCOOPER  = rw_contas.cdcooper and J.nrdconta = rw_contas.nrdconta ; 

         UPDATE CRAPJUR U SET U.Dtiniatv  = nvl(u.Dtiniatv,trunc(sysdate) )  + 1 WHERE U.CDCOOPER  = rw_contas.cdcooper and U.nrdconta = rw_contas.nrdconta ; 
         UPDATE CRAPJUR U SET u.dtatutel  = nvl(u.dtatutel,trunc(sysdate) )  + 1 WHERE U.CDCOOPER  = rw_contas.cdcooper and U.nrdconta = rw_contas.nrdconta ; 

         UPDATE CRAPTTL T SET T.dtemdttl = nvl(t.dtemdttl,trunc(sysdate) )  + 1 WHERE T.CDCOOPER  = rw_contas.cdcooper and T.nrdconta = rw_contas.nrdconta and T.idseqttl = 1; 
         UPDATE CRAPTTL T SET T.dtatutel  = nvl(t.dtatutel,trunc(sysdate) )  + 1 WHERE T.CDCOOPER  = rw_contas.cdcooper and T.nrdconta = rw_contas.nrdconta and T.idseqttl = 1; 


         UPDATE CRAPTFC f SET f.nrdramal = '999'                        WHERE F.CDCOOPER  = rw_contas.cdcooper and F.nrdconta = rw_contas.nrdconta and F.idseqttl = 1; 
         UPDATE CRAPTFC F SET f.dtinsori  = nvl(f.dtinsori,sysdate) + 1 WHERE F.CDCOOPER  = rw_contas.cdcooper and F.nrdconta = rw_contas.nrdconta and F.idseqttl = 1; 
             
         commit;
        
       end;
       
    end loop;
      
  
end;
