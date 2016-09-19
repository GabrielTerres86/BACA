/* ..........................................................................

   Programa: Fontes/conslc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : GATI (Eder)
   Data    : Outubro/2010                       Ultima atualizacao: 06/10/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela CONSLC.
   
   Alteracoes: 29/12/2010 - Inclusao da coluna "Data de Vencimento" (Adriano).
   
               15/02/2011 - Alterado as consultas referentes ao campo "Data"
                            buscando a informaçao em craplim.dtinivig, ao invés 
                            de craplim.dtpropos (Vitor).
               
               29/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               06/10/2014 - (SOFTDESK 88572) - Exibir soma de todos os valores totais e a quantidade 
                            de resultados encontrados para o filtro (Felipe Oliveira)
                
............................................................................. */
{includes/var_online.i}

DEF TEMP-TABLE cratlim NO-UNDO LIKE craplim
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD dsdtxfix AS CHAR
    FIELD dsdtplin AS CHAR
    FIELD dsdlinha AS CHAR
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD datavenc LIKE craplim.dtinivig.

DEF TEMP-TABLE cratlrt NO-UNDO LIKE craplrt
    FIELD dsdtplin AS CHAR  FORMAT "X(11)"
    FIELD dsdtxfix AS CHAR  FORMAT "X(12)".

DEF TEMP-TABLE crawlrt NO-UNDO LIKE cratlrt.

DEF TEMP-TABLE crattip NO-UNDO
    FIELD tpdlinha AS INT
    FIELD dsdtplin AS CHAR.

DEF  VAR tel_dtdinici AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF  VAR tel_dtdfinal AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF  VAR tel_cdagenci AS INTE FORMAT "zz9"                           NO-UNDO.
DEF  VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                    NO-UNDO.
DEF  VAR tel_tpdlinha AS INTE FORMAT "zz9"               INIT 3      NO-UNDO.
DEF  VAR tel_cddlinha AS INTE FORMAT "zz9"                           NO-UNDO.
DEF  VAR tel_nmdopcao AS LOGI FORMAT "ARQUIVO/IMPRESSAO" INIT TRUE   NO-UNDO.
DEF  VAR tel_nmdireto AS CHAR FORMAT "x(20)"                         NO-UNDO.
DEF  VAR tel_nmarquiv AS CHAR FORMAT "x(25)"                         NO-UNDO.
DEF  VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF  VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
DEF  VAR tel_dsdlinha LIKE craplrt.dsdlinha                          NO-UNDO.

DEF  VAR aux_cont     AS INT                                         NO-UNDO. 
DEF  VAR aux_qtdlinha AS INT                                         NO-UNDO. 
DEF  VAR aux_totvalor AS DECI FORMAT "zzz,zzz,zz9.99-"                NO-UNDO. 


DEF  VAR aux_cddopcao AS CHAR                                        NO-UNDO.
DEF  VAR aux_contador AS INT                                         NO-UNDO.
DEF  VAR aux_nmendter AS CHAR FORMAT "x(20)"                         NO-UNDO.
DEF  VAR aux_nmarqimp AS CHAR                                        NO-UNDO.
DEF  VAR aux_confirma AS CHAR FORMAT "!(1)"                          NO-UNDO.
DEF  VAR aux_datavenc AS DATE FORMAT  "99/99/9999"                   NO-UNDO. 

DEF  VAR rel_nmempres AS CHAR FORMAT "x(15)"                         NO-UNDO.
DEF  VAR rel_nmrelato AS CHAR FORMAT "x(40)"             EXTENT 5    NO-UNDO.
DEF  VAR rel_nrmodulo AS INT  FORMAT "9"                             NO-UNDO.
DEF  VAR rel_nmmodulo AS CHAR FORMAT "x(15)"             EXTENT 5    NO-UNDO.

DEF  VAR par_flgrodar AS LOG                             INIT TRUE   NO-UNDO.
DEF  VAR aux_flgescra AS LOG                                         NO-UNDO.
DEF  VAR aux_dscomand AS CHAR                                        NO-UNDO.
DEF  VAR par_flgfirst AS LOG                             INIT TRUE   NO-UNDO.
DEF  VAR par_flgcance AS LOGICAL                                     NO-UNDO.

DEF STREAM str_1.



FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP(1)
     glb_cddopcao COLON 12
                  LABEL "Opcao"
                  AUTO-RETURN
                  HELP "Informe a opcao desejada (T-Terminal ou I-Impressao)."
                  VALIDATE (glb_cddopcao = "T" OR glb_cddopcao = "I", 
                            "014 - Opcao errada.")
     WITH FRAME f_opcao OVERLAY NO-BOX SIDE-LABELS ROW 5 COLUMN 2.

