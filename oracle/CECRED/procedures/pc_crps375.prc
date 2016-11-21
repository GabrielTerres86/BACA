CREATE OR REPLACE PROCEDURE CECRED.pc_crps375( pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo da cooperativa
                                        ,pr_flgresta IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                                        ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                        ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                        ,pr_nmtelant IN VARCHAR2                --> Descricao da tela anterior
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da critica
                                        ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da critica
  BEGIN
  /* ............................................................................

     Programa: pc_crps375  (Antigo: Fontes/crps375.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Mirtes
     Data    : Dezembro/2003.                  Ultima atualizacao: 15/02/2016

     Dados referentes ao programa:

     Frequencia: Diario (Batch).
     Objetivo  : Atende a solicitacao 1.(Exclusivo)
                 Integrar arquivos do BANCO BRASIL  de COBRANCA.
                 Emite relatorio 325.

     Alteracao : 23/03/2004 - Prever Juros(Mirtes)

                 30/03/2004 - Prever Abatimento(Mirtes)

                 08/09/2004 - Desprezar apenas registro com problemas(Mirtes)

                 20/12/2004 - Tratamento de Erros - Segura (Ze Eduardo).

                 28/02/2005 - Tratamento COMPEFORA (Ze Eduardo).

                 15/04/2005 - Tratamento para a importacao do cadastramento
                              dos bloquetos (Ze).

                 21/09/2005 - Tratamento na geracao do arquivo retorno (Ze).

                 23/09/2005 - Modificado FIND FIRST para FIND na tabela
                              crapcop.cdcooper = glb_cdcooper (Diego).

                 30/09/2005 - Acertos no programa (ZE).

                 15/12/2005 - Tratamento COMPEFORA (Ze).

                 20/03/2006 - Trocar consulta no craptab pelo crapcco (Julio/Ze)

                 16/06/2006 - Acerto no arquivo de Retorno (Ze).

                 08/08/2006 - Acerto no crapass.inarqcbr e Convenio com 7 digitos
                              crapceb (Ze).

                 03/10/2006 - Separar arquivos de retorno por conta e por
                              convenio (Julio)

                 09/11/2006 - Envio de email pela BO h_b1wgen0011 (David).

                 05/12/2006 - Mover arquivo de anexo do e-mail para o diretorio
                              salvar (David).

                 22/12/2006 - Incluido no relatorio o nosso numero completo e o
                              convenio (Evandro).

                 22/03/2007 - Erro nrdocmto quando taxa (Magui).

                 12/04/2007 - Retirar rotina de email em comentario (David).

                 30/07/2007 - Enviar email somente para quem estar cadastrado
                              na tela CONTAS e nao mais pelo convenio (ZE).

                 05/03/2008 - Nao criar arquivo de retorno para quem nao estiver
                              cadastrado na tela CONTAS (Ze).

                 12/09/2008 - Alterado campo crapcob.cdbccxlt -> crapcob.cdbandoc
                              (Diego).

                 08/10/2008 - Incluida variaveis para tratamento de desconto de
                              titulos (Elton).

                 10/11/2008 - Incluir controles na selecao de arquivos para
                              importacao (Ze).

                 17/03/2009 - Incluir campo banco e agencia pagto. (Ze).

                 22/06/2009 - Incluir variavel h_b1wgen0023 (Guilherme).

                 18/09/2009 - Ajustes gerais no programa:
                              - Alteracao do FORM totais para incluir novos
                                campos e ajustar variaveis;
                              - Criacao de procedures para estruturacao do codigo
                              - Utilizacao da BO b1wgen0010 para geracao de
                                arquivos de retorno no layout FEBRABAN e OUTROS;
                              - Passagem dos codigos (Procedures) para a BO
                                b1wgen0010
                               (GATI - Eder)

                 29/09/2009 - Tratamento para registro "Y" - Cheques (David).

                 29/10/2009 - Alteracao do relatorio final para apresentar
                              detalhes do cheque (GATI - Eder)

                 17/02/2010 - Realizar inconsistencia 592 apenas para
                              convenio "IMPRESSO PELO SOFTWARE"

                 16/09/2010 - Executar CoopCop mediante parametrizacao na CADCCO
                              (Guilherme/Supero)

                 12/11/2010 - Alteracoes no p_gera_arquivo e crawcta
                              (Guilherme/Supero)

                 14/12/2010 - Inclusao de Transferencia de PAC quando coop 2
                              (Guilherme/Supero)

                 06/01/2011 - Ajuste na condicao para tarifa (David).

                 18/01/2011 - Incluido os e-mails:
                              - fabiano@viacredi.coop.br
                              - moraes@viacredi.coop.br
                              Criado tratamento para atualizar os boletos da
                              Acredicoop para liquidados (Adriano).

                 15/03/2011 - Nao criticar quando crapcob inexistente.
                              Lancamento unificado (Gabriel).

                 29/03/2011 - Acerto na alimentacao do campo tt-regimp.nrdconta
                            - Temporariamente passar FALSE para flgcruni
                              (Guilherme)

                 08/04/2011 - Substituicao dos campos inarqcbr e dsdemail da
                              crapass para a crapceb. Ativar flgcruni (Gabriel).

                 03/05/2011 - Criacao do crapceb quando criado o crapcob
                              (Gabriel).

                 16/05/2011 - Nao sera mais enviado o relatorio 325 para o e-mail
                              fabiano@viacredi.coop.br (Adriano).

                 16/05/2011 - Gravar no dsidenti da lcm a quantidade de boletos
                              (Gabriel).

                 02/06/2011 - Processar titulos somente da cobranca sem registro
                              (Rafael).

                 03/06/2011 - Alterado destinatario do envio de email na procedure
                              gera_relatorio_203_99;
                              De: thiago.delfes@viacredi.coop.br
                              Para: brusque@viacredi.coop.br. (Fabricio)

                 11/08/2011 - Ajuste quando o arquivo for rejeitado e
                              Caracter invalido em entrada numerica X (Ze).

                 16/08/2011 - Tratamento para nao integrar contas inexistentes
                              Trf. 41903 (Ze).

                 23/12/2012 - Tratar CEB de um cooperado que utilizou o CEB
                              errado (Credelesc) conforme Trf. 44309 (Rafael).

                 12/06/2012 - Ajuste no sequencial do arquivo e validar historico
                              do convenio (David Kistner)

                 18/06/2012 - Alteracao na leitura da craptco (David Kruger).

                 10/07/2012 - Ajuste na rotina cria-ceb-cob: criar titulo somente
                              se o cooperado possuir convenio (Rafael).

                 18/09/2012 - Ajuste nos titulos pagos com cheque (Rafael).

                 19/09/2012 - Omitir critica 922 de tit pagos com cheque (Rafael).

                 02/10/2012 - Criar relatorio 627 referente a titulos pagos
                              com cheque (Rafael).

                 22/11/2012 - Tratamento para titulos das contas migradas
                              (Viacredi -> Alto Vale). Alimentado tabela crapafi
                              para acerto financeiro entre as singulares,
                              por parte da Cecred. (Fabricio)

                 04/01/2013 - Apagar registro na cratarq quando arquivo nao
                              for valido ou convenio nao cadastrado. (Rafael)

                 11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                              consulta da craptco (Tiago).

                 24/01/2013 - Utilizar vlr da tarifa do banco ao realizar
                              acerto financeiro de titulos migrados. (Rafael)

                 15/02/2013 - Tratamento para nro. CEB com cinco digitos;
                              convenio "1343313". (Fabricio)

                 26/02/2013 - Nao considerar insitceb na pesquisa CEB do
                              convenio do cooperado. (Rafael)

                 10/06/2013 - Remover titulo do bordero de desconto em estudo
                              no processo de liquidacao de titulo. (Rafael)

                 24/06/2013 - Ajuste nos lanctos de Acerto Financeiro entre
                              contas migradas BB. (Rafael)

                 25/06/2013 - Alimentar as informacoes de valor e historico
                              de tarifas a partidar da procedure
                              carrega_dados_tarifa_cobranca da b1wgen0153 e nao
                              mais da crapcco, nao criar mais craplot e nem
                              craplcm e sim criar lancamento na craplat
                              atraves da b1wgen0153 (Tiago).

                 08/08/2013 - Alterado a procedure "efetiva_atualizacoes_compensacao"
                              incluso processo busca tarifa e historico  utilizando
                              rotina b1wgen0153. (Daniel)

                 25/09/2013 - Incluso novo parametro aux_cdpesqbb na chamada da procedure
                              efetua-lanc-craplat. (Daniel)

                 27/09/2013 - Alterado valor recebido pelo campo crapafi.vllanmto (Daniel).

                 11/10/2013 - Incluido parametro cdprogra nas procedures da
                              b1wgen0153 que carregam dados de tarifas (Tiago).

                 23/10/2013 - Conversao Progress -> Oracle (Edison - AMcom)

                 31/10/2013 - Alterado totalizador de 99 para 999. (Reinert)

                 07/11/2013 - Nova forma de chamar as agências, de PAC agora
                              a escrita será PA (Guilherme Gielow)

                 30/12/2013 - Ajuste no processo de liquidacoes de titulos
                              migrados e no acerto financeiro BB. (Rafael)

                 17/01/2014 - Ajustes na pc_busca_nome_arquivos pois estava-se utilizando
                              o parâmetro de saída para manter o código da critica, o que
                              causava parada no processo com erro (Marcos-Supero)

                 17/01/2014 - Ajuste da versao ref. alteracoes efetuadas no
                              progress no dia 30/12/2013 (Edison - AMcom)

                 08/01/2014 - Adicionado "VALIDATE <tabela>" apos o create de
                              registros nas tabelas. (Rafael).

                 15/01/2014 - Ajuste na rotina de geracao de boletos pagos
                              do convenio "IMPRESSO PELO SOFTWARE" quando
                              cooperado migrou para outra cooperativa (Rafael).

                 24/01/2014 - Ajuste na gravacao do valor da tarifa no arquivo
                              de retorno ao cooperado. (Rafael)
                              - Incluido bloco "DO: END." que foi retirado
                              indevidamente na versaode 30/12/2013 no processo
                              de migracao, que realiza o processamento somente
                              dos titulos validos para a cooperativa. (Rafael)

                 31/01/2014 - Ajuste da versao ref. alteracoes efetuadas no
                              progress no dia 24/01/2014 (Edison - AMcom)

                 21/03/2014 - Ajustes nas chamadas de envio de e-mail para que
                              não seja mais enviado ao log (Marcos-Supero)

                 06/05/2014 - Incluso tratamento para sempre inicializar a variavel
                              vr_craptco_efet com FALSE (Daniel)

                 07/05/2014 - Incluso nova leitura crapceb (cr_crapceb_arq) quando
                              MIGRACAO e nrdconta = 0 (Daniel)

                 13/05/2014 - Efetuar os comandos unix somente antes de comitar
                              os dados (Andrino - RKAM)

                 25/07/2014 - Ajuste no cursor  cr_crapceb4, incluido filtro
                              pelo campo nrcnvceb e retirada dos tratamentos de
                              nrcnvceb com 5 digitos, deve ter apenas 4 digitos (Odirlei -AMcom)

                 29/08/2014 - Projeto 198-Viacon - Incorporacao Concredi e
                              Credimilsul. (Rafael) - Liberação Nov/2014

                 23/09/2014 - Ajuste na pc_atualiza_lancamentos_baixa para inicializar valor
                              flgregis = false, para que gere as informaçoes corretamente, visto que estava ficando
                              nulo, gerando diferença nos relatorios contabeis de ajustes (Odirlei-AMcom)

                 25/09/2014 - Trata leitura dos arquivos para ao fazer to_number, antes fazer trim
                              retirando os espaços em branco para que não apresente erro de invalid_number
                              (Odirlei-AMcom)

                 29/10/2014 - Ajuste cancelamento noturno. Nao estava sendo tratado se a variavel vr_indmigracaocob
                              era nula, cancelando o programa (Andrino - RKAM)

                 04/11/2014 - Projeto 198-Viacon - Incorporacao Concredi e
                              Credimilsul - Ajustes na busca do cooperado na craptco (Odirlei-AMcom)

                 04/12/2014 - Ajuste na pc_processa_arq_compensacao na leitura da tabela craptco,
                              pois dependento do tipo de convenio deverá verificar se é conta migrada pela
                              numero da conta nova(identificaco pela ceb) ou numero de conta antiga(vinda do arquivo) (Odirlei-AMcom)

                 08/12/2014 - Ajustado comando insert na crapafi(Odirlei-AMcom)

                 10/12/2014 - Retirado tratamento para criação dos registros da tabela crapafi para as contas incorporadas,
                              pois não será necessarios gerar ajuste financeiro, pois cooper antiga não existe mais(Odirlei-AMcom)

                 10/12/2014 - Melhorias de Performance. Foi retirada a temp_table vr_tab_crapass e utilizado o
                              cursor cr_crapass para selecionar as informações para cada conta. Nas cooperativas
                              maiores não vale a pena selecionar todo mundo para processar apenas algumas contas.
                              (Alisson - AMcom)

                 12/01/2015 - Ajustado o programa para tratar os boletos de incorporacao que
                              na cooperativa de origem eram de convenios Pre-Impresso
                              SD240149 (Odirlei-AMcom)

                 
                 05/10/2015 - Incluido informacao de nosso numero na gravacao do crapcob
                              SD339759 (Odirlei-AMcom)
                 
                 12/11/2015 - Alterado para quando o convenio utilizar CEB e não contem a informação no
                              arquivo, tentar identificar atraves do CRAPCOB SD356323 (Odirlei-AMcom)                              

                 15/02/2016 - Inclusao do parametro conta na chamada da
                              TARI0001.pc_carrega_dados_tarifa_cobr. (Jaison/Marcos)

				 08/03/2016 - Correção do direcionamento das mensagens de log do programa para 
							  proc_message.log conforme SD 403079 (Carlos Rafael Tanholi)			                             

  ............................................................................ */

    DECLARE
      -- Tipo de registro dos registros importados dos arquivos - boletos
      TYPE typ_reg_regimp IS
        RECORD(  cdcooper crapcop.cdcooper%TYPE
                ,codbanco crapcob.cdbandoc%TYPE
                ,nroconve crapcob.nrcnvcob%TYPE
                ,cdagenci craprej.cdagenci%TYPE
                ,nrdctabb crapcob.nrdctabb%TYPE
                ,nrdocmto crapcob.nrdocmto%TYPE
                ,vllanmto craplcm.vllanmto%TYPE
                ,vlrtarif craplcm.vllanmto%TYPE
                ,dtpagto  craplcm.dtmvtolt%TYPE
                ,nrctares craprej.nrdconta%TYPE
                ,nrseqdig craprej.nrseqdig%TYPE
                ,nrdolote craprej.nrdolote%TYPE
                ,nrdconta crapass.nrdconta%TYPE
                ,codmoeda NUMBER(1)
                ,identifi VARCHAR(20)
                ,codcarte NUMBER(9)
                ,juros    craplcm.vllanmto%TYPE
                ,vlabatim craplcm.vllanmto%TYPE
                ,incnvaut BOOLEAN
                ,dsorgarq VARCHAR2(100)
                ,nrcnvceb INTEGER
                ,cdpesqbb craprej.cdpesqbb%TYPE
                ,cdbanpag crapcob.cdbanpag%TYPE
                ,cdagepag crapcob.cdagepag%TYPE
                ,nmarquiv VARCHAR2(100)
                ,inarqcbr crapceb.inarqcbr%TYPE
                ,dtdgerac DATE
                ,flpagchq BOOLEAN
                ,dcmc7chq VARCHAR2(100)
                ,dscheque VARCHAR2(100)
                ,cdocorre INTEGER
                ,vldpagto craplcm.vllanmto%TYPE
                ,vltarbco NUMBER
                ,cdhistor INTEGER
                ,cdfvlcop INTEGER
                ,first_of BOOLEAN
                ,last_of  BOOLEAN
                -- 16012014
                ,incoptco BOOLEAN
                ,nrctaant craptco.nrctaant%TYPE
                ,cdcopant craptco.cdcopant%TYPE
                );

      TYPE typ_tab_regimp IS
        TABLE OF typ_reg_regimp
        INDEX BY VARCHAR2(100);

      -- Tipo de registro para arquivos das contas processadas para
      -- geracao dos arquivos de retorno - layout febraban
      TYPE typ_reg_crawcta IS
        RECORD( nrdconta crapass.nrdconta%TYPE
                ,dsstring VARCHAR2(240)
                ,nrsequen INTEGER
                ,nrconven INTEGER
                ,nrctabbd INTEGER
                ,reg      INTEGER
                ,qtde_reg INTEGER );

      TYPE typ_tab_crawcta IS
        TABLE OF typ_reg_crawcta
        INDEX BY VARCHAR2(100);

      -- Tipo de registro para contas migradas
      TYPE typ_reg_migracaocob IS
        RECORD( nrdctabb crapcob.nrdctabb%TYPE
               ,cdcopdst INTEGER
               ,nrctadst crapcob.nrdconta%TYPE
               ,cdagedst crapcco.cdagenci%TYPE
               ,cdhistor craplcm.cdhistor%TYPE
               ,vllanmto craplcm.vllanmto%TYPE
               ,vlrtarif craplcm.vllanmto%TYPE
               ,dsorgarq crapcco.dsorgarq%TYPE
               ,nroconve crapcob.nrcnvcob%TYPE
               --16012014
               ,nmrescop crapcop.nmrescop%TYPE
               ,qttitmig INTEGER
               ,nmarquiv VARCHAR2(100)
               );

      TYPE typ_tab_migracaocob IS
        TABLE OF typ_reg_migracaocob
        INDEX BY VARCHAR2(100);

      -- Tipo de registro para armazenar as informações dos arquivos
      -- que serao processados
      TYPE typ_reg_cratarq IS
        RECORD(  flgmarca BOOLEAN
                ,cdcooper INTEGER
                ,nmarquiv VARCHAR2(100)
                ,nrsequen INTEGER
                ,nmquoter VARCHAR2(100)
                ,nrseqdig INTEGER
                ,vllanmto NUMBER
                ,cdagenci INTEGER /* PAC */
                ,cdbccxlt INTEGER /* Banco/Caixa */
                ,nrdolote INTEGER /* Numero do Lote */
                ,tplotmov INTEGER /* Tipo do Lote */
                ,nroconve INTEGER /* Numero do Convenio */
                ,qtregrec INTEGER /* Qtde de boletos recebidos */
                ,qtregicd INTEGER /* Qtde de boletos integrados COM desconto */
                ,qtregisd INTEGER /* Qtde de boletos integrados SEM desconto */
                ,qtregrej INTEGER /* Qtde de boletos rejeitados */
                ,vlregrec NUMBER /* Vlr dos boletos recebidos */
                ,vlregicd NUMBER /* Vlr dos boletos integrados COM desconto */
                ,vlregisd NUMBER /* Vlr dos boletos integrados SEM desconto */
                ,vlregrej NUMBER /* Vlr dos boletos rejeitados */
                ,vltarifa NUMBER /* Vlr total das tarifas dos boletos */
                ,cdhistor INTEGER /* Historico do lancamento do valor do titulo */
                ,cdtarhis INTEGER /* Historico do lancamento da tarifa do titulo */
                ,vlrtarif NUMBER /* Valor da tarifa por boleto cfme. convenio */
                ,qtdmigra INTEGER /* Qtd de titulos migrados - Alto Vale */
                ,vlrmigra NUMBER /* Vlr dos titulos migrados - Alto Vale */
               );

      TYPE typ_tab_cratarq IS
        TABLE OF typ_reg_cratarq
        INDEX BY VARCHAR2(100);

      -- Tipo de registro para armazenar os titulos rejeitados
      TYPE typ_reg_cratrej IS
        RECORD(  cdagenci craprej.cdagenci%TYPE
                ,cdbccxlt craprej.cdbccxlt%TYPE
                ,cdcritic craprej.cdcritic%TYPE
                ,cdempres craprej.cdempres%TYPE
                ,dtmvtolt craprej.dtmvtolt%TYPE
                ,nrdconta craprej.nrdconta%TYPE
                ,nrdolote craprej.nrdolote%TYPE
                ,tpintegr craprej.tpintegr%TYPE
                ,cdhistor craprej.cdhistor%TYPE
                ,vllanmto craprej.vllanmto%TYPE
                ,tplotmov craprej.tplotmov%TYPE
                ,cdpesqbb craprej.cdpesqbb%TYPE
                ,dshistor craprej.dshistor%TYPE
                ,nrseqdig craprej.nrseqdig%TYPE
                ,nrdocmto craprej.nrdocmto%TYPE
                ,nrdctabb craprej.nrdctabb%TYPE
                ,indebcre craprej.indebcre%TYPE
                ,dtrefere craprej.dtrefere%TYPE
                ,vlsdapli craprej.vlsdapli%TYPE
                ,dtdaviso craprej.dtdaviso%TYPE
                ,vldaviso craprej.vldaviso%TYPE
                ,nraplica craprej.nraplica%TYPE
                ,cdcooper craprej.cdcooper%TYPE
                ,nrdctitg craprej.nrdctitg%TYPE
                ,progress_recid NUMBER
                ,nmarquiv VARCHAR2(500)
               );

      TYPE typ_tab_cratrej IS
        TABLE OF typ_reg_cratrej
        INDEX BY VARCHAR2(100);

      -- tabela dos comandos de copia e de movimentacao
      TYPE typ_comando IS TABLE OF VARCHAR2(1000);


      vr_tab_descontar   paga0001.typ_tab_titulos;-- typ_tab_descontar;
      vr_tab_regimp      typ_tab_regimp;
      vr_tab_crawcta     typ_tab_crawcta;
      vr_tab_migracaocob typ_tab_migracaocob;
      vr_tab_cratarq     typ_tab_cratarq;
      vr_tab_erro        gene0001.typ_tab_erro;
      vr_tab_cratrej     typ_tab_cratrej;
      vr_tab_comando     typ_comando := typ_comando();

      --Tabela para receber arquivos lidos no unix
      vr_tab_arquivo     gene0002.typ_split;

      -- Selecionar os dados da Cooperativa
      CURSOR cr_crapcop( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nrdocnpj
              ,cop.cdagedbb
              ,cop.dsdircop
        FROM crapcop cop
        WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cadastro de emissao de bloquetos
      CURSOR cr_crapceb ( pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_nrdconta IN crapceb.nrdconta%TYPE
                         ,pr_nrconven IN crapceb.nrconven%TYPE) IS
        SELECT crapceb.inarqcbr
              ,crapceb.nrdconta
              ,crapceb.flgcruni
              ,crapceb.cddemail
              ,crapceb.nrcnvceb
              ,0 crapcob_nrdconta --busca a conta da crapcob
              ,COUNT(*) OVER() qtde_reg
        FROM   crapceb
        WHERE  crapceb.cdcooper = pr_cdcooper
        AND    crapceb.nrdconta = pr_nrdconta
        AND    crapceb.nrconven = pr_nrconven
        ORDER BY crapceb.cdcooper
                ,crapceb.nrdconta
                ,crapceb.nrconven;
      rw_crapceb cr_crapceb%ROWTYPE;

      -- historicos
      CURSOR cr_craphis( pr_cdcooper IN crapcop.cdcooper%TYPE) IS
        SELECT craphis.cdhistor
              ,craphis.dshistor
              ,craphis.indebcre
        FROM   craphis
        WHERE  craphis.cdcooper = pr_cdcooper;
      rw_craphis cr_craphis%ROWTYPE;

      -- Cursor para retornar os dados dos bloquetos de cobranca
      CURSOR cr_crapcob ( pr_cdcooper IN crapcob.cdcooper%TYPE
                         ,pr_cdbandoc IN crapcob.cdbandoc%TYPE
                         ,pr_nrdctabb IN crapcob.nrdctabb%TYPE
                         ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE
                         ,pr_nrdocmto IN crapcob.nrdocmto%TYPE
                         -- so eh utilizado a conta em uma chamada
                         ,pr_nrdconta IN crapcob.nrdconta%TYPE DEFAULT NULL) IS
        SELECT /*+ INDEX (crapcob CRAPCOB##CRAPCOB1) */
               crapcob.cdcooper
              ,crapcob.nrdconta
              ,crapcob.cdbandoc
              ,crapcob.nrdctabb
              ,crapcob.nrcnvcob
              ,crapcob.nrdocmto
              ,crapcob.dtretcob
              ,crapcob.incobran
              ,crapcob.dtdpagto
              ,crapcob.vldpagto
              ,crapcob.indpagto
              ,crapcob.cdbanpag
              ,crapcob.cdagepag
              ,crapcob.vltarifa
              ,crapcob.nrctremp
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.rowid
              ,COUNT(*) OVER() qtde_reg
        FROM   crapcob
        WHERE  crapcob.cdcooper = pr_cdcooper
        AND    crapcob.cdbandoc = pr_cdbandoc
        AND    crapcob.nrdctabb = pr_nrdctabb
        AND    crapcob.nrcnvcob = pr_nrcnvcob
        AND    crapcob.nrdconta = pr_nrdconta
        AND    crapcob.nrdocmto = pr_nrdocmto
        AND    pr_nrdconta      IS NOT NULL
        UNION
        SELECT /*+ INDEX (crapcob CRAPCOB##CRAPCOB3) */
               crapcob.cdcooper
              ,crapcob.nrdconta
              ,crapcob.cdbandoc
              ,crapcob.nrdctabb
              ,crapcob.nrcnvcob
              ,crapcob.nrdocmto
              ,crapcob.dtretcob
              ,crapcob.incobran
              ,crapcob.dtdpagto
              ,crapcob.vldpagto
              ,crapcob.indpagto
              ,crapcob.cdbanpag
              ,crapcob.cdagepag
              ,crapcob.vltarifa
              ,crapcob.nrctremp
              ,crapcob.nrctasac
              ,crapcob.dtvencto
              ,crapcob.vltitulo
              ,crapcob.rowid
              ,COUNT(*) OVER() qtde_reg
        FROM   crapcob
        WHERE  crapcob.cdcooper = pr_cdcooper
        AND    crapcob.cdbandoc = pr_cdbandoc
        AND    crapcob.nrdctabb = pr_nrdctabb
        AND    crapcob.nrcnvcob = pr_nrcnvcob
        AND    crapcob.nrdocmto = pr_nrdocmto
        AND    pr_nrdconta      IS NULL
        ORDER BY 1,2,3,4,5,6;
      rw_crapcob  cr_crapcob%ROWTYPE;

      -- Cursor para selecionar os parametros do cadastro de cobranca
      CURSOR cr_crapcco_global( pr_cdcooper IN crapcco.cdcooper%TYPE
                              ,pr_cddbanco IN crapcco.cddbanco%TYPE
                              ,pr_nrdctabb IN crapcco.nrdctabb%TYPE
                              ,pr_nroconve IN crapcco.nrconven%TYPE) IS
        SELECT crapcco.cdbccxlt
              ,crapcco.nrdolote
              ,crapcco.cdhistor
              ,crapcco.cdagenci
              ,crapcco.dsorgarq
              ,crapcco.nrconven
              ,crapcco.flgutceb
              ,crapcco.tamannro
        FROM   crapcco
        WHERE  crapcco.cdcooper = pr_cdcooper
        AND    crapcco.cddbanco = pr_cddbanco
        AND    crapcco.nrdctabb = pr_nrdctabb
        AND    crapcco.nrconven = pr_nroconve
        AND    crapcco.flgregis = 0; -- 0-False / 1-true (Contem a situacao da cobranca registrada)
      rw_crapcco_global cr_crapcco_global%ROWTYPE;

      -- seleciona dados dos cooperados
      CURSOR cr_crapass( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.cdsitdtl
              ,crapass.cdcooper
              ,crapass.inpessoa
              ,crapass.ROWID
        FROM   crapass
        WHERE  crapass.cdcooper = pr_cdcooper
        AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;


      -- cursor de lançamentos
      CURSOR cr_craplcm( pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN DATE
                        ,pr_cdagenci IN craplot.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplot.nrdolote%TYPE
                        ,pr_nrdctabb IN INTEGER
                        ,pr_nrdocmto IN INTEGER
                        ,pr_cdpesqbb IN VARCHAR2 DEFAULT NULL
                        )  IS
        SELECT craplcm.cdcooper
        FROM   craplcm
        WHERE  craplcm.cdcooper = pr_cdcooper
        AND    craplcm.dtmvtolt = pr_dtmvtolt
        AND    craplcm.cdagenci = pr_cdagenci
        AND    craplcm.cdbccxlt = pr_cdbccxlt
        AND    craplcm.nrdolote = pr_nrdolote
        AND    craplcm.nrdctabb = pr_nrdctabb
        AND    craplcm.nrdocmto = pr_nrdocmto
        AND    (craplcm.cdpesqbb = pr_cdpesqbb OR pr_cdpesqbb IS NULL);
      rw_craplcm cr_craplcm%ROWTYPE;

      -- Controle de restart
      CURSOR cr_crapres( pr_cdcooper IN crapres.cdcooper%TYPE
                        ,pr_cdprogra IN crapres.cdprogra%TYPE ) IS
        SELECT crapres.cdprogra
              ,crapres.nrdconta
              ,crapres.ROWID
        FROM   crapres
        WHERE  crapres.cdcooper = pr_cdcooper
        AND    crapres.cdprogra = pr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;

      -- Codigo do programa
      vr_cdprogra     CONSTANT crapprg.cdprogra%TYPE := 'CRPS375';
      -- Tratamento de erros
      vr_exc_saida    EXCEPTION;
      vr_exc_fimprg   EXCEPTION;
      vr_cdcritic     crapcri.cdcritic%TYPE;
      vr_dscritic     VARCHAR2(4000);
      -- Variaveis de controle de calendario
      rw_crapdat      BTCH0001.cr_crapdat%ROWTYPE;

      --Variaveis de Arquivo
      vr_input_file  utl_file.file_type;

      -- Diretorios das cooperativas
      vr_caminho_integra VARCHAR2(200);
      vr_caminho_salvar  VARCHAR2(200);
      vr_caminho_cooper  VARCHAR2(200);
      vr_caminho_compbb  VARCHAR2(200);

      -- variaveis de controle de comandos shell
      vr_comando      VARCHAR2(500);
      vr_listadir     VARCHAR2(4000);
      vr_typ_saida    VARCHAR2(1000);
      vr_chave        VARCHAR2(100);

      -- variáveis de controle de arquivos
      vr_nmarquiv VARCHAR2(100);
      vr_setlinha VARCHAR2(298);
      vr_nmarqdeb VARCHAR2(100);
      vr_arqimpor VARCHAR2(4000);
      vr_nmarqaux VARCHAR2(4000);
      vr_dsdemail crapcem.dsdemail%TYPE;
      vr_nrsequen INTEGER;
	    vr_nmarqlog VARCHAR2(100);

      vr_cdbancbb INTEGER;
      vr_nrdctabb INTEGER;
      vr_cdbccxlt INTEGER;
      vr_nrdolote INTEGER;
      vr_cdhistor INTEGER;
      vr_cdagenci INTEGER;
      vr_nrdconta INTEGER;

      vr_qtregrec INTEGER;
      vr_contaarq INTEGER;
      vr_vllanmto NUMBER;
      vr_totvllanmto NUMBER;
      vr_totvllanmt2 NUMBER;
      vr_totqtdbolet NUMBER;
      vr_totqtdbole2 NUMBER;
      vr_nroconve INTEGER;
      vr_vlrtarif NUMBER;
      vr_vltarbco NUMBER;
      vr_cdtarhis INTEGER;
      vr_incnvaut BOOLEAN;
      vr_diagerac NUMBER(2);
      vr_mesgerac NUMBER(2);
      vr_anogerac NUMBER(4);
      vr_dtdgerac DATE;
      vr_loteserv NUMBER(4);
      vr_nrdocmto craprej.nrdocmto%TYPE;
      vr_auxnrctares VARCHAR2(10);
      vr_glbnrctares INTEGER;
      vr_inarqcbr crapceb.inarqcbr%TYPE;
      vr_tplotmov INTEGER := 1;
      vr_nrdoctax craplcm.nrdocmto%TYPE;
      vr_qtregicd INTEGER;
      vr_qtregisd INTEGER;
      vr_qtregrej INTEGER;
      vr_vlcompcr NUMBER;
      vr_vlregicd NUMBER;
      vr_vlregisd NUMBER;
      vr_vlregrej NUMBER;
      vr_vlcompdb NUMBER;
      vr_idorigem INTEGER;
      vr_nmarqimp VARCHAR2(100);
      vr_dtmvtopr DATE;
      vr_flgrejei BOOLEAN;
      vr_fcrapcco_arq BOOLEAN;
      vr_dsorgarq crapcco.dsorgarq%TYPE;
      vr_nmarqind VARCHAR2(100);
      vr_vlliquid NUMBER;
      vr_flgcruni BOOLEAN;
      vr_crapass  BOOLEAN;
      vr_qtdmigra INTEGER;
      vr_vlrmigra NUMBER;

      /*totais para lancamentos unificados */
      vr_vllanmt2 NUMBER;
      vr_qtdbolet INTEGER;
      vr_qtdbole2 INTEGER;

      vr_dsocorre VARCHAR2(100);

      vr_cdhisest INTEGER;
      vr_vltarifa NUMBER;
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_inpessoa INTEGER;

      vr_nrdconta2   INTEGER;
      -- indices das tabelas temporarias
      vr_indregimp   VARCHAR2(100);
      vr_seqregimp   INTEGER;
      vr_indmigracob VARCHAR2(100);
      vr_indcrawcta VARCHAR2(100);
      vr_ind_comando PLS_INTEGER :=0;
      -- Variável de Controle de XML
      vr_des_xml      CLOB;

      --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;

      /*************************************************************************
          Objetivo: Buscar o parametro do nome dos arquivos a serem processados
      *************************************************************************/
      PROCEDURE pc_busca_nome_arquivos(  pr_cdcooper IN crapcop.cdcooper%TYPE    -- codigo da cooperativa
                                        ,pr_cdagenci IN NUMBER                   -- codigo da agencia
                                        ,pr_nrdcaixa IN NUMBER                   -- numero do caixa
                                        ,pr_cddbanco IN NUMBER                   -- codigo do banco
                                        ,pr_nmarqdeb OUT VARCHAR2                -- nome do arquivo
                                        ,pr_tab_erro IN OUT gene0001.typ_tab_erro-- temp-table de erros
                                        ,pr_dscritic OUT VARCHAR2) IS            -- descricao do erro
      BEGIN
        DECLARE
            -- Cursor para selecionar os parametros do cadastro de cobranca
            CURSOR cr_crapcco( pr_cdcooper IN crapcco.cdcooper%TYPE
                              ,pr_cddbanco IN crapcco.cddbanco%TYPE) IS
              SELECT crapcco.nmarquiv
              FROM   crapcco
              WHERE  crapcco.cdcooper = pr_cdcooper
              AND    crapcco.cddbanco = pr_cddbanco
              AND    crapcco.flgregis = 0; -- 0-False / 1-true
            rw_crapcco cr_crapcco%ROWTYPE;

        BEGIN
          -- Forcando a limpeza da tabela de erros
          pr_tab_erro.delete;

          /*--  Busca nome dos arquivos a serem processados  --*/
          /*--  somente de convenios sem registro - Rafael   --*/
          FOR rw_crapcco IN cr_crapcco ( pr_cdcooper => pr_cdcooper
                                        ,pr_cddbanco => pr_cddbanco)
          LOOP
            -- se o parametro não possuir nenhum valor, recebe o
            -- nome do arquivo
            IF TRIM(pr_nmarqdeb) IS NULL THEN
              IF TRIM(rw_crapcco.nmarquiv) IS NOT NULL THEN
                pr_nmarqdeb := TRIM(rw_crapcco.nmarquiv)||'%';
                EXIT; -- saí após encontrar o nome do arquivo
              END IF;
            END IF;
          END LOOP;

          -- se nenhum arquivo foi encontrado, gera crítica
          IF TRIM(pr_nmarqdeb) IS NULL THEN
            -- atribui o codigo da critica
            vr_cdcritic := 181;

            -- incrementa o contador para armazenar a tabela de erros
            vr_nrsequen := nvl(vr_nrsequen,0) + 1;
            /* Retorno de erro da BO */
            gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => pr_cdagenci
                                  ,pr_nrdcaixa => pr_nrdcaixa
                                  ,pr_nrsequen => vr_nrsequen
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => pr_dscritic
                                  ,pr_tab_erro => pr_tab_erro);

            -- alimenta variavel para retornar a critica
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            -- Limpar a crítica
            vr_cdcritic := null;
          END IF;
        END;
      END pc_busca_nome_arquivos; /* fim busca_nome_arquivos */

      /* Insere na tabela de rejeitados */
      PROCEDURE pc_cria_rejeitados( pr_cdcooper IN crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                   ,pr_cdcritic IN INTEGER                -- Codigo da critica
                                   ,pr_nrdconta IN INTEGER                -- Numero da conta
                                   ,pr_nrdctitg IN VARCHAR2               -- Numero da conta de integracao com o Banco do Brasil
                                   ,pr_nrdctabb IN INTEGER                -- Numero da conta no BB
                                   ,pr_dshistor IN VARCHAR2               -- Descricao do historico
                                   ,pr_nmarquiv IN VARCHAR2               -- Nome do arquivo
                                   ,pr_nrdocmto IN craprej.nrdocmto%TYPE  -- Número do documento
                                   ,pr_vllanmto IN NUMBER                 -- Valor do lancamento
                                   -- parametros da pr_tab_regimp
                                   ,pr_nrseqdig IN craprej.nrseqdig%TYPE  -- Digito da sequencia
                                   ,pr_codbanco IN crapcob.cdbandoc%TYPE  -- Codigo do banco
                                   ,pr_cdagenci IN craprej.cdagenci%TYPE  -- Codigo da agencia
                                   ,pr_nrdolote IN craprej.nrdolote%TYPE  -- Numero do lote
                                   ,pr_cdpesqbb IN craprej.cdpesqbb%TYPE  -- Codigo de pesquisa do lancamento no banco do Brasil
                                   ,pr_tab_cratrej IN OUT typ_tab_cratrej -- Tabela de rejeitados
                                   ,pr_qtregrej IN OUT NUMBER             -- Acumulador da quantidade de boletos rejeitados
                                   ,pr_vlregrej IN OUT NUMBER             -- Acumulador do valor dos boletos rejeitados
                                   ,pr_dscritic OUT VARCHAR2 ) IS -- Descricao da critica
      BEGIN
      /*************************************************************************
          Objetivo: Criar registros dos boletos rejeitados na importacao dos
                    arquivos da compensacao
      *************************************************************************/
        DECLARE
          vr_indcratrej VARCHAR2(100);
          vr_seqcratrej INTEGER;
        BEGIN
          -- Sequencial para formar a chave da temp-table
          vr_seqcratrej := pr_tab_cratrej.count()+1;
          -- chave da temp-table utiliza o nome do arquivco e a conta pq o relatório é ordenado por arquivo e conta
          vr_indcratrej := RPad(pr_nmarquiv,50,'#')||LPad(pr_nrdconta,10,'0')||LPad(vr_seqcratrej,5,'0');
          -- alimentando a tabela de rejeitados
          pr_tab_cratrej(vr_indcratrej).dtrefere := substr(pr_nmarquiv,22,6);
          pr_tab_cratrej(vr_indcratrej).nrdconta := pr_nrdconta;
          pr_tab_cratrej(vr_indcratrej).nrdctitg := pr_nrdctitg;
          pr_tab_cratrej(vr_indcratrej).nrdctabb := pr_nrdctabb;
          pr_tab_cratrej(vr_indcratrej).nrdocmto := pr_nrdocmto;
          pr_tab_cratrej(vr_indcratrej).vllanmto := pr_vllanmto;
          pr_tab_cratrej(vr_indcratrej).nrseqdig := pr_nrseqdig;
          pr_tab_cratrej(vr_indcratrej).cdbccxlt := pr_codbanco;
          pr_tab_cratrej(vr_indcratrej).cdagenci := pr_cdagenci;
          pr_tab_cratrej(vr_indcratrej).nrdolote := pr_nrdolote;
          pr_tab_cratrej(vr_indcratrej).cdcritic := pr_cdcritic;
          pr_tab_cratrej(vr_indcratrej).cdcooper := pr_cdcooper;
          pr_tab_cratrej(vr_indcratrej).cdpesqbb := pr_cdpesqbb;
          pr_tab_cratrej(vr_indcratrej).dshistor := pr_dshistor;
          pr_tab_cratrej(vr_indcratrej).nmarquiv := pr_nmarquiv;
          -- Incrementando a quantidade de rejeitados
          pr_qtregrej := nvl(pr_qtregrej,0) + 1;
          -- acumulando o valor dos titulos rejeitados
          pr_vlregrej := nvl(pr_vlregrej,0) + nvl(pr_tab_cratrej(vr_indcratrej).vllanmto,0);

          -- inserindo na tabela de rejeição
          BEGIN
            INSERT INTO craprej( cdagenci
                                , cdbccxlt
                                , cdcritic
                                , cdempres
                                , dtmvtolt
                                , nrdconta
                                , nrdolote
                                , tpintegr
                                , cdhistor
                                , vllanmto
                                , tplotmov
                                , cdpesqbb
                                , dshistor
                                , nrseqdig
                                , nrdocmto
                                , nrdctabb
                                , indebcre
                                , dtrefere
                                , vlsdapli
                                , dtdaviso
                                , vldaviso
                                , nraplica
                                , cdcooper
                                , nrdctitg)
            VALUES  ( nvl(pr_tab_cratrej(vr_indcratrej).cdagenci,0) --cdagenci
                    , nvl(pr_tab_cratrej(vr_indcratrej).cdbccxlt,0) --cdbccxlt
                    , nvl(pr_tab_cratrej(vr_indcratrej).cdcritic,0) --cdcritic
                    , 0 --NULL        --cdempres
                    , NULL        --dtmvtolt
                    , nvl(pr_tab_cratrej(vr_indcratrej).nrdconta,0) --nrdconta
                    , nvl(pr_tab_cratrej(vr_indcratrej).nrdolote,0) --nrdolote
                    , 0        --tpintegr
                    , 0        --cdhistor
                    , nvl(pr_tab_cratrej(vr_indcratrej).vllanmto,0) --vllanmto
                    , 0        --tplotmov
                    , nvl(pr_tab_cratrej(vr_indcratrej).cdpesqbb,' ') --cdpesqbb
                    , nvl(pr_tab_cratrej(vr_indcratrej).dshistor,' ') --dshistor
                    , nvl(pr_tab_cratrej(vr_indcratrej).nrseqdig,0) --nrseqdig
                    , nvl(pr_tab_cratrej(vr_indcratrej).nrdocmto,0) --nrdocmto
                    , nvl(pr_tab_cratrej(vr_indcratrej).nrdctabb,0) --nrdctabb
                    , ' '        --indebcre
                    , pr_tab_cratrej(vr_indcratrej).dtrefere --dtrefere
                    , 0        --vlsdapli
                    , NULL     --dtdaviso
                    , 0        --vldaviso
                    , 0        --nraplica
                    , nvl(pr_tab_cratrej(vr_indcratrej).cdcooper,0)   --cdcooper
                    , nvl(pr_tab_cratrej(vr_indcratrej).nrdctitg,' ')); --nrdctitg
          EXCEPTION
            WHEN OTHERS THEN
              -- gera critica e aborta a execucao do programa
              pr_dscritic := 'Erro ao inserir na tabela craprej na rotina pc_cria_rejeitados. '||SQLERRM;
              -- retorna para o programa chamador da rotina
              RETURN;
          END;
        END;
      END pc_cria_rejeitados; /* fim cria_rejeitados */


      /*--------------------------  Processa arquivos  -------------------------*/
      PROCEDURE pc_processa_arq_compensacao (  pr_cdcooper IN crapcop.cdcooper%TYPE     -- Codigo da cooperativa
                                              ,pr_cdagenci IN INTEGER                   -- Codigo da agencia
                                              ,pr_nrdcaixa IN INTEGER                   -- Número do caixa
                                              ,pr_dtmvtolt IN DATE                      -- Data do movimento
                                              ,pr_tab_cratarq IN OUT typ_tab_cratarq    -- Tabela dos arquivos q serão processados
                                              ,pr_tab_regimp  OUT typ_tab_regimp        -- Tabela dos registros procesados (boletos)
                                              ,pr_tab_erro    OUT gene0001.typ_tab_erro -- Tabela de erros
                                              ,pr_cdcritic    OUT crapcri.cdcritic%TYPE -- Codigo da critica
                                              ,pr_dscritic    OUT VARCHAR2) IS          -- Descricao da critica
      BEGIN
      /*************************************************************************
          Objetivo...: Processar os arquivos de compensacao selecionados
          Observacoes: Temp-tables de retorno:
                       - pr_tab_regimp  : Registros importados - boletos
                       - pr_tab_crawcta : Arquivos das contas processadas
                                          para geracao dos arquivos de retorno -
                                          layout febraban
      *************************************************************************/
        DECLARE

          -- Cadastro de emissao de bloquetos
          CURSOR cr_crapceb3 ( pr_cdcooper IN crapcob.cdcooper%TYPE
                              ,pr_nrconven IN crapceb.nrconven%TYPE
                              ,pr_nrcnvceb IN INTEGER) IS
            SELECT crapceb.inarqcbr
                  ,crapceb.nrdconta
                  ,crapceb.flgcruni
                  ,crapceb.cddemail
                  ,crapceb.nrcnvceb
                  ,0 crapcob_nrdconta --busca a conta da crapcob
                  ,COUNT(*) OVER() qtde_reg
            FROM   crapceb
            WHERE  crapceb.cdcooper = pr_cdcooper
            AND    crapceb.nrconven = pr_nrconven
            AND    crapceb.nrcnvceb = pr_nrcnvceb
            ORDER BY crapceb.cdcooper
                    ,crapceb.nrconven
                    ,crapceb.nrcnvceb;
          
          --> Identidicar numero ceb pelas informações da crapcob
          CURSOR cr_crapcob_ceb(pr_cdcooper  crapcob.cdcooper%TYPE,
                                pr_nrdctabb  crapcob.nrdctabb%TYPE,
                                pr_nrcnvcob  crapcob.nrcnvcob%TYPE,
                                pr_cdbandoc  crapcob.cdbandoc%TYPE,
                                pr_nrdocmto  crapcob.nrdocmto%TYPE) IS                    
            SELECT ceb.nrcnvceb
                   ,COUNT(*) OVER() qtd_reg
            FROM crapcob cob,
                 crapceb ceb
           WHERE ceb.cdcooper = cob.cdcooper
             AND ceb.nrconven = cob.nrcnvcob
             AND ceb.nrdconta = cob.nrdconta
             AND cob.cdcooper = pr_cdcooper
             AND cob.nrdctabb = pr_nrdctabb
             AND cob.nrcnvcob = pr_nrcnvcob
             AND cob.cdbandoc = pr_cdbandoc
             AND cob.nrdocmto = pr_nrdocmto
             AND cob.incobran = 0
             AND cob.dtmvtolt >= to_date('21/10/2015','DD/MM/RRRR');-- data inicial do periodo onde estava gerando nrnosnum errado
          rw_crapcob_ceb cr_crapcob_ceb%ROWTYPE;
             
          --16012014 - inicio
          -- Cursor para selecionar os parametros do cadastro de cobranca
          -- de determinado convênio que não seja da cooperativa logada
          CURSOR cr_crapcco_arq( pr_cdcooper IN crapcco.cdcooper%TYPE
                                ,pr_nrconven IN crapcco.nrconven%TYPE) IS
            SELECT crapcco.cdcooper
                  ,crapcco.dsorgarq
                  ,COUNT(*) OVER() qtde_reg
            FROM   crapcco
            WHERE  crapcco.cdcooper <> pr_cdcooper
            AND    crapcco.nrconven = pr_nrconven;
          rw_crapcco_arq cr_crapcco_arq%ROWTYPE;

          -- Informacoes de contas transferidas entre cooperativas
          CURSOR cr_craptco_arq
                           (pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_nrdconta IN craptco.nrctaant%TYPE
                           ,pr_cdcopant IN craptco.cdcopant%TYPE
                           ,pr_flctaceb IN NUMBER) IS
            SELECT craptco.nrdconta
                   ,craptco.nrctaant
                   ,craptco.cdcopant
                   ,COUNT(*) OVER() qtde_reg
            FROM   craptco
            WHERE  craptco.cdcooper = pr_cdcooper
            -- possibilitar pesquisar pelo numero de conta antiga ou nova.
            -- isso ocorre pois dependendo do convenio irá tratar o numero da conta
            -- vinda no arquivo ou o numero da conta buscana na tabela crapceb que já será a conta nova
            AND    (( pr_flctaceb = 1 and craptco.nrdconta = pr_nrdconta) OR
                    ( pr_flctaceb = 0 and craptco.nrctaant = pr_nrdconta))
            AND    craptco.cdcopant = pr_cdcopant
            AND    craptco.flgativo = 1;

          rw_craptco_arq cr_craptco_arq%ROWTYPE;
          --16012014 - fim

          CURSOR cr_crapceb_arq(pr_cdcooper IN crapcop.cdcooper%TYPE,
                                pr_nrcnvceb IN crapceb.nrcnvceb%TYPE,
                                pr_nrconven IN crapceb.nrconven%TYPE) IS
            SELECT crapceb.nrdconta FROM crapceb WHERE
                   crapceb.cdcooper = pr_cdcooper AND
                   crapceb.nrcnvceb = pr_nrcnvceb AND
                   crapceb.nrconven = pr_nrconven;
          rw_crapceb_arq cr_crapceb_arq%ROWTYPE;

          -- variaveis de trabalho
          vr_nrdocnpj     NUMBER;
          vr_flctaceb     NUMBER;
          vr_flgcebok     BOOLEAN;
          vr_ind          VARCHAR2(100);
          vr_ind_aux      VARCHAR2(100);
          vr_nmarqlog     VARCHAR2(100);

          -- Armazena o valor do parâmetro ref. aos convênios de migração
          vr_nrconven_ceb VARCHAR2(4000);
        BEGIN

          vr_nmarqlog := gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE');

          -- limpando a tabela temporária
          pr_tab_regimp.delete;

          -- Posicionando no primeiro registro da tabela
          vr_ind := pr_tab_cratarq.first;

          -- Iniciando o loop na temp-table
          WHILE vr_ind IS NOT NULL LOOP
            -- Inicializando os acumuladores
            pr_cdcritic := 0;
            vr_qtregrec := 0;
            vr_contaarq := 0;
            vr_vllanmto := 0;

            --Abrir o arquivo lido e percorrer as linhas do mesmo
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_compbb  --> Diretorio do arquivo
                                    ,pr_nmarquiv => pr_tab_cratarq(vr_ind).nmarquiv --> Nome do arquivo
                                    ,pr_tipabert => 'R'            --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                    ,pr_des_erro => pr_dscritic);  --> Erro

            -- Verifica se ocorreram problemas na abertura do arquivo
            IF trim(pr_dscritic) IS NOT NULL THEN
              --Levantar Excecao
              RETURN;
            END IF;

            -------------------------------------------------------------------------------
            -- Testa o header do arquivo antes de entrar no loop para ler o arquivo inteiro
            -------------------------------------------------------------------------------
            -- Le os dados do arquivo e coloca na variavel vr_setlinha
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido

            /*---- CRITICAR HEADER ------------*/
            IF substr(vr_setlinha,8,1) = '0' THEN  /* Header do Arquivo */
              IF substr(vr_setlinha,71,1) = 'X' THEN /* Alt.dig x p/ 0 */
                -- Substitui o X pelo 0
                vr_setlinha := substr(vr_setlinha,1, 70)||'0'||substr(vr_setlinha,72);
              END IF;

              vr_cdbancbb  := substr(vr_setlinha,1,3);   -- Codigo do banco
              vr_nrdctabb  := substr(vr_setlinha,65,7);  -- Numero da conta de dehbito
              vr_nroconve  := substr(vr_setlinha,34,8);  -- numero do convÃªnio
              vr_nrdocnpj  := substr(vr_setlinha,19,14); -- numero do cnpj

              -- Verifica se o convenio esta cadastrado
              OPEN cr_crapcco_global( pr_cdcooper => pr_cdcooper
                                     ,pr_cddbanco => vr_cdbancbb
                                     ,pr_nrdctabb => vr_nrdctabb
                                     ,pr_nroconve => vr_nroconve);
              FETCH cr_crapcco_global INTO rw_crapcco_global;

              -- Se existir convenio
              IF cr_crapcco_global%FOUND THEN

                -- Fechando o cursor cr_crapcco
                CLOSE cr_crapcco_global;

                -- Alimentando as variaveis
                vr_cdbccxlt := rw_crapcco_global.cdbccxlt;
                vr_nrdolote := rw_crapcco_global.nrdolote;
                vr_cdhistor := rw_crapcco_global.cdhistor;
                vr_cdagenci := rw_crapcco_global.cdagenci;
                vr_vllanmto := 0;
                vr_contaarq := 1;
                vr_qtregrec := 0;
                vr_incnvaut := FALSE;
                vr_diagerac := substr(vr_setlinha,144,2);
                vr_mesgerac := substr(vr_setlinha,146,2);
                vr_anogerac := substr(vr_setlinha,148,4);
                vr_dtdgerac := to_date(LPad(vr_diagerac,2,'0')||
                                       LPad(vr_mesgerac,2,'0')||
                                       vr_anogerac,'ddmmyyyy');

                -- verifica se o tipo do registro está correto
                IF substr(vr_setlinha,4,5) <> '00000' THEN
                  /* Tipo de Registro Errado */
                  pr_cdcritic := 468;
                END IF;

                -- verifica se possui convenio migrado de outra
                rw_crapcco_arq := NULL;
                vr_fcrapcco_arq:= FALSE;
                OPEN cr_crapcco_arq( pr_cdcooper => pr_cdcooper
                                    ,pr_nrconven => vr_nroconve);
                FETCH cr_crapcco_arq INTO rw_crapcco_arq;
                vr_fcrapcco_arq := cr_crapcco_arq%FOUND;
                CLOSE cr_crapcco_arq;

                -- busca os números de convênio ref. as contas de migração
                --vr_nrconven_mig := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CTA_CONVENIO_MIGRACAO');

                -- verificando a origem do arquivo e o numero do convenio
                IF rw_crapcco_global.dsorgarq = 'INTERNET' OR
                   rw_crapcco_global.dsorgarq = 'IMPRESSO PELO SOFTWARE' OR
                   (rw_crapcco_global.dsorgarq IN ('MIGRACAO','INCORPORACAO')) --AND
                   -- comentado pois deve verificar se é convenio migrado apenas pela descrição
                   --Possuia código fixo: "Lpad(rw_crapcco.nrconven,7,'0') IN ('1343313','1601301','0457595'))"
                   --InStr(vr_nrconven_mig, LPad(rw_crapcco_global.nrconven,7,'0')) > 0)
                   THEN
                  -- não marcar se anteriormente era pre impresso
                  -- deve deixar buscar o nrdconta no boleto
                  IF nvl(rw_crapcco_arq.dsorgarq,' ') <> 'PRE-IMPRESSO' THEN
                    vr_incnvaut := TRUE;
                  END IF;
                END IF;

                -- Recebendo a origem que esta armazenada no convenio
                vr_dsorgarq := rw_crapcco_global.dsorgarq;
                -- Zerando a critica
                pr_cdcritic := 0;

              ELSE
                -- Fechando o cursor cr_crapcco
                CLOSE cr_crapcco_global;

                -- Atribuindo critica
                pr_cdcritic := 563; /* Convenio Nao Cadastrado */
              END IF; --IF crapcco%FOUND THEN

            ELSE
              -- Atribuindo critica
              pr_cdcritic := 468;
            END IF; --IF substr(vr_setlinha,8,1) = '0' THEN

            -- Se a critica eh diferente de zero
            IF nvl(pr_cdcritic,0) <> 0 THEN

              --Fechar Arquivo
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

              -- Gerando o nome do arquivo de erro
              vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_ind).nmarquiv,8,53);

              -- Comando para copiar o arquivo para a pasta salvar
              vr_ind_comando := vr_ind_comando + 1;
              vr_tab_comando.extend;
              vr_tab_comando(vr_ind_comando) := 'cp '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_ind).nmarquiv||' '||vr_caminho_salvar||' 2> /dev/null';

              -- Comando para mover o arquivo
              vr_ind_comando := vr_ind_comando + 1;
              vr_tab_comando.extend;
              vr_tab_comando(vr_ind_comando) := 'mv '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_ind).nmarquiv||' '||
                                  vr_caminho_integra||'/'||vr_nmarquiv||' 2> /dev/null';

              -- Busca a descricao da critica
              pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||
                            ' Houve criticas na Importacao '||vr_nmarquiv;

              -- Escrevendo a critica no log
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
									                      ,pr_nmarqlog     => vr_nmarqlog
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                         || vr_cdprogra || ' --> '
                                                         || pr_dscritic);

              -- Limpando o codigo da critica
              pr_cdcritic := 0;

              -- Armazenando o proximo indice da temp-table antes de excluir o atual
              vr_ind_aux := pr_tab_cratarq.next(vr_ind);

              /* se o arquivo ja foi movido, nao processar o cratarq */
              pr_tab_cratarq.delete(vr_ind);

              /* Erro no Header - Processar proximo Arquivo */
              vr_ind := vr_ind_aux;

              -- Processa o proximo registro da temp-table
              CONTINUE;
            END IF;

            -- Inicia o processo de leitura do arquivo inteiro
            LOOP
              -- Le os dados do arquivo e coloca na variavel vr_setlinha
              gene0001.pc_le_linha_arquivo( pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                           ,pr_des_text => vr_setlinha); --> Texto lido

              -- se eh o trailer do arquivo, fecha o arquivo e vai para o proximo arquivo
              IF substr(vr_setlinha,8,1) = '9' THEN  /* Trailer do Arquivo */

                -- Incrementao contador de arquivos processados
                vr_contaarq := nvl(vr_contaarq,0) + 1;

                -- Verifica o tipo de registro
                IF substr(vr_setlinha,4,5) <> '99999' THEN

                  --Fechar Arquivo
                  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

                  -- Setando o codigo da critica
                  pr_cdcritic := 468; /* Tipo de Registro Errado */

                  -- Busca a descricao da critica
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
                  pr_dscritic := pr_dscritic||substr(pr_tab_cratarq(vr_ind).nmarquiv,9,29)||' Lote ' || vr_loteserv;

                  -- Escrevendo a critica no log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_nmarqlog     => vr_nmarqlog
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || pr_dscritic);

                END IF; --IF substr(vr_setlinha,4,5) <> '99999' THEN

                EXIT; /* Proximo Arquivo */
              /* Header do Lote */
              ELSIF substr(vr_setlinha,8,1) = '1' THEN
                --
                IF substr(vr_setlinha,9,1) = 'T' THEN
                  -- Incrementando o contador de arquivos
                  vr_contaarq := nvl(vr_contaarq,0) + 1;
                  -- Lendo o numero do lote
                  vr_loteserv := substr(vr_setlinha,4,4);
                  vr_nrsequen := 1;

                  IF to_number(TRIM(substr(vr_setlinha,35,8))) <> vr_nroconve THEN
                    --Fechar Arquivo
                    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

                    vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_ind).nmarquiv,8,53);

                    -- Comando para copiar o arquivo para a pasta salvar
                    vr_ind_comando := vr_ind_comando + 1;
                    vr_tab_comando.extend;
                    vr_tab_comando(vr_ind_comando) := 'cp '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_ind).nmarquiv||' '||vr_caminho_salvar;

                    -- Comando para mover o arquivo
                    vr_ind_comando := vr_ind_comando + 1;
                    vr_tab_comando.extend;
                    vr_tab_comando(vr_ind_comando) := 'mv '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_ind).nmarquiv||' '||
                                        vr_caminho_integra||'/'||vr_nmarquiv;

                    /* Convenio Invalido */
                    pr_cdcritic := 474;

                    -- Busca a descricao da critica
                    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

                    -- Escrevendo a critica no log
                    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                              ,pr_ind_tipo_log => 2 -- Erro tratato
											                        ,pr_nmarqlog     => vr_nmarqlog
                                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                               || vr_cdprogra || ' --> '
                                                               || pr_dscritic);
                    EXIT; /* Proximo Arquivo */
                  END IF;
                END IF; --IF substr(vr_setlinha,9,1) = 'T' THEN /*  Header "T" */

                -- se o numero da conta estiver inconsistente, gera crítica
                IF to_number(TRIM(substr(REPLACE(vr_setlinha,'X','0'),60,13))) <> vr_nrdctabb THEN

                  /* Conta Errada */
                  pr_cdcritic := 127;

                  -- descrição da crítica
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||
                                 ' '||vr_tab_cratarq(vr_ind).nmarquiv||
                                 ' Lote ' || vr_loteserv;

                  -- sequencia da tabela de erros
                  vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                  EXIT; /* Proximo Arquivo */
                END IF;

              /* Registro Detalhe T */
              ELSIF substr(vr_setlinha,8,1)  = '3' AND substr(vr_setlinha,14,1) = 'T' THEN

                -- Incrementando o contador de arquivos
                vr_contaarq := nvl(vr_contaarq,0) + 1;

                -- Incrementa o contador de liquidacao
                IF substr(vr_setlinha,16,2) = '06' THEN
                 vr_qtregrec := nvl(vr_qtregrec,0) + 1;
                END IF;

                /* tarifa cobrada pelo banco */
                vr_vltarbco := to_number(TRIM(substr(vr_setlinha,199,15))) / 100;

                --
                IF vr_incnvaut AND rw_crapcco_global.flgutceb = 0 THEN
                  vr_nrdconta2 := substr(vr_setlinha,38,8);
                ELSE
                  vr_nrdconta2 := 0;
                END IF;

                -- Seta Tipo de pessoa para Juridica
                vr_inpessoa := 2;

                IF vr_nrdconta2 > 0 THEN
                  -- verifica o tipo de pessoa para a conta 2
                  -- se encontrar o associado muda o tipo de pessoa.
                  OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => vr_nrdconta2);
                  FETCH cr_crapass INTO rw_crapass;
                  vr_crapass:= cr_crapass%FOUND;
                  CLOSE cr_crapass;

                  IF vr_crapass THEN
                    vr_inpessoa := rw_crapass.inpessoa;
                  END IF;

                END IF;

                -- inicializando as variaveis
                vr_vlrtarif := 0;
                vr_cdtarhis := 0;
                vr_cdfvlcop := 0;

                -- Carregando os dados de tarifa de cobranca
                TARI0001.pc_carrega_dados_tarifa_cobr ( pr_cdcooper  => pr_cdcooper            --Codigo Cooperativa
                                                       ,pr_nrdconta  => vr_nrdconta2           --Numero Conta
                                                       ,pr_inpessoa  => vr_inpessoa            --Tipo da pessoa
                                                       ,pr_nrconven  => vr_nroconve            --Numero Convenio
                                                       ,pr_dsincide  => 'RET'                  --Descricao Incidencia
                                                       ,pr_cdocorre  => 0                      --Codigo Ocorrencia
                                                       ,pr_cdmotivo  => '31' /* Outras instituicoes financeiras (Correspondente)*/ --Codigo Motivo
                                                       ,pr_vllanmto  => 1                      --Valor Lancamento
                                                       ,pr_cdprogra  => NULL                   --Nome do programa
                                                       ,pr_flaputar  => 1                      --Apurar
													                             ,pr_cdhistor  => vr_cdtarhis            --Codigo Historico
                                                       ,pr_cdhisest  => vr_cdhisest            --Historico Estorno
                                                       ,pr_vltarifa  => vr_vlrtarif            --Valor Tarifa
                                                       ,pr_dtdivulg  => vr_dtdivulg            --Data Divulgacao
                                                       ,pr_dtvigenc  => vr_dtvigenc            --Data Vigencia
                                                       ,pr_cdfvlcop  => vr_cdfvlcop            --Codigo Cooperativa
                                                       ,pr_cdcritic  => pr_cdcritic            --Codigo Critica
                                                       ,pr_dscritic  => pr_dscritic);          --Descricao Critica
                -- Se retornar com erro
                IF pr_dscritic IS NOT NULL THEN
                  -- Escreve os erros no log
                  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                            ,pr_ind_tipo_log => 2 -- Erro tratato
                                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                             || vr_cdprogra || ' --> '
                                                             || pr_dscritic);
                  -- retorna para o programa principal
                  RETURN;
                END IF;

                /* substituicao da tarifa do banco pela tarifa do convenio */
                vr_setlinha := substr(vr_setlinha,1,198)||
                               lpad(vr_vlrtarif * 100, 15,'0')||
                               substr(vr_setlinha,214);

                -- se o banco e lote estiverem inconsistentes, gera crítica
                IF vr_cdbancbb <> to_number(TRIM(substr(vr_setlinha,1,3))) OR
                   vr_loteserv <> to_number(TRIM(substr(vr_setlinha,4,4))) THEN

                  -- setando o codigo da critica
                  /* Nro Lote Errado */
                  pr_cdcritic := 58;

                  -- Incrementando o sequencial de arquivos
                  vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                  -- Busca a descricao da critica
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);

                  -- Adicionando o nome do arquivo e o numero do lote na critica
                  pr_dscritic := pr_dscritic ||' '||vr_tab_cratarq(vr_ind).nmarquiv || ' Lote ' || vr_loteserv;

                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                  EXIT; /* Proximo Arquivo */
                END IF;

                /* Alt.dig x p/ 0 */
                IF  substr(vr_setlinha,49,1) = 'X' THEN
                  vr_setlinha := substr(vr_setlinha,1,48)||'0'||substr(vr_setlinha,1,50);
                END IF;

                -- se o tamanho do nosso numero é 17
                IF rw_crapcco_global.tamannro = 17 THEN
                  -- Se utiliza sequencia cadceb
                  IF rw_crapcco_global.flgutceb = 1 THEN
                    vr_nrdocmto := substr(vr_setlinha,49,6);
                  ELSE
                    vr_nrdocmto := substr(vr_setlinha,46,9);
                  END IF;
                ELSE
                  vr_nrdocmto := substr(vr_setlinha,44,6);
                END IF;
                --Alimentando a tabela auxiliar
                vr_seqregimp := pr_tab_regimp.count() + 1;

                -- Montando o indice da tabela temporaria
                IF vr_incnvaut AND rw_crapcco_global.flgutceb = 0 THEN
                  vr_indregimp := RPad(vr_tab_cratarq(vr_ind).nmarquiv,70,'#')||lpad(substr(vr_setlinha,38,8),10,'0')||lpad(vr_nroconve,8,'0')||lpad(vr_seqregimp,5,'0');
                ELSE
                  vr_indregimp := RPad(vr_tab_cratarq(vr_ind).nmarquiv,70,'#')||lpad('0',10,'0')||lpad(vr_nroconve,8,'0')||lpad(vr_seqregimp,5,'0');
                END IF;

                -- alimentando a tabela temporaria com os titulos importados
                pr_tab_regimp(vr_indregimp).codbanco   := substr(vr_setlinha,1,3);
                pr_tab_regimp(vr_indregimp).cdagenci   := vr_cdagenci;
                pr_tab_regimp(vr_indregimp).nroconve   := vr_nroconve;
                pr_tab_regimp(vr_indregimp).nrdctabb   := vr_nrdctabb;
                pr_tab_regimp(vr_indregimp).nrdocmto   := vr_nrdocmto;
                /* Nosso numero - documento completo */
                pr_tab_regimp(vr_indregimp).cdpesqbb   := substr(vr_setlinha,38,20);
                -- inicializar variavel para saber se buscou o numero da conta na ceb
                vr_flctaceb := 0;
                -- se utiliza sequencia CADCEB
                IF vr_incnvaut AND rw_crapcco_global.flgutceb = 0 THEN
                  pr_tab_regimp(vr_indregimp).nrdconta := substr(vr_setlinha,38,8);
                ELSE
                  pr_tab_regimp(vr_indregimp).nrdconta := 0;
                END IF;
                
                pr_tab_regimp(vr_indregimp).nrcnvceb   := substr(vr_setlinha,45,4);
                pr_tab_regimp(vr_indregimp).incnvaut   := vr_incnvaut;
                pr_tab_regimp(vr_indregimp).vllanmto   := substr(vr_setlinha,82,15) / 100;
                vr_vllanmto                            := nvl(vr_vllanmto,0) + nvl(pr_tab_regimp(vr_indregimp).vllanmto,0);
                
                -- Se utiliza CEB e não localizou numero
                IF rw_crapcco_global.flgutceb = 1 AND 
                   nvl(pr_tab_regimp(vr_indregimp).nrcnvceb,0) = 0 THEN
                  -- Tentar identificar o ceb atraves da crapcob
                  OPEN cr_crapcob_ceb(pr_cdcooper  => pr_cdcooper,
                                      pr_nrdctabb  => pr_tab_regimp(vr_indregimp).nrdctabb,
                                      pr_nrcnvcob  => pr_tab_regimp(vr_indregimp).nroconve,
                                      pr_cdbandoc  => pr_tab_regimp(vr_indregimp).codbanco,
                                      pr_nrdocmto  => pr_tab_regimp(vr_indregimp).nrdocmto);
                  FETCH cr_crapcob_ceb INTO rw_crapcob_ceb;
                  -- Se localizou apenas 1 registro, utilizar este como CEB
                  IF cr_crapcob_ceb%FOUND AND rw_crapcob_ceb.qtd_reg = 1 THEN
                    pr_tab_regimp(vr_indregimp).nrcnvceb := rw_crapcob_ceb.nrcnvceb;
                  END IF;
                  CLOSE cr_crapcob_ceb;                  
                END IF;
                                
                pr_tab_regimp(vr_indregimp).vlrtarif   := substr(vr_setlinha,199,15) / 100;
                pr_tab_regimp(vr_indregimp).vltarbco   := vr_vltarbco;
                pr_tab_regimp(vr_indregimp).codmoeda   := substr(vr_setlinha,132,1);
                pr_tab_regimp(vr_indregimp).codcarte   := substr(vr_setlinha,58,1);
                pr_tab_regimp(vr_indregimp).identifi   := substr(vr_setlinha,38,20);
                pr_tab_regimp(vr_indregimp).dtpagto    := NULL;
                pr_tab_regimp(vr_indregimp).nrseqdig   := substr(vr_setlinha,9,5);
                pr_tab_regimp(vr_indregimp).nrdolote   := vr_loteserv;
                pr_tab_regimp(vr_indregimp).cdbanpag   := substr(vr_setlinha,97,3);
                pr_tab_regimp(vr_indregimp).cdagepag   := substr(vr_setlinha,101,4);
                IF (substr(vr_setlinha,16,2) IN ('50','44') OR substr(vr_setlinha,214,2) = '04')  THEN
                  pr_tab_regimp(vr_indregimp).flpagchq := TRUE;
                ELSE
                  pr_tab_regimp(vr_indregimp).flpagchq := FALSE;
                END IF;
                vr_auxnrctares                         := lpad(vr_loteserv,4,'0')||lpad(pr_tab_regimp(vr_indregimp).nrseqdig,5,'0');
                pr_tab_regimp(vr_indregimp).nrctares   := to_number(vr_auxnrctares);
                pr_tab_regimp(vr_indregimp).nmarquiv   := vr_tab_cratarq(vr_ind).nmarquiv;
                pr_tab_regimp(vr_indregimp).dtdgerac   := vr_dtdgerac;
                pr_tab_regimp(vr_indregimp).dsorgarq   := vr_dsorgarq;
                pr_tab_regimp(vr_indregimp).cdocorre   := substr(vr_setlinha,16,2);
                pr_tab_regimp(vr_indregimp).cdhistor   := vr_cdtarhis;  /* Utilizado para lancamento Tarifa. */
                pr_tab_regimp(vr_indregimp).cdfvlcop   := vr_cdfvlcop; /* Utilizado para lancamento Tarifa. */
                -- Inicializando como false. No progress não existe essa inicialização
                pr_tab_regimp(vr_indregimp).incoptco   := FALSE;

                --16012014 - inicio
                --verifica se o arquivo eh de um convenio que foi migrado
                IF vr_dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

                   -- Busco nrdconta na crapceb
                  IF pr_tab_regimp(vr_indregimp).nrdconta = 0 AND
                     -- não buscar conta pelo crapceb, se anteriormente era Pre-impresso
                     --pois indicador de CEB é igual para todas as contas, deve buscar a nrdconta no boleto(crapcob)
                     rw_crapcco_arq.dsorgarq <> 'PRE-IMPRESSO' THEN
                    OPEN cr_crapceb_arq(pr_cdcooper => pr_cdcooper
                                       ,pr_nrcnvceb => pr_tab_regimp(vr_indregimp).nrcnvceb
                                       ,pr_nrconven => vr_nroconve);
                    FETCH cr_crapceb_arq INTO rw_crapceb_arq;

                    IF cr_crapceb_arq%FOUND THEN
                      pr_tab_regimp(vr_indregimp).nrdconta := rw_crapceb_arq.nrdconta;
                      -- marcar flag ceb, para identificar que ja é o
                      -- numero da conta na cooperativa nova
                      vr_flctaceb := 1;
                    END IF;
                    CLOSE cr_crapceb_arq;

                  END IF;

                  -- só processa se possuir um único convenio de migracao
                  IF vr_fcrapcco_arq /*Found*/ AND Nvl(rw_crapcco_arq.qtde_reg,0) = 1 THEN
                    -- verifica os convenios migrados
                    OPEN cr_craptco_arq
                                   (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_tab_regimp(vr_indregimp).nrdconta
                                   ,pr_cdcopant => rw_crapcco_arq.cdcooper
                                   -- verificar conta tco, dependendo se tem o numero de
                                   -- conta nova(buscada na ceb) ou antiga, lida do arquivo
                                   ,pr_flctaceb => vr_flctaceb);
                    FETCH cr_craptco_arq INTO rw_craptco_arq;

                    -- só processa se encontrar um unico registro na tabela
                    -- atualiza os valores na temp-table
                    IF cr_craptco_arq%FOUND AND Nvl(rw_craptco_arq.qtde_reg,0) = 1 THEN
                      pr_tab_regimp(vr_indregimp).nrdconta := rw_craptco_arq.nrdconta;
                      pr_tab_regimp(vr_indregimp).nrctaant := rw_craptco_arq.nrctaant;
                      pr_tab_regimp(vr_indregimp).cdcopant := rw_craptco_arq.cdcopant;
                      pr_tab_regimp(vr_indregimp).incoptco := TRUE;
                    END IF;
                  END IF; --IF Nvl(rw_crapcco.qtde_reg,0) = 1 THEN
                  -- fechando os cursores
                  CLOSE cr_craptco_arq;
                  --16012014 - fim
                END IF; --IF vr_dsorgarq = 'MIGRACAO' THEN
                -- inicializando as variaveis
                vr_nrdconta := 0;
                vr_inarqcbr := 0;

                /* Tarefa 44309 - REMOVER EM ABRIL/2012 */
                IF (pr_cdcooper = 8 AND
                    pr_tab_regimp(vr_indregimp).nroconve = 2148530 AND
                    pr_tab_regimp(vr_indregimp).nrcnvceb = 1 AND
                    pr_tab_regimp(vr_indregimp).nrdocmto >= 1001 AND
                    pr_tab_regimp(vr_indregimp).nrdocmto <= 2017) OR
                    (pr_cdcooper = 8 AND
                    pr_tab_regimp(vr_indregimp).nroconve = 2148530 AND
                    pr_tab_regimp(vr_indregimp).nrcnvceb = 1 AND
                    pr_tab_regimp(vr_indregimp).nrdocmto >= 3001 AND
                    pr_tab_regimp(vr_indregimp).nrdocmto <= 3023)
                THEN
                  pr_tab_regimp(vr_indregimp).nrcnvceb := 7;
                END IF;

                --
                IF NOT pr_tab_regimp(vr_indregimp).incnvaut THEN
                  -- Buscando informacoes de cobranca
                  OPEN cr_crapcob( pr_cdcooper => pr_cdcooper
                                  ,pr_cdbandoc => pr_tab_regimp(vr_indregimp).codbanco
                                  ,pr_nrdctabb => pr_tab_regimp(vr_indregimp).nrdctabb
                                  ,pr_nrcnvcob => pr_tab_regimp(vr_indregimp).nroconve
                                  ,pr_nrdocmto => pr_tab_regimp(vr_indregimp).nrdocmto);

                  FETCH cr_crapcob INTO rw_crapcob;

                  -- Somente vai processar quando encontrar somente um registro
                  -- cfme condição no progress: IF   AVAILABLE crapcob THEN
                  IF cr_crapcob%FOUND AND nvl(rw_crapcob.qtde_reg,0) = 1 THEN
                    -- Fecha o cursor de cobranca
                    CLOSE cr_crapcob;

                    -- se a conta eh <> de zero, alimenta a variavel e a temp-table
                    IF rw_crapcob.nrdconta <> 0 THEN
                      -- setando o numero da conta com o numero da conta da tabela de emissao de boletos
                      vr_nrdconta                           := rw_crapcob.nrdconta;
                      pr_tab_regimp(vr_indregimp).nrdconta  := rw_crapcob.nrdconta;

                      -- Verificando o cadastro de emissao de bloquetos
                      OPEN cr_crapceb( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => vr_nrdconta
                                      ,pr_nrconven => rw_crapcob.nrcnvcob);
                      FETCH cr_crapceb INTO rw_crapceb;
                      -- Se possuir informacoes no cadastro de emissao de boletos
                      IF cr_crapceb%FOUND THEN
                        vr_inarqcbr := rw_crapceb.inarqcbr;
                      END IF;
                      -- Fechando o cursor;
                      CLOSE cr_crapceb;
                    END IF;
                  ELSE
                    -- fechando o cursor
                    CLOSE cr_crapcob;
                    -- Verifica a coopertativa
                    --16012014 - inicio
                    IF  pr_tab_regimp(vr_indregimp).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                      CONTINUE; /* Proximo registro */
                    END IF;
                    --16012014 - fim
                  END IF; /* IF cr_crapcob%FOUND THEN */
                ELSE

                  -- Verifica se utiliza sequencia CADCEB
                  IF rw_crapcco_global.flgutceb = 1 THEN

                    -- setando variavel para verdadeiro
                    vr_flgcebok := TRUE;

                    -- busca o número do convênio do parâmetro
                    vr_nrconven_ceb := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CTA_CONVENIO_CEB');

                    -- Desativado convenios com 5 digitos, por isso foi retirado tratamento para 5 digitos
                    -- Odirlei - 28/07/2014
                    -- Faz somente para a cooperativa 01-Viacred e para determinado convenio
                    /*IF pr_cdcooper = 1 AND
                      -- Estava fixo: "rw_crapcco.nrconven = 1343313"
                      rw_crapcco_global.nrconven = vr_nrconven_ceb AND
                      substr(pr_tab_regimp(vr_indregimp).nrcnvceb,1,3) = '100' THEN

                      -- Busca informacoes do cadastro de bloquetos
                      OPEN cr_crapceb2( pr_cdcooper => pr_cdcooper
                                       ,pr_nrconven => pr_tab_regimp(vr_indregimp).nroconve
                                       ,pr_nrcnvceb => pr_tab_regimp(vr_indregimp).nrcnvceb);
                      FETCH cr_crapceb2 INTO rw_crapceb;

                      -- se retornar mais de um registro devera fazer um loop em todos os registros
                      IF cr_crapceb2%NOTFOUND OR
                         nvl(rw_crapceb.qtde_reg,0) > 1 THEN
                        -- fecha o cursor
                        CLOSE cr_crapceb2;
                        -- verifca a conta na crapcob
                        OPEN cr_crapceb4( pr_cdcooper => pr_cdcooper
                                        ,pr_nrconven => pr_tab_regimp(vr_indregimp).nroconve
                                        ,pr_nrcnvcob => pr_tab_regimp(vr_indregimp).nroconve
                                        ,pr_nrdocmto => pr_tab_regimp(vr_indregimp).nrdocmto
                                        ,pr_nrdctabb => pr_tab_regimp(vr_indregimp).nrdctabb
                                        ,pr_cdbandoc => pr_tab_regimp(vr_indregimp).codbanco
                                        ,pr_vltitulo => pr_tab_regimp(vr_indregimp).vllanmto
                                        ,pr_nrcnvceb => pr_tab_regimp(vr_indregimp).nrcnvceb);
                        LOOP
                          FETCH cr_crapceb4 INTO rw_crapceb;
                          EXIT WHEN cr_crapceb4%NOTFOUND;

                          -- Alimentando a tabela temporaria
                          pr_tab_regimp(vr_indregimp).nrcnvceb := rw_crapceb.nrcnvceb;
                          pr_tab_regimp(vr_indregimp).nrdconta := rw_crapceb.crapcob_nrdconta;
                        END LOOP;
                        --fechando o cursor
                        CLOSE cr_crapceb4;

                        -- Consulta as informacoes de cobranca pelo documento
                        OPEN cr_crapcob3( pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_tab_regimp(vr_indregimp).nrdconta
                                         ,pr_nrcnvcob => pr_tab_regimp(vr_indregimp).nroconve
                                         ,pr_nrdctabb => pr_tab_regimp(vr_indregimp).nrdctabb
                                         ,pr_cdbandoc => pr_tab_regimp(vr_indregimp).codbanco
                                         ,pr_nrdocmto => pr_tab_regimp(vr_indregimp).nrdocmto);
                        FETCH cr_crapcob3 INTO rw_crapcob;

                        -- verifica se existe informacao para o documento informado
                        IF cr_crapcob3%FOUND THEN
                          --fechando o cursor
                          CLOSE cr_crapcob3;

                          -- busca informacoes do cadastro de emissao de bloquetos para a conta e convenio
                          OPEN cr_crapceb ( pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => rw_crapcob.nrdconta
                                           ,pr_nrconven => rw_crapcob.nrcnvcob);
                          FETCH cr_crapceb INTO rw_crapceb;

                          -- se possuir informacoes, alimenta a temp table com as infomacoes
                          IF cr_crapceb%FOUND THEN
                            vr_flgcebok                           := FALSE;
                            pr_tab_regimp(vr_indregimp).nrdconta  := rw_crapceb.nrdconta;
                            vr_inarqcbr                           := rw_crapceb.inarqcbr;
                          ELSE
                            pr_tab_regimp(vr_indregimp).nrdconta := 0;
                          END IF;
                          -- fecha o cursor
                          CLOSE cr_crapceb;
                        ELSE --IF cr_crapcob3%FOUND THEN
                          --fechando o cursor
                          CLOSE cr_crapcob3;
                        END IF;--IF cr_crapcob3%FOUND THEN
                      ELSE
                        -- Fechando o cursor
                        CLOSE cr_crapceb2;
                      END IF;--IF cr_crapceb2%FOUND AND nvl(rw_crapceb.qtde_reg,0) > 1 THEN

                      -- Se retornou informacoes no cursor
                      --IF cr_crapceb2%FOUND THEN
                      IF rw_crapceb.nrdconta IS NOT NULL THEN
                        -- se possuir um numero de conta, alimenta a temporaria
                        IF rw_crapceb.nrdconta > 0 THEN
                          pr_tab_regimp(vr_indregimp).nrdconta := rw_crapceb.nrdconta;
                        END IF;
                      END IF;

                      -- Se depois do processo acima, o numero da conta ainda estiver zerado e
                      -- o numero do convenio possuir 6 posicoes...
                      IF pr_tab_regimp(vr_indregimp).nrdconta = 0 AND
                         length(pr_tab_regimp(vr_indregimp).nroconve) = 6 THEN

                        -- O numero da conta recebe o que consta no arquivo
                        pr_tab_regimp(vr_indregimp).nrdconta := substr(vr_setlinha,38,8);
                      END IF;--IF pr_tab_regimp(vr_indregimp).nrdconta = 0...
                    END IF;*/ --IF pr_cdcooper = 1 AND

                    -- se é verdadeiro
                    IF vr_flgcebok THEN
                      -- verifica se o convenio esta cadastrado
                      OPEN cr_crapceb3 ( pr_cdcooper => pr_cdcooper
                                        ,pr_nrconven => substr(vr_setlinha,38,7)
                                        ,pr_nrcnvceb => pr_tab_regimp(vr_indregimp).nrcnvceb);
                      FETCH cr_crapceb3 INTO rw_crapceb;

                      -- se encontrou dados
                      IF cr_crapceb3%FOUND THEN
                        pr_tab_regimp(vr_indregimp).nrdconta := rw_crapceb.nrdconta;
                        vr_inarqcbr                          := rw_crapceb.inarqcbr;
                      END IF;

                      -- fecha o cursor
                      CLOSE cr_crapceb3;
                    END IF;-- IF vr_flgcebok THEN
                  ELSE
                    --16012014 - inicio
                    -- se
                    IF  NOT pr_tab_regimp(vr_indregimp).incoptco THEN
                      pr_tab_regimp(vr_indregimp).nrdconta := substr(vr_setlinha,38,8);
                    END IF;
                    --16012014 - fim
                  END IF;--IF rw_crapcco.flgutceb = 1 THEN
                END IF; --IF NOT pr_tab_regimp(vr_indregimp).incnvaut THEN

                -- informa se recebe Arquivo de Retorno de Cobranca
                pr_tab_regimp(vr_indregimp).inarqcbr := vr_inarqcbr;

                IF (vr_incnvaut OR vr_inarqcbr = 2) AND
                     pr_tab_regimp(vr_indregimp).flpagchq = FALSE THEN

                  -- gerando o indice da tabela temporaria: nrdconta||nrconven||nrsequen
                  vr_indcrawcta := lpad(pr_tab_regimp(vr_indregimp).nrdconta,10,'0')||
                                      lpad(vr_nroconve,10,'0')||
                                      lpad(substr(vr_setlinha,9,5),10,'0');

                  -- alimentando a tabela das contas processadas para geracao dos
                  -- arquivos de retorno - layout febraban
                  vr_tab_crawcta(vr_indcrawcta).nrdconta := pr_tab_regimp(vr_indregimp).nrdconta;
                  vr_tab_crawcta(vr_indcrawcta).dsstring := vr_setlinha;
                  vr_tab_crawcta(vr_indcrawcta).nrsequen := substr(vr_setlinha,9,5);
                  vr_tab_crawcta(vr_indcrawcta).nrconven := vr_nroconve;
                  vr_tab_crawcta(vr_indcrawcta).nrctabbd := vr_nrdctabb;

                END IF; --IF (vr_incnvaut OR vr_inarqcbr = 2) AND

              /* Registro Detalhe U */
              ELSIF substr(vr_setlinha,8,1)  = '3' AND substr(vr_setlinha,14,1) = 'U' THEN
                -- Incrementando a quantidade de arquivos
                vr_contaarq := vr_contaarq + 1;

                -- verifica o banco e o lote de servico
                IF  vr_cdbancbb <> to_number(TRIM(substr(vr_setlinha,1,3))) OR
                    vr_loteserv <> to_number(TRIM(substr(vr_setlinha,4,4))) THEN

                  /* Nro Lote Errado */
                  pr_cdcritic := 58;

                  /* Setando a critica */
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
                  pr_dscritic := pr_dscritic || ' ' ||pr_tab_cratarq(vr_ind).nmarquiv || ' Lote ' || vr_loteserv;

                  -- gerando a sequencia da tabela de erros
                  vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                  /* Proximo Arquivo */
                  EXIT;
                END IF;

                /* tt-regimp.existe pois  obrigatorio Detalhe "T" antes */
                pr_tab_regimp(vr_indregimp).dtpagto  := pr_dtmvtolt;
                pr_tab_regimp(vr_indregimp).juros    := (to_number(TRIM(substr(vr_setlinha,18,15))) / 100);
                pr_tab_regimp(vr_indregimp).juros    := nvl(pr_tab_regimp(vr_indregimp).juros,0) + (to_number(TRIM(substr(vr_setlinha,123,15))) / 100);
                pr_tab_regimp(vr_indregimp).vlabatim := (to_number(TRIM(substr(vr_setlinha,33,15))) / 100);
                pr_tab_regimp(vr_indregimp).vlabatim := nvl(pr_tab_regimp(vr_indregimp).vlabatim,0) + (to_number(TRIM(substr(vr_setlinha,48,15))) / 100);
                pr_tab_regimp(vr_indregimp).vldpagto := pr_tab_regimp(vr_indregimp).vllanmto +
                                                         pr_tab_regimp(vr_indregimp).juros  -
                                                         pr_tab_regimp(vr_indregimp).vlabatim;

                --
                IF ( vr_incnvaut OR vr_inarqcbr = 2 ) AND  pr_tab_regimp(vr_indregimp).flpagchq = FALSE THEN

                  -- gerando o indice da tabela temporaria
                  vr_indcrawcta := lpad(pr_tab_regimp(vr_indregimp).nrdconta,10,'0')||
                                      lpad(vr_nroconve,10,'0')||
                                      lpad(substr(vr_setlinha,9,5),10,'0');

                  -- alimentando a tabela das contas processadas para geracao dos
                  -- arquivos de retorno - layout febraban
                  vr_tab_crawcta(vr_indcrawcta).nrdconta := pr_tab_regimp(vr_indregimp).nrdconta;
                  vr_tab_crawcta(vr_indcrawcta).dsstring := vr_setlinha;
                  vr_tab_crawcta(vr_indcrawcta).nrsequen := substr(vr_setlinha,9,5);
                  vr_tab_crawcta(vr_indcrawcta).nrconven := vr_nroconve;
                  vr_tab_crawcta(vr_indcrawcta).nrctabbd := vr_nrdctabb;
                END IF;

              /* Registro Detalhe Y */
              ELSIF substr(vr_setlinha,8,1)  = '3' AND substr(vr_setlinha,14,1) = 'Y' THEN
                -- Incrementando a quantidade de arquivos
                vr_contaarq := vr_contaarq + 1;

                -- verifica o banco e o lote de servico
                IF  vr_cdbancbb <> to_number(TRIM(substr(vr_setlinha,1,3))) OR
                    vr_loteserv <> to_number(TRIM(substr(vr_setlinha,4,4))) THEN

                  /* Nro Lote Errado */
                  pr_cdcritic := 58;

                  /* Setando a critica */
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
                  pr_dscritic := pr_dscritic || ' ' ||pr_tab_cratarq(vr_ind).nmarquiv || ' Lote ' || vr_loteserv;

                  -- gerando a sequencia da tabela de erros
                  vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                  /* Proximo Arquivo */
                  EXIT;
                END IF;

                -- informacoes do cheque
                pr_tab_regimp(vr_indregimp).dscheque := 'Compe:'  || TRIM(substr(vr_setlinha,20,3))  || ' ' ||
                                                        'Banco:'  || TRIM(substr(vr_setlinha,23,3))  || ' ' ||
                                                        'Ag.:'    || TRIM(substr(vr_setlinha,26,4))  || ' ' ||
                                                        'Cta.:'   || TRIM(substr(vr_setlinha,31,10)) || ' ' ||
                                                        'Cheque:' || TRIM(substr(vr_setlinha,42,6));
                IF pr_tab_regimp(vr_indregimp).cdocorre = 6 THEN
                  pr_tab_regimp(vr_indregimp).dcmc7chq := 'CHQ';
                ELSIF pr_tab_regimp(vr_indregimp).cdocorre = 44 THEN
                  pr_tab_regimp(vr_indregimp).dcmc7chq := 'CHQDV';
                ELSIF pr_tab_regimp(vr_indregimp).cdocorre = 50 THEN
                  pr_tab_regimp(vr_indregimp).dcmc7chq := 'CHQPD';
                ELSE
                  pr_tab_regimp(vr_indregimp).dcmc7chq := pr_tab_regimp(vr_indregimp).cdocorre;
                END IF;
                pr_tab_regimp(vr_indregimp).dcmc7chq := pr_tab_regimp(vr_indregimp).dcmc7chq || ';' ||
                                                        TRIM(substr(vr_setlinha,20,3)) || ';' ||
                                                        TRIM(substr(vr_setlinha,23,3)) || ';' ||
                                                        TRIM(substr(vr_setlinha,26,4)) || ';' ||
                                                        TRIM(substr(vr_setlinha,31,10));
                pr_tab_regimp(vr_indregimp).flpagchq := TRUE;

                -- Verifica se existe bloqueto de cobranca para o documento informado
                OPEN cr_crapcob ( pr_cdcooper => pr_cdcooper
                                 ,pr_cdbandoc => pr_tab_regimp(vr_indregimp).codbanco
                                 ,pr_nrdctabb => pr_tab_regimp(vr_indregimp).nrdctabb
                                 ,pr_nrcnvcob => pr_tab_regimp(vr_indregimp).nroconve
                                 ,pr_nrdocmto => pr_tab_regimp(vr_indregimp).nrdocmto
                                 ,pr_nrdconta => pr_tab_regimp(vr_indregimp).nrdconta);
                FETCH cr_crapcob INTO rw_crapcob;
                -- se retornar dados e somente um registro...
                IF cr_crapcob%FOUND AND rw_crapcob.qtde_reg = 1 THEN
                  -- Fecha o cursor
                  CLOSE cr_crapcob;
                  -- Atualiza a tabela crapcob
                  BEGIN
                    UPDATE crapcob SET dcmc7chq = pr_tab_regimp(vr_indregimp).dcmc7chq
                    WHERE ROWID = rw_crapcob.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                      --Fechar Arquivo
                      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
                      -- Gerando a critica
                      pr_dscritic := 'Erro ao atualizar a tabela crapcob na rotina pc_processa_arq_compensacao. '||SQLERRM;
                      -- gerando excecao
                      RAISE vr_exc_saida;
                  END;
                ELSE
                  -- fechando o cursor
                  CLOSE cr_crapcob;
                END IF;

                --
                IF (vr_incnvaut OR vr_inarqcbr = 2) AND pr_tab_regimp(vr_indregimp).flpagchq = FALSE THEN

                  -- alimentando a tabela das contas processadas para geracao dos
                  -- arquivos de retorno - layout febraban
                  vr_indcrawcta := lpad(pr_tab_regimp(vr_indregimp).nrdconta,10,'0')||
                                      lpad(substr(vr_setlinha,9,5),10,'0');
                  vr_tab_crawcta(vr_indcrawcta).nrdconta := pr_tab_regimp(vr_indregimp).nrdconta;
                  vr_tab_crawcta(vr_indcrawcta).dsstring := vr_setlinha;
                  vr_tab_crawcta(vr_indcrawcta).nrsequen := substr(vr_setlinha,9,5);
                  vr_tab_crawcta(vr_indcrawcta).nrconven := vr_nroconve;
                  vr_tab_crawcta(vr_indcrawcta).nrctabbd := vr_nrdctabb;

                END IF;

              /* Trailer  Lote */
              ELSIF  substr(vr_setlinha,8,1)  = '5' THEN

                -- Incrementando a quantidade de arquivos
                vr_contaarq := vr_contaarq + 1;

                -- verifica o banco e o lote de servico
                IF  vr_cdbancbb <> to_number(TRIM(substr(vr_setlinha,1,3))) OR
                    vr_loteserv <> to_number(TRIM(substr(vr_setlinha,4,4))) THEN

                  /* Nro Lote Errado */
                  pr_cdcritic := 58;

                  /* Setando a critica */
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
                  pr_dscritic := pr_dscritic || ' ' ||pr_tab_cratarq(vr_ind).nmarquiv || ' Lote ' || vr_loteserv;

                  -- gerando a sequencia da tabela de erros
                  vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                  /* Proximo Arquivo */
                  EXIT;
                END IF;

              END IF; -- IF substr(vr_setlinha,8,1) = '9' THEN /*  Header Lote */
            END LOOP; -- Inicia o processo de leitura do arquivo inteiro

            --Fechar Arquivo
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;

            IF pr_cdcritic <> 0 THEN

              -- Limpando a tabela temporaria
              pr_tab_regimp.delete;

              -- nome do arquivo que nao processou por erro...
              vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_ind).nmarquiv,8,53);

              -- Comando para copiar o arquivo para a pasta salvar
              vr_ind_comando := vr_ind_comando + 1;
              vr_tab_comando.extend;
              vr_tab_comando(vr_ind_comando) := 'cp '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_ind).nmarquiv||' '||vr_caminho_salvar;

              -- Comando para mover o arquivo
              vr_ind_comando := vr_ind_comando + 1;
              vr_tab_comando.extend;
              vr_tab_comando(vr_ind_comando) := 'mv '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_ind).nmarquiv||' '||
                                  vr_caminho_integra||'/'||vr_nmarquiv;

              -- Seta a descricao da critica
              pr_dscritic := 'Houve criticas na Importacao '||pr_tab_cratarq(vr_ind).nmarquiv;

              -- gerando a sequencia da tabela de erros
              vr_nrsequen := nvl(vr_nrsequen,0) + 1;

              /* Retorno de erro da BO */
              gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nrsequen => vr_nrsequen
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic
                                    ,pr_tab_erro => pr_tab_erro);

              pr_cdcritic := 0;

              -- Vai para o proximo arquivo que de
              vr_ind := pr_tab_cratarq.next(vr_ind);

              CONTINUE; /* Proximo Arquivo */
            END IF;

            -- Atualiza a temp-table dos arquivos
            pr_tab_cratarq(vr_ind).cdagenci := vr_cdagenci;
            pr_tab_cratarq(vr_ind).cdbccxlt := vr_cdbccxlt;
            pr_tab_cratarq(vr_ind).nrdolote := vr_nrdolote;
            pr_tab_cratarq(vr_ind).tplotmov := vr_tplotmov;
            pr_tab_cratarq(vr_ind).nroconve := vr_nroconve;
            pr_tab_cratarq(vr_ind).qtregrec := vr_qtregrec;
            pr_tab_cratarq(vr_ind).nrseqdig := vr_contaarq;
            pr_tab_cratarq(vr_ind).vllanmto := vr_vllanmto;
            pr_tab_cratarq(vr_ind).cdhistor := vr_cdhistor;
            pr_tab_cratarq(vr_ind).cdtarhis := vr_cdtarhis;
            pr_tab_cratarq(vr_ind).vltarifa := vr_vlrtarif;

            -- Vai para o proximo arquivo
            vr_ind := pr_tab_cratarq.next(vr_ind);
          END LOOP; --WHILE vr_ind IS NOT NULL LOOP

          -- se gerou algum erro, retorna critica
          IF pr_tab_erro.count() > 0 THEN
            pr_dscritic := pr_tab_erro(pr_tab_erro.first).dscritic;
          ELSE
            pr_dscritic := NULL;
          END IF;
        END;
      END pc_processa_arq_compensacao;

      /* efetua lançamentos */
      PROCEDURE pc_efetua_lancamento( pr_cdcooper IN crapcop.cdcooper%TYPE
                                     ,pr_nrdconta IN INTEGER
                                     ,pr_vllanmto IN NUMBER
                                     ,pr_cdhistor IN INTEGER
                                     ,pr_nrdocmto IN INTEGER
                                     ,pr_qtdbolet IN INTEGER
                                     ,pr_nrdctabb IN INTEGER /*tt-regimp.nrdctabb*/
                                     ,pr_rowid_craplot IN ROWID
                                     ,pr_dscritic OUT VARCHAR2) IS
      BEGIN
        DECLARE

          -- cursor de lotes
          CURSOR cr_craplot (pr_rowid_craplot IN ROWID ) IS
            SELECT craplot.cdcooper
                  ,craplot.dtmvtolt
                  ,craplot.cdagenci
                  ,craplot.cdbccxlt
                  ,craplot.nrdolote
                  ,craplot.nrseqdig
            FROM   craplot
            WHERE  craplot.ROWID = pr_rowid_craplot;
          rw_craplot cr_craplot%ROWTYPE;

          vr_nrseqdig craplcm.nrseqdig%TYPE;
          vr_cdpesqbb VARCHAR2(100);
          vr_nrdocmto INTEGER;
          vr_existe    BOOLEAN := TRUE;
        BEGIN
          -- seleciona informações do lote
          OPEN cr_craplot( pr_rowid_craplot => pr_rowid_craplot);
          FETCH cr_craplot INTO rw_craplot;
          -- verifica se encontrou o registro pelo rowid
          IF cr_craplot%NOTFOUND THEN
            -- fecha o cursor antes da excecao
            CLOSE cr_craplot;
            -- mensagem de erro que será exibida
            pr_dscritic := 'Não foi encontrado o lote para efetuar o lançamento na rotina pc_efetua_lancamento.';
            -- volta para o programa chamador
            RETURN;
          ELSE
            -- fecha o cursor
            CLOSE cr_craplot;
          END IF;

          -- inicializando a variavel do documento
          vr_nrdocmto := pr_nrdocmto;

          -- enquanto o numero do documento existir na base, incrementa 1000000
          WHILE vr_existe LOOP
            --seleciona informacoes da craplcm
            OPEN cr_craplcm( pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => rw_craplot.dtmvtolt
                            ,pr_cdagenci => rw_craplot.cdagenci
                            ,pr_cdbccxlt => rw_craplot.cdbccxlt
                            ,pr_nrdolote => rw_craplot.nrdolote
                            ,pr_nrdctabb => pr_nrdconta
                            ,pr_nrdocmto => vr_nrdocmto);
            FETCH cr_craplcm INTO rw_craplcm;

            -- se existe o registro, acrescenta um milhao ao número do documento
            IF cr_craplcm%FOUND THEN
              vr_nrdocmto := vr_nrdocmto + 1000000;
            END IF;
            -- alimentando a variavel de controle com o status do cursor
            vr_existe := cr_craplcm%FOUND;
            -- fecha o cursor
            CLOSE cr_craplcm;
          END LOOP;

          -- insere dados na craplcm
          BEGIN
            INSERT INTO craplcm( craplcm.dtmvtolt
                                ,craplcm.cdagenci
                                ,craplcm.cdbccxlt
                                ,craplcm.nrdolote
                                ,craplcm.nrdconta
                                ,craplcm.nrdctabb
                                ,craplcm.nrdctitg
                                ,craplcm.nrdocmto
                                ,craplcm.cdhistor
                                ,craplcm.nrseqdig
                                ,craplcm.vllanmto
                                ,craplcm.cdpesqbb
                                ,craplcm.cdcooper
                                ,craplcm.dsidenti
            ) VALUES (        rw_craplot.dtmvtolt
                              ,rw_craplot.cdagenci
                              ,rw_craplot.cdbccxlt
                              ,rw_craplot.nrdolote
                              ,nvl(pr_nrdconta,0)
                              ,nvl(pr_nrdconta,0)
                              ,lpad(pr_nrdctabb,8,'0')
                              ,nvl(vr_nrdocmto,0)
                              ,nvl(pr_cdhistor,0)
                              ,rw_craplot.nrseqdig + 1
                              ,nvl(pr_vllanmto,0) /* Tarifa - Debito */
                              ,nvl(vr_cdpesqbb,' ')
                              ,nvl(pr_cdcooper,0)
                              ,To_Char(pr_qtdbolet))
            RETURNING craplcm.nrseqdig
                 INTO vr_nrseqdig;
          EXCEPTION
            WHEN OTHERS THEN
            pr_dscritic := 'Erro ao inserir dados na craplcm na rotina pc_efetua_lancamento. '||SQLERRM;
            -- volta para o programa chamador
            RETURN;
          END;

          /* CRED. COBRANCA */
          IF pr_cdhistor = 266 OR pr_cdhistor = 1132 THEN
            BEGIN
              UPDATE craplot SET craplot.qtinfoln = craplot.qtinfoln + 1
                                ,craplot.qtcompln = craplot.qtcompln + 1
                                ,craplot.vlinfocr = craplot.vlinfocr + Nvl(pr_vllanmto,0)
                                ,craplot.vlcompcr = craplot.vlcompcr + Nvl(pr_vllanmto,0)
                                ,craplot.nrseqdig = nvl(vr_nrseqdig,0)
              WHERE craplot.ROWID = pr_rowid_craplot;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar dados na craplot na rotina pc_efetua_lancamento. '||SQLERRM;
                -- volta para o programa chamador
                RETURN;
            END;
          ELSE --IF pr_cdhistor = 266 OR pr_cdhistor = 1132 THEN
            BEGIN
              UPDATE craplot SET craplot.qtinfoln = craplot.qtinfoln + 1
                                ,craplot.qtcompln = craplot.qtcompln + 1
                                ,craplot.vlinfodb = craplot.vlinfodb + Nvl(pr_vllanmto,0)
                                ,craplot.vlcompdb = craplot.vlcompdb + Nvl(pr_vllanmto,0)
                                ,craplot.nrseqdig = nvl(vr_nrseqdig,0)
              WHERE craplot.ROWID = pr_rowid_craplot;
            EXCEPTION
              WHEN OTHERS THEN
                pr_dscritic := 'Erro ao atualizar dados na craplot na rotina pc_efetua_lancamento. '||SQLERRM;
                -- volta para o programa chamador
                RETURN;
            END;
          END IF;--IF pr_cdhistor = 266 OR pr_cdhistor = 1132 THEN
        END;
      END pc_efetua_lancamento;

      /* efetua lancamento de tarifa */
      PROCEDURE pc_efetua_lanc_craplat( pr_cdcooper IN crapcop.cdcooper%TYPE
                                        ,pr_nrdconta IN INTEGER
                                        ,pr_dtmvtolt IN DATE
                                        ,pr_cdagenci IN INTEGER
                                        ,pr_cdbccxlt IN INTEGER
                                        ,pr_nrdolote IN INTEGER
                                        ,pr_tpdolote IN INTEGER
                                        ,pr_cdhistor IN INTEGER
                                        ,pr_vltarifa IN NUMBER
                                        ,pr_cdfvlcop IN INTEGER
                                        ,pr_cdpesqbb IN VARCHAR2
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                        ,pr_dscritic OUT VARCHAR2
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro) IS
      BEGIN
        DECLARE
          vr_rowid_craplat ROWID;
        BEGIN
          IF pr_cdpesqbb = 'LANTAR' THEN
            NULL;
          END IF;
          -- efetua o lançamento da tarifa
          TARI0001.pc_cria_lan_auto_tarifa(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                          ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                          ,pr_dtmvtolt => pr_dtmvtolt --Data Lancamento
                                          ,pr_cdhistor => pr_cdhistor --Codigo Historico
                                          ,pr_vllanaut => pr_vltarifa --Valor lancamento automatico
                                          ,pr_cdoperad => 1           --Codigo Operador
                                          ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                          ,pr_cdbccxlt => pr_cdbccxlt --Codigo banco caixa
                                          ,pr_nrdolote => pr_nrdolote --Numero do lote
                                          ,pr_tpdolote => pr_tpdolote --Tipo do lote
                                          ,pr_nrdocmto => 0           --Numero do documento
                                          ,pr_nrdctabb => pr_nrdconta --Numero da conta
                                          ,pr_nrdctitg => lpad(pr_nrdconta,8,'0') --Numero da conta integracao
                                          ,pr_cdpesqbb => pr_cdpesqbb --Codigo pesquisa
                                          ,pr_cdbanchq => 0  --Codigo Banco Cheque
                                          ,pr_cdagechq => 0  --Codigo Agencia Cheque
                                          ,pr_nrctachq => 0  --Numero Conta Cheque
                                          ,pr_flgaviso => FALSE  --Flag aviso
                                          ,pr_tpdaviso => 0  --Tipo aviso
                                          ,pr_cdfvlcop => pr_cdfvlcop --Codigo cooperativa
                                          ,pr_inproces => rw_crapdat.inproces --Indicador processo
                                          ,pr_rowid_craplat => vr_rowid_craplat --Rowid do lancamento tarifa
                                          ,pr_tab_erro => pr_tab_erro --Tabela retorno erro
                                          ,pr_cdcritic => pr_cdcritic  --Codigo Critica
                                          ,pr_dscritic => pr_dscritic); --Descricao Critica
        END;
      END pc_efetua_lanc_craplat;

      /*Atualizar lancamentos de debito e credito e movimentos de baixa dos boletos importados*/
      PROCEDURE pc_atualiza_lancamentos_baixa( pr_cdcooper IN INTEGER
                                              ,pr_dtmvtolt IN DATE
                                              ,pr_flgcruni IN BOOLEAN
                                              ,pr_cdpesqbb IN VARCHAR2
                                              ,pr_indregimp IN VARCHAR2
                                              ,pr_indcratarq IN VARCHAR2
                                              ,pr_rwcrapcob IN cr_crapcob%ROWTYPE
                                              ,pr_rowid_craplot IN ROWID
                                              ,pr_cdagenci IN INTEGER
                                              ,pr_nrdcaixa IN INTEGER
                                              ,pr_cdcritic  OUT crapcri.cdcritic%TYPE
                                              ,pr_dscritic  OUT VARCHAR2
                                              ,pr_tab_erro  IN OUT gene0001.typ_tab_erro) IS
      BEGIN
      /*************************************************************************
          Objetivo: Atualizar lancamentos de debito e credito e movimentos de
                    baixa dos boletos importados
      *************************************************************************/
        DECLARE
          -- Titulos contidos do Bordero de desconto de titulos
          CURSOR cr_craptdb( pr_cdcooper IN craptdb.cdcooper%TYPE
                            ,pr_nrdconta IN craptdb.nrdconta%TYPE
                            ,pr_cdbandoc IN craptdb.cdbandoc%TYPE
                            ,pr_nrdctabb IN craptdb.nrdctabb%TYPE
                            ,pr_nrcnvcob IN craptdb.nrcnvcob%TYPE
                            ,pr_nrdocmto IN craptdb.nrdocmto%TYPE) IS
            SELECT craptdb.nrdconta
                  ,craptdb.dtvencto
                  ,craptdb.nrseqdig
                  ,craptdb.cdoperad
                  ,craptdb.nrdocmto
                  ,craptdb.nrctrlim
                  ,craptdb.nrborder
                  ,craptdb.vlliquid
                  ,craptdb.dtlibbdt
                  ,craptdb.cdcooper
                  ,craptdb.cdbandoc
                  ,craptdb.nrdctabb
                  ,craptdb.nrcnvcob
                  ,craptdb.cdoperes
                  ,craptdb.dtresgat
                  ,craptdb.vlliqres
                  ,craptdb.vltitulo
                  ,craptdb.insittit
                  ,craptdb.nrinssac
                  ,craptdb.dtdpagto
                  ,craptdb.rowid
            FROM   craptdb
            WHERE  craptdb.cdcooper = pr_cdcooper
            AND    craptdb.nrdconta = pr_nrdconta
            AND    craptdb.cdbandoc = pr_cdbandoc
            AND    craptdb.nrdctabb = pr_nrdctabb
            AND    craptdb.nrcnvcob = pr_nrcnvcob
            AND    craptdb.nrdocmto = pr_nrdocmto;
          rw_craptdb cr_craptdb%ROWTYPE;

          /* flg para controlar se deve creditar o cooperado ou nao
            devido ao titulo ser descontado */
          vr_flgcredi         BOOLEAN;
          vr_inddescontar     VARCHAR2(100);
          vr_tab_erro_bo     gene0001.typ_tab_erro;
        BEGIN
          /*---- Atualizando Lancamento Tarifa --*/
          /* Nao lancar tarifa para pagamentos de titulos que estao em
            emprestimo - Guilherme 22/06/2009 */

          /* controlado antes da chamada do procedimento*/

          -- verifica se o rowtype possui informação
          IF pr_rwcrapcob.nrctremp IS NULL THEN
            -- Volta para o programa chamador sem gerar critica
            RETURN;
          END IF;

          -- se o valor da tarifa é maior que zero
          IF Nvl(vr_tab_regimp(pr_indregimp).vlrtarif,0) > 0  AND
             pr_rwcrapcob.nrctremp = 0 THEN

            -- se não utiliza credito unificado de cobranca
            -- lanca na craplat, senao somente acumula os valores
            IF NOT pr_flgcruni THEN

              vr_nrdoctax := Nvl(vr_nrdoctax,0) + 1;
              vr_totvllanmto := 0;
              vr_totvllanmt2 := 0;
              vr_totqtdbolet := 0;
              vr_totqtdbole2 := 0;

              -- efetua lançamento na craplat
              pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => vr_tab_regimp(pr_indregimp).nrdconta
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_cdagenci => vr_tab_cratarq(pr_indcratarq).cdagenci
                                    ,pr_cdbccxlt => vr_tab_cratarq(pr_indcratarq).cdbccxlt
                                    ,pr_nrdolote => vr_tab_cratarq(pr_indcratarq).nrdolote
                                    ,pr_tpdolote => vr_tab_cratarq(pr_indcratarq).tplotmov
                                    ,pr_cdhistor => vr_tab_regimp(pr_indregimp).cdhistor
                                    ,pr_vltarifa => vr_tab_regimp(pr_indregimp).vlrtarif
                                    ,pr_cdfvlcop => vr_tab_regimp(pr_indregimp).cdfvlcop
                                    ,pr_cdpesqbb => pr_cdpesqbb
                                    ,pr_cdcritic => pr_cdcritic
                                    ,pr_dscritic => pr_dscritic
                                    ,pr_tab_erro => pr_tab_erro);
              -- verifica se ocorreu algum erro
              IF trim(pr_dscritic) IS NOT NULL THEN
                -- retorna para o programa chamador
                RETURN;
              END IF;

            ELSE
              -- acumulando os valores
              vr_totvllanmto := Nvl(vr_totvllanmto,0) + Nvl(vr_tab_regimp(pr_indregimp).vlrtarif,0);
              vr_totqtdbolet := Nvl(vr_totqtdbolet,0) + 1;
            END IF;
            -- acumulando os valores
            vr_vlcompdb := Nvl(vr_vlcompdb,0) + Nvl(vr_tab_regimp(pr_indregimp).vlrtarif,0);
          END IF;

          /* Somente para titulos que nao estao em emprestimo */
          -- se não possuir numero de contrato de emprestimo
          IF  Nvl(pr_rwcrapcob.nrctremp,0) = 0  THEN

            -- Indica que deve creditar o cooperado
            vr_flgcredi := TRUE;

            -- Verificando se o titulo esta em algum bordero de desconto
            OPEN cr_craptdb( pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_rwcrapcob.nrdconta
                            ,pr_cdbandoc => pr_rwcrapcob.cdbandoc
                            ,pr_nrdctabb => pr_rwcrapcob.nrdctabb
                            ,pr_nrcnvcob => pr_rwcrapcob.nrcnvcob
                            ,pr_nrdocmto => pr_rwcrapcob.nrdocmto);
            FETCH cr_craptdb INTO rw_craptdb;

            --Se não estiver em nenhum bordero
            IF cr_craptdb%FOUND THEN
              -- fechando o cursor
              CLOSE cr_craptdb;

              -- se a situacao do titulo é 4-liberado
              IF rw_craptdb.insittit = 4 THEN

                -- indica que nao deve creditar o cooperado
                vr_flgcredi := FALSE;

                /* Armazena os titulos com desconto para efetuar baixa no final do processo */
                vr_inddescontar := LPad(rw_craptdb.nrdconta, 10, '0') || LPad(vr_tab_descontar.count() + 1, 10,'0');
                vr_tab_descontar(vr_inddescontar).flgstats := vr_tab_descontar.Count() + 1;
                vr_tab_descontar(vr_inddescontar).cdbandoc := rw_craptdb.cdbandoc;
                vr_tab_descontar(vr_inddescontar).dtlibbdt := rw_craptdb.dtlibbdt;
                vr_tab_descontar(vr_inddescontar).dtvencto := rw_craptdb.dtvencto;
                vr_tab_descontar(vr_inddescontar).nrcnvcob := rw_craptdb.nrcnvcob;
                vr_tab_descontar(vr_inddescontar).nrctrlim := rw_craptdb.nrctrlim;
                vr_tab_descontar(vr_inddescontar).nrdctabb := rw_craptdb.nrdctabb;
                vr_tab_descontar(vr_inddescontar).nrdocmto := rw_craptdb.nrdocmto;
                vr_tab_descontar(vr_inddescontar).nrinssac := rw_craptdb.nrinssac;
                vr_tab_descontar(vr_inddescontar).vlliquid := rw_craptdb.vlliquid;
                vr_tab_descontar(vr_inddescontar).nrdconta := rw_craptdb.nrdconta;
                vr_tab_descontar(vr_inddescontar).nrborder := rw_craptdb.nrborder;
                vr_tab_descontar(vr_inddescontar).vltitulo := vr_vllanmto;
                -- inicializar valor para que não fique nulo
                vr_tab_descontar(vr_inddescontar).flgregis := FALSE ;

                --
                vr_qtregicd := Nvl(vr_qtregicd,0) + 1;
                vr_vlregicd := Nvl(vr_vlregicd,0) + Nvl(vr_vllanmto,0);
              ELSIF rw_craptdb.insittit = 0 THEN /* Em estudo */
                -- indica que deve creditar o cooperado
                vr_flgcredi := TRUE;

                /* remover titulo do bordero de desconto */
                BEGIN
                  DELETE FROM craptdb WHERE ROWID = rw_craptdb.ROWID;
                EXCEPTION
                  WHEN OTHERS THEN
                    pr_dscritic := 'Erro ao excluir a tabela craptdb na rotina pc_atualiza_lancamentos_baixa. '||SQLERRM;
                    --retorna a critica para o programa chamador
                    RETURN;
                END;
              ELSE --IF rw_craptdb.insittit = 4 THEN
                /* pode ser titulo vencido ou resgatado */
                vr_flgcredi := TRUE;
              END IF;--IF rw_craptdb.insittit = 4 THEN
            ELSE
              -- fechando o cursor
              CLOSE cr_craptdb;
            END IF;

            -- se o cooperado deve ser creditado
            IF vr_flgcredi = TRUE THEN
              --
              IF NOT pr_flgcruni THEN

                vr_totvllanmto := 0;
                vr_totvllanmt2 := 0;
                vr_totqtdbolet := 0;
                vr_totqtdbole2 := 0;

                -- Efetua o lançamento
                pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta  => vr_nrdconta
                                    ,pr_vllanmto  => vr_vllanmto
                                    ,pr_cdhistor  => vr_tab_cratarq(pr_indcratarq).cdhistor
                                    ,pr_nrdocmto  => vr_nrdocmto
                                    ,pr_qtdbolet  => 1
                                    ,pr_nrdctabb  => vr_tab_regimp(pr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                    ,pr_rowid_craplot => pr_rowid_craplot
                                    ,pr_dscritic => pr_dscritic);
                -- se retornar erro, volta para o programa chamador
                IF trim(pr_dscritic) IS NOT NULL THEN
                   -- Volta para o programa chamador
                   RETURN;
                END IF;
              ELSE --IF NOT pr_flgcruni THEN
                vr_totvllanmt2 := Nvl(vr_totvllanmt2,0) + Nvl(vr_vllanmto,0);
                vr_totqtdbole2 := Nvl(vr_totqtdbole2,0) + 1;
                vr_nrdocmto := Nvl(vr_nrdocmto,0) + 1;
              END IF; --IF NOT pr_flgcruni THEN

              vr_qtregisd := Nvl(vr_qtregisd,0) + 1;
              vr_vlregisd := Nvl(vr_vlregisd,0) + Nvl(vr_vllanmto,0);
            END IF;  --IF vr_flgcredi = TRUE THEN
          ELSE --IF  pr_rwcrapcob.nrctremp = 0  THEN
            /* Faz os lancamentos necessarios */
            paga0001.pc_baixa_epr_titulo (pr_cdcooper  => pr_cdcooper     --Codigo Cooperativa
                                          ,pr_cdagenci => 0               --Codigo Agencia
                                          ,pr_nrdcaixa => 0               --Numero do Caixa
                                          ,pr_cdoperad => 0               --Codigo Operador
                                          ,pr_nrdconta => vr_nrdconta     --Numero da Conta
                                          ,pr_idseqttl => 1               --Sequencial do Titular
                                          ,pr_idorigem => 1               --Identificador Origem pagamento
                                          ,pr_nmdatela => 'CRPS375'       --Nome do programa chamador
                                          ,pr_dtmvtolt => pr_dtmvtolt     --Data do Movimento
                                          ,pr_nrctremp => pr_rwcrapcob.nrctremp --Numero Contrato Emprestimo
                                          ,pr_nrctasac => pr_rwcrapcob.nrctasac --Numero da Conta do Sacado
                                          ,pr_nrboleto => pr_rwcrapcob.nrdocmto --Numero do Boleto
                                          ,pr_dtvencto => pr_rwcrapcob.dtvencto --Data Vencimento
                                          ,pr_vlboleto => pr_rwcrapcob.vltitulo --Valor boleto
                                          ,pr_vllanmto => vr_vllanmto           --Valor Lancamento
                                          ,pr_flgerlog => TRUE                  --Gerar erro log
                                          ,pr_tab_erro => vr_tab_erro_bo        --Tabela de erro
                                          ,pr_cdcritic => pr_cdcritic           --Codigo de erro
                                          ,pr_dscritic => pr_dscritic );        --Retorno de Erro
            -- se gerou erro na chamada
            IF trim(pr_dscritic) IS NOT NULL THEN
              -- verifica se gerou a tabela de erros
              IF vr_tab_erro_bo.count() > 0 THEN
                -- Escreve os erros no log
                FOR vr_ind IN vr_tab_erro_bo.first .. vr_tab_erro_bo.last LOOP
                  -- calculando a proxima sequencia
                  vr_nrsequen := Nvl(vr_nrsequen,0) + 1;
                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => vr_tab_erro_bo(vr_ind).dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                END LOOP;--FOR vr_ind IN vr_tab_erro_bo.first .. vr_tab_erro_bo.last LOOP
              END IF;--IF vr_tab_erro.count() > 0 THEN
              -- retorna critica para o programa chamador
              RETURN;
            ELSE
              -- incrementando o contador de registros integrados sem desconto
              vr_qtregisd := Nvl(vr_qtregisd,0) + 1;
              -- acumulando o valor total dos titulos integrados sem desconto
              vr_vlregisd := Nvl(vr_vlregisd,0) + Nvl(vr_vllanmto,0);
            END IF;--IF pr_dscritic IS NOT NULL THEN
          END IF; --IF  pr_rwcrapcob.nrctremp = 0  THEN
        END;
      END pc_atualiza_lancamentos_baixa; /* fim atualiza_lancamentos_baixa */

      /* Insere dados na tabela crapcob*/
      PROCEDURE pc_cria_ceb_cob( pr_cdcooper IN crapcob.cdcooper%TYPE
                                ,pr_dtmvtolt IN DATE
                                ,pr_ind_regimp IN VARCHAR2
                                ,pr_flgutceb IN BOOLEAN
                                ,pr_flgcebok OUT BOOLEAN
                                ,pr_rowid_crapcob OUT ROWID
                                ,pr_dscritic OUT VARCHAR2 ) IS
      BEGIN
        DECLARE
          -- Cadastro de emissao de bloquetos pelo convenio cecred
          -- e numero do convenio do Banco do Brasil
          CURSOR cr_crapceb2 ( pr_cdcooper IN crapcob.cdcooper%TYPE
                              ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE
                              ,pr_nrconven IN crapceb.nrconven%TYPE) IS
            SELECT crapceb.inarqcbr
                  ,crapceb.nrdconta
                  ,crapceb.flgcruni
            FROM   crapceb
            WHERE  crapceb.cdcooper = pr_cdcooper
            AND    crapceb.nrcnvceb = pr_nrcnvceb
            AND    crapceb.nrconven = pr_nrconven
            ORDER BY crapceb.cdcooper
                    ,crapceb.nrconven
                    ,crapceb.nrcnvceb;
          rw_crapceb2 cr_crapceb2%ROWTYPE;

          -- Busca emissao de bloquetos por conta do associado
          -- e convenio do banco do Brasil
          CURSOR cr_crapceb3 ( pr_cdcooper IN crapcob.cdcooper%TYPE
                              ,pr_nrdconta IN crapceb.nrdconta%TYPE
                              ,pr_nrconven IN crapceb.nrconven%TYPE) IS
            SELECT crapceb.inarqcbr
                  ,crapceb.nrdconta
                  ,crapceb.flgcruni
                  ,crapceb.cddemail
                  ,crapceb.nrcnvceb
                  ,0 crapcob_nrdconta
                  ,COUNT(*) OVER() qtde_reg
            FROM   crapceb
            WHERE  crapceb.cdcooper = pr_cdcooper
            AND    crapceb.nrdconta = pr_nrdconta
            AND    crapceb.nrconven = pr_nrconven
            ORDER BY crapceb.cdcooper
                    ,crapceb.nrdconta
                    ,crapceb.nrconven;

          vr_nrctabol INTEGER;
          vr_nrnosnum crapcob.nrnosnum%TYPE;
          
        BEGIN
          pr_flgcebok := FALSE;
          vr_nrctabol := vr_tab_regimp(pr_ind_regimp).nrdconta;

          /* Se tem identificador de sequencia */
          IF pr_flgutceb THEN
            -- verificando os parametros de cobranca
            OPEN cr_crapceb2( pr_cdcooper => pr_cdcooper
                             ,pr_nrcnvceb => vr_tab_regimp(pr_ind_regimp).nrcnvceb
                             ,pr_nrconven => vr_tab_regimp(pr_ind_regimp).nroconve);
            FETCH cr_crapceb2 INTO rw_crapceb2;

            -- se encontrar atribui o numero da conta
            IF cr_crapceb2%FOUND THEN
              vr_nrctabol := rw_crapceb2.nrdconta;
            ELSE
              vr_nrctabol := 0;
            END IF;

            -- fecha o cursor
            CLOSE cr_crapceb2;
          END IF; -- IF pr_flgutceb THEN

          -- se nao tem identificador de sequencia e a conta estiver zerada
          IF NOT (pr_flgutceb  AND vr_nrctabol = 0) THEN

            -- se o número da conta do boleto é diferente de zero...
            IF vr_nrctabol <> 0 THEN
              -- se o cooperado estiver cadastrado
              OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => vr_nrctabol);
              FETCH cr_crapass INTO rw_crapass;
              vr_crapass:= cr_crapass%FOUND;
              CLOSE cr_crapass;

              IF vr_crapass THEN

                /* verificar se cooperado possui convenio */
                OPEN cr_crapceb3 ( pr_cdcooper => pr_cdcooper
                                 ,pr_nrconven => vr_tab_regimp(pr_ind_regimp).nroconve
                                 ,pr_nrdconta => vr_nrctabol);
                FETCH cr_crapceb3 INTO rw_crapceb;

                IF cr_crapceb3%FOUND THEN
                  -- fechando o cursor
                  CLOSE cr_crapceb3;
                  
                  --> Gerar nosso numero
                  IF LENGTH(to_char(vr_tab_regimp(pr_ind_regimp).nroconve)) <= 6 THEN
                    vr_nrnosnum := to_char(vr_nrctabol,'fm00000000') ||
                                   to_char(vr_tab_regimp(pr_ind_regimp).nrdocmto,'fm000000000');
                  ELSE   
                    vr_nrnosnum := to_char(vr_tab_regimp(pr_ind_regimp).nroconve, 'fm0000000') ||
                                   to_char(rw_crapceb.nrcnvceb, 'fm0000') || 
                                   to_char(vr_tab_regimp(pr_ind_regimp).nrdocmto, 'fm000000');    
                  END IF; 
                  
                  -- inserindo crapcob
                  BEGIN
                    INSERT INTO crapcob( crapcob.cdcooper
                                        ,crapcob.dtmvtolt
                                        ,crapcob.dtretcob
                                        ,crapcob.nrdconta
                                        ,crapcob.cdbandoc
                                        ,crapcob.nrdctabb
                                        ,crapcob.nrcnvcob
                                        ,crapcob.nrdocmto
                                        ,crapcob.flgregis
                                        ,crapcob.incobran
                                        ,crapcob.nrnosnum)
                    VALUES ( pr_cdcooper
                            ,pr_dtmvtolt
                            ,pr_dtmvtolt
                            ,nvl(vr_nrctabol,0)
                            ,nvl(vr_tab_regimp(pr_ind_regimp).codbanco,0)
                            ,nvl(vr_tab_regimp(pr_ind_regimp).nrdctabb,0)
                            ,nvl(vr_tab_regimp(pr_ind_regimp).nroconve,0)
                            ,nvl(vr_tab_regimp(pr_ind_regimp).nrdocmto,0)
                            ,0 --FALSE -- cob sem reg.
                            ,0
                            ,vr_nrnosnum)
                    RETURNING crapcob.nrdconta
                              ,crapcob.nrcnvcob
                              ,crapcob.dtretcob
                              ,crapcob.incobran
                              ,crapcob.dtdpagto
                              ,crapcob.vldpagto
                              ,crapcob.indpagto
                              ,crapcob.cdbanpag
                              ,crapcob.cdagepag
                              ,crapcob.vltarifa
                              ,crapcob.nrctremp
                              ,crapcob.cdbandoc
                              ,crapcob.nrdctabb
                              ,crapcob.nrdocmto
                              ,crapcob.nrctasac
                              ,crapcob.dtvencto
                              ,crapcob.vltitulo
                              ,crapcob.rowid
                    INTO      rw_crapcob.nrdconta
                              ,rw_crapcob.nrcnvcob
                              ,rw_crapcob.dtretcob
                              ,rw_crapcob.incobran
                              ,rw_crapcob.dtdpagto
                              ,rw_crapcob.vldpagto
                              ,rw_crapcob.indpagto
                              ,rw_crapcob.cdbanpag
                              ,rw_crapcob.cdagepag
                              ,rw_crapcob.vltarifa
                              ,rw_crapcob.nrctremp
                              ,rw_crapcob.cdbandoc
                              ,rw_crapcob.nrdctabb
                              ,rw_crapcob.nrdocmto
                              ,rw_crapcob.nrctasac
                              ,rw_crapcob.dtvencto
                              ,rw_crapcob.vltitulo
                              ,rw_crapcob.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN
                    pr_dscritic := 'Erro ao inserir dados na tabela crapcob na rotina pc_cria_ceb_cob. '||SQLERRM;
                    --retorna a execução para o programa chamador da rotina
                    RETURN;
                  END;

                  -- retornando o Rowid
                  pr_rowid_crapcob := rw_crapcob.rowid;

                  -- setando o parâmetro de retorno
                  pr_flgcebok := TRUE;

                ELSE
                  -- fechando o cursor
                  CLOSE cr_crapceb3;
                END IF; --IF cr_crapceb%FOUND THEN
