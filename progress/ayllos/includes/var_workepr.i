/* .............................................................................

   Programa: Includes/var_workepr.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo/Margarete
   Data    : Marco/2006.                         Ultima atualizacao: 07/10/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar as TEMP-TABLE, VAR e FORM de uso referente a emprestimos.

   Alteracoes: 07/07/2006 - Criar campo nrdconta nas TEMP-TABLES (Edson).
   
               02/10/2006 - Aumento do EXTENT p/ 199 nrrecepr e nrctremp (Ze).
               
               20/12/2006 - Inclusao do campo Valor do Abono (Elton).
               
               19/12/2007 - Alterado EXTENT nas variaves epr_nrrecepr e 
                            epr_nrctremp (Diego).
               
               30/12/2008 - Inclusao de variavel para imprimir (Gabriel).
               
               11/01/2009 - Inclusao da variavel tel_extcash (Fernando).  
               
               07/10/2010 - Incluir campo de linha de credito (Gabriel).
............................................................................. */

DEF {1} SHARED TEMP-TABLE workepr                                      NO-UNDO
               FIELD nrdconta AS INT     FORMAT "zzzz,zzz,9"
               FIELD nrctremp AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"
               FIELD vlemprst AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"
               FIELD vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
               FIELD vlpreemp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"
               FIELD vlprepag AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"
               FIELD txjuremp AS DECIMAL DECIMALS 7 FORMAT "zz,zz9.9999999"
               FIELD vljurmes AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
               FIELD vljuracu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
               FIELD vlprejuz AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
               FIELD vlsdprej AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
               FIELD dtprejuz AS DATE    FORMAT "99/99/9999"
               FIELD vljrmprj AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
               FIELD vljraprj AS DECIMAL FORMAT "zzz,zzz,zz9.99-"
               FIELD inprejuz LIKE crapepr.inprejuz
               FIELD vlprovis AS DECIMAL FORMAT "zzz,zzz,zz9.99"
               FIELD flgpagto AS LOGICAL FORMAT "Folha/Conta"
               FIELD dtdpagto AS DATE    FORMAT "99/99/9999"
               FIELD cdpesqui AS CHAR    FORMAT "x(25)"
               FIELD dspreapg AS CHAR    FORMAT "x(25)"
               FIELD cdlcremp AS INTE
               FIELD dslcremp AS CHAR    FORMAT "x(20)"
               FIELD dsfinemp AS CHAR    FORMAT "x(20)"
               FIELD dsdaval1 AS CHAR    FORMAT "x(29)"
               FIELD dsdaval2 AS CHAR    FORMAT "x(29)"
               FIELD vlpreapg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
               FIELD qtmesdec AS INTEGER FORMAT "99"
               FIELD qtprecal AS DECIMAL FORMAT "999.9999-"
               FIELD vlacresc AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
               FIELD vlrpagos AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
               FIELD slprjori AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
               FIELD dtultpag AS DATE    FORMAT "99/99/9999"
               FIELD vlrabono LIKE craplem.vllanmto
               FIELD qtpreemp LIKE crapepr.qtpreemp.

DEF {1} SHARED TEMP-TABLE workepr_salvo                                 NO-UNDO
               FIELD nrdconta AS INT     FORMAT "zzzz,zzz,9"
               FIELD nrctremp AS DECIMAL FORMAT "zz,zzz,zzz,zzz,zz9"
               FIELD vlsdeved AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-"
               FIELD vlpreemp AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99" 
               FIELD qtmesdec AS INTEGER FORMAT "99"
               FIELD qtprecal AS DECIMAL FORMAT "999.9999-" 
               FIELD dtdpagto AS DATE    FORMAT "99/99/9999"
               FIELD vlpreapg AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-".

DEF {1} SHARED VAR epr_dttitulo AS CHAR                             NO-UNDO.
DEF {1} SHARED VAR epr_nrrecepr AS INT     EXTENT 400               NO-UNDO.
DEF {1} SHARED VAR epr_nrctremp AS INT     EXTENT 400               NO-UNDO.

DEF {1} SHARED VAR tel_dsdpagto AS CHAR    FORMAT "x(36)"           NO-UNDO.
DEF {1} SHARED VAR tel_qtaditivos AS INT   FORMAT "zzz"             NO-UNDO.
DEF {1} SHARED VAR tel_imprimir AS CHAR    FORMAT "x(8)"
                                           INIT "Imprimir"          NO-UNDO.
DEF {1} SHARED VAR tel_prejuizo AS CHAR    FORMAT "x(8)"             
                                           INIT "Prejuizo"          NO-UNDO.
DEF {1} SHARED VAR tel_dsdemais AS CHAR    FORMAT "x(8)"
                                           INIT "Continua"          NO-UNDO.
DEF {1} SHARED VAR tel_extratos AS CHAR    FORMAT "x(7)"
                                           INIT "Extrato"           NO-UNDO.
DEF {1} SHARED VAR tel_extcash AS  CHAR    FORMAT "x(4)"
                                           INIT "Cash"              NO-UNDO.
DEF {1} SHARED VAR aux_txdjuros AS DEC     DECIMALS 7               NO-UNDO.
DEF {1} SHARED VAR aux_nrctremp AS INT                              NO-UNDO.

DEF {1} SHARED VAR aux_vlsdeved AS DEC     FORMAT "zzz,zzz,zzz,zz9.99-" 
                                                                    NO-UNDO.
DEF {1} SHARED VAR aux_vljuracu AS DEC     FORMAT "zzz,zzz,zz9.99-"  
                                                                    NO-UNDO.
DEF {1} SHARED VAR aux_vlprepag AS DEC     FORMAT "zzz,zzz,zzz,zz9.99" 
                                                                    NO-UNDO.
