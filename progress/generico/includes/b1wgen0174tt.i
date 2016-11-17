/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0174tt.i
    Autor   : Oliver Fagionato (GATI)
    Data    : agosto/2013                     Ultima atualizacao: 24/11/2014
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0174.
  
    Alteracoes: 24/11/2014 - Ajuste para liberacao (Adriano)
               
.............................................................................*/

DEF TEMP-TABLE tt-crapcop NO-UNDO
    FIELD cdcooper AS INT.

DEF TEMP-TABLE tt-crapage NO-UNDO
    FIELD cdagenci AS INT FORMAT "zz9" COLUMN-LABEL "PA"
    FIELD nmresage AS CHAR FORMAT "x(15)" COLUMN-LABEL "nome resumido da agencia".

DEF TEMP-TABLE tt-creditos NO-UNDO
    FIELD cdagenci AS INT                              COLUMN-LABEL "PA"
    FIELD nrdconta AS INT  FORMAT "zzzz,zzz,9"         COLUMN-LABEL "conta/dv"
    FIELD nmprimtl AS CHAR FORMAT "x(50)"              COLUMN-LABEL "nome"
    FIELD inpessoa AS CHAR                             COLUMN-LABEL "Tp.Pes"
    FIELD vlrendim AS DEC  FORMAT "zzzzzz,zz9.99"      COLUMN-LABEL "Rendimento"
    FIELD vltotcre AS DEC  FORMAT "zzz,zzz,zzz,zz9.99" COLUMN-LABEL "Credito"  
    FIELD qtultren AS INT                              COLUMN-LABEL "Credito/Renda"
    FIELD flextjus AS LOG                              COLUMN-LABEL "Ext.Justi"
    FIELD cddjusti AS INT  FORMAT "z9"                 COLUMN-LABEL "Cod.Justi"
    FIELD dsdjusti AS CHAR FORMAT "X(60)"              COLUMN-LABEL "Justificativa"
    FIELD cdoperad AS CHAR FORMAT "x(10)"              COLUMN-LABEL "Operador"
    FIELD infrepcf AS CHAR                             COLUMN-LABEL "COAF"
    FIELD opeenvcf AS CHAR FORMAT "X(10)"              COLUMN-LABEL "Ope.Env.COAF"
    FIELD dsobserv AS CHAR FORMAT "X(60)"              COLUMN-LABEL "Just.Sede"
    FIELD dsobsctr AS CHAR FORMAT "X(60)"              COLUMN-LABEL "Just.Central"
    FIELD dtmvtolt AS DATE                             COLUMN-LABEL "Data"
    FIELD nrdrowid AS   ROWID.
