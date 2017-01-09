/* .............................................................................

   Programa: Fontes/cadtel.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Sidnei (Precise)
   Data    : Outubro/2008                 Ultima Atualizacao: 31/11/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Permitir efetuar o cadastramento das telas. Tela utilizada
               apenas pela operacao "1" (USUARIO SISTEMAS)

   ALTERACAO : 11/05/2009 - Alteracao CDOPERAD (Kbase).

               10/11/2010 - Permitir cadastro do modulo ate o 14
                            (Gabriel)
                            
               22/02/2013 - Retirado campo flgdonet e adicionado campo idambtel
                            'Ambiente Acesso" (Jorge). 
                            
               12/02/2014 - Adicionado confirmação nas opcoes A e I (Lucas).
               
               16/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

               30/11/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
               
                            
............................................................................. */

{ includes/var_online.i } 
{ includes/listel.i NEW }

DEF NEW SHARED VAR shr_nmdatela AS CHAR                        NO-UNDO.
DEF NEW SHARED VAR shr_nmrotina AS CHAR                        NO-UNDO.
DEF NEW SHARED VAR shr_inpessoa AS INT                         NO-UNDO.
                                                         

DEF        VAR tel_nmdatela LIKE craptel.nmdatela              NO-UNDO.
DEF        VAR tel_nrmodulo LIKE craptel.nrmodulo              NO-UNDO.
DEF        VAR tel_cdopptel LIKE craptel.cdopptel              NO-UNDO.
DEF        VAR tel_tldatela LIKE craptel.tldatela              NO-UNDO.
DEF        VAR tel_tlrestel LIKE craptel.tlrestel              NO-UNDO.
DEF        VAR tel_flgteldf LIKE craptel.flgteldf              NO-UNDO.
DEF        VAR tel_flgtelbl LIKE craptel.flgtelbl              NO-UNDO.
DEF        VAR tel_nmrotina LIKE craptel.nmrotina              NO-UNDO.
DEF        VAR tel_lsoppte1 AS CHAR    FORMAT "X(50)"          NO-UNDO.
DEF        VAR tel_lsoppte2 AS CHAR    FORMAT "X(50)"          NO-UNDO.
DEF        VAR tel_lsoppte3 AS CHAR    FORMAT "X(50)"          NO-UNDO.
DEF        VAR tel_inacesso LIKE craptel.inacesso              NO-UNDO.
DEF        VAR tel_idsistem LIKE craptel.idsistem              NO-UNDO.
DEF        VAR tel_idevento LIKE craptel.idevento              NO-UNDO.
DEF        VAR tel_nrordrot LIKE craptel.nrordrot              NO-UNDO.
DEF        VAR tel_idambtel LIKE craptel.idambtel              NO-UNDO.
DEF        VAR tel_nrdnivel LIKE craptel.nrdnivel              NO-UNDO.
DEF        VAR tel_nmrotpai LIKE craptel.nmrotpai              NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"           NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"             NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                            NO-UNDO.
DEF        VAR aux_temassoc AS LOGICAL                         NO-UNDO.

DEF        VAR aux_pesquisa AS LOGICAL FORMAT "S/N"            NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                         NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                         NO-UNDO.
DEF        VAR aux_contalin AS INT                             NO-UNDO.

DEF VAR aux_dadosusr         AS CHAR                            NO-UNDO.
DEF VAR par_loginusr         AS CHAR                            NO-UNDO.
DEF VAR par_nmusuari         AS CHAR                            NO-UNDO.
DEF VAR par_dsdevice         AS CHAR                            NO-UNDO.
DEF VAR par_dtconnec         AS CHAR                            NO-UNDO.
DEF VAR par_numipusr         AS CHAR                            NO-UNDO.
DEF VAR h-b1wgen9999         AS HANDLE                          NO-UNDO.


