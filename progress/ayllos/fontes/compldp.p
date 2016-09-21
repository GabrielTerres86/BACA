/* .............................................................................

   Programa: Fontes/compld.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/Supero
   Data    : Fevereiro/2011                       Ultima alteracao:  /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela COMPEL para Custodia e Descontos nao
               digitalizados.

   Alteracoes: 
                            
............................................................................. */

{ includes/var_online.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF    VAR aut_flgsenha AS LOGICAL                                   NO-UNDO.
DEF    VAR aut_cdoperad AS CHAR                                      NO-UNDO.

DEF    VAR aux_posregis AS RECID                                     NO-UNDO.

DEF TEMP-TABLE crawage                                               NO-UNDO
       FIELD  cdagenci      LIKE crapage.cdagenci
       FIELD  nmresage      LIKE crapage.nmresage
       FIELD  nmcidade      LIKE crapage.nmcidade
       FIELD  cdbandoc      LIKE crapage.cdbandoc
       FIELD  cdbantit      LIKE crapage.cdbantit
       FIELD  cdagecbn      LIKE crapage.cdagecbn
       FIELD  cdbanchq      LIKE crapage.cdbanchq
       FIELD  cdcomchq      LIKE crapage.cdcomchq.

DEF QUERY q_agencia  FOR crawage. 
                                     
DEF BROWSE b_agencia  QUERY q_agencia
      DISP crawage.cdagenci COLUMN-LABEL "PAC" 
           crawage.nmresage COLUMN-LABEL "Nome"
           WITH 13 DOWN CENTERED NO-BOX.

DEF BUFFER crabchd FOR crapchd.
DEF BUFFER crabcdb FOR crapcdb.
DEF BUFFER crabcst FOR crapcst.

DEF        VAR tel_nrdhhini AS INT                                   NO-UNDO.
DEF        VAR tel_nrdmmini AS INT                                   NO-UNDO.
DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_dssituac AS CHAR   FORMAT "x(17)"                 NO-UNDO.
DEF        VAR tel_cddsenha AS CHAR   FORMAT "x(10)"                 NO-UNDO.

DEF   VAR tel_situacao AS LOG   FORMAT "NAO PROCESSADO/PROCESSADO"   NO-UNDO.

DEF        VAR tel_qtchdcxi AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcxs AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcxg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_qtchdcsi AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcss AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdcsg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_qtchddci AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchddcs AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchddcg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_qtchdtti AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdtts AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_qtchdttg AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR tel_vlchdcxi AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcxs AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcxg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_vlchdcsi AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcss AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdcsg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_vlchddci AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchddcs AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchddcg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_vlchdtti AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdtts AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_vlchdttg AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_dtmvtopg AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_flgenvio AS LOG    FORMAT "Enviados/Nao Enviados" NO-UNDO.

DEF        VAR tel_flggerar AS CHAR   FORMAT "x(18)" VIEW-AS COMBO-BOX
   LIST-ITEMS "Custodia Cheques",
              "Desconto Cheques" NO-UNDO.

DEF        VAR tel_dtentrad AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_nrdcaixa AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_nrdolote AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR aux_imprimcr AS LOG    FORMAT "Carta/Relatorio"       NO-UNDO.

DEF        VAR aux_cdbcoenv AS CHAR    INIT "0"                      NO-UNDO.
DEF        VAR aux_flggerar AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR aux_dsbcoenv AS CHAR                                  NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR   FORMAT "!(1)"                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_nrdahora AS INT                                   NO-UNDO.
DEF        VAR aux_cdsituac AS INT                                   NO-UNDO.
DEF        VAR aux_qtarquiv AS INT                                   NO-UNDO.
DEF        VAR aux_flgenvio AS LOG                                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_confirm2 AS INT    FORMAT "9"                     NO-UNDO.

DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_vltotarq AS DECI                                  NO-UNDO.

DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtmvtolt AS CHAR                                  NO-UNDO.
DEF        VAR aux_dtmvtopr AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdat AS CHAR   FORMAT "x(20)"                 NO-UNDO.
DEF        VAR aux_tpdmovto AS CHAR                                  NO-UNDO.
DEF        VAR tot_qtarquiv AS INT                                   NO-UNDO.
DEF        VAR tot_vlcheque AS DECIMAL                               NO-UNDO.
DEF        VAR aux_totqtchq AS INT                                   NO-UNDO.
DEF        VAR aux_totvlchq AS DECIMAL                               NO-UNDO.
DEF        VAR aux_flgerror AS LOGICAL                               NO-UNDO.

DEF        VAR tel_dsdocmc7 AS CHAR   FORMAT "x(34)"                 NO-UNDO.
DEF        VAR aux_lsvalido AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsdigctr AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdagefim LIKE craptvl.cdagenci                    NO-UNDO.
DEF        VAR aux_cdbanchq LIKE crapchd.cdbanchq                    NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_cddsenha AS CHAR    FORMAT "x(8)"                 NO-UNDO.
DEF        VAR aux_nrdcaixa AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_dscopcao AS CHAR    FORMAT "x(10)"                NO-UNDO.
    
DEF        VAR rel_nmcidade AS CHAR    FORMAT "x(27)"                NO-UNDO.
DEF        VAR rel_qttotmen AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_qttotmai AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR rel_qttotger AS INT     FORMAT "zzz,zz9"              NO-UNDO.

DEF        VAR rel_vltotmen AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR rel_vltotmai AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.
DEF        VAR rel_vltotger AS DECI    FORMAT "zzz,zzz,zz9.99"       NO-UNDO.

DEF        VAR rel_dsmvtolt AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR rel_mmmvtolt AS CHAR    FORMAT "x(17)"  EXTENT 12 
                                    INIT["DE  JANEIRO  DE","DE FEVEREIRO DE",
                                         "DE   MARCO   DE","DE   ABRIL   DE",
                                         "DE   MAIO    DE","DE   JUNHO   DE",
                                         "DE   JULHO   DE","DE   AGOSTO  DE",
                                         "DE  SETEMBRO DE","DE  OUTUBRO  DE",
                                         "DE  NOVEMBRO DE","DE  DEZEMBRO DE"]
                                                                     NO-UNDO.
/* variaveis para impressao */
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

/* variaveis da procedure p_divinome */
DEF        VAR aux_qtpalavr AS INTE                                  NO-UNDO.
DEF        VAR rel_nmressbr AS CHAR    EXTENT 2 FORMAT "x(60)"       NO-UNDO.
DEF        VAR aux_contapal AS INTE                                  NO-UNDO.
DEF        VAR aux_nmextcop AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdbccxlt AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmdatela AS CHAR                                  NO-UNDO.

DEF        VAR aux_totregis AS INT                                   NO-UNDO.
DEF        VAR aux_vlrtotal AS DEC                                   NO-UNDO.

DEF VAR h-b1wgen0012 AS HANDLE                                       NO-UNDO.


DEF        TEMP-TABLE crattem                                        NO-UNDO
           FIELD cdseqarq AS INTEGER
           FIELD nrrecchd AS RECID
           INDEX crattem1 cdseqarq.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
               HELP "Informe a opcao desejada (B ou C)."
               VALIDATE(CAN-DO("B,C",glb_cddopcao),
                               "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_compld.

/* FORM tel_dtmvtopg AT 1 LABEL " Dt. Entrada"                                         */
/*                        HELP "Entre com a data de referencia do movimento."          */
/*      tel_cdagenci      LABEL " PAC"                                                 */
/*                  HELP "Entre com o numero do PAC"                                   */
/*             VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper AND     */
/*                                             crapage.cdagenci = INPUT tel_cdagenci), */
/*                                             "015 - Agencia nao cadastrada.")        */
/*      tel_flggerar      LABEL "  Gerar"                                              */
/*      SKIP                                                                           */
/*      WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.                */


FORM tel_dtmvtopg AT  2 LABEL "Dt. Entrada"
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci AT 27 LABEL "PAC"
                 HELP "Entre com o numero do PAC ou 0 para todos os PAC's."
    VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                            crapage.cdagenci = INPUT tel_cdagenci),
                                            "015 - Agencia nao cadastrada.")
     tel_flggerar AT 36 LABEL "  Gerar"
     SKIP
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

