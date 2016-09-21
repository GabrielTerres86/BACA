/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | cadinf/consulta                        | IINF0001.pc_consulta_informativo                 |
  | cadinf/busca                           | IINF0001.pc_seleciona_informativo                |
  | cadinf/alteração                       | IINF0001.pc_altera_informativo                   |  
  | cadinf/inclusão                        | IINF0001.pc_inclui_informativo                   |   
  | cadinf/exclusão                        | IINF0001.pc_exclui_informativo                   |
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/* .............................................................................

   Programa: Fontes/cadinf.p  
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego    
   Data    : Junho/2006.                         Ultima atualizacao: 29/10/2015
          
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Controle de Informativos e Formas de Envio Aceitas
               pela Cooperativa.

   Alteracoes: 23/04/2007 - Alterado para buscar Forma de Envio da tabela
                            craptab (Diego).

               10/05/2007 - Incluida opcao "A" (Diego).
               
               16/05/2007 - Incluidos tratamentos nas opcoes "A" e "E" (Diego).
               
               27/06/2007 - Na opcao "A", verificar se informativo esta
                            disponivel a todos os titulares pela Central, antes
                            de alterar este parametro (Diego).
 
               18/11/2010 - Não permitir inserir um informativo inexistente 
                            quando a lista estiver vazia (Vitor).           
               
               11/01/2010 - Ajuste no FIND FIRST da mensagem da opcao "E":
                            Inserido condicao crabcra.cdperiod = 
                                              crapifc.cdperiod   (Irlan)
                                              
               16/04/2012 - Fonte substituido por cadinfp.p (Tiago).
               
               29/11/2013 - Inclusao de VALIDATE crapifc (Carlos)
               
               20/08/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
               
               29/10/2015 - Ajustes referente a conversao realizada pela DB1
                            (Adriano).
               
.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i }
{ sistema/generico/includes/gera_erro.i}

/* Variaveis para a regua de opcoes */
DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                            "Incluir",
                                            "Excluir"]                 NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","I","E"]               NO-UNDO.
                        
DEF VAR reg_contador AS INT           INIT 1                           NO-UNDO.

DEF VAR aux_dsdopcao AS CHAR FORMAT "x(10)" 
                             EXTENT 2 INIT ["Cancelar",
                                            "Concluir"]                NO-UNDO.
DEF VAR aux_cddopcao AS CHAR EXTENT 2 INIT ["N","S"]                   NO-UNDO.
DEF VAR aux_contador AS INT           INIT 1                           NO-UNDO.

DEF VAR tel_nmrelato AS CHAR     FORMAT "x(15)"                        NO-UNDO.
DEF VAR tel_dsfenvio AS CHAR     FORMAT "x(15)"                        NO-UNDO.
DEF VAR tel_dsperiod AS CHAR     FORMAT "x(15)"                        NO-UNDO.
DEF VAR tel_flgtitul AS LOGICAL  FORMAT "Sim/Nao"                      NO-UNDO.
DEF VAR tel_flgobrig AS LOGICAL  FORMAT "Sim/Nao"                      NO-UNDO.

DEF VAR aux_cdprogra AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR aux_cdrelato AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR aux_cdperiod AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR aux_cdfenvio AS INT      FORMAT "zz9"                          NO-UNDO.
DEF VAR aux_todostit LIKE gnfepri.envcpttl                             NO-UNDO.

DEF VAR aux_nrdlinha AS INT                                            NO-UNDO.
DEF VAR aux_confirma AS CHAR     FORMAT "!(1)"                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_flgexist AS LOGICAL  INIT FALSE                            NO-UNDO.

DEF VAR ant_flgtitul AS LOGICAL                                        NO-UNDO.

DEF VAR aux_nmdcampo AS CHAR                                           NO-UNDO.
DEF VAR aux_existcra AS INTEGER                                        NO-UNDO.
DEF VAR aux_fldelcra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_pedeconf AS LOGICAL                                        NO-UNDO.

/* Variaveis para o XML */ 
DEF VAR xDoc          AS HANDLE                                        NO-UNDO.   
DEF VAR xRoot         AS HANDLE                                        NO-UNDO.  
DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.  
DEF VAR xField        AS HANDLE                                        NO-UNDO. 
DEF VAR xText         AS HANDLE                                        NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO. 
DEF VAR aux_cont      AS INTEGER                                       NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR                                      NO-UNDO.

