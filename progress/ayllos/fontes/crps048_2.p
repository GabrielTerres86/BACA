/* ..........................................................................

   Programa: Fontes/crps048_2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson      
   Data    : Fevereiro/2005                      Ultima atualizacao: 29/10/2013

   Dados referentes ao programa:

   Frequencia: Anual (Batch)
   Objetivo  : Atende a solicitacao 30.
               Emite relatorio detalhado dos creditos do retorno de sobras
               (412).
               
   Alteracoes: 15/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               23/02/2006 - Tratar sinal no campo de retorno do capital
                            (Edson).

               14/10/2008 - Adaptacao para desconto de titulos (David).

               02/04/2009 - Alterado LABEL da coluna "BASE JURO CAPITAL" para
                            "BASE CAPITAL" (Elton).
                            
               16/02/2011 - Novo layout 
                            - (dsc chq + dsc tit + epr) = OPER. CREDITOS
                            - IRRF e RETORNO + JUROS (Guilherme)
                            
               22/03/2011 - Aumento das casas decimais para 8 dig (Guilherme).             
                            

               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               09/10/2013 - Tratamento para Imunidade Tributaria (Ze).
               
               29/10/2013 - Ajuste na instancia da BO 159 (Ze).
............................................................................. */

DEF STREAM str_1.     /* Para arquivo de importacao  */
DEF STREAM str_2.     /* Para relatorio */

{ includes/var_batch.i } 

DEF        VAR rel_nrmodulo    AS INT     FORMAT "9"                   NO-UNDO.
DEF        VAR rel_nmmodulo    AS CHAR    FORMAT "x(15)" EXTENT 5
                                  INIT ["DEP. A VISTA   ","CAPITAL        ",
                                        "EMPRESTIMOS    ","DIGITACAO      ",
                                        "GENERICO       "]             NO-UNDO.
DEF        VAR rel_nmempres    AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmresemp    AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF        VAR rel_nmrelato    AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.

DEF        VAR rel_nrdconta    AS INT                                  NO-UNDO.
DEF        VAR rel_dsagenci    AS CHAR                                 NO-UNDO.

DEF        VAR rel_vlmedcap    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlbascap    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlretcap    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlbasepr    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlretepr    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlbasdsc    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlretdsc    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlbastit    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlrettit    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlbasapl    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlretapl    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlbassdm    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlretsdm    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vldeirrf    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlcredit    AS DECIMAL                              NO-UNDO.
DEF        VAR rel_vlcretot    AS DECIMAL                              NO-UNDO.

DEF        VAR pac_qtassoci    AS INT                                  NO-UNDO.
DEF        VAR pac_vlmedcap    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlbascap    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlretcap    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlbasopc    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlretopc    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlbasapl    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlretapl    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlbassdm    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlretsdm    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vldeirrf    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlcredit    AS DECIMAL                              NO-UNDO.
DEF        VAR pac_vlcretot    AS DECIMAL                              NO-UNDO.

DEF        VAR tot_qtassoci    AS INT                                  NO-UNDO.
DEF        VAR tot_vlmedcap    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlbascap    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlretcap    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlbasopc    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlretopc    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlbasapl    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlretapl    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlbassdm    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlretsdm    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vldeirrf    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlcredit    AS DECIMAL                              NO-UNDO.
DEF        VAR tot_vlcretot    AS DECIMAL                              NO-UNDO.

DEF        VAR ger_qtassoci    AS INT                                  NO-UNDO.
DEF        VAR ger_vlmedcap    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlbascap    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlretcap    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlbasopc    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlretopc    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlbasapl    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlretapl    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlbassdm    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlretsdm    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vldeirrf    AS DECIMAL                              NO-UNDO.
DEF        VAR ger_vlcretot    AS DECIMAL                              NO-UNDO.

DEF        VAR aux_nmarqcal    AS CHAR     INIT "arq/crrl048.cal"      NO-UNDO.

