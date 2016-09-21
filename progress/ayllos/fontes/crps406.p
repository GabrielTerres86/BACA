/* ..........................................................................

   Programa: Fontes/crps406.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Setembro/2004                       Ultima atualizacao: 12/12/2014

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 86.
               Emitir relatorio das contra-ordens (inclusao e baixa) para o
               Banco do Brasil (371).
   
   Alteracao : 24/01/2005 - Alteracao do relatorio para um formato de carta
                            a ser enviado ao B.B. (Evandro)

               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               10/11/2005 - Tratar campo cdcooper na leitura da tabela
                            crapcor (Edson).
                            
               20/01/2006 - Alterado para usar "dtmvtolt" p/ listar (Evandro).

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               22/03/2006 - Alterado para nao imprimir relatorio para
                            Viacredi, somente mandar e-mail (Diego).
                            
               28/05/2007 - Retirado a vinculacao da execucao do imprim
                            ao codigo da cooperativa(Guilherme).
                            
               20/09/2007 - Enviar crrl371 para cobranca@viacredi.coop.br e
                            convenios@viacredi.coop.br (Guilherme).
                                      
               11/02/2008 - Alterado para somente listar contra-ordens do Banco
                            do Brasil (Elton).         
                                          
               27/02/2008 - Enviar crrl371 somente para 
                            controle@viacredi.com.br (Gabriel). 
                                  
               18/03/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               28/10/2008 - Alterar envio de e-mail do rel 371 para
                            credito@viacredi.coop.br e sara@viacredi.coop.br
                            (Gabriel).
               
               11/03/2009 - Ajustado para mostrar todos os cheques com
                            cancelamento de contra-ordens de uma determinada
                            conta (Elton).             

               13/07/2009 - Inicializar varialvel aux_nrctaant nas procedures
                            de inclusao e exclusao (David).
                            
               08/07/2010 - Foi retirado o envio por e-mail do rel 371. 
                            (Adriano). 
                         
               07/12/2011 - Sustação provisória (André R./Supero).     
               
               19/10/2012 - Tratamento campo nmrescop "x(20)" (Diego).
                                  
               12/12/2014 - Alterado historico 815 por 817 na alinea 21 e 
                            incluido o historico 817 na alinea 20 (Lucas R. #177748)
............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de contra-ordens  */

{ includes/var_batch.i "NEW" }

DEF   VAR b1wgen0011   AS HANDLE                                     NO-UNDO.

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.
DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_nrdctabb AS INT                                   NO-UNDO.
DEF        VAR rel_nrcheque AS CHAR                                  NO-UNDO.
DEF        VAR rel_nrcpfcgc AS CHAR       FORMAT "x(18)"             NO-UNDO.
DEF        VAR rel_preenchi AS LOGICAL    FORMAT "     Sim/     Nao" NO-UNDO.
DEF        VAR rel_cdalinea AS INT                                   NO-UNDO.
DEF        VAR rel_dsmvtolt AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR rel_mmmvtolt AS CHAR    FORMAT "x(17)"  EXTENT 12 
                                    INIT["DE  JANEIRO  DE","DE FEVEREIRO DE",
                                         "DE   MARCO   DE","DE   ABRIL   DE",
                                         "DE   MAIO    DE","DE   JUNHO   DE",
                                         "DE   JULHO   DE","DE   AGOSTO  DE",
                                         "DE  SETEMBRO DE","DE  OUTUBRO  DE",
                                         "DE  NOVEMBRO DE","DE  DEZEMBRO DE"]
                                                                     NO-UNDO.

DEF        VAR aux_nrchqfim AS INT                                   NO-UNDO.
DEF        VAR aux_nrctaant AS INT                                   NO-UNDO.

/* variaveis da procedure p_divinome */
DEF        VAR aux_qtpalavr AS INTE                                  NO-UNDO.
DEF        VAR rel_nmressbr AS CHAR    EXTENT 2 FORMAT "x(60)"       NO-UNDO.
DEF        VAR aux_contapal AS INTE                                  NO-UNDO.


