/*..............................................................................

   Programa: sistema/internet/includes/var_ibank.i
   Sistema : Internet - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Junior
   Data    : Julho/2004.                       Ultima atualizacao: 21/08/2017

   Dados referentes ao programa:

   Frequencia: Diario (por solicitacao).
   Objetivo  : Temp-Tables utilizadas nas operacoes do InternetBank.w.
   
   Alteracoes: 30/12/2004 - Inclusao de novas variaveis para o tratamento das 
                            novas includes que tratam da aliquota do IR
                            (Junior).
               
               21/01/2005 - Inclusao de variaveis para o calculo do IR sobre
                            aplicacoes (Junior).
                            
               27/07/2005 - Incluir variaveis para debitos futuros ref. conta
                            negativa e multas (Junior).

               30/03/2006 - Incluir variaveis do bloqueto de cobranca (Ze).

               20/09/2006 - Inclusao de variaveis para gerar boleto (David).
               
               03/10/2006 - Inclusao de variaveis para rotina de carregamento
                            de titulares (David).

               07/12/2006 - Inclusao de variavel para rotina de sacados (David).

               11/03/2007 - Inclusao da variavel txt_flgctitg - para tratar
                            situacao da Conta/ITG (David).
                            
               13/03/2007 - Incluir variaveis para rotinas de consulta de 
                            boletos e cheques pendentes (David).

               20/04/2007 - Incluir variavel para rotinas de boletos (David).

               13/06/2007 - Variaveis para as rotinas de pagamentos (David).
               
               08/08/2007 - Inclusao xml_operacao10 p/ investimento(Guilherme).
               
               10/08/2007 - Incluida TEMP-TABLE xml_operacao30 (Diego).

               06/11/2007 - Incluir temp-tables para operacoes do modulo de 
                            plano de capital (David).

               07/02/2008 - Utilizar include somente para temp-tables das 
                            operacoes - "xml_operacaoX" (David).

               19/03/2008 - Incluir temp-table da operacao 36 e 37 (David).

               09/04/2008 - Adaptacao para agendamento de pagamentos (David).

               02/05/2008 - Incluir campo dtvctopp (vencimento) na temp-table
                            xml_operacao6 (David).
                          - Incluir nrtelfax e hrcancel para instrucao de 
                            estorno na xml_operacao28a (Guilherme).

               31/07/2008 - Novo campo (nrseqaut) para operacao 25 (David).
               
               29/09/2008 - Novos campos para desconto de titulos (David).
               
               12/11/2008 - Adaptacao para mudanca no acesso a conta para 
                            pessoas juridicas (David).

               19/02/2009 - Melhorias no servico de cobranca (David).
               
               20/04/2009 - Retirar temp-tables da rotina 7 (David).

               06/08/2009 - Alteracoes do Projeto de Transferencia para 
                            Credito de Salario (David).
                            
               06/10/2009 - Melhorias na operacao 12 do InternetBank (David).
               
               05/03/2010 - Retirar TEMP-TABLEs xml_operacao17 e 
                            xml_operacao6 (David).
                            
               22/04/2010 - Retirar TEMP-TABLE xml_operacao1 (David).       
               
               14/09/2010 - Retirar TEMP-TABLE xml_operacao29 (David).      
               
               14/09/2010 - Retirar TEMP-TABLE xml_operacao15 e 16 (David).
               
               04/10/2011 - Adicionado campos nmprepos, nrcpfpre, nmoperad e
                            nrcpfope em xml_operacao25 e xml_operacao38 (Jorge).
                            
               09/01/2012 - Adicionado campo idtitdda em xml_operacao38 (Jorge).
               
               12/03/2012 - Adicionado os campos cdbcoctl e cdagectl na
                            temp-table xml_operacao25. (Fabricio)

               03/07/2012 - Incluir tipo do emprestimo na operacao 13
                            (Gabriel)             

               05/04/2013 - Inclusão de campos da xml_operacao30 para
                            horário limite para Pgto./Canc. de Conv. SICREDI (Lucas).

               18/04/2013 - Transferencia intercooperativa (Gabriel).    

              19/07/2013 - 2a fase do Projeto do Credito (Gabriel).

              21/10/2013 - Incluidos campos dtinipla e dtfuturo (Fabricio).

              25/02/2014 - Adicionado na temp-table xml_operacao31 os campos
                           cdtipcor e vlcorfix, e removido dessa mesma
                           temp-table o campo flgplano.
                           (Fabricio)

              02/07/2014 - Ajuste referente ao projeto de captacao:
                           - Criado a temp-table xml_operacao88
                           (Adriano).

              10/09/2014 - Incluir o campo flgpreap na temp-table 
                           xml_operacao13. (James)
                           
              24/11/2014 - Incluido o campo cdorigem na temp-table 
                           xml_operacao13. (James)
                           
              24/11/2014 - Incluido campo inpessoa na Operação 11. (Dionathan)
              
              21/08/2015 - Incluido campo idtipfol na Operação 24 e criação 
                           da xml_operacao146 . (Vanessa)
                           
              29/10/2015 - Incluso novo campo cdorigem na temp-table 
                           xml_operacao14b (Daniel)   
                           
              04/11/2015 - Criação da temp-table xml_operacao141 e xml_operacao143 (Vanessa)

			  04/05/2016 - Incluido o campo cdageban na tabela xml_operacao38
						   (Adriano - M117).
                            
              19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS 
                           pelo InternetBanking (Projeto 338 - Lucas Lunelli)
                           
              22/02/2017 - Alteraçoes para compor comprovantes DARF/DAS 
                           Modelo Sicredi (Lucas Lunelli)
                           
              06/03/2017 - Adicionados campos nrddd, nrcelular e nmoperadora em 
                           xml_operacao38 (Projeto 321 - Lombardi).
                           
			  12/05/2017 - Segunda fase da melhoria 342 (Kelvin).

              21/08/2017 - Inclusao dos campos qtdiacal e vlrdtaxa na
                           xml_operacao14b. (Jaison/James - PRJ298)

..............................................................................*/

