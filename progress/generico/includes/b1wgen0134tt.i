/* ..........................................................................

   Programa: Includes/var_hisopcr.i
   Sigla   : CRED
   Autor   : Tiago
   Data    : Fevereiro/2012.                   Ultima atualizacao: 19/11/2017

   Dados referentes ao programa:
  
   Objetivo  : Criar as variaveis para o historico de credito.
               
   Alteracoes: 12/06/2014 - Adicionar novos historico. (James)
               
               06/03/2015 - Adicionar novos historico (1539). SD 255246 (Kelvin)
               
               11/08/2015 - Adicionado novos historicos. (Reinert)
                
               06/10/2016 - Adicionado novos historicos(2193, 2194, 2180, 2181, 2182),
                            Prj. 302. (Jean Michel)

			   19/11/2017 - Incusao do historico 354 (Jonata - RKAM P364).
                
............................................................................*/
DEF VAR aux_histcred  AS INT EXTENT INIT [1032,        /* Contrato Empr */
                                          1033,        /* Contrato Fina */
                                          1034,        /* Juros Apr Emp */
                                          1035,        /* Juros Apr Fin */
                                          1036,        /* Lib Empr.Fin. */
                                          1037,        /* Juros Empr.   */
                                          1038,        /* Juros Financ. */
                                          1039,        /* Pg. Financ. c/c  */
                                          1040,        /* Db.Juros Empr */
                                          1041,        /* Cr.Juros Empr */
                                          1042,        /* Db.Juros Fina */
                                          1043,        /* Cr.Juros Fina */
                                          1044,        /* Pg. Empr. c/c */
                                          1045,        /* Pg. Aval. Emp */
                                          1046,        /* Pg. Empr. Cotas */
                                          1047,        /* Multa Empr. */
                                          1048,        /* Desc.Ant.Emp. */
                                          1049,        /* Desc.Ant.Fina */
                                          1050,        /* JurosAtrasoEmp */
                                          1051,        /* JuroAtrasoFin */
                                          1052,        /* Est. Parc.Fina */
                                          1053,        /* Desc.Est.Empr */
                                          1054,        /* Desc.Est.Fina */
                                          1055,        /* EstDescAntEmp */
                                          1056,        /* EstDescAntFin */
                                          1057,        /* Pg. Aval.Fina */
                                          1058,        /* Pg. Fina Cotas */
                                          1060,        /* Multa Empr. */
                                          1070,        /* Multa Fin. */
                                          1071,        /* Jur. Mora Emp. */
                                          1072,        /* Jur. Mora Fin. */
                                          1073,        /* Est. Parc.Emp. */
                                          1074,        /* EstTrfCotasEm */
                                          1075,        /* EstTrfCotasFin */
                                          1076,        /* Multa Financ. */
                                          1077,        /* Jur. Mora Emp. */
                                          1078, /* Jur. Mora Fin. */
                                          1618, /* Pg. Aval. Multa Fin. */
                                          1619, /* Pg. Aval. Jur. Mora Emp. */
                                          1620, /* Pg. Aval. Jur. Mora Fin. */
                                          1540, /* Pg. Aval. Multa Emp. */
                                          1541,        /* Aval. Multa Emp. */
                                          1542,        /* Aval. Multa Fin. */
                                          1543,        /* Aval. Jur. Mora Emp. */
                                          1544, /* Aval. Jur. Mora Fin.*/
                                          1539, /* Pg. Parc. Tx.*/
                                          1059, /* LIBER.DO CRED */
                                          1705, /* EST.PARC.EMP. */
                                          1707, /* EST.PARC.FIN. */
                                          1708, /* EST.MULTA EMP */
                                          1711, /* EST.JUROS EMP */ 
                                          1714, /* EST.PARC.AVAL */
                                          1716, /* EST.PARC AVAL */
                                          1717, /* EST.MULTA AVA */
                                          1720, /* EST.MORA AVAL */
                                          1731, /* TRF. PREJUIZO */
                                          1732, /* TRF. PREJUIZO */
                                          1733, /* MULTA TR.PREJ */
                                          1734, /* MULTA TR.PREJ */
                                          1735, /* JUR.MORA PREJ */
                                          1736, /* JUR.MORA PREJ */ 
                                          2193, /* DB.BLOQ.ACORD */
                                          2194, /* CR.DESB.ACORD */
                                          2180, /* CRED.COB.ACOR */
                                          2181, /* ABAT.CONC.ACO */
                                          2182,  /* PAG.DESP.ACOR */                                                                 
                                          /* 25072017 - Jean - Historicos que nao podem ser utilizados melhoria 324 */
                                           349,  /* TRF. PREJUIZO */
                                            350,  /* TRF. PREJUIZO */
                                            391,  /* Pagamento lote 200 */
                                            382,  /* pagamento lote 200 */
                                            384,  /* pagamento lote 100 */
                                            383,  /* abono do prejuizo */
                                          775, /* EST LIQ PREJ */
                                          1586, /*CR PREJ FRAUD */
                                          1587, /*CR PREJ FRAUD*/
                                          1839, /*BAIXA PREJ*/
                                          2288, /*ABONO CT PREJ*/
                                          2381, /* TRF. PREJUIZO */
                                          2382, /* TRF. PREJ JUR */
                                          2383, /* EST.PREJUIZO */
                                          2384, /* EST. PREJ JUR */
                                          2385, /* TRF.PREJ.FRAU */
                                          2386, /* REC. PREJUIZO */
                                          2387, /* EST.REC.PREJ */
                                          2388, /* PAG.PREJ.PRIN */
                                          2389, /* PAG.JUR.PREJ */
                                          2390, /* PAG.ENCA.PREJ */
                                          2391, /* ABONO PREJUIZO */
                                          2392, /* EST.PAG.PREJ */
                                          2393, /* EST.JUR.PREJ */
                                          2394, /* EST.ENCA.PREJ */
                                          2395, /* EST.ABON PREJ */
                                          2396, /* TRF. PREJUIZO */
                                          2397, /* TRF. PREJ JUR */
                                          2398, /* EST.PREJUIZO */
                                          2399, /* EST. PREJ JUR */
                                          2400, /* TRF.PREJ.FRAU */
                                          2401, /* TRF. PREJUIZO */
                                          2402, /* TRF. PREJ JUR */
                                          2403, /* EST.PREJUIZO */
                                          2404, /* EST. PREJ JUR */
                                          2405, /* TRF.PREJ.FRAU */
                                          2406, /* TRF. PREJ JUR */
                                          2407, /* EST. PREJ JUR */
                                          2408, /* TRF. PREJUIZO */
                                          2409, /* JUROS PREJUIZO */
                                          2410, /* EST. TRANSF P */
                                          2411, /* ENCARG.PREJ */
                                          2412, /* TRF.PREJ.FRAU */
                                          2421, /* DESP REC CRED */
                                          2422, /* ESTJUROS PREJ */
                                          2423, /* EST.ENCA.PREJ */
                                          2424, /* EST.DESP.PREJ */
										  354  /* credito cotas */] NO-UNDO.
                        
                                            
