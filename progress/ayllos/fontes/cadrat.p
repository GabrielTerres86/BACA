/* .............................................................................

   Programa: Fontes/cadrat.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes   
   Data    : Julho/2004                     Ultima Atualizacao: 31/11/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir efetuar o cadastramento dos Parametros cadrat      

   Alteracoes: Unificacao dos Bancos - SQLWorks - Fernando
               
               13/11/2006 - Bloqueio da tela para todas as cooperativas nas
                            opcoes "A", "E" e "I" (Elton). 
   
               10/02/2009 - Liberar operacoes soh pro op. 799 (Gabriel).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               05/02/2010 - Considerar somente Ratings Antigos na hora de
                            excluir itens  (Gabriel)
                            
               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i } 

DEF VAR aux_ultlinha AS INTE                                         NO-UNDO.
DEF VAR tel_nrtopico LIKE craptor.nrtopico                           NO-UNDO.
DEF VAR tel_dstopico LIKE craptor.dstopico                           NO-UNDO.
DEF VAR tel_inpessoa LIKE craptor.inpessoa                           NO-UNDO.
DEF VAR tel_nritetop LIKE crapitr.nritetop                           NO-UNDO. 
DEF VAR tel_dsitetop LIKE crapitr.dsitetop                           NO-UNDO.
DEF VAR tel_pesoitem LIKE crapitr.pesoitem                           NO-UNDO.
DEF VAR tel_nrseqite LIKE crapsir.nrseqite                           NO-UNDO.
DEF VAR tel_dsseqite LIKE crapsir.dsseqite                           NO-UNDO.
DEF VAR tel_pesosequ LIKE crapsir.pesosequ                           NO-UNDO.

DEF VAR tel_nrtopicob LIKE craptor.nrtopico                          NO-UNDO.
DEF VAR tel_dstopicob LIKE craptor.dstopico                          NO-UNDO.
DEF VAR tel_flgativob LIKE craptor.flgativo                          NO-UNDO.
DEF VAR tel_nritetopb LIKE crapitr.nritetop                          NO-UNDO.
DEF VAR tel_dsitetopb LIKE crapitr.dsitetop                          NO-UNDO.
DEF VAR tel_pesoitemb LIKE crapitr.pesoitem                          NO-UNDO.
DEF VAR tel_pesosequb LIKE crapsir.pesosequ                          NO-UNDO.
DEF VAR tel_nrseqiteb LIKE crapsir.nrseqite                          NO-UNDO.
DEF VAR tel_dsseqiteb LIKE crapsir.dsseqite                          NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_pesquisa AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contalin AS INT                                   NO-UNDO.

DEF        VAR tel_numdotop AS CHAR                                  NO-UNDO.
DEF        VAR tel_topeitem AS CHAR                                  NO-UNDO.
DEF        VAR tel_topitesq AS CHAR                                  NO-UNDO.

DEF TEMP-TABLE  w_lista                                              NO-UNDO
    FIELDS nrsequen    AS CHAR FORMAT "x(10)" 
    FIELDS descricao   AS CHAR FORMAT "x(50)" 
    FIELDS reg_craptor AS RECID
    FIELDS reg_crapitr AS RECID
    FIELDS reg_crapsir AS RECID
    FIELDs nota        AS DEC  FORMAT "zzz9.99".
     
FORM 
    SKIP (2)
    "Opcao:"      AT 5
     glb_cddopcao AT 12 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (A, C, E, I, R)"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "E" OR glb_cddopcao = "I" OR
                            glb_cddopcao = "R",   "014 - Opcao errada.")
     SKIP(1)
     tel_nrtopico AT  2 LABEL "Nro Topico"  AUTO-RETURN 
                  HELP "Entre com o nro do Topico."
                  VALIDATE (tel_nrtopico > 0,
                            "357 - O campo deve ser preenchido.")
     tel_dstopico AT  2 LABEL "Descricao "   AUTO-RETURN  
                  HELP "Entre com a descricao do Topico."
                  VALIDATE (tel_dstopico <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_inpessoa AT 2 LABEL "Pessoa    "  AUTO-RETURN
                   HELP "Entre com o Tipo de Pessoa(1-Fisica/2-Juridica)"
                   VALIDATE (tel_inpessoa = 1 OR
                             tel_inpessoa = 2,
                             "436 - Tipo de Pessoa errado.")
     SKIP(1)
     tel_nritetop AT  6 LABEL "Nro Item Topico"  AUTO-RETURN
                  HELP "Entre com o nro do Item."
                  VALIDATE (tel_nritetop > 0,
                            "357 - O campo deve ser preenchido.")
     tel_dsitetop AT  6 LABEL "Descricao      "  AUTO-RETURN
                  HELP  "Entre com a descricao do Item"
                  VALIDATE (tel_dsitetop <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_pesoitem AT  6 LABEL "Peso           "  AUTO-RETURN
                  HELP  "Entre com o Peso"
                  VALIDATE (tel_pesoitem > 0,
                           "357 - O campo deve ser preenchido.")
         SKIP (1)
     tel_nrseqite AT 12 LABEL "Nro Seq. " AUTO-RETURN
                  HELP  "Entre com a Sequencia Item"
                  VALIDATE (tel_nrseqite   > 0,
                            "357 - O campo deve ser preenchido.")
     tel_dsseqite AT 12 LABEL "Descricao" AUTO-RETURN
                  HELP  "Entre com a Descricao do Item"
                  VALIDATE (tel_dsseqite <> " ",  
                            "357 - O campo deve ser preenchido.")
     tel_pesosequ AT 12 LABEL "Peso     " AUTO-RETURN
                  HELP  "Entre com o Peso"
                  VALIDATE (tel_pesosequ > 0,
                           "357 - O campo deve ser preenchido.")
     SKIP(1)
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME   
                f_cadrat. 


/* variaveis para mostrar a consulta */          
 
