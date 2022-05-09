begin

     update gncontr gnc 
        set gnc.cdsitret = 9
      where gnc.cdcooper = 3 
        and gnc.dtmvtolt = '09/05/2022'
        and gnc.cdconven = 164
        and gnc.nrsequen = 43
        and gnc.cdsitret = 8;        

     update gncontr gnc 
        set gnc.cdsitret = 9
      where gnc.cdcooper = 3 
        and gnc.dtmvtolt = '09/05/2022'
        and gnc.cdconven = 165
        and gnc.nrsequen = 44
        and gnc.cdsitret = 8;
        
     update gncontr gnc 
        set gnc.cdsitret = 9       
      where gnc.cdcooper = 3 
        and gnc.dtmvtolt = '09/05/2022'
        and gnc.cdconven = 168
        and gnc.nrsequen = 47
        and gnc.cdsitret = 8;
        
     commit;
end;