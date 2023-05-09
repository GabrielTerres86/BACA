BEGIN

  UPDATE crapcob t 
     SET t.vlabatim = DECODE(ROWID,'AAJ30aAAAAAAi2rAAN', 15
                                  ,'AAJ30aAAAAAAlKaAAi', 9.99
                                  ,'AAJ30aAAAAAAp8jAAc', 20
                                  ,'AAJ30aAAAAAAp9WAAY', 7000
                                  ,'AAJ30aAAAAAArM8AAY', 5
                                  ,'AAJ30aAAAAAArUuAAI', 10
                                  ,'AAJ30aAAAAAArpGAAf', 30
                                  ,'AAJ30aAAAAAArwOAAI', 180
                                  ,'AAJ30aAAAAAAsL8AAf', 31.39
                                  ,'AAJ30aAAAAAA1Y2AAI', 500
                                  ,'AAJ30aAAAAAAjWUAAB', 25
                                  ,'AAJ30aAAAAAAoWRAAM', 70
                                  ,'AAJ30aAAAAAAo3UAAV', 5.25
                                  ,'AAJ30aAAAAAAsQEAAM', 12
                                  ,'AAJ30aAAAAAAtDkAAW', 55.64
                                  ,'AAJ30aAAAAAAus1AAY', 25.30
                                  ,'AAJ30aAAAAAA01lAAj', 13
                                  ,'AAJ30aAAAAAA1fNAAW', 27.50
                                  , 0)
   WHERE ROWID IN ('AAJ30aAAAAAAi2rAAN','AAJ30aAAAAAAlKaAAi','AAJ30aAAAAAAp8jAAc','AAJ30aAAAAAAp9WAAY','AAJ30aAAAAAArM8AAY'
                  ,'AAJ30aAAAAAArUuAAI','AAJ30aAAAAAArpGAAf','AAJ30aAAAAAArwOAAI','AAJ30aAAAAAAsL8AAf','AAJ30aAAAAAA1Y2AAI'
                  ,'AAJ30aAAAAAAjWUAAB','AAJ30aAAAAAAoWRAAM','AAJ30aAAAAAAo3UAAV','AAJ30aAAAAAAsQEAAM','AAJ30aAAAAAAtDkAAW'
                  ,'AAJ30aAAAAAAus1AAY','AAJ30aAAAAAA01lAAj','AAJ30aAAAAAA1fNAAW');
 
  UPDATE crapcob t
     SET t.inpagdiv = DECODE(ROWID,'AAJ30aAAAAAAoyBAAU',2
                                  ,'AAJ30aAAAAAApbgAAp',2
                                  ,'AAJ30aAAAAAApbhAAc',2
                                  ,'AAJ30aAAAAAArJBAAK',2
                                  ,'AAJ30aAAAAAArUvAAC',2
                                  ,'AAJ30aAAAAAAsMHAAj',2
                                  ,'AAJ30aAAAAAAn6OAAX',2
                                  ,'AAJ30aAAAAAAsMHAAB',2
                                  ,'AAJ30aAAAAAArq2AAL',2
                                  ,'AAJ30aAAAAAAsLdAAB',2
                                  ,'AAJ30aAAAAAAsk/AAZ',2
                                  ,'AAJ30aAAAAAAtnDAAb',2
                                  ,'AAJ30aAAAAAAt6wAAM',2 ,1)
       , t.vlminimo = DECODE(ROWID,'AAJ30aAAAAAAn6PAAR',1073.61
                                  ,'AAJ30aAAAAAAoSlAAC',721.94
                                  ,'AAJ30aAAAAAAoolAAO',1445.24
                                  ,'AAJ30aAAAAAApW2AAI',50538.96
                                  ,'AAJ30aAAAAAApaUAAe',1960.46
                                  ,'AAJ30aAAAAAApbgAAQ',927.18
                                  ,'AAJ30aAAAAAApfnAAK',563.04
                                  ,'AAJ30aAAAAAAphbAAK',528.42
                                  ,'AAJ30aAAAAAApinAAB',494.04
                                  ,'AAJ30aAAAAAApkrAAA',2572.56
                                  ,'AAJ30aAAAAAApmKAAc',102.97
                                  ,'AAJ30aAAAAAArCrAAZ',407.89
                                  ,'AAJ30aAAAAAArJGAAR',132.21
                                  ,'AAJ30aAAAAAArNyAAD',5293.65
                                  ,'AAJ30aAAAAAArUuAAR',5.65
                                  ,'AAJ30aAAAAAArUuAAY',64.47
                                  ,'AAJ30aAAAAAAsL8AAU',341.49
                                  ,'AAJ30aAAAAAAsL9AAa',85.33
                                  ,'AAJ30aAAAAAAsL+AAN',139.76
                                  ,'AAJ30aAAAAAAsL+AAV',39.31
                                  ,'AAJ30aAAAAAAsL/AAI',105.61
                                  ,'AAJ30aAAAAAAsMBAAa',1625.97
                                  ,'AAJ30aAAAAAAsMCAAY',126.17
                                  ,'AAJ30aAAAAAAsMFAAF',309.04
                                  ,'AAJ30aAAAAAAus3AAI',1378.85
                                  ,'AAJ30aAAAAAAvVoAAP',65
                                  ,'AAJ30aAAAAAAwHMAAK',4951.65
                                  ,'AAJ30aAAAAAAwe5AAE',350.15
                                  ,'AAJ30aAAAAAAxIJAAH',934.79 , t.vlminimo)
   WHERE ROWID IN ('AAJ30aAAAAAAoyBAAU','AAJ30aAAAAAApbgAAp','AAJ30aAAAAAApbhAAc','AAJ30aAAAAAArJBAAK','AAJ30aAAAAAArUvAAC'
                  ,'AAJ30aAAAAAAn6OAAX','AAJ30aAAAAAAoolAAO','AAJ30aAAAAAApaUAAe','AAJ30aAAAAAApfnAAK','AAJ30aAAAAAArCrAAZ'
                  ,'AAJ30aAAAAAAn6PAAR','AAJ30aAAAAAAoSlAAC','AAJ30aAAAAAApW2AAI','AAJ30aAAAAAApW2AAI','AAJ30aAAAAAApbgAAQ'
                  ,'AAJ30aAAAAAAphbAAK','AAJ30aAAAAAApinAAB','AAJ30aAAAAAApkrAAA','AAJ30aAAAAAApmKAAc','AAJ30aAAAAAArJGAAR'
                  ,'AAJ30aAAAAAArNyAAD','AAJ30aAAAAAArUuAAR','AAJ30aAAAAAArUuAAY','AAJ30aAAAAAAsL8AAU','AAJ30aAAAAAAsL9AAa'
                  ,'AAJ30aAAAAAAsL+AAN','AAJ30aAAAAAAsL+AAV','AAJ30aAAAAAAsL/AAI','AAJ30aAAAAAAsMBAAa','AAJ30aAAAAAAsMCAAY'
                  ,'AAJ30aAAAAAAsMFAAF','AAJ30aAAAAAAsMHAAB','AAJ30aAAAAAAsMHAAj','AAJ30aAAAAAArq2AAL','AAJ30aAAAAAAsLdAAB'
                  ,'AAJ30aAAAAAAsk/AAZ','AAJ30aAAAAAAtnDAAb','AAJ30aAAAAAAt6wAAM','AAJ30aAAAAAAus3AAI','AAJ30aAAAAAAvVoAAP'
                  ,'AAJ30aAAAAAAwHMAAK','AAJ30aAAAAAAwe5AAE','AAJ30aAAAAAAxIJAAH');
  
  UPDATE crapcob t 
     SET t.tpjurmor = 3
       , t.vljurdia = 0
   WHERE ROWID IN ('AAJ30aAAAAAAzq0AAD','AAJ30aAAAAAA0J7AAF','AAJ30aAAAAAAsLcAAN','AAJ30aAAAAAAsQEAAN');

  UPDATE crapcob t 
     SET t.vlabatim = (t.nrdocmto / 100) 
   WHERE ROWID IN ('AAJ30aAAAAAA01mAAU','AAJ30aAAAAAA1fOAAG','AAJ30aAAAAAAvVoAAL','AAJ30aAAAAAAtk6AAe');
  
  UPDATE crapcob t 
     SET t.tpjurmor = 3
       , t.vljurdia = 0
       , t.tpdmulta = 3 
       , t.vlrmulta = 0
       , t.vlabatim = 15
   WHERE ROWID IN ('AAJ30aAAAAAAsLsAAT','AAJ30aAAAAAAsL0AAU','AAJ30aAAAAAAtnEAAN','AAJ30aAAAAAAuXGAAG');
  
  UPDATE crapcob t 
    SET t.tpjurmor = 3
       , t.vljurdia = 0
       , t.tpdmulta = 3 
       , t.vlrmulta = 0
       , t.vldescto = (t.nrdocmto / 100)
   WHERE ROWID IN ('AAJ30aAAAAAA01mAAY','AAJ30aAAAAAA01lAAG','AAJ30aAAAAAAusBAAM','AAJ30aAAAAAAuA6AAt');
  
  UPDATE crapcob t 
     SET t.tpdmulta = 3 
       , t.vlrmulta = 0
       , t.vldescto = (t.nrdocmto / 100)
   WHERE ROWID IN ('AAJ30aAAAAAA01lAAB','AAJ30aAAAAAA1fOAAM','AAJ30aAAAAAA1fgAAY','AAJ30aAAAAAAzwbAAe');
  
  UPDATE crapfsf t 
     SET t.dtferiad = to_date('11/01/2023', 'dd/mm/yyyy')
       , t.tpferiad = 0
   WHERE t.cdcidade IN (4109,16300,1212) 
     AND t.dtferiad = to_date('09/01/2023', 'dd/mm/yyyy');
  
  COMMIT;
  
END;
