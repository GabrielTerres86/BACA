create or replace procedure cecred.pc_crps618(pr_cdcooper in  craptab.cdcooper%type
                                             ,pr_nrdconta in  crapcob.nrdconta%type                                              
                                             ,pr_cdcritic out crapcri.cdcritic%type
                                             ,pr_dscritic out varchar2) as

  /******************************************************************************
    Programa: pc_crps618 (Antigo: fontes/crps618.p) 
    Sistema : Cobranca - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Rafael
    Data    : janeiro/2012.                     Ultima atualizacao: 30/11/2018
 
    Dados referentes ao programa:
 
    Frequencia: Diario.
    Objetivo  : Buscar confirmacao de registro dos titulos na CIP.
                Registrar titulos na CIP a partir de novembro/2013.
    
    Observacoes: O script /usr/local/cecred/bin/crps618.pl executa este 
                 programa para verificar o registro/rejeicao dos titulos 
                 na CIP enviados no dia.
                 
                 Horario de execucao: todos os dias, das 6:00h as 22:00h
                                      a cada 15 minutos.
                                      
    Alteracoes: 27/08/2013 - Alterado busca de registros de titulos utilizando
                             a data do movimento anterior (Rafael).
                             
                21/10/2013 - Incluido parametro novo na prep-retorno-cooperado
                             ref. ao numero de remessa do arquivo (Rafael).
                             
                15/11/2013 - Mudanças no processo de registro dos titulos na 
                             CIP: a partir da liberaçao de novembro/2013, os
                             titulos gerados serao registrados por este 
                             programa definidos pela CRON. O campo 
                             "crapcob.insitpro" irá utilizar os seguintes 
                             valores:
                             0 -> sacado comum (nao DDA);
                             1 -> sacado a verificar se é DDA;
                             2 -> Enviado a CIP;
                             3 -> Sacado DDA OK;
                             4 -> nao haverá mais -> retornar a "zero";
                             
                03/12/2013 - Incluido nome da temp-table tt-remessa-dda nos 
                             campos onde faltavam o nome da tabela. (Rafael)
                             
                30/12/2013 - Ajuste na leitura/gravacao das informacoes dos
                             titulos ref. ao DDA. (Rafael)     
                
                14/01/2014 - Alteracao referente a integracao Progress X 
                             Dataserver Oracle 
                             Inclusao do VALIDATE ( Andre Euzebio / SUPERO)  
                             
                03/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).
                
                27/05/2014 - Aumentado o tempo para decurso de prazo de titulos 
                             DDA de 22 para 59 dias (Tiago SD138818).
                             
                17/07/2014 - Alterado forma de gravacao do tipo de multa para
                             garantir a confirmacao do registro na CIP. (Rafael)
                             
                12/02/2014 - Incluido restriçao para nao enviar cobrança para a cabine 
                             no qual o valor ultrapasse 9.999.999,99, pois a cabine
                             existe essa limitaçao de valor e apresentará falha nao 
                             tratada SD-250064 (Odirlei-AMcom)
                             
                28/04/2015 - Ajustar indicador de alt de valor ref a boletos
                             vencidos DDA para "N" -> Sacado nao pode alterar
                             o valor de boleto vencido. (SD 279793 - Rafael)
                             
                29/05/2015 - Concatenar motivo "A4" para titulos DDA no registro
                             de confirmacao de retorno na crapret.
                           - Enviar titulo Cooperativa/EE ao DDA quando já
                             enviado para a PG. (Projeto 219 - Rafael)
                                                         
                31/07/2015 - Ajuste para retirar o caminho absoluto na chamada
                             de fontes
                             (Adriano - SD 314469).
                                                                         
                18/08/2015 - Ajuste na data limite de pagto para boletos do 
                             convenio "EMPRESTIMO" - Projeto 210 (Rafael).
                             
                14/11/2016 - CONVERSÃO PROGRESS >> ORACLE (Renato Darosci - Supero)
                
                01/12/2016 - Alterado para enviar como texto informativo o conteudo do campo
                             dsinform, ao inves do campo dsdinstr
                             Heitor (Mouts) - Chamado 564818

                27/12/2016 - Tratamentos para Nova Plataforma de Cobrança
                             PRJ340 - NPC (Odirlei-AMcom)
                             
                12/07/2017 - Retirado cobranca de tarifa após a rejeição do 
                             boleto DDA na CIP (Rafael)
                             
                14/07/2017 - Retirado verificação do inproces da crapdat. Dessa forma
                             o programa pode ser executado todos os dias. (Rafael)

                20/09/2017 - Ajustado para que e a validação de envio do titulo para a CIP
                             seja feita com duas variáveis, pois caso o pagador não seja DDA
                             e o primeiro titulo identificado como dentro da faixa de ROLLOUT,
                             todos os titulos que serão processados em seguida tambem serão
                             registrados (Douglas - Chamado 756559)
  
                10/10/2017 - Ajustar padrão de Logs
                             Ajustar padrão de Exception Others
                             Inclui nome do modulo logado
                             Padrões na chamada pc_gera_log_batch
                             ( Belli - Envolti - Chamados 729095 - 758611 ) 

                20/10/2017 - O boleto foi gerado pela Conta Online para integração on-line
                             com a CIP. No mesmo momento a rotina de carga normal também estava
                             inicou a execução. O boleto foi enviado tanto pela processo normal
                             quanto pela carga on-line. Incluída verificação do IDTITLEG para
                             evitar envio de título já registrado. (SD#777146 - AJFink)

                09/11/2017 - Inclusão de chamada da procedure npcb0002.pc_libera_sessao_sqlserver_npc.
                             (SD#791193 - AJFink)

                21/05/2018 - Processamento dos títulos foi segregado em lotes menores com limitada
                             quantidade de registros (QTD_REG_LOTE_JDNPC). Segregado o processamento
                             para as cooperativas singulares executarem em paralelo quando carga normal.
                             (INC0013085 - AJFink)

                13/06/2018 - Ajuste para verificar se data de movimento da CIP é igual data referencia
                             (sysdate). Caso elas sejam diferentes, os titulos ficam na fila ate que a 
                             informacao de abertura chegue ao sistema.
                             Chamado SCTASK0015832 - Gabriel (Mouts).

                30/11/2018 - Título deve ser enviado para a CIP independente da remessa para a PG.
                             (INC0025924 - AJFink)

  ******************************************************************************/

  --types
  --registro de lote de titulos
  type typ_reg_lote_titulo is record (crapcob_rowid rowid);
  type typ_tab_lote_titulo is table of typ_reg_lote_titulo index by pls_integer;
  --
  --registro de sacados já consultados para reaproveitar a consulta
  type t_reg_sab is record (cdidesab varchar2(17)
                           ,flsacdda number(1));
  type t_tab_sab is table of t_reg_sab index by varchar2(17);
  --constantes
  ct_cdprogra constant varchar2(10) := 'crps618';   -- Nome do programa
  ct_vllimcab constant number       := 99999999.99; -- Define o valor limite da cabine
  ct_cdoperad constant varchar2(10) := '1';         -- Código do operador - verificar se será fixo ou parametro
  --variaveis
  vr_idprglog tbgen_prglog.idprglog%TYPE := 0;
  vr_iderro   varchar2(1) := 'N';
  --
