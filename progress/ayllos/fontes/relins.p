/* .............................................................................

   Programa: Fontes/relins.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego/Guilherme/Gabriel
   Data    : Outubro/2007                    Ultima Atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela RELINS - Impressao de Relatorios do INSS
   
  Alteracoes : 02/09/2008 - Acerto no FORMAT de Totais em alguns relatorios
                            (Diego);
                          - Ajuste no relatorio 465 (Evandro).
               
               05/11/2008 - Faz impressao dos relatorios na propria tela na
                            opcao "I", nao necessitando utilizar a tela GERIMP
                            para imprimir(Elton). 
               
               22/03/2010 - Incluido no programa as opcoes 000 e 553 (Gati)
               
               15/09/2010 - Substituido crapcop.nmrescop por crapcop.dsdircop na
                            leitura e gravacao dos arquivos (Elton).
                            
               25/01/2011 - Incluido a coluna "PAC Pagto" na procedure gera_470,
                            especificando o PAC onde foi retirado o beneficio
                            (Vitor)
                                        
               11/02/2011 - Criado a opcao 587 (Adriano).    
               
               23/12/2011 - Ajuste na totalizacao dos valores no relatorio
                            465 (Adriano).                     
                            
               14/06/2012 - Incluida coluna "Beneficio" rel 463 (Tiago).
               
               19/06/2012 - Incluido filtro no rel 463 - tpmepgto (Tiago).
               
               14/01/2013 - Criado a opcao 632 "Prova de Vida" (Adriano).
                            
               30/01/2013 - Alterada a procedure 'gera_587' para enquadrar 
                            consultas dentro do escopo da crapcei (Lucas).
                            
               06/03/2013 - Alterada a procedure "gera_632 e gera_463" para 
                            exportar novo arquivo em excel no diretorio 
                             /micros (David Kruger).  
                             
               12/03/2013 - Alteracao na procedure "gera_000" para gerar novo
                            relatorio no diretorio /micros (David Kruger).           
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
                            
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)   
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
 .......................................................................... */

{ includes/var_online.i}


DEF STREAM str_1.
DEF STREAM str_2.

/* variaveis para includes/impressao.i */
DEF VAR par_flgrodar AS LOGICAL                                      NO-UNDO.
DEF VAR par_flgfirst AS LOGICAL                                      NO-UNDO.
DEF VAR par_flgcance AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.
   

/* variaveis para includes/cabrel080_1.i  e  includes/cabrel132_1.i*/
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["","","","",""]         NO-UNDO.
DEF VAR rel_nmarqimp AS CHAR                                         NO-UNDO.

DEF VAR tel_cddopcao AS CHAR    FORMAT "!(1)" INIT  "T"              NO-UNDO.
DEF VAR tel_cdagenci AS INT     FORMAT "zz9"                         NO-UNDO.
DEF VAR tel_dtinicio AS DATE    FORMAT "99/99/9999"                  NO-UNDO.
DEF VAR tel_datfinal AS DATE    FORMAT "99/99/9999"                  NO-UNDO.
DEF VAR tel_benefici AS CHAR    FORMAT "x(1)" INITIAL "T"            NO-UNDO.
DEF VAR tel_nmrecben AS CHAR    FORMAT "x(40)"                       NO-UNDO.
DEF VAR tel_nrprocur LIKE crapcei.nrrecben                           NO-UNDO.
DEF VAR tel_dtcomext AS CHAR    FORMAT "99"                          NO-UNDO.
DEF VAR tel_dtcomex2 AS INT     FORMAT "9999"                        NO-UNDO.

DEF VAR aux_dtcomext AS CHAR    FORMAT "99/9999"                     NO-UNDO.
DEF VAR aux_dtinicio AS DATE    FORMAT "99/99/9999"                  NO-UNDO.
DEF VAR aux_datfinal AS DATE    FORMAT "99/99/9999"                  NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR    FORMAT "x(40)"                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_arqvazio AS LOGICAL                                      NO-UNDO.
DEF VAR aux_qtrelato AS INT                                          NO-UNDO.
DEF VAR aux_flgfirst AS LOGICAL INIT FALSE                           NO-UNDO.
DEF VAR aux_nmagenci AS CHAR                                         NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_relatori AS CHAR    EXTENT  6                            NO-UNDO.
DEF VAR aux_cdagefim LIKE crapage.cdagenci                           NO-UNDO.
DEF VAR aux_dtultpag AS DATE    FORMAT 99/99/9999                    NO-UNDO.
DEF VAR aux_flgextra AS LOG                                          NO-UNDO.
DEF VAR aux_benefici AS INTE                                         NO-UNDO.

DEF VAR aux_relat463 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat464 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat465 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat467 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat468 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat470 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat553 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat587 AS LOGICAL                                      NO-UNDO.
DEF VAR aux_relat632 AS LOGICAL                                      NO-UNDO.

DEF VAR reg_cddopcao AS CHAR EXTENT 10 INIT 
        ["000","463","464","465","467","468","470","553,587,632"] NO-UNDO.
                        
DEF VAR reg_dsdopcao AS CHAR EXTENT 10 INIT 
                     ["000 - Arquivo de Beneficiarios       ",
                      "463 - Beneficiarios do INSS          ",
                      "464 - Previsao Detalhada Pagamentos  ",
                      "465 - Conciliacao de Creditos        ",
                      "467 - Ultimas Alteracoes Solicitadas ",
                      "468 - Previsao de Pagamentos         ",
                      "470 - Creditos Pagos                 ",
                      "553 - Registro de solicit. de 2 via  ",
                      "587 - Demonstrativo de Credito       ",
                      "632 - Prova de Vida"]  NO-UNDO.


FORM " Selecione o relatorio:"
     SKIP(1)
     reg_dsdopcao[1]  FORMAT "x(37)" AT 2 reg_dsdopcao[2]  FORMAT "x(37)" AT 41
     SKIP(1)
     reg_dsdopcao[3]  FORMAT "x(37)" AT 2 reg_dsdopcao[4]  FORMAT "x(37)" AT 41
     SKIP(1)
     reg_dsdopcao[5]  FORMAT "x(37)" AT 2 reg_dsdopcao[6]  FORMAT "x(37)" AT 41
     SKIP(1)
     reg_dsdopcao[7]  FORMAT "x(37)" AT 2 reg_dsdopcao[8]  FORMAT "x(37)" AT 41
     SKIP(1)
     reg_dsdopcao[9]  FORMAT "x(37)" AT 2 reg_dsdopcao[10] FORMAT "X(37)" AT 41
     WITH ROW 8 COLUMN 2 NO-BOX NO-LABELS OVERLAY FRAME f_regua.
                          
FORM SKIP(1)
     tel_cdagenci AT 11 FORMAT "zz9"  LABEL "PA"
            HELP "Informe o numero do PA ou pressione <ENTER> p/ todos."
     tel_benefici   AT 8 LABEL "Beneficiario"
            HELP "(T)-Todos, (C)-Credito em Conta, (R)-Recibo/Cartao"
            VALIDATE(CAN-DO("T,C,R",tel_benefici),"Opcao invalida.")    
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS OVERLAY WIDTH 30
     TITLE " Imprimir " FRAME f_visrel_463.
                                
FORM SKIP(1)
     tel_cdagenci    AT 9 FORMAT "zz9" LABEL "PA"
            HELP "Informe o numero do PA ou pressione <ENTER> p/ todos."
     SKIP(1)
     "Data inicial:" AT 2  tel_dtinicio FORMAT "99/99/9999"
     HELP "Informe a Data Inicial."
     VALIDATE (tel_dtinicio <> ?, "Informe a Data Inicial da consulta.")
     "Data final:"             tel_datfinal FORMAT "99/99/9999"
     HELP "Informe a Data Final."
     VALIDATE (tel_datfinal <> ?, "Informe a Data Final da consulta.")
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABEL OVERLAY WIDTH 51
     TITLE " Imprimir " FRAME f_visrel_467.

FORM SKIP(1)
     tel_nrprocur AT 2  LABEL "NB/NIT"
           HELP "Informe o NB ou o NIT do beneficiario."

     tel_cdagenci AT 33 FORMAT "zz9" LABEL "PA"
     VALIDATE(CAN-FIND(crapage WHERE crapage.cdcooper = glb_cdcooper AND
                                     crapage.cdagenci = tel_cdagenci) OR
                                     tel_cdagenci = 0, 
                                     "962 - PA nao cadastrado.")
     HELP "Informe o PA ou '0' para todos."
     SKIP(1)
     tel_nmrecben AT 2 LABEL "Nome"  
           HELP "Informe o nome do beneficiario ou pressione <ENTER> p/ listar."
     SKIP(1)
     tel_dtcomext LABEL "Competencia" AUTO-RETURN AT 2
     VALIDATE(tel_dtcomext <> ?, "Mes nao informado.")
     HELP "Informe o mês e ano para impressão/visualização do extrato."
     "/" AT 17
     tel_dtcomex2 AUTO-RETURN AT 18
     VALIDATE(tel_dtcomex2 <> 0, "Ano nao informado.")
     HELP "Informe o mês e ano para impressão/visualização do extrato."
     WITH ROW 6 CENTERED SIDE-LABELS NO-LABEL OVERLAY WIDTH 60 
     TITLE "Demonstrativo de credito de beneficio" FRAME f_visrel_587.
     

FORM SKIP(1)
     tel_cdagenci    AT 9 FORMAT "zz9" LABEL "PA"
     HELP "Informe o numero do PA ou pressione <ENTER> p/ todos."
     SKIP(1)
     tel_benefici   AT 8 LABEL "Beneficiario"
     HELP "(T)-Todos, (C)-Credito em Conta, (R)-Recibo/Cartao"
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABEL OVERLAY WIDTH 51
     TITLE " Gerar Arquivo " FRAME f_visrel_000.


FORM SKIP(1)
     tel_cdagenci    AT 13 FORMAT "zz9" LABEL "PA"
     HELP "Informe o numero do PA ou pressione <ENTER> p/ todos."
     SKIP(1)
     WITH ROW 10 CENTERED SIDE-LABELS NO-LABEL OVERLAY WIDTH 30
     TITLE " Gerar Relatorio " FRAME f_visrel_632.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.


DEF QUERY q_nome FOR crapcbi.

DEF BROWSE b_nome QUERY q_nome
    DISP crapcbi.nmrecben COLUMN-LABEL "Beneficiario"
         (IF crapcbi.nrrecben = 0 THEN
             crapcbi.nrbenefi ELSE
             crapcbi.nrrecben) COLUMN-LABEL "NB/NIT" FORMAT "zzzzzzzzz99"
          crapcbi.cdagenci COLUMN-LABEL "PA"
          WITH 4 DOWN WIDTH 48 NO-BOX SCROLLBAR-VERTICAL.

DEF FRAME f_nome
          b_nome
    HELP "Pressione <ENTER> p/ selecionar ou <SETAS> p/ navegar."         
    WITH CENTERED OVERLAY ROW 14 TITLE "Beneficiario".


DEF TEMP-TABLE tt-craplei
          FIELD cdmovext LIKE crapmei.cdmovext
          FIELD dsmovext AS CHAR FORMAT "x(32)"
          FIELD vllanmto LIKE craplei.vllanmto.

DEF TEMP-TABLE tt-prova-vida NO-UNDO
    FIELD cdcooper LIKE crapcbi.cdcooper
    FIELD cdagenci LIKE crapcbi.cdagenci
    FIELD nrcpfcgc AS CHAR
    FIELD nrdconta LIKE crapttl.nrdconta
    FIELD nmrecben LIKE crapcbi.nmrecben
    FIELD nrbenefi LIKE crapcbi.nrbenefi
    FIELD dsbenefi AS CHAR
    FIELD nrtelefo AS CHAR
    FIELD dsendben LIKE crapcbi.dsendben
    FIELD nmbairro LIKE crapcbi.nmbairro
    FIELD nrcepend LIKE crapcbi.nrcepend
    FIELD vlliqcre LIKE craplbi.vlliqcre
    FIELD dtcompvi LIKE crapcbi.dtcompvi
    FIELD dscsitua AS CHAR
    FIELD tpbloque AS INT.


ON RETURN OF b_nome IN FRAME f_nome
   DO:              
       DISABLE b_nome WITH FRAME f_nome.
       HIDE FRAME f_nome.
  
       ENABLE b_nome WITH FRAME f_nome.
       
       PAUSE 0.

       APPLY "ENTRY" TO b_nome IN FRAME f_nome.
       APPLY "END-ERROR" TO b_nome IN FRAME f_nome.
       
   END. /* Fim do ON ENTER */

         
ON VALUE-CHANGED, ENTRY OF b_nome
    DO:
       ASSIGN tel_cdagenci = crapcbi.cdagenci
              tel_nmrecben = crapcbi.nmrecben
              tel_nrprocur = (IF crapcbi.nrrecben <> 0 THEN
                                 crapcbi.nrrecben ELSE
                                 crapcbi.nrbenefi).

       DISPLAY tel_cdagenci
               tel_nmrecben
               tel_nrprocur
               WITH FRAME f_visrel_587.
               
              
    END. /* Fim do ON VALEU-CHANGED */

           
VIEW FRAME f_moldura.
PAUSE(0).
  
