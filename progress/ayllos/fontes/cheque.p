/* .............................................................................

   Programa: Fontes/cheque.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/91.                     Ultima atualizacao: 16/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CHEQUE.

   Alteracoes: 27/10/94 - Alterado para incluir o tratamento 6 para os indicado-
                          res. (Odair).

               06/07/95 - Alterado para mostrar na grade CANC quando indicador
                          do cheque = 8 (Odair).

               26/03/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               01/07/99 - Tratar tpcheque no chq (Odair)

               12/03/2003 - Mostrar os talonarios que tem folhas canceladas
                            (Deborah).

               18/06/2004 - Mostrar tambem os talonarios totalmente processados
                            (Deborah).

               19/07/2005 - Classificado por data de emissao talao(Mirtes)
               
               04/10/2005 - Alteracao de crapchq p/ crapfdc (SQLWorks - Andre).
                            Alteracao do programa p/ visualizacao de cheques.
                            
               18/10/2005 - Analise do programa para ajustes da interface.
               
               25/11/2005 - Inclusao da opcao de cheques solicitados (SQLWorks -
                            Andre).               

               13/12/2005 - Alterado a ordem das opcoes de listagem de cheques
                            (Edson).
                            
               16/01/2006 - Mostrar as devolucoes do cheque (Edson).

               26/05/2006 - Incluir coopes em alguns finds (Magui).

               02/01/2007 - Alterado para enviar talonarios do convenio Bancoob
                            (Ze).
                                           
               30/01/2007 - Incluir campo crapcor.dtmvtolt no frame f_detalhes
                            (David).

               12/02/2007 - Alterar consultas com indice crapfdc1 (David).
               
               26/02/2007 - Incluir bco no browse (Magui).
               
               18/12/2007 - Incluir cod. do operador na contra-ordem(Guilherme).
               
               
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
               
               20/08/2008 - Tratar pracas de compensacao (Magui).

               26/02/2009 - Substituir a leitura da tabela craptab pelo
                            ver_ctace.p para informacoes de conta convenio
                            (Sidnei - Precise IT)

               22/05/2009 - Alteracao CDOPERAD (Kbase).
               
               23/09/2010 - Incluir o campo TD nos detalhes (Ze).
               
               09/12/2010 - Possibilitar a consulta de cheques por numero na 
                            opcao "Todos" (Vitor).        
                          - Incluida aux_where_06 (Vitor).
                            
               17/02/2011 - Acrescentado tres posicoes a mais no format
                            do field crapfdc.nrctadep. (Fabricio)
                            
               09/03/2011 - Aumento na descricao do campo Contra-Ordem 
                           (Eder GATI).
                           
               04/05/2011 - Adaptacao do fonte para BO 40. (André - DB1)
                                        
               16/04/2012 - Fonte substituido por chequep.p (Tiago).
               
               31/08/2012 - Incluido novos campos no detalhe do cheque
                            (Tiago).
                            
               18/12/2012 - Retirar campo Conta TIC (Ze). 
               
               22/08/2013 - Alterado format TD para 3 posiçoes(Daniele).            
               
               30/06/2014 - Incluir campo cdageaco no frame f_detalhe. (Reinert)
               
               16/09/2014 - Inclusão da coluna cdagechq na tela. (Vanessa)
............................................................................. */

{ includes/var_online.i}
{ sistema/generico/includes/var_internet.i}
{ sistema/generico/includes/b1wgen0040tt.i}

DEF BUFFER crabfdc FOR crapfdc.

DEF VAR tel_nrdconta  AS INTE    FORMAT "zzzz,zzz,9"                  NO-UNDO.
DEF VAR tel_nmprimtl  AS CHAR    FORMAT "x(40)"                       NO-UNDO.
DEF VAR tel_qtrequis  AS INTE                                         NO-UNDO.
DEF VAR aux_nrdotipo  AS INTE                                         NO-UNDO.
DEF VAR aux_cddopcao  AS CHAR                                         NO-UNDO.
DEF VAR aux_stimeout  AS INTE                                         NO-UNDO.
DEF VAR aux_nrcheque  AS INTE    FORMAT "zzzzz9"                      NO-UNDO.
DEF VAR aux_nrdconta  AS INTE                                         NO-UNDO.
DEF VAR aux_qtregist AS INTE                                          NO-UNDO.