DEF        VAR aux_nmarqimp AS CHAR    INIT "rl/crrl371.lst"         NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.

DEF BUFFER crabcor FOR crapcor.
DEF BUFFER crabrej FOR craprej.

DEF TEMP-TABLE cratrej          
         FIELD nrdctabb LIKE craprej.nrdctabb
         FIELD nrcheque AS   CHAR.

FORM SKIP(8)
     rel_dsmvtolt
     SKIP(3)
     "AO"
     SKIP
     "BANCO DO BRASIL"
     SKIP
     crapcop.nmcidade FORMAT "x(13)"
     " - "
     crapcop.cdufdcop
     SKIP(3)
     "Solicitamos registrar Contra Ordens dos seguintes cheques:"
     SKIP(3)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_label_contra.

FORM rel_nrdctabb       FORMAT "zzzz,zzz,9" LABEL "Conta"
     rel_nrcheque       FORMAT "x(21)"      LABEL "Nro. dos Cheques"
     rel_cdalinea       FORMAT "99"         LABEL "Alinea"
     rel_nrcpfcgc       FORMAT "x(18)"      LABEL "CPF/CNPJ"
     rel_preenchi                           LABEL "Ch.Preenchido"
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 DOWN FRAME f_contra.
     
     
FORM SKIP(8)
     rel_dsmvtolt
     SKIP(3)
     "AO"
     SKIP
     "BANCO DO BRASIL"
     SKIP
     crapcop.nmcidade FORMAT "x(13)"
     " - "
     crapcop.cdufdcop
     SKIP(3)
     "Solicitamos o cancelamento da Contra Ordens dos cheques abaixo:"
     SKIP(3)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_label_cancel.

FORM cratrej.nrdctabb       FORMAT "zzzz,zzz,9"  LABEL "Conta"
     cratrej.nrcheque AT 16 FORMAT "x(21)"       LABEL "Nro. dos Cheques"
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 DOWN FRAME f_cancel.
     

ASSIGN glb_cdprogra = "crps406".
 
RUN fontes/iniprg.p.


IF   glb_cdcritic > 0 THEN
     QUIT.
  

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

/* montar a data atual por extenso */
rel_dsmvtolt = TRIM(crapcop.nmcidade)            + ", " +
               STRING(DAY(glb_dtmvtolt))         + " "  +
               rel_mmmvtolt[MONTH(glb_dtmvtolt)] + " "  +
               STRING(YEAR(glb_dtmvtolt))        + ".".

RUN p_divinome.

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

FIND LAST crapcor WHERE crapcor.cdcooper = glb_cdcooper   AND
                        crapcor.dtmvtolt = glb_dtmvtolt   AND
                        crapcor.cdbanchq = 1              AND /** BB **/
                        crapcor.flgativo = TRUE
                        NO-LOCK NO-ERROR.

IF   AVAILABLE crapcor   THEN
     RUN proc_inclusao.

FIND FIRST craprej WHERE craprej.cdcooper = glb_cdcooper        AND
                         craprej.dtmvtolt = glb_dtmvtolt        AND
                         craprej.nrdctabb <> craprej.nrdconta   AND  /** BB **/
                         craprej.dshistor = "DCTROR"       NO-LOCK NO-ERROR.
 
IF   AVAILABLE craprej   THEN
     RUN proc_exclusao.
      

IF   NOT aux_regexist   THEN
     DO:
         DISPLAY STREAM str_1 
                 "** NENHUMA CONTRA-ORDEM INCLUIDA/EXCLUIDA NESTA DATA **"
                 SKIP(1)
                 WITH NO-BOX WIDTH 80 FRAME f_nada.
     END.
        
OUTPUT STREAM str_1 CLOSE.
        