FORM tel_nrdconta COLON 12
                  LABEL "Conta"
                  HELP 
                     "Informe o numero da conta ou '0'(zero) para listar todos."
     tel_cdagenci COLON 30
                  LABEL "PA"
                  HELP "Informe o numero do PA ou '0'(zero) para listar todos."
     tel_dtdinici COLON 45
                  LABEL "Data"
                  HELP "Informe a data inicial da consulta." 
     "-"
     tel_dtdfinal NO-LABEL
                  HELP "Informe a data final da consulta." 
     SKIP
     tel_tpdlinha COLON 12
                  LABEL "Tipo limite" 
                  HELP "Informe o codigo ou <F7> para listar as opcoes"
                  VALIDATE (tel_tpdlinha >= 1 AND tel_tpdlinha <= 3,
                            "014 - Opcao errada.")
     crattip.dsdtplin
                  NO-LABEL
                  FORMAT "X(22)"
     tel_cddlinha COLON 46
                  LABEL "Linha"
                  HELP 
                  "Informe a linha de cred. ou '0'(zero) p/ todas ou <F7>"
     tel_dsdlinha FORMAT "X(25)"
                  NO-LABEL
     SKIP(1)                                                
     WITH FRAME f_dados OVERLAY NO-BOX SIDE-LABELS ROW 8 COLUMN 2.

FORM tel_nrdconta COLON 12
                  LABEL "Conta"
                  HELP 
                     "Informe o numero da conta ou '0'(zero) para listar todos."
     tel_cdagenci COLON 35
                  LABEL "PA"
                  HELP "Informe o numero do PA ou '0'(zero) para listar todos."
     tel_dtdinici COLON 45
                  LABEL "Data"
                  HELP "Informe a data inicial da consulta." 
     "-"
     tel_dtdfinal NO-LABEL
                  HELP "Informe a data final da consulta." 
     SKIP
     tel_tpdlinha COLON 12
                  LABEL "Tipo limite" 
                  HELP "Informe o codigo ou <F7> para listar as opcoes"
                  VALIDATE (tel_tpdlinha >= 1 AND tel_tpdlinha <= 3,
                            "014 - Opcao errada.")
     crattip.dsdtplin
                  NO-LABEL
                  FORMAT "X(24)"
     SKIP(1)                                            
     WITH FRAME f_dados_sem_linha OVERLAY NO-BOX SIDE-LABELS ROW 8 COLUMN 2.


DEF QUERY q_cratlim FOR cratlim.
DEF QUERY q_cratlrt FOR cratlrt.
DEF QUERY q_crattip FOR crattip.
     
DEF BROWSE b_cratlim QUERY q_cratlim
    DISPLAY cratlim.cdagenci                       COLUMN-LABEL "PA"
            cratlim.nrdconta                       COLUMN-LABEL "Conta"
            cratlim.dsdtplin   FORMAT "X(11)"      COLUMN-LABEL "Tipo"
            cratlim.dsdlinha   FORMAT "X(25)"      COLUMN-LABEL "Linha"
            cratlim.nrctrlim                       COLUMN-LABEL "Contrato"
            cratlim.vllimite                       COLUMN-LABEL "Valor"
            cratlim.dtinivig                       COLUMN-LABEL "Data"
            cratlim.datavenc   FORMAT "99/99/9999" COLUMN-LABEL "Vencimento"
            cratlim.dsdtxfix   FORMAT "X(12)"      COLUMN-LABEL "Taxa":C12
    WITH WIDTH 78 5 DOWN SCROLLBAR-VERTICAL.

DEF BROWSE b_cratlrt QUERY q_cratlrt
    DISPLAY cratlrt.cddlinha                    COLUMN-LABEL "Cod"
            cratlrt.dsdlinha   FORMAT "x(30)"   COLUMN-LABEL "Descricao"
            cratlrt.dsdtplin   FORMAT "X(11)"   COLUMN-LABEL "Tipo"
            cratlrt.dsdtxfix   FORMAT "X(12)"   COLUMN-LABEL "Taxa":C12
    WITH 7 DOWN OVERLAY TITLE " Linhas de Credito Rotativo " MULTIPLE.

DEF BROWSE b_crattip QUERY q_crattip
    DISPLAY crattip.tpdlinha   FORMAT ">9"      COLUMN-LABEL "Tipo"
            crattip.dsdtplin   FORMAT "X(30)"   COLUMN-LABEL "Descricao"
    WITH 3 DOWN OVERLAY TITLE " Tipos de Limite " NO-LABELS.
            
FORM   b_cratlim  HELP "Use as SETAS para navegar ou <F4> para sair." SKIP
       cratlim.nmprimtl LABEL "Nome Titular"   AT 3
       aux_cont         LABEL "Qtd. Registros" AT 3 
       aux_totvalor     LABEL "Valor Total "      
       
       WITH  NO-BOX CENTERED OVERLAY ROW 10 FRAME f_cratlim SIDE-LABELS.


