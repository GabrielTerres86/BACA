/*.............................................................................

   Programa: b1wgen0010tt.i                  
   Autor   : David
   Data    : Marco/2008                        Ultima atualizacao: 07/12/2017
     
   Dados referentes ao programa:

   Objetivo  : Arquivo com variaveis utlizadas na BO b1wgen0010.p

   Alteracoes: 14/05/2008 - Alterar nrdoccop para dsdoccop (David).
   
               05/02/2009 - Incluir campo tt-consulta-blt.dssituac para
                            exibir no Ayllos (Ze).
                          - Melhorias no servico de cobranca (David).

               28/05/2009 - Incluir campo tt-consulta-blt.cdcartei (David).
               
               01/06/2009 - Incluido tabela tt-rejeita(Sidnei) 
               
               10/09/2009 - Alteracoes para procedimentos de importacao de
                            boletos:
                               - Inclusao de campo cdagenci na temp-table
                                 tt-consulta-blt;
                               - Inclusao das temp-tables cratarq, cratcob,
                                 cratsab, cratass, tt-erros-arq,
                                 tt-boletos-imp e tt-boletos-rej
                                
               18/09/2009 - Inclusao de campo nmquoter na temp-table cratarq
                            (GATI - Eder).
                            
               09/10/2009 - Inclusao e alteracao da temp-table crawarq;
                            Inclusao da temp-table tt-regimp
                            (GATI - Eder)
                            
               14/03/2011 - Substituir dsdemail da ass para a crapcem (Gabriel)

               22/03/2011 - Inclusao do FlgRegis, NrNosNum, DsStatus, FlgAceit
                            e QtDiaPrt na tt-consulta-blt (Guilherme/Supero)
                            
               27/05/2011 - Adicionado campos nrinsava e cdtpinav para a 
                            tt-consulta-blt (Jorge).
                            
               13/07/2011 - Incluido o campo dtocorre na tt-consulta-blt
                            (Adriano).             
                           
               18/07/2011 - Incluido o campo dtdbaixa na tt-consulta-blt
                            (Rafael).
                            
               20/07/2011 - Incluido o campo dsmotivo na tt-consulta-blt(Jorge)
               
               22/07/2011 - Incluido o campo vloutcre na tt-consulta-blt
                            (Adriano).
                            
               25/08/2011 - Criado tt-convenios-cobrem (Jorge).
               
               01/09/2011 - Incluido tt crawrej (Andre R./Supero).
               
               06/09/2011 - Adicionado campo nrlinseq em tt-rejeita(Jorge).
               
               21/09/2011 - Adicionado campo vldocmto, vlmormul e dtvctori em 
                            tt-consulta-blt (Jorge).
                            
               25/10/2011 - Adicionado os campos dscjuros, dscmulta, dscdscto
                            na temp-table tt-consulta-blt. (Fabricio)
                            
               08/03/2013 - Adicionado campo cdbandoc e dtcredit 
                            em crawarq. (Jorge)
                            
               28/03/2013 - Incluido a tabela tt-lat-consolidada (Daniel). 
               
               18/12/2013 - Alterado format do campo nrdocmto. (Rafael).
               
               29/08/2014 - Float: Adição do campo dtcredit na temp-table
                            tt-consulta-blt. (Vanessa).
               
               14/01/2015 - Acrescentado campos na BO tt-consulta-blt
                            (Odirlei-AMcom).

               27/02/2015 - Adicionado campos na tt-consulta-blt.
                            (Projeto Boleto por email - Douglas).
                            
               16/04/2015 - Adicionado campos na tt-consulta-blt.
                            (Projeto Cooperativa Emite e Expede - Reinert)

               11/06/2015 - Adicionar campo flgcarne na tt-consulta-blt para 
                            identificar se o boleto pertence a um carne.
                            (Projeto Boleto formato Carne - Douglas)
                            
               05/01/2016 - Incluso os campos inserasa ,dsserasa, qtdianeg na
                            tt-consulta-blt (Projeto Negativacao Serasa - Daniel)
  
               29/08/2016 - Adicionado novos campos referente a M271. (Kelvin).

               11/10/2016 - Inclusao dos campos de aviso por SMS. 
                            PRJ319 - SMS Cobrança.  (Odirlei-AMcom)

               22/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                            (Jaison/Cechet)

               02/01/2017 - Melhorias referentes a performance no IB na parte
                            de cobrança, adicionado campo flprotes na temptable
                            tt-consulta-blt (Tiago/Ademir SD573538).  

               07/12/2017 - Adicionado os campos para a data de vencimento e 
                            identificar se o boleto está vencido 
                            (Douglas - Chamado 805008)
.............................................................................*/

