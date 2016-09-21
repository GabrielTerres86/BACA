/* .............................................................................

   Programa: Fontes/ratcad.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Fernando   
   Data    : Setembro/2009                    Ultima Atualizacao: 02/03/2011    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir efetuar o cadastramento dos Parametros ratcad      

   NOTA      : ESTA TELA NAO PERMITE ATERACAO, INCLUSAO NEM EXCLUSAO POIS
               AO MUDAR OS ITENS, A BO DE CALCULO DO RATING (b1wgen0043)
               NAO ESTARA CAPACITADA PARA REALIZAR O DEVIDO TRATAMENTO.
               SE FOR PRECISO MUDAR A DESCRICAO DESTES RATINGS, VERIFICAR
               SE ISTO NAO IMPLICA EM PROBLEMAS NA BO DO RATING. (Gabriel).
               
               02/03/2011 - Inclusao do campo "Avaliacao" que indicara se o
                            item pertence a nota do cooperado ou a nota da
                            operacao. (Fabricio)
                                             
   Alteracoes: 
............................................................................. */

{ includes/var_online.i } 

DEF VAR aux_ultlinha  AS INTE                                         NO-UNDO.
DEF VAR tel_nrtopico  LIKE craprat.nrtopico                           NO-UNDO.
DEF VAR tel_dstopico  LIKE craprat.dstopico                           NO-UNDO.
DEF VAR tel_inpessoa  AS CHAR FORMAT "x(15)"                          NO-UNDO.
DEF VAR tel_intopico  AS CHAR FORMAT "x(15)"                          NO-UNDO.
DEF VAR tel_nritetop  LIKE craprai.nritetop                           NO-UNDO. 
DEF VAR tel_dsitetop  LIKE craprai.dsitetop                           NO-UNDO.
DEF VAR tel_pesoitem  LIKE craprai.pesoitem                           NO-UNDO.
DEF VAR tel_nrseqite  LIKE craprad.nrseqite                           NO-UNDO.
DEF VAR tel_dsseqite  LIKE craprad.dsseqite                           NO-UNDO.
DEF VAR tel_pesosequ  LIKE craprad.pesosequ                           NO-UNDO.

DEF VAR tel_nrtopicob LIKE craprat.nrtopico                           NO-UNDO.
DEF VAR tel_dstopicob LIKE craprat.dstopico                           NO-UNDO.
DEF VAR tel_flgativob LIKE craprat.flgativo                           NO-UNDO.
DEF VAR tel_nritetopb LIKE craprai.nritetop                           NO-UNDO.
DEF VAR tel_dsitetopb LIKE craprai.dsitetop                           NO-UNDO.
DEF VAR tel_pesoitemb LIKE craprai.pesoitem                           NO-UNDO.
DEF VAR tel_pesosequb LIKE craprad.pesosequ                           NO-UNDO.
DEF VAR tel_nrseqiteb LIKE craprad.nrseqite                           NO-UNDO.
DEF VAR tel_dsseqiteb LIKE craprad.dsseqite                           NO-UNDO.
                                                                   
DEF VAR aux_confirma  AS CHAR    FORMAT "!(1)"                        NO-UNDO.
DEF VAR aux_contador  AS INTE    FORMAT "z9"                          NO-UNDO.
DEF VAR aux_cddopcao  AS CHAR                                         NO-UNDO.
                                                                   
DEF VAR aux_pesquisa  AS LOGI    FORMAT "S/N"                         NO-UNDO.
DEF VAR aux_regexist  AS LOGI                                         NO-UNDO.
DEF VAR aux_flgretor  AS LOGI                                         NO-UNDO.
DEF VAR aux_contalin  AS INT                                          NO-UNDO.
                                                                   
DEF VAR tel_numdotop  AS CHAR                                         NO-UNDO.
DEF VAR tel_topeitem  AS CHAR                                         NO-UNDO.
DEF VAR tel_topitesq  AS CHAR                                         NO-UNDO.
DEF VAR aux_intopico  AS CHAR FORMAT "x(15)"                          NO-UNDO.
                                                                   