ASSIGN glb_cddopcao = "C".
                          
  
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
   VIEW FRAME f_regua.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN    /* F4 OU FIM  */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "RELINS" THEN
                 DO:
                     HIDE FRAME f_visrel_587.
                     HIDE FRAME f_regua.
                     RETURN.
                 END.
            ELSE
               NEXT.
        END. 
   
   PAUSE 0.   
  
   DISPLAY reg_dsdopcao[1] reg_dsdopcao[2] reg_dsdopcao[3] reg_dsdopcao[4]
           reg_dsdopcao[5] reg_dsdopcao[6] reg_dsdopcao[7] reg_dsdopcao[8]
           reg_dsdopcao[9] reg_dsdopcao[10]
           WITH FRAME f_regua.
    
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
      /* Somente para marcar a opcao escolhida */
      CHOOSE FIELD reg_dsdopcao[1] reg_dsdopcao[2] reg_dsdopcao[3]
                   reg_dsdopcao[4] reg_dsdopcao[5] reg_dsdopcao[6]
                   reg_dsdopcao[7] reg_dsdopcao[8] reg_dsdopcao[9]
                   reg_dsdopcao[10]
                   WITH FRAME f_regua.
         
      { includes/acesso.i }
      
      ASSIGN rel_nmarqimp = ""
             tel_cdagenci = 0
             aux_relat463 = FALSE
             aux_relat464 = FALSE
             aux_relat465 = FALSE
             aux_relat467 = FALSE
             aux_relat468 = FALSE
             aux_relat470 = FALSE
             aux_relat553 = FALSE
             aux_relat587 = FALSE
             aux_relat632 = FALSE.

      IF   FRAME-VALUE = reg_dsdopcao[1] THEN
          DO:
              
              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                   RETURN-VALUE = "NOK"  THEN
                   NEXT.
              
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
                 UPDATE tel_cdagenci tel_benefici
                        WITH FRAME f_visrel_000.
                                    
                 RUN gera_000 (OUTPUT rel_nmarqimp).
                 
                 LEAVE.
              
              END.
              
              HIDE FRAME f_visrel_000  NO-PAUSE.       
          END.   
      ELSE
      IF   FRAME-VALUE = reg_dsdopcao[2]  THEN
           DO:
               RUN opcao.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                    RETURN-VALUE = "NOK"  THEN
                    NEXT.                   

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                   UPDATE tel_cdagenci tel_benefici 
                       WITH FRAME f_visrel_463.
                   
                   IF   tel_cdagenci = 0   THEN
                        aux_cdagefim = 999.
                   ELSE
                        aux_cdagefim = tel_cdagenci.
           
                   CASE tel_benefici:
                       WHEN "T" THEN
                           aux_benefici = 0.
                       WHEN "R" THEN
                           aux_benefici = 1.
                       WHEN "C" THEN
                           aux_benefici = 2.
                       OTHERWISE
                           aux_benefici = 0.
                   END CASE. 
            
                   MESSAGE "Aguarde... Gerando Arquivo.".

                   RUN gera_463 (INPUT glb_cdcooper,
                                 INPUT aux_benefici,
                                 OUTPUT rel_nmarqimp ).

                   HIDE MESSAGE NO-PAUSE.

                   IF RETURN-VALUE <> "OK" THEN
                      LEAVE.
                   
                   LEAVE.
                   
               END.
               
               HIDE FRAME f_visrel_463 NO-PAUSE. 
               
               ASSIGN aux_relat463 = TRUE.

            END.         
      ELSE
      IF   FRAME-VALUE = reg_dsdopcao[3]  THEN
           DO:
               RUN opcao.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                    RETURN-VALUE = "NOK"  THEN
                    NEXT.
                    
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  tel_cdagenci:HELP = "Informe o numero do PA.".
                  UPDATE tel_cdagenci tel_dtinicio tel_datfinal
                         WITH FRAME f_visrel_467.
                                            
                  IF   tel_cdagenci = 0   THEN
                       aux_cdagefim = 999.
                  ELSE
                       aux_cdagefim = tel_cdagenci.

                  RUN gera_464 (OUTPUT rel_nmarqimp).
                  
                  LEAVE.
                  
               END.
               
               HIDE FRAME f_visrel_467 NO-PAUSE.
               
               ASSIGN aux_relat464 = TRUE.
           END.
      ELSE
      IF   FRAME-VALUE = reg_dsdopcao[4] THEN
           DO:
               RUN opcao.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                    RETURN-VALUE = "NOK"  THEN
                    NEXT.
                                        
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               
                  UPDATE tel_cdagenci WITH FRAME f_visrel_463.

                  IF   tel_cdagenci = 0   THEN
                       aux_cdagefim = 999.
                  ELSE
                       aux_cdagefim = tel_cdagenci.

                  RUN gera_465 (OUTPUT rel_nmarqimp).
                  
                  LEAVE.
                  
               END.
               
               HIDE FRAME f_visrel_463 NO-PAUSE.
               
               ASSIGN aux_relat465 = TRUE.
           END.
      ELSE
      IF   FRAME-VALUE = reg_dsdopcao[5] THEN
           DO:
               RUN opcao.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                    RETURN-VALUE = "NOK"  THEN
                    NEXT.
                    
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_cdagenci tel_dtinicio tel_datfinal
                         WITH FRAME f_visrel_467.
                                            
                  IF   tel_cdagenci = 0   THEN
                       aux_cdagefim = 999.
                  ELSE
                       aux_cdagefim = tel_cdagenci.

                  RUN gera_467 (OUTPUT rel_nmarqimp).
                  
                  LEAVE.
               
               END.
               
               HIDE FRAME f_visrel_467 NO-PAUSE.
               
               ASSIGN aux_relat467 = TRUE.
           END.
      ELSE
      IF   FRAME-VALUE = reg_dsdopcao[6] THEN
           DO:
               RUN opcao.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                    RETURN-VALUE = "NOK"  THEN
                    NEXT.
                                        
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  UPDATE tel_cdagenci tel_dtinicio tel_datfinal
                         WITH FRAME f_visrel_467.
                                            
                  IF   tel_cdagenci = 0   THEN
                       aux_cdagefim = 999.
                  ELSE
                       aux_cdagefim = tel_cdagenci.

                  RUN gera_468 (OUTPUT rel_nmarqimp).  
                  
                  LEAVE.
                  
               END.
               
               HIDE FRAME f_visrel_467 NO-PAUSE.
               
               ASSIGN aux_relat468 = TRUE.
           END.
      ELSE
      IF   FRAME-VALUE = reg_dsdopcao[7] THEN
           DO:
               RUN opcao.
               
               IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                    RETURN-VALUE = "NOK"  THEN
                    NEXT.
                                        
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
                  UPDATE tel_cdagenci tel_dtinicio tel_datfinal
                         WITH FRAME f_visrel_467.
                                     
                  IF   tel_cdagenci = 0   THEN
                       aux_cdagefim = 999.
                  ELSE
                       aux_cdagefim = tel_cdagenci.

                  RUN gera_470 (OUTPUT rel_nmarqimp).
                  
                  LEAVE.
               
               END.
               
               HIDE FRAME f_visrel_467  NO-PAUSE.       
               
               ASSIGN aux_relat470 = TRUE.
           END.
     ELSE
     IF   FRAME-VALUE = reg_dsdopcao[8] THEN
          DO:
                
              RUN opcao.
              
              IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  OR 
                   RETURN-VALUE = "NOK"  THEN
                   NEXT.
                                       
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
                 /*UPDATE tel_cdagenci tel_benefici
                        WITH FRAME f_visrel_000.*/
                  
                 RUN gera_553 (OUTPUT rel_nmarqimp).
                 
                 LEAVE.
              
              END.
              
              /*HIDE FRAME f_visrel_000  NO-PAUSE.       */
              
              ASSIGN aux_relat553 = TRUE.

          END.
     ELSE
     IF   FRAME-VALUE = reg_dsdopcao[9] THEN
          DO:    
              CLEAR FRAME f_visrel_587 NO-PAUSE.
              
              ASSIGN tel_nrprocur = 0
                     tel_cdagenci = 0
                     tel_nmrecben = ""
                     tel_dtcomext = "00"
                     tel_dtcomex2 = 0
                     aux_flgextra = FALSE.


              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               
                 UPDATE tel_nrprocur
                        WITH FRAME f_visrel_587.
                
                 IF tel_nrprocur <> 0 THEN
                    DO:
                       FIND crapcbi WHERE crapcbi.cdcooper = glb_cdcooper AND
                                         (crapcbi.nrrecben = tel_nrprocur OR
                                          crapcbi.nrbenefi = tel_nrprocur)
                                          NO-LOCK NO-ERROR.
             
                       IF AVAIL crapcbi THEN
                          DO:
                             ASSIGN tel_nmrecben = crapcbi.nmrecben
                                    tel_cdagenci = crapcbi.cdagenci.
                                 
                             DISP tel_cdagenci
                                  tel_nmrecben
                                  WITH FRAME f_visrel_587.
                 
                          END.
                        ELSE 
                           DO:
                             MESSAGE "Beneficiario nao encontrado.".
                             PAUSE(2) NO-MESSAGE.
                             HIDE MESSAGE.
                             HIDE FRAME f_visrel_587.
                             RETURN.

                           END.

                    END.
                 ELSE
                    DO:
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                       
                          UPDATE tel_cdagenci
                                 WITH FRAME f_visrel_587.

                          LEAVE.

                       END.
                       

                       IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                          LEAVE.

                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                           UPDATE tel_nmrecben 
                                  WITH FRAME f_visrel_587.
                                  
                           OPEN QUERY q_nome 
                                FOR EACH crapcbi WHERE crapcbi.cdcooper = glb_cdcooper AND
                                                      (IF tel_cdagenci <> 0  THEN
                                                          crapcbi.cdagenci = tel_cdagenci ELSE
                                                          crapcbi.cdagenci > 0) AND
                                                       crapcbi.nmrecben MATCHES "*" +
                                                       tel_nmrecben + "*"
                                                       NO-LOCK BY crapcbi.nmrecben.
                                

                            LEAVE.

                       END.

                       IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                          LEAVE.
                        
                       
                       IF   NUM-RESULTS("q_nome") = 0   THEN
                            DO:
                               glb_cdcritic = 911.
                               RUN fontes/critic.p.
                               MESSAGE glb_dscritic.
                               glb_cdcritic = 0.
                               NEXT.
                            END.

                        
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                          
                          ENABLE b_nome WITH FRAME f_nome.
                          PAUSE 0.
                          WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                       
                          HIDE FRAME f_nome.
                          HIDE MESSAGE NO-PAUSE.
                          LEAVE.
                     
                       END.   

                       
                 
                    END.

                 CLOSE QUERY q_nome.

                 IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    LEAVE.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_dtcomext
                           tel_dtcomex2
                           WITH FRAME f_visrel_587.
           
                    IF INT(tel_dtcomext) > 12 THEN
                       DO:
                          MESSAGE "Mes invalido.".
                          PAUSE(2) NO-MESSAGE.
                          HIDE MESSAGE.
                          HIDE FRAME f_visrel_587.
                          RETURN "NOK".
           
                       END.
           
           
                     ASSIGN aux_dtcomext = STRING(tel_dtcomext,"99") + 
                                               STRING(tel_dtcomex2,"9999").
           
                     LEAVE.

                 END.


                 IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    LEAVE.

                 aux_flgextra = TRUE.

                 RUN opcao.
                 
                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                      
                    RUN gera_587 (INPUT tel_nrprocur,
                                  INPUT aux_dtcomext,
                                  OUTPUT rel_nmarqimp).

                    IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                       RETURN-VALUE = "NOK" THEN
                       RETURN.

                    LEAVE.
                    
                 END.
                 
                 ASSIGN aux_relat587 = TRUE.
                 
                 LEAVE. 
                                 
              END.

              HIDE FRAME f_visrel_587.

                   
          END.
     ELSE
     IF FRAME-VALUE = reg_dsdopcao[10] THEN
        DO:
           ASSIGN aux_flgextra = FALSE.

           RUN opcao.

           IF KEYFUNCTION(LAST-KEY) = "END-ERROR" OR 
              RETURN-VALUE <> "OK"                THEN
              NEXT.

           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE tel_cdagenci 
                     WITH FRAME f_visrel_632.

                               
              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                   
                 MESSAGE "Aguarde...Gerando relatorio e Arquivo.".

                 RUN gera_632 (INPUT glb_cdcooper,
                               INPUT 0, /*nrdcaixa*/
                               INPUT glb_cdagenci,
                               INPUT glb_cdoperad,
                               INPUT glb_nmdatela,
                               INPUT 1, /*ayllos*/
                               INPUT glb_dtmvtolt,
                               INPUT tel_cdagenci,
                               OUTPUT rel_nmarqimp).

                 HIDE MESSAGE NO-PAUSE.

                 IF RETURN-VALUE <> "OK" THEN
                    LEAVE.

                 LEAVE.
                 
              END.

              ASSIGN aux_relat632 = TRUE.

              LEAVE.

           END.

           HIDE FRAME f_visrel_632.

        END.

     IF rel_nmarqimp <> ""  THEN
        DO:        
            /* TRATAR ESTA VARIAVEL NA GERACAO DE TODOS OS RELATORIOS */
            IF aux_arqvazio  THEN
               DO:  
                   MESSAGE "ARQUIVO VAZIO.".
                   PAUSE 2 NO-MESSAGE.
                   NEXT.
               END.      
            
            IF tel_cddopcao = "T" THEN
               RUN fontes/visrel.p (INPUT rel_nmarqimp).
            ELSE
            IF tel_cddopcao = "I" THEN
               DO:
                   RUN proc_imprime.
                               
                   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        HIDE MESSAGE NO-PAUSE.
               END.    
            ELSE
               MESSAGE "Escolha invalida, tente novamente!".
        END.
          
   END.
                         
              
END.  /*  Fim do DO WHILE TRUE  */
               

PROCEDURE opcao.

   ASSIGN aux_arqvazio = TRUE
          tel_dtinicio = ?
          tel_datfinal = ?.
   
   IF aux_flgextra = TRUE THEN
      MESSAGE "Informe 'T' para visualizar  ou 'I' p/ imprimir o extrato: "
              UPDATE tel_cddopcao.
   ELSE
      MESSAGE "Informe 'T' p/ visualizar ou 'I' " +
              "p/ imprimir o relatorio: "
              UPDATE tel_cddopcao.
           
   IF   NOT(CAN-DO("T,I", tel_cddopcao))  THEN
        RETURN "NOK".
               
   HIDE MESSAGE NO-PAUSE.
   
   RETURN "OK".

END PROCEDURE.

PROCEDURE proc_imprime.

   IF   aux_relat463  THEN
        ASSIGN glb_nmformul = "80col".
   ELSE
   IF   aux_relat464  THEN
        ASSIGN glb_nmformul = "80col".
   ELSE
   IF   aux_relat465  THEN
        ASSIGN glb_nmformul = "132col".
   ELSE
   IF   aux_relat467  THEN
        ASSIGN glb_nmformul = "132col".
   ELSE
   IF   aux_relat468  THEN
        ASSIGN glb_nmformul = "80col".
   ELSE 
   IF   aux_relat470  THEN
        ASSIGN glb_nmformul = "132col".
   ELSE
   IF   aux_relat553  THEN
        ASSIGN glb_nmformul = "132col".
   ELSE 
   IF   aux_relat587  THEN
        ASSIGN glb_nmformul = "132col".
   ELSE
   IF   aux_relat632  THEN
        ASSIGN glb_nmformul = "234dh".
           
   ASSIGN glb_nrdevias = 1
          glb_nmarqimp = rel_nmarqimp.
  
   RUN fontes/imprim.p.

   IF   glb_inproces = 1 THEN
        UNIX SILENT VALUE("cp " + glb_nmarqimp + " rlnsv/").
   
   INPUT THROUGH basename `tty` NO-ECHO.
   SET aux_nmendter WITH FRAME f_terminal.
   INPUT CLOSE.        
   
   aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                         aux_nmendter.    
   
   ASSIGN aux_nmarqimp = glb_nmarqimp.
              
   /*somente para poder executar a includes/impressao.i */
   FIND FIRST crapass WHERE  crapass.cdcooper = glb_cdcooper 
                             NO-LOCK NO-ERROR.
   
   ASSIGN par_flgrodar = TRUE.

   { includes/impressao.i }
   
   /*     
   MESSAGE "ATENCAO! Verifique a GERIMP!".
   PAUSE(5) NO-MESSAGE.
   HIDE MESSAGE NO-PAUSE.
   */
END.


/******************************* RELATORIOS **********************************/

