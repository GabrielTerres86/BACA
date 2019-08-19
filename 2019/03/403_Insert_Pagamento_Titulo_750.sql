DECLARE
vr_nrseqdig tbdsct_lancamento_bordero.nrseqdig%TYPE;
BEGIN
  SELECT nvl(MAX(nrseqdig),0)+1 
  INTO   vr_nrseqdig
  FROM   tbdsct_lancamento_bordero 
  WHERE  nrtitulo = 2
  AND    nrborder = 27273 
  AND    nrdconta = 13862
  AND    cdcooper = 7;

  INSERT INTO tbdsct_lancamento_bordero
         (/*01*/ cdcooper
         ,/*02*/ nrdconta
         ,/*03*/ nrborder
         ,/*04*/ nrtitulo
         ,/*05*/ nrseqdig
         ,/*06*/ cdbandoc
         ,/*07*/ nrdctabb
         ,/*08*/ nrcnvcob
         ,/*09*/ nrdocmto
         ,/*10*/ dtmvtolt
         ,/*11*/ cdorigem
         ,/*12*/ cdhistor
         ,/*13*/ vllanmto )
  VALUES (/*01*/ 7
         ,/*02*/ 13862
         ,/*03*/ 27273
         ,/*04*/ 2
         ,/*05*/ vr_nrseqdig
         ,/*06*/ 85
         ,/*07*/ 10610
         ,/*08*/ 10610
         ,/*09*/ 179
         ,/*10*/ to_date('03/10/2018','DD/MM/RRRR') 
         ,/*11*/ 7
         ,/*12*/ 2672
         ,/*13*/ 750 );
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20001,'Erro ao inserir o lançamento de borderô: '||SQLERRM);
END;
