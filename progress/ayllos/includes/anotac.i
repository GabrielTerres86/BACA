/* .............................................................................

   Programa: Includes/anotac.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Edson
   Data    : Dezembro/2001                       Ultima alteracao: 08/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela ANOTA.

   Alteracoes: 23/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
   
               22/02/2011 - Utilizacao de BO - (Jose Luis, DB1)
               
               08/04/2014 - Ajuste de whole index (Jean Michel).
............................................................................. */

ASSIGN glb_cdcritic = 0
       aux_tipconsu = YES 
       aux_nmarqimp = "".

ASSIGN btn-incluir:HIDDEN  = TRUE.

ON RETURN OF anota-b DO:

    APPLY "CHOOSE" TO btn-visualiz.
    RETURN NO-APPLY.

END.

ON CHOOSE OF btn-visualiz DO:

    IF  NOT AVAILABLE tt-crapobs  THEN
        RETURN NO-APPLY.

    /**** aqui o registro selecionado ja esta disponivel ***/
    ASSIGN aux_nrseqdig = tt-crapobs.nrseqdig
           aux_recidobs = tt-crapobs.recidobs
           aux_tipconsu = YES.

    RUN fontes/impanotacoes.p.

    HIDE FRAME f_anotacoes.
    RUN fontes/visualiza_anotacoes.p.
    VIEW FRAME f_anotacoes.
    VIEW FRAME f_opcao.  

END.

ON CHOOSE OF btn-imprimir DO:

    IF  NOT AVAILABLE tt-crapobs  THEN
        RETURN NO-APPLY.

    ASSIGN aux_nrseqdig = tt-crapobs.nrseqdig
           aux_recidobs = tt-crapobs.recidobs
           aux_tipconsu = NO.

    RUN fontes/impanotacoes.p.

END.

OPEN QUERY anota-q FOR EACH tt-crapobs NO-LOCK
                    WHERE tt-crapobs.cdcooper = glb_cdcooper.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    UPDATE anota-b btn-visualiz btn-imprimir btn-sair WITH FRAME f_anotacoes. 
    LEAVE.
END.

HIDE FRAME f_anotacoes NO-PAUSE.

/* .......................................................................... */
