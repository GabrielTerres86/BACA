/*.............................................................................

    Programa: sistema/generico/includes/b1wgen0114tt.i
    Autor(a): Rogerius Militão (DB1)
    Data    : Setembro/2011                      Ultima atualizacao: 28/01/2016
  
    Dados referentes ao programa:
  
    Objetivo  : Include com Temp-Tables para a BO b1wgen0114.
  
    Alteracoes: 25/04/2014 - Aumentado format do campo cdlcremp de 3 para 4
                             posicoes (Tiago/Gielow SD137074).
                
                21/01/2015 - Alterado o formato do campo nrctremp para 8 
                             caracters (Kelvin - 233714)
                             
                16/03/2015 - Incluir campo Parecer de Credito (Jonata-RKAM).             
                
                28/01/2016 - Adicionado temp-table tt-dados-portabilidade.
                             (Reinert)
.............................................................................*/ 

DEFINE TEMP-TABLE tt-cmaprv NO-UNDO
       FIELD  cdagenci  AS  INTEGER   FORMAT "zz9"
       FIELD  dtmvtolt  AS  DATE      FORMAT "99/99/9999" 
       FIELD  nrdconta  AS  INTEGER   FORMAT "zzzz,zzz,9"
       FIELD  nrctremp  AS  INTEGER   FORMAT "zz,zzz,zz9"
       FIELD  vlemprst  AS  DECIMAL   FORMAT "zzz,zzz,zz9.99"
       FIELD  cdlcremp  AS  INT       FORMAT "zzz9"
       FIELD  cdfinemp  AS  INT       FORMAT "zz9"
       FIELD  cdopeapv  AS  CHAR      FORMAT "x(10)"
       FIELD  nmoperad  AS  CHAR      FORMAT "x(16)"
       FIELD  insitapv  AS  INT       FORMAT "9"
       FIELD  dsaprova  AS  CHAR      FORMAT "x(20)"
       FIELD  dtaprova  AS  DATE      FORMAT "99/99/9999" 
       FIELD  hrtransa  AS  INT
       FIELD  hrtransf  AS  CHAR
       FIELD  nmprimtl  AS  CHAR      FORMAT "x(30)"
       FIELD  qtpreemp  AS  INT       FORMAT "zz9"
       FIELD  vlpreemp  AS  DECIMAL   FORMAT "zzz,zzz,zz9.99"
       FIELD  dsobscmt  AS  CHAR
       FIELD  cdcomite  AS  INTEGER
       FIELD  nrctrliq  AS  CHAR
       FIELD  dshisobs  AS  CHAR      FORMAT "x(81)"
       FIELD  instatus  AS  INTE      
       FIELD  dsstatus  AS  CHAR      FORMAT "x(20)"  
       INDEX tt-cmaprv1 dtmvtolt nrdconta nrctremp.
                                     
DEFINE TEMP-TABLE tt-emprestimo NO-UNDO
       FIELD  cdopeapv  AS  CHAR      FORMAT "x(10)"
       FIELD  nmoperad  AS  CHAR      FORMAT "x(16)"
       FIELD  dtaprova  AS  DATE      FORMAT "99/99/9999" 
       FIELD  hrtransa  AS  INT
       FIELD  hrtransf  AS  CHAR
       FIELD  dsobscmt  AS  CHAR
       FIELD  dsaprova  AS  CHAR      FORMAT "x(20)"
       FIELD  cdcomite  AS  INTEGER.

DEFINE TEMP-TABLE crabsit NO-UNDO
       FIELD insitapv   AS  INT       FORMAT "z9"
       FIELD dssitapv   AS  CHAR      FORMAT "x(13)".

DEF TEMP-TABLE tt-complemento NO-UNDO
       FIELD cdsequen   AS INT
       FIELD dstipcpl   AS CHAR
       FIELD dscontdo   AS CHAR.

DEF TEMP-TABLE tt-situacao NO-UNDO
       FIELD  insitapv  AS  INT       FORMAT "9"
       FIELD  dsaprova  AS  CHAR      FORMAT "x(20)"
       FIELD  dsresapr  AS  CHAR      FORMAT "x(2)".

DEF TEMP-TABLE tt-dados-portabilidade NO-UNDO
    FIELD ispbif                AS DECI
    FIELD identdpartadmdo       AS DECI
    FIELD cnpjbase_iforcontrto  AS DECI
    FIELD nuportlddctc          AS CHAR
    FIELD codcontrtoor          AS CHAR
    FIELD tpcontrto             AS CHAR
    FIELD tpcli                 AS CHAR
    FIELD cnpj_cpfcli           AS DECI
    FIELD stportabilidade       AS CHAR.

