
/*..............................................................................
   
   Programa: sistema/internet/fontes/InternetBank117.p
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme/SUPERO
   Data    : Agosto/2014                       Ultima atualizacao: 24/07/2015
   
   Dados referentes ao programa:
   Frequencia: Sempre que for chamado (On-Line)
   
   Objetivo  : Gerar arquivo de retorno de Pagamento de Titulos em Lote
      
   Alteracoes: 18/06/2015 - Alterado para ler o xml retornado do procedimento 
                            oracle e incluir na temptable de retorno para web
                            SD294550 (Odirlei-AMcom)
                            
               24/07/2015 - Substituir '&' por 'E' ao gerar arquivo de retorno
                            ao cooperado. (Rafael)
                            
               05/09/2017 - Quando o cooperado possui retorno do arquivo via FTP
                            o arquivo sera disponibilizado no FTP e nao baixado, 
                            com isso devemos retornar uma mensagem informando o 
                            cooperado. (Douglas - Melhoria 271.3)
..............................................................................*/



 { sistema/internet/includes/var_ibank.i    }
 { sistema/generico/includes/var_internet.i }
 { sistema/generico/includes/var_oracle.i   }

 DEF INPUT  PARAM par_cdcooper  LIKE crapcop.cdcooper                   NO-UNDO.
 DEF INPUT  PARAM par_nrdconta  LIKE crapass.nrdconta                   NO-UNDO.
 DEF INPUT  PARAM par_nrconven  LIKE crapass.nrdconta                   NO-UNDO.
 DEF INPUT  PARAM par_nrremret  AS INT                                  NO-UNDO.
 DEF INPUT  PARAM par_dtmvtolt  AS DATE                                 NO-UNDO.
 DEF INPUT  PARAM par_idorigem  AS INT                                  NO-UNDO.

 DEF OUTPUT PARAM par_nmarquiv  AS CHAR                                 NO-UNDO.
 DEF OUTPUT PARAM xml_dsmsgerr  AS CHAR                                 NO-UNDO.
 DEF OUTPUT PARAM               TABLE FOR xml_operacao.
 
 DEF VAR aux_xml_operacao AS LONGCHAR                                   NO-UNDO.
 DEF VAR aux_cdcritic AS INT                                            NO-UNDO.
 DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
 DEF VAR aux_dsinform AS CHAR                                           NO-UNDO.
 DEF VAR aux_flabrtag AS LOG                                            NO-UNDO.
 DEF VAR aux_dslinxml AS CHAR                                           NO-UNDO.
 DEF VAR aux_arquivo  AS CHAR                                           NO-UNDO.
 /* Variaveis para o XML */ 
 DEF VAR xDoc          AS HANDLE                                        NO-UNDO.   
 DEF VAR xRoot         AS HANDLE                                        NO-UNDO.  
 DEF VAR xRoot2        AS HANDLE                                        NO-UNDO.  
 DEF VAR xField        AS HANDLE                                        NO-UNDO. 
 DEF VAR xText         AS HANDLE                                        NO-UNDO. 
 DEF VAR aux_cont_raiz AS INTEGER                                       NO-UNDO. 
 DEF VAR aux_cont      AS INTEGER                                       NO-UNDO. 
 DEF VAR ponteiro_xml  AS MEMPTR                                        NO-UNDO.
 

