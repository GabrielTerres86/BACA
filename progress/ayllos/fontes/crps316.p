/* ..........................................................................

   Programa: Fontes/crps316.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior.
   Data    : Agosto/2001                        Ultima atualizacao: 09/01/2017

   Dados referentes ao programa:

   Frequencia: Mensal - Roda no primeiro dia util de cada mes.
   Objetivo  : Atende a solicitacao 039.
               Ordem na solicitacao: 5.
               Listar os emprestimos por finalidade.
               Emite relatorio 268.

   Alteracoes: 29/09/2005 - Alterado para ler tbm codigo da cooperativa na
                            tabela crapacc (Diego).
                            
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder             
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).      

               09/01/2017 - #587076 Correcao dos formats dos campos 
                            aux_slddeved e tot_slddeved para permitirem 
                            valores negativos (Carlos)
...........................................................................*/

DEF STREAM str_1. /* Para os emprestimos listados. */

DEF    VAR rel_nmempres AS CHAR    FORMAT "x(15)"                      NO-UNDO.
DEF    VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5             NO-UNDO.

DEF    VAR rel_nrmodulo AS INT     FORMAT "9"                          NO-UNDO.
DEF    VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ",
                                         "CAPITAL        ",
                                         "EMPRESTIMOS    ",
                                         "DIGITACAO      ",
                                         "GENERICO       "]            NO-UNDO.

DEF    VAR aux_nmarqimp AS CHAR    FORMAT "x(20)"                      NO-UNDO.

DEF    VAR rel_nmmesref AS CHAR    FORMAT "x(30)"                      NO-UNDO.

DEF    VAR aux_nmmesref AS CHAR    FORMAT "x(10)" EXTENT 12
                                   INIT ["JANEIRO/","FEVEREIRO/",
                                         "MARCO/","ABRIL/",
                                         "MAIO/","JUNHO/",
                                         "JULHO/","AGOSTO/",
                                         "SETEMBRO/","OUTUBRO/",
                                         "NOVEMBRO/","DEZEMBRO/"]      NO-UNDO.

DEF    VAR aux_cdagenci AS INT     FORMAT "zz9"                        NO-UNDO.
DEF    VAR aux_nmresage AS char    FORMAT "x(30)"                      NO-UNDO.

DEF    VAR rel_dslanmto AS CHAR    FORMAT "x(30)"                      NO-UNDO.
DEF    VAR aux_qtemprst AS INT     FORMAT "zzz,zz9"            INIT 0  NO-UNDO.
DEF    VAR aux_vlemprst AS DECIMAL FORMAT "z,zzz,zzz,zz9.99"   INIT 0  NO-UNDO.
DEF    VAR aux_qtddeved AS INT     FORMAT "zzz,zz9"            INIT 0  NO-UNDO.
DEF    VAR aux_slddeved AS DECIMAL FORMAT "z,zzz,zzz,zz9.99-"  INIT 0  NO-UNDO.

DEF    VAR tot_qtemprst AS INT     FORMAT "zzz,zz9"            INIT 0  NO-UNDO.
DEF    VAR tot_vlemprst AS DECIMAL FORMAT "z,zzz,zzz,zz9.99"   INIT 0  NO-UNDO.
DEF    VAR tot_qtddeved AS INT     FORMAT "zzz,zz9"            INIT 0  NO-UNDO.
DEF    VAR tot_slddeved AS DECIMAL FORMAT "z,zzz,zzz,zz9.99-"  INIT 0  NO-UNDO.

{ includes/var_batch.i "NEW" }

ASSIGN glb_cdprogra = "crps316"
       aux_nmarqimp = "rl/crrl268.lst"
       glb_cdempres = 11.

RUN fontes/iniprg.p.

IF glb_cdcritic > 0 THEN
   QUIT.

FORM SKIP(1)
     rel_nmmesref AT 56 LABEL "MES DE REFERENCIA"
     WITH NO-BOX NO-LABELS SIDE-LABELS WIDTH 132 FRAME f_mesref.
     
FORM SKIP(1)
     "PA: "               AT 06
     aux_cdagenci         AT 10
     " - "                AT 13
     aux_nmresage         AT 16
     "EMPRESTADO NO MES"  AT 51
     "ACUMULADO"          AT 93
     SKIP(1)
     "FINALIDADE"         AT 16
     "CONTRATOS"          AT 51
     "VALOR EMPRESTADO"   AT 67
     "CONTRATOS"          AT 93
     "SALDO DEVEDOR"      AT 112
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_agenci.

