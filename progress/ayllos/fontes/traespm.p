/* ............................................................................

   Programa: fontes/traespm.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Fernando Hilgenstieler
   Data    : Julho/2003.                     Ultima atualizacao: 02/06/2014
                              
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Relatorio das transacoes que deverao ser digitadas para 
               controle do SISBACEN.

   Alteracoes: 28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               02/02/2006 - Unificacao dos Bancos - SQLWorks - Eder
               
               04/05/2010 - Ajustado programa para as movimentações em
                            espécie criadas na rotina 20 (a partir da
                            craptvl). (Fernando)  
                            
               24/05/2011 - Realizado adaptacao no layout do relatório
                            para atender as novas exigencias a lavagem 
                            de dinheiro (Adriano).          
                            
               20/07/2011 - Retirado correcao no for each crapcme  
                            (Adriano).   
                            
               02/12/2011 - Corrigir display do down frame (Gabriel). 
               
               06/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               12/11/2013 - Adequacao da regra de negocio a b1wgen0135.p
                            (conversao tela web). (Fabricio)
                            
               02/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................. */

{ includes/var_online.i }       
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM p_b1wgen0135 AS HANDLE NO-UNDO.


DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"     NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"     NO-UNDO.
DEF VAR tel_tpimprim AS LOGICAL FORMAT "T/I"  INIT "T"            NO-UNDO.

DEF VAR aux_nmendter AS CHAR    FORMAT "x(20)"                    NO-UNDO. 
DEF VAR aux_nmarqimp AS CHAR                                      NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                      NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                      NO-UNDO.
DEF VAR aux_flgescra AS LOG                                       NO-UNDO.
DEF VAR aux_dsagenci AS CHAR    FORMAT "x(20)"                    NO-UNDO.
DEF VAR aux_cdocpttl AS LOGICAL                                   NO-UNDO.
DEF VAR aux_contador AS INT                                       NO-UNDO.

DEF VAR par_flgrodar AS LOG     INIT TRUE                         NO-UNDO.
DEF VAR par_flgfirst AS LOG                                       NO-UNDO.
DEF VAR par_flgcance AS LOG                                       NO-UNDO.

DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                INIT ["DEP. A VISTA   ","CAPITAL        ",
                                      "EMPRESTIMOS    ","DIGITACAO      ",
                                      "GENERICO       "]          NO-UNDO.

DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5           NO-UNDO.
DEF VAR rel_nmempres AS CHAR                                      NO-UNDO.
DEF VAR rel_dsagenci AS CHAR    FORMAT "x(21)"                    NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                        NO-UNDO.

DEF VAR rel_nrcpfcgc AS CHAR                                      NO-UNDO.
DEF VAR rel_nrcpfstl AS CHAR                                      NO-UNDO.
DEF VAR rel_cpfcgdst AS CHAR                                      NO-UNDO.
DEF VAR rel_cpfcgrcb AS CHAR                                      NO-UNDO.

DEF VAR aux_tpoperac AS CHAR                                      NO-UNDO.
DEF VAR aux_dtaltera AS DATE                                      NO-UNDO.
DEF VAR aux_dsocpttl AS CHAR                                      NO-UNDO.
DEF VAR aux_nrcpfcgc AS CHAR                                      NO-UNDO.


/*  Gerenciamento da impressao  */
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").


MESSAGE "AGUARDE... Gerando relatorio!".

RUN imprime-listagem-transacoes IN p_b1wgen0135 (INPUT glb_cdcooper,
                                                 INPUT 1,
                                                 INPUT 1,
                                                 INPUT glb_dtmvtolt,
                                                 INPUT 1, /* idorigem */
                                                OUTPUT aux_nmarqimp,
                                                OUTPUT aux_nmarqpdf,
                                                OUTPUT TABLE tt-erro).

HIDE MESSAGE NO-PAUSE.

IF RETURN-VALUE = "NOK" THEN
DO:
    FIND FIRST tt-erro NO-LOCK NO-ERROR.
    MESSAGE tt-erro.dscritic.
    CLEAR FRAME f_transacoes ALL NO-PAUSE.
    LEAVE.
END.

HIDE MESSAGE NO-PAUSE.

MESSAGE "Voce deseja visualizar o relatorio"  
        "em TELA ou na IMPRESSORA? (T/I)"
        UPDATE tel_tpimprim.

IF tel_tpimprim = FALSE THEN
   DO:
      MESSAGE "AGUARDE... Imprimindo relatorio!". 
      FIND FIRST crapass  NO-LOCK NO-ERROR.

      { includes/impressao.i }

   END.  
ELSE
   RUN fontes/visrel.p (INPUT aux_nmarqimp).
   

HIDE MESSAGE NO-PAUSE.

IF tel_tpimprim = FALSE THEN
   IF NOT par_flgcance   THEN
      MESSAGE "Retire o relatorio da impressora!".
   ELSE
      MESSAGE "Impressao cancelada!".



/* .......................................................................... */