PROCEDURE gera_463:
                
   DEF INPUT  PARAM par_cdcooper AS INTE                                NO-UNDO.
   DEF INPUT  PARAM par_tpmepgto AS INTE                                NO-UNDO.
   DEF OUTPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.
   
   DEF VAR aux_totbenef AS INT                                          NO-UNDO.
   DEF VAR aux_dsbenefi AS CHAR                                         NO-UNDO.
   DEF VAR aux_nrbenefi AS DECI                                         NO-UNDO.
   DEF VAR aux_nmarqimp2 AS CHAR                                        NO-UNDO.
   DEF VAR h-b1wgen0091 AS HANDLE                                       NO-UNDO.

   FORM "PA: "  
        aux_nmagenci   FORMAT "x(30)" 
        SKIP(1)
        WITH NO-BOX NO-LABEL WIDTH 50 FRAME f_pac. 

   FORM "PA ;"  
        aux_nmagenci   FORMAT "x(30)" ";"
        SKIP(1)
        WITH NO-BOX NO-LABEL WIDTH 50 FRAME f_pac2. 


   FORM aux_nrbenefi     AT 1  LABEL "NB/NIT"              FORMAT "zzzzzzzzzz9"
        crapcbi.nmrecben AT 13 LABEL "Beneficiario"        FORMAT "x(25)"
        aux_dsbenefi     AT 40 LABEL "Beneficio"           FORMAT "x(20)"
        crapcbi.nrdconta AT 62 LABEL "Conta/dv" 
        crapcbi.dtcompvi AT 74 LABEL "Ult.Comp.Vida"       
        WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_recebedores.

   FORM aux_nrbenefi     COLUMN-LABEL "NB/NIT ;"        FORMAT "zzzzzzzzzz9" ";"
        crapcbi.nmrecben COLUMN-LABEL "Beneficiario ;"  FORMAT "x(25)"       ";"
        aux_dsbenefi     COLUMN-LABEL "Beneficio ;"     FORMAT "x(20)"       ";"
        crapcbi.nrdconta COLUMN-LABEL "Conta/dv ;"                           ";"
        crapcbi.dtcompvi COLUMN-LABEL "Ult.Comp.Vida ;"                      ";"
        WITH NO-BOX NO-UNDERLINE OVERLAY DOWN WIDTH 132 FRAME f_recebedores2. 

   FORM SKIP(1)
        "Total de beneficiarios:"
        aux_totbenef   AT 25   FORMAT "z,zz9"
        SKIP(1)
        WITH NO-BOX NO-LABEL SIDE-LABEL FRAME f_total.


  IF NOT VALID-HANDLE(h-b1wgen0091) THEN
     RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h-b1wgen0091.


  FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                     NO-LOCK NO-ERROR.

  IF NOT AVAIL crapcop THEN
     DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.
        HIDE MESSAGE NO-PAUSE.
        MESSAGE glb_dscritic.
        PAUSE(2) NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.

        IF VALID-HANDLE(h-b1wgen0091) THEN
           DELETE PROCEDURE h-b1wgen0091.
        
        ASSIGN glb_cdcritic = 0
               glb_dscritic = "".

        RETURN "NOK".
        
     END.
   
   ASSIGN par_nmarqimp = "rl/crrl463.lst".
          aux_nmarqimp2 = "/micros/" + crapcop.dsdircop + "/crrl463.lst". 
  
   /* Inicializa Variaveis Relatorio */
   ASSIGN glb_cdcritic    = 0 
          aux_arqvazio    = TRUE
          glb_cdempres    = 11
          glb_cdrelato[1] = 463.
             
   { includes/cabrel132_1.i } 
  
   IF VALID-HANDLE(h-b1wgen0091) THEN
      DELETE PROCEDURE h-b1wgen0091.

   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
   
   OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp2). 

   VIEW STREAM str_1 FRAME f_cabrel132_1.
    

   FOR EACH crapcbi WHERE crapcbi.cdcooper  = glb_cdcooper   AND
                          crapcbi.cdagenci >= tel_cdagenci   AND
                          crapcbi.cdagenci <= aux_cdagefim   AND
                          (crapcbi.tpmepgto = par_tpmepgto   OR 
                           par_tpmepgto     = 0)
                          NO-LOCK USE-INDEX crapcbi6
                          BREAK BY crapcbi.cdagenci:

       ASSIGN aux_totbenef = aux_totbenef + 1
              aux_arqvazio = FALSE.
      
       IF   FIRST-OF(crapcbi.cdagenci)  THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                                   crapage.cdagenci = crapcbi.cdagenci
                                   NO-LOCK NO-ERROR.
                
                IF   AVAIL crapage  THEN
                     ASSIGN aux_nmagenci = STRING(crapage.cdagenci,"zz9") + 
                                           " - " + crapage.nmresage.
                ELSE
                     ASSIGN aux_nmagenci = " ".
                
                DISPLAY STREAM str_1 aux_nmagenci WITH FRAME f_pac.
                
                DISPLAY STREAM str_2 aux_nmagenci WITH FRAME f_pac2. 
                                        
            END.
      
       FIND craptab WHERE craptab.cdcooper = 0                 AND
                          craptab.nmsistem = "CRED"            AND
                          craptab.tptabela = "CONFIG"          AND
                          craptab.cdempres = 0                 AND
                          craptab.cdacesso = "TPBENEINSS"      AND
                          craptab.tpregist = crapcbi.nrespeci   
                          NO-LOCK NO-ERROR.
          
       IF  AVAIL(craptab) THEN
           DO: 
               aux_dsbenefi = craptab.dstextab.
               aux_dsbenefi = REPLACE(aux_dsbenefi, "APOSENTADORIA", "APOS"). 
           END.
       ELSE
           aux_dsbenefi = "".

       IF crapcbi.nrbenefi <> 0 THEN
          ASSIGN aux_nrbenefi = crapcbi.nrbenefi.
       ELSE 
          ASSIGN aux_nrbenefi = crapcbi.nrrecben.

       DISPLAY STREAM str_1 aux_nrbenefi 
                            aux_dsbenefi   
                            crapcbi.nmrecben
                            crapcbi.nrdconta 
                            crapcbi.dtcompvi
                            WITH FRAME f_recebedores.
            
       DOWN STREAM str_1 WITH FRAME f_recebedores.

       DISPLAY STREAM str_2 aux_nrbenefi 
                            aux_dsbenefi   
                            crapcbi.nmrecben
                            crapcbi.nrdconta 
                            crapcbi.dtcompvi
                            WITH FRAME f_recebedores2.
            
       DOWN STREAM str_2 WITH FRAME f_recebedores2. 
       
       IF   LAST-OF(crapcbi.cdagenci)  THEN
            DO:
                DISPLAY STREAM str_1 aux_totbenef WITH FRAME f_total.
                PUT STREAM str_2 SKIP(1) 
                    "Total de beneficiarios: " aux_totbenef ";" SKIP(1).
                aux_totbenef = 0.
            END.
       
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.
                
                DISPLAY STREAM str_1 aux_nmagenci WITH FRAME f_pac.
                                        
            END.
   
   END. /* Fim do FOR EACH */
   
   OUTPUT STREAM str_1 CLOSE.
   OUTPUT STREAM str_2 CLOSE. 

   RETURN "OK".
   
END PROCEDURE.

PROCEDURE gera_465:

   DEF OUTPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.
   
   DEF VAR vlr_naopagos AS DEC                                          NO-UNDO.
   DEF VAR qtd_naopagos AS INT                                          NO-UNDO.
   DEF VAR vlr_bloquead AS DEC                                          NO-UNDO.
   DEF VAR qtd_bloquead AS INT                                          NO-UNDO.

   DEF VAR aux_nmmeiopg AS CHAR                                         NO-UNDO.
   
   FORM "PA: "  
        aux_nmagenci   FORMAT "x(30)" 
        SKIP(1)
        WITH NO-BOX NO-LABEL WIDTH 50 FRAME f_pac.
        
   FORM craplbi.nrbenefi  AT  1  LABEL "NB"                FORMAT "zzzzzzzzzzz9"
        craplbi.nrrecben  AT 14  LABEL "NIT"               FORMAT "zzzzzzzzzzz9"
        aux_nmmeiopg      AT 27  LABEL "Meio de pagamento" FORMAT "x(16)"
        crapcbi.nmrecben  AT 45  LABEL "Beneficiario"      FORMAT "x(30)"  
        craplbi.dtinipag  AT 76  LABEL "Inicio Pgto"
        craplbi.dtfimpag  AT 88  LABEL "Final Pgto"
        craplbi.vllanmto  AT 99  LABEL "Valor"          FORMAT "zzz,zzz,zz9.99"
        craplbi.dtblqcre  AT 114 LABEL "Bloqueio"   
        WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_lancamentos.
        
   FORM SKIP(1)
        " Creditos nao pagos  ==>  Quant:" 
        qtd_naopagos     AT 34   FORMAT "zz9"
        " Valor: "       AT 44
        vlr_naopagos     AT 52   FORMAT "zzz,zz9.99"
        SKIP(1)     
        " Creditos bloqueados ==>  Quant:"    
        qtd_bloquead     AT 34   FORMAT "zz9"
        " Valor:"        AT 44 
        vlr_bloquead     AT 53   FORMAT "zz,zz9.99"
        SKIP(1)
        WITH NO-BOX NO-LABEL WIDTH 132 SIDE-LABEL FRAME f_total.
                                                  
   ASSIGN par_nmarqimp = "rl/crrl465.lst".
   
   /* Inicializa Variaveis Relatorio */
   ASSIGN glb_cdcritic    = 0 
          aux_arqvazio    = TRUE
          glb_cdempres    = 11
          glb_cdrelato[1] = 465.
             
   { includes/cabrel132_1.i }
   
   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
   
   VIEW STREAM str_1 FRAME f_cabrel132_1.
   
                           /* Creditos NAO PAGOS */
   FOR EACH craplbi WHERE (craplbi.cdcooper  = glb_cdcooper   AND
                           craplbi.cdagenci >= tel_cdagenci   AND
                           craplbi.cdagenci <= aux_cdagefim   AND
                           craplbi.dtdpagto  = ?              AND
                           craplbi.dtfimpag >= glb_dtmvtolt   AND
                           craplbi.dtlibcre  = ?)             OR

                           /* Creditos PAGOS NO DIA */
                          (craplbi.cdcooper  = glb_cdcooper   AND
                           craplbi.cdagenci >= tel_cdagenci   AND
                           craplbi.cdagenci <= aux_cdagefim   AND
                           craplbi.dtdpagto  = glb_dtmvtolt   AND
                           craplbi.dtfimpag >= glb_dtmvtolt   AND
                           craplbi.cdsitcre  = 1 /*N Bloq.*/  AND
                           craplbi.dtlibcre  = ?)             OR
                        
                           /* Creditos desbloqueados */
                          (craplbi.cdcooper  = glb_cdcooper   AND
                           craplbi.cdagenci  = tel_cdagenci   AND
                           craplbi.dtdpagto  = ?              AND
                           craplbi.dtdenvio  = ?              AND
                           craplbi.cdsitcre  = 1              AND
                           craplbi.dtlibcre  <> ?)
                           NO-LOCK BREAK BY craplbi.cdagenci:

       IF   FIRST-OF(craplbi.cdagenci)  THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper  AND
                                   crapage.cdagenci = craplbi.cdagenci
                                   NO-LOCK NO-ERROR.
                
                IF   AVAIL crapage  THEN
                     ASSIGN aux_nmagenci = STRING(crapage.cdagenci,"zz9") + 
                                           " - " + crapage.nmresage.
                ELSE
                     ASSIGN aux_nmagenci = " ".
                
                DISPLAY STREAM str_1 aux_nmagenci WITH FRAME f_pac.           
                
            END.
            
       aux_arqvazio = FALSE.
       
       IF   craplbi.dtblqcre <> ?  THEN
            ASSIGN qtd_bloquead = qtd_bloquead + 1
                   vlr_bloquead = vlr_bloquead + craplbi.vllanmto.
       ELSE
            ASSIGN qtd_naopagos = qtd_naopagos + 1
                   vlr_naopagos = vlr_naopagos + craplbi.vllanmto.

       IF   craplbi.tpmepgto = 1  THEN
            ASSIGN aux_nmmeiopg = "Cartao ou Recibo".
       ELSE
       IF   craplbi.tpmepgto = 2  THEN
            ASSIGN aux_nmmeiopg = "Conta corrente".
            
       /* Busca nome do beneficiario por NB */
       FIND crapcbi WHERE crapcbi.cdcooper = glb_cdcooper        AND
                          crapcbi.nrrecben = 0                   AND
                          crapcbi.nrbenefi = craplbi.nrbenefi
                          NO-LOCK NO-ERROR.
                          
       /* Busca nome do beneficiario por NIT */
       IF   NOT AVAILABLE crapcbi   THEN
            FIND crapcbi WHERE crapcbi.cdcooper = glb_cdcooper        AND
                               crapcbi.nrrecben = craplbi.nrrecben    AND
                               crapcbi.nrbenefi = 0
                               NO-LOCK NO-ERROR.
                               
       DISPLAY STREAM str_1 craplbi.nrbenefi craplbi.nrrecben crapcbi.nmrecben
                            aux_nmmeiopg     craplbi.dtinipag craplbi.dtfimpag
                            craplbi.vllanmto craplbi.dtblqcre
                            WITH FRAME f_lancamentos.
       
       DOWN STREAM str_1 WITH FRAME f_lancamentos.
       
       IF   LAST-OF(craplbi.cdagenci)  THEN
            DO:
                DISPLAY STREAM str_1 qtd_naopagos vlr_naopagos
                                     qtd_bloquead vlr_bloquead
                                     WITH FRAME f_total.

                ASSIGN qtd_naopagos = 0
                       vlr_naopagos = 0
                       qtd_bloquead = 0
                       vlr_bloquead = 0.
            END.
         
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.
                
                DISPLAY STREAM str_1 aux_nmagenci WITH FRAME f_pac.
                
            END.
            
   END.     /* Fim do FOR EACH */
   
   OUTPUT STREAM str_1 CLOSE.

END PROCEDURE.

