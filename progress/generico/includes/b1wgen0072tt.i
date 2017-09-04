/*.............................................................................

    Programa: b1wgen0072tt.i
    Autor   : Jose Luis Marchezoni
    Data    : Maio/2010                   Ultima atualizacao: 13/04/2017

    Objetivo  : Definicao das Temp-Tables, CONTAS - RESPONSAVEL LEGAL

    Alteracoes: 16/04/2012 - Ajustes referente ao projto GP - Socios Menores
                             (Adriano).
                                                         
                27/07/2015 - Reformulacao cadastral (Gabriel-RKAM).            

                13/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
.............................................................................*/



/*...........................................................................*/

DEF TEMP-TABLE tt-crapcrl NO-UNDO LIKE crapcrl
     FIELD dsestcvl AS CHAR
     FIELD nrdrowid AS ROWID
     FIELD deletado AS LOG
     FIELD cddopcao AS CHAR
     FIELD cddctato LIKE crapass.nrdconta
     FIELD dtdenasc AS DATE
     FIELD cdhabmen AS INT
     FIELD dsorgemi AS CHAR
     FIELD dsnacion LIKE crapnac.dsnacion.

DEF TEMP-TABLE tt-cratcrl NO-UNDO LIKE tt-crapcrl.
  
DEF TEMP-TABLE tt-resp    NO-UNDO LIKE tt-cratcrl.  

DEF TEMP-TABLE Relacionamento                                       NO-UNDO
    FIELD cdrelacionamento AS INTE
    FIELD dsrelacionamento AS CHAR.
                                         
&IF DEFINED(TT-LOG) <> 0 &THEN

    DEFINE TEMP-TABLE tt-crapcrl-ant NO-UNDO LIKE crapcrl.

    DEFINE TEMP-TABLE tt-crapcrl-atl NO-UNDO LIKE crapcrl.

&ENDIF
