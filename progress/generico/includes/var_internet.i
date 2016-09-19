/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | generico/includes/var_internet.i| EXTR0001                          |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/




/*..............................................................................

   Programa: var_internet.i                  
   Autor   : David
   Data    : Agosto/2007                      Ultima atualizacao: 06/04/2016

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas nas BO's genericas da internet

   Alteracoes: 07/11/2007 - Variaveis para geracao de erros e logs (David).

               11/03/2008 - Incluir origem na variavel des_dorigens (David).
                            
               30/05/2008 - Incluir variavel para armazenar data do servidor
                            (David).
                            
               24/09/2010 - Incluir variavel aux_srvintra que armazena o nome
                            do servidor do Ayllos WEB (David).
                            
               20/10/2010 - Ajustar nome do server pkghttpintranet (David).
               
               15/06/2011 - Incluir pkghomol no tratamento para obter nome
                            do server do Ayllos WEB (David).
                            
               20/09/2011 - Alterar nome do server do Ayllos WEB para o 
                            ambiente de producao (David).
                            
               25/05/2011 - Alterar nome do server do Ayllos WEB para o 
                            ambiente de teste (David).
                            
               17/10/2012 - Alterar servidor web de desenvolvimento (David).
               
               19/03/2013 - Alterar dominio do servidor de producao do Ayllos
                            Web (David).
                            
               25/06/2013 - Incluir pkglibera (David)
               
               15/01/2014 - Incluir pkgtreina (David)
                            
			   06/04/2016 - Ajuste para incluir os novos servidores e atualizar
							os seus respectivos apontamentos
							(Adriano).

..............................................................................*/

DEF TEMP-TABLE tt-erro NO-UNDO LIKE craperr.

DEF TEMP-TABLE tt-msg-confirma NO-UNDO
    FIELD inconfir AS INTE 
    FIELD dsmensag AS CHAR.

DEF VAR aux_datdodia AS DATE                                           NO-UNDO.
DEF VAR des_dorigens AS CHAR                                           NO-UNDO.
DEF VAR aux_srvintra AS CHAR                                           NO-UNDO.

/** ---------------------------------------------------- **/
/** Variavel para geracao de log - Origem da Solicitacao **/
/**                                                      **/
/** -> Origem = 1 - AYLLOS                               **/
/** -> Origem = 2 - CAIXA                                **/
/** -> Origem = 3 - INTERNET                             **/
/** -> Origem = 4 - CASH                                 **/
/** -> Origem = 5 - INTRANET (AYLLOS WEB)                **/
/** -> Origem = 6 - URA                                  **/
/** ---------------------------------------------------- **/
ASSIGN des_dorigens = "AYLLOS,CAIXA,INTERNET,CASH,INTRANET,URA".

/** Armazenar data do servidor **/
ASSIGN aux_datdodia = TODAY.

CASE OS-GETENV("PKGNAME"):
    WHEN "pkgprod"    THEN aux_srvintra = "ayllos.cecred.coop.br".
    WHEN "pkglibera1" THEN aux_srvintra = "aylloslibera1.cecred.coop.br".
    WHEN "pkgdesen1"  THEN aux_srvintra = "ayllosdev1.cecred.coop.br".
	WHEN "pkgdesen2"  THEN aux_srvintra = "ayllosdev2.cecred.coop.br".
    WHEN "pkghomol1"  THEN aux_srvintra = "aylloshomol1.cecred.coop.br".
	WHEN "pkghomol2"  THEN aux_srvintra = "aylloshomol2.cecred.coop.br".
	WHEN "pkghomol3"  THEN aux_srvintra = "aylloshomol3.cecred.coop.br".
	WHEN "pkghomol4"  THEN aux_srvintra = "aylloshomol4.cecred.coop.br".	
	WHEN "pkgqa1"     THEN aux_srvintra = "ayllosqa1.cecred.coop.br".	
	WHEN "pkgqa2"     THEN aux_srvintra = "ayllosqa1.cecred.coop.br".	
    WHEN "pkgtreina2" THEN aux_srvintra = "ayllostreina.cecred.coop.br".
END CASE.                   

/*............................................................................*/