DEF {1} SHARED VAR aux_vljurmes AS DEC     FORMAT "zzz,zzz,zz9.99-" 
                                                                    NO-UNDO.
DEF {1} SHARED VAR aux_qtprecal AS DEC     DECIMALS 4               NO-UNDO.
DEF {1} SHARED VAR aux_dtmesant AS DATE                             NO-UNDO.
DEF {1} SHARED VAR aux_nrdiacal AS INT                              NO-UNDO.
DEF {1} SHARED VAR aux_inhst093 AS LOGICAL                          NO-UNDO.
DEF {1} SHARED VAR aux_ddlanmto AS INT                              NO-UNDO.
DEF {1} SHARED VAR aux_dtultpag AS DATE                             NO-UNDO.
DEF {1} SHARED VAR aux_qtprepag AS INT                              NO-UNDO.
DEF {1} SHARED VAR aux_nrdiames AS INT                              NO-UNDO.
DEF {1} SHARED VAR aux_nrdiamss AS INT                              NO-UNDO.
DEF {1} SHARED VAR aux_vltotemp AS DECIMAL                          NO-UNDO.
DEF {1} SHARED VAR aux_vltotpre AS DECIMAL                          NO-UNDO.
DEF {1} SHARED VAR aux_nrctatos AS INT                              NO-UNDO.
DEF {1} SHARED VAR aux_cdpesqui AS CHAR    FORMAT "x(25)"           NO-UNDO.
DEF {1} SHARED VAR aux_qtpreapg AS DECIMAL DECIMALS 4               NO-UNDO.
DEF {1} SHARED VAR aux_dslcremp AS CHAR    FORMAT "x(31)"           NO-UNDO.
DEF {1} SHARED VAR aux_dsfinemp AS CHAR    FORMAT "x(31)"           NO-UNDO.
DEF {1} SHARED VAR aux_dsdaval1 AS CHAR    FORMAT "x(42)"           NO-UNDO.
DEF {1} SHARED VAR aux_dsdaval2 AS CHAR    FORMAT "x(42)"           NO-UNDO.
DEF {1} SHARED VAR aux_dtrefavs AS DATE                             NO-UNDO.
DEF {1} SHARED VAR aux_flghaavs AS LOGICAL                          NO-UNDO.
DEF {1} SHARED VAR aux_vltotprv AS DECIMAL                          NO-UNDO.

DEF {1} SHARED FRAME f_emprestimo.
DEF {1} SHARED FRAME f_prejuizo.

FORM SKIP    
     workepr.nrctremp AT  5 LABEL "Contrato"
     workepr.cdpesqui AT 42 LABEL "Pesquisa"
     SKIP
     tel_qtaditivos   AT  2 LABEL "Qt.Aditivos" FORMAT "               zz9"
     SKIP 
     workepr.vlemprst AT  3 LABEL "Emprestado"
     workepr.txjuremp AT 37 LABEL "Taxa de Juros"
     SKIP
     workepr.vlsdeved AT  8 LABEL "Saldo"
     workepr.vljurmes AT 38 LABEL "Juros do Mes"
     SKIP
     workepr.vlpreemp AT  4 LABEL "Prestacao"
     workepr.vljuracu AT 34 LABEL "Juros Acumulados"
     SKIP
     workepr.vlprepag AT  2 LABEL "Pago no Mes"
     workepr.dspreapg AT 34 LABEL "Prest.pagas/Tot."
     workepr.vlpreapg AT  1 LABEL "A Regulariz." 
     workepr.qtmesdec AT 34 LABEL "Meses decorridos" FORMAT "            z9"
     SKIP(1)
     workepr.dslcremp AT  2 LABEL "L. Credito"
     workepr.dsfinemp AT 40 LABEL "Finalidade"
     SKIP
     "Avais:"         AT  2
     workepr.dsdaval1 AT  9 NO-LABEL
     workepr.dsdaval2 AT 40 NO-LABEL
     SKIP
     tel_dsdpagto     AT  2 NO-LABEL
     tel_prejuizo     AT 40 NO-LABEL
     tel_imprimir     AT 50 NO-LABEL
     tel_dsdemais     AT 60 NO-LABEL
     tel_extratos     AT 70 NO-LABEL
     WITH ROW 9 CENTERED NO-LABELS SIDE-LABELS OVERLAY
          TITLE epr_dttitulo FRAME f_emprestimo.

FORM 
     SKIP(1)
     "Transferido em:    " AT 5  workepr.dtprejuz FORMAT "99/99/9999"      
     "Valor do Abono:" AT 40 workepr.vlrabono FORMAT "zzz,zzz,zz9.99-"
     SKIP
     "Prejuizo Original:" AT 2 workepr.vlprejuz FORMAT "zzz,zzz,zz9.99-"
     "Juros do Mes:" AT 42 workepr.vljrmprj FORMAT "zzz,zzz,zz9.99-" 
     SKIP 
     "Sld.Prej.Original:" AT 2 workepr.slprjori FORMAT "zzz,zzz,zz9.99-"
     "Juros Acumulados:" AT 38 workepr.vljraprj FORMAT "zzz,zzz,zz9.99-"
     SKIP
     "Valores Pagos:"   AT 6  workepr.vlrpagos FORMAT "zzz,zzz,zz9.99-"
     "Acrescimos:"      AT 44 workepr.vlacresc FORMAT "zzz,zzz,zz9.99-"
     SKIP
     "Saldo Atualizado:" AT 38 workepr.vlsdprej FORMAT "zzz,zzz,zz9.99-" 
     SKIP(1)
     WITH ROW 12 NO-LABELS CENTERED SIDE-LABELS OVERLAY 
          TITLE "Prejuizos do Contrato" FRAME f_prejuizo.

/* .......................................................................... */