/* Cooperativa Dispoe */
DEF TEMP-TABLE w-cadinf                                                NO-UNDO
    FIELD cdprogra    AS INT      FORMAT "zz9"
    FIELD cdrelato    AS INT      FORMAT "zz9"
    FIELD cdfenvio    AS INT      FORMAT "99"
    FIELD cdperiod    AS INT      FORMAT "9"
    FIELD envcpttl    AS LOGI     FORMAT "Sim/Nao"
    FIELD envcobrg    AS LOGI     FORMAT "Sim/Nao"
    FIELD nmrelato    AS CHAR     FORMAT "x(15)"
    FIELD dsfenvio    AS CHAR     FORMAT "x(15)"
    FIELD dsperiod    AS CHAR     FORMAT "x(10)"
    FIELD existcra    AS INTEGER  FORMAT "9"
    FIELD todostit    LIKE gnfepri.envcpttl
    FIELD nrdrowid    AS ROWID.
    
/* CECRED Dispoe */ 
DEF TEMP-TABLE w-informa                                               NO-UNDO
    FIELD cdprogra    AS INT    FORMAT "zz9"
    FIELD cdrelato    AS INT    FORMAT "zz9"
    FIELD cdfenvio    AS INT    FORMAT "99"
    FIELD cdperiod    AS INT    FORMAT "9" 
    FIELD envcpttl    AS LOGI   FORMAT "Sim/Nao"
    FIELD nmrelato    AS CHAR   FORMAT "x(15)"
    FIELD dsfenvio    AS CHAR   FORMAT "x(15)"
    FIELD dsperiod    AS CHAR   FORMAT "x(10)".

/* Cooperativa Dispoe */
DEF QUERY q_informativos FOR w-cadinf.

DEF BROWSE b_informativos QUERY q_informativos
    DISPLAY w-cadinf.nmrelato   COLUMN-LABEL "Informativo"
            w-cadinf.dsfenvio   COLUMN-LABEL "Forma Envio"
            w-cadinf.dsperiod   COLUMN-LABEL "Periodo"
            w-cadinf.envcpttl   COLUMN-LABEL "Todos Titula."
            w-cadinf.envcobrg   COLUMN-LABEL "Envio Obrig."
            WITH 5 DOWN.

FORM b_informativos 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 7 COLUMN 3  WIDTH 76 OVERLAY NO-BOX FRAME f_browse.

/* CECRED Dispoe */
DEF QUERY q_informa FOR w-informa.

DEF BROWSE b_informa QUERY q_informa
    DISPLAY w-informa.nmrelato   COLUMN-LABEL "Informativo"
            w-informa.dsfenvio   COLUMN-LABEL "Forma Envio"
            w-informa.dsperiod   COLUMN-LABEL "Periodo"
            w-informa.envcpttl   COLUMN-LABEL "Todos Titulares"
            WITH 5 DOWN.

FORM b_informa 
     HELP "Pressione ENTER para INCLUIR / F4 ou END para sair."
     WITH ROW 8 CENTERED OVERLAY TITLE COLOR 
          MESSAGES "Informativos para Selecao"  FRAME f_informa.

FORM SKIP(1)
     "      Informativo:" tel_nmrelato  
     SKIP
     "      Forma Envio:" tel_dsfenvio
     SKIP 
     "          Periodo:" tel_dsperiod 
     SKIP
     "  Todos Titulares:" tel_flgtitul
                          HELP "Informe (S)im  ou  (N)ao."  SKIP
     "Envio Obrigatorio:" tel_flgobrig
                          HELP "Informe (S)im  ou  (N)ao."
     SKIP(1)
     WITH ROW 9 COLUMN 21 WIDTH 40 OVERLAY NO-LABEL TITLE COLOR 
     MESSAGE "INFORMATIVO E FORMA DE ENVIO"  FRAME f_inform.


FORM SKIP(10)
     reg_dsdopcao[1]  AT 19  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2]  AT 34  NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3]  AT 49  NO-LABEL FORMAT "x(7)"
     SKIP(1)
     WITH ROW 6 COLUMN 2 WIDTH 78 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     " INFORMATIVOS E FORMAS DE ENVIO DISPONIVEIS " FRAME f_regua.


FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.

/* Para Visualizar MESSAGE do F2 ao entrar na Tela */
ON VALUE-CHANGED, ENTRY OF b_informativos IN FRAME f_browse DO:

   RUN fontes/inicia.p.
       
END. 

