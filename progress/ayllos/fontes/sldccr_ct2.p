/* ............................................................................

   Programa: Fontes/sldccr_ct2.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Agosto/98                           Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para listar contrato de cartoes de credito cdadmcrd 2.

   Alteracoes: 27/05/1999 - Mostrar a data da 2via no final (Deborah).

               25/10/1999 - Buscar os dados da cooperativa no crapcop (Edson).

               09/07/2002 - Imprimir nome completo da Coop (Margarete).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               11/02/2004 - Adaptacao para imprimir contrato para adm. 3 
                            tambem (Julio).

               22/04/2004 - Alterado de BRADESCO/CECRED para CECRED/VISA 
                            (Julio) 
                            
               14/12/2004 - Alterado texto do contrato (Evandro).
               
               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                             
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               10/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)
                            
               09/09/2010 - Alteracao para imprimir contrato PJ
                            (GATI - Sandro)               
                                                        
               24/09/2010 - Alteracao para gerar a proposta diretamente na 
                            BO, apenas disparando a impressao por este fonte.
                            GATI - Sandro
                            
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

DEF NEW SHARED STREAM str_1.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF        VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF        VAR par_flgfirst AS LOGI    INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGI    INIT TRUE                     NO-UNDO.
/**************************************************************/

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_dsmesano AS CHAR    EXTENT 15 INIT
                                       ["de  Janeiro  de","de Fevereiro de",
                                        "de   Marco   de","de    Abril  de",
                                        "de    Maio   de","de    Junho  de",
                                        "de    Julho  de","de   Agosto  de",
                                        "de  Setembro de","de  Outubro  de",
                                        "de  Novembro de","de  Dezembro de"]
                                                                     NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqpdf AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.

DEF        VAR h_b1wgen0028 AS HANDLE                                NO-UNDO.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM " Aguarde... Imprimindo contrato de cartao de credito! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.


RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

VIEW FRAME f_aguarde.

INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

RUN gera_impressao_contrato_cartao IN h_b1wgen0028 (  INPUT glb_cdcooper,
                                                      INPUT 1, /* par_idorigem */
                                                      INPUT glb_cdoperad,
                                                      INPUT glb_nmdatela,
                                                      INPUT tel_nrdconta,
                                                      INPUT glb_dtmvtolt,
                                                      INPUT glb_dtmvtopr,
                                                      INPUT glb_inproces,
                                                      INPUT par_nrctrcrd,
                                                      INPUT aux_nmendter,
                                                      INPUT aux_flgimp2v,
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

RETURN "OK".
/* ......................................................................... */
