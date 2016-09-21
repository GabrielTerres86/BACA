/*..............................................................................

   Programa: internet/fontes/InternetBank134.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vanessa
   Data    : Abril/2015.                       Ultima atualizacao:  /  /

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar os Bancos pelo ISPB
   
   Alteracoes:
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
                           
DEF  INPUT PARAM par_cdcooper LIKE crapcop.nmrescop                    NO-UNDO.
DEF  INPUT PARAM par_nrispbif LIKE crapban.nrispbif                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
 
    FIND crapban WHERE crapban.nrispbif = par_nrispbif NO-LOCK NO-ERROR.
MESSAGE par_nrispbif.
    IF AVAILABLE crapban THEN
        DO:
          CREATE xml_operacao.
          ASSIGN xml_operacao.dslinxml = 
          "<DADOS>" +
          "<cddbanco>"  + STRING(crapban.cdbccxlt) + "</cddbanco>" + 
          "<cdageban>"  + STRING(crapban.nrispbif) + "</cdageban>" + 
          "<nmageban>"  + STRING(crapban.nmresbcc) + "</nmageban>" + 
          "</DADOS>".
        
        END.
        
        
    ELSE 
        DO:
            ASSIGN aux_dscritic = "Banco Inexistente.".
            xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic + "</dsmsgerr>". 
            RETURN "NOK".
        END.

    RETURN 'OK'.
       

/*............................................................................*/


