/* .............................................................................

   Programa: fontes/pesqtc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Irlan
   Data    : Agosto/2010                         Ultima atualizacao: 04/12/2012

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela PESQTC.
   
   Alteracoes: 18/06/2012 - Alteracao na leitura da craptco (David Kruger).
   
               11/10/2012 - Inclusao dos campos cdcooper_dst e nrdconta_dst
                            na tela e na leitura (Lucas R.)
               
               04/12/2012 - Retirado o campo flgativo da consulta (Irlan) 
   
............................................................................ */

{ includes/var_online.i } 

DEF   VAR tel_cdcooper     AS INT      FORMAT "z9"                   NO-UNDO.
DEF   VAR tel_nrdconta     LIKE crapass.nrdconta                     NO-UNDO.
DEF   VAR aux_cddopcao     AS CHAR                                   NO-UNDO.
DEF   VAR aux_stcopant     AS CHAR FORMAT "x(15)"                    NO-UNDO.
DEF   VAR aux_stcooper     AS CHAR FORMAT "x(15)"                    NO-UNDO.
DEF   VAR aux_nrmatric_ant LIKE crapass.nrmatric                     NO-UNDO.
DEF   VAR aux_nrmatric_new LIKE crapass.nrmatric                     NO-UNDO.
DEF   VAR aux_nmprimtl_ant LIKE crapass.nmprimtl                     NO-UNDO.
DEF   VAR aux_nmprimtl_new LIKE crapass.nmprimtl                     NO-UNDO.
DEF   VAR tel_cdcooper_dst AS INT      FORMAT "z9"                   NO-UNDO.
DEF   VAR tel_nrdconta_dst LIKE crapass.nrdconta                     NO-UNDO.

DEF TEMP-TABLE tt-contas                                             NO-UNDO
         FIELD stcopant     AS   CHAR
         FIELD nrctaant     LIKE crapass.nrdconta
         FIELD stsepara     AS   CHAR
         FIELD stcooper     AS   CHAR
         FIELD nrdconta     LIKE crapass.nrdconta
         FIELD nrmatric_ant LIKE crapass.nrmatric
         FIELD nrmatric_new LIKE crapass.nrmatric
         FIELD nmprimtl_ant LIKE crapass.nmprimtl
         FIELD nmprimtl_new LIKE crapass.nmprimtl.

DEF QUERY q-contas FOR tt-contas.

