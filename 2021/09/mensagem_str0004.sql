begin
  insert into crapsqt (nmtabela, nmdcampo, dsdchave, flgciclo, qtincrem, qtmaxseq)
  values ('TBSPB_MSG_STR0004', 'SEQUENCE', 'CDCOOPER', 0, 1, 999999999999999);

  insert into crapsqu (nmtabela, nmdcampo, dsdchave, nrseqatu)
  values ('TBSPB_MSG_STR0004', 'SEQUENCE', 3, 0);

  COMMIT;
end;