ON ANY-KEY OF b_informativos IN FRAME f_browse DO:

   IF KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
      DO:
         ASSIGN reg_contador = reg_contador + 1.

         IF reg_contador > 3   THEN
            ASSIGN reg_contador = 1.
              
         ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].

      END.
   ELSE        
   IF KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
      DO:
          ASSIGN reg_contador = reg_contador - 1.

          IF reg_contador < 1   THEN
             ASSIGN reg_contador = 3.
               
          ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].

      END.
   ELSE
   IF KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
      DO:
         ASSIGN aux_existcra = 1.

         IF AVAILABLE w-cadinf   THEN
            DO:
               ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_informativos") 
                      aux_nrdrowid = w-cadinf.nrdrowid
                      aux_cdprogra = w-cadinf.cdprogra
                      aux_cdrelato = w-cadinf.cdrelato
                      aux_cdfenvio = w-cadinf.cdfenvio
                      aux_cdperiod = w-cadinf.cdperiod
                      aux_todostit = w-cadinf.todostit. /* gnfepri.envcpttl */

               /* Controle p/excluir relatorios vinculados ao informativo */
               IF glb_cddopcao = "E" THEN
                  ASSIGN aux_existcra = w-cadinf.existcra.
               ELSE 
                  ASSIGN aux_existcra = 1.
                      
               /*Desmarca todas as linhas do browse para poder remarcar*/
               b_informativos:DESELECT-ROWS().

            END.
         ELSE
            ASSIGN aux_nrdlinha = 0
                   aux_nrdrowid = ?.
              
         APPLY "GO".

      END.
   ELSE
   IF KEY-FUNCTION(LASTKEY) = "HELP"   THEN
      APPLY LASTKEY.
   ELSE
      RETURN.
                              
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua. 

END.

FORM "Codigo sendo utilizado. Ao exclui-lo"   SKIP
     " todos os cooperados perderao este  "   SKIP
     "            informativo.            "   SKIP(1)
     aux_dsdopcao[1]  AT 7  NO-LABEL 
     aux_dsdopcao[2]  AT 22  NO-LABEL 
     WITH CENTERED ROW 8 OVERLAY SIDE-LABELS TITLE COLOR NORMAL
     "Mensagem" FRAME f_mensagem.
     
/* Retorna  Inclusao  */    
ON RETURN OF b_informa
   DO:     
      IF AVAIL w-informa  THEN
         DO: 
            ASSIGN aux_cdprogra = w-informa.cdprogra
                   aux_cdrelato = w-informa.cdrelato
                   aux_cdfenvio = w-informa.cdfenvio
                   aux_cdperiod = w-informa.cdperiod
                   tel_nmrelato = w-informa.nmrelato
                   tel_dsfenvio = w-informa.dsfenvio
                   tel_dsperiod = w-informa.dsperiod
                   tel_flgtitul = w-informa.envcpttl.
      
            DISPLAY tel_nmrelato tel_dsfenvio tel_dsperiod
                    WITH FRAME f_inform.
            
            IF tel_flgtitul = TRUE  THEN
               UPDATE tel_flgtitul WITH FRAME f_inform.
            ELSE
               DISPLAY tel_flgtitul WITH FRAME f_inform.
                 
            UPDATE tel_flgobrig WITH FRAME f_inform.
         END. 

      APPLY "GO".
   END.

VIEW FRAME f_moldura.
PAUSE (0).  

