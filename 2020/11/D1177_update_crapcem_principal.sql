DECLARE
  
  /*D1171 - Atualizar emails com a flag principal 
    Author: Gustavo Alves (Supero) */
  CURSOR cr_crapcem IS
    select cem.nrdconta, cem.cdcooper, cem.idseqttl, cem.cddemail from crapcem cem
    where cem.idseqttl = (select min(sub.idseqttl) from crapcem sub where sub.cdcooper = cem.cdcooper and sub.nrdconta = cem.nrdconta)
      and cem.cddemail = (select min(sub.cddemail) from crapcem sub where sub.cdcooper = cem.cdcooper and sub.nrdconta = cem.nrdconta and sub.idseqttl = cem.idseqttl)
    group by cem.nrdconta, cem.cdcooper, cem.idseqttl, cem.cddemail
    order by cem.cdcooper, cem.nrdconta;
  rw_crapcem cr_crapcem%ROWTYPE;   
  --
  vr_cont      INTEGER := 0;
  
BEGIN

  FOR rw_crapcem IN cr_crapcem LOOP
    
    vr_cont := vr_cont + 1;
        
    update crapcem 
    set inprincipal = 0
    where cdcooper = rw_crapcem.cdcooper
      and nrdconta = rw_crapcem.nrdconta;

    update crapcem 
    set inprincipal = 1
    where cdcooper = rw_crapcem.cdcooper
      and nrdconta = rw_crapcem.nrdconta 
      and idseqttl = rw_crapcem.idseqttl 
      and cddemail = rw_crapcem.cddemail;
      
    IF vr_cont = 1000 THEN
       COMMIT;
       vr_cont := 0;
    END IF;
    
  END LOOP;
  
  --
  COMMIT;
  
END;
