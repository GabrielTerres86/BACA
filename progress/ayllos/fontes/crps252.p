/* .............................................................................

   Programa: Fontes/crps252.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Novembro/98.                       Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:                                               

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 1.
               Integrar arquivos de DOC's/Depositos do BANCOOB .
               Emite relatorio 205.

   Alteracoes: 04/01/1999 - Alterado para tratar tipo de documento 07 (Edson).
   
               12/01/1999 - Criado historico 319 para os documentos com tipo 7
                            (Deborah).
                            
               17/06/1999 - Criado historico 339 para creditos de seguro saude
                            sul america (Odair)

               18/06/1999 - Alterar relatorio (Odair).

               24/11/1999 - Passar a integrar arquivos de DEPOSITO ENTRE COOP.
                            (Odair)

               04/01/2000 - Nao gerar pedido de impressao (Deborah).

               11/02/2000 - Gerar pedido de impressao (Deborah).

               14/04/2000 - Utilizar o numero da agencia do crapcop (Edson).

               26/05/2000 - Tratar tabela CNVBANCOOB (Odair)
               
               03/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               12/12/2000 - Consistir dados dos DOC's  "D" (Eduardo).

               24/01/2001 - Comparar somente 3 posicoes no nome do arquivo 
                            (Deborah)

               20/03/2001 - Acerto na numeracao dos lotes (Deborah).
               
               15/05/2001 - Conferir a data de referencia dos arquivos da 
                            compensacao Bancoob. (Ze Eduardo).
                            
               06/06/2001 - Atualizar novos campos do craplcm para
                            atender circular 3030 (Margarete).

               23/08/2002 - Alterar para o script/compefora (Margarete).
                
               16/09/2002 - Comparar o cpf se o tipo de doc for 4 (Ze Eduardo).
                            line = 527.

               20/01/2003 - Mostrar os CPF quando der a critica 301 (Deborah)

               07/02/2003 - Tratar restituicao de IRenda (Deborah).

               09/05/2003 - Tratar depositos em cheques (Edson).
               
               19/09/2003 - Imprimir CPF (Fernando).

               13/02/2004 - Nao aceitar valor Maior ou Igual a 5000(Mirtes) 
                   
               22/04/2004 - Rejeitar Doc Bancoob exceto Receita Federal. (Ze)

               10/05/2004 - Rejeiar Doc.Bancoob quando Credifiesc(Mirtes).
               
               30/06/2005 - Alimentado campo cdcooper  das tabelas craprej,
                            craplot, craplcm e crapdpb (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               10/12/2005 - Atualizar craplcm.nrdctitg (Magui).

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               17/05/2007 - Acerto no CREATE craplot e Totais (Ze).

               06/06/2007 - Tratar DOC E nos mesmo modelo do DOC C (Ze).

               04/07/2007 - Manda email para karina, joice e tavares qdo nao
                            existe arquivo para ser integrado (Elton).

               27/08/2007 - Retirado envio email(Guilherme).

               11/09/2007 - Incluir TEC Bancoob (Ze).

               09/04/2008 - Alterado para nao gerar criticas, quando for DOC "D"
                            e a conta ter mais de uma titularidade (Elton).

               15/09/2008 - Inserido no-error no assign da linha 549, caso
                            ocorrorer erro, gerar log em proc_batch.log
                            (Gabriel).

               18/01/2010 - Incluida validacao para TECs recebidas pela COMPE
                            (Elton).

               08/12/2010 - Condicoes Transferencia de PAC e novo relat 203_99
                            (Guilherme/Supero)
                            
               18/01/2011 - Incluido os e-mails:
                            - fabiano@viacredi.coop.br
                            - moraes@viacredi.coop.br
                            (Adriano).
                            
               03/06/2011 - Alterado destinatário do envio de email na procedure
                            gera_relatorio_203_99; 
                            De: thiago.delfes@viacredi.coop.br
                            Para: brusque@viacredi.coop.br. (Fabricio)             
               
               09/12/2011 - Excluído e-mail: - fabiano@viacredi.coop.br (Tiago).
               
               04/04/2012 - Nao integrar DOC Bancoob (exceto TEC) a partir de
                            02/05/2012 - conforme Trf. 46080 (Ze). 
                            
               18/06/2012 - Alteracao na leitura da craptco (David Kruger).
               
               20/12/2012 - Adaptacao para Migracao AltoVale (Ze).
               
               15/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               24/10/2013 - Retirado o "new" e comentarios de teste (Adriano).
               
               13/11/2013 - Tratamento para Migracao para Viacredi (Ze).
               
               17/01/2014 - Inclusao de VALIDATE craprej, craplot, craplcm e 
                            crapdpb (Carlos)
               
               01/07/2014 - Substituido e-mail 
                            "juliana.carla@viacredialtovale.coop.br"
                            para
                            "suporte@viacredialtovale.coop.br"  (Daniele).
               
               10/03/2015 - Alterado para que todos registro entrem na condicao
                            de DOC NAO ACEITO - 798 (SD174586 - Tiago).

			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

............................................................................. */

DEF STREAM str_1.   /*  Para relatorio de criticas  */
DEF STREAM str_2.   /*  Para arquivo de trabalho */

{ includes/var_batch.i }

DEF        VAR rel_nmempres AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR tab_nmarqdoc AS CHAR    FORMAT "x(25)" EXTENT 99      NO-UNDO.
DEF        VAR aux_contador AS INT                                   NO-UNDO.
DEF        VAR aux_contadia AS INT                                   NO-UNDO.
DEF        VAR i            AS INT                                   NO-UNDO.
DEF        VAR aux_nmarquiv AS CHAR                                  NO-UNDO.

DEF        VAR aux_setlinha AS CHAR    FORMAT "x(270)"               NO-UNDO.

DEF        VAR aux_diarefer AS INT                                   NO-UNDO.
DEF        VAR aux_mesrefer AS INT                                   NO-UNDO.
DEF        VAR aux_anorefer AS INT                                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtlibera AS DATE                                  NO-UNDO.

DEF        VAR tot_qtregrec AS INT                                   NO-UNDO.
DEF        VAR tot_qtregint AS INT                                   NO-UNDO.
DEF        VAR tot_qtregrej AS INT                                   NO-UNDO.
DEF        VAR tot_vlregrec AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlregint AS DECIMAL                               NO-UNDO.
DEF        VAR tot_vlregrej AS DECIMAL                               NO-UNDO.

DEF        VAR aux_contareg AS INT                                   NO-UNDO.

DEF        VAR aux_vlcredit AS DECIMAL                               NO-UNDO.

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 756                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_tplotmov AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_nrdolot2 AS INT                                   NO-UNDO.

