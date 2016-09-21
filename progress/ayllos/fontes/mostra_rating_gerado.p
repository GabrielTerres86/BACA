/*..............................................................................
                
    Programa: fontes/mostra_rating_gerado.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Maio/2010                       Ultima atualizacao: 00/00/0000
   
    Dados referentes ao programa:
   
    Frequencia: Sera chamado para mostrar dados do rating gerado. 
               
    Alteracoes:
    
..............................................................................*/

{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i  }
{ includes/gera_rating.i } 

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_tpctrato AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nrctrato AS INTE                                  NO-UNDO.

DEF  INPUT PARAM TABLE FOR tt-impressao-coop.
DEF  INPUT PARAM TABLE FOR tt-impressao-rating.
DEF  INPUT PARAM TABLE FOR tt-impressao-risco.
DEF  INPUT PARAM TABLE FOR tt-impressao-risco-tl.
DEF  INPUT PARAM TABLE FOR tt-impressao-assina.
DEF  INPUT PARAM TABLE FOR tt-efetivacao.
DEF  INPUT PARAM TABLE FOR tt-ratings.

/** Efetivou automaticamente **/
IF  TEMP-TABLE tt-efetivacao:HAS-RECORDS  THEN 
    DO:   
        ASSIGN aux_qtlintel = 0.   
        
        FOR EACH tt-ratings NO-LOCK BY tt-ratings.insitrat DESC
                                       BY tt-ratings.nrnotrat DESC 
                                          BY tt-ratings.dtmvtolt DESC:
     
            IF  aux_qtlintel >= 8  THEN
                LEAVE.
      
            ASSIGN aux_qtlintel = aux_qtlintel + 1.
      
            DISPLAY tt-ratings.dtmvtolt
                    tt-ratings.dsdopera
                    tt-ratings.nrctrrat
                    tt-ratings.nrnotrat
                    tt-ratings.indrisco 
                    tt-ratings.vlutlrat
                    WITH FRAME f_lista_rating.
      
            DOWN WITH FRAME f_lista_rating.
                         
        END. /** Fim do FOR EACH tt-ratings **/
  
        FIND tt-efetivacao WHERE tt-efetivacao.idseqmen = 1 NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-efetivacao  THEN
            MESSAGE tt-efetivacao.dsdefeti.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            PAUSE.
            LEAVE.                          
        END. /** Fim do DO WHILE TRUE **/

        HIDE FRAME f_lista_rating NO-PAUSE.  

        HIDE MESSAGE NO-PAUSE.

        /** Imprimir somente se efetivar Rating **/
        RUN fontes/imprimir_rating.p (INPUT TABLE tt-impressao-coop,
                                      INPUT TABLE tt-impressao-rating,
                                      INPUT TABLE tt-impressao-risco,
                                      INPUT TABLE tt-impressao-risco-tl,
                                      INPUT TABLE tt-impressao-assina,
                                      INPUT TABLE tt-efetivacao).

        /** Achar o Rating efetivo **/
        FIND tt-ratings WHERE tt-ratings.insitrat = 2 NO-LOCK NO-ERROR.

        IF  AVAILABLE tt-ratings  THEN
            DO:
                /** Impressao do Rating efetivo (quando for diferente **/
                /** da operacao que estiver lançando).                **/
                IF  NOT(tt-ratings.tpctrrat = par_tpctrato   AND
                        tt-ratings.nrctrrat = par_nrctrato)  THEN
                    RUN fontes/gera_rating.p (INPUT glb_cdcooper,
                                              INPUT par_nrdconta,
                                              INPUT tt-ratings.tpctrrat,
                                              INPUT tt-ratings.nrctrrat,
                                              INPUT FALSE).
            END.
    END.

/*............................................................................*/