DEF TEMP-TABLE tt-consulta-blt
    FIELD cdcooper LIKE crapcob.cdcooper
    FIELD nrdconta LIKE crapcob.nrdconta
    FIELD idseqttl LIKE crapcob.idseqttl
    FIELD nmprimtl LIKE crapass.nmprimtl
    FIELD incobran AS CHAR FORMAT "x"
    FIELD nossonro AS CHAR FORMAT "x(17)"    
    FIELD nmdsacad LIKE crapcob.nmdsacad
    FIELD nrinssac LIKE crapcob.nrinssac
    FIELD cdtpinsc LIKE crapcob.cdtpinsc
    FIELD dsendsac LIKE crapcob.dsendsac
    FIELD complend LIKE crapsab.complend
    FIELD nmbaisac LIKE crapcob.nmbaisac
    FIELD nmcidsac LIKE crapcob.nmcidsac
    FIELD cdufsaca LIKE crapcob.cdufsaca
    FIELD nrcepsac LIKE crapcob.nrcepsac
    FIELD cdbandoc LIKE crapcob.cdbandoc
    FIELD nmdavali LIKE crapcob.nmdavali
    FIELD nrinsava LIKE crapcob.nrinsava
    FIELD cdtpinav LIKE crapcob.cdtpinav
    FIELD nrcnvcob LIKE crapcob.nrcnvcob
    FIELD nrcnvceb LIKE crapceb.nrcnvceb
    FIELD nrdctabb LIKE crapcob.nrdctabb
    FIELD nrcpfcgc LIKE crapass.nrcpfcgc
    FIELD inpessoa LIKE crapass.inpessoa
    FIELD nrdocmto AS DECI FORMAT "999999999" COLUMN-LABEL "Nro Docto"
    FIELD dtmvtolt LIKE crapcob.dtmvtolt
    FIELD dsdinstr LIKE crapcob.dsdinstr
    FIELD dsinform LIKE crapcob.dsinform
    FIELD dsdoccop LIKE crapcob.dsdoccop
    FIELD dtvencto LIKE crapcob.dtvencto
    FIELD dtretcob LIKE crapcob.dtretcob
    FIELD dtdpagto LIKE crapcob.dtdpagto
    FIELD vltitulo LIKE crapcob.vltitulo
    FIELD vldpagto LIKE crapcob.vldpagto
    FIELD vldescto LIKE crapcob.vldescto
    FIELD vlabatim LIKE crapcob.vlabatim
    FIELD vltarifa LIKE crapcob.vltarifa
    FIELD vlrmulta AS DECI
    FIELD vlrjuros AS DECI
    FIELD vloutdes AS DECI
    FIELD vloutcre AS DECI
    FIELD cdmensag LIKE crapcob.cdmensag
    FIELD dsdpagto AS CHAR FORMAT "x(11)"
    FIELD dsorgarq LIKE crapcco.dsorgarq
    FIELD nrregist AS INTE
    FIELD idbaiexc AS INTE
    FIELD cdsituac AS CHAR   /* Utilizado para a Internet */
    FIELD dssituac AS CHAR   /* Utilizado para o Ayllos   */
    FIELD cddespec LIKE crapcob.cddespec
    FIELD dsdespec AS CHAR
    FIELD dtdocmto LIKE crapcob.dtdocmto
    FIELD cdbanpag AS CHAR FORMAT "x(5)"
    FIELD cdagepag AS CHAR FORMAT "x(4)"
    FIELD flgdesco AS CHAR
    FIELD dtelimin LIKE crapcob.dtelimin
    FIELD cdcartei LIKE crapcob.cdcartei
    FIELD nrvarcar LIKE crapcco.nrvarcar
    FIELD cdagenci LIKE crapass.cdagenci
    FIELD flgregis AS CHAR
    FIELD nrnosnum LIKE crapcob.nrnosnum
    FIELD dsstaabr AS CHAR
    FIELD dsstacom AS CHAR
    FIELD flgaceit AS CHAR
    FIELD dtsitcrt AS DATE
    FIELD agencidv AS CHAR
    FIELD tpjurmor AS INT
    FIELD tpdmulta AS INT
    FIELD flgdprot LIKE crapcob.flgdprot
    FIELD qtdiaprt LIKE crapcob.qtdiaprt
    FIELD indiaprt LIKE crapcob.indiaprt
    FIELD insitpro LIKE crapcob.insitpro
    FIELD flgcbdda AS CHAR
    FIELD cdocorre AS INT
    FIELD dsocorre AS CHAR
    FIELD cdmotivo AS CHAR
    FIELD dsmotivo AS CHAR
    FIELD dtocorre AS DATE
    FIELD dtdbaixa AS DATE
    FIELD vldocmto AS DECI
    FIELD vlmormul AS DECI
    FIELD dtvctori AS DATE
    FIELD dscjuros AS CHAR
    FIELD dscmulta AS CHAR
    FIELD dscdscto AS CHAR
    FIELD dsinssac AS CHAR
    FIELD vldesabt AS DECI
    FIELD vljurmul AS DECI
    FIELD dsorigem AS CHAR
    FIELD dtcredit AS DATE
    FIELD nrborder LIKE craptdb.nrborder
    FIELD vllimtit AS DECI
    FIELD vltdscti AS DECI
    FIELD nrctrlim LIKE craptdb.nrctrlim
    FIELD nrctrlim_ativo LIKE craptdb.nrctrlim
    FIELD dsdemail AS CHAR
    FIELD flgemail AS LOGI
    FIELD inemiten LIKE crapcob.inemiten
    FIELD dsemiten AS CHAR
    FIELD dsemitnt AS CHAR
    FIELD flgcarne AS LOGI
    FIELD inserasa AS CHAR
    FIELD dsserasa AS CHAR
    FIELD flserasa AS LOGI
    FIELD qtdianeg AS INTE
   	FIELD dtvencto_atualizado AS DATE
    FIELD vltitulo_atualizado AS DECI
	FIELD vlmormul_atualizado AS DECI
	FIELD flg2viab AS INTE
	FIELD flprotes AS INTE
	FIELD inavisms AS INTE
	FIELD insmsant AS INTE
	FIELD insmsvct AS INTE
	FIELD insmspos AS INTE
    FIELD dsavisms AS CHAR
	FIELD dssmsant AS CHAR
	FIELD dssmsvct AS CHAR
	FIELD dssmspos AS CHAR
    FIELD inenvcip LIKE crapcob.inenvcip
    FIELD inpagdiv LIKE crapcob.inpagdiv
    FIELD vlminimo LIKE crapcob.vlminimo
    FIELD dtmvtatu AS DATE
    FIELD flgvenci AS INTE.

