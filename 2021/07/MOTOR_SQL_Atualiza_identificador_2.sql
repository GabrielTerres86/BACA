begin

  UPDATE crapbpr x SET flgregim = 0 WHERE  x.cdcooper = 8 AND x.nrdconta = 4715 AND x.NRCTRPRO = 8858 AND x.idseqbem = 19;

  commit;

end;