DEF        VAR aux_txdretor    AS DECIMAL                              NO-UNDO.
DEF        VAR aux_txjurcap    AS DECIMAL                              NO-UNDO.
DEF        VAR aux_txjurapl    AS DECIMAL                              NO-UNDO.
DEF        VAR aux_txjursdm    AS DECIMAL                              NO-UNDO.
DEF        VAR aux_dsprvdef    AS CHAR                                 NO-UNDO.
DEF        VAR aux_dtmvtolt    AS DATE                                 NO-UNDO.
DEF        VAR aux_flgimune    AS LOGICAL                              NO-UNDO.

DEF        VAR h-b1wgen0159    AS HANDLE                               NO-UNDO.

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEFINE TEMP-TABLE crawret
       FIELD cdagenci AS INT
       FIELD nrdconta AS INT
       FIELD nmprimtl AS CHAR
       FIELD vlmedcap AS DECIMAL
       FIELD vlbascap AS DECIMAL
       FIELD vlretcap AS DECIMAL
       FIELD vlbasopc AS DECIMAL
       FIELD vlretopc AS DECIMAL
       FIELD vlbasapl AS DECIMAL
       FIELD vlretapl AS DECIMAL
       FIELD vlbassdm AS DECIMAL
       FIELD vlretsdm AS DECIMAL
       FIELD vldeirrf AS DECIMAL
       FIELD vlcredit AS DECIMAL
       FIELD vlcretot AS DECIMAL
       INDEX crawret1 cdagenci nrdconta.

DEFINE TEMP-TABLE crawtot
       FIELD dsagenci AS CHAR
       FIELD qtassoci AS INT
       FIELD vlmedcap AS DECIMAL
       FIELD vlbascap AS DECIMAL
       FIELD vlretcap AS DECIMAL
       FIELD vlbasopc AS DECIMAL
       FIELD vlretopc AS DECIMAL
       FIELD vlbasapl AS DECIMAL
       FIELD vlretapl AS DECIMAL
       FIELD vlbassdm AS DECIMAL
       FIELD vlretsdm AS DECIMAL
       FIELD vldeirrf AS DECIMAL
       FIELD vlcredit AS DECIMAL
       FIELD vlcretot AS DECIMAL.

{ includes/cabrel234_2.i }
                                                                        
FORM rel_dsagenci AT  2 LABEL "PA" FORMAT "X(30)"
     aux_dsprvdef AT 38 LABEL "TIPO DE CALCULO" FORMAT "x(65)"
     WITH NO-BOX SIDE-LABELS WIDTH 234 FRAME f_pac.

FORM "PERCENTUAL:"         AT  50
     aux_txjurcap          AT  62 FORMAT "zz9.99999999"
     "%"                   AT  74
     "PERCENTUAL: 15%"     AT  76
     "PERCENTUAL:"         AT  99
     aux_txdretor          AT 111 FORMAT "zz9.99999999"
     "%"                   AT 123
     "PERCENTUAL:"         AT 132
     aux_txjurapl          AT 144 FORMAT "zz9.99999999"
     "%"                   AT 156
     "PERCENTUAL:"         AT 165 
     aux_txjursdm          AT 177 FORMAT "zz9.99999999"
     "%"                   AT 189
     SKIP(1)
     "CONTA/DV NOME"       AT   6
     "MEDIA CAPITAL"       AT  47
     "JUROS CAPITAL"       AT  62
     "IRRF"                AT  87
     "BASE OP. CREDITO"    AT  93
     "RETORNO"             AT 117
     "BASE DEP. PRZ."      AT 128
     "RETORNO"             AT 150
     "BASE DEP. VIS."      AT 161
     "RETORNO"             AT 183
     "RETORNO TOTAL"       AT 192
     "RETORNO+JUROS"       AT 207
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_label_retorno.
     
