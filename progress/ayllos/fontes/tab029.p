/* .............................................................................

   Programa: Fontes/tab029.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Abril/2004                         Ultima Atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela TAB029 - Parametros Cartao de Credito
   
   Alteracoes: 07/06/2004 - Sempre que incluir um novo registro, sera com o 
                            tpregist = 1 e altera as tabelas antigas 
                            sendo tpregist = tpregist + 1. (Julio)

               05/07/2005 - Alterado campo cdcooper da tabela craptab (Diego).
   
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               06/02/2006 - Inclusao de NO-UNDO nas temp-tables - SQLWorks -
                            Eder
               
               17/07/2006 - Alteracao do rotulo do campo Valor da Anuidade -                                Elton.
               
               19/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)

                            
............................................................................. */

{ includes/var_online.i } 

DEFINE TEMP-TABLE crawand                                            NO-UNDO
       FIELD  nmresadm  LIKE crapadc.nmresadm
       FIELD  nrsequen  AS  INT   FORMAT "zz9"
       FIELD  cdadmcrd  AS  INT   FORMAT "zz9"
       FIELD  qtparcan  AS  INT   FORMAT "z9"
       FIELD  vlanuida  AS  DECI  FORMAT "zzz,zz9.99"
       FIELD  dtrefere  AS  DATE  FORMAT "99/99/9999".

DEF        VAR tel_cdadmcrd AS INTEGER FORMAT "99"                   NO-UNDO.
DEF        VAR tel_cdtabela AS INTEGER FORMAT "99"                   NO-UNDO.
DEF        VAR tel_qtparcan AS INTEGER FORMAT "99"                   NO-UNDO.
DEF        VAR tel_vlanuida AS DECIMAL FORMAT "999999.99"            NO-UNDO.
DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_tpanuida AS LOGICAL FORMAT "ENTREGA/RENOVACAO"    NO-UNDO. 

DEF        VAR aux_cdacesso AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsacesso AS CHAR    FORMAT "x(50)"                NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)" INIT "N"        NO-UNDO.

DEF        VAR aux_dadosusr AS CHAR                                  NO-UNDO.
DEF        VAR par_loginusr AS CHAR                                  NO-UNDO.
DEF        VAR par_nmusuari AS CHAR                                  NO-UNDO.
DEF        VAR par_dsdevice AS CHAR                                  NO-UNDO.
DEF        VAR par_dtconnec AS CHAR                                  NO-UNDO.
DEF        VAR par_numipusr AS CHAR                                  NO-UNDO.
DEF        VAR h-b1wgen9999 AS HANDLE                                NO-UNDO.

DEF        QUERY qry_anuidade FOR crawand.

DEF        BROWSE brw_anuidade QUERY qry_anuidade
           DISP crawand.cdadmcrd COLUMN-LABEL "Cod."        FORMAT "zz9"
           crawand.nmresadm COLUMN-LABEL "Administradora"                    
           crawand.nrsequen COLUMN-LABEL "Seq"              FORMAT "zz9"
           crawand.qtparcan COLUMN-LABEL "Qtd.Parcelas"     FORMAT "z9"
           crawand.vlanuida COLUMN-LABEL "Vlr Parc. Anuid." FORMAT "zzz,zz9.99"
           crawand.dtrefere COLUMN-LABEL "Data Referencia"  FORMAT "99/99/9999"
           WITH 8 DOWN CENTERED NO-BOX.


FORM SKIP (2)
     "Opcao:"     AT 4
     glb_cddopcao AT 11 NO-LABEL AUTO-RETURN
                  HELP "Entre com a opcao desejada C, A, I, E"
                  VALIDATE (glb_cddopcao = "A" OR glb_cddopcao = "C" OR
                            glb_cddopcao = "I" OR glb_cddopcao = "E",
                            "014 - Opcao errada.")
     tel_tpanuida AT 20 LABEL "Tipo de Anuidade" AUTO-RETURN
             HELP 'Informe o tipo de anuidade que deseja configurar "E" ou "R"'
     WITH SIDE-LABELS
     TITLE COLOR MESSAGE "Parametros para cartao de credito"
           ROW 4 COLUMN 1 OVERLAY SIZE 80 BY 18 FRAME f_opcao029.

