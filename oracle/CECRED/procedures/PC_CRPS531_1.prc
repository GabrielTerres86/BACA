CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS531_1 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                                -- Marcelo Telles Coelho - Projeto 475
                                                ,pr_dsxmltype   IN XMLTYPE                 --> XML descriptografado da mensagem
                                                -- ,pr_idparale     IN crappar.idparale%TYPE   --> ID do paralelo em execução
                                                -- ,pr_idprogra     IN crappar.idprogra%TYPE   --> ID sequencia em execução
                                                -- ,pr_nmarquiv     IN VARCHAR2                --> Nome do arquivo em leitura
                                                -- Fim Projeto 475
                                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                                ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN
/* ............................................................................
=====================DEBUG =======================
Para executar um DEBUG do programa é necessário alterar a janela de TEST
As alterações necessárias estão marcadas com ==>

declare
  -- Non-scalar parameters require additional processing
  pr_dsxmltype xmltype;
==>  pr_clobtype clob := 'TEXTO DA MENSAGEM A SER INTEGRADA';
begin
  -- converter clob em xmltype
  pr_dsxmltype := XMLType.createXML(pr_clobtype);
  -- Call the procedure
  cecred.pc_crps531_1(pr_cdcooper => 3,
                      pr_dsxmltype => pr_dsxmltype,
                      pr_cdcritic => :pr_cdcritic,
                      pr_dscritic => :pr_dscritic);
end;
=====================DEBUG =======================

   Programa: PC_CRPS531_1                       Antigo: Fontes/crps531_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Diego
   Data    : Setembro/2009.                     Ultima atualizacao: 14/01/2019

   Dados referentes ao programa: Fonte extraido e adaptado para execucao em
                                 paralelo. Fonte original crps531.p.

   Frequencia : Sempre que for chamado.
   Objetivo   : Integrar mensagens(TED/TEC) recebidas via SPB.

   Observacao : Quando o processo diario ainda estiver executando na cooperativa
                de destino, a mensagem nao sera processada e permanecera no
                diretorio /integra ate que finalize o processo.

   Alteracoes: 14/02/2012 - Tratar PAG0143R2 que ira substituir a PAG0106R2
                            (Diego).

               27/02/2012 - Tratamento novo catalogo de mensagens V. 3.05,
                            eliminadas mensagens STR0009R2, PAG0109R2,
                            STR0009R1, PAG0109R1, PAG0106R2 (Gabriel).

               10/04/2012 - Chamada da procedure grava-log-ted para os tipos de
                            mensagens: ENVIADO OK, ENVIADO NOK, REJEITADA OK,
                                       RECEBIDA OK, RECEBIDA NOK. (Fabricio)

               08/05/2012 - Incluida procedure processa_conta_transferida
                            para processamento doc/ted de conta transferida
                            entre cooperativas (Tiago).

               08/06/2012 - Gravar devolucao com numero de documento da mensagem
                            original enviada pelo Legado. Na Rejeicao ja estava
                            fazendo isto (Diego).

               29/06/2012 - Ajuste Log TED (David).

               30/07/2012 - Inclusão de novos parametros na procedure grava-log-ted
                            campos: cdagenci = 0, nrdcaixa = 0,
                            cdoperad = "1" (Lucas R.).

               04/12/2012 - Incluir origem da mensagem no numero de controle
                            (Diego).

               28/01/2013 - Corrigido aux_nrdocmto para pegar ultimos 8
                            caracteres do Numero de Controle das mensagens
                            recebidas de outros bancos (Diego).

               18/03/2013 - Tratamento para recebimento da STR0026R2 - VR Boleto.
                            (Fabricio)

               04/07/2013 - Ajustes na rotina de recebimento STR0026R2 referente
                            ao VR Boleto. (Rafael)

               01/11/2013 - Aumento FORMAT campo aux_idprogra "zzzz9" (Diego).

               12/12/2013 - Tratamento na procedure processa_conta_transferida
                            para contas migradas Acredi >> Viacredi; geracao
                            de arquivo. (Fabricio)

               07/01/2014 - Ajustado find da crapcob para utilizar indice (Daniel).

               13/01/2014 - Alteracao referente a integracao Progress X
                            Dataserver Oracle
                            Inclusao do VALIDATE ( Andre Euzebio / SUPERO)

               28/01/2014 - Alterado para utilizar b-crapdat.dtmvtolt
                            na geracao do arquivo de teds migradas. (Fabricio)

               18/02/2014 - Alterado na procedure gera_logspb_transferida para
                            passar como conta do credito na chamada da
                            procedure grava-log-ted, o numero da conta na
                            cooperativa destino. (Fabricio)

               21/03/2014 - Alterado o Format das contas migradas na procedure
                            gera_logspb_transferida. (Reinert)

               20/05/2014 - Retirado criacao do registro de lote (fara apenas
                            leitura e atualizacao do registro criado
                            anteriormente; pelo crps531).
                            (Chamado 158826) - (Fabricio)

               26/06/2014 - Desprezar estorno de TED de repasse de convenios.
                            (Fabricio - PRJ 019).

               23/10/2014 - Incluir a hora no lancamento da craplcm
                            (Jonata-RKAM).

               05/11/2014 - Mover mensagem para o /salvar e deletar objetos xml
                            criados, quando estorno de TED de repasse de
                            convenios (STR0007/STR0020). (Fabricio)

               14/11/2014 - Alteração na procedure processa_conta_transferida
                            para tratar a incormporação da CREDIMILSUL e
                            ACREDI (Vanessa) SD SD223543

               17/11/2014 - Alteração do E-mail destino dos alertas de
                            pagamentos de VR Boleto  (Kelvin)

               03/12/2014 - Nao verificar data do sistema na cooperativa antiga
                            que foi incorporada (Diego).

               08/01/2015 - Tratado para devolver mensagens que apresentem
                            alguma inconsistencia, destinadas a coop. antiga
                            incorporada. Estavam sendo geradas mensagens de
                            devolucao ainda pela coop. antiga, porem as mesmas
                            nao eram integradas na Cabine, pois eram geradas
                            com a data da coop. antiga. A Cabine integra somente
                            mensagens do dia atual. Este tratamento eh valido
                            enquanto a coop. antiga permanecer ativa no nosso
                            sistema(crapcop.flgativo = TRUE) (Diego).

               19/01/2015 - Adição dos parâmetros "arq" e "coop" na chamada do
                            fonte mqcecred_envia.pl. (Dionathan)
               13/04/2015 - Inclusão parametro na  procedure proc_opera_st para
                            tratar as alterações solicitadas no SD271603 FDR041
                            (Vanessa)

               26/05/2015 - Alterado para tratar mensagens de portabilidade de
                            credito. (Reinert).

               10/07/2015 - Validar se a cooperativa esta ativa no sistema,
                            crapcop.flgativo (Diego).

               21/07/2015 - Alterações relacionadas ao Projeto Nova FOLHAIB (Vanessa).

               11/08/2015 - Ajustado proc. verifica_conta, adicionado verificacao
                            caso conta seja migrada, fazer validacao da conta
                            nova. (Jorge/Rodrigo) - SD 308188

               18/09/2015 - Tratamento na procedure processa_conta_transferida
                            para contas migradas Viacredi >> Alto Vale
                            (Douglas - Chamado 288683)

               22/10/2015 - Adicionado verificacao do cpf do TED com o cpf da
                            conta em proc. verifica_conta.
                            (Jorge/Elton) - SD 338096

               29/10/2015 - Inclusao de verificacao estado de crise.
                            (Jaison/Andrino)

               10/12/2015 - Ajustado a rotina importa_xml para substituir
                            o caracter especial chr(216) e chr(248) por "O"
                            pois caracter invalida o xml, fazendo que as informacoes
                            depois dessa tag sejam ignoradas.
                            SD347591 (Odirlei-AMcom)

               08/01/2015 - Alterado procedimento pc_solicita_email para chamar
                            a rotina convertida na b1wgen0011.p
                            SD356863 (Odirlei-AMcom)

               02/02/2016 - Adicionar tratamento para nao permitir realizar
                            TED/TEC das contas migradas ACREDI >> VIACREDI
                            (Douglas - Chamado 366322)

               11/05/2016 - Adicionar tratamento para nao permitir realizar
                            TED/TEC das contas migradas VIACREDI >> ALTO VALE
                            (Douglas - Chamado 406267)

               30/05/2016 - Adicionar tipo de pessoa juridica na pesquisa de contas
                            da verifica_conta (Douglas - Chamado 406267)

               05/07/2016 - Ajuste para considerar inpessoa > 1 ao validar contas
                            juridicas (Adriano - SD 480514).

               14/09/2016 - Ajuste para utilizar uma sequence na geracao do numero
                            de controle, garantindo sua unicidade
                            (Adriano - SD 518645).

               01/12/2016 - Tratamento credito TED/TEC Transposul (Diego).

               06/12/2016 - Incluido mensagens STR0025 E PAG0121 referente ao
                            Bacenjud (Prj 341 - Andrino - Mouts)

               05/01/2017 - Ajuste para retirada de caracterer especiais
                            (Adriano - SD 556053)

               17/01/2017 - Ajuste para retirada de caracterer especiais
                            (Adriano - SD 594482)

               15/02/2017 - Ajuste para devolver mensagem STR00010 para mensagens
                            STR0006R2, PAG0142R2 (Adriano - SD 553778).

               11/05/2017 - Ajuste para que as mensagens de TED que recebemos sejam
                            gravadas na nova estrutura, e gravar as mensagens de
                            devoluçao (Douglas - Chamado 524133)

               23/05/2017 - Ajuste para devolver as mensagens PAG0142R2 como
                            PAG0111 (Douglas - Chamado 524133)

               02/06/2017 - Ajustes referentes ao Novo Catalogo do SPB (Lucas Ranghetti #668207)
                            - Enviar e-mail interbancario para a mensagem STR0003R2 (Lucas Ranghetti #654769)

               30/06/2017 - Ajustado os parametros passados na chamada da
                            pc_gera_log_batch (Douglas - Chamado 524133)

               04/07/2017 - Ajustar as procedures grava_mensagem_ted e grava_ted_rejeitada
                            para gerar as mensagens de erro no arquivo de log
                            crps531_DDMMYYYY.log (Douglas - Chamado 524133)

               07/07/2017 - Ajustar a gravacao do XML da mensagem de TED, para ser feito apenas
                            quando o retorno da verifica_processo for OK (Douglas - Chamado 524133)

               14/07/2017 - Ajustar a procedure deleta_objetos para validar se o handle do objeto eh
                            valido para que seja excluido (Douglas - Chamado 524133)

               01/08/2017 - Conversão Progress >> Oracle PLSQL (Andrei-Mouts)

               09/08/2017 - Inclusao da verificacao do produto TR. (Jaison/James - PRJ298)

               18/08/2017 - Ajuste para efetuar o controle de lock ao realizar a atualizacao
                            da tabela craplfp (Adriano - SD 733103).

               10/10/2017 - Alteracoes melhoria 407 (Mauricio - Mouts)

               06/11/2017 - Alteração no tratamento da mensagem LTR0005R2 (Mauricio - Mouts)

               24/11/2017 - Alteração no tratamento da mensagem LTR0005R2 e tratamento da mensagem SLC0001 (Mauricio - Mouts)

               11/12/2017 - Inclusão do parametro par_cdmensagem - Codigo da mensagem ou critica
                            (Belli - Envolti - Chamado 786752)

               14/12/2017 - Implementação procedure trata_arquivo_ldl (Alexandre Borgmann - Mouts)

               19/12/2017 - Efetuado alteracao para validar corretamente o tipo de pessoa e conta (Jonata - MOUTS).

               29/12/2017 - Tratamento mensagem LDL0020R2,LDL0022,LTR0004 (Alexandre Borgmann - Mouts)

               18/01/2018 - Tratar mensagem STR0006R2 para Cielo (Alexandre Borgmann - Mouts)

               31/01/2018 - Inclusão das ultimas alterações pós-conversão (Andrei-Mouts)

               14/02/2018 - Tratar mensagens CIR0020 e CIR0021, incluir o tratamento junto com a mensagem STR0003R2
                            SD 805540 - Marcelo Telles Coelho-Mouts

               14/03/2018 - Tratar recebimento de TED destinada a contas administradoras de recursos (Rodrigo Heinzle - Supero)

			   16/03/2018 - Ajustado tamanho de variável (Adriano).

			   23/04/2018 - Ajuste para buscar corretamente a cooperativa (Adriano - Homol conversão).
			   
			   15/05/2018 - Bacenjud SM 1 - Heitor (Mouts)

			   18/05/2018 - Ajuste para gerar criticas em contas encerradas (CRAPASS.CDSITDCT = 4)

			   28/05/2018 - Ajustes efetuados:
						    > Para pegar corretamente o número de controle
							> Efetuar devolução para cooperativa coorreta
							(Adriano - INC0016217 ).
              
         30/05/2018 - Ajustes para retirar a validação de IFs incorporadas, pois
                      como foram desatividas, deverá gearar devolução pela cooperativa central
                      (Adriano)

			  04/06/2018 - Ajuste para colocar o uppper na leitura da tabela craptvl, pois está impactando
			               na performance do programa (Adriano - INC0016439).

        06/06/2018 - Ajustes efetuados:
				     > Substituir caracteres especiais;
					 > Ajuste par anão gerar devolução STR0048 indevidamente;
                     (Adriano - INC0016740/INC0016813).
        
         08/06/2018 - Ajuste para enviar e-mail referente a TEC salário somente se nas devoluções
                     (Adriano - REQ0016678).
                     
		     13/06/2018 - Ajuste para inicializar variável  de estado de crise (Adriano).
                     
			 28/06/2018 - Ajuste no controle de envio do arquivo para a pasta "salvar"
				         (Adriano - INC0018303).

			 02/07/2018 - Ajuste na utilização da função SYSDATE somente na geração dos logs,
                    nos demais locais que irão gerar dados em tabelas, irá utilizar a mesma
                    variavel global que terá o mesmo horário (HRTRANSA). Evitando erros na
                    impressão do comprovante do extrato na conta do cooperado.
				           (Wagner - PRB0040144).

			 05/07/2018 - Ajuste para considerar cooperativa ativa (Adriano - PRB0040134).

             17/07/2018 - Ler mensagem str0004R2 para AILOS SCTASK0016979-Recebimento das Liquidacoes da Cabal - Everton Souza (Mouts)
             
             08/08/2018 - INC0021763 - Ajustar a regra de devolução de TEDs para que a mesma seja devolvidas 
                          automáticamente para contas encerradas, independente do tipo. (Renato Darosci)				
             
             10/08/2018 - Salvar arquivos STR0004R2 recusados e gravar historico nulo nas mensagens
                          STR0004R2 e STR0006R2. PRJ486 (Lombardi)
             
             01/09/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA - SPRINT B
                          Marcelo Telles Coelho - Mouts

			 02/10/2018 - Adicionado busca do banco de debito na crapban antes de inserir na tbfin_recursos_movimento - Protesto IEPTB - (Fabio Stein - Supero)
                          
             12/09/2018 - Substituido insert na craplcm para utilizar rotina centralizadora LANC0001.
                          PRJ450 - Regulatorio (Odirlei-AMcom)    
                          
	     29/10/2018 - Ajustes efetuados:
                          > Passado o código da cooperativa, correto, na chamada da rotina pc_efetua_baixa_titulo;
                          > Incluido a passagem do parâmetro pr_nrispbpg na chamada das rotinas paga0001.pc_processa_liquidacao,
                            paga0001.pc_proc_liquid_apos_baixa.
                          (Adriano - PRB0040386).

             01/11/2018 - Ignorar confirmação STR0008R1 para TEDs de protesto (P352 - Cechet)
                          
             17/10/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA - SPRINT C
                          Jose Dill - Mouts
                          
             02/01/2019 - Tratamento para STR0006R2 - Pagto de boletos em cartório (Lucas Afonso/Cechet)                          
                          
             14/01/2019 - Tratamento para STR0006R2, contas 10000003 e 20000006, agencia 100 = Pagto de boletos
                          em cartorio (Lucas Afonso/Cechet)
 
			 16/01/2019 - Revitalizacao (Remocao de lotes) - Pagamentos, Transferencias, Poupanca
                     Heitor (Mouts)

			 07/12/2018 - Alterações referentes ao projeto 475 - MELHORIAS SPB CONTINGÊNCIA - SPRINT D
                          Jose Dill - Mouts
                          
       12/02/2019 - Ajuste da revitalização de lotes craplcm 
                    Jose Dill - Mout (INC0032794)  
                    
       06/03/2019 - Permitir as mensagens SEL e RDC executarem com o processo rodando. 
                    Jose Dill - Mouts              
                    
       26/03/2019 - Inclusão do rollback para vr-boleto 
                    Jose Dill - Mouts (PRB0040712)    

			 06/08/2019 - Inclusão de PA e Caixa na mensagem de devolução de TED em espécie (RITM0022091 - Diógenes Lazzarini)						
 
             #######################################################
             ATENCAO!!! Ao incluir novas mensagens para recebimento,
             lembrar de tratar a procedure gera_erro_xml.
             #######################################################

   ............................................................................ */
  DECLARE

    -- Constantes do programa
    vr_glb_cdprogra  CONSTANT crapprg.cdprogra%TYPE := 'crps531';
    vr_glb_cdagenci CONSTANT NUMBER := 1;
    vr_glb_cdbccxlt CONSTANT NUMBER := 100;
    vr_glb_nrdolote CONSTANT NUMBER := 10115;
    vr_glb_tplotmov CONSTANT NUMBER := 1;
    vr_glb_dataatual CONSTANT DATE := SYSDATE;

    -- Tratamento de erros
    vr_exc_next   EXCEPTION;
    vr_exc_saida  EXCEPTION;
    vr_exc_lock   EXCEPTION;

    -- Erro em chamadas da pc_gera_erro
    vr_des_reto     VARCHAR2(3);
    vr_tab_erro     GENE0001.typ_tab_erro;
    vr_cdcritic     NUMBER;
    vr_dscritic     VARCHAR2(4000);
    vr_typ_saida    VARCHAR2(3000);
    vr_des_saida    VARCHAR2(4000);
    vr_logprogr     VARCHAR2(1000);
    vr_nmarqlog     VARCHAR2(1000);
    vr_des_erro     VARCHAR2(1000);
    vr_tab_retorno  lanc0001.typ_reg_retorno;
    vr_incrineg     INTEGER;

	rw_craplot_rvt lote0001.cr_craplot_sem_lock%rowtype;
    vr_nrseqdig    craplot.nrseqdig%type;

    /* Busca dos dados da cooperativa */
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nrtelura
            ,GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                  ,pr_cdcooper => cop.cdcooper) dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop_central cr_crapcop%ROWTYPE;
    rw_crapcop_mensag cr_crapcop%ROWTYPE;
    rw_crapcop_portab cr_crapcop%ROWTYPE;
    rw_crapcop_MSG    cr_crapcop%ROWTYPE; -- Marcelo Telles Coelho - Projeto 475
    
    /* Busca dos dados da cooperativa */
    CURSOR cr_busca_coop(pr_cdagectl IN crapcop.cdagectl%TYPE
                     ,pr_flgativo IN crapcop.flgativo%TYPE DEFAULT NULL) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nrtelura
            ,GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                  ,pr_cdcooper => cop.cdcooper) dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdagectl = pr_cdagectl
         AND cop.flgativo = nvl(pr_flgativo,cop.flgativo);

    /* Busca dos dados da cooperativa pela conta*/
    CURSOR cr_busca_coop_conta(pr_nrctactl IN crapcop.nrctactl%TYPE
                              ,pr_flgativo IN crapcop.flgativo%TYPE DEFAULT NULL) IS
      SELECT cop.cdcooper
            ,cop.nmrescop
            ,cop.nrtelura
            ,GENE0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                  ,pr_cdcooper => cop.cdcooper) dsdircop
            ,cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.nrctactl = pr_nrctactl
         AND cop.flgativo = nvl(pr_flgativo,cop.flgativo);

    /* Cursor genérico de calendário */
    rw_crapdat_central btch0001.cr_crapdat%ROWTYPE;
    rw_crapdat_mensag btch0001.cr_crapdat%ROWTYPE;
    rw_crapdat_portab btch0001.cr_crapdat%ROWTYPE;

    /* Variaveis genéricos */
    vr_aux_dtintegr DATE;
    vr_aux_flestcri NUMBER;
    vr_aux_inestcri NUMBER := 0;

    /* Variavel para manter arquivo fisico */
    vr_aux_manter_fisico BOOLEAN;
    /* Variavel para armazenar/remover as mensagens de TED processadas */
    vr_msgspb_mover  NUMBER;
    /* Variavel para armazenar as mensagens de TED que nao serao copiadas */
    vr_msgspb_nao_copiar VARCHAR2(4000);

    /* Estrutura para Estado de Crise */
    vr_tab_estad_crise sspb0001.typ_tab_estado_crise;

    /* Variaveis para o processamento do XML */
    vr_aux_CodMsg               VARCHAR2(20);
    vr_aux_NrOperacao           VARCHAR2(100);
    vr_aux_NumCtrlRem           VARCHAR2(100);
    vr_aux_NumCtrlIF            VARCHAR2(100);
    vr_aux_ISPBIFDebtd          VARCHAR2(100);
    vr_aux_BancoDeb             NUMBER := 0;
    vr_aux_AgDebtd              VARCHAR2(100);
    vr_aux_CtDebtd              VARCHAR2(100);
    vr_aux_CNPJ_CPFDeb          VARCHAR2(100);
    vr_aux_NomCliDebtd          VARCHAR2(100);
    vr_aux_ISPBIFCredtd         VARCHAR2(100);
    vr_aux_BancoCre             NUMBER := 0;
    vr_aux_AgCredtd             VARCHAR2(100);
    vr_aux_CtCredtd             VARCHAR2(100);
    vr_aux_CNPJ_CPFCred         VARCHAR2(100);
    vr_aux_NomCliCredtd         VARCHAR2(100);
    vr_aux_NomArqSLC            VARCHAR2(200);
    vr_aux_NumCtrlLTROr         VARCHAR2(100);
    vr_aux_IndrDevLiquid        VARCHAR2(100);
    vr_aux_NumCtrlEmissorArq    VARCHAR2(100);
    vr_aux_TpTranscSLC          VARCHAR2(100);
    vr_aux_TpPessoaCred         VARCHAR2(100);
    vr_aux_CodDevTransf         VARCHAR2(100);
    vr_aux_TpCtCredtd           VARCHAR2(100);
    vr_aux_CtPgtoCredtd         VARCHAR2(100);
    vr_aux_DtHRBC               VARCHAR2(100);
    vr_aux_CtPgtoDebtd          VARCHAR2(100);
    vr_aux_TpCtDebtd            VARCHAR2(100);
    vr_aux_CodMunicOrigem       VARCHAR2(100);
    vr_aux_CodMunicDest         VARCHAR2(100);
    vr_aux_DsVlrLanc            VARCHAR2(100);
    vr_aux_VlrLanc              NUMBER;
    vr_aux_CdLegado             VARCHAR2(100);
    vr_aux_IdentcDep            VARCHAR2(100);
    vr_aux_NumCodBarras         VARCHAR2(100);
    vr_aux_DtMovto              VARCHAR2(100);
    vr_aux_SitLanc              VARCHAR2(100);
    vr_aux_dadosdeb             VARCHAR2(100);
    vr_aux_codierro             NUMBER := 0;
    vr_aux_dsdehist             VARCHAR2(1000);
    vr_aux_tagCABInf            BOOLEAN := FALSE;
    vr_aux_nrctacre             NUMBER := 0;
    vr_aux_nrconven             NUMBER := 0;
    vr_aux_nrdconta             NUMBER := 0;
    vr_aux_nrdocmto             NUMBER := 0;
    vr_aux_msgrejei             VARCHAR2(300);
    vr_aux_nmdirxml             VARCHAR2(300);
    vr_aux_nmarqxml             VARCHAR2(300);
    vr_aux_flgderro             BOOLEAN := FALSE;
    vr_aux_nrctrole             VARCHAR2(100);
    vr_aux_cdageinc             NUMBER := 0;
    vr_aux_nrctremp             NUMBER := 0;
    vr_aux_tpemprst             NUMBER := 2;
    vr_aux_qtregist             NUMBER := 0;
    vr_aux_vlsldliq             NUMBER := 0;
    vr_aux_Hist                 VARCHAR2(200);
    vr_aux_FinlddCli            VARCHAR2(100);
    vr_aux_NumCtrlLTR           VARCHAR2(100);
    vr_aux_ISPBLTR              VARCHAR2(100);
    vr_aux_IdentdPartCamr       VARCHAR2(100);
    vr_aux_NumCtrlSTR           VARCHAR2(100);
    vr_aux_NumCtrlSLC           VARCHAR2(100);
    vr_aux_ISPBIF               VARCHAR2(100);
    vr_aux_TpInf                VARCHAR2(100);
    vr_aux_DtHrSLC              VARCHAR2(100);
    vr_aux_NumSeqCicloLiquid    VARCHAR2(100);
    vr_aux_DtLiquid             VARCHAR2(100);
    vr_aux_IdentdLinhaBilat     VARCHAR2(100);
    vr_aux_TpDeb_Cred           VARCHAR2(100);
    vr_aux_CNPJNLiqdantDebtd    VARCHAR2(100);
    vr_aux_CNPJNLiqdantCredtd   VARCHAR2(100);
    vr_aux_IdentLinhaBilat      VARCHAR2(100);
    vr_aux_TpDebCred            VARCHAR2(100);
    vr_aux_CNPJNLiqdant         VARCHAR2(100);
    vr_aux_FinlddIF             VARCHAR2(100);
    vr_aux_TpPessoaDebtd_Remet  VARCHAR2(100);
    vr_aux_NumCtrlCIROr         VARCHAR2(100); /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
    vr_aux_NumCtrlCIR           VARCHAR2(100); /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
    vr_aux_NumRemessaOr         VARCHAR2(100); /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
    vr_aux_AgIF                 VARCHAR2(100); /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
    vr_aux_FinlddCIR            VARCHAR2(100); /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
    vr_aux_SubTpAtv             VARCHAR2(100); /* Sprint D - Req19*/
    vr_aux_DsVlrFinanc          VARCHAR2(100); /* Sprint D - Req19*/
    vr_aux_CtCed                VARCHAR2(100); /* Sprint D - Req19*/
    vr_aux_DtAgendt             VARCHAR2(100); /* Sprint D - Req19*/   
    vr_idprglog tbgen_prglog.idprglog%type     := 0;
    vr_aux_valor                NUMBER(15,2) := NULL;
    vr_aux_valor_char           VARCHAR2(100) := NULL;
 
    vr_aux_TPCONTA_CREDITADA    VARCHAR2(2);
    vr_aux_NMTITULAR_CREDITADA  VARCHAR2(80);
    vr_aux_DSCONTA_CREDITADA    VARCHAR2(13);
    VR_AUX_CDAGENCI_CREDITADA   NUMBER(5);


    vr_aux_msgderro       VARCHAR(1000);
    vr_tab_situacao_if    SSPB0001.typ_tab_situacao_if;
    vr_aux_nrispbif       NUMBER;
    vr_aux_cddbanco       NUMBER;
    vr_aux_nmdbanco       VARCHAR2(300);
    vr_aux_CodProdt       VARCHAR2(300);
    vr_aux_dtinispb       VARCHAR2(300);
    vr_aux_flgrespo       NUMBER;
    vr_aux_NUPortdd       VARCHAR2(300);
    vr_aux_cdtiptrf       NUMBER;
    vr_aux_dsarqenv       VARCHAR2(1000);

    /* Variáveis da LDL */

    vr_aux_CodGrdLDL      VARCHAR2(30);
    vr_aux_DtHrAbert      VARCHAR2(30);
    vr_aux_DtHrFcht       VARCHAR2(30);
    vr_aux_TpHrio         VARCHAR2(30);
    vr_aux_DtRef          VARCHAR2(30);

    -- Variaveis auxiliares
    vr_aux_dstextab       craptab.dstextab%TYPE;
    vr_log_msgderro       VARCHAR2(1000);
    vr_aux_vlrjuros       NUMBER;
    vr_aux_vlrmulta       NUMBER;
    vr_aux_vldescto       NUMBER;
    vr_aux_vlabatim       NUMBER;
    vr_aux_vlfatura       NUMBER;
    vr_aux_flgvenci       BOOLEAN;
    vr_aux_liqaposb       BOOLEAN;
    vr_aux_cdbanpag       NUMBER;
    vr_aux_dsmotivo       VARCHAR2(100);
    vr_ret_nrremret       NUMBER;
    vr_aux_nrridflp       NUMBER;
    vr_aux_dsdemail       VARCHAR2(4000);    

    -- Pagamentos de titulos
    vr_tab_lcm_consolidada paga0001.typ_tab_lcm_consolidada;
    vr_tab_descontar       paga0001.typ_tab_titulos;
    vr_tab_titulosdt       paga0001.typ_tab_titulos;
    vr_idx_descontar       VARCHAR2(20);

    /* Temp-table para Numerarios */
    TYPE typ_reg_numerario IS RECORD(cdcatego NUMBER
                                    ,vlrdenom NUMBER
                                    ,qtddenom NUMBER);
    TYPE typ_tab_numerario IS TABLE OF typ_reg_numerario
                              INDEX BY PLS_INTEGER;
    vr_tab_numerario typ_tab_numerario;

    /* Temp-table para CIR0060 */
    -- Sprint D Req51
    TYPE typ_reg_numerario_cir0060 IS RECORD(NumRemessa VARCHAR2(500)
                                    ,DtLimEntr VARCHAR2(20));
    TYPE typ_tab_numerario_cir0060 IS TABLE OF typ_reg_numerario_cir0060
                              INDEX BY PLS_INTEGER;
    vr_tab_numerario_cir0060 typ_tab_numerario_cir0060;

    /* Registro de TED */
    CURSOR cr_craptvl(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_idopetrf VARCHAR2) IS
      SELECT nmpesrcb
            ,vldocrcb
            ,nrdconta
            ,nmpesemi
            ,cpfcgemi
            ,cdbccrcb
            ,cdagercb
            ,nrcctrcb
            ,cpfcgrcb
            ,tpdctacr
            ,dshistor
            ,ROWID
			,nrridlfp 
            ,nrdocmto
            ,cdagenci
            ,nrdolote
        FROM craptvl 
       WHERE craptvl.cdcooper = pr_cdcooper
         AND craptvl.tpdoctrf = 3
         AND UPPER(craptvl.idopetrf) = UPPER(pr_idopetrf);
    rw_craptvl cr_craptvl%ROWTYPE;

    /* Buscar dados do banco */
    CURSOR cr_crapban(pr_cdbccxlt craptvl.cdbccrcb%TYPE DEFAULT NULL
                     ,pr_nrispbif crapban.nrispbif%TYPE DEFAULT NULL) IS
      SELECT nrispbif
            ,cdbccxlt
        FROM crapban
       WHERE cdbccxlt = NVL(pr_cdbccxlt,cdbccxlt)
         AND nrispbif = NVL(pr_nrispbif,nrispbif);
    rw_crapban cr_crapban%ROWTYPE;

    /* Registro de TEC Salário */
    CURSOR cr_craplcs(pr_cdcooper crapcop.cdcooper%type
                     ,pr_idopetrf VARCHAR2) IS
      SELECT lcs.vllanmto
            ,lcs.nrdconta
            ,ccs.nmfuncio
            ,ccs.nrcpfcgc
            ,ccs.cdbantrf
            ,ccs.cdagetrf
            ,ccs.nrctatrf
            ,ccs.nrdigtrf
            ,lcs.rowid
        FROM craplcs lcs
            ,crapccs ccs
       WHERE lcs.cdcooper = pr_cdcooper
         AND lcs.idopetrf = pr_idopetrf
         AND lcs.cdcooper = ccs.cdcooper
         AND lcs.nrdconta = ccs.nrdconta;
    rw_craplcs cr_craplcs%ROWTYPE;

    -- Buscar convênio Boleto
    CURSOR cr_crapcco(pr_nrconven NUMBER) IS
      SELECT cdcooper
            ,cddbanco
            ,nrdctabb
            ,nrconven
            ,cdagenci
            ,cdbccxlt
            ,nrdolote
        FROM crapcco
       WHERE nrconven = pr_nrconven
         AND dsorgarq <> 'MIGRACAO'
       ORDER BY cdcooper;
    rw_crapcco cr_crapcco%ROWTYPE;

    -- Buscar Boleto
    CURSOR cr_crapcob(pr_cdcooper crapcob.cdcooper%TYPE
                     ,pr_cdbandoc crapcob.cdbandoc%TYPE
                     ,pr_nrdctabb crapcob.nrdctabb%TYPE
                     ,pr_nrcnvcob crapcob.nrcnvcob%TYPE
                     ,pr_nrdconta crapcob.nrdconta%TYPE
                     ,pr_nrdocmto crapcob.nrdocmto%TYPE) IS
      SELECT crapcob.cdcooper
            ,crapcob.incobran
            ,crapcob.vlabatim
            ,crapcob.vltitulo
            ,crapcob.dtvencto
            ,crapcob.vldescto
            ,crapcob.vlrmulta
            ,crapcob.vljurdia
            ,crapcob.cdmensag
            ,crapcob.insitcrt
            ,crapcob.tpdmulta
            ,crapcob.tpjurmor
            ,crapcob.rowid
        FROM crapcob
       WHERE crapcob.cdcooper = pr_cdcooper
         AND crapcob.cdbandoc = pr_cdbandoc
         AND crapcob.nrdctabb = pr_nrdctabb
         AND crapcob.nrcnvcob = pr_nrcnvcob
         AND crapcob.nrdconta = pr_nrdconta
         AND crapcob.nrdocmto = pr_nrdocmto;
    rw_crapcob cr_crapcob%ROWTYPE;

    -- Buscar conta transferida
    CURSOR cr_craptco(pr_cdcooper NUMBER DEFAULT NULL
                     ,pr_cdcopant NUMBER DEFAULT NULL
                     ,pr_ntctaant NUMBER
                     ,pr_flgativo NUMBER DEFAULT NULL
                     ,pr_tpctatrf NUMBER DEFAULT NULL) IS
      SELECT cdcooper
            ,nrdconta
            ,cdcopant
            ,nrctaant
        FROM craptco
       WHERE cdcooper = NVL(pr_cdcooper,cdcooper)
         AND cdcopant = NVL(pr_cdcopant,cdcopant)
         AND nrctaant = pr_ntctaant
         AND flgativo = NVL(pr_flgativo,flgativo)
         AND tpctatrf = NVL(pr_tpctatrf,tpctatrf);
    rw_craptco cr_craptco%ROWTYPE;

    -- Buscar associado
    CURSOR cr_crapass(pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_nrcpfcgc NUMBER default NULL
                     ,pr_flgjurid NUMBER default 0) IS
      SELECT inpessoa
            ,nrcpfcgc
            ,dtelimin
            ,cdsitdct
        FROM crapass
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcpfcgc = NVL(pr_nrcpfcgc,nrcpfcgc)
         -- Se foi solicitado PJ, então pesquisa inpesssoa > 1
         AND (pr_flgjurid = 0 OR inpessoa > 1);
    rw_crapass cr_crapass%ROWTYPE;

    -- Buscar titular
    CURSOR cr_crapttl(pr_cdcooper NUMBER
                     ,pr_nrdconta NUMBER
                     ,pr_nrcpfcgc NUMBER DEFAULT NULL) IS
      SELECT nrcpfcgc
        FROM crapttl
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrcpfcgc = NVL(pr_nrcpfcgc,nrcpfcgc);
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Cursor Capa do Lote
    CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE
                     ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                     ,pr_cdagenci IN craplot.cdagenci%TYPE
                     ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                     ,pr_nrdolote IN craplot.nrdolote%TYPE)  IS
    SELECT lot.dtmvtolt
          ,lot.cdagenci
          ,lot.cdbccxlt
          ,lot.nrdolote
          ,NVL(lot.nrseqdig,0) nrseqdig
          ,lot.cdcooper
          ,lot.tplotmov
          ,lot.vlinfodb
          ,lot.vlcompdb
          ,lot.qtinfoln
          ,lot.qtcompln
          ,lot.cdoperad
          ,lot.tpdmoeda
          ,lot.rowid
      FROM craplot lot
     WHERE lot.cdcooper = pr_cdcooper
       AND lot.dtmvtolt = pr_dtmvtolt
       AND lot.cdagenci = pr_cdagenci
       AND lot.cdbccxlt = pr_cdbccxlt
       AND lot.nrdolote = pr_nrdolote
       FOR UPDATE;
    rw_craplot cr_craplot%ROWTYPE;

    /* Registro de Lancamento no Dia */
    CURSOR cr_craplcm_exis(pr_cdcooper craplcm.cdcooper%type
                          ,pr_dtmvtolt craplcm.dtmvtolt%type
                          ,pr_cdagenci craplcm.cdagenci%type
                          ,pr_cdbccxlt craplcm.cdbccxlt%type
                          ,pr_nrdolote craplcm.nrdolote%type
                          ,pr_nrdctabb craplcm.nrdctabb%type
                          ,pr_nrdocmto craplcm.nrdocmto%type) IS
      SELECT 1
            ,lcm.vllanmto
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdagenci = pr_cdagenci
         AND lcm.cdbccxlt = pr_cdbccxlt
         AND lcm.nrdolote = pr_nrdolote
         AND lcm.nrdctabb = pr_nrdctabb
         AND lcm.nrdocmto = pr_nrdocmto;
    vr_aux_existlcm NUMBER;
    vr_aux_vllanmto NUMBER;

    -- Projeto 475 Sprint C 
    -- Validar hora fim da grade PAG 
    CURSOR cr_crapcop_grade(pr_cdcooper craplcm.cdcooper%type) is
    SELECT CASE
         WHEN GENE0002.fn_busca_time > copg.fimoppag THEN
           '1' -- Fora do horário
         ELSE
           '2' -- Dentro do horário
         END flg_dtmvto_pag
    FROM crapcop copg
    WHERE copg.cdcooper = pr_cdcooper;
    rw_crapcopgrade cr_crapcop_grade%ROWTYPE;    
    
    -- Projeto 475 Sprint C Req04 
    -- Buscar a cooperativa e o número da conta na tabela enviada
    CURSOR cr_tbspbmsgenv_coop (pr_nrcontrole_if IN tbspb_msg_enviada.nrcontrole_if%type) IS
    SELECT tme.cdcooper
          ,tme.nrdconta
    FROM tbspb_msg_enviada tme
    WHERE tme.nrcontrole_if = pr_nrcontrole_if;
       
    rw_tbspbmsgenv_coop cr_tbspbmsgenv_coop%ROWTYPE;    

    -- Variaveis Projeto 475
    vr_nrseq_mensagem_xml       TBSPB_MSG_XML.NRSEQ_MENSAGEM_XML%TYPE;
    vr_nrseq_mensagem           TBSPB_MSG_ENVIADA.nrseq_mensagem%TYPE;
    vr_nrseq_mensagem_fase      TBSPB_MSG_ENVIADA_FASE.nrseq_mensagem_fase%TYPE;
    vr_aux_tagCABInfConvertida  BOOLEAN := FALSE;
    vr_aux_tagCABInfCCL         BOOLEAN := FALSE;
    vr_aux_CabInf_erro          BOOLEAN := FALSE;
    vr_aux_CabInf_reenvio       BOOLEAN := FALSE;
    vr_nrcontrole_if            TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE;
    vr_aux_NumCtrlRem_Or        VARCHAR2(100);
    vr_dtmovimento              DATE;
    vr_trace_dsxml_mensagem     CLOB;
    vr_trace_cdfase             TBSPB_MSG_ENVIADA_FASE.CDFASE%TYPE;
    vr_trace_idorigem           TBSPB_MSG_XML.INORIGEM_MENSAGEM%TYPE;
    vr_trace_nmmensagem         TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE;
    vr_trace_nmmensagem_XML     TBSPB_MSG_ENVIADA.NMMENSAGEM%TYPE;
    vr_trace_nrcontrole_if      TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE;
    vr_trace_nrcontrole_str_pag TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE;
    vr_trace_nrcontrole_dev     TBSPB_MSG_ENVIADA.NRCONTROLE_IF%TYPE;
    vr_trace_cdcooper           TBSPB_MSG_ENVIADA.CDCOOPER%TYPE;
    vr_trace_nrdconta           TBSPB_MSG_ENVIADA.NRDCONTA%TYPE;
    vr_trace_inenvio            VARCHAR2(01);
    vr_trace_dhdthr_bc          DATE;
    vr_node_valor               VARCHAR2(1000);
    vr_inmsg_GEN                VARCHAR2(01);
    vr_nmremetente              VARCHAR2(100);
    vr_dsdevolucao              craptab.dstextab%TYPE;    
    vr_aux_CD_SITUACAO          VARCHAR2(100);
    vr_aux_dtmovto_aux          VARCHAR2(10);


    -- Rotina para validar a conta
    PROCEDURE pc_verifica_conta(pr_cdcritic OUT NUMBER
                               ,pr_dscritic OUT VARCHAR) IS
      --
      CURSOR cr_conta(pr_cdcooper tbfin_recursos_conta.cdcooper%TYPE
                     ,pr_nrdconta tbfin_recursos_conta.nrdconta%TYPE
                     ) IS
        SELECT trc.nmtitular
          FROM tbfin_recursos_conta trc
         WHERE trc.cdcooper = pr_cdcooper
           AND trc.nrdconta = pr_nrdconta;
      rw_conta cr_conta%ROWTYPE;
      
      -- Variaveis locais
      vr_val_cdcooper NUMBER;
      vr_val_nrdconta NUMBER;
      vr_val_tppessoa VARCHAR2(10);
      vr_val_nrcpfcgc NUMBER;
      vr_val_tpdconta VARCHAR2(10);
      vr_val_nrdctapg VARCHAR2(100);
      -- Buffers locais
      rw_b_crapcop cr_busca_coop%rowtype;
      rw_b_crapdat btch0001.cr_crapdat%rowtype;

    BEGIN

      -- Incializar as variaveis
      vr_val_cdcooper := rw_crapcop_mensag.cdcooper;
      vr_val_nrdconta := to_number(vr_aux_CtCredtd);
      IF vr_aux_CodMsg = 'STR0047R2' THEN
        vr_val_tppessoa := 'J'; -- Conta das filiadas na CECRED
      ELSE
        vr_val_tppessoa := vr_aux_TpPessoaCred;
      END IF;
      vr_val_nrcpfcgc := to_number(vr_aux_CNPJ_CPFCred);
      vr_val_tpdconta := vr_aux_TpCtCredtd;
      vr_val_nrdctapg := vr_aux_CtPgtoCredtd;

      -- Tratar tamanho da conta
      IF LENGTH(vr_val_nrdconta) > 9 THEN
        -- Conta invalida
        pr_cdcritic := 2;
        pr_dscritic := 'Conta informada invalida.';
      ELSE
        IF vr_val_tpdconta = 'PG' OR vr_val_nrdctapg IS NOT NULL THEN
          -- Conta invalida
          pr_cdcritic := 2;
          pr_dscritic := 'Tipo de Conta Incorreto.';
          vr_aux_CtCredtd := vr_val_nrdctapg;
          RETURN;
        END IF;

        -- Para Incorporação Transulcred
        IF vr_aux_cdageinc > 0 THEN
          -- Identifica cooperativa antiga
          OPEN cr_busca_coop(pr_cdagectl => vr_aux_cdageinc);
          FETCH cr_busca_coop
           INTO rw_b_crapcop;
          CLOSE cr_busca_coop;
          -- Buscar nova conta
          OPEN cr_craptco(pr_cdcooper => vr_val_cdcooper
                         ,pr_cdcopant => rw_b_crapcop.cdcooper
                         ,pr_ntctaant => vr_val_nrdconta);
          FETCH cr_craptco
           INTO rw_craptco;
          -- Se encontrou
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            -- Usar Nova conta
            vr_val_nrdconta := rw_craptco.nrdconta;
          ELSE
            CLOSE cr_craptco;
            -- Conta invalida
            pr_cdcritic := 2;
            pr_dscritic := 'Conta informada invalida.';
            RETURN;
          END IF;
        ELSE
          -- Buscar nova conta
          OPEN cr_craptco(pr_cdcopant => vr_val_cdcooper
                         ,pr_ntctaant => vr_val_nrdconta
                         ,pr_flgativo => 1
                         ,pr_tpctatrf => 1);
          FETCH cr_craptco
           INTO rw_craptco;
          -- Se encontrou
          IF cr_craptco%FOUND THEN
            CLOSE cr_craptco;
            -- Verificar se conta foi migrada ACREDI >> VIACREDI
            -- Verificar se conta foi migrada VIACREDI >> ALTO VALE
            IF (rw_craptco.cdcooper = 1 AND rw_craptco.cdcopant = 2)
            OR (rw_craptco.cdcooper = 16 AND rw_craptco.cdcopant = 1) THEN
              -- Conta encerrada
              pr_cdcritic := 1;
              RETURN;
            END IF;

            -- Validacao da conta migrada
            vr_val_cdcooper := rw_craptco.cdcooper;
            vr_val_nrdconta := rw_craptco.nrdconta;

            -- Busca cooperativa onde a conta foi transferida
            OPEN cr_crapcop(pr_cdcooper => vr_val_cdcooper);
            FETCH cr_crapcop
             INTO rw_b_crapcop;
            -- Se não encontrar
            IF cr_crapcop%NOTFOUND THEN
              CLOSE cr_crapcop;
              -- Coop nao encontrar
              pr_cdcritic := 99;
              pr_dscritic := 'Cooperativa migrada nao encontrada.';
              RETURN;
            ELSE
              CLOSE cr_crapcop;
            END IF;
            -- Busca data na cooperativa onde a conta foi transferida
            OPEN btch0001.cr_crapdat(pr_cdcooper => vr_val_cdcooper);
            FETCH btch0001.cr_crapdat
             INTO rw_b_crapdat;
            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
              CLOSE btch0001.cr_crapdat;
              -- Coop nao encontrar
              pr_cdcritic := 99;
              pr_dscritic := 'Data da cooperativa migrada nao encontrada.';
              RETURN;
            ELSE
              CLOSE btch0001.cr_crapdat;
            END IF;
            -- Verifica se conta transferida existe na Coop destino
            OPEN cr_crapass(pr_cdcooper => vr_val_cdcooper
                           ,pr_nrdconta => vr_val_nrdconta);
            FETCH cr_crapass
             INTO rw_crapass;
            -- Se não encontrar
            IF cr_crapass%NOTFOUND THEN
              CLOSE cr_crapass;
              -- Cconta não encontrada
              pr_cdcritic := 99;
              pr_dscritic := 'Conta migrada nao encontrada.';
              RETURN;
            ELSE
              CLOSE cr_crapass;
            END IF;
          ELSE
            CLOSE cr_craptco;
          END IF;
        END IF;

        -- Verifica se o problema esta na conta
        OPEN cr_crapass(pr_cdcooper => vr_val_cdcooper
                       ,pr_nrdconta => vr_val_nrdconta);
        FETCH cr_crapass
         INTO rw_crapass;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          OPEN cr_conta(pr_cdcooper => vr_val_cdcooper
                       ,pr_nrdconta => vr_val_nrdconta
                       );
          --
          FETCH cr_conta INTO rw_conta;
          -- Se não encontrar
          IF cr_conta%NOTFOUND THEN
            CLOSE cr_conta;
          -- Cconta não encontrada
          pr_cdcritic := 2;
          pr_dscritic := 'Conta informada invalida.';
          RETURN;
            --
          END IF;
          --
          CLOSE cr_conta;
          --
        ELSIF rw_crapass.dtelimin IS NOT NULL THEN
          pr_cdcritic := 1;  /* Conta encerrada */
          RETURN;
          
        ELSIF rw_crapass.cdsitdct = 4  THEN -- INC0021763 - Removida a validação dos tipos de TEDs
          pr_cdcritic := 1;  /* Conta encerrada */
          RETURN; 
        
        ELSE
          CLOSE cr_crapass;
          -- Para PF
          IF rw_crapass.inpessoa = 1 THEN
            -- Verifica cpf da TED com o cpf da conta
            OPEN cr_crapttl(pr_cdcooper => vr_val_cdcooper
                           ,pr_nrdconta => vr_val_nrdconta
                           ,pr_nrcpfcgc => vr_val_nrcpfcgc);
            FETCH cr_crapttl
             INTO rw_crapttl;
            -- Se não encontrar
            IF cr_crapttl%NOTFOUND OR NOT (vr_val_tppessoa = 'F' OR vr_aux_CodMsg IN('STR0037R2','PAG0137R2')) THEN
              CLOSE cr_crapttl;
              --CPF divergente
              pr_cdcritic := 3;
              RETURN;
            ELSE
              CLOSE cr_crapttl;
            END IF;
          ELSE -- PJ
            -- Verifica se o problema esta no CPF
            rw_crapass := NULL;
            OPEN cr_crapass(pr_cdcooper => vr_val_cdcooper
                           ,pr_nrdconta => vr_val_nrdconta
                           ,pr_nrcpfcgc => vr_val_nrcpfcgc
                           ,pr_flgjurid => 1);
            FETCH cr_crapass
             INTO rw_crapass;
            -- Se não tiver encontrado
            IF vr_val_tppessoa <> 'J' OR cr_crapass%NOTFOUND  THEN
              CLOSE cr_crapass;
              /*CNPJ divergente*/
              pr_cdcritic := 3;
              -- Sair
              RETURN;
            ELSE
              CLOSE cr_crapass;
            END IF;
          END IF;
        END IF;
      END IF;
      -- Marcelo Telles Coelho - Projeto 475 - Sprint C2
      -- Atualizar a conta migrada na tabela de trace
      IF pr_dscritic IS NULL AND pr_cdcritic IS NULL THEN
        
        IF vr_val_cdcooper <> NVL(rw_b_crapcop.cdcooper,rw_crapcop_mensag.cdcooper)
        OR vr_val_nrdconta <> to_number(vr_aux_CtCredtd)
        THEN
          SSPB0003.pc_atualiza_conta_migrada(pr_nrcontrole_str_pag => vr_trace_nrcontrole_str_pag
                                            ,pr_nrdconta           => vr_val_nrdconta
                                            ,pr_cdcooper           => vr_val_cdcooper
                                            ,pr_nrdconta_migrada   => to_number(vr_aux_CtCredtd)
                                            ,pr_cdcooper_migrada   => NVL(rw_b_crapcop.cdcooper,rw_crapcop_mensag.cdcooper)
                                            ,pr_dscritic           => pr_dscritic);
        END IF;
      END IF;
      -- Fim Projeto 475
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 2; -- Conta invalida
        pr_dscritic := 'Erro nao tratado com a conta --> '||sqlerrm;
    END;

    -- Rotina para substituir caracteres
    FUNCTION fn_getValue(pr_conteudo IN xmldom.DOMNode)RETURN VARCHAR2 IS
      
    BEGIN
    
      RETURN gene0007.fn_caract_controle(xmldom.getNodeValue(pr_conteudo));
      
    END fn_getValue;
    
    -- Rotina para verificar se o processo ainda está rodando
    FUNCTION fn_verifica_processo RETURN BOOLEAN IS
      -- Variavies auxiliares
      vr_cdcooper crapcop.cdcooper%TYPE;
    BEGIN
      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
      END IF;

      -- Buscar o calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat_mensag;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RETURN FALSE;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Se a data do calendário for diferente de sysdate
      IF TRUNC(vr_glb_dataatual) > rw_crapdat_mensag.dtmvtolt THEN
        -- Marcelo Telles Coelho - Projeto 475
        -- Se processo rodando salvar DTMVTOCD para utilizar na PC_TRATA_LANCAMENTOS
        vr_dtmovimento := rw_crapdat_mensag.dtmvtocd;
        -- Não poderá executar
        RETURN false;
      ELSE
        -- Marcelo Telles Coelho - Projeto 475
        -- Se processo rodando salvar DTMVTOLT para utilizar na PC_TRATA_LANCAMENTOS
        vr_dtmovimento := rw_crapdat_mensag.dtmvtolt;
        RETURN true;
      END IF;
    END fn_verifica_processo;

    -- Verificar se o processo esta ainda executando em estado de crise
    FUNCTION fn_verifica_processo_crise RETURN BOOLEAN IS
    BEGIN
      -- Se nao estiver em estado de crise
      IF vr_aux_flestcri = 0 THEN
        -- Acionar verificação do processo
        IF NOT fn_verifica_processo THEN
          -- Marcelo Telles Coelho - Projeto 475
          -- Não interromper o processo
          -- RETURN FALSE;
          RETURN TRUE;
        END IF;
      ELSE
        -- Verifica as Mensagens de Recebimento
        IF NVL(vr_aux_CodMsg,'Sem <CodMsg>') -- Marcelo Telles Coelho - Projeto 475
                         NOT IN('STR0005R2','STR0007R2','STR0008R2','PAG0107R2','STR0025R2','PAG0121R2'-- ]a Judicial - Andrino
                           ,'PAG0108R2','PAG0143R2'-- TED
                           ,'STR0037R2','PAG0137R2'-- TEC
                           ,'STR0026R2' --VR Boleto
                           ,'STR0005','PAG0107','STR0008','PAG0108','PAG0137','STR0037','STR0026'
                           ,'CIR0020' /* Pagamento de Lançamento Devido MECIR */    /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
                           ,'CIR0021' /* Lançamento a Crédito Efetivado do MECIR */ /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
               )
        THEN -- Rejeitadas
          RETURN FALSE;
        END IF;
      END IF;
      -- Se chegar neste ponto sem restrição, retornar positivo
      RETURN TRUE;
    END fn_verifica_processo_crise;

    -- Trazer arquivo de log do mqcecred_processa
    FUNCTION fn_log_mqcecred RETURN VARCHAR2 IS
      -- Variavies auxiliares
      vr_cdcooper crapcop.cdcooper%TYPE;
    BEGIN
      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
      END IF;

      -- Buscar o calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat_mensag;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        RETURN ' ';
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Para estas mensagens nao e necessario aguardar processo
      IF vr_aux_CodMsg IN ('PAG0101','STR0018','STR0019') THEN
        RETURN 'mqcecred_processa_' || to_char(vr_glb_dataatual,'DDMMRR') || '.log';
      ELSE
        RETURN 'mqcecred_processa_' || to_char(rw_crapdat_mensag.dtmvtolt,'DDMMRR') || '.log';
      END IF;
    END;

    /* Geracao de LOG no SPB */
    -- Cuidar ao mecher no log, pois os espacamentos e formats estao --
    -- ajustados para que a tela LOGSPB pegue os dados com SUBSTRING --
    PROCEDURE pc_gera_log_SPB(pr_tipodlog  IN VARCHAR2
                             ,pr_msgderro  IN VARCHAR2) IS
      -- Variavies auxiliares
      vr_cdcooper      crapcop.cdcooper%TYPE;
      vr_cdbcoctl      crapcop.cdbcoctl%TYPE;
      vr_cdagectl      crapcop.cdagectl%TYPE;
      vr_nmpesrcb      craptvl.nmpesrcb%TYPE;
      vr_tipodlog      VARCHAR2(1000);
    BEGIN
      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
        vr_cdbcoctl := rw_crapcop_mensag.cdbcoctl;
        vr_cdagectl := rw_crapcop_mensag.cdagectl;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
        vr_cdbcoctl := rw_crapcop_central.cdbcoctl;
        vr_cdagectl := rw_crapcop_central.cdagectl;
      END IF;

      -- Trazer arquivo de log do mqcecred_processa
      vr_nmarqlog := fn_log_mqcecred;

      -- Geração de LOG conforme o tipo da mensagem
      IF pr_tipodlog = 'RETORNO JD OK' THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - RETORNO JD OK      --> '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                  ,pr_nmarqlog      => vr_nmarqlog);
      ELSIF pr_tipodlog IN('RETORNO SPB','REJEITADA NAO OK') THEN
        -- Se há erro
        IF TRIM(pr_msgderro) IS NOT NULL THEN
          IF pr_tipodlog = 'RETORNO SPB' THEN
            vr_tipodlog := 'RETORNO SPB NAO OK';
          ELSE
            vr_tipodlog := pr_tipodlog;
          END IF;
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - ' || RPAD(substr(vr_tipodlog,1,18),18,' ') || ' --> '
                                                      || 'Evento: ' || RPAD(SUBSTR(VR_aux_CodMsg,1,9),9,' ')
                                                      || ', Motivo Erro: '|| RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                    ,pr_nmarqlog      => vr_nmarqlog);
        ELSE
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RETORNO SPB OK     --> '
                                                      || 'Evento: ' || RPAD(SUBSTR(VR_aux_CodMsg,1,9),9,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                    ,pr_nmarqlog      => vr_nmarqlog);
        END IF;
      ELSIF pr_tipodlog IN('ENVIADA NAO OK','REJEITADA OK') THEN
        -- Marcelo Telles Coelho - Projeto 475
        -- Tratar mensagm digitada na cabine
        IF SUBSTR(vr_aux_NumCtrlIF,1,1) NOT IN ('1','2') THEN
            -- Gerar log
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                      ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                        || to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_glb_cdprogra ||' - '||RPAD(SUBSTR(pr_tipodlog,1,18),18,' ')||' --> '
                                                        || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                        || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                        || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                        || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                        || ', Valor: ' || gene0002.fn_mask(rw_craptvl.vldocrcb,'zzz,zzz,zz9.99')
                                                        || ', Banco Remet.: ' || gene0002.fn_mask(VR_cdbcoctl,'zz9')
                                                        || ', Agencia Remet.: ' || gene0002.fn_mask(vr_cdagectl,'zzz9')
                                                        || ', Conta Remet.: ' || gene0002.fn_mask(rw_craptvl.nrdconta,'zzzzzzzz9')
                                                        || ', Nome Remet.: ' || rpad(substr(rw_craptvl.nmpesemi,1,40),40,' ')
                                                        || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(rw_craptvl.cpfcgemi,'zzzzzzzzzzzzz9')
                                                        || ', Banco Dest.: ' || gene0002.fn_mask(rw_craptvl.cdbccrcb,'zz9')
                                                        || ', Agencia Dest.: ' || gene0002.fn_mask(rw_craptvl.cdagercb,'zzz9')
                                                        || ', Conta Dest.: ' || RPAD(rw_craptvl.nrcctrcb,14,' ')
                                                        || ', Nome Dest.: ' || rpad(substr(vr_nmpesrcb,1,40),40,' ')
                                                        || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(rw_craptvl.cpfcgrcb,'zzzzzzzzzzzzz9')
                                      ,pr_nmarqlog      => vr_nmarqlog);
        -- Fim Projeto 475
        --
        -- Se for TED
        ELSIF SUBSTR(vr_aux_NumCtrlIF,1,1) = 1 THEN
          -- Buscar registro transferência
          OPEN cr_craptvl(pr_cdcooper => vr_cdcooper
                         ,pr_idopetrf => vr_aux_NumCtrlIF);
          FETCH cr_craptvl
           INTO rw_craptvl;
          -- Se encontrar
          IF cr_craptvl%FOUND THEN
            CLOSE cr_craptvl;
            -- Substituir caracteres
            vr_nmpesrcb := gene0007.fn_caract_acento(rw_craptvl.nmpesrcb);
            -- Gerar log
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                      ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                        || to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_glb_cdprogra ||' - '||RPAD(SUBSTR(pr_tipodlog,1,18),18,' ')||' --> '
                                                        || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                        || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                        || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                        || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                        || ', Valor: ' || gene0002.fn_mask(rw_craptvl.vldocrcb,'zzz,zzz,zz9.99')
                                                        || ', Banco Remet.: ' || gene0002.fn_mask(VR_cdbcoctl,'zz9')
                                                        || ', Agencia Remet.: ' || gene0002.fn_mask(vr_cdagectl,'zzz9')
                                                        || ', Conta Remet.: ' || gene0002.fn_mask(rw_craptvl.nrdconta,'zzzzzzzz9')
                                                        || ', Nome Remet.: ' || rpad(substr(rw_craptvl.nmpesemi,1,40),40,' ')
                                                        || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(rw_craptvl.cpfcgemi,'zzzzzzzzzzzzz9')
                                                        || ', Banco Dest.: ' || gene0002.fn_mask(rw_craptvl.cdbccrcb,'zz9')
                                                        || ', Agencia Dest.: ' || gene0002.fn_mask(rw_craptvl.cdagercb,'zzz9')
                                                        || ', Conta Dest.: ' || RPAD(rw_craptvl.nrcctrcb,14,' ')
                                                        || ', Nome Dest.: ' || rpad(substr(vr_nmpesrcb,1,40),40,' ')
                                                        || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(rw_craptvl.cpfcgrcb,'zzzzzzzzzzzzz9')
                                      ,pr_nmarqlog      => vr_nmarqlog);
            -- Para enviada nao ok
            IF pr_tipodlog = 'ENVIADA NAO OK' THEN
              -- Gravar log TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                       ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 2 /* Enviada Nao Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craptvl.vldocrcb
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craptvl.nrdconta
                                       ,pr_nmcopcta => rw_craptvl.nmpesemi
                                       ,pr_nrcpfcop => rw_craptvl.cpfcgemi
                                       ,pr_cdbandif => rw_craptvl.cdbccrcb
                                       ,pr_cdagedif => rw_craptvl.cdagercb
                                       ,pr_nrctadif => rw_craptvl.nrcctrcb
                                       ,pr_nmtitdif => vr_nmpesrcb
                                       ,pr_nrcpfdif => rw_craptvl.cpfcgrcb
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            ELSE
              /* No XML da mensagem REJEITADA nao contem dados
                 da operação, apenas o numero de controle, que
                 utilizamos para buscar os dados na craptvl.
                 Como nao gravamos o ISPB nesta tabela, vamos
                 conseguir obter/logar somente o ISPB das IFs
                 com código de banco */
              /* Buscar dados do banco */
              OPEN cr_crapban(pr_cdbccxlt => rw_craptvl.cdbccrcb);
              FETCH cr_crapban
               INTO rw_crapban;
              -- Se encontrou
              IF cr_crapban%FOUND THEN
                vr_aux_ISPBIFCredtd := rw_crapban.nrispbif;
              END IF;
              CLOSE cr_crapban;
              -- Gerar log da TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                       ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 5 /* Rejeitada Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craptvl.vldocrcb
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craptvl.nrdconta
                                       ,pr_nmcopcta => rw_craptvl.nmpesemi
                                       ,pr_nrcpfcop => rw_craptvl.cpfcgemi
                                       ,pr_cdbandif => rw_craptvl.cdbccrcb
                                       ,pr_cdagedif => rw_craptvl.cdagercb
                                       ,pr_nrctadif => rw_craptvl.nrcctrcb
                                       ,pr_nmtitdif => vr_nmpesrcb
                                       ,pr_nrcpfdif => rw_craptvl.cpfcgrcb
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            END IF;
          ELSE
            CLOSE cr_craptvl;
          END IF;
        ELSE -- TEC
          -- Buscar registro transferência
          OPEN cr_craplcs(pr_cdcooper => vr_cdcooper
                         ,pr_idopetrf => vr_aux_NumCtrlIF);
          FETCH cr_craplcs
           INTO rw_craplcs;
          -- Se encontrar
          IF cr_craplcs%FOUND THEN
            CLOSE cr_craplcs;
            -- Gerar log
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                      ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                        || to_char(sysdate,'hh24:mi:ss')||' - '
                                                        || vr_glb_cdprogra ||' - '||RPAD(SUBSTR(pr_tipodlog,1,18),18,' ')||' --> '
                                                        || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                        || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                        || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                        || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                        || ', Valor: ' || gene0002.fn_mask(rw_craplcs.vllanmto,'zzz,zzz,zz9.99')
                                                        || ', Banco Remet.: ' || gene0002.fn_mask(vr_cdbcoctl,'zz9')
                                                        || ', Agencia Remet.: ' || gene0002.fn_mask(vr_cdagectl,'zzz9')
                                                        || ', Conta Remet.: ' || gene0002.fn_mask(rw_craplcs.nrdconta,'zzzzzzzz9')
                                                        || ', Nome Remet.: ' || rpad(substr(rw_craplcs.nmfuncio,1,40),40,' ')
                                                        || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(rw_craplcs.nrcpfcgc,'zzzzzzzzzzzzz9')
                                                        || ', Banco Dest.: ' || gene0002.fn_mask(rw_craplcs.cdbantrf,'zz9')
                                                        || ', Agencia Dest.: ' || gene0002.fn_mask(rw_craplcs.cdagetrf,'zzz9')
                                                        || ', Conta Dest.: ' || RPAD(rw_craplcs.nrctatrf||rw_craplcs.nrdigtrf,14,' ')
                                                        || ', Nome Dest.: ' || rpad(substr(rw_craplcs.nmfuncio,1,40),40,' ')
                                                        || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(rw_craplcs.nrcpfcgc,'zzzzzzzzzzzzz9')
                                      ,pr_nmarqlog      => vr_nmarqlog);
            -- Para enviada nao ok
            IF pr_tipodlog = 'ENVIADA NAO OK' THEN
              -- Gravar log TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                       ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 2 /* Enviada Nao Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craplcs.vllanmto
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craplcs.nrdconta
                                       ,pr_nmcopcta => rw_craplcs.nmfuncio
                                       ,pr_nrcpfcop => rw_craplcs.nrcpfcgc
                                       ,pr_cdbandif => rw_craplcs.cdbantrf
                                       ,pr_cdagedif => rw_craplcs.cdagetrf
                                       ,pr_nrctadif => rw_craplcs.nrctatrf||rw_craplcs.nrdigtrf
                                       ,pr_nmtitdif => rw_craplcs.nmfuncio
                                       ,pr_nrcpfdif => rw_craplcs.nrcpfcgc
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            ELSE
              -- Gerar log da TED
              sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                       ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                       ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                       ,pr_idorigem => 1
                                       ,pr_cdprogra => vr_glb_cdprogra
                                       ,pr_idsitmsg => 5 /* Rejeitada Ok */
                                       ,pr_nmarqmsg => vr_aux_nmarqxml
                                       ,pr_nmevento => vr_aux_CodMsg
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF
                                       ,pr_vldocmto => rw_craplcs.vllanmto
                                       ,pr_cdbanctl => vr_cdbcoctl
                                       ,pr_cdagectl => vr_cdagectl
                                       ,pr_nrdconta => rw_craplcs.nrdconta
                                       ,pr_nmcopcta => rw_craplcs.nmfuncio
                                       ,pr_nrcpfcop => rw_craplcs.nrcpfcgc
                                       ,pr_cdbandif => rw_craplcs.cdbantrf
                                       ,pr_cdagedif => rw_craplcs.cdagetrf
                                       ,pr_nrctadif => rw_craplcs.nrctatrf||rw_craplcs.nrdigtrf
                                       ,pr_nmtitdif => rw_craplcs.nmfuncio
                                       ,pr_nrcpfdif => rw_craplcs.nrcpfcgc
                                       ,pr_cdidenti => ''
                                       ,pr_dsmotivo => pr_msgderro
                                       ,pr_cdagenci => 0
                                       ,pr_nrdcaixa => 0
                                       ,pr_cdoperad => '1'
                                       ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                       ,pr_inestcri => vr_aux_inestcri
                                       ,pr_cdcritic => vr_cdcritic
                                       ,pr_dscritic => vr_dscritic);
               IF vr_dscritic IS NOT NULL THEN
                 vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
                 RAISE vr_exc_saida;
               END IF;
            END IF;
          ELSE
            CLOSE cr_craplcs;
          END IF;
        END IF;
      ELSIF pr_tipodlog = 'RECEBIDA' THEN
        /* Buscar dados do banco */
        OPEN cr_crapban(pr_nrispbif => vr_aux_ISPBIFDebtd);
        FETCH cr_crapban
         INTO rw_crapban;
        -- Se encontrou
        IF cr_crapban%FOUND THEN
          vr_aux_BancoDeb := rw_crapban.cdbccxlt;
        END IF;
        CLOSE cr_crapban;
        /* Banco CECRED */
        vr_aux_BancoCre := vr_cdbcoctl;
        IF trim(vr_aux_NumCtrlRem) IS NOT NULL THEN
          vr_aux_nrctrole := vr_aux_NumCtrlRem;
        ELSE
          vr_aux_nrctrole := vr_aux_NumCtrlIF;
        END IF;
        -- Se houve erro
        IF pr_msgderro IS NOT NULL THEN
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA NAO OK    --> '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(vr_aux_CtCredtd,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                   ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                   ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 4 /* Enviada Não Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => vr_aux_CtCredtd
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFDebtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        ELSE
         -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(SYSDATE,'dd/mm/yyyy') || ' - '
                                                      || to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA OK        --> '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(vr_aux_CtCredtd,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => vr_cdcooper
                                   ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                   ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 3 /* Enviada Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => vr_aux_CtCredtd
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFDebtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        END IF;
      ELSIF pr_tipodlog = 'SPB-STR-IF' THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - '
                                                    || SUBSTR(vr_aux_CodMsg,1,18)||' --> '
                                                    || pr_msgderro || ' => ISPB ' || vr_aux_nrispbif
                                  ,pr_nmarqlog      => vr_nmarqlog);
      ELSIF pr_tipodlog = 'PAG0101' THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - '
                                                    || SUBSTR(vr_aux_CodMsg,1,18) || ' '
                                  ,pr_nmarqlog      => vr_nmarqlog);
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Erro tratado, gerar em LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_nmarqlog);
      WHEN others THEN
        -- Erro nao tratado
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => vr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro Nao Tratado --> '||SQLERRM
                                  ,pr_nmarqlog      => vr_nmarqlog);
    END pc_gera_log_SPB;

    /* Geracao de LOG no SPB para Transferencias */
    -- Cuidar ao mecher no log, pois os espacamentos e formats estao --
    -- ajustados para que a tela LOGSPB pegue os dados com SUBSTRING --
    PROCEDURE pc_gera_log_SPB_transferida(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                         ,pr_cdbcoctl  IN crapcop.cdbcoctl%TYPE
                                         ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE
                                         ,pr_tipodlog  IN VARCHAR2
                                         ,pr_msgderro  IN VARCHAR2) IS
    BEGIN

      -- Trazer arquivo de log do mqcecred_processa
      vr_nmarqlog := 'mqcecred_processa_'||to_char(pr_dtmvtolt,'DDMMRR')||'.log';

      -- Geração de LOG conforme o tipo da mensagem
      IF pr_tipodlog = 'RECEBIDA' THEN
        /* Buscar dados do banco */
        OPEN cr_crapban(pr_nrispbif => vr_aux_ISPBIFDebtd);
        FETCH cr_crapban
         INTO rw_crapban;
        -- Se encontrou
        IF cr_crapban%FOUND THEN
          vr_aux_BancoDeb := rw_crapban.cdbccxlt;
        END IF;
        CLOSE cr_crapban;
        /* Banco CECRED */
        vr_aux_BancoCre := pr_cdbcoctl;
        IF trim(vr_aux_NumCtrlRem) IS NOT NULL THEN
          vr_aux_nrctrole := vr_aux_NumCtrlRem;
        ELSE
          vr_aux_nrctrole := vr_aux_NumCtrlIF;
        END IF;
        -- Se houve erro
        IF pr_msgderro IS NOT NULL THEN
          -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA NAO OK    --> '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Motivo Erro: ' || RPAD(SUBSTR(pr_msgderro,1,90),90,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(rw_craptco.nrdconta,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => pr_cdcooper
                                   ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                   ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 4 /* Enviada Não Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => rw_craptco.nrdconta
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        ELSE
         -- Gerar log
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                      || to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_glb_cdprogra ||' - RECEBIDA OK        --> '
                                                      || 'Evento: ' || RPAD(SUBSTR(vr_aux_CodMsg,1,9),9,' ')
                                                      || ', Numero Controle: '|| RPAD(SUBSTR(vr_aux_nrctrole,1,20),20,' ')
                                                      || ', Hora: ' || to_char(sysdate,'HH24:MI:SS')
                                                      || ', Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || ', Banco Remet.: ' || gene0002.fn_mask(vr_aux_BancoDeb,'zz9')
                                                      || ', Agencia Remet.: ' || gene0002.fn_mask(vr_aux_AgDebtd,'zzz9')
                                                      || ', Conta Remet.: ' || RPAD(vr_aux_CtDebtd,20,' ')
                                                      || ', Nome Remet.: ' || rpad(substr(vr_aux_NomCliDebtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Remet.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFDeb,'zzzzzzzzzzzzz9')
                                                      || ', Banco Dest.: ' || gene0002.fn_mask(vr_aux_BancoCre,'zz9')
                                                      || ', Agencia Dest.: ' || gene0002.fn_mask(vr_aux_AgCredtd,'zzz9')
                                                      || ', Conta Dest.: ' || gene0002.fn_mask(rw_craptco.nrdconta,'zzzzzzzzzzzzz9')
                                                      || ', Nome Dest.: ' || rpad(substr(vr_aux_NomCliCredtd,1,40),40,' ')
                                                      || ', CPF/CNPJ Dest.: ' || gene0002.fn_mask(vr_aux_CNPJ_CPFCred,'zzzzzzzzzzzzz9')
                                    ,pr_nmarqlog      => vr_nmarqlog);
          -- Gerar log da TED
          sspb0001.pc_grava_log_ted(pr_cdcooper => pr_cdcooper
                                   ,pr_dttransa => TRUNC(vr_glb_dataatual)
                                   ,pr_hrtransa => TO_CHAR(vr_glb_dataatual,'SSSSS')
                                   ,pr_idorigem => 1
                                   ,pr_cdprogra => vr_glb_cdprogra
                                   ,pr_idsitmsg => 3 /* Enviada Ok */
                                   ,pr_nmarqmsg => vr_aux_nmarqxml
                                   ,pr_nmevento => vr_aux_CodMsg
                                   ,pr_nrctrlif => vr_aux_nrctrole
                                   ,pr_vldocmto => vr_aux_VlrLanc
                                   ,pr_cdbanctl => vr_aux_BancoCre
                                   ,pr_cdagectl => vr_aux_AgCredtd
                                   ,pr_nrdconta => rw_craptco.nrdconta
                                   ,pr_nmcopcta => vr_aux_NomCliCredtd
                                   ,pr_nrcpfcop => vr_aux_CNPJ_CPFCred
                                   ,pr_cdbandif => vr_aux_BancoDeb
                                   ,pr_cdagedif => vr_aux_AgDebtd
                                   ,pr_nrctadif => vr_aux_CtDebtd
                                   ,pr_nmtitdif => vr_aux_NomCliDebtd
                                   ,pr_nrcpfdif => vr_aux_CNPJ_CPFDeb
                                   ,pr_cdidenti => ''
                                   ,pr_dsmotivo => pr_msgderro
                                   ,pr_cdagenci => 0
                                   ,pr_nrdcaixa => 0
                                   ,pr_cdoperad => '1'
                                   ,pr_nrispbif => vr_aux_ISPBIFCredtd
                                   ,pr_inestcri => vr_aux_inestcri
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
           IF vr_dscritic IS NOT NULL THEN
             vr_dscritic := 'Erro na gravacao de LOG TED: '||vr_dscritic;
             RAISE vr_exc_saida;
           END IF;
        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Erro tratado, gerar em LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_nmarqlog);
      WHEN others THEN
        -- Erro nao tratado
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - '
                                                    || to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || vr_glb_cdprogra ||' - ERRO GERACAO LOG   --> '
                                                    || 'Numero Controle: ' || RPAD(SUBSTR(vr_aux_NumCtrlIF,1,20),20,' ')
                                                    || ', Erro Nao Tratado --> '||SQLERRM
                                  ,pr_nmarqlog      => vr_nmarqlog);
    END pc_gera_log_SPB_transferida;

    -- Cria registro da mensagem Devolvida
    PROCEDURE pc_cria_gnmvcen(pr_cdagenci IN NUMBER
                             ,pr_dtmvtolt IN DATE
                             ,pr_dsmensag IN VARCHAR2
                             ,pr_dsdebcre IN VARCHAR2
                             ,pr_vllanmto IN NUMBER
                             ,pr_dscritic OUT VARCHAR2) IS
    BEGIN
      INSERT INTO gnmvcen(cdagectl
                         ,dtmvtolt
                         ,dsmensag
                         ,dsdebcre
                         ,vllanmto)
                   VALUES(pr_cdagenci
                         ,pr_dtmvtolt
                         ,pr_dsmensag
                         ,pr_dsdebcre
                         ,pr_vllanmto);
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Erro tratado
        pr_dscritic := 'Erro na rotina pc_cria_gnmvcen --> '||vr_dscritic;
      WHEN others THEN
        -- Erro nao tratado
        pr_dscritic := 'Erro nao tratado na rotina pc_cria_gnmvcen --> '||sqlerrm;
    END;

    /* SubRotina para geração de mensagem de erro em XML e envio a fila para devolução ao SPB */
    PROCEDURE pc_gera_erro_xml(pr_dsdehist  IN VARCHAR2
                              ,pr_codierro  IN NUMBER
                              ,pr_dscritic OUT VARCHAR2) IS
      -- Variavies auxiliares
      vr_cdagectl      crapcop.cdagectl%TYPE;
      vr_cdcooper      crapcop.cdcooper%TYPE;
      vr_dsdircop      VARCHAR2(4000);
      vr_aux_cdMsg_dev VARCHAR2(100);
      vr_ioarquiv      utl_file.file_type;
      vr_nmarquiv      VARCHAR2(1000);
      vr_aux_dsarqenv  VARCHAR2(32767);
      -- Comando SO
      vr_dsparam VARCHAR2(4000);
      vr_comando VARCHAR2(4000);
      --
      -- Variaveis projeto 475
      vr_aux_DtMovto_pag varchar2(10);
    BEGIN

      -- Se já foi lida a Cooperativa da mensagem
      IF rw_crapcop_mensag.cdcooper IS NOT NULL THEN
        -- Usaremos ela
        vr_cdcooper := rw_crapcop_mensag.cdcooper;
        vr_cdagectl := rw_crapcop_mensag.cdagectl;
        vr_dsdircop := rw_crapcop_mensag.dsdircop;
      ELSE
        -- Usaremos a global
        vr_cdcooper := rw_crapcop_central.cdcooper;
        vr_cdagectl := rw_crapcop_central.cdagectl;
        vr_dsdircop := rw_crapcop_central.dsdircop;
      END IF;

      -- Projeto 475 Sprint C REQ13 
      -- As TEDs de devolução que ocorrerem após o horário de encerramento definido na TAB085 
      -- deverão ser geradas com data movimento D+1.
      OPEN cr_crapcop_grade(pr_cdcooper => vr_cdcooper);
      FETCH cr_crapcop_grade INTO rw_crapcopgrade;
      -- Se não encontrar
      IF cr_crapcop_grade%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapcop_grade;
        -- Mantem a data de movimento atual
        vr_aux_DtMovto_pag := to_char(rw_crapdat_mensag.dtmvtocd,'YYYY-MM-DD'); 
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop_grade;
        IF rw_crapcopgrade.flg_dtmvto_pag = 1 THEN
           -- Fora do horário
           -- Utiliza a próxima data de movimento
           vr_aux_DtMovto_pag := to_char(rw_crapdat_mensag.dtmvtopr,'YYYY-MM-DD');
        ELSE
           -- Dentro do horário
           vr_aux_DtMovto_pag := to_char(rw_crapdat_mensag.dtmvtocd,'YYYY-MM-DD');          
        END IF;   
      END IF; 

      -- Buscar o calendário
      OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
      FETCH btch0001.cr_crapdat
       INTO rw_crapdat_mensag;
      -- Se não encontrar
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE btch0001.cr_crapdat;
        -- Montar mensagem de critica
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
        RETURN;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Montar nome do arquivo
      vr_nmarquiv := 'msge_cecred_'
                  /* para evitar duplicidade devido paralelismo */
                  || to_char(SYSTIMESTAMP,'rrrrmmddsssssff3')
                  || to_char(SEQ_TEDENVIO.nextval,'fm000') || '.xml';
      vr_aux_CdLegado := to_char(vr_cdagectl);
      IF vr_aux_CodMsg IN ('STR0037R2','PAG0137R2') THEN
        vr_aux_cdtiptrf := 2; /* TEC */
      ELSE
        vr_aux_cdtiptrf := 1; /* TED */
      END IF;

      vr_aux_NumCtrlIF := vr_aux_cdtiptrf
                       || to_char(vr_glb_dataatual,'rrmmdd')
                       || to_char(vr_cdagectl,'fm0000')
                       || SSPB0001.fn_nrdocmto_nrctrlif
                       || 'A'; /* origem AYLLOS */

      -- Montar o XML
      vr_aux_dsarqenv := '<SISMSG>'
                      ||   '<SEGCAB>'
                      ||     '<CD_LEGADO>' || vr_aux_CdLegado || '</CD_LEGADO>'
                      ||     '<TP_MANUT>I</TP_MANUT>'
                      ||     '<CD_STATUS>D</CD_STATUS>'
                      ||     '<NR_OPERACAO>'|| vr_aux_NumCtrlIF || '</NR_OPERACAO>'
                      ||     '<FL_DEB_CRED>D</FL_DEB_CRED>'
                      ||   '</SEGCAB>';
      -- Montagem do XML conforme tipo da mensagem
      IF vr_aux_CodMsg IN('STR0005R2','STR0007R2','STR0008R2','STR0026R2','STR0037R2','STR0006R2','STR0025R2','STR0034R2') THEN
        vr_aux_cdMsg_dev := 'STR0010';
        -- Continuar XML
        vr_aux_dsarqenv := vr_aux_dsarqenv
                        || '<STR0010>'
                        ||   '<CodMsg>STR0010</CodMsg>'
                        ||   '<NumCtrlIF>' || vr_aux_NumCtrlIF || '</NumCtrlIF>'
                        ||   '<ISPBIFDebtd>' || vr_aux_ISPBIFCredtd || '</ISPBIFDebtd>'
                        ||   '<ISPBIFCredtd>' || vr_aux_ISPBIFDebtd || '</ISPBIFCredtd>'
                        ||   '<VlrLanc>' || vr_aux_DsVlrLanc || '</VlrLanc>'
                        ||   '<CodDevTransf>' || to_char(pr_codierro) ||'</CodDevTransf>'
                        ||   '<NumCtrlSTROr>' || vr_aux_NumCtrlRem || '</NumCtrlSTROr>'
                        /* Descricao Critica */
                        ||   '<Hist>' || pr_dsdehist || '</Hist>'
                        ||   '<DtMovto>'  || vr_aux_DtMovto || '</DtMovto>'
                        || '</STR0010>';
      ELSIF vr_aux_CodMsg IN('PAG0107R2','PAG0108R2','PAG0137R2','PAG0143R2','PAG0121R2','PAG0142R2','PAG0134R2') THEN
        vr_aux_cdMsg_dev := 'PAG0111';
        -- Continuar XML
        vr_aux_dsarqenv := vr_aux_dsarqenv
                        || '<PAG0111>'
                        ||   '<CodMsg>PAG0111</CodMsg>'
                        ||   '<NumCtrlIF>' || vr_aux_NumCtrlIF || '</NumCtrlIF>'
                        ||   '<ISPBIFDebtd>' || vr_aux_ISPBIFCredtd || '</ISPBIFDebtd>'
                        ||   '<ISPBIFCredtd>' || vr_aux_ISPBIFDebtd || '</ISPBIFCredtd>'
                        ||   '<VlrLanc>' || vr_aux_DsVlrLanc || '</VlrLanc>'
                        ||   '<CodDevTransf>' || to_char(pr_codierro) ||'</CodDevTransf>'
                        ||   '<NumCtrlPAGOr>' || vr_aux_NumCtrlRem || '</NumCtrlPAGOr>'
                        /* Descricao Critica */
                        ||   '<Hist>' || pr_dsdehist || '</Hist>'
                        ||   '<DtMovto>' || vr_aux_DtMovto_pag || '</DtMovto>'
                        || '</PAG0111>';
      ELSIF vr_aux_CodMsg = 'STR0047R2' THEN 
        vr_aux_cdMsg_dev := 'STR0048';
        -- Continuar XML
        vr_aux_dsarqenv := vr_aux_dsarqenv
                        || '<STR0048>'
                        ||   '<CodMsg>STR0048</CodMsg>'
                        ||   '<NumCtrlIF>' || vr_aux_NumCtrlIF || '</NumCtrlIF>'
                        ||   '<ISPBIFDebtd>' || vr_aux_ISPBIFCredtd ||'</ISPBIFDebtd>'
                        ||   '<ISPBIFCredtd>' || vr_aux_ISPBIFDebtd ||'</ISPBIFCredtd>'
                        ||   '<VlrLanc>' || vr_aux_DsVlrLanc || '</VlrLanc>'
                        ||   '<CodDevPortdd>' || TO_CHAR(pr_codierro) || '</CodDevPortdd>'
                        ||   '<NumCtrlSTROr>' || vr_aux_NumCtrlRem || '</NumCtrlSTROr>'
                        ||   '<ISPBPrestd>29011780</ISPBPrestd>'
                        /* Descricao Critica */
                        ||   '<Hist>' || pr_dsdehist || '</Hist>'
                        ||   '<DtMovto>' || vr_aux_DtMovto || '</DtMovto>'
                        || '</STR0048>';
      END IF;
      -- Encerar o XML
      vr_aux_dsarqenv := vr_aux_dsarqenv || '</SISMSG>';
      -- Tratamento incorporação Transposul
      -- Necessario retornar os valores originais para apresentar no LOG
      IF vr_aux_cdageinc > 0 THEN /* Agencia incorporada */
        vr_aux_AgCredtd := to_char(vr_aux_cdageinc,'fm0000');
      END IF;
      -- Gera LOG SPB
      pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                     ,pr_msgderro  => vr_log_msgderro);

      -- Cria registro da mensagem Devolvida
      pc_cria_gnmvcen(pr_cdagenci => vr_cdagectl
                     ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                     ,pr_dsmensag => vr_aux_cdMsg_dev
                     ,pr_dsdebcre => 'C'
                     ,pr_vllanmto => vr_aux_VlrLanc
                     ,pr_dscritic => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                    ||' - '|| vr_glb_cdprogra ||' --> '
                                                    ||'Erro execucao - '
                                                    || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                    || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                    || 'Na Rotina pc_cria_gnmvcen --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_logprogr
                                  ,pr_cdprograma    => vr_glb_cdprogra
                                  ,pr_dstiplog      => 'E'
                                  ,pr_tpexecucao    => 3
                                  ,pr_cdcriticidade => 0
                                  ,pr_flgsucesso    => 1);
      END IF;

      -- Gravar a mensagem de TED devolvida
      SSPB0003.pc_grava_mensagem_ted(pr_cdcooper    => vr_cdcooper
                                    ,pr_nrctrlif    => vr_aux_NumCtrlIF
                                    ,pr_dtmensagem  => to_date(vr_aux_DtMovto,'RRRR-MM-DD')
                                    ,pr_nmevento    => vr_aux_cdMsg_dev
                                    ,pr_dsxml       => vr_aux_dsarqenv
                                    ,pr_cdprograma  => vr_glb_cdprogra
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                    ||' - '|| vr_glb_cdprogra ||' --> '
                                                    ||'Erro execucao - '
                                                    || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                    || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                    || 'Na Rotina pc_grava_mensagem_ted --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_logprogr
                                  ,pr_cdprograma    => vr_glb_cdprogra
                                  ,pr_dstiplog      => 'E'
                                  ,pr_tpexecucao    => 3
                                  ,pr_cdcriticidade => 0
                                  ,pr_flgsucesso    => 1
                                  ,pr_cdmensagem    => vr_cdcritic);
      END IF;

      -- Gravar a mensagem de TED devolvida como rejeitada
      SSPB0003.pc_grava_msg_ted_rejeita(pr_cdcooper => vr_cdcooper                                  --> Cooperativa
                                       ,pr_nrdconta => vr_aux_CtCredtd                              --> Conta
                                       ,pr_cdagenci => vr_glb_cdagenci                              --> Agencia
                                       ,pr_nrdcaixa => 0                                            --> Numero do Caixa
                                       ,pr_cdoperad => '1'                                          --> Operador
                                       ,pr_cdprogra => vr_glb_cdprogra                              --> Programa que chamou
                                       ,pr_nmevento => vr_aux_cdMsg_dev                             --> Evento
                                       ,pr_nrctrlif => vr_aux_NumCtrlIF                             --> Numero de controle
                                       ,pr_vldocmto => vr_aux_VlrLanc --> Valor
                                       -- Dados de Origem da TED (Informações da Conta na CENTRAL)
                                       ,pr_cdbanco_origem   => vr_aux_BancoCre       --> Banco
                                       ,pr_cdagencia_origem => vr_aux_AgCredtd       --> Agencia
                                       ,pr_nmtitular_origem => vr_aux_NomCliCredtd   --> Nome do Titular
                                       ,pr_nrcpf_origem     => vr_aux_CNPJ_CPFCred   --> CPF do Titular
                                       -- Dados de Destino da TED (Informações da Conta em outra IF)
                                       ,pr_cdbanco_destino   => vr_aux_BancoDeb     --> Banco
                                       ,pr_cdagencia_destino => vr_aux_AgDebtd      --> Agencia
                                       ,pr_nrconta_destino   => vr_aux_CtDebtd      --> Conta
                                       ,pr_nmtitular_destino => vr_aux_NomCliDebtd  --> Nome do Titular
                                       ,pr_nrcpf_destino     => vr_aux_CNPJ_CPFDeb  --> CPF do Titular
                                       -- Rejeição
                                       ,pr_dsmotivo_rejeicao => pr_dsdehist        --> Motivo da Rejeição
                                       ,pr_nrispbif          => vr_aux_ISPBIFDebtd --> ISPB
                                       ,pr_cdcritic    => vr_cdcritic
                                       ,pr_dscritic    => vr_dscritic);
      -- Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                    ||' - '|| vr_glb_cdprogra ||' --> '
                                                    ||'Erro execucao - '
                                                    || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                    || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                    || 'Na Rotina pc_grava_mensagem_ted --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_logprogr
                                  ,pr_cdprograma    => vr_glb_cdprogra
                                  ,pr_dstiplog      => 'E'
                                  ,pr_tpexecucao    => 3
                                  ,pr_cdcriticidade => 0
                                  ,pr_flgsucesso    => 1
                                  ,pr_cdmensagem    => vr_cdcritic);
      END IF;
      -- Marcelo Telles Coelho - Projeto 475
      -- Gerar registro de rastreio de mensagens
      DECLARE
        vr_nrseq_mensagem_xml NUMBER;
      BEGIN
        sspb0003.pc_grava_xml(pr_nmmensagem         => vr_aux_cdMsg_dev
                             ,pr_inorigem_mensagem  => NULL
                             ,pr_dhmensagem         => SYSDATE
                             ,pr_dsxml_mensagem     => SUBSTR(vr_aux_dsarqenv,1,4000)
                             ,pr_dsxml_completo     => vr_aux_dsarqenv
                             ,pr_inenvio            => 1 -- Mensagem não será enviada para o JD
                             ,pr_cdcooper           => vr_cdcooper
                             ,pr_nrdconta           => NULL
                             ,pr_cdproduto          => 30 -- TED
                             ,pr_nrseq_mensagem_xml => vr_nrseq_mensagem_xml
                             ,pr_dscritic           => vr_dscritic
                             ,pr_des_erro           => vr_des_erro
                             );
        -- se retornou critica, abortar programa
        IF nvl(vr_des_erro,'OK') <> 'OK' OR
          TRIM(vr_dscritic) IS NOT NULL THEN
          vr_cdcritic := 0;
          -- Acionar rotina de LOG
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                      ||' - '|| vr_glb_cdprogra ||' --> '
                                                      ||'Erro execucao - '
                                                      || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                      || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                      || 'Na Rotina pc_gera_erro_xml 1 --> '||vr_dscritic
                                    ,pr_nmarqlog      => vr_logprogr
                                    ,pr_cdprograma    => vr_glb_cdprogra
                                    ,pr_dstiplog      => 'E'
                                    ,pr_tpexecucao    => 3
                                    ,pr_cdcriticidade => 0
                                    ,pr_flgsucesso    => 1
                                    ,pr_cdmensagem    => vr_cdcritic);
          RAISE vr_exc_saida;
        END IF;

        IF vr_aux_CodMsg LIKE '%R2' THEN
          vr_trace_cdfase             := 120; -- Cancelamento de mensagem da IF no Ailos
          vr_trace_idorigem           := 'R';
          vr_trace_inenvio            := 0;
          vr_trace_nmmensagem         := vr_aux_cdMsg_dev;
          vr_trace_nrcontrole_if      := vr_aux_NumCtrlRem;
          vr_trace_nrcontrole_str_pag := vr_aux_NumCtrlRem;
          vr_trace_nrcontrole_dev     := vr_aux_NumCtrlIF;
          vr_trace_cdcooper           := vr_cdcooper;
          vr_trace_nrdconta           := vr_aux_CtCredtd;
        ELSE
          vr_trace_cdfase             := 900; -- Retorno mensagem devolvida pela CECRED
          vr_trace_idorigem           := NULL;
          vr_trace_inenvio            := 0;
          vr_trace_nmmensagem         := vr_aux_cdMsg_dev;
          vr_trace_nrcontrole_if      := vr_aux_NumCtrlIF;
          vr_trace_nrcontrole_str_pag := vr_aux_NumCtrlRem;
          vr_trace_nrcontrole_dev     := NULL;
          vr_trace_cdcooper           := vr_cdcooper;
          vr_trace_nrdconta           := vr_aux_CtCredtd;
        END IF;
        --
        vr_trace_dhdthr_bc := NULL;
        --
        SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_trace_cdfase
                                    ,pr_idorigem               => vr_trace_idorigem
                                    ,pr_inenvio                => vr_trace_inenvio
                                    ,pr_nmmensagem             => vr_aux_cdMsg_dev
                                    ,pr_nrcontrole             => vr_trace_nrcontrole_if
                                    ,pr_nrcontrole_str_pag     => vr_trace_nrcontrole_str_pag
                                    ,pr_nrcontrole_dev_or      => vr_trace_nrcontrole_dev
                                    ,pr_dhmensagem             => SYSDATE
                                    ,pc_dhdthr_bc              => NULL
                                    ,pr_insituacao             => 'OK'
                                    ,pr_dsxml_mensagem         => NULL
                                    ,pr_dsxml_completo         => NULL
                                    ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                    ,pr_cdcooper               => vr_cdcooper
                                    ,pr_nrdconta               => vr_trace_nrdconta
                                    ,pr_cdproduto              => 30 -- TED
                                    ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                    ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                    ,pr_dscritic               => vr_dscritic
                                    ,pr_des_erro               => vr_des_erro
                                    );
        IF vr_dscritic IS NOT NULL THEN
          -- Acionar rotina de LOG
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                      ||' - '|| vr_glb_cdprogra ||' --> '
                                                      ||'Erro execucao - '
                                                      || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                      || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                      || 'Na Rotina pc_gera_erro_xml 2 --> '||vr_dscritic
                                    ,pr_nmarqlog      => vr_logprogr
                                    ,pr_cdprograma    => vr_glb_cdprogra
                                    ,pr_dstiplog      => 'E'
                                    ,pr_tpexecucao    => 3
                                    ,pr_cdcriticidade => 0
                                    ,pr_flgsucesso    => 1
                                    ,pr_cdmensagem    => vr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
        --
        vr_trace_cdfase             := 10; -- Criação de mensagem de cancelamento/devolução no Ailos
        vr_trace_idorigem           := 'E';
        vr_trace_inenvio            := 1;
        vr_trace_nmmensagem         := vr_aux_cdMsg_dev;
        vr_trace_nrcontrole_if      := vr_aux_NumCtrlIF;
        vr_trace_nrcontrole_str_pag := NULL;
        vr_trace_nrcontrole_dev     := vr_aux_NumCtrlRem;
        vr_trace_cdcooper           := vr_cdcooper;
        vr_trace_nrdconta           := vr_aux_CtCredtd;
        --
        SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_trace_cdfase
                                    ,pr_idorigem               => vr_trace_idorigem
                                    ,pr_inenvio                => vr_trace_inenvio
                                    ,pr_nmmensagem             => vr_aux_cdMsg_dev
                                    ,pr_nrcontrole             => vr_trace_nrcontrole_if
                                    ,pr_nrcontrole_str_pag     => vr_trace_nrcontrole_str_pag
                                    ,pr_nrcontrole_dev_or      => vr_trace_nrcontrole_dev
                                    ,pr_dhmensagem             => SYSDATE
                                    ,pc_dhdthr_bc              => vr_trace_dhdthr_bc
                                    ,pr_insituacao             => 'OK'
                                    ,pr_dsxml_mensagem         => NULL
                                    ,pr_dsxml_completo         => NULL
                                    ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                    ,pr_cdcooper               => vr_cdcooper
                                    ,pr_nrdconta               => vr_trace_nrdconta
                                    ,pr_cdproduto              => 30 -- TED
                                    ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                    ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                    ,pr_dscritic               => vr_dscritic
                                    ,pr_des_erro               => vr_des_erro
                                    );
        IF vr_dscritic IS NOT NULL THEN
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                      ||' - '|| vr_glb_cdprogra ||' --> '
                                                      ||'Erro execucao - '
                                                      || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                      || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                      || 'Na Rotina pc_gera_erro_xml - Fase 10 --> '||vr_dscritic
                                    ,pr_nmarqlog      => vr_logprogr
                                    ,pr_cdprograma    => vr_glb_cdprogra
                                    ,pr_dstiplog      => 'E'
                                    ,pr_tpexecucao    => 3
                                    ,pr_cdcriticidade => 0
                                    ,pr_flgsucesso    => 1
                                    ,pr_cdmensagem    => vr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
        --
        vr_trace_cdfase             := 20; -- Criação de mensagem de cancelamento/devolução no Ailos
        vr_trace_idorigem           := 'E';
        vr_trace_inenvio            := 0;
        vr_trace_nmmensagem         := 'Não utiliza OFSAA';
        vr_trace_nrcontrole_if      := vr_aux_NumCtrlIF;
        vr_trace_nrcontrole_str_pag := NULL;
        vr_trace_nrcontrole_dev     := vr_aux_NumCtrlRem;
        vr_trace_cdcooper           := vr_cdcooper;
        vr_trace_nrdconta           := vr_aux_CtCredtd;
        --
        SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_trace_cdfase
                                    ,pr_idorigem               => vr_trace_idorigem
                                    ,pr_inenvio                => vr_trace_inenvio
                                    ,pr_nmmensagem             => vr_trace_nmmensagem
                                    ,pr_nrcontrole             => vr_trace_nrcontrole_if
                                    ,pr_nrcontrole_str_pag     => vr_trace_nrcontrole_str_pag
                                    ,pr_nrcontrole_dev_or      => vr_trace_nrcontrole_dev
                                    ,pr_dhmensagem             => SYSDATE
                                    ,pc_dhdthr_bc              => vr_trace_dhdthr_bc
                                    ,pr_insituacao             => 'OK'
                                    ,pr_dsxml_mensagem         => NULL
                                    ,pr_dsxml_completo         => NULL
                                    ,pr_nrseq_mensagem_xml     => NULL
                                    ,pr_cdcooper               => vr_cdcooper
                                    ,pr_nrdconta               => vr_trace_nrdconta
                                    ,pr_cdproduto              => 30 -- TED
                                    ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                    ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                    ,pr_dscritic               => vr_dscritic
                                    ,pr_des_erro               => vr_des_erro
                                    );
        IF vr_dscritic IS NOT NULL THEN
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                    ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                      ||' - '|| vr_glb_cdprogra ||' --> '
                                                      ||'Erro execucao - '
                                                      || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                      || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                      || 'Na Rotina pc_gera_erro_xml - Fase 20 --> '||vr_dscritic
                                    ,pr_nmarqlog      => vr_logprogr
                                    ,pr_cdprograma    => vr_glb_cdprogra
                                    ,pr_dstiplog      => 'E'
                                    ,pr_tpexecucao    => 3
                                    ,pr_cdcriticidade => 0
                                    ,pr_flgsucesso    => 1
                                    ,pr_cdmensagem    => vr_cdcritic);
          RAISE vr_exc_saida;
        END IF;
        -- Sprint D - Req19
        -- Chamada para procedure para armazenar as informações para o Arquivo Contabil
        vr_aux_valor_char := replace(Nvl(vr_aux_DsVlrFinanc, vr_aux_DsVlrLanc),'.',',');        
        vr_aux_valor := To_Number(vr_aux_valor_char);
        --
        SSPB0001.pc_grava_arquivo_contabil (pr_nmmsg => vr_aux_CodMsg
                                  ,pr_nmmsg_dev => vr_aux_cdMsg_dev
                                  ,pr_dtarquivo => To_date(Nvl(vr_aux_DtAgendt, vr_aux_DtMovto),'RRRR-MM-DD')
                                  ,pr_vlrmsg    => vr_aux_valor
                                  ,pr_FinlddIF  => vr_aux_FinlddIF
                                  ,pr_FinlddCli => vr_aux_FinlddCli
                                  ,pr_NomCliCredtd => vr_aux_NomCliCredtd
                                  ,pr_CodProdt     => vr_aux_CodProdt
                                  ,pr_SubTpAtv     => vr_aux_SubTpAtv
                                  ,pr_CtCredtd     => vr_aux_CtCredtd
                                  ,pr_CtDebtd      => vr_aux_CtDebtd
                                  ,pr_CNPJ_CPFCliCredtd => vr_aux_CNPJ_CPFCred
                                  ,pr_CtCed        => vr_aux_CtCed
                                  ,pr_NumCtrlSTROr => vr_aux_NumCtrlRem_Or  
                                  ,pr_NumCtrlIF    => vr_aux_NumCtrlIF
                                  ,pr_NumCtrlRem   => vr_aux_NumCtrlRem
                                  ,pr_his          => vr_aux_Hist
                                  ,pr_dscritic     => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          --
          cecred.pc_log_programa
            (pr_dstiplog => 'O',              -- tbgen_prglog DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
            pr_cdprograma => vr_glb_cdprogra, -- tbgen_prglog
            pr_cdcooper => pr_cdcooper,       -- tbgen_prglog
            pr_tpexecucao => 1,               -- tbgen_prglog DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
            pr_tpocorrencia => 1,             -- tbgen_prglog_ocorrencia -- 1 ERRO TRATADO
            pr_cdcriticidade => 0,            -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
            pr_dsmensagem => vr_dscritic,     -- tbgen_prglog_ocorrencia
            pr_flgsucesso => 1,               -- tbgen_prglog DEFAULT 1 -- Indicador de sucesso da execução
            pr_nmarqlog => NULL,
            pr_idprglog => vr_idprglog); 
          --
          vr_dscritic := null;
          --    
        END IF;
        -- Fim Sprint D
      END;
      -- FIM projeto 475
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_ioarquiv) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ioarquiv);
        END IF;
        -- Erro tratado
        pr_dscritic := 'Erro na rotina pc_gera_erro_xml --> '||vr_dscritic;
      WHEN others THEN
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_ioarquiv) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ioarquiv);
        END IF;
        -- Erro nao tratado
        pr_dscritic := 'Erro nao tratado na rotina pc_gera_erro_xml --> '||sqlerrm;
    END pc_gera_erro_xml;

    -- Subrotina para efetuar leitura das informações do XML para dentro das variaveis
    PROCEDURE pc_importa_xml(pr_dscritic OUT VARCHAR2) IS

      -- Variaveis específicas deste
      vr_dscomora          VARCHAR2(4000);
      vr_dsdirbin          VARCHAR2(4000);
      vr_comando           VARCHAR2(4000);
      vr_aux_cdagectl_pesq NUMBER;
      vr_aux_nro_controle  VARCHAR2(100);
      vr_nmdirarq          VARCHAR2(1000);
      vr_nmarquiv          VARCHAR2(1000);
      vr_nmarqutp          VARCHAR2(1000);
      vr_input_file        UTL_FILE.file_type;
      vr_output_file       UTL_FILE.file_type;
      vr_getlinha          varchar2(32767);
      vr_setlinha          varchar2(32767);
      vr_txtmensg          CLOB; -- varchar2(32767);
      vr_aux_msgspb_xml    varchar2(32767);

      -- Documento
      vr_xmltype         xmlType;
      vr_parser          xmlparser.Parser;
      vr_doc             xmldom.DOMDocument;

      -- Root
      vr_node_root       xmldom.DOMNodeList;
      vr_item_root       xmldom.DOMNode;
      vr_elem_root       xmldom.DOMElement;

      -- SubItens
      vr_node_list       xmldom.DOMNodeList;
      vr_node_name       VARCHAR2(100);
      vr_item_node       xmldom.DOMNode;
      vr_elem_node       xmldom.DOMElement;

      -- SubItens da SEGCAB
      vr_node_list_segcab xmldom.DOMNodeList;
      vr_node_name_segcab VARCHAR2(100);
      vr_item_node_segcab xmldom.DOMNode;
      vr_valu_node_segcab xmldom.DOMNode;

      -- SubRotina para tratar a cabINF
      PROCEDURE pc_trata_CABinf(pr_node_cabinf IN xmldom.DOMNode
                               ,pr_dscritic   OUT VARCHAR2) IS
        -- SubItens da CABINF
        vr_elem_node_cabinf xmldom.DOMElement;
        vr_node_list_cabinf xmldom.DOMNodeList;
        vr_node_name_cabinf VARCHAR2(100);
        vr_item_node_cabinf xmldom.DOMNode;
        vr_valu_node_cabinf xmldom.DOMNode;

        -- SubItens da GrupoErro
        vr_elem_node_grperr xmldom.DOMElement;
        vr_node_list_grperr xmldom.DOMNodeList;
        vr_node_name_grperr VARCHAR2(100);
        vr_item_node_grperr xmldom.DOMNode;
        vr_valu_node_grperr xmldom.DOMNode;
      BEGIN -- inicio pc_trata_CABinf
        -- Ativar flag
        vr_aux_tagCABInf := TRUE;
        --
        -- Marcelo Telles Coelho - Projeto 475
        -- Identificar se existe a CABInfCancelamento
        vr_aux_tagCABInfCCL        := FALSE;
        vr_aux_tagCABInfConvertida := FALSE;
        vr_aux_CabInf_erro         := FALSE;
        vr_aux_CabInf_reenvio      := FALSE;
        --
        IF vr_node_name IN('CABInfCancelamento') THEN
          vr_aux_tagCABInfCCL := TRUE;
        END IF;
        --
        -- Identificar uma conversão de mensagem no JD
        IF vr_node_name IN('CABInfConvertida') THEN
          vr_aux_tagCABInfConvertida := TRUE;
        END IF;
        -- Fim Projeto 475
        --
        vr_elem_node_cabinf := xmldom.makeElement(pr_node_cabinf);
        -- Faz o get de toda a lista de filhos da CABINF
        vr_node_list_cabinf := xmldom.getChildrenByTagName(vr_elem_node_cabinf,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list_cabinf)-1 LOOP
          -- Buscar o item atual
          vr_item_node_cabinf := xmldom.item(vr_node_list_cabinf, i);
          -- Captura o nome e tipo do nodo
          vr_node_name_cabinf := xmldom.getNodeName(vr_item_node_cabinf);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node_cabinf) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          -- Para a tag CodMsg
          IF vr_node_name_cabinf = 'CodMsg' THEN
            -- Buscar valor da TAG
            vr_valu_node_cabinf := xmldom.getFirstChild(vr_item_node_cabinf);
            vr_aux_CodMsg       := fn_getValue(vr_valu_node_cabinf);
          -- Para a tag NumCtrlIF
          ELSIF vr_node_name_cabinf = 'NumCtrlIF' THEN
            -- Buscar valor da TAG
            vr_valu_node_cabinf := xmldom.getFirstChild(vr_item_node_cabinf);
            vr_aux_NumCtrlIF    := fn_getValue(vr_valu_node_cabinf);
            vr_nrcontrole_if    := fn_getValue(vr_valu_node_cabinf); -- Marcelo Telles Coelho - Projeto 475
          -- Erro de Inconsistencia
          ELSIF vr_node_name_cabinf = 'GrupoTagErro' THEN
            -- Buscar Nodos Filhos
            vr_elem_node_grperr := xmldom.makeElement(vr_item_node_cabinf);
            -- Faz o get de toda a lista de filhos da GrupoTabErro
            vr_node_list_grperr := xmldom.getChildrenByTagName(vr_elem_node_grperr,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grperr)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grperr := xmldom.item(vr_node_list_grperr, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grperr := xmldom.getNodeName(vr_item_node_grperr);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grperr) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node CodErro
              IF vr_node_name_grperr = 'CodErro' THEN
                -- Buscar valor da TAG
                vr_valu_node_grperr := xmldom.getFirstChild(vr_item_node_grperr);
                vr_aux_msgderro     := vr_aux_msgderro||', '||fn_getValue(vr_valu_node_grperr);
                -- Remover virgula a esquerda que fica quando é a primeira atribuição
                vr_aux_msgderro := LTRIM(vr_aux_msgderro,', ');
              -- Para o node TagErro
              ELSIF vr_node_name_grperr = 'TagErro' THEN
                -- Buscar valor da TAG
                vr_valu_node_grperr := xmldom.getFirstChild(vr_item_node_grperr);
                vr_aux_msgderro     := vr_aux_msgderro||', '||fn_getValue(vr_valu_node_grperr);
                -- Remover virgula a esquerda que fica quando é a primeira atribuição
                vr_aux_msgderro := LTRIM(vr_aux_msgderro,', ');
              END IF;
            END LOOP;
          END IF;
        END LOOP;
        --
        -- Marcelo Telles Coelho - Projeto 475
        -- As mensagens com erro não tem o NrControleIF, por isso será utilizado NrOperacao
        IF vr_aux_NumCtrlIF IS NULL THEN
          vr_aux_NumCtrlIF := vr_aux_NrOperacao;
          vr_nrcontrole_if := vr_aux_NrOperacao;
          IF vr_aux_CD_SITUACAO = 'E' THEN
            IF vr_txtmensg like '%<NumControleIF CodErro="EGEN0023"> </NumControleIF>%' THEN
              vr_aux_CabInf_reenvio := TRUE;
            ELSE
            vr_aux_tagCABInfCCL := TRUE;
            vr_aux_CabInf_erro  := TRUE;
          END IF;
        END IF;
        END IF;
        -- Fim Projeto 475
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_CABinf -->'||sqlerrm;
      END pc_trata_CABinf;

      -- SubRotina para tratar a IFs
      PROCEDURE pc_trata_IFs(pr_node      IN xmldom.DOMNode
                            ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da PAG0101/STR0018/STR0019
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens da GrupoSit
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_idx_grpsit       NUMBER := 0;
        vr_aux_descrica     VARCHAR2(1000);
      BEGIN -- pc_trata_IFs
        -- Reiniciar globais
        vr_aux_nrispbif := 0;
        vr_aux_cddbanco := 0;
        vr_aux_nmdbanco := null;

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos do nó passado
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          -- Para Pag0101
          IF vr_node_name = 'Grupo_PAG0101_SitIF' THEN
            -- Mensagem
            vr_aux_CodMsg := 'PAG0101';
            -- Busca os dados da IF Ativa
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos da GrupoTabErro
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
              -- Criar registro na PLTABLE
              vr_idx_grpsit := vr_tab_situacao_if.COUNT()+1;
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node ISPBIF
              IF vr_node_name_grpsit = 'ISPBIF' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_situacao_if(vr_idx_grpsit).nrispbif := GENE0002.fn_char_para_number(fn_getValue(vr_valu_node_grpsit));
              -- Outros
              ELSE
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_situacao_if(vr_idx_grpsit).cdsitope := GENE0002.fn_char_para_number(fn_getValue(vr_valu_node_grpsit));
              END IF;
            END LOOP;
          ELSE
            -- Buscar primeiro filho do nó para buscar seu valor em lógica única
            vr_valu_node := xmldom.getFirstChild(vr_item_node);
            vr_aux_descrica := fn_getValue(vr_valu_node);
            -- Copiar para a respectiva variavel conforme nome da tag
            IF vr_node_name = 'CodMsg' THEN
              vr_aux_CodMsg := vr_aux_descrica;
            ELSIF vr_node_name = 'CodProdt' THEN
              vr_aux_CodProdt := vr_aux_descrica;
            ELSIF vr_node_name IN('ISPBPartIncld_Altd','ISPBPartExcl') THEN
              vr_aux_nrispbif := GENE0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'NumCodIF' THEN
              vr_aux_cddbanco := GENE0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'NomPart'  THEN
              vr_aux_nmdbanco := vr_aux_descrica;
            ELSIF vr_node_name = 'DtIniOp' THEN
              vr_aux_dtinispb := vr_aux_descrica;
            END IF;
          END IF;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_IFs -->'||sqlerrm;
      END pc_trata_IFs;

      -- SubRotina para tratar Portabilidade de Crédito
      PROCEDURE pc_trata_portabilidade(pr_node      IN xmldom.DOMNode
                                      ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da STR0047R2
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

      BEGIN -- inicio pc_trata_portabilidade
        -- Reiniciar globais
        vr_aux_CodMsg := 'STR0047R2';

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;

          -- Para AgeFinDed
          IF vr_node_name = 'Grupo_STR0047R2_AgtFinancDebtd' THEN
            -- Busca filhos
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node CtDebtd
              IF vr_node_name_grpsit = 'CtDebtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CtDebtd := fn_getValue(vr_valu_node_grpsit);
              END IF;
            END LOOP;
          -- Para AgeFinCre
          ELSIF vr_node_name = 'Grupo_STR0047R2_AgtFinancCredtd' THEN
            -- Busca filhos
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node CtCredtd
              IF vr_node_name_grpsit = 'CtCredtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CtCredtd     := fn_getValue(vr_valu_node_grpsit);
              -- CNPJ
              ELSIF vr_node_name_grpsit = 'CNPJCliCredtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CNPJ_CPFCred := fn_getValue(vr_valu_node_grpsit);
              -- Nome
              ELSIF vr_node_name_grpsit = 'NomCliCredtd' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_NomCliCredtd := fn_getValue(vr_valu_node_grpsit);
              END IF;
            END LOOP;
          ELSE
            -- Buscar primeiro filho do nó para buscar seu valor em lógica única
            vr_valu_node := xmldom.getFirstChild(vr_item_node);
            vr_aux_descrica := fn_getValue(vr_valu_node);
            -- Copiar para a respectiva variavel conforme nome da tag
            IF vr_node_name = 'NumCtrlSTR' THEN
              vr_aux_NumCtrlRem := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFDebtd' THEN
              vr_aux_ISPBIFDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFCredtd' THEN
              vr_aux_ISPBIFCredtd := vr_aux_descrica;
            ELSIF vr_node_name = 'AgCredtd' THEN
              vr_aux_AgCredtd := vr_aux_descrica;
            ELSIF vr_node_name = 'NUPortdd'  THEN
              vr_aux_NUPortdd := vr_aux_descrica;
            ELSIF vr_node_name = 'DtMovto' THEN
              vr_aux_DtMovto := vr_aux_descrica;
            ELSIF vr_node_name = 'VlrLanc' THEN
              vr_aux_DsVlrLanc := gene0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'IdentcDep' THEN
              vr_aux_IdentcDep := vr_aux_descrica;
            ELSIF vr_node_name = 'DtHrBC' THEN
              vr_aux_DtHRBC := vr_aux_descrica;
            END IF;
          END IF;
        END LOOP;
        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_portabilidade -->'||sqlerrm;
      END pc_trata_portabilidade;

      -- SubRotina para tratar Recolhimento Numerario
      PROCEDURE pc_trata_numerario(pr_node      IN xmldom.DOMNode
                                  ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da STR0047R2
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- VAriaveis genéricas
        vr_idx_numerario NUMBER;
        vr_aux_descrica  VARCHAR2(1000);

      BEGIN -- inicio pc_trata_numerario

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;

          -- Para AgeFinDed
          IF vr_node_name = 'Grupo_STR0003R2_Den' THEN
            -- Setar mensagem e indice pltable
            vr_aux_CodMsg := 'STR0003R2';
            vr_idx_numerario := vr_tab_numerario.count()+1;

            -- Busca filhos
            vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de filhos
            vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              -- Para o node Catg
              IF vr_node_name_grpsit = 'Catg' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_numerario(vr_idx_numerario).cdcatego := gene0002.fn_char_para_number(fn_getValue(vr_valu_node_grpsit));
              -- Para o node VlrDen
              ELSIF vr_node_name_grpsit = 'VlrDen' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_numerario(vr_idx_numerario).vlrdenom := gene0002.fn_char_para_number(fn_getValue(vr_valu_node_grpsit));
              -- Outros
              ELSE
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_tab_numerario(vr_idx_numerario).qtddenom := gene0002.fn_char_para_number(fn_getValue(vr_valu_node_grpsit));
              END IF;
            END LOOP;
          ELSE
            -- Buscar primeiro filho do nó para buscar seu valor em lógica única
            vr_valu_node := xmldom.getFirstChild(vr_item_node);
            vr_aux_descrica := fn_getValue(vr_valu_node);
            -- Copiar para a respectiva variavel conforme nome da tag
            IF vr_node_name = 'CodMsg' THEN
              vr_aux_CodMsg := vr_aux_descrica;
            ELSIF vr_node_name = 'NumCtrlSTR' THEN
              vr_aux_NumCtrlRem := vr_aux_descrica;
            ELSIF vr_node_name = 'DtHrBC' THEN
              vr_aux_DtHRBC := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFDebtd' THEN
              vr_aux_ISPBIFDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'AgDebtd'  THEN
              vr_aux_AgDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'ISPBIFCredtd' THEN
              vr_aux_ISPBIFCredtd := vr_aux_descrica;
            ELSIF vr_node_name = 'AgCredtd' THEN
              vr_aux_AgCredtd := gene0002.fn_char_para_number(vr_aux_descrica);
            ELSIF vr_node_name = 'VlrLanc' THEN
              vr_aux_DsVlrLanc := vr_aux_descrica;
            ELSIF vr_node_name = 'CodMunicOrigem' THEN
              vr_aux_CodMunicOrigem := vr_aux_descrica;
            ELSIF vr_node_name = 'CodMunicDest' THEN
              vr_aux_CodMunicDest := vr_aux_descrica;
            ELSIF vr_node_name = 'DtMovto' THEN
              vr_aux_DtMovto := vr_aux_descrica;
            END IF;
          END IF;
        END LOOP;
        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_numerario -->'||sqlerrm;
      END pc_trata_numerario;

      PROCEDURE pc_trata_numerario_cir0020(pr_node      IN xmldom.DOMNode
                                          ,pr_dscritic OUT VARCHAR2) IS
      /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */       

        -- SubItens da STR0047R2
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- VAriaveis genéricas
        vr_aux_descrica  VARCHAR2(1000);

      BEGIN -- inicio pc_trata_numerario_cir0020

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;

          -- Buscar primeiro filho do nó para buscar seu valor em lógica única
          vr_valu_node := xmldom.getFirstChild(vr_item_node);
          vr_aux_descrica := fn_getValue(vr_valu_node);
          -- Copiar para a respectiva variavel conforme nome da tag
          IF vr_node_name = 'CodMsg' THEN
            vr_aux_CodMsg := vr_aux_descrica;
          ELSIF vr_node_name = 'NumCtrlIF' THEN
            vr_aux_NumCtrlIF := vr_aux_descrica;
            vr_nrcontrole_if := NULL; -- Marcelo Telles Coelho - Projeto 475
          ELSIF vr_node_name = 'ISPBIF' THEN
            vr_aux_ISPBIF := vr_aux_descrica;
          ELSIF vr_node_name = 'NumCtrlCIROr' THEN
            vr_aux_NumCtrlCIROr := vr_aux_descrica;
          ELSIF vr_node_name = 'VlrLanc' THEN
            vr_aux_DsVlrLanc := vr_aux_descrica;
          ELSIF vr_node_name = 'DtMovto' THEN
            vr_aux_DtMovto := vr_aux_descrica;
          END IF;
        END LOOP;
        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_numerario_cir0020 -->'||sqlerrm;
      END pc_trata_numerario_cir0020;

      PROCEDURE pc_trata_numerario_cir0021(pr_node      IN xmldom.DOMNode
                                          ,pr_dscritic OUT VARCHAR2) IS
      /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */       

        -- SubItens da STR0047R2
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- VAriaveis genéricas
        vr_aux_descrica  VARCHAR2(1000);

      BEGIN -- inicio pc_trata_numerario_cir0021

        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;

          -- Buscar primeiro filho do nó para buscar seu valor em lógica única
          vr_valu_node := xmldom.getFirstChild(vr_item_node);
          vr_aux_descrica := fn_getValue(vr_valu_node);
          -- Copiar para a respectiva variavel conforme nome da tag
          IF vr_node_name = 'CodMsg' THEN
            vr_aux_CodMsg := vr_aux_descrica;
          ELSIF vr_node_name = 'NumCtrlCIR' THEN
            vr_aux_NumCtrlCIR := vr_aux_descrica;
          ELSIF vr_node_name = 'ISPBIF' THEN
            vr_aux_ISPBIF := vr_aux_descrica;
          ELSIF vr_node_name = 'NumCtrlSTR' THEN
            vr_aux_NumCtrlSTR := vr_aux_descrica;
            vr_aux_NumCtrlRem := vr_aux_descrica; -- Marcelo Telles Coelho - Projeto 475
          ELSIF vr_node_name = 'NumRemessaOr' THEN
            vr_aux_NumRemessaOr := vr_aux_descrica;
          ELSIF vr_node_name = 'AgIF' THEN
            vr_aux_AgIF := vr_aux_descrica;
          ELSIF vr_node_name = 'FinlddCIR' THEN
            vr_aux_FinlddCIR := vr_aux_descrica;
          ELSIF vr_node_name = 'DtHrBC' THEN
            vr_aux_DtHrBC := vr_aux_descrica;
          ELSIF vr_node_name = 'VlrLanc' THEN
            vr_aux_DsVlrLanc := vr_aux_descrica;
          ELSIF vr_node_name = 'DtMovto' THEN
            vr_aux_DtMovto := vr_aux_descrica;
          END IF;
        END LOOP;
        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_numerario_cir0021 -->'||sqlerrm;
      END pc_trata_numerario_cir0021;

      -- SubRotina para tratar a Transferencia de Valores
      PROCEDURE pc_trata_transfere(pr_node      IN xmldom.DOMNode
                                  ,pr_dscritic OUT VARCHAR2) IS
        -- SubItens
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

      BEGIN -- inicio pc_trata_transfere
        --
        -- Buscar todos os filhos deste nó
        vr_elem_node := xmldom.makeElement(pr_node);
        -- Faz o get de toda a lista de filhos da CABINF
        vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
        -- Percorrer os elementos
        FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
          -- Buscar o item atual
          vr_item_node := xmldom.item(vr_node_list, i);
          -- Captura o nome e tipo do nodo
          vr_node_name := xmldom.getNodeName(vr_item_node);
          -- Sair se o nodo não for elemento
          IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
            CONTINUE;
          END IF;
          -- Buscar primeiro filho do nó para buscar seu valor em lógica única
          vr_valu_node := xmldom.getFirstChild(vr_item_node);
          vr_aux_descrica := fn_getValue(vr_valu_node);

          -- Gravar variaveis conforme tag em leitura
          IF vr_node_name = 'Grupo_STR0006R2_CtDebtd' THEN
            -- Buscar todos os filhos deste nó
            vr_elem_node := xmldom.makeElement(vr_item_node);
            -- Faz o get de toda a lista de folhas da SEGCAB
            vr_node_list_segcab := xmldom.getChildrenByTagName(vr_elem_node,'*');

            -- Percorrer os elementos
            FOR i IN 0..xmldom.getLength(vr_node_list_segcab)-1 LOOP

              -- Buscar o item atual
              vr_item_node_segcab := xmldom.item(vr_node_list_segcab, i);
              -- Captura o nome e tipo do nodo
              vr_node_name_segcab := xmldom.getNodeName(vr_item_node_segcab);

              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_segcab) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;

              -- Para a tag NR_OPERACAO
              IF vr_node_name_segcab = 'TpCtDebtd' THEN
            -- Buscar valor da TAG
                vr_aux_descrica  := fn_getValue(xmldom.getFirstChild(vr_item_node_segcab));
                vr_aux_TpCtDebtd := vr_aux_descrica;
              END IF;
              -- Para a tag NR_OPERACAO
              IF vr_node_name_segcab = 'CtDebtd' THEN
                -- Buscar valor da TAG
                vr_aux_descrica := fn_getValue(xmldom.getFirstChild(vr_item_node_segcab));
                vr_aux_CtDebtd  := vr_aux_descrica;
              END IF;
            END LOOP;
          ELSIF vr_node_name = 'CodMsg' THEN
            -- Buscar valor da TAG
            vr_aux_CodMsg := vr_aux_descrica;
            -- Nas mensagens de devolucao, o Numero de Controle Original
            -- gerado pela cooperativa eh obtido pela TAG <NR_OPERACAO>
            IF vr_aux_CodMsg in ('STR0010R2','PAG0111R2') THEN
              vr_aux_NumCtrlIF := vr_aux_NrOperacao;
            END IF;
          ELSIF vr_node_name = 'NumCtrlIF' THEN
            -- Numero de Controle da Cooperativa
            vr_aux_NumCtrlIF := vr_aux_descrica;
            vr_nrcontrole_if := vr_aux_descrica; -- Marcelo Telles Coelho - Projeto 475
          ELSIF vr_node_name IN('NumCtrlSTR','NumCtrlPAG') THEN
            -- Numero de Controle do Remetente
            vr_aux_NumCtrlRem := vr_aux_descrica;
          ELSIF vr_node_name IN('NumCtrlSTROr','NumCtrlPAGOr') THEN -- Marcelo Telles Coelho - Projeto 475
            -- Numero de Controle do Remetente de origem            -- Marcelo Telles Coelho - Projeto 475
            vr_aux_NumCtrlRem_Or := vr_aux_descrica;                -- Marcelo Telles Coelho - Projeto 475
          ELSIF vr_node_name = 'ISPBIFDebtd' THEN
            vr_aux_ISPBIFDebtd := vr_aux_descrica;
          ELSIF vr_node_name IN('AgDebtd','CtDebtd','CPFCliDebtd','CNPJ_CPFCliDebtd','CNPJ_CPFCliDebtdTitlar1','CNPJ_CPFCliDebtdTitlar2','CNPJ_CPFRemet','CNPJ_CPFCliDebtd_Remet') THEN
            IF vr_node_name = 'AgDebtd' THEN
              vr_aux_AgDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'CtDebtd' THEN
              vr_aux_CtDebtd := vr_aux_descrica;
            ELSIF vr_node_name = 'CPFCliDebtd' THEN
              vr_aux_CNPJ_CPFCred := vr_aux_descrica;
              vr_aux_CNPJ_CPFDeb  := vr_aux_descrica;
            ELSIF vr_node_name IN('CNPJ_CPFCliDebtd','CNPJ_CPFCliDebtdTitlar1','CNPJ_CPFCliDebtdTitlar2','CNPJ_CPFRemet','CNPJ_CPFCliDebtd_Remet') THEN
              vr_aux_CNPJ_CPFDeb := vr_aux_descrica;
            END IF;
            IF vr_aux_dadosdeb IS NULL THEN
              vr_aux_dadosdeb := vr_node_name || ':' || vr_aux_descrica;
            ELSE
              vr_aux_dadosdeb := vr_aux_dadosdeb || ' / '
                              || vr_node_name || ':' || vr_aux_descrica;
            END IF;
          ELSIF vr_node_name = 'TpCtDebtd' THEN
            vr_aux_TpCtDebtd := vr_aux_descrica;
          ELSIF vr_node_name = 'CtPgtoDebtd' THEN
            vr_aux_CtPgtoDebtd := vr_aux_descrica;
          ELSIF vr_node_name IN('NomCliDebtd','NomCliDebtdTitlar1','NomRemet','NomCliDebtd_Remet') THEN
            vr_aux_NomCliDebtd := vr_aux_descrica;
            -- Transferencia entre mesma titularidade
            IF vr_aux_CodMsg IN('STR0037R2','PAG0137R2') THEN
              vr_aux_NomCliCredtd := vr_aux_descrica;
            END IF;
          ELSIF vr_node_name IN('NomCliCredtd','NomDestinatario','NomCliCredtdTitlar1') THEN
            vr_aux_NomCliCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'ISPBIFCredtd' THEN
            vr_aux_ISPBIFCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'AgCredtd' THEN
            vr_aux_AgCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'TpCtCredtd' THEN
            vr_aux_TpCtCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'CtPgtoCredtd' THEN
            vr_aux_CtPgtoCredtd := vr_aux_descrica;
          ELSIF vr_node_name IN('TpPessoaCredtd','TpPessoaDestinatario') THEN
            vr_aux_TpPessoaCred := vr_aux_descrica;
          ELSIF vr_node_name IN('CNPJ_CPFCliCredtd','CNPJ_CPFDestinatario','CNPJ_CPFCliCredtdTitlar1') THEN
            vr_aux_CNPJ_CPFCred := vr_aux_descrica;
          ELSIF vr_node_name = 'CtCredtd' THEN
            vr_aux_CtCredtd := vr_aux_descrica;
          ELSIF vr_node_name = 'VlrLanc' THEN
            vr_aux_DsVlrLanc := gene0002.fn_char_para_number(vr_aux_descrica);
          ELSIF vr_node_name = 'IdentcDep' THEN
            vr_aux_IdentcDep := vr_aux_descrica;
          ELSIF vr_node_name = 'NumCodBarras' AND vr_aux_CodMsg = 'STR0026R2' THEN
            vr_aux_NumCodBarras := vr_aux_descrica;
          ELSIF vr_node_name IN('SitLancSTR','SitLancPAG'
                               ,'SitOpSEL'                -- Marcelo Telles Coelho - Projeto 475
                               ) THEN
            vr_aux_SitLanc:= vr_aux_descrica;
          ELSIF vr_node_name = 'CodDevTransf' THEN
            vr_aux_CodDevTransf := vr_aux_descrica;
          ELSIF vr_node_name = 'DtMovto' THEN
            vr_aux_DtMovto := vr_aux_descrica;
          ELSIF vr_node_name = 'CNPJNLiqdant'  THEN
            -- CNPJ Liquidante - antecipaçao de recebíveis - Mauricio
            vr_aux_CNPJNLiqdant := vr_aux_descrica;
          ELSIF vr_node_name = 'FinlddIF'  THEN
            -- Tratamento mensagem LTR0005R2 - Mauricio - 03/11/2017
            vr_aux_FinlddIF := vr_aux_descrica;
          ELSIF vr_node_name = 'Hist'  THEN
            vr_aux_Hist := vr_aux_descrica;
          ELSIF vr_node_name = 'DtHrBC'  THEN
            vr_aux_DtHrBC := vr_aux_descrica;
          ELSIF vr_node_name IN('DtHrPAG','DtHrSTR') THEN  -- Marcelo Telles Coelho - Projeto 475
            -- Data/Hora postagem mensagem pelo BACEN      -- Marcelo Telles Coelho - Projeto 475
            vr_aux_DtHrBC := vr_aux_descrica;              -- Marcelo Telles Coelho - Projeto 475
          ElSIF vr_node_name = 'TpPessoaDebtd_Remet'  THEN
            vr_aux_TpPessoaDebtd_Remet := vr_aux_descrica;
          ELSIF vr_node_name = 'TpPessoaDebtd' AND TRIM(vr_aux_TpPessoaDebtd_Remet) IS NULL THEN
            vr_aux_TpPessoaDebtd_Remet := vr_aux_descrica;
          ElSIF vr_node_name = 'FinlddCli'  THEN
            vr_aux_FinlddCli := vr_aux_descrica;
          ElSIF vr_node_name = 'NumCtrlLTR'  THEN
            vr_aux_NumCtrlLTR := vr_aux_descrica;
            vr_aux_NumCtrlRem := vr_aux_descrica;          -- Marcelo Telles Coelho - Projeto 475
          ElSIF vr_node_name = 'ISPBLTR'  THEN
            vr_aux_ISPBLTR := vr_aux_descrica;
          ElSIF  vr_node_name = 'IdentdPartCamr'  THEN
            vr_aux_IdentdPartCamr := vr_aux_descrica;
          ELSIF vr_node_name LIKE 'NumCtrlLDLOr' THEN      -- Marcelo Telles Coelho - Projeto 475
            NULL;                                          -- Marcelo Telles Coelho - Projeto 475
          ELSIF vr_node_name LIKE 'NumCtrl%' THEN          -- Marcelo Telles Coelho - Projeto 475
            IF vr_aux_NumCtrlIF IS NULL THEN               -- Marcelo Telles Coelho - Projeto 475
              -- Numero de Controle da Cooperativa         -- Marcelo Telles Coelho - Projeto 475
              vr_aux_NumCtrlIF := vr_aux_descrica;         -- Marcelo Telles Coelho - Projeto 475
              vr_nrcontrole_if := vr_aux_descrica;         -- Marcelo Telles Coelho - Projeto 475
            END IF;
          ELSIF vr_node_name = 'CodProdt' THEN             -- Jose Dill Sprint D - Req19
            vr_aux_CodProdt := vr_aux_descrica; 
          ELSIF vr_node_name = 'SubTpAtv' THEN             -- Jose Dill Sprint D - Req19
            vr_aux_SubTpAtv := vr_aux_descrica; 
          ELSIF vr_node_name = 'DtAgendt' THEN             -- Jose Dill Sprint D - Req19
            vr_aux_DtAgendt := vr_aux_descrica; 
          END IF;
        END LOOP;

        -- Se conta debitada for Conta de Pagamento
        IF vr_aux_TpCtDebtd = 'PG' THEN
          vr_aux_CtDebtd := vr_aux_CtPgtoDebtd;
        END IF;
        -- Se conta creditada for Conta de Pagamento
        IF vr_aux_TpCtCredtd = 'PG' THEN
          vr_aux_CtCredtd := vr_aux_CtPgtoCredtd;
        END IF;

        -- Se houve retorno de valor
        IF trim(vr_aux_DsVlrLanc) IS NOT NULL THEN
          vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_transfere -->'||sqlerrm;
      END pc_trata_transfere;

      -- SubRotina para tratar a GEN% e %E
      PROCEDURE pc_trata_GEN(pr_node_name  IN VARCHAR2
                            ,pr_node_valor IN VARCHAR2
                            ,pr_dscritic  OUT VARCHAR2) IS
        -- Marcelo Telles Coelho - Projeto 475
        -- Procedure para tratar as mensagens GEN e %E

      BEGIN -- inicio pc_trata_GEN
        -- Setar flags
        vr_aux_tagCABInf           := TRUE;
        vr_aux_tagCABInfCCL        := TRUE;
        vr_aux_tagCABInfConvertida := FALSE;
        --
        vr_aux_NumCtrlIF := vr_aux_NrOperacao;
        vr_nrcontrole_if := vr_aux_NrOperacao;
        -- Para a tag CodMsg
        IF pr_node_name = 'CodMsg' THEN
          IF LENGTH(pr_node_valor) > 10 THEN
            vr_aux_CodMsg     := SUBSTR(pr_node_valor,LENGTH(pr_node_valor)-8,9);
          ELSE
            vr_aux_CodMsg     := pr_node_valor;
          END IF;
        -- Erro de Inconsistencia
        ELSIF pr_node_name = 'ErroGEN' THEN
          vr_aux_msgderro     := pr_node_valor;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro no tratamento do Node pc_trata_GEN -->'||sqlerrm;
      END pc_trata_GEN;

PROCEDURE pc_trata_arquivo_slc0005(pr_node      IN xmldom.DOMNode
                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da SLC0005
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

        vr_ind  NUMBER;
        vr_ind1 NUMBER;
        vr_ind2 NUMBER;

BEGIN -- inicio pc_trata_arquivo_slc0005
    -- Reiniciar globais
    vr_aux_CodMsg := 'SLC0005';

    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);

      -- Buscar primeiro filho do nó para buscar seu valor em lógica única
      vr_valu_node := xmldom.getFirstChild(vr_item_node);
      vr_aux_descrica := xmldom.getNodeValue(vr_valu_node);
      -- Copiar para a respectiva variavel conforme nome da tag
      IF vr_node_name = 'CodMsg' THEN
        vr_aux_codmsg := vr_aux_descrica;
      ELSIF vr_node_name = 'NumCtrlSLC' THEN
        vr_aux_NumCtrlSLC := vr_aux_descrica;
        vr_aux_NumCtrlRem := vr_aux_descrica; -- Marcelo Telles Coelho - Projeto 475
      ELSIF vr_node_name = 'ISPBIF' THEN
        vr_aux_ISPBIF := vr_aux_descrica;
      ELSIF vr_node_name = 'NumCtrlLTROr' THEN
        vr_aux_NumCtrlLTROr := vr_aux_descrica;
      ELSIF vr_node_name = 'TpDeb_Cred' THEN
        vr_aux_TpDebCred := vr_aux_descrica;
      ELSIF vr_node_name = 'ISPBIFDebtd' then
        vr_aux_ISPBIFDebtd := vr_aux_descrica;
      ELSIF vr_node_name = 'CNPJNLiqdantDebtd' THEN
        vr_aux_CNPJNLiqdantDebtd := vr_aux_descrica;
      ELSIF vr_node_name = 'NomCliDebtd' THEN
        vr_aux_NomCliDebtd := vr_aux_descrica;
      ELSIF vr_node_name = 'ISPBIFCredtd' then
        vr_aux_ISPBIFCredtd := vr_aux_descrica;
      ELSIF vr_node_name = 'CNPJNLiqdantCredtd' then
        vr_aux_CNPJNLiqdantCredtd := vr_aux_descrica;
      ELSIF vr_node_name = 'NomCliCredtd' then
        vr_aux_NomCliCredtd := vr_aux_descrica;
      ELSIF vr_node_name = 'VlrLanc' then
        vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_descrica);
      /*ELSIF vr_node_name = 'SubTpAtv' then
        vr_aux_SubTpAtv := vr_aux_descrica;
      ELSIF vr_node_name = 'DescAtv' then
        vr_aux_DescAtv := vr_aux_descrica;*/
      ELSIF vr_node_name = 'IndrDevLiquid' then
        vr_aux_IndrDevLiquid := vr_aux_descrica;
      ELSIF vr_node_name = 'NomArqSLC' then
        vr_aux_NomArqSLC := vr_aux_descrica;
      ELSIF vr_node_name = 'NumCtrlEmissorArq' then
        vr_aux_NumCtrlEmissorArq := vr_aux_descrica;
      ELSIF vr_node_name = 'DtHrSLC' then
        vr_aux_DtHrSLC := vr_aux_descrica;
        vr_aux_DtHrBC  := vr_aux_descrica;              -- Marcelo Telles Coelho - Projeto 475
      ELSIF vr_node_name = 'DtMovto' THEN
        vr_aux_DtMovto := vr_aux_descrica;
      END IF;

    END LOOP;

    cecred.ccrd0006.pc_insere_msg_slc(vr_aux_VlrLanc
                                     ,vr_aux_codmsg
                                     ,vr_aux_NumCtrlSLC
                                     ,vr_aux_ISPBIF
                                     ,NULL --vr_aux_DtLiquid
                                     ,NULL --vr_aux_NumSeqCicloLiquid
                                     ,NULL --vr_aux_CodProdt
                                     ,NULL --vr_aux_IdentLinhaBilat
                                     ,vr_aux_TpDebCred
                                     ,vr_aux_ISPBIFCredtd
                                     ,vr_aux_ISPBIFDebtd
                                     ,vr_aux_CNPJNLiqdantDebtd
                                     ,vr_aux_NomCliDebtd
                                     ,vr_aux_CNPJNLiqdantCredtd
                                     ,vr_aux_NomCliCredtd
                                     ,vr_aux_DtHrSLC
                                     ,vr_aux_DtMovto
                                     ,NULL --vr_aux_TpTranscSLC
                                     ,vr_aux_NomArqSLC
                                     ,vr_aux_NumCtrlLTROr
                                     ,vr_aux_IndrDevLiquid
                                     ,vr_aux_NumCtrlEmissorArq
                                     ,vr_dscritic);

    -- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
       -- Acionar rotina de LOG
       BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                 ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                 ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                      ||' - '|| vr_glb_cdprogra ||' --> '
                                                      || 'pc_insere_msg_slc0005 --> '||vr_dscritic
                                 ,pr_nmarqlog      => vr_logprogr
                                 ,pr_cdprograma    => vr_glb_cdprogra
                                 ,pr_dstiplog      => 'E'
                                 ,pr_tpexecucao    => 3
                                 ,pr_cdcriticidade => 0
                                 ,pr_flgsucesso    => 1
                                 ,pr_cdmensagem    => vr_cdcritic);
    END IF;
    
    pc_gera_log_SPB('RECEBIDA OK'
                   ,'SLC RECEBIDA');

EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_SLC0005 -->'||sqlerrm;
END pc_trata_arquivo_slc0005;


PROCEDURE pc_trata_arquivo_slc0001(pr_node      IN xmldom.DOMNode

                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da SLC0001
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- SubItens1 de Grupo
        vr_elem_node_grpsit1 xmldom.DOMElement;
        vr_node_list_grpsit1 xmldom.DOMNodeList;
        vr_node_name_grpsit1 VARCHAR2(100);
        vr_item_node_grpsit1 xmldom.DOMNode;
        vr_valu_node_grpsit1 xmldom.DOMNode;

        -- SubItens2 de Grupo
        vr_elem_node_grpsit2 xmldom.DOMElement;
        vr_node_list_grpsit2 xmldom.DOMNodeList;
        vr_node_name_grpsit2 VARCHAR2(100);
        vr_item_node_grpsit2 xmldom.DOMNode;
        vr_valu_node_grpsit2 xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

        vr_ind  NUMBER;
        vr_ind1 NUMBER;
        vr_ind2 NUMBER;

BEGIN -- inicio pc_trata_arquivo_slc0001
    -- Reiniciar globais
    vr_aux_CodMsg := 'SLC0001';

    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      IF vr_node_name = 'Grupo_SLC0001_Liquid' THEN
         -- Busca filhos
         vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
         -- Faz o get de toda a lista de filhos
         vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
         -- Percorrer os elementos
         FOR vr_ind1 IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, vr_ind1);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              IF vr_node_name_grpsit = 'DtLiquid' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_DtLiquid := fn_getValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'NumSeqCicloLiquid' THEN
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_NumSeqCicloLiquid := fn_getValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'Grupo_SLC0001_Prodt' THEN
                  -- Busca filhos
                  vr_elem_node_grpsit1 := xmldom.makeElement(vr_item_node_grpsit);
                  -- Faz o get de toda a lista de filhos
                  vr_node_list_grpsit1 := xmldom.getChildrenByTagName(vr_elem_node_grpsit1,'*');
                  -- Percorrer os elementos
                  FOR vr_ind2 IN 0..xmldom.getLength(vr_node_list_grpsit1)-1 LOOP
                    -- Buscar o item atual
                    vr_item_node_grpsit1 := xmldom.item(vr_node_list_grpsit1, vr_ind2);
                    -- Captura o nome e tipo do nodo
                    vr_node_name_grpsit1 := xmldom.getNodeName(vr_item_node_grpsit1);
                    -- Sair se o nodo não for elemento
                    IF xmldom.getNodeType(vr_item_node_grpsit1) <> xmldom.ELEMENT_NODE THEN
                       CONTINUE;
                    END IF;
                    IF vr_node_name_grpsit1 = 'CodProdt' THEN
                       vr_valu_node_grpsit1 := xmldom.getFirstChild(vr_item_node_grpsit1);
                       vr_aux_CodProdt := fn_getValue(vr_valu_node_grpsit1);
                    ELSIF vr_node_name_grpsit1 = 'Grupo_SLC0001_LiquidProdt' THEN
                       -- Busca filhos
                       vr_elem_node_grpsit2 := xmldom.makeElement(vr_item_node_grpsit1);
                       -- Faz o get de toda a lista de filhos
                       vr_node_list_grpsit2 := xmldom.getChildrenByTagName(vr_elem_node_grpsit2,'*');
                       -- Percorrer os elementos
                       FOR vr_ind3 IN 0..xmldom.getLength(vr_node_list_grpsit2)-1 LOOP
                         -- Buscar o item atual
                         vr_item_node_grpsit2 := xmldom.item(vr_node_list_grpsit2, vr_ind3);
                         -- Captura o nome e tipo do nodo
                         vr_node_name_grpsit2 := xmldom.getNodeName(vr_item_node_grpsit2);
                         -- Sair se o nodo não for elemento
                         IF xmldom.getNodeType(vr_item_node_grpsit2) <> xmldom.ELEMENT_NODE THEN
                            CONTINUE;
                         END IF;
                         IF vr_node_name_grpsit2 = 'IdentdLinhaBilat' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_IdentdLinhaBilat := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'TpDeb_Cred' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_TpDeb_Cred := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'ISPBIFCredtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_ISPBIFCredtd := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'ISPBIFDebtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_ISPBIFDebtd := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'VlrLanc' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_DsVlrLanc := fn_getValue(vr_valu_node_grpsit2);
                            vr_aux_VlrLanc := gene0002.fn_char_para_number(vr_aux_DsVlrLanc);
                         ELSIF vr_node_name_grpsit2 = 'CNPJNLiqdantDebtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_CNPJNLiqdantDebtd := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'NomCliDebtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_NomCliDebtd := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'CNPJNLiqdantCredtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_CNPJNLiqdantCredtd := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'NomCliCredtd' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_NomCliCredtd := fn_getValue(vr_valu_node_grpsit2);
                         ELSIF vr_node_name_grpsit2 = 'TpTranscSLC' THEN
                            vr_valu_node_grpsit2 := xmldom.getFirstChild(vr_item_node_grpsit2);
                            vr_aux_TpTranscSLC := fn_getValue(vr_valu_node_grpsit2);
                            IF  vr_aux_TpInf = 'D' THEN -- Apenas para mensagens com tipo = D - Definitiva

                                cecred.ccrd0006.pc_insere_msg_slc(vr_aux_VlrLanc
                                                                 ,vr_aux_codmsg
                                                                 ,vr_aux_NumCtrlSLC
                                                                 ,vr_aux_ISPBIF
                                                                 ,vr_aux_DtLiquid
                                                                 ,vr_aux_NumSeqCicloLiquid
                                                                 ,vr_aux_CodProdt
                                                                 ,vr_aux_IdentLinhaBilat
                                                                 ,vr_aux_TpDebCred
                                                                 ,vr_aux_ISPBIFCredtd
                                                                 ,vr_aux_ISPBIFDebtd
                                                                 ,vr_aux_CNPJNLiqdantDebtd
                                                                 ,vr_aux_NomCliDebtd
                                                                 ,vr_aux_CNPJNLiqdantCredtd
                                                                 ,vr_aux_NomCliCredtd
                                                                 ,vr_aux_DtHrSLC
                                                                 ,vr_aux_DtMovto
                                                                 ,vr_aux_TpTranscSLC
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL
                                                                 ,NULL			
                                                                 ,vr_dscritic);

                                -- Se retornou erro
                                IF vr_dscritic IS NOT NULL THEN
                                   -- Acionar rotina de LOG
                                   BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                                             ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                                             ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                                                  ||' - '|| vr_glb_cdprogra ||' --> '
                                                                                  || 'pc_insere_msg_slc0001 --> '||vr_dscritic
                                                             ,pr_nmarqlog      => vr_logprogr
                                                             ,pr_cdprograma    => vr_glb_cdprogra
                                                             ,pr_dstiplog      => 'E'
                                                             ,pr_tpexecucao    => 3
                                                             ,pr_cdcriticidade => 0
                                                             ,pr_flgsucesso    => 1
                                                             ,pr_cdmensagem    => vr_cdcritic);
                                END IF;
                            END IF;
                         END IF;
                       END LOOP;
                    END IF;
                  END LOOP;
              END IF;
         END LOOP;
      ELSE
         -- Buscar primeiro filho do nó para buscar seu valor em lógica única
         vr_valu_node := xmldom.getFirstChild(vr_item_node);
         vr_aux_descrica := fn_getValue(vr_valu_node);
         -- Copiar para a respectiva variavel conforme nome da tag
         IF vr_node_name = 'NumCtrlSLC' THEN
            -- Numero de Controle do Remetente
            vr_aux_NumCtrlSLC := vr_aux_descrica;
            vr_aux_NumCtrlRem := vr_aux_descrica; -- Marcelo Telles Coelho - Projeto 475
         ELSIF vr_node_name = 'ISPBIF' THEN
            vr_aux_ISPBIF := vr_aux_descrica;
         ELSIF vr_node_name = 'TpInf' THEN
            vr_aux_TpInf := vr_aux_descrica;
         ELSIF vr_node_name = 'DtHrSLC' THEN
            vr_aux_DtHrSLC := vr_aux_descrica;
            vr_aux_DtHrBC  := vr_aux_descrica;              -- Marcelo Telles Coelho - Projeto 475
         ELSIF vr_node_name = 'DtMovto' THEN
            vr_aux_DtMovto := vr_aux_descrica;
         END IF;
      END IF;
    END LOOP;
    
    pc_gera_log_SPB('RECEBIDA OK'
                   ,'SLC RECEBIDA');

EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_slc0001 -->'||sqlerrm;
END pc_trata_arquivo_slc0001;

PROCEDURE pc_trata_arquivo_ldl(pr_node      IN xmldom.DOMNode
                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens da LDL0024/LDL0022
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

        vr_ind  NUMBER;
        vr_ind1 NUMBER;
        vr_ind2 NUMBER;

BEGIN 
    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      -- Buscar primeiro filho do nó para buscar seu valor em lógica única
      vr_valu_node := xmldom.getFirstChild(vr_item_node);
      vr_aux_descrica := fn_getValue(vr_valu_node);
      IF vr_node_name = 'CodMsg' THEN
        -- Buscar valor da TAG
        vr_aux_CodMsg := vr_aux_descrica;
      ELSIF vr_node_name = 'CodProdt' THEN
        -- Numero de Controle do Remetente 
        vr_aux_CodProdt := vr_aux_descrica;
      ELSIF vr_node_name = 'NumCtrlLDL' THEN
        vr_aux_NumCtrlRem := vr_aux_descrica; 
      ELSIF vr_node_name = 'DtRef' THEN  
        vr_aux_DtRef := vr_aux_descrica;
      ELSIF vr_node_name = 'NumCtrlIF' THEN
        -- Numero de Controle da Cooperativa
        vr_aux_NumCtrlIF := vr_aux_descrica;
        vr_nrcontrole_if := vr_aux_descrica; 
      ELSIF vr_node_name = 'VlrLanc' THEN
        vr_aux_DsVlrLanc := gene0002.fn_char_para_number(vr_aux_descrica);
      ELSIF vr_node_name = 'DtMovto' THEN
        vr_aux_DtMovto := vr_aux_descrica;
      END IF;
    END LOOP;
    
    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      
      IF vr_node_name = 'Grupo_LDL0024_HrioCamr' THEN
         -- Busca filhos
         vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
         -- Faz o get de toda a lista de filhos
         vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
         -- Percorrer os elementos
         FOR vr_ind1 IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
              -- Buscar o item atual
              vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, vr_ind1);
              -- Captura o nome e tipo do nodo
              vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
              -- Sair se o nodo não for elemento
              IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
                CONTINUE;
              END IF;
              IF vr_node_name_grpsit = 'CodGrdLDL' THEN
                -- Buscar valor da TAG
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_CodGrdLDL := fn_getValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'DtHrAbert' THEN
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_DtHrAbert := fn_getValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'DtHrFcht' THEN
                vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                vr_aux_DtHrFcht := fn_getValue(vr_valu_node_grpsit);
              ELSIF vr_node_name_grpsit = 'TpHrio' THEN
                  vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
                  vr_aux_TpHrio := fn_getValue(vr_valu_node_grpsit);
                  
                  IF  vr_aux_CodProdt='SLC' and vr_aux_CodGrdLDL in ('PAG94','PAGE3','PAGD3')  THEN
                      cecred.ccrd0006.pc_insere_horario_grade(vr_aux_codmsg
                                                             ,vr_aux_CodGrdLDL
                                                             ,vr_aux_DtHrAbert
                                                             ,vr_aux_DtHrFcht
                                                             ,vr_aux_TpHrio
                                                             ,vr_aux_DtRef
                                                             ,vr_dscritic);

                      -- Se retornou erro
                      IF vr_dscritic IS NOT NULL THEN
                         -- Acionar rotina de LOG
                         BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                                   ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                                   ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                                       ||' - '|| vr_glb_cdprogra ||' --> '
                                                                       || 'pc_insere_horario_grade --> '||vr_dscritic
                                                   ,pr_nmarqlog      => vr_logprogr
                                                   ,pr_cdprograma    => vr_glb_cdprogra
                                                   ,pr_dstiplog      => 'E'
                                                   ,pr_tpexecucao    => 3
                                                   ,pr_cdcriticidade => 0
                                                   ,pr_flgsucesso    => 1
                                                   ,pr_cdmensagem    => vr_cdcritic);
                      END IF;
                  END IF;
              END IF;
         END LOOP;
         END IF;
    END LOOP;
    --
    IF vr_aux_CodMsg = 'LDL0024' THEN
      pc_gera_log_SPB('RECEBIDA OK'
                     ,'LDL0024 RECEBIDA');
    END IF;
    
EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_ldl -->'||sqlerrm;
END pc_trata_arquivo_ldl;

PROCEDURE pc_trata_arquivo_rdc(pr_node      IN xmldom.DOMNode
                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens das RDCs
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

BEGIN 
    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      -- Buscar primeiro filho do nó para buscar seu valor em lógica única
      vr_valu_node := xmldom.getFirstChild(vr_item_node);
      vr_aux_descrica := fn_getValue(vr_valu_node);
      IF vr_node_name = 'CodMsg' THEN
        -- Buscar valor da TAG
        vr_aux_CodMsg := vr_aux_descrica;
      ELSIF vr_node_name = 'NumCtrlIF' THEN
        -- Numero de Controle da Cooperativa
        vr_aux_NumCtrlIF := vr_aux_descrica;
        vr_nrcontrole_if := vr_aux_descrica; 
      ELSIF vr_node_name = 'VlrFinanc' THEN
        vr_aux_DsVlrFinanc := gene0002.fn_char_para_number(vr_aux_descrica);
      ELSIF vr_node_name = 'DtMovto' THEN
        vr_aux_DtMovto := vr_aux_descrica;
      END IF;
    END LOOP;
    --
    
EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_rdc -->'||sqlerrm;
END pc_trata_arquivo_rdc;

PROCEDURE pc_trata_arquivo_sel(pr_node      IN xmldom.DOMNode
                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens das RDCs
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

BEGIN 
    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      -- Buscar primeiro filho do nó para buscar seu valor em lógica única
      vr_valu_node := xmldom.getFirstChild(vr_item_node);
      vr_aux_descrica := fn_getValue(vr_valu_node);
      IF vr_node_name = 'CodMsg' THEN
        -- Buscar valor da TAG
        vr_aux_CodMsg := vr_aux_descrica;
      ELSIF vr_node_name = 'DtMovto' THEN
        vr_aux_DtMovto := vr_aux_descrica;
      ELSIF vr_node_name = 'CtCed' THEN
        vr_aux_CtCed := vr_aux_descrica;
      ELSIF vr_node_name = 'VlrFinanc' THEN
        vr_aux_DsVlrFinanc := gene0002.fn_char_para_number(vr_aux_descrica);
      ELSIF vr_node_name = 'NumCtrlIF' THEN
        -- Numero de Controle da Cooperativa
        vr_aux_NumCtrlIF := vr_aux_descrica;
        vr_nrcontrole_if := vr_aux_descrica;         
      END IF;
    END LOOP;
    --
    
EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_sel -->'||sqlerrm;
END pc_trata_arquivo_sel;

PROCEDURE pc_trata_arquivo_slb(pr_node      IN xmldom.DOMNode
                              ,pr_dscritic OUT VARCHAR2) IS

        -- SubItens das SLBs
        vr_elem_node xmldom.DOMElement;
        vr_node_list xmldom.DOMNodeList;
        vr_node_name VARCHAR2(100);
        vr_item_node xmldom.DOMNode;
        vr_valu_node xmldom.DOMNode;

        -- SubItens de Grupo
        vr_elem_node_grpsit xmldom.DOMElement;
        vr_node_list_grpsit xmldom.DOMNodeList;
        vr_node_name_grpsit VARCHAR2(100);
        vr_item_node_grpsit xmldom.DOMNode;
        vr_valu_node_grpsit xmldom.DOMNode;

        -- Genéricas
        vr_aux_descrica     VARCHAR2(1000);

BEGIN 
    -- Buscar todos os filhos deste nó
    vr_elem_node := xmldom.makeElement(pr_node);
    -- Faz o get de toda a lista de filhos
    vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
    
    -- Percorrer os elementos
    FOR vr_ind IN 0..xmldom.getLength(vr_node_list)-1 LOOP
      -- Buscar o item atual
      vr_item_node := xmldom.item(vr_node_list, vr_ind);
      -- Captura o nome e tipo do nodo
      vr_node_name := xmldom.getNodeName(vr_item_node);
      -- Sair se o nodo não for elemento
      IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
         CONTINUE;
      END IF;
      -- Buscar primeiro filho do nó para buscar seu valor em lógica única
      vr_valu_node := xmldom.getFirstChild(vr_item_node);
      vr_aux_descrica := fn_getValue(vr_valu_node);
      IF vr_node_name = 'CodMsg' THEN
        -- Buscar valor da TAG
        vr_aux_CodMsg := vr_aux_descrica;
      ELSIF vr_node_name = 'DtMovto' THEN
        vr_aux_DtMovto := vr_aux_descrica;
      ELSIF vr_node_name = 'VlrLanc' THEN
        vr_aux_DsVlrLanc := gene0002.fn_char_para_number(vr_aux_descrica);
      ELSIF vr_node_name = 'NumCtrlPart' THEN
        -- Numero de Controle da Cooperativa
        vr_aux_NumCtrlIF := vr_aux_descrica;
        vr_nrcontrole_if := vr_aux_descrica;         
      END IF;
    END LOOP;
    --
    
EXCEPTION
WHEN OTHERS THEN
   pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_sln -->'||sqlerrm;
END pc_trata_arquivo_slb;


PROCEDURE pc_trata_arquivo_cir0060(pr_node      IN xmldom.DOMNode
                            ,pr_dscritic OUT VARCHAR2) IS

  -- SubItens da CIR0060
  vr_elem_node xmldom.DOMElement;
  vr_node_list xmldom.DOMNodeList;
  vr_node_name VARCHAR2(100);
  vr_item_node xmldom.DOMNode;
  vr_valu_node xmldom.DOMNode;

  -- SubItens de Grupo
  vr_elem_node_grpsit xmldom.DOMElement;
  vr_node_list_grpsit xmldom.DOMNodeList;
  vr_node_name_grpsit VARCHAR2(100);
  vr_item_node_grpsit xmldom.DOMNode;
  vr_valu_node_grpsit xmldom.DOMNode;

  -- VAriaveis genéricas
  vr_idx_numerario NUMBER;
  vr_aux_descrica  VARCHAR2(1000);

BEGIN 

  -- Buscar todos os filhos deste nó
  vr_elem_node := xmldom.makeElement(pr_node);
  -- Faz o get de toda a lista de filhos
  vr_node_list := xmldom.getChildrenByTagName(vr_elem_node,'*');
  -- Percorrer os elementos
  FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP
    -- Buscar o item atual
    vr_item_node := xmldom.item(vr_node_list, i);
    -- Captura o nome e tipo do nodo
    vr_node_name := xmldom.getNodeName(vr_item_node);
    -- Sair se o nodo não for elemento
    IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
      CONTINUE;
    END IF;

    IF vr_node_name = 'Grupo_CIR0060_Remessa' THEN
      -- Setar mensagem e indice pltable
      vr_aux_CodMsg := 'CIR0060';
      vr_idx_numerario := vr_tab_numerario_cir0060.count()+1;

      -- Busca filhos
      vr_elem_node_grpsit := xmldom.makeElement(vr_item_node);
      -- Faz o get de toda a lista de filhos
      vr_node_list_grpsit := xmldom.getChildrenByTagName(vr_elem_node_grpsit,'*');
      -- Percorrer os elementos
      FOR i IN 0..xmldom.getLength(vr_node_list_grpsit)-1 LOOP
        -- Buscar o item atual
        vr_item_node_grpsit := xmldom.item(vr_node_list_grpsit, i);
        -- Captura o nome e tipo do nodo
        vr_node_name_grpsit := xmldom.getNodeName(vr_item_node_grpsit);
        -- Sair se o nodo não for elemento
        IF xmldom.getNodeType(vr_item_node_grpsit) <> xmldom.ELEMENT_NODE THEN
          CONTINUE;
        END IF;
        -- Para o node Catg
        IF vr_node_name_grpsit = 'NumRemessa' THEN
          -- Buscar valor da TAG
          vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
          vr_tab_numerario_cir0060(vr_idx_numerario).NumRemessa := fn_getValue(vr_valu_node_grpsit);
        -- Para o node VlrDen
        ELSIF vr_node_name_grpsit = 'DtLimEntr' THEN
          -- Buscar valor da TAG
          vr_valu_node_grpsit := xmldom.getFirstChild(vr_item_node_grpsit);
          vr_tab_numerario_cir0060(vr_idx_numerario).DtLimEntr := fn_getValue(vr_valu_node_grpsit);
        END IF;
      END LOOP;
    ELSE
      -- Buscar primeiro filho do nó para buscar seu valor em lógica única
      vr_valu_node := xmldom.getFirstChild(vr_item_node);
      vr_aux_descrica := fn_getValue(vr_valu_node);
      -- Copiar para a respectiva variavel conforme nome da tag
      IF vr_node_name = 'CodMsg' THEN
        vr_aux_CodMsg := vr_aux_descrica;
      ELSIF vr_node_name = 'ISPBIF' THEN
        vr_aux_ISPBIF := vr_aux_descrica; -- Revisar variavel
      ELSIF vr_node_name = 'DtMovto' THEN
        vr_aux_DtMovto := vr_aux_descrica;
      END IF;
    END IF;
  END LOOP;
  
EXCEPTION
  WHEN OTHERS THEN
    pr_dscritic := 'Erro no tratamento do Node pc_trata_arquivo_cir0060 -->'||sqlerrm;
END pc_trata_arquivo_cir0060;




    BEGIN -- inicio pc_importa_xml
      -- Inicializar valor
      vr_aux_VlrLanc  := 0;
      vr_inmsg_GEN    := 'N';

      -- Efetuar leitura do arquivo limpo em CLOB e já instanciá-lo como XML
        -- Marcelo Telles Coelho - Projeto 475
        -- Utilizar o parametro XMLType
        vr_xmltype := pr_dsxmltype;
        vr_txtmensg:= xmltype.getClobVal(pr_dsxmltype);
        --
      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      vr_parser := xmlparser.newParser;
      xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
      vr_doc := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);

      -- Buscar nodo SISMSG
      vr_node_root := xmldom.getElementsByTagName(vr_doc,'SISMSG');
      vr_item_root := xmldom.item(vr_node_root, 0);
      vr_elem_root := xmldom.makeElement(vr_item_root);

      -- Faz o get de toda a lista SISMSG
      vr_node_list := xmldom.getChildrenByTagName(vr_elem_root,'*');

      -- Percorrer os elementos
      FOR i IN 0..xmldom.getLength(vr_node_list)-1 LOOP

        -- Buscar o item atual
        vr_item_node := xmldom.item(vr_node_list, i);
        -- Captura o nome e tipo do nodo
        vr_node_name := xmldom.getNodeName(vr_item_node);

        -- Sair se o nodo não for elemento
        IF xmldom.getNodeType(vr_item_node) <> xmldom.ELEMENT_NODE THEN
          CONTINUE;
        END IF;

        -- Tratar leitura dos dados do SEGCAB (Header)
        IF vr_node_name = 'SEGCAB' THEN

          -- Buscar todos os filhos deste nó
          vr_elem_node := xmldom.makeElement(vr_item_node);
          -- Faz o get de toda a lista de folhas da SEGCAB
          vr_node_list_segcab := xmldom.getChildrenByTagName(vr_elem_node,'*');

          -- Percorrer os elementos
          FOR i IN 0..xmldom.getLength(vr_node_list_segcab)-1 LOOP

            -- Buscar o item atual
            vr_item_node_segcab := xmldom.item(vr_node_list_segcab, i);
            -- Captura o nome e tipo do nodo
            vr_node_name_segcab := xmldom.getNodeName(vr_item_node_segcab);

            -- Sair se o nodo não for elemento
            IF xmldom.getNodeType(vr_item_node_segcab) <> xmldom.ELEMENT_NODE THEN
              CONTINUE;
            END IF;

            -- Para a tag NR_OPERACAO
            IF vr_node_name_segcab = 'NR_OPERACAO' THEN
              -- Buscar valor da TAG
              vr_valu_node_segcab := xmldom.getFirstChild(vr_item_node_segcab);
              vr_aux_NrOperacao   := fn_getValue(vr_valu_node_segcab);
            END IF;
            -- Para a tag CD_SITUACAO
            IF vr_node_name_segcab = 'CD_SITUACAO' THEN
              -- Buscar valor da TAG
              vr_valu_node_segcab := xmldom.getFirstChild(vr_item_node_segcab);
              vr_aux_CD_SITUACAO  := fn_getValue(vr_valu_node_segcab);
            END IF;
          END LOOP;
        ELSE
          -- Chamar rotinas específicas por Node
          IF vr_node_name IN('CABInfSituacao','CABInfCancelamento'
                            ,'CABInfConvertida' -- Marcelo Telles Coelho - Projeto 475
                            ) THEN
            -- Inconsistencia dados, Resposta da JD ou Rejeicao da cabine
            pc_trata_CabInf(pr_node_cabinf => vr_item_node
                           ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name IN('CodMsg' -- Para mensagens GENE004 e %E - Marcelo Telles Coelho - Mouts - Projeto 475
                               )
             OR vr_inmsg_GEN  = 'S'
             THEN
            -- Marcelo Telles Coelho - Projeto 475
            -- Tratar mensagens GEN% e %E
            vr_inmsg_GEN := 'S';
            -- Buscar valor da TAG
            vr_valu_node_segcab := xmldom.getFirstChild(vr_item_node);
            vr_node_valor       := xmldom.getNodeValue(vr_valu_node_segcab);
            --
            -- Inconsistencia dados, Resposta da JD ou Rejeicao da cabine
            pc_trata_GEN (pr_node_name  => vr_node_name
                         ,pr_node_valor => vr_node_valor
                         ,pr_dscritic   => vr_dscritic);
          ELSIF vr_node_name IN('PAG0101','STR0018','STR0019')  THEN
            -- Trata IFs
            pc_trata_IFs(pr_node        => vr_item_node
                        ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'STR0047R2' THEN
            -- Portabilidade de crédito
            pc_trata_portabilidade(pr_node        => vr_item_node
                                  ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'STR0003R2'THEN
            -- Recolhimento de Numerários
            pc_trata_numerario(pr_node        => vr_item_node
                              ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'CIR0020' THEN /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
            pc_trata_numerario_cir0020(pr_node        => vr_item_node
                                      ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'CIR0021' THEN /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
            pc_trata_numerario_cir0021(pr_node        => vr_item_node
                                      ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'SLC0001' THEN
            -- Inclusão tratamento mensagem SLC0001 - Mauricio - 03/11/2017
            pc_trata_arquivo_slc0001(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name = 'SLC0005' THEN
            -- Inclusão tratamento mensagem SLC0001 - Mauricio - 03/11/2017
            pc_trata_arquivo_slc0005(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name  IN ('LDL0024','LDL0022') THEN 
            -- Inclusão tratamento mensagem LDL0024 - Alexandre (Mouts) - 12/12/2017
            -- Inclusão tratamento mensagem LDL0022 - Sprint D - Req19
            pc_trata_arquivo_ldl(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name  IN ('RDC0002','RDC0007') THEN 
            -- Inclusão tratamento mensagem RDC0002/RDC0007 - Sprint D - Req19
            pc_trata_arquivo_rdc(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name  = 'SEL1069' THEN 
            -- Inclusão tratamento mensagem SEL1069 - Sprint D - Req19
            pc_trata_arquivo_sel(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name  = 'SLB0002' THEN 
            -- Inclusão tratamento mensagem SLB0002 - Sprint D - Req20
            pc_trata_arquivo_slb(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSIF vr_node_name  = 'CIR0060' THEN 
            -- Inclusão tratamento mensagem CIR0060 - Sprint D - Req51
            pc_trata_arquivo_cir0060(pr_node        => vr_item_node
                                ,pr_dscritic    => vr_dscritic);
          ELSE
            -- Trasnferencia de valores
            pc_trata_transfere(pr_node        => vr_item_node
                              ,pr_dscritic    => vr_dscritic);
          END IF;
          -- Se encontrou erro nas rotinas chamadas
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        END IF;
      END LOOP;

      -- Marcelo Telles Coelho - Projeto 475
      -- Guardar o XML para posteriormente salvar nas tabelas de trace do SPB
      vr_trace_dsxml_mensagem := vr_txtmensg;
      -- Marcelo Telles Coelho - Projeto 475
      -- Incluir o XML na tabela TBSPB_MSG_XML
      --
      vr_trace_nmmensagem_xml := NULL;
      --
      IF vr_aux_tagCABInfConvertida THEN
        vr_trace_nmmensagem_xml := 'CABInfConvertida';
      ELSIF vr_aux_CabInf_reenvio THEN
        vr_trace_nmmensagem_xml := 'CABInfSit Duplic.';
      ELSIF vr_aux_CabInf_erro THEN
        vr_trace_nmmensagem_xml := 'CABInfSit Rejeição';
      ELSIF vr_aux_tagCABInfCCL THEN
        IF vr_aux_CodMsg LIKE '%E' THEN
          vr_trace_nmmensagem_xml := vr_aux_CodMsg;
        ELSE
          vr_trace_nmmensagem_xml := 'CABInfCancelamento';
        END IF;
      ELSIF vr_aux_tagCABInf THEN
        vr_trace_nmmensagem_xml := 'CABInfSituacao';
      END IF;
      --
      IF vr_trace_nmmensagem_xml IS NULL THEN
        IF vr_aux_CodMsg IS NULL THEN
          vr_trace_nmmensagem_xml := 'Sem <CodMsg>';
        ELSE
          vr_trace_nmmensagem_xml := vr_aux_CodMsg;
        END IF;
      END IF;
      --
      sspb0003.pc_grava_xml(pr_nmmensagem         => vr_trace_nmmensagem_xml
                           ,pr_inorigem_mensagem  => SSPB0003.fn_retorna_inorigem (pr_nrcontrole_if => vr_nrcontrole_if)
                           ,pr_dhmensagem         => SYSDATE
                           ,pr_dsxml_mensagem     => SUBSTR(vr_trace_dsxml_mensagem,1,4000)
                           ,pr_dsxml_completo     => vr_trace_dsxml_mensagem
                           ,pr_inenvio            => 0 -- Mensagem não será enviada para o JD
                           ,pr_cdcooper           => NVL(rw_crapcop_mensag.cdcooper,rw_crapcop_central.cdcooper)
                           ,pr_nrdconta           => NULL
                           ,pr_cdproduto          => 30 -- TED
                           ,pr_nrseq_mensagem_xml => vr_nrseq_mensagem_xml
                           ,pr_dscritic           => vr_dscritic
                           ,pr_des_erro           => vr_des_erro
                           );
      -- se retornou critica, abortar programa
      IF nvl(vr_des_erro,'OK') <> 'OK' OR
        TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdcritic := 0;
        -- Acionar rotina de LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                  ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                  ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                    ||' - '|| vr_glb_cdprogra ||' --> '
                                                    ||'Erro execucao - '
                                                    || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                    || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                    || 'Na Rotina pc_importa_xml --> '||vr_dscritic
                                  ,pr_nmarqlog      => vr_logprogr
                                  ,pr_cdprograma    => vr_glb_cdprogra
                                  ,pr_dstiplog      => 'E'
                                  ,pr_tpexecucao    => 3
                                  ,pr_cdcriticidade => 0
                                  ,pr_flgsucesso    => 1
                                  ,pr_cdmensagem    => vr_cdcritic);
      END IF;
      -- Fim Projeto 475

      -- Somente se o processo já foi finalizado
      IF fn_verifica_processo THEN
        -- Verificar as mensagens que serao desprezadas na gravacao da nova estrutura
        IF ( vr_msgspb_nao_copiar IS NULL OR ','||vr_aux_CodMsg||',' LIKE ('%,'||vr_msgspb_nao_copiar||',%') ) THEN
          --
          IF vr_aux_NumCtrlRem IS NOT NULL THEN
            vr_aux_nro_controle := vr_aux_NumCtrlRem;
          ELSE
            vr_aux_nro_controle := vr_aux_NumCtrlIF;
          END IF;
          --
          IF vr_aux_tagCABInf THEN
            vr_aux_cdagectl_pesq := gene0002.fn_char_para_number(SUBSTR(vr_aux_NumCtrlIF,8,4));
          ELSE
            vr_aux_cdagectl_pesq := gene0002.fn_char_para_number(vr_aux_AgCredtd);
          END IF;

          -- Busca dados da Coope por cdagectl
          OPEN cr_busca_coop(pr_cdagectl => vr_aux_cdagectl_pesq);
          FETCH cr_busca_coop
           INTO rw_crapcop_mensag;
          CLOSE cr_busca_coop;

          -- Verificar se recebemos data na mensagem XML
          IF TRIM(vr_aux_DtMovto) IS NOT NULL AND gene0002.fn_data(vr_aux_DtMovto,'RRRR-MM-DD') THEN
              -- XML sera processado
              vr_aux_msgspb_xml    := vr_txtmensg;
              vr_aux_manter_fisico := FALSE;
            -- Gravar a mensagem descriptografada
            SSPB0003.pc_grava_mensagem_ted(pr_cdcooper    => NVL(rw_crapcop_mensag.cdcooper,rw_crapcop_central.cdcooper)
                                          ,pr_nrctrlif    => vr_aux_nro_controle
                                          ,pr_dtmensagem  => to_date(vr_aux_DtMovto,'RRRR-MM-DD')
                                          ,pr_nmevento    => vr_aux_CodMsg
                                          ,pr_dsxml       => vr_aux_msgspb_xml
                                          ,pr_cdprograma  => vr_glb_cdprogra
                                          ,pr_cdcritic    => vr_cdcritic
                                          ,pr_dscritic    => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Acionar rotina de LOG
              BTCH0001.pc_gera_log_batch(pr_cdcooper      => NVL(rw_crapcop_mensag.cdcooper,rw_crapcop_central.cdcooper)
                                        ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                        ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                          ||'Erro execucao - '
                                                          || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                          || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                          || ' --> '||vr_dscritic
                                        ,pr_nmarqlog      => vr_logprogr
                                        ,pr_cdprograma    => vr_glb_cdprogra
                                        ,pr_dstiplog      => 'E'
                                        ,pr_tpexecucao    => 3
                                        ,pr_cdcriticidade => 0
                                        ,pr_flgsucesso    => 1
                                        ,pr_cdmensagem    => vr_cdcritic);
            END IF;
          ELSE
            -- Montar mensagem de erro para enviar ao LOG
            vr_aux_manter_fisico := TRUE;
            vr_aux_msgspb_xml    := to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                 || 'Alerta da Execucao Paralela - '
                                 ||'Erro execucao - '
                                 || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                 || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                 || ' - Mensagem de TED nao possui data ou a data eh invalida. Verifique arquivo fisico: ' || vr_aux_nmarqxml;
            -- Acionar rotina de LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => NVL(rw_crapcop_mensag.cdcooper,rw_crapcop_central.cdcooper)
                                      ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                      ,pr_des_log       => vr_aux_msgspb_xml
                                      ,pr_nmarqlog      => vr_logprogr
                                      ,pr_cdprograma    => vr_glb_cdprogra
                                      ,pr_dstiplog      => 'E'
                                      ,pr_tpexecucao    => 3
                                      ,pr_cdcriticidade => 0
                                      ,pr_flgsucesso    => 1);
          END IF;
        END IF;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Remover os arquivos temporarios ignorando possiveis erros
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarquiv);
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarqutp);
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_input_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        END IF;
        IF utl_file.IS_OPEN(vr_output_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_output_file);
        END IF;
        -- Erro tratado
        pr_dscritic := 'Erro na rotina pc_importa_xml --> '||vr_dscritic;
      WHEN others THEN
        -- Remover os arquivos temporarios ignorando possiveis erros
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarquiv);
        gene0001.pc_OScommand_Shell(pr_des_comando => 'rm '||vr_nmdirarq||'/'||vr_nmarqutp);
        -- Fechar arquivos caso abertos
        IF utl_file.IS_OPEN(vr_input_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file);
        END IF;
        IF utl_file.IS_OPEN(vr_output_file) THEN
          gene0001.pc_fecha_arquivo(pr_utlfileh => vr_output_file);
        END IF;
        -- Erro nao tratado
        pr_dscritic := 'Erro nao tratado na rotina pc_importa_xml --> '||sqlerrm;
    END pc_importa_xml;


    -- Funcao true or false para tratar conversao para numero sem gerar exceção
    FUNCTION fn_numerico(pr_dsdtext IN VARCHAR2) RETURN BOOLEAN IS
      vr_nrdtext NUMBER;
    BEGIN
      vr_nrdtext := to_number(pr_dsdtext);
      IF vr_nrdtext IS NOT NULL THEN
        RETURN TRUE;
      END IF;
      RETURN TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END;

    -- Procedimento para tratar registro quando Cecred
    PROCEDURE pc_trata_cecred(pr_cdagectl IN VARCHAR2
                             ,pr_dscritic OUT VARCHAR2) IS
      vr_flgnumer BOOLEAN;
    BEGIN -- inicio pc_trata_cecred
      -- Se recebemos cdagectl
      IF pr_cdagectl IS NOT NULL THEN
        -- Verificar se eh numero
        vr_flgnumer := fn_numerico(pr_cdagectl);
        rw_crapcop_mensag := NULL;
        -- Busca dados da Coope por cdagectl somente se ele for um numero
        IF vr_flgnumer THEN
          OPEN cr_busca_coop(pr_cdagectl => pr_cdagectl
                         ,pr_flgativo => 1);
          FETCH cr_busca_coop
           INTO rw_crapcop_mensag;
          CLOSE cr_busca_coop;
        END IF;
        -- Se mensagem nao pertence a nenhuma Coop.
        IF rw_crapcop_mensag.cdcooper IS NULL THEN
          -- Buscar erro Agencia invalida
          vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'GENERI'
                                                       ,pr_cdempres => 0
                                                       ,pr_cdacesso => 'CDERROSSPB'
                                                       ,pr_tpregist => 2);
          -- Se encontrou
          IF vr_aux_dstextab IS NOT NULL THEN
            -- Copiar a var padrão de erro
            vr_log_msgderro := vr_aux_dstextab;
          END IF;
          -- Nao criar gnmvcen para CABInf
          IF NOT vr_aux_tagCABInf THEN
            -- Cria registro da mensagem Devolvida
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_central.cdagectl
                           ,pr_dtmvtolt => rw_crapdat_central.dtmvtolt
                           ,pr_dsmensag => vr_aux_CodMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;
          END IF;
          -- Para R2
          IF vr_aux_CodMsg LIKE '%R2' THEN
            IF vr_aux_CodMsg IN('STR0010R2','PAG0111R2') THEN
              -- Chamar rotina de log no SPB
              pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                             ,pr_msgderro  => 'DEVOLUCAO DE MENSAGEM ORIGINADA NA CABINE');
            ELSE
            -- Agencia invalida
            pc_gera_erro_xml(pr_dsdehist => 'Agencia de destino invalida.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            END IF;
          ELSE
            -- Chamar rotina de log no SPB
            pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                           ,pr_msgderro  => vr_log_msgderro);
          END IF;
        END IF;
      ELSE
        -- Para pagamento
        IF vr_aux_TpCtCredtd = 'PG' OR TRIM(vr_aux_CtPgtoCredtd) IS NOT NULL THEN
          -- Buscar erro Agencia invalida
          vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'GENERI'
                                                       ,pr_cdempres => 0
                                                       ,pr_cdacesso => 'CDERROSSPB'
                                                       ,pr_tpregist => 2);
          -- Se encontrou
          IF vr_aux_dstextab IS NOT NULL THEN
            -- Copiar a var padrão de erro
            vr_log_msgderro := vr_aux_dstextab;
          END IF;
          -- Nao criar gnmvcen para CABInf
          IF NOT vr_aux_tagCABInf THEN
            -- Cria registro da mensagem Devolvida
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_central.cdagectl
                           ,pr_dtmvtolt => rw_crapdat_central.dtmvtolt
                           ,pr_dsmensag => vr_aux_CodMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;
          END IF;
          -- Para R2
          IF vr_aux_CodMsg LIKE '%R2' THEN
            -- Agencia invalida
            pc_gera_erro_xml(pr_dsdehist => 'Tipo de conta incorreto.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;
        ELSE
          -- Mensagem imprevista
          vr_log_msgderro := 'Mensagem nao prevista';
          -- Chamar rotina de log no SPB
          pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                         ,pr_msgderro  => vr_log_msgderro);

        END IF;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro na rotina pc_trata_cecred -->'||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro na rotina pc_trata_cecred -->'||sqlerrm;
    END pc_trata_cecred;

    -- Buscar motivo devolução
    FUNCTION fn_motivo_devolucao RETURN varchar2 IS
    BEGIN
      -- Buscar descrição de erro conforme motivo
      vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'CDERROSSPB'
                                                   ,pr_tpregist => to_number(vr_aux_CodDevTransf));
      -- Se encontrou
      IF vr_aux_dstextab IS NOT NULL THEN
        -- Retornar
        RETURN to_number(vr_aux_CodDevTransf) || ' - ' || vr_aux_dstextab;
      ELSE
        RETURN to_number(vr_aux_CodDevTransf) || ' - Outros';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN vr_aux_CodDevTransf || ' - Outros ';
    END;

    -- Funcão para validar vencimento titulo
    -- Tratamento para permitir pagamento no primeiro dia util do
    -- ano de titulos vencidos no ultimo dia util do ano anterior
    FUNCTION fn_verifica_vencto_titulo (pr_cdcooper   IN NUMBER
                                       ,pr_dtvencto   IN DATE) RETURN BOOLEAN IS
    BEGIN
      DECLARE
        -- Variaveis Locais
        rw_crapdat btch0001.cr_crapdat%ROWTYPE;
        vr_dtdiautil DATE;
        vr_nranoant  VARCHAR2(4);
      BEGIN
        -- Buscar calendario
        OPEN btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        -- Pagamento no dia OU
        -- Se dia anterior for menor que vencimento
        IF pr_dtvencto > rw_crapdat.dtmvtocd OR rw_crapdat.dtmvtoan < pr_dtvencto THEN
          RETURN FALSE;
        END IF;

        -- Tratamento para permitir pagamento no primeiro dia util do
        -- ano de titulos vencidos no ultimo dia util do ano anterior
        vr_nranoant := to_char(rw_crapdat.dtmvtoan,'YYYY');
        -- Ano anterior diferente Ano Pagamento
        IF vr_nranoant != to_char(rw_crapdat.dtmvtocd,'YYYY') THEN
          -- Montar ultimo dia ano anterior
          vr_dtdiautil:= to_date('3112'||vr_nranoant,'DDMMYYYY');
          -- Se dia 31/12 for segunda-feira obtem data do sabado
          -- para aceitar vencidos do ultimo final de semana
          CASE to_number(to_char(vr_dtdiautil,'D'))
            WHEN 1 THEN vr_dtdiautil:= to_date('2912'||vr_nranoant,'DDMMYYYY');
            WHEN 2 THEN vr_dtdiautil:= to_date('2912'||vr_nranoant,'DDMMYYYY');
            WHEN 7 THEN vr_dtdiautil:= to_date('3012'||vr_nranoant,'DDMMYYYY');
            ELSE NULL;
          END CASE;
          -- Verifica se pode aceitar o titulo vencido
          IF pr_dtvencto >= vr_dtdiautil THEN
            -- Retorna FALSE
            RETURN FALSE;
          END IF;
        END IF;

        -- Se chegar neste ponto, validamos com sucesso
        RETURN true;

      EXCEPTION
        WHEN OTHERS THEN
          -- Sair do programa retornando false
          RETURN false;
      END;
    END fn_verifica_vencto_titulo;

    /* Procedimento para liquidacao de emprestimo novo */
    PROCEDURE pc_liq_contrato_emprest_nov(pr_cdcooper IN crapcop.cdcooper%type
                                         ,pr_nrdconta IN crapass.nrdconta%type
                                         ,pr_nrctremp IN crapepr.nrctremp%type
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                                         ,pr_dtmvtoan IN crapdat.dtmvtoan%type
                                         ,pr_cdagenci IN craplot.cdagenci%type
                                         ,pr_cdagelot IN craplot.cdagenci%type
                                         ,pr_dscritic OUT varchar2) IS
      --Tabelas de Memoria para Pagamentos das Parcelas Emprestimo
      vr_tab_pgto_parcel EMPR0001.typ_tab_pgto_parcel;
      vr_tab_calculado   EMPR0001.typ_tab_calculado;
      -- Tabela memória WPR
      vr_index_crawepr     VARCHAR2(30);
      -- Cursor de Emprestimos
      CURSOR cr_crawepr(pr_cdcooper IN crawepr.cdcooper%TYPE,
                        pr_nrdconta IN crawepr.nrdconta%TYPE,
                        pr_nrctremp IN crawepr.nrctremp%TYPE) IS
        SELECT wepr.tpemprst
              ,wepr.dtlibera
          FROM crawepr wepr
         WHERE wepr.cdcooper = pr_cdcooper
           AND wepr.nrdconta = pr_nrdconta
           AND wepr.nrctremp = pr_nrctremp;
      rw_crawepr  cr_crawepr%ROWTYPE;
      vr_tab_crawepr EMPR0001.typ_tab_crawepr;

    BEGIN
      -- Buscar pagamentos Parcela
      EMPR0001.pc_busca_pgto_parcelas(pr_cdcooper        => pr_cdcooper
                                     ,pr_cdagenci        => pr_cdagelot
                                     ,pr_nrdcaixa        => 0
                                     ,pr_cdoperad        => '1'
                                     ,pr_nmdatela        => vr_glb_cdprogra||'_1'
                                     ,pr_idorigem        => 1 -- Ayllos
                                     ,pr_nrdconta        => pr_nrdconta
                                     ,pr_idseqttl        => 1 -- Seq titula
                                     ,pr_dtmvtolt        => pr_dtmvtolt
                                     ,pr_flgerlog        => 'N'
                                     ,pr_nrctremp        => pr_nrctremp
                                     ,pr_dtmvtoan        => pr_dtmvtoan
                                     ,pr_nrparepr        => 0  /* Todas */
                                     ,pr_des_reto        => vr_des_reto -- Retorno OK / NOK
                                     ,pr_tab_erro        => vr_tab_erro -- Tabela com possíves erros
                                     ,pr_tab_pgto_parcel => vr_tab_pgto_parcel -- Tabela com registros de pagamentos
                                     ,pr_tab_calculado   => vr_tab_calculado); -- Tabela com totais calculados
      -- Se ocorreu erro
      IF vr_des_reto <> 'OK' THEN
        -- Se tem erro
        IF vr_tab_erro.count > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        END IF;
        -- Sair da rotina
        RAISE vr_exc_saida;
      END IF;

      -- Buscar dados da Proposta
      OPEN cr_crawepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr
       INTO rw_crawepr;
      CLOSE cr_crawepr;
      -- Montar Indice acesso
      vr_index_crawepr := lpad(pr_cdcooper, 10,'0') ||
                          lpad(pr_nrdconta, 10,'0') ||
                          lpad(pr_nrctremp, 10,'0');
      -- Popular tabela com informacoes encontradas
      vr_tab_crawepr(vr_index_crawepr).dtlibera := rw_crawepr.dtlibera;
      vr_tab_crawepr(vr_index_crawepr).tpemprst := rw_crawepr.tpemprst;

      -- Efetuar a Liquidacao do Emprestimo
      empr0001.pc_efetua_liquidacao_empr(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                        ,pr_cdagenci => pr_cdagelot         --> Código da agência
                                        ,pr_nrdcaixa => 0                   --> Número do caixa
                                        ,pr_cdoperad => '1'                 --> Código do Operador
                                        ,pr_nmdatela => vr_glb_cdprogra||'_1'   --> Nome da tela
                                        ,pr_idorigem => 1                   --> Id do módulo de sistema
                                        ,pr_cdpactra => 1                   --> P.A. da transação
                                        ,pr_nrdconta => pr_nrdconta         --> Número da conta
                                        ,pr_idseqttl => 1                   --> Seq titular
                                        ,pr_dtmvtolt => pr_dtmvtolt         --> Movimento atual
                                        ,pr_flgerlog => 'N'                 --> Indicador S/N para geração de log
                                        ,pr_nrctremp => pr_nrctremp         --> Número do contrato de empréstimo
                                        ,pr_dtmvtoan => pr_dtmvtoan         --> Data Movimento Anterior
                                        ,pr_ehprcbat => 'N'                 --> Indicador Processo Batch (S/N)
                                        ,pr_tab_pgto_parcel => vr_tab_pgto_parcel --Tabela com Pagamentos de Parcelas
                                        ,pr_tab_crawepr => vr_tab_crawepr   --> Tabela com Contas e Contratos
                                        ,pr_nrseqava => 0                   --> Pagamento: Sequencia do avalista
                                        ,pr_des_erro => vr_des_reto         --> Retorno OK / NOK
                                        ,pr_tab_erro => vr_tab_erro);       --> Tabela de Erros

      -- Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Se possui erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic := 'Erro na liquidacao';
        END IF;
        -- Sair da rotina
        RAISE vr_exc_saida;
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incrementar a critica as mensagens da liquidacao
        pr_dscritic := ' Liquidacao '
                    || '|' || pr_cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := ' Liquidacao '
                    || '|' || pr_cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || sqlerrm;
    END;

    /* Procedimento para liquidacao de emprestimo antigo */
    PROCEDURE pc_liq_contrato_emprest_ant(pr_cdcooper IN crapcop.cdcooper%type
                                         ,pr_nrdconta IN crapass.nrdconta%type
                                         ,pr_nrctremp IN crapepr.nrctremp%type
                                         ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%type
                                         ,pr_dscritic OUT varchar2) IS
      -- Cursor de Emprestimos
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%TYPE) IS
        SELECT epr.cdlcremp
              ,epr.cdagenci
              ,epr.txjuremp
              ,epr.vlpreemp
              ,epr.rowid
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr  cr_crapepr%ROWTYPE;

      -- Busca da linha de credito
      CURSOR cr_craplcr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_cdlcremp craplcr.cdlcremp%TYPE) IS
        SELECT cdlcremp
              ,txdiaria
              ,cdusolcr
          FROM craplcr
         WHERE cdcooper = pr_cdcooper
           AND cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Variaveis auxiliares
      vr_tab_inusatab BOOLEAN;
      vr_aux_txjuremp NUMBER;

    BEGIN
      -- Buscar empréstimo
      OPEN cr_crapepr(pr_cdcooper
                     ,pr_nrdconta
                     ,pr_nrctremp);
      FETCH cr_crapepr
       INTO rw_crapepr;
      IF cr_crapepr%FOUND THEN
        CLOSE cr_crapepr;
        -- Busca as tarifas
        vr_aux_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                    ,pr_nmsistem => 'CRED'
                                                    ,pr_tptabela => 'USUARI'
                                                    ,pr_cdempres => 11
                                                    ,pr_cdacesso => 'TAXATABELA'
                                                    ,pr_tpregist => 0  );
        -- Se nao encontrar
        IF vr_aux_dstextab IS NULL THEN
          vr_tab_inusatab := FALSE;
        ELSE
          IF SUBSTR(vr_aux_dstextab,1,1) = '0' THEN
            vr_tab_inusatab := FALSE;
          ELSE
            vr_tab_inusatab := TRUE;
          END IF;
        END IF;

        -- Buscar linha de credito
        OPEN cr_craplcr(pr_cdcooper,rw_crapepr.cdlcremp);
        FETCH cr_craplcr
         INTO rw_craplcr;
        CLOSE cr_craplcr;

        -- Nao debitar os emprestimos com emissao de boletos
        IF rw_craplcr.cdusolcr = 2 THEN
          vr_dscritic := '|Emprestimo com emissao de boleto - LCR: '|| rw_crapepr.cdlcremp;
          -- Sair da rotina
          RAISE vr_exc_saida;
        END IF;

        -- Se usa tabela
        IF vr_tab_inusatab THEN
          -- Checar se achou LCR antes pois ela é obrigatória
          IF rw_craplcr.cdlcremp IS NULL THEN
            -- Gerar erro
            vr_dscritic :=  gene0001.fn_busca_critica(363)|| ' - LCR: '|| rw_crapepr.cdlcremp;
            -- Sair da rotina
            RAISE vr_exc_saida;
          ELSE
            -- Usar tabela de juros da LCR
            vr_aux_txjuremp := rw_craplcr.txdiaria;
          END IF;
        ELSE
          -- Usar da epr
          vr_aux_txjuremp := rw_crapepr.txjuremp;
        END IF;

        --> Verificar se o cooperado pode realizar debito com o historico 108 - PREST.EMPREST
        IF lanc0001.fn_pode_debitar(pr_cdcooper => pr_cdcooper, 
                                    pr_nrdconta => pr_nrdconta, 
                                    pr_cdhistor => 108) THEN
          vr_dscritic := 'Debito hist. 108 nao permitido para o cooperado.';
          -- Sair da rotina
          RAISE vr_exc_saida;
                                 
        END IF;
        
        -- Atualizar capa do emprestimo
        BEGIN
          UPDATE crapepr
             SET crapepr.inliquid = 1
                ,crapepr.dtultpag = pr_dtmvtolt
                ,crapepr.txjuremp = vr_aux_txjuremp
           WHERE rowid = rw_crapepr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar CRAPEPR --> '||sqlerrm;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Verificar criação do lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => vr_glb_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8453);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;

          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig
               ,cdhistor
               ,cdoperad)
            VALUES
               (pr_dtmvtolt
               ,1
               ,100
               ,8453
               ,vr_glb_tplotmov
               ,pr_cdcooper
               ,0
               ,0
               ,'1')
             RETURNING dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrseqdig
                      ,cdcooper
                      ,tplotmov
                      ,vlinfodb
                      ,vlcompdb
                      ,qtinfoln
                      ,qtcompln
                      ,cdoperad
                      ,tpdmoeda
                      ,rowid
                  into rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.cdcooper
                      ,rw_craplot.tplotmov
                      ,rw_craplot.vlinfodb
                      ,rw_craplot.vlcompdb
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.cdoperad
                      ,rw_craplot.tpdmoeda
                      ,rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8453). '||SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;

        -- Insere pagamento parcela
        BEGIN
          INSERT INTO craplem
             (cdcooper
             ,dtmvtolt
             ,cdagenci
             ,cdbccxlt
             ,nrdolote
             ,nrdconta
             ,nrdocmto
             ,cdhistor
             ,nrseqdig
             ,nrctremp
             ,txjurepr
             ,vlpreemp
             ,vllanmto
             ,dtpagemp)
          VALUES
             (pr_cdcooper
             ,rw_craplot.dtmvtolt
             ,rw_craplot.cdagenci
             ,rw_craplot.cdbccxlt
             ,rw_craplot.nrdolote
             ,pr_nrdconta
             ,vr_aux_nrctremp
             ,095
             ,nvl(rw_craplot.nrseqdig,0) + 1
             ,pr_nrctremp
             ,vr_aux_txjuremp
             ,rw_crapepr.vlpreemp
             ,vr_aux_VlrLanc
             ,rw_craplot.dtmvtolt);
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao inserir na tabela craplem (095). '||SQLERRM;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Atualizar capa do Lote
        BEGIN
          UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_aux_VlrLanc
                            ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_aux_VlrLanc
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela craplot. '||SQLERRM;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Verificar criação do lote
        OPEN cr_craplot(pr_cdcooper => pr_cdcooper
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdagenci => vr_glb_cdagenci
                       ,pr_cdbccxlt => 100
                       ,pr_nrdolote => 8457);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;

          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig
               ,cdhistor
               ,cdoperad)
            VALUES
               (pr_dtmvtolt
               ,1
               ,100
               ,8457
               ,vr_glb_tplotmov
               ,pr_cdcooper
               ,0
               ,0
               ,'1')
             RETURNING dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrseqdig
                      ,cdcooper
                      ,tplotmov
                      ,vlinfodb
                      ,vlcompdb
                      ,qtinfoln
                      ,qtcompln
                      ,cdoperad
                      ,tpdmoeda
                      ,rowid
                  into rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.cdcooper
                      ,rw_craplot.tplotmov
                      ,rw_craplot.vlinfodb
                      ,rw_craplot.vlcompdb
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.cdoperad
                      ,rw_craplot.tpdmoeda
                      ,rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8453). '||SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;

        vr_tab_retorno := NULL;
        vr_incrineg := 0;
        
        -- Inserir Lancamento de debito na conta
        LANC0001.pc_gerar_lancamento_conta
                      ( pr_cdcooper => pr_cdcooper 
                       ,pr_dtmvtolt => rw_craplot.dtmvtolt
                       ,pr_cdagenci => rw_craplot.cdagenci
                       ,pr_cdbccxlt => rw_craplot.cdbccxlt
                       ,pr_nrdolote => rw_craplot.nrdolote
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_nrdctabb => pr_nrdconta
                       ,pr_nrdctitg => GENE0002.fn_mask(pr_nrdconta,'99999999')
                       ,pr_nrdocmto => pr_nrctremp
                       ,pr_cdhistor => 108
                       ,pr_nrseqdig => nvl(rw_craplot.nrseqdig,0) + 1
                       ,pr_cdpesqbb => null
                       ,pr_vllanmto => vr_aux_VlrLanc
                       --> OUT <--
                       ,pr_tab_retorno => vr_tab_retorno
                       ,pr_incrineg => vr_incrineg           -- Indicador de crítica de negócio
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
                       
        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --> Tratativas para critica de negocio
          IF vr_incrineg = 1 THEN
           -- Sair da rotina
           RAISE vr_exc_saida;
          --> Tratativas para criticas de sistema
          ELSE
            -- Sair da rotina
            RAISE vr_exc_saida;
          END IF; 

        END IF;                 

        -- Atualizar capa do Lote
        BEGIN
          UPDATE craplot SET craplot.vlinfodb = nvl(craplot.vlinfodb,0) + vr_aux_VlrLanc
                            ,craplot.vlcompdb = nvl(craplot.vlcompdb,0) + vr_aux_VlrLanc
                            ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                            ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                            ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
          WHERE craplot.ROWID = rw_craplot.ROWID;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
            -- Sair da rotina
            RAISE vr_exc_saida;
        END;

        -- Eliminar avisos de débito pendentes
        BEGIN
          DELETE FROM crapavs
                WHERE crapavs.cdcooper = pr_cdcooper
                  AND crapavs.nrdconta = pr_nrdconta
                  AND crapavs.cdhistor = 108
                  AND crapavs.insitavs = 0
                  AND crapavs.dtrefere >= pr_dtmvtolt;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao eliminar avisos de debito pendentes --> '||sqlerrm;
            -- Sair da rotina
             RAISE vr_exc_saida;
        END;

        -- Desativar o Rating associado a esta operaçao
        rati0001.pc_desativa_rating(pr_cdcooper   => pr_cdcooper         --> Código da Cooperativa
                                   ,pr_cdagenci   => 0                   --> Código da agência
                                   ,pr_nrdcaixa   => 0                   --> Número do caixa
                                   ,pr_cdoperad   => '1'                 --> Código do operador
                                   ,pr_rw_crapdat => pr_rw_crapdat       --> Vetor com dados de parâmetro (CRAPDAT)
                                   ,pr_nrdconta   => pr_nrdconta         --> Conta do associado
                                   ,pr_tpctrrat   => 90                  --> Tipo do Rating (90-Empréstimo)
                                   ,pr_nrctrrat   => pr_nrctremp         --> Número do contrato de Rating
                                   ,pr_flgefeti   => 'S'                 --> Flag para efetivação ou não do Rating
                                   ,pr_idseqttl   => 1                   --> Sequencia de titularidade da conta
                                   ,pr_idorigem   => 1                   --> Indicador da origem da chamada
                                   ,pr_inusatab   => vr_tab_inusatab     --> Indicador de utilização da tabela de juros
                                   ,pr_nmdatela   => vr_glb_cdprogra||'_1'   --> Nome datela conectada
                                   ,pr_flgerlog   => 'N'                 --> Gerar log S/N
                                   ,pr_des_reto   => vr_des_reto         --> Retorno OK / NOK
                                   ,pr_tab_erro   => vr_tab_erro);       --> Tabela com possíves erros
        -- Se retornou erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela
          IF vr_tab_erro.COUNT = 0 THEN
            vr_dscritic:= 'Erro na rati0001.pc_desativa_rating.';
          ELSE
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          END IF;
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

        -- Solicitar a Baixa do gravame
        GRVM0001.pc_solicita_baixa_automatica(pr_cdcooper => pr_cdcooper  -- Código da cooperativa
                                             ,pr_nrdconta => pr_nrdconta  -- Numero da conta do contrato
                                             ,pr_nrctrpro => pr_nrctremp  -- Numero do contrato
                                             ,pr_dtmvtolt => pr_dtmvtolt  -- Data de movimento para baixa
                                             ,pr_des_reto => vr_des_reto  -- Retorno OK ou NOK
                                             ,pr_tab_erro => vr_tab_erro  -- Retorno de erros em PlTable
                                             ,pr_cdcritic => vr_cdcritic  -- Retorno de codigo de critica
                                             ,pr_dscritic => vr_dscritic);-- Retorno de descricao de critica
        -- Se retornou erro
        IF vr_des_reto = 'NOK' THEN
          --Se tem erro na tabela
          IF vr_tab_erro.COUNT > 0 THEN
            vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
          END IF;
          -- Levantar Excecao
          RAISE vr_exc_saida;
        END IF;

      ELSE
        CLOSE cr_crapepr;
      END IF;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Incrementar a critica as mensagens da liquidacao
        pr_dscritic := ' Liquidacao '
                    || '|' || rw_crapepr.cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := ' Liquidacao '
                    || '|' || rw_crapepr.cdagenci
                    || '|' || pr_nrdconta
                    || '|' || pr_nrctremp
                    || '|' || vr_aux_NUPortdd
                    || ' --> ' || sqlerrm;
    END;

    /* Procedimento para processamento de conta transferida entre cooperativas */
    PROCEDURE pc_processa_conta_transferida(pr_cdcopant IN crapcop.cdcooper%type
                                           ,pr_nrctaant IN crapass.nrdconta%type
                                           ,pr_vlrlanct IN NUMBER
                                           ,pr_dscritic OUT varchar2) IS
      -- Buffers locais
      rw_b_crapcop cr_crapcop%rowtype;
      rw_b_crapdat btch0001.cr_crapdat%rowtype;
      rw_b_craplot cr_craplot%ROWTYPE;
      -- Variaveis
      vr_aux_hrtransa NUMBER := to_char(vr_glb_dataatual,'sssss');
      vr_aux_dtmvtolt DATE;
      vr_aux_strmigra VARCHAR2(400);
      vr_aux_nmarqimp VARCHAR2(400);
    BEGIN
      -- Buscar registro de transferencia
      rw_craptco := NULL;
      OPEN cr_craptco(pr_cdcopant => pr_cdcopant
                     ,pr_ntctaant => pr_nrctaant
                     ,pr_flgativo => 1
                     ,pr_tpctatrf => 1);
      FETCH cr_craptco
       INTO rw_craptco;
      -- Se não encontrou
      IF cr_craptco%NOTFOUND THEN
        CLOSE cr_craptco;
        -- No caso de TED destinada a uma IF incorporada,
        -- o parametro par_cdcopant contera o codigo da nova IF
        OPEN cr_craptco(pr_cdcooper => pr_cdcopant
                       ,pr_ntctaant => pr_nrctaant
                       ,pr_flgativo => 1
                       ,pr_tpctatrf => 1);
        FETCH cr_craptco
         INTO rw_craptco;
        CLOSE cr_craptco;
      ELSE
        CLOSE cr_craptco;
      END IF;

      -- Somente se encontrou registro TCO
      IF rw_craptco.nrdconta IS NOT NULL THEN
        -- Busca cooperativa onde a conta foi transferida
        -- Identifica cooperativa antiga
        OPEN cr_crapcop(pr_cdcooper => rw_craptco.cdcooper);
        FETCH cr_crapcop
         INTO rw_b_crapcop;
        -- Se não encontrar
        IF cr_crapcop%NOTFOUND THEN
          CLOSE cr_crapcop;
          -- Retornar erro
          vr_dscritic := 'Registro COP nao encontrado - '||rw_craptco.cdcooper;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcop;
        END IF;

        -- Busca data na cooperativa onde a conta foi transferida
        OPEN btch0001.cr_crapdat(pr_cdcooper => rw_craptco.cdcooper);
        FETCH btch0001.cr_crapdat
         INTO rw_b_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          CLOSE btch0001.cr_crapdat;
          -- Coop nao encontrar
          vr_dscritic := 'Data da cooperativa migrada nao encontrada - '||rw_craptco.cdcooper;
          RAISE vr_exc_saida;
        ELSE
          CLOSE btch0001.cr_crapdat;
        END IF;

        -- Conforme estado de crise
        IF vr_aux_flestcri = 0 THEN
          vr_aux_dtmvtolt := rw_b_crapdat.dtmvtolt;
        ELSE
          vr_aux_dtmvtolt := vr_aux_dtintegr;
        END IF;

        -- Verifica se processo ja finalizou na coop de destino
        IF trunc(vr_glb_dataatual) > vr_aux_dtmvtolt AND vr_aux_flestcri = 0 THEN
          vr_dscritic := 'Processo nao finalizado na Coop migrada - '||rw_craptco.cdcooper;
          RAISE vr_exc_saida;
        END IF;

        -- Verifica se a conta transferida existe
        OPEN cr_crapass(pr_cdcooper => rw_craptco.cdcooper
                       ,pr_nrdconta => rw_craptco.nrdconta);
        FETCH cr_crapass
         INTO rw_crapass;
        -- Se não encontrar
        IF cr_crapass%NOTFOUND THEN
          CLOSE cr_crapass;
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_b_crapcop.cdagectl
                         ,pr_dtmvtolt => vr_aux_dtmvtolt
                         ,pr_dsmensag => vr_aux_codMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => pr_vlrlanct
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          -- Gerar log
          pc_gera_log_SPB_transferida(pr_cdcooper => rw_b_crapcop.cdcooper
                                     ,pr_cdbcoctl => rw_b_crapcop.cdbcoctl
                                     ,pr_dtmvtolt => vr_aux_dtmvtolt
                                     ,pr_tipodlog => 'RECEBIDA'
                                     ,pr_msgderro => 'Registro(crapass) de conta transferida nao encontrado');


          -- Retornar com erro
          vr_dscritic := 'Registro(crapass) de conta transferida nao encontrado';
          raise vr_exc_saida;
        ELSE
          CLOSE cr_crapass;
        END IF;

      ELSE
        -- Retornar erro
        vr_dscritic := 'Registro TCO nao encontrado.';
        RAISE vr_exc_saida;
      END IF;

      -- Buscar / Criar Lote
      /* Projeto Revitalizacao - Remocao de lote */
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_b_crapcop.cdcooper
                                , pr_dtmvtolt => vr_aux_dtmvtolt
                                , pr_cdagenci => vr_glb_cdagenci
                                , pr_cdbccxlt => rw_b_crapcop.cdbcoctl
                                , pr_nrdolote => vr_glb_nrdolote
                                , pr_cdoperad => '1'
                                , pr_nrdcaixa => 0
                                , pr_tplotmov => 1
                                , pr_cdhistor => 0
                                , pr_craplot => rw_craplot_rvt
                                , pr_dscritic => vr_dscritic);

      if vr_dscritic is not null then
        RAISE vr_exc_saida;
      end if;

      -- Verificar se ja existe Lancamento
      vr_aux_existlcm := 0;
      vr_aux_vllanmto := NULL;
      OPEN cr_craplcm_exis(pr_cdcooper => rw_craplot_rvt.cdcooper
                          ,pr_dtmvtolt => rw_craplot_rvt.dtmvtolt
                          ,pr_cdagenci => rw_craplot_rvt.cdagenci
                          ,pr_cdbccxlt => rw_craplot_rvt.cdbccxlt
                          ,pr_nrdolote => rw_craplot_rvt.nrdolote
                          ,pr_nrdctabb => rw_craptco.nrdconta
                          ,pr_nrdocmto => vr_aux_nrdocmto);
      FETCH cr_craplcm_exis
       INTO vr_aux_existlcm,vr_aux_vllanmto;
      CLOSE cr_craplcm_exis;

      -- Se encontrar
      IF vr_aux_existlcm = 1 THEN
        vr_dscritic := 'Lancamento ja existe! Lote: ' ||rw_craplot_rvt.nrdolote||', Doc.: ' || vr_aux_nrdocmto;
      ELSE
        vr_nrseqdig := fn_sequence('CRAPLOT'
			                      ,'NRSEQDIG'
			                      ,''||rw_b_crapcop.cdcooper||';'
				                     ||to_char(vr_aux_dtmvtolt,'DD/MM/RRRR')||';'
				                     ||vr_glb_cdagenci||';'
				                     ||rw_b_crapcop.cdbcoctl||';'
				                     ||vr_glb_nrdolote);
        
        vr_tab_retorno := NULL;
        vr_incrineg := 0;
        
        -- Inserir Lancamento somente se não criticou acima
        LANC0001.pc_gerar_lancamento_conta
                      ( pr_cdcooper => rw_b_crapcop.cdcooper
                       ,pr_dtmvtolt => rw_craplot_rvt.dtmvtolt
                       ,pr_cdagenci => rw_craplot_rvt.cdagenci
                       ,pr_cdbccxlt => rw_craplot_rvt.cdbccxlt
                       ,pr_nrdolote => rw_craplot_rvt.nrdolote
                       ,pr_nrdconta => rw_craptco.nrdconta
                       ,pr_nrdctabb => rw_craptco.nrdconta
                       ,pr_nrdocmto => vr_aux_nrdocmto
                                       --> Credito TEC  TED 
                       ,pr_cdhistor => (CASE vr_aux_CodMsg 
                                           WHEN 'STR0037R2' THEN 799 --> CREDITO TEC
                                           WHEN 'PAG0137R2' THEN 799 --> CREDITO TEC
                                           ELSE 578 --> CREDITO TED
                                        END)
                       ,pr_nrseqdig => vr_nrseqdig
                       ,pr_cdpesqbb => vr_aux_dadosdeb
                       ,pr_vllanmto => pr_vlrlanct
                       ,pr_cdoperad => '1'
                       ,pr_hrtransa => vr_aux_hrtransa
                                              
                       --> OUT <--
                       ,pr_tab_retorno => vr_tab_retorno
                       ,pr_incrineg => vr_incrineg           -- Indicador de crítica de negócio
                       ,pr_cdcritic => vr_cdcritic
                       ,pr_dscritic => vr_dscritic);
                       
        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          --> sem tratativas de critica, criticas serão tratadas no if geral logo abaixo
          NULL;         
        END IF;
      END IF;

      -- Se deu erro na gravação
      IF vr_dscritic IS NOT NULL THEN
        -- Cria registro das movimentacoes no SPB
        pc_cria_gnmvcen(pr_cdagenci => rw_b_crapcop.cdagectl
                       ,pr_dtmvtolt => vr_aux_dtmvtolt
                       ,pr_dsmensag => vr_aux_codMsg
                       ,pr_dsdebcre => 'C'
                       ,pr_vllanmto => pr_vlrlanct
                       ,pr_dscritic => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          raise vr_exc_saida;
        END IF;
        -- Gerar log
        pc_gera_log_SPB_transferida(pr_cdcooper => rw_b_crapcop.cdcooper
                                   ,pr_cdbcoctl => rw_b_crapcop.cdbcoctl
                                   ,pr_dtmvtolt => vr_aux_dtmvtolt
                                   ,pr_tipodlog => 'RECEBIDA'
                                   ,pr_msgderro => vr_dscritic);

        -- Retornar sem erro
        RETURN;
      END IF;

      -- Cria registro das movimentacoes no SPB
      pc_cria_gnmvcen(pr_cdagenci => rw_b_crapcop.cdagectl
                     ,pr_dtmvtolt => vr_aux_dtmvtolt
                     ,pr_dsmensag => vr_aux_codMsg
                     ,pr_dsdebcre => 'C'
                     ,pr_vllanmto => pr_vlrlanct
                     ,pr_dscritic => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        raise vr_exc_saida;
      END IF;

      -- Gerar log
      pc_gera_log_SPB_transferida(pr_cdcooper => rw_b_crapcop.cdcooper
                                 ,pr_cdbcoctl => rw_b_crapcop.cdbcoctl
                                 ,pr_dtmvtolt => vr_aux_dtmvtolt
                                 ,pr_tipodlog => 'RECEBIDA'
                                 ,pr_msgderro => NULL);

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro na rotina pc_processa_conta_transferida --> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado em pc_processa_conta_transferida --> '||sqlerrm;
    END;


    -- Função centralizadora de tabela em usa
    FUNCTION fn_verifica_tab_em_uso(pr_sig_tabela VARCHAR2
                                   ,pr_rowid ROWID DEFAULT NULL
                                   ,pr_progress_recid NUMBER DEFAULT NULL) RETURN NUMBER IS

      -- Verificar tvl
      CURSOR cr_craptvl IS
        SELECT craptvl.rowid
          FROM craptvl
         WHERE craptvl.rowid = pr_rowid
         FOR UPDATE NOWAIT;
      rw_craptvl cr_craptvl%ROWTYPE;

      -- Verificar LCS
      CURSOR cr_craplcs IS
        SELECT craplcs.rowid
          FROM craplcs
         WHERE craplcs.rowid = pr_rowid
         FOR UPDATE NOWAIT;
      rw_craplcs cr_craplcs%ROWTYPE;

      -- Verificar LFP
      CURSOR cr_craplfp IS
        SELECT craplfp.rowid
          FROM craplfp
         WHERE craplfp.progress_recid = pr_progress_recid
         FOR UPDATE NOWAIT;
      rw_craplfp cr_craplfp%ROWTYPE;

    BEGIN
      /* Tratamento para buscar registro se o mesmo estiver em lock, tenta por 10 seg. */
      FOR i IN 1..100 LOOP
        BEGIN
          -- Leitura cfme tabela passada
          IF pr_sig_tabela = 'TVL' THEN
            OPEN cr_craptvl;
            FETCH cr_craptvl INTO rw_craptvl;
            CLOSE cr_craptvl;
          ELSIF pr_sig_tabela = 'LCS' THEN
            OPEN cr_craplcs;
            FETCH cr_craplcs INTO rw_craplcs;
            CLOSE cr_craplcs;
          ELSIF pr_sig_tabela = 'LFP' THEN
            OPEN cr_craplfp;
            FETCH cr_craplfp INTO rw_craplfp;
            CLOSE cr_craplfp;
          END IF;
          EXIT;
        EXCEPTION
          WHEN OTHERS THEN
            IF cr_craptvl%ISOPEN THEN
              CLOSE cr_craptvl;
            END IF;
            IF cr_craplcs%ISOPEN THEN
              CLOSE cr_craplcs;
            END IF;
            IF cr_craplfp%ISOPEN THEN
              CLOSE cr_craplfp;
            END IF;

            -- setar critica caso for o ultimo
            IF i = 100 THEN
              RETURN 1; --> em uso
            END IF;
            -- aguardar 0,5 seg. antes de tentar novamente
            sys.dbms_lock.sleep(0.1);
        END;
      END LOOP;

      RETURN 0; --> liberado
    END fn_verifica_tab_em_uso;

    /* Procedimento geral de tratamento do lançamento */
    PROCEDURE pc_trata_lancamentos(pr_dscritic OUT varchar2) IS

      -- Variaveis auxiliares
      vr_aux_cdhistor  NUMBER;
      vr_aux_cdpesqbb  VARCHAR2(200);
      vr_aux_dtmvtolt  DATE;
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_aux_flgopfin  NUMBER;
      vr_aux_flgenvio  NUMBER;
      vr_aux_dsdemail  VARCHAR2(4000);
      vr_tipolog       VARCHAR2(100);
      vr_aux_flgreccon BOOLEAN := FALSE;
      vr_aux_flgrecsal BOOLEAN := FALSE;
      vr_aux_sal_ant   NUMBER(25,2) := 0;
      vr_aux_nrseqdig   NUMBER;
      vr_idlancto      tbfin_recursos_movimento.idlancto%TYPE;

      --Bacenjud - SM 1
      vr_dsincons      tbgen_inconsist.dsinconsist%TYPE;

      /* Registro de TEC Salário */
      CURSOR cr_craplcs_lct(pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE
                           ,pr_cdhistor craplcs.cdhistor%TYPE
                           ,pr_nrdocmto craplcs.nrdocmto%TYPE ) IS
        SELECT lcs.vllanmto
          FROM craplcs lcs
         WHERE lcs.cdcooper = pr_cdcooper
           AND lcs.dtmvtolt = pr_dtmvtolt
           AND lcs.nrdconta = pr_nrdconta
           AND lcs.cdhistor = pr_cdhistor
           AND lcs.nrdocmto = pr_nrdocmto;
      rw_craplcs_lct cr_craplcs_lct%ROWTYPE;

      -- Buscar dados da conta em transferencia
      CURSOR cr_crapccs(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT cdagetrf
              ,nrctatrf
          FROM crapccs
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crapccs cr_crapccs%ROWTYPE;

      -- Busca o registro de portabilidade aprovada na coop. filiada
      CURSOR cr_portab(pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_nrportab tbepr_portabilidade.nrunico_portabilidade%TYPE) IS
        SELECT nrdconta
              ,nrctremp
              ,dtaprov_portabilidade
          FROM tbepr_portabilidade
         WHERE cdcooper              = pr_cdcooper
           AND nrunico_portabilidade = pr_nrportab;
      rw_portab cr_portab%ROWTYPE;

      -- Buscar informações do contrato a liquidar e do associado do contrato
      CURSOR cr_crapepr(pr_cdcooper crapcop.cdcooper%TYPE
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crawepr.nrctremp%TYPE) IS
        SELECT epr.tpemprst
              ,epr.nrdconta
              ,epr.nrctremp
              ,ass.cdagenci
              ,ass.nmprimtl
              ,epr.inliquid
          FROM crapepr epr
              ,crapass ass
         WHERE epr.cdcooper = ass.cdcooper
           AND epr.nrdconta = ass.nrdconta
           AND epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Buscar informações das contas administradoras de recursos
      CURSOR cr_tbfin_rec_con(pr_cdcooper tbfin_recursos_conta.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_conta.nrdconta%TYPE
                             ,pr_cdagenci tbfin_recursos_conta.cdagenci%TYPE
                            ) IS
        SELECT rc.cdcooper
              ,rc.nrdconta
              ,rc.cdagenci
              ,rc.flgativo
              ,rc.tpconta
              ,rc.nmtitular
          FROM tbfin_recursos_conta rc
         WHERE rc.cdcooper = pr_cdcooper
           AND rc.nrdconta = pr_nrdconta
           AND rc.cdagenci = pr_cdagenci
           AND rc.flgativo = 1;
      rw_tbfin_rec_con cr_tbfin_rec_con%ROWTYPE;

      /*-- Buscar registro de saldo do dia atual das contas administradoras de recursos
      CURSOR cr_tbfin_rec_sal(pr_cdcooper tbfin_recursos_saldo.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_saldo.nrdconta%TYPE
                             ,pr_dtmvtolt tbfin_recursos_saldo.dtmvtolt%TYPE) IS
        SELECT rs.dtmvtolt
              ,rs.vlsaldo_inicial
              ,rs.vlsaldo_final
          FROM tbfin_recursos_saldo rs
         WHERE rs.cdcooper = pr_cdcooper
           AND rs.nrdconta = pr_nrdconta
           AND dtmvtolt = pr_dtmvtolt;
      rw_tbfin_rec_sal cr_tbfin_rec_sal%ROWTYPE;


       -- Buscar registro saldo do dia anterior das contas administradoras de recursos
      CURSOR cr_tbfin_rec_sal_ant(pr_cdcooper tbfin_recursos_saldo.cdcooper%TYPE
                             ,pr_nrdconta tbfin_recursos_saldo.nrdconta%TYPE
                             ,pr_dtmvtolt tbfin_recursos_saldo.dtmvtolt%TYPE) IS
        SELECT rs.vlsaldo_final
          FROM tbfin_recursos_saldo rs
         WHERE rs.cdcooper = pr_cdcooper
           AND rs.nrdconta = pr_nrdconta
           AND dtmvtolt = (pr_dtmvtolt - 1);
      rw_tbfin_rec_sal_ant cr_tbfin_rec_sal_ant%ROWTYPE;*/

      --
      CURSOR cr_craphis(pr_cdcooper craphis.cdcooper%TYPE
                       ,pr_cdhistor craphis.cdhistor%TYPE
                       ) IS
        SELECT craphis.indebcre
          FROM craphis
         WHERE craphis.cdcooper = pr_cdcooper
           AND craphis.cdhistor = pr_cdhistor; 
      --
      rw_craphis cr_craphis%ROWTYPE;
      --

      --Bacenjud - SM 1
      --Buscar maior sequencia inserida na tbblqj_erro_ted para comparar com o parametro de reenvios
      CURSOR cr_tbblqj_erro_ted(pr_cdtransf_bacenjud IN tbblqj_erro_ted.cdtransf_bacenjud%TYPE
                               ,pr_cdcooper          IN tbblqj_erro_ted.cdcooper%TYPE
                               ,pr_nrdconta          IN tbblqj_erro_ted.nrdconta%TYPE) IS
        SELECT nvl(MAX(t.nrsequencia),0)
          FROM tbblqj_erro_ted t
         WHERE t.cdtransf_bacenjud = pr_cdtransf_bacenjud
           AND t.cdcooper          = pr_cdcooper
           AND t.nrdconta          = pr_nrdconta;

      vr_nrsequencia tbblqj_erro_ted.nrsequencia%TYPE;
      
      -- Projeto 475 Sprint C
      -- Validar o nome da mensagem enviada e buscar o XML para buscar outras informacoes para geração de email
      CURSOR cr_tbspbmsgenv (pr_nrcontrole_if IN tbspb_msg_enviada.nrcontrole_if%type) IS
      SELECT tmx.dsxml_completo
            ,tmx.dsxml_mensagem
      FROM tbspb_msg_enviada tme
          ,tbspb_msg_enviada_fase tmef
          ,tbspb_msg_xml tmx
      WHERE tme.nrcontrole_if = pr_nrcontrole_if
      and   tme.nmmensagem in ('STR0005','PAG0107')    
      and   tme.nrseq_mensagem = tmef.nrseq_mensagem
      and   tmef.cdfase in (10,15)
      and   tmef.nrseq_mensagem_xml = tmx.nrseq_mensagem_xml;       
      rw_tbspbmsgenv cr_tbspbmsgenv%ROWTYPE;
      
      -- Projeto 475 Sprint D
      Cursor cr_crapcopctl (pr_cdageclt in number) is
      Select cop.nrctactl, cop.cdcooper
      From Crapcop cop
      Where cop.cdagectl =  pr_cdageclt
      and   cop.flgativo = 1;          
      rw_crapcopctl cr_crapcopctl%rowtype;
      vr_nrdcontacir  crapcop.nrctactl%type;
      
      
    BEGIN -- inicio pc_trata_lancamentos
      -- Para estado de crise
      IF vr_aux_flestcri = 0 THEN
        -- Marcelo Telles Coelho - Projeto 475
        -- Se TRUNC(SYSDATE) > DTMVTOLT ==> Utilizar DTMVTOCD senão Utilizar DTMVTOLT
        -- Definido na FN_VERIFICA_PROCESSO
        -- vr_aux_dtmvtolt := rw_crapdat_mensag.dtmvtolt;
        vr_aux_dtmvtolt := vr_dtmovimento;
      ELSE
        vr_aux_dtmvtolt := vr_aux_dtintegr;
      END IF;

      -- Buscar / Criar Lote
      /* Projeto Revitalizacao - Remocao de lote */
      lote0001.pc_insere_lote_rvt(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                , pr_dtmvtolt => vr_aux_dtmvtolt
                                , pr_cdagenci => vr_glb_cdagenci
                                , pr_cdbccxlt => rw_crapcop_mensag.cdbcoctl
                                , pr_nrdolote => vr_glb_nrdolote
                                , pr_cdoperad => '1'
                                , pr_nrdcaixa => 0
                                , pr_tplotmov => 1
                                , pr_cdhistor => 0
                                , pr_craplot => rw_craplot_rvt
                                , pr_dscritic => vr_dscritic);

      if vr_dscritic is not null then
        RAISE vr_exc_saida;
      end if;

      -- Como no campo CodMsg do XML de rejeicao vem o codigo da
      -- mensagem gerada pela cooperativa, sera gravado
      -- gnmvcen.dsmensag = MSGREJ quando a rejeicao ocorrer com
      -- sucesso, e ERROREJ quando nao ocorrer por alguma critica.
      -- Esta informacao sera utilizada para contabilizacao das
      -- mensagens rejeitadas no relatorio crrl536. No LOG ira constar
      -- o codigo da mensagem original.

      /* Rejeitada pela cabine */
      IF vr_aux_tagCABInf THEN
        -- Gera devolucao com mesmo numero de documento da mensagem gerada pelo Legado
        vr_aux_nrdocmto := TO_NUMBER(SUBSTR(vr_aux_NumCtrlIF,LENGTH(vr_aux_NumCtrlIF) - 8,8));
        vr_aux_msgrejei := vr_aux_CodMsg;
        -- Somente para as mensagems abaixo
        IF vr_aux_CodMsg IN('STR0010','PAG0111','STR0048') THEN
          -- Chamar rotina de log no SPB
          pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                         ,pr_msgderro  => 'Rejeitada pela cabine');
          -- Setar mensagem
          vr_aux_CodMsg := 'MSGREJ';
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_CodMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          
          -- Retornar pois o processo finalizou
          RETURN;
        END IF;
        
      ELSIF vr_aux_CodMsg IN('STR0010R2','PAG0111R2') THEN
        -- Gera devolucao com mesmo numero de documento da mensagem gerada pelo Legado
        vr_aux_nrdocmto := TO_NUMBER(SUBSTR(vr_aux_NumCtrlIF,LENGTH(vr_aux_NumCtrlIF) - 8,8));
      ELSIF LENGTH(vr_aux_NumCtrlRem) >= 7 THEN
        -- Gera devolucao com mesmo numero de documento da mensagem gerada pelo Legado
        vr_aux_nrdocmto := TO_NUMBER(SUBSTR(vr_aux_NumCtrlRem,LENGTH(vr_aux_NumCtrlRem) - 7));
      END IF;

      -- Tratamentos conforme cada tipo de mensagem

      /* Estorno TEC */
      IF (vr_aux_CodMsg in('STR0010R2','PAG0111R2') OR vr_aux_tagCABInf) AND SUBSTR(vr_aux_NumCtrlIF,1,1) = '2' THEN

        -- Definir flopfin conforme tenha chego ou não na IF
        IF vr_aux_tagCABInf THEN
          vr_aux_flgopfin := 1; /* Registro Devolução chegou a IF*/
        ELSE
          vr_aux_flgopfin := 0; /* Registro Devolução que não chegou a IF*/
        END IF;


        -- Buscar registro transferência
        OPEN cr_craplcs(pr_cdcooper => rw_crapcop_mensag.cdcooper
                       ,pr_idopetrf => vr_aux_NumCtrlIF);
        FETCH cr_craplcs
         INTO rw_craplcs;
        -- Se encontrar
        IF cr_craplcs%NOTFOUND THEN
          CLOSE cr_craplcs;
          -- Gerar critica
          vr_dscritic := 'Numero de Controle invalido';
        ELSE
          CLOSE cr_craplcs;

          -- Verificar se tabela esta lockada
          IF fn_verifica_tab_em_uso(pr_sig_tabela => 'LCS'
                                   ,pr_rowid => rw_craplcs.rowid ) = 1 THEN
            vr_dscritic := 'Registro de Transferencia Conta Salario '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
            -- apensa jogar critica em log
            RAISE vr_exc_lock;
          END IF;

          -- Atualizar flopfin do registro da TEC
          BEGIN
            UPDATE craplcs
               SET flgopfin = vr_aux_flgopfin
             WHERE ROWID = rw_craplcs.rowid
             RETURNING nrridlfp
                      ,vllanmto
                      ,nrdconta
                  INTO vr_aux_nrridflp
                      ,vr_aux_VlrLanc
                      ,vr_aux_nrctacre;
            -- Se nao atualizou nenhum registro
            IF SQL%ROWCOUNT = 0 THEN
              -- Gerar critica
              vr_dscritic := 'Numero de Controle invalido';
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao atualizar registro craplcs --> '||sqlerrm;
          END;
        END IF;
        -- Se não deu erro
        IF vr_dscritic IS NULL THEN
          -- Se retornou Recid Folha IB
          IF vr_aux_nrridflp <> 0 THEN
            -- Se ficou na cabine
            IF vr_aux_tagCABInf THEN
              vr_aux_flgopfin := 0;
            ELSE
              vr_aux_flgopfin := 1;
            END IF;
            -- Histórico vem de PRM
            vr_aux_cdhistor := gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'FOLHAIB_HIST_REC_TECSAL');
            -- Flgenvio é sempre false
            vr_aux_flgenvio := 0;
          ELSE
            -- Folha Antigo, tem histórico fixo conforme  estar no SPB ou não
            IF vr_aux_tagCABInf THEN
              vr_aux_cdhistor := 887;
            ELSE
              vr_aux_cdhistor := 801;
            END IF;
            -- OPFIn e flgenvio é sempre true
            vr_aux_flgopfin := 1;
            vr_aux_flgenvio := 1;
          END IF;
          -- Verificar se ja existe Lancamento
          rw_craplcs := NULL;
          OPEN cr_craplcs_lct(pr_cdcooper => rw_crapcop_mensag.cdcooper
                             ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                             ,pr_nrdconta => vr_aux_nrctacre
                             ,pr_cdhistor => vr_aux_cdhistor
                             ,pr_nrdocmto => vr_aux_nrdocmto);
          FETCH cr_craplcs_lct
           INTO rw_craplcs_lct;
          CLOSE cr_craplcs_lct;
          -- Se já existia LCS
          IF rw_craplcs_lct.vllanmto IS NOT NULL THEN
            -- Gerar critica
            vr_dscritic := 'Lancamento ja existe! Conta: '
                        || vr_aux_nrctacre || ', Valor: '
                        || to_char(rw_craplcs_lct.vllanmto,'999g999g990d00')
                        || ', Lote: ' || vr_glb_nrdolote
                        || ', Doc.: ' || vr_aux_nrdocmto;
          ELSE
            BEGIN
              -- Criar LCS
              INSERT INTO craplcs
                 (cdcooper
                 ,dtmvtolt
                 ,nrdconta
                 ,cdhistor
                 ,nrdocmto
                 ,vllanmto
                 ,nrdolote
                 ,cdbccxlt
                 ,cdagenci
                 ,flgenvio
                 ,flgopfin
                 ,cdopetrf
                 ,cdopecrd
                 ,cdsitlcs
                 ,dttransf
                 ,hrtransf
                 ,idopetrf
                 ,nmarqenv
                 ,nrautdoc
                 ,nrridlfp)
              VALUES
                 (rw_crapcop_mensag.cdcooper
                 ,vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                 ,vr_aux_nrctacre
                 ,vr_aux_cdhistor
                 ,vr_aux_nrdocmto
                 ,vr_aux_VlrLanc
                 ,rw_craplot_rvt.nrdolote
                 ,rw_craplot_rvt.cdbccxlt
                 ,rw_craplot_rvt.cdagenci
                 ,vr_aux_flgenvio
                 ,vr_aux_flgopfin
                 ,'1'
                 ,'1'
                 ,1
                 ,vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                 ,to_char(vr_glb_dataatual,'sssss')
                 ,vr_aux_NumCtrlIF
                 ,NULL
                 ,0
                 ,vr_aux_nrridflp);
              -- Atualizar capa do Lote
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao criar lancamento de devolucao ou na atualizacao do Lote: '||sqlerrm;
            END;
            -- Se não houve erro na gravação acima, nova FOLHAIB e foi Rejeitada pela cabine
            IF vr_dscritic IS NULL AND nvl(vr_aux_nrridflp,0) <> 0 AND vr_aux_tagCABInf THEN
              
              -- Buscar dados da conta em transferencia
              OPEN cr_crapccs(rw_crapcop_mensag.cdcooper,vr_aux_nrctacre);
              FETCH cr_crapccs INTO rw_crapccs;
              CLOSE cr_crapccs;
              -- Montar email
              vr_aux_dsdemail := 'Ola, houve rejeicao na cabine da seguinte operacao TEC Salario: <br><br>'
                              || ' Conta/Dv: ' || vr_aux_nrctacre || ' <br>'
                              || ' PA: ' || rw_craplot_rvt.cdagenci || ' <br>'
                              || ' Dt.Credito: ' || vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                              || ' <br>'
                              || ' Dt.Transferencia: ' || vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                              || ' <br>'
                              || ' Valor: ' || to_char(vr_aux_VlrLanc,'fm999g999g999g990d00')  || ' <br>'
                              || ' Age: ' || rw_crapccs.cdagetrf    || ' <br>'
                              || ' Conta TRF: ' || rw_crapccs.nrctatrf || '. <br><br>'
                              || ' Lembramos que voce tera o dia de hoje e o proximo dia util para reprocessa-la na tela TRFSAL opcao X. '
                              || ' Do contrario este lancamento sera devolvido automaticamente para a Empresa. '
                              || ' Voce tambem podera utilizar a opcao E para efetuar o Estorno antecipado, caso nao deseje esperar ate o final do proximo dia util para o devido estorno. <br><br> '
                              || ' Atenciosamente, <br> '
                              || ' Sistemas Cecred.';

              -- Enviar Email para o Financeiro
              gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                        ,pr_cdprogra        => vr_glb_cdprogra
                                        ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'FOLHAIB_EMAIL_ALERT_FIN')
                                        ,pr_des_assunto     => 'Folha de Pagamento - Rejeicao TEC na Cabine'
                                        ,pr_des_corpo       => vr_aux_dsdemail
                                        ,pr_des_anexo       => ''
                                        ,pr_flg_enviar      => 'S'
                                        ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                        ,pr_des_erro        => vr_dscritic);
              -- Se ocorreu erro
              IF trim(vr_dscritic) IS NOT NULL THEN
                -- Marcelo Telles Coelho - Projeto 475
                -- Padronizar os logs no mesmo arquivo
                -- Gerar LOG e continuar o processo normal
                BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                          ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                          ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                            ||'Erro execucao - '
                                                            || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                            || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                            || ' --> '||vr_dscritic
                                         ,pr_nmarqlog      => vr_nmarqlog);
                -- Limpar critica
                vr_dscritic := null;
              END IF;
            END IF;
          END IF;
        END IF;

        -- Se houve critica
        IF vr_dscritic IS NOT NULL THEN
          -- Se nao veio da Cabine
          IF vr_aux_tagCABInf THEN
            -- Gera LOG SPB
            pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                           ,pr_msgderro  => vr_dscritic);
            -- Sobescreve o codMsg
            vr_aux_CodMsg := 'ERROREJ';
          ELSE
            -- Gera LOG SPB
            pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                           ,pr_msgderro  => vr_dscritic);
          END IF;

          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_CodMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          
          -- Processo finalizado
          RETURN;
        ELSE
          -- Se estava na SPB
          IF vr_aux_tagCABInf  THEN
            vr_aux_CodMsg := 'MSGREJ';
          END IF;
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_CodMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
        END IF;
      ELSE /* Eh ESTORNO de TED ou CREDITO de TED/TEC */
        -- Verifica se dados do pagamento da portabilidade conferem.
        -- Caso contrario gera devolucao(STR0048)
        IF vr_aux_CodMsg = 'STR0047R2' THEN
          -- Identifica a IF Credora Original(Coop. Filiada)
          OPEN cr_busca_coop_conta(pr_nrctactl => vr_aux_CtCredtd); -- C/C filiada na Central
          FETCH cr_busca_coop_conta
           INTO rw_crapcop_portab;
          -- Se não encontrar
          IF cr_busca_coop_conta%NOTFOUND THEN
            CLOSE cr_busca_coop_conta;
            -- Coop nao encontrar
            vr_dscritic := 'Erro de sistema: Registro da cooperativa nao encontrado.';
          ELSE
            CLOSE cr_busca_coop_conta;
            -- Busca data na cooperativa onde a conta foi transferida
            OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop_portab.cdcooper);
            FETCH btch0001.cr_crapdat
             INTO rw_crapdat_portab;
            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
              CLOSE btch0001.cr_crapdat;
              -- Data nao encontrar
              vr_dscritic := 'Erro de sistema: Registro de data nao encontrado.';
            ELSE
              CLOSE btch0001.cr_crapdat;
            END IF;
          END IF;
          -- Se houve erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar LOG
            pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                           ,pr_msgderro  => vr_dscritic);
            
            -- Retornar a execução
            RETURN;
          END IF;

          -- Busca o registro de portabilidade aprovada na coop. filiada
          OPEN cr_portab(pr_cdcooper => rw_crapcop_portab.cdcooper
                        ,pr_nrportab => vr_aux_NUPortdd);
          FETCH cr_portab
           INTO rw_portab;
          -- Se não encontrar
          IF cr_portab%NOTFOUND THEN
            CLOSE cr_portab;
            -- Gerar devolucao STR0048
            pc_gera_erro_xml(pr_dsdehist => 'Portabilidade não localizada.'
                            ,pr_codierro => 78
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
            
            -- Retornar a execução
            RETURN;

          ELSE
            CLOSE cr_portab;
            -- Identifica o contrato a ser liquidado e o associado do contrato
            OPEN cr_crapepr(rw_crapcop_portab.cdcooper
                           ,rw_portab.nrdconta
                           ,rw_portab.nrctremp);
            FETCH cr_crapepr
             INTO rw_craPepr;
            CLOSE cr_crapepr;
            -- Armazenar informações
            vr_aux_nrctremp := rw_crapepr.nrctremp;
            vr_aux_tpemprst := rw_crapepr.tpemprst; /*PP ou TR*/

            -- Buscar informações do contrato
            empr0001.pc_obtem_dados_empresti (pr_cdcooper       => rw_crapcop_portab.cdcooper --> Cooperativa conectada
                                             ,pr_cdagenci       => 0                     --> Código da agência
                                             ,pr_nrdcaixa       => 0                     --> Número do caixa
                                             ,pr_cdoperad       => '1'                   --> Código do operador
                                             ,pr_nmdatela       => vr_glb_cdprogra||'_1'     --> Nome datela conectada
                                             ,pr_idorigem       => 1                     --> Indicador da origem da chamada
                                             ,pr_nrdconta       => rw_crapepr.nrdconta   --> Conta do associado
                                             ,pr_idseqttl       => 1                     --> Sequencia de titularidade da conta
                                             ,pr_rw_crapdat     => rw_crapdat_portab          --> Vetor com dados de parâmetro (CRAPDAT)
                                             ,pr_dtcalcul       => vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt --> Data solicitada do calculo
                                             ,pr_nrctremp       => rw_crapepr.nrctremp   --> Número contrato empréstimo
                                             ,pr_cdprogra       => vr_glb_cdprogra||'_1'     --> Programa conectado
                                             ,pr_inusatab       => TRUE                  --> Indicador de utilização da tabela
                                             ,pr_flgerlog       => 'N'                   --> Gerar log S/N
                                             ,pr_flgcondc       => TRUE                  --> Mostrar emprestimos liquidados sem prejuizo
                                             ,pr_nmprimtl       => rw_crapepr.nmprimtl   --> Nome Primeiro Titular
                                             ,pr_tab_parempctl  => --> Dados tabela parametro
                                                                   tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                                                             ,pr_nmsistem => 'CRED'
                                                                                             ,pr_tptabela => 'USUARI'
                                                                                             ,pr_cdempres => 11
                                                                                             ,pr_cdacesso => 'PAREMPCTL'
                                                                                             ,pr_tpregist => 01)
                                             ,pr_tab_digitaliza => --> Dados tabela parametro
                                                                   tabe0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop_portab.cdcooper
                                                                                             ,pr_nmsistem => 'CRED'
                                                                                             ,pr_tptabela => 'GENERI'
                                                                                             ,pr_cdempres => 00
                                                                                             ,pr_cdacesso => 'DIGITALIZA'
                                                                                             ,pr_tpregist => 5)
                                             ,pr_nriniseq       => 0                     --> Numero inicial da paginacao
                                             ,pr_nrregist       => 0                     --> Numero de registros por pagina
                                             ,pr_qtregist       => vr_aux_qtregist       --> Qtde total de registros
                                             ,pr_tab_dados_epr  => vr_tab_dados_epr      --> Saida com os dados do empréstimo
                                             ,pr_des_reto       => vr_des_reto           --> Retorno OK / NOK
                                             ,pr_tab_erro       => vr_tab_erro);         --> Tabela com possíves erros
            -- Testar saida
            IF vr_des_reto = 'NOK' THEN
              IF vr_tab_erro.exists(vr_tab_erro.first) THEN
                vr_dscritic := 'Erro de Sistema - Conta: '||rw_portab.nrdconta||' --> '||
                                -- concatenado a critica na versao oracle para tbm saber a causa de abortar o programa
                                vr_tab_erro(vr_tab_erro.first).dscritic;
              ELSE
                vr_dscritic := 'Erro de Sistema - Conta: '||rw_portab.nrdconta||' nao possui emprestimo.';
              END IF;
              -- Gerar LOG
              pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                             ,pr_msgderro  => vr_dscritic);
              
              -- Retornar a execução
              RETURN;

            END IF;

            -- Calcular Saldo Devedor
            vr_aux_vlsldliq := 0;
            IF vr_tab_dados_epr.COUNT > 0 THEN
              vr_aux_vlsldliq := NVL(vr_tab_dados_epr(vr_tab_dados_epr.first).vlsdeved,0)
                               + NVL(vr_tab_dados_epr(vr_tab_dados_epr.first).vlmtapar,0)
                               + NVL(vr_tab_dados_epr(vr_tab_dados_epr.first).vlmrapar,0);
            END IF;
            vr_log_msgderro := NULL;
            -- 1. Verificar se o valor do pagamento confere com o saldo devedor
            IF vr_aux_vlsldliq <> vr_aux_VlrLanc THEN
              -- Gerar devolucao STR0048
              vr_aux_codierro := 79;
              vr_log_msgderro := 'Portabilidade recusada por divergencia de valor.';
            -- 2. Verifica se contrato ja foi liquidado
            ELSIF rw_crapepr.inliquid = 1 THEN
              vr_aux_codierro := 84;
              vr_log_msgderro := 'Operação de portabilidade já liquidada pelo credor original.';
            -- 3. Verifica se pagamento esta sendo efetuado na mesma data que a IF
            --    Credora Original(neste caso a coop. filiada) aprovou a portabilidade
            ELSIF rw_portab.dtaprov_portabilidade <> to_date(vr_aux_DtMovto,'RRRR-MM-DD') THEN
              vr_aux_codierro := 83;
              vr_log_msgderro := 'Pagamento em data inválida.';
            END IF;

            -- Se houve critica
            IF vr_log_msgderro IS NOT NULL THEN
              -- Gerar devolucao STR0048
              pc_gera_erro_xml(pr_dsdehist => vr_dscritic
                              ,pr_codierro => vr_aux_codierro
                              ,pr_dscritic => vr_dscritic);
              -- Se retornou erro
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;
              -- Gerar LOG
              vr_dscritic := to_char(vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
                                                    ,'dd/mm/rrrr hh24:mi:ss')
                          || ' => Liquidacao '
                          || '|' || rw_crapepr.cdagenci
                          || '|' || rw_crapepr.nrdconta
                          || '|' || rw_crapepr.nrctremp
                          || '|' || vr_aux_NUPortdd
                          || '|' ||'Cancelar => '||vr_log_msgderro;
              -- Marcelo Telles Coelho - Projeto 475
              -- Padronizar os logs no mesmo arquivo
              -- Gerar LOG e continuar o processo normal
              BTCH0001.pc_gera_log_batch(pr_cdcooper      => rw_crapcop_portab.cdcooper
                                        ,pr_ind_tipo_log => 1
                                        ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                          ||'Erro execucao - '
                                                          || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                          || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                          || ' --> '||vr_dscritic
                                       ,pr_nmarqlog      => vr_nmarqlog);
              -- Retornar a execução
              RETURN;
            END IF;

          END IF;
        END IF;

        IF vr_aux_CodMsg = 'CIR0021' THEN /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
          -- Montar email
          vr_aux_dsdemail := 'Codigo Mensagem: ' || vr_aux_CodMsg || ' <br>'
                          || 'Número Controle CIR: ' || vr_aux_NumCtrlCIR || ' <br>'
                          || 'ISPB IF: ' || vr_aux_ISPBIF || ' <br>'
                          || 'Número Controle STR: ' || vr_aux_NumCtrlSTR || ' <br>'
                          || 'Número Remessa Original: ' || vr_aux_NumRemessaOr || ' <br>'
                          || 'Agencia IF: ' || vr_aux_AgIF || ' <br>'
                          || 'Valor Lançamento: ' || vr_aux_VlrLanc || ' <br>'
                          || 'Finalidade CIR: ' || vr_aux_FinlddCIR || ' <br>'
                          || 'Data Hora Bacen: ' || vr_aux_DtHrBC || ' <br>'
                          || 'Data Movimento: ' || vr_aux_DtMovto || ' <br><br>';

          -- Enviar Email para o Financeiro
          gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                    ,pr_cdprogra        => vr_glb_cdprogra
                                    ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'EMAIL_CARRO_FORTE')
                                    ,pr_des_assunto     => 'Lançamento a Crédito Efetivado do MECIR - CECRED'
                                    ,pr_des_corpo       => vr_aux_dsdemail
                                    ,pr_des_anexo       => ''
                                    ,pr_flg_enviar      => 'S'
                                    ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                    ,pr_des_erro        => vr_dscritic);
          -- Se ocorreu erro
          IF trim(vr_dscritic) IS NOT NULL THEN
            -- Gerar LOG e continuar o processo normal
            -- Marcelo Telles Coelho - Projeto 475
            -- Padronizar os logs no mesmo arquivo
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                        ||'Erro execucao - '
                                                        || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                        || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                        || ' --> '||vr_dscritic
                                     ,pr_nmarqlog      => vr_nmarqlog);
            -- Limpar critica
            vr_dscritic := null;
          END IF;

          /* Req50 - Integrar, validar e lançar em conta corrente
             Credito Cedula Pereciada (Projeto 475 Sprint D)*/
          IF vr_aux_AgIF is not null THEN  
            Open cr_crapcopctl (vr_aux_AgIF);
            Fetch cr_crapcopctl into rw_crapcopctl;
            If cr_crapcopctl%found Then
                vr_nrdcontacir:= rw_crapcopctl.nrctactl;
                --
                vr_aux_cdhistor := 2483;
                vr_aux_cdpesqbb := 'CREDITO EM CONTA REF. CEDULA PERICIADA LEGITIMA';   
                --
                -- Gerar lançamento em conta
                BEGIN
                  INSERT INTO craplcm
                     (cdcooper
                     ,dtmvtolt
                     ,cdagenci
                     ,cdbccxlt
                     ,nrdolote
                     ,nrdconta
                     ,nrdctabb
                     ,nrdocmto
                     ,cdhistor
                     ,nrseqdig
                     ,cdpesqbb
                     ,vllanmto
                     ,cdoperad
                     ,hrtransa)
                  VALUES
                     (3 --Gravar sempre em conta corrente na base 3 da central 
                     ,vr_aux_dtmvtolt     
                     ,rw_craplot_rvt.cdagenci --INC0032794
                     ,rw_craplot_rvt.cdbccxlt 
                     ,rw_craplot_rvt.nrdolote 
                     ,vr_nrdcontacir     
                     ,vr_nrdcontacir     
                     ,vr_aux_nrdocmto     
                     ,vr_aux_cdhistor     
                     ,nvl(rw_craplot_rvt.nrseqdig,0) + 1
                     ,vr_aux_cdpesqbb     
                     ,vr_aux_VlrLanc      
                     ,'1'
                     ,to_char(vr_glb_dataatual,'sssss'));
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir na tabela craplcm --> ' || SQLERRM;
                   -- Sair da rotina
                   RAISE vr_exc_saida;
                END;

                -- Atualizar capa do Lote
                BEGIN
                  UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_aux_VlrLanc
                                    ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_aux_VlrLanc
                                    ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                    ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                    ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
                  WHERE craplot.ROWID = rw_craplot_rvt.ROWID;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao atualizar tabela craplot. ' || SQLERRM;
                    -- Sair da rotina
                    RAISE vr_exc_saida;
                END;
                                         
            Else
               -- Não faz nenhum tratamento caso agência seja inválida                   
               Null;
            End If;
            Close cr_crapcopctl;
          End If;  
          -- Fim Projeto 475 Sprint D
            
          -- Retornar a execução
          RETURN;
        END IF;

        -- Caso seja estorno de TED de BACENJUD entao despreza
        IF vr_aux_CodMsg IN('STR0025','PAG0121') THEN
          -- Buscar TVL
          OPEN cr_craptvl(rw_crapcop_mensag.cdcooper,vr_aux_NumCtrlIF);
          FETCH cr_craptvl
           INTO rw_craptvl;
          -- Se não encontrou
          IF cr_craptvl%NOTFOUND THEN
            CLOSE cr_craptvl;
            -- Gera LOG SPB conforme cabInf
            IF vr_aux_tagCABInf THEN
              pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                             ,pr_msgderro  => 'Numero de Controle invalido');
              vr_aux_CodMsg := 'ERROREJ';
            ELSE
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                             ,pr_msgderro  => 'Numero de Controle invalido');
            END IF;
            -- Cria registro das movimentacoes no SPB
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                           ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                           ,pr_dsmensag => vr_aux_codMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;

            -- Retornar a execução
            RETURN;
          ELSE
            CLOSE cr_craptvl;

            --Bacenjud - SM 1
            vr_dsincons := 'TED BacenJud: Rejeitada pela cabine';

            --Busca maior sequencia na tbblqj_erro_ted
            OPEN cr_tbblqj_erro_ted(rw_craptvl.nrcctrcb, rw_crapcop_mensag.cdcooper, rw_craptvl.nrdconta);
            FETCH cr_tbblqj_erro_ted INTO vr_nrsequencia;
            CLOSE cr_tbblqj_erro_ted;

            --Se for menor que o parametro, insere para reenvio no proximo dia util
            IF vr_nrsequencia < gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                         ,pr_cdcooper => rw_crapcop_mensag.cdcooper
                                                         ,pr_cdacesso => 'QTD_REENVIO_TED_BACENJUD') THEN
              --Inclusao de ted na tabela TBBLQJ_ERRO_TED
              BEGIN
                INSERT INTO tbblqj_erro_ted(cdtransf_bacenjud,
                                            cdcooper,
                                            nrdconta,
                                            nrsequencia,
                                            vlordem,
                                            dtinclusao,
                                            dtenvio,
                                            tpmotivo) VALUES (rw_craptvl.nrcctrcb
                                                             ,rw_crapcop_mensag.cdcooper
                                                             ,rw_craptvl.nrdconta
                                                             ,(vr_nrsequencia + 1)
                                                             ,rw_craptvl.vldocrcb
                                                             ,vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                                                             ,NULL
                                                             ,2);

                vr_dsincons := 'TED BacenJud: Rejeitada pela cabine. Sera efetuada nova tentativa de envio no proximo dia util.';
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := '1 - Erro ao inserir na tabela tbblqj_erro_ted - '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            END IF;
            --Fim Bacenjud - SM 1

            -- Gera log de estorno na cobine
            gene0005.pc_gera_inconsistencia(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                           ,pr_iddgrupo => 2
                                           ,pr_tpincons => 2 -- Erro
                                           ,pr_dsregist => 'Cooperativa: ' || rw_crapcop_mensag.nmrescop
                                                        || '   Conta Origem: ' || rw_craptvl.nrdconta
                                                        || '   Valor: ' || to_char(rw_craptvl.vldocrcb,'99g999g990d00')
                                                        || '   Identificacao Dep.: ' || rw_craptvl.nrcctrcb
                                           ,pr_dsincons => vr_dsincons
                                           ,pr_flg_enviar => 1
                                           ,pr_des_erro => vr_des_reto
                                           ,pr_dscritic => vr_dscritic);

            --Bacenjud - SM 1
            --Geracao log SPB
            pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                           ,pr_msgderro  => 'REJEITADA BACENJUD');

            -- Retornar a execução
            RETURN;

          END IF;
        END IF;

        -- Para Bloqueio Judicial ou mensagens da Cabine
        rw_craptvl := null;
        IF vr_aux_CodMsg IN('STR0010R2','PAG0111R2') OR vr_aux_tagCABInf THEN
          -- Busca numero da conta a CREDITAR
          OPEN cr_craptvl(rw_crapcop_mensag.cdcooper,vr_aux_NumCtrlIF);
          FETCH cr_craptvl
           INTO rw_craptvl;
          -- Se não encontrou
          IF cr_craptvl%NOTFOUND THEN
            CLOSE cr_craptvl;
            -- Gera LOG SPB conforme cabInf
            IF vr_aux_tagCABInf THEN
              vr_aux_CodMsg := 'ERROREJ';
              pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                             ,pr_msgderro  => 'Numero de Controle invalido');
            ELSE
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                             ,pr_msgderro  => 'Numero de Controle invalido');
            END IF;
            -- Cria registro das movimentacoes no SPB
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                           ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                           ,pr_dsmensag => vr_aux_codMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;

            -- Retornar a execução
            RETURN;

          ELSE
            CLOSE cr_craptvl;
            -- Sprint D - Não gerar lançamentos para devoluções de convênios (STR0007/STR0020)
            IF rw_craptvl.dshistor = 'CRPS391' THEN
               RETURN;
            END IF;  
            --            
            -- Se está na cabine
            IF vr_aux_tagCABInf THEN
              vr_aux_VlrLanc := rw_craptvl.vldocrcb;

              -- Verificar se tabela esta lockada
              IF fn_verifica_tab_em_uso(pr_sig_tabela => 'TVL'
                                       ,pr_rowid => rw_craptvl.rowid ) = 1 THEN
                vr_dscritic := 'Registro de Transferencia DOC/TED '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
                -- apensa jogar critica em log
                RAISE vr_exc_lock;
              END IF;

              -- Atualizar a operação como finalizada
              BEGIN
                UPDATE craptvl
                   SET craptvl.flgopfin = 1 /*Finaliz.*/
                 WHERE ROWID = rw_craptvl.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao atualizar craptlv --> '||sqlerrm;
                  raise vr_exc_saida;
              END;
            END IF;
            -- Usar a conta da TVL
            vr_aux_nrctacre := rw_craptvl.nrdconta;

            -- Logar Estorno TED de nao cooperado
            IF vr_aux_nrctacre = 0 THEN
              -- Gera LOG SPB conforme cabInf
              IF vr_aux_tagCABInf THEN
                -- Marcelo Telles Coelho - Projeto 475
                -- Gerar LOGSPB para cancelamento
                IF vr_aux_tagCABInfCCL THEN
                  pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                                 ,pr_msgderro  => 'Rejeitada pela cabine.');
                ELSE
                vr_aux_CodMsg := 'ERROREJ';
                pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA NAO OK'
                               ,pr_msgderro  => 'Rejeitada pela cabine');
                END IF;
              ELSE
                pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                               ,pr_msgderro  => fn_motivo_devolucao);
              END IF;
              -- Cria registro das movimentacoes no SPB
              pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                             ,pr_dtmvtolt => vr_aux_dtmvtolt
                             ,pr_dsmensag => vr_aux_codMsg
                             ,pr_dsdebcre => 'C'
                             ,pr_vllanmto => vr_aux_VlrLanc
                             ,pr_dscritic => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                raise vr_exc_saida;
              END IF;
              -- Projeto 475 Sprint C REQ21 - Comunicar equipe responsável de uma devolução recebida (STR0005 e PAG0107)
              OPEN cr_tbspbmsgenv(vr_aux_NumCtrlIF);
              FETCH cr_tbspbmsgenv INTO rw_tbspbmsgenv;
              -- Se não encontrar
              IF cr_tbspbmsgenv%NOTFOUND THEN
                 CLOSE cr_tbspbmsgenv;
                 -- Não tratar
              ELSE
                 CLOSE cr_tbspbmsgenv;
                 vr_dsdevolucao:= null;
                 vr_nmremetente := null;
                 If vr_aux_CodDevTransf is not null then
                   vr_dsdevolucao:= tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                       ,pr_nmsistem => 'CRED'
                                                       ,pr_tptabela => 'GENERI'
                                                       ,pr_cdempres => 0
                                                       ,pr_cdacesso => 'CDERROSSPB'
                                                       ,pr_tpregist => vr_aux_CodDevTransf);
                   vr_dsdevolucao:= ' - '||vr_dsdevolucao;                                    
                 Else
                   vr_dsdevolucao:= 'Rejeição';
                 End If;                               
                 vr_nmremetente := sspb0003.fn_busca_conteudo_campo(rw_tbspbmsgenv.dsxml_mensagem,'NomRemet','S');
                 If vr_aux_dtmovto is not null then
                   vr_aux_dtmovto_aux := To_char(To_date(vr_aux_dtmovto,'YYYY-MM-DD'),'DD/MM/YYYY');
                 Else
                   vr_aux_dtmovto_aux := To_char(sysdate,'DD/MM/YYYY');
                 End if;                                                        
                 -- Enviar email de devolução de TED sem conta para responsáveis
                 vr_aux_dsdemail := 'Pilotos, a TED em espécie abaixo foi devolvida. Favor informar a Cooperativa. <br><br>'
                  || ' <br>'
                  || ' <br>'
                  || ' Cooperativa: ' || rw_crapcop_mensag.cdcooper || ' <br>' 
                  || ' Data de envio: ' || vr_aux_dtmovto_aux || ' <br>'         
                  || ' Nome do Remetente: ' || vr_nmremetente || '. <br><br>'
                  || ' Valor: ' || to_char(vr_aux_VlrLanc,'fm999g999g999g990d00')  || ' <br>'
                  || ' Número de controle IF: ' || vr_aux_NumCtrlIF    || ' <br>'
				  || ' Posto de Atendimento: ' || rw_craptvl.cdagenci || ' <br>'
                  || ' Caixa: ' || substr(rw_craptvl.nrdolote, -3) || ' <br>'				  
                  || ' Motivo da Devolução/Rejeição: ' || vr_aux_CodDevTransf || vr_dsdevolucao|| '. <br><br>'; 
                    
                 gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                            ,pr_cdprogra        => vr_glb_cdprogra
                                            ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'SPB_TED_SEM_CONTA')  
                                            ,pr_des_assunto     => 'DEVOLUÇÃO TED EM ESPÉCIE'
                                            ,pr_des_corpo       => vr_aux_dsdemail
                                            ,pr_des_anexo       => ''
                                            ,pr_flg_enviar      => 'S'
                                            ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                            ,pr_des_erro        => vr_dscritic);                   

                 -- Se ocorreu erro
                 IF trim(vr_dscritic) IS NOT NULL THEN
                   -- Gerar LOG e continuar o processo normal
                   BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                           ,pr_ind_tipo_log  => 1
                           ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                           || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                           || 'Mensagem: ' || vr_aux_CodMsg || ' '
                           || ' --> '||vr_dscritic
                          ,pr_nmarqlog      => vr_nmarqlog);
                   -- Limpar critica
                   vr_dscritic := null;
                 END IF;                   
              END IF;               
              -- Fim 475 Sprint C

              -- Retornar a execução
              RETURN;

            END IF;
          END IF;
        ELSE
          -- Conta a creditar
          vr_aux_nrctacre := vr_aux_CtCredtd;
        END IF;

        -- Se for bloqueio Judicial deve-se gerar email e encerrar o processo nao deve creditar a conta
        IF rw_craptvl.nrdconta IS NOT NULL AND rw_craptvl.tpdctacr = 9 THEN
          --Bacenjud - SM 1
          vr_dsincons := 'TED BacenJud: Devolvida';

          --Busca maior sequencia na tbblqj_erro_ted
          OPEN cr_tbblqj_erro_ted(rw_craptvl.nrcctrcb, rw_crapcop_mensag.cdcooper, rw_craptvl.nrdconta);
          FETCH cr_tbblqj_erro_ted INTO vr_nrsequencia;
          CLOSE cr_tbblqj_erro_ted;

          --Se for menor que o parametro, insere para reenvio no proximo dia util
          IF vr_nrsequencia < gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                       ,pr_cdcooper => rw_crapcop_mensag.cdcooper
                                                       ,pr_cdacesso => 'QTD_REENVIO_TED_BACENJUD') THEN
            --Inclusao de ted na tabela TBBLQJ_ERRO_TED
            BEGIN
              INSERT INTO tbblqj_erro_ted(cdtransf_bacenjud,
                                          cdcooper,
                                          nrdconta,
                                          nrsequencia,
                                          vlordem,
                                          dtinclusao,
                                          dtenvio,
                                          tpmotivo) VALUES (rw_craptvl.nrcctrcb
                                                           ,rw_crapcop_mensag.cdcooper
                                                           ,rw_craptvl.nrdconta
                                                           ,(vr_nrsequencia + 1)
                                                           ,rw_craptvl.vldocrcb
                                                           ,vr_aux_dtmvtolt            -- rw_crapdat_mensag.dtmvtolt
                                                           ,NULL
                                                           ,1);

              vr_dsincons := 'TED BacenJud: Devolvida. Sera efetuada nova tentativa de envio no proximo dia util.';
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := '2 - Erro ao inserir na tabela tbblqj_erro_ted - '||SQLERRM;
                RAISE vr_exc_saida;
            END;
          END IF;
          --Fim Bacenjud - SM 1

          -- Gera log de estorno na cobine
          gene0005.pc_gera_inconsistencia(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                         ,pr_iddgrupo => 2
                                         ,pr_tpincons => 2 -- Erro
                                         ,pr_dsregist => 'Cooperativa: ' || rw_crapcop_mensag.nmrescop
                                                      || '   Conta Origem: ' || rw_craptvl.nrdconta
                                                      || '   Valor: ' || to_char(vr_aux_VlrLanc,'99g999g990d00')
                                                      || '   Identificacao Dep.: ' || rw_craptvl.nrcctrcb
                                         ,pr_dsincons => vr_dsincons
                                         ,pr_flg_enviar => 1
                                         ,pr_des_erro => vr_des_reto
                                         ,pr_dscritic => vr_dscritic);
          -- Cria registro das movimentacoes no SPB
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => vr_aux_dtmvtolt
                         ,pr_dsmensag => vr_aux_codMsg
                         ,pr_dsdebcre => 'C'
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;
          pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                         ,pr_msgderro  => 'DEVOLUCAO BACENJUD');

          
          -- Retornar a execução
          RETURN;

        END IF;

        -- Se existir craptco eh uma conta incorporada ou migrada,
        -- conforme validacao efetuada na procedure verifica_conta.
        IF rw_craptco.nrdconta IS NOT NULL THEN
          pc_processa_conta_transferida(pr_cdcopant => rw_crapcop_mensag.cdcooper
                                       ,pr_nrctaant => vr_aux_nrctacre
                                       ,pr_vlrlanct => vr_aux_VlrLanc
                                       ,pr_dscritic => vr_dscritic);
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
        ELSE
          -- Verificar se o LCM já não existe
          vr_aux_existlcm := 0;
          vr_aux_vllanmto := NULL;
          OPEN cr_craplcm_exis(pr_cdcooper => rw_crapcop_mensag.cdcooper
                              ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_craplot.dtmvtolt
                              ,pr_cdagenci => rw_craplot_rvt.cdagenci
                              ,pr_cdbccxlt => rw_craplot_rvt.cdbccxlt
                              ,pr_nrdolote => rw_craplot_rvt.nrdolote
                              ,pr_nrdctabb => vr_aux_nrctacre
                              ,pr_nrdocmto => vr_aux_nrdocmto);
          FETCH cr_craplcm_exis
           INTO vr_aux_existlcm,vr_aux_vllanmto;
          CLOSE cr_craplcm_exis;
          -- Se encontrou
          IF vr_aux_existlcm = 1 THEN
            -- Para Rejeição
            IF vr_aux_CodMsg in ('STR0010R2','PAG0111R2') OR vr_aux_tagCABInf THEN
              -- Montar textos de logs
              vr_log_msgderro := 'Lancamento ja existe! Conta: ' || vr_aux_nrctacre
                              || ', Lote: ' || rw_craplot_rvt.nrdolote
                              || ', Doc.: ' || vr_aux_nrdocmto;
              -- Conforme cabine
              IF vr_aux_tagCABInf THEN
                vr_tipolog := 'REJEITADA NAO OK';
                vr_aux_CodMsg := 'ERROREJ';
              ELSE
                vr_tipolog := 'RETORNO SPB';
              END IF;
            ELSE
              -- Montar textos de logs
              vr_tipolog := 'RECEBIDA';
              vr_log_msgderro := 'Lancamento ja existe! Lote: '|| rw_craplot_rvt.nrdolote
                              || ', Doc.: ' || vr_aux_nrdocmto;
            END IF;
            -- Cria registro das movimentacoes no SPB
            pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                           ,pr_dtmvtolt => vr_aux_dtmvtolt
                           ,pr_dsmensag => vr_aux_codMsg
                           ,pr_dsdebcre => 'C'
                           ,pr_vllanmto => vr_aux_VlrLanc
                           ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              raise vr_exc_saida;
            END IF;
            -- Gerar LOG SPB
            pc_gera_log_SPB(pr_tipodlog  => vr_tipolog
                           ,pr_msgderro  => vr_log_msgderro);

            -- Retornar a execução
            RETURN;

          ELSE
            -- Gerar histórico
              /* Verifica se a TED é destinada a uma conta administradora de recursos */
              OPEN cr_tbfin_rec_con(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                    ,pr_nrdconta => vr_aux_nrctacre
                                    ,pr_cdagenci => rw_craplot_rvt.cdagenci);
              FETCH cr_tbfin_rec_con
              INTO rw_tbfin_rec_con;

            /* Estorno TED */
            IF vr_aux_CodMsg in('STR0010R2','PAG0111R2') THEN
              vr_aux_cdhistor := 600;
              vr_aux_cdpesqbb := vr_aux_CodDevTransf;
              IF vr_aux_CodMsg = 'STR0010R2' THEN
                IF cr_tbfin_rec_con%FOUND THEN
                  vr_aux_cdhistor := 2734;
                  vr_aux_flgreccon := TRUE; 
                  vr_aux_TPCONTA_CREDITADA := rw_tbfin_rec_con.tpconta;
                  vr_aux_NMTITULAR_CREDITADA := rw_tbfin_rec_con.nmtitular;
                  vr_aux_DSCONTA_CREDITADA := rw_tbfin_rec_con.nrdconta;
                  VR_AUX_CDAGENCI_CREDITADA := rw_tbfin_rec_con.cdagenci;
                END IF;
              END IF;
            /* Estorno TED Rejeitada*/
            ELSIF vr_aux_tagCABInf THEN
              vr_aux_cdhistor := 887;
              vr_aux_cdpesqbb := 'TED/TEC rejeitado coop';
            /* Credito TEC */
            ELSIF vr_aux_CodMsg IN('STR0037R2','PAG0137R2') THEN
              vr_aux_cdhistor := 799;
              vr_aux_cdpesqbb := vr_aux_dadosdeb;
            ELSIF vr_aux_CodMsg = 'STR0047R2' THEN
              vr_aux_cdhistor := 1921;
              vr_aux_cdpesqbb := 'CRED TED PORT';
            ELSE
              /* Credito TED */
              vr_aux_cdhistor := 578;
              vr_aux_cdpesqbb := vr_aux_dadosdeb;

              -- Se encontrar
              IF cr_tbfin_rec_con%FOUND THEN
                vr_aux_flgreccon := TRUE; 
                vr_aux_cdhistor := 2622;
                vr_aux_TPCONTA_CREDITADA := rw_tbfin_rec_con.tpconta;
                vr_aux_NMTITULAR_CREDITADA := rw_tbfin_rec_con.nmtitular;
                vr_aux_DSCONTA_CREDITADA := rw_tbfin_rec_con.nrdconta;
                VR_AUX_CDAGENCI_CREDITADA := rw_tbfin_rec_con.cdagenci;
              END IF;
              END IF;

            CLOSE cr_tbfin_rec_con;

            IF NOT vr_aux_flgreccon THEN

            
              vr_tab_retorno := NULL;
              vr_incrineg := 0;
              
              vr_nrseqdig := fn_sequence('CRAPLOT'
			                      ,'NRSEQDIG'
			                      ,''||rw_crapcop_mensag.cdcooper||';'
				                     ||to_char(rw_craplot_rvt.dtmvtolt,'DD/MM/RRRR')||';'
				                     ||rw_craplot_rvt.cdagenci||';'
				                     ||rw_craplot_rvt.cdbccxlt||';'
				                     ||rw_craplot_rvt.nrdolote);

              -- -- Gerar lançamento em conta
              LANC0001.pc_gerar_lancamento_conta
                            ( pr_cdcooper => rw_crapcop_mensag.cdcooper
                             ,pr_dtmvtolt => rw_craplot_rvt.dtmvtolt
                             ,pr_cdagenci => rw_craplot_rvt.cdagenci
                             ,pr_cdbccxlt => rw_craplot_rvt.cdbccxlt
                             ,pr_nrdolote => rw_craplot_rvt.nrdolote
                             ,pr_nrdconta => vr_aux_nrctacre
                             ,pr_nrdctabb => vr_aux_nrctacre
                             ,pr_nrdocmto => vr_aux_nrdocmto
                             ,pr_cdhistor => vr_aux_cdhistor
                             ,pr_nrseqdig => vr_nrseqdig
                             ,pr_cdpesqbb => vr_aux_cdpesqbb
                             ,pr_vllanmto => vr_aux_VlrLanc
                             ,pr_cdoperad => '1'
                             ,pr_hrtransa => to_char(vr_glb_dataatual,'sssss')
                             
                             --> OUT <--
                             ,pr_tab_retorno => vr_tab_retorno
                             ,pr_incrineg => vr_incrineg           -- Indicador de crítica de negócio
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic);
                             
              IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                --> Tratativas para critica de negocio
                IF vr_incrineg = 1 THEN
                 -- Sair da rotina
                 RAISE vr_exc_saida;
                --> Tratativas para criticas de sistema
                ELSE
                 -- Sair da rotina
                 RAISE vr_exc_saida;
                END IF; 
              END IF;  

              -- Marcelo Telles Coelho - Projeto 475 - SPRINT B
              -- Estornar a tarifa da TED, somente se for devolução/rejeição de TED gerada no Ailos
              IF vr_aux_tagCABInfCCL
              THEN
                FOR r1 IN (SELECT *
                             FROM craplat
                            WHERE cdcooper = rw_crapcop_mensag.cdcooper
                              AND nrdconta = vr_aux_nrctacre
                              AND nrdocmto = vr_aux_nrdocmto)
                LOOP
                  --> Estornar lançamento de tarifa de TED da conta corrente do cooperado
                  TARI0001.pc_estorno_baixa_tarifa (pr_cdcooper  => rw_crapcop_mensag.cdcooper  --> Codigo Cooperativa
                                                   ,pr_cdagenci  => 1                           --> Codigo Agencia
                                                   ,pr_nrdcaixa  => 1                           --> Numero do caixa
                                                   ,pr_cdoperad  => '1'                         --> Codigo Operador
                                                   ,pr_dtmvtolt  => vr_aux_dtmvtolt             --> Data Lancamento
                                                   ,pr_nmdatela  => NULL                        --> Nome da tela
                                                   ,pr_idorigem  => 1               -- AYLLOS   --> Indicador de origem
                                                   ,pr_inproces  => 1                           --> Indicador processo
                                                   ,pr_nrdconta  => vr_aux_nrctacre             --> Numero da Conta
                                                   ,pr_cddopcap  => 1                           --> Codigo de opcao --> 1 - Estorno de tarifa --> 2 - Baixa de tarifa
                                                   ,pr_lscdlant  => r1.cdlantar                 --> Lista de lancamentos de tarifa(delimitador ;)
                                                   ,pr_lscdmote  => ''                          --> Lista de motivos de estorno (delimitador ;)
                                                   ,pr_flgerlog  => 'S'                         --> Indicador se deve gerar log (S-sim N-Nao)
                                                   ,pr_cdcritic  => vr_cdcritic                 --> Codigo Critica
                                                   ,pr_dscritic  => vr_dscritic);               --> Descricao Critica
                  IF nvl(vr_cdcritic,0) > 0 OR
                     TRIM(vr_dscritic) IS NOT NULL THEN
                    RAISE vr_exc_saida;
                  END IF;
                END LOOP;
              END IF;
              -- Fim Projeto 475
              --
              -- Conforme cabine
              IF vr_aux_tagCABInf THEN
                vr_aux_CodMsg := 'MSGREJ';
              END IF;
              -- Cria registro das movimentacoes no SPB
              pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                             ,pr_dtmvtolt => vr_aux_dtmvtolt
                             ,pr_dsmensag => vr_aux_codMsg
                             ,pr_dsdebcre => 'C'
                             ,pr_vllanmto => vr_aux_VlrLanc
                             ,pr_dscritic => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                raise vr_exc_saida;
            END IF;

            ELSE
                   
              /* Seta o vr_aux_ISPBIFDebtd na variavel vr_aux_BancoDeb */
              vr_aux_BancoDeb := vr_aux_ISPBIFDebtd;
        
        
              vr_aux_nrseqdig := fn_sequence('tbfin_recursos_movimento',
                             'nrseqdig',''||rw_crapcop_mensag.cdcooper
                             ||';'||vr_aux_nrctacre||';'||to_char(vr_aux_dtmvtolt,'dd/mm/yyyy')||'');
              
              vr_idlancto := fn_sequence(pr_nmtabela => 'TBFIN_RECURSOS_MOVIMENTO'
                                          ,pr_nmdcampo => 'IDLANCTO'
                                        ,pr_dsdchave => 'IDLANCTO');
                                                            
              -- Gerar lançamento em conta
              BEGIN

                INSERT INTO tbfin_recursos_movimento
                    (cdcooper
                    ,nrdconta
                    ,dtmvtolt
                    ,nrdocmto
                    ,nrseqdig
                    ,cdhistor
                    ,dsdebcre
                    ,vllanmto
                    ,nmif_debitada
                    ,nrispbif
                    ,nrcnpj_debitada
                    ,nmtitular_debitada
                    ,tpconta_debitada
                    ,cdagenci_debitada
                    ,dsconta_debitada
                    ,hrtransa
                    ,cdoperad
                    ,idlancto
                    ,inpessoa_debitada
                    ,inpessoa_creditada
                    ,CDAGENCI_CREDITADA
                    ,DSCONTA_CREDITADA
                    ,TPCONTA_CREDITADA
                    ,NMTITULAR_CREDITADA)
                VALUES
                   (rw_crapcop_mensag.cdcooper
                   ,vr_aux_nrctacre
                   ,vr_aux_dtmvtolt
                   ,vr_aux_nrdocmto
                   ,vr_aux_nrseqdig
                   ,vr_aux_cdhistor
                   ,'C'
                   ,vr_aux_VlrLanc
                   ,vr_aux_BancoDeb
                   ,vr_aux_BancoDeb
                   ,vr_aux_CNPJ_CPFDeb
                   ,vr_aux_NomCliDebtd
                   ,vr_aux_TpCtDebtd
                   ,vr_aux_AgDebtd
                   ,vr_aux_CtDebtd
                   ,to_char(vr_glb_dataatual,'sssss')
                   ,'1'
                   ,vr_idlancto
                   ,DECODE(vr_aux_TpPessoaDebtd_Remet, 'F', 1, 'J', 2)
                   ,DECODE(vr_aux_TpPessoaCred, 'F', 1, 'J', 2)
                   ,vr_aux_CDAGENCI_CREDITADA
                   ,vr_aux_DSCONTA_CREDITADA
                   ,vr_aux_TPCONTA_CREDITADA
                   ,vr_aux_NMTITULAR_CREDITADA
                   );
              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Erro ao inserir na tabela tbfin_recursos_movimento --> ' || SQLERRM;
                 -- Sair da rotina
                 RAISE vr_exc_saida;
              END;

              --
              OPEN cr_craphis(pr_cdcooper => rw_crapcop_mensag.cdcooper
                             ,pr_cdhistor => vr_aux_cdhistor);
              --
              FETCH cr_craphis INTO rw_craphis;
              --
              IF cr_craphis%NOTFOUND THEN
                --
                vr_dscritic := 'Contrapartida do histórico ' || vr_aux_cdhistor || ' não encontrada!';
                CLOSE cr_craphis;
                RAISE vr_exc_saida;
                --
          END IF;
              --
              CLOSE cr_craphis;

              -- Atualiza o saldo
              COBR0011.pc_atualiza_saldo(pr_cdcooper => 3
                                        ,pr_nrdconta => vr_aux_nrctacre
                                        ,pr_dtmvtolt => vr_aux_dtmvtolt
                                        ,pr_vllanmto => vr_aux_VlrLanc
                                        ,pr_dsdebcre => rw_craphis.indebcre
                                        ,pr_dscritic => vr_dscritic);

              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_saida;
              END IF;

              /*OPEN cr_tbfin_rec_sal(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                    ,pr_nrdconta => vr_aux_nrctacre
                                    ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt);
              FETCH cr_tbfin_rec_sal
              INTO rw_tbfin_rec_sal;
              -- Se encontrar
              IF cr_tbfin_rec_sal%FOUND THEN
                vr_aux_flgrecsal := TRUE;
              END IF;
              CLOSE cr_tbfin_rec_sal;

              -- Alterar saldo
              IF vr_aux_flgrecsal THEN

                BEGIN
                  UPDATE tbfin_recursos_saldo
                  SET vlsaldo_final = vlsaldo_final + vr_aux_VlrLanc
                  WHERE cdcooper = rw_crapcop_mensag.cdcooper
                  AND nrdconta = vr_aux_nrctacre;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao editar a tabela tbfin_recursos_saldo --> ' || SQLERRM;
                   -- Sair da rotina
                   RAISE vr_exc_saida;
                END;

              ELSE

                OPEN cr_tbfin_rec_sal_ant(pr_cdcooper => rw_crapcop_mensag.cdcooper
                                        ,pr_nrdconta => vr_aux_nrctacre
                                        ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt);
                FETCH cr_tbfin_rec_sal_ant
                INTO rw_tbfin_rec_sal_ant;
                -- Se encontrar
                IF cr_tbfin_rec_sal_ant%FOUND THEN
                  vr_aux_sal_ant := rw_tbfin_rec_sal_ant.vlsaldo_final;
                END IF;
                CLOSE cr_tbfin_rec_sal_ant;

                BEGIN
                  INSERT INTO tbfin_recursos_saldo
                     (cdcooper
                      ,nrdconta
                      ,dtmvtolt
                      ,vlsaldo_inicial
                      ,vlsaldo_final)
                  VALUES
                     (rw_crapcop_mensag.cdcooper
                     ,vr_aux_nrctacre
                     ,rw_crapdat_mensag.dtmvtolt
                     ,vr_aux_sal_ant
                     ,(vr_aux_sal_ant + vr_aux_VlrLanc));
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Erro ao inserir na tabela tbfin_recursos_saldo --> ' || SQLERRM;
                   -- Sair da rotina
                   RAISE vr_exc_saida;
                END;
              END IF;*/
            END IF;
          END IF;
        END IF;
      END IF;

      -- Mensagem de Sucesso
      IF vr_aux_CodMsg IN('STR0010R2','PAG0111R2') OR vr_aux_tagCABInf THEN
        -- Gerar log conforme situação cabine
        IF vr_aux_tagCABInf THEN
          vr_aux_CodMsg := vr_aux_msgrejei;
          -- Gerar LOG
          pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                         ,pr_msgderro  => 'Rejeitada pela cabine');
        ELSE
          -- Gerar LOG
          pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA NAO OK'
                         ,pr_msgderro  => fn_motivo_devolucao);
        END IF;
      -- Liquidar contrato de empréstimo após receber pagamento da portabilidade
      ELSIF vr_aux_CodMsg = 'STR0047R2' THEN
        -- Leitura do Lote na cooperativa do contrato referente ao crédito do saldo devedor
        -- Verificar criação do lote
        OPEN cr_craplot(pr_cdcooper => rw_crapcop_portab.cdcooper
                       ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
                       ,pr_cdagenci => vr_glb_cdagenci
                       ,pr_cdbccxlt => vr_glb_cdbccxlt
                       ,pr_nrdolote => 600030);
        FETCH cr_craplot INTO rw_craplot;
        -- Se não encontrou capa do lote
        IF cr_craplot%NOTFOUND THEN
          -- Fecha Cursor
          CLOSE cr_craplot;

          BEGIN
            --Inserir a capa do lote retornando informacoes para uso posterior
            INSERT INTO craplot
               (dtmvtolt
               ,cdagenci
               ,cdbccxlt
               ,nrdolote
               ,tplotmov
               ,cdcooper
               ,nrseqdig
               ,cdhistor
               ,cdoperad)
            VALUES
               (vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
               ,vr_glb_cdagenci
               ,vr_glb_cdbccxlt
               ,600030
               ,vr_glb_tplotmov
               ,rw_crapcop_portab.cdcooper
               ,0
               ,0
               ,'1')
             RETURNING dtmvtolt
                      ,cdagenci
                      ,cdbccxlt
                      ,nrdolote
                      ,nrseqdig
                      ,cdcooper
                      ,tplotmov
                      ,vlinfodb
                      ,vlcompdb
                      ,qtinfoln
                      ,qtcompln
                      ,cdoperad
                      ,tpdmoeda
                      ,rowid
                  into vr_aux_dtmvtolt            -- rw_craplot.dtmvtolt
                      ,rw_craplot.cdagenci
                      ,rw_craplot.cdbccxlt
                      ,rw_craplot.nrdolote
                      ,rw_craplot.nrseqdig
                      ,rw_craplot.cdcooper
                      ,rw_craplot.tplotmov
                      ,rw_craplot.vlinfodb
                      ,rw_craplot.vlcompdb
                      ,rw_craplot.qtinfoln
                      ,rw_craplot.qtcompln
                      ,rw_craplot.cdoperad
                      ,rw_craplot.tpdmoeda
                      ,rw_craplot.rowid;
           EXCEPTION
             WHEN OTHERS THEN
               vr_dscritic := 'Erro ao inserir na tabela craplot (8453). '||SQLERRM;
               -- Sair da rotina
               RAISE vr_exc_saida;
           END;
        ELSE
          -- Apenas Fecha Cursor
          CLOSE cr_craplot;
        END IF;
        -- Verificar se já não existe lançamento na conta do Cooperado
        vr_aux_existlcm := 0;
        vr_aux_vllanmto := NULL;
        OPEN cr_craplcm_exis(pr_cdcooper => rw_crapcop_portab.cdcooper
                            ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_craplot.dtmvtolt
                            ,pr_cdagenci => rw_craplot.cdagenci
                            ,pr_cdbccxlt => rw_craplot.cdbccxlt
                            ,pr_nrdolote => rw_craplot.nrdolote
                            ,pr_nrdctabb => rw_portab.nrdconta
                            ,pr_nrdocmto => vr_aux_nrctremp);
        FETCH cr_craplcm_exis
         INTO vr_aux_existlcm,vr_aux_vllanmto;
        CLOSE cr_craplcm_exis;

        -- Se já existia LCS
        IF vr_aux_vllanmto IS NOT NULL THEN
          -- Gerar critica
          vr_dscritic := to_char(vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
                                                ,'dd/mm/rrrr hh24:mi:ss')
                      || ' => Liquidacao '
                      || '|' || rw_crapepr.cdagenci
                      || '|' || rw_crapepr.nrdconta
                      || '|' || vr_aux_nrctremp
                      || '|' || vr_aux_NUPortdd
                      || '|' ||'Lancamento ja existe!';
          -- Escrever em LOG e finalizar o processo
          -- Marcelo Telles Coelho - Projeto 475
          -- Padronizar os logs no mesmo arquivo
          BTCH0001.pc_gera_log_batch(pr_cdcooper      => rw_crapcop_portab.cdcooper
                                    ,pr_ind_tipo_log => 1
                                    ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                      ||'Erro execucao - '
                                                      || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                      || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                      || ' --> '||vr_dscritic
                                    ,pr_nmarqlog      => vr_nmarqlog);
          RETURN;
        ELSE
          -- Conforme o tipo do Empréstimo
          IF vr_aux_tpemprst = 1 THEN -- PP
            -- Chamar liquidação Empréstimo Novo
            pc_liq_contrato_emprest_nov(pr_cdcooper => rw_crapcop_portab.cdcooper
                                       ,pr_nrdconta => rw_portab.nrdconta
                                       ,pr_nrctremp => vr_aux_nrctremp
                                       ,pr_dtmvtolt => vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
                                       ,pr_dtmvtoan => rw_crapdat_portab.dtmvtoan
                                       ,pr_cdagenci => rw_crapepr.cdagenci
                                       ,pr_cdagelot => rw_craplot.cdagenci
                                       ,pr_dscritic => vr_dscritic);
          ELSIF vr_aux_tpemprst = 0 THEN -- TR
            -- Chamar Liquidação Empréstimo Antigo
            pc_liq_contrato_emprest_ant(pr_cdcooper   => rw_crapcop_portab.cdcooper
                                       ,pr_nrdconta   => rw_portab.nrdconta
                                       ,pr_nrctremp   => vr_aux_nrctremp
                                       ,pr_rw_crapdat => rw_crapdat_portab
                                       ,pr_dtmvtolt   => vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
                                       ,pr_dscritic   => vr_dscritic);
          END IF;

          -- Se retornou erro na Liquidação
          IF vr_dscritic IS NOT NULL THEN
            -- Retornar a execução
            RETURN;
          END IF;

          vr_tab_retorno := NULL;
          vr_incrineg := 0;
              
          -- -- Gerar lançamento em conta
          LANC0001.pc_gerar_lancamento_conta
                        ( pr_cdcooper => rw_crapcop_portab.cdcooper
                         ,pr_dtmvtolt => rw_craplot.dtmvtolt
                         ,pr_cdagenci => rw_craplot.cdagenci
                         ,pr_cdbccxlt => rw_craplot.cdbccxlt
                         ,pr_nrdolote => rw_craplot.nrdolote
                         ,pr_nrdconta => rw_portab.nrdconta
                         ,pr_nrdctabb => rw_portab.nrdconta
                         ,pr_nrdocmto => vr_aux_nrctremp
                         ,pr_cdhistor => 1918 --> CRED TED PORT
                         ,pr_vllanmto => vr_aux_VlrLanc
                         ,pr_nrseqdig => rw_craplot.nrseqdig + 1
                         ,pr_cdpesqbb => 'CRED TED PORT'
                         ,pr_cdoperad => '1'
                         ,pr_hrtransa => to_char(vr_glb_dataatual,'sssss')                         
                             
                         --> OUT <--
                         ,pr_tab_retorno => vr_tab_retorno
                         ,pr_incrineg => vr_incrineg           -- Indicador de crítica de negócio
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic);
                             
          IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
            --> Tratativas de erro serão controladas logo abaixo
            NULL;
          ELSE
          BEGIN
            -- Atualizar capa do Lote
            UPDATE craplot SET craplot.vlinfocr = nvl(craplot.vlinfocr,0) + vr_aux_VlrLanc
                              ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + vr_aux_VlrLanc
                              ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                              ,craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                              ,craplot.nrseqdig = nvl(craplot.nrseqdig,0) + 1
            WHERE craplot.ROWID = rw_craplot.ROWID;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic := 'Erro ao criar lancamento de TED ou na atualizacao do Lote: '||sqlerrm;
          END;

          END IF;
          
          -- Se não houve erro até então
          IF vr_dscritic IS NULL THEN

            -- Atualiza situacao da portabilidade para Concluida no JDCTC
            BEGIN
              UPDATE tbepr_portabilidade
                 SET dtliquidacao = vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
               WHERE cdcooper = rw_crapcop_portab.cdcooper
                 AND nrunico_portabilidade = vr_aux_NUPortdd;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar Portabilidade --> '||sqlerrm;
                RAISE vr_exc_saida;
            END;

            -- Achar numero Banco Central
            OPEN cr_crapban(pr_cdbccxlt => 85);
            FETCH cr_crapban
             INTO rw_crapban;
            CLOSE cr_crapban;

            -- Atualiza situacao da portabilidade para Concluida no JDCTC
            empr0006.pc_atualizar_situacao(pr_cdcooper => rw_crapcop_mensag.cdcooper           /* Cód. Cooperativa */
                                          ,pr_idservic => 2                             /* Tipo de servico(1-Proponente/2-Credora) */
                                          ,pr_cdlegado => 'LEG'                         /* Codigo Legado */
                                          ,pr_nrispbif => rw_crapban.nrispbif           /* Numero ISPB IF */
                                          ,pr_nrcontrl => '1'                           /* Nr. controle (verificar) */
                                          ,pr_nuportld => vr_aux_NUPortdd               /* Numero Portabilidade CTC */
                                          ,pr_cdsittit => 'PL5'                         /* Codigo Situacao Titulo */
                                          ,pr_flgrespo => vr_aux_flgrespo               /* 1 - Se o registro na JDCTC for atualizado com sucesso */
                                          ,pr_des_erro => vr_des_reto                   /* Indicador erro OK/NOK */
                                          ,pr_dscritic => vr_dscritic);                 /* Descricao do erro */

            -- Se houve erro
            IF vr_des_reto <> 'OK' OR vr_aux_flgrespo <> 1 THEN
              -- Gerar log
              vr_dscritic := to_char(vr_aux_dtmvtolt            -- rw_crapdat_portab.dtmvtolt
                                                    ,'dd/mm/rrrr hh24:mi:ss')
                          || ' => Liquidacao '
                          || '|' || rw_crapepr.cdagenci
                          || '|' || rw_crapepr.nrdconta
                          || '|' || vr_aux_nrctremp
                          || '|' || vr_aux_NUPortdd
                          || '|' ||'Erro ao atualizar situacao da portabilidade no JDCTC.!';
              -- Escrever em LOG e continuar
              -- Marcelo Telles Coelho - Projeto 475
              -- Padronizar os logs no mesmo arquivo
              BTCH0001.pc_gera_log_batch(pr_cdcooper      => rw_crapcop_portab.cdcooper
                                        ,pr_ind_tipo_log => 1
                                        ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                          ||'Erro execucao - '
                                                          || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                          || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                          || ' --> '||vr_dscritic
                                        ,pr_nmarqlog      => vr_nmarqlog);
              -- Limpar critica
              vr_dscritic := null;
            END IF;

            -- Chegou ao fim sem erro, gera log
            pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                           ,pr_msgderro  => NULL);
          ELSE
            RAISE vr_exc_saida;
          END IF;
        END IF;
      ELSE
        -- Apenas gerar LOG
        pc_gera_log_SPB(pr_tipodlog  => 'RECEBIDA'
                       ,pr_msgderro  => NULL);
      END IF;


    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro tratado em pc_trata_lancamentos --> '||vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro nao tratado em pc_trata_lancamentos --> '||sqlerrm;
    END pc_trata_lancamentos;

    PROCEDURE pc_alter_session_para_default IS 
    -- Marcelo Telles Coelho - Projeto 475 - SPRINT C2
    BEGIN 
      -- Alteração incluindo num comando setar a forma de data e o decimal
      EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD-MON-RR''
                                           NLS_NUMERIC_CHARACTERS = ''.,''';
    END pc_alter_session_para_default;
    
  BEGIN -- INICIO PC_CRPS531_1

    vr_trace_dsxml_mensagem := xmltype.getClobVal(pr_dsxmltype);

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_glb_cdprogra
                              ,pr_action => 'PC_'||vr_glb_cdprogra||'_1');

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop
     INTO rw_crapcop_central;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      pr_cdcritic := 651;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat
     INTO rw_crapdat_central;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      pr_cdcritic := 1;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Definir nome do arquivo de log
    vr_logprogr :=  vr_glb_cdprogra||'_'||to_char(SYSDATE,'DDMMRRRR');                        -- Marcelo Telles Coelho - Projeto 475

    -- Buscar Estado de Crise
    SSPB0001.pc_estado_crise_tb(pr_flproces => 'S'                  -- Indica para verificar o processo
                               ,pr_inestcri => vr_aux_flestcri          -- 0-Sem crise / 1-Com Crise
                               ,pr_tbestcri => vr_tab_estad_crise); -- Tabela com informações

    -- Resetar variaveis
    vr_aux_dtintegr      := rw_crapdat_central.dtmvtolt;
    vr_aux_manter_fisico := TRUE;

    -- Carregar o parametro que identifica se a mensagem sera movida
    vr_msgspb_mover := gene0001.fn_param_sistema('CRED',0,'MSGSPB_MOVER');

    -- Carregar o parametro que identifica as mensagem que nao serao gravadas na nova estrutura
    vr_msgspb_nao_copiar := gene0001.fn_param_sistema('CRED',0,'MSGSPB_NAO_COPIAR');

    vr_tab_situacao_if.delete();

    -- Chamar rotina para processamento do XML
    pc_importa_xml(vr_dscritic);
    -- Se retornou erro
    IF vr_dscritic IS NOT NULL THEN
      -- Incrementar o LOG
      vr_dscritic := 'Erro ao descriptografar e ler o arquivo : ' || vr_aux_nmdirxml||'/'||vr_aux_nmarqxml;
      RAISE vr_exc_saida;
    ELSE
      -- Marcelo Telles Coelho - Projeto 475
      -- Verificar se as mensagens já foram processadas
      IF vr_aux_CodMsg LIKE '%R2'
      OR vr_aux_tagCABInfCCL
      OR vr_aux_CodMsg = 'CIR0021' /* Projeto 475 - Req50 */
      THEN
        IF SSPB0003.fn_ver_msg_processada(pr_nrcontrole_str_pag => NVL(vr_aux_NumCtrlRem,vr_aux_NumCtrlIF)
                                         ,pr_CabInf_erro        => vr_aux_CabInf_erro) THEN
          -- Não preocessa essa mensagem, pois a mesma já foi processada
          -- Processo finalizado
          vr_cdcritic := NULL;
          vr_dscritic := NULL;
          RAISE vr_exc_saida;
        END IF;
      END IF;
      -- Criar bloco para facilitar o desvio de fluxo ao final
      BEGIN

        -- Se o xml conter a TAG <CABInfSituacao>, pode ser mensagem com erro de
        -- inconsistencia de dados (STR0005E,STR0008E,STR0037E,PAG0107E,PAG0108E,
        -- PAG0137E) ou mensagen de controle da JD.
        -- No caso da TAG <CABInfCancelamento, a mensagem refere-se a uma rejeicao
        -- gerada pela Cabine. Todas sao mensagens de retorno ref. alguma mensagem
        -- enviada pela cooperativa
        IF vr_aux_tagCABInf THEN
          -- Busca cooperativa da destino
          OPEN cr_busca_coop(pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4)
                            ,pr_flgativo => 1);
          FETCH cr_busca_coop
           INTO rw_crapcop_mensag;
          -- Se encontrar
          IF cr_busca_coop%FOUND THEN
            CLOSE cr_busca_coop;
            -- Se estamos em estado de crise
            IF vr_aux_flestcri > 0 THEN
              -- Buscar informações da Coop
              IF vr_tab_estad_crise.exists(rw_crapcop_mensag.cdcooper) THEN
                vr_aux_dtintegr := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).dtintegr;
                vr_aux_inestcri := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).inestcri;
              END IF;
            END IF;
            --
            -- Se nao estiver em estado de crise verifica processo
            IF NOT fn_verifica_processo_crise THEN
              -- Arquivo será ignorado
              RAISE vr_exc_next;
            END IF;
            -- Se encontramos mensagem
            IF trim(vr_aux_CodMsg) IS NOT NULL
            OR vr_aux_CabInf_erro     -- Marcelo Telles Coelho - Projeto 475
            THEN
              -- Marcelo Telles Coelho - Projeto 475
              -- Tratamento de mensagens rejeitadas pela cabine (ex: Duplicidade)
              IF vr_aux_CabInf_erro THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                               ,pr_msgderro  => 'Inconsistencia dados - rejeição automática');
                --
                SSPB0003.pc_grava_trace_spb (pr_cdfase                 => 40 -- Confirmação recebimento JD / rejeição automática
                                            ,pr_idorigem               => NULL
                                            ,pr_nmmensagem             => 'Retorno JD Rejeição'
                                            ,pr_nrcontrole             => vr_aux_NumCtrlIF
                                            ,pr_nrcontrole_str_pag     => vr_aux_NumCtrlRem
                                            ,pr_nrcontrole_dev_or      => NULL
                                            ,pr_dhmensagem             => SYSDATE
                                            ,pr_insituacao             => 'NOK'
                                            ,pr_dsxml_mensagem         => NULL
                                            ,pr_dsxml_completo         => NULL
                                            ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                            ,pr_cdcooper               => rw_crapcop_mensag.cdcooper
                                            ,pr_nrdconta               => NVL(vr_aux_CtCredtd,vr_aux_CtDebtd)
                                            ,pr_cdproduto              => 30 -- TED
                                            ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                            ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                            ,pr_dscritic               => vr_dscritic
                                            ,pr_des_erro               => vr_des_erro
                                            );
                IF vr_dscritic IS NOT NULL THEN
                  BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                            ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                            ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                              ||' - '|| vr_glb_cdprogra ||' --> '
                                                              ||'Erro execucao - '
                                                              || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                              || 'Mensagem: CabInfSituacao - Rejeicao '
                                                              || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                            ,pr_nmarqlog      => vr_logprogr
                                            ,pr_cdprograma    => vr_glb_cdprogra
                                            ,pr_dstiplog      => 'E'
                                            ,pr_tpexecucao    => 3
                                            ,pr_cdcriticidade => 0
                                            ,pr_flgsucesso    => 1
                                            ,pr_cdmensagem    => vr_cdcritic);
                  RAISE vr_exc_saida;
                END IF;
                pc_trata_lancamentos(pr_dscritic  => vr_dscritic);
                -- Tratar erro na chamada da gera log SPB
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              ELSIF vr_aux_tagCABInfCCL THEN
                -- Rejeitada pela Cabine Vem com mesmo CodMsg da mensagem gerada pela cooperativa
                --
                -- Marcelo Telles Coelho - Projeto 475
                -- Gerar registro de rastreio de mensagens
                --
                IF vr_aux_CodMsg = 'GEN0004' THEN
                  vr_trace_cdfase     := 43; -- Retorno Câmara - GEN0004
                  vr_trace_nmmensagem := 'GEN0004';
                ELSE
                  vr_trace_cdfase     := 43; -- Rejeição automática - Cancelamento
                  IF vr_aux_CodMsg LIKE '%E' THEN
                    vr_trace_nmmensagem := vr_aux_CodMsg;
                  ELSE
                    vr_trace_nmmensagem := 'CABInfCancelamento';
                  END IF;
                END IF;
                --
                SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_trace_cdfase
                                            ,pr_idorigem               => NULL
                                            ,pr_nmmensagem             => vr_trace_nmmensagem
                                            ,pr_nrcontrole             => vr_aux_NumCtrlIF
                                            ,pr_nrcontrole_str_pag     => vr_aux_NumCtrlRem
                                            ,pr_nrcontrole_dev_or      => NULL
                                            ,pr_dhmensagem             => SYSDATE
                                            ,pr_insituacao             => 'OK'
                                            ,pr_dsxml_mensagem         => NULL
                                            ,pr_dsxml_completo         => NULL
                                            ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                            ,pr_cdcooper               => rw_crapcop_mensag.cdcooper
                                            ,pr_nrdconta               => NVL(vr_aux_CtCredtd,vr_aux_CtDebtd)
                                            ,pr_cdproduto              => 30 -- TED
                                            ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                            ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                            ,pr_dscritic               => vr_dscritic
                                            ,pr_des_erro               => vr_des_erro
                                            );
                IF vr_dscritic IS NOT NULL THEN
                  BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                            ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                            ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                              ||' - '|| vr_glb_cdprogra ||' --> '
                                                              ||'Erro execucao - '
                                                              || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                              || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                              || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                            ,pr_nmarqlog      => vr_logprogr
                                            ,pr_cdprograma    => vr_glb_cdprogra
                                            ,pr_dstiplog      => 'E'
                                            ,pr_tpexecucao    => 3
                                            ,pr_cdcriticidade => 0
                                            ,pr_flgsucesso    => 1
                                            ,pr_cdmensagem    => vr_cdcritic);
                  RAISE vr_exc_saida;
                END IF;
                -- FIM projeto 475
                pc_trata_lancamentos(pr_dscritic  => vr_dscritic);
                -- Tratar erro na chamada da gera log SPB
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;
              ELSE /* Demais mensagens CabinfSituacao com alguma inconsistência: *E, Número de controle duplicado, Data de movimento inválida... */
              -- Tratar inconsistência de Dados
              IF vr_aux_CodMsg LIKE '%E' THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                               ,pr_msgderro  => 'Inconsistencia dados: '|| vr_aux_msgderro ||'.');
                END IF;
              END IF;
              ELSE
              --
              -- Marcelo Telles Coelho - Projeto 475
              IF vr_aux_tagCABInfConvertida THEN
                -- Tratar uma conversão de mensagem no JD
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'CONVERTIDA OK'
                               ,pr_msgderro  => 'Inconsistencia dados: '|| vr_aux_msgderro ||'.');
                --
                -- Marcelo Telles Coelho - Projeto 475
                -- Gerar registro de rastreio de mensagens
                SSPB0003.pc_grava_trace_spb (pr_cdfase                 => 50 -- Retorno de ação manual na cabine - Conversão de código de mensagem
                                            ,pr_idorigem               => NULL
                                            ,pr_nmmensagem             => 'Conversao MSG'
                                            ,pr_nrcontrole             => vr_aux_NumCtrlIF
                                            ,pr_nrcontrole_str_pag     => vr_aux_NumCtrlRem
                                            ,pr_nrcontrole_dev_or      => NULL
                                            ,pr_dhmensagem             => SYSDATE
                                            ,pr_insituacao             => 'OK'
                                            ,pr_dsxml_mensagem         => NULL
                                            ,pr_dsxml_completo         => NULL
                                            ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                            ,pr_cdcooper               => rw_crapcop_mensag.cdcooper
                                            ,pr_nrdconta               => NVL(vr_aux_CtCredtd,vr_aux_CtDebtd)
                                            ,pr_cdproduto              => 30 -- TED
                                            ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                            ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                            ,pr_dscritic               => vr_dscritic
                                            ,pr_des_erro               => vr_des_erro
                                            );
                IF vr_dscritic IS NOT NULL THEN
                  BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                            ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                            ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                              ||' - '|| vr_glb_cdprogra ||' --> '
                                                              ||'Erro execucao - '
                                                              || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                              || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                              || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                            ,pr_nmarqlog      => vr_logprogr
                                            ,pr_cdprograma    => vr_glb_cdprogra
                                            ,pr_dstiplog      => 'E'
                                            ,pr_tpexecucao    => 3
                                            ,pr_cdcriticidade => 0
                                            ,pr_flgsucesso    => 1
                                            ,pr_cdmensagem    => vr_cdcritic);
                  RAISE vr_exc_saida;
                END IF;
              ELSIF vr_aux_CabInf_reenvio THEN
                --
                SSPB0003.pc_grava_trace_spb (pr_cdfase                 => 45 -- Confirmação recebimento JD / rejeição automática
                                            ,pr_idorigem               => NULL
                                            ,pr_nmmensagem             => 'Retorno JD Duplic.'
                                            ,pr_nrcontrole             => vr_aux_NumCtrlIF
                                            ,pr_nrcontrole_str_pag     => vr_aux_NumCtrlRem
                                            ,pr_nrcontrole_dev_or      => NULL
                                            ,pr_dhmensagem             => SYSDATE
                                            ,pr_insituacao             => 'NOK'
                                            ,pr_dsxml_mensagem         => NULL
                                            ,pr_dsxml_completo         => NULL
                                            ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                            ,pr_cdcooper               => rw_crapcop_mensag.cdcooper
                                            ,pr_nrdconta               => NVL(vr_aux_CtCredtd,vr_aux_CtDebtd)
                                            ,pr_cdproduto              => 30 -- TED
                                            ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                            ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                            ,pr_dscritic               => vr_dscritic
                                            ,pr_des_erro               => vr_des_erro
                                            );
                IF vr_dscritic IS NOT NULL THEN
                  BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                            ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                            ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                              ||' - '|| vr_glb_cdprogra ||' --> '
                                                              ||'Erro execucao - '
                                                              || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                              || 'Mensagem: CabInfSituacao - Rejeicao '
                                                              || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                            ,pr_nmarqlog      => vr_logprogr
                                            ,pr_cdprograma    => vr_glb_cdprogra
                                            ,pr_dstiplog      => 'E'
                                            ,pr_tpexecucao    => 3
                                            ,pr_cdcriticidade => 0
                                            ,pr_flgsucesso    => 1
                                            ,pr_cdmensagem    => vr_cdcritic);
                  RAISE vr_exc_saida;
              END IF;
            ELSE
              -- Gera LOG SPB
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO JD OK'
                             ,pr_msgderro  => NULL);
                --
                -- Marcelo Telles Coelho - Projeto 475
                -- Gerar registro de rastreio de mensagens
                SSPB0003.pc_grava_trace_spb (pr_cdfase                 => 40 -- Confirmação recebimento JD / rejeição automática
                                            ,pr_idorigem               => NULL
                                            ,pr_nmmensagem             => 'Retorno JD'
                                            ,pr_nrcontrole             => vr_aux_NumCtrlIF
                                            ,pr_nrcontrole_str_pag     => vr_aux_NumCtrlRem
                                            ,pr_nrcontrole_dev_or      => NULL
                                            ,pr_dhmensagem             => SYSDATE
                                            ,pr_insituacao             => 'OK'
                                            ,pr_dsxml_mensagem         => NULL
                                            ,pr_dsxml_completo         => NULL
                                            ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                            ,pr_cdcooper               => rw_crapcop_mensag.cdcooper
                                            ,pr_nrdconta               => NVL(vr_aux_CtCredtd,vr_aux_CtDebtd)
                                            ,pr_cdproduto              => 30 -- TED
                                            ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                            ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                            ,pr_dscritic               => vr_dscritic
                                            ,pr_des_erro               => vr_des_erro
                                            );
                IF vr_dscritic IS NOT NULL THEN
                  BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                            ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                            ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                              ||' - '|| vr_glb_cdprogra ||' --> '
                                                              ||'Erro execucao - '
                                                              || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                              || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                              || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                            ,pr_nmarqlog      => vr_logprogr
                                            ,pr_cdprograma    => vr_glb_cdprogra
                                            ,pr_dstiplog      => 'E'
                                            ,pr_tpexecucao    => 3
                                            ,pr_cdcriticidade => 0
                                            ,pr_flgsucesso    => 1
                                            ,pr_cdmensagem    => vr_cdcritic);
                  RAISE vr_exc_saida;
            END IF;
              END IF;
              -- FIM projeto 475
              --
            END IF;
            -- Tratar erro na chamada da gera log SPB
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          ELSE -- Se não encontrou
            CLOSE cr_busca_coop;
            pc_trata_cecred (pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4)
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;
          -- Salvar o arquivo
          RAISE vr_exc_next;
        END IF;
        -- Verifica as Mensagens de Recebimento
        IF NVL(vr_aux_CodMsg,'Sem <CodMsg>') -- Marcelo Telles Coelho - Projeto 475
                         NOT IN('PAG0101'                                       -- Situacao IF
                               ,'STR0018','STR0019'                             -- Exclusao/Inclusao IF
                               ,'STR0005R2','STR0007R2','STR0008R2','PAG0107R2'
                               ,'STR0025R2','PAG0121R2'                         -- Transferencia Judicial - Andrino
                               ,'LTR0005R2'                                     -- Antecipaçao de Recebíveis - LTR - Mauricio
                               ,'LDL0020R2'                                     -- Alexandre - Mouts
                               ,'LTR0004'                                       -- Gerada na cabine, mas necessário tratá-la no recebimento                               
                                                                  -- 'LDL0022', -- Mensagem retirada, pois ela é enviada da cabine e não recebida pelo ailos - Projeto 475
                               ,'SLC0001','SLC0005'                             -- Requisição de Transferência de cliente para IF - Mauricio
                               ,'LDL0024'                                       -- Aviso Alteração Horários Câmara LDL - Alexandre Borgmann - Mouts
                               ,'STR0006R2'                                     -- Cielo finalidade 15 gravar e não gerar STR0010 - Alexandre Borgmann - Mouts
                               ,'STR0004R2'                                     -- Rede  ISPBIFDebtd=00000000 (BCO DO BRASIL S.A.) e FinlddIF=23 (Transferência de Recursos - REDECARD – 23)
                               ,'PAG0108R2','PAG0143R2'                         -- TED
                               ,'STR0037R2','PAG0137R2'                         -- TEC
                               ,'STR0010R2','PAG0111R2'                         -- Devolucao TED/TEC enviado com erro
                               ,'STR0003R2'                                     -- Liquidacao de transferencia de numerarios
                               ,'STR0004R1','STR0005R1','STR0008R1','STR0037R1'
                               ,'PAG0107R1','PAG0108R1','PAG0137R1'             -- Confirma envio
                               ,'STR0010R1','PAG0111R1'                         -- Confirma devolucao enviada
                               ,'STR0007R1'                                     -- Incluida pelo Projeto 475 - Ficou de fora quando foi tratado a STR0007R2
                               ,'STR0026R2'                                     -- Recebimento VR Boleto
                               ,'CIR0020'                                       -- Pagamento de Lançamento Devido MECIR /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
                               ,'CIR0021'                                       -- Lançamento a Crédito Efetivado do MECIR /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
                               ,'CIR0060'                                       -- Destinado ao Mecir informar remessas em atraso - Sprint D Req 51
                               ,'STR0047R1','STR0048R1','STR0047R2') THEN       -- Portabilidade de Credito
          -- Marcelo Telles Coelho - Projeto 475
          -- Devolver crítica de processo em curso para o Barramento SOA
          IF  NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'STR%'
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'PAG%'
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'LDL%' -- Sprint D
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'SEL%' -- Sprint D          
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'SLB%' -- Sprint D 
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'RDC%'         
          THEN
          -- Se o processo estiver rodando
          IF NOT fn_verifica_processo THEN
            -- Arquivo será ignorado
            RAISE vr_exc_next;
          END IF;
          END IF;
          -- Fim Projeto 475
          
          -- Sprint D - Req19
          -- Chamada para procedure para armazenar as informações para o Arquivo Contabil
          IF vr_aux_CodMsg IN ('LDL0022','RDC0002','RDC0007','SEL1069','SLB0002'
                              ,'STR0003','STR0004','STR0020' ,'STR0007') THEN
            vr_aux_valor_char := replace(Nvl(vr_aux_DsVlrFinanc, vr_aux_DsVlrLanc),'.',',');        
            vr_aux_valor := To_Number(vr_aux_valor_char);
            --
            SSPB0001.pc_grava_arquivo_contabil (pr_nmmsg => vr_aux_CodMsg
                                      ,pr_nmmsg_dev => null
                                      ,pr_dtarquivo => To_date(Nvl(vr_aux_DtAgendt, vr_aux_DtMovto),'RRRR-MM-DD')
                                      ,pr_vlrmsg    => vr_aux_valor
                                      ,pr_FinlddIF  => vr_aux_FinlddIF
                                      ,pr_FinlddCli => vr_aux_FinlddCli
                                      ,pr_NomCliCredtd => vr_aux_NomCliCredtd
                                      ,pr_CodProdt     => vr_aux_CodProdt
                                      ,pr_SubTpAtv     => vr_aux_SubTpAtv
                                      ,pr_CtCredtd     => vr_aux_CtCredtd
                                      ,pr_CtDebtd      => vr_aux_CtDebtd
                                      ,pr_CNPJ_CPFCliCredtd => vr_aux_CNPJ_CPFCred
                                      ,pr_CtCed        => vr_aux_CtCed
                                      ,pr_NumCtrlSTROr => vr_aux_NumCtrlRem_Or  
                                      ,pr_NumCtrlIF    => vr_aux_NumCtrlIF
                                      ,pr_NumCtrlRem   => vr_aux_NumCtrlRem
                                      ,pr_his          => vr_aux_Hist
                                      ,pr_dscritic     => vr_dscritic);
          END IF;
          --
          IF vr_dscritic IS NOT NULL THEN
            --
            cecred.pc_log_programa
              (pr_dstiplog => 'O', -- tbgen_prglog DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
              pr_cdprograma => vr_glb_cdprogra, -- tbgen_prglog
              pr_cdcooper => pr_cdcooper, -- tbgen_prglog
              pr_tpexecucao => 1, -- tbgen_prglog DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
              pr_tpocorrencia => 1, -- tbgen_prglog_ocorrencia -- 1 ERRO TRATADO
              pr_cdcriticidade => 0, -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
              pr_dsmensagem => vr_dscritic, -- tbgen_prglog_ocorrencia
              pr_flgsucesso => 1, -- tbgen_prglog DEFAULT 1 -- Indicador de sucesso da execução
              pr_nmarqlog => NULL,
              pr_idprglog => vr_idprglog); 
              vr_dscritic := null;
              --    
          END IF;
          -- Fim Sprint D
          
          
          --
          -- Marcelo Telles Coelho - Projeto 475
          -- Gerar registro de rastreio de mensagens
          DECLARE
            vr_lixo   NUMBER;
          BEGIN
            BEGIN
              IF NVL(vr_aux_CodMsg,'Sem <CodMsg>') LIKE '%R1' THEN
                IF vr_aux_SitLanc in ('1'   -- Efetivado
                                     ,'2'   -- Efetivado - Contingência/STR Web
                                     ,'3'   -- Efetivado - Otimização
                                     ,'COM' -- Aprovado
                                     ,'APR' -- Aprovado
                                     ,'ATU' -- Efetivada
                                     ) THEN
                  vr_trace_cdfase   := 55; -- Retorno Câmara - R1
                  vr_trace_idorigem := 'E';
                ELSIF vr_aux_SitLanc in ('18'  -- Pendente por agendamento
                                        ,'AGE' -- Agendado
                                        ,'ENF' -- Pendente à Espera de Execução do Algoritmo Multilateral
                                        ,'CON' -- Pendente
                                        ,'AGU' -- Aguardando processamento
                                        ) THEN
                  vr_trace_cdfase   := 56; -- Retorno Câmara - R1
                  vr_trace_idorigem := 'E';
                ELSIF vr_aux_SitLanc = 'EXP' THEN -- Expirada
                  vr_trace_cdfase   := 60; -- Cancelada /* Sprint D */
                  vr_trace_idorigem := 'E';
                ELSE
                  vr_trace_cdfase   := 57; -- Retorno Câmara - R1
                  vr_trace_idorigem := 'E';
                END IF;
                vr_trace_nrdconta := NVL(vr_aux_CtDebtd,vr_aux_CtCredtd);
              ELSE
                IF vr_aux_CodMsg IN ('LDL0021','SLB0001','CMP0002','CMP0004') THEN
                  IF vr_aux_CodMsg = 'CMP0004' THEN
                    vr_aux_NumCtrlIF := NULL;
                  END IF;
                  vr_trace_cdfase   := 999; -- Mensagens não tratadas
                  vr_trace_idorigem := 'R';
                  vr_trace_nrdconta := vr_aux_CtCredtd;
                ELSE
                  vr_lixo           := TO_NUMBER(SUBSTR(NVL(vr_aux_NumCtrlIF,'1'),1,1));
                  --
                  vr_trace_cdfase   := 999; -- Mensagens não tratadas
                  vr_trace_idorigem := 'R';
                  vr_trace_nrdconta := vr_aux_CtCredtd;
                END IF;
              END IF;
            EXCEPTION
            WHEN OTHERS THEN
              IF vr_aux_CodMsg IS NULL THEN
                vr_trace_cdfase   := 999; -- Mensagens não tratadas
                vr_trace_idorigem := 'R';
                vr_trace_nrdconta := vr_aux_CtCredtd;
              ELSE
                vr_trace_cdfase   := 15; -- Criação de mensagem no JD
                vr_trace_idorigem := 'E';
                vr_trace_nrdconta := vr_aux_CtDebtd;
                --
                IF rw_crapcop_mensag.cdcooper IS NULL THEN
                  -- Tenta converter agencia para numero
                  IF NOT fn_numerico(vr_aux_AgDebtd) THEN
                    vr_aux_flgderro := TRUE;
                  END IF;
                  -- Se não deu erro
                  IF NOT vr_aux_flgderro THEN
                    -- Busca dados da Coope por cdagectl
                    OPEN cr_busca_coop(pr_cdagectl => vr_aux_AgDebtd
                                      ,pr_flgativo => 1);
                    FETCH cr_busca_coop INTO rw_crapcop_MSG;
                    CLOSE cr_busca_coop;
                  END IF;
                ELSE
                  rw_crapcop_MSG.cdcooper := rw_crapcop_mensag.cdcooper;
                END IF;
              END IF;
            END;
            --
            IF vr_aux_DtHrBC IS NOT NULL THEN
              vr_trace_dhdthr_bc := TO_DATE(SUBSTR(vr_aux_DtHrBC,1,10)||' '||SUBSTR(vr_aux_DtHrBC,12,8),'yyyy-mm-dd hh24:mi:ss');
            END IF;
            -- Gerar registro de rastreio de mensagens
            SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_trace_cdfase
                                        ,pr_idorigem               => vr_trace_idorigem
                                        ,pr_nmmensagem             => NVL(vr_aux_CodMsg,'Sem <CodMsg>')
                                        ,pr_nrcontrole             => NVL(vr_aux_NumCtrlIF,vr_aux_NumCtrlRem)
                                        ,pr_nrcontrole_str_pag     => vr_aux_NumCtrlRem
                                        ,pr_nrcontrole_dev_or      => NULL
                                        ,pr_dhmensagem             => SYSDATE
                                        ,pc_dhdthr_bc              => vr_trace_dhdthr_bc
                                        ,pr_insituacao             => 'OK'
                                        ,pr_dsxml_mensagem         => NULL
                                        ,pr_dsxml_completo         => NULL
                                        ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                        ,pr_cdcooper               => rw_crapcop_MSG.cdcooper
                                        ,pr_nrdconta               => vr_trace_nrdconta
                                        ,pr_cdproduto              => 30 -- TED
                                        ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                        ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                        ,pr_dscritic               => vr_dscritic
                                        ,pr_des_erro               => vr_des_erro
                                        );
            IF vr_dscritic IS NOT NULL THEN
              BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                        ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                        ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                          ||' - '|| vr_glb_cdprogra ||' --> '
                                                          ||'Erro execucao - '
                                                          || 'Nr.Controle IF: ' || NVL(vr_aux_NumCtrlIF,vr_aux_NumCtrlRem) || ' '
                                                          || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                          || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                        ,pr_nmarqlog      => vr_logprogr
                                        ,pr_cdprograma    => vr_glb_cdprogra
                                        ,pr_dstiplog      => 'E'
                                        ,pr_tpexecucao    => 3
                                        ,pr_cdcriticidade => 0
                                        ,pr_flgsucesso    => 1
                                        ,pr_cdmensagem    => vr_cdcritic);
              RAISE vr_exc_saida;
            END IF;
          END;
          -- FIM projeto 475
          --
          -- Mensagem nao tratada pelo sistema CECRED e devemos enviar uma mensagem STR0010 como resposta. SD 553778
          IF vr_aux_CodMsg IN('PAG0142R2','STR0034R2','PAG0134R2') THEN
            -- Buscar Coop destino
            rw_crapcop_mensag := NULL;
            OPEN cr_busca_coop(pr_cdagectl => vr_aux_AgCredtd);
            FETCH cr_busca_coop
             INTO rw_crapcop_mensag;
            CLOSE cr_busca_coop;
            -- Mensagem Invalida para o Tipo de Transacao ou Finalidade
            vr_log_msgderro := 'Mensagem Invalida para o Tipo de Transacao ou Finalidade.';
            -- Gerar XML de erro
            pc_gera_erro_xml(pr_dsdehist => 'Mensagem Invalida para o Tipo de Transacao ou Finalidade.'
                            ,pr_codierro => 4
                            ,pr_dscritic => vr_dscritic);
          ELSE
            -- Tratamento Cecred
            pc_trata_cecred (pr_cdagectl => NULL
                            ,pr_dscritic => vr_dscritic);
          END IF;
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            -- Incrementar o LOG
            vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          -- Processo finalizado
          RAISE vr_exc_next;
        ELSE
          -- Sprint D - Req19
          -- Chamada para procedure para armazenar as informações para o Arquivo Contabil
          IF vr_aux_CodMsg in ('LDL0020R2','LTR0004','STR0003R2','LTR0005R2','STR0004R2',
                               'STR0006R2','STR0008R2') THEN
            vr_aux_valor_char := replace(Nvl(vr_aux_DsVlrFinanc, vr_aux_DsVlrLanc),'.',',');        
            vr_aux_valor := To_Number(vr_aux_valor_char);
            --
            SSPB0001.pc_grava_arquivo_contabil (pr_nmmsg => vr_aux_CodMsg
                                      ,pr_nmmsg_dev => null
                                      ,pr_dtarquivo => To_date(Nvl(vr_aux_DtAgendt, vr_aux_DtMovto),'RRRR-MM-DD')
                                      ,pr_vlrmsg    => vr_aux_valor
                                      ,pr_FinlddIF  => vr_aux_FinlddIF
                                      ,pr_FinlddCli => vr_aux_FinlddCli
                                      ,pr_NomCliCredtd => vr_aux_NomCliCredtd
                                      ,pr_CodProdt     => vr_aux_CodProdt
                                      ,pr_SubTpAtv     => vr_aux_SubTpAtv
                                      ,pr_CtCredtd     => vr_aux_CtCredtd
                                      ,pr_CtDebtd      => vr_aux_CtDebtd
                                      ,pr_CNPJ_CPFCliCredtd => vr_aux_CNPJ_CPFCred
                                      ,pr_CtCed        => vr_aux_CtCed
                                      ,pr_NumCtrlSTROr => vr_aux_NumCtrlRem_Or  
                                      ,pr_NumCtrlIF    => vr_aux_NumCtrlIF
                                      ,pr_NumCtrlRem   => vr_aux_NumCtrlRem
                                      ,pr_his          => vr_aux_Hist
                                      ,pr_dscritic     => vr_dscritic);
          END IF;
          --
          IF vr_dscritic IS NOT NULL THEN
            --
            cecred.pc_log_programa
              (pr_dstiplog => 'O', -- tbgen_prglog DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
              pr_cdprograma => vr_glb_cdprogra, -- tbgen_prglog
              pr_cdcooper => pr_cdcooper, -- tbgen_prglog
              pr_tpexecucao => 1, -- tbgen_prglog DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
              pr_tpocorrencia => 1, -- tbgen_prglog_ocorrencia -- 1 ERRO TRATADO
              pr_cdcriticidade => 0, -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
              pr_dsmensagem => vr_dscritic, -- tbgen_prglog_ocorrencia
              pr_flgsucesso => 1, -- tbgen_prglog DEFAULT 1 -- Indicador de sucesso da execução
              pr_nmarqlog => NULL,
              pr_idprglog => vr_idprglog); 
              vr_dscritic := null;
              --    
          END IF;
          -- Fim Sprint D
          
          -- Marcelo Telles Coelho - Projeto 475
          -- Buscar Cooperativa da mensagem
          IF rw_crapcop_mensag.cdcooper IS NULL THEN
            -- Tenta converter agencia para numero
            IF NOT fn_numerico(vr_aux_AgCredtd) THEN
              vr_aux_flgderro := TRUE;
            END IF;
            -- Se não deu erro
            IF NOT vr_aux_flgderro THEN
              -- Busca dados da Coope por cdagectl
              OPEN cr_busca_coop(pr_cdagectl => vr_aux_AgCredtd
                                ,pr_flgativo => 1);
              FETCH cr_busca_coop INTO rw_crapcop_MSG;
              CLOSE cr_busca_coop;
            END IF;
          ELSE
            rw_crapcop_MSG.cdcooper := rw_crapcop_mensag.cdcooper;
          END IF;
          --
          -- Buscar conta da mensagem
          vr_aux_nrdconta := NULL;
          --
          IF NVL(vr_aux_CtCredtd,vr_aux_CtDebtd) IS NULL THEN
            IF vr_aux_NumCodBarras IS NOT NULL THEN
              vr_aux_nrdconta := SUBSTR(vr_aux_NumCodBarras, 26, 8);
            END IF;
          ELSE
            vr_aux_nrdconta := NVL(vr_aux_CtCredtd,vr_aux_CtDebtd);
          END IF;
          --
          -- Gerar registro de rastreio de mensagens
          vr_trace_nrcontrole_if      := NVL(vr_aux_NumCtrlIF,vr_aux_NumCtrlRem);
          vr_trace_nrcontrole_str_pag := vr_aux_NumCtrlRem;
          vr_trace_nrcontrole_dev     := NULL;
          --
          IF vr_aux_CodMsg like '%R1' THEN
            IF vr_aux_SitLanc in ('1'   -- Efetivado
                                 ,'2'   -- Efetivado - Contingência/STR Web
                                 ,'3'   -- Efetivado - Otimização
                                 ,'COM' -- Aprovado
                                 ,'APR' -- Aprovado
                                 ,'ATU' -- Efetivada
                                 ) THEN
              vr_trace_cdfase   := 55; -- Retorno Câmara - R1
              vr_trace_idorigem := 'E';
            ELSIF vr_aux_SitLanc in ('18'  -- Pendente por agendamento
                                    ,'AGE' -- Agendado
                                    ,'ENF' -- Pendente à Espera de Execução do Algoritmo Multilateral
                                    ,'CON' -- Pendente
                                    ,'AGU' -- Aguardando processamento
                                    ) THEN
              vr_trace_cdfase   := 56; -- Retorno Câmara - R1
              vr_trace_idorigem := 'E';
            ELSIF vr_aux_SitLanc = 'EXP' THEN -- Expirada
              vr_trace_cdfase   := 60; -- Cancelada /* Sprint D */
              vr_trace_idorigem := 'E';
            ELSE
              vr_trace_cdfase   := 57; -- Retorno Câmara - R1
              vr_trace_idorigem := 'E';
            END IF;
          ELSIF  vr_aux_CodMsg    LIKE '%R2' THEN
            vr_trace_cdfase             := 115; -- Mensagem de crédito recebida pelo Ailos - R2
            vr_trace_idorigem           := 'R';
            vr_trace_nrcontrole_if      := NULL;
            vr_trace_nrcontrole_str_pag := vr_aux_NumCtrlRem;
            vr_trace_nrcontrole_dev     := vr_aux_NumCtrlIF;
            --
            IF vr_aux_CodDevTransf IS NOT NULL THEN
              -- Projeto 475 Sprint C Req04
              -- Buscar a cooperativa e conta da mensagem original
              IF rw_crapcop_MSG.cdcooper IS NULL THEN
                OPEN cr_tbspbmsgenv_coop(vr_aux_NumCtrlIF);
                FETCH cr_tbspbmsgenv_coop INTO rw_tbspbmsgenv_coop;
                -- Se não encontrar
                IF cr_tbspbmsgenv_coop%NOTFOUND THEN
                   CLOSE cr_tbspbmsgenv_coop;
                   -- Não tratar
                ELSE
                   CLOSE cr_tbspbmsgenv_coop;                    
                   rw_crapcop_MSG.cdcooper:= rw_tbspbmsgenv_coop.cdcooper;
                   vr_aux_nrdconta:= rw_tbspbmsgenv_coop.nrdconta;
                END IF;   
              END IF;
              -- Fim 475            
            
              -- Mensagem de devolução deve ser salva junto ao TED na TBSPB_MSG_ENVIADA_FASE
              SSPB0003.pc_grava_trace_spb (pr_cdfase                 => 60 -- Cancelamento de mensagem na IF destino - R2
                                          ,pr_idorigem               => 'E'
                                          ,pr_nmmensagem             => vr_aux_CodMsg
                                          ,pr_nrcontrole             => vr_aux_NumCtrlIF
                                          ,pr_nrcontrole_str_pag     => NULL
                                          ,pr_nrcontrole_dev_or      => vr_aux_NumCtrlRem
                                          ,pr_dhmensagem             => SYSDATE
                                          ,pc_dhdthr_bc              => vr_trace_dhdthr_bc
                                          ,pr_insituacao             => 'OK'
                                          ,pr_dsxml_mensagem         => NULL
                                          ,pr_dsxml_completo         => NULL
                                          ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                          ,pr_cdcooper               => rw_crapcop_MSG.cdcooper
                                          ,pr_nrdconta               => vr_aux_nrdconta
                                          ,pr_cdproduto              => 30 -- TED
                                          ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                          ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                          ,pr_dscritic               => vr_dscritic
                                          ,pr_des_erro               => vr_des_erro
                                          );
              IF vr_dscritic IS NOT NULL THEN
                BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                          ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                          ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                            ||' - '|| vr_glb_cdprogra ||' --> '
                                                            ||'Erro execucao - '
                                                            || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                            || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                            || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                          ,pr_nmarqlog      => vr_logprogr
                                          ,pr_cdprograma    => vr_glb_cdprogra
                                          ,pr_dstiplog      => 'E'
                                          ,pr_tpexecucao    => 3
                                          ,pr_cdcriticidade => 0
                                          ,pr_flgsucesso    => 1
                                          ,pr_cdmensagem    => vr_cdcritic);
                RAISE vr_exc_saida;
              END IF;
            END IF;
          ELSIF vr_aux_CodMsg IN('STR0010','PAG0111','STR0048') THEN
            vr_trace_cdfase   := 70; -- Rejeitada pela cabine
            vr_trace_idorigem := 'E';
          ELSIF vr_aux_CodMsg IN('LTR0004') THEN
            vr_trace_cdfase   := 15; -- Demais mensagens tratadas
            vr_trace_idorigem := 'E';
          ELSE
            vr_trace_cdfase   := 992; -- Demais mensagens tratadas
            IF vr_aux_CodMsg = 'CIR0020' then -- Sprint D 
              vr_trace_idorigem := 'E';
            Else  
              vr_trace_idorigem := 'R';
            END IF;  
          END IF;
          --
          IF vr_trace_cdfase IS NOT NULL THEN
            vr_trace_dhdthr_bc := NULL;
            --
            IF vr_aux_DtHrBC IS NOT NULL THEN
              vr_trace_dhdthr_bc := TO_DATE(SUBSTR(vr_aux_DtHrBC,1,10)||' '||SUBSTR(vr_aux_DtHrBC,12,8),'yyyy-mm-dd hh24:mi:ss');
            END IF;
            -- Gerar registro de rastreio de mensagens
            SSPB0003.pc_grava_trace_spb (pr_cdfase                 => vr_trace_cdfase
                                        ,pr_idorigem               => vr_trace_idorigem
                                        ,pr_nmmensagem             => vr_aux_CodMsg
                                        ,pr_nrcontrole             => vr_trace_nrcontrole_if
                                        ,pr_nrcontrole_str_pag     => vr_trace_nrcontrole_str_pag
                                        ,pr_nrcontrole_dev_or      => vr_trace_nrcontrole_dev
                                        ,pr_dhmensagem             => SYSDATE
                                        ,pc_dhdthr_bc              => vr_trace_dhdthr_bc
                                        ,pr_insituacao             => 'OK'
                                        ,pr_dsxml_mensagem         => NULL
                                        ,pr_dsxml_completo         => NULL
                                        ,pr_nrseq_mensagem_xml     => vr_nrseq_mensagem_xml
                                        ,pr_cdcooper               => rw_crapcop_MSG.cdcooper
                                        ,pr_nrdconta               => vr_aux_nrdconta
                                        ,pr_cdproduto              => 30 -- TED
                                        ,pr_nrseq_mensagem         => vr_nrseq_mensagem
                                        ,pr_nrseq_mensagem_fase    => vr_nrseq_mensagem_fase
                                        ,pr_dscritic               => vr_dscritic
                                        ,pr_des_erro               => vr_des_erro
                                        );
            IF vr_dscritic IS NOT NULL THEN
              BTCH0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper
                                        ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                        ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')
                                                          ||' - '|| vr_glb_cdprogra ||' --> '
                                                          ||'Erro execucao - '
                                                          || 'Nr.Controle IF: ' || vr_trace_nrcontrole_if || ' '
                                                          || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                          || 'Na Rotina PC_CRPS531_1 --> '||vr_dscritic
                                        ,pr_nmarqlog      => vr_logprogr
                                        ,pr_cdprograma    => vr_glb_cdprogra
                                        ,pr_dstiplog      => 'E'
                                        ,pr_tpexecucao    => 3
                                        ,pr_cdcriticidade => 0
                                        ,pr_flgsucesso    => 1
                                        ,pr_cdmensagem    => vr_cdcritic);
              RAISE vr_exc_saida;
            END IF;
          END IF;
          -- FIM projeto 475
        END IF;

        -- Transferencia Judicial - Andrino
        IF vr_aux_CodMsg IN('STR0025R2','PAG0121R2') THEN
          -- Enviar mensagem STR0010 e PAG0111
          pc_gera_erro_xml(pr_dsdehist => 'IF nao autorizada a receber esse tipo de operacao.'
                          ,pr_codierro => 4
                          ,pr_dscritic => vr_dscritic);
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            -- Incrementar o LOG
            vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;
          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;

    -- Antecipaçao de Recebíveis - LTR - Mauricio
    IF vr_aux_CodMsg in ('LTR0005R2','STR0006R2','LTR0005R2',
                         'LDL0020R2','LTR0004'
                         ,'STR0004R2'  -- Mensagem incluida no IF - Projeto 475
                         -- 'LDL0022', -- Mensagem retirada, pois ela é enviada da cabine e não recebida pelo ailos - Projeto 475
                         )
                         THEN
			  IF vr_aux_CodMsg = 'STR0006R2' and (vr_aux_FinlddCli <> '15'
                  /* OR (vr_aux_CNPJ_CPFDeb<>'01027058000191' and vr_aux_CNPJ_CPFDeb<>'1027058000191') removido solicitado por Lombardi a pedido de Jonathan Hasse*/
				  ) THEN
           -- Se conta 10000003 ou 20000006 e Agencia 100, entao é
           -- TED recebida de boleto pago em cartório
           IF TRIM(vr_aux_CtCredtd) IN ('10000003','20000006') AND
              vr_aux_AgCredtd = '100'               THEN
               NULL;
           ELSE  
			     -- Busca dados da Coope destino
           OPEN cr_busca_coop(pr_cdagectl => vr_aux_AgCredtd);
           FETCH cr_busca_coop INTO rw_crapcop_mensag;
           CLOSE cr_busca_coop;
		     
            /* Mensagem Invalida para o Tipo de Transacao ou Finalidade*/
            vr_aux_codierro := 4;
            vr_aux_dsdehist := 'Mensagem Invalida para o Tipo de Transacao ou Finalidade.';
            vr_log_msgderro := vr_aux_dsdehist;

            pc_gera_erro_xml(vr_aux_dsdehist
                            ,vr_aux_codierro
                            ,vr_dscritic);

            RAISE vr_exc_next;
            END IF;
          -- Marcelo Telles Coelho - Projeto 475
          -- Gerar LOGSPB para mensagem STR004R2
        ELSIF vr_aux_CodMsg = 'STR0004R2' and (vr_aux_FinlddIF <> '23' OR vr_aux_ISPBIFDebtd<>'60701190') THEN

            pc_gera_log_SPB(pr_tipodlog  => 'REJEITADA OK'
                           ,pr_msgderro  => 'Mensagem nao prevista');

            RAISE vr_exc_next;
        ELSE
          ccrd0006.pc_insere_msg_ltr_str(vr_aux_VlrLanc
                                ,vr_aux_CodMsg
                                ,vr_aux_NumCtrlLTR
                                ,vr_aux_NumCtrlSTR
                                ,vr_aux_ISPBLTR
                                ,vr_aux_ISPBIFDebtd
                                ,vr_aux_ISPBIFCredtd
                                ,vr_aux_CNPJNLiqdant
                                ,vr_aux_IdentdPartCamr
                                ,vr_aux_AgCredtd
                                ,vr_aux_CtCredtd
                                ,vr_aux_AgDebtd
                                ,CASE WHEN vr_aux_CodMsg IN ('STR0004R2','STR0006R2') THEN NULL
                                                                                      ELSE vr_aux_Hist END
                                ,vr_aux_FinlddIF
                                ,vr_aux_TpPessoaDebtd_Remet
                                ,vr_aux_CNPJ_CPFDeb
                                ,vr_aux_NomCliDebtd
                                ,vr_aux_FinlddCli
                                ,vr_aux_DtHrBC
                                ,vr_aux_DtMovto
                                ,vr_dscritic);
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
             -- Incrementar o LOG
             vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
             RAISE vr_exc_saida;
          END IF;
          -- Processo finalizado

          RAISE vr_exc_next;
       END IF;
   END IF;
   
        -- Sprint D - Retirada a geração de e-mail (STR0003R2, CIR0020) de dentro da rotina pc_trata_lancamentos
        -- Troca de numerarios - CECRED        
        IF vr_aux_CodMsg = 'STR0003R2' THEN
          -- Montar email
          vr_aux_dsdemail := 'Codigo Mensagem: ' || vr_aux_CodMsg || ' <br>'
                          || 'Numero controle STR: ' || vr_aux_NumCtrlRem || ' <br>'
                          || 'Data Hora Bacen: ' || vr_aux_DtHrBC || ' <br>'
                          || 'ISPB IF Debitada: ' || vr_aux_ISPBIFDebtd || ' <br>'
                          || 'Agencia Debitada: ' || vr_aux_AgDebtd || ' <br>'
                          || 'ISPB IF Credidata: ' || vr_aux_ISPBIFCredtd || ' <br>'
                          || 'Agencia Creditada: ' || vr_aux_AgCredtd || ' <br>'
                          || 'Valor Lançamento: ' || vr_aux_VlrLanc || ' <br>'
                          || 'Codigo Municipio Origem: ' || vr_aux_CodMunicOrigem || ' <br>'
                          || 'Codigo Municipio Destino: ' || vr_aux_codMunicDest || ' <br>'
                          || 'Data Movimento: ' || vr_aux_DtMovto || ' <br><br>';
          -- Incluir numerarios
          FOR vr_idx IN vr_tab_numerario.first..vr_tab_numerario.last LOOP
            vr_aux_dsdemail := vr_aux_dsdemail
                            || 'Categoria: ' || vr_tab_numerario(vr_idx).cdcatego || ' <br>'
                            || 'Valor Denominacao: ' || vr_tab_numerario(vr_idx).vlrdenom || ' <br> '
                            || 'Quantidade Denominacao: ' || vr_tab_numerario(vr_idx).qtddenom || ' <br>';
          END LOOP;

          -- Enviar Email para o Financeiro
          gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                    ,pr_cdprogra        => vr_glb_cdprogra
                                    ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'EMAIL_CARRO_FORTE')
                                    ,pr_des_assunto     => 'Troca de numerarios - CECRED'
                                    ,pr_des_corpo       => vr_aux_dsdemail
                                    ,pr_des_anexo       => ''
                                    ,pr_flg_enviar      => 'S'
                                    ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                    ,pr_des_erro        => vr_dscritic);
          -- Se ocorreu erro
          IF trim(vr_dscritic) IS NOT NULL THEN
            -- Gerar LOG e continuar o processo normal
            -- Marcelo Telles Coelho - Projeto 475
            -- Padronizar os logs no mesmo arquivo
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                        ||'Erro execucao - '
                                                        || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                        || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                        || ' --> '||vr_dscritic
                                     ,pr_nmarqlog      => vr_nmarqlog);
            -- Limpar critica
            vr_dscritic := null;
          END IF;

          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;
        --
        IF vr_aux_CodMsg = 'CIR0020' THEN /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
          -- Montar email
          vr_aux_dsdemail := 'Codigo Mensagem: ' || vr_aux_CodMsg || ' <br>'
                          || 'Número Controle IF: ' || vr_aux_NumCtrlIF || ' <br>'
                          || 'ISPB IF: ' || vr_aux_ISPBIF || ' <br>'
                          || 'Número Controle CIR Original: ' || vr_aux_NumCtrlCIROr || ' <br>'
                          || 'Valor Lançamento: ' || vr_aux_VlrLanc || ' <br>'
                          || 'Data Movimento: ' || vr_aux_DtMovto || ' <br><br>';

          -- Enviar Email para o Financeiro
          gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                    ,pr_cdprogra        => vr_glb_cdprogra
                                    ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'EMAIL_CARRO_FORTE')
                                    ,pr_des_assunto     => 'Pagamento de Lançamento Devido MECIR - CECRED'
                                    ,pr_des_corpo       => vr_aux_dsdemail
                                    ,pr_des_anexo       => ''
                                    ,pr_flg_enviar      => 'S'
                                    ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                    ,pr_des_erro        => vr_dscritic);
          -- Se ocorreu erro
          IF trim(vr_dscritic) IS NOT NULL THEN
            -- Gerar LOG e continuar o processo normal
            -- Marcelo Telles Coelho - Projeto 475
            -- Padronizar os logs no mesmo arquivo
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                        ||'Erro execucao - '
                                                        || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                        || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                        || ' --> '||vr_dscritic
                                     ,pr_nmarqlog      => vr_nmarqlog);
            -- Limpar critica
            vr_dscritic := null;
          END IF;

          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;
        
        -- Sprint D - Req51 Comunicar equipe responsável pela CIR0060
        IF vr_aux_CodMsg = 'CIR0060' THEN
          -- Montar email
          vr_aux_dsdemail := 'Codigo Mensagem: ' || vr_aux_CodMsg || ' <br>'
                          || 'ISPBIF: ' || vr_aux_ISPBIF || ' <br>'
                          || 'Data Movimento: ' || vr_aux_DtMovto || ' <br><br>';
          -- Incluir remessas
          FOR vr_idx IN vr_tab_numerario_cir0060.first..vr_tab_numerario_cir0060.last LOOP
            vr_aux_dsdemail := vr_aux_dsdemail
                            || 'Numero Remessa: ' || vr_tab_numerario_cir0060(vr_idx).NumRemessa || ' <br>'
                            || 'Data Limite Entrega: ' || vr_tab_numerario_cir0060(vr_idx).DtLimEntr || ' <br> ';
          END LOOP;

          -- Enviar Email para o Financeiro
          gene0003.pc_solicita_email(pr_cdcooper        => rw_crapcop_mensag.cdcooper
                                    ,pr_cdprogra        => vr_glb_cdprogra
                                    ,pr_des_destino     => gene0001.fn_param_sistema('CRED',rw_crapcop_mensag.cdcooper,'EMAIL_CARRO_FORTE')
                                    ,pr_des_assunto     => 'Recebimento CIR0060'
                                    ,pr_des_corpo       => vr_aux_dsdemail
                                    ,pr_des_anexo       => ''
                                    ,pr_flg_enviar      => 'S'
                                    ,pr_flg_log_batch   => 'N' --> Incluir inf. no log
                                    ,pr_des_erro        => vr_dscritic);
          -- Se ocorreu erro
          IF trim(vr_dscritic) IS NOT NULL THEN
            -- Padronizar os logs no mesmo arquivo
            BTCH0001.pc_gera_log_batch(pr_cdcooper      => 3
                                      ,pr_ind_tipo_log => 1
                                      ,pr_des_log       => to_char(sysdate,'dd/mm/yyyy') || ' - ' || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                        ||'Erro execucao - '
                                                        || 'Nr.Controle IF: ' || vr_aux_NumCtrlIF || ' '
                                                        || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                        || ' --> '||vr_dscritic
                                     ,pr_nmarqlog      => vr_nmarqlog);
            -- Limpar critica
            vr_dscritic := null;
          END IF;

          -- Processo finalizado
          RAISE vr_exc_next;

        END IF;
        -- Fim Sprint D        
           
        -- VR Boleto
        IF vr_aux_CodMsg = 'STR0026R2' THEN
          -- Trazer arquivo de log do mqcecred_processa
          vr_nmarqlog := fn_log_mqcecred;
          -- Se nao estiver em estado de crise verifica processo
          IF NOT fn_verifica_processo_crise THEN
            -- Arquivo será ignorado
            RAISE vr_exc_next;
          END IF;

          -- Buscar informações do convênio conforme código de barras
          vr_aux_nrconven := SUBSTR(vr_aux_NumCodBarras, 20, 6);
          vr_aux_nrdconta := SUBSTR(vr_aux_NumCodBarras, 26, 8);
          vr_aux_nrdocmto := SUBSTR(vr_aux_NumCodBarras, 34, 9);

          -- Procurar o convênio relacionado
          OPEN cr_crapcco(pr_nrconven => vr_aux_nrconven);
          FETCH cr_crapcco
           INTO rw_crapcco;
          -- Se não encontrar
          IF cr_crapcco%NOTFOUND THEN
            CLOSE cr_crapcco;
            -- Enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'Convenio do VR Boleto nao encontrado.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE
            CLOSE cr_crapcco;
            -- Posicionar a cooperativa da mensagem (Buffer) igual a Cooperativa encontrada na CCO
            OPEN cr_crapcop(pr_cdcooper => rw_crapcco.cdcooper);
            FETCH cr_crapcop
             INTO rw_crapcop_mensag;
            CLOSE cr_crapcop;
          END IF;
          -- Procurar Boleto
          OPEN cr_crapcob(pr_cdcooper => rw_crapcco.cdcooper
                         ,pr_cdbandoc => rw_crapcco.cddbanco
                         ,pr_nrdctabb => rw_crapcco.nrdctabb
                         ,pr_nrcnvcob => rw_crapcco.nrconven
                         ,pr_nrdconta => vr_aux_nrdconta
                         ,pr_nrdocmto => vr_aux_nrdocmto);
          FETCH cr_crapcob
           INTO rw_crapcob;
          -- Se não encontrar
          IF cr_crapcob%NOTFOUND THEN
            CLOSE cr_crapcob;
            -- Enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'VR Boleto nao encontrado.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE
            CLOSE cr_crapcob;
          END IF;

          -- Em estado de critica
          IF vr_aux_flestcri > 0 THEN
            -- Buscar informações do estado de crise
            IF vr_tab_estad_crise.exists(rw_crapcob.cdcooper) THEN
              vr_aux_dtintegr := vr_tab_estad_crise(rw_crapcob.cdcooper).dtintegr;
              vr_aux_inestcri := vr_tab_estad_crise(rw_crapcob.cdcooper).inestcri;
            END IF;
          ELSE
            -- Marcelo Telles Coelho - Projeto 475
            -- Escolher a data a ser utilizada no processo
            -- Se TRUNC(SYSDATE) > DTMVTOLT ==> Utilizar DTMVTOCD senão Utilizar DTMVTOLT
            -- Definido na FN_VERIFICA_PROCESSO
            vr_aux_dtintegr := vr_dtmovimento;
          END IF;

          -- Se Boleto já foi pago
          IF rw_crapcob.incobran = 5 THEN
            -- Enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'VR Boleto ja foi pago.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Processo finalizado
            RAISE vr_exc_next;
          END IF;

          -- variaveis de calculo para juros/multa
          vr_aux_vlrjuros := 0;
          vr_aux_vlrmulta := 0;
          vr_aux_vldescto := 0;
          vr_aux_vlabatim := rw_crapcob.vlabatim;
          vr_aux_vlfatura := rw_crapcob.vltitulo;

          -- Verifica necessidade de calculo juros caso o titulo esteja vencido
          vr_aux_flgvenci := fn_verifica_vencto_titulo(rw_crapcob.cdcooper,rw_crapcob.dtvencto);

          -- calculo de abatimento deve ser antes da aplicacao de juros e multa
          IF vr_aux_vlabatim > 0 THEN
            vr_aux_vlfatura := vr_aux_vlfatura - vr_aux_vlabatim;
          END IF;

          -- Trata o desconto se concede apos o vencimento
          IF rw_crapcob.cdmensag = 2 THEN
            vr_aux_vldescto := rw_crapcob.vldescto;
            vr_aux_vlfatura := vr_aux_vlfatura - vr_aux_vldescto;
          END IF;

          -- Verifica se o titulo esta vencido
          IF vr_aux_flgvenci  THEN
            -- MULTA PARA ATRASO
            IF rw_crapcob.tpdmulta = 1 THEN /* Valor */
              vr_aux_vlrmulta := rw_crapcob.vlrmulta;
            /* % de multa do valor  do boleto */
            ELSIF rw_crapcob.tpdmulta = 2  THEN
              vr_aux_vlrmulta := (rw_crapcob.vlrmulta * vr_aux_vlfatura) / 100;
            END IF;
            /* MORA PARA ATRASO */
            IF rw_crapcob.tpjurmor = 1  THEN /* dias */
              vr_aux_vlrjuros := rw_crapcob.vljurdia * (vr_aux_dtintegr - rw_crapcob.dtvencto);
            ELSIF rw_crapcob.tpjurmor = 2  THEN /* mes */
              vr_aux_vlrjuros := (rw_crapcob.vltitulo * ((rw_crapcob.vljurdia / 100) / 30) * (vr_aux_dtintegr - rw_crapcob.dtvencto));
            END IF;
          ELSE
            -- se concede apos vencto, ja calculou
            IF rw_crapcob.cdmensag <> 2  THEN
              vr_aux_vldescto := rw_crapcob.vldescto;
            END IF;
          END IF;

          IF (rw_crapcob.incobran = 3 AND (rw_crapcob.insitcrt = 0 OR rw_crapcob.insitcrt = 1)) THEN
            vr_aux_liqaposb := TRUE;
          ELSE
            vr_aux_liqaposb := FALSE;
          END IF;

          /* Buscar dados do banco */
          OPEN cr_crapban(pr_cdbccxlt => null
                         ,pr_nrispbif => vr_aux_ISPBIFDebtd);
          FETCH cr_crapban
           INTO rw_crapban;
          -- Se não encontrou
          IF cr_crapban%NOTFOUND THEN
            CLOSE cr_crapban;
            -- enviar mensagem STR0010
            pc_gera_erro_xml(pr_dsdehist => 'Agencia nao encontrada.'
                            ,pr_codierro => 2
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE
            CLOSE cr_crapban;
          END IF;

          vr_aux_cdbanpag := rw_crapban.cdbccxlt;
          vr_aux_dsmotivo := '04'; /* compensacao eletronica */

          -- Liquidação tratar em Bloco para pegar erros de CAST
          BEGIN
            -- Se não for liquidacao de titulo já pago, então liq normal
            IF NOT vr_aux_liqaposb THEN
              paga0001.pc_processa_liquidacao(pr_idtabcob => rw_crapcob.rowid
                                             ,pr_nrnosnum => 0
                                             ,pr_nrispbpg => vr_aux_ISPBIFDebtd
                                             ,pr_cdbanpag => vr_aux_cdbanpag
                                             ,pr_cdagepag => vr_aux_AgDebtd
                                             ,pr_vltitulo => rw_crapcob.vltitulo
                                             ,pr_vlliquid => 0
                                             ,pr_vlrpagto => vr_aux_VlrLanc
                                             ,pr_vlabatim => 0
                                             ,pr_vldescto => vr_aux_vldescto + vr_aux_vlabatim
                                             ,pr_vlrjuros => vr_aux_vlrjuros + vr_aux_vlrmulta
                                             ,pr_vloutdeb => 0
                                             ,pr_vloutcre => 0
                                             ,pr_dtocorre => vr_aux_dtintegr
                                             ,pr_dtcredit => vr_aux_dtintegr
                                             ,pr_cdocorre => 6
                                             ,pr_dsmotivo => vr_aux_dsmotivo
                                             ,pr_dtmvtolt => vr_aux_dtintegr
                                             ,pr_cdoperad => '1'
                                             ,pr_indpagto => 0 -- Compe
                                             ,pr_inestcri => vr_aux_inestcri
                                             ,pr_ret_nrremret => vr_ret_nrremret
                                             ,pr_nmtelant => NULL
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic
                                             ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada
                                             ,pr_tab_descontar => vr_tab_descontar);
            ELSE
              paga0001.pc_proc_liquid_apos_baixa(pr_idtabcob => rw_crapcob.rowid
                                                ,pr_nrnosnum => 0
                                                ,pr_nrispbpg => vr_aux_ISPBIFDebtd
                                                ,pr_cdbanpag => vr_aux_cdbanpag
                                                ,pr_cdagepag => vr_aux_AgDebtd
                                                ,pr_vltitulo => rw_crapcob.vltitulo
                                                ,pr_vlliquid => 0
                                                ,pr_vlrpagto => vr_aux_VlrLanc
                                                ,pr_vlabatim => 0
                                                ,pr_vldescto => vr_aux_vldescto + vr_aux_vlabatim
                                                ,pr_vlrjuros => 0
                                                ,pr_vloutdeb => 0
                                                ,pr_vloutcre => 0
                                                ,pr_dtocorre => vr_aux_dtintegr
                                                ,pr_dtcredit => vr_aux_dtintegr
                                                ,pr_cdocorre => 17
                                                ,pr_dsmotivo => vr_aux_dsmotivo
                                                ,pr_dtmvtolt => vr_aux_dtintegr
                                                ,pr_cdoperad => '1'
                                                ,pr_indpagto => 0 -- Compe
                                                ,pr_inestcri => vr_aux_inestcri
                                                ,pr_ret_nrremret => vr_ret_nrremret
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic
                                                ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada);
            END IF;
            -- Se voltou erro nas criticas
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              
              --Deve efetuar rollback, pois ao chamar a PAGA0001 poderá ter efetuado alguma operação na qual deve ser desfeita
			        ROLLBACK;

              -- Se ha critica sem descricao
              IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;
              -- Gerar a critica em LOG
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo normal
                                        ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                         || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                         || ' Erro ao liquidar fatura '
                                                         ||'Erro execucao - '
                                                         || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                         || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                         || ' , Erro: '||vr_dscritic
                                        ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
              -- Processo finalizado
              RAISE vr_exc_next;
            END IF;
          EXCEPTION
            WHEN vr_exc_next THEN
              -- Apenas propagar
              RAISE vr_exc_next;
            WHEN OTHERS THEN
              -- Gerar a critica em LOG
              BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 1 -- Processo normal
                                        ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                         || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                         ||'Erro execucao - '
                                                         || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                         || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                         || ' , Erro: '||sqlerrm
                                        ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
              -- Processo finalizado
              RAISE vr_exc_next;
          END;
          -- Controle para lancamento consolidado na conta corrente
          paga0001.pc_realiza_lancto_cooperado(pr_cdcooper => rw_crapcco.cdcooper
                                              ,pr_dtmvtolt => vr_aux_dtintegr
                                              ,pr_cdagenci => rw_crapcco.cdagenci
                                              ,pr_cdbccxlt => rw_crapcco.cdbccxlt
                                              ,pr_nrdolote => rw_crapcco.nrdolote
                                              ,pr_cdpesqbb => rw_crapcco.nrconven
                                              ,pr_tab_lcm_consolidada => vr_tab_lcm_consolidada
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
          -- Se voltou erro nas criticas
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            --
            ROLLBACK; --PRB0040712
            --
            -- Se ha critica sem descricao
            IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
              vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            END IF;
            -- Gerar a critica em LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                       || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                       ||'Erro execucao - '
                                                       || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                       || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                       || ' , Erro: '||vr_dscritic
                                      ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
            -- Processo finalizado
            RAISE vr_exc_next;
          END IF;

          -- Realiza liquidacao dos titulos descontados (se houver)
          vr_idx_descontar := vr_tab_descontar.first;
          LOOP
            EXIT WHEN vr_idx_descontar IS NULL;
            -- Devemos criar um novo pltable por conta
            vr_tab_titulosdt(vr_idx_descontar) := vr_tab_descontar(vr_idx_descontar);
            -- Se for o ultimo registro da conta ou da pltable
            IF vr_tab_descontar.next(vr_idx_descontar) IS NULL
            OR vr_tab_descontar(vr_idx_descontar).nrdconta <> vr_tab_descontar(vr_tab_descontar.next(vr_idx_descontar)).nrdconta THEN
              -- Efetuar a baixa do titulo
              DSCT0001.pc_efetua_baixa_titulo (pr_cdcooper    => rw_crapcco.cdcooper -- Codigo Cooperativa
                                              ,pr_cdagenci    => 0               -- Codigo Agencia
                                              ,pr_nrdcaixa    => 0               -- Numero Caixa
                                              ,pr_cdoperad    => 0               -- Codigo operador
                                              ,pr_dtmvtolt    => vr_aux_dtintegr     -- Data Movimento
                                              ,pr_idorigem    => 1               -- Identificador Origem pagamento
                                              ,pr_nrdconta    => vr_tab_descontar(vr_idx_descontar).nrdconta -- Numero da conta
                                              ,pr_indbaixa    => 1                   -- Indicador Baixa /* 1-Pagamento 2- Vencimento */
                                              ,pr_tab_titulos => vr_tab_titulosdt    -- Titulos a serem baixados
                                              ,pr_dtintegr    => vr_aux_dtintegr     -- Data Integração Pagamento
                                              ,pr_cdcritic    => vr_cdcritic         -- Codigo Critica
                                              ,pr_dscritic    => vr_dscritic         -- Descricao Critica
                                              ,pr_tab_erro    => vr_tab_erro);       -- Tabela erros
              -- Se ocorreu erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL OR vr_tab_erro.COUNT() > 0 THEN
                IF vr_tab_erro.Count > 0 THEN
                  vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                ELSE
                  -- Se ha critica sem descricao
                  IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                  END IF;
                END IF;
                -- Gerar a critica em LOG
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                           || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                           || ' Erro ao baixar titulo Cooperado Conta '||vr_tab_descontar(vr_idx_descontar).nrdconta
                                                           ||'Erro execucao - '
                                                           || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                           || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                           || ' , Erro: '||vr_dscritic
                                          ,pr_nmarqlog     => vr_nmarqlog); --> Log específico do SPB
                -- Processo finalizado
                RAISE vr_exc_next;
              END IF;

              -- Limpar tabela temporaria conta
              vr_tab_titulosdt.delete();
            END IF;
            -- Buscar o próximo
            vr_idx_descontar := vr_tab_descontar.next(vr_idx_descontar);
          END LOOP;

          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;

        -- Trata IFs operantes no SPB
        IF vr_aux_CodMsg IN ('PAG0101','STR0018','STR0019') THEN
          -- Trazer arquivo de log do mqcecred_processa
          vr_nmarqlog := fn_log_mqcecred;
          -- Inicializar retorno
          vr_dscritic := 'OK';
          -- Para Pag0101
          IF vr_aux_CodMsg = 'PAG0101' THEN
            -- Somente Para TED
            IF UPPER(vr_aux_CodProdt) = 'TED' THEN
              -- Chamar pc_proc_pag0101
              sspb0001.pc_proc_pag0101_tb(pr_cdprogra => vr_glb_cdprogra
                                         ,pr_nmarqxml => vr_aux_nmarqxml
                                         ,pr_nmarqlog => vr_nmarqlog
                                         ,pr_tab_situa_if => vr_tab_situacao_if
                                         ,pr_des_erro => vr_dscritic);
              -- Caso Sucesso
              IF vr_dscritic = 'OK' THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'PAG0101'
                               ,pr_msgderro  => NULL);
              END IF;
            END IF;
          ELSE
            -- Formatar a data
            vr_aux_dtinispb := SUBSTR(vr_aux_dtinispb, 9, 2) || '/' || SUBSTR(vr_aux_dtinispb, 6, 2) || '/' || SUBSTR(vr_aux_dtinispb, 1, 4);
            -- Chamar rotina de operação do STR
            sspb0001.pc_proc_opera_str(pr_cdprogra => vr_glb_cdprogra
                                      ,pr_nmarqxml => vr_aux_nmarqxml
                                      ,pr_nmarqlog => vr_nmarqlog
                                      ,pr_cdmensag => vr_aux_CodMsg
                                      ,pr_nrispbif => vr_aux_nrispbif
                                      ,pr_cddbanco => vr_aux_cddbanco
                                      ,pr_nmdbanco => vr_aux_nmdbanco
                                      ,pr_dtinispb => vr_aux_dtinispb
                                      ,pr_des_erro => vr_dscritic);
            -- Caso Sucesso
            IF vr_dscritic = 'OK' THEN
              -- Gerar LOG conforme tipo de mensagem
              IF vr_aux_CodMsg = 'STR0018' THEN
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'SPB-STR-IF'
                               ,pr_msgderro  => 'Exclusao IF STR');
              ELSE
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'SPB-STR-IF'
                               ,pr_msgderro  => 'Inclusao IF STR');
              END IF;
            END IF;
          END IF;

          -- Se houve critica
          IF NVL(TRIM(vr_dscritic),'OK') <> 'OK' THEN
            vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
            RAISE vr_exc_saida;
          END IF;

          -- Processo finalizado
          RAISE vr_exc_next;
        END IF;

        -- Verifica se cooperativa de destino eh valida
        IF vr_aux_CodMsg like '%R1'  OR  vr_aux_CodMsg in('STR0010R2','PAG0111R2') THEN
          -- Tenta converter agencia para numero
          IF NOT fn_numerico(SUBSTR(vr_aux_NumCtrlIF,8,4)) THEN
            vr_aux_flgderro := TRUE;
          END IF;
          -- Se não deu erro
          IF NOT vr_aux_flgderro THEN
            -- Busca dados da Coope por cdagectl
            OPEN cr_busca_coop(pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4));
            FETCH cr_busca_coop
             INTO rw_crapcop_mensag;
            -- Se não encontrou
            IF cr_busca_coop%NOTFOUND THEN
              vr_aux_flgderro := TRUE;
            END IF;
            CLOSE cr_busca_coop;
          END IF;

          -- Se gerou erro
          IF vr_aux_flgderro THEN
            pc_trata_cecred (pr_cdagectl => SUBSTR(vr_aux_NumCtrlIF,8,4)
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Processo finalizado
            RAISE vr_exc_next;
          END IF;
        ELSIF vr_aux_CodMsg = 'CIR0020' THEN /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
            /* Busca cooperativa */
            OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
            FETCH cr_crapcop
             INTO rw_crapcop_mensag;
            -- Se não encontrou
            IF cr_crapcop%NOTFOUND THEN
              vr_aux_flgderro := TRUE;
            END IF;
            CLOSE cr_crapcop;
        ELSIF vr_aux_CodMsg = 'CIR0021' THEN /* SD 805540 - 14/02/2018 - Marcelo (Mouts) */
              -- Sprint D - Req50
              -- Deve integrar o lançamento sempre na cooperativa 3 (Central)
              -- Busca os dados da cooperativa 3
              OPEN cr_busca_coop(pr_cdagectl => '100');
              FETCH cr_busca_coop INTO rw_crapcop_mensag;
              CLOSE cr_busca_coop;
        ELSE
          -- Tenta converter agencia para numero
          IF NOT fn_numerico(vr_aux_AgCredtd) THEN
            vr_aux_flgderro := TRUE;
          END IF;
          -- Se não deu erro
          IF NOT vr_aux_flgderro THEN
            -- Busca dados da Coope por cdagectl
            OPEN cr_busca_coop(pr_cdagectl => vr_aux_AgCredtd
                           ,pr_flgativo => 1);
                              
            FETCH cr_busca_coop INTO rw_crapcop_mensag;
            
            -- Se não encontrou
            IF cr_busca_coop%NOTFOUND THEN
              
              CLOSE cr_busca_coop;
              
              -- Tratamento incorporacao TRANSULCRED
              IF to_number(vr_aux_AgCredtd) = 116 AND trunc(vr_glb_dataatual) < to_date('21/01/2017','dd/mm/rrrr') THEN
                -- Usar agencia Incorporada
                vr_aux_cdageinc := to_number(vr_aux_AgCredtd);
                vr_aux_AgCredtd := '0108';
                -- Busca cooperativa de destino (nova)
                OPEN cr_busca_coop(pr_cdagectl => vr_aux_AgCredtd);
                FETCH cr_busca_coop INTO rw_crapcop_mensag;
                CLOSE cr_busca_coop;
              ELSE
                vr_aux_flgderro := TRUE;
              END IF;
              
            ELSE
              CLOSE cr_busca_coop;  
            END IF;
            
          END IF;

          -- Se estamos em estado de crise
          IF vr_aux_flestcri > 0 THEN
            -- Buscar informações da Coop
            IF vr_tab_estad_crise.exists(rw_crapcop_mensag.cdcooper) THEN
              vr_aux_dtintegr := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).dtintegr;
              vr_aux_inestcri := vr_tab_estad_crise(rw_crapcop_mensag.cdcooper).inestcri;
            END IF;
            
          /* IFs incorporadas foram desativadas(crapcop.flgativo = FALSE)
          ELSE
             -- Tratamento incorporacao CONCREDI e CREDIMILSUL 
             IF to_number(vr_aux_AgCredtd) = 103 THEN
               vr_aux_cdageinc := to_number(vr_aux_AgCredtd);
               vr_aux_AgCredtd := '0101';
             ELSIF to_number(vr_aux_AgCredtd) = 114 THEN
               vr_aux_cdageinc := to_number(vr_aux_AgCredtd);
               vr_aux_AgCredtd := '0112';
             END IF;
             -- Busca cooperativa de destino
             OPEN cr_busca_coop(pr_cdagectl => vr_aux_AgCredtd);
             FETCH cr_busca_coop INTO rw_crapcop_mensag;
             CLOSE cr_busca_coop;
             */
          END IF;

          -- Se houve erro
          IF vr_aux_flgderro THEN
            pc_trata_cecred (pr_cdagectl => vr_aux_AgCredtd
                            ,pr_dscritic => vr_dscritic);
            -- Se retornou erro
            IF vr_dscritic IS NOT NULL THEN
              -- Incrementar o LOG
              vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
              RAISE vr_exc_saida;
            END IF;
            -- Processo finalizado
            RAISE vr_exc_next;
          ELSE

            vr_aux_dsdehist := NULL;

            -- Verifica se a conta eh valida
            pc_verifica_conta(pr_cdcritic => vr_aux_codierro
                             ,pr_dscritic => vr_aux_dsdehist);
            -- Se não voltou erro
            IF vr_aux_codierro <> 0 THEN
              -- Buscar o calendário
              OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop_mensag.cdcooper);
              FETCH btch0001.cr_crapdat
               INTO rw_crapdat_mensag;
              -- Se não encontrar
              IF btch0001.cr_crapdat%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE btch0001.cr_crapdat;
                -- Montar mensagem de critica
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
                -- Gerar em LOG
                BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 1 -- Processo normal
                                          ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                           || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                           ||'Erro execucao - '
                                                           || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                           || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                           || ', Erro: '||vr_dscritic
                                          ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
                -- Ir ao próximo registro
                RAISE vr_exc_next;
              ELSE
                -- Apenas fechar o cursor
                CLOSE btch0001.cr_crapdat;
              END IF;
              -- Cria registro da mensagem recebida com ERRO
              pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                             ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                             ,pr_dsmensag => vr_aux_codMsg
                             ,pr_dsdebcre => 'C'
                             ,pr_vllanmto => vr_aux_VlrLanc
                             ,pr_dscritic => vr_dscritic);
              IF vr_dscritic IS NOT NULL THEN
                raise vr_exc_saida;
              END IF;
              -- Buscar erro Agencia invalida
              vr_aux_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 0
                                                           ,pr_nmsistem => 'CRED'
                                                           ,pr_tptabela => 'GENERI'
                                                           ,pr_cdempres => 0
                                                           ,pr_cdacesso => 'CDERROSSPB'
                                                           ,pr_tpregist => vr_aux_codierro);
              -- Se encontrou
              IF vr_aux_dstextab IS NOT NULL THEN
                -- Copiar a var padrão de erro
                vr_log_msgderro := vr_aux_dstextab;
              END IF;
              -- Gerar XML de erro
              pc_gera_erro_xml(pr_dsdehist => vr_aux_dsdehist
                              ,pr_codierro => vr_aux_codierro
                              ,pr_dscritic => vr_dscritic);
              -- Se retornou erro
              IF vr_dscritic IS NOT NULL THEN
                -- Incrementar o LOG
                vr_dscritic := 'Erro ao processar mensagem --> ' || vr_dscritic;
                RAISE vr_exc_saida;
              END IF;
              -- Processo finalizado
              RAISE vr_exc_next;
            END IF;
          END IF;
        END IF;

        -- Confirmacao
        IF vr_aux_CodMsg like '%R1' THEN
          -- Busca data do sistema
          OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop_mensag.cdcooper);
          FETCH btch0001.cr_crapdat
           INTO rw_crapdat_mensag;
          -- Se não encontrar
          IF btch0001.cr_crapdat%NOTFOUND THEN
            -- Fechar o cursor pois efetuaremos raise
            CLOSE btch0001.cr_crapdat;
            -- Montar mensagem de critica
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
            -- Gerar em LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 1 -- Processo normal
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/rrrr') || ' - '
                                                       || to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra || ' --> '
                                                       ||'Erro execucao - '
                                                       || 'Nr.Controle IF: ' || vr_nrcontrole_if || ' '
                                                       || 'Mensagem: ' || vr_aux_CodMsg || ' '
                                                       || ', Erro: '||vr_dscritic
                                      ,pr_nmarqlog     => vr_logprogr); --> Log específico deste programa
            -- Ir ao próximo registro
            RAISE vr_exc_next;
          ELSE
            -- Apenas fechar o cursor
            CLOSE btch0001.cr_crapdat;
          END IF;
          -- Se não validar processo
          IF NOT fn_verifica_processo THEN
            -- Ir ao próximo registro
            RAISE vr_exc_next;
          END IF;
          --
          -- Cria registro da mensagem recebida com ERRO
          pc_cria_gnmvcen(pr_cdagenci => rw_crapcop_mensag.cdagectl
                         ,pr_dtmvtolt => rw_crapdat_mensag.dtmvtolt
                         ,pr_dsmensag => vr_aux_codMsg
                         ,pr_dsdebcre => ' '
                         ,pr_vllanmto => 0
                         ,pr_dscritic => vr_dscritic);
          IF vr_dscritic IS NOT NULL THEN
            raise vr_exc_saida;
          END IF;

          -- Nao gravamos o Numero de Controle das mensagens de
          -- devolucao(STR0010/PAG0111) geradas pelo Legado,
          -- sendo assim, apenas logamos o recebimento da R1
          IF vr_aux_CodMsg NOT IN ('STR0010R1','PAG0111R1') THEN
            -- TED
            IF SUBSTR(vr_aux_NumCtrlIF,1,1) = '1'  THEN
              IF vr_aux_SitLanc IN('1'   -- Efetivado
                                  ,'2'   -- Efetivado - Contingência/STR Web
                                  ,'3'   -- Efetivado - Otimização
                                  ,'COM' -- Aprovado
                                  ) THEN
                -- Buscar o registro da TVL a ser atualizado
                OPEN cr_craptvl(rw_crapcop_mensag.cdcooper,vr_aux_NumCtrlIF);
                FETCH cr_craptvl
                 INTO rw_craptvl;
                -- Se não encontrou
                IF cr_craptvl%NOTFOUND THEN
                  CLOSE cr_craptvl;
                  vr_dscritic := 'Numero de Controle invalido';
                ELSE
                  CLOSE cr_craptvl;
                  -- Verificar se tabela esta lockada
                  IF fn_verifica_tab_em_uso(pr_sig_tabela => 'TVL'
                                           ,pr_rowid => rw_craptvl.rowid ) = 1 THEN
                    vr_dscritic := 'Registro de Transferencia DOC/TED '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
                    -- apensa jogar critica em log
                    RAISE vr_exc_lock;
                  END IF;

                  -- Atualizar flopfin do registro da TED
                  BEGIN
                    UPDATE craptvl
                       SET flgopfin = 1 -- True
                     WHERE ROWID = rw_craptvl.rowid;
                    -- Se nao atualizou nenhum registro
                    IF SQL%ROWCOUNT = 0 THEN
                      -- Gerar critica
                      vr_dscritic := 'Numero de Controle invalido';
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar registro craptvl --> '||sqlerrm;
                  END;
                END IF;
              ELSIF vr_aux_SitLanc IN('18'  -- Pendente por agendamento
                                     ,'AGE' -- Agendado
                                     ,'ENF' -- Pendente à Espera de Execução do Algoritmo Multilateral
                                     ) THEN
                NULL;
              ELSE
                -- Se veio mensagem de Cancelado ou Rejeitado
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA SPB NOK'
                               ,pr_msgderro  => 'Retorno R1 não prevista - Situacao Lancamento: '||vr_aux_SitLanc);
                -- Processo finalizado
                RAISE vr_exc_next;
              END IF;
            -- TEC
            ELSIF SUBSTR(vr_aux_NumCtrlIF,1,1) = '2'  THEN
              IF vr_aux_SitLanc IN('1'   -- Efetivado
                                  ,'2'   -- Efetivado - Contingência/STR Web
                                  ,'3'   -- Efetivado - Otimização
                                  ,'COM' -- Aprovado
                                  ) THEN
                -- Buscar registro transferência
                OPEN cr_craplcs(pr_cdcooper => rw_crapcop_mensag.cdcooper
                               ,pr_idopetrf => vr_aux_NumCtrlIF);
                FETCH cr_craplcs
                 INTO rw_craplcs;
                -- Se encontrar
                IF cr_craplcs%NOTFOUND THEN
                  CLOSE cr_craplcs;
                  -- Gerar critica
                  vr_dscritic := 'Numero de Controle invalido';
                ELSE
                  CLOSE cr_craplcs;

                  -- Verificar se tabela esta lockada
                  IF fn_verifica_tab_em_uso(pr_sig_tabela => 'LCS'
                                           ,pr_rowid => rw_craplcs.rowid ) = 1 THEN
                    vr_dscritic := 'Registro de Transferencia Conta Salario '||vr_aux_NumCtrlIF||' em uso. Tente novamente.';
                    -- apensa jogar critica em log
                    RAISE vr_exc_lock;
                  END IF;
                  -- Atualizar flopfin do registro da TEC
                  BEGIN
                    UPDATE craplcs
                       SET flgopfin = 1 -- True
                     WHERE cdcooper = rw_crapcop_mensag.cdcooper
                       AND idopetrf = vr_aux_NumCtrlIF
                     RETURNING nrridlfp INTO vr_aux_nrridflp;
                    -- Se nao atualizou nenhum registro
                    IF SQL%ROWCOUNT = 0 THEN
                      -- Gerar critica
                      vr_dscritic := 'Numero de Controle invalido';
                    END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar registro craplcs --> '||sqlerrm;
                  END;
                END IF;
                -- Se não deu erro e retornou Recid Folha IB
                IF vr_dscritic IS NULL AND vr_aux_nrridflp <> 0 THEN
                  -- checar se a tabela nao esta em lock
                  IF fn_verifica_tab_em_uso(pr_sig_tabela => 'LFP'
                                           ,pr_progress_recid => vr_aux_nrridflp ) = 1 THEN
                    vr_dscritic := 'Registro de Folha Conta Salario '||vr_aux_nrridflp||' em uso. Tente novamente.';
                    -- apensa jogar critica em log
                    RAISE vr_exc_lock;
                  END IF;

                  -- Usaremos este Recid para atualizar o registro no sistema de Folha
                  BEGIN
                    UPDATE craplfp
                       SET idsitlct = 'T'  -- Transmitido
                          ,dsobslct = NULL -- Sem observações por hora
                     WHERE cdcooper = rw_crapcop_mensag.cdcooper
                       AND progress_recid = vr_aux_nrridflp;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_dscritic := 'Erro ao atualizar registro craplfp --> '||sqlerrm;
                  END;
                END IF;
              ELSIF vr_aux_SitLanc IN('18'  -- Pendente por agendamento
                                     ,'AGE' -- Agendado
                                     ,'ENF' -- Pendente à Espera de Execução do Algoritmo Multilateral
                                     ) THEN
                NULL;
              ELSE
                -- Se veio mensagem de Cancelado ou Rejeitado
                -- Gera LOG SPB
                pc_gera_log_SPB(pr_tipodlog  => 'ENVIADA SPB NOK'
                               ,pr_msgderro  => 'Retorno R1 não prevista - Situacao Lancamento: '||vr_aux_SitLanc);
                -- Processo finalizado
                RAISE vr_exc_next;
              END IF;
              -- Fim Projeto 475
            ELSIF SUBSTR(vr_aux_NumCtrlIF,1,1) = '9' THEN -- TED de Protesto
              NULL;
            -- STR0004
            ELSIF SUBSTR(vr_aux_NumCtrlIF,1,1) <> '3'  THEN
              -- Gera critica
              vr_dscritic := 'Identificador TED/TEC invalido';
            END IF;
            -- Se houve critica
            IF vr_dscritic IS NOT NULL THEN
              -- Gera LOG SPB
              pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                             ,pr_msgderro  => vr_dscritic);
              -- Processo finalizado
              RAISE vr_exc_next;
            END IF;
          END IF;

          -- Ao final, gera LOG SPB
          pc_gera_log_SPB(pr_tipodlog  => 'RETORNO SPB'
                         ,pr_msgderro  => NULL);

          -- Processo finalizado
          RAISE vr_exc_next;

        ELSE
          -- Acionar rotina de tratamento de lançamentos
          pc_trata_lancamentos(pr_dscritic  => vr_dscritic);
          -- Tratar erro na chamada da gera log SPB
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;

          -- Processo finalizado
          RAISE vr_exc_next;

        END IF;

      EXCEPTION
        WHEN vr_exc_next THEN
          NULL; --> Apenas ignorar e continar o processo final
          -- Marcelo Telles Coelho - Projeto 475
          -- Devolver crítica de processo em curso para o Barramento SOA
          IF  NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE '%R1'
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE '%R2'
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'STR%'
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'PAG%'
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'SLC%'
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'CIR%' -- Sprint D 
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'LDL%' -- Sprint D  
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'SEL%' 
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'RDC%'       
          AND NVL(vr_aux_CodMsg,'Sem <CodMsg>') NOT LIKE 'SLB%'  
          AND NOT vr_aux_tagCABInf
          THEN
            IF NOT fn_verifica_processo THEN
              pr_cdcritic := 991; -- Processo rodando
              pr_dscritic := 'Processo rodando';
            END IF;
          END IF;
          -- FIM projeto 475
      END;
    END IF;

    -- Marcelo Telles Coelho - Projeto 475
    -- Eliminar lançamentos em duplicicdade nas tabelas de TBSPB_MSG_*
    -- que ocorrem devido a atualização de mensagens no mesmo instante.
    sspb0003.pc_acerto_recebida(pr_dscritic => vr_dscritic);
    --
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;
    --  Fim Projeto 475
    
    -- Efetuar commit das alterações
    COMMIT;
    pc_alter_session_para_default; -- Marcelo Telles Coelho - Projeto 475 - SPRINT C2

  EXCEPTION
    WHEN vr_exc_lock THEN
      -- O arquivo não será movido, portanto não haverá chamada a pc_salva_arquivo ou pc_mover_arquivo_xml
      -- Assim ele será processado posteriormente em momento que a tabela não estiver em lock
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
      -- Iniciar LOG de execução
      -- Marcelo Telles Coelho - Projeto 475
      -- Padronizar os logs no mesmo arquivo
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                ,pr_des_log       => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                  ||'Erro execucao - '
                                                  || pr_dscritic
                                ,pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'));
      -- Marcelo Telles Coelho - Projeto 475
      -- Salvar o XML recebido para posterior verificação
      sspb0003.pc_grava_xml(pr_nmmensagem         => vr_trace_nmmensagem_xml
                           ,pr_inorigem_mensagem  => NULL
                           ,pr_dhmensagem         => SYSDATE
                           ,pr_dsxml_mensagem     => SUBSTR(vr_trace_dsxml_mensagem,1,4000)
                           ,pr_dsxml_completo     => vr_trace_dsxml_mensagem
                           ,pr_inenvio            => 0 -- Mensagem não será enviada para o JD
                           ,pr_cdcooper           => NULL
                           ,pr_nrdconta           => NULL
                           ,pr_cdproduto          => 30 -- TED
                           ,pr_dsobservacao       => pr_dscritic
                           ,pr_nrseq_mensagem_xml => vr_nrseq_mensagem_xml
                           ,pr_dscritic           => vr_dscritic
                           ,pr_des_erro           => vr_des_erro
                           );
      -- Fim Projeto 475
      -- Efetuar commit das alterações
      COMMIT;
      pc_alter_session_para_default; -- Marcelo Telles Coelho - Projeto 475 - SPRINT C2
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;
      -- Copiar aos parametros
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
      -- Iniciar LOG de execução
      -- Marcelo Telles Coelho - Projeto 475
      -- Padronizar os logs no mesmo arquivo
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log  => 2 -- Erro não tratado
                                ,pr_des_log       => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                  ||'Erro execucao - '
                                                  || pr_dscritic
                                ,pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'));
      -- Marcelo Telles Coelho - Projeto 475
      -- Se ocorreu erro oracle a deverá retorna CDCRITIC não nulo
      IF INSTR(pr_dscritic,'ORA-') > 0 THEN
        pr_cdcritic := 9;
      END IF;
      -- Não executa mais em paralelo
      -- Salvar o XML recebido para posterior verificação
      sspb0003.pc_grava_xml(pr_nmmensagem         => vr_trace_nmmensagem_xml
                           ,pr_inorigem_mensagem  => NULL
                           ,pr_dhmensagem         => SYSDATE
                           ,pr_dsxml_mensagem     => SUBSTR(vr_trace_dsxml_mensagem,1,4000)
                           ,pr_dsxml_completo     => vr_trace_dsxml_mensagem
                           ,pr_inenvio            => 0 -- Mensagem não será enviada para o JD
                           ,pr_cdcooper           => NULL
                           ,pr_nrdconta           => NULL
                           ,pr_cdproduto          => 30 -- TED
                           ,pr_dsobservacao       => pr_dscritic
                           ,pr_nrseq_mensagem_xml => vr_nrseq_mensagem_xml
                           ,pr_dscritic           => vr_dscritic
                           ,pr_des_erro           => vr_des_erro
                           );
      -- Fim Projeto 475
      -- Efetuar commit das alterações
      COMMIT;
      pc_alter_session_para_default;-- Marcelo Telles Coelho - Projeto 475 - SPRINT C2
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Iniciar LOG de execução
      -- Marcelo Telles Coelho - Projeto 475
      -- Padronizar os logs no mesmo arquivo
      BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 3 -- Erro não tratado
                                ,pr_des_log       => to_char(sysdate,'hh24:mi:ss')||' - '|| vr_glb_cdprogra ||' --> '
                                                  ||'Erro execucao - '
                                                  || pr_dscritic
                                ,pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE'));
      -- Efetuar rollback
      ROLLBACK;
      -- Marcelo Telles Coelho - Projeto 475
      -- Salvar o XML recebido para posterior verificação
      sspb0003.pc_grava_xml(pr_nmmensagem         => vr_trace_nmmensagem_xml
                           ,pr_inorigem_mensagem  => NULL
                           ,pr_dhmensagem         => SYSDATE
                           ,pr_dsxml_mensagem     => SUBSTR(vr_trace_dsxml_mensagem,1,4000)
                           ,pr_dsxml_completo     => vr_trace_dsxml_mensagem
                           ,pr_inenvio            => 0 -- Mensagem não será enviada para o JD
                           ,pr_cdcooper           => NULL
                           ,pr_nrdconta           => NULL
                           ,pr_cdproduto          => 30 -- TED
                           ,pr_dsobservacao       => pr_dscritic
                           ,pr_nrseq_mensagem_xml => vr_nrseq_mensagem_xml
                           ,pr_dscritic           => vr_dscritic
                           ,pr_des_erro           => vr_des_erro
                           );
      -- Fim Projeto 475
      COMMIT;
      pc_alter_session_para_default;-- Marcelo Telles Coelho - Projeto 475 - SPRINT C2
  END;
END PC_CRPS531_1;
/
