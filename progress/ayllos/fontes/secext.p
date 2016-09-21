/* .............................................................................

   Programa: Fontes/secext.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Setembro/91                     Ultima Atualizacao: 06/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela SECEXT.

   ALTERACAO : 26/06/96 - Alterado para mostrar as pessoas da secao quando for a
                          opcao consulta (Odair).

               08/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               18/10/00 - Alterar fone para 20 posicoes (Margarete/Planner).

               27/01/2005 - Mudado o LABEL do campo "tel_cdagenci" de "Agencia"
                            para "PAC";
                            HELP de "Informe a agencia." para "Informe o PAC.";
                            VALIDATE de "134 - Agencia errada." para
                            "134 - PAC errado." (Evandro).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
............................................................................. */

{ includes/var_online.i } 

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR    FORMAT "!"                    NO-UNDO.

DEF        VAR tel_nmsecext AS CHAR                                  NO-UNDO.
DEF        VAR tel_nmpesext AS CHAR                                  NO-UNDO.
DEF        VAR tel_nrfonext AS CHAR                                  NO-UNDO.
DEF        VAR tel_indespac AS LOGICAL FORMAT "SECAO/CORREIO"        NO-UNDO.
DEF        VAR tel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR tel_cdsecext AS INT                                   NO-UNDO.

DEF QUERY q_secext FOR crapdes. 

DEF BROWSE  b_secext QUERY q_secext 
    DISPLAY crapdes.cdsecext COLUMN-LABEL "Cod."             FORMAT "zz9"
            crapdes.nmsecext COLUMN-LABEL "Descricao"        FORMAT "x(25)"
            IF   crapdes.indespac = 0 THEN 
                 " SECAO " 
            ELSE "CORREIO" COLUMN-LABEL "Despacho" 
            crapdes.nmpesext COLUMN-LABEL "Pessoa p/extrato" FORMAT "x(20)"
            WITH 8 DOWN CENTERED.

DEF FRAME f_secext  
          SKIP(1)
          b_secext   HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX NO-LABEL CENTERED OVERLAY ROW 7.
 
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_cdagenci  AT 2  LABEL  "PA"  
                         AUTO-RETURN
                         FORMAT "zz9"
                         HELP   "Informe o PA."
                         VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper = 
                                                         glb_cdcooper    AND
                                                         crapage.cdagenci =
                                  tel_cdagenci),"134 - PA errado.") 
     tel_cdsecext  AT 29 LABEL  "Codigo da Secao" 
                         FORMAT "zz9"
                 HELP   "Informe o codigo da secao ou Digite 0 para Listar."
     WITH ROW 6 COLUMN 30 SIDE-LABELS NO-BOX OVERLAY FRAME f_codigo.

FORM tel_cddopcao  LABEL "Opcao" 
                   AUTO-RETURN 
                   HELP "Entre com a opcao desejada (A, C , E ou I)" 
                   VALIDATE (tel_cddopcao = "A" OR tel_cddopcao = "C" OR   
                             tel_cddopcao = "E" OR tel_cddopcao = "I",
                             "014 - Opcao errada.") 
     WITH ROW 6 COLUMN 4 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM SKIP(1)
     tel_nmsecext AT 10  FORMAT "x(25)" 
                         LABEL  "Nome da Secao"
                         AUTO-RETURN
                         HELP "Entre com o Nome da Secao"
                         VALIDATE(tel_nmsecext <> "",
                                  "230 - Nome da secao deve ser informado.")
     SKIP(1)
     tel_nmpesext AT  4  FORMAT "x(20)" 
                         LABEL  "Pessoa para contato"
                         HELP
           "Entre com o nome da pessoa encarregada pela distribuicao na secao."                          AUTO-RETURN
                         VALIDATE(tel_nmpesext <> " ",
                                  "231 - Nome da pessoa deve ser informado.")
     SKIP(1)
     tel_nrfonext AT  2  FORMAT "x(20)" 
                         LABEL  "Telefone para contato"
                   HELP "Entre com o numero do telefone ou ramal para contato."
                         AUTO-RETURN
                         VALIDATE(tel_nrfonext <> "",
                                  "045 - Telefone deve ser informado.")
     SKIP(1)
     tel_indespac AT 15  LABEL "Despacho"
                         HELP  "(S)ecao ou (C)orreio"
     SKIP(1)
     WITH ROW 8 CENTERED SIDE-LABELS OVERLAY FRAME f_secao.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cdcritic = 0
       glb_nmrotina = ""
       tel_cddopcao = "C".