DEF VAR par_nmprimtl AS CHAR                                          NO-UNDO.
DEF VAR par_qtrequis AS INTE                                          NO-UNDO.
DEF VAR par_dsmsgcnt AS CHAR                                          NO-UNDO.

DEF VAR h-b1wgen0040 AS HANDLE                                        NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                        NO-UNDO.

DEF VAR tel_tipos AS INTEGER VIEW-AS RADIO-SET 
                                     HORIZONTAL
                                     RADIO-BUTTONS 
                                     "Em uso",1,
                                     "Arquivo",2,
                                     "Solicitados",3,
                                     "Compensados",4,
                                     "Todos",5
                                     SIZE 60 BY 1                     NO-UNDO.

DEFINE BUTTON btn_devolucoes LABEL "Voltar".

DEFINE QUERY  q_crapfdc FOR tt-cheques SCROLLING.
DEFINE BROWSE b_crapfdc QUERY q_crapfdc NO-LOCK
        DISPLAY tt-cheques.cdbanchq FORMAT "zz9"         COLUMN-LABEL "Bco"
                tt-cheques.cdagechq FORMAT "zzz9"         COLUMN-LABEL "Age"
                tt-cheques.nrcheque FORMAT "zzzzzz,9"    COLUMN-LABEL "Cheque"
                tt-cheques.nrseqems FORMAT "zzzz9"       COLUMN-LABEL "Sq.Em"
                tt-cheques.tpcheque FORMAT "xx"          COLUMN-LABEL "Tp"
                tt-cheques.tpforchq FORMAT "x(2)"        COLUMN-LABEL "Fm"
                tt-cheques.dsobserv FORMAT "x(12)"       COLUMN-LABEL "Observacao"
                tt-cheques.dtemschq FORMAT "99/99/99"    COLUMN-LABEL "Emitido"
                tt-cheques.dtretchq FORMAT "99/99/99"    COLUMN-LABEL "Retirado"
                tt-cheques.dtliqchq FORMAT "99/99/99"    COLUMN-LABEL "Compens."
                tt-cheques.nrdctitg FORMAT "9.999.999-X" COLUMN-LABEL "Conta ITG"
                WITH NO-ROW-MARKERS SIZE 78 BY 13 NO-BOX.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  2 LABEL "Conta/dv." AUTO-RETURN
                        HELP "Entre com o numero da conta do associado."
     tel_nmprimtl AT 25 LABEL "Titular"
     SKIP
     tel_tipos    AT  2 LABEL "Cheques"
          HELP "Use as SETAS de direcao e tecle <ENTER> para continuar." 
     "Req:" SPACE(0)
     tel_qtrequis       NO-LABEL FORMAT "z9"
     SKIP         
     b_crapfdc  AT  1 
         HELP "Tecle <ENTER> para ver detalhes do cheque ou <F4> para retornar."
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_cheque.

