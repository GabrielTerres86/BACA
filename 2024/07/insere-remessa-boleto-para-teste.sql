BEGIN

insert into tbcobran_remessa_npc (CDLEGADO, IDTITLEG, IDOPELEG, NRISPBAD, NRISPBPR, TPOPERAD, DHOPERAD, TPPESORI, NRDOCORI, NMDOCORI, NMFANORI, NMLOGORI, NMCIDORI, NMUFORIG, NRCEPORI, TPPESFIN, NRDOCFIN, NMDOCFIN, NMFANFIN, TPPESPAG, NRDOCPAG, NMDOCPAG, NMFANPAG, NMLOGPAG, NMCIDPAG, NMUFPAGA, NRCEPPAG, TPIDESAC, NRIDESAC, NMDOCSAC, CDCARTEI, CODMOEDA, NRNOSNUM, CDCODBAR, NRLINDIG, DTVENCTO, VLVALOR, NRNUMDOC, CDESPECI, DTEMISSA, QTDIAPRO, DTLIMPGTO, TPPGTO, NUMPARCL, QTTOTPAR, IDTIPNEG, IDBLOQPAG, IDPAGPARC, QTPAGPAR, VLABATIM, DTJUROS, CODJUROS, VLPERJUR, DTMULTA, CODMULTA, VLPERMUL, DTDESCO1, CDDESCO1, VLPERDE1, DTDESCO2, CDDESCO2, VLPERDE2, DTDESCO3, CDDESCO3, VLPERDE3, NRNOTFIS, TPPEMITT, VLPEMITT, TPPEMATT, VLPEMATT, TPMODCAL, TPRECVLD, IDNRCALC, TXBENEFI, NRIDENTI, NRSQCATI, NRFACATI, TPBAIXEFT, NRISPBTE, CDPATTER, DHBAIXEF, DTBAIXEF, VLBAIXEF, CDCANPGT, CDMEIOPG, NRIDEBOL, NRFATBEF, CDSITUAC, CDCOOPER, FLONLINE, DTMVTOLT)
values ('LEG', 135859923, 227260715, 5463212, 5463212, 'I', 20240701165047, 'J', 49727921000140, 'DANIEL MENDES', 'GOLFINHO LTDA', null, null, null, null, 'J', 49727921000140, 'DANIEL MENDES', 'GOLFINHO LTDA', 'F', 57593848051, 'CARLOS SANTOS', null, 'GENERAL OSORIO', 'BLUMENAU', 'SC', 89042000, 0, null, null, '1', '09', '83614206000000048', '08599976600000015001080018361420600000004801', '08591080031836142060900000048017997660000001500', 20240703, 15.00, 'TESTE/0001', '2', 20240701, null, 20240831, 3, null, null, 'N', 'N', 'N', null, 0.00, null, '5', 0.00000, null, '3', 0.00000, null, '0', 0.00000, null, null, null, null, null, null, 'N', null, null, 'V', 15.00000, '01', '3', 'N', null, null, null, null, null, null, null, null, null, null, null, null, null, null, 0, 9, 'S', to_date('01-07-2024', 'dd-mm-yyyy'));
  COMMIT;

END;