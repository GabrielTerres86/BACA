/* .............................................................................

   Programa: Fontes/digita.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Marco/2011                       Ultima alteracao: 23/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela DIGITA para digitalizar cheques antigos em 
               Custodia e Descontos nao digitalizados.

   Alteracoes: 16/04/2012 - Fonte substituido por digitap.p (Tiago)
   
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
                          
               23/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                          
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
      DISP crawage.cdagenci COLUMN-LABEL "PA" 
           crawage.nmresage COLUMN-LABEL "Nome"
           WITH 13 DOWN CENTERED NO-BOX.

DEF BUFFER crabcdb FOR crapcdb.
DEF BUFFER crabcst FOR crapcst.

DEF        VAR tel_nrdhhini AS INT                                   NO-UNDO.
DEF        VAR tel_nrdmmini AS INT                                   NO-UNDO.
DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_dssituac AS CHAR   FORMAT "x(17)"                 NO-UNDO.
DEF        VAR tel_cddsenha AS CHAR   FORMAT "x(10)"                 NO-UNDO.

DEF        VAR tel_situacao AS LOG    FORMAT 
                                       "NAO PROCESSADO/PROCESSADO"   NO-UNDO.

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
DEF        VAR tel_flggerar AS CHAR   FORMAT "x(16)" VIEW-AS COMBO-BOX 
                                      LIST-ITEMS "Custodia Cheques",
                                                 "Desconto Cheques"  NO-UNDO.  

DEF        VAR tel_nrdcaixa AS INT    FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_nrdolote AS INT    FORMAT "zzz,zz9"               NO-UNDO.

DEF        VAR aux_imprimcr AS LOG    FORMAT "Carta/Relatorio"       NO-UNDO.

DEF        VAR aux_cdbcoenv AS CHAR    INIT "0"                      NO-UNDO.
DEF        VAR aux_flggerar AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR aux_dsbcoenv AS CHAR                                  NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR   FORMAT "!(1)"                  NO-UNDO.

DEF        VAR aux_cdagenci AS INT                                   NO-UNDO.
DEF        VAR aux_cdsituac AS INT                                   NO-UNDO.
DEF        VAR aux_qtarquiv AS INT                                   NO-UNDO.
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
DEF        VAR aux_cdbanchq LIKE crapcst.cdbanchq                    NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_cddsenha AS CHAR    FORMAT "x(8)"                 NO-UNDO.
DEF        VAR aux_nrdcaixa AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_nrdolote AS INT     FORMAT "zzz,zz9"               NO-UNDO.
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
DEF        VAR aux_dtliber1 AS DATE                                  NO-UNDO.
DEF        VAR aux_dtliber2 AS DATE                                  NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

DEF VAR h-b1wgen0012 AS HANDLE                                       NO-UNDO.

DEF        TEMP-TABLE crattem                                        NO-UNDO
           FIELD cdseqarq AS INTEGER
           FIELD nrrecchd AS RECID
           INDEX crattem1 cdseqarq.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 3 LABEL "Opcao" AUTO-RETURN
               HELP "Informe a opcao desejada (B, C ou X)."
               VALIDATE(CAN-DO("B,C,X",glb_cddopcao),
                               "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_digita.

FORM tel_dtmvtopg AT  2 LABEL "Dt. Liberacao"
                        HELP "Entre com a Data de Liberacao do movimento."
     tel_cdagenci AT 28 LABEL "PA"
                        HELP 
                          "Entre com o numero do PA ou 0 para todos os PA's."
     tel_flggerar AT 36 LABEL "  Produto"
                        HELP "Selecione o produto."
     SKIP
     WITH ROW 6 COLUMN 13 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

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

IF   NOT AVAILABLE crawage THEN
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
      PAUSE(0).
      
      UPDATE glb_cddopcao  WITH FRAME f_digita.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF   CAPS(glb_nmdatela) <> "DIGITA"  THEN
                 DO:
                     RUN proc_limpa.
                     HIDE FRAME f_digita.
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
       
    WHEN "B" THEN 
         DO:
             RUN proc_limpa.
        
             ASSIGN tel_dtmvtopg = glb_dtmvtolt
                    tel_cdagenci = 0.

             UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_refere.
             UPDATE tel_flggerar WITH FRAME f_refere.

             /*  Nao deixa gerar arquivo no dia 31/12 - NAO TEM COMPE  */
        
             IF   tel_cdagenci = 0      AND
                  crapcop.cdcooper = 2  THEN
                  DO:
                      glb_cdcritic = 15.
                      NEXT.
                  END.
             
             
             IF   MONTH(tel_dtmvtopg) = 12   AND
                  DAY(tel_dtmvtopg)   = 31   THEN
                  DO:
                      glb_cdcritic = 13.
                      NEXT.
                  END.

             ASSIGN aux_dtliber1 = tel_dtmvtopg
                    aux_dtliber2 = tel_dtmvtopg.
          
             DO WHILE TRUE:   
   
                ASSIGN aux_dtliber1 = aux_dtliber1 - 1.
      
                IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber1)))  OR
                     CAN-FIND(crapfer WHERE 
                              crapfer.cdcooper = crapcop.cdcooper AND
                              crapfer.dtferiad = aux_dtliber1)    THEN
                              NEXT.
                                          
                LEAVE.
             END.
             
             ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                                        9999
                                   ELSE tel_cdagenci.
                 
             ASSIGN aux_cdsituac = 0
                    aux_cdagenci = 0
                    glb_cdcritic = 0
                    tel_nrdcaixa = 0
                    tel_nrdolote = 0.
               
             FOR EACH crapage WHERE crapage.cdcooper  = glb_cdcooper AND
                                    crapage.cdagenci >= tel_cdagenci AND
                                    crapage.cdagenci <= aux_cdagefim NO-LOCK:
        
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

                 IF   aux_flggerar = "Custodia Cheques" THEN
                      DO:
                          /* verifica se ja teve algum gerado */
                          FIND FIRST crapcst WHERE 
                                     crapcst.cdcooper =  glb_cdcooper     AND
                                     crapcst.dtlibera >  aux_dtliber1     AND
                                     crapcst.dtlibera <= aux_dtliber2     AND
                                     crapcst.cdagenci =  crapage.cdagenci AND
                                     crapcst.insitprv =  1                AND
                                    (crapcst.insitchq =  0                OR
                                     crapcst.insitchq =  2)
                                     NO-LOCK NO-ERROR.

                          IF   aux_cdsituac = 0 THEN 
                               DO:
                                   IF  AVAILABLE crapcst THEN
                                       ASSIGN aux_cdsituac =
                                            INT(SUBSTR(craptab.dstextab,1,1)).
                               END.
                      END.
                 ELSE
                      DO:
                          /* verifica se ja teve algum gerado */
                          FIND FIRST crapcdb WHERE 
                                     crapcdb.cdcooper =  glb_cdcooper     AND
                                     crapcdb.dtlibera >  aux_dtliber1     AND
                                     crapcdb.dtlibera <= aux_dtliber2     AND
                                     crapcdb.cdagenci =  crapage.cdagenci AND
                                     crapcdb.insitprv =  1                AND
                                     crapcdb.dtlibbdc <> ?                AND
                                    (crapcdb.insitchq =  0                OR
                                     crapcdb.insitchq =  2)
                                     NO-LOCK NO-ERROR.

                          IF   aux_cdsituac = 0 THEN 
                               DO:
                                   IF   AVAILABLE crapcdb THEN
                                        ASSIGN aux_cdsituac =
                                          INT(SUBSTR(craptab.dstextab,1,1)).
                               END.
                      END.
        
             END.  /* For each crapage */
        
             RUN proc_digita(INPUT aux_flggerar, 
                             INPUT FALSE).

             IF   glb_cdcritic <> 0 THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      MESSAGE "AGENCIA = "  aux_cdagenci.                 
                      NEXT.
                 END.

             ASSIGN aux_confirma = "S".

             IF   tel_qtchdttg = 0   THEN
                  DO:
                      BELL.
                      MESSAGE "Nao ha dados para gerar.".
                      PAUSE 2 NO-MESSAGE.
                      glb_cdcritic = 0.
                      RUN proc_limpa.
                      NEXT.
                  END.

             IF   aux_cdsituac <> 0   THEN
                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                     aux_confirma = "N".
                     BELL.
                     MESSAGE COLOR NORMAL 
                            "Ja houve arquivos gravados."
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

             FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                      NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapcop  THEN
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


             /* Instancia a BO 12 */
             RUN sistema/generico/procedures/b1wgen0012.p 
                 PERSISTENT SET h-b1wgen0012.

             IF   NOT VALID-HANDLE(h-b1wgen0012)  THEN
                  DO:
                      glb_nmdatela = "DIGITA".
                      BELL.
                      MESSAGE "Handle invalido para BO b1wgen0012.".
                 
                      IF   glb_conta_script = 0 THEN
                           PAUSE 3 NO-MESSAGE.
                      
                      RETURN.
                  END.

             IF   aux_flggerar = "Custodia Cheques" THEN
                  ASSIGN aux_nmdatela = "DIGITA_CST".
             ELSE
                  ASSIGN aux_nmdatela = "DIGITA_DSC".

             RUN gerar_arquivos_cecred
                    IN h-b1wgen0012(INPUT "DIGITA",
                                    INPUT tel_dtmvtopg,
                                    INPUT glb_cdcooper,
                                    INPUT tel_cdagenci,
                                    INPUT aux_cdagefim,
                                    INPUT glb_cdoperad,
                                    INPUT aux_nmdatela,
                                    INPUT 0,
                                    INPUT 0,
                                    INPUT 0,
                                    OUTPUT glb_cdcritic,
                                    OUTPUT aux_qtarquiv,
                                    OUTPUT aux_totregis,
                                    OUTPUT aux_vlrtotal).

             DELETE PROCEDURE h-b1wgen0012.

             IF   glb_cdcritic > 0  THEN
                  NEXT.

             HIDE MESSAGE NO-PAUSE.

             RUN atualiza_digita(aux_flggerar).

             MESSAGE "Movtos atualizados         ".

             ASSIGN tot_qtarquiv = aux_qtarquiv
                    tot_vlcheque = aux_vlrtotal.

             MESSAGE "Foi(ram) gravado(s) " STRING(tot_qtarquiv, "zzz9") +
                     " arquivo(s) - com o valor total: " + 
                     STRING(tot_vlcheque, "zzz,zzz,zz9.99").

             PAUSE(3) NO-MESSAGE.

         END. /* END do WHEN "B" THEN DO */


    WHEN "X" THEN 
         DO:
             RUN proc_limpa.

             ASSIGN tel_dtmvtopg = glb_dtmvtolt
                    tel_cdagenci = 0.

             UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_refere.
             UPDATE tel_flggerar WITH FRAME f_refere.

             IF   tel_cdagenci = 0      AND
                  crapcop.cdcooper = 2  THEN
                  DO:
                      glb_cdcritic = 15.
                      NEXT.
                  END.
             
             /*  Nao deixa gerar arquivo no dia 31/12 - NAO TEM COMPE  */

             IF   MONTH(tel_dtmvtopg) = 12   AND
                  DAY(tel_dtmvtopg)   = 31   THEN
                  DO:
                      glb_cdcritic = 13.
                      NEXT.
                  END.

             IF   tel_dtmvtopg = glb_dtmvtopr  THEN
                  DO:
                      glb_cdcritic = 13.
                      NEXT.
                  END.
             ELSE
                  DO:
                      ASSIGN aux_dtliber1 = tel_dtmvtopg
                             aux_dtliber2 = tel_dtmvtopg.
          
                      DO WHILE TRUE:   
   
                         ASSIGN aux_dtliber1 = aux_dtliber1 - 1.
      
                         IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber1)))  OR
                              CAN-FIND(crapfer WHERE 
                                       crapfer.cdcooper = crapcop.cdcooper AND
                                       crapfer.dtferiad = aux_dtliber1)    THEN
                              NEXT.
                                               
                         LEAVE.
                      END.
                  END.

             
             ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                                        9999
                                   ELSE tel_cdagenci.

             ASSIGN aux_cdsituac = 0
                    aux_cdagenci = 0
                    glb_cdcritic = 0
                    tel_nrdcaixa = 0
                    tel_nrdolote = 0.

             RUN proc_digita(INPUT aux_flggerar,
                             INPUT TRUE).

             IF   glb_cdcritic <> 0 THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      MESSAGE "AGENCIA = "  aux_cdagenci.                 
                      NEXT.
                  END.

             ASSIGN aux_confirma = "S".

             IF   tel_qtchdttg = 0   THEN
                  DO:
                      BELL.
                      MESSAGE "Nao ha dados para regerar.".
                      PAUSE 2 NO-MESSAGE.
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

             FIND FIRST crapcop WHERE crapcop.cdcooper = glb_cdcooper
                                      NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapcop  THEN
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

             HIDE MESSAGE NO-PAUSE.

             RUN atualiza_digita_regerar(aux_flggerar).

             MESSAGE "Movtos atualizados         ".

             PAUSE 2 NO-MESSAGE.

         END. /* END do WHEN "X" THEN DO */



    WHEN "C" THEN 
         DO:
             RUN proc_limpa.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                IF   glb_cdcritic > 0   THEN
                     DO:
                         RUN fontes/critic.p.
                         BELL.
                         MESSAGE glb_dscritic.
                         glb_cdcritic = 0.
                         PAUSE 2 NO-MESSAGE.
                     END.
                
                UPDATE tel_dtmvtopg tel_cdagenci WITH FRAME f_refere.
                UPDATE tel_flggerar WITH FRAME f_refere.

                IF   tel_cdagenci = 0      AND
                     crapcop.cdcooper = 2  THEN
                     DO:
                         glb_cdcritic = 15.
                         NEXT.
                     END.
                
                IF   tel_dtmvtopg = glb_dtmvtopr  THEN
                     DO:
                         glb_cdcritic = 13.
                         NEXT.
                     END.
                ELSE
                     DO:
                         ASSIGN aux_dtliber1 = tel_dtmvtopg
                                aux_dtliber2 = tel_dtmvtopg.
          
                         DO WHILE TRUE:   
   
                            ASSIGN aux_dtliber1 = aux_dtliber1 - 1.
      
                            IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtliber1)))  OR
                                 CAN-FIND(crapfer WHERE 
                                       crapfer.cdcooper = crapcop.cdcooper AND
                                       crapfer.dtferiad = aux_dtliber1)    THEN
                                 NEXT.
                                               
                            LEAVE.
                         END.
                     END.

                RUN proc_digita(INPUT aux_flggerar,
                                INPUT FALSE).
        
             END. /*  Fim do DO WHILE TRUE  */

         END. /* END do WHEN "C" THEN DO */

   END CASE.
    