FORM tel_cdadmcrd AT 18 LABEL "Codigo da Administradora" AUTO-RETURN
                  HELP "Informe o codigo da administradora de cartoes."
     SKIP(1)
     tel_qtparcan AT 15 LABEL "Qtd. Parcelas para Anuidade" AUTO-RETURN
          HELP "Informe a quantidade de parcelas para o pagamento da anuidade."
     SKIP(1)
     tel_vlanuida AT 12 LABEL "Valor da Parcela para Anuidade" AUTO-RETURN
                        HELP "Informe o valor da parcela para anuidade."
     SKIP(1)
     tel_dtmvtolt AT 27 LABEL "Data Referencia" AUTO-RETURN
                        HELP "Informe a data de referencia"
     SKIP(3)
     WITH SIDE-LABELS ROW 9 COLUMN 2 OVERLAY NO-BOX WIDTH 76 FRAME f_tab029.

FORM brw_anuidade  
     WITH NO-LABEL NO-BOX COLUMN 3 OVERLAY ROW 9 SIZE 76 BY 12 
          FRAME f_browse029.

PROCEDURE p_MudaSeq:
 
  DEF INPUT PARAMETER par_cdadmcrd AS INTEGER   NO-UNDO.

  FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                         craptab.nmsistem = "CRED"         AND
                         craptab.tptabela = "USUARI"       AND
                         craptab.cdempres = 11             AND
                         craptab.cdacesso = aux_cdacesso + 
                                            STRING(par_cdadmcrd, "9")
                         EXCLUSIVE-LOCK
                         BY craptab.tpregist DESCENDING:

      ASSIGN craptab.tpregist = craptab.tpregist + 1.
           
  END.

END.

ON ENTRY, VALUE-CHANGED OF brw_anuidade DO:
   IF   glb_cddopcao = "E"   THEN
        MESSAGE "Pressione <ENTER> para excluir o registro!".
   ELSE
   IF   glb_cddopcao = "A"   THEN
        MESSAGE "Pressione <ENTER> para alterar o registro!".
END.

