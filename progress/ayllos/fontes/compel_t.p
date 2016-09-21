/* ..........................................................................

   Programa: Fontes/compel_t.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Ze Eduardo     
   Data    : Setembro/2003.                  Ultima atualizacao: 22/09/2014    

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Tratamento de arquivo de retorno dos cheques do Banco do Brasil.
               relatorio (304).

   Alteracoes: 20/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)
                            
               22/09/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)             
............................................................................. */

DEF STREAM str_1.
DEF STREAM str_2.

{ includes/var_online.i }

DEF TEMP-TABLE crawarq                                               NO-UNDO
    FIELD nmarquiv AS CHAR              
    FIELD nrsequen AS INTEGER
    FIELD qtcheque AS INTEGER
    FIELD totchequ AS DECIMAL
    INDEX crawarq1 AS PRIMARY
          nmarquiv nrsequen.

DEF TEMP-TABLE crawrel                                               NO-UNDO
    FIELD dtrefere AS DATE
    FIELD nmarquiv AS CHAR              
    FIELD tparquiv AS CHAR
    FIELD cdheader AS INT          /*  0 - Header  /  1 - Detalhe  */
    FIELD nrsequen AS INTEGER
    FIELD dsdocmc7 AS CHAR
    FIELD vlcheque AS DECIMAL
    FIELD cdmotivo AS INT
    FIELD dscritic AS CHAR
        INDEX crawrel1 AS PRIMARY
              nmarquiv cdheader nrsequen.
                      
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.

DEF         VAR par_flgrodar AS LOGICAL INIT TRUE                    NO-UNDO.
DEF         VAR par_flgfirst AS LOGICAL INIT TRUE                    NO-UNDO.
DEF         VAR par_flgcance AS LOGICAL                              NO-UNDO.


DEF         VAR rel_nmempres AS CHAR    FORMAT "x(15)"               NO-UNDO.
DEF         VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5      NO-UNDO.
DEF         VAR rel_nmresemp AS CHAR                                 NO-UNDO.
DEF         VAR rel_nrmodulo AS INT     FORMAT "9"                   NO-UNDO.
DEF         VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF         VAR aux_nmarquiv AS CHAR                                 NO-UNDO.
DEF         VAR aux_setlinha AS CHAR    FORMAT "x(240)"              NO-UNDO.
DEF         VAR aux_flgfirst AS LOGICAL                              NO-UNDO.
DEF         VAR aux_nrconven AS INT                                  NO-UNDO.
DEF         VAR aux_contareg AS INT                                  NO-UNDO.
DEF         VAR aux_cdocorre AS INT                                  NO-UNDO.
DEF         VAR aux_cdmotivo AS INT                                  NO-UNDO.
DEF         VAR aux_flgescra AS LOGICAL                              NO-UNDO.
DEF         VAR aux_dscomand AS CHAR                                 NO-UNDO.
DEF         VAR aux_contador AS INT                                  NO-UNDO.
DEF         VAR aux_tparquiv AS CHAR                                 NO-UNDO.
DEF         VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF         VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.

DEF         VAR aux_nmarqimp AS CHAR                                 NO-UNDO.
DEF         VAR aux_nrsequen AS INT                                  NO-UNDO.
DEF         VAR aux_nmendter AS CHAR    FORMAT "x(20)"               NO-UNDO.
DEF         VAR aux_dtrefere AS DATE                                 NO-UNDO.
DEF         VAR aux_qtcheque AS INT                                  NO-UNDO.
DEF         VAR aux_totchequ AS DECIMAL                              NO-UNDO.
DEF         VAR aux_dsocorre AS CHAR                                 NO-UNDO.
DEF         VAR aux_dscritic AS CHAR                                 NO-UNDO.
DEF         VAR aux_cdheader AS INT                                  NO-UNDO.
DEF         VAR tot_qtcheque AS INT                                  NO-UNDO.
DEF         VAR tot_totchequ AS DECIMAL                              NO-UNDO.

DEF         VAR aux_dadosusr AS CHAR                                 NO-UNDO.
DEF         VAR par_loginusr AS CHAR                                 NO-UNDO.
DEF         VAR par_nmusuari AS CHAR                                 NO-UNDO.
DEF         VAR par_dsdevice AS CHAR                                 NO-UNDO.
DEF         VAR par_dtconnec AS CHAR                                 NO-UNDO.
DEF         VAR par_numipusr AS CHAR                                 NO-UNDO.
DEF         VAR h-b1wgen9999 AS HANDLE                               NO-UNDO.


FORM aux_setlinha  FORMAT "x(240)"
     WITH FRAME AA WIDTH 240 NO-BOX NO-LABELS.

