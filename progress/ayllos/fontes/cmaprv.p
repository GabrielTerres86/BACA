/* ...........................................................................

   Programa: Fontes/cmaprv.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego   
   Data    : Maio/2006                         Ultima Atualizacao: 28/05/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar Controle das Propostas de Emprestimo.

   ALTERACAO : 22/06/06 - Adicionado campo de selecao Operador, selecao por
                          Dt.Aprovacao, incluidos campo de data de proposta na
                          frame f_dados e modificado forma de inclusao de dados
                          na tabela crabsit (David).
                         
               24/07/06 - Implementado controle para arquivo vazio na opcao
                          "R" (Diego).

               29/08/06 - Incluidos campos referente Data Proposta e Numero da 
                          Conta, para agilizar a busca (Diego).
                          
               09/10/06 - Consertada validacao no preenchimento dos campos
                          "Dt.Aprov" e "Situacao" (Diego).
               
               18/01/07 - Alterado formato dos campos do tipo DATE de "99/99/99"
                          para "99/99/9999" (Elton).
                          
               14/07/2009 - Alteracao CDOPERAD (Diego).

               02/09/2009 - Aumentar formato da finalidade (Gabriel).
               
               11/09/2009 - Inclusao de campo Motivo e Observacoes na Nao-
                            Aprovacao da Proposta (GATI - Eder)
               
               18/09/2009 - Alteracao na disposicao dos frames e a alteracao da
                            gravacao e do display dos dados da observacao
                            (Elton).
                            
               25/09/2009 - Ajuste no campo Observacao para nao Estourar (Ze).
               
               13/01/2010 - Melhorias referente ao projeto CMAPRV 2 (David).
               
               25/01/2010 - Melhorias no Saldo Utiliza (Ze).
               
               22/07/2010 - Melhorias na Tela - Campo Observacao (Guilherme).
               
               03/08/2010 - Foi posto a opcao de consultar observacoes no frame
                            f_opcoes_alterar na  opcao "A" (Adriano).
                            
               26/08/2010 - Para opcao "R", quando gerar em Arquivo, perguntar
                            se imprime Complemento. Alterado para 234dh.
                            (Guilherme/Supero)
                            
               21/09/2010 - Alterado os campos contidos no relatorio com
                            complementos. (Henrique)
                            
               27/09/2010 - Incluir menu de alteracoes de Obs. para Coops. que
                            nao possuem tratamento de Comite (Ze).
                            
               17/03/2011 - Incluso parametro OUTPUT TABLE tt-impressao-risco-tl
                            (Guilherme).
                            
               12/09/2011 - Adaptado para uso de BO (Rogerius Militao - DB1).
               
               06/03/2012 - Ayllos-Carac. Problema no frame Motivo quando 
                            digitava valor invalido no campo (Guilherme/Supero)
                            
               16/04/2012 - Fonte substituido por cmaprvp.p (Tiago).
               
               06/08/2013 - Incluido parametro nrctremp para procedure
                            Valida_Dados (Tiago).
               
               04/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)   
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)
                            
               16/03/2015 - Incluir campo Parecer de Credito (Jonata-RKAM).
               
               27/05/2015 - Pedir senha do coordenador quando Aprovacao = 3
                            (Gabriel-RKAM).             

               28/05/2015 - Ajustado para sempre imprimir a observacao no 
                            relatorio. Adicionar confirmação para incluir
                            a observação de comite na alteracao da situação da
                            proposta (Douglas - Melhoria 18)
                            
               02/10/2015 - Alterado tratamento de mensagem de retorno da verificação 
                            de motivo para permitir alterar Observação 
                            (Lucas Lunelli SD 323711)
                            
............................................................................. */
{ includes/var_online.i }

{sistema/generico/includes/b1wgen0043tt.i }
{sistema/generico/includes/var_internet.i }
{sistema/generico/includes/b1wgen0114tt.i }
{sistema/generico/includes/b1wgen0059tt.i &VAR-AMB=SIM &BD-GEN=SIM }

DEF   VAR tel_cdagenci AS INT        FORMAT "zz9"                   NO-UNDO.
DEF   VAR tel_dtaprova AS DATE       FORMAT "99/99/9999"            NO-UNDO.
DEF   VAR tel_dtaprfim AS DATE       FORMAT "99/99/9999"            NO-UNDO.
DEF   VAR tel_aprovad1 AS INT        FORMAT "9"                     NO-UNDO.
DEF   VAR tel_aprovad2 AS INT        FORMAT "9"                     NO-UNDO.
DEF   VAR tel_cdopeapv AS CHAR       FORMAT "x(10)"                 NO-UNDO.
DEF   VAR tel_nrdconta AS INT        FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF   VAR tel_dtpropos AS DATE       FORMAT "99/99/9999"            NO-UNDO.
DEF   VAR tel_cdcmaprv AS INTE       FORMAT ">9"                    NO-UNDO.
DEF   VAR tel_dscmaprv AS CHAR       FORMAT "X(60)"                 NO-UNDO.

DEF   VAR tel_dsobscmt AS CHAR                                      NO-UNDO
                       VIEW-AS EDITOR SIZE 67 BY 5 BUFFER-LINES 10 PFCOLOR 0.

DEF   VAR tel_dsobsdet AS CHAR                                      NO-UNDO
                       VIEW-AS EDITOR SIZE 67 BY 8 BUFFER-LINES 15 PFCOLOR 0. 

DEF   VAR aux_cddopcao AS CHAR                                      NO-UNDO.
DEF   VAR aux_nrdconta AS INTE                                      NO-UNDO.
DEF   VAR aux_confirma AS CHAR       FORMAT "x(1)"                  NO-UNDO.
DEF   VAR aux_confimpr AS CHAR       FORMAT "x(1)"                  NO-UNDO.
DEF   VAR aux_confobse AS CHAR       FORMAT "x(1)"                  NO-UNDO.
DEF   VAR aux_insitapv AS INTE                                      NO-UNDO.
DEF   VAR aux_dsaprova AS CHAR       FORMAT "x(20)"                 NO-UNDO.
DEF   VAR aux_dsresapr AS CHAR       FORMAT "x(100)"                NO-UNDO.
DEF   VAR aux_flgaprov AS LOGI                                      NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
DEF   VAR aux_contador AS INT        FORMAT "99"                    NO-UNDO.
DEF   VAR aux_flgindic AS INTE       FORMAT "9"                     NO-UNDO.
DEF   VAR aux_cdcmaprv AS INTE                                      NO-UNDO.
DEF   VAR aux_dscmaprv AS CHAR                                      NO-UNDO.
DEF   VAR aux_flgalter AS LOGICAL                                   NO-UNDO.
DEF   VAR aux_dscomite AS CHAR                                      NO-UNDO.
DEF   VAR aux_dsdircop AS CHAR                                      NO-UNDO.
DEF   VAR aux_nsenhaok AS LOGI                                      NO-UNDO.
DEF   VAR aux_cdoperad AS CHAR                                      NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR       FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF   VAR tel_dscancel AS CHAR       FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.
DEF   VAR tel_nmarquiv AS CHAR       FORMAT "x(25)"                 NO-UNDO.
DEF   VAR tel_nmdireto AS CHAR       FORMAT "x(20)"                 NO-UNDO.

