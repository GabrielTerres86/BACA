begin
  insert into cecred.tbseg_parametros_prst (IDSEQPAR, CDCOOPER, TPPESSOA, CDSEGURA, TPDPAGTO, MODALIDA, QTPARCEL, PIEDIAS, PIEPARCE, PIELIMIT, PIETAXA, IFTTDIAS, IFTTPARC, IFTTLIMI, IFTTTAXA, LMPSELEG, TPCUSTEI, VLCOMISS, TPADESAO, LIMITDPS, NRAPOLIC, ENDERFTP, LOGINFTP, SENHAFTP, FLGELEPF, FLGINDEN, IDADEDPS, PAGSEGU, SEQARQU, DTINIVIGENCIA, DTFIMVIGENCIA, LMINSOCI, DTCTRMISTA)
  values (cecred.tbseg_parametros_prst_seq.nextval, 5, 1, 514, 0, 0, 0, 0, 0, 0.00, 0.00000000, 0, 0, 0.00, 0.00000000, 0.00, 1, 0.00, 1, 199999.99, '77001236', 'filetransfer.icatuseguros.com.br', 'Producao-Ailos', '@Ailos2019@', 0, 0, 0, 0.02088, 0, to_date('05-11-2023', 'dd-mm-yyyy'), to_date('31-12-2053', 'dd-mm-yyyy'), 0.00, null);
  commit;
end; 