FORM SKIP(3)
     crawrel.nmarquiv   AT 01  FORMAT "x(30)"   LABEL "Arquivo"
     crawrel.tparquiv   AT 55  FORMAT "x(20)"   LABEL "Tipo"
     SKIP(1)
     crawrel.dtrefere   AT 01                   LABEL "Data de Referencia"
     aux_dscritic       AT 40  FORMAT "x(30)"   LABEL "Critica"
     SKIP(1)
     aux_dsocorre       AT 01  FORMAT "x(30)"   LABEL "Ocorrencia de Retorno"
     SKIP(3)
     WITH NO-BOX SIDE-LABEL DOWN WIDTH 80 FRAME f_cabec1.

FORM SKIP(1)
     "CMC-7 DO CHEQUE"       AT 01
     "SEQ"                   AT 38
     "VALOR"                 AT 50
     "DESCRICAO DA CRITICA"  AT 56
     SKIP(1)
     WITH NO-BOX NO-ATTR-SPACE NO-LABELS WIDTH 80 FRAME f_cabec2.

FORM crawrel.dsdocmc7   AT 01  FORMAT "x(34)"
     crawrel.nrsequen   AT 38  FORMAT "zz9"          
     crawrel.vlcheque   AT 42  FORMAT "zz,zzz,zz9.99"
     crawrel.dscritic   AT 56  FORMAT "x(24)"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_lancamentos.

FORM SKIP(1)
     "TOTAL REJEITADOS -->" AT 01
     aux_qtcheque           AT 23  FORMAT "zzz,zz9"          
     aux_totchequ           AT 37  FORMAT "zzz,zzz,zzz,zz9.99"
     SKIP(1)
     "TOTAL DO ARQUIVO -->" AT 01
     crawarq.qtcheque       AT 23  FORMAT "zzz,zz9"          
     crawarq.totchequ       AT 37  FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABEL DOWN WIDTH 80 FRAME f_total.

HIDE MESSAGE NO-PAUSE.

MESSAGE "AGUARDE... Processando Arquivos de Retorno!".

/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.

/*FOR EACH crawrel:
    DELETE crawrel.
END.*/
EMPTY TEMP-TABLE crawrel.

/*FOR EACH crawarq:
    DELETE crawarq.
END.*/
EMPTY TEMP-TABLE crawarq.    

ASSIGN aux_nmarquiv = "integra/IEDCHQ*.RET"
       aux_flgfirst = FALSE.

INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
      NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(40)" .

   UNIX SILENT VALUE("mv " + aux_nmarquiv + " " + aux_nmarquiv + ".ori").

   UNIX SILENT VALUE("script/trnulo " + aux_nmarquiv + ".ori " +
                     aux_nmarquiv).
        
   UNIX SILENT VALUE("rm " + aux_nmarquiv + ".ori").

   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " +
                      aux_nmarquiv + ".q 2> /dev/null").

   INPUT STREAM str_2 FROM VALUE(aux_nmarquiv + ".q") NO-ECHO.

   SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 240.
  
   CREATE crawarq.
   ASSIGN crawarq.nrsequen = INT(STRING(SUBSTR(aux_setlinha,158,06)))
          crawarq.nmarquiv = aux_nmarquiv
          aux_flgfirst     = FALSE.

   INPUT STREAM str_2 CLOSE.
                                                       
END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_flgfirst THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         PAUSE(5) NO-MESSAGE.
         RETURN.
     END.

/* Tabela que contem as dados sobre a compensacao cheques do Banco do Brasil */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "CONFIG"      AND
                   craptab.cdempres = 00            AND
                   craptab.cdacesso = "COMPELBBCH"  AND
                   craptab.tpregist = 000 NO-LOCK NO-ERROR NO-WAIT.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 258.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         PAUSE(5) NO-MESSAGE.
         RETURN.
     END.    

ASSIGN aux_nrsequen = INTEGER(STRING(SUBSTR(craptab.dstextab,34,6),"999999"))
       aux_nrconven = INTEGER(SUBSTR(craptab.dstextab,17,09)).

aux_flgfirst = TRUE.

FOR EACH crawarq BY crawarq.nrsequen
                    BY crawarq.nmarquiv:  

    /*  Verifica  somente  a  Sequencia   */ 

    IF   aux_nrsequen > crawarq.nrsequen THEN
         DO:
             UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
             UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
         
             NEXT.
         END.
         
    IF   aux_nrsequen = crawarq.nrsequen THEN
         RUN proc_processa_arquivo.
    ELSE
         DO:
             glb_cdcritic = 476.
             RUN fontes/critic.p.
             MESSAGE glb_dscritic.
             PAUSE(5) NO-MESSAGE.
             ASSIGN glb_cdcritic = 0
                    aux_nmarquiv = "integra/err" +
                                   SUBSTR(crawarq.nmarquiv,12,29).

             UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
             UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " " + aux_nmarquiv).
             NEXT.
         END.  /*  Fim do ELSE  */

    HIDE MESSAGE NO-PAUSE.

