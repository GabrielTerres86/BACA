/* ..........................................................................

   Programa: Fontes/crps300.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo.       
   Data    : Dezembro/2000.                  Ultima atualizacao: 07/12/2011

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 002 (diario de relatorios)
               Relatorio : 252 (132 colunas - 1 via)
               Ordem do programa na solicitacao : 4
               Emite: Listar as contra-ordens diariamente.

   Alteracoes: 10/11/2005 - Tratar campo cdcooper na leitura da tabela 
                            crapcor (Edson).
                                                    
               05/01/2006 - Cancelar impressao para a Coope 1 (Magui).

               16/02/2006 - Unificaao dos Bancos - SQLWorks - Fernando. 

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               03/03/2010 - Alteracao Historico (Gati)
               
               07/12/2011 - Sustação provisória (André R./Supero).
............................................................................ */

DEF       STREAM str_1.     /* Para relatorio das contra-ordens geradas  */

{ includes/var_batch.i "NEW" }
        
DEF     VAR  aux_cdagenci AS INT                                       NO-UNDO.
DEF     VAR  rel_nmempres AS CHAR  FORMAT "x(15)"                      NO-UNDO.
DEF     VAR  rel_nmrelato AS CHAR  FORMAT "x(40)" EXTENT 5             NO-UNDO.
DEF     VAR  rel_nrmodulo AS INT   FORMAT "9"                          NO-UNDO.
DEF     VAR  rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5
                                   INIT ["DEP. A VISTA   ","CAPITAL        ",
                                         "EMPRESTIMOS    ","DIGITACAO      ",
                                         "GENERICO       "]            NO-UNDO.
DEF     VAR  aux_imprimir AS LOGICAL                                   NO-UNDO.
DEF     VAR  aux_nrchqini AS INT                                       NO-UNDO.
DEF     VAR  aux_nrchqfim AS INT                                       NO-UNDO.
DEF     VAR  rel_nrcpfcgc AS CHAR                                      NO-UNDO.
DEF     VAR  rel_nrtalchq AS INT                                       NO-UNDO.
DEF     VAR  rel_nrdctabb AS INT                                       NO-UNDO.
DEF     VAR  rel_nrcheque AS CHAR                                      NO-UNDO.
DEF     VAR  rel_nrdconta AS INT                                       NO-UNDO.
DEF     VAR  rel_cdhistor AS INT                                       NO-UNDO.

DEFINE TEMP-TABLE tt-hist
    FIELD codigo       AS INTEGER
    FIELD rel_dshistor AS CHARACTER FORMAT "x(30)".

DEFINE BUFFER b-tt-hist FOR tt-hist.

ASSIGN glb_cdprogra = "crps300"
       glb_nmarqimp = "rl/crrl252.lst".
       
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

FORM SKIP 
     "  CONTA/DV PA CONTA BASE  TALAO CHEQUES"    
     "HISTORICO                            NOME"   AT 56
     SKIP                                                                 
     WITH FRAME f_titulo NO-BOX NO-LABELS PAGE-TOP WIDTH 132.
               
FORM SKIP(1)
     rel_nrdconta                AT 01   FORMAT "zzzz,zz9,9"             
     crapass.cdagenci            AT 12   FORMAT "zz9"
     rel_nrdctabb                AT 16   FORMAT "zzzz,zz9,9"
     rel_nrtalchq                AT 27   FORMAT "zz,zz9"
     rel_nrcheque                AT 34   FORMAT "x(21)"
     rel_cdhistor                AT 56   FORMAT "9999"
     b-tt-hist.rel_dshistor      AT 61   FORMAT "x(30)"
     crapass.nmprimtl            AT 93   FORMAT "x(40)"
     SKIP(1)
     WITH FRAME f_linha1 NO-BOX NO-LABELS WIDTH 132.
                 
FORM "CPF/CNPJ:"                       AT 12
     rel_nrcpfcgc                      AT 22  FORMAT "x(20)" 
     "REGISTRO BANCO: ____/____/____"  AT 44
     "DOCUMENTACAO: ____/____/____"    AT 79
     "VISTO: _________________"        AT 109
     SKIP(1)
     WITH FRAME f_linha2 NO-BOX NO-LABELS WIDTH 132. 