DEF   VAR h-b1wgen0114 AS HANDLE                                    NO-UNDO.

FORM WITH NO-LABEL TITLE COLOR MESSAGE glb_tldatela          
     ROW 4 COLUMN 1 SIZE 80 BY 18 OVERLAY WITH FRAME f_moldura.

FORM glb_cddopcao  AT  1 LABEL "Opcao"
                         HELP "Informe a opcao desejada (A,C ou R)."
                         VALIDATE(CAN-DO("A,C,R", glb_cddopcao),
                                    "014 - Opcao errada.")
     tel_cdagenci        LABEL "  PA "                                     
                         HELP 'Informe o numero do PA ou "0" zero para todos.'
     tel_nrdconta        LABEL "  Conta"
                         HELP 'Informe o numero da conta ou "0" para todas.'
     tel_dtpropos        LABEL "   Proposta a partir de"
                         HELP "Informe a data da proposta."
     SKIP(1)
     "Dt.Aprov:"   AT 02
     tel_dtaprova        NO-LABEL
                         HELP "Informe a Data Inicial."
     "Ate"
     tel_dtaprfim        NO-LABEL
                         HELP "Informe a Data Final." 
     "Situacao:"   AT 39
     tel_aprovad1        NO-LABEL
                         HELP "Informe o codigo da situacao ou F7 p/ listar."
                         VALIDATE(INPUT tel_aprovad1 <= 4,
                                    "444 - Codigo situacao errado.") 
     "Ate"
     tel_aprovad2        NO-LABEL
                         HELP "Informe o codigo da situacao ou F7 p/ listar."
                         VALIDATE(INPUT tel_aprovad2 <= 4,
                                    "444 - Codigo situacao errado.")
                                         
     tel_cdopeapv  AT 58 LABEL "Operador"
                   HELP 'Informe o codigo do operador ou BRANCO para todos.'
             
     WITH ROW 5 COLUMN 2 OVERLAY SIDE-LABELS NO-LABEL NO-BOX FRAME f_opcoes.

FORM tt-cmaprv.qtpreemp    AT  2   LABEL "Qtd. Prestacoes"
     tt-cmaprv.vlpreemp    AT 36   LABEL "Vlr. Prestacao"
                                   FORMAT "zzz,zzz,zz9.99"
     SKIP
     tt-cmaprv.dtmvtolt    AT  4   LABEL "Data Proposta"
     tt-cmaprv.dsstatus    AT 32   LABEL "Parecer de Credito"
     SKIP
     tt-cmaprv.insitapv    AT  8   LABEL "Aprovacao"
     HELP "Informe (1)-Aprovado,(2)-Nao Aprovado,(3)-Restricao,(4)-Refazer"
     VALIDATE(INPUT tt-cmaprv.insitapv <= 4 AND INPUT tt-cmaprv.insitapv > 0,
              "444 - Codigo situacao errado.")
        
     tt-cmaprv.dsaprova    AT 21   NO-LABEL
     tt-cmaprv.cdopeapv    AT 42   LABEL "Operador" FORMAT "x(10)"
     tt-cmaprv.nmoperad    AT 62   NO-LABEL
     SKIP
     tt-cmaprv.dtaprova    AT  3   LABEL "Data Aprovacao"
     tt-cmaprv.hrtransa    AT 46   LABEL "Hora"
     WITH NO-LABEL NO-BOX SIDE-LABELS ROW 17 COLUMN 2 OVERLAY FRAME f_dados.

DEF BUTTON bt_sair LABEL "Sair".

FORM tel_cdcmaprv                AT 2        LABEL "Motivo"
           HELP "Informe o codigo do motivo ou F7 p/ listar."
     "-"
     tel_dscmaprv                            NO-LABEL
     WITH SIDE-LABELS OVERLAY CENTERED ROW 9 WIDTH 78
          FRAME f_motivo_naoaprov1.

FORM tel_dsobscmt AT 2   
       HELP "Use a tecla <F4> para sair ou <TAB> para continuar"  NO-LABEL  
     SKIP
     bt_sair      AT 32  HELP "Tecle <ENTER> para confirmar a observacao"
     WITH SIDE-LABELS OVERLAY CENTERED ROW 3 WIDTH 71 TITLE " Observacao  "
          FRAME f_motivo_naoaprov2.
                                                             
FORM tel_dsobsdet AT 2 NO-LABEL  SKIP
     WITH SIDE-LABELS OVERLAY CENTERED ROW 9 WIDTH 70 TITLE " Observacao  "
          FRAME f_det_observ.

FORM SKIP(1)
     "Diretorio:   "     AT 5
     tel_nmdireto
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     SKIP(1)
     WITH OVERLAY CENTERED NO-LABEL WIDTH 70 ROW 10 FRAME f_diretorio.

DEF QUERY q_emprestimos FOR tt-cmaprv.
                                         
DEF BROWSE b_emprestimos  QUERY q_emprestimos
    DISPLAY tt-cmaprv.cdagenci  COLUMN-LABEL "PA" 
            tt-cmaprv.dtmvtolt  COLUMN-LABEL "Data"
            tt-cmaprv.nrdconta  COLUMN-LABEL "Conta/dv"
            tt-cmaprv.nrctremp  COLUMN-LABEL "Contrato"
            tt-cmaprv.vlemprst  COLUMN-LABEL "Emprestado"
            tt-cmaprv.cdlcremp  COLUMN-LABEL "Linha Cred."
            tt-cmaprv.cdfinemp  COLUMN-LABEL "Finalid."
            WITH 5 DOWN WIDTH 78 OVERLAY.
                                            