DEF TEMP-TABLE xml_operacao                                             NO-UNDO
    FIELD dslinxml AS CHAR.
    
DEF TEMP-TABLE xml_operacao8                                            NO-UNDO
    FIELD dscabini AS CHAR
    FIELD nmmesmd1 AS CHAR
    FIELD vlsldmd1 AS CHAR
    FIELD nmmesmd2 AS CHAR
    FIELD vlsldmd2 AS CHAR
    FIELD nmmesmd3 AS CHAR
    FIELD vlsldmd3 AS CHAR
    FIELD nmmesmd4 AS CHAR
    FIELD vlsldmd4 AS CHAR
    FIELD nmmesmd5 AS CHAR
    FIELD vlsldmd5 AS CHAR
    FIELD nmmesmd6 AS CHAR
    FIELD vlsldmd6 AS CHAR
    FIELD dscabfim AS CHAR.
 
DEF TEMP-TABLE xml_operacao9                                            NO-UNDO
    FIELD dscabini AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD dshistor AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD indebcre AS CHAR
    FIELD vllanmto AS CHAR
    FIELD dscabfim AS CHAR.
 
DEF TEMP-TABLE xml_operacao10                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD dshistor AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD indebcre AS CHAR
    FIELD vllanmto AS CHAR
    FIELD vlsldtot AS CHAR
    FIELD dscabfim AS CHAR.

DEF TEMP-TABLE xml_operacao11                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD nmtitula AS CHAR
    FIELD incadsen AS CHAR
    FIELD idseqttl AS CHAR
    FIELD inbloque AS CHAR
    FIELD nrcpfope AS CHAR
    FIELD dscabfim AS CHAR
    FIELD inpessoa AS CHAR.

DEF TEMP-TABLE xml_operacao13                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nrctremp AS CHAR
    FIELD vlemprst AS CHAR
    FIELD qtpreemp AS CHAR
    FIELD qtprecal AS CHAR
    FIELD vlpreemp AS CHAR
    FIELD vlsdeved AS CHAR
    FIELD dslcremp AS CHAR
    FIELD dsfinemp AS CHAR
    FIELD dscabfim AS CHAR
    FIELD tpemprst AS CHAR
    FIELD flgpreap AS CHAR
    FIELD cdorigem AS CHAR
    FIELD dtapgoib AS CHAR
	FIELD nrdrecid AS CHAR.
 
DEF TEMP-TABLE xml_operacao14a                                          NO-UNDO
    FIELD dscabini AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD nrctremp AS CHAR
    FIELD vlemprst AS CHAR
    FIELD qtpreemp AS CHAR
    FIELD qtprecal AS CHAR
    FIELD vlpreemp AS CHAR
    FIELD vlsdeved AS CHAR
    FIELD dslcremp AS CHAR
    FIELD dsfinemp AS CHAR
    FIELD dscabfim AS CHAR.
                             
DEF TEMP-TABLE xml_operacao14b                                          NO-UNDO
    FIELD dscabini AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD dshistor AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD vllanmto AS CHAR
    FIELD indebcre AS CHAR
    FIELD vldsaldo AS CHAR
    FIELD nrparepr AS CHAR
    FIELD dscabfim AS CHAR
    FIELD vldebito AS CHAR
    FIELD vlcredit AS CHAR
    FIELD cdorigem AS CHAR
    FIELD qtdiacal AS CHAR
    FIELD vlrdtaxa AS CHAR.
  