ON RETURN OF brw_anuidade DO:
       
   DO TRANSACTION ON ENDKEY UNDO, LEAVE:

      IF   CAN-DO("A,E", glb_cddopcao)   THEN
           DO:
               DO  aux_contador = 1 TO 10:

                   FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                      craptab.nmsistem = "CRED"        AND
                                      craptab.tptabela = "USUARI"      AND
                                      craptab.cdempres = 11            AND
                                      craptab.cdacesso = aux_cdacesso + 
                                         STRING(crawand.cdadmcrd, "9") AND
                                      craptab.tpregist = crawand.nrsequen
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                   IF   NOT AVAILABLE craptab   THEN
                        IF   LOCKED craptab   THEN
                             DO:
                                  RUN sistema/generico/procedures/b1wgen9999.p
                                  PERSISTENT SET h-b1wgen9999.
    
                                  RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                                                                 INPUT "banco",
                                                                 INPUT "craptab",
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
                                                                
                                    NEXT.
                             END.
                        ELSE
                             DO:
                                 glb_cdcritic = 55.
                                 CLEAR FRAME f_tab029.
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
           END.
           
      IF   glb_cddopcao = "E"   THEN
           DO:
               ASSIGN tel_qtparcan = INT(SUBSTR(craptab.dstextab, 1, 2))
                      tel_vlanuida = DECIMAL(SUBSTR(craptab.dstextab,4,9))
                      tel_dtmvtolt = DATE(INT(SUBSTR(craptab.dstextab,17,2)),
                                     INT(SUBSTR(craptab.dstextab,14,2)),
                                     INT(SUBSTR(craptab.dstextab,20,4))).
                          
               MESSAGE "Deseja realmente excluir este registro ? (S/N):"
               UPDATE aux_confirma.
                             
               IF   CAPS(aux_confirma) = "S"   THEN
                    DELETE craptab.
                        
               HIDE MESSAGE.
           END.
      ELSE
      IF   glb_cddopcao = "A"   THEN   
           DO:
               HIDE MESSAGE.
               ASSIGN tel_cdadmcrd = crawand.cdadmcrd
                      tel_qtparcan = INT(SUBSTR(craptab.dstextab, 1, 2))
                      tel_vlanuida = DECIMAL(SUBSTR(craptab.dstextab,4,9))
                      tel_dtmvtolt = DATE(INT(SUBSTR(craptab.dstextab,17,2)),
                                          INT(SUBSTR(craptab.dstextab,14,2)),
                                          INT(SUBSTR(craptab.dstextab,20,4))).
                      
               DISPLAY tel_cdadmcrd tel_qtparcan tel_vlanuida tel_dtmvtolt 
                       WITH FRAME f_tab029.
            
               SET tel_qtparcan tel_vlanuida tel_dtmvtolt WITH FRAME f_tab029.

               ASSIGN craptab.dstextab = STRING(tel_qtparcan, "99") + " " +
                                      STRING(tel_vlanuida, "999999.99") + " " +
                                      STRING(tel_dtmvtolt, "99/99/9999").

               CLEAR FRAME f_tab029 NO-PAUSE.
           
           END.
           
   END. /* Fim da transacao */

   RELEASE craptab.

   RUN p_carregabrowse(INPUT aux_cdacesso).
END.

glb_cddopcao = "C".
tel_tpanuida = TRUE.

DO WHILE TRUE:

        RUN fontes/inicia.p.

        DISPLAY glb_cddopcao tel_tpanuida WITH FRAME f_opcao029.

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
           PROMPT-FOR glb_cddopcao WITH FRAME f_opcao029.
           LEAVE.
        END.

        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
             DO:
                 RUN fontes/novatela.p.
                 IF   CAPS(glb_nmdatela) <> "TAB029"   THEN
                      DO:
                          HIDE FRAME f_opcao029.
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
      
        ASSIGN glb_cddopcao = INPUT glb_cddopcao.

        SET tel_tpanuida WITH frame f_opcao029.
        
        IF   INPUT tel_tpanuida   THEN
             aux_cdacesso = "ENTRGCART".
        ELSE
             aux_cdacesso = "ANUIDCART".

        IF   INPUT glb_cddopcao = "A" THEN
             DO:
                 RUN p_carregabrowse(INPUT aux_cdacesso).
                 SET brw_anuidade WITH FRAME f_browse029. 
             END.
        ELSE
        IF   INPUT glb_cddopcao = "C" THEN
             DO:
                 RUN p_carregabrowse(INPUT aux_cdacesso).
                 SET brw_anuidade WITH FRAME f_browse029.
             END.
        ELSE
        IF   INPUT glb_cddopcao = "I" THEN
             DO:

                 SET tel_cdadmcrd WITH FRAME f_tab029.
                 
                 DO WHILE NOT CAN-FIND(crapadc 
                                WHERE crapadc.cdcooper = glb_cdcooper AND
                                      crapadc.cdadmcrd = tel_cdadmcrd NO-LOCK):

                    glb_cdcritic = 605.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                          
                    SET tel_cdadmcrd WITH FRAME f_tab029.
                 END.                                    

                 HIDE MESSAGE.
                 
                 RUN p_MudaSeq(tel_cdadmcrd).
                 
                 DO TRANSACTION ON ENDKEY UNDO, LEAVE:

                    FIND craptab WHERE craptab.cdcooper = glb_cdcooper   AND
                                       craptab.nmsistem = "CRED"         AND
                                       craptab.tptabela = "USUARI"       AND
                                       craptab.cdempres = 11             AND
                                       craptab.cdacesso = aux_cdacesso +
                                              STRING(tel_cdadmcrd, "9")  AND
                                       craptab.tpregist = 1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    glb_cdcritic = 0.
                    
                    IF   AVAILABLE craptab   OR   LOCKED craptab  THEN
                         glb_cdcritic = 56.

                    IF   glb_cdcritic <> 0   THEN
                         DO:
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             PAUSE NO-MESSAGE.
                             NEXT.                         
                         END.

                   SET tel_qtparcan tel_vlanuida tel_dtmvtolt 
                           WITH FRAME f_tab029.

                   CREATE craptab.
                   
                   ASSIGN craptab.nmsistem = "CRED"         
                          craptab.tptabela = "USUARI"       
                          craptab.cdempres = 11             
                          craptab.cdacesso = aux_cdacesso + 
                                             STRING(tel_cdadmcrd, "9")  
                          craptab.tpregist = 1
                          craptab.dstextab = 
                                      STRING(tel_qtparcan, "99") + " " +
                                      STRING(tel_vlanuida, "999999.99") + " " +
                                      STRING(tel_dtmvtolt, "99/99/9999")
                          craptab.cdcooper = glb_cdcooper.
                 END. /* Fim da transacao */

                 RELEASE craptab.

                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                      NEXT.

                 CLEAR FRAME f_tab029 NO-PAUSE.

             END.
        ELSE
        IF   INPUT glb_cddopcao = "E" THEN
             DO:               
                 RUN p_carregabrowse(INPUT aux_cdacesso).
                 SET brw_anuidade WITH FRAME f_browse029.                   
                 HIDE MESSAGE.
             END.          
