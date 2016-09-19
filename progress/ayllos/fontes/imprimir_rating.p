/*..............................................................................
                
    Programa: fontes/imprimir_rating.p
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : David
    Data    : Maio/2010                       Ultima atualizacao: 01/04/2011
   
    Dados referentes ao programa:
   
    Frequencia: Sera chamado para efetuar impressao do rating do cooperado. 
               
    Alteracoes: 01/04/2011 - Inclusao da nota e risco do cooperado e alteracao
                             do label "Nota" para 
                             "Nota Rating(cooperado + operacao)". (Fabricio)
    
..............................................................................*/

{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i  }
{ includes/gera_rating.i }


DEF  INPUT PARAM TABLE FOR tt-impressao-coop.
DEF  INPUT PARAM TABLE FOR tt-impressao-rating.
DEF  INPUT PARAM TABLE FOR tt-impressao-risco.
DEF  INPUT PARAM TABLE FOR tt-impressao-risco-tl.
DEF  INPUT PARAM TABLE FOR tt-impressao-assina.
DEF  INPUT PARAM TABLE FOR tt-efetivacao.

DEF STREAM str_1.        
        
VIEW FRAME f_aguarde.

ASSIGN aux_nmarqimp = "rl/rating_" + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 82.

ASSIGN glb_cdrelato[1] = 367 /** Relatorio de impressao do rating **/
       glb_cdempres    = 11. 

{ includes/cabrel132_1.i }

VIEW STREAM str_1 FRAME f_cabrel132_1.

/** Dados do cooperado **/    
FIND FIRST tt-impressao-coop NO-LOCK NO-ERROR.

DISPLAY STREAM str_1 tt-impressao-coop.nrdconta
                     tt-impressao-coop.nmprimtl
                     tt-impressao-coop.dspessoa
                     tt-impressao-coop.nrctrrat
                     tt-impressao-coop.dsdopera
                     WITH FRAME f_cooperado.

/** Topícos do rating **/
FOR EACH tt-impressao-rating NO-LOCK BREAK BY tt-impressao-rating.nrtopico
                                             BY tt-impressao-rating.nritetop
                                               BY tt-impressao-rating.nrseqite:

    IF  FIRST-OF(tt-impressao-rating.nrtopico)  THEN
        DISPLAY STREAM str_1 tt-impressao-rating.nrtopico
                             tt-impressao-rating.dsitetop   
                             WITH FRAME f_rating_1.
    ELSE
    IF  FIRST-OF(tt-impressao-rating.nritetop)  THEN
        DISPLAY STREAM str_1 tt-impressao-rating.dsitetop
                             tt-impressao-rating.dspesoit                              
                             WITH FRAME f_rating_2.
    ELSE
        DISPLAY STREAM str_1 tt-impressao-rating.dsitetop
                             tt-impressao-rating.dspesoit                       
                             WITH FRAME f_rating_3.                 

END. /** Fim do FOR EACH tt-impressao-rating **/

FIND FIRST tt-impressao-risco-tl NO-LOCK NO-ERROR.

FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.

ASSIGN aux_notaoperacao = tt-impressao-risco.vlrtotal - 
                                            tt-impressao-risco-tl.vlrtotal.

/* Nota do cooperado, seu correspondente risco e a nota da operação */
DISPLAY STREAM str_1 tt-impressao-risco-tl.vlrtotal
                     tt-impressao-risco-tl.dsdrisco
                     aux_notaoperacao
                      WITH FRAME f_nota_risco_coop.

/** Valor do rating(cooperado + operacao) e o seu correspondente risco **/ 
DISPLAY STREAM str_1 tt-impressao-risco.vlrtotal
                     tt-impressao-risco.dsdrisco
                     tt-impressao-risco.vlprovis
                     tt-impressao-risco.dsparece
                     WITH FRAME f_nota_risco.

FIND FIRST tt-impressao-assina NO-LOCK NO-ERROR.

DISPLAY STREAM str_1 tt-impressao-assina WITH FRAME f_assina.

/** Imprimir como observacao qual Rating foi efetivado **/
FIND tt-efetivacao WHERE tt-efetivacao.idseqmen = 2 NO-LOCK NO-ERROR.
        
IF  AVAIL tt-efetivacao  THEN
    DISPLAY STREAM str_1 tt-efetivacao.dsdefeti WITH FRAME f_observacao.
     
OUTPUT STREAM str_1 CLOSE.
                          
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    PAUSE 2 NO-MESSAGE.
    LEAVE.

END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_aguarde NO-PAUSE.

ASSIGN tel_cddopcao = "T".

DO WHILE TRUE ON ENDKEY UNDO , LEAVE:
    
    MESSAGE "(T)erminal ou (I)mpressora:" UPDATE tel_cddopcao.
    LEAVE.

END. /** Fim do DO WHILE TRUE **/

HIDE MESSAGE NO-PAUSE.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
    RETURN.

IF  tel_cddopcao = "T"  THEN
    RUN fontes/visrel.p (INPUT aux_nmarqimp).   
ELSE 
IF  tel_cddopcao = "I"  THEN
    DO:
        ASSIGN par_flgrodar = TRUE
               glb_nmformul = "132col"
               glb_nrdevias = 1.

        /** FIND necessario para a include de impressao **/    
        FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                 NO-LOCK NO-ERROR.

        { includes/impressao.i }
    END.  

UNIX SILENT VALUE("rm " + aux_nmarqimp + " 2>/dev/null").

/*............................................................................*/