FORM tel_dtmvtopg AT  2 LABEL "Referencia"
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci AT 28 LABEL "PAC"
                 HELP "Entre com o numero do PAC ou 0 para todos os PAC's."
     tel_flgenvio AT 40 LABEL "Opcao" 
                 HELP "Informe 'N' para nao enviados ou 'E' para enviados."
     SKIP
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_v.


FORM aux_dscopcao   AT 6  NO-LABEL
     "----- Inferior ----- ----- Superior ----- ------- Total ------" AT 16
     SKIP(1)
     "TOTAL GERAL:" AT  3
     tel_qtchdtti   AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtti   AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdtts   AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtts   AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdttg   AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdttg   AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(3)
     WITH ROW 10 COLUMN 2 NO-BOX OVERLAY SIDE-LABELS FRAME f_total.

FORM "----- Inferior ----- ----- Superior ----- ------- Total ------" AT 16
     SKIP(1)
     "Custodia:"  AT  6
     tel_qtchdcsi AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcsi AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcss AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcss AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdcsg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdcsg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP
     "Desconto:"  AT  6
     tel_qtchddci AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddci AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchddcs AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddcs AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchddcg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchddcg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(1)
     "TOTAL GERAL:" AT 3
     tel_qtchdtti AT 16 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtti AT 22 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdtts AT 37 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdtts AT 43 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     tel_qtchdttg AT 58 FORMAT "zzzz9"          NO-LABEL
     tel_vlchdttg AT 64 FORMAT "zzz,zzz,zz9.99" NO-LABEL
     SKIP(3)
     WITH ROW 10 COLUMN 2 NO-BOX OVERLAY SIDE-LABELS FRAME f_total_2.



/* FORM SKIP(1)                                                   */
/*      "(B) - Gerar arquivos" SKIP                               */
/*      "(C) - Consultar" SKIP                                    */
/*      WITH SIZE 63 BY 10 CENTERED OVERLAY ROW 8                 */
/*      TITLE "Escolha uma das opcoes abaixo:" FRAME f_helpopcao. */


ON RETURN OF tel_flggerar DO:

   aux_flggerar = tel_flggerar:SCREEN-VALUE.

   APPLY "GO".
END.


/* Busca dados da cooperativa */
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

/*--- Inicializa com todas as agencias --*/
FIND FIRST crawage NO-LOCK NO-ERROR.
IF  NOT AVAIL crawage THEN
    DO:

       FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
           CREATE crawage.
           ASSIGN crawage.cdagenci = crapage.cdagenci
                  crawage.nmresage = crapage.nmresage
                  crawage.nmcidade = crapage.nmcidade 
                  crawage.cdagecbn = crapage.cdagecbn
                  crawage.cdbanchq = crapage.cdbanchq
                  crawage.cdcomchq = crapage.cdcomchq.
       END. 
    END.      

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtopg = glb_dtmvtolt.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).
   
DO WHILE TRUE:

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               PAUSE 2 NO-MESSAGE.
           END.

      RUN proc_limpa.
/*       VIEW FRAME f_helpopcao. */
      PAUSE(0).
      
      UPDATE glb_cddopcao  WITH FRAME f_compld.