END.

PROCEDURE p_carregabrowse:

  DEF INPUT PARAMETER par_cdacesso  AS CHARACTER              NO-UNDO.

  DEF   VAR    aux_nmadmcrd         LIKE crapadc.nmresadm     NO-UNDO.

/*FOR EACH crawand.
      DELETE crawand.
  END.*/
  
  EMPTY TEMP-TABLE crawand.
  
  FOR EACH craptab WHERE craptab.cdcooper = glb_cdcooper        AND
                         craptab.nmsistem = "CRED"              AND
                         craptab.tptabela = "USUARI"            AND
                         craptab.cdempres = 11                  AND
                         craptab.cdacesso BEGINS(par_cdacesso)  NO-LOCK:

      FIND crapadc WHERE
           crapadc.cdcooper = glb_cdcooper                         AND 
           crapadc.cdadmcrd = INT(SUBSTR(craptab.cdacesso, 10, 1)) NO-LOCK 
           NO-ERROR.
      IF   AVAILABLE crapadc   THEN
           aux_nmadmcrd = crapadc.nmresadm.
      ELSE
           aux_nmadmcrd = " ** ERRO ** ".
      
      CREATE crawand.
      ASSIGN crawand.cdadmcrd = INT(SUBSTR(craptab.cdacesso, 10, 1))
             crawand.nmresadm = aux_nmadmcrd
             crawand.nrsequen = craptab.tpregist
             crawand.qtparcan = INT(SUBSTR(craptab.dstextab, 1, 2))
             crawand.vlanuida = DECIMAL(SUBSTR(craptab.dstextab,4,9))
             crawand.dtrefere = DATE(INT(SUBSTR(craptab.dstextab,17,2)),
                                     INT(SUBSTR(craptab.dstextab,14,2)),
                                     INT(SUBSTR(craptab.dstextab,20,4))).
  END.
  
  OPEN QUERY qry_anuidade FOR EACH crawand BY crawand.cdadmcrd 
                                           BY crawand.nrsequen.
                                           
END.

/* .......................................................................... */

