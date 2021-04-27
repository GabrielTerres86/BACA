BEGIN
  FOR R IN (SELECT CDCOOPER FROM crapcop b  WHERE b.flgativo = 1) LOOP
    /*Pessoa Física*/
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,1,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,2,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,8,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,10,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,11,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,12,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,13,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,14,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,15,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,16,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,17,1,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,18,1,'1');

    /*Pessoa Jurídica*/
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,1,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,3,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,4,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,5,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,6,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,7,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,8,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,9,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,10,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,13,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,14,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,15,2,'1');
    INSERT INTO credito.TBCRED_RECIPROCIDADE(CDCOOPER,tpproduto,cdcatego,inpessoa,cdoperad) VALUES (R.CDCOOPER,0,16,2,'1');
  END LOOP;  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;  
END;
