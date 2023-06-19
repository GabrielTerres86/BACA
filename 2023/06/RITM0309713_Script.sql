DECLARE
BEGIN

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 13
     AND c.nrcnvcob = 112004
     AND c.nrdocmto = 1806
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 300144
     AND c.vltitulo = 862;
  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 7
     AND c.nrcnvcob = 10620
     AND c.nrdocmto = 3380
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 72141
     AND c.vltitulo = 537;
  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 101004
     AND c.nrdocmto = 14797
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 3815439
     AND c.vltitulo = 444.47;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 13
     AND c.nrcnvcob = 112001
     AND c.nrdocmto = 2
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 16425995
     AND c.vltitulo = 2792;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 101004
     AND c.nrdocmto = 14120
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 3815439
     AND c.vltitulo = 733.20;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 10120
     AND c.nrdocmto = 4651
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 7781440
     AND c.vltitulo = 6588.01;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 10120
     AND c.nrdocmto = 4647
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 7781440
     AND c.vltitulo = 24758.10;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 101070
     AND c.nrdocmto = 4238
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 4061632
     AND c.vltitulo = 466.89;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 13
     AND c.nrcnvcob = 112002
     AND c.nrdocmto = 14473
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 406821
     AND c.vltitulo = 586.39;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 10110
     AND c.nrdocmto = 2706
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 7794185
     AND c.vltitulo = 1471.80;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 13
     AND c.nrcnvcob = 112001
     AND c.nrdocmto = 1859
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 249580
     AND c.vltitulo = 2036.60;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 101002
     AND c.nrdocmto = 4
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 16336755
     AND c.vltitulo = 2782.76;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 101004
     AND c.nrdocmto = 827
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 11912960
     AND c.vltitulo = 352.50;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 1
     AND c.nrcnvcob = 101070
     AND c.nrdocmto = 4234
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 4061632
     AND c.vltitulo = 466.89;

  DELETE FROM cecred.tbcobran_retorno_ieptb c
   WHERE c.cdcooper = 13
     AND c.nrcnvcob = 112003
     AND c.nrdocmto = 250436
     AND c.idconciliacao = 0
     AND c.nrremret IS NULL
     AND c.nrdconta = 334065
     AND c.vltitulo = 239.95;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao excluir retornos ieptb ' || SQLERRM);
END;