FORM   b_cratlrt  HELP "Selecao de Linhas de Credito para exibicao dos dados" 
       SKIP
       WITH  NO-BOX CENTERED OVERLAY ROW 10 FRAME f_cratlrt.

FORM   b_crattip  HELP "Selecao de Tipos de Limite para exibicao dos dados" 
       SKIP
       WITH  NO-BOX CENTERED OVERLAY ROW 10 FRAME f_crattip.

/********** Impressao **********/


FORM tel_nmdopcao      COLON 12
                       LABEL "Saida"
                       HELP  "(A)rquivo ou (I)mpressao."
     WITH FRAME f_impressao OVERLAY NO-BOX SIDE-LABELS ROW 12 COLUMN 2.
     
FORM tel_nmdireto      COLON 12
                       LABEL "Diretorio"
     SPACE(2)
     tel_nmarquiv      NO-LABEL HELP "Informe o nome do arquivo."
     WITH FRAME f_diretorio OVERLAY NO-BOX SIDE-LABELS ROW 14 COLUMN 2.
     
FORM cratlim.cdagenci     LABEL "PA"
     cratlim.nrdconta     LABEL "Conta"
     cratlim.dsdtplin     LABEL "Tipo"       FORMAT "X(11)"
     cratlim.dsdlinha     LABEL "Linha"      FORMAT "X(25)"
     cratlim.nrctrlim     LABEL "Contrato"
     cratlim.vllimite     LABEL "Valor"
     cratlim.dtinivig     LABEL "Data"    
     cratlim.datavenc     LABEL "Vencimento" FORMAT "99/99/9999" 
     cratlim.dsdtxfix     LABEL "Taxa":C12   FORMAT "X(12)"
     WITH NO-BOX NO-LABEL DOWN FRAME f_dados_limite WIDTH 132.

FORM crawlrt.cddlinha                  COLUMN-LABEL "Cod"
     crawlrt.dsdlinha  FORMAT "x(30)"  COLUMN-LABEL "Descricao"
     crawlrt.dsdtplin  FORMAT "X(11)"  COLUMN-LABEL "Tipo"
     crawlrt.dsdtxfix  FORMAT "X(12)"  COLUMN-LABEL "Taxa":C12
     WITH NO-BOX NO-LABEL DOWN FRAME f_linhas_selecionadas WIDTH 132.

FORM   aux_cont         LABEL "Qtd. Registros" AT 5
       aux_totvalor     LABEL "Valor Total "   AT 50
       WITH FRAME f_total_limite OVERLAY NO-BOX SIDE-LABELS WIDTH 132.



FORM SKIP(1)
     "CONTRATOS DE LIMITE DE CREDITO"
     SKIP(1)
     WITH FRAME f_cabec_relat NO-BOX NO-LABEL WIDTH 132.

ON   "F7" OF tel_cddlinha IN FRAME f_dados
     DO:
         RUN pi_carrega_linhas.
     
         OPEN QUERY q_cratlrt FOR EACH cratlrt.
     
         DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
              UPDATE b_cratlrt WITH FRAME f_cratlrt.
              LEAVE.
         END.
         HIDE FRAME f_cratlrt NO-PAUSE.
     
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              RETURN NO-APPLY.
     
         EMPTY TEMP-TABLE crawlrt.
     
         DO   aux_contador = 1 TO b_cratlrt:NUM-SELECTED-ROWS:
              b_cratlrt:FETCH-SELECTED-ROW(aux_contador).
     
              CREATE crawlrt.
              BUFFER-COPY cratlrt TO crawlrt.
         
              IF   b_cratlrt:NUM-SELECTED-ROWS = 1   THEN
                   DO:
                       ASSIGN tel_cddlinha = cratlrt.cddlinha.
                       DISP   tel_cddlinha WITH FRAME f_dados.
                   END.
         END.

         APPLY "GO" TO tel_cddlinha.
         RETURN NO-APPLY.
     END.

ON   "F7" OF tel_tpdlinha IN FRAME f_dados
     DO:
         OPEN QUERY q_crattip FOR EACH crattip.
     
         ENABLE b_crattip WITH FRAME f_crattip.
         WAIT-FOR RETURN OF b_crattip FOCUS BROWSE b_crattip.
         
         HIDE FRAME f_crattip NO-PAUSE.
     
         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              RETURN NO-APPLY.

         b_crattip:FETCH-SELECTED-ROW(1).

         ASSIGN tel_tpdlinha = crattip.tpdlinha.

         DISP tel_tpdlinha WITH FRAME f_dados.
     
         APPLY "GO" TO tel_tpdlinha.
         RETURN NO-APPLY.
     END.

