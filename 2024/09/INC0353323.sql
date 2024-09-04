BEGIN
   
 delete from cecred.crapttl
  where cdcooper = 1
    and nrdconta = 19330189
	and idseqttl > 1;
    
 delete from cecred.crapttl
  where cdcooper = 13
    and nrdconta = 302821
	and idseqttl > 1;
    
 delete from cecred.crapttl
  where cdcooper = 16
    and nrdconta = 17457173
	and idseqttl > 1;
	
	commit;

EXCEPTION
  when others THEN
       null;
	   
END
;