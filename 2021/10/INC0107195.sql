begin

  delete crapneg a
   where a.vlestour = 29940.28
     and a.nrseqdig = 62
     and a.qtdiaest = 7
     and a.nrdconta = 500100
     and a.cdcooper = 13;

  delete crapneg a
   where a.vlestour = 983.28
     and a.nrseqdig = 63
     and a.qtdiaest = 1
     and a.nrdconta = 500100
     and a.cdcooper = 13;

  update crapsda a
     set a.VLADDUTL = 0
   where a.nrdconta = 500100
     and a.cdcooper = 13
     and (a.VLADDUTL = 29940.28 or a.VLADDUTL = 983.28);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'Erro ao executar script: ' || SQLERRM);
  
END;
