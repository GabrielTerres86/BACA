/*..............................................................................

    Programa: sistema/generico/includes/b1wgen0070tt.i                  
    Autor   : David
    Data    : Abril/2010                      Ultima atualizacao: 15/02/2011

   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0070.p

   Alteracoes: 15/02/2011 - Incluir campo nos telefones como tipo char
                            (Gabriel)
               
               22/01/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de
			                Transferencia entre PAs (Heitor - RKAM)    
                            
               23/03/2019 - Inclusao dos campos: dssituac; dsdcanal; dtrevisa (Vitor S. Assanuma - GFT)
..............................................................................*/


DEF TEMP-TABLE tt-telefone-cooperado                                    NO-UNDO
    FIELD destptfc AS CHAR
    FIELD tptelefo AS INTE
    FIELD cdseqtfc AS INTE
    FIELD nrdddtfc AS INTE
    FIELD nrtelefo AS DECI
    FIELD nrdramal AS INTE
    FIELD secpscto AS CHAR
    FIELD nmpescto AS CHAR
    FIELD cdopetfn AS INTE
    FIELD nmopetfn AS CHAR
    FIELD nrfonass AS CHAR
    FIELD nrdrowid AS ROWID
    FIELD nrfonres AS CHAR
    FIELD idsittfc AS INTE
    FIELD idorigem AS INTE
    FIELD dssituac AS CHAR
    FIELD dsdcanal AS CHAR
    FIELD dtrevisa AS DATE.

DEF TEMP-TABLE tt-operadoras-celular                                    NO-UNDO
    FIELD cdopetfn AS INTE
    FIELD nmopetfn AS CHAR.


/*............................................................................*/

