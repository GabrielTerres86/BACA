/*..............................................................................

   Programa: siscaixa/web/InternetBank122.p
   Sistema : Mobile - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2014.                       Ultima atualizacao: 07/11/2014

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (Mobile)
   Objetivo  : Listar as cooperativas ativas
   
   Alteracoes: 07/11/2014 - Removido a CECRED da listagem (Guilherme).
               
               23/06/2015 - Removida abreviação VIACREDI AV (Dionathan).
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_nmrescop AS CHAR                                           NO-UNDO.

FOR EACH crapcop FIELDS(cdcooper cdagectl nmrescop) 
   WHERE crapcop.flgativo 
     AND crapcop.cdcooper <> 3:

    IF crapcop.cdcooper = 16 THEN
       aux_nmrescop = "VIACREDI ALTO VALE".
    ELSE
       aux_nmrescop = crapcop.nmrescop.

    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<DADOS>" +
          "<cdcooper>"  + STRING(crapcop.cdcooper) + "</cdcooper>" + 
          "<cdagectl>"  + STRING(crapcop.cdagectl,"9999") + "</cdagectl>" + 
          "<nmrescop>"  + STRING(UPPER(aux_nmrescop)) + "</nmrescop>" +
          "</DADOS>".

END.

RETURN "OK".

/*............................................................................*/
