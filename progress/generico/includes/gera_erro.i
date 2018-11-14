/*..............................................................................

   Programa: gera_erro.i                   
   Autor   : David
   Data    : Outubro/2007                      Ultima atualizacao: 08/11/2007   

   Dados referentes ao programa:

   Objetivo  : Include para geracao de erros
               Necessita a definicao da temp-table "tt-erro" no programa que
               efetua chamada da include.

   Alteracoes: 08/11/2007 - Output no parametro par_dscritic (David).
   
			   14/11/2018 - Tratamento para sobreescrever registro quando
							receber um nrsequen ja existente, evitando 
							crashes na apliccao (Pablão).

..............................................................................*/

PROCEDURE gera_erro:
    
    DEF  INPUT        PARAM par_cdcooper LIKE craperr.cdcooper      NO-UNDO.
    DEF  INPUT        PARAM par_cdagenci LIKE craperr.cdagenci      NO-UNDO.
    DEF  INPUT        PARAM par_nrdcaixa LIKE craperr.nrdcaixa      NO-UNDO.
    DEF  INPUT        PARAM par_nrsequen LIKE craperr.nrsequen      NO-UNDO.
    DEF  INPUT        PARAM par_cdcritic LIKE craperr.cdcritic      NO-UNDO.
    DEF  INPUT-OUTPUT PARAM par_dscritic LIKE craperr.dscritic      NO-UNDO.
    
	/*Verifica se o registro ja existe e atualiza, senao cria novo*/
	FIND tt-erro WHERE tt-erro.cdcooper = par_cdcooper AND
                       tt-erro.cdagenci = par_cdagenci AND
                       tt-erro.nrdcaixa = par_nrdcaixa AND
                       tt-erro.nrsequen = par_nrsequen NO-LOCK NO-ERROR.
	
	IF  NOT AVAILABLE tt-erro  THEN
	DO:
		CREATE tt-erro.
	END.
	
    ASSIGN tt-erro.cdcooper = par_cdcooper
           tt-erro.cdagenci = par_cdagenci
           tt-erro.nrdcaixa = par_nrdcaixa
           tt-erro.nrsequen = par_nrsequen  
           tt-erro.erro     = YES
           tt-erro.cdcritic = par_cdcritic            
           tt-erro.dscritic = par_dscritic.
           
    IF  par_cdcritic <> 0  THEN
        DO:
            FIND crapcri WHERE crapcri.cdcritic = par_cdcritic NO-LOCK NO-ERROR.
            
            IF  AVAILABLE crapcri  THEN     
                ASSIGN tt-erro.dscritic = crapcri.dscritic.
            ELSE
                ASSIGN tt-erro.dscritic = "Critica nao cadastrada.".
                
            par_dscritic = tt-erro.dscritic.    
        END.

END PROCEDURE.

/*............................................................................*/