DO WHILE TRUE: 
 
   ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].
   
   DISPLAY reg_dsdopcao WITH FRAME f_regua.
           
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.
   
   /* Buscar os informativos atraves da procedure Oracle */
   RUN Busca_Informativo.

   IF  RETURN-VALUE <> "OK" THEN
       NEXT.

   OPEN QUERY q_informativos FOR EACH w-cadinf NO-LOCK
                                 BY w-cadinf.cdprogra
                                 BY w-cadinf.nmrelato
                                 BY w-cadinf.dsfenvio.
                                         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      UPDATE b_informativos WITH FRAME f_browse. 
      LEAVE.
   END.
   
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      DO:
         RUN fontes/novatela.p.
         IF CAPS(glb_nmdatela) <> "CADINF"   THEN
            DO:
                HIDE FRAME f_regua.
                HIDE FRAME f_browse.
                RETURN.
            END.
         ELSE
            NEXT.

      END.
                         
   VIEW FRAME f_browse. 

   IF aux_nrdlinha > 0   THEN
      REPOSITION q_informativos TO ROW(aux_nrdlinha).
   
   { includes/acesso.i }

   CASE glb_cddopcao:
     WHEN "A" THEN /* --- ALTERACAO --- */
       DO: 
         /* Deve estar posicionado em alguma linha valida */
         IF aux_nrdlinha = 0 THEN
            NEXT.

         ASSIGN aux_flgexist = NO
                tel_flgtitul = w-cadinf.envcpttl
                tel_flgobrig = w-cadinf.envcobrg
                ant_flgtitul = tel_flgtitul
                tel_nmrelato = w-cadinf.nmrelato
                tel_dsfenvio = w-cadinf.dsfenvio
                tel_dsperiod = w-cadinf.dsperiod 
                aux_pedeconf = YES.

         DISPLAY tel_nmrelato 
                 tel_dsfenvio 
                 tel_dsperiod
                 WITH FRAME f_inform.
        
         /* Somente 1 titular */ 
         IF aux_todostit <> 0 THEN
            DO: 
               DISP tel_flgtitul WITH FRAME f_inform.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_flgobrig WITH FRAME f_inform.

                  LEAVE.

               END.

               IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
                  NEXT.
               
            END.
         ELSE
            DO:            
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_flgtitul tel_flgobrig 
                          WITH FRAME f_inform.

                  LEAVE.

               END.
               
               IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
                  NEXT.
               
               IF  ant_flgtitul <> tel_flgtitul AND
                  (ant_flgtitul = TRUE          AND 
                   tel_flgtitul = FALSE)        THEN
                   MESSAGE "Ao trocar a opcao (Todos Titulares)"
                           "para Nao, os" SKIP
                           "informativos atribuidos aos 2 titulares"
                           " serao" SKIP
                           "excluidos."  VIEW-AS ALERT-BOX.

            END.

         /* Pede a confirmacao */
         ASSIGN aux_confirma = "N".

         RUN Confirma.

         IF aux_confirma = "S" THEN 
            DO: 
               /* Realiza a alteracao do informativo */
               RUN Altera_Informativo.
              
               IF RETURN-VALUE <> "OK" THEN
                  NEXT.
                                       
            END.
         
       END.
     WHEN "I" THEN /* --- INCLUSAO --- */
       DO: 
         HIDE FRAME f_browse.

         /* Realiza a busca dos informativos no Oracle */
         RUN Seleciona_Informativo.

         IF RETURN-VALUE <> "OK" THEN
            NEXT.

         DO WHILE TRUE:

            ASSIGN tel_flgobrig = FALSE.

            OPEN QUERY q_informa FOR EACH w-informa NO-LOCK
                                     BY w-informa.cdprogra.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_informa WITH FRAME f_informa. 
               LEAVE.
            END.

            IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN /* F4 OU FIM */
               LEAVE. 

             IF NOT AVAIL w-informa THEN
                DO:
                   MESSAGE "ATENCAO!!! Nao ha informativo a ser incluido.".

                   PAUSE 3 NO-MESSAGE.
                   LEAVE.
                END.

             /* Pede a confirmacao */
             ASSIGN aux_confirma = "N".

             /* Solicita confirmacao */
             RUN Confirma.

             IF aux_confirma = "S"  THEN
                DO:
                   /* Realiza a inclusao do informativo no Oracle */
                   RUN Inclui_Informativo.

                   IF RETURN-VALUE <> "OK" THEN
                      NEXT.
                END.

             LEAVE.

         END. /* Do While */

       END.
     WHEN "E" THEN /* --- EXCLUSAO --- */
       DO:  
         /* Deve estar posicionado em alguma linha valida */
         IF  aux_nrdlinha = 0 THEN
             NEXT.

         /* Possui relatorio vinculado, Varre todos os informativos 
            iguais aeste que estejam sendo utilizados pelo cooperado */ 
         IF aux_existcra = 0 THEN 
            DO:
               DISPLAY aux_dsdopcao[1] aux_dsdopcao[2]
                       WITH FRAME f_mensagem.

               CHOOSE FIELD aux_dsdopcao[1] aux_dsdopcao[2]
                      WITH FRAME f_mensagem.

               IF FRAME-VALUE = aux_dsdopcao[2] THEN
                  ASSIGN aux_fldelcra = YES.
               ELSE 
                  ASSIGN aux_fldelcra = NO.

               IF FRAME-VALUE = aux_dsdopcao[1] THEN
                  NEXT.
            END.
         ELSE
            DO:
               /* Pede a confirmacao */
               ASSIGN aux_confirma = "N".
               
               /* Solicita confirmacao */
               RUN Confirma.
               
               IF aux_confirma = "N"  THEN
                  NEXT.
               
            END.

         /* Executa a rotina para excluir o informativo */
         RUN Exclui_Informativo ( INPUT aux_fldelcra ).
         
         IF RETURN-VALUE <> "OK" THEN
            NEXT.

       END.

   END CASE.
   
