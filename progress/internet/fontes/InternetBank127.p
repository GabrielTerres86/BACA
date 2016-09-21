
/*..............................................................................

   Programa: siscaixa/web/InternetBank127.p
   Sistema : Mobile - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Novembro/2014.                       Ultima atualizacao:  /  /

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (Mobile)
   Objetivo  : Verificar o tipo de pessoa
   
   Alteracoes:
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF  INPUT PARAM par_cdcooper LIKE crapcob.cdcooper                    NO-UNDO.
DEF  INPUT PARAM par_nrdconta LIKE crapcob.nrdconta                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

IF  NOT CAN-FIND(FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                     crapass.nrdconta = par_nrdconta)  THEN
DO:
    ASSIGN aux_dscritic = "Numero de conta inexistente.".
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".  

    RETURN "NOK".
END.

FOR FIRST crapass FIELDS(inpessoa) WHERE crapass.cdcooper = par_cdcooper AND
                                         crapass.nrdconta = par_nrdconta NO-LOCK.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = 
      "<DADOS>" +
      "<inpessoa>"  + STRING(crapass.inpessoa) + "</inpessoa>" + 
      "</DADOS>".

END.

RETURN "OK".

/*............................................................................*/

