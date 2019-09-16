
/*..............................................................................

   Programa: sistema/internet/procedures/b1wnet0001.p                  
   Autor   : David
   Data    : 14/07/2006                        Ultima atualizacao: 26/08/2019

   Dados referentes ao programa:

   Objetivo  : BO GERACAO DE BOLETOS PARA A INTERNET

   Alteracoes: 18/12/2006 - Alteracao e Inclusao de rotinas (David).

               06/02/2007 - Tratamento para gerar varios boletos em PDF (David).

               20/04/2007 - Incluir campo complemento nos dados do sacado
                            (David).

               23/07/2007 - Tratamento para strings que contenham o caracter
                            especial "&" (David).

               22/11/2007 - Acerto na descricao de criticas (David).

               06/03/2008 - Novas includes e utilizar "TRANSACTION" (David).

               09/05/2008 - Retornar nome do titular para gerar boleto 
                          - Numero do document deve ser informado na tela 
                            (David).

               21/07/2008 - Nao permitir cadastro de sacado com o mesmo CPF do
                            cedente (David).

               11/09/2008 - Incluir parametro com nro do convenio na procedure
                            exclusao-baixa-boleto (David).   

               25/09/2008 - Alterado campo cratcob.cdbccxlt -> cratcob.cdbandoc
                            (Diego).
                          - Nao permitir baixa/exclusao de titulo em desconto
                            (David).

               19/02/2009 - Melhorias no servico de cobranca (David).

               17/04/2009 - Retornar CPF/CNPJ formatado na procedure
                            seleciona-sacados (David).

               28/05/2009 - Carregar numero de variacao de carteira do convenio
                            para os boletos (David).
                          - Melhoria no log de gerenciamento de sacados (David).

               19/06/2009 - Incluido nrctrsac e nrctremp no crapcob(Guilherme).

               15/02/2011 - Critica para verificar a existencia do registro
                            do crapceb (Gabriel).

               15/03/2011 - Inclusao de tratamento para Cobranca Registrada
                           (Guilherme/Supero)
                           
               12/05/2011 - Tratamento para incobran 0,3,4,5 (Guilherme).
               
               19/05/2011 - Alteracoes na rotina de geracao de titulos
                          - Criada procedure p_cria_titulo (Jorge).
               
               27/05/2011 - Adicionado campos nrinsava e cdtpinav para a 
                            tt-consulta-blt (Jorge).
                            
               24/06/2011 - replace de caracter especial em p_grava_boleto
                            tt-consulta-blt (Jorge).
                            
               27/06/2011 - Criado procedure verifica-convenios para ser
                            usada na InternetBank5 (Jorge/Rafael).
                            
               30/06/2011 - Altarada procedure gera-dados, alterado condicao 
                            de run seleciona-sacado. (Jorge).
                         
               14/07/2011 - Adicionado verificação de data de vencimento nao 
                            pode ser <= 7 dias (cob. registrada). 
                          - Caso seja cob. registrada, limpa intrucoes.(Jorge)
                          
               25/07/2011 - Incluido mensagem de protesto para boletos
                            085 - cob. registrada. (Jorge/Rafael)
                          - Alterado qtd dias para protesto, de 3 para 5 dias
                            minimo. (jorge)  
                            
               09/08/2011 - Incluido msg de titulo enviado a CIP na 
                            procedure p_cria_titulo. (Rafael)
                          - Alterado rotina de retorno ao cooperado qdo
                            cob registrada e titulo 085. (Rafael)
                            
               13/09/2011 - Criado procedure gerar-2via-boleto (Jorge).
               
               22/12/2011 - Incluido validação de Praça não 
                            executante de protesto (Tiago).  
                            
               29/12/2011 - Criticar dados do endereço do sacado quando 
                            houver erro de cep, uf ou localidade. (Rafael)
                            
               09/01/2012 - Gerar mensagem de log do titulo sempre quando
                            houver alteracao de dados do sacado. (Rafael)
                            
               08/03/2012 - Ajustes na rotina de registro de titulos no DDA
                            em virtude do novo catalogo de mensagens 3.05
                            da CIP. (Rafael)
                            
               06/06/2012 - Criticar vencimento do titulo quando a data for
                            menor que o dia atual. (Rafael)
                            
               13/08/2012 - Ajuste na tt-consulta-blt ref aos titulos da cob.
                            registrada descontados. (Rafael)
                            
               18/02/2013 - Ajuste na rotina de geracao de boletos - levar
                            em consideracao a sit. do convenio do cooperado
                            crapceb.insitceb (1=ATIVO, 2=INATIVO). (Rafael)

               13/03/2013 - Ajuste na geracao de boletos quando cooperado
                            possui apenas 1 convenio registrado banco do 
                            brasil. (Rafael)
                            
               01/04/2013 - Adicionado verificacao de valor do boleto acima 
                            de 250 mil para VR boletos (Jorge)
                            
               10/04/2013 - Quando cobr.registrada, banco 001 emite/expede, 
                            assegurar que cobranca nao será DDA
                            (crapcob.flgcbdda = FALSE). (Rafael)
                            
               18/04/2013 - Retirado controle de valor maximo de emissao de
                            boletos - Projeto Melhorias da Cobranca. (Rafael)
                          - Gerar instrução de alteração de dados do sacado
                            pelo InternetBanking. (Rafael)
                            
               11/07/2013 - Adicionado parametro em par_dsdintr, passando como
                            primeira letra sendo o tipo de intrucao = 1 ou 
                            informacao = 2 em proc. grava-instrucoes. (Jorge)
                            
               25/07/2013 - Incluido intipemi na procedure verifica-convenios
                            ref. ao tipo de emissao de boleto (Cooperado emite 
                            e expede ou Banco emite e expede) (Rafael/Jorge).
                            
               21/08/2013 - Incluso tratamento na procedure gravar-boleto para
                            utilizar rotina da b1wgen0153 para buscar tarifa
                            (Daniel).
                            
               27/08/2013 - Incluso parametro tt-lat-consolidado na procedure
                            inst-alt-outros-dados. Incluso chamada para o procedure
                            efetua-lancamento-tarifas-lat da b1wgen0090 (Daniel). 
                
               10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).   
                            
                            
               21/10/2013 - Incluso novo parametro na procedure inst-alt-outros-dados
                            e prep-retorno-cooperado (Daniel).
                            
               31/10/2013 - Utilizar crapdat.dtmvtolt na data de emissao dos
                            titulos gerados devido a rejeicao da CIP dos 
                            titulos emitidos durante a madrugada (Rafael).
                            
               15/11/2013 - Retirado rotina de registro de titulos no DDA de
                            forma ONLINE. O processo será realizado pelo fonte
                            crps618.p (Rafael).             
                            
               03/01/2014 - Melhoria no processo de leitura tabela crapcob (Daniel). 
               
               03/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).
               
               11/02/2014 - Na procedure gravar-boleto buscar informacoes da
                            tarifa na b1wgen0153 apenas quando tipo pessoa
                            for <> 3 (Tiago).
                            
               16/04/2014 - #134238 - Correção de verificação de tipo de documento 
                            e formatação; na lista de sacadaos (CPF/CNPJ) (Carlos)
                            
               09/05/2014 - Permitir geracao de boletos e acesso aos relatorios 
                            independente se o convenio esta ativo ou nao. (Rafael)
                            
               27/05/2014 - Ajustes de liberação referente ao projeto Novo 
                            Fator de Vencimento (Rafael).
                            
               27/06/2014 - Comparar vencimento com a data de hoje ao gerar
                            boletos BB com registro (gravar-boleto). (Rafael).
                          - Adequar sequence ao gerar boleto. (Rafael).
                          
               15/09/2014 - Alteração da Nomeclatura para PA (Vanessa).  
               
               27/10/2014 - Fazer verificação de CEP na base dos Correios em validações
                           (Lucas Lunelli SD 206001).

               01/12/2014 - Validar o CNPJ apenas quando não estiver alterando um cadastro
                            de sacado para Inativo, conforme SD 182015 ( Renato - Supero )
                
               05/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                           
               21/01/2015 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)          
                            
               22/01/2015 - Ajustar a gravação dos boletos para quando o pagador
                            possuir e-mail cadastrado, ele seja enviado por e-mail
                            Projeto Boleto por E-mail (Douglas)                
                             
               08/04/2015 - Ajustar a gravar-boleto e a p_cria_titulo para validar 
                            o tipo de emissão Boleto/Carnê o novo campo de vencimento 
                            em dias e o cálculo do valor da parcela/desconto/abatimento 
                            quando emitir em formato carnê.
                            (Projeto Boleto Formato Carnê - Douglas)                
               
               27/04/2015 - Adicionado validacoes para data de emissao retroativa
                            maior que 30 dias e para Data de emissao superior 
                            ao limite 13/10/2049. SD 257997 (Kelvin).  
                            
               14/05/2015 - Ajustes nas procedures verifica-convenios, p_cria_titulo e
                            gravar-boleto referente ao Projeto 219 - CCE (Daniel/Rafael/Reinert)                           
                            
               01/06/2015 - Ajuste para alterar a validação na data de emissao
                            retroativa marior que 90 ao invés de 30
                            (Adriano).    
              
               03/08/2015 - Alterado rotina p_cria_titulo, para gerar corretamente o nosso numero
                            para os convenios de 6 digitos SD308717 (Odirlei-AMcom)
                            
               17/11/2015 - Adicionado param de entrada inestcri em chamada de 
                            proc. consulta-bloqueto. (Jorge/Andrino)
                            
               08/01/2016 - Ajustes referente Projeto Negativacao Serasa (Daniel)  
               
               03/02/2016 - Ajuste na rotina gravar-boleto para que quando
                            for escolhido o tipo de pagamento 3 nao seja
                            permitido informar um dia  <= 0 or > 28
                            (Adriano - SD 395110).
               
               15/02/2016 - Inclusao do parametro conta na chamada da
                            carrega_dados_tarifa_cobranca. (Jaison/Marcos)

               16/02/2016 - Alimentacao da aux_flprotes na gera-dados. (Jaison/Marcos)

               01/06/2016 - Ajuste na validacao da crapsnh para nao verificar
                            idseqttl para operadores de contas PJ com assinatura 
                            conjunta. (Jaison/David - SD: 449958)

               13/07/2016 - #480828 Ajuste do procedimento gerencia-sacados para limpar
                            os espacos antes e depois do nome do sacado ao cadastra-lo
                            e demais campos texto (Carlos)

               22/07/2016 - Atribuir informacoes nas variaveis de protesto e numero do convenio
                            somente quando o flag serasa for falso na procedure gera-dados.
                            Chamado 490114 - Heitor (RKAM)

			         15/08/2016 - Removido validacao de convenio na consulta da tela
							              manutencao (gera-dados), conforme solicitado no chamado 
							              497079. (Kelvin)

			         13/10/2016 - Ajuste na aux_flprotes para buscar apenas o convênio
							              do tipo INTERNET crapcco.dsorgarq = 'INTERNET'
							             (Andrey Formigari - Mouts - SD: 533201)
               
			   03/10/2016 - Ajustes referente a melhoria M271. (Kelvin)

               11/10/2016 - Ajustes para permitir Aviso cobrança por SMS.
                            PRJ319 - SMS Cobrança(Odirlei-AMcom)

               09/11/2016 - Ajuste na correcao realizada pelo Andrey no dia 13/10,
                            nao fixara em convenio INTERNET, mas utilizara uma logica
                            semelhante ao que acontece para SERASA, assumindo valor
                            TRUE se algum dos convenios possuir a opcao de protesto
                            habilitada. Heitor (Mouts) - Chamado 554656

               16/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                            (Jaison/Cechet)

		       23/12/2016 - Ajustes referentes a melhoria de performance na cobrança 
			                do IB (Tiago/Ademir SD566906).

               31/01/2017 - Ajuste para carregar o nome do beneficiario na geracao do 
			                boleto (Douglas - Chamado 601478)

               11/10/2016 - Ajustes para permitir Aviso cobrança por SMS.
                            PRJ319 - SMS Cobrança(Odirlei-AMcom)

               02/01/2017 - PRJ340 - Nova Plataforma de Cobranca - Fase II. 
                            (Ricardo Linhares)                                                              

               30/03/2017 - Adicionado o parametro par_idseqttl na chamada da procedure
                            busca-nome-imp-blt (Douglas - Chamado 637660)

               07/07/2017 - Ajuste na leitura da flprotes.
                            PRJ340 - NPC (Odirlei-AMcom)   

               16/06/2018 - Ajuste na procedure grava-boleto para utilizar o convenio
                            por parametro quando o codigo da carteira for 5-Quanta ou 
                            6-Recuperacao de Credito. (PRJ468 - Previdencia - Rafael)   

               16/08/2018 - Retirado mensagem de serviço de protesto pelo BB (Rafael).

               30/08/2018 - Adicionar validacao nos parametros de TIPO de JUROS, TIPO de MULTA,
                           TIPO de EMISSAO e FORMATO do DOCUMENTO (DOuglas - PRJ285 Nova Conta Online)
      
               17/10/2018 - Impedir criacao de boleto com instrucao de protesto automatico para boletos
                            do tipo Duplicata de Servico (PRJ352 - Andre Clemer - Supero )

	           04/04/2019 - Ajuste na rotina cria_tt-consulta-blt para não incluir informação
			                de titulos descontados liquidados (Daniel - Ailos)
      
	           26/08/2019 - Validar CEP do Sacado, permitir ate 8 posicoes (Lucas Ranghetti PRB004018)
			 
	           03/09/2019 - Foi criado uma regra no backend para que caso as mesmas informações de boleto 
							cheguem em um período menor que 1 minuto, será impedido a geração e apresentará 
							erro para o cooperado. (Lucas - Diego Batista - PRB0041939)
.............................................................................*/


{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/b1wgen0087tt.i }
{ sistema/internet/includes/b1wnet0001tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_deserro  AS CHAR                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEF VAR aux_flserasa AS LOG                                            NO-UNDO. 

DEF NEW SHARED VAR glb_nrcalcul AS DECI                                NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal AS LOGI                                NO-UNDO.



/*............................ PROCEDURES EXTERNAS ...........................*/


/******************************************************************************/
/**                     Procedure para gerar 2via de boleto                  **/
/******************************************************************************/
PROCEDURE gerar-2via-boleto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrinssac AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrnosnum AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdoccop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi3 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi4 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_lindigi5 AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-consulta-blt.

    DEF VAR h-b1wgen0010 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_nrcodbar AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdbanco AS INTE                                    NO-UNDO.
    DEF VAR aux_cdfatvnc AS INTE                                    NO-UNDO.
    DEF VAR aux_vlrtitul AS DECI                                    NO-UNDO.
    DEF VAR aux_nrconven AS DECI                                    NO-UNDO.
    DEF VAR aux_nrnosnum AS DECI                                    NO-UNDO.
    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdocmto AS DECI                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-consulta-blt.    
    
    ASSIGN aux_nrcodbar = SUBSTRING(STRING(par_lindigi1,"9999999999"),1,4)   +
                          STRING(par_lindigi4,"9")                           +
                          STRING(par_lindigi5,"99999999999999")              +
                          SUBSTRING(STRING(par_lindigi1,"9999999999"),5,1)   +
                          SUBSTRING(STRING(par_lindigi1,"9999999999"),6,4)   +
                          SUBSTRING(STRING(par_lindigi2,"99999999999"),1,10) +
                          SUBSTRING(STRING(par_lindigi3,"99999999999"),1,10).
    
    ASSIGN aux_nrdbanco = INTE(SUBSTRING(aux_nrcodbar,1,3))            
           aux_cdfatvnc = INTE(SUBSTRING(aux_nrcodbar,5,4))
           aux_vlrtitul = DECI(SUBSTRING(aux_nrcodbar,10,10)) / 100
           aux_nrconven = DECI(SUBSTRING(aux_nrcodbar,20,6))
           aux_nrdconta = INTE(SUBSTRING(aux_nrcodbar,26,8))
           aux_nrdocmto = INTE(SUBSTRING(aux_nrcodbar,34,9)).

    IF par_nrnosnum > 0 THEN
    DO:
        ASSIGN aux_nrdconta = INTE(SUBSTRING(
                              STRING(par_nrnosnum,"99999999999999999"),1,8))
               aux_nrdocmto = INTE(SUBSTRING(
                              STRING(par_nrnosnum,"99999999999999999"),9,9)).

    END.
    
    RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT SET h-b1wgen0010.

    IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
        DO:
            CREATE tt-erro.
            ASSIGN tt-erro.dscritic = "Handle invalido para BO b1wgen0010.".
            RETURN "NOK".
        END.                  

    RUN consulta-boleto-2via IN h-b1wgen0010(INPUT par_cdcooper,
                                             INPUT par_nrcpfcgc,
                                             INPUT par_nrinssac,
                                             INPUT aux_nrdconta,
                                             INPUT aux_nrconven,
                                             INPUT aux_nrdocmto,
                                             INPUT par_dsdoccop,
                                             INPUT 3,   /* internet */
                                             INPUT par_cdoperad,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT TABLE tt-consulta-blt).

    IF  VALID-HANDLE(h-b1wgen0010) THEN
        DELETE PROCEDURE h-b1wgen0010.

    IF  RETURN-VALUE = "NOK" THEN RETURN "NOK".

    RETURN "OK".        

END PROCEDURE.

/******************************************************************************/
/**                     Procedure para consultar boletos                     **/
/******************************************************************************/
PROCEDURE consultar-boleto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indordem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinssac AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsacad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idsituac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inidocto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_fimdocto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_inivecto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimvecto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inipagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimpagto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_iniemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimemiss AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdoccop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgregis AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_inserasa AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-consulta-blt.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0010 AS HANDLE                                  NO-UNDO.
    DEF VAR aux_qtregist AS INTE                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-consulta-blt.    

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Listar boletos bancarios para consulta e " +
                          "re-impressao".

    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        IF crapass.idastcjt = 0 THEN
        DO:
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.cdsitsnh = 1         /*   AND
                       crapsnh.flgbolet = TRUE      */   NO-LOCK NO-ERROR.
        END.
        ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                     crapsnh.nrdconta = par_nrdconta AND
                                     crapsnh.tpdsenha = 1            AND
                                     crapsnh.cdsitsnh = 1      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    END.

    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta sem permissao para emitir/consultar " +
                                  "boleto.\nAssine o termo de adesao na " +
                                  "Cooperativa.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT SET h-b1wgen0010.

    IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0010.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    RUN consulta-bloqueto IN h-b1wgen0010 (INPUT par_cdcooper,
                                           INPUT par_nrdconta,
                                           INPUT par_inidocto,
                                           INPUT par_fimdocto,
                                           INPUT par_nrinssac,
                                           INPUT par_nmdsacad,
                                           INPUT par_idsituac,
                                           INPUT par_nrregist,
                                           INPUT par_nriniseq,
                                           INPUT par_inivecto,
                                           INPUT par_fimvecto,
                                           INPUT par_inipagto,
                                           INPUT par_fimpagto,
                                           INPUT par_iniemiss,
                                           INPUT par_fimemiss,
                                           INPUT par_indordem,  
                                           INPUT 3,      /** Tipo Consulta **/
                                           INPUT par_idorigem,
                                           INPUT 1,
                                           INPUT 999, 
                                           INPUT par_dsdoccop,
                                           INPUT par_flgregis,
                                           INPUT 0, /* par_inestcri */
                                           INPUT par_inserasa,
                                          OUTPUT aux_qtregist,
                                          OUTPUT aux_nmdcampo,
                                          OUTPUT TABLE tt-erro, 
                                          OUTPUT TABLE tt-consulta-blt).

    DELETE PROCEDURE h-b1wgen0010.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        aux_dscritic = tt-erro.dscritic.
                    ELSE
                        aux_dscritic = "Nao foi possivel efetuar a consulta.".

                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                END.

            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).    

    RETURN "OK".        

END PROCEDURE.