PROCEDURE gera_467:
    
   DEF OUTPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.
   
   DEF VAR rel_dsaltera AS CHAR FORMAT "x(29)"                          NO-UNDO.
   DEF VAR rel_dsmepgto AS CHAR FORMAT "x(16)"                          NO-UNDO.
   
   FORM "PA: "  
        aux_nmagenci   FORMAT "x(30)" 
        SKIP(1)
        WITH NO-BOX NO-LABEL WIDTH 50 FRAME f_pac.

   FORM crapcbi.nrbenefi  AT 1    LABEL "NB"            FORMAT "zzzzzzzzz9"
        crapcbi.nrrecben  AT 12   LABEL "NIT"           FORMAT "zzzzzzzzzz9"
        crapcbi.nrdconta  AT 23   LABEL "Conta"
        crapcbi.nmrecben  AT 34   LABEL "Beneficiario"  FORMAT "x(27)"
        crapcbi.dtatucad  AT 62   LABEL "Solicitacao"
        rel_dsaltera      AT 74   LABEL "Alteracao"
        rel_dsmepgto      AT 104  LABEL "Meio Pagamento"          
        WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_solicitantes.
        
   ASSIGN par_nmarqimp = "rl/crrl467.lst".
   
   /* Inicializa Variaveis Relatorio */
   ASSIGN glb_cdcritic    = 0 
          aux_arqvazio    = TRUE
          glb_cdempres    = 11
          glb_cdrelato[1] = 467.

   { includes/cabrel132_1.i }
      
   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
   
   VIEW STREAM str_1 FRAME f_cabrel132_1.

   FOR EACH crapcbi WHERE crapcbi.cdcooper  = glb_cdcooper   AND
                          crapcbi.cdagenci >= tel_cdagenci   AND
                          crapcbi.cdagenci <= aux_cdagefim   AND
                          crapcbi.dtatucad >= tel_dtinicio   AND
                          crapcbi.dtatucad <= tel_datfinal   AND

                          crapcbi.dtdenvio <> ?
                          NO-LOCK USE-INDEX crapcbi5
                          BREAK BY crapcbi.cdagenci:
                          
       ASSIGN aux_arqvazio = FALSE.
       
       IF   FIRST-OF(crapcbi.cdagenci)   THEN
            DO:
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND
                                   crapage.cdagenci = crapcbi.cdagenci
                                   NO-LOCK NO-ERROR.
                
                IF   AVAILABLE crapage  THEN
                     ASSIGN aux_nmagenci = STRING(crapage.cdagenci,"zz9") + 
                                           " - " + crapage.nmresage.
                ELSE
                     ASSIGN aux_nmagenci = " ".
                
                DISPLAY STREAM str_1 aux_nmagenci WITH FRAME f_pac.           
                                             
            END.
            
       IF   crapcbi.cdaltcad = 1   THEN
            rel_dsaltera = "01-Troca de c/c para cartao".
       ELSE
       IF   crapcbi.cdaltcad = 2   THEN
            rel_dsaltera = "02-Troca de conta corrente".
       ELSE
       IF   crapcbi.cdaltcad = 9   THEN
            rel_dsaltera = "09-Troca de cartao para c/c".
       ELSE
       IF   crapcbi.cdaltcad = 92  THEN
            rel_dsaltera = "92-Solicitacao de confirmacao".

       IF   crapcbi.tpnovmpg = 1   THEN
            rel_dsmepgto = "Cartao ou recibo".
       ELSE 
       IF   crapcbi.tpnovmpg = 2   THEN
            rel_dsmepgto = "Conta corrente".
       
       DISPLAY STREAM str_1 crapcbi.nrbenefi 
                            crapcbi.nrrecben
                            crapcbi.nrdconta
                            crapcbi.nmrecben
                            crapcbi.dtatucad 
                            rel_dsaltera
                            rel_dsmepgto
                            WITH FRAME f_solicitantes.
                       
       DOWN STREAM str_1 WITH FRAME f_solicitantes.
                                                          
       IF   LAST-OF(crapcbi.cdagenci)   THEN
            DOWN 1 STREAM str_1 WITH FRAME f_solicitantes.  
       
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)   THEN
            DO:
                PAGE STREAM str_1.
                
                DISPLAY STREAM str_1 aux_nmagenci WITH FRAME f_pac.
                                        
            END.
       
   END.  /* Fim do FOR EACH */
   
   OUTPUT STREAM str_1 CLOSE.

END PROCEDURE.

PROCEDURE gera_468:

   DEF OUTPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.
   
                 /* Variaveis do periodo informado por PA*/
   DEF VAR aux_vltottp1 AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_vltottp2 AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_tottipo1 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_tottipo2 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_vltotpac AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qtlcmpac AS INT  FORMAT "zzzz9"                          NO-UNDO.
                 
                 /* Variaveis do total do dia */
   DEF VAR aux_vltotdt1 AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qttotdt1 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_vltotdt2 AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qttotdt2 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_vltotdia AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qttotdia AS INT  FORMAT "zzzz9"                          NO-UNDO.

                 /* Variaveis total geral do periodo informado */
   DEF VAR aux_vltotdg1 AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qttotdg1 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_vltotdg2 AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qttotdg2 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_vltotger AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qttotger AS INT  FORMAT "zzzz9"                          NO-UNDO.

   FORM  "Dia: " craplbi.dtinipag
         WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_dia_periodo.
     
   FORM SKIP(1)
        "         Cartao ou Recibo      Conta corrente               Geral"
        SKIP
        "   PA       Valor    Quant       Valor " 
        "  Quant  Valor total  Quant total"
        SKIP
        "   --- -------------- ----- --------------"
        "----- ------------- -----------"
        WITH NO-BOX WIDTH 132 FRAME f_tit_pac_dia.

   FORM craplbi.cdagenci AT 4
        aux_vltottp1     SPACE(2)
        aux_tottipo1     SPACE(1)
        aux_vltottp2     SPACE(2)
        aux_tottipo2     SPACE(0)     
        aux_vltotpac     SPACE(7) 
        aux_qtlcmpac           
        WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_pac_dia.

   FORM "       -------------- ----- -------------- ----- -------------"
        "-----------"
        SKIP
        "Total:"
        aux_vltotdt1     SPACE(2)
        aux_qttotdt1     SPACE(1)
        aux_vltotdt2     SPACE(2)
        aux_qttotdt2     SPACE(0)
        aux_vltotdia     SPACE(7)
        aux_qttotdia
        SKIP(2)
        WITH NO-BOX NO-LABEL FRAME f_total_periodo.

   FORM " Total /Cartao ou recibo:" 
        aux_vltotdg1     AT 28  FORMAT "zz,zzz,zz9.99"
        " Quant:"        AT 44 
        aux_qttotdg1            FORMAT "z,zz9"
        
        " C/C: "         AT 21 
        aux_vltotdg2     AT 28  FORMAT "zz,zzz,zz9.99"
        " Quant:"        AT 44
        aux_qttotdg2            FORMAT "z,zz9"
        SKIP(1)                                        
       
        " Geral: Valor:" AT 12
        aux_vltotger     AT 27  FORMAT "zz,zzz,zz9.99"
        " Quant:"        AT 44
        aux_qttotger            FORMAT "z,zz9"
        WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_total_geral. 

   ASSIGN par_nmarqimp = "rl/crrl468.lst".
   
    /* Inicializa Variaveis Relatorio */
   ASSIGN glb_cdcritic    = 0 
          aux_arqvazio    = TRUE
          glb_cdempres    = 11
          glb_cdrelato[1] = 468.
             
   { includes/cabrel080_1.i }
   
   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
   
   VIEW STREAM str_1 FRAME f_cabrel080_1.

   FOR EACH craplbi WHERE craplbi.cdcooper  = glb_cdcooper   AND
                          craplbi.cdagenci >= tel_cdagenci   AND
                          craplbi.cdagenci <= aux_cdagefim   AND
                          craplbi.dtinipag >= tel_dtinicio   AND
                          craplbi.dtinipag <= tel_datfinal   AND
                          craplbi.dtdpagto  = ?              AND
                          craplbi.cdsitcre  = 1              AND
                          craplbi.dtdenvio  = ?         
                          NO-LOCK BREAK BY craplbi.dtinipag
                                          BY craplbi.cdagenci:

       aux_arqvazio = FALSE.                   
       
       IF   craplbi.tpmepgto = 1   THEN
            DO:
                aux_tottipo1 = aux_tottipo1 + 1.
                aux_vltottp1 = aux_vltottp1 + craplbi.vlliqcre.
            END.
       ELSE
            IF   craplbi.tpmepgto = 2   THEN
                 DO:
                     aux_tottipo2 = aux_tottipo2 + 1.
                     aux_vltottp2 = aux_vltottp2 + craplbi.vlliqcre.
                 END.
    
       IF   FIRST-OF(craplbi.dtinipag)  THEN
            DO:
                DISPLAY STREAM str_1 craplbi.dtinipag 
                                     WITH FRAME f_dia_periodo.
                VIEW STREAM str_1 FRAME f_tit_pac_dia.        
            END.
    
       IF   LAST-OF(craplbi.cdagenci)   THEN
            DO:
              
                       /* Soma totalizadores do PA para cada tipo de pgto */
                ASSIGN aux_vltotpac = aux_vltottp1 + aux_vltottp2
                       aux_qtlcmpac = aux_tottipo1 + aux_tottipo2
                   
                       /* Total geral do dia do tipo 1 do periodo informado */
                       aux_vltotdt1 = aux_vltotdt1 + aux_vltottp1
                       aux_qttotdt1 = aux_qttotdt1 + aux_tottipo1
                   
                       /* Total geral do dia do tipo 2 do periodo informado */
                       aux_vltotdt2 = aux_vltotdt2 + aux_vltottp2
                       aux_qttotdt2 = aux_qttotdt2 + aux_tottipo2
                   
                       /* Soma do geral dos dois tipos do dia */
                       aux_vltotdia = aux_vltotdt1 + aux_vltotdt2
                       aux_qttotdia = aux_qttotdt1 + aux_qttotdt2.

                /* Mostrar os totalizadores do PA */ 
                DISPLAY STREAM str_1 craplbi.cdagenci 
                                     aux_vltottp1
                                     aux_tottipo1
                                     aux_vltottp2
                                     aux_tottipo2
                                     aux_vltotpac
                                     aux_qtlcmpac
                                     WITH FRAME f_pac_dia.
            
                DOWN STREAM str_1 WITH FRAME f_pac_dia.
            
                /* Zera totalizadores do PA e geral do PA */
                ASSIGN aux_vltottp1 = 0
                       aux_vltottp2 = 0
                       aux_tottipo1 = 0
                       aux_tottipo2 = 0
                       aux_vltotpac = 0
                       aux_qtlcmpac = 0.
            
            END.    /* Fim do LAST-OF */

       IF   LAST-OF(craplbi.dtinipag)   THEN
            DO:
                DISPLAY STREAM str_1 aux_vltotdt1 
                                     aux_qttotdt1 
                                     aux_vltotdt2 
                                     aux_qttotdt2 
                                     aux_vltotdia 
                                     aux_qttotdia
                                     WITH FRAME f_total_periodo. 

               /* Soma GERAL do periodo informado */
                      /* Cartao ou recibo */
                ASSIGN aux_vltotdg1  = aux_vltotdg1 + aux_vltotdt1
                       aux_qttotdg1  = aux_qttotdg1 + aux_qttotdt1
                   
                          /* Conta */
                       aux_vltotdg2  = aux_vltotdg2 + aux_vltotdt2
                       aux_qttotdg2  = aux_qttotdg2 + aux_qttotdt2
                   
                          /* Geral */
                       aux_vltotger  = aux_vltotdg1 + aux_vltotdg2
                       aux_qttotger  = aux_qttotdg1 + aux_qttotdg2.
                   
                ASSIGN  aux_vltotdt1 = 0
                        aux_qttotdt1 = 0
                        aux_vltotdt2 = 0
                        aux_qttotdt2 = 0
                        aux_vltotdia = 0
                        aux_qttotdia = 0.
            END.
         
       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
            DO:
                PAGE STREAM str_1.
                
                DISPLAY STREAM str_1 craplbi.dtinipag 
                                     WITH FRAME f_dia_periodo.
               
                VIEW STREAM str_1 FRAME f_tit_pac_dia.
            END.     
   
   END. /* Fim do FOR EACH */
                  
   DISPLAY STREAM str_1 aux_vltotdg1 
                        aux_qttotdg1 
                        aux_vltotdg2 
                        aux_qttotdg2 
                        aux_vltotger 
                        aux_qttotger
                        WITH FRAME f_total_geral.       
   
   OUTPUT STREAM str_1 CLOSE.
   
END PROCEDURE.

PROCEDURE gera_464:
    
   DEF OUTPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.
   
             /* Variaveis do dia do Periodo informado */
   DEF VAR aux_vltottp1 AS DECI FORMAT "zz,zz9.99"                      NO-UNDO.
   DEF VAR aux_vltottp2 AS DECI FORMAT "zz,zz9.99"                      NO-UNDO.
   DEF VAR aux_tottipo1 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_tottipo2 AS INT  FORMAT "zzz9"                           NO-UNDO.
   DEF VAR aux_vltotdia AS DECI FORMAT "zzz,zzz,zz9.99"                 NO-UNDO.
   DEF VAR aux_qttotdia AS INT  FORMAT "zzzz9"                          NO-UNDO.

   DEF VAR aux_nmmepgto AS CHAR                                         NO-UNDO.
                   
   FORM "Dia: " craplbi.dtinipag
        WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_diaa_periodo.
     
   FORM aux_nmmepgto      AT  1  LABEL  "Meio pgto"    FORMAT "x(10)"
        craplbi.nrrecben  AT 12  LABEL  "NIT"          FORMAT "zzzzzzzzzzz"
        craplbi.nrbenefi  AT 24  LABEL  "NB"           FORMAT "zzzzzzzzzzz"
        crapcbi.nmrecben  AT 36  LABEL  "Beneficiario" FORMAT "x(31)" 
        craplbi.vlliqcre  AT 68  LABEL  "Valor"        FORMAT "zz,zz9.99"   
        WITH DOWN NO-BOX NO-LABEL WIDTH 80 FRAME f_pac_diaa.
       
   FORM SKIP(1)
        "Total dia/Cartao ou Recibo:"
        aux_vltottp1      AT 29  FORMAT "zz,zzz,zz9.99"
        "Quant:"          AT 46
        aux_tottipo1             FORMAT "z,zz9"
        "C/C:"            AT 24
        aux_vltottp2      AT 29  FORMAT "zz,zzz,zz9.99"
        "Quant:"          AT 46
        aux_tottipo2             FORMAT "z,zz9"
        
        SKIP (1)
        "Geral: Valor:"   AT 15
        aux_vltotdia      AT 29  FORMAT "zz,zzz,zz9.99"
        "Quant:"          AT 46
        aux_qttotdia             FORMAT "z,zz9"
        SKIP(1)
        WITH NO-BOX NO-LABEL WIDTH 80 FRAME f_tot_diaa.
   
     ASSIGN par_nmarqimp = "rl/crrl464.lst".
   
                 /* Inicializa Variaveis Relatorio */
     ASSIGN glb_cdcritic    = 0 
            aux_arqvazio    = TRUE
            glb_cdempres    = 11
            glb_cdrelato[1] = 464.
             
     { includes/cabrel080_1.i }
   
     OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
   
     VIEW STREAM str_1 FRAME f_cabrel080_1.

     FOR EACH craplbi WHERE craplbi.cdcooper  = glb_cdcooper   AND
                            craplbi.cdagenci >= tel_cdagenci   AND
                            craplbi.cdagenci <= aux_cdagefim   AND
                            craplbi.dtinipag >= tel_dtinicio   AND
                            craplbi.dtinipag <= tel_datfinal   AND
                            craplbi.dtdpagto  = ?              AND
                            craplbi.cdsitcre  = 1              AND
                            craplbi.dtdenvio  = ?
                            NO-LOCK BREAK BY craplbi.dtinipag
                                            BY craplbi.tpmepgto:
                                     
         aux_arqvazio = FALSE.
    
         IF   FIRST-OF(craplbi.dtinipag)  THEN
              DO:
                  DISPLAY STREAM str_1 craplbi.dtinipag 
                                       WITH FRAME f_diaa_periodo.
                                                
              END.
    
         IF   craplbi.tpmepgto = 1   THEN
              DO:
                  ASSIGN aux_nmmepgto = "Cart/Recib"
                         aux_tottipo1 = aux_tottipo1 + 1
                         aux_vltottp1 = aux_vltottp1 + craplbi.vlliqcre.
              END.
         ELSE
         IF   craplbi.tpmepgto = 2   THEN
              DO:
                  ASSIGN aux_nmmepgto = "Conta"
                         aux_tottipo2 = aux_tottipo2 + 1
                         aux_vltottp2 = aux_vltottp2 + craplbi.vlliqcre.
              END.
    
         /* Busca nome do beneficiario NB */ 
         FIND crapcbi WHERE crapcbi.cdcooper = glb_cdcooper        AND
                            crapcbi.nrrecben = 0                   AND
                            crapcbi.nrbenefi = craplbi.nrbenefi
                            NO-LOCK NO-ERROR.
                            
         /* Busca nome do beneficiario NIT */
         IF   NOT AVAILABLE crapcbi   THEN
              FIND crapcbi WHERE crapcbi.cdcooper = glb_cdcooper        AND
                                 crapcbi.nrrecben = craplbi.nrrecben    AND
                                 crapcbi.nrbenefi = 0
                                 NO-LOCK NO-ERROR.
    
         IF   AVAILABLE crapcbi   THEN
              DO:
                  DISPLAY STREAM str_1 aux_nmmepgto
                                       craplbi.nrrecben
                                       craplbi.nrbenefi
                                       crapcbi.nmrecben
                                       craplbi.vlliqcre
                                       WITH FRAME f_pac_diaa. 
    
                 DOWN STREAM str_1 WITH FRAME f_pac_diaa.
             END.
                 
    
         IF   LAST-OF(craplbi.dtinipag)   THEN
              DO:
                  DISPLAY STREAM str_1
                          aux_tottipo1
                          aux_vltottp1
                          aux_tottipo2
                          aux_vltottp2
                         (aux_tottipo1 + aux_tottipo2) @ aux_qttotdia
                         (aux_vltottp1 + aux_vltottp2) @ aux_vltotdia
                          WITH FRAME f_tot_diaa.
                      
                  /* Zera as variaveis que contam o total do dia */
                  ASSIGN aux_tottipo1 = 0
                         aux_vltottp1 = 0
                         aux_tottipo2 = 0
                         aux_vltottp2 = 0.
              END.  
    
         IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
              DO:
                  PAGE STREAM str_1.
                 
                  DISPLAY STREAM str_1 craplbi.dtinipag 
                                       WITH FRAME f_diaa_periodo.
              END.

     END.   /* Fim do FOR EACH */

     OUTPUT STREAM str_1 CLOSE.