END.  /*  Fim do DO WHILE TRUE  */


/*  ........................................................................  */

PROCEDURE proc_digita:

    DEF INPUT PARAM par_flggerar    AS CHAR           NO-UNDO.
    DEF INPUT PARAM par_flgreger    AS LOGICAL        NO-UNDO.
    
    DEF VAR tab_vlchqmai            AS DECI           NO-UNDO.
    DEF VAR aux_insitprv            AS INTE           NO-UNDO.
    
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

    IF   par_flgreger  THEN
         aux_insitprv = 1.
    ELSE
         aux_insitprv = 0.
    
    FIND FIRST craptab WHERE craptab.cdcooper = crapcop.cdcooper    AND
                             craptab.nmsistem = "CRED"              AND
                             craptab.tptabela = "USUARI"            AND
                             craptab.cdempres = 11                  AND
                             craptab.cdacesso = "MAIORESCHQ"        AND
                             craptab.tpregist = 1
                             NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN tab_vlchqmai = 1.
    ELSE
         ASSIGN tab_vlchqmai  = DEC(SUBSTR(craptab.dstextab,1,15)).
    
    
    ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                               9999
                          ELSE tel_cdagenci.
    
    IF   par_flggerar = "Custodia Cheques" THEN
         DO:
             FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper AND
                                    crapcst.dtlibera  > aux_dtliber1 AND
                                    crapcst.dtlibera <= aux_dtliber2 AND
                                    crapcst.cdagenci >= tel_cdagenci AND
                                    crapcst.cdagenci <= aux_cdagefim AND
                                    crapcst.insitprv  = aux_insitprv AND
                                   (crapcst.insitchq  = 0            OR
                                    crapcst.insitchq  = 2)
                                    NO-LOCK:

                 ASSIGN tel_qtchdcsg = tel_qtchdcsg + 1
                        tel_vlchdcsg = tel_vlchdcsg + crapcst.vlcheque.
              
                 IF   crapcst.vlcheque >= tab_vlchqmai  THEN
                      ASSIGN tel_qtchdcss = tel_qtchdcss + 1
                             tel_vlchdcss = tel_vlchdcss + crapcst.vlcheque
    
                             tel_qtchdtts = tel_qtchdtts + 1
                             tel_vlchdtts = tel_vlchdtts + crapcst.vlcheque.
                 ELSE
                      ASSIGN tel_qtchdcsi = tel_qtchdcsi + 1
                             tel_vlchdcsi = tel_vlchdcsi + crapcst.vlcheque
    
                             tel_qtchdtti = tel_qtchdtti + 1
                             tel_vlchdtti = tel_vlchdtti + crapcst.vlcheque.
             
                 ASSIGN tel_qtchdttg = tel_qtchdttg + 1
                        tel_vlchdttg = tel_vlchdttg + crapcst.vlcheque.
    
             END.  /*  Fim do FOR EACH  --  Leitura do crapcst  */
         END.
    ELSE
         DO:
             FOR EACH crapcdb WHERE crapcdb.cdcooper  = glb_cdcooper AND
                                    crapcdb.dtlibera  > aux_dtliber1 AND
                                    crapcdb.dtlibera <= aux_dtliber2 AND
                                    crapcdb.cdagenci >= tel_cdagenci AND
                                    crapcdb.cdagenci <= aux_cdagefim AND
                                    crapcdb.insitprv  = aux_insitprv AND
                                    crapcdb.dtlibbdc <> ?            AND
                                   (crapcdb.insitchq  = 0            OR
                                    crapcdb.insitchq  = 2)
                                    NO-LOCK:

                 ASSIGN tel_qtchddcg = tel_qtchddcg + 1
                        tel_vlchddcg = tel_vlchddcg + crapcdb.vlcheque.

                 IF   crapcdb.vlcheque >= tab_vlchqmai  THEN
                      ASSIGN tel_qtchddcs = tel_qtchddcs + 1
                             tel_vlchddcs = tel_vlchddcs + crapcdb.vlcheque
                             tel_qtchdtts = tel_qtchdtts + 1
                             tel_vlchdtts = tel_vlchdtts + crapcdb.vlcheque.
                 ELSE
                      ASSIGN tel_qtchddci = tel_qtchddci + 1
                             tel_vlchddci = tel_vlchddci + crapcdb.vlcheque
                             tel_qtchdtti = tel_qtchdtti + 1
                             tel_vlchdtti = tel_vlchdtti + crapcdb.vlcheque.

                 ASSIGN tel_qtchdttg = tel_qtchdttg + 1
                        tel_vlchdttg = tel_vlchdttg + crapcdb.vlcheque.

             END.  /*  Fim do FOR EACH  --  Leitura do crapcdb  */
         END.

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

    IF   aux_flggerar = "Custodia Cheques" THEN
         aux_dscopcao = "CUSTODIA".
    ELSE
         aux_dscopcao = "DESCONTO".

    IF   glb_cddopcao = "C" THEN /* CONSULTA */
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
    ELSE /* GERAR - REGERAR */
         DISPLAY aux_dscopcao
                 tel_qtchdtti tel_vlchdtti
                 tel_qtchdtts tel_vlchdtts
                 tel_qtchdttg tel_vlchdttg
                 WITH FRAME f_total.

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc_limpa: /*  Procedure para limpeza da tela  */
    
    HIDE FRAME f_total.
    HIDE FRAME f_total_2.
    HIDE FRAME f_fechamento.
    HIDE FRAME f_refere.
    HIDE FRAME f_movto.
    RETURN.

