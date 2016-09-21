/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0152tt.i
    Autor(a): Gabriel Capoia (DB1)
    Data    : 04/02/2013                      Ultima atualizacao: 08/04/2014
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0152.
  
    Alteracoes: 08/04/2014 - Adicionado FIELD cdcooper 'a temp-table
                             tt-creditos (tratamento WHOLE-INDEX). (Fabricio)
    
.............................................................................*/ 

DEF TEMP-TABLE tt-creditos NO-UNDO
    FIELD cdcooper LIKE crapcld.cdcooper
    FIELD nrdconta LIKE crapcld.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD inpessoa AS   CHAR             COLUMN-LABEL "Tp.Pes"
    FIELD vlrendim LIKE crapcld.vlrendim COLUMN-LABEL "Rendimento"
    FIELD vltotcre LIKE crapcld.vltotcre COLUMN-LABEL "Credito"   
    FIELD flextjus LIKE crapcld.flextjus COLUMN-LABEL "Just."
    FIELD cddjusti LIKE crapcld.cddjusti
    FIELD dsdjusti LIKE crapcld.dsdjusti
    FIELD dsobserv LIKE crapcld.dsobserv
    FIELD cdoperad LIKE crapcld.cdoperad
    FIELD nrdrowid AS   ROWID 
    INDEX icrapcld cdcooper nrdconta.
	
DEF TEMP-TABLE tt-just NO-UNDO
    FIELD cddjusti AS INTE FORMAT "z9"
    FIELD dsdjusti AS CHAR FORMAT "x(55)".