FORM rel_dslanmto         AT 16  
     aux_qtemprst         AT 53  
     aux_vlemprst         AT 67  
     aux_qtddeved         AT 95  
     aux_slddeved         AT 109 
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_dados.

FORM "-------       ----------------            -------       ----------------"
     AT 53
     "T O T A I S ==>"    AT  35
     tot_qtemprst         AT  53
     tot_vlemprst         AT  67
     tot_qtddeved         AT  95
     tot_slddeved         AT 109
     WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_total.

{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

rel_nmmesref = aux_nmmesref[MONTH(glb_dtmvtolt - DAY(glb_dtmvtolt))] +
                      STRING(YEAR(glb_dtmvtolt),"9999").

DISPLAY STREAM str_1 rel_nmmesref WITH FRAME f_mesref.
                      
FOR EACH crapacc WHERE crapacc.cdcooper = glb_cdcooper                       AND
                       crapacc.dtrefere = (glb_dtmvtolt - DAY(glb_dtmvtolt)) AND
                       crapacc.cdempres = 0                                  AND
                      (crapacc.tpregist = 4 OR crapacc.tpregist = 5)         
                       BREAK BY crapacc.cdagenci 
                                BY crapacc.cdlanmto:

    IF   FIRST-OF (crapacc.cdagenci) THEN
         DO:
             FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                crapage.cdagenci = crapacc.cdagenci
                                NO-LOCK NO-ERROR.
    
             IF   AVAILABLE crapage THEN
                  ASSIGN aux_cdagenci = crapacc.cdagenci
                         aux_nmresage = crapage.nmresage. 
             ELSE
                  ASSIGN aux_cdagenci = 0
                         aux_nmresage = "TOTAL GERAL".
         
             DISPLAY STREAM str_1 aux_cdagenci
                                  aux_nmresage WITH FRAME f_agenci.
             ASSIGN aux_qtemprst = 0
                    aux_vlemprst = 0
                    tot_qtemprst = 0
                    tot_vlemprst = 0.
         END.

    IF   crapacc.tpregist = 4    THEN
         IF   crapacc.cdlanmto = 0 THEN
              ASSIGN tot_qtemprst = crapacc.qtlanmto
                     tot_vlemprst = crapacc.vllanmto.
         ELSE
              ASSIGN aux_qtemprst = crapacc.qtlanmto
                     aux_vlemprst = crapacc.vllanmto.
    ELSE
         IF   crapacc.tpregist = 5 THEN
              IF   crapacc.cdlanmto = 0 THEN
                   ASSIGN tot_qtddeved = crapacc.qtlanmto
                          tot_slddeved = crapacc.vllanmto.
              ELSE
                   ASSIGN aux_qtddeved = crapacc.qtlanmto
                          aux_slddeved = crapacc.vllanmto.
                          
    IF   LAST-OF (crapacc.cdlanmto) THEN
         DO:
             FIND crapfin WHERE crapfin.cdcooper = glb_cdcooper     AND
                                crapfin.cdfinemp = crapacc.cdlanmto 
                                NO-LOCK NO-ERROR.
    
             IF   AVAILABLE crapfin THEN
                  rel_dslanmto = (STRING(crapacc.cdlanmto, "999") + 
                                 " - " + crapfin.dsfinemp).
             ELSE
                  rel_dslanmto = (STRING(crapacc.cdlanmto, "999") + 
                                 " - NAO CADASTRADO").
              
             IF   aux_qtemprst <> 0  OR
                  aux_qtddeved <> 0  THEN
                  DO:
                      DISPLAY STREAM str_1 rel_dslanmto aux_qtemprst
                                           aux_vlemprst aux_qtddeved 
                                           aux_slddeved WITH FRAME f_dados.
   
                      DOWN STREAM str_1 WITH FRAME f_dados.
                  END.
             ASSIGN aux_qtemprst = 0
                    aux_vlemprst = 0
                    aux_qtddeved = 0
                    aux_slddeved = 0.
         END.

    IF   LAST-OF (crapacc.cdagenci) THEN
         DO:
             DISPLAY STREAM str_1 tot_qtemprst tot_vlemprst
                                  tot_qtddeved tot_slddeved WITH FRAME f_total.
 
             ASSIGN  tot_qtemprst = 0
                     tot_vlemprst = 0
                     tot_qtddeved = 0
                     tot_slddeved = 0.
         END.

END. /* Fim do FOR EACH.  */

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132dm"
       glb_nmarqimp = "rl/crrl268.lst".

RUN fontes/imprim.p.

RUN fontes/fimprg.p.
/* .......................................................................... */

