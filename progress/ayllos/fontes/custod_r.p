/* ..........................................................................

   Programa: Fontes/custod_r.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Abril/2000.                      Ultima atualizacao: 04/06/2014

   Dados referentes ao programa:

   Frequencia: Diario (ON-LINE).
   Objetivo  : Emitir relatorio de lotes de cheques em custodia digitados no
               dia (233).

   Alteracoes: Alterar nrdolote p/6 posicoes (Margarete/Planner).

               01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).

               18/11/2004 - Listar o numero da conta do associado (Edson).

               25/10/2005 - Alterado para mostrar relatorio detalhado se 
                            a flag for verdadeira (Diego).

               16/11/2005 - Comentado no relatorio 233 linha referente total
                            Geral (Diego).

               24/11/2005 - Acrescentado totalizador Geral no final do
                            relatorio (Diego).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               21/05/2009 - Adicionar opcao para geracao de relatorio em 
                            arquivo (Fernando).
                         
               16/11/2009 - Opcao de imprimir por periodo;
                            Estruturacao do programa em BO (GATI - Eder)
                            
               08/07/2011 - Alteracao na passagem de parametros das procedures:
                            * busca_maiores_cheques_craptab
                            * busca_informacoes_relatorio_custodia
                            (Adriano).
                                       
               11/01/2012 - Reestruturação da BO para comunição com WEB
                            (Gabriel Capoia - DB1). 
                            
               04/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).                
                            
               03/03/2015 - Alteracao do handle da BO 18 para 18i aonde
                            se encontram as funcoes de impressao
                            (Carlos Rafael Tanholi)            
                                              
........................................................................... */

{ sistema/generico/includes/b1wgen0018tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_batch.i } 

DEF STREAM str_1.

DEF INPUT PARAM par_dtmvtini AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_dtmvtfim AS DATE                                 NO-UNDO.
DEF INPUT PARAM par_cdagenci AS INT                                  NO-UNDO.
DEF INPUT PARAM par_flgrelat AS LOGICAL                              NO-UNDO.
DEF INPUT PARAM par_nmdopcao AS LOGICAL                              NO-UNDO.
/*DEF INPUT PARAM tel_nmdireto AS CHAR   FORMAT "x(25)"                NO-UNDO.*/

/* Variaveis padroes utilizadas em impressao.i */
DEF   VAR par_flgrodar AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgfirst AS LOGICAL INIT TRUE                          NO-UNDO.
DEF   VAR par_flgcance AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgfirst AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_regexist AS LOGICAL                                    NO-UNDO.
DEF   VAR aux_flgescra AS LOGICAL                                    NO-UNDO.

/* Variaveis padroes utilizadas em cabrel132_1.i */
DEF   VAR rel_nmempres AS CHAR   FORMAT "x(15)"                      NO-UNDO.
DEF   VAR rel_nmrelato AS CHAR   FORMAT "x(40)" EXTENT 5             NO-UNDO.
DEF   VAR rel_nrmodulo AS INT    FORMAT "9"                          NO-UNDO.
DEF   VAR rel_nmmodulo AS CHAR   FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF   VAR tel_dsimprim AS CHAR   FORMAT "x(8)" INIT "Imprimir"       NO-UNDO.
DEF   VAR tel_dscancel AS CHAR   FORMAT "x(8)" INIT "Cancelar"       NO-UNDO.
DEF   VAR tel_nmarquiv AS CHAR   FORMAT "x(28)"                      NO-UNDO.

DEF   VAR aux_contador AS INT                                        NO-UNDO.
DEF   VAR aux_nmendter AS CHAR   FORMAT "x(20)"                      NO-UNDO.
DEF   VAR aux_server   AS CHAR                                       NO-UNDO.
DEF   VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF   VAR aux_dscomand AS CHAR                                       NO-UNDO.
DEF   VAR h-b1wgen0018i AS HANDLE                                     NO-UNDO.

DEF VAR aux_msgretur AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                        NO-UNDO.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.
          
FORM "Diretorio: "                                                  AT 5
     /*tel_nmdireto*/
     tel_nmarquiv        HELP "Informe o nome do arquivo."
     WITH OVERLAY ROW 10 NO-LABEL NO-BOX COLUMN 2 FRAME f_diretorio.

IF  par_nmdopcao  /* Arquivo */   THEN
    DO:
        /*DISPLAY tel_nmdireto WITH FRAME f_diretorio.*/

        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            UPDATE tel_nmarquiv WITH FRAME f_diretorio.

            IF  tel_nmarquiv = "" THEN 
                DO:
                    MESSAGE "Arquivo nao informado !!".
                    NEXT.
                END.
            LEAVE.
        END.

        IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            DO:
                HIDE FRAME f_diretorio NO-PAUSE.
                LEAVE.
            END.

         ASSIGN aux_nmendter = tel_nmarquiv.
        
         MESSAGE "AGUARDE... GERANDO RELATORIO!".
    END. /* IF   par_nmdopcao  /* Arquivo */ */
ELSE
    DO:
        INPUT THROUGH basename `tty` NO-ECHO.
        SET aux_nmendter WITH FRAME f_terminal.
        INPUT CLOSE.

        INPUT THROUGH basename `hostname -s` NO-ECHO.
        IMPORT UNFORMATTED aux_server.
        INPUT CLOSE.
        aux_nmendter = substr(aux_server,length(aux_server) - 1) +
                              aux_nmendter.

        MESSAGE "AGUARDE... IMPRIMINDO RELATORIO!".
    END.

IF  NOT VALID-HANDLE(h-b1wgen0018i) THEN
    RUN sistema/generico/procedures/b1wgen0018i.p 
        PERSISTENT SET h-b1wgen0018i.

RUN gera-lotes-custodia IN h-b1wgen0018i
                      ( INPUT glb_cdcooper,
                        INPUT glb_cdagenci,
                        INPUT 0,
                        INPUT 1, /*idorigem*/
                        INPUT glb_nmdatela,
                        INPUT glb_cdprogra,
                        INPUT glb_dtmvtolt,
                        INPUT par_dtmvtini,
                        INPUT par_dtmvtfim,
                        INPUT par_cdagenci,
                        INPUT par_nmdopcao,
                        INPUT par_flgrelat,
                        INPUT aux_nmendter,
                       OUTPUT aux_nmarqimp,
                       OUTPUT aux_nmarqpdf,
                       OUTPUT aux_msgretur, 
                       OUTPUT TABLE tt-erro).

IF  VALID-HANDLE(h-b1wgen0018i) THEN
    DELETE PROCEDURE h-b1wgen0018i.

IF  RETURN-VALUE <> "OK" THEN
    DO:
        FIND FIRST tt-erro NO-ERROR.

        IF  AVAIL tt-erro   THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
                RETURN.
            END.
    END.

HIDE MESSAGE NO-PAUSE.

IF  aux_msgretur <> "" THEN
    DO:
        MESSAGE aux_msgretur.
        HIDE FRAME f_diretorio NO-PAUSE.
    END.
ELSE
    DO:
        ASSIGN glb_nmformul = ""
               glb_nrcopias = 1
               glb_nmarqimp = aux_nmarqimp.

        FIND FIRST crapass WHERE
                   crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

        { includes/impressao.i }

        IF  NOT par_flgcance THEN
            DO:
                MESSAGE "RETIRE O RELATORIO DA IMPRESSORA!".
            END.
        ELSE
            DO:
                MESSAGE "IMPRESSAO CANCELADA!".
            END.
    END.

PAUSE 2 NO-MESSAGE.
/* ......................................................................... */
