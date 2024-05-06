BEGIN

 update crapsld
    set vlsddisp = -200
 where cdcooper = 16
   and nrdconta = 97540722;
                    
 update crapsld a
    set vlsddisp = -80
  where cdcooper = 16
    and nrdconta = 97540420;
   
 update crapsld a
    set vlsddisp = 10
  where cdcooper = 16
    and nrdconta = 97540110;

  update crapass a
     set vllimcre = 500
 where cdcooper = 16
   and nrdconta in (97540722,
                    97540420,
                    97540110);
                    
commit;

end;                    