/******************************************************************************/
/**                  Procedure para excluir/baixar boletos                   **/
/******************************************************************************/
PROCEDURE exclusao-baixa-boleto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idtransa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Efetuar " +
                         (IF  par_idtransa = 1  THEN
                              "baixa"
                          ELSE
                              "exclusao") +
                          " de boleto de cobranca".
    
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        IF crapass.idastcjt = 0 THEN
        DO:
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.cdsitsnh = 1        /*    AND
                       crapsnh.flgbolet = TRUE     */    NO-LOCK NO-ERROR.
        END.
        ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                     crapsnh.nrdconta = par_nrdconta AND
                                     crapsnh.tpdsenha = 1            AND
                                     crapsnh.cdsitsnh = 1      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    END.
                       
    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta sem permissao para emitir/consultar " +
                                  "boleto.\nAssine o termo de adesao na " +
                                  "Cooperativa.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.

    ASSIGN aux_flgtrans = FALSE.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:


        FIND crapcco WHERE crapcco.cdcooper = par_cdcooper AND
                           crapcco.nrconven = par_nrcnvcob
                           NO-LOCK NO-ERROR.

        IF NOT AVAIL(crapcco) THEN DO:
            aux_dscritic = "Convenio nao cadastrado".
        END.

        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

    
        DO aux_contador = 1 TO 10:
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
            
            FIND crapcob WHERE crapcob.cdcooper = par_cdcooper     AND
                               crapcob.cdbandoc = crapcco.cddbanco AND
                               crapcob.nrdctabb = crapcco.nrdctabb AND
                               crapcob.nrcnvcob = par_nrcnvcob     AND
                               crapcob.nrdconta = par_nrdconta     AND
                               crapcob.nrdocmto = par_nrdocmto 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                           
            IF  NOT AVAILABLE crapcob  THEN
                DO:
                    IF  LOCKED crapcob  THEN
                        DO:
                            aux_dscritic = "Registro do boleto esta sendo " +
                                           "alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Boleto nao cadastrado.".
                END.

            LEAVE.

        END. /** Fim do DO .. TO **/

        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.

        IF  crapcob.incobran <> 0 OR crapcob.dtdpagto <> ?  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O boleto nao pode ser " +
                                      (IF  par_idtransa = 1  THEN
                                           "baixado."
                                       ELSE
                                           "excluido.").

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        FIND craptdb WHERE (craptdb.cdcooper = crapcob.cdcooper AND
                            craptdb.nrdconta = crapcob.nrdconta AND
                            craptdb.cdbandoc = crapcob.cdbandoc AND
                            craptdb.nrdctabb = crapcob.nrdctabb AND
                            craptdb.nrcnvcob = crapcob.nrcnvcob AND
                            craptdb.nrdocmto = crapcob.nrdocmto AND
         /** A Liberar **/  craptdb.insittit = 0)
         NO-LOCK NO-ERROR.
                           
         IF  NOT AVAIL craptdb THEN
             FIND craptdb WHERE 
                 (craptdb.cdcooper = crapcob.cdcooper AND
                  craptdb.nrdconta = crapcob.nrdconta AND
                  craptdb.cdbandoc = crapcob.cdbandoc AND
                  craptdb.nrdctabb = crapcob.nrdctabb AND
                  craptdb.nrcnvcob = crapcob.nrcnvcob AND
                  craptdb.nrdocmto = crapcob.nrdocmto AND
              /** Liberado  **/  craptdb.insittit = 4)               
              NO-LOCK NO-ERROR.
                           
        IF  AVAILABLE craptdb  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O boleto nao pode ser " +
                                    (IF  par_idtransa = 1  THEN
                                         "baixado"
                                     ELSE
                                         "excluido") +
                                    " devido ao desconto de titulos.".     

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_idtransa = 1  THEN  /** Baixa **/
            ASSIGN crapcob.incobran = 5
                   crapcob.indpagto = 3
                   crapcob.dtdpagto = par_dtmvtolt
                   crapcob.dtdbaixa = par_dtmvtolt.
        ELSE
        IF  par_idtransa = 2  THEN  /** Exclusao **/
            ASSIGN crapcob.incobran = 5
                   crapcob.dtelimin = par_dtmvtolt
                   crapcob.indpagto = 3.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de transacao invalido.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao1.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrcnvcob",
                                             INPUT "",
                                             INPUT STRING(par_nrcnvcob)).
                
                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrdocmto",
                                             INPUT "",
                                             INPUT STRING(par_nrdocmto)).
                END.

            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcnvcob",
                                     INPUT "",
                                     INPUT STRING(par_nrcnvcob)).
                
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrdocmto",
                                     INPUT "",
                                     INPUT STRING(par_nrdocmto)).
        END.
        
    RETURN "OK".    
      
END PROCEDURE.