FORM b_emprestimos 
        HELP "Use as <SETAS> p/ navegar, <F4> p/ sair e <ENTER> p/ detalhar."
     SKIP                                                    
     WITH NO-BOX ROW 8 COLUMN 2 OVERLAY FRAME f_emprestimos.

DEF QUERY  q_situacao FOR crabsit.

DEF BROWSE b_situacao QUERY q_situacao
      DISP SPACE(6)
           crabsit.insitapv              
           crabsit.dssitapv             
           WITH 5 DOWN  NO-LABEL OVERLAY.    

DEF FRAME f_situacoes
          b_situacao 
          HELP "Use as <SETAS> p/ navegar, <F4> p/ sair e <ENTER> p/ detalhar." 
          SKIP 
          WITH NO-BOX OVERLAY ROW 8 COLUMN 51.

DEF VAR tel_btaltobs AS CHAR INIT "Alterar as Observacoes Anteriores"   NO-UNDO.
DEF VAR tel_btnovobs AS CHAR INIT "     Incluir Nova Observacao     "   NO-UNDO.
DEF VAR tel_btcnsobs AS CHAR INIT "      Consultar Observacao       "   NO-UNDO.

FORM SKIP(1)
     tel_btaltobs NO-LABEL AT 04 FORMAT "x(33)" 
     SKIP(1)
     tel_btnovobs NO-LABEL AT 04 FORMAT "x(33)"
     SKIP(1) 
     tel_btcnsobs NO-LABEL AT 04 FORMAT "x(33)"
     SKIP(1)
     WITH OVERLAY CENTERED TITLE COLOR NORMAL " Alterar Observacao ? " 
          WIDTH 40 ROW 10 FRAME f_opcoes_alterar.


ON "GO","RETURN" OF tel_cdcmaprv IN FRAME f_motivo_naoaprov1
   DO:

      IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
          RUN sistema/generico/procedures/b1wgen0059.p
              PERSISTENT SET h-b1wgen0059.
      RUN busca-gncmapr IN h-b1wgen0059
          ( INPUT INPUT tel_cdcmaprv,
            INPUT "ZM",  /* Resolver problema do Cod 0 06/03/2012 */
            INPUT 999999,
            INPUT 1,
           OUTPUT aux_qtregist,
           OUTPUT TABLE tt-gncmapr ).
    
      DELETE PROCEDURE h-b1wgen0059.

      FIND FIRST tt-gncmapr
           NO-ERROR.
      
      IF  AVAILABLE tt-gncmapr THEN
          ASSIGN tel_dscmaprv = tt-gncmapr.dscmaprv.

       DISP tel_dscmaprv WITH FRAME f_motivo_naoaprov1.
   END.

ON "END-ERROR" OF tel_dsobscmt IN FRAME f_motivo_naoaprov2
   DO:
       NEXT-PROMPT bt_sair WITH FRAME f_motivo_naoaprov2.
       RETURN NO-APPLY.
   END.
       
ON "RETURN" OF bt_sair IN FRAME f_motivo_naoaprov2
   DO:
        HIDE FRAME f_motivo_naoaprov1.
        HIDE FRAME f_motivo_naoaprov2. 
        APPLY "GO". 
   END.           

ON "RETURN" OF tel_dsobscmt IN FRAME f_motivo_naoaprov2
   APPLY 32.

ON "RETURN" OF tel_cdcmaprv IN FRAME f_motivo_naoaprov1
   APPLY "GO" TO SELF.

ON "VALUE-CHANGED", "ENTRY" OF b_emprestimos
   DO:
       IF   AVAILABLE tt-cmaprv  THEN
            DO: 
                DISPLAY 
                   tt-cmaprv.qtpreemp tt-cmaprv.vlpreemp tt-cmaprv.insitapv 
                   tt-cmaprv.dsaprova tt-cmaprv.cdopeapv tt-cmaprv.nmoperad
                   tt-cmaprv.dtaprova tt-cmaprv.dtmvtolt tt-cmaprv.dsstatus 
                   STRING(tt-cmaprv.hrtransa,"HH:MM:SS") @ tt-cmaprv.hrtransa
                   WITH FRAME f_dados.
            END.
   END.     

        