ASSIGN glb_nrcopias = IF NOT aux_regexist THEN 1 ELSE 2
       glb_nmformul = "timbre"
       glb_nmarqimp = aux_nmarqimp.


RUN fontes/imprim.p.

RUN fontes/fimprg.p.

/* .......................................................................... */

PROCEDURE proc_inclusao:

    ASSIGN aux_nrctaant = 0.
    
    DISPLAY STREAM str_1 rel_dsmvtolt 
                         crapcop.nmcidade
                         crapcop.cdufdcop
                         WITH FRAME f_label_contra.

    FOR EACH crapcor WHERE crapcor.cdcooper = glb_cdcooper AND
                           crapcor.dtmvtolt = glb_dtmvtolt AND      
                           crapcor.cdbanchq = 1            AND /** BB **/
                           crapcor.flgativo = TRUE
                           NO-LOCK
                           BY crapcor.nrdctabb BY crapcor.nrcheque:
 
        FIND craphis NO-LOCK WHERE 
             craphis.cdcooper = crapcor.cdcooper AND 
             craphis.cdhistor = crapcor.cdhistor NO-ERROR.
   
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = crapcor.nrdconta
                           NO-LOCK NO-ERROR.
                           
        ASSIGN rel_nrdctabb = crapcor.nrdctabb
               rel_nrcheque = STRING(crapcor.nrcheque,"zzz,zzz,9")
               rel_preenchi = IF craphis.cdhistor = 817 OR
                                 craphis.cdhistor = 818 THEN
                                 TRUE
                              ELSE
                                 FALSE
               aux_regexist = TRUE.
               
        /* Tratamento de CPF/CGC */
        IF   crapass.inpessoa = 1   THEN
             ASSIGN  rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                     rel_nrcpfcgc = STRING(rel_nrcpfcgc,"    xxx.xxx.xxx-xx").
        ELSE
             ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                    rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
        
        /* Tratamento para a alinea */
        IF   crapcor.dtvalcor >= glb_dtmvtolt AND
             crapcor.dtvalcor <> ?            THEN
             rel_cdalinea = 70.
        ELSE
        IF   crapcor.cdhistor = 815   THEN
             rel_cdalinea = 21.
        ELSE             
        IF   crapcor.cdhistor = 818   OR
             crapcor.cdhistor = 835   THEN
             rel_cdalinea = 28.
        ELSE             
        IF   crapcor.cdhistor = 825   OR 
             crapcor.cdhistor = 817   THEN
             rel_cdalinea = 20.
        ELSE             
             rel_cdalinea = 0.
        
        IF   aux_nrctaant <> crapcor.nrdconta   THEN
             ASSIGN aux_nrctaant = crapcor.nrdconta
                    aux_nrchqfim = 0.

        IF   aux_nrchqfim >= crapcor.nrcheque   THEN
             NEXT.
        
        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.
                 DISPLAY STREAM str_1 rel_dsmvtolt
                                      crapcop.nmcidade
                                      crapcop.cdufdcop
                                      WITH FRAME f_label_contra.
             END.

        RUN agrupar_cheques ("I").

    END.  /*  Fim do FOR EACH -- crapcor  */

    /* assinatura da COOP */
    PUT STREAM str_1 SKIP(3)
                     "Duvidas entrar em contato com a " AT 5
                     crapcop.nmrescop FORMAT "X(20)"  "."
                     SKIP(4)
                     "Atenciosamente,"      AT 5
                     SKIP(7)
                     rel_nmressbr[1]        AT 5
                     SKIP
                     rel_nmressbr[2]        AT 5
                     SKIP.

END PROCEDURE.

