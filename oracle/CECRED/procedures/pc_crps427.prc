CREATE OR REPLACE PROCEDURE CECRED.pc_crps427(pr_cdcooper  IN craptab.cdcooper%TYPE,
                                              pr_flgresta  IN PLS_INTEGER,            --> Flag padrão para utilização de restart
                                              pr_stprogra OUT PLS_INTEGER,            --> Saída de termino da execução
                                              pr_infimsol OUT PLS_INTEGER,            --> Saída de termino da solicitação,
                                              pr_cdcritic OUT crapcri.cdcritic%TYPE,
                                              pr_dscritic OUT VARCHAR2) AS
/* .............................................................................

   Programa: pc_crps427 - Antigo Fontes/crps427.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Dezembro/2004.                    Ultima atualizacao: 12/09/2017

   Dados referentes ao programa:

   Frequencia: Diario (Cadeia 1).

   Objetivo  : Atende a solicitacao 2.
               Emitir relatorio (391) da Conciliacao COBAN (Correspondente 
               Bancario).

   Alteracoes: 08/12/2004 - Gerar relatorio 397 (Evandro).
               
               13/12/2004 - Mudado o format da Hora Trans para HH:MM:SS
                            (Evandro).
                            
               10/01/2005 - Incluida a Agencia de Relacionamento de cada PAC
                            (Evandro).
                            
               07/03/2005 - Corrigida a forma de leitura para o relelatorio 397
                            e incluido comando de impressao do relatorio 397
                            (Evandro).

               01/07/2005 - Alimentado campo cdcooper da tabela craprcb (Diego).
               
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).    
               
               11/11/2005 - Desprezar tipo docto 3 (Recebimento INSS)(Mirtes)
                                                                 
               12/01/2006 - Tratar tipo docto 3- Recebto INSS(Mirtes)

               17/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               19/06/2006 - Incluir tratamento para docto tipo 3 no
                            Relatorio 397 (David).
                            
               15/01/2007 - Substituido dados da craptab "CORRESPOND" por
                            valores da crapage.cdagecbn (Elton).
               
               04/11/2008 - Divisao de colunas do relatorio 397 (martin)      

               29/04/2009 - Incluir no crrl391 as diferencas por PAC (Gabriel).
                
               12/08/2009 - Verificar diferencas da tabela craprcb para crapcbb
                          - Algumas leituras estavam sem NO-LOCK(Guilherme).
                          
               08/05/2012 - Incluído campos de codigo de barra e hora de
                            atendimento no relatorio 391 no item de 
                            "diferencas de valores" (Guilherme Maba).
                            
               04/01/2013 - Listar todos os documentos quando der diferenca.
                            Retirar comentarios desnecessarios.
                            (Gabriel).             
               
               09/09/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               09/10/2013 - Ajustes no crrl397, total do VLR.FAT estava errado,
                            ajustado cabecalho para 132col (Lucas R.)
                            
               14/10/2013 - Ajustes no crrl391, listar valores por PAs e nao
                            por cooperativa como estava (Lucas R.)
                            
               28/10/2013 - Incluir crapage.cdcooper = glb_cdcooper no FIND
                            do crapage do str_1 (Lucas R.)
                            
               20/11/2013 - Retirado NEXT do  relatorio str_1 crrl391, nao
                            usar NEXT em BREAK BY (Lucas R.)
                            
               24/01/2014 - Incluir VALIDATE craprcb (Lucas R.) 

               25/03/2014 - Conversão Progress >> Oracle PL/SQL (Daniel - Supero).
               
               22/01/2016 - #377293 Inclusão da função upper() no campo cdoperad, 
                            cursor cr_crapcbb (Carlos)
                            
               12/09/2017 - Decorrente a inclusão de novo parâmetro na rotina pc_abre_arquivo,
                            foi ncessário ajuste para mencionar os parâmetros no momento da chamada
                            (Adriano - SD 734960 ).
............................................................................. */

  -- Buscar os dados da cooperativa
  cursor cr_crapcop (pr_cdcooper in craptab.cdcooper%type) is
    select crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl
      from crapcop
     where cdcooper = pr_cdcooper;
  rw_crapcop     cr_crapcop%rowtype;
  -- Movimentos Correspondente Bancario - Banco do Brasil
  cursor cr_crapcbb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select crapcbb.cdagenci,
           crapcbb.flgrgatv,
           crapcbb.tpdocmto,
           crapcbb.dsdocmc7,
           count(*) qtde,
           sum(crapcbb.valorpag) valorpag,
           lpad(crapcbb.cdagenci, 3, ' ')||'  -  '||crapage.nmresage dsagenci
      from crapage,
           crapope,
           crapcbb
     where crapcbb.cdcooper = pr_cdcooper
       and crapcbb.dtmvtolt = pr_dtmvtolt
       and crapope.cdcooper = crapcbb.cdcooper
       and upper(crapope.cdoperad) = upper(crapcbb.cdopecxa)
       and crapage.cdcooper = crapcbb.cdcooper
       and crapage.cdagenci = crapcbb.cdagenci
     group by crapcbb.cdagenci,
              crapcbb.flgrgatv,
              crapcbb.tpdocmto,
              crapcbb.dsdocmc7,
              crapage.nmresage
     order by 1, 2, 3, 4;
  -- Retorno do COBAN (CBF800)
  cursor cr_craprcb (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select craprcb.cdagenci - 100 cdagenci,
           craprcb.cdtransa,
           craprcb.flgrgatv,
           craprcb.formaliq,
           count(*) qtde,
           sum(craprcb.valorpag) valorpag
      from crapage,
           craprcb
     where craprcb.cdcooper = pr_cdcooper
       and craprcb.dtmvtolt = pr_dtmvtolt
       and craprcb.cdtransa in ('268', '358', '284')
       and craprcb.cdagenci <> 9999
       and crapage.cdcooper = craprcb.cdcooper
       and crapage.cdagenci = craprcb.cdagenci - 100
     group by craprcb.cdagenci,
              craprcb.cdtransa,
              craprcb.flgrgatv,
              craprcb.formaliq
     order by 1, 2, 3, 4;
  -- Buscar diferenças da cooperativa em relação ao Banco do Brasil
  cursor cr_coopbb (pr_cdcooper in crapcop.cdcooper%type,
                    pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select cdbarras,
           cdagenci,
           nrdcaixa,
           valor_cooper,
           valor_coban,
           hora_coban
      from (select crapcbb.cdbarras,
                   crapcbb.cdagenci,
                   crapcbb.nrdcaixa,
                   crapcbb.valorpag valor_cooper,
                   sum(craprcb.valorpag) valor_coban,
                   gene0002.fn_converte_time_data(craprcb.hrdmovto, 'S') hora_coban
              from craprcb,
                   crapcbb
             where crapcbb.cdcooper = pr_cdcooper
               and crapcbb.dtmvtolt = pr_dtmvtolt
               and crapcbb.flgrgatv = 1
               and craprcb.cdcooper (+) = crapcbb.cdcooper
               and craprcb.cdbarras (+) = substr(crapcbb.cdbarras, 4)
               and craprcb.dtmvtolt (+) = crapcbb.dtmvtolt
               and craprcb.cdagenci (+) = crapcbb.cdagenci + 100
               and craprcb.nrdcaixa (+) = crapcbb.nrdcaixa
               and craprcb.flgrgatv (+) = crapcbb.flgrgatv
             group by crapcbb.cdbarras,
                      crapcbb.cdagenci,
                      crapcbb.nrdcaixa,
                      crapcbb.valorpag,
                      craprcb.hrdmovto)
     where valor_cooper <> valor_coban
    order by cdagenci,
             nrdcaixa,
             cdbarras;
  -- Buscar diferenças do Banco do Brasil em relação à cooperativa
  cursor cr_bbcoop (pr_cdcooper in crapcop.cdcooper%type,
                    pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select craprcb.cdbarras,
           craprcb.cdagenci,
           craprcb.nrdcaixa,
           craprcb.valorpag,
           gene0002.fn_converte_time_data(craprcb.hrdmovto, 'S') hora_coban
      from craprcb
     where craprcb.cdcooper = pr_cdcooper
       and craprcb.dtmvtolt = pr_dtmvtolt
       and craprcb.cdtransa in ('268','358','284')
       and craprcb.cdagenci <> 9999
       and not exists (select 1
                         from crapcbb
                        where crapcbb.cdcooper = craprcb.cdcooper
                          and substr(crapcbb.cdbarras, 4) = craprcb.cdbarras
                          and crapcbb.dtmvtolt = craprcb.dtmvtolt
                          and crapcbb.cdagenci = craprcb.cdagenci - 100
                          and crapcbb.nrdcaixa = craprcb.nrdcaixa
                          and crapcbb.flgrgatv = 1)
     order by craprcb.cdagenci,
              craprcb.nrdcaixa,
              craprcb.cdbarras;
  -- Movimentos Correspondente Bancario - Banco do Brasil (Mês)
  cursor cr_crapcbb_mes (pr_cdcooper in crapcop.cdcooper%type,
                         pr_dtiniper in crapdat.dtmvtolt%type,
                         pr_dtfimper in crapdat.dtmvtolt%type) is
    select crapcbb.cdagenci,
           crapcbb.tpdocmto,
           crapage.cdagecbn,
           count(*) qtde,
           sum(crapcbb.valorpag) valorpag
      from crapage,
           crapcbb
     where crapcbb.cdcooper = pr_cdcooper
       and crapcbb.dtmvtolt between pr_dtiniper and pr_dtfimper
       and crapcbb.flgrgatv = 1
       and crapage.cdcooper = crapcbb.cdcooper
       and crapage.cdagenci = crapcbb.cdagenci
     group by crapcbb.cdagenci,
              crapcbb.tpdocmto,
              crapage.cdagecbn
     order by 1, 2;
  -- PL/Table para armazenar os movimentos da craprcb e crapcbb (crrl391)
  type typ_movimento is record (dsagenci  varchar2(25),
                                cdagenci  crapage.cdagenci%type,
                                qttitrec  number(6),
                                vltitrec  crapcbb.valorpag%type,
                                qttitliq  number(6),
                                vltitliq  crapcbb.valorpag%type,
                                qttitcan  number(6),
                                vltitcan  crapcbb.valorpag%type,
                                qtfatrec  number(6),
                                vlfatrec  crapcbb.valorpag%type,
                                qtfatliq  number(6),
                                vlfatliq  crapcbb.valorpag%type,
                                qtfatcan  number(6),
                                vlfatcan  crapcbb.valorpag%type,
                                qtinss    number(6),
                                vlinss    crapcbb.valorpag%type,
                                qtdinhei  number(6),
                                vldinhei  crapcbb.valorpag%type,
                                qtcheque  number(6),
                                vlcheque  crapcbb.valorpag%type,
                                vlrepasse crapcbb.valorpag%type);
  type typ_tab_movimento is table of typ_movimento index by pls_integer;
  -- O índice da pl/table é o código da agência
  vr_ind_movto       crapage.cdagenci%type;
  -- Instâncias da pl/table
  vr_crapcbb         typ_tab_movimento;
  vr_craprcb         typ_tab_movimento;
  -- PL/Table para armazenar os movimentos da crapcbb (crrl397)
  type typ_crapcbb is record (cdagenci  crapage.cdagenci%type,
                              agrelaci  crapage.cdagecbn%type,
                              qttit     number(6),
                              vltit     crapcbb.valorpag%type,
                              qtfat     number(6),
                              vlfat     crapcbb.valorpag%type,
                              qttitfat  number(6),
                              vltitfat  crapcbb.valorpag%type,
                              vltotrec  crapcbb.valorpag%type,
                              qtdoinss  number(6),
                              vldoinss  crapcbb.valorpag%type,
                              vlttinss  crapcbb.valorpag%type);
  type typ_tab_crapcbb is table of typ_crapcbb index by pls_integer;
  -- O índice da pl/table é o código da agência
  vr_ind_crapcbb_mes crapage.cdagenci%type;
  -- Instâncias da pl/table
  vr_crapcbb_mes     typ_tab_crapcbb;
  --
  rw_crapdat         btch0001.cr_crapdat%rowtype;
  rw_craptab         btch0001.cr_craptab%rowtype;
  -- Código do programa
  vr_cdprogra        crapprg.cdprogra%type;
  -- Tratamento de erros
  vr_exc_saida       exception;
  vr_exc_fimprg      exception;
  vr_cdcritic        pls_integer;
  vr_dscritic        varchar2(4000);
  -- Variáveis para armazenar as informações em XML
  vr_des_xml         clob;
  -- Variável para armazenar os dados do XML antes de incluir no CLOB
  vr_texto_completo  varchar2(32600);
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio   varchar2(200);
  vr_nom_arquivo     varchar2(200);
  vr_nrcopias        number(1) := 1;
  -- PL/Table que vai armazenar os nomes de arquivos a serem processados
  vr_tab_arqtmp      gene0002.typ_split;
  vr_indice          integer;
  -- Variáveis para armazenar as taxas cadastradas na craptab
  vr_vldataxa        number(6,2);
  vr_vltxinss        number(6,2);
  -- Variáveis para armazenar os títulos usados no crrl391
  vr_cbb_titulo      varchar2(75);
  vr_rcb_titulo      varchar2(75);
  -- Variável para definir se exibe a seção de diferenças no relatório
  vr_tem_diferenca   boolean := false;
  vr_dsdircop        VARCHAR2(500);
  
  -- Busca o nome dos arquivos "cbf80*" na pasta "compbb" da cooperativa
  procedure pc_seleciona_arquivos (pr_dsdircop in  varchar2,     -- Diretorio da cooperativa
                                   pr_dscritic out varchar2) is  -- Descricao erro
    -- Retorno da função que busca os nomes de arquivos
    vr_listadir    varchar2(2000);
  begin
    -- Recupera a lista de arquivos "compbb/cbf80*"
    gene0001.pc_lista_arquivos(pr_path     => pr_dsdircop||'/compbb',
                               pr_pesq     => 'cbf80%',
                               pr_listarq  => vr_listadir,
                               pr_des_erro => pr_dscritic);
    -- Se ocorrer erro ao recuperar lista de arquivos, registra no log
    if trim(pr_dscritic) is not null then
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || pr_dscritic);
    end if;          
    --Carregar a lista de arquivos txt na pl/table
    vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listadir); 
  exception
    when others then
      pr_dscritic := 'Erro ao recuperar lista de arquivos de compbb: '||sqlerrm;
  end;

  -- Procedimento para importar as informações dos arquivos "cbf80*"
  procedure processa_arquivos (pr_dsdircop in  varchar2,
                               pr_nmarquiv in  varchar2,
                               pr_dscritic out varchar2) is
    cursor cr_craprcb (pr_cdcooper in crapcop.cdcooper%type,
                       pr_datadarq in craprcb.datadarq%type,
                       pr_nrseqarq in craprcb.nrseqarq%type) is
      select 1
        from craprcb
       where cdcooper = pr_cdcooper
         and datadarq = pr_datadarq
         and nrseqarq = pr_nrseqarq;
    rw_craprcb      cr_craprcb%rowtype;
    --
    vr_arquivo       utl_file.file_type;
    vr_setlinha      varchar2(500);
    vr_tipo_saida    varchar2(3);
    vr_datadarq      date;
    vr_nrseqarq      number(9);
    vr_rowid_rcb     varchar2(18);
    vr_tot_registro  number(15);
  BEGIN                    
    -- Abre o arquivo
    gene0001.pc_abre_arquivo(pr_nmdireto => pr_dsdircop||'/compbb',
                             pr_nmarquiv => pr_nmarquiv,
                             pr_tipabert => 'R',
                             pr_utlfileh => vr_arquivo,
                             pr_des_erro => pr_dscritic);
    if pr_dscritic is not null then
      raise vr_exc_saida;
    end if;
    -- Leitura da primeira linha do arquivo
    gene0001.pc_le_linha_arquivo(vr_arquivo,
                                 vr_setlinha);
    if substr(vr_setlinha, 1, 1) =  '0' then  -- Header do Arquivo
      vr_datadarq := to_date(substr(vr_setlinha, 5, 8), 'yyyymmdd');
      vr_nrseqarq := to_number(nvl(trim(substr(vr_setlinha, 28, 9)), '0'));
    end if;
    -- Verifica se existe retorno do COBAN
    open cr_craprcb (pr_cdcooper,
                     vr_datadarq,
                     vr_nrseqarq);
      fetch cr_craprcb into rw_craprcb;
      if cr_craprcb%notfound then
        -- Se ainda não existe, deve processar o arquivo
        loop
          -- Leitura das linhas do arquivo
          begin
            gene0001.pc_le_linha_arquivo(vr_arquivo,
                                         vr_setlinha);
          exception
            when no_data_found then
              -- Terminou o arquivo, deve sair do loop
              exit;
          end;
          -- Faz o tratamento de acordo com o tipo da linha
          if substr(vr_setlinha,1,1) = '1' then -- DETALHE 1
            begin
              insert into craprcb (datadarq,
                                   nrseqarq,
                                   nmarquiv,
                                   dtmvtolt,
                                   cdchaveb,
                                   cdtransa,
                                   dtdmovto,
                                   valorpag,
                                   cdagenci,
                                   nrdcaixa,
                                   formaliq,
                                   hrdmovto,
                                   autchave,
                                   cdagerel,
                                   cdcooper,
                                   flgrgatv)
              values (vr_datadarq,
                      vr_nrseqarq,
                      'compbb/'||pr_nmarquiv,
                      to_date(substr(vr_setlinha, 5, 8), 'yyyymmdd'),
                      substr(vr_setlinha,17,8),
                      substr(vr_setlinha,29,3),
                      to_date(substr(vr_setlinha, 32, 8), 'yyyymmdd'),
                      to_number(substr(vr_setlinha,46,17)) / 100,
                      to_number(substr(vr_setlinha,63,4)),
                      to_number(substr(vr_setlinha,67,4)),
                      to_number(substr(vr_setlinha,71,2)),
                      to_number(substr(vr_setlinha,40,6)),
                      to_number(substr(vr_setlinha,25,4)),
                      to_number(substr(vr_setlinha,13,4)),
                      pr_cdcooper,
                      decode(to_number(substr(vr_setlinha, 73, 3)),
                             3, 0,
                             1))
              returning rowid into vr_rowid_rcb;
            exception
              when others then
                close cr_craprcb;
                pr_dscritic := 'Erro ao criar retorno do COBAN: '||sqlerrm;
                return;
            end;          
          elsif substr(vr_setlinha,1,1) =  '2' then -- Detalhe 2
            begin
              update craprcb
                 set cdbarras = trim(substr(vr_setlinha,5,45))
               where rowid = vr_rowid_rcb;
            exception
              when others then
                close cr_craprcb;
                pr_dscritic := 'Erro ao incluir código de barras no retorno do COBAN: '||sqlerrm;
                return;
            end;          
          elsif substr(vr_setlinha,1,1) =  '9' then -- Totais registros
            vr_tot_registro := to_number(substr(vr_setlinha,5,15));
          end if;
        end loop;
      end if;
    close cr_craprcb;
    -- Mover o arquivo processado para a pasta "salvar" da cooperativa
    gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdircop||'/compbb/'||pr_nmarquiv||' '||pr_dsdircop||'/salvar',
                                pr_typ_saida   => vr_tipo_saida,
                                pr_des_saida   => pr_dscritic);
    -- testa erro
    if vr_tipo_saida = 'ERR' then
      pr_dscritic := 'Erro ao mover o arquivo : '||pr_dscritic;
    end if;
  end;

  -- Procedimento para criar a pl/table e zerar os valores
  procedure pc_inicializa_pltable (pr_cdagenci in crapage.cdagenci%type,
                                   pr_tipo     in number) is
  begin
    if pr_tipo = 1 then
      if vr_crapcbb.exists(pr_cdagenci) then
        return;
      end if;
      vr_crapcbb(pr_cdagenci).dsagenci := null;
      vr_crapcbb(pr_cdagenci).cdagenci := 0;
      vr_crapcbb(pr_cdagenci).qttitrec := 0;
      vr_crapcbb(pr_cdagenci).vltitrec := 0;
      vr_crapcbb(pr_cdagenci).qttitliq := 0;
      vr_crapcbb(pr_cdagenci).vltitliq := 0;
      vr_crapcbb(pr_cdagenci).qttitcan := 0;
      vr_crapcbb(pr_cdagenci).vltitcan := 0;
      vr_crapcbb(pr_cdagenci).qtfatrec := 0;
      vr_crapcbb(pr_cdagenci).vlfatrec := 0;
      vr_crapcbb(pr_cdagenci).qtfatliq := 0;
      vr_crapcbb(pr_cdagenci).vlfatliq := 0;
      vr_crapcbb(pr_cdagenci).qtfatcan := 0;
      vr_crapcbb(pr_cdagenci).vlfatcan := 0;
      vr_crapcbb(pr_cdagenci).qtinss := 0;
      vr_crapcbb(pr_cdagenci).vlinss := 0;
      vr_crapcbb(pr_cdagenci).qtdinhei := 0;
      vr_crapcbb(pr_cdagenci).vldinhei := 0;
      vr_crapcbb(pr_cdagenci).qtcheque := 0;
      vr_crapcbb(pr_cdagenci).vlcheque := 0;
      vr_crapcbb(pr_cdagenci).vlrepasse := 0;
    elsif pr_tipo = 2 then
      if vr_craprcb.exists(pr_cdagenci) then
        return;
      end if;
      vr_craprcb(pr_cdagenci).dsagenci := null;
      vr_craprcb(pr_cdagenci).cdagenci := 0;
      vr_craprcb(pr_cdagenci).qttitrec := 0;
      vr_craprcb(pr_cdagenci).vltitrec := 0;
      vr_craprcb(pr_cdagenci).qttitliq := 0;
      vr_craprcb(pr_cdagenci).vltitliq := 0;
      vr_craprcb(pr_cdagenci).qttitcan := 0;
      vr_craprcb(pr_cdagenci).vltitcan := 0;
      vr_craprcb(pr_cdagenci).qtfatrec := 0;
      vr_craprcb(pr_cdagenci).vlfatrec := 0;
      vr_craprcb(pr_cdagenci).qtfatliq := 0;
      vr_craprcb(pr_cdagenci).vlfatliq := 0;
      vr_craprcb(pr_cdagenci).qtfatcan := 0;
      vr_craprcb(pr_cdagenci).vlfatcan := 0;
      vr_craprcb(pr_cdagenci).qtinss := 0;
      vr_craprcb(pr_cdagenci).vlinss := 0;
      vr_craprcb(pr_cdagenci).qtdinhei := 0;
      vr_craprcb(pr_cdagenci).vldinhei := 0;
      vr_craprcb(pr_cdagenci).qtcheque := 0;
      vr_craprcb(pr_cdagenci).vlcheque := 0;
      vr_craprcb(pr_cdagenci).vlrepasse := 0;
    elsif pr_tipo = 3 then
      if vr_crapcbb_mes.exists(pr_cdagenci) then
        return;
      end if;
      vr_crapcbb_mes(pr_cdagenci).cdagenci := pr_cdagenci;
      vr_crapcbb_mes(pr_cdagenci).agrelaci := 0;
      vr_crapcbb_mes(pr_cdagenci).qttit    := 0;
      vr_crapcbb_mes(pr_cdagenci).vltit    := 0;
      vr_crapcbb_mes(pr_cdagenci).qtfat    := 0;
      vr_crapcbb_mes(pr_cdagenci).vlfat    := 0;
      vr_crapcbb_mes(pr_cdagenci).qttitfat := 0;
      vr_crapcbb_mes(pr_cdagenci).vltitfat := 0;
      vr_crapcbb_mes(pr_cdagenci).vltotrec := 0;
      vr_crapcbb_mes(pr_cdagenci).qtdoinss := 0;
      vr_crapcbb_mes(pr_cdagenci).vldoinss := 0;
      vr_crapcbb_mes(pr_cdagenci).vlttinss := 0;
    end if;
  end;

  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2,
                           pr_fecha_xml in boolean default false) is
  begin
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  end;

