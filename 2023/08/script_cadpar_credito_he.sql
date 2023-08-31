BEGIN
 INSERT INTO tbgen_dominio_campo (NMDOMINIO, CDDOMINIO, DSCODIGO)
 VALUES ('TIPOMODALIDADEIMOB', '12', 'Emprestimo Garantia Imovel');

 INSERT INTO cecred.crappat(CDPARTAR
                            ,NMPARTAR
                            ,TPDEDADO
                            ,CDPRODUT)
  VALUES((SELECT MAX(cdpartar) + 1 FROM crappat)
         ,'HISTORICOS_CONTRATO_CRED/HOME/07C,01C,11C,16C,02C,14C'
         ,2
         ,0);

  INSERT INTO cecred.crappco(CDPARTAR
                            ,CDCOOPER
                            ,DSCONTEU)
    VALUES
      ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar LIKE '%HISTORICOS_CONTRATO_CRED/HOME/%')
      ,3
      ,'4235');

  COMMIT;
    
EXCEPTION
   WHEN OTHERS THEN
   ROLLBACK;
END; 