/*       HIDE FRAME f_helpopcao NO-PAUSE.  */
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "COMPLD"  THEN
                 DO:
                     RUN proc_limpa.
                     HIDE FRAME f_compld.
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


   CASE glb_cddopcao:
       
    WHEN "B" THEN DO:

        RUN proc_limpa.
        
        ASSIGN tel_dtmvtopg = glb_dtmvtolt
               tel_cdagenci = 0.

        UPDATE tel_dtmvtopg   tel_cdagenci WITH FRAME f_refere.
        UPDATE tel_flggerar WITH FRAME f_refere.

         /*  Nao deixa gerar arquivo no dia 31/12 - NAO TEM COMPE  */
        
        IF   MONTH(tel_dtmvtopg) = 12   AND
             DAY(tel_dtmvtopg)   = 31   THEN
             DO:
                 glb_cdcritic = 13.
                 NEXT.
             END.

        ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                              THEN 9999
                              ELSE tel_cdagenci.
                 
        ASSIGN aux_cdsituac = 0
               aux_cdagenci = 0
               glb_cdcritic = 0
               tel_nrdcaixa = 0
               tel_nrdolote = 0
               tel_dtentrad = glb_dtmvtolt.
               
        FOR EACH crapage WHERE crapage.cdcooper  = glb_cdcooper AND
                               crapage.cdagenci >= tel_cdagenci AND
                               crapage.cdagenci <= aux_cdagefim NO-LOCK,
            EACH crawage WHERE crawage.cdagenci  = crapage.cdagenci AND
                               crawage.cdbanchq <> crapcop.cdbcoctl
                               NO-LOCK:
        
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                               craptab.nmsistem = "CRED"        AND
                               craptab.tptabela = "GENERI"      AND
                               craptab.cdempres = 00            AND
                               craptab.cdacesso = "HRTRCOMPEL"  AND
                               craptab.tpregist = crapage.cdagenci
                               NO-LOCK NO-ERROR.

            IF   NOT AVAILABLE craptab   THEN
                 DO:
                     glb_cdcritic = 55.
                     NEXT.
                 END.

            ASSIGN aux_nrdahora = INT(SUBSTR(craptab.dstextab,03,05)).
            
            FIND FIRST crapchd WHERE 
                       crapchd.cdcooper  = glb_cdcooper      AND
                       crapchd.dtmvtolt  = tel_dtmvtopg      AND
                       crapchd.inchqcop  = 0                 AND
                       crapchd.cdagenci  = crapage.cdagenci  AND
                       crapchd.cdbanchq <> crapcop.cdbcoctl
                       NO-LOCK NO-ERROR.

            IF  aux_cdsituac = 0 THEN 
                DO:
                   IF  AVAIL crapchd THEN
                       ASSIGN aux_cdsituac =
                                  INT(SUBSTR(craptab.dstextab,1,1)).
                END.
        
        END.  /* For each crapage */
        
        ASSIGN aux_flgenvio = NO.

        
        /* CONSULTA E EXIBE NA TELA */
        CASE aux_flggerar:

          WHEN "Custodia Cheques"     THEN 
              RUN proc_compld(INPUT "600").

          WHEN "Desconto Cheques" THEN
              RUN proc_compld(INPUT "700").

        END CASE.



        IF  glb_cdcritic <> 0 THEN
            DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               MESSAGE "AGENCIA = "  aux_cdagenci.                 
               NEXT.
            END.

        ASSIGN aux_confirma = "S".

        IF  aux_cdsituac <> 0   THEN
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                aux_confirma = "N".
                BELL.
                MESSAGE COLOR NORMAL 
                       "Os arquivos ja foram gravados."
                       "Deseja regrava-los? (S/N):"
                        UPDATE aux_confirma.
                        glb_cdcritic = 0.
                        LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
             aux_confirma <> "S" THEN
             DO:
                 glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 RUN proc_limpa.
                 NEXT.
             END.
        
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           aux_confirma = "N".

           glb_cdcritic = 78.
           RUN fontes/critic.p.
           BELL.
           MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
           glb_cdcritic = 0.
           LEAVE.

        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
             aux_confirma <> "S" THEN
             DO:
                 glb_cdcritic = 79.
                 RUN fontes/critic.p.
                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 RUN proc_limpa.
                 NEXT.
             END.


        /*---- Controle de 1 operador utilizando  tela --*/                
        DO TRANSACTION:
           FIND  craptab WHERE
                 craptab.cdcooper = glb_cdcooper      AND       
                 craptab.nmsistem = "CRED"            AND
                 craptab.tptabela = "GENERI"          AND
                 craptab.cdempres = glb_cdcooper      AND         
                 craptab.cdacesso = "COMPLD"          AND
                 craptab.tpregist = 1                 NO-LOCK NO-ERROR.
       
           IF  NOT AVAIL craptab THEN 
               DO:
                  CREATE craptab.
                  ASSIGN craptab.nmsistem = "CRED"      
                         craptab.tptabela = "GENERI"          
                         craptab.cdempres = glb_cdcooper            
                         craptab.cdacesso = "COMPLD"                
                         craptab.tpregist = 1  
                         craptab.cdcooper = glb_cdcooper.       
                  RELEASE craptab.    
               END.
        END. /* Fim da Transacao */

        FIND FIRST  crapcop WHERE crapcop.cdcooper = glb_cdcooper
                          NO-LOCK NO-ERROR.
        IF  NOT AVAIL crapcop  THEN
            DO:
               glb_cdcritic = 651.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic "--> SISTEMA CANCELADO!".
               PAUSE MESSAGE
               "Tecle <entra> para voltar `a tela de identificacao!".
               BELL.
               NEXT.
            END.

        DO  WHILE TRUE:
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper      AND
                               craptab.nmsistem = "CRED"            AND
                               craptab.tptabela = "GENERI"          AND
                               craptab.cdempres = crapcop.cdcooper  AND
                               craptab.cdacesso = "COMPLD"          AND
                               craptab.tpregist = 1 NO-LOCK NO-ERROR.
                               
            IF  NOT AVAIL craptab THEN 
                DO:
                   MESSAGE 
                   "Controle nao cad.(Avise Inform) Processo Cancelado!".
                   PAUSE MESSAGE
                   "Tecle <entra> para voltar `a tela de identificacao!".
                   BELL.
                   LEAVE.
                END.

            IF  craptab.dstextab <> " " THEN
                DO:
                    MESSAGE
                       "Processo sendo utilizado pelo Operador " +
                       TRIM(SUBSTR(craptab.dstextab,1,20)).
                    PAUSE MESSAGE
                     "Peca liberacao Coordenador/Gerente ou Aguarde......".
                
                    RUN fontes/pedesenha.p (INPUT glb_cdcooper, 
                                            INPUT 2, 
                                            OUTPUT aut_flgsenha,
                                            OUTPUT aut_cdoperad).
                                                                          
                    IF   aut_flgsenha    THEN
                         LEAVE.
            
                    NEXT.
                
                END.

            LEAVE.
        END.
        
        DO TRANSACTION:
           FIND craptab WHERE craptab.cdcooper = glb_cdcooper         AND
                              craptab.nmsistem = "CRED"               AND
                              craptab.tptabela = "GENERI"             AND
                              craptab.cdempres = crapcop.cdcooper     AND
                              craptab.cdacesso = "COMPLD"             AND
                              craptab.tpregist = 1  
                              EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
           IF  AVAIL craptab THEN     
               DO:
                  ASSIGN craptab.dstextab = glb_cdoperad.
                  RELEASE craptab.
               END.
        END. /* DO TRANSACTION */  
        /*----------------------------------------*/


        /* Instancia a BO 12 */
        RUN sistema/generico/procedures/b1wgen0012.p 
            PERSISTENT SET h-b1wgen0012.

        IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
             DO:
                 glb_nmdatela = "COMPLD".
                 BELL.
                 MESSAGE "Handle invalido para BO b1wgen0012.".
                 IF   glb_conta_script = 0 THEN
                      PAUSE 3 NO-MESSAGE.
                 RETURN.
             END.

        ASSIGN tel_dtentrad = tel_dtmvtopg
               aux_nmdatela =
                      IF   aux_flggerar = "Custodia Cheques" THEN
                           "COMPLD_CST"
                      ELSE
                           "COMPLD_DSC"
               aux_nrdcaixa =
                      IF   aux_flggerar = "Custodia Cheques" THEN
                           600
                      ELSE
                           700.

        RUN gerar_arquivos_cecred
               IN h-b1wgen0012(INPUT "COMPEL",
                               INPUT tel_dtentrad,
                               INPUT glb_cdcooper,
                               INPUT tel_cdagenci,
                               INPUT aux_cdagefim,
                               INPUT glb_cdoperad,
                               INPUT aux_nmdatela,
                               INPUT tel_nrdolote,         /*nrdolote*/
                               INPUT 0,                    /*nrdcaixa*/
                               INPUT STRING(aux_nrdcaixa), /*cdbccxlt*/
                               OUTPUT glb_cdcritic,
                               OUTPUT aux_qtarquiv,
                               OUTPUT aux_totregis,
                               OUTPUT aux_vlrtotal).

        DELETE PROCEDURE h-b1wgen0012.
        /* Fim - Instancia a BO 12 */


        IF   glb_cdcritic > 0  THEN
             DO:
                 RUN atualiza_controle_operador.
                 NEXT.
             END.

        HIDE MESSAGE NO-PAUSE.

        /** VERIFICAR */
        DO ON STOP UNDO, LEAVE:
           RUN fontes/compld_r.p(INPUT tel_dtmvtopg,
                                 INPUT tel_cdagenci,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT TRUE,
                                 INPUT TABLE crawage,
                                 INPUT NO,
                                 INPUT NO).

           PAUSE 2 NO-MESSAGE.
        END.

        HIDE MESSAGE NO-PAUSE.

        RUN atualiza_compld (INPUT STRING(aux_nrdcaixa) ).


        MESSAGE "Movtos atualizados         ".

        RUN atualiza_controle_operador.


        ASSIGN tot_qtarquiv = aux_qtarquiv
               tot_vlcheque = aux_vlrtotal.

        MESSAGE "Foi(ram) gravado(s) " STRING(tot_qtarquiv, "zzz9") +
                " arquivo(s) - com o valor total: " + 
                STRING(tot_vlcheque, "zzz,zzz,zz9.99").

        PAUSE(3) NO-MESSAGE.

    END. /* END do WHEN "B" THEN DO */



    WHEN "C" THEN DO:

        RUN proc_limpa.

        ASSIGN tel_flgenvio = TRUE.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

           UPDATE tel_dtmvtopg   tel_cdagenci
                  WITH FRAME f_refere_v.

           UPDATE tel_flgenvio WITH FRAME f_refere_v.

           ASSIGN aux_flgenvio = tel_flgenvio.


           RUN proc_compld(INPUT "600,700").

           aux_confirma = "N".

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              IF   tel_qtchdttg = 0   THEN
                   LEAVE.
           
              MESSAGE COLOR NORMAL
                      "Deseja listar os LOTES referentes a pesquisa(S/N)?:"
                      UPDATE aux_confirma.
              LEAVE.

           END. /* fim do DO WHILE */

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                aux_confirma <> "S"                  THEN .
           ELSE
               RUN fontes/compld_r.p(INPUT tel_dtmvtopg, 
                                     INPUT tel_cdagenci,
                                     INPUT 0, 
                                     INPUT 0, 
                                     INPUT FALSE,
                                     INPUT TABLE crawage,                     
                                     INPUT tel_flgenvio,
                                     INPUT tel_flgenvio).
        END. /*  Fim do DO WHILE TRUE  */

    END. /* END do WHEN "C" THEN DO */

   END CASE.
    
