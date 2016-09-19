/* .............................................................................

   Programa: Includes/var_carmag.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/99.                         Ultima atualizacao: 22/07/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)

   Objetivo  : Criacao das variaveis para tratamento de cartao magnetico.

   Alteracoes: 26/05/2000 - Incluir a data de entrega do cartao (Edson).

               05/03/2008 - f_magnetico2 para pessoa juridica (Guilherme).
               
               19/05/2009 - FORM f_cartao_magnetico para apresentacao dos
                            dados com base na temp-table tt-dados-carmag -
                            Alteracao para utilizacao de BOs - GATI - Eder
                            
               21/12/2011 - Incluido f_opcao_senha (Diego).
               
               19/01/2012 - Format na conta de selecao do preposto
                          - Tratamento para Letras de Seguranca TAA 
                          - Alteracao senhas cartao para CHAR (Guilherme).
                          
               11/01/2013 - Adicionada variável 'aux_flgletca' para identificar
                            se o cooperado possui letras cadastradas (Lucas).
               
               22/07/2015 - Remover as opcoes Limite, Entrega e Recibo de Saque.
                            (James)
............................................................................. */

DEF {1} SHARED VAR aux_confirma AS CHAR FORMAT "X"                     NO-UNDO.

DEF VAR tel_flgemsrc AS LOGI FORMAT "EMITE/NAO EMITE"                  NO-UNDO.

DEF VAR tel_nmdavali LIKE crapavt.nmdavali                             NO-UNDO.
DEF VAR tel_nmdavanv LIKE crapavt.nmdavali                             NO-UNDO.

DEF VAR tel_nrsenatu AS CHAR                                           NO-UNDO.
DEF VAR tel_nrsennov AS CHAR                                           NO-UNDO.
DEF VAR tel_nrsencon AS CHAR                                           NO-UNDO.

DEF VAR tel_dssennov AS CHAR                                           NO-UNDO.
DEF VAR tel_dssencon AS CHAR                                           NO-UNDO.
DEF VAR aux_flgcadas AS CHAR                                           NO-UNDO.


DEF VAR h_b1wgen0032 AS HANDLE                                         NO-UNDO.
     
DEF VAR tab_dsdopcao AS CHAR EXTENT 7 INIT 
        ["Bloqueio","Cancelamento","Consulta",
         "Impressao","Senha","Solicitacao","Entrega"]                  NO-UNDO.
DEF VAR tab_cddopcao AS CHAR EXTENT 9 INIT
        ["B","X","C","M","H","S","L"]                                  NO-UNDO.
        
DEF VAR aux_nrcpfppt AS DECI                                           NO-UNDO.

DEF VAR aux_flgreabr AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR aux_flgsenha AS LOGI                                           NO-UNDO.
DEF VAR aux_trocappt AS LOGI                                           NO-UNDO.
DEF VAR aux_flgletca AS LOGI                                           NO-UNDO.

DEF VAR aux_dsrecsaq AS CHAR INIT "NAO EMITE,EMITE"                    NO-UNDO.
DEF VAR aux_dssaqmax AS CHAR INIT "DIARIO,SEMANAL,QUINZENAL,MENSAL,LIVRE"
                                                                       NO-UNDO.

DEF VAR aux_inposmax AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_inposusu AS INTE                                           NO-UNDO.
DEF VAR aux_inposrec AS INTE INIT 1                                    NO-UNDO.
DEF VAR aux_iddopcao AS INTE                                           NO-UNDO.
DEF VAR aux_nrdopcao AS INTEGER INIT 7                                 NO-UNDO.
DEF VAR aux_nrdlinha AS INTE                                           NO-UNDO.

DEF VAR tel_sennumer AS CHAR INIT "Numerica"                           NO-UNDO.
DEF VAR tel_solletra AS CHAR INIT "Letras de Seguranca"                NO-UNDO.

DEF VAR aux_flcarmag AS LOG                                            NO-UNDO.
                                                                     
DEF QUERY q_cartoes      FOR tt-cartoes-magneticos.
DEF QUERY q_procuradores FOR tt-preposto-carmag.

DEF BROWSE b_cartoes QUERY q_cartoes DISPLAY
  tt-cartoes-magneticos.nmtitcrd COLUMN-LABEL "Titular"          FORMAT "X(34)"
  tt-cartoes-magneticos.nrcartao COLUMN-LABEL "Numero do Cartao" FORMAT "X(19)"
  tt-cartoes-magneticos.dssitcar COLUMN-LABEL "Situacao"         FORMAT "X(17)"
  WITH 5 DOWN NO-BOX.

DEF BROWSE b_procuradores QUERY q_procuradores DISPLAY
  tt-preposto-carmag.nrdctato COLUMN-LABEL "Conta/dv" FORMAT "zzzz,zz9,9"
  tt-preposto-carmag.nmdavali COLUMN-LABEL "Nome"  FORMAT "x(25)"    
  tt-preposto-carmag.dscpfcgc COLUMN-LABEL "C.P.F" FORMAT "x(14)"   
  tt-preposto-carmag.dsproftl COLUMN-LABEL "Cargo" FORMAT "x(15)"    
  WITH 5 DOWN NO-BOX.
              
