begin 
  
 UPDATE crapcre c
    SET c.dtmvtolt = trunc(SYSDATE)
  WHERE c.rowid IN ('AAAljBAABAAOfLnAB9'
                   ,'AAAljBAABAAOfLYAB0'
                   ,'AAAljBAABAAOfKhABa'
                   ,'AAAljBAABAAOfLxABz'
                   ,'AAAljBAABAAOfKzAAv'
                   ,'AAAljBAABAAOe9xAAW'
                   ,'AAAljBAABAAOfLKAA3');



UPDATE crapcre c
   SET c.dtmvtolt = trunc(SYSDATE)
 WHERE c.rowid IN ('AAAljBAABAAOfK1ABG'
                  ,'AAAljBAABAAOe9yABD'
                  ,'AAAljBAABAAOfLZAB7'
                  ,'AAAljBAABAAOfKiABG'
                  ,'AAAljBAABAAOfKhABa'
                  ,'AAAljBAABAAOfKnACF'
                  ,'AAAljBAABAAOfKtABb'
                  ,'AAAljBAABAAOe9xAAW'
                  ,'AAAljBAABAAOfKKABD'
                  ,'AAAljBAABAAOfKDABL'
                  ,'AAAljBAABAAOe96ABv'
                  ,'AAAljBAABAAOfKGAAL'
                  ,'AAAljBAABAAOfLwAAj'
                  ,'AAAljBAABAAOfLDAAX');

UPDATE crapcre c
   SET c.dtmvtolt = trunc(SYSDATE)
 WHERE c.rowid IN ('AAAljBAABAAOfL6AAF'
                  ,'AAAljBAABAAOfL6AAD'
                  ,'AAAljBAABAAOfLLABA'
                  ,'AAAljBAABAAOfLXABX'
                  ,'AAAljBAABAAOfL1AAA'
                  ,'AAAljBAABAAOfL6AAG');



commit;

end;