--------------------------------------------------------------
----procedimentos genericos para funcionamento do programa----
--------------------------------------------------------------
  PROCEDURE pc_controla_log_batch(pr_cdcooper_in   IN crapcop.cdcooper%TYPE
                                 ,pr_dstiplog      IN VARCHAR2 -- 'I' início; 'F' fim; 'E' erro
                                 ,pr_dscritic      IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%type DEFAULT 0
                                 ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%type DEFAULT 0) IS
    --
    /*procedure que grava log do programa*/
    --
    -- Refeita rotina de log - 10/10/2017 - Ch 758611 
    vr_dscritic_aux VARCHAR2(4000);
    vr_tpocorrencia tbgen_prglog_ocorrencia.tpocorrencia%type;
  BEGIN
    vr_dscritic_aux := pr_dscritic||', cdcooper:'||pr_cdcooper_in||', nrdconta:'||pr_nrdconta;
    IF pr_dstiplog IN ('O', 'I', 'F') THEN
      vr_tpocorrencia := 4; 
    ELSE
      vr_tpocorrencia := 2;       
    END IF;
    --> Controlar geração de log de execução dos jobs 
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E')
                          ,pr_cdprograma    => ct_cdprogra
                          ,pr_cdcooper      => pr_cdcooper_in
                          ,pr_tpexecucao    => 2 --job
                          ,pr_tpocorrencia  => vr_tpocorrencia
                          ,pr_cdcriticidade => pr_cdcriticidade
                          ,pr_cdmensagem    => pr_cdmensagem
                          ,pr_dsmensagem    => vr_dscritic_aux
                          ,pr_idprglog      => vr_idprglog
                          ,pr_nmarqlog      => NULL);
  EXCEPTION  
    WHEN OTHERS THEN  
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper_in);   
  END pc_controla_log_batch;
  --
  procedure pc_raise_error(pr_dsmensag in varchar2
                          ,pr_cdcritic in crapcri.cdcritic%type
                          ,pr_dscritic in varchar2
                          ,pr_idempilh in boolean) is
    --
    /*recebe a critica como parametro trata a descricao e o código e executa um raise*/
    --
    vr_cdcritic number(5)      := pr_cdcritic;
    vr_dscritic varchar2(4000) := pr_dscritic;
    --
  begin
    --
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      if nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      end if;
      raise_application_error(-20001,pr_dsmensag||vr_dscritic,pr_idempilh);
    end if;
    --
  end pc_raise_error;
  --
  procedure pc_captura_registra_log(pr_cdcooper_in in  craptab.cdcooper%type
                                   ,pr_dsmensag in varchar2) is
    --
    /*captura as informações da exceção e grava o log*/
    --
    vr_dscritic varchar2(4000);
    --
  begin
    --
    vr_dscritic := pr_dsmensag
                 ||dbms_utility.format_error_backtrace
          ||' - '||dbms_utility.format_error_stack;
    --
    pc_controla_log_batch(pr_cdcooper_in   => pr_cdcooper_in
                         ,pr_dstiplog      => 'E'
                         ,pr_dscritic      => vr_dscritic
                         ,pr_cdcriticidade => 1
                         ,pr_cdmensagem    => 0);
    --
  end pc_captura_registra_log;
  --
