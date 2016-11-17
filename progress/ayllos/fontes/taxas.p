/* .............................................................................

   Programa: Fontes/taxas.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/95.                      Ultima atualizacao: 25/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAXAS.

   Alteracoes: 17/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               21/09/2000 - Alterado grupo de linhas para 2 posicoes (Deborah).

               02/04/2001 - Usar 9999 para cdlcremp (Margarete/Planner).
               
               20/06/2001 - Incluir prejuizo (Margarete).

               01/11/2004 - Listar Taxas Desconto de Cheques (tipo 7) (Mirtes)

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               03/08/2009 - Incluido campo "Lim.Empr."  - alimentado quando
                            craptax.tpdetaxa = 2 e quando a descricao da linha
                            for igual a limite empresarial (Fernando).
                            
               14/02/2011 - Retirado os campos "Cheq.Esp." e "Lim.Empr." e 
                            incluido o campo "Tipo Cr." para tratar as opções
                            Linha de Crédito e Limite de Crédito.
                            (Isara - RKAM)
                            
               25/04/2014 - Aumentado o format do campo cdlcremp de 3 para 4
                            posicoes (Tiago/Gielow SD137074).             
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_dtmesref AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_dtanoref AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR tel_dsinduti AS CHAR    FORMAT "x(6)"                 NO-UNDO.
DEF        VAR tel_cdlcremp AS INT     FORMAT "zzzz"                  NO-UNDO.
DEF        VAR tel_tplincrd AS INT     FORMAT "9"                    NO-UNDO.

DEF        VAR tel_txsaqblq AS DECIMAL FORMAT "z9.999999"            NO-UNDO.
DEF        VAR tel_txmultas AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_txreajus AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_txdaufir AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_txdatrtr AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_txjuprej AS DECIMAL FORMAT "zz9.99"               NO-UNDO.
DEF        VAR tel_dsobser1 AS CHAR    FORMAT "x(27)"                NO-UNDO.
DEF        VAR tel_dsobser2 AS CHAR    FORMAT "x(70)"                NO-UNDO.
DEF        VAR tel_dsobser3 AS CHAR    FORMAT "x(70)"                NO-UNDO.
DEF        VAR tel_dsobser4 AS CHAR    FORMAT "x(70)"                NO-UNDO.
DEF        VAR tel_dtrefere AS CHAR    FORMAT "x(07)"                NO-UNDO.
DEF        VAR tel_dslincre AS CHAR    FORMAT "x(36)"                NO-UNDO.
DEF        VAR tel_dssitlcr AS CHAR    FORMAT "x(01)"                NO-UNDO.

DEF        VAR aux_dtgerref AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_verifica AS CHAR                                  NO-UNDO.
DEF        VAR aux_primvez  AS LOG                                   NO-UNDO.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 20 DOWN WIDTH 80 TITLE glb_tldatela
     FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao"   AUTO-RETURN
                        HELP "D - Determinado Mes, L - Linha de Credito"
                        VALIDATE(CAN-DO("D,L",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_dtmesref AT 12 LABEL "Mes" AUTO-RETURN
                        HELP "Entre com o Ano de referencia"
     tel_dtanoref AT 20 LABEL "Ano" AUTO-RETURN
                        HELP "Entre com o Ano de referencia"
                        VALIDATE(INPUT FRAME f_taxas tel_dtanoref > 1000,
                     "560 - Ano errado. Deve ser no formato AAAA. Ex.: 1997")
     
     tel_tplincrd AT 31 LABEL "Tipo Cr."
                        HELP "1 - Linha de Credito, 2 - Limite de Credito"
                        VALIDATE(CAN-DO("1,2",tel_tplincrd),
                                 "014 - Opcao errada.")

     tel_cdlcremp AT 44 LABEL "L.Cr."   AUTO-RETURN
                        HELP "Entre com o codigo da Linha de Credito"
     tel_dsinduti AT 57 LABEL "Index. Utiliz"
     SKIP(1)
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_taxas.

FORM tel_txsaqblq AT 2  LABEL "Saque S/Bloq."
     tel_txmultas AT 35 LABEL "Multa"
     tel_txdaufir AT 56  LABEL "Ufir"
     SKIP
     tel_txdatrtr AT 11 LABEL "T.R."
     tel_txreajus AT 29 LABEL "Reaj.Limite"
     tel_txjuprej AT 55 LABEL "Prej."
     SKIP
     tel_dsobser1 AT 2  LABEL "Obs."
     SKIP
     tel_dsobser2 AT 8  NO-LABELS
     SKIP
     tel_dsobser3 AT 8  NO-LABELS
     SKIP
     tel_dsobser4 AT 8  NO-LABELS
     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_observacao.

FORM "Mes/Ano  Linha de Credito"     AT 2
     "Mensal      Diaria Grupo Sit"  AT 49
     WITH ROW 14 COLUMN 2 OVERLAY NO-BOX FRAME f_descricao.

FORM "Mes/Ano    Linha de Credito" AT 2
     "Mensal"                      AT 49
     WITH ROW 14 COLUMN 2 OVERLAY NO-BOX FRAME f_descricao1.

FORM "Mes/Ano  Linha de Credito"     AT 2
     "Mensal      Diaria Grupo Sit"  AT 49
     WITH ROW 9 COLUMN 2 OVERLAY NO-BOX FRAME f_descricao2.

FORM "Mes/Ano  Linha de Credito"  AT 2
     "Mensal"                     AT 49
     WITH ROW 9 COLUMN 2 OVERLAY NO-BOX FRAME f_descricao3.

FORM tel_dtrefere      AT 2
     tel_dslincre      AT 11
     craptax.txmensal  AT 49  FORMAT "zz9.99"
     craptax.txdiaria  AT 56  FORMAT "zz9.9999999"
     craptax.grlcremp  AT 70  FORMAT "99"
     tel_dssitlcr      AT 75
     WITH ROW 15 COLUMN 2 OVERLAY 6 DOWN NO-BOX  NO-LABELS FRAME f_linha.

FORM tel_dtrefere      AT 2
     tel_dslincre      AT 11
     craptax.txmensal  AT 49  FORMAT "zz9.99"
     craptax.txdiaria  AT 56  FORMAT "zz9.9999999"
     craptax.grlcremp  AT 70  FORMAT "99"
     tel_dssitlcr      AT 75
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-BOX NO-LABELS  FRAME f_linha1.

FORM tel_dtrefere      AT 2
     tel_dslincre      AT 11
     craptax.txmensal  AT 49  FORMAT "zz9.99"
     WITH ROW 15 COLUMN 2 OVERLAY 6 DOWN NO-BOX NO-LABELS  FRAME f_linha2.

FORM tel_dtrefere      AT 2
     tel_dslincre      AT 11
     craptax.txmensal  AT 49  FORMAT "zz9.99"
     WITH ROW 10 COLUMN 2 OVERLAY 11 DOWN NO-BOX NO-LABELS  FRAME f_linha3.

ASSIGN glb_cddopcao = "D"
       tel_dtanoref = YEAR(glb_dtmvtolt)
       tel_tplincrd = 1.

VIEW FRAME f_moldura.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   DO WHILE TRUE:

      IF   glb_cdcritic <> 0 THEN
           DO:
              RUN fontes/critic.p.
              BELL.
              MESSAGE glb_dscritic.
              HIDE  FRAME f_descricao.
              HIDE  FRAME f_descricao1.
              HIDE  FRAME f_descricao2.
              HIDE  FRAME f_descricao3.
              CLEAR FRAME f_taxas.
              CLEAR FRAME f_observacao.
              CLEAR FRAME f_linha  ALL NO-PAUSE.
              CLEAR FRAME f_linha1 ALL NO-PAUSE.
              CLEAR FRAME f_linha2 ALL NO-PAUSE.
              CLEAR FRAME f_linha3 ALL NO-PAUSE.
              glb_cdcritic = 0.
           END.

      aux_verifica = glb_cddopcao.

      NEXT-PROMPT tel_dtmesref WITH FRAME f_taxas.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         UPDATE glb_cddopcao tel_dtmesref tel_dtanoref tel_tplincrd WITH FRAME f_taxas.

         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
           DO:
               RUN fontes/novatela.p.
               IF   CAPS(glb_nmdatela) <> "TAXAS" THEN
                    DO:
                        HIDE FRAME f_taxas.
                        HIDE FRAME f_observacao.
                        HIDE FRAME f_descricao.
                        HIDE FRAME f_descricao1.
                        HIDE FRAME f_descricao2.
                        HIDE FRAME f_descricao3.
                        HIDE FRAME f_linha.
                        HIDE FRAME f_linha1.
                        HIDE FRAME f_linha2.
                        HIDE FRAME f_linha3.
                        HIDE FRAME f_moldura.
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

      IF   ((tel_dtmesref = 0  AND glb_cddopcao <> "L") OR tel_dtmesref > 12) OR
             tel_dtanoref > YEAR(glb_dtmvtolt)                              THEN
           DO:
              glb_cdcritic = 13.
              NEXT.
           END.

      IF   glb_cddopcao = "D"  OR tel_dtmesref <> 0   THEN
           aux_dtgerref = DATE(tel_dtmesref,01,tel_dtanoref).
      ELSE
           aux_dtgerref = DATE(01,01,0001).

      IF   aux_dtgerref > glb_dtmvtolt   THEN
           DO:
              glb_cdcritic = 13.
              NEXT.
           END.

      aux_regexist = FALSE.

      IF   glb_cddopcao = "D"  THEN
           DO:
              ASSIGN tel_cdlcremp = 0
                     tel_txreajus = 0 .

              IF   aux_verifica <> glb_cddopcao THEN
                   DO:
                      HIDE FRAME f_descricao.
                      HIDE FRAME f_descricao1.
                      HIDE FRAME f_descricao2.
                      HIDE FRAME f_descricao3.
                      HIDE FRAME f_linha1.
                      HIDE FRAME f_linha3.
                      HIDE FRAME f_observacao.
                      DISPLAY tel_cdlcremp WITH FRAME f_taxas.
                   END.
             
              FOR EACH craptax WHERE craptax.cdcooper  = glb_cdcooper        AND
                               MONTH(craptax.dtmvtolt) = MONTH(aux_dtgerref) AND
                                YEAR(craptax.dtmvtolt) = YEAR(aux_dtgerref)
                                     NO-LOCK:

                  aux_regexist = TRUE.

                  IF   craptax.tpdetaxa = 1    AND 
                       craptax.cdlcremp = 9999 THEN
                       ASSIGN tel_dsinduti = SUBSTR(craptax.dslcremp,1,6)
                              tel_txdaufir = craptax.txmensal
                              tel_txdatrtr = craptax.txdiaria
                              tel_dsobser1 = SUBSTR(craptax.dslcremp,8,27)
                              tel_dsobser2 = SUBSTR(craptax.dslcremp,35,76)
                              tel_dsobser3 = SUBSTR(craptax.dslcremp,111,76)
                              tel_dsobser4 = SUBSTR(craptax.dslcremp,187,76).
                  ELSE
                  IF   craptax.tpdetaxa = 3 THEN
                       tel_txsaqblq = craptax.txmensal.
                  ELSE
                  IF   craptax.tpdetaxa = 4 THEN
                       tel_txmultas = craptax.txmensal.
                  ELSE
                  IF   craptax.tpdetaxa = 5 THEN
                       tel_txreajus = craptax.txmensal.
                  ELSE
                  IF   craptax.tpdetaxa = 6 THEN
                       tel_txjuprej = craptax.txmensal.

              END. /* Fim do FOR EACH */

              IF   aux_regexist THEN
                   DO:
                       DISPLAY tel_dsinduti  WITH FRAME f_taxas.

                       DISPLAY tel_txsaqblq  tel_txmultas  tel_txreajus  
                               tel_txdaufir  tel_txdatrtr  tel_txjuprej
                               tel_dsobser1  tel_dsobser2  tel_dsobser3
                               tel_dsobser4  WITH FRAME f_observacao.
                   END.

              CLEAR FRAME f_linha ALL NO-PAUSE.
              CLEAR FRAME f_linha2 ALL NO-PAUSE.

              ASSIGN aux_contador = 0
                     aux_flgretor = FALSE.

              CASE tel_tplincrd:

                  /* LINHA DE CREDITO */
                  WHEN 1 THEN
                  DO: 
                      FOR EACH craptax WHERE craptax.cdcooper  = glb_cdcooper        AND 
                                       MONTH(craptax.dtmvtolt) = MONTH(aux_dtgerref) AND
                                        YEAR(craptax.dtmvtolt) = YEAR(aux_dtgerref)  AND
                                             craptax.tpdetaxa  = 1                   AND
                                             craptax.cdlcremp <> 9999 
                                             NO-LOCK:
        
                          HIDE FRAME f_descricao1.
                          VIEW FRAME f_descricao.
                          PAUSE(0).
                
                          ASSIGN aux_regexist = TRUE
                                 tel_dtrefere =
                                     SUBSTR(STRING(craptax.dtmvtolt,"99/99/9999"),4,7)
                                 tel_dslincre = STRING(craptax.cdlcremp,"zzz9")    +
                                                " - " +  craptax.dslcremp
                                 tel_dssitlcr = IF  craptax.insitlcr = 0
                                                    THEN "L"
                                                    ELSE "B"
                                 aux_contador = aux_contador + 1.
                
                          IF   aux_contador = 1   THEN
                               IF   aux_flgretor   THEN
                                    DO:
                                       PAUSE MESSAGE
                                  "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                       CLEAR FRAME f_linha ALL NO-PAUSE.
                                    END.
                
                          DISPLAY tel_dtrefere         tel_dslincre
                                  craptax.txmensal     craptax.txdiaria
                                  craptax.grlcremp     tel_dssitlcr
                                  WITH  FRAME f_linha.               
                
                          IF   aux_contador = 6   THEN
                               DO:
                                   ASSIGN aux_contador = 0
                                          aux_flgretor = TRUE.
                               END.
                          ELSE
                               DOWN WITH FRAME f_linha.
        
                      END. /* Fim do FOR EACH */
                  END.

                  /* LIMITE DE CREDITO */
                  WHEN 2 THEN
                  DO:
                      FOR EACH craptax WHERE craptax.cdcooper  = glb_cdcooper        AND 
                                       MONTH(craptax.dtmvtolt) = MONTH(aux_dtgerref) AND
                                        YEAR(craptax.dtmvtolt) = YEAR(aux_dtgerref)  AND
                                             craptax.tpdetaxa  = 2                    
                                             NO-LOCK:
        
                          HIDE FRAME f_descricao.
                          VIEW FRAME f_descricao1.
                          PAUSE(0).
                
                          ASSIGN aux_regexist = TRUE
                                 tel_dtrefere =
                                     SUBSTR(STRING(craptax.dtmvtolt,"99/99/9999"),4,7)
                                 tel_dslincre = STRING(craptax.cdlcremp,"zzz9")    +
                                                " - " +  craptax.dslcremp
                                 aux_contador = aux_contador + 1.
                
                          IF   aux_contador = 1   THEN
                               IF   aux_flgretor   THEN
                                    DO:
                                       PAUSE MESSAGE
                                  "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                       CLEAR FRAME f_linha2 ALL NO-PAUSE.
                                    END.
                
                          DISPLAY tel_dtrefere         
                                  tel_dslincre
                                  craptax.txmensal     
                                  WITH FRAME f_linha2.
                
                          IF   aux_contador = 6   THEN
                               DO:
                                   ASSIGN aux_contador = 0
                                          aux_flgretor = TRUE.
                               END.
                          ELSE
                               DOWN WITH FRAME f_linha2.
        
                      END. /* Fim do FOR EACH */
                  END.

              END CASE.

              /* Taxas Desconto de Cheques */ 
              ASSIGN aux_primvez  = YES.

             FOR EACH craptax WHERE craptax.cdcooper  = glb_cdcooper        AND
                              MONTH(craptax.dtmvtolt) = MONTH(aux_dtgerref) AND
                               YEAR(craptax.dtmvtolt) = YEAR(aux_dtgerref)  AND  
                                    craptax.tpdetaxa  = 7 NO-lOCK:

                  IF  aux_primvez = YES THEN
                      DO:
                         DISPLAY " " @ tel_dtrefere   
                                 " " @ tel_dslincre
                                 " " @ craptax.txmensal  
                                 " " @ craptax.txdiaria
                                 " " @ craptax.grlcremp  
                                 " " @ tel_dssitlcr
                              WITH  FRAME f_linha.
                         DOWN WITH FRAME f_linha.
                         DISPLAY " " @ tel_dtrefere   
                                 "DESCONTO DE CHEQUES" @ tel_dslincre
                                 " " @ craptax.txmensal  
                                 " " @ craptax.txdiaria
                                 " " @ craptax.grlcremp  
                                 " " @ tel_dssitlcr
                              WITH  FRAME f_linha.
                         DOWN WITH FRAME f_linha.
                         DISPLAY " " @ tel_dtrefere   
                                 " " @ tel_dslincre
                                 " " @ craptax.txmensal  
                                 " " @ craptax.txdiaria
                                 " " @ craptax.grlcremp  
                                 " " @ tel_dssitlcr
                              WITH  FRAME f_linha.
                         DOWN WITH FRAME f_linha.
                       
                         ASSIGN aux_primvez = NO.
                      END.

                  VIEW FRAME f_descricao.
                  PAUSE(0).

                  ASSIGN aux_regexist = TRUE
                         tel_dtrefere =
                             SUBSTR(STRING(craptax.dtmvtolt,"99/99/9999"),4,7)
                         tel_dslincre = STRING(craptax.cdlcremp,"zzz9")    +
                                        " - " +  craptax.dslcremp
                         tel_dssitlcr = IF  craptax.insitlcr = 0
                                            THEN "L"
                                            ELSE "B"
                         aux_contador = aux_contador + 1.

                  IF   aux_contador = 1   THEN
                       IF   aux_flgretor   THEN
                            DO:
                               PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                               CLEAR FRAME f_linha ALL NO-PAUSE.
                            END.

                  DISPLAY tel_dtrefere         tel_dslincre
                          craptax.txmensal     craptax.txdiaria
                          " " @ craptax.grlcremp   
                          tel_dssitlcr
                          WITH  FRAME f_linha.

                  IF   aux_contador = 6   THEN
                       DO:
                           ASSIGN aux_contador = 0
                                  aux_flgretor = TRUE.
                       END.
                  ELSE
                       DOWN WITH FRAME f_linha.

              END. /* Fim do FOR EACH */  
              
              IF  NOT aux_regexist  THEN
                  DO:
                      glb_cdcritic = 347.
                      NEXT.
                  END.

           END. /* Fim do DO */ 

      ELSE
      IF   glb_cddopcao = "L"  THEN
           DO:
               tel_dsinduti = "".

               IF  aux_verifica <> glb_cddopcao THEN
                   DO:
                       HIDE FRAME f_observacao.
                       HIDE FRAME f_descricao.
                       HIDE FRAME f_descricao1.
                       HIDE FRAME f_descricao2.
                       HIDE FRAME f_descricao3.
                       HIDE FRAME f_linha.
                       HIDE FRAME f_linha2.
                       DISPLAY    tel_dsinduti WITH FRAME f_taxas.
                   END.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                  UPDATE tel_cdlcremp WITH FRAME f_taxas.

                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */

               CLEAR FRAME f_linha1 ALL NO-PAUSE.
               CLEAR FRAME f_linha3 ALL NO-PAUSE.

               ASSIGN aux_contador = 0
                      aux_flgretor = FALSE
                      aux_regexist = FALSE.

               CASE tel_tplincrd:

                 /* LINHA DE CREDITO */
                 WHEN 1 THEN
                 DO:
                     FOR EACH  craptax WHERE craptax.cdcooper  = glb_cdcooper  AND
                                             craptax.tpdetaxa  =  1            AND
                                             craptax.cdlcremp  =  tel_cdlcremp AND
                                             craptax.dtmvtolt >= aux_dtgerref
                                             USE-INDEX craptax2  
                                             NO-LOCK:
        
                        HIDE FRAME f_descricao3.
                        VIEW FRAME f_descricao2.
                        PAUSE(0).
        
                        ASSIGN aux_regexist = TRUE
                               tel_dtrefere =
                                   SUBSTR(STRING(craptax.dtmvtolt,"99/99/9999"),4,7)
                               tel_dslincre = STRING(craptax.cdlcremp,"zzz9")   +
                                              " - "  + craptax.dslcremp
                               tel_dssitlcr = IF  craptax.insitlcr = 0
                                                  THEN "L"
                                                  ELSE "B"
                               aux_contador = aux_contador + 1.
        
                        IF   aux_contador = 1   THEN
                             IF   aux_flgretor   THEN
                                  DO:
                                     PAUSE MESSAGE
                               "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                     CLEAR FRAME f_linha1 ALL NO-PAUSE.
                                  END.
        
                        DISPLAY tel_dtrefere         tel_dslincre
                                craptax.txmensal     craptax.txdiaria
                                craptax.grlcremp     tel_dssitlcr
                                WITH  FRAME f_linha1.
        
                        IF   aux_contador = 11 THEN
                             DO:
                                 ASSIGN aux_contador = 0
                                        aux_flgretor = TRUE.
                             END.
                        ELSE
                             DOWN WITH FRAME f_linha1.
        
                     END. /* Fim do FOR EACH. */
                 END.

                 /* LIMITE DE CREDITO */
                 WHEN 2 THEN
                 DO:
                     FOR EACH  craptax WHERE craptax.cdcooper  = glb_cdcooper  AND
                                             craptax.tpdetaxa  =  2            AND
                                             craptax.cdlcremp  =  tel_cdlcremp AND
                                             craptax.dtmvtolt >= aux_dtgerref
                                             USE-INDEX craptax2  
                                             NO-LOCK:
        
                         HIDE FRAME f_descricao2.
                         VIEW FRAME f_descricao3.
                         PAUSE(0).
               
                         ASSIGN aux_regexist = TRUE
                                tel_dtrefere =
                                    SUBSTR(STRING(craptax.dtmvtolt,"99/99/9999"),4,7)
                                tel_dslincre = STRING(craptax.cdlcremp,"zzz9")    +
                                               " - " +  craptax.dslcremp
                                aux_contador = aux_contador + 1.
               
                         IF   aux_contador = 1   THEN
                              IF   aux_flgretor   THEN
                                   DO:
                                      PAUSE MESSAGE
                                 "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                      CLEAR FRAME f_linha3 ALL NO-PAUSE.
                                   END.
               
                         DISPLAY tel_dtrefere         
                                 tel_dslincre
                                 craptax.txmensal     
                                 WITH FRAME f_linha3.
               
                         IF   aux_contador = 11   THEN
                              DO:
                                  ASSIGN aux_contador = 0
                                         aux_flgretor = TRUE.
                              END.
                         ELSE
                              DOWN WITH FRAME f_linha3.
        
                     END. /* Fim do FOR EACH */
                 END.

               END CASE.

               IF   NOT aux_regexist THEN
                    DO:
                        glb_cdcritic = 363.
                        NEXT.
                    END.

           END.         
   END. /* FIM do DO WHILE TRUE */

END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