END PROCEDURE.

PROCEDURE gera_470:

   DEF OUTPUT PARAM par_nmarqimp AS CHAR                                NO-UNDO.
                                                                       
   DEF VAR aux_tpmepgto AS CHAR                                         NO-UNDO.
   DEF VAR aux_vldoipmf AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_vlotipmf AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_pacpagto AS INTE                                         NO-UNDO.                           
    
    /* variaveis para  calcular valor total por pa, e quantidade */
   DEF VAR aux_totalcre AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_quantida AS INTEGER                                      NO-UNDO.
   DEF VAR aux_totaldcc AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_quantid2 AS INTEGER                                      NO-UNDO.
   DEF VAR aux_totalpac AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_quantpac AS INTEGER                                      NO-UNDO.
    
    /* variaveis para calcular valores gerais, e quantidade */
   DEF VAR aux_geralcre AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_quantger AS INTEGER                                      NO-UNDO.
   DEF VAR aux_geraldcc AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_quantge2 AS INTEGER                                      NO-UNDO.
   DEF VAR aux_valorger AS DECIMAL                                      NO-UNDO.
   DEF VAR aux_geralpac AS INTEGER                                      NO-UNDO.
   
               
   FORM "PA: "
        aux_nmagenci FORMAT "x(30)"
        SKIP (1)
        WITH NO-BOX NO-LABEL WIDTH 50 FRAME f_pac.
         
   FORM craplbi.dtdpagto AT  1  LABEL "Data Pgto"                            
        aux_pacpagto     AT 13  LABEL "PA Pgto"         FORMAT "zz9"                     
        craplbi.nrbenefi AT 21  LABEL "NB"              FORMAT "zzzzzzzzz9"  
        craplbi.nrrecben AT 32  LABEL "NIT"             FORMAT "zzzzzzzzzz9" 
        craplbi.nrdconta AT 44  LABEL "Conta/dv"                             
        crapcbi.nmrecben AT 55  LABEL "Beneficiario"    FORMAT "x(30)"       
        aux_tpmepgto     AT 86  LABEL "Meio pagamento"  FORMAT "x(14)"       
        craplbi.vllanmto AT 101 LABEL "Valor bruto"     FORMAT "z,zzz,zz9.99"
        craplbi.vlliqcre AT 114 LABEL "Valor pago"      FORMAT "z,zzz,zz9.99"
        aux_vldoipmf     AT 127 LABEL "CPMF"            format "z9.99"       
        WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_pagtos.                  

   FORM SKIP (1) 
        "Total PA / Cartao ou Recibo:"    
        aux_totalcre   AT 32  FORMAT "zz,zzz,zz9.99"  
        "Quant:"       AT 49
        aux_quantida          FORMAT "zzz,zz9" /*"z,zz9"*/
        "C/C:"         AT 26
        aux_totaldcc   AT 32  FORMAT "zz,zzz,zz9.99"
        "Quant:"       AT 49
        aux_quantid2          FORMAT "zzz,zz9" /*"z,zz9"*/
           
        "Total Valor:" AT 18
        aux_totalpac   AT 32  FORMAT "zz,zzz,zz9.99"
        "Total:"       AT 49                      
        aux_quantpac          FORMAT "zzz,zz9" /*"z,zz9"*/
        SKIP (1)          
        WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_total.
                                
   FORM SKIP(1)  
        "Total Geral/Cartao ou Recibo:" 
        aux_geralcre   AT 32  FORMAT "zz,zzz,zz9.99"   
        "Quant:"       AT 49
        aux_quantger          FORMAT "zzz,zz9" /*"z,zz9"*/
        "C/C:"         AT 26
        aux_geraldcc   AT 32  FORMAT "zz,zzz,zz9.99"
        "Quant:"       AT 49
        aux_quantge2          FORMAT "zzz,zz9" /*"z,zz9"*/
          
        "Geral: Valor:"AT 17
        aux_valorger   AT 32  FORMAT "zz,zzz,zz9.99"
        "Total:"       AT 49
        aux_geralpac          FORMAT "zzz,zz9" /*"z,zz9"*/
        WITH NO-BOX NO-LABEL WIDTH 132 FRAME f_total_geral.

   ASSIGN par_nmarqimp = "rl/crrl470.lst".
    
   /* Inicializa variaveis Relatorio */ 
                        
   ASSIGN glb_cdcritic    = 0
          aux_arqvazio    = TRUE
          glb_cdempres    = 11
          glb_cdrelato[1] = 470.

   { includes/cabrel132_1.i }
    
   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
   
   VIEW STREAM str_1 FRAME f_cabrel132_1.

   FOR EACH craplbi WHERE craplbi.cdcooper  = glb_cdcooper   AND
                          craplbi.cdagenci >= tel_cdagenci   AND
                          craplbi.cdagenci <= aux_cdagefim   AND
                          craplbi.dtdpagto >= tel_dtinicio   AND
                          craplbi.dtdpagto <= tel_datfinal   NO-LOCK
                          BREAK BY craplbi.cdagenci
                                   BY craplbi.dtdpagto:
       
        
       aux_arqvazio = FALSE.
        
       IF   craplbi.tpmepgto = 1  THEN
            ASSIGN aux_totalcre  = aux_totalcre + craplbi.vlliqcre
                   aux_quantida  = aux_quantida + 1
                   aux_geralcre  = aux_geralcre + craplbi.vlliqcre
                   aux_quantger  = aux_quantger + 1.
           
                  
       IF   craplbi.tpmepgto = 2   THEN
            ASSIGN aux_totaldcc  = aux_totaldcc + craplbi.vlliqcre
                   aux_quantid2  = aux_quantid2 + 1
                   aux_geraldcc  = aux_geraldcc + craplbi.vlliqcre
                   aux_quantge2  = aux_quantge2 + 1.
           
                    
       ASSIGN aux_totalpac  = aux_totalcre + aux_totaldcc
              aux_quantpac  = aux_quantida + aux_quantid2               
              aux_valorger  = aux_geralcre + aux_geraldcc
              aux_geralpac  = aux_quantger + aux_quantge2.
        
        
       IF   FIRST-OF(craplbi.cdagenci)   THEN
            DO:
               
                FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND
                                   crapage.cdagenci = craplbi.cdagenci
                                   NO-LOCK NO-ERROR.                        
                                    
                IF   AVAILABLE crapage   THEN
                     aux_nmagenci = STRING(crapage.cdagenci,"zz9") + " - " +
                                    crapage.nmresage.
                ELSE
                     aux_nmagenci = "** PA NAO ENCONTRADO **".
                      
                DISPLAY STREAM str_1 aux_nmagenci WITH FRAME f_pac.
                
            END.
      
       IF   craplbi.tpmepgto = 1   THEN
            DO:
                
                /* Busca o registro de pagamento */
                FIND craplpi WHERE craplpi.cdcooper = craplbi.cdcooper   AND
                                   craplpi.nrbenefi = craplbi.nrbenefi   AND
                                   craplpi.nrrecben = craplbi.nrrecben   AND   /**/
                                   craplpi.dtiniper = craplbi.dtiniper   AND
                                   craplpi.dtfimper = craplbi.dtfimper
                                   NO-LOCK NO-ERROR.
                  
                IF   AVAIL craplpi THEN 
                      DO:   
                          IF   craplpi.tppagben = 1   THEN
                               aux_tpmepgto  = "Cartao".
                          ELSE 
                               aux_tpmepgto  = "Recibo".

                          aux_vldoipmf = craplpi.vldoipmf.
                      END.
            END.                              
       ELSE
       IF   craplbi.tpmepgto = 2 THEN
            
            ASSIGN aux_tpmepgto = "Conta Corrente"
                   aux_vldoipmf = 0.
           
       /* Nome do beneficiario NIT */
       
       FIND crapcbi WHERE crapcbi.cdcooper = glb_cdcooper       AND
                          crapcbi.nrrecben = craplbi.nrrecben   AND
                          crapcbi.nrbenefi = 0
                          NO-LOCK NO-ERROR.
       
       
       /* Nome do beneficiario NB */
       IF   NOT AVAILABLE crapcbi   THEN
            FIND crapcbi WHERE crapcbi.cdcooper = glb_cdcooper       AND
                               crapcbi.nrrecben = 0                  AND
                               crapcbi.nrbenefi = craplbi.nrbenefi
                               NO-LOCK NO-ERROR.

       /* PA onde foi realizado o saque */  
       FIND craplpi WHERE craplpi.cdcooper = craplbi.cdcooper   AND
                          craplpi.nrbenefi = craplbi.nrbenefi   AND
                          craplpi.nrrecben = craplbi.nrrecben   AND
                          craplpi.dtiniper = craplbi.dtiniper   AND
                          craplpi.dtfimper = craplbi.dtfimper
                          NO-LOCK NO-ERROR.

       aux_pacpagto = 0.

       IF AVAIL craplpi THEN
           ASSIGN aux_pacpagto = craplpi.cdagenci.
       ELSE
           ASSIGN aux_pacpagto = craplbi.cdagenci.

                           
       DISPLAY STREAM str_1  craplbi.dtdpagto  aux_vldoipmf
                             aux_pacpagto      aux_tpmepgto
                             craplbi.nrbenefi  craplbi.nrrecben
                             crapcbi.nmrecben  craplbi.nrdconta
                             craplbi.vllanmto  craplbi.vlliqcre
                             WITH FRAME f_pagtos.  
                              
       DOWN STREAM str_1 WITH FRAME f_pagtos.
       
       IF   LAST-OF(craplbi.cdagenci)   THEN
            DO:  
                 DISPLAY STREAM str_1 aux_totalcre 
                                      aux_quantida  
                                      aux_totaldcc 
                                      aux_quantid2 
                                      aux_totalpac
                                      aux_quantpac WITH FRAME f_total.
                  
                 ASSIGN aux_totalcre = 0
                        aux_quantida = 0
                        aux_totaldcc = 0
                        aux_quantid2 = 0
                        aux_totalpac = 0
                        aux_quantpac = 0.
            END.

       IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
            DO:
               PAGE STREAM str_1.
                
               DISPLAY STREAM str_1 aux_nmagenci 
                                    WITH FRAME f_pac.
            END.
  
   END. /* Fim do FOR EACH */ 

   IF   tel_cdagenci = 0 THEN  
        
        /* se selecionar todos os pa's, mostra o total de cada valor  */
        
             DISPLAY STREAM str_1 aux_geralcre
                                  aux_quantger                                
                                  aux_geraldcc
                                  aux_quantge2
                                  aux_valorger
                                  aux_geralpac WITH FRAME f_total_geral.
 

   OUTPUT STREAM str_1 CLOSE.
    
END PROCEDURE.     /* Fim gera_470 */

