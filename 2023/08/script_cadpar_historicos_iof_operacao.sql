BEGIN

  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, '01F,10006,100;01G,20006,100;')
   WHERE a.cdcooper = 1
     AND a.cdpartar = 118;
     
  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, '02F,10006,100;02G,20006,100;')
   WHERE a.cdcooper = 2
     AND a.cdpartar = 118;   

  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, '07F,10006,100;07G,20006,100;')
   WHERE a.cdcooper = 7
     AND a.cdpartar = 118;
     
  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, '11F,10006,100;11G,20006,100;')
   WHERE a.cdcooper = 11
     AND a.cdpartar = 118; 

  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, '14F,10006,100;14G,20006,100;')
   WHERE a.cdcooper = 14
     AND a.cdpartar = 118;
     
  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, '16F,10006,100;16G,20006,100;')
   WHERE a.cdcooper = 16
     AND a.cdpartar = 118; 
          
  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, 'VLIOF_OPE,4376/')
  WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE '%HISTORICOS_DEB_SFI/HOME/%'); 
   
  UPDATE cecred.crappco a
     SET a.dsconteu = CONCAT(a.dsconteu, 'VLIOF_OPE,4375/')
   WHERE a.cdpartar = (SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE '%HISTORICOS_DEB_SFI/PJ/%'); 
   
   
  INSERT INTO cecred.crappat(CDPARTAR
                            ,NMPARTAR
                            ,TPDEDADO
                            ,CDPRODUT)
  VALUES((SELECT MAX(cdpartar) + 1 FROM crappat)
         ,'HISTORICOS_DEB_SFI/GARANTIDO/01F,02F,07F,11F,14F,16F'
         ,2
         ,0);

  INSERT INTO cecred.crappco(CDPARTAR
                            ,CDCOOPER
                            ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE '%HISTORICOS_DEB_SFI/GARANTIDO/%')
      ,3
      ,'VLPARCELA,4267/VLIOF,4266/VLMORA,4265/VLMULTA,4264/VLTAXA_ADM,3715/VLSEGURO_MPI,3718/VLSEGURO_DFI,3717/VLNOMINAL,3694/VLIOF_OPE,4376/');
 

  INSERT INTO cecred.crappat(CDPARTAR
                            ,NMPARTAR
                            ,TPDEDADO
                            ,CDPRODUT)
  VALUES((SELECT MAX(cdpartar) + 1 FROM crappat)
         ,'HISTORICOS_DEB_SFI/GARANTIDO/PJ/01G,02G,07G,11G,14G,16G'
         ,2
         ,0);

  INSERT INTO cecred.crappco(CDPARTAR
                            ,CDCOOPER
                            ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE '%HISTORICOS_DEB_SFI/GARANTIDO/PJ/%')
      ,3
      ,'VLPARCELA,4267/VLIOF,4266/VLMORA,4265/VLMULTA,4264/VLTAXA_ADM,3716/VLSEGURO_MPI,3718/VLSEGURO_DFI,3717/VLNOMINAL,3811/VLIOF_OPE,4375/');

  COMMIT;
    
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END; 