DEF TEMP-TABLE  w_lista                                               NO-UNDO
    FIELDS nrsequen    AS CHAR FORMAT "x(10)" 
    FIELDS descricao   AS CHAR FORMAT "x(50)" 
    FIELDS reg_craprat AS RECID
    FIELDS reg_craprai AS RECID
    FIELDS reg_craprad AS RECID
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
     tel_inpessoa AT 2 LABEL "Pessoa    " AUTO-RETURN
                   HELP "Entre com o Tipo de Pessoa(1-Fisica/2-Juridica)"
                   VALIDATE (tel_inpessoa = "1" OR
                             tel_inpessoa = "2",
                             "436 - Tipo de Pessoa errado.")
     tel_intopico AT 2 LABEL "Avaliacao " AUTO-RETURN
                   HELP "Entre com o Tipo da Avaliacao(1-Cooperado/2-Operacao)"
                   VALIDATE (tel_intopico = "1" OR
                             tel_intopico = "2",
                             "014 - Opcao errada.")
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
                f_ratcad. 


/* variaveis para mostrar a consulta */           
DEF QUERY  bratcad-q FOR  w_lista. 

DEF BROWSE bratcad-b QUERY bratcad-q
    DISPLAY W_lista.nrsequen   LABEL  "SEQ"
            W_lista.descricao  NO-LABEL
            W_lista.nota       LABEL "NOTA"
    WITH 7 DOWN OVERLAY WIDTH 78 CENTERED.
 
FORM
      bratcad-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
      WITH NO-LABEL ROW 5 COLUMN 2 WIDTH 78 OVERLAY NO-BOX FRAME f_ratcadc.

FORM  
    /* " " AT 1*/
     tel_intopico  AT  1  LABEL "Aval. " FORMAT "x(1)" AUTO-RETURN
                   HELP "Entre com o Tipo da Avaliacao(1-Cooperado/2-Operacao)"
                   VALIDATE (tel_intopico = "1" OR
                             tel_intopico = "2",
                             "014 - Opcao errada.")
     "      "
     aux_intopico
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
     
            COLUMN 2 NO-ATTR-SPACE OVERLAY WIDTH 77 FRAME  f_ratcadc1.


ON VALUE-CHANGED, ENTRY OF bratcad-b
   DO:       
      IF  AVAIL w_LISTA THEN 
          DO:
             RUN lista_detalhado.
             
             IF  glb_cddopcao = "E"   THEN
                 MESSAGE "Pressione <ENTER> para Excluir !".
                 
          END.
    END.

ON RETURN OF bratcad-b
   DO:
      IF  AVAIL w_lista THEN
          DO:

             FIND craprat WHERE RECID(craprat) = w_lista.reg_craprat NO-ERROR.
             FIND craprai WHERE RECID(craprai) = w_lista.reg_craprai NO-ERROR.
             FIND craprad WHERE RECID(craprad) = w_lista.reg_craprad NO-ERROR.

             IF   glb_cddopcao = "A"   THEN
                  DO:
                     UPDATE  tel_intopico
                             tel_dstopicob
                             tel_flgativob  
                             tel_dsitetopb   
                             tel_pesoitemb
                             tel_dsseqiteb  
                             tel_pesosequb
                             WITH FRAME f_ratcadc1.

                     RUN atualiza_tabela.

                     ASSIGN aux_ultlinha = CURRENT-RESULT-ROW("bratcad-q").
                     RUN open_browser.
                     REPOSITION bratcad-q TO ROW aux_ultlinha.
                    
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

   DISPLAY glb_cddopcao WITH FRAME f_ratcad.
   
   NEXT-PROMPT tel_nrtopico WITH FRAME f_ratcad. 

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      UPDATE glb_cddopcao WITH FRAME f_ratcad.
       
      IF   INPUT glb_cddopcao <> "R"   THEN
           UPDATE tel_nrtopico WITH FRAME f_ratcad. 

      LEAVE.
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "ratcad"   THEN
                 DO:
                     HIDE FRAME f_ratcad.
                     HIDE FRAME f_ratcadc.
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
            IF   glb_dsdepart <> "TI"         AND
                 glb_dsdepart <> "PRODUTOS"   AND
                 glb_dsdepart <> "FINANCEIRO" THEN  
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
            { includes/ratcadi.i }
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
        RUN fontes/ratcad_r.p.
        