DO WHILE TRUE:

   ASSIGN tel_cdsecext = 0
          tel_cdagenci = 0.
                    
   CLEAR FRAME f_opcao.
   
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_cddopcao WITH FRAME f_opcao.
      LEAVE.
      
   END.
            
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "SECEXT"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

     
   CASE tel_cddopcao:
        WHEN "A" THEN       /*  Opcao de Alteracao  */ 
             DO:
                 glb_cddopcao = "A".
                 
                 { includes/acesso.i }

                 RUN P_Pesquisa.
                 
                 { includes/secexta.i }
               
                 HIDE FRAME f_codigo.
             END.
        
        WHEN "C" THEN       /*  Opcao de Consulta  */ 
             DO:
                 glb_cddopcao = "C".

                 { includes/acesso.i }

                 RUN P_Pesquisa.
                 
                 { includes/secextc.i }

                 HIDE FRAME f_codigo.
             END. 
                 
        WHEN "E" THEN       /*  Opcao de Exclusao  */ 
             DO:
                 glb_cddopcao = "E".

                 { includes/acesso.i }

                 RUN P_Pesquisa.
                  
                 { includes/secexte.i }
                 
                 HIDE FRAME f_codigo.
             END.
         
        WHEN "I" THEN       /*  Opcao de Inclusao  */ 
             DO:
                 glb_cddopcao = "I".

                 { includes/acesso.i }
                 
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_cdagenci tel_cdsecext WITH FRAME f_codigo.
                    LEAVE.
      
                 END.             
                 
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                      DO:
                          HIDE FRAME f_codigo.
                          NEXT.
                      END.
   
                 IF   (tel_cdsecext <> 0) THEN
                      DO:
                          FIND crapdes WHERE 
                               crapdes.cdcooper = glb_cdcooper AND
                               crapdes.cdagenci = tel_cdagenci AND
                               crapdes.cdsecext = tel_cdsecext NO-LOCK NO-ERROR.
                                              
                          IF   AVAILABLE crapdes THEN
                               DO:
                                   glb_cdcritic = 232.
                                   RUN fontes/critic.p.
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   glb_cdcritic = 0.
                                   PAUSE 5 NO-MESSAGE.
                                   HIDE FRAME f_codigo.
                                   NEXT.
                               END.
                 
                          { includes/secexti.i }
                    
                      END.            
                 ELSE
                      DO:
                          glb_cdcritic = 042.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          glb_cdcritic = 0.
                          PAUSE 5 NO-MESSAGE.
                      END.

                 HIDE FRAME f_codigo.
             END.            
      
      END CASE.

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE P_Pesquisa:

  HIDE FRAME f_secext.
  
  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

     UPDATE tel_cdagenci tel_cdsecext WITH FRAME f_codigo.
     LEAVE.
      
  END.             
                 
  IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
       DO:
           HIDE FRAME f_codigo.
           NEXT.
       END.
                  
   IF   tel_cdsecext = 0  THEN
        DO:
            OPEN QUERY q_secext 
                 FOR EACH crapdes WHERE crapdes.cdcooper = glb_cdcooper  AND
                                        crapdes.cdagenci = tel_cdagenci
                                        NO-LOCK BY crapdes.cdsecext.
        
            ENABLE b_secext WITH FRAME f_secext.

            WAIT-FOR DEFAULT-ACTION OF b_secext.
                          
            HIDE FRAME f_secext.
            
            ASSIGN tel_cdsecext  =  crapdes.cdsecext
                   tel_cdagenci  =  crapdes.cdagenci.
           
            DISPLAY tel_cdagenci tel_cdsecext  WITH FRAME f_codigo.
        END.
   ELSE
        DO:
            FIND crapdes WHERE crapdes.cdcooper = glb_cdcooper AND
                               crapdes.cdagenci = tel_cdagenci AND
                               crapdes.cdsecext = tel_cdsecext
                               NO-LOCK NO-ERROR.
                                              
            IF   NOT AVAILABLE crapdes THEN
                 DO:
                     glb_cdcritic = 019.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     glb_cdcritic = 0.
                     PAUSE 5 NO-MESSAGE.
                     HIDE FRAME f_codigo.
                     NEXT.
                 END.
        END.
                  
END PROCEDURE.

/* .......................................................................... */