END.

IF  NOT aux_flgfirst THEN
    DO:
        DO TRANSACTION ON ENDKEY UNDO, LEAVE:
             
           /*   Atualiza a sequencia da remessa  */
               
           DO aux_contador = 1 TO 10:
 
              FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                 craptab.nmsistem = "CRED"        AND
                                 craptab.tptabela = "CONFIG"      AND
                                 craptab.cdempres = 00            AND
                                 craptab.cdacesso = "COMPELBBCH"  AND
                                 craptab.tpregist = 000
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
                            LEAVE.
                        END.    
                            
              ELSE
                   glb_cdcritic = 0.

              LEAVE.

           END.  /*  Fim do DO .. TO  */

           IF   glb_cdcritic > 0 THEN
                DO:
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    PAUSE(5) NO-MESSAGE.
                    LEAVE.
                END.

           ASSIGN craptab.dstextab = SUBSTR(craptab.dstextab,1,33) +
                                     STRING(aux_nrsequen,"999999").

        END. /* TRANSACTION */
    END.  /*   NOT aux_flgfirst  */

/*.........................   Imprime Relatorio   ........................*/

ASSIGN aux_qtcheque = 0
       aux_totchequ = 0.

FOR EACH crawrel USE-INDEX crawrel1 
                     BREAK BY crawrel.nmarquiv
                              BY crawrel.cdheader
                                 BY crawrel.nrsequen:

    IF   FIRST-OF(crawrel.nmarquiv) THEN
         DO:
             ASSIGN glb_cdcritic    = 0
                    glb_nrdevias    = 1
                    glb_cdempres    = 11
                    glb_cdrelato[1] = 304.

             { includes/cabrel080_1.i }

             aux_nmarqimp = "rl/O304_" + STRING(TIME,"99999") + ".lst".
 
             HIDE MESSAGE NO-PAUSE.

             /*  Gerenciamento da impressao  */

             INPUT THROUGH basename `tty` NO-ECHO.

             SET aux_nmendter WITH FRAME f_terminal.

             INPUT CLOSE.
             
             aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                   aux_nmendter.

             UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
             
             MESSAGE "AGUARDE... Imprimindo relatorio!".

             FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                NO-LOCK NO-ERROR.
             
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

             PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

             PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

             VIEW STREAM str_1 FRAME f_cabrel080_1.
        
             CASE crawrel.cdmotivo:
                  WHEN 00 THEN aux_dsocorre = "Remessa Aceita".
                  WHEN 01 THEN aux_dsocorre = "Remessa Aceita (01)".
                  WHEN 02 THEN aux_dsocorre = "Header Invalido".
                  WHEN 03 THEN aux_dsocorre = "Header Invalido".
                  WHEN 04 THEN aux_dsocorre = "Empresa Invalida".
                  WHEN 05 THEN aux_dsocorre = "Fora de LayOut".
                  WHEN 06 THEN aux_dsocorre = "Detalhe Invalido".
                  WHEN 07 THEN aux_dsocorre = "Trailler Invalido".
                  WHEN 08 THEN aux_dsocorre = "Nro Remessa Invalido".
                  WHEN 09 THEN aux_dsocorre = "Data Remessa Invalido".
                  WHEN 10 THEN aux_dsocorre = "Erro Qtdade no Rodape".
                  WHEN 11 THEN aux_dsocorre = "Erro Valor no Rodape".
                  OTHERWISE    aux_dsocorre = "Critica desconhecida".
             END CASE.
 
             ASSIGN aux_dscritic = IF   crawrel.dscritic = "" THEN
                                        "NENHUMA"
                                   ELSE crawrel.dscritic.     
             
             DISPLAY STREAM str_1 crawrel.nmarquiv  crawrel.tparquiv
                                  crawrel.dtrefere  aux_dscritic
                                  aux_dsocorre      WITH FRAME f_cabec1.
                                  
             VIEW STREAM str_1 FRAME f_cabec2.
         END.

    IF   crawrel.cdmotivo <> 00 THEN
         DO:
    
            ASSIGN aux_qtcheque = aux_qtcheque + 1
                   aux_totchequ = aux_totchequ + crawrel.vlcheque.
               
            DISPLAY STREAM str_1 crawrel.dsdocmc7   crawrel.nrsequen
                                 crawrel.vlcheque   crawrel.dscritic   
                                 WITH FRAME f_lancamentos.

            DOWN STREAM str_1 WITH FRAME f_lancamentos.
         
         END.
         
    IF   LINE-COUNTER(str_1) > 77 THEN
         DO:
             PAGE STREAM str_1.
             VIEW STREAM str_1 FRAME f_cabrel080_1.
             VIEW STREAM str_1 FRAME f_cabec2.
         END.

    IF   LAST-OF(crawrel.nmarquiv) THEN
         DO:
             FIND crawarq WHERE crawarq.nmarquiv = crawrel.nmarquiv 
                                NO-LOCK NO-ERROR.
                                
             IF   NOT AVAILABLE crawarq THEN
                  DO:
                      glb_cdcritic = 182.
                      RUN fontes/critic.p.
                      MESSAGE glb_dscritic.
                      PAUSE(5) NO-MESSAGE.
                      ASSIGN glb_cdcritic = 0.
                      LEAVE.
                  END.
             
             DISPLAY STREAM str_1 aux_qtcheque      aux_totchequ 
                                  crawarq.qtcheque  crawarq.totchequ 
                                  WITH FRAME f_total.
             
             DISPLAY STREAM str_1 SKIP(2)
                                  "                 REGISTROS REJEITADOS" AT 44
                                  SKIP(5)
                                  "_____________________________________" AT 44
                                  SKIP
                                  "   CADASTRO E VISTO DO FUNCIONARIO   " AT 44
                                  WITH NO-LABELS NO-BOX WIDTH 80 FRAME f_visto.

             PAGE STREAM str_1.

             PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

             PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

             OUTPUT STREAM str_1 CLOSE.
 
             ASSIGN glb_nrcopias = 1
                    glb_nmformul = "80col"
                    glb_nmarqimp = aux_nmarqimp
                    aux_qtcheque = 0
                    aux_totchequ = 0.

             { includes/impressao.i }

         END.