END. /* Fim DO WHILE TRUE */


PROCEDURE p_carregabrowser.
          
   RUN open_browser.
     
   ENABLE bratcad-b    
          WITH FRAME f_ratcadc.

   WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.

END PROCEDURE.
 
 
PROCEDURE open_browser.    
      
   RUN carrega_tabela_work.
   
   OPEN QUERY bratcad-q FOR EACH  w_lista NO-LOCK.

END PROCEDURE. 


PROCEDURE lista_browser.

   DISPLAY "" @ tel_nrtopico
           "" @ tel_dstopico
           "" @ tel_inpessoa
           "" @ tel_intopico
           "" @ tel_nritetop
           "" @ tel_dsitetop
           "" @ tel_nrseqite
           "" @ tel_dsseqite
           "" @ tel_pesoitem
           "" @ tel_pesosequ
           WITH FRAME f_ratcad. 

   PAUSE(0).

   RUN carrega_tabela_work.
   
   RUN p_carregabrowser.

   HIDE FRAME f_ratcadc.

END PROCEDURE.


PROCEDURE atualiza_tabela.

   DO TRANSACTION :

       FIND craprat WHERE craprat.cdcooper = glb_cdcooper AND
                          craprat.nrtopico = tel_nrtopicob 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND craprai WHERE craprai.cdcooper = glb_cdcooper  AND
                          craprai.nrtopico = tel_nrtopicob AND
                          craprai.nritetop = tel_nritetopb 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND LAST craprad WHERE craprad.cdcooper = glb_cdcooper  AND
                               craprad.nrtopico = tel_nrtopicob AND 
                               craprad.nritetop = tel_nritetopb AND
                               craprad.nrseqite = tel_nrseqiteb 
                               EXCLUSIVE-LOCK NO-ERROR.

       ASSIGN craprat.intopico = INT(tel_intopico)
              craprat.dstopico = tel_dstopicob
              craprat.flgativo = tel_flgativob.
       
       ASSIGN craprai.dsitetop = tel_dsitetopb.

       ASSIGN craprad.dsseqite = tel_dsseqiteb
              craprai.pesoitem = tel_pesoitemb
              craprad.pesosequ = tel_pesosequb.
              
    END.

END PROCEDURE.


PROCEDURE elimina_tabela.
 
   DO TRANSACTION :
   
       /* verifica se pode ser excluido */
       FIND FIRST crapras WHERE crapras.cdcooper = glb_cdcooper    AND
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
 
       FIND craprat WHERE craprat.cdcooper = glb_cdcooper  AND
                          craprat.nrtopico = tel_nrtopicob 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND craprai WHERE craprai.cdcooper = glb_cdcooper  AND
                          craprai.nrtopico = tel_nrtopicob AND
                          craprai.nritetop = tel_nritetopb 
                          EXCLUSIVE-LOCK NO-ERROR.

       FIND LAST craprad WHERE craprad.cdcooper = glb_cdcooper  AND
                               craprad.nrtopico = tel_nrtopicob AND 
                               craprad.nritetop = tel_nritetopb AND
                               craprad.nrseqite = tel_nrseqiteb 
                               EXCLUSIVE-LOCK NO-ERROR.
    
       IF  AVAIL craprad THEN                 
           DELETE craprad.

       FIND LAST craprad  WHERE craprad.cdcooper = glb_cdcooper  AND
                                craprad.nrtopico = tel_nrtopicob AND 
                                craprad.nritetop = tel_nritetopb 
                                NO-LOCK NO-ERROR.
   
       IF  NOT AVAIL craprad THEN 
           DO:
              DELETE craprai.
           END.
           
       FIND LAST craprai WHERE craprai.cdcooper = glb_cdcooper  AND
                               craprai.nrtopico = tel_nrtopicob 
                               NO-LOCK NO-ERROR.

       IF  NOT AVAIL craprai THEN
           DO:
              DELETE craprat.
           END.     
   END.