DEF        VAR aux_nrdconta AS INTEGER                               NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.

DEF        VAR aux_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgrejei AS LOGICAL                               NO-UNDO.

DEF        VAR aux_cdbancob AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdageban AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdep AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqdoc AS CHAR                                  NO-UNDO.

DEF        VAR flg_nmarqdoc AS LOGICAL                               NO-UNDO.
DEF        VAR flg_dpcheque AS LOGICAL                               NO-UNDO.

DEF        VAR aux_vllanmto AS DECI                                  NO-UNDO.
DEF        VAR aux_nrdocmto AS INT                                   NO-UNDO.
DEF        VAR aux_nrseqarq AS INT                                   NO-UNDO.
DEF        VAR aux_cdpesqbb AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtcompln AS INT                                   NO-UNDO.
DEF        VAR aux_vlcompcr AS DECI                                  NO-UNDO.
DEF        VAR aux_nmdestin AS CHAR                                  NO-UNDO.
DEF        VAR aux_tpdedocs AS INT                                   NO-UNDO.

DEF        VAR aux_cpfdesti AS DECI                                  NO-UNDO.
DEF        VAR aux_cpfremet AS DECI                                  NO-UNDO.
DEF        VAR aux_dtauxili AS CHAR                                  NO-UNDO.

DEF        VAR aux_cdbanchq LIKE craplcm.cdbanchq                    NO-UNDO.
DEF        VAR aux_cdcmpchq LIKE craplcm.cdcmpchq                    NO-UNDO.
DEF        VAR aux_cdagechq LIKE craplcm.cdagechq                    NO-UNDO.
DEF        VAR aux_nrctachq LIKE craplcm.nrctachq                    NO-UNDO.
DEF        VAR aux_nrlotchq LIKE craplcm.nrlotchq                    NO-UNDO.
DEF        VAR aux_sqlotchq LIKE craplcm.sqlotchq                    NO-UNDO.
DEF        VAR aux_cdpeslcm AS CHAR                                  NO-UNDO.
DEF        VAR aux_dsinform AS CHAR FORMAT "x(100)"                  NO-UNDO.
DEF        VAR aux_nrcpfstl LIKE crapttl.nrcpfcgc					 NO-UNDO.
DEF        VAR aux_nrcpfttl LIKE crapttl.nrcpfcgc                    NO-UNDO.
  
DEF        VAR rel_cpfdesti AS CHAR FORMAT "x(18)"                   NO-UNDO.
DEF        VAR rel_dscpfcgc AS CHAR FORMAT "x(18)"                   NO-UNDO.

FORM aux_setlinha  FORMAT "x(270)"
     WITH FRAME AA WIDTH 270 NO-BOX NO-LABELS.

FORM SKIP(1)
     "ARQUIVO:"         AT 01
     aux_nmarquiv       AT 10 FORMAT "x(35)"    NO-LABEL
     SKIP(1)
     glb_dtmvtolt       AT 01 FORMAT "99/99/9999" LABEL "DATA"
     aux_cdagenci       AT 18 FORMAT "zz9"        LABEL "PA"
     aux_cdbccxlt       AT 30 FORMAT "zz9"        LABEL "BANCO/CAIXA"
     aux_nrdolote       AT 49 FORMAT "zzz,zz9"    LABEL "LOTE"
     aux_tplotmov       AT 63 FORMAT "99"         LABEL "TIPO"
     SKIP(1)
     "  CONTA/DV  DOCMTO DESTINATARIO                      VALOR"
     "DOC BANCO-AGENCIA-DEPOSITANTE            CRITICA"
     SKIP
     "---------- ------- ------------------------- -------------"
     "--- ------------------------------------ ------------------------------"
     WITH NO-BOX SIDE-LABELS DOWN WIDTH 132 FRAME f_cab.

FORM craprej.nrdconta     AT  1                  NO-LABEL     
     craprej.nrdocmto     FORMAT "zzz,zz9"       NO-LABEL
     craprej.dshistor     FORMAT "x(25)"         NO-LABEL 
     craprej.vllanmto     FORMAT "zz,zzz,zz9.99" NO-LABEL
     craprej.indebcre     FORMAT " !"            NO-LABEL 
     craprej.cdpesqbb     FORMAT "x(35)" AT 64   NO-LABEL                      
     glb_dscritic         FORMAT "x(30)" AT 101  NO-LABEL
     SKIP
     rel_dscpfcgc         FORMAT "x(18)" AT 20   NO-LABEL
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_lanctos.

FORM aux_dsinform         AT 20                   NO-LABEL
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_dados.  

FORM SKIP(1)
     "RECEBIDOS      INTEGRADOS      REJEITADOS"   AT  28
     SKIP(1)
     "REGISTROS:"         AT 10
     tot_qtregrec         AT 30 FORMAT "zzz,zz9"
     tot_qtregint         AT 46 FORMAT "zzz,zz9"
     tot_qtregrej         AT 62 FORMAT "zzz,zz9"
     tot_vlregrec         AT 22 FORMAT "zzzz,zzz,zz9.99"
     tot_vlregint         AT 38 FORMAT "zzzz,zzz,zz9.99"
     tot_vlregrej         AT 54 FORMAT "zzzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS DOWN WIDTH 132 FRAME f_total.

ASSIGN glb_cdprogra = "crps252"
       glb_flgbatch = FALSE.

RUN fontes/iniprg.p.
 
IF   glb_cdcritic > 0 THEN
     RETURN.
 
/* Busca dados da cooperativa */

FIND crapcop WHERE  crapcop.cdcooper = glb_cdcooper  AND
                    crapcop.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                           " - " + glb_cdprogra + "' --> '"  +
                           glb_dscritic + " >> log/proc_batch.log").
         RETURN.
     END.


ASSIGN aux_nmarquiv = "integra/3" + STRING(crapcop.cdagebcb,"9999") + "*.RT*"
       aux_contador = 0.               
 
INPUT STREAM str_1 THROUGH VALUE( "ls " + aux_nmarquiv + " 2> /dev/null")
             NO-ECHO.
                                              
DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

   SET STREAM str_1 aux_nmarquiv FORMAT "x(60)" .
            
   UNIX SILENT VALUE("quoter " + aux_nmarquiv + " > " + 
                     aux_nmarquiv + ".q 2> /dev/null").

   ASSIGN aux_contador               = aux_contador + 1
          tab_nmarqdoc[aux_contador] = aux_nmarquiv.

END.  /*  Fim do DO WHILE TRUE  */

INPUT STREAM str_1 CLOSE.