FORM SKIP(1)
     "Opcao:"     AT 3
     glb_cddopcao AT 10 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada (A, C, E, V ou I)."
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "V" OR glb_cddopcao = "I" OR
                            glb_cddopcao = "E",
                            "014 - Opcao errada.")
     SKIP(1)
     tel_nmdatela AT 10 LABEL "Nome"  AUTO-RETURN
                  HELP "Informe o nome da tela - F7 para listar"
     tel_nmrotina AT 10 LABEL "Rotina" 
                  HELP "Informe o nome da rotina - F7 para listar"
     tel_nrmodulo AT 55 LABEL "Nr. Modulo" AUTO-RETURN
                  HELP "Entre com o nro do modulo (Deve ser 1,2,3,4,5)."
                  VALIDATE (tel_nrmodulo >= 1 AND tel_nrmodulo <=14,
                            "014 - Modulo incorreto.") SKIP
     tel_tldatela AT 10 LABEL "Titulo Tela" AUTO-RETURN
                  HELP  "Entre com o titulo da tela"
     tel_tlrestel AT 10 LABEL "Titulo Resumido" AUTO-RETURN 
                  HELP  "Entre com o titulo resumido da tela"    
     SKIP
     tel_cdopptel AT 10 LABEL "Opcoes da Tela"  AUTO-RETURN
                  HELP "Entre com as opcoes da tela."  SKIP
     tel_lsoppte1 AT 10 LABEL "Opcoes da Rotina" AUTO-RETURN
                  HELP "Entre com as opcoes da rotina."  SKIP
     tel_lsoppte2 AT 28 NO-LABEL AUTO-RETURN
                  HELP "Entre com as opcoes da rotina (continuacao 2a linha)"
     SKIP
     tel_lsoppte3 AT 28 NO-LABEL AUTO-RETURN
                  HELP "Entre com as opcoes da rotina (continuacao 3a linha)"
     SKIP(1)
     tel_flgteldf AT 10 LABEL "Tela Default"
                  HELP "Entre com SIM para Default ou Nao caso contrario"
     tel_flgtelbl AT 30 LABEL "Situacao"
                  HELP "Entre com a situacao da tela (Liberada/Bloqueada)"
     tel_idambtel AT 55 LABEL "Ambiente Acesso"
                  HELP "Ambiente de Acesso (0-Todos 1-Caracter 2-Web)" SKIP
     tel_inacesso AT 10 LABEL "Acesso"  
                  HELP "Indicador Acesso(0-Nao/1-Apos Solic./2-Durante Proc.)"
     tel_idsistem AT 30 LABEL "Sistema" 
                  HELP "Identificacao do Sistema (1-Ayllos, 2-Progrid)"
     tel_idevento AT 55 LABEL "Evento"   
                  HELP "Identificacao do Modulo (1-Progrid 2-Assembleias)" SKIP
     tel_nrordrot AT 10 LABEL "Nr. Ordem"
                  HELP "Informe a ordem de apresentacao da rotina na tela"
     tel_nrdnivel AT 10 LABEL "Nivel"
                  HELP "Informe o Nivel de apresentacao da tela"
     tel_nmrotpai AT 30 LABEL "Rotina Pai"
                  HELP "Informe o nome da rotina pai - F7 para listar"
     WITH ROW 4 SIDE-LABELS TITLE glb_tldatela OVERLAY WIDTH 80 FRAME f_tela.

/* variaveis para mostrar a consulta */
DEF QUERY  brotinas-q FOR craptel.
DEF BROWSE brotinas-b QUERY brotinas-q
      DISP craptel.nmrotina COLUMN-LABEL "Rotina"
           SPACE(1)
           craptel.nrordrot COLUMN-LABEL "Ordem"
           SPACE(1)           
           craptel.nrdnivel COLUMN-LABEL "Nivel"
           SPACE(1)
           craptel.nmrotpai COLUMN-LABEL "Rotina Pai"
           WITH  9  DOWN OVERLAY.    

DEF FRAME f_rotinas
          brotinas-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

ON ENTER OF brotinas-b IN FRAME f_rotinas
   DO:
       /* selecionou rotina via browser e retorna para tela */
       ASSIGN  tel_nmrotina = craptel.nmrotina.
       DISPLAY tel_nmrotina WITH FRAME f_tela.
       
       APPLY "END-ERROR".
   END.
   
glb_cddopcao = "C".