---------------------------------------------------------------------------
----procedimentos relacionados ao negocio de registro de títulos na CIP----
---------------------------------------------------------------------------
  --
  function fn_qtd_reg_lote_jdnpc return number is
    --
    /*funcao que retorna a quantidade de registros por lote parametrizada*/
    --
    vr_dstextab craptab.dstextab%TYPE;
    vr_qtregist number(10) := 0;
    --
  begin
    --
    begin
      --> Buscar parametro de carga inicial de faixa de rollout
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'QTD_REG_LOTE_JDNPC'
                                               ,pr_tpregist => 0);
      --
      vr_qtregist := nvl(to_number(vr_dstextab),0);
      --
      if nvl(vr_qtregist,0) = 0 then
        --
        vr_qtregist := 1000;
        --
      end if;
      --
    exception
      when others then
        begin
          --
          pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper
                                 ,pr_dsmensag => 'fn_qtd_reg_lote_jdnpc:');
          --
          vr_qtregist := 1000;
          --
        end;
    end;
    --
    return vr_qtregist;
    --
  end fn_qtd_reg_lote_jdnpc;
  --
  function fn_sacado_dda(pr_tppessoa in varchar2 -- Tipo de pessoa
                        ,pr_nrcpfcgc in number   -- Cpf ou CNPJ
                        ,pr_tab_sab  in out nocopy t_tab_sab
                        ) return integer is
    --
    vr_cdidesab varchar2(17);
    vr_flsacdda integer;
    vr_cdcritic number;
    vr_dscritic varchar2(32000);
    --exceptions
    vr_exc_saida exception;
    --
  begin
    --
    vr_cdidesab := pr_tppessoa||to_char(pr_nrcpfcgc,'fm0000000000000000');
    --
    if pr_tab_sab.exists(vr_cdidesab) then
      --
      vr_flsacdda := pr_tab_sab(vr_cdidesab).flsacdda;
      --
    else
      --
      ddda0001.pc_verifica_sacado_dda(pr_tppessoa => pr_tppessoa
                                     ,pr_nrcpfcgc => pr_nrcpfcgc
                                     ,pr_flgsacad => vr_flsacdda
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      --
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        --
        raise vr_exc_saida;
        --
      end if;
      --
      pr_tab_sab(vr_cdidesab).cdidesab := vr_cdidesab;
      pr_tab_sab(vr_cdidesab).flsacdda := vr_flsacdda;
      --
    end if;
    --
    return (vr_flsacdda);
    --
  exception
    when vr_exc_saida then
      begin
        --
        if nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
          -- buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;
        -- Log de erro da execução
        pc_controla_log_batch(pr_cdcooper_in   => pr_cdcooper
                             ,pr_dstiplog      => 'E'
                             ,pr_dscritic      => vr_dscritic
                             ,pr_cdcriticidade => 1
                             ,pr_cdmensagem    => vr_cdcritic);
        --
        raise_application_error(-20001,'fn_sacado_dda('||pr_tppessoa||'-'||pr_nrcpfcgc||')');
        --
      end;
    when others then
      begin
        --
        pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper
                               ,pr_dsmensag => 'fn_sacado_dda('||pr_tppessoa||'-'||pr_nrcpfcgc||'):');
        --
        raise_application_error(-20001,'fn_sacado_dda',true);
        --
      end;
  end fn_sacado_dda;
  --
  function fn_valida_titulo(pr_cdcooper_in in crapcop.cdcooper%type
                           ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                           ,pr_idcrgini number
                           ,pr_crapcob_rowid rowid
                           ,pr_vltitulo number
                           ,pr_tppsssab varchar2
                           ,pr_nrinssac crapsab.nrinssac%type
                           ,pr_tab_sab in out nocopy t_tab_sab) return number is
    --
    /*executa as validações padrão do título*/
    --
    vr_idregdes number(1) := 0;
    vr_flgrollt integer := 0;
    vr_flgsacad number := 0;
    vr_des_erro varchar2(10);
    vr_dscritic varchar2(4000);
    --
  begin
    --
    -- Tratamento para nao enviar para a cabine pois a cabine existe essa limitaçao de valor 
    if pr_vltitulo > ct_vllimcab then
      --
      vr_idregdes := 1;
      -- Cria o log da cobrança
      paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_crapcob_rowid
                                   ,pr_cdoperad => ct_cdoperad
                                   ,pr_dtmvtolt => sysdate
                                   ,pr_dsmensag => 'Falha no envio para a CIP (valor superior ao suportado)'
                                   ,pr_des_erro => vr_des_erro
                                   ,pr_dscritic => vr_dscritic);
      -- se ocorrer erro
      if vr_des_erro <> 'OK' then
        raise_application_error(-20001,'Cria log valor: '||vr_dscritic);
      end if;
      --
    end if;
    --
    --se não é carga inicial e registro não foi desconsiderado então validar proxima regra
    if pr_idcrgini = 0 and vr_idregdes = 0 then
      --> Verificar rollout da plataforma de cobrança
      vr_flgrollt := NPCB0001.fn_verifica_rollout(pr_cdcooper => pr_cdcooper_in
                                                 ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt
                                                 ,pr_vltitulo => pr_vltitulo
                                                 ,pr_tpdregra => 1);--1-registro
      --
      --se o valor estiver fora da faixa de rollout então verficar se pagador DDA
      if vr_flgrollt = 0 then
        --
        vr_flgsacad := fn_sacado_dda(pr_tppessoa => pr_tppsssab
                                    ,pr_nrcpfcgc => pr_nrinssac
                                    ,pr_tab_sab  => pr_tab_sab);
        --
        --se o pagador não é DDA então deve desconsiderar o registro
        if vr_flgsacad <> 1 then
          --
          vr_idregdes := 1;
          --
        end if;
        --
      end if;
      --
    end if;
    --
    return vr_idregdes;
    --
  end fn_valida_titulo;
  --
  procedure pc_atualiza_status_envio_dda(pr_tab_remessa_dda in out ddda0001.typ_tab_remessa_dda
                                        ,pr_tpdenvio        in integer) is  --> tipo de envio(0-Normal/Batch, 1-Online, 2-Carga inicial)    
    --
    vr_index     integer;
    vr_dscmplog  varchar2(200);
    vr_des_erro  varchar2(10);
    vr_dscritic  varchar2(4000);
    --
  begin
    --
    vr_index := pr_tab_remessa_dda.FIRST;
    --
    while vr_index is not null loop      
      -- Verifica se ocorreu erro
      if trim(pr_tab_remessa_dda(vr_index).dscritic) is not null then
        -- Atualizar CRAPCOB 
        begin
          update crapcob
             set flgcbdda = 0 -- FALSE
                ,insitpro = 0
                ,idtitleg = 0
                ,idopeleg = 0
                ,inenvcip = 0 -- não enviar
                ,dhenvcip = null
           where rowid = pr_tab_remessa_dda(vr_index).rowidcob;
        exception
          when others then
            raise_application_error(-20001,'update crapcob 01',true);
        end;
      else
        -- Atualizar CRAPCOB 
        begin
          update crapcob
             set flgcbdda = 1 -- TRUE
                ,insitpro = 2 -- recebido JD
                ,inenvcip = 2 -- enviado
                ,dhenvcip = sysdate
           where rowid = pr_tab_remessa_dda(vr_index).rowidcob;           
        exception
          when others then
            raise_application_error(-20001,'update crapcob 02',true);
        end;
        --Definir complemento do log conforme tipo de envio
        vr_dscmplog := null;
        if pr_tpdenvio = 1 then
          vr_dscmplog := ' online';
        elsif pr_tpdenvio = 2 then
          vr_dscmplog := ' carga NPC';
        end if;
        -- Incluir o log do boleto
        paga0001.pc_cria_log_cobranca(pr_idtabcob => pr_tab_remessa_dda(vr_index).rowidcob
                                     ,pr_cdoperad => ct_cdoperad
                                     ,pr_dtmvtolt => sysdate
                                     ,pr_dsmensag => 'Titulo enviado a CIP'||vr_dscmplog
                                     ,pr_des_erro => vr_des_erro
                                     ,pr_dscritic => vr_dscritic);
        -- se ocorrer erro
        if vr_des_erro <> 'OK' then
          raise_application_error(-20001,'Cria log: '||vr_dscritic);
        end if;
        --
      end if;
      --
      vr_index := pr_tab_remessa_dda.next(vr_index);
      --
    end loop;
    --
  exception 
    when others then
      pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper
                             ,pr_dsmensag => 'pc_atualiza_status_envio_dda:');
  end pc_atualiza_status_envio_dda;
  --
  procedure pc_carga_inic_npc(pr_cdcooper_in in crapcop.cdcooper%type
                             ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                             ,pr_qtlottit in number
                             ,pr_tab_sab in out nocopy t_tab_sab) is
    --
    procedure pc_verifica_carga_inicial(pr_cdcooper_in in crapcop.cdcooper%type
                                       ,pr_idexecut out number
                                       ,pr_dtcrgrol out date
                                       ,pr_vlrollou out number) is
      --
      vr_dstextab   craptab.dstextab%TYPE;  
      vr_tab_campos gene0002.typ_split;  
      vr_idexecut   number(1) := 1; --inicializado como já processado
      vr_dtcrgrol   date;
      vr_vlrollou   number(15,2);
      --
    begin
      --
      --> Buscar parametro de carga inicial de faixa de rollout
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper_in
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'ROLLOUT_CIP_CARGA'
                                               ,pr_tpregist => 0);
      --
      vr_tab_campos:= gene0002.fn_quebra_string(vr_dstextab,';');
      --
      --se existir o parâmetro
      if nvl(vr_tab_campos.count,0) > 0 then
        --
        --inicilizar variáveis com os valores do parâmetro
        vr_idexecut := to_number(vr_tab_campos(1));
        vr_dtcrgrol := to_date(vr_tab_campos(2),'dd/mm/yyyy');
        vr_vlrollou := to_number(vr_tab_campos(3),'999999d99','NLS_NUMERIC_CHARACTERS = ''.,''');
        --
        --se a data parametrizada é maior que sysdate então deve indicar "já processado"
        --ou se data de movimento da CIP é diferente de sysdate
        --para evitar processamento da carga antes da data parametrizada
        if vr_dtcrgrol > trunc(sysdate) then
          --
          vr_idexecut := 1;
          --
        end if;
        --
        if vr_idexecut = 0 then
          --se ainda não processado então atualiza o parametro
          --para que na proxima execução não faça carga inicial novamente
          begin
            update craptab tab
               set tab.dstextab = '1'||substr(tab.dstextab,2)
             where cdcooper        = pr_cdcooper_in
               and upper(nmsistem) = 'CRED'
               and upper(tptabela) = 'GENERI'
               and cdempres        = 0
               and upper(cdacesso) = 'ROLLOUT_CIP_CARGA'
               and tpregist        = 0; 
          exception 
            when others then
              raise_application_error(-20001,'update craptab('||pr_cdcooper_in||')');
          end;
          --
          --commit para garantir que outras sessões peguem o parâmetro atualizado e sem lock
          commit;
          --
        end if;
        --
      end if;
      --
      pr_idexecut := vr_idexecut;
      pr_dtcrgrol := vr_dtcrgrol;
      pr_vlrollou := vr_vlrollou;
      --
    exception
      when others then
        begin
          --
          pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_dsmensag => 'pc_verifica_carga_inicial(Cooper:'||pr_cdcooper_in||'):');
          --
          rollback;
          raise_application_error(-20001,'pc_verifica_carga_inicial',true);
          --
        end;
    end pc_verifica_carga_inicial;
    --
    procedure pc_processa_carga_inicial(pr_cdcooper_in in craptab.cdcooper%type
                                       ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                                       ,pr_dtcrgrol in date
                                       ,pr_vlrollou in number) is
      --
      --cursor que busca somente o rowid do título para formar os lotes
      cursor c_lote_tit(pr_cdcooper_cr in crapcop.cdcooper%type
                       ,pr_dtcrgrol_cr in date
                       ,pr_vlrollou_cr in number) is
        select /*+index(cop CRAPCOP##CRAPCOP1, cco CRAPCCO##CRAPCCO1, cob CRAPCOB##CRAPCOB9)*/
               cob.rowid crapcob_rowid
        from crapcob cob
            ,crapcco cco
            ,crapcop cop
        where 
          --deve existir o pagador na base do cooperado
              exists (
                      select 1
                      from crapsab sab
                      where sab.cdcooper = cob.cdcooper+0
                        and sab.nrdconta = cob.nrdconta+0
                        and sab.nrinssac = cob.nrinssac+0
                     )
          --
          --Se titulo Cooperativa/EE e nao foi enviado ainda para a PG, nao enviar ao DDA 
          --INC0025924 and not (cob.inemiten = 3 and cob.inemiexp <> 2)
          and cob.flgregis = 1 /*cobranca registrada*/
          and cob.incobran = 0 /*aberto*/
          and cob.dtdpagto is null /*sem data de pagamento*/
          and cob.vltitulo >= pr_vlrollou_cr
          and nvl(cob.nrdident,0) = 0 /*sem o número unico da Cabine JDNPC*/
          and nvl(cob.idtitleg,0) = 0 /*sem o número unico do Ayllos/NPC*/
          and cob.nrcnvcob = cco.nrconven+0
          and cob.dtvencto+0 >= trunc(sysdate) /*CIP não aceita título vencido*/
          and cob.dtvencto >= pr_dtcrgrol_cr
          and cob.cdcooper = cco.cdcooper+0
          --
          and cco.flgregis = 1 /*convenios de cobranca com registro*/
          and cco.cddbanco = cop.cdbcoctl+0 /*somente do banco controlador da cooperativa singular*/
          and cco.cdcooper = cop.cdcooper+0
          --
          and cop.cdcooper = pr_cdcooper_cr;
      --
      --cursor que busca o título com os mesmos critérios do cursor de lote
      --como o sistema é on-line e vários jobs estão executando simultaneamente
      --é importante validar se o título ainda atende às condições para integração
      cursor cr_titulo(pr_crapcob_rowid in rowid
                      ,pr_cdcooper_cr in crapcop.cdcooper%type
                      ,pr_dtcrgrol_cr in date
                      ,pr_vlrollou_cr in number) is
        select /*+index(cop CRAPCOP##CRAPCOP1, cco CRAPCCO##CRAPCCO1)*/
               cob.rowid crapcob_rowid
              ,cob.vltitulo
              ,cob.dtvencto
              ,cob.vldescto
              ,cob.vlabatim
              ,cob.flgdprot
              ,decode(cob.cdtpinsc
                 ,1,'F'
                 ,'J') tppsssab
              ,cob.nrinssac
        from crapcco cco
            ,crapcop cop
            ,crapcob cob
        where cco.flgregis = 1 /*convenios de cobranca com registro*/
          and cco.cddbanco = cop.cdbcoctl+0 /*somente do banco controlador da cooperativa singular*/
          and cco.nrconven = cob.nrcnvcob+0
          and cco.cdcooper = cop.cdcooper+0
          --
          and cop.cdcooper = cob.cdcooper+0
          --
          --deve existir o pagador na base do cooperado
          and exists (
                      select 1
                      from crapsab sab
                      where sab.cdcooper = cob.cdcooper+0
                        and sab.nrdconta = cob.nrdconta+0
                        and sab.nrinssac = cob.nrinssac+0
                     )
          --
          --Se titulo Cooperativa/EE e nao foi enviado ainda para a PG, nao enviar ao DDA 
          --INC0025924 and not (cob.inemiten = 3 and cob.inemiexp <> 2)
          and cob.flgregis = 1 /*cobranca registrada*/
          and cob.incobran = 0 /*aberto*/
          and cob.dtdpagto is null /*sem data de pagamento*/
          and cob.vltitulo >= pr_vlrollou_cr
          and nvl(cob.nrdident,0) = 0 /*sem o número unico da Cabine JDNPC*/
          and nvl(cob.idtitleg,0) = 0 /*sem o número unico do Ayllos/NPC*/
          and cob.dtvencto+0 >= trunc(sysdate) /*CIP não aceita título vencido*/
          and cob.dtvencto+0 >= pr_dtcrgrol_cr
          and cob.cdcooper+0 = pr_cdcooper_cr
          and cob.rowid = pr_crapcob_rowid
        order by cob.nrinssac;
      rw_titulo cr_titulo%rowtype;
      --
      vr_tab_lote_titulo typ_tab_lote_titulo;
      vr_tab_remessa_dda ddda0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda ddda0001.typ_tab_retorno_dda;
      --
      vr_crapcob_rowid rowid;
      vr_idregprc number(1);
      vr_idregdes number(1);
      vr_qtregist number(10) := 0;
      vr_cdcritic number;
      vr_dscritic varchar2(32000);
      --
    begin
      --
      --abertura do cursor geral de títulos da cooperativa
      open c_lote_tit(pr_cdcooper_cr => pr_cdcooper_in
                     ,pr_dtcrgrol_cr => pr_dtcrgrol
                     ,pr_vlrollou_cr => pr_vlrollou);
      loop
        --
        vr_tab_lote_titulo.delete;
        vr_tab_remessa_dda.delete;
        vr_tab_retorno_dda.delete;
        --fetch de titulos em lotes
        fetch c_lote_tit bulk collect into vr_tab_lote_titulo limit pr_qtlottit;
        exit when nvl(vr_tab_lote_titulo.count,0) = 0;
        --
        --tratamento do lote de títulos
        for i in vr_tab_lote_titulo.first .. vr_tab_lote_titulo.last
        loop
          --
          begin
            --
            vr_idregprc := 0; --marcar o registro como não processado
            vr_idregdes := 0; --marcar o registro como considerado na integração
            vr_crapcob_rowid := vr_tab_lote_titulo(i).crapcob_rowid;
            --
            open cr_titulo(pr_crapcob_rowid => vr_crapcob_rowid
                          ,pr_cdcooper_cr => pr_cdcooper_in
                          ,pr_dtcrgrol_cr => pr_dtcrgrol
                          ,pr_vlrollou_cr => pr_vlrollou);
            fetch cr_titulo into rw_titulo;
            --se o cursor não retornou nada é porque o registro já foi processado por outro job
            if cr_titulo%notfound then
              --
              vr_idregprc := 1; --marcar o registro como processado
              --
            end if;
            close cr_titulo;
            --
            --se ainda não foi processado proseguir com a validação
            if vr_idregprc = 0 then
              --
              vr_idregdes := fn_valida_titulo(pr_cdcooper_in => pr_cdcooper_in
                                             ,pr_rw_crapdat => pr_rw_crapdat
                                             ,pr_idcrgini => 1 --carga inicial
                                             ,pr_crapcob_rowid => rw_titulo.crapcob_rowid
                                             ,pr_vltitulo => rw_titulo.vltitulo
                                             ,pr_tppsssab => rw_titulo.tppsssab
                                             ,pr_nrinssac => rw_titulo.nrinssac
                                             ,pr_tab_sab => pr_tab_sab);
              --
              --se não deve ser desconsiderado então preparar integração com JDNPC
              if vr_idregdes = 0 then
                --
                ddda0001.pc_cria_remessa_dda(pr_rowid_cob => rw_titulo.crapcob_rowid
                                            ,pr_tpoperad => 'I'
                                            ,pr_tpdbaixa => null
                                            ,pr_dtvencto => rw_titulo.dtvencto
                                            ,pr_vldescto => rw_titulo.vldescto
                                            ,pr_vlabatim => rw_titulo.vlabatim
                                            ,pr_flgdprot => (case rw_titulo.flgdprot when 0 then false else true end)
                                            ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                --
                pc_raise_error('ddda0001.pc_cria_remessa_dda:',vr_cdcritic,vr_dscritic,false);
                --
                vr_qtregist := vr_qtregist + 1;
                --
              end if;
              --
            end if;
            --
          exception
            when others then
              begin
                --
                vr_iderro := 'S';--ocorreu erro no processamento
                --
                pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                       ,pr_dsmensag => 'Lote titulos(rowid:'||vr_crapcob_rowid||'):');
                --
                --executa rollback do lote, limpa tabelas de memoria e sai do loop deste lote
                rollback;
                vr_tab_lote_titulo.delete;
                vr_tab_remessa_dda.delete;
                vr_tab_retorno_dda.delete;
                exit;
                --
              end;
          end;
          --
        end loop; --loop tab_lote_titulo
        --
        begin
          -- Realizar a remessa de títulos DDA
          if nvl(vr_tab_remessa_dda.count,0) > 0 then
            --
            ddda0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tab_remessa_dda
                                           ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                           ,pr_cdcritic        => vr_cdcritic
                                           ,pr_dscritic        => vr_dscritic);
            -- Verificar se ocorreu erro
            pc_raise_error('ddda0001.pc_remessa_tit_tab_dda:',vr_cdcritic,vr_dscritic,false);
            --
            -- Atualizar status da remessa de títulos DDA      
            pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tab_remessa_dda
                                        ,pr_tpdenvio        => 2);
            --
            --commit para cada lote de títulos integrados com a JDNPC
            commit;
            --
          end if;
          --
        exception
          when others then
            begin
              --
              vr_iderro := 'S';--ocorreu erro no processamento
              --
              pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                     ,pr_dsmensag => 'Remessa titulos JDNPC:');
              --
              --executa rollback do lote, limpa tabelas de memoria e vai para o próximo lote
              rollback;
              vr_tab_lote_titulo.delete;
              vr_tab_remessa_dda.delete;
              vr_tab_retorno_dda.delete;
              --
            end;
        end;
        --
      end loop; --loop c_lote_tit
      close c_lote_tit;
      --
      --antes de encerrar o procedimento limpa as tabelas de memoria
      vr_tab_lote_titulo.delete;
      vr_tab_remessa_dda.delete;
      vr_tab_retorno_dda.delete;
      --
      --commit final do procedimento
      commit;
      npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_01');
      --
    exception
      when others then
        begin
          --
          vr_iderro := 'S';--ocorreu erro no processamento
          --
          pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_dsmensag => 'pc_processa_carga_inicial(Cooper:'||pr_cdcooper_in||'):');
          --
          rollback;
          npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_02');
          raise_application_error(-20001,'pc_processa_carga_inicial',true);
          --
        end;
    end pc_processa_carga_inicial;
    --
  begin
    --
    declare
      --
      vr_idexecut number(1);
      vr_dtcrgrol date;
      vr_vlrollou number(15,2);
      --
    begin
      --
      pc_verifica_carga_inicial(pr_cdcooper_in => pr_cdcooper_in
                               ,pr_idexecut => vr_idexecut
                               ,pr_dtcrgrol => vr_dtcrgrol
                               ,pr_vlrollou => vr_vlrollou);
      --
      --se retornar 0 então deve realizar a carga inicial da faixa de rollout
      if nvl(vr_idexecut,1) = 0 then
        --
        pc_processa_carga_inicial(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_rw_crapdat => pr_rw_crapdat
                                 ,pr_dtcrgrol => vr_dtcrgrol
                                 ,pr_vlrollou => vr_vlrollou);
        --
      end if;
      --
    exception
      when others then
        begin
          --
          pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_dsmensag => 'pc_carga_inic_npc(Cooper:'||pr_cdcooper_in||'):');
          --
          rollback;
          raise_application_error(-20001,'pc_carga_inic_npc',true);
          --
        end;
    end;
    --
  end pc_carga_inic_npc;
  --
  procedure pc_carga_normal_npc(pr_cdcooper_in in crapcop.cdcooper%type
                               ,pr_nrdconta_in in crapcob.nrdconta%type
                               ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                               ,pr_qtlottit in number
                               ,pr_tab_sab in out nocopy t_tab_sab) is
    --
    procedure pc_processa_carga_normal(pr_cdcooper_in in craptab.cdcooper%type
                                      ,pr_rw_crapdat in btch0001.cr_crapdat%rowtype
                                      ,pr_nrdconta_in in crapcob.nrdconta%type) is
      --
      --cursor que busca somente o rowid do título para formar os lotes
      cursor c_lote_tit(pr_cdcooper_cr in crapcop.cdcooper%type
                       ,pr_nrdconta_cr in crapcob.nrdconta%type
                       ,pr_rw_crapdat_cr in btch0001.cr_crapdat%rowtype) is
        select /*+index(cob CRAPCOB##CRAPCOB12, cco CRAPCCO##CRAPCCO1, cop CRAPCOP##CRAPCOP1)*/
               cob.rowid crapcob_rowid
        from crapcop cop
            ,crapcco cco
            ,crapcob cob
        where cop.cdbcoctl = cco.cddbanco+0 /*somente do banco controlador da cooperativa singular*/
          and cop.cdcooper = cco.cdcooper+0
          --
          --deve existir o pagador na base do cooperado
          and exists (
                      select 1
                      from crapsab sab
                      where sab.cdcooper = cob.cdcooper+0
                        and sab.nrdconta = cob.nrdconta+0
                        and sab.nrinssac = cob.nrinssac+0
                     )
          --
          and cco.flgregis = 1 /*convenios de cobranca com registro*/
          and cco.nrconven = cob.nrcnvcob+0
          and cco.cdcooper = cob.cdcooper+0
          --Se titulo Cooperativa/EE e nao foi enviado ainda para a PG, nao enviar ao DDA 
          --INC0025924 and not (cob.inemiten = 3 and cob.inemiexp <> 2)
          and cob.flgregis+0 = 1 /*cobranca registrada*/
          and cob.incobran+0 = 0 /*aberto*/
          and trunc(cob.dtdpagto) is null /*sem data de pagamento*/
          and nvl(cob.nrdident,0) = 0 /*sem o número unico da Cabine JDNPC*/
          and nvl(cob.idtitleg,0) = 0 /*sem o número unico do Ayllos/NPC*/
          and (cob.nrdconta = pr_nrdconta_cr or nvl(pr_nrdconta_cr,0) = 0)
          and ((nvl(pr_nrdconta_cr,0) > 0 and cob.inregcip = 1) or (nvl(pr_nrdconta_cr,0) = 0 ))
          and cob.dtvencto+0 >= trunc(sysdate) /*CIP não aceita título vencido*/
          and cob.dtmvtolt+0 >= (pr_rw_crapdat_cr.dtmvtolt-7)
          and cob.inenvcip = 1 /*a enviar*/
          and cob.cdcooper = pr_cdcooper_cr;
      --
      --cursor que busca o título com os mesmos critérios do cursor de lote
      --como o sistema é on-line e vários jobs estão executando simultaneamente
      --é importante validar se o título ainda atende às condições para integração
      cursor cr_titulo(pr_crapcob_rowid in rowid
                      ,pr_cdcooper_cr in crapcop.cdcooper%type
                      ,pr_nrdconta_cr in crapcob.nrdconta%type
                      ,pr_rw_crapdat_cr in btch0001.cr_crapdat%rowtype) is
        select /*+index(cop CRAPCOP##CRAPCOP1, cco CRAPCCO##CRAPCCO1)*/
               cob.rowid crapcob_rowid
              ,cob.vltitulo
              ,cob.dtvencto
              ,cob.vldescto
              ,cob.vlabatim
              ,cob.flgdprot
              ,decode(cob.cdtpinsc
                 ,1,'F'
                 ,'J') tppsssab
              ,cob.nrinssac
        from crapcco cco
            ,crapcop cop
            ,crapcob cob
        where cco.flgregis = 1 /*convenios de cobranca com registro*/
          and cco.cddbanco = cop.cdbcoctl+0 /*somente do banco controlador da cooperativa singular*/
          and cco.nrconven = cob.nrcnvcob+0
          and cco.cdcooper = cop.cdcooper+0
          --
          and cop.cdcooper = cob.cdcooper+0
          --
          --deve existir o pagador na base do cooperado
          and exists (
                      select 1
                      from crapsab sab
                      where sab.cdcooper = cob.cdcooper+0
                        and sab.nrdconta = cob.nrdconta+0
                        and sab.nrinssac = cob.nrinssac+0
                     )
          --
          --Se titulo Cooperativa/EE e nao foi enviado ainda para a PG, nao enviar ao DDA 
          --INC0025924 and not (cob.inemiten = 3 and cob.inemiexp <> 2)
          and cob.flgregis+0 = 1 /*cobranca registrada*/
          and cob.incobran+0 = 0 /*aberto*/
          and trunc(cob.dtdpagto) is null /*sem data de pagamento*/
          and nvl(cob.nrdident,0) = 0 /*sem o número unico da Cabine JDNPC*/
          and nvl(cob.idtitleg,0) = 0 /*sem o número unico do Ayllos/NPC*/
          and (cob.nrdconta = pr_nrdconta_cr or nvl(pr_nrdconta_cr,0) = 0)
          and ((nvl(pr_nrdconta_cr,0) > 0 and cob.inregcip = 1) or (nvl(pr_nrdconta_cr,0) = 0 ))
          and cob.dtvencto+0 >= trunc(sysdate) /*CIP não aceita título vencido*/
          and cob.dtmvtolt+0 >= (pr_rw_crapdat_cr.dtmvtolt-7)
          and cob.inenvcip = 1 /*a enviar*/
          and cob.cdcooper+0 = pr_cdcooper_cr
          and cob.rowid = pr_crapcob_rowid
        order by cob.nrinssac;
      rw_titulo cr_titulo%rowtype;
      --
      vr_tab_lote_titulo typ_tab_lote_titulo;
      vr_tab_remessa_dda ddda0001.typ_tab_remessa_dda;
      vr_tab_retorno_dda ddda0001.typ_tab_retorno_dda;
      --
      vr_crapcob_rowid rowid;
      vr_idregprc number(1);
      vr_idregdes number(1);
      vr_tpdenvio number(1);
      vr_qtregist number(10) := 0;
      vr_cdcritic number;
      vr_dscritic varchar2(32000);
      --
    begin
      --
      --abertura do cursor geral de títulos da cooperativa
      open c_lote_tit(pr_cdcooper_cr => pr_cdcooper_in
                     ,pr_nrdconta_cr => pr_nrdconta_in
                     ,pr_rw_crapdat_cr => pr_rw_crapdat);
      loop
        --
        vr_tpdenvio := 0;
        if nvl(pr_nrdconta_in,0) <> 0 then
          vr_tpdenvio := 1;
        END IF;
        --
        vr_tab_lote_titulo.delete;
        vr_tab_remessa_dda.delete;
        vr_tab_retorno_dda.delete;
        --fetch de titulos em lotes
        fetch c_lote_tit bulk collect into vr_tab_lote_titulo limit pr_qtlottit;
        exit when nvl(vr_tab_lote_titulo.count,0) = 0;
        --
        --tratamento do lote de títulos
        for i in vr_tab_lote_titulo.first .. vr_tab_lote_titulo.last
        loop
          --
          begin
            --
            vr_idregprc := 0; --marcar o registro como não processado
            vr_idregdes := 0; --marcar o registro como considerado na integração
            vr_crapcob_rowid := vr_tab_lote_titulo(i).crapcob_rowid;
            --
            open cr_titulo(pr_crapcob_rowid => vr_crapcob_rowid
                          ,pr_cdcooper_cr => pr_cdcooper_in
                          ,pr_nrdconta_cr => pr_nrdconta_in
                          ,pr_rw_crapdat_cr => pr_rw_crapdat);
            fetch cr_titulo into rw_titulo;
            --se o cursor não retornou nada é porque o registro já foi processado por outro job
            if cr_titulo%notfound then
              --
              vr_idregprc := 1; --marcar o registro como processado
              --
            end if;
            close cr_titulo;
            --
            --se ainda não foi processado proseguir com a validação
            if vr_idregprc = 0 then
              --
              vr_idregdes := fn_valida_titulo(pr_cdcooper_in => pr_cdcooper_in
                                             ,pr_rw_crapdat => pr_rw_crapdat
                                             ,pr_idcrgini => 0 --carga normal
                                             ,pr_crapcob_rowid => rw_titulo.crapcob_rowid
                                             ,pr_vltitulo => rw_titulo.vltitulo
                                             ,pr_tppsssab => rw_titulo.tppsssab
                                             ,pr_nrinssac => rw_titulo.nrinssac
                                             ,pr_tab_sab => pr_tab_sab);
              --
              --se não deve ser desconsiderado então preparar integração com JDNPC
              if vr_idregdes = 0 then
                --
                ddda0001.pc_cria_remessa_dda(pr_rowid_cob => rw_titulo.crapcob_rowid
                                            ,pr_tpoperad => 'I'
                                            ,pr_tpdbaixa => null
                                            ,pr_dtvencto => rw_titulo.dtvencto
                                            ,pr_vldescto => rw_titulo.vldescto
                                            ,pr_vlabatim => rw_titulo.vlabatim
                                            ,pr_flgdprot => (case rw_titulo.flgdprot when 0 then false else true end)
                                            ,pr_tab_remessa_dda => vr_tab_remessa_dda
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
                --
                pc_raise_error('ddda0001.pc_cria_remessa_dda:',vr_cdcritic,vr_dscritic,false);
                --
                vr_qtregist := vr_qtregist + 1;
                --
              else
                --
                -- Atualizar CRAPCOB 
                begin
                  update crapcob
                     set flgcbdda = 0 -- FALSE
                       , insitpro = 0
                       , inenvcip = 0 -- não enviar
                       , dhenvcip = null
                       , inregcip = 0 -- sem registro na CIP
                   where rowid = rw_titulo.crapcob_rowid;
                exception
                  when others then
                    raise_application_error(-20001,'update crapcob 03',true);
                end;
                --
              end if;
              --
            end if;
            --
          exception
            when others then
              begin
                --
                vr_iderro := 'S';--ocorreu erro no processamento
                --
                pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                       ,pr_dsmensag => 'Lote titulos(rowid:'||vr_crapcob_rowid||'):');
                --
                vr_tab_lote_titulo.delete;
                vr_tab_remessa_dda.delete;
                vr_tab_retorno_dda.delete;
                --rollback somente se não é integração on-line
                if nvl(pr_nrdconta_in,0) = 0 then
                  --executa rollback do lote, limpa tabelas de memoria e sai do loop deste lote
                  rollback;
                else
                  raise_application_error(-20001,'cria remessa',true);
                end if;
                --
                exit;
                --
              end;
          end;
          --
        end loop; --loop tab_lote_titulo
        --
        begin
          -- Realizar a remessa de títulos DDA
          if nvl(vr_tab_remessa_dda.count,0) > 0 then
            --
            ddda0001.pc_remessa_tit_tab_dda(pr_tab_remessa_dda => vr_tab_remessa_dda
                                           ,pr_tab_retorno_dda => vr_tab_retorno_dda
                                           ,pr_cdcritic        => vr_cdcritic
                                           ,pr_dscritic        => vr_dscritic);
            -- Verificar se ocorreu erro
            pc_raise_error('ddda0001.pc_remessa_tit_tab_dda:',vr_cdcritic,vr_dscritic,false);
            --
            -- Atualizar status da remessa de títulos DDA      
            pc_atualiza_status_envio_dda(pr_tab_remessa_dda => vr_tab_remessa_dda
                                        ,pr_tpdenvio        => vr_tpdenvio);
            --
            --commit somente se não é integração on-line
            if nvl(pr_nrdconta_in,0) = 0 then
              --commit para cada lote de títulos integrados com a JDNPC
              commit;
              --
            end if;
            --
          end if;
          --
        exception
          when others then
            begin
              --
              vr_iderro := 'S';--ocorreu erro no processamento
              --
              pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                     ,pr_dsmensag => 'Remessa titulos JDNPC:');
              --
              vr_tab_lote_titulo.delete;
              vr_tab_remessa_dda.delete;
              vr_tab_retorno_dda.delete;
              --
              --rollback somente se não é integração on-line
              if nvl(pr_nrdconta_in,0) = 0 then
                --executa rollback do lote, limpa tabelas de memoria e vai para o próximo lote
                rollback;
              else
                raise_application_error(-20001,'remessa titulos',true);
              end if;
              --
            end;
        end;
        --
      end loop; --loop c_lote_tit
      close c_lote_tit;
      --
      --antes de encerrar o procedimento limpa as tabelas de memoria
      vr_tab_lote_titulo.delete;
      vr_tab_remessa_dda.delete;
      vr_tab_retorno_dda.delete;
      --
      --commit somente se não é integração on-line
      if nvl(pr_nrdconta_in,0) = 0 then
        --commit final do procedimento
        commit;
        npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_03');
        --
      end if;
      --
    exception
      when others then
        begin
          --
          vr_iderro := 'S';--ocorreu erro no processamento
          --
          pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_dsmensag => 'pc_processa_carga_normal(Cooper:'||pr_cdcooper_in||'):');
          --
          --rollback somente se não é integração on-line
          if nvl(pr_nrdconta_in,0) = 0 then
            rollback;
            npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_04');
          end if;
          --
          raise_application_error(-20001,'pc_processa_carga_normal',true);
          --
        end;
    end pc_processa_carga_normal;
    --
  begin
    --
    begin
      --
      pc_processa_carga_normal(pr_cdcooper_in => pr_cdcooper_in
                              ,pr_rw_crapdat => pr_rw_crapdat
                              ,pr_nrdconta_in => pr_nrdconta_in);
      --
    exception
      when others then
        begin
          --
          pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper_in
                                 ,pr_dsmensag => 'pc_carga_normal_npc(Cooper:'||pr_cdcooper_in||'):');
          --rollback somente se não é integração on-line
          if nvl(pr_nrdconta_in,0) = 0 then
            rollback;
            npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_05');
          end if;
          --
          raise_application_error(-20001,'pc_carga_normal_npc',true);
          --
        end;
    end;
    --
  end pc_carga_normal_npc;
  --
