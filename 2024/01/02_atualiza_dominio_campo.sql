BEGIN 
 UPDATE tbgen_dominio_campo t
    SET t.DSCODIGO = 'CESSAO CARTAO ORIGINACAO'
  WHERE t.CDDOMINIO = 9
    AND t.NMDOMINIO = 'INORIGEM_RATING'
   ;
 COMMIT;
END;
