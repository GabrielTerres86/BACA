CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS647(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                             ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada AS
  /* ..........................................................................

  Programa: pc_crps647                           Antigo: Fontes/crps647.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autora  : Lucas R.
  Data    : Setembro/2013                        Ultima atualizacao: 13/09/2017

  Dados referentes ao programa:

  Frequencia: Diario (Batch).
  Objetivo  : Integrar Arquivos de debitos de consorcios enviados pelo SICREDI.
              Emite relatorio 661 e 673.

  Alteracoes: 27/11/2013 - Incluido o RUN do fimprg no final do programa e onde 
                           a glb_cdcritic <> 0 antes do return. (Lucas R.)
                           
              10/12/2013 - Alterado crapndb.dtmvtolt para armazenar data de 
                           vencimneto do debito, (aux_setlinha,45,8).
                         - Substituido glb_dtmvtoan por glb_dtmvtolt (Lucas R.)
                         
              11/12/2013 - Ajustes na gravacao da crapndb para gravar posicao
                           70,60 (Lucas R.)
                           
              14/01/2014 - Alteracao referente a integracao Progress X 
                           Dataserver Oracle 
                           Inclusao do VALIDATE ( Andre Euzebio / SUPERO)       
                           
              20/01/2014 - Na critica 182 substituir NEXT por 
                           "RUN fontes/fimprg.p RETURN".
                         - Mover IF  glb_cdcritic <> 0 THEN RETURN para logo apos
                           o run fontes/iniprg.p. (Lucas R.)
                           
              12/02/2014 - Ajustes para importar arquivo de debito automatico
                           junto com o de consorcios - Softdesk 128107 (Lucas R)
                           
              18/02/2014 - Alterado craptab.cdacesso = "LOTEINT031" para
                           craptab.cdacesso = "LOTEINT032" - Softdesk 131871 
                           (Lucas R.)
                           
              04/04/2014 - Retirado craptab do LOTEINT032 e substituido por
                           aux_nrdolote = 6650.
                         - Na craplau adicionado ao create o campo cdempres 
                           (Lucas R)
                           
              23/05/2014 - incluido nas consultas da craplau
                           craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                           
              03/10/2014 - Alterado lo/proc_batch para log/proc_message.log
                           (Lucas R./Elton)             
                           
              24/03/2015 - Criada a function verificaUltDia e chamada sempre
                           que for criado um registro na crapndb ou craplau
                           (SD245218 - Tiago)
                           
              30/03/2015 - Alterado gravacao da crapass.cdagenci quando nao 
                           encontrar PA, na critica 961 (Lucas R. #265513)
                           
              08/04/2015 - Adicionado a data na frente do log do proc_message
                           (Tiago).             
  						 
              06/05/2015 - Retirado a gravacao do campo nrcrcard na tabela
                           craplau pois havia problemas de conversao com os 
                           dados que estavam vindo do arquivo FUT e este dado
                           acabava nao sendo usado posteriormente
                           SD282057 (Tiago/Fabricio).
                           
              14/08/2015 - Ajustes na busca de arquivos no diretorio do Connect.
                           (Chamado 276157) - (Fabricio)
                           
              04/09/2015 - Incluir validacao caso o cooperado esteja demitido 
                           (Lucas Ranghetti #324974)
                           
              21/09/2015 - Ajustes no processamento dos arquivos.
                           Gerar quoter em outro diretorio pois o diretorio do
                           Connect no Unix eh um mapeamento do servidor Connect
                           Windows e acontecem alguns problemas ao trabalhar com
                           arquivos dentro deste mapeamento. 
                           (Chamado 276157) - (Fabricio)
                           
              18/01/2016 - Ajuste na leitura da tabela CRAPCNS (consorcio) para
                           filtrar tambem pela conta Sicredi (quando um cooperado
                           possui duas contas e migra o consorcio de uma conta
                           para outra, o n. do contrato nao se altera e, como
                           o CPF eh o mesmo da falha no FIND porque retorna dois
                           registros). (Chamado 377579) - (Fabricio)
                           
              25/01/2016 - Incluido crapatr.dtfimatr = ? na verificacao da autorizacao,
                           pois autorizacao nao pode estar cancelada ao efetuar 
                           agendamento (Ranghetti #389327)
                           
              29/01/2016 - Incluir craplau.insitlau = 1 na busca do registro para 
                           cancelamento(Ranghetti #384817)
                         - Adicionar crapass para uma temp-table para ganhar performace
                           na execucao do programa (Ranghetti/Elton)
                           
                         
              19/05/2016 - Incluido ajuste para notificar cooperado qnd valor 
                           da fatura ultrapassar limite definido 
                           PRJ320 - Oferta DebAut (Odirlei-AMcom)  

              20/05/2016 - Incluido nas consultas da craplau
                           craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)
                            
              25/07/2016 - Se for o convenio 045, 14 BRT CELULAR - FEBRABAN e referencia conter 
                           um hifen no final, iremos despresar este hifen e seguir normalmente 
                           com o programa (Lucas Ranghetti #453337)
             
              03/08/2016 - Incluir crapndb para a critica 103 (Lucas Ranghetti #490987)
             
              14/09/2016 - Ajuste para somente verificar valor maximo para debito
                           caso lancamento nao seja de Consorcio (J5).
                           (Chamado 519962) - (Fabrício)
                            
              27/09/2016 - Ajuste para somente criar crapndb se nao for os registros "C" e "D"
                           (Lucas Ranghetti #507171)
               
              03/11/2016 - Conversao Progress >> Oracle PLSQL (Jonata-MOUTs)
              
              14/02/2017 - Incluir validacao para critica 502 para caso o sicredi nos
                           envie agendamento de debito com o valor zerado 
                           (Lucas Ranghetti #604860)
                           
              23/02/2017 - Retirado caracteres especiais na hora de exibir as 
                           criticas no relatorio 673 (Tiago/Fabricio #616085)
              03/03/2017 - Enviar e-mail para o convenios em caso de gerar algum erro inesperado.
                           (Lucas Ranghetti #622878)
                           
              06/03/2017 - Adicionar nvl para os campos nrdaviso e nrboleto ao atualizar
                           informações de consorcios (Lucas Ranghetti #623432)
                           
              13/03/2017 - Alterado para no registro 'C' quando cancelamento, gravar a data
                           do processamento e nao do inicio da autorização (Lucas Ranghetti #628127)
                           
              30/03/2017 - Somente enviar e-mail caso nao for a critica de arquivo nao existe (182)
                           e nao for na Cecred, as demais criticas seguem enviando normalmente
                           (Lucas Ranghetti #635894)

              11/04/2017 - Busca o nome resumido (Ricardo Linhares #547566)                           

              17/07/2017 - Ajustes para permitir o agendamento de lancamentos da mesma
                           conta e referencia no mesmo dia(dtmvtolt) porem com valores
                           diferentes (Lucas Ranghetti #684123)
                           
              01/08/2017 - Incluir tratamento para contas demitidas, exibir critica correta
                           no relatorio (Lucas Ranghetti #711763)

              13/09/2017 - Atribuir ao nome resumido o nome completo limitando em 20
                           caracteres. (Jaison/Aline - #744121)

   ............................................................................. */
  -- Constantes do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS647';
  vr_cdagenlt CONSTANT PLS_INTEGER := 1;
  vr_cdbccxlt CONSTANT PLS_INTEGER := 100;
  vr_cdbccxpg CONSTANT PLS_INTEGER := 11;
  vr_nrdolote CONSTANT PLS_INTEGER := 6650;
  
  -- Tratamento de erros
  vr_exc_fimprg EXCEPTION;
  vr_exc_saida  EXCEPTION;
  
  vr_dscritic varchar2(4000);
  vr_cdcritic crapcri.cdcritic%TYPE;

  /* Busca dos dados da cooperativa */
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT cop.nrctasic
          ,cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
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
       AND  craplau.insitlau <> 3;
  rw_craplau_dup cr_craplau_dup%ROWTYPE;
  
  /* Cursor generico de calendario */
  RW_CRAPDAT BTCH0001.CR_CRAPDAT%ROWTYPE;
  
  -- Variaveis auxiliares para o tratamento do arquivo
  vr_nmdirrec varchar2(200);
  vr_nmdirrcb varchar2(200);
  vr_digitmes CHAR(1);
  vr_nmarqmov varchar2(200);
  vr_nrdlinha NUMBER := 0;
  vr_contareg NUMBER := 1;
  vr_vldebito number := 0;
  vr_flgdupli boolean := FALSE;
  vr_geraerro boolean := FALSE;
  vr_flgclote boolean := TRUE;
  vr_nrdolote_sms NUMBER := 0;
  
  -- Variaveis para leitura linha a linha
  vr_diarefer pls_integer;
  vr_mesrefer pls_integer;
  vr_anorefer pls_integer;
  vr_dtrefere DATE;
  vr_tpregist char(1);
  vr_vllanmto NUMBER;
  vr_cdrefere VARCHAR2(25);
  vr_nmempres crapscn.dsnomcnv%type;
  vr_dsnomres crapscn.dsnomres%type;
  vr_dsnomsms crapscn.dsnomres%type;
  vr_cdempres crapscn.cdempres%type;
  vr_tpdebito NUMBER(1);
  vr_cdhistor craphis.cdhistor%type;
  vr_nrctacns crapass.nrctacns%type;
  vr_nrdconta crapass.nrdconta%TYPE;
  vr_cdagenci crapass.cdagenci%TYPE;
  vr_cdcrindb VARCHAR2(2);
  vr_critiarq VARCHAR2(2);
  vr_texto_email VARCHAR2(4000);
  vr_emaildst VARCHAR2(1000);
  vr_nrdocmto_int craplau.nrdocmto%TYPE; 
  
  -- Comandos no OS
  vr_typsaida varchar2(3);
  vr_dessaida varchar2(2000);
  
  -- Arquivo e informações em leitura 
  vr_arqhandle utl_file.file_type;
  vr_dslinharq varchar2(4000);
  
  -- Variaveis para os relatórios 
  vr_xmlrel_661 CLOB;
  vr_txtrel_661 VARCHAR2(32767);
  vr_xmlrel_673 CLOB;
  vr_txtrel_673 VARCHAR2(32767);
  vr_tot_qtdrejei NUMBER;
  vr_tot_vlpareje NUMBER;
  vr_tot_qtdreceb NUMBER;
  vr_tot_vlparceb NUMBER;
  vr_tot_qtdinteg NUMBER;
  vr_tot_vlpainte NUMBER;
  
  -- Estrutura para alimentar os dados dos relatórios 
  TYPE typ_reg_relato IS RECORD (cdcooper crapcop.cdcooper%type
                                ,nrdconta crapcns.nrdconta%type
                                ,cdrefere VARCHAR2(100)
                                ,vlparcns crapcns.vlparcns%type
                                ,nrctacns crapcns.nrctacns%type
                                ,dtdebito DATE
                                ,cdcritic PLS_INTEGER
                                ,dscritic VARCHAR2(1000)
                                ,tpdebito PLS_INTEGER
                                ,nmempres VARCHAR2(300) 
                                ,cdagenci PLS_INTEGER); 
  TYPE typ_tab_relato IS TABLE OF typ_reg_relato INDEX BY VARCHAR2(38);
  vr_tab_relato_661 typ_tab_relato; --> Consorcios
  vr_tab_relato_673 typ_tab_relato; --> Importacao de debitos
  vr_reg_relato typ_reg_relato; --> Registro temporário 
  vr_idx_relato VARCHAR2(38);   --> Indice: 3(Critica) + 5(PA) + 10(Conta) + 10(CtaConsorcio) + SeqLinha(10)
  
  -- Busca das empresas conveniadas
  CURSOR cr_crapcsn(pr_cdempres crapscn.cdempres%type) IS
    SELECT cdempres 
          ,dsnomcnv 
		  ,dsnomres
      FROM crapscn 
     WHERE cdempres = trim(pr_cdempres);
  
  -- Busca do cadastro de associados
  CURSOR cr_crapass IS
    SELECT nrctacns
          ,nrdconta
          ,cdagenci
          ,dtdemiss
      FROM crapass
     WHERE cdcooper = pr_cdcooper
       AND nrctacns <> 0;
  
  -- Registro para armazenar as contas
  TYPE typ_tab_crapass IS TABLE OF cr_crapass%ROWTYPE INDEX BY PLS_INTEGER;
  vr_tab_crapass typ_tab_crapass;
  
  -- Busca consorcio
  CURSOR cr_crapcns (pr_nrctrato crapcns.nrctrato%TYPE
                    ,pr_nrcpfcgc crapcns.nrcpfcgc%TYPE
                    ,pr_nrctacns crapcns.nrctacns%TYPE) IS
    SELECT tpconsor
          ,ROWID
      FROM crapcns
     WHERE cdcooper = pr_cdcooper 
       AND nrctrato = pr_nrctrato
       AND nrcpfcgc = pr_nrcpfcgc
       AND nrctacns = pr_nrctacns;
  rw_crapcns cr_crapcns%ROWTYPE;       
  
  -- Busca autorização de debito 
  CURSOR cr_crapatr(pr_nrdconta crapatr.nrdconta%TYPE
                   ,pr_cdempres crapatr.cdempres%TYPE
                   ,pr_cdrefere crapatr.cdrefere%TYPE
                   ,pr_flgativo VARCHAR DEFAULT 'S') IS
    SELECT rowid
          ,cdrefere
          ,dtiniatr
          ,dtfimatr
          ,ddvencto
          ,nmfatura
          ,flgmaxdb
          ,vlrmaxdb
          ,cdhistor
      FROM crapatr
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta 
       AND cdrefere = pr_cdrefere
       AND cdhistor = 1019  
       AND cdempres = pr_cdempres
       AND ( (pr_flgativo = 'S' AND dtfimatr is null ) OR pr_flgativo = 'N');
  rw_crapatr cr_crapatr%ROWTYPE;
  rw_crabatr cr_crapatr%ROWTYPE;
  
  -- Busca lançamento futuro 
  CURSOR cr_craplau(pr_nrdconta crapatr.nrdconta%TYPE
                   ,pr_dtrefere crapdat.dtmvtolt%TYPE 
                   ,pr_cdrefere crapatr.cdrefere%TYPE
                   ,pr_cdhistor craphis.cdhistor%TYPE) IS 
    SELECT 1
      FROM craplau 
     WHERE cdcooper = pr_cdcooper 
       AND nrdconta = pr_nrdconta 
       AND dtmvtopg = pr_dtrefere
       AND nrdocmto = pr_cdrefere
       AND cdhistor = pr_cdhistor 
       AND insitlau <> 3;
  vr_exislau number;     
  
  -- Busca lançamento no dia
  CURSOR cr_craplau_dia(pr_nrdconta crapatr.nrdconta%TYPE
                       ,pr_dtmvtolt crapdat.dtmvtolt%TYPE 
                       ,pr_cdrefere crapatr.cdrefere%TYPE) IS 
    SELECT 1
      FROM craplau 
     WHERE cdcooper = pr_cdcooper 
       AND dtmvtolt = pr_dtmvtolt
       AND cdagenci = vr_cdagenlt
       AND cdbccxlt = vr_cdbccxlt
       AND nrdolote = vr_nrdolote
       AND nrdconta = pr_nrdconta
       AND nrdocmto = pr_cdrefere;
  
  -- Verificar existencia de LOTE
  CURSOR cr_craplot(pr_dtmvtolt DATE) IS
    SELECT rowid nrrowid
          ,dtmvtolt
          ,cdagenci
          ,cdbccxlt
          ,cdbccxpg
          ,nrdolote
          ,tplotmov
          ,qtinfoln
          ,qtcompln
          ,vlinfodb
          ,vlcompdb
          ,nrseqdig
      FROM craplot 
     WHERE cdcooper = pr_cdcooper 
       AND dtmvtolt = pr_dtmvtolt 
       AND cdagenci = vr_cdagenlt           
       AND cdbccxlt = vr_cdbccxlt  
       AND nrdolote = vr_nrdolote;      
  rw_craplot cr_craplot%ROWTYPE;
  
  -- Subrotina para validação padrão dos registros das linhas CDE 
  PROCEDURE pc_valida_linha_cde(pr_cdcritic OUT NUMBER 
                               ,pr_dscritic OUT VARCHAR2) IS
  BEGIN    
    -- Inicializar retorno 
    pr_cdcritic := 0;
    -- Separar cdrefere
    vr_cdrefere := trim(substr(vr_dslinharq,2,25));
    -- Buscar empresa conveniadas
    vr_cdempres := ' ';
    vr_nmempres := ' ';
    vr_dsnomres := ' ';
    OPEN cr_crapcsn(substr(vr_dslinharq,148,10));
    FETCH cr_crapcsn
     INTO vr_cdempres
         ,vr_nmempres
         ,vr_dsnomres;
    CLOSE cr_crapcsn;     
    
    /* Se for o convenio 14 BRT CELULAR - FEBRABAN, vamos ignorar o hifen no final da referencia caso exista */
    IF vr_cdempres = '045' THEN
      -- Remover hifen ao final caso exista
      vr_cdrefere := RTRIM(vr_cdrefere,'-');
    END IF;
    -- Buscar posição específica de consórcios
    IF TRIM(substr(vr_dslinharq,148,10)) = 'J5' THEN 
      vr_tpdebito := 1;
      vr_cdhistor := 1230;
    ELSE          
      vr_tpdebito := 2;
      vr_cdhistor := 1019;
    END IF;    
    -- Buscar conta do convênio
    vr_nrctacns := SUBSTR(vr_dslinharq,31,14);
    -- Se não encontrou ou Encontrou e o associado está inativo 
    IF NOT vr_tab_crapass.EXISTS(vr_nrctacns) OR vr_tab_crapass(vr_nrctacns).dtdemiss IS NOT NULL THEN 
      
      -- Se nao existir conta na crapass, vamos criticar com conta errada
      IF NOT vr_tab_crapass.EXISTS(vr_nrctacns) THEN
        vr_nrdconta := 0;
        vr_cdagenci := 0;
        IF vr_tpregist = 'E' THEN 
          pr_cdcritic := 127; -- Conta errada
        END IF;
      ELSIF vr_tab_crapass(vr_nrctacns).dtdemiss IS NOT NULL THEN -- se for demitido
        vr_nrdconta := vr_tab_crapass(vr_nrctacns).nrdconta;
        vr_cdagenci := vr_tab_crapass(vr_nrctacns).cdagenci;
        
        IF vr_tpregist = 'E' THEN 
          pr_cdcritic := 64; -- Conta encerrada
        END IF;
      END IF;
      
      -- Somente no registro "E"
      IF vr_tpregist = 'E' THEN 
        -- Criar NDB
        BEGIN 
          INSERT INTO crapndb (cdcooper
                              ,dtmvtolt
                              ,nrdconta
                              ,cdhistor
                              ,flgproce
                              ,dstexarq)
                       values (pr_cdcooper
                              ,rw_crapdat.dtmvtopr
                              ,vr_nrdconta
                              ,vr_cdhistor
                              ,0
                              ,'F' || SUBSTR(vr_dslinharq,2,66) || 
                               '15' || SUBSTR(vr_dslinharq,70,60) ||
                               lpad(' ',16,' ')                ||
                               SUBSTR(vr_dslinharq,140,2)  ||
                               SUBSTR(vr_dslinharq,148,10) ||
                               SUBSTR(vr_dslinharq,158,1)  || '  ');
        EXCEPTION
          WHEN OTHERS THEN 
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao criar NDB --> ' || sqlerrm;
            RAISE vr_exc_saida;
        END;
        -- Criar registro para inserção 
        vr_reg_relato := NULL;
        vr_reg_relato.cdcooper := pr_cdcooper;
        vr_reg_relato.nrdconta := vr_nrdconta;
        vr_reg_relato.cdrefere := vr_cdrefere;
        vr_reg_relato.nrctacns := vr_nrctacns;
        -- Valor da parcela e data somente no registro E
        CASE vr_tpregist 
          WHEN 'E' THEN           
            vr_reg_relato.vlparcns := vr_vllanmto;
            vr_reg_relato.dtdebito := vr_dtrefere;
          ELSE 
            vr_reg_relato.vlparcns := 0;
            vr_reg_relato.dtdebito := null;
        END CASE;  
        -- Restante dos campos 
        vr_reg_relato.cdcritic := pr_cdcritic;
        vr_reg_relato.dscritic := gene0001.fn_busca_critica(pr_cdcritic);
        vr_reg_relato.tpdebito := vr_tpdebito;
        vr_reg_relato.nmempres := vr_nmempres;
        vr_reg_relato.cdagenci := vr_cdagenci;
        -- Criar registro na tabela conforme o tipo 
        IF vr_tpdebito = 1 THEN 
          -- Rel 661 
          vr_idx_relato := lpad(pr_cdcritic,3,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
          vr_tab_relato_661(vr_idx_relato) := vr_reg_relato;
        ELSE 
          -- Rel 673 
          vr_idx_relato := lpad(pr_cdcritic,3,'0') || lpad(vr_cdagenci,5,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
          vr_tab_relato_673(vr_idx_relato) := vr_reg_relato;
        END IF;
      END IF;  
      -- Retornar para processar o proximo registro caso haja critica
      IF pr_cdcritic > 0 THEN 
        RETURN;
      END IF;  
    ELSE
      -- Copiar informações encontradas       
      vr_nrdconta := vr_tab_crapass(vr_nrctacns).nrdconta;
      vr_cdagenci := vr_tab_crapass(vr_nrctacns).cdagenci;
    END IF;
    
    -- Se for consorcio J5
    IF vr_tpdebito = 1 THEN
      -- Busca consorcio especifico
      OPEN cr_crapcns(SUBSTR(vr_dslinharq,2,8)
                     ,SUBSTR(vr_dslinharq,10,14)
                     ,vr_nrctacns);
      FETCH cr_crapcns
       INTO rw_crapcns;
      -- Se encontrar
      IF cr_crapcns%FOUND THEN 
        -- Fechar cursor
        CLOSE cr_crapcns;
        -- Ajustar histórico conforme tipo do consorcio 
        CASE rw_crapcns.tpconsor
          WHEN 1 THEN /* MOTO */
            vr_cdhistor := 1230;
          WHEN 2 THEN /* AUTO */
            vr_cdhistor := 1231;
          WHEN 3 THEN /* PESADOS */
            vr_cdhistor := 1232;
          WHEN 4 THEN /* IMOVEIS */
            vr_cdhistor := 1233;
          WHEN 5 THEN /* SERVICOS */
            vr_cdhistor := 1234;
          ELSE 
            vr_cdhistor := 1230;          
        END CASE;        
        -- Atualizar aviso e boleto 
        BEGIN 
          UPDATE crapcns 
             SET nrdaviso = nvl(TRIM(SUBSTR(vr_dslinharq,89,11)),0)
                ,nrboleto = nvl(TRIM(SUBSTR(vr_dslinharq,70,9)),0)
           WHERE rowid = rw_crapcns.rowid;
        EXCEPTION 
          WHEN OTHERS THEN 
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar CRAPCNS --> '||sqlerrm;
            RAISE vr_exc_saida;
        END;
      ELSE 
        -- Fechar cursor e Gerar critica 
        CLOSE cr_crapcns;
        pr_cdcritic := 484;
      END IF;
    ELSE 
      -- Busca autorização de debito (tratar em bloco para caso invalid number considerar 484)
      BEGIN 
        rw_crapatr := null;
        OPEN cr_crapatr(vr_nrdconta
                       ,vr_cdempres
                       ,vr_cdrefere);
        FETCH cr_crapatr
         INTO rw_crapatr;
        -- Se não encontrou autorização 
        IF cr_crapatr%NOTFOUND THEN 
          -- Gerar critica 
          pr_cdcritic := 484;
        END IF;
        -- Fechar cursor       
        CLOSE cr_crapatr;
      EXCEPTION
        WHEN OTHERS THEN 
          -- Contrato não encontrado
          pr_cdcritic := 484;
      END;  
      -- validar valor zerado, se for zerado vamos criticar com a critica 
      -- 502 - Conta nao emitida.
      IF vr_vllanmto = 0 THEN
        pr_cdcritic := 502;     
    END IF;
    END IF;
    -- Se encontrarmos critica, somente gerar NDB no tipo de registro E
    IF pr_cdcritic > 0 AND vr_tpregist = 'E' THEN 
      
      IF pr_cdcritic = 502 THEN
        vr_critiarq := '96'; -- 96 - Manutenção do Cadastro
      ELSE
        vr_critiarq := '30';
      END IF;
      -- Criar NDB 
      BEGIN 
        INSERT INTO crapndb (cdcooper
                            ,dtmvtolt
                            ,nrdconta
                            ,cdhistor
                            ,flgproce
                            ,dstexarq)
                     values (pr_cdcooper
                            ,rw_crapdat.dtmvtopr
                            ,vr_nrdconta
                            ,vr_cdhistor
                            ,0
                            ,'F' || SUBSTR(vr_dslinharq,2,66) || 
                             vr_critiarq || 
                             SUBSTR(vr_dslinharq,70,60) ||
                             lpad(' ',16,' ')                ||
                             SUBSTR(vr_dslinharq,140,2)  ||
                             SUBSTR(vr_dslinharq,148,10) ||
                             SUBSTR(vr_dslinharq,158,1)  || '  ');
      EXCEPTION
        WHEN OTHERS THEN 
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao criar NDB --> ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
      -- Criar registro para inserção 
      vr_reg_relato := NULL;
      vr_reg_relato.cdcooper := pr_cdcooper;
      vr_reg_relato.nrdconta := vr_nrdconta;
      vr_reg_relato.cdrefere := vr_cdrefere;
      vr_reg_relato.nrctacns := vr_nrctacns;
      -- Valor da parcela e data somente no registro E
      CASE vr_tpregist 
        WHEN 'E' THEN           
          vr_reg_relato.vlparcns := vr_vllanmto;
          vr_reg_relato.dtdebito := vr_dtrefere;
        ELSE 
          vr_reg_relato.vlparcns := 0;
          vr_reg_relato.dtdebito := null;
      END CASE;  
      -- Restante dos campos 
      vr_reg_relato.cdcritic := pr_cdcritic;
      vr_reg_relato.dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      vr_reg_relato.tpdebito := vr_tpdebito;
      vr_reg_relato.nmempres := vr_nmempres;
      vr_reg_relato.cdagenci := vr_cdagenci;
      -- Criar registro na tabela conforme o tipo 
      IF vr_tpdebito = 1 THEN 
        -- Rel 661 
        vr_idx_relato := lpad(pr_cdcritic,3,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
        vr_tab_relato_661(vr_idx_relato) := vr_reg_relato;
      ELSE 
        -- Rel 673 
        vr_idx_relato := lpad(pr_cdcritic,3,'0') || lpad(vr_cdagenci,5,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
        vr_tab_relato_673(vr_idx_relato) := vr_reg_relato;
      END IF;
      -- Retornar para processar o proximo registro
      RETURN;
    END IF;
  EXCEPTION 
    WHEN vr_exc_saida THEN 
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro nao tratado ao validar linhas CDE: '||SQLERRM;
  END;  
  
BEGIN
  -- Incluir nome do modulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
  FETCH cr_crapcop
   INTO rw_crapcop;
  -- Se nao encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois havera raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;
  -- Leitura do calendario da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se nao encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;
  
  -- Validacoes iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro e <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;
  
  -- Diretorios de retorno 
  vr_nmdirrec := gene0001.fn_param_sistema('CRED',0,'DIR_658_RECEBE');
  vr_nmdirrcb := gene0001.fn_param_sistema('CRED',0,'DIR_658_RECEBIDOS');
  -- Busca o endereco de email para os casos de criticas
  vr_emaildst := gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS387_EMAIL');
  
  -- Montagem do nome do arquivo conforme a data
  CASE to_char(rw_crapdat.dtmvtolt,'MM') 
    WHEN '10' THEN 
      vr_digitmes := 'O';
    WHEN '11' THEN
      vr_digitmes := 'N';
    WHEN '12' THEN
      vr_digitmes := 'D';
    ELSE 
      vr_digitmes := ltrim(to_char(rw_crapdat.dtmvtolt,'MM'),'0');
  END CASE;
  vr_nmarqmov := '0' || TO_CHAR(SUBSTR(rw_crapcop.nrctasic,1,4),'fm0000')
              || vr_digitmes || to_char(rw_crapdat.dtmvtolt,'dd');

  -- Buscaremos com extensão FUT em maiusculo e minusculo 
  IF gene0001.fn_exis_arquivo(vr_nmdirrec||'/'||vr_nmarqmov||'.FUT') THEN
    -- Completamos o nome do arquivo 
    vr_nmarqmov := vr_nmarqmov||'.FUT';  
  ELSIF gene0001.fn_exis_arquivo(vr_nmdirrec||'/'||vr_nmarqmov||'.fut') THEN   
    -- Completamos o nome do arquivo 
    vr_nmarqmov := vr_nmarqmov||'.fut';
  ELSE 
    -- Gerar critica 182 
    vr_cdcritic := 182;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic) || ' --> Arquivo esperado: '||vr_nmarqmov||'.FUT';
    -- Finalizar a execução 
    RAISE vr_exc_fimprg;
  END IF;
        
  -- Enviar critica 219 ao LOG
  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                            ,pr_ind_tipo_log => 2 -- Erro tratato
                            ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                             || vr_cdprogra || ' --> '
                                             || gene0001.fn_busca_critica(219) || ' --> ' 
                                             || vr_nmdirrec||'/'||vr_nmarqmov);
  -- Efetuar abertura do arquivo 
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdirrec||'/'
                          ,pr_nmarquiv => vr_nmarqmov
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_arqhandle
                          ,pr_des_erro => vr_dscritic);
  -- Em caso de problema na abertura do arquivo 
  IF vr_dscritic IS NOT NULL THEN
    vr_dscritic := 'Erro na abertura do arquivo --> ' || vr_nmdirrec||'/'||vr_nmarqmov|| ' --> ' ||vr_dscritic;
    RAISE vr_exc_saida;
  END IF;
      
  -- Carregar tabela de associados
  FOR rw_crapass IN cr_crapass LOOP 
    vr_tab_crapass(rw_crapass.nrctacns) := rw_crapass;
  END LOOP;
    
  -- Efetuar laço para processamento das linhas do arquivo 
  BEGIN 
    LOOP 
      -- Inicializar controles de erro
      vr_cdcritic := 0;
      vr_cdcrindb := NULL;
      
      -- Leitura linha a linha           
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_arqhandle
                                  ,pr_des_text => vr_dslinharq);
      
      -- Incrementar contador de linhas 
      vr_nrdlinha := vr_nrdlinha + 1;
      
      -- Somente na primeira linha
      IF vr_nrdlinha = 1 THEN 
        -- Separar dia, mês e ano da data de referência 
        BEGIN 
          vr_diarefer := SUBSTR(vr_dslinharq,72,2);
          vr_mesrefer := SUBSTR(vr_dslinharq,70,2);
          vr_anorefer := SUBSTR(vr_dslinharq,66,4);
          -- Tentar montar data 
          vr_dtrefere := to_date(to_char(vr_diarefer,'fm00')||to_char(vr_mesrefer,'fm00')||to_char(vr_anorefer,'fm0000'),'ddmmrrrr');
        EXCEPTION
          WHEN OTHERS THEN 
            -- Enviar ao LOG 
            vr_cdcritic := 13;
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> Linha --> ' ||vr_nrdlinha || ' --> ' 
                                                       || gene0001.fn_busca_critica(vr_cdcritic));   
            -- Pular ao próximo registro 
            CONTINUE; 
        END;
        -- Pular ao próximo registro pois o header só necessita dessa leitura 
        CONTINUE;
      END IF;
      
      -- Leitura do tipo de registro 
      vr_tpregist := substr(vr_dslinharq,1,1);
      
      -- somatoria da quantidade de registros no arquivo
      vr_contareg := vr_contareg + 1;

      -- Se encontrar novo header 
      CASE vr_tpregist 
        WHEN 'A' THEN 
          -- Gerar critica 468
          vr_cdcritic := 468;
          RAISE vr_exc_saida; 
        WHEN 'C' THEN   
          -- Acionar rotina padrão de validação 
          pc_valida_linha_cde(vr_cdcritic,vr_dscritic);
          -- Sair se houve erro critico, a dscritic terá informação e temos de abortar
          IF vr_dscritic IS NOT NULL THEN 
            RAISE vr_exc_saida;
          END IF;
          -- Continuar se houve encontro de critica na validação do registro 
          IF vr_cdcritic > 0 THEN 
            CONTINUE;
          END IF;
          -- Criar registro para o relatório 
          vr_reg_relato := NULL;
          vr_reg_relato.cdcooper := pr_cdcooper;
          vr_reg_relato.nrdconta := vr_nrdconta;
          vr_reg_relato.cdrefere := vr_cdrefere;
          vr_reg_relato.nrctacns := vr_nrctacns;
          vr_reg_relato.vlparcns := 0;
          vr_reg_relato.dtdebito := null;
          vr_reg_relato.cdcritic := 0;
          vr_reg_relato.dscritic := SUBSTR(vr_dslinharq,45,40);
          vr_reg_relato.tpdebito := vr_tpdebito;
          vr_reg_relato.nmempres := vr_nmempres;
          vr_reg_relato.cdagenci := vr_cdagenci;
          -- Criar registro na tabela conforme o tipo 
          IF vr_tpdebito = 1 THEN 
            -- Rel 661 
            vr_idx_relato := lpad(0,3,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
            vr_tab_relato_661(vr_idx_relato) := vr_reg_relato;
          ELSE 
            -- Rel 673 
            vr_idx_relato := lpad(0,3,'0') || lpad(vr_cdagenci,5,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
            vr_tab_relato_673(vr_idx_relato) := vr_reg_relato;
          END IF;
          -- Se foi buscado a ATR anteriormente e não foi enviado "1" na posição 158 
          IF rw_crapatr.rowid IS NOT NULL AND SUBSTR(vr_dslinharq,158,1) <> '1' THEN 
            -- Efetuaremos o cancelamento da autorização 
            BEGIN 
              UPDATE crapatr 
                 SET dtfimatr = rw_crapdat.dtmvtolt
               WHERE ROWID = rw_crapatr.rowid;
            EXCEPTION
              WHEN OTHERS THEN 
                vr_dscritic := 'Erro ao cancelar autorizacao --> '||sqlerrm;
                raise vr_exc_saida;
            END;
          END IF;
        WHEN 'D' THEN 
          -- Acionar rotina padrão de validação 
          pc_valida_linha_cde(vr_cdcritic,vr_dscritic);
          -- Sair se houve erro critico, a dscritic terá informação e temos de abortar
          IF vr_dscritic IS NOT NULL THEN 
            RAISE vr_exc_saida;
          END IF;
          -- Continuar se houve encontro de critica na validação do registro 
          IF vr_cdcritic > 0 THEN 
            CONTINUE;
          END IF;
          -- Ler nova referencia convenio 
          vr_cdrefere := trim(SUBSTR(vr_dslinharq,45,25));
          -- Criar registro para o relatório 
          vr_reg_relato := NULL;
          vr_reg_relato.cdcooper := pr_cdcooper;
          vr_reg_relato.nrdconta := vr_nrdconta;
          vr_reg_relato.cdrefere := vr_cdrefere;
          vr_reg_relato.nrctacns := vr_nrctacns;
          vr_reg_relato.vlparcns := 0;
          vr_reg_relato.dtdebito := null;
          vr_reg_relato.cdcritic := 0;
          vr_reg_relato.dscritic := SUBSTR(vr_dslinharq,70,60);
          vr_reg_relato.tpdebito := vr_tpdebito;
          vr_reg_relato.nmempres := vr_nmempres;
          vr_reg_relato.cdagenci := vr_cdagenci;
          -- Criar registro na tabela conforme o tipo 
          IF vr_tpdebito = 1 THEN 
            -- Rel 661 
            vr_idx_relato := lpad(0,3,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
            vr_tab_relato_661(vr_idx_relato) := vr_reg_relato;
          ELSE 
            -- Rel 673 
            vr_idx_relato := lpad(0,3,'0') || lpad(vr_cdagenci,5,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
            vr_tab_relato_673(vr_idx_relato) := vr_reg_relato;
          END IF;
          -- Somente para convênios
		      IF vr_tpdebito <> 1 THEN 
		        -- Em caso de solicitar fim da autorização ou substituição da autorização antiga 
            IF substr(vr_dslinharq,158,1) IN ('0','1') THEN 
              -- Atualizar fim da autorização se ainda não efetuado no cancelamento e sempre na substituição  
              IF rw_crapatr.rowid IS NOT NULL AND (   (substr(vr_dslinharq,158,1) = '1' AND rw_crapatr.dtfimatr IS NULL)
                                                   OR (substr(vr_dslinharq,158,1) = '0') ) THEN 
                -- Efetuaremos o cancelamento da autorização 
                BEGIN 
                  UPDATE crapatr 
                   SET dtfimatr = rw_crapdat.dtmvtolt
                   WHERE ROWID = rw_crapatr.rowid;
                EXCEPTION
                  WHEN OTHERS THEN 
                  vr_dscritic := 'Erro ao cancelar autorizacao --> '||sqlerrm;
                  raise vr_exc_saida;
                END;
              END IF;  
              -- Para substituição 
              IF substr(vr_dslinharq,158,1) = '0' THEN
                -- Busca se já existe a nova autorização de debito 
                rw_crabatr := null;
                OPEN cr_crapatr(vr_nrdconta
                               ,vr_cdempres
                               ,vr_cdrefere
                               ,'N');
                FETCH cr_crapatr
                 INTO rw_crabatr;
                -- Se não encontrou autorização 
                IF cr_crapatr%NOTFOUND THEN 
                  -- Fechar cursor       
                  CLOSE cr_crapatr;
                  -- Criamos a nova autorização com base na anterior
                  BEGIN 
                    INSERT INTO crapatr (cdcooper
                                        ,nrdconta
                                        ,cdrefere
                                        ,cddddtel
                                        ,cdhistor
                                        ,ddvencto 
                                        ,dtiniatr
                                        ,dtultdeb
                                        ,nmfatura
                                        ,dtfimatr) 
                                 VALUES (pr_cdcooper
                                        ,vr_nrdconta
                                        ,vr_cdrefere
                                        ,0
                                        ,vr_cdhistor
                                        ,rw_crapatr.ddvencto 
                                        ,rw_crapatr.dtiniatr
                                        ,null
                                        ,rw_crapatr.nmfatura
                                        ,rw_crapatr.dtfimatr);
                  EXCEPTION
                    WHEN OTHERS THEN 
                    vr_dscritic := 'Erro ao criar autorizacao --> '||sqlerrm;
                    raise vr_exc_saida;
                  END;
                ELSE
                  -- Fechar cursor       
                  CLOSE cr_crapatr;
                  -- Apenas reativamos a autorização antiga encontrada 
                  BEGIN 
                    UPDATE crapatr 
                       SET dtfimatr = NULL 
                     WHERE ROWID = rw_crabatr.rowid;
                  EXCEPTION
                    WHEN OTHERS THEN 
                    vr_dscritic := 'Erro ao reativar autorizacao --> '||sqlerrm;
                    raise vr_exc_saida;
                  END;
                END IF;
                -- Atualiza numero de documentos de lançamentos futuros vinculados a autorização anterior                 
                BEGIN 
                  UPDATE craplau
                     SET nrdocmto = vr_cdrefere
                   WHERE cdcooper = pr_cdcooper     
                     AND nrdconta  = vr_nrdconta 
                     AND dtmvtolt >= rw_crapdat.dtmvtolt
                     AND (nrdocmto  = rw_crapatr.cdrefere
                      OR nrcrcard  = rw_crapatr.cdrefere)
                     AND insitlau  = 1               
                     AND dsorigem NOT IN('INTERNET','TAA','PG555','CARTAOBB','BLOQJUD','DAUT BANCOOB','TRMULTAJUROS');
                EXCEPTION
                  WHEN OTHERS THEN 
                  vr_dscritic := 'Erro ao atualizar lançamentos futuros da nova autorizacao --> '||sqlerrm;
                  raise vr_exc_saida;
                END;
              END IF;			  
            END IF;
          END IF;
        WHEN 'E' THEN 
          -- Separar valor do débito 
          BEGIN 
            vr_vllanmto := to_number(SUBSTR(vr_dslinharq,53,15)) / 100;
          EXCEPTION 
            WHEN OTHERS THEN 
              vr_dscritic := ' Ao converter o valor do lançamento --> '|| SUBSTR(vr_dslinharq,53,15);
              RAISE vr_exc_saida;
          END;
          -- Incrementar valor do débito 
          vr_vldebito := vr_vldebito + vr_vllanmto;
          -- Separar a data do lançamento 
          BEGIN 
            vr_diarefer := SUBSTR(vr_dslinharq,51,2);
            vr_mesrefer := SUBSTR(vr_dslinharq,49,2);
            vr_anorefer := SUBSTR(vr_dslinharq,45,4);
            -- Tentar montar data 
            vr_dtrefere := to_date(to_char(vr_diarefer,'fm00')||to_char(vr_mesrefer,'fm00')||to_char(vr_anorefer,'fm0000'),'ddmmrrrr');
          EXCEPTION
            WHEN OTHERS THEN 
              -- Critica 
              vr_cdcritic := 13;
              RAISE vr_exc_saida; 
          END;
          -- Acionar rotina padrão de validação 
          pc_valida_linha_cde(vr_cdcritic,vr_dscritic);
          -- Sair se houve erro critico, a dscritic terá informação e temos de abortar
          IF vr_dscritic IS NOT NULL THEN 
            RAISE vr_exc_saida;
          END IF;
          -- Continuar se houve encontro de critica na validação do registro 
          IF vr_cdcritic > 0 THEN 
            CONTINUE;
          END IF;
          -- Caso enviado debito anterior a 30 dias
          IF (vr_dtrefere + 30) < rw_crapdat.dtmvtolt THEN
            -- Gerar critica 13 
            vr_cdcrindb := '13';
            vr_cdcritic := 13;
          ELSE 
            -- Continuar conforme o tipo do movimento 
            IF SUBSTR(vr_dslinharq,158,1) = 0 THEN
            
              BEGIN 
                vr_nrdocmto_int:= vr_cdrefere;
              EXCEPTION 
                WHEN OTHERS THEN
                  vr_cdcritic := 484;
                  vr_cdcrindb := '30';
              END;
              
              IF nvl(vr_cdcritic,0) = 0 THEN      
                -- Somente vamos verificar se for deb. aut. sicredi        
                IF vr_cdhistor = 1019 THEN                
                  LOOP
                    -- Busca os lancamentos automaticos
                    IF cr_craplau_dup%ISOPEN THEN
                      CLOSE cr_craplau_dup;
                    END IF;
                    -- Caso o convenio enviar mais que uma referencia no mesmo dia para a mesma
                    -- conta e valor do debito ou data de pagamento forem diferentes, vamos
                    -- incrementar um zero no final para permitir a inclusão do lançamento
                    OPEN cr_craplau_dup(pr_cdcooper, -- cdcooper
                                        vr_nrdconta, -- nrdconta
                                        rw_crapdat.dtmvtolt, -- dtmvtolt
                                        vr_dtrefere, -- dtmvtopg
                                        vr_cdhistor, -- cdhistor
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
                
              -- Inclusao deve verificar duplicidade 
              OPEN cr_craplau(pr_nrdconta => vr_nrdconta
                             ,pr_dtrefere => vr_dtrefere
                             ,pr_cdrefere => vr_nrdocmto_int
                             ,pr_cdhistor => vr_cdhistor);
              FETCH cr_craplau 
               INTO vr_exislau;              
              -- Se encontrar 
              IF cr_craplau%FOUND THEN 
                -- Fechar cursor e gerar critica 92
                CLOSE cr_craplau;
                vr_flgdupli := TRUE;
                vr_cdcrindb := '13';
                vr_cdcritic := 92;
              ELSE 
                -- Fechar cursor e continuar para a gravação 
                CLOSE cr_craplau;
                -- Se foi solicitada criação de lote
                IF vr_flgclote THEN
                  -- Verificar se existe registro
                  OPEN cr_craplot(rw_crapdat.dtmvtolt);
                  FETCH cr_craplot
                   INTO rw_craplot;
                  -- Se não existe 
                  IF cr_craplot%NOTFOUND THEN                
                    -- Fechar o cursor
                    CLOSE cr_craplot;                    
                    -- Tentaremos criar o registro do lote
                    BEGIN
                      INSERT INTO craplot (cdcooper
                                          ,dtmvtolt
                                          ,dtmvtopg
                                          ,cdagenci
                                          ,cdbccxlt
                                          ,cdbccxpg
                                          ,cdhistor
                                          ,cdoperad
                                          ,nrdolote
                                          ,tpdmoeda
                                          ,tplotmov)
                                    VALUES(pr_cdcooper          -- cdcooper
                                          ,rw_crapdat.dtmvtolt  -- dtmvtolt
                                          ,rw_crapdat.dtmvtopr  -- dtmttopg
                                          ,vr_cdagenlt  -- cdagenci
                                          ,vr_cdbccxlt  -- cdbccxlt
                                          ,vr_cdbccxpg  -- cdbccxpg
                                          ,vr_cdhistor  -- cdhistor 
                                          ,'1'          -- cdoperad
                                          ,vr_nrdolote  -- nrdolote
                                          ,1            -- tpdmoeda
                                          ,12)          -- tplotmov
                                 RETURNING rowid
                                          ,dtmvtolt
                                          ,cdagenci
                                          ,cdbccxlt
                                          ,cdbccxpg
                                          ,nrdolote
                                          ,tplotmov
                                          ,qtinfoln 
                                          ,qtcompln 
                                          ,vlinfodb 
                                          ,vlcompdb
                                          ,nrseqdig
                                      INTO rw_craplot.nrrowid 
                                          ,rw_craplot.dtmvtolt
                                          ,rw_craplot.cdagenci
                                          ,rw_craplot.cdbccxlt
                                          ,rw_craplot.cdbccxpg
                                          ,rw_craplot.nrdolote
                                          ,rw_craplot.tplotmov
                                          ,rw_craplot.qtinfoln 
                                          ,rw_craplot.qtcompln 
                                          ,rw_craplot.vlinfodb 
                                          ,rw_craplot.vlcompdb
                                          ,rw_craplot.nrseqdig;
                    EXCEPTION
                      WHEN dup_val_on_index THEN
                        -- Lote já existe, critica 59
                        vr_cdcritic := 59;
                        vr_dscritic := gene0001.fn_busca_critica(59) || ' - LOTE = ' || to_char(vr_nrdolote,'fm000g000');
                        RAISE vr_exc_saida;
                      WHEN others THEN 
                        -- Erro não tratado 
                        vr_dscritic := ' na insercao do lote '||vr_nrdolote|| ' --> ' || sqlerrm;
                        RAISE vr_exc_saida;
                    END;          
                  END IF;
                  -- Atualizar o controle indicando que houve criação do lote
                  vr_flgclote := false;
                END IF;
                
                -- Inclusao deve verificar duplicidade 
                OPEN cr_craplau_dia(pr_nrdconta => vr_nrdconta
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdrefere => vr_nrdocmto_int);
                FETCH cr_craplau_dia 
                 INTO vr_exislau;              
                -- Se encontrar 
                IF cr_craplau_dia%FOUND THEN 
                  -- Fechar cursor e gerar critica 103 no relatório NDB 04
                  CLOSE cr_craplau_dia;
                  vr_cdcritic := 103;
                  vr_cdcrindb := '13';
                  vr_flgdupli := TRUE;
                ELSE 
                  -- Fechar cursor e continuar com a inserção da LAU 
                  CLOSE cr_craplau_dia;
                  -- Registro ao relatório 
                  vr_reg_relato := NULL;
                  vr_reg_relato.cdcooper := pr_cdcooper;
                  vr_reg_relato.nrdconta := vr_nrdconta;
                  vr_reg_relato.cdrefere := vr_cdrefere;
                  vr_reg_relato.nrctacns := vr_nrctacns;
                  vr_reg_relato.vlparcns := vr_vllanmto;
                  vr_reg_relato.dtdebito := vr_dtrefere;
                  vr_reg_relato.tpdebito := vr_tpdebito;
                  vr_reg_relato.nmempres := vr_nmempres;
                  vr_reg_relato.cdagenci := vr_cdagenci;
                  vr_reg_relato.cdcritic := 0;
                  -- Criar registro na tabela conforme o tipo 
                  IF vr_tpdebito = 1 THEN 
                    -- Rel 661 
                    vr_idx_relato := lpad(0,3,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
                    vr_tab_relato_661(vr_idx_relato) := vr_reg_relato;
                  ELSE 
                    -- Rel 673 
                    vr_idx_relato := lpad(0,3,'0') || lpad(vr_cdagenci,5,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
                    vr_tab_relato_673(vr_idx_relato) := vr_reg_relato;
                  END IF;
                  -- Atualizar LOTE 
                  rw_craplot.qtinfoln := rw_craplot.qtinfoln + 1;
                  rw_craplot.qtcompln := rw_craplot.qtcompln + 1;
                  rw_craplot.vlinfodb := rw_craplot.vlinfodb + nvl(vr_vllanmto,0);
                  rw_craplot.vlcompdb := rw_craplot.vlcompdb + nvl(vr_vllanmto,0);
                  rw_craplot.nrseqdig := rw_craplot.nrseqdig + 1;
                  -- Criar LAU 
                  BEGIN
                    -- Criando lançamento 
                    INSERT INTO craplau (cdcooper                                                   
                                        ,dtmvtopg
                                        ,cdagenci
                                        ,cdbccxlt
                                        ,cdbccxpg
                                        ,cdhistor
                                        ,dtmvtolt
                                        ,insitlau
                                        ,nrdconta
                                        ,nrdctabb 
                                        ,nrdolote
                                        ,nrseqdig
                                        ,tpdvalor
                                        ,vllanaut
                                        ,nrdocmto
                                        ,cdseqtel
                                        ,cdempres
                                        ,dscedent
                                        ,dttransa
                                        ,hrtransa
                                        ,nrcrcard)
                                 VALUES(pr_cdcooper                                          -- cdcooper
                                       ,gene0005.fn_valida_dia_util(pr_cdcooper,vr_dtrefere) -- dtmvtopg
                                       ,rw_craplot.cdagenci                                -- cdagenci
                                       ,rw_craplot.cdbccxlt                                -- cdbccxlt
                                       ,rw_craplot.cdbccxpg                                -- cdbccxpg
                                       ,vr_cdhistor                                        -- cdhistor
                                       ,rw_craplot.dtmvtolt                                -- dtmvtolt
                                       ,1                                                  -- insitlau
                                       ,vr_nrdconta                                        -- nrdconta
                                       ,vr_nrdconta                                        -- nrdctabb
                                       ,rw_craplot.nrdolote                                -- nrdolote
                                       ,rw_craplot.nrseqdig                                -- nrseqdig
                                       ,1                                                  -- tpdvalor
                                       ,vr_vllanmto                                        -- vllanaut
                                       ,vr_nrdocmto_int                                    -- nrdocmto
                                       ,SUBSTR(vr_dslinharq,70,60)                         -- cdseqtel
                                       ,vr_cdempres                                        -- cdempres
                                       ,vr_nmempres                                        -- dscedent
                                       ,rw_crapdat.dtmvtolt                                -- dttransa
                                       ,to_char(sysdate,'sssss')                            -- hrtransa
                                       ,vr_cdrefere);
                  EXCEPTION 
                    WHEN OTHERS THEN 
                      vr_dscritic := ' na inserção do lançamento em CC --> '||sqlerrm;
                      RAISE vr_exc_saida;
                  END;
                  -- Verifica necessidade de envio de SMS
                  IF vr_tpdebito = 2 THEN 
                    -- Validar valor maior que o limite parametrizado
                    IF rw_crapatr.flgmaxdb = 1 AND vr_vllanmto > rw_crapatr.vlrmaxdb THEN  
                      -- Notificar cooperado que fatura excede limite
                      
                      --Atribui o nome resumido se houver
                      IF (TRIM(vr_dsnomres) IS NOT NULL) THEN  
                        vr_dsnomsms := vr_dsnomres;
                      ELSE
                        vr_dsnomsms := SUBSTR(vr_nmempres, 1, 20);
                      END IF;
                      
                      sicr0001.pc_notif_cooperado_debaut(pr_cdcritic      => 967       -- 967 - Limite ultrapassado.
                                                        ,pr_cdcooper      => pr_cdcooper
                                                        ,pr_nmrescop      => rw_crapcop.nmrescop
                                                        ,pr_cdprogra      => vr_cdprogra
                                                        ,pr_nrdconta      => vr_nrdconta
                                                        ,pr_nrdocmto      => vr_cdrefere
                                                        ,pr_nmconven      => vr_dsnomsms
                                                        ,pr_dtmvtopg      => gene0005.fn_valida_dia_util(pr_cdcooper,vr_dtrefere)
                                                        ,pr_vllanaut      => vr_vllanmto
                                                        ,pr_vlrmaxdb      => rw_crapatr.vlrmaxdb
                                                        ,pr_cdrefere      => rw_crapatr.cdrefere
                                                        ,pr_cdhistor      => rw_crapatr.cdhistor
                                                        ,pr_tpdnotif      => 0 --> Todos
                                                        ,pr_flfechar_lote => 0 -- Não fecha o lote a cada SMS
                                                        ,pr_idlote_sms    => vr_nrdolote_sms);  
                    END IF;
                  END IF;
                END IF;
              END IF;
              END IF;
            ELSE  
              -- Efetuar cancelamento de lançamento agendado 
              BEGIN 
                UPDATE craplau 
                   SET dtdebito = rw_crapdat.dtmvtolt
                      ,insitlau = 3 
                 WHERE cdcooper = pr_cdcooper       
                   AND dtmvtopg = vr_dtrefere       
                   AND nrdconta = vr_nrdconta       
                   AND (nrdocmto = vr_cdrefere
                    OR nrcrcard = vr_cdrefere)
                   AND insitlau = 1;
                -- Se encontrou registro 
                IF sql%ROWCOUNT > 0 THEN 
                  -- Gerar critica 739 e NDB 99
                  vr_cdcritic := 739;
                  vr_cdcrindb := '99';
                ELSE 
                  -- Gerar critica 501 e NDB 97
                  vr_cdcritic := 501;
                  vr_cdcrindb := '97';
                END IF;
              EXCEPTION 
                WHEN OTHERS THEN 
                  vr_dscritic := ' no cancelamento de lancamento agendado em CC --> '||sqlerrm;
                  RAISE vr_exc_saida;
              END;
            END IF;
          END IF;

          -- Se chegarmos neste ponto com critica 
          IF vr_cdcrindb IS NOT NULL THEN 
            -- Criar NDB 
            BEGIN 
              INSERT INTO crapndb (cdcooper
                                  ,dtmvtolt
                                  ,nrdconta
                                  ,cdhistor
                                  ,flgproce
                                  ,dstexarq)
                           values (pr_cdcooper
                                  ,rw_crapdat.dtmvtopr
                                  ,vr_nrdconta
                                  ,vr_cdhistor
                                  ,0
                                  ,'F' || SUBSTR(vr_dslinharq,2,66) || 
                                   vr_cdcrindb || SUBSTR(vr_dslinharq,70,60) ||
                                   lpad(' ',16,' ')                ||
                                   SUBSTR(vr_dslinharq,140,2)  ||
                                   SUBSTR(vr_dslinharq,148,10) ||
                                   SUBSTR(vr_dslinharq,158,1)  || '  ');
            EXCEPTION
              WHEN OTHERS THEN 
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao criar NDB --> ' || sqlerrm;
                RAISE vr_exc_saida;
            END;
          END IF;
          -- Critica para o relatório 
          IF vr_cdcritic > 0 THEN           
            -- Criar registro para inserção 
            vr_reg_relato := NULL;
            vr_reg_relato.cdcooper := pr_cdcooper;
            vr_reg_relato.nrdconta := vr_nrdconta;
            vr_reg_relato.cdrefere := vr_cdrefere;
            vr_reg_relato.nrctacns := vr_nrctacns;
            vr_reg_relato.vlparcns := vr_vllanmto;
            vr_reg_relato.dtdebito := vr_dtrefere;
            -- Restante dos campos 
            vr_reg_relato.cdcritic := vr_cdcritic;
            vr_reg_relato.dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            vr_reg_relato.tpdebito := vr_tpdebito;
            vr_reg_relato.nmempres := vr_nmempres;
            vr_reg_relato.cdagenci := vr_cdagenci;
            -- Criar registro na tabela conforme o tipo 
            IF vr_tpdebito = 1 THEN 
              -- Rel 661 
              vr_idx_relato := lpad(vr_cdcritic,3,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
              vr_tab_relato_661(vr_idx_relato) := vr_reg_relato;
            ELSE 
              -- Rel 673 
              vr_idx_relato := lpad(vr_cdcritic,3,'0') || lpad(vr_cdagenci,5,'0') || lpad(vr_nrdconta,10,'0') || lpad(vr_nrctacns,10,'0') || lpad(vr_nrdlinha,10,'0');
              vr_tab_relato_673(vr_idx_relato) := vr_reg_relato;
            END IF;
          END IF; 
        WHEN 'Z' THEN 
          -- Validar total de lançamentos
          BEGIN 
            IF vr_contareg <> to_number(SUBSTR(vr_dslinharq,2,6)) THEN
              vr_cdcritic := 504;
              RAISE vr_exc_saida;
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN 
              -- Propagar a exceção
              RAISE vr_exc_saida;
            WHEN OTHERS THEN 
              -- Se ocorrer erro ao converter a quantidade de lançamentos, também consideraremos como diferença
              vr_cdcritic := 504;
              RAISE vr_exc_saida;              
          END;
          -- Validar valores dos lançamentos
          BEGIN 
            IF vr_vldebito <> to_number(SUBSTR(vr_dslinharq,8,17))/100 THEN
              vr_cdcritic := 505;
              RAISE vr_exc_saida;
            END IF;
          EXCEPTION
            WHEN vr_exc_saida THEN 
              -- Propagar a exceção
              RAISE vr_exc_saida;
            WHEN OTHERS THEN 
              -- Se ocorrer erro ao converter o valor dos lançamentos, também consideraremos como diferença
              vr_cdcritic := 505;
              RAISE vr_exc_saida;              
          END;
        ELSE 
          -- Tipo inexistente, então diminuimos o contador e geramos log
          vr_contareg := vr_contareg - 1;
          -- Enviar ao LOG 
          vr_cdcritic := 468;
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> Linha --> ' ||vr_nrdlinha || ' --> '
                                                     || gene0001.fn_busca_critica(vr_cdcritic));   
          -- Ignorar o registro 
          continue;
      END CASE;
    END LOOP;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Buscar descrição da critica 
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN 
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Adicionar o numero da linha ao erro 
      vr_dscritic := 'Erro na linha '||vr_nrdlinha|| ' do arquivo: '||vr_nmarqmov ||' --> '|| vr_dscritic;      
      
      vr_texto_email := '<b>Abaixo os erros encontrados no processo de importacao do debito SICREDI:</b><br><br>'||
                        to_char(SYSDATE,'dd/mm/yyyy HH24:MI:SS') || ' --> ' || vr_dscritic;

      -- Por fim, envia o email
      gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra
                                ,pr_des_destino => vr_emaildst
                                ,pr_des_assunto => 'Critica importacao debito - SICREDI'
                                ,pr_des_corpo   => vr_texto_email
                                ,pr_des_anexo   => NULL
                                ,pr_flg_enviar  => 'N'
                                ,pr_des_erro    => vr_dscritic);
    WHEN no_data_found THEN
      NULL; --> Fim da leitura 
    WHEN OTHERS THEN
      -- Adicionar o numero da linha ao erro 
      vr_dscritic := 'Erro na linha '||vr_nrdlinha|| ' do arquivo: '||vr_nmarqmov ||' --> '|| SQLERRM;
      
      vr_texto_email := '<b>Abaixo os erros encontrados no processo de importacao do debito SICREDI:</b><br><br>'||
                        to_char(SYSDATE,'dd/mm/yyyy HH24:MI:SS') || ' --> ' || vr_dscritic;

      -- Por fim, envia o email
      gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra
                                ,pr_des_destino => vr_emaildst
                                ,pr_des_assunto => 'Critica importacao debito - SICREDI'
                                ,pr_des_corpo   => vr_texto_email
                                ,pr_des_anexo   => NULL
                                ,pr_flg_enviar  => 'N'
                                ,pr_des_erro    => vr_dscritic);
  END;
  
  -- Fechar handle do arquivo pendente 
  gene0001.pc_fecha_arquivo(vr_arqhandle);
  
  -- Se houve erro no processamento do arquivo 
  IF vr_cdcritic NOT IN(0,484) OR vr_dscritic IS NOT NULL THEN 
    -- Desfazer alterações pendentes
    ROLLBACK;
    -- Renomear arquivo como erro e não continuar (Deixará na mesma pasta)
    gene0001.pc_OSCommand_Shell(pr_des_comando => 'mv ' || vr_nmdirrec||'/'||vr_nmarqmov|| ' ' || vr_nmdirrec||'/err_'||vr_nmarqmov
                               ,pr_typ_saida => vr_typsaida
                               ,pr_des_saida => vr_dessaida);
    -- Havendo erro, finalizar
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic := 'Erro ao mover arquivo com erro, alteracoes desfeitas --> ' || vr_dessaida;
      RAISE vr_exc_saida;
    ELSE 
      -- Finalizar execução 
      RAISE vr_exc_fimprg;
    END IF;  
  END IF;

  -- Se há lote de SMS a encerrar
  IF vr_nrdolote_sms > 0 THEN 
    -- Encerrar lote de SMS
    ESMS0001.pc_conclui_lote_sms(pr_idlote_sms  => vr_nrdolote_sms
                                ,pr_dscritic    => vr_dscritic);
  END IF;                       
  
  -- Se houve registros duplicados 
  IF vr_flgdupli THEN 
    -- Apenas gerar critica 740 no log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || gene0001.fn_busca_critica(740) || ' --> ' 
                                               || vr_nmdirrec||'/'||vr_nmarqmov);
  END IF;
  
  -- Atualizar a CRAPLOT após o processamento, pois os valores estão apenas em memória
  BEGIN 
    UPDATE craplot 
       SET qtinfoln = rw_craplot.qtinfoln
          ,qtcompln = rw_craplot.qtcompln
          ,vlinfodb = rw_craplot.vlinfodb
          ,vlcompdb = rw_craplot.vlcompdb
          ,nrseqdig = rw_craplot.nrseqdig
     WHERE rowid = rw_craplot.nrrowid;
  EXCEPTION
    WHEN OTHERS THEN 
      vr_dscritic := 'Erro ao atualizar o lote após processamento --> '||sqlerrm;
      RAISE vr_exc_saida;
  END;
 
  -- Efetuar geração do relatório 661 
  IF vr_tab_relato_661.count > 0 THEN 
    -- Inicializar XML
    dbms_lob.createtemporary(vr_xmlrel_661, TRUE);
    dbms_lob.open(vr_xmlrel_661, dbms_lob.lob_readwrite);
    
    -- Inicializar totalizadores 
    vr_tot_qtdrejei := 0;
    vr_tot_vlpareje := 0;
    vr_tot_qtdreceb := 0;
    vr_tot_vlparceb := 0;
    vr_tot_qtdinteg := 0;
    vr_tot_vlpainte := 0;
    
    -- Inicializa o xml
    gene0002.pc_escreve_xml(vr_xmlrel_661,
                            vr_txtrel_661,
                           '<?xml version="1.0" encoding="utf-8"?>'||
                           '<root><consorcios>');
      
    -- Iterar sobre os registros acumulados para o relatório 
    vr_idx_relato := vr_tab_relato_661.first;
    LOOP
      -- Sair quando terminar a leitura
      EXIT WHEN vr_idx_relato IS NULL;
      -- Enviar registro de consorcio 
      gene0002.pc_escreve_xml(vr_xmlrel_661
                           ,vr_txtrel_661
                           ,'<consorcio nrdconta="'||gene0002.fn_mask_conta(vr_tab_relato_661(vr_idx_relato).nrdconta)||'" '||
                                      ' nrctacns="'||gene0002.fn_mask_conta(vr_tab_relato_661(vr_idx_relato).nrctacns)||'"'||
                                      ' cdrefere="'||vr_tab_relato_661(vr_idx_relato).cdrefere||'" '||
                                      ' vlparcns="'||TO_CHAR(vr_tab_relato_661(vr_idx_relato).vlparcns,'fm999g999g999g990d00')||'" '||
                                      ' dtdebito="'||TO_CHAR(vr_tab_relato_661(vr_idx_relato).dtdebito,'dd/mm/rrrr')||'" '||
                                      ' dscritic="'||SUBSTR(vr_tab_relato_661(vr_idx_relato).dscritic,1,50)||'"/>');
      -- Acumular recebidos 
      vr_tot_qtdreceb := vr_tot_qtdreceb + 1;
      vr_tot_vlparceb := vr_tot_vlparceb + nvl(vr_tab_relato_661(vr_idx_relato).vlparcns,0);
      -- rejeitados / nao considera a critica 739 pois e de cancelamento de debitos
      IF vr_tab_relato_661(vr_idx_relato).cdcritic NOT IN(0,739) THEN 
        vr_tot_qtdrejei := vr_tot_qtdrejei + 1;
        vr_tot_vlpareje := vr_tot_vlpareje + nvl(vr_tab_relato_661(vr_idx_relato).vlparcns,0);
      END IF;
      -- Navegar ao proximo registro 
      vr_idx_relato := vr_tab_relato_661.next(vr_idx_relato);
    END LOOP;
    -- Ao final, calcular totais integrados 
    vr_tot_qtdinteg := vr_tot_qtdreceb - vr_tot_qtdrejei;
    vr_tot_vlpainte := vr_tot_vlparceb - vr_tot_vlpareje;
    -- Fecharemos a tag de consorcios e então enviaremos os totais e fecharemos o XML 
    gene0002.pc_escreve_xml(vr_xmlrel_661
                           ,vr_txtrel_661
                           ,'</consorcios><total nmarquiv="'||vr_nmarqmov||'" '||
                                               ' qtdreceb="'||TO_CHAR(vr_tot_qtdreceb,'fm999g999g999g990')||'" '||
                                               ' vlparceb="'||TO_CHAR(vr_tot_vlparceb,'fm999g999g999g990d00')||'"'||
                                               ' qtdrejei="'||TO_CHAR(vr_tot_qtdrejei,'fm999g999g999g990')||'" '||
                                               ' vlpareje="'||TO_CHAR(vr_tot_vlpareje,'fm999g999g999g990d00')||'" '||
                                               ' qtdinteg="'||TO_CHAR(vr_tot_qtdinteg,'fm999g999g999g990')||'" '||
                                               ' vlpainte="'||TO_CHAR(vr_tot_vlpainte,'fm999g999g999g990d00')||'"/></root>'
                           ,true);    

    -- Por fim, iremos solicitar a emissão do relatório 
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_xmlrel_661,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/root/consorcios/consorcio',    --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl661.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => NULL,                --> nao enviar parametros
                                pr_dsarqsaid =>  gene0001.fn_diretorio('C',pr_cdcooper,'rl')||'/crrl661.lst', --> Arquivo final
                                pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                pr_qtcoluna  => 132,                  --> Quantidade de colunas
                                pr_cdrelato  => 661,                   --> Sequencia do cabecalho
                                pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '132col',             --> Nome do formulário para impressão
                                pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                pr_dspathcop => NULL,                --> Diretorio para copia dos arquivos
                                pr_des_erro  => vr_dscritic);        --> Saida com erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Liberando a memoria alocada para os CLOBs
    dbms_lob.close(vr_xmlrel_661);
    dbms_lob.freetemporary(vr_xmlrel_661);   
  END IF; -- Dados para o relatório 661
  
  -- Efetuar geração do relatório 673 
  IF vr_tab_relato_673.count > 0 THEN 
    -- Inicializar XML
    dbms_lob.createtemporary(vr_xmlrel_673, TRUE);
    dbms_lob.open(vr_xmlrel_673, dbms_lob.lob_readwrite);
    
    -- Inicializar totalizadores 
    vr_tot_qtdrejei := 0;
    vr_tot_vlpareje := 0;
    vr_tot_qtdreceb := 0;
    vr_tot_vlparceb := 0;
    vr_tot_qtdinteg := 0;
    vr_tot_vlpainte := 0;
    
    -- Inicializa o xml
    gene0002.pc_escreve_xml(vr_xmlrel_673,
                            vr_txtrel_673,
                           '<?xml version="1.0" encoding="utf-8"?>'||
                           '<root><convenios>');
      
    -- Iterar sobre os registros acumulados para o relatório 
    vr_idx_relato := vr_tab_relato_673.first;
    LOOP
      -- Sair quando terminar a leitura
      EXIT WHEN vr_idx_relato IS NULL;
      -- Enviar registro de consorcio 
      gene0002.pc_escreve_xml(vr_xmlrel_673
                             ,vr_txtrel_673
                             ,'<convenio cdagenci="'||to_char(vr_tab_relato_673(vr_idx_relato).cdagenci,'fm990')||'" '||
                                       ' nrdconta="'||gene0002.fn_mask_conta(vr_tab_relato_673(vr_idx_relato).nrdconta)||'" '||
                                       ' nrctacns="'||gene0002.fn_mask_conta(vr_tab_relato_673(vr_idx_relato).nrctacns)||'"'||
                                       ' nmempres="'||SUBSTR(vr_tab_relato_673(vr_idx_relato).nmempres,1,20)||'" '||
                                       ' cdrefere="'||vr_tab_relato_673(vr_idx_relato).cdrefere||'" '||
                                       ' vlparcns="'||TO_CHAR(vr_tab_relato_673(vr_idx_relato).vlparcns,'fm999g999g999g990d00')||'" '||
                                       ' dtdebito="'||TO_CHAR(vr_tab_relato_673(vr_idx_relato).dtdebito,'dd/mm/rrrr')||'" '||
                                       ' dscritic="'||gene0007.fn_caract_acento(pr_texto => SUBSTR(vr_tab_relato_673(vr_idx_relato).dscritic,1,35)
                                                                               ,pr_insubsti => 1)||'"/>');
      -- Acumular recebidos 
      vr_tot_qtdreceb := vr_tot_qtdreceb + 1;
      vr_tot_vlparceb := vr_tot_vlparceb + nvl(vr_tab_relato_673(vr_idx_relato).vlparcns,0);
      -- rejeitados / nao considera a critica 739 pois e de cancelamento de debitos
      IF vr_tab_relato_673(vr_idx_relato).cdcritic NOT IN(0,739) THEN 
        vr_tot_qtdrejei := vr_tot_qtdrejei + 1;
        vr_tot_vlpareje := vr_tot_vlpareje + nvl(vr_tab_relato_673(vr_idx_relato).vlparcns,0);
      END IF;
      -- Navegar ao proximo registro 
      vr_idx_relato := vr_tab_relato_673.next(vr_idx_relato);
    END LOOP;
    -- Ao final, calcular totais integrados 
    vr_tot_qtdinteg := vr_tot_qtdreceb - vr_tot_qtdrejei;
    vr_tot_vlpainte := vr_tot_vlparceb - vr_tot_vlpareje;
    -- Fecharemos a tag de consorcios e então enviaremos os totais e fecharemos o XML 
    gene0002.pc_escreve_xml(vr_xmlrel_673
                           ,vr_txtrel_673
                           ,'</convenios><total nmarquiv="'||vr_nmarqmov||'" '||
                                              ' qtdreceb="'||TO_CHAR(vr_tot_qtdreceb,'fm999g999g999g990')||'" '||
                                              ' vlparceb="'||TO_CHAR(vr_tot_vlparceb,'fm999g999g999g990d00')||'"'||
                                              ' qtdrejei="'||TO_CHAR(vr_tot_qtdrejei,'fm999g999g999g990')||'" '||
                                              ' vlpareje="'||TO_CHAR(vr_tot_vlpareje,'fm999g999g999g990d00')||'" '||
                                              ' qtdinteg="'||TO_CHAR(vr_tot_qtdinteg,'fm999g999g999g990')||'" '||
                                              ' vlpainte="'||TO_CHAR(vr_tot_vlpainte,'fm999g999g999g990d00')||'"/></root>'
                           ,true);    
    -- Por fim, iremos solicitar a emissão do relatório 
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                pr_dsxml     => vr_xmlrel_673,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/root/convenios/convenio',    --> No base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl673.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => NULL,                --> nao enviar parametros
                                pr_dsarqsaid =>  gene0001.fn_diretorio('C',pr_cdcooper,'rl')||'/crrl673.lst', --> Arquivo final
                                pr_flg_gerar => 'N',                 --> Não gerar o arquivo na hora
                                pr_qtcoluna  => 132,                  --> Quantidade de colunas
                                pr_cdrelato  => 673,                   --> Sequencia do cabecalho
                                pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '132col',             --> Nome do formulário para impressão
                                pr_nrcopias  => 1,                   --> Número de cópias para impressão
                                pr_dspathcop => NULL,                --> Diretorio para copia dos arquivos
                                pr_des_erro  => vr_dscritic);        --> Saida com erro

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_saida;
    END IF;

    -- Liberando a memoria alocada para os CLOBs
    dbms_lob.close(vr_xmlrel_673);
    dbms_lob.freetemporary(vr_xmlrel_673); 
  END IF; -- Dados para o relatório 673
  
  -- Se houve erro de integração 
  IF vr_geraerro THEN 
    -- Critica 191 
    vr_cdcritic := 191;
  ELSE 
    -- Critica 190 
    vr_cdcritic := 190;
  END IF; 
  
  -- Ao final do processamento, gerar critica ao LOG 
  btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                            ,pr_ind_tipo_log => 2 -- Erro tratato
                            ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                            ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                             || vr_cdprogra || ' --> '
                                             || gene0001.fn_busca_critica(vr_cdcritic) || ' --> ' 
                                             || vr_nmdirrec||'/'||vr_nmarqmov);      
      
  -- Move arquivo integrado para o diretorio recebidos 
  gene0001.pc_OSCommand_Shell(pr_des_comando => 'mv ' || vr_nmdirrec||'/'||vr_nmarqmov|| ' ' || vr_nmdirrcb||'/'||vr_nmarqmov
                             ,pr_typ_saida => vr_typsaida
                             ,pr_des_saida => vr_dessaida);
  -- Havendo erro, finalizar
  IF vr_typsaida = 'ERR' THEN
    vr_dscritic := 'Erro ao mover arquivo apos processar, alteracoes desfeitas --> ' || vr_dessaida;
    RAISE vr_exc_saida;
  END IF;
  
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
                             
    -- somente enviar e-mail caso nao for a critica de arquivo nao existe e nao for na cecred
    IF vr_cdcritic <> 182 AND pr_cdcooper = 3 OR
       pr_cdcooper <> 3 THEN    
                               
    vr_texto_email := '<b>Abaixo os erros encontrados no processo de importacao do debito SICREDI:</b><br><br>'||
                        to_char(SYSDATE,'dd/mm/yyyy HH24:MI:SS') || ' --> ' || vr_dscritic;

    -- Por fim, envia o email
    gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra
                              ,pr_des_destino => vr_emaildst
                              ,pr_des_assunto => 'Critica importacao debito - SICREDI'
                              ,pr_des_corpo   => vr_texto_email
                              ,pr_des_anexo   => NULL
                              ,pr_flg_enviar  => 'N'
                              ,pr_des_erro    => vr_dscritic);                         
    END IF;
                             
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
                              
    -- Devolvemos código e critica encontradas    
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    
    vr_texto_email := '<b>Abaixo os erros encontrados no processo de importacao do debito SICREDI:</b><br><br>'||
                      to_char(SYSDATE,'dd/mm/yyyy HH24:MI:SS') || ' --> ' || vr_dscritic;

    -- Por fim, envia o email
    gene0003.pc_solicita_email(pr_cdprogra    => vr_cdprogra
                              ,pr_des_destino => vr_emaildst
                              ,pr_des_assunto => 'Critica importacao debito - SICREDI'
                              ,pr_des_corpo   => vr_texto_email
                              ,pr_des_anexo   => NULL
                              ,pr_flg_enviar  => 'N'
                              ,pr_des_erro    => vr_dscritic);     
                                 
    -- Efetuar rollback
    ROLLBACK;
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;
END PC_CRPS647;
/
