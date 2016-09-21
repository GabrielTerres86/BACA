/* .............................................................................

   Programa: Fontes/seguro_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Junho/97.                        Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da impressao da proposta e/ou contrato
               de seguros.

   Alteracoes: 04/09/98 - Tratar tipo de conta 7 (Deborah).

               07/06/1999 - Tratar CPMF (Deborah)
               
               21/09/2001 - Seguro Residencial (Ze Eduardo).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).
               
               24/03/2005 - Tratamento para tipo de seguro 11 - CASA (Evandro).
               
               15/04/2005 - Nao imprimir o "PARA DIGITACAO" quando for
                            substituicao do seguro CASA - tipo 11 (Evandro).

               08/06/2005 - Tratar tipo de conta 17  e 18(Mirtes).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               04/10/2005 - Tirado o frame f_pula_6 antes do frame f_digitacao
                            (Evandro).
                            
               01/12/2005 - Colocar a quantidade de parcelas no seguro tipo
                            CASA (Evandro).
                            
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               09/02/2006 - Correcao na impressao da proposta para parcela
                            unica (Julio)
                            
               26/06/2006 - Mostrar somatoria com numero de parcelas para todas
                            as propostas de seguro tipo 11 (Julio)
                            
               05/07/2006 - Alterado numero de vias da Autorizacao de Debito
                            para seguro residencial CHUBB (Diego).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.

               22/04/2009 - Retirado tudo do seguro AUTO (Gabriel).
               
               05/04/2010 - Retirar frame f_digit_casa (Gabriel).
               
               29/08/2011 - Alterado layout do relatorio para seguros
                            residenciais, de tipo 11 (Gati - Oliver)
                            
               07/12/2011 - Incluir numero de vias igual 2 (Gabriel).   
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................. */

DEF INPUT PARAM par_recidseg AS INT                                  NO-UNDO.

{ sistema/generico/includes/b1wgen0038tt.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }
{ includes/var_seguro_m.i "NEW" }
{ includes/var_cpmf.i } 

/* Include com a tt-erro */
{ sistema/generico/includes/var_internet.i }

DEF VAR aux_nmprogra AS CHAR                                         NO-UNDO.
DEF VAR aux_vlpreseg AS DECIMAL                                      NO-UNDO.
DEFINE VARIABLE aux_nmarqpdf AS CHARACTER   NO-UNDO.

{ includes/cpmf.i } 

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

RUN sistema/generico/procedures/b1wgen0033.p
    PERSISTENT SET h-b1wgen0033.

RUN imprimir_proposta_seguro IN h-b1wgen0033( INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_dtmvtolt,
                                              INPUT aux_nrdconta,
                                              INPUT 1,
                                              INPUT 1,
                                              INPUT glb_nmdatela,
                                              INPUT FALSE,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT aux_nmendter,
                                              INPUT string(par_recidseg),
                                              OUTPUT aux_nmarqimp,
                                              OUTPUT aux_nmarqpdf,
                                              OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0033.

IF   RETURN-VALUE <> "OK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF   AVAIL tt-erro   THEN
            DO:
                ASSIGN glb_dscritic = tt-erro.dscritic
                       glb_cdcritic = tt-erro.cdcritic.

                 BELL.
                 MESSAGE glb_dscritic.
                 glb_cdcritic = 0.
                 RETURN.
            END.
    END.

ASSIGN glb_nrdevias = 2.

FIND FIRST crapass WHERE
       crapass.cdcooper = glb_cdcooper      AND
       crapass.nrdconta = aux_nrdconta  NO-ERROR.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

{ includes/impressao.i }

/* .......................................................................... */