DEF QUERY  bcadrat-q FOR  w_lista. 

DEF BROWSE bcadrat-b QUERY bcadrat-q
      DISPLAY W_lista.nrsequen   LABEL  "SEQ"
              W_lista.descricao  NO-LABEL
              W_lista.nota       LABEL "NOTA"
      WITH 7 DOWN OVERLAY WIDTH 78 CENTERED.
 
FORM
      bcadrat-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
      WITH NO-LABEL ROW 5 COLUMN 2 WIDTH 78 OVERLAY NO-BOX FRAME f_cadratc.

FORM  
     " " AT 1
     tel_numdotop  AT  1  LABEL "Topico"
     tel_dstopicob HELP "Entre com a descricao do Topico."
                   VALIDATE (tel_dstopicob <> " ",
                            "357 - O campo deve ser preenchido.")
     tel_flgativob LABEL "Atv"  AUTO-RETURN
     tel_topeitem  AT 1   LABEL "Item  "
     tel_dsitetopb FORMAT "x(47)" HELP  "Entre com a descricao do Item"
                   VALIDATE (tel_dsitetopb <> " ",
                            "357 - O campo deve ser preenchido.")
     "Peso:"      AT 66
     tel_pesoitemb HELP  "Entre com o Peso"
                   VALIDATE (tel_pesoitemb > 0,
                            "357 - O campo deve ser preenchido.")
      
     tel_topitesq  AT 1   LABEL "Seq.  "
     tel_dsseqiteb FORMAT "x(47)" HELP  "Entre com a Descricao do Item"
                   VALIDATE (tel_dsseqiteb <> " ",  
                            "357 - O campo deve ser preenchido.")
     "Peso:"       AT 66
     tel_pesosequb HELP "Entre com o Peso"
            VALIDATE (tel_pesosequb > 0,
                            "357 - O campo deve ser preenchido.")
     " " AT 1
      WITH NO-LABEL SIDE-LABELS ROW 16 NO-BOX 
     COLUMN 2 NO-ATTR-SPACE OVERLAY WIDTH 77
     FRAME  f_cadratc1.

ON VALUE-CHANGED, ENTRY OF bcadrat-b
   DO:       
      IF  AVAIL w_LISTA THEN 
          DO:

             RUN lista_detalhado.
             
             IF  glb_cddopcao = "E"   THEN
                 MESSAGE "Pressione <ENTER> para Excluir !".
                 
          END.
    END.

ON RETURN OF bcadrat-b
   DO:
      IF  AVAIL w_lista THEN
          DO:

             FIND craptor WHERE RECID(craptor) = w_lista.reg_craptor NO-ERROR.
             FIND crapitr WHERE RECID(crapitr) = w_lista.reg_crapitr NO-ERROR.
             FIND crapsir WHERE RECID(crapsir) = w_lista.reg_crapsir NO-ERROR.

             IF   glb_cddopcao = "A"   THEN
                  DO:
                     UPDATE  tel_dstopicob
                             tel_flgativob  
                             tel_dsitetopb   
                             tel_pesoitemb
                             tel_dsseqiteb  
                             tel_pesosequb
                             WITH FRAME f_cadratc1.

                     RUN atualiza_tabela.

                    ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("bcadrat-q").
                    RUN open_browser.
                    REPOSITION bcadrat-q TO ROW aux_ultlinha.
                    
                    RUN lista_detalhado.
                  
                  END.
             ELSE
             IF   glb_cddopcao = "E"   THEN
                  DO:           
                     aux_confirma = "N".

                     MESSAGE COLOR NORMAL
                         "Deseja realmente excluir este registro ?"
                          UPDATE aux_confirma.
                        
                     IF   CAPS(aux_confirma) = "S"  THEN
                          DO:
                             RUN elimina_tabela.

                             RUN open_browser.
                             
                             RUN lista_detalhado.
                          
                          END.
                  END.      
         END.
   END.