--              ELSE
                -- fechando o cursor
--                CLOSE cr_crapass;
              END IF; --IF cr_crapass%FOUND THEN
            END IF; --IF vr_nrctabol <> 0 THEN
          END IF; --IF NOT (pr_flgutceb  AND vr_nrctabol = 0) THEN
        END;
      END pc_cria_ceb_cob;


      /*Efetivar as atualizacoes com base na importacao dos arquivos*/
      PROCEDURE pc_efetiva_atualiz_compensacao ( pr_cdcooper IN crapcop.cdcooper%TYPE -- Codigo da cooperativa
                                               ,pr_cdagenci IN INTEGER                -- Codigo ca agencia
                                               ,pr_nrdcaixa IN INTEGER                -- Codigo do caixa
                                               ,pr_dtmvtolt IN DATE                   -- Data da movimento
                                               ,pr_dtmvtopr IN DATE                   -- Data do proximo movimento
                                               ,pr_cdprogra IN crapprg.cdprogra%TYPE  -- Codigo do programa
                                               ,pr_tab_regimp  IN OUT typ_tab_regimp  -- Tabela dos titulos processados
                                               ,pr_tab_cratarq IN OUT typ_tab_cratarq -- Tabela dos arquivos
                                               ,pr_tab_cratrej IN OUT typ_tab_cratrej -- Tabela dos titulos rejeitados
                                               ,pr_tab_erro    OUT gene0001.typ_tab_erro -- Tabela de erros
                                               ,pr_cdcritic    OUT crapcri.cdcritic%TYPE -- Codigo da critica
                                               ,pr_dscritic    OUT VARCHAR2) IS          -- Descricao da critica
      BEGIN
      /*************************************************************************
          Objetivo...: Efetivar as atualizacoes com base na importacao dos
                       arquivos
          Temp-tables: tt-regimp: Boletos importados para atualizacoes na base
                       cratarq : Arquivos a serem movidos/eliminados
      *************************************************************************/
        DECLARE
          -- cadastro de historicos
          TYPE typ_reg_craphis IS
            RECORD ( cdhistor craphis.cdhistor%TYPE
                    ,dshistor craphis.dshistor%TYPE
                    ,indebcre craphis.indebcre%TYPE);

          -- cadastro de historicos
          TYPE typ_tab_craphis IS
            TABLE OF typ_reg_craphis
            INDEX BY PLS_INTEGER;

          vr_tab_craphis typ_tab_craphis;

          -- Cursor para selecionar os parametros do cadastro de cobranca
          CURSOR cr_crapcco_efet( pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_nrconven IN crapcco.nrconven%TYPE) IS
            SELECT crapcco.cdcooper
            FROM   crapcco
            WHERE  crapcco.cdcooper <> pr_cdcooper
            AND    crapcco.nrconven = pr_nrconven
            AND    crapcco.dsorgarq IN ('MIGRACAO','INCORPORACAO');
          rw_crapcco_efet cr_crapcco_efet%ROWTYPE;

          -- Informacoes de contas transferidas entre cooperativas
          CURSOR cr_craptco_efet( pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdcopant IN crapcop.cdcooper%TYPE
                                 ,pr_nrctaant IN INTEGER ) IS
            SELECT craptco.nrdconta
                   ,craptco.cdcooper
                   ,craptco.cdagenci
                   ,craptco.cdcopant
            FROM   craptco
            WHERE  craptco.cdcooper = pr_cdcooper
            AND    craptco.cdcopant = pr_cdcopant
            AND    craptco.nrctaant = pr_nrctaant
            AND    craptco.tpctatrf <> 3
            AND    craptco.flgativo = 1; -- True
          rw_craptco_efet cr_craptco_efet%ROWTYPE;

          -- Informacoes de contas transferidas entre cooperativas
          CURSOR cr_craptco_efet2( pr_cdcooper IN crapcop.cdcooper%TYPE
                                 ,pr_cdcopant IN crapcop.cdcooper%TYPE
                                 ,pr_nrdconta IN INTEGER ) IS
            SELECT craptco.nrdconta
                   ,craptco.cdcooper
                   ,craptco.cdagenci
                   ,craptco.cdcopant
            FROM   craptco
            WHERE  craptco.cdcooper = pr_cdcooper
            AND    craptco.cdcopant = pr_cdcopant
            AND    craptco.nrdconta = pr_nrdconta
            AND    craptco.tpctatrf <> 3
            AND    craptco.flgativo = 1; -- True

          -- seleciona dados da duplicacao de matricula
          CURSOR cr_craptrf( pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_nrdconta IN craptrf.nrdconta%TYPE ) IS
            SELECT craptrf.nrdconta
                  ,craptrf.nrsconta
            FROM   craptrf
            WHERE  craptrf.cdcooper = pr_cdcooper
            AND    craptrf.nrdconta = pr_nrdconta
            AND    craptrf.tptransa = 1
            ORDER BY progress_recid;
          rw_craptrf cr_craptrf%ROWTYPE;

          -- cadastro de contas transferidas entre cooperativas
          CURSOR cr_craptco2( pr_cdcopant IN craptco.cdcopant%TYPE
                             ,pr_nrctaant IN craptco.nrctaant%TYPE) IS
            SELECT craptco.cdcopant
                  ,craptco.nrctaant
            FROM   craptco
            WHERE  craptco.cdcopant = pr_cdcopant
            AND    craptco.nrctaant = pr_nrctaant
            AND    craptco.tpctatrf = 1
            AND    craptco.flgativo = 1 --true
            AND    craptco.tpctatrf <> 3
            ORDER BY progress_recid;
          rw_craptco2 cr_craptco2%ROWTYPE;

          -- cadastro de lotes
          CURSOR cr_craplot( pr_cdcooper IN crapcop.cdcooper%TYPE
                            ,pr_dtmvtolt IN DATE
                            ,pr_cdagenci IN craplot.cdagenci%TYPE
                            ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                            ,pr_nrdolote IN craplot.nrdolote%TYPE ) IS
            SELECT craplot.cdcooper
                  ,craplot.ROWID
            FROM   craplot
            WHERE  craplot.cdcooper = pr_cdcooper
            AND    craplot.dtmvtolt = pr_dtmvtolt
            AND    craplot.cdagenci = pr_cdagenci
            AND    craplot.cdbccxlt = pr_cdbccxlt
            AND    craplot.nrdolote = pr_nrdolote;
          rw_craplot cr_craplot%ROWTYPE;

          -- Informações do acerto Financeiro BB entre cooperativas.
          CURSOR cr_crapafi( pr_cdcooper IN crapafi.cdcooper%TYPE
                            ,pr_nrdctabb IN crapafi.nrdctabb%TYPE  --n(10)
                            ,pr_dtmvtolt IN DATE
                            ,pr_cdcopdst IN crapafi.cdcopdst%TYPE  --n(6)
                            ,pr_cdagedst IN crapafi.cdagedst%TYPE  --n(6)
                            ,pr_nrctadst IN crapafi.nrctadst%TYPE  --n(10)
                            ,pr_cdhistor IN crapafi.cdhistor%TYPE ) IS --n(4)
            SELECT crapafi.ROWID
            FROM   crapafi
            WHERE  crapafi.cdcooper = pr_cdcooper
            AND    crapafi.nrdctabb = pr_nrdctabb
            AND    crapafi.dtmvtolt = pr_dtmvtolt
            AND    crapafi.cdcopdst = pr_cdcopdst
            AND    crapafi.cdagedst = pr_cdagedst
            AND    crapafi.nrctadst = pr_nrctadst
            AND    crapafi.cdhistor = pr_cdhistor;
          rw_crapafi cr_crapafi%ROWTYPE;

          rw_crapcop_efet cr_crapcop%ROWTYPE;
          vr_tab_titulos  PAGA0001.typ_tab_titulos;
          vr_tab_erro_bo  gene0001.typ_tab_erro;
          vr_tab_regimp1  typ_tab_regimp;
          vr_tab_regimp2  typ_tab_regimp;
          vr_flgcebok     BOOLEAN;
          vr_flagtco      BOOLEAN;
          vr_inpessoa     INTEGER;
          vr_indcratarq   VARCHAR2(100);
          vr_indregimp    VARCHAR2(100);
          vr_indtitulos   VARCHAR2(100);
          vr_inddescontar     VARCHAR2(100);
          vr_inddescontar_aux VARCHAR2(100);
          vr_rowid_craplot    ROWID;
          vr_rowid_crapcob    ROWID;
          vr_nrdconta_quebra  INTEGER;
          vr_cdpesqbb         VARCHAR2(100);
          vr_crapcobfound     BOOLEAN;
          vr_craptco_efet     BOOLEAN;
          -- controle de NEXT do progress
          vr_proximo_arquivo  EXCEPTION;
          vr_proximo_registro EXCEPTION;

          -------------------------------------------------------------------
          -- procedimento para filtrar os registros da tabela temporária ref.
          -- ao parâmetro pr_tab_regimp e retornar os registros que devem ser
          -- processados nos parâmetros pr_tab_regimp1 e pr_tab_regimp2
          -------------------------------------------------------------------
          PROCEDURE pc_filtra_regimp(pr_nmarquiv IN VARCHAR2
                                    ,pr_tab_regimp IN typ_tab_regimp
                                    ,pr_tab_regimp1 OUT typ_tab_regimp
                                    ,pr_tab_regimp2 OUT typ_tab_regimp
                                     ) IS
          BEGIN
            DECLARE
              vr_indice VARCHAR2(100);
            BEGIN
              -- posiciona no primeiro registro
              vr_indice := pr_tab_regimp.FIRST;
              -- navega em todos os registros da tabela temporaria
              WHILE vr_indice IS NOT NULL LOOP
                -- Alimentando a primeira temp-table (pr_tab_regimp1)
                IF pr_tab_regimp(vr_indice).nmarquiv = pr_nmarquiv AND
                   pr_tab_regimp(vr_indice).nrctares > vr_glbnrctares /* lote+seq. */  AND
                   pr_tab_regimp(vr_indice).nrdconta = 0        AND
                   pr_tab_regimp(vr_indice).flpagchq = FALSE THEN

                  -- Alimentando a primeira temp-table (pr_tab_regimp1)
                  pr_tab_regimp1(vr_indice).cdcooper := pr_tab_regimp(vr_indice).cdcooper;
                  pr_tab_regimp1(vr_indice).codbanco := pr_tab_regimp(vr_indice).codbanco;
                  pr_tab_regimp1(vr_indice).nroconve := pr_tab_regimp(vr_indice).nroconve;
                  pr_tab_regimp1(vr_indice).cdagenci := pr_tab_regimp(vr_indice).cdagenci;
                  pr_tab_regimp1(vr_indice).nrdctabb := pr_tab_regimp(vr_indice).nrdctabb;
                  pr_tab_regimp1(vr_indice).nrdocmto := pr_tab_regimp(vr_indice).nrdocmto;
                  pr_tab_regimp1(vr_indice).vllanmto := pr_tab_regimp(vr_indice).vllanmto;
                  pr_tab_regimp1(vr_indice).vlrtarif := pr_tab_regimp(vr_indice).vlrtarif;
                  pr_tab_regimp1(vr_indice).dtpagto  := pr_tab_regimp(vr_indice).dtpagto ;
                  pr_tab_regimp1(vr_indice).nrctares := pr_tab_regimp(vr_indice).nrctares;
                  pr_tab_regimp1(vr_indice).nrseqdig := pr_tab_regimp(vr_indice).nrseqdig;
                  pr_tab_regimp1(vr_indice).nrdolote := pr_tab_regimp(vr_indice).nrdolote;
                  pr_tab_regimp1(vr_indice).nrdconta := pr_tab_regimp(vr_indice).nrdconta;
                  pr_tab_regimp1(vr_indice).codmoeda := pr_tab_regimp(vr_indice).codmoeda;
                  pr_tab_regimp1(vr_indice).identifi := pr_tab_regimp(vr_indice).identifi;
                  pr_tab_regimp1(vr_indice).codcarte := pr_tab_regimp(vr_indice).codcarte;
                  pr_tab_regimp1(vr_indice).juros    := pr_tab_regimp(vr_indice).juros   ;
                  pr_tab_regimp1(vr_indice).vlabatim := pr_tab_regimp(vr_indice).vlabatim;
                  pr_tab_regimp1(vr_indice).incnvaut := pr_tab_regimp(vr_indice).incnvaut;
                  pr_tab_regimp1(vr_indice).dsorgarq := pr_tab_regimp(vr_indice).dsorgarq;
                  pr_tab_regimp1(vr_indice).nrcnvceb := pr_tab_regimp(vr_indice).nrcnvceb;
                  pr_tab_regimp1(vr_indice).cdpesqbb := pr_tab_regimp(vr_indice).cdpesqbb;
                  pr_tab_regimp1(vr_indice).cdbanpag := pr_tab_regimp(vr_indice).cdbanpag;
                  pr_tab_regimp1(vr_indice).cdagepag := pr_tab_regimp(vr_indice).cdagepag;
                  pr_tab_regimp1(vr_indice).nmarquiv := pr_tab_regimp(vr_indice).nmarquiv;
                  pr_tab_regimp1(vr_indice).inarqcbr := pr_tab_regimp(vr_indice).inarqcbr;
                  pr_tab_regimp1(vr_indice).dtdgerac := pr_tab_regimp(vr_indice).dtdgerac;
                  pr_tab_regimp1(vr_indice).flpagchq := pr_tab_regimp(vr_indice).flpagchq;
                  pr_tab_regimp1(vr_indice).dcmc7chq := pr_tab_regimp(vr_indice).dcmc7chq;
                  pr_tab_regimp1(vr_indice).dscheque := pr_tab_regimp(vr_indice).dscheque;
                  pr_tab_regimp1(vr_indice).cdocorre := pr_tab_regimp(vr_indice).cdocorre;
                  pr_tab_regimp1(vr_indice).vldpagto := pr_tab_regimp(vr_indice).vldpagto;
                  pr_tab_regimp1(vr_indice).vltarbco := pr_tab_regimp(vr_indice).vltarbco;
                  pr_tab_regimp1(vr_indice).cdhistor := pr_tab_regimp(vr_indice).cdhistor;
                  pr_tab_regimp1(vr_indice).cdfvlcop := pr_tab_regimp(vr_indice).cdfvlcop;
                  pr_tab_regimp1(vr_indice).incoptco := pr_tab_regimp(vr_indice).incoptco;
                  pr_tab_regimp1(vr_indice).nrctaant := pr_tab_regimp(vr_indice).nrctaant;
                  pr_tab_regimp1(vr_indice).cdcopant := pr_tab_regimp(vr_indice).cdcopant;

                -- Alimentando a segunda temp-table (pr_tab_regimp2)
                ELSIF pr_tab_regimp(vr_indice).nmarquiv = pr_nmarquiv AND
                   pr_tab_regimp(vr_indice).nrctares > vr_glbnrctares /* lote+seq. */  AND
                   pr_tab_regimp(vr_indice).nrdconta <> 0                            AND
                   pr_tab_regimp(vr_indice).cdocorre = 6 THEN

                  -- Alimentando a segunda temp-table (pr_tab_regimp2)
                  pr_tab_regimp2(vr_indice).cdcooper := pr_tab_regimp(vr_indice).cdcooper;
                  pr_tab_regimp2(vr_indice).codbanco := pr_tab_regimp(vr_indice).codbanco;
                  pr_tab_regimp2(vr_indice).nroconve := pr_tab_regimp(vr_indice).nroconve;
                  pr_tab_regimp2(vr_indice).cdagenci := pr_tab_regimp(vr_indice).cdagenci;
                  pr_tab_regimp2(vr_indice).nrdctabb := pr_tab_regimp(vr_indice).nrdctabb;
                  pr_tab_regimp2(vr_indice).nrdocmto := pr_tab_regimp(vr_indice).nrdocmto;
                  pr_tab_regimp2(vr_indice).vllanmto := pr_tab_regimp(vr_indice).vllanmto;
                  pr_tab_regimp2(vr_indice).vlrtarif := pr_tab_regimp(vr_indice).vlrtarif;
                  pr_tab_regimp2(vr_indice).dtpagto  := pr_tab_regimp(vr_indice).dtpagto ;
                  pr_tab_regimp2(vr_indice).nrctares := pr_tab_regimp(vr_indice).nrctares;
                  pr_tab_regimp2(vr_indice).nrseqdig := pr_tab_regimp(vr_indice).nrseqdig;
                  pr_tab_regimp2(vr_indice).nrdolote := pr_tab_regimp(vr_indice).nrdolote;
                  pr_tab_regimp2(vr_indice).nrdconta := pr_tab_regimp(vr_indice).nrdconta;
                  pr_tab_regimp2(vr_indice).codmoeda := pr_tab_regimp(vr_indice).codmoeda;
                  pr_tab_regimp2(vr_indice).identifi := pr_tab_regimp(vr_indice).identifi;
                  pr_tab_regimp2(vr_indice).codcarte := pr_tab_regimp(vr_indice).codcarte;
                  pr_tab_regimp2(vr_indice).juros    := pr_tab_regimp(vr_indice).juros   ;
                  pr_tab_regimp2(vr_indice).vlabatim := pr_tab_regimp(vr_indice).vlabatim;
                  pr_tab_regimp2(vr_indice).incnvaut := pr_tab_regimp(vr_indice).incnvaut;
                  pr_tab_regimp2(vr_indice).dsorgarq := pr_tab_regimp(vr_indice).dsorgarq;
                  pr_tab_regimp2(vr_indice).nrcnvceb := pr_tab_regimp(vr_indice).nrcnvceb;
                  pr_tab_regimp2(vr_indice).cdpesqbb := pr_tab_regimp(vr_indice).cdpesqbb;
                  pr_tab_regimp2(vr_indice).cdbanpag := pr_tab_regimp(vr_indice).cdbanpag;
                  pr_tab_regimp2(vr_indice).cdagepag := pr_tab_regimp(vr_indice).cdagepag;
                  pr_tab_regimp2(vr_indice).nmarquiv := pr_tab_regimp(vr_indice).nmarquiv;
                  pr_tab_regimp2(vr_indice).inarqcbr := pr_tab_regimp(vr_indice).inarqcbr;
                  pr_tab_regimp2(vr_indice).dtdgerac := pr_tab_regimp(vr_indice).dtdgerac;
                  pr_tab_regimp2(vr_indice).flpagchq := pr_tab_regimp(vr_indice).flpagchq;
                  pr_tab_regimp2(vr_indice).dcmc7chq := pr_tab_regimp(vr_indice).dcmc7chq;
                  pr_tab_regimp2(vr_indice).dscheque := pr_tab_regimp(vr_indice).dscheque;
                  pr_tab_regimp2(vr_indice).cdocorre := pr_tab_regimp(vr_indice).cdocorre;
                  pr_tab_regimp2(vr_indice).vldpagto := pr_tab_regimp(vr_indice).vldpagto;
                  pr_tab_regimp2(vr_indice).vltarbco := pr_tab_regimp(vr_indice).vltarbco;
                  pr_tab_regimp2(vr_indice).cdhistor := pr_tab_regimp(vr_indice).cdhistor;
                  pr_tab_regimp2(vr_indice).cdfvlcop := pr_tab_regimp(vr_indice).cdfvlcop;
                  pr_tab_regimp2(vr_indice).incoptco := pr_tab_regimp(vr_indice).incoptco;
                  pr_tab_regimp2(vr_indice).nrctaant := pr_tab_regimp(vr_indice).nrctaant;
                  pr_tab_regimp2(vr_indice).cdcopant := pr_tab_regimp(vr_indice).cdcopant;

                END IF;
                -- indo para o proximo registro da tabela
                vr_indice := pr_tab_regimp.NEXT(vr_indice);
              END LOOP;
            END;
          END pc_filtra_regimp;

          /*************************************************************************
              Objetivo: Alterar a indexação da temp-table criando o first-of/last-of
          *************************************************************************/
          PROCEDURE pc_ajusta_ordem_regimp( pr_tab_regimp IN OUT typ_tab_regimp -- temp-table com os registros
          ) IS
          BEGIN
            DECLARE
              vr_indatual   VARCHAR2(100);
              vr_indaux     VARCHAR2(100);
              vr_controle   VARCHAR2(100);
            BEGIN
              vr_indatual := pr_tab_regimp.first;
              vr_controle := '#';
              WHILE vr_indatual IS NOT NULL LOOP
                -- se o controle é igual e o first_of é nulo
                IF vr_controle <>
                   rpad(pr_tab_regimp(vr_indatual).nmarquiv,70,'#')||lpad(pr_tab_regimp(vr_indatual).nrdconta,10,'0')||lpad(pr_tab_regimp(vr_indatual).nroconve,8,'0')
                THEN
                  pr_tab_regimp(vr_indatual).first_of := TRUE;
                ELSE
                  pr_tab_regimp(vr_indatual).first_of := FALSE;
                END IF;
                -- Armazena o valor do registro anterior
                vr_controle :=  rpad(pr_tab_regimp(vr_indatual).nmarquiv,70,'#')||lpad(pr_tab_regimp(vr_indatual).nrdconta,10,'0')||lpad(pr_tab_regimp(vr_indatual).nroconve,8,'0');
                -- Armazena o indice do registro atual
                vr_indaux := vr_indatual;
                -- vai para o proximo registro
                vr_indatual := pr_tab_regimp.NEXT(vr_indatual);
                -- verifica se é last-of
                IF vr_indatual IS NOT NULL THEN
                  IF vr_controle <>
                    rpad(pr_tab_regimp(vr_indatual).nmarquiv,70,'#')||lpad(pr_tab_regimp(vr_indatual).nrdconta,10,'0')||lpad(pr_tab_regimp(vr_indatual).nroconve,8,'0')
                  THEN
                    -- marca o registro anterior como last-of
                    pr_tab_regimp(vr_indaux).last_of := TRUE;
                  ELSE
                    pr_tab_regimp(vr_indaux).last_of := FALSE;
                  END IF;
                ELSE
                  pr_tab_regimp(vr_indaux).last_of := TRUE;
                END IF;
              END LOOP;
            END;
          END pc_ajusta_ordem_regimp;


        BEGIN

          -- limpando os dados da tabela temporaria
          -- tabela global declarada no programa principal
          vr_tab_migracaocob.delete;

          --limpa a tabela temporaria de historicos
          vr_tab_craphis.delete;
          -- carrega a tabela temporaria de historicos
          FOR rw_craphis IN cr_craphis(pr_cdcooper => pr_cdcooper) LOOP
            vr_tab_craphis(rw_craphis.cdhistor).cdhistor := rw_craphis.cdhistor;
            vr_tab_craphis(rw_craphis.cdhistor).dshistor := rw_craphis.dshistor;
            vr_tab_craphis(rw_craphis.cdhistor).indebcre := rw_craphis.indebcre;
          END LOOP;

          /*LOOP PRINCIPAL*/
          -- posicionando no primeiro registro da temp-table
          vr_indcratarq := pr_tab_cratarq.first;
          -- Iniciando o loop e processamento do arquivo
          WHILE vr_indcratarq IS NOT NULL LOOP
            BEGIN

              -- inicializando as variaveis
              vr_qtdmigra := 0;
              vr_vlrmigra := 0;

              -- Se historico nao existir exclui o arquivo e gera erro
              IF NOT vr_tab_craphis.EXISTS(pr_tab_cratarq(vr_indcratarq).cdhistor) THEN

                -- Gerando o nome do arquivo de erro
                vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_indcratarq).nmarquiv,8,53);

                -- Comando para copiar o arquivo para a pasta salvar
                vr_ind_comando := vr_ind_comando + 1;
                vr_tab_comando.extend;
                vr_tab_comando(vr_ind_comando) := 'cp '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_indcratarq).nmarquiv||' '||vr_caminho_salvar;

                -- Comando para mover o arquivo
                vr_ind_comando := vr_ind_comando + 1;
                vr_tab_comando.extend;
                vr_tab_comando(vr_ind_comando) := 'mv '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_indcratarq).nmarquiv||' '||
                                    vr_caminho_integra||'/'||vr_nmarquiv||' 2> /dev/null';

                -- alimenta a critica para carregar na tabela de erros
                pr_dscritic := 'Historico ' ||pr_tab_cratarq(vr_indcratarq).cdhistor ||
                               ' nao cadastrado para arquivo '||pr_tab_cratarq(vr_indcratarq).nmarquiv;

                -- Incrementando o sequencial de arquivos
                -- variavel global utilizada em todo o processo
                vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                /* Retorno de erro da BO */
                gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                      ,pr_cdagenci => pr_cdagenci
                                      ,pr_nrdcaixa => pr_nrdcaixa
                                      ,pr_nrsequen => vr_nrsequen
                                      ,pr_cdcritic => pr_cdcritic
                                      ,pr_dscritic => pr_dscritic
                                      ,pr_tab_erro => pr_tab_erro);

                -- reinicializando a variavel de controle de critica
                pr_dscritic := ' ';

                -- Processa o proximo registro da temp-table
                RAISE vr_proximo_arquivo;

              END IF;

              -- se tem valor de tarifa
              IF  nvl(pr_tab_cratarq(vr_indcratarq).vltarifa,0) > 0  THEN

                -- Se nao historico nao existir exclui o arquivo e gera erro
                IF NOT vr_tab_craphis.EXISTS(pr_tab_cratarq(vr_indcratarq).cdtarhis) THEN

                  -- Gerando o nome do arquivo de erro
                  vr_nmarquiv := 'err'||substr(pr_tab_cratarq(vr_indcratarq).nmarquiv,8,53);

                  -- Comando para copiar o arquivo para a pasta salvar
                  vr_ind_comando := vr_ind_comando + 1;
                  vr_tab_comando.extend;
                  vr_tab_comando(vr_ind_comando) := 'cp '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_indcratarq).nmarquiv||' '||vr_caminho_salvar||' 2> /dev/null';

                  -- Comando para mover o arquivo
                  vr_ind_comando := vr_ind_comando + 1;
                  vr_tab_comando.extend;
                  vr_tab_comando(vr_ind_comando) := 'mv '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_indcratarq).nmarquiv||' '||
                                      vr_caminho_integra||'/'||vr_nmarquiv||' 2> /dev/null';

                  -- descricao da critica para alimentar a tabela de erro
                  pr_dscritic := 'Historico ' ||pr_tab_cratarq(vr_indcratarq).cdhistor ||
                                 ' nao cadastrado para arquivo '||pr_tab_cratarq(vr_indcratarq).nmarquiv;

                  -- Incrementando o sequencial de arquivos
                  vr_nrsequen := nvl(vr_nrsequen,0) + 1;

                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => pr_dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                  -- limpando a variavel de controle de criticas
                  pr_dscritic := ' ';

                  -- Processa o proximo registro da temp-table
                  RAISE vr_proximo_arquivo;
                END IF; --IF cr_craphis%NOTFOUND THEN
              END IF;--IF  nvl(pr_tab_cratarq(vr_indcratarq).vltarifa,0) > 0  THEN

              -- inicializando as variaveis
              vr_nrdoctax := 1000000;
              vr_qtregicd := 0;
              vr_qtregisd := 0;
              vr_qtregrej := 0;
              vr_vlcompcr := 0;
              vr_vlregicd := 0;
              vr_vlregisd := 0;
              vr_vlcompdb := 0;
              vr_vlregrej := 0;
              vr_totvllanmto := 0;
              vr_totvllanmt2 := 0;
              vr_totqtdbolet := 0;
              vr_totqtdbole2 := 0;

              -- Retorna a tabela temporária pr_tab_regimp somente com os registros
              -- que devem ser processados em cada LOOP:
              -- vr_tab_regimp1 => primeiro loop
              -- vr_tab_regimp2 => segundo loop
              pc_filtra_regimp( pr_nmarquiv    => pr_tab_cratarq(vr_indcratarq).nmarquiv
                               ,pr_tab_regimp  => pr_tab_regimp
                               ,pr_tab_regimp1 => vr_tab_regimp1
                               ,pr_tab_regimp2 => vr_tab_regimp2);

              /*PRIMEIRO LOOP*/
              vr_indregimp := vr_tab_regimp1.first;
              -- verifica todos os registros que serao processados
              WHILE vr_indregimp IS NOT NULL LOOP
                BEGIN
                  -- alimentando as variaveis
                  vr_cdpesqbb := lpad(vr_tab_regimp1(vr_indregimp).nroconve,8,'0');
                  -- armazenando o valor do lancamento
                  vr_vllanmto := nvl(vr_tab_regimp1(vr_indregimp).vllanmto,0)
                                 + nvl(vr_tab_regimp1(vr_indregimp).juros,0)
                                 - nvl(vr_tab_regimp1(vr_indregimp).vlabatim,0);
                  -- armazenando o numero do documento
                  vr_nrdocmto := vr_tab_regimp1(vr_indregimp).nrdocmto;
                  -- armazenando o valor compensado a credito
                  vr_vlcompcr := nvl(vr_vlcompcr,0) + nvl(vr_vllanmto,0);

                  -- se eh da cooperativa 16 e migracao, acumula os valores e vai para o proximo
                  --IF pr_cdcooper = 16 AND vr_tab_regimp1(vr_indregimp).dsorgarq = 'MIGRACAO' THEN
                  IF vr_tab_regimp1(vr_indregimp).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                    -- Acumulando a quantidade de rejeitados
                    vr_qtregrej := nvl(vr_qtregrej,0) + 1;
                    -- acumulando o total de rejeitados
                    vr_vlregrej := nvl(vr_vlregrej,0) + nvl(vr_vllanmto,0);
                    -- vai para o proximo registro
                    RAISE vr_proximo_registro;
                  END IF;

                  -- carrega a tabela pr_tab_cratrej com os titulos rejeitados
                  pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                     ,pr_cdcritic => 592
                                     ,pr_nrdconta => vr_tab_regimp1(vr_indregimp).nrdconta
                                     ,pr_nrdctitg => ' '
                                     ,pr_nrdctabb => 0
                                     ,pr_dshistor => ' '
                                     ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                     ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                     -- parametros da pr_tab_regimp
                                     ,pr_nmarquiv => vr_tab_regimp1(vr_indregimp).nmarquiv
                                     ,pr_nrseqdig => vr_tab_regimp1(vr_indregimp).nrseqdig
                                     ,pr_codbanco => vr_tab_regimp1(vr_indregimp).codbanco
                                     ,pr_cdagenci => vr_tab_regimp1(vr_indregimp).cdagenci
                                     ,pr_nrdolote => vr_tab_regimp1(vr_indregimp).nrdolote
                                     ,pr_cdpesqbb => vr_tab_regimp1(vr_indregimp).cdpesqbb
                                     ,pr_tab_cratrej => pr_tab_cratrej
                                     ,pr_qtregrej    => vr_qtregrej
                                     ,pr_vlregrej    => vr_vlregrej
                                     ,pr_dscritic    => pr_dscritic);
                  -- Tratando a critica
                  IF trim(pr_dscritic) IS NOT NULL THEN
                    -- retorna o processamento para o programa chamador
                    RETURN;
                  END IF;

                EXCEPTION
                  WHEN vr_proximo_registro THEN
                    NULL;
                END;
                -- vai para o proximo registro
                vr_indregimp := vr_tab_regimp1.next(vr_indregimp);
              END LOOP; -- /*PRIMEIRO LOOP*/

              /* AJUSTANDO FIRST-OF e LAST-OF da temp-table*/
              pc_ajusta_ordem_regimp( pr_tab_regimp => vr_tab_regimp2);

              /*SEGUNDO LOOP*/
              -- posiciona no primeiro registro
              vr_indregimp := vr_tab_regimp2.first;

              -- verifica todos os registros que serao processados
              WHILE vr_indregimp IS NOT NULL LOOP
                BEGIN
                  -- alimentando as variaveis
                  pr_cdcritic := 0;

                  vr_craptco_efet := FALSE; -- Daniel 06/05/2014

                  vr_cdpesqbb := lpad(vr_tab_regimp2(vr_indregimp).nroconve,8,'0');
                  vr_vllanmto := nvl(vr_tab_regimp2(vr_indregimp).vllanmto,0)
                                 + nvl(vr_tab_regimp2(vr_indregimp).juros,0)
                                 - nvl(vr_tab_regimp2(vr_indregimp).vlabatim,0);
                  -- armazenando o numero do documento
                  vr_nrdocmto := vr_tab_regimp2(vr_indregimp).nrdocmto;
                  vr_vlcompcr := nvl(vr_vlcompcr,0) + nvl(vr_vllanmto,0);
                  vr_flagtco  := FALSE;

                  -- Se é título ref. a conta que foi migrada
                  IF  NOT vr_tab_regimp2(vr_indregimp).incoptco OR
                      vr_tab_regimp2(vr_indregimp).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

                    IF  NOT vr_tab_regimp2(vr_indregimp).incoptco THEN

                      OPEN cr_crapcco_efet( pr_cdcooper => pr_cdcooper
                                           ,pr_nrconven => vr_tab_regimp2(vr_indregimp).nroconve);
                      FETCH cr_crapcco_efet INTO rw_crapcco_efet;

                      IF  cr_crapcco_efet%FOUND THEN
                        --fechando o cursor
                        CLOSE cr_crapcco_efet;
                        -- abre o cursor passando a cooperativa selecionada na crapcco
                        OPEN cr_craptco_efet( pr_cdcooper => rw_crapcco_efet.cdcooper
                                             ,pr_cdcopant => pr_cdcooper
                                             ,pr_nrctaant => vr_tab_regimp2(vr_indregimp).nrdconta);
                        FETCH cr_craptco_efet INTO rw_craptco_efet;
                        -- controle para saber se retornou informacoes da craptco
                        vr_craptco_efet := cr_craptco_efet%FOUND;
                        -- fechando o cursor
                        CLOSE cr_craptco_efet;
                      ELSE
                        -- fechando o cursor
                        CLOSE cr_crapcco_efet;
                      END IF;

                    ELSE
                      -- Verifica se a conta foi transferida entre cooperativas
                      OPEN cr_craptco_efet2( pr_cdcooper => pr_cdcooper
                                           ,pr_cdcopant => vr_tab_regimp2(vr_indregimp).cdcopant
                                           ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta);
                      FETCH cr_craptco_efet2 INTO rw_craptco_efet;
                      -- controle para saber se retornou informacoes da craptco
                      vr_craptco_efet := cr_craptco_efet2%FOUND;
                      -- fechando o cursor
                      CLOSE cr_craptco_efet2;
                    END IF;--IF  NOT vr_tab_regimp2(vr_indregimp).incoptco THEN

                    -- Se a conta foi transferida
                    IF vr_craptco_efet THEN

                      -- se a conta foi transferida e nao foi migrada,
                      -- lanca como rejeitado no código 951 - Conta migrada.
                      IF vr_tab_regimp2(vr_indregimp).dsorgarq NOT IN ('MIGRACAO','INCORPORACAO') THEN

                        -- insere na tabela de rejeitados
                        pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                           ,pr_cdcritic => 951
                                           ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                           ,pr_nrdctitg => ' '
                                           ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                           ,pr_dshistor => rw_craphis.dshistor
                                           ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                           ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                           -- parametros da vr_tab_regimp2
                                           ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                           ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                           ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                           ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                           ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                           ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                           ,pr_tab_cratrej => pr_tab_cratrej
                                           ,pr_qtregrej    => vr_qtregrej
                                           ,pr_vlregrej    => vr_vlregrej
                                           ,pr_dscritic    => pr_dscritic);
                        -- Tratando a critica
                        IF trim(pr_dscritic) IS NOT NULL THEN
                          -- retorna o processamento para o programa chamador
                          RETURN;
                        END IF;
                      END IF;--IF  pr_cdcooper = 1 THEN

                      /*Não deve gerar temptable para incorporação, para assim não gerar os lançamentos
                        na crapafi, pois não precisa ser gerado ajuste, uma vez que a cooperativa antiga não existe mais*/
                      IF vr_tab_regimp2(vr_indregimp).dsorgarq NOT IN ('INCORPORACAO') THEN
                        -- criando o indice da temp-table
                        vr_indmigracob := lpad(rw_craptco_efet.nrdconta,10,'0')||lpad(vr_tab_regimp2(vr_indregimp).nroconve,10,'0');
                        -- Verifica se existe o registro de conta e convenio na tabela temporaria
                        IF vr_tab_migracaocob.exists(vr_indmigracob) THEN
                          -- Atualiza o registro
                          vr_tab_migracaocob(vr_indmigracob).vllanmto := nvl(vr_tab_migracaocob(vr_indmigracob).vllanmto,0) +
                                                                          nvl(vr_vllanmto,0);
                          vr_tab_migracaocob(vr_indmigracob).vlrtarif := nvl(vr_tab_migracaocob(vr_indmigracob).vlrtarif,0) +
                                                                          nvl(vr_tab_regimp2(vr_indregimp).vltarbco,0);
                          vr_tab_migracaocob(vr_indmigracob).qttitmig := nvl(vr_tab_migracaocob(vr_indmigracob).qttitmig,0) + 1;
                        ELSE

                          -- se não é convenio proveniente de migracao ele busca da cooperativa
                          -- normal, senão ele buscada cooperativa anterior
                          IF  NOT vr_tab_regimp2(vr_indregimp).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                            -- busca informações da cooperativa
                            OPEN cr_crapcop(pr_cdcooper => rw_craptco_efet.cdcooper);
                            FETCH cr_crapcop INTO rw_crapcop_efet;
                            CLOSE cr_crapcop;
                          ELSE
                            -- busca informações da cooperativa
                            OPEN cr_crapcop(pr_cdcooper => rw_craptco_efet.cdcopant);
                            FETCH cr_crapcop INTO rw_crapcop_efet;
                            CLOSE cr_crapcop;
                          END IF;

                          -- cria um novo registro
                          vr_tab_migracaocob(vr_indmigracob).nrdctabb := vr_tab_regimp2(vr_indregimp).nrdctabb;
                          vr_tab_migracaocob(vr_indmigracob).cdcopdst := rw_crapcop_efet.cdcooper;
                          vr_tab_migracaocob(vr_indmigracob).nrctadst := rw_craptco_efet.nrdconta;
                          vr_tab_migracaocob(vr_indmigracob).cdagedst := rw_craptco_efet.cdagenci;
                          vr_tab_migracaocob(vr_indmigracob).cdhistor := rw_craphis.cdhistor;
                          vr_tab_migracaocob(vr_indmigracob).vllanmto := nvl(vr_vllanmto,0);
                          vr_tab_migracaocob(vr_indmigracob).vlrtarif := vr_tab_regimp2(vr_indregimp).vltarbco;
                          vr_tab_migracaocob(vr_indmigracob).dsorgarq := vr_tab_regimp2(vr_indregimp).dsorgarq;
                          vr_tab_migracaocob(vr_indmigracob).nroconve := vr_tab_regimp2(vr_indregimp).nroconve;
                          vr_tab_migracaocob(vr_indmigracob).nmrescop := rw_crapcop_efet.nmrescop;
                          vr_tab_migracaocob(vr_indmigracob).qttitmig := 1;
                          vr_tab_migracaocob(vr_indmigracob).nmarquiv := pr_tab_cratarq(vr_indcratarq).nmarquiv;

                        END IF;--IF vr_tab_migracaocob.exists(vr_indmigracob) THEN
                      END IF; -- Fim IF NOT IN ('INCORPORACAO')

                      -- Alimentando os totalizadores
                      vr_flagtco  := TRUE;
                      vr_qtdmigra := nvl(vr_qtdmigra,0) + 1;
                      vr_vlrmigra := nvl(vr_vlrmigra,0) + nvl(vr_vllanmto,0);
                      --END IF;--IF pr_cdcooper = 1 OR vr_tab_regimp2(vr_indregimp).dsorgarq = 'MIGRACAO' THEN
                    END IF;--IF cr_craptco%FOUND THEN
                  END IF;--IF  NOT vr_tab_regimp2(vr_indregimp).incoptco

                  -- se é conta proveniente de migracao
                  IF vr_tab_regimp2(vr_indregimp).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

                    -- Abre o cursor das cobrancas
                    OPEN cr_crapcob ( pr_cdcooper => pr_cdcooper
                                     ,pr_cdbandoc => vr_tab_regimp2(vr_indregimp).codbanco
                                     ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                     ,pr_nrcnvcob => vr_tab_regimp2(vr_indregimp).nroconve
                                     ,pr_nrdocmto => vr_tab_regimp2(vr_indregimp).nrdocmto
                                     ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta);
                    FETCH cr_crapcob INTO rw_crapcob;
                    -- atribuindo o rowid
                    vr_rowid_crapcob := rw_crapcob.rowid;

                    --verifica se tem informacao na crapcob
                    IF cr_crapcob%NOTFOUND THEN
                      CLOSE cr_crapcob;
                      -- Verifica o cadastro de emissao de bloquetos para saber se existe convÃªnio configurado
                      OPEN cr_crapceb( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                      ,pr_nrconven => vr_tab_regimp2(vr_indregimp).nroconve);
                      FETCH cr_crapceb INTO rw_crapceb;

                      -- verifica se existe informacao
                      IF cr_crapceb%NOTFOUND THEN
                        -- fechando o cursor
                        CLOSE cr_crapceb;
                        -- avanca para o proximo registro
                        RAISE vr_proximo_registro;
                      ELSE
                        -- fechando o cursor
                        CLOSE cr_crapceb;
                      END IF;--IF cr_crapceb%NOTFOUND THEN
                    ELSE
                      --fechando o cursor
                      CLOSE cr_crapcob;
                    END IF;--IF cr_crapcob%NOTFOUND THEN
                  END IF;--IF vr_tab_regimp2(vr_indregimp).dsorgarq = 'MIGRACAO' THEN

                  -- se a conta foi transferida ou migrada
                  IF NOT vr_flagtco OR vr_tab_regimp2(vr_indregimp).dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN

                    -- se é o first-of da quebra...
                    IF nvl(vr_tab_regimp2(vr_indregimp).first_of,FALSE) THEN

                      -- Busca informacoes do convenio para verificar
                      -- se utiliza crédito unificado na cobranca
                      OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                      ,pr_nrconven => vr_tab_regimp2(vr_indregimp).nroconve);
                      FETCH cr_crapceb INTO rw_crapceb;

                      -- se encontrou informacoes
                      IF cr_crapceb%FOUND THEN
                        -- marca se utiliza crédito unificado de cobranca
                        vr_flgcruni := (rw_crapceb.flgcruni = 1);
                      ELSE
                        vr_flgcruni := FALSE;
                      END IF;
                      -- se utiliza credito unificado de cobranca, zera o número do documento
                      IF vr_flgcruni THEN
                        vr_nrdocmto := 0;
                      END IF;
                      --fecha o cursor
                      CLOSE cr_crapceb;
                    END IF;

                    -- se não utiliza credito unificado de cobranca, trabalha com o número do documento
                    -- que veio no arquivo
                    IF NOT vr_flgcruni THEN
                      vr_nrdocmto := vr_tab_regimp2(vr_indregimp).nrdocmto;
                      vr_nrdoctax := 1000000;
                    END IF;

                    /** Se boleto foi pago com cheque, nao efetuar o credito **/
                    IF vr_tab_regimp2(vr_indregimp).flpagchq  AND vr_tab_regimp2(vr_indregimp).cdocorre <> 06 THEN

                      -- se eh o último registro da conta/convenio
                      IF vr_tab_regimp2(vr_indregimp).last_of THEN

                        IF Nvl(vr_totvllanmt2,0) > 0 THEN
                          -- Efetua o lançamento
                          pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => vr_nrdconta
                                              ,pr_vllanmto => vr_totvllanmt2
                                              ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                              ,pr_nrdocmto => vr_nrdocmto
                                              ,pr_qtdbolet => vr_totqtdbole2
                                              ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                              ,pr_rowid_craplot => vr_rowid_craplot
                                              ,pr_dscritic => pr_dscritic);
                          -- se retornar erro, volta para o programa chamador
                          IF trim(pr_dscritic) IS NOT NULL THEN
                            -- Volta para o programa chamador
                            RETURN;
                          END IF;
                        END IF;

                        --
                        IF vr_totvllanmto > 0 THEN
                          -- efetua o lançamento da tarifa
                          pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                ,pr_vltarifa => vr_totvllanmto
                                                ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                ,pr_cdpesqbb => vr_cdpesqbb
                                                ,pr_cdcritic => pr_cdcritic
                                                ,pr_dscritic => pr_dscritic
                                                ,pr_tab_erro => pr_tab_erro);
                          -- verifica se ocorreu algum erro
                          IF trim(pr_dscritic) IS NOT NULL THEN
                            -- retorna para o programa chamador
                            RETURN;
                          END IF;
                        END IF;

                        -- reinicializando os totalizadores por conta/convênio
                        vr_totvllanmto := 0;
                        vr_totvllanmt2 := 0;
                        vr_totqtdbolet := 0;
                        vr_totqtdbole2 := 0;
                      END IF; --IF vr_tab_regimp2(vr_indregimp).last_of THEN

                      -- vai para o proximo registro da temp-table
                      RAISE vr_proximo_registro;
                    END IF; --IF vr_tab_regimp2(vr_indregimp).flpagchq  AND vr_tab_regimp2(vr_indregimp).cdocorre <> 06 THEN

                    -- Inicializando o rowtype para a proxima iteracao, pois se a consulta
                    -- nao retornar registros, o fetch não limpa o rowtype
                    rw_crapcob := NULL;

                    /* Acessar Bloquetos Cadastrados - Pegar nro conta associado */
                    IF vr_tab_regimp2(vr_indregimp).incnvaut THEN
                      -- Abrindo o cadastro de boquetos pelo número da conta
                      OPEN cr_crapcob( pr_cdcooper => pr_cdcooper
                                      ,pr_cdbandoc => vr_tab_regimp2(vr_indregimp).codbanco
                                      ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                      ,pr_nrcnvcob => vr_tab_regimp2(vr_indregimp).nroconve
                                      ,pr_nrdocmto => vr_tab_regimp2(vr_indregimp).nrdocmto
                                      ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta);
                    ELSE
                      -- Abrindo o cadastro de bloquetos sem passar o numero da conta
                      OPEN cr_crapcob( pr_cdcooper => pr_cdcooper
                                      ,pr_cdbandoc => vr_tab_regimp2(vr_indregimp).codbanco
                                      ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                      ,pr_nrcnvcob => vr_tab_regimp2(vr_indregimp).nroconve
                                      ,pr_nrdocmto => vr_tab_regimp2(vr_indregimp).nrdocmto);
                    END IF;--IF vr_tab_regimp2(vr_indregimp).incnvaut THEN
                    -- lendo as informacoes retornadas pelo cursor
                    FETCH cr_crapcob INTO rw_crapcob;

                    -- atribuindo o rowid
                    vr_rowid_crapcob := rw_crapcob.rowid;

                    -- se retornar 0 registros ou mais que 1 registro
                    -- é igual a NOT AVAILABLE no progress
                    vr_crapcobfound := (nvl(rw_crapcob.qtde_reg,0) = 1);

                    -- se não existir ou se existir mais que um registro
                    -- processa o bloco...
                    IF NOT vr_crapcobfound THEN
                      -- fechando o cursor
                      CLOSE cr_crapcob;
                      -- Abre o cursor de parametros de cobranca
                      OPEN cr_crapcco_global( pr_cdcooper => pr_cdcooper
                                             ,pr_cddbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                             ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                             ,pr_nroconve => vr_tab_regimp2(vr_indregimp).nroconve);
                      FETCH cr_crapcco_global INTO rw_crapcco_global;

                      -- se existir informações processa...
                      IF cr_crapcco_global%FOUND THEN

                        --fecha o cursor
                        CLOSE cr_crapcco_global;

                        -- busca os números de convênio ref. as contas de migração
                        --vr_nrconven_mig := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CTA_CONVENIO_MIGRACAO');

                        /* PRIMEIRA VERIFICACAO */
                        IF ((rw_crapcco_global.dsorgarq = 'IMPRESSO PELO SOFTWARE') OR
                           ( rw_crapcco_global.dsorgarq IN ('MIGRACAO','INCORPORACAO')-- AND
                           -- deve verificar os convenios migrados apenas pela descrição
                           --lpad(rw_crapcco_global.nrconven,7,'0') IN ('1343313','1601301','0457595'))) AND
                           --InStr(vr_nrconven_mig, LPad(rw_crapcco_global.nrconven,7,'0')) > 0)
                           )) AND
                           vr_tab_regimp2(vr_indregimp).incnvaut
                        THEN
                          --31012014
                          -- nao pode gerar boletos de convenio impresso pelo software de cooperado migrado
                          IF NOT rw_crapcco_global.dsorgarq IN ('MIGRACAO','INCORPORACAO') AND vr_flagtco = TRUE THEN
                            -- vai para o proximo registro da temp-table
                            RAISE vr_proximo_registro;
                          END IF;

                          -- chamada para criacao do registro crapcob
                          pc_cria_ceb_cob( pr_cdcooper => pr_cdcooper
                                          ,pr_dtmvtolt => pr_dtmvtolt
                                          ,pr_ind_regimp => vr_indregimp
                                          ,pr_flgutceb   => (rw_crapcco_global.flgutceb = 1)
                                          ,pr_flgcebok   => vr_flgcebok
                                          ,pr_rowid_crapcob => vr_rowid_crapcob
                                          ,pr_dscritic   => pr_dscritic );

                          IF trim(pr_dscritic) IS NOT NULL THEN
                            --retorna a critica para o programa que chamou a rotina
                            RETURN;
                          END IF;

                          -- se inseriu na crapcob marca que possui registro
                          IF vr_rowid_crapcob IS NOT NULL THEN
                            vr_crapcobfound := TRUE;
                          END IF;

                          IF NOT vr_flgcebok THEN
                            -- se é migracao
                            IF NOT rw_crapcco_global.dsorgarq IN ('MIGRACAO','INCORPORACAO') THEN
                              -- chamada para criacao dos rejeitados
                              pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                                ,pr_cdcritic => 592
                                                ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                ,pr_nrdctitg => ' '
                                                ,pr_nrdctabb => 0
                                                ,pr_dshistor => ' '
                                                ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                                ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                                -- parametros da vr_tab_regimp2
                                                ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                                ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                                ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                                ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                                ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                                ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                                ,pr_tab_cratrej => pr_tab_cratrej
                                                ,pr_qtregrej    => vr_qtregrej
                                                ,pr_vlregrej    => vr_vlregrej
                                                ,pr_dscritic    => pr_dscritic);
                              -- Tratando a critica
                              IF trim(pr_dscritic) IS NOT NULL THEN
                                -- retorna o processamento para o programa chamador
                                RETURN;
                              END IF;

                              -- Se é o último registro da conta/convenio
                              IF vr_tab_regimp2(vr_indregimp).last_of THEN
                                -- se o valor do lancamento é maior que zero
                                IF nvl(vr_totvllanmt2,0) > 0 THEN
                                  -- Efetua o lançamento
                                  pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                                      ,pr_nrdconta => vr_nrdconta
                                                      ,pr_vllanmto => vr_totvllanmt2
                                                      ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                                      ,pr_nrdocmto => vr_nrdocmto
                                                      ,pr_qtdbolet => vr_totqtdbole2
                                                      ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                                      ,pr_rowid_craplot => vr_rowid_craplot
                                                      ,pr_dscritic => pr_dscritic);
                                  -- se retornar erro, volta para o programa chamador
                                  IF trim(pr_dscritic) IS NOT NULL THEN
                                    -- Volta para o programa chamador
                                    RETURN;
                                  END IF;
                                END IF; --IF nvl(vr_vllanmt2,0) > 0 THEN

                                -- se o valor é maior que zero faz o lancamento da tarifa
                                IF Nvl(vr_totvllanmto,0) > 0 THEN

                                  -- efetua o lançamento da tarifa
                                  pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                        ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                        ,pr_dtmvtolt => pr_dtmvtolt
                                                        ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                        ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                        ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                        ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                        ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                        ,pr_vltarifa => vr_totvllanmto
                                                        ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                        ,pr_cdpesqbb => vr_cdpesqbb
                                                        ,pr_cdcritic => pr_cdcritic
                                                        ,pr_dscritic => pr_dscritic
                                                        ,pr_tab_erro => pr_tab_erro);
                                  -- verifica se ocorreu algum erro
                                  IF trim(pr_dscritic) IS NOT NULL THEN
                                    -- retorna para o programa chamador
                                    RETURN;
                                  END IF;
                                END IF; --IF Nvl(vr_vllanmto,0) > 0 THEN

                                -- Inikcializando as variaveis
                                vr_totvllanmto := 0;
                                vr_totvllanmt2 := 0;
                                vr_totqtdbolet := 0;
                                vr_totqtdbole2 := 0;
                              END IF;--IF  LAST-OF (tt-regimp.nroconve) THEN

                              -- avanca para o proximo registro
                              RAISE vr_proximo_registro;
                            END IF; --IF rw_crapcco.dsorgarq <> 'MIGRACAO' THEN

                          END IF; --IF NOT vr_flgcebok THEN

                        ELSE /* PRIMEIRA VERIFICACAO */ --IF ((rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE') OR
                          /* se nao for cooperado migrado, critica
                             titulo nao encontrado 592 */
                          IF vr_flagtco = FALSE THEN
                            -- chamada para criacao dos rejeitados
                            pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                              ,pr_cdcritic => 592
                                              ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                              ,pr_nrdctitg => ' '
                                              ,pr_nrdctabb => 0
                                              ,pr_dshistor => ' '
                                              ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                              ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                              -- parametros da vr_tab_regimp2
                                              ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                              ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                              ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                              ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                              ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                              ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                              ,pr_tab_cratrej => pr_tab_cratrej
                                              ,pr_qtregrej    => vr_qtregrej
                                              ,pr_vlregrej    => vr_vlregrej
                                              ,pr_dscritic    => pr_dscritic);
                            -- Tratando a critica
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- retorna o processamento para o programa chamador
                              RETURN;
                            END IF;
                          END IF;--IF vr_flagtco = FALSE THEN

                          -- Se é o último registro da conta/convenio
                          IF vr_tab_regimp2(vr_indregimp).last_of THEN
                            -- se o valor do lancamento é maior que zero
                            IF nvl(vr_totvllanmt2,0) > 0 THEN
                              -- Efetua o lançamento
                              pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => vr_nrdconta
                                                  ,pr_vllanmto => vr_totvllanmt2
                                                  ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                                  ,pr_nrdocmto => vr_nrdocmto
                                                  ,pr_qtdbolet => vr_totqtdbole2
                                                  ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                                  ,pr_rowid_craplot => vr_rowid_craplot
                                                  ,pr_dscritic => pr_dscritic);

                              -- se retornar erro, volta para o programa chamador
                              IF trim(pr_dscritic) IS NOT NULL THEN
                                -- Volta para o programa chamador
                                RETURN;
                              END IF;
                            END IF; --IF nvl(vr_totvllanmt2,0) > 0 THEN

                            -- se o valor é maior que zero faz o lancamento da tarifa
                            IF Nvl(vr_totvllanmto,0) > 0 THEN

                              -- efetua o lançamento da tarifa
                              pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                    ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                    ,pr_dtmvtolt => pr_dtmvtolt
                                                    ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                    ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                    ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                    ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                    ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                    ,pr_vltarifa => vr_totvllanmto
                                                    ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                    ,pr_cdpesqbb => vr_cdpesqbb
                                                    ,pr_cdcritic => pr_cdcritic
                                                    ,pr_dscritic => pr_dscritic
                                                    ,pr_tab_erro => pr_tab_erro);
                              -- verifica se ocorreu algum erro
                              IF trim(pr_dscritic) IS NOT NULL THEN
                                -- retorna para o programa chamador
                                RETURN;
                              END IF;
                            END IF; --IF Nvl(vr_totvllanmto,0) > 0 THEN

                            -- Inikcializando as variaveis
                            vr_vllanmto := 0;
                            vr_vllanmt2 := 0;
                            vr_qtdbolet := 0;
                            vr_qtdbole2 := 0;
                          END IF;--IF  LAST-OF (tt-regimp.nroconve) THEN

                          -- avanca para o proximo registro
                          RAISE vr_proximo_registro;

                        END IF; /* PRIMEIRA VERIFICACAO */ --IF ((rw_crapcco.dsorgarq = 'IMPRESSO PELO SOFTWARE') OR

                      ELSE --IF cr_crapcco%FOUND THEN

                        -- fecha o cursor
                        CLOSE cr_crapcco_global;

                        -- chamada para criacao dos rejeitados
                        pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                          ,pr_cdcritic => 563
                                          ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                          ,pr_nrdctitg => ' '
                                          ,pr_nrdctabb => 0
                                          ,pr_dshistor => ' '
                                          ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                          ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                          -- parametros da vr_tab_regimp2
                                          ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                          ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                          ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                          ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                          ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                          ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                          ,pr_tab_cratrej => pr_tab_cratrej
                                          ,pr_qtregrej    => vr_qtregrej
                                          ,pr_vlregrej    => vr_vlregrej
                                          ,pr_dscritic    => pr_dscritic);
                        -- Tratando a critica
                        IF trim(pr_dscritic) IS NOT NULL THEN
                          -- retorna o processamento para o programa chamador
                          RETURN;
                        END IF;

                        -- Se é o último registro da conta/convenio
                        IF vr_tab_regimp2(vr_indregimp).last_of THEN
                          -- se o valor do lancamento é maior que zero
                          IF nvl(vr_totvllanmt2,0) > 0 THEN
                            -- Efetua o lançamento
                            pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => vr_nrdconta
                                                ,pr_vllanmto => vr_totvllanmt2
                                                ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                                ,pr_nrdocmto => vr_nrdocmto
                                                ,pr_qtdbolet => vr_totqtdbole2
                                                ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                                ,pr_rowid_craplot => vr_rowid_craplot
                                                ,pr_dscritic => pr_dscritic);
                            -- se retornar erro, volta para o programa chamador
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- Volta para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF nvl(vr_vllanmt2,0) > 0 THEN

                          -- se o valor é maior que zero faz o lancamento da tarifa
                          IF Nvl(vr_totvllanmto,0) > 0 THEN

                            -- efetua o lançamento da tarifa
                            pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                  ,pr_dtmvtolt => pr_dtmvtolt
                                                  ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                  ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                  ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                  ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                  ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                  ,pr_vltarifa => vr_totvllanmto
                                                  ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                  ,pr_cdpesqbb => vr_cdpesqbb
                                                  ,pr_cdcritic => pr_cdcritic
                                                  ,pr_dscritic => pr_dscritic
                                                  ,pr_tab_erro => pr_tab_erro);
                            -- verifica se ocorreu algum erro
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- retorna para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF Nvl(vr_vllanmto,0) > 0 THEN

                          -- Inikcializando as variaveis
                          vr_totvllanmto := 0;
                          vr_totvllanmt2 := 0;
                          vr_totqtdbolet := 0;
                          vr_totqtdbole2 := 0;
                        END IF;--IF  LAST-OF (tt-regimp.nroconve) THEN

                        -- avanca para o proximo registro
                        RAISE vr_proximo_registro;

                      END IF; --IF cr_crapcco%FOUND THEN
                    ELSE --IF cr_crapcob%NOTFOUND THEN
                      -- fechando o cursor
                      CLOSE cr_crapcob;

                      -- se a data em que o associado retirou o bloqueto estiver nula
                      IF rw_crapcob.dtretcob IS NULL THEN
                        -- chamada para criacao dos rejeitados
                        pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                          ,pr_cdcritic => 589
                                          ,pr_nrdconta => rw_crapcob.nrdconta
                                          ,pr_nrdctitg => ' '
                                          ,pr_nrdctabb => 0
                                          ,pr_dshistor => ' '
                                          ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                          ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                          -- parametros da vr_tab_regimp2
                                          ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                          ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                          ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                          ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                          ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                          ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                          ,pr_tab_cratrej => pr_tab_cratrej
                                          ,pr_qtregrej    => vr_qtregrej
                                          ,pr_vlregrej    => vr_vlregrej
                                          ,pr_dscritic    => pr_dscritic);
                        -- Tratando a critica
                        IF trim(pr_dscritic) IS NOT NULL THEN
                          -- retorna o processamento para o programa chamador
                          RETURN;
                        END IF;

                        -- se é o ultimo registro da conta/convenio
                        IF vr_tab_regimp2(vr_indregimp).last_of THEN

                          IF Nvl(vr_totvllanmt2,0) > 0 THEN
                            -- Efetua o lançamento
                            pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => vr_nrdconta
                                                ,pr_vllanmto => vr_totvllanmt2
                                                ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                                ,pr_nrdocmto => vr_nrdocmto
                                                ,pr_qtdbolet => vr_totqtdbole2
                                                ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                                ,pr_rowid_craplot => vr_rowid_craplot
                                                ,pr_dscritic => pr_dscritic);
                            -- se retornar erro, volta para o programa chamador
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- Volta para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF Nvl(vr_vllanmt2,0) > 0 THEN

                          -- se o valor é  que zero faz o lancamento da tarifa
                          IF Nvl(vr_totvllanmto,0) > 0 THEN

                            -- efetua o lançamento da tarifa
                            pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                  ,pr_dtmvtolt => pr_dtmvtolt
                                                  ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                  ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                  ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                  ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                  ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                  ,pr_vltarifa => vr_totvllanmto
                                                  ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                  ,pr_cdpesqbb => vr_cdpesqbb
                                                  ,pr_cdcritic => pr_cdcritic
                                                  ,pr_dscritic => pr_dscritic
                                                  ,pr_tab_erro => pr_tab_erro);
                            -- verifica se ocorreu algum erro
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- retorna para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF Nvl(vr_vllanmto,0) > 0 THEN

                          -- Inikcializando as variaveis
                          vr_totvllanmto := 0;
                          vr_totvllanmt2 := 0;
                          vr_totqtdbolet := 0;
                          vr_totqtdbole2 := 0;

                        END IF;--IF vr_tab_regimp2(vr_indregimp).last_of THEN

                        -- avanca para o proximo registro
                        RAISE vr_proximo_registro;

                      END IF;--IF rw_crapcob.dtretcob IS NULL THEN

                      -- se o Indicador de cobranca é 5(?) (0-nao entrou, 1-entrou)
                      IF rw_crapcob.incobran = 5 THEN
                        -- chamada para criacao dos rejeitados
                        pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                          ,pr_cdcritic => 594 --594 - Bloqueto ja processado.
                                          ,pr_nrdconta => rw_crapcob.nrdconta
                                          ,pr_nrdctitg => ' '
                                          ,pr_nrdctabb => 0
                                          ,pr_dshistor => ' '
                                          ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                          ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                          -- parametros da vr_tab_regimp2
                                          ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                          ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                          ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                          ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                          ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                          ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                          ,pr_tab_cratrej => pr_tab_cratrej
                                          ,pr_qtregrej    => vr_qtregrej
                                          ,pr_vlregrej    => vr_vlregrej
                                          ,pr_dscritic    => pr_dscritic);
                        -- Tratando a critica
                        IF trim(pr_dscritic) IS NOT NULL THEN
                          -- retorna o processamento para o programa chamador
                          RETURN;
                        END IF;

                        -- se é o ultimo registro da conta/convenio
                        IF vr_tab_regimp2(vr_indregimp).last_of THEN

                          IF Nvl(vr_totvllanmt2,0) > 0 THEN
                            -- Efetua o lançamento
                            pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => vr_nrdconta
                                                ,pr_vllanmto => vr_totvllanmt2
                                                ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                                ,pr_nrdocmto => vr_nrdocmto
                                                ,pr_qtdbolet => vr_totqtdbole2
                                                ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                                ,pr_rowid_craplot => vr_rowid_craplot
                                                ,pr_dscritic => pr_dscritic);
                            -- se retornar erro, volta para o programa chamador
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- Volta para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF Nvl(vr_vllanmt2,0) > 0 THEN

                          -- se o valor é maior que zero faz o lancamento da tarifa
                          IF Nvl(vr_totvllanmto,0) > 0 THEN

                            -- efetua o lançamento da tarifa
                            pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                  ,pr_dtmvtolt => pr_dtmvtolt
                                                  ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                  ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                  ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                  ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                  ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                  ,pr_vltarifa => vr_totvllanmto
                                                  ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                  ,pr_cdpesqbb => vr_cdpesqbb
                                                  ,pr_cdcritic => pr_cdcritic
                                                  ,pr_dscritic => pr_dscritic
                                                  ,pr_tab_erro => pr_tab_erro);
                            -- verifica se ocorreu algum erro
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- retorna para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF Nvl(vr_vllanmto,0) > 0 THEN

                          -- Inikcializando as variaveis
                          vr_totvllanmto := 0;
                          vr_totvllanmt2 := 0;
                          vr_totqtdbolet := 0;
                          vr_totqtdbole2 := 0;

                        END IF;--IF vr_tab_regimp2(vr_indregimp).last_of THEN

                        -- avanca para o proximo registro
                        RAISE vr_proximo_registro;

                      END IF;--IF rw_crapcob.incobran = 5 THEN
                      --
                      IF NOT vr_tab_regimp2(vr_indregimp).incnvaut THEN
                        -- Atualiza o numero da conta na temp-table
                        vr_tab_regimp2(vr_indregimp).nrdconta := rw_crapcob.nrdconta;
                      END IF;
                    END IF;--IF cr_crapcob%NOTFOUND THEN

                    vr_nrdconta := vr_tab_regimp2(vr_indregimp).nrdconta;

                    --Selecionar Cooperado
                    OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => vr_nrdconta);
                    FETCH cr_crapass INTO rw_crapass;
                    vr_crapass:= cr_crapass%FOUND;
                    CLOSE cr_crapass;

                    -- se não existir cadastro do cooperado
                    IF NOT vr_crapass THEN
                      -- chamada para criacao dos rejeitados
                      pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                        ,pr_cdcritic => 9
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_nrdctitg => ' '
                                        ,pr_nrdctabb => 0
                                        ,pr_dshistor => ' '
                                        ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                        ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                        -- parametros da vr_tab_regimp2
                                        ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                        ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                        ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                        ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                        ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                        ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                        ,pr_tab_cratrej => pr_tab_cratrej
                                        ,pr_qtregrej    => vr_qtregrej
                                        ,pr_vlregrej    => vr_vlregrej
                                        ,pr_dscritic    => pr_dscritic);
                      -- Tratando a critica
                      IF trim(pr_dscritic) IS NOT NULL THEN
                        -- retorna o processamento para o programa chamador
                        RETURN;
                      END IF;

                      -- avanca para o proximo registro
                      RAISE vr_proximo_registro;
                    END IF; --IF cr_crapass%NOTFOUND THEN

                    -- se a situacao estiver entre...
                    IF rw_crapass.cdsitdtl  IN (2,4,5,6,7,8) THEN
                      -- verifica transferencia e duplicacao de matricula
                      OPEN cr_craptrf( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => vr_nrdconta);
                      FETCH cr_craptrf INTO rw_craptrf;

                      -- se localizou um registro
                      IF cr_craptrf%FOUND THEN
                        vr_nrdconta := rw_craptrf.nrsconta;
                      END IF; --IF   AVAILABLE craptrf   THEN
                      -- fechando o cursor
                      CLOSE cr_craptrf;
                    END IF;--IF vr_tab_crapass(vr_nrdconta).cdsitdtl IN (2,4,5,6,7,8) THEN

                    vr_tab_regimp2(vr_indregimp).inarqcbr := vr_inarqcbr;

                    -- atualizando também na temp-table principal, pois estão com o mesmo indice
                    pr_tab_regimp(vr_indregimp).inarqcbr := vr_inarqcbr;


                    -- se é cooperativa 2
                    IF pr_cdcooper = 2 THEN
                      -- verificando o cadastro de contas transferidas entre cooperativas
                      OPEN cr_craptco2( pr_cdcopant => pr_cdcooper
                                       ,pr_nrctaant => vr_nrdconta);
                      FETCH cr_craptco2 INTO rw_craptco2;

                      -- se existir dados
                      IF cr_craptco2%FOUND THEN

                        -- fechando o cursor
                        CLOSE cr_craptco2;

                        -- chamada para criacao dos rejeitados
                        pc_cria_rejeitados( pr_cdcooper => rw_craptco2.cdcopant
                                          ,pr_cdcritic => 999
                                          ,pr_nrdconta => rw_craptco2.nrctaant
                                          ,pr_nrdctitg => ' '
                                          ,pr_nrdctabb => 0
                                          ,pr_dshistor => ' '
                                          ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                          ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                          -- parametros da vr_tab_regimp2
                                          ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                          ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                          ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                          ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                          ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                          ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                          ,pr_tab_cratrej => pr_tab_cratrej
                                          ,pr_qtregrej    => vr_qtregrej
                                          ,pr_vlregrej    => vr_vlregrej
                                          ,pr_dscritic    => pr_dscritic);
                        -- Tratando a critica
                        IF trim(pr_dscritic) IS NOT NULL THEN
                          -- retorna o processamento para o programa chamador
                          RETURN;
                        END IF;

                        -- Atualizando a tabela crapcob
                        BEGIN
                          UPDATE crapcob SET  crapcob.incobran = 5  /* Pago */
                                            ,crapcob.dtdpagto = pr_dtmvtolt
                                            ,crapcob.vldpagto = vr_vllanmto
                                            ,crapcob.indpagto = 0 /* Compe */
                                            ,crapcob.cdbanpag = vr_tab_regimp2(vr_indregimp).cdbanpag
                                            ,crapcob.cdagepag = vr_tab_regimp2(vr_indregimp).cdagepag
                                            ,crapcob.vltarifa = pr_tab_cratarq(vr_indcratarq).vltarifa
                          WHERE ROWID = vr_rowid_crapcob;
                          -- retornando para a variavel de registro.

                        EXCEPTION
                          WHEN OTHERS THEN
                            pr_dscritic := 'Erro ao atualizar a tabela crapcob na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                            -- retorna a critica para o programa que chamou a rotina
                            RETURN;
                        END;

                        -- se é o ultimo registro da conta/convenio
                        IF vr_tab_regimp2(vr_indregimp).last_of THEN

                          --
                          IF Nvl(vr_totvllanmt2,0) > 0 THEN
                            -- Efetua o lançamento
                            pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => vr_nrdconta
                                                ,pr_vllanmto => vr_totvllanmt2
                                                ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                                ,pr_nrdocmto => vr_nrdocmto
                                                ,pr_qtdbolet => vr_totqtdbole2
                                                ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                                ,pr_rowid_craplot => vr_rowid_craplot
                                                ,pr_dscritic => pr_dscritic);
                            -- se retornar erro, volta para o programa chamador
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- Volta para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF Nvl(vr_vllanmt2,0) > 0 THEN

                          -- se o valor é maior que zero faz o lancamento da tarifa
                          IF Nvl(vr_totvllanmto,0) > 0 THEN

                            -- efetua o lançamento da tarifa
                            pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                  ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                  ,pr_dtmvtolt => pr_dtmvtolt
                                                  ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                  ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                  ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                  ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                  ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                  ,pr_vltarifa => vr_totvllanmto
                                                  ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                  ,pr_cdpesqbb => vr_cdpesqbb
                                                  ,pr_cdcritic => pr_cdcritic
                                                  ,pr_dscritic => pr_dscritic
                                                  ,pr_tab_erro => pr_tab_erro);
                            -- verifica se ocorreu algum erro
                            IF trim(pr_dscritic) IS NOT NULL THEN
                              -- retorna para o programa chamador
                              RETURN;
                            END IF;
                          END IF; --IF Nvl(vr_vllanmto,0) > 0 THEN

                          -- Inicializando as variaveis
                          vr_totvllanmto := 0;
                          vr_totvllanmt2 := 0;
                          vr_totqtdbolet := 0;
                          vr_totqtdbole2 := 0;

                        END IF;--IF vr_tab_regimp2(vr_indregimp).last_of THEN

                        -- avanca para o proximo registro
                        RAISE vr_proximo_registro;
                      ELSE
                        -- fechando o cursor
                        CLOSE cr_craptco2;
                      END IF; --IF cr_craptco2%FOUND THEN
                    END IF;--IF pr_cdcooper = 2 THEN

                    /*********************** Atualizacoes **********************/
                    /* -------- Criacao de Lote --------- */
                    OPEN cr_craplot ( pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => pr_dtmvtopr
                                     ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                     ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                     ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote);
                    FETCH cr_craplot INTO rw_craplot;

                    IF cr_craplot%NOTFOUND THEN
                      -- fechando o cursor
                      CLOSE cr_craplot;

                      BEGIN
                        INSERT INTO craplot( craplot.dtmvtolt
                                            ,craplot.cdagenci
                                            ,craplot.cdbccxlt
                                            ,craplot.nrdolote
                                            ,craplot.tplotmov
                                            ,craplot.cdcooper)
                        VALUES ( pr_dtmvtopr
                                ,nvl(pr_tab_cratarq(vr_indcratarq).cdagenci,0)
                                ,nvl(pr_tab_cratarq(vr_indcratarq).cdbccxlt,0)
                                ,nvl(pr_tab_cratarq(vr_indcratarq).nrdolote,0)
                                ,nvl(pr_tab_cratarq(vr_indcratarq).tplotmov,0)
                                ,pr_cdcooper)
                        RETURNING craplot.ROWID
                             INTO vr_rowid_craplot;
                      EXCEPTION
                        WHEN OTHERS THEN
                         pr_dscritic := 'Erro ao inserir dados na tabela craplot na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                         -- retorna a critica para o programa que chamou a rotina
                         RETURN;
                      END;
                    ELSE
                      -- fechando o cursor
                      CLOSE cr_craplot;
                      -- inicializando o rowid da craplot
                      vr_rowid_craplot := rw_craplot.ROWID;
                    END IF;-- IF cr_craplot%NOTFOUND THEN

                    -- verifica se existe o lançamento
                    OPEN cr_craplcm( pr_cdcooper => pr_cdcooper
                                    ,pr_dtmvtolt => pr_dtmvtopr
                                    ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                    ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                    ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                    ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdconta
                                    ,pr_nrdocmto => vr_tab_regimp2(vr_indregimp).nrdocmto
                                    ,pr_cdpesqbb => vr_cdpesqbb /* Nro. Conve */);
                    FETCH cr_craplcm INTO rw_craplcm;
                    -- se localizar o lançamento insere rejeitados
                    IF cr_craplcm%FOUND THEN
                      -- fecha o cursor
                      CLOSE cr_craplcm;
                      -- chamada para criacao dos rejeitados
                      pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                        ,pr_cdcritic => 92
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_nrdctitg => lpad(vr_tab_regimp2(vr_indregimp).nrdctabb,8,'0')
                                        ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                        ,pr_dshistor => ' '
                                        ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                        ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                        -- parametros da vr_tab_regimp2
                                        ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                        ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                        ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                        ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                        ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                        ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                        ,pr_tab_cratrej => pr_tab_cratrej
                                        ,pr_qtregrej    => vr_qtregrej
                                        ,pr_vlregrej    => vr_vlregrej
                                        ,pr_dscritic    => pr_dscritic);
                      -- Tratando a critica
                      IF trim(pr_dscritic) IS NOT NULL THEN
                        -- retorna o processamento para o programa chamador
                        RETURN;
                      END IF;

                      -- se é o ultimo registro da conta/convenio
                      IF vr_tab_regimp2(vr_indregimp).last_of THEN

                        --
                        IF Nvl(vr_totvllanmt2,0) > 0 THEN
                          -- Efetua o lançamento
                          pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => vr_nrdconta
                                              ,pr_vllanmto => vr_totvllanmt2
                                              ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                              ,pr_nrdocmto => vr_nrdocmto
                                              ,pr_qtdbolet => vr_totqtdbole2
                                              ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                              ,pr_rowid_craplot => vr_rowid_craplot
                                              ,pr_dscritic => pr_dscritic);
                          -- se retornar erro, volta para o programa chamador
                          IF trim(pr_dscritic) IS NOT NULL THEN
                            -- Volta para o programa chamador
                            RETURN;
                          END IF;
                        END IF; --IF Nvl(vr_vllanmt2,0) > 0 THEN

                        -- se o valor é maior que zero faz o lancamento da tarifa
                        IF Nvl(vr_totvllanmto,0) > 0 THEN

                          -- efetua o lançamento da tarifa
                          pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                ,pr_vltarifa => vr_totvllanmto
                                                ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                ,pr_cdpesqbb => vr_cdpesqbb
                                                ,pr_cdcritic => pr_cdcritic
                                                ,pr_dscritic => pr_dscritic
                                                ,pr_tab_erro => pr_tab_erro);
                          -- verifica se ocorreu algum erro
                          IF trim(pr_dscritic) IS NOT NULL THEN
                            -- retorna para o programa chamador
                            RETURN;
                          END IF;
                        END IF; --IF Nvl(vr_vllanmto,0) > 0 THEN

                        -- Inikcializando as variaveis
                        vr_totvllanmto := 0;
                        vr_totvllanmt2 := 0;
                        vr_totqtdbolet := 0;
                        vr_totqtdbole2 := 0;

                      END IF;--IF vr_tab_regimp2(vr_indregimp).last_of THEN

                      -- avanca para o proximo registro
                      RAISE vr_proximo_registro;
                    ELSE
                      -- fecha o cursor
                      CLOSE cr_craplcm;
                    END IF;--IF cr_craplcm%FOUND THEN

                    IF vr_crapcobfound THEN
                      -- Efetua os lançamentos de baixa de títulos
                      pc_atualiza_lancamentos_baixa( pr_cdcooper => pr_cdcooper
                                                    ,pr_dtmvtolt => pr_dtmvtolt
                                                    ,pr_flgcruni => vr_flgcruni
                                                    ,pr_cdpesqbb => vr_cdpesqbb
                                                    ,pr_indregimp  => vr_indregimp
                                                    ,pr_indcratarq => vr_indcratarq
                                                    ,pr_rwcrapcob  => rw_crapcob
                                                    ,pr_rowid_craplot => vr_rowid_craplot --rw_craplot.ROWID
                                                    ,pr_cdagenci      => pr_cdagenci
                                                    ,pr_nrdcaixa      => pr_nrdcaixa
                                                    ,pr_cdcritic      => pr_cdcritic
                                                    ,pr_dscritic      => pr_dscritic
                                                    ,pr_tab_erro      => pr_tab_erro);
                      -- verifica se ocorreu algum erro
                      IF trim(pr_dscritic) IS NOT NULL THEN
                        -- retorna para o programa chamador
                        RETURN;
                      END IF;

                      /* Acessar Bloquetos Cadastrados - Pegar nro conta associado */
                      IF vr_tab_regimp2(vr_indregimp).incnvaut THEN
                        -- Abrindo o cadastro de boquetos pelo número da conta
                        OPEN cr_crapcob( pr_cdcooper => pr_cdcooper
                                        ,pr_cdbandoc => vr_tab_regimp2(vr_indregimp).codbanco
                                        ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                        ,pr_nrcnvcob => vr_tab_regimp2(vr_indregimp).nroconve
                                        ,pr_nrdocmto => vr_tab_regimp2(vr_indregimp).nrdocmto
                                        ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta);
                      ELSE
                        -- Abrindo o cadastro de bloquetos sem passar o numero da conta
                        OPEN cr_crapcob( pr_cdcooper => pr_cdcooper
                                        ,pr_cdbandoc => vr_tab_regimp2(vr_indregimp).codbanco
                                        ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb
                                        ,pr_nrcnvcob => vr_tab_regimp2(vr_indregimp).nroconve
                                        ,pr_nrdocmto => vr_tab_regimp2(vr_indregimp).nrdocmto);
                      END IF;--IF vr_tab_regimp2(vr_indregimp).incnvaut THEN
                      -- lendo as informacoes retornadas pelo cursor
                      FETCH cr_crapcob INTO rw_crapcob;

                      -- atribuindo o rowid
                      vr_rowid_crapcob := rw_crapcob.rowid;

                      -- se não existir informações processa
                      -- corrigido
                      IF cr_crapcob%NOTFOUND OR nvl(rw_crapcob.qtde_reg,0) > 1 THEN
                        -- gera crítica
                        pr_cdcritic := 592;
                      END IF;
                      -- fechando o cursor
                      CLOSE cr_crapcob;
                    END IF;--IF rw_crapcob.ROWID IS NOT NULL THEN

                    -- se gerou critica lanca como rejeitado
                    IF Nvl(pr_cdcritic,0) > 0 THEN
                      -- cria os rejeitados
                      pc_cria_rejeitados( pr_cdcooper => pr_cdcooper
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_nrdconta => vr_nrdconta
                                        ,pr_nrdctitg => ' '
                                        ,pr_nrdctabb => 0
                                        ,pr_dshistor => ' '
                                        ,pr_nrdocmto => vr_nrdocmto      -- Número do documento
                                        ,pr_vllanmto => nvl(vr_vllanmto,0)  -- Valor do lancamento
                                        -- parametros da vr_tab_regimp2
                                        ,pr_nmarquiv => vr_tab_regimp2(vr_indregimp).nmarquiv
                                        ,pr_nrseqdig => vr_tab_regimp2(vr_indregimp).nrseqdig
                                        ,pr_codbanco => vr_tab_regimp2(vr_indregimp).codbanco
                                        ,pr_cdagenci => vr_tab_regimp2(vr_indregimp).cdagenci
                                        ,pr_nrdolote => vr_tab_regimp2(vr_indregimp).nrdolote
                                        ,pr_cdpesqbb => vr_tab_regimp2(vr_indregimp).cdpesqbb
                                        ,pr_tab_cratrej => pr_tab_cratrej
                                        ,pr_qtregrej    => vr_qtregrej
                                        ,pr_vlregrej    => vr_vlregrej
                                        ,pr_dscritic    => pr_dscritic);
                      -- Tratando a critica
                      IF trim(pr_dscritic) IS NOT NULL THEN
                        -- retorna o processamento para o programa chamador
                        RETURN;
                      END IF;

                      /* Garantir que soh serao passados para a efetua_baixa_titulo,
                      titulos que estao em DESCONTO */
                      --IF   AVAILABLE tt-descontar   THEN
                      --    DELETE tt-descontar.
                      IF vr_tab_descontar.Count() > 0 THEN
                        vr_tab_descontar.DELETE;
                      END IF;

                      -- se eh o último registro da conta/convenio
                      IF vr_tab_regimp2(vr_indregimp).last_of THEN
                        IF Nvl(vr_totvllanmt2,0) > 0 THEN
                          -- Efetua o lançamento
                          pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => vr_nrdconta
                                              ,pr_vllanmto => vr_totvllanmt2
                                              ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                              ,pr_nrdocmto => vr_nrdocmto
                                              ,pr_qtdbolet => vr_totqtdbole2
                                              ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                              ,pr_rowid_craplot => vr_rowid_craplot
                                              ,pr_dscritic => pr_dscritic);
                          -- se retornar erro, volta para o programa chamador
                          IF trim(pr_dscritic) IS NOT NULL THEN
                            -- Volta para o programa chamador
                            RETURN;
                          END IF;
                        END IF;--IF Nvl(vr_totvllanmt2,0) > 0 THEN
                        --
                        IF vr_totvllanmto > 0 THEN
                          -- efetua o lançamento da tarifa
                          pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                                ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                                ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                                ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                                ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                                ,pr_vltarifa => vr_totvllanmto
                                                ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                                ,pr_cdpesqbb => vr_cdpesqbb
                                                ,pr_cdcritic => pr_cdcritic
                                                ,pr_dscritic => pr_dscritic
                                                ,pr_tab_erro => pr_tab_erro);
                          -- verifica se ocorreu algum erro
                          IF trim(pr_dscritic) IS NOT NULL THEN
                            -- retorna para o programa chamador
                            RETURN;
                          END IF;
                        END IF;--IF vr_totvllanmto > 0 THEN
                        -- reinicializando os totalizadores por conta/convênio
                        vr_totvllanmto := 0;
                        vr_totvllanmt2 := 0;
                        vr_totqtdbolet := 0;
                        vr_totqtdbole2 := 0;
                      END IF; --IF vr_tab_regimp2(vr_indregimp).last_of THEN

                      -- avanca para o proximo registro
                      RAISE vr_proximo_registro;

                    END IF;--IF Nvl(pr_cdcritic,0) > 0 THEN

                    /* realizar apenas quando possui Bloquetos de Cobranca */
                    IF vr_rowid_crapcob IS NOT NULL THEN
                      BEGIN
                        UPDATE crapcob SET
                               crapcob.incobran  = 5          /* Processado */
                              ,crapcob.dtdpagto = pr_dtmvtolt
                              ,crapcob.vldpagto = vr_vllanmto
                              ,crapcob.indpagto = 0          /* Compensacao */
                              ,crapcob.cdbanpag = vr_tab_regimp2(vr_indregimp).cdbanpag
                              ,crapcob.cdagepag = vr_tab_regimp2(vr_indregimp).cdagepag
                              ,crapcob.vltarifa = pr_tab_cratarq(vr_indcratarq).vltarifa
                        WHERE ROWID = vr_rowid_crapcob
                        RETURNING crapcob.incobran
                                 ,crapcob.dtdpagto
                                 ,crapcob.vldpagto
                                 ,crapcob.indpagto
                                 ,crapcob.cdbanpag
                                 ,crapcob.cdagepag
                                 ,crapcob.vltarifa
                            INTO rw_crapcob.incobran
                                 ,rw_crapcob.dtdpagto
                                 ,rw_crapcob.vldpagto
                                 ,rw_crapcob.indpagto
                                 ,rw_crapcob.cdbanpag
                                 ,rw_crapcob.cdagepag
                                 ,rw_crapcob.vltarifa;
                      EXCEPTION
                        WHEN OTHERS THEN
                          pr_dscritic := 'Erro ao atualizar a tabela crapcob na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                          -- retorna a critica para o programa que chamou a rotina
                          RETURN;
                      END;
                    END IF; /* FIM do IF AVAILABLE crapcob*/

                    IF pr_flgresta = 1 THEN
                      -- verifica restart
                      OPEN cr_crapres ( pr_cdcooper => pr_cdcooper
                                       ,pr_cdprogra => pr_cdprogra);
                      FETCH cr_crapres INTO rw_crapres;

                      -- verifica se tem restart
                      IF cr_crapres%NOTFOUND THEN
                        -- fecha o cursor
                        CLOSE cr_crapres;

                        pr_cdcritic := 151;
                        pr_dscritic := ' ';
                        vr_nrsequen := Nvl(vr_nrsequen,0) + 1;

                        gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                              ,pr_cdagenci => pr_cdagenci
                                              ,pr_nrdcaixa => pr_nrdcaixa
                                              ,pr_nrsequen => vr_nrsequen
                                              ,pr_cdcritic => pr_cdcritic
                                              ,pr_dscritic => pr_dscritic
                                              ,pr_tab_erro => pr_tab_erro);

                        -- retorna a critica para o programa que chamou a rotina
                        RETURN;
                      ELSE
                        -- fecha o cursor
                        CLOSE cr_crapres;

                        -- atualiza o controle de restart
                        UPDATE crapres SET nrdconta = vr_tab_regimp2(vr_indregimp).nrctares
                        WHERE crapres.rowid = rw_crapres.rowid;

                      END IF; --IF cr_crapres%NOTFOUND THEN
                    END IF;

                    -- se eh o último registro da conta/convenio
                    IF vr_tab_regimp2(vr_indregimp).last_of THEN
                      IF Nvl(vr_totvllanmt2,0) > 0 THEN
                        -- Efetua o lançamento
                        pc_efetua_lancamento( pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => vr_nrdconta
                                            ,pr_vllanmto => vr_totvllanmt2
                                            ,pr_cdhistor => pr_tab_cratarq(vr_indcratarq).cdhistor
                                            ,pr_nrdocmto => vr_nrdocmto
                                            ,pr_qtdbolet => vr_totqtdbole2
                                            ,pr_nrdctabb => vr_tab_regimp2(vr_indregimp).nrdctabb /*tt-regimp.nrdctabb*/
                                            ,pr_rowid_craplot => vr_rowid_craplot
                                            ,pr_dscritic => pr_dscritic);
                        -- se retornar erro, volta para o programa chamador
                        IF pr_dscritic IS NOT NULL THEN
                          -- Volta para o programa chamador
                          RETURN;
                        END IF;
                      END IF;--IF Nvl(vr_vllanmt2,0) > 0 THEN
                      --
                      IF vr_totvllanmto > 0 THEN
                        -- efetua o lançamento da tarifa
                        pc_efetua_lanc_craplat( pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => vr_tab_regimp2(vr_indregimp).nrdconta
                                              ,pr_dtmvtolt => pr_dtmvtolt
                                              ,pr_cdagenci => pr_tab_cratarq(vr_indcratarq).cdagenci
                                              ,pr_cdbccxlt => pr_tab_cratarq(vr_indcratarq).cdbccxlt
                                              ,pr_nrdolote => pr_tab_cratarq(vr_indcratarq).nrdolote
                                              ,pr_tpdolote => pr_tab_cratarq(vr_indcratarq).tplotmov
                                              ,pr_cdhistor => vr_tab_regimp2(vr_indregimp).cdhistor
                                              ,pr_vltarifa => vr_totvllanmto
                                              ,pr_cdfvlcop => vr_tab_regimp2(vr_indregimp).cdfvlcop
                                              ,pr_cdpesqbb => vr_cdpesqbb
                                              ,pr_cdcritic => pr_cdcritic
                                              ,pr_dscritic => pr_dscritic
                                              ,pr_tab_erro => pr_tab_erro);
                        -- verifica se ocorreu algum erro
                        IF trim(pr_dscritic) IS NOT NULL THEN
                          -- retorna para o programa chamador
                          RETURN;
                        END IF;
                      END IF;--IF vr_vllanmto > 0 THEN

                      -- reinicializando os totalizadores por conta/convênio
                      vr_totvllanmto := 0;
                      vr_totvllanmt2 := 0;
                      vr_totqtdbolet := 0;
                      vr_totqtdbole2 := 0;
                    END IF; --IF vr_tab_regimp2(vr_indregimp).last_of THEN

                  END IF; --IF NOT vr_flagtco OR pr_cdcooper = 16 THEN

                  vr_flagtco := FALSE;
                EXCEPTION
                  WHEN vr_proximo_registro THEN
                    NULL;
                END; -- BEGIN SEGUNDO LOOP
                -- vai para o proximo registro
                vr_indregimp := vr_tab_regimp2.next(vr_indregimp);
              END LOOP; -- /*SEGUNDO LOOP*/

              /* Totais do Arquivo */
              BEGIN
                INSERT INTO craprej( craprej.dtrefere
                                    ,craprej.nrdconta
                                    ,craprej.nrseqdig
                                    ,craprej.vllanmto
                                    ,craprej.cdcooper)
                VALUES ( SUBSTR(pr_tab_cratarq(vr_indcratarq).nmarquiv,22,06)
                        ,999999999
                        ,nvl(pr_tab_cratarq(vr_indcratarq).nrseqdig,0)
                        ,nvl(pr_tab_cratarq(vr_indcratarq).vllanmto,0)
                        ,nvl(pr_cdcooper,0)
                       );
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir dados na tabela craprej na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                  -- retorna a critica para o programa que chamou a rotina
                  RETURN;
              END;

              -- atualizando dados na tabela temporaria de arquivos
              pr_tab_cratarq(vr_indcratarq).qtregicd := vr_qtregicd;
              pr_tab_cratarq(vr_indcratarq).qtregisd := vr_qtregisd;
              pr_tab_cratarq(vr_indcratarq).qtregrej := vr_qtregrej;
              pr_tab_cratarq(vr_indcratarq).vlregrec := vr_vlcompcr;
              pr_tab_cratarq(vr_indcratarq).vlregicd := vr_vlregicd;
              pr_tab_cratarq(vr_indcratarq).vlregisd := vr_vlregisd;
              pr_tab_cratarq(vr_indcratarq).vltarifa := vr_vlcompdb;
              pr_tab_cratarq(vr_indcratarq).vlregrej := vr_vlregrej;
              pr_tab_cratarq(vr_indcratarq).qtdmigra := vr_qtdmigra;
              pr_tab_cratarq(vr_indcratarq).vlrmigra := vr_vlrmigra;
            EXCEPTION
              WHEN vr_proximo_arquivo THEN
                NULL;
            END; -- Begin Loop principal
            vr_indcratarq := pr_tab_cratarq.next(vr_indcratarq);
          END LOOP;-- /*LOOP PRINCIPAL*/ WHILE vr_indcratarq IS NOT NULL LOOP

          vr_indmigracob := vr_tab_migracaocob.first;

          WHILE vr_indmigracob IS NOT NULL LOOP
            -- se a cooperativa for altovale utiliza o historico 1132. para as demais utiliza 266.
            --16012014
            --IF pr_cdcooper = 16 THEN
            IF vr_tab_migracaocob(vr_indmigracob).dsorgarq IN ('MIGRACAO') THEN
              vr_cdhistor := 1132;
            ELSE
              vr_cdhistor := 266;
            END IF;

            -- verificando os dados das contas migradas
            OPEN cr_crapafi ( pr_cdcooper => pr_cdcooper
                             ,pr_nrdctabb => vr_tab_migracaocob(vr_indmigracob).nrdctabb
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_cdcopdst => vr_tab_migracaocob(vr_indmigracob).cdcopdst
                             ,pr_cdagedst => vr_tab_migracaocob(vr_indmigracob).cdagedst
                             ,pr_nrctadst => vr_tab_migracaocob(vr_indmigracob).nrctadst
                             ,pr_cdhistor => vr_cdhistor);
            FETCH cr_crapafi INTO rw_crapafi;

            -- se não existir o registro, o mesmo será inserido
            IF  cr_crapafi%NOTFOUND THEN
              -- fechaando o cursor
              CLOSE cr_crapafi;

              -- inserindo informações na crapafi
              BEGIN
                INSERT INTO crapafi ( crapafi.cdcooper
                                    ,crapafi.nrdctabb
                                    ,crapafi.dtmvtolt
                                    ,crapafi.dtlanmto
                                    ,crapafi.cdcopdst
                                    ,crapafi.cdagedst
                                    ,crapafi.nrctadst
                                    ,crapafi.cdhistor
                                    ,crapafi.cdhisafi
                                    ,crapafi.vllanmto
                                    ,crapafi.flprcctl)
                VALUES ( pr_cdcooper
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).nrdctabb,0)
                        ,pr_dtmvtolt
                        ,pr_dtmvtopr
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).cdcopdst,0)
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).cdagedst,0)
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).nrctadst,0)
                        ,Decode(vr_tab_migracaocob(vr_indmigracob).dsorgarq, 'MIGRACAO', 1132, 266)
                        ,Decode(vr_tab_migracaocob(vr_indmigracob).dsorgarq, 'MIGRACAO', 1124, 1123 /*Credito Cobranca Alto Vale*/)
                        ,Nvl(vr_tab_migracaocob(vr_indmigracob).vllanmto,0)
                        ,0 /*False*/);
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inseri dados na tabela crapafi na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                  -- retorna a critica para o programa que chamou a rotina
                  RETURN;
              END;

            ELSE --IF  cr_crapafi%NOTFOUND THEN
              --fechando o cursor
              CLOSE cr_crapafi;
              -- atualizando informações na crapafi
              BEGIN
                UPDATE crapafi
                SET crapafi.vllanmto = crapafi.vllanmto + Nvl(vr_tab_migracaocob(vr_indmigracob).vllanmto,0)
                WHERE  crapafi.ROWID = rw_crapafi.ROWID;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao atualizar dados na tabela crapafi na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                  -- retorna a critica para o programa que chamou a rotina
                  RETURN;
              END;
            END IF; -- IF  cr_crapafi%NOTFOUND THEN

            /* Assume como padrao tarifa pessoa juridica*/
            vr_inpessoa := 2;

            --Selecionar Cooperado
            OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => vr_tab_migracaocob(vr_indmigracob).nrctadst);
            FETCH cr_crapass INTO rw_crapass;
            vr_crapass:= cr_crapass%FOUND;
            CLOSE cr_crapass;

            -- se existir a conta
            IF vr_crapass THEN
              vr_inpessoa := rw_crapass.inpessoa;
            END IF;

            vr_vltarifa := 0;
            vr_cdhistor := 0;

            -- somente buscar tarifa se for inpessoa <> 3(sem fins lucartivos)
            -- se for 3 pr_vltarifa ficará zero
            IF vr_inpessoa <> 3 THEN

              /* Busca informacoes tarifa */
              TARI0001.pc_carrega_dados_tarifa_cobr (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                                    ,pr_nrdconta  => vr_tab_migracaocob(vr_indmigracob).nrctadst --Numero Conta
                                                    ,pr_nrconven  => vr_tab_migracaocob(vr_indmigracob).nroconve --Numero Convenio
                                                    ,pr_dsincide  => 'RET'              --Descricao Incidencia
                                                    ,pr_cdocorre  => 0 --Codigo Ocorrencia
                                                    ,pr_cdmotivo  => 31 --Codigo Motivo
                                                    ,pr_inpessoa  => vr_inpessoa --Tipo Pessoa
                                                    ,pr_vllanmto  => 1               --Valor Lancamento
                                                    ,pr_cdprogra  => vr_cdprogra --Nome Programa
                                                    ,pr_flaputar  => 1           --Apurar
                                                    ,pr_cdhistor  => vr_cdhistor --Codigo Historico
                                                    ,pr_cdhisest  => vr_cdhisest               --Historico Estorno
                                                    ,pr_vltarifa  => vr_vltarifa --Valor Tarifa
                                                    ,pr_dtdivulg  => vr_dtdivulg                  --Data Divulgacao
                                                    ,pr_dtvigenc  => vr_dtvigenc                  --Data Vigencia
                                                    ,pr_cdfvlcop  => vr_cdfvlcop               --Codigo Cooperativa
                                                    ,pr_cdcritic  => pr_cdcritic  --Codigo Critica
                                                    ,pr_dscritic  => pr_dscritic); --Descricao Critica
              -- se retornar erro
              IF trim(pr_dscritic) IS NOT NULL THEN
                -- registra o erro no log
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || pr_dscritic);
                -- limpa a variavel de critica
                pr_dscritic := ' ';
              END IF; --IF pr_dscritic IS NOT null THEN
            END IF; -- FIM IF inpessoa <> 3

            -- verificando os dados das contas migradas
            OPEN cr_crapafi ( pr_cdcooper => pr_cdcooper
                             ,pr_nrdctabb => vr_tab_migracaocob(vr_indmigracob).nrdctabb
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_cdcopdst => vr_tab_migracaocob(vr_indmigracob).cdcopdst
                             ,pr_cdagedst => vr_tab_migracaocob(vr_indmigracob).cdagedst
                             ,pr_nrctadst => vr_tab_migracaocob(vr_indmigracob).nrctadst
                             ,pr_cdhistor => vr_cdhistor);
            FETCH cr_crapafi INTO rw_crapafi;

            -- se não existir o registro, o mesmo será inserido
            IF  cr_crapafi%NOTFOUND THEN
              -- fechaando o cursor
              CLOSE cr_crapafi;
              -- inserindo informações na crapafi
              BEGIN
                INSERT INTO crapafi ( crapafi.cdcooper
                                    ,crapafi.nrdctabb
                                    ,crapafi.dtmvtolt
                                    ,crapafi.dtlanmto
                                    ,crapafi.cdcopdst
                                    ,crapafi.cdagedst
                                    ,crapafi.nrctadst
                                    ,crapafi.cdhistor
                                    ,crapafi.cdhisafi
                                    ,crapafi.vllanmto
                                    ,crapafi.flprcctl)
                VALUES ( pr_cdcooper
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).nrdctabb,0)
                        ,pr_dtmvtolt
                        ,pr_dtmvtopr
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).cdcopdst,0)
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).cdagedst,0)
                        ,nvl(vr_tab_migracaocob(vr_indmigracob).nrctadst,0)
                        ,nvl(vr_cdhistor,0)
                        ,Decode(vr_tab_migracaocob(vr_indmigracob).dsorgarq, 'MIGRACAO', 1125, 1126 /*Credito Cobranca Alto Vale*/)
                        ,Nvl(vr_tab_migracaocob(vr_indmigracob).vlrtarif,0)
                        ,0 /*False*/);
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao inserir valor da tarifa na tabela crapafi na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                  -- retorna para o programa que chamou a rotina
                  RETURN;
              END;

            ELSE --IF  cr_crapafi%NOTFOUND THEN
              --fechando o cursor
              CLOSE cr_crapafi;
              -- atualizando informações na crapafi
              BEGIN
                UPDATE crapafi
                SET crapafi.vllanmto = crapafi.vllanmto + Nvl(vr_tab_migracaocob(vr_indmigracob).vlrtarif,0)
                WHERE  crapafi.ROWID = rw_crapafi.ROWID;
              EXCEPTION
                WHEN OTHERS THEN
                  pr_dscritic := 'Erro ao atualizar valor da tarifa na tabela crapafi na rotina pc_efetiva_atualiz_compensacao. '||SQLERRM;
                  -- retorna para o programa que chamou a rotina
                  RETURN;
              END;
            END IF; -- IF  cr_crapafi%NOTFOUND THEN

            vr_indmigracob := vr_tab_migracaocob.NEXT(vr_indmigracob);
          END LOOP;--WHILE vr_indmigracob IS NOT NULL LOOP

          /* Depois de todos os movimentos de Cobranca, efetuar os movimentos de
           baixa de titulos que estao em DESCONTO */
          -- posicionando no primeiro registro
          vr_inddescontar  := vr_tab_descontar.first;

          -- loop para percorrer a tabela temporiaria
          WHILE vr_inddescontar IS NOT NULL LOOP
            -- calculando o proximo indice
            vr_indtitulos := lpad(vr_tab_descontar(vr_inddescontar).nrdconta,10,'0')||lpad(vr_tab_titulos.count() + 1,10,'0');

            -- carregando os titulos na temp table de títulos
            vr_tab_titulos(vr_indtitulos).cdbandoc := vr_tab_descontar(vr_inddescontar).cdbandoc;
            vr_tab_titulos(vr_indtitulos).nrdctabb := vr_tab_descontar(vr_inddescontar).nrdctabb;
            vr_tab_titulos(vr_indtitulos).nrcnvcob := vr_tab_descontar(vr_inddescontar).nrcnvcob;
            vr_tab_titulos(vr_indtitulos).nrdconta := vr_tab_descontar(vr_inddescontar).nrdconta;
            vr_tab_titulos(vr_indtitulos).nrdocmto := vr_tab_descontar(vr_inddescontar).nrdocmto;
            vr_tab_titulos(vr_indtitulos).vltitulo := vr_tab_descontar(vr_inddescontar).vltitulo;
            vr_tab_titulos(vr_indtitulos).flgregis := vr_tab_descontar(vr_inddescontar).flgregis;

            -- Armazenando a conta do indice da temp-table
            vr_nrdconta_quebra := vr_tab_descontar(vr_inddescontar).nrdconta;
            --armazenando o indice anterior
            vr_inddescontar_aux := vr_inddescontar;
            -- indo para o proximo registro
            vr_inddescontar := vr_tab_descontar.NEXT(vr_inddescontar);

            -- se não é o último registro da tabela
            IF vr_inddescontar IS NOT NULL THEN

              -- verifica se é quebra de conta (last-of) e efetua o lançamento
              IF vr_nrdconta_quebra <> vr_tab_descontar(vr_inddescontar).nrdconta THEN

                vr_idorigem := 1;    /** AYLLOS **/

                DSCT0001.pc_efetua_baixa_titulo (pr_cdcooper    => pr_cdcooper  --Codigo Cooperativa
                                                ,pr_cdagenci    => 0  --Codigo Agencia
                                                ,pr_nrdcaixa    => 0  --Numero Caixa
                                                ,pr_cdoperad    => 0  --Codigo operador
                                                ,pr_dtmvtolt    => pr_dtmvtopr--pr_dtmvtolt     --Data Movimento
                                                ,pr_idorigem    => vr_idorigem --Identificador Origem pagamento
                                                ,pr_nrdconta    => vr_tab_descontar(vr_inddescontar_aux).nrdconta  --Numero da conta
                                                ,pr_indbaixa    => 1 --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                                ,pr_tab_titulos => vr_tab_titulos --Titulos a serem baixados
                                                ,pr_cdcritic    => pr_cdcritic     --Codigo Critica
                                                ,pr_dscritic    => pr_dscritic     --Descricao Critica
                                                ,pr_tab_erro    => vr_tab_erro_bo); --Tabela erros

                vr_tab_titulos.DELETE;
                vr_indtitulos := 0;

                -- verifica se gerou a tabela de erros
                IF vr_tab_erro_bo.count() > 0 THEN
                  -- Escreve os erros no log
                  FOR vr_ind IN vr_tab_erro_bo.first .. vr_tab_erro_bo.last LOOP
                    -- calculando a proxima sequencia
                    vr_nrsequen := Nvl(vr_nrsequen,0) + 1;
                    /* Retorno de erro da BO */
                    gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                          ,pr_cdagenci => pr_cdagenci
                                          ,pr_nrdcaixa => pr_nrdcaixa
                                          ,pr_nrsequen => vr_nrsequen
                                          ,pr_cdcritic => pr_cdcritic
                                          ,pr_dscritic => vr_tab_erro_bo(vr_ind).dscritic
                                          ,pr_tab_erro => pr_tab_erro);

                  END LOOP;--FOR vr_ind IN vr_tab_erro_bo.first .. vr_tab_erro_bo.last LOOP
                END IF;--IF vr_tab_erro_bo.count() > 0 THEN
              END IF; --IF vr_nrdconta_quebra <> vr_tab_descontar(vr_tab_descontar).nrdconta THEN
            ELSE

              vr_idorigem := 1;    /** AYLLOS **/

              DSCT0001.pc_efetua_baixa_titulo (pr_cdcooper    => pr_cdcooper  --Codigo Cooperativa
                                              ,pr_cdagenci    => 0  --Codigo Agencia
                                              ,pr_nrdcaixa    => 0  --Numero Caixa
                                              ,pr_cdoperad    => 0  --Codigo operador
                                              ,pr_dtmvtolt    => pr_dtmvtopr     --Data Movimento
                                              ,pr_idorigem    => vr_idorigem --Identificador Origem pagamento
                                              ,pr_nrdconta    => vr_tab_descontar(vr_inddescontar_aux).nrdconta  --Numero da conta
                                              ,pr_indbaixa    => 1 --Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                              ,pr_tab_titulos => vr_tab_titulos --Titulos a serem baixados
                                              ,pr_cdcritic    => pr_cdcritic     --Codigo Critica
                                              ,pr_dscritic    => pr_dscritic     --Descricao Critica
                                              ,pr_tab_erro    => vr_tab_erro_bo); --Tabela erros

              vr_tab_titulos.DELETE;
              vr_indtitulos := 0;

              -- verifica se gerou a tabela de erros
              IF vr_tab_erro_bo.count() > 0 THEN
                -- Escreve os erros no log
                FOR vr_ind IN vr_tab_erro_bo.first .. vr_tab_erro_bo.last LOOP
                  -- calculando a proxima sequencia
                  vr_nrsequen := Nvl(vr_nrsequen,0) + 1;
                  /* Retorno de erro da BO */
                  gene0001.pc_gera_erro( pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_nrsequen => vr_nrsequen
                                        ,pr_cdcritic => pr_cdcritic
                                        ,pr_dscritic => vr_tab_erro_bo(vr_ind).dscritic
                                        ,pr_tab_erro => pr_tab_erro);

                END LOOP;--FOR vr_ind IN vr_tab_erro_bo.first .. vr_tab_erro_bo.last LOOP
              END IF;--IF vr_tab_erro_bo.count() > 0 THEN

            END IF;--IF vr_tab_descontar IS NOT NULL THEN
          END LOOP;--WHILE vr_inddescontar IS NOT NULL LOOP

          IF pr_tab_erro.Count() > 0 THEN
            pr_dscritic := pr_tab_erro(pr_tab_erro.first).dscritic;
            RETURN;
          END IF;

          -- posiciona na primeira linha da temp-table
          vr_indcratarq := pr_tab_cratarq.first;
          -- inicia loop para leitura da temp-table
          WHILE vr_indcratarq IS NOT NULL LOOP

            vr_ind_comando := vr_ind_comando + 1;
            vr_tab_comando.extend;
            vr_tab_comando(vr_ind_comando) := 'mv '||vr_caminho_compbb||'/'||pr_tab_cratarq(vr_indcratarq).nmarquiv||' '||vr_caminho_salvar||' 2> /dev/null';

            -- vai para a proxima linha da temp-table
            vr_indcratarq := pr_tab_cratarq.NEXT(vr_indcratarq);
          END LOOP;
        END;
      END pc_efetiva_atualiz_compensacao;

      /*Gera o arquivo de retorno*/
      PROCEDURE pc_gera_arquivo( pr_rwcrapcop IN cr_crapcop%ROWTYPE          -- Dados da cooperativa
                                ,pr_rwcrapdat IN BTCH0001.cr_crapdat%ROWTYPE -- Dados do calendario
                                ,pr_nmtelant  IN VARCHAR2                    -- Programa anterior
                                ,pr_cdprogra  IN VARCHAR2                    -- Codigo do programa
                                ,pr_dscritic  OUT VARCHAR2                   -- Descricao da critica
                                ) IS
      BEGIN
        DECLARE
          /* Localiza Tarifa */
          CURSOR cr_crapcco ( pr_cdcooper IN crapcco.cdcooper%TYPE
                             ,pr_nrconven IN crapcco.nrconven%TYPE ) IS
            SELECT crapcco.vlrtarif
            FROM   crapcco
            WHERE  crapcco.cdcooper = pr_cdcooper
            AND    crapcco.nrconven = pr_nrconven
            AND    crapcco.flgregis = 0; --FALSE
          rw_crapcco cr_crapcco%ROWTYPE;

          -- Cadastro de emails
          CURSOR cr_crapcem ( pr_cdcooper IN crapcem.cdcooper%TYPE
                             ,pr_nrdconta IN crapcem.nrdconta%TYPE
                             ,pr_cddemail IN crapcem.cddemail%TYPE ) IS
            SELECT crapcem.dsdemail
            FROM   crapcem
            WHERE crapcem.cdcooper = pr_cdcooper
            AND   crapcem.nrdconta = pr_nrdconta
            AND   crapcem.idseqttl = 1 -- sequencia do titular
            AND   crapcem.cddemail = pr_cddemail;
          rw_crapcem cr_crapcem%ROWTYPE;

          vr_dtmvtolt VARCHAR2(8);
          vr_dtmvtopr VARCHAR2(8);
          vr_dsdahora VARCHAR2(6);
          vr_qtregist INTEGER;
          vr_dsstring VARCHAR2(4000);
          vr_dsdatamv VARCHAR2(8);
          vr_vltarifa NUMBER;
          vr_input_file utl_file.file_type;
          vr_linha   VARCHAR2(4000);
          vr_crapceb BOOLEAN;

          -- Objetivo: Alterar a indexação da temp-table criando o first-of/last-of
          PROCEDURE pc_ajusta_ordem_crawcta( pr_tab_crawcta IN OUT typ_tab_crawcta -- temp-table com os registros
          ) IS
          BEGIN
            DECLARE
              vr_indatual   VARCHAR2(100);
              vr_indaux     VARCHAR2(100);
              vr_contador   INTEGER;
              vr_controle   VARCHAR2(100);
            BEGIN
              -- posicionando no primeiro registro da tabela
              vr_indatual := pr_tab_crawcta.first;
              -- inicializando o contador
              vr_contador := 0;
              WHILE vr_indatual IS NOT NULL
              LOOP
                -- incrementando o contador
                vr_contador := Nvl(vr_contador,0) + 1;
                -- atribuindo a sequencia do registro na tabela
                pr_tab_crawcta(vr_indatual).reg := vr_contador;
                -- gerando a variavel de controle
                vr_controle := lpad(pr_tab_crawcta(vr_indatual).nrdconta,10,'0')||
                               lpad(pr_tab_crawcta(vr_indatual).nrconven,10,'0');
                -- armazenando o indice atual para comparações
                vr_indaux   := vr_indatual;
                -- posicionando no próximo registro
                vr_indatual := pr_tab_crawcta.NEXT(vr_indatual);
                -- se nao chegou no final da tabela
                IF vr_indatual IS NOT NULL THEN
                  -- verifica se é o ultimo registro
                  IF vr_controle <>
                     lpad(pr_tab_crawcta(vr_indatual).nrdconta,10,'0')||
                     lpad(pr_tab_crawcta(vr_indatual).nrconven,10,'0')
                  THEN
                    pr_tab_crawcta(vr_indaux).reg := vr_contador;
                    pr_tab_crawcta(vr_indaux).qtde_reg := vr_contador;
                    vr_contador := 0;
                  END IF;
                -- se é o ultimo registro da tabela atribui o contador
                ELSE
                  pr_tab_crawcta(vr_indaux).qtde_reg := vr_contador;
                END IF;
              END LOOP;
            END;
          END pc_ajusta_ordem_crawcta;

        BEGIN
          -- formatando as datas e hora
          vr_dtmvtolt := To_Char(pr_rwcrapdat.dtmvtolt ,'DDMMYYYY');
          vr_dtmvtopr := To_Char(pr_rwcrapdat.dtmvtopr ,'DDMMYYYY');
          vr_dsdahora := To_Char(SYSDATE, 'hh24miss');

          -- marca os registros como first-of e last-of
          pc_ajusta_ordem_crawcta( pr_tab_crawcta => vr_tab_crawcta);

          -- posicionando no primeiro registro
          vr_indcrawcta := vr_tab_crawcta.first;

          -- percorrendo a tabela temporaria
          WHILE vr_indcrawcta IS NOT NULL LOOP
            OPEN cr_crapceb( pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => vr_tab_crawcta(vr_indcrawcta).nrdconta
                            ,pr_nrconven  => vr_tab_crawcta(vr_indcrawcta).nrconven);
            FETCH cr_crapceb INTO rw_crapceb;
            -- Verifica se tem dados. utilizado em dois locais
            vr_crapceb := cr_crapceb%FOUND;
            -- fechando o cursor;
            CLOSE cr_crapceb;
            -- se retornar dados
            IF vr_crapceb THEN
              vr_inarqcbr := rw_crapceb.inarqcbr;
            ELSE
              vr_inarqcbr := 0;
            END IF;

            IF vr_inarqcbr <> 2 THEN
              vr_indcrawcta := vr_tab_crawcta.NEXT(vr_indcrawcta);
              CONTINUE;
            END IF;

            -- se é first-of
            IF vr_tab_crawcta(vr_indcrawcta).reg = 1 THEN
              IF pr_nmtelant = 'COMPEFORA' THEN
                vr_nmarqind := 'RET-compef-';
              ELSE
                vr_nmarqind := 'RET-compe-';
              END IF;
              vr_dsdatamv := To_Char(pr_rwcrapdat.dtmvtolt,'DDMMYYYY');
              vr_nmarqind := vr_nmarqind ||
                             LPad(vr_tab_crawcta(vr_indcrawcta).nrconven,8,'0') || '-' ||
                             LPad(vr_tab_crawcta(vr_indcrawcta).nrdconta,8,'0') || '-' ||
                             vr_dsdatamv;
              vr_qtregist := 0;

              --Abrir arquivo modo write
              gene0001.pc_abre_arquivo(pr_nmdireto => vr_caminho_cooper||'/arq' --> Diretorio do arquivo
                                      ,pr_nmarquiv => vr_nmarqind       --> Nome do arquivo
                                      ,pr_tipabert => 'W'               --> Modo de abertura (R,W,A)
                                      ,pr_utlfileh => vr_input_file     --> Handle do arquivo aberto
                                      ,pr_des_erro => pr_dscritic);     --> Erro

              IF trim(pr_dscritic) IS NOT NULL THEN
                pr_dscritic := pr_dscritic || ' na rotina pc_gera_arquivo.';
                -- retorna o processamento para o programa chamador
                RETURN;
              END IF;

              /******** HEADER DO ARQUIVO ************/
              vr_linha := '00100000'||
                          '         '||
                          '2'||
                          LPad(pr_rwcrapcop.nrdocnpj,14,'0')||
                          LPad(vr_tab_crawcta(vr_indcrawcta).nrconven,9,'0')||
                          '           '||
                          LPad(pr_rwcrapcop.cdagedbb, 6,'0')||
                          LPad(vr_tab_crawcta(vr_indcrawcta).nrctabbd,13,'0')||
                          ' '||
                          RPad(pr_rwcrapcop.nmrescop,30,' ')||
                          'BANCO DO BRASIL'||
                          rpad(' ',25,' ')||
                          '2'||
                          vr_dtmvtolt||
                          vr_dsdahora||
                          '000001'||
                          '00001'||
                          rpad(' ',72,' ');

              -- Escreve linha no arquivo...
              gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text  => vr_linha);    --> Texto para escrita

              /******** HEADER DO LOTE ************/
              vr_linha := '00100011T01  030 2'||
                          LPad(pr_rwcrapcop.nrdocnpj,15,'0')||
                          LPad(vr_tab_crawcta(vr_indcrawcta).nrconven,9,'0')||
                          '0014       '||
                          LPad(pr_rwcrapcop.cdagedbb,6,'0')||
                          LPad(vr_tab_crawcta(vr_indcrawcta).nrctabbd,13,'0')||
                          ' '||
                          RPad(pr_rwcrapcop.nmrescop,30,' ')||
                          RPad(' ',80,' ')||
                          '00000001'||
                          vr_dtmvtolt||
                          vr_dtmvtolt||
                          RPad(' ',33,' ');

              -- Escreve linha no arquivo...
              gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text  => vr_linha);    --> Texto para escrita

            END IF; --IF vr_tab_crawcta(vr_indcrawcta).reg = 1 THEN

            /* Localiza Tarifa */
            OPEN cr_crapcco ( pr_cdcooper => pr_cdcooper
                             ,pr_nrconven => vr_tab_crawcta(vr_indcrawcta).nrconven);
            FETCH cr_crapcco INTO rw_crapcco;
            -- se não encontrar, o valor da tarifa será zerado, caso contrario, assume o valor da tabela
            IF cr_crapcco%NOTFOUND THEN
              vr_vltarifa := 0;
            ELSE
              vr_vltarifa := Nvl(rw_crapcco.vlrtarif,0) * 100;
            END IF;
            -- fechando o cursor
            CLOSE cr_crapcco;

            --incrementando a quantidade de registros
            vr_qtregist := Nvl(vr_qtregist,0) + 1;

            -- Verifica a variavel vr_dsstring
            IF   SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,14,1) = 'T' THEN
              --31012014
              /* o valor da tarifa ja eh substituido na string
                 durante a leitura do arquivo na chamada da b1wgen0153 */
              vr_dsstring := SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,1,8) ||
                             lpad(vr_qtregist,5,'0') ||
                             SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,14,200) ||
                             SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,214,27);


            ELSIF SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,14,1) = 'U' THEN -- Verifica a variavel vr_dsstring
              -- calculando o valor liquido
              vr_vlliquid := SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,78,15) -
                             vr_vltarifa;

              -- ajusta o valor liquido caso seja negativo
              IF Nvl(vr_vlliquid,0) < 0 THEN
                vr_vlliquid := 0;
              END IF;

              vr_dsstring := SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,1,8)||
                            lpad(vr_qtregist,5,'0')          ||
                            SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,14,79)||
                            lpad(Nvl(vr_vlliquid,0),15,'0')||
                            SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,108,38)||
                            vr_dtmvtopr ||
                            SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,154,87);
            ELSE
              vr_dsstring := SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,1,8)||
                            lpad(vr_qtregist,5,'0') ||
                            SUBSTR(vr_tab_crawcta(vr_indcrawcta).dsstring,14,227);

            END IF;---- Verifica a variavel vr_dsstring

            -- Escreve linha no arquivo...
            gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text  => vr_dsstring); --> Texto para escrita

            -- Verifica se é last-of
            IF vr_tab_crawcta(vr_indcrawcta).reg = Nvl(vr_tab_crawcta(vr_indcrawcta).qtde_reg,0) THEN

              /******** TRAILER DO LOTE ************/
              vr_linha := '00100015' ||
                          '         ' ||
                          LPad(vr_qtregist+2, 6, '0') ||
                          LPad('0',123,'0') ||
                          lpad(' ',094,' ');

              -- Escreve linha no arquivo...
              gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text  => vr_linha);    --> Texto para escrita

              /******** TRAILER DO ARQUIVO ************/
              vr_linha := '00199999' ||
                          '         ' ||
                          '000001' ||
                          LPad(vr_qtregist+4, 6, '0') ||
                          '000000' ||
                          lpad(' ',156,' ') ||
                          lpad('0',029,'0') ||
                          lpad(' ',020,' ');

              -- Escreve linha no arquivo...
              gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text  => vr_linha);    --> Texto para escrita

              -- fechando o arquivo
              gene0001.pc_fecha_arquivo(pr_utlfileh  => vr_input_file);

              -- Converter para DOS
              gene0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                          ,pr_nmarquiv => vr_caminho_cooper||'/arq/'||vr_nmarqind
                                          ,pr_nmarqenv => vr_nmarqind
                                          ,pr_des_erro => pr_dscritic);
              IF pr_dscritic IS NOT NULL THEN
                RETURN;
              END IF;

              -- Comando para mover o arquivo para a pasta salvar
              vr_ind_comando := vr_ind_comando + 1;
              vr_tab_comando.extend;
              vr_tab_comando(vr_ind_comando) := 'mv '||vr_caminho_cooper||'/arq/'||vr_nmarqind||' '||vr_caminho_salvar||' 2> /dev/null';

              -- código da critica
              vr_cdcritic := 655;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              -- inicializa a variavel de e-mail
              vr_dsdemail := ' ';
              -- se encontrou dados na crapceb
              IF vr_crapceb THEN
                -- busca o endereco de e-mail
                OPEN cr_crapcem ( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapceb.nrdconta
                                 ,pr_cddemail => rw_crapceb.cddemail);
                FETCH cr_crapcem INTO rw_crapcem;
                -- se encontrar dados na crapcem
                IF cr_crapcem%FOUND THEN
                  vr_dsdemail :=  rw_crapcem.dsdemail;
                END IF;
                -- fecha o cursor
                CLOSE cr_crapcem;
              END IF;
              -- se tem endereço de e-mail
              IF trim(vr_dsdemail) IS NOT NULL THEN
                --Enviar Email
                gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                          ,pr_cdprogra        => pr_cdprogra
                                          ,pr_des_destino     => vr_dsdemail
                                          ,pr_des_assunto     => 'ARQUIVO DE COBRANCA DA ' || pr_rwcrapcop.nmrescop
                                          ,pr_des_corpo       => ' '
                                          ,pr_des_anexo       => vr_caminho_cooper||'/converte/'||vr_nmarqind
                                          ,pr_flg_log_batch   => 'N' --> Não gerar no LOG
                                          ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                          ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                          ,pr_flg_enviar      => 'N' --> Enviar o e-mail na hora
                                          ,pr_des_erro        => pr_dscritic);

                IF trim(pr_dscritic) IS NOT NULL THEN
                  -- retorna o processamento para o programa chamador
                  RETURN;
                END IF;
              END IF;

            END IF;
            -- vai para o proximo registro do arquivo
            vr_indcrawcta := vr_tab_crawcta.NEXT(vr_indcrawcta);
          END LOOP;
        END;
      END pc_gera_arquivo;

      /*************************************************************************
          Objetivo: Geracao dos relatorios 325 - Acompanhamento da integracao
                    dos boletos por convenio
      *************************************************************************/
      PROCEDURE pc_gera_relatorios_325(  pr_cdcooper IN crapcop.cdcooper%type
                                        ,pr_dtmvtolt IN DATE
                                        ,pr_dtmvtopr IN DATE
                                        ,pr_cdprogra IN VARCHAR2
                                        ,pr_tab_cratarq IN typ_tab_cratarq
                                        ,pr_tab_cratrej IN typ_tab_cratrej
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                        ,pr_dscritic OUT VARCHAR2) IS
      BEGIN
        /*************************************************************************
            Objetivo: Geracao dos relatorios 325 - Acompanhamento da integracao
                      dos boletos por convenio
        *************************************************************************/
        DECLARE
          vr_indcratarq VARCHAR2(100);
          vr_indcratrej VARCHAR2(100);
          vr_nmarqimp   VARCHAR2(200);
          vr_dshistor   VARCHAR2(200);
          vr_contador   INTEGER;
          vr_qtderegistros  INTEGER;
          -- controle de migrados
          vr_indmigracaocob VARCHAR2(100);
          vr_indmigraaux    VARCHAR2(100);
          vr_tab_auxmigra   typ_tab_migracaocob;
          vr_cdcooper       crapcop.cdcooper%TYPE;
          vr_qttitmig       NUMBER;
          vr_vllanmto       NUMBER;
          vr_vlrtarif       NUMBER;
          vr_nmarqlog   VARCHAR2(100);

          -- Procedure para reordenar a temp-table vr_tab_migracaocob
          PROCEDURE pc_reordena(pr_tab_migra IN OUT typ_tab_migracaocob) IS
          BEGIN
            DECLARE
              vr_indatual VARCHAR2(100);
              vr_indnovo  VARCHAR2(100);
              vr_tab_rel  typ_tab_migracaocob;
            BEGIN
              -- posiciona no primeiro registro da tabela
              vr_indatual := pr_tab_migra.first;

              -- percorre a tabela temporaria
              WHILE vr_indatual IS NOT NULL LOOP
                -- se os boletos forem do arquivo que esta sendo processado
                IF pr_tab_migra(vr_indatual).nmarquiv = pr_tab_cratarq(vr_indcratarq).nmarquiv THEN

                  -- gerando o novo indice
                  vr_indnovo := lpad(pr_tab_migra(vr_indatual).nmarquiv,50,'#')||
                                lpad(pr_tab_migra(vr_indatual).cdcopdst,10,'0')||
                                lpad(pr_tab_migra(vr_indatual).nrctadst,10,'0')||
                                lpad(vr_tab_rel.count()+1,5,'0');

                  vr_tab_rel(vr_indnovo).nrdctabb := pr_tab_migra(vr_indatual).nrdctabb;
                  vr_tab_rel(vr_indnovo).cdcopdst := pr_tab_migra(vr_indatual).cdcopdst;
                  vr_tab_rel(vr_indnovo).nrctadst := pr_tab_migra(vr_indatual).nrctadst;
                  vr_tab_rel(vr_indnovo).cdagedst := pr_tab_migra(vr_indatual).cdagedst;
                  vr_tab_rel(vr_indnovo).cdhistor := pr_tab_migra(vr_indatual).cdhistor;
                  vr_tab_rel(vr_indnovo).vllanmto := pr_tab_migra(vr_indatual).vllanmto;
                  vr_tab_rel(vr_indnovo).vlrtarif := pr_tab_migra(vr_indatual).vlrtarif;
                  vr_tab_rel(vr_indnovo).dsorgarq := pr_tab_migra(vr_indatual).dsorgarq;
                  vr_tab_rel(vr_indnovo).nroconve := pr_tab_migra(vr_indatual).nroconve;
                  vr_tab_rel(vr_indnovo).nmrescop := pr_tab_migra(vr_indatual).nmrescop;
                  vr_tab_rel(vr_indnovo).qttitmig := pr_tab_migra(vr_indatual).qttitmig;
                  vr_tab_rel(vr_indnovo).nmarquiv := pr_tab_migra(vr_indatual).nmarquiv;
                END IF;--IF pr_tab_migra(vr_indatual).nmarquiv = pr_tab_cratarq(vr_indcratarq).nmarquiv AND

                -- vai para o proximo registro
                vr_indatual := pr_tab_migra.NEXT(vr_indatual);
              END LOOP; /* WHILE vr_indatual IS NOT NULL LOOP */

              -- retorna a tabela reordenada
              pr_tab_migra := vr_tab_rel;
            END;
          END pc_reordena;

        -- inicio do programa
        BEGIN
          vr_nmarqlog := gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE');

          -- inicializando as variaveis de controle
          pr_cdcritic := 0;
          -- inicializando o contador de arquivos gerados
          vr_contador := 1;
          -- posicionando no primeiro registro da temp-table
          vr_indcratarq := pr_tab_cratarq.first;
          -- percorrendo a tabela temporaria
          WHILE vr_indcratarq IS NOT NULL LOOP
            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            -- ajusta o nome do aqrquivo
            vr_nmarqimp := 'crrl325_' || lpad(vr_contador,3,'0') || '.lst';
            -- inicializando o flag que indica se tem rejeitados
            vr_flgrejei := FALSE;
            -------------------------------------------
            -- Iniciando a geração do XML
            -------------------------------------------
            pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl325><arquivos idarquivo="'||vr_indcratarq||'" '||
                           'nmarquiv="'||pr_tab_cratarq(vr_indcratarq).nmarquiv||'" '||
                           'cdagenci="'||pr_tab_cratarq(vr_indcratarq).cdagenci||'" '||
                           'nrdolote="'||to_char(pr_tab_cratarq(vr_indcratarq).nrdolote,'fm999G999G999')||'" '||
                           'nroconve="'||lpad(pr_tab_cratarq(vr_indcratarq).nroconve,8,'0')||'" '||
                           'cdbccxlt="'||pr_tab_cratarq(vr_indcratarq).cdbccxlt||'" '||
                           'tplotmov="'||lpad(pr_tab_cratarq(vr_indcratarq).tplotmov,2,'0')||'" '||
                           'dtmvtopr="'||To_Char(pr_dtmvtopr,'dd/mm/yyyy')||'" '||
                           'qtregrec="'||to_char(pr_tab_cratarq(vr_indcratarq).qtregrec,'fm999G999G999')||'" '||
                           'qtregrej="'||to_char(pr_tab_cratarq(vr_indcratarq).qtregrej,'fm999G999G999')||'" '||
                           'vlregisd="'||pr_tab_cratarq(vr_indcratarq).vlregisd||'" '||
                           'qtregicd="'||to_char(pr_tab_cratarq(vr_indcratarq).qtregicd,'fm999G999G999')||'" '||
                           'vlregrec="'||pr_tab_cratarq(vr_indcratarq).vlregrec||'" '||
                           'vlregrej="'||pr_tab_cratarq(vr_indcratarq).vlregrej||'" '||
                           'qtregisd="'||pr_tab_cratarq(vr_indcratarq).qtregisd||'" '||
                           'vlregicd="'||pr_tab_cratarq(vr_indcratarq).vlregicd||'" '||
                           'vltarifa="'||pr_tab_cratarq(vr_indcratarq).vltarifa||'" '||
                           'qtdmigra="'||to_char(pr_tab_cratarq(vr_indcratarq).qtdmigra,'fm999G999G999')||'" '||
                           'vlrmigra="'||pr_tab_cratarq(vr_indcratarq).vlrmigra||'" '||
                           'nmarqimp="'||vr_nmarqimp||'">'
                           );

            -- posicionando no primeiro registro
            vr_indcratrej := pr_tab_cratrej.first;
            -- busca a quantidade de registros da tabela temporaria
            vr_qtderegistros := pr_tab_cratrej.count();
            -- percorrendo a tabela temporaria
            WHILE vr_indcratrej IS NOT NULL LOOP
              -- só processa o arquivo que está apontado na tabela de arquivos
              IF pr_tab_cratrej(vr_indcratrej).nmarquiv = pr_tab_cratarq(vr_indcratarq).nmarquiv THEN
                --  indica que tem rejeitados
                vr_flgrejei := TRUE;

                -- marcando o codigo da crítica
                pr_cdcritic := pr_tab_cratrej(vr_indcratrej).cdcritic;

                -- se o codigo da critica eh 999, indica qie é associado da viacredi
                IF pr_cdcritic = 999 THEN
                  pr_dscritic := 'Rejeitado - Associado VIACREDI';
                ELSE
                  -- senao busca a descricao da critica do cadastro
                  pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
                END IF;

                -- inicializando o historico
                vr_dshistor := ' ';

                /** Boleto pago c/ cheque **/
                IF pr_tab_cratrej(vr_indcratrej).cdcritic = 922  AND
                   trim(pr_tab_cratrej(vr_indcratrej).dshistor) IS NOT NULL THEN
                   -- setando o valor do histórico
                   vr_dshistor := pr_tab_cratrej(vr_indcratrej).dshistor;
                END IF;
                -- excreve xml
                pc_escreve_xml('<rejeitados id="'||vr_indcratrej||'">'||
                                  '<nrseqdig>'||to_char(pr_tab_cratrej(vr_indcratrej).nrseqdig, 'fm999G999G999')||'</nrseqdig>'||
                                  '<nrdocmto>'||to_char(pr_tab_cratrej(vr_indcratrej).nrdocmto,'fm999G999G999')||'</nrdocmto>'||
                                  '<vllanmto>'||pr_tab_cratrej(vr_indcratrej).vllanmto||'</vllanmto>'||
                                  '<cdagenci>'||pr_tab_cratrej(vr_indcratrej).cdagenci||'</cdagenci>'||
                                  '<nrdconta>'||gene0002.fn_mask_conta(pr_tab_cratrej(vr_indcratrej).nrdconta)||'</nrdconta>'||
                                  '<cdpesqbb>'||Trim(pr_tab_cratrej(vr_indcratrej).cdpesqbb)||'</cdpesqbb>'||
                                  '<cdbccxlt>'||pr_tab_cratrej(vr_indcratrej).cdbccxlt||'</cdbccxlt>'||
                                  '<nrdolote>'||pr_tab_cratrej(vr_indcratrej).nrdolote||'</nrdolote>'||
                                  '<dshistor>'||vr_dshistor||'</dshistor>'||
                                  '<dscritic>'||pr_dscritic||'</dscritic>'||
                               '</rejeitados>');
              END IF;

              -- vai para a proxima iteracao
              vr_indcratrej := pr_tab_cratrej.NEXT(vr_indcratrej);

            END LOOP; /* WHILE vr_indcratrej IS NOT NULL LOOP */

            -- se não tem rejeitados, cria uma linha em branco no xml para que tenha
            -- ao menos uma linha de detalhe no xml
            IF NOT vr_flgrejei THEN
              pc_escreve_xml('<rejeitados id="000000">'||
                                '<nrseqdig>0</nrseqdig>'||
                                '<nrdocmto>0</nrdocmto>'||
                                '<vllanmto>0</vllanmto>'||
                                '<cdagenci>0</cdagenci>'||
                                '<nrdconta>0</nrdconta>'||
                                '<cdpesqbb>0</cdpesqbb>'||
                                '<cdbccxlt>0</cdbccxlt>'||
                                '<nrdolote>0</nrdolote>'||
                                '<dshistor>0</dshistor>'||
                                '<dscritic>0</dscritic>'||
                             '</rejeitados>');
            END IF;--IF NOT vr_flgrejei THEN

            -- se tem titulos migrados, soma as tarifas
            IF nvl(pr_tab_cratarq(vr_indcratarq).qtdmigra,0) > 0 THEN
              -- zerando as variaveis de controle
              vr_qttitmig := 0;
              vr_vllanmto := 0;
              vr_vlrtarif := 0;
              -- recebe o conteudo da tabela que deve ser reordenada
              vr_tab_auxmigra := vr_tab_migracaocob;
              -- reordena a tabela temporaria das contas migradas
              pc_reordena(pr_tab_migra => vr_tab_auxmigra);
              -- posicionando no primeiro registro
              vr_indmigracaocob := vr_tab_auxmigra.FIRST;
              -- inicializando a variavel de controle
              IF vr_indmigracaocob IS NOT NULL THEN
              vr_cdcooper := vr_tab_auxmigra(vr_indmigracaocob).cdcopdst;
              END IF;
              -- percorrendo a tabela temporaria
              WHILE vr_indmigracaocob IS NOT NULL LOOP
                -- controle de first-of. Enquanto não mudar a cooperativa, acumula os valores
                IF vr_cdcooper = vr_tab_auxmigra(vr_indmigracaocob).cdcopdst THEN
                  vr_qttitmig := Nvl(vr_qttitmig,0) + Nvl(vr_tab_auxmigra(vr_indmigracaocob).qttitmig,0);
                  vr_vllanmto := Nvl(vr_vllanmto,0) + Nvl(vr_tab_auxmigra(vr_indmigracaocob).vllanmto,0);
                  vr_vlrtarif := Nvl(vr_vlrtarif,0) + Nvl(vr_tab_auxmigra(vr_indmigracaocob).vlrtarif,0);
                ELSE
                  -- gerando o registro de totalizacao das migracoes por cooperativa
                  pc_escreve_xml( '<migrados id="'||vr_tab_auxmigra(vr_indmigracaocob).cdcopdst||'">'||
                                    '<m_cdcopdst>'||vr_tab_auxmigra(vr_indmigracaocob).cdcopdst||'</m_cdcopdst>'||
                                    '<m_nmrescop>'||vr_tab_auxmigra(vr_indmigracaocob).nmrescop||'</m_nmrescop>'||
                                    '<m_qttitmig>'||vr_qttitmig||'</m_qttitmig>'||
                                    '<m_vllanmto>'||vr_vllanmto||'</m_vllanmto>'||
                                    '<m_vlrtarif>'||vr_vlrtarif||'</m_vlrtarif>'||
                                  '</migrados>'
                                );
                  -- zerando as variaveis de controle
                  vr_qttitmig := 0;
                  vr_vllanmto := 0;
                  vr_vlrtarif := 0;
                END IF;

                -- armazena o codigo da cooperativa atual
                vr_cdcooper := vr_tab_auxmigra(vr_indmigracaocob).cdcopdst;

                -- armazena o indice atual
                vr_indmigraaux := vr_indmigracaocob;

                -- vai para a proxima iteracao
                vr_indmigracaocob := vr_tab_auxmigra.NEXT(vr_indmigracaocob);
              END LOOP;--WHILE vr_indmigracaocob IS NOT NULL LOOP
              -- se ainda tem valor é porque nao foi gerado o valor
              IF vr_qttitmig > 0 THEN
                -- gerando o registro de totalizacao das migracoes por cooperativa
                pc_escreve_xml( '<migrados id="'||vr_tab_auxmigra(vr_indmigraaux).cdcopdst||'">'||
                                  '<m_cdcopdst>'||vr_tab_auxmigra(vr_indmigraaux).cdcopdst||'</m_cdcopdst>'||
                                  '<m_nmrescop>'||vr_tab_auxmigra(vr_indmigraaux).nmrescop||'</m_nmrescop>'||
                                  '<m_qttitmig>'||vr_qttitmig||'</m_qttitmig>'||
                                  '<m_vllanmto>'||vr_vllanmto||'</m_vllanmto>'||
                                  '<m_vlrtarif>'||vr_vlrtarif||'</m_vlrtarif>'||
                                '</migrados>'
                              );
                -- zerando as variaveis de controle
                vr_qttitmig := 0;
                vr_vllanmto := 0;
                vr_vlrtarif := 0;
              END IF;
            END IF;

            -- finalizando o arquivo
            pc_escreve_xml('</arquivos></crrl325>');

            -- se encontrou rejeitados, atribui o codigo da critica
            IF vr_flgrejei THEN
              pr_cdcritic := 191;
            ELSE
              pr_cdcritic := 190;
            END IF;

            -- busca a descricao da critica
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||
                           ' --> ' ||
                           pr_tab_cratarq(vr_indcratarq).nmarquiv;

            -- excevendo no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || pr_cdprogra || ' --> '
                                                       || pr_dscritic);
            -- reinicializando o codigo da critica
            pr_cdcritic := 0;

            -- Gerando o relatório
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                      ,pr_cdprogra  => pr_cdprogra
                                      ,pr_dtmvtolt  => pr_dtmvtolt
                                      ,pr_dsxml     => vr_des_xml
                                      ,pr_dsxmlnode => '/crrl325/arquivos'
                                      ,pr_dsjasper  => 'crrl325.jasper'
                                      ,pr_dsparams  => ' '
                                      ,pr_dsarqsaid => vr_caminho_cooper ||'/rl/'|| vr_nmarqimp
                                      ,pr_flg_gerar => 'S'
                                      ,pr_qtcoluna  => 132
                                      ,pr_sqcabrel  => 1
                                      ,pr_flg_impri => 'S'
                                      ,pr_nrcopias  => 1
                                      ,pr_des_erro  => pr_dscritic);

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

            -- incrementa o contador de arquivos
            vr_contador := Nvl(vr_contador,0) + 1;

            -- vai para a proxima iteracao
            vr_indcratarq := pr_tab_cratarq.NEXT(vr_indcratarq);
          END LOOP; /* WHILE vr_indcratarq IS NOT NULL */
        END;
      END pc_gera_relatorios_325;

      /*************************************************************************
          Objetivo: Geracao dos relatorios 627 - Acompanhamento da integracao
                    dos boletos pagos com cheque - cob. sem registro BB
      *************************************************************************/
      PROCEDURE pc_gera_relatorios_627( pr_cdcooper IN crapcop.cdcooper%type
                                       ,pr_dtmvtolt IN DATE
                                       ,pr_dtmvtopr IN DATE
                                       ,pr_cdprogra IN VARCHAR2
                                       ,pr_tab_cratarq IN typ_tab_cratarq
                                       ,pr_tab_regimp IN typ_tab_regimp
                                       ,pr_dsdircop  IN VARCHAR2
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                       ,pr_dscritic OUT VARCHAR2) IS
      BEGIN
        /*************************************************************************
            Objetivo: Geracao dos relatorios 627 - Acompanhamento da integracao
                      dos boletos pagos com cheque - cob. sem registro BB
        *************************************************************************/
        DECLARE
          vr_flcopctl   BOOLEAN;
          vr_flg_impri  CHAR(1);
          vr_indcratarq VARCHAR2(100);
          vr_contador   INTEGER;
          vr_dircecred  VARCHAR2(200);
          vr_tab_auxregimp    typ_tab_regimp;

          -- Procedure para reordenar o relatório
          PROCEDURE pc_reordena(pr_tab_reg IN OUT typ_tab_regimp) IS
          BEGIN
            DECLARE
              vr_indatual VARCHAR2(100);
              vr_indnovo  VARCHAR2(100);
              vr_tab_rel  typ_tab_regimp;
            BEGIN
              -- posiciona no primeiro registro da tabela
              vr_indatual := pr_tab_reg.first;

              -- percorre a tabela temporaria
              WHILE vr_indatual IS NOT NULL LOOP
                -- se os boletos forem do arquivo que esta sendo processado
                IF pr_tab_reg(vr_indatual).nmarquiv = pr_tab_cratarq(vr_indcratarq).nmarquiv AND
                   pr_tab_reg(vr_indatual).flpagchq = TRUE THEN

                  -- gerando o novo indice
                  vr_indnovo := lpad(pr_tab_reg(vr_indatual).nmarquiv,50,'#')||
                                lpad(pr_tab_reg(vr_indatual).cdocorre,10,'0')||
                                lpad(pr_tab_reg(vr_indatual).nrdconta,10,'0')||
                                lpad(vr_tab_rel.count()+1,5,'0');

                  vr_tab_rel(vr_indnovo).cdcooper := pr_tab_reg(vr_indatual).cdcooper;
                  vr_tab_rel(vr_indnovo).codbanco := pr_tab_reg(vr_indatual).codbanco;
                  vr_tab_rel(vr_indnovo).nroconve := pr_tab_reg(vr_indatual).nroconve;
                  vr_tab_rel(vr_indnovo).cdagenci := pr_tab_reg(vr_indatual).cdagenci;
                  vr_tab_rel(vr_indnovo).nrdctabb := pr_tab_reg(vr_indatual).nrdctabb;
                  vr_tab_rel(vr_indnovo).nrdocmto := pr_tab_reg(vr_indatual).nrdocmto;
                  vr_tab_rel(vr_indnovo).vllanmto := pr_tab_reg(vr_indatual).vllanmto;
                  vr_tab_rel(vr_indnovo).vlrtarif := pr_tab_reg(vr_indatual).vlrtarif;
                  vr_tab_rel(vr_indnovo).dtpagto  := pr_tab_reg(vr_indatual).dtpagto ;
                  vr_tab_rel(vr_indnovo).nrctares := pr_tab_reg(vr_indatual).nrctares;
                  vr_tab_rel(vr_indnovo).nrseqdig := pr_tab_reg(vr_indatual).nrseqdig;
                  vr_tab_rel(vr_indnovo).nrdolote := pr_tab_reg(vr_indatual).nrdolote;
                  vr_tab_rel(vr_indnovo).nrdconta := pr_tab_reg(vr_indatual).nrdconta;
                  vr_tab_rel(vr_indnovo).codmoeda := pr_tab_reg(vr_indatual).codmoeda;
                  vr_tab_rel(vr_indnovo).identifi := pr_tab_reg(vr_indatual).identifi;
                  vr_tab_rel(vr_indnovo).codcarte := pr_tab_reg(vr_indatual).codcarte;
                  vr_tab_rel(vr_indnovo).juros    := pr_tab_reg(vr_indatual).juros   ;
                  vr_tab_rel(vr_indnovo).vlabatim := pr_tab_reg(vr_indatual).vlabatim;
                  vr_tab_rel(vr_indnovo).incnvaut := pr_tab_reg(vr_indatual).incnvaut;
                  vr_tab_rel(vr_indnovo).dsorgarq := pr_tab_reg(vr_indatual).dsorgarq;
                  vr_tab_rel(vr_indnovo).nrcnvceb := pr_tab_reg(vr_indatual).nrcnvceb;
                  vr_tab_rel(vr_indnovo).cdpesqbb := pr_tab_reg(vr_indatual).cdpesqbb;
                  vr_tab_rel(vr_indnovo).cdbanpag := pr_tab_reg(vr_indatual).cdbanpag;
                  vr_tab_rel(vr_indnovo).cdagepag := pr_tab_reg(vr_indatual).cdagepag;
                  vr_tab_rel(vr_indnovo).nmarquiv := pr_tab_reg(vr_indatual).nmarquiv;
                  vr_tab_rel(vr_indnovo).inarqcbr := pr_tab_reg(vr_indatual).inarqcbr;
                  vr_tab_rel(vr_indnovo).dtdgerac := pr_tab_reg(vr_indatual).dtdgerac;
                  vr_tab_rel(vr_indnovo).flpagchq := pr_tab_reg(vr_indatual).flpagchq;
                  vr_tab_rel(vr_indnovo).dcmc7chq := pr_tab_reg(vr_indatual).dcmc7chq;
                  vr_tab_rel(vr_indnovo).dscheque := pr_tab_reg(vr_indatual).dscheque;
                  vr_tab_rel(vr_indnovo).cdocorre := pr_tab_reg(vr_indatual).cdocorre;
                  vr_tab_rel(vr_indnovo).vldpagto := pr_tab_reg(vr_indatual).vldpagto;
                  vr_tab_rel(vr_indnovo).vltarbco := pr_tab_reg(vr_indatual).vltarbco;
                  vr_tab_rel(vr_indnovo).cdhistor := pr_tab_reg(vr_indatual).cdhistor;
                  vr_tab_rel(vr_indnovo).cdfvlcop := pr_tab_reg(vr_indatual).cdfvlcop;
                  vr_tab_rel(vr_indnovo).first_of := pr_tab_reg(vr_indatual).first_of;
                  vr_tab_rel(vr_indnovo).last_of  := pr_tab_reg(vr_indatual).last_of ;
                END IF;--IF pr_tab_reg(vr_indatual).nmarquiv = pr_tab_cratarq(vr_indcratarq).nmarquiv AND

                -- vai para o proximo registro
                vr_indatual := pr_tab_reg.NEXT(vr_indatual);
              END LOOP; /* WHILE vr_indatual IS NOT NULL LOOP */

              -- retorna a tabela reordenada
              pr_tab_reg := vr_tab_rel;
            END;
          END pc_reordena;

        BEGIN
          --inicializando as variaveis de controle
          pr_cdcritic := 0;
          vr_contador := 0;

          -- recebe o conteudo da tabela que deve ser reordenada
          vr_tab_auxregimp := pr_tab_regimp;

          -- posicionando no primeiro registro da temp-table
          vr_indcratarq := pr_tab_cratarq.first;

          --
          WHILE vr_indcratarq IS NOT NULL LOOP
            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            -- incrementando a quantidade de arquivos
            vr_contador := Nvl(vr_contador,0) + 1;

            -- ajusta o nome do aqrquivo
            vr_nmarqimp := 'crrl627_' || lpad(vr_contador,3,'0') || '.lst';

            -- variável de controle para informar se existe informacoes
            -- para serem impressas no relatorio
            vr_flcopctl  := FALSE;
            vr_flg_impri := 'S';

            -------------------------------------------
            -- Iniciando a geração do XML
            -------------------------------------------
            pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl627><arquivos idarquivo="'||vr_indcratarq||'">'||
                           '<nmarquiv>'||pr_tab_cratarq(vr_indcratarq).nmarquiv||'</nmarquiv>'||
                           '<cdagenci>'||pr_tab_cratarq(vr_indcratarq).cdagenci||'</cdagenci>'||
                           '<nrdolote>'||to_char(pr_tab_cratarq(vr_indcratarq).nrdolote,'fm999G999G999')||'</nrdolote>'||
                           '<nroconve>'||lpad(pr_tab_cratarq(vr_indcratarq).nroconve,8,'0')||'</nroconve>'||
                           '<cdbccxlt>'||pr_tab_cratarq(vr_indcratarq).cdbccxlt||'</cdbccxlt>'||
                           '<tplotmov>'||lpad(pr_tab_cratarq(vr_indcratarq).tplotmov,2,'0')||'</tplotmov>'||
                           '<dtmvtopr>'||To_Char(pr_dtmvtopr,'dd/mm/yyyy')||'</dtmvtopr>'
                           );

            -- Carregando a temp-table de titulos
            vr_tab_auxregimp := pr_tab_regimp;

            -- Reordenando e filtrando a tabela temporaria
            pc_reordena(pr_tab_reg => vr_tab_auxregimp);

            -- posiciona no primeiro registro da tabela
            vr_indregimp := vr_tab_auxregimp.first;

            -- percorre a tabela temporaria
            WHILE vr_indregimp IS NOT NULL LOOP

              vr_flcopctl := TRUE;

              -- verifica o codigo da ocorrencia
              IF vr_tab_auxregimp(vr_indregimp).cdocorre = 6 THEN
                vr_dsocorre := '==> Cheques compensados em D-0';
              ELSIF vr_tab_auxregimp(vr_indregimp).cdocorre = 44 THEN
                vr_dsocorre := '==> Cheques devolvidos';
              ELSIF vr_tab_auxregimp(vr_indregimp).cdocorre = 50 THEN
                vr_dsocorre := '==> Cheques pendentes de compensacao';
              ELSIF vr_tab_auxregimp(vr_indregimp).cdocorre <> 6  AND
                    vr_tab_auxregimp(vr_indregimp).cdocorre <> 44 AND
                    vr_tab_auxregimp(vr_indregimp).cdocorre <> 50 THEN

                vr_dsocorre := '==> Ocorrencia nao encontrada ' ||vr_tab_auxregimp(vr_indregimp).cdocorre;
              END IF;--IF vr_tab_auxregimp(vr_indregimp).cdocorre = 6 THEN

              -- escreve xml
              pc_escreve_xml('<lancamentos id="'||vr_indregimp||'">'||
                               '<nrseqdig>'||to_char(vr_tab_auxregimp(vr_indregimp).nrseqdig,'fm999G999G999')||'</nrseqdig>'||
                               '<nrdocmto>'||to_char(vr_tab_auxregimp(vr_indregimp).nrdocmto,'fm999G999G999')||'</nrdocmto>'||
                               '<vllanmto>'||to_char(vr_tab_auxregimp(vr_indregimp).vldpagto,'fm999G999G990D00')||'</vllanmto>'||
                               '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_auxregimp(vr_indregimp).nrdconta)||'</nrdconta>'||
                               '<cdpesqbb>'||vr_tab_auxregimp(vr_indregimp).cdpesqbb||'</cdpesqbb>'||
                               '<dscheque>'||vr_tab_auxregimp(vr_indregimp).dscheque||'</dscheque>'||
                               '<dsocorre>'||vr_dsocorre||'</dsocorre>'||
                             '</lancamentos>');

              -- proxima iteração
              vr_indregimp := vr_tab_auxregimp.NEXT(vr_indregimp);
            END LOOP; /* WHILE vr_indregimp IS NOT NULL LOOP */

            -- se não tem nenhum documento associado, gera um registro vazio para
            -- gerar as informações do cabecalho no iReport
            IF NOT vr_flcopctl THEN

              -- indica que não é pra gerar o pdf
              vr_flg_impri := 'N';

              -- excreve xml
              pc_escreve_xml('<lancamentos id="0">'||
                               '<nrseqdig>0</nrseqdig>'||
                               '<nrdocmto>0</nrdocmto>'||
                               '<vllanmto>0</vllanmto>'||
                               '<nrdconta>0</nrdconta>'||
                               '<cdpesqbb>0</cdpesqbb>'||
                               '<dscheque>0</dscheque>'||
                               '<dsocorre>0</dsocorre>'||
                             '</lancamentos>');
            END IF;
            -------------------------------------------
            -- Finalizando o XML
            -------------------------------------------
            pc_escreve_xml('</arquivos></crrl627>');

            -- Gerando o relatório na cooperativa logada
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                      ,pr_cdprogra  => pr_cdprogra
                                      ,pr_dtmvtolt  => pr_dtmvtolt
                                      ,pr_dsxml     => vr_des_xml
                                      ,pr_dsxmlnode => '/crrl627/arquivos/lancamentos'
                                      ,pr_dsjasper  => 'crrl627.jasper'
                                      ,pr_dsparams  => ' '
                                      ,pr_dsarqsaid => vr_caminho_cooper ||'/rl/'|| vr_nmarqimp
                                      ,pr_flg_gerar => 'S'
                                      ,pr_qtcoluna  => 132
                                      ,pr_sqcabrel  => 2
                                      ,pr_flg_impri => vr_flg_impri
                                      ,pr_nrcopias  => 1
                                      ,pr_des_erro  => pr_dscritic);

            /* se relatorio contem informacoes, copiar relatorio para central */
            IF  vr_flcopctl THEN

              -- retorna a descricao do patch da cecred
              vr_dircecred := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => 3
                                                 ,pr_nmsubdir => 'rl');

              -- renomeando o arquivo para gerar o pdf na cooperativa central
              vr_nmarqimp := 'crrl627_' ||pr_dsdircop || '_' || lpad(vr_contador,3,'0') || '.lst';

              /* gerar documento pdf na intranet para central */
              gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                        ,pr_cdprogra  => pr_cdprogra
                                        ,pr_dtmvtolt  => pr_dtmvtolt
                                        ,pr_dsxml     => vr_des_xml
                                        ,pr_dsxmlnode => '/crrl627/arquivos/lancamentos'
                                        ,pr_dsjasper  => 'crrl627.jasper'
                                        ,pr_dsparams  => ' '
                                        ,pr_dsarqsaid => vr_caminho_cooper ||'/rl/'||vr_nmarqimp --vr_dircecred||'/'||vr_nmarqimp
                                        ,pr_flg_gerar => 'N'
                                        ,pr_qtcoluna  => 132
                                        ,pr_sqcabrel  => 2
                                        ,pr_flg_impri => 'N'
                                        ,pr_nmformul  => '132col'
                                        ,pr_nrcopias  => 1
                                        ,pr_flgremarq => 'S'    --> Flag para remover o arquivo após cópia/email
                                        ,pr_dspathcop => vr_dircecred /*local onde deve ser criado o arquivo*/
                                        ,pr_dsextcop  => 'pdf' --> Extensão para cópia do relatório aos diretórios
                                        ,pr_des_erro  => pr_dscritic);

            END IF;

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

            -- proxima iteração
            vr_indcratarq := pr_tab_cratarq.NEXT(vr_indcratarq);
          END LOOP; /* FOR EACH cratarq: */
        END; -- DECLARE -- BEGIN
      END pc_gera_relatorios_627; /* fim gera_relatorios_627 */

      /* gera relatorio dos rejeitados*/
      PROCEDURE pc_gera_relatorios_325_tco( pr_cdcooper IN crapcop.cdcooper%TYPE
                                           ,pr_dtmvtopr IN DATE
                                           ,pr_cdprogra IN VARCHAR
                                           ,pr_dtmvtolt IN DATE
                                           ,pr_tab_cratarq IN typ_tab_cratarq
                                           ,pr_tab_cratrej IN typ_tab_cratrej
                                           ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                           ,pr_dscritic OUT VARCHAR2) IS
      BEGIN
        DECLARE
          vr_indcratarq VARCHAR2(100);
          vr_indcratrej VARCHAR2(100);
          vr_email_dest VARCHAR2(4000);
          vr_contador   INTEGER;
          vr_nmarqlog   VARCHAR2(100);
        BEGIN
          vr_nmarqlog := gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE');

          -- contador de arquivos
          vr_contador := 0;
          -- posiciona no primeiro registro do arquivo
          vr_indcratarq := pr_tab_cratarq.first;
          -- loop na temp-table
          WHILE vr_indcratarq IS NOT NULL LOOP
            -- Inicializar o CLOB
            dbms_lob.createtemporary(vr_des_xml, TRUE);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            -- incrementando o contador de arquivos
            vr_contador := Nvl(vr_contador,0) + 1;

            -- gerando o nome do arquivo
            vr_nmarqimp := 'crrl325_'||gene0001.fn_param_sistema('CRED',pr_cdcooper,'SUFIXO_RELATO_TOTAL')||'_'||LPad(vr_contador,3,'0') || '.lst';

            -- inicializando a variavel de controle
            vr_flgrejei := FALSE;

            -------------------------------------------
            -- Iniciando a geração do XML
            -------------------------------------------
            pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl325><arquivos idarquivo="'||vr_indcratarq||'">'||
                           '<nmarquiv>'||pr_tab_cratarq(vr_indcratarq).nmarquiv||'</nmarquiv>'||
                           '<cdagenci>'||pr_tab_cratarq(vr_indcratarq).cdagenci||'</cdagenci>'||
                           '<nrdolote>'||to_char(pr_tab_cratarq(vr_indcratarq).nrdolote,'fm999G999G999')||'</nrdolote>'||
                           '<nroconve>'||pr_tab_cratarq(vr_indcratarq).nroconve||'</nroconve>'||
                           '<cdbccxlt>'||pr_tab_cratarq(vr_indcratarq).cdbccxlt||'</cdbccxlt>'||
                           '<tplotmov>'||lpad(pr_tab_cratarq(vr_indcratarq).tplotmov,2,'0')||'</tplotmov>'||
                           '<dtmvtopr>'||To_Char(pr_dtmvtopr,'dd/mm/yyyy')||'</dtmvtopr>'||
                           '<qtregrec>'||'0'||'</qtregrec>'||
                           '<qtregrej>'||pr_tab_cratarq(vr_indcratarq).qtregrej||'</qtregrej>'||
                           '<vlregisd>'||'0'||'</vlregisd>'||
                           '<qtregicd>'||'0'||'</qtregicd>'||
                           '<vlregrec>'||'0'||'</vlregrec>'||
                           '<vlregrej>'||pr_tab_cratarq(vr_indcratarq).vlregrej||'</vlregrej>'||
                           '<qtregisd>'||'0'||'</qtregisd>'||
                           '<vlregicd>'||'0'||'</vlregicd>'||
                           '<vltarifa>'||'0'||'</vltarifa>'||
                           '<qtdmigra>'||pr_tab_cratarq(vr_indcratarq).qtdmigra||'</qtdmigra>'||
                           '<vlrmigra>'||pr_tab_cratarq(vr_indcratarq).vlrmigra||'</vlrmigra>'
                           );

            -- posicionando no primeiro registro
            vr_indcratrej := pr_tab_cratrej.first;
            -- percorrendo a tabela temporaria
            WHILE vr_indcratrej IS NOT NULL LOOP
              -- só processa o arquivo que está apontado na tabela de arquivos
              IF pr_tab_cratrej(vr_indcratrej).cdcritic = 999 AND
                 pr_tab_cratrej(vr_indcratrej).nmarquiv = pr_tab_cratarq(vr_indcratarq).nmarquiv THEN

                -- indica que tem rejeitado
                vr_flgrejei := TRUE;

                pr_cdcritic := pr_tab_cratrej(vr_indcratrej).cdcritic;
                pr_dscritic := 'Rejeitado - Associado VIACREDI';

                -- escreve xml
                pc_escreve_xml('<lancamentos id="'||vr_indcratrej||'">'||
                              '<nrseqdig>'||pr_tab_cratrej(vr_indcratrej).nrseqdig||'</nrseqdig>'||
                              '<nrdocmto>'||to_char(pr_tab_cratrej(vr_indcratrej).nrdocmto,'999G999')||'</nrdocmto>'||
                              '<vllanmto>'||To_Char(pr_tab_cratrej(vr_indcratrej).vllanmto,'fm999G999G990D00')||'</vllanmto>'||
                              '<cdagenci>'||pr_tab_cratrej(vr_indcratrej).cdagenci||'</cdagenci>'||
                              '<nrdconta>'||gene0002.fn_mask_conta(pr_tab_cratrej(vr_indcratrej).nrdconta)||'</nrdconta>'||
                              '<cdpesqbb>'||pr_tab_cratrej(vr_indcratrej).cdpesqbb||'</cdpesqbb>'||
                              '<cdbccxlt>'||pr_tab_cratrej(vr_indcratrej).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||pr_tab_cratrej(vr_indcratrej).nrdolote||'</nrdolote>'||
                              '<dscritic>'||pr_dscritic||'</dscritic></lancamentos>');
              END IF;

              -- vai para a proxima iteracao
              vr_indcratrej := pr_tab_cratrej.NEXT(vr_indcratrej);

            END LOOP; /* WHILE vr_indcratrej IS NOT NULL LOOP */

            -- Se não tem nenhum detalhe, força a geração do detalhe para
            -- que sejam exibidos os totais do arquivo no ireport
            IF NOT vr_flgrejei THEN
              -- escreve xml
              pc_escreve_xml('<lancamentos id="0">'||
                                '<nrseqdig>0</nrseqdig>'||
                                '<nrdocmto>0</nrdocmto>'||
                                '<vllanmto>0</vllanmto>'||
                                '<cdagenci>0</cdagenci>'||
                                '<nrdconta>0</nrdconta>'||
                                '<cdpesqbb>0</cdpesqbb>'||
                                '<cdbccxlt>0</cdbccxlt>'||
                                '<nrdolote>0</nrdolote>'||
                                '<dscritic>0</dscritic>'||
                             '</lancamentos>');

            END IF;--IF NOT vr_flgrejei THEN

            -- finalizando o arquivo
            pc_escreve_xml('</arquivos></crrl325>');
            -- codigo da critica
            IF vr_flgrejei THEN
              pr_cdcritic := 191;
            ELSE
              pr_cdcritic := 190;
            END IF;
            -- descricao da critica
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)||
                           ' --> ' || pr_tab_cratarq(vr_indcratarq).nmarquiv;
            -- gera log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || pr_dscritic);

            --Recuperar emails de destino
            vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS444_RELATORIO_TCO');

            -- se o e-mail nao estiver configurado, gera excecao
            IF trim(vr_email_dest) IS NULL THEN
              -- Monta mensagem de erro utilizando a variavel global pois
              -- direciona a excecao para o final do programa
              vr_dscritic:= 'Nao foi encontrado destinatario para relatorio TCO.';
              --Levantar Excecao
              RAISE vr_exc_saida;
            END IF;

            -- Gerando o relatório na cooperativa logada
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                                      ,pr_cdprogra  => pr_cdprogra
                                      ,pr_dtmvtolt  => pr_dtmvtolt
                                      ,pr_dsxml     => vr_des_xml
                                      ,pr_dsxmlnode => '/crrl325/arquivos/lancamentos'
                                      ,pr_dsjasper  => 'crrl325_total.jasper'
                                      ,pr_dsparams  => ' '
                                      ,pr_dsarqsaid => vr_caminho_cooper ||'/rl/'|| vr_nmarqimp
                                      ,pr_flg_gerar => 'S'
                                      ,pr_qtcoluna  => 132
                                      ,pr_sqcabrel  => 1
                                      ,pr_flg_impri => 'S'
                                      ,pr_nrcopias  => 1
                                      ,pr_dsmailcop => vr_email_dest /* Destinatarios separados por ";"*/
                                      ,pr_dsassmail => 'Relatorio de Cobranca BB' /* Assunto do e-mail*/
                                      ,pr_fldosmail => 'S'                               --> Conversar anexo para DOS antes de enviar
                                      ,pr_dscmaxmail => ' | tr -d "\032"'                --> Complemento do comando converte-arquivo
                                      ,pr_des_erro  => pr_dscritic);
            -- codigo da critica
            pr_cdcritic := 0;
            pr_dscritic := ' ';

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

            -- vai para a proxima iteracao do arquivo
            vr_indcratarq := pr_tab_cratarq.NEXT(vr_indcratarq);
          END LOOP; /* FOR EACH cratarq: */
        END; --declare begin...
      END pc_gera_relatorios_325_tco; /* fim gera_relatorios_325_tco */

    -- INICIO
    BEGIN
       vr_nmarqlog := gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE');
       
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop( pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        -- gera excecao
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Validações iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro é <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      -- Busca o diretorio da cooperativa conectada
      vr_caminho_cooper := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '');

      -- Setando os diretorios auxiliares
      vr_caminho_integra := vr_caminho_cooper||'/integra';
      vr_caminho_salvar  := vr_caminho_cooper||'/salvar';
      vr_caminho_compbb  := vr_caminho_cooper||'/compbb';

      vr_glbnrctares := 0;

      /*-----------------------  Verifica se deve rodar ou nao  ------------------*/
      IF pr_nmtelant = 'COMPEFORA' THEN
        rw_crapdat.dtmvtopr := rw_crapdat.dtmvtolt;
      END IF;

      --Comando para remover os arquivos .q caso existam no diretorio /compbb
      -- Estes arquivos eram gerados pelo progress para o processamento
      -- mas nao sao necessarios no oracle.
      vr_comando:= 'rm '||vr_caminho_compbb||'/*.q 2> /dev/null';

      --Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                          ,pr_des_comando => vr_comando
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_dscritic);

      --Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
        RAISE vr_exc_saida;
      END IF;

      /*-------------  Busca nome dos arquivos a serem processados  --------------*/
      pc_busca_nome_arquivos ( pr_cdcooper => pr_cdcooper
                              ,pr_cdagenci => 0
                              ,pr_nrdcaixa => 0
                              ,pr_cddbanco => 1
                              ,pr_nmarqdeb => vr_nmarqdeb
                              ,pr_tab_erro => vr_tab_erro
                              ,pr_dscritic => vr_dscritic);

      -- Se a busca do nome do arquivo retornar alguma critica
      -- apenas escreve no log e continua o processamento
      IF trim(vr_dscritic) IS NOT NULL THEN
        -- verifica se gerou a tabela de erros
        IF vr_tab_erro.count() > 0 THEN
          -- registra a critica no arquivo de log
          FOR vr_ind IN vr_tab_erro.first .. vr_tab_erro.last LOOP
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_tab_erro(vr_ind).dscritic);
          END LOOP;
        END IF;
      END IF;

      -- limpando o conteudo da variavel
      vr_dscritic := ' ';

      -- Nao existe convenio cadastrado
      IF trim(vr_nmarqdeb) IS NULL THEN
        -- Finaliza o programa mantendo o processamento da cadeia
        RAISE vr_exc_fimprg;
      END IF;

      --Listar arquivos
      gene0001.pc_lista_arquivos( pr_path     => vr_caminho_compbb
                                 ,pr_pesq     => vr_nmarqdeb
                                 ,pr_listarq  => vr_listadir
                                 ,pr_des_erro => vr_dscritic);

      -- se ocorrer erro ao recuperar lista de arquivos
      -- registra no log
      IF trim(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic);

      END IF;

      /* Nao existem arquivos para serem importados */
      IF trim(vr_listadir) IS NULL THEN
        -- Finaliza o programa mantendo o processamento da cadeia
        RAISE vr_exc_fimprg;
      END IF;

      -- Limpando a tabela que possui a lista de arquivos que devem ser processados
      vr_tab_cratarq.delete;

      --Carregar a lista de arquivos na temp table
      vr_tab_arquivo := gene0002.fn_quebra_string(pr_string => vr_listadir);

      -- Se retornou informacoes na temp table
      IF vr_tab_arquivo.count() > 0 THEN
        -- carrega informacoes na cratqrq
        FOR vr_ind IN vr_tab_arquivo.first .. vr_tab_arquivo.last LOOP
          -- Monta a chave da temp-table
          vr_chave := lpad(pr_cdcooper,5,'0')||rpad(vr_tab_arquivo(vr_ind),55,'#')||lpad(vr_ind,10,'0');

          -- carrega a temp-table com a lista de arquivos que devems er processados
          vr_tab_cratarq(vr_chave).nmarquiv := vr_tab_arquivo(vr_ind);
          vr_tab_cratarq(vr_chave).nrsequen := vr_ind;
          vr_tab_cratarq(vr_chave).nmquoter := vr_tab_arquivo(vr_ind)||'.q';
        END LOOP;
      -- Se nao possuir aquivos, sai do programa
      ELSE
        -- Finaliza o programa mantendo o processamento da cadeia
        RAISE vr_exc_fimprg;
      END IF;

      /*--------------------------  Processa arquivos  -------------------------*/
      -- Carrega as informações dos títulos na temp-table vr_tab_regimp
      pc_processa_arq_compensacao ( pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => 0
                                    ,pr_nrdcaixa => 0
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_tab_cratarq => vr_tab_cratarq
                                    ,pr_tab_regimp  => vr_tab_regimp /* boletos */
                                    ,pr_tab_erro    => vr_tab_erro
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);

      -- Se a busca do nome do arquivo retornar alguma critica
      IF trim(vr_dscritic) IS NOT NULL THEN
        -- verifica se gerou a tabela de erros
        IF vr_tab_erro.count() > 0 THEN
          -- grava mensagem de erro no log
          FOR vr_ind IN vr_tab_erro.first .. vr_tab_erro.last LOOP
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_tab_erro(vr_ind).dscritic);
          END LOOP;
        END IF;
        -- Abortando o processamento...
        RAISE vr_exc_saida;
      END IF;

      /*------------  Processa informacoes dos arquivos - atualizacoes ------------*/
      vr_arqimpor := ' ';

      -- Posicionando no primeiro registro da tabela
      vr_indregimp := vr_tab_regimp.FIRST;

      -- variavel auxiliar para controle de break by
      vr_nmarqaux   := 'X';

      -- Iniciando o loop na temp-table
      WHILE vr_indregimp IS NOT NULL LOOP

        -- se é FIRST-OF(nmarquiv)
        IF vr_nmarqaux <> vr_tab_regimp(vr_indregimp).nmarquiv THEN
          IF trim(vr_arqimpor) IS NULL THEN
            vr_arqimpor := vr_tab_regimp(vr_indregimp).nmarquiv;
          ELSE
            vr_arqimpor := vr_arqimpor || ',' || vr_tab_regimp(vr_indregimp).nmarquiv;
          END IF;
        END IF;
        -- armazena o nome do arquivo
        vr_nmarqaux   := vr_tab_regimp(vr_indregimp).nmarquiv;

        -- proximo registro da temp-table
        vr_indregimp := vr_tab_regimp.NEXT(vr_indregimp);
      END LOOP;

      -- Gerando critica e escrevendo no log
      -- 219 - INTEGRANDO ARQUIVO
      vr_cdcritic := 219;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' --> '||vr_arqimpor;

      -- Escreve no log os arquivos que serão processados
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
      -- Escreve somente o codigo do programa no log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => vr_nmarqlog
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra);

      -- Limpando as variáveis de controle de críticas
      vr_cdcritic := 0;
      vr_dscritic := ' ';

      -- Efetua as baixas e lança os rejeitados
      pc_efetiva_atualiz_compensacao ( pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => 0
                                     ,pr_nrdcaixa => 0
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                     ,pr_cdprogra => vr_cdprogra
                                     ,pr_tab_regimp  => vr_tab_regimp
                                     ,pr_tab_cratarq => vr_tab_cratarq
                                     ,pr_tab_cratrej => vr_tab_cratrej
                                     ,pr_tab_erro    => vr_tab_erro
                                     ,pr_cdcritic    => vr_cdcritic
                                     ,pr_dscritic    => vr_dscritic);

      -- Se retornar alguma critica
      IF trim(vr_dscritic) IS NOT NULL THEN
        -- verifica se gerou a tabela de erros
        IF vr_tab_erro.count() > 0 THEN
          -- grava mensagem de erro no log
          FOR vr_ind IN vr_tab_erro.first .. vr_tab_erro.last LOOP
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_tab_erro(vr_ind).dscritic);
          END LOOP;
        END IF;
        -- Abortando o processamento...
        RAISE vr_exc_saida;
      END IF;

      /* Gera Arquivos de Retorno - FEBRABAN e Outros */
      pc_gera_arquivo( pr_rwcrapcop => rw_crapcop
                      ,pr_rwcrapdat => rw_crapdat
                      ,pr_nmtelant  => pr_nmtelant
                      ,pr_cdprogra  => vr_cdprogra
                      ,pr_dscritic  => vr_dscritic);

      -- tratando erro na execucao do proedimento
      IF trim(vr_dscritic) IS NOT NULL THEN
        -- Abortando o processamento...
        RAISE vr_exc_saida;
      END IF;

      /*-------------------------  Gera Relatorios Finais ----------------------*/
      pc_gera_relatorios_325(  pr_cdcooper => pr_cdcooper
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                              ,pr_cdprogra => vr_cdprogra
                              ,pr_tab_cratarq => vr_tab_cratarq
                              ,pr_tab_cratrej => vr_tab_cratrej
                              ,pr_cdcritic    => vr_cdcritic
                              ,pr_dscritic    => vr_dscritic);

      -- Se a busca do nome do arquivo retornar alguma critica
      IF trim(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic);
        -- Abortando o processamento...
        RAISE vr_exc_saida;
      END IF;

      /*-------------------------  Gera Relatorios Finais ----------------------*/
      pc_gera_relatorios_627( pr_cdcooper => pr_cdcooper
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_tab_cratarq => vr_tab_cratarq
                             ,pr_tab_regimp  => vr_tab_regimp
                             ,pr_dsdircop    => rw_crapcop.dsdircop
                             ,pr_cdcritic    => vr_cdcritic
                             ,pr_dscritic    => vr_dscritic);

      -- Se retornar alguma critica
      IF trim(vr_dscritic) IS NOT NULL THEN
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic);
        -- Abortando o processamento...
        RAISE vr_exc_saida;
      END IF;

      /*---------------------  Gera Relatorio Critica TCO ----------------------*/
      IF pr_cdcooper = 2 THEN
        -- gera relatorio de conta integracao
        pc_gera_relatorios_325_tco(pr_cdcooper => pr_cdcooper
                                  ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                                  ,pr_cdprogra  => vr_cdprogra
                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                  ,pr_tab_cratarq => vr_tab_cratarq
                                  ,pr_tab_cratrej => vr_tab_cratrej
                                  ,pr_cdcritic    => vr_cdcritic
                                  ,pr_dscritic    => vr_dscritic);

        IF trim(vr_dscritic) IS NOT NULL THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratado
                                        ,pr_nmarqlog     => vr_nmarqlog
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic);
          -- Abortando o processamento...
          RAISE vr_exc_saida;
        END IF;--IF vr_dscritic IS NOT NULL THEN
      END IF;--IF pr_cdcooper = 2 THEN

      /*  Rotina de Utilizacao Temporaria para gerar baixas dos boletos
          pagos via compensacao e caixa somente para o convenio 457595
          utilizado para gerar boletos atraves do sistema CoopCob - Antigo
          Alpes (Adilson) - 11/02/2009 - ZE                              */
      cobr0001.pc_gera_retorno_arq_cob_coop(pr_cdcooper => pr_cdcooper             -- Codigo da cooperativa
                                           ,pr_cdprogra => vr_cdprogra             -- Codigo do programa
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt     -- Data do movimento
                                           ,pr_cdagenci => 0                       -- Codigo da agencia
                                           ,pr_nrocaixa => 0                       -- Codigo do caixa
                                           ,pr_cdcritic => vr_cdcritic             -- Codigo da critica
                                           ,pr_dscritic => vr_dscritic             -- Descricao da critica
                                           ,pr_tab_erro => vr_tab_erro);           -- tabela de erros

      -- Se retornar alguma critica
      IF trim(vr_dscritic) IS NOT NULL THEN
        -- verifica se gerou a tabela de erros
        IF vr_tab_erro.count() > 0 THEN
          -- grava mensagem de erro no log
          FOR vr_ind IN vr_tab_erro.first .. vr_tab_erro.last LOOP
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_nmarqlog     => vr_nmarqlog
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_tab_erro(vr_ind).dscritic);
          END LOOP;
        END IF;
        -- Abortando o processamento...
        RAISE vr_exc_saida;
      END IF;

      -- limpando as tabelas temporarias
      vr_tab_descontar.delete;
      vr_tab_regimp.delete;
      vr_tab_crawcta.delete;
      vr_tab_migracaocob.delete;
      vr_tab_cratarq.delete;
      vr_tab_erro.delete;
      vr_tab_cratrej.delete;
      vr_tab_arquivo.delete;

      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Efetua os comandos unix de copia e de movimentacao
      vr_ind_comando := vr_tab_comando.first;
      WHILE vr_ind_comando IS NOT NULL LOOP

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_tab_comando(vr_ind_comando)
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => pr_dscritic);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          -- gera excecao e sai da execucao
          pr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_tab_comando(vr_ind_comando);
          -- retornando ao programa chamador
          RAISE vr_exc_saida;
        END IF;

        -- Vai para o proximo registro
        vr_ind_comando := vr_tab_comando.next(vr_ind_comando);
      END LOOP;

      -- Efetuar Commit de informacoes pendentes de gravacao
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          -- Buscar a descricao
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se foi gerada critica para envio ao log
        IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => vr_nmarqlog
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic );
        END IF;
        -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
        btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);
        -- Efetuar commit pois gravaremos o que foi processo ateh entao
        COMMIT;
      WHEN vr_exc_saida THEN

        -- Gera informacao que nenhum dado de arquivo foi processado
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || 'ATENCAO: Todo o processo foi retornado. Nenhum arquivo foi processado!');

        -- Se foi retornado apenas codigo
        IF vr_cdcritic > 0 AND trim(vr_dscritic) IS NULL THEN
          -- Buscar a descricao
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Devolvemos codigo e critica encontradas
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Efetuar rollback
        ROLLBACK;

      WHEN OTHERS THEN
        -- Gera informacao que nenhum dado de arquivo foi processado
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_nmarqlog     => vr_nmarqlog
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || 'ATENCAO: Todo o processo foi retornado. Nenhum arquivo foi processado!');

        -- Efetuar retorno do erro nao tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;

    END;
  END pc_crps375;
  /