DO WHILE TRUE:
        
        RUN fontes/inicia.p.
        
        DISPLAY glb_cddopcao WITH FRAME f_tela.
        NEXT-PROMPT tel_nmdatela WITH FRAME f_tela.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           SET glb_cddopcao 
               WITH FRAME f_tela.
        
           LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "CADTEL"   THEN
                      DO:
                          HIDE FRAME f_tela.
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

        /*critica para permitir somente o departamento: TI */
        IF   glb_cddepart <> 20 THEN
             DO:
                 glb_cdcritic = 36.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 NEXT.
             END.

        DO WHILE TRUE:
               UPDATE tel_nmdatela WITH FRAME f_tela

               EDITING:
               READKEY.

               IF   LASTKEY = KEYCODE("F7") THEN
                    DO:
                         IF   FRAME-FIELD = "tel_nmdatela"   THEN
                             DO:
                                 ASSIGN shr_nmdatela = tel_nmdatela.
                                 RUN fontes/zoom_tela.p.
                                 IF   shr_nmdatela <> "" THEN
                                      DO:
                                         ASSIGN
                                             tel_nmdatela = shr_nmdatela.
                                         DISPLAY tel_nmdatela
                                                 WITH FRAME f_tela.
                                     END.
                             END.
                    END.
                    ELSE
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                         UNDO, LEAVE.
                    ELSE
                         APPLY LASTKEY.
              END.  /*  Fim do EDITING  */
              
              LEAVE.
        END.
           
        ASSIGN tel_nmdatela = CAPS(INPUT tel_nmdatela).
        DISPLAY tel_nmdatela WITH FRAME f_tela.

        DO WHILE TRUE:                                
              UPDATE tel_nmrotina WITH FRAME f_tela

              EDITING:
                  READKEY.

               IF   LASTKEY = KEYCODE("F7") THEN
                    DO:
                         IF   FRAME-FIELD = "tel_nmrotina"   THEN
                             DO:
                                 ASSIGN shr_nmdatela = tel_nmdatela.
                                 RUN fontes/zoom_rotina.p.
                              /* IF   shr_nmrotina <> "" THEN */
                                      DO:
                                         ASSIGN  tel_nmrotina = shr_nmrotina.
                                         DISPLAY tel_nmrotina
                                                 WITH FRAME f_tela.
                                     END.
                             END.
                    END.
                    ELSE
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                         UNDO, LEAVE.
                    ELSE
                         APPLY LASTKEY.

              END.  /*  Fim do EDITING  */
              
              LEAVE.
        END.
              
        ASSIGN tel_nmrotina = CAPS(INPUT tel_nmrotina).
        DISPLAY tel_nmrotina WITH FRAME f_tela.

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                  RUN altera_tela.
             END.
        ELSE
             IF   INPUT glb_cddopcao = "V" THEN
                  DO:
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            PAUSE(0).
                           
                            OPEN QUERY brotinas-q
                                 FOR  EACH craptel NO-LOCK 
                                 WHERE craptel.cdcooper = glb_cdcooper
                                   AND craptel.nmdatela = tel_nmdatela
                                    BY craptel.nrordrot 
                                    BY craptel.nrdnivel.
                      
                            ENABLE brotinas-b    
                              WITH FRAME f_rotinas.

                            WAIT-FOR WINDOW-CLOSE OF CURRENT-WINDOW.
                      
                            LEAVE.
                         END.
                         HIDE FRAME f_rotinas.
                         
                         RUN consulta_tela.
                  END.
             ELSE
                  IF   INPUT glb_cddopcao = "E"   THEN
                       DO:
                           RUN excluir_tela.
                       END.
                  ELSE
                       IF   INPUT glb_cddopcao = "I"   THEN
                            DO:
                                  RUN insere_tela.
                            END.
                       ELSE
                            IF   INPUT glb_cddopcao = "C"   THEN
                                 DO:
                                       RUN consulta_tela.
                                 END.
                       
END.

