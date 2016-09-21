CREATE OR REPLACE PACKAGE CECRED.cxon0014 AS

/*..............................................................................

   Programa: cxon0014                        Antigo: siscaixa/web/dbo/b1crap14.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Mirtes.
   Data    : Marco/2001                      Ultima atualizacao: 05/12/2014

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
                            "IMPRESSO PELO SOFTWARE" e n�o existir o crapcob
                            (Elton).

               02/05/2011 - Tratamento para liquida��o de cob. registrada
                          - Criticar titulos com numero de caracteres <> de 44
                            e nao aceitar caracteres nao numerico (Guilherme);
                          - Acerto na contabiliza��o dos cheques na craplot
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

               19/11/2012 - Titulos migrados para Alto Vale s�o interbancarios
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

               14/06/2013 - Altera��o fun��o enviar_email_completo para
                            nova vers�o (Jean Michel).

               07/07/2013 - Convers�o Progress para Oracle (Alisson - AMcom)

               09/05/2014 - Tratamento para nao aceitar titulos do banco Real (Elton).

               09/05/2014 - Replicar manuten��o progress (Odirlei/AMcom).

               29/05/2014 - Replicar manuten��o realizada no progres para a
                            procedure "pc_busca_sequencial_fatura"
                            (Douglas - Chamado 128278)

               19/08/2014 - Criar procedure bypass pc_gera_titulos_iptu_prog
                            chamado exclusivamente pela b1wgen0016.paga_titulo
                            no Progress (Projeto 03-Float - Rafael).

               04/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir
                            nomenclaturas Cedente por Benefici�rio e  Sacado por Pagador
                            Chamado 229313 (Jean Reddiga - RKAM).

               27/07/2015 - #308980 Valida o pagamento em duplicidade dos convenios SICREDI (1154) verificando
                            os �ltimos 5 anos da craplft, assim como o sicredi, que tamb�m valida os �ltimos
                            5 anos (Carlos)
..............................................................................*/

  /* Procedure para gerar os titulos de iptu */
  PROCEDURE pc_gera_titulos_iptu (pr_cooper          IN INTEGER --Codigo Cooperativa
                                 ,pr_nrdconta        IN INTEGER --Numero da Conta
                                 ,pr_idseqttl        IN crapttl.idseqttl%TYPE --Sequencial do titular
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
                            ,pr_tpcptdoc        IN craptit.tpcptdoc%TYPE DEFAULT 1-- Tipo de captura do documento (1=Leitora, 2=Linha digitavel).
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
                                       ,pr_cdcritic     OUT INTEGER      --C�digo do erro
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

END CXON0014;
/
CREATE OR REPLACE PACKAGE BODY CECRED.cxon0014 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CXON0014
  --  Sistema  : Procedimentos e funcoes das transacoes do caixa online
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2013.                   Ultima atualizacao: 25/08/2016
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
    --             25/01/2015 - Adicionada valida��o por meio de arrecada��o pelo
  --                          campo crapscn.dsoparre para Conv. Sicredi (Lunelli SD 234418)
  --
    --             11/03/2015 - Adicionada verifica��o pelo d�gito 8 no in�cio do cdbarra
  --                          de faturas na rotina 'pc_retorna_valores_fatura' (Lunelli SD 245425).
  --
  --             12/03/2015 - #202833 Tratamento para n�o aceitar t�tulos do Banco Boavista (231) (Carlos)
  --
  --             29/04/2015 - #267196 Tratamento para n�o aceitar t�tulos do Banco Standard (012) (Carlos)
  --
  --             05/06/2015 - Remover valida��es para o convenio 963 Foz do brasil (Lucas Ranghetti #292200)
  --
  --             02/07/2015 - #302133 Tratamento para n�o aceitar t�tulos do Banco Itaubank (479) (Carlos)
  --
  --             27/07/2015 - #308980 Valida o pagamento em duplicidade dos convenios SICREDI (1154) verificando
  --                          os �ltimos 5 anos da craplft, assim como o sicredi, que tamb�m valida os �ltimos
  --                          5 anos (Carlos)
  --
  --             14/08/2015 - pc_gera_titulo_iptu e pc_gera_faturas -> inclus�o do parametro pr_tpcptdoc, para identificacao do tipo de captura
  --                          (leitora ou manual(linha digitavel)) (Odirlei-AMcom)
  --
  --             04/01/2016 - Ajuste na leitura da tabela cracbf para utilizar UPPER nos campos VARCHAR
  --                          pois ser� incluido o UPPER no indice desta tabela - SD 375854
  --                          (Adriano).
  --
  --             11/01/2016 - Ajuste na leitura da tabela cracbf para utilizar UPPER nos campos VARCHAR
  --                          pois ser� incluido o UPPER no indice desta tabela - SD 375854
  --                          (Adriano).
  --
  --             25/08/2016 - #456682 Inclusao de ip na tentativa de pagamento de boleto incluido na crapcbf (Carlos)
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
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
     AND   crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE;

  --Selecionar informacoes dos bancos
  CURSOR cr_crapban (pr_cdbccxlt IN crapban.cdbccxlt%type) IS
    SELECT crapban.nmresbcc
          ,crapban.nmextbcc
          ,crapban.cdbccxlt
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
          ,crapcon.flgcnvsi
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
    --   Atualiza��o: 09/05/2014 - Ajustado para somente buscar tarifa se for
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

      --s� buscar tarifa se for inpessoa <> 3(sem fins lucartivos)
      -- se for 3 vltarifa ficar� zero
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
        -- Fechar o cursor pois haver� raise
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
    --   17/11/2014 - Ajustado variavel que monta o n�mero de controle IF do pagamento de
    --                um VR Boleto. O campo precisa ter 20 posi��es. (Rafael)
    --
    --   05/12/2014 - De acordo com a circula 3.656 do Banco Central,substituir
    --                nomenclaturas Cedente por Benefici�rio e  Sacado por Pagador
    --                Chamado 229313 (Jean Reddiga - RKAM).
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
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
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

      --Numero Contrato
      vr_nrctrlif:= '1'||To_Char(rw_crapdat.dtmvtocd,'MMDD')||gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                    substr(To_Char(SYSTIMESTAMP,'MISSFF'),1,10)|| vr_sufixo;

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
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
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
                                 ,pr_idseqttl        IN crapttl.idseqttl%TYPE --Sequencial do titular
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
  --  Data     : Julho/2013.                   Ultima atualizacao: 06/10/2015
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
  --             30/12/2014 - Ajuste para lockar a tabela CRAPlot para n�o permitir que seja gerado
  --                          titulo com o mesmo nrdocto, visto que o nrdocto � gerado a partir do nrseqdig do lote.
  --                          essa situa��o reflete no estorno do titulo SD 238584 (Odirlei-AMcom)
  --
  --             20/02/2015 - Ajustes para melhor tratamento de criticas e n�o perder as mensagens.
  --                          SD253990 (Odirlei-AMcom)
  --
  --             11/06/2015 - Tratamento Projeto Coop/Emit/Exp (Daniel)
  --
  --             25/06/2015 - Ajuste na cria��o do lote, para assim que inserir dar o commit
  --                          com pragma autonomos_transaction, para liberar o registro e minimizar
  --                          o tempo de lock da tabela lote(Odirlei-AMcom)
  --
  --             28/07/2015 - Ajuste para testar se a tabela craplot esta lockada antes de realizar o update
  --                          assim evitando custo do banco para gerenciar lock(Odirlei-Amcom)
  --
  --             30/07/2015 - Alterado para n�o fazer o atualiza��o do lote qnd for agencia = 90 Internet
  --                          nestes casos ir� atualizar na paga0001, diminuindo tempo de lock da tabela (Odirlei-Amcom)
  --
  --             14/08/2015 - pc_gera_titulo_iptu e pc_gera_faturas -> inclus�o do parametro pr_tpcptdoc, para identificacao do tipo de captura
  --                          (leitora ou manual(linha digitavel)) (Odirlei-AMcom)
  --
  --             06/10/2015 - Inclusao do nrsnosnum na criacao da crapcob SD339759 (Odirlei-AMcom)
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
      vr_registro  ROWID;
      vr_dsconmig  VARCHAR2(100);
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
      -- Vari�vel t�tulo com movimenta��o liq ap�s baixa/ou liq tit n�o registrado
      vr_liqaposb BOOLEAN := FALSE;

      vr_aux_cdocorre NUMBER;

      -- Procedimento para inserir o lote e n�o deixar tabela lockada
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
                  ,craplot.nrseqdig
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
                  ,1  -- craplot.nrseqdig
                  ,pr_tplotmov
                  ,pr_cdoperad
                  ,pr_cdhistor
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING  craplot.ROWID
                       ,craplot.nrdolote
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
                   INTO rw_craplot_ctl.ROWID
                      , rw_craplot_ctl.nrdolote
                      , rw_craplot_ctl.nrseqdig
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
        ELSE
          -- ou atualizar o nrseqdig para reservar posi��o
          UPDATE craplot
             SET craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
           WHERE craplot.ROWID = rw_craplot_ctl.ROWID
           RETURNING craplot.nrseqdig INTO rw_craplot_ctl.nrseqdig;
        END IF;

        CLOSE cr_craplot;

        -- retornar informa��es para o programa chamador
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
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
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

      -- Controlar cria��o de lote, com pragma
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
          ,craptit.tpcptdoc)
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
          ,Nvl(rw_craplot.nrseqdig,0)        -- nrdocmto
          ,' '                               -- cdopedev
          ,NULL                              -- dtdevolu
          ,pr_insittit /*  Arrec. caixa  */  -- insittit
          ,Nvl(rw_craplot.nrseqdig,0)        -- nrseqdig
          ,pr_intitcop                       -- intitcop
          ,vr_flgenvio                       -- flgenvio
          ,vr_flgpgdda                       -- flgpgdda
          ,pr_nrinsced                       -- nrinsced
          ,pr_cdcoptfn                       -- cdcoptfn
          ,pr_cdagetfn                       -- cdagetfn
          ,pr_nrterfin                       -- nrterfin
          ,pr_tpcptdoc)                      -- tpcptdoc
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

          -- Controlar cria��o de lote, com pragma
          pc_insere_lote (pr_cdcooper => rw_crapcop.cdcooper,
                          pr_dtmvtolt => rw_crapdat.dtmvtocd,
                          pr_cdagenci => pr_cod_agencia,
                          pr_cdbccxlt => 100,
                          pr_nrdolote =>10800 + pr_nro_caixa,
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
              ,Nvl(rw_craplot_lcm.nrseqdig,0)  -- nrseqdig
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
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao inserir na tabela craplcm. '||sqlerrm;
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
                                         ,pr_cdcritic => vr_cdcritic          --C�digo de erro
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

          --Atualizar lote da lcm por ultimo, a fim de diminuir tempo de lock
          BEGIN
            UPDATE craplot SET craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                              ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                              ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + pr_valor_informado
                              ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + pr_valor_informado
                              ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0)
            WHERE craplot.ROWID = rw_craplot_lcm.ROWID
            RETURNING craplot.nrseqdig INTO rw_craplot_lcm.nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;

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
             -- verificar se n�o � convenio impresso pelo software
             -- Se for, ser� necess�rio crir t�tulo na crapcob, sen�o gerar erro pois o t�tulo n�o existe;
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

                -- Abrir o cursor novamente para buscar o mesmo rec�m-criado;
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

                -- criar vari�vel que identifica t�tulo com movimenta��o liq ap�s baixa/ou liq tit n�o registrado;
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

            --Processar a Liquidacao
            PAGA0001.pc_processa_liquidacao (pr_idtabcob     => rw_crapcob.rowid       --Rowid da Cobranca
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

            --Processar Liquidacao apos baixa
            PAGA0001.pc_proc_liquid_apos_baixa (pr_idtabcob     => rw_crapcob.rowid       --Rowid da Cobranca
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

          -- fun��o monta a tabela de valores a ser creditado para o cooperado (vr_tab_lcm_consolidada)
          -- apenas se o float for D-0
/*
          IF rw_crapcco.qtdfloat = 0 THEN

            PAGA0001.pc_valores_a_creditar(pr_cdcooper => rw_crapcob.cdcooper
                                          ,pr_nrcnvcob => rw_crapcob.nrcnvcob
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_dtcredit => vr_dtcredit
                                          ,pr_idtabcob => rw_crapcob.rowid -- montar valor apenas para um t�tulo
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
            vr_dscritic:= 'Parametro de Convenio de conta migrada n�o encontrado. '||SQLERRM;
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
                                              ,pr_cdcritic     => vr_cdcritic         --C�digo do erro
                                              ,pr_dscritic     => vr_dscritic);       --Descricao do erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na autenticacao do pagamento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      -- Apenas atualizar o lote se n�o for pagamento pela INTERNET
      -- pagamentos pela Internet, atualizacao do lote ser� na paga0001.pc_paga_titulo
      IF pr_cod_agencia <> 90 THEN
        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot_rowid (pr_rowid  => rw_craplot.rowid);
            FETCH cr_craplot_rowid INTO rw_craplot_rowid;
            CLOSE cr_craplot_rowid;
            vr_dscritic := NULL;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot_rowid%ISOPEN THEN
                 CLOSE cr_craplot_rowid;
               END IF;

               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 vr_dscritic:= 'Registro de lote '||rw_craplot.nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar 0,5 seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        -- Atualizar lote de cria��o da Tit, deixado por ultimo para diminuir tempo de lock
        BEGIN
          UPDATE craplot SET craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                            ,craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                            ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + pr_valor_informado
                            ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + pr_valor_informado
          WHERE craplot.ROWID = rw_craplot.ROWID
          RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF; --cdagenci <> 90

      /* Atualiza sequencia Autenticacao */
      BEGIN
        UPDATE craptit SET craptit.nrautdoc = pr_ult_sequencia
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
  -- Altera��es : Incluido parametro pc_tpcptdoc (Odirlei-AMcom)
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

    pc_gera_titulos_iptu(pr_cooper => pr_cooper
                       , pr_nrdconta => pr_nrdconta
                       , pr_idseqttl => pr_idseqttl
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
  PROCEDURE pc_verifica_vencimento_titulo (pr_cod_cooper     IN INTEGER  --Codigo Cooperativa
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
  --  Data     : Julho/2013.                   Ultima atualizacao: 06/10/2015
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
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Tipo de tabela de erro
      vr_tab_erro GENE0001.typ_tab_erro;
      --Variaveis Locais
      vr_dt_dia_util DATE;
      vr_dt_feriado  DATE;
      vr_libepgto    BOOLEAN;
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
      -- Se n�o encontrar
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
        
        -- Verificar se a data ocd � maior que a data de movimento devido a pagamentos
        -- feitos antes de terminar o processo batch, onde que a dtmvtolt ser� a nova dtmvtoan
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
        --Se n�o estiver liberado
        IF vr_libepgto = FALSE AND pr_cod_agencia NOT IN (90,91)THEN
          pr_critica_data:= FALSE;
        END IF;
      ELSE
        /** Agendamento de Pagamento **/
        --Verificar se a data de vencimento eh dia util
        vr_dt_feriado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cod_cooper
                                                   ,pr_dtmvtolt => pr_dt_vencto
                                                   ,pr_tipo     => 'P');
        --Se nao for dia util
        IF vr_dt_feriado >= pr_dt_agendamento THEN
          --Sair
          RAISE vr_exc_saida;
        END IF;
        --Marcar para criticar a data
        pr_critica_data:= TRUE;

        /** Aceita agendamento de titulo com vencimento no ultimo dia **/
        /** util do ano somente no primeiro dia util do proximo ano   **/
        /** Exemplo: VENCIMENTO 31/12/2009 - AGENDAMENTO - 04/01/2010 **/

        IF to_number(To_Char(pr_dt_agendamento,'YYYY')) -
           To_Number(to_char(pr_dt_vencto,'YYYY')) = 1  THEN
          --Montar o dia util
          vr_dt_dia_util:= TO_DATE('01/01/'||To_Char(pr_dt_agendamento,'YYYY'),'DD/MM/YYYY');
          --Verficar se eh dia util
          vr_dt_dia_util:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cod_cooper
                                                      ,pr_dtmvtolt => vr_dt_dia_util
                                                      ,pr_tipo     => 'P');
          --Se data agendamento igual ao dia util encontrado
          IF pr_dt_agendamento = vr_dt_dia_util THEN
            --Data dia util
            vr_dt_dia_util:= TO_DATE('31/12/'||to_char(pr_dt_vencto,'YYYY'),'DD/MM/YYYY');
            /** Se dia 31/12 for segunda-feira obtem data do sabado **/
            /** para aceitar vencidos do ultimo final de semana     **/
            IF To_Number(to_char(vr_dt_dia_util,'D')) = 2  THEN
              vr_dt_dia_util:= TO_DATE('29/12/'||to_char(pr_dt_vencto,'YYYY'),'DD/MM/YYYY');
            ELSIF To_Number(to_char(vr_dt_dia_util,'D')) = 1  THEN
              /** Se dia 31/12 for domingo, o ultimo dia util e 29/12 **/
              vr_dt_dia_util:= TO_DATE('29/12/'||to_char(pr_dt_vencto,'YYYY'),'DD/MM/YYYY');
            ELSIF To_Number(to_char(vr_dt_dia_util,'D')) = 7  THEN
              /** Se dia 31/12 for sabado, o ultimo dia util e 30/12 **/
              vr_dt_dia_util:= TO_DATE('30/12/'||to_char(pr_dt_vencto,'YYYY'),'DD/MM/YYYY');
            END IF;
            /** Verifica se pode aceitar o titulo vencido **/
            IF  pr_dt_vencto >= vr_dt_dia_util THEN
              --Retorna false
              pr_critica_data:= FALSE;
            END IF;
          END IF;
        END IF;
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
  --             28/07/2014 - Devido a desativa�ao dos convenios com 5 digitos(crapceb)
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
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
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
        vr_dscritic:= 'Parametro de Convenio de conta migrada n�o encontrado. '||SQLERRM;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Quebrar o codigo de barras
      vr_banco:= TO_NUMBER(SUBSTR(pr_codbarras, 1, 3));
      vr_convenio1:= TO_NUMBER(SUBSTR(pr_codbarras, 20, 6));
      vr_convenio2:= TO_NUMBER(SUBSTR(pr_codbarras, 25, 8));  /* ALPES */
      vr_convenio3:= TO_NUMBER(SUBSTR(pr_codbarras, 26, 7));  /* CEB */
      vr_nrconvceb:= TO_NUMBER(SUBSTR(pr_codbarras, 33, 4));  /* CEB */
      vr_bloqueto1:= TO_NUMBER(SUBSTR(pr_codbarras, 26, 5));  /* 5 d�gitos */
      vr_bloqueto2:= TO_NUMBER(SUBSTR(pr_codbarras, 34, 9));  /* ALPES */
      vr_bloqueto3:= TO_NUMBER(SUBSTR(pr_codbarras, 33, 10)); /* 10 d�gitos */
      vr_bloqueto4:= TO_NUMBER(SUBSTR(pr_codbarras, 37, 6)); /*6 d�gitos CEB*/
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
                                           ,pr_cdcritic     => vr_cdcritic     --C�digo do erro
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
                                   'CECRED nao encontrado. ('||gene0002.fn_mask(vr_nrconvceb,'9999')||')';
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
  --  Data     : Julho/2013.                   Ultima atualizacao: 22/06/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para retornar valores dos titulos iptu
  --
  --
  --  Alteracoes:  09/05/2014 - Replicar manuten��o progress (Odirlei/AMcom).
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
  --                            nomenclaturas Cedente por Benefici�rio e  Sacado por Pagador
  --                            Chamado 229313 (Jean Reddiga - RKAM).
  --
  --               12/12/2014 - Tratamento para nao aceitar titulos do Banco Santander (353).
  --                            (Jaison - SD: 231108)
  --
  --               22/12/2014 - Ajustes para retornar valores de juros e abatimento com valor zero
  --                            quando n�o tiver valor, e ajustado para calcular juros mesmo se for boleto de
  --                            convenio de incorpora��o/migra��o (Odirlei/AMcom SD 234943)
  --
  --               05/01/2014 - Ajuste para que a valida��o de limite de valor do VR_Boleto seja
  --                            realizado apenas para o TAA e internet bank, assim n�o apresentando a critica
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
  --                            pois ser� incluido o UPPER no indice desta tabela - SD 375854
  --                            (Adriano).
  --
  --               11/01/2016 - Ajuste na leitura da tabela crapcbf para utilizar UPPER nos campos VARCHAR
  --                            pois ser� incluido o UPPER no indice desta tabela - SD 375854
  --                            (Adriano).
  --
  --               22/06/2016 - Ajustado leitura da crapagb para buscar apenas as agencias ativas e
  --                            alterado a critica de agencia nao encontrada de 100 para 956
  --                            (Douglas - Chamado 417655)
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
               crapcco.dsorgarq
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
               crapcco.dsorgarq
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
        FROM crapcob
        WHERE crapcob.cdcooper = pr_cdcooper
        AND   crapcob.nrcnvcob = pr_nrcnvcob
        AND   crapcob.nrdconta = pr_nrdconta
        AND   crapcob.nrdocmto = pr_nrdocmto
        AND   crapcob.nrdctabb = pr_nrdctabb;
      rw_crapcob cr_crapcob%ROWTYPE;

      -- Verificacao de codigo de barras fraudulento
      CURSOR cr_crapcbf(pr_cd_barra crapcbf.dsfraude%TYPE) IS
        SELECT 1
          FROM crapcbf
         WHERE tpfraude = 1 -- boletos
           AND UPPER(dsfraude) = UPPER(pr_cd_barra);
      rw_crapcbf cr_crapcbf%ROWTYPE;

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

      vr_nrdipatu VARCHAR2(1000);

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
    BEGIN
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
      /* Se titulo for VR Boleto e DDA, remover idtitdda do c�digo de barras */
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
      -- Se n�o encontrar
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
                                 ,pr_dsc_erro => 'Sistema em estado de crise. VR Boleto nao permitido!'
                                 ,pr_flg_erro => TRUE
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
            vr_cdcritic := 0;
            vr_dscritic := 'Sistema em estado de crise. VR Boleto nao permitido!';
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

            --Determinar a parte que ser� validada
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

            --Determinar a parte que ser� validada
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
                                     pr_des_destino => 'prevencaodefraudes@cecred.coop.br',
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
        IF (to_number(SUBSTR(pr_codigo_barras,16,4)) = 557) AND /* Prefeitura*/
           (to_number(SUBSTR(pr_codigo_barras,02,1)) = 1)  THEN /* Cod.Segmto*/
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
        ELSE
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
      END IF;

      --Nao for IPTU
      IF pr_iptu = 0 THEN
        IF pr_titulo5 <> 0  THEN
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

        /** Tratamento para banco **/
        IF rw_crapban.cdbccxlt = 012 OR  -- Banco Standard
           rw_crapban.cdbccxlt = 231 OR  -- Banco Boavista
           rw_crapban.cdbccxlt = 353 OR  -- Banco Santander
           rw_crapban.cdbccxlt = 356 OR  -- Banco Real
           rw_crapban.cdbccxlt = 479     -- Itaubank
        THEN
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
           -- Caixa on-line n�o � necessario validar
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
          /* Verifica se conv boleto � de cobranca 085 */
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
          -- Se for cobranca registrada, calcular o valor do titulo conforme instru��o

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
            /* nao eh permitido receber boleto de emprestimo vencido */
            IF rw_crapcco.dsorgarq = 'EMPRESTIMO' THEN
              vr_des_erro:= 'Cob. Emprestimo. - Boleto Vencido.';
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
          
            /* MULTA PARA ATRASO */
            IF rw_crapcob.tpdmulta = 1  THEN /* Valor */
              --Multa
              pr_vlrmulta:= rw_crapcob.vlrmulta;
              --Somar a multa na fatura
              pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrmulta;
            ELSIF rw_crapcob.tpdmulta = 2  THEN /* % de multa do valor  do boleto */
              --Multa
              pr_vlrmulta:= APLI0001.fn_round(((rw_crapcob.vlrmulta/100)* rw_crapcob.vltitulo),2);
              --Somar a multa na fatura
              pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrmulta;
            END IF;
            /* MORA PARA ATRASO */
            IF rw_crapcob.tpjurmor = 1  THEN /* dias */
              --Juros
              pr_vlrjuros:= APLI0001.fn_round((rw_crapcob.vljurdia *
                                       (rw_crapdat.dtmvtocd - rw_crapcob.dtvencto)),2);
              --Somar juros na fatura
              pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrjuros;
            ELSIF rw_crapcob.tpjurmor = 2  THEN /* mes */
              --Juros
              pr_vlrjuros:= APLI0001.fn_round((rw_crapcob.vltitulo *
                                      APLI0001.fn_round(((rw_crapcob.vljurdia / 100) / 30) ,10) *
                                      (rw_crapdat.dtmvtocd - rw_crapcob.dtvencto)),2);
              --Somar juros na fatura
              pr_vlfatura:= Nvl(pr_vlfatura,0) + pr_vlrjuros;
            END IF;
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
          -- se o valor informado for maior que o vlr do boleto, criticar - Projeto 210
          ELSIF ROUND(pr_valor_informado,2) > ROUND(pr_vlfatura,2) AND
                rw_crapcco.dsorgarq = 'EMPRESTIMO' THEN
            IF vr_critica_data THEN
              vr_des_erro:= 'Cob. Emprestimo. - Valor informado '||
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

          /* Mensagem informando a composi��o do valor docto */
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
      IF vr_critica_data AND pr_cod_operador <> 'DDA' THEN
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
       WHEN OTHERS THEN
         pr_cdcritic:= 0;
         pr_dscritic:= 'Erro na rotina CXON0014.pc_retorna_vlr_titulo_iptu. '||SQLERRM;
    END;
  END pc_retorna_vlr_titulo_iptu;

  /* Calcular Digito verificador Modulo 11 */
  PROCEDURE pc_verifica_digito (pr_nrcalcul IN VARCHAR2       --Numero a ser calculado
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
          vr_peso:= 2;
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
  --  Sistema  : Retonar o ano do c�digo barras
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

  /* Retonar a data do c�digo barras em dias */
  FUNCTION fn_retorna_data_dias (pr_nrdedias  IN INTEGER  --Numero de Dias
                                ,pr_inanocal  IN INTEGER) --Indicador do Ano
  RETURN DATE IS
--------------------------------------------------------------------------------------------------------------
  --
  --  Programa : fn_retorna_data_dias          Antigo: dbo/b1crap14.p/retorna-data-dias
  --  Sistema  : Retonar a data do c�digo barras em dias
  --  Sigla    : CXON
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Agosto/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retonar o ano do c�digo barras

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
  --  Data     : Agosto/2013.                   Ultima atualizacao: 11/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para validacoes Sicredi
  --
  -- Altera��es: 27/07/2015 - Tratamento da vr_dttolera conforme faz no programa progress (Lucas Ranghetti/Elton)
  --
  --             28/07/2015 - Adicionar crapscn.dsoparre <> 'E' no cursor do crapscn (Lucas Ranghetti #234418)
  --
  --             11/11/2015 - Fechar cursor cr_lft_ult_pag_sicredi que estava permanecendo aberto quando
  --                          nao encontrava registro. (Fabricio)
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
      rw_crapscn cr_crapscn%ROWTYPE;
      --selecionar transacao de convenio
      CURSOR cr_crapstn (pr_cdempres IN crapstn.cdempres%type
                        ,pr_tpmeiarr IN crapstn.tpmeiarr%type) IS
        SELECT crapstn.cdempres
              ,crapstn.tpmeiarr
              ,crapstn.dstipdrf
        FROM crapstn
        WHERE crapstn.cdempres = pr_cdempres
        AND   crapstn.tpmeiarr = pr_tpmeiarr;
      rw_crapstn cr_crapstn%ROWTYPE;

      CURSOR cr_lft_ult_pag_sicredi (pr_cdcooper      IN craplft.cdcooper%type
                                    ,pr_codigo_barras IN VARCHAR2
                                    ,pr_cdhistor      IN craplft.cdhistor%type
                                    ,pr_tpfatura      IN craplft.tpfatura%type) IS
        SELECT /*+index (lft CRAPLFT##CRAPLFT5) */
               lft.dtvencto
          FROM craplft lft
         WHERE lft.cdcooper = pr_cdcooper
           AND UPPER(lft.cdbarras) = pr_codigo_barras -- UPPER necess�rio pois o index lft5 est� com upper
           AND lft.cdhistor = pr_cdhistor
           AND lft.tpfatura <> pr_tpfatura
           AND lft.dtvencto > ADD_MONTHS(SYSDATE,-60) -- Verifica apenas os �ltimos 5 anos pois o sicredi tamb�m
                                                        -- valida os pagamentos feitos em at� 5 anos.
        ORDER BY lft.dtvencto DESC
      ;
      rw_lft_ult_pag_sicredi cr_lft_ult_pag_sicredi%ROWTYPE;


      --Variaveis Locais
      vr_hhsicini  INTEGER;
      vr_hhsicfim  INTEGER;
      vr_contador  INTEGER;
      vr_dttolera  DATE;
      vr_dtferiado DATE;
      vr_inanocal  INTEGER;
      vr_flgachou  BOOLEAN;
      vr_tpmeiarr  VARCHAR2(1);
      vr_nrdcaixa  INTEGER;
      vr_dstextab  craptab.dstextab%TYPE;
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

      /* Valida��o para saber se o convenio possui o meio de arrecadacao utilizado */
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

      /* Validacao para nao aceitar DARFs e DAS na Internet/TAA/ */
      IF pr_cod_agencia IN (90,91) THEN  /* TAA OU Internet*/
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
      -- Verifica se a data esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;
      /* N�o repete validacao ja realizada se for Agendamento */
      IF pr_idagenda <> 2 THEN
        /* Valida��o referente aos dias de tolerancia */
        IF rw_crapscn.nrtolera <> 99 THEN /* Se nao for tolerancia ilimitada */
          IF nvl(rw_crapstn.dstipdrf, ' ') <> ' '  OR
             rw_crapscn.cdempres = 'K0' THEN
            /* DARF PRETO EUROPA */
            IF pr_cdempcon IN (64,153) AND pr_cdsegmto = 5 THEN /* DARFC0064 ou DARFC0153 */
              --Retornar ano
              vr_inanocal:= CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_codigo_barras,20,1))
                                                            ,pr_darfndas => FALSE);
              --Retornar data dias
              vr_dttolera:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_codigo_barras,21,3)) --Numero de Dias
                                                         ,pr_inanocal => vr_inanocal); --Indicador do Ano
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
            IF rw_crapdat.dtmvtocd > vr_dttolera THEN
              --Montar mensagem erro
              vr_cod_erro:= 0;
              vr_des_erro:= 'Prazo para pagamento apos o vencimento excedido.';
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
          ELSE  /* Nao eh DARF/DAS */
            BEGIN
            vr_dttolera:= TO_DATE(gene0002.fn_mask(SUBSTR(pr_codigo_barras,26,2),'99')|| '/'||
                                  gene0002.fn_mask(SUBSTR(pr_codigo_barras,24,2),'99')|| '/'||
                                  gene0002.fn_mask(SUBSTR(pr_codigo_barras,20,4),'9999'),'DD/MM/YYYY');
            --Iniciar contador
            vr_contador:= 1;
            --Dia toleracia
            IF rw_crapscn.dsdiatol = 'U' THEN /* Dias �teis */
              LOOP
                --Incrementa dia tolerancia
                vr_dttolera:= vr_dttolera + 1;
                --Verifica se eh feriado ou final de semana
                vr_dtferiado:= GENE0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper --> Cooperativa conectada
                                                          ,pr_dtmvtolt => vr_dttolera --> Data do movimento
                                                          ,pr_tipo     => 'P');       --> Proximo dia util
                --Se for data diferenteeh feriado ou final semana
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
               rw_crapdat.dtmvtocd > vr_dttolera THEN
              --Montar mensagem erro
              vr_cod_erro:= 0;
              vr_des_erro:= 'Prazo para pagamento apos o vencimento excedido.';
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
            EXCEPTION
            WHEN OTHERS THEN
              NULL;
            END;
          END IF;
        END IF;
      END IF;

      --Selecionar lancamentos de fatura
      OPEN cr_lft_ult_pag_sicredi (pr_cdcooper      => pr_cdcooper
                                  ,pr_codigo_barras => pr_codigo_barras
                                  ,pr_cdhistor      => 1154
                                  ,pr_tpfatura      => 2);
      --Posicionar no proximo registro
      FETCH cr_lft_ult_pag_sicredi INTO rw_lft_ult_pag_sicredi;

      -- Se encontrar fatura j� paga:
      IF cr_lft_ult_pag_sicredi%FOUND THEN

        CLOSE cr_lft_ult_pag_sicredi;

        vr_cod_erro := 0;

        vr_des_erro := 'Fatura ja arrecadada dia ' ||
                       to_char(rw_lft_ult_pag_sicredi.dtvencto,'dd/mm/RRRR') || '.';

        -- se o pagamento for no caixa on-line gerar a cr�tica
        IF pr_cod_agencia <> 90 AND
           pr_cod_agencia <> 91 THEN

            vr_des_erro := vr_des_erro ||  ' Para consultar o canal de recebimento, verificar na tela PESQTI.';

        ELSE -- senao, � internet/mobile (cdagenci = 90) ou TA (cdagenci = 91)

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

  -- Alteracoes: 29/05/2014 - Removido as validacoes para Sicredi (1154), Samae
  --                          Jaragua (396), DARE Sefaz (1063). Alterado o tamanho do
  --                          substr do codigo de barras. (Douglas - Chamado 128278)
  --
  --             18/06/2014 - Removido as validacoes para GNRE - SEFAZ (1065).
  --                          (Douglas - Chamado 128278)
  --
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

      CASE pr_cdhistor
      WHEN 308 THEN /*  Telesc Brasil Telecom  */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,20,20));
      WHEN 374 THEN     /*  Embratel  */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,21,13));
      WHEN 398 THEN     /* Prefeitura Gaspar */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,20,25));
      WHEN 663 THEN      /* Prefeitura de Pomerode */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,20,25));
      WHEN 456 THEN      /* Aguas Itapema */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,30,13));
      WHEN 964 THEN      /* Aguas de Massaranduba */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,30,13));
      WHEN 618 THEN      /* Samae Pomerode */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,25,14));
      WHEN 899 THEN     /* Samae Rio Negrinho */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,25,14));
      WHEN 625 THEN      /* CELESC */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,27,16));
      WHEN 666 THEN      /* CELESC */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,27,16));
      WHEN 659 THEN      /* P.M.Itajai */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 464 THEN      /* Aguas Pres.Getulio */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 929 THEN       /* CERSAD */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 963 THEN      /* Foz do Brasil */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,17));
      WHEN 671 THEN      /**DAE Navegantes**/
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,29,14));
      WHEN 373 THEN      /**IPTU Blumenau**/
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,28,15));
      WHEN 675 THEN       /** SEMASA Itajai **/
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,30,14));
      ELSE /*  Casan e outros */
        pr_cdseqfat:= TO_NUMBER(SUBSTR(pr_codigo_barras,7,38));
      END CASE;
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
  --  Data     : Julho/2013.                   Ultima atualizacao: 27/07/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para retornar valores fatura
  --
  -- Alteracoes: 27/07/2015 - Na chamada da CXON0014.pc_validacoes_sicredi adicionado validacao
  --                          de critica (Lucas Ranghetti #312583 )
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Selecionar cadastro empresas conveniadas
      CURSOR cr_crapcon (pr_cdcooper IN crapcon.cdcooper%type
                        ,pr_cdempcon IN crapcon.cdempcon%type
                        ,pr_cdsegmto IN crapcon.cdsegmto%type) IS
        SELECT crapcon.cdcooper
              ,crapcon.flgcnvsi
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

      --Variaveis Locais
      vr_nrdcaixa INTEGER;
      vr_lindigit NUMBER;
      vr_fatura   NUMBER;
      vr_calc     VARCHAR2(100);
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
      objeitvo de n�o validar hor�rio de limite de pagamento SICREDI */
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
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
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

            -- Identifica��o de Fatura
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
         --Retornar C�digo barras
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
      IF rw_crapcon.flgcnvsi = 1 THEN
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
          --Levantar Excecao
          RAISE vr_exc_erro;
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
      /* P.M. ITAJAI */
      IF rw_crapcon.cdempcon = 2044 AND rw_crapcon.cdsegmto = 1 THEN
        --Data movimento anterior
        vr_dtmvtoan:= To_Char(rw_crapdat.dtmvtoan,'YYYYMMDD');
        IF To_Number(SUBSTR(pr_codigo_barras,20,8)) <= To_Number(vr_dtmvtoan) THEN
          --Criar Erro
          CXON0000.pc_cria_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cod_agencia
                               ,pr_nrdcaixa => vr_nrdcaixa
                               ,pr_cod_erro => 0
                               ,pr_dsc_erro => 'Nao eh possivel efetuar esta operacao, pois a fatura esta vencida.'
                               ,pr_flg_erro => TRUE
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);
          IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Nao eh possivel efetuar esta operacao, pois a fatura esta vencida.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
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
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
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
                                            rw_craplft.vlrmulta),'fm999g999g999g990d00')|| '    ';
      ELSE
        vr_tab_literal(vr_iLnAut):= '    N. DO DOCUMENTO:    '||
                                    gene0002.fn_mask(vr_cdseqfat,'99.99.99999.9999999-9')|| '    ';
      END IF;
      --Incrementar linha
      vr_iLnAut:= vr_iLnAut+1;
      IF  vr_tpdarf = 1 THEN
        vr_tab_literal(vr_iLnAut):= LPad(' ',48,' ');
      ELSE
        vr_tab_literal(vr_iLnAut):= '    VALOR TOTAL (R$):      '||
                                    TO_CHAR((rw_craplft.vllanmto + rw_craplft.vlrjuros +
                                            rw_craplft.vlrmulta),'fm999g999g999g990d00')|| '    ';
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
        --Fechar Cursor
        CLOSE cr_crapaut;

      END IF;
      --Fechar Cursor
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
  --  Data     : Agosto/2013.                   Ultima atualizacao: 14/08/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para gerar as faturas
  --
  -- Altera��o: 30/12/2014 - Ajuste na leitura da CRAPLOT, para reservar o registro(lock)
  --                         conforme no progress(Odirlei-AMcom)
  --
  --            25/06/2015 - Ajuste na cria��o do lote, para assim que inserir dar o commit
  --                         com pragma autonomos_transaction, para liberar o registro e minimizar
  --                         o tempo de lock da tabela lote(Odirlei-AMcom)
  --
  --            24/07/2015 - Incluido nvl nas verifica��es  = 0, para garantir a valida��o do campo
  --                         (Odirlei - AMcom)
  --
  --            28/07/2015 - Ajuste para testar se a tabela craplot esta lockada antes de realizar o update
  --                         assim evitando custo do banco para gerenciar lock(Odirlei-Amcom)
  --
  --             30/07/2015 - Alterado para n�o fazer o atualiza��o do lote qnd for agencia = 90 Internet
  --                          nestes casos ir� atualizar na paga0001, diminuindo tempo de lock da tabela (Odirlei-Amcom)
  --
  --             14/08/2015 - pc_gera_titulo_iptu e pc_gera_faturas -> inclus�o do parametro pr_tpcptdoc, para identificacao do tipo de captura
  --                          (leitora ou manual(linha digitavel)) (Odirlei-AMcom)
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
      vr_nrcpfcgc NUMBER;
      vr_registro ROWID;
      --Tipo de registro de data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
      --Variaveis erro
      vr_cod_erro INTEGER;
      vr_des_erro VARCHAR2(1000);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecao
      vr_exc_erro EXCEPTION;

      -- Procedimento para inserir o lote e n�o deixar tabela lockada
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
                  ,craplot.nrseqdig
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
                  ,1  -- craplot.nrseqdig
                  ,13 -- craplot.tplotmov
                  ,pr_cdoperad
                  ,0
                  ,pr_nrdcaixa
                  ,pr_cdoperad)
             RETURNING craplot.dtmvtolt
                      ,craplot.cdagenci
                      ,craplot.cdbccxlt
                      ,craplot.nrdolote
                      ,craplot.nrseqdig
                      ,craplot.qtcompln
                      ,craplot.qtinfoln
                      ,craplot.vlcompcr
                      ,craplot.vlinfocr
                      ,craplot.ROWID
                 INTO  rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.qtcompln
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.vlcompcr
                      ,rw_craplot.vlinfocr
                      ,rw_craplot.rowid;
        ELSE
          -- ou atualizar o nrseqdig para reservar posi��o
          UPDATE craplot
             SET craplot.nrseqdig = Nvl(craplot.nrseqdig,0) + 1
           WHERE craplot.ROWID = rw_craplot.ROWID
           RETURNING craplot.nrseqdig INTO rw_craplot.nrseqdig;
        END IF;

        CLOSE cr_craplot;

        -- retornar informa��es para o programa chamador
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
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
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
      IF rw_crapcon.flgcnvsi = 1 THEN
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
        IF pr_vlfatura < 10 AND rw_crapscn.cdempres IN ('K0','147','149','145','608') THEN
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
      END IF;

      -- Controlar cria��o de lote, com pragma
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
          )
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
          ,Nvl(rw_craplot.nrseqdig,0)
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
          )
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
        /* Calculo da Data Limite */
        --Retornar ano do codigo barras
        vr_inanocal:= CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,20,1))
                                                      ,pr_darfndas => FALSE);
        --Retornar data dias
        vr_dtlimite:= CXON0014.fn_retorna_data_dias(pr_nrdedias => To_Number(SUBSTR(pr_cdbarras,21,3)) --Numero de Dias
                                                   ,pr_inanocal => vr_inanocal); --Indicador do Ano
        /* Calculo do Periodo de Apuracao */
        --Retornar ano do codigo barras
        vr_inanocal:= CXON0014.fn_retorna_ano_cdbarras(pr_innumano => TO_NUMBER(SUBSTR(pr_cdbarras,41,1))
                                                      ,pr_darfndas => FALSE);
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
                             ,craplft.tpfatura = 2  /* ( Darf � ARF) */
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
                             ,craplft.tpfatura = 2  /* ( Darf � ARF) */
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
                                              ,pr_cdcritic     => vr_cdcritic          --C�digo do erro
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

      -- Apenas atualizar o lote se n�o for pagamento pela INTERNET
      -- pagamentos pela Internet, atualizacao do lote ser� na paga0001.pc_paga_convenio
      IF pr_cod_agencia <> 90 THEN

        /* Tratamento para buscar registro de lote se o mesmo estiver em lock, tenta por 10 seg. */
        FOR i IN 1..100 LOOP
          BEGIN
            -- Leitura do lote
            OPEN cr_craplot_rowid (pr_rowid  => rw_craplot.rowid);
            FETCH cr_craplot_rowid INTO rw_craplot_rowid;
            CLOSE cr_craplot_rowid;
            vr_dscritic := NULL;
            EXIT;
          EXCEPTION
            WHEN OTHERS THEN
               IF cr_craplot_rowid%ISOPEN THEN
                 CLOSE cr_craplot_rowid;
               END IF;

               -- setar critica caso for o ultimo
               IF i = 100 THEN
                 vr_dscritic:= 'Registro de lote '||rw_craplot.nrdolote||' em uso. Tente novamente.';
               END IF;
               -- aguardar 0,5 seg. antes de tentar novamente
               sys.dbms_lock.sleep(0.1);
          END;
        END LOOP;

        -- se encontrou erro ao buscar lote, abortar programa
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;

        /* Atualiza o lote na craplot por ultimo para tentar manter menos tempo em lock */
        BEGIN
          UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                            ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + pr_vlfatura
                            ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + pr_vlfatura
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic:= 0;
            pr_dscritic:= 'Erro ao atualizar tabela craplot. '||SQLERRM;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END;
      END IF;
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
                                       ,pr_cdcritic     OUT INTEGER      --C�digo do erro
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
  --  Data     : Agosto/2014.                   Ultima atualizacao: 24/07/2015
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
  --               01/12/2014 - Ajustes ref. aos boletos da Incorpora��o. (Rafael)
  --
  --               24/07/2015 - Ajuste na verifica��o do campo de nrdconta = 0, pois o campo pode estar nulo
  --                            SD312105 (Odirlei-AMcom)
  --
  --               13/05/2016 - Inclusao da critica '980 - Convenio do cooperado bloqueado'
  --                            PRJ318 - Nova Plataforma de cobran�a (Odirlei-AMcom)             
  ---------------------------------------------------------------------------------------------------------------
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
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
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
                    -- n�o eh cooperado migrado e nao tem CEB, Liq Interbancaria
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
                  -- n�o eh cooperado migrado, Liq Interbancaria
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

                /* liq interbancaria (nesse caso, de outra cooperativa) */
                RAISE vr_exc_saida;

             END IF; -- craptco%FOUND
          END IF; -- cr_crapceb1%FOUND

          -- Verificar se o Convenio do cooperado est� bloqueado
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


END CXON0014;
/