END.  /*  Fim do DO WHILE TRUE  */


/*  ........................................................................  */

/* PROCEDURE proc_compld_old:                                                       */
/*                                                                                  */
/*    DEF INPUT PARAM par_cdbccxlt    AS CHAR           NO-UNDO.                    */
/*                                                                                  */
/*    ASSIGN tel_qtchdcxi = 0                                                       */
/*           tel_qtchdcxs = 0                                                       */
/*           tel_qtchdcxg = 0                                                       */
/*                                                                                  */
/*           tel_vlchdcxi = 0                                                       */
/*           tel_vlchdcxs = 0                                                       */
/*           tel_vlchdcxg = 0                                                       */
/*                                                                                  */
/*           tel_qtchddci = 0                                                       */
/*           tel_qtchddcs = 0                                                       */
/*           tel_qtchddcg = 0                                                       */
/*                                                                                  */
/*           tel_vlchddci = 0                                                       */
/*           tel_vlchddcs = 0                                                       */
/*           tel_vlchddcg = 0                                                       */
/*                                                                                  */
/*           tel_qtchdcsi = 0                                                       */
/*           tel_qtchdcss = 0                                                       */
/*           tel_qtchdcsg = 0                                                       */
/*                                                                                  */
/*           tel_vlchdcsi = 0                                                       */
/*           tel_vlchdcss = 0                                                       */
/*           tel_vlchdcsg = 0                                                       */
/*                                                                                  */
/*           tel_qtchdtti = 0                                                       */
/*           tel_qtchdtts = 0                                                       */
/*           tel_qtchdttg = 0                                                       */
/*                                                                                  */
/*           tel_vlchdtti = 0                                                       */
/*           tel_vlchdtts = 0                                                       */
/*           tel_vlchdttg = 0.                                                      */
/*                                                                                  */
/*    ASSIGN aux_cdagefim = IF tel_cdagenci = 0                                     */
/*                          THEN 9999                                               */
/*                          ELSE tel_cdagenci.                                      */
/*                                                                                  */
/*                                                                                  */
/*    /* Na consulta devera aparecer os dados da CECRED - 085 */                    */
/*    /* Nas demais operacoes nao devem tratar   CECRED - 085 */                    */
/*    IF   glb_cddopcao <> "C" THEN                                                 */
/*         DO:                                                                      */
/*             IF   aux_flgenvio THEN /* Enviados */                                */
/*                                                                                  */
/*                 /*OBS: Temporariamente foi incluido o 0 no cdbcoenv pois         */
/*                 só o campo da tabela so sera alimentado com 1,756, 85            */
/*                 quando for liberado a compe. Apos isso, remover o 0 */           */
/*                  ASSIGN aux_cdbcoenv = "0,1,756," + STRING(crapcop.cdbcoctl).    */
/*             ELSE                   /* Nao Enviados */                            */
/*                  ASSIGN aux_cdbcoenv = "0".                                      */
/*         END.                                                                     */
/*                                                                                  */
/*                                                                                  */
/*    FOR EACH crapchd WHERE crapchd.cdcooper  = glb_cdcooper AND                   */
/*                           crapchd.dtmvtolt  = tel_dtmvtopg AND                   */
/*                           crapchd.cdagenci >= tel_cdagenci AND                   */
/*                           crapchd.cdagenci <= aux_cdagefim AND                   */
/*                           crapchd.inchqcop  = 0            AND                   */
/*                           crapchd.flgenvio  = aux_flgenvio AND                   */
/*                           CAN-DO(aux_cdbcoenv,STRING(crapchd.cdbcoenv)) AND      */
/*                           CAN-DO(par_cdbccxlt,STRING(crapchd.cdbccxlt))          */
/*                           NO-LOCK,                                               */
/*        EACH crawage WHERE crawage.cdagenci  = crapchd.cdagenci                   */
/*                           NO-LOCK BREAK BY crawage.cdagenci:                     */
/*                                                                                  */
/*        /*                                                                        */
/*          Nao processar registro para opcao "B". Na atualiza_compld foi colocado  */
/*          restricao tambem. Para isto sera utilizado a tela PRCCTL                */
/*        */                                                                        */
/*                                                                                  */
/*        IF  glb_cddopcao = "B"  AND                                               */
/*            crawage.cdbanchq = crapcop.cdbcoctl  THEN                             */
/*            NEXT.                                                                 */
/*                                                                                  */
/*        IF   crawage.cdbanchq <> 1 AND glb_cddopcao = "D"   THEN                  */
/*             NEXT.                                                                */
/*                                                                                  */
/*        IF   crapchd.tpdmovto <> 1   AND                                          */
/*             crapchd.tpdmovto <> 2   THEN                                         */
/*             NEXT.                                                                */
/*                                                                                  */
/*        IF   NOT CAN-DO("0,2",STRING(crapchd.insitchq))   THEN                    */
/*             NEXT.                                                                */
/*                                                                                  */
/*        IF   CAN-DO("11,500",STRING(crapchd.cdbccxlt))   THEN       /*  CAIXA  */ */
/*             DO:                                                                  */
/*                 ASSIGN tel_qtchdcxg = tel_qtchdcxg + 1                           */
/*                        tel_vlchdcxg = tel_vlchdcxg + crapchd.vlcheque.           */
/*                                                                                  */
/*                 IF   crapchd.tpdmovto = 1   THEN                                 */
/*                      ASSIGN tel_qtchdcxs = tel_qtchdcxs + 1                      */
/*                             tel_vlchdcxs = tel_vlchdcxs + crapchd.vlcheque       */
/*                                                                                  */
/*                             tel_qtchdtts = tel_qtchdtts + 1                      */
/*                             tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.      */
/*                 ELSE                                                             */
/*                 IF   crapchd.tpdmovto = 2   THEN                                 */
/*                      ASSIGN tel_qtchdcxi = tel_qtchdcxi + 1                      */
/*                             tel_vlchdcxi = tel_vlchdcxi + crapchd.vlcheque       */
/*                                                                                  */
/*                             tel_qtchdtti = tel_qtchdtti + 1                      */
/*                             tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.      */
/*             END.                                                                 */
/*        ELSE                                                                      */
/*        IF   CAN-DO("600",STRING(crapchd.cdbccxlt))   THEN       /*  CUSTODIA  */ */
/*             DO:                                                                  */
/*                 ASSIGN tel_qtchdcsg = tel_qtchdcsg + 1                           */
/*                        tel_vlchdcsg = tel_vlchdcsg + crapchd.vlcheque.           */
/*                                                                                  */
/*                 IF   crapchd.tpdmovto = 1   THEN                                 */
/*                      ASSIGN tel_qtchdcss = tel_qtchdcss + 1                      */
/*                             tel_vlchdcss = tel_vlchdcss + crapchd.vlcheque       */
/*                                                                                  */
/*                             tel_qtchdtts = tel_qtchdtts + 1                      */
/*                             tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.      */
/*                 ELSE                                                             */
/*                 IF   crapchd.tpdmovto = 2   THEN                                 */
/*                      ASSIGN tel_qtchdcsi = tel_qtchdcsi + 1                      */
/*                             tel_vlchdcsi = tel_vlchdcsi + crapchd.vlcheque       */
/*                                                                                  */
/*                             tel_qtchdtti = tel_qtchdtti + 1                      */
/*                             tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.      */
/*             END.                                                                 */
/*        ELSE                                                                      */
/*        IF   CAN-DO("700",STRING(crapchd.cdbccxlt))   THEN      /*  DESC. CHQ  */ */
/*             DO:                                                                  */
/*                 ASSIGN tel_qtchddcg = tel_qtchddcg + 1                           */
/*                        tel_vlchddcg = tel_vlchddcg + crapchd.vlcheque.           */
/*                                                                                  */
/*                 IF   crapchd.tpdmovto = 1   THEN                                 */
/*                      ASSIGN tel_qtchddcs = tel_qtchddcs + 1                      */
/*                             tel_vlchddcs = tel_vlchddcs + crapchd.vlcheque       */
/*                                                                                  */
/*                             tel_qtchdtts = tel_qtchdtts + 1                      */
/*                             tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.      */
/*                 ELSE                                                             */
/*                 IF   crapchd.tpdmovto = 2   THEN                                 */
/*                      ASSIGN tel_qtchddci = tel_qtchddci + 1                      */
/*                             tel_vlchddci = tel_vlchddci + crapchd.vlcheque       */
/*                                                                                  */
/*                             tel_qtchdtti = tel_qtchdtti + 1                      */
/*                             tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.      */
/*             END.                                                                 */
/*                                                                                  */
/*        ASSIGN tel_qtchdttg = tel_qtchdttg + 1                                    */
/*               tel_vlchdttg = tel_vlchdttg + crapchd.vlcheque.                    */
/*                                                                                  */
/*        IF   LAST-OF(crawage.cdagenci)   THEN                                     */
/*             IF   glb_cddopcao = "D"   THEN                                       */
/*                  DO:                                                             */
/*                      ASSIGN rel_nmcidade = crawage.nmcidade.                     */
/*                                                                                  */
/*                                                                                  */
/*                      DISPLAY STREAM str_1                                        */
/*                                     rel_nmcidade                                 */
/*                                     crawage.cdagecbn                             */
/*                                     crawage.cdagenci                             */
/*                                     tel_qtchdtti                                 */
/*                                     tel_qtchdtts                                 */
/*                                     tel_qtchdttg                                 */
/*                                     WITH FRAME f_protocolos.                     */
/*                                                                                  */
/*                      DOWN STREAM str_1 WITH FRAME f_protocolos.                  */
/*                                                                                  */
/*                      ASSIGN rel_qttotmen = rel_qttotmen + tel_qtchdtti           */
/*                             rel_qttotmai = rel_qttotmai + tel_qtchdtts           */
/*                             rel_qttotger = rel_qttotger + tel_qtchdttg           */
/*                             tel_qtchdtti = 0                                     */
/*                             tel_qtchdtts = 0                                     */
/*                             tel_qtchdttg = 0.                                    */
/*                  END.                                                            */
/*                                                                                  */
/*    END.  /*  Fim do FOR EACH  --  Leitura do crapchd  */                         */
/*                                                                                  */
/*    IF   tel_qtchdttg <> (tel_qtchdcxg + tel_qtchdcsg + tel_qtchddcg)   OR        */
/*         tel_vlchdttg <> (tel_vlchdcxg + tel_vlchdcsg + tel_vlchddcg)   THEN      */
/*         DO:                                                                      */
/*             MESSAGE "ERRO - Informe o CPD ==> Qtd: "                             */
/*                     STRING(tel_qtchdcxg + tel_qtchdcsg + tel_qtchddcg,           */
/*                            "zzz,zz9-")                                           */
/*                     " Valor: "                                                   */
/*                     STRING(tel_vlchdcxg + tel_vlchdcsg + tel_vlchddcg,           */
/*                            "zzz,zzz,zz9.99-") .                                  */
/*         END.                                                                     */
/*                                                                                  */
/*    DISPLAY tel_qtchdcxi tel_vlchdcxi                                             */
/*            tel_qtchdcxs tel_vlchdcxs                                             */
/*            tel_qtchdcxg tel_vlchdcxg                                             */
/*                                                                                  */
/*            tel_qtchdcsi tel_vlchdcsi                                             */
/*            tel_qtchdcss tel_vlchdcss                                             */
/*            tel_qtchdcsg tel_vlchdcsg                                             */
/*                                                                                  */
/*            tel_qtchddci tel_vlchddci                                             */
/*            tel_qtchddcs tel_vlchddcs                                             */
/*            tel_qtchddcg tel_vlchddcg                                             */
/*                                                                                  */
/*            tel_qtchdtti tel_vlchdtti                                             */
/*            tel_qtchdtts tel_vlchdtts                                             */
/*            tel_qtchdttg tel_vlchdttg                                             */
/*            WITH FRAME f_total.                                                   */
/*                                                                                  */
/* END PROCEDURE.                                                                   */

