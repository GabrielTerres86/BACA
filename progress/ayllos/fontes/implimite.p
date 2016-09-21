/* ............................................................................

   Programa: Fontes/implimite.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Maio/99.                        Ultima atualizacao: 25/08/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer o tratamento para impressao do contrato e proposta e  
               cancelamento para limite de credito.

   Alteracoes: 25/10/1999 - Alterado para buscar dados da cooperativa no 
                            crapcop (Edson).
   
               04/12/2000 - Incluir opcao de impressao (Margarete/Planner).

               16/04/2001 - Transforma-lo em .p (Margarete/Planner).

               30/07/2001 - Imprimir observacoes (Margarete).

               04/12/2001 - Imprimir titulo na promissoria (Margarete).

               01/07/2002 - Colocar opcoes na impressao (Margarete).

               17/01/2003 - Ajuste na nota promissoria para tratar os 
                            conjuges fiadores (Eduardo).

               13/03/2003 - Alterado para tratar novos campos craplim (Edson).
 
               04/05/2003 - Modificar o Texto do Contrato (Ze Eduardo).
               
               08/09/2003 - Se nao encontrar a tabela LOCALIDADE, deixar o nome
                            da cidade em branco (Fernando).
                            
               09/12/2003 - Buscar o nome da cidade no crapcop (Junior).

               17/03/2004 - Campos truncados (Margarete).

               12/07/2004 - Inclusao do campo CPF/CNPJ e das datas das consul-
                            tas do SPC e da Central de Risco (Evandro).

               20/07/2004 - Impressao Valor Utilizado(Evandro)

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               23/05/2006 - Modificados campos referente endereco para a
                            estrutura crapenc (Diego).
                            
               12/01/2007 - Substituido cidade do PAC da tabela craptab por
                            cidade do PAC da tabela crapage (Elton).

               02/05/2007 - Criar layout para impressao do contrato de
                            limite empresarial (David).

               29/05/2007 - Acerto na alteracao acima (David).
               
               25/10/2007 - Mostrar secao a partir da ttl.nmdsecao(Guilherme).
               
               18/02/2008 - Se cje possui conta mostrar dados da ass(Guilherme)

               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                            arquivo (Martin).
                
               01/07/2009 - Alteracao para utilizacao de BOs (GATI - Eder)

               05/08/2009 - Enviar proposta via e-mail (David).
               
               02/12/2009 - Impressao do Rating da proposta atual
                            e historico do Rating (Gabriel).
               
               09/06/2010 - Reorganizado layout do limite de credito (Adriano). 
               
               23/06/2010 - Passar a procedure de envio de contratos para
                            a BO 24 (Gabriel).
                            
               20/09/2010 - Utilizar BO para gerar impressao (David).
               
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               25/08/2014 - Ajustes referentes ao Projeto CET (Lucas R./Gielow)
............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i } 

DEF INPUT PARAM par_nrdconta AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_tpimpres AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_nrctrlim AS INTE                                   NO-UNDO.
DEF INPUT PARAM par_flgimpnp AS LOGI                                   NO-UNDO.

DEF VAR par_flgrodar AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgfirst AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgcance AS LOGI                                           NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.

DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
                                                                    
DEF VAR aux_contador AS INTE                                           NO-UNDO.

DEF VAR tel_flgemail AS LOGI                                           NO-UNDO.
                                                                    
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"             NO-UNDO.
                                                                    
DEF VAR h-b1wgen0019 AS HANDLE                                         NO-UNDO.

FORM "Aguarde... Imprimindo contrato e proposta!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_1.
     
FORM "Aguarde... Imprimindo contrato!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_2.

FORM "Aguarde... Imprimindo proposta!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_3.

FORM "Aguarde... Imprimindo termo de cancelamento!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_4.

FORM "Aguarde... Imprimindo CET!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde_5.

FORM SKIP(1)
     "Efetuar envio de e-mail para Sede?" AT 3
     tel_flgemail NO-LABEL FORMAT "S/N"
     SKIP(1)
     WITH OVERLAY ROW 14 CENTERED WIDTH 42 TITLE COLOR NORMAL "Destino"
     FRAME f_email.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

ASSIGN tel_flgemail = FALSE.
    
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    UPDATE tel_flgemail WITH FRAME f_email.
    LEAVE.

END. /** Fim do DO WHILE TRUE **/

HIDE FRAME f_email NO-PAUSE.

IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
    ASSIGN tel_flgemail = FALSE.

CASE par_tpimpres:
    WHEN 1 THEN VIEW FRAME f_aguarde_1.
    WHEN 2 THEN VIEW FRAME f_aguarde_2.
    WHEN 3 THEN VIEW FRAME f_aguarde_3.
    WHEN 4 THEN VIEW FRAME f_aguarde_4.
    WHEN 6 THEN VIEW FRAME f_aguarde_5. /* impressao do cet */
END CASE.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.
   
RUN sistema/generico/procedures/b1wgen0019.p PERSISTENT SET h-b1wgen0019. 

IF  NOT VALID-HANDLE(h-b1wgen0019)  THEN
    DO:
        BELL.
        MESSAGE "Handle invalido para BO b1wgen0019.".
        PAUSE 3 NO-MESSAGE.
        HIDE MESSAGE NO-PAUSE.

        HIDE FRAME f_aguarde_1 NO-PAUSE.
        HIDE FRAME f_aguarde_2 NO-PAUSE.
        HIDE FRAME f_aguarde_3 NO-PAUSE.
        HIDE FRAME f_aguarde_4 NO-PAUSE.
        HIDE FRAME f_aguarde_5 NO-PAUSE.

        RETURN.
    END.

RUN gera-impressao-limite IN h-b1wgen0019 (INPUT glb_cdcooper,
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT glb_cdoperad,
                                           INPUT glb_nmdatela,
                                           INPUT 1,
                                           INPUT par_nrdconta,
                                           INPUT 1,
                                           INPUT glb_dtmvtolt,
                                           INPUT glb_dtmvtopr,
                                           INPUT glb_inproces,
                                           INPUT par_tpimpres,
                                           INPUT par_nrctrlim,
                                           INPUT par_flgimpnp,
                                           INPUT aux_nmendter,
                                           INPUT tel_flgemail,
                                           INPUT TRUE,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0019.

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

        HIDE FRAME f_aguarde_1 NO-PAUSE.
        HIDE FRAME f_aguarde_2 NO-PAUSE.
        HIDE FRAME f_aguarde_3 NO-PAUSE.
        HIDE FRAME f_aguarde_4 NO-PAUSE.
        HIDE FRAME f_aguarde_5 NO-PAUSE.

        RETURN.
    END.

HIDE FRAME f_aguarde_1 NO-PAUSE.
HIDE FRAME f_aguarde_2 NO-PAUSE.
HIDE FRAME f_aguarde_3 NO-PAUSE.
HIDE FRAME f_aguarde_4 NO-PAUSE.
HIDE FRAME f_aguarde_5 NO-PAUSE.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

{ includes/impressao.i }

RETURN.

/*............................................................................*/
