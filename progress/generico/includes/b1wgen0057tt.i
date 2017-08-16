/*..............................................................................

    Programa: b1wgen0057tt.i
    Autor   : Jose Luis
    Data    : Marco/2010                   Ultima atualizacao: 00/00/0000   

    Objetivo  : Definicao das Temp-Tables para tela de CONJUGE

    Alteracoes: 
   
..............................................................................*/


DEFINE TEMP-TABLE tt-crapcje NO-UNDO LIKE crapcje
    FIELD dsescola AS CHARACTER
    FIELD rsfrmttl AS CHARACTER
    FIELD rsnatocp AS CHARACTER
    FIELD rsdocupa AS CHARACTER
    FIELD dsctrtab AS CHARACTER
    FIELD rsnvlcgo AS CHARACTER
    FIELD dsturnos AS CHARACTER
    FIELD cdgraupr AS INTEGER
    FIELD dsblqalt AS CHARACTER
    FIELD cdoedcje AS CHARACTER
    FIELD nrdrowid AS ROWID.
                                                                                
&IF DEFINED(TT-LOG) <> 0 &THEN

    DEF TEMP-TABLE tt-crapcje-ant NO-UNDO LIKE crapcje.

    DEF TEMP-TABLE tt-crapcje-atl NO-UNDO LIKE tt-crapcje-ant.

&ENDIF

/*............................................................................*/
    
    
