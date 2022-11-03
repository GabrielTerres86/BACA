BEGIN
  delete cecred.crapopi opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA = 13212176  
    and opi.NRCPFOPE in (37884077
                        ,75347504072);
  
  
  delete cecred.crapopi opi
  where opi.CDCOOPER = 1
    and opi.NRDCONTA = 14672146  
    and opi.NRCPFOPE in (760440093
                        ,928052052
                        ,1017265038
                        ,1298337038
                        ,2036394051
                        ,2168988030
                        ,2264866055
                        ,2536128024
                        ,3312840066
                        ,3372627059
                        ,4679309962
                        ,4747902902
                        ,9545278951
                        );
                        
  commit;
END;