begin
  --
  gene0001.pc_set_modulo(pr_module => 'PC_'||upper(ct_cdprogra), pr_action => null);
  --
  pc_controla_log_batch(pr_cdcooper_in   => pr_cdcooper
                       ,pr_dstiplog      => 'I');
  --
  declare
    --
    vr_tab_sab t_tab_sab;
    --
    rw_crapdat  btch0001.cr_crapdat%ROWTYPE;
    vr_cdcritic number;
    vr_dscritic varchar2(32000);
    vr_qtlottit number(10);
    vr_jobname  varchar2(100);
    vr_dsplsql  varchar2(10000);
    vr_currenttimestamp timestamp with time zone;
    --exceptions
    vr_exc_saida exception;
    --
  begin
    --
    if to_date(ddda0001.fn_datamov,'yyyymmdd') = trunc(sysdate) then
      --
    --busca a data de processo da cooperativa
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    END IF;
    -- Fechar 
    CLOSE BTCH0001.cr_crapdat;
    --
    vr_tab_sab.delete;
    --
    ---------------------------------------
    --chamada raiz, a partir do crps618.p--
    ---------------------------------------
    if nvl(pr_cdcooper,0) = 3 and nvl(pr_nrdconta,0) = 0 then
      --
        --iniciliza horario de execução dos jobs para iniciarem todos em paralelo
        vr_currenttimestamp := to_timestamp_tz(to_char(CAST(current_timestamp AT TIME ZONE 'AMERICA/SAO_PAULO' AS timestamp)+(4/86400),'ddmmyyyyhh24miss')||' AMERICA/SAO_PAULO','ddmmyyyyhh24miss TZR');
        --
      for r_cop in (
                    select cop.cdcooper
                    from crapcop cop
                    where cop.cdcooper <> 3
                      and cop.flgativo = 1
                    order by cop.cdcooper
                   )
      loop
        --chama o proprio crps618 para cada cooperativa singular
        vr_jobname := 'JB618_COOP'||trim(to_char(r_cop.cdcooper,'00'))||'$';
        vr_dsplsql := 
