BEGIN
  INSERT INTO expurgo.tbhst_controle (
         nmowner,
         nmtabela,
         nmcampo_refere,
         nrdias_refere,
         tpintervalo,
         nmanalista,
         dtinicio,
         tpoperacao
  ) VALUES (
         'CARTAO',
         'TBCRD_LOG_CARTAO',
         'DHLOG',
         120,
         4,
         'Paulo Rech',
         SYSDATE,
         3
  );
  
  COMMIT;
END;  