/******************************************************************************/
/**                Procedure para cadastro dos boleto gerados                **/
/******************************************************************************/
PROCEDURE gravar-boleto:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinssac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdavali AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdtpinav AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinsava AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdoccop AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vltitulo AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddespec AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcartei AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtdocmto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vldescto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlabatim AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qttitulo AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdtpvcto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiavct AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdmensag AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdinstr AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsinform AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM par_flgdprot AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiaprt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_indiaprt AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inemiten AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlrmulta AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vljurdia AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgaceit AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgregis AS LOGI                           NO-UNDO.
    
    /* 1=vlr "R$" diario, 2= "%" Mensal, 3=isento */
    DEF  INPUT PARAM par_tpjurmor AS INTE                           NO-UNDO.
    
    /* 1=vlr "R$", 2= "%" , 3=isento */
    DEF  INPUT PARAM par_tpdmulta AS INTE                           NO-UNDO.

    /* 1 = Boleto / 2 = Carnê */
    DEF  INPUT PARAM par_tpemitir AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdiavct AS INTE                           NO-UNDO.

    /* Serasa */
    DEF  INPUT PARAM par_flserasa AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_qtdianeg AS INTE                           NO-UNDO.

    /* Aviso SMS */
    DEF  INPUT PARAM par_inavisms AS INTE                                  NO-UNDO.
    DEF  INPUT PARAM par_insmsant AS INTE                                  NO-UNDO.
    DEF  INPUT PARAM par_insmsvct AS INTE                                  NO-UNDO.
    DEF  INPUT PARAM par_insmspos AS INTE                                  NO-UNDO.

    /* NPC */
    DEF  INPUT PARAM par_flgregon AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpagdiv AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlminimo AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-consulta-blt.
    DEF OUTPUT PARAM TABLE FOR tt-dados-sacado-blt.
        
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrsacado AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcnvceb AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdocmto AS INTE                                    NO-UNDO.
    DEF VAR aux_diavecto AS INTE                                    NO-UNDO.
    DEF VAR dia_vencimto AS INTE                                    NO-UNDO.
    DEF VAR mes_vencimto AS INTE                                    NO-UNDO.
    DEF VAR ano_vencimto AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdoccop AS INTE                                    NO-UNDO.
    DEF VAR aux_cdtarhis AS INTE                                    NO-UNDO.
    DEF VAR aux_flgsacad AS INTE                                    NO-UNDO.
    DEF VAR aux_cdbandoc AS INTE                                    NO-UNDO.

    DEF VAR aux_vltarifa AS DECI                                    NO-UNDO.
    DEF VAR aux_nrinssac AS DECI                                    NO-UNDO.
    
    DEF VAR aux_vencimto AS DATE                                    NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_nrnosnum AS CHAR                                    NO-UNDO.
    
    DEF VAR aux_lsdoctos AS LONGCHAR                                NO-UNDO.

    DEF VAR tar_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR tar_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR tar_vltarifa AS DECI                                    NO-UNDO.
    DEF VAR tar_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR tar_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR tar_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR aux_qtdbltcb AS INTE                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.

    DEF VAR aux_diasvcto AS INTE                                    NO-UNDO.

    /* EMAIL DOS PAGADORES */
    DEF VAR aux_dsdemail AS CHAR                                    NO-UNDO.

    /* Nome do Beneficiario para imprimir no boleto */
    DEF VAR aux_nmdobnfc AS CHAR                                    NO-UNDO.

    /* Tratamento para os boletos e a emissão de carnê */
    DEF VAR aux_vltitulo      AS DECI                               NO-UNDO.
    DEF VAR aux_vldescto      AS DECI                               NO-UNDO.
    DEF VAR aux_vlabatim      AS DECI                               NO-UNDO.
    DEF VAR aux_vltitulo_dif  AS DECI                               NO-UNDO.
    DEF VAR aux_vldescto_dif  AS DECI                               NO-UNDO.
    DEF VAR aux_vlabatim_dif  AS DECI                               NO-UNDO.

    DEF BUFFER crabceb FOR crapceb.

    DEF VAR h-b1wgen0010 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0087 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0088 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0090 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-consulta-blt.
    EMPTY TEMP-TABLE tt-dados-sacado-blt.
    EMPTY TEMP-TABLE tt-verifica-sacado.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gerar boleto bancario e obter dados para impressao".
    
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        IF crapass.idastcjt = 0 THEN
        DO:
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.cdsitsnh = 1       /*     AND
                       crapsnh.flgbolet = TRUE    */     NO-LOCK NO-ERROR.
        END.
        ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                     crapsnh.nrdconta = par_nrdconta AND
                                     crapsnh.tpdsenha = 1            AND
                                     crapsnh.cdsitsnh = 1      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    END.
                       
    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta sem permissao para emitir/consultar " +
                                  "boleto.\nAssine o termo de adesao na " +
                                  "Cooperativa.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.

    ASSIGN aux_flgtrans = FALSE.
      
    TRANSACAO:

    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:

        FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                 crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF AVAIL crapass THEN
        DO:
            IF crapass.inpessoa = 1 AND par_flgdprot THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Protesto Automatico nao permitido.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        END.
        
        IF  TRIM(par_nrinssac) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o(s) pagador(es) para gerar o(s)" +
                                      " boleto(s).".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /* comentado pois par_dtmvtolt vem da crapdat - Rafael Cechet - 06/04/11
           IF  par_dtmvtolt < aux_datdodia  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de emissao invalida.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.*/

        IF TRIM(par_nmdavali) <> "" OR par_nrinsava > 0  THEN
            DO:
                IF TRIM(par_nmdavali) = "" THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Informe o Nome do Avalista.".
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                ELSE IF par_cdtpinav = 0 THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Informe o tipo de documento " + 
                                          "do Avalista.".
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                ELSE IF par_nrinsava = 0 THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Informe o Documento do Avalista.".
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
            END.

        IF  TRIM(par_dsdoccop) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o numero do documento.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        IF  par_dtvencto = ?  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe a data de vencimento.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_dtvencto > DATE("13/10/2049") THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de vencimento superior " + 
                                      "ao limite 13/10/2049.".
    
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF par_dtdocmto > DATE("13/10/2049") THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de documento superior " + 
                                      "ao limite 13/10/2049.".
    
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
         
         IF (TODAY - 90) > par_dtdocmto THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data retroativa maior que 90 dias.".
    
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_dtvencto < par_dtdocmto  OR
            par_dtvencto < TODAY  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de vencimento invalida.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        /* comparar vencimento com a data de hoje */
        IF  par_dtvencto <= ADD-INTERVAL(TODAY,+7,'DAYS') AND
            par_inemiten = 1 /* banco emite e expede */ AND 
            par_flgregis /* cob registrada */ THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Data de vencimento inferior a 7 dias.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_inemiten = 3 /* coop. emite e expede */ AND 
            par_flgregis /* cob registrada */ THEN
            DO:
                FIND craptab WHERE 
                     craptab.cdcooper = 3                  AND /* Parametro Apenas Cadastrado na Cecred */
                     craptab.nmsistem = "CRED"             AND
                     craptab.tptabela = "GENERI"           AND
                     craptab.cdempres = 0                  AND
                     craptab.cdacesso = "DIASVCTOCEE"      AND
                     craptab.tpregist = 0
                     NO-LOCK NO-ERROR.
                    
                IF  NOT AVAILABLE craptab   THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Tabela com parametro vencimento nao encontrado.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                    
                ASSIGN aux_diasvcto = INT(SUBSTR(craptab.dstextab,1,2)).

                IF par_dtvencto <= ADD-INTERVAL(TODAY,aux_diasvcto,'DAYS') THEN
                DO:

                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Vencimento inferior a " + STRING(aux_diasvcto) +
                                           " dia(s) de acordo com este tipo de emissao.".
                           
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
            END.

        IF  par_vltitulo > 0  THEN
            DO:
                /*IF  par_vltitulo > crapsnh.vllbolet  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Valor do titulo e maior que " +
                                              "o limite liberado para a conta.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.*/
                    
                IF  par_vldescto >= par_vltitulo  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Desconto nao pode ser maior " +
                                              "que o valor do boleto.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                            
                IF  par_vlabatim >= par_vltitulo  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Abatimento nao pode ser " +
                                              "maior que o valor do boleto.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                                
                IF (par_vldescto + par_vlabatim) >= par_vltitulo  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Desconto/Abatimento nao pode " +
                                              "ser maior que o valor do " +
                                              "boleto.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

                /* VR boletos */
                IF  par_vltitulo >= 250000 AND NOT par_flgregis  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Boletos acima de R$ 250.000,00 " +
                                              "somente na modalidade de " +
                                              "Cobranca com Registro.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

            END.
        ELSE
            DO:
                IF  par_vldescto > 0  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Desconto nao pode ser maior " +
                                              "que o valor do boleto.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                            
                IF  par_vlabatim > 0  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Abatimento nao pode ser maior " +
                                              "que o valor do boleto.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.                                 
            END.
                    
        IF  par_cddespec < 1 OR par_cddespec > 7  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Especie do documento invalida.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        IF  par_cdmensag > 0 AND par_vldescto <= 0  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o valor do desconto.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_vldescto > 0 AND par_cdmensag <> 1 AND par_cdmensag <> 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de mensagem para desconto " +
                                      "invalida.".
                                      
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
             
        IF  par_qttitulo <= 0  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe a quantidade de parcelas.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_qttitulo > 120  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Quantidade maxima de mensalidades " +
                                      "permitida e 120.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_cdtpvcto <> 1 AND par_cdtpvcto <> 2 AND par_cdtpvcto <> 3  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de vencimento invalido.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        IF  par_cdtpvcto = 2 AND par_qtdiavct <= 0  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe a quantidade de dias para o " +
                                      "vencimento.".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  par_cdtpvcto = 3 AND (par_nrdiavct <= 0 OR par_nrdiavct > 28)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Dia de vencimento no mes invalido".

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF par_flgregis AND ( par_vlminimo > 0 OR CAN-DO("0,1,2", STRING(par_inpagdiv)) ) THEN
           DO:           
           
             IF par_vlminimo > 0.01 AND (par_inpagdiv = 0 OR par_inpagdiv = 2) THEN                         
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Valor minimo informado nao esta de acordo com " + 
                                          "o tipo de pagto divergente".

                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
             
             
             IF par_vlminimo > 0.01 AND par_inpagdiv = 1 THEN              
                DO:                
                  IF par_vlminimo > (par_vltitulo - (par_vldescto + par_vlabatim)) THEN
                     DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Valor minimo superior ao valor final boleto".

                       UNDO TRANSACAO, LEAVE TRANSACAO.
                     END.                     
                END.
                
             IF par_vlminimo = 0 AND par_inpagdiv = 1 THEN         
                 DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Valor minimo deve ser superior a zero".

                   UNDO TRANSACAO, LEAVE TRANSACAO.
                 END.                              
           END.

       /* Verificar se o TIPO de JUROS, ou MULTA, sejam um dos valores validos*/
       IF  NOT CAN-DO("1,2,3",STRING(par_tpjurmor)) OR    /* 1=vlr "R$" diario, 2= "%" Mensal, 3=isento */
           NOT CAN-DO("1,2,3",STRING(par_tpdmulta)) THEN  /* 1=vlr "R$", 2= "%" , 3=isento */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de juros de mora ou tipo de multa nao selecionado".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF NOT CAN-DO("1,2",STRING(par_tpemitir)) THEN  /* 1-Boleto/2-Carne */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Formato do documento (boleto avulso ou carne) nao selecionado".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        
        IF NOT CAN-DO("1,2,3",STRING(par_inemiten)) THEN  /* 1-Banco/2-Cooperado/3-Cooperativa */
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Forma de emissao do documento nao selecionado".
            
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF par_tpemitir = 2 THEN /* 1-Boleto/2-Carne */            
           DO:
           
             IF ((par_vltitulo / par_qttitulo) < 0.01) THEN
                DO:            
                  ASSIGN aux_cdcritic = 0
                         aux_dscritic = "Valor das parcelas nao pode ser menor que R$0,01".
              
                  UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
           END.
            
        RUN sistema/generico/procedures/b1wgen0010.p PERSISTENT SET h-b1wgen0010.

        IF  NOT VALID-HANDLE(h-b1wgen0010)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0010.".

            UNDO TRANSACAO, LEAVE TRANSACAO.
        END.                  


        /*Busca nome impresso no boleto*/
        RUN busca-nome-imp-blt IN h-b1wgen0010( INPUT par_cdcooper
                                              , INPUT par_nrdconta
                                              , INPUT par_idseqttl
                                              , INPUT "consulta-boleto-2via" /*nmprogra*/
                                              ,OUTPUT aux_nmdobnfc
                                              ,OUTPUT aux_dscritic).
                                              
        IF  VALID-HANDLE(h-b1wgen0010) THEN
            DELETE PROCEDURE h-b1wgen0010.                                              

        IF  RETURN-VALUE <> "OK" OR
            aux_dscritic <> ""   THEN 
		    DO: 
			      IF  aux_dscritic = "" THEN 
			      DO:   
				        ASSIGN aux_dscritic =  "Nao foi possivel buscar o nome do beneficiario para ser impresso no boleto".
			      END.
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.


        /* ************************************************************************* */
            /* Daniel */

            IF  par_cdtpvcto = 1  THEN /** Vencimento Mensal **/
                ASSIGN dia_vencimto = DAY(par_dtvencto)
                       mes_vencimto = MONTH(par_dtvencto)
                       ano_vencimto = YEAR(par_dtvencto).
            ELSE
                ASSIGN aux_vencimto = ?.

            DO aux_contador = 1 TO par_qttitulo:

                IF  par_cdtpvcto = 1  THEN
                DO:
                    ASSIGN aux_diavecto = dia_vencimto.
            
                    DO WHILE TRUE:

                        aux_vencimto = DATE(mes_vencimto,aux_diavecto,
                                            ano_vencimto) NO-ERROR.

                        IF  ERROR-STATUS:ERROR  THEN
                            DO:
                                aux_diavecto = aux_diavecto - 1.
                                NEXT.
                            END.
        
                        LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
        
                    IF  mes_vencimto = 12  THEN
                        ASSIGN mes_vencimto = 01
                               ano_vencimto = ano_vencimto + 1.
                    ELSE
                        ASSIGN mes_vencimto = mes_vencimto + 1.
                END.
                ELSE
                DO:
                
                    aux_vencimto = IF  aux_vencimto = ?  THEN
                                       par_dtvencto
                                   ELSE
                                       aux_vencimto + par_qtdiavct.
                END.


               IF  aux_vencimto > DATE("13/10/2049") THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Parcela " + STRING(aux_contador) +
                                          " possui vencimento superior ao limite 13/10/2049.".
                    UNDO TRANSACAO, LEAVE TRANSACAO.
               END.

            END.

        /* ************************************************************************* */


        /** Cobranca Registrada **/
        IF  par_flgregis THEN DO:
            /** se for cobranca registrada, valor do titulo nescessario **/
            IF NOT par_vltitulo > 0 THEN DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Valor do Titulo precisa ser superior " + 
                                      "a zero quando Cobranca Registrada!".
                UNDO, LEAVE.
            END.

            /** Instrucao Automatica **/
            IF  par_flgdprot THEN DO:
                /** Nao permitir dias fora da faixa de 3 a 15 dias **/
                IF  par_qtdiaprt < 5 OR par_qtdiaprt > 15  THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = 
                           "Protesto - Qtd. de dias fora do limite permitido!".
                       
                    UNDO, LEAVE.
                END.
                /* se dia for util e superior a 5 dias, recusar */
                IF  par_indiaprt = 1 AND par_qtdiaprt > 5 THEN DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = 
                           "Quantidade de dias uteis fora do limite permitido!".
                    UNDO, LEAVE.
                END.

            END.
            
            DO aux_nrsacado = 1 TO NUM-ENTRIES(par_nrinssac,"%"):
    
                ASSIGN aux_nrinssac = DECI(ENTRY(aux_nrsacado,par_nrinssac,"%"))
                       aux_nrdoccop = 1.
                
                IF  aux_nrinssac = 0  THEN
                    NEXT.
                
                FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                                   crapsab.nrdconta = par_nrdconta AND
                                   crapsab.nrinssac = aux_nrinssac 
                                   NO-LOCK NO-ERROR.
                                       
                IF  NOT AVAILABLE crapsab  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Pagador informado nao cadastrado.".

                        IF  VALID-HANDLE(h-b1wgen0087) THEN
                            DELETE PROCEDURE h-b1wgen0087.
                               
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
    
                CREATE tt-verifica-sacado.
                ASSIGN tt-verifica-sacado.nrcpfcgc = int64(aux_nrinssac)
                       tt-verifica-sacado.tppessoa = IF crapsab.cdtpinsc = 1 
                                                      THEN 
                                                        "F"  /*Fisica*/
                                                      ELSE 
                                                        "J" /*Juridica*/
                       tt-verifica-sacado.flgsacad  = FALSE.
    
                
            END. /* Fim DO... TO.... */
            
            /* se for cob. reg. limpa instrucoes */
            ASSIGN par_dsdinstr = "".

        END. /* se flgregis = true - cobranca registrada */

        /* Loop de sacados */
        DO aux_nrsacado = 1 TO NUM-ENTRIES(par_nrinssac,"%"):
            
            ASSIGN aux_nrinssac = DECI(ENTRY(aux_nrsacado,par_nrinssac,"%"))
                   aux_nrdoccop = 1.
            
            IF  aux_nrinssac = 0  THEN
                NEXT.

            FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                               crapsab.nrdconta = par_nrdconta AND
                               crapsab.nrinssac = aux_nrinssac 
                               NO-LOCK NO-ERROR.

            IF par_flgregis THEN
                FIND tt-verifica-sacado WHERE 
                     tt-verifica-sacado.nrcpfcgc = aux_nrinssac NO-ERROR.

            FIND FIRST tt-dados-sacado-blt 
                WHERE tt-dados-sacado-blt.cdcooper = par_cdcooper
                  AND tt-dados-sacado-blt.nrdconta = par_nrdconta
                  AND tt-dados-sacado-blt.nrinssac = aux_nrinssac
                NO-LOCK NO-ERROR.
            
            IF NOT AVAIL tt-dados-sacado-blt THEN
            DO:
                CREATE tt-dados-sacado-blt.
                ASSIGN tt-dados-sacado-blt.cdcooper = par_cdcooper
                       tt-dados-sacado-blt.nrdconta = par_nrdconta
                       tt-dados-sacado-blt.nmdsacad = REPLACE(crapsab.nmdsacad,
                                                              "&","%26")
                       tt-dados-sacado-blt.dsendsac = REPLACE(crapsab.dsendsac,
                                                              "&","%26")
                       tt-dados-sacado-blt.complend = REPLACE(crapsab.complend,
                                                              "&","%26")
                       tt-dados-sacado-blt.nmbaisac = REPLACE(crapsab.nmbaisac,
                                                              "&","%26")
                       tt-dados-sacado-blt.nmcidsac = REPLACE(crapsab.nmcidsac,
                                                              "&","%26")
                       tt-dados-sacado-blt.nrendsac = crapsab.nrendsac
                       tt-dados-sacado-blt.cdufsaca = crapsab.cdufsaca
                       tt-dados-sacado-blt.nrcepsac = crapsab.nrcepsac
                       tt-dados-sacado-blt.nrinssac = crapsab.nrinssac
                       tt-dados-sacado-blt.cdtpinsc = crapsab.cdtpinsc
                       tt-dados-sacado-blt.flgsacad = (IF par_flgregis THEN tt-verifica-sacado.flgsacad ELSE FALSE).
                       
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

                RUN STORED-PROCEDURE pc_busca_emails_pagador
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT aux_nrinssac,
                                            OUTPUT "",  /* pr_dsdemail */
                                            OUTPUT "",  /* pr_des_erro */
                                            OUTPUT ""). /* pr_dscritic */

                CLOSE STORED-PROC pc_busca_emails_pagador
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_dsdemail = ""
                       aux_dscritic = ""
                       aux_deserro  = ""
                       aux_dsdemail = pc_busca_emails_pagador.pr_dsdemail
                                          WHEN pc_busca_emails_pagador.pr_dsdemail <> ?
                       aux_dscritic = pc_busca_emails_pagador.pr_dscritic
                                          WHEN pc_busca_emails_pagador.pr_dscritic <> ?
                       aux_deserro = pc_busca_emails_pagador.pr_des_erro
                                          WHEN pc_busca_emails_pagador.pr_des_erro <> ?.

                ASSIGN tt-dados-sacado-blt.dsdemail = aux_dsdemail
                       tt-dados-sacado-blt.flgemail = (IF TRIM(aux_dsdemail) <> "" THEN TRUE ELSE FALSE).
            END.
            
            IF  par_cdtpvcto = 1  THEN /** Vencimento Mensal **/
                ASSIGN dia_vencimto = DAY(par_dtvencto)
                       mes_vencimto = MONTH(par_dtvencto)
                       ano_vencimto = YEAR(par_dtvencto).
            ELSE IF  par_cdtpvcto = 2  THEN /** Vencimento a cada X dias **/
                ASSIGN aux_vencimto = ?.
            ELSE /** Vencimento no dia X de cada mes **/
                ASSIGN dia_vencimto = DAY(par_dtvencto)
                       mes_vencimto = MONTH(par_dtvencto)
                       ano_vencimto = YEAR(par_dtvencto).

            /* se flgregis = true - cobranca registrada */
            IF par_flgregis THEN
            DO:                                                
			
				/** Instrucao Automatica E Duplicata de Servico **/
				IF  par_flgdprot AND par_cddespec = 2 THEN DO:
				
				
					{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

					RUN STORED-PROCEDURE pc_validar_dsnegufds_parprt
						aux_handproc = PROC-HANDLE NO-ERROR
												(INPUT par_cdcooper,
												 INPUT tt-dados-sacado-blt.cdufsaca,
												OUTPUT "",  /* pr_des_erro */
												OUTPUT ""). /* pr_dscritic */

					CLOSE STORED-PROC pc_validar_dsnegufds_parprt
						  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

					{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

					ASSIGN aux_dscritic = ""
						   aux_deserro  = ""
						   aux_dscritic = pc_validar_dsnegufds_parprt.pr_dscritic
											  WHEN pc_validar_dsnegufds_parprt.pr_dscritic <> ?
						   aux_deserro = pc_validar_dsnegufds_parprt.pr_des_erro
											  WHEN pc_validar_dsnegufds_parprt.pr_des_erro <> ?.

					ASSIGN tt-dados-sacado-blt.dsdemail = aux_dsdemail
						   tt-dados-sacado-blt.flgemail = (IF TRIM(aux_dsdemail) <> "" THEN TRUE ELSE FALSE).
						   
					IF aux_dscritic <> "" THEN DO:
						IF  VALID-HANDLE(h-b1wgen0087) THEN
							DELETE PROCEDURE h-b1wgen0087.

						UNDO TRANSACAO, LEAVE TRANSACAO.
					END.
					

				END.
			
                /* Se o codigo da carteira for 5 ou 6, entao o convenio sera
                   escolhido pelo parameto par_nrcnvcob */
                /* carteira 5 - Quanta */
                /* carteira 6 - Recuperacao de credito */
                IF par_cdcartei = 5 OR 
                   par_cdcartei = 6 THEN DO:                   
                   IF par_nrcnvcob = ? THEN
                      ASSIGN par_nrcnvcob = 0.
                END.
                ELSE 
                  ASSIGN par_nrcnvcob = 0.
                                              
                /* o sistema irá fazer a escolha do convenio em funcao
                   do sacado ser DDA ou nao */

                IF par_inemiten = 1 AND tt-verifica-sacado.flgsacad = FALSE THEN
                DO:
                    FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper
                                       AND crapcco.cddbanco = 1
                                       AND crapcco.flginter = TRUE
                                       AND crapcco.flgregis = TRUE
                                       /*AND crapcco.flgativo = TRUE*/
                                       AND crapcco.dsorgarq = "INTERNET"
                                       NO-LOCK
                       ,FIRST crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                       AND crapceb.nrdconta = par_nrdconta 
                                       AND crapceb.nrconven = crapcco.nrconven
                                       AND crapceb.insitceb = 1
                                       NO-LOCK:
                        par_nrcnvcob = crapcco.nrconven.
                    END.
                END.
                ELSE
                DO:
                  IF par_nrcnvcob = 0 THEN DO:
                    FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper
                                       AND crapcco.cddbanco = 085
                                       AND crapcco.flginter = TRUE
                                       AND crapcco.flgregis = TRUE
                                       /*AND crapcco.flgativo = TRUE*/
                                       AND crapcco.dsorgarq = "INTERNET"
                                       NO-LOCK
                       ,FIRST crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                       AND crapceb.nrdconta = par_nrdconta  
                                       AND crapceb.nrconven = crapcco.nrconven
                                       AND crapceb.insitceb = 1
                                       NO-LOCK:
                        par_nrcnvcob = crapcco.nrconven.
                      END.                    
                  END.
                  ELSE DO:
                        FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper
                                           AND crapcco.cddbanco = 085
                                           AND crapcco.nrconven = par_nrcnvcob
                                           NO-LOCK
                           ,FIRST crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                           AND crapceb.nrdconta = par_nrdconta  
                                           AND crapceb.nrconven = crapcco.nrconven
                                           AND crapceb.insitceb = 1
                                           NO-LOCK:
                            par_nrcnvcob = crapcco.nrconven.
                      END.                                      
                    END.                       

                    /* se nao encontrou convenio 085, pode ser que o cooperado
                       tenha somente convenio registrado 001 */
                    IF  par_nrcnvcob = 0 THEN
                        DO:
                            FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper
                                               AND crapcco.cddbanco = 001
                                               AND crapcco.flginter = TRUE
                                               AND crapcco.flgregis = TRUE
                                               /*AND crapcco.flgativo = TRUE*/
                                               AND crapcco.dsorgarq = "INTERNET"
                                               NO-LOCK
                               ,FIRST crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                               AND crapceb.nrdconta = par_nrdconta 
                                               AND crapceb.nrconven = crapcco.nrconven
                                               AND crapceb.insitceb = 1
                                               NO-LOCK:
                                par_nrcnvcob = crapcco.nrconven.
                            END.

                            IF  par_nrcnvcob > 0 THEN
                                DO:
                                    FIND tt-verifica-sacado WHERE 
                                         tt-verifica-sacado.nrcpfcgc = aux_nrinssac 
                                         EXCLUSIVE-LOCK NO-ERROR.
    
                                    ASSIGN tt-verifica-sacado.flgsacad = FALSE.

                                    FIND FIRST tt-dados-sacado-blt 
                                        WHERE tt-dados-sacado-blt.cdcooper = par_cdcooper
                                          AND tt-dados-sacado-blt.nrdconta = par_nrdconta
                                          AND tt-dados-sacado-blt.nrinssac = aux_nrinssac
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                                    IF  AVAIL tt-dados-sacado-blt THEN
                                        ASSIGN tt-dados-sacado-blt.flgsacad = FALSE.
                                END.
                        END.
                END.
            END. /* fim se flgregis = true - cobranca registrada */
            ELSE /* senao sera cobranca sem registro */
            DO:
                ASSIGN par_nrcnvcob = 0.

                FOR EACH crapcco WHERE crapcco.cdcooper = par_cdcooper 
                                    /*AND crapcco.flgativo = TRUE*/
                                    AND crapcco.flginter = TRUE         
                                    AND crapcco.flgregis = FALSE        
                                    AND crapcco.dsorgarq = "INTERNET"
                                    NO-LOCK
                   ,FIRST crapceb WHERE crapceb.cdcooper = crapcco.cdcooper
                                    AND crapceb.nrdconta = par_nrdconta 
                                    AND crapceb.nrconven = crapcco.nrconven
                                    AND crapceb.insitceb = 1
                                    NO-LOCK:

                    par_nrcnvcob = crapcco.nrconven.
                END.
            END.

            FIND crapceb WHERE 
                 crapceb.cdcooper = par_cdcooper AND
                 crapceb.nrdconta = par_nrdconta AND
                 crapceb.nrconven = par_nrcnvcob AND
				 crapceb.insitceb = 1 NO-LOCK NO-ERROR.

            FIND crapcco WHERE
                 crapcco.cdcooper = par_cdcooper AND
                 crapcco.nrconven = par_nrcnvcob NO-LOCK NO-ERROR.

            /* buscar convenio do cooperado - crapceb */
            IF AVAIL crapceb THEN
            DO:
                ASSIGN par_nrcnvcob = crapcco.nrconven.
                FIND LAST crapceb WHERE crapceb.cdcooper = par_cdcooper 
                                    AND crapceb.nrdconta = par_nrdconta
                                    AND crapceb.nrconven = par_nrcnvcob 
                                    NO-LOCK USE-INDEX crapceb1 NO-ERROR.
            END.
            ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                   aux_dscritic = 
                           "Convenio nao cadastrado ou invalido.".

                IF  VALID-HANDLE(h-b1wgen0087) THEN
                    DELETE PROCEDURE h-b1wgen0087.

                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
            /** Procura convenio CEB do cooperado **/
            FIND LAST crapceb WHERE crapceb.cdcooper = par_cdcooper AND
                                    crapceb.nrdconta = par_nrdconta AND
                                    crapceb.nrconven = crapcco.nrconven 
                                    NO-LOCK USE-INDEX crapceb1 NO-ERROR.
            
            IF  NOT AVAILABLE crapceb OR crapceb.insitceb <> 1 THEN
            DO:
                IF   NOT AVAIL crapceb   THEN
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Conta sem cobranca cadastrada." +
                                "\nEntre em contato com seu PA.".
                ELSE
                     ASSIGN aux_cdcritic = 0
                            aux_dscritic = "Cadastro de cobranca inativo."+
                                         "\nEntre em contato com seu PA.".

                IF  VALID-HANDLE(h-b1wgen0087) THEN
                    DELETE PROCEDURE h-b1wgen0087.
    
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.                
            ELSE
                aux_nrcnvceb = crapceb.nrcnvceb.

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                                
            /* Calcular o valor de cada parcela */
            IF par_tpemitir = 1 THEN
            DO: /* Quando for boleto o valor de cada parcela será 
                   o valor que veio como parametro
                   e o valor da diferença será zero */
                ASSIGN aux_vltitulo     = par_vltitulo
                       aux_vldescto     = par_vldescto
                       aux_vlabatim     = par_vlabatim
                       aux_vltitulo_dif = 0
                       aux_vldescto_dif = 0
                       aux_vlabatim_dif = 0.
            END.
            ELSE 
            DO: /* Quando for carnê temos que dividir o valor 
                   do titulo/desconto/abatimento pela quantidade 
                   de parcelas e calcular a diferença de cada uma*/
                ASSIGN  aux_vltitulo     = TRUNC(par_vltitulo / par_qttitulo,2)
                        aux_vldescto     = TRUNC(par_vldescto / par_qttitulo,2)
                        aux_vlabatim     = TRUNC(par_vlabatim / par_qttitulo,2)
                        aux_vltitulo_dif = TRUNC(par_vltitulo -
                                                (aux_vltitulo * par_qttitulo),2)
                        aux_vldescto_dif = TRUNC(par_vldescto -
                                                (aux_vldescto * par_qttitulo),2)
                        aux_vlabatim_dif = TRUNC(par_vlabatim -
                                                (aux_vlabatim * par_qttitulo),2).

            END.
			
			
            /*PRB0041939 - Validar se já foi gerado o mesmo boleto no prazo de 1 minuto */
			FOR EACH crapcob NO-LOCK WHERE crapcob.cdcooper = par_cdcooper
                                       AND crapcob.nrdconta = par_nrdconta
                                       AND crapcob.dtmvtolt = par_dtmvtolt
                                       AND crapcob.nrinssac = aux_nrinssac
                                       AND crapcob.dtdocmto = par_dtdocmto
                                       AND crapcob.dtvencto = par_dtvencto
                                       AND crapcob.vltitulo = (aux_vltitulo + aux_vltitulo_dif),
                EACH crapcol NO-LOCK WHERE crapcol.cdcooper = crapcob.cdcooper
                                       AND crapcol.nrdconta = crapcob.nrdconta
                                       AND crapcol.nrdocmto = crapcob.nrdocmto
                                       AND crapcol.nrcnvcob = crapcob.nrcnvcob
                                       AND (TIME - crapcol.hrtransa) <= 60:

                FIND FIRST crapcri WHERE crapcri.cdcritic = 2100 NO-LOCK NO-ERROR.

                IF  AVAILABLE crapcri  THEN
                    DO: 
                        ASSIGN  aux_cdcritic = crapcri.cdcritic
                                aux_dscritic = crapcri.dscritic.
    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
                ELSE
                    DO:
                        ASSIGN  aux_cdcritic = 0
                                aux_dscritic = "Você acabou de gerar um boleto com os mesmos dados (valor, pagador e vencimento)."+
                                                "\nPara emitir novamente um boleto igual, aguarde um minuto.".
												
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

            END.

            /* DO... To... dos Titulos */
            DO aux_contador = 1 TO par_qttitulo:

                IF  par_cdtpvcto = 1  THEN
                DO:
                    /* Vencimento Mensal */
                    ASSIGN aux_diavecto = dia_vencimto.
            
                    DO WHILE TRUE:

                        aux_vencimto = DATE(mes_vencimto,aux_diavecto,
                                            ano_vencimto) NO-ERROR.

                        IF  ERROR-STATUS:ERROR  THEN
                            DO:
                                aux_diavecto = aux_diavecto - 1.
                                NEXT.
                            END.
        
                        LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
        
                    IF  mes_vencimto = 12  THEN
                        ASSIGN mes_vencimto = 01
                               ano_vencimto = ano_vencimto + 1.
                    ELSE
                        ASSIGN mes_vencimto = mes_vencimto + 1.
                END.
                ELSE IF par_cdtpvcto = 2 THEN
                DO:
                    /* Vencimento a cada X dias */
                    aux_vencimto = IF  aux_vencimto = ?  THEN
                                       par_dtvencto
                                   ELSE
                                       aux_vencimto + par_qtdiavct.
                END.
                ELSE 
                DO:
                    
                    /* O vencimento da primeira parcela será no dia que foi informado*/
                    IF aux_contador = 1 THEN
                        aux_vencimto = par_dtvencto.
                    ELSE 
                    DO:
                        /* Vencimento no dia X de cada mês */
                        ASSIGN aux_diavecto = par_nrdiavct.
                        IF  mes_vencimto = 12  THEN
                            ASSIGN mes_vencimto = 01
                                   ano_vencimto = ano_vencimto + 1.
                        ELSE
                            ASSIGN mes_vencimto = mes_vencimto + 1.

                        DO WHILE TRUE:
    
                            aux_vencimto = DATE(mes_vencimto,aux_diavecto,
                                                ano_vencimto) NO-ERROR.
    
                            IF  ERROR-STATUS:ERROR  THEN
                                DO:
                                    aux_diavecto = aux_diavecto - 1.
                        
                                    NEXT.
                                END.
            
                            LEAVE.
    
                        END. /** Fim do DO WHILE TRUE **/

                    END.
                END.
        
                /* run na procedura de criacao do titulo */
                RUN p_cria_titulo (INPUT par_cdcooper,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT aux_nmdobnfc,
                                   INPUT crapcco.nrconven,
                                   INPUT aux_nrcnvceb,
                                   INPUT aux_nrdocmto,
                                   INPUT par_inemiten,
                                   INPUT crapcco.cddbanco,
                                   
                                   INPUT crapcco.nrdctabb,
                                   INPUT crapcco.cdcartei,
                                   INPUT par_cddespec,
                                   INPUT crapsab.cdtpinsc,
                                   INPUT crapsab.nrinssac,
                                   INPUT par_nmdavali,
                                   INPUT par_cdtpinav,
                                   INPUT par_nrinsava,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtdocmto,
                                   INPUT aux_vencimto,
                                   INPUT (aux_vldescto + aux_vldescto_dif),
                                   INPUT (aux_vlabatim + aux_vlabatim_dif),
                                   INPUT par_cdmensag,
                                   INPUT CAPS(TRIM(par_dsdoccop)),
                                   INPUT aux_nrdoccop,
                                   INPUT (aux_vltitulo + aux_vltitulo_dif),
                                   INPUT par_dsdinstr,
                                   INPUT par_dsinform,
                                   INPUT crapsab.nrctasac,
                                   INPUT par_nrctremp,
                                   INPUT aux_nrnosnum,
                                   INPUT par_flgdprot,
                                   INPUT par_qtdiaprt,
                                   INPUT par_indiaprt,
                                   INPUT par_vljurdia,
                                   INPUT par_vlrmulta,
                                   INPUT par_flgaceit,
                                   INPUT par_flgregis,
                                   INPUT (IF par_flgregis THEN 
                                              tt-verifica-sacado.flgsacad 
                                          ELSE 
                                              FALSE),
                                   INPUT par_tpjurmor,
                                   INPUT par_tpdmulta,
                                   INPUT par_tpemitir,
                                   INPUT par_cdoperad,

                                   /* Serasa */
                                   INPUT par_flserasa,
                                   INPUT par_qtdianeg,

                                   /* Aviso SMS*/
                                   INPUT par_inavisms,
                                   INPUT par_insmsant,
                                   INPUT par_insmsvct,
                                   INPUT par_insmspos,

                                   /* NPC */
                                   INPUT crapceb.flgregon,
                                   INPUT par_inpagdiv,
                                   INPUT par_vlminimo,

                                   INPUT TABLE tt-dados-sacado-blt,
                                   INPUT-OUTPUT aux_lsdoctos,
                                  OUTPUT aux_cdcritic,
                                  OUTPUT aux_dscritic,
                                  OUTPUT TABLE tt-consulta-blt).

                /* incrementar o numero do nrdocmto para cada titulo */
                ASSIGN aux_nrdocmto = aux_nrdocmto + 1
                       aux_nrdoccop = aux_nrdoccop + 1.

                /* zerar as diferenças pois elas foram adicionado todo na primeira parcela */
                ASSIGN aux_vltitulo_dif = 0
                       aux_vldescto_dif = 0
                       aux_vlabatim_dif = 0.
                
                IF  RETURN-VALUE = "NOK" OR aux_dscritic <> ""  THEN
                    DO:                                 
                        IF  VALID-HANDLE(h-b1wgen0087) THEN
                            DELETE PROCEDURE h-b1wgen0087.
    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

            END. /** Fim do DO ... TO qtd  Titulos**/

        END. /** Fim do DO ... TO par_insssac - sacados**/
    
        ASSIGN aux_flgtrans = TRUE.
            
    END. /** Fim do DO TRANSACTION - TRANSACAO **/

    /* se flgregis = true - cobranca registrada */
    IF  par_flgregis AND aux_flgtrans THEN
    DO:
        
        /* INICIO - cobrar tarifas de forma consolidada */
        FOR EACH tt-consulta-blt NO-LOCK BREAK BY tt-consulta-blt.nrcnvcob:

            IF tt-consulta-blt.cdbandoc = 085 THEN
            DO:

                ASSIGN aux_qtdbltcb = aux_qtdbltcb + 1.

                /* Deve gerar tarifa para cada convenio */
                IF LAST-OF(tt-consulta-blt.nrcnvcob) THEN
                DO:                                       

                    FIND FIRST crapcob WHERE crapcob.cdcooper = tt-consulta-blt.cdcooper
                                         AND crapcob.nrcnvcob = tt-consulta-blt.nrcnvcob
                                         AND crapcob.nrdconta = tt-consulta-blt.nrdconta
                                         AND crapcob.nrdocmto = tt-consulta-blt.nrdocmto
                                         AND crapcob.nrdctabb = tt-consulta-blt.nrdctabb
                                         AND crapcob.cdbandoc = tt-consulta-blt.cdbandoc
                                         NO-LOCK NO-ERROR.

                    FIND FIRST crapcco WHERE crapcco.cdcooper = tt-consulta-blt.cdcooper
                                         AND crapcco.nrconven = tt-consulta-blt.nrcnvcob
                                         NO-LOCK NO-ERROR.

                    /* Assume como padrao pessoa juridica ao efetuar busca tarifa*/
                    ASSIGN aux_inpessoa = 2.
                
                    FIND FIRST crapass WHERE crapass.cdcooper = tt-consulta-blt.cdcooper
                                         AND crapass.nrdconta = tt-consulta-blt.nrdconta
                                         NO-LOCK NO-ERROR.
                
                    IF  AVAIL crapass THEN
                        ASSIGN aux_inpessoa = crapass.inpessoa.
                
                    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
                        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
                
                    ASSIGN tar_vltarifa = 0
                           tar_cdhistor = 0
                           tar_cdfvlcop = 0.
                
                    IF  aux_inpessoa <> 3 THEN /* nao cobrar tarifa na geracao ref Cooperativa/EE */
                        DO:
                            /* Busca informacoes tarifa */
                            RUN carrega_dados_tarifa_cobranca IN h-b1wgen0153
                                              (INPUT  tt-consulta-blt.cdcooper,         /* cdcooper */
                                               INPUT  tt-consulta-blt.nrdconta,         /* nrdconta */
                                               INPUT  tt-consulta-blt.nrcnvcob,         /* nrconven */ 
                                               INPUT  "RET",                            /* dsincide REM/RET */ 
                                               INPUT  2,                                /* cdocorre */
                                               INPUT  tt-consulta-blt.cdmotivo,         /* cdmotivo */
                                               INPUT  aux_inpessoa,                     /* inpessoa */
                                               INPUT  1,                                /* vllanmto */
                                               INPUT  "",                               /* cdprogra */
											   INPUT  1,                                /* flaputar = Sim */
                                               OUTPUT tar_cdhistor,                     /* cdhistor */
                                               OUTPUT tar_cdhisest,                     /* cdhisest */
                                               OUTPUT tar_vltarifa,                     /* vltarifa */
                                               OUTPUT tar_dtdivulg,                     /* dtdivulg */
                                               OUTPUT tar_dtvigenc,                     /* dtvigenc */
                                               OUTPUT tar_cdfvlcop,                     /* cdfvlcop */
                                               OUTPUT TABLE tt-erro).
                        END.

                    
                    IF TEMP-TABLE tt-erro:HAS-RECORDS THEN 
                       DO:
                       
                         /* erro de tarifa nao cadastrada */
                         FIND FIRST tt-erro EXCLUSIVE-LOCK NO-ERROR.
                         
                         /* sera ignorada */
                         DELETE tt-erro.
                       END.

                    IF  VALID-HANDLE(h-b1wgen0153)  THEN
                        DELETE PROCEDURE h-b1wgen0153.

                    ASSIGN  aux_vltarifa = tar_vltarifa * aux_qtdbltcb.

                    IF aux_vltarifa > 0 THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT 
                            SET h-b1wgen0090.
                        
                        IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Handle invalido para BO b1wgen0090.".
                        
                                UNDO, LEAVE.
                            END.
                                        
                        RUN gera-lcm-cooperado IN h-b1wgen0090 (INPUT ROWID(crapcob),
                                                                INPUT ROWID(crapcco),
                                                                INPUT tar_cdhistor,
                                                                INPUT aux_vltarifa,
                                                                INPUT par_dtmvtolt,
                                                                INPUT tar_cdfvlcop,
                                                                OUTPUT aux_dscritic).           
                        IF  VALID-HANDLE(h-b1wgen0090) THEN
                            DELETE PROCEDURE h-b1wgen0090.
                    END.

                    ASSIGN aux_qtdbltcb = 0.
                END.

            END.
        END.
        /* FIM - cobrar tarifas de forma consolidada */
          
        /* Enviar para CIP */
        IF crapceb.flgregon = TRUE THEN /* Envia para CIP apenas no Online */ 
        DO:
        
          RUN enviar-cip (INPUT par_cdcooper,
                          INPUT par_nrdconta).
          
        END.

    END.
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao2.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
                
            RETURN "NOK".
        END.
    ELSE
    DO:
        
    END.
            
    IF  par_flgerlog  THEN 
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrcnvcob",
                                     INPUT "",
                                     INPUT STRING(par_nrcnvcob)).

            DO aux_contador = 1 TO NUM-ENTRIES(aux_lsdoctos,","):
            
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrdocmto",
                                         INPUT "",
                                         INPUT ENTRY(aux_contador,
                                                     aux_lsdoctos,",")).

            END.
        END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE enviar-cip:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                        RUN STORED-PROCEDURE pc_registra_tit_cip_online  aux_handproc = PROC-HANDLE
                        (INPUT par_cdcooper,
                         INPUT par_nrdconta,
                         OUTPUT 0, 
                         OUTPUT "").

                        CLOSE STORED-PROC pc_registra_tit_cip_online 
                                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            
                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    RETURN "OK".
  
