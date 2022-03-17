BEGIN

       update crapdpt 
          set cdocorre = '00'          
        where cdcooper = 1 
          and nrdconta = 830968 
          and trunc(dtmvtopg) = '10/01/2022' 
          and dscodbar = '00196886100002319900000003280036000001311717'
          and nrremret = 253;
		  commit;
END;


BEGIN
       update crapdpt 
          set cdocorre = '00'          
        where cdcooper = 1 
          and nrdconta = 830968 
          and trunc(dtmvtopg) = '14/01/2022' 
          and dscodbar = '00197886500013050000000001606063000000003117'
          and nrremret = 253;
		  commit;
END;