ON   RETURN OF b_cratlrt IN FRAME f_cratlrt
     DO:
         APPLY "GO" TO b_cratlrt.
     END.

ON   "VALUE-CHANGED" OF b_cratlim IN FRAME f_cratlim
     DO:
          DISP cratlim.nmprimtl aux_cont aux_totvalor WITH FRAME f_cratlim.
     END.

VIEW FRAME f_moldura.
PAUSE (0).

ASSIGN glb_cddopcao = "T".

/* Opcoes do campo Tipo Limite */
EMPTY TEMP-TABLE crattip.
CREATE crattip.
ASSIGN crattip.tpdlinha = 1
       crattip.dsdtplin = "Limite de Credito PF".

CREATE crattip.
ASSIGN crattip.tpdlinha = 2
       crattip.dsdtplin = "Limite de Credito PJ".

CREATE crattip.
ASSIGN crattip.tpdlinha = 3
       crattip.dsdtplin = "Todos".

RELEASE crattip.
  
DO   WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
     HIDE FRAME f_opcao        NO-PAUSE.
     HIDE FRAME f_dados        NO-PAUSE.
     HIDE FRAME f_cratlim      NO-PAUSE.
     HIDE FRAME f_cratlrt      NO-PAUSE.
     HIDE FRAME f_crattip      NO-PAUSE.
     HIDE FRAME f_diretorio    NO-PAUSE.
     HIDE FRAME f_impressao    NO-PAUSE.
     HIDE FRAME f_dados_limite NO-PAUSE.

     EMPTY TEMP-TABLE crawlrt.

     ASSIGN tel_nrdconta = 0
            tel_cdagenci = 0
            tel_dtdinici = ?
            tel_dtdfinal = ?
            tel_tpdlinha = 3
            tel_cddlinha = 0
            tel_dsdlinha = ""
            aux_datavenc = ?.

     DISPLAY glb_cddopcao WITH  FRAME f_opcao.


     DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
         UPDATE  glb_cddopcao WITH FRAME f_opcao.

         DISPLAY tel_nrdconta
                 tel_cdagenci
                 tel_dtdinici
                 tel_dtdfinal
                 tel_tpdlinha
                 "" @ crattip.dsdtplin
                 tel_cddlinha
                 tel_dsdlinha  
                 WITH FRAME f_dados.

         DO   WHILE TRUE:
              
              UPDATE  tel_nrdconta
                      WITH FRAME f_dados.
              
              IF   tel_nrdconta <> 0                               AND
                   NOT CAN-FIND(crapass WHERE
                                crapass.cdcooper = glb_cdcooper AND 
                                crapass.nrdconta = tel_nrdconta)   THEN   
                   DO:
                       ASSIGN glb_cdcritic = 564.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       /*CLEAR FRAME f_dados.*/
                       NEXT.
                   END.

              LEAVE.
         END.

         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.

         DO   WHILE TRUE:

              UPDATE  tel_cdagenci
                      WITH FRAME f_dados.
              
              IF   tel_cdagenci <> 0                               AND
                   NOT CAN-FIND(crapage WHERE
                                crapage.cdcooper = glb_cdcooper AND 
                                crapage.cdagenci = tel_cdagenci)   THEN   
                   DO:
                       ASSIGN glb_cdcritic = 15.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       /*CLEAR FRAME f_dados.*/
                       NEXT.
                   END.
              
              LEAVE.

         END.

         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.

         DO   WHILE TRUE:

               UPDATE  tel_dtdinici tel_dtdfinal
                       WITH FRAME f_dados.
              
               IF   tel_nrdconta = 0    THEN
                    DO:
                        IF   tel_dtdinici = ? OR tel_dtdfinal = ? THEN
                             DO:
                                 BELL.
                                 MESSAGE "Data inicial e data final devem ser informadas.".
                                 /*CLEAR FRAME f_dados. */
                                 NEXT.
                             END.
                    END.
               ELSE
                    DO:
                        IF   (tel_dtdinici = ? AND tel_dtdfinal <> ?) OR
                             (tel_dtdinici <> ? AND tel_dtdfinal = ?) THEN    
                             DO:
                                 BELL.
                                 MESSAGE "Informe Data inicial e Final ou nenhuma data.".
                                 /*CLEAR FRAME f_dados. */
                                 NEXT.
                             END.
                    END.

               IF   tel_dtdinici > tel_dtdfinal   THEN
                    DO:
                        BELL.
                        MESSAGE "Data inicial maior que final.".
                        /*CLEAR FRAME f_dados.*/
                        NEXT.
                    END.
              
               LEAVE.

         END.

         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.

         DO   WHILE TRUE:

              UPDATE  tel_tpdlinha WITH FRAME f_dados.
              
              FIND crattip WHERE crattip.tpdlinha = tel_tpdlinha NO-ERROR.
              IF   AVAIL crattip   THEN
                   DISP crattip.dsdtplin WITH FRAME f_dados.
              
              UPDATE  tel_cddlinha WITH FRAME f_dados.
              
              IF   tel_cddlinha <> 0                               AND
                   NOT CAN-FIND(craplrt WHERE
                                craplrt.cdcooper = glb_cdcooper    
                            AND craplrt.cddlinha = tel_cddlinha)   THEN   
                   DO:
                       ASSIGN glb_cdcritic = 363.
                       RUN fontes/critic.p.
                       BELL.
                       MESSAGE glb_dscritic.
                       /*CLEAR FRAME f_dados.*/
                       NEXT.
                   END.
              
              IF   tel_cddlinha <> 0                               AND
                   tel_tpdlinha <> 3                               AND
                   NOT CAN-FIND(craplrt WHERE
                                craplrt.cdcooper = glb_cdcooper    
                            AND craplrt.cddlinha = tel_cddlinha
                            AND craplrt.tpdlinha = tel_tpdlinha)   THEN   
                   DO:
                       ASSIGN glb_cdcritic = 0.
                       BELL.
                       MESSAGE "Linha de credito nao e do tipo informado.".
                       /*CLEAR FRAME f_dados.*/
                       NEXT.
                   END.
              
              IF   tel_cddlinha <> 0   THEN
                   DO:
                       FIND craplrt WHERE
                            craplrt.cdcooper = glb_cdcooper   AND
                            craplrt.cddlinha = tel_cddlinha   NO-LOCK NO-ERROR.
                       IF   AVAIL craplrt   THEN
                            ASSIGN tel_dsdlinha = craplrt.dsdlinha.
                       ELSE
                            ASSIGN tel_dsdlinha = "".
                   END.
              ELSE
                   ASSIGN tel_dsdlinha = "".
              
              DISP tel_dsdlinha WITH FRAME f_dados.
              
              LEAVE.
         END.

         IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
              NEXT.

         LEAVE.
     END.                     

     IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
          DO:
              RUN  fontes/novatela.p.
              IF   CAPS(glb_nmdatela) <> "CONSLC"   THEN
                   LEAVE.
              ELSE
                   NEXT.
          END.
      
     
     IF   aux_cddopcao <> glb_cddopcao   THEN
          DO:
              { includes/acesso.i }
              ASSIGN aux_cddopcao = glb_cddopcao
                     glb_cdcritic = 0.
          END.

     MESSAGE "Carregando dados...".
     RUN pi_carrega_dados.
     PAUSE 0.
     

     OPEN QUERY q_cratlim FOR EACH cratlim 
                               BY cratlim.cdagenci
                               BY cratlim.nrdconta.

     QUERY q_cratlim:GET-FIRST().
     
     IF   NOT AVAILABLE cratlim   THEN
          DO:
              HIDE MESSAGE NO-PAUSE.
              MESSAGE "Nenhum Registro Encontrado.".
              PAUSE 3 NO-MESSAGE.
              NEXT.
          END.
          
     IF   glb_cddopcao = "T"   THEN
          DO:
              
              HIDE MESSAGE NO-PAUSE.
              ENABLE b_cratlim WITH FRAME f_cratlim.
              APPLY "VALUE-CHANGED" TO b_cratlim IN FRAME f_cratlim.
              WAIT-FOR END-ERROR OF DEFAULT-WINDOW.     
              HIDE FRAME f_cratlim NO-PAUSE.
             

              
          END.
     ELSE
          DO:
              HIDE MESSAGE NO-PAUSE.
              UPDATE tel_nmdopcao WITH FRAME f_impressao.

              INPUT THROUGH basename `tty` NO-ECHO.
              SET aux_nmendter WITH FRAME f_terminal.
              INPUT CLOSE.

              aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                   aux_nmendter.

              FIND crapcop WHERE 
                   crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
              
              IF  tel_nmdopcao  THEN
                  DO:
                      ASSIGN tel_nmdireto = "/micros/" + crapcop.dsdircop + "/".
                      
                      DISP tel_nmdireto   WITH FRAME f_diretorio.
                      UPDATE tel_nmarquiv WITH FRAME f_diretorio.
                      
                      ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.
                  END.
              ELSE
                  ASSIGN aux_nmarqimp = "rl/conslc.lst".

              /* Inicializa Variaveis Relatorio */
              ASSIGN glb_cdcritic    = 0
                     glb_cdrelato[1] = 580.

              { includes/cabrel132_1.i }

              OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

              VIEW STREAM str_1 FRAME f_cabrel132_1.
              VIEW STREAM str_1 FRAME f_cabec_relat.

              /****** Parametros ******/
              PUT STREAM str_1 SKIP(1) "PARAMETROS: " SKIP(1).

              IF   CAN-FIND(FIRST crawlrt) THEN   
                   DO:
                        DISP STREAM str_1
                             tel_nrdconta
                             tel_cdagenci
                             tel_dtdinici 
                             tel_dtdfinal 
                             tel_tpdlinha 
                             crattip.dsdtplin
                             WITH FRAME f_dados_sem_linha.

                        PUT STREAM str_1 SKIP "LINHAS SELECIONADAS: " SKIP(1).
                   
                        FOR EACH crawlrt:
                            DISP STREAM str_1
                                 crawlrt.cddlinha
                                 crawlrt.dsdlinha
                                 crawlrt.dsdtplin
                                 crawlrt.dsdtxfix
                                 WITH FRAME f_linhas_selecionadas.
                            DOWN WITH FRAME f_linhas_selecionadas.
                        END.
                   END.
              ELSE 
                   DO:
                       IF    tel_cddlinha = 0   THEN
                             ASSIGN tel_dsdlinha = "Todas".

                       DISP STREAM str_1
                            tel_nrdconta
                            tel_cdagenci
                            tel_dtdinici 
                            tel_dtdfinal 
                            tel_tpdlinha 
                            crattip.dsdtplin
                            tel_cddlinha 
                            tel_dsdlinha 
                            WITH FRAME f_dados.
                   END.

              PUT STREAM str_1 SKIP(1).
              /***** Fim Parametros *****/
               ASSIGN aux_totvalor = 0.
               ASSIGN aux_cont = 0.
              FOR EACH cratlim:
                       
                       DISPLAY STREAM str_1
                       cratlim.cdagenci
                       cratlim.nrdconta
                       cratlim.dsdtplin
                       cratlim.dsdlinha
                       cratlim.nrctrlim
                       cratlim.dsdtxfix
                       cratlim.dtinivig  
                       cratlim.datavenc
                       cratlim.vllimite
                       WITH FRAME f_dados_limite.

                       DOWN STREAM str_1 WITH FRAME f_dados_limite.
                    
                        ASSIGN aux_cont = aux_cont + 1     
                         aux_totvalor = aux_totvalor + cratlim.vllimite.


                  
              END.
              PUT STREAM str_1 SKIP(2).                  
              DISP STREAM str_1 aux_cont  aux_totvalor WITH FRAME f_total_limite.

              
              
                       
              OUTPUT STREAM str_1 CLOSE.     
              
              HIDE MESSAGE NO-PAUSE.
              
              IF  tel_nmdopcao  THEN
                  DO:
                      UNIX SILENT VALUE("cp " + aux_nmarqimp + " " + 
                                        aux_nmarqimp + "_copy").
                                                     
                      UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + "_copy" +
                                        ' | tr -d "\032" > ' + aux_nmarqimp +
                                        " 2>/dev/null").
                                  
                      UNIX SILENT VALUE("rm " + aux_nmarqimp + "_copy").
              
                      BELL.
                      MESSAGE "Arquivo gerado com sucesso no diretorio: " + 
                              aux_nmarqimp.
                      PAUSE 3 NO-MESSAGE.
                  END.
              ELSE
                  IF  CAN-FIND(FIRST cratlim)  THEN
                      DO:
                          RUN confirma.
                          IF   aux_confirma = "S"  THEN
                               DO:
                                   ASSIGN  glb_nmformul = "132col"
                                           glb_nrcopias = 1
                                           glb_nmarqimp = aux_nmarqimp.
                                   
                                   FIND FIRST crapass NO-LOCK WHERE 
                                              crapass.cdcooper = glb_cdcooper 
                                              NO-ERROR. 
                               
                                   { includes/impressao.i }
                               END.
                      END.
                  ELSE
                      DO:
                          ASSIGN glb_cdcritic = 263.
                          RUN fontes/critic.p.
                          BELL.
                          MESSAGE glb_dscritic.
                          PAUSE 2 NO-MESSAGE.
                          NEXT.
                      END.
                      
              HIDE FRAME f_diretorio.
              HIDE FRAME f_dados.
          END.
   
     ASSIGN glb_cddopcao = "T".