FORM SKIP
     tt-cheques.nrpedido  COLON 21 LABEL "Pedido" " " 
     tt-cheques.dtsolped           LABEL "Enviado em"   FORMAT "99/99/99"
     tt-cheques.dtrecped           LABEL "Recebido em"  FORMAT "99/99/99"
     SKIP(1)
     tt-cheques.dsdocmc7  COLON 21 LABEL "CMC-7"
     SKIP
     tt-cheques.dscordem  COLON 21 LABEL "Contra-ordem" FORMAT "x(54)" SKIP
     tt-cheques.dscorde1     AT 52 NO-LABEL             FORMAT "x(25)"
     SKIP
     tt-cheques.dtmvtolt  COLON 21 NO-LABEL             FORMAT "x(52)"
     SKIP
     tt-cheques.cdbandep  COLON 21 LABEL "Depositado no Banco"
     tt-cheques.cdagedep     AT 32 LABEL "Agencia"
     tt-cheques.nrctadep     AT 51 FORMAT "zzz,zzz,zzz,zz9,9" LABEL "Conta"
     SKIP
     tt-cheques.cdageaco  COLON 21 LABEL "Coop. Acolhedora"
     tt-cheques.cdtpdchq     AT 37 LABEL "TD"       FORMAT "zz9"
     tt-cheques.vlcheque  COLON 56 LABEL "Valor"    FORMAT "zz,zzz,zzz,zz9.99"
     SKIP(1)
     tt-cheques.cdbantic  COLON 21 LABEL "Custodiado no Banco"
     tt-cheques.cdagetic     AT 32 LABEL "Agencia"
     tt-cheques.dtlibtic     AT 51 LABEL "Liberacao em"
     SKIP(1)
     btn_devolucoes          AT 35
     WITH ROW 8 COLUMN 2 OVERLAY 1 DOWN WIDTH 78 
          SIDE-LABELS TITLE " Detalhes do Cheque "
          FRAME f_detalhe.

FORM aux_nrcheque LABEL "A partir de" AUTO-RETURN
    HELP "Insira o nro do cheque a ser listado (sem digito) ou 0 p/ todos"
    WITH ROW 8 COLUMN 3 WIDTH 30 OVERLAY SIDE-LABELS NO-BOX FRAME f_nrcheque.

ON  ANY-KEY OF tel_tipos IN FRAME f_cheque
    DO:
        aux_nrdotipo = tel_tipos:INPUT-VALUE.
             
        IF (LASTKEY = KEYCODE("UP")    OR
            LASTKEY = KEYCODE("RIGHT"))  THEN
            DO:
                aux_nrdotipo = aux_nrdotipo + 1.
   
                IF  aux_nrdotipo > 5  THEN
                    aux_nrdotipo = 1.
   
                tel_tipos = aux_nrdotipo.
                           
                DISPLAY tel_tipos WITH FRAME f_cheque.
            END.
        ELSE
        IF (LASTKEY = KEYCODE("DOWN")   OR
            LASTKEY = KEYCODE("LEFT")) THEN
            DO:
                aux_nrdotipo = aux_nrdotipo - 1.
                
                IF  aux_nrdotipo < 1  THEN
                    aux_nrdotipo = 5.
   
                tel_tipos = aux_nrdotipo.
                           
                DISPLAY tel_tipos WITH FRAME f_cheque.
            END.
        ELSE
        IF  LASTKEY = KEYCODE("RETURN")  THEN
            DO:
                APPLY "VALUE-CHANGED" TO tel_tipos.
                APPLY "F1" TO tel_tipos.
            END.
        ELSE
        IF  LASTKEY = KEYCODE("F4")   THEN
            APPLY LASTKEY.
        ELSE
            RETURN NO-APPLY.
    END.


ON  ENTER OF tel_tipos IN FRAME f_cheque
    DO:
        APPLY "F1" TO SELF.
    END.


ON  ROW-DISPLAY OF b_crapfdc IN FRAME f_cheque
    DO: 

        IF  tt-cheques.dtemschq = ?   THEN
            ASSIGN tt-cheques.dtemschq:SCREEN-VALUE IN BROWSE b_crapfdc = "".
        IF  tt-cheques.dtretchq = ?   THEN
            ASSIGN tt-cheques.dtretchq:SCREEN-VALUE IN BROWSE b_crapfdc = "".
        IF  tt-cheques.dtliqchq = ?   THEN
            ASSIGN tt-cheques.dtliqchq:SCREEN-VALUE IN BROWSE b_crapfdc = "".

        ASSIGN tt-cheques.nrcheque:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.nrseqems:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.tpcheque:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.tpforchq:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.dsobserv:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.dtemschq:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.dtretchq:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.dtliqchq:DCOLOR IN BROWSE b_crapfdc = 0
               tt-cheques.nrdctitg:DCOLOR IN BROWSE b_crapfdc = 0.
        
        IF  tt-cheques.flgsubtd  THEN
            ASSIGN tt-cheques.nrcheque:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.nrseqems:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.tpcheque:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.tpforchq:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.dsobserv:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.dtemschq:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.dtretchq:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.dtliqchq:DCOLOR IN BROWSE b_crapfdc = 1
                   tt-cheques.nrdctitg:DCOLOR IN BROWSE b_crapfdc = 1.
    END.


