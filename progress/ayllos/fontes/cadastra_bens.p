/* ..........................................................................
  
   Programa: Fontes/cadastra_bens.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Agosto/2009                         Ultima atualizacao: 25/06/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line).
   Objetivo  : Permitir cadastrar em temp-table os bens dos procuradores
               terceiros.
              
   Alteracoes: 21/12/2011 - Corrigido warnings (Tiago).
   
               25/06/2012 - Ajustes refrente ao projeto GP - Socios Menores
                           (Adriano).
               
               
..............................................................................*/


{ includes/var_online.i }

DEF VAR aux_cdsequen AS INTE                                        NO-UNDO.   

DEF TEMP-TABLE tt-cad_bens
    FIELD dsrelbem LIKE crapbem.dsrelbem
    FIELD persemon LIKE crapbem.persemon
    FIELD qtprebem LIKE crapbem.qtprebem
    FIELD vlprebem LIKE crapbem.vlprebem
    FIELD vlrdobem LIKE crapbem.vlrdobem
    FIELD cdsequen AS   INTE
    FIELD cddopcao AS CHAR
    FIELD deletado AS LOG
    FIELD nrdrowid AS ROWID
    FIELD cpfdoben AS CHAR
    INDEX tt-cad_bens1 cdsequen.
    

DEF INPUT-OUTPUT PARAM TABLE FOR tt-cad_bens.
DEF INPUT PARAM par_nmrotina AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_nrdrowid AS ROWID                                  NO-UNDO.
DEF INPUT PARAM par_cpfdoben AS CHAR                                   NO-UNDO.


DEF VAR reg_dsdopcao AS CHAR EXTENT 3 INIT ["Alterar",
                                            "Excluir",
                                            "Incluir"]                 NO-UNDO.

DEF VAR reg_contador AS INTE          INIT 3                           NO-UNDO.


DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)"                             NO-UNDO.

DEF QUERY q-bens FOR tt-cad_bens.

DEF BROWSE b-bens QUERY q-bens 
    DISPLAY tt-cad_bens.dsrelbem COLUMN-LABEL "Bem" FORMAT "x(15)"
            tt-cad_bens.persemon COLUMN-LABEL "Percentual s/ onus"
            tt-cad_bens.qtprebem COLUMN-LABEL "Parc."
            tt-cad_bens.vlprebem COLUMN-LABEL "Valor Parcela"
            tt-cad_bens.vlrdobem COLUMN-LABEL "Valor Bem"
            WITH WIDTH 76 CENTERED NO-BOX 5 DOWN.
            
FORM b-bens
        HELP "Pressione <ENTER> p/ selecionar - <F4> ou <END> p/ sair."
     SKIP(1)
     
     WITH WIDTH 76 CENTERED ROW 10 COLUMN 2 OVERLAY NO-BOX FRAME f_bens.
     
FORM SKIP(8)
     reg_dsdopcao[1] AT 15 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[2] AT 35 NO-LABEL FORMAT "x(7)"
     reg_dsdopcao[3] AT 55 NO-LABEL FORMAT "x(7)"
     
     WITH ROW 9 WIDTH 78 CENTERED OVERLAY SIDE-LABELS 
          
          TITLE " BENS " FRAME f_regua.

FORM SKIP(1)
     tt-cad_bens.dsrelbem    AT 15 LABEL "Descricao do bem"     FORMAT "x(40)"
        HELP "Informe a descricao do bem." 
        VALIDATE (tt-cad_bens.dsrelbem <> "", 
                  "375 - O campo deve ser prenchido.")
                       
     tt-cad_bens.persemon    AT 12 LABEL "Percentual sem onus"  FORMAT "zz9.99"
        HELP "Informe o percentual sem onus."
        VALIDATE (tt-cad_bens.persemon <= 100,"269 - Valor errado.")

     tt-cad_bens.qtprebem    AT 15 LABEL "Parcelas a pagar"     FORMAT "zz9"
        HELP "Informe a quantidade de parcelas a pagar."
        VALIDATE (INPUT tt-cad_bens.persemon = 100  OR
                   (INPUT tt-cad_bens.persemon <> 100 AND tt-cad_bens.qtprebem > 0),
                  "375 - O campo deve ser prenchido.")
     
     tt-cad_bens.vlprebem    AT 15 LABEL "Valor da parcela"     FORMAT "zzz,zz9.99"
        HELP "Informe o valor da parcela do bem."
        VALIDATE (INPUT tt-cad_bens.persemon = 100  OR
                    (INPUT tt-cad_bens.persemon <> 100  AND tt-cad_bens.vlprebem > 0),
                 "375 - O campo deve ser prenchido.")        

     tt-cad_bens.vlrdobem    AT 19 LABEL "Valor do bem"    FORMAT "zzz,zzz,zz9.99"
        HELP "Informe o valor do bem."
        VALIDATE (tt-cad_bens.vlrdobem <> 0,"375 - O campo deve ser prenchido.")
        
     SKIP(1)
     WITH ROW 10 CENTERED WIDTH 76 OVERLAY SIDE-LABELS NO-BOX FRAME f_altera.
 