begin
  -- Nome do programa
  vr_cdprogra := 'CRPS427';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS427',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se ocorreu erro
  if vr_cdcritic <> 0 then
    -- Envio centralizado de log de erro
    raise vr_exc_saida;
  end if;
  -- Verifica se a cooperativa esta cadastrada
  open cr_crapcop(pr_cdcooper);
    fetch cr_crapcop into rw_crapcop;
    -- Verificar se existe informação, e gerar erro caso não exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exceção
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close btch0001.cr_crapdat;
  
  -- diretorio padrao da cooperativa
  vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                      ,pr_cdcooper => pr_cdcooper
                                      ,pr_nmsubdir => ''); 
  
  -- INÍCIO DA IMPORTAÇÃO DOS ARQUIVOS
  -- Busca os nomes dos arquivos a processar e inclui na PL/Table
  pc_seleciona_arquivos(vr_dsdircop,
                        vr_dscritic);
  if vr_dscritic is not null then
    raise vr_exc_saida;
  end if;
  -- Leitura da PL/Table e processamento dos arquivos
  vr_indice := vr_tab_arqtmp.first;
  while vr_indice is not null loop
    -- Chama o procedimento que faz a leitura do arquivo
    processa_arquivos(vr_dsdircop,
                      vr_tab_arqtmp(vr_indice),
                      vr_dscritic);
    vr_indice := vr_tab_arqtmp.next(vr_indice);
  end loop;
  -- FINAL DA IMPORTAÇÃO DOS ARQUIVOS
  -- ********************************
  -- INÍCIO DO RELATÓRIO CRRL397
  -- Cria o registro para o total na pl/table e zera os seus campos
  pc_inicializa_pltable(99999,
                        1);
  -- Leitura dos movimentos Banco do Brasil
  for rw_crapcbb in cr_crapcbb (pr_cdcooper,
                                rw_crapdat.dtmvtolt) loop
    -- Cria o registro para a agência na pl/table e zera os seus campos
    pc_inicializa_pltable(rw_crapcbb.cdagenci,
                          1);
    -- Cria o registro para a agência na pl/table e zera os seus campos
    pc_inicializa_pltable(rw_crapcbb.cdagenci,
                          2);
    -- Nome da agência (cabeçalho da página do relatório)
    vr_crapcbb(rw_crapcbb.cdagenci).dsagenci := rw_crapcbb.dsagenci;
    vr_crapcbb(rw_crapcbb.cdagenci).cdagenci := rw_crapcbb.cdagenci;
    -- para o resumo da cooperativa
    if rw_crapcbb.tpdocmto = 1 then  -- Titulos
      vr_crapcbb(rw_crapcbb.cdagenci).qttitrec := vr_crapcbb(rw_crapcbb.cdagenci).qttitrec + rw_crapcbb.qtde;
      vr_crapcbb(rw_crapcbb.cdagenci).vltitrec := vr_crapcbb(rw_crapcbb.cdagenci).vltitrec + rw_crapcbb.valorpag;
      vr_crapcbb(99999).qttitrec := vr_crapcbb(99999).qttitrec + rw_crapcbb.qtde;
      vr_crapcbb(99999).vltitrec := vr_crapcbb(99999).vltitrec + rw_crapcbb.valorpag;
      --se registro estiver ativo 
      if rw_crapcbb.flgrgatv = 1 then 
        vr_crapcbb(rw_crapcbb.cdagenci).qttitliq := vr_crapcbb(rw_crapcbb.cdagenci).qttitliq + rw_crapcbb.qtde;
        vr_crapcbb(rw_crapcbb.cdagenci).vltitliq := vr_crapcbb(rw_crapcbb.cdagenci).vltitliq + rw_crapcbb.valorpag;
        vr_crapcbb(99999).qttitliq := vr_crapcbb(99999).qttitliq + rw_crapcbb.qtde;
        vr_crapcbb(99999).vltitliq := vr_crapcbb(99999).vltitliq + rw_crapcbb.valorpag;
      else
        vr_crapcbb(rw_crapcbb.cdagenci).qttitcan := vr_crapcbb(rw_crapcbb.cdagenci).qttitcan + rw_crapcbb.qtde;
        vr_crapcbb(rw_crapcbb.cdagenci).vltitcan := vr_crapcbb(rw_crapcbb.cdagenci).vltitcan + rw_crapcbb.valorpag;
        vr_crapcbb(99999).qttitcan := vr_crapcbb(99999).qttitcan + rw_crapcbb.qtde;
        vr_crapcbb(99999).vltitcan := vr_crapcbb(99999).vltitcan + rw_crapcbb.valorpag;
      end if;
    else -- Faturas
      --se tipo de documento for 2
      if rw_crapcbb.tpdocmto = 2 then
        vr_crapcbb(rw_crapcbb.cdagenci).qtfatrec := vr_crapcbb(rw_crapcbb.cdagenci).qtfatrec + rw_crapcbb.qtde;
        vr_crapcbb(rw_crapcbb.cdagenci).vlfatrec := vr_crapcbb(rw_crapcbb.cdagenci).vlfatrec + rw_crapcbb.valorpag;
        vr_crapcbb(99999).qtfatrec := vr_crapcbb(99999).qtfatrec + rw_crapcbb.qtde;
        vr_crapcbb(99999).vlfatrec := vr_crapcbb(99999).vlfatrec + rw_crapcbb.valorpag;
        --se o registro estiver ativo
        if rw_crapcbb.flgrgatv = 1 then 
          vr_crapcbb(rw_crapcbb.cdagenci).qtfatliq := vr_crapcbb(rw_crapcbb.cdagenci).qtfatliq + rw_crapcbb.qtde;
          vr_crapcbb(rw_crapcbb.cdagenci).vlfatliq := vr_crapcbb(rw_crapcbb.cdagenci).vlfatliq + rw_crapcbb.valorpag;
          vr_crapcbb(99999).qtfatliq := vr_crapcbb(99999).qtfatliq + rw_crapcbb.qtde;
          vr_crapcbb(99999).vlfatliq := vr_crapcbb(99999).vlfatliq + rw_crapcbb.valorpag;
        else
          vr_crapcbb(rw_crapcbb.cdagenci).qtfatcan := vr_crapcbb(rw_crapcbb.cdagenci).qtfatcan + rw_crapcbb.qtde;
          vr_crapcbb(rw_crapcbb.cdagenci).vlfatcan := vr_crapcbb(rw_crapcbb.cdagenci).vlfatcan + rw_crapcbb.valorpag;
          vr_crapcbb(99999).qtfatcan := vr_crapcbb(99999).qtfatcan + rw_crapcbb.qtde;
          vr_crapcbb(99999).vlfatcan := vr_crapcbb(99999).vlfatcan + rw_crapcbb.valorpag;
        end if;
      ELSE
        --se o registro estiver ativo
        if rw_crapcbb.flgrgatv = 1 then
          vr_crapcbb(rw_crapcbb.cdagenci).qtinss := vr_crapcbb(rw_crapcbb.cdagenci).qtinss + rw_crapcbb.qtde;
          vr_crapcbb(rw_crapcbb.cdagenci).vlinss := vr_crapcbb(rw_crapcbb.cdagenci).vlinss + rw_crapcbb.valorpag;
          vr_crapcbb(99999).qtinss := vr_crapcbb(99999).qtinss + rw_crapcbb.qtde;
          vr_crapcbb(99999).vlinss := vr_crapcbb(99999).vlinss + rw_crapcbb.valorpag;
        end if;
      end if;
    end if;
    --se o registro estiver ativo e tipo de documento for diferente de 3
    if rw_crapcbb.flgrgatv = 1 and
       rw_crapcbb.tpdocmto <> 3 then 
      --se CMC-7 do cheque acolhido para deposito estiver nulo
      if rw_crapcbb.dsdocmc7 = ' ' then 
        vr_crapcbb(rw_crapcbb.cdagenci).qtdinhei := vr_crapcbb(rw_crapcbb.cdagenci).qtdinhei + rw_crapcbb.qtde;
        vr_crapcbb(rw_crapcbb.cdagenci).vldinhei := vr_crapcbb(rw_crapcbb.cdagenci).vldinhei + rw_crapcbb.valorpag;
        vr_crapcbb(99999).qtdinhei := vr_crapcbb(99999).qtdinhei + rw_crapcbb.qtde;
        vr_crapcbb(99999).vldinhei := vr_crapcbb(99999).vldinhei + rw_crapcbb.valorpag;
      else
        vr_crapcbb(rw_crapcbb.cdagenci).qtcheque := vr_crapcbb(rw_crapcbb.cdagenci).qtcheque + rw_crapcbb.qtde;
        vr_crapcbb(rw_crapcbb.cdagenci).vlcheque := vr_crapcbb(rw_crapcbb.cdagenci).vlcheque + rw_crapcbb.valorpag;
        vr_crapcbb(99999).qtcheque := vr_crapcbb(99999).qtcheque + rw_crapcbb.qtde;
        vr_crapcbb(99999).vlcheque := vr_crapcbb(99999).vlcheque + rw_crapcbb.valorpag;
      end if;
    end if;
    -- Totaliza o valor da remessa
    vr_crapcbb(rw_crapcbb.cdagenci).vlrepasse := vr_crapcbb(rw_crapcbb.cdagenci).vltitliq + vr_crapcbb(rw_crapcbb.cdagenci).vlfatliq - vr_crapcbb(rw_crapcbb.cdagenci).vlinss;
    vr_crapcbb(99999).vlrepasse := vr_crapcbb(99999).vltitliq + vr_crapcbb(99999).vlfatliq - vr_crapcbb(99999).vlinss;
  end loop;
  -- Cria o registro para o total na pl/table e zera os seus campos
  pc_inicializa_pltable(99999,
                        2);
  -- Leitura do retorno do COBAN (antigo gera_relatorio_bb)
  for rw_craprcb in cr_craprcb (pr_cdcooper,
                                rw_crapdat.dtmvtolt) loop
    -- Cria o registro para a agência na pl/table e zera os seus campos
    pc_inicializa_pltable(rw_craprcb.cdagenci,
                          2);
    -- para o resumo do banco do brasil
    if rw_craprcb.cdtransa = '268' then  -- Titulos
      vr_craprcb(rw_craprcb.cdagenci).qttitrec := vr_craprcb(rw_craprcb.cdagenci).qttitrec + rw_craprcb.qtde;
      vr_craprcb(rw_craprcb.cdagenci).vltitrec := vr_craprcb(rw_craprcb.cdagenci).vltitrec + rw_craprcb.valorpag;
      vr_craprcb(99999).qttitrec := vr_craprcb(99999).qttitrec + rw_craprcb.qtde;
      vr_craprcb(99999).vltitrec := vr_craprcb(99999).vltitrec + rw_craprcb.valorpag;
      --se o registro estiver ativo
      if rw_craprcb.flgrgatv = 1 then 
        vr_craprcb(rw_craprcb.cdagenci).qttitliq := vr_craprcb(rw_craprcb.cdagenci).qttitliq + rw_craprcb.qtde;
        vr_craprcb(rw_craprcb.cdagenci).vltitliq := vr_craprcb(rw_craprcb.cdagenci).vltitliq + rw_craprcb.valorpag;
        vr_craprcb(99999).qttitliq := vr_craprcb(99999).qttitliq + rw_craprcb.qtde;
        vr_craprcb(99999).vltitliq := vr_craprcb(99999).vltitliq + rw_craprcb.valorpag;
      else
        vr_craprcb(rw_craprcb.cdagenci).qttitcan := vr_craprcb(rw_craprcb.cdagenci).qttitcan + rw_craprcb.qtde;
        vr_craprcb(rw_craprcb.cdagenci).vltitcan := vr_craprcb(rw_craprcb.cdagenci).vltitcan + rw_craprcb.valorpag;
        vr_craprcb(99999).qttitcan := vr_craprcb(99999).qttitcan + rw_craprcb.qtde;
        vr_craprcb(99999).vltitcan := vr_craprcb(99999).vltitcan + rw_craprcb.valorpag;
      end if;
    else -- Faturas
      --se transacao for 358
      if rw_craprcb.cdtransa = '358' then
        vr_craprcb(rw_craprcb.cdagenci).qtfatrec := vr_craprcb(rw_craprcb.cdagenci).qtfatrec + rw_craprcb.qtde;
        vr_craprcb(rw_craprcb.cdagenci).vlfatrec := vr_craprcb(rw_craprcb.cdagenci).vlfatrec + rw_craprcb.valorpag;
        vr_craprcb(99999).qtfatrec := vr_craprcb(99999).qtfatrec + rw_craprcb.qtde;
        vr_craprcb(99999).vlfatrec := vr_craprcb(99999).vlfatrec + rw_craprcb.valorpag;
        --se o registro estiver ativo
        if rw_craprcb.flgrgatv = 1 then 
          vr_craprcb(rw_craprcb.cdagenci).qtfatliq := vr_craprcb(rw_craprcb.cdagenci).qtfatliq + rw_craprcb.qtde;
          vr_craprcb(rw_craprcb.cdagenci).vlfatliq := vr_craprcb(rw_craprcb.cdagenci).vlfatliq + rw_craprcb.valorpag;
          vr_craprcb(99999).qtfatliq := vr_craprcb(99999).qtfatliq + rw_craprcb.qtde;
          vr_craprcb(99999).vlfatliq := vr_craprcb(99999).vlfatliq + rw_craprcb.valorpag;
        else
          vr_craprcb(rw_craprcb.cdagenci).qtfatcan := vr_craprcb(rw_craprcb.cdagenci).qtfatcan + rw_craprcb.qtde;
          vr_craprcb(rw_craprcb.cdagenci).vlfatcan := vr_craprcb(rw_craprcb.cdagenci).vlfatcan + rw_craprcb.valorpag;
          vr_craprcb(99999).qtfatcan := vr_craprcb(99999).qtfatcan + rw_craprcb.qtde;
          vr_craprcb(99999).vlfatcan := vr_craprcb(99999).vlfatcan + rw_craprcb.valorpag;
        end if;
      ELSE
        --se o registro estiver ativo        
        if rw_craprcb.flgrgatv = 1 then
          vr_craprcb(rw_craprcb.cdagenci).qtinss := vr_craprcb(rw_craprcb.cdagenci).qtinss + rw_craprcb.qtde;
          vr_craprcb(rw_craprcb.cdagenci).vlinss := vr_craprcb(rw_craprcb.cdagenci).vlinss + rw_craprcb.valorpag;
          vr_craprcb(99999).qtinss := vr_craprcb(99999).qtinss + rw_craprcb.qtde;
          vr_craprcb(99999).vlinss := vr_craprcb(99999).vlinss + rw_craprcb.valorpag;
        end if;
      end if;
    end if;
    --se o registro estiver ativo
    if rw_craprcb.flgrgatv = 1 and
       rw_craprcb.cdtransa <> '284' then 
      if rw_craprcb.formaliq = 1 then 
        vr_craprcb(rw_craprcb.cdagenci).qtdinhei := vr_craprcb(rw_craprcb.cdagenci).qtdinhei + rw_craprcb.qtde;
        vr_craprcb(rw_craprcb.cdagenci).vldinhei := vr_craprcb(rw_craprcb.cdagenci).vldinhei + rw_craprcb.valorpag;
        vr_craprcb(99999).qtdinhei := vr_craprcb(99999).qtdinhei + rw_craprcb.qtde;
        vr_craprcb(99999).vldinhei := vr_craprcb(99999).vldinhei + rw_craprcb.valorpag;
      else
        vr_craprcb(rw_craprcb.cdagenci).qtcheque := vr_craprcb(rw_craprcb.cdagenci).qtcheque + rw_craprcb.qtde;
        vr_craprcb(rw_craprcb.cdagenci).vlcheque := vr_craprcb(rw_craprcb.cdagenci).vlcheque + rw_craprcb.valorpag;
        vr_craprcb(99999).qtcheque := vr_craprcb(99999).qtcheque + rw_craprcb.qtde;
        vr_craprcb(99999).vlcheque := vr_craprcb(99999).vlcheque + rw_craprcb.valorpag;
      end if;
    end if;
    -- Totaliza o valor da remessa
    vr_craprcb(rw_craprcb.cdagenci).vlrepasse := vr_craprcb(rw_craprcb.cdagenci).vltitliq + vr_craprcb(rw_craprcb.cdagenci).vlfatliq - vr_craprcb(rw_craprcb.cdagenci).vlinss;
    vr_craprcb(99999).vlrepasse := vr_craprcb(99999).vltitliq + vr_craprcb(99999).vlfatliq - vr_craprcb(99999).vlinss;
  end loop;
  -- Incluir informações no XML para geração do relatório
  -- Definição do diretório e nome do arquivo a ser gerado
  vr_nom_diretorio := gene0001.fn_diretorio('c',  -- /usr/coop
                                            pr_cdcooper,
                                            'rl');
  vr_nom_arquivo := 'crrl391.lst';
  -- Leitura da PL/Table e geração do arquivo XML para o relatório
  -- Inicializar o CLOB
  vr_des_xml := null;
  dbms_lob.createtemporary(vr_des_xml, true);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  vr_texto_completo := null;
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl391>');
  -- Leitura da PL/Table
  vr_ind_movto := vr_crapcbb.first;
  while vr_ind_movto is not null loop
    -- Define o cabeçalho da sessão
    if vr_ind_movto = 99999 then
      vr_cbb_titulo := '   TOTAL DOS MOVIMENTOS DA COOPERATIVA';
      vr_rcb_titulo := '     TOTAL DOS MOVIMENTOS DO BANCO DO BRASIL';
    else
      vr_cbb_titulo := 'RESUMO DOS MOVIMENTOS DA COOPERATIVA - PA '||vr_ind_movto;
      vr_rcb_titulo := 'RESUMO DOS MOVIMENTOS DO BANCO DO BRASIL - PA '||vr_ind_movto;
    end if;
    -- Inclui informações da agência no XML
    pc_escreve_xml('<agencia dsagenci="'||vr_crapcbb(vr_ind_movto).dsagenci||'">'||
                      '<cbb_titulo>'   ||vr_cbb_titulo||'</cbb_titulo>'||
                      '<cbb_qttitrec>' ||vr_crapcbb(vr_ind_movto).qttitrec ||'</cbb_qttitrec>'||
                      '<cbb_vltitrec>' ||vr_crapcbb(vr_ind_movto).vltitrec ||'</cbb_vltitrec>'||
                      '<cbb_qttitliq>' ||vr_crapcbb(vr_ind_movto).qttitliq ||'</cbb_qttitliq>'||
                      '<cbb_vltitliq>' ||vr_crapcbb(vr_ind_movto).vltitliq ||'</cbb_vltitliq>'||
                      '<cbb_qttitcan>' ||vr_crapcbb(vr_ind_movto).qttitcan ||'</cbb_qttitcan>'||
                      '<cbb_vltitcan>' ||vr_crapcbb(vr_ind_movto).vltitcan ||'</cbb_vltitcan>'||
                      '<cbb_qtfatrec>' ||vr_crapcbb(vr_ind_movto).qtfatrec ||'</cbb_qtfatrec>'||
                      '<cbb_vlfatrec>' ||vr_crapcbb(vr_ind_movto).vlfatrec ||'</cbb_vlfatrec>'||
                      '<cbb_qtfatliq>' ||vr_crapcbb(vr_ind_movto).qtfatliq ||'</cbb_qtfatliq>'||
                      '<cbb_vlfatliq>' ||vr_crapcbb(vr_ind_movto).vlfatliq ||'</cbb_vlfatliq>'||
                      '<cbb_qtfatcan>' ||vr_crapcbb(vr_ind_movto).qtfatcan ||'</cbb_qtfatcan>'||
                      '<cbb_vlfatcan>' ||vr_crapcbb(vr_ind_movto).vlfatcan ||'</cbb_vlfatcan>'||
                      '<cbb_qtinss>'   ||vr_crapcbb(vr_ind_movto).qtinss   ||'</cbb_qtinss  >'||
                      '<cbb_vlinss>'   ||vr_crapcbb(vr_ind_movto).vlinss   ||'</cbb_vlinss  >'||
                      '<cbb_qtdinhei>' ||vr_crapcbb(vr_ind_movto).qtdinhei ||'</cbb_qtdinhei>'||
                      '<cbb_vldinhei>' ||vr_crapcbb(vr_ind_movto).vldinhei ||'</cbb_vldinhei>'||
                      '<cbb_qtcheque>' ||vr_crapcbb(vr_ind_movto).qtcheque ||'</cbb_qtcheque>'||
                      '<cbb_vlcheque>' ||vr_crapcbb(vr_ind_movto).vlcheque ||'</cbb_vlcheque>'||
                      '<cbb_vlremessa>'||vr_crapcbb(vr_ind_movto).vlrepasse||'</cbb_vlremessa>'||
                      '<rcb_titulo>'   ||vr_rcb_titulo||'</rcb_titulo>'||
                      '<rcb_qttitrec>' ||vr_craprcb(vr_ind_movto).qttitrec ||'</rcb_qttitrec>'||
                      '<rcb_vltitrec>' ||vr_craprcb(vr_ind_movto).vltitrec ||'</rcb_vltitrec>'||
                      '<rcb_qttitliq>' ||vr_craprcb(vr_ind_movto).qttitliq ||'</rcb_qttitliq>'||
                      '<rcb_vltitliq>' ||vr_craprcb(vr_ind_movto).vltitliq ||'</rcb_vltitliq>'||
                      '<rcb_qttitcan>' ||vr_craprcb(vr_ind_movto).qttitcan ||'</rcb_qttitcan>'||
                      '<rcb_vltitcan>' ||vr_craprcb(vr_ind_movto).vltitcan ||'</rcb_vltitcan>'||
                      '<rcb_qtfatrec>' ||vr_craprcb(vr_ind_movto).qtfatrec ||'</rcb_qtfatrec>'||
                      '<rcb_vlfatrec>' ||vr_craprcb(vr_ind_movto).vlfatrec ||'</rcb_vlfatrec>'||
                      '<rcb_qtfatliq>' ||vr_craprcb(vr_ind_movto).qtfatliq ||'</rcb_qtfatliq>'||
                      '<rcb_vlfatliq>' ||vr_craprcb(vr_ind_movto).vlfatliq ||'</rcb_vlfatliq>'||
                      '<rcb_qtfatcan>' ||vr_craprcb(vr_ind_movto).qtfatcan ||'</rcb_qtfatcan>'||
                      '<rcb_vlfatcan>' ||vr_craprcb(vr_ind_movto).vlfatcan ||'</rcb_vlfatcan>'||
                      '<rcb_qtinss>'   ||vr_craprcb(vr_ind_movto).qtinss   ||'</rcb_qtinss  >'||
                      '<rcb_vlinss>'   ||vr_craprcb(vr_ind_movto).vlinss   ||'</rcb_vlinss  >'||
                      '<rcb_qtdinhei>' ||vr_craprcb(vr_ind_movto).qtdinhei ||'</rcb_qtdinhei>'||
                      '<rcb_vldinhei>' ||vr_craprcb(vr_ind_movto).vldinhei ||'</rcb_vldinhei>'||
                      '<rcb_qtcheque>' ||vr_craprcb(vr_ind_movto).qtcheque ||'</rcb_qtcheque>'||
                      '<rcb_vlcheque>' ||vr_craprcb(vr_ind_movto).vlcheque ||'</rcb_vlcheque>'||
                      '<rcb_vlremessa>'||vr_craprcb(vr_ind_movto).vlrepasse||'</rcb_vlremessa>'||
                   '</agencia>');
    vr_ind_movto := vr_crapcbb.next(vr_ind_movto);
  end loop;
  -- Verifica se o fechamento esta OK
  if vr_crapcbb(99999).qttitliq <> vr_craprcb(99999).qttitliq or
     vr_crapcbb(99999).vltitliq <> vr_craprcb(99999).vltitliq or
     vr_crapcbb(99999).qtfatliq <> vr_craprcb(99999).qtfatliq or
     vr_crapcbb(99999).vlfatliq <> vr_craprcb(99999).vlfatliq or
     vr_crapcbb(99999).qtinss <> vr_craprcb(99999).qtinss or
     vr_crapcbb(99999).vlinss <> vr_craprcb(99999).vlinss or
     vr_crapcbb(99999).qtdinhei <> vr_craprcb(99999).qtdinhei or
     vr_crapcbb(99999).vldinhei <> vr_craprcb(99999).vldinhei or
     vr_crapcbb(99999).qtcheque <> vr_craprcb(99999).qtcheque or
     vr_crapcbb(99999).vlcheque <> vr_craprcb(99999).vlcheque then
    -- Busca diferenças da cooperativa em relação ao Banco do Brasil
    for rw_coopbb in cr_coopbb (pr_cdcooper,
                                rw_crapdat.dtmvtolt) loop
      -- Se encontrar diferenças, inclui no XML
      vr_tem_diferenca := true;
      pc_escreve_xml('<diferenca tipo="DA COOPERATIVA EM RELACAO AO BANCO DO BRASIL">'||
                        '<linha1> PA '||lpad(rw_coopbb.cdagenci, 3, ' ')||
                               '  -  Caixa '||lpad(rw_coopbb.nrdcaixa, 3, ' ')||
                               '  Coop. => '||lpad(to_char(rw_coopbb.valor_cooper, 'fm9G999G990D00'), 12, ' ')||
                               '  BB => '||lpad(to_char(rw_coopbb.valor_coban, 'fm9G999G990D00'), 12, ' ')||
                        '</linha1>'||
                        '<linha2>Cod. Barras '||rw_coopbb.cdbarras||
                               ' Hora '||rw_coopbb.hora_coban||
                        '</linha2>'||
                     '</diferenca>');
    end loop;
    -- Busca diferenças do Banco do Brasil em relação à cooperativa
    for rw_bbcoop in cr_bbcoop (pr_cdcooper,
                                rw_crapdat.dtmvtolt) loop
      -- Se encontrar diferenças, inclui no XML
      vr_tem_diferenca := true;
      pc_escreve_xml('<diferenca tipo="DO BANCO DO BRASIL EM RELACAO A COOPERATIVA">'||
                        '<linha1> PA '||lpad(rw_bbcoop.cdagenci - 100, 10, ' ')||
                               '  -  Caixa '||lpad(rw_bbcoop.nrdcaixa, 4, ' ')||
                               '  BB => '||lpad(to_char(rw_bbcoop.valorpag, 'fm9G999G990D00'), 14, ' ')||
                        '</linha1>'||
                        '<linha2>Cod. Barras '||rw_bbcoop.cdbarras||
                               '    Hora '||rw_bbcoop.hora_coban||
                        '</linha2>'||
                     '</diferenca>');
    end loop;
  end if;
  -- Se não encontrou diferenças, gera uma tag para informar o ireport que não precisa exibir este subreport
  if not vr_tem_diferenca then
    pc_escreve_xml('<diferenca tipo="0"></diferenca>');
  end if;
  -- Fecha o XML
  pc_escreve_xml('</crrl391>',
                 true);
  -- Solicita o relatório
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                              pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                              pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                              pr_dsxmlnode => '/crrl391',  --> Nó base do XML para leitura dos dados
                              pr_dsjasper  => 'crrl391.jasper',    --> Arquivo de layout do iReport
                              pr_dsparams  => null,
                              pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                              pr_flg_gerar => 'N',
                              pr_qtcoluna  => 132,
                              pr_sqcabrel  => 1,
                              pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                              pr_nmformul  => '132col',            --> Nome do formulário para impressão
                              pr_nrcopias  => vr_nrcopias,         --> Número de cópias para impressão
                              pr_des_erro  => vr_dscritic);        --> Saída com erro
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);
  -- Testar se houve erro
  if vr_dscritic is not null then
    -- Gerar exceção
    vr_cdcritic := 0;
    raise vr_exc_saida;
  end if;
  -- FINAL DO RELATÓRIO CRRL391
  -- ***********************************
  -- INÍCIO DO RELATÓRIO CRRL397
  -- Deve executar apenas quando for o último dia do mês
  if to_char(rw_crapdat.dtmvtolt, 'mm') <> to_char(rw_crapdat.dtmvtopr, 'mm') then
    -- para pegar o valor da taxa
    open btch0001.cr_craptab (pr_cdcooper,
                              'CRED',
                              'USUARI',
                              11,
                              'CORRESPOND',
                              0,
                              null);
      fetch btch0001.cr_craptab into rw_craptab;
      -- Verificar se existe informação, e gerar erro caso não exista
      if btch0001.cr_craptab%found then
        -- Atribui taxas às variáveis
        vr_vldataxa := to_number(substr(rw_craptab.dstextab, 15, 6));
        vr_vltxinss := to_number(substr(rw_craptab.dstextab, 22, 6));
      end if;
    close btch0001.cr_craptab;
    -- Cria o registro para o total na pl/table e zera os seus campos
    pc_inicializa_pltable(99999,
                          3);
    -- Busca as informações do mês
    for rw_crapcbb_mes in cr_crapcbb_mes(pr_cdcooper,
                                         rw_crapdat.dtinimes,
                                         rw_crapdat.dtultdia) loop
      -- Cria o registro para a agência na pl/table e zera os seus campos
      pc_inicializa_pltable(rw_crapcbb_mes.cdagenci,
                            3);
      -- Código da agência (cabeçalho da página do relatório)
      vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).cdagenci := rw_crapcbb_mes.cdagenci;
      vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).agrelaci := rw_crapcbb_mes.cdagecbn;
      -- Tarifas Titulo/Faturas
      if rw_crapcbb_mes.tpdocmto in (1, 2) then
        if rw_crapcbb_mes.tpdocmto = 1 then  -- Titulos
          vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qttit := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qttit + rw_crapcbb_mes.qtde;
          vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vltit := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vltit + rw_crapcbb_mes.valorpag;
          vr_crapcbb_mes(99999).qttit := vr_crapcbb_mes(99999).qttit + rw_crapcbb_mes.qtde;
          vr_crapcbb_mes(99999).vltit := vr_crapcbb_mes(99999).vltit + rw_crapcbb_mes.valorpag;
        else -- Faturas
          vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qtfat := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qtfat + rw_crapcbb_mes.qtde;
          vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vlfat := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vlfat + rw_crapcbb_mes.valorpag;
          vr_crapcbb_mes(99999).qtfat := vr_crapcbb_mes(99999).qtfat + rw_crapcbb_mes.qtde;
          vr_crapcbb_mes(99999).vlfat := vr_crapcbb_mes(99999).vlfat + rw_crapcbb_mes.valorpag;
        end if;
        -- Títulos + faturas
        vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qttitfat := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qttitfat + rw_crapcbb_mes.qtde;
        vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vltitfat := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vltitfat + rw_crapcbb_mes.valorpag;
        vr_crapcbb_mes(99999).qttitfat := vr_crapcbb_mes(99999).qttitfat + rw_crapcbb_mes.qtde;
        vr_crapcbb_mes(99999).vltitfat := vr_crapcbb_mes(99999).vltitfat + rw_crapcbb_mes.valorpag;
      end if;
      -- Tarifas INSS
      if rw_crapcbb_mes.tpdocmto = 3 then
        vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qtdoinss := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qtdoinss + rw_crapcbb_mes.qtde;
        vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vldoinss := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vldoinss + rw_crapcbb_mes.valorpag;
        vr_crapcbb_mes(99999).qtdoinss := vr_crapcbb_mes(99999).qtdoinss + rw_crapcbb_mes.qtde;
        vr_crapcbb_mes(99999).vldoinss := vr_crapcbb_mes(99999).vldoinss + rw_crapcbb_mes.valorpag;
      end if;
      -- Total de receitas e de INSS
      vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vltotrec := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qttitfat * vr_vldataxa;
      vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).vlttinss := vr_crapcbb_mes(rw_crapcbb_mes.cdagenci).qtdoinss * vr_vltxinss;
      vr_crapcbb_mes(99999).vltotrec := vr_crapcbb_mes(99999).qttitfat * vr_vldataxa;
      vr_crapcbb_mes(99999).vlttinss := vr_crapcbb_mes(99999).qtdoinss * vr_vltxinss;
    end loop;
    -- Incluir informações no XML para geração do relatório
    -- Definição do diretório e nome do arquivo a ser gerado
    vr_nom_diretorio := gene0001.fn_diretorio('C',  -- /usr/coop
                                              pr_cdcooper,
                                              'rl');
    vr_nom_arquivo := 'crrl397.lst';
    -- Leitura da PL/Table e geração do arquivo XML para o relatório
    -- Inicializar o CLOB
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := null;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl397>');
    -- Leitura da PL/Table
    vr_ind_crapcbb_mes := vr_crapcbb_mes.first;
    while vr_ind_crapcbb_mes is not null loop
      pc_escreve_xml('<agencia cdagenci="'||vr_crapcbb_mes(vr_ind_crapcbb_mes).cdagenci||'">'||
                        '<agrelaci>'    ||vr_crapcbb_mes(vr_ind_crapcbb_mes).agrelaci||'</agrelaci>'||
                        '<mes_qttit>'   ||vr_crapcbb_mes(vr_ind_crapcbb_mes).qttit   ||'</mes_qttit>'||
                        '<mes_vltit>'   ||vr_crapcbb_mes(vr_ind_crapcbb_mes).vltit   ||'</mes_vltit>'||
                        '<mes_qtfat>'   ||vr_crapcbb_mes(vr_ind_crapcbb_mes).qtfat   ||'</mes_qtfat>'||
                        '<mes_vlfat>'   ||vr_crapcbb_mes(vr_ind_crapcbb_mes).vlfat   ||'</mes_vlfat>'||
                        '<mes_qttitfat>'||vr_crapcbb_mes(vr_ind_crapcbb_mes).qttitfat||'</mes_qttitfat>'||
                        '<mes_vltitfat>'||vr_crapcbb_mes(vr_ind_crapcbb_mes).vltitfat||'</mes_vltitfat>'||
                        '<mes_vltotrec>'||vr_crapcbb_mes(vr_ind_crapcbb_mes).vltotrec||'</mes_vltotrec>'||
                        '<mes_qtdoinss>'||vr_crapcbb_mes(vr_ind_crapcbb_mes).qtdoinss||'</mes_qtdoinss>'||
                        '<mes_vldoinss>'||vr_crapcbb_mes(vr_ind_crapcbb_mes).vldoinss||'</mes_vldoinss>'||
                        '<mes_vlttinss>'||vr_crapcbb_mes(vr_ind_crapcbb_mes).vlttinss||'</mes_vlttinss>'||
                     '</agencia>');
      vr_ind_crapcbb_mes := vr_crapcbb_mes.next(vr_ind_crapcbb_mes);
    end loop;
    -- Fecha o XML
    pc_escreve_xml('</crrl397>',
                   true);
    -- Solicita o relatório
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crrl397/agencia',  --> Nó base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl397.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => null,
                                pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 234,
                                pr_sqcabrel  => 2,
                                pr_flg_impri => 'S',                 --> Chamar a impressão (Imprim.p)
                                pr_nmformul  => '234dh',            --> Nome do formulário para impressão
                                pr_nrcopias  => vr_nrcopias,         --> Número de cópias para impressão
                                pr_des_erro  => vr_dscritic);        --> Saída com erro
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    -- Testar se houve erro
    if vr_dscritic is not null then
      -- Gerar exceção
      vr_cdcritic := 0;
      raise vr_exc_saida;
    end if;
  end if;
  -- FINAL DO RELATÓRIO CRRL397
  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  --
  commit;
exception
  when vr_exc_fimprg then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Se foi gerada critica para envio ao log
    if vr_cdcritic > 0 or vr_dscritic is not null then
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );
    end if;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    commit;
  when vr_exc_saida then
    -- Se foi retornado apenas código
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    rollback;
  when others then
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    rollback;
end;
/
