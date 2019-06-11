CREATE OR REPLACE PROCEDURE CECRED.pc_crps573_fabricio(pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                             ,pr_stprogra OUT PLS_INTEGER            --> Sa�da de termino da execu��o
                                             ,pr_infimsol OUT PLS_INTEGER            --> Sa�da de termino da solicita��o
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps573 (Fontes/crps573.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Guilherme
       Data    : Junho/2018                       Ultima atualizacao: 16/07/2018

       Dados referentes ao programa:

       Frequencia:
       Objetivo  : Gerar arquivo(3040) Dados Individualizados de Risco de Credito
                   Juncao do 3020 com o 3030
                   Geracao de relatorio para conferencia
                   Solicitacao : 80
                   Ordem do programa na solicitacao = 4.
                   Relatorio 566 e 567.
                   Programa baseado no crps368
                   Programa baseado no crps369 (tag <Agreg>)

       Alteracoes : 03/03/2011 - Retirar critica acima de 5milhoes e tratamento
                                 para garantia nao fidejussoria (Guilherme).

                    12/07/2011 - Realizado alteracao para atender ao novo layout
                                 (Adriano).

                    05/08/2011 - Incluido atributo VarCamb. (Irlan)

                    08/08/2011 - Incluido atibuto DiaAtraso (Irlan)

                    12/09/2011 - N�o permitir faturamento anual negativo (Irlan)

                    04/10/2011 - Inserido Cosif e PercIndx (Irlan)

                    19/10/2011 - Incluido os dados da central de risco no
                                 cabecalho do arquivo 3040 (Adriano).

                    29/12/2011 - Mudan�a de crit�rio para sobre opera��es de
                                 cr�dito por solicita��o do Banco Central
                                 (Irlan/Lucas).

                    05/06/2012 - Ajuste na provisao (Gabriel).

                    17/08/2012 - Removido Procedure
                                 verifica_garantidores_nao_fidejussorio
                                 e sua chamada. (Lucas R.)

                    25/09/2012 - Inicializado aux_cddesemp com 1 ao inves de zero
                                 (Irlan)

                    10/10/2012 - Tratar campo de modalidade quando 299, 499
                                 (Gabriel).

                    22/11/2012 - Ajuste divida estancada (Tiago).
                               - Ajustar lanctos da crapris com cdorigem 4 e 5
                                 como um unico lancto (Rafael).

                    04/01/2013 - Criada procedure verifica_conta_altovale_573
                                 para desprezar as contas migradas (Tiago).

                    14/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                                 consulta da craptco (Tiago).

                    21/01/2013 - Gerar as sa�das das opera��es. (Tiago)

                    21/01/2013 - Inclusao do UNFORMATTED na inpressao da tag < inf
                                 e inclusao multiplicacao por 100 para buscar o valor
                                 inteiro (Lucas R.).

                    22/01/2013 - Incluir validacao para para alterar modalidade
                                 0203 para 0206 somente se for pessoa fisica
                                 (Lucas R.)

                    08/02/2013 - Ajustes processo de geracao entradas e saidas (Daniel).

                    14/02/2013 - Ajustes processo de geracao entradas e saidas para tratar
                                 re-geracao do arquivo.(Daniel).

                    01/04/2013 - Incluso procedure verifica_garantia_alienacao_fiduciaria
                                 (Daniel).

                    24/04/2013 - Incluso tratamento para empresimos/financiamentos migrados para
                                 Altovale, incluso registro <Inf Tp="1001" nos casos de
                                 cdnatuop = "02" (Daniel).

                    17/05/2013 - Incluido tratamento de arredondamento na rotina
                                 normaliza_juros, acrescentado ao indice tt-agreg
                                 o campo cdvencto e adicionado chamada da procedure
                                 busca_modalidade para retirar repeticao de codigo
                                 (Tiago).

                    17/06/2013 - Tratamento para emprestimos do BNDES; leitura
                                 da crapebn quando crapvri.cdmodali = 0499 ou 0299.
                                 (Fabricio)

                    11/07/2013 - Ajustes no arq3040 devido a quebra por cpf nao
                                 estar apresentando os resultados conforme desejado
                                 foi necessario realizar a mesma pegando apenas as
                                 8 primeiras posicoes do cpf (Tiago).

                    05/08/2013 - Chamada da procedure busca_taxeft nos pontos
                                 em que se precisa calcular a taxa efetiva anual.
                                 (Fabricio)

                    14/08/2013 - Incluida procedure verifica_inf_chassi que cria
                                 tag <inf> quando modalidade=04 e sub=01 e conter
                                 informacoes do chassi (Tiago).

                    26/08/2013 - Incluida regra na procedure verifica_inf_chassi
                                 para considerar apenas ("AUTOMOVEL,MOTO,CAMINHAO")
                                 do campo crapbpr.dscatbem (Tiago).

                    29/08/2013 - incluida procedure
                                 verifica_inf_aplicacao_regulatoria que cria tag
                                 <inf> para contratos com linha de credito "DIM"
                                 (Tiago).

                    17/03/2013 - Ajustado os valores de referencia de faturamento
                                 anual para definicao do porte de cliente PJ
                                 (Adriano)

                    05/12/2013 - Renomeada procedure verifica_conta_altovale_573
                                 para verifica_conta_migracao_573 que despreza
                                 as contas migradas (Tiago).

                    17/12/2013 - Inserido PAs da migracao na condicao da craptco
                                 na procedure verifica_conta_migracao_573 (Tiago).

                    30/12/2013 - Ajuste para considerar radical do cpf/cnpj no
                                 "FOR EACH tt-ris" Adriano).

                    09/01/2014 - Ajuste tratamento migracao e corrigido erro na
                                 totalizacao tt-agreg (Daniel).

                    27/01/2014 - Convers�o Progress para PLSQL (Andrino/RKAM)

                    16/01/2014 - Incluso Total de Clientes (TotalCli) no cabecalho,
                                 incluso renda anual para pessoa fisica <FatAnual>
                                 (Daniel).

                    07/02/2014 - Incluso ajuste apara adequacao Oracle, conforme
                                 solicitacao Andrino, softdesk 125051 (Daniel).

                    10/02/2014 - Ajuste calculo desempenho da opera��o (Daniel).

                    07/03/2014 - Ajuste regra para tratamento modalidade "0203" e
                                 "0206" (Daniel).
                                 
                    02/05/2014 - Ajustes Legais Maio/2014: Quando emprestimo BNDES
                                 enviar Origem Recurso como 0202 e nao 0199.
                                 Alterada procedure pc_busca_modalidade: Novo 
                                 param de entrada (origem), e novo de saida(orgrec)
                                (Guilherme/SUPERO).

                    07/05/2014 - Ajustes para montagem do valor da divida com mascara
                                 mais ampla, pois estava estourando as informa��es 
                                 (Marcos-Supero)             

                    15/05/2014 - Ajuste na variavel vr_dtfimctr, pois quando nulo
                                 gera cr�tica no Validador do Banco Central.
                                 Ajuste na pc_busca_taxeft, quando pr_cdmodali = 0201
                                 nao era inicializada a variavel vr_txeanual, deixando
                                 ela como NULL, gerando critica no Validador do BC
                                 (Guilherme/SUPERO)
                                 
                    30/06/2014 - Corre��o nas modalidades de capital de giro, antes usavamos
                                 o calculo para encerramento do empr�stimo para definir se 
                                 ele era 0215(capital de giro com prazo de vencimento at� 365 d)
                                 ou 0216 (capital de giro com prazo vencimento superior 365 d)
                                 mas na verdade temos de considerar a data de contrata��o 
                                 frente a data atual, e se for um empr�stimo de periodo maior
                                 que 365 ent�o gerar o 0215. (Marcos-Supero)
                                 
                    01/07/2014 - Melhorias na codifica��o com coment�rios, remo��o de codifica��o
                                 duplicada, e corre��o de l�gicas err�neas (Marcos-Supero)
                                 
                    03/07/2014 - Altera��es para adicionar novos campos do Fluxo Financeiro 
                                 (DtaProxParcela, VlrProxParcela e QtdParcelas) (Marcos-Supero)   
                                 
                    19/09/2014 - Corre��o na busca da conta cosif para considerar a modalidade
                                 enviada ao 3040 e n�o mais a modalidade do risco (Marcos-Supero)
                                 
                    10/10/2014 - Corre��o na busca da conta cosif para modalidade de Repasse
                                 (Marcos-Supero)    
                                 
                    12/11/2014 - Corre��o na busca de detalhes dos Border�s de Titulo e Cheque j� 
                                 que agora o nrctremp n�o cont�m mais o contrato de limite, mas sim 
                                 o n�mero do Border�. (Marcos-Supero)  
                                 
                    19/12/2014 - Inclus�o das informa��es de Ente Consignante quando empr�stimo ou
                                 financiamento consignado em folha (Marcos-Supero)             
                                 
                    16/01/2015 - Ajustes no campo para definir o vencimento da opera��o de empr�stimos
                                 que deve verificar a data da ultima parcela (produto novo) e usar o 
                                 calculo de meses * parcelas a partir da primeira (produto antigo)
                               - Tamb�m removi a l�gica para teste de incorpora��o, pois em novembro
                                 j� enviamos os contratos incorporados (Marcos-Supero)

                    02/02/2015 - Remo��o da procedure pc_busca_modalidade, passamos a usar a fun��o
                                 de banco fn_busca_modalidade para evitar retrabalho e reaproveitarmos
                                 o c�digo da mesma no cadastro de positivos, no crps573 e crps280
                               - Tamb�m ajustamos do Doc3040 para envio das informa��es de Limite
                                 n�o Utilizado - Modalidade 1901. (Marcos-Supero)    
                                 
                    24/04/2015 - Corre��o da l�gica de busca das sa�das de Desconto de Titulos (0301)
                                 onde havia agrupamento apenas por CPF, onde o correto � considerar
                                 tamb�m o n�mero do contrato (Border�), pois cada border� � um novo 
                                 contrato e est�vamos enviando apenas um registro de sa�da, gerando os
                                 questionamentos Q1, onde opera��es n�o aparecem nem ativas nem inativas
                                 (Marcos-Supero)   
                                 
                    30/04/2015 - Corre��o no envio do Ente Consignante. Quando empr�stimos em preju�zo
                                 n�o mais enviaremos o CNPJ do Ente, mais sim a informa��o Cd="1",
                                 que para o Bacen significa que a opera��o foi desconsignada 
                               - Implementa��o de nova regra (or) para marcar contratos resultantes
                                 de renegocia��o, onde contratos que possuem alguma liquida��o (nrctrliq)
                                 marcaremos com CarctEspecial="1" (Marcos-Supero)
                    
                    06/05/2015 - Novo ajuste quanto ao Ente Consignante, para se n�o houver Cnpj na CaDEMP,
                                 pegarmos a informa��o da aba Comercial da tela CONTAS (Marcos-Supero)
                                 
                    07/05/2015 - Remo��o do digito verificador para as contas cosif, conforme email enviado
                                 Bacen e atrelado ao SD283602 (Marcos-Supero)      
                                 
                    08/05/2015 - Ap�s reuni�o com diretoria e �reas de cr�dito e controles internos, foi 
                                 solicitado para enviarmos ao BAcen os contratos como negocia��o somente
                                 observando se o mesmo liquidou algum outro, e n�o mais observar a linha de 
                                 cr�dito ou qualificador da Opera��o, ficando desta forma sincronizado
                                 a regra de marca��o de sa�da e de novo contrato (Marcos-Supero) 
                                 
                    06/07/2015 - Ajustes na busca da linha de desconto quando Desconto de Cheque ou Titulo,
                                 que ap�s ajuste para envio dos contratos separadamente do contrato de limite
                                 unificamos a busca e sempre usavamos o tipo de desconto = 2, e quando desconto
                                 de titulo deve ser igual a 3 - (Marcos-Supero).     
                               
                    06/07/2015 - Ajuste na informacao "Data Fim do Contrato" para o AD, para buscar o inicio
                                 da data que teve o estouro de conta. (James)
                                 
                    24/11/2015 - Ajuste para enviar o Grupo Economico para as opera��es Ativas. (James)
                    
                    24/11/2015 - Ajuste para enviar a data de vencimento da operacao nas operacoes de Baixas. (James)
                               
                    04/01/2016 - Ajuste na tag dtVencOp, para pegar a informacao do campo crapris.dtvencop(Chamado:367635).(James)

                    10/03/2016 - Projeto 306 - Implantacao Provisao de risco de credito sobre garantias prestadas. (James)
                    
                    31/03/2016 - Ajuste para informar como Origem do Recurso 0203 as opera��es do BNDES-Finame 
                                 no arquivo 3040. (SD 426476 - Carlos Rafael Tanholi)
                                
                    05/04/2016 - Ajuste para pegar a taxa efetiva anual do cart�o da tabela crapprm. (James)
                    
                    20/04/2016 - Ajuste para dividir o arquivo em partes. (James)
                    
                    10/05/2016 - Ajuste no numero do contrato para enviar a modalidade que vai na tag modalidade. (James)
                    
                    24/05/2016 - Ajuste para enviar o "Ente Consignante" como 1502. (James)

                    09/06/2016 - Ajustes complementares para dividir o arquivo 3040 em partes 
                                 SD422373 (Odirlei-AMcom)

                    10/03/2016 - Projeto 306 - Implantacao Provisao de risco de credito sobre garantias prestadas. (James)
                    
                    31/03/2016 - Ajuste para informar como Origem do Recurso 0203 as opera��es do BNDES-Finame 
                                 no arquivo 3040. (SD 426476 - Carlos Rafael Tanholi)
                                
                    05/04/2016 - Ajuste para pegar a taxa efetiva anual do cart�o da tabela crapprm. (James)
                    
                    10/05/2016 - Ajuste no numero do contrato para enviar a modalidade que vai na tag modalidade. (James)
                    
                    24/05/2016 - Ajuste para enviar o "Ente Consignante" como 1502. (James)
                    
                    24/06/2016 - Correcao para o uso correto do indice da CRAPTAB nesta rotina.(Carlos Rafael Tanholi).
                    
                    20/07/2016 - Resolucao dos chamados 491068, 488220 e 486570. (James)
                    
                    01/08/2016 - Resolucao do chamado 497022 - Operacoes de saida 0305. (James)

                    26/09/2016 - Ajustes na rotina pc_carrega_base_risco para o envio correto 
                                 da data de vencimento e quantidade de dias atraso.
                                 SD488220 (Odirlei-AMcom)

                    24/10/2016 - Alterado o Ident de 1 para 2 conforme solicita��o realizada no chamado 541753
                                 ( Renato Darosci - Supero )
                                 
                    03/11/2016 - Alterada a fun��o de classifica��o do porte de pessoa f�sica, para que sejam considerados
                                 como "sem redimento", rendas mensais de at� 0.01 (inclusive) e n�o mais rendas com valor 
                                 zero apenas. Esta altera��o corrige o problema relatado no chamado SD 549969, onde contas
                                 cadastradas com rendimento igual a 0.01 estavam sendo enviadas com c�digo de porte igual
                                 a 2 - AT� 1 SAL�RIO M�NIMO. (Renato Darosci - Supero)
                                 
                    06/01/2017 - Ajuste para desprezar contas migradas da Transulcred para Transpocred antes da incorpora��o.
                                 PRJ342 - Incorpora��o Transulcred (Odirlei-AMcom)
                                 
                    24/02/2017 - Ajuste na tratativa do campo Ident, o qual estava verificando campos incorretos para
					                       informar a baixa do gravames (Daniel - Chamado: 615103) 

                    08/03/2017 - Alteracao na regra de porte cliente juridico (Daniel - Chamado: 626161) 

                    13/04/2016 - Ajustes PRJ343 - Cessao de Credito (Odirlei-AMcom)

                    11/05/2017 - Incluso tratativa para caracteristica especial 17 (Daniel - Chamado: 639510)

                    18/05/2017 - P408 - Inclus�o dos contratos inddocto=5 - Provis�o de Garantias Prestas
                                 Andrei - Mouts
                                 
                    15/08/2017 - Alterar cursores onde efetuavam leitura da tabela crapbpr
                                 pelo cr_tbepr_bens_hst que chama a tabela tbepr_bens_hst
                                 (Lucas Ranghetti #734912)
                                 
                    23/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

                    21/11/2017 - Criada procedure pc_garantia_cobertura_opera. 
                                 Projeto 404 -  Automatiza��o da Garantia de Aplica��o nas Opera��es de Cr�dito (Lombardi)

                    27/12/2017 - Ajustado para enviar a qtd de dias de atraso calculado na 
                                 central de risco para os contratos em prejuizo, devido a auditoria do Bacen.
                                 (Odirlei-AMcom/Oscar) 
																 
								    09/02/2018 - Corre��o de erro na consulta de �ndices quando empr�stimo do BNDES (PRJ298), 
                                 erro reportado pelos plantonistas (Jean Michel)

                    24/01/2018 - Inclus�o de consist�ncia do novo campo para identifica��o da qualifica��o da opera��o(crapepr.idquaprc)
                                 (Daniel-AMcom)

                    20/02/2018 - Incluso procedimento para atender ao Projeto Ligeirinho. Foi necess�rio incluir
                                procedimento de paralelismo para ganho de performance. - Mauro Amancio (Amcom).                                              
                                 
                    02/04/2018 - Inclus�o de envio de Carac Espec=19 para ATIVO PROBLEM�TICO - Daniel(AMcom)

                    17/04/2018 - Incluir no arquivo somente fluxo de vencimento com valor maior que 0
                                 ou menor que -100. Empresa 81, o sistema deve validar (se n�o tem mais
                                 CNPJ deve ser enviado 1) conforme o manual do 3040. (SD#855059-AJFink)
								
                    09/05/2018 - Corre��o para considerar apenas os contratos com cobertura de opera��o ativa (Lucas Skroch - Supero)
				   
                    10/05/2018 - Ajuste na proc pc_garantia_cobertura_opera para nao enviar atricuto Ident 
                                 da tag Gar quando tipo for "0104" ou "0105". PRJ366 (Lombardi)
				   
                    07/06/2018 - P450 - Considerar contrato Limite/ADP na Qtde Contratos(qtctrliq) (Guilherme/AMcom)

                    18/06/2018 - Ajustes no procedimento de paralelismo para ganho de performance. - Mario Bernat (Amcom). 
                    
                    16/07/2018 - P442 - Remo��o da l�gica principal para dentro do novo pc_crps573_1, isso � necess�rio
                                 para reaproveitamento de c�digo quando execu��o trimestral na Central onde � criado
                                 o arquivo BNDES (Marcos-Envolti)                                             

.............................................................................................................................*/

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- C�digo do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS573';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT cop.nmrescop
              ,cop.nmextcop
              ,cop.nrdocnpj
              ,cop.dsnomscr
              ,cop.dsemascr
              ,cop.dstelscr
              ,cop.nrcepend
              ,cop.cdufdcop
              ,cop.dsdircop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop   cr_crapcop%ROWTYPE;
      
      -- Cursor gen�rico de calend�rio
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- busca a data de parametro com base nos dados da Solicitacao
      CURSOR cr_crapsol IS
        SELECT to_date(crapsol.dsparame,'DD/MM/YYYY') dsparame
          FROM crapsol,
               crapprg
         WHERE crapprg.cdcooper = pr_cdcooper
           AND crapprg.cdprogra = vr_cdprogra
           AND crapsol.cdcooper = crapprg.cdcooper
           AND crapsol.nrsolici = crapprg.nrsolici;

      ------------------------------- VARIAVEIS -------------------------------
      -- Variavel com a data base
      vr_dtrefere DATE;
      -- Variaveis gerais
      vr_dstextab craptab.dstextab%TYPE; -- Variavel de texto do risco bacen
      -- Valor do salario minimo
      vr_vlsalmin NUMBER(17,2);          
      -- Taxa anual
      vr_txeanual_tab NUMBER(10,4);
       
    -- ----------------------------------------------------------------
    -- Rotina Principal     
    -- ----------------------------------------------------------------
    BEGIN
      --------------- VALIDACOES INICIAIS -----------------
      -- Incluir nome do m�dulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
      
      -- Leitura do calend�rio da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat;
      -- Se n�o encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_saida;
      ELSE
        -- Fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
        
      -- Valida��es iniciais do programa
      BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                               ,pr_flgbatch => 1
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_cdcritic => vr_cdcritic);
      -- Se a variavel de erro � <> 0
      IF vr_cdcritic <> 0 THEN
        -- Envio centralizado de log de erro
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
      -- Buscar data da solicita��o
  /*    BEGIN
        OPEN cr_crapsol;
        FETCH cr_crapsol 
         INTO vr_dtrefere;
        -- N�o existe crapsol
        IF cr_crapsol%NOTFOUND THEN
          CLOSE cr_crapsol;
          vr_dscritic := 'Nao encontrado solicitacao para o programa (CRAPSOL).';
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_crapsol;
      EXCEPTION
        WHEN vr_exc_saida THEN
          RAISE vr_exc_saida;
        WHEN others THEN  
          vr_dscritic := 'Problema ao retornar a data da solicitacao (CRAPSOL).';
          RAISE vr_exc_saida;
      END;
      */
      
      vr_dtrefere := to_date('31/05/2019', 'DD/MM/RRRR');
      
      --Verificar se o programa deve ser executado
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'RISCOBACEN'
                                               ,pr_tpregist => 0);
  /*    IF substr(vr_dstextab,1,1) <> '1' THEN
        vr_cdcritic := 411; --Tabela de execucao nao liberada
        RAISE vr_exc_saida;
      ELSE */
        -- Busca o valor do salario minimo
        vr_vlsalmin := GENE0002.fn_char_para_number(SUBSTR(vr_dstextab,13,11));
 --     END IF;
      
            
      -- Busca Taxa Efetiva Anual - TAB0004
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'JUROSNEGAT'
                                               ,pr_tpregist => 001);
      -- Se encontrou
      IF trim(vr_dstextab) IS NOT NULL THEN
        BEGIN
          -- Converte a informa��o para number
          vr_txeanual_tab := SUBSTR(vr_dstextab,1,10);
          vr_txeanual_tab := ROUND((POWER(1 + (vr_txeanual_tab / 100),12) - 1) * 100,2);
        EXCEPTION
          WHEN OTHERS THEN
            vr_txeanual_tab := 0;
        END;  
      END IF;
      
      
      /* Acionar gera��o normal do Doc3040 */  
      pc_crps573_1(pr_cdcooper => pr_cdcooper         --> Cooperativa solicitada
                  ,pr_dtrefere => vr_dtrefere         --> Data de refer�ncia
                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do calend�rio
                  ,pr_dtultdma => rw_crapdat.dtultdma --> Data do ultimo dia do m�s anterior
                  ,pr_inproces => rw_crapdat.inproces --> Indicador do estado do processo
                  ,pr_vlsalmin => vr_vlsalmin         --> Valor m�nimo
                  ,pr_txeanual => vr_txeanual_tab     --> Taxa Anual
                  ,pr_flbbndes => 'N'                 --> Executar S� BNDEs
                  ,pr_cdcritic => vr_cdcritic         --> Critica encontrada
                  ,pr_dscritic => vr_dscritic);       --> Texto de erro/critica encontrada
      
      -- Em caso de problema
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- PAra a Central e em execu��es Trimestrais
      IF pr_cdcooper = 3 AND to_char(vr_dtrefere,'mm') IN ('03','06','09','12') THEN
        
        -- Acionar gera��o do Doc3040 espec�fico do BNDES 
        pc_crps573_1(pr_cdcooper => pr_cdcooper         --> Cooperativa solicitada
                    ,pr_dtrefere => vr_dtrefere         --> Data de refer�ncia   
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do calend�rio
                    ,pr_dtultdma => rw_crapdat.dtultdma --> Data do ultimo dia do m�s anterior
                    ,pr_inproces => rw_crapdat.inproces --> Indicador do estado do processo
                    ,pr_vlsalmin => vr_vlsalmin         --> Valor m�nimo
                    ,pr_txeanual => vr_txeanual_tab     --> Taxa Anual
                    ,pr_flbbndes => 'S'                 --> Executar BNDEs
                    ,pr_cdcritic => vr_cdcritic         --> Critica encontrada
                    ,pr_dscritic => vr_dscritic);       --> Texto de erro/critica encontrada
        
        -- Em caso de problema
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
     
      END IF;
            
      -- Atualiza o indicador na tabela generica da cooperativa informando que o processo foi finalizado
      BEGIN
        UPDATE craptab
           SET dstextab = '2'||SUBSTR(dstextab,2,4000)
         WHERE craptab.cdcooper = pr_cdcooper
           AND upper(craptab.nmsistem) = 'CRED'
           AND upper(craptab.tptabela) = 'USUARI'
           AND craptab.cdempres = 11
           AND upper(craptab.cdacesso) = 'RISCOBACEN'
           AND craptab.tpregist = 000;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao atualizar tabela CRAPTAB: '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
        
                         
      
      -- Envio do log/mensagem para a contabilidade
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 1 -- Processo normal
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || '663 --> '
                                                 || gene0001.fn_busca_critica(663) );      
             
      -- Salvar informa��es atualizadas
      COMMIT;
                                  
      
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        -- Devolvemos c�digo e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;

        
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro n�o tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;

        -- Efetuar rollback
        ROLLBACK;
    END;
  END pc_crps573_fabricio;
/