END PROCEDURE.

/******************************************************************************/
/**           Procedure para retornar dados para geracao de boletos          **/
/******************************************************************************/
PROCEDURE gera-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldsacad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-blt.
    DEF OUTPUT PARAM TABLE FOR tt-sacados-blt.

    DEF VAR aux_intipcob         AS INTEGER                         NO-UNDO.
    DEF VAR aux_intipemi         AS INTEGER                         NO-UNDO.
    DEF VAR aux_nrconven         AS INTEGER                         NO-UNDO.
            
    DEF VAR aux_qtminneg         AS INT                             NO-UNDO.
    DEF VAR aux_qtmaxneg         AS INT                             NO-UNDO.
    DEF VAR aux_valormin         AS DEC                             NO-UNDO.
    DEF VAR aux_textodia         AS CHAR                            NO-UNDO.
    DEF VAR aux_flprotes         AS LOG                             NO-UNDO.
    DEF VAR aux_flgregon         AS LOG                             NO-UNDO.
    DEF VAR aux_flgpgdiv         AS LOG                             NO-UNDO.
    DEF VAR aux_flpersms         AS INT                             NO-UNDO.
    DEF VAR aux_fllindig         AS INT                             NO-UNDO.
    DEF VAR aux_flsitsms         AS INT                             NO-UNDO.
    DEF VAR aux_idcontrato       AS INT                             NO-UNDO.
            
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-blt.
    EMPTY TEMP-TABLE tt-sacados-blt.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Carregar dados para geracao de boleto bancario".
    
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        IF crapass.idastcjt = 0 THEN
        DO:
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.cdsitsnh = 1      /*      AND
                       crapsnh.flgbolet = TRUE   */      NO-LOCK NO-ERROR.
        END.
        ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                     crapsnh.nrdconta = par_nrdconta AND
                                     crapsnh.tpdsenha = 1            AND
                                     crapsnh.cdsitsnh = 1      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    END.
                       
    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta sem permissao para emitir/consultar " +
                                  "boleto.\nAssine o termo de adesao na " +
                                  "Cooperativa.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.
    /*ELSE IF crapsnh.vllbolet = 0 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Limite do valor maximo do " +
                                  "boleto nao cadastrado.\nEntre em " +
                                  "contato com seu PA.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.*/
        
    IF  par_vldsacad < 2 THEN /* Quando receber valor 2 nao deve consultar sacados */
        DO:
            RUN seleciona-sacados (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_nmdatela,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT par_idseqttl,
                                   INPUT "",
                                   INPUT par_vldsacad,
                                   INPUT FALSE,
								   INPUT 0,
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-sacados-blt).
                                 
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                    IF  AVAILABLE tt-erro  THEN
                        aux_dscritic = tt-erro.dscritic.
                    ELSE        
                        aux_dscritic = "Nao foi possivel concluir a requisicao3".
                
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
            
                    RETURN "NOK".
                END.

            IF  par_vldsacad = 1  THEN
                DO:                
                    FIND FIRST tt-sacados-blt NO-LOCK NO-ERROR.
            
                    IF  NOT AVAILABLE tt-sacados-blt  THEN
                        DO: 
                            ASSIGN aux_cdcritic = 0 
                                   aux_dscritic = "Nao foram encontrados registros de" +
                                                  " Pagadores.\nEfetue o cadastro de " +
                                                  "pagador na secao " + '"BOLETO"' + 
                                                  " no item " + '"CADASTRAR/' + 
                                                  'ALTERAR PAGADOR".'.
                       
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                                                   
                            IF  par_flgerlog  THEN
                                RUN proc_gerar_log (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT aux_dscritic,
                                                    INPUT aux_dsorigem,
                                                    INPUT aux_dstransa,
                                                    INPUT FALSE,
                                                    INPUT par_idseqttl,
                                                    INPUT par_nmdatela,
                                                    INPUT par_nrdconta,
                                                   OUTPUT aux_nrdrowid).
                                           
                            RETURN "NOK".
                        END.
                END.
        END.
         
    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                             crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).       

            RETURN "NOK".
        END.
    
    RUN verifica-convenios (INPUT par_cdcooper,
                            INPUT par_nrdconta,
                           OUTPUT aux_intipcob,
                           OUTPUT aux_intipemi).

    ASSIGN aux_flserasa = FALSE
               aux_flprotes = FALSE
               aux_flgregon = FALSE
               aux_flgpgdiv = FALSE.

    FOR EACH  crapceb WHERE crapceb.cdcooper = par_cdcooper     AND 
                            crapceb.nrdconta = par_nrdconta     AND
                            crapceb.insitceb = 1 /* Somente ativos */ NO-LOCK
	   ,FIRST  crapcco WHERE crapcco.cdcooper = crapceb.cdcooper AND
	                         crapcco.nrconven = crapceb.nrconven AND
                           crapcco.cddbanco = 85               AND /*Cecred*/
							             crapcco.flginter = TRUE NO-LOCK:

        

    IF aux_flgregon = FALSE THEN
       IF crapcco.dsorgarq = "INTERNET" THEN
          aux_flgregon = crapceb.flgregon.

    IF aux_flgpgdiv = FALSE THEN
       IF crapcco.dsorgarq = "INTERNET" THEN
          aux_flgpgdiv = crapceb.flgpgdiv.

    IF aux_flprotes = FALSE THEN
       aux_flprotes = crapceb.flprotes.

		IF aux_flserasa = FALSE THEN
        ASSIGN aux_nrconven = crapcco.nrconven
               aux_flserasa = crapceb.flserasa.

    END.

    IF  aux_nrconven > 0 THEN
        FIND crapcco WHERE crapcco.cdcooper = par_cdcooper AND
                           crapcco.nrconven = aux_nrconven
                           NO-LOCK NO-ERROR.

    IF  aux_intipcob = 0  THEN
        DO:
            ASSIGN aux_cdcritic = 563 
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.

    FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                             crapenc.nrdconta = par_nrdconta AND
                             crapenc.idseqttl = 1            NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapenc  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Endereco nao cadastrado.".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).

            RETURN "NOK".
        END.
       

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_busca_param_negativ
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT "",
                                OUTPUT 0,
                                OUTPUT 0,
                                OUTPUT 0,   
                                OUTPUT "", 
                                OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_busca_param_negativ
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dscritic = ""

           aux_dscritic = pc_busca_param_negativ.pr_dscritic
                              WHEN pc_busca_param_negativ.pr_dscritic <> ?

           aux_qtminneg = pc_busca_param_negativ.pr_qtminimo_negativacao
                              WHEN pc_busca_param_negativ.pr_qtminimo_negativacao <> ?

           aux_qtmaxneg = pc_busca_param_negativ.pr_qtmaximo_negativacao
                              WHEN pc_busca_param_negativ.pr_qtmaximo_negativacao <> ?

           aux_valormin = pc_busca_param_negativ.pr_vlminimo_boleto
                              WHEN pc_busca_param_negativ.pr_vlminimo_boleto <> ?

           aux_textodia = pc_busca_param_negativ.pr_dstexto_dia
                              WHEN pc_busca_param_negativ.pr_dstexto_dia <> ?.

    /* Verificar serviço de SMS*/
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
                                                  
    RUN STORED-PROCEDURE pc_verifar_serv_sms
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper  /* pr_cdcooper  */
                                            ,INPUT par_nrdconta  /* pr_nrdconta  */
                                            ,INPUT 'INTERNETBANK'/* pr_nmdatela  */
                                            ,INPUT 3             /* pr_idorigem  */
                                            /*----> OUT <-----*/ 
                                            ,OUTPUT 0            /* pr_idcontrato */
                                            ,OUTPUT 0            /* pr_flsitsms */ 
                                            ,OUTPUT ""           /* pr_dsalerta */ 
                                            ,OUTPUT 0            /* pr_cdcritic */ 
                                            ,OUTPUT "").         /* pr_dscritic */ 

    CLOSE STORED-PROC pc_verifar_serv_sms
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl}}

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_verifar_serv_sms.pr_cdcritic 
                          WHEN pc_verifar_serv_sms.pr_cdcritic <> ?
           aux_dscritic = pc_verifar_serv_sms.pr_dscritic 
                          WHEN pc_verifar_serv_sms.pr_dscritic <> ?.

    IF aux_dscritic <> "" THEN
      DO:

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
                         
          IF  par_flgerlog  THEN
              RUN proc_gerar_log (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT aux_dscritic,
                                  INPUT aux_dsorigem,
                                  INPUT aux_dstransa,
                                  INPUT FALSE,
                                  INPUT par_idseqttl,
                                  INPUT par_nmdatela,
                                  INPUT par_nrdconta,
                                 OUTPUT aux_nrdrowid).

          RETURN "NOK".          
      END. 
            
    ASSIGN aux_flsitsms = 0
           aux_idcontrato = 0
           aux_flsitsms = pc_verifar_serv_sms.pr_flsitsms 
                          WHEN pc_verifar_serv_sms.pr_flsitsms <> ?
           aux_idcontrato = pc_verifar_serv_sms.pr_idcontrato 
                          WHEN pc_verifar_serv_sms.pr_idcontrato <> ?.
    
    /* Se retornou numero de contrato é pq existe contrato ativo */
    ASSIGN aux_flpersms = 0.
    IF aux_idcontrato > 0 AND 
       aux_flsitsms = 1 THEN
    DO:
      ASSIGN aux_flpersms = 1.
    END.  
      
      
    /* Verificar se coop permite enviar linha digitavel por email  */
    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_verif_permite_lindigi
        aux_handproc = PROC-HANDLE NO-ERROR
                                ( INPUT par_cdcooper,
                                 OUTPUT 0,            /* pr_flglinha_digitavel */ 
                                 OUTPUT "").          /* pr_dscritic */

    CLOSE STORED-PROC pc_verif_permite_lindigi
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dscritic = ""
           aux_fllindig = 0 
           aux_fllindig = pc_verif_permite_lindigi.pr_flglinha_digitavel
                              WHEN pc_verif_permite_lindigi.pr_flglinha_digitavel <> ?
           aux_dscritic = pc_verif_permite_lindigi.pr_dscritic
                              WHEN pc_verif_permite_lindigi.pr_dscritic <> ?.       
      
    CREATE tt-dados-blt.
    ASSIGN tt-dados-blt.vllbolet = crapsnh.vllbolet
           tt-dados-blt.dsdinstr = crapsnh.dsdinstr
           tt-dados-blt.dtmvtolt = aux_datdodia
           tt-dados-blt.nrdctabb = crapcco.nrdctabb
           tt-dados-blt.nrconven = crapcco.nrconven
           tt-dados-blt.cddbanco = crapcco.cddbanco
           tt-dados-blt.flgregon = INT(aux_flgregon)
           tt-dados-blt.flgpgdiv = INT(aux_flgpgdiv)

        /* tt-dados-blt.cdcartei = crapcco.nrvarcar*/
           tt-dados-blt.cdcartei = crapcco.cdcartei
           tt-dados-blt.nrvarcar = crapcco.nrvarcar

           tt-dados-blt.tamannro = crapcco.tamannro
           tt-dados-blt.dsendere = REPLACE(TRIM(crapenc.dsendere),"&","%26")
           tt-dados-blt.nrendere = crapenc.nrendere
           tt-dados-blt.nmbairro = REPLACE(crapenc.nmbairro,"&","%26")
           tt-dados-blt.nmcidade = REPLACE(crapenc.nmcidade,"&","%26")
           tt-dados-blt.cdufende = crapenc.cdufende
           tt-dados-blt.nrcepend = crapenc.nrcepend
           tt-dados-blt.flpersms = aux_flpersms
           tt-dados-blt.fllindig = aux_fllindig
           tt-dados-blt.intipcob = aux_intipcob  /* 1-Cob S/ Registro 
                                                    2-Cob C/ Registro
                                                    3-Todos */
           tt-dados-blt.intipemi = aux_intipemi. /* 0 - sem convenio 
                                                    1 - cooperado emite expede
                                                    2 - banco emite expede
                                                    3 - cooperado + banco */
          
    IF  crapass.inpessoa = 1  THEN
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
                       
            IF  NOT AVAILABLE crapttl  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Titular nao cadastrado.".
           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                   
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).

                    RETURN "NOK".
                END.
        
            ASSIGN tt-dados-blt.nmprimtl = REPLACE(crapttl.nmextttl,"&","%26")
                   tt-dados-blt.nrcpfcgc = crapttl.nrcpfcgc
                   tt-dados-blt.inpessoa = crapttl.inpessoa.
        END.
    ELSE    
        ASSIGN tt-dados-blt.nmprimtl = REPLACE(crapass.nmprimtl,"&","%26")
               tt-dados-blt.nrcpfcgc = crapass.nrcpfcgc
               tt-dados-blt.inpessoa = crapass.inpessoa.


        /* Serasa */
        ASSIGN tt-dados-blt.flserasa = INT(aux_flserasa)
               tt-dados-blt.qtminneg = aux_qtminneg
               tt-dados-blt.qtmaxneg = aux_qtmaxneg
               tt-dados-blt.valormin = aux_valormin
               tt-dados-blt.textodia = aux_textodia
               tt-dados-blt.flprotes = INT(aux_flprotes).

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).


    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**              Procedure para selecionar pagadoress da consulta               **/
