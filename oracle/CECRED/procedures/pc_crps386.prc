create or replace procedure cecred.pc_crps386(pr_cdcooper  in craptab.cdcooper%type,
                                       pr_flgresta  in pls_integer,            --> Flag padr�o para utiliza��o de restart
                                       pr_stprogra out pls_integer,            --> Sa�da de termino da execu��o
                                       pr_infimsol out pls_integer,            --> Sa�da de termino da solicita��o,
                                       pr_cdcritic out crapcri.cdcritic%type,
                                       pr_dscritic out varchar2) as
/* ..........................................................................

   Programa: pc_crps386 - Antigo Fontes/crps386.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio/Mirtes
   Data    : Abril/2004                    Ultima atualizacao: 23/08/2016

   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Gerar arquivo de atualizacao de cadastro de debito em conta
               para convenios
               Solicitacao : 086
               Ordem do programa na solicitacao = 1.
               Exclusividade = 2
               Relatorio 343.

   Alteracao : 29/09/2004 - Tratamento para o convenio 5 - CELESC CECRED
                            (Julio)

               03/11/2004 - Tratamento para o convenio 15 - VIVO (Julio) 
               
               26/11/2004 - Tratamento para convenio 16 - SAMAE TIMBO (Julio)

               30/11/2004 - Cooperativa 1, nunca vai com "9001" na frente do
                            numero da conta (Julio)

               07/01/2005 - Tamanho do codigo de referencia para convenio 15
                            deve ser igual a 11 (Julio)
                            
               26/01/2005 - Tratamento para SAMAE GASPAR CECRED (Julio)
                            
               02/02/2005 - Tratamento SAMAE BLUMENAU CECRED (Julio)
               
               22/04/2005 - Tratamento UNIMED (Julio)

               30/05/2005 - Tratamento Aguas Itapema -> 24 (Julio)

               24/08/2005 - Tratamento Samae Brusque -> 25 / 616 (Julio)
               
               23/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               20/10/2005 - Tratamento Samae Pomerode -> 26 / 619 (Julio)
               
               12/01/2006 - Tratamento para email's em branco (Julio)
               
               12/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               13/10/2006 - Tratamento para CELESC Distribuicao -> 30 (Julio)
               
               24/11/2006 - Acertar envio de email pela BO b1wgen0011 (David).
               
               27/11/2006 - Restringir envio de email para convenio 28 - Unimed
                            (Elton).
               
               02/02/2007 - Tratamento para DAE Navegantes -> 31 (Elton).
               
               31/05/2007 - Restringir envio de arquivo contendo autorizacoes
                            de debito para convenio 32 - Uniodonto (Elton).
               
               01/06/2007 - Incluido possibilidade de envio de arquivo para
                            Accestage (Elton).
               
               19/11/2007 - Tratamento para Aguas de Joinville -> 33 (Elton).
               
               26/11/2007 - Tratamento para SEMASA Itajai -> 34 (Elton).
               
               09/06/2008 - Inclu�da a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "for each" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               01/07/2008 - Alterados "finds e for eachs" para buscar o codigo
                            da cooperativa atraves da variavel "glb_cdcooper"
                            nas tabelas genericas. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               15/08/2008 - Tratamento para o convenio SAMAE Jaragua -> 9
                            (Diego).
               
               26/02/2009 - Acerto na leitura da tabela gncooper, campo
                            cdcooper (Diego).
               
               16/10/2009 - Restringir envio de arquivo de autorizacoes para
                            convenio 38 - Unimed Planalto Norte e convenio 43 -
                            Servmed (Elton).
                            
               11/05/2010 - Tratamento para convenio 45 - Aguas Pres. Getulio;
                          - Tratamento para convenio 48 - TIM Celular (Elton).
                            
               01/10/2010 - Tratamento para Samae Rio Negrinho -> 49 (Elton).
               
               05/04/2011 - Tratamento para CERSAD -> 51;
                          - Tratamento para Foz do Brasil -> 53;
                          - Tratamento para Aguas de Massaranduba -> 54 (Elton).

               27/01/2012 - Tratamento para Unificacao Arq. Convenios
                            (Guilherme/Supero)
                            
               22/06/2012 - Substituido gncoper por crapcop (Tiago).
               
               02/07/2012 - Alterado nomeclatura do relat�rio gerado incluindo 
                            c�digo do convenio (Guilherme Maba).
                            
               02/08/2012 - Acerto para convenios com arquivos unificados que 
                            utilizam a Nexxera, para enviar somente o arquivo 
                            unificado para a van (Elton).
                            
               09/10/2012 - Tratamento para executar o programa todos os dias 
                            (Elton).
               
               31/07/2013 - Melhorias no c�digo fonte e envio da informacao da 
                            agencia da cooperativa na Cecred no arquivo de 
                            inclusoes (Elton).
                            
               22/01/2014 - Incluir VALIDATE gncvuni, gncontr (Lucas R.) 

               02/04/2014 - Convers�o Progress >> Oracle PL/SQL (Daniel - Supero).
               
               28/05/2014 - Retirado mensagens do log, "Executando Integracao 
                            Arq.Convenio, conforme chamdado: 146188 
                            data: 07/04/2014 - "Geracao de arquivo para unificacao", 
                            chamado: 146197 data: 07/04/2014 - "Sem movtos Convenio", 
                            chamado: 146206 data: 07/04/2014 - J�ssica (DB1).
                            
               26/08/2014 - D�bito F�cil : Tratamento para autoriza��es de d�bitos que
                            foram suspensas pelos usu�rios (Vanessa).
                            
               08/10/2014 - #184874 Retorno das mensagens de log retiradas em 28/05.
                            Altera��o de pr_flg_gerar para'S' na procedure pc_solicita_relato_arquivo
                            para gerar o arquivo na hora (Carlos)
               
               13/10/2014 - Corre��o no cursor cr_crapatr, trocando o order by 6 pelo alias do campo 
                            inexecuc para n�o afetar a ordena��o caso novos campos sejam incluidos (Vanessa).

               22/10/2014 - Adicionado + 2 no contador de linhas ref. ao cabe�alho e rodap� do arquivo gerado (Carlos)
               
               23/10/2014 - Adicionada a convers�o ux2dos dos arquivos que s�o enviados por e-mail (Carlos)
               
               31/10/2014 - Ajuste para buscar novamente o nrseqatu e lockar o registro
                            para que outra cooperativa n�o gere arquivo com o mesmo sequencial 
                            (SD 216255 Odirlei-AMcom).
                            
               29/11/2014 - Implementacao Van E-Sales (utilizacao inicial pela Oi).
                            (Chamado 192004) - (Fabricio)
                                 
               26/08/2015 - Caso a data de inicio da autoriza��o seja menor que 01/09/2013 
                            e for um cancelamento de debito ira buscar o campo para agencia 
                            "cdagedeb", caso contrario busca "cdagectl" (Lucas Ranghetti #296778)
                            
               15/06/2016 - Adicnioar ux2dos para a Van E-sales (Lucas Ranghetti #469980)
                            
      			   13/07/2016 - Nao deve mais enviar o codigo da cooperativa na frente do campo conta.
			                      Chamado 407247 (Heitor - RKAM)
                            
               23/08/2016 - Verificar final de semanas e feriados para verificar suspen��es
                            (Lucas Ranghetti #499496)             
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
  -- Buscar os conv�nios ativos por cooperativa
  cursor cr_gnconve (pr_cdcooper in crapcop.cdcooper%type) is
    select gnconve.cdcooper,
           gnconve.nmempres,
           gnconve.cdhisdeb,
           gnconve.cdconven,
           gnconve.flgcvuni,
           gnconve.nrcnvfbr,
           gnconve.cddbanco,
           gnconve.nrseqatu,
           gnconve.nmarqatu,
           gnconve.dsenddeb,
           gnconve.tpdenvio,
           gnconve.cdagedeb,
           crapcop.nmrescop,
           gnconve.rowid row_id
      from craphis,
           crapcop,
           gnconve,
           gncvcop
     where gncvcop.cdcooper = pr_cdcooper     
       and gnconve.cdconven = gncvcop.cdconven
       and gnconve.flgativo = 1
       and gnconve.cdhisdeb > 0 -- Somente arq.integracao
       and gnconve.nmarqatu <> ' '
       and crapcop.cdcooper = gnconve.cdcooper
       and craphis.cdcooper = gncvcop.cdcooper
       and craphis.cdhistor = gnconve.cdhisdeb;
  -- Buscar autorizacoes de debito em conta
  cursor cr_crapatr (pr_cdcooper in crapcop.cdcooper%type,
                     pr_dtmovini IN crapdat.dtmvtolt%TYPE,
                     pr_dtmvtolt in crapdat.dtmvtolt%type,
                     pr_cdhisdeb in gnconve.cdhisdeb%type) is
    select crapatr.dtiniatr,           
           crapatr.dtfimsus,
           crapatr.dtfimatr,
           crapatr.dtinisus,  
           crapatr.cdrefere,
           crapatr.nrdconta,
           substr(crapatr.nmfatura, 1, 40) nmfatura,
           case 
               when crapatr.dtfimatr =  pr_dtmvtolt then 'CANCELAMENTOS'
               when crapatr.dtinisus =  pr_dtmvtolt then 'CANCELAMENTOS'
               else 'INCLUSOES'
            end tipo,
            case 
               when crapatr.dtfimatr =  pr_dtmvtolt then 1
               when crapatr.dtinisus =  pr_dtmvtolt then 1
               else 2
            end inexecuc
                     
      from crapatr
     where crapatr.cdcooper = pr_cdcooper
       and (   crapatr.dtiniatr = pr_dtmvtolt
            or crapatr.dtfimatr = pr_dtmvtolt
            or crapatr.dtinisus = pr_dtmvtolt 
            or crapatr.dtfimsus BETWEEN pr_dtmovini AND pr_dtmvtolt)
       and crapatr.cdhistor = pr_cdhisdeb
     order by inexecuc,
              nlssort(crapatr.nmfatura, 'NLS_SORT=BINARY_AI'),
              crapatr.nrdconta,
              crapatr.cdhistor,
              crapatr.cdrefere;
  rw_crapatr         cr_crapatr%rowtype;
  -- Buscar controle de execu��es
  cursor cr_gncontr (pr_cdcooper in crapcop.cdcooper%type,
                     pr_cdconven in gnconve.cdconven%type,
                     pr_dtmvtolt in crapdat.dtmvtolt%type) is
    select gncontr.nrsequen,
           gncontr.rowid row_id
      from gncontr
     where gncontr.cdcooper = pr_cdcooper
       and gncontr.tpdcontr = 2 -- Atual.Cad.Deb.Autom.
       and gncontr.cdconven = pr_cdconven
       and gncontr.dtmvtolt = pr_dtmvtolt;
  
  -- Busca sequencial do convenio atualizado e
  -- deixar registro com lock, para o sequencial n�o ser utilizado por outra cooperativa
  CURSOR cr_gbconve (pr_rowid rowid)is
    SELECT nrseqatu
      FROM gnconve
     WHERE gnconve.rowid = pr_rowid
     FOR UPDATE; 
  rw_gbconve cr_gbconve%rowtype;
       
  rw_gncontr         cr_gncontr%rowtype;
  -- Informa��es de data
  rw_crapdat         btch0001.cr_crapdat%rowtype;
  -- C�digo do programa
  vr_cdprogra        crapprg.cdprogra%type;
  -- Tratamento de erros
  vr_exc_saida       exception;
  vr_exc_fimprg      exception;
  vr_cdcritic        pls_integer;
  vr_dscritic        varchar2(4000);
  vr_typ_said        varchar2(3);
  -- Vari�vel para armazenar as informa��es em XML
  vr_des_xml         clob;
  -- Vari�vel para armazenar os dados do XML antes de incluir no CLOB
  vr_texto_completo  varchar2(32600);
  -- Vari�vel para armazenar as informa��es em TXT
  vr_des_txt         clob;
  -- Vari�vel para armazenar os dados do TXT antes de incluir no CLOB
  vr_texto_completo_txt  varchar2(32600);
  -- Vari�vel auxiliar para preenchimento do TXT
  vr_dslinreg        varchar2(153);
  -- Vari�veis para o caminho e nome do arquivo base
  vr_nom_diretorio   varchar2(200);
  vr_nom_arquivo     varchar2(200);
  -- Vari�veis utilizadas para solicita��o do relat�rio
  vr_nrcopias        number(1) := 1;
  vr_flgremarq       varchar2(1);
  -- PL/Table que vai armazenar os destinat�rios para envio de e-mail
  vr_destinatarios   gene0002.typ_split;
  vr_indice          integer;
  -- Vari�veis auxiliares para o processamento
  vr_cdcooperativa   varchar2(4);
  vr_tot_qtregist    number(5);
  vr_nrseqarq        gncontr.nrsequen%type;
  vr_cdrefere        varchar2(27);
  vr_inexecuc        number(1);
  vr_dtautori        varchar2(8);
  vr_cdidenti        varchar2(27);
  vr_concvuni        gncvuni.nrseqreg%type;
  vr_nmdbanco        crapcop.nmrescop%type;
  vr_nrdbanco        gnconve.cddbanco%type;
  vr_nragenci        crapcop.cdagectl%type;
  vr_nrconven        gnconve.nrcnvfbr%type;
  vr_nmempcon        gnconve.nmempres%type;
  vr_nrsequen        varchar2(6);
  vr_nmarqdat        varchar2(100);
  vr_nmarqped        varchar2(24);
  vr_dtmovini        DATE;

  -- Subrotina para escrever texto na vari�vel CLOB do XML
  procedure pc_escreve_xml(pr_des_dados in varchar2,
                           pr_fecha_xml in boolean default false) is
  begin
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  end;
  -- Subrotina para escrever texto na vari�vel CLOB do TXT
  procedure pc_escreve_txt(pr_des_dados in varchar2,
                           pr_fecha_txt in boolean default false) is
  begin
    gene0002.pc_escreve_xml(vr_des_txt, vr_texto_completo_txt, pr_des_dados, pr_fecha_txt);
  end;

begin
  -- Nome do programa
  vr_cdprogra := 'CRPS386';
  -- Incluir nome do m�dulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS386',
                             pr_action => vr_cdprogra);
  -- Valida��es iniciais do programa
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
    -- Verificar se existe informa��o, e gerar erro caso n�o exista
    if cr_crapcop%notfound then
      -- Fechar o cursor
      close cr_crapcop;
      -- Gerar exce��o
      vr_cdcritic := 57;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close cr_crapcop;
  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    -- Verificar se existe informa��o, e gerar erro caso n�o exista
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor
      close btch0001.cr_crapdat;
      -- Gerar exce��o
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      raise vr_exc_saida;
    end if;
  close btch0001.cr_crapdat;

  -- Data anterior util
  vr_dtmovini := gene0005.fn_valida_dia_util(pr_cdcooper,
                                             (rw_crapdat.dtmvtolt - 1), -- 1 dia anterior
                                             'A',    -- Anterior
                                             TRUE,   -- Feriado
                                             FALSE); -- Desconsiderar 31/12
  -- Adiciona mais um 1 dia na data inicial, para pegar finais de semana e feriados
  vr_dtmovini := vr_dtmovini + 1;

 -- N�mero sequencial para Movimento de Convenios Unificados
  vr_concvuni := 0;
  -- Leitura dos conv�nios ativos para a cooperativa
  for rw_gnconve in cr_gnconve (pr_cdcooper) loop
    -- Inclui mensagem no log
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || 'Executando Integracao Arq. Convenio - '
                                               || to_char(rw_gnconve.cdconven) || '  - '
                                               || rw_gnconve.nmempres );
    -- Verifica se o conv�nio possui movimento
    -- Se n�o tem movimento, n�o precisa gerar os arquivos
    open cr_crapatr (pr_cdcooper,
                     vr_dtmovini,
                     rw_crapdat.dtmvtolt,
                     rw_gnconve.cdhisdeb);
      fetch cr_crapatr into rw_crapatr;
      if cr_crapatr%notfound then
        -- Inclui mensagem no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || 'Sem movtos Convenio - '
                                                   || to_char(rw_gnconve.cdconven));
        -- Fecha o cursor e passa para o pr�ximo conv�nio
        close cr_crapatr;
        continue;
      end if;
    close cr_crapatr;
    -- Define o c�digo da cooperativa
    if rw_gnconve.cdcooper = pr_cdcooper or 
       pr_cdcooper = 1 then
      vr_cdcooperativa := ' ';
    else
      --Solicitado no chamado 407247 que n�o envie mais o c�digo da cooperativa na frente da conta
      --Deixei o IF acima para deixar mais claro a condi��o que era utilizada anteriormente, pode ser retirado posteriormente.
      --vr_cdcooperativa := '9'||to_char(pr_cdcooper,'fm000');
      vr_cdcooperativa := ' ';
    end if;
    -- Procedure NOMEIA_ARQUIVOS do progress
    open cr_gncontr (pr_cdcooper,
                     rw_gnconve.cdconven,
                     rw_crapdat.dtmvtolt);
      fetch cr_gncontr into rw_gncontr;
      if cr_gncontr%found then
        vr_nrseqarq := rw_gncontr.nrsequen;
      else
        
        -- Busca sequencial do convenio atualizado
        OPEN cr_gbconve (pr_rowid => rw_gnconve.row_id); 
        FETCH cr_gbconve INTO rw_gbconve;
        CLOSE cr_gbconve;
        
        -- Procedure OBTEM_ATUALIZA_SEQUENCIA do progress
        vr_nrseqarq := rw_gbconve.nrseqatu;
        if not rw_gnconve.flgcvuni = 1 then
          begin
            update gnconve
               set nrseqatu = nrseqatu + 1
             where rowid = rw_gnconve.row_id
            returning nrseqatu into rw_gnconve.nrseqatu;
          exception
            when others then
              vr_dscritic := 'Erro ao atualizar gnconve.nrseqatu: '||sqlerrm;
              raise vr_exc_saida;
          end;
        end if;
        --
        begin
          insert into gncontr (cdcooper,
                               tpdcontr,
                               cdconven,
                               dtmvtolt,
                               nrsequen)
          values (pr_cdcooper,
                  2,
                  rw_gnconve.cdconven,
                  rw_crapdat.dtmvtolt,
                  vr_nrseqarq)
          returning nrsequen, rowid into rw_gncontr;
        exception
          when others then
            vr_dscritic := 'Erro ao inserir gncontr: '||sqlerrm;
            raise vr_exc_saida;
        end;
        -- Fim da procedure OBTEM_ATUALIZA_SEQUENCIA do progress
      end if;
    close cr_gncontr;
    --
    vr_nmdbanco := rw_gnconve.nmrescop;
    --
    if rw_gnconve.cdconven = 14 then
      vr_nmdbanco := ' ';
    end if;
    --
    vr_nrdbanco := rw_gnconve.cddbanco;
    vr_nrconven := rw_gnconve.nrcnvfbr;
    vr_nmempcon := rw_gnconve.nmempres;
    --
    vr_nrsequen := to_char(vr_nrseqarq, 'fm000000');
    --
    vr_nmarqdat := trim(substr(rw_gnconve.nmarqatu, 1, 4))||
                       to_char(rw_crapdat.dtmvtolt, 'mmdd')||'.'||
                       substr(vr_nrsequen, 4, 3);
    --
    if substr(rw_gnconve.nmarqatu,5,2)  = 'MM' and
       substr(rw_gnconve.nmarqatu,7,2)  = 'DD' and
       substr(rw_gnconve.nmarqatu,10,3) = 'TXT' then
      vr_nmarqdat := trim(substr(rw_gnconve.nmarqatu, 1, 4)) +            
                         to_char(rw_crapdat.dtmvtolt, 'mmdd')||
                         '.txt';
    end if;
    --
    if substr(rw_gnconve.nmarqatu,5,2)  = 'DD' and
       substr(rw_gnconve.nmarqatu,7,2)  = 'MM' and
       substr(rw_gnconve.nmarqatu,10,3) = 'RET' then 
      vr_nmarqdat := trim(substr(rw_gnconve.nmarqatu, 1, 4))||
                          to_char(rw_crapdat.dtmvtolt, 'ddmm')||
                          '.ret';
    end if;
    --
    if substr(rw_gnconve.nmarqatu,5,2)  = 'CP' and -- Cooperativa
       substr(rw_gnconve.nmarqatu,7,2)  = 'MM' and
       substr(rw_gnconve.nmarqatu,9,2)  = 'DD' and
       substr(rw_gnconve.nmarqatu,12,3) = 'SEQ' then 
      vr_nmarqdat := trim(substr(rw_gnconve.nmarqatu, 1, 4))||
                          to_char(rw_gnconve.cdcooper, 'fm00')||
                          to_char(rw_crapdat.dtmvtolt, 'mmdd')||
                          '.'||substr(vr_nrsequen, 4, 3);
    end if;
    --
    if substr(rw_gnconve.nmarqatu,4,1)  = 'C' and
       substr(rw_gnconve.nmarqatu,5,4)  = 'SEQU' and
       substr(rw_gnconve.nmarqatu,10,3) = 'RET' then 
      vr_nmarqdat := trim(substr(rw_gnconve.nmarqatu, 1, 3))||
                         to_char(rw_gnconve.cdcooper, 'fm0')||
                         substr(vr_nrsequen, 3, 4)||'.ret';
    end if;
    --
    vr_nmarqped := vr_nmarqdat;
    -- Fim da procedure NOMEIA_ARQUIVOS do progress
    --
    -- O programa gera simultaneamente um arquivo texto e um relat�rio (XML)
    -- Define o nome do arquivo, de acordo com o conv�nio, pois ir� gerar um relat�rio para cada conv�nio
    vr_nom_arquivo := 'crrl343_c'||to_char(rw_gnconve.cdconven, 'fm0000')||'.lst';
    -- Leitura da PL/Table e gera��o do arquivo XML para o relat�rio
    -- Inicializar o CLOB do XML
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    -- Inicilizar as informa��es do XML
    vr_texto_completo := null;
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?>'||
                     '<crrl386>'||
                       '<nmarqdat>'||vr_nmarqped||'</nmarqdat>'||
                       '<nmempcon>'||rpad(rw_gnconve.nmempres, 20, ' ')||'</nmempcon>');
    -- Inicializar o CLOB do TXT
    vr_des_txt := null;
    dbms_lob.createtemporary(vr_des_txt, true);
    dbms_lob.open(vr_des_txt, dbms_lob.lob_readwrite);
    -- Inicilizar as informa��es do TXT
    vr_texto_completo_txt := null;
    pc_escreve_txt('A2'||          
                   rpad(rw_gnconve.nrcnvfbr, 20, ' ')||
                   rpad(rw_gnconve.nmempres, 20, ' ')||
                   to_char(rw_gnconve.cddbanco, 'fm000')||
                   rpad(rw_gnconve.nmrescop, 20, ' ')||
                   to_char(rw_crapdat.dtmvtolt, 'yyyymmdd')||
                   to_char(vr_nrseqarq, 'fm000000')||
                   '04DEBITO AUTOMATICO'||
                   '                                                    '||
                   chr(10));
    -- Vari�veis de controle
    vr_inexecuc := 0;
    vr_tot_qtregist := 0;
    -- Leitura das autorizacoes de debito em conta
    for rw_crapatr in cr_crapatr (pr_cdcooper,
                                  vr_dtmovini,
                                  rw_crapdat.dtmvtolt,
                                  rw_gnconve.cdhisdeb) loop
            
      -- Atribuir a data da autoriza��o
      vr_dtautori := to_char(rw_crapatr.dtiniatr, 'yyyymmdd');
     
      IF rw_gnconve.cdconven = 4 THEN -- CASAN
        vr_nragenci := 1294;
      ELSE
        -- Caso a data de inicio da autoriza��o seja menor que 01/09/2013 e for um cancelamento 
        -- de debito ira gravar a agencia com formato antigo. Ex: "0001"            
        -- Caso contrario grava com novo formato. Ex: 0101
        IF (rw_crapatr.dtiniatr < to_date('01/09/2013','dd/mm/yyyy')) THEN 
          vr_nragenci := TRIM(rw_gnconve.cdagedeb);
        ELSE
          vr_nragenci := rw_crapcop.cdagectl;      
        END IF;
      END IF;

      if rw_gnconve.cdconven <> 1 then -- Brasil Telecom
         if rw_crapatr.inexecuc = 1 THEN 
            if rw_crapatr.dtfimatr = rw_crapdat.dtmvtolt then
               vr_dtautori := to_char(rw_crapatr.dtfimatr, 'yyyymmdd');
            else 
               vr_dtautori := to_char(rw_crapatr.dtinisus, 'yyyymmdd');
            end if; 
         else 
            if rw_crapatr.dtiniatr = rw_crapdat.dtmvtolt then
               vr_dtautori := to_char(rw_crapatr.dtiniatr, 'yyyymmdd');
            else
               vr_dtautori := to_char(rw_crapdat.dtmvtolt, 'yyyymmdd');
            end if; 
         end if;     
      end if;
            
      --
      if rw_gnconve.cdconven in (8, 16, 19, 20, 25, 26, 11, 49) then
        vr_cdidenti := to_char(rw_crapatr.cdrefere, 'fm000000')||lpad(' ', 19, ' ');
      elsif rw_gnconve.cdconven in (4, 24, 31, 33, 53, 54) then
        vr_cdidenti := to_char(rw_crapatr.cdrefere, 'fm00000000')||lpad(' ', 17, ' ');
      elsif rw_gnconve.cdconven in (2, 10, 5, 30, 14, 45, 51) then
        vr_cdidenti := to_char(rw_crapatr.cdrefere, 'fm000000000')||lpad(' ', 16, ' ');
      elsif rw_gnconve.cdconven in (3, 48) then
        vr_cdidenti := to_char(rw_crapatr.cdrefere, 'fm00000000000000000000')||lpad(' ', 5, ' ');
      elsif rw_gnconve.cdconven = 15 then
        vr_cdidenti := to_char(rw_crapatr.cdrefere, 'fm00000000000')||lpad(' ', 14, ' ');
      elsif rw_gnconve.cdconven = 22 then
        vr_cdidenti := to_char(rw_crapatr.cdrefere, 'fm0000000000000000000')||lpad(' ', 6, ' ');
      else
        vr_cdidenti := to_char(rw_crapatr.cdrefere, 'fm0000000000')||lpad(' ', 15, ' ');
      end if;
      --
      vr_cdrefere := to_char(rw_crapatr.cdrefere, 'fm999999999999999G000000000G0');
      vr_tot_qtregist := vr_tot_qtregist + 1;
      --            
      if rw_gnconve.cdconven = 9 then
        vr_dslinreg := 'B'||
                       vr_cdidenti||
                       to_char(vr_nragenci, 'fm0000')||
                       '  '||
                       rpad(vr_cdcooperativa, 4, ' ')||
                       to_char(rw_crapatr.nrdconta, 'fm00000000')||
                       vr_dtautori||
                       lpad(' ', 97, ' ')||
                       to_char(rw_crapatr.inexecuc, 'fm0');
      elsif vr_cdcooperativa <> ' ' then
        vr_dslinreg := 'B'||
                       vr_cdidenti||
                       to_char(vr_nragenci, 'fm0000')||
                       rpad(vr_cdcooperativa, 4, ' ')||
                       to_char(rw_crapatr.nrdconta, 'fm0000000000')||
                       vr_dtautori||
                       lpad(' ', 97, ' ')||
                       to_char(rw_crapatr.inexecuc, 'fm0');
      else
        vr_dslinreg := 'B'||
                       vr_cdidenti||
                       to_char(vr_nragenci, 'fm0000')||
                       to_char(rw_crapatr.nrdconta, 'fm00000000')||
                       rpad(vr_cdcooperativa, 6, ' ')||
                       vr_dtautori||
                       lpad(' ', 97, ' ')||
                       to_char(rw_crapatr.inexecuc, 'fm0');
      end if;
      
      --      
      if rw_gnconve.flgcvuni = 1 then
        vr_concvuni := vr_concvuni + 1;
        begin
          insert into gncvuni (cdcooper,
                               cdconven,
                               dtmvtolt,
                               flgproce,
                               nrseqreg,
                               dsmovtos,
                               tpdcontr)
          values (pr_cdcooper,
                  rw_gnconve.cdconven,
                  rw_crapdat.dtmvtolt,
                  0,
                  vr_concvuni,
                  vr_dslinreg,
                  3); -- Tipo Autoriz. Debito
        exception
          when others then
            pr_dscritic := 'Erro ao criar gncvuni: '||sqlerrm;
            raise vr_exc_saida;
        end;
      end if;
      -- Inclui a linha no arquivo texto
      pc_escreve_txt(vr_dslinreg||chr(10));
      -- Controle de quebra por TIPO
      if vr_inexecuc = 0 then
        -- Primeiro registro
        pc_escreve_xml('<tipo dstipo="'||rw_crapatr.tipo||'">');
        vr_inexecuc := rw_crapatr.inexecuc;
      elsif vr_inexecuc <> rw_crapatr.inexecuc then
        -- Incluir a quebra
        pc_escreve_xml('</tipo><tipo dstipo="'||rw_crapatr.tipo||'">');
        vr_inexecuc := rw_crapatr.inexecuc;
      end if;
      -- Incluir informa��es do associado
      pc_escreve_xml('<conta nrdconta="'||to_char(rw_crapatr.nrdconta, 'fm9999G990G0')||'">'||
                       '<nmfatura>'||rw_crapatr.nmfatura||'</nmfatura>'||
                       '<cdrefere>'||vr_cdrefere||'</cdrefere>'||
                       '<dtiniatr>'||to_char(rw_crapatr.dtiniatr, 'dd/mm/yyyy')||'</dtiniatr>'||
                     '</conta>');
    end loop;
    -- Finalizar o arquivo XML
    if vr_inexecuc <> 0 then
      pc_escreve_xml('</tipo>');
    end if;
        
    pc_escreve_xml('<tot_registros>'||vr_tot_qtregist||'</tot_registros></crrl386>',
                   true);
    -- Finalizar o arquivo TXT
    --adiciona + 2 linhas referentes ao cabe�alho e rodap� do arquivo
    pc_escreve_txt('Z'||lpad(vr_tot_qtregist + 2, 6, '0')||lpad('0', 17, '0')||lpad(' ', 126, ' ')||chr(10),
                   true);
    -- Defini��o do diret�rio onde o relat�rio ser� gerado
    vr_nom_diretorio := gene0001.fn_diretorio('c',  -- /usr/coop
                                              pr_cdcooper,
                                              'rl');
    -- Solicita o relat�rio usando o XML
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> Data do movimento atual
                                pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                pr_dsxmlnode => '/crrl386/tipo/conta',    --> N� base do XML para leitura dos dados
                                pr_dsjasper  => 'crrl343.jasper',    --> Arquivo de layout do iReport
                                pr_dsparams  => null,
                                pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                                pr_flg_gerar => 'N',
                                pr_qtcoluna  => 132,
                                pr_sqcabrel  => 1,
                                pr_flg_impri => 'S',                 --> Chamar a impress�o (Imprim.p)
                                pr_nmformul  => '132dm',             --> Nome do formul�rio para impress�o
                                pr_nrcopias  => vr_nrcopias,                   --> N�mero de c�pias para impress�o
                                pr_des_erro  => vr_dscritic);        --> Sa�da com erro

    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    -- Testar se houve erro
    if vr_dscritic is not null then
      -- Gerar exce��o
      vr_cdcritic := 0;
      raise vr_exc_saida;
    end if;
    -- Defini��o do diret�rio onde o relat�rio ser� gerado
    vr_nom_diretorio := gene0001.fn_diretorio('c',  -- /usr/coop
                                              pr_cdcooper,
                                              'arq');
    -- Define se ir� copiar ou mover para o diret�rio salvar
    if rw_gnconve.flgcvuni <> 1 then
      if rw_gnconve.tpdenvio = 5 then -- Accesstage
        vr_flgremarq := 'N';
      else
        vr_flgremarq := 'S';
      end if;
    else
      vr_flgremarq := 'S';
    end if;
    -- Gera o arquivo TXT e move para o diret�rio "salvar"
    gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => pr_cdcooper,         --> Cooperativa conectada
                                        pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                        pr_dtmvtolt  => rw_crapdat.dtmvtolt,         --> Data do movimento atual
                                        pr_dsxml     => vr_des_txt,          --> Arquivo de dados (CLOB)
                                        pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nmarqped, --> Arquivo final
                                        pr_flg_impri => 'N',                 --> Chamar a impress�o (Imprim.p)
                                        pr_flg_gerar => 'S',                 --> Gerar o arquivo na hora
                                        pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                              pr_cdcooper => pr_cdcooper,
                                                                              pr_nmsubdir => '/salvar'),    --> Diret�rios a copiar o relat�rio
                                        pr_flgremarq => vr_flgremarq,                 --> Flag para remover o arquivo ap�s c�pia/email
                                        pr_des_erro  => vr_dscritic);        --> Sa�da com erro
    -- Liberando a mem�ria alocada pro CLOB
    dbms_lob.close(vr_des_txt);
    dbms_lob.freetemporary(vr_des_txt);
    -- Procedure atualiza_controle do progress
    if rw_gnconve.flgcvuni <> 1 then  -- Somente se nao for unificado
      vr_cdcritic := 657; -- Intranet - tpdenvio = 1
      
      if rw_gnconve.tpdenvio = 2 then -- E-Sales
        vr_cdcritic := 696;
        
        -- ux2dos, ira mandar o arquivo para o converte da cooperativa
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper                  --> Cooperativa
                                    ,pr_nmarquiv => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                                   pr_cdcooper => pr_cdcooper,
                                                                                   pr_nmsubdir => '/salvar')||
                                                                                   '/'||vr_nmarqped --> Caminho e nome do arquivo a ser convertido
                                    ,pr_nmarqenv => vr_nmarqped                  --> Nome desejado para o arquivo convertido
                                    ,pr_des_erro => vr_dscritic);                --> Retorno da critica

        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        -- Buscar o arquivo convertido e copiar para o diretorio da esales
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                                   pr_cdcooper => pr_cdcooper,
                                                                                   pr_nmsubdir => '/converte')||
                                                      '/'||vr_nmarqped||' /usr/connect/esales/envia/',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        -- testa erro na c�pia
        if vr_typ_said = 'ERR' then
          vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqped||' (1): '||vr_dscritic;
          raise vr_exc_saida;
        end if;
      end if;
      
      if rw_gnconve.tpdenvio = 3 then -- Nexxera
        vr_cdcritic := 748;
        --
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                                   pr_cdcooper => pr_cdcooper,
                                                                                   pr_nmsubdir => '/salvar')||
                                                      '/'||vr_nmarqped||' /usr/nexxera/envia/',
                                    pr_typ_saida   => vr_typ_said,
                                    pr_des_saida   => vr_dscritic);
        -- testa erro na c�pia
        if vr_typ_said = 'ERR' then
          vr_dscritic := 'Erro ao copiar o arquivo '||vr_nmarqped||' (1): '||vr_dscritic;
          raise vr_exc_saida;
        end if;
      end if;

      --
      if rw_gnconve.tpdenvio = 5 then --Accestage
        vr_cdcritic := 905; 
      end if;
      --

      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra );
      --
      if rw_gnconve.tpdenvio <> 1 then -- Internet
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic || ' '
                                                 || vr_nmarqdat || ' - Debito Automatico - '
                                                 || rw_gnconve.nmempres || ': _________');
      else
        -- Carregar a lista de destinat�rios na pl/table
        vr_destinatarios := gene0002.fn_quebra_string(pr_string => rw_gnconve.dsenddeb); 
        vr_indice := vr_destinatarios.first;
        
        -- Converte o arquivo (ux2dos) antes de enviar por email
        GENE0003.pc_converte_arquivo(pr_cdcooper => pr_cdcooper
                                    ,pr_nmarquiv => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                              pr_cdcooper => pr_cdcooper,
                                                                              pr_nmsubdir => '/salvar')||'/'||vr_nmarqped
                                    ,pr_nmarqenv => vr_nmarqdat
                                    ,pr_des_erro => vr_dscritic);

        --arquivo que sera anexado ao email
        vr_nom_diretorio := gene0001.fn_diretorio('C',  -- /usr/coop
                                              pr_cdcooper,
                                              '/converte');

        vr_nmarqdat := vr_nom_diretorio||'/'||vr_nmarqdat;                  
                                     
        while vr_indice is not null loop
          if trim(vr_destinatarios(vr_indice)) is not null then
            gene0003.pc_solicita_email(pr_cdprogra => vr_cdprogra,
                                       pr_des_destino => vr_destinatarios(vr_indice),
                                       pr_des_assunto => 'ARQUIVO DE DEBITO DA '||rw_gnconve.nmempres,
                                       pr_des_corpo => null,
                                       pr_des_anexo => vr_nmarqdat,
                                       pr_flg_remove_anex => 'N',
                                       pr_des_erro => vr_dscritic);
            if vr_dscritic is not null then
              raise vr_exc_saida;
            end if;
          end if;
          vr_indice := vr_destinatarios.next(vr_indice);
        end loop;
      end if;
    else -- gnconve.flgcvuni = 1
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, -- Erro tratato
                                 pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra 
                                                 || ' --> Geracao de arquivo para unificacao - '
                                                 || vr_nmarqdat );
    end if;
    --
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra );
    -- Atualizar Arquivo de Controle
    begin
      update gncontr
         set gncontr.dtcredit = rw_crapdat.dtmvtolt,
             gncontr.nmarquiv = vr_nmarqped,
             gncontr.qtdoctos = vr_tot_qtregist
       where gncontr.rowid = rw_gncontr.row_id;
    exception
      when others then
        vr_dscritic := 'Erro ao atualizar arquivo de controle: '||sqlerrm;
        raise vr_exc_saida;
    end;
  end loop;
  -- Finaliza a execu��o com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);
  --
  commit;
exception
  when vr_exc_fimprg then
    -- Se foi retornado apenas c�digo
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descri��o
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
    -- Efetuar commit pois gravaremos o que foi processo at� ent�o
    commit;
  when vr_exc_saida then
    -- Se foi retornado apenas c�digo
    if vr_cdcritic > 0 and vr_dscritic is null then
      -- Buscar a descri��o
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    end if;
    -- Devolvemos c�digo e critica encontradas
    pr_cdcritic := nvl(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    rollback;
  when others then
    -- Efetuar retorno do erro n�o tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    rollback;
end;
/