DEF TEMP-TABLE xml_operacao21                                           NO-UNDO
    FIELD dscabini AS CHAR 
    FIELD dtemschq AS CHAR 
    FIELD dtretchq AS CHAR 
    FIELD nrdctabb AS CHAR
    FIELD nrcheque AS CHAR 
    FIELD chqtaltb AS CHAR 
    FIELD dsobserv AS CHAR 
    FIELD dscabfim AS CHAR.
    
DEF TEMP-TABLE xml_operacao24                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD dtrefere AS CHAR
    FIELD dsdpagto AS CHAR
    FIELD dsholeri AS CHAR     
    FIELD dscabfim AS CHAR
    FIELD idtipfol AS CHAR
    FIELD nrdrowid AS CHAR.

DEF TEMP-TABLE xml_operacao25                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD cdtippro AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD dttransa AS CHAR
    FIELD hrautent AS CHAR
    FIELD vldocmto AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD nrseqaut AS CHAR
    FIELD dsinfor1 AS CHAR
    FIELD dsinfor2 AS CHAR
    FIELD dsinfor3 AS CHAR
    FIELD dsprotoc AS CHAR
    FIELD dscedent AS CHAR
    FIELD cdagenda AS CHAR
    FIELD qttotreg AS CHAR
    FIELD nmprepos AS CHAR
    FIELD nrcpfpre AS CHAR
    FIELD nmoperad AS CHAR
    FIELD nrcpfope AS CHAR
    FIELD cdbcoctl AS CHAR
    FIELD cdagectl AS CHAR
    FIELD cdagesic AS CHAR
    FIELD dscabfim AS CHAR.

DEF TEMP-TABLE xml_operacao26                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD lindigi1 AS CHAR
    FIELD lindigi2 AS CHAR
    FIELD lindigi3 AS CHAR
    FIELD lindigi4 AS CHAR
    FIELD lindigi5 AS CHAR
    FIELD cdbarras AS CHAR
    FIELD nmconban AS CHAR
    FIELD dtmvtopg AS CHAR
    FIELD vlrdocum AS CHAR
    FIELD cdseqfat AS CHAR
    FIELD nrdigfat AS CHAR
    FIELD nrcnvcob AS CHAR
    FIELD nrboleto AS CHAR
    FIELD nrctacob AS CHAR
    FIELD insittit AS CHAR
    FIELD intitcop AS CHAR
    FIELD nrdctabb AS CHAR
    FIELD dttransa AS CHAR
    FIELD dscabfim AS CHAR.
    
DEF TEMP-TABLE xml_operacao28a                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD hrinipag AS CHAR
    FIELD hrfimpag AS CHAR
    FIELD idesthor AS CHAR
    FIELD flgconve AS CHAR
    FIELD flgtitul AS CHAR
    FIELD nrtelfax AS CHAR
    FIELD hrcancel AS CHAR
    FIELD dscabfim AS CHAR.
    
DEF TEMP-TABLE xml_operacao28b                                          NO-UNDO
    FIELD dscabini AS CHAR
    FIELD nmextcon AS CHAR
    FIELD dscabfim AS CHAR.
 
DEF TEMP-TABLE xml_operacao30                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD nmextcon AS CHAR
    FIELD hhoraini AS CHAR
    FIELD hhorafim AS CHAR
    FIELD hhoracan AS CHAR
    FIELD dscabfim AS CHAR.    

DEF TEMP-TABLE xml_operacao31                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD hrinipla AS CHAR
    FIELD hrfimpla AS CHAR
    FIELD despagto AS CHAR
    FIELD vlprepla AS CHAR
    FIELD qtpremax AS CHAR
    FIELD dtdpagto AS CHAR
    FIELD flcancel AS CHAR
    FIELD dtlimini AS CHAR
    FIELD dtinipla AS CHAR
    FIELD dtfuturo AS CHAR
    FIELD cdtipcor AS CHAR
    FIELD vlcorfix AS CHAR
    FIELD dscabfim AS CHAR.
           
DEF TEMP-TABLE xml_operacao34                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD cdtippto AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD dttransa AS CHAR
    FIELD hrautent AS CHAR
    FIELD vldocmto AS CHAR
    FIELD nrdocmto AS CHAR    
    FIELD dsinfor1 AS CHAR
    FIELD dsinfor2 AS CHAR
    FIELD dsinfor3 AS CHAR
    FIELD dsprotoc AS CHAR
    FIELD dscabfim AS CHAR.

DEF TEMP-TABLE xml_operacao36                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD cdseqlin AS CHAR
    FIELD dsdlinha AS CHAR
    FIELD dscabfim AS CHAR.

