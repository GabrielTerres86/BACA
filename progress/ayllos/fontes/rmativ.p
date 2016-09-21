/* .............................................................................
   Programa: Fontes/rmativ.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton
   Data    : junho/2006                Ultima Atualizacao: 16/04/2012  

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela RMATIV.
         
   Alteracao : 16/04/2012 - Fonte substituido por rmativp.p (Tiago).
............................................................................ */

{ includes/var_online.i } 

DEF        VAR tel_cdrmativ AS INT     FORMAT "zzz"                  NO-UNDO.
DEF        VAR tel_nmrmativ AS CHAR    FORMAT "x(30)"                NO-UNDO.
DEF        VAR tel_cdseteco AS INT     FORMAT "zz"                   NO-UNDO.
DEF        VAR tel_nmseteco AS CHAR    FORMAT "x(25)"                NO-UNDO.
                                                                       
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_cdrmativ LIKE gnrativ.cdrmativ INITIAL 1          NO-UNDO.


FORM SKIP (3)
     "Opcao:"     AT 5
     glb_cddopcao AT 12 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (A, C, E ou I)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I",
                            "014 - Opcao errada.")
     SKIP (3)
     "Codigo  Ramo de Atividade              Setor Economico" AT 9
     SKIP(1)
     tel_cdrmativ AT 11 AUTO-RETURN
                 HELP "Informe o codigo do ramo de atividade ou F7 para listar."
     tel_nmrmativ AT 17 AUTO-RETURN
                  HELP "Informe o nome do ramo de atividade."
                  VALIDATE (tel_nmrmativ <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_cdseteco AT 48 AUTO-RETURN
                  HELP "Informe o codigo do setor economico ou F7 para listar."
                  VALIDATE (tel_cdseteco <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_nmseteco AT 51
     
     SKIP(6)
     WITH NO-LABELS TITLE " Ramos de Atividades " ROW 4 COLUMN 1 OVERLAY 
                    WIDTH 80 FRAME f_ramos.

/* variaveis para mostrar a consulta */

DEF QUERY  ramos-q FOR gnrativ.
DEF BROWSE ramos-b QUERY ramos-q
      DISP SPACE(5)
           gnrativ.cdrmativ              COLUMN-LABEL "Codigo"
           SPACE(3)
           gnrativ.nmrmativ              COLUMN-LABEL "Ramo de Atividade"
           SPACE(5)
           WITH 9 DOWN OVERLAY TITLE "RAMO DE ATIVIDADE".

DEF FRAME f_ramosc
          ramos-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP
          WITH NO-BOX CENTERED OVERLAY ROW 8 .

DEF QUERY setoreco-q FOR craptab. 
DEF BROWSE setoreco-b QUERY setoreco-q
      DISP craptab.tpregist                     COLUMN-LABEL "Cod."
           craptab.dstextab     FORMAT "x(20)"  COLUMN-LABEL "Setor Economico"
           WITH 06 DOWN OVERLAY TITLE "SETOR ECONOMICO".    
                            
FORM setoreco-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_setoreco.          

ON  RETURN OF setoreco-b 
    DO:
        ASSIGN tel_cdseteco = craptab.tpregist
               tel_nmseteco = SUBSTR(craptab.dstextab,01,20).
               
        DISPLAY tel_cdseteco tel_nmseteco WITH FRAME f_ramos.    
        APPLY "GO".
    END.
        
ON  RETURN OF ramos-b
    DO:   
        ASSIGN tel_cdrmativ = gnrativ.cdrmativ 
               tel_nmrmativ = gnrativ.nmrmativ
               tel_cdseteco = gnrativ.cdseteco.
                                    
        DISPLAY tel_cdrmativ  tel_nmrmativ tel_cdseteco WITH FRAME f_ramos.
        RUN pesq_setor_economico.
        APPLY "GO".
    END.        

ASSIGN glb_cddopcao = "C".

DO WHILE TRUE:
        
   ASSIGN tel_cdrmativ = 0.
        
   RUN fontes/inicia.p.
       
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_ramos.

      LEAVE.
   END.
       
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "RMATIV"   THEN
                 DO:
                     HIDE FRAME f_ramos.
                     HIDE FRAME f_ramosc.
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
             
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           
      IF   glb_cddopcao <> "I" THEN 
           UPDATE  tel_cdrmativ   WITH FRAME f_ramos
                      
           EDITING:
               
               READKEY.     
               IF   LASTKEY = KEYCODE("F7") THEN                           
                    DO:
                       IF   FRAME-FIELD = "tel_cdrmativ"   THEN
                            DO:
                               OPEN QUERY ramos-q 
                               FOR EACH gnrativ NO-LOCK BY gnrativ.cdrmativ.
                                 
                               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                                                UPDATE  ramos-b WITH FRAME f_ramosc.
                                  LEAVE.
                               END.
                              
                               HIDE FRAME f_ramosc.
                               NEXT.                                   
                            END.    
                    END. 
               ELSE 
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
                        LEAVE.
                    ELSE 
                        APPLY LASTKEY.
           END.  /*  Fim do EDITING  */           
           
      LEAVE.           
   END.
         
   ASSIGN tel_nmrmativ = CAPS(INPUT tel_nmrmativ)
          glb_cddopcao = INPUT glb_cddopcao.

   IF   INPUT glb_cddopcao = "A" THEN
        DO:
            { includes/rmativa.i }
        END.    
   ELSE
   IF   INPUT glb_cddopcao = "C" THEN
        DO:
            { includes/rmativc.i }
        END.    
   ELSE
   IF   INPUT glb_cddopcao = "E"   THEN
        DO:
            { includes/rmative.i }
        END.    
   ELSE
   IF   INPUT glb_cddopcao = "I"   THEN
        DO:
            FOR EACH gnrativ NO-LOCK BREAK BY gnrativ.cdrmativ: 
                                 
                IF   LAST-OF(gnrativ.cdrmativ)  THEN
                     aux_cdrmativ = gnrativ.cdrmativ + 1.   
            END.
                                 
            ASSIGN tel_cdrmativ = aux_cdrmativ. 
                                
            { includes/rmativi.i }
        END.
END.

/* mostra descricao do setor economico */
PROCEDURE pesq_setor_economico:
 
   ASSIGN  tel_nmrmativ = gnrativ.nmrmativ 
           tel_cdseteco = gnrativ.cdseteco.
        
   FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                      craptab.cdacesso = "SETORECONO" AND
                      craptab.tpregist = tel_cdseteco
                      NO-LOCK NO-ERROR.
                           
   ASSIGN tel_nmseteco = IF   AVAILABLE craptab THEN
                              "- " + craptab.dstextab
                         ELSE "Nao Cadastrado".

   DISPLAY tel_nmrmativ tel_cdseteco tel_nmseteco WITH FRAME f_ramos.  
          
END PROCEDURE.


/* <F7> NO CAMPO tel_cdseteco */
PROCEDURE lista_setor_economico:       

   UPDATE tel_cdseteco  WITH FRAME f_ramos
 
   EDITING:
           READKEY.

           IF   LASTKEY = KEYCODE("F7") THEN              
                DO:
                    IF   FRAME-FIELD = "tel_cdseteco" THEN  
                         DO:
                             OPEN QUERY setoreco-q FOR EACH craptab WHERE 
                                       craptab.cdcooper = glb_cdcooper AND
                                       craptab.cdacesso =  "SETORECONO" NO-LOCK.
                          
                             DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   UPDATE setoreco-b WITH FRAME f_setoreco.
                                   LEAVE.   
                             END. 
                             
                             HIDE FRAME f_setoreco.
                             NEXT.   
                         END.
                END. 
           ELSE 
                APPLY LASTKEY.
   END.  

END PROCEDURE.
/*.......................................................................... */