/******************************************************************************/
PROCEDURE seleciona-sacados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsacad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitsac LIKE crapsab.cdsitsac             NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrconins AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-sacados-blt.

    DEF VAR aux_dsinssac AS CHAR                                    NO-UNDO.
    DEF VAR aux_errodcep AS LOGICAL                                 NO-UNDO.
    DEF VAR aux_errodpnp AS LOGICAL                                 NO-UNDO.

    DEF VAR aux_dsdemail AS CHAR                                    NO-UNDO.

	DEF VAR aux_qtregcon AS INTEGER									NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-sacados-blt.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Consulta de pagadores para boleto bancario".
    
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        IF crapass.idastcjt = 0 THEN
        DO:
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.cdsitsnh = 1        /*    AND
                       crapsnh.flgbolet = TRUE     */    NO-LOCK NO-ERROR.
        END.
        ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                     crapsnh.nrdconta = par_nrdconta AND
                                     crapsnh.tpdsenha = 1            AND
                                     crapsnh.cdsitsnh = 1      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    END.
                       
    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta sem permissao para emitir/consultar " +
                                  "boleto.\nAssine o termo de adesao na " +
                                  "Cooperativa.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.
        
    ASSIGN aux_qtregcon = 0.

    FOR EACH crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                           crapsab.nrdconta = par_nrdconta AND
                           crapsab.nmdsacad MATCHES "*" + par_nmdsacad + "*" AND 
                           (( par_nrconins > 0 AND STRING(crapsab.nrinssac) MATCHES "*" + STRING( par_nrconins ) + "*" ) OR par_nrconins = 0)
                           NO-LOCK BY crapsab.nmdsacad:
        
        /* Se nao foi passado nada para a pesquisa limito os resultados a 400 senao 2000 */
        IF TRIM(par_nmdsacad) = "" AND
           aux_qtregcon >= 400     THEN
           DO:			   
              LEAVE.
           END.
        ELSE
           DO:
              IF TRIM(par_nmdsacad) <> "" AND
                 aux_qtregcon >= 2000     THEN
                 DO:
                   LEAVE.
                 END.
           END.

        ASSIGN aux_qtregcon = aux_qtregcon + 1.
        
        IF  par_cdsitsac <> 0 AND crapsab.cdsitsac <> par_cdsitsac  THEN
            NEXT.
                                                      /* 80835988953 */
        IF  crapsab.cdtpinsc = 1 AND crapsab.nrinssac <= 99999999999  THEN
            aux_dsinssac = STRING(crapsab.nrinssac,
                                  "99999999999").
        ELSE
            aux_dsinssac = STRING(crapsab.nrinssac,
                                  "99999999999999").
                                

        ASSIGN aux_errodcep = FALSE
               aux_errodpnp = FALSE.

        IF crapsab.nrcepsac > 0 THEN
        DO:

            FIND FIRST crapdne WHERE crapdne.nrceplog = crapsab.nrcepsac AND
                                     crapdne.idoricad = 1     /* Correios */
                                     NO-LOCK NO-ERROR.
            IF  NOT AVAIL(crapdne) THEN
                DO:
                    FIND FIRST crapdne WHERE crapdne.nrceplog = crapsab.nrcepsac AND
                                             crapdne.idoricad = 2       /* Ayllos */
                                             NO-LOCK NO-ERROR.
                    IF  NOT AVAIL(crapdne) THEN
                        DO:
                            ASSIGN aux_errodcep = TRUE.
                        END.
                    ELSE
                        DO:
                            IF TRIM(crapdne.cduflogr) <> TRIM(crapsab.cdufsaca) OR
                               TRIM(crapdne.nmextcid) <> TRIM(crapsab.nmcidsac) THEN
                               aux_errodcep = TRUE.
                        END.
                END.
           ELSE
                DO:
                    IF TRIM(crapdne.cduflogr) <> TRIM(crapsab.cdufsaca) OR
                       TRIM(crapdne.nmextcid) <> TRIM(crapsab.nmcidsac) THEN
                       aux_errodcep = TRUE.
                END.

            IF NOT aux_errodcep THEN
            DO:
                FIND FIRST crappnp WHERE 
                           crappnp.nmextcid = crapsab.nmcidsac AND
                           crappnp.cduflogr = crapsab.cdufsaca NO-LOCK NO-ERROR.

                IF AVAIL crappnp THEN
                   ASSIGN aux_errodpnp = TRUE.
            END.
        END.
        ELSE
            ASSIGN aux_errodcep = TRUE.
                           

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

        RUN STORED-PROCEDURE pc_busca_emails_pagador
            aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT crapsab.cdcooper,
                                     INPUT crapsab.nrdconta,
                                     INPUT crapsab.nrinssac,
                                    OUTPUT "",  /* pr_dsdemail */
                                    OUTPUT "",  /* pr_des_erro */
                                    OUTPUT ""). /* pr_dscritic */

        CLOSE STORED-PROC pc_busca_emails_pagador
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dsdemail = ""
               aux_dscritic = ""
               aux_deserro  = ""
               aux_dsdemail = pc_busca_emails_pagador.pr_dsdemail
                                  WHEN pc_busca_emails_pagador.pr_dsdemail <> ?
               aux_dscritic = pc_busca_emails_pagador.pr_dscritic
                                  WHEN pc_busca_emails_pagador.pr_dscritic <> ?
               aux_deserro = pc_busca_emails_pagador.pr_des_erro
                                  WHEN pc_busca_emails_pagador.pr_des_erro <> ?.

                           
        CREATE tt-sacados-blt.
        ASSIGN tt-sacados-blt.nmdsacad = 
                 (IF aux_errodcep THEN "** Verificar endereço ** - " 
                  ELSE "") + 
                 (IF aux_errodpnp THEN "** Praça nao protesta ** - " 
                  ELSE "") + 
                  REPLACE(crapsab.nmdsacad,"&","%26")
               tt-sacados-blt.nmsacado = REPLACE(crapsab.nmdsacad,"&","%26")
               tt-sacados-blt.dsflgend = aux_errodcep
               tt-sacados-blt.dsflgprc = aux_errodpnp
               tt-sacados-blt.nrinssac = crapsab.nrinssac
               tt-sacados-blt.cdtpinsc = crapsab.cdtpinsc
               tt-sacados-blt.dsinssac = aux_dsinssac
               tt-sacados-blt.nrctasac = crapsab.nrctasac
               tt-sacados-blt.dsctasac = TRIM(STRING(crapsab.nrctasac,
                                                     "zzzz,zz9,9"))
               tt-sacados-blt.cdsitsac = crapsab.cdsitsac
               tt-sacados-blt.dssitsac = IF crapsab.cdsitsac = 1 THEN
                                            "Ativo"
                                         ELSE
                                         IF crapsab.cdsitsac = 2 THEN
                                            "Inativo"
                                         ELSE
                                            ""
               tt-sacados-blt.dsdemail = aux_dsdemail
               tt-sacados-blt.flgemail = (IF TRIM(aux_dsdemail) <> "" THEN 
                                             TRUE
                                          ELSE 
                                             FALSE).
                                       
    END. /** Fim do FOR EACH crapsab **/
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK". 

END PROCEDURE.


/******************************************************************************/
/**            Procedure para validar e carregar dados do sacado             **/
/******************************************************************************/
PROCEDURE valida-sacado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinssac AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgvalid AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-dados-sacado-blt.

    DEF VAR aux_dscriend AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdemail AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados-sacado-blt.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Carregar dados de pagador para boleto bancario".
 
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        IF crapass.idastcjt = 0 THEN
        DO:
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.cdsitsnh = 1       /*     AND
                       crapsnh.flgbolet = TRUE    */     NO-LOCK NO-ERROR.
        END.
        ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                     crapsnh.nrdconta = par_nrdconta AND
                                     crapsnh.tpdsenha = 1            AND
                                     crapsnh.cdsitsnh = 1      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    END.
                       
    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta sem permissao para emitir/consultar " +
                                  "boleto.\nAssine o termo de adesao na " +
                                  "Cooperativa.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.
        
    FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                       crapsab.nrdconta = par_nrdconta AND
                       crapsab.nrinssac = par_nrinssac NO-LOCK NO-ERROR.
                             
    IF  NOT AVAILABLE crapsab  THEN
        DO:
            IF  NOT par_flgvalid  THEN
                DO:
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT "",
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT TRUE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                               
                    RETURN "OK".
                END.
                
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Pagador informado nao possui registro.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
            
            RETURN "NOK".
        END.

    /** Se ja foi gerado algum boleto, o sacado nao pode ser removido **/
    FIND FIRST crapcob WHERE crapcob.cdcooper = par_cdcooper AND
                             crapcob.nrdconta = par_nrdconta AND
                             crapcob.nrinssac = par_nrinssac NO-LOCK NO-ERROR.

    ASSIGN aux_dscriend = "".

    IF crapsab.nrcepsac > 0 THEN
    DO:

        FIND FIRST crapdne WHERE crapdne.nrceplog = crapsab.nrcepsac AND
                                 crapdne.idoricad = 1     /* Correios */
                                 NO-LOCK NO-ERROR.
        IF  NOT AVAIL(crapdne) THEN
            DO:
                FIND FIRST crapdne WHERE crapdne.nrceplog = crapsab.nrcepsac AND
                                         crapdne.idoricad = 2       /* Ayllos */
                                         NO-LOCK NO-ERROR.
                IF  NOT AVAIL(crapdne) THEN
                    DO:
                        ASSIGN aux_dscriend = "CEP".
                    END.
                ELSE
                    DO:
                        IF TRIM(crapdne.cduflogr) <> TRIM(crapsab.cdufsaca) THEN
                           aux_dscriend = "UF".
            
                        IF TRIM(crapdne.nmextcid) <> TRIM(crapsab.nmcidsac) THEN
                           aux_dscriend = aux_dscriend + 
                                          (IF aux_dscriend <> "" THEN ";" ELSE "") +
                                          "CIDADE".
                    END.
            END.
        ELSE
            DO:
                IF TRIM(crapdne.cduflogr) <> TRIM(crapsab.cdufsaca) THEN
                   aux_dscriend = "UF".
    
                IF TRIM(crapdne.nmextcid) <> TRIM(crapsab.nmcidsac) THEN
                   aux_dscriend = aux_dscriend + 
                                  (IF aux_dscriend <> "" THEN ";" ELSE "") +
                                  "CIDADE".
            END.      
    END.
    ELSE
        ASSIGN aux_dscriend = "CEP".
                             
    CREATE tt-dados-sacado-blt.
    ASSIGN tt-dados-sacado-blt.cdcooper = par_cdcooper
           tt-dados-sacado-blt.nrdconta = par_nrdconta
           tt-dados-sacado-blt.cdtpinsc = crapsab.cdtpinsc
           tt-dados-sacado-blt.nrinssac = crapsab.nrinssac
           tt-dados-sacado-blt.nmdsacad = REPLACE(crapsab.nmdsacad,"&","%26")
           tt-dados-sacado-blt.dsendsac = REPLACE(crapsab.dsendsac,"&","%26")
           tt-dados-sacado-blt.nrendsac = crapsab.nrendsac
           tt-dados-sacado-blt.complend = REPLACE(crapsab.complend,"&","%26")
           tt-dados-sacado-blt.nmbaisac = REPLACE(crapsab.nmbaisac,"&","%26")
           tt-dados-sacado-blt.nmcidsac = REPLACE(crapsab.nmcidsac,"&","%26")
           tt-dados-sacado-blt.cdufsaca = crapsab.cdufsaca
           tt-dados-sacado-blt.nrcepsac = crapsab.nrcepsac
           tt-dados-sacado-blt.cdsitsac = crapsab.cdsitsac
           tt-dados-sacado-blt.dssitsac = IF crapsab.cdsitsac = 1 THEN
                                             "Ativo"
                                          ELSE
                                          IF crapsab.cdsitsac = 2 THEN
                                             "Inativo"
                                          ELSE
                                             ""
           tt-dados-sacado-blt.flgremov = (IF  AVAILABLE crapcob  THEN
                                              FALSE
                                           ELSE
                                              TRUE)
           tt-dados-sacado-blt.dscriend = aux_dscriend
           tt-dados-sacado-blt.nrcelsac = crapsab.nrcelsac.

           
    /* Buscar o e-mail do pagador */       
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_busca_emails_pagador
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT crapsab.cdcooper,
                                 INPUT crapsab.nrdconta,
                                 INPUT crapsab.nrinssac,
                                OUTPUT "",  /* pr_dsdemail */
                                OUTPUT "",  /* pr_des_erro */
                                OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_busca_emails_pagador
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_dsdemail = ""
           aux_dscritic = ""
           aux_deserro  = ""
           aux_dsdemail = pc_busca_emails_pagador.pr_dsdemail
                              WHEN pc_busca_emails_pagador.pr_dsdemail <> ?
           aux_dscritic = pc_busca_emails_pagador.pr_dscritic
                              WHEN pc_busca_emails_pagador.pr_dscritic <> ?
           aux_deserro = pc_busca_emails_pagador.pr_des_erro
                              WHEN pc_busca_emails_pagador.pr_des_erro <> ?.
           
           
    ASSIGN tt-dados-sacado-blt.dsdemail = aux_dsdemail.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
                           
    RETURN "OK".
    
END PROCEDURE.