END PROCEDURE.

/*............................................................................*/

PROCEDURE atualiza_digita:

    DEF INPUT PARAM par_flggerar    AS CHAR        NO-UNDO.
    
    HIDE MESSAGE NO-PAUSE.
    
    MESSAGE "Atualizando movtos gerados ...".
    
    ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                               9999
                          ELSE tel_cdagenci.
    
    IF   par_flggerar = "Custodia Cheques" THEN
         DO:
             FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper AND
                                    crapcst.dtlibera  > aux_dtliber1 AND
                                    crapcst.dtlibera <= aux_dtliber2 AND
                                    crapcst.cdagenci >= tel_cdagenci AND
                                    crapcst.cdagenci <= aux_cdagefim AND
                                    crapcst.insitprv  = 0            AND
                                   (crapcst.insitchq  = 0            OR
                                    crapcst.insitchq  = 2)
                                    NO-LOCK:
    
                 DO WHILE TRUE:
    
                    FIND crabcst WHERE RECID(crabcst) = RECID(crapcst) 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF   NOT AVAILABLE crabcst   THEN
                         IF   LOCKED crabcst   THEN
                              DO:
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crabcst),
                                    					 INPUT "banco",
                                    					 INPUT "crabcst",
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
                                    
                                    glb_cdcritic = 0.
                                 
                                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     PAUSE(3) NO-MESSAGE.
                                     LEAVE.
                                  END.
                                  NEXT.
                              END.
    
                    ASSIGN crabcst.insitprv = 1
                           crabcst.dtprevia = glb_dtmvtolt.
            
                    RELEASE crabcst.
                    LEAVE.
                 END.
             END.  /* fim do FOR EACH */
         END.
    ELSE
         DO:
             FOR EACH crapcdb WHERE crapcdb.cdcooper  = glb_cdcooper AND
                                    crapcdb.dtlibera  > aux_dtliber1 AND
                                    crapcdb.dtlibera <= aux_dtliber2 AND
                                    crapcdb.cdagenci >= tel_cdagenci AND
                                    crapcdb.cdagenci <= aux_cdagefim AND
                                    crapcdb.insitprv  = 0            AND
                                    crapcdb.dtlibbdc <> ?            AND
                                   (crapcdb.insitchq  = 0            OR
                                    crapcdb.insitchq  = 2)
                                    NO-LOCK:
    
                 DO WHILE TRUE:
    
                     FIND crabcdb WHERE RECID(crabcdb) = RECID(crapcdb) 
                                        EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                     IF   NOT AVAILABLE crabcdb   THEN
                          IF   LOCKED crabcdb   THEN
                               DO:
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crabcdb),
                                    					 INPUT "banco",
                                    					 INPUT "crabcdb",
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
                                    
                                    glb_cdcritic = 0.
                        
                                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                      PAUSE(3) NO-MESSAGE.
                                      LEAVE.
                                   END.
                          
                                   NEXT.
                               END.
    
                     ASSIGN crabcdb.insitprv = 1
                            crabcdb.dtprevia = glb_dtmvtolt.
                     RELEASE crabcdb.
                     LEAVE.
                 END.
             END.  /* fim do FOR EACH */
         END.
    
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " Operador: " + glb_cdoperad +
                      " - CHEQUES GERADOS -  PA de " + 
                      STRING(tel_cdagenci) + " ate " + STRING(aux_cdagefim) +
                      " - Data: " + STRING(tel_dtmvtopg,"99/99/9999") +
                      " >> log/digita.log").

END PROCEDURE.

/*............................................................................*/

PROCEDURE atualiza_digita_regerar:

    DEF INPUT PARAM par_flggerar    AS CHAR        NO-UNDO.
    
    HIDE MESSAGE NO-PAUSE.
    
    MESSAGE "Atualizando movtos gerados ...".
    
    ASSIGN aux_cdagefim = IF   tel_cdagenci = 0 THEN 
                               9999
                          ELSE tel_cdagenci.
    
    IF   par_flggerar = "Custodia Cheques" THEN
         DO:
             FOR EACH crapcst WHERE crapcst.cdcooper  = glb_cdcooper AND
                                    crapcst.dtlibera  > aux_dtliber1 AND
                                    crapcst.dtlibera <= aux_dtliber2 AND
                                    crapcst.cdagenci >= tel_cdagenci AND
                                    crapcst.cdagenci <= aux_cdagefim AND
                                    crapcst.insitprv  = 1            AND
                                   (crapcst.insitchq  = 0            OR
                                    crapcst.insitchq  = 2)
                                    NO-LOCK:
    
                 DO WHILE TRUE:
    
                    FIND crabcst WHERE RECID(crabcst) = RECID(crapcst) 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF   NOT AVAILABLE crabcst   THEN
                         IF   LOCKED crabcst   THEN
                              DO:
                                  
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crabcst),
                                    					 INPUT "banco",
                                    					 INPUT "crabcst",
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
                                    
                                    glb_cdcritic = 0.
                           
                                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     PAUSE(3) NO-MESSAGE.
                                     LEAVE.
                                  END.
                               
                                  NEXT.
                              END.
    
                    ASSIGN crabcst.insitprv = 0
                           crabcst.dtprevia = ?.
                    RELEASE crabcst.
                    LEAVE.
    
                 END.
             END.  /* fim do FOR EACH */
         END.
    ELSE
         DO:
             FOR EACH crapcdb WHERE crapcdb.cdcooper  = glb_cdcooper AND
                                    crapcdb.dtlibera  > aux_dtliber1 AND
                                    crapcdb.dtlibera <= aux_dtliber2 AND
                                    crapcdb.cdagenci >= tel_cdagenci AND
                                    crapcdb.cdagenci <= aux_cdagefim AND
                                    crapcdb.insitprv  = 1            AND
                                    crapcdb.dtlibbdc <> ?            AND
                                   (crapcdb.insitchq  = 0            OR
                                    crapcdb.insitchq  = 2)
                                    NO-LOCK:
    
                 DO WHILE TRUE:
    
                    FIND crabcdb WHERE RECID(crabcdb) = RECID(crapcdb) 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                    IF   NOT AVAILABLE crabcdb   THEN
                         IF   LOCKED crabcdb   THEN
                              DO:
                                  
                                    RUN sistema/generico/procedures/b1wgen9999.p
                                    PERSISTENT SET h-b1wgen9999.
                                    
                                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crabcdb),
                                    					 INPUT "banco",
                                    					 INPUT "crabcdb",
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
                                    
                                    glb_cdcritic = 0.
                              
                                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     PAUSE(3) NO-MESSAGE.
                                     LEAVE.
                                  END.
                               
                                  NEXT.
                              END.
    
                    ASSIGN crabcdb.insitprv = 0
                           crabcdb.dtprevia = ?.
                    RELEASE crabcdb.
                    LEAVE.
    
                 END.
             END.  /* fim do FOR EACH */
         END.
    
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " Operador: " + glb_cdoperad +
                      " - CHEQUES REGERADOS -  PA de " + 
                      STRING(tel_cdagenci) + " ate " + STRING(aux_cdagefim) +
                      " - Data: " + STRING(tel_dtmvtopg,"99/99/9999") +
                      " >> log/digita.log").
   
END PROCEDURE.

/*............................................................................*/

