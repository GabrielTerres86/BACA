/* .............................................................................

   Programa: Fontes/impetj.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Agosto/2000  

   Dados referentes ao programa:                 Ultima Alteracao : 24/04/2009

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPETJ.

   Alteracoes: 30/10/2000 - Ajuste para impressoras N40 (Deborah).

               27/06/2001 - Imprimir para o PAC 15 (Deborah).
               
               09/07/2002 - Imprimir somente Selecao de contas (Ze Eduardo).
               
               05/08/2002 - Incluir agencia na secao de extrato (Ze Eduardo).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               31/10/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               24/04/2009 - Acertar logica de FOR EACH que utiliza OR (David).
               
               12/11/2011 - Incluido format de 40 para o campo nmprimtl
                            (Kbase - Gilnei)
............................................................................. */

DEF STREAM str_1.     

{ includes/var_online.i }

DEF       TEMP-TABLE cratass                                         NO-UNDO
          FIELD nrdconta  AS  INT    FORMAT "zzzz,zz9,9"
          INDEX cratass1  nrdconta.

DEF        VAR rel_nmresage     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmresemp     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmrelato     AS CHAR    FORMAT "x(40)" EXTENT 5   NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_inexecut AS CHAR    FORMAT "x(1)"                 NO-UNDO.
DEF        VAR aux_inseleca AS CHAR    FORMAT "x(1)"                 NO-UNDO.

DEF        VAR aux_incontad AS INT                                   NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqsai AS CHAR INIT "rl/crrl245.lst"            NO-UNDO.
DEF        VAR aux_cdsecext AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqetq AS INT                                   NO-UNDO.

DEF        VAR aux_cdempres AS INT  FORMAT "zzzz9"                   NO-UNDO.

DEF        VAR aux_fieldlcc AS CHAR FORMAT "x(07)" 
               VIEW-AS FILL-IN                                       NO-UNDO.

DEF        VAR aux_listadcc AS CHAR 
               VIEW-AS SELECTION-LIST MULTIPLE INNER-CHARS 30
               INNER-LINES 5 SCROLLBAR-VERTICAL                      NO-UNDO.
    
DEF        BUTTON aux_butnsair  LABEL "Finalizar".
                      
DEF        FRAME  f_inserir_conta   
                  SKIP(2)
                  aux_fieldlcc         AT  30  LABEL "Digite a Conta"
                  HELP "Utiliza o <TAB> para navegar ou <END> para sair"
                  SKIP(1)
                  aux_listadcc         AT  24  NO-LABEL
                  HELP "Selecione uma Conta para Excluir"
                  SKIP(1)
                  aux_butnsair         AT  35
                  HELP "Tecle <ENTER> para finalizar o cadastro"
                  SKIP(3)
                  WITH SIDE-LABELS TITLE glb_tldatela
                  OVERLAY WIDTH 80 CENTERED.

FORM "PARA:"           AT 86  SKIP(1)
      crapass.nmprimtl AT 86  FORMAT "x(40)" SKIP(1)
      crapass.cdagenci AT 86  FORMAT "999"
      "/"
      crapass.nrdconta        FORMAT "9999,999,9"
      crapemp.nmresemp AT 111 FORMAT "x(15)"  SKIP
      aux_cdsecext     AT 86  FORMAT "999"
      " - "
      crapdes.nmsecext        FORMAT "x(25)"
      aux_nrseqetq     AT 122 FORMAT "z,zz9"
      WITH NO-BOX NO-ATTR-SPACE NO-LABEL DOWN WIDTH 132 FRAME f_etiqueta.

FORM SPACE(1)
     WITH ROW 4  OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(6)
     "Todos os associados ou informar Selecao:" AT 10
     aux_inseleca NO-LABEL 
                  HELP "Entre com T(odos) ou S(elecao)."
     SKIP(9)
     WITH SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_selecao.

FORM SKIP(6)
     "Confirme a personalizacao do Informativo:" AT 20
     aux_inexecut NO-LABEL 
                  HELP "Entre com S ou N"
     SKIP(9)
     WITH SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_executa.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_nrdevias = 0.

PAUSE(0).

RUN fontes/inicia.p.

ASSIGN glb_cdcritic    = 0
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 245.

{ includes/cabrel132_1.i }

DO WHILE TRUE:

   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
         END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "IMPETJ"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <>  glb_cddopcao THEN
        DO:
            { includes/acesso.i }
        END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        NEXT.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      ASSIGN aux_inseleca = "T".
      
      UPDATE aux_inseleca WITH FRAME f_selecao.
      
      IF   aux_inseleca = "S"  THEN
           DO: 
               ON   DEFAULT-ACTION OF aux_listadcc
                    aux_listadcc:DELETE(aux_listadcc:SCREEN-VALUE).
   
               ON   RETURN OF aux_fieldlcc 
                    DO:
                        FIND crapass WHERE 
                             crapass.cdcooper = glb_cdcooper AND
                             crapass.nrdconta = INT(aux_fieldlcc:SCREEN-VALUE) 
                             NO-LOCK NO-ERROR.

                        IF   NOT AVAILABLE crapass THEN
                             DO:
                                 glb_cdcritic = 009.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 PAUSE 5 NO-MESSAGE.
                             END.
                        ELSE 
                             DO:
                                 aux_listadcc:ADD-FIRST(
                                               aux_fieldlcc:SCREEN-VALUE).
                                 aux_fieldlcc:SCREEN-VALUE = "".
                             END.
     
                        aux_fieldlcc:CURSOR-OFFSET = 1.
                        RETURN NO-APPLY.
                    END.
   
               ENABLE ALL WITH FRAME f_inserir_conta.
               WAIT-FOR CHOOSE OF aux_butnsair.

               IF   (aux_listadcc:LIST-ITEMS <> ?) THEN
                    DO:
                        aux_inexecut = "S".
                        
                        DO   aux_incontad = 1 TO
                             NUM-ENTRIES(aux_listadcc:LIST-ITEMS,","):
                             CREATE cratass.
                             ASSIGN cratass.nrdconta = INTEGER(
                              ENTRY(aux_incontad,aux_listadcc:LIST-ITEMS,",")).
                        END.
                           
                    END.
                        
           END.  /*  If  selecao de contas   */
      ELSE
           DO:
               ASSIGN aux_inexecut = "N".
      
               UPDATE aux_inexecut WITH FRAME f_executa.
            END.

      IF   aux_inexecut = "S"  THEN
           DO: 

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
              ASSIGN aux_confirma = "N"
                     glb_cdcritic = 78.

              RUN fontes/critic.p.
              BELL.
              MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
              glb_cdcritic = 0.
              LEAVE.
                     
           END.

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR aux_confirma <> "S" THEN
                DO:
                    ASSIGN glb_cdcritic = 79.
                    LEAVE.
                END.

           MESSAGE "Aguarde a geracao...".
           
           OUTPUT STREAM str_1 TO VALUE(aux_nmarqsai) PAGED PAGE-SIZE 80.

           FOR EACH crapass WHERE (crapass.cdcooper = glb_cdcooper AND 
                                   crapass.dtdemiss = ?            AND
                                   crapass.cdsitdct = 1            AND
                                   aux_inseleca     = "T")         OR
                                  (crapass.cdcooper = glb_cdcooper AND
                                   aux_inseleca     = "S"          AND
                                   CAN-FIND(cratass WHERE 
                                       cratass.nrdconta = crapass.nrdconta))
                                   NO-LOCK:

               IF   crapass.inpessoa = 1   THEN 
                    DO:
                        FIND crapttl WHERE 
                             crapttl.cdcooper = glb_cdcooper       AND
                             crapttl.nrdconta = crapass.nrdconta   AND
                             crapttl.idseqttl = 1 NO-LOCK NO-ERROR.
                        
                        IF   AVAIL crapttl  THEN
                             ASSIGN aux_cdempres = crapttl.cdempres.
                    END.
               ELSE
                    DO:
                        FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper  AND
                                           crapjur.nrdconta = crapass.nrdconta
                                           NO-LOCK NO-ERROR.
                
                        IF   AVAIL crapjur  THEN
                             ASSIGN aux_cdempres = crapjur.cdempres.
                    END.

               IF   glb_cdcooper = 1   THEN
                    IF  NOT ((crapass.cdagenci = 9)  OR 
                            (crapass.cdagenci = 15) OR
                            (CAN-DO("1,8",STRING(crapass.cdagenci)) AND
                             CAN-DO("999,102,121,818",
                             STRING(crapass.cdsecext))))   THEN
                             NEXT.

               FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper AND
                                  crapemp.cdempres = aux_cdempres 
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapemp THEN
                    DO:
                        MESSAGE "Empresa nao cadastrada" aux_cdempres.
                        BELL.
                        RETURN.
                    END.
         
               IF   crapass.cdsecext = 0 THEN
                    aux_cdsecext = 999.
               ELSE
                    aux_cdsecext = crapass.cdsecext.
 
               FIND crapdes WHERE crapdes.cdcooper = glb_cdcooper     AND
                                  crapdes.cdagenci = crapass.cdagenci AND 
                                  crapdes.cdsecext = aux_cdsecext 
                                  USE-INDEX crapdes1 NO-LOCK NO-ERROR.

               IF   NOT AVAILABLE crapdes THEN
                    DO:
                        MESSAGE "Destino de extrato nao cadastrado"
                                crapass.cdsecext.
                        BELL.
                        RETURN.
                    END.

               aux_nrseqetq = aux_nrseqetq + 1.
       
               DISPLAY STREAM str_1 crapass.nmprimtl crapass.cdagenci 
                                    crapass.nrdconta crapemp.nmresemp
                                    aux_cdsecext     crapdes.nmsecext
                                    aux_nrseqetq WITH FRAME f_etiqueta.
               
               PAGE STREAM str_1.
                
           END.  /*  Fim do FOR EACH -- Leitura do ASS */
  
           OUTPUT STREAM str_1 CLOSE.

           ASSIGN glb_nmarqimp = "rl/crrl245.lst"
                  glb_nmformul = "jornal".

           HIDE MESSAGE NO-PAUSE.
           
           MESSAGE "Solicite a impressao ao CPD...". 
           PAUSE 8  NO-MESSAGE.

           RUN fontes/imprim.p.

           LEAVE.
           
           END.
   END.
           
END.

/* ......................................................................... */