DEF BROWSE b-contas QUERY q-contas
    DISPLAY tt-contas.stcopant  LABEL "Coop Ant"       FORMAT "x(15)"     
            tt-contas.nrctaant  LABEL "Conta/Dv Ant" 
            tt-contas.stsepara  FORMAT "x(12)"
            tt-contas.stcooper  LABEL "Nova Coop"      FORMAT "x(15)"
            tt-contas.nrdconta  LABEL "Nova Conta/Dv"
            WITH 5 DOWN WIDTH 78 NO-LABELS OVERLAY.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C)."
                        VALIDATE(CAN-DO("C",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

FORM tel_cdcooper  AT 1 LABEL "Cooperativa Ant."
                        HELP "Informe o Codigo da Cooperativa ou F7 para pesquisar"
                        FORMAT "zz9" 
                        AUTO-RETURN
                        VALIDATE(CAN-FIND (crapcop WHERE
                                           crapcop.cdcooper = tel_cdcooper),
                                 "893 - Codigo nao cadastrado")
     
     tel_nrdconta  AT 32 LABEL "Conta/dv Ant."   FORMAT "zzzz,zzz,9"
                        HELP "Informe Conta/Dv, F7 p/ pesquisa ou 0(Zero) p/ todas as contas."


     tel_cdcooper_dst  AT 1 LABEL "Cooperativa Nova"
                            HELP "Informe o Codigo da Cooperativa Nova ou F7 para pesquisar"
                            FORMAT "zz9"
                            AUTO-RETURN
                            VALIDATE(CAN-FIND (crapcop WHERE
                                               crapcop.cdcooper = tel_cdcooper_dst),
                                     "893 - Codigo nao cadastrado")

     tel_nrdconta_dst  AT 32 LABEL "Conta/dv Nova"   FORMAT "zzzz,zzz,9"
                             HELP "Informe Conta/Dv, F7 p/ pesquisa ou 0(Zero) p/ todas as contas."
     SKIP(10)            
     WITH ROW 6 COLUMN 16 SIDE-LABELS OVERLAY NO-BOX FRAME f_pesqtc.

FORM b-contas
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 9 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_browse.

FORM tt-contas.nrmatric_ant   AT 2   LABEL "Matricula Anterior"  
     tt-contas.nmprimtl_ant          NO-LABEL SKIP   
     tt-contas.nrmatric_new   AT 2   LABEL "Nova Matricula    " 
     tt-contas.nmprimtl_new          NO-LABEL
     WITH ROW 18 COLUMN 2 NO-BOX SIDE-LABELS OVERLAY FRAME f_detalhes.

ON ITERATION-CHANGED OF b-contas
   DO:
       DISPLAY tt-contas.nrmatric_ant
               tt-contas.nmprimtl_ant
               tt-contas.nrmatric_new
               tt-contas.nmprimtl_new
               WITH FRAME f_detalhes.
   END.
     
VIEW FRAME f_moldura.
PAUSE 0.

DO WHILE TRUE:          

   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.
      
      UPDATE glb_cddopcao  WITH FRAME f_opcao.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "PESQTC"  THEN
                 DO:
                     HIDE FRAME f_opcao.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C"   THEN
        DO:
            RUN limpa_campos.
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdcooper tel_nrdconta tel_cdcooper_dst tel_nrdconta_dst
               WITH FRAME f_pesqtc 
               EDITING:
                   READKEY.
                   IF  LASTKEY = KEYCODE("F7")  THEN
                       DO:
                          IF   FRAME-FIELD = "tel_cdcooper"  THEN
                               DO:
                                   RUN fontes/zoom_cooper.p 
                                       (OUTPUT tel_cdcooper).
                                   DISPLAY tel_cdcooper 
                                           WITH FRAME f_pesqtc.
                               END.
                          ELSE
                          IF   FRAME-FIELD = "tel_nrdconta"   THEN
                               DO:
                                   RUN fontes/zoom_associados.p
                                       (INPUT  tel_cdcooper:SCREEN-VALUE,
                                        OUTPUT tel_nrdconta).
        
                                   DISPLAY tel_nrdconta
                                           WITH FRAME f_pesqtc.
                               END.
                       END.
                   ELSE
                           APPLY LAST-KEY.

                         IF  LASTKEY = KEYCODE("F7")  THEN
                            DO:
                                IF FRAME-FIELD = "tel_cdcooper_dst"  THEN
                                   DO:
                                       RUN fontes/zoom_cooper.p 
                                           (OUTPUT tel_cdcooper_dst).
                                       DISPLAY tel_cdcooper_dst 
                                               WITH FRAME f_pesqtc.
                                   END.
                                ELSE
                                IF   FRAME-FIELD = "tel_nrdconta_dst"   THEN
                                     DO:
                                         RUN fontes/zoom_associados.p
                                             (INPUT  tel_cdcooper_dst:SCREEN-VALUE,
                                              OUTPUT tel_nrdconta_dst).
                
                                         DISPLAY tel_nrdconta_dst
                                                 WITH FRAME f_pesqtc.
                                     END.
                            END.
               END.
             
               

               /*Novas Contas ou Contas Anteriores*/
               FOR EACH craptco NO-LOCK WHERE 
                        (craptco.cdcooper  = tel_cdcooper_dst  AND 
                       ((craptco.nrdconta  = tel_nrdconta_dst) OR 
                        (tel_nrdconta_dst = 0)) )              AND
                        (craptco.cdcopant  = tel_cdcooper      AND 
                       ((craptco.nrctaant  = tel_nrdconta)     OR 
                        (tel_nrdconta = 0)) )                  AND
                        craptco.tpctatrf = 1: 
                   
                   FIND FIRST crapcop NO-LOCK 
                                      WHERE crapcop.cdcooper = craptco.cdcopant
                                      NO-ERROR.
                   IF   AVAIL crapcop THEN
                        ASSIGN aux_stcopant = STRING(crapcop.cdcooper) + "-" +  
                                       crapcop.nmrescop.
                   
                   FIND FIRST crapcop NO-LOCK 
                                      WHERE crapcop.cdcooper = craptco.cdcooper
                                      NO-ERROR.
                   IF   AVAIL crapcop THEN
                        ASSIGN aux_stcooper = STRING(crapcop.cdcooper) + "-" +  
                                       crapcop.nmrescop.
                   
                   FIND crapass NO-LOCK WHERE crapass.cdcooper = craptco.cdcopant AND
                                              crapass.nrdconta = craptco.nrctaant
                                              NO-ERROR.
                   IF   AVAIL crapass THEN
                        ASSIGN aux_nrmatric_ant = crapass.nrmatric
                               aux_nmprimtl_ant = crapass.nmprimtl. 
                   ELSE
                        ASSIGN aux_nrmatric_ant = 0
                               aux_nmprimtl_ant = "".
                    
                   FIND crapass NO-LOCK WHERE crapass.cdcooper = craptco.cdcooper AND
                                              crapass.nrdconta = craptco.nrdconta
                                              NO-ERROR.
                   IF   AVAIL crapass THEN
                        ASSIGN aux_nrmatric_new = crapass.nrmatric
                               aux_nmprimtl_new = crapass.nmprimtl.
                   ELSE
                        ASSIGN aux_nrmatric_new = 0
                               aux_nmprimtl_new = "".

                   CREATE tt-contas.
                   ASSIGN tt-contas.stcopant     = aux_stcopant
                          tt-contas.nrctaant     = craptco.nrctaant
                          tt-contas.stcooper     = aux_stcooper
                          tt-contas.nrdconta     = craptco.nrdconta
                          tt-contas.stsepara     = "===========>"
                          tt-contas.nrmatric_ant = aux_nrmatric_ant 
                          tt-contas.nrmatric_new = aux_nrmatric_new
                          tt-contas.nmprimtl_ant = aux_nmprimtl_ant
                          tt-contas.nmprimtl_new = aux_nmprimtl_new.

               END. /*FOR EACH craptco*/

               OPEN QUERY q-contas FOR EACH tt-contas.

               IF   NOT AVAILABLE tt-contas  THEN
                    DO:
                        MESSAGE "Nao existe transferencia para essa conta.".
                        NEXT.
                    END.
               ELSE
               DO:
                   ENABLE b-contas WITH FRAME f_browse.
                    
                   DISPLAY tt-contas.nrmatric_ant
                           tt-contas.nmprimtl_ant 
                           tt-contas.nrmatric_new
                           tt-contas.nmprimtl_new 
                       WITH FRAME f_detalhes.

                   WAIT-FOR CLOSE OF CURRENT-WINDOW.
               END.
            
            END. 
        END.

END.

PROCEDURE limpa_campos.

    ASSIGN  tel_cdcooper     = 0
            tel_nrdconta     = 0 
            aux_stcopant     = ""
            aux_stcooper     = ""
            aux_nrmatric_ant = 0
            aux_nrmatric_new = 0
            aux_nmprimtl_ant = ""
            aux_nmprimtl_new = ""
            tel_cdcooper_dst = 0
            tel_nrdconta_dst = 0 .

    EMPTY TEMP-TABLE tt-contas.    
    HIDE FRAME f_contas.                     
    HIDE FRAME f_pesqtc.    
    HIDE FRAME f_detalhes.
      
END PROCEDURE.