glb_cddopcao = "C".

DO WHILE TRUE:

        RUN carrega_tabela_work.
     
        RUN fontes/inicia.p.

        HIDE MESSAGE.

        DISPLAY glb_cddopcao WITH FRAME f_cadrat.
        NEXT-PROMPT tel_nrtopico WITH FRAME f_cadrat. 

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           UPDATE glb_cddopcao WITH FRAME f_cadrat.
            
           IF   INPUT glb_cddopcao <> "R"   THEN
                UPDATE tel_nrtopico WITH FRAME f_cadrat. 

           LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "cadrat"   THEN
                      DO:
                          HIDE FRAME f_cadrat.
                          HIDE FRAME f_cadratc.
                          RETURN.
                      END.
                 ELSE
                      NEXT.
             END.


        IF   aux_cddopcao <> INPUT glb_cddopcao THEN
             DO:
                 { includes/acesso.i }
                 aux_cddopcao = INPUT glb_cddopcao.
             END.

        ASSIGN tel_dstopico = CAPS(INPUT tel_dstopico)
               glb_cddopcao = INPUT glb_cddopcao.

        IF   CAN-DO("A,E,I",INPUT glb_cddopcao)   THEN 
             DO:
                 IF   glb_cddepart <> 20 AND   /* TI       */    
                      glb_cddepart <> 14 THEN  /* PRODUTOS */    
                      DO:
                          glb_cdcritic = 327.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          NEXT.
                      END.
             END.  
                                
        IF   INPUT glb_cddopcao = "I" THEN
             DO:
                 { includes/cadrati.i }
             END.
        ELSE
             IF   INPUT glb_cddopcao = "C"  OR  
                  INPUT glb_cddopcao = "E"  OR
                  INPUT glb_cddopcao = "A" THEN
                  DO:
                      MESSAGE "Lista browser".
                      RUN lista_browser.
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "R"   THEN
                       RUN fontes/cadrat_r.p.
        
END.

PROCEDURE p_carregabrowser.
          
   RUN open_browser.
     
   ENABLE bcadrat-b    
          WITH FRAME f_cadratc.

   WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

END PROCEDURE.
 
 
PROCEDURE open_browser.    
      
   RUN carrega_tabela_work.
   
   OPEN QUERY bcadrat-q 
        FOR EACH  w_lista NO-LOCK.
END PROCEDURE. 



PROCEDURE lista_browser.

   DISPLAY "" @ tel_nrtopico
           "" @ tel_dstopico
           "" @ tel_nritetop
           "" @ tel_dsitetop
           "" @ tel_nrseqite
           "" @ tel_dsseqite
           "" @ tel_pesoitem
           "" @ tel_pesosequ
           WITH FRAME f_cadrat. 
   PAUSE(0).

   RUN carrega_tabela_work.
   
   RUN p_carregabrowser.

   HIDE FRAME f_cadratc.
END PROCEDURE.


PROCEDURE atualiza_tabela.

   DO TRANSACTION :

       FIND craptor WHERE craptor.cdcooper = glb_cdcooper AND
                          craptor.nrtopico = tel_nrtopicob 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND crapitr WHERE crapitr.cdcooper = glb_cdcooper  AND
                          crapitr.nrtopico = tel_nrtopicob AND
                          crapitr.nritetop = tel_nritetopb 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND LAST crapsir WHERE crapsir.cdcooper = glb_cdcooper  AND
                               crapsir.nrtopico = tel_nrtopicob AND 
                               crapsir.nritetop = tel_nritetopb AND
                               crapsir.nrseqite = tel_nrseqiteb 
                               EXCLUSIVE-LOCK NO-ERROR.

       ASSIGN craptor.dstopico = tel_dstopicob
              craptor.flgativo = tel_flgativob.
       
       ASSIGN crapitr.dsitetop = tel_dsitetopb.

       ASSIGN crapsir.dsseqite = tel_dsseqiteb
              crapitr.pesoitem = tel_pesoitemb
              crapsir.pesosequ = tel_pesosequb.
              
    END. 
END PROCEDURE.