PROCEDURE gera_000:

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                    NO-UNDO.
    DEFINE VARIABLE  aux_arquivo  AS CHARACTER               NO-UNDO.

    DEF VAR aux_nmarqimp2 AS CHAR                            NO-UNDO.
    DEF VAR aux_nrbenefi LIKE crapcbi.nrrecben               NO-UNDO.
    DEF VAR aux_nmprocur LIKE crappbi.nmprocur               NO-UNDO.
    
    ASSIGN aux_nrbenefi = 0.


    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    IF AVAIL crapcop THEN
        ASSIGN aux_arquivo = "/micros/" + crapcop.dsdircop + "/beneficiarios.txt"
               aux_nmarqimp2 = "/micros/" + crapcop.dsdircop + "/comprovacao_de_vida.lst".

    OUTPUT STREAM str_1 TO VALUE(aux_arquivo).
    OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp2).
    
    IF   tel_benefici = "T" THEN
         DO:
             FOR EACH crapcbi NO-LOCK
                 WHERE crapcbi.cdcooper  = glb_cdcooper:
                 IF  tel_cdagenci <> 0 THEN
                     DO:
                         IF crapcbi.cdagenci <> tel_cdagenci THEN NEXT.
                     END.

                 FIND FIRST craplbi
                      WHERE craplbi.cdcooper = crapcbi.cdcooper       
                        AND craplbi.nrrecben = crapcbi.nrrecben                          
                        AND craplbi.nrbenefi = crapcbi.nrbenefi            
                        NO-LOCK NO-ERROR.                                                
                                                                           
                 IF  AVAIL craplbi THEN                                                  
                     ASSIGN aux_dtultpag = craplbi.dtdpagto.          
                 ELSE                                                                    
                     ASSIGN aux_dtultpag = ?.                         
                 
                 PUT STREAM str_1 TRIM(crapcbi.nmrecben)            FORMAT "x(28)"
                                  ";"                       
                                  TRIM(crapcbi.dsendben)            FORMAT "x(60)"
                                  ";"                      
                                  TRIM(crapcbi.nmbairro)            FORMAT "x(17)"
                                  ";"                       
                                  TRIM(string(crapcbi.nrcepend))    FORMAT "x(10)"
                                  ";"
                                  IF aux_dtultpag <> ? THEN STRING(aux_dtultpag)
                                                       ELSE "" 
                                  ";"
                                  SKIP.
             END.      
         END.

    IF   tel_benefici = "C" THEN
         DO:
             FOR EACH crapcbi NO-LOCK
                 WHERE crapcbi.nrdconta <> 0
                   AND crapcbi.cdcooper  = glb_cdcooper:

                 IF   tel_cdagenci <> 0 THEN
                      DO:
                          IF crapcbi.cdagenci <> tel_cdagenci THEN NEXT.
                      END.
                 
                 FIND FIRST craplbi
                      WHERE craplbi.cdcooper = crapcbi.cdcooper
                        AND craplbi.nrrecben = crapcbi.nrrecben
                        AND craplbi.nrbenefi = crapcbi.nrbenefi 
                        NO-LOCK NO-ERROR.
                
                 IF   AVAIL craplbi THEN
                      ASSIGN aux_dtultpag = craplbi.dtdpagto.
                 ELSE 
                     ASSIGN aux_dtultpag = ?.
                 
                 PUT STREAM str_1 TRIM(crapcbi.nmrecben)            FORMAT "x(28)"
                                  ";"                       
                                  TRIM(crapcbi.dsendben)            FORMAT "x(60)"
                                  ";"                      
                                  TRIM(crapcbi.nmbairro)            FORMAT "x(17)"
                                  ";"                       
                                  TRIM(string(crapcbi.nrcepend))    FORMAT "x(10)"
                                  ";"
                                  IF aux_dtultpag <> ? THEN STRING(aux_dtultpag)
                                                       ELSE "" 
                                  ";"
                                  SKIP.                 
             END.
         END.

    IF   tel_benefici = "R" THEN
         DO:
             FOR EACH crapcbi NO-LOCK
                 WHERE crapcbi.nrdconta = 0
                   AND crapcbi.cdcooper  = glb_cdcooper:

                 IF   tel_cdagenci <> 0 THEN
                      DO:
                          IF crapcbi.cdagenci <> tel_cdagenci THEN NEXT.
                      END.

                 FIND FIRST craplbi
                     WHERE craplbi.cdcooper = crapcbi.cdcooper
                       AND craplbi.nrrecben = crapcbi.nrrecben
                       AND craplbi.nrbenefi = crapcbi.nrbenefi 
                       NO-LOCK NO-ERROR.

                 IF   AVAIL craplbi THEN
                      ASSIGN aux_dtultpag = craplbi.dtdpagto.
                 ELSE 
                     ASSIGN aux_dtultpag = ?.
                                  
                 PUT STREAM str_1 TRIM(crapcbi.nmrecben)            FORMAT "x(28)"
                                  ";"                       
                                  TRIM(crapcbi.dsendben)            FORMAT "x(60)"
                                  ";"                      
                                  TRIM(crapcbi.nmbairro)            FORMAT "x(17)"
                                  ";"                       
                                  TRIM(string(crapcbi.nrcepend))    FORMAT "x(10)"
                                  ";"
                                  IF aux_dtultpag <> ? THEN STRING(aux_dtultpag)
                                                       ELSE "" 
                                  ";"
                                  SKIP.
             END.
         END.

    FOR EACH crapcbi WHERE crapcbi.nrdconta <> 0 AND
                           (IF tel_cdagenci <> 0 THEN 
                               crapcbi.cdagenci = tel_cdagenci
                            ELSE
                               TRUE)             AND
                           crapcbi.cdcooper  = glb_cdcooper 
                           NO-LOCK BREAK BY crapcbi.cdagenci
                                         BY crapcbi.nrdconta:

       ASSIGN aux_nrbenefi = (IF crapcbi.nrbenefi <> 0 THEN
                                 crapcbi.nrbenefi
                              ELSE
                                 crapcbi.nrrecben)
              aux_nmprocur = "".

       FIND FIRST craplbi WHERE craplbi.cdcooper = crapcbi.cdcooper AND      
                                craplbi.nrrecben = crapcbi.nrrecben AND
                                craplbi.nrbenefi = crapcbi.nrbenefi 
                                NO-LOCK NO-ERROR.

       IF crapcbi.indresvi = 2 THEN
          DO:
             FIND crappbi WHERE crappbi.cdcooper = crapcbi.cdcooper AND
                                crappbi.nrrecben = crapcbi.nrrecben AND
                                crappbi.nrbenefi = crapcbi.nrbenefi
                                NO-LOCK NO-ERROR.

             ASSIGN aux_nmprocur = crappbi.nmprocur.
          END.

       DISP STREAM str_2 crapcbi.cdagenci COLUMN-LABEL "PA ;"     ";"
                         crapcbi.nrdconta COLUMN-LABEL "Conta ;"   ";"
                         crapcbi.nmrecben COLUMN-LABEL "Nome ;"    ";"
                         crapcbi.nrcpfcgc COLUMN-LABEL "CPF ;"     ";"
                         aux_nrbenefi     COLUMN-LABEL "NIT/NB ;"  ";" 
                         craplbi.vlliqcre COLUMN-LABEL "Valor beneficio ;" 
                         WHEN AVAIL craplbi ";"
                         crapcbi.dtcompvi COLUMN-LABEL "Comprovacao de Vida ;" ";"
                         aux_nmprocur COLUMN-LABEL "Procurador ;" 
                         WHEN AVAIL crappbi ";"
                         WITH WIDTH 200 NO-UNDERLINE.



    END.

    OUTPUT STREAM str_1 CLOSE.
    OUTPUT STREAM str_2 CLOSE.

END PROCEDURE. /*Fim gera_000*/


PROCEDURE gera_553:
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                  NO-UNDO.
    
    DEFINE VARIABLE tel_datainic  AS DATE.
    DEFINE VARIABLE tel_datafina  AS DATE.
    DEFINE VARIABLE tel_nrbenefi  LIKE crapcbi.nrbenefi    NO-UNDO.
    DEFINE VARIABLE tel_nrrecben  LIKE crapcbi.nrrecben    NO-UNDO.
    DEFINE VARIABLE aux_motivoPe  AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE tel_opcaoUsa  AS INTEGER               NO-UNDO.
    DEF VAR aux_opcaoesc AS CHAR                           NO-UNDO.
    
    FORM "Opcao:" 
         aux_opcaoesc AT 8 NO-LABEL FORMAT "x(20)" SKIP(2)
         "NB" AT 9
         "NIT" AT 20
         "BENEFICIARIO" AT 24
         "SOLICITACAO" AT 55
         "MOTIVO" AT 67 SKIP
         "----------"
         "-----------"
         "------------------------------"
         "-----------"
         "-----------------------"
         WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_pagtos.
    
    FORM crapsci.nrbenefi AT 1   NO-LABEL    FORMAT "zzzzzzzzz9"    
         crapsci.nrrecben AT 12  NO-LABEL    FORMAT "zzzzzzzzzz9"
         crapcbi.nmrecben AT 24  NO-LABEL    FORMAT "x(30)"
         crapsci.dtmvtolt AT 55  NO-LABEL
         aux_motivoPe     AT 67  NO-LABEL    FORMAT "x(25)" SKIP
         WITH DOWN NO-BOX NO-LABEL WIDTH 132 FRAME f_pagtos2.
        
    FORM SKIP(1)
         tel_opcaoUsa    AT 8 FORMAT "z" LABEL "Opcao"
         HELP "Informe a opcao (1)- 2a. Via de cartao, (2)- 2a. Via de senha)."  
         SKIP(1)
         tel_cdagenci    AT 9 FORMAT "zz9" LABEL "PA"
         HELP "Informe o numero do PA ou pressione <ENTER> p/ todos."
         SKIP(1)
         tel_nrbenefi AT 8   LABEL "NB"             FORMAT "zzzzzzzzz9"    
         tel_nrrecben AT 23  LABEL "NIT"            FORMAT "zzzzzzzzzz9"
         SKIP(1)
         tel_datainic AT 2 LABEL "Data Inicial" FORMAT 99/99/9999
         VALIDATE (tel_datainic <> ?, "Informe a Data Inicial da consulta.")
         /*SKIP(1)*/
         tel_datafina AT 28 LABEL "Data Final" FORMAT 99/99/9999
         VALIDATE (tel_datafina <> ?, "Informe a Data Final da consulta.")
         WITH ROW 10 CENTERED SIDE-LABELS NO-LABEL OVERLAY WIDTH 51
         TITLE " Gerar Arquivo " FRAME f_visrel_553.

    ASSIGN par_nmarqimp = "rl/crrl553.lst".
    
    OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 132.
    VIEW STREAM str_1 FRAME f_cabrel132_1.

    ASSIGN tel_opcaoUsa = 1.

    UPDATE tel_opcaoUsa
           tel_cdagenci
           tel_nrbenefi
           tel_nrrecben
           tel_datainic
           tel_datafina
        WITH FRAME f_visrel_553.

    HIDE FRAME f_visrel_553  NO-PAUSE.

    /* Inicializa Variaveis Relatorio */
    ASSIGN glb_cdcritic    = 0 
           aux_arqvazio    = TRUE
           glb_cdempres    = 11
           glb_cdrelato[1] = 553.

    { includes/cabrel132_1.i}

    IF   tel_opcaoUsa = 1 THEN
         DO:
             ASSIGN aux_opcaoesc = "2a. Via de cartao".
         END.
    ELSE 
         DO:
             ASSIGN aux_opcaoesc = "2a. Via de senha".
         END.
        
        
    DISPLAY STREAM str_1 aux_opcaoesc
         WITH FRAME f_pagtos.
   
    FOR EACH  crapsci NO-LOCK
        WHERE crapsci.dtmvtolt >= tel_datainic
          AND crapsci.dtmvtolt <= tel_datafina
          AND crapsci.tpsolici  = tel_opcaoUsa 
          AND crapsci.cdcooper  = glb_cdcooper
          BREAK BY crapsci.dtmvtolt.
       
        IF   tel_cdagenci <> 0 
        AND  crapsci.cdagenci <> tel_cdagenci THEN 
             NEXT.
        
        
        IF   tel_nrbenefi <> 0 
        AND  crapsci.nrbenefi <> tel_nrbenefi THEN
             DO:
                 IF tel_nrrecben = 0 THEN 
                     NEXT.
                 ELSE
                     IF   crapsci.nrrecben <> tel_nrrecben THEN NEXT.
             END.
        ELSE
            IF   tel_nrrecben <> 0 AND crapsci.nrrecben <> tel_nrrecben THEN 
                 NEXT. 
        

        FIND FIRST crapcbi
             WHERE crapcbi.nrrecben = crapsci.nrrecben 
               AND crapcbi.cdcooper = crapsci.cdcooper
               AND crapcbi.nrbenefi = crapsci.nrbenefi NO-LOCK NO-ERROR.
       
        IF   AVAIL crapcbi  THEN
             DO:
                 ASSIGN aux_arqvazio = FALSE.
                 IF    crapsci.cdmotsol = 1 THEN
                     ASSIGN aux_motivoPe = "1-Perda/Extravio".
                 IF    crapsci.cdmotsol = 2 THEN
                     ASSIGN aux_motivoPe = "2-Roubo".
                 IF    crapsci.cdmotsol = 3 THEN 
                     ASSIGN aux_motivoPe = "3-Esquecimento da Senha".

                 DISPLAY STREAM str_1
                                crapsci.nrbenefi
                                crapsci.nrrecben
                                crapcbi.nmrecben
                                crapsci.dtmvtolt
                                aux_motivoPe      SKIP
                                WITH FRAME f_pagtos2.
                 DOWN STREAM str_1 WITH FRAME f_pagtos2.
             END.
    END.
    OUTPUT STREAM str_1 CLOSE.

END PROCEDURE. /*fim gera_553*/



