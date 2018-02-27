/*..............................................................................

   Programa: internet/fontes/InternetBank128.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Vanessa
   Data    : Dezembro/2014.                       Ultima atualizacao:07/04/2016
   
   Dados referentes ao programa:

   Frequencia: Sempre que for chamado (On-Line)
   Objetivo  : Consultar as Agencias cadastradas
   
   Alteracoes:     17/02/2016 - Ajustes para o cadastro e envio de TED, M. 118
                                (Jean Michel).
                                
                   07/04/2016 - Ajuste para remover caracteres especiais do nmageban,
                                conforme solicitado no chamado 430305. (Kelvin)
                                  
                   09/02/2018 - Ajustado para quando nao encontrar a agencia nao retornar
                                erro. Alguns bancos realmente nao possuem a descricao das
                                agencias publicadas, exemplo banco 102 - XP INVEST.
                                O IB atual ignora as mensagens de erro, conforme fonte:
                                [...]\viacredi\extrato\busca_agencia.php (Anderson - P285)
                                  
..............................................................................*/
    
CREATE WIDGET-POOL.

{ sistema/internet/includes/var_ibank.i }
{ sistema/generico/includes/var_internet.i }
                           
DEF  INPUT PARAM par_cdcooper LIKE crapcop.nmrescop                    NO-UNDO.
DEF  INPUT PARAM par_cdabanco LIKE crapagb.cddbanco                    NO-UNDO.
DEF  INPUT PARAM par_nragenci LIKE crapagb.cdageban                    NO-UNDO.

DEF OUTPUT PARAM xml_dsmsgerr AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM TABLE FOR xml_operacao.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_nmageban AS CHAR									                         NO-UNDO.
 
    FIND crapagb WHERE crapagb.cddbanco = par_cdabanco    AND
                       crapagb.cdageban =  par_nragenci  NO-LOCK NO-ERROR.

    IF AVAILABLE crapagb THEN
        DO:
          ASSIGN aux_nmageban = crapagb.nmageban.
	
          RUN sistema/ayllos/fontes/substitui_caracter.p (INPUT-OUTPUT aux_nmageban).  
          
          CREATE xml_operacao.
          ASSIGN xml_operacao.dslinxml = 
          "<DADOS>" +
          "<cddbanco>"  + TRIM(STRING(crapagb.cddbanco)) + "</cddbanco>" + 
          "<cdageban>"  + TRIM(STRING(crapagb.cdageban)) + "</cdageban>" + 
          "<nmageban>"  + TRIM(STRING(aux_nmageban))     + "</nmageban>" + 
          "</DADOS>".
   
        END.
        
        
    ELSE 
        DO:
            CREATE xml_operacao.
            ASSIGN xml_operacao.dslinxml = 
            "<DADOS>" +
            "<cddbanco>"  + TRIM(STRING(par_cdabanco)) + "</cddbanco>" + 
            "<cdageban>"  + TRIM(STRING(par_nragenci)) + "</cdageban>" + 
            "<nmageban>"  + "</nmageban>" + 
            "</DADOS>".
        END.

    RETURN 'OK'.

/*............................................................................*/


