BEGIN
  -- Cancelamento da proposta de Majoração
  UPDATE crawlim w
     SET w.insitlim = 3
   WHERE w.cdcooper = 1
     AND w.nrdconta = 9252797
     AND w.tpctrlim = 2
     AND w.nrctrlim = 131157
     AND w.nrctrmnt = 105706;

  COMMIT;
END;
