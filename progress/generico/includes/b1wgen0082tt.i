/* ...........................................................................
   
   Programa: b1wgen0082tt.i
   Autor   : Gabriel
   Data    : Dezembro/2010                  Ultima atualizacao: 13/12/2016
   
   Dados referentes ao programa:
   
   Objetivo  : Arquivo com as variaveis da BO b1wgen0082.
   
   Alteracoes: 19/05/2011 - Incluir flgregis na tt-cadastro-bloqueto
                            Incluir flgregis na tt-crapcco (Guilherme).
                            
               21/07/2011 - Criar tabela de endereco , cooperativa e campos
                            para as testemunhas (Gabriel)           
                            
               22/08/2011 - Criado campo dsorgban na tt-cadastro-bloqueto
                            (Adriano).                 
                            
               28/04/2015 - Ajustes referente ao projeto DP 219 - Cooperativa
                            emite e expede. (Reinert)
                                                                            
               23/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                            (Jaison/Andrino)

               07/04/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

			   04/08/2016 - Adicionado campo inenvcob na temp-table 
							tt-cadastro-bloqueto (Reinert).

               13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)

............................................................................ */


DEF TEMP-TABLE tt-cadastro-bloqueto
    FIELD nrconven LIKE crapceb.nrconven
    FIELD nrcnvceb LIKE crapceb.nrcnvceb
    FIELD insitceb LIKE crapceb.insitceb 
    FIELD dtcadast LIKE crapceb.dtcadast
    FIELD cdoperad LIKE crapceb.cdoperad
    FIELD dsorgarq LIKE crapcco.dsorgarq
    FIELD flgativo LIKE crapcco.flgativo 
    FIELD dssitceb AS   LOGI FORMAT "ATIVO/INATIVO" INIT YES
    FIELD inarqcbr AS   INTE
    FIELD cddemail AS   INTE
    FIELD dsdemail AS   CHAR
    FIELD flgcruni AS   LOGI FORMAT "SIM/NAO" INIT YES
    FIELD flgcebhm AS   LOGI FORMAT "SIM/NAO" INIT NO
    FIELD vllbolet AS   DECI
    FIELD flgregis AS   LOGICAL FORMAT "SIM/NAO" INIT NO
    FIELD dsorgban AS   CHAR
    FIELD flgregon AS   LOGICAL FORMAT "S/N"
    FIELD flgpgdiv AS   LOGICAL FORMAT "S/N"
    FIELD flcooexp AS   LOGICAL FORMAT "S/N"
    FIELD flceeexp AS   LOGICAL FORMAT "S/N"
    FIELD cddbanco LIKE crapcco.cddbanco
    FIELD flserasa AS   LOGICAL FORMAT "S/N"
    FIELD flsercco AS   INTE
    FIELD qtdfloat LIKE crapceb.qtdfloat
    FIELD flprotes LIKE crapceb.flprotes
	FIELD qtlimaxp LIKE crapceb.qtlimaxp
	FIELD qtlimmip LIKE crapceb.qtlimmip
    FIELD qtdecprz LIKE crapceb.qtdecprz
    FIELD idrecipr LIKE crapceb.idrecipr
    FIELD inenvcob LIKE crapceb.inenvcob.

DEF TEMP-TABLE tt-crapcco 
    FIELD nrconven AS CHAR
    FIELD flgativo AS CHAR
    FIELD dsorgarq AS CHAR
    FIELD flgregis AS CHAR.

DEF TEMP-TABLE tt-titulares 
    FIELD idseqttl LIKE crapttl.idseqttl
    FIELD nmextttl LIKE crapttl.nmextttl
    FIELD vllbolet LIKE crapsnh.vllbolet.

DEF TEMP-TABLE tt-emails-titular NO-UNDO
    FIELD cddemail AS INTE
    FIELD dsdemail AS CHAR.

DEF TEMP-TABLE tt-dados-adesao-net NO-UNDO
    FIELD nrdocnpj AS CHAR FORMAT "x(18)"
    FIELD nmcidade AS CHAR FORMAT "x(20)"
    FIELD nrdconta LIKE crapass.nrdconta
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD nrcpfcgc AS CHAR FORMAT "x(18)"
    FIELD nmdtest1 AS CHAR
    FIELD cpftest1 AS CHAR
    FIELD nmdtest2 AS CHAR
    FIELD cpftest2 AS CHAR
    FIELD dsmvtolt AS CHAR
    FIELD dsmvtope AS CHAR
    FIELD nmoperad AS CHAR
    FIELD cddbanco AS CHAR
    FIELD cdagectl AS CHAR.

DEF TEMP-TABLE tt-crapenc NO-UNDO LIKE crapenc.

DEF TEMP-TABLE tt-crapcop NO-UNDO LIKE crapcop.

/* ..........................................................................*/