END.
                
PROCEDURE pi_carrega_dados:
   /*************************************************************************
       Objetivo: Carregar dados para exibicao em tela ou relatorio conforme 
                 parametros de tela
   *************************************************************************/
   EMPTY TEMP-TABLE cratlim.
    /*zerar contadores */    
    ASSIGN aux_cont = 0.
    ASSIGN aux_totvalor=0.

   IF   tel_nrdconta <> 0   THEN /* Filtra 1o. pela conta pra ser mais rapido */
        DO:
            FOR EACH crapass WHERE
                     crapass.cdcooper = glb_cdcooper            AND
                     crapass.nrdconta = tel_nrdconta            NO-LOCK,
                EACH craplim WHERE
                     craplim.cdcooper  = crapass.cdcooper       AND
                     craplim.nrdconta  = crapass.nrdconta       AND
                     craplim.tpctrlim  = 1 /* Chq Especial */   AND
                     craplim.insitlim  = 2 /* Ativo        */   AND 
                     ((tel_dtdinici <> ? AND craplim.dtinivig >= tel_dtdinici) OR TRUE)  
                                                                AND
                     ((tel_dtdfinal <> ? AND craplim.dtinivig <= tel_dtdfinal) OR TRUE)  
                                                                AND
                     TRUE
                     NO-LOCK,
               FIRST craplrt WHERE
                     craplrt.cdcooper = craplim.cdcooper        AND
                     craplrt.cddlinha = craplim.cddlinha        NO-LOCK:

                IF   CAN-FIND(FIRST crawlrt)   AND
                     NOT CAN-FIND(crawlrt WHERE
                                  crawlrt.cdcooper = craplrt.cdcooper    AND
                                  crawlrt.cddlinha = craplrt.cddlinha)   THEN
                     NEXT.

                ASSIGN aux_datavenc = craplim.dtinivig + craplim.qtdiavig.
                

                 /*CONTADOR*/
                IF   tel_cdagenci    <> 0              AND 
                    crapass.cdagenci <> tel_cdagenci   THEN
                        DO:
                            ASSIGN aux_cont = aux_cont.
                            ASSIGN aux_totvalor = aux_totvalor.
                        END.
                ELSE
                        DO:
                            ASSIGN aux_cont = aux_cont + 1.
                            ASSIGN aux_totvalor = aux_totvalor + craplim.vllimite.
                        END.
                /*FINAL CONTADOR*/

                RUN pi_cria_cratlim.


            END.
        END.
   ELSE
      IF   CAN-FIND(FIRST crawlrt)   THEN /* Selecionou uma ou mais linhas */
        DO:
            FOR EACH crawlrt,
               FIRST craplrt WHERE 
                     craplrt.cdcooper  = crawlrt.cdcooper       AND
                     craplrt.cddlinha  = crawlrt.cddlinha       NO-LOCK,
                EACH craplim WHERE
                     craplim.cdcooper  = craplrt.cdcooper       AND
                     craplim.cddlinha  = craplrt.cddlinha       AND
                     craplim.tpctrlim  = 1 /* Chq Especial */   AND
                     craplim.insitlim  = 2 /* Ativo        */   AND 
                     craplim.dtinivig >= tel_dtdinici           AND         
                     craplim.dtinivig <= tel_dtdfinal           NO-LOCK,    
               FIRST crapass WHERE
                     crapass.cdcooper = craplim.cdcooper        AND
                     crapass.nrdconta = craplim.nrdconta        NO-LOCK:

                ASSIGN aux_datavenc = craplim.dtinivig + craplim.qtdiavig.

                /*CONTADOR*/
                IF   tel_cdagenci    <> 0              AND 
                    crapass.cdagenci <> tel_cdagenci   THEN
                        DO:
                            ASSIGN aux_cont = aux_cont.
                            ASSIGN aux_totvalor = aux_totvalor.
                        END.
                ELSE
                        DO:
                            ASSIGN aux_cont = aux_cont + 1.
                            ASSIGN aux_totvalor = aux_totvalor + craplim.vllimite.
                        END.
                /*FINAL CONTADOR*/

                RUN pi_cria_cratlim.
            END.
        END.
   ELSE  /* Nao selecionou linhas, mas filtrou por tipo e/ou codigo */
       IF   tel_tpdlinha <> 3   OR
        tel_cddlinha <> 0   THEN
        DO:
            FOR EACH craplrt WHERE                        
                     craplrt.cdcooper = glb_cdcooper            AND
                    (craplrt.tpdlinha = tel_tpdlinha            
                  OR tel_tpdlinha     = 3)                      AND
                    (craplrt.cddlinha = tel_cddlinha            
                  OR tel_cddlinha     = 0)                      NO-LOCK,
                EACH craplim WHERE
                     craplim.cdcooper  = craplrt.cdcooper       AND
                     craplim.cddlinha  = craplrt.cddlinha       AND
                     craplim.tpctrlim  = 1 /* Chq Especial */   AND
                     craplim.insitlim  = 2 /* Ativo        */   AND 
                     craplim.dtinivig >= tel_dtdinici           AND        
                     craplim.dtinivig <= tel_dtdfinal           NO-LOCK,   
               FIRST crapass WHERE
                     crapass.cdcooper = craplim.cdcooper        AND
                     crapass.nrdconta = craplim.nrdconta        NO-LOCK:

                ASSIGN aux_datavenc = craplim.dtinivig + craplim.qtdiavig.

                /*CONTADOR*/
                IF   tel_cdagenci    <> 0              AND 
                    crapass.cdagenci <> tel_cdagenci   THEN
                        DO:
                            ASSIGN aux_cont = aux_cont.
                            ASSIGN aux_totvalor = aux_totvalor.
                        END.
                ELSE
                        DO:
                            ASSIGN aux_cont = aux_cont + 1.
                            ASSIGN aux_totvalor = aux_totvalor + craplim.vllimite.
                        END.
                /*FINAL CONTADOR*/

                RUN pi_cria_cratlim.
               
            END.
        END.
   ELSE
        DO:
           
            FOR EACH craplim WHERE
                     craplim.cdcooper  = glb_cdcooper           AND
                     craplim.tpctrlim  = 1 /* Chq Especial */   AND
                     craplim.insitlim  = 2 /* Ativo        */   AND 
                     craplim.dtinivig >= tel_dtdinici           AND       
                     craplim.dtinivig <= tel_dtdfinal           NO-LOCK,  
               FIRST crapass WHERE
                      
                     crapass.cdcooper = craplim.cdcooper        AND
                     crapass.nrdconta = craplim.nrdconta        NO-LOCK,
               FIRST craplrt WHERE
                     craplrt.cdcooper = craplim.cdcooper        AND
                     craplrt.cddlinha = craplim.cddlinha        NO-LOCK:
                     

               ASSIGN aux_datavenc = craplim.dtinivig + craplim.qtdiavig.

                /*CONTADOR*/
                IF   tel_cdagenci    <> 0              AND 
                    crapass.cdagenci <> tel_cdagenci   THEN
                        DO:
                            ASSIGN aux_cont = aux_cont.
                            ASSIGN aux_totvalor = aux_totvalor.
                        END.
                ELSE
                        DO:
                            ASSIGN aux_cont = aux_cont + 1.
                            ASSIGN aux_totvalor = aux_totvalor + craplim.vllimite.
                        END.
                /*FINAL CONTADOR*/         
                RUN pi_cria_cratlim.
                
          END.
      END.       