{ includes/cabrel132_1.i }               /* Monta cabecalho do relatorio */

OUTPUT STREAM str_1 TO rl/crrl252.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.
VIEW STREAM str_1 FRAME f_titulo.
                                                             
ASSIGN  rel_nrdconta = 0        rel_nrtalchq = 0         rel_nrdctabb = 0  
        rel_nrcheque = " "      rel_cdhistor = 0         aux_nrchqini = 0        
        aux_nrchqfim = 0        aux_imprimir = FALSE.

/*   Le cadastro de contra-ordens  */

EMPTY TEMP-TABLE tt-hist.
FOR EACH crapcor WHERE crapcor.cdcooper = glb_cdcooper   AND
                       crapcor.dtemscor = glb_dtmvtolt   AND
                       crapcor.flgativo = TRUE
                               BREAK BY crapcor.dtemscor
                                        BY crapcor.nrdconta
                                           BY crapcor.nrtalchq
                                              BY crapcor.cdhistor 
                                                 BY crapcor.nrcheque:
 
    FIND FIRST tt-hist NO-LOCK
         WHERE tt-hist.codigo = crapcor.cdhistor NO-ERROR.

    IF   (rel_nrdconta <> 0)  THEN      
         DO:
             IF   (rel_nrdconta <> crapcor.nrdconta)     OR
                  (rel_nrdctabb <> crapcor.nrdctabb)     OR
                  (rel_nrtalchq <> crapcor.nrtalchq)     OR
                  (rel_cdhistor <> crapcor.cdhistor)     THEN
                  aux_imprimir = TRUE.
             ELSE     
                  DO:
                      IF   (INTEGER(SUBSTRING(STRING
                                   (aux_nrchqfim,"9999999"),1,6))) <>
                          ((INTEGER(SUBSTRING(STRING
                                   (crapcor.nrcheque,"9999999"),1,6))) - 1) THEN                             aux_imprimir = TRUE.
                      ELSE
                            aux_imprimir = FALSE.

                  END.                                                   
         END.
 
    IF   aux_imprimir THEN        
         DO:
             FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                                crapass.nrdconta = rel_nrdconta 
                                NO-LOCK NO-ERROR.
    
             IF   NOT AVAILABLE crapass   THEN
                  DO:
                      glb_cdcritic = 009.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") 
                                        + " - " + glb_cdprogra + "' --> '" + 
                                        glb_dscritic + "Conta " + 
                                        STRING(crapcor.nrdconta) +
                                        " >> log/proc_batch.log").
                      QUIT.
                  END.

             IF   aux_nrchqfim <> aux_nrchqini THEN
                  rel_nrcheque = STRING(aux_nrchqini, "zzz,zz9,9") + " A " + 
                                 STRING(aux_nrchqfim, "zzz,zz9,9").
             ELSE 
                  rel_nrcheque = STRING(aux_nrchqini, "zzz,zz9,9").
                                              
             FIND FIRST b-tt-hist NO-LOCK
                  WHERE b-tt-hist.codigo = rel_cdhistor NO-ERROR.

             CLEAR FRAME f_linha1.
             DISPLAY STREAM str_1  rel_nrdconta                crapass.cdagenci
                                   rel_nrdctabb                rel_nrtalchq
                                   rel_nrcheque                rel_cdhistor
                                   b-tt-hist.rel_dshistor      crapass.nmprimtl 
                                   WITH FRAME f_linha1. 
             DOWN STREAM str_1 WITH FRAME f_linha1. 
                       
             IF   LENGTH(STRING(crapass.nrcpfcgc)) = 11 OR
                  LENGTH(STRING(crapass.nrcpfcgc)) = 10 OR
                  LENGTH(STRING(crapass.nrcpfcgc)) =  9 OR
                  LENGTH(STRING(crapass.nrcpfcgc)) =  8 THEN     
                  ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                         rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
             ELSE
                 ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                       rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
      
             CLEAR FRAME f_linha2.
             DISPLAY STREAM str_1    rel_nrcpfcgc     WITH FRAME f_linha2. 
             DOWN STREAM str_1 WITH FRAME f_linha2.            
         
             ASSIGN  rel_nrdconta = 0    rel_nrtalchq = 0    rel_nrdctabb = 0
                     rel_nrcheque = " "  aux_nrchqini = 0    aux_nrchqfim = 0
                     rel_cdhistor = 0    aux_imprimir = FALSE.
         END.  /*   Fim  do IF  */
         
    /*   Le o arquivo de historico   */
    IF NOT AVAIL tt-hist THEN
         DO:
             FIND craphis NO-LOCK 
                  WHERE craphis.cdcooper = crapcor.cdcooper 
                    AND craphis.cdhistor = crapcor.cdhistor NO-ERROR.               
             IF   NOT AVAILABLE craphis   THEN
                  DO:
                      glb_cdcritic = 526.
                      RUN fontes/critic.p.
                      UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") 
                                        + " - " + glb_cdprogra + "' --> '" + 
                                       glb_dscritic + " >> log/proc_batch.log").
                      QUIT.
                  END.
    
             CREATE tt-hist.
             ASSIGN tt-hist.codigo       = craphis.cdhistor
                    tt-hist.rel_dshistor = craphis.dshistor.

         END.
        
    ASSIGN rel_nrdconta = crapcor.nrdconta
           rel_nrtalchq = crapcor.nrtalchq
           rel_cdhistor = crapcor.cdhistor
           rel_nrdctabb = crapcor.nrdctabb. 
           
    IF   aux_nrchqini = 0 THEN       
         ASSIGN aux_nrchqini = crapcor.nrcheque 
                aux_nrchqfim = crapcor.nrcheque.
    ELSE
         aux_nrchqfim = crapcor.nrcheque.
    
    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         PAGE STREAM str_1.
        
