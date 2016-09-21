/* ............................................................................

   Programa: Fontes/crps595.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Maio/2011                        Ultima atualizacao: 06/01/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : 
               

   Alteracao : 24/06/2011 - Exluir arquivo quoter quando nao for convenio de
                            cobranca registrada (David).
                            
               31/12/2012 - Copiar arquivos ied241 da Viacredi quando prog.
                            for executado na Alto Vale (Rafael).
                            
               04/03/2013 - Retirado rotina de cópia dos arquivos ied241 da
                            Viacredi para Alto Vale - Atualmente realizado 
                            pelo script ArquivosBB.sh (Rafael).    
                            
               24/12/2013 - Ajuste Migracao Acredi->Viacredi (Rafael).
               
               06/01/2015 - Ajuste projeto Incorporacao. (Rafael).
............................................................................ */

{ sistema/generico/includes/b1wgen0010tt.i }

{ includes/var_batch.i }


DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho */

DEF VAR aux_contador AS INT                                      NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                     NO-UNDO.
DEF VAR aux_setlinha AS CHAR    FORMAT "x(298)"                  NO-UNDO.
DEF VAR aux_nmarqdeb AS CHAR                                     NO-UNDO.
DEF VAR aux_arqimpor AS CHAR    FORMAT "X(150)"                  NO-UNDO.
DEF VAR tab_nmarqtel AS CHAR    FORMAT "x(25)" EXTENT 99         NO-UNDO.
DEF VAR aux_nrconven AS INT                                      NO-UNDO.
DEF VAR aux_nrdocnpj AS DECI                                     NO-UNDO.
DEF VAR aux_nmarqnew AS CHAR                                     NO-UNDO.


/********************************* Inicio ***********************************/
ASSIGN glb_cdprogra = "crps595"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.
     

IF   glb_cdcritic > 0 THEN
     RETURN.

/*-------------------------  Busca dados da cooperativa --------------------*/
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN "NOK".
     END.

ASSIGN aux_nmarqdeb = "compbb/ied241*".


/*-----------  Busca arquivos a serem processados e prepara quoter ----------*/
EMPTY TEMP-TABLE cratarq.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarqdeb + " 2> /dev/null")
      NO-ECHO.

DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(70)".

   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                     aux_nmarquiv + ".q 2> /dev/null").

   CREATE cratarq.
   ASSIGN cratarq.nmarquiv = aux_nmarquiv
          cratarq.nmquoter = aux_nmarquiv + ".q"
          aux_contador     = aux_contador + 1.

END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_contador = 0 THEN   /* Nao existem arquivos para serem importados */
     DO:
        RUN fontes/fimprg.p.
        RETURN.
     END.



FOR EACH cratarq:

    ASSIGN glb_cdcritic = 0.
    
    
    INPUT STREAM str_2 THROUGH VALUE("head -n 1 " + cratarq.nmquoter) NO-ECHO.
    
    SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 300.


    ASSIGN aux_nrconven  = INTE(SUBSTR(aux_setlinha,33,9))
           aux_nrdocnpj  = DECI(SUBSTR(aux_setlinha,19,14)).


    /* nao checar CNPJ quando executar na Alto Vale e Viacredi */
    IF  NOT CAN-DO("1,13,16", STRING(glb_cdcooper)) THEN DO:
    
        /** Verificar se o CNPJ do arqv. pertence coop processada **/
        FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper
                       AND crapcop.nrdocnpj = aux_nrdocnpj
            NO-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapcop THEN DO:
    
            aux_nmarquiv = "integra/err" + SUBSTR(cratarq.nmarquiv,8,29).
            UNIX SILENT VALUE("rm " + cratarq.nmquoter + " 2> /dev/null").
            UNIX SILENT VALUE("cp " + cratarq.nmarquiv + " salvar").
            UNIX SILENT VALUE("mv " + cratarq.nmarquiv + " " + 
                                       aux_nmarquiv).
    
            RUN fontes/critic.p.
    
            ASSIGN glb_dscritic = " Arquivo nao pertence a esta cooperativa".
    
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                " - " + glb_cdprogra + "' --> '" +
                                glb_dscritic + " " + aux_nmarquiv +
                                " >> log/proc_batch.log").
            NEXT.
    
        END.

    END.


    /* Verificar se o Convenio do arqv. se refere ao conv. Coop */
    FIND crapcco WHERE crapcco.cdcooper = glb_cdcooper   AND
                       crapcco.nrconven = aux_nrconven   AND
                       crapcco.cddbanco = 1              AND
                       crapcco.flgregis = TRUE
                       NO-LOCK NO-ERROR.

    IF  AVAILABLE crapcco THEN 
        DO:
            /* Renomeia arquivo de ied241 para ied242 */
            aux_nmarqnew = REPLACE(cratarq.nmarquiv,"ied241","ied242").
            
            UNIX SILENT VALUE("mv " + cratarq.nmarquiv + " " + 
                                      aux_nmarqnew).
    
        END.

    UNIX SILENT VALUE("rm " + cratarq.nmquoter + " 2> /dev/null").

    INPUT STREAM str_2 CLOSE.

END. /* FIM do FOR EACh cratarq */


RUN fontes/fimprg.p.