FORM crawret.nrdconta     AT   4 FORMAT "zzzz,zzz,9"
     crawret.nmprimtl     AT  15 FORMAT "x(30)"
     crawret.vlmedcap     AT  46 FORMAT "zzz,zzz,zz9.99"
     crawret.vlretcap     AT  61 FORMAT "zzz,zzz,zz9.99-"
     crawret.vldeirrf     AT  77 FORMAT "zzz,zzz,zz9.99"
     crawret.vlbasopc     AT  92 FORMAT "zz,zzz,zzz,zz9.99"
     crawret.vlretopc     AT 110 FORMAT "zzz,zzz,zz9.99"
     crawret.vlbasapl     AT 125 FORMAT "zz,zzz,zzz,zz9.99"
     crawret.vlretapl     AT 143 FORMAT "zzz,zzz,zz9.99"
     crawret.vlbassdm     AT 158 FORMAT "zz,zzz,zzz,zz9.99"
     crawret.vlretsdm     AT 176 FORMAT "zzz,zzz,zz9.99"
     crawret.vlcredit     AT 191 FORMAT "zzz,zzz,zz9.99"
     crawret.vlcretot     AT 206 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 234 DOWN FRAME f_retorno.

FORM SKIP(1)
     pac_qtassoci     AT  15 FORMAT "zzz,zz9"
     pac_vlmedcap     AT  46 FORMAT "zzz,zzz,zz9.99"
     pac_vlretcap     AT  61 FORMAT "zzz,zzz,zz9.99-"
     pac_vldeirrf     AT  77 FORMAT "zzz,zzz,zz9.99"
     pac_vlbasopc     AT  92 FORMAT "zz,zzz,zzz,zz9.99"
     pac_vlretopc     AT 110 FORMAT "zzz,zzz,zz9.99"
     pac_vlbasapl     AT 125 FORMAT "zz,zzz,zzz,zz9.99"
     pac_vlretapl     AT 143 FORMAT "zzz,zzz,zz9.99"
     pac_vlbassdm     AT 158 FORMAT "zz,zzz,zzz,zz9.99"
     pac_vlretsdm     AT 176 FORMAT "zzz,zzz,zz9.99"
     pac_vlcredit     AT 191 FORMAT "zzz,zzz,zz9.99"
     pac_vlcretot     AT 206 FORMAT "zzz,zzz,zz9.99"
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_total_pac.
   
FORM "TIPO DE CALCULO:"    AT   1 
     aux_dsprvdef          AT  18 FORMAT "x(65)"
     SKIP(1)
     "RESUMO GERAL"        AT   1
     "PERCENTUAL:"         AT  49
     aux_txjurcap          AT  61 FORMAT "zz9.99999999"
     "%"                   AT  73
     "PERCENTUAL: 15%"     AT  75
     "PERCENTUAL:"         AT  99 
     aux_txdretor          AT 111 FORMAT "zz9.99999999"
     "%"                   AT 123
     "PERCENTUAL:"         AT 132
     aux_txjurapl          AT 144 FORMAT "zz9.99999999"
     "%"                   AT 156
     "PERCENTUAL:"         AT 165 
     aux_txjursdm          AT 177 FORMAT "zz9.99999999"
     "%"                   AT 189
     SKIP(1)
     "PA"                  AT   5
     "QTD."                AT  36
     "MEDIA CAPITAL"       AT  46
     "JUROS CAPITAL"       AT  61
     "IRRF"                AT  86
     "BASE OP. CREDITO"    AT  93
     "RETORNO"             AT 117
     "BASE DEP. PRZ."      AT 128
     "RETORNO"             AT 150
     "BASE DEP. VIS."      AT 161
     "RETORNO"             AT 183
     "RETORNO TOTAL"       AT 192
     "RETORNO+JUROS"       AT 207
     WITH NO-BOX NO-LABELS WIDTH 234 FRAME f_label_total_geral.