/* Retorna Emprestimo */    
ON "RETURN" OF b_emprestimos
   DO:
       IF   glb_cddopcao = "A"   THEN
            DO: 
                HIDE MESSAGE NO-PAUSE.
                
                RUN Valida_Dados.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN NO-APPLY.
                
                IF   AVAILABLE tt-cmaprv THEN
                     DO:
                            
                          DISP tt-cmaprv.dsaprova WITH FRAME f_dados.
                          PAUSE 0.
                          HIDE FRAME f_motivo_naoaprov1 
                               FRAME f_motivo_naoaprov2 NO-PAUSE.
                            
                          ASSIGN aux_insitapv = tt-cmaprv.insitapv.
                          UPDATE tt-cmaprv.insitapv WITH FRAME f_dados.
                          
                          IF   tt-cmaprv.insitapv = 1   THEN
                               ASSIGN aux_dsaprova = "Aprovado"
                                      aux_dsresapr = "".
                          ELSE
                          IF   tt-cmaprv.insitapv = 2   THEN
                               ASSIGN aux_dsaprova = "Nao Aprovado"
                                      aux_dsresapr = "NA :".
                          ELSE
                          IF   tt-cmaprv.insitapv = 3   THEN
                               ASSIGN aux_dsaprova = "Com Restric."
                                      aux_dsresapr = "AR :".
                          ELSE
                          IF   tt-cmaprv.insitapv = 4   THEN
                               ASSIGN aux_dsaprova = "Refazer"
                                      aux_dsresapr = "RF :".
                          ELSE
                               ASSIGN aux_dsaprova = ""
                                      aux_dsresapr = "".

                          IF  aux_dsaprova <> "" AND aux_dscomite <> "" THEN
                              ASSIGN tt-cmaprv.dsaprova = aux_dsaprova + " - " + aux_dscomite.
                            
                          DISP tt-cmaprv.dsaprova WITH FRAME f_dados.
                          PAUSE 0.
                                      
                          RUN Verifica_Rating.

                          IF   RETURN-VALUE = "NOK"   THEN
                               NEXT.
                          
                          /* Solicitar a confirmação para incluir observação apenas quando alterar para a situação: 
                             0 - Não Analisado / 1 - Aprovado / 4 - Refazer
                             */
                          IF tt-cmaprv.insitapv = 0 OR tt-cmaprv.insitapv = 1 OR tt-cmaprv.insitapv = 4 THEN
                          DO:

                              /* Confirmacao para incluir a observacao */
                              DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            
                                  ASSIGN aux_confobse = "S".
                                  RUN fontes/critic.p.
                                  ASSIGN glb_cdcritic = 0.
                                  BELL.
                                  MESSAGE COLOR NORMAL "Deseja Incluir Observacao do Comite? (S/N):" 
                                          UPDATE aux_confobse.
                                  LEAVE.
                              END.  /*  Fim do DO WHILE TRUE  */
                        
                              /* Se END-ERROR mostra a critica de operacao nao efetuada*/
                              IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                                  DO:
                                      glb_cdcritic = 79.
                                      RUN fontes/critic.p.
                                      BELL.
                                      MESSAGE glb_dscritic.
                                      glb_cdcritic = 0.
                                      NEXT.
                                  END.
                          END.
                          ELSE 
                              ASSIGN aux_confobse = "S". /* Caso contrário sempre solicita*/

                          /* Se confirmar a observacao, verefica e solicita inclusao 
                             se for "N" não faz nada */
                          IF aux_confobse = "S" THEN
                          DO:
                              /* Se incluir observacao, verifica o motivo */
                              RUN Verifica_Motivo.
                              IF   RETURN-VALUE = "NOK"   THEN
                                   UNDO.
                          END.

                          /* Confirmacao da operacao */
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               ASSIGN aux_confirma = "N"
                                      glb_cdcritic = 78.
                               RUN fontes/critic.p.
                               BELL.
                               MESSAGE COLOR NORMAL glb_dscritic 
                                       UPDATE aux_confirma.
                               ASSIGN glb_cdcritic = 0.
                               LEAVE.
                          END.
                        
                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                               aux_confirma <> "S"                  THEN
                               DO:
                                   ASSIGN tt-cmaprv.insitapv = aux_insitapv
                                          glb_cdcritic       = 79.
                                   RUN fontes/critic.p.
                                   BELL.
                                   MESSAGE glb_dscritic.
                                   ASSIGN glb_cdcritic = 0.
                                   NEXT.
                               END.

                          /* Pedir senha do Coordenador */
                          IF  (tt-cmaprv.insitapv = 1   OR 
                               tt-cmaprv.insitapv = 3)  AND
                              tt-cmaprv.instatus = 3   THEN
                              DO:
                                  RUN fontes/pedesenha.p (INPUT glb_cdcooper,
                                                          INPUT 2,
                                                         OUTPUT aux_nsenhaok,
                                                         OUTPUT aux_cdoperad).

                                  IF  NOT aux_nsenhaok  THEN
                                      UNDO, NEXT.
                              END.

                          RUN Grava_Dados.
                            
                          IF   RETURN-VALUE = "NOK"   THEN
                               UNDO.

                     END. /* IF   AVAILABLE tt-cmaprv */
            END. /* IF   glb_cddopcao = "A" */
       ELSE    
       IF   glb_cddopcao = "C"   THEN
            DO:    
                IF   AVAILABLE tt-cmaprv   THEN
                     DO: 
                         tel_dsobsdet = tt-cmaprv.dsobscmt.
                         
                         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:     
                            
                            DISP tel_dsobsdet WITH FRAME f_det_observ.
                                            
                            PAUSE MESSAGE 
                               "Pressione qualquer tecla pra continuar...".
                                               
                            HIDE FRAME f_det_observ NO-PAUSE.      
                            LEAVE.                                           
                         END.  
                         
                         HIDE FRAME f_det_observ NO-PAUSE.
                     END. /* IF   AVAILABLE tt-cmaprv */
            END. /* IF   glb_cddopcao = "C" */
                   
   END. /* ON "RETURN" OF b_emprestimos */
                 
/* Retorna Situacao */    
ON RETURN OF b_situacao
   DO:    
       IF   NOT AVAILABLE crabsit  THEN
            DO:
                glb_cdcritic = 444.
                RUN fontes/critic.p.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                NEXT.
            END.
       
       IF   aux_flgaprov  THEN
            DO:
                ASSIGN tel_aprovad1 = crabsit.insitapv.
                DISPLAY tel_aprovad1 WITH FRAME f_opcoes.
            END.
       ELSE
            DO:
                ASSIGN tel_aprovad2 = crabsit.insitapv.
                DISPLAY tel_aprovad2 WITH FRAME f_opcoes.
            END.
       
       APPLY "GO".
   END.

RUN fontes/inicia.p.

VIEW FRAME f_moldura. 
PAUSE(0).                           

ASSIGN glb_cddopcao = "C".

RUN Busca_Titulo.

IF  RETURN-VALUE = "NOK"  THEN
    RETURN.

RUN p_cria_situacao.