END.  /*  Fim do FOR EACH  --  Leitura do cadastro de contra-ordens  */

IF   (rel_nrdconta <> 0) THEN
     DO:
         FIND crapass WHERE  crapass.cdcooper = glb_cdcooper  AND 
                             crapass.nrdconta = rel_nrdconta  NO-LOCK NO-ERROR.
    
         IF   NOT AVAILABLE crapass   THEN
              DO:
                  glb_cdcritic = 009.
                  RUN fontes/critic.p.
                  UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") 
                                    + " - " + glb_cdprogra + "' --> '" + 
                                    glb_dscritic + "Conta " + 
                                    STRING(crapcor.nrdconta) +
                                    " >> log/proc_batch.log").
                  QUIT.
              END.

         IF   aux_nrchqfim <> aux_nrchqini THEN
              rel_nrcheque = STRING(aux_nrchqini, "zzz,zz9,9") + " A " + 
                             STRING(aux_nrchqfim, "zzz,zz9,9").
         ELSE
              rel_nrcheque = STRING(aux_nrchqini, "zzz,zz9,9").
              
         FIND FIRST b-tt-hist NO-LOCK
              WHERE b-tt-hist.codigo = rel_cdhistor NO-ERROR.

         CLEAR FRAME f_linha1.
         DISPLAY STREAM str_1  rel_nrdconta                crapass.cdagenci
                               rel_nrdctabb                rel_nrtalchq
                               rel_nrcheque                rel_cdhistor
                               b-tt-hist.rel_dshistor      crapass.nmprimtl 
                               WITH FRAME f_linha1. 
         DOWN STREAM str_1 WITH FRAME f_linha1. 
                       
         IF   LENGTH(STRING(crapass.nrcpfcgc)) = 11 OR
              LENGTH(STRING(crapass.nrcpfcgc)) = 10 OR
              LENGTH(STRING(crapass.nrcpfcgc)) =  9 OR
              LENGTH(STRING(crapass.nrcpfcgc)) =  8 THEN
              ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                     rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
         ELSE
              ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                     rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
      
         CLEAR FRAME f_linha2.
         DISPLAY STREAM str_1   rel_nrcpfcgc   WITH FRAME f_linha2. 
         DOWN STREAM str_1 WITH FRAME f_linha2.            
     END.  /*  fim do IF */

OUTPUT STREAM str_1 CLOSE.
glb_nmformul = "132dm".  /* Usar duplex marginado */

IF  rel_nrdconta > 0    AND
    glb_cdcooper <> 1   THEN
    RUN fontes/imprim.p.

RUN fontes/fimprg.p.
/* ....................................................................... */



