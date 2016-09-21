/*..............................................................................

    Programa: b1wgen0017.p
    Autor   : Evandro
    Data    : Maio/2007                      Ultima Atualizacao: 11/05/2016
    
    Dados referentes ao programa:

    Objetivo  : BO para listar os holerites.

    Alteracoes: 07/03/2008 - Utilizar include para temp-table (David).
    
                28/07/2011 - Alterado ordenacao por data decrescente (Jorge).
                
                27/12/2013 - Alterado 3a linha de PAC para PA. (Reinert)
                
                18/08/2015 - Alteraçoes Projeto 158 - Folha IB (Vanessa)
                
                09/12/2015 - Ajustando campo dtrefere para CHAR.
                             (Andre Santos - SUPERO)


                11/05/2016 - Melhoria na mensagem quando nao houver
				             comprovante. (Marcos-Supero)
					       - Remocao do procedimento detalha_holerite
							 convertido e nao mais utilizado (Marcos-Supero)


..............................................................................*/
{ sistema/generico/includes/b1wgen0017tt.i }
{ sistema/internet/includes/var_ibank.i    }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/var_oracle.i   }


/* Variáveis utilizadas para receber clob da rotina no oracle */
DEF VAR xDoc          AS HANDLE   NO-UNDO.   
DEF VAR xRoot         AS HANDLE   NO-UNDO.  
DEF VAR xRoot2        AS HANDLE   NO-UNDO.  
DEF VAR xField        AS HANDLE   NO-UNDO. 
DEF VAR xText         AS HANDLE   NO-UNDO. 
DEF VAR aux_cont_raiz AS INTEGER  NO-UNDO. 
DEF VAR aux_cont      AS INTEGER  NO-UNDO. 
DEF VAR ponteiro_xml  AS MEMPTR   NO-UNDO. 
DEF VAR xml_req       AS LONGCHAR NO-UNDO.



PROCEDURE lista_holerites:

    DEF INPUT  PARAM par_cdcooper LIKE crapcop.cdcooper             NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crapass.nrdconta             NO-UNDO.
    DEF INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-holerites.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.
    
    DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtrefere AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdpagto AS CHAR                                    NO-UNDO.
    DEF VAR aux_idtipfol AS INT                                     NO-UNDO.
    DEF VAR aux_nrdrowid AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-holerites.
    
    /* Inicializando objetos para leitura do XML */ 
    CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
    CREATE X-NODEREF  xRoot.   /* Vai conter a tag raiz em diante */ 
    CREATE X-NODEREF  xRoot2.  /* Vai conter a tag aplicacao em diante */ 
    CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
    CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 
    
   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
   
    /* Efetuar a chamada a rotina Oracle */
    RUN STORED-PROCEDURE pc_lista_holerites_ib
    aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper     /* Código da Cooperativa*/
                                        ,INPUT par_nrdconta             /* Código do Operador*/
                                        ,INPUT par_idseqttl     /* Nome da Tela*/
                                        ,OUTPUT ?               /* XML com informações de LOG*/
                                        ,OUTPUT 0               /* Código da crítica */
                                        ,OUTPUT "").            /* Descrição da crítica */

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_lista_holerites_ib
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_cdcritic = pc_lista_holerites_ib.pr_cdcritic 
                         WHEN pc_lista_holerites_ib.pr_cdcritic <> ?
          aux_dscritic = pc_lista_holerites_ib.pr_dscritic 
                         WHEN pc_lista_holerites_ib.pr_dscritic <> ?.
                                                        
    /* Buscar o XML na tabela de retorno da procedure Progress */ 
    ASSIGN xml_req = pc_lista_holerites_ib.pr_clobxml.
    
    /* Efetuar a leitura do XML*/ 
    SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
    PUT-STRING(ponteiro_xml,1) = xml_req. 
    
    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
    xDoc:GET-DOCUMENT-ELEMENT(xRoot).
      
    DO  aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 
        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
        
        IF xRoot2:SUBTYPE <> "ELEMENT"   THEN 
           NEXT. 
    
        IF xRoot2:NUM-CHILDREN > 0 THEN
           CREATE tt-holerites.

        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:
        
            xRoot2:GET-CHILD(xField,aux_cont).
            
           
       
            IF xField:SUBTYPE <> "ELEMENT" THEN 
                NEXT. 
            
            xField:GET-CHILD(xText,1).                   
            
            
            ASSIGN aux_dtrefere =     (xText:NODE-VALUE) WHEN xField:NAME = "dtrefere"
                   aux_dsdpagto =     (xText:NODE-VALUE) WHEN xField:NAME = "dsdpagto"
                   aux_idtipfol = INT (xText:NODE-VALUE) WHEN xField:NAME = "idtipfol"
                   aux_nrdrowid =     (xText:NODE-VALUE) WHEN xField:NAME = "nrdrowid".                   
             
                   
        END.
        
        ASSIGN tt-holerites.dtrefere = aux_dtrefere
               tt-holerites.dsdpagto = aux_dsdpagto
               tt-holerites.nrdrowid = aux_nrdrowid
               tt-holerites.idtipfol = aux_idtipfol.
        
   
    END.
    
    
    FIND FIRST tt-holerites NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE tt-holerites   THEN
         DO:
             par_dscritic = "  O comprovante salarial está disponível apenas para cooperados que recebem crédito de salário na Cooperativa.  ".
             RETURN "NOK".
         END.
   
    
    RETURN "OK".
 
END PROCEDURE.