END.

/*................................ PROCEDURES ...............................*/

PROCEDURE Confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.

      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */
           
   IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR   
      aux_confirma <> "S"                THEN
      DO:
          ASSIGN glb_cdcritic = 79.
          RUN fontes/critic.p.
          ASSIGN glb_cdcritic = 0.
          BELL.
          MESSAGE glb_dscritic.
          PAUSE 2 NO-MESSAGE.
      END. /* Mensagem de confirmacao */

END PROCEDURE.  

/* ------------------------------------------------------------------------- */
/*                       PESQUISA/LISTA OS INFORMATIVOS                      */
/* ------------------------------------------------------------------------- */
PROCEDURE Busca_Informativo:

  EMPTY TEMP-TABLE w-cadinf.
  EMPTY TEMP-TABLE tt-erro.

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_consulta_informativo_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,  /*codigo da cooperativa*/
                                          INPUT 0, /*codigo da agencia*/
                                          INPUT 0, /*Numero do caixa*/
                                          INPUT 1, /*idorigem*/
                                          INPUT glb_cdoperad, /*codigo do operador*/
                                          INPUT glb_nmdatela, /*nome da tela*/
                                          INPUT glb_dtmvtolt, /*data do movimento*/
                                         OUTPUT "", /*Nome do Campo*/ 
                                         OUTPUT "", /*Saida OK/NOK*/
                                         OUTPUT ?, /*Tabela Cadinf*/ 
                                         OUTPUT 0, /*Codigo da critica*/ 
                                         OUTPUT ""). /*Descricao da critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_consulta_informativo_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  /* Busca possíveis erros */ 
  ASSIGN glb_cdcritic = 0
         glb_dscritic = ""
         aux_nmdcampo = ""
         glb_cdcritic = pc_consulta_informativo_car.pr_cdcritic 
                        WHEN pc_consulta_informativo_car.pr_cdcritic <> ?
         glb_dscritic = pc_consulta_informativo_car.pr_dscritic 
                        WHEN pc_consulta_informativo_car.pr_dscritic <> ?
         aux_nmdcampo = pc_consulta_informativo_car.pr_nmdcampo 
                        WHEN pc_consulta_informativo_car.pr_nmdcampo <> ?.  
  
  IF glb_cdcritic <> 0  OR glb_dscritic <> "" THEN
     DO:
        RUN gera_erro (INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,          /** Sequencia **/
                       INPUT glb_cdcritic,
                       INPUT-OUTPUT glb_dscritic).

        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        RETURN "NOK".
     END.

  /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
  para visualizacao dos registros na tela */

  /* Buscar o XML na tabela de retorno da procedure Progress */ 
  ASSIGN xml_req = pc_consulta_informativo_car.pr_clob_ret.

  /* Efetuar a leitura do XML*/ 
  SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
  PUT-STRING(ponteiro_xml,1) = xml_req. 

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe na tag xField */

  IF ponteiro_xml <> ? THEN
     DO:   
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).

        DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

           xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

           IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
              NEXT. 

           IF xRoot2:NUM-CHILDREN > 0 THEN
              DO:
                  CREATE w-cadinf.
              END.

           DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

              xRoot2:GET-CHILD(xField,aux_cont).

              IF xField:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 

              xField:GET-CHILD(xText,1).

              ASSIGN w-cadinf.cdprogra = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdprogra"
                     w-cadinf.cdrelato = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdrelato"
                     w-cadinf.cdfenvio = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdfenvio"
                     w-cadinf.cdperiod = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdperiod"
                     w-cadinf.nmrelato = xText:NODE-VALUE WHEN xField:NAME = "nmrelato"
                     w-cadinf.dsfenvio = xText:NODE-VALUE WHEN xField:NAME = "dsfenvio"
                     w-cadinf.dsperiod = xText:NODE-VALUE WHEN xField:NAME = "dsperiod"
                     w-cadinf.todostit = INT(xText:NODE-VALUE) WHEN xField:NAME = "todostit"
                     w-cadinf.existcra = INT(xText:NODE-VALUE) WHEN xField:NAME = "existcra".

              IF xField:NAME = "nrdrowid" THEN 
                 DO:
                    w-cadinf.nrdrowid = TO-ROWID(xText:NODE-VALUE).
                 END.

              IF xField:NAME = "envcpttl" THEN 
                 DO:
                    CASE xText:NODE-VALUE:
                        WHEN "0" THEN ASSIGN w-cadinf.envcpttl = YES.
                        WHEN "1" THEN ASSIGN w-cadinf.envcpttl = NO.
                        OTHERWISE ASSIGN w-cadinf.envcpttl = NO.
                    END CASE.
                 END.

              IF xField:NAME = "envcobrg" THEN 
                 DO:
                    CASE xText:NODE-VALUE:
                        WHEN "1" THEN ASSIGN w-cadinf.envcobrg = YES.
                        WHEN "0" THEN ASSIGN w-cadinf.envcobrg = NO.
                        OTHERWISE ASSIGN w-cadinf.envcobrg = NO.
                    END CASE.
                 END.
           END. 
        END.

        SET-SIZE(ponteiro_xml) = 0. 

     END.

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xRoot2. 
  DELETE OBJECT xField. 
  DELETE OBJECT xText. 

  RETURN "OK".