FORM SPACE(2)
     tab_dsdopcao[1] FORMAT "x(8)"
     SPACE(2)
     tab_dsdopcao[2] FORMAT "x(12)"
     SPACE(2)
     tab_dsdopcao[3] FORMAT "x(8)"     
     SPACE(2)
     tab_dsdopcao[4] FORMAT "x(9)"
     SPACE(2)
     tab_dsdopcao[5] FORMAT "x(5)"
     SPACE(2)
     tab_dsdopcao[6] FORMAT "x(11)"     
     SPACE(2)
     tab_dsdopcao[7] FORMAT "x(7)"
     SPACE(2)
     SKIP(1)     
     WITH ROW 19 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM SKIP(1)
     tel_nrsenatu AT 3 FORMAT "999,999" LABEL "          Senha Atual" BLANK
     SKIP(1)
     tel_nrsennov AT 3 FORMAT "999,999" LABEL "           Senha Nova" BLANK
     SKIP(1)
     tel_nrsencon AT 3 FORMAT "999,999" LABEL "Confirme a Senha Nova" BLANK
     " "
     SKIP(1)
     WITH ROW 11 CENTERED TITLE COLOR NORMAL " Alteracao de Senha "
          OVERLAY SIDE-LABELS FRAME f_senha.

FORM SKIP(1)
     tel_dssennov AT 3 FORMAT "x(3)" LABEL " Letras de Seguranca" BLANK
                  HELP "Informe letras de 'A' a 'U'."
     SKIP(1)
     tel_dssencon AT 3 FORMAT "x(3)" LABEL "Confirme suas letras" BLANK
                  HELP "Informe letras de 'A' a 'U'."
     " "
     SKIP(1)
     WITH ROW 12 CENTERED TITLE COLOR NORMAL " Letras de Seguranca "
          OVERLAY SIDE-LABELS FRAME f_senha_let.
       
FORM SKIP(1)
     tt-dados-carmag.dsusucar AT  3 LABEL "Titular" FORMAT "x(19)" 
        HELP "Use as setas de DIRECAO para escolher o tipo de titular."
     tt-dados-carmag.nmtitcrd NO-LABEL              FORMAT "x(30)"
             VALIDATE(TRIM(tt-dados-carmag.nmtitcrd) <> "",
                      "016 - NOME DO TITULAR DEVE SER INFORMADO.")         
     SKIP(1)
     tt-dados-carmag.nrcartao AT  4 LABEL "Numero"     FORMAT "X(20)"
     tt-dados-carmag.nrseqcar AT 39 LABEL "Sequencial" FORMAT "zzzzzz,zz9"
     SKIP(1)     
     tt-dados-carmag.dtemscar AT 39 LABEL "Emitido em"      FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dscarcta AT  3 LABEL "Tipo de Cartao"  FORMAT "x(15)"
     tt-dados-carmag.dtvalcar AT 39 LABEL "Valido ate"      FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dssitcar AT  9 LABEL "Situacao"        FORMAT "x(16)"
     tt-dados-carmag.dtentcrm AT 38 LABEL "Entregue em"     FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dtcancel AT 37 LABEL "Cancelado em"    FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dttransa AT  3 LABEL "Data Transacao"  FORMAT "99/99/9999"
     tt-dados-carmag.hrtransa AT 35 LABEL "Hora Transacao"  FORMAT  "x(9)"
     SKIP
     tt-dados-carmag.nmoperad AT  3 LABEL "Op."             FORMAT "x(26)"
     SKIP
     WITH ROW 06 NO-LABELS SIDE-LABELS OVERLAY
          TITLE COLOR NORMAL " Cartao Magnetico "
          CENTERED FRAME f_cartao_magnetico.
                    
FORM SKIP(1)
     tt-dados-carmag.nmtitcrd AT  3 LABEL "Titular" FORMAT "x(40)" 
     SKIP(1)
     tt-dados-carmag.nrcartao AT  4 LABEL "Numero"     FORMAT "X(20)"
     tt-dados-carmag.nrseqcar AT 39 LABEL "Sequencial" FORMAT "zzzzzz,zz9"
     SKIP(1)   
     tt-dados-carmag.dtemscar AT 39 LABEL "Emitido em"      FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dscarcta AT  3 LABEL "Tipo de Cartao"  FORMAT "x(15)"
     tt-dados-carmag.dtvalcar AT 39 LABEL "Valido ate"      FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dssitcar AT  9 LABEL "Situacao"        FORMAT "x(16)"
     tt-dados-carmag.dtentcrm AT 38 LABEL "Entregue em"     FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dtcancel AT 37 LABEL "Cancelado em"    FORMAT "99/99/9999"
     SKIP
     tt-dados-carmag.dttransa AT  3 LABEL "Data Transacao"  FORMAT "99/99/9999"
     tt-dados-carmag.hrtransa AT 35 LABEL "Hora Transacao"  FORMAT  "x(9)"
     SKIP
     tt-dados-carmag.nmoperad AT  3 LABEL "Op."             FORMAT "x(26)"
     SKIP
     WITH ROW 06 NO-LABELS SIDE-LABELS OVERLAY
          TITLE COLOR NORMAL " Cartao Magnetico "
          CENTERED FRAME f_cartao_magnetico2.                    

