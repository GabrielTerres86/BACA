/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank168.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Dionathan
   Data    : Março/2016.                       Ultima atualizacao: 26/02/2016
   
   Dados referentes ao programa:
   
   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Retornar as informações de telefone e horários do SAC e da Ouvidoria
   
   Alteracoes: 
..............................................................................*/
 
CREATE WIDGET-POOL.
    
{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.

DEF OUTPUT PARAM TABLE FOR xml_operacao.


FOR FIRST crapcop FIELDS(nrtelsac nrtelouv hrinisac hrfimsac hriniouv hrfimouv) 
                  WHERE crapcop.cdcooper = par_cdcooper
                  NO-LOCK. END.

IF AVAIL crapcop THEN
  DO:
  
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<nrtelsac>' + STRING(crapcop.nrtelsac) + '</nrtelsac>'.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<hrinisac>' + REPLACE(REPLACE(STRING(crapcop.hrinisac,"HH:MM"),':','h'),'h00','h') + '</hrinisac>'.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<hrfimsac>' + REPLACE(REPLACE(STRING(crapcop.hrfimsac,"HH:MM"),':','h'),'h00','h') + '</hrfimsac>'.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<nrtelouv>' + STRING(crapcop.nrtelouv) + '</nrtelouv>'.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<hriniouv>' + REPLACE(REPLACE(STRING(crapcop.hriniouv,"HH:MM"),':','h'),'h00','h') + '</hriniouv>'.
    
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '<hrfimouv>' + REPLACE(REPLACE(STRING(crapcop.hrfimouv,"HH:MM"),':','h'),'h00','h') + '</hrfimouv>'.
    
  END.
ELSE
  DO:
    ASSIGN aux_dscritic = "Registro de cooperativa nao encontrado."
           xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>".   
          
    RUN proc_geracao_log (INPUT FALSE).  
                             
    RETURN "NOK".
  END.
RETURN "OK".
            
/*............................................................................*/
