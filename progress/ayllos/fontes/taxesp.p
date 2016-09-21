/* .............................................................................

   Programa: Fontes/taxesp.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/94.                       Ultima atualizacao: 22/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAXRDCA.

   Alteracoes: 05/02/96 - Incluir tipo de taxa na tela (Odair).

               02/12/96 - Tratar RDCA2 (Odair).

               21/11/97 - Tratar RDCA 3O DIAS ESPECIAL (Edson).

               11/03/98 - Alterado para cadastrar taxa tipo 4 - idem tipo
                          3 para o periodo de 10/02/98 a 05/03/98 (Deborah).

               17/04/98 - Tratamento para milenio e troca para V8 (Margarete).
               
               30/11/1999 - Tratar taxa especial de poupanca programada                                      (Deborah).

               08/02/2001 - Aplicacoes RDCA60 e Poup. Progr. apos o dia 28 do
                            mes. (Eduardo).

               02/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_dtiniper AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_dtfimper AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_qtdiaute AS INTEGER FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_txofimes AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txofidia AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_txprodia AS DECIMAL FORMAT "zz9.999999"           NO-UNDO.
DEF        VAR tel_dscalcul AS CHAR    FORMAT "x(3)"                 NO-UNDO.
DEF        VAR tel_tptaxesp AS INTEGER FORMAT "9" INIT "1"           NO-UNDO.
DEF        VAR tel_vlfaixas AS DEC     FORMAT "zzz,zz9.99"           NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.

DEF        VAR aux_flgerros AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dsfaixas AS CHAR INIT "0,500,1.000"    NO-UNDO.
DEF        VAR aux_indpostp AS INT                                   NO-UNDO.

DEF        VAR aux_tptaxrda AS INTE               EXTENT 99          NO-UNDO.
DEF        VAR aux_vlfaixas AS DECIMAL            EXTENT 99          NO-UNDO.
DEF        VAR aux_txadical AS DECIMAL DECIMALS 6 EXTENT 99          NO-UNDO.
DEF        VAR aux_cartaxas AS INTE                                  NO-UNDO.
DEF        VAR aux_vllidtab AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgfaixa AS LOG                                   NO-UNDO.
DEF        VAR aux_qtdtxtab AS INTE                                  NO-UNDO.
DEF        VAR aux_qtfaixas AS INTE                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela
     FRAME f_moldura.

FORM glb_cddopcao AT  3 LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A,C,D,E ou I)."
                        VALIDATE(CAN-DO("A,C,E,I",glb_cddopcao),
                                 "014 - Opcao errada.")
     tel_tptaxesp AT 24 LABEL "Tipo de Taxa" AUTO-RETURN
     HELP "1 RDCA, 2 Poup.Progr., 3 RDCA60"
                        VALIDATE(CAN-DO("1,2,3",STRING(tel_tptaxesp)),
                                 "014 - Opcao errada.")
     SKIP(2)
     "De         Ate              Faixa Ut   Mes       Ofic. Dia"
     " Projet.Dia Cal?"
     SKIP(1)
     tel_dtiniper     AT 01  AUTO-RETURN
                        HELP "Entre com a data inicial de referencia."
                        VALIDATE(tel_dtiniper <> ?,"013 - Data errada.")
     tel_dtfimper     AT 12 NO-LABEL   /*  NAO COLOCAR AUTO-RETURN  */
                        HELP "Entre com a data final de referencia."
                        VALIDATE(tel_dtfimper <> ?,"013 - Data errada.")
     tel_vlfaixas     AT 24 NO-LABEL
                        HELP "Entre com o valor da faixa."
     tel_qtdiaute     AT 35  AUTO-RETURN
                        HELP "Entre com a quantidade de dias uteis."
                        VALIDATE(tel_qtdiaute > 0,"380 - Numero errado.")
     tel_txofimes     AT 38  AUTO-RETURN
                        HELP "Entre com a taxa oficial do mes."
     tel_txofidia     AT 49  AUTO-RETURN
                        HELP "Entre com a taxa oficial do dia."
     tel_txprodia     AT 61  AUTO-RETURN
                        HELP "Entre com a taxa projetada do dia."
     tel_dscalcul     AT 73
     WITH ROW 7 COLUMN 3 NO-BOX NO-LABEL SIDE-LABELS OVERLAY  FRAME f_taxesp.

ASSIGN  glb_cddopcao = "C"
        glb_cdcritic = 0.