FORM b_cartoes
     WITH ROW 10 CENTERED TITLE COLOR NORMAL " Cartoes Magneticos " 
          FRAME f_cartoes OVERLAY.
          
FORM b_procuradores
     SKIP(1)
     tel_nmdavali AT 3 LABEL "Preposto atual" FORMAT "x(25)"
     SKIP
     tel_nmdavanv AT 3 LABEL "Preposto novo" FORMAT "x(25)"
     WITH CENTERED ROW 9 TITLE "Selecao de Preposto" 
          SIDE-LABELS OVERLAY FRAME f_procurad.      

FORM SKIP(1)
     tel_sennumer AT 5
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     tel_solletra  FORMAT "x(19)" AT 18
     HELP "Tecle <Entra> para confirmar ou <Fim> para retornar."
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY CENTERED  WIDTH 42
     NO-LABELS FRAME f_opcao_senha.

IF glb_nmdatela = "ATENDA" THEN
   ASSIGN aux_nrdopcao = 6.   

ON ANY-KEY OF b_cartoes IN FRAME f_cartoes DO:

    IF   KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
         DO:         
             aux_iddopcao = aux_iddopcao + 1.
    
             IF   aux_iddopcao > aux_nrdopcao   THEN
                  aux_iddopcao = 1.
                             
             CHOOSE FIELD tab_dsdopcao[aux_iddopcao] PAUSE 0 
                    WITH FRAME f_opcoes.
         END.
    ELSE    
    IF   KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
         DO:
             aux_iddopcao = aux_iddopcao - 1.
 
             IF   aux_iddopcao < 1   THEN
                  aux_iddopcao = aux_nrdopcao.
                     
             CHOOSE FIELD tab_dsdopcao[aux_iddopcao] PAUSE 0 
                    WITH FRAME f_opcoes.
         END.
    ELSE
    IF   KEYFUNCTION(LASTKEY) = "HELP"   THEN
         APPLY "HELP".
    ELSE
    IF   CAN-DO("GO,RETURN",KEYFUNCTION(LASTKEY))   THEN
         DO:
             ASSIGN aux_nrdlinha = 0.
                            
             IF   CAN-FIND(FIRST tt-cartoes-magneticos)   THEN 
                  ASSIGN aux_nrdlinha = CURRENT-RESULT-ROW("q_cartoes").
                  
             APPLY "GO".
         END.
    
END.

ON RETURN OF b_procuradores IN FRAME f_procurad DO:
    
    HIDE MESSAGE NO-PAUSE.
      
    ASSIGN tel_nmdavanv = tt-preposto-carmag.nmdavali
           aux_trocappt = FALSE.
           
    DISPLAY tel_nmdavanv WITH FRAME f_procurad.
            
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
        BELL.
        ASSIGN aux_confirma = "N".
        MESSAGE COLOR NORMAL "Confirma atualizacao de preposto?"
                UPDATE aux_confirma.              
        LEAVE.
    
    END.  /*  Fim do DO WHILE TRUE  */
      
    IF  aux_confirma = "S" THEN
        DO:
            RUN sistema/generico/procedures/b1wgen0032.p
                PERSISTENT SET h_b1wgen0032.
            
            RUN atualizar-preposto IN h_b1wgen0032
                                (INPUT glb_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT glb_cdoperad,   
                                 INPUT glb_nmdatela,
                                 INPUT 1,
                                 INPUT tel_nrdconta,
                                 INPUT 1, 
                                 INPUT tt-preposto-carmag.nrcpfcgc,
                                 INPUT TRUE, 
                                OUTPUT TABLE tt-erro).
            
            DELETE PROCEDURE h_b1wgen0032.
               
            IF  RETURN-VALUE = "NOK" THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
                    
                    IF  AVAILABLE tt-erro  THEN
                        DO:
                            BELL. 
                            MESSAGE tt-erro.dscritic.
                        END.
                END. 
            ELSE            
            IF  aux_nrcpfppt <> tt-preposto-carmag.nrcpfcgc  THEN
                aux_trocappt = TRUE.
        END.   

    APPLY "GO".   
   
END. 

ON END-ERROR OF b_procuradores IN FRAME f_procurad DO:

    DISABLE b_procuradores WITH FRAME f_procurad.
    HIDE FRAME f_procurad NO-PAUSE.
    HIDE MESSAGE NO-PAUSE.
    
END.

/* .......................................................................... */


