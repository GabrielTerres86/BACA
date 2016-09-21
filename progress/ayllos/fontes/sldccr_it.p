/* ............................................................................

   Programa: Fontes/sldccr_it.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                           Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para imprimir propostas de cartao de credito.

   Alteracoes: Tratar novo convenio de cartao (Odair).
               14/06/99 - Imprimir total de aplicacoes (Odair)

               11/10/1999 - Imprimir proposta de alteracao de limite (Deborah).

               29/10/1999 - Buscar os dados da cooperativa no crapcop (Edson).

               11/11/1999 - Acerto no nome da administradora (Deborah).

               16/10/2000 - Alterar fone para 20 posicoes (Margarete/Planner)

               27/07/2001 - Incluir geracao da nota promissoria (Margarete).

               09/07/2002 - Imprimir nome completo da Coop (Margarete).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               22/04/2004 - Tratamento para especial para administradora 3
                            (Julio).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               27/01/2006 -  Unificacao dos Bancos - SQLWorks - Luciane.

               04/10/2006 - Alterado texto do destino do relatorio para
                            ADMINISTRATIVO/FINANCEIRO (Elton).

               05/11/2007 - Alterado nmdsecao(crapass)p/ttl.nmdsecao(Guilherme).
               
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               16/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                           (GATI - Eder)

               20/10/2010 - Alteracao para imprimir termo de pessoa jurica
                           (Gati - Daniel).       
                           
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................ */
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT  PARAM par_nrctrcrd   AS  INTEGER       NO-UNDO.
DEF  INPUT  PARAM par_nrcrcard   AS DECI           NO-UNDO.

DEF  VAR aux_repsolic   AS CHAR FORMAT "x(40)"             NO-UNDO.

DEF NEW SHARED STREAM str_1.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF   VAR aux_flgescra     AS LOGICAL                                NO-UNDO.
DEF   VAR par_flgfirst     AS LOGICAL INIT TRUE                      NO-UNDO.
DEF   VAR par_flgcance     AS LOGICAL                                NO-UNDO.
DEF   VAR aux_dscomand     AS CHAR                                   NO-UNDO.
DEF   VAR par_flgrodar     AS LOGICAL INIT TRUE                      NO-UNDO.
/**************************************************************/
DEF   VAR tel_dsimprim     AS CHAR FORMAT "x(8)" INIT "Imprimir"     NO-UNDO.
DEF   VAR tel_dscancel     AS CHAR FORMAT "x(8)" INIT "Cancelar"     NO-UNDO.
DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.
DEF   VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.
DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
DEF   VAR h_b1wgen0028     AS HANDLE                                 NO-UNDO.
DEF   VAR h_Termos         AS HANDLE                                 NO-UNDO.

DEF   VAR aux_tipopess       AS INT                       NO-UNDO.
DEF   VAR aux_nrcpfcgc       AS CHAR FORMAT "x(15)"       NO-UNDO.
DEF   VAR aux_nmprimtl       AS CHAR                      NO-UNDO.
DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.

DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
DEFINE VARIABLE aux_nrcrcard AS DECI      FORMAT "9999,9999,9999,9999" NO-UNDO.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM " Aguarde... Imprimindo proposta de alteracao de limite! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

RUN verifica_associado IN h_b1wgen0028 (INPUT glb_cdcooper,
                                        INPUT tel_nrdconta,
                                        OUTPUT aux_tipopess).

DELETE PROCEDURE h_b1wgen0028.


IF  aux_tipopess = 2 THEN
    DO:

        RUN fontes/termos_pj.p PERSISTENT SET h_termos.
            
        RUN altera_limite_pj IN   h_termos (INPUT glb_cdcooper,
                                            INPUT glb_cdoperad,
                                            INPUT glb_nmdatela,
                                            INPUT glb_dtmvtolt,
                                            INPUT par_nrctrcrd,
                                            INPUT tel_nrdconta).

        DELETE PROCEDURE  h_termos.
           
     END.

ELSE 
     DO:

         VIEW FRAME f_aguarde.
    
        INPUT THROUGH basename `tty` NO-ECHO.
        SET aux_nmendter WITH FRAME f_terminal.
        INPUT CLOSE.
        
        aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                              aux_nmendter.

        RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

        RUN imprimi_limite_pf IN  h_b1wgen0028 ( INPUT glb_cdcooper,
                                                 INPUT 1, /* par_idorigem */
                                                 INPUT glb_cdoperad, 
                                                 INPUT glb_nmdatela,
                                                 INPUT tel_nrdconta,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT glb_dtmvtopr,
                                                 INPUT glb_inproces,
                                                 INPUT par_nrctrcrd,
                                                 INPUT aux_nmendter,
                                                OUTPUT aux_nmarqimp,
                                                OUTPUT aux_nmarqpdf,
                                                OUTPUT TABLE tt-erro).
                                              
        DELETE PROCEDURE h_b1wgen0028.

        IF  RETURN-VALUE = "NOK" THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                IF  AVAILABLE tt-erro THEN
                    DO:
                        BELL.
                        MESSAGE tt-erro.dscritic.
                        PAUSE 3 NO-MESSAGE.
                        HIDE MESSAGE NO-PAUSE.
                    END.
    
                HIDE FRAME f_aguarde NO-PAUSE.
    
                RETURN "NOK".
            END.
         
        HIDE FRAME f_aguarde NO-PAUSE.

        glb_nrdevias = 1.

        FIND crapass WHERE
             crapass.cdcooper = glb_cdcooper AND
             crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

        { includes/impressao.i }
    
END.

RETURN "OK".

/* ......................................................................... */
