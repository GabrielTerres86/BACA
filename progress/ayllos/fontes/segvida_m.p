/* .............................................................................

   Programa: Fontes/segvida_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah
   Data    : Agosto/1999                         Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da impressao da proposta e/ou contrato
               de seguros de vida em grupo.

   Alteracoes: 19/10/1999 - Imprimir mais uma via da proposta (Deborah).

               10/11/1999 - Seguro de vida para conjuge (Deborah).

               20/01/2000 - Tratar seguro prestamista (Deborah).

               31/01/2000 - Incluir a assinatura do conjuge na proposta 
                            de seguro de vida  (Deborah).

               16/02/2000 - Acertar a impressao do segundo titular 
                            (Deborah).
                            
               07/08/2003 - Imprimir nome da cooperativa no cabecalho
                            (Fernando).
                            
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               30/07/2004 - Incluir observacao sobre o cancelamento do seguro
                            (Edson).

               23/03/2005 - Incluir o campo craptsg.cdsegura na leitura da
                            tabela craptsg (Edson).

               11/04/2005 - Imprimir autorizacao de consulta ao SPC (Edson).
               
               16/08/2005 - Alterado para buscar descricao do estado civil
                            na tabela generica gnetcvl(Diego).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               19/01/2006 - Corrigido alinhamento da palavra "PRESTAMISTA"
                            (Evandro).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               11/09/2006 - Incluido clausula 5 sobre "Idade Limite" na
                            proposta de seguro de vida (David).

               11/01/2007 - Efetuado acerto leitura tabela gnetcvl
                            (faltou no-error)(Mirtes)
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase) - Eduardo Silva.
               
               31/03/2010 - Adaptacao para browswe dinamico (Gabriel)
               
               18/08/2010 - Alterado para igualar o estado civil do titular e
                            conjuge (beneficiario) (Vitor).
                            
               10/09/2010 - Alteracao do limite de idade conforme o limite da
                            cooperativa (Vitor).               
                            
               04/10/2010 - Alterar titulo da proposta quando o seguro cobrir
                            o conjuge do cooperado (David).
                            
               12/11/2010 - Incluida a palavra "CADIN" na proposta de seguro
                            (Vitor)
                            
               18/10/2011 - Realizada alteração para utilizar procedure de 
                            impressão imprimir_alt_seg_vida (Lauro).       
                            
               27/02/2013 - Incluir parametro par_cddopcao (Lucas R.)   
               
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
............................................................................. */
DEF INPUT PARAM par_recidseg AS INT                                  NO-UNDO.
DEF INPUT PARAM par_cddopcao AS CHAR                                 NO-UNDO.

DEF STREAM str_1.

DEF VAR aux_nrcntseg AS INT                                          NO-UNDO.
DEF VAR aux_nrctrseg AS INT                                          NO-UNDO.

DEF VAR aux_nmprogra AS CHAR                                         NO-UNDO.
DEF VAR aux_vlpreseg AS DECIMAL                                      NO-UNDO.
DEF VAR aux_idadelmt AS INT FORMAT "z9"                              NO-UNDO.
DEF VAR aux_idadelm2 AS INT FORMAT "z9"                              NO-UNDO.
DEF VAR aux_nrdmeses AS INT                                          NO-UNDO.
DEF VAR aux_dsdidade AS CHAR                                         NO-UNDO.
DEFINE VARIABLE aux_nmarqpdf AS CHARACTER                            NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro_m.i "NEW" }
{ includes/var_cpmf.i } 
{ includes/var_seguro.i } 
{ sistema/generico/includes/var_internet.i }
{ includes/cpmf.i } 
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal. 

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

RUN sistema/generico/procedures/b1wgen0033.p
    PERSISTENT SET h-b1wgen0033.

RUN imprimir_alt_seg_vida IN h-b1wgen0033(INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_dtmvtolt,
                                          INPUT tel_nrdconta,
                                          INPUT 1,
                                          INPUT 1,
                                          INPUT glb_nmdatela,
                                          INPUT FALSE,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT aux_nmendter,
                                          INPUT STRING(par_recidseg),
                                          INPUT par_cddopcao,
                                          OUTPUT aux_nmarqimp,
                                          OUTPUT aux_nmarqpdf,
                                          OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0033.

IF   RETURN-VALUE <> "OK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF   AVAIL tt-erro   THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
                VIEW FRAME f_tipo.
                RETURN NO-APPLY.
            END.
    END.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

ASSIGN glb_nrdevias = 1.

/* Busca a cobertura do plano  */

FIND FIRST crapass WHERE
       crapass.cdcooper = glb_cdcooper      AND
       crapass.nrdconta = tel_nrdconta  NO-ERROR.

{ includes/impressao.i }
/* .......................................................................... */