PROCEDURE proc_compld:

   DEF INPUT PARAM par_cdbccxlt    AS CHAR           NO-UNDO.
   
   DEF VAR tab_vlchqmai            AS DECI           NO-UNDO.

   ASSIGN tel_qtchddci = 0
          tel_qtchddcs = 0
          tel_qtchddcg = 0
   
          tel_vlchddci = 0
          tel_vlchddcs = 0
          tel_vlchddcg = 0

          tel_qtchdcsi = 0
          tel_qtchdcss = 0
          tel_qtchdcsg = 0

          tel_vlchdcsi = 0
          tel_vlchdcss = 0
          tel_vlchdcsg = 0

          tel_qtchdtti = 0
          tel_qtchdtts = 0
          tel_qtchdttg = 0

          tel_vlchdtti = 0
          tel_vlchdtts = 0
          tel_vlchdttg = 0.


   FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                            craptab.nmsistem = "CRED"              AND
                            craptab.tptabela = "USUARI"            AND
                            craptab.cdempres = 11                  AND
                            craptab.cdacesso = "MAIORESCHQ"        AND
                            craptab.tpregist = 1
                            NO-LOCK NO-ERROR.

   IF   NOT AVAIL craptab   THEN
        ASSIGN tab_vlchqmai = 1.
   ELSE
        ASSIGN tab_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).


   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 THEN 9999
                         ELSE tel_cdagenci.
        
   FOR EACH crapchd WHERE crapchd.cdcooper  = glb_cdcooper AND
                          crapchd.dtmvtolt  = tel_dtmvtopg AND
                          crapchd.cdagenci >= tel_cdagenci AND
                          crapchd.cdagenci <= aux_cdagefim AND
                          crapchd.inchqcop  = 0            AND
                          crapchd.flgenvio  = aux_flgenvio AND
                          crapchd.insitprv  = 0            AND
                          CAN-DO(par_cdbccxlt,STRING(crapchd.cdbccxlt)) NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = crapchd.cdagenci 
                  NO-LOCK BREAK BY crawage.cdagenci:

        /* Nao processar registro para opcao "B". Na atualiza_compld foi colocado
          restricao tambem. Para isto sera utilizado a tela PRCCTL  */
        IF  glb_cddopcao = "B"  AND
            crawage.cdbanchq = crapcop.cdbcoctl  THEN
            NEXT.

        IF   crapchd.tpdmovto <> 1   AND
             crapchd.tpdmovto <> 2   THEN
             NEXT.

        IF   NOT CAN-DO("0,2",STRING(crapchd.insitchq))   THEN  
             NEXT.

        IF   CAN-DO("600",STRING(crapchd.cdbccxlt))   THEN       /*  CUSTODIA  */
             DO:
                 ASSIGN tel_qtchdcsg = tel_qtchdcsg + 1
                        tel_vlchdcsg = tel_vlchdcsg + crapchd.vlcheque.

                 IF   crapchd.tpdmovto = 1   THEN       
                      ASSIGN tel_qtchdcss = tel_qtchdcss + 1
                             tel_vlchdcss = tel_vlchdcss + crapchd.vlcheque

                             tel_qtchdtts = tel_qtchdtts + 1
                             tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.
                 ELSE
                 IF   crapchd.tpdmovto = 2   THEN
                      ASSIGN tel_qtchdcsi = tel_qtchdcsi + 1
                             tel_vlchdcsi = tel_vlchdcsi + crapchd.vlcheque

                             tel_qtchdtti = tel_qtchdtti + 1
                             tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.
             END.
        ELSE
        IF   CAN-DO("700",STRING(crapchd.cdbccxlt))   THEN      /*  DESC. CHQ  */
             DO:
                 ASSIGN tel_qtchddcg = tel_qtchddcg + 1
                        tel_vlchddcg = tel_vlchddcg + crapchd.vlcheque.

                 IF   crapchd.tpdmovto = 1   THEN       
                      ASSIGN tel_qtchddcs = tel_qtchddcs + 1
                             tel_vlchddcs = tel_vlchddcs + crapchd.vlcheque

                             tel_qtchdtts = tel_qtchdtts + 1
                             tel_vlchdtts = tel_vlchdtts + crapchd.vlcheque.
                 ELSE
                 IF   crapchd.tpdmovto = 2   THEN
                      ASSIGN tel_qtchddci = tel_qtchddci + 1
                             tel_vlchddci = tel_vlchddci + crapchd.vlcheque

                             tel_qtchdtti = tel_qtchdtti + 1
                             tel_vlchdtti = tel_vlchdtti + crapchd.vlcheque.
             END.

        ASSIGN tel_qtchdttg = tel_qtchdttg + 1
               tel_vlchdttg = tel_vlchdttg + crapchd.vlcheque.

    END.  /*  Fim do FOR EACH  --  Leitura do crapchd  */


    IF   tel_qtchdttg <> (tel_qtchdcsg + tel_qtchddcg)   OR
         tel_vlchdttg <> (tel_vlchdcsg + tel_vlchddcg)   THEN
         DO:
             MESSAGE "ERRO - Informe o CPD ==> Qtd: "
                     STRING(tel_qtchdcsg + tel_qtchddcg,
                            "zzz,zz9-")
                     " Valor: " 
                     STRING(tel_vlchdcsg + tel_vlchddcg,
                            "zzz,zzz,zz9.99-") .
         END.

    IF par_cdbccxlt = "600" THEN
        aux_dscopcao = "CUSTODIA".
    ELSE
        aux_dscopcao = "DESCONTO".


    IF NUM-ENTRIES(par_cdbccxlt) < 2 THEN /* GERAR*/
        DISPLAY aux_dscopcao
                tel_qtchdtti tel_vlchdtti
                tel_qtchdtts tel_vlchdtts
                tel_qtchdttg tel_vlchdttg
                WITH FRAME f_total.
    ELSE /* CONSULTA */
        DISPLAY tel_qtchdcsi tel_vlchdcsi
                tel_qtchdcss tel_vlchdcss
                tel_qtchdcsg tel_vlchdcsg
    
                tel_qtchddci tel_vlchddci
                tel_qtchddcs tel_vlchddcs
                tel_qtchddcg tel_vlchddcg

                tel_qtchdtti tel_vlchdtti
                tel_qtchdtts tel_vlchdtts
                tel_qtchdttg tel_vlchdttg
                WITH FRAME f_total_2.


