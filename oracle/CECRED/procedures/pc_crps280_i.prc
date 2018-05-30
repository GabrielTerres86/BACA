CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS280_I(pr_cdcooper   IN crapcop.cdcooper%TYPE --> Coop. conectada
                                               ,pr_rw_crapdat IN OUT btch0001.cr_crapdat%ROWTYPE --> Dados da crapdat
                                               ,pr_dtrefere   IN DATE                  --> Data de referência para o cálculo
                                               ,pr_cdprogra   IN crapprg.cdprogra%TYPE --> Codigo programa conectado
                                               ,pr_dsdircop   IN crapcop.dsdircop%TYPE --> Diretório da cooperativa
                                                ----
                                               ,pr_flgresta IN PLS_INTEGER --> Flag padrão para utilização de restart
                                               ,pr_stprogra OUT PLS_INTEGER --> Saída de termino da execução
                                               ,pr_infimsol OUT PLS_INTEGER --> Saída de termino da solicitação,
                                                ----
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
     Data    : Fevereiro/2006                  Ultima atualizacao: 20/02/2018

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
		                      Close Product Backlog Item 4403:Alteração regra no Risco da Melhora - 6 meses
							  (Daniel Junior - AMcom)


                 20/02/2018 - Paralelismo - Projeto Ligeirinho (Fabiano B. Dias - AMcom)

                 01/03/2018 - Alterado a Data do Risco e Quantidade de Dias Risco para considerar a diária
                              nos relatórios 354 e 227. (Diego Simas - AMcom)
                              
                 16/05/2018 - Retirado a parte da geração do relatório, do qual foi incluída no programa crps280_i_1
                              que será chamado pelo JOb. Neste programa foi incluída a submissão do JOB e retirado as
                              tratativas do paralelismo - Josiane Stiehler - AMcom 
  ............................................................................. */

  DECLARE
    -- Tratamento de erros
    vr_exc_erro exception;
    vr_tab_erro GENE0001.typ_tab_erro;
    -- Desvio de fluxo para ingorar o registro
    vr_exc_ignorar EXCEPTION;

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

    vr_cdcritic   pls_integer;
    vr_dscritic   varchar2(2000);

    -- Exceptions
    vr_exc_fimprg exception;
    vr_exc_saida  exception;
    -- Código do programa
    vr_cdprogra      crapprg.cdprogra%type;

    -- Índices para leitura das pl/tables ao gerar o XML
    vr_indice_dados_epr varchar2(1000);
    vr_indice_crapris   varchar2(1000);
    vr_ds_xml           tbgen_batch_relatorio_wrk.dscritic%type;
    ds_character_separador constant varchar2(1) := '#';
    --Código de controle retornado pela rotina gene0001.pc_grava_batch_controle
    vr_idcontrole tbgen_batch_controle.idcontrole%TYPE;

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

   

    -- Estrutra de PL Table para tabela CRAPTCO
      TYPE typ_tab_craptco 
        IS TABLE OF crapass.nrdconta%TYPE
          INDEX BY PLS_INTEGER;

    vr_tab_craptco typ_tab_craptco;

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
         AND ris.vldivida > 0;


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
              ,epr.cdagenci -- Ligeirinho.
            ,
             (SELECT ces.dtvencto
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



    -- Variaveis para o retorno da pc_obtem_dados_empresti
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;


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

      vr_tpemprst       VARCHAR2(10); -- Tipo de Contrato


    -- Variável para o caminho dos arquivos no rl
    vr_indice      VARCHAR2(100);

    -- Variaveis para o Cyber
      vr_txmenemp    crapepr.txmensal%TYPE;
      vr_txdjuros    craplcr.txdiaria%TYPE;
    vr_tab_diapagto NUMBER;
    vr_tab_dtcalcul DATE;
    -- Flag para desconto em folha
    vr_tab_flgfolha BOOLEAN;
    -- Configuração para mês novo
    vr_tab_ddmesnov INTEGER;

    --microcredito
    vr_cdusolcr           craplcr.cdusolcr%TYPE;
    vr_dsorgrec           craplcr.dsorgrec%TYPE;
       
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



    --Limpar todos os dados temporarios gerados por este programa.
    procedure pc_clear_memoria is
    begin
      delete from tbgen_batch_relatorio_wrk wrk
       where wrk.cdcooper = pr_cdcooper
         and wrk.cdprograma = pr_cdprogra --in ('CRPS280_I','CRPS280','CRPS516' )
         and wrk.dtmvtolt = pr_rw_crapdat.dtmvtolt;

    end pc_clear_memoria;


    procedure pc_busca_arq_controle_risco is
    begin
      -- Busca do arquivo para controle de informaçõs da central de risco
      FOR rw_crapris IN cr_crapris LOOP
        BEGIN
          -- Verifica migração/incorporação
          IF NOT
              fn_verifica_conta_migracao(pr_nrdconta => rw_crapris.nrdconta) THEN
            CONTINUE;
          END IF;

          vr_fleprces := 0;

          -- Para Emprestimos/Financiamentos
          IF rw_crapris.cdorigem = 3 THEN
            -- Para empréstimos BNDES
            IF rw_crapris.dsinfaux = 'BNDES' THEN
              -- Buscar informações da crapebn
              OPEN cr_crapebn(pr_nrdconta => rw_crapris.nrdconta,
                              pr_nrctremp => rw_crapris.nrctremp);
              FETCH cr_crapebn
                INTO vr_vlpreemp;
              -- Se encontrou
              IF cr_crapebn%FOUND THEN
                CLOSE cr_crapebn;
                vr_cdlcremp := 'BNDES';
			         	vr_tpemprst := NULL; -- paralelismo.

                IF rw_crapris.qtdiaatr > 0 THEN
                  vr_qtatraso := TRUNC(rw_crapris.qtdiaatr / 30, 0) + 1;
									vr_qtdiaatr := rw_crapris.qtdiaatr; -- paralelismo.
                ELSE
                  vr_qtatraso := 0;
									vr_qtdiaatr := 0; -- paralelismo.
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
              OPEN cr_crapepr(pr_nrdconta => rw_crapris.nrdconta,
                              pr_nrctremp => rw_crapris.nrctremp);
              FETCH cr_crapepr
                INTO rw_crapepr;
              -- Somente se encontrar
              IF cr_crapepr%FOUND THEN
                -- fechar o cursor e continuar o processo
                CLOSE cr_crapepr;

                -- Indicador se é um emprestimo de cessao
                vr_fleprces := case
                                 when rw_crapepr.dtvencto_original is null then
                                  0
                                 else
                                  1
                               end;

                -- Inicializar qtde meses decorridos com o valor da tabela
                vr_qtmesdec := rw_crapepr.qtmesdec;

                /* Efetuar correcao quantidade parcelas em atraso */

                vr_qtprecal_intei := rw_crapepr.qtprecal;

                -- Se existir data do primeiro pagamento
                IF rw_crapepr.dtdpagto IS NOT NULL THEN
                  -- Se o dia de pagamento é posterior E a data correte ainda é no mesmo mÊs
                  --   OU
                  -- Se o dia corrente e o próximo dia util são do mesmo mês e a data de pagamento venceu
                  IF (to_char(rw_crapepr.dtdpagto, 'dd') >
                     to_char(pr_rw_crapdat.dtmvtolt, 'dd') AND
                     TRUNC(rw_crapepr.dtdpagto, 'mm') =
                     TRUNC(pr_rw_crapdat.dtmvtolt, 'mm')) OR
                     (TRUNC(pr_rw_crapdat.dtmvtolt, 'mm') =
                     TRUNC(pr_rw_crapdat.dtmvtopr, 'mm') AND
                     rw_crapepr.dtdpagto > pr_rw_crapdat.dtmvtolt) THEN
                    -- Decrementar -1 mês
                    vr_qtmesdec := vr_qtmesdec - 1;
                  END IF;
                END IF;

                -- Iremos buscar a tabela de juros nas linhas de crédito
                OPEN cr_craplcr(pr_cdcooper => pr_cdcooper,
                                pr_cdlcremp => rw_crapepr.cdlcremp);
                FETCH cr_craplcr
                  INTO rw_craplcr;
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
                IF to_char(pr_rw_crapdat.dtmvtolt, 'MM') =
                   to_char(pr_rw_crapdat.dtmvtopr, 'MM') THEN
                  -- verifica o tipo do emprestimo 0-atual
                  IF rw_crapepr.tpemprst = 0 THEN
                    vr_qtprecal_decim := rw_crapepr.qtlcalat;
                  ELSE
                    /* END IF crapepr.tpemprst = 0 */
                    vr_qtprecal_decim := rw_crapepr.qtpcalat;
                  END IF;

                  -- Guardar o valor retornado para a variavel inteira
                  vr_qtprecal_intei := vr_qtprecal_decim;
                  -- Acumular aos valores de retorno (inteiro e decimal) o valor da tabela
                  vr_qtprecal_intei := vr_qtprecal_intei +
                                       rw_crapepr.qtprecal;
                  vr_qtprecal_decim := vr_qtprecal_decim +
                                       rw_crapepr.qtprecal;
                  -- Guardar o saldo devedor atual
                  vr_vlsdeved_atual := rw_crapepr.vlsdevat;

                ELSE
                  /* Mensal */
                  vr_qtprecal_intei := rw_crapepr.qtprecal;
                  vr_vlsdeved_atual := rw_crapepr.vlsdeved;
                  vr_qtprecal_decim := rw_crapepr.qtprecal;
                END IF;

                -- Buscando a configuração de empréstimo cfme a empresa da conta
                empr0001.pc_config_empresti_empresa(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                                   ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data corrente
                                                   ,pr_nrdconta => rw_crapris.nrdconta --> Numero da conta do empréstim
                                                   ,pr_dtcalcul => vr_tab_dtcalcul --> Data calculada de pagamento
                                                   ,pr_diapagto => vr_tab_diapagto --> Dia de pagamento das parcelas
                                                   ,pr_flgfolha => vr_tab_flgfolha --> Flag de desconto em folha S/N
                                                   ,pr_ddmesnov => vr_tab_ddmesnov --> Configuração para mês novo
                                                   ,pr_cdcritic => pr_cdcritic --> Código do erro
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
                vr_indice := LPAD(rw_crapepr.nrdconta, 10, '0') ||
                             LPAD(rw_crapepr.nrctremp, 10, '0');
                -- Alimentando a tabela de emprestimos
                vr_tab_dados_epr(vr_indice).cdagenci := rw_crapepr.cdagenci; -- Ligeirinho.
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
                IF rw_crapepr.tpemprst IN (1, 2) THEN
                  -- Utilizaremos o valor da tabela
                  vr_qtdiaatr := rw_crapris.qtdiaatr;
                ELSE
                  -- Calcular os dias em atraso com base nos meses decorridos
                  vr_qtdiaatr := (vr_qtmesdec - vr_qtprecal_decim) * 30;

                  IF vr_qtdiaatr <= 0 AND rw_crapepr.flgpagto = 0 THEN
                    -- Conta corrente
                    vr_qtdiaatr := pr_rw_crapdat.dtmvtolt -
                                   rw_crapepr.dtdpagto;
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
                  WHEN 0 THEN
                    vr_tpemprst := 'TR';
                  WHEN 1 THEN
                    vr_tpemprst := 'PP';
                  WHEN 2 THEN
                    vr_tpemprst := 'POS';
                  ELSE
                    vr_tpemprst := '-';
                END CASE;

                -- Para empréstimo pré-fixado ou Pos-Fixado
                IF rw_crapepr.tpemprst IN (1, 2) THEN
                  -- Número prestações recebe qtde decorrida - parcelas calculadas
                  vr_nroprest := rw_crapepr.qtmesdec - nvl(rw_crapepr.qtpcalat, 0);

                  -- Se deu negativo, considerar 0
                  IF vr_nroprest < 0 THEN
                    vr_nroprest := 0;
                  END IF;

                  -- Se houver atraso na tabela de risco
                  IF rw_crapris.qtdiaatr > 0 THEN
                    -- Calcular dividindo a quantidade de dias por 30
                    vr_qtatraso := TRUNC(rw_crapris.qtdiaatr / 30) + 1;
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
            vr_des_chave_crapris := LPAD(rw_crapris.cdagenci, 5, '0') ||
                                    to_char(999999.9999 - nvl(vr_nroprest, 0), '000000d0000') ||
                                    RPAD(rw_crapris.nmprimtl, 60, ' ') ||
                                    LPAD(rw_crapris.nrctremp, 10, '0') ||
                                    LPAD(rw_crapris.nrseqctr, 5, '0') ||
                                    LPAD(rw_crapris.nrdconta, 10, '0') ||
                                    to_char(rw_crapris.dtrefere, 'ddmmyyyy') ||
                                    LPAD(rw_crapris.innivris, 5, '0');

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
            vr_des_chave_crapris := LPAD(rw_crapris.cdagenci, 5, '0') ||
                                    to_char(999999.9999, '000000d0000') ||
                                    RPAD(rw_crapris.nmprimtl, 60, ' ') ||
                                    LPAD(rw_crapris.nrctremp, 10, '0') ||
                                    LPAD(rw_crapris.nrseqctr, 5, '0') ||
                                    LPAD(rw_crapris.nrdconta, 10, '0') ||
                                    to_char(rw_crapris.dtrefere, 'ddmmyyyy') ||
                                    LPAD(rw_crapris.innivris, 5, '0');
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
            vr_des_chave_crapris := LPAD(rw_crapris.cdagenci, 5, '0') ||
                                    to_char(999999.9999, '000000d0000') ||
                                    RPAD(rw_crapris.nmprimtl, 60, ' ') ||
                                    LPAD(rw_crapris.nrctremp, 10, '0') ||
                                    LPAD(rw_crapris.nrseqctr, 5, '0') ||
                                    LPAD(rw_crapris.nrdconta, 10, '0') ||
                                    to_char(rw_crapris.dtrefere, 'ddmmyyyy') ||
                                    LPAD(rw_crapris.innivris, 5, '0');

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
          vr_tab_crapris(vr_des_chave_crapris).vlpreemp := nvl(vr_vlpreemp, 0);
          vr_tab_crapris(vr_des_chave_crapris).cdlcremp := vr_cdlcremp;
          vr_tab_crapris(vr_des_chave_crapris).cdfinemp := vr_cdfinemp;
          vr_tab_crapris(vr_des_chave_crapris).qtatraso := vr_qtatraso;
          vr_tab_crapris(vr_des_chave_crapris).cdusolcr := vr_cdusolcr;
          vr_tab_crapris(vr_des_chave_crapris).dsorgrec := vr_dsorgrec;
          vr_tab_crapris(vr_des_chave_crapris).dtinictr := rw_crapris.dtinictr;

          IF rw_crapris.cdorigem = 1 THEN
            -- conta corrente
            vr_tab_crapris(vr_des_chave_crapris).qtdiaatr := vr_qtatraso;
          ELSE
            vr_tab_crapris(vr_des_chave_crapris).qtdiaatr := vr_qtdiaatr;
          END IF;

          vr_tab_crapris(vr_des_chave_crapris).dsinfaux := rw_crapris.dsinfaux;
          vr_tab_crapris(vr_des_chave_crapris).tpemprst := vr_tpemprst;
          vr_tab_crapris(vr_des_chave_crapris).fleprces := nvl(vr_fleprces, 0);

        EXCEPTION
          WHEN vr_exc_ignorar THEN
            -- Exceção criada apenas para desviar o fluxo
            -- para este ponto e não processar o registro
            NULL;
        END;
      END LOOP; --FOR rw_crapris IN cr_crapris LOOP --> Termino leitura dos riscos

    END pc_busca_arq_controle_risco;

    PROCEDURE pc_popular_tbgen_batch_rel_wrk(pr_cdcooper     in tbgen_batch_relatorio_wrk.cdcooper%type,
                                             pr_nmtabmemoria in tbgen_batch_relatorio_wrk.cdprograma%type,
                                             pr_dtmvtolt     in tbgen_batch_relatorio_wrk.dtmvtolt%type,
                                             pr_cdagenci     in tbgen_batch_relatorio_wrk.cdagenci%type,

                                             pr_vlindice in tbgen_batch_relatorio_wrk.dschave%type,
                                             pr_dscritic  in tbgen_batch_relatorio_wrk.dscritic%type,
                                             pr_des_erro out varchar2) is
    begin
      insert into tbgen_batch_relatorio_wrk
        (cdcooper,
         cdprograma,
         dsrelatorio,
         dtmvtolt,
         cdagenci,
         nrdconta,
         dschave,
         dscritic)
      values
        (pr_cdcooper,
         pr_cdprogra,
         pr_nmtabmemoria,
         pr_dtmvtolt,
         99999,
         9999999999,
         pr_vlindice,
         pr_dscritic);

      commit;
    EXCEPTION
      WHEN OTHERS THEN
        --Montar mensagem de erro
        pr_des_erro := 'Erro ao inserir na tabela tbgen_batch_relatorio_wrk. ' || SQLERRM;
    END pc_popular_tbgen_batch_rel_wrk;

    PROCEDURE pc_grava_tab_wrk_dados_epr(pr_des_erro out varchar2) IS
      -- VR_TAB_DADOS_EPR
    BEGIN
      vr_indice_dados_epr := vr_tab_dados_epr.first;
      while vr_indice_dados_epr is not null loop
        vr_ds_xml := ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).cdagenci || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).nrdconta || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).nrctremp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlpapgat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).flgpagto || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dtdpagto || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlsdevat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).qtpcalat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).txmensal || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).txjuremp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlppagat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).qtmdecat || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).inprejuz || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).inliquid || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).qtpreemp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).cdlcremp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).cdfinemp || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dtmvtolt || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vlemprst || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).tpdescto || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).vljurmes || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dsorgrec || ds_character_separador ||
                     vr_tab_dados_epr(vr_indice_dados_epr).dtinictr || ds_character_separador;

        pc_popular_tbgen_batch_rel_wrk(pr_cdcooper     => pr_cdcooper,
                                       pr_nmtabmemoria => 'VR_TAB_DADOS_EPR',
                                       pr_dtmvtolt     => pr_rw_crapdat.dtmvtolt,
                                       pr_cdagenci     => vr_tab_dados_epr(vr_indice_dados_epr).cdagenci,
                                       pr_vlindice     => vr_indice_dados_epr,
                                       pr_dscritic     => vr_ds_xml,
                                       pr_des_erro     => vr_dscritic);
        vr_indice_dados_epr := vr_tab_dados_epr.next(vr_indice_dados_epr);
      end loop; -- vr_tab_dados_epr
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro PC_GRAVA_TAB_WRK_DADOS_EPR: ' || sqlerrm;
        dbms_output.put_line('erro :' || sqlerrm);
    END pc_grava_tab_wrk_dados_epr;

 

    PROCEDURE pc_grava_tab_wrk_crapris(pr_des_erro out varchar2) IS
      -- VR_TAB_CRAPRIS
    BEGIN
      vr_indice_crapris := vr_tab_crapris.first;
      while vr_indice_crapris is not null loop
        vr_ds_xml := ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdagenci || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nroprest || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nmprimtl || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrdconta || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrcpfcgc || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dtrefere || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).innivris || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrctremp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdmodali || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).nrseqctr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vldivida || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vljura60 || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdorigem || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).inpessoa || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).qtdriclq || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).vlpreemp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdlcremp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdfinemp || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).qtatraso || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).cdusolcr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dsorgrec || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dtinictr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).qtdiaatr || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).dsinfaux || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).tpemprst || ds_character_separador ||
                     vr_tab_crapris(vr_indice_crapris).fleprces || ds_character_separador;

        pc_popular_tbgen_batch_rel_wrk(pr_cdcooper     => pr_cdcooper,
                                       pr_nmtabmemoria => 'VR_TAB_CRAPRIS',
                                       pr_dtmvtolt     => pr_rw_crapdat.dtmvtolt,
                                       pr_cdagenci     => vr_tab_crapris(vr_indice_crapris).cdagenci,
                                       pr_vlindice     => vr_indice_crapris,
                                       pr_dscritic     => vr_ds_xml,
                                       pr_des_erro     => vr_dscritic);
        vr_indice_crapris:= vr_tab_crapris.next(vr_indice_crapris);
      end loop; -- vr_tab_crapris
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro PC_GRAVA_TAB_WRK_CRAPRIS: ' || sqlerrm;
        dbms_output.put_line('erro :' || sqlerrm);
    END pc_grava_tab_wrk_crapris;


    -- Controla Controla log em banco de dados
    PROCEDURE pc_controla_log_programa(pr_dstiplog   IN VARCHAR2, -- Tipo de Log
                                       pr_dscritic   IN VARCHAR2  -- Descrição do Log
                                      )
    IS
      vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
      vr_tpocorrencia       tbgen_prglog_ocorrencia.tpocorrencia%type;
    BEGIN         
      IF pr_dstiplog = 'O' THEN
        vr_tpocorrencia     := 4; 
      ELSE
        vr_tpocorrencia     := 2; 
      END IF;    

      --> Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog, 
                             pr_cdprograma    => pr_cdprogra,
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 1, -- 1 batch
                             pr_tpocorrencia  => vr_tpocorrencia,
                             pr_cdcriticidade => 0, --baixa
                             pr_dsmensagem    => pr_dscritic ||
                                                         ' - pr_cdcritic: ' || pr_cdcritic ||
                                                         ' - pr_cdcooper: ' || pr_cdcooper ||
                                                         ' - pr_cdprogra: ' || pr_cdprogra,
                             pr_idprglog      => vr_idprglog);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END pc_controla_log_programa;
    
    -- Projeto Paralelismo
    PROCEDURE pc_cria_job(pr_cdcooper_prog IN  crapcop.cdcooper%TYPE
                          ,pr_qtminuto     IN  NUMBER
                          ,pr_cdcritic     OUT INTEGER
                          ,pr_dscritic     OUT VARCHAR2
                           ) IS
        vr_jobname      VARCHAR2  (100);
        vr_qtparametros PLS_INTEGER    := 1;
      BEGIN    
        pr_cdcritic := NULL;
        pr_dscritic := NULL;    
  
        vr_jobname  := 'JBRISCO_RELATO_PROVISAO_' || lpad(pr_cdcooper_prog,2,'0');
                        
        --Caso o job não possuir intervalo, significa que é um job paralelo.
        -- que será executado e destruido.
        -- para isso devemos garantir que o nome não se repita
       -- vr_jobname := dbms_scheduler.generate_job_name(vr_jobname);                  
        dbms_scheduler.create_job(job_name     => vr_jobname
                                 ,job_type     => 'STORED_PROCEDURE'
                                 ,job_action   => 'CECRED.PC_CRPS280_I_1'
                                 ,enabled      => FALSE
                                 ,number_of_arguments => 3
                                 ,start_date          => ( SYSDATE + (pr_qtminuto /1440) ) --> Horario da execução
                                 ,repeat_interval     => NULL                              --> apenas uma vez
                                  );    
        vr_qtparametros := 1; -- pr_cdcooper
        dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                            ,argument_position => vr_qtparametros
                                            ,argument_value    => anydata.ConvertNumber(pr_cdcooper_prog)
                                            );        
         
        vr_qtparametros := 2; -- pr_dtrefere
        
        dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                            ,argument_position => vr_qtparametros
                                            ,argument_value    => anydata.ConvertDate(pr_dtrefere)
                                            ); 
                                            
         vr_qtparametros := 3; -- pr_cdprogra                                    
        dbms_scheduler.set_job_anydata_value(job_name          => vr_jobname
                                            ,argument_position => vr_qtparametros
                                            ,argument_value    => anydata.ConvertVarchar2(pr_cdprogra)
                                            );      
    
        dbms_scheduler.enable(  name => vr_jobname );      
    
      EXCEPTION
        WHEN vr_exc_saida THEN
          pr_cdcritic:= vr_cdcritic;
          pr_dscritic:= vr_dscritic;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
          --Variavel de erro recebe erro ocorrido
          pr_cdcritic:= NULL;
          pr_dscritic:= sqlerrm;  
      END pc_cria_job; 

    ---------------------------------------
    -- Inicio Bloco Principal pc_crps280_I
    ---------------------------------------

  BEGIN
    vr_cdprogra:= 'CRPS280_I';
    
    -- Incluido controle de inicio de programa - Projeto Ligeirinho
    pc_controla_log_programa('I', 'Inicio da execução'); 
    
    pc_controla_log_programa('O', '01 Programa crps280_i iniciado');
    
    -- Limpar as tabelas geradas no processo
    vr_tab_erro.DELETE;
    vr_tab_risco.DELETE;
    vr_tab_risco_aux.DELETE;
    vr_tab_crapris.DELETE;
    vr_tab_contab.DELETE;

    -- Limpa os dados da tabela temporária 
    pc_clear_memoria;

    -- Inicializar pl-table
    pc_inicializa_pltable;

    -- Para os programas em paralelo devemos buscar o array crapdat.
    -- Leitura do calendário da cooperativa
    IF pr_rw_crapdat.dtmvtolt IS NULL THEN
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
        INTO pr_rw_crapdat;
      CLOSE btch0001.cr_crapdat;
    END IF;
	 
    pc_controla_log_programa('O', '02 Inicio do processo');


    -- Validações iniciais do programa
    btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 1,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se retornou algum erro
    if vr_cdcritic <> 0 then
      vr_dscritic := nvl(vr_dscritic, 'x') ||
                     'Chamou btch0001.pc_valida_iniprg.';
      raise vr_exc_saida;
    end if;

    -- Incluir nome do módulo logado
    gene0001.pc_informa_acesso(pr_module => 'PC_CRPS280_I',
                               pr_action => vr_cdprogra);



    --Preencher a pl-table com as informações dos associados.
    pc_controla_log_programa('O', '03 Inicio pc_busca_arq_controle_risco ');
    
    pc_busca_arq_controle_risco;
    
    pc_controla_log_programa('O', '04 Fim pc_busca_arq_controle_risco ');
    
    --Popular a tabela wrk, com as informações das agencias que estao na pl-table.
    pc_controla_log_programa('O', '05 inicio pc_grava_tab_wrk_dados_epr ');
    pc_grava_tab_wrk_dados_epr(vr_dscritic);
    pc_controla_log_programa('O', '06 Fnicio pc_grava_tab_wrk_dados_epr ');
    --Se retornou erro
    
   -- vr_dscritic := 'teste de erro';
    
    IF vr_dscritic IS NOT NULL THEN
       --Levantar Exceção
       RAISE vr_exc_saida;
    END IF;

    pc_controla_log_programa('O', '07 inicio pc_grava_tab_wrk_crapris ');
    pc_grava_tab_wrk_crapris(vr_dscritic);
    pc_controla_log_programa('O', '08 fim pc_grava_tab_wrk_crapris ');
    --Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Exceção
      RAISE vr_exc_saida;
    END IF;

    pc_controla_log_programa('O', '09 inicio pc_cria_job ');
      
    pc_cria_job(pr_cdcooper_prog => pr_cdcooper
               ,pr_qtminuto      => 1
               ,pr_cdcritic      => vr_cdcritic
               ,pr_dscritic      => vr_dscritic);
    --Se ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
       --Levantar Excecao
       vr_dscritic := 'pc_cria_job - '||vr_dscritic;
       RAISE vr_exc_saida;
    END IF;   

    pc_controla_log_programa('O', '10 fim pc_cria_job ');

    -- Limpar as tabelas geradas no processo
    vr_tab_erro.DELETE;
    vr_tab_risco.DELETE;
    vr_tab_risco_aux.DELETE;
    vr_tab_crapris.DELETE;
    vr_tab_contab.DELETE;
    
    
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    
    pc_controla_log_programa('F', 'Fim Execução');

    --Salvar informacoes no banco de dados
    commit;
 
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se não foi passado o codigo da critica
      IF pr_cdcritic IS NULL THEN
        -- Utilizaremos código zero, pois foi erro não cadastrado
        pr_cdcritic := 0;
      END IF;
      -- Retornar o erro tratado
         pr_dscritic := 'Erro na rotina PC_CRPS280_I. Detalhes: '||pr_dscritic;
      WHEN vr_exc_fimprg THEN

			-- Se foi retornado apenas código
			if vr_cdcritic > 0 and vr_dscritic is null then
				-- Buscar a descrição
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			end if;
			
			-- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
			btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
															 ,pr_cdprogra => vr_cdprogra
															 ,pr_infimsol => pr_infimsol
															 ,pr_stprogra => pr_stprogra);

		  pc_controla_log_programa('E', 'Erro [vr_exc_erro] '||' - '||vr_dscritic);
			-- Efetuar commit pois gravaremos o que foi processo até então
			commit;
										 
    WHEN vr_exc_saida THEN

			-- Se foi retornado apenas código
			if vr_cdcritic > 0 and vr_dscritic is null then
				-- Buscar a descrição
				vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
			end if;

			-- Devolvemos código e critica encontradas
			pr_cdcritic := nvl(vr_cdcritic,0);
			pr_dscritic := vr_dscritic;
			
      pc_controla_log_programa('E', 'Erro [vr_exc_saida] '||' - '||pr_dscritic);
      
			-- Efetuar rollback
			rollback;										 
	 WHEN OTHERS THEN
      -- Retornar o erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic ||'.Erro não tratado na rotina PC_CRPS280_I. Detalhes: ' ||SQLERRM;

      pc_controla_log_programa('E', 'Erro [others] '||' - '||pr_dscritic);
      -- Efetuar rollback
			rollback;	
  END;
END PC_CRPS280_I;
/