/***************************************************************************/
PROCEDURE consulta_tela:
       
     IF   tel_nmdatela <> "" THEN
     DO:
          FIND FIRST craptel WHERE 
               craptel.cdcooper = glb_cdcooper AND
               craptel.nmdatela = tel_nmdatela AND 
               craptel.nmrotina = tel_nmrotina
               NO-LOCK NO-ERROR NO-WAIT.

          IF   AVAILABLE craptel   THEN
               DO:
                   ASSIGN tel_nmdatela = craptel.nmdatela
                          tel_nrmodulo = craptel.nrmodulo
                          tel_cdopptel = craptel.cdopptel
                          tel_tldatela = craptel.tldatela
                          tel_tlrestel = craptel.tlrestel
                          tel_flgteldf = craptel.flgteldf
                          tel_flgtelbl = craptel.flgtelbl
                          tel_nmrotina = craptel.nmrotina
                          tel_lsoppte1 = 
                             SUBSTR(craptel.lsopptel,  1, 50)
                          tel_lsoppte2 = 
                             SUBSTR(craptel.lsopptel, 51, 100)
                          tel_lsoppte3 = 
                             SUBSTR(craptel.lsopptel, 101,150)
                          tel_inacesso = craptel.inacesso
                          tel_idsistem = craptel.idsistem
                          tel_idevento = craptel.idevento
                          tel_nrordrot = craptel.nrordrot
                          tel_idambtel = craptel.idambtel
                          tel_nrdnivel = craptel.nrdnivel
                          tel_nmrotpai = craptel.nmrotpai.
                          
                   DISPLAY tel_nmdatela
                           tel_nrmodulo
                           tel_cdopptel
                           tel_tldatela
                           tel_tlrestel
                           tel_flgteldf
                           tel_flgtelbl
                           tel_nmrotina
                           tel_lsoppte1
                           tel_lsoppte2
                           tel_lsoppte3
                           tel_inacesso
                           tel_idsistem
                           tel_idevento
                           tel_nrordrot
                           tel_idambtel
                           tel_nrdnivel
                           tel_nmrotpai 
                           WITH FRAME f_tela.
                   
                   ASSIGN glb_cdcritic = 0.
               END.
          ELSE
               DO:
                   ASSIGN glb_cdcritic = 322.
                   RUN fontes/critic.p.
                   BELL.
                   MESSAGE glb_dscritic.
                   CLEAR FRAME f_tela.
                   DISPLAY tel_nmdatela WITH FRAME f_tela.
                   NEXT.
               END.
     END.

END PROCEDURE.

/***************************************************************************/
PROCEDURE altera_tela:

