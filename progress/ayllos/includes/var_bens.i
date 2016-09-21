/* ............................................................................

   Programa: includes/var_bens.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Junho/2010                          Ultima atualizacao:
   
   Dados referentes ao programa:
   
   Frequencia: Diario (On-line).
   Objetivo  : Definicao das variaveis, form´s e eventos dos bens do cooperado.
            
   Alteracoes: 26/11/2010 - Adicionado variavel aux_msgrvcad para revisão 
                            cadastral (Gabriel, DB1). 
                                                   
............................................................................ */
                                                                               
{ sistema/generico/includes/b1wgen0056tt.i }

DEF VAR tel_dsrelbem AS CHAR                                           NO-UNDO.
DEF VAR tel_persemon AS DECI                                           NO-UNDO.
DEF VAR tel_qtprebem AS INTE                                           NO-UNDO.
DEF VAR tel_vlprebem AS DECI                                           NO-UNDO.
DEF VAR tel_vlrdobem AS DECI                                           NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.

DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]               NO-UNDO.
DEF VAR reg_contador AS INTE          INIT 3                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                           NO-UNDO.
DEF VAR aux_idseqbem AS INTE                                           NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                           NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                           NO-UNDO.

DEF VAR par_msgconta AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0056 AS HANDLE                                         NO-UNDO.


DEF QUERY q-crapbem  FOR tt-crapbem.

DEF BROWSE b-crapbem QUERY q-crapbem
    DISPLAY tt-crapbem.dsrelbem COLUMN-LABEL "Bem"  FORMAT "x(18)"
            tt-crapbem.persemon COLUMN-LABEL "Percentual s/ onus"
            tt-crapbem.qtprebem COLUMN-LABEL "Parc."
            tt-crapbem.vlprebem COLUMN-LABEL "Vlr. Parcela"
            tt-crapbem.vlrdobem COLUMN-LABEL "Vlr. Bem" FORMAT "zzz,zzz,zz9.99"
            WITH NO-BOX 5 DOWN.

FORM b-crapbem
        HELP "Pressione <ENTER> p/ selecionar - <F4> ou <END> p/ sair."
     SKIP(1)
     WITH CENTERED WIDTH 76 ROW 12 COLUMN 2 OVERLAY NO-BOX FRAME f_crapbem.

FORM SKIP(8)
     reg_dsdopcao[1] AT 15 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2] AT 35 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3] AT 55 NO-LABEL FORMAT "x(7)"

     WITH CENTERED ROW 11 WIDTH 78 OVERLAY 
          SIDE-LABELS TITLE " BENS " FRAME f_regua.

FORM SKIP(1)
     tel_dsrelbem    AT 15 LABEL "Descricao do bem"     FORMAT "x(40)"
        HELP "Informe a descricao do bem." 
        VALIDATE (tel_dsrelbem <> "", 
                  "375 - O campo deve ser prenchido.")
                       
     tel_persemon    AT 12 LABEL "Percentual sem onus"  FORMAT "zz9.99"
        HELP "Informe o percentual sem onus."
        VALIDATE (tel_persemon <= 100,"269 - Valor errado.")

     tel_qtprebem    AT 15 LABEL "Parcelas a pagar"     FORMAT "zz9"
        HELP "Informe a quantidade de parcelas a pagar."
        VALIDATE (INPUT tel_persemon = 100  OR
                   (INPUT tel_persemon <> 100 AND tel_qtprebem > 0),
                  "375 - O campo deve ser prenchido.")
     
     tel_vlprebem    AT 15 LABEL "Valor da parcela"     FORMAT "zzz,zz9.99"
        HELP "Informe o valor da parcela do bem."
        VALIDATE (INPUT tel_persemon = 100  OR
                    (INPUT tel_persemon <> 100  AND  tel_vlprebem > 0),
                 "375 - O campo deve ser prenchido.")        

     tel_vlrdobem    AT 19 LABEL "Valor do bem"         FORMAT "zzz,zzz,zz9.99"
        HELP "Informe o valor do bem."
        VALIDATE (tel_vlrdobem <> 0,"375 - O campo deve ser prenchido.")
        
     SKIP(1)
     WITH CENTERED ROW 12 COLUMN 2 WIDTH 74 OVERLAY SIDE-LABELS
     
          NO-BOX FRAME f_altera.


                
ON ENTRY OF b-crapbem IN FRAME f_crapbem DO:

   IF   aux_nrdlinha > 0   THEN
        REPOSITION q-crapbem TO ROW(aux_nrdlinha).

END.


ON ANY-KEY OF b-crapbem IN FRAME f_crapbem DO:

    /* Na consulta da proposta de emprestimo , nao altera nada .. */
   IF   glb_cddopcao = "C"       AND 
        glb_nmdatela = "ATENDA"  THEN
        IF   KEYFUNCTION(LASTKEY) <> "END-ERROR"    AND
             KEYFUNCTION(LASTKEY) <> "CURSOR-DOWN"  AND
             KEYFUNCTION(LASTKEY) <> "CURSOR-UP"    THEN
             APPLY "END-ERROR" TO b-crapbem IN FRAME f_crapbem.
      

   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
        DO:
            reg_contador = reg_contador + 1.

            IF   reg_contador > 3   THEN
                 reg_contador = 1.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE        
   IF   KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
        DO:
            reg_contador = reg_contador - 1.

            IF   reg_contador < 1   THEN
                 reg_contador = 3.
                 
            glb_cddopcao = reg_cddopcao[reg_contador].
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "HELP"   THEN
        APPLY LASTKEY.
   ELSE
   IF   CAN-DO("RETURN",STRING(KEY-FUNCTION(LASTKEY)))   THEN
        DO:
           ASSIGN glb_cddopcao = reg_cddopcao[reg_contador].

           IF   AVAILABLE tt-crapbem   THEN
                DO:
                    ASSIGN aux_nrdrowid = tt-crapbem.nrdrowid
                           aux_idseqbem = tt-crapbem.idseqbem
                           aux_nrdlinha = CURRENT-RESULT-ROW("q-crapbem").
                         
                    /*Desmarca todas as linhas do browse para poder remarcar*/
                    b-crapbem:DESELECT-ROWS().
                END.
           ELSE
                ASSIGN aux_nrdrowid = ?
                       aux_idseqbem = 0
                       aux_nrdlinha = 0.
                         
           APPLY "GO".
        END.
   ELSE
   IF   KEY-FUNCTION(LASTKEY) = "GO" THEN
        DO:      
            APPLY "END-ERROR" TO b-crapbem IN FRAME f_crapbem.  

            PAUSE 0.
        END.
   ELSE
        RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.


ON LEAVE OF tel_persemon IN FRAME f_altera DO:

    IF   INPUT tel_persemon = 100   THEN
         DO:
             ASSIGN tel_qtprebem = 0
                    tel_vlprebem = 0.
                    
             DISPLAY tel_qtprebem 
                     tel_vlprebem WITH FRAME f_altera.   
         END.
END.


/* Nao editar parcelas quando o bem estiver quitado */
ON ANY-KEY OF tel_qtprebem, tel_vlprebem IN FRAME f_altera DO:

   IF   CAN-DO("GO,RETURN,TAB,BACK-TAB,CURSOR-DOWN,CURSOR-UP,END-ERROR," +
                "CURSOR-LEFT,CURSOR-RIGHT",KEYFUNCTION(LASTKEY))  THEN
        RETURN.
    
   IF   INPUT tel_persemon = 100   THEN
        RETURN NO-APPLY.

END.

             


/* ......................................................................... */