IF   aux_contador = 0 THEN
     DO:
         glb_cdcritic = 182.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                            glb_cdprogra + "' --> '" + glb_dscritic +
                            " >> log/proc_batch.log").

         RUN fontes/fimprg.p.
         RETURN.
     END.

/*  Calcula data de liberacao dos depositos em cheque  */

aux_dtlibera = glb_dtmvtolt.

DO WHILE TRUE:       /*  5 dias uteis  */

   aux_dtlibera = aux_dtlibera + 1.
   
   IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtlibera)))               OR
        CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper    AND
                               crapfer.dtferiad = aux_dtlibera)   THEN
        NEXT.
        
   aux_contadia = aux_contadia + 1.

   IF   aux_contadia = 4   THEN
        LEAVE.
   
END.  /*  Fim do DO WHILE TRUE  */

/*  Fim da verificacao se deve executar  */

FIND craptab WHERE craptab.cdcooper = glb_cdcooper       AND
                   craptab.nmsistem = "CRED"             AND
                   craptab.tptabela = "GENERI"           AND
                   craptab.cdempres = crapcop.cdcooper   AND
                   craptab.cdacesso = "CNVBANCOOB"       AND
                   craptab.tpregist = 001
                   NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 472.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic +
                           " >> log/proc_batch.log").
         glb_cdcritic = 0.
         RETURN.
     END.

ASSIGN  aux_cdbancob = "756"
        aux_cdageban = STRING(crapcop.cdagebcb)
        aux_nmarqdoc = SUBSTR(craptab.dstextab,17,6)
        aux_nmarqdep = SUBSTR(craptab.dstextab,24,3).

IF   glb_nmtelant = "COMPEFORA"   THEN
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtoan),"9999") +
                           STRING(MONTH(glb_dtmvtoan),"99") +
                           STRING(DAY(glb_dtmvtoan),"99").
ELSE
     ASSIGN aux_dtauxili = STRING(YEAR(glb_dtmvtolt),"9999") +
                           STRING(MONTH(glb_dtmvtolt),"99") +
                           STRING(DAY(glb_dtmvtolt),"99").

