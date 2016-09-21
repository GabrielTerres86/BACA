/* .............................................................................

   Programa: fontes/impressao_termo_cobranca.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2006                   Ultima Atualizacao: 22/07/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Efetuar a impressao do termo de cobranca.

   Alteracoes: 08/12/2006 - Alteracao no layout e no formato dos campos texto
                            (Elton).
     
               02/01/2007 - Alterado layout e incluido crapcop.dsclaccb no texto
                            (Elton).
               
               31/01/2007 - Incluido operador responsavel pela impressao do
                            termo (Elton).
   
               01/12/2010 - (001) Alteraçao de format para x(50) 
                            Leonardo Américo (Kbase).
                           
               14/12/2010 - Passar a logica do programa para a BO 82 (Gabriel). 
               
               22/07/2011 - Impressao da cobranca Registrada (Gabriel).          
               
               16/10/2012 - Tornar default "S" para impressao da Adesao na
                            confirmacao do convenio (Rafael).
                            
               07/08/2014 - Inserir o parametro de nrconven na chamada da 
                            rotina obtem-dados-adesao  (Renato - Supero)
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM par_nrdconta AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_dsdtitul AS CHAR                                   NO-UNDO.
DEF INPUT PARAM par_flgregis AS LOGI                                   NO-UNDO.
DEF INPUT param par_nrconven AS INTE                                   NO-UNDO.


DEF VAR aux_confirma AS CHAR                                           NO-UNDO.

/* Variaveis para a impressao */
DEF VAR par_flgrodar AS LOGI                                           NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                           NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_flgescra AS LOGICAL                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"          NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"          NO-UNDO.
                  
DEF VAR par_nmdtest1 AS CHAR                                           NO-UNDO.
DEF VAR par_cpftest1 AS DECI                                           NO-UNDO.
DEF VAR par_nmdtest2 AS CHAR                                           NO-UNDO.
DEF VAR par_cpftest2 AS DECI                                           NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0082 AS HANDLE                                         NO-UNDO.

ASSIGN aux_confirma = "S".

MESSAGE COLOR NORMAL "Deseja efetuar a impressao do termo de Adesao?"
     UPDATE aux_confirma FORMAT "X(01)".

HIDE MESSAGE NO-PAUSE.
        
IF   aux_confirma <> "S"   THEN
     RETURN.

IF   par_flgregis   THEN /* Cobranca Registrada */
     DO:   
         RUN fontes/testemunhas.p (INPUT par_nrdconta,
                                  OUTPUT par_nmdtest1,
                                  OUTPUT par_cpftest1,
                                  OUTPUT par_nmdtest2,
                                  OUTPUT par_cpftest2).                                       
     END.

INPUT THROUGH basename `tty` NO-ECHO.
SET aux_nmendter WITH FRAME f_terminal.
INPUT CLOSE.  

RUN sistema/generico/procedures/b1wgen0082.p PERSISTENT SET h-b1wgen0082.

RUN obtem-dados-adesao IN h-b1wgen0082 (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT glb_cdoperad,
                                        INPUT glb_nmdatela,
                                        INPUT 1, /* Ayllos */
                                        INPUT par_nrdconta, 
                                        INPUT 1, /* Tit */
                                        INPUT par_flgregis,
                                        INPUT par_nmdtest1,
                                        INPUT par_cpftest1,
                                        INPUT par_nmdtest2,
                                        INPUT par_cpftest2,
                                        INPUT aux_nmendter,
                                        INPUT par_dsdtitul, 
                                        INPUT glb_dtmvtolt,
                                        INPUT TRUE, 
                                        INPUT par_nrconven,
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT par_nmarqimp,
                                       OUTPUT par_nmarqpdf).
DELETE PROCEDURE h-b1wgen0082.

IF   RETURN-VALUE <> "OK"   THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.
         ELSE
              MESSAGE "Erro na impressao do termo de adesao.".

         RETURN.
     END.

ASSIGN aux_nmarqimp =  par_nmarqimp 
       par_flgrodar    = TRUE.    

/* Duas vias para a Registrada */
IF   par_flgregis   THEN
     ASSIGN glb_nrdevias = 2.

/* Compilar includes de impressao */
FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

{ includes/impressao.i }

/*...........................................................................*/

