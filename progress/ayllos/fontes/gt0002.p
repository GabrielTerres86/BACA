/* .............................................................................

   Programa: Fontes/gt0002.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                     Ultima Atualizacao: 22/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Relacionar Convenios as Cooperativas
   
   Alteracoes: 03/03/2009 - Permitir somente operador 799 ou 1 nas
                            opcoes I,E.   (Fernando).
                            
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               16/04/2012 - Fonte substituido por gt0002p.p (Tiago).
               
               23/04/2012 - Incluido o departamento "COMPE" na validacao dos
                            departamentos (Adriano).
               
               22/06/2012 - Substituido gncoper por crapcop (Tiago).          
               
               19/09/2013 - Adaptar fonte para BO. (Gabriel Capoia - DB1)
............................................................................. */

{ includes/var_online.i  } 
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0176tt.i }

DEF        VAR tel_nmrescop    LIKE crapcop.nmrescop                 NO-UNDO.   
DEF        VAR tel_cdconven    LIKE gncvcop.cdconven                 NO-UNDO.
DEF        VAR tel_cdcooper    LIKE gncvcop.cdcooper                 NO-UNDO.
DEF        VAR tel_nmempres    LIKE gnconve.nmempres                 NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmdcampo AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtregist AS INTE                                  NO-UNDO.
DEF        VAR h-b1wgen0176 AS HANDLE                                NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM "Opcao:"       AT 6
     glb_cddopcao   AUTO-RETURN
                  HELP "Entre com a opcao desejada"
                  VALIDATE (glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")
     SKIP (2)
     tel_cdcooper    AT 11  LABEL "Cooperativa"
                            HELP "Informe Codigo Cooperativa"
     tel_nmrescop    AT 41  LABEL "Nome"
     SKIP (1)
     tel_cdconven    AT 11  LABEL "Cod.Convenio"
                            HELP "Informe Nro Convenio"
     tel_nmempres    AT 41  LABEL "Nome Convenio"
     WITH  NO-LABELS /*TITLE " Manutencao Convenios "*/
     ROW 6 OVERLAY COLUMN 2 FRAME f_convenio NO-BOX SIDE-LABELS PFCOLOR 0.


/* variaveis para mostrar a consulta */          
 
DEF QUERY bgncvcopq FOR tt-gt0002.

DEF BROWSE bgncvcop-b QUERY bgncvcopq
      DISP SPACE(5)
           tt-gt0002.cdcooper                COLUMN-LABEL "Coop."
           SPACE(2)
           tt-gt0002.nmrescop FORMAT "x(11)" COLUMN-LABEL "Nome"
           SPACE(2)
           tt-gt0002.cdconven                COLUMN-LABEL "Convenio"
           SPACE(2)                          
           tt-gt0002.nmempres FORMAT "x(17)" COLUMN-LABEL "Nome"
           SPACE(2)                          
           tt-gt0002.cdcooped                COLUMN-LABEL "Coop.Dominio"
           WITH 9 DOWN OVERLAY.    

DEF FRAME f_convenioc
          bgncvcop-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

/**********************************************/



glb_cddopcao = "C".

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_convenio.

ASSIGN tel_cdcooper = 0
       tel_cdconven = 0.

RUN fontes/inicia.p.

DO WHILE TRUE:
    
    DISPLAY glb_cddopcao WITH FRAME f_convenio.

    NEXT-PROMPT tel_cdcooper WITH FRAME f_convenio.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        UPDATE glb_cddopcao tel_cdcooper
               tel_cdconven  WITH FRAME f_convenio
        EDITING:

            READKEY.
            APPLY LASTKEY.

            HIDE MESSAGE NO-PAUSE.

            IF  GO-PENDING THEN
                DO:
                    RUN Busca_Dados.

                    IF  RETURN-VALUE <> "OK" THEN
                        DO:
                            {sistema/generico/includes/foco_campo.i
                                    &VAR-GERAL=SIM
                                    &NOME-FRAME="f_convenio"
                                    &NOME-CAMPO=aux_nmdcampo }
                        END.
                END.
        END. /*  Fim do EDITING  */
           
        LEAVE.
    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF  CAPS(glb_nmdatela) <> "GT0002" THEN
                DO:
                    HIDE FRAME f_convenio.
                    HIDE FRAME f_convenioc.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

        IF  aux_cddopcao <> INPUT glb_cddopcao THEN
            DO: 
                { includes/acesso.i }
                ASSIGN aux_cddopcao = INPUT glb_cddopcao.
            END.

        ASSIGN  glb_cddopcao = INPUT glb_cddopcao.

        IF  INPUT glb_cddopcao = "C" THEN
            DO:
                HIDE FRAME f_convenioc.
                { includes/gt0002c.i }
            END.
        ELSE
        IF  INPUT glb_cddopcao = "E" THEN
            DO:
                HIDE FRAME f_convenioc.
                { includes/gt0002e.i }
            END.
        ELSE
        IF  INPUT glb_cddopcao = "I"   THEN
            DO:
                HIDE FRAME f_convenioc.
                { includes/gt0002i.i }
            END.
END.

/* .......................................................................... */

PROCEDURE Busca_Dados:

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-gt0002.
    EMPTY TEMP-TABLE tt-gt0002-aux.

    DO WITH FRAME f_convenio:
        ASSIGN glb_cddopcao
               tel_cdconven
               tel_cdcooper.
    END.
    
    IF  NOT VALID-HANDLE(h-b1wgen0176) THEN
        RUN sistema/generico/procedures/b1wgen0176.p
            PERSISTENT SET h-b1wgen0176.

    MESSAGE "Aguarde...buscando dados...".

    RUN Busca_Dados IN h-b1wgen0176
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_dsdepart,
          INPUT glb_cddopcao,
          INPUT tel_cdconven,
          INPUT tel_cdcooper,
          INPUT 0, /* nrregist */
          INPUT 0, /* nriniseq */
          INPUT TRUE, /* flgerlog */
         OUTPUT aux_qtregist,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-gt0002,
         OUTPUT TABLE tt-gt0002-aux,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.

    IF  VALID-HANDLE(h-b1wgen0176) THEN
        DELETE OBJECT h-b1wgen0176.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

PROCEDURE Grava_Dados:

    EMPTY TEMP-TABLE tt-erro.
    
    IF  NOT VALID-HANDLE(h-b1wgen0176) THEN
        RUN sistema/generico/procedures/b1wgen0176.p
            PERSISTENT SET h-b1wgen0176.

    MESSAGE "Aguarde...gravando dados...".

    RUN Grava_Dados IN h-b1wgen0176
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_dtmvtolt,
          INPUT glb_nmdatela,
          INPUT 1, /* idorigem */
          INPUT glb_cddopcao,
          INPUT tel_cdconven,
          INPUT tel_cdcooper,
         OUTPUT TABLE tt-erro) NO-ERROR.

    HIDE MESSAGE NO-PAUSE.

    IF  VALID-HANDLE(h-b1wgen0176) THEN
        DELETE OBJECT h-b1wgen0176.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.
    
    RETURN "OK".

END PROCEDURE. /* Grava_Dados */