DO  i = 1 TO aux_contador:

    ASSIGN aux_flgrejei = FALSE
           aux_vlcredit = 0
           aux_qtcompln = 0
           aux_vlcompcr = 0.

    INPUT STREAM str_2 FROM VALUE(tab_nmarqdoc[i] + ".q") NO-ECHO.

    SET STREAM str_2 aux_setlinha  WITH FRAME AA WIDTH 270.

    IF  SUBSTR(aux_setlinha,1,10) <> "0000000000"  THEN
        glb_cdcritic = 468.
    
    IF  aux_nmarqdep <> SUBSTR(aux_setlinha,21,3) AND
        aux_nmarqdoc <> SUBSTR(aux_setlinha,21,6) THEN
        glb_cdcritic = 173.

    IF  SUBSTR(aux_setlinha,31,8) <> aux_dtauxili THEN
        glb_cdcritic = 013.
    
    IF  SUBSTR(aux_setlinha,67,3) <> aux_cdbancob THEN
        glb_cdcritic = 057.

    IF  glb_cdcritic <> 0 THEN
        DO:
            INPUT STREAM str_2 CLOSE.
            RUN fontes/critic.p.
            aux_nmarquiv = "integra/erd" + SUBSTR(tab_nmarqdoc[i],12,29).
            UNIX SILENT VALUE("rm " + tab_nmarqdoc[i] + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + tab_nmarqdoc[i] + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                              glb_cdprogra + "' --> '" + glb_dscritic + " " +
                              aux_nmarquiv + " >> log/proc_batch.log").
            glb_cdcritic = 0.
            NEXT.
        END.
    
    IF   SUBSTR(aux_setlinha,21,6) = aux_nmarqdoc THEN 
         flg_nmarqdoc = TRUE.
    ELSE
         DO:
             flg_nmarqdoc = FALSE.

             IF   SUBSTR(aux_setlinha,21,6) = "DEC001"   THEN
                  flg_dpcheque = FALSE.
             ELSE
                  flg_dpcheque = TRUE.
         END.
    
    aux_contareg = 1.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 270.
 
       aux_contareg = aux_contareg + 1.

       IF   SUBSTR(aux_setlinha,7,4) = aux_cdageban AND
            SUBSTR(aux_setlinha,4,3) = aux_cdbancob THEN
            aux_vlcredit = aux_vlcredit +
                           (DEC(SUBSTR(aux_setlinha,31,18)) / 100).
       ELSE
       IF   SUBSTR(aux_setlinha,1,10) = "9999999999" THEN
            DO:
                IF   aux_contareg <> INT(SUBSTR(aux_setlinha,250,6)) THEN
                     glb_cdcritic = 504.
                ELSE
               IF   aux_vlcredit <> (DEC(SUBSTR(aux_setlinha,77,18)) / 100) THEN
                     glb_cdcritic = 505.

                LEAVE.

            END.
       ELSE
            DO:
                glb_cdcritic = 513.
                LEAVE.
            END.    
    END.

    INPUT STREAM str_2 CLOSE.

    IF  glb_cdcritic <> 0 THEN
        DO:
            RUN fontes/critic.p.
            aux_nmarquiv = "integra/erd" + SUBSTR(tab_nmarqdoc[i],12,29).
            UNIX SILENT VALUE("rm " + tab_nmarqdoc[i] + ".q 2> /dev/null").
            UNIX SILENT VALUE("mv " + tab_nmarqdoc[i] + " " + aux_nmarquiv).
            UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                              glb_cdprogra + "' --> '" + glb_dscritic + " " +
                              tab_nmarqdoc[i] + " >> log/proc_batch.log").
            glb_cdcritic = 0.
            NEXT.
        END.

    IF   glb_inrestar = 0 OR glb_nrctares = 0 THEN
         aux_flgfirst = TRUE.
    ELSE
         aux_flgfirst = FALSE.
         
    glb_cdcritic = 219.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + glb_cdprogra
                      + "' --> '" + glb_dscritic + "' --> '" + tab_nmarqdoc[i]
                      + " >> log/proc_batch.log").

    glb_cdcritic = 0.

    INPUT STREAM str_2 FROM VALUE(tab_nmarqdoc[i] + ".q") NO-ECHO.

    SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 270.

    TRANS_1:
    DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

       SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 270.

       ASSIGN aux_nrseqarq = INT(SUBSTR(aux_setlinha,250,6))
              aux_cpfdesti = 0
              aux_cpfremet = 0.

       IF   aux_nrseqarq <= glb_nrctares THEN
            NEXT.
       
       IF   SUBSTR(aux_setlinha,1,10) = "9999999999" THEN
            DO:
                CREATE craprej.
                ASSIGN craprej.dtrefere = aux_dtauxili
                       craprej.nrdconta = 999999999
                       craprej.nrseqdig = INT(SUBSTR(aux_setlinha,250,6))
                       craprej.vllanmto = DEC(SUBSTR(aux_setlinha,77,18)) / 100
                       craprej.cdcooper = glb_cdcooper.
                VALIDATE craprej.
                                              
                DO  WHILE TRUE:

                    FIND crapres WHERE crapres.cdcooper = glb_cdcooper  AND
                                       crapres.cdprogra = glb_cdprogra
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                    IF   NOT AVAILABLE crapres   THEN
                         IF   LOCKED crapres   THEN
                              DO:
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                         ELSE
                              DO:
                                  glb_cdcritic = 151.
                                  RUN fontes/critic.p.
                                  UNIX SILENT
                                      VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                             " - " + glb_cdprogra + "' --> '" +
                                             glb_dscritic +
                                             " >> log/proc_batch.log").
                                  UNDO, RETURN.
                         END.
                    ELSE
                         crapres.nrdconta = 0.

                    LEAVE.

                END.  /*  Fim do DO WHILE TRUE  */

                IF  NOT aux_flgfirst THEN
                    DO WHILE TRUE:

                       FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                          craptab.nmsistem = "CRED"        AND
                                          craptab.tptabela = "GENERI"      AND
                                          craptab.cdempres = 00            AND
                                          craptab.cdacesso = "NUMLOTEBCO"  AND
                                          craptab.tpregist = 001
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF   NOT AVAILABLE craptab THEN
                            IF   LOCKED craptab THEN
                                 DO:
                                     PAUSE 2 NO-MESSAGE.
                                     NEXT.
                                 END.
                            ELSE
                                 DO:
                                     glb_cdcritic = 472.
                                     RUN fontes/critic.p.
                                     UNIX SILENT VALUE ("echo " +
                                                STRING(TIME,"HH:MM:SS") + " - "
                                                 + glb_cdprogra + "' --> '" +
                                                glb_dscritic + 
                                                " >> log/proc_batch.log").
                                     RETURN.
                                 END.

                       craptab.dstextab = IF   aux_nrdolote = 7019 THEN
                                               "7010"
                                          ELSE 
                                               STRING(aux_nrdolote + 1,"9999").

                       LEAVE.

                    END.    /*  Fim do DO WHILE TRUE  */

                LEAVE TRANS_1.
            END.

       ASSIGN aux_nrdconta = INT(SUBSTR(aux_setlinha,17,08))
              aux_nrdocmto = INT(SUBSTR(aux_setlinha,25,6))
              aux_vllanmto = DEC(SUBSTR(aux_setlinha,31,18)) / 100
              aux_nrseqarq = INT(SUBSTR(aux_setlinha,250,6))
              aux_cdpesqbb = SUBSTR(aux_setlinha,121,3) + "-" + 
                             SUBSTR(aux_setlinha,124,5) + "-" + 
                             SUBSTR(aux_setlinha,142,40)
              aux_cdpeslcm = SUBSTR(aux_setlinha,142,40)
              aux_nmdestin = SUBSTR(aux_setlinha,49,40)      /* nome */ 
              aux_tpdedocs = INT(SUBSTR(aux_setlinha,203,1)) /* tipo c, d */
              aux_cdbanchq = INT(SUBSTR(aux_setlinha,121,3))
              aux_cdcmpchq = INT(SUBSTR(aux_setlinha,118,3))
              aux_cdagechq = INT(SUBSTR(aux_setlinha,124,4))
              aux_nrctachq = DEC(SUBSTR(aux_setlinha,129,13))
              aux_sqlotchq = INT(SUBSTR(aux_setlinha,250,6))
              rel_cpfdesti = SUBSTR(aux_setlinha,89,14) 
			  aux_nrcpfstl = 0
			  aux_nrcpfttl = 0
			  NO-ERROR.
              
       IF   ERROR-STATUS:ERROR THEN
            DO:
                glb_cdcritic = 843.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                  " - " + glb_cdprogra + "' --> '"  +
                                  glb_dscritic + " "                + 
                                  STRING(aux_nrseqarq,"zzzz,zz9")   +
                                  " >> log/proc_batch.log").
                glb_cdcritic = 0.
                NEXT TRANS_1.
            END.
       
       FIND crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                          crapass.nrdconta = aux_nrdconta  NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapass   THEN
            DO: 
                CREATE craprej.
                ASSIGN craprej.dtrefere = aux_dtauxili
                       craprej.nrdconta = aux_nrdconta
                       craprej.dshistor = aux_nmdestin
                       craprej.nrdocmto = aux_nrdocmto 
                       craprej.vllanmto = aux_vllanmto
                       craprej.nrseqdig = aux_nrseqarq
                       craprej.cdpesqbb = aux_cdpesqbb
                       craprej.cdcooper = glb_cdcooper
     /* tipo de doc */ craprej.indebcre = IF   aux_tpdedocs = 2 THEN
                                               "A" 
                                          ELSE
                                          IF   aux_tpdedocs = 3 THEN
                                               "B" 
                                          ELSE
                                          IF   aux_tpdedocs = 4 THEN
                                               "C" 
                                          ELSE
                                          IF   aux_tpdedocs = 5 THEN
                                               "D" 
                                          ELSE
                                          IF   aux_tpdedocs = 6 THEN
                                               "E" 
                                          ELSE
                                               STRING(aux_tpdedocs)
                       craprej.cdcritic = 9
                       craprej.vldaviso = DEC(rel_cpfdesti).
                VALIDATE craprej.
                       
                NEXT TRANS_1.    
            END.

	   IF crapass.inpessoa = 1 THEN
	      DO:
		     FOR FIRST crapttl FIELDS(nrcpfcgc)
			                   WHERE crapttl.cdcooper = crapass.cdcooper AND
							         crapttl.nrdconta = crapass.nrdconta AND
									 crapttl.idseqttl = 2
									 NO-LOCK:

			   ASSIGN aux_nrcpfstl = crapttl.nrcpfcgc.

			 END.

			 FOR FIRST crapttl FIELDS(nrcpfcgc)
			                   WHERE crapttl.cdcooper = crapass.cdcooper AND
							         crapttl.nrdconta = crapass.nrdconta AND
									 crapttl.idseqttl = 3
									 NO-LOCK:

			   ASSIGN aux_nrcpfttl = crapttl.nrcpfcgc.

			 END.

		  END.

       IF   glb_cdcooper = 1 OR
            glb_cdcooper = 2 THEN
            DO:
                /* Critica apenas contas cadastradas no TCO */
                FIND FIRST craptco WHERE craptco.cdcopant = glb_cdcooper AND
                                         craptco.nrctaant = aux_nrdconta AND
                                         craptco.tpctatrf = 1            AND
                                         craptco.flgativo = TRUE
                                         NO-LOCK NO-ERROR.
        
                IF   AVAILABLE craptco THEN 
                     DO:
                         CREATE craprej.
                         ASSIGN craprej.dtrefere = aux_dtauxili
                                craprej.nrdconta = aux_nrdconta
                                craprej.dshistor = aux_nmdestin
                                craprej.nrdocmto = aux_nrdocmto 
                                craprej.vllanmto = aux_vllanmto
                                craprej.nrseqdig = aux_nrseqarq
                                craprej.cdpesqbb = aux_cdpesqbb
                                craprej.cdcooper = glb_cdcooper
              /* tipo de doc */ craprej.indebcre = IF   aux_tpdedocs = 2 THEN
                                                        "A" 
                                                   ELSE
                                                   IF   aux_tpdedocs = 3 THEN
                                                        "B" 
                                                   ELSE
                                                   IF   aux_tpdedocs = 4 THEN
                                                        "C" 
                                                   ELSE
                                                   IF   aux_tpdedocs = 5 THEN
                                                        "D" 
                                                   ELSE
                                                   IF   aux_tpdedocs = 6 THEN
                                                        "E" 
                                                   ELSE
                                                        STRING(aux_tpdedocs)
                                craprej.cdcritic = 999
                                craprej.vldaviso = DEC(rel_cpfdesti).
                         VALIDATE craprej.

                         NEXT TRANS_1.    
                     END.
            END.         
               
       IF   CAN-DO("2,4,5,6,7,8",STRING(crapass.cdsitdtl))   THEN
            DO:
                FIND FIRST craptrf WHERE craptrf.cdcooper = glb_cdcooper     AND
                                         craptrf.nrdconta = crapass.nrdconta AND
                                         craptrf.tptransa = 1 NO-LOCK NO-ERROR.

                IF   AVAILABLE craptrf THEN
                     aux_nrdconta = craptrf.nrsconta.
            END.

       IF   flg_nmarqdoc THEN
            DO:
                IF   INT(SUBSTR(aux_setlinha,105,2)) = 14 THEN
                     aux_cdhistor = 97.
                ELSE
                     IF   INT(SUBSTR(aux_setlinha,105,2)) = 50 AND
                          aux_tpdedocs = 2                     THEN
                          aux_cdhistor = 519.
                     ELSE
                          aux_cdhistor = 319.
                
                IF   SUBSTR(aux_setlinha,142,21) = "SUL AMERICA AETNA SEG" THEN
                     aux_cdhistor = 339. 
            END.
       ELSE
            ASSIGN aux_cdhistor = IF   flg_dpcheque THEN
                                       445
                                  ELSE 345.
            
       IF   aux_tpdedocs = 4 OR aux_tpdedocs = 6 OR aux_tpdedocs = 9 OR 
           (INT(SUBSTR(aux_setlinha,105,2)) = 50 AND aux_tpdedocs = 2) THEN
            DO:
                ASSIGN aux_cpfdesti = DECIMAL(SUBSTR(aux_setlinha,89,14)).
                IF  NOT ((aux_cpfdesti = crapass.nrcpfcgc)   OR
                         (aux_cpfdesti = aux_nrcpfstl)      OR
                         (aux_cpfdesti = aux_nrcpfttl))     THEN   
                         glb_cdcritic = 301.
            END.
            
       IF   aux_tpdedocs = 5 THEN
            DO:
                ASSIGN aux_cpfdesti = DECIMAL(SUBSTR(aux_setlinha,89,14)) 
                       aux_cpfremet = DECIMAL(SUBSTR(aux_setlinha,182,14)). 
              
                IF   aux_cpfdesti = aux_cpfremet THEN
                     DO:
                         IF   crapass.nrcpfcgc <> aux_cpfdesti  THEN
                              glb_cdcritic = 301.
                     END.
                ELSE
                     DO:   
                         IF   ((aux_cpfdesti = crapass.nrcpfcgc)   OR
                               (aux_cpfdesti = aux_nrcpfstl))      AND
                              ((aux_cpfremet = crapass.nrcpfcgc)   OR
                               (aux_cpfremet = aux_nrcpfstl))      THEN
                              .
                         ELSE     
                              glb_cdcritic = 301.   
                     END.
            END.
       
       IF   INT(SUBSTR(aux_setlinha,230,11)) > 0 THEN
            glb_cdcritic = 513.
             
       IF   glb_dtmvtolt >= 05/02/2012 THEN
            DO:
               /* IF   aux_cdhistor <> 519 THEN --comentado para cair todos nesta critica */
                     glb_cdcritic = 798.
            END.
       
       IF   glb_cdcritic > 0 THEN
            DO:
                CREATE craprej.
                ASSIGN craprej.dtrefere = aux_dtauxili
                       craprej.nrdconta = aux_nrdconta
                       craprej.nrdocmto = aux_nrdocmto 
                       craprej.vllanmto = aux_vllanmto
                       craprej.nrseqdig = aux_nrseqarq
                       craprej.cdcritic = glb_cdcritic
                       craprej.cdpesqbb = aux_cdpesqbb
                       glb_cdcritic     = 0
                       craprej.cdcooper = glb_cdcooper
                       craprej.vldaviso = DEC(rel_cpfdesti)
                       craprej.dshistor = IF   craprej.cdcritic = 301 THEN
                                               STRING(aux_nmdestin,"x(40)") +
                                               "CPF Remetente " + 
                                               STRING(aux_cpfremet) +
                                               " CPF Destinatario " +
                                               STRING(aux_cpfdesti)
                                          ELSE aux_nmdestin
     /* tipo de doc */ craprej.indebcre = IF   aux_tpdedocs = 2 THEN
                                               "A" 
                                          ELSE
                                          IF   aux_tpdedocs = 3 THEN
                                               "B" 
                                          ELSE
                                          IF   aux_tpdedocs = 4 THEN
                                               "C" 
                                          ELSE
                                          IF   aux_tpdedocs = 5 THEN
                                               "D" 
                                          ELSE
                                          IF   aux_tpdedocs = 6 THEN
                                               "E" 
                                          ELSE
                                               STRING(aux_tpdedocs).
                VALIDATE craprej.

                NEXT TRANS_1.    
            END.

       IF   aux_flgfirst   THEN
            DO:

               /* acessar tabela de lotes */
               
                FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                                   craptab.nmsistem = "CRED"        AND
                                   craptab.tptabela = "GENERI"      AND
                                   craptab.cdempres = 00            AND
                                   craptab.cdacesso = "NUMLOTEBCO"  AND
                                   craptab.tpregist = 001
                                   NO-LOCK NO-ERROR NO-WAIT.

                IF   NOT AVAILABLE craptab THEN
                     DO:
                         glb_cdcritic = 472.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").
                         UNDO TRANS_1, RETURN.
                     END.

                aux_nrdolot2 = INT(craptab.dstextab).

                DO WHILE TRUE:

                   IF   CAN-FIND(craplot WHERE 
                                         craplot.cdcooper = glb_cdcooper AND
                                         craplot.dtmvtolt = glb_dtmvtolt AND
                                         craplot.cdagenci = aux_cdagenci AND
                                         craplot.cdbccxlt = aux_cdbccxlt AND
                                         craplot.nrdolote = aux_nrdolot2
                                         USE-INDEX craplot1) THEN
                          aux_nrdolot2 = aux_nrdolot2 + 1.
                   ELSE
                          LEAVE.
          
                END.  /*  Fim do DO WHILE TRUE  */

                ASSIGN  aux_nrdolote = aux_nrdolot2.

                CREATE craplot.
                ASSIGN craplot.dtmvtolt = glb_dtmvtolt
                       craplot.cdagenci = aux_cdagenci
                       craplot.cdbccxlt = aux_cdbccxlt
                       craplot.nrdolote = aux_nrdolote
                       craplot.tplotmov = aux_tplotmov
                       craplot.cdcooper = glb_cdcooper
                       aux_flgfirst     = FALSE.
                VALIDATE craplot.
            END.
       ELSE
            DO:
                FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND
                                   craplot.dtmvtolt = glb_dtmvtolt   AND
                                   craplot.cdagenci = aux_cdagenci   AND
                                   craplot.cdbccxlt = aux_cdbccxlt   AND
                                   craplot.nrdolote = aux_nrdolote
                                   USE-INDEX craplot1 NO-ERROR.

                IF   NOT AVAILABLE craplot   THEN
                     DO:
                         glb_cdcritic = 60.
                         RUN fontes/critic.p.
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                           " - " + glb_cdprogra + "' --> '" +
                                           glb_dscritic + " BANCOOB - LOTE = "
                                           + STRING(aux_nrdolote,"999,999") +
                                           " >> log/proc_batch.log").
                         UNDO TRANS_1, RETURN.
                     END.
            END.

       IF   CAN-FIND(craplcm WHERE craplcm.cdcooper = glb_cdcooper   AND
                                   craplcm.dtmvtolt = glb_dtmvtolt   AND
                                   craplcm.cdagenci = aux_cdagenci   AND
                                   craplcm.cdbccxlt = aux_cdbccxlt   AND
                                   craplcm.nrdolote = aux_nrdolote   AND
                                   craplcm.nrdctabb = aux_nrdconta   AND
                                   craplcm.nrdocmto = aux_nrdocmto
                                   USE-INDEX craplcm1)   THEN
            DO:
                glb_cdcritic = 92.
                RUN fontes/critic.p.
                UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " + 
                                  glb_cdprogra + "' --> '" + glb_dscritic +
                                  " >> log/proc_batch.log").
                glb_cdcritic = 0.
                UNDO TRANS_1, RETURN.
            END.    

       IF   glb_cdcritic > 0 THEN
            DO:
                CREATE craprej.
                ASSIGN craprej.dtrefere = aux_dtauxili
                       craprej.nrdconta = aux_nrdconta
                       craprej.nrdocmto = aux_nrdocmto 
                       craprej.vllanmto = aux_vllanmto
                       craprej.nrseqdig = aux_nrseqarq
                       craprej.cdpesqbb = aux_cdpesqbb
                       craprej.cdcritic = glb_cdcritic
                       craprej.dshistor = aux_nmdestin
                       craprej.cdcooper = glb_cdcooper
                       craprej.vldaviso = DEC(rel_cpfdesti)
     /* tipo de doc */ craprej.indebcre = IF   aux_tpdedocs = 2 THEN
                                               "A" 
                                          ELSE
                                          IF   aux_tpdedocs = 3 THEN
                                               "B" 
                                          ELSE
                                          IF   aux_tpdedocs = 4 THEN
                                               "C" 
                                          ELSE
                                          IF   aux_tpdedocs = 5 THEN
                                               "D"
                                          ELSE
                                          IF   aux_tpdedocs = 6 THEN
                                               "E"
                                          ELSE     
                                               STRING(aux_tpdedocs)
                       glb_cdcritic = 0.
                VALIDATE craprej.
                                        
                NEXT TRANS_1.    
            END.
       ELSE
            DO:
                CREATE craplcm.
                ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                       craplcm.cdagenci = craplot.cdagenci
                       craplcm.cdbccxlt = craplot.cdbccxlt
                       craplcm.nrdolote = craplot.nrdolote
                       craplcm.nrdconta = aux_nrdconta
                       craplcm.nrdctabb = aux_nrdconta
                       craplcm.nrdctitg = STRING(aux_nrdconta,"99999999")
                       craplcm.nrdocmto = aux_nrdocmto
                       craplcm.cdhistor = aux_cdhistor
                       craplcm.vllanmto = aux_vllanmto
                       craplcm.nrseqdig = aux_nrseqarq
                       craplcm.cdpesqbb = aux_cdpeslcm
                       craplcm.cdcooper = glb_cdcooper

                       craplcm.cdbanchq = aux_cdbanchq 
                       craplcm.cdcmpchq = aux_cdcmpchq
                       craplcm.cdagechq = aux_cdagechq 
                       craplcm.nrctachq = aux_nrctachq
                       craplcm.sqlotchq = aux_sqlotchq
              
                       craplot.qtinfoln = craplot.qtinfoln + 1
                       craplot.qtcompln = craplot.qtcompln + 1
                       craplot.vlinfocr = craplot.vlinfocr + aux_vllanmto
                       craplot.vlcompcr = craplot.vlcompcr + aux_vllanmto
                       craplot.nrseqdig = craplcm.nrseqdig

                       aux_qtcompln     = aux_qtcompln + 1
                       aux_vlcompcr     = aux_vlcompcr + aux_vllanmto

                       glb_cdcritic = 0.
                VALIDATE craplcm.
            
                IF   flg_dpcheque   THEN
                     DO:
                         CREATE crapdpb.
                         ASSIGN crapdpb.dtmvtolt = craplot.dtmvtolt
                                crapdpb.cdagenci = craplot.cdagenci
                                crapdpb.cdbccxlt = craplot.cdbccxlt
                                crapdpb.nrdolote = craplot.nrdolote
                                crapdpb.nrdconta = craplcm.nrdconta
                                crapdpb.dtliblan = aux_dtlibera
                                crapdpb.cdhistor = craplcm.cdhistor
                                crapdpb.nrdocmto = craplcm.nrdocmto
                                crapdpb.vllanmto = craplcm.vllanmto
                                crapdpb.inlibera = 1
                                crapdpb.cdcooper = glb_cdcooper.
                         VALIDATE crapdpb.
                     END.
            END.           
            
       CREATE craprej.
       ASSIGN craprej.dtrefere = aux_dtauxili
              craprej.nrdconta = aux_nrdconta
              craprej.nrdocmto = aux_nrdocmto 
              craprej.vllanmto = aux_vllanmto
              craprej.nrseqdig = aux_nrseqarq
              craprej.cdpesqbb = aux_cdpesqbb
              craprej.dshistor = aux_nmdestin
              craprej.cdcooper = glb_cdcooper
              craprej.vldaviso = DEC(rel_cpfdesti)
              craprej.indebcre = IF   aux_tpdedocs = 2 THEN  /* tipo de doc */
                                      "A"
                                 ELSE
                                 IF   aux_tpdedocs = 3 THEN
                                      "B"
                                 ELSE     
                                 IF   aux_tpdedocs = 4 THEN
                                      "C"
                                 ELSE
                                 IF   aux_tpdedocs = 5 THEN
                                      "D"
                                 ELSE
                                 IF   aux_tpdedocs = 6 THEN
                                      "E" 
                                 ELSE
                                      STRING(aux_tpdedocs)
              craprej.cdcritic = glb_cdcritic
              glb_cdcritic     = 0.
       VALIDATE craprej.

       DO WHILE TRUE:

          FIND crapres WHERE crapres.cdcooper = glb_cdcooper     AND
                             crapres.cdprogra = glb_cdprogra
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

          IF   NOT AVAILABLE crapres   THEN
               IF   LOCKED crapres   THEN
                    DO:
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
               ELSE
                    DO:
                        glb_cdcritic = 151.
                        RUN fontes/critic.p.
                        UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                          " - " + glb_cdprogra + "' --> '" +
                                          glb_dscritic +
                                          " >> log/proc_batch.log").
                        UNDO TRANS_1, RETURN.
                    END.

          LEAVE.

       END.  /*  Fim do DO WHILE TRUE  */

       crapres.nrdconta = aux_nrseqarq.

    END. /* FIM do DO WHILE TRUE TRANSACTION */

    INPUT STREAM str_2 CLOSE.

    UNIX SILENT VALUE("mv " + tab_nmarqdoc[i] + " salvar").
    UNIX SILENT VALUE("rm " + tab_nmarqdoc[i] + ".q 2> /dev/null").

    ASSIGN tot_qtregrec = 0    tot_qtregint = 0      tot_qtregrej = 0
           tot_vlregrec = 0    tot_vlregint = 0      tot_vlregrej = 0
           glb_cdcritic = 0    aux_flgfirst = TRUE.

    { includes/cabrel132_1.i }

    ASSIGN aux_nmarqimp = "rl/crrl205_" + STRING(i,"99") +  ".lst"
           glb_cdempres = 11
           aux_nmarquiv = tab_nmarqdoc[i].

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    DISPLAY STREAM str_1   aux_nmarquiv    glb_dtmvtolt    aux_cdagenci
                           aux_cdbccxlt    aux_nrdolote    aux_tplotmov    
                           WITH FRAME f_cab.

    FOR EACH craprej WHERE  craprej.cdcooper = glb_cdcooper  AND
                            craprej.dtrefere = aux_dtauxili
                            NO-LOCK BY craprej.nrdconta :
               
        IF   LINE-COUNTER(str_1) > 82 THEN
             DO:
                 PAGE STREAM str_1.
         
                 DISPLAY STREAM str_1 aux_nmarquiv  glb_dtmvtolt  aux_cdagenci
                                      aux_cdbccxlt  aux_nrdolote  aux_tplotmov
                                      WITH FRAME f_cab.
             END.
                     
        IF   craprej.nrdconta < 999999999  THEN
             DO:
                 glb_dscritic = "".
                 
                 IF   craprej.cdcritic > 0 THEN
                      DO:
                          aux_flgrejei = TRUE.
                          
                          glb_cdcritic = craprej.cdcritic.

                          IF   glb_cdcritic = 999 THEN
                               DO:
                                   IF   glb_cdcooper = 2 THEN
                                        glb_dscritic = 
                                           "Rejeitado - Associado VIACREDI".
                                   ELSE
                                        glb_dscritic = 
                                           "Rejeitado - Associado ALTOVALE".
                               END.
                          ELSE
                              RUN fontes/critic.p.

                          ASSIGN tot_qtregrej = tot_qtregrej + 1        
                                 tot_vlregrej = tot_vlregrej + craprej.vllanmto.

                      END.
                      
                 RUN p_monta_cpfcgc.     
                      
                 DISPLAY STREAM str_1  craprej.nrdconta  craprej.dshistor
                                       craprej.indebcre  craprej.nrdocmto  
                                       craprej.cdpesqbb  craprej.vllanmto 
                                       glb_dscritic      rel_dscpfcgc
                                       WITH FRAME f_lanctos.
                         
                 DOWN STREAM str_1 WITH FRAME f_lanctos.        
                
                 IF   SUBSTRING(craprej.dshistor,40,20) <> "" THEN
                      DO:
                          aux_dsinform = SUBSTRING(craprej.dshistor,41,60).
                          DISPLAY STREAM str_1 aux_dsinform 
                                         WITH FRAME f_dados.
                          DOWN STREAM str_1 WITH FRAME f_dados.
                      END.
             END.
        ELSE
             DO:
                 
                 ASSIGN tot_qtregrec = craprej.nrseqdig - 2  
                        tot_qtregint = aux_qtcompln
                        tot_vlregrec = craprej.vllanmto
                        tot_vlregint = aux_vlcompcr.
                        
                 DISPLAY STREAM str_1  tot_qtregrec  tot_qtregint  tot_qtregrej
                                       tot_vlregrec  tot_vlregint  tot_vlregrej
                                       WITH FRAME f_total. 
             END.
             
    END.


    OUTPUT STREAM str_1 CLOSE.

    glb_cdcritic = IF aux_flgrejei THEN 191 ELSE 190.
    RUN fontes/critic.p.
    UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                      " - " + glb_cdprogra + "' --> '" +
                      glb_dscritic + "' --> '" +  tab_nmarqdoc[i] +
                      " >> log/proc_batch.log").

    ASSIGN glb_nrcopias = 1
           glb_nmformul = ""
           glb_nmarqimp = aux_nmarqimp
           glb_cdcritic = 0.

    RUN fontes/imprim.p.

    IF   glb_cdcooper = 1 OR
         glb_cdcooper = 2 THEN
         RUN gera_relatorio_205_99.
         
    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                           craprej.dtrefere = aux_dtauxili
                           EXCLUSIVE-LOCK TRANSACTION:
     
        DELETE craprej.
    END. 
            
