INSERT INTO crapaut(cdagenci, nrdcaixa, dtmvtolt, nrsequen, cdopecxa, hrautent, vldocmto, nrdocmto, tpoperac, cdstatus, estorno, nrseqaut 
                   , cdhistor, dslitera, blidenti, bltotpag, bltotrec, blsldini, blvalrec, inusodbl, nrdconta, nrdctadp, dsleitur, dsobserv
                   , cdcooper, dsprotoc) 
     VALUES (1, 4, to_date('07-01-2021', 'dd-mm-yyyy'), 5, 'f0010292', 31226, 1234.08, 31226.00, 1, '1', 0, 0, 135, 'VIACREDI - COOPERATIVA DE CREDITO DO VALE DO ITA                                                07/01/21 08:42:19 PA  001  CAIXA:  04/f0010292                                                        ** COMPROVANTE   31.226 **                                                                CONTA...: 58.2   PA:  1                                MOACIR KRAMBECK                                 MARY KRAMBECK                                                                               TIPO DE DEBITO                   VALOR EM R$ ------------------------------------------------    DB.AUTORIZADO                      1.234,08                                                 FGTS E social                                                                                   _______________________________________________ ASSINATURA                                                                                      085010100104 00005 070121             *1.234,08P                                                                                                                                                                                                                                                                                                                                                                                                ', '58.2 - MOACIR KRAMBECK 08:33:56', 1234.08
             , 1234.08, 0.00, 0.00, 0, 0, 0, ' ', ' ', 1, ' ');
commit;
INSERT INTO crapaut(cdagenci, nrdcaixa, dtmvtolt, nrsequen, cdopecxa, hrautent, vldocmto, nrdocmto, tpoperac, cdstatus, estorno, nrseqaut 
                   , cdhistor, dslitera, blidenti, bltotpag, bltotrec, blsldini, blvalrec, inusodbl, nrdconta, nrdctadp, dsleitur, dsobserv
                   , cdcooper, dsprotoc) 
     VALUES (1, 4, to_date('07-01-2021', 'dd-mm-yyyy'), 6, 'f0010292', 31286, 1234.08, 31286.00, 1, '1', 0, 0, 135, 'VIACREDI - COOPERATIVA DE CREDITO DO VALE DO ITA                                                07/01/21 08:42:19 PA  001  CAIXA:  04/f0010292                                                        ** COMPROVANTE   31.286 **                                                                CONTA...: 58.2   PA:  1                                MOACIR KRAMBECK                                 MARY KRAMBECK                                                                               TIPO DE DEBITO                   VALOR EM R$ ------------------------------------------------    DB.AUTORIZADO                      1.234,08                                                 FGTS E social                                                                                   _______________________________________________ ASSINATURA                                                                                      085010100104 00006 070121             *1.234,08P                                                                                                                                                                                                                                                                                                                                                                                                ', '58.2 - MOACIR KRAMBECK 08:33:56', 1234.08
             , 1234.08, 0.00, 0.00, 0, 0, 0, ' ', ' ', 1, ' ');
commit;

update crapaut
   set nrseqaut = 5
     , dslitera = '085010100104 00043 070121E00005       1.234,08PG'
 WHERE cdcooper = 1
   AND cdagenci = 1
   AND nrdcaixa = 4
   AND dtmvtolt = to_date('07/01/2021', 'dd/mm/yyyy')
   AND nrsequen = 43;
commit;
 update crapaut
    set nrseqaut = 6
      , dslitera = '085010100104 00044 070121E00006       1.234,08PG'
 WHERE cdcooper = 1
   AND cdagenci = 1
   AND nrdcaixa = 4
   AND dtmvtolt = to_date('07/01/2021', 'dd/mm/yyyy')
   AND nrsequen = 44;
commit;