FORM crawtot.dsagenci     AT   4 FORMAT "x(24)"
     crawtot.qtassoci     AT  33 FORMAT "zzz,zz9"
     crawtot.vlmedcap     AT  45 FORMAT "zzz,zzz,zz9.99"
     crawtot.vlretcap     AT  60 FORMAT "zzz,zzz,zz9.99-"
     crawtot.vldeirrf     AT  76 FORMAT "zzz,zzz,zz9.99"
     crawtot.vlbasopc     AT  92 FORMAT "zz,zzz,zzz,zz9.99"
     crawtot.vlretopc     AT 110 FORMAT "zzz,zzz,zz9.99"
     crawtot.vlbasapl     AT 125 FORMAT "zz,zzz,zzz,zz9.99"
     crawtot.vlretapl     AT 143 FORMAT "zzz,zzz,zz9.99"
     crawtot.vlbassdm     AT 158 FORMAT "zz,zzz,zzz,zz9.99"
     crawtot.vlretsdm     AT 176 FORMAT "zzz,zzz,zz9.99"
     crawtot.vlcredit     AT 191 FORMAT "zzz,zzz,zz9.99"
     crawtot.vlcretot     AT 206 FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS WIDTH 234 DOWN FRAME f_total_geral.
    
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.   

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         RUN controle_critica.
     END.

IF   SEARCH(aux_nmarqcal) = ?   THEN
     DO:
         glb_dscritic = "ARQUIVO NAO ENCONTRADO: " + aux_nmarqcal.
         RUN controle_critica.
         RETURN.
     END.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "EXEICMIRET"   AND
                   craptab.tpregist = 1              NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 283.
         RUN fontes/critic.p.
         RUN controle_critica.
         RETURN.
     END.
ELSE
     DO:
         ASSIGN aux_txdretor = DECIMAL(SUBSTRING(craptab.dstextab,05,12))
                aux_txjurcap = DECIMAL(SUBSTRING(craptab.dstextab,20,13))
                aux_txjurapl = DECIMAL(SUBSTRING(craptab.dstextab,33,12))
                aux_txjursdm = DECIMAL(SUBSTRING(craptab.dstextab,54,12))
                aux_dsprvdef = IF INT(SUBSTRING(dstextab,18,1)) = 1
                               THEN "*** CALCULO DEFINITIVO *** Lancamentos correspondentes realizados"
                               ELSE "*** SOMENTE PREVIA ***".
     END.

RUN sistema/generico/procedures/b1wgen0159.p PERSISTENT SET h-b1wgen0159.

     
ASSIGN aux_dtmvtolt = DATE(12, 31, YEAR(glb_dtmvtolt) - 1).
     
INPUT STREAM str_1 FROM VALUE(aux_nmarqcal) NO-ECHO.

OUTPUT STREAM str_2 TO rl/crrl412.lst PAGED PAGE-SIZE 60.
             