PROCEDURE proc_exclusao:

    ASSIGN aux_nrctaant = 0.
    
    IF   aux_regexist   THEN
         PAGE STREAM str_1.
    
    DISPLAY STREAM str_1 rel_dsmvtolt
                         crapcop.nmcidade
                         crapcop.cdufdcop
                         WITH FRAME f_label_cancel.

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper       AND
                           craprej.dtmvtolt = glb_dtmvtolt       AND
                           craprej.nrdctabb <> craprej.nrdconta  AND /** BB **/
                           craprej.dshistor = "DCTROR"           NO-LOCK
                           BY craprej.nrdocmto:
    
        FIND craphis NO-LOCK WHERE craphis.cdcooper = craprej.cdcooper AND 
                                   craphis.cdhistor = craprej.cdhistor NO-ERROR.
                                       
        FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                           crapass.nrdconta = craprej.nrdconta
                           NO-LOCK NO-ERROR.
        
        ASSIGN rel_nrdctabb = craprej.nrdctabb
               rel_nrcheque = STRING(craprej.nrdocmto,"zzz,zzz,9")
               aux_regexist = TRUE.

        IF   aux_nrctaant <> craprej.nrdconta   THEN
             ASSIGN aux_nrctaant = craprej.nrdconta
                    aux_nrchqfim = 0.

        IF   aux_nrchqfim >= craprej.nrdocmto   THEN
             NEXT.

        IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
             DO:
                 PAGE STREAM str_1.
                 DISPLAY STREAM str_1 rel_dsmvtolt
                                      crapcop.nmcidade
                                      crapcop.cdufdcop
                                      WITH FRAME f_label_cancel.
             END.

        RUN agrupar_cheques ("E").
        
    END.  /*  Fim do FOR EACH -- craprej  */

    FOR EACH cratrej BY cratrej.nrdctabb:
        
        DISPLAY STREAM str_1
                cratrej.nrdctabb   
                cratrej.nrcheque  
                WITH FRAME f_cancel.
        
        DOWN STREAM str_1 WITH FRAME f_cancel.
    
    END.
    
    /* assinatura da COOP */
    PUT STREAM str_1 SKIP(3)
                     "Duvidas entrar em contato com a " AT 5
                     crapcop.nmrescop FORMAT "X(20)" "."
                     SKIP(4)
                     "Atenciosamente,"      AT 5
                     SKIP(7)
                     rel_nmressbr[1]        AT 5
                     SKIP
                     rel_nmressbr[2]        AT 5
                     SKIP.

END PROCEDURE.