ASSIGN FRAME f_motivo_naoaprov2:FRAME  = FRAME f_motivo_naoaprov1:HANDLE
       FRAME f_motivo_naoaprov1:HEIGHT = 12.    

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    HIDE FRAME f_motivo_naoaprov2 
         FRAME f_motivo_naoaprov1 NO-PAUSE.
       
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
       UPDATE glb_cddopcao WITH FRAME f_opcoes.
       LEAVE.
          
    END.
       
    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
         DO:
             RUN fontes/novatela.p.
             IF   CAPS(glb_nmdatela) <> "CMAPRV"   THEN
                  DO:
                     IF  VALID-HANDLE(h-b1wgen0114) THEN
                         DELETE OBJECT h-b1wgen0114.
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
  
    IF   glb_cddopcao = "A"  OR 
         glb_cddopcao = "C"  THEN
         DO:
             RUN p_selecao. 
                                        
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                  RETURN.
             
             RUN Busca_Dados.
             
             IF  RETURN-VALUE <> "OK" THEN
                 NEXT.
             
             OPEN QUERY q_emprestimos FOR EACH tt-cmaprv.
                 
             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                UPDATE b_emprestimos WITH FRAME f_emprestimos.
                LEAVE.
             END.

             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  DO:
                      HIDE FRAME f_emprestimos.
                      HIDE FRAME f_dados.

                      ASSIGN tel_nrdconta = 0
                             tel_dtpropos = ?
                             tel_cdagenci = 0
                             tel_dtaprova = ?
                             tel_dtaprfim = ?
                             tel_aprovad1 = 0
                             tel_aprovad2 = 0
                             tel_cdopeapv = " ". 
                  END.

         END.
    ELSE
    IF   glb_cddopcao = "R"  THEN
         DO:
             RUN p_selecao.
             
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                  RETURN.
                      
             RUN Valida_Dados.
             
             IF  RETURN-VALUE <> "OK" THEN
                 NEXT.

             DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                ASSIGN aux_confimpr = "N".
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
                BELL.
                MESSAGE COLOR NORMAL "Gerar Relatorio em Arquivo ? (S/N):" 
                        UPDATE aux_confimpr.
                LEAVE.
             END.  /*  Fim do DO WHILE TRUE  */
    
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                  DO:
                      glb_cdcritic = 79.
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      NEXT.
                  END.
             
             IF  aux_confimpr <> "S" THEN
                 ASSIGN aux_confimpr = "N".

             IF   aux_confimpr = "S" THEN
                  DO:
                     ASSIGN tel_nmdireto = "/micros/" + LC(aux_dsdircop) + "/".
                     DISPLAY tel_nmdireto WITH FRAME f_diretorio.
                     UPDATE tel_nmarquiv WITH FRAME f_diretorio.
                     ASSIGN aux_nmarqimp = tel_nmdireto + tel_nmarquiv.
                     HIDE FRAME f_diretorio.
                  END.
             

             RUN Gera_Impressao.
             
         END.

END. /* Do While */
                                    
IF  VALID-HANDLE(h-b1wgen0114) THEN
    DELETE OBJECT h-b1wgen0114.

/*********************************PROCEDURES**********************************/

PROCEDURE p_cria_situacao. 

    /* Cria situacoes para BROWSE b_situacao */
    DO  aux_flgindic = 0 TO 4:
        DO:
            CREATE crabsit.
        
            ASSIGN crabsit.insitapv = aux_flgindic
                   crabsit.dssitapv = IF aux_flgindic = 0 THEN
                                         "Nao Analisado"
                                      ELSE
                                      IF aux_flgindic = 1 THEN
                                         "Aprovado"
                                      ELSE
                                      IF aux_flgindic = 2 THEN
                                         "Nao Aprovado"
                                      ELSE
                                      IF aux_flgindic = 3 THEN
                                         "Com Restricao"
                                      ELSE   
                                      "Refazer".
        END.
        
    END. /* Fim do DO */
    
END PROCEDURE.
 
PROCEDURE p_selecao.

   UPDATE tel_cdagenci WITH FRAME f_opcoes.
   
   IF   tel_cdagenci <> 0  THEN
        DO:
            UPDATE tel_dtpropos tel_dtaprova tel_dtaprfim tel_aprovad1 
                   tel_aprovad2 tel_cdopeapv WITH FRAME f_opcoes
                   
            EDITING:
                        
              DO WHILE TRUE:
               
                 READKEY PAUSE 1.
           
                 IF   LASTKEY = KEYCODE("F7")   AND
                     (FRAME-FIELD = "tel_aprovad1" OR 
                      FRAME-FIELD = "tel_aprovad2")  THEN
                      DO:
                          IF   FRAME-FIELD = "tel_aprovad1"  THEN
                               ASSIGN aux_flgaprov = TRUE.
                          ELSE
                               ASSIGN aux_flgaprov = FALSE.
                 
                          OPEN QUERY q_situacao FOR EACH crabsit.
                  
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                             UPDATE b_situacao WITH FRAME f_situacoes.
                             LEAVE.
                          END.
                          
                          HIDE FRAME f_situacoes.
                          NEXT.

                      END.
                  
                 APPLY LASTKEY.
                 LEAVE.

              END. /* fim DO WHILE */
            END. /* fim do EDITING */
        END.
   ELSE
        DO:
            UPDATE tel_nrdconta tel_dtpropos tel_dtaprova tel_dtaprfim 
                   tel_aprovad1 tel_aprovad2 tel_cdopeapv WITH FRAME f_opcoes
   
            EDITING:
                        
              DO WHILE TRUE:
                 READKEY.
                 IF   LASTKEY = KEYCODE("F7")  THEN
                      DO:

                         IF  FRAME-FIELD = "tel_nrdconta"   AND
                             LASTKEY = KEYCODE("F7")        THEN
                             DO: 
                                 RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                               OUTPUT aux_nrdconta).
    
                                 IF  aux_nrdconta > 0   THEN
                                     DO:
                                         ASSIGN tel_nrdconta = aux_nrdconta.
                                         DISPLAY tel_nrdconta WITH FRAME f_opcoes.
                                         PAUSE 0.
                                         APPLY "RETURN".
                                     END.
                             END.
                         ELSE 
                             IF  (FRAME-FIELD = "tel_aprovad1" OR 
                              FRAME-FIELD = "tel_aprovad2")  THEN
                              DO:
                                  IF   FRAME-FIELD = "tel_aprovad1"  THEN
                                       ASSIGN aux_flgaprov = TRUE.
                                  ELSE
                                        ASSIGN aux_flgaprov = FALSE.
                         
                                  OPEN QUERY q_situacao FOR EACH crabsit.
                         
                                  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                     UPDATE b_situacao WITH FRAME f_situacoes.
                                     LEAVE.
                                  END.
                                  
                                  HIDE FRAME f_situacoes.
                                  NEXT.
                              END.
                       END.
                 ELSE 
                    APPLY LASTKEY.

                 LEAVE.
                 
              END. /* fim DO WHILE */
            END. /* fim do EDITING */
        END.

END PROCEDURE.

PROCEDURE confirma.

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     ASSIGN aux_confirma = "N"
            glb_cdcritic = 78.
     RUN fontes/critic.p.
     ASSIGN glb_cdcritic = 0.
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

