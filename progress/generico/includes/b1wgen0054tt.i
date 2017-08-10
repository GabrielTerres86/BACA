/*..............................................................................

    Programa: b1wgen0054tt.i
    Autor   : Jose Luis
    Data    : Janeiro/2010                   Ultima atualizacao: 20/04/2017  

    Objetivo  : Definicao das Temp-Tables para tela FILIACAO (task 119)

    Alteracoes: 20/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).
   
..............................................................................*/


DEFINE TEMP-TABLE tt-filiacao NO-UNDO 
    FIELD nmpaittl AS CHARACTER
    FIELD nmmaettl AS CHARACTER.

&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-filiacao-ant NO-UNDO 
        FIELD nmpaittl LIKE crapttl.nmpaittl
        FIELD nmmaettl LIKE crapttl.nmmaettl
        FIELD dsfiliac LIKE crapass.dsfiliac.

    DEFINE TEMP-TABLE tt-filiacao-atl NO-UNDO LIKE tt-filiacao-ant.

&ENDIF

/*............................................................................*/