END.

/* .......................................................................... */

/*.........................   Le Arq e Grava no Temp  .......................*/

PROCEDURE proc_processa_arquivo:

   ASSIGN aux_nrsequen = aux_nrsequen + 1
          aux_flgfirst = FALSE
          aux_cdheader = 0
          aux_contareg = 1
          aux_qtcheque = 0
          aux_totchequ = 0.
                      
   glb_cdcritic = 340.
   RUN fontes/critic.p.
   MESSAGE glb_dscritic.
   PAUSE(0) NO-MESSAGE.
   ASSIGN glb_cdcritic = 0
          glb_dscritic = "".

   INPUT STREAM str_1 FROM VALUE(crawarq.nmarquiv + ".q") NO-ECHO.

   /*   Header do Arquivo   */
    
   SET STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 240.

   ASSIGN aux_tparquiv = SUBSTR(aux_setlinha,181,20)
          aux_dtrefere = DATE(INT(STRING(SUBSTR(aux_setlinha,146,02),"99")),
                              INT(STRING(SUBSTR(aux_setlinha,144,02),"99")),
                              INT(STRING(SUBSTR(aux_setlinha,148,04),"9999"))).
   
   IF    INTEGER(SUBSTR(aux_setlinha,33,9)) <> aux_nrconven THEN
         glb_cdcritic = 563.
    
   IF    INTEGER(SUBSTR(aux_setlinha,53,6)) <> crapcop.cdagedbb THEN
         glb_cdcritic = 134.
         
   IF    INTEGER(SUBSTR(aux_setlinha,59,13)) <> crapcop.nrctadbb THEN
         glb_cdcritic = 127.

   IF   glb_cdcritic <> 0 THEN
        RUN fontes/critic.p.
    
   /*   Header do Lote   */

   SET STREAM str_1 aux_setlinha  WITH FRAME AA WIDTH 240.

   aux_cdmotivo = INTEGER(SUBSTR(aux_setlinha,233,02)).
              
   RUN proc_grava_erro.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN glb_dscritic = "" 
              aux_cdheader = 1.
              
       SET STREAM str_1 aux_setlinha WITH FRAME AA WIDTH 240.

       /*  Verifica se eh final do Arquivo  */
       
       IF   INTEGER(SUBSTR(aux_setlinha,8,1)) = 5 THEN
            DO:
                /*   Conferir o total do arquivo   */

                ASSIGN crawarq.qtcheque = aux_qtcheque
                       crawarq.totchequ = DECIMAL(SUBSTR(aux_setlinha,24,18))
                                          / 100.
                NEXT.
            END.
       ELSE     
            IF   INTEGER(SUBSTR(aux_setlinha,8,1)) = 9 THEN
                 NEXT.

       ASSIGN aux_cdmotivo = INT(SUBSTR(aux_setlinha,231,02))
              aux_cdmotivo = IF   aux_cdmotivo = 3 THEN
                                  0
                             ELSE aux_cdmotivo    
              aux_cdocorre = INT(SUBSTR(aux_setlinha,233,02))
              aux_qtcheque = aux_qtcheque + 1
              aux_totchequ = aux_totchequ + 
                             (DECIMAL(SUBSTR(aux_setlinha,66,15)) / 100).

       IF   aux_cdmotivo = 01 THEN
            DO:
                CASE aux_cdocorre:
                     WHEN 54 THEN glb_dscritic = "Custodia em Garantia".
                     WHEN 55 THEN glb_dscritic = "Substituicao da Garantia".
                     WHEN 56 THEN glb_dscritic = "Excedente da Garantia".
                     OTHERWISE    glb_dscritic = "Critica desconhecida".
                END CASE.
            END.
       ELSE     
            DO: 
                IF   aux_cdmotivo = 02 THEN
                     DO:
                         CASE aux_cdocorre:
                              WHEN 07 THEN glb_dscritic = "Banco inexistente".
                              WHEN 08 THEN glb_dscritic = "Agencia inexistente".
                              WHEN 09 THEN glb_dscritic = "Conta BB invalida".
                              WHEN 10 THEN glb_dscritic = 
                                                      "Data Bom Para invalida".
                              WHEN 11 THEN glb_dscritic = "Valor Invalido".
                              WHEN 12 THEN glb_dscritic = "Dados Invalidos".
                              WHEN 13 THEN glb_dscritic = "Magnetico Invalidos".
                              WHEN 14 THEN glb_dscritic = 
                                                      "Cheque em Duplicidade".
                              WHEN 15 THEN glb_dscritic = 
                                                      "Cheque ja Custodiado".
                              WHEN 16 THEN glb_dscritic = "Agencia inexistente".
                              WHEN 17 THEN glb_dscritic = 
                                                      "Reg. DETALHE Invalido".
                              WHEN 19 THEN glb_dscritic = 
                                                     "Dados do VERSO invalidos".
                              WHEN 20 THEN glb_dscritic = "Remessa Recusada".
                              WHEN 57 THEN glb_dscritic = 
                                                     "CPF do Cheque Invalido".
                              OTHERWISE    glb_dscritic = 
                                           "Critica desconhecida".
                         END CASE.
                     END.
                ELSE     
                     DO:
                         IF   aux_cdmotivo = 06 THEN
                              DO:
                                  CASE aux_cdocorre:
                                       WHEN 21 THEN glb_dscritic =
                                                   "Cheque Excluido".
                                       WHEN 59 THEN glb_dscritic = 
                                                   "Cheque Excluido".
                                       WHEN 60 THEN glb_dscritic = 
                                                   "Excluido pela Agencia".
                                  END CASE.
                              END.
                         ELSE       /*       Devolucao de Cheques     */
                              IF   aux_cdmotivo = 05 THEN 
                                   glb_dscritic = "Devolucao - alinea " +
                                                  STRING(aux_cdocorre, "99").
                     END.                        
            END.   /*  Fim do Else  */              
       
       IF   glb_dscritic <> "" THEN
            RUN proc_grava_erro.
       
       ASSIGN aux_contareg = aux_contareg + 1.
       
    END.  /*   Fim  do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.

    UNIX SILENT VALUE("mv " + crawarq.nmarquiv + " salvar").
    UNIX SILENT VALUE("rm " + crawarq.nmarquiv + ".q 2> /dev/null").
         
END PROCEDURE.

PROCEDURE proc_grava_erro:

   CREATE crawrel.
   ASSIGN crawrel.nmarquiv = crawarq.nmarquiv
          crawrel.tparquiv = aux_tparquiv
          crawrel.cdheader = aux_cdheader
          crawrel.dtrefere = aux_dtrefere
          crawrel.cdmotivo = aux_cdmotivo
          crawrel.dscritic = glb_dscritic.
          
   IF   aux_cdheader = 1 THEN
        ASSIGN crawrel.nrsequen = INT(SUBSTR(aux_setlinha,09,05))
               crawrel.dsdocmc7 = SUBSTR(aux_setlinha,18,34)
               crawrel.vlcheque = (DECIMAL(SUBSTR(aux_setlinha,66,15)) / 100).
   
END PROCEDURE
/* ......................................................................... */