PROCEDURE gera_587:

  DEF INPUT PARAM par_nrprocur  LIKE crapcei.nrrecben           NO-UNDO.
  DEF INPUT PARAM par_dtcomext  AS CHAR FORMAT "99/9999"        NO-UNDO.
  DEF OUTPUT PARAM par_nmarqimp AS CHAR                         NO-UNDO.
                                                                
  DEF VAR aux_cdmovext AS INT FORMAT "zz9"                      NO-UNDO.
  DEF VAR aux_dsmovext AS CHAR FORMAT "x(30)"                   NO-UNDO.
  DEF VAR aux_vllanmto AS DEC FORMAT "zzz,zz9.99-"              NO-UNDO.
  DEF VAR aux_vlrliqui AS DEC  FORMAT "zzz,zz9.99"              NO-UNDO.
  DEF VAR aux_dslinha1 AS CHAR FORMAT "x(40)"                   NO-UNDO.
  DEF VAR aux_dslinha2 AS CHAR FORMAT "x(40)"                   NO-UNDO.
  DEF VAR aux_dslinha3 AS CHAR FORMAT "x(40)"                   NO-UNDO.
  DEF VAR aux_dtgralo2 AS DATE FORMAT "99/99/9999"              NO-UNDO.
  DEF VAR aux_cdtippag AS CHAR FORMAT "x(15)"                   NO-UNDO.
  DEF VAR aux_timeextr AS CHAR                                  NO-UNDO.
  DEF VAR aux_nrbenefi AS DEC  FORMAT "zzzzzzzzz9"              NO-UNDO.
  DEF VAR aux_nrrecben AS DEC  FORMAT "zzzzzzzzz9"              NO-UNDO.
  DEF VAR aux_nmbenefi AS CHAR FORMAT "x(40)"                   NO-UNDO.
  DEF VAR aux_dtcomext AS CHAR                                  NO-UNDO.
  DEF VAR aux_cdorgpag AS INT                                   NO-UNDO.
  DEF VAR aux_fontepag AS CHAR FORMAT "x(4)"                    NO-UNDO.
  DEF VAR aux_nrcnpjem AS CHAR FORMAT "x(18)"                   NO-UNDO.
  DEF VAR aux_dsespeci AS CHAR FORMAT "x(39)"                   NO-UNDO.
  DEF VAR aux_dscooper AS CHAR FORMAT "x(16)"                   NO-UNDO.
  DEF VAR aux_fill_1   AS CHAR FORMAT "x(48)"                   NO-UNDO.
  DEF VAR aux_fill_2   AS CHAR FORMAT "x(48)"                   NO-UNDO.
  DEF VAR aux_fill_3   AS CHAR FORMAT "x(48)"                   NO-UNDO.
      
  DEF VAR aux_tmlinha1 AS INT                                   NO-UNDO.
  DEF VAR aux_auxlinh1 AS INT                                   NO-UNDO.
  DEF VAR aux_tmlinha2 AS INT                                   NO-UNDO.
  DEF VAR aux_auxlinh2 AS INT                                   NO-UNDO.
  DEF VAR aux_tmlinha3 AS INT                                   NO-UNDO.
  DEF VAR aux_auxlinh3 AS INT                                   NO-UNDO.
  DEF VAR aux_flgbenef AS LOG                                   NO-UNDO.

  DEF VAR rel_fontepag AS CHAR FORMAT "x(4)"                    NO-UNDO.
  DEF VAR rel_nmbenefi AS CHAR FORMAT "x(40)"                   NO-UNDO.
  DEF VAR rel_cdtippag AS CHAR FORMAT "x(15)"                   NO-UNDO.
  DEF VAR rel_nrbenefi AS CHAR FORMAT "x(11)"                   NO-UNDO.
  DEF VAR rel_cdorgpag AS CHAR FORMAT "x(13)"                   NO-UNDO.
  DEF VAR rel_dsmovext AS CHAR FORMAT "x(32)"                   NO-UNDO.
  DEF VAR rel_dtcomext AS CHAR                                  NO-UNDO.
  DEF VAR rel_dsctotal AS CHAR FORMAT "x(37)"                   NO-UNDO.
  DEF VAR rel_nrrecben AS CHAR FORMAT "x(11)"                   NO-UNDO.
  DEF VAR aux_dtcompet AS CHAR                                  NO-UNDO.

  FORM SKIP(3)
       glb_dtmvtolt
       "DEMONSTRATIVO DE" AT 18 
       aux_timeextr AT 41
       SKIP
       "CREDITO DE BENEFICIO" AT 16
       SKIP(2)
       rel_fontepag LABEL "Fonte Pagadora" 
       "/ CNPJ:" 
       aux_nrcnpjem AT 31
       SKIP
       "Beneficiario:" 
       rel_nmbenefi AT 14
       SKIP
       "Competencia:"
       rel_dtcomext AT 13
       SKIP
       "Modalidade Pagamento:"
       rel_cdtippag AT 22
       SKIP
       "NB:" 
       rel_nrbenefi AT 4
       "/" AT 32
       "NIT:" 
       rel_nrrecben AT 38
       SKIP
       aux_dsespeci LABEL "Especie"
       SKIP
       "OP:"
       rel_cdorgpag AT 4
       "/" AT 18
       "Cooperativa:"
       aux_dscooper AT 32
       SKIP(2)
       aux_fill_1
       SKIP
       "COD DESCRICAO"
       "VALOR" AT 44
       SKIP
       WITH ROW 10 CENTERED SIDE-LABELS NO-LABEL OVERLAY WIDTH 132 FRAME f_cabecalho_inss.

  FORM aux_cdmovext
       rel_dsmovext 
       aux_vllanmto AT 38
       WITH DOWN CENTERED SIDE-LABEL NO-LABEL OVERLAY WIDTH 132 FRAME f_beneficio_inss.

  FORM SKIP(2)
       rel_dsctotal
       aux_vlrliqui AT 39
       SKIP(2)
       aux_dslinha1
       SKIP
       aux_dslinha2
       SKIP
       aux_dslinha3
       SKIP
       aux_fill_2
       SKIP
       "As informacoes foram fornecidas em" 
       aux_dtgralo2 "e"
       SKIP
       "sao de responsabilidade do INSS. Duvidas, ligue"
       SKIP
       "135."
       SKIP
       aux_fill_3
       WITH ROW 10 CENTERED SIDE-LABELS NO-LABEL OVERLAY WIDTH 132 FRAME f_mensagem_inss.
     

  ASSIGN par_nmarqimp = "rl/crrl587.lst".
       
  OUTPUT STREAM str_1 TO VALUE(par_nmarqimp).

   
  HIDE FRAME f_inss  NO-PAUSE.
   
  EMPTY TEMP-TABLE tt-craplei.

  
  /* Inicializa Variaveis Relatorio */
  ASSIGN glb_cdcritic    = 0 
         aux_arqvazio    = TRUE
         aux_fill_1        = FILL("-",48)
         aux_fill_2        = FILL("-",48)
         aux_fill_3        = FILL("-",48).
                   
  
  aux_dtcompet = SUBSTRING(par_dtcomext,1,2) + "/" + 
                       SUBSTRING(par_dtcomext,3,4).
                      
  FIND crapcei WHERE crapcei.cdcooper = glb_cdcooper AND
                    (crapcei.nrrecben = par_nrprocur OR
                     crapcei.nrbenefi = par_nrprocur)AND
                     crapcei.dtcomext = aux_dtcompet
                     NO-LOCK NO-ERROR.

        
  IF AVAIL crapcei THEN
     DO:      
        ASSIGN aux_vlrliqui = crapcei.vlrliqui
               aux_dslinha1 = crapcei.dslinha1
               aux_dslinha2 = crapcei.dslinha2
               aux_dslinha3 = crapcei.dslinha3
               aux_fontepag = "INSS"
               aux_nrcnpjem = STRING(crapcei.nrcnpjem, "99999999999999")
               aux_nrcnpjem = STRING(aux_nrcnpjem, "xx.xxx.xxx/xxxx-xx")
               aux_nmbenefi = crapcei.nmrecben
               aux_dtcomext = crapcei.dtcomext
               aux_nrbenefi = crapcei.nrbenefi
               aux_nrrecben = crapcei.nrrecben
               aux_cdorgpag = crapcei.cdorgpag
               aux_dtgralo2 = crapcei.dtgralot
               aux_timeextr = STRING(TIME, "HH:MM:SS")
               aux_cdtippag = (IF crapcei.tpmepgto = 2 THEN
                               "Conta" ELSE
                               "Cartao ou Recibo")
               aux_arqvazio = FALSE
               rel_cdorgpag = STRING(aux_cdorgpag)
               rel_nrbenefi = STRING(aux_nrbenefi)
               rel_nrrecben = STRING(aux_nrrecben).


        /* Abrevia os campos */
        RUN fontes/abreviar.p (INPUT aux_dscooper, 17,
                               OUTPUT aux_dscooper).

        RUN fontes/abreviar.p (INPUT aux_fontepag, 4,
                               OUTPUT rel_fontepag).
       
        RUN fontes/abreviar.p (INPUT aux_nmbenefi, 35,
                               OUTPUT rel_nmbenefi).
       
        RUN fontes/abreviar.p (INPUT aux_cdtippag, 27,
                               OUTPUT rel_cdtippag).
       
        RUN fontes/abreviar.p (INPUT rel_nrbenefi, 27,
                               OUTPUT rel_nrbenefi).
          
        RUN fontes/abreviar.p (INPUT rel_cdorgpag, 13,
                               OUTPUT rel_cdorgpag).

        RUN fontes/abreviar.p (INPUT rel_nrrecben, 11,
                               OUTPUT rel_nrrecben).

        RUN fontes/abreviar.p (INPUT aux_dtcomext, 35,
                               OUTPUT rel_dtcomext).


        IF aux_dslinha1 <> "" THEN
           aux_tmlinha1 = (48 - LENGTH(aux_dslinha1)).
        ELSE
           aux_tmlinha1 = 48.

        IF aux_dslinha2 <> "" THEN
           aux_tmlinha2 = (48 - LENGTH(aux_dslinha2)). 
        ELSE
           aux_tmlinha2 = 48.

        IF aux_dslinha3 <> "" THEN
           aux_tmlinha3 = (48 - LENGTH(aux_dslinha3)).
        ELSE 
           aux_tmlinha3 = 48.


        IF aux_tmlinha1 MOD 2 = 0 THEN
           DO:
              aux_tmlinha1 = aux_tmlinha1 / 2.
              aux_auxlinh1 = aux_tmlinha1.

           END.
        ELSE
           DO:           
              aux_tmlinha1 = (aux_tmlinha1 + 1) / 2.
              aux_auxlinh1 = (aux_tmlinha1 - 1).

           END.


        IF aux_tmlinha2 MOD 2 = 0 THEN
           DO:           
              aux_tmlinha2 = aux_tmlinha2 / 2.
              aux_auxlinh2 = aux_tmlinha2.

           END.
        ELSE
           DO:           
              aux_tmlinha2 = (aux_tmlinha2 + 1) / 2.
              aux_auxlinh2 = (aux_tmlinha2 - 1).

           END.


        IF aux_tmlinha3 MOD 2 = 0 THEN
           DO:           
              aux_tmlinha3 = aux_tmlinha3 / 2.
              aux_auxlinh3 = aux_tmlinha3.

           END.
        ELSE
           DO:          
              aux_tmlinha3 = (aux_tmlinha3 + 1) / 2.
              aux_auxlinh3 = (aux_tmlinha3 - 1).

           END.

        FIND craptab WHERE craptab.cdcooper = 0                  AND
                           craptab.nmsistem = "CRED"             AND
                           craptab.tptabela = "CONFIG"           AND
                           craptab.cdempres = 0                  AND
                           craptab.cdacesso = "TPBENEINSS"       AND
                           craptab.tpregist = crapcei.nrespeci  
                           NO-LOCK NO-ERROR.
   
        IF AVAILABLE craptab   THEN
           aux_dsespeci = STRING(crapcei.nrespeci) + 
                          " - " + craptab.dstextab. 
     
     
        FIND FIRST crapage WHERE crapage.cdcooper = crapcei.cdcooper AND
                                 crapage.cdorgpag = crapcei.cdorgpag
                                 NO-LOCK NO-ERROR.
     
        IF AVAIL crapage THEN
           DO:
              FIND crapcop WHERE crapcop.cdcooper = crapage.cdcooper
                                 NO-LOCK NO-ERROR.
   
              IF AVAIL crapcop THEN
                 aux_dscooper = STRING(crapcop.cdagebcb) + " - "
                                + crapcop.nmrescop. 
     
            END.


        FOR EACH craplei WHERE craplei.cdcooper = crapcei.cdcooper AND
                               craplei.nrrecben = crapcei.nrrecben AND
                               craplei.nrbenefi = crapcei.nrbenefi AND
                               craplei.dtcomext = crapcei.dtcomext
                               NO-LOCK:
            
            FIND crapmei WHERE crapmei.cdmovext = craplei.cdlanmto
                               NO-LOCK NO-ERROR.
       
            IF AVAIL crapmei THEN
               DO:
                  ASSIGN aux_cdmovext = crapmei.cdmovext
                         aux_dsmovext = crapmei.dsmovext
                         aux_vllanmto = (IF crapmei.tpmovext = "D" THEN 
                                            craplei.vllanmto * -1 ELSE
                                            craplei.vllanmto).


                  RUN fontes/abreviar.p (INPUT aux_dsmovext, 32,
                                         OUTPUT rel_dsmovext).
                  
                  CREATE tt-craplei.
                  ASSIGN tt-craplei.cdmovext = aux_cdmovext
                         tt-craplei.dsmovext = (rel_dsmovext + FILL(".",32 - LENGTH(rel_dsmovext)) )
                         tt-craplei.vllanmto = aux_vllanmto.
                                                   
                  aux_flgbenef = TRUE.

               END.
            ELSE
               DO:
                 glb_cdcritic = 80.
                 RUN fontes/critic.p.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.

                 HIDE FRAME f_visrel_587.
                 HIDE MESSAGE.
                 RETURN "NOK".
       
               END.
         
        END.

        IF aux_flgbenef THEN
           DO:
              DISP STREAM str_1 aux_fill_1
                                aux_nrcnpjem 
                                aux_timeextr
                                glb_dtmvtolt
                                (FILL(".",17 - LENGTH(aux_dscooper)) + aux_dscooper) 
                                             @ aux_dscooper FORMAT "x(17)"   
                                (FILL(".",11 - LENGTH(rel_nrrecben)) + rel_nrrecben) 
                                             @ rel_nrrecben FORMAT "x(11)"
                                (FILL(".",39 - LENGTH(aux_dsespeci)) + aux_dsespeci) 
                                             @ aux_dsespeci FORMAT "x(39)"
                                (FILL(".",36 - LENGTH(rel_dtcomext)) + rel_dtcomext) 
                                             @ rel_dtcomext FORMAT "x(48)"
                                (FILL(".",4 - LENGTH(rel_fontepag)) + rel_fontepag) 
                                             @ rel_fontepag FORMAT "x(4)"
                                (FILL(".",35 - LENGTH(rel_nmbenefi)) + rel_nmbenefi) 
                                             @ rel_nmbenefi FORMAT "x(48)"
                                (FILL(".",27 - LENGTH(rel_nrbenefi)) + rel_nrbenefi) 
                                             @ rel_nrbenefi FORMAT "x(27)" 
                                (FILL(".",13 - LENGTH(rel_cdorgpag)) + rel_cdorgpag) 
                                             @ rel_cdorgpag FORMAT "x(13)"   
                                (FILL(".",27 - LENGTH(rel_cdtippag)) + rel_cdtippag) 
                                             @ rel_cdtippag FORMAT "x(48)"
                                WITH FRAME f_cabecalho_inss.
                         
              
              FOR EACH tt-craplei NO-LOCK:
                  
                  DISP STREAM str_1 tt-craplei.cdmovext @ aux_cdmovext
                                    tt-craplei.dsmovext @ rel_dsmovext
                                    tt-craplei.vllanmto @ aux_vllanmto
                                    WITH FRAME f_beneficio_inss.
           
                  DOWN WITH FRAME f_beneficio_inss.
           
              END.
              
              
              DISP STREAM str_1 aux_vlrliqui
                                aux_dtgralo2
                                aux_fill_2
                                aux_fill_3    
                                ("TOTAL" + (FILL(".",32))) @ rel_dsctotal
                                (FILL(".", aux_tmlinha1) + 
                                  (IF aux_dslinha1 <> "" THEN 
                                      aux_dslinha1 ELSE "") + 
                                        FILL(".", aux_auxlinh1)) @ 
                                          aux_dslinha1 FORMAT "x(48)"
                                (FILL(".", aux_tmlinha2) + 
                                  (IF aux_dslinha2 <> "" THEN 
                                      aux_dslinha2 ELSE "") + 
                                        FILL(".", aux_auxlinh2)) @ 
                                          aux_dslinha2 FORMAT "x(48)"
                                (FILL(".", aux_tmlinha3) + 
                                  (IF aux_dslinha3 <> "" THEN 
                                      aux_dslinha3 ELSE "") + 
                                        FILL(".", aux_auxlinh3)) @ 
                                          aux_dslinha3 FORMAT "x(48)"
                                WITH FRAME f_mensagem_inss.
          
                                                            
                                                           
           END.
        ELSE
           DO:
              MESSAGE "Nenhum lancamento encontrado.".
              HIDE FRAME f_visrel_587.
              HIDE MESSAGE.
              RETURN "NOK".
       
           END.

     END. 
  ELSE
     DO:
        MESSAGE "Informacoes nao encontradas.".
        PAUSE(2) NO-MESSAGE.
        HIDE MESSAGE.
        HIDE FRAME f_visrel_587.
        RETURN "NOK".

     END.
            
  OUTPUT STREAM str_1 CLOSE.
   
  RETURN "OK".

  
