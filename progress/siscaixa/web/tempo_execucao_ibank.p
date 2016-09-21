/*.............................................................................

   Programa: siscaixa/web/tempo_execucao_ibank.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : David
   Data    : Dezembro/2014                    Ultima atualizacao: 00/00/0000

   Dados referentes ao programa:

   Frequencia: Conforme tempo de monitoracao
   Objetivo  : Executar requisicao no servico WebSpeed do InternetBank para
               monitoracao de performance e disponibilidade
   
   Alteracoes: 28/07/2015 - Adição de parâmetro flmobile para indicar se origem
                            da chamada é do mobile (Dionathan)
                             
.............................................................................*/ 

{ sistema/internet/includes/var_ibank.i }

/* Include para usar os comandos para WEB */
{src/web2/wrap-cgi.i}

/* Configura a saída como XML */
OUTPUT-CONTENT-TYPE ("text/xml":U).

{&out} "<?xml version='1.0' encoding='ISO-8859-1' ?><CECRED><RETORNO>".

DEF VAR aux_dsmsgerr AS CHAR NO-UNDO.

FIND crapdat WHERE crapdat.cdcooper = 1 NO-LOCK NO-ERROR.

RUN sistema/internet/fontes/InternetBank1.p (INPUT crapdat.cdcooper,
                                             INPUT 329,
                                             INPUT 1,
                                             INPUT 0,
                                             INPUT crapdat.dtmvtolt,
                                             INPUT crapdat.dtmvtopr,
                                             INPUT crapdat.dtmvtocd,
                                             INPUT crapdat.inproces,
                                             INPUT 0,
                                             INPUT crapdat.dtmvtolt,
                                             INPUT "",
                                             INPUT "",
                                             INPUT crapdat.dtmvtoan,
                                             INPUT FALSE,
                                            OUTPUT aux_dsmsgerr,
                                            OUTPUT TABLE xml_operacao) NO-ERROR.

IF  ERROR-STATUS:NUM-MESSAGES > 0  THEN
    {&out} "NOK".    
ELSE
    {&out} "OK".

{&out} "</RETORNO></CECRED>".
