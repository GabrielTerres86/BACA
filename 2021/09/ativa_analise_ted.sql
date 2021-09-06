BEGIN

UPDATE tbgen_analise_fraude_param a
   SET a.flgativo = 1
 WHERE a.cdoperacao = 12;
 COMMIT;
END;