PROCEDURE pi_motivo_nao_aprov.

   /*************************************************************************
        Objetivo: Solicitar motivo e complemento de nao-aprovacao
    *************************************************************************/
   DEF     INPUT PARAM par_cdcomite    AS INTEGER                  NO-UNDO.
   DEF     INPUT PARAM par_dsobscmt    AS CHAR                     NO-UNDO.
   DEF     INPUT PARAM par_flgcmtlc    AS LOGICAL                  NO-UNDO.
   DEF    OUTPUT PARAM par_flgalter    AS LOGICAL                  NO-UNDO.
  
   ASSIGN tel_cdcmaprv = 0
          tel_dscmaprv = "". 
          
   IF   par_dsobscmt <> ""    AND
      ((par_flgcmtlc = TRUE   AND    /* Comite Sede */
        par_cdcomite = 2)         OR
        par_flgcmtlc = FALSE) THEN   /* Nao possui comite */
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               HIDE FRAME f_det_observ NO-PAUSE.

               DISPLAY tel_btaltobs tel_btnovobs tel_btcnsobs 
                       WITH FRAME f_opcoes_alterar.

               CHOOSE FIELD tel_btaltobs tel_btnovobs tel_btcnsobs 
                            WITH FRAME f_opcoes_alterar.

               ASSIGN par_flgalter = FRAME-VALUE = tel_btaltobs.

               HIDE FRAME f_opcoes_alterar NO-PAUSE.

               IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    DO:   /* F4 OU FIM */
                       LEAVE.
                    END.

               IF   FRAME-VALUE = tel_btcnsobs THEN
                    DO:
                        IF   AVAILABLE tt-cmaprv   THEN
                             DO: 
                                 tel_dsobsdet = tt-cmaprv.dsobscmt.
                        
                                 DISP tel_dsobsdet WITH FRAME f_det_observ.
                                            
                                 PAUSE MESSAGE 
                                    "Pressione qualquer tecla pra continuar...".
                      
                                 HIDE FRAME f_det_observ NO-PAUSE.
                             END.  
                    END.
               ELSE
                    LEAVE.
            END.
            
            HIDE FRAME f_opcoes_alterar NO-PAUSE.

            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 RETURN "NOK".
        END.
   ELSE
        par_flgalter = FALSE.
   
   ASSIGN tt-cmaprv.dsobscmt = par_dsobscmt.

   
   /***** Preencher com Resumido da Aprvacao na area de complemento */
   IF   par_flgalter THEN
        tel_dsobscmt = aux_dsresapr + par_dsobscmt.
   ELSE
        tel_dsobscmt = aux_dsresapr + "".
       
   DO   WHILE TRUE ON ENDKEY UNDO, LEAVE
                   ON ERROR  UNDO, LEAVE:
                                                       
        ENABLE ALL        WITH FRAME f_motivo_naoaprov1.            
        DISP tel_dscmaprv WITH FRAME f_motivo_naoaprov1. 
        DISP tel_dsobscmt WITH FRAME f_motivo_naoaprov2.
        PAUSE 0.         

        IF   NOT par_flgalter THEN /* Incluir Nova Observacao  */
             DO:
                 UPDATE tel_cdcmaprv WITH FRAME f_motivo_naoaprov1
                 EDITING:
               
                 READKEY.
                 
                 IF   LASTKEY = KEYCODE("F7")   THEN
                      DO:
                          RUN fontes/zoom_motivo_nao_aprovacao.p 
                                         (OUTPUT aux_cdcmaprv,
                                          OUTPUT aux_dscmaprv).
                            
                          IF   RETURN-VALUE = "NOK"   THEN
                               UNDO.
                            
                          ASSIGN tel_cdcmaprv = aux_cdcmaprv
                                 tel_dscmaprv = aux_dscmaprv.
                          DISP tel_cdcmaprv
                               tel_dscmaprv
                               WITH FRAME f_motivo_naoaprov1.
                            
                          PAUSE 0.     
                       
                          APPLY "GO" TO tel_cdcmaprv IN
                                FRAME f_motivo_naoaprov1.
                      END.
                  
                 APPLY LASTKEY.

                 END. /* fim do EDITING */
                 
                 FIND gncmapr WHERE gncmapr.cdcmaprv = tel_cdcmaprv 
                                    NO-LOCK NO-ERROR.
                 
                 IF  AVAIL gncmapr THEN
                     ASSIGN tel_dscmaprv = gncmapr.dscmaprv.
                    
             END.       

        UPDATE tel_dsobscmt bt_sair WITH FRAME f_motivo_naoaprov2.

        IF   SUBSTR(tel_dsobscmt,1,4) <> aux_dsresapr THEN
             tel_dsobscmt = aux_dsresapr + tel_dsobscmt.
        
        LEAVE.

   END.

  IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
       DO:
           HIDE FRAME f_motivo_naoaprov1 NO-PAUSE.
           HIDE FRAME f_motivo_naoaprov2 NO-PAUSE.
           RETURN "NOK".
       END.
   
   RETURN "OK".
      
   
END PROCEDURE. /* pi_motivo_nao_aprov */

/* ......................................................................... */

PROCEDURE Busca_Titulo:
    
    DEF VAR aux_tldatela AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0114) THEN
        RUN sistema/generico/procedures/b1wgen0114.p
            PERSISTENT SET h-b1wgen0114.

    RUN Busca_Titulo IN h-b1wgen0114
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT 1,
         OUTPUT aux_dscomite,
         OUTPUT aux_dsdircop,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0114) THEN
        DELETE OBJECT h-b1wgen0114.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
 
             FIND FIRST tt-erro NO-ERROR.
 
             IF  AVAILABLE tt-erro THEN 
             DO:
                 HIDE FRAME f_moldura.
                 PAUSE(0).
 
                 ASSIGN glb_nmdatela = "MENU00".
 
                 BELL.
                 MESSAGE tt-erro.dscritic.
             END.
                    
             RETURN "NOK".  
         END.
     ELSE
         DO:
             
             IF  aux_dscomite <> ""  THEN
                 ASSIGN aux_tldatela = " Comite Aprova - Comite " + aux_dscomite.
             ELSE 
                 ASSIGN aux_tldatela = " Comite Aprova ".

             ASSIGN glb_tldatela = aux_tldatela + SUBSTR(glb_tldatela,INDEX(glb_tldatela,"(")).
             
             FRAME f_moldura:TITLE = glb_tldatela.
 
             RETURN "OK".
         END.

END PROCEDURE. /* Busca_Titulo */


PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-cmaprv.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0114) THEN
        RUN sistema/generico/procedures/b1wgen0114.p
            PERSISTENT SET h-b1wgen0114.

    RUN Busca_Dados IN h-b1wgen0114
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_inproces,
          INPUT glb_cddopcao,     
          INPUT tel_cdagenci,
          INPUT tel_nrdconta,
          INPUT tel_dtpropos,
          INPUT tel_dtaprova,
          INPUT tel_dtaprfim,
          INPUT tel_aprovad1,
          INPUT tel_aprovad2,
          INPUT tel_cdopeapv,
          INPUT 1,
          INPUT 999999999,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-cmaprv,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0114) THEN
        DELETE OBJECT h-b1wgen0114.
 
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
 
             FIND FIRST tt-erro NO-ERROR.
 
             IF  AVAILABLE tt-erro THEN
                 MESSAGE tt-erro.dscritic.
                    
             RETURN "NOK".  
         END.
     
     RETURN "OK".

END PROCEDURE. /* Busca_Dados */


PROCEDURE Valida_Dados:
    
    DEF VAR aux_nrdcont1 AS INTE                    NO-UNDO.
    DEF VAR aux_nrctrliq AS CHAR                    NO-UNDO.
    DEF VAR aux_vlemprst AS DECI                    NO-UNDO.
    DEF VAR aux_nrctremp LIKE crawepr.nrctremp      NO-UNDO.

    IF  AVAIL tt-cmaprv THEN 
        DO:
            ASSIGN  aux_nrdcont1 = tt-cmaprv.nrdconta
                    aux_nrctrliq = tt-cmaprv.nrctrliq
                    aux_vlemprst = tt-cmaprv.vlemprst
                    aux_nrctremp = tt-cmaprv.nrctremp.
        END.
    
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0114) THEN
        RUN sistema/generico/procedures/b1wgen0114.p
            PERSISTENT SET h-b1wgen0114.

    RUN Valida_Dados IN h-b1wgen0114
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_inproces,
          INPUT glb_cddopcao,     
          INPUT tel_nrdconta,
          INPUT tel_dtpropos,
          INPUT tel_dtaprova,
          INPUT tel_dtaprfim,
          INPUT tel_aprovad1,
          INPUT tel_aprovad2,
          INPUT aux_nrdcont1,
          INPUT aux_nrctrliq,
          INPUT aux_vlemprst,
          INPUT YES,
          INPUT aux_nrctremp, 
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0114) THEN
        DELETE OBJECT h-b1wgen0114.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
 
             FIND FIRST tt-erro NO-ERROR.
                
             IF  AVAILABLE tt-erro THEN
                 MESSAGE tt-erro.dscritic.
                    
             RETURN "NOK".  
         END.
     
     RETURN "OK".

END PROCEDURE. /* Valida_Dados */


PROCEDURE Verifica_Rating:
    
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgretor AS CHAR                                    NO-UNDO.
    DEF VAR aux_confirma AS CHAR FORMAT "x(1)"                      NO-UNDO.

    MESSAGE "Aguarde, verificando Rating...".

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0114) THEN
        RUN sistema/generico/procedures/b1wgen0114.p
            PERSISTENT SET h-b1wgen0114.

    RUN Verifica_Rating IN h-b1wgen0114
        (INPUT glb_cdcooper,
         INPUT 0, /* cdagenci */
         INPUT 0, /* nrdcaixa */
         INPUT glb_cdoperad,
         INPUT 1, /* idorigem */
         INPUT glb_nmdatela,
         INPUT glb_dtmvtolt,
         INPUT glb_dtmvtopr,
         INPUT glb_inproces,
         INPUT tt-cmaprv.nrdconta,
         INPUT tt-cmaprv.nrctremp,
        OUTPUT aux_msgalert,
        OUTPUT aux_msgretor,
        OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0114) THEN
        DELETE OBJECT h-b1wgen0114.
 
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
 
             FIND FIRST tt-erro NO-ERROR.
 
             IF  AVAILABLE tt-erro THEN
                 MESSAGE tt-erro.dscritic.
                    
             RETURN "NOK".  
         END.
    ELSE 
        DO:
            IF  aux_msgalert <> "" THEN
                DO:
                    BELL.
                    MESSAGE aux_msgalert.
                    PAUSE 5 NO-MESSAGE.
                END.
            ELSE 
                IF  aux_msgretor <> ""  THEN
                    DO:
                        ASSIGN aux_confirma = "N".
                        BELL.
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                              
                            MESSAGE COLOR NORMAL aux_msgretor UPDATE aux_confirma.
                            LEAVE.
                        END.

                        IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                             aux_confirma <> "S"                  THEN
                             DO:
                                 ASSIGN glb_cdcritic = 79.
                                 RUN fontes/critic.p.
                                 BELL.
                                 MESSAGE glb_dscritic.
                                 ASSIGN glb_cdcritic = 0.
                                 RETURN "NOK".
                             END.

                    END.

        END.

    HIDE MESSAGE NO-PAUSE.

    RETURN "OK".

END PROCEDURE. /* Verifica_Rating */


PROCEDURE Verifica_Motivo:
    
    DEF VAR aux_cdcomite AS INTE                                    NO-UNDO.
    DEF VAR aux_dsobscmt AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgcmtlc AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_msgretur AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0114) THEN
        RUN sistema/generico/procedures/b1wgen0114.p
            PERSISTENT SET h-b1wgen0114.

    RUN Verifica_Motivo IN h-b1wgen0114
        (INPUT glb_cdcooper,
         INPUT glb_cdoperad,
         INPUT glb_nmdatela,
         INPUT glb_cdagenci,
         INPUT 0,
         INPUT 1,
         INPUT tt-cmaprv.nrdconta, 
         INPUT tt-cmaprv.nrctremp,
         INPUT TRUE,
        OUTPUT aux_cdcomite, 
        OUTPUT aux_dsobscmt, 
        OUTPUT aux_flgcmtlc, 
        OUTPUT aux_msgretur,
        OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0114) THEN
        DELETE OBJECT h-b1wgen0114.
 
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
 
             FIND FIRST tt-erro NO-ERROR.
 
             IF  AVAILABLE tt-erro THEN
                 MESSAGE tt-erro.dscritic.
                    
             RETURN "NOK".  
         END.
    ELSE 
        DO:
             IF   aux_msgretur <> "" THEN
                  DO:
                     MESSAGE aux_msgretur.
                     PAUSE 5 NO-MESSAGE.
                  END.   

             RUN pi_motivo_nao_aprov(
                    INPUT aux_cdcomite,
                    INPUT aux_dsobscmt,
                    INPUT aux_flgcmtlc,
                   OUTPUT aux_flgalter).
             
             IF   RETURN-VALUE = "NOK"   THEN
                  RETURN "NOK". 
             
             ASSIGN tt-cmaprv.dsobscmt = "".
    END.


    RETURN "OK".

