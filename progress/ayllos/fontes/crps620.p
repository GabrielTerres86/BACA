/* ................................................................................................

   Programa: Fontes/crps620.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Lucas/Guilherme
   Data    : Marco/2012                       Ultima atualizacao: 30/07/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Fazer batimento das informaçoes com o Smartshare-Selbetti
               Emitir Relacao de Contratos Nao Digitalizados.
               Relatorio 620 - Solicitaçao 01.
               
   Alteracoes: 09/07/2013 - Adicionado parametro para 'efetua_batimento_ged'
                            (Lucas).
               
               28/11/2013 - Alteraçao da procedure efetua_batimento_ged, inclusao
                            do parametro de retorno par_nmarqcre (Jean Michel).
                            
               23/01/2013 - Alteraçao na chamada da procedure efetua_batimento_ged (Jean Michel).
               
               20/02/2014 - Alterado 132col por 234dh na impressao do cadastro (Lucas R.)
                                             
               06/03/2014 - Alterado parametro tipopcao da procedure 
                            efetua_batimento_ged de 3 para 4 (Lucas R.)
               
               31/07/2015 - Opçao para todos os relatórios foi alterada para 
                            para 0, enquanto a opçao 4 foi alterada para ser 
                            utilizada para o novo relatório de termos.
                            Projeto 158 Folha de Pagamento (Lombardi)
................................................................................................ */

{ includes/var_batch.i "NEW" }
{ sistema/generico/includes/b1wgen0137tt.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR h-b1wgen0137 AS HANDLE                                      NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqcre AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqmat AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqter AS CHAR                                        NO-UNDO.

ASSIGN glb_cdprogra = "crps620"
       glb_dtmvtolt = TODAY.

RUN sistema/generico/procedures/b1wgen0137.p
    PERSISTENT SET h-b1wgen0137.

IF  NOT VALID-HANDLE(h-b1wgen0137) THEN
DO:
    ASSIGN glb_dscritic = "Handle invalido para h-b1wgen0137".
    
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - crps620 " + "' --> '"  +
                      glb_dscritic + " >> log/proc_batch.log").
    RETURN.
END.                      

FOR EACH crapcop NO-LOCK:
        
    RUN efetua_batimento_ged IN h-b1wgen0137 (INPUT crapcop.cdcooper,
                                              INPUT ?,
                                              INPUT TODAY,
                                              INPUT ?,
                                              INPUT 0, /* 0 - Batch / 1 - Tela */
                                              INPUT 0, /* 0 - Todos */
                                             OUTPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqcre,
                                             OUTPUT aux_nmarqmat,
                                             OUTPUT aux_nmarqter,
                                             OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            FIND LAST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro  THEN
                ASSIGN glb_dscritic = tt-erro.dscritic + " Coop: " + 
                                      STRING(crapcop.nmrescop).
            ELSE
                ASSIGN glb_dscritic = "Nao foi possivel efetuar o batimento " +
                                      "da digitalizacao de documentos. " +
                                      "Coop: " + STRING(crapcop.nmrescop).
        
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                              " - crps620 " + "' --> '"  +
                              glb_dscritic + 
                              " >> /usr/coop/cecred/log/proc_batch.log").
        END.
        
        IF  aux_nmarqimp <> "" AND aux_nmarqimp <> ? THEN
            DO:
                ASSIGN glb_nmformul = "234dh"
                   glb_nmarqimp = aux_nmarqimp
                   glb_nrcopias = 1.
        
                RUN fontes/imprim_unif.p (INPUT INTE(crapcop.cdcooper)).
            END.
        
        IF  aux_nmarqcre <> "" AND aux_nmarqcre <> ? THEN
            DO:
             
                ASSIGN glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqcre
                       glb_nrcopias = 1.
        
                RUN fontes/imprim_unif.p (INPUT INTE(crapcop.cdcooper)).
            END.

        IF  aux_nmarqmat <> "" AND aux_nmarqmat <> ? THEN
            DO:
             
                ASSIGN glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqmat
                       glb_nrcopias = 1.
        
                RUN fontes/imprim_unif.p (INPUT INTE(crapcop.cdcooper)).
            END.
            
        IF  aux_nmarqter <> "" AND aux_nmarqter <> ? THEN
                DO:
                    ASSIGN glb_nmformul = "132col"
                       glb_nmarqimp = aux_nmarqter
                       glb_nrcopias = 1.

                    RUN fontes/imprim_unif.p (INPUT INTE(crapcop.cdcooper)).
                END.


END.

DELETE PROCEDURE h-b1wgen0137.

/* .......................................................................... */