DO TRANSACTION ON ENDKEY UNDO, LEAVE:

   DO  aux_contador = 1 TO 10:

       FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper
                            AND craptel.nmdatela = tel_nmdatela
                            AND craptel.nmrotina = tel_nmrotina
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptel   THEN
            IF   LOCKED craptel   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
            			PERSISTENT SET h-b1wgen9999.
            
            		RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptel),
            									   INPUT "banco",
            									   INPUT "craptel",
            									  OUTPUT par_loginusr,
            									  OUTPUT par_nmusuari,
            									  OUTPUT par_dsdevice,
            									  OUTPUT par_dtconnec,
            									  OUTPUT par_numipusr).
            
            		DELETE PROCEDURE h-b1wgen9999.
            
            		ASSIGN aux_dadosusr = 
            			 "077 - Tabela sendo alterada p/ outro terminal.".
            
            		DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            			MESSAGE aux_dadosusr.
            			PAUSE 3 NO-MESSAGE.
            			LEAVE.
            		END.
            
            		ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
            							  " - " + par_nmusuari + ".".
            
            		HIDE MESSAGE NO-PAUSE.
            
            		DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            			MESSAGE aux_dadosusr.
            			PAUSE 5 NO-MESSAGE.
            			LEAVE.
            		END.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 322.
                     LEAVE.
                 END.
       ELSE
            DO:
                aux_contador = 0.
                LEAVE.
            END.
   END.

   IF   aux_contador <> 0   THEN
        DO:
            RUN fontes/critic.p.             
            BELL.
            MESSAGE glb_dscritic.
            NEXT.
        END.

   ASSIGN tel_nmdatela = craptel.nmdatela
          tel_nrmodulo = craptel.nrmodulo
          tel_cdopptel = craptel.cdopptel
          tel_tldatela = craptel.tldatela
          tel_tlrestel = craptel.tlrestel
          tel_flgteldf = craptel.flgteldf
          tel_flgtelbl = craptel.flgtelbl
          tel_nmrotina = craptel.nmrotina
          tel_lsoppte1 = SUBSTR(craptel.lsopptel,  1, 50)
          tel_lsoppte2 = SUBSTR(craptel.lsopptel, 51, 100)
          tel_lsoppte3 = SUBSTR(craptel.lsopptel, 101,150)
          tel_inacesso = craptel.inacesso
          tel_idsistem = craptel.idsistem
          tel_idevento = craptel.idevento
          tel_nrordrot = craptel.nrordrot
          tel_idambtel = craptel.idambtel
          tel_nrdnivel = craptel.nrdnivel
          tel_nmrotpai = craptel.nmrotpai.
                                                  
   DISPLAY tel_nmdatela
           tel_nrmodulo
           tel_cdopptel
           tel_tldatela
           tel_tlrestel
           tel_flgteldf
           tel_flgtelbl
           tel_nmrotina
           tel_lsoppte1
           tel_lsoppte2
           tel_lsoppte3
           tel_inacesso
           tel_idsistem
           tel_idevento
           tel_nrordrot
           tel_idambtel
           tel_nrdnivel
           tel_nmrotpai
           WITH FRAME f_tela.
                      
   DO  WHILE TRUE:
       SET tel_nrmodulo
           tel_tldatela
           tel_tlrestel
           tel_cdopptel
           tel_lsoppte1
           tel_lsoppte2
           tel_lsoppte3
           tel_flgteldf
           tel_flgtelbl
           tel_idambtel
           tel_inacesso
           tel_nrordrot
           tel_nrdnivel
           tel_nmrotpai
           WITH FRAME f_tela

           EDITING:
              READKEY.

               IF   LASTKEY = KEYCODE("F7") THEN
                    DO:
                         IF   FRAME-FIELD = "tel_nmrotpai"   THEN
                             DO:
                                 ASSIGN shr_nmdatela = tel_nmdatela.
                                 RUN fontes/zoom_rotina.p.
                              /* IF   shr_nmrotina <> "" THEN */
                                      DO:
                                         ASSIGN  tel_nmrotpai = shr_nmrotina.
                                         DISPLAY tel_nmrotpai
                                                 WITH FRAME f_tela.
                                     END.
                             END.
                    END.
                    ELSE
                    IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                         UNDO, LEAVE.
                    ELSE
                         APPLY LASTKEY.

           END.  /*  Fim do EDITING  */

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

          ASSIGN aux_confirma = "N"
          glb_cdcritic = 78.
              
          RUN fontes/critic.p.
          BELL.
          MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
          LEAVE.
       END.
                                
       IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
          aux_confirma <> "S" THEN
          DO:
              glb_cdcritic = 79.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              glb_cdcritic = 0.
              NEXT.
          END.
    
       IF aux_confirma = "S" THEN
          DO:
               ASSIGN craptel.nmdatela = tel_nmdatela
                      craptel.nrmodulo = tel_nrmodulo
                      craptel.cdopptel = tel_cdopptel
                      craptel.tldatela = tel_tldatela
                      craptel.tlrestel = tel_tlrestel
                      craptel.flgteldf = tel_flgteldf
                      craptel.flgtelbl = tel_flgtelbl
                      craptel.nmrotina = tel_nmrotina
                      craptel.lsopptel = tel_lsoppte1 + tel_lsoppte2 + tel_lsoppte3
                      craptel.inacesso = tel_inacesso
                      craptel.idsistem = tel_idsistem
                      craptel.idevento = tel_idevento
                      craptel.nrordrot = tel_nrordrot
                      craptel.idambtel = tel_idambtel
                      craptel.nrdnivel = tel_nrdnivel
                      craptel.nmrotpai = tel_nmrotpai.
          END.
       LEAVE.
   END.

END. /* Fim da transacao */

RELEASE craptel.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

CLEAR FRAME f_tela NO-PAUSE.

END PROCEDURE.

/***************************************************************************/
PROCEDURE excluir_tela.

/* buscar informacoes */
RUN consulta_tela.

