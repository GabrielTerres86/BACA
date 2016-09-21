/* .............................................................................

   Programa: Fontes/inicia_help.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Marco/2006.                        Ultima atualizacao: 18/10/2012

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado.
   Objetivo  : Rotina de verificacao de versao da AJUDA.

   Alteracoes: 24/08/2006 - Adequacao a exibicao do F2 por rotina (Evandro).
     
               12/09/2006 - Alteracao no controle da variavel de controle de
                            visualizacao do F2 (Evandro).
                            
               19/03/2008 - Aumentado format do campo glb_cdcooper para "99"
                            (Diego).
                          
               29/05/2012 - Ajustes para Oracle (Evandro).

               18/10/2012 - Tratar nova estrutura gnchopa (Gabriel)     

............................................................................. */

{ includes/var_online.i }

DEF INPUT PARAM par_flgvalid AS LOGICAL                              NO-UNDO.

DEF VAR aux_flentrou         AS LOGICAL                              NO-UNDO.
DEF VAR aux_lsopeavi         AS CHAR                                 NO-UNDO.

DEF BUFFER gnbhopa FOR gnchopa.

/* Verifica se o operador ja viu a nova versao */
IF   par_flgvalid   THEN
     DO:
        IF  KEY-FUNCTION(LASTKEY) <> "END-ERROR" THEN
            DO:         
               aux_flentrou = NO.
               
               /*Busca alguma versao da AJUDA da tela que o operador nao viu*/
               FOR EACH gnchelp WHERE gnchelp.nmdatela  = glb_nmdatela   AND
                                      gnchelp.dtlibera <= glb_dtmvtolt
                                      NO-LOCK BREAK BY gnchelp.nmrotina
                                                      BY gnchelp.dtlibera:
                   
                   IF   LAST-OF(gnchelp.dtlibera)   THEN
                        DO:
                            FIND gnchopa WHERE 
                                 gnchopa.nmdatela = gnchelp.nmdatela   AND
                                 gnchopa.nmrotina = gnchelp.nmrotina   AND
                                 gnchopa.nrversao = gnchelp.nrversao
                                 NO-LOCK NO-ERROR.

                            IF   AVAIL gnchopa   THEN
                                 ASSIGN aux_lsopeavi = gnchopa.lsopeavi.
                                  
                            IF   KEY-FUNCTION(LASTKEY) <> "HELP"       AND
                                 glb_cdcritic = 0                      AND
                                 glb_opvihelp = NO                     AND
                                 NOT CAN-DO(aux_lsopeavi,"999")        AND
                                 NOT CAN-DO(aux_lsopeavi,
                                     STRING(glb_cdcooper,"99") +
                                     "-" + glb_cdoperad)               THEN
                                 DO:
                                     MESSAGE "ATENCAO!! Foi liberada uma nova"
                                             "versao da AJUDA desta tela!"
                                             VIEW-AS ALERT-BOX.
                                     LEAVE.
                                 END.
                        END.
               END. /* For each */
            END.     
     END.
/* Inclui o operador na versao visitada */
ELSE
     DO:
        /* Busca a(s) AJUDA(S) da tela */
        FOR EACH gnchelp WHERE gnchelp.nmdatela  = glb_nmtelant   AND
                               gnchelp.dtlibera <= glb_dtmvtolt   
                               NO-LOCK,
                              
           FIRST gnchopa WHERE gnchopa.nmdatela = gnchelp.nmdatela   AND
                               gnchopa.nmrotina = gnchelp.nmrotina   AND
                               gnchopa.nrversao = gnchelp.nrversao   NO-LOCK:

            aux_lsopeavi = gnchopa.lsopeavi.

            /* Verifica se o operador ja viu essa versao para atualizar */
            IF   AVAILABLE gnchelp                                       AND
                 glb_opvihelp = YES                                      AND
                 NOT CAN-DO(aux_lsopeavi,"999")                      AND
                 NOT CAN-DO(aux_lsopeavi,STRING(glb_cdcooper,"99") + 
                            "-" + glb_cdoperad)                          THEN
                 DO:                       
                     FIND gnbhopa WHERE gnbhopa.nmdatela = gnchelp.nmdatela 
                                    AND gnbhopa.nmrotina = gnchelp.nmrotina
                                    AND gnbhopa.nrversao = gnchelp.nrversao
                                    EXCLUSIVE-LOCK NO-ERROR.
        
                     ASSIGN aux_lsopeavi     = gnbhopa.lsopeavi
                            aux_lsopeavi     = aux_lsopeavi +
                                               STRING(glb_cdcooper,"99") + 
                                               "-" + glb_cdoperad + ","
                            gnbhopa.lsopeavi = aux_lsopeavi.
                                  
                     FIND CURRENT gnbhopa NO-LOCK.                                  
                 END.
        END.
     END.
     
/*............................................................................*/