END PROCEDURE.

PROCEDURE Seleciona_Informativo:

  EMPTY TEMP-TABLE w-informa.
  EMPTY TEMP-TABLE tt-erro.

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_seleciona_informativo_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,  /*codigo da cooperativa*/    
                                          INPUT 0, /*codigo da agencia*/                    
                                          INPUT 0, /*Numero do caixa*/                      
                                          INPUT 1, /*idorigem*/                             
                                          INPUT glb_cdoperad, /*codigo do operador*/        
                                          INPUT glb_nmdatela, /*nome da tela*/              
                                          INPUT glb_dtmvtolt, /*data do movimento*/                          
                                         OUTPUT "", /*Nome do Campo*/             
                                         OUTPUT "", /*Saida OK/NOK*/                        
                                         OUTPUT ?, /*Tabela Cadinf*/                        
                                         OUTPUT 0, /*Codigo da critica*/                    
                                         OUTPUT ""). /*Descricao da critica*/               

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_seleciona_informativo_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  /* Busca possíveis erros */ 
  ASSIGN glb_cdcritic = 0
         glb_dscritic = ""
         aux_nmdcampo = ""   
         glb_cdcritic = pc_seleciona_informativo_car.pr_cdcritic 
                        WHEN pc_seleciona_informativo_car.pr_cdcritic <> ?
         glb_dscritic = pc_seleciona_informativo_car.pr_dscritic 
                        WHEN pc_seleciona_informativo_car.pr_dscritic <> ?
         aux_nmdcampo = pc_seleciona_informativo_car.pr_nmdcampo 
                        WHEN pc_seleciona_informativo_car.pr_nmdcampo <> ?.

         
  IF glb_cdcritic <> 0  OR glb_dscritic <> "" THEN
     DO:
        RUN gera_erro (INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,          /** Sequencia **/
                       INPUT glb_cdcritic,
                       INPUT-OUTPUT glb_dscritic).

        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        RETURN "NOK".
     END.

  /*Leitura do XML de retorno da proc e criacao dos registros na tt-contras
  para visualizacao dos registros na tela */

  /* Buscar o XML na tabela de retorno da procedure Progress */ 
  ASSIGN xml_req = pc_seleciona_informativo_car.pr_clob_ret.

  /* Efetuar a leitura do XML*/ 
  SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
  PUT-STRING(ponteiro_xml,1) = xml_req. 

  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe na tag xField */

  IF ponteiro_xml <> ? THEN
     DO:   
        xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
        xDoc:GET-DOCUMENT-ELEMENT(xRoot).

        DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

           xRoot:GET-CHILD(xRoot2,aux_cont_raiz).

           IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
              NEXT. 

           IF xRoot2:NUM-CHILDREN > 0 THEN
              DO:
                  CREATE w-informa.
              END.

           DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

              xRoot2:GET-CHILD(xField,aux_cont).

              IF xField:SUBTYPE <> "ELEMENT" THEN 
                 NEXT. 

              xField:GET-CHILD(xText,1).

              ASSIGN w-informa.cdprogra = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdprogra"
                     w-informa.cdrelato = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdrelato"
                     w-informa.cdfenvio = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdfenvio"
                     w-informa.cdperiod = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdperiod"
                     w-informa.nmrelato = xText:NODE-VALUE WHEN xField:NAME = "nmrelato"
                     w-informa.dsfenvio = xText:NODE-VALUE WHEN xField:NAME = "dsfenvio"
                     w-informa.dsperiod = xText:NODE-VALUE WHEN xField:NAME = "dsperiod".

              IF xField:NAME = "envcpttl" THEN 
                 DO:
                    CASE xText:NODE-VALUE:
                        WHEN "0" THEN ASSIGN w-informa.envcpttl = YES.
                        WHEN "1" THEN ASSIGN w-informa.envcpttl = NO.
                        OTHERWISE ASSIGN w-informa.envcpttl = NO.
                    END CASE.
                 END.
           END.      
        END.

        SET-SIZE(ponteiro_xml) = 0. 
     END.

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xRoot2. 
  DELETE OBJECT xField. 
  DELETE OBJECT xText. 

  RETURN "OK".