IF glb_cdcritic = 0 THEN
DO:   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ASSIGN aux_confirma = "N"
      glb_cdcritic = 78.
          
      RUN fontes/critic.p.
      BELL.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.
   END.
                            
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
      aux_confirma <> "S" THEN
      DO:
          glb_cdcritic = 79.
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          glb_cdcritic = 0.
          NEXT.
      END.

   IF aux_confirma = "S" THEN
      DO:
         FIND FIRST craptel WHERE 
              craptel.cdcooper = glb_cdcooper AND
              craptel.nmdatela = tel_nmdatela AND 
              craptel.nmrotina = tel_nmrotina
              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

         IF   AVAILABLE craptel   THEN
              DELETE craptel.

         MESSAGE "Tela/Rotina excluida com sucesso ".

         CLEAR FRAME f_tela NO-PAUSE.
      END.
END.   
END PROCEDURE.

/***************************************************************************/
PROCEDURE insere_tela:

IF   tel_nmdatela = ""  THEN
     DO:
         ASSIGN glb_cdcritic = 375.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         CLEAR FRAME f_tela.

         DISPLAY glb_cddopcao tel_nmdatela WITH FRAME f_tela.
         NEXT.
     END. 

FIND FIRST craptel WHERE craptel.cdcooper = glb_cdcooper
                     AND craptel.nmdatela = tel_nmdatela
                     AND craptel.nmrotina = tel_nmrotina
                   NO-LOCK  NO-ERROR NO-WAIT.

IF   AVAILABLE craptel   THEN
     DO:
         BELL.
         MESSAGE "Tela/Rotina ja Cadastrada !".

         DISPLAY glb_cddopcao tel_nmdatela WITH FRAME f_tela.
         NEXT.
     END.
     
IF   tel_nmrotina = "PROGRID"  THEN
     ASSIGN tel_idevento = 1
            tel_idsistem = 2.
ELSE
IF   tel_nmrotina = "ASSEMBLEIA"  THEN
     ASSIGN tel_idevento = 2
            tel_idsistem = 2.
ELSE
     ASSIGN tel_idevento = 0
            tel_idsistem = 1.  /* Ayllos */
            
DISPLAY tel_idsistem tel_idevento WITH FRAME f_tela.

DO TRANSACTION ON ENDKEY UNDO, LEAVE:
   
   DO WHILE TRUE:
       SET tel_nrmodulo
           tel_tldatela
           tel_tlrestel
           tel_cdopptel
           tel_lsoppte1
           tel_lsoppte2
           tel_lsoppte3
           tel_flgteldf
           tel_flgtelbl
           tel_idambtel
           tel_inacesso
           tel_nrordrot
           tel_nrdnivel
           tel_nmrotpai
           WITH FRAME f_tela.

       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          ASSIGN aux_confirma = "N"
          glb_cdcritic = 78.
              
          RUN fontes/critic.p.
          BELL.
          MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
          LEAVE.
       END.
                                
       IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
          aux_confirma <> "S" THEN
          DO:
              glb_cdcritic = 79.
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              glb_cdcritic = 0.
              NEXT.
          END.

       IF  aux_confirma = "S" THEN
           DO:
               CREATE craptel.
               ASSIGN craptel.nmdatela = tel_nmdatela
                      craptel.nrmodulo = tel_nrmodulo
                      craptel.cdcooper = glb_cdcooper
                      craptel.cdopptel = tel_cdopptel
                      craptel.tldatela = tel_tldatela
                      craptel.tlrestel = tel_tlrestel
                      craptel.flgteldf = tel_flgteldf
                      craptel.flgtelbl = tel_flgtelbl
                      craptel.nmrotina = tel_nmrotina
                      craptel.lsopptel = tel_lsoppte1 + tel_lsoppte2 + tel_lsoppte3
                      craptel.inacesso = tel_inacesso
                      craptel.idsistem = tel_idsistem
                      craptel.idevento = tel_idevento
                      craptel.nrordrot = tel_nrordrot
                      craptel.idambtel = tel_idambtel
                      craptel.nrdnivel = tel_nrdnivel
                      craptel.nmrotpai = tel_nmrotpai.
           END.
       
       LEAVE.
   END.

END. /* Fim da transacao */

RELEASE craptel.

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
     NEXT.

MESSAGE "Tela/Rotina cadastrada com sucesso ".

CLEAR FRAME f_tela NO-PAUSE.

END PROCEDURE.

/* ..........................................................................*/
 