VIEW STREAM str_2 FRAME f_cabrel234_2.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
   SET STREAM str_1
       rel_nrdconta FORMAT "99999999"
       ^          /* Ignora o segundo campo do arquivo  */
       rel_vlmedcap FORMAT "999999999999.99-"
       rel_vlbascap FORMAT "999999999999.99-"
       rel_vlretcap FORMAT "999999999999.99-"
       rel_vlbasepr FORMAT "999999999999.99-"
       rel_vlretepr FORMAT "999999999999.99-"
       rel_vlbasdsc FORMAT "999999999999.99-"
       rel_vlretdsc FORMAT "999999999999.99-"
       rel_vlbastit FORMAT "999999999999.99-"
       rel_vlrettit FORMAT "999999999999.99-"
       rel_vlbasapl FORMAT "999999999999.99-"
       rel_vlretapl FORMAT "999999999999.99-"
       rel_vlbassdm FORMAT "999999999999.99-"
       rel_vlretsdm FORMAT "999999999999.99-"
       rel_vlcredit FORMAT "999999999999.99-"
       rel_vlcretot FORMAT "999999999999.99-"
       rel_vldeirrf FORMAT "999999999999.99-"
       WITH FRAME f_integra.

   IF   rel_nrdconta = 99999999   THEN
        LEAVE.

   IF   rel_vlbascap = 0   AND
        rel_vlretcap = 0   AND
        rel_vlbasepr = 0   AND
        rel_vlretepr = 0   AND
        rel_vlbasdsc = 0   AND
        rel_vlretdsc = 0   AND
        rel_vlbastit = 0   AND
        rel_vlrettit = 0   AND
        rel_vlbasapl = 0   AND
        rel_vlretapl = 0   AND
        rel_vlbassdm = 0   AND
        rel_vlretsdm = 0   AND
        rel_vldeirrf = 0   AND
        rel_vlcredit = 0   AND 
        rel_vlcretot = 0   THEN
        NEXT.

   FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND
                      crapass.nrdconta = rel_nrdconta   NO-LOCK NO-ERROR.
   
   RUN verifica-imunidade-tributaria 
                          IN h-b1wgen0159(
                               INPUT crapass.cdcooper,
                               INPUT crapass.nrdconta,
                               INPUT aux_dtmvtolt,
                               INPUT FALSE,
                               INPUT 6,
                               INPUT 0,
                               OUTPUT aux_flgimune,
                               OUTPUT TABLE tt-erro).

   IF   aux_flgimune THEN
        rel_vldeirrf = 0.
   
   CREATE crawret.
   ASSIGN crawret.nrdconta = rel_nrdconta
          crawret.cdagenci = IF AVAILABLE crapass
                                THEN crapass.cdagenci
                                ELSE 1
          crawret.nmprimtl = IF AVAILABLE crapass
                                THEN crapass.nmprimtl
                                ELSE "NAO CADASTRADO"
          crawret.vlmedcap = rel_vlmedcap
          crawret.vlbascap = rel_vlbascap
          crawret.vlretcap = rel_vlretcap
          crawret.vlbasopc = rel_vlbasepr + rel_vlbasdsc + rel_vlbastit
          crawret.vlretopc = rel_vlretepr + rel_vlretdsc + rel_vlrettit
          crawret.vlbasapl = rel_vlbasapl
          crawret.vlretapl = rel_vlretapl
          crawret.vlbassdm = rel_vlbassdm
          crawret.vlretsdm = rel_vlretsdm
          crawret.vldeirrf = rel_vldeirrf
          crawret.vlcredit = rel_vlcredit
          crawret.vlcretot = rel_vlcretot.

END.  /*  Fim do DO WHILE TRUE  */

IF   VALID-HANDLE(h-b1wgen0159)   THEN
     DELETE PROCEDURE h-b1wgen0159.


INPUT STREAM str_1 CLOSE.