END PROCEDURE.

/*............................................................................*/

PROCEDURE proc_limpa: /*  Procedure para limpeza da tela  */
    
    HIDE FRAME f_total.
    HIDE FRAME f_total_2.
    HIDE FRAME f_fechamento.
    HIDE FRAME f_refere.
    HIDE FRAME f_refere_v.
    HIDE FRAME f_refere_custod.
    HIDE FRAME f_refere_caixa.
    HIDE FRAME f_movto.
    RETURN.

END PROCEDURE.

/*............................................................................*/

PROCEDURE atualiza_compld:

   DEF INPUT PARAM par_cdbccxlt    AS CHAR           NO-UNDO.

   HIDE MESSAGE NO-PAUSE.

   MESSAGE "Atualizando movtos gerados ...".

   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                         THEN 9999
                         ELSE tel_cdagenci.

   FOR EACH crapchd WHERE crapchd.cdcooper  = glb_cdcooper AND
                          crapchd.dtmvtolt  = tel_dtmvtopg AND
                          crapchd.cdagenci >= tel_cdagenci AND
                          crapchd.cdagenci <= aux_cdagefim AND
                          crapchd.inchqcop  = 0            AND
                          crapchd.flgenvio  = NO           AND
                          crapchd.insitprv  = 0            AND
                          CAN-DO(par_cdbccxlt,STRING(crapchd.cdbccxlt)) NO-LOCK,
       EACH crawage WHERE crawage.cdagenci  = crapchd.cdagenci AND
                          /*Processamento para cecred eh feito pela PRCCTL*/
                          crawage.cdbanchq <> crapcop.cdbcoctl NO-LOCK:
             
       DO WHILE TRUE:
           
           FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crabchd   THEN
                IF   LOCKED crabchd   THEN
                     DO:
                        glb_cdcritic = 77.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           PAUSE(3) NO-MESSAGE.
                           LEAVE.
                        END.
                        NEXT.
                     END.
           
           ASSIGN crabchd.flgenvio = TRUE
                  crabchd.cdbcoenv = crawage.cdbanchq.
           RELEASE crabchd.
           LEAVE.
       END.
   END.  /* fim do FOR EACH */