ON  ENTER OF b_crapfdc IN FRAME f_cheque
    DO: 
        IF  AVAIL tt-cheques THEN
            DO:

                ASSIGN glb_nrchqcdv = INT(STRING(tt-cheques.nrcheque) +
                                          STRING(tt-cheques.nrdigchq)).
        
                DISPLAY tt-cheques.nrpedido
                        tt-cheques.dtsolped
                        tt-cheques.dtrecped
                        tt-cheques.dsdocmc7
                        tt-cheques.dscordem
                        tt-cheques.dscorde1
                        tt-cheques.dtmvtolt
                        tt-cheques.vlcheque
                        tt-cheques.cdtpdchq
                        tt-cheques.cdbandep  
                        tt-cheques.cdagedep  
                        tt-cheques.nrctadep 
                        tt-cheques.cdbantic
                        tt-cheques.cdagetic
                        tt-cheques.dtlibtic   
                        tt-cheques.cdageaco WITH FRAME f_detalhe.
               
                ENABLE btn_devolucoes WITH FRAME f_detalhe.
                APPLY "ENTRY" TO btn_devolucoes IN FRAME f_detalhe.
            END.
    END.
   
ON  CHOOSE OF btn_devolucoes IN FRAME f_detalhe
    DO: 
        HIDE FRAME f_detalhe.
    END.

ON  "F4" OF btn_devolucoes IN FRAME f_detalhe
    DO:
        HIDE FRAME f_detalhe.
        APPLY "ENTRY" TO b_crapfdc IN FRAME f_cheque.
        RETURN NO-APPLY.
    END.

/* .......................................................................... */

ASSIGN glb_cddopcao = "C".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.

PAUSE 0.

DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                    
        UPDATE tel_nrdconta WITH FRAME f_cheque
        
        EDITING:
        
            aux_stimeout = 0.
           
            DO WHILE TRUE:
           
                READKEY PAUSE 1.
                
                IF  LASTKEY = -1   THEN
                    DO:
                        aux_stimeout = aux_stimeout + 1.
                
                        IF  aux_stimeout > glb_stimeout   THEN
                            DO:
                                DELETE PROCEDURE h-b1wgen0040.
                                QUIT.
                            END.

                        NEXT.
                    END.
           
                APPLY LASTKEY.
           
                LEAVE.
        
            END.  /*  Fim do DO WHILE TRUE  */
        
        END.  /*  Fim do EDITING  */
 
        IF  aux_cddopcao <> glb_cddopcao   THEN
            DO:
                { includes/acesso.i}
                ASSIGN aux_cddopcao = glb_cddopcao.
            END.
   
        tel_qtrequis = 0.
       
        IF  tel_nrdconta > 0   THEN
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                    RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.

                ASSIGN aux_nrdconta = tel_nrdconta.

                RUN dig_fun IN h-b1wgen9999 
                            ( INPUT glb_cdcooper,
                              INPUT glb_cdagenci,
                              INPUT 0,
                              INPUT-OUTPUT aux_nrdconta,
                             OUTPUT TABLE tt-erro ).

                ASSIGN aux_nrdconta = 0.

                DELETE PROCEDURE h-b1wgen9999.

                IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                    DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.
                       
                        IF  AVAIL tt-erro  THEN
                            DO:
                                MESSAGE tt-erro.dscritic.
                                CLEAR FRAME f_cheque NO-PAUSE.
                                CLEAR FRAME f_lanctos ALL NO-PAUSE.
                                NEXT.
                            END.
                    END.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen0040) THEN
            RUN sistema/generico/procedures/b1wgen0040.p
                PERSISTENT SET h-b1wgen0040.

        RUN verifica-conta IN h-b1wgen0040
                           ( INPUT glb_cdcooper, 
                             INPUT glb_cdagenci, 
                             INPUT 0, 
                             INPUT glb_cdoperad, 
                             INPUT glb_nmdatela, 
                             INPUT 1, 
                             INPUT tel_nrdconta, 
                             INPUT 0, 
                             INPUT YES, 
                            OUTPUT par_nmprimtl, 
                            OUTPUT par_qtrequis, 
                            OUTPUT par_dsmsgcnt, 
                            OUTPUT TABLE tt-erro ).

        DELETE PROCEDURE h-b1wgen0040.

        IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                IF  AVAIL tt-erro  THEN
                    DO:
                        MESSAGE tt-erro.dscritic.
                        CLEAR FRAME f_cheque NO-PAUSE.
                        CLEAR FRAME f_lanctos ALL NO-PAUSE.
                        NEXT.
                    END.
            END.

        IF  par_dsmsgcnt <> ""  THEN
            DO:
                BELL.
                MESSAGE par_dsmsgcnt.
            END.

        DISPLAY par_nmprimtl @ tel_nmprimtl 
                par_qtrequis @ tel_qtrequis WITH FRAME f_cheque.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
            tel_tipos = 1.
           
            UPDATE tel_tipos WITH FRAME f_cheque.
           
            IF  tel_tipos = 5 THEN
                DO:
                    HIDE BROWSE b_crapfdc.
                    ASSIGN aux_nrcheque = 0.
                    UPDATE aux_nrcheque WITH FRAME f_nrcheque.
                    HIDE aux_nrcheque.
                END.

            IF  NOT VALID-HANDLE(h-b1wgen0040) THEN
                RUN sistema/generico/procedures/b1wgen0040.p
                    PERSISTENT SET h-b1wgen0040.
     
            RUN busca-cheques IN h-b1wgen0040
                              ( INPUT glb_cdcooper,     
                                INPUT glb_cdagenci,    
                                INPUT 0,    
                                INPUT glb_cdoperad,    
                                INPUT glb_nmdatela,    
                                INPUT 1,    
                                INPUT tel_nrdconta,    
                                INPUT 0,    
                                INPUT YES,    
                                INPUT tel_tipos,       
                                INPUT aux_nrcheque, 
                                INPUT 999999999,
                                INPUT 1,
                               OUTPUT aux_qtregist,
                               OUTPUT TABLE tt-erro,    
                               OUTPUT TABLE tt-cheques ).

            DELETE PROCEDURE h-b1wgen0040.

            IF  TEMP-TABLE tt-erro:HAS-RECORDS  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                   
                    IF  AVAIL tt-erro  THEN
                        DO:
                            MESSAGE tt-erro.dscritic.
                            CLEAR FRAME f_cheque NO-PAUSE.
                            CLEAR FRAME f_lanctos ALL NO-PAUSE.
                            NEXT.
                        END.
                END.


            OPEN QUERY q_crapfdc FOR EACH tt-cheques NO-LOCK.
         
            ENABLE b_crapfdc WITH FRAME f_cheque.
         
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
                UPDATE b_crapfdc WITH FRAME f_cheque.
                LEAVE.
         
            END.
            
            IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"  THEN
                DO:
                    DISABLE b_crapfdc WITH FRAME f_cheque.
                    LEAVE.
                END.
           
        END.  /*  Fim do DO WHILE TRUE  */
   
        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
            NEXT.
   
    END.  /*  Fim do DO WHILE TRUE  */
   
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  glb_nmdatela <> "CHEQUE"   THEN
                DO:
                    HIDE FRAME f_cheque.
                    HIDE FRAME f_lanctos.
                    HIDE FRAME f_moldura.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.
   
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */


