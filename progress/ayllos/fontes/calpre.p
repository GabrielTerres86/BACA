/* .............................................................................

   Programa: Fontes/calpre.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/94.                       Ultima atualizacao: 09/11/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CALPRE -- Manutencao dos indices de prestacoes.

   Alteracoes: 11/11/94 - Incluida as opcoes de alteracao e exclusao de previa
                          de calculo.

               31/08/95 - Alterado para solicitar as linhas de credito a serem
                          impressas (Edson).

               17/01/97 - Alterado para calcular os coeficientes de prestacao
                          somente com a taxa base informada (Edson).

               07/03/2001 - Oferecer sempre 1 via na tela (Deborah).

               27/06/2005 - Alimentado campo cdcooper das tabelas craptab e    
                            crapsol (Diego).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               23/05/2006 - Implementado bloqueio para mais de um operador
                            utilizando a tela ao mesmo tempo (Diego).
                            
               14/02/2007 - Bloqueia tela quando alguem esta fazendo alteracao,
                            calculo definitivo ou exclusao (Elton).
                            
               13/05/2008 - Utilizar a tabela crapccp para armazenar o
                            coeficiente da linhas de credito, no lugar do
                            extende atributo craplcr.incalpre(Sidnei - Precise).

               01/07/2009 - Na opcao "R", so um operador por vez, por
                            causa da criacao do crapsol (Magui).
                            
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               16/02/2011 - Aumentar para 44 elementos na tela (Gabriel).
               
               10/03/2011 - Criado um browse para melhor visualização das
                            informações no estado de Consulta. (Fabrício)
                            
               27/02/2012 - Corrigido verificacao da existencia dos dados nas
                            opcoes A, D, E. (Fabricio)
                            
               03/12/2013 - Inclusao de VALIDATE craptab, crapccp e crapsol
                            (Carlos)
               
               25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).
                            
               09/11/2015 - Aumentado format do campo de GRUPO (Lunelli SD 353723)
............................................................................. */

DEF BUFFER crabtab FOR craptab.

DEF TEMP-TABLE crawgrp                                              NO-UNDO
               FIELD nrgrplcr AS INT     FORMAT "zz9"
               FIELD txbaspre AS DECIMAL FORMAT "zz9.99".

DEF STREAM str_1.

{ includes/var_online.i }

DEF        VAR tel_nrgrplcr AS INT     FORMAT "zz9"               NO-UNDO.
DEF        VAR tel_cdlcrimp AS INT     EXTENT 40                  NO-UNDO.

DEF        VAR tel_txbaspre AS DECIMAL FORMAT "zz9.99"            NO-UNDO.

DEF        VAR tel_dsdgrupo AS CHAR    FORMAT "x(14)" EXTENT 44   NO-UNDO.
DEF        VAR tel_lslcremp AS CHAR    FORMAT "x(74)" EXTENT 10   NO-UNDO.

DEF        VAR tel_txjurfix AS DECIMAL FORMAT "zz9.99"            NO-UNDO.
DEF        VAR tel_txjurvar AS DECIMAL FORMAT "zz9.99"            NO-UNDO.
DEF        VAR tel_txpresta AS DECIMAL FORMAT "zz9.99"            NO-UNDO.

DEF        VAR tel_qtdcasas AS INT     FORMAT "9"                 NO-UNDO.
DEF        VAR tel_nrinipre AS INT     FORMAT "z9"                NO-UNDO.
DEF        VAR tel_nrfimpre AS INT     FORMAT "z9"                NO-UNDO.
DEF        VAR tel_nrcopias AS INT     FORMAT "z9"                NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                               NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "x"                 NO-UNDO.
DEF        VAR aux_nmarqtmp AS CHAR    INIT "arq/crps090.tmp"     NO-UNDO.

DEF        VAR aux_txbaspre AS DECIMAL                            NO-UNDO.
DEF        VAR aux_incalpre AS DECIMAL                            NO-UNDO.
DEF        VAR aux_incalcul AS DECIMAL                            NO-UNDO.

DEF        VAR aux_tentaler AS INT                                NO-UNDO.
DEF        VAR aux_contador AS INT                                NO-UNDO.
DEF        var aux_contalcr AS INT                                NO-UNDO.
DEF        VAR aux_nrgrplcr AS INT                                NO-UNDO.
DEF        VAR aux_qtpresta AS INT                                NO-UNDO.
DEF        VAR aux_stimeout AS INT                                NO-UNDO.
DEF        VAR aux_cdlcremp AS INT                                NO-UNDO.

DEF        VAR aux_flgclear AS LOGICAL INIT TRUE                  NO-UNDO.

DEF        VAR aux_modCount  AS INT                                NO-UNDO.
DEF        VAR aux_contador2 AS INT                                NO-UNDO.
DEF        VAR aux_modCount2 AS INT                                NO-UNDO.
DEF        VAR aux_contregis AS INT                                NO-UNDO.
DEF        VAR aux_flgMod1 AS LOGICAL                              NO-UNDO.
DEF        VAR aux_flgMod2 AS LOGICAL                              NO-UNDO.
DEF        VAR aux_flgMod3 AS LOGICAL                              NO-UNDO.

DEF TEMP-TABLE tt-grupo1 NO-UNDO
    FIELD nrdlinha AS INT FORMAT "zz9"
    FIELD grupo_taxa AS CHAR FORMAT "x(18)".

DEF TEMP-TABLE tt-grupo2 NO-UNDO
    FIELD nrdlinha AS INT FORMAT "zz9"
    FIELD grupo_taxa AS CHAR FORMAT "x(18)".

DEF TEMP-TABLE tt-grupo3 NO-UNDO
    FIELD nrdlinha AS INT FORMAT "zz9"
    FIELD grupo_taxa AS CHAR FORMAT "x(18)".

DEF TEMP-TABLE tt-grupo4 NO-UNDO
    FIELD nrdlinha AS INT FORMAT "zz9"
    FIELD grupo_taxa AS CHAR FORMAT "x(18)".
                                   

DEF QUERY q-craplcr FOR tt-grupo1, tt-grupo2, tt-grupo3, tt-grupo4.

DEF BROWSE b-craplcr QUERY q-craplcr
    DISP tt-grupo1.grupo_taxa
         tt-grupo2.grupo_taxa
         tt-grupo3.grupo_taxa
         tt-grupo4.grupo_taxa
     WITH 11 DOWN NO-BOX ROW 8 COLUMN 2 NO-LABELS WIDTH 75.

FORM SKIP(1) "  Grupo  Taxa Base | Grupo  Taxa Base | Grupo  Taxa Base | Grupo  Taxa Base"
    b-craplcr    
    WITH NO-BOX ROW 7 COLUMN 2 NO-LABELS OVERLAY WIDTH 75 FRAME f_cabec.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, D, E, P ou R)."
                        VALIDATE(CAN-DO("A,C,D,E,P,R",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_nrgrplcr AT 17 LABEL "Grupo"
     HELP "Informe o n. do grupo de linhas de credito ou 0 para navegar."
                        
     tel_txbaspre AT 29 LABEL "Taxa Base"
                        HELP "Informe a taxa base para o calculo da prestacao."
     "%"          AT 47
     WITH NO-BOX ROW 6 COLUMN 2 SIDE-LABELS WIDTH 78 OVERLAY FRAME f_calpre.

FORM "Linhas de Credito:" AT 3
     SKIP(1)
     tel_lslcremp[01] AT 3 SKIP
     tel_lslcremp[02] AT 3 SKIP
     tel_lslcremp[03] AT 3 SKIP
     tel_lslcremp[04] AT 3 SKIP
     tel_lslcremp[05] AT 3 SKIP
     tel_lslcremp[06] AT 3 SKIP
     tel_lslcremp[07] AT 3 SKIP
     tel_lslcremp[08] AT 3 SKIP
     tel_lslcremp[09] AT 3 SKIP
     tel_lslcremp[10] AT 3 SKIP
     WITH NO-BOX ROW 8 COLUMN 2 NO-LABELS OVERLAY WIDTH 78 FRAME f_linhas.

    
VIEW FRAME f_moldura.

PAUSE 0.

VIEW FRAME f_calpre.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               IF   aux_flgclear   THEN
                    DO:
                        CLEAR FRAME f_calpre NO-PAUSE.
                    END.

               MESSAGE glb_dscritic.
               ASSIGN glb_cdcritic = 0
                      aux_flgclear = TRUE.
           END.

      CLOSE QUERY q-craplcr.

      EMPTY TEMP-TABLE tt-grupo1.
      EMPTY TEMP-TABLE tt-grupo2.
      EMPTY TEMP-TABLE tt-grupo3.
      EMPTY TEMP-TABLE tt-grupo4.

      ASSIGN aux_contador  = 0
             aux_contador2 = 1
             aux_modCount  = 0
             aux_modCount2 = 0.

      ASSIGN aux_flgMod1 = NO
             aux_flgMod2 = NO
             aux_flgMod3 = NO.

      /*  Lista os grupos de linhas de credito  */
      FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper NO-LOCK 
                             BREAK BY craplcr.nrgrplcr:

           IF   FIRST-OF(craplcr.nrgrplcr)   THEN
              ASSIGN aux_contador = aux_contador + 1.               

      END.  /*  Fim do FOR EACH  */

      IF aux_contador >= 4 THEN
      DO:
          ASSIGN aux_modCount = aux_contador MOD 4.
          ASSIGN aux_modCount2 = aux_modCount.
          ASSIGN aux_contador = TRUNC(aux_contador / 4, 0).
      END.
      ELSE
          ASSIGN aux_contador = 1.



      FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper NO-LOCK 
                             BREAK BY craplcr.nrgrplcr:

           IF   FIRST-OF(craplcr.nrgrplcr)   THEN
           DO:
                IF aux_contador2 <= aux_contador THEN
                DO:
                    CREATE tt-grupo1.
                    ASSIGN tt-grupo1.nrdlinha = aux_contador2
                           tt-grupo1.grupo_taxa = "   " + 
                                STRING(craplcr.nrgrplcr,"zz9") + "   " +
                                STRING(craplcr.txbaspre,"zz9.99") + " % |".

                    ASSIGN aux_contador2 = aux_contador2 + 1.
            
                END.
                ELSE
                IF (aux_modCount > 0) AND (aux_contador2 <= (aux_contador * 2))
                                      AND NOT aux_flgMod1 THEN
                DO:
                    CREATE tt-grupo1.
                    ASSIGN tt-grupo1.nrdlinha = aux_contador2
                           tt-grupo1.grupo_taxa = "   " + 
                                   STRING(craplcr.nrgrplcr,"zz9") + "   " +
                                   STRING(craplcr.txbaspre,"zz9.99") + " % |".

                    ASSIGN aux_modCount = aux_modCount - 1
                           aux_flgMod1  = YES.
        
                END.
                ELSE
                IF aux_contador2 <= (aux_contador * 2) THEN
                DO:
                    CREATE tt-grupo2.
                    ASSIGN tt-grupo2.nrdlinha = aux_contador2 - aux_contador
                           tt-grupo2.grupo_taxa = "   " +
                                   STRING(craplcr.nrgrplcr,"zz9") + "   " +
                                   STRING(craplcr.txbaspre,"zz9.99") + " % |".

                    ASSIGN aux_contador2 = aux_contador2 + 1.

                END.
                ELSE
                IF (aux_modCount > 0) AND (aux_contador2 <= (aux_contador * 3))
                                      AND NOT aux_flgMod2 THEN
                DO:
                    CREATE tt-grupo2.
                    ASSIGN tt-grupo2.nrdlinha = aux_contador2 - aux_contador.
                           tt-grupo2.grupo_taxa = "   " + 
                                   STRING(craplcr.nrgrplcr,"zz9") + "   " +
                                   STRING(craplcr.txbaspre,"zz9.99") + " % |".

                    ASSIGN aux_modCount = aux_modCount - 1
                           aux_flgMod2  = YES.

                END.
                ELSE
                IF aux_contador2 <= (aux_contador * 3) THEN
                DO:
                    CREATE tt-grupo3.
                    ASSIGN tt-grupo3.nrdlinha = 
                                            aux_contador2 - (aux_contador * 2)
                           tt-grupo3.grupo_taxa = "   " +
                                   STRING(craplcr.nrgrplcr,"zz9") + "   " +
                                   STRING(craplcr.txbaspre,"zz9.99") + " % |".

                    ASSIGN aux_contador2 = aux_contador2 + 1.
                END.
                ELSE
                IF (aux_modCount > 0) AND (aux_contador2 <= (aux_contador * 4))
                                      AND NOT aux_flgMod3 THEN
                DO:
                    CREATE tt-grupo3.
                    ASSIGN tt-grupo3.nrdlinha = 
                                            aux_contador2 - (aux_contador * 2)
                           tt-grupo3.grupo_taxa = "   " + 
                                   STRING(craplcr.nrgrplcr,"zz9") + "   " +
                                   STRING(craplcr.txbaspre,"zz9.99") + " % |".

                    ASSIGN aux_modCount = aux_modCount - 1
                           aux_flgMod3  = YES.
                END.
                ELSE
                IF aux_contador2 <= (aux_contador * 4) THEN
                DO:
                    CREATE tt-grupo4.
                    ASSIGN tt-grupo4.nrdlinha = 
                                            aux_contador2 - (aux_contador * 3)
                           tt-grupo4.grupo_taxa = "   " +
                                   STRING(craplcr.nrgrplcr,"zz9") + "   " +
                                   STRING(craplcr.txbaspre,"zz9.99") + " %".
                                    
                    ASSIGN aux_contador2 = aux_contador2 + 1.
                END.
           END.
      END.

      IF aux_contador2 = 2 THEN
      DO:
            CREATE tt-grupo2.
            ASSIGN tt-grupo2.nrdlinha = 1
                   tt-grupo2.grupo_taxa = "                 |".

            CREATE tt-grupo3.
            ASSIGN tt-grupo3.nrdlinha = 1
                   tt-grupo3.grupo_taxa = "                 |".

            CREATE tt-grupo4.
            ASSIGN tt-grupo4.nrdlinha = 1
                   tt-grupo4.grupo_taxa = "".

      END.
      ELSE
      IF aux_contador2 = 3 THEN
      DO:
            CREATE tt-grupo3.
            ASSIGN tt-grupo3.nrdlinha = 1
                   tt-grupo3.grupo_taxa = "                 |".

            CREATE tt-grupo4.
            ASSIGN tt-grupo4.nrdlinha = 1
                   tt-grupo4.grupo_taxa = "".
      END.
      ELSE
      IF aux_contador2 = 4 THEN
      DO:
            CREATE tt-grupo4.
            ASSIGN tt-grupo4.nrdlinha = 1
                   tt-grupo4.grupo_taxa = "".
      END.
      ELSE
      IF aux_modCount2 = 1 THEN
      DO:
            CREATE tt-grupo2.
            ASSIGN tt-grupo2.nrdlinha = aux_contador + 1
                   tt-grupo2.grupo_taxa = "                 |".

            CREATE tt-grupo3.
            ASSIGN tt-grupo3.nrdlinha = aux_contador + 1
                   tt-grupo3.grupo_taxa = "                 |".

            CREATE tt-grupo4.
            ASSIGN tt-grupo4.nrdlinha = aux_contador + 1
                   tt-grupo4.grupo_taxa = "".
      END.
      ELSE
      IF aux_modCount2 = 2 THEN
      DO:
            CREATE tt-grupo3.
            ASSIGN tt-grupo3.nrdlinha = aux_contador2 - (aux_contador * 3)
                   tt-grupo3.grupo_taxa = "                 |".

            CREATE tt-grupo4.
            ASSIGN tt-grupo4.nrdlinha = aux_contador2 - (aux_contador * 3)
                   tt-grupo4.grupo_taxa = "".
      END.
      ELSE
      IF aux_modCount2 = 3 THEN
      DO:
            CREATE tt-grupo4.
            ASSIGN tt-grupo4.nrdlinha = aux_contador2 - (aux_contador * 3)
                   tt-grupo4.grupo_taxa = "".
      END.

      VIEW FRAME f_cabec.

      OPEN QUERY q-craplcr FOR EACH tt-grupo1,
                 EACH tt-grupo2 WHERE tt-grupo2.nrdlinha = tt-grupo1.nrdlinha,
                 EACH tt-grupo3 WHERE tt-grupo3.nrdlinha = tt-grupo2.nrdlinha,
                 EACH tt-grupo4 WHERE tt-grupo4.nrdlinha = tt-grupo3.nrdlinha.

      ENABLE b-craplcr WITH FRAME f_cabec.

      NEXT-PROMPT tel_nrgrplcr WITH FRAME f_calpre.
      
      RELEASE crapsol.
      
      UPDATE glb_cddopcao WITH FRAME f_calpre

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

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:      
            RUN fontes/novatela.p.      
            IF   glb_nmdatela <> "CALPRE"   THEN
                 DO:
                     DO TRANSACTION:
                        FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                           craptab.nmsistem = "CRED"        AND
                                           craptab.tptabela = "GENERI"      AND
                                           craptab.cdempres = 00            AND
                                           craptab.cdacesso = "OPCALCPRE"   AND
                                           craptab.tpregist = 0
                                           EXCLUSIVE-LOCK NO-ERROR.
            
                        IF   AVAILABLE craptab   THEN
                             craptab.dstextab = "".
                     END.
                     
                     HIDE BROWSE b-craplcr.
                     HIDE FRAME f_calpre.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao
                   glb_cdcritic = 0.
        END.
                                        
   /* Somente um usuario pode usar as opcoes "A", "D", "E" e "R"  mesmo tempo */
   DO WHILE TRUE:
     
      FIND craptab WHERE craptab.cdcooper = glb_cdcooper        AND 
                         craptab.nmsistem = "CRED"              AND
                         craptab.tptabela = "GENERI"            AND
                         craptab.cdempres = 00                  AND
                         craptab.cdacesso = "OPCALCPRE"         AND
                         craptab.tpregist = 0  NO-LOCK NO-ERROR.

      IF (glb_cddopcao = "D"  OR
          glb_cddopcao = "A"  OR
          glb_cddopcao = "E"  OR
          glb_cddopcao = "R") AND 
          SUBSTR(craptab.dstextab,1,10) <> glb_cdoperad THEN
          DO:
              IF   NOT AVAILABLE craptab  THEN
                   DO TRANSACTION:
                      CREATE craptab.
                       ASSIGN craptab.cdcooper = glb_cdcooper
                              craptab.nmsistem = "CRED"
                              craptab.tptabela = "GENERI"
                              craptab.cdempres = 00
                              craptab.cdacesso = "OPCALCPRE"
                              craptab.tpregist = 0.

                       VALIDATE craptab.
                   END.
     
              IF   craptab.dstextab <> ""    THEN
                   DO:             
                        HIDE MESSAGE.
                        MESSAGE "Esta tela esta sendo usada pelo operador"
                                 craptab.dstextab.
                        MESSAGE "Aguarde ou pressione F4/END para sair...".

                        READKEY PAUSE 2.
                        IF  KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
                            DO:                 
                                /* Forca a saida para a tela do MENU */
                             /*   glb_nmdatela = "".    */  
                                RETURN.                         
                            END.

                        NEXT.   
                   END.   
              ELSE
                   DO TRANSACTION:
                      FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.
            
                      IF  AVAILABLE craptab   THEN
                          craptab.dstextab = STRING(glb_cdoperad,"x(10)") + 
                                             "-" + glb_nmoperad.
                
                          RELEASE craptab.
                          HIDE MESSAGE.
                   END. 

          END. /** fim do IF **/   
      ELSE
          IF  (glb_cddopcao = "C"  OR
              glb_cddopcao =  "P")  AND
              SUBSTR(craptab.dstextab,1,10) =  glb_cdoperad THEN
              DO TRANSACTION:
                 
                 FIND CURRENT craptab EXCLUSIVE-LOCK NO-ERROR.
                 
                 IF  AVAILABLE craptab   THEN
                     craptab.dstextab = "".  
                 
                 RELEASE craptab.
              
              END.   
      LEAVE.
   END. /** WHILE TRUE **/   

                                         
   IF   glb_cddopcao = "A"   THEN
        TRANS_A:

        DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_A, LEAVE
                                  ON ERROR UNDO TRANS_A, NEXT:

          

           /*  Lista os grupos de linhas de credito com previa de calculo  */

           RUN carrega_grupos.

           IF   aux_contregis = 0   THEN
                DO:
                    glb_cdcritic = 383.
                    LEAVE TRANS_A.
                END.

           UPDATE tel_nrgrplcr WITH FRAME f_calpre.

           DO WHILE TRUE:

              FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                 craptab.nmsistem = "CRED"           AND
                                 craptab.tptabela = "USUARI"         AND
                                 craptab.cdempres = 11               AND
                                 craptab.cdacesso = "CALCPRESTA"     AND
                                 craptab.tpregist = tel_nrgrplcr
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            glb_cdcritic = 383.
                            LEAVE TRANS_A.
                        END.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           tel_txbaspre = DECIMAL(craptab.dstextab).

           DO WHILE TRUE ON ENDKEY UNDO TRANS_A, LEAVE:

              UPDATE tel_txbaspre WITH FRAME f_calpre

              EDITING:

                 READKEY.

                 IF   FRAME-FIELD = "tel_txbaspre"   THEN
                      IF   LASTKEY =  KEYCODE(".")   THEN
                           APPLY 44.
                      ELSE
                           APPLY LASTKEY.
                 ELSE
                      APPLY LASTKEY.

              END.  /*  Fim do EDITING  */

              IF   tel_txbaspre = 0   THEN
                   DO:
                       glb_cdcritic = 185.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       glb_cdcritic = 0.
                       NEXT.
                   END.

              LEAVE.

           END.   /*  Fim do DO WHILE TRUE  */

           RUN fontes/confirma.p (INPUT "",
                                 OUTPUT aux_confirma).
          
           IF   aux_confirma <> "S"   THEN
                UNDO TRANS_A, LEAVE.
                
           craptab.dstextab = STRING(tel_txbaspre,"999.99").

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE e da transacao  */
   ELSE
   IF   glb_cddopcao = "E"   THEN
        TRANS_E:

        DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_E, LEAVE
                                  ON ERROR UNDO TRANS_E, NEXT:

           /*  Lista os grupos de linhas de credito com previa de calculo  */

           RUN carrega_grupos.

           IF   aux_contregis = 0   THEN
                DO:
                    glb_cdcritic = 383.
                    LEAVE.
                END.

           UPDATE tel_nrgrplcr WITH FRAME f_calpre.

           DO WHILE TRUE:

              FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                 craptab.nmsistem = "CRED"           AND
                                 craptab.tptabela = "USUARI"         AND
                                 craptab.cdempres = 11               AND
                                 craptab.cdacesso = "CALCPRESTA"     AND
                                 craptab.tpregist = tel_nrgrplcr
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            glb_cdcritic = 383.
                            RUN fontes/critic.p.
                            MESSAGE glb_dscritic.                            
                            glb_cdcritic = 0.
                            NEXT TRANS_E.
                        END.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           tel_txbaspre = DECIMAL(craptab.dstextab).

           DISPLAY tel_txbaspre WITH FRAME f_calpre.

           RUN fontes/confirma.p (INPUT "",
                                 OUTPUT aux_confirma).

           IF   aux_confirma <> "S"   THEN
                UNDO TRANS_E, LEAVE.

           DELETE craptab.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE e da transacao  */
   ELSE
   IF   glb_cddopcao = "P"   THEN
        TRANS_P:

        DO WHILE TRUE TRANSACTION ON ENDKEY UNDO TRANS_P, LEAVE
                                  ON ERROR  UNDO TRANS_P, LEAVE:

           ASSIGN tel_nrgrplcr = 0
                  tel_txbaspre = 0.
           
           UPDATE tel_nrgrplcr tel_txbaspre WITH FRAME f_calpre

           EDITING:

              READKEY.

              IF   FRAME-FIELD = "tel_txbaspre"   THEN
                   IF   LASTKEY =  KEYCODE(".")   THEN
                        APPLY 44.
                   ELSE
                        APPLY LASTKEY.
              ELSE
                   APPLY LASTKEY.

           END.  /*  Fim do EDITING  */

           IF   tel_txbaspre = 0   THEN
                DO:
                    glb_cdcritic = 185.
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    NEXT.
                END.

           ASSIGN tel_lslcremp = ""
                  aux_contador = 1
                  aux_contalcr = 0.

           /*  Leitura das linhas de credito com a taxa base  */

           FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                  craplcr.nrgrplcr = tel_nrgrplcr NO-LOCK:

               aux_contalcr = aux_contalcr + 1.
               
               IF   aux_contalcr > 15   THEN
                    ASSIGN aux_contador = aux_contador + 1
                           aux_contalcr = 1.
                           
               tel_lslcremp[aux_contador] = tel_lslcremp[aux_contador] + 
                                            STRING(craplcr.cdlcremp,"zzz9") +
                                            "  ".

           END.  /*  Fim do FOR EACH  */

           HIDE BROWSE b-craplcr NO-PAUSE.
           
           DISPLAY tel_lslcremp WITH FRAME f_linhas.
           
           RUN fontes/confirma.p (INPUT "",
                                 OUTPUT aux_confirma).

           IF   aux_confirma <> "S"   THEN
                UNDO TRANS_P, LEAVE.

           DO WHILE TRUE:

              FIND craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                 craptab.nmsistem = "CRED"           AND
                                 craptab.tptabela = "USUARI"         AND
                                 craptab.cdempres = 11               AND
                                 craptab.cdacesso = "CALCPRESTA"     AND
                                 craptab.tpregist = tel_nrgrplcr
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

              IF   NOT AVAILABLE craptab   THEN
                   IF   LOCKED craptab   THEN
                        DO:
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                   ELSE
                        DO:
                            CREATE craptab.
                            ASSIGN craptab.nmsistem = "CRED"
                                   craptab.tptabela = "USUARI"
                                   craptab.cdempres = 11
                                   craptab.cdacesso = "CALCPRESTA"
                                   craptab.tpregist = tel_nrgrplcr
                                   craptab.cdcooper = glb_cdcooper.
                        END.

              LEAVE.

           END.  /*  Fim do DO WHILE TRUE  */

           craptab.dstextab = STRING(tel_txbaspre,"999.99").

           VALIDATE craptab.

           LEAVE.

        END.  /*  Fim do DO WHILE TRUE e da transacao  */
   ELSE
   IF   glb_cddopcao = "D" THEN
        TRANS_D:

        DO TRANSACTION ON ERROR UNDO TRANS_D, NEXT:

           /*  Lista os grupos de linhas de credito com previa de calculo  */

           RUN carrega_grupos.

           IF   aux_contregis = 0   THEN
                DO:
                    glb_cdcritic = 383.
                    UNDO TRANS_D, NEXT.
                END.

           RUN fontes/confirma.p (INPUT "",
                                 OUTPUT aux_confirma).

           IF   aux_confirma <> "S"   THEN
                UNDO TRANS_D, NEXT.

           PUT SCREEN COLOR MESSAGE ROW 22
               "Aguarde, alterando os coeficientes de prestacoes...".

           PAUSE 2 NO-MESSAGE.

           FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                                  craptab.nmsistem = "CRED"           AND
                                  craptab.tptabela = "USUARI"         AND
                                  craptab.cdempres = 11               AND
                                  craptab.cdacesso = "CALCPRESTA"
                                  EXCLUSIVE-LOCK:
               
               FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper     AND
                                      craplcr.nrgrplcr = craptab.tpregist
                                      EXCLUSIVE-LOCK:
                   
                   ASSIGN craplcr.txbaspre = DECIMAL(craptab.dstextab)

                          tel_txjurfix = craplcr.txjurfix
                          tel_txjurvar = craplcr.txjurvar
                          tel_txpresta = craplcr.txpresta
                          tel_qtdcasas = craplcr.qtdcasas
                          tel_nrinipre = craplcr.nrinipre
                          tel_nrfimpre = craplcr.nrfimpre.

                   /** Limpar coeficientes **/
                   FOR EACH crapccp WHERE 
                                    crapccp.cdcooper = craplcr.cdcooper AND
                                    crapccp.cdlcremp = craplcr.cdlcremp
                                    EXCLUSIVE-LOCK:
                       DELETE crapccp.             
                   END.
                   
                   DO aux_qtpresta = tel_nrinipre TO tel_nrfimpre:

                      IF   craplcr.txbaspre = 0   THEN
                           aux_incalpre = 1 / aux_qtpresta.
                      ELSE
                           ASSIGN aux_txbaspre = craplcr.txbaspre / 100

                               aux_incalcul = EXP(1 + aux_txbaspre,aux_qtpresta)
                                  aux_incalpre = EXP((aux_incalcul - 1) /
                                              (aux_txbaspre * aux_incalcul),-1).

                      ASSIGN aux_incalpre = ROUND(aux_incalpre,tel_qtdcasas).
 
                      /** popular tabela de coeficientes **/
                      CREATE crapccp.
                      ASSIGN crapccp.cdcooper = craplcr.cdcooper
                             crapccp.cdlcremp = craplcr.cdlcremp
                             crapccp.nrparcel = aux_qtpresta
                             crapccp.incalpre = aux_incalpre.
                      
                      VALIDATE crapccp.

                   END.  /*  Fim do DO .. TO  */

               END.  /*  Fim do FOR EACH  */

               DELETE craptab.

           END.  /*  Fim do FOR EACH  */

           PUT SCREEN ROW 22 FILL(" ",80).

        END.  /*  Fim do da transacao -- TRANS_D:  */
   ELSE
   IF   glb_cddopcao = "C" THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           UPDATE tel_nrgrplcr WITH FRAME f_calpre.

           IF tel_nrgrplcr = 0 THEN
               UPDATE b-craplcr WITH FRAME f_cabec.

           ASSIGN tel_lslcremp = ""
                  tel_txbaspre = 0
                  aux_contador = 1
                  aux_contalcr = 0.

           /*  Leitura das linhas de credito com a taxa base  */

           FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                  craplcr.nrgrplcr = tel_nrgrplcr NO-LOCK:

               aux_contalcr = aux_contalcr + 1.
               
               IF   aux_contalcr > 15   THEN
                    ASSIGN aux_contador = aux_contador + 1
                           aux_contalcr = 1.
                           
               tel_lslcremp[aux_contador] = tel_lslcremp[aux_contador] + 
                                            STRING(craplcr.cdlcremp,"zzz9") +
                                            "  ".
               tel_txbaspre = craplcr.txbaspre.
               
           END.  /*  Fim do FOR EACH  */

           HIDE BROWSE b-craplcr NO-PAUSE.
           
           IF   tel_lslcremp[1] = ""   THEN
                tel_lslcremp[1] = "Nao ha linhas de credito cadastradas " +
                                  "para este grupo.".
           
           DISPLAY tel_txbaspre WITH FRAME f_calpre.
           
           DISPLAY tel_lslcremp WITH FRAME f_linhas.

        END.  /*  Fim do DO WHILE TRUE  */
   ELSE    
   IF   glb_cddopcao = "R"   THEN
        DO:
            ASSIGN tel_nrcopias = 1
                   tel_cdlcrimp = 0
                   glb_cdcritic = 0
                   glb_dsparame = "".

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE tel_cdlcrimp FORMAT "zzz9" AUTO-RETURN
                      WITH ROW 10 CENTERED OVERLAY NO-LABELS
                           TITLE " Entre com a linhas de credito a imprimir "
                           FRAME f_impressao.

               DO aux_contador = 1 TO 40:

                  IF   tel_cdlcrimp[aux_contador] = 0   THEN
                       NEXT.

                  glb_dsparame = glb_dsparame +
                                 STRING(tel_cdlcrimp[aux_contador]) + ",".

               END.  /*  Fim do DO .. TO  */

               BELL.
               MESSAGE COLOR NORMAL
                       "Entre com o numero de copias a serem impressas:"
                       UPDATE tel_nrcopias.

               IF    tel_nrcopias = 0   THEN
                     tel_nrcopias = 1.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

            HIDE FRAME f_impressao NO-PAUSE.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 NEXT.

            FIND FIRST craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                     craptab.nmsistem = "CRED"         AND
                                     craptab.tptabela = "USUARI"       AND
                                     craptab.cdempres = 11             AND
                                     craptab.cdacesso = "CALCPRESTA"
                                     NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     TRANS_R_1:

                     DO WHILE TRUE TRANSACTION ON ERROR UNDO TRANS_R_1, NEXT.

                        FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper  AND
                                           crapsol.nrsolici = 47            AND
                                           crapsol.dtrefere = glb_dtmvtolt  AND
                                           crapsol.nrseqsol = 1
                                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                        IF   AVAILABLE crapsol   THEN
                             IF   crapsol.insitsol = 1   THEN
                                  DO:
                                      glb_cdcritic = 386.
                                      LEAVE.
                                  END.
                             ELSE
                                  DO:
                                      ASSIGN crapsol.insitsol = 1
                                             crapsol.nrdevias = tel_nrcopias
                                             crapsol.dsparame = "  " +
                                                                glb_dsparame
                                             glb_dsparame     = "".
                                      LEAVE.
                                  END.
                        ELSE
                        IF   LOCKED crapsol   THEN
                             NEXT.

                        CREATE crapsol.
                        ASSIGN crapsol.nrsolici = 47
                               crapsol.dtrefere = glb_dtmvtolt
                               crapsol.nrseqsol = 1
                               crapsol.cdempres = 11
                               crapsol.dsparame = "  " + glb_dsparame
                               crapsol.insitsol = 1
                               crapsol.nrdevias = tel_nrcopias
                               crapsol.cdcooper = glb_cdcooper

                               glb_dsparame     = "".

                        VALIDATE crapsol.

                        LEAVE.

                     END.  /*  Fim da transacao  --  TRANS_R_1  */

                     IF   glb_cdcritic > 0   THEN
                          NEXT.

                     RUN fontes/crps090.p.

                     NEXT.
                 END.

            TRANS_R_2:

            DO WHILE TRUE TRANSACTION ON ERROR UNDO TRANS_R_2, NEXT.

               FIND crapsol WHERE crapsol.cdcooper = glb_cdcooper   AND
                                  crapsol.nrsolici = 47             AND
                                  crapsol.dtrefere = glb_dtmvtolt   AND
                                  crapsol.nrseqsol = 1
                                  EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

               IF   AVAILABLE crapsol    THEN
                    IF   crapsol.insitsol = 1   THEN
                         DO:
                             glb_cdcritic = 386.
                             LEAVE.
                         END.
                    ELSE
                         DO:
                             ASSIGN crapsol.insitsol = 1
                                    crapsol.nrdevias = tel_nrcopias
                                    crapsol.dsparame = "P " + glb_dsparame.
                             LEAVE.
                         END.
               ELSE
               IF   LOCKED crapsol   THEN
                    NEXT.

               CREATE crapsol.
               ASSIGN crapsol.nrsolici = 47
                      crapsol.dtrefere = glb_dtmvtolt
                      crapsol.nrseqsol = 1
                      crapsol.cdempres = 11
                      crapsol.dsparame = "P " + glb_dsparame
                      crapsol.insitsol = 1
                      crapsol.nrdevias = tel_nrcopias
                      crapsol.cdcooper = glb_cdcooper.

               LEAVE.

            END.  /*  Fim da transacao  --  TRANS_R_2  */

            RELEASE crapsol.

            IF   glb_cdcritic > 0   THEN
                 NEXT.

            OUTPUT STREAM str_1 TO VALUE(aux_nmarqtmp).

            FOR EACH craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                   craplcr.flgstlcr = YES          NO-LOCK:

                IF   glb_dsparame <> ""   THEN
                     IF   NOT CAN-DO(glb_dsparame,STRING(craplcr.cdlcremp)) THEN
                          NEXT.

                FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                   craptab.nmsistem = "CRED"         AND
                                   craptab.tptabela = "USUARI"       AND
                                   craptab.cdempres = 11             AND
                                   craptab.cdacesso = "CALCPRESTA"   AND
                                   craptab.tpregist = craplcr.nrgrplcr
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE craptab   THEN
                     tel_txbaspre = craplcr.txbaspre.
                ELSE
                     tel_txbaspre = DECIMAL(craptab.dstextab).

                ASSIGN tel_txjurfix = craplcr.txjurfix
                       tel_txjurvar = craplcr.txjurvar
                       tel_txpresta = craplcr.txpresta
                       tel_qtdcasas = craplcr.qtdcasas
                       tel_nrinipre = craplcr.nrinipre
                       tel_nrfimpre = craplcr.nrfimpre.

                PUT STREAM str_1
                    craplcr.cdlcremp FORMAT "9999" " 000 "
                    tel_txbaspre     FORMAT "999.999999"
                    SKIP.

                DO aux_qtpresta = tel_nrinipre TO tel_nrfimpre:

                   IF   tel_txbaspre = 0   THEN
                        aux_incalpre = 1 / aux_qtpresta.
                   ELSE
                        ASSIGN aux_txbaspre = tel_txbaspre / 100

                               aux_incalcul = EXP(1 + aux_txbaspre,aux_qtpresta)
                               aux_incalpre = EXP((aux_incalcul - 1) /
                                              (aux_txbaspre * aux_incalcul),-1).

                   aux_incalpre = ROUND(aux_incalpre,tel_qtdcasas).

                   PUT STREAM str_1
                       craplcr.cdlcremp FORMAT "9999"      " "
                       aux_qtpresta     FORMAT "999"      " "
                       aux_incalpre     FORMAT "999.999999"
                       SKIP.

                END.  /*  Fim do DO .. TO  */

            END.  /*  Fim do FOR EACH  */

            OUTPUT STREAM str_1 CLOSE.

            RUN fontes/crps090.p.

        END.

END.  /*  Fim do DO WHILE TRUE  */

/******************************* PROCEDURES **********************************/

PROCEDURE carrega_grupos.
    
    CLOSE QUERY q-craplcr.

    EMPTY TEMP-TABLE tt-grupo1.
    EMPTY TEMP-TABLE tt-grupo2.
    EMPTY TEMP-TABLE tt-grupo3.
    EMPTY TEMP-TABLE tt-grupo4.

    ASSIGN aux_contador  = 0
           aux_contador2 = 1
           aux_modCount  = 0
           aux_modCount2 = 0
           aux_contregis = 0.

    ASSIGN aux_flgMod1 = NO
           aux_flgMod2 = NO
           aux_flgMod3 = NO.

    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper  AND 
                             craptab.nmsistem = "CRED"        AND
                             craptab.tptabela = "USUARI"      AND
                             craptab.cdempres = 11            AND
                             craptab.cdacesso ="CALCPRESTA"   NO-LOCK:

        ASSIGN aux_contador = aux_contador + 1
               aux_contregis = aux_contregis + 1.

    END.
    
    IF aux_contador >= 4 THEN
    DO:
        ASSIGN aux_modCount = aux_contador MOD 4.
        ASSIGN aux_modCount2 = aux_modCount.
        ASSIGN aux_contador = TRUNC(aux_contador / 4, 0).
    END.
    ELSE
        ASSIGN aux_contador = 1.

    FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper  AND 
                           craptab.nmsistem = "CRED"        AND
                           craptab.tptabela = "USUARI"      AND
                           craptab.cdempres = 11            AND
                           craptab.cdacesso ="CALCPRESTA"   NO-LOCK:

        ASSIGN tel_txbaspre = DECIMAL(craptab.dstextab).

        IF aux_contador2 <= aux_contador THEN
        DO:
            CREATE tt-grupo1.
            ASSIGN tt-grupo1.nrdlinha = aux_contador2
                   tt-grupo1.grupo_taxa = "   " + 
                STRING(craptab.tpregist,"zz9") + "   " +
                                   STRING(tel_txbaspre,"zz9.99") + " % |".

            ASSIGN aux_contador2 = aux_contador2 + 1.
            
        END.
        ELSE
        IF (aux_modCount > 0) AND (aux_contador2 <= (aux_contador * 2))
                              AND NOT aux_flgMod1 THEN
        DO:
            CREATE tt-grupo1.
            ASSIGN tt-grupo1.nrdlinha = aux_contador2
                   tt-grupo1.grupo_taxa = "   " + 
                STRING(craptab.tpregist,"zz9") + "   " +
                                   STRING(tel_txbaspre,"zz9.99") + " % |".

            ASSIGN aux_modCount = aux_modCount - 1
                   aux_flgMod1  = YES.
        
        END.
        ELSE
        IF aux_contador2 <= (aux_contador * 2) THEN
        DO:
            CREATE tt-grupo2.
            ASSIGN tt-grupo2.nrdlinha = aux_contador2 - aux_contador
                   tt-grupo2.grupo_taxa = "   " +
                        STRING(craptab.tpregist,"zz9") + "   " + 
                                   STRING(tel_txbaspre,"zz9.99") + " % |".

            ASSIGN aux_contador2 = aux_contador2 + 1.

        END.
        ELSE
        IF (aux_modCount > 0) AND (aux_contador2 <= (aux_contador * 3))
                              AND NOT aux_flgMod2 THEN
        DO:
            CREATE tt-grupo2.
            ASSIGN tt-grupo2.nrdlinha = aux_contador2 - aux_contador.
                   tt-grupo2.grupo_taxa = "   " + 
                    STRING(craptab.tpregist,"zz9") + "   " +
                                       STRING(tel_txbaspre,"zz9.99") + " % |".

            ASSIGN aux_modCount = aux_modCount - 1
                   aux_flgMod2  = YES.

        END.
        ELSE
        IF aux_contador2 <= (aux_contador * 3) THEN
        DO:
            CREATE tt-grupo3.
            ASSIGN tt-grupo3.nrdlinha = aux_contador2 - (aux_contador * 2)
                   tt-grupo3.grupo_taxa = "   " +
                        STRING(craptab.tpregist,"zz9") + "   " + 
                                   STRING(tel_txbaspre,"zz9.99") + " % |".

            ASSIGN aux_contador2 = aux_contador2 + 1.
        END.
        ELSE
        IF (aux_modCount > 0) AND (aux_contador2 <= (aux_contador * 4))
                              AND NOT aux_flgMod3 THEN
        DO:
            CREATE tt-grupo3.
            ASSIGN tt-grupo3.nrdlinha = aux_contador2 - (aux_contador * 2).
                   tt-grupo3.grupo_taxa = "   " + 
                        STRING(craptab.tpregist,"zz9") + "   " +
                                           STRING(tel_txbaspre,"zz9.99") + " % |".

            ASSIGN aux_modCount = aux_modCount - 1
                   aux_flgMod3  = YES.
        END.
        ELSE
        IF aux_contador2 <= (aux_contador * 4) THEN
        DO:
            CREATE tt-grupo4.
            ASSIGN tt-grupo4.nrdlinha = aux_contador2 - (aux_contador * 3)
                   tt-grupo4.grupo_taxa = "   " +
                        STRING(craptab.tpregist,"zz9") + "   " + 
                                   STRING(tel_txbaspre,"zz9.99") + " %".
                                    
            ASSIGN aux_contador2 = aux_contador2 + 1.
        END.
    END.

    IF aux_contador2 = 2 THEN
    DO:
        CREATE tt-grupo2.
        ASSIGN tt-grupo2.nrdlinha = 1
               tt-grupo2.grupo_taxa = "                 |".

        CREATE tt-grupo3.
        ASSIGN tt-grupo3.nrdlinha = 1
               tt-grupo3.grupo_taxa = "                 |".

        CREATE tt-grupo4.
        ASSIGN tt-grupo4.nrdlinha = 1
               tt-grupo4.grupo_taxa = "".

    END.
    ELSE
    IF aux_contador2 = 3 THEN
    DO:
        CREATE tt-grupo3.
        ASSIGN tt-grupo3.nrdlinha = 1
               tt-grupo3.grupo_taxa = "                 |".

        CREATE tt-grupo4.
        ASSIGN tt-grupo4.nrdlinha = 1
               tt-grupo4.grupo_taxa = "".
    END.
    ELSE
    IF aux_contador2 = 4 THEN
    DO:
        CREATE tt-grupo4.
        ASSIGN tt-grupo4.nrdlinha = 1
               tt-grupo4.grupo_taxa = "".
    END.
    ELSE
    IF aux_modCount2 = 1 THEN
    DO:
        CREATE tt-grupo2.
        ASSIGN tt-grupo2.nrdlinha = aux_contador + 1.
               tt-grupo2.grupo_taxa = "                 |".

        CREATE tt-grupo3.
        ASSIGN tt-grupo3.nrdlinha = aux_contador + 1.
               tt-grupo3.grupo_taxa = "                 |".

        CREATE tt-grupo4.
        ASSIGN tt-grupo4.nrdlinha = aux_contador + 1.
               tt-grupo4.grupo_taxa = "".
    END.
    ELSE
    IF aux_modCount2 = 2 THEN
    DO:
        CREATE tt-grupo3.
        ASSIGN tt-grupo3.nrdlinha = aux_contador2 - (aux_contador * 3).
               tt-grupo3.grupo_taxa = "                 |".

        CREATE tt-grupo4.
        ASSIGN tt-grupo4.nrdlinha = aux_contador2 - (aux_contador * 3).
               tt-grupo4.grupo_taxa = "".
    END.
    ELSE
    IF aux_modCount2 = 3 THEN
    DO:
        CREATE tt-grupo4.
        ASSIGN tt-grupo4.nrdlinha = aux_contador2 - (aux_contador * 3).
               tt-grupo4.grupo_taxa = "".
    END.

    VIEW FRAME f_cabec.

    OPEN QUERY q-craplcr FOR EACH tt-grupo1,
                 EACH tt-grupo2 WHERE tt-grupo2.nrdlinha = tt-grupo1.nrdlinha,
                 EACH tt-grupo3 WHERE tt-grupo3.nrdlinha = tt-grupo2.nrdlinha,
                 EACH tt-grupo4 WHERE tt-grupo4.nrdlinha = tt-grupo3.nrdlinha.

    ENABLE b-craplcr WITH FRAME f_cabec.

END PROCEDURE.


/* .......................................................................... */