'declare
  vr_cdcritic integer; 
  vr_dscritic varchar2(400);
begin
  pc_crps618(pr_cdcooper   => '||r_cop.cdcooper
         ||',pr_nrdconta  => 0'
         ||',pr_cdcritic  => vr_cdcritic '
         ||',pr_dscritic  => vr_dscritic );
end;';
        --
        gene0001.pc_submit_job(pr_cdcooper => r_cop.cdcooper
                              ,pr_cdprogra => ct_cdprogra
                              ,pr_dsplsql  => vr_dsplsql
                                ,pr_dthrexe  => vr_currenttimestamp
                              ,pr_interva  => NULL
                              ,pr_jobname  => vr_jobname
                              ,pr_des_erro => vr_dscritic );
        --
        if trim(vr_dscritic) is not null then
          --
          raise vr_exc_saida;
          --
        end if;
        --
      end loop;
      --
    ----------------------------------------------------------
    --chamada recursiva, a partir do próprio pc_crps618 raiz--
    ----------------------------------------------------------
    elsif nvl(pr_cdcooper,0) <> 3 and nvl(pr_nrdconta,0) = 0 then
      --
      vr_qtlottit := fn_qtd_reg_lote_jdnpc;
      --
      pc_carga_inic_npc(pr_cdcooper_in => pr_cdcooper
                       ,pr_rw_crapdat => rw_crapdat
                       ,pr_qtlottit => vr_qtlottit
                       ,pr_tab_sab => vr_tab_sab);
      --
      pc_carga_normal_npc(pr_cdcooper_in => pr_cdcooper
                         ,pr_nrdconta_in => nvl(pr_nrdconta,0)
                         ,pr_rw_crapdat => rw_crapdat
                         ,pr_qtlottit => vr_qtlottit
                         ,pr_tab_sab => vr_tab_sab);
      --
    ------------------------------
    --chamada do registro online--
    ------------------------------
    elsif nvl(pr_nrdconta,0) <> 0 then
      --
      vr_qtlottit := fn_qtd_reg_lote_jdnpc;
      --
      pc_carga_normal_npc(pr_cdcooper_in => pr_cdcooper
                         ,pr_nrdconta_in => nvl(pr_nrdconta,0)
                         ,pr_rw_crapdat => rw_crapdat
                         ,pr_qtlottit => vr_qtlottit
                         ,pr_tab_sab => vr_tab_sab);
      --
    end if;
    --
    vr_tab_sab.delete;
    --
    if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
      --
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      --
    end if;
    --
    end if;
    --
  exception
    when vr_exc_saida then
      begin
        --
        vr_iderro := 'S';--ocorreu erro no processamento
        -- Se foi retornado apenas código
        if nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
          -- buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        end if;
        -- Devolvemos código e critica encontradas
        --pr_cdcritic := nvl(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
        -- Log de erro da execução
        pc_controla_log_batch(pr_cdcooper_in   => pr_cdcooper
                             ,pr_dstiplog      => 'E'
                             ,pr_dscritic      => vr_dscritic
                             ,pr_cdcriticidade => 1
                             ,pr_cdmensagem    => vr_cdcritic);
        -- Efetuar rollback
        if nvl(pr_nrdconta,0) = 0 then
          rollback;
          npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_06');
        end if;
        --
      end;
    when others then
      begin
        --
        vr_iderro := 'S';--ocorreu erro no processamento
        --
        pc_captura_registra_log(pr_cdcooper_in => pr_cdcooper
                               ,pr_dsmensag => 'pc_crps618 Geral(Cooper:'||pr_cdcooper||'):');
        --
        pr_dscritic := 'pc_crps618 Geral(Cooper:'||pr_cdcooper||'):'||sqlerrm;
        -- Efetuar rollback
        if nvl(pr_nrdconta,0) = 0 then
          rollback;
          npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_07');
        end if;
        --
      end;
  end;
  --
  if vr_iderro = 'S' then
    --
    cobr0009.pc_notifica_cobranca(pr_dsassunt => 'CRPS618 - Falha ao enviar movimento da cobranca para JD'
                                 ,pr_dsmensag => 'Ocorreu falhar ao enviar movimento da cobranca bancaria para a Cabine JD.'
                                               ||' Entre em contato com a área de Sustentação de Sistemas para analise dos logs('||vr_idprglog||'). (PC_CRPS618)'
                                 ,pr_idprglog => vr_idprglog);
    --
  end if;
  --
  --commit somente se não é integração on-line
  if nvl(pr_nrdconta,0) = 0 then
    --commit final quando data de movimento da CIP é diferente de trunc(sysdate)
    commit;
    npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => 'pc_crps618_08');
    --
  end if;
  --
  pc_controla_log_batch(pr_cdcooper_in   => pr_cdcooper
                       ,pr_dstiplog      => 'F');
  --
end pc_crps618;
/
