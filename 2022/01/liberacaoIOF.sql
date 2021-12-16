BEGIN
  UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00008200 WHERE tit.tpiof = 2;
  UPDATE tbgen_iof_taxa tit SET tit.vltaxa_iof = 0.00004100 WHERE tit.tpiof = 3;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;