ON ANY-KEY OF b-bens IN FRAME f_bens DO:

   IF KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
      DO:
          reg_contador = reg_contador + 1.

          IF reg_contador > 3   THEN
             reg_contador = 1.
               
      END.
   ELSE        
      IF KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
         DO:
             reg_contador = reg_contador - 1.
    
             IF reg_contador < 1   THEN
                reg_contador = 3.
                  
         END.
      ELSE
         IF KEY-FUNCTION(LASTKEY) = "HELP"   THEN
            APPLY LASTKEY.
         ELSE
            IF CAN-DO("RETURN,GO",STRING(KEY-FUNCTION(LASTKEY)))   THEN
               DO:
                  APPLY "GO".
               END.
            ELSE
               RETURN.
            
   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

END.


ON LEAVE OF tt-cad_bens.persemon IN FRAME f_altera DO:

   IF INPUT tt-cad_bens.persemon = 100   THEN
      DO:
          ASSIGN tt-cad_bens.qtprebem = 0
                 tt-cad_bens.vlprebem = 0.
                  
          DISPLAY tt-cad_bens.qtprebem 
                  tt-cad_bens.vlprebem 
                  WITH FRAME f_altera. 
                    
      END.
END.
 
/* Nao editar parcelas quando o bem estiver quitado */
ON ANY-KEY OF tt-cad_bens.qtprebem, tt-cad_bens.vlprebem IN FRAME f_altera DO:

   IF CAN-DO("GO,RETURN,TAB,BACK-TAB,CURSOR-DOWN,CURSOR-UP,END-ERROR," +
              "CURSOR-LEFT,CURSOR-RIGHT",KEYFUNCTION(LASTKEY))  THEN
      RETURN.
    
   IF INPUT tt-cad_bens.persemon = 100 THEN
      RETURN NO-APPLY.

