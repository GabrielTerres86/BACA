/* .............................................................................

   Programa: Fontes/resgat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Dezembro/94.                        Ultima atualizacao: 06/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar os resgates de RDA da tela RESGAT.

   Alteracoes: 27/03/95 - Alterado para tratar tpresgat igual a 5 (Deborah).

               25/03/96 - Alterado para incluir procedimentos para  poupanca
                          programada (Odair).

               03/12/96 - Tratar RDCA2 (Odair).

               08/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               16/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

             25/06/2001 - Permitir que o usuario solicite o resgate de 
                          poupanca programadas. (Ze Eduardo).

             11/04/2002 - Mostrar resgates estornados e cancelados (Margarete).

             31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

             17/10/2006 - Arrumado posiconado dos dados da consulta (Elton).
             
             06/02/2015 - Leitura de resgates de novas aplicacoes
                          e nova implementação para exibicao dos
                          dados, projeto Novos Produtos de Captacao
                          (Jean Michel).
             
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0081tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR tel_nrdconta  AS INT     FORMAT "zzzz,zzz,9" NO-UNDO.
DEF VAR tel_nmprimtl  AS CHAR    FORMAT "x(40)"      NO-UNDO.
DEF VAR tel_tpaplica  AS CHAR    FORMAT "x(06)"      NO-UNDO.

DEF VAR aux_contador  AS INT     FORMAT "99"         NO-UNDO.
DEF VAR aux_stimeout  AS INT                         NO-UNDO.
DEF VAR aux_nrdlinha  AS INT                         NO-UNDO.

DEF VAR aux_flgretor  AS LOGICAL                     NO-UNDO.

DEF VAR aux_cddopcao  AS CHAR                        NO-UNDO.

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                      NO-UNDO.   
DEF VAR xRoot         AS HANDLE                      NO-UNDO.  
DEF VAR xRoot2        AS HANDLE                      NO-UNDO.  
DEF VAR xField        AS HANDLE                      NO-UNDO. 
DEF VAR xText         AS HANDLE                      NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER                     NO-UNDO. 
DEF VAR aux_cont      AS INTEGER                     NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR                      NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR                    NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

DEF QUERY q_resgates FOR tt-resg-aplica.

DEF BROWSE b_resgates QUERY q_resgates
    DISP tt-resg-aplica.dtresgat LABEL "Resgate"  FORMAT "99/99/9999"
         tt-resg-aplica.nraplica LABEL "Aplic."   FORMAT "zzzzz9"
         tt-resg-aplica.tpresgat LABEL "Tp.A."    FORMAT "x(12)"
         tt-resg-aplica.vllanmto LABEL "Valor"    FORMAT "zzz,zzz,zz9.99"
         tt-resg-aplica.nrdocmto LABEL "Docmto"   FORMAT "zzz,zz9"
         tt-resg-aplica.nmoperad LABEL "Operador" FORMAT "x(8)"
         tt-resg-aplica.sitresga LABEL "ST"       FORMAT "x(2)"
         tt-resg-aplica.hrtransa LABEL "Hora"     FORMAT "x(5)"
         WITH NO-LABEL NO-BOX 9 DOWN.

FORM tel_nrdconta AT  3 LABEL "Conta/dv" AUTO-RETURN
                        HELP "Informe o numero da conta do associado"
     tel_nmprimtl AT 27 LABEL "Titular"
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY FRAME f_resgat.         

FORM b_resgates
     HELP "Use as SETAS para navegar e <F4> para sair" 
     WITH ROW 8 CENTERED OVERLAY  FRAME f_resgates TITLE "Resgates".

glb_cddopcao = "C".

DO WHILE TRUE:
    VIEW FRAME f_moldura.

    PAUSE(0).

    RUN fontes/inicia.p.
    
    HIDE FRAME f_resgates.
    CLEAR FRAME f_resgat.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      HIDE FRAME f_resgates.

      UPDATE tel_nrdconta WITH FRAME f_resgat
                                              
      EDITING:
    
         aux_stimeout = 0.
    
         DO WHILE TRUE:
    
            READKEY PAUSE 1.
    
            IF LASTKEY = -1   THEN
              DO:
                aux_stimeout = aux_stimeout + 1.
    
                IF aux_stimeout > glb_stimeout THEN
                  QUIT.
    
                NEXT.
              END.
    
            APPLY LASTKEY.
    
            LEAVE.
    
         END.  /*  Fim do DO WHILE TRUE  */
    
      END.  /*  Fim do EDITING  */
    
      glb_nrcalcul = tel_nrdconta.
      RUN fontes/digfun.p.
    
      IF NOT glb_stsnrcal   THEN
        DO:
          glb_cdcritic = 8.
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          CLEAR FRAME f_resgat NO-PAUSE.
          NEXT-PROMPT tel_nrdconta WITH FRAME f_resgat.
          glb_cdcritic = 0.
          NEXT.
        END.

      LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */

    IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
      DO:
                
        RUN fontes/novatela.p.

        IF glb_nmdatela <> "RESGAT" THEN
          DO:
            HIDE FRAME f_resgat.
            CLEAR FRAME f_resgat.
            RETURN.
          END.
        ELSE
          NEXT. 
          
      END.

    IF aux_cddopcao <> glb_cddopcao   THEN
     DO:
       { includes/acesso.i}
       aux_cddopcao = glb_cddopcao.
     END.
    
    FIND crapass WHERE crapass.cdcooper = glb_cdcooper   AND 
                       crapass.nrdconta = tel_nrdconta   NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE crapass   THEN
     DO:
       glb_cdcritic = 9.
       RUN fontes/critic.p.
       BELL.
       MESSAGE glb_dscritic.
       CLEAR FRAME f_resgat  NO-PAUSE.
       NEXT-PROMPT tel_nrdconta WITH FRAME f_resgat.
       glb_cdcritic = 0.
       NEXT.
     END.

    tel_nmprimtl = crapass.nmprimtl.
    
    ASSIGN aux_contador = 0
           aux_flgretor = FALSE.
    
    DISPLAY tel_nmprimtl WITH FRAME f_resgat.
    
    RUN carrega_dados.

    OPEN QUERY q_resgates FOR EACH tt-resg-aplica NO-LOCK.
    
    UPDATE b_resgates WITH FRAME f_resgates.

    IF aux_nrdlinha > 0 THEN
      DO: 
          IF  aux_nrdlinha > NUM-RESULTS("q_resgates")  THEN
              ASSIGN aux_nrdlinha = NUM-RESULTS("q_resgates").
    
          REPOSITION q_resgates TO ROW(aux_nrdlinha).
      END.

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE carrega_dados:

    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} } 
    
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_consulta_resgates_car
     aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper, /* Código da Cooperativa */
                                         INPUT 1,            /* Codigo de agencia */
                                         INPUT 1,            /* Numero de caixa */
                                         INPUT glb_cdoperad, /* Codigo do operador */
                                         INPUT glb_nmdatela, /* Nome da tela */
                                         INPUT 1,            /* Origem da transacao */
                                         INPUT 1,            /* Sequencial do titular */
                                         INPUT tel_nrdconta, /* Número da Conta */
                                         INPUT glb_dtmvtolt, /* Data de Movimento */
                                         INPUT 0,            /* Numero da Aplicacao */
                                         INPUT 1,            /* Indicador de opcao (Cancelamento/Proximo) */
                                         INPUT 0,            /* Gravar log */
                                        OUTPUT ?,            /* XML com informações de LOG */
                                        OUTPUT 0,            /* Código da crítica */
                                        OUTPUT "").          /* Descrição da crítica */
    
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_consulta_resgates_car
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} } 
    
    /* Busca possíveis erros */ 
    ASSIGN glb_cdcritic = pc_consulta_resgates_car.pr_cdcritic.
    ASSIGN glb_dscritic = pc_consulta_resgates_car.pr_dscritic.
    
    HIDE MESSAGE NO-PAUSE.
                                                        
    /* Verifica se ocorreu alguma critica na consulta */
    IF glb_dscritic <> ? THEN
     DO:         
       BELL.
       MESSAGE glb_dscritic.
       PAUSE 3 NO-MESSAGE.
       HIDE MESSAGE NO-PAUSE.
       RETURN NO-APPLY.
     END.
    
    EMPTY TEMP-TABLE tt-resg-aplica.
    
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_consulta_resgates_car.pr_clobxmlc. 
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    IF ponteiro_xml <> ? THEN
      DO:
        
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).
    
        DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
    
          xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
    
          IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
            NEXT. 
                    
          IF xRoot2:NUM-CHILDREN > 0 THEN
            CREATE tt-resg-aplica.
           
          DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
                
            xRoot2:GET-CHILD(xField,aux_cont).
                    
            IF xField:SUBTYPE <> "ELEMENT" THEN 
              NEXT. 
                
            xField:GET-CHILD(xText,1).
    
            ASSIGN tt-resg-aplica.nraplica =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nraplica".
            ASSIGN tt-resg-aplica.dtresgat = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtresgat".
            ASSIGN tt-resg-aplica.nrdocmto =  INT(xText:NODE-VALUE) WHEN xField:NAME = "nrdocmto".
            ASSIGN tt-resg-aplica.tpresgat =      xText:NODE-VALUE  WHEN xField:NAME = "tpresgat".
            ASSIGN tt-resg-aplica.sitresga =      xText:NODE-VALUE  WHEN xField:NAME = "dsresgat".
            ASSIGN tt-resg-aplica.nmoperad =      xText:NODE-VALUE  WHEN xField:NAME = "nmoperad".
            ASSIGN tt-resg-aplica.hrtransa =      xText:NODE-VALUE  WHEN xField:NAME = "hrtransa".
            ASSIGN tt-resg-aplica.vllanmto =  DEC(xText:NODE-VALUE) WHEN xField:NAME = "vllanmto".
            
          END. 
            
        END.
    
      SET-SIZE(ponteiro_xml) = 0. 
    END.
    
    DELETE OBJECT xDoc. 
    DELETE OBJECT xRoot. 
    DELETE OBJECT xRoot2. 
    DELETE OBJECT xField. 
    DELETE OBJECT xText.
    /* Fim leitura do XML */
    
    RETURN "OK".

END PROCEDURE.
/* .......................................................................... */
