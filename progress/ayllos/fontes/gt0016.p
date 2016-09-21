/* .............................................................................

   Programa: Fontes/gt0016.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Isara - RKAM
   Data    : Abril/2011                        Ultima Atualizacao: 16/04/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Cadastramento da Modalidade (Generico)
   
   Alteracoes: 16/04/2012 - Fonte substituido por gt0016p.p (Tiago).
   
............................................................................. */

{ includes/var_online.i  }

DEF VAR tel_cdmodali LIKE gnmodal.cdmodali     NO-UNDO.
DEF VAR tel_dsmodali LIKE gnmodal.dsmodali     NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                   NO-UNDO. 
DEF VAR aux_confirma AS CHAR  FORMAT "!(1)"    NO-UNDO.

DEF TEMP-TABLE tt-gnmodal NO-UNDO
    FIELD cdmodali LIKE gnmodal.cdmodali 
    FIELD dsmodali LIKE gnmodal.dsmodali.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     "Opcao:"     AT 6
     glb_cddopcao AUTO-RETURN
                  HELP "Entre com a opcao desejada (A, C, I, L)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "I" OR glb_cddopcao = "L", 
                            "014 - Opcao errada.")
     SKIP (2)
     tel_cdmodali    AT  3  LABEL "Codigo"
                            HELP "Informe o codigo da modalidade"
                            VALIDATE( tel_cdmodali <> " ",
                            "357 - O codigo deve ser preenchido.")
     SKIP(1)
     tel_dsmodali    AT 3   Label "Descricao"
                            HELP "Informe a descricao da modalidade"
     WITH NO-LABELS ROW 5 OVERLAY COLUMN 2 FRAME f_modalida NO-BOX SIDE-LABELS.

/*** Browse Listar ***/
DEF QUERY q_opcaol FOR tt-gnmodal.

DEF BROWSE b_opcaol QUERY q_opcaol
   DISPLAY tt-gnmodal.cdmodali COLUMN-LABEL "Codigo"     FORMAT "x(02)"
           tt-gnmodal.dsmodali COLUMN-LABEL "Modalidade" FORMAT "x(40)"
           WITH 11 DOWN NO-BOX WIDTH 73.

FORM b_opcaol
    WITH ROW 8 CENTERED OVERLAY TITLE COLOR NORMAL " Modalidades " 
    FRAME f_listar.

/**********************************************/

glb_cddopcao = "C".

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).
VIEW FRAME f_modalida.

DO WHILE TRUE:

    DISPLAY glb_cddopcao WITH FRAME f_modalida.
    
    NEXT-PROMPT tel_cdmodali WITH FRAME f_modalida.
    
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        SET glb_cddopcao WITH FRAME f_modalida.

        LEAVE.
    END.

     /* F4, END ou FIM */
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    
    DO:
        RUN fontes/novatela.p.

        IF  CAPS(glb_nmdatela) <> "GT0016"   THEN
            DO:
                HIDE FRAME f_modalida.
                RETURN.
            END.
        ELSE
            NEXT.
    END.

    IF  aux_cddopcao <> INPUT glb_cddopcao THEN
    DO:
        { includes/acesso.i }
        aux_cddopcao = INPUT glb_cddopcao.
    END.

    ASSIGN glb_cddopcao = INPUT glb_cddopcao.

    CASE glb_cddopcao:

        WHEN "A" THEN
        DO:
            { includes/gt0016a.i }
        END.

        WHEN "C" THEN
        DO:
            { includes/gt0016c.i }
        END.

        WHEN "I" THEN
        DO:
            { includes/gt0016i.i }
        END.

        WHEN "L" THEN
        DO:
            { includes/gt0016l.i }
        END.

    END CASE.
    
END.

/* .......................................................................... */   