END PROCEDURE.
    
/* ------------------------------------------------------------------------- */
/*                          INSERIR  INFORMATIVO                             */
/* ------------------------------------------------------------------------- */
PROCEDURE Inclui_Informativo:

  EMPTY TEMP-TABLE tt-erro.

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */
  RUN STORED-PROCEDURE pc_inclui_informativo_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,  /*codigo da cooperativa*/    
                                          INPUT 0, /*codigo da agencia*/                    
                                          INPUT 0, /*Numero do caixa*/                      
                                          INPUT 1, /*idorigem*/                             
                                          INPUT glb_cdoperad, /*codigo do operador*/        
                                          INPUT glb_nmdatela, /*nome da tela*/              
                                          INPUT glb_dtmvtolt, /*data do movimento*/         
                                          INPUT aux_cdrelato, /*Cod.Informativo*/           
                                          INPUT aux_cdprogra, /*Cod.Programac*/             
                                          INPUT aux_cdfenvio, /*Cod.Forma envio*/           
                                          INPUT aux_cdperiod, /*Cod.Periodicid.*/           
                                          INPUT INT(tel_flgobrig), /*Obrigatório*/               
                                          INPUT (IF tel_flgtitul = TRUE THEN 
                                                    0 
                                                 ELSE 
                                                    1), /*Possui Titular*/     
                                         OUTPUT "", /*Nome do Campo*/                       
                                         OUTPUT "", /*Saida OK/NOK*/                        
                                         OUTPUT ?, /*Tabela Cadinf*/                        
                                         OUTPUT 0, /*Codigo da critica*/                    
                                         OUTPUT ""). /*Descricao da critica*/               

  /* Fechar o procedimento para buscarmos o resultado */
  CLOSE STORED-PROC pc_inclui_informativo_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  /* Busca possíveis erros */
  ASSIGN glb_cdcritic = 0
         glb_dscritic = ""
         tel_nmrelato = ""
         tel_dsfenvio = ""
         tel_dsperiod = ""
         tel_flgtitul = FALSE
         tel_flgobrig = FALSE
         aux_nmdcampo = ""
         glb_cdcritic = pc_inclui_informativo_car.pr_cdcritic
                        WHEN pc_inclui_informativo_car.pr_cdcritic <> ?
         glb_dscritic = pc_inclui_informativo_car.pr_dscritic
                        WHEN pc_inclui_informativo_car.pr_dscritic <> ?
         aux_nmdcampo = pc_inclui_informativo_car.pr_nmdcampo
                        WHEN pc_inclui_informativo_car.pr_nmdcampo <> ?.

  IF glb_cdcritic <> 0  OR glb_dscritic <> "" THEN
     DO:
        RUN gera_erro (INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,          /** Sequencia **/
                       INPUT glb_cdcritic,
                       INPUT-OUTPUT glb_dscritic).

        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        RETURN "NOK".
     END.

  RETURN "OK".