END.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:


   DISPLAY reg_dsdopcao WITH FRAME f_regua.

   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD reg_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_regua.

  
   IF par_nmrotina = "PROCURADORES" THEN
      OPEN QUERY q-bens FOR EACH tt-cad_bens NO-LOCK.
   ELSE
      OPEN QUERY q-bens FOR EACH tt-cad_bens WHERE 
                                   NOT tt-cad_bens.deletado            AND 
                                   tt-cad_bens.nrdrowid = par_nrdrowid AND
                                   tt-cad_bens.cpfdoben = par_cpfdoben 
                                   NO-LOCK.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
      UPDATE b-bens WITH FRAME f_bens.
      LEAVE.

   END.     
   
   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
      DO:           
          CLOSE QUERY q-bens.
          HIDE FRAME f_regua.
          HIDE FRAME f_altera.
          HIDE FRAME f_bens.
          LEAVE.

      END.

   VIEW FRAME f_bens.
   
   IF reg_contador = 1   THEN  /* Alteracao */
      DO:
          IF NOT AVAIL tt-cad_bens   THEN
             NEXT.
              
          DO TRANSACTION:
          
             FIND CURRENT tt-cad_bens EXCLUSIVE-LOCK NO-ERROR.
          
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
            
                UPDATE tt-cad_bens.dsrelbem
                       tt-cad_bens.persemon
                       tt-cad_bens.qtprebem
                       tt-cad_bens.vlprebem
                       tt-cad_bens.vlrdobem 
                       WITH FRAME f_altera.

                LEAVE.
                 
             END.        
           
             IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
           
             RUN proc_confirma.
          
             IF aux_confirma <> "S"   THEN
                DO:
                    UNDO,
                    NEXT.
                END.
          
             ASSIGN tt-cad_bens.dsrelbem = CAPS(tt-cad_bens.dsrelbem)
                    tt-cad_bens.cddopcao = "A"
                    tt-cad_bens.nrdrowid = par_nrdrowid
                    tt-cad_bens.cpfdoben = par_cpfdoben.
          
          END. /* Fim transacao */
         
          DISPLAY tt-cad_bens.dsrelbem WITH FRAME f_altera.
          
          PAUSE 0.

      END. /***  Fim Alteracao ****/
   ELSE
      IF reg_contador = 2   THEN               /* Exclusao */
         DO: 
             IF NOT AVAILABLE tt-cad_bens   THEN
                NEXT.
      
             RUN proc_confirma.
             
             IF aux_confirma <> "S"   THEN
                NEXT.
                  
             DO TRANSACTION:
             
                FIND CURRENT tt-cad_bens EXCLUSIVE-LOCK NO-ERROR.
             
      
                IF par_nmrotina = "PROCURADORES" THEN
                   DELETE tt-cad_bens. 
                ELSE
                   ASSIGN tt-cad_bens.deletado = YES
                          tt-cad_bens.cddopcao = "E"
                          tt-cad_bens.nrdrowid = par_nrdrowid
                          tt-cad_bens.cpfdoben = par_cpfdoben.
                 
             END.    
      
         END.
      ELSE   /* Inclusao */
         DO:
             aux_contador = 0.
             
             FOR EACH tt-cad_bens WHERE tt-cad_bens.nrdrowid = par_nrdrowid AND
                                        tt-cad_bens.cpfdoben = par_cpfdoben
                                        NO-LOCK:
             
                 ASSIGN aux_contador = aux_contador + 1.
             
             END.
      
             /* bens serao gravados na crapavt, que possui extent 6 */
             IF aux_contador = 6   THEN
                DO:
                    MESSAGE "Limite no cadastramento de bens atingido !!".
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
      
                END.
             
             FIND LAST tt-cad_bens NO-LOCK NO-ERROR.
             
             ASSIGN aux_cdsequen = IF AVAILABLE tt-cad_bens THEN
                                      tt-cad_bens.cdsequen + 1
                                   ELSE
                                      1.
             
             DO TRANSACTION:
             
                CREATE tt-cad_bens.
             
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
               
                   UPDATE tt-cad_bens.dsrelbem
                          tt-cad_bens.persemon
                          tt-cad_bens.qtprebem
                          tt-cad_bens.vlprebem
                          tt-cad_bens.vlrdobem 
                          WITH FRAME f_altera.
      
                   LEAVE.
                    
                END.        
      
                IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN  /* Desfaz */
                   DO:
                       DELETE tt-cad_bens.
                       NEXT.
      
                   END.
      
                RUN proc_confirma.
             
                IF aux_confirma <> "S"   THEN  /* Desfaz */
                   DO:
                       DELETE tt-cad_bens.
                       NEXT.
      
                   END.
             
                ASSIGN tt-cad_bens.dsrelbem = CAPS(tt-cad_bens.dsrelbem)
                       tt-cad_bens.cdsequen = aux_cdsequen
                       tt-cad_bens.cddopcao = "I"
                       tt-cad_bens.nrdrowid = par_nrdrowid
                       tt-cad_bens.cpfdoben = par_cpfdoben.
             
             END. /* Fim transacao */
             
             DISPLAY tt-cad_bens.dsrelbem WITH FRAME f_altera. 
      
             PAUSE 0.
      
         END. /* Fim opcao "I" */

   CLOSE QUERY q-bens.

END.  /* Fim DO WHILE TRUE */



PROCEDURE proc_confirma:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
      RUN fontes/critic.p.
      glb_cdcritic = 0.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
          
   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
      aux_confirma <> "S"                  THEN
      DO:
         glb_cdcritic = 79.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         PAUSE 1 NO-MESSAGE.
         HIDE MESSAGE NO-PAUSE.
         glb_cdcritic = 0.
         LEAVE.
      END.

END PROCEDURE.


/*............................................................................*/
