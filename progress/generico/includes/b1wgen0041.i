/*..............................................................................
  Programa: b1wgen0041.i
  Autor   : Fernando
  Data    : Julho/2009                  Ultima atualizacao: 
  Dados referentes ao programa:

  Objetivo  : Variaveis e temp-tables utlizadas na BO b1wgen0041.p.

  Alteracoes: 
.............................................................................*/

DEF TEMP-TABLE w-rescard  NO-UNDO
    FIELD nrcctitg AS CHAR 
    FIELD nmcctitg AS CHAR 
    FIELD nmestpar AS CHAR  
    FIELD cdestcrt AS CHAR   
    FIELD cdmodcrt AS CHAR   
    FIELD cdparcrt AS CHAR 
    FIELD cdparest AS CHAR 
    FIELD idseqptd AS CHAR 
    FIELD dsmodcrt AS CHAR 
    FIELD cddebtcc AS CHAR 
    FIELD dsdebtcc AS CHAR 
    FIELD indmldir AS CHAR 
    FIELD cdenvcrt AS CHAR 
    FIELD dtvencrt AS CHAR 
    FIELD nmestcrt AS CHAR 
    FIELD nmprimtl AS CHAR 
    FIELD nrcpfcgc AS CHAR 
    FIELD vllimttl AS CHAR 
    FIELD vllimpar AS CHAR 
    FIELD vllimptd AS CHAR 
    FIELD cdestfnc AS CHAR 
    FIELD cdrescrt AS CHAR 
    FIELD dsrescrt AS CHAR 
    FIELD cdresptd AS CHAR 
    FIELD dsresptd AS CHAR 
    FIELD indprote AS CHAR 
    FIELD indatvpt AS CHAR 
    FIELD nrpltptd AS CHAR 
    FIELD idseqend AS CHAR 
    FIELD dslograd AS CHAR 
    FIELD nmbairro AS CHAR 
    FIELD nmmunici AS CHAR 
    FIELD cdufende AS CHAR 
    FIELD nrcepend AS CHAR.

DEF TEMP-TABLE w-resctitg NO-UNDO
    FIELD nrconven AS CHAR
    FIELD cdageitg AS CHAR
    FIELD nrdctitg AS CHAR
    FIELD cdagecon AS CHAR
    FIELD nrdctcon AS CHAR
    FIELD inpessoa AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD dtnascop AS CHAR
    FIELD cdptaten AS CHAR
    FIELD cdptagen AS CHAR
    FIELD nmptaten AS CHAR
    FIELD dsdendat AS CHAR
    FIELD dslograd AS CHAR
    FIELD cdestcon AS CHAR
    FIELD dsestcon AS CHAR
    FIELD cdrescct AS CHAR
    FIELD dsrescct AS CHAR
    FIELD cdestitg AS CHAR
    FIELD dsestitg AS CHAR
    FIELD indusoct AS CHAR
    FIELD indusotl AS CHAR
    FIELD vllimite AS CHAR
    FIELD dtinilim AS CHAR
    FIELD dtfimlim AS CHAR
    FIELD indcccon AS CHAR
    FIELD dsccconj AS CHAR
    FIELD dtabercc AS CHAR
    FIELD idseqend AS CHAR
    FIELD nmdlogra AS CHAR
    FIELD nmbairro AS CHAR
    FIELD nmmunici AS CHAR
    FIELD cdufende AS CHAR
    FIELD nrcepend AS CHAR
    FIELD idseqttl AS CHAR
    FIELD ordimpre AS CHAR
    FIELD nrteltal AS CHAR
    FIELD nmttltal AS CHAR
    FIELD dstxtdoc AS CHAR
    FIELD dtnasttl AS CHAR
    FIELD dtabrtcc AS CHAR
    INDEX nrcpfcgc idseqttl.

DEF STREAM str_1. /* Recebimentos dos arquivos */
    
DEF VAR aux_cdagedbb     AS INTE                             NO-UNDO.
DEF VAR aux_nrdctitg     AS CHAR                             NO-UNDO.
DEF VAR aux_linha_envio  AS CHAR                             NO-UNDO.
DEF VAR aux_nrcctitg     AS INTE                             NO-UNDO.
DEF VAR aux_contador     AS INTE                             NO-UNDO.
DEF VAR aux_nmarquiv     AS CHAR                             NO-UNDO.
DEF VAR aux_setlinha     AS CHAR                             NO-UNDO.
DEF VAR aux_nmarqmen     AS CHAR                             NO-UNDO.
DEF VAR aux_nmendter     AS CHAR                             NO-UNDO.