END PROCEDURE.

/*............................................................................*/

PROCEDURE atualiza_compld_regerar:

   DEF INPUT PARAM par_cdbccxlt    AS CHAR           NO-UNDO.

   HIDE MESSAGE NO-PAUSE.

   MESSAGE "Atualizando movtos gerados ...".

   ASSIGN aux_cdagefim = IF tel_cdagenci = 0 
                         THEN 9999
                         ELSE tel_cdagenci.

  FOR EACH crapchd WHERE crapchd.cdcooper  = glb_cdcooper AND
                         crapchd.dtmvtolt  = tel_dtmvtopg AND
                         crapchd.cdagenci >= tel_cdagenci AND
                         crapchd.cdagenci <= aux_cdagefim AND
                         crapchd.inchqcop  = 0            AND
                         crapchd.flgenvio  = YES          AND
                         crapchd.insitprv  = 0            AND
                         CAN-DO(par_cdbccxlt,STRING(crapchd.cdbccxlt)) NO-LOCK,
      EACH crawage WHERE crawage.cdagenci  = crapchd.cdagenci AND
                         /*Processamento para cecred eh feito pela PRCCTL*/
                         crawage.cdbanchq <> crapcop.cdbcoctl NO-LOCK:
   
       DO WHILE TRUE:
           
           FIND crabchd WHERE RECID(crabchd) = RECID(crapchd) 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

           IF   NOT AVAILABLE crabchd   THEN
                IF   LOCKED crabchd   THEN
                     DO:
                         glb_cdcritic = 77.
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            PAUSE(3) NO-MESSAGE.
                            LEAVE.
                         END.
                         NEXT.
                     END.
           
           ASSIGN crabchd.flgenvio = NO
                  crabchd.cdbcoenv = 0.
           RELEASE crabchd.
           LEAVE.

       END.
   END.  /* fim do FOR EACH */
   
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:
      FOR EACH gncpchq WHERE gncpchq.cdcooper =  glb_cdcooper AND
                             gncpchq.dtmvtolt =  glb_dtmvtolt AND
                             gncpchq.cdtipreg =  1            AND
                             gncpchq.cdagenci >= tel_cdagenci AND
                             gncpchq.cdagenci <= aux_cdagefim 
                             EXCLUSIVE-LOCK:
          DELETE gncpchq.
      END.
   END.   /* TRANSACTION */

   UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
            " - " + STRING(glb_dtmvtolt,"99/99/9999") +
            " - CHEQUES REGERADOS - PAC de " + 
            STRING(tel_cdagenci) + " ate " + STRING(aux_cdagefim) +
            " - Data: " + STRING(tel_dtmvtopg,"99/99/9999") +
            " >> log/compld.log").
   
END PROCEDURE.

/*............................................................................*/

PROCEDURE atualiza_controle_operador.

  FIND craptab WHERE craptab.cdcooper = glb_cdcooper         AND
                     craptab.nmsistem = "CRED"               AND       
                     craptab.tptabela = "GENERI"             AND
                     craptab.cdempres = crapcop.cdcooper     AND       
                     craptab.cdacesso = "COMPLD"             AND
                     craptab.tpregist = 1  
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
  IF  AVAIL craptab THEN      
      DO:
         ASSIGN craptab.dstextab = " ".
         RELEASE craptab.
      END.

END PROCEDURE.

/*............................................................................*/
