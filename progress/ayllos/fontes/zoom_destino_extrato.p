/*.............................................................................

   Programa: fontes/zoom_destino_extrato.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Agosto/2006                         Ultima alteracao: 19/05/1010  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Zoom da tabela crapemp - Cadastro de destinos de extratos.

   Alteracoes:  19/05/2010 - Adaptado para usar BO (Jose Luis, DB1)
............................................................................. */

{ sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM }
{ includes/gg0000.i}

DEF INPUT PARAM par_cdcooper AS INT                              NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                              NO-UNDO.

DEF SHARED VAR shr_cdsecext LIKE crapdes.cdsecext                NO-UNDO.
DEF SHARED VAR shr_nmsecext LIKE crapdes.nmsecext                NO-UNDO.

DEF QUERY q_secext FOR tt-crapdes. 

DEF BROWSE  b_secext QUERY q_secext                         
    DISPLAY tt-crapdes.cdsecext COLUMN-LABEL "Cod."      FORMAT "zz9"
            tt-crapdes.dssecext COLUMN-LABEL "Descricao" FORMAT "x(25)"
            IF   tt-crapdes.indespac = 0 THEN 
                 " SECAO " 
            ELSE "CORREIO" COLUMN-LABEL "Despacho" 
            WITH 8 DOWN CENTERED TITLE "DESTINO DE EXTRATO".

FORM b_secext HELP "Use <TAB> para navegar" 
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_secext.          

DEF FRAME f_secext  
          SKIP(1)
          b_secext   HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX NO-LABEL CENTERED OVERLAY ROW 8.
 
IF  NOT aux_fezbusca THEN
    DO:
        /* Verifica se o banco generico ja esta conectado */
        ASSIGN aux_flggener = f_verconexaogener().

        IF  aux_flggener OR f_conectagener()  THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
                    RUN sistema/generico/procedures/b1wgen0059.p
                        PERSISTENT SET h-b1wgen0059.

                RUN busca-crapdes IN h-b1wgen0059
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT 0,
                      INPUT "",
                      INPUT 999999,
                      INPUT 1,
                     OUTPUT aux_qtregist,
                     OUTPUT TABLE tt-crapdes ).
            
                DELETE PROCEDURE h-b1wgen0059.

                ASSIGN aux_fezbusca = YES.

                IF  NOT aux_flggener  THEN
                    RUN p_desconectagener.
            END.
    END.

ON RETURN OF b_secext 
   DO:
       ASSIGN shr_cdsecext = tt-crapdes.cdsecext
              shr_nmsecext = tt-crapdes.dssecext.
          
       CLOSE QUERY q_secext.               
       
       HIDE FRAME f_secext NO-PAUSE.

       APPLY "END-ERROR" TO b_secext.
   END.

OPEN QUERY q_secext FOR EACH tt-crapdes NO-LOCK BY tt-crapdes.cdsecext.

SET b_secext WITH FRAME f_secext.
   
/* .......................................................................... */