ASSIGN aux_tptaxrda = 0
       aux_vlfaixas = 0
       aux_txadical = 0
       aux_qtfaixas = 0.
       
FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper     AND
                       craptab.nmsistem = "CRED"           AND
                       craptab.tptabela = "CONFIG"         AND
                       craptab.cdacesso = "TXADIAPLIC"     NO-LOCK:
                       
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtfaixas = aux_qtfaixas + 1
              aux_tptaxrda[aux_qtfaixas] = craptab.tpregist
              aux_txadical[aux_qtfaixas] = DECIMAL(ENTRY(2,aux_vllidtab,"#"))
              aux_vlfaixas[aux_qtfaixas] = DECIMAL(ENTRY(1,aux_vllidtab,"#")).
    END.
END.                  

VIEW FRAME f_moldura.

PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF  glb_cdcritic <> 0 THEN
       DO:
          RUN fontes/critic.p.
          BELL.
          MESSAGE glb_dscritic.
          glb_cdcritic = 0.
       END.

   NEXT-PROMPT tel_tptaxesp WITH FRAME f_taxesp.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao tel_tptaxesp tel_dtiniper WITH FRAME f_taxesp.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "taxesp"   THEN
                 DO:
                     HIDE FRAME f_moldura.
                     HIDE FRAME f_taxesp.
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

   ASSIGN tel_dtfimper = ?
          tel_qtdiaute = 0
          tel_txofimes = 0
          tel_txofidia = 0
          tel_txprodia = 0
          tel_dscalcul = ''.

     IF   glb_cddopcao = "A"   THEN
        DO:
             IF   tel_tptaxesp = 3  OR  /* rdca 60 */
                 /* tel_tptaxesp = 4  OR nao existe mais */
                  tel_tptaxesp = 2  THEN /* poupanca programada */
                  DO:
                      { includes/taxesp2a.i }   
                  END.
          /*   ELSE
             IF   tel_tptaxesp = 6   THEN  /* nao existe mais */
                  DO:
                      { includes/taxesp6a.i }  
                  END.*/   
               ELSE
                  DO:
                      { includes/taxespa.i }
                  END.
        END. 
   ELSE      
        IF   glb_cddopcao = "C"   THEN
             DO:
                 IF   tel_tptaxesp = 3  OR /* rdca 60 */
                    /*  tel_tptaxesp = 4  OR  nao existe mais */
                      tel_tptaxesp = 2  THEN /* poupanca programada */
                      DO:
                          { includes/taxesp2c.i }
                      END.
              /*   ELSE   
                 IF   tel_tptaxesp = 6   THEN /* nao existe mais */
                      DO:
                          { includes/taxesp6c.i }
                      END. */
                 ELSE   
                      DO:
                          { includes/taxespc.i }
                      END.
             END.
        ELSE
        /*     IF   glb_cddopcao = "D"   THEN
                  DO:
                      IF   tel_tptaxesp = 3  OR
                           tel_tptaxesp = 4  THEN
                           DO:
                               { includes/taxesp2d.i }
                           END.
                  END. 
             ELSE       */
                  IF   glb_cddopcao = "E"   THEN
                       DO:
                           IF   tel_tptaxesp = 3  OR /* rdca 60 */
                              /*  tel_tptaxesp = 4  OR */
                                tel_tptaxesp = 2  THEN /* poup.programada */
                                DO:
                                     { includes/taxesp2e.i }   
                                END.
                         /*  ELSE
                           IF   tel_tptaxesp = 6   THEN /* nao existe mais */
                                DO:
                                    { includes/taxesp6e.i }
                                END.*/ 
                           ELSE
                                DO:
                                    { includes/taxespe.i }
                                END.
                       END.
                  ELSE   
                       IF   glb_cddopcao = "I"   THEN
                            DO:
                                IF   tel_tptaxesp = 3  OR /* rdca 60 */
                                   /*  tel_tptaxesp = 4  OR */
                                     tel_tptaxesp = 2  THEN /*poup.programada*/
                                     DO:
                                         { includes/taxesp2i.i }
                                     END.
                             /*   ELSE
                                IF   tel_tptaxesp = 6   THEN /* nao existe */
                                     DO:
                                         { includes/taxesp6i.i }
                                     END. */  
                                ELSE
                                     DO:
                                         { includes/taxespi.i }
                                     END. 
                            END.
END.

/* .......................................................................... */