DEF TEMP-TABLE tt-arq-cobranca  
    FIELD cdseqlin AS INTEGER
    FIELD dslinha  AS CHAR
    INDEX tt-arq-cobranca1 AS PRIMARY cdseqlin.
        
DEF TEMP-TABLE tt-convenios-cobranca NO-UNDO
    FIELD nrcnvcob AS INTE.

DEF TEMP-TABLE tt-convenios-cobrem NO-UNDO
    FIELD nrconven LIKE crapcco.nrconven
    FIELD cddbanco LIKE crapcco.cddbanco
    FIELD nrremret LIKE craprtc.nrremret.

DEF TEMP-TABLE tt-totais-cobranca
    FIELD cdcooper LIKE crapcob.cdcooper
    FIELD nrdconta LIKE crapcob.nrdconta
    FIELD dtmvtolt AS DATE                   /* Data do dia */
    FIELD nrcnvcob AS INTE
    FIELD qtvencid AS INTE                   /* Qtd. vencidos */
    FIELD vlvencid AS DECIMAL                /* Vlr. vencidos */
    FIELD qtdatual AS INTE      EXTENT 4     /* Qtd. de Hoje */
    FIELD vldatual AS DECIMAL   EXTENT 4     /* Vlr. de Hoje */
    FIELD qtate10d AS INTE      EXTENT 4     /* Qtd. ate 10dias */
    FIELD vlate10d AS DECIMAL   EXTENT 4     /* Vlr. ate 10dias */
    FIELD qtate30d AS INTE      EXTENT 4     /* Qtd. de 11 a 30dias */
    FIELD vlate30d AS DECIMAL   EXTENT 4     /* Vlr. de 11 a 30dias */
    FIELD qtsup30d AS INTE      EXTENT 4     /* Qtd. superior a 30dias */
    FIELD vlsup30d AS DECIMAL   EXTENT 4.    /* Vlr. superior a 30dias */
    /* 1 aberto(vencidos), 2 liquidados, 3 baixado, 4 descontados */

