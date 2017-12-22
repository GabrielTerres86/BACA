/* ..........................................................................

   Programa: Includes/var_hisopcr.i
   Sigla   : CRED
   Autor   : Tiago
   Data    : Fevereiro/2012.                   Ultima atualizacao: 20/12/2017

   Dados referentes ao programa:
  
   Objetivo  : Criar as variaveis para o historico de credito.
               
   Alteracoes: 12/06/2014 - Adicionar novos historico. (James)
               
               06/03/2015 - Adicionar novos historico (1539). SD 255246 (Kelvin)
               
               11/08/2015 - Adicionado novos historicos. (Reinert)
                
               06/10/2016 - Adicionado novos historicos(2193, 2194, 2180, 2181, 2182),
                            Prj. 302. (Jean Michel)
                
			         19/11/2017 - Incusao do historico 354 (Jonata - RKAM P364).
                
               20/12/2017 - Inclusao dos historicos 2013 e 2014, Prj. 402 (Jean Michel). 
               
............................................................................*/
DEF VAR aux_histcred  AS INT EXTENT INIT [ 354, /* credito cotas */
                                          1032,	/* Contrato Empr */
                                          1033,	/* Contrato Fina */
                                          1034,	/* Juros Apr Emp */
                                          1035,	/* Juros Apr Fin */
                                          1036,	/* Lib Empr.Fin. */
                                          1037,	/* Juros Empr.   */
                                          1038,	/* Juros Financ. */
                                          1039,	/* Pg. Financ. c/c  */
                                          1040,	/* Db.Juros Empr */
                                          1041,	/* Cr.Juros Empr */
                                          1042,	/* Db.Juros Fina */
                                          1043,	/* Cr.Juros Fina */
                                          1044,	/* Pg. Empr. c/c */
                                          1045,	/* Pg. Aval. Emp */
                                          1046,	/* Pg. Empr. Cotas */
                                          1047,	/* Multa Empr. */
                                          1048,	/* Desc.Ant.Emp. */
                                          1049,	/* Desc.Ant.Fina */
                                          1050,	/* JurosAtrasoEmp */
                                          1051,	/* JuroAtrasoFin */
                                          1052,	/* Est. Parc.Fina */
                                          1053,	/* Desc.Est.Empr */
                                          1054,	/* Desc.Est.Fina */
                                          1055,	/* EstDescAntEmp */
                                          1056,	/* EstDescAntFin */
                                          1057,	/* Pg. Aval.Fina */
                                          1058,	/* Pg. Fina Cotas */
                                          1059, /* LIBER.DO CRED */
                                          1060,	/* Multa Empr. */
                                          1070,	/* Multa Fin. */
                                          1071,	/* Jur. Mora Emp. */
                                          1072,	/* Jur. Mora Fin. */
                                          1073,	/* Est. Parc.Emp. */
                                          1074,	/* EstTrfCotasEm */
                                          1075,	/* EstTrfCotasFin */
                                          1076,	/* Multa Financ. */
                                          1077,	/* Jur. Mora Emp. */
                                          1078, /* Jur. Mora Fin. */                                          
                                          1539, /* Pg. Parc. Tx.*/
                                          1540, /* Pg. Aval. Multa Emp. */
                                          1541,	/* Aval. Multa Emp. */
                                          1542,	/* Aval. Multa Fin. */
                                          1543,	/* Aval. Jur. Mora Emp. */
                                          1544, /* Aval. Jur. Mora Fin.*/
                                          1618, /* Pg. Aval. Multa Fin. */
                                          1619, /* Pg. Aval. Jur. Mora Emp. */
                                          1620, /* Pg. Aval. Jur. Mora Fin. */                                          
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
                                          2013, /* Empréstimo CDC */
                                          2014, /* Financiamento CDC */
                                          2180, /* CRED.COB.ACOR */
                                          2181, /* ABAT.CONC.ACO */
                                          2182, /* PAG.DESP.ACOR */
                                          2193, /* DB.BLOQ.ACORD */
                                          2194] /* CR.DESB.ACORD */ NO-UNDO.
                        
                                            
