/* .............................................................................

   Programa: Fontes/cpf.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah       
   Data    : Janeiro/2004                    Ultima atualizacao: 29/08/2013  

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CPF -- Consultar o cadastro em ordem de CPF.

   Alteracoes: 26/11/2004 - Tratar conta integracao.                           

               31/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).
                            
               25/01/2006 - Unificacao dos Bancos - SQLWorks - Andre
     
               13/02/2007 - Alterado para mostrar corretamente o CPF do segundo
                            titular. Arrumado para receber pessoas juridicas
                            (Elton).
               
               29/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_nrpesqui AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzz"   NO-UNDO.
DEF        VAR tel_nrcpfcgc AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_nrcpfstl AS CHAR    FORMAT "x(18)"                NO-UNDO.
DEF        VAR tel_dsagenci AS CHAR    FORMAT "x(03)"                NO-UNDO.
DEF        VAR tel_dsempres AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_nmtitula AS CHAR    FORMAT "x(35)"                NO-UNDO.
DEF        VAR tel_nmsegntl AS CHAR    FORMAT "x(35)"                NO-UNDO.
DEF        VAR tel_dtnasctl AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "z9"                   NO-UNDO.

DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_stimeout AS INT                                   NO-UNDO.

DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF BUFFER cratttl FOR crapttl. 

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     tel_nrpesqui AT 03 LABEL "Numero do CPF/CNPJ" AUTO-RETURN
                        HELP "Informe o CPF/CNPJ a pesquisar"
     tel_cdagenci AT 70 LABEL "PA" 
                        HELP "Entre com o PA a ser pesquisado ou 0 para todos"
     SKIP(1)
     "PA    Conta/dv   Conta/ITG Titulares                        CPF/CNPJ"
     WITH ROW 5 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_cpf.

FORM SKIP(1)
     tel_dsagenci     
     crapass.nrdconta 
     crapass.nrdctitg
     tel_nmtitula    FORMAT "x(32)" 
     tel_nrcpfcgc     
     SKIP
     tel_nmsegntl     AT  28 FORMAT "x(32)"
     tel_nrcpfstl     
     WITH ROW 09 COLUMN 2 OVERLAY 4 DOWN NO-LABEL NO-BOX FRAME f_dados.

VIEW FRAME f_moldura.

PAUSE(0).

glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "CPF"  THEN
                 DO:
                     HIDE FRAME f_cpf.
                     HIDE FRAME f_dados.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_dados ALL NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE tel_nrpesqui tel_cdagenci WITH FRAME f_cpf

      EDITING:

         aux_stimeout = 0.

         DO WHILE TRUE:

            READKEY PAUSE 1.

            IF   LASTKEY = -1   THEN
                 DO:
                     aux_stimeout = aux_stimeout + 1.

                     IF   aux_stimeout > glb_stimeout   THEN
                          QUIT.

                     NEXT.
                 END.

            APPLY LASTKEY.

            LEAVE.

         END.  /*  Fim do DO WHILE TRUE  */

      END.  /*  Fim do EDITING  */

      ASSIGN aux_regexist = FALSE
             aux_flgretor = FALSE
             aux_contador = 0.

      CLEAR FRAME f_dados ALL NO-PAUSE.

      /****Pessoa Fisica***/
      FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper       AND 
                             crapttl.nrcpfcgc = DEC(tel_nrpesqui)  
                             NO-LOCK:

          FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                             crapass.nrdconta = crapttl.nrdconta 
                             NO-LOCK NO-ERROR.
          
          IF   NOT AVAILABLE crapass THEN
               DO:
                    PAUSE MESSAGE
                    "Registro do Associado nao encontrado favor avisar o CPD".
                    NEXT.
               END.

          IF   tel_cdagenci > 0 AND
              (crapass.cdagenci <> tel_cdagenci) THEN
               NEXT.

          ASSIGN aux_regexist = TRUE
                 aux_contador = aux_contador + 1
                 tel_nrcpfstl = ""
                 tel_nmtitula = ""  
                 tel_nmsegntl = "".

          IF   aux_contador = 1   THEN
               IF   aux_flgretor   THEN
                    DO:
                        PAUSE MESSAGE
                        "Tecle <Entra> para continuar ou <Fim> para encerrar".
                        CLEAR FRAME f_dados ALL NO-PAUSE.
                    END.
               ELSE
                    aux_flgretor = TRUE.

          FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                             crapage.cdagenci = crapass.cdagenci
                             NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE crapage   THEN
               tel_dsagenci = "nao cadastrado - " +
                               STRING(crapass.cdagenci,"zz9").
          ELSE
               tel_dsagenci = STRING(crapage.cdagenci,"zz9").

          
          IF crapttl.idseqttl = 1 THEN
             DO:                            
                ASSIGN tel_nrcpfcgc = STRING(crapttl.nrcpfcgc,"99999999999")
                       tel_nrcpfcgc = STRING(tel_nrcpfcgc, "xxx.xxx.xxx-xx")
                       tel_nmtitula = crapttl.nmextttl.
                
                FIND cratttl WHERE cratttl.cdcooper = glb_cdcooper     AND
                                   cratttl.nrdconta = crapttl.nrdconta AND
                                   cratttl.idseqttl = 2 NO-ERROR.
                
                IF  AVAIL cratttl THEN
                    DO:
                        ASSIGN tel_nrcpfstl =  
                                   STRING(cratttl.nrcpfcgc,"99999999999")
                               tel_nrcpfstl =  
                                   STRING(tel_nrcpfstl, "xxx.xxx.xxx-xx")
                               tel_nmsegntl = cratttl.nmextttl.
                    END.
             END. 
          
          IF   crapttl.idseqttl = 2 THEN
               DO:
                   ASSIGN tel_nrcpfstl = STRING(crapttl.nrcpfcgc,"99999999999")
                          tel_nrcpfstl = STRING(tel_nrcpfstl, "xxx.xxx.xxx-xx")
                          tel_nmsegntl = crapttl.nmextttl.
                   
                   FIND cratttl WHERE cratttl.cdcooper = glb_cdcooper     AND
                                      cratttl.nrdconta = crapttl.nrdconta AND
                                      cratttl.idseqttl = 1 NO-ERROR.
                   
                   IF  AVAIL cratttl THEN
                       DO:    
                           ASSIGN tel_nrcpfcgc = 
                                      STRING(cratttl.nrcpfcgc,"99999999999")
                                  tel_nrcpfcgc = 
                                      STRING(tel_nrcpfcgc, "xxx.xxx.xxx-xx")
                                  tel_nmtitula = cratttl.nmextttl.
                       END. 
               END.
               
          DISPLAY tel_dsagenci crapass.nrdconta tel_nmtitula 
                  tel_nrcpfcgc tel_nmsegntl     crapass.nrdctitg
                  tel_nrcpfstl WHEN tel_nrcpfstl <> ""
                  WITH FRAME f_dados.
          
          IF   aux_contador = 4   THEN
               aux_contador = 0.
          ELSE
               DOWN WITH FRAME f_dados.

      END.  /*  Fim do FOR EACH  */
      
      
      IF   NOT aux_regexist   THEN
           DO:
              /**Pessoa Juridica **/
              FOR EACH crapass WHERE  crapass.cdcooper = glb_cdcooper      AND
                                      crapass.nrcpfcgc = DEC(tel_nrpesqui) AND
                                      crapass.inpessoa <> 1 NO-LOCK:         
                                                             
                  IF  tel_cdagenci > 0 AND
                      (crapass.cdagenci <> tel_cdagenci) THEN
                      NEXT.

                  ASSIGN aux_regexist = TRUE
                         aux_contador = aux_contador + 1
                         tel_nrcpfstl = ""
                         tel_nmtitula = ""  
                         tel_nmsegntl = "".

                  IF aux_contador = 1   THEN
                     IF aux_flgretor   THEN
                        DO:
                          PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                          CLEAR FRAME f_dados ALL NO-PAUSE.
                        END.
                     ELSE
                        aux_flgretor = TRUE.

                  FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                     crapage.cdagenci = crapass.cdagenci
                                     NO-LOCK NO-ERROR.

                  IF   NOT AVAILABLE crapage   THEN
                       tel_dsagenci = "nao cadastrado - " +
                                      STRING(crapass.cdagenci,"zz9").
                  ELSE
                       tel_dsagenci = STRING(crapage.cdagenci,"zz9").
            
                  ASSIGN 
                      tel_nrcpfcgc = STRING(crapass.nrcpfcgc, "99999999999999")
                      tel_nrcpfcgc = STRING(tel_nrcpfcgc, "xx.xxx.xxx/xxxx-xx")
                      tel_nmtitula = crapass.nmprimtl.
                
                  DISPLAY tel_dsagenci crapass.nrdconta tel_nmtitula 
                          tel_nrcpfcgc tel_nmsegntl     crapass.nrdctitg
                          tel_nrcpfstl WHEN tel_nrcpfstl <> ""
                          WITH FRAME f_dados.                   
                  
                  IF   aux_contador = 4   THEN
                       aux_contador = 0.
                  ELSE
                       DOWN WITH FRAME f_dados.
                   
              END. /*  Fim do FOR EACH        */
           END.   /*  Fim do IF aux_regexist */
      
      IF   NOT aux_regexist   THEN
           glb_cdcritic = 780.

   END.  /*  Fim do DO WHILE TRUE  */

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */
