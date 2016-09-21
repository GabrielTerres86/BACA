/*..............................................................................

    Programa: b1wgen0037a.p                  
    Autor   : David
    Data    : Janeiro/2009                    Ultima atualizacao: 00/00/0000

    Dados referentes ao programa:

    Objetivo  : Obter nome e descricao do informativo e grupo ao qual pertence

    Alteracoes: 
                            
..............................................................................*/

DEF  INPUT PARAM par_cdprogra AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_cdrelato AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM par_nmrelato AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_dsrelato AS CHAR                                  NO-UNDO.
DEF OUTPUT PARAM par_cdgrprel AS INTE                                  NO-UNDO.
DEF OUTPUT PARAM par_dscritic AS CHAR                                  NO-UNDO.

FIND gnrlema WHERE gnrlema.cdprogra = par_cdprogra AND
                   gnrlema.cdrelato = par_cdrelato NO-LOCK NO-ERROR.
     
IF  NOT AVAILABLE gnrlema  THEN
    DO:
        ASSIGN par_dscritic = "Informativo nao cadastrado.".
        RETURN.
    END.
    
ASSIGN par_nmrelato = gnrlema.nmrelato
       par_dsrelato = gnrlema.dsrelato
       par_cdgrprel = gnrlema.cdgrprel.

/*............................................................................*/