DEF TEMP-TABLE xml_operacao37                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD nrcnvcob AS CHAR
    FIELD dscabfim AS CHAR.

DEF TEMP-TABLE xml_operacao38                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD dtmvtage AS CHAR
    FIELD dtmvtopg AS CHAR
    FIELD vllanaut AS CHAR
    FIELD dttransa AS CHAR
    FIELD hrtransa AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD dssitlau AS CHAR
    FIELD dslindig AS CHAR
    FIELD dscedent AS CHAR
    FIELD dtvencto AS CHAR
    FIELD nrctadst AS CHAR
    FIELD cdtiptra AS CHAR
    FIELD dstiptra AS CHAR
    FIELD incancel AS CHAR
    FIELD qttotage AS CHAR    
    FIELD nmprepos AS CHAR
    FIELD nrcpfpre AS CHAR
    FIELD nmoperad AS CHAR
    FIELD nrcpfope AS CHAR
    FIELD dscabfim AS CHAR
    FIELD idtitdda AS CHAR
    FIELD dsageban AS CHAR
    FIELD cdageban AS CHAR
    FIELD tpcaptur AS CHAR
    FIELD dstipcat AS CHAR
    FIELD dsidpgto AS CHAR
    FIELD dsnomfon AS CHAR
    FIELD vlprinci AS CHAR
    FIELD vlrmulta AS CHAR
    FIELD vlrjuros AS CHAR
    FIELD vlrtotal AS CHAR
    FIELD vlrrecbr AS CHAR
    FIELD vlrperce AS CHAR
    FIELD cdreceit AS CHAR
    FIELD nrrefere AS CHAR
    FIELD dtagenda AS CHAR
    FIELD dtperiod AS CHAR
    FIELD nrcpfcgc AS CHAR
    FIELD dtvendrf AS CHAR
    FIELD nrddd    AS CHAR
    FIELD nrcelular AS CHAR
    FIELD nmoperadora AS CHAR.

DEF TEMP-TABLE xml_operacao88                                           NO-UNDO
    FIELD dscabini AS CHAR
    FIELD cdtippro AS CHAR
    FIELD dtmvtolt AS CHAR
    FIELD dttransa AS CHAR
    FIELD hrtransa AS CHAR
    FIELD hrautent AS CHAR
    FIELD vldocmto AS CHAR
    FIELD nrdocmto AS CHAR
    FIELD nrseqaut AS CHAR
    FIELD dsinfor1 AS CHAR
    FIELD dsinfor2 AS CHAR
    FIELD dsinfor3 AS CHAR
    FIELD dsprotoc AS CHAR
    FIELD dscedent AS CHAR
    FIELD flgagend AS CHAR
    FIELD nmprepos AS CHAR
    FIELD nrcpfpre AS CHAR
    FIELD nmoperad AS CHAR
    FIELD nrcpfope AS CHAR
    FIELD cdbcoctl AS CHAR
    FIELD cdagectl AS CHAR
    FIELD cdagesic AS CHAR
    FIELD dscabfim AS CHAR.


DEF TEMP-TABLE xml_operacao146                                           NO-UNDO
    FIELD nrseqvld AS CHAR
    FIELD dsdconta AS CHAR
    FIELD dscpfcgc AS CHAR
    FIELD dsorigem AS CHAR
    FIELD dsdescri AS CHAR
    FIELD iddstipo AS CHAR
    FIELD vlrpagto AS CHAR
    FIELD dscritic AS CHAR
    FIELD nrseqpag AS CHAR.

DEF TEMP-TABLE xml_operacao143                                           NO-UNDO
    FIELD nrdconta AS CHAR
    FIELD nrcpfemp AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD dsdcargo AS CHAR
    FIELD dtadmiss AS CHAR
    FIELD dstelefo AS CHAR
    FIELD dsdemail AS CHAR
    FIELD nrregger AS CHAR
    FIELD nrodopis AS CHAR
    FIELD nrdactps AS CHAR
    FIELD cdempres AS CHAR
    FIELD idtpcont AS CHAR
    FIELD vlultsal AS CHAR.

DEF TEMP-TABLE xml_operacao141                                           NO-UNDO
    FIELD cdcooper AS CHAR
    FIELD cdempres AS CHAR
    FIELD nrdconta AS CHAR
    FIELD nrcpfemp AS CHAR
    FIELD cdorigem AS CHAR
    FIELD vllancto AS CHAR
    FIELD dsrowlfp AS CHAR
    FIELD nmprimtl AS CHAR
    FIELD idtpcont AS CHAR.

DEF TEMP-TABLE tt-arq-folha												 NO-UNDO
	FIELD cdseqlin AS INT
	FIELD dsdlinha AS CHAR.	
/*............................................................................*/