/******************************************************************************/
/**             Procedure para Cadastrar/Alterar/Excluir sacados             **/
/******************************************************************************/
PROCEDURE gerencia-sacados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdsacad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdtpinsc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrinssac AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsendsac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendsac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbaisac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepsac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidsac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufsaca AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitsac AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tprotina AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpinstru AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdemail AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcelsac AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_flgstcpf AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR aux_cdtpinsc AS INTE                                    NO-UNDO.
    DEF VAR aux_nrendsac AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcepsac AS INTE                                    NO-UNDO.
    DEF VAR aux_cdsitsac AS INTE                                    NO-UNDO.
    DEF VAR aux_ponteiro AS INTE                                    NO-UNDO.

    DEF VAR aux_nmdsacad AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendsac AS CHAR                                    NO-UNDO.
    DEF VAR aux_complend AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmbaisac AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmcidsac AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdufsaca AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdemail AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcelsac AS DECI                                    NO-UNDO.
    
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0088 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0090 AS HANDLE                                  NO-UNDO.
        
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF  par_tprotina = 0  THEN
                               "Cadastrar" 
                           ELSE
                           IF  par_tprotina = 1  THEN
                               "Alterar"
                           ELSE
                               "Excluir") + " pagador de boleto bancario"
           aux_flgtrans = FALSE.
           
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        IF crapass.idastcjt = 0 THEN
        DO:
    FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                       crapsnh.nrdconta = par_nrdconta AND
                       crapsnh.idseqttl = par_idseqttl AND  
                       crapsnh.tpdsenha = 1            AND
                       crapsnh.cdsitsnh = 1       /*     AND
                       crapsnh.flgbolet = TRUE    */     NO-LOCK NO-ERROR.
        END.
        ELSE
        DO:
            FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper AND
                                     crapsnh.nrdconta = par_nrdconta AND
                                     crapsnh.tpdsenha = 1            AND
                                     crapsnh.cdsitsnh = 1      
                                     NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
        END.
    END.
                       
    IF  NOT AVAILABLE crapsnh  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Conta sem permissao para emitir/consultar " +
                                  "boleto.\nAssine o termo de adesao na " +
                                  "Cooperativa.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.     
     
    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        IF  par_nrinssac <= 0  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o documento do pagador.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT 
            SET h-b1wgen9999.
    
        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.       
            END.

        RUN valida-cpf-cnpj IN h-b1wgen9999 (INPUT par_nrinssac,
                                            OUTPUT aux_flgstcpf,
                                            OUTPUT aux_inpessoa).

        DELETE PROCEDURE h-b1wgen9999.
            
        IF  NOT aux_flgstcpf AND par_cdsitsac <> 2 THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "CPF/CNPJ invalido.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.       
            END.
            
        IF  par_tprotina <> 2  THEN /* Excluir */
            DO:
        IF  crapass.inpessoa = 1  THEN
            DO:
                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                                   crapttl.nrdconta = par_nrdconta AND
                                   crapttl.nrcpfcgc = par_nrinssac 
                                   NO-LOCK NO-ERROR.
                               
                IF  AVAILABLE crapttl  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "CPF/CNPJ do pagador deve ser " +
                                              "diferente do CPF/CNPJ do " +
                                              "beneficiario.".
                     
                        UNDO TRANSACAO, LEAVE TRANSACAO.         
                    END.
            END.
        ELSE
            DO:
                IF  crapass.nrcpfcgc = par_nrinssac  THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "CPF/CNPJ do pagador deve ser " +
                                              "diferente do CPF/CNPJ do " +
                                              "beneficiario.".
                        
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.  
            END.
        
        IF  par_cdtpinsc < 1 OR par_cdtpinsc > 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Tipo de documento invalido.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        IF  TRIM(par_nmdsacad) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o nome do pagador.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.

        IF  TRIM(par_dsendsac) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o endereco do pagador.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        IF LENGTH(par_dsendsac) > 55 THEN   
           DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Endereco deve possuir apenas 55 caracteres.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
           END.            
            
        IF  par_nrcepsac <= 0  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o CEP do pagador.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.    
            
        /* Validar CEP apenas 8 digitos */
        IF  LENGTH(par_nrcepsac) > 8  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "CEP invalido.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
        /***********/

        IF  TRIM(par_nmbaisac) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o bairro do pagador.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        IF  TRIM(par_nmcidsac) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe a cidade do pagador.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.    

        IF  TRIM(par_cdufsaca) = ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Informe o estado do pagador.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.
            
        IF  par_cdsitsac < 1 OR par_cdsitsac > 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Situacao invalida.".
                       
                UNDO TRANSACAO, LEAVE TRANSACAO.
            END.        
            END.
        
        IF  par_tprotina = 0  THEN /** Cadastrar **/
            DO:

                FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                                   crapsab.nrdconta = par_nrdconta AND
                                   crapsab.nrinssac = par_nrinssac 
                                   NO-LOCK NO-ERROR.

                IF  AVAIL crapsab THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Pagador informado ja existe.".
    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.

                CREATE crapsab.
                ASSIGN crapsab.cdcooper = par_cdcooper
                       crapsab.nrdconta = par_nrdconta
                       crapsab.nrinssac = par_nrinssac
                       crapsab.cdtpinsc = par_cdtpinsc
                       crapsab.nmdsacad = TRIM(CAPS(par_nmdsacad))
                       crapsab.dsendsac = TRIM(CAPS(par_dsendsac))
                       crapsab.nrendsac = par_nrendsac
                       crapsab.nrcepsac = par_nrcepsac
                       crapsab.complend = par_complend
                       crapsab.nmbaisac = TRIM(CAPS(par_nmbaisac))
                       crapsab.nmcidsac = TRIM(CAPS(par_nmcidsac))
                       crapsab.cdufsaca = TRIM(CAPS(par_cdufsaca))
                       crapsab.cdsitsac = par_cdsitsac
                       crapsab.cdoperad = par_cdoperad
                       crapsab.dtmvtolt = par_dtmvtolt
                       crapsab.hrtransa = TIME
                       crapsab.nrcelsac = par_nrcelsac.
                       
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

                RUN STORED-PROCEDURE pc_atualiza_email_pagador
                    aux_handproc = PROC-HANDLE NO-ERROR
                                            (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrinssac,
                                             INPUT par_dsdemail,
                                            OUTPUT "",  /* pr_des_erro */
                                            OUTPUT ""). /* pr_dscritic */

                CLOSE STORED-PROC pc_atualiza_email_pagador
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                ASSIGN aux_dscritic = ""
                       aux_deserro  = ""
                       aux_dscritic = pc_atualiza_email_pagador.pr_dscritic
                                          WHEN pc_atualiza_email_pagador.pr_dscritic <> ?
                       aux_deserro = pc_atualiza_email_pagador.pr_des_erro
                                          WHEN pc_atualiza_email_pagador.pr_des_erro <> ?.


                IF aux_deserro <> "OK" THEN
                DO:
                    IF TRIM(aux_dscritic) <> "" THEN
                        ASSIGN aux_dscritic = "Erro na atualizacao de e-mail do pagador".
                    UNDO TRANSACAO, LEAVE TRANSACAO.
                END.
                 
            END.
        ELSE
            DO:
                DO aux_contador = 1 TO 10:
                
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "".
                           
                    FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                                       crapsab.nrdconta = par_nrdconta AND
                                       crapsab.nrinssac = par_nrinssac 
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                       
                    IF  NOT AVAILABLE crapsab  THEN
                        DO:
                            IF  LOCKED crapsab  THEN
                                DO:
                                    aux_dscritic = "Dados do pagador estao " +
                                                   "sendo alterados no " +
                                                   "momento.".
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                            ELSE
                                aux_dscritic = "Pagador informado nao esta " +
                                               "cadastrado.".           
                        END.
                       
                    LEAVE.
                       
                END. /** Fim do DO ... TO **/

                IF  aux_dscritic <> ""  THEN
                    UNDO TRANSACAO, LEAVE TRANSACAO.
            
                IF  par_tprotina = 1  THEN /** Alterar **/
                DO:
                    ASSIGN aux_cdtpinsc     = crapsab.cdtpinsc
                           aux_nmdsacad     = crapsab.nmdsacad
                           aux_dsendsac     = crapsab.dsendsac
                           aux_nrendsac     = crapsab.nrendsac
                           aux_nrcepsac     = crapsab.nrcepsac
                           aux_complend     = crapsab.complend
                           aux_nmbaisac     = crapsab.nmbaisac
                           aux_nmcidsac     = crapsab.nmcidsac
                           aux_cdufsaca     = crapsab.cdufsaca
                           aux_cdsitsac     = crapsab.cdsitsac
                           aux_nrcelsac     = crapsab.nrcelsac
                           crapsab.cdtpinsc = par_cdtpinsc
                           crapsab.nmdsacad = CAPS(par_nmdsacad)
                           crapsab.dsendsac = CAPS(par_dsendsac)
                           crapsab.nrendsac = par_nrendsac
                           crapsab.nrcepsac = par_nrcepsac
                           crapsab.complend = par_complend
                           crapsab.nmbaisac = CAPS(par_nmbaisac)
                           crapsab.nmcidsac = CAPS(par_nmcidsac)
                           crapsab.cdufsaca = CAPS(par_cdufsaca)
                           crapsab.cdsitsac = par_cdsitsac
                           crapsab.cdoperad = par_cdoperad
                           crapsab.dtmvtolt = par_dtmvtolt
                           crapsab.hrtransa = TIME
                           crapsab.nrcelsac = par_nrcelsac.

                    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

                    RUN STORED-PROCEDURE pc_atualiza_email_pagador
                        aux_handproc = PROC-HANDLE NO-ERROR
                                                (INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrinssac,
                                                 INPUT par_dsdemail,
                                                OUTPUT "",  /* pr_des_erro */
                                                OUTPUT ""). /* pr_dscritic */

                    CLOSE STORED-PROC pc_atualiza_email_pagador
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

                    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

                    ASSIGN aux_dscritic = ""
                           aux_deserro  = ""
                           aux_dscritic = pc_atualiza_email_pagador.pr_dscritic
                                              WHEN pc_atualiza_email_pagador.pr_dscritic <> ?
                           aux_deserro = pc_atualiza_email_pagador.pr_des_erro
                                              WHEN pc_atualiza_email_pagador.pr_des_erro <> ?.


                    IF aux_deserro <> "OK" THEN
                    DO:
                        IF TRIM(aux_dscritic) <> "" THEN
                            ASSIGN aux_dscritic = "Erro na atualizacao de e-mail do pagador".
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.


                    /* se houver titulos em aberto, gravar no log do titulo
                       que o cooperado alterou os dados do sacado */

                    RUN sistema/generico/procedures/b1wgen0088.p
                        PERSISTENT SET h-b1wgen0088.

                    IF  NOT VALID-HANDLE(h-b1wgen0088) THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Handle invalido para b1wgen0088.".
                            UNDO TRANSACAO, LEAVE TRANSACAO.       
                        END.

                    FOR EACH crapcco WHERE
                             crapcco.cdcooper = par_cdcooper
                         AND crapcco.flgregis = TRUE
                         NO-LOCK
                       ,EACH crapceb WHERE
                             crapceb.cdcooper = crapcco.cdcooper
                         AND crapceb.nrconven = crapcco.nrconven
                         AND crapceb.nrdconta = par_nrdconta
                         NO-LOCK 
                       ,EACH crapcob WHERE
                             crapcob.cdcooper = crapceb.cdcooper
                         AND crapcob.nrdconta = crapceb.nrdconta
                         AND crapcob.nrcnvcob = crapceb.nrconven
                         AND crapcob.nrinssac = par_nrinssac
                         AND crapcob.incobran = 0
                         AND crapcob.insitcrt = 0
                         NO-LOCK:

                        /* alteração normal */
                        IF  par_tpinstru = 0 THEN
                            DO:
                                CREATE crapcol.
                                ASSIGN crapcol.cdcooper = crapcob.cdcooper
                                       crapcol.nrdconta = crapcob.nrdconta
                                       crapcol.nrdocmto = crapcob.nrdocmto
                                       crapcol.nrcnvcob = crapcob.nrcnvcob
                                       crapcol.dslogtit = "Alteracao de dados do pagador"
                                       crapcol.cdoperad = par_cdoperad
                                       crapcol.dtaltera = TODAY
                                       crapcol.hrtransa = TIME.
                            END.

                        /* instrução comandada pelo cooperado */
                        IF  par_tpinstru = 1 THEN
                            DO:
                                RUN inst-alt-outros-dados IN h-b1wgen0088
                                    (INPUT crapcob.cdcooper,
                                     INPUT crapcob.nrdconta,
                                     INPUT crapcob.nrcnvcob,
                                     INPUT crapcob.nrdocmto,
                                     INPUT 31, /* cnab 240 - alt outros dados */
                                     INPUT TODAY,
                                     INPUT par_cdoperad,
                                     INPUT 0, /* aux_nrremess */
                                    OUTPUT aux_dscritic,
                                    INPUT-OUTPUT TABLE tt-lat-consolidada ).

                                IF  TRIM(aux_dscritic) <> "" THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 0.
                                        UNDO TRANSACAO, LEAVE TRANSACAO.
                                    END.

                                
                            END.

                    END.

                    /* Inicio - Rotina para cobranca tarifa */

                    IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
                        RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT SET h-b1wgen0090.
                    
                    RUN efetua-lancamento-tarifas-lat IN h-b1wgen0090(INPUT par_cdcooper,
                                                                      INPUT par_dtmvtolt,
                                                                      INPUT-OUTPUT TABLE tt-lat-consolidada ).
            
                    IF  VALID-HANDLE(h-b1wgen0090) THEN
                        RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT SET h-b1wgen0090.
                
                    /* Fim - Rotina para cobranca tarifa */

                    IF  VALID-HANDLE(h-b1wgen0088) THEN
                        DELETE PROCEDURE h-b1wgen0088.
                END.
                ELSE
                IF  par_tprotina = 2  THEN /** Excluir **/
                    DO:
                        FIND FIRST crapcob WHERE 
                                   crapcob.cdcooper = par_cdcooper AND
                                   crapcob.nrdconta = par_nrdconta AND
                                   crapcob.nrinssac = par_nrinssac 
                                   NO-LOCK NO-ERROR. 
                                      
                        IF  AVAILABLE crapcob  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "O pagador ja possui um " +
                                                      "boleto cadastrado. " +
                                                      "Exclusao nao permitida.".
                    
                                UNDO TRANSACAO, LEAVE TRANSACAO.
                            END.
                            
                        DELETE crapsab.       
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Tipo de rotina invalido.".
                    
                        UNDO TRANSACAO, LEAVE TRANSACAO.
                    END.
            END.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/
            
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao4.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).

                    RUN proc_gerar_log_item 
                       (INPUT aux_nrdrowid,
                        INPUT "nrinssac",
                        INPUT "",
                        INPUT IF  par_cdtpinsc = 1  THEN 
                                  STRING(STRING(par_nrinssac,
                                     "99999999999"),"xxx.xxx.xxx-xx") 
                              ELSE
                                  STRING(STRING(par_nrinssac,
                                     "99999999999999"),"xx.xxx.xxx/xxxx-xx")).
                END.
                
            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            RUN proc_gerar_log_item 
                       (INPUT aux_nrdrowid,
                        INPUT "nrinssac",
                        INPUT "",
                        INPUT IF  par_cdtpinsc = 1  THEN 
                                  STRING(STRING(par_nrinssac,
                                     "99999999999"),"xxx.xxx.xxx-xx") 
                              ELSE
                                  STRING(STRING(par_nrinssac,
                                     "99999999999999"),"xx.xxx.xxx/xxxx-xx")). 

            IF  par_tprotina = 0 OR par_tprotina = 1  THEN
                DO:
                    IF  aux_cdtpinsc <> par_cdtpinsc  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "cdtpinsc",
                                                 INPUT TRIM(STRING(aux_cdtpinsc,
                                                            "z")),
                                                 INPUT TRIM(STRING(par_cdtpinsc,
                                                            "z"))).
                    
                    IF  aux_nmdsacad <> par_nmdsacad  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "nmdsacad",
                                                 INPUT aux_nmdsacad,
                                                 INPUT par_nmdsacad).
                                                 
                    IF  aux_dsendsac <> par_dsendsac  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "dsendsac",
                                                 INPUT aux_dsendsac,
                                                 INPUT par_dsendsac).
                                                                              
                    IF  aux_nrendsac <> par_nrendsac  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "nrendsac",
                                                 INPUT TRIM(STRING(aux_nrendsac,
                                                            "z,zzz,zzz,zzz")),
                                                 INPUT TRIM(STRING(par_nrendsac,
                                                            "z,zzz,zzz,zzz"))).
                                                                               
                    IF  aux_nrcepsac <> par_nrcepsac  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "nrcepsac",
                                                 INPUT TRIM(STRING(aux_nrcepsac,
                                                            "zzzzz,zzz")),
                                                 INPUT TRIM(STRING(par_nrcepsac,
                                                            "zzzzz,zzz"))).
                                                                               
                    IF  aux_complend <> par_complend  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "complend",
                                                 INPUT aux_complend,
                                                 INPUT par_complend).
                                                                               
                    IF  aux_nmbaisac <> par_nmbaisac  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "nmbaisac",
                                                 INPUT aux_nmbaisac,
                                                 INPUT par_nmbaisac).
                                                       
                    IF  aux_nmcidsac <> par_nmcidsac  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "nmcidsac",
                                                 INPUT aux_nmcidsac,
                                                 INPUT par_nmcidsac).
                                                                               
                    IF  aux_cdufsaca <> par_cdufsaca  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "cdufsaca",
                                                 INPUT aux_cdufsaca,
                                                 INPUT par_cdufsaca).
                                                                 
                    IF  aux_cdsitsac <> par_cdsitsac  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "cdsitsac",
                                                 INPUT TRIM(STRING(aux_cdsitsac,
                                                            "z")),
                                                 INPUT TRIM(STRING(par_cdsitsac,
                                                            "z"))).

                    IF  aux_nrcelsac <> par_nrcelsac  THEN
                        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                                 INPUT "nrcelsac",
                                                 INPUT TRIM(STRING(aux_nrcelsac)),
                                                 INPUT TRIM(STRING(par_nrcelsac))).
                END.
        END.
              
    RETURN "OK".
                
END PROCEDURE.


/******************************************************************************/
/**             Procedure para Cadastrar Instrucoes para Boletos             **/
/******************************************************************************/
PROCEDURE grava-instrucoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsdinstr AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_tpdinstr AS INTE                                    NO-UNDO.

    DEF VAR aux_dsdinstr AS CHAR                                    NO-UNDO.
    DEF VAR old_dsdinstr AS CHAR                                    NO-UNDO.   
    DEF VAR ent_dsdinstr AS CHAR                                    NO-UNDO.
    DEF VAR ent_dsdinfor AS CHAR                                    NO-UNDO.

    DEF VAR aux_idastcjt AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Cadastrar instrucoes ou informacoes " +
                          "para boleto bancario" 
           aux_flgtrans = FALSE
           aux_tpdinstr = INTEGER(ENTRY(1,par_dsdinstr,"|"))
           aux_dsdinstr = ENTRY(2,par_dsdinstr,"|").

    /* 1 - Instrucao, 2 - Informacao */
    IF aux_tpdinstr <> 1 AND aux_tpdinstr <> 2 THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo Instrucao ou Informacao nao permitida.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                END.
                
            RETURN "NOK".
        END.
           
    FIND FIRST crapass 
         WHERE crapass.cdcooper = par_cdcooper
           AND crapass.nrdconta = par_nrdconta 
           NO-LOCK NO-ERROR.

    IF AVAIL crapass THEN
    DO:
        ASSIGN aux_idastcjt = crapass.idastcjt.

    TRANSACAO:
    
    DO TRANSACTION ON ERROR UNDO TRANSACAO, LEAVE TRANSACAO:
    
        DO aux_contador = 1 TO 10:
        
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".
                   
                FOR EACH crapsnh FIELDS(dsdinstr)
                   WHERE crapsnh.cdcooper = par_cdcooper  AND
                         crapsnh.nrdconta = par_nrdconta  AND

                         /* Para operadores de PJ com 
                         Exigencia assinatura conjunta */
                        (aux_idastcjt = 1 OR

                         crapsnh.idseqttl = par_idseqttl) AND
                         crapsnh.tpdsenha = 1             AND
                               crapsnh.cdsitsnh = 1       /*     AND
                               crapsnh.flgbolet = TRUE    */     
                         EXCLUSIVE-LOCK:
                       
                    ASSIGN aux_flgtrans = TRUE
                           old_dsdinstr = crapsnh.dsdinstr.

                    /* se tiver apenas instrucoes */
                    IF NUM-ENTRIES(crapsnh.dsdinstr,";") <= 1  THEN
                        ASSIGN ent_dsdinstr = crapsnh.dsdinstr
                               ent_dsdinfor = "".    
                    ELSE
                        ASSIGN ent_dsdinstr = ENTRY(1,crapsnh.dsdinstr,";")
                               ent_dsdinfor = ENTRY(2,crapsnh.dsdinstr,";").

                    /* se for gravacao de Instrucoes */
                    IF aux_tpdinstr = 1 THEN
                        ASSIGN crapsnh.dsdinstr = aux_dsdinstr + ";" + 
                                                  ent_dsdinfor
                                   aux_dsdinstr = crapsnh.dsdinstr.
                    ELSE
                        ASSIGN crapsnh.dsdinstr = ent_dsdinstr + ";" +
                                                  aux_dsdinstr
                                   aux_dsdinstr = crapsnh.dsdinstr.
                END. /* FOR EACH crapsnh */

            LEAVE.
        
        END. /** Fim do DO ... TO **/

            IF  NOT aux_flgtrans  THEN
                ASSIGN aux_dscritic = "Conta sem permissao para emitir/" +
                                      "consultar boleto.\nAssine o termo de " +
                                      "adesao na Cooperativa.".

        IF  aux_dscritic <> ""  THEN
            UNDO TRANSACAO, LEAVE TRANSACAO.
        
        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANSACAO **/
    END. /* AVAIL crapass */
            
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                aux_dscritic = "Nao foi possivel concluir a requisicao5.".
                
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                               
            IF  par_flgerlog  THEN
                DO:
                    RUN proc_gerar_log (INPUT par_cdcooper,
                                        INPUT par_cdoperad,
                                        INPUT aux_dscritic,
                                        INPUT aux_dsorigem,
                                        INPUT aux_dstransa,
                                        INPUT FALSE,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT par_nrdconta,
                                       OUTPUT aux_nrdrowid).
                END.
                
            RETURN "NOK".
        END.
            
    IF  par_flgerlog  THEN
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
        
            IF  old_dsdinstr <> aux_dsdinstr  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "dsdinstr",
                                         INPUT aux_dsdinstr,
                                         INPUT par_dsdinstr).
        END.
              
    RETURN "OK".
                
END PROCEDURE.

PROCEDURE p_grava_boleto:

   DEF INPUT        PARAM p-cdcooper       AS INTE.
   DEF INPUT        PARAM p-nmdobnfc       AS CHAR.
   DEF INPUT        PARAM p-cod-agencia    AS INTE.
   DEF INPUT        PARAM p-nro-caixa      AS INTE.
   DEF INPUT        PARAM p-data-limite    AS DATE.

   DEF OUTPUT       PARAM TABLE FOR tt-consulta-blt.

   DEF VAR aux_nossonro AS CHAR FORMAT "x(19)" NO-UNDO.
   DEF VAR aux_flgdesco AS CHAR                NO-UNDO.
   DEF VAR aux_dsstaabr AS CHAR                NO-UNDO.
   DEF VAR aux_dsstacom AS CHAR                NO-UNDO.
   DEF VAR aux_dtsitcrt AS DATE                NO-UNDO.
   DEF VAR aux_nrcnvceb AS INTE                NO-UNDO.

   IF  NOT AVAILABLE crapcco  THEN
       DO:

           RETURN "NOK".
       END.
   
   IF   crapcco.flgutceb THEN
        DO:
            FIND LAST crapceb WHERE crapceb.cdcooper = crapcob.cdcooper AND
                                    crapceb.nrdconta = crapcob.nrdconta AND
                                    crapceb.nrconven = crapcob.nrcnvcob AND
                                    crapceb.insitceb = 1
                                    NO-LOCK USE-INDEX crapceb1 NO-ERROR.
             
            IF  NOT AVAILABLE crapceb  THEN
                DO:

                    RETURN "NOK".
                END.
                
            ASSIGN aux_nrcnvceb = crapceb.nrcnvceb
                   aux_nossonro = STRING(crapcob.nrcnvcob,"9999999") + 
                                  STRING(crapceb.nrcnvceb,"9999") +
                                  STRING(crapcob.nrdocmto,"999999").
        END.
    ELSE
        ASSIGN aux_nossonro = STRING(crapcob.nrdconta,"99999999") +
                              STRING(crapcob.nrdocmto,"999999999").