FOR EACH crawret NO-LOCK BREAK BY crawret.cdagenci
                                  BY crawret.nrdconta:

    IF   FIRST-OF(crawret.cdagenci)   THEN
         DO:
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                crapage.cdagenci = crawret.cdagenci
                                NO-LOCK NO-ERROR.
             
             IF   NOT AVAILABLE crapage   THEN
                  rel_dsagenci = STRING(crawret.cdagenci,"999") +
                                 "-NAO CADASTRADO".
             ELSE
                  rel_dsagenci = STRING(crawret.cdagenci,"999") + "-" +
                                 crapage.nmresage.
                                 
             ASSIGN pac_qtassoci = 0
                    pac_vlmedcap = 0
                    pac_vlbascap = 0
                    pac_vlretcap = 0
                    pac_vlbasopc = 0
                    pac_vlretopc = 0
                    pac_vlbasapl = 0
                    pac_vlretapl = 0
                    pac_vlbassdm = 0
                    pac_vlretsdm = 0
                    pac_vldeirrf = 0
                    pac_vlcredit = 0
                    pac_vlcretot = 0.
             
             PAGE STREAM str_2.

             DISPLAY STREAM str_2
                     rel_dsagenci
                     aux_dsprvdef WITH FRAME f_pac.
                     
             DISPLAY STREAM str_2 aux_txjurcap aux_txdretor 
                                  aux_txjurapl aux_txjursdm 
                                  WITH FRAME f_label_retorno.

         END.
         
    DISPLAY STREAM str_2
            crawret.nrdconta   crawret.nmprimtl
            crawret.vlmedcap   
            crawret.vlretcap   crawret.vlbasopc
            crawret.vlretopc   crawret.vlbasapl
            crawret.vlretapl   crawret.vlcredit
            crawret.vlbassdm   crawret.vlretsdm
            crawret.vldeirrf   crawret.vlcretot
            WITH FRAME f_retorno.
            
    DOWN STREAM str_2 WITH FRAME f_retorno. 

    IF   LINE-COUNTER(str_2) > PAGE-SIZE(str_2)  THEN
         DO:
             PAGE STREAM str_2.

             DISPLAY STREAM str_2
                     rel_dsagenci 
                     aux_dsprvdef WITH FRAME f_pac.

             DISPLAY STREAM str_2 aux_txjurcap aux_txdretor 
                                  aux_txjurapl aux_txjursdm 
                                  WITH FRAME f_label_retorno.

         END.
         
    ASSIGN pac_qtassoci = pac_qtassoci + 1
           pac_vlmedcap = pac_vlmedcap + crawret.vlmedcap
           pac_vlbascap = pac_vlbascap + crawret.vlbascap
           pac_vlretcap = pac_vlretcap + crawret.vlretcap
           pac_vlbasopc = pac_vlbasopc + crawret.vlbasopc
           pac_vlretopc = pac_vlretopc + crawret.vlretopc
           pac_vlbasapl = pac_vlbasapl + crawret.vlbasapl
           pac_vlretapl = pac_vlretapl + crawret.vlretapl
           pac_vlbassdm = pac_vlbassdm + crawret.vlbassdm
           pac_vlretsdm = pac_vlretsdm + crawret.vlretsdm
           pac_vldeirrf = pac_vldeirrf + crawret.vldeirrf
           pac_vlcredit = pac_vlcredit + crawret.vlcredit
           pac_vlcretot = pac_vlcretot + crawret.vlcretot.
         
    IF   LAST-OF(crawret.cdagenci)   THEN
         DO:
             IF   LINE-COUNTER(str_2) > (PAGE-SIZE(str_2) - 3)   THEN
                  DO:
                      PAGE STREAM str_2.

                      DISPLAY STREAM str_2
                              rel_dsagenci 
                              aux_dsprvdef 
                              WITH FRAME f_pac.

                      DISPLAY STREAM str_2 aux_txjurcap aux_txdretor 
                                           aux_txjurapl aux_txjursdm 
                                           WITH FRAME f_label_retorno.

                  END.
             
             DISPLAY STREAM str_2
                     pac_qtassoci   pac_vlmedcap
                     pac_vlretcap   pac_vlbasopc
                     pac_vlretopc   pac_vlbasapl
                     pac_vlretapl   pac_vlcredit
                     pac_vlbassdm   pac_vlretsdm
                     pac_vldeirrf   pac_vlcretot
                     WITH FRAME f_total_pac.
                      
             CREATE crawtot.
             ASSIGN crawtot.dsagenci = rel_dsagenci
                    crawtot.qtassoci = pac_qtassoci
                    crawtot.vlmedcap = pac_vlmedcap
                    crawtot.vlbascap = pac_vlbascap
                    crawtot.vlretcap = pac_vlretcap
                    crawtot.vlbasopc = pac_vlbasopc
                    crawtot.vlretopc = pac_vlretopc
                    crawtot.vlbasapl = pac_vlbasapl
                    crawtot.vlretapl = pac_vlretapl
                    crawtot.vlbassdm = pac_vlbassdm
                    crawtot.vlretsdm = pac_vlretsdm
                    crawtot.vldeirrf = pac_vldeirrf
                    crawtot.vlcredit = pac_vlcredit
                    crawtot.vlcretot = pac_vlcretot.
         END.
                                  
