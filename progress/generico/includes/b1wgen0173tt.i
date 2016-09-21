/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0173tt.i
    Autor   : Douglas Quisinski (CECRED)
    Data    : Dezembro/2014                     Ultima atualizacao:   /  /
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0173.
  
    Alteracoes: 
               
.............................................................................*/

DEF TEMP-TABLE tt-crapcop NO-UNDO
    FIELD cdcooper LIKE crapcop.cdcooper
    FIELD dsdircop LIKE crapcop.dsdircop.

DEF TEMP-TABLE tt-creditos NO-UNDO
    FIELD cdagenci AS   INTE             COLUMN-LABEL "PA"
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD inpessoa AS   CHAR             COLUMN-LABEL "Tp.Pes"
    FIELD vlrendim LIKE crapcld.vlrendim COLUMN-LABEL "Rendimento" 
                                         FORMAT "zzz,zzz,zz9.99"
    FIELD vltotcre LIKE crapcld.vltotcre COLUMN-LABEL "Credito"  
    FIELD qtultren AS   INT              COLUMN-LABEL "Credito/Renda"
    FIELD flextjus LIKE crapcld.flextjus
    FIELD cddjusti LIKE crapcld.cddjusti
    FIELD dsdjusti LIKE crapcld.dsdjusti
    FIELD cdoperad LIKE crapcld.cdoperad
    FIELD infrepcf AS   CHAR             COLUMN-LABEL "COAF"
    FIELD opeenvcf LIKE crapcld.opeenvcf 
    FIELD dsobserv LIKE crapcld.dsobserv
    FIELD dsobsctr LIKE crapcld.dsobsctr
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD dsstatus AS   CHAR             COLUMN-LABEL "Status"
    FIELD nrdrowid AS   ROWID.

DEF TEMP-TABLE tt-atividade NO-UNDO
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD tpvincul LIKE crapass.tpvincul 
    FIELD cdagenci LIKE crapass.cdagenci 
    FIELD vlrendim LIKE crapcld.vlrendim COLUMN-LABEL "Rendimento" 
                                         FORMAT "zzz,zzz,zz9.99"
    FIELD vltotcre LIKE crapcld.vltotcre COLUMN-LABEL "Credito"  
    FIELD qtultren AS   INT              COLUMN-LABEL "Credito/Renda"
    FIELD cddjusti LIKE crapcld.cddjusti 
    FIELD dsdjusti LIKE crapcld.dsdjusti 
    FIELD infrepcf AS   CHAR             COLUMN-LABEL "COAF"
    FIELD dsobserv LIKE crapcld.dsobserv
    FIELD dsobsctr LIKE crapcld.dsobsctr
    FIELD dsstatus AS   CHAR             COLUMN-LABEL "Status".

DEF TEMP-TABLE tt-pesquisa NO-UNDO
    FIELD cdagenci AS   INTE             COLUMN-LABEL "PA"
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD dtmvtolt LIKE crapcld.dtmvtolt
    FIELD vlrendim LIKE crapcld.vlrendim COLUMN-LABEL "Rendimento"   
                                         FORMAT "zzz,zzz,zz9.99"
    FIELD vltotcre LIKE crapcld.vltotcre COLUMN-LABEL "Credito"      
    FIELD qtultren AS   INT              COLUMN-LABEL "Credito/Renda"
    FIELD dsstatus AS   CHAR             COLUMN-LABEL "Status"
    FIELD dsdjusti LIKE crapcld.dsdjusti
    FIELD infrepcf AS   CHAR             COLUMN-LABEL "COAF".

DEF TEMP-TABLE tt-just NO-UNDO
    FIELD cddjusti AS INTE FORMAT "z9"
    FIELD dsdjusti AS CHAR FORMAT "x(55)".

DEF TEMP-TABLE tt-crapcld NO-UNDO
    FIELD rowidcld AS   ROWID
    FIELD nrdconta LIKE crapcld.nrdconta.