DO TRANSACTION:
    
     CREATE tt-consulta-blt.

     ASSIGN tt-consulta-blt.nmprimtl = REPLACE(p-nmdobnfc,"&","%26").

     /*  Verifica no Cadastro de Sacados Cobranca */
     
     FIND crapsab WHERE crapsab.cdcooper = crapcob.cdcooper AND
                        crapsab.nrdconta = crapcob.nrdconta AND
                        crapsab.nrinssac = crapcob.nrinssac NO-LOCK NO-ERROR.
     IF  AVAILABLE crapsab  THEN
         ASSIGN tt-consulta-blt.nmdsacad = REPLACE(crapsab.nmdsacad,"&","%26")
                tt-consulta-blt.dsendsac = IF crapsab.nrendsac = 0 THEN
                                              REPLACE(crapsab.dsendsac,"&","%26")
                                           ELSE
                                              REPLACE(crapsab.dsendsac,"&","%26")
                                              + ", " +
                                              TRIM(STRING(crapsab.nrendsac,
                                                         "zzzzz9"))
                tt-consulta-blt.complend = crapsab.complend
                tt-consulta-blt.nmbaisac = crapsab.nmbaisac
                tt-consulta-blt.nmcidsac = crapsab.nmcidsac
                tt-consulta-blt.cdufsaca = crapsab.cdufsaca
                tt-consulta-blt.nrcepsac = crapsab.nrcepsac.
     ELSE
         ASSIGN tt-consulta-blt.nmdsacad = REPLACE(crapcob.nmdsacad,"&","%26").


     ASSIGN tt-consulta-blt.nmdavali = REPLACE(crapcob.nmdavali,"&","%26")
            tt-consulta-blt.nrinsava = crapcob.nrinsava
            tt-consulta-blt.cdtpinav = crapcob.cdtpinav
            tt-consulta-blt.vlrjuros = crapcob.vljurpag
            tt-consulta-blt.vlrmulta = crapcob.vlmulpag.


     ASSIGN tt-consulta-blt.flserasa = crapcob.flserasa
            tt-consulta-blt.qtdianeg = crapcob.qtdianeg.

     ASSIGN tt-consulta-blt.cdcooper = crapcob.cdcooper
            tt-consulta-blt.nrdconta = crapcob.nrdconta
            tt-consulta-blt.idseqttl = crapcob.idseqttl
            tt-consulta-blt.nossonro = aux_nossonro
            tt-consulta-blt.incobran = IF  crapcob.incobran = 0  THEN
                                           "N"
                                       ELSE
                                       IF  crapcob.incobran = 3  THEN
                                           "B"
                                       ELSE
                                           "C"
            tt-consulta-blt.nrdocmto = crapcob.nrdocmto
            tt-consulta-blt.dsdoccop = crapcob.dsdoccop
            tt-consulta-blt.nrdctabb = crapcob.nrdctabb
            tt-consulta-blt.nrcpfcgc = crapass.nrcpfcgc
            tt-consulta-blt.inpessoa = crapass.inpessoa
            tt-consulta-blt.nrcnvcob = crapcob.nrcnvcob
            tt-consulta-blt.nrcnvceb = aux_nrcnvceb
            tt-consulta-blt.dtmvtolt = crapcob.dtmvtolt
            tt-consulta-blt.dtretcob = crapcob.dtretcob
            tt-consulta-blt.dtdpagto = crapcob.dtdpagto
            tt-consulta-blt.cdbandoc = crapcob.cdbandoc
            tt-consulta-blt.vldpagto = crapcob.vldpagto
            tt-consulta-blt.dtvencto = crapcob.dtvencto
            tt-consulta-blt.vltitulo = crapcob.vltitulo
            tt-consulta-blt.nrinssac = crapcob.nrinssac
            tt-consulta-blt.cdtpinsc = crapcob.cdtpinsc
            tt-consulta-blt.vltarifa = crapcob.vltarifa
            tt-consulta-blt.flgregis = IF  crapcob.flgregis = TRUE  THEN
                                           " S"
                                       ELSE
                                           " N"
            tt-consulta-blt.flgaceit = IF  crapcob.flgaceit = TRUE  THEN
                                           " S"
                                       ELSE
                                           " N"

            tt-consulta-blt.cdmensag = crapcob.cdmensag

            tt-consulta-blt.cdcartei = crapcco.cdcartei
            tt-consulta-blt.nrvarcar = crapcco.nrvarcar

            tt-consulta-blt.dsdinstr = crapcob.dsdinstr
            tt-consulta-blt.dsinform = crapcob.dsinform

            tt-consulta-blt.nrnosnum = crapcob.nrnosnum
            tt-consulta-blt.dtdocmto = crapcob.dtdocmto
            tt-consulta-blt.cddespec = crapcob.cddespec
            tt-consulta-blt.vldescto = crapcob.vldescto
            tt-consulta-blt.vlabatim = crapcob.vlabatim

            tt-consulta-blt.vlrjuros = crapcob.vljurdia
            tt-consulta-blt.tpjurmor = crapcob.tpjurmor

            tt-consulta-blt.vlrmulta = crapcob.vlrmulta
            tt-consulta-blt.tpdmulta = crapcob.tpdmulta

            tt-consulta-blt.flgdprot = crapcob.flgdprot
            tt-consulta-blt.qtdiaprt = crapcob.qtdiaprt
            tt-consulta-blt.indiaprt = crapcob.indiaprt
            tt-consulta-blt.insitpro = crapcob.insitpro
            .


     CASE tt-consulta-blt.cddespec:
        WHEN  1 THEN tt-consulta-blt.dsdespec = "DM".
        WHEN  2 THEN tt-consulta-blt.dsdespec = "DS".
        WHEN  3 THEN tt-consulta-blt.dsdespec = "NP".
        WHEN  4 THEN tt-consulta-blt.dsdespec = "MENS".
        WHEN  5 THEN tt-consulta-blt.dsdespec = "NF".
        WHEN  6 THEN tt-consulta-blt.dsdespec = "RECI".
        WHEN  7 THEN tt-consulta-blt.dsdespec = "OUTR".
     END CASE.

     IF   crapcob.cdbanpag = 11 THEN
          ASSIGN tt-consulta-blt.cdbanpag = "COOP."
                 tt-consulta-blt.cdagepag = "".
     ELSE
          ASSIGN tt-consulta-blt.cdbanpag = STRING(crapcob.cdbanpag,"zzz")
                 tt-consulta-blt.cdagepag = STRING(crapcob.cdagepag,"zzzz").

     IF  crapcob.dtdpagto = ? AND crapcob.incobran = 0  THEN
         DO:
             IF  crapcob.dtvencto <= p-data-limite THEN
                 ASSIGN tt-consulta-blt.cdsituac = "V".
             ELSE
                 ASSIGN tt-consulta-blt.cdsituac = "A".
         END.                       
     ELSE
     IF  crapcob.dtdpagto <> ? AND crapcob.dtdbaixa = ?  THEN
         ASSIGN tt-consulta-blt.cdsituac = "L".
     ELSE
     IF  crapcob.dtdbaixa <> ? OR crapcob.incobran = 3  THEN 
         ASSIGN tt-consulta-blt.cdsituac = "B".
     ELSE
     IF  crapcob.dtelimin <> ?  THEN
         ASSIGN tt-consulta-blt.cdsituac = "E".

     CASE tt-consulta-blt.cdsituac:
          WHEN "A" THEN tt-consulta-blt.dssituac = "ABERTO".
          WHEN "V" THEN tt-consulta-blt.dssituac = "VENCIDO".
          WHEN "B" THEN tt-consulta-blt.dssituac = "BAIXADO".
          WHEN "E" THEN tt-consulta-blt.dssituac = "EXCLUIDO".
          WHEN "L" THEN tt-consulta-blt.dssituac = "LIQUIDADO".
     END CASE. 


     FIND crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.

     CASE crapcob.incobran:
         WHEN 0 THEN DO: 
             CASE crapcob.insitcrt:
                 WHEN 1 THEN DO:
                     IF  crapcob.dtvencto < crapdat.dtmvtolt THEN
                         ASSIGN aux_dsstaabr = "INS"
                                aux_dsstacom = "C/ INST PROT"
                                aux_dtsitcrt = ?.
                     ELSE
                         ASSIGN aux_dsstaabr = "ABE"
                                aux_dsstacom = "ABERTO"
                                aux_dtsitcrt = ?.
                 END.
                 WHEN 2 THEN ASSIGN aux_dsstaabr = "REM"
                                    aux_dsstacom = "REM CARTORIO"
                                    aux_dtsitcrt = crapcob.dtsitcrt.
                 WHEN 3 THEN ASSIGN aux_dsstaabr = "CAR"
                                    aux_dsstacom = "EM CARTORIO"
                                    aux_dtsitcrt = crapcob.dtsitcrt
                                    aux_dtsitcrt = ?.
                 WHEN 4 THEN ASSIGN aux_dsstaabr = "SUS"
                                    aux_dsstacom = "SUSTADO"
                                    aux_dtsitcrt = crapcob.dtsitcrt.

                 /* se não for nenhuma dos opções acima, então aberto
                    Rafael Cechet - 30/03/11 */
                 OTHERWISE ASSIGN aux_dsstaabr = "ABE"
                                  aux_dsstacom = "ABERTO"
                                  aux_dtsitcrt = ?.

             END CASE.
         END.
         WHEN 3 THEN DO:
             
             CASE crapcob.insitcrt:
                
                WHEN 5 THEN ASSIGN aux_dsstaabr = "PRT"
                                   aux_dsstacom = "PROTESTADO"
                                   aux_dtsitcrt = crapcob.dtsitcrt.

                OTHERWISE  ASSIGN aux_dsstaabr = "BX"
                                  aux_dsstacom = "BAIXADO"
                                  aux_dtsitcrt = ?.
             END CASE.

         END.
         WHEN 5 THEN ASSIGN aux_dsstaabr = "LIQ"
                            aux_dsstacom = "LIQUIDADO"
                            aux_dtsitcrt = ?.
         WHEN 4 THEN ASSIGN aux_dsstaabr = "REJ"
                            aux_dsstacom = "REJEITADO"
                            aux_dtsitcrt = ?.
         OTHERWISE ASSIGN aux_dsstaabr = "ABE"
                          aux_dsstacom = "ABERTO"
                          aux_dtsitcrt = ?.
     END CASE.

     ASSIGN tt-consulta-blt.dsstaabr = aux_dsstaabr
            tt-consulta-blt.dsstacom = aux_dsstacom
            tt-consulta-blt.dtsitcrt = aux_dtsitcrt
            tt-consulta-blt.dssituac = (IF crapcob.flgregis THEN 
                                          aux_dsstacom
                                       ELSE "").
     
     FIND craptdb WHERE craptdb.cdcooper = crapcob.cdcooper   AND
                        craptdb.nrdconta = crapcob.nrdconta   AND
                        craptdb.cdbandoc = crapcob.cdbandoc   AND
                        craptdb.nrdctabb = crapcob.nrdctabb   AND
                        craptdb.nrcnvcob = crapcob.nrcnvcob   AND
                        craptdb.nrdocmto = crapcob.nrdocmto   NO-LOCK NO-ERROR.
                       
	 IF   AVAILABLE craptdb AND craptdb.insitapr <> 2 AND craptdb.vlsldtit > 0 THEN
          DO:
              CASE craptdb.insittit:
                   WHEN 0 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD PENDENTE"
                                      aux_flgdesco             = "".
                   WHEN 1 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD RESGATADO"
                                      aux_flgdesco             = "".
                   WHEN 2 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD PAGO"
                                      aux_flgdesco             = "*".
                   WHEN 3 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD VENCIDO"
                                      aux_flgdesco             = "*".
                   WHEN 4 THEN ASSIGN tt-consulta-blt.dssituac =
                                      tt-consulta-blt.dssituac + "/TD LIBERADO"
                                      aux_flgdesco             = "*".
              END CASE.
          END.

     IF   tt-consulta-blt.cdsituac = "L" THEN
          CASE crapcob.indpagto:
               WHEN 0 THEN DO:
                               IF   crapcob.incobran = 5  AND
                                    crapcob.vldpagto > 0  THEN
                                    tt-consulta-blt.dsdpagto = "COMPENSACAO".
                               ELSE 
                                    tt-consulta-blt.dsdpagto = "".
                           END.                       
               WHEN 1 THEN tt-consulta-blt.dsdpagto = "CAIXA".
               WHEN 2 THEN tt-consulta-blt.dsdpagto = "LANCOB".
               WHEN 3 THEN tt-consulta-blt.dsdpagto = "INTERNET".
               WHEN 4 THEN tt-consulta-blt.dsdpagto = "TAA".
          END CASE.                    
     ELSE
          tt-consulta-blt.dsdpagto = "".

     ASSIGN tt-consulta-blt.dsorgarq = crapcco.dsorgarq
            tt-consulta-blt.flgdesco = aux_flgdesco.
            
     FIND crapass WHERE
          crapass.cdcooper = tt-consulta-blt.cdcooper   AND
          crapass.nrdconta = tt-consulta-blt.nrdconta   NO-LOCK NO-ERROR.
     IF   AVAIL crapass   THEN
          ASSIGN tt-consulta-blt.cdagenci = crapass.cdagenci.

     /* gravar na temptable agencia da cooperativa
        Utilizado na internet - Rafael Cechet - 01/04/11 */
     IF tt-consulta-blt.cdbandoc = 085 THEN 
     DO:
          FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper NO-LOCK.
          ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagectl,"9999").
     END.
     ELSE
     DO:
         FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper NO-LOCK.
         ASSIGN tt-consulta-blt.agencidv = STRING(crapcop.cdagedbb,"99999").
     END.

     /* Aviso SMS */
     ASSIGN tt-consulta-blt.inavisms = crapcob.inavisms
            tt-consulta-blt.insmsant = crapcob.insmsant
            tt-consulta-blt.insmsvct = crapcob.insmsvct
            tt-consulta-blt.insmspos = crapcob.insmspos.


   END. /* Fim do DO TRANSACTION */
  
END PROCEDURE. /* p_grava_bloqueto */


/*procedure para criacao de titulo */
PROCEDURE p_cria_titulo:
                                                    
    DEF INPUT   PARAM p-cdcooper    LIKE crapcob.cdcooper   NO-UNDO.
    DEF INPUT   PARAM p-nrdconta    LIKE crapcob.nrdconta   NO-UNDO.
    DEF INPUT   PARAM p-idseqttl    LIKE crapcob.idseqttl   NO-UNDO.
    DEF INPUT   PARAM p-nmdobnfc    AS CHAR                 NO-UNDO. /* Nome do Beneficiario */
    DEF INPUT   PARAM p-nrcnvcob    LIKE crapcob.nrcnvcob   NO-UNDO.
    DEF INPUT   PARAM p-nrcnvceb    LIKE crapceb.nrcnvceb   NO-UNDO.
    DEF INPUT   PARAM p-nrdocmto    LIKE crapcob.nrdocmto   NO-UNDO.
    DEF INPUT   PARAM p-inemiten    LIKE crapcob.inemiten   NO-UNDO.
    DEF INPUT   PARAM p-cddbanco    LIKE crapcob.cdbandoc   NO-UNDO.
    DEF INPUT   PARAM p-nrdctabb    LIKE crapcob.nrdctabb   NO-UNDO.
    DEF INPUT   PARAM p-cdcartei    LIKE crapcob.cdcartei   NO-UNDO.
    DEF INPUT   PARAM p-cddespec    LIKE crapcob.cddespec   NO-UNDO.
    DEF INPUT   PARAM p-cdtpinsc    LIKE crapcob.cdtpinsc   NO-UNDO.
    DEF INPUT   PARAM p-nrinssac    LIKE crapcob.nrinssac   NO-UNDO.
    DEF INPUT   PARAM p-nmdavali    LIKE crapcob.nmdavali   NO-UNDO.
    DEF INPUT   PARAM p-cdtpinav    LIKE crapcob.cdtpinav   NO-UNDO.
    DEF INPUT   PARAM p-nrinsava    LIKE crapcob.nrinsava   NO-UNDO.
    DEF INPUT   PARAM p-dtmvtolt    LIKE crapcob.dtmvtolt   NO-UNDO.
    DEF INPUT   PARAM p-dtdocmto    LIKE crapcob.dtdocmto   NO-UNDO.
    DEF INPUT   PARAM p-vencimto    LIKE crapcob.dtvencto   NO-UNDO.
    DEF INPUT   PARAM p-vldescto    LIKE crapcob.vldescto   NO-UNDO.
    DEF INPUT   PARAM p-vlabatim    LIKE crapcob.vlabatim   NO-UNDO.
    DEF INPUT   PARAM p-cdmensag    LIKE crapcob.cdmensag   NO-UNDO.
    DEF INPUT   PARAM p-dsdoccop    LIKE crapcob.dsdoccop   NO-UNDO.
    DEF INPUT   PARAM p-nrdoccop    LIKE crapcob.nrdoccop   NO-UNDO.
    DEF INPUT   PARAM p-vltitulo    LIKE crapcob.vltitulo   NO-UNDO.
    DEF INPUT   PARAM p-dsdinstr    LIKE crapcob.dsdinstr   NO-UNDO.
    DEF INPUT   PARAM p-dsinform    LIKE crapcob.dsinform   NO-UNDO.
    DEF INPUT   PARAM p-nrctasac    LIKE crapcob.nrctasac   NO-UNDO.
    DEF INPUT   PARAM p-nrctremp    LIKE crapcob.nrctremp   NO-UNDO.
    DEF INPUT   PARAM p-nrnosnum    LIKE crapcob.nrnosnum   NO-UNDO.
    DEF INPUT   PARAM p-flgdprot    LIKE crapcob.flgdprot   NO-UNDO.
    DEF INPUT   PARAM p-qtdiaprt    LIKE crapcob.qtdiaprt   NO-UNDO.
    DEF INPUT   PARAM p-indiaprt    LIKE crapcob.indiaprt   NO-UNDO.
    DEF INPUT   PARAM p-vljurdia    LIKE crapcob.vljurdia   NO-UNDO.
    DEF INPUT   PARAM p-vlrmulta    LIKE crapcob.vlrmulta   NO-UNDO.
    DEF INPUT   PARAM p-flgaceit    LIKE crapcob.flgaceit   NO-UNDO.
    DEF INPUT   PARAM p-flgregis    LIKE crapcob.flgregis   NO-UNDO.
    DEF INPUT   PARAM p-flgsacad    AS LOGI                 NO-UNDO.
    DEF INPUT   PARAM p-tpjurmor    LIKE crapcob.tpjurmor   NO-UNDO.
    DEF INPUT   PARAM p-tpdmulta    LIKE crapcob.tpdmulta   NO-UNDO.
    DEF INPUT   PARAM p-tpemitir    AS INTE                 NO-UNDO.
    DEF INPUT   PARAM p-cdoperad    LIKE crapcob.cdoperad   NO-UNDO.

     /* Serasa */
    DEF INPUT   PARAM p-flserasa    LIKE crapcob.flserasa   NO-UNDO.
    DEF INPUT   PARAM p-qtdianeg    LIKE crapcob.qtdianeg   NO-UNDO.

    /* Aviso SMS */
    DEF  INPUT PARAM p-inavisms AS INTE                                  NO-UNDO.
    DEF  INPUT PARAM p-insmsant AS INTE                                  NO-UNDO.
    DEF  INPUT PARAM p-insmsvct AS INTE                                  NO-UNDO.
    DEF  INPUT PARAM p-insmspos AS INTE                                  NO-UNDO.

    /* NPC */
    DEF INPUT   PARAM p-flgregon    AS INTE                 NO-UNDO.
    DEF INPUT   PARAM p-inpagdiv    LIKE crapcob.inpagdiv   NO-UNDO.
    DEF INPUT   PARAM p-vlminimo    LIKE crapcob.vlminimo   NO-UNDO.

    DEF INPUT   PARAM TABLE FOR tt-dados-sacado-blt.
    DEF INPUT-OUTPUT  PARAM p-lsdoctos       AS CHAR        NO-UNDO.
    DEF OUTPUT  PARAM p-cdcritic       AS INTE              NO-UNDO.
    DEF OUTPUT  PARAM p-dscritic       AS CHAR              NO-UNDO.
    DEF OUTPUT  PARAM TABLE FOR tt-consulta-blt.

    DEF VAR h-b1wgen0088 AS HANDLE                          NO-UNDO.
    DEF VAR h-b1wgen0090 AS HANDLE                          NO-UNDO.
    
    DEF VAR aux_cdbarras AS CHAR                            NO-UNDO.
    DEF VAR aux_dsdjuros AS CHAR                            NO-UNDO.
    DEF VAR aux_vltarifa LIKE crapcct.vltarifa              NO-UNDO.
    DEF VAR aux_cdtarhis LIKE crapcct.cdtarhis              NO-UNDO.
    DEF VAR aux_nrnosnum LIKE crapcob.nrnosnum              NO-UNDO.
    DEF VAR aux_cddespec AS CHAR                            NO-UNDO.
    DEF VAR aux_dtdemiss AS DATE                            NO-UNDO.

    DEF VAR aux_busca    AS CHAR                            NO-UNDO.
    DEF VAR aux_nrdocmto LIKE crapcob.nrdocmto              NO-UNDO.
    
    /* Serasa */
    DEF VAR aux_qtminneg AS INTE                            NO-UNDO.
    DEF VAR aux_qtmaxneg AS INTE                            NO-UNDO.

    DEF VAR aux_valormin AS DEC                             NO-UNDO.
    DEF VAR aux_textodia AS CHAR                            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                            NO-UNDO.
    
    /* Registrar na CIP */ 
    DEF VAR aux_inregcip AS INTEGER                         NO-UNDO.
    /* Indicador do tipo de pessoa fisica/juridica */ 
    DEF VAR aux_tppessoa AS CHAR                            NO-UNDO.
    /* Identificador de pagador DDA */
    DEF VAR aux_flgsacad AS INTEGER                         NO-UNDO.
    /* Rollout do valor do titulo */
    DEF VAR aux_rollout  AS INTEGER                         NO-UNDO.
    /* Motivo */
    DEF VAR aux_cdmotivo AS CHAR                            NO-UNDO.
    /* Ponteiro para buscar o Valor de Rollout */ 
    DEF VAR aux_ponteiro AS INTEGER                         NO-UNDO.
    
    FIND crapcco WHERE cdcooper = p-cdcooper
                   AND nrconven = p-nrcnvcob NO-LOCK NO-ERROR.

    /* Testar parametro em relacao ao convenio */
    IF  crapcco.flgregis <> p-flgregis THEN
        DO:
            ASSIGN p-cdcritic = 0
                   p-dscritic = "Tipo de cobranca invalida.".
            RETURN "NOK".
        END.

    ASSIGN aux_busca = TRIM(STRING(p-cdcooper)) + ";" +
                       TRIM(STRING(p-nrdconta)) + ";" +
                       TRIM(STRING(p-nrcnvcob)) + ";" +
                       TRIM(STRING(p-nrdctabb)) + ";" +
                       TRIM(STRING(p-cddbanco)).

    /* Busca a proxima sequencia do campo CRAPCOB.NRDOCMTO */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPCOB"
                                            ,INPUT "NRDOCMTO"
                                            ,INPUT aux_busca
                                            ,INPUT "N"
                                            ,"").
        
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                          
        ASSIGN aux_nrdocmto = INTE(pc_sequence_progress.pr_sequence)
                                                  WHEN pc_sequence_progress.pr_sequence <> ?.

    IF  aux_nrdocmto = 0 THEN DO:
        ASSIGN aux_dscritic = "Erro ao gerar numero do documento.".
        RETURN "NOK".
    END.


    IF  crapcco.cddbanco <> 085 THEN
    DO:
        /* Se for convenio de 6 digito deve gerar
           o nosso numero apenas com a conta e docto SD 308717*/
        IF LENGTH(STRING(p-nrcnvcob)) = 6 THEN
          ASSIGN aux_nrnosnum = STRING(p-nrdconta  ,"99999999") +
                                STRING(aux_nrdocmto,"999999999").
        ELSE
          ASSIGN aux_nrnosnum = STRING(p-nrcnvcob, "9999999") + 
                                STRING(p-nrcnvceb, "9999") + 
                                STRING(aux_nrdocmto, "999999").
    END.
    ELSE
        ASSIGN aux_nrnosnum = STRING(p-nrdconta,"99999999") +
                              STRING(aux_nrdocmto,"999999999").
    
    /**** validação praça não executante de protesto ****/
    FIND crapsab WHERE crapsab.cdcooper = p-cdcooper AND
                       crapsab.nrdconta = p-nrdconta AND
                       crapsab.nrinssac = p-nrinssac NO-LOCK NO-ERROR.

    IF NOT AVAILABLE crapsab THEN
    DO:
        ASSIGN p-cdcritic = 0
               p-dscritic = "Pagador nao encontrado.".
        RETURN "NOK".
    END.
    
    /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validaçao nao é mais necessária
      pois agora Todas as cidades podem ter protesto*/
    /*IF p-flgregis THEN
    DO:
        FIND crappnp WHERE crappnp.nmextcid = crapsab.nmcidsac AND
                           crappnp.cduflogr = crapsab.cdufsaca NO-LOCK NO-ERROR.
    
        IF  AVAILABLE crappnp THEN
        DO:
            ASSIGN p-flgdprot = FALSE 
                   p-qtdiaprt = 0 
                   p-indiaprt = 3.
    
            CREATE crapcol.
            ASSIGN crapcol.cdcooper = p-cdcooper
                   crapcol.nrdconta = p-nrdconta
                   crapcol.nrdocmto = aux_nrdocmto
                   crapcol.nrcnvcob = p-nrcnvcob
                   crapcol.dslogtit = "Obs.: Praca nao executante de protesto"
                   crapcol.cdoperad = p-cdoperad
                   crapcol.dtaltera = TODAY
                   crapcol.hrtransa = TIME.
        END.

    END.*/

    /* se banco emite e expede, nosso num conv+ceb+doctmo -
       Rafael Cechet 29/03/11 */

    IF  NOT AVAIL(crapdat) THEN
        FIND crapdat WHERE crapdat.cdcooper = p-cdcooper
            NO-LOCK NO-ERROR.

    ASSIGN aux_dtdemiss = crapdat.dtmvtolt.

    IF p-qtdianeg > 0 THEN
    DO:

        RUN busca_param_negativacao (INPUT  p-cdcooper,
                                     INPUT  crapsab.cdufsaca,
                                     OUTPUT aux_qtminneg,
                                     OUTPUT aux_qtmaxneg,
                                     OUTPUT aux_valormin,
                                     OUTPUT aux_textodia,
                                     OUTPUT aux_dscritic).

        IF p-qtdianeg < aux_qtminneg OR 
           p-qtdianeg > aux_qtmaxneg THEN
            ASSIGN p-qtdianeg = aux_qtminneg.


    END.

    /* Se foi informado para enviar aviso, porem sem selecionar
       o momente, deve gravar como nao enviar aviso */
    IF  p-inavisms <> 0 AND 
        p-insmsant =  0 AND 
        p-insmsvct =  0 AND 
        p-insmspos =  0 THEN
    DO:
      ASSIGN p-inavisms = 0.
    END.
    
    /* se o convenio do cooperado possuir registro online
       devera gravar o boleto com registro online; */ 
    ASSIGN aux_inregcip = 0.
    IF p-flgregon = 1 THEN 
    DO:
        /* Verificar se eh Cooperativa Emite e Expede*/
        IF p-inemiten = 3 THEN
            ASSIGN aux_inregcip = 2. /* Registro via batch */ 
        ELSE
            ASSIGN aux_inregcip = 1. /* Registro ONLINE */ 
    END.
    ELSE 
        ASSIGN aux_inregcip = 0. /* Sem registro na CIP */ 
    
    
    CREATE crapcob.
    ASSIGN crapcob.cdcooper = p-cdcooper
           crapcob.nrdconta = p-nrdconta
           crapcob.nrdocmto = aux_nrdocmto
           crapcob.idseqttl = p-idseqttl
           crapcob.dtmvtolt = aux_dtdemiss
           crapcob.cdbandoc = p-cddbanco
           crapcob.incobran = 0
           crapcob.nrcnvcob = p-nrcnvcob
           crapcob.nrdctabb = p-nrdctabb
           crapcob.cdcartei = p-cdcartei
           crapcob.cddespec = p-cddespec
           crapcob.cdtpinsc = p-cdtpinsc
           crapcob.nrinssac = p-nrinssac
           crapcob.nmdavali = CAPS(p-nmdavali)
           crapcob.cdtpinav = p-cdtpinav
           crapcob.nrinsava = p-nrinsava
           crapcob.dtretcob = p-dtmvtolt
           crapcob.dtdocmto = p-dtdocmto
           crapcob.dtvencto = p-vencimto
           crapcob.dtvctori = p-vencimto
           crapcob.vldescto = p-vldescto
           crapcob.vlabatim = p-vlabatim
           crapcob.cdmensag = p-cdmensag
           crapcob.dsdoccop = CAPS(TRIM(p-dsdoccop)) + "/" +
                              STRING(p-nrdoccop,"9999")
           crapcob.vltitulo = p-vltitulo
           crapcob.dsdinstr = CAPS(p-dsdinstr)
           crapcob.dsinform = CAPS(p-dsinform)
           crapcob.cdimpcob = 3
           crapcob.flgimpre = TRUE
           crapcob.nrctasac = p-nrctasac
           crapcob.nrctremp = p-nrctremp
           
           crapcob.nrnosnum = aux_nrnosnum
           crapcob.flgdprot = p-flgdprot
           crapcob.qtdiaprt = p-qtdiaprt

           /* Serasa */
           crapcob.flserasa = p-flserasa
           crapcob.qtdianeg = p-qtdianeg

           /* Aviso SMS */
           crapcob.inavisms = p-inavisms
           crapcob.insmsant = p-insmsant
           crapcob.insmsvct = p-insmsvct
           crapcob.insmspos = p-insmspos

           /* NPC */        
           crapcob.inenvcip = IF p-cddbanco = 85 THEN 1 ELSE 0
           crapcob.inpagdiv = p-inpagdiv
           crapcob.vlminimo = p-vlminimo
           
           /* 0=sem registro na CIP, 1=registro online, 2=registro offline*/
           crapcob.inregcip = aux_inregcip
           
           crapcob.indiaprt = p-indiaprt
           crapcob.vljurdia = p-vljurdia
           crapcob.vlrmulta = p-vlrmulta
           crapcob.flgaceit = p-flgaceit
           crapcob.flgregis = p-flgregis
           crapcob.inemiten = p-inemiten
           crapcob.insitcrt = 0
           crapcob.insitpro = IF p-flgregis AND p-cddbanco = 85 THEN 1
                              ELSE 0                    
           crapcob.flgcbdda = p-flgsacad
           /* 1=vlr "R$" diario, 2= "%" Mensal, 3=isento */
           crapcob.tpjurmor = IF p-vljurdia = 0 THEN 3 
                              ELSE p-tpjurmor

           /* 1=vlr "R$", 2= "%" , 3=isento */
           crapcob.tpdmulta = IF p-vlrmulta = 0 THEN 3
                              ELSE p-tpdmulta

           crapcob.idopeleg = IF  p-flgsacad THEN 
                                  NEXT-VALUE(seqcob_idopeleg)
                              ELSE 0
           crapcob.idtitleg = IF  p-flgsacad THEN 
                                  NEXT-VALUE(seqcob_idtitleg)
                              ELSE 0
           crapcob.inemiexp = IF p-inemiten = 3 THEN 1 /* a enviar à PG */
                              ELSE 0.


                
    RUN p_grava_boleto (INPUT p-cdcooper,
                        INPUT p-nmdobnfc,
                        INPUT 1,
                        INPUT 999,
                        INPUT ?,
                        OUTPUT TABLE tt-consulta-blt).

    IF p-flgsacad THEN
    DO:
        
        FIND crapass WHERE crapass.cdcooper = crapcob.cdcooper AND
                           crapass.nrdconta = crapcob.nrdconta 
             NO-LOCK NO-ERROR.
                
        RUN p_calc_codigo_barras(ROWID(crapcob), OUTPUT aux_cdbarras).

        IF crapcob.tpjurmor = 1 THEN
            ASSIGN aux_dsdjuros = "1".
        ELSE IF crapcob.tpjurmor = 2 THEN
            ASSIGN aux_dsdjuros = "3".
        ELSE IF crapcob.tpjurmor = 3 THEN
            ASSIGN aux_dsdjuros = "5".

        CASE crapcob.cddespec: 
            WHEN 1 THEN ASSIGN aux_cddespec = "02".
            WHEN 2 THEN ASSIGN aux_cddespec = "04".
            WHEN 3 THEN ASSIGN aux_cddespec = "12".
            WHEN 4 THEN ASSIGN aux_cddespec = "21".
            WHEN 5 THEN ASSIGN aux_cddespec = "23".
            WHEN 6 THEN ASSIGN aux_cddespec = "17".
            WHEN 7 THEN ASSIGN aux_cddespec = "99".
        END CASE.

        FIND crapban WHERE crapban.cdbccxlt = crapcob.cdbandoc
            NO-LOCK NO-ERROR.

        IF NOT AVAIL crapban THEN
        DO:
            ASSIGN p-cdcritic = 0
                   p-dscritic = "Parametro nrispbif nao encontrado.".
            RETURN "NOK".
        END.


    END. 

    /** Validacoes de Cobranca Registrada **/
    IF  p-cddbanco = 1 AND p-flgregis = TRUE THEN DO:

        RUN sistema/generico/procedures/b1wgen0088.p PERSISTENT 
            SET h-b1wgen0088.

        IF  NOT VALID-HANDLE(h-b1wgen0088)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen0088.".

                RETURN "NOK".
            END.

        RUN gera_pedido_remessa IN h-b1wgen0088 (INPUT ROWID(crapcob),
                                                 INPUT p-dtmvtolt,
                                                 INPUT p-cdoperad).

        DELETE PROCEDURE h-b1wgen0088.

    END.
    ELSE IF crapcob.cdbandoc = 085 THEN DO: 
    
        /* Identificar se eh pessoa fisica ou juridica
             -> cdtpinsc = 1 -- Fisica
             -> cdtpinsc = 2 -- Juridica */
        IF crapcob.cdtpinsc = 1 THEN
            ASSIGN aux_tppessoa = "F".
        ELSE
            ASSIGN aux_tppessoa = "J".
    
            
        /* Emergencial (Rafael) */
        /* Retirado devido aos problemas entre transcoes SQL/Server e Oracle */
        ASSIGN aux_flgsacad = 0.
    
        /* Verificações para identificar se o boleto eh DDA "A4"
           se deve ser registrado online "R1"
           e se eh Cooperativa Emite e Expede "P1" */ 
           