END.  /*  Fim do FOR EACH crawret  */


/*  Resumo geral ............................................................ */

PAGE STREAM str_2.
  
DISPLAY STREAM str_2 aux_dsprvdef
                     aux_txjurcap aux_txdretor 
                     aux_txjurapl aux_txjursdm 
                     WITH FRAME f_label_total_geral.

FOR EACH crawtot NO-LOCK BY crawtot.dsagenci:

    DISPLAY STREAM str_2
            crawtot.dsagenci   crawtot.qtassoci
            crawtot.vlmedcap   crawtot.vlretcap
            crawtot.vlbasopc   crawtot.vlretopc
            crawtot.vlbasapl   crawtot.vlretapl
            crawtot.vlcredit   crawtot.vldeirrf
            crawtot.vlbassdm   crawtot.vlretsdm
            crawtot.vlcretot
            WITH FRAME f_total_geral.
    
    DOWN STREAM str_2 WITH FRAME f_total_geral.

    ASSIGN tot_qtassoci = tot_qtassoci + crawtot.qtassoci
           tot_vlmedcap = tot_vlmedcap + crawtot.vlmedcap
           tot_vlbascap = tot_vlbascap + crawtot.vlbascap
           tot_vlretcap = tot_vlretcap + crawtot.vlretcap
           tot_vlbasopc = tot_vlbasopc + crawtot.vlbasopc
           tot_vlretopc = tot_vlretopc + crawtot.vlretopc
           tot_vlbasapl = tot_vlbasapl + crawtot.vlbasapl
           tot_vlretapl = tot_vlretapl + crawtot.vlretapl
           tot_vlbassdm = tot_vlbassdm + crawtot.vlbassdm
           tot_vlretsdm = tot_vlretsdm + crawtot.vlretsdm
           tot_vldeirrf = tot_vldeirrf + crawtot.vldeirrf
           tot_vlcredit = tot_vlcredit + crawtot.vlcredit
           tot_vlcretot = tot_vlcretot + crawtot.vlcretot.

END.  /*  Fim do FOR EACH  */

DOWN STREAM str_2 2 WITH FRAME f_total_geral.

DISPLAY STREAM str_2
        tot_qtassoci @ crawtot.qtassoci
        tot_vlmedcap @ crawtot.vlmedcap
        tot_vlretcap @ crawtot.vlretcap
        tot_vlbasopc @ crawtot.vlbasopc 
        tot_vlretopc @ crawtot.vlretopc
        tot_vlbasapl @ crawtot.vlbasapl  
        tot_vlretapl @ crawtot.vlretapl
        tot_vlbassdm @ crawtot.vlbassdm  
        tot_vlretsdm @ crawtot.vlretsdm
        tot_vldeirrf @ crawtot.vldeirrf
        tot_vlcredit @ crawtot.vlcredit
        tot_vlcretot @ crawtot.vlcretot
        WITH FRAME f_total_geral.

DOWN STREAM str_2 WITH FRAME f_total_geral.

OUTPUT STREAM str_2 CLOSE.

/* Jogar para o /micros/COOP/contab se for previa */
IF  glb_inproces = 1  THEN 
    UNIX SILENT VALUE("ux2dos rl/crrl412.lst > /micros/" +
                      crapcop.dsdircop + "/contab/crrl412.txt").     

ASSIGN glb_nmformul = "234dh"     
       glb_nrcopias = 1
       glb_nmarqimp = "rl/crrl412.lst".
                
RUN fontes/imprim.p.

PROCEDURE controle_critica:

   IF glb_inproces <> 1 THEN
        DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" + glb_dscritic +
                               " >> log/proc_batch.log").
        END.
   ELSE DO:
             MESSAGE glb_dscritic.
             PAUSE.
        END.

END PROCEDURE.
                        
/* .......................................................................... */