PROCEDURE agrupar_cheques.
    
    DEF INPUT PARAM aux_tpoperac AS CHAR    FORMAT "x(1)"           NO-UNDO.

    IF   aux_tpoperac = "I"   THEN    /* inclusao */
         DO:
             glb_nrcalcul = crapcor.nrcheque.
       
             FOR EACH crabcor WHERE crabcor.cdcooper = glb_cdcooper       AND 
                                    crabcor.dtemscor = crapcor.dtemscor   AND
                                    crabcor.nrdconta = crapcor.nrdconta   AND
                                    crabcor.nrdctabb = crapcor.nrdctabb   AND
                                    crabcor.nrtalchq = crapcor.nrtalchq   AND
                                    crabcor.nrcheque > crapcor.nrcheque
                                    NO-LOCK            
                                    BY crabcor.nrdctabb
                                       BY crabcor.nrcheque:

                 glb_nrcalcul = glb_nrcalcul + 10.

                 RUN fontes/digfun.p.
                 
                 IF   glb_nrcalcul <> crabcor.nrcheque  THEN
                      DO:
                         DISPLAY STREAM str_1
                                        rel_nrdctabb  rel_nrcheque  
                                        rel_nrcpfcgc  rel_preenchi
                                        rel_cdalinea
                                        WITH FRAME f_contra.

                         DOWN STREAM str_1 WITH FRAME f_contra.

                         RETURN.
                      END.
                 ELSE
                      ASSIGN 
                          rel_nrcheque = STRING(crapcor.nrcheque,"zzz,zzz,9") +
                                         " a " +
                                         STRING(crabcor.nrcheque,"zzz,zzz,9")
                          aux_nrchqfim = crabcor.nrcheque.
             END.                                   
         
             DISPLAY STREAM str_1
                            rel_nrdctabb  rel_nrcheque  
                            rel_nrcpfcgc  rel_preenchi
                            rel_cdalinea
                            WITH FRAME f_contra.

             DOWN STREAM str_1 WITH FRAME f_contra.
         
         END.
    ELSE
    IF   aux_tpoperac = "E"   THEN      /* exclusao */
         DO:
             glb_nrcalcul = craprej.nrdocmto.
            
             FOR EACH crabrej WHERE crabrej.cdcooper = glb_cdcooper       AND
                                    crabrej.dtmvtolt = craprej.dtmvtolt   AND
                                    crabrej.dshistor = craprej.dshistor   AND
                                    crabrej.nrdconta = craprej.nrdconta   AND
                                    crabrej.nrdctabb = craprej.nrdctabb   AND
                                    crabrej.nrdocmto > craprej.nrdocmto
                                    NO-LOCK            
                                    BY crabrej.nrdctabb  
                                       BY crabrej.nrdocmto:

                 glb_nrcalcul = glb_nrcalcul + 10.

                 RUN fontes/digfun.p.
                 
                 IF   glb_nrcalcul <> crabrej.nrdocmto  THEN
                      DO:
                         CREATE cratrej.
                         ASSIGN cratrej.nrdctabb = rel_nrdctabb
                                cratrej.nrcheque = rel_nrcheque.
                         
                         RETURN.
                      END.
                 ELSE
                      ASSIGN 
                          rel_nrcheque = STRING(craprej.nrdocmto,"zzz,zzz,9") +
                                         " a " +
                                         STRING(crabrej.nrdocmto,"zzz,zzz,9")
                          aux_nrchqfim = crabrej.nrdocmto.
             END.                                   
             
             CREATE cratrej.
             ASSIGN cratrej.nrdctabb = rel_nrdctabb
                    cratrej.nrcheque = rel_nrcheque.
             
         END.
         

END PROCEDURE.


PROCEDURE p_divinome:

  /******* Divide o campo crapcop.nmextcop em duas Strings *******/
  
  ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
                        rel_nmressbr = "".

  DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
     IF   aux_contapal <= aux_qtpalavr   THEN
          rel_nmressbr[1] = rel_nmressbr[1] +   
                      (IF TRIM(rel_nmressbr[1]) = "" THEN "" ELSE " ") 
                           + ENTRY(aux_contapal,crapcop.nmextcop," ").
     ELSE
          rel_nmressbr[2] = rel_nmressbr[2] +
                      (IF TRIM(rel_nmressbr[2]) = "" THEN "" ELSE " ")
                           + ENTRY(aux_contapal,crapcop.nmextcop," ").
  END.  /*  Fim DO .. TO  */ 
           
  /* centralizar as duas strings */
  IF   LENGTH(rel_nmressbr[1]) > LENGTH(rel_nmressbr[2])   THEN
       ASSIGN 
          rel_nmressbr[1] = TRIM(rel_nmressbr[1])
          rel_nmressbr[2] = FILL(" ",INT(LENGTH(rel_nmressbr[1]) / 2) -
                                     INT(LENGTH(rel_nmressbr[2]) / 2)) +
                            rel_nmressbr[2].
  ELSE
  IF   LENGTH(rel_nmressbr[1]) < LENGTH(rel_nmressbr[2])   THEN
       ASSIGN 
          rel_nmressbr[1] = FILL(" ",INT(LENGTH(rel_nmressbr[2]) / 2) -
                                     INT(LENGTH(rel_nmressbr[1]) / 2)) +
                            rel_nmressbr[1]
          rel_nmressbr[2] = TRIM(rel_nmressbr[2]).
  ELSE
       ASSIGN rel_nmressbr[1] = TRIM(rel_nmressbr[1])
              rel_nmressbr[2] = TRIM(rel_nmressbr[2]).

END PROCEDURE.

/* .......................................................................... */
