BEGIN
  UPDATE CECRED.crapcob cob
     SET cob.vltitulo = cob.vltitulo + cob.vlabatim + cob.vldescto + 100
   WHERE cob.nrdident = '3024021601134316785';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_cdcooper => 3, pr_compleme => 'boleto 3024021601134316785');
    ROLLBACK;
    RAISE;
END;