END PROCEDURE. /* Verifica_Motivo */


PROCEDURE Grava_Dados:
    
    EMPTY TEMP-TABLE tt-emprestimo.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0114) THEN
        RUN sistema/generico/procedures/b1wgen0114.p
            PERSISTENT SET h-b1wgen0114.

    RUN Grava_Dados IN h-b1wgen0114
        (INPUT glb_cdcooper,
         INPUT glb_cdagenci,
         INPUT 0,
         INPUT glb_nmdatela,
         INPUT 1,
         INPUT glb_dtmvtolt,
         INPUT glb_cdoperad,
         INPUT tt-cmaprv.nrdconta,
         INPUT tt-cmaprv.nrctremp,
         INPUT tt-cmaprv.insitapv,
         INPUT tt-cmaprv.dsobscmt,
         INPUT tel_dsobscmt,
         INPUT tel_dscmaprv,
         INPUT aux_flgalter,
         INPUT aux_insitapv,
         INPUT TRUE,
        OUTPUT TABLE tt-emprestimo,
        OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0114) THEN
        DELETE OBJECT h-b1wgen0114.
 
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
                                     
             FIND FIRST tt-erro NO-ERROR.
 
             IF  AVAILABLE tt-erro THEN
             DO: 
                 
                 MESSAGE tt-erro.dscritic VIEW-AS ALERT-BOX.
             END.   
             RETURN "NOK".  
         END.
    ELSE 

       IF  tt-cmaprv.insitapv <> aux_insitapv  THEN
            DO:
    
                FIND FIRST tt-emprestimo NO-ERROR.
                
                IF  AVAIL tt-emprestimo THEN 
                    DO:
                        ASSIGN tt-cmaprv.cdopeapv = tt-emprestimo.cdopeapv
                               tt-cmaprv.nmoperad = tt-emprestimo.nmoperad
                               tt-cmaprv.dtaprova = tt-emprestimo.dtaprova
                               tt-cmaprv.hrtransa = tt-emprestimo.hrtransa
                               tt-cmaprv.dsobscmt = tt-emprestimo.dsobscmt
                               tt-cmaprv.dsaprova = aux_dsaprova.
    
                        DISPLAY
                            tt-cmaprv.insitapv tt-cmaprv.dsaprova
                            tt-cmaprv.cdopeapv tt-cmaprv.nmoperad
                            tt-cmaprv.dtaprova tt-cmaprv.dtmvtolt
                            STRING(tt-cmaprv.hrtransa, "HH:MM:SS") @ tt-cmaprv.hrtransa
                            WITH FRAME f_dados.
                    END.
    
            END.

    RELEASE tt-cmaprv.
    ASSIGN tel_dsobscmt = "".

    RETURN "OK".

END PROCEDURE. /* Grava_Dados */


PROCEDURE Gera_Impressao:
    
    DEF   VAR aux_flgescra AS LOGICAL                                   NO-UNDO.
    DEF   VAR aux_dscomand AS CHAR                                      NO-UNDO.
    DEF   VAR aux_nmarqpdf AS CHAR                                      NO-UNDO.
    DEF   VAR aux_nmendter AS CHAR       FORMAT "x(20)"                 NO-UNDO.
    
    DEF   VAR par_flgcance AS LOGICAL                                   NO-UNDO.
    DEF   VAR par_flgrodar AS LOGICAL    INIT TRUE                      NO-UNDO.
    DEF   VAR par_flgfirst AS LOGICAL    INIT TRUE                      NO-UNDO.

    EMPTY TEMP-TABLE tt-cmaprv.
    EMPTY TEMP-TABLE tt-erro.

    INPUT THROUGH basename `tty` NO-ECHO.
      SET aux_nmendter WITH FRAME f_terminal.
    INPUT CLOSE.
    
    aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                          aux_nmendter.  

    IF  NOT VALID-HANDLE(h-b1wgen0114) THEN
        RUN sistema/generico/procedures/b1wgen0114.p
            PERSISTENT SET h-b1wgen0114.

    RUN Gera_Impressao IN h-b1wgen0114
        ( INPUT glb_cdcooper,
          INPUT glb_cdagenci,
          INPUT 0,
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,
          INPUT glb_dtmvtolt,
          INPUT glb_dtmvtopr,
          INPUT glb_inproces,
          INPUT aux_nmendter,
          INPUT glb_cddopcao,     
          INPUT tel_cdagenci,
          INPUT tel_nrdconta,
          INPUT tel_dtpropos,
          INPUT tel_dtaprova,
          INPUT tel_dtaprfim,
          INPUT tel_aprovad1,
          INPUT tel_aprovad2,
          INPUT tel_cdopeapv,
          INPUT "S", /* sempre gerar com observação */
          INPUT aux_confimpr,
          INPUT-OUTPUT aux_nmarqimp, 
         OUTPUT aux_nmarqpdf, 
         OUTPUT TABLE tt-cmaprv,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0114) THEN
        DELETE OBJECT h-b1wgen0114.
 
    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
         DO:
             HIDE MESSAGE NO-PAUSE.
 
             FIND FIRST tt-erro NO-ERROR.
 
             IF  AVAILABLE tt-erro THEN
                 MESSAGE tt-erro.dscritic.
                    
             RETURN "NOK".  
         END.
    ELSE
        DO:
            
            FIND FIRST tt-cmaprv NO-ERROR.
            IF   AVAIL tt-cmaprv  THEN
                 DO:
                     IF   aux_confimpr = "N" THEN   /*  Via Impressora  */
                          DO:
                              RUN confirma.
                              IF   aux_confirma = "S"   THEN
                                   DO:
                                       ASSIGN glb_nmformul = "234dh"
                                              glb_nrdevias = 1 
                                              glb_nmarqimp = aux_nmarqimp.

                                      /* Utilizado somente para includes de impressao */
                                      FIND FIRST crapass WHERE
                                                 crapass.cdcooper = glb_cdcooper
                                                 NO-LOCK NO-ERROR.

                                      { includes/impressao.i }
                                   END.   
                          END.
                 END.
        END.

     RETURN "OK".

END PROCEDURE. /* Gera_Impressao */