END PROCEDURE.


/*PROCEDURE RESPONSAVEL PELA GERACAO DO REL 632 "PROVA DE VIDA"*/
PROCEDURE gera_632:

  DEF INPUT PARAM par_cdcooper AS INT                           NO-UNDO.
  DEF INPUT PARAM par_nrdcaixa AS INT                           NO-UNDO.
  DEF INPUT PARAM par_cdagenci AS INT                           NO-UNDO.
  DEF INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
  DEF INPUT PARAM par_idorigem AS INT                           NO-UNDO.
  DEF INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
  DEF INPUT PARAM par_ageselec AS INT                           NO-UNDO.

  DEF OUTPUT PARAM par_nmarqimp AS CHAR                         NO-UNDO.
                                                                
  DEF VAR aux_dsbenefi AS CHAR                                  NO-UNDO.
  DEF VAR aux_nrtelefo AS CHAR                                  NO-UNDO.
  DEF VAR aux_nrbenefi LIKE crapcbi.nrrecben                    NO-UNDO.
  DEF VAR h-b1wgen0091 AS HANDLE                                NO-UNDO.
  DEF VAR aux_tpbloque AS INT                                   NO-UNDO.
  DEF VAR aux_nrcpfcgc AS CHAR                                  NO-UNDO.
  DEF VAR aux_dscsitua AS CHAR                                  NO-UNDO.
  DEF VAR aux_contpac  AS INTE                                  NO-UNDO.
  DEF VAR aux_totgeral AS INTE                                  NO-UNDO.
  DEF VAR aux_nmarqimp2 AS CHAR                                 NO-UNDO.


  FORM "Conta"               AT 06
       "Nome"                AT 12
       "CPF"                 AT 44
       "NIT/NB"              AT 54
       "Valor do Beneficio"  AT 61
       "Tipo de Beneficio"   AT 80
       "Telefone"            AT 112
       "Endereco"            AT 127
       "Bairro"              AT 168
       "CEP"                 AT 193
       "Dt. Comp. Vida"      AT 197
       SKIP
       "---------- -------------------- --------------"
       "------------ ------------------ ------------------------------ ---------------" 
       "---------------------------------------- -----------------"
       "---------- --------------" 
       WITH NO-LABEL NO-BOX OVERLAY WIDTH 234 FRAME f_cabecalho_prova_vida.

  FORM tt-prova-vida.nrdconta 
       tt-prova-vida.nmrecben FORMAT "X(20)"
       tt-prova-vida.nrcpfcgc     FORMAT "X(14)"
       tt-prova-vida.nrbenefi     FORMAT "zzzzzzzzzzz9"
       tt-prova-vida.vlliqcre AT 65
       tt-prova-vida.dsbenefi     FORMAT "X(30)"
       tt-prova-vida.nrtelefo     FORMAT "X(15)"
       tt-prova-vida.dsendben FORMAT "X(40)"
       tt-prova-vida.nmbairro
       tt-prova-vida.nrcepend
       tt-prova-vida.dtcompvi
       WITH NO-LABEL NO-BOX DOWN OVERLAY WIDTH 234 FRAME f_beneficio. 

  FORM tt-prova-vida.cdagenci COLUMN-LABEL "PA ;"                                ";"
       tt-prova-vida.nrdconta COLUMN-LABEL "Conta ;"                              ";" 
       tt-prova-vida.nmrecben COLUMN-LABEL "Nome ;"       FORMAT "X(20)"          ";"
       tt-prova-vida.nrcpfcgc COLUMN-LABEL "CPF ;"        FORMAT "X(14)"          ";"
       tt-prova-vida.nrbenefi COLUMN-LABEL "NIT/NB ;"     FORMAT "zzzzzzzzzzz9"   ";"
       tt-prova-vida.vlliqcre COLUMN-LABEL "Valor do Beneficio ;"                 ";"
       tt-prova-vida.dsbenefi COLUMN-LABEL "Tipo de Beneficio ;"   FORMAT "X(30)" ";" 
       tt-prova-vida.nrtelefo COLUMN-LABEL "Telefone ;"   FORMAT "X(15)"          ";"
       tt-prova-vida.dsendben COLUMN-LABEL "Endereco ;"   FORMAT "X(40)"          ";"
       tt-prova-vida.nmbairro COLUMN-LABEL "Bairro ;"                             ";"
       tt-prova-vida.nrcepend COLUMN-LABEL "CEP ;"                                ";"
       tt-prova-vida.dtcompvi COLUMN-LABEL "Dt. Comp. Vida ;"                     ";"
       WITH NO-BOX NO-UNDERLINE OVERLAY DOWN WIDTH 280 FRAME f_beneficio2. 

  EMPTY TEMP-TABLE tt-prova-vida.

  ASSIGN glb_cdcritic    = 0
         glb_dscritic    = ""
         aux_arqvazio    = TRUE
         par_nmarqimp    = "rl/crrl632.lst"
         aux_dsbenefi    = ""
         glb_cdempres    = 11  
         glb_cdrelato[1] = 632
         aux_tpbloque    = 0
         aux_dscsitua    = ""
         aux_contpac     = 0
         aux_totgeral    = 0. 

  IF NOT VALID-HANDLE(h-b1wgen0091) THEN
     RUN sistema/generico/procedures/b1wgen0091.p PERSISTENT SET h-b1wgen0091.


  FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                     NO-LOCK NO-ERROR.

  IF NOT AVAIL crapcop THEN
     DO:
        ASSIGN glb_cdcritic = 651.
        RUN fontes/critic.p.
        HIDE MESSAGE NO-PAUSE.
        MESSAGE glb_dscritic.
        PAUSE(2) NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.

        IF VALID-HANDLE(h-b1wgen0091) THEN
           DELETE PROCEDURE h-b1wgen0091.
        
        ASSIGN glb_cdcritic = 0
               glb_dscritic = "".

        RETURN "NOK".
        
     END.
  
  ASSIGN aux_nmarqimp2 = "/micros/" + crapcop.dsdircop + "/crrl632.lst".

  FOR EACH crapcbi WHERE crapcbi.cdcooper = par_cdcooper  AND
                        (par_ageselec = 0                  OR
                         crapcbi.cdagenci = par_ageselec)
                         NO-LOCK:

      ASSIGN aux_tpbloque = DYNAMIC-FUNCTION("verificacao_bloqueio" 
                                    IN h-b1wgen0091,
                                    INPUT crapcbi.cdcooper,         
                                    INPUT par_nrdcaixa,             
                                    INPUT par_cdagenci,             
                                    INPUT par_cdoperad,             
                                    INPUT par_nmdatela,             
                                    INPUT par_idorigem,             
                                    INPUT par_dtmvtolt,             
                                    INPUT crapcbi.nrcpfcgc,         
                                    INPUT (IF crapcbi.nrrecben <> 0 THEN 
                                              crapcbi.nrrecben
                                           ELSE
                                              crapcbi.nrbenefi),
                                    INPUT 2 /*Ben. Especifico*/).

      IF aux_tpbloque <> 0 THEN
         DO:
            ASSIGN aux_arqvazio = FALSE
                   aux_dsbenefi = ""
                   aux_nrtelefo = ""
                   aux_nrbenefi = 0
                   aux_nrcpfcgc = ""
                   aux_dscsitua = "".

            FIND craptab WHERE craptab.cdcooper = 0                   AND
                               craptab.nmsistem = "CRED"              AND
                               craptab.tptabela = "CONFIG"            AND
                               craptab.cdempres = 0                   AND
                               craptab.cdacesso = "TPBENEINSS"        AND
                               craptab.tpregist = crapcbi.nrespeci
                               NO-LOCK NO-ERROR.
            
            IF AVAIL craptab THEN
               ASSIGN aux_dsbenefi = craptab.dstextab
                      aux_dsbenefi = REPLACE(aux_dsbenefi,"APOSENTADORIA",
                                             "APOS").
            
            
            FIND crapttl WHERE crapttl.cdcooper = crapcbi.cdcooper AND
                               crapttl.nrdconta = crapcbi.nrdconta AND
                               crapttl.nrcpfcgc = crapcbi.nrcpfcgc 
                               NO-LOCK NO-ERROR.
            
            IF AVAIL crapttl THEN
               FIND FIRST craptfc WHERE craptfc.cdcooper = crapttl.cdcooper AND
                                        craptfc.nrdconta = crapttl.nrdconta AND
                                        craptfc.idseqttl = crapttl.idseqttl AND
                                        craptfc.tptelefo = 2
                                        NO-LOCK NO-ERROR.
            
            
            FIND FIRST craplbi WHERE craplbi.cdcooper = crapcbi.cdcooper AND
                                     craplbi.nrrecben = crapcbi.nrrecben AND
                                     craplbi.nrbenefi = crapcbi.nrbenefi
                                     NO-LOCK NO-ERROR.

            ASSIGN aux_nrbenefi = (IF crapcbi.nrbenefi <> 0 THEN
                                      crapcbi.nrbenefi
                                   ELSE
                                      crapcbi.nrrecben)
                   aux_nrtelefo = (IF AVAIL craptfc THEN
                                      "(" + STRING(craptfc.nrdddtfc) + ")" +
                                      STRING(craptfc.nrtelefo)
                                   ELSE
                                      "" )
                   aux_nrcpfcgc = STRING(crapcbi.nrcpfcgc,"99999999999")
                   aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx")
                   aux_dscsitua = (IF aux_tpbloque = 1 THEN
                                      "BLOQ. FALTA COMPROVACAO VIDA"
                                   ELSE
                                   IF aux_tpbloque = 2 THEN
                                      "COMPROVACAO NAO EFETUADA"
                                   ELSE
                                      "COMPROVACAO PRESTES A VENCER").
            
            CREATE tt-prova-vida.

            ASSIGN tt-prova-vida.cdcooper = crapcbi.cdcooper
                   tt-prova-vida.cdagenci = crapcbi.cdagenci
                   tt-prova-vida.nrcpfcgc = aux_nrcpfcgc    
                   tt-prova-vida.nrdconta = crapttl.nrdconta WHEN AVAIL crapttl
                   tt-prova-vida.nmrecben = crapcbi.nmrecben
                   tt-prova-vida.nrbenefi = aux_nrbenefi    
                   tt-prova-vida.dsbenefi = aux_dsbenefi    
                   tt-prova-vida.nrtelefo = aux_nrtelefo    
                   tt-prova-vida.dsendben = crapcbi.dsendben
                   tt-prova-vida.nmbairro = crapcbi.nmbairro
                   tt-prova-vida.nrcepend = crapcbi.nrcepend
                   tt-prova-vida.vlliqcre = craplbi.vlliqcre WHEN AVAIL craplbi
                   tt-prova-vida.dtcompvi = crapcbi.dtcompvi
                   tt-prova-vida.dscsitua = aux_dscsitua
                   tt-prova-vida.tpbloque = aux_tpbloque.

                        
         END.

  END.

  IF VALID-HANDLE(h-b1wgen0091) THEN
     DELETE PROCEDURE h-b1wgen0091.


  OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGE-SIZE 63.
  
  OUTPUT STREAM str_2 TO VALUE(aux_nmarqimp2).

  { includes/cabrel132_1.i }

  VIEW STREAM str_1 FRAME f_cabrel132_1.
  
  VIEW STREAM str_2 FRAME f_cabrel132_1.


  FOR EACH tt-prova-vida NO-LOCK BREAK BY tt-prova-vida.cdagenci
                                        BY tt-prova-vida.tpbloque
                                         BY tt-prova-vida.nrdconta:

      ASSIGN aux_contpac  = aux_contpac + 1
             aux_totgeral = aux_totgeral + 1. 

      IF LINE-COUNTER(str_1) = 62 THEN
         DO:             
             PAGE STREAM str_1.
             VIEW STREAM str_1 FRAME f_cabrel132_1.
             VIEW STREAM str_1 FRAME f_cabecalho_prova_vida.

         END.
      ELSE
         IF FIRST-OF(tt-prova-vida.cdagenci) OR 
            FIRST-of(tt-prova-vida.tpbloque)THEN
            DO: 
               PAGE STREAM str_1.
               VIEW STREAM str_1 FRAME f_cabrel132_1.
               PUT STREAM str_1 "PA: " tt-prova-vida.cdagenci
                                " - " 
                                tt-prova-vida.dscsitua FORMAT "X(28)"
                                SKIP(2).

               VIEW STREAM str_1 FRAME f_cabecalho_prova_vida.
        
               
            END.

      ASSIGN aux_arqvazio = FALSE
             aux_dsbenefi = ""
             aux_nrtelefo = ""
             aux_nrbenefi = 0
             aux_nrcpfcgc = ""
             aux_dscsitua = "".

      DISP STREAM str_1 tt-prova-vida.nrcpfcgc
                        tt-prova-vida.nrdconta
                        tt-prova-vida.nmrecben
                        tt-prova-vida.nrbenefi 
                        tt-prova-vida.dsbenefi
                        tt-prova-vida.nrtelefo
                        tt-prova-vida.dsendben
                        tt-prova-vida.nmbairro
                        tt-prova-vida.nrcepend
                        tt-prova-vida.vlliqcre
                        tt-prova-vida.dtcompvi
                        WITH FRAME f_beneficio.


      DOWN WITH FRAME f_beneficio.

      IF LAST-OF (tt-prova-vida.cdagenci) THEN
         DO: 
             PUT STREAM str_1 SKIP(1) "TOTAL PA: " aux_contpac
             SKIP(1).

             ASSIGN aux_contpac = 0.
         END.

      DISP STREAM str_2 tt-prova-vida.cdagenci
                        tt-prova-vida.nrdconta
                        tt-prova-vida.nmrecben
                        tt-prova-vida.nrcpfcgc
                        tt-prova-vida.nrbenefi
                        tt-prova-vida.vlliqcre
                        tt-prova-vida.dsbenefi
                        tt-prova-vida.nrtelefo
                        tt-prova-vida.dsendben
                        tt-prova-vida.nmbairro
                        tt-prova-vida.nrcepend
                        tt-prova-vida.dtcompvi
                        WITH FRAME f_beneficio2.

      DOWN WITH FRAME f_beneficio2.
                  
  END.

  IF par_ageselec = 0 THEN
     PUT STREAM str_1 "TOTAL GERAL: " aux_totgeral.

  OUTPUT STREAM str_1 CLOSE.
  OUTPUT STREAM str_2 CLOSE.


  RETURN "OK".

  
END PROCEDURE.

                           
/*****************************************************************************/