END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*                          ALTERA OS INFORMATIVOS                           */
/* ------------------------------------------------------------------------- */
PROCEDURE Altera_Informativo:
  
  EMPTY TEMP-TABLE tt-erro.
  
  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */ 
  RUN STORED-PROCEDURE pc_altera_informativo_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,  /*codigo da cooperativa*/    
                                          INPUT 0, /*codigo da agencia*/
                                          INPUT 0, /*Numero do caixa*/
                                          INPUT 1, /*idorigem*/
                                          INPUT glb_cdoperad, /*codigo do operador*/
                                          INPUT glb_nmdatela, /*nome da tela*/
                                          INPUT glb_dtmvtolt, /*data do movimento*/
                                          INPUT aux_cdrelato, /*Cod.Informativo*/
                                          INPUT aux_cdprogra, /*Cod.Programac*/
                                          INPUT aux_cdfenvio, /*Cod.Forma envio*/
                                          INPUT aux_cdperiod, /*Cod.Periodicid.*/
                                          INPUT (IF tel_flgtitul = TRUE THEN 
                                                    0 
                                                 ELSE 
                                                    1), /*Possui Titular*/
                                          INPUT INT(tel_flgobrig), /*Obrigatorio*/
                                         OUTPUT "", /*Nome do Campo*/
                                         OUTPUT "", /*Saida OK/NOK*/
                                         OUTPUT ?, /*Tabela Cadinf*/
                                         OUTPUT 0, /*Codigo da critica*/
                                         OUTPUT ""). /*Descricao da critica*/

  /* Fechar o procedimento para buscarmos o resultado */ 
  CLOSE STORED-PROC pc_altera_informativo_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

  /* Busca possíveis erros */ 
  ASSIGN glb_cdcritic = 0
         glb_dscritic = ""
         tel_nmrelato = ""
         tel_dsfenvio = ""
         tel_dsperiod = ""
         tel_flgtitul = FALSE
         tel_flgobrig = FALSE
         aux_nmdcampo = ""
         glb_cdcritic = pc_altera_informativo_car.pr_cdcritic
                        WHEN pc_altera_informativo_car.pr_cdcritic <> ?
         glb_dscritic = pc_altera_informativo_car.pr_dscritic
                        WHEN pc_altera_informativo_car.pr_dscritic <> ?
         aux_nmdcampo = pc_altera_informativo_car.pr_nmdcampo 
                        WHEN pc_altera_informativo_car.pr_nmdcampo <> ?.
    
  IF glb_cdcritic <> 0  OR glb_dscritic <> "" THEN
     DO: 
        RUN gera_erro (INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,          /** Sequencia **/
                       INPUT glb_cdcritic,
                       INPUT-OUTPUT glb_dscritic).

        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        RETURN "NOK".
     END.

  RETURN "OK".

END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*                           EXCLUIR INFORMATIVO                             */
/* ------------------------------------------------------------------------- */
PROCEDURE Exclui_Informativo:

  DEFINE INPUT  PARAMETER par_fldelcra AS LOGICAL                    NO-UNDO.

  EMPTY TEMP-TABLE tt-erro.

  { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

  /* Efetuar a chamada da rotina Oracle */
  RUN STORED-PROCEDURE pc_exclui_informativo_car
      aux_handproc = PROC-HANDLE NO-ERROR(INPUT glb_cdcooper,  /*codigo da cooperativa*/
                                          INPUT 0, /*codigo da agencia*/
                                          INPUT 0, /*Numero do caixa*/
                                          INPUT 1, /*idorigem*/
                                          INPUT glb_cdoperad, /*codigo do operador*/
                                          INPUT glb_nmdatela, /*nome da tela*/
                                          INPUT glb_dtmvtolt, /*data do movimento*/
                                          INPUT aux_cdrelato, /*Cod.Informativo*/
                                          INPUT aux_cdprogra, /*Cod.Programac*/  
                                          INPUT aux_cdfenvio, /*Cod.Forma envio*/
                                          INPUT aux_cdperiod, /*Cod.Periodicid.*/
                                          INPUT INT(par_fldelcra),
                                         OUTPUT "", /*Nome do campo*/
                                         OUTPUT "", /*Saida OK/NOK*/
                                         OUTPUT ?, /*Tabela Cadinf*/
                                         OUTPUT 0, /*Codigo da critica*/
                                         OUTPUT ""). /*Descricao da critica*/

  /* Fechar o procedimento para buscarmos o resultado */
  CLOSE STORED-PROC pc_exclui_informativo_car
         aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

  /* Busca possíveis erros */
  ASSIGN glb_cdcritic = 0
         glb_dscritic = ""
         aux_nmdcampo = ""
         glb_cdcritic = pc_exclui_informativo_car.pr_cdcritic
                        WHEN pc_exclui_informativo_car.pr_cdcritic <> ?
         glb_dscritic = pc_exclui_informativo_car.pr_dscritic
                        WHEN pc_exclui_informativo_car.pr_dscritic <> ?
         aux_nmdcampo = pc_exclui_informativo_car.pr_nmdcampo
                        WHEN pc_exclui_informativo_car.pr_nmdcampo <> ?.

  IF glb_cdcritic <> 0  OR glb_dscritic <> "" THEN
     DO:
        RUN gera_erro (INPUT glb_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1,          /** Sequencia **/
                       INPUT glb_cdcritic,
                       INPUT-OUTPUT glb_dscritic).

        MESSAGE glb_dscritic.
        PAUSE 3 NO-MESSAGE.
        RETURN "NOK".
     END.

  RETURN "OK".

END PROCEDURE.

/*...........................................................................*/