/* rejeitados na importacao no arquivo de cobranca */
DEF TEMP-TABLE tt-rejeita
    FIELD tpcritic AS INT
    FIELD cdseqcri AS INT  
    FIELD seqdetal AS CHAR 
    FIELD dscritic AS CHAR FORMAT "x(72)"
    FIELD nrlinseq AS CHAR
    INDEX tt-rejeita1 AS PRIMARY  cdseqcri.

/*** Temp-tables para procedimentos de geracao de boletos ***/
DEF TEMP-TABLE cratarq        NO-UNDO
    FIELD flgmarca   AS LOGI
    FIELD cdcooper   AS INTE
    FIELD nmarquiv   AS CHAR              
    FIELD nrsequen   AS INTE
    FIELD nmquoter   AS CHAR
    FIELD nrseqdig   AS INTE
    FIELD vllanmto   AS DECI
    /* Campos utilizados na integracao de boletos */
    FIELD cdagenci   AS INTE /* PAC */
    FIELD cdbccxlt   AS INTE /* Banco/Caixa */
    FIELD nrdolote   AS INTE /* Numero do Lote */
    FIELD tplotmov   AS INTE /* Tipo do Lote */
    FIELD nroconve   AS INTE /* Numero do Convenio */
    FIELD qtregrec   AS INTE /* Qtde de boletos recebidos */
    FIELD qtregicd   AS INTE /* Qtde de boletos integrados COM desconto */
    FIELD qtregisd   AS INTE /* Qtde de boletos integrados SEM desconto */
    FIELD qtregrej   AS INTE /* Qtde de boletos rejeitados */
    FIELD vlregrec   AS DECI /* Vlr dos boletos recebidos */
    FIELD vlregicd   AS DECI /* Vlr dos boletos integrados COM desconto */
    FIELD vlregisd   AS DECI /* Vlr dos boletos integrados SEM desconto */
    FIELD vlregrej   AS DECI /* Vlr dos boletos rejeitados */
    FIELD vltarifa   AS DECI /* Vlr total das tarifas dos boletos */

    FIELD cdhistor   AS INTE /* Historico do lancamento do valor do titulo */
    FIELD cdtarhis   AS INTE /* Historico do lancamento da tarifa do titulo */
    FIELD vlrtarif   AS DECI /* Valor da tarifa por boleto cfme. convenio */
    FIELD qtdmigra   AS INTE /* Qtd de titulos migrados - Alto Vale */
    FIELD vlrmigra   AS DECI /* Vlr dos titulos migrados - Alto Vale */
    INDEX cratarq_1  AS PRIMARY cdcooper nmarquiv nrsequen.

DEF TEMP-TABLE cratcob        NO-UNDO LIKE crapcob.
DEF TEMP-TABLE cratsab        NO-UNDO LIKE crapsab.
DEF TEMP-TABLE cratass        NO-UNDO LIKE crapass.
DEF TEMP-TABLE cratrej        NO-UNDO LIKE craprej
    FIELD nmarquiv AS CHAR.

DEF TEMP-TABLE tt-erros-arq   NO-UNDO
    FIELD nmarquiv AS CHAR
    FIELD nrsequen AS INT
    FIELD dsdoerro AS CHAR
    INDEX ch_seqarq nmarquiv nrsequen.