END PROCEDURE. /* Fim pi_carrega_dados */

PROCEDURE pi_cria_cratlim:
   /*************************************************************************
       Objetivo: Carregar dados conforme parametros de tela
   *************************************************************************/
   IF   tel_cdagenci     <> 0              AND 
        crapass.cdagenci <> tel_cdagenci   THEN
        NEXT.

    CREATE cratlim.
    BUFFER-COPY craplim TO cratlim
        ASSIGN cratlim.cdagenci = crapass.cdagenci
               cratlim.nmprimtl = crapass.nmprimtl
               cratlim.dsdlinha = STRING(craplrt.cddlinha,">>9") + "-" +
                                  craplrt.dsdlinha
               cratlim.dsdtxfix = STRING(craplrt.txjurfix,">>9.99%") + " + TR"
               cratlim.dsdtplin = STRING(craplrt.tpdlinha = 1,
                                         "Limite PF/Limite PJ")
               cratlim.datavenc = aux_datavenc.

END PROCEDURE. /* Fim pi_cria_cratlim */

PROCEDURE pi_carrega_linhas:
    /*************************************************************************
       Objetivo: Criar temp-table cratlrt com linhas de credito para selecao
   *************************************************************************/
    EMPTY TEMP-TABLE cratlrt.

    CASE tel_tpdlinha:
        WHEN 1 OR
        WHEN 2 THEN DO:
            FOR EACH craplrt WHERE craplrt.cdcooper = glb_cdcooper AND
                                   craplrt.tpdlinha = tel_tpdlinha NO-LOCK:
                RUN pi_cria_cratlrt.
            END.
        END.
        WHEN 3 THEN DO:
            FOR EACH craplrt WHERE craplrt.cdcooper = glb_cdcooper NO-LOCK:
                RUN pi_cria_cratlrt.
            END.
        END.
    END CASE.

END PROCEDURE. /* Fim pi_carrega_linhas */

PROCEDURE pi_cria_cratlrt:
   /*************************************************************************
       Objetivo: Criar temp-table cratlrt
   *************************************************************************/
    CREATE cratlrt.
    BUFFER-COPY craplrt TO cratlrt
        ASSIGN cratlrt.dsdtxfix = STRING(craplrt.txjurfix,">>9.99%") + " + TR"
               cratlrt.dsdtplin = STRING(craplrt.tpdlinha = 1,
                                         "Limite PF/Limite PJ").
END PROCEDURE. /* Fim pi_cria_cratlrt */

PROCEDURE confirma:
              
   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N"
             glb_cdcritic = 78.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.
            CLEAR FRAME f_cadgps.
        END. /* Mensagem de confirmacao */

END PROCEDURE.
/* .......................................................................... */