END.

RUN fontes/fimprg.p.

/* .......................................................................... */

PROCEDURE p_monta_cpfcgc:

    ASSIGN glb_nrcalcul = craprej.vldaviso.
         
    IF   LENGTH(STRING(craprej.vldaviso)) > 11   THEN
         DO:
             ASSIGN rel_dscpfcgc = STRING(craprej.vldaviso,"99999999999999")
                    rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").

             RETURN.
         END.
    
    RUN fontes/cpffun.p.
           
    IF   glb_stsnrcal   THEN
         ASSIGN rel_dscpfcgc = STRING(craprej.vldaviso,"99999999999")
                rel_dscpfcgc = STRING(rel_dscpfcgc,"xxx.xxx.xxx-xx").
    ELSE
         ASSIGN rel_dscpfcgc = STRING(craprej.vldaviso,"99999999999999")
                rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
                     
END PROCEDURE.

/* .......................................................................... */

PROCEDURE gera_relatorio_205_99:

    DEF VAR h-b1wgen0011 AS HANDLE NO-UNDO.

    /**** TCO - IMPRESSAO DO RELAT  CRRL205_99 - CRITICA 999 ****/
    ASSIGN tot_qtregrec = 0    
           tot_qtregint = 0      
           tot_qtregrej = 0
           tot_vlregrec = 0    
           tot_vlregint = 0      
           tot_vlregrej = 0
           glb_cdcritic = 0    
           aux_flgfirst = TRUE   
           aux_flgrejei = FALSE.

    ASSIGN aux_nmarqimp = "crrl205_999_" + STRING(i,"99") + ".lst"
           glb_cdempres = 11
           aux_nmarquiv = tab_nmarqdoc[i].

    OUTPUT STREAM str_1 TO VALUE("rl/" + aux_nmarqimp) PAGED PAGE-SIZE 84.

    VIEW STREAM str_1 FRAME f_cabrel132_1.

    DISPLAY STREAM str_1   aux_nmarquiv    glb_dtmvtolt    aux_cdagenci
                           aux_cdbccxlt    aux_nrdolote    aux_tplotmov    
                           WITH FRAME f_cab.

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                           craprej.dtrefere = aux_dtauxili  AND
                           craprej.cdcritic = 999
                           NO-LOCK BY craprej.nrdconta :
               
        IF   LINE-COUNTER(str_1) > 82 THEN
             DO:
                 PAGE STREAM str_1.
         
                 DISPLAY STREAM str_1 aux_nmarquiv  glb_dtmvtolt  aux_cdagenci
                                      aux_cdbccxlt  aux_nrdolote  aux_tplotmov
                                      WITH FRAME f_cab.
             END.

        IF   glb_cdcooper = 2 THEN
             ASSIGN glb_dscritic = "Rejeitado - Associado VIACREDI".
        ELSE
             ASSIGN glb_dscritic = "Rejeitado - Associado ALTOVALE".
               
        ASSIGN tot_qtregrej = tot_qtregrej + 1        
               tot_vlregrej = tot_vlregrej + craprej.vllanmto.

        RUN p_monta_cpfcgc.     
                  
        DISPLAY STREAM str_1  craprej.nrdconta  craprej.dshistor
                              craprej.indebcre  craprej.nrdocmto  
                              craprej.cdpesqbb  craprej.vllanmto 
                              glb_dscritic      rel_dscpfcgc
                              WITH FRAME f_lanctos.
                     
        DOWN STREAM str_1 WITH FRAME f_lanctos.        
            
        IF   SUBSTRING(craprej.dshistor,40,20) <> "" THEN
             DO:
                 aux_dsinform = SUBSTRING(craprej.dshistor,41,60).
         
                 DISPLAY STREAM str_1 aux_dsinform WITH FRAME f_dados.

                 DOWN STREAM str_1 WITH FRAME f_dados.
             END.
    END.

    DISPLAY STREAM str_1  tot_qtregrec  tot_qtregint  tot_qtregrej
                          tot_vlregrec  tot_vlregint  tot_vlregrej
                          WITH FRAME f_total.

    FOR EACH craprej WHERE craprej.cdcooper = glb_cdcooper  AND
                           craprej.dtrefere = aux_dtauxili
                           EXCLUSIVE-LOCK TRANSACTION:

        DELETE craprej.
    END.

    OUTPUT STREAM str_1 CLOSE.
             
    ASSIGN glb_nrcopias = 1
           glb_nmformul = ""
           glb_nmarqimp = "rl/" + aux_nmarqimp
           glb_cdcritic = 0.
            
    RUN fontes/imprim.p.
     
    RUN sistema/generico/procedures/b1wgen0011.p 
        PERSISTENT SET h-b1wgen0011.

    IF   NOT VALID-HANDLE (h-b1wgen0011)  THEN
         DO:
             UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                               glb_cdprogra + "' --> '" +
                               "Handle invalido para h-b1wgen0011." +
                               " >> log/proc_batch.log").
             QUIT.          
         END.

    RUN converte_arquivo IN h-b1wgen0011(INPUT glb_cdcooper,
                                         INPUT "rl/" + aux_nmarqimp,
                                         INPUT aux_nmarqimp).

    IF   glb_cdcooper = 2 THEN
         RUN enviar_email IN h-b1wgen0011(
                                     INPUT glb_cdcooper,
                                     INPUT "crps252",
                                     INPUT "suporte@viacredi.coop.br," +
                                           "compe@cecred.coop.br", 
                                     INPUT "Relatorio Integracao " +
                                           "DOCs Bancoob",
                                     INPUT aux_nmarqimp,
                                     INPUT FALSE).
    ELSE
    IF   glb_cdcooper = 1 THEN
         RUN enviar_email IN h-b1wgen0011(
                                     INPUT glb_cdcooper,
                                     INPUT "crps252",
                                     INPUT "compe@cecred.coop.br," +
                                           "suporte@viacredialtovale.coop.br",
                                     INPUT "Relatorio Integracao " +
                                           "DOCs Bancoob",
                                     INPUT aux_nmarqimp,
                                     INPUT FALSE).
    
    DELETE PROCEDURE h-b1wgen0011.

END PROCEDURE.

/* .......................................................................... */