DEF TEMP-TABLE tt-boletos-imp NO-UNDO
    FIELD nmarquiv AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nrbloque AS DECI
    FIELD nmdsacad AS CHAR
    FIELD vltitulo AS DECI.

DEF TEMP-TABLE tt-boletos-rej NO-UNDO
    FIELD nmarquiv AS CHAR
    FIELD nrdconta AS INTE
    FIELD nmprimtl AS CHAR
    FIELD nrdocmto AS DECI
    FIELD dscritic AS CHAR.
/*** Fim Temp-tables para procedimentos de geracao de boletos ***/

DEF TEMP-TABLE crawarq NO-UNDO
    FIELD tparquiv AS INTEGER
    FIELD nrdconta LIKE crapcob.nrdconta           
    FIELD nrconven LIKE crapcob.nrcnvcob
    FIELD nrdocmto LIKE crapcob.nrdocmto
    FIELD tamannro LIKE crapcco.tamannro
    FIELD nrdctabb LIKE crapcco.nrdctabb 
    FIELD vldpagto LIKE crapcob.vldpagto
    FIELD vlrtarcx LIKE crapcco.vlrtarcx 
    FIELD vlrtarnt LIKE crapcco.vlrtarnt
    FIELD vlrtarcm LIKE crapcco.vlrtarif
    FIELD vltrftaa LIKE crapcco.vltrftaa 
    FIELD indpagto LIKE crapcob.indpagto
    FIELD inarqcbr AS INTEGER
    FIELD flgutceb LIKE crapcco.flgutceb
    FIELD dsorgarq LIKE crapcco.dsorgarq
    FIELD dtdpagto LIKE crapcob.dtdpagto
    FIELD dsdemail LIKE crapcem.dsdemail
    FIELD cdbandoc LIKE crapcob.cdbandoc
    FIELD dtcredit LIKE crapcob.dtdpagto
    INDEX crawarq1 AS PRIMARY tparquiv nrconven nrdconta nrdocmto.

/* rejeitados na integracao */
DEF TEMP-TABLE crawrej
    FIELD cdcooper   AS INT
    FIELD nrdconta   LIKE crapass.nrdconta
    FIELD nrdocmto   LIKE crapcob.nrdocmto
    FIELD dscritic   AS CHAR FORMAT "x(30)"
    INDEX crawrej1   AS PRIMARY cdcooper nrdconta nrdocmto.

DEF TEMP-TABLE tt-crapoco NO-UNDO
    FIELD cdocorre AS INTE
    FIELD dsocorre AS CHAR
    FIELD lsinstru AS CHAR.

DEF TEMP-TABLE tt-crapass NO-UNDO
    FIELD nmprimtl AS CHAR
    FIELD cdagenci AS INTE.

DEF TEMP-TABLE crawaux NO-UNDO
    FIELD cdcooper  AS INTE
    FIELD nmarquiv  AS CHAR              
    FIELD nrsequen  AS INTE
    INDEX crawaux_1 AS PRIMARY cdcooper nmarquiv nrsequen.

DEF TEMP-TABLE w-arquivos NO-UNDO
    FIELD tparquiv AS CHAR  
    FIELD dsarquiv AS CHAR
    FIELD flginteg AS LOGI.

DEF TEMP-TABLE tt-arquivos NO-UNDO LIKE w-arquivos.

DEF TEMP-TABLE tt-logcob NO-UNDO
    FIELD dsdthora AS CHAR
    FIELD dsdeslog AS CHAR
    FIELD dsoperad AS CHAR.



DEF TEMP-TABLE tt-lat-consolidada NO-UNDO
    FIELD cdcooper  AS INTE
    FIELD nrdconta  LIKE crapass.nrdconta
    FIELD nrdocmto  LIKE crapcob.nrdocmto
    FIELD nrcnvcob  LIKE crapcob.nrcnvcob
    FIELD dsincide  AS CHAR
    FIELD cdocorre  LIKE craptar.cdocorre
    FIELD cdmotivo  LIKE craptar.cdmotivo
    FIELD vllanmto  AS DEC
    FIELD dscritic  AS CHAR.
     
/*...........................................................................*/