PROCEDURE elimina_tabela.
 
   DO TRANSACTION :
   
       /* Verifica se pode ser excluido (Somente Ratings antigos) */
       FIND FIRST crapras WHERE crapras.cdcooper = glb_cdcooper    AND
                                crapras.nrctrrat = 0               AND
                                crapras.tpctrrat = 0               AND
                                crapras.nrtopico = tel_nrtopicob   AND
                                crapras.nritetop = tel_nritetopb   AND
                                crapras.nrseqite = tel_nrseqiteb 
                                NO-LOCK NO-ERROR.

       IF   AVAILABLE crapras   THEN
            DO:
                glb_cdcritic = 813.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                RETURN.
            END.
 
       FIND craptor WHERE craptor.cdcooper = glb_cdcooper  AND
                          craptor.nrtopico = tel_nrtopicob 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND crapitr WHERE crapitr.cdcooper = glb_cdcooper  AND
                          crapitr.nrtopico = tel_nrtopicob AND
                          crapitr.nritetop = tel_nritetopb 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND LAST crapsir WHERE crapsir.cdcooper = glb_cdcooper  AND
                               crapsir.nrtopico = tel_nrtopicob AND 
                               crapsir.nritetop = tel_nritetopb AND
                               crapsir.nrseqite = tel_nrseqiteb 
                               EXCLUSIVE-LOCK NO-ERROR.
    
       IF  AVAIL crapsir THEN                 
           DELETE crapsir.

       FIND LAST crapsir  WHERE crapsir.cdcooper = glb_cdcooper  AND
                                crapsir.nrtopico = tel_nrtopicob AND 
                                crapsir.nritetop = tel_nritetopb 
                                NO-LOCK NO-ERROR.
   
       IF  NOT AVAIL crapsir THEN 
           DO:
              DELETE crapitr.
           END.
           
       FIND LAST crapitr WHERE crapitr.cdcooper = glb_cdcooper  AND
                               crapitr.nrtopico = tel_nrtopicob 
                               NO-LOCK NO-ERROR.

       IF  NOT AVAIL crapitr THEN
           DO:
              DELETE craptor.
           END.   
  END.
END PROCEDURE.


PROCEDURE  carrega_tabela_work.

   /*FOR EACH    w_lista:
       DELETE w_lista.
   END. */
   
   EMPTY TEMP-TABLE w_lista.
   
   /*--- Gera tabela cadrat --*/
   FOR  EACH craptor NO-LOCK WHERE
             craptor.cdcooper  = glb_cdcooper   AND
             craptor.nrtopico >= tel_nrtopico,
        EACH crapitr NO-LOCK WHERE
             crapitr.cdcooper = glb_cdcooper   AND
             crapitr.nrtopico = craptor.nrtopico,   
        EACH crapsir NO-LOCK WHERE
             crapsir.cdcooper = glb_cdcooper   AND
             crapsir.nrtopico = crapitr.nrtopico   AND
             crapsir.nritetop = crapitr.nritetop  
          BY craptor.nrtopico
             BY crapitr.nritetop 
                BY crapsir.nrseqite.
        
        CREATE w_lista.
        ASSIGN w_lista.nrsequen = TRIM(STRING(craptor.nrtopico)) + "." +
                                  TRIM(STRING(crapitr.nritetop)) + "." +
                                  TRIM(STRING(crapsir.nrseqite)).
        ASSIGN w_lista.descricao   = crapsir.dsseqite
               w_lista.reg_craptor = RECID(craptor)
               w_lista.reg_crapitr = RECID(crapitr)
               w_lista.reg_crapsir = RECID(crapsir)
               w_lista.nota        = crapitr.pesoitem * crapsir.pesosequ.
   END.
END PROCEDURE.


PROCEDURE lista_detalhado.

   
   IF  AVAIL w_lista THEN
       DO:
          
          FIND craptor WHERE RECID(craptor) = w_lista.reg_craptor NO-ERROR.
          FIND crapitr WHERE RECID(crapitr) = w_lista.reg_crapitr NO-ERROR.
          FIND crapsir WHERE RECID(crapsir) = w_lista.reg_crapsir NO-ERROR.
          
          ASSIGN 
               tel_nrtopicob = craptor.nrtopico 
               tel_dstopicob = craptor.dstopico 
               tel_flgativob = craptor.flgativo
               tel_nritetopb = crapitr.nritetop  
               tel_dsitetopb = crapitr.dsitetop  
               tel_nrseqiteb = crapsir.nrseqite    
               tel_dsseqiteb = crapsir.dsseqite   
               tel_pesoitemb = crapitr.pesoitem
               tel_numdotop  = TRIM(STRING(craptor.nrtopico))
               tel_topeitem  = tel_numdotop + "." +
                               TRIM(STRING(crapitr.nritetop))
               tel_topitesq  = tel_topeitem + "." +
                               TRIM(STRING(crapsir.nrseqite))
               tel_pesosequb  = crapsir.pesosequ.
          DISPLAY
               tel_dstopicob  
               tel_flgativob
               tel_dsitetopb                     
               tel_dsseqiteb    
               tel_pesoitemb
               tel_numdotop
               tel_topeitem
               tel_topitesq
               tel_pesosequb
               WITH FRAME f_cadratc1.
       END.
   ELSE
       DO:
          HIDE FRAME   f_cadratc1.
       END.
END PROCEDURE. 
 


/* ....................................................................... */

 
