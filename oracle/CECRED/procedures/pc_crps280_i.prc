CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS280_I(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Coop. conectada
                                               ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE --> Dados da crapdat
                                               ,pr_dtrefere   IN DATE                  --> Data de referência para o cálculo
                                               ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo programa conectado
                                               ,pr_dsdircop   IN crapcop.dsdircop%TYPE --> Diretório da cooperativa
                                               ,pr_vltotprv  OUT crapbnd.vltotprv%TYPE --> Total acumulado de provisões
                                               ,pr_vltotdiv  OUT crapbnd.vltotdiv%TYPE --> Total acumulado de dívidas
                                               ,pr_cdcritic  OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                               ,pr_dscritic  OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
  BEGIN
  /* ..........................................................................

     Programa: pc_crps280_i (Antiga includes/crps280.i)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Evandro
     Data    : Fevereiro/2006                  Ultima atualizacao: 07/03/2018

     Dados referentes ao programa:

     Frequencia: Mensal ou Tela.
     Objetivo  : Atende a solicitacao 4 ou 104.
                 Emite relatorio da provisao para creditos de liquidacao duvidosa
                 (227).

     Alteracoes: 16/02/2006 - Alterado p/ listar Riscos por PAC (Diego).

                 22/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                 27/06/2006 - Alterado para liberar Arquivo PDF do relatorio 354
                              (Diego).

                 25/07/2006 - Alterado numero de copias do relatorio 227 para
                              Viacredi (Elton).

                 04/09/2006 - Envio do rel.227 por e_mail(substituido rel.354)
                              (Mirtes)

                 08/12/2006 - Alterado para 3 o numero de copias do relatorio 227
                              para Viacredi (Elton).

                 08/04/2008 - Alterado envio de email para BO b1wgen0011
                              (Sidnei - Precise)

                            - Enviar email para creditextil@creditextil.coop.br
                              (Gabriel).

                 01/09/2008 - Alteracao cdempres (Kbase IT).

                            - Incluir coluna com o pac , incluir email
                              convenios@viacredi.coop.br (Gabriel)

                 23/10/2008 - Incluir prejuizo a +48M ate 60M (Magui).

                 04/12/2008 - Tratamento para desconto de titulos somando com o
                              desconto de cheques (Evandro).

                 19/05/2009 - Adicionado e-mail cdc@viacredi.coop.br para o
                              relatorio 227 com glb_cdcooper = 1 (Fernando).

                 20/06/2009 - Adicionado e-mail controle@viacredi.coop.br para o
                              relatorio 227 com glb_cdcooper = 1 (Mirtes).

                 19/10/2009 - Enviado relatorio crrl354.lst da viacredi para
                              diretorio micros/viacredi/Tiago exceto quando
                              executa fontes/crps184.p (Elton).

                 04/12/2009 - Retirar campos relacianados ao Rating na crapass.
                              Utilizar a crapnrc (Gabriel).

                 09/03/2010 - Gera arquivo texto para ser aberto no excel se
                              cooperativa for Viacredi ou Creditextil (Elton).

                            - Nao listar os Rating que nao podem ser atualizados
                              no relatorio "Operacoes_credito_em_dia".
                              Este mesmo relatorio esta sendo disponibilizado
                              na intranet para todas as coopes (rel 552) (Gabriel).

                 02/06/2010 - Desconsiderar quando estouros em conta pra central
                              e emprestimos com menos de 6 meses (Gabriel).

                 29/06/2010 - Tratamento para calculo da quantidade de meses
                              decorridos (Elton).

                 27/07/2010 - Gera relatorio crrl552.lst mesmo quando nao possuir
                              movimentos, mostrando somente o cabecalho (Elton).

                 09/08/2010 - Incluida coluna "MESES/DIAS ATR." para os relatorios
                              crrl227.lst e crrl354.lst (Elton).

                 23/08/2010 - Feito tratamento de Emprestimos (0299),
                              Financiamento (0499) (Adriano).

                 30/08/2010 - Modificada posicao da coluna "MESES/DIAS ATR." no
                              arquivo crrl354.txt (Evandro/Elton).

                 29/10/2010 - Correcao Parcelas em Atraso(Mirtes)

                 13/12/2010 - Criado relatorio de contas em risco H por mais de
                              6 meses (Henrique).

                 04/01/2011 - Incluido as colunas "Risco, Data Risco, Dias em
                              Risco" (Adriano).

                 02/02/2011 - Voltado qtdade parcela para inte. Impacto na
                              provisao das coopes muito grande (Magui).

                 02/03/2011 - Valores maiores que 5 milhoes devem ser informados
                              Ha uma alteracao no 3020 (Magui).

                 04/03/2011 - Ajuste para gerar o PDF do relatorio 581 (Henrique).

                 22/03/2011 - Inserida informacao de dias de atraso no relatorio
                              crrl581 (Henrique).

                 08/04/2011 - Retirado os pontos dos campos numéricos e decimais
                              que são exportados para o arquivo crrl354.txt.
                              (Isara - RKAM)

                 29/04/2011 - Ajustado para multiplicar par_qtatraso por 30
                              somente quando a origem for igual a 3 (Adriano).
                              Ajustes no campo qtdiaris (Magui).

                 02/05/2011 - Substituido codigo por descricao no campo origem,
                              relatorio 581 (Adriano).

                 15/08/2011 - Copia relatorio crrl354.lst para o diretorio
                              /micros/cecred/auditoria/"cooperativa".
                            - Copia relatorio crrl354.txt para diretorio
                              /micros/credifoz (Elton).

                 31/10/2011 - Alterado o format do campo aux_qtdiaris para "zzz9"
                              (Adriano).

                 01/06/2012 - Exibir juros atraso + 60 e considerar este valor
                              no calculo da provisao (Gabriel).

                 15/06/2012 - Ajuste no arquivo 354.txt (Gabriel)

                 17/09/2012 - Ajuste no campo risco Atual (Gabriel).

                 26/09/2012 - Ajuste no display do 354.txt (Gabriel).

                 03/10/2012 - Disponibilizar arquivo crrl264.txt para
                              Alto Vale (David Kruger).

                 09/10/2012 - Ajuste no relatorio 227 referente ao desconto
                              de titulos da cob. registrada (Rafael).

                 07/12/2012 - Realizado a inclusao de um carecter * nas colunas:
                               - "Risco", do relatório 354 (exeto o que eh gerado
                                 para envio ao radar).
                               - "Risco atual", do relatorio 227.
                              Para indicar que a conta faz parte de algum
                              grupo economico (Adriano).

                 04/01/2013 - Criada procedure verifica_conta_altovale_280
                              para desprezar as contas migradas (Tiago).

                 11/01/2013 - Incluida condicao (craptco.tpctatrf <> 3) na
                              consulta da craptco (Tiago).

                 07/02/2013 - Ajustes para o novo tipo de emprestimo (Gabriel).

                 11/03/2013 - Conversão Progress >> Oracle PL-Sql (Marcos-Supero)

                 27/03/2013 - Ajuste para usar o nrcpfcgc para verificar se o
                              mesmo esta em algum grupo economico (Adriano).

                 18/04/2013 - Ajustes realizados:
                            - Alterado "FIND crabris" para "FIND LAST crabris"
                              na procedure risco_h;
                            - Incluido "w-crapris.cdorigem = crapris.cdorigem"
                              no "FIRST w-crapris" da linha 643;
                            - Alimentado o campo cdorigem no create da
                              w-crapris (Adriano).

                 02/05/2013 - Alterada a busca do risco para gerar lista do risco(H)
                              pois havia sido utilizada uma solução alternativa para
                              garantir o mesmo comportanto que o Find no Progress, e
                              como foi corrigido no Progress para Find-last, podemos
                              deixar o teste correto. (Marcos-Supero)

                 24/05/2013 - Incluido o campo qtdiaatr na temp-table typ_reg_crapris.
                            - Ajustes referente ao acrescimo de uma coluna nos
                              relatorios 354.lst, 354.txt, 227.lst com os dias em
                              atraso dos emprestimos).
                            - Alimentado a "aux_qtprecal_deci = crapepr.qtprecal"
                              para quando for mensal (Marcos-Supero).

                 19/06/2013 - Alterado condição crabris.dtrefere >= aux_dtrefere
                              para crabris.dtrefere = aux_dtrefere.
                              Utilizado no relat. 552. (Marcos-Supero)

                 19/06/2013 - Tratar os dias de atraso da mesma maneira que a
                              includes crps398.i (Marcos-Supero).

                 21/06/2013 - Tratamento para criação do campo
                              w-crapris.nrseqctr (Lucas).

                 09/07/2013 - Salva o crrl354 da CREDCREA no /micros (Ze).

                 26/08/2013 - Incluido caminhos para geracao do arquiv crrl354.txt
                              para todas cooperativas (Marcos-Supero).

                 05/09/2013 - Incluido uma coluna ao final do arquivo crrl354.txt
                              com o valor total do atraso atualizado do dia da
                              geração do arquivo é o mesmo valor que vem da tela
                              atenda .

                              Leitura da crapebn quando crapris.cdorigem = 3
                              para verificar se eh emprestimo do BNDES.

                              Atribuicao do conteudo 'BNDES' para a coluna LC,
                              quando este for emprestimo do BNDES. Para isso,
                              alterado o tipo do campo w-crapris.cdlcremp, de
                              INTE para CHAR.

                              Incluido caminhos para geracao do arquiv crrl354.txt
                              para todas cooperativas. (Gabriel).

                 30/09/2013 - Incluido a chamada da procedure
                              "atualiza_dados_gerais_emprestimo"
                              "atualiza_dados_gerais_conta" para os contratos
                              que nao ocorreram debito (Gabriel).

                            - Alteradas Strings de PAC para PA. (Gabriel)

                 30/10/2013 - Atualizar o campo dtatufin da tabela crapcyb.(Gabriel)

                 30/10/2013 - Adicionado FORMAT para variável rel_vljura60.
                              (Gabriel)

                 30/10/2013 - Ajustado para nao atualizar a data de atualizacao
                              financeira no cyber, quando o valor a regularizar
                              for igual 0. (Gabriel)

                 11/11/2013 - Remover arquivo 354.txt do /arq (Gabriel).

                 13/11/2013 - Ajustes no crps354.txt para manter igualdade ao
                              progress (Gabriel).

                 19/11/2013 - Ajustes para evitar erro no tratamento do cyber
                              (Gabriel)

                 29/11/2013 - Ajuste para tratar quantidade de parcelas negativas
                              para os emprestimos "Price Prefixados" (Gabriel).

                 17/12/2013 - Atualizar o campo tt-crapcyb.dtdpagto dos contratos
                              de emprestimos que estão no Cyber. (Gabriel)

                 17/12/2013 - Alterada procedure verifica_conta_altovale_280
                              para verifica_conta_migracao_280 que despreza
                              as contas migradas (Gabriel).

                 17/12/2013 - Alterado forma de calculo da inadimplencia nos
                             relatorios 354 e 227, deduzido da variavel
                             tot_vlropera o valor total de juros atraso +60.
                             (Gabriel)

                 19/12/2013 - Adicionado PAs na condicao da craptco para
                              migracao acredi (Gabriel).

                 14/02/2014 - Correção no export do crrl354.lst conforme regra
                              do Progress (Marcos-Supero)

                 17/02/2014 - Ajustes no fluxo para cópia do crrl354.txt (Marcos-Supero)

                 07/01/2014 - Ajuste para melhorar performance (James).

                 03/02/2014 - Remover a chamada da procedure
                              "obtem-dados-emprestimo" (James)

                 11/02/2014 - Ajuste para criar os registros no CYBER (James)

                 21/02/2014 - Ajuste para rodar na mensal (James)

                 07/03/2014 - Manutenção 201402 (Edison-Amcom)

                 02/04/2014 - Ajuste para calcular o campo "w-crapris.nroprest"
                              para o novo tipo de emprestimo. (James)

                 09/04/2014 - Ajustes devido a revalidação
                  
                 16/04/2014 - Projeto padronização das linhas de crédito
                              alterado relatório 552 para receber coluna de 
                              finalidade. (Reinert)
                              
                 30/04/2014 - Ajustes nos caracteres de quebra de linha (Marcos)

                 05/05/2014 - Ajuste no envio dos dados para o CYBER. (James)
                 
                 23/05/2014 - Ajustado para converter o relatorio(ux2dos) antes 
                              de envia-lo por e-mail(Odirlei-AMcom)  

                 17/10/2014 - Inserido tratamento para migracao da 
                              Concredi->Viacredi e Credimilsul->Scrcred. (Jaison)
                              
                 20/10/2014 - Ajustado para efetuar o arrendondamento no percentual
                              da variavel med_atrsinad (chamado 179276) (Andrino-RKAM)              
                              
                 22/10/2014 - Nova regra quanto ao Saldo Bloqueado liberado ao Cooperado,
                              pois a partir de agora esta informação está incorporada ao 
                              mesmo risco do Adiantamento a Depositante (AD). 
                              Desta forma removemos a lista Outros Empréstimos, já que 
                              não haverá mais riscos nesta situação (Marcos-Supero)             
                              
                 24/10/2014 - Incluido novas linhas de credito de desconto. (James)
                 
                 03/02/2015 - Inclusão dos contrados de limite não  utilizado (IndDocto=3) 
                              nos relatórios 227 e 354 (Marcos-Supero)
                              
                 15/04/2015 - Projeto de separação contábeis de PF e PJ.
                              (Andre Santos - SUPERO)                           
                 26/06/2015 - Projeto 215 - DV 3 (Daniel)   
         
                 02/07/2015 - Ajuste para atualizar o risco da proposta de emprestimo. (James)
                 
                 11/01/2016 - (Chamado 372817) Coluna qtd dias atraso do relatório 354
                              nao estava aparesentando o valor correto(Tiago Castro - RKAM).
                              
                 18/01/2016 - (Chamado 386297) Considerar o total da carteira no calculo
                              da inadimplencia. (James)
                              
                 03/06/2016 - Ajuste no cursor cr_crapris para somente buscar do dia. (James)
                              
                 26/08/2016 - Alteracao na forma de leitura da CRAPVRI cujo resultado foi
                              um ganho em performance e tempo de execucao. (Carlos R. Tanholi)             

                 30/08/2016 - Remover a validação do risco pela regra (vr_percentu <> 0.5) e 
                              realizar a validação atráves do nível do risco.
                              
                 22/12/2016 - Alteracoes para melhorar a performance deste programa. SD 573847.
                              (Carlos R. Tanholi)

                 22/02/2017 - Ajustes referente ao Prj.307 Automatização Arquivos Contábeis Ayllos 
                              Inclusão de informações no crrl227 e criçãode novos arquivos para o
                              Radar e Matera (Jonatas-Supero)   

                 23/03/2017 - Ajustes PRJ343 - Cessao de credito.
                              (Odirlei-AMcom)   
                
                 23/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)

                 05/09/2017 - Ajustado para gerar os historicos separadamente no arquivo AJUSTE_MICROCREDITO
                              (Rafael Faria - Supero)

                 16/01/2018 - Somente chamar a rotina de atualizacao dos dados financeiros para o Cyber
                              caso a cooperativa conectada seja uma singular. (Chamado 831629) - (Fabricio)

                 19/01/2017 - Regra (IF pr_cdprogra = 'CRPS280' THEN) comentada para o projeto Contratação de Crédito 
                              Backlog Item 4403:Alteração regra no Risco da Melhora - 6 meses
                  (Daniel Junior - AMcom)

           01/03/2018 - Alterado a Data do Risco e Quantidade de Dias Risco para considerar a diária
                nos relatórios 354 e 227. (Diego Simas - AMcom)

         07/03/2018 - Incluído nova coluna (JUR +60 REF) nos relatórios 354 e 227. (Diego Simas - AMcom)

  ............................................................................. */

   DECLARE
      -- Constante
      vr_flgerar  CHAR(1) := 'S';
      -- Tratamento de erros
      vr_exc_erro exception;
      -- Erro em chamadas da pc_gera_erro
      vr_des_reto VARCHAR(3);
      vr_tab_erro GENE0001.typ_tab_erro;
      -- Desvio de fluxo para ingorar o registro
      vr_exc_ignorar EXCEPTION;
      -- chave de indice 
      vr_chave_index VARCHAR2(240);    

      -- Constante para usar em indice do primeiro nivel
      vr_vlfinanc_pf CONSTANT VARCHAR2(10) := 'VLFINANCPF'; -- Valor Financiamento PF
      vr_vlfinanc_pj CONSTANT VARCHAR2(10) := 'VLFINANCPJ'; -- Valor Financiamento PJ   
      vr_vlempres_pf CONSTANT VARCHAR2(10) := 'VLEMPRESPF'; -- Valor Emprestimo PF
      vr_vlempres_pj CONSTANT VARCHAR2(10) := 'VLEMPRESPJ'; -- Valor Emprestimo PJ 
      vr_vlchqdes    CONSTANT VARCHAR2(10) := 'VLCHQDES';   -- Valor Cheque Descontado
      vr_vltitdes_cr CONSTANT VARCHAR2(10) := 'VLTITDESCR'; -- Valor Titulo Descontado Com Registro
      vr_vltitdes_sr CONSTANT VARCHAR2(10) := 'VLTITDESCR'; -- Valor Titulo Descontado Sem Registro
      vr_vladtdep    CONSTANT VARCHAR2(10) := 'VLADTDEP';   -- Valor Adiantamento Depositante
      vr_vlchqesp    CONSTANT VARCHAR2(10) := 'VLCHQESP';   -- Valor Cheque Especial
      vr_vleprces    CONSTANT VARCHAR2(10) := 'VLEPRCES'; -- Valor Emprestimo PF
      -- Constante para usar em indice do segundo nivel
      vr_provis      CONSTANT VARCHAR2(10) := 'PROVIS';     -- Coluna de Provisao do relat 227
      vr_divida      CONSTANT VARCHAR2(10) := 'DIVIDA';     -- Coluna de Divida do relat 227

      ---------- Cursores Genéricos ----------

      -- Cursor genérico de parametrização --
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE
                       ,pr_tpregist IN craptab.tpregist%TYPE) IS
        SELECT tab.dstextab
              ,tab.tpregist
          FROM craptab tab
         WHERE tab.cdcooper        = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres        = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso
           AND tab.tpregist        >= pr_tpregist
         ORDER BY tab.progress_recid;
      rw_craptab cr_craptab%ROWTYPE;

      -------- Tipos e registros genéricos ------------

      -- Definição do tipo de registro para englobar descrições e percentuais dos riscos A, B, C, etc...
      -- Obs: Na versao antiga do programa, cada campo era um vetor, na nova, todos os campos
      --      ficam presentes num unico registro da tabela vr_tab_risco
      TYPE typ_reg_risco IS
        RECORD(dsdrisco VARCHAR2(2)   -- "x(02)"
              ,percentu NUMBER(5,2)); -- "zz9.99"

      -- Definicao do tipo de tabela de riscos
      TYPE typ_tab_risco IS
        TABLE OF typ_reg_risco
          INDEX BY PLS_INTEGER;
          
      -- Pl-Table para gravar valores contah por tipo de pessoa com o index - 1-Fisico/2-Juridico         
      TYPE typ_reg_total IS
        RECORD(vlfinanc_pf NUMBER   -- Valor Financiamento Pessoa Fisica
              ,vlfinanc_pj NUMBER   -- Valor Financiamento Pessoa Juridica
              ,vlempres_pf NUMBER   -- Valor Emprestimo
              ,vlempres_pj NUMBER   -- Valor Emprestimo
              ,vlchqdes NUMBER      -- Valor Cheque Descontado
              ,vltitdes_cr NUMBER   -- Valor Titulo Descontado
              ,vltitdes_sr NUMBER   -- Valor Titulo Descontado
              ,vladtdep NUMBER      -- Valor Adiantamento Depositante
              ,vlchqesp NUMBER);    -- Valor Cheque Especial

      -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
      TYPE typ_tab_total IS TABLE OF typ_reg_total INDEX BY PLS_INTEGER;
      
      -- Instancia e indexa por tipo de pessoa com o index - 1-Fisico/2-Juridico
      TYPE typ_tab_coluna IS TABLE OF typ_tab_total INDEX BY VARCHAR2(10);
      
      -- Dados Para Contabilidade - 1-Fisico/2-Juridico
      TYPE typ_tab_contab IS TABLE OF typ_tab_coluna INDEX BY VARCHAR2(10);

      -- Vetor para armazenar os dados de riscos
      vr_tab_risco typ_tab_risco;
      -- Vetor auxiliar para guardar uma posição a mais
      vr_tab_risco_aux typ_tab_risco;
      -- Vetor auxiliar para guardar uma posição a mais
      vr_tab_contab    typ_tab_contab;
      -- Vetor auxiliar para guardar uma posição a mais
      vr_tab_contab_cessao    typ_tab_contab;


      -- Registro para as informações copiadas da tabela crapris (Antigo w-crapris)
      TYPE typ_reg_crapris IS
        RECORD(cdagenci crapage.cdagenci%TYPE  --> Chave Asc
              ,nroprest NUMBER                 --> Chave Desc
              ,nmprimtl crapass.nmprimtl%TYPE  --> Chave Asc
              ,nrdconta crapris.nrdconta%TYPE
              ,nrcpfcgc crapris.nrcpfcgc%TYPE
              ,dtrefere crapris.dtrefere%TYPE
              ,innivris crapris.innivris%TYPE
              ,nrctremp crapris.nrctremp%TYPE
              ,vlpreemp crapepr.vlpreemp%TYPE
              ,cdlcremp VARCHAR2(10)
              ,qtatraso NUMBER
              ,qtdiaatr PLS_INTEGER
              ,cdmodali crapris.cdmodali%TYPE
              ,nrseqctr crapris.nrseqctr%TYPE
              ,vldivida crapris.vldivida%TYPE
              ,vljura60 crapris.vljura60%TYPE
              ,cdorigem crapris.cdorigem%TYPE
              ,inpessoa crapris.inpessoa%TYPE
              ,qtdriclq crapris.qtdriclq%TYPE
              ,cdfinemp crapepr.cdfinemp%TYPE
              ,dsinfaux crapris.dsinfaux%TYPE
              ,tpemprst VARCHAR2(10)
              ,cdusolcr craplcr.cdusolcr%TYPE
              ,dsorgrec craplcr.dsorgrec%TYPE
              ,dtinictr crapris.dtinictr%TYPE
              ,fleprces INTEGER);

      -- Definição de um tipo de tabela com o registro acima
      TYPE typ_tab_crapris IS
        TABLE OF typ_reg_crapris
          INDEX BY VARCHAR2(150);

      -- Tabela para armazenar os registros da crapris em processo
      vr_tab_crapris typ_tab_crapris;

      -- Variavel para chaveamento da tabela de riscos
      -- Agencia(5) + NroPrest(12) + NmPrintl(60) + NrCtrEmp(10) + NrSeqCtr(5)
      -- NrdConta(10) + DtRefere(8) + InNivRis(5)
      vr_des_chave_crapris VARCHAR2(150);

      -- Definição de registro para totalização dos riscos
      TYPE typ_reg_totris IS
        RECORD(qtdabase INTEGER   -- "zzz,zz9"
              ,vldabase NUMBER    -- "zzz,zzz,zzz,zz9.99"
              ,vljura60 NUMBER    --
              ,vljrpf60 NUMBER    --
              ,vljrpj60 NUMBER    --
              ,vlprovis NUMBER);  -- "zzz,zzz,zzz,zz9.99"

      -- Definicao do tipo de tabela de totalização de riscos
      TYPE typ_tab_totris IS
        TABLE OF typ_reg_totris
          INDEX BY PLS_INTEGER;

      -- Vetor para armazenar a totalização dos riscos por PAC
      vr_tab_totrispac typ_tab_totris;
      -- Vetor para armazenar a totalização dos riscos geral
      vr_tab_totrisger typ_tab_totris;

      -- Tipo de registro para as informações da contabilidade
      TYPE typ_reg_contabi IS
        RECORD(rel1731_1      NUMBER(14,2) DEFAULT 0  -- Financiamentos Pessoais [Provisao]
              ,rel1731_1_v    NUMBER(14,2) DEFAULT 0  -- Financiamentos Pessoais [Divida(S/Prejuizo)]
              ,rel1731_2      NUMBER(14,2) DEFAULT 0  -- Financiamentos Empresas [Provisao]
              ,rel1731_2_v    NUMBER(14,2) DEFAULT 0  -- Financiamentos Empresas [Divida(S/Prejuizo)]
              ,rel1721        NUMBER(14,2) DEFAULT 0  -- Emprestimos Pessoais [Provisao]
              ,rel1721_v      NUMBER(14,2) DEFAULT 0  -- Emprestimos Pessoais [Divida(S/Prejuizo)]
              ,rel1723        NUMBER(14,2) DEFAULT 0  -- Emprestimos Empresas [Provisao]
              ,rel1723_v      NUMBER(14,2) DEFAULT 0  -- Emprestimos Empresas [Divida(S/Prejuizo)]
              ,rel1724_c      NUMBER(14,2) DEFAULT 0  -- Cheques Descontados [Provisao]
              ,rel1724_v_c    NUMBER(14,2) DEFAULT 0  -- Cheques Descontados [Divida(S/Prejuizo)]
              ,rel1724_cr     NUMBER(14,2) DEFAULT 0  -- Titulos Desc. C/Registro [Provisao]
              ,rel1724_v_cr   NUMBER(14,2) DEFAULT 0  -- Titulos Desc. C/Registro [Divida(S/Prejuizo)]
              ,rel1724_sr     NUMBER(14,2) DEFAULT 0  -- Titulos Desc. S/Registro [Provisao]
              ,rel1724_v_sr   NUMBER(14,2) DEFAULT 0  -- Titulos Desc. S/Registro [Divida(S/Prejuizo)]
              ,rel1722_0101   NUMBER(14,2) DEFAULT 0  -- Adiant.Depositante [Provisao]
              ,rel1722_0101_v NUMBER(14,2) DEFAULT 0  -- Adiant.Depositante [Divida(S/Prejuizo)]
              ,rel1722_0201   NUMBER(14,2) DEFAULT 0  -- Cheque Especial [Provisao]
              ,rel1722_0201_v NUMBER(14,2) DEFAULT 0  -- Cheque Especial [Divida(S/Prejuizo)]
              ,rel1760        NUMBER(14,2) DEFAULT 0  -- Emprestimos cessao [Provisao]
              ,rel1760_v      NUMBER(14,2) DEFAULT 0  -- Emprestimos cessao [Divida(S/Prejuizo)]
              );

      -- Criação de um vetor com base nesse registro
      vr_vet_contabi typ_reg_contabi;

      -- Estrutra de PL Table para tabela CRAPTCO 
      TYPE typ_tab_craptco 
        IS TABLE OF crapass.nrdconta%TYPE
          INDEX BY PLS_INTEGER;

      vr_tab_craptco typ_tab_craptco;      

      -- Definição de registro para totalização por origem de microcrédito
      TYPE typ_reg_microcredito IS
        RECORD(idgrumic INTEGER   -- Id do grupo para separação das informações - 1 - CECRED / 2 - BNDES
              ,vlpesfis NUMBER    -- Valor acumulado das operações no MicroCrédito para Pessoas Físicas
              ,vlpesjur NUMBER    -- Valor acumulado das operações no MicroCrédito para Pessoas Jurídicas
              ,vlate59d NUMBER    -- Valor acumulado das operações no MicroCrédito com prazo até 59 dias
              ,vlaci59d NUMBER);  -- Valor acumulado das operações no MicroCrédito com prazo acima de 59 dias

      -- Definicao do tipo de tabela totalização por origem de microcrédito
      TYPE typ_tab_microcredito IS
        TABLE OF typ_reg_microcredito
          INDEX BY craplcr.dsorgrec%type;

      -- Vetor para armazenar a totalização por origem de microcrédito
      vr_tab_microcredito typ_tab_microcredito;     
      
      -- Definição de registro para totalização por finalidade de microcrédito
      TYPE typ_reg_miccred_fin IS
        RECORD(vllibctr    NUMBER   -- Valor acumulado liberação de contratos
              ,vlaprrec    NUMBER   -- Valor acumulado apropriação de receitas
              ,vlprvper    NUMBER   -- Valor acumulado provisão de perdas
              ,vldebpar91  NUMBER   -- Valor acumulado débito de parcelas historico 91
              ,vldebpar95  NUMBER   -- Valor acumulado débito de parcelas historico 95
              ,vldebpar441 NUMBER); -- Valor acumulado débito de parcelas historico 441

      -- Definicao do tipo de tabela totalização por finalidade de microcrédito
      TYPE typ_tab_miccred_fin IS
        TABLE OF typ_reg_miccred_fin
          INDEX BY VARCHAR2(5);

      -- Vetor para armazenar a totalização por finalidade de microcrédito
      vr_tab_miccred_fin typ_tab_miccred_fin; 
      
      -- Definição de registro para totalização por nível de risco de microcrédito
      TYPE typ_reg_miccred_nivris IS
        RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

      -- Definicao do tipo de tabela totalização por nível de risco de microcrédito
      TYPE typ_tab_miccred_nivris IS
        TABLE OF typ_reg_miccred_nivris
          INDEX BY crawepr.dsnivris%type;

      -- Vetor para armazenar a totalização por nível de risco de microcrédito
      vr_tab_miccred_nivris typ_tab_miccred_nivris;  
      
      
      -- Definição de registro para totalização por nível de risco de FINAME
      TYPE typ_reg_finame_nivris IS
        RECORD(vlslddev NUMBER);  -- Valor acumulado saldo devedor

      -- Definicao do tipo de tabela totalização por nível de risco de FINAME
      TYPE typ_tab_finame_nivris IS
        TABLE OF typ_reg_finame_nivris
          INDEX BY crawepr.dsnivris%type;

      -- Vetor para armazenar a totalização por nível de risco de FINAME
      vr_tab_finame_nivris typ_tab_finame_nivris;
          

      ---------- Cursores específicos do processo ----------

      -- Busca do arquivo para controle de informaçõs da central de risco
      CURSOR cr_crapris IS
        SELECT ris.nrdconta
              ,DECODE(ass.inpessoa,3,2,ass.inpessoa) inpessoa /* Tratamento para Pessoa Administrativa considerar com PJ*/
              ,ris.nrcpfcgc
              ,ris.dtrefere
              ,ris.innivris
              ,ris.nrctremp
              ,ris.cdorigem
              ,ris.qtdiaatr
              ,ris.cdmodali
              ,ris.nrseqctr
              ,ris.vldivida
              ,ris.vljura60
              ,ris.qtdriclq
              ,ass.cdagenci
              ,ass.nmprimtl
              ,ris.dsinfaux
              ,ris.dtinictr
          FROM crapass ass
              ,crapris ris
         WHERE ris.cdcooper  = ass.cdcooper
           AND ris.nrdconta  = ass.nrdconta
           AND ris.cdcooper  = pr_cdcooper
           AND ris.dtrefere  = pr_dtrefere
           AND ris.inddocto  = 1 -- Docto 3020
           AND ris.vldivida  > 0; 
           
      -- Buscar o valor do Juros +60 Refinanciado
      CURSOR cr_juros60_ref(pr_nrdconta IN crapris.nrdconta%TYPE
                           ,pr_nrctremp IN crapris.nrctremp%TYPE) IS
      SELECT SUM(tlf.vljuros60) vljura60
        FROM crawepr crwpr,
             crapepr epr,
             tbepr_liquidado_financiado tlf,
             crapass ass 
       WHERE (crwpr.nrctrliq##1   = tlf.nrctremp
        OR    crwpr.nrctrliq##2 = tlf.nrctremp
        OR    crwpr.nrctrliq##3 = tlf.nrctremp
        OR    crwpr.nrctrliq##4 = tlf.nrctremp
        OR    crwpr.nrctrliq##5 = tlf.nrctremp
        OR    crwpr.nrctrliq##6 = tlf.nrctremp
        OR    crwpr.nrctrliq##7 = tlf.nrctremp
        OR    crwpr.nrctrliq##8 = tlf.nrctremp
        OR    crwpr.nrctrliq##9 = tlf.nrctremp
        OR    crwpr.nrctrliq##10= tlf.nrctremp)
        AND   crwpr.nrctremp = epr.nrctremp
        AND   crwpr.cdcooper = epr.cdcooper
        AND   crwpr.cdagenci = epr.cdagenci
        AND   crwpr.nrdconta = epr.nrdconta
        AND   epr.cdcooper   = tlf.cdcooper
        AND   epr.nrdconta   = tlf.nrdconta  
        AND   tlf.cdcooper   = ass.cdcooper
        AND   tlf.nrdconta   = ass.nrdconta
        AND   epr.cdcooper   = pr_cdcooper
        AND   epr.nrdconta   = pr_nrdconta
        AND   epr.nrctremp   = pr_nrctremp
        GROUP BY epr.nrctremp;
        rw_juros60_ref cr_juros60_ref%ROWTYPE;
         
      vr_juros60_ref   NUMBER:=0;  
      vr_nrctremp_refi VARCHAR2(300);   

      -- Busca de registro de transferência entre cooperativas
      CURSOR cr_craptco_via_alto IS
        SELECT tco.nrdconta
          FROM craptco tco
         WHERE tco.cdcooper = pr_cdcooper
           AND tco.cdcopant = 1
           AND tco.tpctatrf <> 3;

      CURSOR cr_craptco_acredi_via IS
        SELECT tco.nrdconta
          FROM craptco tco
         WHERE tco.cdcooper = pr_cdcooper
           AND tco.cdcopant = 2
           AND tco.tpctatrf <> 3
           AND tco.cdageant IN (2,4,6,7,11);

      CURSOR cr_craptco_concredi_via IS
        SELECT tco.nrdconta
          FROM craptco tco
         WHERE tco.cdcooper = pr_cdcooper
           AND tco.cdcopant = 4
           AND tco.tpctatrf <> 3;

      CURSOR cr_craptco_credimilsul_scrcred IS
        SELECT tco.nrdconta
          FROM craptco tco
         WHERE tco.cdcooper = pr_cdcooper
           AND tco.cdcopant = 15
           AND tco.tpctatrf <> 3;

      -- Busca dos limites não utilizados
      CURSOR cr_ris_liminutz IS
        SELECT ris.nrdconta
              ,ris.vldivida
              ,ris.inpessoa
          FROM crapris ris
         WHERE ris.cdcooper  = pr_cdcooper
           AND ris.dtrefere >= pr_dtrefere
           AND ris.inddocto  = 3; -- Docto 3020 (Limite Não Utilizado

      -- Buscar detalhes dos empréstimos
      CURSOR cr_crapepr(pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT epr.qtmesdec
              ,epr.dtdpagto
              ,epr.qtprecal
              ,epr.vlsdeved
              ,epr.qtpreemp
              ,epr.vlpreemp
              ,epr.cdlcremp
              ,epr.tpemprst
              ,epr.flgpagto
              ,epr.qtlcalat
              ,epr.qtpcalat
              ,epr.txmensal
              ,epr.vlsdevat
              ,epr.inliquid
              ,epr.txjuremp
              ,epr.nrdconta
              ,epr.nrctremp
              ,epr.vlpapgat
              ,epr.qtmdecat
              ,epr.inprejuz
              ,epr.cdfinemp
              ,epr.dtmvtolt
              ,epr.vlemprst
              ,epr.tpdescto
              ,epr.vlppagat
              ,epr.vljurmes
              ,(SELECT ces.dtvencto
                  FROM tbcrd_cessao_credito ces
                 WHERE ces.cdcooper = epr.cdcooper
                   AND ces.nrdconta = epr.nrdconta
                   AND ces.nrctremp = epr.nrctremp ) dtvencto_original
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Buscar detalhes do emprestimo BNDES
      CURSOR cr_crapebn (pr_nrdconta IN crapebn.nrdconta%TYPE
                        ,pr_nrctremp IN crapebn.nrdconta%TYPE) IS
        SELECT ebn.vlparepr
          FROM crapebn ebn
         WHERE ebn.cdcooper = pr_cdcooper
           AND ebn.nrdconta = pr_nrdconta
           AND ebn.nrctremp = pr_nrctremp;

      -- Buscar detalhes do saldo da conta
      CURSOR cr_crapsld(pr_nrdconta IN crapsld.nrdconta%TYPE) IS
        SELECT sld.qtdriclq
          FROM crapsld sld
         WHERE sld.cdcooper = pr_cdcooper
           AND sld.nrdconta = pr_nrdconta;
      rw_crapsld cr_crapsld%ROWTYPE;

      -- Buscar nome da agência
      CURSOR cr_crapage(pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT nmresage
          FROM crapage
         WHERE cdcooper = pr_cdcooper
           AND cdagenci = pr_cdagenci;
      vr_nmresage crapage.nmresage%TYPE;

      -- Testar a existência de risco na data passada, tipo e dcmto passado
      CURSOR cr_crapris_tst(pr_nrdconta IN crapris.nrdconta%TYPE
                           ,pr_innivris IN crapris.innivris%TYPE
                           ,pr_dtini IN crapris.dtrefere%TYPE
                           ,pr_dtfim IN crapris.dtrefere%TYPE
                           ,pr_inddocto IN crapris.inddocto%TYPE) IS
                           
        SELECT COUNT(DISTINCT ris.dtrefere) AS exis_crapris
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.nrdconta = pr_nrdconta
           AND ris.innivris = pr_innivris
           AND ris.dtrefere BETWEEN pr_dtini AND pr_dtfim
           AND ris.inddocto = pr_inddocto;
           
      vr_exis_crapris NUMBER;


      CURSOR cr_crapvri(pr_dtrefere IN crapris.dtrefere%TYPE) IS 
      SELECT nrdconta
            ,innivris
            ,cdmodali        
            ,nrctremp        
            ,nrseqctr        
            ,SUM(DECODE(greatest(cdvencto,110),cdvencto,DECODE(LEAST(cdvencto,290),cdvencto, vldivida,0),0)) vldivida
            ,SUM(DECODE(greatest(cdvencto,205),cdvencto,DECODE(LEAST(cdvencto,290),cdvencto, vldivida,0),0)) vltotatr
            ,COUNT(DISTINCT DECODE(greatest(cdvencto,205),cdvencto,DECODE(LEAST(cdvencto,290),cdvencto, 1,NULL),NULL)) qtpreatr
            ,SUM(DECODE(cdvencto, 310, vldivida, 320, vldivida, 330, vldivida, 0) ) vlprejuz
        FROM crapvri
       WHERE cdcooper = pr_cdcooper
         AND dtrefere = pr_dtrefere
    GROUP BY nrdconta,innivris,cdmodali,nrctremp,nrseqctr;
          
    TYPE typ_crapvri IS TABLE OF cr_crapvri%ROWTYPE                            index by PLS_INTEGER;
    vr_tab_crapvri typ_crapvri;
    
    
    --Type para armazenar as os associados
    type typ_reg_crapvri is record (vldivida crapvri.vldivida%TYPE,
                                    vltotatr crapvri.vldivida%TYPE,
                                    qtpreatr crapass.qtfoltal%TYPE,
                                    vlprejuz crapvri.vldivida%TYPE);

    type typ_tab_reg_crapvri is table of typ_reg_crapvri index by VARCHAR2(240);
    vr_tab_crapvri_index typ_tab_reg_crapvri;    
    

      -- Testar a existência de Rating efetivo
      CURSOR cr_crapnrc(pr_nrdconta IN crapnrc.nrdconta%TYPE) IS
        SELECT 1
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND insitrat = 2;

      -- Testar a existência de Rating por contrato
      CURSOR cr_contrato_nrc(pr_nrdconta IN crapnrc.nrdconta%TYPE
                            ,pr_nrctrrat IN crapnrc.nrctrrat%TYPE
                            ,pr_tpctrrat IN crapnrc.nrctrrat%TYPE) IS
        SELECT indrisco
          FROM crapnrc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrrat = pr_nrctrrat
           AND tpctrrat = pr_tpctrrat;

      -- Buscar nível de risco do empréstimo
      CURSOR cr_crawepr(pr_nrdconta IN crawepr.nrdconta%TYPE
                       ,pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT dsnivris,
               rowid
          FROM crawepr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;
      
      -- Buscar quantidade de meses através dos registros na crapris
      CURSOR cr_crapris_count(pr_nrdconta IN crapris.nrdconta%TYPE
                             ,pr_nrctremp IN crapris.nrctremp%TYPE
                             ,pr_cdorigem IN crapris.cdorigem%TYPE) IS
        SELECT COUNT(1)
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.nrdconta = pr_nrdconta
           AND ris.nrctremp = pr_nrctremp
           AND ris.cdorigem  = pr_cdorigem
           AND ris.dtrefere >= pr_dtrefere - 190;
      vr_qtd_crapris NUMBER;

      -- Testar a existência de risco na data passada, origem, modalidade e docto
      CURSOR cr_crapris_est(pr_nrdconta IN crapris.nrdconta%TYPE
                           ,pr_cdorigem IN crapris.cdorigem%TYPE
                           ,pr_cdmodali IN crapris.cdmodali%TYPE
                           ,pr_dtrefere IN crapris.dtrefere%TYPE
                           ,pr_inddocto IN crapris.inddocto%TYPE) IS
        SELECT 1
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.nrdconta = pr_nrdconta
           AND ris.cdmodali = pr_cdmodali
           AND ris.cdorigem = pr_cdorigem
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = pr_inddocto;
      vr_flgexis_estouro NUMBER;

      -- Retornar ultimo lançamento de risco para a data e tipo de documento passado
      CURSOR cr_crapris_last(pr_nrdconta IN crapris.nrdconta%TYPE
                               ,pr_dtrefere IN crapris.dtrefere%TYPE) IS
        SELECT /*+ INDEX (ris CRAPRIS##CRAPRIS1) */
              'S' ind_achou
              ,ris.innivris
              ,ris.dtdrisco
              ,ris.vldivida
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.nrdconta = pr_nrdconta
           AND ris.dtrefere = pr_dtrefere
           AND ris.inddocto = 1
        ORDER BY CDCOOPER DESC, NRDCONTA DESC, DTREFERE DESC, INNIVRIS DESC;

      rw_crapris_last cr_crapris_last%ROWTYPE;

      -- Verifica se a conta em questao pertence a algum grupo economico
      CURSOR cr_crapgrp(pr_nrcpfcgc IN crapgrp.nrcpfcgc%TYPE) IS
        SELECT '*'
          FROM crapgrp
         WHERE cdcooper = pr_cdcooper
           AND nrcpfcgc = pr_nrcpfcgc;

      /* Cursor de Linha de Credito */
      CURSOR cr_craplcr (pr_cdcooper IN craplcr.cdcooper%TYPE
                        ,pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT craplcr.cdlcremp
              ,craplcr.dsoperac
              ,craplcr.txmensal
              ,craplcr.txdiaria
              ,craplcr.cdusolcr
              ,craplcr.dsorgrec              
        FROM craplcr
        WHERE craplcr.cdcooper = pr_cdcooper
        AND   craplcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      CURSOR cr_craplem(pr_nrdconta IN craplem.nrdconta%TYPE
                       ,pr_nrctremp IN craplem.nrctremp%TYPE) IS 
        SELECT lem.cdhistor
              ,NVL(SUM(lem.vllanmto),0) vllanmto
          FROM craplem lem
         WHERE lem.cdcooper = pr_cdcooper
           AND lem.nrdconta = pr_nrdconta
           AND lem.nrctremp = pr_nrctremp
           AND lem.dtmvtolt BETWEEN TRUNC(pr_rw_crapdat.dtmvtolt,'MM') AND pr_rw_crapdat.dtmvtolt
           AND lem.cdhistor in (91,95,441) --> Pagamentos / juros
         GROUP BY lem.cdhistor; 

      CURSOR cr_craplim(pr_nrdconta IN craplim.nrdconta%TYPE
                       ,pr_nrctremp IN craplim.nrctrlim%TYPE) IS 
        SELECT count(*) existe_contrato_finame
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.nrctrlim = pr_nrctremp
           AND lim.tpctrlim = 1  --> Cheque especial
           AND lim.insitlim = 2  --> Ativo
           AND lim.cddlinha = 2; --> Linha BNDES Finame;  
      rw_craplim cr_craplim%ROWTYPE;
      
      CURSOR cr_crapris_reccaixa IS
        SELECT cop.nmrescop,
               LTRIM(gene0002.fn_mask(epr.nrctremp,'zz.zzz.zz9')) nrctremp,
               ris.dtinictr,
               epr.vlemprst,
               epr.vlsdeved
          FROM crapris ris
              ,crapepr epr
              ,crapcop cop
         WHERE ris.nrdconta = epr.nrdconta
           AND ris.nrctremp = epr.nrctremp
           AND ris.cdcooper = epr.cdcooper
           AND epr.nrdconta = cop.nrctactl
           AND ris.nrdconta = epr.nrdconta
           AND ris.nrctremp = epr.nrctremp           
           and epr.vlsdeved > 0
           AND epr.cdfinemp = 1
           AND ris.cdorigem = 3
           AND ris.dtrefere = pr_dtrefere           
           AND ris.cdcooper = pr_cdcooper
        ORDER BY cop.nmrescop,
                 epr.nrctremp;
      
      -- Variaveis para o retorno da pc_obtem_dados_empresti
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;

      -- Variaveis auxiliares
      vr_contador  INTEGER;     -- Contador para a tabela de riscos

      --  Variaveis para o calculo de empréstimo
      vr_qtmesdec       NUMBER;       --> Quantidade decimal de meses decorrentes
      vr_qtprecal_decim NUMBER;       --> Quantidade para calculo de parcelas em atraso (em decimal)
      vr_qtprecal_intei INTEGER;      --> Quantidade para calculo de parcelas em atraso
      vr_vlsdeved_atual NUMBER(11,2); --> Saldo devedor pra calculo atual
      vr_inusatab       BOOLEAN;      --> Indicador S/N de utilização de tabela de juros

      vr_fleprces       INTEGER;      --> Indicador se emprestimo de Cessao.
      
      -- Variaveis temporárias para gravação da tabela crapris somente após processar
      vr_vlpreemp crapepr.vlpreemp%TYPE;
      vr_cdlcremp VARCHAR2(10);
      vr_nroprest NUMBER;
      vr_qtatraso NUMBER;
      vr_qtdiaatr PLS_INTEGER;
      vr_cdfinemp crapepr.cdlcremp%TYPE;

      -- Variaveis para o retorno da configuração tab30
      vr_vlarrast NUMBER;  -- Limite (valor de arrasto)
      vr_vlsalmin NUMBER;  -- Salário mínimo
      vr_diasatrs INTEGER; -- Dias de atraso
      vr_atrsinad INTEGER; -- Dias de atraso para inadimplencia

      -- Variaveis para os XMLs
      --> crrl227
      vr_clobxml_227 CLOB;    
      vr_txtauxi_227 VARCHAR2(32767);
      --> crrl354
      vr_clobxml_354 CLOB;    
      vr_txtauxi_354 VARCHAR2(32767);
      --> crrl552
      vr_clobxml_552 CLOB;    
      vr_txtauxi_552 VARCHAR2(32767);
      --> crrl581
      vr_clobxml_581 CLOB;    
      vr_txtauxi_581 VARCHAR2(32767);

      --> Descrição genérica para reaproveitamento de código
      vr_des_xml_gene VARCHAR2(32767);

      -- Variáveis auxiliares para o relatório 5 - crrl581.lst
      vr_ddatraso INTEGER;
      vr_contdata INTEGER;
      vr_flgrisco BOOLEAN;
      vr_dsorigem VARCHAR2(1);
      vr_dtfimmes DATE;

      vr_dtmesant DATE;
      vr_dt6meses DATE;      
      -- Variáveis genéricas para vários relatórios
      vr_vldivida       NUMBER(15,2);--> Totalizador de dívida
      vr_vldivjur       NUMBER(15,2);--> Totalizador de dívida quando PJ
      vr_vlpreatr       NUMBER;      --> Valor perstação em atraso
      vr_vlprejuz       NUMBER := 0; --> Total geral de prejuízo
      vr_vlprejuz_conta NUMBER;      --> Total de prejuízo na conta
      vr_qtpreatr       PLS_INTEGER; --> Indicador de atraso
      vr_vltotatr       NUMBER;      --> Totalizador de atrasos
      vr_vlpercen       NUMBER;      --> Valor auxiliar para calcular o atraso
      vr_nivrisco       VARCHAR2(2); --> Auxiliar para nível do risco
      vr_dtdrisco       DATE;        --> Data do risco ant
      vr_qtdiaris       INTEGER;     --> Qtd dias do risco
      vr_dsnivris       VARCHAR2(2); --> Nivel do risco atual
      vr_pertenge       VARCHAR2(1); --> Indicador de grupo empresarial
      vr_percentu       NUMBER(5,2); --> Percentual auxiliar
      vr_indrisco       crapnrc.indrisco%TYPE; -- Risco rating
      vr_vlpreapg       NUMBER(20,10); --> Vl. prestacao paga.
      vr_cdorigem       NUMBER(1);   --> Origem do Cyber
      
      vr_tpemprst       VARCHAR2(10); -- Tipo de Contrato
      
      -- Flags para indicar que as tags de agência já foram enviadas no XML
      vr_flgpac01 BOOLEAN;
      vr_flgpac02 BOOLEAN;

      -- Variáveis de totalização por PAC
      vr_tot_qtctremp INTEGER;     -- CONTRATOS EM ATRASO
      vr_tot_vlpreatr NUMBER;      -- DESPESA PROVISIONADA
      vr_tot_qtctrato INTEGER;     -- CONTRATOS EM DIA
      vr_tot_vldespes NUMBER;      -- DESPESA PROVISIONADA
      vr_tot_qtempres INTEGER;     -- TOTAIS DA CARTEIRA
      vr_tot_vlsdeved NUMBER;      -- SALDO DEVEDOR DA CARTEIRA
      vr_med_percentu NUMBER;      -- MÉDIA % TAXA
      vr_tot_vlsdvatr NUMBER;      -- SALDO DEVEDOR EM ATRASO
      vr_tot_vlatraso NUMBER;      -- VALOR EM ATRASO
      vr_percbase     NUMBER(5,2); -- %BASE
      vr_tot_qtdopera INTEGER;     -- TOTAL QTDE
      vr_tot_qtdopfis INTEGER;     -- TOTAL QTDE POR PF
      vr_tot_qtdopjur INTEGER;     -- TOTAL QTDE POR PJ
      vr_tot_vlropera NUMBER(18,2);      -- TOTAL SALDO DEVEDOR
      vr_tot_vlropfis NUMBER(18,2);      -- TOTAL SALDO DEVEDOR POR PF
      vr_tot_vlropjur NUMBER(18,2);      -- TOTAL SALDO DEVEDOR POR PJ
      
      vr_tot_qtatrasa INTEGER;     -- QTDE ATRASO MAIOR INADIMPLENCIA
      vr_tot_qtatrfis INTEGER;     -- QTDE ATRASO MAIOR INADIMPLENCIA POR PF
      vr_tot_qtatrjur INTEGER;     -- QTDE ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_tot_vlatrasa NUMBER;      -- VALOR ATRASO MAIOR INADIMPLENCIA
      vr_tot_vlatrfis NUMBER;      -- VALOR ATRASO MAIOR INADIMPLENCIA POR PF
      vr_tot_vlatrjur NUMBER;      -- VALOR ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_med_atrsinad NUMBER;      -- % INADIMPLENCIA
      vr_med_atindfis NUMBER;      -- % INADIMPLENCIA POR PF
      vr_med_atindjur NUMBER;      -- % INADIMPLENCIA POR PJ

      -- Variáveis para totalização geral
      vr_tot_qtctremp_geral INTEGER := 0; -- CONTRATOS EM ATRASO
      vr_tot_vlpreatr_geral NUMBER  := 0; -- DESPESA PROVISIONADA
      vr_tot_qtctrato_geral INTEGER := 0; -- CONTRATOS EM DIA
      vr_tot_vldespes_geral NUMBER  := 0; -- DESPESA PROVISIONADA
      vr_tot_vlatraso_geral NUMBER  := 0; -- VALOR EM ATRASO
      vr_tot_vlsdeved_geral NUMBER  := 0; -- SALDO DEVEDOR
      vr_tot_qtempres_geral INTEGER := 0; -- QUANTIDADE DE EMPREST
      vr_tot_qtdopera_geral INTEGER := 0; -- TOTAL QTDE
      vr_tot_qtdopfis_geral INTEGER := 0; -- TOTAL QTDE POR PF
      vr_tot_qtdopjur_geral INTEGER := 0; -- TOTAL QTDE POR PJ      
      vr_tot_vlropera_geral NUMBER  := 0; -- TOTAL SALDO DEVEDOR
      vr_tot_vlropfis_geral NUMBER  := 0; -- TOTAL SALDO DEVEDOR
      vr_tot_vlropjur_geral NUMBER  := 0; -- TOTAL SALDO DEVEDOR
      vr_tot_qtatrasa_geral INTEGER := 0; -- QTDE ATRASO MAIOR INADIMPLENCIA
      vr_tot_qtatrfis_geral INTEGER := 0; -- QTDE ATRASO MAIOR INADIMPLENCIA POR PF
      vr_tot_qtatrjur_geral INTEGER := 0; -- QTDE ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_tot_vlatrasa_geral NUMBER  := 0; -- VALOR ATRASO MAIOR INADIMPLENCIA
      vr_tot_vlatrfis_geral NUMBER  := 0; -- VALOR ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_tot_vlatrjur_geral NUMBER  := 0; -- VALOR ATRASO MAIOR INADIMPLENCIA POR PJ
      vr_med_atrsinad_geral NUMBER  := 0; -- % INADIMPLENCIA
      vr_med_atindfis_geral NUMBER  := 0; -- % INADIMPLENCIA POR PJ
      vr_med_atindjur_geral NUMBER  := 0; -- % INADIMPLENCIA POR PJ

      -- Variáveis para a escrita no arquivo crrl354.txt
      vr_clob_354     CLOB;               --> Clob para conter o dados do txt
      vr_txtarqui_354  VARCHAR2(32767);    --> Texto auxiliar para evitar gravação excessiva no CLOB
      vr_nmdireto_354 VARCHAR2(200);      --> Diretório específico para o mesmo
      vr_nmarquiv_354 VARCHAR2(20);       --> Nome do arquivo 354
      vr_dssepcol_354 VARCHAR2(1) := ';'; --> Caracter separador dentro do arquivo 354
      vr_cdlcremp_354 VARCHAR2(10);        --> Linha de crédito auxiliar
      vr_dspathcp_354 VARCHAR2(4000);     --> Path para cópia do arquivo exportado

      -- Variaveis para cópia e envio de e-mail dos relatórios
      vr_dspathcopia VARCHAR2(4000);
      vr_dsmailcopia VARCHAR2(4000);
      vr_dsassunmail VARCHAR2(300);

      -- Variável para o caminho dos arquivos no rl
      vr_nom_direto  VARCHAR2(200);
      vr_indice      VARCHAR2(100);

      -- Variaveis para o Cyber
      vr_txmensal    NUMBER(10,6);
      vr_dstextab    VARCHAR2(100);
      vr_flgrpeco    NUMBER(1);
      vr_flgresid    NUMBER(1);
      vr_txmenemp    crapepr.txmensal%TYPE;
      vr_txdjuros    craplcr.txdiaria%TYPE;
      vr_tab_diapagto NUMBER;
      vr_tab_dtcalcul DATE;
      -- Flag para desconto em folha
      vr_tab_flgfolha BOOLEAN;
      -- Configuração para mês novo
      vr_tab_ddmesnov INTEGER;
      vr_flgconsg     INTEGER;

      --microcredito
      vr_chave_microcredito craplcr.dsorgrec%TYPE;
      vr_cdusolcr           craplcr.cdusolcr%TYPE;
      vr_dsorgrec           craplcr.dsorgrec%TYPE;
      
      --finame
      vr_tot_libctnfiname   NUMBER := 0;
      vr_tot_prvperdafiname NUMBER := 0;
      
      --controle de arquivo
      vr_dtmvtolt_yymmdd    VARCHAR2(6);
      vr_nom_diretorio      VARCHAR2(200); 
      vr_nom_dir_copia      VARCHAR2(200);

      -- P307 Calculo de Compensação de Microcrédito
      vr_tot_vltttlcr_dim        NUMBER := 0;
      vr_tot_vltttlcr_dim_outros NUMBER := 0;       
      vr_totatraso59_dim         NUMBER := 0;
      vr_totatraso59_dim_outros  NUMBER := 0;


      -- Retorna linha cabeçalho arquivo Radar ou Matera
      FUNCTION fn_set_cabecalho(pr_inilinha IN VARCHAR2
                               ,pr_dtarqmv  IN DATE
                               ,pr_dtarqui  IN DATE
                               ,pr_origem   IN NUMBER      --> Conta Origem
                               ,pr_destino  IN NUMBER      --> Conta Destino
                               ,pr_vltotal  IN NUMBER      --> Soma total de todas as agencias
                               ,pr_dsconta  IN VARCHAR2)   --> Descricao da conta
                               RETURN VARCHAR2 IS
      BEGIN
         RETURN pr_inilinha --> Identificacao inicial da linha
              ||TO_CHAR(pr_dtarqmv,'YYMMDD')||',' --> Data AAMMDD do Arquivo
              ||TO_CHAR(pr_dtarqui,'DDMMYY')||',' --> Data DDMMAA
              ||pr_origem||','                    --> Conta Origem
              ||pr_destino||','                   --> Conta Destino
              ||TRIM(TO_CHAR(pr_vltotal,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'))||','
              ||'5210'||','
              ||pr_dsconta;
      END fn_set_cabecalho;
      
      -- Retorna linha gerencial arquivo Radar ou Matera
      FUNCTION fn_set_gerencial(pr_cdagenci in number
                               ,pr_vlagenci in number)  
                               RETURN VARCHAR2 IS
      BEGIN
         RETURN lpad(pr_cdagenci,3,0)||',' 
              ||TRIM(TO_CHAR(pr_vlagenci,'FM999999999999990D00', 'NLS_NUMERIC_CHARACTERS=.,'));
      END fn_set_gerencial;      

      -- SobRotina que cria registros contab no arquivo texto
      PROCEDURE pc_cria_node_contab(pr_des_xml    IN OUT VARCHAR2
                                   ,pr_des_contab IN VARCHAR2
                                   ,pr_num_valor1 IN NUMBER
                                   ,pr_num_valor2 IN NUMBER
                                   ,pr_num_vlpvpf IN NUMBER
                                   ,pr_num_vlprpj IN NUMBER
                                   ,pr_num_vldvpf IN NUMBER
                                   ,pr_num_vldvpj IN NUMBER
                                   ,pr_flcessao   IN INTEGER DEFAULT 0
                                   ) IS
      BEGIN
         -- Escreve no XML abrindo e fechando a tag de contab
         pr_des_xml := pr_des_xml
                      ||'<contab>'
                      ||'  <idcessao>'||pr_flcessao  ||'</idcessao> '
                      ||'  <dscontab>'||pr_des_contab||'</dscontab>'
                      ||'  <vlprovis>'||to_char(pr_num_valor1,'fm999g999g999g990d00')||'</vlprovis>'
                      ||'  <vldivida>'||to_char(pr_num_valor2,'fm999g999g999g990d00')||'</vldivida>'
                      ||'  <vlprvfis>'||to_char(pr_num_vlpvpf,'fm999g999g999g990d00')||'</vlprvfis>'
                      ||'  <vlprvjur>'||to_char(pr_num_vlprpj,'fm999g999g999g990d00')||'</vlprvjur>'
                      ||'  <vldivfis>'||to_char(pr_num_vldvpf,'fm999g999g999g990d00')||'</vldivfis>'
                      ||'  <vldivjur>'||to_char(pr_num_vldvpj,'fm999g999g999g990d00')||'</vldivjur>'
                      ||'</contab>';
      END;
      
      -- SobRotina que cria registros microcredito no arquivo texto
      PROCEDURE pc_cria_node_miccre(pr_des_xml          IN OUT VARCHAR2
                                   ,pr_idgrumic         IN NUMBER
                                   ,pr_ds_microcredito  IN VARCHAR2
                                   ,pr_vlreprec         IN NUMBER
                                   ,pr_vlempatr         IN NUMBER
                                   ,pr_vlreprec_pf      IN NUMBER
                                   ,pr_vlreprec_pj      IN NUMBER
                                   ,pr_vlate59d         IN NUMBER
                                   ,pr_vlaci59d         IN NUMBER) IS
      BEGIN
         -- Escreve no XML abrindo e fechando a tag de microcredito
         pr_des_xml := pr_des_xml
                      ||'<microcredito>'
                      ||'  <idgrumic>'||pr_idgrumic||'</idgrumic>'
                      ||'  <dsorgrec>'||pr_ds_microcredito||'</dsorgrec>'
                      ||'  <vlreprec>'||to_char(pr_vlreprec,'fm999g999g999g990d00')||'</vlreprec>'
                      ||'  <vlempatr>'||to_char(pr_vlempatr,'fm999g999g999g990d00')||'</vlempatr>'                       
                      ||'  <vlrepfis>'||to_char(pr_vlreprec_pf,'fm999g999g999g990d00')||'</vlrepfis>'
                      ||'  <vlrepjur>'||to_char(pr_vlreprec_pj,'fm999g999g999g990d00')||'</vlrepjur>'
                      ||'  <vlaci59d>'||to_char(pr_vlaci59d,'fm999g999g999g990d00')||'</vlaci59d>'                      
                      ||'  <vlate59d>'||to_char(pr_vlate59d,'fm999g999g999g990d00')||'</vlate59d>'
                      ||'</microcredito>';

      END pc_cria_node_miccre;
      
      
      -- Inicializa Pl-Table
      PROCEDURE pc_inicializa_pltable IS
      BEGIN
         FOR idx IN 1..3 LOOP
            -- Inicializa Todas as Informacoes da Coluna Provisao
            vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(idx).vlfinanc_pf := 0;
            vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(idx).vlfinanc_pj := 0;
            vr_tab_contab(vr_vlempres_pf)(vr_provis)(idx).vlempres_pf := 0;
            vr_tab_contab(vr_vlempres_pj)(vr_provis)(idx).vlempres_pj := 0;
            vr_tab_contab(vr_vlchqdes)(vr_provis)(idx).vlchqdes := 0;
            vr_tab_contab(vr_vltitdes_cr)(vr_provis)(idx).vltitdes_cr := 0;
            vr_tab_contab(vr_vltitdes_sr)(vr_provis)(idx).vltitdes_sr := 0;
            vr_tab_contab(vr_vladtdep)(vr_provis)(idx).vladtdep := 0;
            vr_tab_contab(vr_vlchqesp)(vr_provis)(idx).vlchqesp := 0;
            
            -- Inicializa Todas as Informacoes da Coluna Divida
            vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(idx).vlfinanc_pf := 0;
            vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(idx).vlfinanc_pj := 0;
            vr_tab_contab(vr_vlempres_pf)(vr_divida)(idx).vlempres_pf := 0;
            vr_tab_contab(vr_vlempres_pj)(vr_divida)(idx).vlempres_pj := 0;
            vr_tab_contab(vr_vlchqdes)(vr_divida)(idx).vlchqdes := 0;
            vr_tab_contab(vr_vltitdes_cr)(vr_divida)(idx).vltitdes_cr := 0;
            vr_tab_contab(vr_vltitdes_sr)(vr_divida)(idx).vltitdes_sr := 0;
            vr_tab_contab(vr_vladtdep)(vr_divida)(idx).vladtdep := 0;
            vr_tab_contab(vr_vlchqesp)(vr_divida)(idx).vlchqesp := 0;
         END LOOP;
     vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf := 0;
         vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj := 0;
         vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf := 0;
         vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj := 0;
      END;
      
      PROCEDURE pc_gera_arq_compe_mic(pr_dscritic OUT VARCHAR2) IS

         vr_txt_compmicro VARCHAR2(500);
         vr_nmarquiv   VARCHAR2(200);
         vr_dscritic   VARCHAR2(4000);
         vr_input_file UTL_FILE.file_type;  
         vr_typ_said         VARCHAR2(4);
          
      BEGIN
        
        IF  (nvl(vr_tot_vltttlcr_dim,0) + 
                   nvl(vr_tot_vltttlcr_dim_outros,0) +       
                   nvl(vr_totatraso59_dim,0) + 
                   nvl(vr_totatraso59_dim_outros,0)) > 0 THEN
        
          -- Nome do arquivo a ser gerado
          vr_nmarquiv := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_MICROCREDITO_COMPENSACAO.txt';

          -- Tenta abrir o arquivo de log em modo gravacao
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                  ,pr_nmarquiv => vr_nmarquiv          --> Nome do arquivo
                                  ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);        --> Erro
          IF vr_dscritic IS NOT NULL THEN
             -- Levantar Excecao
             RAISE vr_exc_erro;
          END IF;      
           
          -- 1ª linha
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'3967'
                                              ,'9264'
                                              ,vr_tot_vltttlcr_dim
                                              ,'"TOTAL DIM SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM - VENCIDOS ATE 59 DIAS"');
            
          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                                          
                              
          -- 2ª linha 
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'3972'
                                              ,'9264'
                                              ,vr_totatraso59_dim
                                              ,'"TOTAL DIM SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM - VENCIDOS A MAIS DE 59 DIAS"');
                                           
          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                              
          -- 3ª linha
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'9264'
                                              ,'3967'
                                              ,vr_tot_vltttlcr_dim
                                              ,'"REVERSAO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM - VENCIDOS ATE 59 DIAS"');
          
          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                             
          -- 4ª linha 
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'9264'
                                              ,'3972'
                                              ,vr_totatraso59_dim
                                              ,'"REVERSAO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM - VENCIDOS A MAIS DE 59 DIAS"');
                                           
          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
           
          --Linhas PNMPO DIM E CAIXA                             
          -- 1ª linha
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'3965'
                                              ,'9264'
                                              ,vr_tot_vltttlcr_dim_outros
                                              ,'"SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS ATE 59 DIAS"');
          
          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                            
                            
          -- 2ª linha
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,'3968'
                                              ,'9264'
                                              ,vr_totatraso59_dim_outros
                                              ,'"SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS A MAIS DE 59 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);

                                         
          -- 3ª linha
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'9264'
                                              ,'3965'
                                              ,vr_tot_vltttlcr_dim_outros
                                              ,'"REVERSAO DO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS ATE 59 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                              
                            
          -- 4ª linha
          vr_txt_compmicro := fn_set_cabecalho('50'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,'9264'
                                              ,'3968'
                                              ,vr_totatraso59_dim_outros
                                              ,'"REVERSAO DO SALDO DAS OPERACOES DE MICROCREDITO APLICADOS AOS COOPERADOS COM RECURSOS ORIUNDOS DE DIM PNMPO E DIM PNMPO CAIXA – VENCIDOS A MAIS DE 59 DIAS"');

          GENE0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file
                                        ,pr_des_text => vr_txt_compmicro);
                                          
          -- Fechar Arquivo
          BEGIN
             gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          EXCEPTION
             WHEN OTHERS THEN
             -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
             vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarquiv||'>: ' || SQLERRM;
             RAISE vr_exc_erro;
          END;
          
          -- Copia o arquivo gerado para o diretório final convertendo para DOS
          gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarquiv||' > '||vr_nom_dir_copia||'/'||vr_nmarquiv||' 2>/dev/null',
                                      pr_typ_saida   => vr_typ_said,
                                      pr_des_saida   => vr_dscritic);
          -- Testar erro
          if vr_typ_said = 'ERR' then
             vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarquiv||': '||vr_dscritic;
             raise vr_exc_erro;
          end if;
        
        END IF;
                                         
      END pc_gera_arq_compe_mic;
      --
      
      PROCEDURE pc_gera_arq_finame(pr_dscritic OUT VARCHAR2) IS
        
         vr_nmarqfin   VARCHAR2(200);
         vr_dscritic   VARCHAR2(4000);
         vr_input_file UTL_FILE.file_type;  
         vr_setlinha         VARCHAR2(400);                  --> Linhas do arquivo        
         vr_typ_said         VARCHAR2(4);
         vr_chave_nivris     VARCHAR2(10);
         --
         vr_destino          NUMBER;
         vr_origem           NUMBER;
         -- Variavel de Exception
         vr_exc_erro EXCEPTION;
               
      BEGIN
         
         -- Nome do arquivo a ser gerado
         vr_nmarqfin := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_AJUSTE_FINAME.txt';

         -- Tenta abrir o arquivo de log em modo gravacao
         gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                 ,pr_nmarquiv => vr_nmarqfin          --> Nome do arquivo
                                 ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                 ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                 ,pr_des_erro => vr_dscritic);        --> Erro
         IF vr_dscritic IS NOT NULL THEN
            -- Levantar Excecao
            RAISE vr_exc_erro;
         END IF;
         
         --Valor liberação contrato finame
         IF vr_tot_libctnfiname > 0 THEN
           
            vr_setlinha := fn_set_cabecalho('20'
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,1432
                                           ,1631
                                           ,vr_tot_libctnfiname
                                           ,'"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO BNDES - FINAME"');
                                               
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
            
            vr_setlinha := fn_set_gerencial('999',vr_tot_libctnfiname);
               
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
         
         END IF;
         
         --Valor provisão de perda contrato finame
         IF vr_tot_prvperdafiname > 0 THEN
            
            --Linhas de provisão
            vr_setlinha := fn_set_cabecalho('20'
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,pr_rw_crapdat.dtmvtolt
                                           ,5589
                                           ,1435
                                           ,vr_tot_prvperdafiname
                                           ,'"AJUSTE CONTABIL – PROVISAO BNDES FINAME"');
                                               
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
            
            vr_setlinha := fn_set_gerencial('999',vr_tot_prvperdafiname);
               
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
         
            --Linhas de reversão
            vr_setlinha := fn_set_cabecalho('20'
                                           ,pr_rw_crapdat.dtmvtopr
                                           ,pr_rw_crapdat.dtmvtopr
                                           ,1435
                                           ,5589
                                           ,vr_tot_prvperdafiname
                                           ,'"REVERSAO AJUSTE CONTABIL – PROVISAO BNDES FINAME"');
                                               
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
            
            vr_setlinha := fn_set_gerencial('999',vr_tot_prvperdafiname);
               
            gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto para escrita
         
         END IF;
         --
         vr_chave_nivris := vr_tab_finame_nivris.first;
         LOOP 
          
            EXIT WHEN vr_chave_nivris IS NULL;
            
            --Gera no arquivo linhas referente a valor de liberação de contrato
            IF vr_tab_finame_nivris(vr_chave_nivris).vlslddev > 0 THEN
             
               IF vr_chave_nivris IN ('A','AA') THEN
                  vr_destino := 3321;  --provisão 
                  vr_origem  := 3321;  --reversão
               ELSIF vr_chave_nivris = 'B' THEN
                  vr_destino := 3332; --provisão
                  vr_origem  := 3332; --reversão                
               ELSIF vr_chave_nivris = 'C' THEN
                  vr_destino := 3342; --provisão
                  vr_origem  := 3342; --reversão
               ELSIF vr_chave_nivris = 'D' THEN
                  vr_destino := 3352; --provisão
                  vr_origem  := 3352; --reversão
               ELSIF vr_chave_nivris = 'E' THEN
                  vr_destino := 3362; --provisão
                  vr_origem  := 3362; --reversão
               ELSIF vr_chave_nivris = 'F' THEN 
                  vr_destino := 3372; --provisão
                  vr_origem  := 3372; --reversão
               ELSIF vr_chave_nivris = 'G' THEN 
                  vr_destino := 3382; --provisão
                  vr_origem  := 3382; --reversão
               ELSIF vr_chave_nivris IN ('H','HH') THEN
                  vr_destino := 3392; --provisão
                  vr_origem  := 3392; --reversão
               END IF;
             
               --Gerar linhas de PROVISÃO
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,9302
                                              ,vr_destino
                                              ,vr_tab_finame_nivris(vr_chave_nivris).vlslddev
                                              ,'"CLASSIFICACAO DE RISCO DE REPASSES BNDES FINAME DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');
                                                
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
             
              --Gerar linhas de REVERSÃO
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,vr_origem
                                              ,9302
                                              ,vr_tab_finame_nivris(vr_chave_nivris).vlslddev
                                              ,'"REVERSAO DE AJUSTE DE CLASSIFICACAO DE RISCO DE REPASSES BNDES FINAME DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');
                                                
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
            END IF;
           
            vr_chave_nivris := vr_tab_finame_nivris.next(vr_chave_nivris);   
         END LOOP;
        
         -- Fechar Arquivo
         BEGIN
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
         EXCEPTION
            WHEN OTHERS THEN
            -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
            vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarqfin||'>: ' || SQLERRM;
            RAISE vr_exc_erro;
         END;
        
         -- Copia o arquivo gerado para o diretório final convertendo para DOS
         gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqfin||' > '||vr_nom_dir_copia||'/'||vr_nmarqfin||' 2>/dev/null',
                                     pr_typ_saida   => vr_typ_said,
                                     pr_des_saida   => vr_dscritic);
         -- Testar erro
         if vr_typ_said = 'ERR' then
           vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqfin||': '||vr_dscritic;
           raise vr_exc_erro;
         end if;
         
      EXCEPTION
        WHEN vr_exc_erro THEN
           pr_dscritic := vr_dscritic;  
        WHEN OTHERS THEN
           pr_dscritic := 'Erro geral na procedure pc_gera_arq_miccred: '||SQLERRM;       
      END pc_gera_arq_finame;
      
      PROCEDURE pc_gera_arq_miccred(pr_dscritic OUT VARCHAR2) IS
        
         vr_nmarqmic         VARCHAR2(200);
         vr_dscritic         VARCHAR2(4000);
         vr_chave_finalidade VARCHAR2(50);
         vr_chave_nivris     VARCHAR2(10);
         vr_input_file       UTL_FILE.file_type;             --> Handle Utl File
         vr_setlinha         VARCHAR2(400);                  --> Linhas do arquivo        
         vr_typ_said         VARCHAR2(4);
         --
         vr_destino          NUMBER;
         vr_origem           NUMBER;
         vr_descricao        VARCHAR2(400);
        
         -- Variavel de Exception
         vr_exc_erro EXCEPTION;
        
      BEGIN
         
         -- Nome do arquivo a ser gerado
         vr_nmarqmic := vr_dtmvtolt_yymmdd||'_'||lpad(pr_cdcooper,2,0)||'_AJUSTE_MICROCREDITO.txt';

         -- Tenta abrir o arquivo de log em modo gravacao
         gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio     --> Diretório do arquivo
                                 ,pr_nmarquiv => vr_nmarqmic          --> Nome do arquivo
                                 ,pr_tipabert => 'W'                  --> Modo de abertura (R,W,A)
                                 ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                 ,pr_des_erro => vr_dscritic);        --> Erro
         IF vr_dscritic IS NOT NULL THEN
            -- Levantar Excecao
            RAISE vr_exc_erro;
         END IF;
         
         vr_chave_finalidade := vr_tab_miccred_fin.first;
         LOOP 
          
            EXIT WHEN vr_chave_finalidade IS NULL;
            
            --Gera no arquivo linhas referente a valor de liberação de contrato
            IF vr_tab_miccred_fin(vr_chave_finalidade).vllibctr > 0 THEN
              
               IF vr_chave_finalidade = 1 THEN
                  vr_origem := 1437;
                  vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO MICROCREDITO CEF"';
               ELSIF vr_chave_finalidade = 2 THEN
                  vr_origem := 1780;  
                  vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO CCB IMOBILIZADO REFAP"';   
               ELSIF vr_chave_finalidade = 3 THEN
                  vr_origem := 5505;  
                  vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO CCB MAIS CREDITO"';                                       
               ELSIF vr_chave_finalidade = 4 THEN
                  vr_origem := 1440;  
                  vr_descricao := '"AJUSTE CONTABIL REF. LIBERACAO DE RECURSO MICROCREDITO BNDES"';                  
               END IF;
               
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,vr_origem
                                              ,1662
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vllibctr
                                              ,vr_descricao);

               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
               IF vr_chave_finalidade IN (1,4) THEN
                  vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vllibctr);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vllibctr);  
               END IF;
               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            END IF;
            --
            --Gera no arquivo linhas referente a valor de apropriação de contrato
            IF vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec > 0 THEN
              
               IF vr_chave_finalidade = 1 THEN
                  vr_origem := 1437;
                  vr_destino := 7302;
                  vr_descricao := '"AJUSTE CONTABIL REF. JUROS MICROCREDITO CEF"';
               ELSIF vr_chave_finalidade = 2 THEN
                  vr_origem := 1780;  
                  vr_destino := 7112;                  
                  vr_descricao := '"AJUSTE CONTABIL - JUROS CCB IMOBILIZADO REFAP (INVESTIMENTOS)"';  
               ELSIF vr_chave_finalidade = 3 THEN
                  vr_origem := 5505;  
                  vr_destino := 7011;                  
                  vr_descricao := '"AJUSTE CONTABIL - JUROS CCB MAIS CREDITO"';                                      
               ELSIF vr_chave_finalidade = 4 THEN
                  vr_origem := 1440;  
                  vr_destino := 7306;                  
                  vr_descricao := '"AJUSTE CONTABIL REF. JUROS MICROCREDITO BNDES"';                  
               END IF;
               
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,vr_origem
                                              ,1662
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec
                                              ,vr_descricao);
                                               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
               END IF;
               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita

               --Escreve novamente as linhas para outra conta de débito e crédito
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,7141
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec
                                              ,vr_descricao);

               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlaprrec); 
               END IF; 
               
               --Escreve duas vezes a linha gerencial
               FOR i IN 1..2 LOOP
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                ,pr_des_text => vr_setlinha); --> Texto para escrita
               END LOOP;
            END IF;
            --
            --Gera no arquivo linhas referente a valor de provisão de contrato
            IF vr_tab_miccred_fin(vr_chave_finalidade).vlprvper > 0 THEN
              
               IF vr_chave_finalidade = 1 THEN
                  --para provisão
                  vr_destino := 1438;
                  --para reversao
                  vr_origem := 1438;
                  vr_descricao := '"AJUSTE CONTABIL - PROVISAO CEF"';
               ELSIF vr_chave_finalidade = 2 THEN
                  --para provisão
                  vr_destino := 1702;
                  --para reversao
                  vr_origem  := 1702;  
                  vr_descricao := '"AJUSTE CONTABIL - PROVISAO CCB IMOBILIZADO REFAP"';                   
               ELSIF vr_chave_finalidade = 4 THEN
                  --para provisão
                  vr_destino := 1441;
                  --para reversao
                  vr_origem  := 1441;  
                  vr_descricao := '"AJUSTE CONTABIL - PROVISAO BNDES"';                  
               END IF;
               
               --Cria linhas de provisão
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,5595
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlprvper
                                              ,vr_descricao);
                                               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);                 
               END IF;
               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
               --Cria linhas de reversão
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,pr_rw_crapdat.dtmvtopr
                                              ,vr_origem
                                              ,5595
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vlprvper
                                              ,replace(vr_descricao,'PROVISAO','REVERSAO'));
                                               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vlprvper); 
               END IF;
               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
            END IF; 

            -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
            IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91 > 0 THEN

               IF vr_chave_finalidade = 1 THEN
                  vr_destino := 1437;
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS MICROCREDITO CEF"';
               ELSIF vr_chave_finalidade = 2 THEN
                  vr_destino := 1780;
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS CCB IMOBILIZADO REFAP"';
               ELSIF vr_chave_finalidade = 3 THEN
                  vr_destino := 5505;
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS CCB MAIS CREDITO"';
               ELSIF vr_chave_finalidade = 4 THEN
                  vr_destino := 1440;
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. JUROS MICROCREDITO BNDES"';
               END IF;

               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,1662
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91
                                              ,vr_descricao);
                                               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN            
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar91);
               END IF; 
               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            END IF;    

            -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
            IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95 > 0 THEN

               IF vr_chave_finalidade = 1 THEN
                  vr_destino := 1437;
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL MICROCREDITO CEF"';
               ELSIF vr_chave_finalidade = 2 THEN
                  vr_destino := 1780;  
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL CCB IMOBILIZADO REFAP"';
               ELSIF vr_chave_finalidade = 3 THEN
                  vr_destino := 5505;  
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL CCB MAIS CREDITO"';
               ELSIF vr_chave_finalidade = 4 THEN
                  vr_destino := 1440;  
                  vr_descricao := '"AJUSTE CONTABIL - PAGTO. MENSAL MICROCREDITO BNDES"';
               END IF;

               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,1662
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95
                                              ,vr_descricao);
                                               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita

               IF vr_chave_finalidade IN (1,4) THEN
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar95);
               END IF;

               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            END IF;

            -- Gera no arquivo linhas referente a valor de pagamento de parcelas de contrato
            IF vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441 > 0 THEN
              
               IF vr_chave_finalidade = 1 THEN
                  vr_origem  := 7306;
                  vr_destino := 7302;
                  vr_descricao := '(AJUSTE DE SALDO - MICROCREDITO CEF - AJUSTE CONTABIL)"';
               ELSIF vr_chave_finalidade = 2 THEN
                  vr_origem  := 7306;
                  vr_destino := 7112;
                  vr_descricao := '(AJUSTE DE SALDO - CCB IMOBILIZADO REFAP - AJUSTE CONTABIL)"';
               ELSIF vr_chave_finalidade = 3 THEN
                  vr_origem  := 7306;
                  vr_destino := 7011;
                  vr_descricao := '(AJUSTE DE SALDO - CCB MAIS CREDITO - AJUSTE CONTABIL)"';
               ELSIF vr_chave_finalidade = 4 THEN
                  vr_origem  := 1440;
                  vr_destino := 1662;
                  vr_descricao := '(AJUSTE DE SALDO - MICROCREDITO BNDES - AJUSTE CONTABIL)"';
               END IF;
               
               vr_setlinha := fn_set_cabecalho('20'
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,pr_rw_crapdat.dtmvtolt
                                              ,vr_origem
                                              ,vr_destino
                                              ,vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441
                                              ,'"EMPRESTIMOS EFETUADOS PARA ASSOCIADOS - (0441) JUROS SOBRE EMPRESTIMOS ' || vr_descricao);
                                               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            
               IF vr_chave_finalidade IN (1,4) THEN            
                 vr_setlinha := fn_set_gerencial('001',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441);
               ELSE
                 vr_setlinha := fn_set_gerencial('999',vr_tab_miccred_fin(vr_chave_finalidade).vldebpar441);   
               END IF; 
               
               gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                             ,pr_des_text => vr_setlinha); --> Texto para escrita
            END IF;           
           
            vr_chave_finalidade := vr_tab_miccred_fin.next(vr_chave_finalidade); 
          
        END LOOP;
        
        vr_chave_nivris := vr_tab_miccred_nivris.first;
        LOOP 
          
           EXIT WHEN vr_chave_nivris IS NULL;
            
           --Gera no arquivo linhas referente a valor de liberação de contrato
           IF vr_tab_miccred_nivris(vr_chave_nivris).vlslddev > 0 THEN
             
              IF vr_chave_nivris IN ('A','AA') THEN
                 vr_destino := 3321;  --provisão 
                 vr_origem  := 3321;  --reversão
              ELSIF vr_chave_nivris = 'B' THEN
                 vr_destino := 3332; --provisão
                 vr_origem  := 3332; --reversão                
              ELSIF vr_chave_nivris = 'C' THEN
                 vr_destino := 3342; --provisão
                 vr_origem  := 3342; --reversão
              ELSIF vr_chave_nivris = 'D' THEN
                 vr_destino := 3352; --provisão
                 vr_origem  := 3352; --reversão
              ELSIF vr_chave_nivris = 'E' THEN
                 vr_destino := 3362; --provisão
                 vr_origem  := 3362; --reversão
              ELSIF vr_chave_nivris = 'F' THEN 
                 vr_destino := 3372; --provisão
                 vr_origem  := 3372; --reversão
              ELSIF vr_chave_nivris = 'G' THEN 
                 vr_destino := 3382; --provisão
                 vr_origem  := 3382; --reversão
              ELSIF vr_chave_nivris IN ('H','HH') THEN
                 vr_destino := 3392; --provisão
                 vr_origem  := 3392; --reversão
              END IF;
             
              --Gerar linhas de PROVISÃO
              vr_setlinha := fn_set_cabecalho('20'
                                             ,pr_rw_crapdat.dtmvtolt
                                             ,pr_rw_crapdat.dtmvtolt
                                             ,9302
                                             ,vr_destino
                                             ,vr_tab_miccred_nivris(vr_chave_nivris).vlslddev
                                             ,'"CLASSIFICACAO DE RISCO DE REPASSES CEF E BNDES DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');
                                               
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto para escrita
            
             --Gerar linhas de REVERSÃO
              vr_setlinha := fn_set_cabecalho('20'
                                             ,pr_rw_crapdat.dtmvtopr
                                             ,pr_rw_crapdat.dtmvtopr
                                             ,vr_origem
                                             ,9302
                                             ,vr_tab_miccred_nivris(vr_chave_nivris).vlslddev
                                             ,'"REVERSAO DE AJUSTE DE CLASSIFICACAO DE RISCO DE REPASSES CEF E BNDES DEVIDO AJUSTES DO DOCUMENTO 4010 ENVIANDO AO BACEN"');
                                               
              gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto para escrita
            
           END IF;
           
           vr_chave_nivris := vr_tab_miccred_nivris.next(vr_chave_nivris);   
        END LOOP;
        
        -- Fechar Arquivo
        BEGIN
           gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        EXCEPTION
           WHEN OTHERS THEN
           -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
           vr_dscritic := 'Problema ao fechar o arquivo <'||vr_nom_diretorio||'/'||vr_nmarqmic||'>: ' || SQLERRM;
           RAISE vr_exc_erro;
        END;

        -- Copia o arquivo gerado para o diretório final convertendo para DOS
        gene0001.pc_oscommand_shell(pr_des_comando => 'ux2dos '||vr_nom_diretorio||'/'||vr_nmarqmic||' > '||vr_nom_dir_copia||'/'||vr_nmarqmic||' 2>/dev/null',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        -- Testar erro
        if vr_typ_said = 'ERR' then
          vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqmic||': '||vr_dscritic;
          raise vr_exc_erro;
        end if;   
      
      EXCEPTION
        WHEN vr_exc_erro THEN
           pr_dscritic := vr_dscritic;  
        WHEN OTHERS THEN
           pr_dscritic := 'Erro geral na procedure pc_gera_arq_miccred: '||SQLERRM; 
      END pc_gera_arq_miccred;
      

      /* Processar conta de migração entre cooperativas */
      FUNCTION fn_verifica_conta_migracao(pr_nrdconta  IN crapass.nrdconta%TYPE) --> Número da conta
                                                                                 RETURN BOOLEAN IS
      BEGIN
         -- Validamos Apenas Via, AV e SCR   
         IF NOT pr_cdcooper IN(1,13,16) THEN
            -- OK
            RETURN TRUE;
         ELSE
            IF vr_tab_craptco.exists(pr_nrdconta) THEN
               RETURN FALSE;
            ELSE
               -- Tudo OK até aqui, retornamos true
               RETURN TRUE;
            END IF;  
         END IF;
      END fn_verifica_conta_migracao;

   ---------------------------------------
   -- Inicio Bloco Principal pc_crps280_I
   ---------------------------------------

   BEGIN
      -- Limpar as tabelas geradas no processo
      vr_tab_erro.DELETE;
      vr_tab_risco.DELETE;
      vr_tab_risco_aux.DELETE;
      vr_tab_crapris.DELETE;
      vr_tab_totrispac.DELETE;
      vr_tab_totrisger.DELETE;
      vr_tab_contab.DELETE;
      vr_tab_microcredito.DELETE;
      vr_tab_miccred_fin.DELETE;
      vr_tab_miccred_nivris.DELETE;
      
      -- Inicializar pl-table
      pc_inicializa_pltable;

      -- Quando for rodado pelo programa crps184, deverá ser gerado o relatorio no mesmo instante
      IF pr_cdprogra = 'CRPS184' THEN
        vr_flgerar := 'S';
      END IF;
      -- Leitura das descricoes de risco A,B,C etc e percentuais
      FOR rw_craptab IN cr_craptab(pr_cdcooper => pr_cdcooper
                                  ,pr_nmsistem => 'CRED'
                                  ,pr_tptabela => 'GENERI'
                                  ,pr_cdempres => 00
                                  ,pr_cdacesso => 'PROVISAOCL'
                                  ,pr_tpregist => 0) LOOP
         -- Para cada registro, buscar o contador atual na posição 12
         vr_contador := SUBSTR(rw_craptab.dstextab,12,2);
         -- Adicionar na tabela as informações de descrição e percentuais
         vr_tab_risco(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
         vr_tab_risco(vr_contador).percentu := SUBSTR(rw_craptab.dstextab,1,6);
         vr_tab_risco_aux(vr_contador).dsdrisco := TRIM(SUBSTR(rw_craptab.dstextab,8,3));
         vr_tab_risco_aux(vr_contador).percentu := SUBSTR(rw_craptab.dstextab,1,6);
      END LOOP;

      -- Alimentar variavel para nao ser preciso criar registro na PROVISAOCL
      vr_tab_risco(10).dsdrisco     := 'HH';
      vr_tab_risco(10).percentu     := 0;
      vr_tab_risco_aux(10).dsdrisco := 'H';
      vr_tab_risco_aux(10).percentu := 0;

      -- Buscar o primeiro registro com tpregist >= 0
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'GENERI'
                     ,pr_cdempres => 00
                     ,pr_cdacesso => 'PROVISAOCL'
                     ,pr_tpregist => 0);
      FETCH cr_craptab
       INTO rw_craptab;
      -- Se não encontrar
      IF cr_craptab%NOTFOUND THEN
         -- Utilizar percentual = 100
         vr_percbase := 100;
      ELSE
         -- Utilizar o percentual encontrado
         vr_percbase := gene0002.fn_char_para_number(SUBSTR(rw_craptab.dstextab,1,6));
      END IF;
      CLOSE cr_craptab;

      -- Leitura do indicador de uso da tabela de taxa de juros
      rw_craptab := NULL;
      OPEN cr_craptab(pr_cdcooper => pr_cdcooper
                     ,pr_nmsistem => 'CRED'
                     ,pr_tptabela => 'USUARI'
                     ,pr_cdempres => 11
                     ,pr_cdacesso => 'TAXATABELA'
                     ,pr_tpregist => 0);
      FETCH cr_craptab
       INTO rw_craptab;
      -- Se encontrar
      IF cr_craptab%FOUND THEN
         -- Se a primeira posição do campo
         -- dstextab for diferente de zero
         IF SUBSTR(rw_craptab.dstextab,1,1) != '0' THEN
            -- É porque existe tabela parametrizada
            vr_inusatab := TRUE;
         ELSE
            -- Não existe
            vr_inusatab := FALSE;
         END IF;
      ELSE
         -- Não existe
         vr_inusatab := FALSE;
      END IF;
      CLOSE cr_craptab;

      -- Carregar os dados gravados na TAB030
      tabe0001.pc_busca_tab030(pr_cdcooper => pr_cdcooper     --> Coop
                              ,pr_cdagenci => 0               --> Código da agência
                              ,pr_nrdcaixa => 0               --> Número do caixa
                              ,pr_cdoperad => 0               --> Código do Operador
                              ,pr_vllimite => vr_vlarrast     --> Limite
                              ,pr_vlsalmin => vr_vlsalmin     --> Salário mínimo
                              ,pr_diasatrs => vr_diasatrs     --> Dias de atraso
                              ,pr_atrsinad => vr_atrsinad     --> Dias de atraso para inadimplência
                              ,pr_des_reto => vr_des_reto     --> Indicador de saída com erro (OK/NOK)
                              ,pr_tab_erro => vr_tab_erro);   --> Tabela com erros) IS

      -- Se retornar erro
      IF vr_des_reto = 'NOK' THEN
         -- Se veio erro na tabela
         IF vr_tab_erro.COUNT > 0 then
            -- Montar erro
            pr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
            pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
         ELSE
            -- Por algum motivo retornou erro mais a tabela veio vazia
            pr_dscritic := 'Tab.Erro vazia - não é possível retornar o erro da chamada tabe0001.pc_busca_tab030';
         END IF;
         -- Sair com erro
         RAISE vr_exc_erro;
      END IF;

      -- Carrega as tabelas de contas transferidas da Viacredi e do AltoVale e SCRCred
      IF pr_cdcooper = 1 THEN

         -- Vindas da Acredicoop
         IF pr_dtrefere <= TO_DATE('31/12/2013', 'DD/MM/RRRR') THEN
            FOR regs IN cr_craptco_acredi_via LOOP
               vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
            END LOOP;
         END IF;

         -- Incorporação da Concredi 
         IF pr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
            FOR regs IN cr_craptco_concredi_via LOOP
               vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
            END LOOP;
         END IF;

         -- Migração Via >> Altovale
      ELSIF pr_cdcooper = 16 AND pr_dtrefere <= TO_DATE('31/12/2012', 'DD/MM/RRRR') THEN
         -- Vindas da Via
         FOR regs IN cr_craptco_via_alto LOOP
            vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
         END LOOP;
         -- Incorporação da Credimil >> SCR
      ELSIF pr_cdcooper = 13 AND pr_dtrefere <= TO_DATE('30/11/2014', 'DD/MM/RRRR') THEN
         -- Vindas da Credimil
         FOR regs IN cr_craptco_credimilsul_scrcred LOOP
            vr_tab_craptco(regs.nrdconta) := regs.nrdconta;
         END LOOP;
      END IF;      

      -- Busca do diretório base da cooperativa para a geração de relatórios
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                            ,pr_cdcooper => pr_cdcooper);

      -- Busca agora o diretório base da cooperativa para a geração de arquivos
      -- Obs: será utilizado apenas para o 354.txt
      vr_nmdireto_354 := gene0001.fn_diretorio(pr_tpdireto => 'C'         --> /usr/coop
                                              ,pr_cdcooper => pr_cdcooper
                                              ,pr_nmsubdir => '/arq');

      -- Desde que o programa chamador não seja o 184
      IF pr_cdprogra <> 'CRPS184' THEN
         -- Atribuir o nome ao arquivo
         vr_nmarquiv_354 := 'crrl354.txt';
         -- Criar o CLOB para envio dos dados do txt
         dbms_lob.createtemporary(vr_clob_354, TRUE, dbms_lob.CALL);
         dbms_lob.open(vr_clob_354, dbms_lob.lob_readwrite);
         -- Envio do header
         gene0002.pc_escreve_xml(pr_xml => vr_clob_354
                                ,pr_texto_completo => vr_txtarqui_354
                                ,pr_texto_novo =>'CONTA/DV'||vr_dssepcol_354
                                               ||'TITULAR'||vr_dssepcol_354
                                               ||'TIPO'||vr_dssepcol_354
                                               ||'ORG'||vr_dssepcol_354
                                               ||'CONTRATO'||vr_dssepcol_354
                                               ||'LC'||vr_dssepcol_354
                                               ||'SALDO DEVEDOR'||vr_dssepcol_354
                                               ||'JUR.ATRASO+60'||vr_dssepcol_354
                                               ||'PARCELA'||vr_dssepcol_354
                                               ||'QT.PARC.'||vr_dssepcol_354
                                               ||'TOT.ATRASO'||vr_dssepcol_354
                                               ||'DESPESA'||vr_dssepcol_354
                                               ||'%'||vr_dssepcol_354
                                               ||'PA'||vr_dssepcol_354
                                               ||'MESES/DIAS ATR.'||vr_dssepcol_354
                                               ||'RISCO ATU.'||vr_dssepcol_354
                                               ||'RISCO ANT.'||vr_dssepcol_354
                                               ||'DATA RISCO ANT'||vr_dssepcol_354
                                               ||'DIAS RIS'||vr_dssepcol_354
                                               ||'DIAS ATR'||vr_dssepcol_354
                                               ||'TOT.ATRASO ATENDA'
                                               ||chr(10));
      END IF;

      -- Inicializar os registros no totalizador de riscos geral
      FOR vr_contador IN vr_tab_risco.FIRST..vr_tab_risco.LAST LOOP
        -- Acumular totalizadores por risco geral
        vr_tab_totrisger(vr_contador).qtdabase := 0;
        vr_tab_totrisger(vr_contador).vljura60 := 0;
        vr_tab_totrisger(vr_contador).vljrpf60 := 0;
        vr_tab_totrisger(vr_contador).vljrpj60 := 0;
        vr_tab_totrisger(vr_contador).vlprovis := 0;
        vr_tab_totrisger(vr_contador).vldabase := 0;
      END LOOP;

      -- Obter taxa mensal da craptab
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'JUROSNEGAT'
                                               ,pr_tpregist => 1);

      IF vr_dstextab IS NOT NULL  THEN
         vr_txmensal := to_number ( substr(vr_dstextab,1,10) );
      END IF;

      -- Inicializar totalizadores -de provisão e dívida os valores calculados
      pr_vltotdiv := 0;
      pr_vltotprv := 0;

      -- carrega a PLTABLE da CRAPVRI baseado na data de referencia do CRPS
      OPEN cr_crapvri(pr_dtrefere);

      LOOP 
        FETCH cr_crapvri BULK COLLECT INTO vr_tab_crapvri LIMIT 100000; -- carrega de 100 em 100 mil registros

        EXIT WHEN vr_tab_crapvri.COUNT = 0;
        
        IF vr_tab_crapvri.COUNT > 0 THEN
          -- percorre a PLTABLE refazendo o indice com a composicao dos campos
          FOR idx IN vr_tab_crapvri.FIRST..vr_tab_crapvri.LAST LOOP
            -- monta o indice
            vr_chave_index := vr_tab_crapvri(idx).nrdconta || vr_tab_crapvri(idx).innivris || vr_tab_crapvri(idx).cdmodali || vr_tab_crapvri(idx).nrctremp || vr_tab_crapvri(idx).nrseqctr;
            -- alimenta a nova PLTABLE apenas com os campos necessarios
            vr_tab_crapvri_index(vr_chave_index).vldivida := vr_tab_crapvri(idx).vldivida;
            vr_tab_crapvri_index(vr_chave_index).vltotatr := vr_tab_crapvri(idx).vltotatr;
            vr_tab_crapvri_index(vr_chave_index).qtpreatr := vr_tab_crapvri(idx).qtpreatr;
            vr_tab_crapvri_index(vr_chave_index).vlprejuz := vr_tab_crapvri(idx).vlprejuz;

          END LOOP;
        END IF;
        
        vr_tab_crapvri.DELETE;

      END LOOP;
      CLOSE cr_crapvri;
            
      -- Busca do arquivo para controle de informaçõs da central de risco
      FOR rw_crapris IN cr_crapris LOOP
         BEGIN
            -- Verifica migração/incorporação
            IF NOT fn_verifica_conta_migracao(pr_nrdconta  => rw_crapris.nrdconta) THEN
               CONTINUE;
            END IF;
          
            vr_fleprces := 0;
         
            -- Para Emprestimos/Financiamentos 
            IF rw_crapris.cdorigem = 3 THEN
               -- Para empréstimos BNDES
               IF rw_crapris.dsinfaux = 'BNDES' THEN
                  -- Buscar informações da crapebn
                  OPEN cr_crapebn(pr_nrdconta => rw_crapris.nrdconta
                                 ,pr_nrctremp => rw_crapris.nrctremp);
                  FETCH cr_crapebn 
                    INTO vr_vlpreemp;
                  -- Se encontrou
                  IF cr_crapebn%FOUND  THEN 
                     CLOSE cr_crapebn;
                     vr_cdlcremp := 'BNDES';
                  
                     IF rw_crapris.qtdiaatr > 0  THEN
                        vr_qtatraso := TRUNC(rw_crapris.qtdiaatr / 30 , 0) + 1;
                     ELSE
                        vr_qtatraso := 0;
                     END IF;
                    
                     /* BNDES - Enquanto nao tivermos campo no arquivo de
                          OPERACOES da TOTVS com a quantidade
                          de parcelas em atraso, iremos utilizar a quantidade de
                          meses em atraso. Enquanto nao ultrapassar a da final
                          do contrato nao teremos problema, pois a quantidade de
                          meses em atraso vai bater com a quantidade de parcelas
                          em atraso. Porem, se ultrapassar, a quantidade de
                          meses continuara aumentando, e a quantidade de
                          parcelas nao, e este campo nao podera ser igual.
                     */
                     vr_nroprest := vr_qtatraso;
                  ELSE
                     CLOSE cr_crapebn;
                  END IF;
               -- Empréstimos Cooperativa
               ELSE
                  -- Buscar detalhes dos empréstimos
                  OPEN cr_crapepr(pr_nrdconta => rw_crapris.nrdconta
                                 ,pr_nrctremp => rw_crapris.nrctremp);
                  FETCH cr_crapepr
                   INTO rw_crapepr;
                  -- Somente se encontrar
                  IF cr_crapepr%FOUND THEN
                     -- fechar o cursor e continuar o processo
                     CLOSE cr_crapepr;
                     
                     -- Indicador se é um emprestimo de cessao
                     vr_fleprces := case when rw_crapepr.dtvencto_original is null then 0 else 1 end;
                     
                     -- Inicializar qtde meses decorridos com o valor da tabela
                     vr_qtmesdec := rw_crapepr.qtmesdec;
                     
                     /* Efetuar correcao quantidade parcelas em atraso */

                     vr_qtprecal_intei :=  rw_crapepr.qtprecal;

                     -- Se existir data do primeiro pagamento
                     IF rw_crapepr.dtdpagto IS NOT NULL THEN
                        -- Se o dia de pagamento é posterior E a data correte ainda é no mesmo mÊs
                        --   OU
                        -- Se o dia corrente e o próximo dia util são do mesmo mês e a data de pagamento venceu
                        IF ( to_char(rw_crapepr.dtdpagto,'dd') > to_char(pr_rw_crapdat.dtmvtolt,'dd') AND TRUNC(rw_crapepr.dtdpagto,'mm') = TRUNC(pr_rw_crapdat.dtmvtolt,'mm') )
                        OR ( TRUNC(pr_rw_crapdat.dtmvtolt,'mm') = TRUNC(pr_rw_crapdat.dtmvtopr,'mm') AND rw_crapepr.dtdpagto > pr_rw_crapdat.dtmvtolt ) THEN
                           -- Decrementar -1 mês
                           vr_qtmesdec := vr_qtmesdec - 1;
                        END IF;
                     END IF;

                     -- Iremos buscar a tabela de juros nas linhas de crédito
                     OPEN cr_craplcr( pr_cdcooper => pr_cdcooper
                                     ,pr_cdlcremp => rw_crapepr.cdlcremp);
                     FETCH cr_craplcr INTO rw_craplcr;
                     -- Se não encontrar
                     IF cr_craplcr%NOTFOUND THEN
                        -- Fechar o cursor
                        CLOSE cr_craplcr;
                        -- Gerar erro
                        pr_cdcritic := 363;
                        pr_dscritic := gene0001.fn_busca_critica(363);
                        -- sai do loop e continua o procesamento
                        -- equivalente LEAVE do progress
                        EXIT;
                     END IF;
                     -- Fechar o cursor
                     CLOSE cr_craplcr;

                     IF rw_crapepr.tpemprst = 0 THEN
                        vr_txmenemp := rw_craplcr.txmensal;
                     ELSE
                        vr_txmenemp := rw_crapepr.txmensal;
                     END IF;

                     /* Diario */
                     IF to_char(pr_rw_crapdat.dtmvtolt,'MM') = to_char(pr_rw_crapdat.dtmvtopr,'MM') THEN
                        -- verifica o tipo do emprestimo 0-atual
                        IF rw_crapepr.tpemprst = 0 THEN
                           vr_qtprecal_decim := rw_crapepr.qtlcalat;
                        ELSE /* END IF crapepr.tpemprst = 0 */
                           vr_qtprecal_decim := rw_crapepr.qtpcalat;
                        END IF;

                        -- Guardar o valor retornado para a variavel inteira
                        vr_qtprecal_intei := vr_qtprecal_decim;
                        -- Acumular aos valores de retorno (inteiro e decimal) o valor da tabela
                        vr_qtprecal_intei := vr_qtprecal_intei + rw_crapepr.qtprecal;
                        vr_qtprecal_decim := vr_qtprecal_decim + rw_crapepr.qtprecal;
                        -- Guardar o saldo devedor atual
                        vr_vlsdeved_atual := rw_crapepr.vlsdevat;

                     ELSE /* Mensal */
                        vr_qtprecal_intei := rw_crapepr.qtprecal;
                        vr_vlsdeved_atual := rw_crapepr.vlsdeved;
                        vr_qtprecal_decim := rw_crapepr.qtprecal;
                     END IF;


                     -- Buscando a configuração de empréstimo cfme a empresa da conta
                     empr0001.pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper           --> Código da Cooperativa
                                                        ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt   --> Data corrente
                                                        ,pr_nrdconta => rw_crapris.nrdconta   --> Numero da conta do empréstim
                                                        ,pr_dtcalcul => vr_tab_dtcalcul       --> Data calculada de pagamento
                                                        ,pr_diapagto => vr_tab_diapagto       --> Dia de pagamento das parcelas
                                                        ,pr_flgfolha => vr_tab_flgfolha       --> Flag de desconto em folha S/N
                                                        ,pr_ddmesnov => vr_tab_ddmesnov       --> Configuração para mês novo
                                                        ,pr_cdcritic => pr_cdcritic           --> Código do erro
                                                        ,pr_des_erro => pr_dscritic);

                     -- se existe a taxa no parâmetro e se o
                     -- indicador de liquidacao do emprestimo estiver 0=ativo
                     IF vr_inusatab AND rw_crapepr.inliquid = 0 THEN
                        -- atribui a taxa de juros diaria
                        vr_txdjuros := rw_craplcr.txdiaria;
                     ELSE
                        -- atribui a taxa de juros do emprestimo
                        vr_txdjuros := rw_crapepr.txjuremp;
                     END IF;

                     ----------------------------------
                     -- criando registro de emprestimo
                     ----------------------------------

                     -- criando o indice da tabela temporaria
                     vr_indice := LPAD(rw_crapepr.nrdconta,10,'0')||LPAD(rw_crapepr.nrctremp,10,'0');
                     -- Alimentando a tabela de emprestimos
                     vr_tab_dados_epr(vr_indice).nrdconta := rw_crapepr.nrdconta;
                     vr_tab_dados_epr(vr_indice).nrctremp := rw_crapepr.nrctremp;
                     vr_tab_dados_epr(vr_indice).vlpapgat := rw_crapepr.vlpapgat;
                     vr_tab_dados_epr(vr_indice).flgpagto := rw_crapepr.flgpagto;
                     vr_tab_dados_epr(vr_indice).dtdpagto := rw_crapepr.dtdpagto;
                     vr_tab_dados_epr(vr_indice).vlsdevat := rw_crapepr.vlsdevat;
                     vr_tab_dados_epr(vr_indice).qtpcalat := rw_crapepr.qtpcalat;
                     vr_tab_dados_epr(vr_indice).txmensal := vr_txmenemp;
                     vr_tab_dados_epr(vr_indice).txjuremp := vr_txdjuros;
                     vr_tab_dados_epr(vr_indice).vlppagat := rw_crapepr.vlppagat;
                     vr_tab_dados_epr(vr_indice).qtmdecat := rw_crapepr.qtmdecat;
                     vr_tab_dados_epr(vr_indice).inprejuz := rw_crapepr.inprejuz;
                     vr_tab_dados_epr(vr_indice).inliquid := rw_crapepr.inliquid;
                     vr_tab_dados_epr(vr_indice).qtpreemp := rw_crapepr.qtpreemp;
                     vr_tab_dados_epr(vr_indice).cdlcremp := rw_crapepr.cdlcremp;
                     vr_tab_dados_epr(vr_indice).cdfinemp := rw_crapepr.cdfinemp;
                     vr_tab_dados_epr(vr_indice).dtmvtolt := rw_crapepr.dtmvtolt;
                     vr_tab_dados_epr(vr_indice).vlemprst := rw_crapepr.vlemprst;
                     vr_tab_dados_epr(vr_indice).tpdescto := rw_crapepr.tpdescto; 
                     vr_tab_dados_epr(vr_indice).vljurmes := rw_crapepr.vljurmes;
                     -- Para microcrédito
                     IF rw_craplcr.cdusolcr = 1 AND rw_craplcr.dsorgrec <> ' ' THEN
                       -- Armazenar a origem do Microcrédito 
                       vr_tab_dados_epr(vr_indice).dsorgrec := rw_craplcr.dsorgrec;
                     END IF;
                     -- Armazenar a data de início do contrato
                     vr_tab_dados_epr(vr_indice).dtinictr := rw_crapris.dtinictr;             

                     /* Caso for cessao de credito, a data da primeira parcela eh o vcto original da cessao */
                     IF vr_fleprces = 1 THEN
                        vr_tab_dados_epr(vr_indice).dtdpagto := rw_crapepr.dtvencto_original;
                     END IF;

                     -- Para empréstimo pré-fixado ou Pos-Fixado
                     IF rw_crapepr.tpemprst IN (1,2) THEN
                        -- Utilizaremos o valor da tabela
                        vr_qtdiaatr := rw_crapris.qtdiaatr;
                     ELSE
                        -- Calcular os dias em atraso com base nos meses decorridos
                        vr_qtdiaatr := (vr_qtmesdec - vr_qtprecal_decim) * 30;

                        IF vr_qtdiaatr <= 0 AND rw_crapepr.flgpagto = 0 THEN   -- Conta corrente
                           vr_qtdiaatr := pr_rw_crapdat.dtmvtolt - rw_crapepr.dtdpagto;
                        END IF;

                        -- Garantir que não fique negativo
                        IF vr_qtdiaatr < 0 THEN
                           vr_qtdiaatr := 0;
                        END IF;

                     END IF;

                     -- Decrementar dos meses corridos a quantidade calculada
                     vr_qtmesdec := (vr_qtmesdec - vr_qtprecal_intei);

                     -- Garantir que a quantidade não fique abaixo de zero
                     IF vr_qtmesdec < 0 THEN
                        vr_qtmesdec := 0;
                     END IF;

                     -- Copiar o valor a variável de atraso
                     vr_qtatraso := vr_qtmesdec;

                     -- Garantir que não fique superior a quantidade de parcelas
                     IF vr_qtmesdec > rw_crapepr.qtpreemp THEN
                       vr_qtmesdec := rw_crapepr.qtpreemp;
                     END IF;

                     -- Atribuir aos campos da tabela o valor da parcela e linha de credito
                     vr_vlpreemp := rw_crapepr.vlpreemp;
                     vr_cdlcremp := to_char(rw_crapepr.cdlcremp);
                     vr_cdfinemp := rw_crapepr.cdfinemp;
                     vr_cdusolcr := rw_craplcr.cdusolcr;
                     vr_dsorgrec := rw_craplcr.dsorgrec;

                     CASE rw_crapepr.tpemprst
                       WHEN 0 THEN vr_tpemprst := 'TR';
                       WHEN 1 THEN vr_tpemprst := 'PP';
                       WHEN 2 THEN vr_tpemprst := 'POS';
                       ELSE        vr_tpemprst := '-';
                     END CASE;
                     
                     -- Para empréstimo pré-fixado ou Pos-Fixado
                     IF rw_crapepr.tpemprst IN (1,2) THEN
                        -- Número prestações recebe qtde decorrida - parcelas calculadas
                        vr_nroprest := rw_crapepr.qtmesdec - nvl(rw_crapepr.qtpcalat,0);

                        -- Se deu negativo, considerar 0
                        IF  vr_nroprest < 0  THEN
                            vr_nroprest := 0;
                        END IF;

                        -- Se houver atraso na tabela de risco
                        IF rw_crapris.qtdiaatr > 0 THEN
                           -- Calcular dividindo a quantidade de dias por 30
                           vr_qtatraso := TRUNC(rw_crapris.qtdiaatr/30)+1;
                        ELSE
                           -- Sem atraso
                           vr_qtatraso := 0;
                        END IF;
                     ELSE
                        -- Número de prestações e quantidade em atraso é equivalente a quantidade de meses decorridos
                        vr_nroprest := vr_qtmesdec;
                        vr_qtatraso := vr_qtatraso;
                     END IF;

                  ELSE
                     -- Apenas fechar o cursor
                     CLOSE cr_crapepr;
                     -- Limpar variáveis
                     vr_vlpreemp := NULL;
                     vr_cdlcremp := NULL;
                     vr_cdfinemp := NULL;
                     vr_tpemprst := NULL;
                     vr_cdusolcr := NULL;
                     vr_dsorgrec := NULL;
                  END IF;

               END IF;

               -- Montar chave para tabela de riscos com Nro Prestação
               -- Agencia(5) + NroPrest(12) + NmPrimtl(60) + NrCtrEmp(10) + NrSeqCtr(5)
               -- NrdConta(10) + DtRefere(8) + InNivRis(5)
               vr_des_chave_crapris := LPAD(rw_crapris.cdagenci,5,'0')
                                    || to_char(999999.9999 - nvl(vr_nroprest,0),'000000d0000')
                                    || RPAD(rw_crapris.nmprimtl,60,' ')
                                    || LPAD(rw_crapris.nrctremp,10,'0')
                                    || LPAD(rw_crapris.nrseqctr,5,'0')
                                    || LPAD(rw_crapris.nrdconta,10,'0')
                                    || to_char(rw_crapris.dtrefere,'ddmmyyyy')
                                    || LPAD(rw_crapris.innivris,5,'0');
                                    
            -- Para conta corrente
            ELSIF rw_crapris.cdorigem = 1 THEN
               
               -- Limpar variaveis específicas de empréstimo
               vr_vlpreemp := NULL;
               vr_cdlcremp := NULL;
               vr_nroprest := NULL;
               vr_cdfinemp := NULL;
               vr_tpemprst := NULL;
               vr_qtatraso := 0;
               vr_qtdiaatr := 0;
               vr_cdusolcr := NULL;
               vr_dsorgrec := NULL;               
            
               -- Buscar informaçoes do saldo da conta
               OPEN cr_crapsld(pr_nrdconta => rw_crapris.nrdconta);
               FETCH cr_crapsld
                 INTO rw_crapsld;
                 -- Se tiver encontrado
               IF cr_crapsld%FOUND THEN
                  -- Utilizar o campo com a quantidade de dias com saldo negativo
                  vr_qtatraso := rw_crapsld.qtdriclq;
               END IF;
               -- Fechar o cursor
               CLOSE cr_crapsld;

               -- Montar chave para tabela de riscos sem Nro Prestação
               -- Agencia(5) + NroPrest(12) + NmPrimtl(60) + NrCtrEmp(10) + NrSeqCtr(5)
               -- NrdConta(10) + DtRefere(8) + InNivRis(5)
               vr_des_chave_crapris := LPAD(rw_crapris.cdagenci,5,'0')
                                    || to_char(999999.9999,'000000d0000')
                                    || RPAD(rw_crapris.nmprimtl,60,' ')
                                    || LPAD(rw_crapris.nrctremp,10,'0')
                                    || LPAD(rw_crapris.nrseqctr,5,'0')
                                    || LPAD(rw_crapris.nrdconta,10,'0')
                                    || to_char(rw_crapris.dtrefere,'ddmmyyyy')
                                    || LPAD(rw_crapris.innivris,5,'0');
            ELSE
               -- Limpar variaveis específicas de empréstimo
               vr_vlpreemp := NULL;
               vr_cdlcremp := NULL;
               vr_cdfinemp := NULL;
               vr_nroprest := NULL;
               vr_tpemprst := NULL;
               vr_qtatraso := 0;
               vr_qtdiaatr := 0;
               vr_cdusolcr := NULL;
               vr_dsorgrec := NULL;               

               -- Montar chave para tabela de riscos sem Nro Prestação
               -- Agencia(5) + NroPrest(12) + NmPrimtl(60) + NrCtrEmp(10) + NrSeqCtr(5)
               -- NrdConta(10) + DtRefere(8) + InNivRis(5)
               vr_des_chave_crapris := LPAD(rw_crapris.cdagenci,5,'0')
                                    || to_char(999999.9999,'000000d0000')
                                    || RPAD(rw_crapris.nmprimtl,60,' ')
                                    || LPAD(rw_crapris.nrctremp,10,'0')
                                    || LPAD(rw_crapris.nrseqctr,5,'0')
                                    || LPAD(rw_crapris.nrdconta,10,'0')
                                    || to_char(rw_crapris.dtrefere,'ddmmyyyy')
                                    || LPAD(rw_crapris.innivris,5,'0');

            END IF;

            -- Criar registro com as informações do risco
            vr_tab_crapris(vr_des_chave_crapris).cdagenci := rw_crapris.cdagenci;
            vr_tab_crapris(vr_des_chave_crapris).nroprest := vr_nroprest;
            vr_tab_crapris(vr_des_chave_crapris).nmprimtl := rw_crapris.nmprimtl;
            vr_tab_crapris(vr_des_chave_crapris).nrdconta := rw_crapris.nrdconta;
            vr_tab_crapris(vr_des_chave_crapris).nrcpfcgc := rw_crapris.nrcpfcgc;
            vr_tab_crapris(vr_des_chave_crapris).dtrefere := rw_crapris.dtrefere;
            vr_tab_crapris(vr_des_chave_crapris).innivris := rw_crapris.innivris;
            vr_tab_crapris(vr_des_chave_crapris).nrctremp := rw_crapris.nrctremp;
            vr_tab_crapris(vr_des_chave_crapris).cdmodali := rw_crapris.cdmodali;
            vr_tab_crapris(vr_des_chave_crapris).nrseqctr := rw_crapris.nrseqctr;
            vr_tab_crapris(vr_des_chave_crapris).vldivida := rw_crapris.vldivida;
            vr_tab_crapris(vr_des_chave_crapris).vljura60 := rw_crapris.vljura60;
            vr_tab_crapris(vr_des_chave_crapris).cdorigem := rw_crapris.cdorigem;
            vr_tab_crapris(vr_des_chave_crapris).inpessoa := rw_crapris.inpessoa;
            vr_tab_crapris(vr_des_chave_crapris).qtdriclq := rw_crapris.qtdriclq;
            vr_tab_crapris(vr_des_chave_crapris).vlpreemp := nvl(vr_vlpreemp,0);
            vr_tab_crapris(vr_des_chave_crapris).cdlcremp := vr_cdlcremp;
            vr_tab_crapris(vr_des_chave_crapris).cdfinemp := vr_cdfinemp;
            vr_tab_crapris(vr_des_chave_crapris).qtatraso := vr_qtatraso;
            vr_tab_crapris(vr_des_chave_crapris).cdusolcr := vr_cdusolcr;
            vr_tab_crapris(vr_des_chave_crapris).dsorgrec := vr_dsorgrec;
            vr_tab_crapris(vr_des_chave_crapris).dtinictr := rw_crapris.dtinictr;            
            
            IF rw_crapris.cdorigem = 1 THEN -- conta corrente
              vr_tab_crapris(vr_des_chave_crapris).qtdiaatr := vr_qtatraso;
            ELSE
              vr_tab_crapris(vr_des_chave_crapris).qtdiaatr := vr_qtdiaatr;
            END IF;
            
            vr_tab_crapris(vr_des_chave_crapris).dsinfaux := rw_crapris.dsinfaux;
            vr_tab_crapris(vr_des_chave_crapris).tpemprst := vr_tpemprst;
            vr_tab_crapris(vr_des_chave_crapris).fleprces := nvl(vr_fleprces,0);


            
         EXCEPTION
            WHEN vr_exc_ignorar THEN
               -- Exceção criada apenas para desviar o fluxo
               -- para este ponto e não processar o registro
               NULL;
         END;
      END LOOP; --FOR rw_crapris IN cr_crapris LOOP --> Termino leitura dos riscos

      -------- Inicialização comum de todos os CLOBs de XML ------

      -- Para o crrl227.lst
      dbms_lob.createtemporary(vr_clobxml_227, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml_227, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(pr_xml => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo => '<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Para o crrl354.lst
      dbms_lob.createtemporary(vr_clobxml_354, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml_354, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Para o crr581.lst
      dbms_lob.createtemporary(vr_clobxml_581, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml_581, dbms_lob.lob_readwrite);
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_581
                             ,pr_texto_completo => vr_txtauxi_581
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Somente abrir o arquivo 3 em caso de chamada pelo crps280
      IF pr_cdprogra = 'CRPS280' THEN
         -- Para o crr552.lst
         dbms_lob.createtemporary(vr_clobxml_552, TRUE, dbms_lob.CALL);
         dbms_lob.open(vr_clobxml_552, dbms_lob.lob_readwrite);
         gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_552
                                ,pr_texto_completo => vr_txtauxi_552
                                ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><raiz>');
      END IF;

      -- Buscar o primeiro registro da tabela temporária
      vr_des_chave_crapris := vr_tab_crapris.FIRST;
      LOOP
         -- Sair quando não houverem mais registros a processar
         EXIT WHEN vr_des_chave_crapris IS NULL;

         -- Reiniciar variáveis de controle
         vr_vldivida       := 0;
         vr_vlprejuz_conta := 0;
         vr_qtpreatr       := 0;
         vr_vltotatr       := 0;

         -- Se mudou o PAC ou é o primeiro registro
         IF vr_des_chave_crapris = vr_tab_crapris.FIRST OR vr_tab_crapris(vr_tab_crapris.PRIOR(vr_des_chave_crapris)).cdagenci <> vr_tab_crapris(vr_des_chave_crapris).cdagenci THEN
            -- Buscar nome da agência
            OPEN cr_crapage(vr_tab_crapris(vr_des_chave_crapris).cdagenci);
            FETCH cr_crapage
              INTO vr_nmresage;
            CLOSE cr_crapage;

            -- Inicializar os registros no totalizador de riscos por PAC
            FOR vr_contador IN vr_tab_risco.FIRST..vr_tab_risco.LAST LOOP
              -- Acumular totalizadores por risco geral
              vr_tab_totrispac(vr_contador).qtdabase := 0;
              vr_tab_totrispac(vr_contador).vljrpf60 := 0;
              vr_tab_totrispac(vr_contador).vljrpj60 := 0;
              vr_tab_totrispac(vr_contador).vljura60 := 0;
              vr_tab_totrispac(vr_contador).vlprovis := 0;
              vr_tab_totrispac(vr_contador).vldabase := 0;
            END LOOP;

            -- Reiniciar totalizadores
            vr_tot_qtctremp := 0;
            vr_tot_qtctrato := 0;
            vr_tot_vldespes := 0;
            vr_tot_qtempres := 0;
            vr_tot_vlsdeved := 0;
            vr_med_percentu := 0;
            vr_tot_vlsdvatr := 0;
            vr_tot_vlatraso := 0;
            vr_tot_vlpreatr := 0;
            vr_tot_qtdopera := 0;
            vr_tot_qtdopfis := 0;
            vr_tot_qtdopjur := 0;
            vr_tot_vlropera := 0;
            vr_tot_vlropfis := 0;
            vr_tot_vlropjur := 0;
            vr_tot_qtatrasa := 0;
            vr_tot_qtatrfis := 0;
            vr_tot_qtatrjur := 0;
            vr_tot_vlatrasa := 0;
            vr_tot_vlatrfis := 0;
            vr_tot_vlatrjur := 0;
            -- Reinicializar controle de envio da tag de PAC
            vr_flgpac01 := FALSE;
            vr_flgpac02 := FALSE;

         END IF;

         -- Guardar a origem cfme os tipos
         IF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 1 THEN
           vr_dsorigem := 'C';
         ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem IN(2,4,5) THEN
           vr_dsorigem := 'D';
         ELSE
           vr_dsorigem := 'E';
         END IF;

         -- Se o risco tiver nivel de risco = 9
         IF vr_tab_crapris(vr_des_chave_crapris).innivris = 9 THEN
            -- Preparar as informações para geração de linha no relatório crrl581
            vr_dtfimmes := TRUNC(pr_dtrefere,'mm')-1; --> Mês anterior
            vr_contdata := 1;
            vr_flgrisco := TRUE;

            -- Para origem 3 - empréstimos
            IF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 3 THEN
               -- Multiplicar os dias para termos a informação em meses
               vr_ddatraso := vr_tab_crapris(vr_des_chave_crapris).qtatraso * 30;
            ELSE
               -- Utilizar a informação já retornada
               vr_ddatraso := vr_tab_crapris(vr_des_chave_crapris).qtatraso;
            END IF;

            -- Efetuar laço de 6 tentativas para buscar o risco 9
            -- nos ultimos 6 fechamentos de mês
            vr_dtmesant := LAST_DAY(ADD_MONTHS(TRUNC(pr_dtrefere,'mm'), -1)); --> Ultimo dia Mês anterior (30-31)/MM/YYYY
            vr_dt6meses := ADD_MONTHS(TRUNC(pr_dtrefere,'mm'), -6); --> Primeiro dia de 5 meses atras 01/MM/YYYY

               OPEN cr_crapris_tst(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                  ,pr_innivris => 9
                               ,pr_dtini    => vr_dt6meses
                               ,pr_dtfim    => vr_dtmesant
                                  ,pr_inddocto => 1 ); -- Docto 3020
               FETCH cr_crapris_tst
                INTO vr_exis_crapris;
               -- Se não existir risco H no mês procurado
            IF vr_exis_crapris < 6 THEN
                 vr_flgrisco := FALSE;
               END IF;

            CLOSE cr_crapris_tst;

            -- Se mesmo assim continuar existindo o risco
            IF vr_flgrisco THEN
              -- Enviar o registro para o XML do relatório
              gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_581
                                     ,pr_texto_completo => vr_txtauxi_581
                                     ,pr_texto_novo     =>'<riscoH>'
                                                        ||' <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_crapris(vr_des_chave_crapris).nrdconta))||'</nrdconta>'
                                                        ||' <nmprimtl>'||SUBSTR(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,1,40)||'</nmprimtl>'
                                                        ||' <tpemprst>'||vr_tab_crapris(vr_des_chave_crapris).tpemprst||'</tpemprst>'
                                                        ||' <cdagenci>'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'</cdagenci>'
                                                        ||' <dsorigem>'||vr_dsorigem||'</dsorigem>'
                                                        ||' <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'zz.zzz.zz9'))||'</nrctremp>'
                                                        ||' <cdmodali>'||to_char(vr_tab_crapris(vr_des_chave_crapris).cdmodali,'fm0000')||'</cdmodali>'
                                                        ||' <vldivida>'||to_char(vr_tab_crapris(vr_des_chave_crapris).vldivida,'fm999g999g990d00')||'</vldivida>'
                                                        ||' <ddatraso>'||to_char(vr_ddatraso,'fm999g990')||'</ddatraso>'
                                                        ||'</riscoH>');
            END IF;
         END IF;

         vr_chave_index := vr_tab_crapris(vr_des_chave_crapris).nrdconta || vr_tab_crapris(vr_des_chave_crapris).innivris || 
                           vr_tab_crapris(vr_des_chave_crapris).cdmodali || vr_tab_crapris(vr_des_chave_crapris).nrctremp || 
                           vr_tab_crapris(vr_des_chave_crapris).nrseqctr;


         IF vr_tab_crapvri_index.exists(vr_chave_index) THEN

           vr_vldivida := vr_vldivida + vr_tab_crapvri_index(vr_chave_index).vldivida;
           vr_qtpreatr := vr_tab_crapvri_index(vr_chave_index).qtpreatr;
           vr_vltotatr := vr_vltotatr + vr_tab_crapvri_index(vr_chave_index).vltotatr;
           vr_vlprejuz := vr_vlprejuz + vr_tab_crapvri_index(vr_chave_index).vlprejuz;
           vr_vlprejuz_conta := vr_vlprejuz_conta + vr_tab_crapvri_index(vr_chave_index).vlprejuz;

            END IF;

         -- Somente considerar se houver diferença na dívida, do contrario considerar prejuízo
         IF vr_vlprejuz_conta <> vr_tab_crapris(vr_des_chave_crapris).vldivida THEN
            -- Guardar percentual
            vr_percentu := vr_tab_risco(vr_tab_crapris(vr_des_chave_crapris).innivris).percentu;
            -- Calcular o percentual para o atraso com base nos percentuais da tabela
            vr_vlpercen := vr_percentu / 100;
            -- Calcular o valor de prestação em atraso
            vr_vlpreatr := ROUND( (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60 ) * vr_vlpercen ,2);
            -- Acumular totalizadores por risco de PAC
            vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase + 1;
            vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 + vr_tab_crapris(vr_des_chave_crapris).vljura60;
            -- Acumular juros 60 por PA separando por PF e PJ
            IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
               IF vr_tab_totrispac.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
                  vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 + vr_tab_crapris(vr_des_chave_crapris).vljura60;
               ELSE
                  vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_crapris(vr_des_chave_crapris).vljura60;
               END IF;                   
            ELSE
               IF vr_tab_totrispac.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
                  vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 + vr_tab_crapris(vr_des_chave_crapris).vljura60;
               ELSE
                  vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_crapris(vr_des_chave_crapris).vljura60;                  
               END IF;
            END IF;            
            vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis + vr_vlpreatr;
            vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase := vr_tab_totrispac(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase + vr_vldivida;
            -- Acumular totalizadores por risco geral
            vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).qtdabase + 1;
            vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljura60 + vr_tab_crapris(vr_des_chave_crapris).vljura60;
            -- Acumular juros 60 por PF e PJ
            IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
               IF vr_tab_totrisger.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
                  vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 + vr_tab_crapris(vr_des_chave_crapris).vljura60;
               ELSE
                  vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpf60 := vr_tab_crapris(vr_des_chave_crapris).vljura60;
               END IF;                   
            ELSE
               IF vr_tab_totrisger.EXISTS(vr_tab_crapris(vr_des_chave_crapris).innivris) THEN
                  vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 + vr_tab_crapris(vr_des_chave_crapris).vljura60;
               ELSE
                  vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vljrpj60 := vr_tab_crapris(vr_des_chave_crapris).vljura60;                  
               END IF;
            END IF;
            --
            vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vlprovis + vr_vlpreatr;
            vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase := vr_tab_totrisger(vr_tab_crapris(vr_des_chave_crapris).innivris).vldabase + vr_vldivida;

            -- Para origens de empréstimo
            IF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 3 THEN
               
               
               -- Re-criando o indice da tabela temporaria
               vr_indice := LPAD(vr_tab_crapris(vr_des_chave_crapris).nrdconta,10,'0')
                         || LPAD(vr_tab_crapris(vr_des_chave_crapris).nrctremp,10,'0');
                                   
               -- Checagem Origem
               IF vr_tab_dados_epr.exists(vr_indice) THEN
                  IF vr_tab_dados_epr(vr_indice).dsorgrec IS NOT NULL THEN 
                     -- Checar se este recurso já possui registro na vr_tab_microcredito 
                     IF NOT vr_tab_microcredito.exists(vr_tab_dados_epr(vr_indice).dsorgrec) THEN
                        -- Criar o registro:
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesfis := 0;
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesjur := 0;
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlate59d := 0;
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlaci59d := 0;

                        -- Verificar o grupo conforme os tipos de MicroCrédito
                        IF vr_tab_dados_epr(vr_indice).dsorgrec LIKE '%BRDE%' 
                        OR vr_tab_dados_epr(vr_indice).dsorgrec LIKE '%BNDES%' THEN
                           -- BNDEs
                           vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).idgrumic := 2;        
                        ELSE
                           -- Cecred
                           vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).idgrumic := 1;         
                        END IF;
                     END IF;

                     -- Armazenaremos a operação atual conforme o tipo de pessoa da mesma
                     IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesfis 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesfis + vr_vldivida;
                     ELSE
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesjur 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlpesjur + vr_vldivida;
                     END IF;
                    
                     -- Se o atraso for até 59 dias
                     IF vr_tab_crapris(vr_des_chave_crapris).qtdiaatr <= 59 THEN
                        -- Acumular no período até 59 
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlate59d 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlate59d + vr_vldivida;
                           
                        IF vr_tab_dados_epr(vr_indice).dsorgrec = 'MICROCREDITO DIM' THEN
                           vr_tot_vltttlcr_dim := vr_tot_vltttlcr_dim + vr_vldivida; -- Acumulo total da linha
                        ELSIF vr_tab_dados_epr(vr_indice).dsorgrec IN ('MICROCREDITO PNMPO CAIXA','MICROCREDITO PNMPO DIM') THEN
                           vr_tot_vltttlcr_dim_outros := vr_tot_vltttlcr_dim_outros + vr_vldivida; -- Acumulo total da linha 
                        END IF;
                           
                     ELSE
                        -- Acumular no restante
                        vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlaci59d 
                           := vr_tab_microcredito(vr_tab_dados_epr(vr_indice).dsorgrec).vlaci59d + vr_vldivida;
                           
                        IF vr_tab_dados_epr(vr_indice).dsorgrec = 'MICROCREDITO DIM' THEN
                           vr_totatraso59_dim := vr_totatraso59_dim + vr_vldivida;
                        ELSIF vr_tab_dados_epr(vr_indice).dsorgrec IN ('MICROCREDITO PNMPO CAIXA','MICROCREDITO PNMPO DIM') THEN
                           vr_totatraso59_dim_outros := vr_totatraso59_dim_outros + vr_vldivida;
                        END IF;                           
                           
                     END IF;
                  END IF;
               END IF;
               
               -- Emprestimo de cessao de credito
               IF vr_tab_crapris(vr_des_chave_crapris).fleprces = 1 THEN
               
                 -- Gravar Emprestimos conforme o tipo de pessoa
                  IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                     -- Gravar campos
                     vr_vet_contabi.rel1760   := vr_vet_contabi.rel1760 + vr_vlpreatr;
                     vr_vet_contabi.rel1760_v := vr_vet_contabi.rel1760_v + vr_vldivida;

                     -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                     vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf := vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf + vr_vlpreatr;
                     vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf := vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf + vr_vldivida;
                     
                  ELSE
                     vr_vet_contabi.rel1760   := vr_vet_contabi.rel1760 + vr_vlpreatr;
                     vr_vet_contabi.rel1760_v := vr_vet_contabi.rel1760_v + vr_vldivida;
                     
                     -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                     vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj := vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj + vr_vlpreatr;
                     vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj := vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj + vr_vldivida;
                     
               END IF;
               
               
               
               -- Para modalidade 299 -
               ELSIF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 299 THEN
                  
                  -- Gravar Emprestimos conforme o tipo de pessoa
                  IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                     -- Gravar campos
                     vr_vet_contabi.rel1721   := vr_vet_contabi.rel1721 + vr_vlpreatr;
                     vr_vet_contabi.rel1721_v := vr_vet_contabi.rel1721_v + vr_vldivida;

                     -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                     vr_tab_contab(vr_vlempres_pf)(vr_provis)(1).vlempres_pf := vr_tab_contab(vr_vlempres_pf)(vr_provis)(1).vlempres_pf + vr_vlpreatr;
                     vr_tab_contab(vr_vlempres_pf)(vr_divida)(1).vlempres_pf := vr_tab_contab(vr_vlempres_pf)(vr_divida)(1).vlempres_pf + vr_vldivida;
                     
                  ELSE
                     vr_vet_contabi.rel1723   := vr_vet_contabi.rel1723 + vr_vlpreatr;
                     vr_vet_contabi.rel1723_v := vr_vet_contabi.rel1723_v + vr_vldivida;
                     
                     -- Gravar inf de emprestimos por coluna separando por tipo de pessoa
                     vr_tab_contab(vr_vlempres_pj)(vr_provis)(2).vlempres_pj := vr_tab_contab(vr_vlempres_pj)(vr_provis)(2).vlempres_pj + vr_vlpreatr;
                     vr_tab_contab(vr_vlempres_pj)(vr_divida)(2).vlempres_pj := vr_tab_contab(vr_vlempres_pj)(vr_divida)(2).vlempres_pj + vr_vldivida;
                     
                  END IF;
                  
                  -- Para modalidade 499
               ELSIF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 499 THEN
                  
                  -- Gravar Financiamentos conforme o tipo de pessoa
                  IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                     -- Gravar campos
                     vr_vet_contabi.rel1731_1   := vr_vet_contabi.rel1731_1 + vr_vlpreatr;
                     vr_vet_contabi.rel1731_1_v := vr_vet_contabi.rel1731_1_v + vr_vldivida;
                     
                     -- Gravar inf de financiamento por coluna separando por tipo de pessoa
                     vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(1).vlfinanc_pf := vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(1).vlfinanc_pf + vr_vlpreatr;
                     vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(1).vlfinanc_pf := vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(1).vlfinanc_pf + vr_vldivida;
                     
                  ELSE
                     vr_vet_contabi.rel1731_2   := vr_vet_contabi.rel1731_2 + vr_vlpreatr;
                     vr_vet_contabi.rel1731_2_v := vr_vet_contabi.rel1731_2_v + vr_vldivida;

                     -- Gravar inf de financiamento por coluna separando por tipo de pessoa
                     vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(2).vlfinanc_pj := vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(2).vlfinanc_pj + vr_vlpreatr;
                     vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(2).vlfinanc_pj := vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(2).vlfinanc_pj + vr_vldivida;
                     
                  END IF;

               END IF;
            -- Para origens de conta corrente
            ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 1 THEN
               -- Para modalidade 201
               IF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 0201 THEN
                  -- Cheque Especial
                  vr_vet_contabi.rel1722_0201   := vr_vet_contabi.rel1722_0201 + vr_vlpreatr;
                  vr_vet_contabi.rel1722_0201_v := vr_vet_contabi.rel1722_0201_v + vr_vldivida;
                  
                  -- Gravar inf de cheque especial por coluna separando por tipo de pessoa
                  vr_tab_contab(vr_vlchqesp)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp := vr_tab_contab(vr_vlchqesp)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp + vr_vlpreatr;
                  vr_tab_contab(vr_vlchqesp)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp := vr_tab_contab(vr_vlchqesp)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqesp + vr_vldivida;
                  
               ELSE
                  -- Adiant.Depositante
                  vr_vet_contabi.rel1722_0101   := vr_vet_contabi.rel1722_0101   + vr_vlpreatr;
                  vr_vet_contabi.rel1722_0101_v := vr_vet_contabi.rel1722_0101_v + vr_vldivida;

                  -- Gravar inf de Adiant.Depositante por coluna separando por tipo de pessoa
                  vr_tab_contab(vr_vladtdep)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep := vr_tab_contab(vr_vladtdep)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep + vr_vlpreatr;
                  vr_tab_contab(vr_vladtdep)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep := vr_tab_contab(vr_vladtdep)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vladtdep + vr_vldivida;

               END IF;
            -- Para Desconto de Cheques
            ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 2 THEN
               vr_vet_contabi.rel1724_v_c := vr_vet_contabi.rel1724_v_c + vr_vldivida;
               vr_vet_contabi.rel1724_c   := vr_vet_contabi.rel1724_c   + vr_vlpreatr;
               
               -- Gravar inf de desconto de cheques por coluna separando por tipo de pessoa
               vr_tab_contab(vr_vlchqdes)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes := vr_tab_contab(vr_vlchqdes)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes + vr_vlpreatr;
               vr_tab_contab(vr_vlchqdes)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes := vr_tab_contab(vr_vlchqdes)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vlchqdes + vr_vldivida;
               
               -- Para Desconto de Titulos S/ Registro
            ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 4 THEN
               vr_vet_contabi.rel1724_v_sr := vr_vet_contabi.rel1724_v_sr + vr_vldivida;
               vr_vet_contabi.rel1724_sr   := vr_vet_contabi.rel1724_sr   + vr_vlpreatr;
               
               -- Gravar inf de desconto de titulos s/ registro por coluna separando por tipo de pessoa
               vr_tab_contab(vr_vltitdes_sr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr := vr_tab_contab(vr_vltitdes_sr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr + vr_vlpreatr;
               vr_tab_contab(vr_vltitdes_sr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr := vr_tab_contab(vr_vltitdes_sr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_sr + vr_vldivida;               
               
            -- Desconto de Titulos C/ Registro
            ELSIF vr_tab_crapris(vr_des_chave_crapris).cdorigem = 5 THEN
               vr_vet_contabi.rel1724_v_cr := vr_vet_contabi.rel1724_v_cr + vr_vldivida;
               vr_vet_contabi.rel1724_cr   := vr_vet_contabi.rel1724_cr   + vr_vlpreatr;

               -- Gravar inf de desconto de titulos c/ registro por coluna separando por tipo de pessoa
               vr_tab_contab(vr_vltitdes_cr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr := vr_tab_contab(vr_vltitdes_cr)(vr_provis)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr + vr_vlpreatr;
               vr_tab_contab(vr_vltitdes_cr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr := vr_tab_contab(vr_vltitdes_cr)(vr_divida)(vr_tab_crapris(vr_des_chave_crapris).inpessoa).vltitdes_cr + vr_vldivida;               

            END IF;
            
            -- Totais por PAC
            vr_tot_qtempres := vr_tot_qtempres + 1;
            vr_tot_vlsdeved := vr_tot_vlsdeved + vr_vldivida;
            -- Totalização cfme existência de atraso sim/nao
            
            IF vr_qtpreatr > 0 THEN
               -- Acumular como empréstimo
               vr_tot_qtctremp := vr_tot_qtctremp + 1;
               vr_tot_vlpreatr := vr_tot_vlpreatr + vr_vlpreatr;
            ELSE
               -- Acumular como carteira
               vr_tot_qtctrato := vr_tot_qtctrato + 1;
               vr_tot_vldespes := vr_tot_vldespes + vr_vlpreatr;
            END IF;
            
            -- Acumular valor e quantidade de operações de empréstimo
            vr_tot_vlropera := vr_tot_vlropera + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60);
            vr_tot_qtdopera := vr_tot_qtdopera + 1;

            -- Acumular valor e quantidade de operações de empréstimo por tipo de pessoa
            IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
              vr_tot_vlropfis := vr_tot_vlropfis + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60);
              vr_tot_qtdopfis := vr_tot_qtdopfis + 1;
            ELSE
              vr_tot_vlropjur := vr_tot_vlropjur + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60);
              vr_tot_qtdopjur := vr_tot_qtdopjur + 1;
            END IF;

            -- Se a quantidade de dias em atraso for superior a inadimplencia parametrizada
            IF vr_tab_crapris(vr_des_chave_crapris).qtdiaatr > NVL(vr_atrsinad,0) THEN
              -- Sumarizar nas quantidades de inadimplencia
              vr_tot_vlatrasa := vr_tot_vlatrasa + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60);
              vr_tot_qtatrasa := vr_tot_qtatrasa + 1;
                  
              -- Sumarizar nas quantidades de inadimplencia por tipo de pessoa
              IF vr_tab_crapris(vr_des_chave_crapris).inpessoa = 1 THEN
                vr_tot_vlatrfis := vr_tot_vlatrfis + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60);
                vr_tot_qtatrfis := vr_tot_qtatrfis + 1;
              ELSE
                vr_tot_vlatrjur := vr_tot_vlatrjur + (vr_vldivida - vr_tab_crapris(vr_des_chave_crapris).vljura60);
                vr_tot_qtatrjur := vr_tot_qtatrjur + 1;
              END IF;
                  
            END IF;            

            -- Acumular nas totalizadores de provisão e dívida os valores calculados
            pr_vltotdiv := pr_vltotdiv + vr_vldivida;
            pr_vltotprv := pr_vltotprv + vr_vlpreatr;
         END IF;

         -- Somente em caso de chamada pelo crps280
         
     --IF pr_cdprogra = 'CRPS280' THEN
     -- Regra (IF) comentada para o projeto Contratação de Crédito 
     -- Close Product Backlog Item 4403:Alteração regra no Risco da Melhora - 6 meses
         
            -- Renato Darosci - 30/08/2016 - ao invés de utilizar o percentual de 0.5 na 
            -- condição, vamos verificar o nível de risco "A".
            -- ANTES => IF vr_qtpreatr <= 0 AND vr_percentu <> 0.5 AND
            --
            -- Somente com risco em dia, que não seja do tipo A, Sem Prejuízo e somente Empréstimo
            IF vr_qtpreatr <= 0 AND vr_tab_crapris(vr_des_chave_crapris).innivris <> 2 AND 
               vr_vldivida > 0  AND vr_dsorigem = 'E' THEN -- So emprestimo

               vr_dsnivris := '';
                  
               -- Empréstimo Cooperativa
               OPEN cr_crawepr(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                              ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp);
                                
               FETCH cr_crawepr
                INTO rw_crawepr;
               -- Verifica se encontrou registro 
               IF cr_crawepr%FOUND THEN
                 -- Fechar o cursor para buscar novamente
                 CLOSE cr_crawepr;
                 vr_dsnivris := rw_crawepr.dsnivris;
               ELSE
                 -- Fechar o cursor para buscar novamente
                 CLOSE cr_crawepr;
               END IF; 

               -- Somente continuar se nível não for A
               IF UPPER(vr_dsnivris) <> 'A' AND vr_dsnivris <> ' ' THEN
                 
                 -- Buscar estouro de conta
                 vr_flgexis_estouro := 0;
                 OPEN cr_crapris_est(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                    ,pr_cdorigem => 1 --> Conta
                                    ,pr_cdmodali => 101 --> Adiant. a Depos
                                    ,pr_dtrefere => pr_dtrefere
                                    ,pr_inddocto => 1); --> Dcto 3020
                 FETCH cr_crapris_est
                  INTO vr_flgexis_estouro;
                 CLOSE cr_crapris_est;
                     
                 -- Somente continuar se não encontrou estouro de conta
                 IF vr_flgexis_estouro = 0 THEN
                   
                   -- Buscar quantidade de meses através dos registros na crapris
                   vr_qtd_crapris := 0;
                   OPEN cr_crapris_count(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                        ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp
                                        ,pr_cdorigem => 3);
                   FETCH cr_crapris_count
                    INTO vr_qtd_crapris;
                   CLOSE cr_crapris_count;
                    
                   -- Somente continuar se quantidade de meses é igual ou superior a 6
                   IF vr_qtd_crapris >= 6 THEN
                     
                     -- Se chegou neste ponto, as regras abaixo estão satisfeita e estaremos
                     -- criando um novo registro no relatório 552:
                     --  1) Niveis com risco A, nao podem ser melhorados, entao sao ignorados no relatorio
                     --  2) Nao pode ter estouro de Conta
                     --  3) Emprestimo com igual/mais de 6 meses
                     --  4) Somente quem nao tem Rating

                     -- Iremos enviar o registro do emprestimo no XML 3
                     gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_552
                                            ,pr_texto_completo => vr_txtauxi_552
                                            ,pr_texto_novo     =>'<credito>'
                                                                 ||' <cdagenci>'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'</cdagenci>'
                                                                 ||' <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_crapris(vr_des_chave_crapris).nrdconta))||'</nrdconta>'
                                                                 ||' <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'zz.zzz.zz9'))||'</nrctremp>'
                                                                 ||' <cdfinemp>'||vr_tab_crapris(vr_des_chave_crapris).cdfinemp||'</cdfinemp>'
                                                                 ||' <cdlcremp>'||vr_tab_crapris(vr_des_chave_crapris).cdlcremp||'</cdlcremp>'
                                                                 ||' <vldivida>'||to_char(vr_vldivida,'fm999g999g990d00')||'</vldivida>' -- ver
                                                                 ||' <vlpreatr>'||to_char(vr_vlpreatr,'fm999g999g990d00')||'</vlpreatr>' -- ver
                                                                 ||' <vlpreemp>'||to_char(vr_tab_crapris(vr_des_chave_crapris).vlpreemp,'fm999g999g990d00')||'</vlpreemp>'
                                                                 ||' <percentu>'||to_char(vr_percentu,'fm990d00')||'</percentu>'
                                                                 ||' <desrisco>'||vr_tab_risco(vr_tab_crapris(vr_des_chave_crapris).innivris).dsdrisco||'</desrisco>'
                                                                 ||'</credito>');                                                         
                                                                     
                     -- Atualiza o Risco da proposta de Emprestimo
                     BEGIN
                       UPDATE crawepr SET
                              crawepr.dsnivris = 'A',
                              crawepr.dtaltniv = pr_rw_crapdat.dtmvtolt
                        WHERE crawepr.rowid = rw_crawepr.rowid;
                     EXCEPTION
                       WHEN OTHERS THEN
                         pr_dscritic := 'Erro ao atualizar crawepr. ' || SQLERRM;
                         --Levantar Excecao
                         RAISE vr_exc_erro;
                     END;                           
                   END IF; --> >= 6 meses                        
                 END IF; --> Sem estou de conta
               END IF; --> Nivel <> A               
            END IF; --> Somente com risco em dia, que não seja do tipo A, Sem Prejuízo e somente Empréstimo
         --END IF; --> Somente para crps280
     -- Regra (END IF) comentada para o projeto Contratação de Crédito 
     -- Close Product Backlog Item 4403:Alteração regra no Risco da Melhora - 6 meses


         -- Alimentar varíaveis para detalhamento dos riscos atual e anterior
         vr_dtdrisco := NULL;
         vr_qtdiaris := 0;

         -- Busca o ultimo lançamento de risco para a conta com
         -- valor superior ao valor de arrasto e desta vez com a data igual
         -- a data de referência passada para buscarmos as informações do risco atual
         vr_nivrisco     := NULL;
         rw_crapris_last := NULL;

         FOR rw_crapris_last IN cr_crapris_last(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                                ,pr_dtrefere => pr_dtrefere) LOOP  --> Data passada
             IF rw_crapris_last.vldivida > vr_vlarrast THEN
            vr_nivrisco := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;
                vr_dtdrisco := rw_crapris_last.dtdrisco;
                EXIT;              
         ELSE
               -- atribui na primeira vez e guarda o maior risco
               IF rw_crapris_last.innivris = 10 THEN   
              vr_nivrisco := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;
            
                  -- atribui com data do primeiro registro
                  IF vr_dtdrisco IS NULL THEN
            vr_dtdrisco := rw_crapris_last.dtdrisco;
                      EXIT;
                   END IF;                  
            END IF;
         END IF;
         END LOOP;

         -- Buscar novamente o ultimo lançamento de risco para a conta com
         -- valor superior ao valor de arrasto e data igual ao final do mês         
         vr_dsnivris     := 'A';
         rw_crapris_last := NULL;

         FOR rw_crapris_last IN cr_crapris_last(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                                ,pr_dtrefere => pr_rw_crapdat.dtultdma) LOOP  --> Final do mês anterior
             IF vr_dtdrisco IS NULL THEN
                vr_dtdrisco := rw_crapris_last.dtdrisco;
             END IF;
             
             IF rw_crapris_last.vldivida > vr_vlarrast THEN
            vr_dsnivris := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;
                
                IF rw_crapris_last.innivris = 10 THEN
                   IF vr_nivrisco IS NULL THEN
                      vr_nivrisco := vr_dsnivris;
                   END IF;
                END IF;
               
                EXIT;              
         ELSE
               -- atribui na primeira vez e guarda o maior risco
               IF rw_crapris_last.innivris = 10 THEN   
                  vr_dsnivris := vr_tab_risco_aux(rw_crapris_last.innivris).dsdrisco;

                  IF vr_nivrisco IS NULL THEN
                     vr_nivrisco := vr_dsnivris;
                  END IF;  
               END IF;

             END IF;
         END LOOP;
            
         IF vr_nivrisco IS NULL THEN
            vr_nivrisco := 'A';
            END IF;  
            
         -- Se encontrou o registro
         IF NOT vr_dtdrisco IS NULL THEN
            -- Se a data for anterior ao dia atual
            IF pr_rw_crapdat.dtmvtolt > vr_dtdrisco THEN
               -- Calcular a diferença
               vr_qtdiaris := pr_rw_crapdat.dtmvtolt - vr_dtdrisco;
            END IF;
         END IF;

         -- Reiniciar variavel de controle de grupo empresarial
         vr_pertenge := '';

         -- Verifica se a conta em questao pertence a algum grupo economico
         OPEN cr_crapgrp(pr_nrcpfcgc => vr_tab_crapris(vr_des_chave_crapris).nrcpfcgc);
         FETCH cr_crapgrp
           INTO vr_pertenge; --> Se encontrar registros na consulta, a variavel receberá '*'
         CLOSE cr_crapgrp;
         -- Se houve atraso
         IF vr_qtpreatr > 0 THEN
            -- Acumular no totalizador de saldo devedor
            vr_tot_vlsdvatr := vr_tot_vlsdvatr + vr_vldivida;
         END IF;

         -- Acumular o totalizador de atraso
         vr_tot_vlatraso := vr_tot_vlatraso + vr_vltotatr;

         -- Gerar linha no relatório 227 cfme as regras abaixo:
         -- 1) Existe atraso
         -- 2.1) Modalidade 101 desde que a quantidade de dias Saldo Negativo Risco > dias em atraso
         -- OU
         -- 2.2) OU Modalidade <> 101
         IF vr_qtpreatr > 0 AND
            (   (vr_tab_crapris(vr_des_chave_crapris).cdmodali = 101 AND vr_tab_crapris(vr_des_chave_crapris).qtdriclq >= vr_diasatrs)
              OR
            (vr_tab_crapris(vr_des_chave_crapris).cdmodali <> 101) ) THEN
            
            -- Se ainda não foi enviada a TAG de agência
            IF NOT vr_flgpac01 THEN
               -- Criar a tag do PAC no relatório
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                      ,pr_texto_completo => vr_txtauxi_227
                                      ,pr_texto_novo     => '<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
               -- Ativar flag para não enviar mais a tag de agência
               vr_flgpac01 := TRUE;
            END IF;
            
            -- Buscar valor do Juros +60 Refinanciado
            OPEN cr_juros60_ref(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                               ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp);
            FETCH cr_juros60_ref INTO rw_juros60_ref;              
            IF  cr_juros60_ref%FOUND THEN
              IF  nvl(rw_juros60_ref.vljura60,0) = 0 THEN
                  vr_juros60_ref := 0;
              ELSE
                  vr_juros60_ref := rw_juros60_ref.vljura60;   
              END IF;
            ELSE
                vr_juros60_ref := 0;
            END IF;
            
            CLOSE cr_juros60_ref;
            
            -- Enviar registro para o XML 1
            vr_des_xml_gene := '<atraso>'
                             ||' <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_crapris(vr_des_chave_crapris).nrdconta))||'</nrdconta>'
                             ||' <nmprimtl>'||SUBSTR(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,1,35)||'</nmprimtl>'
                             ||' <tpemprst>'||vr_tab_crapris(vr_des_chave_crapris).tpemprst||'</tpemprst>'
                             ||' <dsorigem>'||vr_dsorigem||'</dsorigem>'
                             ||' <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'zzzzzzz9'))||'</nrctremp>'
                             ||' <vldivida>'||to_char(vr_vldivida,'fm999g999g990d00')||'</vldivida>'
                             ||' <vljura60>'||to_char(vr_tab_crapris(vr_des_chave_crapris).vljura60,'fm999g999g990d00')||'</vljura60>'
                             ||' <vljura60ref>'||to_char(vr_juros60_ref,'fm999g999g990d00')||'</vljura60ref>'
                             ||' <vlpreemp>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).vlpreemp,0),'fm999g990d00')||'</vlpreemp>'
                             ||' <nroprest>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).nroprest,0),'fm990d00')||'</nroprest>'
                             ||' <qtatraso>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtatraso,'fm990d00')||'</qtatraso>'
                             ||' <vltotatr>'||to_char(vr_vltotatr,'fm999g999g990d00')||'</vltotatr>'
                             ||' <vlpreatr>'||to_char(vr_vlpreatr,'fm999g999g990d00')||'</vlpreatr>'
                             ||' <percentu>'||to_char(vr_percentu,'fm990d00')||'</percentu>'
                             ||' <cdagenci>'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'</cdagenci>'
                             ||' <pertenge>'||vr_pertenge||'</pertenge>'
                             ||' <nivrisco>'||vr_nivrisco||'</nivrisco>'
                             ||' <dtdrisco>'||to_char(vr_dtdrisco,'dd/mm/rr')||'</dtdrisco>'
                             ||' <qtdiaris>'||to_char(vr_qtdiaris,'fm9990')||'</qtdiaris>'
                             ||' <qtdiaatr>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtdiaatr,'fm999990')||'</qtdiaatr>';
            
            -- Somente enviar limite de crédio com origem = 'E'
            IF vr_dsorigem = 'E' THEN
              vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp>'||vr_tab_crapris(vr_des_chave_crapris).cdlcremp||'</cdlcremp>';
            ELSE
              vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp/>';
            END IF;

            -- Não enviar nivel em caso de ser AA
            IF vr_dsnivris <> 'AA' THEN
              vr_des_xml_gene := vr_des_xml_gene || '<dsnivris>'||vr_dsnivris||'</dsnivris>';
            ELSE
              vr_des_xml_gene := vr_des_xml_gene || '<dsnivris/>';
            END IF;

            -- Fechar tag atraso enviando pro XML
            gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                  ,pr_texto_completo => vr_txtauxi_227
                                  ,pr_texto_novo     => vr_des_xml_gene || '</atraso>');
         END IF;

         -- Gerar linha no relatório 354 se não houver prejuizo total
         IF vr_vldivida > 0 THEN

            -- Se ainda não foi enviada a TAG de agência
            IF NOT vr_flgpac02 THEN
               -- Criar a tag do PAC no relatório
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                      ,pr_texto_completo => vr_txtauxi_354
                                      ,pr_texto_novo     => '<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
               -- Ativar flag para não enviar mais a tag de agência
               vr_flgpac02 := true;
            END IF;
            
            -- Buscar valor do Juros +60 Refinanciado
            OPEN cr_juros60_ref(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                               ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp);
            FETCH cr_juros60_ref INTO rw_juros60_ref;     
            IF  cr_juros60_ref%FOUND THEN
              IF  nvl(rw_juros60_ref.vljura60,0) = 0 THEN
                  vr_juros60_ref := 0;
              ELSE
                  vr_juros60_ref := rw_juros60_ref.vljura60;   
              END IF;
            ELSE
                vr_juros60_ref := 0;
            END IF;
            CLOSE cr_juros60_ref;
             
            -- Enviar registro para o XML 2
            vr_des_xml_gene :='<divida>'
                            ||' <nrdconta>'||LTRIM(gene0002.fn_mask_conta(vr_tab_crapris(vr_des_chave_crapris).nrdconta))||'</nrdconta>'
                            ||' <nmprimtl>'||SUBSTR(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,1,35)||'</nmprimtl>'
                            ||' <tpemprst>'||vr_tab_crapris(vr_des_chave_crapris).tpemprst||'</tpemprst>'
                            ||' <dsorigem>'||vr_dsorigem||'</dsorigem>'
                            ||' <nrctremp>'||LTRIM(gene0002.fn_mask(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'zzzzzzz9'))||'</nrctremp>'
                            ||' <vldivida>'||to_char(vr_vldivida,'fm999g999g990d00')||'</vldivida>'
                            ||' <vljura60>'||to_char(vr_tab_crapris(vr_des_chave_crapris).vljura60,'fm999g990d00')||'</vljura60>'
                            ||' <vljura60ref>'||to_char(vr_juros60_ref,'fm999g999g990d00')||'</vljura60ref>'
                            ||' <vlpreemp>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).vlpreemp,0),'fm999g990d00')||'</vlpreemp>'
                            ||' <nroprest>'||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).nroprest,0),'fm990d00')||'</nroprest>'
                            ||' <qtatraso>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtatraso,'fm990d00')||'</qtatraso>'
                            ||' <vltotatr>'||to_char(vr_vltotatr,'fm999g999g990d00')||'</vltotatr>'
                            ||' <cdagenci>'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'</cdagenci>'
                            ||' <vlpreatr>'||to_char(vr_vlpreatr,'fm999g999g990d00')||'</vlpreatr>'
                            ||' <percentu>'||to_char(vr_percentu,'fm990d00')||'</percentu>'
                            ||' <pertenge>'||vr_pertenge||'</pertenge>'
                            ||' <nivrisco>'||vr_nivrisco||'</nivrisco>'
                            ||' <dtdrisco>'||to_char(vr_dtdrisco,'dd/mm/rr')||'</dtdrisco>'
                            ||' <qtdiaris>'||to_char(vr_qtdiaris,'fm9990')||'</qtdiaris>'
                            ||' <qtdiaatr>'||to_char(vr_tab_crapris(vr_des_chave_crapris).qtdiaatr,'fm999990')||'</qtdiaatr>';

            -- Somente enviar limite de crédio com origem = 'E'
            IF vr_dsorigem = 'E' THEN
               vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp>'||vr_tab_crapris(vr_des_chave_crapris).cdlcremp||'</cdlcremp>';
            ELSE
               vr_des_xml_gene := vr_des_xml_gene || '<cdlcremp/>';
            END IF;

            -- Não enviar nivel em caso de ser AA
            IF vr_dsnivris <> 'AA' THEN
               vr_des_xml_gene := vr_des_xml_gene || '<dsnivris>'||vr_dsnivris||'</dsnivris>';
            ELSE
               vr_des_xml_gene := vr_des_xml_gene || '<dsnivris/>';
            END IF;

            -- Finalmente enviar para o XML
            gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                   ,pr_texto_completo => vr_txtauxi_354
                                   ,pr_texto_novo     => vr_des_xml_gene||'</divida>');

            -- Desde que o programa chamador não seja o 184
            IF pr_cdprogra <> 'CRPS184' THEN
               -- Limpar linha de Crédito
               vr_cdlcremp_354 := ' ';

               -- Somente se a origem for empréstimo
               IF vr_dsorigem = 'E' THEN
                  vr_cdlcremp_354 := vr_tab_crapris(vr_des_chave_crapris).cdlcremp;
                  -- inicializando o valor
                  vr_vlpreapg := 0;
                  -- monta o indice de busca dos emprestimo
                  vr_indice   := lpad(vr_tab_crapris(vr_des_chave_crapris).nrdconta,10,'0')||
                                 lpad(vr_tab_crapris(vr_des_chave_crapris).nrctremp,10,'0');

                  -- se existir registro na tabela de emprestimo
                  --IF vr_indice IS NOT NULL THEN
                  IF vr_tab_dados_epr.exists(vr_indice) THEN
                     
                     -- Copiar o valor do atraso
                     vr_vlpreapg := vr_tab_dados_epr(vr_indice).vlpapgat;

                     IF ((pr_cdcooper = 1) AND  /* 1 - Viacredi */  
                        (vr_tab_dados_epr(vr_indice).cdlcremp = 800 OR
                         vr_tab_dados_epr(vr_indice).cdlcremp = 900 OR
                         vr_tab_dados_epr(vr_indice).cdlcremp = 907 OR
                         vr_tab_dados_epr(vr_indice).cdlcremp = 909)) THEN
                        vr_cdorigem := 2; -- Desconto
                     ELSIF ((pr_cdcooper = 2)  AND /* 2 - Creditextil */
                            (vr_tab_dados_epr(vr_indice).cdlcremp = 850 OR
                             vr_tab_dados_epr(vr_indice).cdlcremp = 900)) THEN                  
                        vr_cdorigem := 2; -- Desconto  
                     ELSIF ((pr_cdcooper = 13) AND /* 13 - SCRCRED */
                            (vr_tab_dados_epr(vr_indice).cdlcremp = 800 OR
                             vr_tab_dados_epr(vr_indice).cdlcremp = 900 OR
                             vr_tab_dados_epr(vr_indice).cdlcremp = 903)) THEN
                        vr_cdorigem := 2; -- Desconto
                     ELSIF (((pr_cdcooper <> 1) AND (pr_cdcooper <> 2) AND (pr_cdcooper <> 13)) AND 
                           (vr_tab_dados_epr(vr_indice).cdlcremp = 800 OR
                             vr_tab_dados_epr(vr_indice).cdlcremp = 900)) THEN
                        vr_cdorigem := 2; -- Desconto
                     ELSE
                        vr_cdorigem := 3;
                     END IF;

                     -- Flag de residuo
                     IF  vr_tab_dados_epr(vr_indice).inprejuz  = 0 AND
                         vr_tab_dados_epr(vr_indice).inliquid  = 0 AND
                         vr_tab_dados_epr(vr_indice).vlsdevat >= 0 AND
                         vr_tab_dados_epr(vr_indice).qtpcalat >= vr_tab_dados_epr(vr_indice).qtpreemp  THEN
                       --informa que existe residuo
                       vr_flgresid := 1;
                     ELSE 
                       vr_flgresid := 0;                    
                     END IF;

                     -- Grupo economico
                     IF vr_pertenge = '*'  THEN
                        vr_flgrpeco := 1;
                     ELSE
                        vr_flgrpeco := 0;
                     END IF;

                     -- verifica o indicador de consignado
                     IF vr_tab_dados_epr(vr_indice).tpdescto = 2 THEN
                       vr_flgconsg := 1;
                     ELSE
                       vr_flgconsg := 0;
                     END IF;

                     -- Somente atualiza os dados para o Cyber caso nao esteja rodando na Cecred
                     IF pr_cdcooper <> 3 THEN
                     -- Atualiza dados do emprestimo para o CYBER
                     cybe0001.pc_atualiza_dados_financeiro(pr_cdcooper => pr_cdcooper                                   -- Codigo da Cooperativa
                                                          ,pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta -- Numero da conta
                                                          ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp -- Numero do contrato
                                                          ,pr_cdorigem => vr_cdorigem                                   -- Origem cyber
                                                          ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt                        -- Identifica a data de criacao do reg. de cobranca na CYBER.
                                                          ,pr_vlsdeved => vr_tab_dados_epr(vr_indice).vlsdevat          -- Saldo devedor
                                                          ,pr_vlpreapg => vr_tab_dados_epr(vr_indice).vlpapgat          -- Valor a regularizar
                                                          ,pr_qtprepag => vr_tab_dados_epr(vr_indice).qtpcalat          -- Prestacoes Pagas
                                                          ,pr_txmensal => vr_tab_dados_epr(vr_indice).txmensal          -- Taxa mensal
                                                          ,pr_txdiaria => vr_tab_dados_epr(vr_indice).txjuremp          -- Taxa diaria
                                                          ,pr_vlprepag => vr_tab_dados_epr(vr_indice).vlppagat          -- Vlr. Prest. Pagas
                                                          ,pr_qtmesdec => vr_tab_dados_epr(vr_indice).qtmdecat          -- Qtd. meses decorridos
                                                          ,pr_dtdpagto => vr_tab_dados_epr(vr_indice).dtdpagto          -- Data de pagamento
                                                          ,pr_cdlcremp => vr_tab_dados_epr(vr_indice).cdlcremp          -- Codigo da linha de credito
                                                          ,pr_cdfinemp => vr_tab_dados_epr(vr_indice).cdfinemp          -- Codigo da finalidade.
                                                          ,pr_dtefetiv => vr_tab_dados_epr(vr_indice).dtmvtolt          -- Data da efetivacao do emprestimo.
                                                          ,pr_vlemprst => vr_tab_dados_epr(vr_indice).vlemprst          -- Valor emprestado.
                                                          ,pr_qtpreemp => vr_tab_dados_epr(vr_indice).qtpreemp          -- Quantidade de prestacoes.
                                                          ,pr_flgfolha => vr_tab_dados_epr(vr_indice).flgpagto          -- O pagamento e por Folha
                                                          ,pr_vljura60 => vr_tab_crapris(vr_des_chave_crapris).vljura60 -- Juros 60 dias
                                                          ,pr_vlpreemp => vr_tab_crapris(vr_des_chave_crapris).vlpreemp -- Valor da prestacao
                                                          ,pr_qtpreatr => vr_tab_crapris(vr_des_chave_crapris).nroprest -- Qtd. Prestacoes
                                                          ,pr_vldespes => vr_vlpreatr                                   -- Valor despesas
                                                          ,pr_vlperris => vr_percentu                                   -- Valor percentual risco
                                                          ,pr_nivrisat => vr_dsnivris                                   -- Risco atual
                                                          ,pr_nivrisan => vr_nivrisco                                   -- Risco anterior
                                                          ,pr_dtdrisan => vr_dtdrisco                                   -- Data risco anterior
                                                          ,pr_qtdiaris => vr_qtdiaris                                   -- Quantidade dias risco
                                                          ,pr_qtdiaatr => vr_tab_crapris(vr_des_chave_crapris).qtdiaatr -- Dias de atraso
                                                          ,pr_flgrpeco => vr_flgrpeco                                   -- Grupo Economico
                                                          ,pr_flgpreju => vr_tab_dados_epr(vr_indice).inprejuz          -- Esta em prejuizo.
                                                          ,pr_flgconsg => vr_flgconsg                                   --Indicador de valor consignado.
                                                          ,pr_flgresid => vr_flgresid                                   -- Flag de residuo
                                                          ,pr_dscritic => pr_dscritic);

                     IF pr_dscritic IS NOT NULL  THEN
                        RAISE vr_exc_erro;
                     END IF;
                     END IF;
                 
                  END IF; -- IF vr_indice IS NOT NULL THEN

                  -- Origem de conta corrente e Adiant. a Depositante 
               ELSIF vr_dsorigem = 'C' AND vr_tab_crapris(vr_des_chave_crapris).cdmodali = 0101  THEN  

                  -- Grupo economico
                  IF vr_pertenge = '*'  THEN
                     vr_flgrpeco := 1;
                  ELSE
                     vr_flgrpeco := 0;
                  END IF;

                  -- Somente atualiza os dados para o Cyber caso nao esteja rodando na Cecred
                  IF pr_cdcooper <> 3 THEN
                  -- Atualizar os contratos em cobranca do CYBER
                  cybe0001.pc_atualiza_dados_financeiro (pr_cdcooper => pr_cdcooper                                   -- Codigo da Cooperativa
                                                        ,pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta -- Numero da conta
                                                        ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp -- Numero do contrato
                                                        ,pr_cdorigem => 1                                             -- Conta corrente
                                                        ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt                        -- Identifica a data de criacao do reg. de cobranca na CYBER.
                                                        ,pr_dtdpagto => pr_rw_crapdat.dtmvtolt                        -- Data de pagamento
                                                        ,pr_dtefetiv => pr_rw_crapdat.dtmvtolt                        -- Data da efetivacao do emprestimo.
                                                        ,pr_qtpreemp => 1                                             -- Quantidade de prestacoes.
                                                        ,pr_vlemprst => vr_vldivida                                   -- Valor emprestado.
                                                        ,pr_vlsdeved => vr_vldivida                                   -- Saldo devedor
                                                        ,pr_vljura60 => vr_tab_crapris(vr_des_chave_crapris).vljura60 -- Juros 60 dias
                                                        ,pr_vlpreemp => vr_tab_crapris(vr_des_chave_crapris).vlpreemp -- Valor da prestacao
                                                        ,pr_qtpreatr => vr_tab_crapris(vr_des_chave_crapris).nroprest -- Qtd. Prestacoes
                                                        ,pr_vlpreapg => vr_vldivida                                   -- Valor a regularizar
                                                        ,pr_vldespes => vr_vlpreatr                                   -- Valor despesas
                                                        ,pr_vlperris => vr_percentu                                   -- Valor percentual risco
                                                        ,pr_nivrisat => vr_dsnivris                                   -- Risco atual
                                                        ,pr_nivrisan => vr_nivrisco                                   -- Risco anterior
                                                        ,pr_dtdrisan => vr_dtdrisco                                   -- Data risco anterior
                                                        ,pr_qtdiaris => vr_qtdiaris                                   -- Quantidade dias risco
                                                        ,pr_qtdiaatr => vr_tab_crapris(vr_des_chave_crapris).qtatraso -- Dias de atraso
                                                        ,pr_flgrpeco => vr_flgrpeco                                   -- Grupo Economico
                                                        ,pr_flgresid => 0                                             -- Flag de residuo
                                                        ,pr_qtprepag => 0                                             -- Prestacoes Pagas
                                                        ,pr_txmensal => vr_txmensal                                   -- Taxa mensal
                                                        ,pr_txdiaria => 0                                             -- Taxa diaria
                                                        ,pr_vlprepag => 0                                             -- Vlr. Prest. Pagas
                                                        ,pr_qtmesdec => 0                                             -- Qtd. meses decorridos
                                                        ,pr_cdlcremp => 0                                             -- Codigo da linha de credito
                                                        ,pr_cdfinemp => 0                                             -- Codigo da finalidade.
                                                        ,pr_flgfolha => 0                                             -- O pagamento e por Folha
                                                        ,pr_flgpreju => 0                                             -- Esta em prejuizo.
                                                        ,pr_flgconsg => 0                                             --Indicador de valor consignado.
                                                        ,pr_dscritic => pr_dscritic);

                  IF pr_dscritic IS NOT NULL  THEN
                     RAISE vr_exc_erro;
                  END IF;                
               END IF;
               END IF;

               -- Enviar a linha arquivo arquivo 354.txt
               gene0002.pc_escreve_xml(pr_xml => vr_clob_354
                                      ,pr_texto_completo => vr_txtarqui_354
                                      ,pr_texto_novo =>RPAD(vr_tab_crapris(vr_des_chave_crapris).nrdconta,8,' ')||vr_dssepcol_354
                                                     ||RPAD(vr_tab_crapris(vr_des_chave_crapris).nmprimtl,50,' ')||vr_dssepcol_354
                                                     ||RPAD(vr_tab_crapris(vr_des_chave_crapris).tpemprst,4,' ')||vr_dssepcol_354
                                                     ||vr_dsorigem||vr_dssepcol_354
                                                     ||LPAD(to_char(vr_tab_crapris(vr_des_chave_crapris).nrctremp,'fm99999999'),8,' ')||vr_dssepcol_354
                                                     ||RPAD(vr_cdlcremp_354,8,' ')||vr_dssepcol_354
                                                     ||RPAD(vr_vldivida,8,' ')||vr_dssepcol_354
                                                     ||RPAD(NVL(to_char(vr_tab_crapris(vr_des_chave_crapris).vljura60),' '),8,' ')||vr_dssepcol_354
                                                     ||RPAD(NVL(to_char(vr_tab_crapris(vr_des_chave_crapris).vlpreemp),' '),8,' ')||vr_dssepcol_354
                                                     ||to_char(nvl(vr_tab_crapris(vr_des_chave_crapris).nroprest,0),'999990d00')||vr_dssepcol_354
                                                     ||RPAD(vr_vltotatr,8,' ')||vr_dssepcol_354
                                                     ||RPAD(vr_vlpreatr,8,' ')||vr_dssepcol_354
                                                     ||LPAD(to_char(vr_percentu,'fm990d00'),6,' ')||vr_dssepcol_354
                                                     ||LPAD(vr_tab_crapris(vr_des_chave_crapris).cdagenci,3,' ')||vr_dssepcol_354
                                                     ||to_char(vr_tab_crapris(vr_des_chave_crapris).qtatraso,'999990d00')||vr_dssepcol_354
                                                     ||RPAD(vr_dsnivris,8,' ')||vr_dssepcol_354
                                                     ||RPAD(vr_nivrisco,8,' ')||vr_dssepcol_354
                                                     ||to_char(vr_dtdrisco,'dd/mm/rr')||vr_dssepcol_354
                                                     ||RPAD(vr_qtdiaris,8,' ')||vr_dssepcol_354
                                                     ||LPAD(to_char(vr_tab_crapris(vr_des_chave_crapris).qtdiaatr,'fm99999999'),10,' ') || vr_dssepcol_354
                                                     ||LPAD(to_char(NVL(vr_vlpreapg,0),'fm999G999G999G990D00'),18,' ')
                                                     ||chr(10));
            END IF;
         END IF;
        
         -- Se é o ultimo registro do PAC ou é o ultro registro da tabela
         IF vr_des_chave_crapris = vr_tab_crapris.LAST OR vr_tab_crapris(vr_tab_crapris.NEXT(vr_des_chave_crapris)).cdagenci <> vr_tab_crapris(vr_des_chave_crapris).cdagenci THEN
  
            -- Se uma das variáveis de pac estão ativas
            IF vr_flgpac01 OR vr_flgpac02 THEN

               -- Testar caso uma das flags não esteja ativa e em caso positivo enviar a tag da agência
               -- pois mesmo não existindo detalhes do 227 ou do 354 existe do outro, e então temos que
               -- enviar as informações totalizadoras e de risco
               IF NOT vr_flgpac01 THEN
                  -- Criar a tag do PAC no relatório
                  gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                         ,pr_texto_completo => vr_txtauxi_227
                                         ,pr_texto_novo     =>'<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
                  -- Ativar flag para não enviar mais a tag de agência
                  vr_flgpac01 := true;
               END IF;

               IF NOT vr_flgpac02 THEN
                  -- Criar a tag do PAC no relatório
                  gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                         ,pr_texto_completo => vr_txtauxi_354
                                         ,pr_texto_novo     => '<agencia cdagenci="'||vr_tab_crapris(vr_des_chave_crapris).cdagenci||'" nmresage="'||vr_nmresage||'">');
                  -- Ativar flag para não enviar mais a tag de agência
                  vr_flgpac02 := true;
               END IF;

               -- Somente calcular o total percentual se saldo devedor > 0
               IF vr_tot_vlsdeved > 0 THEN
                  vr_med_percentu := (vr_tot_vlatraso / vr_tot_vlsdeved)*100;
               ELSE
                  vr_med_percentu := null;
               END IF;
               
               -- Somente se houver valor de operação
               IF vr_tot_vlropera <> 0 THEN
                  vr_med_atrsinad := ROUND(((vr_tot_vlatrasa / vr_tot_vlropera) * 100),2);
               ELSE
                  vr_med_atrsinad := 0;
               END IF;
               
               -- Somente se houver valor de operação por pessoa fisica
               IF vr_tot_vlropfis <> 0 THEN
                  vr_med_atindfis := ROUND(((vr_tot_vlatrfis / vr_tot_vlropfis) * 100),2);
               ELSE
                  vr_med_atindfis := 0;
               END IF;
               
               -- Somente se houver valor de operação por pessoa juridica
               IF vr_tot_vlropjur <> 0 THEN
                  vr_med_atindjur := ROUND(((vr_tot_vlatrjur / vr_tot_vlropjur) * 100),2);
               ELSE
                  vr_med_atindjur := 0;
               END IF;

               -- Montar informações de totalização e provisão
               vr_des_xml_gene := '<totalizacao>'
                               || '  <qtctremp>'||to_char(vr_tot_qtctremp,'fm999g990')||'</qtctremp>'
                               || '  <vlsdvatr>'||to_char(vr_tot_vlsdvatr,'fm999g999g999g990d00')||'</vlsdvatr>'
                               || '  <vlatraso>'||to_char(vr_tot_vlatraso,'fm999g999g999g990d00')||'</vlatraso>'
                               || '  <qtempres>'||to_char(vr_tot_qtempres,'fm999g990')||'</qtempres>'
                               || '  <vlsdeved>'||to_char(vr_tot_vlsdeved,'fm999g999g999g990d00')||'</vlsdeved>'
                               || '  <percentu>'||to_char(vr_med_percentu,'fm990d00')||'</percentu>'
                               || '  <vlpreatr>'||to_char(vr_tot_vlpreatr,'fm999g999g999g990d00')||'</vlpreatr>'
                               || '  <qtctrato>'||to_char(vr_tot_qtctrato,'fm999g990')||'</qtctrato>'
                               || '  <vldespes>'||to_char(vr_tot_vldespes,'fm999g999g999g990d00')||'</vldespes>'
                               || '  <percbase>'||to_char(vr_percbase,'fm990d00')||'</percbase>'
                               || '  <qtdopera>'||to_char(vr_tot_qtdopera,'fm999g990')||'</qtdopera>'
                               || '  <qtdopfis>'||to_char(vr_tot_qtdopfis,'fm999g990')||'</qtdopfis>'
                               || '  <qtdopjur>'||to_char(vr_tot_qtdopjur,'fm999g990')||'</qtdopjur>'                               
                               || '  <vlropera>'||to_char(vr_tot_vlropera,'fm999g999g999g990d00')||'</vlropera>'
                               || '  <vlropfis>'||to_char(vr_tot_vlropfis,'fm999g999g999g990d00')||'</vlropfis>'
                               || '  <vlropjur>'||to_char(vr_tot_vlropjur,'fm999g999g999g990d00')||'</vlropjur>'
                               || '  <qtatrasa>'||to_char(vr_tot_qtatrasa,'fm999g990')||'</qtatrasa>'
                               || '  <qtatrfis>'||to_char(vr_tot_qtatrfis,'fm999g990')||'</qtatrfis>'
                               || '  <qtatrjur>'||to_char(vr_tot_qtatrjur,'fm999g990')||'</qtatrjur>'
                               || '  <vlatrasa>'||to_char(vr_tot_vlatrasa,'fm999g999g999g990d00')||'</vlatrasa>'
                               || '  <vlatrfis>'||to_char(vr_tot_vlatrfis,'fm999g999g999g990d00')||'</vlatrfis>'
                               || '  <vlatrjur>'||to_char(vr_tot_vlatrjur,'fm999g999g999g990d00')||'</vlatrjur>'                                                              
                               || '  <atrsinad>'||to_char(nvl(vr_atrsinad,0),'fm990')||'</atrsinad>'
                               || '  <med_atrsinad>'||to_char(vr_med_atrsinad,'fm999g990d00')||'%</med_atrsinad>'
                               || '  <med_atindfis>'||to_char(vr_med_atindfis,'fm999g990d00')||'%</med_atindfis>'
                               || '  <med_atindjur>'||to_char(vr_med_atindjur,'fm999g990d00')||'%</med_atindjur>'
                               || '  <vlprejuz/>'
                               || '</totalizacao>';

               -- Enviar informações de totalização para os relatórios 1 e 2
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                    ,pr_texto_completo => vr_txtauxi_227
                                    ,pr_texto_novo     => vr_des_xml_gene);
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                      ,pr_texto_completo => vr_txtauxi_354
                                      ,pr_texto_novo     => vr_des_xml_gene);
               -- Reiniciar string genérica
               vr_des_xml_gene := '<tabriscos>';

               -- Para cada registro da tabela de riscos por PAC (Navegar somente até last-1 para não mostrar o HH)
               FOR vr_ind IN vr_tab_totrispac.FIRST..vr_tab_totrispac.LAST-1 LOOP
                  -- Criar uma nova tag para o risco atual
                  vr_des_xml_gene := vr_des_xml_gene
                                  ||'<risco>'
                                  ||' <dsdrisco>'||vr_tab_risco(vr_ind).dsdrisco||'</dsdrisco>'
                                  ||' <percentu>'||to_char(vr_tab_risco(vr_ind).percentu,'fm990d00')||'</percentu>'
                                  ||' <qtdabase>'||to_char(vr_tab_totrispac(vr_ind).qtdabase,'fm999g990')||'</qtdabase>'
                                  ||' <vldabase>'||to_char(vr_tab_totrispac(vr_ind).vldabase,'fm999g999g999g990d00')||'</vldabase>'
                                  ||' <vljrpf60>'||to_char(vr_tab_totrispac(vr_ind).vljrpf60,'fm999g999g999g990d00')||'</vljrpf60>'
                                  ||' <vljrpj60>'||to_char(vr_tab_totrispac(vr_ind).vljrpj60,'fm999g999g999g990d00')||'</vljrpj60>'                                  
                                  ||' <vljura60>'||to_char(vr_tab_totrispac(vr_ind).vljura60,'fm999g999g999g990d00')||'</vljura60>'
                                  ||' <vlprovis>'||to_char(vr_tab_totrispac(vr_ind).vlprovis,'fm999g999g999g990d00')||'</vlprovis>'
                                  ||'</risco>';
               END LOOP;

               -- Fechar tag de tab de riscos
               vr_des_xml_gene := vr_des_xml_gene||'</tabriscos>';
               
               -- Enviar o quadro de valores por risco montado na string
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                      ,pr_texto_completo => vr_txtauxi_227
                                      ,pr_texto_novo     => vr_des_xml_gene);
               
               -- Zerar os totalizadores por risco por PAC
               vr_tab_totrispac.DELETE;
               
               -- Fechar a tag do PAC nos relatórios 227 e 354 (1 e 2)
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                                      ,pr_texto_completo => vr_txtauxi_227
                                      ,pr_texto_novo     => '</agencia>');
               
               gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                                      ,pr_texto_completo => vr_txtauxi_354
                                      ,pr_texto_novo     => '</agencia>');
               
               -- Sumarizar totalizadores
               vr_tot_qtctremp_geral := vr_tot_qtctremp_geral + vr_tot_qtctremp;
               vr_tot_vlpreatr_geral := vr_tot_vlpreatr_geral + vr_tot_vlpreatr;
               vr_tot_qtctrato_geral := vr_tot_qtctrato_geral + vr_tot_qtctrato;
               vr_tot_vldespes_geral := vr_tot_vldespes_geral + vr_tot_vldespes;
               vr_tot_qtempres_geral := vr_tot_qtempres_geral + vr_tot_qtempres;
               vr_tot_vlatraso_geral := vr_tot_vlatraso_geral + vr_tot_vlatraso;
               vr_tot_vlsdeved_geral := vr_tot_vlsdeved_geral + vr_tot_vlsdeved;
               vr_tot_qtdopera_geral := vr_tot_qtdopera_geral + vr_tot_qtdopera;
               vr_tot_qtdopfis_geral := vr_tot_qtdopfis_geral + vr_tot_qtdopfis;
               vr_tot_qtdopjur_geral := vr_tot_qtdopjur_geral + vr_tot_qtdopjur;
               vr_tot_vlropera_geral := vr_tot_vlropera_geral + vr_tot_vlropera;
               vr_tot_vlropfis_geral := vr_tot_vlropfis_geral + vr_tot_vlropfis;
               vr_tot_vlropjur_geral := vr_tot_vlropjur_geral + vr_tot_vlropjur;
               vr_tot_qtatrasa_geral := vr_tot_qtatrasa_geral + vr_tot_qtatrasa;
               vr_tot_qtatrfis_geral := vr_tot_qtatrfis_geral + vr_tot_qtatrfis;
               vr_tot_qtatrjur_geral := vr_tot_qtatrjur_geral + vr_tot_qtatrjur;
               vr_tot_vlatrasa_geral := vr_tot_vlatrasa_geral + vr_tot_vlatrasa;
               vr_tot_vlatrfis_geral := vr_tot_vlatrfis_geral + vr_tot_vlatrfis;
               vr_tot_vlatrjur_geral := vr_tot_vlatrjur_geral + vr_tot_vlatrjur;
            END IF;
         END IF;
         
         --Agupar valores microcrédito das filiadas por finalidade
         IF pr_cdcooper = 3 AND (TRUNC(pr_rw_crapdat.dtmvtolt,'mm') <> TRUNC(pr_rw_crapdat.dtmvtopr,'mm')) THEN
            
            IF ((vr_tab_crapris(vr_des_chave_crapris).cdfinemp IN (1,4) AND
                vr_tab_crapris(vr_des_chave_crapris).cdusolcr = 1) OR
                (vr_tab_crapris(vr_des_chave_crapris).cdfinemp IN (2,3)) AND
                 vr_tab_crapris(vr_des_chave_crapris).cdusolcr = 0) AND
               vr_tab_crapris(vr_des_chave_crapris).dsorgrec <> ' ' THEN
          
               -- Garantir que a finalidade exista na PL Table
               IF NOT vr_tab_miccred_fin.exists(vr_tab_crapris(vr_des_chave_crapris).cdfinemp) THEN
                 vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vllibctr    := 0;
                 vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlaprrec    := 0;
                 vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlprvper    := 0;
                 vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar91  := 0;
                 vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar95  := 0;
                 vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar441 := 0;                 
               END IF;
               
               --Apenas contratos liberados no mês
               IF vr_tab_crapris(vr_des_chave_crapris).dtinictr BETWEEN TRUNC(pr_rw_crapdat.dtmvtolt,'mm') 
                                                                    AND pr_rw_crapdat.dtmvtolt THEN 
                 vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vllibctr := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vllibctr + vr_tab_dados_epr(vr_indice).vlemprst;
               END IF;

               vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlaprrec := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlaprrec + vr_tab_dados_epr(vr_indice).vljurmes;
               vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlprvper := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vlprvper + vr_vlpreatr;

               -- Busca valor de parcelas pagas
               FOR rw_craplem in cr_craplem(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                                           ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp) LOOP
                 IF rw_craplem.cdhistor = 91 then 
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar91 := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar91 + rw_craplem.vllanmto;
                 ELSIF rw_craplem.cdhistor = 95 then 
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar95 := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar95 + rw_craplem.vllanmto;
                 ELSE 
                   vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar441 := vr_tab_miccred_fin(vr_tab_crapris(vr_des_chave_crapris).cdfinemp).vldebpar441 + rw_craplem.vllanmto;
                 END IF;
               END LOOP;
              
               --Agupar valores microcrédito das filiadas por nível de risco
               IF vr_tab_crapris(vr_des_chave_crapris).cdfinemp IN (1,4) THEN
                 IF vr_tab_miccred_nivris.exists(vr_dsnivris) THEN
                   vr_tab_miccred_nivris(vr_dsnivris).vlslddev := vr_tab_miccred_nivris(vr_dsnivris).vlslddev + vr_vldivida;
                 ELSE
                   vr_tab_miccred_nivris(vr_dsnivris).vlslddev := vr_vldivida;
                 END IF;
               END IF;
            END IF;

            --Agrupar informações operação finame
            IF vr_tab_crapris(vr_des_chave_crapris).cdmodali = 201 THEN
              
               -- Verifica se contrato é finame
               OPEN cr_craplim(pr_nrdconta => vr_tab_crapris(vr_des_chave_crapris).nrdconta
                              ,pr_nrctremp => vr_tab_crapris(vr_des_chave_crapris).nrctremp);
               FETCH cr_craplim INTO rw_craplim;
               CLOSE cr_craplim; 
               --
               IF rw_craplim.existe_contrato_finame > 0 THEN
                  
                  IF vr_tab_crapris(vr_des_chave_crapris).dtinictr >= TRUNC(pr_rw_crapdat.dtmvtolt,'mm') AND
                     vr_tab_crapris(vr_des_chave_crapris).dtinictr <= pr_rw_crapdat.dtmvtolt THEN
                    
                    vr_tot_libctnfiname   := vr_tot_libctnfiname + vr_vldivida;
                    
         END IF;
        
                  vr_tot_prvperdafiname := vr_tot_prvperdafiname + vr_vlpreatr;
                  
                  --Agrupar valores de finame por nível de risco
                  IF vr_tab_finame_nivris.exists(vr_dsnivris) THEN
                     vr_tab_finame_nivris(vr_dsnivris).vlslddev := vr_tab_finame_nivris(vr_dsnivris).vlslddev + vr_vldivida;
                  ELSE
                     vr_tab_finame_nivris(vr_dsnivris).vlslddev := vr_vldivida;
                  END IF;
               END IF;
            END IF;
         END IF;
         --
         -- Buscar o próximo registro
         vr_des_chave_crapris := vr_tab_crapris.NEXT(vr_des_chave_crapris);
      END LOOP;

      --Gerar arquivo de operações de micro crédito e finame das filiadas
      IF (TRUNC(pr_rw_crapdat.dtmvtolt,'mm') <> TRUNC(pr_rw_crapdat.dtmvtopr,'mm')) THEN

         -- Formata a data para criar o nome do arquivo
         vr_dtmvtolt_yymmdd := to_char(pr_rw_crapdat.dtmvtolt, 'yymmdd');
      
         -- Busca do diretório onde ficará o arquivo
         vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                   pr_cdcooper => pr_cdcooper,
                                                   pr_nmsubdir => 'contab');
         
         -- Busca do diretório onde o Radar ou Matera pegará o arquivo                                          
         vr_nom_dir_copia := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                    ,pr_cdcooper => 0
                                                    ,pr_cdacesso => 'DIR_ARQ_CONTAB_X');

         --Apenas para cecred e apenas no último dia do mês
         IF pr_cdcooper = 3 THEN
           --Gera arquivo de operação de microcrédito
           pc_gera_arq_miccred(pr_dscritic);

           IF pr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
           END IF;
           --
           --Gera arquivo de operação de finame
           pc_gera_arq_finame(pr_dscritic);
          
           IF pr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
           END IF;   
         END IF; 
         --
         --Gera arquivo de compensação de microcredito
         pc_gera_arq_compe_mic(pr_dscritic);     
         --
      END IF;

      -- Agora iremos enviar o PAC 99 como totalizador das informações
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => '<agencia cdagenci="99" nmresage="TOTALIZACAO">');

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '<agencia cdagenci="99" nmresage="TOTALIZACAO">');

      -- Somente calcular o total percentual se saldo devedor > 0
      IF vr_tot_vlsdeved_geral > 0 THEN
         vr_med_percentu := (vr_tot_vlatraso_geral / vr_tot_vlsdeved_geral)*100;
      ELSE
         vr_med_percentu := NULL;
      END IF;

      -- Somente se houver valor de operação
      IF vr_tot_vlropera_geral <> 0 THEN
         vr_med_atrsinad_geral := ROUND(((vr_tot_vlatrasa_geral / vr_tot_vlropera_geral) * 100),2);
      ELSE
         vr_med_atrsinad_geral := 0;
      END IF;

      -- Somente se houver valor de operação de pessoa fisica
      IF vr_tot_vlropfis_geral <> 0 THEN
         vr_med_atindfis_geral := ROUND(((vr_tot_vlatrfis_geral / vr_tot_vlropfis_geral) * 100),2);
      ELSE
         vr_med_atindfis_geral := 0;
      END IF;

      -- Somente se houver valor de operação de pessoa juridica
      IF vr_tot_vlropjur_geral <> 0 THEN
         vr_med_atindjur_geral := ROUND(((vr_tot_vlatrjur_geral / vr_tot_vlropjur_geral) * 100),2);
      ELSE
         vr_med_atindjur_geral := 0;
      END IF;

      -- Gerar registro de totalização
      vr_des_xml_gene := '<totalizacao>'
                      || '  <qtctremp>'||to_char(vr_tot_qtctremp_geral,'fm999g990')||'</qtctremp>'
                      || '  <vlsdvatr/>'
                      || '  <vlatraso>'||to_char(vr_tot_vlatraso_geral,'fm999g999g999g990d00')||'</vlatraso>'
                      || '  <qtempres>'||to_char(vr_tot_qtempres_geral,'fm999g990')||'</qtempres>'
                      || '  <vlsdeved>'||to_char(vr_tot_vlsdeved_geral,'fm999g999g999g990d00')||'</vlsdeved>'
                      || '  <percentu>'||to_char(vr_med_percentu,'fm990d00')||'</percentu>'
                      || '  <vlpreatr>'||to_char(vr_tot_vlpreatr_geral,'fm999g999g999g990d00')||'</vlpreatr>'
                      || '  <qtctrato>'||to_char(vr_tot_qtctrato_geral,'fm999g990')||'</qtctrato>'
                      || '  <vldespes>'||to_char(vr_tot_vldespes_geral,'fm999g999g999g990d00')||'</vldespes>'
                      || '  <qtdopera>'||to_char(vr_tot_qtdopera_geral,'fm999g990')||'</qtdopera>'
                      || '  <qtdopfis>'||to_char(vr_tot_qtdopfis_geral,'fm999g990')||'</qtdopfis>'
                      || '  <qtdopjur>'||to_char(vr_tot_qtdopjur_geral,'fm999g990')||'</qtdopjur>'
                      || '  <vlropera>'||to_char(vr_tot_vlropera_geral,'fm999g999g999g990d00')||'</vlropera>'
                      || '  <vlropfis>'||to_char(vr_tot_vlropfis_geral,'fm999g999g999g990d00')||'</vlropfis>'
                      || '  <vlropjur>'||to_char(vr_tot_vlropjur_geral,'fm999g999g999g990d00')||'</vlropjur>'
                      || '  <qtatrasa>'||to_char(vr_tot_qtatrasa_geral,'fm999g990')||'</qtatrasa>'
                      || '  <qtatrfis>'||to_char(vr_tot_qtatrfis_geral,'fm999g990')||'</qtatrfis>'
                      || '  <qtatrjur>'||to_char(vr_tot_qtatrjur_geral,'fm999g990')||'</qtatrjur>'
                      || '  <vlatrasa>'||to_char(vr_tot_vlatrasa_geral,'fm999g999g999g990d00')||'</vlatrasa>'
                      || '  <vlatrfis>'||to_char(vr_tot_vlatrfis_geral,'fm999g999g999g990d00')||'</vlatrfis>'
                      || '  <vlatrjur>'||to_char(vr_tot_vlatrjur_geral,'fm999g999g999g990d00')||'</vlatrjur>'
                      || '  <atrsinad>'||to_char(nvl(vr_atrsinad,0),'fm990')||'</atrsinad>'
                      || '  <med_atrsinad>'||to_char(vr_med_atrsinad_geral,'fm999g990d00')||'%</med_atrsinad>'
                      || '  <med_atindfis>'||to_char(vr_med_atindfis_geral,'fm999g990d00')||'%</med_atindfis>'
                      || '  <med_atindjur>'||to_char(vr_med_atindjur_geral,'fm999g990d00')||'%</med_atindjur>'
                      || '  <percbase>'||to_char(vr_percbase,'fm990d00')||'</percbase>'
                      || '  <vlprejuz>'||to_char(vr_vlprejuz,'fm999g999g999g990d00')||'</vlprejuz>'
                      || '</totalizacao>';

      -- Enviar as Tags de totalização ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => vr_des_xml_gene);

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => vr_des_xml_gene);

      -- Reiniciar string genérica
      vr_des_xml_gene := '<tabriscos>';
      
      -- Para cada registro da tabela de riscos geral (Navegar somente até last-1 para não mostrar o HH)
      FOR vr_ind IN vr_tab_totrisger.FIRST..vr_tab_totrisger.LAST-1 LOOP
         -- Criar uma nova tag para o risco atual
         vr_des_xml_gene := vr_des_xml_gene
                         ||'<risco>'
                         ||' <dsdrisco>'||vr_tab_risco(vr_ind).dsdrisco||'</dsdrisco>'
                         ||' <percentu>'||to_char(vr_tab_risco(vr_ind).percentu,'fm990d00')||'</percentu>'
                         ||' <qtdabase>'||to_char(vr_tab_totrisger(vr_ind).qtdabase,'fm999g990')||'</qtdabase>'
                         ||' <vldabase>'||to_char(vr_tab_totrisger(vr_ind).vldabase,'fm999g999g999g990d00')||'</vldabase>'
                         ||' <vljrpf60>'||to_char(vr_tab_totrisger(vr_ind).vljrpf60,'fm999g999g999g990d00')||'</vljrpf60>'
                         ||' <vljrpj60>'||to_char(vr_tab_totrisger(vr_ind).vljrpj60,'fm999g999g999g990d00')||'</vljrpj60>'                         
                         ||' <vljura60>'||to_char(vr_tab_totrisger(vr_ind).vljura60,'fm999g999g999g990d00')||'</vljura60>'
                         ||' <vlprovis>'||to_char(vr_tab_totrisger(vr_ind).vlprovis,'fm999g999g999g990d00')||'</vlprovis>'
                         ||'</risco>';
      END LOOP;

      -- Fechar tag de tab de riscos
      vr_des_xml_gene := vr_des_xml_gene||'</tabriscos>';

      -- Enviar o quadro de valores por risco montado na string
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => vr_des_xml_gene);

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => vr_des_xml_gene);

      -- Zerar o totalizador geral
      vr_tab_totrisger.DELETE;

      -- Enviar o quadro "DADOS PARA CONTABILIDADE", primeiro a tag principal
      vr_des_xml_gene := '<tabcontab>';

      -- Para cada informação, efetuar a chamada que monta a tag completa
      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Financiamentos Pessoais'
                         ,pr_num_valor1 => vr_vet_contabi.rel1731_1
                         ,pr_num_valor2 => vr_vet_contabi.rel1731_1_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(1).vlfinanc_pf
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlfinanc_pf)(vr_provis)(2).vlfinanc_pf
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(1).vlfinanc_pf
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlfinanc_pf)(vr_divida)(2).vlfinanc_pf);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Financiamentos Empresas'
                         ,pr_num_valor1 => vr_vet_contabi.rel1731_2
                         ,pr_num_valor2 => vr_vet_contabi.rel1731_2_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(1).vlfinanc_pj
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlfinanc_pj)(vr_provis)(2).vlfinanc_pj
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(1).vlfinanc_pj
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlfinanc_pj)(vr_divida)(2).vlfinanc_pj);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Emprestimos Pessoais'
                         ,pr_num_valor1 => vr_vet_contabi.rel1721
                         ,pr_num_valor2 => vr_vet_contabi.rel1721_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlempres_pf)(vr_provis)(1).vlempres_pf
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlempres_pf)(vr_provis)(2).vlempres_pf
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlempres_pf)(vr_divida)(1).vlempres_pf
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlempres_pf)(vr_divida)(2).vlempres_pf);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Emprestimos Empresas'
                         ,pr_num_valor1 => vr_vet_contabi.rel1723
                         ,pr_num_valor2 => vr_vet_contabi.rel1723_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlempres_pj)(vr_provis)(1).vlempres_pj
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlempres_pj)(vr_provis)(2).vlempres_pj
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlempres_pj)(vr_divida)(1).vlempres_pj
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlempres_pj)(vr_divida)(2).vlempres_pj);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Cheques Descontados'
                         ,pr_num_valor1 => vr_vet_contabi.rel1724_c
                         ,pr_num_valor2 => vr_vet_contabi.rel1724_v_c
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlchqdes)(vr_provis)(1).vlchqdes
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlchqdes)(vr_provis)(2).vlchqdes
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlchqdes)(vr_divida)(1).vlchqdes
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlchqdes)(vr_divida)(2).vlchqdes);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Titulos Desc. C/Registro'
                         ,pr_num_valor1 => vr_vet_contabi.rel1724_cr
                         ,pr_num_valor2 => vr_vet_contabi.rel1724_v_cr
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vltitdes_cr)(vr_provis)(1).vltitdes_cr
                         ,pr_num_vlprpj => vr_tab_contab(vr_vltitdes_cr)(vr_provis)(2).vltitdes_cr
                         ,pr_num_vldvpf => vr_tab_contab(vr_vltitdes_cr)(vr_divida)(1).vltitdes_cr
                         ,pr_num_vldvpj => vr_tab_contab(vr_vltitdes_cr)(vr_divida)(2).vltitdes_cr);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Titulos Desc. S/Registro'
                         ,pr_num_valor1 => vr_vet_contabi.rel1724_sr
                         ,pr_num_valor2 => vr_vet_contabi.rel1724_v_sr
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vltitdes_sr)(vr_provis)(1).vltitdes_sr
                         ,pr_num_vlprpj => vr_tab_contab(vr_vltitdes_sr)(vr_provis)(2).vltitdes_sr
                         ,pr_num_vldvpf => vr_tab_contab(vr_vltitdes_sr)(vr_divida)(1).vltitdes_sr
                         ,pr_num_vldvpj => vr_tab_contab(vr_vltitdes_sr)(vr_divida)(2).vltitdes_sr);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Adiant.Depositante'
                         ,pr_num_valor1 => vr_vet_contabi.rel1722_0101
                         ,pr_num_valor2 => vr_vet_contabi.rel1722_0101_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vladtdep)(vr_provis)(1).vladtdep
                         ,pr_num_vlprpj => vr_tab_contab(vr_vladtdep)(vr_provis)(2).vladtdep
                         ,pr_num_vldvpf => vr_tab_contab(vr_vladtdep)(vr_divida)(1).vladtdep
                         ,pr_num_vldvpj => vr_tab_contab(vr_vladtdep)(vr_divida)(2).vladtdep);

      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Cheque Especial'
                         ,pr_num_valor1 => vr_vet_contabi.rel1722_0201
                         ,pr_num_valor2 => vr_vet_contabi.rel1722_0201_v
                         ,pr_num_vlpvpf => vr_tab_contab(vr_vlchqesp)(vr_provis)(1).vlchqesp
                         ,pr_num_vlprpj => vr_tab_contab(vr_vlchqesp)(vr_provis)(2).vlchqesp
                         ,pr_num_vldvpf => vr_tab_contab(vr_vlchqesp)(vr_divida)(1).vlchqesp
                         ,pr_num_vldvpj => vr_tab_contab(vr_vlchqesp)(vr_divida)(2).vlchqesp);

      
      -- Dados da cessao de credito
      -- Para cada informação, efetuar a chamada que monta a tag completa
      pc_cria_node_contab(pr_des_xml    => vr_des_xml_gene
                         ,pr_des_contab => 'Avais e Garantias Prestadas'
                         ,pr_num_valor1 => vr_vet_contabi.rel1760
                         ,pr_num_valor2 => vr_vet_contabi.rel1760_v
                         ,pr_num_vlpvpf => vr_tab_contab_cessao(vr_vleprces)(vr_provis)(1).vlempres_pf
                         ,pr_num_vlprpj => vr_tab_contab_cessao(vr_vleprces)(vr_provis)(2).vlempres_pj
                         ,pr_num_vldvpf => vr_tab_contab_cessao(vr_vleprces)(vr_divida)(1).vlempres_pf
                         ,pr_num_vldvpj => vr_tab_contab_cessao(vr_vleprces)(vr_divida)(2).vlempres_pj
                         ,pr_flcessao   => 1);
                         
      -- FEchar a tag de contabilização
      vr_des_xml_gene := vr_des_xml_gene || '</tabcontab>';
      
      --Abrir tag microcredito
      vr_des_xml_gene := vr_des_xml_gene || '<tabmicrocredito>';
      
      --Repete para ordem por grupo de microcredito
      FOR vr_cont in 1..2 LOOP
        vr_chave_microcredito := vr_tab_microcredito.first;
        LOOP 
          
           EXIT WHEN vr_chave_microcredito IS NULL;
           
           IF vr_tab_microcredito(vr_chave_microcredito).idgrumic = vr_cont THEN 
             pc_cria_node_miccre(pr_des_xml          => vr_des_xml_gene
                                ,pr_idgrumic         => vr_tab_microcredito(vr_chave_microcredito).idgrumic
                                ,pr_ds_microcredito  => vr_chave_microcredito
                                ,pr_vlreprec         => vr_tab_microcredito(vr_chave_microcredito).vlpesfis +
                                                        vr_tab_microcredito(vr_chave_microcredito).vlpesjur
                                ,pr_vlempatr         => vr_tab_microcredito(vr_chave_microcredito).vlate59d +
                                                        vr_tab_microcredito(vr_chave_microcredito).vlaci59d
                                ,pr_vlreprec_pf      => vr_tab_microcredito(vr_chave_microcredito).vlpesfis
                                ,pr_vlreprec_pj      => vr_tab_microcredito(vr_chave_microcredito).vlpesjur
                                ,pr_vlate59d         => vr_tab_microcredito(vr_chave_microcredito).vlate59d
                                ,pr_vlaci59d          => vr_tab_microcredito(vr_chave_microcredito).vlaci59d);     
           
           END IF;
           vr_chave_microcredito := vr_tab_microcredito.next(vr_chave_microcredito); 
          
        END LOOP; 
      END LOOP;

      vr_des_xml_gene := vr_des_xml_gene || '</tabmicrocredito>';  
      
      --Gerar quadro de recursos captados da caixa apenas no crrl227 da central
      IF pr_cdcooper = 3 THEN 
        --Abrir tag reccaixa
        vr_des_xml_gene := vr_des_xml_gene || '<tabreccaixa>';
        
        FOR rw_reccaixa in cr_crapris_reccaixa loop
          vr_des_xml_gene := vr_des_xml_gene
                            ||'<reccaixa>'
                            ||'  <nmrescop_caixa>'||rw_reccaixa.nmrescop||'</nmrescop_caixa>'
                            ||'  <nrctremp_caixa>'||rw_reccaixa.nrctremp||'</nrctremp_caixa>'
                            ||'  <dtinictr_caixa>'||to_char(rw_reccaixa.dtinictr,'dd/mm/rrrr')||'</dtinictr_caixa>'
                            ||'  <vlemprst_caixa>'||to_char(rw_reccaixa.vlemprst,'fm999g999g999g990d00')||'</vlemprst_caixa>'
                            ||'  <vlsdeved_caixa>'||to_char(rw_reccaixa.vlsdeved,'fm999g999g999g990d00')||'</vlsdeved_caixa>'
                            ||'</reccaixa>';     
        END LOOP;
      
        vr_des_xml_gene := vr_des_xml_gene || '</tabreccaixa>';   
      END IF;
      
      -- Zerar totalizadores para Limite não Utilizado (Dados para Bacen)
      vr_vldivida := 0;
      vr_vldivjur := 0;

      -- Busca dos riscos de Limite Não Utilizado 
      FOR rw_ris IN cr_ris_liminutz LOOP
         -- Verifica migração/incorporação
         IF NOT fn_verifica_conta_migracao(pr_nrdconta  => rw_ris.nrdconta) THEN
            CONTINUE;
         END IF;
        
         -- Acumular o valor conforme inpessoa
         IF rw_ris.inpessoa = 1 THEN
            vr_vldivida := vr_vldivida + rw_ris.vldivida;
         ELSE  
            vr_vldivjur := vr_vldivjur + rw_ris.vldivida;
         END IF;  
      END LOOP;

      -- Enviar o quadro "DADOS PARA BANCO CENTRAL", primeiro a tag principal
      vr_des_xml_gene := vr_des_xml_gene || '<infbacen>'
                                         ||'  <dsinform>Limite contratado e nao utilizado</dsinform>'
                                         ||'  <vldivida>'||to_char(vr_vldivida,'fm999g999g999g990d00')||'</vldivida>'
                                         ||'  <vldivjur>'||to_char(vr_vldivjur,'fm999g999g999g990d00')||'</vldivjur>'
                                         ||'</infbacen>';

      -- Enviar as Tags de contailização ao XML
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => vr_des_xml_gene);

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => vr_des_xml_gene);

      -- Fechar as tags para o PAC 99
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => '</agencia>');

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '</agencia>');

      -------- Trecho comum de criação de XML a partir do CLOB ------

      -- Para o crrl227.lst
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_227
                             ,pr_texto_completo => vr_txtauxi_227
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

      -- Para o crrl354.lst
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_354
                             ,pr_texto_completo => vr_txtauxi_354
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

      -- Para o crrl581.lst
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_581
                             ,pr_texto_completo => vr_txtauxi_581
                             ,pr_texto_novo     => '</raiz>'
                             ,pr_fecha_xml      => TRUE);

      -- Somente trabalhar com o arquivo 3 em caso de chamada pelo crps280
      IF pr_cdprogra = 'CRPS280' THEN
         -- Para o crr552.lst
         gene0002.pc_escreve_xml(pr_xml            => vr_clobxml_552
                                ,pr_texto_completo => vr_txtauxi_552
                                ,pr_texto_novo     => '</raiz>'
                                ,pr_fecha_xml      => TRUE);
      END IF;

      -- Solicitar a geração do relatório crrl581
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml_581                         --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/riscoH'                       --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl581.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl581.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 132                                  --> 132 colunas
                                 ,pr_flg_gerar => vr_flgerar                           --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_cdrelato  => 581                                  --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      dbms_lob.close(vr_clobxml_581);
      dbms_lob.freetemporary(vr_clobxml_581);

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_erro;
      END IF;

      -- Quando execução em programa diferente do crps184
      IF pr_cdprogra <> 'CRPS184' THEN
         -- Cópia do 354.lst com lógica comum, onde ocorre envio conforme o diretório parametrizado em CRRL354_COPIA.
         vr_dspathcopia := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL354_COPIA');
         -- Se tiver encontrado parâmetro
         IF vr_dspathcopia IS NOT NULL THEN
            -- Se existir o literal [dsdircop] iremos substituí-lo
            vr_dspathcopia := REPLACE(vr_dspathcopia,'[dsdircop]',pr_dsdircop);
         END IF;
      END IF;

      -- Solicitar a geração do relatório crrl354
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml_354                         --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/agencia'                      --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl354.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl354.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 132 colunas
                                 ,pr_flg_gerar => vr_flgerar                           --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 1                                    --> Número de cópias
                                 ,pr_cdrelato  => 354                                  --> Qual a seq do cabrel
                                 ,pr_dspathcop => vr_dspathcopia                       --> Diretório a copiar o LST ao termino da geração
                                 ,pr_fldoscop  => 'S'                                  --> Flag para converter o arquivo gerado em DOS antes da cópia
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      dbms_lob.close(vr_clobxml_354);
      dbms_lob.freetemporary(vr_clobxml_354);

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_erro;
      END IF;

      
      -- Solicitar a geração do relatório crrl227
      gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                                 ,pr_cdprogra  => pr_cdprogra                          --> Programa chamador
                                 ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt               --> Data do movimento atual
                                 ,pr_dsxml     => vr_clobxml_227                         --> Arquivo XML de dados
                                 ,pr_dsxmlnode => '/raiz/agencia'                      --> Nó base do XML para leitura dos dados
                                 ,pr_dsjasper  => 'crrl227.jasper'                     --> Arquivo de layout do iReport
                                 ,pr_dsparams  => null                                 --> Sem parâmetros
                                 ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl227.lst'     --> Arquivo final com o path
                                 ,pr_qtcoluna  => 234                                  --> 132 colunas
                                 ,pr_flg_gerar => vr_flgerar                           --> Geraçao na hora
                                 ,pr_flg_impri => 'S'                                  --> Chamar a impressão (Imprim.p)
                                 ,pr_nmformul  => '234dh'                              --> Nome do formulário para impressão
                                 ,pr_nrcopias  => 3                                    --> Número de cópias
                                 ,pr_cdrelato  => 227                                  --> Qual a seq do cabrel
                                 ,pr_des_erro  => pr_dscritic);                        --> Saída com erro

      dbms_lob.close(vr_clobxml_227);
      dbms_lob.freetemporary(vr_clobxml_227);

      -- Testar se houve erro
      IF pr_dscritic IS NOT NULL THEN
         -- Gerar exceção
         RAISE vr_exc_erro;
      END IF;

      -- Somente trabalhar com o arquivo 3 em caso de chamada pelo crps280
      IF pr_cdprogra = 'CRPS280' THEN

         -- Solicitar a geração do relatório crrl552
         gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
                                    ,pr_cdprogra  => pr_cdprogra                   --> Programa chamador
                                    ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt           --> Data do movimento atual
                                    ,pr_dsxml     => vr_clobxml_552                  --> Arquivo XML de dados
                                    ,pr_dsxmlnode => '/raiz/credito'               --> Nó base do XML para leitura dos dados
                                    ,pr_dsjasper  => 'crrl552.jasper'              --> Arquivo de layout do iReport
                                    ,pr_dsparams  => null                          --> Sem parâmetros
                                    ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl552.lst' --> Arquivo final com o path
                                    ,pr_qtcoluna  => 132                           --> 132 colunas
                                    ,pr_flg_gerar => vr_flgerar                    --> Geraçao na hora
                                    ,pr_flg_impri => 'S'                           --> Chamar a impressão (Imprim.p)
                                    ,pr_nmformul  => '132col'                      --> Nome do formulário para impressão
                                    ,pr_nrcopias  => 1                             --> Número de cópias
                                    ,pr_cdrelato  => 552                           --> Qual a seq do cabrel
                                    ,pr_des_erro  => pr_dscritic);                 --> Saída com erro
         dbms_lob.close(vr_clobxml_552);
         dbms_lob.freetemporary(vr_clobxml_552);

         -- Testar se houve erro
         IF pr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
         END IF;
      END IF;

      -- Quando execução em programa diferente do crps184
      IF pr_cdprogra <> 'CRPS184' THEN
  
         -- Copia do 354.TXT com lógica comum, onde ocorre envio conforme o diretório parametrizado em CRRL354_COPIA.
         vr_dspathcp_354 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL354_COPIA');
         
         -- Se tiver encontrado parâmetro
         IF vr_dspathcp_354 IS NOT NULL THEN
            -- Se existir o literal [dsdircop] iremos substituí-lo
            vr_dspathcp_354 := REPLACE(vr_dspathcp_354,'[dsdircop]',pr_dsdircop);
         END IF;
         
         -- Somente para 1 e 2 (Viacredi e Acredicoop)
         IF pr_cdcooper IN(1,2) THEN
            -- Copiar também o arquivo crrl354.txt para o diretório salvar
            vr_dspathcp_354 := vr_dspathcp_354 || ';' || vr_nom_direto||'/salvar/';
         END IF;
         
         -- Se foi encontrado algum path para export do arquivo
         IF vr_dspathcp_354 IS NOT NULL THEN
            -- Efetuar escrita final do 354.txt para gravar a varchar2 pendente no clob
            gene0002.pc_escreve_xml(pr_xml            => vr_clob_354
                                   ,pr_texto_completo => vr_txtarqui_354
                                   ,pr_texto_novo     => ''
                                   ,pr_fecha_xml      => TRUE); 
            -- Finalmente submete o arquivo pra geração
            gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper                            --> Cooperativa conectada
                                               ,pr_cdprogra  => pr_cdprogra                            --> Programa chamador
                                               ,pr_dtmvtolt  => pr_rw_crapdat.dtmvtolt                 --> Data do movimento atual
                                               ,pr_dsxml     => vr_clob_354                            --> Arquivo XML de dados
                                               ,pr_cdrelato  => '354'                                  --> Código do relatório
                                               ,pr_dsarqsaid => vr_nmdireto_354||'/'||vr_nmarquiv_354  --> Arquivo final com o path
                                               ,pr_flg_gerar => vr_flgerar                             --> Geraçao na hora
                                               ,pr_dspathcop => vr_dspathcp_354                        --> Copiar para o diretório
                                              ,pr_fldoscop  => 'S'                                    --> executar comando ux2dos
                                              ,pr_flgremarq => 'S'                                    --> Após cópia, remover arquivo de origem
                                              ,pr_des_erro  => pr_dscritic);                          --> Saída com erro
         END IF;
         
         -- Liberando a memória alocada pro CLOB
         dbms_lob.close(vr_clob_354);
         dbms_lob.freetemporary(vr_clob_354);
         
         -- Testar se houve erro
         IF pr_dscritic IS NOT NULL THEN
            -- Gerar exceção
            RAISE vr_exc_erro;
         END IF;
      END IF;

      -- Limpar as tabelas geradas no processo
      vr_tab_erro.DELETE;
      vr_tab_risco.DELETE;
      vr_tab_risco_aux.DELETE;
      vr_tab_crapris.DELETE;
      vr_tab_totrispac.DELETE;
      vr_tab_totrisger.DELETE;
      vr_tab_contab.DELETE;
      vr_tab_microcredito.DELETE;
      vr_tab_miccred_fin.DELETE;
      vr_tab_miccred_nivris.DELETE;      

   EXCEPTION
      WHEN vr_exc_erro THEN
         -- Se não foi passado o codigo da critica
         IF pr_cdcritic IS NULL THEN
            -- Utilizaremos código zero, pois foi erro não cadastrado
            pr_cdcritic := 0;
         END IF;
         -- Retornar o erro tratado
         pr_dscritic := 'Erro na rotina PC_CRPS280_I. Detalhes: '||pr_dscritic;
      WHEN OTHERS THEN
         -- Retornar o erro não tratado
         pr_cdcritic := 0;
         pr_dscritic := 'Erro não tratado na rotina PC_CRPS280_I. Detalhes: '||SQLERRM;
   END;
END PC_CRPS280_I;