{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

 RUN STORED-PROCEDURE pc_gerar_arq_ret_pgto aux_handproc = PROC-HANDLE NO-ERROR
                      (INPUT par_cdcooper,
                       INPUT par_nrdconta,
                       INPUT par_nrconven,
                       INPUT par_nrremret,
                       INPUT par_dtmvtolt,
                       INPUT 3, /* par_idorigem - 3 - Internet Banking */
                       INPUT "996", /* cdoperad */
                       OUTPUT "",
                       OUTPUT "",
                       OUTPUT "",
                       OUTPUT 0,
                       OUTPUT "").

 CLOSE STORED-PROC pc_gerar_arq_ret_pgto aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

 ASSIGN aux_xml_operacao = ""
        aux_cdcritic = 0
        aux_dscritic = ""
        aux_dsinform = ""
        aux_cdcritic = pc_gerar_arq_ret_pgto.pr_cdcritic
                       WHEN pc_gerar_arq_ret_pgto.pr_cdcritic <> ?
        aux_dscritic = pc_gerar_arq_ret_pgto.pr_dscritic
                       WHEN pc_gerar_arq_ret_pgto.pr_dscritic <> ?
        aux_dsinform = pc_gerar_arq_ret_pgto.pr_dsinform
                       WHEN pc_gerar_arq_ret_pgto.pr_dsinform <> ?
        aux_xml_operacao = pc_gerar_arq_ret_pgto.pr_dsarquiv
                       WHEN pc_gerar_arq_ret_pgto.pr_dsarquiv <> ?.

 { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

 IF  aux_cdcritic <> 0   OR
     aux_dscritic <> ""  THEN DO: 

     IF  aux_dscritic = "" THEN DO:
         FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic 
                    NO-LOCK NO-ERROR.

         IF  AVAIL crapcri THEN
             ASSIGN aux_dscritic = crapcri.dscritic.
         ELSE
             ASSIGN aux_dscritic =  "Nao foi possivel verificar " +
                                    "efetuar download do arquivo de retorno.".
     END.

     ASSIGN xml_dsmsgerr = "<dsmsgerr>" + aux_dscritic +
                        "</dsmsgerr>".  

     RETURN "NOK".

 END.
 
 IF aux_dsinform <> "" THEN
 DO:
    /* Incluir linha no xml */
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = "<dsinform>" + 
                                   aux_dsinform +
                                   "</dsinform>".
    
    RETURN "OK".
 END.
 
 
 /**********************************************/
  /**LER XML RETORNADO DO PROCEDIMENTO ORACLE **/ 
  /**********************************************/
  /* Inicializando objetos para leitura do XML */ 
  CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
  CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
  CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
  CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
  CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
  ASSIGN aux_flabrtag = FALSE.
  
  /***************************************/
  /* Efetuar a leitura do XML operacao26 */ 
  /***************************************/
/*  RUN fontes/substitui_caracter.p (INPUT-OUTPUT aux_xml_operacao). */

ASSIGN aux_xml_operacao = REPLACE(aux_xml_operacao,"&","E")
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Á","A")
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Â","A")
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Ã","A")
       
       aux_xml_operacao = REPLACE(aux_xml_operacao,"É","E")     
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Ê","E")
        
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Í","I")
       
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Ó","O")      
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Ô","O")        
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Õ","O")
          
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Ú","U")    
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Û","U")

       aux_xml_operacao = REPLACE(aux_xml_operacao,"í","i")
       aux_xml_operacao = REPLACE(aux_xml_operacao,"Ç","C") 

       aux_xml_operacao = REPLACE(aux_xml_operacao,"'"," ")        
       aux_xml_operacao = REPLACE(aux_xml_operacao,"`"," ").

  SET-SIZE(ponteiro_xml) = LENGTH(aux_xml_operacao) + 1. 
  PUT-STRING(ponteiro_xml,1) = aux_xml_operacao. 


  IF ponteiro_xml <> ? THEN  
  DO:
    
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE).       
    
    xDoc:GET-DOCUMENT-ELEMENT(xRoot) NO-ERROR.
    
    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        
        /* Limpar variaveis  */ 
        ASSIGN aux_dslinxml = "".   
            
        xRoot:GET-CHILD(xField,aux_cont_raiz) NO-ERROR. 

        IF xField:SUBTYPE <> "ELEMENT" THEN 
            NEXT. 
        
        xField:GET-CHILD(xText,1) NO-ERROR. 
        
        /* Se nao vier conteudo na TAG */ 
        IF ERROR-STATUS:ERROR             OR  
           ERROR-STATUS:NUM-MESSAGES > 0  THEN
           NEXT.
        
        /* Verificar se deve abrir a tag
           qnd for a primeira vez no loop*/
        IF aux_flabrtag = FALSE THEN
        DO:
          
          ASSIGN aux_arquivo  = xText:NODE-VALUE WHEN xField:NAME = "arquivo"
                 aux_flabrtag = TRUE.
                 
          /* Incluir linha no xml */
          CREATE xml_operacao.
          ASSIGN xml_operacao.dslinxml = '<retorno><arquivo>' +
                                         aux_arquivo + 
                                         '</arquivo>'.
          
        END.
        
        ASSIGN aux_dslinxml = xText:NODE-VALUE WHEN xField:NAME = "linha".
        
        /* Incluir linha no xml */
        CREATE xml_operacao.
        ASSIGN xml_operacao.dslinxml = "<linha>" + aux_dslinxml +
                                        "</linha>".
   
    END.
    
    SET-SIZE(ponteiro_xml) = 0. 
  END.
   
  /* Verificar se tag foi aberta*/
  IF aux_flabrtag = TRUE THEN
  DO:   
    
    /* Incluir linha no xml */
    CREATE xml_operacao.
    ASSIGN xml_operacao.dslinxml = '</retorno>'.
    
  END. 

  DELETE OBJECT xDoc. 
  DELETE OBJECT xRoot. 
  DELETE OBJECT xRoot2. 
  DELETE OBJECT xField. 
  DELETE OBJECT xText.
  
 RETURN "OK".

 /* ............................... PROCEDURES ............................... */