END PROCEDURE.


PROCEDURE  carrega_tabela_work.

   EMPTY TEMP-TABLE w_lista.
   
   /*--- Gera tabela ratcad --*/
   FOR  EACH craprat NO-LOCK WHERE
             craprat.cdcooper  = glb_cdcooper      AND
             craprat.nrtopico >= tel_nrtopico,
        EACH craprai NO-LOCK WHERE
             craprai.cdcooper = glb_cdcooper       AND
             craprai.nrtopico = craprat.nrtopico,   
        EACH craprad NO-LOCK WHERE
             craprad.cdcooper = glb_cdcooper       AND
             craprad.nrtopico = craprai.nrtopico   AND
             craprad.nritetop = craprai.nritetop  
          BY craprad.nrtopico
             BY craprai.nritetop 
                BY craprad.nrseqite.
        
        CREATE w_lista.
        ASSIGN w_lista.nrsequen = TRIM(STRING(craprat.nrtopico)) + "." +
                                  TRIM(STRING(craprai.nritetop)) + "." +
                                  TRIM(STRING(craprad.nrseqite)).
        ASSIGN w_lista.descricao   = craprad.dsseqite
               w_lista.reg_craprat = RECID(craprat)
               w_lista.reg_craprai = RECID(craprai)
               w_lista.reg_craprad = RECID(craprad)
               w_lista.nota        = craprai.pesoitem * craprad.pesosequ.
   END.

END PROCEDURE.


PROCEDURE lista_detalhado.
 
   IF  AVAIL w_lista THEN
       DO:
           FIND craprat WHERE RECID(craprat) = w_lista.reg_craprat NO-ERROR.
           
           FIND craprai WHERE RECID(craprai) = w_lista.reg_craprai NO-ERROR.
           
           FIND craprad WHERE RECID(craprad) = w_lista.reg_craprad NO-ERROR.
          
           ASSIGN tel_nrtopicob = craprat.nrtopico 
                  tel_dstopicob = craprat.dstopico 
                  tel_flgativob = craprat.flgativo
                  tel_nritetopb = craprai.nritetop  
                  tel_dsitetopb = craprai.dsitetop  
                  tel_nrseqiteb = craprad.nrseqite    
                  tel_dsseqiteb = craprad.dsseqite   
                  tel_pesoitemb = craprai.pesoitem
                  tel_numdotop  = TRIM(STRING(craprat.nrtopico))
                  tel_topeitem  = tel_numdotop + "." +
                                  TRIM(STRING(craprai.nritetop))
                  tel_topitesq  = tel_topeitem + "." +
                                  TRIM(STRING(craprad.nrseqite))
                  tel_pesosequb = craprad.pesosequ
                  tel_intopico  = TRIM(STRING(craprat.intopico)).
                  
           IF craprat.intopico = 1 THEN
               ASSIGN aux_intopico = "Cooperado".
           ELSE
               ASSIGN aux_intopico = "Operacao".
          
           DISPLAY tel_dstopicob  
                   tel_flgativob
                   tel_dsitetopb                     
                   tel_dsseqiteb    
                   tel_pesoitemb
                   tel_numdotop
                   tel_topeitem
                   tel_topitesq
                   tel_pesosequb
                   tel_intopico
                   aux_intopico WITH FRAME f_ratcadc1.
       END.
   ELSE
       DO:
          HIDE FRAME   f_ratcadc1.
       END.

END PROCEDURE. 
 


/* ....................................................................... */

 
