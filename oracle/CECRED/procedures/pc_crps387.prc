CREATE OR REPLACE PROCEDURE CECRED.pc_crps387 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
/* .............................................................................

   Programa: pc_crps387 (Fontes/crps387.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Abril/2004                        Ultima atualizacao: 28/03/2018

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 092.
               Integrar Arquivos Debito Automatico(GENERICO)
               Emite relatorio 344.

   Alteracoes: 31/05/2004 -  Alterado tamanho campo contrato(impressao).
                             Desprezar convenios que nao pertencam a
                             cooperativa(Mirtes)

               08/06/2004 - Mover arquivos diretorio integra para diretorio
                            salvar(quando nao estiverem parametrizados na
                            tabela de convenios)(Mirtes)

               24/06/2004 - Tratamento de erro. (Ze Eduardo).

               26/07/2004 - Sequenciar pelo numero do convenio (Mirtes).

               27/07/2004 - Alterado path /usr/nexxera(Mirtes).

               29/11/2004 - Tratamento para recebimento do registro "D" (Julio)

               03/02/2005 - Acerto para atribuicao do numero do documento
                            para o craplau (Julio)

               22/02/2005 - Alterada a forma de leitura do codigo do cliente
                            no convenio (Julio)

               06/03/2005 - Tratamento para Convenio 22 (Julio)

               19/04/2005 - Tratamento para Registro "D", aceitar referencias
                            com ate 25 digitos (Julio)

               01/07/2005 - Alimentado campo cdcooper das tabelas crapndb,
                            craplot, craplau, crapavs, e do buffer crabatr
                            (Diego).

               12/07/2005 - Tratamento UNIMED Blumenau -> 509 (Julio)

               12/08/2005 - Nao tirar mais a data de cancelamento da
                            autorizacao quando um convenio enviar rejeicao de
                            cancelamento (Julio).

               23/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               03/10/2005 - Comparar valor do lancamento para verificar
                            duplicidades, so consistir se o valor for igual.
                            (Julio)

               11/10/2005 - Comparar nrseqdig para cada lancamento (Julio)

               07/11/2005 - Tratamento especial para registro duplicado da
                            UNIMED (Julio)

               16/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               20/02/2006 - Fazer importacao de registros tipo "B" para a
                            criacao da crapatr (Evandro).

               03/05/2006 - Criticar contas com numero maior que 8 digitos
                            vindas no arquivo (Julio)

               12/05/2006 - Tratamento para registros duplicados UNIMED 22
                            (Julio)

               21/06/2006 - Retirada NO-LOCK leitura craplau(erro)(Mirtes)

               22/08/2006 - Tratamento para numeros de conta, maiores do que
                            o suportado por uma variavel INTEGER (Julio)

               27/11/2006 - Apresentar relatorio de inclusoes e cancelamentos
                            quando for debito automatico (B) (Elton).

               30/03/2007 - Utilizar o historico na busca do tipo D (Evandro).

               07/05/2007 - Atualizar os registros da craplau quando for tipo
                            "D" (Evandro).

               29/05/2007 - Inclui informacoes na tabela gnarqrx quando
                            convenio requer confirmacao de recebimento do
                            arquivo enviado (registro "J") (Elton).

               26/09/2007 - Alterado para incluir "0" no numero de documento dos
                            registros duplicados mais de uma vez do convenio
                            UNIMED 22 (Elton).

               02/01/2008 - Tratamento na integracao de arquivo da uniodonto
                            quando conta nao existir na cooperativa (David).

               02/04/2008 - Incluido cdcooper e EXCLUSIVE-LOCK na transacao que
                            apaga os dados da tabela generica gncontr (Elton).

               04/06/2008 - Campo dsorigem nas leituras da craplau
                          - Campo cdcooper nas leituras da craphis (David)

               20/10/2008 - Nao permite debito de contas que estejam demitidas;
                          - Mostra no relatorio 344, critica 447 quando conta
                            estiver cancelada (Elton).

               12/11/2008 - Nao mostrar critica no log quando o motivo for
                            cancelamento de debito (Elton).

               14/11/2008 - Possibilita o cadastramento de debito quando receber
                            registro do tipo "E" e gnconve.flgindeb = TRUE
                            (Elton).

               22/12/2008 - Tratado problemas com contas transferidas (Elton).

               16/01/2009 - Alteracao CDEMPRES (Kbase).

               23/01/2009 - Preenche o campo "crapatr.nmempres" quando for
                            incluido autorizacao de debito para  convenio 586
                            (Elton).

               27/02/2009 - Corrigido tamanho do nome do arquivo (Diego).

               03/03/2009 - Recebe registros de cadastramento "B" do convenio
                            ADDMAKLER - 39 sem a necessidade da Declaracao
                            (Elton).

               14/07/2009 - incluido no for each a condiçao -
                            craplau.dsorigem <> "PG555" - Precise - Paulo.

               07/08/2009 - Nao permite incluir autorizacoes quando convenio for
                            UNIODONTO - 32 (Elton).

               17/08/2009 - Alterado para permitir inclusao de autorizacoes
                            quando convenio for UNIODONTO - 32 (Elton).

               23/09/2009 - Nao mostra no log a critica de autorizacao de debito
                            ja cadastrada;
                          - Mostra no relatorio e no log critica de lancamento
                            automatico ja existente "craplau" (Elton).

               16/10/2009 - Tratamento para convenio 38 - Unimed Planalto Norte
                            (Elton).

               03/09/2010 - Tratamento para convenio 48 - TIM Celular
                          - Se cooperado estiver com autorizacao cancelada,
                            nao limpa o campo crapatr.dtfimatr, caso o convenio
                            mande um debito e estiver com gnconve.flgindeb =
                            TRUE (Elton).

               29/03/2011 - Acerto no tratamento da Unimed - 22 (Elton).

               02/06/2011 - incluido no for each a condiçao -
                            craplau.dsorigem <> "TAA" (Evandro).

               17/06/2011 - Criticar desagendamento de debito quando debito
                            nao tiver sido agendando (Elton).

               05/07/2011 - Tratamento para registros duplicados da
                            Liberty - 55 (Elton).

               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)

               23/01/2012 - Tratar conta invalida (Guilherme/Supero)

               15/06/2012 - Substituiçao da critica 127 pela chamada da
                            procedure critica_debito_cooperativa (Lucas R.).

               19/06/2012 - Inclusao de chamada na linha 908 para a procedure
                            critica_debito_cooperativa e tratamento para
                            critica 13 (Lucas R.).

               03/07/2012 - Alterado nomeclatura do relatório gerado incluindo
                            código do convenio (Guilherme Maba).

               06/07/2012 - Substituido gncoper por crapcop (Tiago).

               20/09/2012 - Tratamento para migracao Alto Vale (Elton).

               30/11/2012 - Acerto para migracao Alto Vale (Elton).

               27/02/2013 - Na linha 2212 incluir IF aux_tpregist = "E" grava o
                            w-relato.vllanmto se nao atribui "0".
                          - Na linha 2198 incluir IF  par_flgtxtar = 1 grava o
                            crabcop.cdcooper se nao faz como antes (Lucas R.).
                          - Tratamento para codigo de referencia zerado (Elton).

               03/06/2013 - Incluido no FOR EACH,FIND FIRST e FIND a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO)

               09/09/2013 - Nova forma de chamar as agencias, de PAC agora
                            a escrita será PA (André Euzébio - Supero).

               05/11/2013 - Tratamento migracao Acredi (Elton).

               27/11/2013 - Ajustar programa para tratar o campo agencia dos
                            arquivos de debito automatico (Lucas R.)

               22/01/2014 - Incluir VALIDATE gnarqrx,gncontr,crapatr,crabatr,
                            craplot,craplau,crapndb,crapavs (Lucas R)

               23/01/2014 - Ajustes referentes ao Max.Int para nrdconta
                            (Lucas R)

               13/03/2014 - SD 103517 - Inserido o envio de criticas do processo
                            via email para cpd@cecred.coop.br,
                            convenios@cecred.coop.br (Tiago / Elton).

               14/03/2014 - Conversão Progress para PLSQL (Andrino/RKAM)

               08/05/2014 - Ajuste para tratar nrconven vindo do arquivo como numerico
                            evitando a critica 474 (Odirlei/AMcom)

               13/05/2014 - Gerar ndb com critica 96 (manutencao de conta) para as
                            concessionarias quando cdcritic = 502.
                            (Chamado 86247) - (Fabricio).

                01/04/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).

                30/05/2014 - Erros de leitura de linha devem ser gerados no arquivo
                            crps387.log e enviado por email no final do processo (Andrino-RKAM)

               23/06/2014 - SD144925 - Erros de Arquivos fora de Sequencia (Critica 476) devem
                            ser gerados no arquivo crps387.log (Vanessa Klein)

               08/08/2014 - #174235 Tratamento para cancelamento de debito automatico (Carlos)

               15/09/2014 - #193553 Aumentado p/ 3 meses a quantidade de registros armazenados
                            na gncontr, em "Eliminar Movimentos de Controle" (Carlos)

               30/09/2014 - Correcao nº da conta do relatorio de criticas. (Fabricio)

               13/10/2014 - #199162 ajustes para incorporação concredi e credimilsul (Carlos)

               30/10/2014 - Ajustar rotina para não causar a parada do processo quando ocorrer
                            erro na leitura do arquivo. ( Renato - Supero )

               12/01/2015 - Tratamento para desprezar registro no arquivo que contem o codigo
                            da cooperativa diferente da cooperativa que esta rodando no
                            momento (migracao/incorporacao - ajuste).
                            (Chamados 235642/239398) - (Fabricio)

               13/01/2015 - Alimentado mais tres campos na criacao do lau
                            (dsorigem, cdtiptra e dscedent).
                            (Chamado 229249 # PRJ Melhoria) - (Fabricio)

               24/03/2015 - Criada function fn_verifica_ult_dia e chamado
                            sempre que for inserir um registro nas tabelas
                            crapndb ou craplau (SD245218 - Tiago).

               08/04/2015 - Gerar o log do processo/integração dos arquivos no
                            crps387.log (Lucas R. #273211 )

               21/05/2015 - Remover arquivos de erro com mais de 7 dias no
                            diretorio integra e desviar logs que nao
                            afetam o processo para o proc_message.log
                            (Tiago #283886).

               03/08/2015 - Chamar a procedure pc_critica_debito_cooperativa somente
                            se o vr_tpregist for diferente de 'C' (Lucas Ranghetti #306537)

               06/08/2015 - Retirado RAISE vr_exc_saida para a critica "57" (Lucas Ranghetti #316932)

               03/09/2015 - Caso a referencia do arquivo vier zerada, devera gerar crapndb para
                            registros 'E' (Lucas Ranghetti #317736)

               15/09/2015 - Quando for cecred verificar na gncontr se ha registro para
                            outra cooperativa primeiro antes de importar senao
                            nao tomar acao nenhuma quanto a este arquivo
                            (Tiago/Fabricio #297250).

               17/09/2015 - Corrigido problemas com erros nao tratados e que
                            deixavam de enviar email para compe qdo o processo
                            de importacao nao havia ocorrido com sucesso
                            (Tiago/Fabricio #289858).

               19/10/2015 - Incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).

               26/01/2016 - Alterado local da verificacao da gncontr para cecred
                            caso uma singular nao tenha processado o arquivo ainda
                            (Lucas Ranghetti #382172 )

               28/01/2016 - Retirado regra dos 20 dias pra traz a substituido pela
                            regra "dtrefere < dtmvtolt", tambem alterado critica gerada
                            na tabela crapndb de "13" para "18" (Lucas Ranghetti #386514 )
                          - Incluir geracao da crapndb para as criticas 92,103,739,501
                            (Lucas Ranghetti #386413)

               18/02/2016 - Incluir texto nos emails enviados (Lucas Ranghetti #397491)

               26/02/2016 - Incluir validacao de NSA caso tenha mais que um arquivo para
                            processar no mesmo dia para o mesmo convenio (Lucas Ranghetti #379974 )

               26/02/2016 - Incluido temp table para guardar os cancelamentos, caso ocorra
                            um lançamento antes de ocorrer o cancelamento do registro.
                            Verifica a tabela temporária para efetuar o cancelamento e após
                            efetuar o agendamento do lançamento automático.
                            (Gisele Campos Neves - RKAM #386257 )

				       28/03/2016 - Removido o campo nrsequen tabela temporária cancelados, 
							              porque não está sendo alimentado em nenhum lugar.
                            (Gisele Campos Neves - RKAM #424908 )
                            
               03/03/2016 -  Incluido critica quando conter caracteres na Agência e no 
                             código de referência. (Gisele Campos Neves - RKAM #385689).
                             
               13/05/2016 - Retornar registro 'H' para cada regitro 'D' rejeitado (Lucas Ranghetti #420416)
               
               16/05/2016 - Adicionar validacao do campo Identificacao do Cliente junto com a
                            validacao da agencia para debito, valida caracteres especiais
                            (Lucas Ranghetti #447827)
                
				       19/05/2016 - Incluido ajuste para notificar cooperado qnd valor da fatura ultrapassar
                            limite definido PRJ320 - Oferta DebAut (Odirlei-AMcom)      
                            
               29/06/2016 - Incluir validacao de conta migrada para usa agencia = sim (Lucas Ranghetti #473220)
               
               07/07/2016 - Retirar o fechamento do cursor do crapass na criacao da critica 95, 
                            estava dando problema pois ja havia fechado (Lucas Ranghetti #478906)
                            
               03/08/2016 - Ajustes para garantir que o rw_crapatr não fique com lixo do registro
                            anterior. PRJ320 - Oferta DebAut (Odirlei-AMcom)      
                             
               30/08/2016 - Alterar data de cancelamento da autorização para gravar com a data
                            do sistema dtmvtolt (Lucas Ranghetti #493282)             
                            
               23/09/2016 - Tratar registros de vr_nro_conta_dec < 9000000000 para tratar
                            agencia(cdagectl) do debito (Lucas Ranghetti#527719)
                            
               27/09/2016 - Alterado gravacao na crapatr no campo dtiniatr para gravar
                            a data com o dia do processo (Lucas Ranghetti #506501)
                            
               04/10/2016 - Tratar registros dos convenios samae timbo e casan para
                            que caso a conta seja < 9000000000 verificar se autorizacao 
                            pertence a conta, e para o samae timbo, ignorar registros que nao 
                            sao da viacredi (Lucas Ranghetti #534110)
                            
               13/10/2016 - Alterar update na crapatr do campo dtfimatr para gravar a data do dia ao
                            inves de gravar a data de inicio da autorizacao dtiniatr (Lucas Ranghetti #532520)

               25/10/2016 - Arrumar validacao para caracteres invalidos nos campos de referencia
                            e numero da conta (Lucas Ranghetti #532367)                            
                          - Gerar critica para a cecred apenas de agencia invalida (Lucas Ranghetti #537658)
                          
               28/10/2016 - Adicionar validação para quando recebermos referencia nula
                            (Lucas Ranghetti #542656)
                            
               11/11/2016 - Incluir validação de cooperativa dentro do if da casan agencia
                            1294 (Lucas Ranghetti #551176)
                          - Incluir tratamento para não incluir crapndb para registro do tipo 'C'
                            (Lucas Ranghetti #545443)
               
                            
               28/11/2016 - Ajustes para quando rodar na Cecred tratar quase que exclusivamente apenas
                            a situacao de Agencia Invalida. (Chamados 564779/565655) - (Fabricio)
                            
               28/12/2016 - Ajustes para incorporação da Transulcred (SD585459 Tiago/Elton)             

      			   05/01/2016 - Incluido NVL para tratar agencia e conta do arquivo
			                      pois recebia NULL e as tratativas subsequentes nao
                 	      		funcionavam da forma esperada, incluido tbem tratamentos
                            de critica qdo usa agencia NAO nos convenios
                            que tem um padrao de layout diferente (Tiago/Fabricio SD571189).
                            
               19/01/2017 - Incluir tratamento em casos que o convenio enviar debitos da mesma referencia
                            para a mesma conta porém com data de pagamento ou valor diferentes
                            (Lucas Ranghetti #533520)
              
               25/01/2017 - Tratado para qdo for validar se é uma conta migrada e nao encontrar
                            verificar se é uma cooperativa migrada e criar critica de conta errada   
                            (Tiago/Fabricio SD596101)
                            
               26/01/2017 - Tratamento para criar crapndb para a critica 092 - Lancamento
                            ja existe, se estiver na cooperativa que estiver rodando.
                            (Lucas Ranghetti #589758)
                           
               27/01/2017  - Tratamento para a Unimed para cosos que precise adicionar um zero
                             final seja verificado se cooperativa que esta rodando 
                             é igual ao que iremos crirar o registro (Lucas Ranghetti #591560)
    
	             30/01/2017 - Implementado join no cursor que verifica coop migrada (Tiago/Facricio)
               
               02/03/2017 - Adicionar dtmvtopg no filtro do cursor cr_craplau_dup (Lucas Ranghetti #618379)
			   
               08/03/2017 - Ajustes para quando vier caracter especial na posicao do arquivo
                            que se refere a numero de conta criticar apenas para a cooperativa
                            correspondente (Tiago/Fabricio SD620952)

			         29/03/2017 - Para casos em que a conta for migrada e a cooperativa ainda estiver
                            ativa e convenio usar agencia vamos dar um continue e somente irá 
                            ser agendado o pagamento uma vez na cooperativa em que a conta foi 
                            migrada (Lucas Ranghetti #640199)
                            
               31/03/2017 - Ajustes para quando vier a conta > 9000000000 e usar agencia, gravar 
                            o numero da conta completo inclusive com o 900+coop a frente da conta
                            (Lucas Ranghetti #636973)
                            
			   04/04/2017 - Ajuste para integracao de arquivos com layout na versao 5
				            (Jonata - RKAM M311).

               11/04/2017 - Fechar cursor da craptco quando estiver aberto, tambem verificar
                            se estiver aberto e caso estiver, fechar (Lucas Ranghetti/Fabricio)
                            
               15/05/2017 - Incluir tratamento para validar a ultima linha do arquivo 
                            (Lucas Ranghetti #669962)

             16/05/2017 - Ajuste para alterar o format da variável vr_nrconta_cancel
				                  (Jonata - RKAM M311).
                            
               19/05/2017 - Tratamento para cooperado demitido (Lucas Ranghetti #656251)
               
               30/06/2017 - Modificado o "tail -2" para uma solucao mais dinamica e que comtempla
                            varias situações do arquivo com quebra e sem quebra de linha ao final
                            (Tiago/Fabricio #701374)
                            
               05/07/2017 - Nao vamos criar crapndb registro "F" para cada registro "B" criticado,
                            o registro "F" eh exclusivo do registro "E" (Lucas Ranghetti #706349)
                            
               06/07/2017 - Incluir tratamento para validar corretamente a versao do layout
                            (Lucas Ranghetti #707912)
                      
               02/10/2017 - Ajustar padrão de Logs
                            Ajustar padrão de Exception Others
                            Inclui nome do modulo logado
                            ( Belli - Envolti - Chamados 708424 / 758608) 
                            
               20/11/2017 - Validar consistencia da referencia para a cecred, caso ocorra erro,
                            vamos enviar e-mail para o convenios@cecred.coop.br (Lucas Ranghetti #790577)
                            
               24/01/2018 - Validar dia util para a data do pagamento, se vir sab,dom, feriado vamos
                            considerar o proximo dia util. (Lucas Ranghetti #832286)

               02/02/2018 - Ajsutar exception da referencia para gravar ndb somente para
                            a cooperativa do agendamento (Lucas Ranghetti #837177) 
                      
               28/03/2018 - Ajustar de mensagem de erro para alerta
                            Ajustar pc_trata_log 
                            ( Belli - Envolti - Chamados INC0011662 ) 
                            
............................................................................ */

    DECLARE
      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS387';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      -- Excluido vr_exc_fimprg EXCEPTION por não utilizar - 02/10/2017 - Ch 708424
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dsconteu VARCHAR2(4000);

      -- Tratamento de erros - 02/10/2017 - Chamados 708424
      vr_dscritic_in         VARCHAR2 (4000);
      -- Tratar codigos de critica - Chamado INC0011662 - 28/03/2018
      -- Excluidos controles vr_id_tipo_log_in e vr_ds_tipo_log_in
      vr_cdcritic_in         crapcri.cdcritic%TYPE;
      vr_dstiplog            VARCHAR2 (1);
      vr_tpocorre            tbgen_prglog_ocorrencia.tpocorrencia%TYPE;
      vr_cdcricid            tbgen_prglog_ocorrencia.cdcriticidade%TYPE;

      vr_dscodbar craplau.dscodbar%TYPE;
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.cdcooper
              ,cop.nmrescop
              ,cop.nmextcop
              ,cop.cdagectl
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Busca a maior agencia e a maior cooperativa
      CURSOR cr_crapcop_2 IS
        SELECT MAX(cdcooper) cdcooper,
               MAX(cdagectl) cdagectl
          FROM crapcop;

      -- Busca sobre a tabela de convenios da cooperativa
      CURSOR cr_gncvcop IS
        SELECT cdconven
          FROM gncvcop
         WHERE gncvcop.cdcooper = pr_cdcooper
         ORDER BY cdconven;

      -- Cursor sobre o cadastro de convenios
      CURSOR cr_gnconve(pr_cdconven gnconve.cdconven%TYPE) IS
        SELECT gnconve.nmempres,
               gnconve.nmarqint,
               gnconve.cdconven,
               gnconve.nrseqint,
               gnconve.cddbanco,
               gnconve.flggeraj,
               gnconve.flgagenc,
               gnconve.cdhisdeb,
               gnconve.cdcooper,
               gnconve.flgindeb,
               gnconve.flgdecla,
               gnconve.nrlayout,
               craphis.inavisar,
               craphis.cdhistor
          FROM craphis,
               crapcop,
               gnconve
         WHERE gnconve.cdconven = pr_cdconven
           AND gnconve.flgativo = 1       /* Somente convenio ativo */
           AND gnconve.cdhisdeb > 0       /* Somente arq.integracao */
           AND gnconve.nmarqint <> ' '
           AND crapcop.cdcooper = gnconve.cdcooper
           AND craphis.cdcooper = pr_cdcooper
           AND craphis.cdhistor = gnconve.cdhisdeb;

      -- Cursor sobre o cadastro de convenios
      CURSOR cr_gnconve_2 IS
        SELECT nmarqint
          FROM gnconve
         WHERE gnconve.nmarqint <> ' ';

      CURSOR cr_gncontr_gen(pr_cdconven gnconve.cdconven%TYPE
                           ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                           ,pr_nrseqarq gncontr.nrsequen%TYPE) IS
          SELECT 1
            FROM gncontr
           WHERE cdcooper <> 3
             AND cdconven = pr_cdconven
             AND dtmvtolt = pr_dtmvtolt
             AND tpdcontr = 3
             AND nrsequen = pr_nrseqarq;
        rw_gncontr_gen cr_gncontr_gen%ROWTYPE;

      -- Cursor sobre a tabela de controle de execucoes
      CURSOR cr_gncontr(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_cdconven gncontr.cdconven%TYPE,
                        pr_dtmvtolt gncontr.dtmvtolt%TYPE,
                        pr_nrseqarq gncontr.nrsequen%TYPE) IS
        SELECT flgmigra,
               nrsequen,
               ROWID
          FROM gncontr
         WHERE gncontr.cdcooper = pr_cdcooper
           AND gncontr.tpdcontr = 3            /* Integr.Arq. */
           AND gncontr.cdconven = pr_cdconven
           AND gncontr.dtmvtolt = pr_dtmvtolt
           AND gncontr.nrsequen = nvl(pr_nrseqarq, gncontr.nrsequen)
         ORDER BY progress_recid DESC;
      rw_gncontr cr_gncontr%ROWTYPE;

      -- Cursor sobre a tabela de controle de execucoes
      CURSOR cr_gncontr_1(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_cdconven gncontr.cdconven%TYPE,
                          pr_nrseqarq gncontr.nrsequen%TYPE) IS
        SELECT flgmigra,
               nrsequen,
               ROWID
          FROM gncontr
         WHERE gncontr.cdcooper = pr_cdcooper
           AND gncontr.tpdcontr = 3            /* Integr.Arq. */
           AND gncontr.cdconven = pr_cdconven
           AND gncontr.nrsequen = nvl(pr_nrseqarq, gncontr.nrsequen)
         ORDER BY progress_recid DESC;
      rw_gncontr_1 cr_gncontr_1%ROWTYPE;

      -- Cursor sobre a tabela de contas transferidas entre cooperativas
      CURSOR cr_craptco(pr_nrdconta craptco.nrdconta%TYPE) IS
        SELECT cdcooper,
               nrdconta
          FROM craptco
         WHERE craptco.cdcopant = pr_cdcooper
           AND craptco.nrctaant = pr_nrdconta
           AND craptco.tpctatrf = 1
           AND craptco.flgativo = 1;
      rw_craptco cr_craptco%ROWTYPE;

      -- Cursor conta incorporada pela cooperativa
      CURSOR cr_craptco_conta_incorporada(pr_cdcooper crapcop.cdcooper%TYPE,
                                          pr_cdcopant crapcop.cdcooper%TYPE,
                                          pr_nrdconta craptco.nrdconta%TYPE) IS
        SELECT cdcooper, nrdconta
          FROM craptco
         WHERE craptco.cdcooper = pr_cdcooper
           AND craptco.cdcopant = pr_cdcopant
           AND craptco.nrctaant = pr_nrdconta
           AND craptco.tpctatrf = 1
           AND craptco.flgativo = 1;
      rw_craptco_conta_incorporada cr_craptco%ROWTYPE;

      CURSOR cr_craptco_coop(pr_cdcooper crapcop.cdcooper%TYPE,
                             pr_cdcopant crapcop.cdcooper%TYPE) IS
        SELECT tco.cdcooper, tco.cdcopant
          FROM craptco tco, crapcop cop
         WHERE tco.cdcooper = pr_cdcooper
           AND tco.cdcopant = pr_cdcopant
           AND tco.tpctatrf = 1
           AND tco.flgativo = 1
           AND cop.cdcooper = pr_cdcopant
           AND cop.flgativo = 0;
      rw_craptco_coop cr_craptco_coop%ROWTYPE;

      -- Cursor sobre os dados do associado
      CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE,
                        pr_flgdemis INTEGER) IS -- Buscar somente quando data de demissao for nula
        SELECT cdsitdtl,
               nrdconta,
               nmprimtl,
               cdsecext,
               cdagenci,
               nrcpfcgc,
               inpessoa,
               dtdemiss
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta
           AND (pr_flgdemis = 0
            OR  crapass.dtdemiss IS NULL);
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor sobre os dados de transferencia e Duplicacao de Matricula
      CURSOR cr_craptrf(pr_cdcooper crapass.cdcooper%TYPE,
                        pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT nrsconta
          FROM craptrf
         WHERE craptrf.cdcooper = pr_cdcooper
           AND craptrf.nrdconta = pr_nrdconta
           AND craptrf.tptransa = 1  -- TIPO TRANSACAO
           AND craptrf.insittrs = 2; -- INDICADOR
      rw_craptrf cr_craptrf%ROWTYPE;

      -- Cadastro das autorizacoes de debito em conta
      CURSOR cr_crapatr(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_nrdconta crapatr.nrdconta%TYPE,
                        pr_cdhistor crapatr.cdhistor%TYPE,
                        pr_cdrefere crapatr.cdrefere%TYPE) IS
        SELECT dtfimatr,
               dtiniatr,
               nmfatura,
               ddvencto,
               nrdconta,
               flgmaxdb,
               vlrmaxdb,
               cdrefere,
               cdhistor,
               ROWID
          FROM crapatr
         WHERE crapatr.cdcooper = pr_cdcooper
           AND crapatr.nrdconta = pr_nrdconta
           AND crapatr.cdhistor = pr_cdhistor
           AND crapatr.cdrefere = pr_cdrefere;
      rw_crapatr cr_crapatr%ROWTYPE;

      -- Cadastro das autorizacoes de debito em conta
      CURSOR cr_crapatr_2(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_nrdconta crapatr.nrdconta%TYPE,
                          pr_cdhistor crapatr.cdhistor%TYPE,
                          pr_cdrefere crapatr.cdrefere%TYPE) IS
        SELECT dtfimatr,
               ROWID
          FROM crapatr
         WHERE crapatr.cdcooper = pr_cdcooper
           AND crapatr.nrdconta = pr_nrdconta
           AND crapatr.cdhistor = pr_cdhistor
           AND crapatr.cdrefere = pr_cdrefere;
      rw_crapatr_2 cr_crapatr_2%ROWTYPE;


      -- Consulta as capas de lote
      CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE,
                        pr_nrdolote craplot.nrdolote%TYPE) IS
        SELECT dtmvtolt,
               cdagenci,
               cdbccxlt,
               nrseqdig,
               cdbccxpg,
               ROWID
          FROM craplot
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = 1
           AND cdbccxlt = 100
           AND nrdolote = pr_nrdolote;
      rw_craplot cr_craplot%ROWTYPE;

      -- Busca os lancamentos automaticos
      CURSOR cr_craplau(pr_cdcooper craplau.cdcooper%TYPE,
                        pr_nrdconta craplau.nrdconta%TYPE,
                        pr_dtmvtolt craplau.dtmvtolt%TYPE,
                        pr_dtmvtopg craplau.dtmvtopg%TYPE,
                        pr_cdhistor craplau.cdhistor%TYPE,
                        pr_nrdocmto craplau.nrdocmto%TYPE) IS
        SELECT dtmvtolt,
               dtmvtopg,
               cdhistor,
               nrdconta,
               nrdocmto,
               vllanaut,
               nrseqdig,
               ROWID
          FROM craplau
         WHERE  craplau.cdcooper = pr_cdcooper
           AND  craplau.nrdconta = pr_nrdconta
           AND (craplau.dtmvtolt = nvl(pr_dtmvtolt, to_date('31122999','ddmmyyyy'))
           OR   craplau.dtmvtopg = pr_dtmvtopg)
           AND  craplau.cdhistor = pr_cdhistor
           AND  craplau.nrdocmto = pr_nrdocmto
           AND  craplau.insitlau <> 3
           AND  craplau.dsorigem <> 'CAIXA'
           AND  craplau.dsorigem <> 'INTERNET'
           AND  craplau.dsorigem <> 'TAA'
           AND  craplau.dsorigem <> 'PG555'
           AND  craplau.dsorigem <> 'CARTAOBB'
           AND  craplau.dsorigem <> 'BLOQJUD'
           AND  craplau.dsorigem <> 'DAUT BANCOOB';
      rw_craplau cr_craplau%ROWTYPE;

      -- Busca os lancamentos automaticos
      CURSOR cr_craplau_dup(pr_cdcooper craplau.cdcooper%TYPE,
                            pr_nrdconta craplau.nrdconta%TYPE,
                            pr_dtmvtolt craplau.dtmvtolt%TYPE,
                            pr_dtmvtopg craplau.dtmvtopg%TYPE,
                            pr_cdhistor craplau.cdhistor%TYPE,
                            pr_nrdocmto craplau.nrdocmto%TYPE) IS
        SELECT dtmvtolt,
               dtmvtopg,
               cdhistor,
               nrdconta,
               nrdocmto,
               vllanaut,
               nrseqdig,
               ROWID
          FROM craplau
         WHERE  craplau.cdcooper = pr_cdcooper
           AND  craplau.nrdconta = pr_nrdconta
           AND  (craplau.dtmvtolt = pr_dtmvtolt
            OR  craplau.dtmvtopg = pr_dtmvtopg)
           AND  craplau.cdhistor = pr_cdhistor
           AND  craplau.nrdocmto = pr_nrdocmto
           AND  craplau.insitlau <> 3
           AND  craplau.dsorigem <> 'CAIXA'
           AND  craplau.dsorigem <> 'INTERNET'
           AND  craplau.dsorigem <> 'TAA'
           AND  craplau.dsorigem <> 'PG555'
           AND  craplau.dsorigem <> 'CARTAOBB'
           AND  craplau.dsorigem <> 'BLOQJUD'
           AND  craplau.dsorigem <> 'DAUT BANCOOB';
      rw_craplau_dup cr_craplau_dup%ROWTYPE;

      -- Busca os lancamentos automaticos
      CURSOR cr_craplau_2(pr_cdcooper craplau.cdcooper%TYPE,
                          pr_dtmvtolt craplau.dtmvtolt%TYPE,
                          pr_cdagenci craplau.cdagenci%TYPE,
                          pr_cdbccxlt craplau.cdbccxlt%TYPE,
                          pr_nrdolote craplau.nrdolote%TYPE,
                          pr_nrdconta craplau.nrdconta%TYPE,
                          pr_nrdocmto craplau.nrdocmto%TYPE) IS
        SELECT 1
          FROM craplau
         WHERE cdcooper = pr_cdcooper
           AND dtmvtolt = pr_dtmvtolt
           AND cdagenci = pr_cdagenci
           AND cdbccxlt = pr_cdbccxlt
           AND nrdolote = pr_nrdolote
           AND nrdconta = pr_nrdconta
           AND nrdocmto = pr_nrdocmto;
      rw_craplau_2 cr_craplau_2%ROWTYPE;

      /*Busca a cooperativa pelo cdagectl*/
      CURSOR cr_cdcooper(pr_cdagectl IN crapcop.cdagectl%TYPE) IS
        SELECT crapcop.cdcooper
          FROM crapcop
         WHERE crapcop.cdagectl = pr_cdagectl;         
      rw_cdcooper cr_cdcooper%ROWTYPE;

      CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE
                       ,pr_nrdconta IN crapttl.nrdconta%TYPE
                       ,pr_nrcpfcgc IN crapttl.nrcpfcgc%TYPE) IS
      SELECT t.cdcooper
            ,t.nrdconta
            ,t.nrcpfcgc
       FROM crapttl t
      WHERE t.cdcooper = pr_cdcooper
        AND t.nrdconta = pr_nrdconta
        AND t.nrcpfcgc = pr_nrcpfcgc;
      rw_crapttl cr_crapttl%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      -- Criacao de temp/table para os dados do relatorio
      TYPE typ_reg_relato IS
        RECORD(nrdconta   NUMBER(15),
               contrato   VARCHAR2(25),
               ocorrencia VARCHAR2(40),
               dtmvtolt   craprej.dtmvtolt%TYPE,
               vllanmto   NUMBER(17,2),
               descrica   craprej.dshistor%TYPE,
               nmarquiv   VARCHAR2(100),
               nrdctabb   craprej.nrdctabb%TYPE,
               cdcritic   crapcri.cdcritic%TYPE,
               dscritic   crapcri.dscritic%TYPE,
               tpintegr   craprej .tpintegr%TYPE,
               nrdocmto   craprej.nrdocmto%TYPE,
               nmprimtl   crapass.nmprimtl%TYPE,
               operacao   BOOLEAN);
      TYPE typ_tab_relato IS
        TABLE OF typ_reg_relato
          INDEX BY VARCHAR2(52);  -- Chave: cdcritic(05), tpintegr(5), nrdconta(10), contrato(27), sequencial(05)
      -- Vetor para armazenar os dados do relatorio
      vr_tab_relato typ_tab_relato;
      -- Indice para a temp/table vr_tab_relato
      vr_ind        VARCHAR2(52);
      vr_nrseq      PLS_INTEGER := 0;

      /* Declaração de tipo para os arquivos sem restricoes de erros para serem processados */
      TYPE typ_nmarquiv IS TABLE OF VARCHAR2(300) INDEX BY PLS_INTEGER;
      vr_tab_nmarquiv typ_nmarquiv;

      /* Declaração de tipo para os erros ocorridos no processo por caracter invalido */
      TYPE typ_erro IS TABLE OF VARCHAR2(1000) INDEX BY PLS_INTEGER;
      vr_tab_erro typ_erro;

      -- Criacao de temp/table para os arquivos de debito
      TYPE typ_reg_crawarq IS
        RECORD(nmarquiv VARCHAR2(100),
               nrsequen PLS_INTEGER,
               setlinha VARCHAR2(150));
      TYPE typ_tab_crawarq IS
        TABLE OF typ_reg_crawarq
          INDEX BY VARCHAR2(106); -- Chave: nrsequen(06), nmarquiv(100)
      -- Vetor para armazenar os arquivos de debito
      vr_tab_crawarq typ_tab_crawarq;
      -- Indice para a temp/table vr_tab_crawarq
      vr_ind_arq     VARCHAR2(106);

      -- Criacao  de temp/table para os registros de debitos cancelados
      TYPE typ_reg_debcancel IS
        RECORD(setlinha VARCHAR2(150));
      TYPE typ_tab_debcancel IS
        TABLE OF typ_reg_debcancel
          INDEX BY VARCHAR2(106); -- Chave: nrsequen(06), nmarquiv(100)
      -- Vetor para armazenar os arquivos de debito
      vr_tab_debcancel typ_tab_debcancel;
      -- Indice para a temp/table vr_tab_debcancel
      vr_ind_deb     VARCHAR2(106);

      ------------------------------- VARIAVEIS -------------------------------
      -- Variaveis gerais
      vr_texto_completo VARCHAR2(32600);                              --> Variável para armazenar os dados do XML antes de incluir no CLOB
      vr_des_xml  CLOB;                                               --> XML do relatorio
      vr_nmarqimp VARCHAR2(50);                                       --> Nome do relatorio
      vr_nom_direto VARCHAR2(200);                                    --> Local onde sera gravado o relatorio
      vr_cdultcop crapcop.cdagectl%TYPE;                              --> Maior codigo de agencia
      vr_cdultage crapcop.cdcooper%TYPE;                              --> Maior codigo de cooperativa
      vr_dstextab craptab.dstextab%TYPE;                              --> Texto de parametro para a busca do numero do lote
      vr_dstextab_2 craptab.dstextab%TYPE;                            --> Texto de parametro para a busca do numero do lote
      vr_nrdolote PLS_INTEGER;                                        --> Numero do lote
      vr_nmdirdeb VARCHAR2(100);                                      --> Nome do diretorio onde sera feito a pesquisa de arquivos de debito
      vr_nmarqdeb VARCHAR2(200);                                      --> Nome com o filtro do arquivo de debitos
      vr_flg_migracao    BOOLEAN;                                     --> Flag de convenio migrado
      vr_cdcoptab crapcop.cdcooper%TYPE;                              --> Codigo da cooperativa para contas transferidas
      vr_nrseqarq gnconve.nrseqint%TYPE;                              --> Numero sequencial do arquivo de debito automatico
      vr_contador PLS_INTEGER;                                        --> Contador para arquivos consistidos
      vr_dtcancel DATE;                                               --> Data de fim (cancelamento) da autorizacao.
      vr_flgrejei BOOLEAN;                                            --> Flag de registro rejeitado
      vr_nrdbanco gnconve.cddbanco%TYPE;                              --> Identificacao do banco para Febraban
      vr_vldebito NUMBER(17,2);                                       --> Valor do debito
      vr_input_file utl_file.file_type;                               --> Variavel do arquivo
      vr_setlinha VARCHAR2(4000);                                     --> Linha do arquivo
      vr_diarefer INTEGER;                                            --> Dia de referencia
      vr_mesrefer INTEGER;                                            --> Mes de referencia
      vr_anorefer INTEGER;                                            --> Ano de referencia
      vr_dtrefere DATE;                                               --> Data de referencia
      vr_nmarquiv VARCHAR2(300);                                      --> Nome do arquivo com erro
      vr_cdconven gnarqrx.cdconven%TYPE;                              --> Codigo do convenio
      vr_nrsequen gnarqrx.nrsequen%TYPE;                              --> numero sequencial do arquivo
      vr_nrseqgen gnarqrx.nrsequen%TYPE;                              --> numero sequencial do arquivo
      vr_dtgerarq gnarqrx.dtgerarq%TYPE;                              --> Data de geracao do arquivo
      vr_nmarqcon VARCHAR2(100);                                      --> Nome do arquivo
      vr_contareg PLS_INTEGER;                                        --> Contador de registros no arquivo
      vr_tpregist VARCHAR2(01);                                       --> Tipo de registro no arquivo (A=Cabecalho, E=Corpo, Z=Rodape)
      vr_contlinh PLS_INTEGER := 0;                                   --> Contador de linhas
      vr_flg_ctamigra BOOLEAN;                                        --> Flag informando se a conta foi migrada
      vr_cdcooper crapcop.cdcooper%TYPE;                              --> Codigo da cooperativa
      vr_cdagedeb crapcop.cdagectl%TYPE;                              --> Agencia de debito
      vr_nro_conta_dec NUMBER(15);                                    --> Numero da conta existente no arquivo
      vr_nro_conta_tam VARCHAR2(14);                                  --> Numero da conta existente no arquivo no formato varchar2(14)
      vr_dsrefere VARCHAR2(25);                                       --> Registro de referencia dentro do arquivo
      vr_cdrefere crapatr.cdrefere%TYPE;                              --> Codigo de referencia do debito
      vr_nrdconta craptco.nrdconta%TYPE;                              --> Numero da conta
      vr_tpintegr PLS_INTEGER;                                        --> Codigo do tipo de integracao
      vr_cdcritic_tmp PLS_INTEGER;                                    --> Codigo de criticidade para geracao da temp-table
      vr_dstexarq_tmp VARCHAR2(02);                                   --> Variavel auxiliar para gravacao do campo dstexarq
      vr_nrcrcard_tmp craplau.nrcrcard%TYPE;                          --> Numero do cartao Credicard
      vr_dscritic_tmp VARCHAR2(200);                                  --> Descritivo do erro que sera utilizado no relatorio
      vr_nrdocmto_int craplau.nrdocmto%TYPE;                          --> Numero do documento
      vr_vllanmto NUMBER(17,2);                                       --> Valor do lancamento
      vr_flgfirst BOOLEAN;                                            --> Indicador de primeiro registro
      vr_flgfirst_lanc_a BOOLEAN;                                     --> Indicador de primeiro registro para o nó "ocorrencia"
      vr_flgfirst_lanc_b BOOLEAN;                                     --> Indicador de primeiro registro para o nó "lancamento"
      vr_nmempcon gnconve.nmempres%TYPE;                              --> Nome da empresa do convenio
      vr_cdagenci crapass.cdagenci%TYPE := 1;                         --> Codigo da agencia
      vr_cdbccxlt PLS_INTEGER := 100;                                 --> Código do banco / caixa
      vr_tplotmov PLS_INTEGER := 12;                                  --> Tipo do lote
      vr_dsmovmto VARCHAR2(03);                                       --> Descricao do movimento do erro
      vr_operacao VARCHAR2(15);                                       --> Descricao da operacao (Inclusao/Cancelamento)
      vr_dtlimite DATE;                                               --> Data limite para exclusao dos registros da gncontr
      vr_dslanmto VARCHAR2(20);                                       --> Valor do lancamento ja convertido para texto
      vr_emaildst VARCHAR2(200);                                      --> Email para os casos de critica
      vr_arqvazio BOOLEAN;                                            --> Flag de verificacao de arquivo vazio
      vr_texto_email VARCHAR2(4000);                                  --> Texto do email de erro
      vr_nrauxili NUMBER;                                             -- Variável para ler/tratar a leitura do arquivo
      vr_dtultdia DATE;                                               --> ira conter a data de ref ou prox dia util se for 31/12/2xxx
      vr_semmovto BOOLEAN;                                            --> Flag para caso nenhuma singular tenha processado
      vr_ind_debcancel VARCHAR2(1);                                   --> Indicador para validar se tem cancelamento debito em conta ou não.
      vr_nrconta_cancel NUMBER(15);                                   --> Numero da conta para registro debito em conta cacelado
      vr_dsrefere_cancel VARCHAR2(25);                                --> Registro de referencia dentro do arquivo para registro de debito em conta cancelado
      vr_nrdocmto_cancel craplau.nrdocmto%TYPE;                       --> Numero do documento para debito em conta cancelado
      vr_dtrefere_cancel DATE;                                        --> Data de referencia
      vr_inserir_lancamento  varchar2(1);                             --> Inserir Lancamento
      vr_dstexarq VARCHAR2(150);                                      --> Texto arquivo
      vr_nrdolote_sms NUMBER := NULL;                                 --> Numero de lote do SMS
      vr_nrcpfcgc crapttl.nrcpfcgc%TYPE;                              --> Número do cpf
      vr_cpfvalido BOOLEAN;                                           --> False - CPF inválido / TRUE - CPF válido
      vr_tppesssoa tbconv_det_agendamento.tppessoa_dest%TYPE;         --> Tipo de pessoa 
      vr_idlancto craplau.idlancto%TYPE;                              --> Código de indetificação do lançamento
      vr_nrdconta_relato VARCHAR2(15);                                --> Conta para exibir no relatorio
      vr_des_anexo VARCHAR2(500) := NULL;                             --> Caminho do anexo do e-mail
      vr_setlinha2 VARCHAR2(500);
      -- variaveis para utilizacao de comando no OS
      vr_comando       varchar2(200);
      vr_typ_saida2     varchar2(4);
      
      -- Variaveis totalizadoras
      vr_doc_gravado PLS_INTEGER := 0;                                --> Quantidade de documentos gravados
      vr_vlr_gravado NUMBER(17,2) := 0;                               --> Valor total gravado
      vr_doc_gravado_migrado PLS_INTEGER := 0;                        --> Quantidade de documentos migrados gravados
      vr_vlr_gravado_migrado NUMBER(17,2) := 0;                       --> Valor total gravado de documentos migrados
      vr_tot_qtregrec PLS_INTEGER := 0;                               --> Quantidade de registros recebidos
      vr_tot_qtregint PLS_INTEGER := 0;                               --> Quantidade de registros integrados
      vr_tot_qtregrej PLS_INTEGER := 0;                               --> Quantidade de registros rejeitados
      vr_tot_qtaltrec PLS_INTEGER := 0;                               --> Quantidade de alteracoes cadastrais recebidas
      vr_tot_qtaltint PLS_INTEGER := 0;                               --> Quantidade de alteracoes cadastrais integradas
      vr_tot_qtaltrej PLS_INTEGER := 0;                               --> Quantidade de alteracoes cadastrais rejeitadas
      vr_tot_qtfatrec PLS_INTEGER := 0;                               --> Quantidade de faturas recebidas
      vr_tot_qtfatint PLS_INTEGER := 0;                               --> Quantidade de faturas integradas
      vr_tot_qtfatrej PLS_INTEGER := 0;                               --> Quantidade de faturas rejeitadas
      vr_tot_vlfatrec NUMBER(17,2):= 0;                               --> Valor total de faturas recebidas
      vr_tot_vlfatint NUMBER(17,2):= 0;                               --> Valor total de faturas integradas
      vr_tot_vlfatrej NUMBER(17,2):= 0;                               --> Valor total de faturas rejeitadas
      vr_stsnrcal     BOOLEAN;                                        -->Validação de CPF/CNPJ

      --Variaveis de controle usa agencia NAO
      vr_cdagestr      VARCHAR2(4);
      vr_nrctastr      VARCHAR2(10);
      vr_nro_cta_str   VARCHAR2(15);
      vr_cdageinv      NUMBER(10);      
      vr_nrctainv      NUMBER(10);

      -- Controla Controla log
      PROCEDURE pc_trata_log( pr_dstiplog IN VARCHAR2            -- I-início/ F-fim/ O-ocorrência/ E-erro
                             ,pr_tpocorre IN NUMBER DEFAULT NULL -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensage
                             ,pr_dscritic IN VARCHAR2            -- Descrição do Log
                             ,pr_cdcritic IN tbgen_prglog_ocorrencia.cdmensagem%type    DEFAULT 0 -- Codigo da descrição do Log
                             ,pr_cdcricid IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 2 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            )
      IS
      /* .............................................................................

         Programa: pc_crps387  (fontes/crps387a.p)
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Data    : Oktober/2017                     Ultima atualizacao: 28/03/2018
         Autor   : Belli - Envolti - Chamado 708424

         Dados referentes ao programa:

         Frequencia: Disparado pela ppropria procedure.
         Objetivo  : Gerar Log centralizado.

         Alteracoes: 
               28/03/2018 - Ajustar de mensagem de erro para alerta
                            Ajustar pc_trata_log 
                            ( Belli - Envolti - Chamados INC0011662 ) 

      ............................................................................. */
        vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
      BEGIN   
        --> Controlar geração de log de execução dos jobs                                
        CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog 
                              ,pr_tpocorrencia  => pr_tpocorre
                              ,pr_cdcriticidade => pr_cdcricid
                              ,pr_cdcooper      => pr_cdcooper 
                              ,pr_dsmensagem    => pr_dscritic ||
                                                   '. pr_cdcooper:'  || pr_cdcooper ||
                                                   ', pr_flgresta:' || pr_flgresta
                              ,pr_cdmensagem    => pr_cdcritic
                              ,pr_cdprograma    => vr_cdprogra
                              ,pr_idprglog      => vr_idprglog
                              ,pr_tpexecucao    => 1 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                              );   
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
      END pc_trata_log;

      --------------------------- SUBROTINAS INTERNAS --------------------------
      FUNCTION fn_verifica_ult_dia(pr_cdcooper crapcop.cdcooper%TYPE, pr_dtrefere  IN DATE) RETURN DATE IS
      BEGIN
        DECLARE
          CURSOR cr_ultdia(pr_cdcooper crapcop.cdcooper%TYPE) IS
            SELECT TRUNC(add_months(dat.dtmvtolt,12),'RRRR')-1 AS ultimdia
              FROM crapdat dat
             WHERE dat.cdcooper = pr_cdcooper;

          rw_ultdia cr_ultdia%ROWTYPE;

          vr_dtrefere DATE;

        BEGIN
          -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.fn_verifica_ult_dia', pr_action => NULL);

          IF pr_dtrefere IS NOT NULL THEN

             OPEN cr_ultdia(pr_cdcooper => pr_cdcooper);

             FETCH cr_ultdia INTO rw_ultdia;

             IF cr_ultdia%FOUND THEN
               CLOSE cr_ultdia;

               IF pr_dtrefere = rw_ultdia.ultimdia THEN
                  rw_ultdia.ultimdia := rw_ultdia.ultimdia + 1;
                  vr_dtrefere := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper, pr_dtmvtolt => rw_ultdia.ultimdia); 
                  -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
                  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra||'.fn_verifica_ult_dia', pr_action => NULL);	
                  RETURN vr_dtrefere;
               END IF;
             ELSE
               CLOSE cr_ultdia;
               RETURN pr_dtrefere;
             END IF;
          END IF;

          RETURN pr_dtrefere;
        END;
      END fn_verifica_ult_dia;     
      
      -- Rotina para envio de criticas de email para o grupo convenios@cecred.coop.br
      PROCEDURE pc_envia_critica_email(pr_cdprogra crapprg.cdprogra%TYPE,
                                       pr_cdcooper crapcop.cdcooper%TYPE,
                                       pr_conteudo VARCHAR2,
                                       pr_nmempres VARCHAR2,
                                       pr_nmarquiv  VARCHAR2 DEFAULT NULL) IS
        vr_titemail VARCHAR2(200);
      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_envia_critica_email', pr_action => NULL);

        IF pr_nmempres IS NULL THEN
          vr_titemail := 'Critica Execucao Importacao - '||upper(pr_cdprogra);
        ELSE
          vr_titemail := 'Critica Importacao Arquivo - ' || pr_nmempres;
        END IF;
        gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                  ,pr_cdprogra        => pr_cdprogra
                                  ,pr_des_destino     => vr_emaildst
                                  ,pr_des_assunto     => vr_titemail
                                  ,pr_des_corpo       => pr_conteudo
                                  ,pr_des_anexo       => pr_nmarquiv
                                  ,pr_flg_remove_anex => 'N'
                                  ,pr_des_erro        => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018     
          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                                     
          vr_cdcritic_in := 1197;
          vr_dscritic_in := gene0001.fn_busca_critica(vr_cdcritic)||
                         ' vr_dscritic:' || vr_dscritic ||
		                     ', pr_cdcooper:'    || pr_cdcooper ||
                         ', pr_cdprogra:'    || pr_cdprogra ||
                         ', pr_des_destino:' || vr_emaildst ||
                         ', pr_des_assunto:' || vr_titemail ||
                         ', pr_des_corpo:'   || pr_conteudo ||
                         ', pr_des_anexo:'   || pr_nmarquiv ||
                         ', pr_flg_remove_anex:' || 'N';                                                       
          vr_cdcritic := NULL;
          -- Gera Log de critica MAS não para o processo
          pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                      ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                      ,pr_dscritic => vr_dscritic_in
                      ,pr_cdcritic => vr_cdcritic_in
                      ,pr_cdcricid => 1  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                      ); 
        END IF;
        -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_envia_critica_email', pr_action => NULL);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018   
          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                   
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
							           'pc_envia_critica_email. ' ||
		                     'pr_cdcooper:'      || pr_cdcooper ||
                         ', pr_cdprogra:'    || pr_cdprogra ||
                         ', pr_des_destino:' || vr_emaildst ||
                         ', pr_des_assunto:' || vr_titemail ||
                         ', pr_des_corpo:'   || pr_conteudo ||
                         ', pr_des_anexo:'   || pr_nmarquiv ||
                         ', pr_flg_remove_anex:N. '         || SQLERRM;
          RAISE vr_exc_saida;
      END pc_envia_critica_email;

      -- Rotina responsavel na inclusao de avisos de debito na tabela CRAPAVS
      PROCEDURE pc_gera_aviso_debito IS
        BEGIN
          -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
          GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_gera_aviso_debito', pr_action => NULL);

          INSERT INTO crapavs
            (cdagenci,
             cdsecext,
             cdhistor,
             nrdconta,
             nrdocmto,
             vllanmto,
             nrseqdig,
             vldebito,
             vlestdif,
             insitavs,
             flgproce,
             tpdaviso,
             dtdebito,
             cdempres,
             dtrefere,
             dtmvtolt,
             cdcooper)
           VALUES
            (rw_crapass.cdagenci,
             rw_crapass.cdsecext,
             rw_craplau.cdhistor,
             rw_craplau.nrdconta,
             rw_craplau.nrdocmto,
             rw_craplau.vllanaut,
             rw_craplau.nrseqdig,
             0,
             0,
             0,
             0,
             2,
             rw_craplau.dtmvtopg,
             0,
             rw_craplau.dtmvtolt,
             rw_craplau.dtmvtolt,
             vr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                           ||' CRAPAVS: cdagenci:'||rw_crapass.cdagenci
                           ||', cdsecext:'||rw_crapass.cdsecext||', cdhistor:'||rw_craplau.cdhistor
                           ||', nrdconta:'||rw_craplau.nrdconta||', nrdocmto:'||rw_craplau.nrdocmto
                           ||', vllanaut:'||rw_craplau.vllanaut||', nrseqdig:'||rw_craplau.nrseqdig
                           ||', vldebito:0, vlestdif:0, insitavs:0, flgproce:0, tpdaviso:2, cdempres:0'
                           ||', dtdebito:'||rw_craplau.dtmvtopg||', dtrefere:'||rw_craplau.dtmvtolt
                           ||', dtmvtolt:'||rw_craplau.dtmvtolt||', cdcooper:'||vr_cdcooper
                           ||'. '||SQLERRM;
            RAISE vr_exc_saida;

        END pc_gera_aviso_debito;

      -- Rotina responsavel na inclusao de criticas de debito na tabela CRAPNDB e no relatorio de criticas
      PROCEDURE pc_critica_debito_cooperativa(pr_flgtxtar PLS_INTEGER,
                                              pr_cdhisdeb gnconve.cdhisdeb%TYPE,
                                              pr_nmarquiv VARCHAR2) IS

        vr_par_dstextar PLS_INTEGER;
        vr_par_cdcritic PLS_INTEGER;
        vr_par_dscritic VARCHAR2(58);
        vr_dtmvtopr DATE;

      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_critica_debito_cooperativa', pr_action => NULL);

        IF vr_cdcooper IS NULL THEN
          vr_cdcooper := pr_cdcooper;
        END IF;

        IF pr_flgtxtar = 1 THEN
          vr_par_dstextar := 14;
          vr_par_cdcritic := 794; -- Cooperativa Invalida
        END IF;

        IF pr_flgtxtar = 2 THEN
          vr_par_dstextar := 15;
          vr_par_cdcritic := 127; -- conta Errada
        END IF;

        IF pr_flgtxtar = 3 THEN
          vr_par_dstextar := 18; -- Data do debito anterior a do processamento
          vr_par_cdcritic := 13; -- Data errada          
        END IF;
        
        IF pr_flgtxtar = 1 THEN
           vr_dtmvtopr := fn_verifica_ult_dia(rw_crapcop.cdcooper, rw_crapdat.dtmvtopr);
        ELSE
           vr_dtmvtopr := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
        END IF;
        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_critica_debito_cooperativa', pr_action => NULL);
        
        vr_par_dscritic := gene0001.fn_busca_critica(vr_par_cdcritic);

        -- Para cada regitro D rejeitado, retornamos o H        
        IF vr_tpregist = 'D' THEN                           
          vr_dstexarq := 'H' || SUBSTR(vr_setlinha,2,68) || RPAD(vr_par_dscritic,80) || SUBSTR(vr_setlinha,150,1);
        ELSE
          vr_dstexarq := 'F' || SUBSTR(vr_setlinha,2,66) || vr_par_dstextar || SUBSTR(vr_setlinha,70,81);
        END IF;
                       
        -- Insere no arquivo com os registros de debito em conta nao efetuados       (via febraban).
        BEGIN
          INSERT INTO crapndb
            (dtmvtolt,
             nrdconta,
             cdhistor,
             flgproce,
             dstexarq,
             cdcooper)
           VALUES
            (vr_dtmvtopr,
             vr_nrdconta,
             pr_cdhisdeb,
             0,
             vr_dstexarq,
             decode(pr_flgtxtar,1,rw_crapcop.cdcooper,vr_cdcooper));
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
            vr_cdcritic := 1034; 
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                           ||'CRAPNDB(1): dtmvtolt:'   ||vr_dtmvtopr
                           ||', nrdconta:'||vr_nrdconta||', cdhistor:'||pr_cdhisdeb
                           ||', flgproce:0, dstexarq:' ||vr_dstexarq||', flgtxtar:'||pr_flgtxtar
                           ||', cdcooper:'||rw_crapcop.cdcooper||' ou '||vr_cdcooper
                           ||'. '||SQLERRM;
            RAISE vr_exc_saida;
        END;

        -- monta a chave para a pl_table vr_tab_relato
        vr_nrseq := vr_nrseq + 1;
        vr_ind := lpad(vr_par_cdcritic,5,'0')|| '00003'|| lpad(vr_nrdconta,10,'0') ||
                  lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

        vr_tab_relato(vr_ind).nmarquiv := pr_nmarquiv;
        vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
        vr_tab_relato(vr_ind).contrato := vr_cdrefere;
        IF vr_cdcritic <> 13 THEN
          vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
        END IF;
        vr_tab_relato(vr_ind).nrdctabb := 0;
        vr_tab_relato(vr_ind).cdcritic := vr_par_cdcritic;
        vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
        IF vr_tpregist = 'E' THEN -- Corpo do arquivo
          vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
        ELSE
          vr_tab_relato(vr_ind).vllanmto := 0;
        END IF;
        vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
        vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
      EXCEPTION
        WHEN vr_exc_saida THEN 
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018   
          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                                         
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
							           'pc_critica_debito_cooperativa. '||
		                     'pr_flgtxtar:'    || pr_flgtxtar ||
                         ', pr_cdhisdeb:'  || pr_cdhisdeb ||
                         ', pr_nmarquiv:'  || pr_nmarquiv || '. '||SQLERRM;
          RAISE vr_exc_saida;
      END pc_critica_debito_cooperativa;

      -- busca os arquivos de debito para serem processados
      PROCEDURE pc_busca_arquivos_debito(pr_cdcooper  IN crapcop.cdcooper%TYPE,    -- Cooperativa
                                         pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE,    -- Data movimento
                                         pr_nmdirdeb  IN VARCHAR2,                 -- Diretorio onde sera feito a leitura
                                         pr_nmarqdeb  IN VARCHAR2,                 -- Nome do arquivo com filtro que sera feito a leitura
                                         pr_cdconven  IN gnconve.cdconven%TYPE,    -- Convenio que devera ser processado
                                         pr_nrseqarq  IN gncontr.nrsequen%TYPE,    -- Sequencia do arquivo que sera lida
                                         pr_nmempres  IN gnconve.nmempres%TYPE,    -- Nome do convenio
                                         pr_contador OUT PLS_INTEGER) IS           -- Contador de registros processados
      /* .............................................................................

         Programa: pc_crps387.pc_busca_arquivos_debito  (fontes/crps387a.p)
         Sistema : Conta-Corrente - Cooperativa de Credito
         Sigla   : CRED
         Data    : Abril/2004                     Ultima atualizacao: 28/03/2018

         Dados referentes ao programa:

         Frequencia: Diario (Batch).
         Objetivo  : Verifica se os arquivos de integracao devem ou nao serem execu-
                     tados, verificando a sequencia dos arquivos e outros parametros
                     comparando com a tabela dos convenios.

         Alteracoes: 30/11/2004 - Aplicar dos2ux para leitura dos arquivos (Julio).

                     07/12/2004 - Nao consistir nome da empresa para conveio
                                  VIVO (15). Provisorio durante o processo de
                                  migracao interna da VIVO - (Julio)

                     06/03/2005 - Numero do convenio pode ter mais de 5 digitos
                                  (Julio).

                     13/04/2006 - Nao consistir mais nome do convenio no arquivo
                                  (Julio).

                     17/06/2013 - Envio de email quando ocorrer critica 476(Jean Michel).

                     13/03/2014 - SD 103517 - Inserido o envio de criticas do processo
                                  via email para cpd@cecred.coop.br,
                                  convenios@cecred.coop.br (Tiago / Elton).

                     14/03/2014 - Conversão Progress para PLSQL (Andrino/RKAM)
                      
                     28/03/2018 - Ajustar de mensagem de erro para alerta
                                  Ajustar pc_trata_log 
                                  ( Belli - Envolti - Chamados INC0011662 ) 

      ............................................................................. */

        -- Cursores
        CURSOR cr_gnconve_2(pr_cdconven gnconve.cdconven%TYPE) IS
          SELECT nrcnvfbr,
                 nmempres,
                 nrlayout
            FROM gnconve
           WHERE cdconven = pr_cdconven;
        rw_gnconve_2 cr_gnconve_2%ROWTYPE;

        -- Variaveis gerais
        TYPE typ_arquivos IS TABLE OF VARCHAR2(1000) INDEX BY PLS_INTEGER;

        vr_tab_arquivos    typ_arquivos;          --> Tabela para receber arquivos lidos no unix
        vr_nrsequen        PLS_INTEGER;           --> Sequencial do arquivo
        vr_nrconven        gnconve.nrcnvfbr%TYPE; --> Numero do convenio conforme definido no contrato
        vr_nmarqaux        VARCHAR2(300);         --> Nome para arquivo auxiliar para geracao do nome do arquivo com erro
        vr_conteudo        VARCHAR2(1000);        --> Conteudo do email para os casos de erro
        vr_linha_arquivo   PLS_INTEGER;           --> Linha do arquivo que esta sendo lida
        --Agrupa os parametros - Chamado INC0011662 - 28/03/2018
        vr_dsparame VARCHAR2(4000);
      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_busca_arquivos_debito', pr_action => NULL);
        --Ajuste mensagem de erro Chamado INC0011662 - 28/03/2018
        vr_dsparame := ', pr_dtmvtolt:'    || pr_dtmvtolt ||
		                   ', pr_nmdirdeb:'    || pr_nmdirdeb ||
                       ', pr_nmarqdeb:'    || pr_nmarqdeb ||
		                   ', pr_cdconven:'    || pr_cdconven ||
                       ', pr_nrseqarq:'    || pr_nrseqarq ||
		                   ', pr_nmempres:'    || pr_nmempres;
        pr_contador := 0;

        /* Nao foi utilizado o gene0001.pc_lista_arquivos porque a ordem de busca dos arquivos não eh a mesma
           que a ordem existente no progress */

        --Listar arquivos no diretorio
        gene0001.pc_oscommand_shell(pr_des_comando => 'ls '||pr_nmdirdeb||'/'||pr_nmarqdeb||' > '||pr_nmdirdeb||'/crps387.tmp');

        -- Abre o arquivo contendo a lista dos arquivos de debito
        gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdirdeb          --> Diretorio do arquivo
                                ,pr_nmarquiv => 'crps387.tmp'        --> Nome do arquivo
                                ,pr_tipabert => 'R'                  --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);        --> Erro

        -- Inicializa as variaveis
        vr_linha_arquivo := 0;
        vr_tab_arquivos.delete;
        vr_tab_crawarq.delete;

        LOOP
          BEGIN
            -- Ler a linha do arquivo.
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          EXCEPTION
            WHEN OTHERS THEN
              EXIT;
          END;

          vr_linha_arquivo := nvl(vr_linha_arquivo,0) + 1;
          vr_tab_arquivos(vr_linha_arquivo) := substr(vr_setlinha,instr(vr_setlinha,'/',-1)+1);
        END LOOP;

        -- Efetua o fechamento do arquivo
        BEGIN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
            -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018  
            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                           
            vr_cdcritic := 1039;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                           ' pr_nmarquiv:'  || 'crps387.tmp'     ||
                           ', pr_tipabert:' || 'R.'              ||
                           vr_dsparame      || '. '              ||
						               SQLERRM||'.';
            --Levantar Excecao
            RAISE vr_exc_saida;
        END;

        -- Exclui o arquivo temporario
        gene0001.pc_oscommand_shell(pr_des_comando => 'rm '||pr_nmdirdeb||'/crps387.tmp');

        --Percorrer todos os arquivos
        FOR idx IN 1..vr_tab_arquivos.COUNT LOOP
          -- Move o arquivo para "arquivo.ux"
          gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||pr_nmdirdeb||'/'||vr_tab_arquivos(idx)|| ' ' ||pr_nmdirdeb||'/'||vr_tab_arquivos(idx)|| '.ux');

          -- Converte o arquivo de DOS para Unix
          gene0001.pc_oscommand_shell(pr_des_comando => 'dos2ux '||pr_nmdirdeb||'/'||vr_tab_arquivos(idx)|| '.ux > ' ||pr_nmdirdeb||'/'||vr_tab_arquivos(idx));

          -- Exclui o arquivo "arquivo.ux"
          gene0001.pc_oscommand_shell(pr_des_comando => 'rm '||pr_nmdirdeb||'/'||vr_tab_arquivos(idx)|| '.ux');

          -- Abre o arquivo
          gene0001.pc_abre_arquivo(pr_nmdireto => pr_nmdirdeb          --> Diretorio do arquivo
                                  ,pr_nmarquiv => vr_tab_arquivos(idx) --> Nome do arquivo
                                  ,pr_tipabert => 'R'                  --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_input_file        --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_dscritic);        --> Erro

          BEGIN
            -- Ler a linha do arquivo.
            gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                        ,pr_des_text => vr_setlinha); --> Texto lido
          EXCEPTION
            WHEN no_data_found THEN
              -- Fecha arquivo
              BEGIN
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                  CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                  vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                  vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                  vr_cdcritic := 1039; -- 2-Erro ao fechar arquivo
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                                 ' nmarquivo:'    || 'crps387.tmp'      ||
                                 ', pr_tipabert:' || 'R.'               ||
                                 vr_dsparame      || '. '               ||
						                     SQLERRM||'.';
                  --Levantar Excecao
                  RAISE vr_exc_saida;
              END;
              -- Envio centralizado de log de erro
              vr_cdcritic_in := 263; -- Arquivo '||vr_tab_arquivos(idx)||' vazio
              vr_dscritic_in := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic_in) ||
                                '(1). nmarquivo:' || vr_tab_arquivos(idx)||
                                ', caminho:'      || pr_nmdirdeb         ||
                                vr_dsparame;
              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
              pc_trata_log(pr_dstiplog => 'O' -- I-início; F-fim; O-ocorrência; E-erro
                          ,pr_tpocorre => 3   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_dscritic => vr_dscritic_in
                          ,pr_cdcritic => vr_cdcritic_in
                          ,pr_cdcricid => 0  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ); 
              continue; -- Volta para o inicio do loop
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
              vr_cdcritic := 1053; -- 3-Erro na leitura do arquivo
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             ' nmarquivo:' || vr_tab_arquivos(idx) ||
                             ', nmdirdeb:' || pr_nmdirdeb          ||
                             vr_dsparame   || '. '                 ||
                             SQLERRM||'.';
              RAISE vr_exc_saida;
          END;

          -- Fecha arquivo
          BEGIN
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018  
              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                           
              vr_cdcritic := 1039; -- Erro ao fechar o arquivo.
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                             ' pr_nmarquiv:'  || 'crps387.tmp'     ||
                             ', pr_tipabert:' || 'R'               ||
                             vr_dsparame      || '. '              ||
		  				               SQLERRM||'.';
              --Levantar Excecao
              RAISE vr_exc_saida;
          END;

          BEGIN
            vr_nrseqgen := SUBSTR(vr_setlinha,74,6);

            -- Popula a temp/table com os dados da primeira linha do arquivo de debito
            vr_tab_crawarq(SUBSTR(vr_setlinha,74,6)||vr_tab_arquivos(idx)).nrsequen := SUBSTR(vr_setlinha,74,6);
            vr_tab_crawarq(SUBSTR(vr_setlinha,74,6)||vr_tab_arquivos(idx)).nmarquiv := vr_tab_arquivos(idx);
            vr_tab_crawarq(SUBSTR(vr_setlinha,74,6)||vr_tab_arquivos(idx)).setlinha := SUBSTR(vr_setlinha,1,150);
          EXCEPTION
            WHEN OTHERS THEN
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
              -- Excluido pc_internal_exception, caso de erro controlado - Chamado INC0011662 - 28/03/2018
              vr_nmarqaux := vr_tab_arquivos(idx);
              vr_nmarquiv := pr_nmdirdeb||'/err' || vr_tab_arquivos(idx);
              -- Acrescenta "err" no inicio do nome do arquivo
              gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||pr_nmdirdeb||'/'||vr_tab_arquivos(idx)|| ' ' || vr_nmarquiv);              
              -- Envio centralizado de log de erro              
              vr_cdcritic := 1203; -- Problemas com header do arquivo
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) ||
                             'nmarquivo:' || vr_tab_arquivos(idx)  ||
                             ', caminho:' || pr_nmdirdeb           ||
		                         vr_dsparame  ||'. '                   ||
                             SQLERRM;

              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
              pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                          ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_dscritic => vr_dscritic
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_cdcricid => 1  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ); 
              -- Montar mensagem para enviar no e-mail
              vr_dscritic := vr_dscritic  || '<br>' ||
                             'Convenio: ' || pr_cdconven || '<br>' ||
                             'NSA: '      || vr_nrseqgen;

              pc_envia_critica_email('CRPS387A',
                                     pr_cdcooper,
                                     vr_dscritic,
                                     NULL);
              -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
              GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_busca_arquivos_debito', pr_action => NULL);
              CONTINUE;
          END;

        END LOOP;

        -- Abre os dados do convenio
        OPEN cr_gnconve_2(pr_cdconven);
        FETCH cr_gnconve_2 INTO rw_gnconve_2;
        -- Se nao encontrou convenio cancela com erro
        IF cr_gnconve_2%NOTFOUND THEN
          IF pr_cdcooper = 3 THEN
            -- Montar mensagem para enviar no e-mail
            vr_dscritic := gene0001.fn_busca_critica(566) || '<br>' ||
                           'Convenio: ' || pr_cdconven    || '<br>' ||
                           'Arquivo: '  || pr_nmarqdeb    || '<br>' ||
                           'NSA: '      || pr_nrseqarq;
            -- Envia critica por email
            pc_envia_critica_email('CRPS387A',
                                   pr_cdcooper,
                                   vr_dscritic,
                                   NULL);
            -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
            GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_busca_arquivos_debito', pr_action => NULL);
          END IF;
          -- Exclusão vr_dscritic := '' para ficar o default NULL - Chamado INC0011662 - 28/03/2018
          vr_cdcritic := 566; /* Falta Controle Convenio */
          RAISE vr_exc_saida;
        END IF;
        CLOSE cr_gnconve_2;

        vr_nrsequen := pr_nrseqarq;

        -- Vai para o primeiro registro da temp/table de arquivos
        vr_ind_arq := vr_tab_crawarq.first;

        WHILE vr_ind_arq IS NOT NULL LOOP

          /*  Verifica  somente  a  Sequencia   */
          IF vr_nrsequen = vr_tab_crawarq(vr_ind_arq).nrsequen THEN
            vr_nrconven := TRIM(SUBSTR(rw_gnconve_2.nrcnvfbr,1,10));
            vr_cdcritic := 0;

            IF SUBSTR(vr_tab_crawarq(vr_ind_arq).setlinha,1,1) <> 'A'  THEN
              vr_cdcritic := 468; -- Tipo de registro errado;
            END IF;

            IF SUBSTR(vr_tab_crawarq(vr_ind_arq).setlinha,2,1) <> 1 AND 
               vr_cdcritic = 0 THEN
              vr_cdcritic := 473; -- Codigo de remessa invalido.
            END IF;

            BEGIN
              IF TO_NUMBER(trim(SUBSTR(vr_tab_crawarq(vr_ind_arq).setlinha,3,20))) <> TO_NUMBER(vr_nrconven) AND
                 vr_cdcritic = 0 THEN
                vr_cdcritic := 474; -- Codigo e/ou numero do convenio invalido.
              END IF;
            EXCEPTION
              --tratamento para caso ocorrer erro na conversão pra number
              WHEN OTHERS THEN
                 vr_cdcritic := 474; -- Codigo e/ou numero do convenio invalido.
            END;
            -- Validar versão do arquivo
            BEGIN 
              IF (SUBSTR(vr_tab_crawarq(vr_ind_arq).setlinha,80,2) NOT IN (4,5)             OR
                 SUBSTR(vr_tab_crawarq(vr_ind_arq).setlinha,80,2) <> rw_gnconve_2.nrlayout) AND 
                 vr_cdcritic = 0 THEN
                vr_cdcritic := 477; -- Versao invalida.
              END IF;
            EXCEPTION 
              WHEN OTHERS THEN
                vr_cdcritic := 477; -- Versao invalida.
            END;   
                      
            IF SUBSTR(vr_tab_crawarq(vr_ind_arq).setlinha,82,17) <> 'DEBITO AUTOMATICO' AND 
               vr_cdcritic = 0 THEN
              vr_cdcritic := 478; -- Nao eh arquivo de debito automatico.
            END IF;

            -- Se possui criticas
            IF vr_cdcritic <> 0 THEN
              -- busca a descricao da critica
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              vr_nmarqaux := vr_tab_crawarq(vr_ind_arq).nmarquiv;
              vr_nmarquiv := pr_nmdirdeb||'/err' || vr_nmarqaux;

              -- Acrescenta "err" no inicio do nome do arquivo
              gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||pr_nmdirdeb||'/'||vr_tab_crawarq(vr_ind_arq).nmarquiv|| ' ' || vr_nmarquiv);
              
              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
              pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                          ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_dscritic => vr_dscritic ||
                                          ' pr_cdconven:'  || pr_cdconven ||
                                          ', vr_nmarqaux:' || vr_nmarqaux ||
                                          ', vr_nrsequen:' || vr_nrsequen ||
                                          vr_dsparame
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_cdcricid => 1  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ); 
              -- Montar mensagem para enviar no e-mail
              vr_dscritic := vr_dscritic  || '<br>' ||
                             'Convenio: ' || pr_cdconven || '<br>' ||
                             'Arquivo: '  || vr_nmarqaux || '<br>' ||
                             'NSA: '      || vr_nrsequen;

              -- Envio de email de critica
              pc_envia_critica_email('CRPS387A',
                                     pr_cdcooper,
                                     vr_dscritic,
                                     pr_nmempres);

              -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
              GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_busca_arquivos_debito', pr_action => NULL);
              -- Limpa as variaveis de erro
              vr_cdcritic := 0;
              vr_dscritic := NULL;

              -- Vai para o proximo registro
              vr_ind_arq := vr_tab_crawarq.next(vr_ind_arq);
              continue;
            ELSE

              vr_nrsequen := vr_nrsequen + 1;
              pr_contador := pr_contador + 1;
              vr_tab_nmarquiv(pr_contador) := vr_tab_crawarq(vr_ind_arq).nmarquiv;
            END IF;  /*  Fim  do  ELSE   */
          ELSE
            vr_cdcritic := 476; -- arquivo fora de sequencia

            -- busca a descricao da critica
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            vr_nmarqaux := vr_tab_crawarq(vr_ind_arq).nmarquiv;
            vr_nmarquiv := pr_nmdirdeb||'/err' || vr_nmarqaux;

            vr_conteudo := to_char(sysdate,'dd/mm/yyyy HH24:MI:SS') || ' - ' || vr_cdprogra || ' --> ' ||
                       vr_dscritic || ' ' || vr_nmarqaux ||
                       ' Seq. Parametrizada ' || to_char(vr_nrsequen,'000000') ||
                       ' Seq. Arquivo ' || to_char(vr_tab_crawarq(vr_ind_arq).nrsequen,'000000');

            -- Acrescenta "err" no inicio do nome do arquivo
            gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||pr_nmdirdeb||'/'||vr_tab_crawarq(vr_ind_arq).nmarquiv|| ' ' || vr_nmarquiv);
            -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
            pc_trata_log( pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                         ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                         ,pr_dscritic => vr_dscritic       || 
                                         ' vr_nmarqaux:'   || vr_nmarqaux ||
                                         ', vr_nrsequen:'  || to_char(vr_nrsequen,'000000') ||
                                         ', nrSequArquivo:'|| to_char(vr_tab_crawarq(vr_ind_arq).nrsequen,'000000')||
                                         vr_dsparame 
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_cdcricid => 1  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                         );             
            -- Limpa as variaveis de erro
            vr_cdcritic := 0;
            vr_dscritic := NULL;

            -- Enviar e-mail com o log gerado
            gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_cdprogra        => 'CRPS387A'
                                      ,pr_des_destino     => vr_emaildst
                                      ,pr_des_assunto     => 'Arquivo Fora de Sequencia - ' || rw_gnconve_2.nmempres
                                      ,pr_des_corpo       => vr_conteudo
                                      ,pr_des_anexo       => NULL
                                      ,pr_des_erro        => vr_dscritic);
            -- Verificar se houve erro ao solicitar e-mail
            IF vr_dscritic IS NOT NULL THEN
              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018     
              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                                     
              vr_cdcritic := 1197;
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                             ' vr_dscritic:'     || vr_dscritic ||
    		                     ', pr_cdcooper:'    || pr_cdcooper ||
                             ', pr_cdprogra:'    || 'CRPS387A'  ||
                             ', pr_des_destino:' || vr_emaildst ||
                             ', pr_des_assunto:' || 'Arquivo Fora de Sequencia - ' || rw_gnconve_2.nmempres ||
                             ', pr_des_corpo:'   || vr_conteudo ||
                             ', pr_des_anexo:'   || 'NULL'      ||
		                         vr_dsparame         || '. '        ||
                             SQLERRM||'.';
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
            GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra||'.pc_busca_arquivos_debito', pr_action => NULL);	  
            
          END IF;  /*  Fim do ELSE  */

          -- Vai para o proximo registro
          vr_ind_arq := vr_tab_crawarq.next(vr_ind_arq);
        END LOOP;
      EXCEPTION
        WHEN vr_exc_saida THEN 
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018   
          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                                         
          vr_cdcritic := 9999;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
							           'pc_busca_arquivos_debito' || 
		                     vr_dsparame ||'. '||SQLERRM;
          RAISE vr_exc_saida; 
      END pc_busca_arquivos_debito;

      -- Rotina responsavel na inclusao de criticas de debito Cancelados  na tabela CRAPNDB e no relatorio de criticas
      PROCEDURE pc_critica_debito_cancelado(pr_cdcooper craplau.cdcooper%TYPE,
                                            pr_nrdconta craplau.nrdconta%TYPE,
                                            pr_dtmvtolt craplau.dtmvtolt%TYPE,
                                            pr_dtmvtopg craplau.dtmvtopg%TYPE,
                                            pr_cdhistor craplau.cdhistor%TYPE,
                                            pr_nrdocmto craplau.nrdocmto%TYPE) IS


      BEGIN
        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
        GENE0001.pc_set_modulo(pr_module => 'PC_CRPS387.pc_critica_debito_cancelado', pr_action => NULL);

        BEGIN
          UPDATE craplau
             SET dtdebito = pr_dtmvtolt,
                 insitlau = 3
           WHERE craplau.cdcooper = pr_cdcooper
           AND  craplau.nrdconta = pr_nrdconta
           AND (craplau.dtmvtolt = nvl(null, to_date('31122999','ddmmyyyy'))
           OR   craplau.dtmvtopg = pr_dtmvtopg)
           AND  craplau.cdhistor = pr_cdhistor
           AND  craplau.nrdocmto = pr_nrdocmto
           AND  craplau.insitlau <> 3
           AND  craplau.dsorigem <> 'CAIXA'
           AND  craplau.dsorigem <> 'INTERNET'
           AND  craplau.dsorigem <> 'TAA'
           AND  craplau.dsorigem <> 'PG555'
           AND  craplau.dsorigem <> 'CARTAOBB'
           AND  craplau.dsorigem <> 'BLOQJUD'
           AND  craplau.dsorigem <> 'DAUT BANCOOB';
        EXCEPTION
          WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
             -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
             vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
             vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
             vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
             vr_cdcritic := 1035;   
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                            ||'CRAPLAU(1): dtdebito:'||pr_dtmvtolt
                            ||', insitlau:3 com cdcooper:'||pr_cdcooper
                            ||', nrdconta:'||pr_nrdconta||', dtmvtolt:'||pr_dtmvtopg
                            ||', cdhistor:'||pr_cdhistor||', insitlau <> 3, nrdocmto:'||pr_nrdocmto
                            ||', dsorigem <> CAIXA, INTERNET, TAA, PG555, CARTAOBB, BLOQJUD, DAUT BANCOOB.'
                            ||SQLERRM;
            RAISE vr_exc_saida;
        END;
        vr_cdcritic := 739; -- Lancamento de Debito Cancelado.

        BEGIN
          INSERT INTO crapndb
            (dtmvtolt,
             nrdconta,
             cdhistor,
             flgproce,
             dstexarq,
             cdcooper)
          VALUES
            (vr_dtultdia,
             pr_nrdconta,
             pr_cdhistor,
             0,
             'F' ||SUBSTR(vr_setlinha,2,66) || '99' || SUBSTR(vr_setlinha,70,81),
             vr_cdcooper);
        EXCEPTION
          WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
             CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
             -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
             vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
             vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
             vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
             vr_cdcritic := 1034;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                            ||'CRAPNDB(2): dtmvtolt:'   ||vr_dtultdia
                            ||', nrdconta:'||pr_nrdconta||', cdhistor:'||pr_cdhistor
                            ||', flgproce:0, dstexarq:' ||'F' ||SUBSTR(vr_setlinha,2,66) || '99' || SUBSTR(vr_setlinha,70,81)
                            ||', cdcooper:'||vr_cdcooper
                            ||'. '||SQLERRM;

            vr_cdcritic := 0;
            RAISE vr_exc_saida;
        END;

      END pc_critica_debito_cancelado;

    ----------------------------- INICIO DA ROTINA PRINCIPAL -----------------------------
    BEGIN

      --------------- VALIDACOES INICIAIS -----------------

      -- Incluir nome do módulo logado
      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                ,pr_action => null);
      -- Incluido controle de Log inicio programa - Chamado INC0011662 - 28/03/2018
      pc_trata_log( pr_dstiplog => 'I'
                   ,pr_tpocorre => NULL
                   ,pr_dscritic => NULL
                   ,pr_cdcritic => NULL
                   ,pr_cdcricid => NULL
                  ); 

      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop;
      FETCH cr_crapcop
       INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica - Chamado INC0011662 - 28/03/2018
        vr_tpocorre := 1;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
        vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
        vr_cdcricid := 1;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica  
        vr_cdcritic := 651; 
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      -- Leitura do calendário da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat
      INTO rw_crapdat;

      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica - Chamado INC0011662 - 28/03/2018
        vr_tpocorre := 1;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
        vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
        vr_cdcricid := 1;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica  
        vr_cdcritic := 1;
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
        -- Montar mensagem de critica - Chamado INC0011662 - 28/03/2018
        vr_tpocorre := 1;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
        vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
        vr_cdcricid := 1;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica  
        RAISE vr_exc_saida;
      END IF;

      --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------

      -- Busca do diretorio base da cooperativa
      vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'rl'); --> Utilizaremos o rl

      -- Busca o maior codigo de cooperativa e o maior codigo de agencia
      OPEN cr_crapcop_2;
      FETCH cr_crapcop_2 INTO vr_cdultcop, vr_cdultage;
      CLOSE cr_crapcop_2;

      -- Busca o endereco de email para os casos de criticas
      vr_emaildst := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS387_EMAIL');

      -- Busca o numero do lote
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 00
                                               ,pr_cdacesso => 'LOTEINT031'
                                               ,pr_tpregist => 001);

      -- Verifica se nao encontrou o numero do lote
      IF vr_dstextab IS NULL THEN
        -- Montar mensagem de critica - Chamado INC0011662 - 28/03/2018
        vr_tpocorre := 1;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
        vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
        vr_cdcricid := 1;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica  
        vr_cdcritic := 512;  -- Falta tabela de numero de lote para integracao de convenio.

        -- Envia critica por email
        pc_envia_critica_email('CRPS387',
                               pr_cdcooper,
                               gene0001.fn_busca_critica(vr_cdcritic),
                               NULL);

        -- Retornar nome do módulo logado - Chamado INC0011662 - 28/03/2018
        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => null);
        RAISE vr_exc_saida;
      END IF;
      -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

      vr_nrdolote := vr_dstextab;

      --Movida busca do diretório para fora do loop - Chamado 758606
      -- Busca do diretorio base da cooperativa
      vr_nmdirdeb  := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'integra'); --> Utilizaremos o integra

      -- Loop sobre a tabela de convenios da cooperativa
      FOR rw_gncvcop IN cr_gncvcop LOOP

        -- Loop sobre o cadastro de convenios
        FOR rw_gnconve IN cr_gnconve(rw_gncvcop.cdconven) LOOP
        BEGIN
          -- Limpa a temp_table do relatorio
          vr_tab_relato.delete;
          -- Envio centralizado de log de erro
          vr_cdcritic_in := 1201;
          vr_dscritic_in := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic_in) ||
                            ' - Integracao Arquivo Convenio:'||to_char(rw_gncvcop.cdconven,'fm9990') ||
                            ' - ' || rw_gnconve.nmempres;
          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
          pc_trata_log(pr_dstiplog => 'O' -- I-início; F-fim; O-ocorrência; E-erro
                      ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                      ,pr_dscritic => vr_dscritic_in
                      ,pr_cdcritic => vr_cdcritic_in
                      ,pr_cdcricid => 0  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                      );        

          vr_nmarqdeb     := TRIM(rw_gnconve.nmarqint) || '*';
          vr_flg_migracao := FALSE;
          vr_cdcoptab     := 0;
          vr_semmovto     := FALSE;

          -- Se o arquivo for de debito, muda o nome do arquivo para o filtro
          IF  rw_gnconve.nmarqint = 'Deb' THEN
             vr_nmarqdeb := 'Deb%.rem';
          END IF;

          /*------Verificar sequencia  - Atualizar sequencia ---*/
          IF cr_gncontr%ISOPEN THEN
            CLOSE cr_gncontr;
          END IF;
          OPEN cr_gncontr(pr_cdcooper, rw_gnconve.cdconven, rw_crapdat.dtmvtolt, NULL);
          FETCH cr_gncontr INTO rw_gncontr;

          -- Se nao encontrar a sequencia
          IF cr_gncontr%NOTFOUND THEN
             vr_nrseqarq := rw_gnconve.nrseqint;
          ELSE
            -- se for um contrato migrado
            IF rw_gncontr.flgmigra = 1 THEN
              vr_nrseqarq := rw_gnconve.nrseqint;
            ELSE
              vr_nrseqarq := rw_gncontr.nrsequen + 1;
            END IF;
          END IF;
          CLOSE cr_gncontr;

          -- Efetua a busca dos arquivos de debito e a consistencia da linha inicial
          pc_busca_arquivos_debito(pr_cdcooper,
                                   rw_crapdat.dtmvtolt,
                                   vr_nmdirdeb,
                                   vr_nmarqdeb,
                                   rw_gnconve.cdconven, /* Passar convenio */
                                   vr_nrseqarq,
                                   rw_gnconve.nmempres,
                                   vr_contador);

          -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
          GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

          /* Data de cancelamento da autorizacao */
          vr_dtcancel := rw_crapdat.dtmvtolt;
          vr_nrseqarq := vr_nrseqarq - 1; /* p/incrementar Seq.  */

          -- Loop de leitura de todos os arquivos
          FOR i IN 1..nvl(vr_contador,0) LOOP

            -- Inicializa as variaveis
            vr_doc_gravado  := 0;
            vr_vlr_gravado  := 0;
            vr_tot_qtregrec := 0;
            vr_tot_qtregint := 0;
            vr_tot_qtregrej := 0;
            vr_tot_qtaltrec := 0;
            vr_tot_qtaltint := 0;
            vr_tot_qtaltrej := 0;
            vr_tot_qtfatrec := 0;
            vr_tot_qtfatint := 0;
            vr_tot_qtfatrej := 0;
            vr_tot_vlfatrec := 0;
            vr_tot_vlfatint := 0;
            vr_tot_vlfatrej := 0;
            vr_doc_gravado_migrado := 0;
            vr_vlr_gravado_migrado := 0;

            vr_nrseqarq := vr_nrseqarq + 1;  /* Incrementar Seq. */
            vr_cdcritic := 0;
            vr_flgrejei := FALSE;
            vr_nrdbanco := rw_gnconve.cddbanco;
            vr_vldebito := 0;

            -- Abre o arquivo
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirdeb                    --> Diretorio do arquivo
                                    ,pr_nmarquiv => vr_tab_nmarquiv(i)             --> Nome do arquivo
                                    ,pr_tipabert => 'R'                            --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_input_file                  --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic);                  --> Erro

            BEGIN
              -- Ler a linha do arquivo.
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto lido
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                -- Ajuste mensagem - 15/03/2018 - Chamado 801483 
                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                 
                vr_cdcritic := 1053;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               '(1) pr_nmdireto:'||vr_nmdirdeb ||
                               ', pr_nmarquiv:'  ||vr_tab_nmarquiv(i) ||
                               '. ' || SQLERRM||'.';
                RAISE vr_exc_saida;
            END;

            vr_diarefer := SUBSTR(vr_setlinha,72,2);
            vr_mesrefer := SUBSTR(vr_setlinha,70,2);
            vr_anorefer := SUBSTR(vr_setlinha,66,4);

            BEGIN
              vr_dtrefere := to_date('01'||lpad(vr_mesrefer,2,'0')||vr_anorefer,'ddmmyyyy');
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 13; -- Data errada
            END;

            IF vr_cdcritic <> 13 THEN
              IF SUBSTR(vr_setlinha,43,3) <> vr_nrdbanco THEN
                vr_cdcritic := 57; -- banco nao cadastrado
              END IF;
            END IF;

            IF vr_cdcritic <> 0 THEN
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

              vr_nmarquiv := vr_nmdirdeb|| '/err' || vr_tab_nmarquiv(i);

              -- Acrescenta "err" no inicio do nome do arquivo
              gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_nmdirdeb||'/'||vr_tab_nmarquiv(i)|| ' ' || vr_nmarquiv);

              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
              pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                          ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_dscritic => vr_dscritic ||
                                          ' cdconven:'     || rw_gnconve.cdconven ||
                                          ', nmarquiv:'    || vr_tab_nmarquiv(i)  ||
                                          ', vr_nrseqarq:' || vr_nrseqarq
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_cdcricid => 1   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          );              

              IF pr_cdcooper = 3 THEN -- Se for da Cecred
                -- Montar mensagem para enviar no e-mail
                vr_dscritic := vr_dscritic  || '<br>' ||
                               'Convenio: ' || rw_gnconve.cdconven || '<br>' ||
                               'Arquivo: '  || vr_tab_nmarquiv(i)  || '<br>' ||
                               'NSA: '      || vr_nrseqarq;

                -- Envia critica por email
                pc_envia_critica_email('CRPS387',
                                  pr_cdcooper,
                                  vr_dscritic,
                                  rw_gnconve.nmempres);
              END IF;
              -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
              GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

              -- Limpa as variaveis de erro
              vr_cdcritic := 0;
              vr_dscritic := NULL;

              continue;  -- Vai para o proximo registro
            END IF;

            -- Se for convenio novo nao entra
            IF vr_nrseqarq > 1 THEN
              -- Verificar se NSA anterior está criado
              OPEN cr_gncontr_1(pr_cdcooper, rw_gnconve.cdconven, (vr_nrseqarq - 1) );
              FETCH cr_gncontr_1 INTO rw_gncontr_1;
              -- Se nao encontrar dados efetua a insercao
              IF cr_gncontr_1%NOTFOUND THEN
                CLOSE cr_gncontr_1;
                vr_nmarquiv := vr_nmdirdeb|| '/err' || vr_tab_nmarquiv(i);
                vr_cdcritic := 476; -- arquivo fora de sequencia

                -- busca a descricao da critica
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                vr_dsconteu := to_char(sysdate,'dd/mm/yyyy HH24:MI:SS') || ' - ' ||
                               vr_cdprogra || ' --> ' || vr_dscritic || ' ' || vr_tab_nmarquiv(i) ||
                               ' Seq. Parametrizada ' || to_char((vr_nrseqarq - 1),'000000') ||
                               ' Seq. Arquivo ' || to_char(vr_nrseqarq);

                -- Acrescenta "err" no inicio do nome do arquivo
                gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_nmdirdeb||'/'||vr_tab_nmarquiv(i)|| ' ' || vr_nmarquiv);

                vr_dscritic_in := vr_dscritic ||
                                  ' nmarquiv:'     || vr_tab_nmarquiv(i) ||
                                  ', vr_nrseqarq:' || to_char((vr_nrseqarq - 1),'000000');
                -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
                pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                            ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            ,pr_dscritic => vr_dscritic_in
                            ,pr_cdcritic => vr_cdcritic
                            ,pr_cdcricid => 1   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            );     

                -- Limpa as variaveis de erro
                vr_cdcritic := 0;
                vr_dscritic := NULL;

                -- Enviar e-mail com o log gerado
                gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                          ,pr_cdprogra        => 'CRPS387A'
                                          ,pr_des_destino     => vr_emaildst
                                          ,pr_des_assunto     => 'Arquivo Fora de Sequencia - ' || rw_gnconve.nmempres
                                          ,pr_des_corpo       => vr_dsconteu -- conteudo
                                          ,pr_des_anexo       => NULL
                                          ,pr_des_erro        => vr_dscritic);

                -- Verificar se houve erro ao solicitar e-mail
                IF vr_dscritic IS NOT NULL THEN
                  -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018   
                  vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                  vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                  vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                                       
                  vr_cdcritic := 1197;
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                                 ' vr_dscritic:' || vr_dscritic ||
    		                         ', pr_cdcooper:'    || pr_cdcooper ||
                                 ', pr_cdprogra:'    || 'CRPS387A' ||
                                 ', pr_des_destino:' || vr_emaildst ||
                                 ', pr_des_assunto:' || 'Arquivo Fora de Sequencia - ' || rw_gnconve.nmempres ||
                                 ', pr_des_corpo:'   || vr_dsconteu ||
                                 ', pr_des_anexo:'   || 'NULL';    
                  RAISE vr_exc_saida;
                END IF;
                -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
                GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);	

                continue;  -- Vai para o proximo registro
              ELSE
                CLOSE cr_gncontr_1;
              END IF;
            END IF;
            /*** Verifica se gera confirmacao de recebimento de arquivo**/
            IF rw_gnconve.flggeraj = 1 then
              vr_cdconven := rw_gnconve.cdconven;
              vr_nrsequen := SUBSTR(vr_setlinha,74,6);
              vr_dtgerarq := to_DAte(SUBSTR(vr_setlinha,66,8),'YYYYMMDD');
              vr_nmarqcon := vr_tab_nmarquiv(i);
            END IF;

            /*--- Criticar Tipos de Registros ---*/

            vr_contareg := 1;

            -- Inicializa as variaveis
            vr_ind_deb := 0;
            vr_tab_debcancel.delete;

            LOOP

              BEGIN
                -- Ler a linha do arquivo.
                gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                            ,pr_des_text => vr_setlinha); --> Texto lido
              EXCEPTION
                WHEN OTHERS THEN -- Chegou ao final do arquivo
                  EXIT;
              END;

              vr_tpregist := SUBSTR(vr_setlinha,1,1);
              -- Verifica o tipo de regsitro
              IF vr_tpregist NOT IN ('A','B','C','D','E','Z') THEN
                vr_cdcritic := 468; -- Tipo de registro errado.
                EXIT;
              END IF;

              vr_contareg := vr_contareg + 1;
              -- Se for novamente um registro de cabecalho
              IF vr_tpregist = 'A' THEN
                vr_cdcritic := 468; -- Tipo de registro errado.
                EXIT;
              ELSIF vr_tpregist = 'E' THEN -- Corpo do arquivo
                -- validar a leitura do valor do arquivo
                BEGIN
                  vr_nrauxili := to_number(SUBSTR(vr_setlinha,53,15));
                EXCEPTION
                  WHEN OTHERS THEN
                    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
                    -- Popula tabela de erro
                    vr_cdcritic_in := 1053;
                    vr_tab_erro(vr_tab_erro.count+1) := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic_in) ||
                                                        ' (2) vr_cdconven:'  || vr_cdconven ||
                                                        ', vr_contareg:' || to_char(vr_contareg) ||
                                                        ', nmarquiv:'    || vr_tab_nmarquiv(i) ||
                                                        '. ' || SQLERRM;
                    -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
                    pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                                ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                ,pr_dscritic => vr_tab_erro(vr_tab_erro.count)
                                ,pr_cdcritic => vr_cdcritic_in
                                ,pr_cdcricid => 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                               );     
                    -- Atribui o valor zero para a variável
                    vr_nrauxili := 0;
                END;

                -- Calcula o valor de débido
                vr_vldebito := vr_vldebito + (vr_nrauxili / 100);

                vr_diarefer := substr(vr_setlinha,51,2);
                vr_mesrefer := substr(vr_setlinha,49,2);
                vr_anorefer := substr(vr_setlinha,45,4);

                BEGIN
                  vr_dtrefere := to_date(substr(vr_setlinha,45,8),'yyyymmdd');
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 13; -- Data errada
                    EXIT;
                END;
                -- Popula a temp/table com os registro de debito cancelado na temp/table
                IF SUBSTR(vr_setlinha,150,1) = 1 THEN
                  vr_tab_debcancel(vr_ind_deb).setlinha := SUBSTR(vr_setlinha,1,150);
                   vr_ind_deb := vr_ind_deb + 1;
                END IF;
              ELSIF vr_tpregist = 'Z' THEN -- Rodapé

                -- Buscar o total do arquivo no rodapé
                BEGIN
                  vr_nrauxili := to_number(SUBSTR(vr_setlinha,08,17));
                EXCEPTION
                  WHEN OTHERS THEN
                    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
                    -- Popula tabela de erro
                    vr_cdcritic_in := 1053;
                    vr_tab_erro(vr_tab_erro.count+1) := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic_in) ||
                                                        ' (3)cdconven:' || vr_cdconven ||
                                                        ',contareg:' || to_char(vr_contareg) ||
                                                        ',nmarquiv:' || vr_tab_nmarquiv(i) ||
                                                        '. '         || SQLERRM;
                    -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
                    pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                                ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                ,pr_dscritic => vr_tab_erro(vr_tab_erro.count)
                                ,pr_cdcritic => vr_cdcritic_in
                                ,pr_cdcricid => 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                               );       
                    -- Atribui o valor um negativo para a variável
                    vr_nrauxili := -1;

                END;

                IF vr_contareg <> SUBSTR(vr_setlinha,2,6) THEN
                  vr_cdcritic := 504; -- Quantidade de registros errada.
                  EXIT;
                ELSIF vr_vldebito <> (vr_nrauxili / 100) THEN
                  vr_cdcritic := 505; -- Valor dos debitos errado.
                  EXIT;
                END IF;

                --Verifica se gera confirmacao de recebimento de arquivo
                IF rw_gnconve.flggeraj = 1 THEN
                  -- Insere os dados do arquivo recebido
                  BEGIN
                    INSERT INTO gnarqrx
                        (cdconven,
                         nrsequen,
                         dtgerarq,
                         nmarquiv,
                         qtregarq,
                         vltotarq,
                         dtmvtolt)
                    VALUES
                        (vr_cdconven,
                         vr_nrsequen,
                         vr_dtgerarq,
                         vr_nmarqcon,
                         SUBSTR(vr_setlinha,2,6),
                         SUBSTR(vr_setlinha,8,17) / 100,
                         rw_crapdat.dtmvtolt);

                  EXCEPTION
                    WHEN dup_val_on_index THEN
                      -- Renato Darosci - 14/05/2014 - Programa alterado para tratar o estouro de chave
                      -- através de exception e não com select, como feito anteriormente. Como o programa
                      -- roda paralelamente em várias cooperativas, ocorreram casos onde o programa realizava
                      -- a inserção em mais de uma cooperativa ao mesmo tempo, causando erro.
                      NULL;
                    WHEN OTHERS THEN
                      -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                      -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                      vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                      vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                      vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                      vr_cdcritic := 1034;
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                     ||'GNARQRX: cdconven:'||vr_cdconven
                                     ||', nrsequen:'||vr_nrsequen||', dtgerarq:'||vr_dtgerarq
                                     ||', nmarquiv:'||vr_nmarqcon||', qtregarq:'||SUBSTR(vr_setlinha,2,6)
                                     ||', vltotarq:'||SUBSTR(vr_setlinha,8,17) / 100
                                     ||', dtmvtolt:'||rw_crapdat.dtmvtolt
                                     ||'. '||SQLERRM;
                      RAISE vr_exc_saida;
                  END;
                END IF; --rw_gnconve.flggeraj = 1
                EXIT; -- Sai do loop
              END IF;
              
            END LOOP;

           /* o comando abaixo ignora quebras de linha atraves do 'grep -v' e o 'tail -1' retorna
              a ultima linha do resultado do grep */
           vr_comando:= 'grep -v '||'''^$'' '||vr_nmdirdeb||'/'||vr_tab_nmarquiv(i)||'| tail -1';

           --Executar o comando no unix
           GENE0001.pc_OScommand(pr_typ_comando => 'S'
                                ,pr_des_comando => vr_comando
                                ,pr_typ_saida   => vr_typ_saida2
                                ,pr_des_saida   => vr_setlinha2);
           --Se ocorreu erro dar RAISE
           IF vr_typ_saida2 = 'ERR' THEN
             -- Montar mensagem de critica - Chamado INC0011662 - 28/03/2018
             vr_tpocorre := 1;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
             vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
             vr_cdcricid := 1;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica  
             vr_cdcritic := 1114; --Nao foi possivel executar comando unix
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)||' '||vr_comando;
             RAISE vr_exc_saida;
           END IF;
                 
           --Verificar se a ultima linha é o Trailer
           IF SUBSTR(vr_setlinha2,01,01) <> 'Z' THEN 
             -- Substituir o codigo ficticio 999 pelo 1204 cadastrado - Chamado INC0011662 - 28/03/2018 
             vr_cdcritic := 1204; -- Arquivo incompleto. - 999;
             vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);             
           END IF;

            -- Fechar o arquivo
            BEGIN
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018  
                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                           
                vr_cdcritic := 1039;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                               ' vr_nmdirdeb:'    || vr_nmdirdeb        ||
                               ', pr_nmarquiv:'    || vr_tab_nmarquiv(i) ||
                               ', pr_tipabert:'    || 'R'           ||
		    				               ', (5). ' || SQLERRM||'.';
                --Levantar Excecao
                RAISE vr_exc_saida;
            END;


            IF vr_cdcritic <> 0 THEN
              -- Substituir o codigo ficticio 999 pelo 1204 cadastrado - Chamado INC0011662 - 28/03/2018 
              IF vr_cdcritic <> 1204 THEN
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;

              IF pr_cdcooper = 3 THEN -- Se for da Cecred
                -- Montar mensagem para enviar no e-mail
                vr_dscritic := vr_dscritic  || '<br><br>' ||
                               'Convenio: ' || rw_gnconve.cdconven || '<br>' ||
                               'Arquivo: '  || vr_tab_nmarquiv(i)  || '<br>' ||
                               'NSA: '      || vr_nrseqarq;

                -- Somente enviar anexo caso arquivo esteja incompleto
                -- Substituir o codigo ficticio 999 pelo 1204 cadastrado - Chamado INC0011662 - 28/03/2018 
                IF vr_cdcritic = 1204 THEN
                  vr_des_anexo:= vr_nmdirdeb||'/'||vr_tab_nmarquiv(i);
                END IF;

                -- Envia critica por email
                pc_envia_critica_email('CRPS387',
                                  pr_cdcooper,
                                  vr_dscritic,
                                  rw_gnconve.nmempres,
                                  vr_des_anexo);
                vr_des_anexo:= NULL;
                -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
              END IF;

              -- Substituir o codigo ficticio 999 pelo 1204 cadastrado - Chamado INC0011662 - 28/03/2018               
              IF vr_cdcritic <> 1204 THEN
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;
              
              vr_nmarquiv := vr_nmdirdeb||'/err' || vr_tab_nmarquiv(i);

              -- Acrescenta "err" no inicio do nome do arquivo
              gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_nmdirdeb||'/'||vr_tab_nmarquiv(i)|| ' ' || vr_nmarquiv);

              vr_cdcritic_in := NVL(vr_cdcritic,0);
              vr_dscritic_in := vr_dscritic ||
                                ' vr_nmarquiv:' || vr_nmarquiv;
              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
              pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                          ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_dscritic => vr_dscritic_in
                          ,pr_cdcritic => vr_cdcritic_in
                          ,pr_cdcricid => 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          );            

              -- Limpa as variaveis de erro
              vr_cdcritic := 0;
              vr_dscritic := NULL;

              continue;  -- Vai para o proximo registro
             END IF;

            /*---------- Efetuar Integracao -------------*/

            vr_contlinh := 1;

            vr_cdcritic_in := 219;
            vr_dscritic_in := vr_dscritic_in ||' - '||vr_tab_nmarquiv(i);
            -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
            pc_trata_log(pr_dstiplog => 'O' -- I-início; F-fim; O-ocorrência; E-erro
                        ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                        ,pr_dscritic => vr_dscritic_in
                        ,pr_cdcritic => vr_cdcritic_in
                        ,pr_cdcricid => 0  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                        );           

            -- Abre o arquivo
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirdeb                    --> Diretorio do arquivo
                                    ,pr_nmarquiv => vr_tab_nmarquiv(i)             --> Nome do arquivo
                                    ,pr_tipabert => 'R'                            --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_input_file                  --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_dscritic);                  --> Erro

            vr_arqvazio := FALSE;
            BEGIN
              -- Ler a linha do arquivo.
              gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                          ,pr_des_text => vr_setlinha); --> Texto lido
            EXCEPTION
              WHEN no_data_found THEN
                vr_arqvazio := TRUE;
                vr_cdcritic_in := 263; -- Arquivo vazio
                vr_dscritic_in := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic_in) ||
                                  ' (2) nmdirdeb:' || vr_nmdirdeb ||
                                  ', nmarquivo:'   || vr_tab_nmarquiv(i);
                -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
                pc_trata_log(pr_dstiplog => 'O' -- I-início; F-fim; O-ocorrência; E-erro
                            ,pr_tpocorre => 3   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            ,pr_dscritic => vr_dscritic_in
                            ,pr_cdcritic => vr_cdcritic_in
                            ,pr_cdcricid => 0  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            );   
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                -- Montar mensagem de critica - Chamado INC0011662 - 28/03/2018
                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica          
                vr_cdcritic := 1053;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                               '(4) pr_nmdireto:' || vr_nmdirdeb ||
                               ', pr_nmarquiv:'   || vr_tab_nmarquiv(i) ||
                               '. ' || SQLERRM||'.';        				
                RAISE vr_exc_saida;
            END;

            -- Se o arquivo nao estiver vazio
            IF NOT vr_arqvazio THEN
              LOOP -- Leitura linha a linha do arquivo para integracao
                BEGIN
                  -- Marca um ponto de rollback caso houver erro na leitura da linha
                  SAVEPOINT LEITURA_LINHA;
                  BEGIN
                    -- Ler a linha do arquivo.
                    gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_input_file --> Handle do arquivo aberto
                                                ,pr_des_text => vr_setlinha); --> Texto lido
                  EXCEPTION
                    WHEN OTHERS THEN -- Chegou ao final do arquivo
                      EXIT;
                  END;

                  vr_contlinh := vr_contlinh + 1;
                  vr_cdcritic := 0;
                  vr_flg_ctamigra := FALSE;
                  vr_tpregist := SUBSTR(vr_setlinha,1,1);

                  IF vr_tpregist = 'Z' THEN
                    -- monta a chave para a pl_table vr_tab_relato
                    vr_nrseq := vr_nrseq + 1;
                    vr_ind := '00000000009999999999999999999999999999999999999'||lpad(vr_nrseq,5,'0');

                    vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                    vr_tab_relato(vr_ind).nrdconta := 999999999;
                    vr_tab_relato(vr_ind).nrdocmto := SUBSTR(vr_setlinha,2,6);
                    vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,8,17) / 100;

                    IF pr_cdcooper = 3 THEN
                       OPEN cr_gncontr_gen(pr_cdconven => rw_gnconve.cdconven
                                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                          ,pr_nrseqarq => vr_nrseqarq);
                       FETCH cr_gncontr_gen INTO rw_gncontr_gen;

                       IF cr_gncontr_gen%NOTFOUND THEN
                          CLOSE cr_gncontr_gen;
                          vr_semmovto := TRUE;
                          EXIT; -- Sair do loop
                       END IF;

                       CLOSE cr_gncontr_gen;
                    END IF;

                    /**** Tratamento Migracao *****/
                    IF vr_flg_migracao THEN
                      vr_cdcooper := vr_cdcoptab;

                      -- Acessa os dados sobre os controles de execucoes
                      OPEN cr_gncontr(vr_cdcooper, rw_gnconve.cdconven, rw_crapdat.dtmvtolt, vr_nrseqarq);
                      FETCH cr_gncontr INTO rw_gncontr;
                      -- Se nao encontrar dados efetua a insercao
                      IF cr_gncontr%NOTFOUND THEN
                        -- Insere no controle de execucoes
                        BEGIN
                          INSERT INTO gncontr
                            (cdcooper,
                             tpdcontr,
                             cdconven,
                             dtmvtolt,
                             nrsequen,
                             flgmigra,
                             qtdoctos,
                             vldoctos,
                             dtcredit,
                             nmarquiv,
                             vltarifa,
                             vlapagar)
                           VALUES
                            (vr_cdcooper,
                             3,
                             rw_gnconve.cdconven,
                             rw_crapdat.dtmvtolt,
                             vr_nrseqarq,
                             1,
                             vr_doc_gravado_migrado,
                             vr_vlr_gravado_migrado,
                             rw_crapdat.dtmvtolt,
                             vr_tab_relato(vr_ind).nmarquiv,
                             0,
                             0)
                            RETURNING flgmigra,
                                      nrsequen,
                                      ROWID
                                 INTO rw_gncontr.flgmigra,
                                      rw_gncontr.nrsequen,
                                      rw_gncontr.ROWID;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'GNCONTR(1): cdcooper:'  ||vr_cdcooper
                                           ||', tpdcontr:3, cdconven:'||rw_gnconve.cdconven
                                           ||', dtmvtolt:'||rw_crapdat.dtmvtolt||', nrsequen:'||vr_nrseqarq
                                           ||', flgmigra:1, qtdoctos:'||vr_doc_gravado_migrado
                                           ||', vldoctos:'||vr_vlr_gravado_migrado||', dtcredit:'||rw_crapdat.dtmvtolt
                                           ||', nmarquiv:'||vr_tab_relato(vr_ind).nmarquiv||', vltarifa:0, vlapagar:0'
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      ELSE
                        -- Altera o controle de execucoes aumentando a quantidade e os valores de documentos executados
                        BEGIN
                          UPDATE gncontr
                             SET qtdoctos = qtdoctos + vr_doc_gravado_migrado,
                                 vldoctos = vldoctos + vr_vlr_gravado_migrado,
                                 dtcredit = rw_crapdat.dtmvtolt,
                                 nmarquiv = vr_tab_relato(vr_ind).nmarquiv,
                                 vltarifa = 0,
                                 vlapagar = 0
                           WHERE ROWID = rw_gncontr.rowid;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1035;   
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'GNCONTR(1): qtdoctos:'||vr_doc_gravado_migrado
                                           ||', vldoctos:'||vr_vlr_gravado_migrado||', dtcredit:'||rw_crapdat.dtmvtolt
                                           ||', nmarquiv:'||vr_tab_relato(vr_ind).nmarquiv
                                           ||', vltarifa:0, vlapagar:0 com rowid:'||rw_gncontr.rowid
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      END IF;
                      CLOSE cr_gncontr;
                    END IF;

                    OPEN cr_gncontr(pr_cdcooper, rw_gnconve.cdconven, rw_crapdat.dtmvtolt, vr_nrseqarq);
                    FETCH cr_gncontr INTO rw_gncontr;
                    -- Se nao encontrar dados efetua a insercao
                    IF cr_gncontr%NOTFOUND THEN
                      -- Insere no controle de execucoes
                      BEGIN
                        INSERT INTO gncontr
                          (cdcooper,
                           tpdcontr,
                           cdconven,
                           dtmvtolt,
                           nrsequen,
                           dtcredit,
                           nmarquiv,
                           qtdoctos,
                           vldoctos,
                           vltarifa,
                           vlapagar)
                         VALUES
                          (pr_cdcooper,
                           3,
                           rw_gnconve.cdconven,
                           rw_crapdat.dtmvtolt,
                           vr_nrseqarq,
                           rw_crapdat.dtmvtolt,
                           vr_tab_relato(vr_ind).nmarquiv,
                           vr_doc_gravado,
                           vr_vlr_gravado,
                           0,
                           0)
                           RETURNING flgmigra,
                                     nrsequen,
                                     ROWID
                                INTO rw_gncontr.flgmigra,
                                     rw_gncontr.nrsequen,
                                     rw_gncontr.ROWID;
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1034;   
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'GNCONTR(2): cdcooper:'  ||pr_cdcooper
                                         ||', tpdcontr:3, cdconven:'||rw_gnconve.cdconven
                                         ||', dtmvtolt:'||rw_crapdat.dtmvtolt||', nrsequen:'||vr_nrseqarq
                                         ||', dtcredit:'||rw_crapdat.dtmvtolt||', nmarquiv:'||vr_tab_relato(vr_ind).nmarquiv
                                         ||', qtdoctos:'||vr_doc_gravado     ||', vldoctos:'||vr_vlr_gravado
                                         ||', vltarifa:0, vlapagar:0'
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    ELSE
                      -- Altera o controle de execucoes
                      BEGIN
                        UPDATE gncontr
                           SET dtcredit = rw_crapdat.dtmvtolt,
                               nmarquiv = vr_tab_relato(vr_ind).nmarquiv,
                               qtdoctos = qtdoctos + vr_doc_gravado,
                               vldoctos = vldoctos + vr_vlr_gravado,
                               vltarifa = 0,
                               vlapagar = 0
                         WHERE ROWID = rw_gncontr.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1035;   
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'GNCONTR(2): dtcredit:'||rw_crapdat.dtmvtolt
                                         ||', nmarquiv:'||vr_tab_relato(vr_ind).nmarquiv
                                         ||', qtdoctos:'||vr_doc_gravado||', vldoctos:'||vr_vlr_gravado
                                         ||', vltarifa:0, vlapagar:0 com rowid:'||rw_gncontr.rowid
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    END IF;
                    CLOSE cr_gncontr;

                    EXIT; -- Sai do loop

                  END IF; --vr_tpregist = 'Z'                                  
                  
                  vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);                  
        	        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

                                    -- Se a linha for referente ao corpo do arquivo
                  IF vr_tpregist = 'E' THEN
                    vr_diarefer := SUBSTR(vr_setlinha,51,2);
                    vr_mesrefer := SUBSTR(vr_setlinha,49,2);
                    vr_anorefer := SUBSTR(vr_setlinha,45,4);

                    BEGIN
                      vr_dtrefere := to_date(lpad(vr_diarefer,2,'0')||lpad(vr_mesrefer,2,'0')||vr_anorefer,'ddmmyyyy');
                      vr_dtrefere := gene0005.fn_valida_dia_util(vr_cdcooper, vr_dtrefere, 'P');	
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 13; -- Data invalida
                    END;
                    -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
                    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                   
                  END IF;
                                    
                  -- Validar caracteres especiais
                  BEGIN
                    vr_nro_conta_dec := NVL(trim(SUBSTR(vr_setlinha,31,14)),0);
                  EXCEPTION
                    WHEN OTHERS THEN
                      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
                      --Irei verificar se usa agencia ou nao pois o tratamento muda
                      IF rw_gnconve.flgagenc = 0 THEN
                         
                         vr_cdagestr := NULL;
                         vr_nrctastr := NULL;
                         vr_nro_cta_str := ' ';
                      
                         BEGIN 
                           vr_cdageinv := RPAD(trim(SUBSTR(vr_setlinha,31,4)),4,'x');
                         EXCEPTION
                           WHEN OTHERS THEN
                             IF pr_cdcooper <> 3 THEN
                                CONTINUE;
                             END IF;
                                
                             vr_cdagestr := '9000';
                         END;
                         
                         IF vr_cdagestr IS NULL THEN
                            vr_nro_cta_str := vr_nro_cta_str||trim(SUBSTR(vr_setlinha,31,4));
                         ELSE
                            vr_nro_cta_str := vr_nro_cta_str||vr_cdagestr;
                         END IF;      

                         BEGIN
                           vr_nrctainv := NVL(trim(SUBSTR(vr_setlinha,35,10)),0);
                         EXCEPTION
                           WHEN OTHERS THEN
                             IF pr_cdcooper = 3 THEN
                                CONTINUE;
                             END IF;
                             
                             vr_nrctastr := '0000000000';
                         END;                      
                         
                         IF vr_nrctastr IS NULL THEN
                            vr_nro_cta_str := vr_nro_cta_str||trim(SUBSTR(vr_setlinha,35,10));
                         ELSE
                            vr_nro_cta_str := vr_nro_cta_str||vr_nrctastr;
                         END IF;                               
                      
                         vr_nro_conta_dec := NVL(trim(vr_nro_cta_str),0);
                      ELSE
                      
                      BEGIN  
                        vr_cdagedeb := NVL(trim(SUBSTR(vr_setlinha,27,4)),0);
                      EXCEPTION
                        WHEN OTHERS THEN
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
                          -- apenas Cecred pode gerar critica de agencia invalida
                          IF pr_cdcooper <> 3 THEN
                            continue;  
                          END IF;
                          
                          vr_cdcritic := 15; --  Agencia nao cadastrada.               
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                          -- Não devemos criar crapndb para registro C e B
                          IF vr_tpregist NOT IN( 'C', 'B') THEN
                            -- Para cada regitro D rejeitado, retornamos o H        
                            IF vr_tpregist = 'D' THEN
                              vr_dstexarq := 'H' || SUBSTR(vr_setlinha,2,68) || RPAD(vr_dscritic,80) || SUBSTR(vr_setlinha,150,1);
                            ELSE
                              vr_dstexarq := 'F' || SUBSTR(vr_setlinha,2,66) || '14' || SUBSTR(vr_setlinha,70,81);
                            END IF;                  
                            -- Arquivo com os registros de debito com caracteres invalido
                            BEGIN
                              INSERT INTO crapndb
                                (dtmvtolt,
                                 nrdconta,
                                 cdhistor,
                                 flgproce,
                                 dstexarq,
                                 cdcooper)
                               VALUES
                                (vr_dtultdia,
                                 vr_nrdconta,
                                 rw_gnconve.cdhisdeb,
                                 0,
                                 vr_dstexarq,
                                 pr_cdcooper);
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPNDB(3): dtmvtolt:'   ||vr_dtultdia
                                               ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                               ||', flgproce:0, dstexarq:' ||vr_dstexarq||', cdcooper:'||pr_cdcooper
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;
                          END IF;
                          -- monta a chave para a pl_table vr_tab_relato
                          vr_nrseq := vr_nrseq + 1;
                          vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                    lpad(SUBSTR(vr_setlinha,02,25),27,'0') || lpad(vr_nrseq,5,'0');
                          vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                          vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                          vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                          vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;                       
                          vr_tab_relato(vr_ind).nrdctabb := 0;
                          vr_tab_relato(vr_ind).cdcritic := 15;
                          vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                          vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                          vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                          vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                          vr_flgrejei     := TRUE;                          
                          CONTINUE;                                                
                      END;                      
                      
                      -- Verificar se a agencia esta dentro do range de agencias
                      IF (vr_cdagedeb < 101 OR vr_cdagedeb > vr_cdultage) THEN
                          -- apenas Cecred pode gerar critica de agencia invalida
                          IF pr_cdcooper <> 3 THEN
                            continue;  
                          END IF;
                          
                          vr_cdcritic := 15; --  Agencia nao cadastrada.               
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                          -- Não devemos criar crapndb para registro C e B
                          IF vr_tpregist NOT IN( 'C', 'B') THEN
                            -- Para cada regitro D rejeitado, retornamos o H        
                            IF vr_tpregist = 'D' THEN
                              vr_dstexarq := 'H' || SUBSTR(vr_setlinha,2,68) || RPAD(vr_dscritic,80) || SUBSTR(vr_setlinha,150,1);
                            ELSE
                              vr_dstexarq := 'F' || SUBSTR(vr_setlinha,2,66) || '14' || SUBSTR(vr_setlinha,70,81);
                            END IF;                  
                            -- Arquivo com os registros de debito com caracteres invalido
                            BEGIN
                              INSERT INTO crapndb
                                (dtmvtolt,
                                 nrdconta,
                                 cdhistor,
                                 flgproce,
                                 dstexarq,
                                 cdcooper)
                               VALUES
                                (vr_dtultdia,
                                 vr_nrdconta,
                                 rw_gnconve.cdhisdeb,
                                 0,
                                 vr_dstexarq,
                                 pr_cdcooper);
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPNDB(4): dtmvtolt:'   ||vr_dtultdia
                                               ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                               ||', flgproce:0, dstexarq:' ||vr_dstexarq||', cdcooper:'||pr_cdcooper
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;
                          END IF;
                          -- monta a chave para a pl_table vr_tab_relato
                          vr_nrseq := vr_nrseq + 1;
                          vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                    lpad(SUBSTR(vr_setlinha,02,25),27,'0') || lpad(vr_nrseq,5,'0');
                          vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                          vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                          vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                          vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;                       
                          vr_tab_relato(vr_ind).nrdctabb := 0;
                          vr_tab_relato(vr_ind).cdcritic := 15;
                          vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                          vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                          vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                          vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                          vr_flgrejei     := TRUE;                          
                          CONTINUE;                                                
                         
                      END IF;
                      
                      /* se esta rodando na Cecred e deu erro pra conta, ignora o registro pois nao
                         sera possivel validar a agencia */
                      IF pr_cdcooper = 3 THEN
                             CONTINUE;
                      END IF;
                            
                      /*Se for agencia sim e deu problema na hora de converter a conta
                        devolver a critica apenas pra coop do registro e descartar pras 
                        outras coops*/
                      IF rw_crapcop.cdagectl <> vr_cdagedeb AND  
                         (vr_cdagedeb > 100 AND vr_cdagedeb <= vr_cdultage) THEN
                         CONTINUE;
                      END IF;
                            
                      vr_cdcritic := 564; -- Conta nao cadastrada.
                      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                          -- Não devemos criar crapndb para registro C e B
                          IF vr_tpregist NOT IN( 'C', 'B') THEN
                      -- Para cada regitro D rejeitado, retornamos o H        
                      IF vr_tpregist = 'D' THEN
                        vr_dstexarq := 'H' || SUBSTR(vr_setlinha,2,68) || RPAD(vr_dscritic,80) || SUBSTR(vr_setlinha,150,1);
                      ELSE
                        vr_dstexarq := 'F' || SUBSTR(vr_setlinha,2,66) || '15' || SUBSTR(vr_setlinha,70,81);
                      END IF;                  
                      -- Arquivo com os registros de debito com caracteres invalido
                      BEGIN
                        INSERT INTO crapndb
                          (dtmvtolt,
                           nrdconta,
                           cdhistor,
                           flgproce,
                           dstexarq,
                           cdcooper)
                         VALUES
                          (vr_dtultdia,
                           0, -- Conta
                           rw_gnconve.cdhisdeb,
                           0,
                           vr_dstexarq,
                           pr_cdcooper);
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1034;
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'CRAPNDB(5): dtmvtolt:'||vr_dtultdia
                                         ||', nrdconta:0, cdhistor:'||rw_gnconve.cdhisdeb
                                         ||', flgproce:0, dstexarq:'||vr_dstexarq||', cdcooper:'||pr_cdcooper
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                          END IF;
                      
                      -- monta a chave para a pl_table vr_tab_relato
                      vr_nrseq := vr_nrseq + 1;
                      vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(10,'0') ||
                                lpad(SUBSTR(vr_setlinha,02,25),27,'0') || lpad(vr_nrseq,5,'0');
                      vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                      vr_tab_relato(vr_ind).nrdconta := 0;
                      vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                      vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;                       
                      vr_tab_relato(vr_ind).nrdctabb := 0;
                      vr_tab_relato(vr_ind).cdcritic := 564;
                      vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                      vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                      vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                      vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                      vr_flgrejei     := TRUE;                          
                      
                      continue;                      
                      END IF;  
                  END; --fim WHEN OTHERS
                  
                  vr_nro_conta_tam := TRIM(vr_nro_conta_dec);
                  vr_nro_conta_tam := ltrim(vr_nro_conta_tam, '0');                  
                  
                  IF vr_nro_conta_dec < 9000000000 THEN                  
                    IF vr_nro_conta_dec >= 2147483647 THEN
                      vr_nrdconta := 0;
                    ELSE
                      vr_nrdconta := vr_nro_conta_dec;
                    END IF;
                  ELSE 
                    vr_nrdconta := SUBSTR(vr_nro_conta_tam,5,10);
                  END IF;
                    
                  -- Validar caracteres especiais
             
                  BEGIN
                      vr_cdagedeb := NVL(trim(SUBSTR(vr_setlinha,27,4)),0);
                  EXCEPTION
                      WHEN OTHERS THEN
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
                        -- apenas Cecred pode gerar critica de agencia invalida
                        IF pr_cdcooper <> 3 THEN
                          continue;  
                        END IF;
                        
                        vr_cdcritic := 15; --  Agencia nao cadastrada.               
                        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);

                        -- Não devemos criar crapndb para registro C e B
                        IF vr_tpregist NOT IN( 'C', 'B') THEN
                        -- Para cada regitro D rejeitado, retornamos o H        
                        IF vr_tpregist = 'D' THEN
                          vr_dstexarq := 'H' || SUBSTR(vr_setlinha,2,68) || RPAD(vr_dscritic,80) || SUBSTR(vr_setlinha,150,1);
                        ELSE
                          vr_dstexarq := 'F' || SUBSTR(vr_setlinha,2,66) || '14' || SUBSTR(vr_setlinha,70,81);
                        END IF;                  
                        -- Arquivo com os registros de debito com caracteres invalido
                        BEGIN
                          INSERT INTO crapndb
                            (dtmvtolt,
                             nrdconta,
                             cdhistor,
                             flgproce,
                             dstexarq,
                             cdcooper)
                           VALUES
                            (vr_dtultdia,
                             vr_nrdconta,
                             rw_gnconve.cdhisdeb,
                             0,
                             vr_dstexarq,
                             pr_cdcooper);
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPNDB(6): dtmvtolt:'||vr_dtultdia
                                           ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                           ||', flgproce:0, dstexarq:'||vr_dstexarq||', cdcooper:'||pr_cdcooper
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                        END IF;
                        -- monta a chave para a pl_table vr_tab_relato
                        vr_nrseq := vr_nrseq + 1;
                        vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                  lpad(SUBSTR(vr_setlinha,02,25),27,'0') || lpad(vr_nrseq,5,'0');
                        vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                        vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                        vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                        vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;                       
                        vr_tab_relato(vr_ind).nrdctabb := 0;
                        vr_tab_relato(vr_ind).cdcritic := 15;
                        vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                        vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                        vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                        vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                        vr_flgrejei     := TRUE;                          
                        continue;                      
                  END;                  
                  
                  vr_dsrefere := ltrim(trim(substr(vr_setlinha,2,25)),'0');
                  
                  IF SUBSTR(vr_dsrefere,1,1) IS NOT NULL AND 
                     pr_cdcooper <> 3 THEN -- Não critica referencia para a cecred
                    BEGIN
                     vr_cdrefere := vr_dsrefere;
                    EXCEPTION
                      WHEN OTHERS THEN                        
                        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
                        vr_cdcritic := 453; -- Autorizacao nao encontrada.
                        vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
                          
                        /*Se for agencia sim e deu problema na hora de converter a referencia
                        devolver a critica apenas pra coop do registro e descartar pras 
                        outras coops*/
                        IF rw_gnconve.flgagenc = 1 THEN
                          IF rw_crapcop.cdagectl <> vr_cdagedeb AND  
                             (vr_cdagedeb > 100 AND vr_cdagedeb <= vr_cdultage) THEN
                             CONTINUE;
                          END IF;
                        ELSIF vr_nro_conta_dec > 9000000000 THEN -- Conta > 9000000000 
                          IF SUBSTR(vr_nro_conta_tam,2,3) <> pr_cdcooper THEN
                            CONTINUE;
                          END IF;
                        ELSE 
                        
                          -- Se a agencia de debito for diferente da agencia de controle
                          -- e agencia de debito for diferente de 001(viacredi) ou cooperativa do processo
                          -- for diferente de Viacredi então vamos ignorar o registro
                          -- e agencia de debito nao for casan e samae timbo 
                          IF vr_cdagedeb NOT IN(1294,23) THEN
                            IF vr_cdagedeb <> rw_crapcop.cdagectl 
                               AND (vr_cdagedeb <> 1 OR rw_crapcop.cdcooper <> 1) THEN
                              continue;
                            END IF;
                          ELSE
                            -- Se agencia do debito for 0023 (Samae Timbo) e cooperativa nao for viacredi
                            -- devemos ignorar
                            IF vr_cdagedeb = 23 AND rw_crapcop.cdcooper <> 1 THEN
                              continue;
                            ELSIF vr_cdagedeb = 1294 THEN                                                  
                              -- processar registros da casan somente na cooperativa em questao
                              IF pr_cdcooper <> rw_crapcop.cdcooper THEN
                                continue;
                              END IF;  
                                        
                              -- Abre o cursor de associados
                              IF cr_crapass%ISOPEN THEN
                                CLOSE cr_crapass;
                              END IF;
                              -- verificar se a conta pertence a cooperativa que esta rodando
                              OPEN cr_crapass(pr_cdcooper, vr_nrdconta, 0);
                              FETCH cr_crapass INTO rw_crapass;
                              
                              IF cr_crapass%NOTFOUND THEN
                                CLOSE cr_crapass;
                                continue;
                              ELSE
                                CLOSE cr_crapass;
                              END IF;                            
                            END IF;
                          END IF;
                        END IF;
                        
                        -- Não devemos criar crapndb para registro C e B
                        IF vr_tpregist NOT IN( 'C', 'B') THEN
                        -- Para cada regitro D rejeitado, retornamos o H
                        IF vr_tpregist = 'D' THEN
                          vr_dstexarq := 'H' || SUBSTR(vr_setlinha,2,68) || RPAD(vr_dscritic,80) || SUBSTR(vr_setlinha,150,1);
                        ELSE
                          vr_dstexarq := 'F'||SUBSTR(vr_setlinha,2,66)||'30'||SUBSTR(vr_setlinha,70,81);
                        END IF;          
                          
                        -- Arquivo com os registros de debito com caracteres invalido          
                        BEGIN
                          INSERT INTO crapndb
                            (dtmvtolt,
                             nrdconta,
                             cdhistor,
                             flgproce,
                             dstexarq,
                             cdcooper)
                           VALUES
                            (vr_dtultdia,
                             vr_nrdconta,
                             rw_gnconve.cdhisdeb,
                             0,
                             vr_dstexarq,
                             pr_cdcooper);
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPNDB(7): dtmvtolt:'||vr_dtultdia
                                           ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                           ||', flgproce:0, dstexarq:'||vr_dstexarq||', cdcooper:'||pr_cdcooper
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                        END IF;
                        -- monta a chave para a pl_table vr_tab_relato
                        vr_nrseq := vr_nrseq + 1;
                        vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                  lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                        vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                        vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                        vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                        IF vr_cdcritic <> 13 THEN
                          vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                        END IF;
                        vr_tab_relato(vr_ind).nrdctabb := 0;
                        vr_tab_relato(vr_ind).cdcritic := 453;
                        vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                        vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                        vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                        vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                        vr_flgrejei     := TRUE;                          
                        continue;                      
                    END;
                  ELSE
                    IF SUBSTR(vr_dsrefere,1,1) IS NULL AND 
                      vr_tpregist in('E','D') AND pr_cdcooper <> 3 THEN -- nao critica para Cecred
                      vr_cdcritic := 453; -- Autorizacao nao encontrada.
                      vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA
                          
                      /*Se for agencia sim e deu problema na hora de converter a referencia
                        devolver a critica apenas pra coop do registro e descartar pras 
                        outras coops*/
                      IF rw_gnconve.flgagenc = 1 THEN
                        IF rw_crapcop.cdagectl <> vr_cdagedeb AND  
                           (vr_cdagedeb > 100 AND vr_cdagedeb <= vr_cdultage) THEN
                           CONTINUE;
                        END IF;
                      ELSIF vr_nro_conta_dec > 9000000000 THEN -- Conta > 9000000000 
                        IF to_number(SUBSTR(vr_nro_conta_tam,2,3)) <> pr_cdcooper THEN
                          CONTINUE;
                        END IF;
                      ELSE 
                        
                        -- Se a agencia de debito for diferente da agencia de controle
                        -- e agencia de debito for diferente de 001(viacredi) ou cooperativa do processo
                        -- for diferente de Viacredi então vamos ignorar o registro
                        -- e agencia de debito nao for casan e samae timbo 
                        IF vr_cdagedeb NOT IN(1294,23) THEN
                          IF vr_cdagedeb <> rw_crapcop.cdagectl 
                             AND (vr_cdagedeb <> 1 OR rw_crapcop.cdcooper <> 1) THEN
                            continue;
                          END IF;
                        ELSE
                          -- Se agencia do debito for 0023 (Samae Timbo) e cooperativa nao for viacredi
                          -- devemos ignorar
                          IF vr_cdagedeb = 23 AND rw_crapcop.cdcooper <> 1 THEN
                            continue;
                          ELSIF vr_cdagedeb = 1294 THEN                                                  
                            -- processar registros da casan somente na cooperativa em questao
                            IF pr_cdcooper <> rw_crapcop.cdcooper THEN
                              continue;
                            END IF;  
                                        
                            -- Abre o cursor de associados
                            IF cr_crapass%ISOPEN THEN
                              CLOSE cr_crapass;
                            END IF;
                            -- verificar se a conta pertence a cooperativa que esta rodando
                            OPEN cr_crapass(pr_cdcooper, vr_nrdconta, 0);
                            FETCH cr_crapass INTO rw_crapass;
                              
                            IF cr_crapass%NOTFOUND THEN
                              CLOSE cr_crapass;
                              continue;
                            ELSE
                              CLOSE cr_crapass;
                            END IF;                            
                          END IF;
                        END IF;
                      END IF;
                      
                      -- Para cada regitro D rejeitado, retornamos o H
                      IF vr_tpregist = 'D' THEN
                        vr_dstexarq := 'H' || SUBSTR(vr_setlinha,2,68) || RPAD(vr_dscritic,80) || SUBSTR(vr_setlinha,150,1);
                      ELSE
                        vr_dstexarq := 'F'||SUBSTR(vr_setlinha,2,66)||'30'||SUBSTR(vr_setlinha,70,81);
                      END IF;          
                          
                      -- Arquivo com os registros de debito com caracteres invalido          
                      BEGIN
                        INSERT INTO crapndb
                          (dtmvtolt,
                           nrdconta,
                           cdhistor,
                           flgproce,
                           dstexarq,
                           cdcooper)
                         VALUES
                          (vr_dtultdia,
                           vr_nrdconta,
                           rw_gnconve.cdhisdeb,
                           0,
                           vr_dstexarq,
                           pr_cdcooper);
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1034;
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'CRAPNDB(8): dtmvtolt:'   ||vr_dtultdia
                                         ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                         ||', flgproce:0, dstexarq:' ||vr_dstexarq||', cdcooper:'||pr_cdcooper
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;

                      -- monta a chave para a pl_table vr_tab_relato
                      vr_nrseq := vr_nrseq + 1;
                      vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                      vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                      vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                      vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                      IF vr_cdcritic <> 13 THEN
                        vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                      END IF;
                      vr_tab_relato(vr_ind).nrdctabb := 0;
                      vr_tab_relato(vr_ind).cdcritic := 453;
                      vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                      vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                      vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                      vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                      vr_flgrejei     := TRUE;                          
                      continue;    
                  ELSE
                      IF vr_tpregist IN( 'C', 'B') THEN
                      vr_cdrefere := vr_dsrefere; -- Validar se referencia é valida
                      END IF;
                    vr_cdrefere := 0;
                  END IF;  
                  END IF;  

                  -- Verifica se o convenio usa agencias no arquivo enviado
                  IF rw_gnconve.flgagenc = 1 THEN
                    /* Verificacao para tratar recebimento de agencia invalida
                      (ocorre somente pela CECRED ) */
                    IF pr_cdcooper = 3 AND (vr_cdagedeb < 100 OR vr_cdagedeb > vr_cdultage) THEN

                      IF vr_nro_conta_dec >= 2147483647 THEN /* Max.Int */
                        vr_nrdconta := 0;
                      ELSE
                        vr_nrdconta := vr_nro_conta_dec;
                      END IF;

                      -- Somente ira gerar crapndb caso o registro não seja do tipo "C" e "B"
                      IF vr_tpregist NOT IN( 'C', 'B') THEN
                        pc_critica_debito_cooperativa(1, rw_gnconve.cdhisdeb, vr_tab_nmarquiv(i));
                        -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                      END IF;
                      continue;
                    END IF;

                    -- Se a agencia de debito for diferente da agencia de controle da central ignora a linha
                    IF vr_cdagedeb <> rw_crapcop.cdagectl THEN
                    
                      OPEN cr_cdcooper(pr_cdagectl => vr_cdagedeb);
                      FETCH cr_cdcooper INTO rw_cdcooper;
                      
                      IF cr_cdcooper%NOTFOUND THEN
                         CLOSE cr_cdcooper;
                         CONTINUE;
                      ELSE
                         vr_cdcooper := rw_cdcooper.cdcooper;
                      END IF;
                      
                      CLOSE cr_cdcooper;                   
                    
                     /**** Tratamento incorporacao ****/
                      IF cr_craptco_conta_incorporada%ISOPEN THEN
                        CLOSE cr_craptco_conta_incorporada;
                      END IF;

                      OPEN cr_craptco_conta_incorporada(pr_cdcooper => pr_cdcooper,
                                                        pr_cdcopant => vr_cdcooper,
                                                        pr_nrdconta => vr_nrdconta);
                      FETCH cr_craptco_conta_incorporada INTO rw_craptco_conta_incorporada;
                      
                      IF cr_craptco_conta_incorporada%FOUND THEN -- Se for uma conta transferida
                        CLOSE cr_craptco_conta_incorporada;
                        vr_flg_ctamigra := TRUE;
                        vr_nrdconta := rw_craptco_conta_incorporada.nrdconta;
                        vr_cdcooper := pr_cdcooper;
                        vr_nrdolote := vr_dstextab;
                      ELSE
                         CLOSE cr_craptco_conta_incorporada;
                         
                         OPEN cr_craptco_coop(pr_cdcooper => pr_cdcooper,
                                              pr_cdcopant => vr_cdcooper);                                              
                         FETCH cr_craptco_coop INTO rw_craptco_coop;
                         
                         IF cr_craptco_coop%FOUND THEN                                                  
                            CLOSE cr_craptco_coop;
                            -- Somente ira gerar crapndb caso o registro não seja do tipo "C" e "B"
                            IF vr_tpregist NOT IN ('C','B') THEN
                               vr_cdcooper := pr_cdcooper;
                               pc_critica_debito_cooperativa(2, rw_gnconve.cdhisdeb, vr_tab_nmarquiv(i));
                               -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                               GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                            END IF;

                            CONTINUE; /* Nao pertence a Cooperativa que estou rodando...*/
                         END IF;
                         
                         CLOSE cr_craptco_coop;
                         CONTINUE;
                      END IF;                    

                    ELSE /* Max.Int */
                      IF vr_nro_conta_dec >= 2147483647 THEN
                        vr_nrdconta := 0;
                      ELSE
                        vr_nrdconta := vr_nro_conta_dec;
                      END IF;

                      -- Verificar se cursor esta aberto
                      IF cr_craptco%ISOPEN THEN
                        CLOSE cr_craptco;
                      END IF;
                      
                      /**** Tratamento migracao ****/
                      OPEN cr_craptco(vr_nrdconta);
                      FETCH cr_craptco INTO rw_craptco;
                      IF cr_craptco%FOUND THEN -- Se for uma conta transferida
                        CLOSE cr_craptco;
                        CONTINUE;
                        /* comentado trexo pois somente vamos criar o agendamento na coop
                           que foi migrada
                        -- Busca o numero do lote
                        vr_dstextab_2 := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_craptco.cdcooper
                                                                   ,pr_nmsistem => 'CRED'
                                                                   ,pr_tptabela => 'GENERI'
                                                                   ,pr_cdempres => 00
                                                                   ,pr_cdacesso => 'LOTEINT031'
                                                                   ,pr_tpregist => 001);

                        vr_flg_ctamigra := TRUE;
                        vr_flg_migracao := TRUE;
                        vr_cdcooper := rw_craptco.cdcooper;
                        vr_cdcoptab := rw_craptco.cdcooper;
                        vr_nrdconta := rw_craptco.nrdconta;
                        vr_nrdolote := vr_dstextab_2; */
                      ELSE -- Se nao for uma conta transferida
                        vr_cdcooper := pr_cdcooper;
                        vr_nrdolote := vr_dstextab;
                      END IF;
                      CLOSE cr_craptco;
                    END IF;
                  ELSIF vr_nro_conta_dec < 9000000000 THEN /* Tratar erro, Maior que 10 nao pode converter para INT - ZE */
                    IF vr_nro_conta_dec >= 2147483647   THEN /* Max.Int*/
                      vr_nrdconta := 0;
                    ELSE
                      vr_nrdconta := vr_nro_conta_dec;
                    END IF;

                    -- se agencia de debito nao for casan e samae timbo 
                    IF vr_cdagedeb NOT IN(1294,23) THEN
                    IF pr_cdcooper = 3 AND (vr_cdagedeb < 100 OR vr_cdagedeb > vr_cdultage) 
                       AND vr_cdagedeb <> 1 THEN

                      -- Somente ira gerar crapndb caso o registro não seja do tipo "C" e "B"
                      IF vr_tpregist NOT IN( 'C', 'B') THEN
                        pc_critica_debito_cooperativa(1, rw_gnconve.cdhisdeb, vr_tab_nmarquiv(i));
                        -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                      END IF;
                      continue;
                      END IF;
                    END IF;
                    
                    -- Se a agencia de debito for diferente da agencia de controle
                    -- e agencia de debito for diferente de 001(viacredi) ou cooperativa do processo
                    -- for diferente de Viacredi então vamos ignorar o registro
                    -- e agencia de debito nao for casan e samae timbo 
                    IF vr_cdagedeb NOT IN(1294,23) THEN
                    IF vr_cdagedeb <> rw_crapcop.cdagectl 
                       AND (vr_cdagedeb <> 1 OR rw_crapcop.cdcooper <> 1) THEN
                      continue;
                    END IF;
                    END IF;
                    
                  /*  -- Se a cooperativa do processo for diferente da cooperativa do convenio e se for diferente de Viacredi
                    -- ignora o registro
                    IF rw_crapcop.cdcooper <> rw_gnconve.cdcooper AND
                       rw_crapcop.cdcooper <> 1 THEN
                      continue;
                    ELSIF rw_crapcop.cdcooper = 3 THEN -- Se for Cecred
                      continue;
                    END IF; */

                    /**** Tratamento migracao ****/
                    OPEN cr_craptco(vr_nrdconta);
                    FETCH cr_craptco INTO rw_craptco;
                    IF cr_craptco%FOUND THEN -- Se for uma conta transferida
                      -- Busca o numero do lote
                      vr_dstextab_2 := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_craptco.cdcooper
                                                                 ,pr_nmsistem => 'CRED'
                                                                 ,pr_tptabela => 'GENERI'
                                                                 ,pr_cdempres => 00
                                                                 ,pr_cdacesso => 'LOTEINT031'
                                                                 ,pr_tpregist => 001);
                      -- Retornar nome do módulo logado - Chamado INC0011662 - 28/03/2018
                      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => null);
                      vr_flg_ctamigra := TRUE;
                      vr_flg_migracao := TRUE;
                      vr_cdcooper := rw_craptco.cdcooper;
                      vr_cdcoptab := rw_craptco.cdcooper;
                      vr_nrdconta := rw_craptco.nrdconta;
                      vr_nrdolote := vr_dstextab_2;
                    ELSE -- Se nao for uma conta transferida
                      vr_cdcooper := pr_cdcooper;
                      vr_nrdolote := vr_dstextab;
                    END IF;
                    CLOSE cr_craptco;
                    
                    -- Se agencia do debito for 0023 (Samae Timbo) e cooperativa nao for viacredi
                    -- devemos ignorar
                    IF vr_cdagedeb = 23 AND rw_crapcop.cdcooper <> 1 THEN
                      continue;
                    END IF;
                    
                    -- Não validar agencia para a casan na cecred
                    IF vr_cdagedeb = 1294 AND rw_crapcop.cdcooper = 3 THEN
                      continue;
                    END IF;
                    
                     -- Verificacao especifica da casan
                    IF vr_cdagedeb = 1294 THEN                    
                      
                      -- processar registros da casan somente na cooperativa em questao
                      IF vr_cdcooper <> rw_crapcop.cdcooper THEN
                        continue;
                      END IF;    
                                
                      -- Abre o cursor de associados
                      IF cr_crapass%ISOPEN THEN
                        CLOSE cr_crapass;
                      END IF;
                      -- verificar se a conta pertence a cooperativa que esta rodando
                      OPEN cr_crapass(vr_cdcooper, vr_nrdconta, 0);
                      FETCH cr_crapass INTO rw_crapass;
                      
                      IF cr_crapass%FOUND THEN
                        CLOSE cr_crapass;
                        
                        -- Cadastro das autorizacoes de debito em conta
                        IF cr_crapatr%ISOPEN THEN
                          CLOSE cr_crapatr;
                        END IF;
                        
                        -- se encontrou conta na cooperativa do processo, verificar se referencia
                        -- tambem pertence a esta conta
                        OPEN cr_crapatr(vr_cdcooper, vr_nrdconta, rw_gnconve.cdhisdeb, vr_cdrefere);
                        FETCH cr_crapatr INTO rw_crapatr;
                        
                        IF cr_crapatr%NOTFOUND THEN
                          CLOSE cr_crapatr;                                                
                          continue;
                        ELSE
                          -- se referencia pertence a esta conta, segue o programa normalmente
                          CLOSE cr_crapatr;                                                                        
                        END IF;
                      ELSE
                        -- Se conta nao for da cooperativa do processo, pula para o proximo registro
                        CLOSE cr_crapass;
                        continue;
                      END IF;
                    END IF;
                  ELSE
                    /* Posicao 31,1(aux_setlinha possue 9) */

                     vr_cdcooper := SUBSTR(vr_nro_conta_tam,2,3);

                     vr_nrdconta := SUBSTR(vr_nro_conta_tam,5,10);

                     IF rw_crapcop.cdcooper = 3 AND -- se for Cecred
                        ((vr_cdcooper) < 1 OR                  -- Cooperativa de transferencia nao existir
                         (vr_cdcooper) > vr_cdultcop) THEN
                       -- Somente ira gerar crapndb caso o registro não seja do tipo "C" e "B"
                       IF vr_tpregist NOT IN( 'C', 'B') THEN
                         pc_critica_debito_cooperativa(1, rw_gnconve.cdhisdeb, vr_tab_nmarquiv(i));
                         -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                         GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                       END IF;
                       continue;
                     END IF;

                     IF rw_crapcop.cdcooper <> vr_cdcooper THEN

                       /**** Tratamento incorporacao ****/
                       IF cr_craptco_conta_incorporada%ISOPEN THEN
                         CLOSE cr_craptco_conta_incorporada;
                       END IF;

                       OPEN cr_craptco_conta_incorporada(pr_cdcooper => pr_cdcooper,
                                                         pr_cdcopant => vr_cdcooper,
                                                         pr_nrdconta => vr_nrdconta);
                       FETCH cr_craptco_conta_incorporada INTO rw_craptco_conta_incorporada;

                       IF cr_craptco_conta_incorporada%FOUND THEN -- Se for uma conta transferida
                         vr_flg_ctamigra := TRUE;
                         vr_nrdconta := rw_craptco_conta_incorporada.nrdconta;
                       ELSE
                         OPEN cr_craptco_coop(pr_cdcooper => pr_cdcooper,
                                              pr_cdcopant => vr_cdcooper);                                              
                         FETCH cr_craptco_coop INTO rw_craptco_coop;
                         
                         IF cr_craptco_coop%FOUND THEN                                                  
                            CLOSE cr_craptco_coop;
                            -- Somente ira gerar crapndb caso o registro não seja do tipo "C" e "B"
                            IF vr_tpregist NOT IN( 'C', 'B') THEN
                               vr_cdcooper := pr_cdcooper;
                               pc_critica_debito_cooperativa(2, rw_gnconve.cdhisdeb, vr_tab_nmarquiv(i));
                               -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                               GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                            END IF;

                            CONTINUE; /* Nao pertence a Cooperativa que estou rodando...*/
                         END IF;
                         
                         CLOSE cr_craptco_coop;
                         CONTINUE;
                       END IF;
                     END IF;

                    /**** Tratamento migracao ****/
                    OPEN cr_craptco(vr_nrdconta);
                    FETCH cr_craptco INTO rw_craptco;
                    IF cr_craptco%FOUND THEN -- Se for uma conta transferida
                      /* Se a cooperativa do registro atual eh diferente da cooperativa
                         que esta rodando no momento, entao despreza o registro. */
                      IF rw_craptco.cdcooper <> vr_cdcooper THEN
                        CLOSE cr_craptco;
                        continue;
                      END IF;

                      -- Busca o numero do lote
                      vr_dstextab_2 := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_craptco.cdcooper
                                                                 ,pr_nmsistem => 'CRED'
                                                                 ,pr_tptabela => 'GENERI'
                                                                 ,pr_cdempres => 00
                                                                 ,pr_cdacesso => 'LOTEINT031'
                                                                 ,pr_tpregist => 001);
                      -- Retornar nome do módulo logado - Chamado INC0011662 - 28/03/2018
                      GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => null);
                      vr_flg_ctamigra := TRUE;
                      vr_flg_migracao := TRUE;
                      vr_cdcooper := rw_craptco.cdcooper;
                      vr_cdcoptab := rw_craptco.cdcooper;
                      vr_nrdconta := rw_craptco.nrdconta;
                      vr_nrdolote := vr_dstextab_2;
                    ELSE -- Se nao for uma conta transferida
                      vr_cdcooper := pr_cdcooper;
                      vr_nrdolote := vr_dstextab;
                    END IF;
                    CLOSE cr_craptco;
                  END IF;

                  -- Verifica se o numero da conta eh invalido
                  IF vr_nrdconta >= 100000000 THEN
                    -- Somente ira gerar crapndb caso o registro não seja do tipo "C" e "B"
                    IF vr_tpregist NOT IN( 'C', 'B') THEN
                      pc_critica_debito_cooperativa(2, rw_gnconve.cdhisdeb, vr_tab_nmarquiv(i));
                      -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                    END IF;
                    continue;
                  END IF;

                  LOOP
                    -- Abre o cursor de associados
                    IF cr_crapass%ISOPEN THEN
                      CLOSE cr_crapass;
                    END IF;
                    OPEN cr_crapass(vr_cdcooper, vr_nrdconta, 0);
                    FETCH cr_crapass INTO rw_crapass;

                    -- Se nao encontrar o associado sai do loop
                    IF cr_crapass%NOTFOUND THEN
                      CLOSE cr_crapass;
                      EXIT;
                    ELSE
                      IF rw_crapass.cdsitdtl IN (2,4,6,8) THEN

                        -- abre o cursor sobre os dados de transferencia e duplicacao de matricula
                        OPEN cr_craptrf(vr_cdcooper, rw_crapass.nrdconta);
                        FETCH cr_craptrf INTO rw_craptrf;
                        -- Se nao encontrou sai do loop
                        IF cr_craptrf%NOTFOUND THEN
                          CLOSE cr_crapass;
                          CLOSE cr_craptrf;
                          -- ATRIBUI O CODIGO DA CRITICA
                          vr_cdcritic := 95;                                                    -- TITULAR DA CONTA BLOQUEADO
                          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic); -- BUSCA DESCRICAO DA CRITICA

                          -- Não devemos criar crapndb para registro C e B
                          IF vr_tpregist NOT IN( 'C', 'B') THEN                          
                            vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                            -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                            GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                          
                          -- Para cada regitro D rejeitado, retornamos o H
                          IF vr_tpregist = 'D' THEN 
                              vr_dstexarq := 'H' ||SUBSTR(vr_setlinha,2,68) || RPAD(vr_dscritic,80) || SUBSTR(vr_setlinha,150,1);
                          ELSE
                            vr_dstexarq := 'F'||SUBSTR(vr_setlinha,2,66)||'04'||SUBSTR(vr_setlinha,70,81);
                          END IF;
                          
                          -- Arquivo com os registros de debito com referencia zeradas
                          BEGIN
                            INSERT INTO crapndb
                              (dtmvtolt,
                               nrdconta,
                               cdhistor,
                               flgproce,
                               dstexarq,
                               cdcooper)
                             VALUES
                              (vr_dtultdia,
                               vr_nrdconta,
                               rw_gnconve.cdhisdeb,
                               0,
                               vr_dstexarq,
                               vr_cdcooper);
                          EXCEPTION
                            WHEN OTHERS THEN
                              -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                              -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                              vr_cdcritic := 1034;
                              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                             ||'CRAPNDB(9): dtmvtolt:'||vr_dtultdia
                                             ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                             ||', flgproce:0, dstexarq:' ||vr_dstexarq||', cdcooper:'||vr_cdcooper
                                             ||'. '||SQLERRM;
                              RAISE vr_exc_saida;
                          END;
                          END IF;
                          -- monta a chave para a pl_table vr_tab_relato
                          vr_nrseq := vr_nrseq + 1;
                          vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                    lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                          vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                          vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                          vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                          IF vr_cdcritic <> 13 THEN
                            vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                          END IF;
                          vr_tab_relato(vr_ind).nrdctabb := 0;
                          vr_tab_relato(vr_ind).cdcritic := vr_cdcritic;
                          vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                          vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                          vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                          vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);

                          vr_flgrejei     := TRUE;
                        ELSE
                          vr_nrdconta := rw_craptrf.nrsconta;
                          CLOSE cr_crapass;
                          CLOSE cr_craptrf;
                          continue;
                        END IF;
                      END IF;
                    END IF;
                    EXIT;
                  END LOOP;

                  -- Abre o cursor de associados
                  IF cr_crapass%ISOPEN THEN
                    CLOSE cr_crapass;
                  END IF;
                  OPEN cr_crapass(vr_cdcooper, vr_nrdconta, 0);
                  FETCH cr_crapass INTO rw_crapass;

                  -- Se a linha for referente ao corpo do arquivo
                  IF vr_tpregist = 'E' THEN
                    vr_diarefer := SUBSTR(vr_setlinha,51,2);
                    vr_mesrefer := SUBSTR(vr_setlinha,49,2);
                    vr_anorefer := SUBSTR(vr_setlinha,45,4);

                    BEGIN
                      vr_dtrefere := to_date(lpad(vr_diarefer,2,'0')||lpad(vr_mesrefer,2,'0')||vr_anorefer,'ddmmyyyy');
                      vr_dtrefere := gene0005.fn_valida_dia_util(vr_cdcooper, vr_dtrefere, 'P');
                    EXCEPTION
                      WHEN OTHERS THEN
                        vr_cdcritic := 13; -- Data invalida
                    END;

                    -- Se nao existir criticas
                    IF vr_cdcritic = 0 THEN
                      -- Data de referencia nao pode ser inferior a data de processo
                      IF vr_dtrefere <= rw_crapdat.dtmvtolt THEN
                        pc_critica_debito_cooperativa(3, rw_gnconve.cdhisdeb, vr_tab_nmarquiv(i));
                        -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                        continue;
                      END IF;
                    END IF;
                  END IF;             

                  IF vr_tpregist = 'E' THEN
                    
                    /*** Tratamento para codigo de referencia zerado ***/
                    IF to_number(SUBSTR(vr_setlinha,02,25)) = 0 THEN
                      -- Caso a referencia do arquivo vier zerada, devera gerar crapndb
                      vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                      -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

                      -- Arquivo com os registros de debito com referencia zeradas
                      BEGIN
                        INSERT INTO crapndb
                          (dtmvtolt,
                           nrdconta,
                           cdhistor,
                           flgproce,
                           dstexarq,
                           cdcooper)
                         VALUES
                          (vr_dtultdia,
                           vr_nrdconta,
                           rw_gnconve.cdhisdeb,
                           0,
                           'F'||SUBSTR(vr_setlinha,2,66)||'30'||SUBSTR(vr_setlinha,70,81),
                           vr_cdcooper);
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1034;
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'CRAPNDB(10): dtmvtolt:'  ||vr_dtultdia
                                         ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                         ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'30'||SUBSTR(vr_setlinha,70,81)
                                         ||', cdcooper:'||vr_cdcooper
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;

                      -- monta a chave para a pl_table vr_tab_relato
                      vr_nrseq := vr_nrseq + 1;
                      vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                      vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                      vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                      vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                      IF vr_cdcritic <> 13 THEN
                        vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                      END IF;
                      vr_tab_relato(vr_ind).nrdctabb := 0;
                      vr_tab_relato(vr_ind).cdcritic := 453;
                      vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                      vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                      vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                      vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);

                      vr_flgrejei     := TRUE;

                      continue; -- Vai para a proxima linha do arquivo
                   
                    --Se convênio utiliza layout FEBRABAN na versão 5
                    ELSIF rw_gnconve.nrlayout = 5 THEN
                        
                      IF cr_crapass%FOUND THEN                                                
                        
                        BEGIN 
                          vr_nrcpfcgc  := nvl(to_number(TRIM(SUBSTR(vr_setlinha,131,15))),0);
                          vr_tppesssoa := nvl(to_number(TRIM(SUBSTR(vr_setlinha,130,1))),0);
                                  
                        EXCEPTION
                          WHEN OTHERS THEN
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);      
                            -- Caso a referencia do arquivo vier zerada, devera gerar crapndb
                            vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                            -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                            GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                                  
                            -- Arquivo com os registros de debito com referencia zeradas
                            BEGIN
                              INSERT INTO crapndb
                                (dtmvtolt,
                                 nrdconta,
                                 cdhistor,
                                 flgproce,
                                 dstexarq,
                                 cdcooper)
                               VALUES
                                (vr_dtultdia,
                                 vr_nrdconta,
                                 rw_gnconve.cdhisdeb,
                                 0,
                                 'F'||SUBSTR(vr_setlinha,2,66)||'19'||SUBSTR(vr_setlinha,70,81),
                                 vr_cdcooper);
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPNDB(11): dtmvtolt:'  ||vr_dtultdia
                                               ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                               ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'19'||SUBSTR(vr_setlinha,70,81)
                                               ||', cdcooper:'||vr_cdcooper
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;

                            -- monta a chave para a pl_table vr_tab_relato
                            vr_nrseq := vr_nrseq + 1;
                            vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                      lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                            vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                            vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                            vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                                  
                            IF vr_cdcritic <> 13 THEN
                              vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                            END IF;
                                  
                            vr_tab_relato(vr_ind).nrdctabb := 0;
                            vr_tab_relato(vr_ind).cdcritic := 1001; --CPF/CNPJ Informado Diverge da Conta Corrente.
                            vr_tab_relato(vr_ind).dscritic := ' -> ' || TRIM(SUBSTR(vr_setlinha,131,15));
                            vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                            vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                            vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                            vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);

                            vr_flgrejei     := TRUE;

                            continue; -- Vai para a proxima linha do arquivo*/
                            
                        END;
                          
                        /*** Se o número do CPF não veio no arquivo ***/
                        IF vr_nrcpfcgc  = 0 OR
                           vr_tppesssoa = 0 THEN
                            
                          -- Caso a referencia do arquivo vier zerada, devera gerar crapndb
                          vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                          -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                          GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                            
                          -- Arquivo com os registros de debito com referencia zeradas
                          BEGIN
                            INSERT INTO crapndb
                              (dtmvtolt,
                               nrdconta,
                               cdhistor,
                               flgproce,
                               dstexarq,
                               cdcooper)
                             VALUES
                              (vr_dtultdia,
                               vr_nrdconta,
                               rw_gnconve.cdhisdeb,
                               0,
                               'F'||SUBSTR(vr_setlinha,2,66)||'19'||SUBSTR(vr_setlinha,70,81),
                               vr_cdcooper);
                          EXCEPTION
                            WHEN OTHERS THEN
                              -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                              -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                              vr_cdcritic := 1034;
                              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                             ||'CRAPNDB(12): dtmvtolt:'  ||vr_dtultdia
                                             ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                             ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'19'||SUBSTR(vr_setlinha,70,81)
                                             ||', cdcooper:'||vr_cdcooper
                                             ||'. '||SQLERRM;
                              RAISE vr_exc_saida;
                          END;

                          -- monta a chave para a pl_table vr_tab_relato
                          vr_nrseq := vr_nrseq + 1;
                          vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                    lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                          vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                          vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                          vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                            
                          IF vr_cdcritic <> 13 THEN
                            vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                          END IF;
                            
                          vr_tab_relato(vr_ind).nrdctabb := 0;
                          vr_tab_relato(vr_ind).cdcritic := 1002; --CPF/CNPJ Não Enviado
                          vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                          vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                          vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                          vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);

                          vr_flgrejei     := TRUE;

                          continue; -- Vai para a proxima linha do arquivo                          
                        
                        ELSE
                                 
                          vr_cpfvalido := TRUE;
                          
                          IF NOT vr_tppesssoa IN(1,2)                       OR 
                            (vr_tppesssoa = 1 AND rw_crapass.inpessoa <> 2) OR
                            (vr_tppesssoa = 2 AND rw_crapass.inpessoa <> 1) THEN
                                    
                            vr_cpfvalido := FALSE;
                                    
                          ELSIF vr_tppesssoa = 2 THEN
                                  
                            -- Valida CPF enviado
                            GENE0005.pc_valida_cpf(pr_nrcalcul => vr_nrcpfcgc   --Numero a ser verificado
                                                  ,pr_stsnrcal => vr_stsnrcal);   --Situacao
                                    
                            IF NOT vr_stsnrcal THEN
                                      
                              vr_cpfvalido := FALSE;
                                      
                            ELSE
                                    
                              OPEN cr_crapttl(pr_cdcooper => vr_cdcooper
                                             ,pr_nrdconta => vr_nrdconta
                                             ,pr_nrcpfcgc => vr_nrcpfcgc);
                                                     
                              FETCH cr_crapttl INTO rw_crapttl;
                                      
                              IF cr_crapttl%NOTFOUND THEN

                                vr_cpfvalido := FALSE;
                                        
                              END IF;
                                      
                              CLOSE cr_crapttl;
                                    
                            END IF;
                                  
                          ELSE 
                                      
                             -- Valida CPF/CNPJ enviado
                             GENE0005.pc_valida_cnpj(pr_nrcalcul => vr_nrcpfcgc   --Numero a ser verificado
                                                    ,pr_stsnrcal => vr_stsnrcal);   --Situacao
                                          
                             IF NOT vr_stsnrcal THEN
                                       
                               vr_cpfvalido := FALSE;
                                       
                             ELSIF rw_crapass.nrcpfcgc <> vr_nrcpfcgc THEN
                                     
                               vr_cpfvalido := FALSE;
                                       
                            END IF;
                                                 
                          END IF;
                                    
                          /*** Se o cpf for devergen a conta  ***/
                          IF NOT vr_cpfvalido THEN
                                  
                            -- Caso a referencia do arquivo vier zerada, devera gerar crapndb
                            vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                            -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                            GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                                  
                            -- Arquivo com os registros de debito com referencia zeradas
                            BEGIN
                              INSERT INTO crapndb
                                (dtmvtolt,
                                 nrdconta,
                                 cdhistor,
                                 flgproce,
                                 dstexarq,
                                 cdcooper)
                               VALUES
                                (vr_dtultdia,
                                 vr_nrdconta,
                                 rw_gnconve.cdhisdeb,
                                 0,
                                 'F'||SUBSTR(vr_setlinha,2,66)||'19'||SUBSTR(vr_setlinha,70,81),
                                 vr_cdcooper);
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);    
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPNDB(13): dtmvtolt:'  ||vr_dtultdia
                                               ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                               ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'19'||SUBSTR(vr_setlinha,70,81)
                                               ||', cdcooper:'||vr_cdcooper
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;

                            -- monta a chave para a pl_table vr_tab_relato
                            vr_nrseq := vr_nrseq + 1;
                            vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                      lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                            vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                            vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                            vr_tab_relato(vr_ind).contrato := SUBSTR(vr_setlinha,02,25);
                                  
                            IF vr_cdcritic <> 13 THEN
                              vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                            END IF;
                                  
                            vr_tab_relato(vr_ind).nrdctabb := 0;
                            vr_tab_relato(vr_ind).cdcritic := 1001; --CPF/CNPJ Informado Diverge da Conta Corrente.
                            vr_tab_relato(vr_ind).dscritic := ' -> ' || TRIM(SUBSTR(vr_setlinha,131,15));
                            vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                            vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                            vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                            vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);

                            vr_flgrejei     := TRUE;

                            continue; -- Vai para a proxima linha do arquivo*/
                                                            
                          END IF;
                          
                        END IF;
                        
                      END IF;
                       
                    END IF;
                   
                  END IF;
                                    
                  -- Cadastro das autorizacoes de debito em conta
                  IF cr_crapatr%ISOPEN THEN
                    CLOSE cr_crapatr;
                  END IF;
                  rw_crapatr := NULL;
                  OPEN cr_crapatr(vr_cdcooper, vr_nrdconta, rw_gnconve.cdhisdeb, vr_cdrefere);
                  FETCH cr_crapatr INTO rw_crapatr;

                  IF ((cr_crapatr%FOUND AND rw_crapatr.dtfimatr IS NOT NULL) OR
                      (cr_crapatr%NOTFOUND)                                  OR
                      (cr_crapass%FOUND AND rw_crapass.dtdemiss IS NOT NULL) OR
                      (cr_crapass%NOTFOUND))                                 AND
                      vr_tpregist <> 'B'                                     THEN
                    IF rw_gnconve.flgindeb = 1 AND
                       vr_tpregist     = 'E'   AND
                       cr_crapass%FOUND        AND                       
                       cr_crapatr%NOTFOUND     AND 
                       rw_crapass.dtdemiss IS NULL THEN -- Somente cooperados ativos
                         -- Insere no Cadastro das autorizacoes de debito em conta
                         BEGIN
                            INSERT INTO crapatr
                              (cdcooper,
                               nrdconta,
                               cdhistor,
                               cdrefere,
                               cddddtel,
                               ddvencto,
                               dtiniatr,
                               dtultdeb,
                               nmfatura,
                               dtfimatr,
                               nmempres)
                             VALUES
                              (vr_cdcooper,
                               vr_nrdconta,
                               rw_gnconve.cdhisdeb,
                               vr_cdrefere,
                               0,
                               1,
                               rw_crapdat.dtmvtolt,
                               NULL,
                               rw_crapass.nmprimtl,
                               NULL,
                               rw_gnconve.nmempres)
                             RETURNING dtfimatr,
                                       dtiniatr,
                                       nmfatura,
                                       ddvencto,
                                       nrdconta,
                                       flgmaxdb,
                                       vlrmaxdb,
                                       cdrefere,
                                       cdhistor,
                                       ROWID
                                  INTO rw_crapatr.dtfimatr,
                                       rw_crapatr.dtiniatr,
                                       rw_crapatr.nmfatura,
                                       rw_crapatr.ddvencto,
                                       rw_crapatr.nrdconta,
                                       rw_crapatr.flgmaxdb,
                                       rw_crapatr.vlrmaxdb,
                                       rw_crapatr.cdrefere,
                                       rw_crapatr.cdhistor,
                                       rw_crapatr.ROWID;                                       
                         EXCEPTION
                           WHEN OTHERS THEN
                              -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                              -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                              vr_cdcritic := 1034;
                              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                             ||'CRAPATR(1): cdcooper:'  ||vr_cdcooper
                                             ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                             ||', cdrefere:'||vr_cdrefere||', cddddtel:0, ddvencto:1'
                                             ||', dtiniatr:'||rw_crapdat.dtmvtolt
                                             ||', dtultdeb: NULL, nmfatura:'||rw_crapass.nmprimtl
                                             ||', dtfimatr: NULL, nmempres:'||rw_gnconve.nmempres
                                             ||'. '||SQLERRM;
                              RAISE vr_exc_saida;
                         END;

                      -- monta a chave para a pl_table vr_tab_relato
                      vr_nrseq := vr_nrseq + 1;
                      vr_ind := '0000000004'|| lpad(vr_nrdconta,10,'0') ||
                                lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                      /*** Mostra no relatorio que houve inclusao ***/
                      vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                      vr_tab_relato(vr_ind).nmprimtl := rw_crapass.nmprimtl;
                      vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                      vr_tab_relato(vr_ind).operacao := TRUE;
                      vr_tab_relato(vr_ind).tpintegr :=  4;

                    ELSE

                      IF vr_tpregist = 'E' THEN
                        vr_tpintegr := 3; /* fatura rejeitada */
                      ELSIF  vr_tpregist = 'C' THEN
                        vr_tpintegr := 1; /* alt. rejeitada */
                      ELSIF vr_tpregist = 'D' THEN
                        vr_tpintegr := 2; /* alt. integrada */
                      ELSE
                        vr_tpintegr := 0;
                      END IF;

                      vr_dstexarq_tmp := '30';
                      IF cr_crapass%NOTFOUND  THEN  
                        vr_cdcritic_tmp := 127; -- Conta Errada
                        vr_dstexarq_tmp := '15';
                      ELSIF cr_crapass%FOUND AND rw_crapass.dtdemiss IS NOT NULL THEN
                        vr_cdcritic_tmp := 64; -- Conta Encerrada
                        vr_dstexarq_tmp := '15';
                      ELSIF cr_crapatr%NOTFOUND THEN /*Autoriz.nao encontrada*/
                        vr_cdcritic_tmp := 453;
                      ELSE                       /*Autorizacao cancelada.*/
                        vr_cdcritic_tmp := 447;
                      END IF;

                      -- monta a chave para a pl_table vr_tab_relato
                      vr_nrseq := vr_nrseq + 1;
                      vr_ind := lpad(vr_cdcritic_tmp,5,'0')||lpad(vr_tpintegr,5,'0')|| lpad(vr_nrdconta,10,'0') ||
                                lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                      vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                      vr_tab_relato(vr_ind).nrdconta := vr_nro_conta_dec;
                      vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                      vr_tab_relato(vr_ind).cdcritic := vr_cdcritic_tmp;
                      vr_tab_relato(vr_ind).tpintegr := vr_tpintegr;

                      IF vr_tpregist = 'C' THEN
                        vr_tab_relato(vr_ind).nrdctabb := SUBSTR(vr_setlinha,150,1);
                      ELSE
                        vr_tab_relato(vr_ind).nrdctabb := 0;
                      END IF;

                      IF vr_tpregist = 'E' THEN
                        vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                        vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                      ELSE
                        vr_tab_relato(vr_ind).vllanmto := 0;
                      END IF;

                      IF vr_tpregist = 'E' THEN
                        vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                        vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                      ELSIF vr_tpregist = 'C' THEN
                        vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,45,40);
                        vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,85,40);
                      ELSE
                        vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                        vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                      END IF;

                      IF vr_tpregist = 'E' THEN

                        vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

                        -- Arquivo com os registros de debito em conta nao efetuados (via febraban).
                        BEGIN
                          INSERT INTO crapndb
                            (dtmvtolt,
                             nrdconta,
                             cdhistor,
                             flgproce,
                             dstexarq,
                             cdcooper)
                           VALUES
                            (vr_dtultdia,
                             vr_nrdconta,
                             rw_gnconve.cdhisdeb,
                             0,
                             'F'||SUBSTR(vr_setlinha,2,66)||vr_dstexarq_tmp||SUBSTR(vr_setlinha,70,81),
                             vr_cdcooper);
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPNDB(15): dtmvtolt:'  ||vr_dtultdia
                                           ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                           ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||vr_dstexarq_tmp||SUBSTR(vr_setlinha,70,81)
                                           ||', cdcooper:'||vr_cdcooper
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;

                      END IF;  /* aux_tpregist = "E" */

                      vr_flgrejei := TRUE;

                      CLOSE cr_crapatr;
                      continue; -- Volta para a proxima linha

                    END IF;

                  END IF;  /* vr_tpregist <> "B" */

                  IF vr_tpregist = 'C' THEN
                    -- monta a chave para a pl_table vr_tab_relato
                    vr_nrseq := vr_nrseq + 1;
                    vr_ind := '0000000001'|| lpad(vr_nrdconta,10,'0') ||
                              lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                    vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                    vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                    vr_tab_relato(vr_ind).contrato := vr_cdrefere ;
                    vr_tab_relato(vr_ind).dtmvtolt := NULL;
                    vr_tab_relato(vr_ind).nrdctabb := SUBSTR(vr_setlinha,150,1);
                    vr_tab_relato(vr_ind).cdcritic := 0;
                    vr_tab_relato(vr_ind).vllanmto := 0;
                    vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,45,40);
                    vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,85,40);
                    vr_tab_relato(vr_ind).tpintegr := 1;  /*Total altera REJEITADOS*/

                    vr_flgrejei := TRUE;

                    IF cr_crapatr%FOUND THEN
                      IF SUBSTR(vr_setlinha,150,1) <> '1' THEN
                        rw_crapatr.dtfimatr := vr_dtcancel;
                        BEGIN
                          UPDATE crapatr
                             SET crapatr.dtfimatr = vr_dtcancel
                           WHERE ROWID = rw_crapatr.rowid;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1035;   
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPATR(1): dtfimatr:'||vr_dtcancel
                                           ||', rowid:'||rw_crapatr.rowid
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      END IF;
                    END IF;

                    continue;
                  ELSIF vr_tpregist = 'D' THEN
                    -- monta a chave para a pl_table vr_tab_relato
                    vr_nrseq := vr_nrseq + 1;
                    vr_ind := '0000000002'|| lpad(vr_nrdconta,10,'0') ||
                              lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');


                    vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                    vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                    vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                    vr_tab_relato(vr_ind).dtmvtolt := NULL;
                    vr_tab_relato(vr_ind).nrdctabb := 0;
                    vr_tab_relato(vr_ind).cdcritic := 0;
                    vr_tab_relato(vr_ind).vllanmto := 0;
                    vr_tab_relato(vr_ind).tpintegr := 2; /* Alteracao integrada */
                    vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                    vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,70,60);

                    vr_flgrejei := TRUE;

                    IF SUBSTR(vr_setlinha,150,1) = 1 THEN
                      IF rw_crapatr.dtfimatr IS NULL THEN
                        rw_crapatr.dtfimatr := vr_dtcancel;
                        BEGIN
                          UPDATE crapatr
                             SET crapatr.dtfimatr = vr_dtcancel
                           WHERE ROWID = rw_crapatr.rowid;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1035;   
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPATR(2): dtfimatr:'||vr_dtcancel
                                           ||', rowid:'||rw_crapatr.rowid
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      END IF;
                    ELSIF SUBSTR(vr_setlinha,150,1) = 0 THEN
                      -- Abre o cursor de cadastro das autorizacoes de debito em conta
                      OPEN cr_crapatr_2(vr_cdcooper, vr_nrdconta, rw_gnconve.cdhisdeb, SUBSTR(vr_setlinha,45,25));
                      FETCH cr_crapatr_2 INTO rw_crapatr_2;
                      IF cr_crapatr_2%FOUND THEN
                        /* Tira canc. */
                        rw_crapatr_2.dtfimatr := NULL;
                        BEGIN
                          UPDATE crapatr
                             SET dtfimatr = NULL
                           WHERE ROWID = rw_crapatr_2.rowid;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1035;   
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPATR(3): dtfimatr:NULL'
                                           ||', rowid:'||rw_crapatr_2.rowid
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      ELSE
                        /*  Nao existe registro anterior  */
                        BEGIN
                          INSERT INTO crapatr
                            (nrdconta,
                             cdrefere,
                             cddddtel,
                             cdhistor,
                             ddvencto,
                             dtiniatr,
                             dtultdeb,
                             nmfatura,
                             dtfimatr,
                             cdcooper)
                           VALUES
                            (rw_crapatr.nrdconta,
                             SUBSTR(vr_setlinha,45,25),
                             0,
                             rw_gnconve.cdhisdeb,
                             rw_crapatr.ddvencto,
                             rw_crapatr.dtiniatr,
                             NULL,
                             rw_crapatr.nmfatura,
                             rw_crapatr.dtfimatr,
                             vr_cdcooper)
                           RETURNING dtfimatr,
                                     ROWID
                                INTO rw_crapatr_2.dtfimatr,
                                     rw_crapatr_2.ROWID;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPATR(2): nrdconta:'||rw_crapatr.nrdconta
                                           ||', cdrefere:'||SUBSTR(vr_setlinha,45,25)||', cddddtel:0'
                                           ||', cdhistor:'||rw_gnconve.cdhisdeb||', ddvencto:'||rw_crapatr.ddvencto
                                           ||', dtiniatr:'||rw_crapatr.dtiniatr||', dtultdeb:NULL'
                                           ||', nmfatura:'||rw_crapatr.nmfatura||', dtfimatr:'||rw_crapatr.dtfimatr
                                           ||', cdcooper:'||vr_cdcooper
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      END IF;
                      CLOSE cr_crapatr_2;

                      -- Finaliza a autorizacao de debito em conta
                      rw_crapatr.dtfimatr := vr_dtcancel;
                      BEGIN
                        UPDATE crapatr
                           SET dtfimatr = vr_dtcancel
                         WHERE ROWID = rw_crapatr.rowid;
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1035;   
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'CRAPATR(4): dtfimatr:'||vr_dtcancel
                                         ||', rowid:'||rw_crapatr.rowid
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;

                      vr_tab_relato(vr_ind).ocorrencia := TRIM(substr(vr_setlinha,45,25));

                      /* Verifica se existe lancamento automatico para
                         a fatura e atualiza o numero */
                      BEGIN
                        UPDATE craplau
                           SET nrdocmto = SUBSTR(vr_setlinha,45,25)
                         WHERE cdcooper = vr_cdcooper
                           AND nrdconta = rw_crapatr.nrdconta
                           AND dtmvtolt >= rw_crapdat.dtmvtolt
                           AND nrdocmto  = vr_cdrefere
                           AND insitlau  = 1
                           AND dsorigem <> 'CAIXA'
                           AND dsorigem <> 'INTERNET'
                           AND dsorigem <> 'TAA'
                           AND dsorigem <> 'PG555'
                           AND dsorigem <> 'CARTAOBB'
                           AND dsorigem <> 'BLOQJUD'
                           AND dsorigem <> 'DAUT BANCOOB';
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1035;   
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'CRAPLAU(2): nrdocmto:'||SUBSTR(vr_setlinha,45,25)
                                         ||', cdcooper:'||vr_cdcooper
                                         ||', nrdconta:'||rw_crapatr.nrdconta||', dtmvtolt >:'||rw_crapdat.dtmvtolt
                                         ||', nrdocmto:'||vr_cdrefere||', insitlau = 1'
                                         ||', dsorigem <> CAIXA, INTERNET, TAA, PG555, CARTAOBB, BLOQJUD, DAUT BANCOOB'
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;
                    END IF;
                    continue; -- Vai para a proxima linha do arquivo

                  ELSIF vr_tpregist = 'E' THEN -- Corpo do arquivo
                     
                    IF vr_cdcritic = 0 THEN

                      IF SUBSTR(vr_setlinha,53,15) = 0 THEN
                        vr_cdcritic := 502;

                        vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                        -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                        GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

                        -- Insere registro no arquivo com os registros de debito em conta nao efetuados (via febraban).
                        BEGIN
                          INSERT INTO crapndb
                            (dtmvtolt,
                             nrdconta,
                             cdhistor,
                             flgproce,
                             dstexarq,
                             cdcooper)
                          VALUES
                            (vr_dtultdia,
                             vr_nrdconta,
                             rw_gnconve.cdhisdeb,
                             0,
                             'F' ||SUBSTR(vr_setlinha,2,66) || '96' || SUBSTR(vr_setlinha,70,81),
                             vr_cdcooper);
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPNDB(16): dtmvtolt:'  ||vr_dtultdia
                                           ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                           ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'96'||SUBSTR(vr_setlinha,70,81)
                                           ||', cdcooper:'||vr_cdcooper
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;

                        -- monta a chave para a pl_table vr_tab_relato
                        vr_nrseq := vr_nrseq + 1;
                        vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                  lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                        vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                        vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                        vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                        IF vr_cdcritic <> 13 THEN
                          vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                        END IF;
                        vr_tab_relato(vr_ind).nrdctabb := 0;
                        vr_tab_relato(vr_ind).cdcritic := vr_cdcritic;
                        vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                        vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                        vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                        vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);

                        vr_flgrejei     := FALSE;

                        continue; -- Vai para a proxima linha do arquivo

                      END IF;
                      
                    END IF;

                    -- Se nao tiver ocorrido erros, processa a linha
                    IF vr_cdcritic <> 0 THEN
                      -- monta a chave para a pl_table vr_tab_relato
                      vr_nrseq := vr_nrseq + 1;
                      vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                      vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                      vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                      vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                      IF vr_cdcritic <> 13 THEN
                        vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                      END IF;
                      vr_tab_relato(vr_ind).nrdctabb := 0;
                      vr_tab_relato(vr_ind).cdcritic := vr_cdcritic;
                      vr_tab_relato(vr_ind).tpintegr := 3;  /* fatura rejeitada */
                      vr_tab_relato(vr_ind).vllanmto := SUBSTR(vr_setlinha,53,15) / 100;
                      vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                      vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);

                      vr_flgrejei     := TRUE;
                    END IF;

                    IF rw_crapatr.dtfimatr IS NOT NULL THEN
                      vr_dtultdia := fn_verifica_ult_dia(vr_cdcooper, rw_crapdat.dtmvtopr);
                      -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                      GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                      -- Insere registro no arquivo com os registros de debito em conta nao efetuados (via febraban).
                      BEGIN
                        INSERT INTO crapndb
                          (dtmvtolt,
                           nrdconta,
                           cdhistor,
                           flgproce,
                           dstexarq,
                           cdcooper)
                         VALUES
                          (vr_dtultdia,
                           vr_nrdconta,
                           rw_gnconve.cdhisdeb,
                           0,
                           'F' ||SUBSTR(vr_setlinha,2,66) || '30' || SUBSTR(vr_setlinha,70,81),
                           vr_cdcooper);
                      EXCEPTION
                        WHEN OTHERS THEN
                          -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                          CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                          vr_cdcritic := 1034;
                          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                         ||'CRAPNDB(17): dtmvtolt:'  ||vr_dtultdia
                                         ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                         ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'30'||SUBSTR(vr_setlinha,70,81)
                                         ||', cdcooper:'||vr_cdcooper
                                         ||'. '||SQLERRM;
                          RAISE vr_exc_saida;
                      END;

                      continue; -- Vai para a proxima linha do arquivo
                    END IF;

                    IF vr_cdcritic > 0 THEN
                      vr_cdcritic  := 0;
                      continue; -- Vai para a proxima linha do arquivo
                    END IF;

                    LOOP
                      -- busca a capa do lote
                      OPEN cr_craplot(vr_cdcooper, rw_crapdat.dtmvtolt, vr_nrdolote);
                      FETCH cr_craplot INTO rw_craplot;

                      -- Se nao existir efetua a inclusao
                      IF cr_craplot%NOTFOUND THEN
                        BEGIN
                          INSERT INTO craplot
                            (dtmvtolt,
                             dtmvtopg,
                             cdagenci,
                             cdbccxlt,
                             cdbccxpg,
                             cdhistor,
                             nrdolote,
                             cdoperad,
                             tplotmov,
                             tpdmoeda,
                             cdcooper)
                           VALUES
                            (rw_crapdat.dtmvtolt,
                             rw_crapdat.dtmvtopr,
                             1,
                             100,
                             11,
                             rw_gnconve.cdhisdeb,
                             vr_nrdolote,
                             '1',
                             12,
                             1,
                             vr_cdcooper)
                           RETURNING dtmvtolt,
                                     cdagenci,
                                     cdbccxlt,
                                     nrseqdig,
                                     cdbccxpg,
                                     ROWID
                                INTO rw_craplot.dtmvtolt,
                                     rw_craplot.cdagenci,
                                     rw_craplot.cdbccxlt,
                                     rw_craplot.nrseqdig,
                                     rw_craplot.cdbccxpg,
                                     rw_craplot.ROWID;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPLOT: dtmvtolt:'||rw_crapdat.dtmvtolt
                                           ||', dtmvtopg:'||rw_crapdat.dtmvtopr||', cdagenci:1, cdbccxlt:100'
                                           ||', cdbccxpg:11, cdhistor:'||rw_gnconve.cdhisdeb
                                           ||', nrdolote:'||vr_nrdolote||', cdoperad:1, tplotmov:12, tpdmoeda:1'
                                           ||', cdcooper:'||vr_cdcooper
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      ELSE
                        CLOSE cr_craplot;
                        EXIT;
                      END IF;
                      CLOSE cr_craplot;
                    END LOOP;

                    LOOP

                      vr_dsrefere     := substr(vr_setlinha,2,25);
                      vr_dsrefere     := TRIM(vr_dsrefere);
                      vr_dsrefere     := LTRIM(vr_dsrefere, '0');
                      vr_nrdocmto_int := vr_dsrefere;
                      vr_vllanmto     := SUBSTR(vr_setlinha,53,15) / 100;

                      /* Tratamento para registros duplicados */
                      IF SUBSTR(vr_setlinha,150,1) = 0 THEN

                        IF (rw_gnconve.cdconven = 22 OR      /** UNIMED **/
                         rw_gnconve.cdconven = 55)   THEN  /** LIBERTY **/
                        LOOP
                          -- Busca os lancamentos automaticos
                          IF cr_craplau%ISOPEN THEN
                            CLOSE cr_craplau;
                          END IF;
                          OPEN cr_craplau(vr_cdcooper, vr_nrdconta, rw_craplot.dtmvtolt, vr_dtrefere, rw_gnconve.cdhisdeb, vr_nrdocmto_int);
                          FETCH cr_craplau INTO rw_craplau;

                            -- somente adicionar um zero a mais para a cooperativa que tiver rodando
                            IF cr_craplau%FOUND AND 
                              vr_cdcooper = pr_cdcooper THEN 
                            vr_nrdocmto_int :=  to_char(vr_nrdocmto_int) || '0';
                          ELSE
                            CLOSE cr_craplau;
                            EXIT;
                          END IF;
                          CLOSE cr_craplau;
                        END LOOP;
                        ELSE
                          LOOP
                            -- Busca os lancamentos automaticos
                            IF cr_craplau_dup%ISOPEN THEN
                              CLOSE cr_craplau_dup;
                      END IF;
                            -- Caso o convenio enviar mais que uma referencia no mesmo dia para a mesma
                            -- conta e valor do debito ou data de pagamento forem diferentes, vamos
                            -- incrementar um zero no final para permitir a inclusão do lançamento
                            OPEN cr_craplau_dup(vr_cdcooper, -- cdcooper
                                                vr_nrdconta, -- nrdconta
                                                rw_craplot.dtmvtolt, -- dtmvtolt
                                                vr_dtrefere, -- dtmvtopg
                                                rw_gnconve.cdhisdeb, -- cdhistor
                                                vr_nrdocmto_int); -- nrdocmto
                            FETCH cr_craplau_dup INTO rw_craplau_dup;

                            IF cr_craplau_dup%FOUND THEN
                              
                              IF rw_craplau_dup.dtmvtopg = vr_dtrefere AND
                                 rw_craplau_dup.vllanaut = vr_vllanmto THEN
                                 CLOSE cr_craplau_dup;
                                 EXIT;
                              ELSE                              
                                vr_nrdocmto_int :=  to_char(vr_nrdocmto_int) || '0';
                              END IF;
                            ELSE
                              CLOSE cr_craplau_dup;
                              EXIT;
                            END IF;
                            CLOSE cr_craplau_dup;
                          END LOOP;
                        END IF; 
                      END IF; -- fim IF SUBSTR(vr_setlinha,150,1) = 0 THEN

                      -- Busca os lancamentos automaticos
                      IF cr_craplau%ISOPEN THEN
                        CLOSE cr_craplau;
                      END IF;  --                             dtmvtolt dtmvtopg
                      OPEN cr_craplau(vr_cdcooper, vr_nrdconta, NULL, vr_dtrefere, rw_gnconve.cdhisdeb, vr_nrdocmto_int);
                      FETCH cr_craplau INTO rw_craplau;
                      vr_inserir_lancamento := 'N';  
                      IF cr_craplau%FOUND THEN -- Se encontrou registro
                        IF SUBSTR(vr_setlinha,150,1) = 1 THEN
                            -- Valida Cancelamento
                             vr_ind_debcancel:= 'N';
                            vr_ind_deb := vr_tab_debcancel.first;
                            WHILE vr_ind_deb IS NOT NULL LOOP
                                IF vr_tab_debcancel(vr_ind_deb).setlinha = vr_setlinha  THEN
                                  vr_ind_debcancel:= 'S';
                                  pc_critica_debito_cancelado(vr_cdcooper, vr_nrdconta, rw_crapdat.dtmvtolt, vr_dtrefere, rw_gnconve.cdhisdeb, vr_nrdocmto_int);
                                  -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                                  GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

                                  IF vr_cdcritic <> 0 THEN
                                    -- monta a chave para a pl_table vr_tab_relato
                                    vr_nrseq := vr_nrseq + 1;
                                    vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                              lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                                    vr_tab_relato(vr_ind).nmarquiv   := vr_tab_nmarquiv(i);
                                    vr_tab_relato(vr_ind).nrdconta   := vr_nrdconta;
                                    vr_tab_relato(vr_ind).contrato   := vr_cdrefere;
                                    vr_tab_relato(vr_ind).dtmvtolt   := vr_dtrefere;
                                    vr_tab_relato(vr_ind).nrdctabb   := 0;
                                    vr_tab_relato(vr_ind).cdcritic   := vr_cdcritic;
                                    vr_tab_relato(vr_ind).tpintegr   := 3;
                                    vr_tab_relato(vr_ind).vllanmto   := SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,53,15) / 100;
                                    vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,70,40);
                                    vr_tab_relato(vr_ind).descrica   := SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,110,20);
                                    vr_flgrejei     := TRUE;
                                  END IF;
                                  vr_cdcritic := 0;
                                  vr_tab_debcancel.delete(vr_ind_deb);
                                  EXIT;
                               END IF;
                               vr_ind_deb := vr_tab_debcancel.next(vr_ind_deb);
                          END LOOP;
                        ELSE
                          -- Valida Cancelamento
                           vr_ind_debcancel:= 'N';
                           vr_ind_deb := vr_tab_debcancel.first;
                           WHILE vr_ind_deb IS NOT NULL LOOP
                           BEGIN
                             vr_dtrefere_cancel := to_date(lpad(SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,51,2),2,'0')||lpad(SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,49,2),2,'0')|| SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,45,4),'ddmmyyyy');
                           EXCEPTION
                             WHEN OTHERS THEN
                               vr_cdcritic := 13; -- Data errada
                           END;
                           vr_nrconta_cancel  := SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,31,14);
                           vr_dsrefere_cancel := substr(vr_tab_debcancel(vr_ind_deb).setlinha,2,25);
                           vr_dsrefere_cancel := TRIM(vr_dsrefere_cancel);
                           vr_dsrefere_cancel := LTRIM(vr_dsrefere_cancel, '0');
                           vr_nrdocmto_cancel := vr_dsrefere_cancel;
                           IF(  vr_nrdconta = vr_nrconta_cancel AND vr_dtrefere_cancel = vr_dtrefere AND  vr_nrdocmto_int = vr_nrdocmto_cancel )THEN
                                vr_ind_debcancel:= 'S';
                                pc_critica_debito_cancelado(vr_cdcooper, vr_nrconta_cancel, rw_crapdat.dtmvtolt, vr_dtrefere_cancel, rw_gnconve.cdhisdeb, vr_nrdocmto_cancel);
                                -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                                GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

                                -- monta a chave para a pl_table vr_tab_relato
                                vr_nrseq := vr_nrseq + 1;
                                vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrconta_cancel,10,'0') ||
                                          lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');
                                vr_tab_relato(vr_ind).nmarquiv   := vr_tab_nmarquiv(i);
                                vr_tab_relato(vr_ind).nrdconta   := vr_nrconta_cancel;
                                vr_tab_relato(vr_ind).contrato   := vr_cdrefere;
                                vr_tab_relato(vr_ind).dtmvtolt   := vr_dtrefere_cancel;
                                vr_tab_relato(vr_ind).nrdctabb   := 0;
                                vr_tab_relato(vr_ind).cdcritic   := vr_cdcritic;
                                vr_tab_relato(vr_ind).tpintegr   := 3;
                                vr_tab_relato(vr_ind).vllanmto   := SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,53,15) / 100;
                                vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,70,40);
                                vr_tab_relato(vr_ind).descrica   := SUBSTR(vr_tab_debcancel(vr_ind_deb).setlinha,110,20);
                                vr_flgrejei     := TRUE;

                                vr_tab_debcancel.delete(vr_ind_deb);
                                vr_cdcritic := 0;
                                EXIT;

                           END IF;
                           vr_ind_deb := vr_tab_debcancel.next(vr_ind_deb);
                          END LOOP;
                          IF vr_ind_debcancel = 'N' THEN
                          vr_cdcritic := 092; -- Lancamento ja existe
                            -- Criar retorno para o convenio somente se tiver o lançamento 
                            -- tiver rodando na cooperativa em questão
                            IF vr_cdcooper = pr_cdcooper THEN
                          -- Retorna ao convenio com a critica 13 caso lancamento seja duplicado
                          BEGIN
                            INSERT INTO crapndb
                              (dtmvtolt,
                               nrdconta,
                               cdhistor,
                               flgproce,
                               dstexarq,
                               cdcooper)
                            VALUES
                              (vr_dtultdia,
                               vr_nrdconta,
                               rw_gnconve.cdhisdeb,
                               0,
                               'F' ||SUBSTR(vr_setlinha,2,66) || '13' || SUBSTR(vr_setlinha,70,81),
                               vr_cdcooper);
                          EXCEPTION
                            WHEN OTHERS THEN
                              -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                              -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                              vr_cdcritic := 1034;
                              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                             ||'CRAPNDB(18): dtmvtolt:'  ||vr_dtultdia
                                             ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                             ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'13'||SUBSTR(vr_setlinha,70,81)
                                             ||', cdcooper:'||vr_cdcooper
                                             ||'. '||SQLERRM;
                              RAISE vr_exc_saida;
                          END;
                            END IF;
                          ELSE
                            vr_inserir_lancamento := 'S';
                          END IF;
                        END IF;

                        IF vr_cdcritic <> 0 THEN
                          -- monta a chave para a pl_table vr_tab_relato
                          vr_nrseq := vr_nrseq + 1;
                          vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                    lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                          vr_tab_relato(vr_ind).nmarquiv   := vr_tab_nmarquiv(i);
                          vr_tab_relato(vr_ind).nrdconta   := vr_nrdconta;
                          vr_tab_relato(vr_ind).contrato   := vr_cdrefere;
                          vr_tab_relato(vr_ind).dtmvtolt   := vr_dtrefere;
                          vr_tab_relato(vr_ind).nrdctabb   := 0;
                          vr_tab_relato(vr_ind).cdcritic   := vr_cdcritic;
                          vr_tab_relato(vr_ind).tpintegr   := 3;
                          vr_tab_relato(vr_ind).vllanmto   := vr_vllanmto;
                          vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                          vr_tab_relato(vr_ind).descrica   := SUBSTR(vr_setlinha,110,20);
                          vr_flgrejei     := TRUE;
                        END IF;
                      ELSE -- Se nao encontrou registro

                        /** Critica se houver 2 debitos para a
                            mesma pessoa no mesmo arquivo **/
                        IF cr_craplau_2%ISOPEN THEN
                          CLOSE cr_craplau_2;
                        END IF;
                        OPEN cr_craplau_2(vr_cdcooper, rw_crapdat.dtmvtolt, rw_craplot.cdagenci, rw_craplot.cdbccxlt,
                                          vr_nrdolote, vr_nrdconta, vr_nrdocmto_int);
                        FETCH cr_craplau_2 INTO rw_craplau_2;

                        IF cr_craplau_2%FOUND THEN
                           -- Gerar crapndb caso ocorra lancamento duplicado para a mesma pessoa
                           BEGIN
                              INSERT INTO crapndb
                                (dtmvtolt,
                                 nrdconta,
                                 cdhistor,
                                 flgproce,
                                 dstexarq,
                                 cdcooper)
                              VALUES
                                (vr_dtultdia,
                                 vr_nrdconta,
                                 rw_gnconve.cdhisdeb,
                                 0,
                                 'F' ||SUBSTR(vr_setlinha,2,66) || '13' || SUBSTR(vr_setlinha,70,81),
                                 vr_cdcooper);
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPNDB(19): dtmvtolt:'  ||vr_dtultdia
                                               ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                               ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'13'||SUBSTR(vr_setlinha,70,81)
                                               ||', cdcooper:'||vr_cdcooper
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;

                          -- monta a chave para a pl_table vr_tab_relato
                          vr_nrseq := vr_nrseq + 1;
                          vr_ind := '0010300003'|| lpad(vr_nrdconta,10,'0') ||
                                    lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                          vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                          vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                          vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                          vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                          vr_tab_relato(vr_ind).nrdctabb := 0;
                          vr_tab_relato(vr_ind).cdcritic := 103;
                          vr_tab_relato(vr_ind).tpintegr := 3;
                          vr_tab_relato(vr_ind).vllanmto := vr_vllanmto;
                          vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                          vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                          vr_flgrejei                := TRUE;
                          
                          vr_cdcritic := vr_tab_relato(vr_ind).cdcritic;
                          vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                                         ' craplau'    ||
                                         ', nrdconta:' || vr_nrdconta ||
                                         ', nrdocmto:' || vr_nrdocmto_int;
                          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
                          pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                                      ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                      ,pr_dscritic => vr_dscritic
                                      ,pr_cdcritic => vr_cdcritic
                                      ,pr_cdcricid => 1   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                      );     
                        ELSE
                          /** No desagendamento nao cria craplau **/
                          IF SUBSTR(vr_setlinha,150,1) = 1 THEN
                            vr_cdcritic := 501; -- Lancamento nao encontrado no craplau
                            -- Gerar critica de Cancelamento nao encontrado
                            BEGIN
                              INSERT INTO crapndb
                                (dtmvtolt,
                                 nrdconta,
                                 cdhistor,
                                 flgproce,
                                 dstexarq,
                                 cdcooper)
                              VALUES
                                (vr_dtultdia,
                                 vr_nrdconta,
                                 rw_gnconve.cdhisdeb,
                                 0,
                                 'F' ||SUBSTR(vr_setlinha,2,66) || '97' || SUBSTR(vr_setlinha,70,81),
                                 vr_cdcooper);
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPNDB(20): dtmvtolt:'  ||vr_dtultdia
                                               ||', nrdconta:'||vr_nrdconta||', cdhistor:'||rw_gnconve.cdhisdeb
                                               ||', flgproce:0, dstexarq:' ||'F'||SUBSTR(vr_setlinha,2,66)||'97'||SUBSTR(vr_setlinha,70,81)
                                               ||', cdcooper:'||vr_cdcooper
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;

                            -- monta a chave para a pl_table vr_tab_relato
                            vr_nrseq := vr_nrseq + 1;
                            vr_ind := lpad(vr_cdcritic,5,'0')||'00003'|| lpad(vr_nrdconta,10,'0') ||
                                      lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                            vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                            vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                            vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                            vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                            vr_tab_relato(vr_ind).nrdctabb := 0;
                            vr_tab_relato(vr_ind).cdcritic := vr_cdcritic;
                            vr_tab_relato(vr_ind).tpintegr := 3;
                            vr_tab_relato(vr_ind).vllanmto := vr_vllanmto;
                            vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                            vr_tab_relato(vr_ind).descrica := SUBSTR(vr_setlinha,110,20);
                            vr_flgrejei     := TRUE;
                          ELSE

                             vr_inserir_lancamento := 'S';
                          END IF; /** fim else (vr_setlinha,150,1) **/

                        END IF; -- cr_craplau2

                      END IF; -- cr_craplau
                      IF vr_inserir_lancamento = 'S' THEN
                            -- Popula o numero do cartao Credicard
                            IF rw_gnconve.cdhistor = 31   OR  /* BRAS.TELECOM */
                               rw_gnconve.cdhistor = 453  THEN /* VIVO DEB. AUT. */
                              vr_nrcrcard_tmp := SUBSTR(vr_setlinha,2,11);
                            ELSIF rw_gnconve.cdhistor = 292 THEN /* BTV */
                              vr_nrcrcard_tmp := 0;
                            ELSE
                              vr_nrcrcard_tmp := nvl(SUBSTR(vr_setlinha,2,25),0);
                            END IF;

                            vr_dscodbar := ' ';

                            -- Popula o codigo de criticidade para contas migradas
                            IF vr_flg_ctamigra THEN
                              vr_cdcritic_tmp := 951; -- Conta migrada.
                              vr_dscodbar := 'MIGRADO';
                            ELSE
                              vr_cdcritic_tmp := 0;
                            END IF;

                            /*Pega proximo dia util se for ultimo dia do ano ou devolve
                              a propria data passada como referencia*/
                            vr_dtrefere := fn_verifica_ult_dia(vr_cdcooper, vr_dtrefere);
                            -- Inclusão do módulo e ação logado - Chamado 758608 - 24/10/2017
                            GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);

                            -- Cria registro na tabela de lancamentos automaticos
                            BEGIN
                              INSERT INTO craplau
                                (cdagenci,
                                 cdbccxlt,
                                 cdbccxpg,
                                 cdcritic,
                                 cdhistor,
                                 dtdebito,
                                 dtmvtolt,
                                 dtmvtopg,
                                 insitlau,
                                 nrdconta,
                                 nrdctabb,
                                 nrdolote,
                                 nrseqdig,
                                 nrseqlan,
                                 tpdvalor,
                                 cdseqtel,
                                 vllanaut,
                                 cdcooper,
                                 nrdocmto,
                                 nrcrcard,
                                 dsorigem,
                                 cdtiptra,
                                 dscedent,
                                 dscodbar)
                               VALUES
                                (rw_craplot.cdagenci,
                                 rw_craplot.cdbccxlt,
                                 rw_craplot.cdbccxpg,
                                 vr_cdcritic_tmp,
                                 rw_gnconve.cdhisdeb,
                                 NULL,
                                 rw_craplot.dtmvtolt,
                                 vr_dtrefere,
                                 1,
                                 vr_nrdconta,
                                 vr_nrdconta,
                                 vr_nrdolote,
                                 rw_craplot.nrseqdig + 1,
                                 0,
                                 1,
                                 SUBSTR(vr_setlinha,70,60),
                                 vr_vllanmto,
                                 vr_cdcooper,
                                 vr_nrdocmto_int,
                                 vr_nrcrcard_tmp,
                                 'DEBAUT',
                                 6, -- Debito Automatico
                                 rw_gnconve.nmempres,
                                 vr_dscodbar)
                               RETURNING dtmvtolt,
                                         dtmvtopg,
                                         cdhistor,
                                         nrdconta,
                                         nrdocmto,
                                         vllanaut,
                                         nrseqdig,
                                         ROWID,
                                         idlancto
                                    INTO rw_craplau.dtmvtolt,
                                         rw_craplau.dtmvtopg,
                                         rw_craplau.cdhistor,
                                         rw_craplau.nrdconta,
                                         rw_craplau.nrdocmto,
                                         rw_craplau.vllanaut,
                                         rw_craplau.nrseqdig,
                                         rw_craplau.ROWID,
                                         vr_idlancto;
                                         
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);  
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPLAU: cdagenci:'||rw_craplot.cdagenci
                                               ||', cdbccxlt:'||rw_craplot.cdbccxlt||', cdbccxpg:'||rw_craplot.cdbccxpg
                                               ||', cdcritic:'||vr_cdcritic_tmp    ||', cdhistor:'||rw_gnconve.cdhisdeb
                                               ||', dtdebito:NULL, dtmvtolt:'   ||rw_craplot.dtmvtolt||', dtmvtopg:'||vr_dtrefere
                                               ||', insitlau:1, nrdconta:'      ||vr_nrdconta||', nrdctabb:'||vr_nrdconta
                                               ||', nrdolote:'||vr_nrdolote     ||', nrseqdig:'||rw_craplot.nrseqdig + 1
                                               ||', nrseqlan:0, tpdvalor:1'     ||', cdseqtel:'||SUBSTR(vr_setlinha,70,60)
                                               ||', vllanaut:'||vr_vllanmto     ||', cdcooper:'||vr_cdcooper
                                               ||', nrdocmto:'||vr_nrdocmto_int ||', nrcrcard:'||vr_nrcrcard_tmp
                                               ||', dsorigem:DEBAUT, cdtiptra:6'||', dscedent:'||rw_gnconve.nmempres
                                               ||', dscodbar:'||vr_dscodbar
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;
                            BEGIN
                              INSERT INTO tbconv_det_agendamento(idlancto
                                                                ,cdlayout
                                                                ,tppessoa_dest
                                                                ,nrcpfcgc_dest)
                                                         VALUES (vr_idlancto
                                                                ,rw_gnconve.nrlayout
                                                                ,vr_tppesssoa
                                                                ,vr_nrcpfcgc);	
                                             
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1034;
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'tbconv_det_agendamento: idlancto:'||vr_idlancto
                                               ||', cdlayout:'     ||rw_gnconve.nrlayout
                                               ||', tppessoa_dest:'||vr_tppesssoa
                                               ||', nrcpfcgc_dest:'||vr_nrcpfcgc
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;

                            -- Atualiza a capa do lote
                            BEGIN
                              UPDATE craplot
                                 SET nrseqdig = nrseqdig + 1,
                                     qtcompln = qtcompln + 1,
                                     qtinfoln = qtinfoln + 1,
                                     vlcompdb = vlcompdb + vr_vllanmto,
                                     vlcompcr = 0,
                                     vlinfodb = vlcompdb + vr_vllanmto,
                                     vlinfocr = 0
                               WHERE ROWID = rw_craplot.rowid;
                            EXCEPTION
                              WHEN OTHERS THEN
                                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                                vr_cdcritic := 1035;   
                                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                               ||'CRAPLOT: vr_vllanmto:'||vr_vllanmto
                                               ||', vlcompcr:0, vlinfocr:0'
                                               ||', rowid:'||rw_craplot.rowid
                                               ||'. '||SQLERRM;
                                RAISE vr_exc_saida;
                            END;

                            -->>> Validar valor maior que o limite parametrizado
                            IF rw_crapatr.flgmaxdb = 1 AND 
                               rw_craplau.vllanaut > rw_crapatr.vlrmaxdb THEN
                              
                              vr_cdcritic := 967;  -- Limite ultrapassado.
                              ---> Notificar critica ao cooperado 
                              SICR0001.pc_notif_cooperado_DEBAUT
                                                    ( pr_cdcritic  => vr_cdcritic
                                                     ,pr_cdcooper  => vr_cdcooper 
                                                     ,pr_nmrescop  => rw_crapcop.nmrescop
                                                     ,pr_cdprogra  => vr_cdprogra
                                                     ,pr_nrdconta  => rw_craplau.nrdconta
                                                     ,pr_nrdocmto  => rw_craplau.nrdocmto
                                                     ,pr_nmconven  => rw_gnconve.nmempres
                                                     ,pr_dtmvtopg  => rw_craplau.dtmvtopg
                                                     ,pr_vllanaut  => rw_craplau.vllanaut
                                                     ,pr_vlrmaxdb  => rw_crapatr.vlrmaxdb
                                                     ,pr_cdrefere  => rw_crapatr.cdrefere
                                                     ,pr_cdhistor  => rw_crapatr.cdhistor
                                                     ,pr_flfechar_lote => 0 -- Fechar
                                                     ,pr_idlote_sms   => vr_nrdolote_sms); 
                               -- Retornar nome do módulo logado - Chamado INC0011662 - 28/03/2018
                              GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => null);  
                              vr_cdcritic := 0;                         
                            END IF;   

                            /**** Tratamento migracao Migracao ***/
                            IF vr_flg_ctamigra THEN

                              IF vr_cdcooper <> pr_cdcooper THEN /* migracao */
                              vr_doc_gravado_migrado := vr_doc_gravado_migrado + 1;
                              vr_vlr_gravado_migrado := vr_vlr_gravado_migrado + vr_vllanmto;
                              ELSE
                                vr_doc_gravado := vr_doc_gravado + 1;
                                vr_vlr_gravado := vr_vlr_gravado + vr_vllanmto;
                              END IF;

                              -- monta a chave para a pl_table vr_tab_relato
                              vr_nrseq := vr_nrseq + 1;
                              vr_ind := '0095100005'|| lpad(vr_nrdconta,10,'0') ||
                                        lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                              vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                              vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                              vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                              vr_tab_relato(vr_ind).dtmvtolt := vr_dtrefere;
                              vr_tab_relato(vr_ind).nrdctabb := 0;
                              vr_tab_relato(vr_ind).cdcritic := 951;
                              vr_tab_relato(vr_ind).tpintegr := 5;
                              vr_tab_relato(vr_ind).vllanmto := vr_vllanmto;
                              vr_tab_relato(vr_ind).ocorrencia := SUBSTR(vr_setlinha,70,40);
                              vr_flgrejei      := TRUE;
                            ELSE
                              vr_doc_gravado := vr_doc_gravado + 1;
                              vr_vlr_gravado := vr_vlr_gravado + vr_vllanmto;
                            END IF;

                            IF rw_gnconve.inavisar = 1 THEN -- Indicador que deve avisar o debito
                              pc_gera_aviso_debito;
                              -- Retorna nome do modulo logado - 02/10/2017 - Ch 708424 
                              GENE0001.pc_set_modulo(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);
                            END IF;
                            vr_inserir_lancamento := 'N';
                      END IF;
                      EXIT;

                    END LOOP;

                    continue; -- Vai para o proximo registro

                  ELSIF vr_tpregist = 'B' THEN
                    /* Aceita a importacao se for TRUE ou ADDMAKLER */
                    IF (rw_gnconve.flgdecla = 0   AND
                        rw_gnconve.cdconven <> 39) OR    /* Addmakler */
                        cr_crapass%NOTFOUND THEN
                       continue;
                    END IF;

                    -- Abre o cursor de cadastro das autorizacoes de debito em conta
                    IF cr_crapatr_2%ISOPEN THEN
                      CLOSE cr_crapatr_2;
                    END IF;
                    OPEN cr_crapatr_2(vr_cdcooper, vr_nrdconta, rw_gnconve.cdhisdeb, SUBSTR(vr_setlinha,02,25));
                    FETCH cr_crapatr_2 INTO rw_crapatr_2;
                    IF cr_crapatr_2%FOUND THEN
                      /* Inclusao */
                      IF SUBSTR(vr_setlinha,150,01) = '2'  THEN
                        -- Monta o codigo de criticidade
                        IF rw_crapatr_2.dtfimatr IS NULL THEN
                          vr_cdcritic_tmp := 452; -- Autorizacao ja cadastrada.
                        ELSE
                          vr_cdcritic_tmp := 447; -- Autorizacao cancelada.

                          vr_dscritic_in := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic_tmp) ||
                                            'Debito Automatico' ||
                                            ', nrdconta:'    || vr_nrdconta ||
                                            ', cdconven:' || rw_gnconve.cdconven;
                          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
                          pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                                      ,pr_tpocorre => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                      ,pr_dscritic => vr_dscritic_in
                                      ,pr_cdcritic => vr_cdcritic_tmp
                                      ,pr_cdcricid => 1   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                      );    
                        END IF;

                        -- monta a chave para a pl_table vr_tab_relato
                        vr_nrseq := vr_nrseq + 1;
                        vr_ind := lpad(vr_cdcritic_tmp,5,'0')||'00004'|| lpad(vr_nrdconta,10,'0') ||
                                  lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                        vr_tab_relato(vr_ind).nmarquiv := vr_tab_nmarquiv(i);
                        vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                        vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                        vr_tab_relato(vr_ind).dtmvtolt := NULL;
                        vr_tab_relato(vr_ind).nrdctabb := 0;
                        vr_tab_relato(vr_ind).cdcritic := vr_cdcritic_tmp;
                        vr_tab_relato(vr_ind).tpintegr := 4;
                        vr_tab_relato(vr_ind).vllanmto := 0;
                        vr_tab_relato(vr_ind).ocorrencia := ' ';
                        vr_tab_relato(vr_ind).descrica := ' ';
                        vr_tab_relato(vr_ind).nmprimtl := rw_crapass.nmprimtl;
                        vr_tab_relato(vr_ind).operacao := TRUE;

                      ELSE    /* Exclusao */
                        rw_crapatr_2.dtfimatr := to_date(SUBSTR(vr_setlinha,45,8),'YYYYMMDD');
                        BEGIN
                          UPDATE crapatr
                             SET dtfimatr = to_date(SUBSTR(vr_setlinha,45,8),'YYYYMMDD')
                           WHERE ROWID = rw_crapatr_2.rowid;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1035;   
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||'CRAPATR(5): dtfimatr:'||to_date(SUBSTR(vr_setlinha,45,8),'YYYYMMDD')
                                           ||', rowid:'||rw_crapatr_2.rowid
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;

                        -- monta a chave para a pl_table vr_tab_relato
                        vr_nrseq := vr_nrseq + 1;
                        vr_ind := '0000000004'|| lpad(vr_nrdconta,10,'0') ||
                                  lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                        vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                        vr_tab_relato(vr_ind).nmprimtl := rw_crapass.nmprimtl;
                        vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                        vr_tab_relato(vr_ind).operacao := FALSE;
                        vr_tab_relato(vr_ind).tpintegr := 4;

                      END IF;

                      continue; -- Vai para a proxima linha do arquivo
                    ELSE -- cr_crapatr_2%notfound
                      /*Inclusao*/
                      IF SUBSTR(vr_setlinha,150,01) = '2'  AND
                         cr_crapass%FOUND THEN
                        /*** Tratamento para codigo de referencia zerado ***/
                        IF to_number(SUBSTR(vr_setlinha,02,25)) = 0 THEN
                          continue;
                        END IF;

                        BEGIN
                          INSERT INTO crapatr
                            (nrdconta,
                             cdrefere,
                             cddddtel,
                             cdhistor,
                             ddvencto,
                             dtiniatr,
                             dtultdeb,
                             nmfatura,
                             dtfimatr,
                             cdcooper,
                             nmempres)
                           VALUES
                            (vr_nrdconta,
                             SUBSTR(vr_setlinha,02,25),
                             0,
                             rw_gnconve.cdhisdeb,
                             1,
                             to_date(SUBSTR(vr_setlinha,45,08),'YYYYMMDD'),
                             NULL,
                             rw_crapass.nmprimtl,
                             NULL,
                             vr_cdcooper,
                             decode(rw_gnconve.cdhisdeb, 586, rw_gnconve.nmempres, ' '))
                           RETURNING dtfimatr,
                                     ROWID
                                INTO rw_crapatr_2.dtfimatr,
                                     rw_crapatr_2.ROWID;
                        EXCEPTION
                          WHEN OTHERS THEN
                            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
                            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
                            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                            vr_cdcritic := 1034;
                            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                                           ||' CRAPATR: nrdconta:'||vr_nrdconta
                                           ||', cdrefere:'                ||SUBSTR(vr_setlinha,02,25)
                                           ||', cddddtel:0, cdhistor:'    ||rw_gnconve.cdhisdeb
                                           ||', ddvencto:1, dtiniatr:'    ||to_date(SUBSTR(vr_setlinha,45,08),'YYYYMMDD')
                                           ||', dtultdeb: NULL, nmfatura:'||rw_crapass.nmprimtl
                                           ||', dtfimatr: NULL, cdcooper:'||vr_cdcooper
                                           ||', nmempres:'                ||rw_gnconve.nmempres
                                           ||'. '||SQLERRM;
                            RAISE vr_exc_saida;
                        END;
                      END IF;

                      -- monta a chave para a pl_table vr_tab_relato
                      vr_nrseq := vr_nrseq + 1;
                      vr_ind := '0000000004'|| lpad(vr_nrdconta,10,'0') ||
                                lpad(vr_cdrefere*100,27,'0') || lpad(vr_nrseq,5,'0');

                      vr_tab_relato(vr_ind).nrdconta := vr_nrdconta;
                      vr_tab_relato(vr_ind).contrato := vr_cdrefere;
                      vr_tab_relato(vr_ind).operacao := TRUE;
                      vr_tab_relato(vr_ind).tpintegr := 4;
                      IF cr_crapass%FOUND THEN
                        vr_tab_relato(vr_ind).nmprimtl := rw_crapass.nmprimtl;
                      ELSE
                        vr_tab_relato(vr_ind).nmprimtl := 'Associado nao cadastrado.';
                      END IF;

                      /*Critica em exclusao de conta nao cadastrada no crapatr*/
                      IF SUBSTR(vr_setlinha,150,01) <> '2' THEN
                        vr_tab_relato(vr_ind).dtmvtolt := NULL;
                        vr_tab_relato(vr_ind).cdcritic := 453; -- Autorizacao nao encontrada.
                      ELSIF cr_crapass%NOTFOUND THEN
                        vr_tab_relato(vr_ind).dtmvtolt := NULL;
                        vr_tab_relato(vr_ind).ocorrencia := 'Inclusao de autorizacao';
                        vr_tab_relato(vr_ind).cdcritic := 9; -- Associado nao cadastrado.
                      END IF;
                    END IF;
                    continue;
                  END IF;
                EXCEPTION
                  WHEN vr_exc_saida THEN 
                    RAISE vr_exc_saida;
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                    CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                    -- Popula tabela de erro
                    vr_cdcritic_in := 1053;
                    vr_dscritic_in := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic_in) ||
                                      ' (5) cdconven:' || rw_gnconve.cdconven ||
                                      ', nmempres:' || rw_gnconve.nmempres ||
                                      ', contlinh:' || to_char(vr_contlinh)||
                                      ', nmarquiv:' || vr_tab_nmarquiv(i)  ||
                                      ', ' || SQLERRM;
                    -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
                    pc_trata_log(pr_dstiplog => 'E' -- I-início; F-fim; O-ocorrência; E-erro
                                ,pr_tpocorre => 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                ,pr_dscritic => vr_dscritic_in
                                ,pr_cdcritic => vr_cdcritic_in
                                ,pr_cdcricid => 1   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                );     
                    vr_tab_erro(vr_tab_erro.count+1) := vr_dscritic_in;                
                    -- Caso houver erro na leitura da linha, efetua o rollback somente para a linha
                    ROLLBACK TO LEITURA_LINHA;
                END;
              END LOOP; -- Leitura linha a linha do arquivo para integracao
            END IF; -- not vr_arqvazio

            -- Fecha arquivo
            BEGIN
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018  
                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                           
                vr_cdcritic := 1039;
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                               ' vr_nmdirdeb:'    || vr_nmdirdeb        ||
                               ', pr_nmarquiv:'    || vr_tab_nmarquiv(i) ||
                               ', pr_tipabert:'    || 'R'           ||
		    				               ', (6), ' || SQLERRM;
                --Levantar Excecao
                RAISE vr_exc_saida;
            END;

            -- Caso nenhuma filiada tenha processado ainda e a central tenha processado antes
            IF vr_semmovto THEN
              vr_cdcritic := 597; -- Sem movtos integracao
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                             ' cdconven:' || rw_gncvcop.cdconven;
              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
              pc_trata_log(pr_dstiplog => 'O' -- I-início; F-fim; O-ocorrência; E-erro
                          ,pr_tpocorre => 3   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_dscritic => vr_dscritic
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          );                                  
            ELSE
              -- Move o arquivo para o diretorio salvar
              gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_nmdirdeb||'/'||vr_tab_nmarquiv(i)|| ' ' ||
                                                    gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                                         ,pr_cdcooper => pr_cdcooper
                                                                         ,pr_nmsubdir => 'salvar'));
              -- Se possuir rejeitados
              IF vr_flgrejei THEN
                vr_cdcritic := 191; -- Arquivo integrado com rejeitados
              ELSE
                vr_cdcritic := 190; -- Arquivo integrado com sucesso
              END IF;

              -- Envio centralizado de log de erro
              vr_cdcritic_in := vr_cdcritic;
              vr_dscritic_in := gene0001.fn_busca_critica(vr_cdcritic_in) ||
                                ' nmarquiv:'  || vr_tab_nmarquiv(i) ||
                                ', nmdirdeb:' || vr_nmdirdeb;
              -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
              pc_trata_log(pr_dstiplog => 'O' -- I-início; F-fim; O-ocorrência; E-erro
                          ,pr_tpocorre => 4   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_dscritic => vr_dscritic_in
                          ,pr_cdcritic => vr_cdcritic_in
                          ,pr_cdcricid => 0  -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          );
            END IF;

            -- Inicializa as variaveis totalizadoras
            vr_tot_qtregrec := 0;
            vr_tot_qtregrej := 0;
            vr_tot_qtaltint := 0;
            vr_tot_qtfatrec := 0;
            vr_tot_qtfatrej := 0;
            vr_tot_vlfatint := 0;
            vr_tot_qtregint := 0;
            vr_tot_qtaltrec := 0;
            vr_tot_qtaltrej := 0;
            vr_tot_qtfatint := 0;
            vr_tot_vlfatrec := 0;
            vr_tot_vlfatrej := 0;
            vr_flgfirst     := TRUE;
            vr_flgfirst_lanc_a := TRUE;
            vr_flgfirst_lanc_b := TRUE;
            vr_cdcritic     := 0;

            -- Define o nome do relatorio
            vr_nmarqimp := 'crrl344_c' ||
                            to_char(rw_gnconve.cdconven,'fm0000') || '_' ||
                            SUBSTR(to_char(vr_nrseqarq,'fm000000'),5,2) ||
                            '.lst';

            /* IMPRESSAO DO RELATORIO */

            -- Inicializar o CLOB
            vr_des_xml := null;
            dbms_lob.createtemporary(vr_des_xml, true);
            dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

            -- Inicializa o XML
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '<?xml version="1.0" encoding="utf-8"?><crrl344>');
            -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
            GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);	
            vr_ind := vr_tab_relato.first;
            WHILE vr_ind IS NOT NULL LOOP

              vr_nmarquiv := vr_tab_relato(vr_ind).nmarquiv;

              -- Se for o primeiro registro
              IF vr_flgfirst THEN
                vr_nmempcon := rw_gnconve.nmempres;

                -- Escreve o cabecalho do arquivo
                gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '<nmarquiv>'||substr(vr_nmarquiv,1,20)||'</nmarquiv>'||
                                '<nmempcon>'||vr_nmempcon||'</nmempcon>'||
                                '<dtmvtolt>'||to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY')||'</dtmvtolt>'||
                                '<cdagenci>'||vr_cdagenci||'</cdagenci>'||
                                '<cdbccxlt>'||vr_cdbccxlt||'</cdbccxlt>'||
                                '<nrdolote>'||gene0002.fn_mask(vr_nrdolote,'zzz.zz9')||'</nrdolote>'||
                                '<tplotmov>'||vr_tplotmov||'</tplotmov>');
                vr_flgfirst := FALSE;
              END IF;

              IF vr_tab_relato(vr_ind).nrdctabb = 0 THEN
                vr_dsmovmto := ' ';
              ELSIF vr_tab_relato(vr_ind).nrdctabb = 1 THEN
                vr_dsmovmto := 'EXC';
              ELSIF vr_tab_relato(vr_ind).nrdctabb = 2 THEN
                vr_dsmovmto := 'INC';
              ELSE
                vr_dsmovmto := 'ERR';
              END IF;

              vr_dscritic_tmp := ' ';

              -- Se possuir critica
              IF vr_tab_relato(vr_ind).cdcritic <> 0 THEN
                vr_dscritic_tmp := gene0001.fn_busca_critica(vr_tab_relato(vr_ind).cdcritic);
              END IF;

              IF vr_tab_relato(vr_ind).nrdconta <> 999999999 THEN
                IF vr_tab_relato(vr_ind).tpintegr =  4 AND nvl(vr_tab_relato(vr_ind).cdcritic,0) = 0 THEN
                  -- Se for o primeiro lancamento deste tipo efetua a abertura do nó
                  IF vr_flgfirst_lanc_b THEN
                    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                            '<lancamento>');
                    vr_flgfirst_lanc_b := FALSE;
                  END IF;

                  -- Popula o tipo de operacao
                  IF vr_tab_relato(vr_ind).operacao THEN
                    vr_operacao := 'Inclusao';
                  ELSE
                    vr_operacao := 'Cancelamento';
                  END IF;

                  -- Escreve a linha do contrato com a operacao
                  gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                        '<conta>'||
                                          '<nrdconta>'||gene0002.fn_mask_conta(vr_tab_relato(vr_ind).nrdconta)||'</nrdconta>'||
                                          '<nmprimtl>'||gene0007.fn_caract_controle(vr_tab_relato(vr_ind).nmprimtl)||'</nmprimtl>'||
                                          '<contrato>'||vr_tab_relato(vr_ind).contrato||'</contrato>'||
                                          '<operacao>'||vr_operacao||'</operacao>'||
                                        '</conta>');
                ELSE
                  -- Se ja existir a abertura do Nó "lancamento", efetua o fechamento do mesmo
                  IF NOT vr_flgfirst_lanc_b THEN
                    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                            '</lancamento>');
                    vr_flgfirst_lanc_b := TRUE;
                  END IF;

                  -- Se for o primeiro lancamento deste tipo efetua a abertura do nó
                  IF vr_flgfirst_lanc_a THEN
                    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                            '<ocorrencia>');
                    vr_flgfirst_lanc_a := FALSE;
                  END IF;

                  -- Se o valor for zeros, nao deve-se imprimir
                  IF nvl(vr_tab_relato(vr_ind).vllanmto,0) > 0 THEN
                    vr_dslanmto := to_char(vr_tab_relato(vr_ind).vllanmto,'fm999G999G990D00');
                  ELSE
                    vr_dslanmto := ' ';
                  END IF;

                  -- nao formatar para numeros acima de 9000000000 pois vai estourar 
                  -- o campo no ireport
                  IF vr_tab_relato(vr_ind).nrdconta < 9000000000 THEN
                    vr_nrdconta_relato := gene0002.fn_mask_conta(vr_tab_relato(vr_ind).nrdconta);
                  ELSE
                    vr_nrdconta_relato := vr_tab_relato(vr_ind).nrdconta;
                  END IF;

                  -- Escreve a linha do contrato com a operacao
                  gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                        '<conta>'||
                                          '<nrdconta>'||vr_nrdconta_relato||'</nrdconta>'||
                                          '<contrato>'||vr_tab_relato(vr_ind).contrato||'</contrato>'||
                                          '<dsmovmto>'||vr_dsmovmto||'</dsmovmto>'||
                                          '<ocorrencia>'||gene0007.fn_caract_controle(nvl(substr(vr_tab_relato(vr_ind).ocorrencia,1,30),' '))||'</ocorrencia>'||
                                          '<vllanmto>'||vr_dslanmto||'</vllanmto>'||
                                          '<dtmvtolt>'||nvl(to_char(vr_tab_relato(vr_ind).dtmvtolt,'dd/mm/yyyy'),' ')||'</dtmvtolt>'||
                                          '<dscritic>'||substr(vr_dscritic_tmp,1,60) || vr_tab_relato(vr_ind).dscritic || '</dscritic>'||
                                          '<descrica>'||vr_tab_relato(vr_ind).descrica||'</descrica>'||
                                        '</conta>');
                END IF;

              END IF;

              IF vr_tab_relato(vr_ind).tpintegr = 1 THEN -- Alterados e Rejeitados
                vr_tot_qtaltrej := vr_tot_qtaltrej + 1;
                vr_tot_qtaltrec := vr_tot_qtaltrec + 1;
              ELSIF vr_tab_relato(vr_ind).tpintegr = 2 THEN -- Alterados e Integrados
                vr_tot_qtaltint := vr_tot_qtaltint + 1;
                vr_tot_qtaltrec := vr_tot_qtaltrec + 1;
              ELSIF vr_tab_relato(vr_ind).tpintegr = 3 THEN -- Faturados e rejeitados
                vr_tot_qtfatrej := vr_tot_qtfatrej + 1;
                vr_tot_vlfatrej := vr_tot_vlfatrej + vr_tab_relato(vr_ind).vllanmto;
              END IF;

              vr_tot_qtregrej := vr_tot_qtaltrej + vr_tot_qtfatrej;

              IF vr_tab_relato(vr_ind).nrdconta = 999999999 THEN
                vr_tot_qtregrec := vr_tab_relato(vr_ind).nrdocmto - 2;
                vr_tot_vlfatrec := vr_tab_relato(vr_ind).vllanmto;
                vr_tot_qtregint := vr_tot_qtregrec - vr_tot_qtregrej;
                vr_tot_qtfatrec := vr_tot_qtregrec - vr_tot_qtaltrec;
                vr_tot_qtfatint := vr_tot_qtfatrec - vr_tot_qtfatrej;
                vr_tot_vlfatint := vr_tot_vlfatrec - vr_tot_vlfatrej;
              END IF;

              vr_ind := vr_tab_relato.next(vr_ind);
              -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
              GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);	

            END LOOP;  /* for each w-relato */

            -- Se ja existir a abertura do Nó "lancamento", efetua o fechamento do mesmo
            IF NOT vr_flgfirst_lanc_b THEN
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                      '</lancamento>');
            END IF;

            -- Se ja existir a abertura do Nó "ocorrencia", efetua o fechamento do mesmo
            IF NOT vr_flgfirst_lanc_a THEN
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                      '</ocorrencia>');
            END IF;

            IF pr_cdcooper = rw_gnconve.cdcooper THEN
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<tot_qtregrec>'||to_char(vr_tot_qtregrec,'fm999G999G990')||'</tot_qtregrec>'||
                '<tot_qtregint>'||to_char(vr_tot_qtregint,'fm999G999G990')||'</tot_qtregint>'||
                '<tot_qtregrej>'||to_char(vr_tot_qtregrej,'fm999G999G990')||'</tot_qtregrej>'||
                '<tot_qtaltrec>'||to_char(vr_tot_qtaltrec,'fm999G999G990')||'</tot_qtaltrec>'||
                '<tot_qtaltint>'||to_char(vr_tot_qtaltint,'fm999G999G990')||'</tot_qtaltint>'||
                '<tot_qtaltrej>'||to_char(vr_tot_qtaltrej,'fm999G999G990')||'</tot_qtaltrej>'||
                '<tot_qtfatrec>'||to_char(vr_tot_qtfatrec,'fm999G999G990')||'</tot_qtfatrec>'||
                '<tot_qtfatint>'||to_char(vr_tot_qtfatint,'fm999G999G990')||'</tot_qtfatint>'||
                '<tot_qtfatrej>'||to_char(vr_tot_qtfatrej,'fm999G999G990')||'</tot_qtfatrej>'||
                '<tot_vlfatrec>'||to_char(vr_tot_vlfatrec,'fm999G999G990D00')||'</tot_vlfatrec>'||
                '<tot_vlfatint>'||to_char(vr_tot_vlfatint,'fm999G999G990D00')||'</tot_vlfatint>'||
                '<tot_vlfatrej>'||to_char(vr_tot_vlfatrej,'fm999G999G990D00')||'</tot_vlfatrej>');
            ELSE
              gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                '<tot_qtregrec></tot_qtregrec>'||
                '<tot_qtregint></tot_qtregint>'||
                '<tot_qtregrej></tot_qtregrej>'||
                '<tot_qtaltrec></tot_qtaltrec>'||
                '<tot_qtaltint></tot_qtaltint>'||
                '<tot_qtaltrej></tot_qtaltrej>'||
                '<tot_qtfatrec>'||to_char(vr_doc_gravado,'fm999G999G990')||'</tot_qtfatrec>'||
                '<tot_qtfatint></tot_qtfatint>'||
                '<tot_qtfatrej></tot_qtfatrej>'||
                '<tot_vlfatrec>'||to_char(vr_vlr_gravado,'fm999G999G990D00')||'</tot_vlfatrec>'||
                '<tot_vlfatint></tot_vlfatint>'||
                '<tot_vlfatrej></tot_vlfatrej>');
            END IF;

            -- Finaliza o arquivo
            gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo,
                                '</crrl344>',TRUE);
            -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
            GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);	
            -- Efetuar solicitação de geração de relatório --
            gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                           ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                           ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                           ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                           ,pr_dsxmlnode => '/crrl344'          --> Nó base do XML para leitura dos dados
                           ,pr_dsjasper  => 'crrl344.jasper'    --> Arquivo de layout do iReport
                           ,pr_dsparams  => NULL                --> Enviar como parâmetro apenas o valor maior deposito
                           ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final
                           ,pr_qtcoluna  => 234                 --> 132 colunas
                           ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_1.i}
                           ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                           ,pr_nmformul  => '234col'            --> Nome do formulário para impressão
                           ,pr_flg_gerar => 'N'                 --> Geraçao na hora
                           ,pr_nrcopias  => 1                   --> Número de cópias
                           ,pr_des_erro  => vr_dscritic);       --> Saída com erro
            -- Verifica se ocorreu erro na geracao do relatorio
            IF vr_dscritic IS NOT NULL THEN
              -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica 
              vr_cdcritic := 1197;
              vr_dscritic := vr_dscritic ||
                             ' - gene0002.pc_solicita_relato';	
              RAISE vr_exc_saida;
            END IF;
            -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
            GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);	

            -- Liberando a memória alocada pro CLOB
            dbms_lob.close(vr_des_xml);
            dbms_lob.freetemporary(vr_des_xml);

            -- Limpa a tabela de relatorios
            vr_tab_relato.delete;

            -- Efetua a gravacao, pois ja processou e moveu o arquivo
            COMMIT;

          END LOOP; -- 1..vr_contador

          IF vr_contador = 0 THEN
            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
            vr_cdcritic := 597; -- Sem movtos integracao
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
                           ' cdconven:' || rw_gncvcop.cdconven;
            pc_trata_log(pr_dstiplog => 'O' -- I-início; F-fim; O-ocorrência; E-erro
                        ,pr_tpocorre => 3   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                        ,pr_dscritic => vr_dscritic
                        ,pr_cdcritic => vr_cdcritic
                        ,pr_cdcricid => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                        );    
            vr_cdcritic := NULL;
            vr_dscritic := NULL;   
          END IF;

          -- Atualiza o numero do lote
          BEGIN
            UPDATE craptab
               SET dstextab = to_char(decode(to_number(dstextab),6625,6600
                                                             ,to_number(dstextab)+1),'fm000000')
             WHERE craptab.cdcooper = pr_cdcooper
               AND upper(craptab.nmsistem) = 'CRED'
               AND upper(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres = 00
               AND upper(craptab.cdacesso) = 'LOTEINT031'
               AND craptab.tpregist = 001
               RETURNING dstextab INTO vr_dstextab;
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
              CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
              -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
              vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
              vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
              vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
              vr_cdcritic := 1035;   
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                               ||'CRAPTAB(1): cdcooper:'||pr_cdcooper
                               ||', nmsistem:CRED, tptabela:GENERI'
                               ||', cdempres:00, cdacesso:LOTEINT031, tpregist:001'
                               ||', cdconven:'||rw_gncvcop.cdconven
                               ||'. '||SQLERRM;
              RAISE vr_exc_saida;
          END;

          vr_nrdolote := vr_dstextab;

          /*** Tratamento migracao ***/
          IF vr_flg_migracao THEN
            -- Atualiza o numero do lote para conta migrada
            BEGIN
              UPDATE craptab
                 SET dstextab = to_char(decode(to_number(dstextab),6625,6600
                                                               ,to_number(dstextab)+1),'fm000000')
               WHERE craptab.cdcooper = vr_cdcoptab
                 AND upper(craptab.nmsistem) = 'CRED'
                 AND upper(craptab.tptabela) = 'GENERI'
                 AND craptab.cdempres = 00
                 AND upper(craptab.cdacesso) = 'LOTEINT031'
                 AND craptab.tpregist = 001
               RETURNING dstextab INTO vr_dstextab;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
                CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
                -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
                vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
                vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
                vr_cdcritic := 1035;   
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                               ||'CRAPTAB(2): cdcooper:'||vr_cdcoptab
                               ||', nmsistem:CRED, tptabela:GENERI'
                               ||', cdempres:00, cdacesso:LOTEINT031, tpregist:001'
                               ||', cdconven:'||rw_gncvcop.cdconven
                               ||'. '||SQLERRM;
                RAISE vr_exc_saida;
            END;

            vr_nrdolote := vr_dstextab;

          END IF;

        EXCEPTION
          WHEN vr_exc_saida THEN 
            RAISE vr_exc_saida;
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica  
            vr_cdcritic := 1036;
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                           ||'Loop gnconve - ' 
                           ||'cdconven:' || rw_gncvcop.cdconven
                           ||', cdcooper:' || pr_cdcooper
                           ||'. '||SQLERRM;
            RAISE vr_exc_saida;
        END;
        END LOOP; -- Loop sobre a tabela gnconve

      END LOOP; -- Loop sobre a tabela gncvcop

      --> Concluir envio dos SMS
      IF nvl(vr_nrdolote_sms,0) > 0 THEN
        ESMS0001.pc_conclui_lote_sms(pr_idlote_sms  => vr_nrdolote_sms 
                                    ,pr_dscritic    => vr_dscritic);
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018  
          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica 
          vr_cdcritic := 1197;
          vr_dscritic := vr_dscritic ||
                         ' - ESMS0001.pc_conclui_lote_sms';	
          RAISE vr_exc_saida;
        END IF;    
        -- Retornar nome do módulo logado - Chamado INC0011662 - 28/03/2018
        GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => null);                        
      END IF;
      

      /*--- Eliminar Arquivos (Independente de Terem Convenios) -----*/
      FOR rw_gnconve_2 IN cr_gnconve_2 LOOP
        vr_nmarqdeb := vr_nmdirdeb || '/' || TRIM(rw_gnconve_2.nmarqint) || '*';
        gene0001.pc_oscommand_shell(pr_des_comando => 'mv '||vr_nmdirdeb||'/'||vr_nmarqdeb|| ' ' ||
                                                  gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                                       ,pr_cdcooper => pr_cdcooper
                                                                       ,pr_nmsubdir => 'salvar')||' 2> /dev/null');

        gene0001.pc_oscommand_shell(pr_des_comando => 'rm '||vr_nmdirdeb||'/'||vr_nmarqdeb||' 2> /dev/null');
      END LOOP;

      /*--- Eliminar arquivos de erro com data maior que 7 dias ---*/
      gene0001.pc_oscommand_shell(pr_des_comando => 'find '||vr_nmdirdeb||'/errd* \( -type f -o -name . -o -prune \) -a -mtime +7 -exec rm {} \; 2> /dev/null');
      /*---- Eliminar Movimentos de Controle ---*/
      IF to_char(rw_crapdat.dtmvtolt,'MM') <> to_char(rw_crapdat.dtmvtoan,'MM') THEN
        -- Busca o primeiro dia de tres meses antes da data dtmvtolt
        vr_dtlimite := trunc(add_months(rw_crapdat.dtmvtolt,-3),'MM');

        BEGIN
          DELETE gncontr
           WHERE gncontr.cdcooper = pr_cdcooper
             AND gncontr.dtmvtolt < vr_dtlimite;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
            CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper); 
            -- Ajuste log da critica - Chamado INC0011662 - 28/03/2018
            vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
            vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
            vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica   
            vr_cdcritic := 1037;   
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)
                            ||' gncontr(1)'
                            ||', cdcooper:'||pr_cdcooper
                            ||', dtmvtolt:'||vr_dtlimite
                            ||'. '||SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      -- Caso houver erro, envia email
      IF vr_tab_erro.count > 0 AND
         pr_cdcooper = 3 THEN -- Enviar somente para a Cecred, pois os arquivos sao processados em todas
                              -- as cooperativas. Estava gerando email igual em todas as cooperativas
        -- Concatena o texto do log
        FOR i IN 1..vr_tab_erro.last LOOP
          IF nvl(length(vr_texto_email),0) < 3500 THEN
            vr_texto_email := vr_texto_email || vr_tab_erro(i)||'<br>';
          END IF;
        END LOOP;

        vr_texto_email := '<b>Abaixo os erros encontrados no processo de importacao do debito:</b><br><br>'||
                          vr_texto_email;

        -- Por fim, envia o email
        gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra
                                  ,pr_des_destino => vr_emaildst
                                  ,pr_des_assunto => 'Critica importacao debito - CONVENIO'
                                  ,pr_des_corpo   => vr_texto_email
                                  ,pr_des_anexo   => NULL
                                  ,pr_flg_enviar  => 'N'
                                  ,pr_des_erro    => vr_dscritic);
        -- Verificar se houve erro ao solicitar e-mail
        IF vr_dscritic IS NOT NULL THEN
          -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018  
          vr_tpocorre := 2;    -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
          vr_dstiplog := 'E';  -- I-início/ F-fim/ O-ocorrência/ E-erro   
          vr_cdcricid := 2;    -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica                                                                          
          vr_cdcritic := 1197;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||
                         ' vr_dscritic:' || vr_dscritic ||
    		                 ', pr_cdcooper:'    || pr_cdcooper ||
                         ', pr_des_destino:' || vr_emaildst ||
                         ', pr_des_assunto:' || 'Critica importacao debito - CONVENIO' ||
                         ', pr_des_corpo:'   || vr_texto_email ||
                         ', pr_des_anexo:'   || 'NULL' ||
                         ', pr_flg_enviar:'  || 'N';
          RAISE vr_exc_saida;
        END IF;
        -- Retorna nm módulo logado - Utilizada rotina que garante setar a forma de data e decimal - Cham INC0011662 - 28/03/2018     
        GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra, pr_action => NULL);	
      END IF;

      ----------------- ENCERRAMENTO DO PROGRAMA -------------------
                            
      -- Processo OK, devemos chamar a fimprg
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);

      -- Incluido controle de Log FIM programa - Chamado INC0011662 - 28/03/2018
      pc_trata_log( pr_dstiplog => 'F'
                   ,pr_tpocorre => NULL
                   ,pr_dscritic => NULL
                   ,pr_cdcritic => NULL
                   ,pr_cdcricid => NULL
                  ); 

      -- Salvar informações atualizadas
      COMMIT;
      
      -- Limpa nome do modulo logado - Chamado INC0011662 - 28/03/2018
      GENE0001.pc_informa_acesso(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      -- Excluido WHEN vr_exc_fimprg por não utilizar - 02/10/2017 - Ch 708424 
      WHEN vr_exc_saida THEN
        -- Buscar a descrição - Se foi retornado apenas código
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic);        
        -- Devolvemos código e critica encontradas das variaveis locais
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Envio centralizado de log da critica - Chamado INC0011662 - 28/03/2018
        pc_trata_log(pr_dstiplog => vr_dstiplog
                    ,pr_tpocorre => vr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                    ,pr_dscritic => pr_dscritic
                    ,pr_cdcritic => pr_cdcritic
                    ,pr_cdcricid => vr_cdcricid
                    ); 
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 02/10/2017 - Ch 708424 
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);   
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 9999;
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                       'CRPS387. '||SQLERRM||'. '; 
        -- Ajuste log de critica - Chamado INC0011662 - 28/03/2018
        pc_trata_log(pr_dstiplog => 'E'
                    ,pr_tpocorre => 2 -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                    ,pr_dscritic => pr_dscritic||'.'
                    ,pr_cdcritic => pr_cdcritic
                    ,pr_cdcricid => 2
                    ); 
        -- Efetuar rollback
        ROLLBACK;        
    END;

  END pc_crps387;
/
  