/*        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    

        /* Identificar se o pagador eh DDA */
        RUN STORED-PROCEDURE pc_verifica_sacado_DDA
            aux_handproc = PROC-HANDLE NO-ERROR
                                    (INPUT aux_tppessoa,
                                     INPUT crapcob.nrinssac,
                                    OUTPUT 0,   /* pr_flgsacad */
                                    OUTPUT 0,   /* pr_cdcritic */
                                    OUTPUT ""). /* pr_dscritic */

        CLOSE STORED-PROC pc_verifica_sacado_DDA
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
        
        ASSIGN aux_flgsacad = 0
               aux_flgsacad = pc_verifica_sacado_DDA.pr_flgsacad 
                              WHEN pc_verifica_sacado_DDA.pr_flgsacad <> ?. */                              
        
        ASSIGN aux_cdmotivo = "".
        
        /* 1) se pagador DDA -> vr_cdmotivo = 'A4'; */ 
        IF aux_flgsacad = 1 THEN
            ASSIGN aux_cdmotivo = "A4".
        
        /* 2) se inregcip = 1 -> vr_cdmotivo = 'R1' (concatenar); */ 
        IF aux_inregcip = 1 THEN
            ASSIGN aux_cdmotivo = aux_cdmotivo + "R1".
        
        /* 3) se inemiten = 3 -> vr_cdmotivo = 'P1' (concatenar); */ 
        IF p-inemiten = 3 THEN
            ASSIGN aux_cdmotivo = aux_cdmotivo + "P1".
                   
        ASSIGN tt-consulta-blt.cdmotivo = aux_cdmotivo.

        RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT 
            SET h-b1wgen0090.

        IF  NOT VALID-HANDLE(h-b1wgen0090) THEN
            DO:
                ASSIGN p-cdcritic = 0
                       p-dscritic = "Handle invalido para BO b1wgen0090.".

                RETURN "NOK".
            END.

        FIND FIRST crapcop WHERE crapcop.cdcooper = p-cdcooper
            NO-LOCK NO-ERROR.
      

        RUN prep-retorno-cooperado IN h-b1wgen0090 (INPUT ROWID(crapcob),
                                                    INPUT 2, /* ent confirmada */
                                                    INPUT aux_cdmotivo,
                                                    INPUT 0,
                                                    INPUT crapcop.cdbcoctl,
                                                    INPUT crapcop.cdagectl,
                                                    INPUT p-dtmvtolt,
                                                    INPUT p-cdoperad,
                                                    INPUT 0). /* aux_nrremess */
        DELETE PROCEDURE h-b1wgen0090.

    END.

    /*** Criando log do processo - Cobranca Registrada ***/
    IF p-flgregis THEN DO:
        CREATE crapcol.
        ASSIGN crapcol.cdcooper = p-cdcooper
               crapcol.nrdconta = p-nrdconta
               crapcol.nrdocmto = aux_nrdocmto
               crapcol.nrcnvcob = p-nrcnvcob
               crapcol.dslogtit = (IF p-tpemitir = 1 THEN "Titulo gerado"
                                   ELSE "Titulo gerado - Carne")
               crapcol.cdoperad = p-cdoperad
               crapcol.dtaltera = TODAY
               crapcol.hrtransa = TIME.
    END.

    IF p-flgregis AND p-inemiten = 3 THEN /* cooperativa emite e expede */ 
    DO:
        /*** Criando log do boleto – Titulo a enviar para PG ***/
        CREATE crapcol.
        ASSIGN crapcol.cdcooper = p-cdcooper
               crapcol.nrdconta = p-nrdconta
               crapcol.nrdocmto = aux_nrdocmto
               crapcol.nrcnvcob = p-nrcnvcob
               crapcol.dslogtit = "Titulo a enviar para PG"
               crapcol.cdoperad = p-cdoperad
               crapcol.dtaltera = TODAY
               crapcol.hrtransa = TIME.
    END.


    ASSIGN p-lsdoctos = p-lsdoctos + 
                         (IF  p-lsdoctos <> ""  THEN
                              ","
                          ELSE
                              "") + STRING(aux_nrdocmto) 
           p-nrdocmto = p-nrdocmto + 1
           p-nrdoccop = p-nrdoccop + 1.

    RETURN "OK".

END PROCEDURE.



PROCEDURE p_calc_codigo_barras:

    DEF INPUT PARAM par_idcrapcob           AS ROWID          NO-UNDO.
    DEF OUTPUT PARAM par_cod_barras         AS CHAR           NO-UNDO. 
    
    DEF VAR aux             AS CHAR                           NO-UNDO.
    DEF VAR dtini           AS DATE INIT "10/07/1997"         NO-UNDO.

    DEF VAR aux_ftvencto    AS INTE                                          NO-UNDO.

    IF crapcob.dtvencto >= DATE("22/02/2025") THEN
           aux_ftvencto = (crapcob.dtvencto - DATE("22/02/2025")) + 1000.
        ELSE
           aux_ftvencto = (crapcob.dtvencto - dtini).

    FIND crapcob WHERE ROWID(crapcob) = par_idcrapcob NO-LOCK NO-ERROR.

    ASSIGN aux = string(crapcob.cdbandoc,"999")
                           + "9" /* moeda */
                           + "1" /* nao alterar - constante */
                           + STRING(aux_ftvencto, "9999") 
                           + string(crapcob.vltitulo * 100, "9999999999")
                           + string(crapcob.nrcnvcob, "999999")
                           + string(crapcob.nrnosnum, "99999999999999999")
                           + string(crapcob.cdcartei, "99")
               glb_nrcalcul = DECI(aux).

    RUN sistema/ayllos/fontes/digcbtit.p.
        ASSIGN par_cod_barras = string(glb_nrcalcul, 
           "99999999999999999999999999999999999999999999").
        
END PROCEDURE.

PROCEDURE verifica-convenios:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_intipcob AS INTEGER                        NO-UNDO.
    DEF OUTPUT PARAM par_intipemi AS INTEGER                        NO-UNDO.

    /* par_intipcob
       0 = sem convenio
       1 = cobranca sem registro
       2 = cobranca registrada
       3 = os dois convenios (Jorge/Rafael) */

    /* par_intipemi
       0 = sem convenio
       1 = cooperado emite e expede
       2 = banco emite e expede
       3 = cooperado + banco (emite e expede) (Jorge/Rafael) 
       4 = cooperativa emite e expede
       5 = cooperativa emite e expede + cooperado emite e expede;
       6 = cooperativa emite e expede + banco emite e expede;
       7 = cooperativa emite e expede + cooperado emite e expede + banco emite e expede;
       
       COO => Cooperado Emite e Expede
       BCO => Banco Emite e Expede
       CEE => Cooperativa Emite e Expede
        
       -------------------------------------------
       intipemi | CEE  BCO  COO
       0        |  0    0    0  => Sem convenio
       -------------------------------------------
       1        |  0    0    1  => COO
       -------------------------------------------
       2        |  0    1    0  => BCO
       -------------------------------------------
       3        |  0    1    1  => COO + BCO
       -------------------------------------------
       4        |  1    0    0  => CEE
       -------------------------------------------
       5        |  1    0    1  => COO + CEE
       -------------------------------------------
       6        |  1    1    0  => BCO + CEE
       -------------------------------------------
       7        |  1    1    1  => COO + BCO + CEE
       -------------------------------------------
    */

    /* verificar se o cooperado tem cob sem registro */
    FOR EACH crapcco 
       WHERE crapcco.cdcooper = par_cdcooper AND
             /*crapcco.flgativo = TRUE         AND*/
             crapcco.flgregis = FALSE        AND 
             crapcco.flginter = TRUE         /*AND
             crapcco.dsorgarq = "INTERNET"   */NO-LOCK
      ,FIRST crapceb
       WHERE crapceb.cdcooper = crapcco.cdcooper    AND
             crapceb.nrconven = crapcco.nrconven    AND
             crapceb.nrdconta = par_nrdconta        AND
             crapceb.insitceb = 1              NO-LOCK:
        
        ASSIGN par_intipcob = 1.
        LEAVE.
    END.
                               
    /* verificar se o cooperado tem cob. registrada */
    FOR EACH crapcco 
       WHERE crapcco.cdcooper = par_cdcooper        AND
             crapcco.nrconven > 0                   AND
             /*crapcco.flgativo = TRUE                AND
             crapcco.dsorgarq = "INTERNET"          AND */
             crapcco.flginter = TRUE                AND
             crapcco.flgregis = TRUE            NO-LOCK
      ,FIRST crapceb
       WHERE crapceb.cdcooper = crapcco.cdcooper    AND
             crapceb.nrconven = crapcco.nrconven    AND
             crapceb.nrdconta = par_nrdconta        AND
             crapceb.insitceb = 1              NO-LOCK:
    
       ASSIGN par_intipcob = par_intipcob + 2.

       LEAVE.                                 
    END.

    /* verificar convenio emite e expede */
    FOR EACH crapcco 
       WHERE crapcco.cdcooper = par_cdcooper        AND
             crapcco.nrconven > 0                   AND
             /*crapcco.flgativo = TRUE                AND */
             crapcco.dsorgarq = "INTERNET"          AND 
             crapcco.flginter = TRUE                AND
             crapcco.flgregis = TRUE            NO-LOCK
      ,FIRST crapceb
       WHERE crapceb.cdcooper = crapcco.cdcooper    AND
             crapceb.nrconven = crapcco.nrconven    AND
             crapceb.nrdconta = par_nrdconta        AND
             crapceb.insitceb = 1              NO-LOCK:
    
       IF  crapcco.cddbanco = 085  AND 
           crapceb.flcooexp = TRUE AND
           (par_intipemi = 0 OR par_intipemi = 2 OR 
            par_intipemi = 4 OR par_intipemi = 6) THEN
           ASSIGN par_intipemi = par_intipemi + 1.

       IF  crapcco.cddbanco = 085  AND 
           crapceb.flceeexp = TRUE AND
           (par_intipemi >= 0 OR par_intipemi <= 3) THEN
           ASSIGN par_intipemi = par_intipemi + 4.

       IF  crapcco.cddbanco = 001 AND 
           (par_intipemi = 0 OR par_intipemi = 1 OR 
            par_intipemi = 4 OR par_intipemi = 5) THEN
           ASSIGN par_intipemi = par_intipemi + 2.


    END.

    RETURN "OK".


END PROCEDURE.

PROCEDURE busca_param_negativacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdufsaca AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_qtminneg AS INTEGER                        NO-UNDO.
    DEF OUTPUT PARAM par_qtmaxneg AS INTEGER                        NO-UNDO.
    DEF OUTPUT PARAM par_valormin AS DEC                            NO-UNDO.
    DEF OUTPUT PARAM par_textodia AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    

    RUN STORED-PROCEDURE pc_busca_param_negativ
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_cdufsaca,
                                OUTPUT 0,
                                OUTPUT 0,
                                OUTPUT 0,   
                                OUTPUT "", 
                                OUTPUT ""). /* pr_dscritic */

    CLOSE STORED-PROC pc_busca_param_negativ
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }

    ASSIGN par_dscritic = ""

           par_dscritic = pc_busca_param_negativ.pr_dscritic
                              WHEN pc_busca_param_negativ.pr_dscritic <> ?

           par_qtminneg = pc_busca_param_negativ.pr_qtminimo_negativacao
                              WHEN pc_busca_param_negativ.pr_qtminimo_negativacao <> ?

           par_qtmaxneg = pc_busca_param_negativ.pr_qtmaximo_negativacao
                              WHEN pc_busca_param_negativ.pr_qtmaximo_negativacao <> ?

           par_valormin = pc_busca_param_negativ.pr_vlminimo_boleto
                              WHEN pc_busca_param_negativ.pr_vlminimo_boleto <> ?

           par_textodia = pc_busca_param_negativ.pr_dstexto_dia
                              WHEN pc_busca_param_negativ.pr_dstexto_dia <> ?.

END PROCEDURE.

/*............................................................................*/


