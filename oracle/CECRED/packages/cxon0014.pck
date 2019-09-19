CREATE OR REPLACE PACKAGE CECRED.cxon0014 AS

/*..............................................................................

   Programa: cxon0014                        Antigo: siscaixa/web/dbo/b1crap14.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 19/09/2016

   Dados referentes ao programa:

   Frequencia: Diario (Caixa Online).
   Objetivo  : Tratar Arrecadacao de Titulos com codigo de barras

   Alteracoes: 26/09/2005 - Tratar Identificacao do segmento no codigo de
                            barras para fatura IPTU Blumenau(Pos. 2 - 2)
                            Passar codigo da cooperativa e nrdconta como
                            parametro para as procedures (Julio)

               12/04/2006 - Permitir bloquetos vencidos quando este for da
                            coopertativa (Julio)

               08/08/2006 - Tratar novo layout de bloqueto (crapceb) (Julio)

               15/08/2007 - Alterado para usar a data com crapdat.dtmvtocd e
                            tratamento para os erros da internet;
                          - Criada procedure gera-tarifa-titulo e identificar
                            quando boleto for pago pela internet (Evandro).

               03/01/2008 - Validar horario de digitacao somente quando nao
                            for PAC 90 (David).

               15/04/2008 - Adaptacao para agendamentos (David).

               03/06/2008 - Separacao de lotes para titulos da coop (Evandro).

               08/07/2008 - Acerto na leitura do crapcob (Magui).

               15/09/2008 - Alterado campo crapcob.cdbccxlt -> crapcob.cdbandoc
                            (Diego).

               08/10/2008 - Chama a BO efetua_baixa_titulo e nao gera
                            lancamento de credito para conta do cooperado no
                            caso do titulo estar em desconto (Elton).
                          - Utilizar craplot.nrseqdig + 1 no campo nrdocmto
                            em vez de TIME quando criar o registro da craptit
                            (David).

               08/12/2008 - Incluir parametro na chamada do programa pcrap03.p
                            (David).

               15/04/2009 - Tratamento para tarifas (Gabriel).
                          - Origem AUTOMATICO alterado para IMPRESSO PELO
                            SOFTWARE ou INTERNET (Guilherme).
                          - Postergacao da data de vencimento na verificacao
                            se o titulo esta em desconto ou nao(Guilherme).

               19/05/2009 - Chamar a baixa de desconto de titulo somente se
                            o titulo estiver em desconto(aux_flgdesct = YES)
                            (Guilherme).

               02/06/2009 - Alterar tratamento para verificacao de registros
                            que estao com EXCLUSIVE-LOCK (David).
                          - Inserido tratamento de erro na chamada da b1wgen0030
                            (Guilherme).

               23/06/2009 - Adaptar para pagamento de titulos que estao em
                            emprestimo (Guilherme).

               24/07/2009 - Se o titulo for da cooperativa, verificar se esta
                            vencido (David).

               22/10/2009 - Converte para DECIMAL ao inves de INTEGER o valor
                            passado para variavel p-bloqueto na procedure
                            identifica-titulo-coop (Elton).

               26/10/2009 - Corrigir a busca do convenio (crapcco) para
                            utilizar o cdcooper (Evandro).

               27/10/2009 - Tratamento para nao aceitar titulos vencidos como
                            agendamento (David).

               08/01/2010 - Tratamento para aceitar titulos que venceram no
                            ultimo dia util do ano (David).

               10/06/2010 - Tratamento para o PAC 91 - TAA (Evandro/Elton).

               20/10/2010 - Inclusao de parametros na procedure
                            gera-titulos-iptu (Vitor)

               27/12/2010 - Incluida procedure atualiza-cheque e incluido
                            novos parametros na procedure gera-titulos-iptu
                            (Elton).

               16/02/2011 - Tratamento para Projeto DDA (David).

               04/03/2011 - Tratamento para Feriado de Carnaval e Feriado em
                            Joinville (David).

               18/03/2011 - Cria crapcob quando boleto for do tipo
                            "IMPRESSO PELO SOFTWARE" e n¿o existir o crapcob
                            (Elton).

               02/05/2011 - Tratamento para liquida¿¿o de cob. registrada
                          - Criticar titulos com numero de caracteres <> de 44
                            e nao aceitar caracteres nao numerico (Guilherme);
                          - Acerto na contabiliza¿¿o dos cheques na craplot
                            (Elton).

               08/07/2011 - Incluido novos parametros na procedure
                            gera-titulos-iptu (Elton).

               14/07/2011 - Alterado identifica-titulos-coop
                            Quando criar titulo, identificar que pertence
                            a cooperativa (Rafael).

               03/08/2011 - Alterado identifica-titulos-coop
                            Buscar titulos Banco do Brasil somente quando
                            for cob. sem registro (Rafael).

               12/08/2011 - Feriado Credicomin (David).

               08/11/2011 - Ajuste no campo aux_cdmotivo - passado p/ CHAR
                            Ajuste calculo juros/multa na procedure
                            retorna-valores-titulo-iptu (Rafael).

               21/11/2011 - Ajuste no calculo de juros/multa - usado ROUND
                            com 2 casas decimais. (Rafael)

               20/12/2011 - Buscar somente IF operantes quando validar
                            boleto no pagto (Rafael).

               10/02/2012 - Realizado a chamada para a procedure
                            verifica_feriado (Adriano).

               16/03/2012 - Utilizar o valor de abatimento do boleto antes do
                            calculo de juros/multa. (Rafael)

               04/05/2012 - Ajuste no pagto DDA vencido. (Rafael)

               08/08/2012 - Ajuste da rotina de pagto de titulos descontados
                            da cob. registrada. (Rafael)

               15/08/2012 - Acerto para nao criticar dois titulos com mesmo
                            numero de convenio, mesmo numero de documento e
                            contas diferentes (Elton).

               19/11/2012 - Titulos migrados para Alto Vale s¿o interbancarios
                            quando pagos na Viacredi. (Rafael)

               29/11/2012 - Ajuste na identificacao dos titulos 085. (Rafael)

               08/01/2013 - Ajuste no pagto de titulos migrados. (Rafael)

               11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                            consulta da craptco (Tiago).
                          - Adicionado condicional especial para AltoVale em
                            proc. identifica-titulo-coop. (Jorge)

               22/01/2013 - Ajuste na liquidacao de titulos de convenios
                            migrados 085. (Rafael)

               21/02/2013 - Ajuste na liquidacao de titulos com CEB 5 digitos
                            do convenio 1343313 Viacredi. (Rafael)

               21/03/2013 - Aumentar formato para evitar erros de conversao
                            na gera titulos iptu (Gabriel)

               09/05/2013 - Projeto VR Boleto - envio de pagto de titulos VR
                            por STR ao SPB. (Rafael)

               20/05/2013 - Novo param. procedure 'grava-autenticacao-internet'
                            (Lucas).

               14/06/2013 - Altera¿¿o fun¿¿o enviar_email_completo para
                            nova vers¿o (Jean Michel).

               07/07/2013 - Convers¿o Progress para Oracle (Alisson - AMcom)

               09/05/2014 - Tratamento para nao aceitar titulos do banco Real (Elton).

               09/05/2014 - Replicar manutenção progress (Odirlei/AMcom).

               29/05/2014 - Replicar manutenção realizada no progres para a
                            procedure "pc_busca_sequencial_fatura"
                            (Douglas - Chamado 128278)

               19/08/2014 - Criar procedure bypass pc_gera_titulos_iptu_prog
                            chamado exclusivamente pela b1wgen0016.paga_titulo
                            no Progress (Projeto 03-Float - Rafael).

               04/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir
                            nomenclaturas Cedente por Beneficiário e  Sacado por Pagador
                            Chamado 229313 (Jean Reddiga - RKAM).

               27/07/2015 - #308980 Valida o pagamento em duplicidade dos convenios SICREDI (1154) verificando
                            os últimos 5 anos da craplft, assim como o sicredi, que também valida os últimos
                            5 anos (Carlos)

               22/07/2016 - Ajustada a procedure pc_validacoes_sicredi para ser retirado o bloqueio de
                            pagamento de DARF e DAS via PA 90, Prj. 338. (Jean Michel)

					     19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS pelo
							              InternetBanking (Projeto 338 - Lucas Lunelli)
               12/07/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA
                            Marcelo Telles Coelho - Mouts
               01/09/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA - SPRINT B
                            Marcelo Telles Coelho - Mouts

..............................................................................*/

  /* Procedure para gerar os titulos de iptu */
  PROCEDURE pc_gera_titulos_iptu (pr_cooper          IN INTEGER --Codigo Cooperativa
                                 ,pr_nrdconta        IN INTEGER --Numero da Conta
                                 ,pr_idseqttl        IN crapttl.idseqttl%TYPE --Sequencial do titular
                                 ,pr_inpessoa        IN crapass.inpessoa%TYPE DEFAULT NULL --> Indicador do tipo de pessoa pagadora
                                 ,pr_nrcpfcgc        IN crapass.inpessoa%TYPE DEFAULT NULL --> Numero CPF/CNPJ da pessoa pagadora
                                 ,pr_cod_operador    IN VARCHAR2          --Codigo do operador
                                 ,pr_cod_agencia     IN INTEGER            --Codigo da Agencia
                                 ,pr_nro_caixa       IN INTEGER            --Numero do Caixa
                                 ,pr_nrinsced        IN NUMBER             -- CPF/CNPJ do Cedente
                                 ,pr_idtitdda        IN NUMBER             -- identificador titulo DDA
                                 ,pr_nrinssac        IN NUMBER             -- CPF/CNPJ do Sacado
                                 ,pr_fatura4         IN NUMBER             -- Fatura
                                 ,pr_titulo1         IN NUMBER             -- FORMAT "99999,99999"
                                 ,pr_titulo2         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo3         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo4         IN NUMBER             -- FORMAT "9"
                                 ,pr_titulo5         IN NUMBER             -- FORMAT "zz,zzz,zzz,zzz999"
                                 ,pr_iptu            IN BOOLEAN            --IPTU
                                 ,pr_flgpgdda        IN BOOLEAN            --Indicador pagto DDA
                                 ,pr_codigo_barras   IN VARCHAR2           --Codigo de Barras
                                 ,pr_valor_informado IN NUMBER         --Valor informado
                                 ,pr_vlfatura        IN NUMBER          --Valor da Fatura
                                 ,pr_nrdconta_cob    IN INTEGER        --Numero Conta Cobranca
                                 ,pr_insittit        IN INTEGER        --Situacao Titulo
                                 ,pr_intitcop        IN INTEGER        --Titulo da Cooperativa
                                 ,pr_convenio        IN NUMBER         --Numero Convenio
                                 ,pr_bloqueto        IN OUT NUMBER     --Numero Bloqueto
                                 ,pr_contaconve      IN INTEGER        --Numero Conta Convenio
                                 ,pr_cdcoptfn        IN INTEGER         --Codigo Cooperativa transferencia
                                 ,pr_cdagetfn        IN INTEGER         --Codigo Agencia Transferencia
                                 ,pr_nrterfin        IN INTEGER         --Numero terminal Financeiro
                                 ,pr_flgpgchq        IN BOOLEAN         --Flag pagamento cheque
                                 ,pr_vlrjuros        IN NUMBER         --Valor dos Juros
                                 ,pr_vlrmulta        IN NUMBER         --Valor da Multa
                                 ,pr_vldescto        IN NUMBER         --Valor do Desconto
                                 ,pr_vlabatim        IN NUMBER         --Valor do Abatimento
                                 ,pr_vloutdeb        IN NUMBER         --Valor Saida Debitado
                                 ,pr_vloutcre        IN NUMBER         --Valor Saida Creditado
                                 ,pr_tpcptdoc        IN craptit.tpcptdoc%TYPE DEFAULT 1-- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                                 ,pr_cdctrlcs        IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                 ,pr_tppagmto        IN craptit.tppagmto%TYPE --TIPO DO PAGAMENTO
                                 ,pr_idanafrd        IN tbgen_analise_fraude.idanalise_fraude%TYPE DEFAULT NULL -- Identificador de analise de fraude
                                 ,pr_rowidcob        OUT ROWID         --ROWID da cobranca
                                 ,pr_indpagto        OUT INTEGER       --Indicador Pagamento
                                 ,pr_nrcnvbol        OUT INTEGER       --Numero Convenio Boleto
                                 ,pr_nrctabol        OUT INTEGER       --Numero Conta Boleto
                                 ,pr_nrboleto        OUT INTEGER       --Numero do Boleto
                                 ,pr_histor          OUT INTEGER       --Historico
                                 ,pr_pg              OUT BOOLEAN       --Indicador Pago
                                 ,pr_docto           OUT NUMBER        --Numero documento
                                 ,pr_literal         OUT VARCHAR2      --Descricao Literal
                                 ,pr_ult_sequencia   OUT INTEGER       --Ultima Sequencia
                                 ,pr_cdcritic        OUT INTEGER     --Codigo do erro
                                 ,pr_dscritic        OUT VARCHAR2);   --Descricao do erro

  /* Procedure para chamar a pc_gera_titulos_iptu pelo Progress */
  PROCEDURE pc_gera_titulos_iptu_prog
                                 (pr_cooper          IN INTEGER --Codigo Cooperativa
                                 ,pr_nrdconta        IN INTEGER --Numero da Conta
                                 ,pr_idseqttl        IN crapttl.idseqttl%TYPE --Sequencial do titular
                                 ,pr_cod_operador    IN VARCHAR2           --Codigo do operador
                                 ,pr_cod_agencia     IN INTEGER            --Codigo da Agencia
                                 ,pr_nro_caixa       IN INTEGER            --Numero do Caixa
                                 ,pr_nrinsced        IN NUMBER             -- CPF/CNPJ do Cedente
                                 ,pr_idtitdda        IN NUMBER             -- identificador titulo DDA
                                 ,pr_nrinssac        IN NUMBER             -- CPF/CNPJ do Sacado
                                 ,pr_fatura4         IN NUMBER             -- Fatura
                                 ,pr_titulo1         IN NUMBER             -- FORMAT "99999,99999"
                                 ,pr_titulo2         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo3         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo4         IN NUMBER             -- FORMAT "9"
                                 ,pr_titulo5         IN NUMBER             -- FORMAT "zz,zzz,zzz,zzz999"
                                 ,pr_iptu            IN NUMBER             --IPTU
                                 ,pr_flgpgdda        IN NUMBER             --Indicador pagto DDA
                                 ,pr_codigo_barras   IN VARCHAR2           --Codigo de Barras
                                 ,pr_valor_informado IN NUMBER             --Valor informado
                                 ,pr_vlfatura        IN NUMBER             --Valor da Fatura
                                 ,pr_nrdconta_cob    IN INTEGER            --Numero Conta Cobranca
                                 ,pr_insittit        IN INTEGER            --Situacao Titulo
                                 ,pr_intitcop        IN INTEGER            --Titulo da Cooperativa
                                 ,pr_convenio        IN NUMBER             --Numero Convenio
                                 ,pr_bloqueto        IN OUT NUMBER         --Numero Bloqueto
                                 ,pr_contaconve      IN INTEGER            --Numero Conta Convenio
                                 ,pr_cdcoptfn        IN INTEGER            --Codigo Cooperativa transferencia
                                 ,pr_cdagetfn        IN INTEGER            --Codigo Agencia Transferencia
                                 ,pr_nrterfin        IN INTEGER            --Numero terminal Financeiro
                                 ,pr_flgpgchq        IN NUMBER             --Flag pagamento em cheque
                                 ,pr_vlrjuros        IN NUMBER             --Valor dos Juros
                                 ,pr_vlrmulta        IN NUMBER             --Valor da Multa
                                 ,pr_vldescto        IN NUMBER             --Valor do Desconto
                                 ,pr_vlabatim        IN NUMBER             --Valor do Abatimento
                                 ,pr_vloutdeb        IN NUMBER             --Valor Saida Debitado
                                 ,pr_vloutcre        IN NUMBER             --Valor Saida Creditado
                                 ,pr_tpcptdoc        IN craptit.tpcptdoc%TYPE DEFAULT 1-- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                                 ,pr_cdctrlcs        IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                 ,pr_tppagmto        IN craptit.tppagmto%TYPE --TIPO DO PAGAMENTO
                                 ,pr_recidcob        OUT NUMBER            --RECID da cobranca
                                 ,pr_indpagto        OUT INTEGER           --Indicador Pagamento
                                 ,pr_nrcnvbol        OUT INTEGER           --Numero Convenio Boleto
                                 ,pr_nrctabol        OUT INTEGER           --Numero Conta Boleto
                                 ,pr_nrboleto        OUT INTEGER           --Numero do Boleto
                                 ,pr_histor          OUT INTEGER           --Historico
                                 ,pr_pg              OUT NUMBER            --Indicador Pago
                                 ,pr_docto           OUT NUMBER            --Numero documento
                                 ,pr_literal         OUT VARCHAR2          --Descricao Literal
                                 ,pr_ult_sequencia   OUT INTEGER           --Ultima Sequencia
                                 ,pr_cdcritic        OUT INTEGER           --Codigo do erro
                                 ,pr_dscritic        OUT VARCHAR2);      --Descricao do erro

  /* Procedure para retornar valores titulos iptu */
  PROCEDURE pc_retorna_vlr_titulo_iptu (pr_cooper          IN INTEGER --Codigo Cooperativa
                                       ,pr_nrdconta        IN INTEGER --Numero da Conta
                                       ,pr_idseqttl        IN crapttl.idseqttl%TYPE --Sequencial do titular
                                       ,pr_cod_operador    IN VARCHAR2          --Codigo do operador
                                       ,pr_cod_agencia     IN INTEGER            --Codigo da Agencia
                                       ,pr_nro_caixa       IN INTEGER            --Numero do Caixa
                                       ,pr_titulo1         IN OUT NUMBER             -- FORMAT "99999,99999"
                                       ,pr_titulo2         IN OUT NUMBER             -- FORMAT "99999,999999"
                                       ,pr_titulo3         IN OUT NUMBER             -- FORMAT "99999,999999"
                                       ,pr_titulo4         IN OUT NUMBER             -- FORMAT "9"
                                       ,pr_titulo5         IN OUT NUMBER             -- FORMAT "zz,zzz,zzz,zzz999"
                                       ,pr_codigo_barras   IN OUT VARCHAR2     --Codigo de Barras
                                       ,pr_iptu            IN PLS_INTEGER            --IPTU
                                       ,pr_valor_informado IN NUMBER         --Valor informado
                                       ,pr_cadastro        IN NUMBER             --Numero Cadastro
                                       ,pr_cadastro_conf   IN NUMBER           --Confirmacao Cadastro
                                       ,pr_dt_agendamento  IN DATE            --Data Agendamento
                                       ,pr_cdctrlcs        IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                       ,pr_vlfatura        OUT NUMBER          --Valor da Fatura
                                       ,pr_outra_data      OUT PLS_INTEGER        --Outra data
                                       ,pr_outro_valor     OUT PLS_INTEGER        --Outro valor
                                       ,pr_nrdconta_cob    OUT INTEGER        --Numero Conta Cobranca
                                       ,pr_insittit        OUT INTEGER        --Situacao Titulo
                                       ,pr_intitcop        OUT INTEGER        --Titulo da Cooperativa
                                       ,pr_convenio        OUT NUMBER         --Numero Convenio
                                       ,pr_bloqueto        OUT NUMBER         --Numero Bloqueto
                                       ,pr_contaconve      OUT INTEGER        --Numero Conta Convenio
                                       ,pr_cobregis        OUT PLS_INTEGER    --Cobranca Registrada
                                       ,pr_msgalert        OUT VARCHAR2       --Mensagem de alerta
                                       ,pr_vlrjuros        OUT NUMBER         --Valor dos Juros
                                       ,pr_vlrmulta        OUT NUMBER         --Valor da Multa
                                       ,pr_vldescto        OUT NUMBER         --Valor do Desconto
                                       ,pr_vlabatim        OUT NUMBER         --Valor do Abatimento
                                       ,pr_vloutdeb        OUT NUMBER         --Valor Saida Debitado
                                       ,pr_vloutcre        OUT NUMBER         --Valor Saida Creditado
                                       ,pr_cdcritic        OUT INTEGER     --Codigo do erro
                                       ,pr_dscritic        OUT VARCHAR2);   --Descricao do erro

  /* Calcular Digito verificador Modulo 11 */
  PROCEDURE pc_verifica_digito (pr_nrcalcul IN VARCHAR2       --Numero a ser calculado
		                       ,pr_poslimit IN INTEGER        --Utilizado para validação de dígito adicional de DAS
                               ,pr_nrdigito OUT INTEGER);   --Digito verificador

  /* Procedure para validar o codigo de barras */
  PROCEDURE pc_valida_codigo_barras (pr_cooper         IN VARCHAR2                   --Codigo Cooperativa
                                    ,pr_nrdconta       IN crapttl.nrdconta%TYPE      --Numero da Conta
                                    ,pr_idseqttl       IN crapttl.idseqttl%TYPE      --Sequencial Titular
                                    ,pr_cod_operador   IN VARCHAR2                   --Codigo Operador
                                    ,pr_cod_agencia    IN INTEGER                    --Codigo Agencia
                                    ,pr_nro_caixa      IN INTEGER                    --Numero Caixa
                                    ,pr_codigo_barras  IN OUT VARCHAR2               --Codigo Barras
                                    ,pr_cdcritic       OUT INTEGER     --Codigo do erro
                                    ,pr_dscritic       OUT VARCHAR2);   --Descricao do erro

  /*Validação referente aos dias de tolerancia nos convênios Sicredi*/
  PROCEDURE pc_verifica_dtlimite_tributo(pr_cdcooper      IN INTEGER     -- Codigo Cooperativa
                                        ,pr_cdagenci      IN INTEGER     --Codigo Agencia
                                        ,pr_cdempcon      IN crapcon.cdempcon%TYPE -- Codigo Empresa Convenio
                                        ,pr_cdsegmto      IN crapcon.cdsegmto%TYPE -- Codigo Segmento Convenio
                                        ,pr_codigo_barras IN VARCHAR2    -- Codigo barras
                                        ,pr_dtmvtopg      IN DATE        -- Data da operação
                                        ,pr_flnrtole      IN BOOLEAN DEFAULT TRUE -- Verificar se a tolerância é ilimitada
										                    ,pr_dttolera      OUT DATE       -- Data de Tolerância (Vencimento)
                                        ,pr_cdcritic      OUT INTEGER    -- Codigo do erro
                                        ,pr_dscritic      OUT VARCHAR2);

  /* Procedure para retornar valores fatura */
  PROCEDURE pc_retorna_valores_fatura (pr_cdcooper      IN INTEGER      --Codigo Cooperativa
                                      ,pr_nrdconta      IN INTEGER      --Numero da Conta
                                      ,pr_idseqttl      IN INTEGER      --Sequencial Titular
                                      ,pr_cod_operador  IN VARCHAR2     --Codigo Operador
                                      ,pr_cod_agencia   IN INTEGER      --Codigo Agencia
                                      ,pr_nro_caixa     IN INTEGER      --Numero Caixa
                                      ,pr_fatura1       IN NUMBER       --Parte 1 fatura
                                      ,pr_fatura2       IN NUMBER       --Parte 2 fatura
                                      ,pr_fatura3       IN NUMBER       --Parte 3 fatura
                                      ,pr_fatura4       IN NUMBER       --Parte 4 fatura
                                      ,pr_codigo_barras IN OUT VARCHAR2 --Codigo barras
                                      ,pr_cdseqfat      OUT NUMBER      --Sequencial faturamento
                                      ,pr_vlfatura      OUT NUMBER      --Valor Fatura
                                      ,pr_nrdigfat      OUT INTEGER     --Digito Faturamento
                                      ,pr_iptu          OUT BOOLEAN     --Indicador IPTU
                                      ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                      ,pr_dscritic      OUT VARCHAR2); --Descricao do erro

  /* Function para buscar sequencial da fatura */
  FUNCTION fn_busca_sequencial_fatura (pr_cdhistor      IN crapcon.cdhistor%TYPE --Codigo historico
                                      ,pr_codigo_barras IN VARCHAR2)             --Codigo Barras
                                       RETURN NUMBER;

  /* Procedure para buscar sequencial da fatura */
  PROCEDURE pc_busca_sequencial_fatura (pr_cdhistor      IN crapcon.cdhistor%type    --Codigo historico
                                       ,pr_codigo_barras IN VARCHAR2                 --Codigo Barras
                                       ,pr_cdseqfat      OUT NUMBER                  --Numero Sequencial Fatura
                                       ,pr_cdcritic      OUT INTEGER   --Codigo do erro
                                       ,pr_dscritic      OUT VARCHAR2); --Descricao do erro

  /* Procedure para gerar as faturas */
  PROCEDURE pc_gera_faturas (pr_cdcooper      IN INTEGER      --Codigo Cooperativa
                            ,pr_nrdconta      IN INTEGER      --Numero da Conta
                            ,pr_idseqttl      IN INTEGER      --Sequencial Titular
                            ,pr_cod_operador  IN VARCHAR2     --Codigo Operador
                            ,pr_cod_agencia   IN INTEGER      --Codigo Agencia
                            ,pr_nro_caixa     IN INTEGER      --Numero Caixa
                            ,pr_cdbarras      IN VARCHAR2     --Codigo barras
                            ,pr_cdseqfat      IN NUMBER       --Sequencial faturamento
                            ,pr_vlfatura      IN NUMBER       --Valor Fatura
                            ,pr_nrdigfat      IN INTEGER      --Digito Faturamento
                            ,pr_valorinf      IN NUMBER       --Valor Informado
                            ,pr_cdcoptfn      IN INTEGER      --Cooperativa do terminal financeiro
                            ,pr_cdagetfn      IN INTEGER      --Agencia do terminal financeiro
                            ,pr_nrterfin      IN INTEGER      --Numero Terminal Financeiro
                            ,pr_tpcptdoc      IN craptit.tpcptdoc%TYPE DEFAULT 1-- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                            ,pr_dsnomfon      IN VARCHAR2 DEFAULT ' ' -- Numero do Telefone
                            ,pr_identificador IN VARCHAR2 DEFAULT ' ' -- Identificador FGTS/DAE
                            ,pr_idanafrd      IN tbgen_analise_fraude.idanalise_fraude%TYPE DEFAULT NULL -- Identificador de analise de fraude
                            ,pr_histor        OUT INTEGER     --Codigo Historico
                            ,pr_pg            OUT BOOLEAN     --Indicador Pago
                            ,pr_docto         OUT NUMBER      --Numero Documento
                            ,pr_literal       OUT VARCHAR2    --Literal
                            ,pr_ult_sequencia OUT INTEGER     --Ultima Sequencia
                            ,pr_cdcritic      OUT INTEGER   --Codigo do erro
                            ,pr_dscritic      OUT VARCHAR2); --Descricao do erro

  PROCEDURE pc_calcula_data_vencimento (pr_dtmvtolt     IN DATE          --Data Movimento
                                       ,pr_de_campo     IN INTEGER       --Fator
                                       ,pr_dtvencto     OUT DATE         --Sequencial do titular
                                       ,pr_cdcritic     OUT INTEGER      --Código do erro
                                       ,pr_dscritic     OUT VARCHAR2);   --Descricao do erro

  /* Procedure para identificar titulo cooperativa */
  PROCEDURE pc_identifica_titulo_coop (pr_cooper        IN INTEGER   --Codigo Cooperativa
                                      ,pr_nro_conta     IN INTEGER   --Numero Conta
                                      ,pr_idseqttl      IN INTEGER   --Sequencial do Titular
                                      ,pr_cod_agencia   IN INTEGER   --Codigo da Agencia
                                      ,pr_nro_caixa     IN INTEGER   --Numero Caixa
                                      ,pr_codbarras     IN VARCHAR2  --Codigo Barras
                                      ,pr_flgcritica    IN BOOLEAN   --Flag Critica
                                      ,pr_nrdconta      OUT INTEGER  --Numero da Conta
                                      ,pr_insittit      OUT INTEGER  --Situacao Titulo
                                      ,pr_intitcop      OUT INTEGER  --Indicador titulo cooperativa
                                      ,pr_convenio      OUT NUMBER   --Numero Convenio
                                      ,pr_bloqueto      OUT NUMBER   --Numero Boleto
                                      ,pr_contaconve    OUT INTEGER  --Conta do Convenio
                                      ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                      ,pr_dscritic      OUT VARCHAR2); --Descricao do erro

  /* Procedure para identificar titulo cooperativa */
  PROCEDURE pc_identifica_titulo_coop2 (pr_cooper        IN INTEGER   --Codigo Cooperativa
                                      ,pr_nro_conta     IN INTEGER   --Numero Conta
                                      ,pr_idseqttl      IN INTEGER   --Sequencial do Titular
                                      ,pr_cod_agencia   IN INTEGER   --Codigo da Agencia
                                      ,pr_nro_caixa     IN INTEGER   --Numero Caixa
                                      ,pr_codbarras     IN VARCHAR2  --Codigo Barras
                                      ,pr_flgcritica    IN BOOLEAN   --Flag Critica
                                      ,pr_nrdconta      OUT INTEGER  --Numero da Conta
                                      ,pr_insittit      OUT INTEGER  --Situacao Titulo
                                      ,pr_intitcop      OUT INTEGER  --Indicador titulo cooperativa
                                      ,pr_convenio      OUT NUMBER   --Numero Convenio
                                      ,pr_bloqueto      OUT NUMBER   --Numero Boleto
                                      ,pr_contaconve    OUT INTEGER  --Conta do Convenio
                                      ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                      ,pr_dscritic      OUT VARCHAR2); --Descricao do erro

 PROCEDURE pc_calcula_vlr_titulo_vencido (pr_vltitulo      IN crapcob.vltitulo%TYPE  -- Valor do titulo em cobrança
                                         ,pr_tpdmulta      IN crapcob.tpdmulta%TYPE  -- Tipo de multa (1 - Valor Dia / 2 - Mensal / 3 - Isento)
                                         ,pr_vlrmulta      IN crapcob.vlrmulta%TYPE  -- Contem o valor da multa
                                         ,pr_tpjurmor      IN crapcob.tpjurmor%TYPE  -- Tipo de juros (1 - Valor Dia / 2 - Mensal / 3 - Isento)
                                         ,pr_vljurdia      IN crapcob.vljurdia%TYPE  -- Contem o valor de juros ao dia
                                         ,pr_qtdiavenc     IN PLS_INTEGER            -- Quantidade de dias para vencimento
                                         ,pr_vlfatura      OUT crapcob.vltitulo%TYPE -- Valor da fatura
                                         ,pr_vlrmulta_calc OUT crapcob.vlrmulta%TYPE -- Contem o valor da multa calculado
                                         ,pr_vlrjuros_calc OUT crapcob.vljurdia%TYPE -- Contem o valor do juros calculado
                                         ,pr_dscritic      OUT VARCHAR2);            -- Descricao do erro

PROCEDURE pc_retorna_vlr_tit_vencto (pr_cdcooper      IN INTEGER    -- Cooperativa
                                    ,pr_nrdconta      IN INTEGER    -- Conta
                                    ,pr_idseqttl      IN INTEGER    -- Titular
                                    ,pr_cdagenci      IN INTEGER    -- Agência
                                    ,pr_nrdcaixa      IN INTEGER    -- Caixa
                                    ,pr_titulo1       IN NUMBER     -- FORMAT "99999,99999"
                                    ,pr_titulo2       IN NUMBER     -- FORMAT "99999,999999"
                                    ,pr_titulo3       IN NUMBER     -- FORMAT "99999,999999"
                                    ,pr_titulo4       IN NUMBER     -- FORMAT "9"
                                    ,pr_titulo5       IN NUMBER     -- FORMAT "zz,zzz,zzz,zzz999"
                                    ,pr_codigo_barras IN VARCHAR2   -- Codigo de Barras
                                    ,pr_vlfatura      OUT NUMBER    -- Valor da fatura
                                    ,pr_vlrjuros      OUT NUMBER    -- Valor dos juros
                                    ,pr_vlrmulta      OUT NUMBER    -- Valor da multa
                                    ,pr_fltitven      OUT NUMBER    -- Indicador Vencido
                                    ,pr_des_erro      OUT VARCHAR2  -- Indicador erro OK/NOK
                                    ,pr_dscritic      OUT VARCHAR2);

/* Retonar o ano do codigo barras do Darf Europa */
FUNCTION fn_ret_ano_barras_darf (pr_innumano IN INTEGER) -- Numero Ano
RETURN INTEGER;

  /* Procedure para verificar vencimento titulo */
  PROCEDURE pc_verifica_vencimento_titulo (pr_cod_cooper     IN INTEGER  --Codigo Cooperativa
                                          ,pr_cod_agencia     IN INTEGER  --Codigo da Agencia
                                          ,pr_dt_agendamento  IN DATE     --Data Agendamento
                                          ,pr_dt_vencto       IN DATE     --Data Vencimento
                                          ,pr_critica_data    OUT BOOLEAN --Critica na validacao
                                          ,pr_cdcritic        OUT INTEGER --Codigo da Critica
                                          ,pr_dscritic        OUT VARCHAR2 --Descricao do erro
                                          ,pr_tab_erro        OUT GENE0001.typ_tab_erro);  --Tabela retorno erro

 /* Retonar o ano do codigo barras do Darf Europa */
PROCEDURE pc_ret_ano_barras_darf_car (pr_innumano IN INTEGER,
                                      pr_outnumano OUT INTEGER); -- Numero Ano

  /* Procedure para estornar títulos iptu  - Demetrius Wolff - Mouts*/
  PROCEDURE pc_estorna_titulos_iptu (pr_cdcooper      IN  INTEGER    --Codigo Cooperativa
                                    ,pr_cod_operador  IN  VARCHAR2   --Codigo Operador
                                    ,pr_cod_agencia   IN  INTEGER    --Codigo Agencia
                                    ,pr_nro_caixa     IN  INTEGER    --Numero Caixa
                                    ,pr_iptu          IN  NUMBER    --IPTU
                                    ,pr_codigo_barras IN  VARCHAR2   -- Codigo de Barras
                                    ,pr_histor        OUT INTEGER    --Codigo Historico
                                    ,pr_pg            OUT NUMBER    --Indicador Pago
                                    ,pr_docto         OUT NUMBER     --Numero Documento
                                    ,pr_cdcritic      OUT INTEGER    --Codigo do erro
                                    ,pr_dscritic      OUT VARCHAR2); --Descricao do erro

  /* Retonar o ano do codigo barras */
  FUNCTION fn_retorna_ano_cdbarras (pr_innumano IN INTEGER  --Numero do Ano
                                   ,pr_darfndas IN BOOLEAN) --Darf/Ndas
           RETURN INTEGER;

  /* Retonar a data do c¿digo barras em dias */
  FUNCTION fn_retorna_data_dias (pr_nrdedias  IN INTEGER  --Numero de Dias
                                ,pr_inanocal  IN INTEGER) --Indicador do Ano
           RETURN DATE;

  --> Procedure para estornar faturas
  PROCEDURE pc_estorna_faturas ( pr_cdcooper      IN INTEGER       --Codigo Cooperativa
                                ,pr_cdoperad      IN VARCHAR2      --Codigo Operador
                                ,pr_cdagenci      IN INTEGER       --Codigo Agencia
                                ,pr_nrdcaixa      IN INTEGER       --Numero Caixa
                                ,pr_cddbarra      IN VARCHAR2      --Codigo de Barras
                                ,pr_cdseqfat      IN VARCHAR2      --Codigo sequencial da fatura
                                ,pr_cdhistor      OUT INTEGER      --Codigo Historico
                                ,pr_pg            OUT NUMBER       --Indicador Pago
                                ,pr_nrdocmto      OUT NUMBER       --Numero Documento
                                ,pr_cdcritic      OUT INTEGER      --Codigo do erro
                                ,pr_dscritic      OUT VARCHAR2);   --Descricao do erro

  --> Procedure para gerar a linha digitavel a fatura em base do codigo de barras
  PROCEDURE pc_calc_lindig_fatura ( pr_cdbarras IN  VARCHAR2
                                   ,pr_lindigit OUT VARCHAR2);
                                   
  /* Calcular Digito adicional */
  PROCEDURE pc_calcula_dv_adicional (pr_cdbarras IN VARCHAR2       --Codigo barras
                                    ,pr_poslimit IN INTEGER        --Utilizado para validação de dígito adicional de DAS
                                    ,pr_nrdigito IN INTEGER        --Numero a ser calculado
                                    ,pr_flagdvok OUT BOOLEAN) ;   --Digito correto sim/nao                                
   
  /* Procedures para calculo de DV do numero da DAS e DV's adicionais da DAS  */
  PROCEDURE pc_calcula_dv_numero_das (pr_numerdas IN VARCHAR2       --Codigo barras
                                     ,pr_dvnrodas IN INTEGER        --Utilizado para validação de dígito adicional de DAS
                                     ,pr_flagdvok OUT BOOLEAN);  --Digito correto sim/nao
                                     
END CXON0014;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cxon0014 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXON0014
  --  Sistema  : Procedimentos e funcoes das transacoes do caixa online
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 25/02/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos e funcoes das transacoes do caixa online
  --
  -- Alteracoes: 29/05/2014 - Removido as validacoes para Sicredi (1154), Samae
  --                          Jaragua (396), DARE Sefaz (1063). Alterado o tamanho do
  --                          substr do codigo de barras da procedure
  --                          "pc_busca_sequencial_fatura" (Douglas - Chamado 128278)
  --
  --             18/06/2014 - Removido as validacoes para GNRE - SEFAZ (1065).
  --                         (Douglas - Chamado 128278)
    --
    --             25/01/2015 - Adicionada validação por meio de arrecadação pelo
  --                          campo crapscn.dsoparre para Conv. Sicredi (Lunelli SD 234418)
  --
    --             11/03/2015 - Adicionada verificação pelo dígito 8 no início do cdbarra
  --                          de faturas na rotina 'pc_retorna_valores_fatura' (Lunelli SD 245425).
  --
  --             12/03/2015 - #202833 Tratamento para não aceitar títulos do Banco Boavista (231) (Carlos)
  --
  --             29/04/2015 - #267196 Tratamento para não aceitar títulos do Banco Standard (012) (Carlos)
  --
  --             05/06/2015 - Remover validações para o convenio 963 Foz do brasil (Lucas Ranghetti #292200)
  --
  --             02/07/2015 - #302133 Tratamento para não aceitar títulos do Banco Itaubank (479) (Carlos)
  --
  --             27/07/2015 - #308980 Valida o pagamento em duplicidade dos convenios SICREDI (1154) verificando
  --                          os últimos 5 anos da craplft, assim como o sicredi, que também valida os últimos
  --                          5 anos (Carlos)
  --
  --             14/08/2015 - pc_gera_titulo_iptu e pc_gera_faturas -> inclusão do parametro pr_tpcptdoc, para identificacao do tipo de captura
  --                          (leitora ou manual(linha digitavel)) (Odirlei-AMcom)
  --
  --             04/01/2016 - Ajuste na leitura da tabela cracbf para utilizar UPPER nos campos VARCHAR
  --                          pois será incluido o UPPER no indice desta tabela - SD 375854
  --                          (Adriano).
  --
  --             11/01/2016 - Ajuste na leitura da tabela cracbf para utilizar UPPER nos campos VARCHAR
  --                          pois será incluido o UPPER no indice desta tabela - SD 375854
  --                          (Adriano).
  --
  --             22/07/2016 - Ajustada a procedure pc_validacoes_sicredi para ser retirado o bloqueio de
  --                          pagamento de DARF e DAS via PA 90, Prj. 338. (Jean Michel)
	--
  --             25/08/2016 - #456682 Inclusao de ip na tentativa de pagamento de boleto incluido na crapcbf (Carlos)
  --
	--             19/09/2016 - Alteraçoes pagamento/agendamento de DARF/DAS pelo
	--						              InternetBanking (Projeto 338 - Lucas Lunelli)
  --
  --             10/01/2017 - Ajustar a procedure pc_verifica_vencimento_titulo para verificar se a conta que
  --                          esta realizando o pagando/agendametno um titulo 085, e possuir privilegios de
  --                          PAGADORVIP, não calcula multa e juros para o titulo (Douglas - Chamado 551630).
  --
  --             07/02/2017 - Ajustes para verificar vencimento da P.M. PRES GETULIO, P.M. GUARAMIRIM e SANEPAR
  --                          (Tiago/Fabricio SD593203)
  --
  --              13/01/2017 - Criar procedure/function ret_ano_barras_darf
  --                           para a nova regra de validacao das DARFs
  --                           (Lucas Ranghetti #588835)
  --
  --              20/03/2017 - Ajuste para verificar vencimento da P.M. TIMBO, DEFESA CIVIL TIMBO
  --                           MEIO AMBIENTE DE TIMBO, TRANSITO DE TIMBO (Lucas Ranghetti #630176)
  --
  --              12/04/2017 - Ajuste para verificar vencimento da P.M. AGROLANDIA (Tiago #647174)
    --
  --              19/04/2017 - Estornar títulos iptu  - Demetrius Wolff - Mouts
  --
  --              22/05/2017 - Ajustes para verificar vencimento da P.M. TROMBUDO CENTRAL
  --                           e FMS TROMBUDO CENTRAL (Tiago/Fabricio #653830)
  --
  --              26/05/2017 - Ajustes para verificar vencimento da P.M. AGROLANDIA
  --                           (Tiago/Fabricio #647174)

  --              13/06/2017 - Retirado validacao incorreta na procedure pc_retorna_vlr_titulo_iptu
  --                          (Tiago/Elton #691470)
  --
  --              07/12/2017 - Melhoria 458, adicionado campo v_tppagmto na procedure pc_gera_titulos_iptu_prog
  --                           e na procedure pc_gera_titulos_iptu - Antonio R. Jr (Mouts)
  --
  --              11/12/2017 - Alterar campo flgcnvsi por tparrecd.
  --                           PRJ406-FGTS (Odirlei-AMcom)
  --
  --              14/02/2018 - Projeto Ligeirinho. Alterado para gravar na tabela de lotes (craplot) somente no final
  --                           da execução do CRPS509 => INTERNET E TAA. (Fabiano Girardi AMcom)
  --
  --              04/07/2018 - Projeto Ligeirinho. Ajustes atualização na CRAPLOT #40089 (Mário AMcom)
  --
  --              03/09/2018 - Correção para remover lote (Jonata - Mouts).

  --
  --              21/12/2018 - inc0028676 Retornando a versão do package para correçao da criação/atualização
  --                           do lote na rotina pc_gera_faturas (Carlos)
  --
  --              25/02/2019 - Inclusão de novas validações no código de barras para DARF/DAS
  --                           (sctask0046009 - Adriano).
  --
  --              08/05/2019 - Aplicar critica da quantidade de dias para "data vencimento" e "periodo de apuração" para DARF 64 e 153.
  --                           Com isso, em caso de falhas na digitação pelo cooperado o sistema irá criticar.
  --                           (INC0014834 - Wagner - Sustentação).  
  --
  --              25/06/2019 - Alterado ponto de validação da critica da quantidade de dias para "data vencimento" e "periodo de apuração" para DARF 64 e 153.
  --                           (INC0018809 - Jackson - Sustentação).  
  ---------------------------------------------------------------------------------------------------------------

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nrtelura
          ,crapcop.dsdircop
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.flgoppag
          ,crapcop.flgopstr
          ,crapcop.inioppag
          ,crapcop.fimoppag
          ,crapcop.iniopstr
          ,crapcop.fimopstr
          ,crapcop.cdagebcb
          ,crapcop.dssigaut
          ,crapcop.cdagesic
          ,crapcop.nrtelsac
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  /* Busca dos dados do associado */
  CURSOR cr_crapass(pr_cdcooper IN craptab.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT crapass.nrdconta
          ,crapass.nmprimtl
          ,crapass.inpessoa
          ,crapass.cdagenci
          ,crapass.vllimcre
          ,crapass.nrdctitg
          ,crapass.nrcpfcgc
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;
  rw_crapass_pag cr_crapass%ROWTYPE;

  --Selecionar informacoes dos bancos
  CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
    SELECT crapban.nmresbcc
          ,crapban.nmextbcc
          ,crapban.cdbccxlt
          ,crapban.nrispbif
    FROM crapban
    WHERE crapban.cdbccxlt = pr_cdbccxlt;
  rw_crapban cr_crapban%ROWTYPE;

  --Selecionar Informacoes das Agencias
  CURSOR cr_crapagb (pr_cddbanco IN crapagb.cddbanco%TYPE) IS
    SELECT crapagb.cddbanco
    FROM crapagb
    WHERE crapagb.cddbanco = pr_cddbanco
      AND UPPER(crapagb.cdsitagb) = 'S';
  rw_crapagb cr_crapagb%ROWTYPE;

  --Buscar informacoes de lote
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT  craplot.nrdolote
           ,craplot.nrseqdig
           ,craplot.cdbccxlt
           ,craplot.tplotmov
           ,craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.cdhistor
           ,craplot.cdoperad
           ,craplot.qtcompln
           ,craplot.qtinfoln
           ,craplot.vlcompcr
           ,craplot.vlinfocr
           ,craplot.vlcompdb
           ,craplot.vlinfodb
           ,craplot.rowid
    FROM craplot craplot
    WHERE craplot.cdcooper = pr_cdcooper
    AND   craplot.dtmvtolt = pr_dtmvtolt
    AND   craplot.cdagenci = pr_cdagenci
    AND   craplot.cdbccxlt = pr_cdbccxlt
    AND   craplot.nrdolote = pr_nrdolote
    FOR UPDATE NOWAIT;

  rw_craplot cr_craplot%ROWTYPE;

  --Testar se o lote esta em lock
  CURSOR cr_craplot_rowid (pr_rowid IN ROWID) IS
    SELECT  1
    FROM craplot craplot
    WHERE craplot.rowid = pr_rowid
    FOR UPDATE NOWAIT;
  rw_craplot_rowid cr_craplot_rowid%ROWTYPE;

  --Selecionar Convenio
  CURSOR cr_crapscn (pr_cdempcon IN crapscn.cdempcon%type
                    ,pr_cdsegmto IN crapscn.cdsegmto%type
                    ,pr_tipo     IN INTEGER) IS
    SELECT crapscn.cdsegmto
          ,crapscn.nrtolera
          ,crapscn.dsdiatol
          ,crapscn.cdempres
          ,crapscn.dsoparre
    FROM crapscn
    WHERE ((pr_tipo = 1 AND crapscn.cdempcon = pr_cdempcon) OR
           (pr_tipo = 2 AND crapscn.cdempco2 = pr_cdempcon) OR
           (pr_tipo = 3 AND crapscn.cdempco3 = pr_cdempcon) OR
           (pr_tipo = 4 AND crapscn.cdempco4 = pr_cdempcon) OR
           (pr_tipo = 5 AND crapscn.cdempco5 = pr_cdempcon)
          )
    AND   crapscn.cdsegmto = pr_cdsegmto
    AND   crapscn.dtencemp IS NULL
    AND   crapscn.dsoparre <> 'E'
    ORDER BY crapscn.progress_recid ASC;

  --Selecionar transacao de convenio
  CURSOR cr_crapstn (pr_cdempres IN crapstn.cdempres%type
                    ,pr_tpmeiarr IN crapstn.tpmeiarr%type) IS
    SELECT crapstn.cdempres
          ,crapstn.tpmeiarr
          ,crapstn.dstipdrf
    FROM crapstn
    WHERE UPPER(crapstn.cdempres) = UPPER(pr_cdempres)
    AND   UPPER(crapstn.tpmeiarr) = UPPER(pr_tpmeiarr);

  --Selecionar informacoes convenio cobranca
  CURSOR cr_crapcco (pr_cdcooper IN crapcco.cdcooper%type
                    ,pr_nrconven IN crapcco.nrconven%TYPE) IS
    SELECT crapcco.cddbanco
          ,crapcco.dsorgarq
          ,crapcco.flgutceb
          ,crapcco.nrconven
          ,crapcco.nrdctabb
          ,crapcco.vlrtarnt
          ,crapcco.vltrftaa
          ,crapcco.vlrtarcx
          ,crapcco.flgregis
          ,crapcco.flgativo
          ,crapcco.cdagenci
          ,crapcco.cdbccxlt
          ,crapcco.nrdolote
          ,crapcco.qtdfloat
    FROM crapcco
    WHERE crapcco.cdcooper = pr_cdcooper
    AND   crapcco.nrconven = pr_nrconven;
  rw_crapcco cr_crapcco%ROWTYPE;

  --Selecionar Informacoes Convenios
  CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                    ,pr_cdempcon IN crapcon.cdempcon%type
                    ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
    SELECT crapcon.flginter
          ,crapcon.nmextcon
          ,crapcon.tparrecd
          ,crapcon.cdhistor
          ,crapcon.nmrescon
          ,crapcon.cdempcon
          ,crapcon.cdsegmto
    FROM crapcon
    WHERE crapcon.cdcooper = pr_cdcooper
    AND   crapcon.cdempcon = pr_cdempcon
    AND   crapcon.cdsegmto = pr_cdsegmto;
  rw_crapcon cr_crapcon%ROWTYPE;

  --Selecionar informacoes da autenticacao
  CURSOR cr_crapaut (pr_rowid IN ROWID) IS
    SELECT crapaut.cdcooper
          ,crapaut.dtmvtolt
          ,crapaut.cdagenci
          ,crapaut.nrdcaixa
          ,crapaut.vldocmto
          ,crapaut.hrautent
          ,crapaut.nrsequen
          ,crapaut.cdopecxa
          ,crapaut.cdhistor
          ,crapaut.dsprotoc
          ,crapaut.nrdocmto
          ,crapaut.ROWID
    FROM crapaut
    WHERE ROWID = pr_rowid;
  rw_crapaut cr_crapaut%ROWTYPE;

  --Selecionar informacoes log transacoes no sistema
  CURSOR cr_craplgm(pr_cdcooper IN craplgm.cdcooper%type,
                    pr_nrdconta IN craplgm.nrdconta%type,
                    pr_idseqttl IN craplgm.idseqttl%type,
                    pr_dttransa IN craplgm.dttransa%type,
                    pr_dsorigem IN craplgm.dsorigem%type,
                    pr_cdoperad IN craplgm.cdoperad%type,
                    pr_flgtrans IN craplgm.flgtrans%type,
                    pr_dstransa IN craplgm.dstransa%TYPE) IS
    SELECT m.hrtransa
          ,i.dsdadatu
      FROM craplgm m
          ,craplgi i
     WHERE m.cdcooper = pr_cdcooper
       AND m.nrdconta = pr_nrdconta
       AND m.idseqttl = pr_idseqttl
       AND m.dsorigem = 'INTERNET'
       AND m.cdoperad = '996'
       AND m.dttransa = pr_dttransa
       AND i.nmdcampo = 'IP'
       AND m.cdcooper = i.cdcooper
       AND m.nrdconta = i.nrdconta
       AND m.idseqttl = i.idseqttl
       AND m.dttransa = i.dttransa
       AND m.hrtransa = i.hrtransa
       AND m.nrsequen = i.nrsequen
       AND m.dstransa = pr_dstransa
     ORDER BY m.progress_recid DESC;

  --Tipo de registro do tipo data
  rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

  /* Procedure para selecionar o valor das tarifas bancarias */
  PROCEDURE pc_pega_valor_tarifas (pr_cdcooper  IN  INTEGER               --Codigo da Cooperativa
                                  ,pr_nrdconta  IN  INTEGER               --Numero Conta
                                  ,pr_nrcnvcob  IN  crapcob.nrcnvcob%type --Numero Convenio Cobranca
                                  ,pr_inpessoa  IN  INTEGER               --Tipo pessoa
                                  ,pr_histarcx  OUT INTEGER               --Historico Caixa
                                  ,pr_histarnt  OUT INTEGER               --Historico Internet
                                  ,pr_histrtaa  OUT INTEGER               --Historico transferencia taa
                                  ,pr_cdhisest  OUT INTEGER               --Codigo Historico Estorno
                                  ,pr_dtdivulg  OUT DATE                  --Data Divulgacao
                                  ,pr_dtvigenc  OUT DATE                  --Data Vigencia
                                  ,pr_cdfvlccx  OUT INTEGER               --Codigo Faixa Valor Caixa
                                  ,pr_vlrtarcx  OUT NUMBER                --Valor tarifa caixa
                                  ,pr_vlrtarnt  OUT NUMBER                --Valor tarifa
                                  ,pr_vltrftaa  OUT NUMBER                --Valor transferencia taa
                                  ,pr_cdfvlcnt  OUT INTEGER               --Codigo Faixa Conta
                                  ,pr_cdfvltaa  OUT INTEGER               --Codigo Faixa TAA
                                  ,pr_tab_erro  OUT gene0001.typ_tab_erro --Tabela retorno erro
                                  ,pr_cdcritic  OUT INTEGER               --Codigo Critica
                                  ,pr_dscritic  OUT VARCHAR2) IS          --Descricao Critica
    /* .........................................................................
    --
    --  Programa : pc_pega_valor_tarifas           Antigo: b2crap14.p/pega_valor_tarifas
    --  Sistema  : Cred
    --  Sigla    : CXON0014
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 15/02/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para selecionar o valor das tarifas bancarias
    --
    --   Atualização: 09/05/2014 - Ajustado para somente buscar tarifa se for
    --                               inpessoa <> 3 (sem fins lucartivos) (Odirlei/AMcom)
    --
    --                15/02/2016 - Inclusao do parametro conta na chamada da
    --                             TARI0001.pc_carrega_dados_tarifa_cobr. (Jaison/Marcos)
    --
    -- ......................................................................... */
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_histar INTEGER;
      vr_vlrtar NUMBER;
      vr_cdfvl  INTEGER;
      vr_motivo VARCHAR2(2);
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar parametros retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --só buscar tarifa se for inpessoa <> 3(sem fins lucartivos)
      -- se for 3 vltarifa ficará zero
      IF pr_inpessoa = 3 THEN
        pr_vlrtarcx:= 0;
        pr_vlrtarnt:= 0;
        pr_vltrftaa:= 0;
      ELSE

        --Percorrer os 3 tipos
        FOR idx IN 1..3 LOOP
          --Atribuir valor do Motivo
          CASE idx
            WHEN 1 THEN vr_motivo:= '03'; /* Caixa da cooperativa */
            WHEN 2 THEN vr_motivo:= '33'; /* Internet banking */
            WHEN 3 THEN vr_motivo:= '32'; /* TAA */
          END CASE;

          --Buscar dados tarifa cobranca
          TARI0001.pc_carrega_dados_tarifa_cobr (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                ,pr_nrdconta  => pr_nrdconta  --Numero Conta
                                                ,pr_nrconven  => pr_nrcnvcob  --Numero Convenio
                                                ,pr_dsincide  => 'RET'        --Descricao Incidencia
                                                ,pr_cdocorre  => 0            --Codigo Ocorrencia
                                                ,pr_cdmotivo  => vr_motivo    --Codigo Motivo
                                                ,pr_inpessoa  => pr_inpessoa  --Tipo Pessoa
                                                ,pr_vllanmto  => 1            --Valor Lancamento
                                                ,pr_cdprogra  => NULL         --Nome Programa
                                                ,pr_flaputar  => 0            --Nao apurar
                                                ,pr_cdhistor  => vr_histar    --Codigo Historico
                                                ,pr_cdhisest  => pr_cdhisest  --Historico Estorno
                                                ,pr_vltarifa  => vr_vlrtar    --Valor Tarifa
                                                ,pr_dtdivulg  => pr_dtdivulg  --Data Divulgacao
                                                ,pr_dtvigenc  => pr_dtvigenc  --Data Vigencia
                                                ,pr_cdfvlcop  => vr_cdfvl     --Codigo Faixa
                                                ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                                ,pr_dscritic  => vr_dscritic); --Descricao Critica
          --Se ocorrer erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Determinar o parametro que ira retornar
          CASE idx
            WHEN 1 THEN
              pr_histarcx:= vr_histar;
              pr_vlrtarcx:= vr_vlrtar;
              pr_cdfvlccx:= vr_cdfvl;
            WHEN 2 THEN
              pr_histarnt:= vr_histar;
              pr_vlrtarnt:= vr_vlrtar;
              pr_cdfvlcnt:= vr_cdfvl;
            WHEN 3 THEN
              pr_histrtaa:= vr_histar;
              pr_vltrftaa:= vr_vlrtar;
              pr_cdfvltaa:= vr_cdfvl;
          END CASE;
        END LOOP;
      END IF; -- FIM IF inpessoa <> 3
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CXON0014.pc_pega_valor_tarifas. '||sqlerrm;
    END;
  END pc_pega_valor_tarifas;

  /* Procedure para selecionar o valor das tarifas bancarias */
  PROCEDURE pc_efetua_lanc_craplat (pr_cdcooper IN INTEGER --Codigo Cooperativa
                                   ,pr_nrdconta IN INTEGER --Numero da Conta
                                   ,pr_dtmvtolt IN DATE    --Data Lancamento
                                   ,pr_cdhistor IN INTEGER --Codigo Historico
                                   ,pr_vllanaut IN NUMBER  --Valor lancamento automatico
                                   ,pr_cdoperad IN VARCHAR2 --Codigo Operador
                                   ,pr_cdagenci IN INTEGER  --Codigo Agencia
                                   ,pr_cdbccxlt IN INTEGER  --Codigo banco caixa
                                   ,pr_nrdolote IN INTEGER  --Numero do lote
                                   ,pr_tpdolote IN INTEGER  --Tipo do lote
                                   ,pr_nrdocmto IN NUMBER   --Numero do documento
                                   ,pr_nrdctabb IN INTEGER  --Numero da conta
                                   ,pr_nrdctitg IN VARCHAR2 --Numero da conta integracao
                                   ,pr_cdpesqbb IN VARCHAR2 --Codigo pesquisa
                                   ,pr_cdbanchq IN INTEGER  --Codigo Banco Cheque
                                   ,pr_cdagechq IN INTEGER  --Codigo Agencia Cheque
                                   ,pr_nrctachq IN INTEGER  --Numero Conta Cheque
                                   ,pr_flgaviso IN BOOLEAN  --Flag aviso
                                   ,pr_tpdaviso IN INTEGER  --Tipo aviso
                                   ,pr_cdfvlcop IN INTEGER  --Codigo cooperativa
                                   ,pr_inproces IN INTEGER  --Indicador processo
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro --Tabela retorno erro
                                   ,pr_cdcritic OUT INTEGER --Codigo Critica
                                   ,pr_dscritic OUT VARCHAR2) IS --Descricao Critica
    -- .........................................................................
    --
    --  Programa : pc_efetua_lanc_craplat           Antigo: b2crap14.p/efetua-lanc-craplat
    --  Sistema  : Cred
    --  Sigla    : CXON0014
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para selecionar o valor das tarifas bancarias
  BEGIN
    DECLARE
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tabela de memoria de erro
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      vr_rowid_craplat ROWID;
    BEGIN
      --Inicializar variavel retorno erro
      TARI0001.pc_cria_lan_auto_tarifa (pr_cdcooper => pr_cdcooper   --Codigo Cooperativa
                                       ,pr_nrdconta => pr_nrdconta   --Numero da Conta
                                       ,pr_dtmvtolt => pr_dtmvtolt   --Data Lancamento
                                       ,pr_cdhistor => pr_cdhistor   --Codigo Historico
                                       ,pr_vllanaut => pr_vllanaut   --Valor lancamento automatico
                                       ,pr_cdoperad => pr_cdoperad   --Codigo Operador
                                       ,pr_cdagenci => pr_cdagenci   --Codigo Agencia
                                       ,pr_cdbccxlt => pr_cdbccxlt   --Codigo banco caixa
                                       ,pr_nrdolote => pr_nrdolote   --Numero do lote
                                       ,pr_tpdolote => pr_tpdolote   --Tipo do lote
                                       ,pr_nrdocmto => pr_nrdocmto   --Numero do documento
                                       ,pr_nrdctabb => pr_nrdctabb   --Numero da conta
                                       ,pr_nrdctitg => pr_nrdctitg   --Numero da conta integracao
                                       ,pr_cdpesqbb => pr_cdpesqbb   --Codigo pesquisa
                                       ,pr_cdbanchq => pr_cdbanchq   --Codigo Banco Cheque
                                       ,pr_cdagechq => pr_cdagechq   --Codigo Agencia Cheque
                                       ,pr_nrctachq => pr_nrctachq   --Numero Conta Cheque
                                       ,pr_flgaviso => pr_flgaviso   --Flag aviso
                                       ,pr_tpdaviso => pr_tpdaviso   --Tipo aviso
                                       ,pr_cdfvlcop => pr_cdfvlcop   --Codigo cooperativa
                                       ,pr_inproces => pr_inproces   --Indicador processo
                                       ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                       ,pr_tab_erro => vr_tab_erro   --Tabela retorno erro
                                       ,pr_cdcritic => vr_cdcritic   --Codigo Critica
                                       ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CXON0014.pc_efetua_lanc_craplat. '||sqlerrm;
    END;
  END pc_efetua_lanc_craplat;


  /* Procedure para gerar a tarifa do titulo */
  PROCEDURE pc_gera_tarifa_titulo (pr_cdcooper     IN INTEGER  --Codigo Cooperativa
                                  ,pr_nrdconta_cob IN INTEGER  --Numero Conta Cobranca
                                  ,pr_cod_agencia  IN INTEGER  --Codigo Agencia
                                  ,pr_nro_caixa    IN INTEGER  --Numero do Caixa
                                  ,pr_cod_operador IN VARCHAR2 --Codigo Operador
                                  ,pr_convenio     IN INTEGER  --Numero Convenio
                                  ,pr_nrautdoc     IN INTEGER  --Numero Autenticacao
                                  ,pr_cdcritic     OUT INTEGER --Codigo Critica
                                  ,pr_dscritic     OUT VARCHAR2) IS --Descricao Critica
    -- .........................................................................
    --
    --  Programa : pc_gera_tarifa_titulo           Antigo: b2crap14.p/gera-tarifa-titulo
    --  Sistema  : Cred
    --  Sigla    : CXON0014
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para gerar a tarifa do titulo
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_inpessoa crapass.inpessoa%TYPE;
      vr_cdhistor craplcm.cdhistor%TYPE;
      vr_vltarifa craplcm.vllanmto%TYPE;
      --Variaveis das Tarifas
      vr_histarcx INTEGER;
      vr_histarnt INTEGER;
      vr_histrtaa INTEGER;
      vr_cdhisest INTEGER;
      vr_cdfvlccx INTEGER;
      vr_cdfvlcnt INTEGER;
      vr_cdfvltaa INTEGER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_vlrtarcx NUMBER;
      vr_vlrtarnt NUMBER;
      vr_vltrftaa NUMBER;

      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Tabela de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    BEGIN
      --Inicializar valores retorno erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      /* Data do sistema */
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      /* Pega o historico e valor da taxa */
      OPEN cr_crapcco (pr_cdcooper => pr_cdcooper
                      ,pr_nrconven => pr_convenio);
      --Posicionar no proximo registro
      FETCH cr_crapcco INTO rw_crapcco;
      --Se nao encontrou
      IF cr_crapcco%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcco;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Convenio nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcco;

      /* Assume tarifa pessoa juridica como padrao */
      vr_inpessoa:= 2;

      --Encontrar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta_cob);
      --Posicionar no proximo registro
      FETCH cr_crapass INTO rw_crapass;
      --Se encontrar
      IF cr_crapass%FOUND THEN
        vr_inpessoa:= rw_crapass.inpessoa;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
      --Limpar tabela erro
      vr_tab_erro.DELETE;

      --Buscar valores das tarifas
      CXON0014.pc_pega_valor_tarifas (pr_cdcooper  => pr_cdcooper --Codigo da Cooperativa
                                     ,pr_nrdconta  => pr_nrdconta_cob --Numero Conta
                                     ,pr_nrcnvcob  => pr_convenio --Numero Convenio Cobranca
                                     ,pr_inpessoa  => vr_inpessoa --Tipo pessoa
                                     ,pr_histarcx  => vr_histarcx --Historico Caixa
                                     ,pr_histarnt  => vr_histarnt --Historico Internet
                                     ,pr_histrtaa  => vr_histrtaa --Historico transferencia taa
                                     ,pr_cdhisest  => vr_cdhisest --Codigo Historico Estorno
                                     ,pr_dtdivulg  => vr_dtdivulg --Data Divulgacao
                                     ,pr_dtvigenc  => vr_dtvigenc --Data Vigencia
                                     ,pr_cdfvlccx  => vr_cdfvlccx --Faixa Valor Caixa
                                     ,pr_vlrtarcx  => vr_vlrtarcx --Valor tarifa caixa
                                     ,pr_vlrtarnt  => vr_vlrtarnt --Valor tarifa
                                     ,pr_vltrftaa  => vr_vltrftaa --Valor transferencia taa
                                     ,pr_cdfvlcnt  => vr_cdfvlcnt --Faixa Valor
                                     ,pr_cdfvltaa  => vr_cdfvltaa --Faixa Valor TAA
                                     ,pr_tab_erro  => vr_tab_erro --Tabela retorno erro
                                     ,pr_cdcritic  => vr_cdcritic --Codigo Critica
                                     ,pr_dscritic  => vr_dscritic); --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Determinar historico e tarifa
      CASE pr_cod_agencia
        WHEN 90 THEN /* Tarifa para pagamento atraves da internet */
          vr_cdhistor:= vr_histarnt; /* crapcco.cdhisnet */
          vr_vltarifa:= vr_vlrtarnt; /* crapcco.vlrtarnt. */
          vr_cdfvlcop:= vr_cdfvlcnt;
        WHEN 91 THEN
          vr_cdhistor:= vr_histrtaa; /* crapcco.cdhistaa */
          vr_vltarifa:= vr_vltrftaa; /* crapcco.vltrftaa. */
          vr_cdfvlcop:= vr_cdfvltaa;
        ELSE
          vr_cdhistor:= vr_histarcx; /* crapcco.cdhiscxa */
          vr_vltarifa:= vr_vlrtarcx; /* crapcco.vlrtarcx. */
          vr_cdfvlcop:= vr_cdfvlccx;
      END CASE;

      /* Ignora caso tarifa esteja zerada */
      IF vr_vltarifa = 0 THEN
        --Sair
        RAISE vr_exc_saida;
      END IF;

      /* Gera lancamento tarifa na craplat */
      CXON0014.pc_efetua_lanc_craplat (pr_cdcooper => pr_cdcooper          --Codigo Cooperativa
                                      ,pr_nrdconta => pr_nrdconta_cob      --Numero da Conta
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtocd  --Data Lancamento
                                      ,pr_cdhistor => vr_cdhistor          --Codigo Historico
                                      ,pr_vllanaut => vr_vltarifa          --Valor lancamento automatico
                                      ,pr_cdoperad => pr_cod_operador      --Codigo Operador
                                      ,pr_cdagenci => pr_cod_agencia       --Codigo Agencia
                                      ,pr_cdbccxlt => 100                  --Codigo banco caixa
                                      ,pr_nrdolote => 10900 + pr_nro_caixa --Numero do lote
                                      ,pr_tpdolote => 1                    --Tipo do lote
                                      ,pr_nrdocmto => 0                    --Numero do documento
                                      ,pr_nrdctabb => pr_nrdconta_cob      --Numero da conta
                                      ,pr_nrdctitg => gene0002.fn_mask(pr_nrdconta_cob,'99999999') --Numero da conta integracao
                                      ,pr_cdpesqbb => NULL         --Codigo pesquisa
                                      ,pr_cdbanchq => 0            --Codigo Banco Cheque
                                      ,pr_cdagechq => 0            --Codigo Agencia Cheque
                                      ,pr_nrctachq => 0            --Numero Conta Cheque
                                      ,pr_flgaviso => FALSE        --Flag aviso
                                      ,pr_tpdaviso => 0            --Tipo aviso
                                      ,pr_cdfvlcop => vr_cdfvlcop  --Codigo cooperativa
                                      ,pr_inproces => 1            --Indicador processo
                                      ,pr_tab_erro => vr_tab_erro  --Tabela retorno erro
                                      ,pr_cdcritic => vr_cdcritic  --Codigo Critica
                                      ,pr_dscritic => vr_dscritic); --Descricao Critica
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic:= NULL;
        pr_dscritic:= NULL;
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CXON0014.pc_gera_tarifa_titulo. '||sqlerrm;
    END;
  END pc_gera_tarifa_titulo;


  /* Procedure para enviar vrboleto spb */
  PROCEDURE pc_envia_vrboleto_spb (pr_cdcooper  IN INTEGER  --Codigo da Cooperativa
                                  ,pr_cdagenci  IN INTEGER  --Codigo da Agencia
                                  ,pr_nrdcaixa  IN INTEGER  --Numero de Caixa
                                  ,pr_cdoperad  IN VARCHAR2 --Operador
                                  ,pr_nrinssac  IN NUMBER   --Numero Inscricao sacado
                                  ,pr_idseqttl  IN crapttl.idseqttl%TYPE --Sequencia do titular
                                  ,pr_cdbarras  IN VARCHAR2 --Codigo barras
                                  ,pr_nrinsced  IN NUMBER   --Numero Inscricao Cedente
                                  ,pr_vldpagto  IN NUMBER   --Valor pagamento
                                  ,pr_idorigem  IN INTEGER  --origem do pagamento
                                  ,pr_cdcritic  OUT INTEGER --Codigo Critica
                                  ,pr_dscritic  OUT VARCHAR2) IS --Descricao Critica
    -- .........................................................................
    --
    --  Programa : pc_envia_vrboleto_spb           Antigo: b2crap14.p/envia_vrboleto_spb
    --  Sistema  : Cred
    --  Sigla    : CXON0014
    --  Autor    : Alisson C. Berrido - AMcom
    --  Data     : Julho/2013.                   Ultima atualizacao: 05/12/2014
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure para enviar vrboleto spb
    --
    --   13/11/2014 - Alterado tamanho da variavel vr_conteudo para VARCHAR2(1000) (Rafael)
    --
    --   17/11/2014 - Ajustado variavel que monta o número de controle IF do pagamento de
    --                um VR Boleto. O campo precisa ter 20 posições. (Rafael)
    --
    --   05/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir
    --                nomenclaturas Cedente por Beneficiário e  Sacado por Pagador
    --                Chamado 229313 (Jean Reddiga - RKAM).
    --   30/07/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA
    --                Marcelo Telles Coelho - Mouts
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_cdbccxlt    INTEGER;
      vr_conteudo    VARCHAR2(1000);
      vr_lindigit    VARCHAR2(100);
      vr_nrctrlif    VARCHAR2(100);
      vr_tpinsced    INTEGER;
      vr_tppesced    VARCHAR2(100);
      vr_dsorigem    VARCHAR2(100);
      vr_tpinssac    INTEGER;
      vr_tppessac    VARCHAR2(100);
      vr_des_assunto VARCHAR2(1000);
      vr_email_dest  VARCHAR2(1000);
      vr_flginsok BOOLEAN;
      vr_nrdcaixa    INTEGER;
      vr_cdagenci    INTEGER;
      vr_sufixo      VARCHAR2(1);
      vr_cdoperad    crapope.cdoperad%TYPE;
      --Variaveis de erro
      vr_cd_erro  crapcri.cdcritic%TYPE;
      vr_des_erro     VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;

      --Variaveis Projeto 475
      vr_nrseq_mensagem10    tbspb_msg_enviada_fase.nrseq_mensagem%type;
      vr_nrseq_mensagem20    tbspb_msg_enviada_fase.nrseq_mensagem%type;
      vr_nrseq_mensagem_fase tbspb_msg_enviada_fase.nrseq_mensagem_fase%type := null;

    BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        --Mensagem erro
        vr_des_erro:= 'Cooperativa nao cadastrada.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      /** Validar CPF/CNPJ do Cedente **/
      GENE0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrinsced --Numero inscricao cedente
                                  ,pr_stsnrcal => vr_flginsok --Flag Inscricao
                                  ,pr_inpessoa => vr_tpinsced); --Tipo Inscricao Cedente
      --Cpf ou Cnpj invalido
      IF NOT vr_flginsok THEN
        --Mensagem erro
        vr_des_erro:= 'CPF/CNPJ do beneficiario invalido.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      --Tipo Inscricao Cedente
      IF vr_tpinsced = 1 THEN
        --Pessoa Fisica
        vr_tppesced:= 'F';
      ELSE
        --Pessoa Juridica
        vr_tppesced:= 'J';
      END IF;
      /** Validar CPF/CNPJ do Sacado **/
      GENE0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrinssac --Numero inscricao sacado
                                  ,pr_stsnrcal => vr_flginsok --Flag Inscricao OK
                                  ,pr_inpessoa => vr_tpinssac); --Tipo Inscricao sacado
      --Cpf ou Cnpj invalido
      IF NOT vr_flginsok THEN
        --Mensagem erro
        vr_des_erro:= 'CPF/CNPJ do pagador invalido.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Tipo Inscricao Sacado
      IF vr_tpinssac = 1 THEN
        --Pessoa Fisica
        vr_tppessac:= 'F';
      ELSE
        --Pessoa Juridica
        vr_tppessac:= 'J';
      END IF;
      --Numero Banco/Caixa
      vr_cdbccxlt:= TO_NUMBER(SUBSTR(pr_cdbarras,1,3));
      --Selecionar o Banco
      OPEN cr_crapban (pr_cdbccxlt => vr_cdbccxlt);
      --Posicionar no proximo registro
      FETCH cr_crapban INTO rw_crapban;
      --Se nao encontrar
      IF cr_crapban%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapban;
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => 'Banco nao encontrado.'
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Banco nao encontrado.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapban;

      IF pr_idorigem = 3 THEN
         vr_cdagenci := 90;
         vr_nrdcaixa := 900;
         vr_cdoperad := '996';
         vr_sufixo   := 'I'; /* Internet */
      ELSE
         vr_cdagenci := pr_cdagenci;
         vr_nrdcaixa := pr_nrdcaixa;
         vr_cdoperad := pr_cdoperad;
         vr_sufixo   := 'C';
      END IF;

      -- Marcelo Telles Coelho - Projeto 475
      -- Passar a gerar o número de controle no mesmo padrão de TED/TEC
      -- --Numero Contrato
      -- vr_nrctrlif:= '1'||To_Char(rw_crapdat.dtmvtocd,'MMDD')||gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
      --               substr(To_Char(SYSTIMESTAMP,'MISSFF'),1,10)|| vr_sufixo;
      --
      vr_nrctrlif := '1'
                  || to_char(SYSDATE,'rrmmdd')
		  || gene0002.fn_mask(rw_crapcop.cdagectl,'9999')
                  || SSPB0001.fn_nrdocmto_nrctrlif -- Projeto 475 - SPRINT B
                  || vr_sufixo;
      -- Fim Projeto 475

      -- Marcelo Telles Coelho - Projeto 475
      -- Gerar registro de rastreio de mensagens
      -- Fase 10
      sspb0003.pc_grava_trace_spb(pr_cdfase                 => 10
                                 ,pr_idorigem               => 'E'
                                 ,pr_nmmensagem             => 'MSG_TEMPORARIA'
                                 ,pr_nrcontrole             => vr_nrctrlif
                                 ,pr_nrcontrole_str_pag     => NULL
                                 ,pr_nrcontrole_dev_or      => NULL
                                 ,pr_dhmensagem             => sysdate
                                 ,pr_insituacao             => 'OK'
                                 ,pr_dsxml_mensagem         => null
                                 ,pr_dsxml_completo         => null
                                 ,pr_nrseq_mensagem_xml     => null
                                 ,pr_nrdconta               => NULL
                                 ,pr_cdcooper               => pr_cdcooper
                                 ,pr_cdproduto              => 30 -- TED
                                 ,pr_nrseq_mensagem         => vr_nrseq_mensagem10
                                 ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                 ,pr_dscritic               => vr_dscritic
                                 ,pr_des_erro               => vr_des_erro);
      -- Se ocorreu erro
      IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cd_erro
                             ,pr_dscritic => vr_des_erro);

          IF vr_des_erro IS NOT NULL THEN
             vr_dscritic := vr_dscritic || ' - ' || vr_des_erro;
          END IF;

          IF vr_cdcritic IS NULL THEN
          vr_cdcritic:= 0;
          END IF;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      --
      -- Gerar registro de rastreio de mensagens
      -- Fase 20
      sspb0003.pc_grava_trace_spb(pr_cdfase                 => 20
                                 ,pr_nmmensagem             => 'Nao Utiliza OFSAA'
                                 ,pr_nrcontrole             => vr_nrctrlif
                                 ,pr_nrcontrole_str_pag     => NULL
                                 ,pr_nrcontrole_dev_or      => NULL
                                 ,pr_dhmensagem             => sysdate
                                 ,pr_insituacao             => 'OK'
                                 ,pr_dsxml_mensagem         => null
                                 ,pr_dsxml_completo         => null
                                 ,pr_nrseq_mensagem_xml     => null
                                 ,pr_nrdconta               => NULL
                                 ,pr_cdcooper               => pr_cdcooper
                                 ,pr_cdproduto              => 30 -- TED
                                 ,pr_nrseq_mensagem         => vr_nrseq_mensagem20
                                 ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                 ,pr_dscritic               => vr_dscritic
                                 ,pr_des_erro               => vr_des_erro);
      -- Se ocorreu erro
      IF NVL(vr_des_erro,'OK') <> 'OK' OR TRIM(vr_dscritic) IS NOT NULL THEN
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cd_erro
                             ,pr_dscritic => vr_des_erro);

          IF vr_des_erro IS NOT NULL THEN
             vr_dscritic := vr_dscritic || ' - ' || vr_des_erro;
          END IF;

          IF vr_cdcritic IS NULL THEN
          vr_cdcritic:= 0;
          END IF;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;
      -- Fim Projeto 475

      /** Enviar mensagem STR0026 para a cabine SPB **/
      SSPB0001.pc_proc_envia_vr_boleto (pr_cdcooper => pr_cdcooper  /* Cooperativa*/
                                       ,pr_cdagenci => vr_cdagenci  /* Cod. Agencia  */
                                       ,pr_nrdcaixa => vr_nrdcaixa  /* Numero  Caixa */
                                       ,pr_cdoperad => vr_cdoperad  /* Operador */
                                       ,pr_cdorigem => pr_idorigem  /* Cod. Origem */
                                       ,pr_nrctrlif => vr_nrctrlif  /* NumCtrlIF */
                                       ,pr_dscodbar => pr_cdbarras  /* codigo de barras */
                                       ,pr_cdbanced => vr_cdbccxlt  /* Banco Cedente */
                                       ,pr_cdageced => 0            /* Agencia Cedente */
                                       ,pr_tppesced => vr_tppesced  /* tp pessoa cedente */
                                       ,pr_nrinsced => pr_nrinsced  /* CPF/CNPJ Ced  */
                                       ,pr_tppessac => vr_tppessac  /* tp pessoa sacado */
                                       ,pr_nrinssac => pr_nrinssac  /* CPF/CNPJ Sac  */
                                       ,pr_vldocmto => 0            /* Vlr. DOCMTO */
                                       ,pr_vldesabt => 0            /* Vlr Desc. Abat */
                                       ,pr_vlrjuros => 0            /* Vlr Juros */
                                       ,pr_vlrmulta => 0            /* Vlr Multa */
                                       ,pr_vlroutro => 0            /* Vlr Out Acresc */
                                       ,pr_vldpagto => pr_vldpagto  /* Vlr Pagamento */
                                       ,pr_cdcritic => vr_cdcritic  /* Codigo Critica */
                                       ,pr_dscritic => vr_dscritic); /* Descricao Critica */
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_dscritic
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cd_erro
                             ,pr_dscritic => vr_des_erro);

          IF vr_des_erro IS NOT NULL THEN
             vr_dscritic := vr_dscritic || ' - ' || vr_des_erro;
          END IF;

          IF vr_cdcritic IS NULL THEN
          vr_cdcritic:= 0;
          END IF;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END IF;

      /** Enviar email para operadores da cabine SPB **/

      --Verificar Origem
      IF pr_idorigem = 3 THEN
        vr_dsorigem:= 'INTERNET';
      ELSE
        vr_dsorigem:= 'CAIXA';
      END IF;
      --Montar Conteudo email
      vr_conteudo:= 'Pagamento VR Boleto efetuado via ' ||vr_dsorigem||
                    ' na <strong>'||rw_crapcop.nmrescop || '</strong><br>'||
                    '<br><strong>CPF/CNPJ Beneficiario:</strong> '||
                    TRIM(pr_nrinsced)||
                    '<br><strong>CPF/CNPJ Pagador:</strong> '||
                    TRIM(pr_nrinssac)||
                    '<br><strong>Codigo de Barras:</strong> '||
                    LPAD(pr_cdbarras,44,'9')||
                    '<br><strong>Linha Digitavel:</strong> '||
                    vr_lindigit||
                    '<br><strong>Valor:</strong> '||
                    TRIM(TO_CHAR(pr_vldpagto,'fm999g999g999g990d00'));

      --Recuperar emails de destino
      vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'SPB_VRBOLETO');
      --Montar Assunto email
      vr_des_assunto:= 'PAGTO '||rw_crapcop.nmrescop ||' '||TRIM(pr_nrinssac)||
                       ' R$ '||TRIM(TO_CHAR(pr_vldpagto,'fm999g999g999g990d00'));
      --Enviar Email
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'INTERNETBANK'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => vr_des_assunto
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      IF vr_dscritic IS NOT NULL  THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina CXON0014.pc_envia_vrboleto_spb. '||sqlerrm;
    END;
  END pc_envia_vrboleto_spb;

  /* Procedure para gerar os titulos de iptu */
  PROCEDURE pc_gera_titulos_iptu (pr_cooper          IN INTEGER --Codigo Cooperativa
                                 ,pr_nrdconta        IN INTEGER --Numero da Conta
                                 ,pr_idseqttl        IN crapttl.idseqttl%TYPE --> Sequencial do titular
                                 ,pr_inpessoa        IN crapass.inpessoa%TYPE DEFAULT NULL --> Indicador do tipo de pessoa pagadora
                                 ,pr_nrcpfcgc        IN crapass.inpessoa%TYPE DEFAULT NULL --> Numero CPF/CNPJ da pessoa pagadora
                                 ,pr_cod_operador    IN VARCHAR2          --Codigo do operador
                                 ,pr_cod_agencia     IN INTEGER            --Codigo da Agencia
                                 ,pr_nro_caixa       IN INTEGER            --Numero do Caixa
                                 ,pr_nrinsced        IN NUMBER             -- CPF/CNPJ do Cedente
                                 ,pr_idtitdda        IN NUMBER             -- identificador titulo DDA
                                 ,pr_nrinssac        IN NUMBER             -- CPF/CNPJ do Sacado
                                 ,pr_fatura4         IN NUMBER             -- Fatura
                                 ,pr_titulo1         IN NUMBER             -- FORMAT "99999,99999"
                                 ,pr_titulo2         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo3         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo4         IN NUMBER             -- FORMAT "9"
                                 ,pr_titulo5         IN NUMBER             -- FORMAT "zz,zzz,zzz,zzz999"
                                 ,pr_iptu            IN BOOLEAN            --IPTU
                                 ,pr_flgpgdda        IN BOOLEAN            --Indicador pagto DDA
                                 ,pr_codigo_barras   IN VARCHAR2           --Codigo de Barras
                                 ,pr_valor_informado IN NUMBER             --Valor informado
                                 ,pr_vlfatura        IN NUMBER             --Valor da Fatura
                                 ,pr_nrdconta_cob    IN INTEGER            --Numero Conta Cobranca
                                 ,pr_insittit        IN INTEGER            --Situacao Titulo
                                 ,pr_intitcop        IN INTEGER            --Titulo da Cooperativa
                                 ,pr_convenio        IN NUMBER             --Numero Convenio
                                 ,pr_bloqueto        IN OUT NUMBER         --Numero Bloqueto
                                 ,pr_contaconve      IN INTEGER            --Numero Conta Convenio
                                 ,pr_cdcoptfn        IN INTEGER            --Codigo Cooperativa transferencia
                                 ,pr_cdagetfn        IN INTEGER            --Codigo Agencia Transferencia
                                 ,pr_nrterfin        IN INTEGER            --Numero terminal Financeiro
                                 ,pr_flgpgchq        IN BOOLEAN            --Flag pagamento em cheque
                                 ,pr_vlrjuros        IN NUMBER             --Valor dos Juros
                                 ,pr_vlrmulta        IN NUMBER             --Valor da Multa
                                 ,pr_vldescto        IN NUMBER             --Valor do Desconto
                                 ,pr_vlabatim        IN NUMBER             --Valor do Abatimento
                                 ,pr_vloutdeb        IN NUMBER             --Valor Saida Debitado
                                 ,pr_vloutcre        IN NUMBER             --Valor Saida Creditado
                                 ,pr_tpcptdoc        IN craptit.tpcptdoc%TYPE DEFAULT 1-- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                                 ,pr_cdctrlcs        IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                 ,pr_tppagmto        IN craptit.tppagmto%TYPE --TIPO DO PAGAMENTO
                                 ,pr_idanafrd        IN tbgen_analise_fraude.idanalise_fraude%TYPE DEFAULT NULL -- Identificador de analise de fraude
                                 ,pr_rowidcob        OUT ROWID             --ROWID da cobranca
                                 ,pr_indpagto        OUT INTEGER           --Indicador Pagamento
                                 ,pr_nrcnvbol        OUT INTEGER           --Numero Convenio Boleto
                                 ,pr_nrctabol        OUT INTEGER           --Numero Conta Boleto
                                 ,pr_nrboleto        OUT INTEGER           --Numero do Boleto
                                 ,pr_histor          OUT INTEGER           --Historico
                                 ,pr_pg              OUT BOOLEAN           --Indicador Pago
                                 ,pr_docto           OUT NUMBER            --Numero documento
                                 ,pr_literal         OUT VARCHAR2          --Descricao Literal
                                 ,pr_ult_sequencia   OUT INTEGER           --Ultima Sequencia
                                 ,pr_cdcritic        OUT INTEGER           --Codigo do erro
                                 ,pr_dscritic        OUT VARCHAR2) IS      --Descricao do erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_titulos_iptu    Antigo: dbo/b2crap14.p/gera-titulos-iptu
  --  Sistema  : Procedure para gerar os titulos iptu
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 03/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  --
  -- Objetivo  : Procedure para gerar os titulos iptu
  --
  -- Alteracoes: 04/12/2014 - Alteracao no retorno da critica na rotina de baixa
  --                          do desconto de titulos. (Jaison)
  --
  --             30/12/2014 - Ajuste para lockar a tabela CRAPlot para não permitir que seja gerado
  --                          titulo com o mesmo nrdocto, visto que o nrdocto é gerado a partir do nrseqdig do lote.
  --                          essa situação reflete no estorno do titulo SD 238584 (Odirlei-AMcom)
  --
  --             20/02/2015 - Ajustes para melhor tratamento de criticas e não perder as mensagens.
  --                          SD253990 (Odirlei-AMcom)
  --
  --             11/06/2015 - Tratamento Projeto Coop/Emit/Exp (Daniel)
  --
  --             25/06/2015 - Ajuste na criação do lote, para assim que inserir dar o commit
  --                          com pragma autonomos_transaction, para liberar o registro e minimizar
  --                          o tempo de lock da tabela lote(Odirlei-AMcom)
  --
  --             28/07/2015 - Ajuste para testar se a tabela craplot esta lockada antes de realizar o update
  --                          assim evitando custo do banco para gerenciar lock(Odirlei-Amcom)
  --
  --             30/07/2015 - Alterado para não fazer o atualização do lote qnd for agencia = 90 Internet
  --                          nestes casos irá atualizar na paga0001, diminuindo tempo de lock da tabela (Odirlei-Amcom)
  --
  --             14/08/2015 - pc_gera_titulo_iptu e pc_gera_faturas -> inclusão do parametro pr_tpcptdoc, para identificacao do tipo de captura
  --                          (leitora ou manual(linha digitavel)) (Odirlei-AMcom)
  --
  --             06/10/2015 - Inclusao do nrsnosnum na criacao da crapcob SD339759 (Odirlei-AMcom)
  --
  --             01/08/2017 - Ajustes contigencia CIP. PRJ340-NPC (Odirlei-AMcom)
  --
  --             18/07/2018 - Inclusão de pc_internal_exception nas exceptions others da procedure pc_paga_titulo
  --                          (André Bohn Mout's) - PRB0040172
  --
  --             03/09/2018 - Correção para remover lote (Jonata - Mouts).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar Empresas Conveniadas
      CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%TYPE
                        ,pr_cdempcon IN crapcon.cdempcon%TYPE
                        ,pr_cdsegmto IN crapcon.cdsegmto%TYPE) IS
        SELECT crapcon.cdhistor
        FROM crapcon
        WHERE crapcon.cdcooper = pr_cdcooper
        AND   crapcon.cdempcon = pr_cdempcon
        AND   crapcon.cdsegmto = pr_cdsegmto;
      rw_crapcon cr_crapcon%ROWTYPE;

      --Selecionar cadastro emissao bloquetos
      CURSOR cr_crapceb (pr_cdcooper IN crapceb.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%type
                        ,pr_nrconven IN crapceb.nrconven%type) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.nrdconta
        FROM crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
        AND    crapceb.nrconven = pr_nrconven
        AND    crapceb.nrdconta = pr_nrdconta;
      rw_crapceb cr_crapceb%ROWTYPE;

      --Selecionar informacoes titulos descontados bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type
                        ,pr_insittit IN craptdb.insittit%type) IS
        SELECT craptdb.dtvencto
        FROM craptdb
        WHERE craptdb.cdcooper = pr_cdcooper
        AND   craptdb.nrdconta = pr_nrdconta
        AND   craptdb.cdbandoc = pr_cdbandoc
        AND   craptdb.nrdctabb = pr_nrdctabb
        AND   craptdb.nrcnvcob = pr_nrcnvcob
        AND   craptdb.nrdocmto = pr_nrdocmto
        AND   craptdb.insittit = pr_insittit;
      rw_craptdb cr_craptdb%ROWTYPE;

      --Selecionar lancamentos
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplcm.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplcm.nrdolote%TYPE
                        ,pr_cdhistor IN craplcm.cdhistor%TYPE
                        ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
        SELECT craplcm.nrdconta
              ,craplcm.nrseqdig
        FROM craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
        AND   craplcm.dtmvtolt = pr_dtmvtolt
        AND   craplcm.cdagenci = pr_cdagenci
        AND   craplcm.cdbccxlt = pr_cdbccxlt
        AND   craplcm.nrdolote = pr_nrdolote
        AND   craplcm.cdhistor = pr_cdhistor
        AND   craplcm.nrdctabb = pr_nrdctabb
        AND   craplcm.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;

      --Selecionar informacoes cobranca
      CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_cdbandoc IN crapcob.cdbandoc%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdctabb IN crapcob.nrdctabb%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type
                        ,pr_nrdconta IN crapcob.nrdconta%type) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
              ,crapcob.nrctremp
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.nrdctabb
              ,crapcob.flgregis
              ,crapcob.nrnosnum
              ,crapcob.dtmvtolt
              ,crapcob.dsinform
              ,crapcob.rowid
              ,crapcob.inemiten
              ,crapcob.nrdident
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.cdbandoc = pr_cdbandoc
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdconta = pr_nrdconta;
      rw_crapcob cr_crapcob%ROWTYPE;

      rw_craplot_lcm cr_craplot%ROWTYPE;
      --Variaveis Locais
      vr_nrdcaixa  INTEGER;
      vr_tplotmov  craplot.tplotmov%TYPE;
      vr_cdbandst  craptit.cdbandst%TYPE;
      vr_cddmoeda  craptit.cddmoeda%TYPE;
      vr_nrboleto  NUMBER;
      vr_idorigem  INTEGER;
      vr_flgdesct  BOOLEAN;
      --vr_dsmotivo  VARCHAR2(1000);
      vr_cdmotivo  VARCHAR2(1000);
      vr_nrretcoo  INTEGER;
      vr_indpagto  INTEGER;
      vr_vltarifa  NUMBER;
      vr_flgregst  BOOLEAN;
      vr_flgassoc  BOOLEAN;
      vr_nrinsced  NUMBER;
      vr_nrdctabb  INTEGER;
      vr_nro_lote  INTEGER;
      vr_cdhistor  INTEGER;
      vr_flgpgdda  INTEGER;
      vr_flgenvio  INTEGER;
      vr_digito    INTEGER;
      vr_index     INTEGER;
      vr_nrinsced1 INTEGER;
      vr_nrnosnum  crapcob.nrnosnum%TYPE;
      vr_nrseqdig craplcm.nrseqdig%TYPE :=0;
      vr_registro  ROWID;
      vr_dsconmig  VARCHAR2(100);
      vr_nridetit  NUMBER;
      vr_tpdbaixa  INTEGER;
      vr_flcontig  INTEGER;
      vr_inpessoa  crapass.inpessoa%TYPE;
      vr_nrcpfcgc  crapass.nrcpfcgc%TYPE;

      --Variaveis Erro
      --vr_cod_erro crapcri.cdcritic%TYPE;
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_dscriti2 VARCHAR2(4000);
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Registro do tipo titulos
      rw_craptit craptit%ROWTYPE;
      rw_craptit_rowid ROWID;
      --Tabela de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Tabela de lancamentos para consolidar
      vr_tab_lcm_consolidada PAGA0001.typ_tab_lcm_consolidada;
      --Tabela de Titulos
      vr_tab_descontar PAGA0001.typ_tab_titulos;
      vr_tab_titulos   PAGA0001.typ_tab_titulos;
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;
      -- Variável título com movimentação liq após baixa/ou liq tit não registrado
      vr_liqaposb BOOLEAN := FALSE;

      vr_aux_cdocorre NUMBER;
      vr_vltitulo     craptit.vltitulo%TYPE;

      -- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                                pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                                pr_cdagenci IN craplot.cdagenci%TYPE,
                                pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                                pr_nrdolote IN craplot.nrdolote%TYPE,
                                pr_cdoperad IN craplot.cdoperad%TYPE,
                                pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                                pr_tplotmov IN craplot.tplotmov%TYPE,
                                pr_cdhistor IN craplot.cdhistor%TYPE,
                                pr_craplot  OUT cr_craplot%ROWTYPE,
                                pr_dscritic OUT VARCHAR2)IS

        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;
        -- criar rowtype controle
        rw_craplot_ctl cr_craplot%ROWTYPE;

      BEGIN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => pr_nrdolote);
            FETCH cr_craplot INTO rw_craplot_ctl;
            pr_dscritic := NULL;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot%ISOPEN THEN
                 CLOSE cr_craplot;
               END IF;

               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 pr_dscritic:= pr_dscritic||'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar 0,5 seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;

        IF cr_craplot%NOTFOUND THEN
          -- criar registros de lote na tabela
          INSERT INTO craplot
                  (craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote
                  ,craplot.tplotmov
                  ,craplot.cdoperad
                  ,craplot.cdhistor
                  ,craplot.nrdcaixa
                  ,craplot.cdopecxa)
          VALUES  (pr_cdcooper
                  ,pr_dtmvtolt
                  ,pr_cdagenci
                  ,pr_cdbccxlt
                  ,pr_nrdolote
                  ,pr_tplotmov
                  ,pr_cdoperad
                  ,pr_cdhistor
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING  craplot.ROWID
                       ,craplot.nrdolote
                       ,craplot.cdbccxlt
                       ,craplot.tplotmov
                       ,craplot.dtmvtolt
                       ,craplot.cdagenci
                       ,craplot.cdhistor
                       ,craplot.cdoperad
                       ,craplot.qtcompln
                       ,craplot.qtinfoln
                       ,craplot.vlcompcr
                       ,craplot.vlinfocr
                   INTO rw_craplot_ctl.ROWID
                      , rw_craplot_ctl.nrdolote
                      , rw_craplot_ctl.cdbccxlt
                      , rw_craplot_ctl.tplotmov
                      , rw_craplot_ctl.dtmvtolt
                      , rw_craplot_ctl.cdagenci
                      , rw_craplot_ctl.cdhistor
                      , rw_craplot_ctl.cdoperad
                      , rw_craplot_ctl.qtcompln
                      , rw_craplot_ctl.qtinfoln
                      , rw_craplot_ctl.vlcompcr
                      , rw_craplot_ctl.vlinfocr;
        
        END IF;

        CLOSE cr_craplot;

        -- retornar informações para o programa chamador
        pr_craplot := rw_craplot_ctl;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          ROLLBACK;
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
      END pc_insere_lote;

    BEGIN

      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      /* Tratamento de erros para internet */
      IF pr_cod_agencia = 90 THEN
        --Numero da Caixa
        vr_nrdcaixa:= TO_NUMBER(pr_nrdconta || pr_idseqttl);
        vr_idorigem:= 3;    /** Internet **/
      ELSIF pr_cod_agencia = 91 THEN
        --Numero da Caixa
        vr_nrdcaixa:= TO_NUMBER(pr_nrdconta || pr_idseqttl);
        vr_idorigem:= 4;    /** Cash/TAA **/
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
        vr_idorigem:= 2;    /** Caixa On-Line **/
      END IF;

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      --Eliminar Erro
      CXON0000.pc_elimina_erro (pr_cooper      => pr_cooper       --Codigo cooperativa
                               ,pr_cod_agencia => pr_cod_agencia  --Codigo agencia
                               ,pr_nro_caixa   => vr_nrdcaixa     --Numero Caixa
                               ,pr_cdcritic    => vr_cdcritic     --Codigo do erro
                               ,pr_dscritic    => vr_dscritic);   --Descricao do erro
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Verificar se o caixa esta zerado
      IF pr_cod_agencia = 0 OR pr_nro_caixa = 0 OR pr_cod_operador IS NULL OR pr_cod_operador IS NULL  THEN
        --Mensagem erro
        vr_des_erro:= 'ERRO!!! PA ZERADO. FECHE O CAIXA E AVISE O CPD. ';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      --> Caso possua numero de consulta da Nova Plataforma de cobrança
      --> Deve efetuar as validações
      IF TRIM(pr_cdctrlcs) IS NOT NULL THEN

        --> Validação do pagamento do boleto na Nova plataforma de cobrança
        NPCB0001.pc_valid_pagamento_npc
                          ( pr_cdcooper  => rw_crapcop.cdcooper --> Codigo da cooperativa
                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data de movimento
                           ,pr_cdctrlcs  => pr_cdctrlcs         --> Numero de controle da consulta no NPC
                           ,pr_dtagenda  => NULL                --> Data de agendamento
                           ,pr_vldpagto  => pr_valor_informado  --> Valor a ser pago
                           ,pr_vltitulo  => vr_vltitulo         --> Valor do titulo
                           ,pr_nridenti  => vr_nridetit         --> Retornar numero de identificacao do titulo no npc
                           ,pr_tpdbaixa  => vr_tpdbaixa         --> Retornar tipo de baixa
                           ,pr_flcontig  => vr_flcontig         --> Retornar inf que a CIP esta em modo de contigencia
                           ,pr_cdcritic  => vr_cdcritic         --> Codigo da critico
                           ,pr_dscritic  => vr_dscritic );      --> Descrição da critica

        --> Verificar se retornou critica
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          --> Abortar programa
          RAISE vr_exc_erro;
        END IF;
      --> Se for titulo da cooperativa
      ELSIF pr_intitcop = 1 THEN
        vr_tpdbaixa := 1; -- Baixa Operacional Integral Intrabancária
      END IF;

      --Se for iptu
      IF pr_iptu THEN
        --Numero lote
        vr_nro_lote:= 17000 + pr_nro_caixa;
        vr_tplotmov:= 21;
      ELSE
        --Numero lote
        vr_nro_lote:= 16000 + pr_nro_caixa;
        vr_tplotmov:= 20;
      END IF;
      --Historico
      vr_cdhistor:= 0;
      --Se for iptu
      IF pr_iptu THEN
        --Selecionar Empresas Conveniadas
        OPEN cr_crapcon (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdempcon => to_number(SUBSTR(pr_codigo_barras,16,4))
                        ,pr_cdsegmto => to_number(SUBSTR(pr_codigo_barras,2,1)));
        --Posicionar no proximo registro
        FETCH cr_crapcon INTO rw_crapcon;
        --Se nao encontrar
        IF cr_crapcon%FOUND THEN
          --Historico
          vr_cdhistor:= rw_crapcon.cdhistor;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapcon;
      ELSE
        --Historico
        vr_cdhistor:= 713; /* Titulos */
      END IF;

      --Se o codigo de barra estiver vazio
      IF nvl(pr_codigo_barras, ' ') = ' ' THEN
        --Mensagem erro
        vr_des_erro:= 'ERRO!!! CODIGO DE BARRAS NULO. AVISE O CPD. ';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_crapcop.cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')||';'
                                   ||pr_cod_agencia||';'
                                   ||11||';'
                                   ||vr_nro_lote);

      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
       PAGA0001., que é chamada na rotina PC_CRPS509. Tem por finalidade definir
       se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
       da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
       a agencia do cooperado*/

      if not paga0001.fn_exec_paralelo then
        -- Controlar criação de lote, com pragma
        pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                        pr_dtmvtolt => rw_crapdat.dtmvtocd,
                        pr_cdagenci => pr_cod_agencia,
                        pr_cdbccxlt => 11,
                        pr_nrdolote => vr_nro_lote,
                        pr_cdoperad => pr_cod_operador,
                        pr_nrdcaixa => pr_nro_caixa,
                        pr_tplotmov => vr_tplotmov,
                        pr_cdhistor => vr_cdhistor,
                        pr_craplot  => rw_craplot,
                        pr_dscritic => vr_dscritic);

        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

      else
        paga0001.pc_insere_lote_wrk (pr_cdcooper => rw_crapcop.cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                     pr_cdagenci => pr_cod_agencia,
                                     pr_cdbccxlt => 11,
                                     pr_nrdolote => vr_nro_lote,
                                     pr_cdoperad => pr_cod_operador,
                                     pr_nrdcaixa => pr_nro_caixa,
                                     pr_tplotmov => vr_tplotmov,
                                     pr_cdhistor => vr_cdhistor,
                                     pr_cdbccxpg => null,
                                     pr_nmrotina => 'CXON0014.PC_GERA_TITULOS_IPTU');

        rw_craplot.dtmvtolt := rw_crapdat.dtmvtocd;
        rw_craplot.cdagenci := pr_cod_agencia;
        rw_craplot.cdbccxlt := 11;
        rw_craplot.nrdolote := vr_nro_lote;
        rw_craplot.cdoperad := pr_cod_operador;
        rw_craplot.tplotmov := vr_tplotmov;
        rw_craplot.cdhistor := vr_cdhistor;
         
      end if;


      
      
      --Se for iptu
      IF pr_iptu THEN
        vr_digito:= to_number(SUBSTR(gene0002.fn_mask(pr_fatura4,'999999999999'),12,1));
      ELSE
        vr_digito:= pr_titulo4;
      END IF;

      --Determinar codigo barras
      IF rw_craplot.tplotmov = 21  THEN
        vr_cdbandst:= to_number(SUBSTR(pr_codigo_barras,16,04));
        vr_cddmoeda:= to_number(SUBSTR(pr_codigo_barras,03,01));
      ELSE
        vr_cdbandst:= to_number(SUBSTR(pr_codigo_barras,01,03));
        vr_cddmoeda:= to_number(SUBSTR(pr_codigo_barras,04,01));
      END IF;
      --Transformar boolean em integer
      IF pr_flgpgdda THEN
        vr_flgpgdda:= 1;
      ELSE
        vr_flgpgdda:= 0;
      END IF;
      --Determinar envio
      IF (pr_intitcop = 1) OR
         (pr_valor_informado >= 250000 AND NOT pr_iptu AND
         Trunc(SYSDATE) >= To_Date('28/06/2013','DD/MM/YYYY')) THEN
        vr_flgenvio:= 1;
      ELSE
        vr_flgenvio:= 0;
      END IF;

      --Selecionar Banco
      rw_crapban := NULL;
      OPEN cr_crapban (pr_cdbccxlt => vr_cdbandst);
      --Posicionar no proximo registro
      FETCH cr_crapban INTO rw_crapban;
      CLOSE cr_crapban;

      --> Atribuir valores do parametro
      vr_inpessoa := pr_inpessoa;
      vr_nrcpfcgc := pr_nrcpfcgc;

      -- Se possui conta informada e nao contem o inpessoa ou o CPF/CNPJ
      -- Deve buscar da conta do cooperato
      IF nvl(pr_nrdconta,0) <> 0 AND
        (nvl(pr_inpessoa,0) = 0 OR nvl(pr_nrcpfcgc,0) = 0) THEN
        --Selecionar informacoes associado
        OPEN cr_crapass (pr_cdcooper => pr_cooper
                        ,pr_nrdconta => pr_nrdconta);
        --Posicionar no proximo registro
        FETCH cr_crapass INTO rw_crapass_pag;
        IF cr_crapass%FOUND THEN
          CLOSE cr_crapass;
          vr_inpessoa := rw_crapass_pag.inpessoa;
          vr_nrcpfcgc := rw_crapass_pag.nrcpfcgc;
        ELSE
           CLOSE cr_crapass;
        END IF;
      END IF;

      --Inserir titulo
      BEGIN
        INSERT INTO craptit
          (craptit.cdcooper
          ,craptit.nrdconta
          ,craptit.dtmvtolt
          ,craptit.cdagenci
          ,craptit.cdbccxlt
          ,craptit.nrdolote
          ,craptit.cdbandst
          ,craptit.cddmoeda
          ,craptit.cdoperad
          ,craptit.dscodbar
          ,craptit.nrdvcdbr
          ,craptit.tpdocmto
          ,craptit.vldpagto
          ,craptit.vltitulo
          ,craptit.dtdpagto
          ,craptit.nrdocmto
          ,craptit.cdopedev
          ,craptit.dtdevolu
          ,craptit.insittit
          ,craptit.nrseqdig
          ,craptit.intitcop
          ,craptit.flgenvio
          ,craptit.flgpgdda
          ,craptit.nrinsced
          ,craptit.cdcoptfn
          ,craptit.cdagetfn
          ,craptit.nrterfin
          ,craptit.tpcptdoc
          ,craptit.cdctrlcs
          ,craptit.tppagmto
          ,craptit.nrdident
          ,craptit.nrispbds
          ,craptit.inpessoa
          ,craptit.nrcpfcgc
          ,craptit.tpbxoper
          ,craptit.flgconti
          ,craptit.idanafrd
          ,craptit.idseqttl)
        VALUES
          (rw_crapcop.cdcooper               -- cdcooper
          ,pr_nrdconta                       -- nrdconta
          ,rw_craplot.dtmvtolt               -- dtmvtolt
          ,rw_craplot.cdagenci               -- cdagenci
          ,rw_craplot.cdbccxlt               -- cdbccxlt
          ,rw_craplot.nrdolote               -- nrdolote
          ,vr_cdbandst                       -- cdbandst
          ,vr_cddmoeda                       -- cddmoeda
          ,pr_cod_operador                   -- cdoperad
          ,pr_codigo_barras                  -- dscodbar
          ,vr_digito                         -- nrdvcdbr   /*Digito Verificador Codigo de Barras*/
          ,rw_craplot.tplotmov               -- tpdocmto
          ,pr_valor_informado                -- vldpagto
          ,pr_vlfatura                       -- vltitulo
          ,rw_crapdat.dtmvtocd               -- dtdpagto
          ,Nvl(vr_nrseqdig,0)                -- nrdocmto
          ,' '                               -- cdopedev
          ,NULL                              -- dtdevolu
          ,pr_insittit /*  Arrec. caixa  */  -- insittit
          ,Nvl(vr_nrseqdig,0)                -- nrseqdig
          ,pr_intitcop                       -- intitcop
          ,vr_flgenvio                       -- flgenvio
          ,vr_flgpgdda                       -- flgpgdda
          ,pr_nrinsced                       -- nrinsced
          ,pr_cdcoptfn                       -- cdcoptfn
          ,pr_cdagetfn                       -- cdagetfn
          ,pr_nrterfin                       -- nrterfin
          ,pr_tpcptdoc                       -- tpcptdoc
          ,nvl(pr_cdctrlcs,' ')              -- cdctrlcs
          ,pr_tppagmto                       -- tppagmto
          ,nvl(vr_nridetit,0)                -- nrdident
          ,nvl(rw_crapban.nrispbif,0)        -- nrispbds
          ,nvl(vr_inpessoa,0)                -- inpessoa
          ,nvl(vr_nrcpfcgc,0)                -- nrcpfcgc
          ,nvl(vr_tpdbaixa,0)                -- tpbxoper
          ,nvl(vr_flcontig,0)                -- flgconti
          ,NULLIF(pr_idanafrd,0)             -- idanafrd
          ,pr_idseqttl)                      -- idseqttl
        RETURNING
          craptit.nrseqdig
         ,craptit.nrdocmto
         ,craptit.rowid
        INTO
          rw_craptit.nrseqdig
         ,rw_craptit.nrdocmto
         ,rw_craptit_rowid;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na tabela craptit.'||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;

      --> Buscar nosso numero do codigo de barras
      vr_nrnosnum := SUBSTR(pr_codigo_barras,26,17);

      /* Titulos da cooperativa */
      IF NOT pr_iptu AND pr_intitcop = 1 THEN
        --Encontrar Associado
        OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => pr_nrdconta_cob);
        --Posicionar no proximo registro
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrar
        IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 9
                               ,pr_dsc_erro => NULL
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 9;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapass;
        /* Verifica se deve extrair o CEB do nro do boleto */
        OPEN cr_crapcco (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrconven => to_number(pr_convenio));
        --Posicionar no proximo registro
        FETCH cr_crapcco INTO rw_crapcco;
        --Fechar Cursor
        CLOSE cr_crapcco;
        --Numero do boleto
        vr_nrboleto:= pr_bloqueto;
        --Selecionar informacoes cadastro emissores bloqueto
        OPEN cr_crapceb (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => pr_nrdconta_cob
                        ,pr_nrconven => To_Number(pr_convenio));
        --Posicionar no proximo registro
        FETCH cr_crapceb INTO rw_crapceb;
        --Se nao encontrar
        IF cr_crapceb%FOUND AND rw_crapcco.cddbanco <> 085 THEN
          --Numero Bloqueto
          pr_bloqueto:= TO_NUMBER(gene0002.fn_mask(rw_crapceb.nrcnvceb,'99999')||
                                  gene0002.fn_mask(pr_bloqueto,'999999999'));
        END IF;
        --Fechar Cursor
        CLOSE cr_crapceb;
        --Selecionar informacoes titulos descontados bordero
        OPEN cr_craptdb (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => pr_nrdconta_cob
                        ,pr_cdbandoc => rw_crapcco.cddbanco
                        ,pr_nrdctabb => pr_contaconve
                        ,pr_nrcnvcob => to_number(pr_convenio)
                        ,pr_nrdocmto => vr_nrboleto
                        ,pr_insittit => 4);
        --Posicionar no proximo registro
        FETCH cr_craptdb INTO rw_craptdb;
        --Verificar se encontrou Titulo Descontado
        vr_flgdesct:= cr_craptdb%FOUND;

        --Se encontrar
        IF vr_flgdesct THEN
          /* a COMPE pode atrasar */
          IF  rw_craptdb.dtvencto <= rw_crapdat.dtmvtocd THEN
            /* postergacao da data de vencimento */
            vr_flgdesct:= rw_craptdb.dtvencto > rw_crapdat.dtmvtoan;
          ELSE
            --Desconto titulo
            vr_flgdesct:= TRUE;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_craptdb;

        IF pr_cod_agencia = 90 THEN
          vr_indpagto:= 3;  /* Internet */
          --vr_dsmotivo:= '33 - Liquidacaoo na Internet (Home banking)';
          vr_cdmotivo:= '33';
          /* Tarifa para pagamento atraves da internet */
          vr_vltarifa:= rw_crapcco.vlrtarnt;
        ELSIF pr_cod_agencia = 91 THEN
          vr_indpagto:= 4;  /* Internet */
          --vr_dsmotivo:= '32 - Liquidacao Terminal de Auto-Atendimento';
          vr_cdmotivo:= '32';
          /* Tarifa para pagamento atraves de TAA */
          vr_vltarifa:= rw_crapcco.vltrftaa;
        ELSE
          /* Tarifa para pagamento atraves do caixa on-line */
          vr_vltarifa:= rw_crapcco.vlrtarcx;
          --vr_dsmotivo:= NULL;
          vr_cdmotivo:= '0';
          /* dinheiro */
          IF NOT pr_flgpgchq THEN
            vr_indpagto:= 1; /* Caixa On-Line */
            --vr_dsmotivo:= '03 - Liquidacao no Guiche de Caixa em Dinheiro';
            vr_cdmotivo:= '03';
          ELSE  /* cheque */
            vr_indpagto:= 1; /* Caixa On-Line */
            --vr_dsmotivo:= '30 - Liquidacao no Guiche de Caixa em Cheque';
            vr_cdmotivo:= '30';
          END IF;
        END IF;

        /* identificar se o titulo eh de um convenio de cobranca registrada */
        IF rw_crapcco.cddbanco = rw_crapcop.cdbcoctl THEN
          --Cobranca registrada
          vr_flgregst:= TRUE;
        ELSE
          --Cobranca nao registrada
          vr_flgregst:= FALSE;
        END IF;
        --Se nao estiver descontado e nao for registrado
        IF NOT vr_flgdesct  AND NOT vr_flgregst THEN

           vr_nrseqdig := fn_sequence('CRAPLOT'
                                      ,'NRSEQDIG'
                                      ,''||rw_crapcop.cdcooper||';'
                                         ||to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')||';'
                                         ||pr_cod_agencia||';'
                                         ||100||';'
                                         ||10800 + pr_nro_caixa);

          /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
           PAGA0001., que é chamada na rotina PC_CRPS509. Tem por finalidade definir
           se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
           da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
           a agencia do cooperado*/

          if not paga0001.fn_exec_paralelo then
            -- Controlar criação de lote, com pragma
            pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                            pr_dtmvtolt => rw_crapdat.dtmvtocd,
                            pr_cdagenci => pr_cod_agencia,
                            pr_cdbccxlt => 100,
                            pr_nrdolote => 10800 + pr_nro_caixa,
                            pr_cdoperad => pr_cod_operador,
                            pr_nrdcaixa => pr_nro_caixa,
                            pr_tplotmov => 1,
                            pr_cdhistor => 654,
                            pr_craplot  => rw_craplot_lcm,
                            pr_dscritic => vr_dscritic);

            -- se encontrou erro ao buscar lote, abortar programa
            IF vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

          ELSE
           paga0001.pc_insere_lote_wrk (pr_cdcooper => rw_crapcop.cdcooper,
                                       pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                       pr_cdagenci => pr_cod_agencia,
                                       pr_cdbccxlt => 100,
                                       pr_nrdolote => 10800 + pr_nro_caixa,
                                       pr_cdoperad => pr_cod_operador,
                                       pr_nrdcaixa => pr_nro_caixa,
                                       pr_tplotmov => 1,
                                       pr_cdhistor => 654,
                                       pr_cdbccxpg => null,
                                       pr_nmrotina => 'CXON0014.PC_GERA_TITULOS_IPTU');

            rw_craplot_lcm.dtmvtolt := rw_crapdat.dtmvtocd;
            rw_craplot_lcm.cdagenci := pr_cod_agencia;
            rw_craplot_lcm.cdbccxlt := 100;
            rw_craplot_lcm.nrdolote := 10800 + pr_nro_caixa;
            rw_craplot_lcm.cdoperad := pr_cod_operador;
            rw_craplot_lcm.tplotmov := 1;
            rw_craplot_lcm.cdhistor := 654;
            
          end if;
		                              
          
          --Numero da Conta
          vr_nrdctabb:= pr_contaconve;
          --Selecionar lancamentos para conta convenio
          OPEN cr_craplcm (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_dtmvtolt => rw_craplot_lcm.dtmvtolt
                          ,pr_cdagenci => rw_craplot_lcm.cdagenci
                          ,pr_cdbccxlt => rw_craplot_lcm.cdbccxlt
                          ,pr_nrdolote => rw_craplot_lcm.nrdolote
                          ,pr_cdhistor => rw_craplot_lcm.cdhistor
                          ,pr_nrdctabb => pr_contaconve
                          ,pr_nrdocmto => pr_bloqueto);
          --Posicionar no proximo registro
          FETCH cr_craplcm INTO rw_craplcm;
          --Se nao encontrar
          IF cr_craplcm%FOUND THEN
            --Fechar Cursor
            CLOSE cr_craplcm;
            --Se a conta for diferente da de cobranca
            IF rw_craplcm.nrdconta <> pr_nrdconta_cob THEN
              --Selecionar lancamentos para conta convenio
              OPEN cr_craplcm (pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_dtmvtolt => rw_craplot_lcm.dtmvtolt
                              ,pr_cdagenci => rw_craplot_lcm.cdagenci
                              ,pr_cdbccxlt => rw_craplot_lcm.cdbccxlt
                              ,pr_nrdolote => rw_craplot_lcm.nrdolote
                              ,pr_cdhistor => rw_craplot_lcm.cdhistor
                              ,pr_nrdctabb => pr_nrdconta_cob
                              ,pr_nrdocmto => pr_bloqueto);
              --Posicionar no proximo registro
              FETCH cr_craplcm INTO rw_craplcm;
              --Se nao encontrar
              IF cr_craplcm%FOUND THEN
                --Fechar Cursor
                CLOSE cr_craplcm;
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 92
                                     ,pr_dsc_erro => NULL
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 92;
                  vr_dscritic:= NULL;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              ELSE
                --Fechar Cursor
                CLOSE cr_craplcm;
                --Numero da conta
                vr_nrdctabb:= pr_nrdconta_cob;
              END IF;
            ELSE /* mesma Conta */
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 92
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 92;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
          --Fechar Cursor
          IF cr_craplcm%ISOPEN THEN
            CLOSE cr_craplcm;
          END IF;

          --Criar lancamento
          BEGIN
            INSERT INTO craplcm
              (craplcm.cdagenci
              ,craplcm.cdbccxlt
              ,craplcm.cdcooper
              ,craplcm.cdhistor
              ,craplcm.cdoperad
              ,craplcm.cdpesqbb
              ,craplcm.dtmvtolt
              ,craplcm.dtrefere
              ,craplcm.hrtransa
              ,craplcm.nrautdoc
              ,craplcm.nrdconta
              ,craplcm.nrdctabb
              ,craplcm.nrdctitg
              ,craplcm.nrdocmto
              ,craplcm.nrdolote
              ,craplcm.nrseqdig
              ,craplcm.vllanmto
              ,craplcm.cdcoptfn
              ,craplcm.cdagetfn
              ,craplcm.nrterfin)
            VALUES
              (rw_craplot_lcm.cdagenci         -- cdagenci
              ,rw_craplot_lcm.cdbccxlt         -- cdbccxlt
              ,rw_crapcop.cdcooper             -- cdcooper
              ,rw_craplot_lcm.cdhistor         -- cdhistor
              ,rw_craplot_lcm.cdoperad         -- cdoperad
              ,TRIM(pr_convenio)               -- cdpesqbb
              ,rw_craplot_lcm.dtmvtolt         -- dtmvtolt
              ,rw_craplot_lcm.dtmvtolt         -- dtrefere
              ,GENE0002.fn_busca_time          -- hrtransa
              ,nvl(pr_ult_sequencia,0)         -- nrautdoc
              ,pr_nrdconta_cob                 -- nrdconta
              ,vr_nrdctabb                     -- nrdctabb
              ,rw_crapass.nrdctitg             -- nrdctitg
              ,pr_bloqueto                     -- nrdocmto
              ,rw_craplot_lcm.nrdolote         -- nrdolote
              ,Nvl(vr_nrseqdig,0)  -- nrseqdig
              ,pr_valor_informado              -- vllanmto
              ,pr_cdcoptfn                     -- cdcoptfn
              ,pr_cdagetfn                     -- cdagetfn
              ,pr_nrterfin)                    -- nrterfin
            RETURNING
              craplcm.nrseqdig
            INTO
              rw_craplcm.nrseqdig;
          EXCEPTION
            WHEN Others THEN
              declare
                vr_dscomplemento varchar2(4000) := null;
              begin
                vr_dscomplemento := rw_craplot_lcm.cdagenci                -- cdagenci
                                    ||'-'||rw_craplot_lcm.cdbccxlt         -- cdbccxlt
                                    ||'-'||rw_crapcop.cdcooper             -- cdcooper
                                    ||'-'||rw_craplot_lcm.cdhistor         -- cdhistor
                                    ||'-'||rw_craplot_lcm.cdoperad         -- cdoperad
                                    ||'-'||TRIM(pr_convenio)               -- cdpesqbb
                                    ||'-'||rw_craplot_lcm.dtmvtolt         -- dtmvtolt
                                    ||'-'||rw_craplot_lcm.dtmvtolt         -- dtrefere
                                    ||'-'||GENE0002.fn_busca_time          -- hrtransa
                                    ||'-'||nvl(pr_ult_sequencia,0)         -- nrautdoc
                                    ||'-'||pr_nrdconta_cob                 -- nrdconta
                                    ||'-'||vr_nrdctabb                     -- nrdctabb
                                    ||'-'||rw_crapass.nrdctitg             -- nrdctitg
                                    ||'-'||pr_bloqueto                     -- nrdocmto
                                    ||'-'||rw_craplot_lcm.nrdolote         -- nrdolote
                                    ||'-'||Nvl(vr_nrseqdig,0)  -- nrseqdig
                                    ||'-'||pr_valor_informado              -- vllanmto
                                    ||'-'||pr_cdcoptfn                     -- cdcoptfn
                                    ||'-'||pr_cdagetfn                     -- cdagetfn
                                    ||'-'||pr_nrterfin;                    -- nrterfin
                CECRED.pc_internal_exception (pr_cdcooper => rw_crapcop.cdcooper, pr_compleme => vr_dscomplemento);
              end;
              vr_cdcritic:= 0;
              vr_dscritic:= 'CXON0014 - Erro ao inserir na tabela craplcm. '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;

          /* Faz a baixa de titulos em emprestimo */
          OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_cdbandoc => rw_crapcco.cddbanco
                          ,pr_nrcnvcob => to_number(pr_convenio)
                          ,pr_nrdctabb => pr_contaconve
                          ,pr_nrdocmto => vr_nrboleto
                          ,pr_nrdconta => pr_nrdconta_cob);
          --Posicionar no primeiro registro
          FETCH cr_crapcob INTO rw_crapcob;
          --Se nao encontrou
          IF cr_crapcob%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapcob;
            IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' THEN
              --Criar cobranca
              BEGIN
                INSERT INTO crapcob
                  (crapcob.cdcooper
                  ,crapcob.nrdconta
                  ,crapcob.cdbandoc
                  ,crapcob.nrdctabb
                  ,crapcob.nrcnvcob
                  ,crapcob.nrdocmto
                  ,crapcob.incobran
                  ,crapcob.dtretcob
                  ,crapcob.nrnosnum)
                VALUES
                  (rw_crapcop.cdcooper
                  ,pr_nrdconta_cob
                  ,rw_crapcco.cddbanco
                  ,pr_contaconve
                  ,to_number(pr_convenio)
                  ,vr_nrboleto
                  ,0
                  ,rw_crapdat.dtmvtocd
                  ,vr_nrnosnum)
                RETURNING
                  crapcob.nrdconta
                 ,crapcob.nrctremp
                 ,crapcob.nrctasac
                 ,crapcob.nrdocmto
                 ,crapcob.dtvencto
                 ,crapcob.vltitulo
                 ,crapcob.rowid
                INTO
                  rw_crapcob.nrdconta
                 ,rw_crapcob.nrctremp
                 ,rw_crapcob.nrctasac
                 ,rw_crapcob.nrdocmto
                 ,rw_crapcob.dtvencto
                 ,rw_crapcob.vltitulo
                 ,rw_crapcob.rowid;
              EXCEPTION
                WHEN Others THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao inserir na tabela crapcob. '||sqlerrm;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
            ELSE
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => 'Registro de boleto nao encontrado.'
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Registro de boleto nao encontrado.';
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
          --Fechar Cursor
          IF cr_crapcob%ISOPEN THEN
            CLOSE cr_crapcob;
          END IF;
          --Se tem contrato e numero sacado
          IF rw_crapcob.nrctremp <> 0  AND rw_crapcob.nrctasac <> 0 THEN
            --Baixar titulo
            PAGA0001.pc_baixa_epr_titulo (pr_cdcooper => rw_crapcop.cdcooper  --Codigo Cooperativa
                                         ,pr_cdagenci => pr_cod_agencia       --Codigo Agencia
                                         ,pr_nrdcaixa => pr_nro_caixa         --Numero do Caixa
                                         ,pr_cdoperad => pr_cod_operador      --Codigo Operador
                                         ,pr_nrdconta => rw_crapcob.nrdconta  --Numero da Conta
                                         ,pr_idseqttl => 1                    --Sequencial do Titular
                                         ,pr_idorigem => vr_idorigem          --Identificador Origem pagamento
                                         ,pr_nmdatela => 'b2crap14.p'         --Nome do programa chamador
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtocd  --Data do Movimento
                                         ,pr_nrctremp => rw_crapcob.nrctremp  --Numero Contrato Emprestimo
                                         ,pr_nrctasac => rw_crapcob.nrctasac  --Numero da Conta do Sacado
                                         ,pr_nrboleto => rw_crapcob.nrdocmto  --Numero do Boleto
                                         ,pr_dtvencto => rw_crapcob.dtvencto  --Data Vencimento
                                         ,pr_vlboleto => rw_crapcob.vltitulo  --Valor boleto
                                         ,pr_vllanmto => pr_valor_informado   --Valor Lancamento
                                         ,pr_flgerlog => TRUE                 --Gerar erro log
                                         ,pr_tab_erro => vr_tab_erro          --Tabela de erro
                                         ,pr_cdcritic => vr_cdcritic          --C¿digo de erro
                                         ,pr_dscritic => vr_dscritic);        --Retorno de Erro
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Se tem erro na tabela
              IF vr_tab_erro.Count > 0 THEN
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 0
                                     ,pr_dsc_erro => vr_tab_erro(vr_tab_erro.FIRST).dscritic
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              ELSE
                --Mensagem erro
                vr_des_erro:= 'Nao foi possivel baixar titulo do emprestimo.';
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 0
                                     ,pr_dsc_erro => vr_des_erro
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= vr_des_erro;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            END IF;
          END IF; --rw_crapcob.nrctremp <> 0  AND rw_crapcob.nrctasac <> 0


        ELSIF vr_flgregst THEN /* Cobranca Registrada */
          /* Faz a baixa de titulos em emprestimo */
          OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_nrcnvcob => to_number(pr_convenio)
                          ,pr_nrdconta => pr_nrdconta_cob
                          ,pr_nrdocmto => vr_nrboleto
                          ,pr_nrdctabb => pr_contaconve
                          ,pr_cdbandoc => rw_crapcco.cddbanco);
          --Posicionar no primeiro registro
          FETCH cr_crapcob INTO rw_crapcob;
          --Se nao encontrou
          IF cr_crapcob%NOTFOUND THEN
             -- verificar se não é convenio impresso pelo software
             -- Se for, será necessário crir título na crapcob, senão gerar erro pois o título não existe;
             IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' THEN
               BEGIN
               INSERT INTO crapcob (cdcooper
                                   ,nrdconta
                                   ,nrcnvcob
                                   ,nrdocmto
                                   ,nrdctabb
                                   ,cdbandoc
                                   ,dtmvtolt
                                   ,dtvencto
                                   ,vltitulo
                                   ,incobran
                                   ,flgregis
                                   ,vlabatim
                                   ,vldescto
                                   ,tpdmulta
                                   ,tpjurmor
                                   ,dsdoccop
                                   ,flgdprot
                                   ,nrnosnum)
                            VALUES (rw_crapcop.cdcooper
                                   ,pr_nrdconta_cob
                                   ,to_number(pr_convenio)
                                   ,vr_nrboleto
                                   ,rw_crapcco.nrdctabb
                                   ,rw_crapcco.cddbanco
                                   ,rw_crapdat.dtmvtolt
                                   ,rw_crapdat.dtmvtolt
                                   ,pr_valor_informado -- parametro do valor do pagamento
                                   ,0 -- incobran
                                   ,rw_crapcco.flgregis
                                   ,0 -- vlabatim
                                   ,0 -- vldescto
                                   ,3 -- tpdmulta
                                   ,3 -- tpjurmor
                                   ,to_char(vr_nrboleto) -- dscodcop
                                   ,0                    -- flgdprot
                                   ,vr_nrnosnum );
               EXCEPTION
               WHEN OTHERS THEN
                 vr_dscritic := 'Erro ao inserir crapcob (CXON0014.pc_gera_titulos_iptu): '||SQLERRM;
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               END;

               --Fechar Cursor
               CLOSE cr_crapcob;

                -- Abrir o cursor novamente para buscar o mesmo recém-criado;
                OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_nrcnvcob => to_number(pr_convenio)
                                ,pr_nrdconta => pr_nrdconta_cob
                                ,pr_nrdocmto => vr_nrboleto
                                ,pr_nrdctabb => pr_contaconve
                                ,pr_cdbandoc => rw_crapcco.cddbanco);
                --Posicionar no primeiro registro
                FETCH cr_crapcob INTO rw_crapcob;
                --Fechar Cursor
                CLOSE cr_crapcob;

                -- criar variável que identifica título com movimentação liq após baixa/ou liq tit não registrado;
                vr_liqaposb:= TRUE;
             ELSE

               --Mensagem erro
               vr_des_erro:= 'Registro de boleto nao encontrado.';

               --Criar erro
               CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cod_erro => 0
                                    ,pr_dsc_erro => vr_des_erro
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
               --Se ocorreu erro
               IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               ELSE
                 vr_cdcritic:= 0;
                 vr_dscritic:= vr_des_erro;
                 --Levantar Excecao
                 RAISE vr_exc_erro;
               END IF;
             END IF;
          ELSIF rw_crapcob.incobran IN (3,5) THEN --cr_crapcob%FOUND
            --Fechar Cursor
            CLOSE cr_crapcob;
            --Mensagem erro
            CASE rw_crapcob.incobran
              WHEN 3 THEN vr_des_erro:= 'Boleto ja baixado.';
              WHEN 5 THEN vr_des_erro:= 'Boleto ja pago.';
            END CASE;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => vr_des_erro
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= vr_des_erro;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          ELSIF rw_crapcob.dsinform LIKE 'LIQAPOSBX%' THEN
                vr_liqaposb := TRUE;
          END IF;
          --Fechar Cursor
          IF cr_crapcob%ISOPEN THEN
            CLOSE cr_crapcob;
          END IF;

          IF vr_liqaposb = FALSE THEN

            IF rw_crapcob.inemiten = 3 THEN
              vr_aux_cdocorre := 76;
            ELSE
              vr_aux_cdocorre := 6;
            END IF;

            --Selecionar Banco
            rw_crapban := NULL;
            OPEN cr_crapban (pr_cdbccxlt => rw_crapcop.cdbcoctl);
            --Posicionar no proximo registro
            FETCH cr_crapban INTO rw_crapban;
            CLOSE cr_crapban;

            --Processar a Liquidacao
            PAGA0001.pc_processa_liquidacao (pr_idtabcob     => rw_crapcob.rowid       --Rowid da Cobranca
                                            ,pr_nrispbpg     => rw_crapban.nrispbif    --ISPB recebedora
                                            ,pr_nrnosnum     => 0                      --Nosso Numero
                                            ,pr_cdbanpag     => rw_crapcop.cdbcoctl    --Codigo banco pagamento
                                            ,pr_cdagepag     => rw_crapcop.cdagectl    --Codigo Agencia pagamento
                                            ,pr_vltitulo     => rw_crapcob.vltitulo    --Valor do titulo
                                            ,pr_vlliquid     => 0                      --Valor Liquidacao
                                            ,pr_vlrpagto     => pr_valor_informado     --Valor pagamento
                                            ,pr_vlabatim     => pr_vlabatim            --Valor abatimento
                                            ,pr_vldescto     => pr_vldescto            --Valor desconto
                                            ,pr_vlrjuros     => pr_vlrjuros + pr_vlrmulta   --Valor juros
                                            ,pr_vloutdeb     => pr_vloutdeb            --Valor saida debito
                                            ,pr_vloutcre     => pr_vloutcre            --Valor saida credito
                                            ,pr_dtocorre     => rw_crapdat.dtmvtocd    --Data Ocorrencia
                                            ,pr_dtcredit     => rw_crapdat.dtmvtocd    --Data Credito
                                            ,pr_cdocorre     => vr_aux_cdocorre        --Codigo Ocorrencia
                                            ,pr_dsmotivo     => vr_cdmotivo            --Descricao Motivo
                                            ,pr_dtmvtolt     => rw_crapdat.dtmvtocd    --Data movimento
                                            ,pr_cdoperad     => pr_cod_operador        --Codigo Operador
                                            ,pr_indpagto     => vr_indpagto            --Indicador pagamento /* 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA */
                                            ,pr_ret_nrremret => vr_nrretcoo            --Numero remetente
                                            ,pr_cdcritic     => vr_cdcritic            --Codigo Critica
                                            ,pr_dscritic     => vr_dscritic            --Descricao Critica
                                            ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                            ,pr_tab_descontar       => vr_tab_descontar);     --Tabela de titulos
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => vr_cdcritic
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= vr_cdcritic;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          ELSE

            IF rw_crapcob.inemiten = 3 THEN
              vr_aux_cdocorre := 77;
            ELSE
              vr_aux_cdocorre := 17;
            END IF;

            --Selecionar Banco
            rw_crapban := NULL;
            OPEN cr_crapban (pr_cdbccxlt => rw_crapcop.cdbcoctl);
            --Posicionar no proximo registro
            FETCH cr_crapban INTO rw_crapban;
            CLOSE cr_crapban;

            --Processar Liquidacao apos baixa
            PAGA0001.pc_proc_liquid_apos_baixa (pr_idtabcob     => rw_crapcob.rowid       --Rowid da Cobranca
                                               ,pr_nrispbpg     => rw_crapban.nrispbif    --ISPB recebedora
                                               ,pr_nrnosnum     => 0                      --Nosso Numero
                                               ,pr_cdbanpag     => rw_crapcop.cdbcoctl    --Codigo banco pagamento
                                               ,pr_cdagepag     => rw_crapcop.cdagectl    --Codigo Agencia pagamento
                                               ,pr_vltitulo     => rw_crapcob.vltitulo    --Valor do titulo
                                               ,pr_vlliquid     => 0                      --Valor Liquidacao
                                               ,pr_vlrpagto     => pr_valor_informado     --Valor pagamento
                                               ,pr_vlabatim     => 0                      --Valor abatimento
                                               ,pr_vldescto     => 0                       --Valor desconto
                                               ,pr_vlrjuros     => 0                      --Valor juros
                                               ,pr_vloutdeb     => 0                      --Valor saida debito
                                               ,pr_vloutcre     => 0                      --Valor saida credito
                                               ,pr_dtocorre     => rw_crapdat.dtmvtocd    --Data Ocorrencia
                                               ,pr_dtcredit     => rw_crapdat.dtmvtocd    --Data Credito
                                               ,pr_cdocorre     => vr_aux_cdocorre        --Codigo Ocorrencia
                                               ,pr_dsmotivo     => vr_cdmotivo            --Descricao Motivo
                                               ,pr_dtmvtolt     => rw_crapdat.dtmvtocd    --Data movimento
                                               ,pr_cdoperad     => pr_cod_operador        --Codigo Operador
                                               ,pr_indpagto     => vr_indpagto            --Indicador pagamento /* 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA */
                                               ,pr_ret_nrremret => vr_nrretcoo            --Numero remetente
                                               ,pr_cdcritic     => vr_cdcritic            --Codigo Critica
                                               ,pr_dscritic     => vr_dscritic            --Descricao Critica
                                               ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada); --Tabela lancamentos

            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => vr_cdcritic
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= vr_cdcritic;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;

          -- função monta a tabela de valores a ser creditado para o cooperado (vr_tab_lcm_consolidada)
          -- apenas se o float for D-0
/*
          IF rw_crapcco.qtdfloat = 0 THEN

            PAGA0001.pc_valores_a_creditar(pr_cdcooper => rw_crapcob.cdcooper
                                          ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_dtcredit => vr_dtcredit
                                          ,pr_idtabcob => rw_crapcob.rowid -- montar valor apenas para um título
                                          ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada --Tabela lancamentos consolidada
                                          ,pr_cdprogra => vr_cdprogra           --Nome Programa
                                          ,pr_cdcritic => vr_cdcritic           --Codigo da Critica
                                          ,pr_dscritic => vr_dscritic);         --Descricao da critica

            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;

          END IF;
*/
          /** Realiza os Lancamentos na conta do cooperado */
          PAGA0001.pc_realiza_lancto_cooperado (pr_cdcooper => rw_crapcob.cdcooper --Codigo Cooperativa
                                               ,pr_dtmvtolt => rw_crapdat.dtmvtocd --Data Movimento
                                               ,pr_cdagenci => rw_crapcco.cdagenci --Codigo Agencia
                                               ,pr_cdbccxlt => rw_crapcco.cdbccxlt --Codigo banco caixa
                                               ,pr_nrdolote => rw_crapcco.nrdolote --Numero do Lote
                                               ,pr_cdpesqbb => rw_crapcob.nrcnvcob --Codigo Pesquisa
                                               ,pr_cdcritic => vr_cdcritic         --Codigo Critica
                                               ,pr_dscritic => vr_dscritic         --Descricao Critica
                                               ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          --Retornar ROWID
          pr_rowidcob:= rw_crapcob.ROWID;
          --Retornar Indicador Pagamento
          pr_indpagto:= vr_indpagto;
          --Verificar se a tabela tem registros
          vr_flgdesct:= vr_tab_descontar.Count > 0;
        END IF; --NOT vr_flgdesct  AND NOT vr_flgregst

        --Encontrar Associado
        OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => pr_nrdconta_cob);
        --Posicionar no proximo registro
        FETCH cr_crapass INTO rw_crapass;
        --Determinar se achou ou nao
        vr_flgassoc:= cr_crapass%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass;
        /* Faz a baixa de titulos em emprestimo */
        OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdbandoc => rw_crapcco.cddbanco
                        ,pr_nrcnvcob => to_number(pr_convenio)
                        ,pr_nrdctabb => pr_contaconve
                        ,pr_nrdocmto => vr_nrboleto
                        ,pr_nrdconta => pr_nrdconta_cob);
        --Posicionar no primeiro registro
        FETCH cr_crapcob INTO rw_crapcob;
        --Se nao encontrou
        IF cr_crapcob%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapcob;
          --Buscar convenios das contas migradas nos parametros
          --vr_dsconmig = 1601301,0457595
          vr_dsconmig:= gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'CONV_CTA_MIGRADA_AV');
          --Se nao encontrou parametro
          IF vr_dsconmig IS NULL THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Parametro de Convenio de conta migrada não encontrado. '||SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          IF rw_crapcco.dsorgarq IN ('IMPRESSO PELO SOFTWARE','MIGRACAO','INCORPORACAO') AND
             INSTR(vr_dsconmig,To_Number(gene0002.fn_mask(rw_crapcco.nrconven,'9999999'))) > 0 AND
             vr_flgassoc THEN
            --Criar cobranca
            BEGIN
              INSERT INTO crapcob
                (crapcob.cdcooper
                ,crapcob.nrdconta
                ,crapcob.cdbandoc
                ,crapcob.nrdctabb
                ,crapcob.nrcnvcob
                ,crapcob.nrdocmto
                ,crapcob.incobran
                ,crapcob.dtretcob
                ,crapcob.nrnosnum)
              VALUES
                (rw_crapcop.cdcooper
                ,pr_nrdconta_cob
                ,rw_crapcco.cddbanco
                ,pr_contaconve
                ,to_number(pr_convenio)
                ,vr_nrboleto
                ,0
                ,rw_crapdat.dtmvtocd
                ,vr_nrnosnum)
              RETURNING
                crapcob.nrdconta
               ,crapcob.nrctremp
               ,crapcob.nrctasac
               ,crapcob.nrdocmto
               ,crapcob.dtvencto
               ,crapcob.vltitulo
               ,crapcob.rowid
             INTO
                rw_crapcob.nrdconta
               ,rw_crapcob.nrctremp
               ,rw_crapcob.nrctasac
               ,rw_crapcob.nrdocmto
               ,rw_crapcob.dtvencto
               ,rw_crapcob.vltitulo
               ,rw_crapcob.rowid;
            EXCEPTION
              WHEN Others THEN
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao inserir na tabela crapcob. '||sqlerrm;
                --Levantar Excecao
                RAISE vr_exc_erro;
            END;
          ELSE
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 592
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 592;
              vr_dscritic:= '';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
        --Fechar Cursor
        IF cr_crapcob%ISOPEN THEN
          CLOSE cr_crapcob;
        END IF;
        --Atualizar tabela cobranca
        BEGIN
          UPDATE crapcob SET crapcob.incobran = 5
                            ,crapcob.dtdpagto = rw_crapdat.dtmvtocd
                            ,crapcob.vldpagto = pr_valor_informado
                            ,crapcob.indpagto = vr_indpagto
                            ,crapcob.cdbanpag = 11
                            ,crapcob.cdagepag = 0
                            ,crapcob.vltarifa = vr_vltarifa
          WHERE crapcob.ROWID = rw_crapcob.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela crapcob. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
        --Atualizar valores para retornar
        pr_nrcnvbol:= rw_crapcob.nrcnvcob;
        pr_nrctabol:= rw_crapcob.nrdconta;
        pr_nrboleto:= rw_crapcob.nrdocmto;

        /* Gerar tarifa somente para titulos que nao estao em emprst
           e nao estiverem na cobranca registrada */
        IF Nvl(rw_crapcob.nrctremp,0) = 0 AND NOT vr_flgregst THEN
          --Gerar tarifa titulo
          CXON0014.pc_gera_tarifa_titulo (pr_cdcooper     => rw_crapcop.cdcooper --Codigo Cooperativa
                                         ,pr_nrdconta_cob => pr_nrdconta_cob   --Numero Conta Cobranca
                                         ,pr_cod_agencia  => pr_cod_agencia    --Codigo Agencia
                                         ,pr_nro_caixa    => pr_nro_caixa      --Numero do Caixa
                                         ,pr_cod_operador => pr_cod_operador   --Codigo Operador
                                         ,pr_convenio     => pr_convenio       --Numero Convenio
                                         ,pr_nrautdoc     => pr_ult_sequencia  --Numero Autenticacao
                                         ,pr_cdcritic     => vr_cdcritic       --Codigo Critica
                                         ,pr_dscritic     => vr_dscritic);     --Descricao Critica
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => vr_dscritic
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= vr_dscritic;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF; --rw_crapcob.nrctremp = 0 AND NOT

        /* Se o titulo estiver em desconto chama a rotina de baixa */
        IF vr_flgdesct THEN
          --Montar indice para tabela memoria titulos
          vr_index:= vr_tab_titulos.Count + 1;
          vr_tab_titulos(vr_index).cdbandoc:= rw_crapcob.cdbandoc;
          vr_tab_titulos(vr_index).nrdctabb:= rw_crapcob.nrdctabb;
          vr_tab_titulos(vr_index).nrcnvcob:= rw_crapcob.nrcnvcob;
          vr_tab_titulos(vr_index).nrdconta:= rw_crapcob.nrdconta;
          vr_tab_titulos(vr_index).nrdocmto:= rw_crapcob.nrdocmto;
          vr_tab_titulos(vr_index).vltitulo:= pr_valor_informado;
          vr_tab_titulos(vr_index).flgregis:= rw_crapcob.flgregis = 1;

          --Efetuar a baixa do titulo
          DSCT0001.pc_efetua_baixa_titulo (pr_cdcooper    => rw_crapcop.cdcooper --Codigo Cooperativa
                                          ,pr_cdagenci    => pr_cod_agencia      --Codigo Agencia
                                          ,pr_nrdcaixa    => pr_nro_caixa        --Numero Caixa
                                          ,pr_cdoperad    => pr_cod_operador     --Codigo operador
                                          ,pr_dtmvtolt    => rw_crapdat.dtmvtocd --Data Movimento
                                          ,pr_idorigem    => vr_idorigem         --Identificador Origem pagamento
                                          ,pr_nrdconta    => pr_nrdconta         --Numero da conta
                                          ,pr_indbaixa    => 1                   --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                          ,pr_dtintegr    => rw_crapdat.dtmvtocd -- Data de integração do pagamento
                                          ,pr_tab_titulos => vr_tab_titulos      --Titulos a serem baixados
                                          ,pr_cdcritic    => vr_cdcritic         --Codigo Critica
                                          ,pr_dscritic    => vr_dscritic         --Descricao Critica
                                          ,pr_tab_erro    => vr_tab_erro);       --Tabela erros
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            IF vr_tab_erro.Count > 0 THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => vr_tab_erro(vr_tab_erro.FIRST).dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            ELSE
              vr_dscriti2 := 'DSCT0001.pc_efetua_baixa_titulo: ' || vr_cdcritic || ' - ' || vr_dscritic;
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => vr_dscriti2
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= vr_dscriti2;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
        END IF; --vr_flgdesct

        --> Se for titulo da cooperativa
        --> deve armazenar o numero de ident titulo
        IF TRIM(rw_crapcob.nrdident) > 0 AND
           nvl(vr_nridetit,0) = 0 THEN
          vr_nridetit := rw_crapcob.nrdident;
        END IF;


      END IF; --NOT pr_iptu AND pr_intitcop = 1
      --Parametros de retorno
      pr_pg:= FALSE;
      pr_docto:= rw_craptit.nrdocmto;
      pr_histor:= vr_cdhistor;

      /* enviar VR Boleto ao SPB */
      IF NOT pr_iptu AND pr_intitcop = 0 AND
         pr_valor_informado >= 250000 AND Trunc(SYSDATE) >= To_Date('28/06/2013','DD/MM/YYYY') THEN
        --Se for DDA
        IF pr_idtitdda > 0 THEN
          --Buscar cedente do DDA
          DDDA0001.pc_busca_cedente_DDA (pr_cdcooper  => rw_crapcop.cdcooper --Codigo Cooperativa
                                        ,pr_idtitdda  => pr_idtitdda         --Identificador Titulo dda
                                        ,pr_nrinsced  => vr_nrinsced         --Numero inscricao cedente
                                        ,pr_cdcritic  => vr_cdcritic         --Codigo de Erro
                                        ,pr_dscritic  => vr_dscritic);       --Descricao de Erro
          --se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;

        --Se encontrou numero inscricao ou o numero foi passado por parametro
        IF vr_nrinsced > 0 OR pr_nrinsced > 0 THEN
          --Se for indicado dda
          IF pr_idtitdda > 0 THEN
            vr_nrinsced1:= vr_nrinsced;
          ELSE
            vr_nrinsced1:= pr_nrinsced;
          END IF;
          --Enviar boleto SPB
          CXON0014.pc_envia_vrboleto_spb(pr_cdcooper  => rw_crapcop.cdcooper  --Codigo da Cooperativa
                                        ,pr_cdagenci  => pr_cod_agencia       --Codigo da Agencia
                                        ,pr_nrdcaixa  => pr_nro_caixa         --Numero de Caixa
                                        ,pr_cdoperad  => pr_cod_operador      --Operador
                                        ,pr_nrinssac  => pr_nrinssac          --Numero Inscricao sacado
                                        ,pr_idseqttl  => pr_idseqttl          --Sequencia do titular
                                        ,pr_cdbarras  => pr_codigo_barras     --Codigo barras
                                        ,pr_nrinsced  => vr_nrinsced1         --Numero Inscricao Cedente
                                        ,pr_vldpagto  => pr_valor_informado   --Valor pagamento
                                        ,pr_idorigem  => vr_idorigem          --origem do pagamento
                                        ,pr_cdcritic  => vr_cdcritic          --Codigo Critica
                                        ,pr_dscritic  => vr_dscritic);        --Descricao Critica

          --se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Criar erro
            /*CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => vr_cdcritic
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cod_erro
                                 ,pr_dscritic => vr_des_erro);*/

              /*IF vr_cod_erro IS NULL THEN
                 vr_cod_erro := 0;
            END IF;*/

              IF vr_des_erro IS NOT NULL THEN
                 vr_dscritic := vr_dscritic || ' - ' || vr_des_erro;
              END IF;

              --Levantar Excecao
              RAISE vr_exc_erro;
          END IF;
        END IF; --vr_nrinsced > 0 OR pr_nrinsced > 0
      END IF; --NOT pr_iptu AND pr_intitcop = 0

      /* Grava uma autenticacao */
      CXON0000.pc_grava_autenticacao_internet (pr_cooper       => pr_cooper            --Codigo Cooperativa
                                              ,pr_nrdconta     => pr_nrdconta          --Numero da Conta
                                              ,pr_idseqttl     => pr_idseqttl          --Sequencial do titular
                                              ,pr_cod_agencia  => pr_cod_agencia       --Codigo Agencia
                                              ,pr_nro_caixa    => pr_nro_caixa         --Numero do caixa
                                              ,pr_cod_operador => pr_cod_operador      --Codigo Operador
                                              ,pr_valor        => pr_valor_informado   --Valor da transacao
                                              ,pr_docto        => pr_docto             --Numero documento
                                              ,pr_operacao     => pr_pg                --Indicador Operacao Debito
                                              ,pr_status       => '1'                  --Status da Operacao - Online
                                              ,pr_estorno      => FALSE                --Indicador Estorno
                                              ,pr_histor       => pr_histor            --Historico Debito
                                              ,pr_data_off     => NULL                 --Data Transacao
                                              ,pr_sequen_off   => 0                    --Sequencia
                                              ,pr_hora_off     => 0                    --Hora transacao
                                              ,pr_seq_aut_off  => 0                    --Sequencia automatica
                                              ,pr_cdempres     => NULL                 --Descricao Observacao
                                              ,pr_literal      => pr_literal          --Descricao literal lcm
                                              ,pr_sequencia    => pr_ult_sequencia    --Sequencia Autenticacao
                                              ,pr_registro     => vr_registro         --ROWID do registro debito
                                              ,pr_cdcritic     => vr_cdcritic         --C¿digo do erro
                                              ,pr_dscritic     => vr_dscritic);       --Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na autenticacao do pagamento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* Atualiza sequencia Autenticacao */
      BEGIN
        UPDATE craptit
           SET craptit.nrautdoc = pr_ult_sequencia,
               craptit.nrdident = nvl(vr_nridetit,craptit.nrdident)
        WHERE craptit.ROWID = rw_craptit_rowid;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar tabela craptit. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;

         --Criar registro de erro -- para garantir que todos os erros
         -- estejam na tabela
         CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0014.pc_gera_titulos_iptu. '||SQLERRM;

         --Criar registro de erro -- para garantir que todos os erros
         -- estejam na tabela
         CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

    END;
  END pc_gera_titulos_iptu;

  /* Procedure para chamar a pc_gera_titulos_iptu pelo Progress */
  PROCEDURE pc_gera_titulos_iptu_prog
                                 (pr_cooper          IN INTEGER --Codigo Cooperativa
                                 ,pr_nrdconta        IN INTEGER --Numero da Conta
                                 ,pr_idseqttl        IN crapttl.idseqttl%TYPE --Sequencial do titular
                                 ,pr_cod_operador    IN VARCHAR2           --Codigo do operador
                                 ,pr_cod_agencia     IN INTEGER            --Codigo da Agencia
                                 ,pr_nro_caixa       IN INTEGER            --Numero do Caixa
                                 ,pr_nrinsced        IN NUMBER             -- CPF/CNPJ do Cedente
                                 ,pr_idtitdda        IN NUMBER             -- identificador titulo DDA
                                 ,pr_nrinssac        IN NUMBER             -- CPF/CNPJ do Sacado
                                 ,pr_fatura4         IN NUMBER             -- Fatura
                                 ,pr_titulo1         IN NUMBER             -- FORMAT "99999,99999"
                                 ,pr_titulo2         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo3         IN NUMBER             -- FORMAT "99999,999999"
                                 ,pr_titulo4         IN NUMBER             -- FORMAT "9"
                                 ,pr_titulo5         IN NUMBER             -- FORMAT "zz,zzz,zzz,zzz999"
                                 ,pr_iptu            IN NUMBER             --IPTU
                                 ,pr_flgpgdda        IN NUMBER             --Indicador pagto DDA
                                 ,pr_codigo_barras   IN VARCHAR2           --Codigo de Barras
                                 ,pr_valor_informado IN NUMBER             --Valor informado
                                 ,pr_vlfatura        IN NUMBER             --Valor da Fatura
                                 ,pr_nrdconta_cob    IN INTEGER            --Numero Conta Cobranca
                                 ,pr_insittit        IN INTEGER            --Situacao Titulo
                                 ,pr_intitcop        IN INTEGER            --Titulo da Cooperativa
                                 ,pr_convenio        IN NUMBER             --Numero Convenio
                                 ,pr_bloqueto        IN OUT NUMBER         --Numero Bloqueto
                                 ,pr_contaconve      IN INTEGER            --Numero Conta Convenio
                                 ,pr_cdcoptfn        IN INTEGER            --Codigo Cooperativa transferencia
                                 ,pr_cdagetfn        IN INTEGER            --Codigo Agencia Transferencia
                                 ,pr_nrterfin        IN INTEGER            --Numero terminal Financeiro
                                 ,pr_flgpgchq        IN NUMBER             --Flag pagamento em cheque
                                 ,pr_vlrjuros        IN NUMBER             --Valor dos Juros
                                 ,pr_vlrmulta        IN NUMBER             --Valor da Multa
                                 ,pr_vldescto        IN NUMBER             --Valor do Desconto
                                 ,pr_vlabatim        IN NUMBER             --Valor do Abatimento
                                 ,pr_vloutdeb        IN NUMBER             --Valor Saida Debitado
                                 ,pr_vloutcre        IN NUMBER             --Valor Saida Creditado
                                 ,pr_tpcptdoc        IN craptit.tpcptdoc%TYPE DEFAULT 1-- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                                 ,pr_cdctrlcs        IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                 ,pr_tppagmto        IN craptit.tppagmto%TYPE --TIPO DO PAGAMENTO
                                 ,pr_recidcob        OUT NUMBER            --RECID da cobranca
                                 ,pr_indpagto        OUT INTEGER           --Indicador Pagamento
                                 ,pr_nrcnvbol        OUT INTEGER           --Numero Convenio Boleto
                                 ,pr_nrctabol        OUT INTEGER           --Numero Conta Boleto
                                 ,pr_nrboleto        OUT INTEGER           --Numero do Boleto
                                 ,pr_histor          OUT INTEGER           --Historico
                                 ,pr_pg              OUT NUMBER            --Indicador Pago
                                 ,pr_docto           OUT NUMBER            --Numero documento
                                 ,pr_literal         OUT VARCHAR2          --Descricao Literal
                                 ,pr_ult_sequencia   OUT INTEGER           --Ultima Sequencia
                                 ,pr_cdcritic        OUT INTEGER           --Codigo do erro
                                 ,pr_dscritic        OUT VARCHAR2) IS      --Descricao do erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_titulos_iptu_prog    Antigo:
  --  Sistema  : Procedure bypass que chama pc_gera_titulos_iptu
  --  Sigla    : CXON
  --  Autor    : Rafael Cechet
  --  Data     : Agosto/2014.                   Ultima atualizacao: 19/08/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure bypass para chamar pc_gerar os titulos iptu
  --
  -- Alterações : Incluido parametro pc_tpcptdoc (Odirlei-AMcom)
  --
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_rowidcob ROWID;
      vr_iptu BOOLEAN;
      vr_flgpgdda BOOLEAN;
      vr_flgpgchq BOOLEAN;
      vr_pg BOOLEAN;
      vr_stsnrcal BOOLEAN;
      vr_inpessoa crapass.inpessoa%TYPE;

  BEGIN

    CASE pr_iptu
       WHEN 0 THEN vr_iptu := FALSE;
       WHEN 1 THEN vr_iptu := TRUE;
    END CASE;

    CASE pr_flgpgdda
       WHEN 0 THEN vr_flgpgdda := FALSE;
       WHEN 1 THEN vr_flgpgdda := TRUE;
    END CASE;

    CASE pr_flgpgchq
       WHEN 0 THEN vr_flgpgchq := FALSE;
       WHEN 1 THEN vr_flgpgchq := TRUE;
    END CASE;

    --> Identificar o tipo de pessoa do cpf/cnpj do pagador
    GENE0005.pc_valida_cpf_cnpj ( pr_nrcalcul => pr_nrinssac       --Numero a ser verificado
                                 ,pr_stsnrcal => vr_stsnrcal     --Situacao
                                 ,pr_inpessoa => vr_inpessoa);

    pc_gera_titulos_iptu(pr_cooper => pr_cooper
                       , pr_nrdconta => pr_nrdconta
                       , pr_idseqttl => pr_idseqttl
                       , pr_inpessoa => vr_inpessoa --> Indicador do tipo de pessoa pagadora
                       , pr_nrcpfcgc => pr_nrinssac --> Numero CPF/CNPJ da pessoa pagadora
                       , pr_cod_operador => pr_cod_operador
                       , pr_cod_agencia => pr_cod_agencia
                       , pr_nro_caixa => pr_nro_caixa
                       , pr_nrinsced => pr_nrinsced
                       , pr_idtitdda => pr_idtitdda
                       , pr_nrinssac => pr_nrinssac
                       , pr_fatura4 => pr_fatura4
                       , pr_titulo1 => pr_titulo1
                       , pr_titulo2 => pr_titulo2
                       , pr_titulo3 => pr_titulo3
                       , pr_titulo4 => pr_titulo4
                       , pr_titulo5 => pr_titulo5
                       , pr_iptu => vr_iptu
                       , pr_flgpgdda => vr_flgpgdda
                       , pr_codigo_barras => pr_codigo_barras
                       , pr_valor_informado => pr_valor_informado
                       , pr_vlfatura => pr_vlfatura
                       , pr_nrdconta_cob => pr_nrdconta_cob
                       , pr_insittit => pr_insittit
                       , pr_intitcop => pr_intitcop
                       , pr_convenio => pr_convenio
                       , pr_bloqueto => pr_bloqueto
                       , pr_contaconve => pr_contaconve
                       , pr_cdcoptfn => pr_cdcoptfn
                       , pr_cdagetfn => pr_cdagetfn
                       , pr_nrterfin => pr_nrterfin
                       , pr_flgpgchq => vr_flgpgchq
                       , pr_vlrjuros => pr_vlrjuros
                       , pr_vlrmulta => pr_vlrmulta
                       , pr_vldescto => pr_vldescto
                       , pr_vlabatim => pr_vlabatim
                       , pr_vloutdeb => pr_vloutdeb
                       , pr_vloutcre => pr_vloutcre
                       , pr_tpcptdoc => pr_tpcptdoc
                       , pr_cdctrlcs => pr_cdctrlcs
                       , pr_tppagmto => pr_tppagmto
                       , pr_rowidcob => vr_rowidcob
                       , pr_indpagto => pr_indpagto
                       , pr_nrcnvbol => pr_nrcnvbol
                       , pr_nrctabol => pr_nrctabol
                       , pr_nrboleto => pr_nrboleto
                       , pr_histor => pr_histor
                       , pr_pg => vr_pg
                       , pr_docto => pr_docto
                       , pr_literal => pr_literal
                       , pr_ult_sequencia => pr_ult_sequencia
                       , pr_cdcritic => pr_cdcritic
                       , pr_dscritic => pr_dscritic);

     IF vr_rowidcob IS NOT NULL THEN
        BEGIN
          SELECT cob.progress_recid INTO pr_recidcob
            FROM crapcob cob
           WHERE cob.rowid = vr_rowidcob;

        EXCEPTION
           WHEN OTHERS THEN
               pr_recidcob := NULL;

         END;
      END IF;

      IF vr_pg THEN
         pr_pg := 1;
      ELSE
         pr_pg := 0;
      END IF;

  END;

END pc_gera_titulos_iptu_prog;

  /* Procedure para verificar vencimento titulo */
  PROCEDURE pc_verifica_vencimento_titulo (pr_cod_cooper      IN INTEGER  --Codigo Cooperativa
                                          ,pr_cod_agencia     IN INTEGER  --Codigo da Agencia
                                          ,pr_dt_agendamento  IN DATE     --Data Agendamento
                                          ,pr_dt_vencto       IN DATE     --Data Vencimento
                                          ,pr_critica_data    OUT BOOLEAN --Critica na validacao
                                          ,pr_cdcritic        OUT INTEGER --Codigo da Critica
                                          ,pr_dscritic        OUT VARCHAR2 --Descricao do erro
                                          ,pr_tab_erro        OUT GENE0001.typ_tab_erro) IS --Tabela retorno erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_vencimento_titulo    Antigo: dbo/b2crap14.p/verifica-vencimento-titulo
  --  Sistema  : Procedure para verificar vencimento titulo
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 20/12/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para verificar vencimento titulo
  --
  -- Alteracoes: 29/10/2014 - Tratamento para data de vencimento nula (Rafael).
  --
  --             03/02/2015 - Ajuste em concatenacao em '01/01', estava com ',' em vez de '||'.
  --                          (Jorge/Elton) - SD 238239
  --
  --             06/10/2015 - Ajuste na rotina devido devido para incluir tratamento quando o
  --                          processo ainda estiver rodando, no qual a dtmvtoan esta ainda defazada SD329517 (Odirlei)
  --
  --             17/03/2017 - Removido validacao de pagador vip (Chamado 629635)
  --
  --             20/12/2017 - Alterada validação da data de agendamento e data de vencimento.
  --                          Retirar validação do último dia do ano e incluir chamada da
  --                          função npcb0001.fn_titulo_vencimento_pagamento que recebe
  --                          a data de vencimento do título e retorna o prazo máximo
  --                          para pagamento sem ser considerado vencido (SD#818552 - AJFink)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Tipo de tabela de erro
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis Locais
      vr_dt_dia_util DATE;
      vr_dt_feriado  DATE;
      vr_libepgto    BOOLEAN;
      vr_dtvencto date := null;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Tipo de registro para datas
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    BEGIN
      --Inicializar variavel retorno
      pr_critica_data:= FALSE;
      --Liberado Pagamento
      vr_libepgto:= FALSE;

      /* se data for nula, pode ser boleto sem vencimento */
      IF pr_dt_vencto IS NULL THEN
         RAISE vr_exc_saida;
      END IF;

      --Selecionar a data do movimento
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cod_cooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      --Se a data de agendamento eh nula
      IF pr_dt_agendamento IS NULL THEN
        IF pr_cod_cooper = 1 AND pr_cod_agencia = 62 AND
           pr_dt_vencto BETWEEN To_Date('07/09/2011','DD/MM/YYYY') AND To_Date('12/09/2011','DD/MM/YYYY') AND
           rw_crapdat.dtmvtocd = To_Date('13/09/2011','DD/MM/YYYY')  THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
        /** Permitir o pagamento de titulos vencidos entre 13/08/2011 e
            15/08/2011 na Sede da Credicomin, devido ao feriado na cidade de Lages (15/08) **/
        IF pr_cod_cooper = 10 AND pr_cod_agencia = 1 AND
           pr_dt_vencto BETWEEN To_Date('13/08/2011','DD/MM/YYYY') AND To_Date('15/08/2011','DD/MM/YYYY') AND
           rw_crapdat.dtmvtocd = To_Date('16/08/2011','DD/MM/YYYY')  THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;

        /** Pagamento no dia **/
        IF pr_dt_vencto > rw_crapdat.dtmvtocd  THEN
        --Sair
          RAISE vr_exc_saida;
        END IF;

        -- Verificar se a data ocd é maior que a data de movimento devido a pagamentos
        -- feitos antes de terminar o processo batch, onde que a dtmvtolt será a nova dtmvtoan
        IF rw_crapdat.dtmvtocd > rw_crapdat.dtmvtolt THEN
          IF rw_crapdat.dtmvtolt < pr_dt_vencto THEN
            --Sair
            RAISE vr_exc_saida;
          END IF;
        ELSE
          IF rw_crapdat.dtmvtoan < pr_dt_vencto  THEN
            --Sair
            RAISE vr_exc_saida;
          END IF;
        END IF;


        --Criticar data
        pr_critica_data:= TRUE;

        /** Tratamento para permitir pagamento no primeiro dia util do **/
        /** ano de titulos vencidos no ultimo dia util do ano anterior **/
        IF to_char(rw_crapdat.dtmvtoan,'YYYY') <> to_char(rw_crapdat.dtmvtocd,'YYYY')  THEN
          --Data dia util
          vr_dt_dia_util:= TO_DATE('31/12/'||to_char(rw_crapdat.dtmvtoan,'YYYY'),'DD/MM/YYYY');
          /** Se dia 31/12 for segunda-feira obtem data do sabado **/
          /** para aceitar vencidos do ultimo final de semana     **/
          IF To_Number(to_char(vr_dt_dia_util,'D')) = 2  THEN
            vr_dt_dia_util:= TO_DATE('29/12/'||to_char(rw_crapdat.dtmvtoan,'YYYY'),'DD/MM/YYYY');
          ELSIF To_Number(to_char(vr_dt_dia_util,'D')) = 1  THEN
            /** Se dia 31/12 for domingo, o ultimo dia util e 29/12 **/
            vr_dt_dia_util:= TO_DATE('29/12/'||to_char(rw_crapdat.dtmvtoan,'YYYY'),'DD/MM/YYYY');
          ELSIF To_Number(to_char(vr_dt_dia_util,'D')) = 7  THEN
            /** Se dia 31/12 for sabado, o ultimo dia util e 30/12 **/
            vr_dt_dia_util:= TO_DATE('30/12/'||to_char(rw_crapdat.dtmvtoan,'YYYY'),'DD/MM/YYYY');
          END IF;
          /** Verifica se pode aceitar o titulo vencido **/
          IF  pr_dt_vencto >= vr_dt_dia_util THEN
            --Retorna false
            pr_critica_data:= FALSE;
          END IF;
        END IF;
        --Limpar tabela erro
        vr_tab_erro.DELETE;
        --Verificar feriado
        CCAF0001.pc_verifica_feriado (pr_cdcooper => pr_cod_cooper          --Codigo da cooperativa
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtocd    --Data para verificacao
                                     ,pr_cdagenci => pr_cod_agencia         --Codigo da Agencia
                                     ,pr_dtboleto => pr_dt_vencto           --Data do Titulo
                                     ,pr_flgvenci => vr_libepgto            --Indicador titulo vencido
                                     ,pr_cdcritic => vr_cdcritic            --Codigo do erro
                                     ,pr_dscritic => vr_dscritic            --Descricao do erro
                                     ,pr_tab_erro => vr_tab_erro);          --Tabela de erros
        --Se ocorreu erro
        IF  vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        --Se n¿o estiver liberado
        IF vr_libepgto = FALSE AND pr_cod_agencia NOT IN (90,91)THEN
          pr_critica_data:= FALSE;
        END IF;
      ELSE

        vr_dtvencto := npcb0001.fn_titulo_vencimento_pagamento(pr_cdcooper => pr_cod_cooper
                                                              ,pr_dtvencto => pr_dt_vencto);

        -- se a data de agendamento é maior que o prazo de vencimento
        -- então a data é criticada pois o título estará vencido
              pr_critica_data:= FALSE;
        if trunc(pr_dt_agendamento) > trunc(vr_dtvencto) then
          pr_critica_data:= TRUE;
        end if;

      END IF;
    EXCEPTION
       WHEN vr_exc_saida THEN
         NULL;
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0014.pc_verifica_vencimento_titulo. '||SQLERRM;
    END;
  END pc_verifica_vencimento_titulo;


  /* Procedure para identificar titulo cooperativa */
  PROCEDURE pc_identifica_titulo_coop (pr_cooper        IN INTEGER   --Codigo Cooperativa
                                      ,pr_nro_conta     IN INTEGER   --Numero Conta
                                      ,pr_idseqttl      IN INTEGER   --Sequencial do Titular
                                      ,pr_cod_agencia   IN INTEGER   --Codigo da Agencia
                                      ,pr_nro_caixa     IN INTEGER   --Numero Caixa
                                      ,pr_codbarras     IN VARCHAR2  --Codigo Barras
                                      ,pr_flgcritica    IN BOOLEAN   --Flag Critica
                                      ,pr_nrdconta      OUT INTEGER  --Numero da Conta
                                      ,pr_insittit      OUT INTEGER  --Situacao Titulo
                                      ,pr_intitcop      OUT INTEGER  --Indicador titulo cooperativa
                                      ,pr_convenio      OUT NUMBER   --Numero Convenio
                                      ,pr_bloqueto      OUT NUMBER   --Numero Boleto
                                      ,pr_contaconve    OUT INTEGER  --Conta do Convenio
                                      ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                      ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_identifica_titulo_coop    Antigo: dbo/b2crap14.p/identifica-titulo-coop
  --  Sistema  : Procedure para identificar titulo cooperativa
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 03/02/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para identificar titulo cooperativa
  --
  -- Alteracoes: 03/02/2014 - Igualar tratamento do Progress (Gabriel).
  --
  --             28/07/2014 - Devido a desativaçao dos convenios com 5 digitos(crapceb)
  --                          foi retirado tratamento para 5 digitos na identifica-titulo-coop
  --                         (Odirlei - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar informacoes convenio cobranca
      CURSOR cr_crapcco (pr_cdcooper  IN crapcco.cdcooper%type
                        ,pr_cddbanco  IN crapcco.cddbanco%TYPE
                        ,pr_flgregis  IN crapcco.flgregis%TYPE
                        ,pr_nrconven1 IN crapcco.nrconven%TYPE
                        ,pr_nrconven2 IN crapcco.nrconven%TYPE
                        ,pr_nrconven3 IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cddbanco
              ,crapcco.dsorgarq
              ,crapcco.flgutceb
              ,crapcco.nrconven
              ,crapcco.nrdctabb
        FROM crapcco
        WHERE crapcco.cdcooper = pr_cdcooper
        AND   crapcco.cddbanco = pr_cddbanco
        AND   crapcco.flgregis = pr_flgregis
        AND   (((crapcco.nrconven = pr_nrconven1    OR /* Convenio nao CEB */
                 crapcco.nrconven = pr_nrconven2)   AND
                 crapcco.flgutceb = 0)
               OR /* Convenio CEB */
               (crapcco.nrconven = pr_nrconven3 AND
                crapcco.flgutceb = 1));
      rw_crapcco cr_crapcco%ROWTYPE;

      --Selecionar informacoes convenio cobranca
      CURSOR cr_crapcco2 (pr_cdcooper IN crapcco.cdcooper%type
                         ,pr_cddbanco IN crapcco.cddbanco%TYPE
                         ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cddbanco
              ,crapcco.dsorgarq
              ,crapcco.flgutceb
              ,crapcco.nrconven
              ,crapcco.nrdctabb
        FROM crapcco
        WHERE crapcco.cdcooper = pr_cdcooper
        AND   crapcco.cddbanco = pr_cddbanco
        AND   crapcco.nrconven = pr_nrconven;

      --Selecionar cadastro emissao bloquetos
      CURSOR cr_crapceb4 (pr_cdcooper IN crapceb.cdcooper%type
                         ,pr_nrconven IN crapceb.nrconven%type
                         ,pr_nrcnvceb IN varchar2) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.nrdconta
        FROM crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
        AND    crapceb.nrconven = pr_nrconven
        AND    crapceb.nrcnvceb = pr_nrcnvceb;
      rw_crapceb4 cr_crapceb4%ROWTYPE;

      --Selecionar informacoes Cobranca
      CURSOR cr_crapcob1 (pr_rowid IN ROWID) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
        FROM crapcob
        WHERE crapcob.ROWID = pr_rowid;
      rw_crapcob cr_crapcob1%ROWTYPE;

      --Selecionar contas migradas
      CURSOR cr_craptco (pr_cdcooper IN craptco.cdcooper%type
                        ,pr_cdcopant IN craptco.cdcopant%type
                        ,pr_nrctaant IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.cdcopant
        FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
        AND   craptco.cdcopant = pr_cdcopant
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.flgativo = pr_flgativo
        AND   craptco.tpctatrf <> pr_tpctatrf;
      rw_craptco cr_craptco%ROWTYPE;

      --Selecionar informacoes cobranca
      CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_cdbandoc IN crapcob.cdbandoc%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdctabb IN crapcob.nrdctabb%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type
                        ,pr_nrdconta IN crapcob.nrdconta%type) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.cdbandoc = pr_cdbandoc
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdconta = pr_nrdconta;

      --Selecionar informacoes cobranca
      CURSOR cr_crapcob2 (pr_cdcooper IN crapcob.cdcooper%type
                         ,pr_cdbandoc IN crapcob.cdbandoc%type
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                         ,pr_nrdctabb IN crapcob.nrdctabb%type
                         ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.cdbandoc = pr_cdbandoc
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.nrdocmto = pr_nrdocmto;

      --Variaveis Locais
      vr_banco        INTEGER;
      vr_convenio1    NUMBER;
      vr_convenio2    NUMBER;
      vr_convenio3    NUMBER;
      vr_bloqueto1    NUMBER;
      vr_bloqueto2    NUMBER;
      vr_bloqueto3    NUMBER;
      vr_bloqueto4    NUMBER;
      vr_nrdconta     INTEGER;
      vr_nrconvceb    INTEGER;
      vr_digbloqueto1 NUMBER;
      vr_nrdcaixa     INTEGER;
      vr_flgcrapass   BOOLEAN;
      vr_flgcrapcob   BOOLEAN;
      vr_dsconmig     VARCHAR2(100);
      vr_nrnosnum     crapcob.nrnosnum%TYPE;
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis Erro
      vr_des_erro VARCHAR2(1000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      /* Tratamento de erros para internet e TAA */
      IF pr_cod_agencia IN (90,91) THEN
        vr_nrdcaixa:= to_number(pr_nro_conta || pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      --Buscar convenios das contas migradas nos parametros
      vr_dsconmig:= gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'CONV_CTA_MIGRADA_AV');
      --Se nao encontrou parametro
      IF vr_dsconmig IS NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Parametro de Convenio de conta migrada não encontrado. '||SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Quebrar o codigo de barras
      vr_banco:= TO_NUMBER(SUBSTR(pr_codbarras, 1, 3));
      vr_convenio1:= TO_NUMBER(SUBSTR(pr_codbarras, 20, 6));
      vr_convenio2:= TO_NUMBER(SUBSTR(pr_codbarras, 25, 8));  /* ALPES */
      vr_convenio3:= TO_NUMBER(SUBSTR(pr_codbarras, 26, 7));  /* CEB */
      vr_nrconvceb:= TO_NUMBER(SUBSTR(pr_codbarras, 33, 4));  /* CEB */
      vr_bloqueto1:= TO_NUMBER(SUBSTR(pr_codbarras, 26, 5));  /* 5 d¿gitos */
      vr_bloqueto2:= TO_NUMBER(SUBSTR(pr_codbarras, 34, 9));  /* ALPES */
      vr_bloqueto3:= TO_NUMBER(SUBSTR(pr_codbarras, 33, 10)); /* 10 d¿gitos */
      vr_bloqueto4:= TO_NUMBER(SUBSTR(pr_codbarras, 37, 6)); /*6 d¿gitos CEB*/
      vr_nrdconta:= TO_NUMBER(SUBSTR(pr_codbarras, 26, 8));  /* ALPES */
      pr_insittit:= 4;
      pr_intitcop:= 0;
      pr_convenio:= 0;
      pr_bloqueto:= 0;
      --> Buscar nosso numero do codigo de barras
      vr_nrnosnum := SUBSTR(pr_codbarras,26,17);

      --Digito do Bloqueto
      vr_digbloqueto1:= TO_NUMBER(TRIM(vr_convenio1)||TRIM(gene0002.fn_mask(vr_bloqueto1,'99999'))||'0');

      --Verificar Digito
      CXON0000.pc_verifica_digito_internet (pr_cooper       => pr_cooper       --Codigo Cooperativa
                                           ,pr_nrdconta     => pr_nro_conta    --Numero da Conta
                                           ,pr_idseqttl     => pr_idseqttl     --Sequencial do titular
                                           ,pr_cod_agencia  => pr_cod_agencia  --Codigo Agencia
                                           ,pr_nro_caixa    => pr_nro_caixa    --Numero do caixa
                                           ,pr_nro_conta    => vr_digbloqueto1 --Codigo Da Conta
                                           ,pr_cdcritic     => vr_cdcritic     --C¿digo do erro
                                           ,pr_dscritic     => vr_dscritic);   --Descricao do erro
      --Se ocorreu erro, desconsiderar
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic := NULL;
        vr_dscritic := NULL;
      END IF;
      --Digito Bloqueto1
      vr_digbloqueto1:= TO_NUMBER(SUBSTR(vr_digbloqueto1,LENGTH(vr_digbloqueto1),1));
      vr_bloqueto1:= TO_NUMBER(vr_bloqueto1||TRIM(vr_digbloqueto1));

      --Eliminar Erro
      CXON0000.pc_elimina_erro (pr_cooper      => pr_cooper       --Codigo cooperativa
                               ,pr_cod_agencia => pr_cod_agencia  --Codigo agencia
                               ,pr_nro_caixa   => vr_nrdcaixa     --Numero Caixa
                               ,pr_cdcritic    => vr_cdcritic     --Codigo do erro
                               ,pr_dscritic    => vr_dscritic);   --Descricao do erro
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao]
        RAISE vr_exc_erro;
      END IF;

      --Se for banco brasil
      IF vr_banco = 1 THEN
        --Selecionar informacoes cadastro cobranca
        OPEN cr_crapcco (pr_cdcooper  => rw_crapcop.cdcooper
                        ,pr_cddbanco  => vr_banco
                        ,pr_flgregis  => 0
                        ,pr_nrconven1 => vr_convenio1
                        ,pr_nrconven2 => vr_convenio2
                        ,pr_nrconven3 => vr_convenio3);
        --Posicionar no primeiro registro
        FETCH cr_crapcco INTO rw_crapcco;
        --Se encontrou
        IF cr_crapcco%FOUND THEN
          IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' OR
             rw_crapcco.dsorgarq = 'INTERNET'               OR
             rw_crapcco.dsorgarq = 'MIGRACAO'               THEN
            --Se utiliza sequencia CADC
            IF rw_crapcco.flgutceb = 1 THEN
              --Buscar parametro CEB
              -- desativar tratamento ceb 5 digitos
              /*vr_nrconven_ceb:= gene0001.fn_param_sistema('CRED',rw_crapcop.cdcooper,'CTA_CONVENIO_CEB');
              --Se nao encontrou parametro
              IF vr_nrconven_ceb IS NULL THEN
                --Montar mensagem erro
                vr_cdcritic:= 0;
                vr_dscritic:= 'Nao foi encontrado convenio CEB 5 digitos.';
              END IF;*/

              -- Desativar tratamento com ceb 5 digitos, deve sempre ter 4 digitos
              /* tratamento para titulos com CEB 5 digitos */
              /*IF rw_crapcop.cdcooper = 1 AND
                 rw_crapcco.nrconven = vr_nrconven_ceb AND
                 SUBSTR(vr_nrconvceb,1,3) = '100' THEN
                --Selecionar cadastro emissao bloquetos
                OPEN cr_crapceb (pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_nrconven => rw_crapcco.nrconven
                                ,pr_nrcnvceb => TRIM(gene0002.fn_mask(vr_nrconvceb,'ZZZ9')));
                --Posicionar no proximo registro
                FETCH cr_crapceb INTO rw_crapceb;
                --Se nao encontrou
                IF cr_crapceb%NOTFOUND OR rw_crapceb.qtdreg > 1 THEN
                  --Fechar Cursor
                  CLOSE cr_crapceb;
                  --Selecionar cadastro emissao bloquetos e cobranca
                  FOR rw_crapceb2 IN cr_crapceb2 (pr_cdcooper => rw_crapcop.cdcooper
                                                 ,pr_nrconven => rw_crapcco.nrconven
                                                 ,pr_nrcnvceb => TRIM(gene0002.fn_mask(vr_nrconvceb,'ZZZ9'))
                                                 ,pr_nrdocmto => vr_bloqueto4
                                                 ,pr_vltitulo => vr_vltitulo) LOOP
                    --ROWID da cobranca
                    vr_rowidcob:= rw_crapceb2.ROWID;
                  END LOOP;
                  --Selecionar informacoes Cobranca
                  OPEN cr_crapcob1 (pr_rowid => vr_rowidcob);
                  --Posicionar no proximo registro
                  FETCH cr_crapcob1 INTO rw_crapcob;
                  --Se nao encontrar
                  IF cr_crapcob1%FOUND THEN
                    --Selecionar cadastro emissao bloquetos
                    OPEN cr_crapceb3 (pr_cdcooper => rw_crapcob.cdcooper
                                     ,pr_nrconven => rw_crapcob.nrcnvcob
                                     ,pr_nrdconta => rw_crapcob.nrdconta);
                    --Posicionar no proximo registro
                    FETCH cr_crapceb3 INTO rw_crapceb3;
                    --Se Encontrou
                    IF cr_crapceb3%FOUND THEN
                      vr_nrconvceb:= rw_crapceb3.nrcnvceb;
                    END IF;
                    --Fechar Cursor
                    CLOSE cr_crapceb3;
                  END IF;
                  --Fechar Cursor
                  CLOSE cr_crapcob1;
                END IF;
                --Fechar Cursor
                IF cr_crapceb%ISOPEN THEN
                  CLOSE cr_crapceb;
                END IF;
              END IF;*/
              --Selecionar cadastro emissao bloquetos
              OPEN cr_crapceb4 (pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_nrconven => rw_crapcco.nrconven
                               ,pr_nrcnvceb => vr_nrconvceb);
              --Posicionar no proximo registro
              FETCH cr_crapceb4 INTO rw_crapceb4;
              --Se Encontrou
              IF cr_crapceb4%FOUND THEN
                /* verificar se cooperado foi migrado */
                OPEN cr_craptco (pr_cdcooper => rw_crapcop.cdcooper --16 --odirlei
                                ,pr_cdcopant => rw_crapceb4.cdcooper
                                ,pr_nrctaant => rw_crapceb4.nrdconta
                                ,pr_flgativo => 1
                                ,pr_tpctatrf => 3);
                --Posicionar no proximo registro
                FETCH cr_craptco INTO rw_craptco;
                --Se nao encontrar
                IF cr_craptco%FOUND THEN
                  --Fechar Cursores
                  CLOSE cr_craptco;
                  IF cr_crapceb4%ISOPEN THEN
                    CLOSE cr_crapceb4;
                  END IF;
                  IF cr_crapcco%ISOPEN THEN
                    CLOSE cr_crapcco;
                  END IF;
                  /* se cooperado foi migrado, entao eh liquidacao interbancaria */
                  --Levantar Excecao para sair
                  RAISE vr_exc_saida;
                ELSE
                  --Numero da Conta
                  vr_nrdconta:= rw_crapceb4.nrdconta;
                  --Numero Bloqueto
                  vr_bloqueto2:= vr_bloqueto4;
                END IF;
                --Fechar Cursor
                IF cr_craptco%ISOPEN THEN
                  CLOSE cr_craptco;
                END IF;
              ELSE
                 /* se convenio for migracao, entao eh liquidacao interbancaria */
                 IF  rw_crapcco.dsorgarq = 'MIGRACAO' OR
                     rw_crapcco.dsorgarq = 'INCORPORACAO' THEN
                   --Levantar Excecao para sair
                   RAISE vr_exc_saida;
                 ELSE
                   --Se for para gerar critica
                   IF pr_flgcritica THEN
                     --Fechar Cursor
                     CLOSE cr_crapceb4;
                     --Mensagem erro
                     vr_des_erro:= '882 - Convenio '||
                                   'AILOS nao encontrado. ('||gene0002.fn_mask(vr_nrconvceb,'9999')||')';
                     --Criar erro
                     CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                          ,pr_cdagenci => pr_cod_agencia
                                          ,pr_nrdcaixa => vr_nrdcaixa
                                          ,pr_cod_erro => 0
                                          ,pr_dsc_erro => vr_des_erro
                                          ,pr_flg_erro => TRUE
                                          ,pr_cdcritic => vr_cdcritic
                                          ,pr_dscritic => vr_dscritic);
                     --Se ocorreu erro
                     IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                     ELSE
                       vr_cdcritic:= 0;
                       vr_dscritic:= vr_des_erro;
                       --Levantar Excecao
                       RAISE vr_exc_erro;
                     END IF;
                   END IF;
                 END IF;
              END IF;
              --Fechar Cursor
              IF cr_crapceb4%ISOPEN THEN
                CLOSE cr_crapceb4;
              END IF;
            END IF;

            --Selecionar informacoes cobranca
            OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_cdbandoc => rw_crapcco.cddbanco
                            ,pr_nrcnvcob => rw_crapcco.nrconven
                            ,pr_nrdctabb => rw_crapcco.nrdctabb
                            ,pr_nrdocmto => vr_bloqueto2
                            ,pr_nrdconta => vr_nrdconta);
            --Posicionar no proximo registro
            FETCH cr_crapcob INTO rw_crapcob;
            --Se nao encontrar
            IF cr_crapcob%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapcob;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapcob;
          ELSE
            --Selecionar informacoes cobranca
            OPEN cr_crapcob2 (pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_cdbandoc => rw_crapcco.cddbanco
                             ,pr_nrcnvcob => rw_crapcco.nrconven
                             ,pr_nrdctabb => rw_crapcco.nrdctabb
                             ,pr_nrdocmto => vr_bloqueto3);
            --Posicionar no proximo registro
            FETCH cr_crapcob2 INTO rw_crapcob;
            --Verificar se encontrou
            vr_flgcrapcob:= cr_crapcob2%FOUND;
            --Fechar Cursor
            CLOSE cr_crapcob2;

            --Se nao encontrou
            IF NOT vr_flgcrapcob THEN
              --Selecionar informacoes cobranca
              OPEN cr_crapcob2 (pr_cdcooper => rw_crapcop.cdcooper
                               ,pr_cdbandoc => rw_crapcco.cddbanco
                               ,pr_nrcnvcob => rw_crapcco.nrconven
                               ,pr_nrdctabb => rw_crapcco.nrdctabb
                               ,pr_nrdocmto => vr_bloqueto1);
              --Posicionar no proximo registro
              FETCH cr_crapcob2 INTO rw_crapcob;
              --Verificar se encontrou
              vr_flgcrapcob:= cr_crapcob2%FOUND;
              --Fechar Cursor
              CLOSE cr_crapcob2;
            END IF;
          END IF;

          --Se nao encontrou crapcob
          IF NOT vr_flgcrapcob THEN
            /* se nao existir titulo, entao verificar se cooperado eh migrado */
            OPEN cr_craptco (pr_cdcooper => 16
                            ,pr_cdcopant => rw_crapcop.cdcooper
                            ,pr_nrctaant => vr_nrdconta
                            ,pr_flgativo => 1
                            ,pr_tpctatrf => 3);
            --Posicionar no proximo registro
            FETCH cr_craptco INTO rw_craptco;
            --Se nao encontrar
            IF cr_craptco%FOUND THEN
              --Fechar Cursor
              CLOSE cr_craptco;
              --Sair
              RAISE vr_exc_saida;
            END IF;
            --Fechar Cursor
            CLOSE cr_craptco;
          END IF;

          --Selecionar informacoes associado
          OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_nrdconta => vr_nrdconta);
          --Posicionar no proximo registro
          FETCH cr_crapass INTO rw_crapass;
          --Verificar se encontrou
          vr_flgcrapass:= cr_crapass%FOUND;
          --Fechar Cursor
          CLOSE cr_crapass;

          /* condicao especial para contas migradas p AltoVale */
          IF NOT vr_flgcrapcob THEN
            --vr_dsconmig = 1601301,0457595
            IF (rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE') OR
               (rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') AND
                INSTR(vr_dsconmig,To_Number(To_Char(rw_crapcco.nrconven,'fm0000000'))) > 0 AND
                NOT vr_flgcrapass) THEN
              --Sair do programa
              RAISE vr_exc_saida;
            END IF;
          END IF;

          --Nao existir Cobranca
          IF NOT vr_flgcrapcob THEN
            --vr_dsconmig = 1601301,0457595
            IF (rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE') OR
               (rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') AND
                INSTR(vr_dsconmig,To_Number(To_Char(rw_crapcco.nrconven,'fm0000000'))) > 0 AND
                vr_flgcrapass) THEN
              --Criar Cobranca
              BEGIN
                INSERT INTO crapcob
                  (crapcob.cdcooper
                  ,crapcob.nrdconta
                  ,crapcob.cdbandoc
                  ,crapcob.nrdctabb
                  ,crapcob.nrcnvcob
                  ,crapcob.nrdocmto
                  ,crapcob.incobran
                  ,crapcob.dtretcob
                  ,crapcob.nrnosnum)
                VALUES
                  (rw_crapcop.cdcooper
                  ,vr_nrdconta
                  ,rw_crapcco.cddbanco
                  ,rw_crapcco.nrdctabb
                  ,rw_crapcco.nrconven
                  ,vr_bloqueto2
                  ,0
                  ,rw_crapdat.dtmvtocd
                  ,vr_nrnosnum);
              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao criar cobranca. '||SQLERRM;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
              --Valores de retorno
              pr_insittit:= 2;
              pr_intitcop:= 1;
              pr_nrdconta:= rw_crapcob.nrdconta;
              pr_convenio:= rw_crapcob.nrcnvcob;
              pr_bloqueto:= rw_crapcob.nrdocmto;
              pr_contaconve:= rw_crapcco.nrdctabb;
            ELSE
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 592
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 592;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          ELSE
            /* excluido/pago e Baixado */
            IF (rw_crapcob.incobran IN (5,3) AND pr_flgcritica) THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 594
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 594;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            ELSIF rw_crapcob.dtretcob IS NULL AND pr_flgcritica THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 589
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 589;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            ELSE
              --Retornar valores
              pr_insittit:= 2;
              pr_intitcop:= 1;
              pr_nrdconta:= rw_crapcob.nrdconta;
              pr_convenio:= rw_crapcob.nrcnvcob;
              pr_bloqueto:= rw_crapcob.nrdocmto;
              pr_contaconve:= rw_crapcco.nrdctabb;
            END IF;
          END IF;
        END IF;
        --Fechar Cursor
        IF cr_crapcco%ISOPEN THEN
          CLOSE cr_crapcco;
        END IF;
      ELSIF vr_banco = rw_crapcop.cdbcoctl  THEN /* CECRED */
        --Selecionar informacoes associado
        OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => vr_nrdconta);
        --Posicionar no proximo registro
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrar
        vr_flgcrapass:= cr_crapass%FOUND;
        --Fechar Cursor
        CLOSE cr_crapass;

        --Selecionar informacoes cadastro cobranca
        OPEN cr_crapcco2 (pr_cdcooper  => rw_crapcop.cdcooper
                         ,pr_cddbanco  => vr_banco
                         ,pr_nrconven  => To_Number(vr_convenio1));
        --Posicionar no primeiro registro
        FETCH cr_crapcco2 INTO rw_crapcco;
        --Se encontrou
        IF cr_crapcco2%FOUND THEN
          IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' OR
             rw_crapcco.dsorgarq = 'INTERNET'               OR
             rw_crapcco.dsorgarq = 'MIGRACAO'               THEN
            --Selecionar informacoes cobranca
            OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_cdbandoc => rw_crapcco.cddbanco
                            ,pr_nrcnvcob => rw_crapcco.nrconven
                            ,pr_nrdctabb => rw_crapcco.nrdctabb
                            ,pr_nrdocmto => vr_bloqueto2
                            ,pr_nrdconta => vr_nrdconta);
            --Posicionar no proximo registro
            FETCH cr_crapcob INTO rw_crapcob;
            --Se nao encontrar
            IF cr_crapcob%NOTFOUND THEN
              --Fechar Cursor
              CLOSE cr_crapcob;
              /* verificar se cooperado foi migrado */
              OPEN cr_craptco (pr_cdcooper => 16
                              ,pr_cdcopant => rw_crapcop.cdcooper
                              ,pr_nrctaant => vr_nrdconta
                              ,pr_flgativo => 1
                              ,pr_tpctatrf => 3);
              --Posicionar no proximo registro
              FETCH cr_craptco INTO rw_craptco;
              --Se nao encontrar
              IF cr_craptco%FOUND THEN
                --Fechar Cursor
                CLOSE cr_craptco;
                IF cr_crapcco2%ISOPEN THEN
                  CLOSE cr_crapcco2;
                END IF;
                --Sair
                RAISE vr_exc_saida;
              END IF;
              --Fechar Cursor
              CLOSE cr_craptco;
              --vr_dsconmig = 1601301,0457595
              IF (rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE') OR
               (rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') AND
                INSTR(vr_dsconmig,To_Number(To_Char(rw_crapcco.nrconven,'fm0000000'))) > 0 AND
                vr_flgcrapass) THEN
                --Criar Cobranca
                BEGIN
                  INSERT INTO crapcob
                    (crapcob.cdcooper
                    ,crapcob.nrdconta
                    ,crapcob.cdbandoc
                    ,crapcob.nrdctabb
                    ,crapcob.nrcnvcob
                    ,crapcob.nrdocmto
                    ,crapcob.incobran
                    ,crapcob.dtretcob
                    ,crapcob.nrnosnum)
                  VALUES
                    (rw_crapcop.cdcooper
                    ,vr_nrdconta
                    ,rw_crapcco.cddbanco
                    ,rw_crapcco.nrdctabb
                    ,rw_crapcco.nrconven
                    ,vr_bloqueto2
                    ,0
                    ,rw_crapdat.dtmvtocd
                    ,vr_nrnosnum);
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 0;
                    vr_dscritic:= 'Erro ao criar cobranca. '||SQLERRM;
                END;
              ELSE
                /* se titulo 085 nao encontrado e migracao entao eh liquidacao interbancaria */
                IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                  --Sair
                  RAISE vr_exc_saida;
                END IF;
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 592
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 592;
                  vr_dscritic:= NULL;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              END IF;
            ELSE
              --Fechar Cursor
              CLOSE cr_crapcob;
              /* verificar se cooperado foi migrado */
              OPEN cr_craptco (pr_cdcooper => 16
                              ,pr_cdcopant => rw_crapcob.cdcooper
                              ,pr_nrctaant => rw_crapcob.nrdconta
                              ,pr_flgativo => 1
                              ,pr_tpctatrf => 3);
              --Posicionar no proximo registro
              FETCH cr_craptco INTO rw_craptco;
              --Se nao encontrar
              IF cr_craptco%FOUND THEN
                --Fechar Cursor
                CLOSE cr_craptco;
                --Sair
                RAISE vr_exc_saida;
              END IF;
              --Fechar Cursor
              CLOSE cr_craptco;

              /* excluido/pago e baixado */
              IF (rw_crapcob.incobran IN (5,3) AND pr_flgcritica) THEN
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 594
                                     ,pr_dsc_erro => NULL
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 594;
                  vr_dscritic:= NULL;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              ELSIF rw_crapcob.dtretcob IS NULL AND pr_flgcritica THEN
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 589
                                     ,pr_dsc_erro => NULL
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 589;
                  vr_dscritic:= NULL;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              ELSE
                --Retornar valores
                pr_insittit:= 2;
                pr_intitcop:= 1;
                pr_nrdconta:= rw_crapcob.nrdconta;
                pr_convenio:= rw_crapcob.nrcnvcob;
                pr_bloqueto:= rw_crapcob.nrdocmto;
                pr_contaconve:= rw_crapcco.nrdctabb;
              END IF;
            END IF;
            --Fechar Cursor
            IF cr_crapcob%ISOPEN THEN
              CLOSE cr_crapcob;
            END IF;
          END IF;
        END IF;
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0014.pc_identifica_titulo_coop. '||SQLERRM;

    END;
  END pc_identifica_titulo_coop;


  /* Procedure para retornar valores titulos iptu */
  PROCEDURE pc_retorna_vlr_titulo_iptu (pr_cooper          IN INTEGER               --Codigo Cooperativa
                                       ,pr_nrdconta        IN INTEGER               --Numero da Conta
                                       ,pr_idseqttl        IN crapttl.idseqttl%TYPE --Sequencial do titular
                                       ,pr_cod_operador    IN VARCHAR2              --Codigo do operador
                                       ,pr_cod_agencia     IN INTEGER               --Codigo da Agencia
                                       ,pr_nro_caixa       IN INTEGER               --Numero do Caixa
                                       ,pr_titulo1         IN OUT NUMBER            -- FORMAT "99999,99999"
                                       ,pr_titulo2         IN OUT NUMBER            -- FORMAT "99999,999999"
                                       ,pr_titulo3         IN OUT NUMBER            -- FORMAT "99999,999999"
                                       ,pr_titulo4         IN OUT NUMBER            -- FORMAT "9"
                                       ,pr_titulo5         IN OUT NUMBER            -- FORMAT "zz,zzz,zzz,zzz999"
                                       ,pr_codigo_barras   IN OUT VARCHAR2          --Codigo de Barras
                                       ,pr_iptu            IN PLS_INTEGER           --IPTU
                                       ,pr_valor_informado IN NUMBER                --Valor informado
                                       ,pr_cadastro        IN NUMBER                --Numero Cadastro
                                       ,pr_cadastro_conf   IN NUMBER                --Confirmacao Cadastro
                                       ,pr_dt_agendamento  IN DATE                  --Data Agendamento
                                       ,pr_cdctrlcs        IN tbcobran_consulta_titulo.cdctrlcs%TYPE DEFAULT NULL --> Numero de controle da consulta no NPC
                                       ,pr_vlfatura        OUT NUMBER               --Valor da Fatura
                                       ,pr_outra_data      OUT PLS_INTEGER          --Outra data
                                       ,pr_outro_valor     OUT PLS_INTEGER          --Outro valor
                                       ,pr_nrdconta_cob    OUT INTEGER              --Numero Conta Cobranca
                                       ,pr_insittit        OUT INTEGER              --Situacao Titulo
                                       ,pr_intitcop        OUT INTEGER              --Titulo da Cooperativa
                                       ,pr_convenio        OUT NUMBER               --Numero Convenio
                                       ,pr_bloqueto        OUT NUMBER               --Numero Bloqueto
                                       ,pr_contaconve      OUT INTEGER              --Numero Conta Convenio
                                       ,pr_cobregis        OUT PLS_INTEGER          --Cobranca Registrada
                                       ,pr_msgalert        OUT VARCHAR2             --Mensagem de alerta
                                       ,pr_vlrjuros        OUT NUMBER               --Valor dos Juros
                                       ,pr_vlrmulta        OUT NUMBER               --Valor da Multa
                                       ,pr_vldescto        OUT NUMBER               --Valor do Desconto
                                       ,pr_vlabatim        OUT NUMBER               --Valor do Abatimento
                                       ,pr_vloutdeb        OUT NUMBER               --Valor Saida Debitado
                                       ,pr_vloutcre        OUT NUMBER               --Valor Saida Creditado
                                       ,pr_cdcritic        OUT INTEGER              --Codigo do erro
                                       ,pr_dscritic        OUT VARCHAR2) IS         --Descricao do erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_retorna_vlr_titulo_iptu    Antigo: dbo/b2crap14.p/retorna-valores-titulo-iptu
  --  Sistema  : Procedure para retornar valores dos titulos iptu
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 03/01/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para retornar valores dos titulos iptu
  --
  --
  --  Alteracoes:  09/05/2014 - Replicar manutenção progress (Odirlei/AMcom).
  --
  --               03/06/2014 - Verificacao de codigo de barra fraudulento (Andrino-RKAM).
  --
  --               01/07/2014 - Incluso tratamento para novo Fator de Vencimento
  --                            (Daniel)
  --
  --               22/10/2014 - Ajuste no calculo de titulos vencidos - variavel vr_critica_data
  --                            nao estava sendo utilizada de forma correta. (Rafael)
  --
  --               24/10/2014 - Novo ajuste no calculo de titulos vencidos, desta vez para
  --                            os titulos da Nossa Remessa (outros bancos). (Rafael)
  --
  --               29/10/2014 - Ajuste na rotina que calcula vencimento ref. a boletos que
  --                            nao possuem vencimento (nulo). (Rafael)
  --
  --               05/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir
  --                            nomenclaturas Cedente por Beneficiário e  Sacado por Pagador
  --                            Chamado 229313 (Jean Reddiga - RKAM).
  --
  --               12/12/2014 - Tratamento para nao aceitar titulos do Banco Santander (353).
  --                            (Jaison - SD: 231108)
  --
  --               22/12/2014 - Ajustes para retornar valores de juros e abatimento com valor zero
  --                            quando não tiver valor, e ajustado para calcular juros mesmo se for boleto de
  --                            convenio de incorporação/migração (Odirlei/AMcom SD 234943)
  --
  --               05/01/2014 - Ajuste para que a validação de limite de valor do VR_Boleto seja
  --                            realizado apenas para o TAA e internet bank, assim não apresentando a critica
  --                            no caixa online conforme relatado no chamado SD 235679 (Odirlei/AMcom)
  --
  --               17/09/2015 - Ajuste melhoria de performace, incluido hinto no cursor cr_crapcob
  --					        (Odirlei-AMcom)
  --
  --               26/10/2015 - Inclusao de verificacao indicador estado de crise. (Jaison/Andrino)
  --
  --               28/10/2015 - Recusar valor de boleto a maior quando boleto for para regularizacao de
  --                            contrato de emprestimo. Projeto 210. (Rafael)
  --
  --               03/11/2015 - Recusar boleto vencido de boletos de contrato emprestimo. Projeto 210. (Rafael)
  --
  --               04/01/2016 - Ajuste na leitura da tabela crapcbf para utilizar UPPER nos campos VARCHAR
  --                            pois será incluido o UPPER no indice desta tabela - SD 375854
  --                            (Adriano).
  --
  --               11/01/2016 - Ajuste na leitura da tabela crapcbf para utilizar UPPER nos campos VARCHAR
  --                            pois será incluido o UPPER no indice desta tabela - SD 375854
  --                            (Adriano).
  --
  --               22/06/2016 - Ajustado leitura da crapagb para buscar apenas as agencias ativas e
  --                            alterado a critica de agencia nao encontrada de 100 para 956
  --                            (Douglas - Chamado 417655)
  --
  --               25/08/2016 - Caso encontre o parâmetro pagadorvip permite pagar valor menor que o valor do
  --                            documento (M271 - Kelvin)
  --
  --               13/06/2017 - Retirado validacao que estava feita de forma incorreta olhando no valor
  --                            do titulo para nao ocorrer critica 100 (Tiago/Elton #691470)
  --
  --               01/08/2017 - Ajustes contigencia CIP. PRJ340-NPC (Odirlei-AMcom)
  --
  --               30/10/2017 - Nao validar valor maximo do boleto ao verificar multiplos pagamentos. (Rafael)
  --
  --               08/08/2018 - Adicionado teste para não permitir pagamentos vencidos de boletos da cobtit (Luis Fernando - GFT)
  --
  --			   03/01/2019 - Nova regra para bloquear bancos. (Andrey Formigari - #SCTASK0035990)
  --
  --               12/08/2019 - Adicionada busca do cdctrlcs (Jefferson - MoutS)
  --
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar Titulos
      CURSOR cr_craptit (pr_cdcooper IN craptit.cdcooper%type
                        ,pr_dtmvtolt IN craptit.dtmvtolt%TYPE
                        ,pr_nrdconta IN craptit.nrdconta%type
                        ,pr_cdagenci IN craptit.cdagenci%type
                        ,pr_cdbccxlt IN craptit.cdbccxlt%type
                        ,pr_nrdolote IN craptit.nrdolote%type
                        ,pr_dscodbar IN craptit.dscodbar%type) IS
        SELECT /*+ INDEX (craptit craptit##craptit3) */
               craptit.dscodbar
              ,craptit.flgpgdda
              ,craptit.vldpagto
              ,craptit.rowid
        FROM craptit
        WHERE craptit.cdcooper = pr_cdcooper
        AND   craptit.dtmvtolt = pr_dtmvtolt
        AND   craptit.nrdconta = pr_nrdconta
        AND   craptit.cdagenci = pr_cdagenci
        AND   craptit.cdbccxlt = pr_cdbccxlt
        AND   craptit.nrdolote = pr_nrdolote
        AND   Upper(craptit.dscodbar) = Upper(pr_dscodbar);
      rw_craptit cr_craptit%ROWTYPE;

      --Selecionar Titulos
      CURSOR cr_craptit2 (pr_cdcooper IN craptit.cdcooper%type
                         ,pr_dtmvtolt IN craptit.dtmvtolt%TYPE
                         ,pr_dscodbar IN craptit.dscodbar%type) IS
        SELECT /*+ INDEX (craptit craptit##craptit3) */
               craptit.dscodbar
              ,craptit.flgpgdda
              ,craptit.vldpagto
              ,craptit.rowid
        FROM craptit
        WHERE craptit.cdcooper = pr_cdcooper
        AND   craptit.dtmvtolt = pr_dtmvtolt
        AND   Upper(craptit.dscodbar) = Upper(pr_dscodbar);

      --Selecionar Titulos
      CURSOR cr_craptit3 (pr_cdcooper IN craptit.cdcooper%type
                         ,pr_dtmvtolt IN craptit.dtmvtolt%TYPE
                         ,pr_cdagenci IN craptit.cdagenci%type
                         ,pr_cdbccxlt IN craptit.cdbccxlt%type
                         ,pr_nrdolote IN craptit.nrdolote%type
                         ,pr_dscodbar IN craptit.dscodbar%type) IS
        SELECT /*+ INDEX (craptit craptit##craptit3) */
               craptit.dscodbar
              ,craptit.flgpgdda
              ,craptit.vldpagto
              ,craptit.rowid
        FROM craptit
        WHERE craptit.cdcooper = pr_cdcooper
        AND   craptit.dtmvtolt = pr_dtmvtolt
        AND   craptit.cdagenci = pr_cdagenci
        AND   craptit.cdbccxlt = pr_cdbccxlt
        AND   craptit.nrdolote = pr_nrdolote
        AND   Upper(craptit.dscodbar) = Upper(pr_dscodbar);

      --Selecionar informacoes convenio cobranca
      CURSOR cr_crapcco (pr_codigo_barras IN VARCHAR2
                        ,pr_cddbanco      IN crapcco.cddbanco%TYPE) IS
        SELECT crapcco.cddbanco,
               crapcco.dsorgarq,
               crapcco.flgregis
        FROM crapcco
        WHERE SUBSTR(gene0002.fn_mask(crapcco.nrconven,'9999999'),2,4) = SUBSTR(pr_codigo_barras,20,4)
        AND crapcco.cddbanco = pr_cddbanco
        AND NOT (crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO'));
      rw_crapcco cr_crapcco%ROWTYPE;

      --Selecionar informacoes convenio cobranca
      CURSOR cr_crapcco2 (pr_cdcooper IN crapcco.cdcooper%type
                         ,pr_nrconven IN crapcco.nrconven%type
                         ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
        SELECT crapcco.cddbanco,
               crapcco.dsorgarq,
               crapcco.flgregis
        FROM crapcco
        WHERE crapcco.cdcooper = pr_cdcooper
        AND   crapcco.nrconven = pr_nrconven
        AND   crapcco.cddbanco = pr_cddbanco;

      --Selecionar informacoes cobranca
      CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdconta IN crapcob.nrdconta%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type
                        ,pr_nrdctabb IN crapcob.nrdctabb%type) IS
        SELECT /*+index (crapcob CRAPCOB##CRAPCOB1) */
               crapcob.vltitulo
              ,crapcob.cdmensag
              ,crapcob.vldescto
              ,crapcob.vlabatim
              ,crapcob.tpdmulta
              ,crapcob.vlrmulta
              ,crapcob.vljurdia
              ,crapcob.tpjurmor
              ,crapcob.dtvencto
              ,crapcob.dsinform
              ,crapcob.inpagdiv
              ,crapcob.vlminimo
              ,crapceb.flgpgdiv
        FROM crapcob,
             crapceb
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdconta = pr_nrdconta
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.cdcooper = crapceb.cdcooper(+)
        AND   crapcob.nrdconta = crapceb.nrdconta(+)
        AND   crapcob.nrcnvcob = crapceb.nrconven(+);
      rw_crapcob cr_crapcob%ROWTYPE;

      -- Verificacao de codigo de barras fraudulento
      CURSOR cr_crapcbf(pr_cd_barra crapcbf.dsfraude%TYPE) IS
        SELECT 1
          FROM crapcbf
         WHERE tpfraude = 1 -- boletos
           AND UPPER(dsfraude) = UPPER(pr_cd_barra);
      rw_crapcbf cr_crapcbf%ROWTYPE;

      -- Verificar se erro ja foi gravado
      CURSOR cr_craperr (pr_cdcritic IN INTEGER,
                         pr_dscritic IN VARCHAR2) IS
      SELECT 1 flexiste
        FROM craperr err
       WHERE err.cdcooper = pr_cooper
         AND err.cdagenci = pr_cod_agencia
         AND err.nrdcaixa = pr_nro_caixa
         AND ( err.cdcritic = pr_cdcritic OR
               upper(err.dscritic) = upper(pr_dscritic));
      rw_craperr cr_craperr%ROWTYPE;

      --Variaveis Locais
      vr_critica_data   BOOLEAN:= FALSE;
      vr_flg_zeros      BOOLEAN;
      vr_dstextab       craptab.dstextab%TYPE;
      vr_nrdcaixa       INTEGER;
      vr_contador       INTEGER;
      vr_tab_intransm   INTEGER;
      vr_tab_hrlimite   INTEGER;
      vr_retorno        BOOLEAN;
      vr_flg_cdbarerr   BOOLEAN;
      vr_hrvrbini       INTEGER;
      vr_hrvrbfim       INTEGER;
      vr_nro_lote       INTEGER;
      vr_nro_digito     INTEGER;
      vr_idtitdda       NUMBER:= 0;
      vr_de_valor_calc  VARCHAR2(100);
      vr_de_campo       NUMBER;
      vr_de_p_titulo5   NUMBER;
      vr_dt_dtvencto    DATE;
      vr_dt_feriado     DATE;
      vr_des_corpo      VARCHAR2(1000);
      vr_inestcri       INTEGER;
      vr_clobxmlc       CLOB;

      vr_cdctrlcs tbcobran_consulta_titulo.cdctrlcs%TYPE;

      vr_nrdipatu VARCHAR2(1000);
      vr_nridetit       NUMBER;
      vr_tpdbaixa       INTEGER;
      vr_flcontig       INTEGER;
      vr_invalcon       INTEGER;
	  vr_cdbancos crapprm.dsvlrprm%TYPE;

      --Variaveis Erro
      vr_des_erro VARCHAR2(1000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_vcto_cdcritic crapcri.cdcritic%TYPE;
      vr_vcto_dscritic VARCHAR2(4000);
      --Tipo da tabela de erros
      vr_tab_erro GENE0001.typ_tab_erro;
      --Tipo de registro para datas
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis Excecao
      vr_exc_erro EXCEPTION;

      PROCEDURE pc_busca_cdctrlcs(pr_dscodbar IN  craplau.dscodbar%TYPE
                                 ,pr_cdctrlcs OUT craplau.cdctrlcs%TYPE) IS

        CURSOR cr_cct(pr_dscodbar craplau.dscodbar%TYPE) IS
          SELECT MAX(cct.cdctrlcs)
            FROM tbcobran_consulta_titulo cct
           WHERE cct.dscodbar = pr_dscodbar;
        rw_cct cr_cct%ROWTYPE;
        
      BEGIN
        
        OPEN cr_cct(pr_dscodbar => pr_dscodbar);
        FETCH cr_cct INTO pr_cdctrlcs;
        CLOSE cr_cct;
        
      EXCEPTION
       WHEN OTHERS THEN
         CECRED.pc_internal_exception;
         pr_cdctrlcs := NULL;
      END pc_busca_cdctrlcs;

    BEGIN -- inicio pc_retorna_vlr_titulo_iptu
      --Inicializar variaveis retorno
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      pr_cobregis:= 0;
      pr_outra_data:=0;
      pr_outro_valor:=0;
      pr_vlrjuros := 0;
      pr_vlrmulta := 0;
      pr_vldescto := 0;
      pr_vlabatim := 0;
      pr_vloutdeb := 0;
      pr_vloutcre := 0;

      /* Tratamento especifico para VR Boletos */
      BEGIN
        vr_idtitdda:= TO_NUMBER(GENE0002.fn_busca_entrada(2,pr_codigo_barras,';'));
      EXCEPTION
        WHEN OTHERS THEN
          vr_idtitdda:= 0;
      END;
      /* Se titulo for VR Boleto e DDA, remover idtitdda do c¿digo de barras */
      IF vr_idtitdda > 0 THEN
        pr_codigo_barras:= GENE0002.fn_busca_entrada(1,pr_codigo_barras,';');
      END IF;
      /* Tratamento de erros para internet e TAA */
      IF pr_cod_agencia IN (90,91) THEN
        vr_nrdcaixa:= to_number(pr_nrdconta || pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;

      --Inicializar parametros saida
      pr_vlfatura:= 0;
      pr_outra_data:= 0;
      pr_outro_valor:= 0;
      --Eliminar Erro
      CXON0000.pc_elimina_erro (pr_cooper      => pr_cooper       --Codigo cooperativa
                               ,pr_cod_agencia => pr_cod_agencia  --Codigo agencia
                               ,pr_nro_caixa   => vr_nrdcaixa     --Numero Caixa
                               ,pr_cdcritic    => vr_cdcritic     --Codigo do erro
                               ,pr_dscritic    => vr_dscritic);   --Descricao do erro
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se informou valor zerado
      IF pr_valor_informado = 0 THEN
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => 'Valor deve ser informado'
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Valor deve ser informado';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Se for iptu
      IF pr_iptu = 1 THEN
        --Numero lote
        vr_nro_lote:= 17000 + pr_nro_caixa;
      ELSE
        --Numero lote
        vr_nro_lote:= 16000 + pr_nro_caixa;
      END IF;

      /* Verificar Codigo Barras / Linha Digitavel - Digito/Codigo */
      IF pr_iptu = 0 THEN
        /*  Tabela com o horario limite para digitacao  */
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'HRTRTITULO'
                                               ,pr_tpregist => pr_cod_agencia);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 676
                               ,pr_dsc_erro => NULL
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 676;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        ELSE
          --Inicio transmissao
          vr_tab_intransm:= to_number(SUBSTR(vr_dstextab,1,1));
          --Hora Limite
          vr_tab_hrlimite:= to_number(SUBSTR(vr_dstextab,3,5));
        END IF;

        -- Busca o indicador estado de crise
        SSPB0001.pc_estado_crise (pr_inestcri => vr_inestcri
                                 ,pr_clobxmlc => vr_clobxmlc);

        -- Se estiver setado como estado de crise
        -- Se estiver setado como estado de crise
        IF  vr_inestcri > 0 AND pr_valor_informado >= 250000 THEN
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => 'Sistema SPB temporariamente indisponível para pagamento de VR Boleto!' -- Marcelo Telles Coelho - Projeto 475 - SPRINT B
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            vr_cdcritic := 0;
            vr_dscritic := 'Sistema SPB temporariamente indisponível para pagamento de VR Boleto!'; -- Marcelo Telles Coelho - Projeto 475 - SPRINT B
            RAISE vr_exc_erro;
        END IF;

        --Se foi informado titulo
        IF NVL(pr_titulo1,0) <> 0 OR
           NVL(pr_titulo2,0) <> 0 OR
           NVL(pr_titulo3,0) <> 0 OR
           NVL(pr_titulo4,0) <> 0 OR
           NVL(pr_titulo5,0) <> 0 THEN

          --Validar os digitos das 3 primeiras partes da linha digitavel
          FOR idx IN 1..3 LOOP

            --Determinar a parte que ser¿ validada
            CASE idx
              WHEN 1 THEN
                vr_de_valor_calc:= pr_titulo1;
                vr_flg_zeros:= TRUE;
              WHEN 2 THEN
                vr_de_valor_calc:= pr_titulo2;
                vr_flg_zeros:= FALSE;
              WHEN 3 THEN
                vr_de_valor_calc:= pr_titulo3;
                vr_flg_zeros:= FALSE;
            END CASE;
            --Calcular digito verificador

            /*  Calcula digito- Primeiro campo da linha digitavel  */
            CXON0000.pc_calc_digito_verif (pr_valor        => vr_de_valor_calc   --> Valor Calculado
                                          ,pr_valida_zeros => vr_flg_zeros       --> Validar Zeros
                                          ,pr_nro_digito   => vr_nro_digito      --> Digito Verificador
                                          ,pr_retorno      => vr_retorno);       --> Retorno digito correto
            --Se retornou erro
            IF vr_retorno = FALSE THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 8
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 8;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END LOOP; --For idx 1..3

          /*  Compoe o codigo de barras atraves da linha digitavel  */
          pr_codigo_barras:= SUBSTR(gene0002.fn_mask(pr_titulo1,'9999999999'),1,4)||
                             gene0002.fn_mask(pr_titulo4,'9')||
                             gene0002.fn_mask(pr_titulo5,'99999999999999')||
                             SUBSTR(gene0002.fn_mask(pr_titulo1,'9999999999'),5,1)||
                             SUBSTR(gene0002.fn_mask(pr_titulo1,'9999999999'),6,4)||
                             SUBSTR(gene0002.fn_mask(pr_titulo2,'99999999999'),1,10)||
                             SUBSTR(gene0002.fn_mask(pr_titulo3,'99999999999'),1,10);
        ELSE
          /* Compoe a Linha Digitavel atraves do Codigo de Barras */
          /* validar tamanho de 44 caracteres no codigo de barras e
                      somente aceitar algarismo 0-9 */
          vr_flg_cdbarerr:= gene0002.fn_numerico(pr_codigo_barras) = FALSE;

          --Se o codigo barras for diferente 44 posicoes
          IF Length(pr_codigo_barras) != 44 THEN
            vr_flg_cdbarerr:= TRUE;
          END IF;

          --Se o codigo barras estiver errado
          IF  vr_flg_cdbarerr THEN
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => 'Codigo de Barras invalido.'
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Codigo de Barras invalido.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Montar parametros saida
          pr_titulo1:= TO_NUMBER(SUBSTR(pr_codigo_barras,01,04)||
                                 SUBSTR(pr_codigo_barras,20,01)||
                                 SUBSTR(pr_codigo_barras,21,04)|| '0');
          pr_titulo2:= TO_NUMBER(SUBSTR(pr_codigo_barras,25,10)|| '0');
          pr_titulo3:= TO_NUMBER(SUBSTR(pr_codigo_barras,35,10)|| '0');
          pr_titulo4:= TO_NUMBER(SUBSTR(pr_codigo_barras,05,01));
          pr_titulo5:= TO_NUMBER(SUBSTR(pr_codigo_barras,06,14));

          /**- VERIFICA COM EDSON A VALIDACAO DE LINHA DIGITAVEL -*/
          FOR idx IN 1..3 LOOP

            --Determinar a parte que ser¿ validada
            CASE idx
              WHEN 1 THEN
                vr_de_valor_calc:= pr_titulo1;
                vr_flg_zeros:= TRUE;
              WHEN 2 THEN
                vr_de_valor_calc:= pr_titulo2;
                vr_flg_zeros:= FALSE;
              WHEN 3 THEN
                vr_de_valor_calc:= pr_titulo3;
                vr_flg_zeros:= FALSE;
            END CASE;
            --Calcular digito verificador

            /*  Calcula digito- Primeiro campo da linha digitavel  */
            CXON0000.pc_calc_digito_verif (pr_valor        => vr_de_valor_calc   --> Valor Calculado
                                          ,pr_valida_zeros => vr_flg_zeros       --> Validar Zeros
                                          ,pr_nro_digito   => vr_nro_digito      --> Digito Verificador
                                          ,pr_retorno      => vr_retorno);       --> Retorno digito correto

            --Determinar a parte que sera retornada
            CASE idx
              WHEN 1 THEN pr_titulo1:= TO_NUMBER(vr_de_valor_calc);
              WHEN 2 THEN pr_titulo2:= TO_NUMBER(vr_de_valor_calc);
              WHEN 3 THEN pr_titulo3:= TO_NUMBER(vr_de_valor_calc);
            END CASE;
          END LOOP; --For idx 1..3
        END IF;

        -- Verifica se o codigo de barras eh fraudulento
        OPEN cr_crapcbf(pr_codigo_barras);
        FETCH cr_crapcbf INTO rw_crapcbf;
        IF cr_crapcbf%FOUND THEN
          CLOSE cr_crapcbf;

          -- Pegar ultimo ip
          FOR rw_craplgm IN cr_craplgm(pr_cdcooper => pr_cooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_dttransa => trunc(SYSDATE)
                                      ,pr_dsorigem => 'INTERNET'
                                      ,pr_cdoperad => '996'
                                      ,pr_flgtrans => 1
                                      ,pr_dstransa => 'Efetuado login de acesso a conta on-line.') LOOP
            vr_nrdipatu := rw_craplgm.dsdadatu;
            exit;
          END LOOP;-- Loop craplgm

          -- monta o corpo do email
          vr_des_corpo := '<b>Atencao! Houve tentativa de pagamento de codigo de barras fraudulento.<br>'||
                          'IP: ' || vr_nrdipatu || '<br>' ||
                          'Conta: </b>'||gene0002.fn_mask_conta(pr_nrdconta)||'<br>'||
                          '<b>Cod. Barras: </b>'||pr_codigo_barras;
          -- Envio de e-mail informando que houve a tentativa
          gene0003.pc_solicita_email(pr_cdcooper => pr_cooper,
                                     pr_cdprogra => 'PAGA0001',
                                     pr_des_destino => 'prevencaodefraudes@ailos.coop.br',
                                     pr_des_assunto => 'Tentativa de pagamento cod. barras fraudulento',
                                     pr_des_corpo => vr_des_corpo,
                                     pr_des_anexo => NULL,
                                     pr_flg_enviar => 'S',
                                     pr_des_erro => vr_dscritic);

          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 0
                               ,pr_dsc_erro => 'Dados incompativeis. Pagamento nao realizado!'
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF nvl(vr_cdcritic,0)<> 0 OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_dscritic := 'Dados incompativeis. Pagamento nao realizado!';
            RAISE vr_exc_erro;
          END IF;

        END IF;
        CLOSE cr_crapcbf;

        /* inicializar */
        vr_retorno := TRUE;
        /* Calculo do Digito Verificador  - Titulo */
        vr_de_valor_calc:= pr_codigo_barras;
        --Executar rotina calculo digito titulo
        CXON0000.pc_calc_digito_titulo (pr_valor   => vr_de_valor_calc --> Valor Calculado
                                       ,pr_retorno => vr_retorno);     --> Retorno digito correto
        --Se retornou erro
        IF NOT vr_retorno THEN
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 8
                               ,pr_dsc_erro => NULL
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 8;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF; --pr_iptu = FALSE

      IF pr_iptu = 1 THEN /* Processa IPTU */
        IF (to_number(SUBSTR(pr_codigo_barras,16,4)) = 557) AND /* Prefeitura*/
           (to_number(SUBSTR(pr_codigo_barras,02,1)) = 1)  THEN /* Cod.Segmto*/
          IF (to_number(SUBSTR(pr_codigo_barras,28,3)) = 511)  THEN
            --Verificar codigo cadastrado
            IF pr_cadastro <> pr_cadastro_conf THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 841
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 841;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
            --Numero cadastro igual zero
            IF pr_cadastro = 0 THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 375
                                   ,pr_dsc_erro => NULL
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 375;
                vr_dscritic:= NULL;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;

            --Colocar o cadastro no codigo barras
            pr_codigo_barras:= SubStr(pr_codigo_barras,1,30)||
                               gene0002.fn_mask(pr_cadastro,'9999999999')||
                               SubStr(pr_codigo_barras,41);
          END IF;
          --Selecionar informacoes titulos
          OPEN cr_craptit (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdagenci => pr_cod_agencia
                          ,pr_cdbccxlt => 11
                          ,pr_nrdolote => vr_nro_lote
                          ,pr_dscodbar => pr_codigo_barras);
          --Posicionar no proximo registro
          FETCH cr_craptit INTO rw_craptit;
          --Se nao encontrar
          IF cr_craptit%FOUND THEN
            --Fechar Cursor
            CLOSE cr_craptit;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 92
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 92;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_craptit;

          --Selecionar informacoes titulos
          OPEN cr_craptit2 (pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                           ,pr_dscodbar => pr_codigo_barras);
          --Posicionar no proximo registro
          FETCH cr_craptit2 INTO rw_craptit;
          --Se nao encontrar
          IF cr_craptit2%FOUND THEN
            --Fechar Cursor
            CLOSE cr_craptit2;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 456
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 456;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_craptit2;
          --Verificar se o titulo existe
          --Nao retirar o upper para uso correto do indice
          BEGIN
            SELECT /*+ INDEX (craptit craptit##craptit3) */ Count(1)
            INTO vr_contador
            FROM craptit
            WHERE craptit.cdcooper = rw_crapcop.cdcooper
            AND   upper(craptit.dscodbar) = upper(pr_codigo_barras);
          EXCEPTION
            WHEN OTHERS THEN
              vr_contador:= 0;
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao selecionar titulo.';
              RAISE vr_exc_erro;
          END;
          --Se Encontrou titulo
          IF vr_contador > 0 THEN
            pr_outra_data:= 1;
          ELSE
            pr_outra_data:= 0;
          END IF;
          --Retonar Valor fatura
          pr_vlfatura:= to_number(SUBSTR(pr_codigo_barras,5,11)) / 100;
        ELSE
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 100
                               ,pr_dsc_erro => NULL
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 100;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      ELSE  /* Titulo */
          --Selecionar informacoes titulos
          OPEN cr_craptit3 (pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                           ,pr_cdagenci => pr_cod_agencia
                           ,pr_cdbccxlt => 11
                           ,pr_nrdolote => vr_nro_lote
                           ,pr_dscodbar => pr_codigo_barras);
          --Posicionar no proximo registro
          FETCH cr_craptit3 INTO rw_craptit;
          --Se nao encontrar
          IF cr_craptit3%FOUND THEN
            --Fechar Cursor
            CLOSE cr_craptit3;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 92
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 92;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_craptit3;

          --Selecionar informacoes titulos
          OPEN cr_craptit2 (pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                           ,pr_dscodbar => pr_codigo_barras);
          --Posicionar no proximo registro
          FETCH cr_craptit2 INTO rw_craptit;
          --Se nao encontrar
          IF cr_craptit2%FOUND THEN
            --Fechar Cursor
            CLOSE cr_craptit2;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 456
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 456;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_craptit2;

          BEGIN
            SELECT /*+ INDEX (craptit craptit##craptit3) */ Count(1)
            INTO vr_contador
            FROM craptit
            WHERE craptit.cdcooper = rw_crapcop.cdcooper
            AND   upper(craptit.dscodbar) = upper(pr_codigo_barras);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao selecionar titulo.';
              RAISE vr_exc_erro;
          END;
          --Se Encontrou TRUE, senao FALSE
          IF vr_contador > 0 THEN
            pr_outra_data := 1;
          ELSE
            pr_outra_data := 0;
          END IF;

          /*  Verifica a hora somente para a arrecadacao caixa  */
          IF GENE0002.fn_busca_time >= vr_tab_hrlimite AND pr_cod_agencia NOT IN (90,91) THEN
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 676
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 676;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;

          /* Valida transmissao do arquivo de titulos somente se  */
          /* nao for um agendamento de pagamento                 */
          IF pr_dt_agendamento IS NULL AND vr_tab_intransm > 0 THEN
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 677
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);

            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 677;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;

      --Nao for IPTU
      IF pr_iptu = 0 THEN
        -- Somente validar se não for NPC
        IF TRIM(pr_cdctrlcs) IS NULL AND pr_titulo5 <> 0  THEN
          vr_de_campo:= TO_NUMBER(SUBSTR(gene0002.fn_mask(pr_titulo5,'99999999999999'),1,4));
          vr_de_p_titulo5:= TO_NUMBER(SUBSTR(gene0002.fn_mask(pr_titulo5,'99999999999999'),5,10));
          --Retornar valor fatura
          pr_vlfatura:= vr_de_p_titulo5 / 100;
          --Data do Vencimento
          --vr_dt_dtvencto:= To_Date('07/10/1997','DD/MM/YYYY') + vr_de_campo;
          --Se valor diferente zero

          IF vr_de_campo <> 0 THEN

            pc_calcula_data_vencimento (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_de_campo => vr_de_campo
                                       ,pr_dtvencto => vr_dt_dtvencto
                                       ,pr_cdcritic => vr_vcto_cdcritic          -- Codigo da Critica
                                       ,pr_dscritic => vr_vcto_dscritic);        -- Descricao da Critica

            --Se ocorreu erro
            IF vr_vcto_cdcritic IS NOT NULL OR vr_vcto_dscritic IS NOT NULL THEN
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => vr_vcto_cdcritic
                                     ,pr_dsc_erro => vr_vcto_dscritic
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= vr_vcto_cdcritic;
                  vr_dscritic:= vr_vcto_dscritic;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;

            END IF;

            --Limpar tabela erro
            vr_tab_erro.DELETE;
            --Verificar vencimento do titulo
            pc_verifica_vencimento_titulo (pr_cod_cooper      => rw_crapcop.cdcooper  --Codigo Cooperativa
                                          ,pr_cod_agencia     => pr_cod_agencia       --Codigo da Agencia
                                          ,pr_dt_agendamento  => pr_dt_agendamento    --Data Agendamento
                                          ,pr_dt_vencto       => vr_dt_dtvencto       --Data Vencimento
                                          ,pr_critica_data    => vr_critica_data      --Critica na validacao
                                          ,pr_cdcritic        => vr_cdcritic          --Codigo da Critica
                                          ,pr_dscritic        => vr_dscritic           --Descricao da Critica
                                          ,pr_tab_erro        => vr_tab_erro);        --Tabela retorno erro
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              IF vr_tab_erro.Count > 0 THEN
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 0
                                     ,pr_dsc_erro => vr_tab_erro(vr_tab_erro.FIRST).dscritic
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 0;
                  vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Nao foi possivel realizar o pagamento.';
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 0
                                     ,pr_dsc_erro => vr_tab_erro(vr_tab_erro.FIRST).dscritic
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
              END IF;
            END IF;
          END IF;
        END IF; --pr_titulo5 <> 0

        --Selecionar Banco
        OPEN cr_crapban (pr_cdbccxlt => To_Number(SUBSTR(gene0002.fn_mask(pr_titulo1,'99999,99999'),1,3)));
        --Posicionar no proximo registro
        FETCH cr_crapban INTO rw_crapban;
        --Se nao encontrar
        IF cr_crapban%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapban;
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 57
                               ,pr_dsc_erro => NULL
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 57;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapban;

		/* Bancos que não podemos mais aceitar o recebimento de titulos. */
		vr_cdbancos := gene0001.fn_param_sistema('CRED',0,'BANCOS_BLQ_TIT');

		/* Não permitir a inclusão de titulos para os bancos 012, 231, 353, 356, 409 e 479 */
		IF INSTR(','||vr_cdbancos||',',','||rw_crapban.cdbccxlt||',') > 0 THEN
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 57
                               ,pr_dsc_erro => NULL
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 57;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;

        --Selecionar Agencias
        OPEN cr_crapagb (pr_cddbanco => rw_crapban.cdbccxlt);
        --Posicionar no primeiro registro
        FETCH cr_crapagb INTO rw_crapagb;
        --Se nao encontrou
        IF cr_crapagb%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapagb;
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 956
                               ,pr_dsc_erro => NULL
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 956;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapagb;
      END IF;

      --Identificar titulo Cooperativa
      pc_identifica_titulo_coop2 (pr_cooper      => pr_cooper        --Codigo Cooperativa
                                ,pr_nro_conta   => pr_nrdconta      --Numero Conta
                                ,pr_idseqttl    => pr_idseqttl      --Sequencial do Titular
                                ,pr_cod_agencia => pr_cod_agencia   --Codigo da Agencia
                                ,pr_nro_caixa   => pr_nro_caixa     --Numero Caixa
                                ,pr_codbarras   => pr_codigo_barras --Codigo Barras
                                ,pr_flgcritica  => TRUE             --Flag Critica
                                ,pr_nrdconta    => pr_nrdconta_cob  --Numero da Conta OUT
                                ,pr_insittit    => pr_insittit      --Situacao Titulo
                                ,pr_intitcop    => pr_intitcop      --Indicador titulo cooperativa
                                ,pr_convenio    => pr_convenio      --Numero Convenio
                                ,pr_bloqueto    => pr_bloqueto      --Numero Boleto
                                ,pr_contaconve  => pr_contaconve    --Conta do Convenio
                                ,pr_cdcritic    => vr_cdcritic      --Codigo do erro
                                ,pr_dscritic    => vr_dscritic);    --Descricao erro
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /* Nao eh permitido pagto de VR Boletos pelo TAA */
      IF  pr_intitcop = 0 AND pr_cod_agencia = 91 AND pr_iptu = 0 AND
          pr_valor_informado >= 250000 AND Trunc(SYSDATE) >= To_Date('28/06/2013','DD/MM/YYYY') THEN
        --Nao permite pagamento TAA
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => 'Valor nao permitido para pagamento em TAA.'
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Valor nao permitido para pagamento em TAA.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      /* Nao eh permitido agendamento de VR Boletos */
      IF pr_iptu = 0 AND pr_valor_informado >= 250000 AND
         Trunc(SYSDATE) >= To_Date('28/06/2013','DD/MM/YYYY') AND pr_dt_agendamento IS NOT NULL THEN
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => 'Valor nao permitido para agendamento.'
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Valor nao permitido para agendamento.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      /* Pagto de VR Boleto pelo InternetBanking, apenas pelo DDA */
      IF  pr_intitcop = 0 AND pr_cod_agencia = 90 AND pr_iptu = 0 AND
          pr_valor_informado >= 250000 AND Trunc(SYSDATE) >= To_Date('28/06/2013','DD/MM/YYYY') AND
          vr_idtitdda = 0 THEN
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => 'Valor permitido apenas pelo link de pagamentos DDA.'
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Valor permitido apenas pelo link de pagamentos DDA.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      /* verificar dia util, horario e limite de pagto VR Boleto */
      IF  pr_iptu = 0 AND pr_valor_informado >= 250000 AND
          Trunc(SYSDATE) >= To_Date('28/06/2013','DD/MM/YYYY') THEN
        /* limite de pagto VR Boleto */
        --Selecionar informacoes associado
        OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        --Posicionar no proximo registro
        FETCH cr_crapass INTO rw_crapass;
        --Se nao encontrar
        IF cr_crapass%FOUND AND
           -- tratamento de valor deve ocorrer apenas para Internet Bank e o TAA
           -- Caixa on-line não é necessario validar
           pr_cod_agencia IN (90,91) THEN

          --Buscar limite associado
          vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'GENERI'
                                                  ,pr_cdempres => 0
                                                  ,pr_cdacesso => 'LIMINTERNT'
                                                  ,pr_tpregist => rw_crapass.inpessoa);
          --Se encontrou
          IF vr_dstextab IS NOT NULL THEN
            --Se ultrapassou o limite
            IF (rw_crapass.inpessoa = 1 AND
                pr_valor_informado > GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(15,vr_dstextab,';'))) OR
               (rw_crapass.inpessoa = 2 AND
                pr_valor_informado > GENE0002.fn_char_para_number(GENE0002.fn_busca_entrada(16,vr_dstextab,';'))) THEN
              --Fechar Cursor
              CLOSE cr_crapass;
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => 'Pagamento de VR Boleto superior ao limite operacional.'
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Pagamento de VR Boleto superior ao limite operacional.';
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapass;

        /* pagto de VR Boletos apenas para dias uteis */
        vr_dt_feriado:= GENE0005.fn_valida_dia_util(pr_cdcooper  => pr_cooper
                                                   ,pr_dtmvtolt  => SYSDATE
                                                   ,pr_tipo      => 'P'
                                                   ,pr_feriado   => TRUE
                                                   ,pr_excultdia => TRUE);

        --Se a data retornada for diferente eh feriado
        IF Trunc(vr_dt_feriado) <> Trunc(SYSDATE) THEN
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 0
                               ,pr_dsc_erro => 'Pagamento de VR Boletos permitido apenas em dias uteis.'
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Pagamento de VR Boletos permitido apenas em dias uteis.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;

        --Buscar Horario Boleto
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRVRBOLETO'
                                                ,pr_tpregist => NULL);
        --Se nao encontrou
        IF vr_dstextab IS NULL THEN
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 0
                               ,pr_dsc_erro => 'Parametro de pagto de VR Boletos nao encontrado.'
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Parametro de pagto de VR Boletos nao encontrado.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        ELSE
          IF UPPER(GENE0002.fn_busca_entrada(1,vr_dstextab,';')) = 'NO' THEN
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => 'Pagamento de VR Boletos bloqueado.'
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Pagamento de VR Boletos bloqueado.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Hora Inicial VRB
          vr_hrvrbini:= TO_NUMBER(GENE0002.fn_busca_entrada(2,vr_dstextab,';'));
          --Hora Final VRB
          vr_hrvrbfim:= TO_NUMBER(GENE0002.fn_busca_entrada(3,vr_dstextab,';'));
          IF NOT GENE0002.fn_busca_time BETWEEN vr_hrvrbini AND vr_hrvrbfim THEN
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => 'Horario excedido para pagto de VR Boletos.'
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Horario excedido para pagto de VR Boletos.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END IF;
      END IF;

      /* verificar se VR Boleto pertence a outra cooperativa associada */
      IF pr_iptu = 0 AND pr_intitcop = 0 AND pr_valor_informado >= 250000 AND
         Trunc(SYSDATE) >= To_Date('28/06/2013','DD/MM/YYYY') AND SUBSTR(pr_codigo_barras,1,3) = '085' THEN
        --Verificar se eh numerico  (Oracle 10g+)
        IF REGEXP_INSTR(SubStr(pr_codigo_barras,20,4), '[^[:digit:]]') = 0 THEN
          /* Verifica se conv boleto ¿ de cobranca 085 */
          --Selecionar informacoes convenio cobranca
          OPEN cr_crapcco (pr_codigo_barras => pr_codigo_barras
                          ,pr_cddbanco      => 085);
          --Posicionar no proximo registro
          FETCH cr_crapcco INTO rw_crapcco;
          --Se encontrar
          IF cr_crapcco%FOUND THEN
            --Fechar Cursor
            CLOSE cr_crapcco;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => 'VR Boleto deve ser pago apenas na cooperativa do beneficiario.'
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'VR Boleto deve ser pago apenas na cooperativa do beneficiario.';
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapcco;
        END IF;
      END IF;

      vr_cdctrlcs := TRIM(pr_cdctrlcs);
      pc_busca_cdctrlcs(pr_dscodbar => pr_codigo_barras
                       ,pr_cdctrlcs => vr_cdctrlcs);
      
      --> Caso possua numero de consulta da Nova Plataforma de cobrança
      --> Deve efetuar as validações
      IF TRIM(vr_cdctrlcs) IS NOT NULL THEN

        --> Validação do pagamento do boleto na Nova plataforma de cobrança
        NPCB0001.pc_valid_pagamento_npc
                          ( pr_cdcooper  => rw_crapcop.cdcooper --> Codigo da cooperativa
                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data de movimento
                           ,pr_cdctrlcs  => vr_cdctrlcs         --> Numero de controle da consulta no NPC
                           ,pr_dtagenda  => pr_dt_agendamento   --> Data agendada para pagmento do boleto
                           ,pr_vldpagto  => pr_valor_informado  --> Valor a ser pago
                           ,pr_vltitulo  => pr_vlfatura         --> Valor do titulo
                           ,pr_idvlrmax  => 0                   --> *** Nao validar valor maximo ***
                           ,pr_nridenti  => vr_nridetit         --> Retornar numero de identificacao do titulo no npc
                           ,pr_tpdbaixa  => vr_tpdbaixa         --> Retornar tipo de baixa
                           ,pr_flcontig  => vr_flcontig         --> Retornar inf que a CIP esta em modo de contigencia
                           ,pr_cdcritic  => vr_cdcritic         --> Codigo da critico
                           ,pr_dscritic  => vr_dscritic );      --> Descrição da critica

        --> Verificar se retornou critica
        IF nvl(vr_cdcritic,0) <> 0 OR
           TRIM(vr_dscritic) IS NOT NULL THEN
          --> Abortar programa
          RAISE vr_exc_erro;
        END IF;

      END IF;

      /********************************************************/
      /***********FAZER CALCULO DO VALOR DO TITULO*************/
      IF pr_intitcop = 1 THEN /* Se for titulo da cooperativa */
        /* Verifica se conv boleto eh de cobranca 085 */
        --Selecionar informacoes convenio cobranca
        OPEN cr_crapcco2 (pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_nrconven => to_number(pr_convenio)
                         ,pr_cddbanco => rw_crapcop.cdbcoctl);
        --Posicionar no proximo registro
        FETCH cr_crapcco2 INTO rw_crapcco;
        --Se encontrar
        IF cr_crapcco2%FOUND THEN
          -- Se for cobranca registrada, calcular o valor do titulo conforme instru¿¿o

          --Selecionar informacoes cobranca
          OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_nrcnvcob => to_number(pr_convenio)
                          ,pr_nrdconta => pr_nrdconta_cob
                          ,pr_nrdocmto => pr_bloqueto
                          ,pr_nrdctabb => pr_contaconve);
          --Posicionar no proximo registro
          FETCH cr_crapcob INTO rw_crapcob;
          --Se nao encontrar
          IF cr_crapcob%NOTFOUND THEN
            --Fechar Cursores
            CLOSE cr_crapcob;
            CLOSE cr_crapcco2;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 11
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 11;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapcob;

          /* Parametros de saida da cobranca registrada */
          pr_vlrjuros:= 0;
          pr_vlrmulta:= 0;
          pr_vldescto:= 0;
          pr_vlabatim:= 0;
          pr_vloutdeb:= 0;
          pr_vloutcre:= 0;
          pr_vlfatura:= rw_crapcob.vltitulo;

          /* trata o desconto */
          /* se concede apos o vencimento */
          IF rw_crapcob.cdmensag = 2 THEN
            --Valor Desconto
            pr_vldescto:= rw_crapcob.vldescto;
            --Diminuir valor desconto do Valor Fatura
            pr_vlfatura:= Nvl(pr_vlfatura,0) - pr_vldescto;
          END IF;
          /* utilizar o abatimento antes do calculo de juros/multa */
          IF rw_crapcob.vlabatim > 0 THEN
            --Valor Abatimento
            pr_vlabatim:= rw_crapcob.vlabatim;
            --Diminuir valor abatimento do Valor Fatura
            pr_vlfatura:= Nvl(pr_vlfatura,0) - pr_vlabatim;
          END IF;

          --Limpar tabela erro
          vr_tab_erro.DELETE;
          --Verificar vencimento do titulo
          pc_verifica_vencimento_titulo (pr_cod_cooper      => rw_crapcop.cdcooper  --Codigo Cooperativa
                                        ,pr_cod_agencia     => pr_cod_agencia       --Codigo da Agencia
                                        ,pr_dt_agendamento  => pr_dt_agendamento    --Data Agendamento
                                        ,pr_dt_vencto       => nvl(rw_crapcob.dtvencto,vr_dt_dtvencto)  --Data Vencimento
                                        ,pr_critica_data    => vr_critica_data      --Critica na validacao
                                        ,pr_cdcritic        => vr_cdcritic          --Codigo da Critica
                                        ,pr_dscritic        => vr_dscritic           --Descricao da Critica
                                        ,pr_tab_erro        => vr_tab_erro);        --Tabela retorno erro
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            IF vr_tab_erro.Count > 0 THEN
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => vr_tab_erro(vr_tab_erro.FIRST).dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Nao foi possivel realizar o pagamento.';
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => vr_tab_erro(vr_tab_erro.FIRST).dscritic
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
            END IF;
          END IF;

          /* verifica se o titulo esta vencido */
          IF vr_critica_data THEN
            /* nao eh permitido receber boleto de emprestimo ou de cobtit vencido */
            IF rw_crapcco.dsorgarq IN ('EMPRESTIMO','DESCONTO DE TITULO') THEN
              CASE WHEN rw_crapcco.dsorgarq = 'EMPRESTIMO' THEN
              vr_des_erro:= 'Cob. Emprestimo. - Boleto Vencido.';
                WHEN rw_crapcco.dsorgarq = 'DESCONTO DE TITULO' THEN
                  vr_des_erro:= 'Cob. Desc. de Titulo - Boleto Vencido.';
              END CASE;
              pr_msgalert := vr_des_erro;
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => vr_des_erro
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= vr_des_erro;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;

           CXON0014.pc_calcula_vlr_titulo_vencido(pr_vltitulo      => pr_vlfatura
                                                 ,pr_tpdmulta      => rw_crapcob.tpdmulta
                                                 ,pr_vlrmulta      => rw_crapcob.vlrmulta
                                                 ,pr_tpjurmor      => rw_crapcob.tpjurmor
                                                 ,pr_vljurdia      => rw_crapcob.vljurdia
                                                 ,pr_qtdiavenc     => (rw_crapdat.dtmvtocd - rw_crapcob.dtvencto)
                                                 ,pr_vlfatura      => pr_vlfatura
                                                 ,pr_vlrmulta_calc => pr_vlrmulta
                                                 ,pr_vlrjuros_calc => pr_vlrjuros
                                                 ,pr_dscritic      => vr_dscritic );
          ELSE
            /* se concede apos vencto, ja calculou */
            IF rw_crapcob.cdmensag <> 2  THEN
              --Valor Desconto
              pr_vldescto:= rw_crapcob.vldescto;
              --Retirar o desconto da fatura
              pr_vlfatura:= Nvl(pr_vlfatura,0) - pr_vldescto;
            END IF;
          END IF;

          /* Para cobranca registrada nao permite pagar valor menor que o valor do docto
             calculando desconto juros abatimento e multa */
          IF ROUND(pr_valor_informado,2) < ROUND(pr_vlfatura,2) AND
             pr_cod_operador <> 'DDA' AND
             NOT (nvl(rw_crapcob.dsinform,' ') LIKE 'LIQAPOSBX%') THEN

            /*Caso encontre o pagadorvip permite pagar valor menor que o valor do documento*/
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                      ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'PAGADORVIP'
                                                     ,pr_tpregist => pr_nrdconta);

            IF TRIM(vr_dstextab) IS NULL THEN

              --> Validar valor no periodo de convivencia
              vr_invalcon := cecred.npcb0002.fn_valid_val_conv ( pr_cdcooper => rw_crapcop.cdcooper,
                                                                 pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                                                 pr_flgregis => rw_crapcco.flgregis,
                                                                 pr_flgpgdiv => rw_crapcob.flgpgdiv,
                                                                 pr_vlinform => pr_valor_informado,
                                                                 pr_vltitulo => pr_vlfatura);

              --> Se retornou 1-permite ou 0-nao permite, deve validar pela rotina
              --> caso retornar 3-nao validado, deve fazer as demais validações
              IF vr_invalcon IN (1,0) THEN
                -- se retornou 0-nao permite deve gerar cririca
                IF vr_invalcon = 0 THEN
                  --Montar mensagem de erro
                  vr_des_erro:= 'Cob. Reg. - Valor informado '||
                                to_char(pr_valor_informado, 'fm999g999g990d00')||
                                ' menor que valor doc. '||
                                to_char(pr_vlfatura,'fm999g999g990D00');
                  pr_msgalert := vr_des_erro;
                  --Criar erro
                  CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                       ,pr_cdagenci => pr_cod_agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa
                                       ,pr_cod_erro => 0
                                       ,pr_dsc_erro => vr_des_erro
                                       ,pr_flg_erro => TRUE
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
                  --Se ocorreu erro
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                  ELSE
                    vr_cdcritic:= 0;
                    vr_dscritic:= vr_des_erro;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                  END IF;

                END IF;
              -- nao autoriza pagamento divergente
              ELSIF nvl(rw_crapcob.inpagdiv,0) = 0 THEN
              --Montar mensagem de erro
              vr_des_erro:= 'Cob. Reg. - Valor informado '||
                            to_char(pr_valor_informado, 'fm999g999g990d00')||
                            ' menor que valor doc. '||
                            to_char(pr_vlfatura,'fm999g999g990D00');
              pr_msgalert := vr_des_erro;
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => 0
                                   ,pr_dsc_erro => vr_des_erro
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              --Se ocorreu erro
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= vr_des_erro;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;

              -- autoriza pagar com valor minimo
              ELSIF nvl(rw_crapcob.inpagdiv,0) = 1 THEN

                IF ROUND(pr_valor_informado,2) < nvl(rw_crapcob.vlminimo,0) THEN

                  --Montar mensagem de erro
                  vr_des_erro:= 'Cob. Reg. - Valor informado '||
                                to_char(pr_valor_informado, 'fm999g999g990d00')||
                                ' menor que o valor minimo do doc. '||
                                to_char(rw_crapcob.vlminimo,'fm999g999g990D00');
                  pr_msgalert := vr_des_erro;
                  --Criar erro
                  CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                       ,pr_cdagenci => pr_cod_agencia
                                       ,pr_nrdcaixa => vr_nrdcaixa
                                       ,pr_cod_erro => 0
                                       ,pr_dsc_erro => vr_des_erro
                                       ,pr_flg_erro => TRUE
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
                  --Se ocorreu erro
                  IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                  ELSE
                    vr_cdcritic:= 0;
                    vr_dscritic:= vr_des_erro;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
            END IF;

                END IF;

              -- autoriza pagar com qualquer valor
              ELSIF nvl(rw_crapcob.inpagdiv,0) = 2 THEN
                 NULL;
              END IF;

            END IF;
          -- se o valor informado for maior que o vlr do boleto, criticar - Projeto 210
          ELSIF ROUND(pr_valor_informado,2) > ROUND(pr_vlfatura,2) AND
               rw_crapcco.dsorgarq IN ('EMPRESTIMO','DESCONTO DE TITULO') THEN
            IF vr_critica_data THEN
              CASE WHEN rw_crapcco.dsorgarq = 'EMPRESTIMO' THEN
                  vr_des_erro:= 'Cob. Emprestimo. - Valor informado ';
                WHEN rw_crapcco.dsorgarq = 'DESCONTO DE TITULO' THEN
                  vr_des_erro:= 'Cob. Desc. de Titulo - Valor informado ';
              END CASE;
              vr_des_erro:= vr_des_erro ||
                            to_char(pr_valor_informado, 'fm999g999g990d00')||
                            ' maior que valor doc. '||
                            to_char(pr_vlfatura,'fm999g999g990D00');
            ELSE
              vr_des_erro := 'Erro';
            END IF;
            pr_msgalert := vr_des_erro;
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 0
                                 ,pr_dsc_erro => vr_des_erro
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= vr_des_erro;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
          END IF;

          /* Mensagem informando a composi¿¿o do valor docto */
          IF pr_vlrjuros <> 0  OR pr_vlrmulta <> 0  OR pr_vldescto <> 0  OR
             pr_vlabatim <> 0  OR pr_vloutdeb <> 0  OR pr_vloutcre <> 0  OR
             pr_vlfatura <> pr_valor_informado THEN
            --Mensagem Alerta
            pr_msgalert:= 'Cob. Reg. - Valor Doc inclui '||'Abat./Desc./Juros/Multas.';
          END IF;
          /* Parametro para informar que titulo eh de cobranca registrada */
          pr_cobregis:= 1;
        END IF;
        --Fechar Cursor
        IF cr_crapcco2%ISOPEN THEN
          CLOSE cr_crapcco2;
        END IF;
      END IF;
      /********* FIM FAZER CALCULO DO VALOR DO TITULO *********/
      /********************************************************/
      IF pr_vlfatura <> pr_valor_informado AND pr_vlfatura <> 0 THEN
        --Retonar indicacao outro valor
        pr_outro_valor:= 1;
      END IF;

      /* se p-cod-operador <> "DDA" entao critica titulo vencido - Rafael */
      /* situacao temporaria ate o projeto do TED estar ok */
      IF vr_critica_data AND pr_cod_operador <> 'DDA' AND TRIM(vr_cdctrlcs) IS NULL THEN
        --Mensagem de erro
        vr_des_erro:= ' = '||To_Char(vr_dt_dtvencto,'DD/MM/YYYY');
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 13
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          IF pr_intitcop = 0 OR pr_dt_agendamento IS NOT NULL THEN
            --Levantar Excecao
            pr_cdcritic := 13;
            vr_dscritic := vr_des_erro;
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;

         -- Verificar se erro ja foi gravado
         rw_craperr := NULL;
         OPEN cr_craperr (pr_cdcritic => pr_cdcritic,
                          pr_dscritic => pr_dscritic );
         FETCH cr_craperr INTO rw_craperr;
         CLOSE cr_craperr;

         IF nvl(rw_craperr.flexiste,0) <> 1 THEN
         --Criar registro de erro -- para garantir que todos os erros
         -- estejam na tabela
         CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

          END IF;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0014.pc_retorna_vlr_titulo_iptu. '||SQLERRM;

         --Criar registro de erro -- para garantir que todos os erros
         -- estejam na tabela
         CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);


    END;
  END pc_retorna_vlr_titulo_iptu;

  /* Calcular Digito verificador Modulo 11 */
  PROCEDURE pc_verifica_digito (pr_nrcalcul IN VARCHAR2       --Numero a ser calculado
		                       ,pr_poslimit IN INTEGER        --Utilizado para validação de dígito adicional de DAS
                               ,pr_nrdigito OUT INTEGER) IS --Digito verificador
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_digito             Antigo: dbo/b1crap14.p/verifica_digito
  --  Sistema  : Calcular Digito verificador Modulo 11
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Calcular Digito verificador Modulo 11

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_peso    INTEGER:= 2;
      vr_calculo INTEGER:= 0;
      vr_resto   INTEGER:= 0;
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Percorrer string
      FOR idx IN REVERSE 1..Length(pr_nrcalcul) LOOP
        vr_calculo:= vr_calculo + (to_number(SubStr(pr_nrcalcul,idx,1)) * vr_peso);
        --Incrementa peso
        vr_peso:= vr_peso + 1;
        --Se Passou 9
        IF vr_peso > 9 THEN

			-- Para validação de dígito adicional de DAS
			IF pr_poslimit <> 0 THEN
				 IF pr_poslimit <> 38 THEN
          vr_peso:= 2;
        END IF;
			ELSE
				 vr_peso:= 2;
			END IF;

        END IF;
      END LOOP;
      --Resto
      vr_resto:= Mod(vr_calculo,11);
      IF vr_resto > 9 THEN
        pr_nrdigito:= 1;
      ELSIF vr_resto IN (0,1) THEN
        pr_nrdigito:= 0;
      ELSE
        pr_nrdigito:= 11 - vr_resto;
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         NULL;
       WHEN OTHERS THEN
         NULL;
    END;
  END pc_verifica_digito;
  
  
  /* Calcular Digito adicional */
  PROCEDURE pc_calcula_dv_adicional (pr_cdbarras IN VARCHAR2       --Codigo barras
                                    ,pr_poslimit IN INTEGER        --Utilizado para validação de dígito adicional de DAS
                                    ,pr_nrdigito IN INTEGER        --Numero a ser calculado
                                    ,pr_flagdvok OUT BOOLEAN) IS   --Digito correto sim/nao
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calcula_dv_adicional             Antigo: dbo/b1crap14.p/calcula_dv_adicional
  --  Sistema  : Calcular Digito adicional
  --  Sigla    : CXON
  --  Autor    : Adriano - Ailos
  --  Data     : Fevereiro/2019.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Calcular Digito adicional

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_digito    INTEGER:= 0;
      vr_peso      INTEGER:= 2;
      vr_calculo   INTEGER:= 0;
      vr_resto     INTEGER:= 0;
      vr_strnume   VARCHAR2(4000);
      
      -- Busca parâmetro que indica se as validações devem ser feitas ou não
      vr_ligaValidacao INTEGER := GENE0001.fn_param_sistema('CRED',0,'VALIDACAO_DARF_DAS');
      
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      
    BEGIN
      /*
         Esse parametro foi criado para permitir ligar/desligar essa validação a 
         qualquer momento.       */
      IF vr_ligaValidacao = 0 THEN
      
        pr_flagdvok := TRUE;
        RETURN;  
        
      END IF;
      
      vr_strnume := substr(pr_cdbarras,1,3) || 
                    substr(pr_cdbarras,5,pr_poslimit);
      
      --Percorrer string
      FOR idx IN REVERSE 1..Length(vr_strnume) LOOP
        vr_calculo:= vr_calculo + (to_number(SubStr(vr_strnume,idx,1)) * vr_peso);
                
        /* Para o calculo do segundo dv adicional (par_poslimit = 38)
           deve-se utilizar peso de 2 a 42. */
        IF vr_peso = 9 AND pr_poslimit <> 38 THEN
          
          vr_peso:= 2;
          
        ELSE
          
          --Incrementa peso
          vr_peso:= vr_peso + 1;
        
        END IF;
        
      END LOOP;
      
      --Resto
      vr_resto:= Mod(vr_calculo,11);
      
      IF vr_resto IN (0,1) THEN
        vr_digito := 0; 
      ELSIF vr_resto = 10 THEN
        vr_digito := 1;   
      END IF;
      
      IF vr_resto <> 0  AND 
         vr_resto <> 1  AND
         vr_resto <> 10 THEN
        vr_digito:= 11 - vr_resto;
      
      END IF;
      
      IF vr_digito = pr_nrdigito THEN
        pr_flagdvok := TRUE;
      ELSE
        pr_flagdvok := FALSE;
      END IF;      
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         NULL;
       WHEN OTHERS THEN
         NULL;
    END;
  END pc_calcula_dv_adicional;
  
  /* Procedures para calculo de DV do numero da DAS e DV's adicionais da DAS  */
  PROCEDURE pc_calcula_dv_numero_das (pr_numerdas IN VARCHAR2       --Codigo barras
                                     ,pr_dvnrodas IN INTEGER        --Utilizado para validação de dígito adicional de DAS
                                     ,pr_flagdvok OUT BOOLEAN) IS   --Digito correto sim/nao
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calcula_dv_numero_das             Antigo: dbo/b1crap14.p/calcula_dv_numero_das
  --  Sistema  : Calcular Digito DAS
  --  Sigla    : CXON
  --  Autor    : Adriano - Ailos
  --  Data     : Fevereiro/2019.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Calcular Digito DAS

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_digito    INTEGER:= 0;
      vr_peso      INTEGER:= 2;
      vr_calculo   INTEGER:= 0;
      vr_resto     INTEGER:= 0;
      
      -- Busca parâmetro que indica se as validações devem ser feitas ou não
      vr_ligaValidacao INTEGER := GENE0001.fn_param_sistema('CRED',0,'VALIDACAO_DARF_DAS');
            
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      /*
         Esse parametro foi criado para permitir ligar/desligar essa validação a 
         qualquer momento.       */
      IF vr_ligaValidacao = 0 THEN
      
        pr_flagdvok := TRUE;
        RETURN;  
        
      END IF;
      
      --Percorrer string
      FOR idx IN REVERSE 1..Length(pr_numerdas) LOOP
        vr_calculo:= vr_calculo + (to_number(SubStr(pr_numerdas,idx,1)) * vr_peso);
                
        IF vr_peso = 9 THEN
          
          vr_peso:= 2;
          
        ELSE
          
          --Incrementa peso
          vr_peso:= vr_peso + 1;
        
        END IF;
        
      END LOOP;
      
      --Resto
      vr_resto:= Mod(vr_calculo,11);
      
      IF vr_resto IN (0,1) THEN
        vr_digito := 0; 
      ELSIF vr_resto = 10 THEN
        vr_digito := 1;   
      END IF;
      
      IF vr_resto <> 0  AND 
         vr_resto <> 1  AND
         vr_resto <> 10 THEN
        vr_digito:= 11 - vr_resto;
      
      END IF;
      
      IF vr_digito = pr_dvnrodas THEN
        pr_flagdvok := TRUE;
      ELSE
        pr_flagdvok := FALSE;
      END IF;      
      
    EXCEPTION
       WHEN vr_exc_erro THEN
         NULL;
       WHEN OTHERS THEN
         NULL;
    END;
  END pc_calcula_dv_numero_das;


  /* Procedure para validar o codigo de barras */
  PROCEDURE pc_valida_codigo_barras (pr_cooper         IN VARCHAR2                   --Codigo Cooperativa
                                    ,pr_nrdconta       IN crapttl.nrdconta%TYPE      --Numero da Conta
                                    ,pr_idseqttl       IN crapttl.idseqttl%TYPE      --Sequencial Titular
                                    ,pr_cod_operador   IN VARCHAR2                   --Codigo Operador
                                    ,pr_cod_agencia    IN INTEGER                    --Codigo Agencia
                                    ,pr_nro_caixa      IN INTEGER                    --Numero Caixa
                                    ,pr_codigo_barras  IN OUT VARCHAR2               --Codigo Barras
                                    ,pr_cdcritic       OUT INTEGER     --Codigo do erro
                                    ,pr_dscritic       OUT VARCHAR2) IS --Descricao do erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_codigo_barras             Antigo: dbo/b1crap14.p/valida-codigo-barras
  --  Sistema  : Procedure para validar o codigo de barras
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validar o codigo de barras

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_nrdcaixa INTEGER;
      --Variaveis erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      /* Tratamento de erros para internet e TAA */
      IF pr_cod_agencia IN (90,91)  THEN  /** TAA **/
        vr_nrdcaixa:= TO_NUMBER(pr_nrdconta||pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      --Eliminar erro
      CXON0000.pc_elimina_erro (pr_cooper      => pr_cooper
                               ,pr_cod_agencia => pr_cod_agencia
                               ,pr_nro_caixa   => vr_nrdcaixa
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se o codigo de barras estiver preenchido e o tamanho <> 44
      IF nvl(pr_codigo_barras, ' ') <> ' ' AND LENGTH(pr_codigo_barras) <> 44 THEN
        --Codigo barras
        pr_codigo_barras:= ' ';
        --Criar Erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 666
                             ,pr_dsc_erro => NULL
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 666;
          vr_dscritic:= NULL;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao processar rotina CXON0014.pc_valida_codigo_barras. '||SQLERRM;
    END;
  END pc_valida_codigo_barras;

  /* Retonar o ano do codigo barras */
  FUNCTION fn_retorna_ano_cdbarras (pr_innumano IN INTEGER  --Numero do Ano
                                   ,pr_darfndas IN BOOLEAN) --Darf/Ndas
  RETURN INTEGER IS
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_retorna_ano_cdbarras          Antigo: dbo/b1crap14.p/retorna-ano-cdbarras
  --  Sistema  : Retonar o ano do c¿digo barras
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retonar o ano do codigo barras

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Se for Darf/Ndas
      IF pr_darfndas THEN
        RETURN (2000 + pr_innumano);
      END IF;
      --Se Indicador ano entiver entre 1 e 6
      IF pr_innumano BETWEEN 1 AND 6 THEN
        RETURN (2010 + pr_innumano);
      ELSIF  pr_innumano BETWEEN 7 AND 9 THEN
        RETURN (2000 + pr_innumano);
      ELSIF  pr_innumano = 0 THEN
        RETURN(2010);
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         RETURN(NULL);
       WHEN OTHERS THEN
         RETURN(NULL);
    END;
  END fn_retorna_ano_cdbarras;

  /* Retonar a data do c¿digo barras em dias */
  FUNCTION fn_retorna_data_dias (pr_nrdedias  IN INTEGER  --Numero de Dias
                                ,pr_inanocal  IN INTEGER) --Indicador do Ano
  RETURN DATE IS
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_retorna_data_dias          Antigo: dbo/b1crap14.p/retorna-data-dias
  --  Sistema  : Retonar a data do c¿digo barras em dias
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retonar o ano do c¿digo barras

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_contador INTEGER:= 0;
      vr_dtinican DATE;
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Data Inicial
      vr_dtinican:= TO_DATE('01/01/'||pr_inanocal,'DD/MM/YYYY');
      --Quantidade dias invalida
      IF pr_nrdedias <= 0 THEN
        RETURN(NULL);
      END IF;
      WHILE vr_contador <> pr_nrdedias LOOP
        --Incrementar Data Inicial
        vr_dtinican:= vr_dtinican + 1;
        --Incrementar Contador
        vr_contador:= vr_contador + 1;
      END LOOP;
      --retornar data encontrada
      RETURN(vr_dtinican - 1);
    EXCEPTION
       WHEN vr_exc_erro THEN
         RETURN(NULL);
       WHEN OTHERS THEN
         RETURN(NULL);
    END;
  END fn_retorna_data_dias;

  /* Valida os dias de tolerancia nos convênios Sicredi */
  PROCEDURE pc_verifica_dtlimite_tributo(pr_cdcooper      IN INTEGER     -- Codigo Cooperativa
                                        ,pr_cdagenci      IN INTEGER     --Codigo Agencia
                                        ,pr_cdempcon      IN crapcon.cdempcon%TYPE -- Codigo Empresa Convenio
                                        ,pr_cdsegmto      IN crapcon.cdsegmto%TYPE -- Codigo Segmento Convenio
                                        ,pr_codigo_barras IN VARCHAR2    -- Codigo barras
                                        ,pr_dtmvtopg      IN DATE        -- Data da operação
                                        ,pr_flnrtole      IN BOOLEAN DEFAULT TRUE -- Verificar se a tolerância é ilimitada
									                    	,pr_dttolera      OUT DATE       -- Data de Tolerância (Vencimento)
                                        ,pr_cdcritic      OUT INTEGER    -- Codigo do erro
                                        ,pr_dscritic      OUT VARCHAR2) IS
  --------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_verifica_dtlimite_tributo
  --  Sigla    : CXON
  --  Autor    : Dionathan
  --  Data     : Julho/2016.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validação dos dias de tolerancia nos convênios Sicredi
  --
  -- Alterações: 02/01/2018 - incluido validação de vencimento/validade bancoob. PRJ406 - FGTS(Odirlei-AMcom)  
  --
  --             08/05/2019 - Aplicar critica da quantidade de dias para "data vencimento" e "periodo de apuração" para DARF 64 e 153.
  --                          Com isso, em caso de falhas na digitação pelo cooperado o sistema irá criticar.
  --                          (INC0014834 - Wagner - Sustentação).
  --   
  ---------------------------------------------------------------------------------------------------------------

  --> Validar convenio
  CURSOR cr_crapcon ( pr_cdcooper  crapcon.cdcooper%type,
                      pr_cdempcon  crapcon.cdempcon%TYPE,
                      pr_cdsegmto  crapcon.cdsegmto%TYPE) IS
    SELECT con.tparrecd,
           con.cdempcon,
           con.cdsegmto
      FROM crapcon con
     WHERE con.cdcooper = pr_cdcooper
       AND con.cdempcon = pr_cdempcon
       AND con.cdsegmto = pr_cdsegmto;
  rw_crapcon cr_crapcon%ROWTYPE;

  --> Arrecadacao
  CURSOR cr_tbarrecd (pr_cdempcon tbconv_arrecadacao.cdempcon%TYPE,
                      pr_cdsegmto tbconv_arrecadacao.cdsegmto%TYPE,
                      pr_tparrecd tbconv_arrecadacao.tparrecadacao%TYPE) IS
    SELECT arr.nrdias_tolerancia
      FROM tbconv_arrecadacao arr
     WHERE arr.cdempcon = pr_cdempcon
       AND arr.cdsegmto = pr_cdsegmto
       AND arr.tparrecadacao = pr_tparrecd;
  rw_tbarrecd cr_tbarrecd%ROWTYPE;

  --Busca o convênio SICREDI
  rw_crapscn cr_crapscn%ROWTYPE;
  cr_crapscn_found BOOLEAN := FALSE;
  --Selecionar transacao de convenio
  rw_crapstn cr_crapstn%ROWTYPE;
  cr_crapstn_found BOOLEAN := FALSE;

  --Variáveis
  vr_contador  INTEGER;
  vr_tpmeiarr  VARCHAR2(1);
  vr_inanocal  INTEGER;
  vr_dttolera  DATE;
  vr_dtferiado DATE;

  vr_cdempcon NUMBER;
  vr_nrinsemp NUMBER;
  vr_nrdocmto NUMBER;
  vr_nrrecolh NUMBER;
  vr_dtcompet DATE;
  vr_dtvencto DATE;
  vr_vldocmto NUMBER;
  vr_nrsqgrde NUMBER;


  vr_exc_erro EXCEPTION;

  BEGIN
    --> Validar convenio
    OPEN cr_crapcon ( pr_cdcooper  => pr_cdcooper,
                      pr_cdempcon  => pr_cdempcon,
                      pr_cdsegmto  => pr_cdsegmto);
    FETCH cr_crapcon INTO rw_crapcon;
    IF cr_crapcon%NOTFOUND THEN
      CLOSE cr_crapcon;
      pr_cdcritic:= 0;
      pr_dscritic:= 'Documento nao aceito. Procure seu Posto de Atendimento para maiores informacoes.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcon;
    END IF;

    --> Bancoob
    IF rw_crapcon.tparrecd = 2 THEN

      paga0003.pc_extrai_cdbarras_fgts_dae ( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                            ,pr_cdbarras => pr_codigo_barras --> Codigo de barras

                                            ---- OUT ----
                                            ,pr_cdempcon => vr_cdempcon --> Retorna numero da empresa conveniada
                                            ,pr_nrinsemp => vr_nrinsemp --> Numero de inscricao da empresa(CNPJ/CEI/CPF)
                                            ,pr_nrdocmto => vr_nrdocmto --> Numero do documento
                                            ,pr_nrrecolh => vr_nrrecolh --> Numero identificado de recolhimento
                                            ,pr_dtcompet => vr_dtcompet --> Data da competencia
                                            ,pr_dtvencto => vr_dtvencto --> Data de vencimento/validade
                                            ,pr_vldocmto => vr_vldocmto --> Valor do documento
                                            ,pr_nrsqgrde => vr_nrsqgrde --> Sequencial da GRDE

                                            ,pr_dscritic => pr_dscritic); --> Critica

      IF TRIM(pr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      IF pr_cdempcon IN (0178,0179,0180,0181,0239,0240,0451) AND
         pr_cdsegmto = 5 THEN

        --> validar data limite de antecipacao
        IF pr_dtmvtopg < vr_dtvencto - 30 THEN
          pr_cdcritic:= 0;
          pr_dscritic:= 'Data da validade excede período máximo de antecipação: 30 dias.';
          RAISE vr_exc_erro;
        END IF;
      END IF;

      IF pr_cdempcon IN (0178,0179,0180,0181,0239,0240,0451,0432) AND
         pr_cdsegmto = 5 THEN

        --> validar data limite de pagamento
        IF vr_dtvencto < pr_dtmvtopg THEN
          pr_cdcritic:= 0;
          pr_dscritic:= 'Prazo para pagamento excedido.';
          RAISE vr_exc_erro;
        END IF;
      ELSE
        --> Arrecadacao
        OPEN cr_tbarrecd (pr_cdempcon => rw_crapcon.cdempcon,
                          pr_cdsegmto => rw_crapcon.cdsegmto,
                          pr_tparrecd => rw_crapcon.tparrecd);

        FETCH cr_tbarrecd INTO rw_tbarrecd;
        IF cr_tbarrecd%NOTFOUND THEN
          CLOSE cr_tbarrecd;
          pr_cdcritic:= 0;
          pr_dscritic:= 'Convenio de arrecadacao nao encontrado.';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_tbarrecd;
        END IF;

        /* Se nao for tolerancia ilimitada */
        IF vr_dtvencto IS NOT NULL THEN
          IF rw_tbarrecd.nrdias_tolerancia <> 99 OR NOT pr_flnrtole THEN
            vr_dttolera := vr_dtvencto + rw_tbarrecd.nrdias_tolerancia;
            LOOP
              --Verifica se eh feriado ou final de semana
              vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                        ,pr_dtmvtolt => vr_dttolera --> Data do movimento
                                                        ,pr_tipo     => 'P');       --> Proximo dia util
              --Se for dia util
              IF vr_dtferiado = vr_dttolera THEN
                --Sair loop
                EXIT;
              END IF;
              --Incrementar data
              vr_dttolera:= vr_dttolera + 1;
            END LOOP;

            --> validar data limite para pagamento
            IF vr_dttolera < pr_dtmvtopg THEN
              pr_cdcritic:= 0;
              pr_dscritic:= 'Prazo para pagamento apos o vencimento excedido.';
              RAISE vr_exc_erro;
            END IF;

            -- sem críticas, devolve data calculada
            pr_dttolera := vr_dttolera;
          END IF;
        END IF;
      END IF;

    ELSE

    cr_crapscn_found := FALSE;
    /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
    FOR idx IN 1..5 LOOP
      /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
      OPEN cr_crapscn (pr_cdempcon  => TO_NUMBER(SUBSTR(pr_codigo_barras,16,4))
                      ,pr_cdsegmto  => SUBSTR(pr_codigo_barras,2,1)
                      ,pr_tipo      => idx);
      FETCH cr_crapscn INTO rw_crapscn;
      cr_crapscn_found := cr_crapscn%FOUND;
      CLOSE cr_crapscn;

      IF cr_crapscn_found THEN
        --Abandona loop
        EXIT;
      END IF;
    END LOOP;

    IF NOT cr_crapscn_found THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Documento nao aceito. Procure seu Posto de Atendimento para maiores informacoes.';
        RAISE vr_exc_erro;
    END IF;

    --Determinar tipo transacao
    CASE pr_cdagenci
        WHEN 90 THEN vr_tpmeiarr:= 'D';
        WHEN 91 THEN vr_tpmeiarr:= 'A';
        ELSE vr_tpmeiarr:= 'C';
    END CASE;

    --selecionar transacao de convenio
    OPEN cr_crapstn (pr_cdempres => rw_crapscn.cdempres
                    ,pr_tpmeiarr => vr_tpmeiarr);
    FETCH cr_crapstn INTO rw_crapstn;
    cr_crapstn_found := cr_crapstn%FOUND;
    CLOSE cr_crapstn;

    IF NOT cr_crapstn_found THEN
        pr_cdcritic:= 0;
        pr_dscritic:= 'Convenio nao disponivel para esse meio de arrecadacao.';
        RAISE vr_exc_erro;
    END IF;


   IF rw_crapscn.nrtolera <> 99 OR NOT pr_flnrtole THEN /* Se nao for tolerancia ilimitada */
    IF nvl(rw_crapstn.dstipdrf, ' ') <> ' '  OR
       rw_crapscn.cdempres = 'K0' THEN
      /* DARF PRETO EUROPA */
      IF pr_cdempcon IN (64,153) AND pr_cdsegmto = 5 THEN /* DARFC0064 ou DARFC0153 */
        --Retornar ano
        vr_inanocal:= CXON0014.fn_ret_ano_barras_darf (pr_innumano => TO_NUMBER(SUBSTR(pr_codigo_barras,20,1)));
        --Retornar data dias
        vr_dttolera:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_codigo_barras,21,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano
                                                   
        /* Criticar quantidade de dias inválidos no código de barras - INICIO */
        -- Para a Data de Vencimento
        IF SUBSTR(pr_codigo_barras,21,3) IS NOT NULL AND 
           (To_Number(SUBSTR(pr_codigo_barras,21,3)) < 1 OR
            To_Number(SUBSTR(pr_codigo_barras,21,3)) > 366) THEN
          --Mensagem erro
          pr_cdcritic:= 0;
          pr_dscritic:= 'Data do vecimento invalida.';
          RAISE vr_exc_erro;
      END IF;
        
        -- Para o Período de Apuração
        IF SUBSTR(pr_codigo_barras,42,3) IS NOT NULL AND 
           (To_Number(SUBSTR(pr_codigo_barras,42,3)) < 1 OR
            To_Number(SUBSTR(pr_codigo_barras,42,3)) > 366) THEN
          --Mensagem erro
          pr_cdcritic:= 0;
          pr_dscritic:= 'Periodo de apuracao invalido.';
          RAISE vr_exc_erro;
        END IF;
        
        /* Criticar quantidade de dias inválidos no código de barras - FIM */
                                                           
      END IF;
      /* DARF NUMERADO / DAS */
      IF pr_cdempcon IN (385,328) AND pr_cdsegmto = 5 THEN /* DARFC0385 ou DAS - SIMPLES NACIONAL */
        --Retornar ano
        vr_inanocal:= CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_codigo_barras,20,2))
                                                      ,pr_darfndas => TRUE);
        --Retornar data dias
        vr_dttolera:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_codigo_barras,22,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano
      END IF;
      --Data agendamento maior tolerancia
      IF pr_dtmvtopg > vr_dttolera THEN
        --Montar mensagem erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Prazo para pagamento apos o vencimento excedido.';
        RAISE vr_exc_erro;
      END IF;
    ELSE  /* Nao é DARF/DAS */
      BEGIN
        vr_dttolera:= TO_DATE(gene0002.fn_mask(SUBSTR(pr_codigo_barras,26,2),'99')|| '/'||
                              gene0002.fn_mask(SUBSTR(pr_codigo_barras,24,2),'99')|| '/'||
                              gene0002.fn_mask(SUBSTR(pr_codigo_barras,20,4),'9999'),'DD/MM/YYYY');
        --Iniciar contador
        vr_contador:= 1;
        --Dia toleracia
        IF rw_crapscn.dsdiatol = 'U' THEN /* Dias úteis */
          LOOP
            --Incrementa dia tolerancia
            vr_dttolera:= vr_dttolera + 1;
            --Verifica se eh feriado ou final de semana
            vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                      ,pr_dtmvtolt => vr_dttolera --> Data do movimento
                                                      ,pr_tipo     => 'P');       --> Proximo dia util
            --Se for data diferente é feriado ou final semana
            IF vr_dtferiado <> vr_dttolera THEN
              --Proxima iteracao loop
              CONTINUE;
            END IF;
            --Se contador igual tolerancia
            IF vr_contador = rw_crapscn.nrtolera THEN
              --Sair loop
              EXIT;
            END IF;
            --Incrementar contador
            vr_contador:= vr_contador + 1;
          END LOOP;
        ELSE  /* Dias corridos */
          vr_dttolera:= vr_dttolera + rw_crapscn.nrtolera;
          LOOP
            --Verifica se eh feriado ou final de semana
            vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                      ,pr_dtmvtolt => vr_dttolera --> Data do movimento
                                                      ,pr_tipo     => 'P');       --> Proximo dia util
            --Se for dia util
            IF vr_dtferiado = vr_dttolera THEN
              --Sair loop
              EXIT;
            END IF;
            --Incrementar data
            vr_dttolera:= vr_dttolera + 1;
          END LOOP;
        END IF;
        --Se for maior igual a 2010 e data agendamento maior tolerancia
        IF To_Number(TO_CHAR(vr_dttolera,'YYYY')) >= 2010 AND
           pr_dtmvtopg > vr_dttolera THEN
          --Montar mensagem erro
          pr_cdcritic := 0;
          pr_dscritic := 'Prazo para pagamento apos o vencimento excedido.';
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
    END IF;
	-- sem críticas, devolve data calculada
	pr_dttolera := vr_dttolera;

  END IF;
  
    IF nvl(rw_crapstn.dstipdrf, ' ') <> ' '  OR
       rw_crapscn.cdempres = 'K0' THEN
      /* DARF PRETO EUROPA */
      IF pr_cdempcon IN (64,153) AND pr_cdsegmto = 5 THEN /* DARFC0064 ou DARFC0153 */
        /* Criticar quantidade de dias inválidos no código de barras - INICIO */
        -- Para a Data de Vencimento
        IF SUBSTR(pr_codigo_barras,21,3) IS NOT NULL AND 
           (To_Number(SUBSTR(pr_codigo_barras,21,3)) < 1 OR
            To_Number(SUBSTR(pr_codigo_barras,21,3)) > 366) THEN
          --Mensagem erro
          pr_cdcritic:= 0;
          pr_dscritic:= 'Data do vecimento invalida.';
          RAISE vr_exc_erro;
        END IF;
        
        -- Para o Período de Apuração
        IF SUBSTR(pr_codigo_barras,42,3) IS NOT NULL AND 
           (To_Number(SUBSTR(pr_codigo_barras,42,3)) < 1 OR
            To_Number(SUBSTR(pr_codigo_barras,42,3)) > 366) THEN
          --Mensagem erro
          pr_cdcritic:= 0;
          pr_dscritic:= 'Periodo de apuracao invalido.';
          RAISE vr_exc_erro;
        END IF;
        /* Criticar quantidade de dias inválidos no código de barras - FIM */                                                   
      END IF;
    END IF;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
        IF pr_dscritic IS NULL THEN
          pr_dscritic := 'Erro ao validar dias de tolerancia.';
        END IF;
        RETURN;
  END pc_verifica_dtlimite_tributo;

  /* Realizar validacoes para Sicredi */
  PROCEDURE pc_validacoes_sicredi (pr_cdcooper      IN INTEGER     --Codigo Cooperativa
                                  ,pr_cod_agencia   IN INTEGER     --Codigo Agencia
                                  ,pr_nrdconta      IN INTEGER     --Numero da Conta
                                  ,pr_idseqttl      IN INTEGER     --Sequencial Titular
                                  ,pr_nro_caixa     IN INTEGER     --Numero Caixa
                                  ,pr_codigo_barras IN VARCHAR2    --Codigo barras
                                  ,pr_idagenda      IN INTEGER     --Identificador Agendamento
                                  ,pr_flgpgag       IN BOOLEAN     --Indicador Pagto agendamento
                                  ,pr_cdempcon      IN crapcon.cdempcon%TYPE --Codigo Empresa Convenio
                                  ,pr_cdsegmto      IN crapcon.cdsegmto%TYPE --Codigo Segmento Convenio
                                  ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                  ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro

--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_validacoes_sicredi             Antigo: dbo/b1crap14.p/validacoes-sicredi
  --  Sistema  : Procedure para validacoes Sicredi
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: 25/02/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validacoes Sicredi
  --
  -- Alterações: 27/07/2015 - Tratamento da vr_dttolera conforme faz no programa progress (Lucas Ranghetti/Elton)
  --
  --             28/07/2015 - Adicionar crapscn.dsoparre <> 'E' no cursor do crapscn (Lucas Ranghetti #234418)
  --
  --             11/11/2015 - Fechar cursor cr_lft_ult_pag_sicredi que estava permanecendo aberto quando
  --                          nao encontrava registro. (Fabricio)
  --
  --             22/07/2016 - Extração da validação dos dias de tolerancia nos convênios Sicredi para a procedure
  --                          pc_verifica_dtlimite_tributo (Dionathan)
  --
  --             22/07/2016 - Ajustada para ser retirado o bloqueio de pagamento de DARF e DAS via PA 90,
  --                          Prj. 338. (Jean Michel)
  --
  --              25/02/2019 - Inclusão de novas validações no código de barras para DARF/DAS
  --                           (sctask0046009 - Adriano).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Busca o convênio SICREDI
      rw_crapscn cr_crapscn%ROWTYPE;
      --selecionar transacao de convenio
      rw_crapstn cr_crapstn%ROWTYPE;

      CURSOR cr_lft_ult_pag_sicredi (pr_cdcooper      IN craplft.cdcooper%type
                                    ,pr_codigo_barras IN VARCHAR2
                                    ,pr_cdhistor      IN craplft.cdhistor%type
                                    ,pr_tpfatura      IN craplft.tpfatura%type) IS
        SELECT /*+index (lft CRAPLFT##CRAPLFT5) */
               lft.dtvencto
          FROM craplft lft
         WHERE lft.cdcooper = pr_cdcooper
           AND UPPER(lft.cdbarras) = pr_codigo_barras -- UPPER necessário pois o index lft5 está com upper
           AND lft.cdhistor = pr_cdhistor
           AND lft.tpfatura <> pr_tpfatura
           AND lft.dtvencto > ADD_MONTHS(SYSDATE,-60) -- Verifica apenas os últimos 5 anos pois o sicredi também
                                                        -- valida os pagamentos feitos em até 5 anos.
        ORDER BY lft.dtvencto DESC;

      rw_lft_ult_pag_sicredi cr_lft_ult_pag_sicredi%ROWTYPE;

      --Variaveis Locais
	  vr_dttolera  DATE;
      vr_hhsicini  INTEGER;
      vr_hhsicfim  INTEGER;
      vr_flgachou  BOOLEAN;
      vr_tpmeiarr  VARCHAR2(1);
      vr_nrdcaixa  INTEGER;
      vr_dstextab  craptab.dstextab%TYPE;
	  vr_numerdas  VARCHAR2(100);
	  vr_dvnrodas  INTEGER;
	  vr_poslimit  INTEGER;
	  vr_dvadicio  INTEGER;
	  vr_digito    INTEGER;
    vr_flagdvok BOOLEAN:=FALSE;
      --Variaveis erro
      vr_cod_erro  INTEGER;
      vr_des_erro  VARCHAR2(400);
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      --Tipo de registro de data
      rw_crapdat   BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      /* Tratamento de erros para internet e TAA */
      IF pr_cod_agencia IN (90,91) THEN    /** Internet ou TAA **/
         vr_nrdcaixa:= TO_NUMBER(pr_nrdconta||pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;

      /* Se nao for Agendamento nem Pagto de Agendamento */
      IF pr_idagenda <> 2 AND NOT pr_flgpgag THEN
        /* Validacao de horarios de convenios SICREDI */
        vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                ,pr_nmsistem => 'CRED'
                                                ,pr_tptabela => 'GENERI'
                                                ,pr_cdempres => 0
                                                ,pr_cdacesso => 'HRPGSICRED'
                                                ,pr_tpregist => pr_cod_agencia);
        IF vr_dstextab IS NULL THEN
          --Criar Erro
          vr_cod_erro:= 0;
          vr_des_erro:= 'Parametros de Horario nao cadastrados.';
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= vr_cod_erro;
            vr_dscritic:= vr_des_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        ELSE
          --Horario Inicial e Final Sicredi
          vr_hhsicini:= To_Number(GENE0002.fn_busca_entrada(1,vr_dstextab,' '));
          vr_hhsicfim:= To_Number(GENE0002.fn_busca_entrada(2,vr_dstextab,' '));
        END IF;
        --Se estiver dentro horario inicial e final
        IF GENE0002.fn_busca_time NOT BETWEEN vr_hhsicini AND vr_hhsicfim THEN
          --Se for TAA ou Iternet
          IF pr_cod_agencia IN (90,91) THEN
            --Montar mensagem erro
            vr_cod_erro:= 0;
            vr_des_erro:= 'Esse convenio e aceito ate as ' || GENE0002.fn_converte_time_data(vr_hhsicfim)||
                          'hs. O pagamento pode ser agendado para o proximo dia util.';
          ELSE
            --Montar mensagem erro
            vr_cod_erro:= 676;
            vr_des_erro:= NULL;
          END IF;
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= vr_cod_erro;
            vr_dscritic:= vr_des_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;

      --Marcar que nao encontrou
      vr_flgachou:= FALSE;
      /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
      FOR idx IN 1..5 LOOP
        /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
        OPEN cr_crapscn (pr_cdempcon  => TO_NUMBER(SUBSTR(pr_codigo_barras,16,4))
                        ,pr_cdsegmto  => SUBSTR(pr_codigo_barras,2,1)
                        ,pr_tipo      => idx);
        --Posicionar no proximo registro
        FETCH cr_crapscn INTO rw_crapscn;
        --Se nao encontrar
        IF cr_crapscn%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapscn;
        ELSE
          --Fechar Cursor
          CLOSE cr_crapscn;
          --Marcar que encontrou
          vr_flgachou:= TRUE;
          --Abandona loop
          EXIT;
        END IF;
      END LOOP;
      --Se nao encontrou
      IF NOT vr_flgachou THEN
        --Montar mensagem erro
        vr_cod_erro:= 0;
        vr_des_erro:= 'Documento nao aceito. Procure seu Posto de Atendimento para maiores informacoes.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => vr_cod_erro
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= vr_cod_erro;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      /* Validação para saber se o convenio possui o meio de arrecadacao utilizado */
            --Determinar tipo transacao
            CASE pr_cod_agencia
                WHEN 90 THEN vr_tpmeiarr:= 'D';
                WHEN 91 THEN vr_tpmeiarr:= 'A';
                ELSE vr_tpmeiarr:= 'C';
            END CASE;

            IF rw_crapscn.dsoparre LIKE TO_CHAR('%'||vr_tpmeiarr||'%') THEN

                --selecionar transacao de convenio
                OPEN cr_crapstn (pr_cdempres => rw_crapscn.cdempres
                                                ,pr_tpmeiarr => vr_tpmeiarr);
                --Posicionar no proximo registro
                FETCH cr_crapstn INTO rw_crapstn;
                --Se nao encontrar
                IF cr_crapstn%NOTFOUND THEN
                    --Fechar Cursor
                    CLOSE cr_crapstn;
                    --Montar mensagem erro
                    vr_cod_erro:= 0;
                    vr_des_erro:= 'Convenio nao disponivel para esse meio de arrecadacao.';
                    --Criar erro
                    CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                                             ,pr_cdagenci => pr_cod_agencia
                                                             ,pr_nrdcaixa => vr_nrdcaixa
                                                             ,pr_cod_erro => vr_cod_erro
                                                             ,pr_dsc_erro => vr_des_erro
                                                             ,pr_flg_erro => TRUE
                                                             ,pr_cdcritic => vr_cdcritic
                                                             ,pr_dscritic => vr_dscritic);
                    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                        --Levantar Excecao
                        RAISE vr_exc_erro;
                    ELSE
                        vr_cdcritic:= vr_cod_erro;
                        vr_dscritic:= vr_des_erro;
                        --Levantar Excecao
                        RAISE vr_exc_erro;
                    END IF;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapstn;
            ELSE
                --Montar mensagem erro
                vr_cod_erro:= 0;
                vr_des_erro:= 'Convenio nao disponivel para esse meio de arrecadacao.';
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                                         ,pr_cdagenci => pr_cod_agencia
                                                         ,pr_nrdcaixa => vr_nrdcaixa
                                                         ,pr_cod_erro => vr_cod_erro
                                                         ,pr_dsc_erro => vr_des_erro
                                                         ,pr_flg_erro => TRUE
                                                         ,pr_cdcritic => vr_cdcritic
                                                         ,pr_dscritic => vr_dscritic);
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                ELSE
                    vr_cdcritic:= vr_cod_erro;
                    vr_dscritic:= vr_des_erro;
                    --Levantar Excecao
                    RAISE vr_exc_erro;
                END IF;
            END IF;

      /* Validacao para nao aceitar DARFs e DAS no TAA/ */
      IF pr_cod_agencia = 91 THEN  /* TAA */
        IF nvl(rw_crapstn.dstipdrf, ' ') <> ' ' OR rw_crapscn.cdempres = 'K0' THEN
          --Montar mensagem erro
          vr_cod_erro:= 0;
          vr_des_erro:= 'Nao permitido o pagamento deste tipo de guia.';
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= vr_cod_erro;
            vr_dscritic:= vr_des_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
      END IF;
            END IF;
            END IF;

	  -- Se nao for Agendamento nem Pagto de Agendamento
      IF pr_idagenda <> 2 AND NOT pr_flgpgag THEN
			-- DAS - SIMPLES NACIONAL
			IF rw_crapscn.cdempres = 'K0' THEN

				vr_numerdas := SUBSTR(pr_codigo_barras, 25, 16);
      			vr_dvnrodas := TO_NUMBER(SUBSTR(pr_codigo_barras, 41, 1));

				CXON0014.pc_verifica_digito (pr_nrcalcul => vr_numerdas  --Numero a ser calculado
				                            ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                  			,pr_nrdigito => vr_digito);  --Digito verificador
				IF vr_digito <> vr_dvnrodas THEN
					vr_cod_erro:= 8;
        			vr_des_erro:= '';
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => vr_cod_erro
                                   ,pr_dsc_erro => vr_des_erro
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= vr_cod_erro;
                vr_dscritic:= vr_des_erro;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;

				FOR idx IN 42..44 LOOP

					vr_poslimit := idx;

				  	vr_dvnrodas := TO_NUMBER(SUBSTR(pr_codigo_barras, vr_poslimit, 1));
					vr_poslimit := (vr_poslimit - 5);
				  	vr_numerdas := (SUBSTR(pr_codigo_barras, 1, 3) ||
					                SUBSTR(pr_codigo_barras, 5, vr_poslimit));

					CXON0014.pc_verifica_digito (pr_nrcalcul => vr_numerdas  --Numero a ser calculado
					                            ,pr_poslimit => vr_poslimit  --Utilizado para validação de dígito adicional de DAS
                                    			,pr_nrdigito => vr_digito);  --Digito verificador
					IF vr_digito <> vr_dvnrodas THEN
						vr_cod_erro:= 8;
						vr_des_erro:= '';
              --Criar erro
              CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cod_agencia
                                   ,pr_nrdcaixa => vr_nrdcaixa
                                   ,pr_cod_erro => vr_cod_erro
                                   ,pr_dsc_erro => vr_des_erro
                                   ,pr_flg_erro => TRUE
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
              IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                --Levantar Excecao
                RAISE vr_exc_erro;
              ELSE
                vr_cdcritic:= vr_cod_erro;
                vr_dscritic:= vr_des_erro;
                --Levantar Excecao
                RAISE vr_exc_erro;
              END IF;
            END IF;

				END LOOP;

			END IF;
      
      /* Para DAS - SIMPLES NACIONAL e  DARFC0385 (DARF NUMERADO)
         deve ser realizado a validação dos digitos.*/
      IF rw_crapscn.cdempres IN ('K0','608') THEN
            
        pc_calcula_dv_numero_das(pr_numerdas => substr(pr_codigo_barras,25,16)        --Codigo barras
                                ,pr_dvnrodas => to_number(substr(pr_codigo_barras,41,1)) --Utilizado para validação de dígito adicional de DAS
                                ,pr_flagdvok => vr_flagdvok);
            
        --Se digito não estiver correto
        IF NOT vr_flagdvok THEN
                
          vr_cdcritic := 8;
          vr_des_erro:= ''; 
          --Levantar Excecao
          RAISE vr_exc_erro;
                
	  END IF;
              
        FOR idx IN 42..44 LOOP

          vr_poslimit := idx;

          vr_dvadicio := TO_NUMBER(SUBSTR(pr_codigo_barras, vr_poslimit, 1));
                
          pc_calcula_dv_adicional (pr_cdbarras => pr_codigo_barras     --Codigo barras
                                  ,pr_poslimit => vr_poslimit - 5 --Utilizado para validação de dígito adicional de DAS
                                  ,pr_nrdigito => vr_dvadicio     --Numero a ser calculado
                                  ,pr_flagdvok => vr_flagdvok);   --Digito correto sim/nao
                                      
          IF NOT vr_flagdvok THEN
                  
            vr_cdcritic:= 8;
            vr_des_erro:= '';
            
            --Levantar Excecao
            RAISE vr_exc_erro;
                  
          END IF;


        END LOOP;

              
      END IF;
            
	  END IF;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
          END IF;
      /* N¿o repete validacao ja realizada se for Agendamento */
      IF pr_idagenda <> 2 THEN
        /* Validação referente aos dias de tolerancia */
        pc_verifica_dtlimite_tributo(pr_cdcooper      => pr_cdcooper
                                    ,pr_cdagenci      => pr_cod_agencia
                                    ,pr_cdempcon      => pr_cdempcon
                                    ,pr_cdsegmto      => pr_cdsegmto
                                    ,pr_codigo_barras => pr_codigo_barras
                                    ,pr_dtmvtopg      => rw_crapdat.dtmvtocd
                                    ,pr_flnrtole      => TRUE
									                  ,pr_dttolera      => vr_dttolera
                                    ,pr_cdcritic      => pr_cdcritic
                                    ,pr_dscritic      => pr_dscritic);

        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;

      --Selecionar lancamentos de fatura
      OPEN cr_lft_ult_pag_sicredi (pr_cdcooper      => pr_cdcooper
                                  ,pr_codigo_barras => pr_codigo_barras
                                  ,pr_cdhistor      => 1154
                                  ,pr_tpfatura      => 2);
      --Posicionar no proximo registro
      FETCH cr_lft_ult_pag_sicredi INTO rw_lft_ult_pag_sicredi;

      -- Se encontrar fatura já paga:
      IF cr_lft_ult_pag_sicredi%FOUND THEN

        CLOSE cr_lft_ult_pag_sicredi;

        vr_cod_erro := 0;

        vr_des_erro := 'Fatura ja arrecadada dia ' ||
                       to_char(rw_lft_ult_pag_sicredi.dtvencto,'dd/mm/RRRR') || '.';

        -- se o pagamento for no caixa on-line gerar a crítica
        IF pr_cod_agencia <> 90 AND
           pr_cod_agencia <> 91 THEN

            vr_des_erro := vr_des_erro ||  ' Para consultar o canal de recebimento, verificar na tela PESQTI.';

        ELSE -- senao, é internet/mobile (cdagenci = 90) ou TA (cdagenci = 91)

          IF pr_flgpgag = FALSE THEN
            vr_des_erro := vr_des_erro || ' Duvidas entrar em contato com o SAC pelo telefone ' ||
                           rw_crapcop.nrtelsac || '.';
          END IF;

        END IF;

        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => vr_cod_erro
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic := vr_cod_erro;
          vr_dscritic := vr_des_erro;
          RAISE vr_exc_erro;
        END IF;

      ELSE
        CLOSE cr_lft_ult_pag_sicredi;
      END IF;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao processar rotina CXON0014.pc_validacoes_sicredi. '||SQLERRM;
    END;
  END pc_validacoes_sicredi;

  FUNCTION fn_busca_sequencial_fatura (pr_cdhistor      IN crapcon.cdhistor%TYPE --Codigo historico
                                      ,pr_codigo_barras IN VARCHAR2)             --Codigo Barras
                                       RETURN NUMBER IS
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_busca_sequencial_fatura             Antigo: dbo/b1crap14.p/busca_sequencial_fatura
  --  Sistema  : Buscar Sequencial da fatura
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: 18/06/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Buscar Sequencial da fatura

  -- Alteracoes: 29/05/2014 - Removido as validacoes para Sicredi (1154), Samae
  --                          Jaragua (396), DARE Sefaz (1063). Alterado o tamanho do
  --                          substr do codigo de barras. (Douglas - Chamado 128278)
  --
  --             18/06/2014 - Removido as validacoes para GNRE - SEFAZ (1065).
  --                          (Douglas - Chamado 128278)
  --
  --             26/07/2016 - Procedure transformada em Function para otimização de performance
  --                         (Dionathan)
  ---------------------------------------------------------------------------------------------------------------

  vr_cdseqfat NUMBER; --Codigo Sequencial Fatura

    BEGIN

    vr_cdseqfat := NULL;

      CASE pr_cdhistor
      WHEN 308 THEN /*  Telesc Brasil Telecom  */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,20,20));
      WHEN 374 THEN     /*  Embratel  */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,21,13));
      WHEN 398 THEN     /* Prefeitura Gaspar */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,20,25));
      WHEN 663 THEN      /* Prefeitura de Pomerode */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,20,25));
      WHEN 456 THEN      /* Aguas Itapema */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,30,13));
      WHEN 964 THEN      /* Aguas de Massaranduba */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,30,13));
      WHEN 618 THEN      /* Samae Pomerode */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,25,14));
      WHEN 899 THEN     /* Samae Rio Negrinho */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,25,14));
      WHEN 625 THEN      /* CELESC */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,27,16));
      WHEN 666 THEN      /* CELESC */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,27,16));
      WHEN 659 THEN      /* P.M.Itajai */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 464 THEN      /* Aguas Pres.Getulio */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 929 THEN       /* CERSAD */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 963 THEN      /* Foz do Brasil */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 671 THEN      /**DAE Navegantes**/
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,29,14));
      WHEN 373 THEN      /**IPTU Blumenau**/
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,15));
      WHEN 675 THEN       /** SEMASA Itajai **/
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,30,14));
      ELSE /*  Casan e outros */
        vr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,7,38));
      END CASE;

      RETURN vr_cdseqfat;
  END fn_busca_sequencial_fatura;


  /* Buscar Sequencial da fatura */
  PROCEDURE pc_busca_sequencial_fatura (pr_cdhistor      IN crapcon.cdhistor%TYPE      --Codigo historico
                                       ,pr_codigo_barras IN VARCHAR2                   --Codigo Barras
                                       ,pr_cdseqfat      OUT NUMBER                    --Codigo Sequencial Fatura
                                       ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                       ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro

--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_sequencial_fatura             Antigo: dbo/b1crap14.p/busca_sequencial_fatura
  --  Sistema  : Buscar Sequencial da fatura
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: 18/06/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Buscar Sequencial da fatura
  --
  -- Anotações : 26/07/2016 - Procedure transformada em Function para otimização de performance
  --                         (Dionathan)
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Chama a function
      pr_cdseqfat := fn_busca_sequencial_fatura(pr_cdhistor, pr_codigo_barras);

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao processar rotina CXON0014.pc_busca_sequencial_fatura. '||SQLERRM;
    END;
  END pc_busca_sequencial_fatura;

  /* Procedure para retornar valores fatura */
  PROCEDURE pc_retorna_valores_fatura (pr_cdcooper      IN INTEGER      --Codigo Cooperativa
                                      ,pr_nrdconta      IN INTEGER      --Numero da Conta
                                      ,pr_idseqttl      IN INTEGER      --Sequencial Titular
                                      ,pr_cod_operador  IN VARCHAR2     --Codigo Operador
                                      ,pr_cod_agencia   IN INTEGER      --Codigo Agencia
                                      ,pr_nro_caixa     IN INTEGER      --Numero Caixa
                                      ,pr_fatura1       IN NUMBER       --Parte 1 fatura
                                      ,pr_fatura2       IN NUMBER       --Parte 2 fatura
                                      ,pr_fatura3       IN NUMBER       --Parte 3 fatura
                                      ,pr_fatura4       IN NUMBER       --Parte 4 fatura
                                      ,pr_codigo_barras IN OUT VARCHAR2 --Codigo barras
                                      ,pr_cdseqfat      OUT NUMBER      --Sequencial faturamento
                                      ,pr_vlfatura      OUT NUMBER      --Valor Fatura
                                      ,pr_nrdigfat      OUT INTEGER     --Digito Faturamento
                                      ,pr_iptu          OUT BOOLEAN     --Indicador IPTU
                                      ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                      ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_retorna_valores_fatura             Antigo: dbo/b1crap14.p/retorna-valores-fatura
  --  Sistema  : Procedure para retornar valores fatura
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 25/02/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para retornar valores fatura
  --
  -- Alteracoes: 27/07/2015 - Na chamada da CXON0014.pc_validacoes_sicredi adicionado validacao
  --                          de critica (Lucas Ranghetti #312583 )
  --
  --             20/03/2017 - Ajuste para verificar vencimento da P.M. TIMBO, DEFESA CIVIL TIMBO
  --                          MEIO AMBIENTE DE TIMBO, TRANSITO DE TIMBO (Lucas Ranghetti #630176)
  --
  --             12/04/2017 - Ajuste para verificar vencimento da P.M. AGROLANDIA (Tiago #647174)
  --
  --             22/05/2017 - Ajustes para verificar vencimento da P.M. TROMBUDO CENTRAL
  --                          e FMS TROMBUDO CENTRAL (Tiago/Fabricio #653830)
  --
  --             26/05/2017 - Ajustes para verificar vencimento da P.M. AGROLANDIA
  --                          (Tiago/Fabricio #647174)
  --
  --             31/05/2017 - Regra para alertar o usuário quando tentar pagar um GPS na modalidade de
  --                          pagamento apresentando a seguinte mensagem: GPS deve ser paga na opção
  --                          Transações - GPS do menu de serviços. (Rafael Monteiro - Mouts)
  --
  --             28/07/2017 - Alterar a verificacao de vencimento das faturas de convenio, para que
  --                          seja feito atraves de parametrizacao na crapprm (Douglas - Chamado 711440)
  --
  --             16/03/2018 - Ajuste de acentuação na mensagem de crítica de fatura vencida
  --                          (Rafael - Projeto 285 - Nova Conta Online - ID172 - PCT6)
  --
  --              25/02/2019 - Inclusão de novas validações no código de barras para DARF/DAS
  --                           (sctask0046009 - Adriano).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Selecionar cadastro empresas conveniadas
      CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                        ,pr_cdempcon IN crapcon.cdempcon%type
                        ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
        SELECT crapcon.cdcooper
              ,crapcon.tparrecd
              ,crapcon.cdempcon
              ,crapcon.cdsegmto
              ,crapcon.cdhistor
        FROM crapcon
        WHERE crapcon.cdcooper = pr_cdcooper
        AND   crapcon.cdempcon = pr_cdempcon
        AND   crapcon.cdsegmto = pr_cdsegmto;
      rw_crapcon cr_crapcon%ROWTYPE;
      --Selecionar lancamentos de fatura
      CURSOR cr_craplft (pr_cdcooper IN craplft.cdcooper%type
                        ,pr_dtmvtolt IN craplft.dtmvtolt%type
                        ,pr_cdagenci IN craplft.cdagenci%type
                        ,pr_cdbccxlt IN craplft.cdbccxlt%type
                        ,pr_nrdolote IN craplft.nrdolote%type
                        ,pr_cdseqfat IN craplft.cdseqfat%type) IS
        SELECT craplft.cdcooper
        FROM craplft
        WHERE craplft.cdcooper = pr_cdcooper
        AND   craplft.dtmvtolt = pr_dtmvtolt
        AND   craplft.cdagenci = pr_cdagenci
        AND   craplft.cdbccxlt = pr_cdbccxlt
        AND   craplft.nrdolote = pr_nrdolote
        AND   craplft.cdseqfat = pr_cdseqfat;
      rw_craplft cr_craplft%ROWTYPE;

      -- Efetuar a busca do valor na tabela
      CURSOR cr_crapprm_dias_tolera (pr_cdacesso IN VARCHAR) IS
        SELECT to_number(prm.dsvlrprm) dsvlrprm
          FROM crapprm prm
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 0 --> Busca tanto da passada, quanto da geral (se existir)
           AND prm.cdacesso = pr_cdacesso; --> Trará a cooperativa passada primeiro, e caso não encontre nela, trará da 0(zero)

      -- Acesso a quantidade de dias de tolerancia
      vr_cdacesso      VARCHAR2(24);
      vr_qtdias_tolera INTEGER;

      --Variaveis Locais
      vr_nrdcaixa INTEGER;
      vr_lindigit NUMBER;
      vr_fatura   NUMBER;
      vr_calc     VARCHAR2(100);
      vr_dsc_erro VARCHAR2(100);
      vr_lote     INTEGER;
      vr_digito   INTEGER;
      vr_nrdigito INTEGER;
      vr_idagenda INTEGER;
      vr_retorno  BOOLEAN;
      vr_flgpgag  BOOLEAN;
      vr_dtmvtoan VARCHAR2(8);
      --Tipo de registro de data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

	  vr_cdcritic_aux crapcri.cdcritic%TYPE;
      vr_dscritic_aux VARCHAR2(4000);

      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      /* Tratamento de erros para internet e TAA */
      IF pr_cod_agencia IN (90,91) THEN
        vr_nrdcaixa:= TO_NUMBER(pr_nrdconta||pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;

      /* Utiliza operador 1000 para agendamentos */
      IF pr_cod_operador = '1000' THEN
        vr_idagenda:= 2;
      ELSE
        vr_idagenda:= 1;
      END IF;
      /* Utiliza operador 1001 para Pagto de agendamentos com o
      objeitvo de n¿o validar hor¿rio de limite de pagamento SICREDI */
      vr_flgpgag:= pr_cod_operador = '1001';

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      --Eliminar erro
      CXON0000.pc_elimina_erro (pr_cooper      => pr_cdcooper
                               ,pr_cod_agencia => pr_cod_agencia
                               ,pr_nro_caixa   => vr_nrdcaixa
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Inicializar variaveis
      pr_iptu:= FALSE;
      pr_cdseqfat:= 0;
      pr_vlfatura:= 0;
      pr_nrdigfat:= 0;

            -- Identificação de Fatura
            IF  SUBSTR(pr_codigo_barras,1,1) <> '8' THEN
                 -- Criar Erro
                 CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                                            ,pr_cdagenci => pr_cod_agencia
                                                            ,pr_nrdcaixa => vr_nrdcaixa
                                                            ,pr_cod_erro => 8
                                                            ,pr_dsc_erro => NULL
                                                            ,pr_flg_erro => TRUE
                                                            ,pr_cdcritic => vr_cdcritic
                                                            ,pr_dscritic => vr_dscritic);
                 IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 ELSE
                     vr_cdcritic:= 8;
                     vr_dscritic:= NULL;
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                 END IF;
            END IF;
    -- Validar se eh GPS
      IF to_number(SUBSTR(pr_codigo_barras,16,4)) = 270 AND
         to_number(SUBSTR(pr_codigo_barras,2,1)) = 5 THEN
        BEGIN
          --Criar Erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 0
                               ,pr_dsc_erro => 'GPS deve ser paga na opção Transações - GPS do menu de serviços.'
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro chamada Oracle CXON0000 '||sqlerrm;
            RAISE vr_exc_erro;
        END;
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'GPS deve ser paga na opção Transações - GPS do menu de serviços.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --
      --Selecionar cadastro empresas conveniadas
      OPEN cr_crapcon (pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_cdempcon => to_number(SUBSTR(pr_codigo_barras,16,4))
                      ,pr_cdsegmto => to_number(SUBSTR(pr_codigo_barras,2,1)));
      --Posicionar no proximo registro
      FETCH cr_crapcon INTO rw_crapcon;
      --Se nao encontrar
      IF cr_crapcon%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcon;
        --Criar Erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 0
                             ,pr_dsc_erro => 'Empresa nao Conveniada '||SUBSTR(pr_codigo_barras,2,1) ||
                                             '/'||SUBSTR(pr_codigo_barras,16,4)
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Empresa nao Conveniada '||SUBSTR(pr_codigo_barras,2,1) ||
                                             '/'||SUBSTR(pr_codigo_barras,16,4);
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcon;

      IF pr_fatura1 <> 0 OR
         pr_fatura2 <> 0 OR
         pr_fatura3 <> 0 OR
         pr_fatura4 <> 0 THEN
         /* Valida os campos manuais de 1 ate 4 */
         FOR idx IN 1..4 LOOP
           --Determinar a linha que sera validada
           CASE idx
             WHEN 1 THEN vr_fatura:= pr_fatura1;
             WHEN 2 THEN vr_fatura:= pr_fatura2;
             WHEN 3 THEN vr_fatura:= pr_fatura3;
             WHEN 4 THEN vr_fatura:= pr_fatura4;
           END CASE;
           --Linha Digitavel
           vr_lindigit:= TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_fatura,'999999999999'),1,11));
           --Numero Digito
           vr_nrdigito:= TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_fatura,'999999999999'),12,11));
           IF SUBSTR(pr_codigo_barras,3,1) IN ('6','7') THEN
             /** Verificacao pelo modulo 10**/
             CXON0000.pc_calc_digito_iptu_samae (pr_valor    => vr_lindigit   --> Valor Calculado
                                                ,pr_nrdigito => vr_digito     --> Digito Verificador
                                                ,pr_retorno  => vr_retorno);  --> Retorno digito correto
           ELSE
             /*** Verificacao pelo modulo 11 ***/
             CXON0014.pc_verifica_digito (pr_nrcalcul => vr_lindigit  --Numero a ser calculado
						                 ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                         ,pr_nrdigito => vr_digito); --Digito verificador
           END IF;
           --Verificar se os numeros batem
           IF  vr_digito <> vr_nrdigito  THEN
             --Criar Erro
             CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cod_agencia
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_cod_erro => 8
                                  ,pr_dsc_erro => NULL
                                  ,pr_flg_erro => TRUE
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
             IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
               --Levantar Excecao
               RAISE vr_exc_erro;
             ELSE
               vr_cdcritic:= 8;
               vr_dscritic:= NULL;
               --Levantar Excecao
               RAISE vr_exc_erro;
             END IF;
           END IF;
         END LOOP;
         --Retornar C¿digo barras
         pr_codigo_barras:= SUBSTR(gene0002.fn_mask(pr_fatura1,'999999999999'),1,11)||
                            SUBSTR(gene0002.fn_mask(pr_fatura2,'999999999999'),1,11)||
                            SUBSTR(gene0002.fn_mask(pr_fatura3,'999999999999'),1,11)||
                            SUBSTR(gene0002.fn_mask(pr_fatura4,'999999999999'),1,11);
      END IF;
      --Calcular Digito Codigo Barras
      vr_calc:= pr_codigo_barras;

      IF SUBSTR(pr_codigo_barras,3,1) IN ('6','7') THEN
        /*** Calculo digito verificador pelo modulo 10 ***/
        CXON0000.pc_calc_digito_iptu_samae (pr_valor    => vr_calc       --> Valor Calculado
                                           ,pr_nrdigito => vr_digito --> Digito Verificador
                                           ,pr_retorno  => vr_retorno);  --> Retorno digito correto
      ELSE
        /*** Verificacao do digito no modulo 11 ***/
        CXON0000.pc_calc_digito_titulo_mod11 (pr_valor      => vr_calc        --> Valor Calculado
                                             ,pr_nro_digito => vr_digito  --> Digito verificador
                                             ,pr_retorno    => vr_retorno);   --> Retorno digito correto
      END IF;

      --Se ocorreu erro na validacao
      IF NOT vr_retorno THEN
        --Criar Erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 8
                             ,pr_dsc_erro => NULL
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 8;
          vr_dscritic:= NULL;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      /* validacoes relativas aos convenios SICREDI */
      IF rw_crapcon.tparrecd = 1 THEN
        CXON0014.pc_validacoes_sicredi (pr_cdcooper      => pr_cdcooper      --Codigo Cooperativa
                                       ,pr_cod_agencia   => pr_cod_agencia   --Codigo Agencia
                                       ,pr_nrdconta      => pr_nrdconta      --Numero da Conta
                                       ,pr_idseqttl      => pr_idseqttl      --Sequencial Titular
                                       ,pr_nro_caixa     => pr_nro_caixa     --Numero Caixa
                                       ,pr_codigo_barras => pr_codigo_barras --Codigo barras
                                       ,pr_idagenda      => vr_idagenda      --Identificador Agendamento
                                       ,pr_flgpgag       => vr_flgpgag       --Indicador Pag agendado
                                       ,pr_cdempcon      => rw_crapcon.cdempcon --Codigo Empresa Convenio
                                       ,pr_cdsegmto      => rw_crapcon.cdsegmto --Codigo Segmento Convenio
                                       ,pr_cdcritic      => vr_cdcritic      --Codigo do erro
                                       ,pr_dscritic      => vr_dscritic);    --Descricao do erro
        -- Se houver critica devera retorna-la
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Criar Erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cdcritic
                               ,pr_dsc_erro => vr_dscritic
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic_aux
                               ,pr_dscritic => vr_dscritic_aux);
          IF vr_cdcritic_aux IS NOT NULL OR
             vr_dscritic_aux IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
          ELSE
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      --> Bancoob
      ELSIF rw_crapcon.tparrecd = 2 THEN
        PAGA0003.pc_validacoes_bancoob
                              (pr_cdcooper => pr_cdcooper           -- Codigo Cooperativa
                              ,pr_cdagenci => pr_cod_agencia        -- Agencia do Associado
                              ,pr_nrdcaixa => pr_nro_caixa          -- Numero caixa
                              ,pr_nrdconta => pr_nrdconta           -- Numero da conta
                              ,pr_idseqttl => pr_idseqttl           -- Identificador Sequencial titulo
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt   -- Data Movimento
                              ,pr_cdbarras => pr_codigo_barras      -- Codigo de barras
                              ,pr_cdempcon => rw_crapcon.cdempcon   -- Codigo Empresa Convenio
                              ,pr_cdsegmto => rw_crapcon.cdsegmto   -- Codigo Segmento Convenio
                              ,pr_idagenda => vr_idagenda           -- Indicador se é agendamento (1 – Nesta Data / 2 – Agendamento)
                              ,pr_flgpgag  => vr_flgpgag            -- Indicador Pagto agendamento
                              ---- OUT ----
                              ,pr_cdcritic => vr_cdcritic           -- Retorno codigo de critica
                              ,pr_dscritic => vr_dscritic);         -- Retorno de descrição Critica


        -- Se houver critica devera retorna-la
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Criar Erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cdcritic
                               ,pr_dsc_erro => vr_dscritic
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic_aux
                               ,pr_dscritic => vr_dscritic_aux);
          IF vr_cdcritic_aux IS NOT NULL OR
             vr_dscritic_aux IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            --Levantar Excecao
            RAISE vr_exc_erro;
      END IF;
        END IF;
      END IF;

      /* CASA FELIZ */
      IF rw_crapcon.cdempcon = 8359 AND rw_crapcon.cdsegmto = 6 THEN
        /* Nao permitir faturas da promocao antiga (menor que 20/10/2006) */
        IF  To_Number(SUBSTR(pr_codigo_barras,24,8)) <= 20061020  THEN
          --Criar Erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 0
                               ,pr_dsc_erro => 'Esta promocao nao eh mais valida!'
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Esta promocao nao eh mais valida!';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END IF;

      -- Montar a chave de acesso para buscar os dias de tolerando do convenio
      -- e identificar se o Convenio pode ser pago vencido
      vr_cdacesso:= 'VALIDA_PAGTO_' ||
                    to_char(rw_crapcon.cdempcon) || '_' ||
                    to_char(rw_crapcon.cdsegmto);

      -- Buscar os dias de tolerancia
      OPEN cr_crapprm_dias_tolera(pr_cdacesso => vr_cdacesso);
      FETCH cr_crapprm_dias_tolera INTO vr_qtdias_tolera;

      -- Identifica se existe a chave para validar o vencimento do convenio
      -- Validar se fatura esta vencida
      IF cr_crapprm_dias_tolera%FOUND THEN

        -- Apenas fecha o cursor
        CLOSE cr_crapprm_dias_tolera;

        --Data movimento anterior
        vr_dtmvtoan:= To_Char(rw_crapdat.dtmvtoan - vr_qtdias_tolera,'YYYYMMDD');
        IF To_Number(SUBSTR(pr_codigo_barras,20,8)) <= To_Number(vr_dtmvtoan) THEN
          --Criar Erro
          IF pr_cod_agencia IN (90,91) THEN
            vr_dsc_erro := 'Não é possível efetuar esta operação pois a fatura está vencida.';
          ELSE
            vr_dsc_erro := 'Nao eh possivel efetuar esta operacao pois a fatura esta vencida.';
          END IF;

          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 0
                               ,pr_dsc_erro => vr_dsc_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= vr_dsc_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;

      ELSE
        -- Como essa chave nao existe, nao validamos o vencimento
        -- Apenas fecha o cursor
        CLOSE cr_crapprm_dias_tolera;
      END IF;

      /* Buscar Sequencial da fatura */
      CXON0014.pc_busca_sequencial_fatura(pr_cdhistor      => rw_crapcon.cdhistor  --Codigo historico
                                         ,pr_codigo_barras => pr_codigo_barras     --Codigo Barras
                                         ,pr_cdseqfat      => pr_cdseqfat          --Codigo Sequencial Fatura
                                         ,pr_cdcritic      => vr_cdcritic          --Codigo erro
                                         ,pr_dscritic      => vr_dscritic);        --Descricao erro
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Retornar valor fatura
      pr_vlfatura:= TO_NUMBER(SUBSTR(pr_codigo_barras,5,11)) / 100;

      --Retornar Digito Faturamento
      IF  rw_crapcon.cdhistor IN (644,307,348)  THEN
        pr_nrdigfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,43,02));
      ELSE
        pr_nrdigfat:= 0;
      END IF;

      /* Lote - 15000 --- Tipo 13 --- FATURAS ---*/
      vr_lote:= 15000 + pr_nro_caixa;

      --Selecionar lancamentos de fatura
      OPEN cr_craplft (pr_cdcooper => rw_crapcop.cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                      ,pr_cdagenci => pr_cod_agencia
                      ,pr_cdbccxlt => 11
                      ,pr_nrdolote => vr_lote
                      ,pr_cdseqfat => pr_cdseqfat);
      --Posicionar no proximo registro
      FETCH cr_craplft INTO rw_craplft;
      --Se encontrar
      IF cr_craplft%FOUND THEN
        --Fechar Cursor
        CLOSE cr_craplft;
        --Criar Erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 92
                             ,pr_dsc_erro => NULL
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 92;
          vr_dscritic:= NULL;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_craplft;


    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic := vr_cdcritic;
         pr_dscritic := vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic := 0;
         pr_dscritic := 'Erro ao processar rotina CXON0014.pc_retorna_valores_fatura. '||SQLERRM;
    END;
  END pc_retorna_valores_fatura;

  /* Procedure para gerar recibo darf */
  PROCEDURE pc_gera_recibo_darf (pr_cdcooper      IN INTEGER      --Codigo Cooperativa
                                ,pr_cod_agencia   IN INTEGER      --Codigo Agencia
                                ,pr_nro_caixa     IN INTEGER      --Numero Caixa
                                ,pr_cdempcon      IN INTEGER      --Codigo Empresa Convenio
                                ,pr_cdsegmto      IN INTEGER      --Codigo Segmento Convenio
                                ,pr_literal       IN VARCHAR2     --Literal Autenticacao
                                ,pr_registro      IN ROWID        --Registro Autenticacao
                                ,pr_craplft_rowid IN ROWID        --ROWID craplft
                                ,pr_literal_comp  OUT VARCHAR2    --Literal Autenticacao Comprovante
                                ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_recibo_darf             Antigo: dbo/b1crap14.p/gera-recibo-darf
  --  Sistema  : Procedure para gerar recibo DARF
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gerar recibo DARF

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Tipo de tabela de memoria para string
      TYPE typ_tab_literal IS TABLE OF VARCHAR2(48) INDEX BY PLS_INTEGER;
      --Tabela de memoria para guardar darf
      vr_tab_literal typ_tab_literal;
      --Selecionar lancamento fatura
      CURSOR cr_craplft (pr_rowid IN ROWID) IS
        SELECT craplft.cdbarras
              ,craplft.cdseqfat
              ,craplft.vllanmto
              ,craplft.vlrjuros
              ,craplft.vlrmulta
        FROM craplft
        WHERE craplft.ROWID = pr_rowid;
      rw_craplft cr_craplft%ROWTYPE;
      --Variaveis Locais
      vr_iLnAut   INTEGER;
      vr_tpdarf   INTEGER;
      vr_cdseqfat VARCHAR2(100);
      --Variaveis erro
      vr_cod_erro INTEGER;
      vr_des_erro VARCHAR2(1000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Se a cooperativa origem nao existir
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        pr_cdcritic:= 0;
        pr_dscritic:= 'Cooperativa nao cadastrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      --Selecionar lancamento fatura
      OPEN cr_craplft (pr_rowid => pr_craplft_rowid);
      --Posicionar no proximo registro
      FETCH cr_craplft INTO rw_craplft;
      --Se nao encontrar
      IF cr_craplft%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_craplft;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Lancamento de fatura nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_craplft;

      --Sequencia de Faturamento
      vr_cdseqfat:= LPAD(TRIM(SUBSTR(rw_craplft.cdseqfat,1,17)),17,'0');

      --Verificar o Segmento
      IF pr_cdsegmto = 5 THEN
        --Verificar convenio
        CASE pr_cdempcon
          WHEN 064 THEN vr_tpdarf:= 1; /* DARFC0064 */
          WHEN 153 THEN vr_tpdarf:= 1; /* DARFC0153 */
          WHEN 154 THEN vr_tpdarf:= 2; /* DARFS0154 */
          WHEN 328 THEN vr_tpdarf:= 2; /* DAS - SIMPLES NACIONAL */
          WHEN 385 THEN vr_tpdarf:= 3; /* DARFC0385 */
          ELSE NULL;
        END CASE;
      END IF;

      --LImpar tabela memoria
      vr_tab_literal.DELETE;

      --Iniciar Linha
      vr_iLnAut:= 1;
      IF  vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= '        COMPROVANTE DE PAGAMENTO DE DAS         ';
      ELSE
        vr_tab_literal(vr_iLnAut):= '          COMPROVANTE DE PAGAMENTO DE           ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= '               SIMPLES NACIONAL                 ';
      ELSE
        vr_tab_literal(vr_iLnAut):= '               DARF/DARF SIMPLES                ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= '          AGENTE ARRECADADOR: CNC 748           ';
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= '         BANCO COOPERATIVO SICREDI S.A.         ';
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= '     DATA DO PAGAMENTO: '|| TO_CHAR(rw_crapdat.dtmvtocd,'DD/MM/YYYY') ||
                                  ' '||To_Char(SYSDATE,'HH24:MI:SS')||'     ';
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= LPad('-',48,'-');
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= '               CODIGO DE BARRAS                 ';
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= '            '|| SUBSTR(rw_craplft.cdbarras,1,11)|| ' '||
                                  SUBSTR(rw_craplft.cdbarras,12,11) || '             ';
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= '            '|| SUBSTR(rw_craplft.cdbarras,23,11)|| ' '||
                                  SUBSTR(rw_craplft.cdbarras,34,11) || '             ';
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      vr_tab_literal(vr_iLnAut):= LPad(' ',48,' ');
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= '    VALOR TOTAL (R$):      '||
                                    TO_CHAR((rw_craplft.vllanmto + rw_craplft.vlrjuros +
                                            rw_craplft.vlrmulta),'999g999g999g990d00')|| '  ';
      ELSE
        vr_tab_literal(vr_iLnAut):= '    N. DO DOCUMENTO:    '||
                                    gene0002.fn_mask(vr_cdseqfat,'99.99.99999.9999999-9')|| '   ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= LPad(' ',48,' ');
      ELSE
        vr_tab_literal(vr_iLnAut):= '    VALOR TOTAL (R$):      '||
                                    TO_CHAR((rw_craplft.vllanmto + rw_craplft.vlrjuros +
                                            rw_craplft.vlrmulta),'999g999g999g990d00')|| '  ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= '    MODELO APROVADO PELA SRF - ADE CONJUNTO     ';
      ELSE
        vr_tab_literal(vr_iLnAut):= LPad('-',48,'-');
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= '            CORAT/COTEC N. 001/2006             ';
      ELSIF vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= '                  AUTENTICACAO                  ';
      ELSE
        vr_tab_literal(vr_iLnAut):= '    MODELO APROVADO PELA SRF - ADE CONJUNTO     ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= LPad('-',48,'-');
      ELSIF vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= SubStr(pr_literal,1,48);
      ELSE
        vr_tab_literal(vr_iLnAut):= '            CORAT/COTEC N. 001/2006             ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= '                  AUTENTICACAO                 ';
      ELSIF vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= SubStr(pr_literal,49);
      ELSE
        vr_tab_literal(vr_iLnAut):= LPad('-',48,'-');
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= SubStr(pr_literal,1,48);
      ELSIF vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= LPad('-',48,'-');
      ELSE
        vr_tab_literal(vr_iLnAut):= '                  AUTENTICACAO                 ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= SubStr(pr_literal,49);
      ELSIF vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= '      GUARDE ESTE COMPROVANTE JUNTO COM O       ';
      ELSE
        vr_tab_literal(vr_iLnAut):= SubStr(pr_literal,1,48);
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= LPad('-',48,'-');
      ELSIF vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= '            DAS - SIMPLES NACIONAL              ';
      ELSE
        vr_tab_literal(vr_iLnAut):= SubStr(pr_literal,49);
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= '      GUARDE ESTE COMPROVANTE JUNTO COM O       ';
      ELSIF vr_tpdarf = 2 THEN
        vr_tab_literal(vr_iLnAut):= LPad('_',48,'_');
      ELSE
        vr_tab_literal(vr_iLnAut):= LPad('-',48,'-');
      END IF;

      IF vr_tpdarf IN (1,3) THEN
        --Incrementar linha
        vr_iLnAut:= vr_iLnAut+1;
        IF  vr_tpdarf = 1 THEN
          vr_tab_literal(vr_iLnAut):= '               DARF/DARF SIMPLES                ';
        ELSE
          vr_tab_literal(vr_iLnAut):= '      GUARDE ESTE COMPROVANTE JUNTO COM O       ';
        END IF;
        --Incrementar linha
        vr_iLnAut:= vr_iLnAut+1;
        IF  vr_tpdarf = 1 THEN
          vr_tab_literal(vr_iLnAut):= LPad('_',48,'_');
        ELSE
          vr_tab_literal(vr_iLnAut):= '               DARF/DARF SIMPLES                ';
        END IF;
        IF vr_tpdarf = 3 THEN
          --Incrementar linha
          vr_iLnAut:= vr_iLnAut+1;
          vr_tab_literal(vr_iLnAut):= LPad('_',48,'_');
        END IF;
      END IF;

      --Incluir 7 linhas em branco
      FOR idx IN 1..7 LOOP
        --Incrementar linha
        vr_iLnAut:= vr_iLnAut+1;
        vr_tab_literal(vr_iLnAut):= LPad(' ',48,' ');
      END LOOP;

      --Inicializar Literal do comprocante
      pr_literal_comp:= '';
      --Concatenar literal retorno
      FOR idx IN 1..vr_iLnAut LOOP
        IF vr_tab_literal.EXISTS(idx) THEN
          pr_literal_comp:= pr_literal_comp || vr_tab_literal(idx);
        END IF;
      END LOOP;

      /* Autenticacao REC */
      OPEN cr_crapaut (pr_rowid => pr_registro);
      --Posicionar no proximo registro
      FETCH cr_crapaut INTO rw_crapaut;
      --Se nao encontrar
      IF cr_crapaut%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapaut;
        vr_cod_erro:= 0;
        vr_des_erro:= 'Erro Sistema - CRAPAUT nao Encontrado.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => pr_nro_caixa
                             ,pr_cod_erro => vr_cod_erro
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= vr_cod_erro;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      ELSE
      IF cr_crapaut%ISOPEN THEN
        CLOSE cr_crapaut;
        --Atualizar autenticacao
        BEGIN
          UPDATE crapaut SET crapaut.dslitera = pr_literal_comp
          WHERE crapaut.ROWID = rw_crapaut.ROWID;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela crapaut. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
     END IF;

    EXCEPTION
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao processar rotina CXON0014.pc_gera_recibo_darf. '||SQLERRM;
    END;
  END pc_gera_recibo_darf;


  /* Procedure para gerar as faturas */
  PROCEDURE pc_gera_faturas (pr_cdcooper      IN INTEGER      --Codigo Cooperativa
                            ,pr_nrdconta      IN INTEGER      --Numero da Conta
                            ,pr_idseqttl      IN INTEGER      --Sequencial Titular
                            ,pr_cod_operador  IN VARCHAR2     --Codigo Operador
                            ,pr_cod_agencia   IN INTEGER      --Codigo Agencia
                            ,pr_nro_caixa     IN INTEGER      --Numero Caixa
                            ,pr_cdbarras      IN VARCHAR2     --Codigo barras
                            ,pr_cdseqfat      IN NUMBER       --Sequencial faturamento
                            ,pr_vlfatura      IN NUMBER       --Valor Fatura
                            ,pr_nrdigfat      IN INTEGER      --Digito Faturamento
                            ,pr_valorinf      IN NUMBER       --Valor Informado
                            ,pr_cdcoptfn      IN INTEGER      --Cooperativa do terminal financeiro
                            ,pr_cdagetfn      IN INTEGER      --Agencia do terminal financeiro
                            ,pr_nrterfin      IN INTEGER      --Numero Terminal Financeiro
                            ,pr_tpcptdoc      IN craptit.tpcptdoc%TYPE DEFAULT 1-- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
                            ,pr_dsnomfon      IN VARCHAR2 DEFAULT ' ' -- Numero do Telefone
                            ,pr_identificador IN VARCHAR2 DEFAULT ' ' -- Identificador FGTS/DAE
                            ,pr_idanafrd      IN tbgen_analise_fraude.idanalise_fraude%TYPE DEFAULT NULL -- Identificador de analise de fraude
                            ,pr_histor        OUT INTEGER     --Codigo Historico
                            ,pr_pg            OUT BOOLEAN     --Indicador Pago
                            ,pr_docto         OUT NUMBER      --Numero Documento
                            ,pr_literal       OUT VARCHAR2    --Literal
                            ,pr_ult_sequencia OUT INTEGER     --Ultima Sequencia
                            ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                            ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_gera_faturas             Antigo: dbo/b1crap14.p/gera-faturas
  --  Sistema  : Procedure para gerar as faturas
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: 25/02/2019
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gerar as faturas
  --
  -- Alteração: 30/12/2014 - Ajuste na leitura da CRAPLOT, para reservar o registro(lock)
  --                         conforme no progress(Odirlei-AMcom)
  --
  --            25/06/2015 - Ajuste na criação do lote, para assim que inserir dar o commit
  --                         com pragma autonomos_transaction, para liberar o registro e minimizar
  --                         o tempo de lock da tabela lote(Odirlei-AMcom)
  --
  --            24/07/2015 - Incluido nvl nas verificações  = 0, para garantir a validação do campo
  --                         (Odirlei - AMcom)
  --
  --            28/07/2015 - Ajuste para testar se a tabela craplot esta lockada antes de realizar o update
  --                         assim evitando custo do banco para gerenciar lock(Odirlei-Amcom)
  --
  --             30/07/2015 - Alterado para não fazer o atualização do lote qnd for agencia = 90 Internet
  --                          nestes casos irá atualizar na paga0001, diminuindo tempo de lock da tabela (Odirlei-Amcom)
  --
  --             14/08/2015 - pc_gera_titulo_iptu e pc_gera_faturas -> inclusão do parametro pr_tpcptdoc, para identificacao do tipo de captura
  --                          (leitora ou manual(linha digitavel)) (Odirlei-AMcom)
  -- 
  --             03/09/2018 - Correção para remover lote (Jonata - Mouts).
  --
  --             29/11/2018 - Ajustado rotina pc_inseri_lote para utilizar a sequence igual a quando executado 
  --                          paralelismo, para que não ocorra em de utilizar o mesmo numero do nrseqdig(Debitador unico - Odirlei/AMcom ).           
  --
  --              25/02/2019 - Inclusão de novas validações no código de barras para DARF/DAS
  --                           (sctask0046009 - Adriano).
  --
  --              08/05/2019 - Aplicar critica da quantidade de dias para "data vencimento" e "periodo de apuração" para DARF 64 e 153.
  --                           Com isso, em caso de falhas na digitação pelo cooperado o sistema irá criticar.
  --                           (INC0014834 - Wagner - Sustentação).
  -- 
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Selecionar Convenio
      CURSOR cr_crapscn (pr_cdempcon IN crapscn.cdempcon%type
                        ,pr_cdsegmto IN crapscn.cdsegmto%type
                        ,pr_tipo     IN INTEGER) IS
        SELECT crapscn.cdsegmto
              ,crapscn.nrtolera
              ,crapscn.dsdiatol
              ,crapscn.cdempres
        FROM crapscn
        WHERE ((pr_tipo = 1 AND crapscn.cdempcon = pr_cdempcon) OR
               (pr_tipo = 2 AND crapscn.cdempco2 = pr_cdempcon)
              )
        AND   crapscn.cdsegmto = pr_cdsegmto
        AND   crapscn.dtencemp is null
        ORDER BY crapscn.progress_recid ASC;
      rw_crapscn cr_crapscn%ROWTYPE;
      --Selecionar Cadastro Convenios Sicredi
      CURSOR cr_crapstb (pr_cdtribut IN crapstb.cdtribut%type) IS
        SELECT crapstb.cdtribut
        FROM crapstb
        WHERE crapstb.cdtribut = pr_cdtribut;
      rw_crapstb cr_crapstb%ROWTYPE;
      --Selecionar informacoes lancamentos fatura
      CURSOR cr_craplft IS
        SELECT craplft.rowid
             ,craplft.nrseqdig
             ,craplft.cdhistor
             ,craplft.tpfatura
             ,craplft.cdempcon
             ,craplft.cdsegmto
             ,craplft.dtlimite
             ,craplft.cdtribut
             ,craplft.nrcpfcgc
             ,craplft.dtapurac
        FROM craplft;
      rw_craplft cr_craplft%ROWTYPE;
      --Variaveis Locais
      vr_nrdcaixa INTEGER;
      vr_inanocal INTEGER;
      vr_nro_lote INTEGER;
      vr_dtapurac DATE;
      vr_dtlimite DATE;
      vr_cdempres VARCHAR2(100);
      vr_nrdigito INTEGER;
      vr_flgachou BOOLEAN;
      vr_nrcpfcgc VARCHAR2(100);
      vr_registro ROWID;
      vr_nrseqdig craplcm.nrseqdig%TYPE :=0;
      vr_poslimit INTEGER;
   	  vr_dvadicio INTEGER;
      vr_flagdvok BOOLEAN:=FALSE;
      
      vr_cdempcon NUMBER;
      vr_nrinsemp VARCHAR2(20);
      vr_nrdocmto NUMBER;
      vr_nrrecolh NUMBER;
      vr_dtcompet DATE;
      vr_vldocmto NUMBER;
      vr_nrsqgrde NUMBER;

      --Tipo de registro de data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis erro
      vr_cod_erro INTEGER;
      vr_des_erro VARCHAR2(1000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;


      -- Procedimento para inserir o lote e não deixar tabela lockada
      PROCEDURE pc_insere_lote (pr_cdcooper IN craplot.cdcooper%TYPE,
                                pr_dtmvtolt IN craplot.dtmvtolt%TYPE,
                                pr_cdagenci IN craplot.cdagenci%TYPE,
                                pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                                pr_nrdolote IN craplot.nrdolote%TYPE,
                                pr_cdoperad IN craplot.cdoperad%TYPE,
                                pr_nrdcaixa IN craplot.nrdcaixa%TYPE,
                                pr_craplot  OUT cr_craplot%ROWTYPE,
                                pr_dscritic OUT VARCHAR2)IS

        -- Pragma - abre nova sessao para tratar a atualizacao
        PRAGMA AUTONOMOUS_TRANSACTION;

      BEGIN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot (pr_cdcooper  => pr_cdcooper,
                             pr_dtmvtolt  => pr_dtmvtolt,
                             pr_cdagenci  => pr_cdagenci,
                             pr_cdbccxlt  => pr_cdbccxlt,
                             pr_nrdolote  => pr_nrdolote);
            FETCH cr_craplot INTO rw_craplot;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot%ISOPEN THEN
                 CLOSE cr_craplot;
               END IF;
               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 pr_dscritic:= 'Registro de lote '||pr_nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar meio segundo seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF pr_dscritic IS NOT NULL THEN
          ROLLBACK;
          RETURN;
        END IF;

        IF cr_craplot%NOTFOUND THEN
          -- criar registros de lote na tabela
          INSERT INTO craplot
                  (craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote
                  ,craplot.tplotmov
                  ,craplot.cdoperad
                  ,craplot.cdhistor
                  ,craplot.nrdcaixa
                  ,craplot.cdopecxa)
          VALUES  (pr_cdcooper
                  ,pr_dtmvtolt
                  ,pr_cdagenci
                  ,pr_cdbccxlt
                  ,pr_nrdolote
                  ,13 -- craplot.tplotmov
                  ,pr_cdoperad
                  ,0
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.qtcompln
                      ,craplot.qtinfoln
                      ,craplot.vlcompcr
                      ,craplot.vlinfocr
                      ,craplot.ROWID
                 INTO  rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.qtcompln
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.vlcompcr
                      ,rw_craplot.vlinfocr
                      ,rw_craplot.rowid;
         
        END IF;

        CLOSE cr_craplot;

        -- retornar informações para o programa chamador
        pr_craplot := rw_craplot;

        COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          IF cr_craplot%ISOPEN THEN
            CLOSE cr_craplot;
          END IF;
          ROLLBACK;
          -- se ocorreu algum erro durante a criac?o
          pr_dscritic := 'Erro ao gravar craplot('|| pr_nrdolote||'): '||SQLERRM;
      END pc_insere_lote;

    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      /* Tratamento de erros para internet e TAA */
      IF pr_cod_agencia IN (90,91) THEN
        vr_nrdcaixa:= TO_NUMBER(pr_nrdconta||pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;

      --Se a cooperativa origem nao existir
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        pr_cdcritic:= 0;
        pr_dscritic:= 'Cooperativa nao cadastrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      --Eliminar Erro
      CXON0000.pc_elimina_erro (pr_cooper      => pr_cdcooper     --Codigo cooperativa
                               ,pr_cod_agencia => pr_cod_agencia  --Codigo agencia
                               ,pr_nro_caixa   => vr_nrdcaixa     --Numero Caixa
                               ,pr_cdcritic    => vr_cdcritic     --Codigo do erro
                               ,pr_dscritic    => vr_dscritic);   --Descricao do erro
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --verificar se informacoes estao zeradas
      IF nvl(pr_cod_agencia,0) = 0 OR nvl(pr_nro_caixa,0) = 0 OR nvl(pr_cod_operador, ' ') = ' ' THEN
        --Mensagem erro
        vr_cod_erro:= 0;
        vr_des_erro:= 'ERRO! PA ZERADO. FECHE O CAIXA E AVISE O CPD.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => vr_cod_erro
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= vr_cod_erro;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Verificar valor fatura zerado
      IF nvl(pr_vlfatura,0) = 0 AND nvl(pr_valorinf,0) = 0 THEN
        --Mensagem erro
        vr_cod_erro:= 0;
        vr_des_erro:= 'Valor deve ser informado.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => vr_cod_erro
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= vr_cod_erro;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      /* Lote - 15000 --- Tipo 13 --- FATURAS ---*/
      vr_nro_lote:= 15000 + pr_nro_caixa;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      /* Pega o nome do convenio */
      OPEN cr_crapcon (pr_cdcooper => pr_cdcooper
                      ,pr_cdempcon => TO_NUMBER(SUBSTR(pr_cdbarras,16,4))
                      ,pr_cdsegmto => TO_NUMBER(SUBSTR(pr_cdbarras,2,1)));
      --Posicionar no proximo registro
      FETCH cr_crapcon INTO rw_crapcon;
      --Se nao encontrar
      IF cr_crapcon%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcon;
        --Mensagem erro
        vr_cod_erro:= 0;
        vr_des_erro:= 'Empresa nao Conveniada.';
        --Criar erro
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => vr_cod_erro
                             ,pr_dsc_erro => vr_des_erro
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= vr_cod_erro;
          vr_dscritic:= vr_des_erro;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcon;
      --Se convenio Sicredi
      IF rw_crapcon.tparrecd = 1 THEN
        --Marcar como nao encontrado
        vr_flgachou:= FALSE;
        FOR idx IN 1..2 LOOP
          /* Procura cod. da empresa do convenio SICREDI em cada campo de Num. do Cod. Barras */
          OPEN cr_crapscn (pr_cdempcon  => rw_crapcon.cdempcon
                          ,pr_cdsegmto  => rw_crapcon.cdsegmto
                          ,pr_tipo      => idx);
          --Posicionar no proximo registro
          FETCH cr_crapscn INTO rw_crapscn;
          --Se nao encontrar
          IF cr_crapscn%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_crapscn;
          ELSE
            --Fechar Cursor
            CLOSE cr_crapscn;
            --Marcar que encontrou
            vr_flgachou:= TRUE;
            --Abandona loop
            EXIT;
          END IF;
        END LOOP;
        --Se nao encontrou
        IF NOT vr_flgachou THEN
          --Mensagem erro
          vr_cod_erro:= 0;
          vr_des_erro:= 'Falta registro de Conv. SICREDI.';
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= vr_cod_erro;
            vr_dscritic:= vr_des_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        /* Validacao para nao aceitar DARFs menor que R$10,00 */
        /* DAS - SIMPLES NACIONAL        */
        /* DARFC0064 - DARF PRETO EUROPA */
        /* DARFC0153 - DARF PRETO EUROPA */
        /* DARFS0154 - DARF SIMPLES      */
        /* DARFC0385 (DARF NUMERADO)     */
        IF rw_crapscn.cdempres IN ('K0','147','149','145','608') THEN
          
          IF pr_vlfatura < 10 THEN
            
            --Mensagem erro
            vr_cod_erro:= 0;
            vr_des_erro:= 'Pagamento deve ser maior ou igual a R$10,00.';
            --Criar erro
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => vr_cod_erro
                                 ,pr_dsc_erro => vr_des_erro
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
            ELSE
              vr_cdcritic:= vr_cod_erro;
              vr_dscritic:= vr_des_erro;
              --Levantar Excecao
              RAISE vr_exc_erro;
            END IF;
            
          END IF;
          
          /* Para DAS - SIMPLES NACIONAL e  DARFC0385 (DARF NUMERADO)
             deve ser realizado a validação dos digitos.*/
          IF rw_crapscn.cdempres IN ('K0','608') THEN
          
            pc_calcula_dv_numero_das(pr_numerdas => substr(pr_cdbarras,25,16)        --Codigo barras
                                    ,pr_dvnrodas => to_number(substr(pr_cdbarras,41,1)) --Utilizado para validação de dígito adicional de DAS
                                    ,pr_flagdvok => vr_flagdvok);
          
            --Se digito não estiver correto
            IF NOT vr_flagdvok THEN
              
              vr_cdcritic := 8;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); 
              --Levantar Excecao
              RAISE vr_exc_erro;
              
            END IF;
            
            FOR idx IN 42..44 LOOP

              vr_poslimit := idx;

              vr_dvadicio := TO_NUMBER(SUBSTR(pr_cdbarras, vr_poslimit, 1));
              
              pc_calcula_dv_adicional (pr_cdbarras => pr_cdbarras     --Codigo barras
                                      ,pr_poslimit => vr_poslimit - 5 --Utilizado para validação de dígito adicional de DAS
                                      ,pr_nrdigito => vr_dvadicio     --Numero a ser calculado
                                      ,pr_flagdvok => vr_flagdvok);   --Digito correto sim/nao
                                    
              IF NOT vr_flagdvok THEN
                
                vr_cdcritic:= 8;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                          
                --Levantar Excecao
                RAISE vr_exc_erro;
                
              END IF;

            END LOOP;
            
          END IF;
          
        END IF;
                
      END IF;

      vr_nrseqdig := fn_sequence('CRAPLOT'
                                ,'NRSEQDIG'
                                ,''||rw_crapcop.cdcooper||';'
                                   ||to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')||';'
                                   ||pr_cod_agencia||';'
                                   ||11||';'
                                   ||vr_nro_lote);    
      /*[PROJETO LIGEIRINHO] Esta função retorna verdadeiro, quando o processo foi iniciado pela rotina:
       PAGA0001., que é chamada na rotina PC_CRPS509. Tem por finalidade definir
       se grava na tabela CRAPLOT no momento em que esta rodando a esta rotina OU somente no final da execucação
       da PC_CRPS509, para evitar o erro de lock da tabela, pois esta gravando a agencia 90,91 ou 1 ao inves de gravar
       a agencia do cooperado*/

      if not paga0001.fn_exec_paralelo then
        -- Controlar criação de lote, com pragma
        pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                        pr_dtmvtolt => rw_crapdat.dtmvtocd,
                        pr_cdagenci => pr_cod_agencia,
                        pr_cdbccxlt => 11,
                        pr_nrdolote => vr_nro_lote,
                        pr_cdoperad => pr_cod_operador,
                        pr_nrdcaixa => pr_nro_caixa,
                        pr_craplot  => rw_craplot,
                        pr_dscritic => vr_dscritic);

        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

      else
        PAGA0001.pc_insere_lote_wrk (pr_cdcooper => rw_crapcop.cdcooper,
                                     pr_dtmvtolt => rw_crapdat.dtmvtocd,
                                     pr_cdagenci => pr_cod_agencia,
                                     pr_cdbccxlt => 11,
                                     pr_nrdolote => vr_nro_lote,
                                     pr_cdoperad => pr_cod_operador,
                                     pr_nrdcaixa => pr_nro_caixa,
                                     pr_tplotmov => null,
                                     pr_cdhistor => 0,
                                     pr_cdbccxpg => null,
                                     pr_nmrotina => 'CXON0014.PC_GERA_FATURAS');

        rw_craplot.dtmvtolt := rw_crapdat.dtmvtocd;
        rw_craplot.cdagenci := pr_cod_agencia;
        rw_craplot.cdbccxlt := 11;
        rw_craplot.nrdolote := vr_nro_lote;
        rw_craplot.cdoperad := pr_cod_operador;

            
      end if;
	      
      
      --Criar lancamento de fatura
      BEGIN
        INSERT INTO craplft
          (craplft.cdcooper
          ,craplft.nrdconta
          ,craplft.dtmvtolt
          ,craplft.cdagenci
          ,craplft.cdbccxlt
          ,craplft.nrdolote
          ,craplft.cdseqfat
          ,craplft.vllanmto
          ,craplft.cdhistor
          ,craplft.nrseqdig
          ,craplft.nrdigfat
          ,craplft.dtvencto
          ,craplft.cdbarras
          ,craplft.insitfat
          ,craplft.cdempcon
          ,craplft.cdsegmto
          ,craplft.cdcoptfn
          ,craplft.cdagetfn
          ,craplft.nrterfin
          ,craplft.tpcptdoc
          ,craplft.dsnomfon
          ,craplft.idanafrd
          ,craplft.idseqttl)
        VALUES
          (rw_crapcop.cdcooper
          ,pr_nrdconta
          ,rw_craplot.dtmvtolt
          ,rw_craplot.cdagenci
          ,rw_craplot.cdbccxlt
          ,rw_craplot.nrdolote
          ,pr_cdseqfat
          ,pr_vlfatura
          ,rw_crapcon.cdhistor
          ,Nvl(vr_nrseqdig,0)
          ,pr_nrdigfat
          ,rw_crapdat.dtmvtocd
          ,pr_cdbarras
          ,1
          ,rw_crapcon.cdempcon
          ,rw_crapcon.cdsegmto
          ,pr_cdcoptfn
          ,pr_cdagetfn
          ,pr_nrterfin
          ,pr_tpcptdoc
          ,pr_dsnomfon
          ,NULLIF(pr_idanafrd,0)            -- idanafrd
          ,pr_idseqttl)                     -- idseqttl
        RETURNING
           craplft.ROWID
          ,craplft.nrseqdig
          ,craplft.cdhistor
          ,craplft.tpfatura
        INTO
           rw_craplft.rowid
          ,rw_craplft.nrseqdig
          ,rw_craplft.cdhistor
          ,rw_craplft.tpfatura;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao inserir na tabela craplft. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;


      /* DARF PRETO EUROPA */
      IF rw_crapcon.cdempcon IN (64,153) AND rw_crapcon.cdsegmto = 5 THEN /* DARFC0064  ou DARFC0153*/
        /* Validacao Cd. Tributo */
        --Selecionar Cadastro Convenios Sicredi
        OPEN cr_crapstb (pr_cdtribut => TO_NUMBER(SUBSTR(pr_cdbarras,37,4)));
        --Posicionar no proximo registro
        FETCH cr_crapstb INTO rw_crapstb;
        --Se nao encontrar
        IF cr_crapstb%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapstb;
          --Mensagem erro
          vr_cod_erro:= 0;
          vr_des_erro:= 'Tributo nao cadastrado.';
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= vr_cod_erro;
            vr_dscritic:= vr_des_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapstb;
        
        /* Criticar quantidade de dias inválidos no código de barras - INICIO */
        -- Para a Data de Vencimento
        IF SUBSTR(pr_cdbarras,21,3) IS NOT NULL AND 
           (To_Number(SUBSTR(pr_cdbarras,21,3)) < 1 OR
            To_Number(SUBSTR(pr_cdbarras,21,3)) > 366) THEN
          --Mensagem erro
          vr_cod_erro:= 0;
          vr_des_erro:= 'Data do vecimento invalida.';
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= vr_cod_erro;
            vr_dscritic:= vr_des_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- Para o Período de Apuração
        IF SUBSTR(pr_cdbarras,42,3) IS NOT NULL AND 
           (To_Number(SUBSTR(pr_cdbarras,42,3)) < 1 OR
            To_Number(SUBSTR(pr_cdbarras,42,3)) > 366) THEN
          --Mensagem erro
          vr_cod_erro:= 0;
          vr_des_erro:= 'Periodo de apuracao invalido.';
          --Criar erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => vr_cod_erro
                               ,pr_dsc_erro => vr_des_erro
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= vr_cod_erro;
            vr_dscritic:= vr_des_erro;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        /* Criticar quantidade de dias inválidos no código de barras - FIM */
        
        /* Calculo da Data Limite */
        --Retornar ano do codigo barras
        vr_inanocal:= CXON0014.fn_ret_ano_barras_darf(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,20,1)));
        --Retornar data dias
        vr_dtlimite:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_cdbarras,21,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano
        /* Calculo do Periodo de Apuracao */
        --Retornar ano do codigo barras
        vr_inanocal:= CXON0014.fn_ret_ano_barras_darf(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,41,1)));
        --Retornar data dias
        vr_dtapurac:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_cdbarras,42,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano

        --Determinar numero cpfcgc
        /* Grava CPF ou CNPJ dependendo da posicao 24 */
        IF  TO_NUMBER(SUBSTR(pr_cdbarras,24,1)) = 0 THEN
          vr_nrcpfcgc:= SUBSTR(pr_cdbarras,25,11);
        ELSIF TO_NUMBER(SUBSTR(pr_cdbarras,24,1)) = 1 THEN
          --Buscar o digito do cnpj
          vr_nrdigito:= GENE0005.fn_retorna_digito_cnpj(pr_nrcalcul => TO_NUMBER(SUBSTR(pr_cdbarras,25,12)));
          vr_nrcpfcgc:= SUBSTR(pr_cdbarras,25,12) || GENE0002.fn_mask(vr_nrdigito,'99');
        END IF;
        --Atualizar lancamento fatura
        BEGIN
          UPDATE craplft SET craplft.tpfatura = 2  /* ( Darf / ARF) */
                            ,craplft.dtlimite = vr_dtlimite
                            ,craplft.dtapurac = vr_dtapurac
                            ,craplft.cdtribut = SUBSTR(pr_cdbarras,37,4)
                            ,craplft.nrcpfcgc = vr_nrcpfcgc
          WHERE craplft.ROWID = rw_craplft.ROWID
          RETURNING
               craplft.tpfatura
              ,craplft.cdempcon
              ,craplft.cdsegmto
              ,craplft.nrseqdig
              ,craplft.cdhistor
          INTO rw_craplft.tpfatura
              ,rw_craplft.cdempcon
              ,rw_craplft.cdsegmto
              ,rw_craplft.nrseqdig
              ,rw_craplft.cdhistor;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplft. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;

      /* DARF SIMPLES */
      IF rw_crapcon.cdempcon = 154 AND rw_crapcon.cdsegmto = 5 THEN /* DARFS0154 */
        --Retornar ano do codigo barras
        vr_inanocal:= CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,20,1))
                                                      ,pr_darfndas => FALSE);
        --Retornar data dias
        vr_dtapurac:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_cdbarras,21,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano
        --Atualizar lancamento fatura
        BEGIN
          UPDATE craplft SET  craplft.dtapurac = vr_dtapurac
                             ,craplft.nrcpfcgc = SUBSTR(pr_cdbarras,24,8)
                             ,craplft.vlrecbru = TO_NUMBER(SUBSTR(pr_cdbarras,32,9))
                             ,craplft.vlpercen = TO_NUMBER(SUBSTR(pr_cdbarras,41,4))
                             ,craplft.tpfatura = 2  /* ( Darf ¿ ARF) */
          WHERE craplft.ROWID = rw_craplft.ROWID
          RETURNING
               craplft.tpfatura
              ,craplft.cdempcon
              ,craplft.cdsegmto
              ,craplft.nrseqdig
              ,craplft.cdhistor
          INTO rw_craplft.tpfatura
              ,rw_craplft.cdempcon
              ,rw_craplft.cdsegmto
              ,rw_craplft.nrseqdig
              ,rw_craplft.cdhistor;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplft. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;

      /* DARFC0385 (DARF NUMERADO) */
      IF rw_crapcon.cdempcon = 385 AND rw_crapcon.cdsegmto = 5 THEN
        --Retornar ano do codigo barras
        vr_inanocal:= CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,20,2))
                                                      ,pr_darfndas => TRUE);
        --Retornar data dias
        vr_dtlimite:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_cdbarras,22,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano
        --Atualizar lancamento fatura
        BEGIN
          UPDATE craplft SET  craplft.dtlimite = vr_dtlimite
                             ,craplft.tpfatura = 2  /* ( Darf ¿ ARF) */
          WHERE craplft.ROWID = rw_craplft.ROWID
          RETURNING craplft.tpfatura
                   ,craplft.cdempcon
                   ,craplft.cdsegmto
                   ,craplft.nrseqdig
                   ,craplft.cdhistor
          INTO rw_craplft.tpfatura
              ,rw_craplft.cdempcon
              ,rw_craplft.cdsegmto
              ,rw_craplft.nrseqdig
              ,rw_craplft.cdhistor;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplft. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;

      /* DAS - SIMPLES NACIONAL */
      IF rw_crapcon.cdempcon = 328 AND rw_crapcon.cdsegmto = 5 THEN
        --Retornar ano do codigo barras
        vr_inanocal:= CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,20,2))
                                                      ,pr_darfndas => TRUE);
        --Retornar data dias
        vr_dtlimite:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_cdbarras,22,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano
        --Atualizar lancamento fatura
        BEGIN
          UPDATE craplft SET  craplft.dtlimite = vr_dtlimite
                             ,craplft.tpfatura = 1
          WHERE craplft.ROWID = rw_craplft.ROWID
          RETURNING
               craplft.tpfatura
              ,craplft.cdempcon
              ,craplft.cdsegmto
              ,craplft.nrseqdig
              ,craplft.cdhistor
          INTO rw_craplft.tpfatura
              ,rw_craplft.cdempcon
              ,rw_craplft.cdsegmto
              ,rw_craplft.nrseqdig
              ,rw_craplft.cdhistor;
        EXCEPTION
          WHEN Others THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplft. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;

      --> DAE/FGTS
      IF rw_crapcon.cdempcon IN(0432, --> DAE
                                0178,0179,0180,0181,0239,0240,0451) AND --> FGTS
         rw_crapcon.cdsegmto = 5 THEN

        paga0003.pc_extrai_cdbarras_fgts_dae
                                   ( pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                                    ,pr_cdbarras => pr_cdbarras --> Codigo de barras

                                    ---- OUT ----
                                    ,pr_cdempcon => vr_cdempcon --> Retorna numero da empresa conveniada
                                    ,pr_nrinsemp => vr_nrinsemp --> Numero de inscricao da empresa(CNPJ/CEI/CPF)
                                    ,pr_nrdocmto => vr_nrdocmto --> Numero do documento
                                    ,pr_nrrecolh => vr_nrrecolh --> Numero identificado de recolhimento
                                    ,pr_dtcompet => vr_dtcompet --> Data da competencia
                                    ,pr_dtvencto => vr_dtlimite --> Data de vencimento/validade
                                    ,pr_vldocmto => vr_vldocmto --> Valor do documento
                                    ,pr_nrsqgrde => vr_nrsqgrde --> Sequencial da GRDE

                                    ,pr_dscritic => vr_dscritic); --> Critica

        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        IF rw_crapcon.cdempcon IN(0432) THEN --> DAE
          --Atualizar lancamento fatura
          BEGIN
            UPDATE craplft
               SET craplft.tpfatura = 4 -- DAE
                  ,craplft.dtlimite = vr_dtlimite
                  ,craplft.cdtribut = SUBSTR(pr_cdbarras,16,4)
                  ,craplft.nrrefere = nvl(pr_identificador,' ')
            WHERE craplft.ROWID = rw_craplft.ROWID
            RETURNING
                 craplft.tpfatura
                ,craplft.dtlimite
                ,craplft.cdtribut
            INTO rw_craplft.tpfatura
                ,rw_craplft.dtlimite
                ,rw_craplft.cdtribut;
          EXCEPTION
            WHEN Others THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar tabela craplft(DAE). '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;

        --> FGTS
        ELSE
          --Atualizar lancamento fatura
          BEGIN
            UPDATE craplft
               SET craplft.tpfatura = 3 --FGTS
                  ,craplft.dtlimite = vr_dtlimite
                  ,craplft.dtapurac = vr_dtcompet
                  ,craplft.cdtribut = SUBSTR(pr_cdbarras,16,4)
                  ,craplft.nrcpfcgc = vr_nrinsemp
                  ,craplft.nrrefere = nvl(pr_identificador,' ')
            WHERE craplft.ROWID = rw_craplft.ROWID

            RETURNING
                 craplft.tpfatura
                ,craplft.dtlimite
                ,craplft.dtapurac
                ,craplft.cdtribut
                ,craplft.nrcpfcgc
            INTO rw_craplft.tpfatura
                ,rw_craplft.dtlimite
                ,rw_craplft.dtapurac
                ,rw_craplft.cdtribut
                ,rw_craplft.nrcpfcgc;
          EXCEPTION
            WHEN Others THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar tabela craplft(FGTS). '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;

      END IF;
      END IF; --> Fim DAE/FGTS


      /* DARF PRETO EUROPA - DARFC0064 */
      /* DARF PRETO EUROPA - DARFC0153 */
      /* DARFC0385 (DARF NUMERADO) */
      /* DARF SIMPLES - DARFS0154 */
      IF rw_craplft.tpfatura = 1 OR
        (rw_craplft.cdempcon IN (64,153,385,154) AND rw_craplft.cdsegmto= 5) THEN
        --Se existe crapscn
        IF vr_flgachou THEN
          vr_cdempres:= rw_crapscn.cdempres;
        END IF;
      ELSE
        vr_cdempres:= NULL;
      END IF;
      --Retorna Parametros
      pr_pg:= FALSE;
      pr_docto:= rw_craplft.nrseqdig;
      pr_histor:= rw_craplft.cdhistor;

      /* Grava uma autenticacao para o debido da conta */
      CXON0000.pc_grava_autenticacao_internet (pr_cooper       => pr_cdcooper          --Codigo Cooperativa
                                              ,pr_nrdconta     => pr_nrdconta          --Numero da Conta
                                              ,pr_idseqttl     => pr_idseqttl          --Sequencial do titular
                                              ,pr_cod_agencia  => pr_cod_agencia       --Codigo Agencia
                                              ,pr_nro_caixa    => pr_nro_caixa         --Numero do caixa
                                              ,pr_cod_operador => pr_cod_operador      --Codigo Operador
                                              ,pr_valor        => pr_vlfatura          --Valor da transacao
                                              ,pr_docto        => pr_docto             --Numero documento
                                              ,pr_operacao     => pr_pg                --Indicador Operacao Debito
                                              ,pr_status       => '1'                  --Status da Operacao - Online
                                              ,pr_estorno      => FALSE                --Indicador Estorno
                                              ,pr_histor       => pr_histor            --Historico Debito
                                              ,pr_data_off     => NULL                 --Data Transacao
                                              ,pr_sequen_off   => 0                    --Sequencia
                                              ,pr_hora_off     => 0                    --Hora transacao
                                              ,pr_seq_aut_off  => 0                    --Sequencia automatica
                                              ,pr_cdempres     => vr_cdempres          --Descricao Observacao
                                              ,pr_literal      => pr_literal           --Descricao literal lcm
                                              ,pr_sequencia    => pr_ult_sequencia     --Sequencia
                                              ,pr_registro     => vr_registro          --ROWID do registro debito
                                              ,pr_cdcritic     => vr_cdcritic          --C¿digo do erro
                                              ,pr_dscritic     => vr_dscritic);        --Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na autenticacao do pagamento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se empresa estiver preenchida
      IF vr_cdempres IS NOT NULL THEN
        --Gerar DARF
        CXON0014.pc_gera_recibo_darf (pr_cdcooper      => pr_cdcooper         --Codigo Cooperativa
                                     ,pr_cod_agencia   => pr_cod_agencia      --Codigo Agencia
                                     ,pr_nro_caixa     => pr_nro_caixa        --Numero Caixa
                                     ,pr_cdempcon      => rw_crapcon.cdempcon --Codigo Empresa Convenio
                                     ,pr_cdsegmto      => rw_crapcon.cdsegmto --Codigo Segmento Convenio
                                     ,pr_literal       => pr_literal          --Literal Autenticacao
                                     ,pr_registro      => vr_registro         --Registro Autenticacao
                                     ,pr_craplft_rowid => rw_craplft.rowid    --ROWID craplft
                                     ,pr_literal_comp  => pr_literal          --Literal Autenticacao Comprovante
                                     ,pr_cdcritic      => vr_cdcritic         --Codigo do erro
                                     ,pr_dscritic      => vr_dscritic);       --Descricao do erro
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      /* Atualiza sequencia Autenticacao */
      BEGIN
        UPDATE craplft SET  craplft.nrautdoc = pr_ult_sequencia
        WHERE craplft.ROWID = rw_craplft.rowid;
      EXCEPTION
        WHEN Others THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao atualizar tabela craplft. '||sqlerrm;
          --Levantar Excecao
          RAISE vr_exc_erro;
      END;


            EXCEPTION
      WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;

         --Criar registro de erro -- para garantir que todos os erros
         -- estejam na tabela
         CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);

       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro ao processar rotina CXON0014.pc_gera_faturas. '||SQLERRM;

         --Criar registro de erro -- para garantir que todos os erros
         -- estejam na tabela
         CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => pr_cod_agencia
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cod_erro => pr_cdcritic
                              ,pr_dsc_erro => pr_dscritic
                              ,pr_flg_erro => TRUE
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
    END;
  END pc_gera_faturas;

  /* Procedure para calcular Data de Vencimento */
  PROCEDURE pc_calcula_data_vencimento (pr_dtmvtolt     IN DATE          --Data Movimento
                                       ,pr_de_campo     IN INTEGER       --Fator
                                       ,pr_dtvencto     OUT DATE         --Sequencial do titular
                                       ,pr_cdcritic     OUT INTEGER      --Código do erro
                                       ,pr_dscritic     OUT VARCHAR2) IS --Descricao do erro
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calcula_data_vencimento    Antigo: dbo/b2crap14.p/calcula_data_vencimento
  --  Sistema  : Procedure para calcular data de vencimento
  --  Sigla    : CRED
  --  Autor    : Daniel Zimmermann
  --  Data     : Julho/2014.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para calcular data de vencimento

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis Locais
      vr_fatordia INTEGER;
      vr_fator    INTEGER;
      vr_dtvencto DATE;

      vr_situacao INTEGER;
      vr_contador INTEGER;

      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
    BEGIN
      -- 0 - Fora Ranger
      -- 1 - A Vencer
      -- 2 - Vencida
      vr_situacao := 0;

      -- Calcular Fator do Dia
      vr_fatordia := pr_dtmvtolt - to_date('07/10/1997','DD/MM/RRRR');

      IF vr_fatordia > 9999 THEN

        IF ( vr_fatordia MOD 9000 ) < 1000 THEN
            vr_fatordia := ( vr_fatordia MOD 9000 ) + 9000;
        ELSE
            vr_fatordia := ( vr_fatordia MOD 9000 );
        END IF;

      END IF;

      -- Verifica se esta A Vencer
      vr_fator    := vr_fatordia;
      vr_contador := 0;

      WHILE TRUE LOOP

        vr_contador := vr_contador + 1;

        IF vr_contador > 5500 THEN
          EXIT;
        END IF;

        IF pr_de_campo = vr_fator THEN
            vr_situacao := 1; -- A Vencer
            EXIT;
        END IF;

        IF vr_fator > 9999 THEN
            vr_fator := 1000;
        ELSE
            vr_fator := vr_fator + 1;
        END IF;

      END LOOP;

      -- Verifica se esta Vencido
      vr_fator := vr_fatordia - 1;

      IF vr_fator < 1000 THEN
        vr_fator := vr_fator + 9000;
      END IF;

      IF vr_situacao = 0 THEN

        vr_contador := 0;

        WHILE TRUE LOOP

          vr_contador := vr_contador + 1;

          IF vr_contador > 3000 THEN
            EXIT;
          END IF;

          IF pr_de_campo = vr_fator THEN
              vr_situacao := 2; -- Vencido
              EXIT;
          END IF;

          IF vr_fator < 1000 THEN
              vr_fator := vr_fator + 9000;
          ELSE
              vr_fator := vr_fator - 1;
          END IF;

        END LOOP;

      END IF;

      IF vr_situacao = 0  THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Boleto fora do ranger permitido!';
        RAISE vr_exc_erro;
      ELSE
        IF vr_situacao = 1 THEN  -- A Vencer
            IF vr_fatordia > pr_de_campo THEN
                vr_dtvencto := pr_dtmvtolt + ( pr_de_campo - 1000 + (9999 - vr_fatordia + 1 ) );
            ELSE
                vr_dtvencto := pr_dtmvtolt + ( pr_de_campo - vr_fatordia);
            END IF;
        ELSE -- Vencido
             IF vr_fatordia > pr_de_campo THEN
                vr_dtvencto := pr_dtmvtolt + ( pr_de_campo - vr_fatordia);
             ELSE
                vr_dtvencto := pr_dtmvtolt + ( pr_de_campo - vr_fatordia - 9000 );
             END IF;
        END IF;

      END IF;

      pr_dtvencto := vr_dtvencto;

    EXCEPTION
       WHEN vr_exc_saida THEN
         NULL;
       WHEN vr_exc_erro THEN
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0000.pc_consultar_data_vencimento. '||SQLERRM;
    END;
  END pc_calcula_data_vencimento;

  /* Procedure para identificar titulo cooperativa */
  PROCEDURE pc_identifica_titulo_coop2 (pr_cooper        IN INTEGER   --Codigo Cooperativa
                                      ,pr_nro_conta     IN INTEGER   --Numero Conta
                                      ,pr_idseqttl      IN INTEGER   --Sequencial do Titular
                                      ,pr_cod_agencia   IN INTEGER   --Codigo da Agencia
                                      ,pr_nro_caixa     IN INTEGER   --Numero Caixa
                                      ,pr_codbarras     IN VARCHAR2  --Codigo Barras
                                      ,pr_flgcritica    IN BOOLEAN   --Flag Critica
                                      ,pr_nrdconta      OUT INTEGER  --Numero da Conta
                                      ,pr_insittit      OUT INTEGER  --Situacao Titulo
                                      ,pr_intitcop      OUT INTEGER  --Indicador titulo cooperativa
                                      ,pr_convenio      OUT NUMBER   --Numero Convenio
                                      ,pr_bloqueto      OUT NUMBER   --Numero Boleto
                                      ,pr_contaconve    OUT INTEGER  --Conta do Convenio
                                      ,pr_cdcritic      OUT INTEGER     --Codigo do erro
                                      ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_identifica_titulo_coop    Antigo: dbo/b2crap14.p/identifica-titulo-coop
  --  Sistema  : Procedure para identificar titulo cooperativa
  --  Sigla    : CXON
  --  Autor    : Rafael Cechet
  --  Data     : Agosto/2014.                   Ultima atualizacao: 07/04/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Nova Procedure para identificar titulo cooperativa
  --
  -- Alteracoes:
  --
  --               22/10/2014 - Retirado criticas 965 e 966 do convenio "IMPRESSO PELO SOFTWARE"
  --                            do Banco do Brasil - sem registro. (Rafael)
  --
  --               23/10/2014 - Inicializado parametros de saida que estavam nulos: pr_contaconve e
  --                            pr_nrdconta. (Rafael)
  --
  --               01/12/2014 - Ajustes ref. aos boletos da Incorporação. (Rafael)
  --
  --               24/07/2015 - Ajuste na verificação do campo de nrdconta = 0, pois o campo pode estar nulo
  --                            SD312105 (Odirlei-AMcom)
  --
  --               13/05/2016 - Inclusao da critica '980 - Convenio do cooperado bloqueado'
  --                            PRJ318 - Nova Plataforma de cobrança (Odirlei-AMcom)
  --
  --               07/04/2017 - Ajustado para quando nao encontrar CEB e TCO rejeitar o pagamento com a
  --                            mensagem "911 - Beneficiario nao cadastrado.", ao invés de aceitar o
  --                            pagamento como sendo "Liquidação Interbancária" (Douglas - Chamado 619274)
  --
  --               14/11/2017 - Quando o convenio existe na cooperativa porém não encontra a conta
  --                            que está no código de barras, então verificar se o convênio existe
  --                            em outra singular para tratar como  "Liquidação Interbancária"
  --                            (AJFink - Chamado 792324)
  --
  --               22/01/2019 - Gerar crítica 1462 quando boleto estiver bloqueado para pagamento (P352-Cechet)
  ---------------------------------------------------------------------------------------------------------------
    --
    procedure pc_convenio_outra_singular(pr_cdcooper in  crapceb.cdcooper%type
                                        ,pr_nrconven in  crapceb.nrconven%type
                                        ,pr_idcnvsng out number) is
      --
      --verifica se o convenio existe em outra singular do sistema Cecred
      cursor cr_crapcco(pr_cdcooper in crapceb.cdcooper%type
                       ,pr_nrconven in crapceb.nrconven%type) is
        select 1 idexiste
        from crapcco cco
        where cco.cdcooper <> pr_cdcooper
          and cco.nrconven = pr_nrconven;
      --
      vr_idexiste number(1);
      vr_idcnvsng number(1) := 0;
      --
    begin
      --
      open cr_crapcco(pr_cdcooper => pr_cdcooper
                     ,pr_nrconven => pr_nrconven);
      fetch cr_crapcco into vr_idexiste;
      if cr_crapcco%found then
        --
        vr_idcnvsng := 1;
        --
      end if;
      close cr_crapcco;
      --
      pr_idcnvsng := vr_idcnvsng;
      --
    end pc_convenio_outra_singular;
    --
  BEGIN
    DECLARE
      --Cursores Locais

      --Selecionar informacoes convenio cobranca
      CURSOR cr_crapcco (pr_cdcooper  IN crapcco.cdcooper%type
                        ,pr_nrconven  IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cddbanco
              ,crapcco.dsorgarq
              ,crapcco.flgutceb
              ,crapcco.nrconven
              ,crapcco.nrdctabb
              ,crapcco.flgregis
        FROM crapcco
        WHERE crapcco.cdcooper = pr_cdcooper
          AND crapcco.nrconven = pr_nrconven;
      rw_crapcco cr_crapcco%ROWTYPE;

      --Selecionar de qual cooperativa o convenio pertencia
      CURSOR cr_ceb_ant (pr_cdcooper IN crapcco.cdcooper%TYPE
                        ,pr_nrdconta IN crapceb.nrdconta%TYPE
                        ,pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT cco.cdcooper cco_cdcopant
              ,cco.dsorgarq
              ,tco.cdcooper tco_cdcooper
              ,tco.nrdconta tco_nrdconta
          FROM crapcco cco, crapceb ceb, craptco tco
         WHERE cco.cdcooper <> pr_cdcooper
           AND cco.nrconven = pr_nrconven
           AND ceb.cdcooper = cco.cdcooper
           AND ceb.nrdconta = pr_nrdconta
           AND ceb.nrconven = cco.nrconven
           AND tco.cdcopant = cco.cdcooper
           AND tco.nrctaant = ceb.nrdconta;
      rw_ceb_ant cr_ceb_ant%ROWTYPE;

      --Selecionar informacoes convenio 'IMPRESSO PELO SOFTWARE'
      CURSOR cr_cco_impresso (pr_nrconven IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cddbanco
              ,crapcco.dsorgarq
              ,crapcco.nrconven
              ,crapcco.nrdctabb
        FROM crapcco
        WHERE crapcco.cdcooper > 0
          AND crapcco.nrconven = pr_nrconven
          AND crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE';
      rw_cco_impresso cr_cco_impresso%ROWTYPE;

      --Selecionar cadastro emissao bloquetos - conv 6 digitos
      CURSOR cr_crapceb1 (pr_cdcooper IN crapceb.cdcooper%type
                         ,pr_nrconven IN crapceb.nrconven%type
                         ,pr_nrdconta IN crapceb.nrdconta%TYPE) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.nrdconta
              ,crapceb.flgcebhm
              ,crapceb.insitceb
        FROM crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
          AND  crapceb.nrconven = pr_nrconven
          AND  crapceb.nrdconta = pr_nrdconta;
      rw_crapceb1 cr_crapceb1%ROWTYPE;

      --Selecionar cadastro emissao bloquetos - conv 7 digitos
      CURSOR cr_crapceb2 (pr_cdcooper IN crapceb.cdcooper%type
                         ,pr_nrconven IN crapceb.nrconven%type
                         ,pr_nrcnvceb IN varchar2) IS
        SELECT crapceb.cdcooper
              ,crapceb.nrconven
              ,crapceb.nrcnvceb
              ,crapceb.nrdconta
        FROM crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
        AND    crapceb.nrconven = pr_nrconven
        AND    crapceb.nrcnvceb = pr_nrcnvceb;
      rw_crapceb2 cr_crapceb2%ROWTYPE;

      -- Verificar se cooperado entrou na cooperativa pela conta anterior
      CURSOR cr_craptco (pr_cdcooper IN craptco.cdcooper%type
                        ,pr_nrctaant IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.nrdconta
        FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.flgativo = pr_flgativo
        AND   craptco.tpctatrf <> pr_tpctatrf;
      rw_craptco cr_craptco%ROWTYPE;

      -- Verificar se cooperado saiu da cooperativa pela conta anterior
      CURSOR cr_craptco2(pr_cdcopant IN craptco.cdcopant%type
                        ,pr_nrctaant IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.nrdconta
        FROM craptco
        WHERE craptco.cdcopant = pr_cdcopant
        AND   craptco.nrctaant = pr_nrctaant
        AND   craptco.flgativo = pr_flgativo
        AND   craptco.tpctatrf <> pr_tpctatrf;
      rw_craptco2 cr_craptco2%ROWTYPE;

      -- Verificar se cooperado entrou na cooperativa pela conta nova
      CURSOR cr_craptco3 (pr_cdcooper IN craptco.cdcooper%type
                        ,pr_nrdconta IN craptco.nrctaant%TYPE
                        ,pr_flgativo IN craptco.flgativo%TYPE
                        ,pr_tpctatrf IN craptco.tpctatrf%type) IS
        SELECT craptco.nrdconta
        FROM craptco
        WHERE craptco.cdcooper = pr_cdcooper
        AND   craptco.nrdconta = pr_nrdconta
        AND   craptco.flgativo = pr_flgativo
        AND   craptco.tpctatrf <> pr_tpctatrf;
      rw_craptco3 cr_craptco3%ROWTYPE;


      --Selecionar informacoes cobranca
      CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_cdbandoc IN crapcob.cdbandoc%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdctabb IN crapcob.nrdctabb%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type
                        ,pr_nrdconta IN crapcob.nrdconta%type) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
              ,crapcob.nrdctabb
              ,crapcob.dtbloque
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.cdbandoc = pr_cdbandoc
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdconta = pr_nrdconta;
      rw_crapcob cr_crapcob%ROWTYPE;

      --Variaveis Locais
      vr_banco        INTEGER;
      vr_convenio     INTEGER;
      vr_convenio1    NUMBER;
      vr_convenio2    NUMBER;
      vr_bloqueto     NUMBER;
      vr_bloqueto1    NUMBER;
      vr_bloqueto2    NUMBER;
      vr_nrdconta     INTEGER;
      vr_nrdconta1    INTEGER;
      vr_nrconvceb    INTEGER;
      vr_nrdcaixa     INTEGER;
      vr_vltitulo     NUMBER;
      vr_nrnosnum     crapcob.nrnosnum%TYPE;
      --Registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis Erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis Excecao
      vr_exc_saida EXCEPTION;
      vr_exc_erro  EXCEPTION;
      vr_dtvencto DATE;
      vr_fv INTEGER;
      vr_idcnvsng number(1);

      PROCEDURE pc_checa_convenio_cooperado
                (pr_cdcooper IN crapcco.cdcooper%TYPE
                ,pr_nrconven IN crapcco.nrconven%TYPE
                ,pr_nrdconta IN crapceb.nrdconta%type) IS
      BEGIN
          --Selecionar cadastro emissao bloquetos
          OPEN cr_crapceb1 (pr_cdcooper => pr_cdcooper
                           ,pr_nrconven => pr_nrconven
                           ,pr_nrdconta => pr_nrdconta);
          --Posicionar no proximo registro
          FETCH cr_crapceb1 INTO rw_crapceb1;

          IF cr_crapceb1%NOTFOUND THEN
             IF cr_crapceb1%ISOPEN THEN
                CLOSE cr_crapceb1;
             END IF;
             --Criar erro - '966 - Cooperado sem convenio cadastrado'
             CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 966
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
             vr_cdcritic := 966;
             vr_dscritic := NULL;
             RAISE vr_exc_erro;
          ELSE
             IF cr_crapceb1%ISOPEN THEN
               CLOSE cr_crapceb1;
             END IF;

             IF rw_crapceb1.flgcebhm = 0 THEN
                --Criar erro - '965 - Convenio do cooperado nao homologado'
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cod_erro => 965
                                    ,pr_dsc_erro => NULL
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
                vr_cdcritic := 965;
                vr_dscritic := NULL;
                RAISE vr_exc_erro;
             END IF;
          END IF; -- cr_crapceb1%notfound
      END;

    BEGIN
      --Inicializar variaveis erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      /* Tratamento de erros para internet e TAA */
      IF pr_cod_agencia IN (90,91) THEN
        vr_nrdcaixa:= to_number(pr_nro_conta || pr_idseqttl);
      ELSE
        vr_nrdcaixa:= pr_nro_caixa;
      END IF;
      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cooper);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= 'Registro de cooperativa nao encontrado.';
        --Levantar Excecao
        RAISE vr_exc_saida;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n¿o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver¿ raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Quebrar o codigo de barras
      vr_banco:= TO_NUMBER(SUBSTR(pr_codbarras, 1, 3));
      vr_vltitulo:= TO_NUMBER(SUBSTR(pr_codbarras, 10, 10)) / 100;
      vr_convenio1:= TO_NUMBER(SUBSTR(pr_codbarras, 20, 6));  /* Conv 6 digitos */
      vr_convenio2:= TO_NUMBER(SUBSTR(pr_codbarras, 26, 7));  /* Conv 7 digitos */
      vr_nrconvceb:= TO_NUMBER(SUBSTR(pr_codbarras, 33, 4));  /* CEB */
      vr_nrdconta1:= TO_NUMBER(SUBSTR(pr_codbarras, 26, 8));  /* Conta 6 digitos */
      vr_bloqueto1:= TO_NUMBER(SUBSTR(pr_codbarras, 34, 9));  /* Boleto 6 digitos */
      vr_bloqueto2:= TO_NUMBER(SUBSTR(pr_codbarras, 37, 6));  /* Boleto 7 digitos */
      vr_nrnosnum := SUBSTR(pr_codbarras, 26, 17);  /* Nosso numero */
      pr_insittit:= 4;
      pr_intitcop:= 0;
      pr_convenio:= 0;
      pr_bloqueto:= 0;
      pr_contaconve:= 0;
      pr_nrdconta := 0;

      BEGIN
        vr_fv := to_number(substr(pr_codbarras, 6, 4));
        pc_calcula_data_vencimento(pr_dtmvtolt => rw_crapdat.dtmvtolt
                                 , pr_de_campo => vr_fv
                                 , pr_dtvencto => vr_dtvencto
                                 , pr_cdcritic => pr_cdcritic
                                 , pr_dscritic => pr_dscritic );

        EXCEPTION
           WHEN OTHERS THEN
               vr_dtvencto := rw_crapdat.dtmvtolt;
      END;

      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Eliminar Erro
      CXON0000.pc_elimina_erro (pr_cooper      => pr_cooper       --Codigo cooperativa
                               ,pr_cod_agencia => pr_cod_agencia  --Codigo agencia
                               ,pr_nro_caixa   => vr_nrdcaixa     --Numero Caixa
                               ,pr_cdcritic    => vr_cdcritic     --Codigo do erro
                               ,pr_dscritic    => vr_dscritic);   --Descricao do erro
      --Se Ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Se for banco brasil
      IF vr_banco = 1 THEN
         --Selecionar convenio 6 digitos
         OPEN cr_crapcco (pr_cdcooper  => rw_crapcop.cdcooper
                         ,pr_nrconven  => vr_convenio1);
         --Posicionar no primeiro registro
         FETCH cr_crapcco INTO rw_crapcco;
         --Se encontrou convenio 6 digitos
         IF cr_crapcco%FOUND THEN
            CLOSE cr_crapcco;

            -- se convenio BB com registro, entao Liq Interbancaria
            IF rw_crapcco.flgregis = 1 THEN
               RAISE vr_exc_saida;
            END IF;

            --Selecionar cadastro emissao bloquetos - conv 6 digitos
            OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_nrconven => rw_crapcco.nrconven
                             ,pr_nrdconta => vr_nrdconta1);
            --Posicionar no proximo registro
            FETCH cr_crapceb1 INTO rw_crapceb1;
            --Se Encontrou
            IF cr_crapceb1%FOUND THEN
               CLOSE cr_crapceb1;
               /* verificar se cooperado saiu da cooperativa */
               OPEN cr_craptco2( pr_cdcopant => rw_crapcop.cdcooper
                                ,pr_nrctaant => vr_nrdconta1
                                ,pr_flgativo => 1
                                ,pr_tpctatrf => 3);
               FETCH cr_craptco2 INTO rw_craptco2;
               /* se encontrou, entao cooperado saiu e eh Liq Interbancaria */
               IF cr_craptco2%FOUND THEN
                  CLOSE cr_craptco2;
                  RAISE vr_exc_saida;
               ELSE
                  vr_nrdconta := vr_nrdconta1;
                  vr_bloqueto := vr_bloqueto1;
                  vr_convenio := vr_convenio1;
                  IF cr_craptco2%ISOPEN THEN
                     CLOSE cr_craptco2;
                  END IF;
               END IF;
            ELSE
               IF cr_crapceb1%ISOPEN THEN
                  CLOSE cr_crapceb1;
               END IF;

               --Selecionar de qual cooperativa o convenio pertencia
               OPEN cr_ceb_ant(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_nrdconta => vr_nrdconta1
                              ,pr_nrconven => vr_convenio1);
               FETCH cr_ceb_ant INTO rw_ceb_ant;

               IF cr_ceb_ant%FOUND THEN
                 CLOSE cr_ceb_ant;
                 /* verificar se cooperado entrou na cooperativa */
                 IF rw_ceb_ant.tco_cdcooper = rw_crapcop.cdcooper THEN
                    --Selecionar cadastro emissao bloquetos - conv 6 digitos
                    OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_nrconven => rw_crapcco.nrconven
                                     ,pr_nrdconta => rw_ceb_ant.tco_nrdconta);
                    --Posicionar no proximo registro
                    FETCH cr_crapceb1 INTO rw_crapceb1;
                    IF cr_crapceb1%FOUND THEN
                       CLOSE cr_crapceb1;
                       vr_nrdconta := rw_ceb_ant.tco_nrdconta;
                       vr_bloqueto := vr_bloqueto1;
                       vr_convenio := vr_convenio1;
                    ELSE
                       IF cr_crapceb1%ISOPEN THEN
                          CLOSE cr_crapceb1;
                       END IF;
                       -- eh cooperado migrado e nao tem CEB, Liq Interbancaria
                       RAISE vr_exc_saida;
                    END IF;
                 ELSE
                    -- não eh cooperado migrado e nao tem CEB, Liq Interbancaria
                    RAISE vr_exc_saida;
                 END IF;
               ELSE
                 CLOSE cr_ceb_ant;
               END IF;
            END IF;
         ELSE
            -- verificar se eh convenio de 7 digitos
            IF cr_crapcco%ISOPEN THEN
               CLOSE cr_crapcco;
            END IF;

            --Selecionar convenio 7 digitos
            OPEN cr_crapcco (pr_cdcooper  => rw_crapcop.cdcooper
                            ,pr_nrconven  => vr_convenio2);
            --Posicionar no primeiro registro
            FETCH cr_crapcco INTO rw_crapcco;
            --Se encontrou convenio 7 digitos
            IF cr_crapcco%FOUND THEN
               CLOSE cr_crapcco;

               -- se convenio BB com registro, entao Liq Interbancaria
               IF rw_crapcco.flgregis = 1 THEN
                  RAISE vr_exc_saida;
               END IF;

               --Selecionar cadastro emissao bloquetos - conv 7 digitos
               OPEN cr_crapceb2 (pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_nrconven => rw_crapcco.nrconven
                                ,pr_nrcnvceb => vr_nrconvceb);
               --Posicionar no proximo registro
               FETCH cr_crapceb2 INTO rw_crapceb2;
               --Se Encontrou
               IF cr_crapceb2%FOUND THEN
                  CLOSE cr_crapceb2;
                  /* verificar se cooperado saiu da cooperativa */
                  OPEN cr_craptco2( pr_cdcopant => rw_crapcop.cdcooper
                                   ,pr_nrctaant => rw_crapceb2.nrdconta
                                   ,pr_flgativo => 1
                                   ,pr_tpctatrf => 3);
                  FETCH cr_craptco2 INTO rw_craptco2;
                  /* se encontrou, entao cooperado saiu e eh Liq Interbancaria */
                  IF cr_craptco2%FOUND THEN
                     CLOSE cr_craptco2;
                     RAISE vr_exc_saida;
                  ELSE
                     vr_nrdconta := rw_crapceb2.nrdconta;
                     vr_bloqueto := vr_bloqueto2;
                     vr_convenio := vr_convenio2;
                     IF cr_craptco2%ISOPEN THEN
                        CLOSE cr_craptco2;
                     END IF;
                  END IF;
               ELSE
                  IF cr_crapceb2%ISOPEN THEN
                     CLOSE cr_crapceb2;
                  END IF;

                  /* verificar se cooperado entrou na cooperativa pela conta nova*/
                  OPEN cr_craptco3( pr_cdcooper => rw_crapcop.cdcooper
                                   ,pr_nrdconta => rw_crapceb2.nrdconta
                                   ,pr_flgativo => 1
                                   ,pr_tpctatrf => 3);
                  FETCH cr_craptco3 INTO rw_craptco3;
                  /* se encontrou, entao cooperado saiu e eh Liq Interbancaria */
                  IF cr_craptco3%FOUND THEN
                     vr_nrdconta := rw_craptco3.nrdconta;
                     vr_bloqueto := vr_bloqueto2;
                     vr_convenio := vr_convenio2;
                     IF cr_craptco3%ISOPEN THEN
                        CLOSE cr_craptco3;
                     END IF;
                  ELSE
                     IF cr_craptco3%ISOPEN THEN
                        CLOSE cr_craptco3;
                     END IF;
                     -- nao tem CEB, entao eh Liq Interbancaria
                     RAISE vr_exc_saida;
                  END IF;
               END IF;
            ELSE
               -- convenio nao encontrado
               --Fechar Cursores
               IF cr_crapcco%ISOPEN THEN
                  CLOSE cr_crapcco;
               END IF;
               RAISE vr_exc_saida;
            END IF;
         END IF;

         --se nao encontrou bloqueto ou conta, sair
         IF nvl(vr_bloqueto,0) = 0 OR
            nvl(vr_nrdconta,0) = 0 THEN
            RAISE vr_exc_saida;
         END IF;

         --Selecionar informacoes cobranca
         OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_cdbandoc => rw_crapcco.cddbanco
                         ,pr_nrcnvcob => rw_crapcco.nrconven
                         ,pr_nrdctabb => rw_crapcco.nrdctabb
                         ,pr_nrdocmto => vr_bloqueto
                         ,pr_nrdconta => vr_nrdconta);
         --Posicionar no proximo registro
         FETCH cr_crapcob INTO rw_crapcob;
         --Se nao encontrar
         IF cr_crapcob%NOTFOUND THEN
           --Fechar Cursor
           CLOSE cr_crapcob;

           IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' THEN

              -- criar crapcob
              BEGIN
                INSERT INTO crapcob
                  (crapcob.cdcooper
                  ,crapcob.nrdconta
                  ,crapcob.cdbandoc
                  ,crapcob.nrdctabb
                  ,crapcob.nrcnvcob
                  ,crapcob.nrdocmto
                  ,crapcob.incobran
                  ,crapcob.dtretcob
                  ,crapcob.dtmvtolt
                  ,crapcob.vltitulo
                  ,crapcob.flgregis
                  ,crapcob.nrnosnum)
                VALUES
                  (rw_crapcop.cdcooper
                  ,vr_nrdconta
                  ,rw_crapcco.cddbanco
                  ,rw_crapcco.nrdctabb
                  ,rw_crapcco.nrconven
                  ,vr_bloqueto
                  ,0
                  ,rw_crapdat.dtmvtocd
                  ,rw_crapdat.dtmvtocd
                  ,vr_vltitulo
                  ,rw_crapcco.flgregis
                  ,vr_nrnosnum);

                 --Retornar valores
                 pr_insittit:= 2;
                 pr_intitcop:= 1;
                 pr_nrdconta:= vr_nrdconta;
                 pr_convenio:= rw_crapcco.nrconven;
                 pr_bloqueto:= vr_bloqueto;
                 pr_contaconve:= rw_crapcco.nrdctabb;

              EXCEPTION
                WHEN OTHERS THEN
                  vr_cdcritic:= 0;
                  vr_dscritic:= 'Erro ao criar boleto. '||SQLERRM;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
              END;
           ELSE
              IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                 -- verificar se o convenio migrado eh 'IMPRESSO PELO SOFTWARE'
                 OPEN cr_cco_impresso( pr_nrconven => rw_crapcco.nrconven );
                 FETCH cr_cco_impresso INTO rw_cco_impresso;
                 -- se o convenio existir, entao criar boleto crapcob
                 IF cr_cco_impresso%FOUND THEN

                    BEGIN
                      CLOSE cr_cco_impresso;
                      -- criar boleto crapcob
                      INSERT INTO crapcob
                        (crapcob.cdcooper
                        ,crapcob.nrdconta
                        ,crapcob.cdbandoc
                        ,crapcob.nrdctabb
                        ,crapcob.nrcnvcob
                        ,crapcob.nrdocmto
                        ,crapcob.incobran
                        ,crapcob.dtretcob
                        ,crapcob.dtmvtolt
                        ,crapcob.vltitulo
                        ,crapcob.flgregis
                        ,crapcob.nrnosnum)
                      VALUES
                        (rw_crapcop.cdcooper
                        ,vr_nrdconta
                        ,rw_crapcco.cddbanco
                        ,rw_crapcco.nrdctabb
                        ,rw_crapcco.nrconven
                        ,vr_bloqueto
                        ,0
                        ,rw_crapdat.dtmvtocd
                        ,rw_crapdat.dtmvtocd
                        ,vr_vltitulo
                        ,rw_crapcco.flgregis
                        ,vr_nrnosnum);

                       --Retornar valores
                       pr_insittit:= 2;
                       pr_intitcop:= 1;
                       pr_nrdconta:= vr_nrdconta;
                       pr_convenio:= rw_crapcco.nrconven;
                       pr_bloqueto:= vr_bloqueto;
                       pr_contaconve:= rw_crapcco.nrdctabb;

                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic:= 0;
                        vr_dscritic:= 'Erro ao criar boleto. '||SQLERRM;
                        --Levantar Excecao
                        RAISE vr_exc_erro;
                    END;
                 ELSE
                    IF cr_cco_impresso%ISOPEN THEN
                       CLOSE cr_cco_impresso;
                    END IF;
                    RAISE vr_exc_saida;
                 END IF; -- cco_impresso%found
              ELSE
                --Criar erro - '592 - Bloqueto nao encontrado'
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 592
                                     ,pr_dsc_erro => NULL
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 592;
                  vr_dscritic:= 'Bloqueto nao encontrado';
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;

              END IF; -- 'MIGRACAO,INCORPORACAO'

           END IF; -- 'IMPRESSO PELO SOFTWARE'

           -- fechar cursor
           IF cr_crapcob%ISOPEN THEN
              CLOSE cr_crapcob;
           END IF;
           --Selecionar informacoes cobranca
           OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_cdbandoc => rw_crapcco.cddbanco
                           ,pr_nrcnvcob => rw_crapcco.nrconven
                           ,pr_nrdctabb => rw_crapcco.nrdctabb
                           ,pr_nrdocmto => vr_bloqueto
                           ,pr_nrdconta => vr_nrdconta);
           --Posicionar no proximo registro
           FETCH cr_crapcob INTO rw_crapcob;
           CLOSE cr_crapcob;
         END IF; -- cr_crapcob%NOTFOUND

         --Selecionar informacoes associado
         OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper
                         ,pr_nrdconta => vr_nrdconta);
         --Posicionar no proximo registro
         FETCH cr_crapass INTO rw_crapass;
         CLOSE cr_crapass;

         --Valores de retorno
         pr_insittit:= 2;
         pr_intitcop:= 1;
         pr_nrdconta:= rw_crapcob.nrdconta;
         pr_convenio:= rw_crapcob.nrcnvcob;
         pr_bloqueto:= rw_crapcob.nrdocmto;
         pr_contaconve:= rw_crapcob.nrdctabb;

        /* excluido/pago e Baixado */
        IF (rw_crapcob.incobran IN (5,3) AND pr_flgcritica) THEN
           --Criar erro
           CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cod_erro => 594
                                ,pr_dsc_erro => NULL
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
             --Levantar Excecao
             RAISE vr_exc_erro;
           ELSE
             vr_cdcritic:= 594;
             vr_dscritic:= NULL;
             --Levantar Excecao
             RAISE vr_exc_erro;
           END IF;
        ELSIF rw_crapcob.dtretcob IS NULL AND pr_flgcritica THEN
           --Criar erro
           CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                ,pr_cdagenci => pr_cod_agencia
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cod_erro => 589
                                ,pr_dsc_erro => NULL
                                ,pr_flg_erro => TRUE
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
           --Se ocorreu erro
           IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              --Levantar Excecao
              RAISE vr_exc_erro;
           ELSE
              vr_cdcritic:= 589;
              vr_dscritic:= NULL;
              --Levantar Excecao
              RAISE vr_exc_erro;
           END IF;
        ELSE
            --Retornar valores
            pr_insittit:= 2;
            pr_intitcop:= 1;
            pr_nrdconta:= rw_crapcob.nrdconta;
            pr_convenio:= rw_crapcob.nrcnvcob;
            pr_bloqueto:= rw_crapcob.nrdocmto;
            pr_contaconve:= rw_crapcob.nrdctabb;
        END IF;

        --Fechar Cursor
        IF cr_crapcco%ISOPEN THEN
          CLOSE cr_crapcco;
        END IF;

        --Fechar Cursor
        IF cr_crapcob%ISOPEN THEN
          CLOSE cr_crapcob;
        END IF;

      ELSIF vr_banco = rw_crapcop.cdbcoctl  THEN /* CECRED */

        vr_nrdconta := vr_nrdconta1;
        vr_bloqueto := vr_bloqueto1;
        vr_convenio := vr_convenio1;

        --Selecionar informacoes cadastro cobranca
        OPEN cr_crapcco (pr_cdcooper  => rw_crapcop.cdcooper
                        ,pr_nrconven  => vr_convenio);
        --Posicionar no primeiro registro
        FETCH cr_crapcco INTO rw_crapcco;
        --Se encontrou
        IF cr_crapcco%FOUND THEN
          IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
             OPEN cr_ceb_ant(pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_nrdconta => vr_nrdconta
                            ,pr_nrconven => vr_convenio);
             FETCH cr_ceb_ant INTO rw_ceb_ant;

             IF cr_ceb_ant%FOUND THEN
               CLOSE cr_ceb_ant;
               IF rw_ceb_ant.tco_cdcooper = rw_crapcop.cdcooper THEN
                  vr_nrdconta := rw_ceb_ant.tco_nrdconta;
               ELSE
                  -- não eh cooperado migrado, Liq Interbancaria
                  --Fechar Cursores
                  RAISE vr_exc_saida;
               END IF;
             ELSE
               CLOSE cr_ceb_ant;
             END IF;
          END IF;

          --Selecionar cadastro emissao bloquetos
          OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                           ,pr_nrconven => rw_crapcco.nrconven
                           ,pr_nrdconta => vr_nrdconta);
          --Posicionar no proximo registro
          FETCH cr_crapceb1 INTO rw_crapceb1;
          IF cr_crapceb1%FOUND THEN
             CLOSE cr_crapceb1;

             /* verificar se cooperado saiu da cooperativa */
             OPEN cr_craptco2( pr_cdcopant => rw_crapcop.cdcooper
                              ,pr_nrctaant => vr_nrdconta
                              ,pr_flgativo => 1
                              ,pr_tpctatrf => 3);
             FETCH cr_craptco2 INTO rw_craptco2;
             /* se encontrou, entao cooperado saiu e eh Liq Interbancaria */
             IF cr_craptco2%FOUND THEN
                CLOSE cr_craptco2;
                RAISE vr_exc_saida;
             ELSE
                vr_nrdconta := rw_crapceb1.nrdconta;
             END IF;
          ELSE

             IF cr_crapceb1%ISOPEN THEN
                CLOSE cr_crapceb1;
             END IF;

             /* verificar se cooperado migrado entrou na cooperativa pela conta anterior */
             OPEN cr_craptco (pr_cdcooper => rw_crapcop.cdcooper
                             ,pr_nrctaant => vr_nrdconta
                             ,pr_flgativo => 1
                             ,pr_tpctatrf => 3);
             --Posicionar no proximo registro
             FETCH cr_craptco INTO rw_craptco;
             --Se nao encontrar
             IF cr_craptco%FOUND THEN
                CLOSE cr_craptco;
                --Selecionar cadastro emissao bloquetos - conv 6 digitos
                OPEN cr_crapceb1 (pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_nrconven => rw_crapcco.nrconven
                                 ,pr_nrdconta => rw_craptco.nrdconta);
                --Posicionar no proximo registro
                FETCH cr_crapceb1 INTO rw_crapceb1;
                IF cr_crapceb1%FOUND THEN
                   CLOSE cr_crapceb1;
                   vr_nrdconta := rw_craptco.nrdconta;
                ELSE
                   IF cr_crapceb1%ISOPEN THEN
                      CLOSE cr_crapceb1;
                   END IF;
                   -- eh cooperado migrado e nao tem CEB, Liq Interbancaria
                   RAISE vr_exc_saida;
                END IF;
             ELSE
                IF cr_craptco%ISOPEN THEN
                   CLOSE cr_craptco;
                END IF;

                IF cr_crapceb1%ISOPEN THEN
                   CLOSE cr_crapceb1;
                END IF;

                --Se chegou até aqui é porque o convênio existe na cooperativa
                --porém não foi localizada a conta que está no "nosso número".
                --Nesse caso o convênio pode ser de outra cooperativa do sistema Cecred.
                pc_convenio_outra_singular(pr_cdcooper => pr_cooper
                                          ,pr_nrconven => vr_convenio
                                          ,pr_idcnvsng => vr_idcnvsng);
                --se o convênio também existe em outra singular do sistema Cecred então Liq Interbancária
                if vr_idcnvsng = 1 then
                  --
                  RAISE vr_exc_saida;
                  --
                end if;

                -- Se nao encontrou CEB e TCO, então a conta não existe
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 911
                                     ,pr_dsc_erro => NULL
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 911;
                  vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;

             END IF; -- craptco%FOUND
          END IF; -- cr_crapceb1%FOUND

          -- Verificar se o Convenio do cooperado está bloqueado
          IF rw_crapceb1.insitceb = 4 THEN -- bloqueado
            --Criar erro - '980 - Convenio do cooperado bloqueado'
            CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                 ,pr_cdagenci => pr_cod_agencia
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cod_erro => 980
                                 ,pr_dsc_erro => NULL
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            vr_cdcritic := 980;
            vr_dscritic := NULL;
            RAISE vr_exc_erro;
          END IF;

          --Selecionar informacoes cobranca
          OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_cdbandoc => rw_crapcco.cddbanco
                          ,pr_nrcnvcob => rw_crapcco.nrconven
                          ,pr_nrdctabb => rw_crapcco.nrdctabb
                          ,pr_nrdocmto => vr_bloqueto
                          ,pr_nrdconta => vr_nrdconta);
          --Posicionar no proximo registro
          FETCH cr_crapcob INTO rw_crapcob;

          --Se nao encontrar
          IF cr_crapcob%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapcob;

             IF rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE' THEN

                -- verifica criticas 965 e 966;
                pc_checa_convenio_cooperado(pr_cdcooper => pr_cooper
                                           ,pr_nrconven => rw_crapcco.nrconven
                                           ,pr_nrdconta => vr_nrdconta);

                -- criar boleto
                BEGIN

                 INSERT INTO crapcob (cdcooper
                                     ,nrdconta
                                     ,nrcnvcob
                                     ,nrdocmto
                                     ,nrdctabb
                                     ,cdbandoc
                                     ,dtmvtolt
                                     ,dtvencto
                                     ,vltitulo
                                     ,incobran
                                     ,flgregis
                                     ,vlabatim
                                     ,vldescto
                                     ,tpdmulta
                                     ,tpjurmor
                                     ,dsdoccop
                                     ,flgdprot
                                     ,nrnosnum
                                     ,dsinform)
                              VALUES (rw_crapcop.cdcooper
                                     ,vr_nrdconta
                                     ,rw_crapcco.nrconven
                                     ,vr_bloqueto
                                     ,rw_crapcco.nrdctabb
                                     ,rw_crapcco.cddbanco
                                     ,rw_crapdat.dtmvtolt --dtmvtolt
                                     ,vr_dtvencto --dtvencto
                                     ,vr_vltitulo -- parametro do valor do pagamento
                                     ,0 -- incobran
                                     ,rw_crapcco.flgregis
                                     ,0 -- vlabatim
                                     ,0 -- vldescto
                                     ,3 -- tpdmulta
                                     ,3 -- tpjurmor
                                     ,to_char(vr_bloqueto) -- dscodcop
                                     ,0                    -- flgdprot
                                     ,vr_nrnosnum
                                     ,'LIQAPOSBX' || SUBSTR(pr_codbarras,26,17) );

                     --Retornar valores
                     pr_insittit:= 2;
                     pr_intitcop:= 1;
                     pr_nrdconta:= vr_nrdconta;
                     pr_convenio:= rw_crapcco.nrconven;
                     pr_bloqueto:= vr_bloqueto;
                     pr_contaconve:= rw_crapcco.nrdctabb;

               EXCEPTION
                 WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao inserir crapcob (CXON0014.pc_identifica_titulo_coop): '||SQLERRM;
                   --Levantar Excecao
                   RAISE vr_exc_erro;
               END;

             ELSE -- 'IMPRESSO PELO SOFTWARE'

                IF rw_crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

                   OPEN cr_cco_impresso( pr_nrconven => rw_crapcco.nrconven );
                   FETCH cr_cco_impresso INTO rw_cco_impresso;

                   IF cr_cco_impresso%FOUND THEN
                      -- criar boleto
                      CLOSE cr_cco_impresso;

                      -- verifica criticas 965 e 966;
                      pc_checa_convenio_cooperado(pr_cdcooper => pr_cooper
                                                 ,pr_nrconven => rw_crapcco.nrconven
                                                 ,pr_nrdconta => vr_nrdconta);

                      BEGIN
                       INSERT INTO crapcob (cdcooper
                                           ,nrdconta
                                           ,nrcnvcob
                                           ,nrdocmto
                                           ,nrdctabb
                                           ,cdbandoc
                                           ,dtmvtolt
                                           ,dtvencto
                                           ,vltitulo
                                           ,incobran
                                           ,flgregis
                                           ,vlabatim
                                           ,vldescto
                                           ,tpdmulta
                                           ,tpjurmor
                                           ,dsdoccop
                                           ,flgdprot
                                           ,nrnosnum
                                           ,dsinform)
                                    VALUES (rw_crapcop.cdcooper
                                           ,vr_nrdconta
                                           ,rw_crapcco.nrconven
                                           ,vr_bloqueto
                                           ,rw_crapcco.nrdctabb
                                           ,rw_crapcco.cddbanco
                                           ,rw_crapdat.dtmvtolt --dtmvtolt
                                           ,vr_dtvencto --dtvencto
                                           ,vr_vltitulo -- parametro do valor do pagamento
                                           ,0 -- incobran
                                           ,rw_crapcco.flgregis
                                           ,0 -- vlabatim
                                           ,0 -- vldescto
                                           ,3 -- tpdmulta
                                           ,3 -- tpjurmor
                                           ,to_char(vr_bloqueto) -- dscodcop
                                           ,0                    -- flgdprot
                                           ,SUBSTR(pr_codbarras,26,17)
                                           ,'LIQAPOSBX' || SUBSTR(pr_codbarras,26,17) );

                       --Retornar valores
                       pr_insittit:= 2;
                       pr_intitcop:= 1;
                       pr_nrdconta:= vr_nrdconta;
                       pr_convenio:= rw_crapcco.nrconven;
                       pr_bloqueto:= vr_bloqueto;
                       pr_contaconve:= rw_crapcco.nrdctabb;

                     EXCEPTION
                       WHEN OTHERS THEN
                         vr_dscritic := 'Erro ao inserir crapcob (CXON0014.pc_identifica_titulo_coop): '||SQLERRM;
                         --Levantar Excecao
                         RAISE vr_exc_erro;
                     END;

                   ELSE
                      IF cr_cco_impresso%ISOPEN THEN
                         CLOSE cr_cco_impresso;
                      END IF;
                      -- convenio eh migrado mas nao eh 'IMPRESSO PELO SOFTWARE', entao Liq interbancaria
                      RAISE vr_exc_saida;
                   END IF;
                ELSE -- 'MIGRACAO,INCORPORACAO'
                   -- nao eh migracao e nem impresso pelo software, 592
                   --Criar erro - '592 - Bloqueto nao encontrado'
                   CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                        ,pr_cdagenci => pr_cod_agencia
                                        ,pr_nrdcaixa => vr_nrdcaixa
                                        ,pr_cod_erro => 592
                                        ,pr_dsc_erro => NULL
                                        ,pr_flg_erro => TRUE
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);
                   --Se ocorreu erro
                   IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                   ELSE
                     vr_cdcritic:= 592;
                     vr_dscritic:= 'Bloqueto nao encontrado';
                     --Levantar Excecao
                     RAISE vr_exc_erro;
                   END IF;

                END IF; -- 'MIGRACAO,INCORPORACAO'

             END IF; -- 'IMPRESSO PELO SOFTWARE'

          ELSE -- cr_crapcob%NOTFOUND

             CLOSE cr_crapcob;

             /* excluido/pago e baixado */
             IF (rw_crapcob.incobran IN (5,3) AND pr_flgcritica) THEN
                --Criar erro
                CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                     ,pr_cdagenci => pr_cod_agencia
                                     ,pr_nrdcaixa => vr_nrdcaixa
                                     ,pr_cod_erro => 594
                                     ,pr_dsc_erro => NULL
                                     ,pr_flg_erro => TRUE
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 594;
                  vr_dscritic:= NULL;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;
             ELSIF rw_crapcob.dtbloque IS NOT NULL AND pr_flgcritica THEN
               -- Criar erro
               -- Boleto bloqueado para pagamento
               CXON0000.pc_cria_erro(pr_cdcooper => pr_cooper
                                    ,pr_cdagenci => pr_cod_agencia
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cod_erro => 1462
                                    ,pr_dsc_erro => NULL
                                    ,pr_flg_erro => TRUE
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
                                    
                --Se ocorreu erro
                IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                ELSE
                  vr_cdcritic:= 1462;
                  vr_dscritic:= NULL;
                  --Levantar Excecao
                  RAISE vr_exc_erro;
                END IF;                                   
                
             END IF; /* excluido/pago e baixado */
             --Retornar valores
             pr_insittit:= 2;
             pr_intitcop:= 1;
             pr_nrdconta:= rw_crapcob.nrdconta;
             pr_convenio:= rw_crapcob.nrcnvcob;
             pr_bloqueto:= rw_crapcob.nrdocmto;
             pr_contaconve:= rw_crapcco.nrdctabb;
          END IF; -- cr_crapcob%NOTFOUND
          --Fechar Cursor
          IF cr_crapcob%ISOPEN THEN
            CLOSE cr_crapcob;
          END IF;
        ELSE
          -- convenio 085 nao encontrado na cooperativa, Liq Interbancaria
          RAISE vr_exc_saida;
        END IF; -- crapcco%FOUND
      ELSE
        -- Liq Interbancaria
        RAISE vr_exc_saida;
      END IF; -- vr_banco = 1

    EXCEPTION
       WHEN vr_exc_saida THEN
         IF cr_crapcco%ISOPEN THEN CLOSE cr_crapcco; END IF;
         IF cr_crapceb1%ISOPEN THEN CLOSE cr_crapceb1; END IF;
         IF cr_crapceb2%ISOPEN THEN CLOSE cr_crapceb2; END IF;
         IF cr_craptco%ISOPEN THEN CLOSE cr_craptco; END IF;
         IF cr_craptco2%ISOPEN THEN CLOSE cr_craptco2; END IF;
         IF cr_craptco3%ISOPEN THEN CLOSE cr_craptco3; END IF;
         IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
         IF cr_ceb_ant%ISOPEN THEN CLOSE cr_ceb_ant; END IF;
       WHEN vr_exc_erro THEN
         IF cr_crapcco%ISOPEN THEN CLOSE cr_crapcco; END IF;
         IF cr_crapceb1%ISOPEN THEN CLOSE cr_crapceb1; END IF;
         IF cr_crapceb2%ISOPEN THEN CLOSE cr_crapceb2; END IF;
         IF cr_craptco%ISOPEN THEN CLOSE cr_craptco; END IF;
         IF cr_craptco2%ISOPEN THEN CLOSE cr_craptco2; END IF;
         IF cr_craptco3%ISOPEN THEN CLOSE cr_craptco3; END IF;
         IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
         IF cr_ceb_ant%ISOPEN THEN CLOSE cr_ceb_ant; END IF;
         pr_cdcritic:= vr_cdcritic;
         pr_dscritic:= vr_dscritic;
       WHEN OTHERS THEN
         IF cr_crapcco%ISOPEN THEN CLOSE cr_crapcco; END IF;
         IF cr_crapceb1%ISOPEN THEN CLOSE cr_crapceb1; END IF;
         IF cr_crapceb2%ISOPEN THEN CLOSE cr_crapceb2; END IF;
         IF cr_craptco%ISOPEN THEN CLOSE cr_craptco; END IF;
         IF cr_craptco2%ISOPEN THEN CLOSE cr_craptco2; END IF;
         IF cr_craptco3%ISOPEN THEN CLOSE cr_craptco3; END IF;
         IF cr_crapcob%ISOPEN THEN CLOSE cr_crapcob; END IF;
         IF cr_ceb_ant%ISOPEN THEN CLOSE cr_ceb_ant; END IF;
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0014.pc_identifica_titulo_coop. '||SQLERRM;

    END;

  END pc_identifica_titulo_coop2;

  /* ..........................................................................

	  Programa : pc_calcula_vlr_titulo_vencido
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : Kelvin Souza Ott
	  Data     : Setembro/2016.                   Ultima atualizacao: 14/12/2016

	  Dados referentes ao programa:

	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para calcular valor do titulo vencido

	  Alteração : 14/12/2016 - Parametro de retorno pr_vlrmulta_calc e pr_vlrjuros_calc
                             não eram inicializados causando problema na gravação da crapret
                             com vljurmul nulo. Impacto no relatório 601 e no arquivo
                             de retorno de cobrança ao cooperado (AJFink - SD#571733)

	...........................................................................*/
  PROCEDURE pc_calcula_vlr_titulo_vencido(pr_vltitulo      IN crapcob.vltitulo%TYPE  -- Valor do titulo em cobrança
                                         ,pr_tpdmulta      IN crapcob.tpdmulta%TYPE  -- Tipo de multa (1 - Valor Dia / 2 - Mensal / 3 - Isento)
                                         ,pr_vlrmulta      IN crapcob.vlrmulta%TYPE  -- Contem o valor da multa
                                         ,pr_tpjurmor      IN crapcob.tpjurmor%TYPE  -- Tipo de juros (1 - Valor Dia / 2 - Mensal / 3 - Isento)
                                         ,pr_vljurdia      IN crapcob.vljurdia%TYPE  -- Contem o valor de juros ao dia
                                         ,pr_qtdiavenc     IN PLS_INTEGER            -- Quantidade de dias para vencimento
                                         ,pr_vlfatura      OUT crapcob.vltitulo%TYPE -- Valor da fatura
                                         ,pr_vlrmulta_calc OUT crapcob.vlrmulta%TYPE -- Contem o valor da multa calculado
                                         ,pr_vlrjuros_calc OUT crapcob.vljurdia%TYPE -- Contem o valor do juros calculado
                                         ,pr_dscritic      OUT VARCHAR2) IS          -- Descricao do erro

    --Variaveis de erro
    vr_dscritic  VARCHAR2(1000);

  BEGIN

    pr_vlfatura := pr_vltitulo;
    -- MULTA PARA ATRASO
    pr_vlrmulta_calc := 0; --SD#571733
    IF pr_tpdmulta = 1  THEN -- Valor
      --Multa
      pr_vlrmulta_calc := pr_vlrmulta;
      --Somar a multa na fatura
      pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrmulta_calc;
    ELSIF pr_tpdmulta = 2  THEN -- % de multa do valor  do boleto
      --Multa
      pr_vlrmulta_calc:= trunc(((pr_vlrmulta/100) * pr_vltitulo),2);
      --Somar a multa na fatura
      pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrmulta_calc;
    END IF;

    -- MORA PARA ATRASO
    pr_vlrjuros_calc := 0; --SD#571733
    IF pr_tpjurmor = 1  THEN -- dias
      --Juros
      pr_vlrjuros_calc:= trunc((pr_vljurdia * pr_qtdiavenc),2);
      --Somar juros na fatura
      pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrjuros_calc;
    ELSIF pr_tpjurmor = 2  THEN -- mes
      --Juros
      pr_vlrjuros_calc:= trunc((pr_vltitulo *
                         trunc(((pr_vljurdia / 100) / 30) ,10) * (pr_qtdiavenc)),2);
      --Somar juros na fatura
      pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrjuros_calc;
    END IF;

 EXCEPTION

   WHEN OTHERS THEN
     pr_dscritic := 'Erro nao tratado na procedure CXON0014.pc_calcula_vlr_titulo_vencido: ' || SQLERRM
                    || ' Linha: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

  END pc_calcula_vlr_titulo_vencido;

  PROCEDURE pc_retorna_vlr_tit_vencto (pr_cdcooper      IN INTEGER    -- Cooperativa
                                      ,pr_nrdconta      IN INTEGER    -- Conta
                                      ,pr_idseqttl      IN INTEGER    -- Titular
                                      ,pr_cdagenci      IN INTEGER    -- Agência
                                      ,pr_nrdcaixa      IN INTEGER    -- Caixa
                                      ,pr_titulo1       IN NUMBER     -- FORMAT "99999,99999"
                                      ,pr_titulo2       IN NUMBER     -- FORMAT "99999,999999"
                                      ,pr_titulo3       IN NUMBER     -- FORMAT "99999,999999"
                                      ,pr_titulo4       IN NUMBER     -- FORMAT "9"
                                      ,pr_titulo5       IN NUMBER     -- FORMAT "zz,zzz,zzz,zzz999"
                                      ,pr_codigo_barras IN VARCHAR2   -- Codigo de Barras
                                      ,pr_vlfatura      OUT NUMBER    -- Valor da fatura
                                      ,pr_vlrjuros      OUT NUMBER    -- Valor dos juros
                                      ,pr_vlrmulta      OUT NUMBER    -- Valor da multa
                                      ,pr_fltitven      OUT NUMBER    -- Indicador Vencido
                                      ,pr_des_erro      OUT VARCHAR2  -- Indicador erro OK/NOK
                                      ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro
    /* ..........................................................................

	  Programa : pc_retorna_vlr_tit_vencto
	  Sistema  : Conta-Corrente - Cooperativa de Credito
	  Sigla    : CRED
	  Autor    : Kelvin Souza Ott
	  Data     : Setembro/2016.                   Ultima atualizacao: 27/03/2017

	  Dados referentes ao programa:

	  Frequencia: Sempre que for chamado
	  Objetivo  : Procedure para retornar o valor do titulo vencido

	  Alteração : 02/12/2016 - Correcao do paramentro pr_des_erro para ser VARCHAR2
                             - Corrigido tratamento de erro para quando existir apenas
                               o cdcritic preenchido (Douglas - Chamado 563281)

                  10/01/2017 - Correcao para que não seja criado o titulo quando informar o
                               codigo de barras. A criacao de um titulo deve ser feita apenas
                               quando confirmar o pagamento do titulo. Essa procedure deve devolver
                               o valor do titulo, caso já exista no Ayllos, devolve o valor, caso
                               contrário deverá devolver o valor que está no código de barras
                               (Douglas - Chamado 575078)

                  07/02/2017 - Ajustado a query para verificar se o boleto existe no sistema.
                               (Douglas - Chamado 602954)

                  22/02/2017 - Adicionado o calculo do valor do desconto do boleto.
                               Nao estava sendo calculado para exibir em tela
                               (Douglas - Chamado 611514)

                  27/03/2017 - Ajustado a pc_verifica_vencimento_titulo para utilizar o codigo
                               da cooperativa que está realizando a busca do valor, ao invés da cooperativa
                               do boleto.
                             - Ajustado o tratamento de erro na chamada da pc_verifica_vencimento_titulo
                             (Douglas - Chamado 628306)
                             
    ...........................................................................*/
    --Selecionar informacoes cobranca
    CURSOR cr_crapcob (pr_nrcnvcob IN crapcob.nrcnvcob%type
                      ,pr_nrdconta IN crapcob.nrdconta%type
                      ,pr_nrdocmto IN crapcob.nrdocmto%type
                      ,pr_cdbandoc IN crapcob.cdbandoc%type) IS
      SELECT crapcob.cdcooper,
             crapcob.nrdconta,
             crapcob.vltitulo,
             crapcob.cdmensag,
             crapcob.vldescto,
             crapcob.vlabatim,
             crapcob.tpdmulta,
             crapcob.vlrmulta,
             crapcob.vljurdia,
             crapcob.tpjurmor,
             crapcob.dtvencto,
             crapcob.dsinform
        FROM crapcob, crapceb, crapcco
       WHERE crapceb.nrconven = pr_nrcnvcob
         AND crapceb.nrdconta = pr_nrdconta
         AND crapcco.cdcooper = crapceb.cdcooper + 0
         AND crapcco.nrconven = crapceb.nrconven + 0
         AND crapcob.cdcooper = crapceb.cdcooper + 0
         AND crapcob.nrcnvcob = crapceb.nrconven + 0
         AND crapcob.nrdconta = crapceb.nrdconta + 0
         AND crapcob.nrdocmto = pr_nrdocmto
         AND crapcob.nrdctabb = crapcco.nrdctabb + 0
         AND crapcob.cdbandoc = pr_cdbandoc;
    rw_crapcob cr_crapcob%ROWTYPE;

    vr_de_valor_calc  VARCHAR2(100);
    vr_flg_zeros      BOOLEAN;
    vr_nro_digito     INTEGER;
    vr_retorno        BOOLEAN;
    vr_flg_cdbarerr   BOOLEAN;
    vr_intitcop       NUMBER;
    vr_vldescto       NUMBER;
    vr_vlabatim       NUMBER;
    vr_de_p_titulo5   NUMBER;
    vr_critica_data   BOOLEAN:= FALSE;
    vr_codigo_barras  VARCHAR2(100);
    vr_titulo1        NUMBER;
    vr_titulo2        NUMBER;
    vr_titulo3        NUMBER;
    vr_titulo4        NUMBER;
    vr_titulo5        NUMBER;
    vr_vlfatura       NUMBER;
    vr_vlrjuros       NUMBER;
    vr_vlrmulta       NUMBER;
    vr_fltitven       NUMBER;

    --Variaveis de erro
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic   VARCHAR2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;


  BEGIN
    vr_codigo_barras := pr_codigo_barras;
    vr_titulo1 := pr_titulo1;
    vr_titulo2 := pr_titulo2;
    vr_titulo3 := pr_titulo3;
    vr_titulo4 := pr_titulo4;
    vr_titulo5 := pr_titulo5;

    /* Data do sistema */
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haver¿ raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    --Se foi informado titulo
    IF NVL(vr_titulo1,0) <> 0 OR
       NVL(vr_titulo2,0) <> 0 OR
       NVL(vr_titulo3,0) <> 0 OR
       NVL(vr_titulo4,0) <> 0 OR
       NVL(vr_titulo5,0) <> 0 THEN

      --Validar os digitos das 3 primeiras partes da linha digitavel
      FOR idx IN 1..3 LOOP

        --Determinar a parte que ser¿ validada
        CASE idx
          WHEN 1 THEN
            vr_de_valor_calc:= vr_titulo1;
            vr_flg_zeros:= TRUE;
          WHEN 2 THEN
            vr_de_valor_calc:= vr_titulo2;
            vr_flg_zeros:= FALSE;
          WHEN 3 THEN
            vr_de_valor_calc:= vr_titulo3;
            vr_flg_zeros:= FALSE;
        END CASE;
        --Calcular digito verificador

        /*  Calcula digito- Primeiro campo da linha digitavel  */
        CXON0000.pc_calc_digito_verif (pr_valor        => vr_de_valor_calc   --> Valor Calculado
                                      ,pr_valida_zeros => vr_flg_zeros       --> Validar Zeros
                                      ,pr_nro_digito   => vr_nro_digito      --> Digito Verificador
                                      ,pr_retorno      => vr_retorno);       --> Retorno digito correto
        --Se retornou erro
        IF vr_retorno = FALSE THEN
          --Se ocorreu erro
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN

            IF vr_cdcritic IS NOT NULL AND
               TRIM(vr_dscritic) IS NULL THEN

              vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 8;
            vr_dscritic:= NULL;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP; --For idx 1..3

      /*  Compoe o codigo de barras atraves da linha digitavel  */
      vr_codigo_barras := SUBSTR(gene0002.fn_mask(vr_titulo1,'9999999999'),1,4)||
                          gene0002.fn_mask(vr_titulo4,'9')||
                          gene0002.fn_mask(vr_titulo5,'99999999999999')||
                          SUBSTR(gene0002.fn_mask(vr_titulo1,'9999999999'),5,1)||
                          SUBSTR(gene0002.fn_mask(vr_titulo1,'9999999999'),6,4)||
                          SUBSTR(gene0002.fn_mask(vr_titulo2,'99999999999'),1,10)||
                          SUBSTR(gene0002.fn_mask(vr_titulo3,'99999999999'),1,10);
    ELSE
      /* Compoe a Linha Digitavel atraves do Codigo de Barras */
      /* validar tamanho de 44 caracteres no codigo de barras e
                  somente aceitar algarismo 0-9 */
      vr_flg_cdbarerr:= gene0002.fn_numerico(vr_codigo_barras) = FALSE;

      --Se o codigo barras for diferente 44 posicoes
      IF Length(vr_codigo_barras) != 44 THEN
        vr_flg_cdbarerr:= TRUE;
      END IF;

      --Se o codigo barras estiver errado
      IF  vr_flg_cdbarerr THEN
        --Se ocorreu erro
        IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
          IF vr_cdcritic IS NOT NULL AND
             TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;

          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Codigo de Barras invalido.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --Montar parametros saida
      vr_titulo1 := TO_NUMBER(SUBSTR(vr_codigo_barras,01,04)||
                             SUBSTR(vr_codigo_barras,20,01)||
                             SUBSTR(vr_codigo_barras,21,04)|| '0');
      vr_titulo2 := TO_NUMBER(SUBSTR(vr_codigo_barras,25,10)|| '0');
      vr_titulo3 := TO_NUMBER(SUBSTR(vr_codigo_barras,35,10)|| '0');
      vr_titulo4 := TO_NUMBER(SUBSTR(vr_codigo_barras,05,01));
      vr_titulo5 := TO_NUMBER(SUBSTR(vr_codigo_barras,06,14));

      /**- VERIFICA COM EDSON A VALIDACAO DE LINHA DIGITAVEL -*/
      FOR idx IN 1..3 LOOP

        --Determinar a parte que ser¿ validada
        CASE idx
          WHEN 1 THEN
            vr_de_valor_calc:= vr_titulo1;
            vr_flg_zeros:= TRUE;
          WHEN 2 THEN
            vr_de_valor_calc:= vr_titulo2;
            vr_flg_zeros:= FALSE;
          WHEN 3 THEN
            vr_de_valor_calc:= vr_titulo3;
            vr_flg_zeros:= FALSE;
        END CASE;
        --Calcular digito verificador

        /*  Calcula digito- Primeiro campo da linha digitavel  */
        CXON0000.pc_calc_digito_verif (pr_valor        => vr_de_valor_calc   --> Valor Calculado
                                      ,pr_valida_zeros => vr_flg_zeros       --> Validar Zeros
                                      ,pr_nro_digito   => vr_nro_digito      --> Digito Verificador
                                      ,pr_retorno      => vr_retorno);       --> Retorno digito correto

        --Determinar a parte que sera retornada
        CASE idx
          WHEN 1 THEN vr_titulo1:= TO_NUMBER(vr_de_valor_calc);
          WHEN 2 THEN vr_titulo2:= TO_NUMBER(vr_de_valor_calc);
          WHEN 3 THEN vr_titulo3:= TO_NUMBER(vr_de_valor_calc);
        END CASE;
      END LOOP; --For idx 1..3
    END IF;

    /* Verifica se conv boleto eh de cobranca 085 */
    --Selecionar informacoes cobranca
    OPEN cr_crapcob (pr_nrcnvcob => to_number(SUBSTR(vr_codigo_barras, 20, 06))
                    ,pr_nrdconta => to_number(SUBSTR(vr_codigo_barras, 26, 08))
                    ,pr_nrdocmto => to_number(SUBSTR(vr_codigo_barras, 34, 09))
                    ,pr_cdbandoc => to_number(SUBSTR(vr_codigo_barras, 01, 03)));

    --Posicionar no proximo registro
    FETCH cr_crapcob INTO rw_crapcob;
    --Se nao encontrar
    IF cr_crapcob%FOUND THEN
      --Titulo Encontrado
      vr_intitcop := 1;
    ELSE
      -- Titulo nao Encontrado
      vr_intitcop := 0;

    END IF;
    --Fechar Cursor
    CLOSE cr_crapcob;

    /********************************************************/
    /***********FAZER CALCULO DO VALOR DO TITULO*************/
    IF vr_intitcop = 1 THEN /* Se for titulo da cooperativa */
      /* Parametros de saida da cobranca registrada */
      vr_vlrjuros := 0;
      vr_vlrmulta := 0;
      vr_vldescto := 0;
      vr_vlabatim := 0;
      vr_vlfatura := rw_crapcob.vltitulo;

      /* trata o desconto */
      /* se concede apos o vencimento */
      IF rw_crapcob.cdmensag = 2 THEN
        --Valor Desconto
        vr_vldescto:= rw_crapcob.vldescto;
        --Diminuir valor desconto do Valor Fatura
        vr_vlfatura:= Nvl(vr_vlfatura,0) - vr_vldescto;
      END IF;
      /* utilizar o abatimento antes do calculo de juros/multa */
      IF rw_crapcob.vlabatim > 0 THEN
        --Valor Abatimento
        vr_vlabatim:= rw_crapcob.vlabatim;
        --Diminuir valor abatimento do Valor Fatura
        vr_vlfatura:= Nvl(vr_vlfatura,0) - vr_vlabatim;
      END IF;

      -- Limpar a tabela de erros
      vr_tab_erro.DELETE;

      --Verificar vencimento do titulo
           
      pc_verifica_vencimento_titulo (pr_cod_cooper      => pr_cdcooper          --Codigo Cooperativa
                                    ,pr_cod_agencia     => pr_cdagenci          --Codigo da Agencia
                                    ,pr_dt_agendamento  => NULL                 --Data Agendamento
                                    ,pr_dt_vencto       => rw_crapcob.dtvencto  --Data Vencimento
                                    ,pr_critica_data    => vr_critica_data      --Critica na validacao
                                    ,pr_cdcritic        => vr_cdcritic          --Codigo da Critica
                                    ,pr_dscritic        => vr_dscritic          --Descricao da Critica
                                    ,pr_tab_erro        => vr_tab_erro);        --Tabela retorno erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        IF vr_tab_erro.Count > 0 THEN
          vr_dscritic:= vr_dscritic || ' ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSIF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        vr_dscritic:= 'Nao foi possivel verificar o vencimento do boleto. Erro: ' || vr_dscritic;

            --Levantar Excecao
            RAISE vr_exc_erro;
        END IF;

      --Retorna se está vencido ou não
      IF vr_critica_data = TRUE THEN
        vr_fltitven := 1;
      ELSE
        vr_fltitven := 2;
      END IF;

      /* verifica se o titulo esta vencido */
      IF vr_critica_data THEN

        CXON0014.pc_calcula_vlr_titulo_vencido(pr_vltitulo => vr_vlfatura
                                              ,pr_tpdmulta => rw_crapcob.tpdmulta
                                              ,pr_vlrmulta => rw_crapcob.vlrmulta
                                              ,pr_tpjurmor => rw_crapcob.tpjurmor
                                              ,pr_vljurdia => rw_crapcob.vljurdia
                                              ,pr_qtdiavenc => (rw_crapdat.dtmvtocd - rw_crapcob.dtvencto)
                                              ,pr_vlfatura => vr_vlfatura
                                              ,pr_vlrmulta_calc => vr_vlrmulta
                                              ,pr_vlrjuros_calc => vr_vlrjuros
                                              ,pr_dscritic =>  vr_dscritic);


      ELSE
        -- se concede apos vencto, ja calculou
        IF rw_crapcob.cdmensag <> 2  THEN
          --Valor Desconto
          vr_vldescto:= rw_crapcob.vldescto;
          --Retirar o desconto da fatura
          vr_vlfatura:= Nvl(vr_vlfatura,0) - vr_vldescto;
        END IF;
      END IF;

    ELSE
      -- Se não está vencido devolver o valor do titulo que está no boleto
      vr_de_p_titulo5:= TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_titulo5,'99999999999999'),5,10));
      --Retornar valor fatura
      vr_vlfatura:= vr_de_p_titulo5 / 100;
    END IF;

    --Retorna os valores calculados
    pr_vlfatura := vr_vlfatura;
    pr_vlrjuros := vr_vlrjuros;
    pr_vlrmulta := vr_vlrmulta;
    pr_fltitven := vr_fltitven;

    --Se tudo deu certo retorna OK
    pr_des_erro := 'OK';
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
      IF TRIM(vr_dscritic) IS NULL THEN
        IF vr_cdcritic > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          vr_dscritic := 'Erro nao tratado na procedure CXON0014.pc_retorna_vlr_tit_vencto (1): ' || SQLERRM
                         || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        END IF;
      END IF;
      vr_dscritic:= REPLACE(vr_dscritic,'"', NULL);
      vr_dscritic:= REPLACE(vr_dscritic,'''', NULL);
      vr_dscritic:= REPLACE(vr_dscritic,chr(10), NULL);
      vr_dscritic:= REPLACE(vr_dscritic,chr(13), NULL);
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      vr_dscritic:= 'Erro nao tratado na procedure CXON0014.pc_retorna_vlr_tit_vencto (2): ' || SQLERRM
                     || ' ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

      vr_dscritic:= REPLACE(vr_dscritic,'"', NULL);
      vr_dscritic:= REPLACE(vr_dscritic,'''', NULL);
      vr_dscritic:= REPLACE(vr_dscritic,chr(10), NULL);
      vr_dscritic:= REPLACE(vr_dscritic,chr(13), NULL);
      pr_dscritic := vr_dscritic;

  END pc_retorna_vlr_tit_vencto;

  /* Retonar o ano do codigo barras do Darf Europa */
  FUNCTION fn_ret_ano_barras_darf (pr_innumano IN INTEGER) -- Numero Ano
  RETURN INTEGER IS
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_ret_ano_cdbarras_darf
  --  Sistema  : Retonar o ano do codigo barras do Darf Europa
  --  Sigla    : CXON
  --  Autor    : Lucas Ranghetti
  --  Data     : Janeiro/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retonar o ano do codigo barras do Darf Europa

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;
    BEGIN
      --Se Indicador ano entiver entre 1 e 3
      IF pr_innumano BETWEEN 1 AND 3 THEN
        RETURN (2020 + pr_innumano);
      ELSIF  pr_innumano BETWEEN 4 AND 9 THEN
        RETURN (2010 + pr_innumano);
      ELSIF  pr_innumano = 0 THEN
        RETURN(2020);
      END IF;
    EXCEPTION
       WHEN vr_exc_erro THEN
         RETURN(NULL);
       WHEN OTHERS THEN
         RETURN(NULL);
    END;
  END fn_ret_ano_barras_darf;

   /* Retonar o ano do codigo barras do Darf Europa */
  PROCEDURE pc_ret_ano_barras_darf_car (pr_innumano IN INTEGER,
                                        pr_outnumano OUT INTEGER) IS -- Numero Ano

--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_ret_ano_cdbarras_darf
  --  Sistema  : Retonar o ano do codigo barras do Darf Europa
  --  Sigla    : CXON
  --  Autor    : Lucas Ranghetti
  --  Data     : Janeiro/2017.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retonar o ano do codigo barras do Darf Europa

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    BEGIN

     pr_outnumano:= fn_ret_ano_barras_darf(pr_innumano => pr_innumano);

    EXCEPTION
       WHEN OTHERS THEN
         NULL;
    END;
  END pc_ret_ano_barras_darf_car;


  /* Procedure para estornar títulos iptu  - Demetrius Wolff - Mouts*/
  PROCEDURE pc_estorna_titulos_iptu (pr_cdcooper      IN INTEGER       --Codigo Cooperativa
                                    ,pr_cod_operador  IN VARCHAR2      --Codigo Operador
                                    ,pr_cod_agencia   IN INTEGER       --Codigo Agencia
                                    ,pr_nro_caixa     IN INTEGER       --Numero Caixa
                                    ,pr_iptu          IN NUMBER       --IPTU
                                    ,pr_codigo_barras IN VARCHAR2      --Codigo de Barras
                                    ,pr_histor        OUT INTEGER      --Codigo Historico
                                    ,pr_pg            OUT NUMBER      --Indicador Pago
                                    ,pr_docto         OUT NUMBER       --Numero Documento
                                    ,pr_cdcritic      OUT INTEGER      --Codigo do erro
                                    ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro

  /*---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_estorna_titulos_iptu    Antigo: dbo/b2crap15.p/estorna-titulos-iptu
  --  Sistema  : CECRED
  --  Sigla    : CXON
  --  Autor    : Demetrius Wolff - Mouts
  --  Data     : Maio/2017                   Ultima atualizacao: 03/09/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  --
  -- Objetivo  : Procedure para estornar títulos iptu
  --
  -- Alteracoes: 03/09/2018 - Correção para remover lote (Jonata - Mouts).
  --
  --
  ---------------------------------------------------------------------------------------------------------------*/

      --Selecionar Titulos
      CURSOR cr_craptit3 (pr_cdcooper IN craptit.cdcooper%type
                         ,pr_dtmvtolt IN craptit.dtmvtolt%TYPE
                         ,pr_cdagenci IN craptit.cdagenci%type
                         ,pr_cdbccxlt IN craptit.cdbccxlt%type
                         ,pr_nrdolote IN craptit.nrdolote%type
                         ,pr_dscodbar IN craptit.dscodbar%type) IS
        SELECT /*+ INDEX (craptit craptit##craptit3) */
               craptit.dscodbar
              ,craptit.flgpgdda
              ,craptit.nrdocmto
              ,craptit.vldpagto
              ,craptit.cdctrbxo
              ,craptit.rowid
        FROM craptit
        WHERE craptit.cdcooper = pr_cdcooper
        AND   craptit.dtmvtolt = pr_dtmvtolt
        AND   craptit.cdagenci = pr_cdagenci
        AND   craptit.cdbccxlt = pr_cdbccxlt
        AND   craptit.nrdolote = pr_nrdolote
        AND   Upper(craptit.dscodbar) = Upper(pr_dscodbar);
      rw_craptit cr_craptit3%ROWTYPE;

      --Selecionar informacoes titulos descontados bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type
                        ,pr_insittit IN craptdb.insittit%type) IS
        SELECT craptdb.dtvencto
        FROM craptdb
        WHERE craptdb.cdcooper = pr_cdcooper
        AND   craptdb.nrdconta = pr_nrdconta
        AND   craptdb.cdbandoc = pr_cdbandoc
        AND   craptdb.nrdctabb = pr_nrdctabb
        AND   craptdb.nrcnvcob = pr_nrcnvcob
        AND   craptdb.nrdocmto = pr_nrdocmto
        AND   craptdb.insittit = pr_insittit;
      rw_craptdb   cr_craptdb%ROWTYPE;
      vr_fcraptdb  BOOLEAN;

      --Selecionar lancamentos
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplcm.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplcm.nrdolote%TYPE
                        ,pr_cdhistor IN craplcm.cdhistor%TYPE
                        ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE
                        ,pr_nrdconta IN craplcm.nrdconta%TYPE) IS
        SELECT craplcm.vllanmto
              ,craplcm.rowid
        FROM craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
        AND   craplcm.dtmvtolt = pr_dtmvtolt
        AND   craplcm.cdagenci = pr_cdagenci
        AND   craplcm.cdbccxlt = pr_cdbccxlt
        AND   craplcm.nrdolote = pr_nrdolote
        AND   craplcm.cdhistor = pr_cdhistor
        AND   craplcm.nrdctabb = pr_nrdctabb
        AND   craplcm.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;

      --Selecionar informacoes cobranca
      CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_cdbandoc IN crapcob.cdbandoc%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdctabb IN crapcob.nrdctabb%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type
                        ,pr_nrdconta IN crapcob.nrdconta%type) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
              ,crapcob.nrctremp
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.nrdctabb
              ,crapcob.flgregis
              ,crapcob.nrnosnum
              ,crapcob.dtmvtolt
              ,crapcob.dsinform
              ,crapcob.rowid
              ,crapcob.inemiten
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.cdbandoc = pr_cdbandoc
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdconta = pr_nrdconta;
      rw_crapcob cr_crapcob%ROWTYPE;

      --Selecionar lancamentos de tarifas
      CURSOR cr_craplat (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_nrdconta IN crapcob.nrdconta%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
        SELECT craplat.rowid
          FROM craplat
         WHERE craplat.cdcooper = pr_cdcooper
           AND craplat.dtmvtolt = rw_crapdat.dtmvtolt
           AND craplat.insitlat = 1 -- pendente
           AND craplat.nrdconta = pr_nrdconta
           AND craplat.cdpesqbb = to_char(pr_cdcooper)||';'||
                                  to_char(pr_nrdconta)||';'||
                                  to_char(pr_nrcnvcob)||';'||
                                  to_char(pr_nrdocmto);
      rw_craplat cr_craplat%ROWTYPE;

      rw_craplot_lcm cr_craplot%ROWTYPE;
      rw_b_craplot   cr_craplot%ROWTYPE;


      --Variaveis Locais
      vr_cdhistor      craplcm.cdhistor%TYPE;
      vr_tplotmov      craplot.tplotmov%TYPE;
      vr_nrdcaixa      INTEGER;
      vr_nrdconta      INTEGER;  --Numero da Conta
      vr_insittit      INTEGER;  --Situacao Titulo
      vr_intitcop      INTEGER;  --Indicador titulo cooperativa
      vr_convenio      NUMBER;   --Numero Convenio
      vr_bloqueto      NUMBER;   --Numero Boleto
      vr_contaconve    INTEGER;  --Conta do Convenio
      vr_idorigem      INTEGER;
      vr_flgdesct      BOOLEAN;


      --Variaveis de erro
      vr_cd_erro   crapcri.cdcritic%TYPE;
      vr_des_erro  VARCHAR2(4000);
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      vr_dscriti2  VARCHAR2(4000);
      vr_nro_lote  INTEGER;
      vr_index     INTEGER;

      --Tabela de erros
      vr_tab_erro GENE0001.typ_tab_erro;

      --Tabela de Titulos
      vr_tab_titulos   PAGA0001.typ_tab_titulos;

      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;


  BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      /* Tratamento de erros para internet */
      IF pr_cod_agencia = 90 THEN
        vr_idorigem:= 3;    /** Internet **/
      ELSIF pr_cod_agencia = 91 THEN
        vr_idorigem:= 4;    /** Cash/TAA **/
      ELSE
        vr_idorigem:= 2;    /** Caixa On-Line **/
      END IF;

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_des_erro:= 'Cooperativa nao cadastrada.';
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapcop;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --Se for iptu
      IF pr_iptu = 1 THEN
        --Numero lote
        vr_nro_lote:= 17000 + pr_nro_caixa;
      ELSE
        --Numero lote
        vr_nro_lote:= 16000 + pr_nro_caixa;
      END IF;

      --Selecionar informacoes titulos
      OPEN cr_craptit3 (pr_cdcooper => rw_crapcop.cdcooper
                       ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                       ,pr_cdagenci => pr_cod_agencia
                       ,pr_cdbccxlt => 11
                       ,pr_nrdolote => vr_nro_lote
                       ,pr_dscodbar => pr_codigo_barras);
      FETCH cr_craptit3 INTO rw_craptit;
      --Se nao encontrar
      IF cr_craptit3%NOTFOUND THEN
        CLOSE cr_craptit3;
        CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cod_agencia
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cod_erro => 90
                             ,pr_dsc_erro => NULL
                             ,pr_flg_erro => TRUE
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
         IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
           RAISE vr_exc_erro;
         ELSE
           vr_cdcritic:= 90;
           vr_dscritic:= NULL;
           RAISE vr_exc_erro;
         END IF;
      END IF;
      CLOSE cr_craptit3;

      pr_pg     := 0;
      pr_docto  := rw_craptit.nrdocmto;

      --Identificar titulo Cooperativa
      pc_identifica_titulo_coop2 (pr_cooper      => pr_cdcooper      --Codigo Cooperativa
                                 ,pr_nro_conta   => 0 --             --Numero Conta
                                 ,pr_idseqttl    => 0 --             --Sequencial do Titular
                                 ,pr_cod_agencia => pr_cod_agencia   --Codigo da Agencia
                                 ,pr_nro_caixa   => pr_nro_caixa     --Numero Caixa
                                 ,pr_codbarras   => pr_codigo_barras --Codigo Barras
                                 ,pr_flgcritica  => FALSE            --Flag Critica
                                 ,pr_nrdconta    => vr_nrdconta      --Numero da Conta OUT
                                 ,pr_insittit    => vr_insittit      --Situacao Titulo
                                 ,pr_intitcop    => vr_intitcop      --Indicador titulo cooperativa
                                 ,pr_convenio    => vr_convenio      --Numero Convenio
                                 ,pr_bloqueto    => vr_bloqueto      --Numero Boleto
                                 ,pr_contaconve  => vr_contaconve    --Conta do Convenio
                                 ,pr_cdcritic    => vr_cdcritic      --Codigo do erro
                                 ,pr_dscritic    => vr_dscritic);    --Descricao erro

      --Se ocorreu erro
      IF vr_cdcritic > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        RAISE vr_exc_erro;
      END IF;

      IF vr_intitcop = 1 THEN /* Se for título da cooperativa */

        /* Verifica se deve extrair o CEB do nro do boleto */
        OPEN cr_crapcco (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrconven => vr_convenio);
        --Posicionar no proximo registro
        FETCH cr_crapcco INTO rw_crapcco;
        CLOSE cr_crapcco;

        --Selecionar informacoes titulos descontados bordero
        OPEN cr_craptdb (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_nrdconta => vr_nrdconta
                        ,pr_cdbandoc => rw_crapcco.cddbanco
                        ,pr_nrdctabb => vr_contaconve
                        ,pr_nrcnvcob => vr_convenio
                        ,pr_nrdocmto => vr_bloqueto
                        ,pr_insittit => 2); -- pago
        FETCH cr_craptdb INTO rw_craptdb;
        vr_fcraptdb := FALSE;
        vr_fcraptdb := cr_craptdb%FOUND;
        CLOSE cr_craptdb;

        -- Se o título for de cobrança sem registro (crapcob.flgregis = 0),
        --   significa que será necessário verificar se houve o crédito do pagamento na conta do cooperado beneficiário;
        -- se houve crédito em conta, será necessário excluir o lançamento;

        IF vr_fcraptdb = FALSE THEN

          --Selecionar informacoes cobranca
          IF cr_crapcob%ISOPEN THEN
            CLOSE cr_crapcob;
          END IF;
          OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_cdbandoc => rw_crapcco.cddbanco
                          ,pr_nrcnvcob => to_number(vr_convenio)
                          ,pr_nrdctabb => vr_contaconve
                          ,pr_nrdocmto => vr_bloqueto
                          ,pr_nrdconta => vr_nrdconta);
          FETCH cr_crapcob INTO rw_crapcob;

          IF cr_crapcob%FOUND
          AND rw_crapcob.flgregis = 0 THEN
            CLOSE cr_crapcob;

            IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
            END IF;
            -- registro de cobrança sem registro, verificar se houve o crédito do pagamento na conta do cooperado beneficiário
            OPEN cr_craplot (pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_dtmvtolt => rw_crapdat.dtmvtocd
                            ,pr_cdagenci => pr_cod_agencia
                            ,pr_cdbccxlt => 100
                            ,pr_nrdolote => 10800 + pr_nro_caixa);
            FETCH cr_craplot INTO rw_craplot;
            IF cr_craplot%FOUND THEN
              CLOSE cr_craplot;
              --Selecionar lancamentos para conta convenio
              OPEN cr_craplcm (pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_dtmvtolt => rw_craplot.dtmvtolt
                              ,pr_cdagenci => rw_craplot.cdagenci
                              ,pr_cdbccxlt => rw_craplot.cdbccxlt
                              ,pr_nrdolote => rw_craplot.nrdolote
                              ,pr_cdhistor => 654 --rw_craplot.cdhistor
                              ,pr_nrdctabb => vr_contaconve
                              ,pr_nrdocmto => vr_bloqueto
                              ,pr_nrdconta => vr_nrdconta);
              FETCH cr_craplcm INTO rw_craplcm;
              IF cr_craplcm%FOUND THEN
                CLOSE cr_craplcm;

                BEGIN
                  DELETE craplcm
                   WHERE rowid = rw_craplcm.rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic:= 11;
                    RAISE vr_exc_erro;
                END;

              ELSE
                CLOSE cr_craplcm;
              END IF;

            ELSE
              CLOSE cr_craplot;
            END IF;
          ELSE
            CLOSE cr_crapcob;
          END IF;

        ELSE -- cr_craptdb%FOUND

          IF cr_crapcob%ISOPEN THEN
            CLOSE cr_crapcob;
          END IF;
          OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                          ,pr_cdbandoc => rw_crapcco.cddbanco
                          ,pr_nrcnvcob => vr_convenio
                          ,pr_nrdctabb => vr_contaconve
                          ,pr_nrdocmto => vr_bloqueto
                          ,pr_nrdconta => vr_nrdconta);
          FETCH cr_crapcob INTO rw_crapcob;
          IF cr_crapcob%FOUND THEN
            CLOSE cr_crapcob;

            --Montar indice para tabela memoria titulos
            vr_index:= vr_tab_titulos.Count + 1;
            vr_tab_titulos(vr_index).cdbandoc:= rw_crapcob.cdbandoc;
            vr_tab_titulos(vr_index).nrdctabb:= rw_crapcob.nrdctabb;
            vr_tab_titulos(vr_index).nrcnvcob:= rw_crapcob.nrcnvcob;
            vr_tab_titulos(vr_index).nrdconta:= rw_crapcob.nrdconta;
            vr_tab_titulos(vr_index).nrdocmto:= rw_crapcob.nrdocmto;
            -- dados nao utilizados
            -- vr_tab_titulos(vr_index).vltitulo:= pr_valor_informado;
            -- vr_tab_titulos(vr_index).flgregis:= rw_crapcob.flgregis = 1;

            DSCT0001.pc_efetua_estorno_baixa_titulo (pr_cdcooper    => rw_crapcop.cdcooper --Codigo Cooperativa
                                                    ,pr_cdagenci    => pr_cod_agencia      --Codigo Agencia
                                                    ,pr_nrdcaixa    => pr_nro_caixa        --Numero Caixa
                                                    ,pr_cdoperad    => pr_cod_operador     --Codigo operador
                                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtocd --Data Movimento
                                                    ,pr_idorigem    => vr_idorigem         --Identificador Origem pagamento
                                                    ,pr_nrdconta    => vr_nrdconta         --Numero da conta
                                                    ,pr_tab_titulos => vr_tab_titulos      --Titulos a serem baixados
                                                    ,pr_cdcritic    => vr_cdcritic         --Codigo Critica
                                                    ,pr_dscritic    => vr_dscritic         --Descricao Critica
                                                    ,pr_tab_erro    => vr_tab_erro);       --Tabela erros
            --Se ocorreu erro
            IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
              IF vr_tab_erro.Count > 0 THEN
                vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                RAISE vr_exc_erro;
              ELSE
                vr_dscritic := 'Erro ao estornar baixa de titulo: ' || vr_cdcritic || ' - ' || vr_dscritic;
                vr_cdcritic := vr_cdcritic;
                RAISE vr_exc_erro;

              END IF;
            END IF;
          END IF;
          IF cr_crapcob%ISOPEN THEN
            CLOSE cr_crapcob;
          END IF;

        END IF;

        IF cr_crapcob%ISOPEN THEN
          CLOSE cr_crapcob;
        END IF;

        -- Tornar título "em aberto"
        OPEN cr_crapcob (pr_cdcooper => rw_crapcop.cdcooper
                        ,pr_cdbandoc => rw_crapcco.cddbanco
                        ,pr_nrcnvcob => vr_convenio
                        ,pr_nrdctabb => vr_contaconve
                        ,pr_nrdocmto => vr_bloqueto
                        ,pr_nrdconta => vr_nrdconta);
        FETCH cr_crapcob INTO rw_crapcob;
        IF cr_crapcob%FOUND THEN
          BEGIN
            UPDATE crapcob
               SET crapcob.incobran = 0
                  ,crapcob.indpagto = 0
                  ,crapcob.dtdpagto = null
                  ,crapcob.vldpagto = 0
                  ,crapcob.vltarifa = 0
                  ,crapcob.cdbanpag = 0
                  ,crapcob.cdagepag = 0
            WHERE rowid = rw_crapcob.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'erro ao atualizar crapcob';
              RAISE vr_exc_erro;
          END;
        END IF;

        --> Cancelar cobrança de tarifa
        OPEN cr_craplat (pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_nrdconta => vr_nrdconta
                        ,pr_nrcnvcob => vr_convenio
                        ,pr_nrdocmto => vr_bloqueto);
        FETCH cr_craplat INTO rw_craplat;
        IF cr_craplat%FOUND THEN
          CLOSE cr_craplat;
          BEGIN
            UPDATE craplat
               SET craplat.insitlat = 3  -- Baixado
                  ,craplat.cdmotest = 0  -- Cechet informou que não tem codigo para 'Estorno de pagamento'
                  ,craplat.dtdestor = rw_crapdat.dtmvtolt
                  ,craplat.cdopeest = pr_cod_operador
             WHERE rowid = rw_craplat.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'erro ao atualizar craplat';
              RAISE vr_exc_erro;
          END;
        ELSE
          CLOSE cr_craplat;
        END IF;

       --> Rotina para excluir o registro de liquidação do boleto, do movimento da cobrança (crapret)
        IF rw_crapcob.flgregis = 1 THEN
          BEGIN
            DELETE crapret
             WHERE crapret.cdcooper = rw_crapcob.cdcooper
               AND crapret.nrdconta = rw_crapcob.nrdconta
               AND crapret.nrcnvcob = rw_crapcob.nrcnvcob
               AND crapret.nrdocmto = rw_crapcob.nrdocmto
               AND crapret.dtocorre = rw_crapdat.dtmvtocd
               AND crapret.cdocorre in (6,17,76,77);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'erro ao excluir crapret: '||SQLERRM;
              RAISE vr_exc_erro;
          END;

        END IF;

        --Criar log Cobranca
        PAGA0001.pc_cria_log_cobranca(pr_idtabcob => rw_crapcob.ROWID --ROWID da Cobranca
                                     ,pr_cdoperad => pr_cod_operador  --Operador
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtocd   --Data movimento
                                     ,pr_dsmensag => 'Cobrança estornada.' --Descricao Mensagem
                                     ,pr_des_erro => vr_des_erro      --Indicador erro
                                     ,pr_dscritic => vr_dscritic);    --Descricao erro
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

      END IF; /* Se for título da cooperativa */

      -- Apagar registro da craptit
      BEGIN
        DELETE craptit
         WHERE rowid = rw_craptit.rowid;

        IF SQL%ROWCOUNT = 0 THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao excluir registro de pagamento';
          RAISE vr_exc_erro;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          vr_cdcritic:= 0;
          vr_dscritic:= 'erro ao excluir craptit';
          RAISE vr_exc_erro;
      END;

      IF vr_nro_lote BETWEEN 16000 AND 16999 THEN
        pr_histor := 713;
      ELSE
        pr_histor := 686;
      END IF;
  EXCEPTION
    WHEN vr_exc_erro THEN

       IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;

       pr_cdcritic:= vr_cdcritic;
       pr_dscritic:= vr_dscritic;

    WHEN OTHERS THEN

       pr_cdcritic:= 0;
       pr_dscritic:= 'Erro ao processar rotina CXON0014.pc_estorna_titulos_iptu. '||SQLERRM;

  END pc_estorna_titulos_iptu;



  --> Procedure para estornar faturas
  PROCEDURE pc_estorna_faturas ( pr_cdcooper      IN INTEGER       --Codigo Cooperativa
                                ,pr_cdoperad      IN VARCHAR2      --Codigo Operador
                                ,pr_cdagenci      IN INTEGER       --Codigo Agencia
                                ,pr_nrdcaixa      IN INTEGER       --Numero Caixa
                                ,pr_cddbarra      IN VARCHAR2      --Codigo de Barras
                                ,pr_cdseqfat      IN VARCHAR2      --Codigo sequencial da fatura
                                ,pr_cdhistor      OUT INTEGER      --Codigo Historico
                                ,pr_pg            OUT NUMBER       --Indicador Pago
                                ,pr_nrdocmto      OUT NUMBER       --Numero Documento
                                ,pr_cdcritic      OUT INTEGER      --Codigo do erro
                                ,pr_dscritic      OUT VARCHAR2) IS --Descricao do erro

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_estorna_faturas    Antigo: dbo/b2crap15.p/estorna-faturas
    Sistema  : CECRED
    Sigla    : CXON
    Autor    : Odirlei Busana - AMcom
    Data     : Abril/2018                   Ultima atualizacao: 03/09/2018

   Dados referentes ao programa:

   Frequencia: -----

   Objetivo  : Procedure para estornar de faturas

   Alteracoes: 05/04/2018 - Conversão Progress -> Oracle.
                            PRJ381 - Antifraude. (Odirlei-AMcom)

			   03/09/2018 - Correção para remover lote (Jonata - Mouts).
  ---------------------------------------------------------------------------------------------------------------*/

      -- Selecionar fatura
      CURSOR cr_craplft ( pr_cdcooper craplft.cdcooper%TYPE,
                          pr_dtmvtocd crapdat.dtmvtocd%TYPE,
                          pr_cdagenci craplft.cdagenci%TYPE,
                          pr_cdbccxlt craplft.cdbccxlt%TYPE,
                          pr_nrdolote craplft.nrdolote%TYPE,
                          pr_cdseqfat craplft.cdseqfat%TYPE ) IS
        SELECT lft.vllanmto,
               lft.insitfat,
               lft.nrseqdig,
               lft.cdhistor,
               lft.rowid
          FROM craplft lft
         WHERE lft.cdcooper = pr_cdcooper
           AND lft.dtmvtolt = pr_dtmvtocd
           AND lft.cdagenci = pr_cdagenci
           AND lft.cdbccxlt = pr_cdbccxlt
           AND lft.nrdolote = pr_nrdolote
           AND lft.cdseqfat = pr_cdseqfat;
      rw_craplft cr_craplft%ROWTYPE;

     --> Buscar lote
     CURSOR cr_craplot ( pr_cdcooper craplot.cdcooper%TYPE,
                         pr_dtmvtocd craplot.dtmvtolt%TYPE,
                         pr_cdagenci craplot.cdagenci%TYPE,
                         pr_nrdolote craplot.nrdolote%TYPE ) IS
       SELECT lot.rowid,
              lot.cdbccxlt,
              lot.nrdolote,
              lot.cdagenci,
              lot.vlcompdb,
              lot.vlinfodb,
              lot.vlcompcr,
              lot.vlinfocr
         FROM craplot lot
        WHERE lot.cdcooper = pr_cdcooper
          AND lot.dtmvtolt = pr_dtmvtocd
          AND lot.cdagenci = pr_cdagenci
          AND lot.cdbccxlt = 11 --> Fixo
          AND lot.nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;


      --Selecionar Titulos
      CURSOR cr_craptit3 (pr_cdcooper IN craptit.cdcooper%type
                         ,pr_dtmvtolt IN craptit.dtmvtolt%TYPE
                         ,pr_cdagenci IN craptit.cdagenci%type
                         ,pr_cdbccxlt IN craptit.cdbccxlt%type
                         ,pr_nrdolote IN craptit.nrdolote%type
                         ,pr_dscodbar IN craptit.dscodbar%type) IS
        SELECT /*+ INDEX (craptit craptit##craptit3) */
               craptit.dscodbar
              ,craptit.flgpgdda
              ,craptit.nrdocmto
              ,craptit.vldpagto
              ,craptit.cdctrbxo
              ,craptit.rowid
        FROM craptit
        WHERE craptit.cdcooper = pr_cdcooper
        AND   craptit.dtmvtolt = pr_dtmvtolt
        AND   craptit.cdagenci = pr_cdagenci
        AND   craptit.cdbccxlt = pr_cdbccxlt
        AND   craptit.nrdolote = pr_nrdolote
        AND   Upper(craptit.dscodbar) = Upper(pr_dscodbar);
      rw_craptit cr_craptit3%ROWTYPE;

      --Selecionar informacoes titulos descontados bordero
      CURSOR cr_craptdb (pr_cdcooper IN craptdb.cdcooper%type
                        ,pr_nrdconta IN craptdb.nrdconta%type
                        ,pr_cdbandoc IN craptdb.cdbandoc%type
                        ,pr_nrdctabb IN craptdb.nrdctabb%type
                        ,pr_nrcnvcob IN craptdb.nrcnvcob%type
                        ,pr_nrdocmto IN craptdb.nrdocmto%type
                        ,pr_insittit IN craptdb.insittit%type) IS
        SELECT craptdb.dtvencto
        FROM craptdb
        WHERE craptdb.cdcooper = pr_cdcooper
        AND   craptdb.nrdconta = pr_nrdconta
        AND   craptdb.cdbandoc = pr_cdbandoc
        AND   craptdb.nrdctabb = pr_nrdctabb
        AND   craptdb.nrcnvcob = pr_nrcnvcob
        AND   craptdb.nrdocmto = pr_nrdocmto
        AND   craptdb.insittit = pr_insittit;
      rw_craptdb   cr_craptdb%ROWTYPE;
      vr_fcraptdb  BOOLEAN;

      --Selecionar lancamentos
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplcm.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplcm.nrdolote%TYPE
                        ,pr_cdhistor IN craplcm.cdhistor%TYPE
                        ,pr_nrdctabb IN craplcm.nrdctabb%TYPE
                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE
                        ,pr_nrdconta IN craplcm.nrdconta%TYPE) IS
        SELECT craplcm.vllanmto
              ,craplcm.rowid
        FROM craplcm
        WHERE craplcm.cdcooper = pr_cdcooper
        AND   craplcm.dtmvtolt = pr_dtmvtolt
        AND   craplcm.cdagenci = pr_cdagenci
        AND   craplcm.cdbccxlt = pr_cdbccxlt
        AND   craplcm.nrdolote = pr_nrdolote
        AND   craplcm.cdhistor = pr_cdhistor
        AND   craplcm.nrdctabb = pr_nrdctabb
        AND   craplcm.nrdocmto = pr_nrdocmto;
      rw_craplcm cr_craplcm%ROWTYPE;

      --Selecionar informacoes cobranca
      CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_cdbandoc IN crapcob.cdbandoc%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdctabb IN crapcob.nrdctabb%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type
                        ,pr_nrdconta IN crapcob.nrdconta%type) IS
        SELECT crapcob.cdbandoc
              ,crapcob.cdcooper
              ,crapcob.nrcnvcob
              ,crapcob.nrdconta
              ,crapcob.nrdocmto
              ,crapcob.incobran
              ,crapcob.dtretcob
              ,crapcob.nrctremp
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.nrdctabb
              ,crapcob.flgregis
              ,crapcob.nrnosnum
              ,crapcob.dtmvtolt
              ,crapcob.dsinform
              ,crapcob.rowid
              ,crapcob.inemiten
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.cdbandoc = pr_cdbandoc
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdctabb = pr_nrdctabb
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdconta = pr_nrdconta;
      rw_crapcob cr_crapcob%ROWTYPE;

      --Selecionar lancamentos de tarifas
      CURSOR cr_craplat (pr_cdcooper IN crapcob.cdcooper%type
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_nrdconta IN crapcob.nrdconta%type
                        ,pr_nrcnvcob IN crapcob.nrcnvcob%type
                        ,pr_nrdocmto IN crapcob.nrdocmto%type) IS
        SELECT craplat.rowid
          FROM craplat
         WHERE craplat.cdcooper = pr_cdcooper
           AND craplat.dtmvtolt = rw_crapdat.dtmvtolt
           AND craplat.insitlat = 1 -- pendente
           AND craplat.nrdconta = pr_nrdconta
           AND craplat.cdpesqbb = to_char(pr_cdcooper)||';'||
                                  to_char(pr_nrdconta)||';'||
                                  to_char(pr_nrcnvcob)||';'||
                                  to_char(pr_nrdocmto);
      rw_craplat cr_craplat%ROWTYPE;

      rw_craplot_lcm cr_craplot%ROWTYPE;
      rw_b_craplot   cr_craplot%ROWTYPE;


      --Variaveis Locais
      vr_cdhistor      craplcm.cdhistor%TYPE;
      vr_tplotmov      craplot.tplotmov%TYPE;
      vr_nrdcaixa      INTEGER;
      vr_nrdconta      INTEGER;  --Numero da Conta
      vr_insittit      INTEGER;  --Situacao Titulo
      vr_intitcop      INTEGER;  --Indicador titulo cooperativa
      vr_convenio      NUMBER;   --Numero Convenio
      vr_bloqueto      NUMBER;   --Numero Boleto
      vr_contaconve    INTEGER;  --Conta do Convenio
      vr_idorigem      INTEGER;
      vr_flgdesct      BOOLEAN;


      --Variaveis de erro
      vr_cd_erro   crapcri.cdcritic%TYPE;
      vr_des_erro  VARCHAR2(4000);
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  VARCHAR2(4000);
      vr_dscriti2  VARCHAR2(4000);
      vr_nrdolote  INTEGER;
      vr_index     INTEGER;

      --Tabela de erros
      vr_tab_erro GENE0001.typ_tab_erro;

      --Tabela de Titulos
      vr_tab_titulos   PAGA0001.typ_tab_titulos;

      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;


  BEGIN
      --Inicializar parametros erro
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;

      --Verificar se a cooperativa existe
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapcop;

      --Numero lote
      vr_nrdolote:= 15000 + pr_nrdcaixa;

      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      --> Buscar lote
      OPEN cr_craplot ( pr_cdcooper => rw_crapcop.cdcooper,
                        pr_dtmvtocd => rw_crapdat.dtmvtocd,
                        pr_cdagenci => pr_cdagenci,
                        pr_nrdolote => vr_nrdolote);
      FETCH cr_craplot INTO rw_craplot;
      IF cr_craplot%NOTFOUND THEN
        CLOSE cr_craplot;
        vr_cdcritic := 60;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplot;
      END IF;

      -- Selecionar fatura
      OPEN cr_craplft ( pr_cdcooper => rw_crapcop.cdcooper,
                        pr_dtmvtocd => rw_crapdat.dtmvtocd,
                        pr_cdagenci => pr_cdagenci,
                        pr_cdbccxlt => rw_craplot.cdbccxlt,
                        pr_nrdolote => rw_craplot.nrdolote,
                        pr_cdseqfat => pr_cdseqfat);
      FETCH cr_craplft INTO rw_craplft;
      IF cr_craplft%NOTFOUND THEN
        CLOSE cr_craplft;
        vr_cdcritic := 90; -- 090 - Lancamento inexistente.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplft;
      END IF;

      IF rw_craplft.insitfat <> 1 THEN
        vr_cdcritic := 103; -- 103 - Lancamento automatico ja efetuado.
        RAISE vr_exc_erro;
      END IF;

      BEGIN
        DELETE craplft lft
         WHERE lft.rowid = rw_craplft.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao excluir a fatura(craplft): '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      pr_pg       := 0;
      pr_nrdocmto := rw_craplft.nrseqdig;
      pr_cdhistor := rw_craplft.cdhistor;

  EXCEPTION
    WHEN vr_exc_erro THEN

       IF nvl(vr_cdcritic,0) > 0 AND vr_dscritic IS NULL THEN
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
       END IF;

       pr_cdcritic:= vr_cdcritic;
       pr_dscritic:= vr_dscritic;

    WHEN OTHERS THEN

       pr_cdcritic:= 0;
       pr_dscritic:= 'Erro ao processar rotina CXON0014.pc_estorna_faturas. '||SQLERRM;

  END pc_estorna_faturas;

  --> Procedure para gerar a linha digitavel a fatura em base do codigo de barras
  PROCEDURE pc_calc_lindig_fatura ( pr_cdbarras IN  VARCHAR2
                                   ,pr_lindigit OUT VARCHAR2) IS

  /*---------------------------------------------------------------------------------------------------------------

    Programa : pc_calc_lindig_fatura
    Sistema  : CECRED
    Sigla    : CXON
    Autor    : Odirlei Busana - AMcom
    Data     : Abril/2018                   Ultima atualizacao: 18/06/2019

   Dados referentes ao programa:

   Frequencia: -----

   Objetivo  : Procedure para gerar a linha digitavel a fatura em base do codigo de barras

   Alteracoes: 18/06/2019 - PRB0041451 - Ajuste para corrigir erro registrado na tabela tbgen_erro_sistema.
                                         O calculo da linha digitavel so deve ser feito quando receber um 
										 codigo de barras valido (Diego).


  ---------------------------------------------------------------------------------------------------------------*/
    vr_lindigi1 VARCHAR2(12);
    vr_lindigi2 VARCHAR2(12);
    vr_lindigi3 VARCHAR2(12);
    vr_lindigi4 VARCHAR2(12);
    vr_cdcalcul VARCHAR2(100);
    vr_nrdigito INTEGER;
    vr_flgretor BOOLEAN;

  BEGIN

    IF  TRIM(pr_cdbarras) IS NULL THEN
	    pr_lindigit := NULL;
        RETURN;
    END IF;

    FOR idx IN 1..4 LOOP
      CASE idx
        WHEN 1 THEN
          vr_lindigi1:= SUBSTR(pr_cdbarras, 1, 11);
          vr_cdcalcul:= TO_NUMBER(vr_lindigi1);

        WHEN 2 THEN
          vr_lindigi2:= SUBSTR(pr_cdbarras, 12, 11);
          vr_cdcalcul:= TO_NUMBER(vr_lindigi2);

        WHEN 3 THEN
          vr_lindigi3:= SUBSTR(pr_cdbarras, 23, 11);
          vr_cdcalcul:= TO_NUMBER(vr_lindigi3);

        WHEN 4 THEN
          vr_lindigi4:= SUBSTR(pr_cdbarras, 34, 11);
          vr_cdcalcul:= TO_NUMBER(vr_lindigi4);

      END CASE;

      IF SUBSTR(pr_cdbarras,3,1) IN ('6','7') THEN
        /*** Calculo digito verificador pelo modulo 10 ***/
        CXON0000.pc_calc_digito_iptu_samae (pr_valor    => vr_cdcalcul       --> Valor Calculado
                                         ,pr_nrdigito => vr_nrdigito    --> Digito Verificador
                                         ,pr_retorno  => vr_flgretor);  --> Retorno digito correto
      ELSE
        /*** Verificacao pelo modulo 11 ***/
        CXON0014.pc_verifica_digito (pr_nrcalcul => vr_cdcalcul  --Numero a ser calculado
                          ,pr_poslimit => 0            --Utilizado para validação de dígito adicional de DAS
                                    ,pr_nrdigito => vr_nrdigito); --Digito verificador
      END IF;

      CASE idx
        WHEN 1 THEN
          vr_lindigi1:= TO_NUMBER(gene0002.fn_mask(vr_lindigi1,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));

        WHEN 2 THEN
          vr_lindigi2:= TO_NUMBER(gene0002.fn_mask(vr_lindigi2,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));

        WHEN 3 THEN
          vr_lindigi3:= TO_NUMBER(gene0002.fn_mask(vr_lindigi3,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));

        WHEN 4 THEN
          vr_lindigi4:= TO_NUMBER(gene0002.fn_mask(vr_lindigi4,'99999999999')||gene0002.fn_mask(vr_nrdigito,'9'));

      END CASE;

    END LOOP;


    /* Monta linha digitavel */
    pr_lindigit:= SUBSTR(gene0002.fn_mask(vr_lindigi1,'999999999999'),1,11) ||'-'||
                  SUBSTR(gene0002.fn_mask(vr_lindigi1,'999999999999'),12,1) ||' '||
                  SUBSTR(gene0002.fn_mask(vr_lindigi2,'999999999999'),1,11) ||'-'||
                  SUBSTR(gene0002.fn_mask(vr_lindigi2,'999999999999'),12,1) ||' '||
                  SUBSTR(gene0002.fn_mask(vr_lindigi3,'999999999999'),1,11) ||'-'||
                  SUBSTR(gene0002.fn_mask(vr_lindigi3,'999999999999'),12,1) ||' '||
                  SUBSTR(gene0002.fn_mask(vr_lindigi4,'999999999999'),1,11) ||'-'||
                  SUBSTR(gene0002.fn_mask(vr_lindigi4,'999999999999'),12,1);
  EXCEPTION
   WHEN OTHERS THEN
     --Gravar tabela especifica de log
     CECRED.pc_internal_exception;
     pr_lindigit := NULL;
  END pc_calc_lindig_fatura;

END CXON0014;
/
