CREATE OR REPLACE PACKAGE CECRED.TELA_CADPAC IS

  PROCEDURE pc_busca_pac(pr_cddopcao     IN VARCHAR2 --> Opcao
                        ,pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_pac(pr_cddopcao     IN VARCHAR2 --> Opcao
                        ,pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        ,pr_nmextage     IN crapage.nmextage%TYPE --> Nome da agencia
                        ,pr_nmresage     IN crapage.nmresage%TYPE --> Nome resumido da agencia
                        ,pr_insitage     IN crapage.insitage%TYPE --> Situacao (0-Implantacao,1-Ativo,2-Inativo,3-Temporariamente Indisponivel)
                        ,pr_cdcxaage     IN crapage.cdcxaage%TYPE --> Numero do caixa do posto
                        ,pr_tpagenci     IN crapage.tpagenci%TYPE --> Tipo de agencia: 0-Convencional, 1-Pioneira (IN-PIONEIRA)
                        ,pr_cdccuage     IN crapage.cdccuage%TYPE --> Numero do centro de custo do posto
                        ,pr_cdorgpag     IN crapage.cdorgpag%TYPE --> Codigo identificador do orgao pagador junto ao INSS
                        ,pr_cdagecbn     IN crapage.cdagecbn%TYPE --> Codigo da agencia de relacionamento COBAN
                        ,pr_cdcomchq     IN crapage.cdcomchq%TYPE --> Codigo de compensacao de cheque
                        ,pr_vercoban     IN crapage.vercoban%TYPE --> Consultar as pendencias do COBAN no fechamento do caixa
                        ,pr_cdbantit     IN crapage.cdbantit%TYPE --> Codigo do Banco do Titulo onde sera entregue a COMPE
                        ,pr_cdagetit     IN crapage.cdagetit%TYPE --> Codigo da agencia dos titulos onde sera entregue a COMPE
                        ,pr_cdbanchq     IN crapage.cdbanchq%TYPE --> Codigo do Banco do Cheque onde sera entregue a COMPE
                        ,pr_cdagechq     IN crapage.cdagechq%TYPE --> Codigo da agencia do cheque onde sera entregue a COMPE
                        ,pr_cdbandoc     IN crapage.cdbandoc%TYPE --> Codigo do Banco do DOC onde sera entregue a COMPE
                        ,pr_cdagedoc     IN crapage.cdagedoc%TYPE --> Codigo da agencia do DOC onde sera entregue a COMPE
                        ,pr_flgdsede     IN crapage.flgdsede%TYPE --> PA eh Sede da cooperativa
                        ,pr_cdagepac     IN crapage.cdagepac%TYPE --> Numero da agencia do PA na Central
												,pr_flgutcrm     IN crapage.flgutcrm%TYPE --> Flag de controle de acesso ao CRM
                        ,pr_dsendcop     IN crapage.dsendcop%TYPE --> Endereco do PA
                        ,pr_nrendere     IN crapage.nrendere%TYPE --> Numero (ref. endereco) do PA
                        ,pr_nmbairro     IN crapage.nmbairro%TYPE --> Nome do bairro onde esta localizado o PA
                        ,pr_dscomple     IN crapage.dscomple%TYPE --> Complemento do endereco do PA
                        ,pr_nrcepend     IN crapage.nrcepend%TYPE --> Codigo de enderecamento postal do endereco do PA
                        ,pr_idcidade     IN crapage.idcidade%TYPE --> Código identificador da cidade (crapmun)
                        ,pr_nmcidade     IN crapage.nmcidade%TYPE --> Nome da cidade onde esta localizado o PA
                        ,pr_cdufdcop     IN crapage.cdufdcop%TYPE --> Sigla do estado onde esta localizado o PA
                        ,pr_dsdemail     IN crapage.dsdemail%TYPE --> E-mail do PA
                        ,pr_dsmailbd     IN crapage.dsmailbd%TYPE --> E-mail envio borderos cadastrados via Internet Banking
                        ,pr_dsinform1    IN crapage.dsinform##1%TYPE --> Descricao do endereco do PA a ser impresso no cheque
                        ,pr_dsinform2    IN crapage.dsinform##2%TYPE --> Descricao do endereco do PA a ser impresso no cheque
                        ,pr_dsinform3    IN crapage.dsinform##3%TYPE --> Descricao do endereco do PA a ser impresso no cheque
                        ,pr_hhsicini     IN VARCHAR2 --> Horario inicial SICREDI
                        ,pr_hhsicfim     IN VARCHAR2 --> Horario final SICREDI
                        ,pr_hhtitini     IN VARCHAR2 --> Horario inicial Titulos/Faturas
                        ,pr_hhtitfim     IN VARCHAR2 --> Horario final Titulos/Faturas
                        ,pr_hhcompel     IN VARCHAR2 --> Horario Cheques
                        ,pr_hhcapini     IN VARCHAR2 --> Horario inicial Capital/Captacao
                        ,pr_hhcapfim     IN VARCHAR2 --> Horario final Capital/Captacao
                        ,pr_hhdoctos     IN VARCHAR2 --> Horario Doctos
                        ,pr_hhtrfini     IN VARCHAR2 --> Horario inicial Transferencia
                        ,pr_hhtrffim     IN VARCHAR2 --> Horario final Transferencia
                        ,pr_hhguigps     IN VARCHAR2 --> Horario Guias GPS
                        ,pr_hhbolini     IN VARCHAR2 --> Horario inicial Geracao/Instrucoes Cob. Registrada
                        ,pr_hhbolfim     IN VARCHAR2 --> Horario final Geracao/Instrucoes Cob. Registrada
                        ,pr_hhenvelo     IN VARCHAR2 --> Horario Deposito TAA
                        ,pr_hhcpaini     IN VARCHAR2 --> Horario inicial Credito Pre-Aprovado
                        ,pr_hhcpafim     IN VARCHAR2 --> Horario final Credito Pre-Aprovado
                        ,pr_hhlimcan     IN VARCHAR2 --> Horario Cancelamento de pagamentos
                        ,pr_hhsiccan     IN VARCHAR2 --> Horario Cancelamento pagamento SICREDI
                        ,pr_nrtelvoz     IN crapage.nrtelvoz%TYPE --> Telefone de voz do PA
                        ,pr_nrtelfax     IN crapage.nrtelfax%TYPE --> Telefone para FAX do PA
                        ,pr_qtddaglf     IN crapage.qtddaglf%TYPE --> Quantidade de dias limite para agendamentos
                        ,pr_qtmesage     IN crapage.qtmesage%TYPE --> Qtd. meses agendados
                        ,pr_qtddlslf     IN crapage.qtddlslf%TYPE --> Quantidade de dias para listar lancamentos futuros
                        ,pr_flsgproc     IN VARCHAR2 --> Flag Processo Manual
                        ,pr_vllimapv     IN crapage.vllimapv%TYPE --> Limite de Aprovacao para o Comite Local
                        ,pr_qtchqprv     IN crapage.qtchqprv%TYPE --> Quantidade maxima de cheques por previa e por caixa
                        ,pr_flgdopgd     IN crapage.flgdopgd%TYPE --> Indica se o pac esta ativo para participar do progrid
                        ,pr_cdageagr     IN crapage.cdageagr%TYPE --> Indica o pac agrupador
                        ,pr_cddregio     IN crapage.cddregio%TYPE --> Codigo da Regional
                        ,pr_tpageins     IN crapage.tpageins%TYPE --> Contem o tipo de agencia (0-Convencional, 1-Pioneira)
                        ,pr_cdorgins     IN crapage.cdorgins%TYPE --> Codigo identificador do orgao pagador junto ao INSS-SICREDI
                        ,pr_vlminsgr     IN crapage.vlminsgr%TYPE --> Contem o valor minimo para efetuar a sangria de caixa
                        ,pr_vlmaxsgr     IN crapage.vlmaxsgr%TYPE --> Contem o valor maximo para efetuar a sangria de caixa
                        ,pr_flmajora     IN crapage.flmajora%TYPE --> Contem o identificador de Majoracao habilitada
                        ,pr_cdagefgt     IN crapage.cdagefgt%TYPE --> Agencia do CAF/FGTS
                        ,pr_hhini_bancoob IN VARCHAR2             --> Horario inicial de pagamento bancoob
                        ,pr_hhfim_bancoob IN VARCHAR2             --> Horario final de pagamento bancoob 
                        ,pr_hhcan_bancoob IN VARCHAR2             --> Horario limite cancelamento de pagamento bancoob                         
                        ,pr_vllimpag      IN crapage.vllimpag%TYPE --> Valor limite máximo pagamento sem autorização
                        ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_valor_comite(pr_cddopcao     IN VARCHAR2 --> Opcao
                                 ,pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        	       ,pr_vllimapv     IN crapage.vllimapv%TYPE --> Limite de Aprovacao para o Comite Local
                                 ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_valida_caixa(pr_cdagenci     IN crapbcx.cdagenci%TYPE --> Codigo da agencia
                        	 ,pr_nrdcaixa     IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                           ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_caixa(pr_cdagenci     IN crapbcx.cdagenci%TYPE --> Codigo da agencia
                        	,pr_nrdcaixa     IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                          ,pr_cdopercx     IN crapbcx.cdopecxa%TYPE --> Codigo do operador
                          ,pr_dtdcaixa     IN VARCHAR2 --> Data do caixa
                          ,pr_rowidcxa     IN ROWID
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_grava_dados_site(pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        	     ,pr_nmpasite     IN crapage.nmpasite%TYPE --> Nome do PA para apresentacao no site da cooperativa
                               ,pr_dstelsit     IN crapage.dstelsit%TYPE --> Telefone do PA para apresentacao no site da cooperativa
                               ,pr_dsemasit     IN crapage.dsemasit%TYPE --> E-mail do PA para apresentacao no site da cooperativa
 															 ,pr_hrinipaa     IN VARCHAR2              --> Hora Inicial atendimento
															 ,pr_hrfimpaa     IN VARCHAR2              --> Hora Final atendimento
															 ,pr_indspcxa     IN crapage.indspcxa%TYPE --> Possui Caixa
                               ,pr_nrlatitu     IN crapage.nrlatitu%TYPE --> Latitude da localizacao
                               ,pr_nrlongit     IN crapage.nrlongit%TYPE --> Longitude da localizacao
                               ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro    OUT VARCHAR2); --> Erros do processo

  PROCEDURE pc_lista_pas(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                        ,pr_flgpaaut  IN INTEGER DEFAULT 1     --> Flag que indica se PAs de Auto-Atendimento deverão ser listados
                        ,pr_retxml   OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                        ,pr_des_erro OUT VARCHAR2);            --> Erros do processo                                                              

END TELA_CADPAC;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_CADPAC IS
  ---------------------------------------------------------------------------
  --
  --  Programa : TELA_CADPAC
  --  Sistema  : Ayllos Web
  --  Autor    : Jaison Fernando
  --  Data     : Julho - 2016                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Objetivo  : Centralizar rotinas relacionadas a tela CADPAC
  --
  -- Alteracoes: 08/08/2017 - Inclusao de flag de majoracao, melhoria 438
  --                          Heitor (Mouts)
  --
  --             20/12/2017 - Ajustes para inclusao dos campos do FGTS/Bancoob.
  --                          PRJ406-FGTS(Odirlei-AMcom)
  --             03/01/2018 - M307 Solicitação de senha e limite para pagamento (Diogo / MoutS)
  ---------------------------------------------------------------------------
  
  -- Definicao do tipo de registro
  TYPE typ_reg_crapage IS
  RECORD (nmextage crapage.nmextage%TYPE
         ,nmresage crapage.nmresage%TYPE
         ,insitage crapage.insitage%TYPE
         ,cdcxaage crapage.cdcxaage%TYPE
         ,tpagenci crapage.tpagenci%TYPE
         ,cdccuage crapage.cdccuage%TYPE
         ,cdorgpag crapage.cdorgpag%TYPE
         ,cdagecbn crapage.cdagecbn%TYPE
         ,cdcomchq crapage.cdcomchq%TYPE
         ,vercoban crapage.vercoban%TYPE
         ,cdbantit crapage.cdbantit%TYPE
         ,cdagetit crapage.cdagetit%TYPE
         ,cdbanchq crapage.cdbanchq%TYPE
         ,cdagechq crapage.cdagechq%TYPE
         ,cdbandoc crapage.cdbandoc%TYPE
         ,cdagedoc crapage.cdagedoc%TYPE
         ,flgdsede crapage.flgdsede%TYPE
         ,cdagepac crapage.cdagepac%TYPE
				 ,flgutcrm crapage.flgutcrm%TYPE
         ,cdagefgt crapage.cdagefgt%TYPE
         ,dsendcop crapage.dsendcop%TYPE
         ,nrendere crapage.nrendere%TYPE
         ,nmbairro crapage.nmbairro%TYPE
         ,dscomple crapage.dscomple%TYPE
         ,nrcepend crapage.nrcepend%TYPE
         ,idcidade crapage.idcidade%TYPE
         ,nmcidade crapage.nmcidade%TYPE
         ,cdufdcop crapage.cdufdcop%TYPE
         ,dsdemail crapage.dsdemail%TYPE
         ,dsmailbd crapage.dsmailbd%TYPE
         ,dsinform1 crapage.dsinform##1%TYPE
         ,dsinform2 crapage.dsinform##2%TYPE
         ,dsinform3 crapage.dsinform##3%TYPE
         ,hhsicini VARCHAR2(5)
         ,hhsicfim VARCHAR2(5)
         ,hhini_bancoob VARCHAR2(5)
         ,hhfim_bancoob VARCHAR2(5)
         ,hhtitini VARCHAR2(5)
         ,hhtitfim VARCHAR2(5)
         ,hhcompel VARCHAR2(5)
         ,hhcapini VARCHAR2(5)
         ,hhcapfim VARCHAR2(5)
         ,hhdoctos VARCHAR2(5)
         ,hhtrfini VARCHAR2(5)
         ,hhtrffim VARCHAR2(5)
         ,hhguigps VARCHAR2(5)
         ,hhbolini VARCHAR2(5)
         ,hhbolfim VARCHAR2(5)
         ,hhenvelo VARCHAR2(5)
         ,hhcpaini VARCHAR2(5)
         ,hhcpafim VARCHAR2(5)
         ,hhlimcan VARCHAR2(5)
         ,hhsiccan VARCHAR2(5)
         ,hhcan_bancoob VARCHAR2(5)
         ,nrtelvoz crapage.nrtelvoz%TYPE
         ,nrtelfax crapage.nrtelfax%TYPE
         ,qtddaglf crapage.qtddaglf%TYPE
         ,qtmesage crapage.qtmesage%TYPE
         ,qtddlslf crapage.qtddlslf%TYPE
         ,flsgproc VARCHAR2(3)
         ,vllimapv crapage.vllimapv%TYPE
         ,qtchqprv crapage.qtchqprv%TYPE
         ,flgdopgd crapage.flgdopgd%TYPE
         ,cdageagr crapage.cdageagr%TYPE
         ,cddregio crapage.cddregio%TYPE
         ,dsdregio crapreg.dsdregio%TYPE
         ,tpageins crapage.tpageins%TYPE
         ,cdorgins crapage.cdorgins%TYPE
         ,vlminsgr crapage.vlminsgr%TYPE
         ,vlmaxsgr crapage.vlmaxsgr%TYPE
         ,nmpasite crapage.nmpasite%TYPE
         ,dstelsit crapage.dstelsit%TYPE
         ,dsemasit crapage.dsemasit%TYPE
				 ,dssitpaa VARCHAR2(10)
				 ,hrinipaa VARCHAR2(5)
				 ,hrfimpaa VARCHAR2(5)
				 ,indspcxa crapage.indspcxa%TYPE
				 ,indsptaa VARCHAR2(1)
         ,nrlatitu crapage.nrlatitu%TYPE
         ,nrlongit crapage.nrlongit%TYPE
         ,flmajora crapage.flmajora%TYPE
         ,vllimpag crapage.vllimpag%TYPE);

  -- Definicao do tipo de tabela registro
  TYPE typ_tab_crapage IS TABLE OF typ_reg_crapage INDEX BY PLS_INTEGER;

  -- Vetor para armazenar os dados da tabela
  vr_tab_crapage typ_tab_crapage;
			
  -- Seleciona operador
  CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE
                   ,pr_cdoperad crapope.cdoperad%TYPE) IS
    SELECT crapope.cddepart
      FROM crapope
     WHERE crapope.cdcooper = pr_cdcooper
       AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
  rw_crapope cr_crapope%ROWTYPE;

  -- Selecionar a cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
          ,crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  PROCEDURE pc_carrega_dados(pr_cdcooper     IN crapage.cdcooper%TYPE --> Codigo da cooperativa
                            ,pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                            ,pr_tab_crapage OUT typ_tab_crapage --> PLTABLE com os dados
                            ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                            ,pr_dscritic    OUT VARCHAR2) IS --> Descricao da critica
  BEGIN

    /* .............................................................................

    Programa: pc_carrega_dados
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados do PA.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT crapage.nmextage
              ,crapage.nmresage
              ,crapage.insitage
              ,crapage.cdcxaage
              ,crapage.tpagenci
              ,crapage.cdccuage
              ,crapage.cdorgpag
              ,crapage.cdagecbn
              ,crapage.cdcomchq
              ,crapage.vercoban
              ,crapage.cdbantit
              ,crapage.cdagetit
              ,crapage.cdbanchq
              ,crapage.cdagechq
              ,crapage.cdbandoc
              ,crapage.cdagedoc
              ,crapage.flgdsede
              ,crapage.cdagepac
							,crapage.flgutcrm
              ,crapage.cdagefgt
              ,crapage.dsendcop
              ,crapage.nrendere
              ,crapage.nmbairro
              ,crapage.dscomple
              ,crapage.nrcepend
              ,crapage.idcidade
              ,crapage.nmcidade
              ,crapage.cdufdcop
              ,crapage.dsdemail
              ,crapage.dsmailbd
              ,crapage.dsinform##1 dsinform1
              ,crapage.dsinform##2 dsinform2
              ,crapage.dsinform##3 dsinform3
              ,crapage.hrcancel
              ,crapage.nrtelvoz
              ,crapage.nrtelfax
              ,crapage.qtddaglf
              ,crapage.qtmesage
              ,crapage.qtddlslf
              ,crapage.vllimapv
              ,crapage.qtchqprv
              ,crapage.flgdopgd
              ,crapage.cdageagr
              ,crapage.cddregio
              ,crapage.tpageins
              ,crapage.cdorgins
              ,crapage.vlminsgr
              ,crapage.vlmaxsgr
              ,crapage.nmpasite
              ,crapage.dstelsit
              ,crapage.dsemasit
							,crapage.hrinipaa
							,crapage.hrfimpaa
							,crapage.indspcxa
							,DECODE((SELECT COUNT(*) FROM craptfn
							                         JOIN tbsite_taa taa
																			   ON taa.cdcooper = craptfn.cdcooper
																			  AND taa.nrterfin = craptfn.nrterfin
																			  AND taa.flganexo_pa = 1  -- PA possui TAA anexo
			                                WHERE craptfn.cdcooper = crapage.cdcooper
			                                  AND craptfn.cdagenci = crapage.cdagenci
															          /*	 Não considerar se TAA estão ativos ou não																				
																				AND craptfn.flsistaa = 1 -- TAA está ativo */
																				), 0, '0', '1')
																				 AS indsptaa
              ,crapage.nrlatitu
              ,crapage.nrlongit
              ,crapage.flmajora
              ,crapage.vllimpag
          FROM crapage
         WHERE crapage.cdcooper = pr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
      rw_crapage cr_crapage%ROWTYPE;

      -- Selecionar a regional
      CURSOR cr_crapreg(pr_cdcooper IN crapreg.cdcooper%TYPE
                       ,pr_cddregio IN crapreg.cddregio%TYPE) IS
        SELECT crapreg.dsdregio
          FROM crapreg
         WHERE crapreg.cdcooper = pr_cdcooper
           AND crapreg.cddregio = pr_cddregio;
      
      -- Variaveis Gerais
      vr_blnfound BOOLEAN;
      vr_dstextab craptab.dstextab%TYPE;
      vr_hhsicini VARCHAR2(5); -- HH:MM
      vr_hhsicfim VARCHAR2(5); -- HH:MM
      vr_hhini_bancoob VARCHAR2(5); -- HH:MM
      vr_hhfim_bancoob VARCHAR2(5); -- HH:MM      
      vr_hhtitini VARCHAR2(5); -- HH:MM
      vr_hhtitfim VARCHAR2(5); -- HH:MM
      vr_hhcompel VARCHAR2(5); -- HH:MM
      vr_hhcapini VARCHAR2(5); -- HH:MM
      vr_hhcapfim VARCHAR2(5); -- HH:MM
      vr_hhdoctos VARCHAR2(5); -- HH:MM
      vr_hhtrfini VARCHAR2(5); -- HH:MM
      vr_hhtrffim VARCHAR2(5); -- HH:MM
      vr_hhguigps VARCHAR2(5); -- HH:MM
      vr_hhbolini VARCHAR2(5); -- HH:MM
      vr_hhbolfim VARCHAR2(5); -- HH:MM
      vr_hhenvelo VARCHAR2(5); -- HH:MM
      vr_hhcpaini VARCHAR2(5); -- HH:MM
      vr_hhcpafim VARCHAR2(5); -- HH:MM
      vr_hhsiccan VARCHAR2(5); -- HH:MM
      vr_hhcan_bancoob VARCHAR2(5); -- HH:MM
      vr_flsgproc VARCHAR2(3);
      vr_dsdregio crapreg.dsdregio%TYPE;
			vr_dssitpaa VARCHAR2(10);

    BEGIN
      -- Limpa PLTABLE
      pr_tab_crapage.DELETE;

      -- Selecionar os dados
      OPEN cr_crapage(pr_cdcooper => pr_cdcooper
                     ,pr_cdagenci => pr_cdagenci);
      FETCH cr_crapage INTO rw_crapage;
      -- Alimenta a booleana
      vr_blnfound := cr_crapage%FOUND;
      -- Fechar o cursor
      CLOSE cr_crapage;

      -- Se encontrou
      IF vr_blnfound THEN

        -- Selecionar a regional
        OPEN cr_crapreg(pr_cdcooper => pr_cdcooper
                       ,pr_cddregio => rw_crapage.cddregio);
        FETCH cr_crapreg INTO vr_dsdregio;
        CLOSE cr_crapreg;

        -- Pagamentos Faturas Sicredi
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRPGSICRED'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhsicini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(1,vr_dstextab,' '));
        vr_hhsicfim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(2,vr_dstextab,' '));
        vr_hhsiccan := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(3,vr_dstextab,' '));

        -- Pagamentos Faturas Bancoob
        vr_dstextab := NULL;
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRPGBANCOOB'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhini_bancoob := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(1,vr_dstextab,' '));
        vr_hhfim_bancoob := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(2,vr_dstextab,' '));
        vr_hhcan_bancoob := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(3,vr_dstextab,' '));


        -- Pagamentos Titulos/Faturas
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRTITULO'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhtitini := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,9,5));
        vr_hhtitfim := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));
        vr_flsgproc := SUBSTR(vr_dstextab,15,3);

        -- Cheques
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRCOMPEL'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhcompel := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));

        -- Plano Capital/Captacao
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRPLANCAPI'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhcapini := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,9,5));
        vr_hhcapfim := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));

        -- Doctos
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRDOCTOS'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhdoctos := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));

        -- Transferencia
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRANSFER'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhtrfini := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,9,5));
        vr_hhtrffim := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));

        -- Guias GPS
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRGUIASGPS'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhguigps := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,3,5));

        -- Geracao/Instrucoes Cob. Registrada
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRCOBRANCA'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhbolini := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,7,5));
        vr_hhbolfim := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,1,5));

        -- Deposito TAA
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRTRENVELO'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhenvelo := GENE0002.fn_converte_time_data(SUBSTR(vr_dstextab,1,5));

        -- Contratacao de Credito Pre-Aprovado
        vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsistem => 'CRED'
                                                 ,pr_tptabela => 'GENERI'
                                                 ,pr_cdempres => 0
                                                 ,pr_cdacesso => 'HRCTRPREAPROV'
                                                 ,pr_tpregist => pr_cdagenci);

        vr_hhcpaini := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(1,vr_dstextab,' '));
        vr_hhcpafim := GENE0002.fn_converte_time_data(GENE0002.fn_busca_entrada(2,vr_dstextab,' '));

				IF rw_crapage.insitage = 1 THEN -- Ativo
					IF GENE0002.fn_busca_time BETWEEN rw_crapage.hrinipaa AND rw_crapage.hrfimpaa THEN
						vr_dssitpaa := 'ABERTO';
					ELSE 
						vr_dssitpaa := 'FECHADO';
					END IF;
				ELSE
					vr_dssitpaa := 'FECHADO';
				END IF;

        -- Carrega os dados na PLTRABLE
        pr_tab_crapage(pr_cdagenci).nmextage := rw_crapage.nmextage;
        pr_tab_crapage(pr_cdagenci).nmresage := rw_crapage.nmresage;
        pr_tab_crapage(pr_cdagenci).insitage := rw_crapage.insitage;
        pr_tab_crapage(pr_cdagenci).cdcxaage := rw_crapage.cdcxaage;
        pr_tab_crapage(pr_cdagenci).tpagenci := rw_crapage.tpagenci;
        pr_tab_crapage(pr_cdagenci).cdccuage := rw_crapage.cdccuage;
        pr_tab_crapage(pr_cdagenci).cdorgpag := rw_crapage.cdorgpag;
        pr_tab_crapage(pr_cdagenci).cdagecbn := rw_crapage.cdagecbn;
        pr_tab_crapage(pr_cdagenci).cdcomchq := rw_crapage.cdcomchq;
        pr_tab_crapage(pr_cdagenci).vercoban := rw_crapage.vercoban;
        pr_tab_crapage(pr_cdagenci).cdbantit := rw_crapage.cdbantit;
        pr_tab_crapage(pr_cdagenci).cdagetit := rw_crapage.cdagetit;
        pr_tab_crapage(pr_cdagenci).cdbanchq := rw_crapage.cdbanchq;
        pr_tab_crapage(pr_cdagenci).cdagechq := rw_crapage.cdagechq;
        pr_tab_crapage(pr_cdagenci).cdbandoc := rw_crapage.cdbandoc;
        pr_tab_crapage(pr_cdagenci).cdagedoc := rw_crapage.cdagedoc;
        pr_tab_crapage(pr_cdagenci).flgdsede := rw_crapage.flgdsede;
        pr_tab_crapage(pr_cdagenci).cdagepac := rw_crapage.cdagepac;
        pr_tab_crapage(pr_cdagenci).flgutcrm := rw_crapage.flgutcrm;				
        pr_tab_crapage(pr_cdagenci).cdagefgt := rw_crapage.cdagefgt;
        pr_tab_crapage(pr_cdagenci).dsendcop := rw_crapage.dsendcop;
        pr_tab_crapage(pr_cdagenci).nrendere := rw_crapage.nrendere;
        pr_tab_crapage(pr_cdagenci).nmbairro := rw_crapage.nmbairro;
        pr_tab_crapage(pr_cdagenci).dscomple := rw_crapage.dscomple;
        pr_tab_crapage(pr_cdagenci).nrcepend := rw_crapage.nrcepend;
        pr_tab_crapage(pr_cdagenci).idcidade := rw_crapage.idcidade;
        pr_tab_crapage(pr_cdagenci).nmcidade := rw_crapage.nmcidade;
        pr_tab_crapage(pr_cdagenci).cdufdcop := rw_crapage.cdufdcop;
        pr_tab_crapage(pr_cdagenci).dsdemail := rw_crapage.dsdemail;
        pr_tab_crapage(pr_cdagenci).dsmailbd := rw_crapage.dsmailbd;
        pr_tab_crapage(pr_cdagenci).dsinform1 := rw_crapage.dsinform1;
        pr_tab_crapage(pr_cdagenci).dsinform2 := rw_crapage.dsinform2;
        pr_tab_crapage(pr_cdagenci).dsinform3 := rw_crapage.dsinform3;
        pr_tab_crapage(pr_cdagenci).hhsicini := vr_hhsicini;
        pr_tab_crapage(pr_cdagenci).hhsicfim := vr_hhsicfim;
        pr_tab_crapage(pr_cdagenci).hhini_bancoob := vr_hhini_bancoob;
        pr_tab_crapage(pr_cdagenci).hhfim_bancoob := vr_hhfim_bancoob;        
        pr_tab_crapage(pr_cdagenci).hhtitini := vr_hhtitini;
        pr_tab_crapage(pr_cdagenci).hhtitfim := vr_hhtitfim;
        pr_tab_crapage(pr_cdagenci).hhcompel := vr_hhcompel;
        pr_tab_crapage(pr_cdagenci).hhcapini := vr_hhcapini;
        pr_tab_crapage(pr_cdagenci).hhcapfim := vr_hhcapfim;
        pr_tab_crapage(pr_cdagenci).hhdoctos := vr_hhdoctos;
        pr_tab_crapage(pr_cdagenci).hhtrfini := vr_hhtrfini;
        pr_tab_crapage(pr_cdagenci).hhtrffim := vr_hhtrffim;
        pr_tab_crapage(pr_cdagenci).hhguigps := vr_hhguigps;
        pr_tab_crapage(pr_cdagenci).hhbolini := vr_hhbolini;
        pr_tab_crapage(pr_cdagenci).hhbolfim := vr_hhbolfim;
        pr_tab_crapage(pr_cdagenci).hhenvelo := vr_hhenvelo;
        pr_tab_crapage(pr_cdagenci).hhcpaini := vr_hhcpaini;
        pr_tab_crapage(pr_cdagenci).hhcpafim := vr_hhcpafim;
        pr_tab_crapage(pr_cdagenci).hhlimcan := GENE0002.fn_converte_time_data(rw_crapage.hrcancel);
        pr_tab_crapage(pr_cdagenci).hhsiccan := vr_hhsiccan;
        pr_tab_crapage(pr_cdagenci).hhcan_bancoob := vr_hhcan_bancoob;
        pr_tab_crapage(pr_cdagenci).nrtelvoz := rw_crapage.nrtelvoz;
        pr_tab_crapage(pr_cdagenci).nrtelfax := rw_crapage.nrtelfax;
        pr_tab_crapage(pr_cdagenci).qtddaglf := rw_crapage.qtddaglf;
        pr_tab_crapage(pr_cdagenci).qtmesage := rw_crapage.qtmesage;
        pr_tab_crapage(pr_cdagenci).qtddlslf := rw_crapage.qtddlslf;
        pr_tab_crapage(pr_cdagenci).flsgproc := vr_flsgproc;
        pr_tab_crapage(pr_cdagenci).vllimapv := rw_crapage.vllimapv;
        pr_tab_crapage(pr_cdagenci).qtchqprv := rw_crapage.qtchqprv;
        pr_tab_crapage(pr_cdagenci).flgdopgd := rw_crapage.flgdopgd;
        pr_tab_crapage(pr_cdagenci).cdageagr := rw_crapage.cdageagr;
        pr_tab_crapage(pr_cdagenci).cddregio := rw_crapage.cddregio;
        pr_tab_crapage(pr_cdagenci).dsdregio := vr_dsdregio;
        pr_tab_crapage(pr_cdagenci).tpageins := rw_crapage.tpageins;
        pr_tab_crapage(pr_cdagenci).cdorgins := rw_crapage.cdorgins;
        pr_tab_crapage(pr_cdagenci).vlminsgr := rw_crapage.vlminsgr;
        pr_tab_crapage(pr_cdagenci).vlmaxsgr := rw_crapage.vlmaxsgr;
        pr_tab_crapage(pr_cdagenci).nmpasite := rw_crapage.nmpasite;
        pr_tab_crapage(pr_cdagenci).dstelsit := rw_crapage.dstelsit;
        pr_tab_crapage(pr_cdagenci).dsemasit := rw_crapage.dsemasit;
				pr_tab_crapage(pr_cdagenci).dssitpaa := vr_dssitpaa;
				pr_tab_crapage(pr_cdagenci).hrinipaa := GENE0002.fn_converte_time_data(rw_crapage.hrinipaa);
				pr_tab_crapage(pr_cdagenci).hrfimpaa := GENE0002.fn_converte_time_data(rw_crapage.hrfimpaa);
				pr_tab_crapage(pr_cdagenci).indspcxa := rw_crapage.indspcxa;
				pr_tab_crapage(pr_cdagenci).indsptaa := rw_crapage.indsptaa;
        pr_tab_crapage(pr_cdagenci).nrlatitu := rw_crapage.nrlatitu;
        pr_tab_crapage(pr_cdagenci).nrlongit := rw_crapage.nrlongit;
        pr_tab_crapage(pr_cdagenci).flmajora := rw_crapage.flmajora;
        pr_tab_crapage(pr_cdagenci).vllimpag := rw_crapage.vllimpag;

      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;
    END;

  END pc_carrega_dados;

  PROCEDURE pc_busca_pac(pr_cddopcao     IN VARCHAR2 --> Opcao
                        ,pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_busca_pac
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para buscar os dados do PA.

    Alteracoes: 23/01/2018 - Adicionado nova permissao para o departamento CANAIS,
                             conforme solicitado no chamado 825830. (Kelvin)
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADPAC'
                                ,pr_action => NULL);
      -- NAO foi informado PA
      IF pr_cdagenci = 0 THEN
        vr_cdcritic := 89;
        RAISE vr_exc_erro;
      END IF;

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seleciona operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;

      -- Verifica se tem permissao de alteracao
      IF (pr_cdagenci = 90 OR pr_cdagenci = 91) AND
          pr_cddopcao <> 'C'                    AND
          -- Não for 4-COMPE / 8-COORD.ADM/FINANCEIRO / 9-COORD.PRODUTOS / 18-SUPORTE / 20-TI / 1-CANAIS
          rw_crapope.cddepart NOT IN (4,8,9,18,20,1) THEN
          vr_dscritic := 'PA 90 ou PA 91 podem ser alterados pelos departamentos: TI, SUPORTE, COORD.ADM/FIN., COORD.PROD, COMPE e CANAIS.';
          RAISE vr_exc_erro;
      END IF;

      -- Carrega os dados da agencia
      pc_carrega_dados(pr_cdcooper    => vr_cdcooper
                      ,pr_cdagenci    => pr_cdagenci
                      ,pr_tab_crapage => vr_tab_crapage
                      ,pr_cdcritic    => vr_cdcritic
                      ,pr_dscritic    => vr_dscritic);

      -- Se houve retorno de erro
      IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Se for inclusao e encontrou
      IF pr_cddopcao = 'I' THEN
        -- Se encontrou
        IF vr_tab_crapage.COUNT > 0 THEN
          vr_cdcritic := 787;
          RAISE vr_exc_erro;
        END IF;
      ELSE
        -- Se for consulta/edicao/opcao X/B e NAO encontrar
        IF vr_tab_crapage.COUNT = 0 THEN
          vr_cdcritic := 962;
          RAISE vr_exc_erro;
        END IF;

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmextage'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nmextage
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmresage'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nmresage
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'insitage'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).insitage
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdcxaage'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdcxaage
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'tpagenci'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).tpagenci
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdccuage'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdccuage
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdorgpag'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdorgpag
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdagecbn'
                              ,pr_tag_cont => LPAD(vr_tab_crapage(pr_cdagenci).cdagecbn,4,0)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdcomchq'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdcomchq
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vercoban'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).vercoban
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdbantit'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdbantit
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdagetit'
                              ,pr_tag_cont => GENE0002.fn_mask(vr_tab_crapage(pr_cdagenci).cdagetit,'zzzz.z')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdbanchq'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdbanchq
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdagechq'
                              ,pr_tag_cont => GENE0002.fn_mask(vr_tab_crapage(pr_cdagenci).cdagechq,'zzzz.z')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdbandoc'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdbandoc
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdagedoc'
                              ,pr_tag_cont => GENE0002.fn_mask(vr_tab_crapage(pr_cdagenci).cdagedoc,'zzzz.z')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgdsede'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).flgdsede
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdagepac'
                              ,pr_tag_cont => GENE0002.fn_mask(vr_tab_crapage(pr_cdagenci).cdagepac,'zz.zzz')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgutcrm'
                              ,pr_tag_cont => GENE0002.fn_mask(vr_tab_crapage(pr_cdagenci).flgutcrm,'zz.zzz')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdagefgt'
                              ,pr_tag_cont => GENE0002.fn_mask(vr_tab_crapage(pr_cdagenci).cdagefgt,'zzzz.z')
                              ,pr_des_erro => vr_dscritic);
                
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsendcop'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsendcop
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrendere'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nrendere
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmbairro'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nmbairro
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dscomple'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dscomple
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrcepend'
                              ,pr_tag_cont => GENE0002.fn_mask(vr_tab_crapage(pr_cdagenci).nrcepend,'99.999-999')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'idcidade'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).idcidade
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmcidade'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nmcidade
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdufdcop'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdufdcop
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsdemail'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsdemail
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsmailbd'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsmailbd
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsinform1'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsinform1
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsinform2'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsinform2
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsinform3'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsinform3
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhsicini'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhsicini,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhsicfim'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhsicfim,'00:00')
                              ,pr_des_erro => vr_dscritic);

        --> BANCOOB
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhini_bancoob'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhini_bancoob,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhfim_bancoob'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhfim_bancoob,'00:00')
                              ,pr_des_erro => vr_dscritic);
                              
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhtitini'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhtitini,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhtitfim'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhtitfim,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhcompel'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhcompel,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhcapini'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhcapini,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhcapfim'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhcapfim,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhdoctos'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhdoctos,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhtrfini'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhtrfini,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhtrffim'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhtrffim,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhguigps'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhguigps,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhbolini'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhbolini,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhbolfim'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhbolfim,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhenvelo'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhenvelo,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhcpaini'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhcpaini,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhcpafim'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhcpafim,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhlimcan'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).hhlimcan
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhsiccan'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhsiccan,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hhcan_bancoob'
                              ,pr_tag_cont => NVL(vr_tab_crapage(pr_cdagenci).hhcan_bancoob,'00:00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrtelvoz'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nrtelvoz
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrtelfax'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nrtelfax
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'qtddaglf'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).qtddaglf
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'qtmesage'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).qtmesage
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'qtddlslf'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).qtddlslf
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flsgproc'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).flsgproc
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vllimapv'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapage(pr_cdagenci).vllimapv,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'qtchqprv'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).qtchqprv
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flgdopgd'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).flgdopgd
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdageagr'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdageagr
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cddregio'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cddregio
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsdregio'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsdregio
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'tpageins'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).tpageins
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'cdorgins'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).cdorgins
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vlminsgr'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapage(pr_cdagenci).vlminsgr,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vlmaxsgr'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapage(pr_cdagenci).vlmaxsgr,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nmpasite'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).nmpasite
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dstelsit'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dstelsit
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dsemasit'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dsemasit
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dssitpaa'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).dssitpaa
                              ,pr_des_erro => vr_dscritic);

				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hrinipaa'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).hrinipaa
                              ,pr_des_erro => vr_dscritic);
															
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'hrfimpaa'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).hrfimpaa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'indspcxa'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).indspcxa
                              ,pr_des_erro => vr_dscritic);
															
				GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'indsptaa'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).indsptaa
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrlatitu'
                              ,pr_tag_cont => (CASE WHEN vr_tab_crapage(pr_cdagenci).nrlatitu <> 0 THEN REPLACE(vr_tab_crapage(pr_cdagenci).nrlatitu,',','.') ELSE '' END)
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'nrlongit'
                              ,pr_tag_cont => (CASE WHEN vr_tab_crapage(pr_cdagenci).nrlongit <> 0 THEN REPLACE(vr_tab_crapage(pr_cdagenci).nrlongit,',','.') ELSE '' END)
                              ,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'flmajora'
                              ,pr_tag_cont => vr_tab_crapage(pr_cdagenci).flmajora
                              ,pr_des_erro => vr_dscritic);
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'vllimpag'
                              ,pr_tag_cont => TO_CHAR(vr_tab_crapage(pr_cdagenci).vllimpag,'FM999G999G999G990D00')
                              ,pr_des_erro => vr_dscritic);
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_busca_pac;

  PROCEDURE pc_item_log(pr_cdcooper IN INTEGER --> Codigo da cooperativa
                       ,pr_cddopcao IN VARCHAR2 --> Opcao
                       ,pr_cdoperad IN VARCHAR2 --> Codigo do operador
                       ,pr_cdagenci IN INTEGER --> Codigo da agencia
                       ,pr_dsdcampo IN VARCHAR2 --> Descricao do campo
                       ,pr_vldantes IN VARCHAR2 --> Valor antes
                       ,pr_vldepois IN VARCHAR2) IS  --> Valor depois
  BEGIN

    /* .............................................................................

    Programa: pc_item_log
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os itens do LOG.

    Alteracoes: -----
    ..............................................................................*/
    DECLARE

    BEGIN
      -- Se for alteracao e nao tem diferenca, retorna
      IF pr_cddopcao = 'A' AND pr_vldantes = pr_vldepois THEN
        RETURN;
      END IF;

      IF pr_cddopcao = 'A' THEN
        -- Geral LOG
        BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_nmarqlog     => 'cadpac.log'
                                  ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                      ' --> Operador ' || pr_cdoperad ||
                                                      ' alterou o campo ' || pr_dsdcampo ||
                                                      ' de ' || pr_vldantes ||
                                                      ' para ' || pr_vldepois || 
                                                      ' no PA ' || pr_cdagenci);
      ELSE

        IF pr_cddopcao = 'I' THEN
          -- Geral LOG
          BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratado
                                    ,pr_nmarqlog     => 'cadpac.log'
                                    ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                        ' --> Operador ' || pr_cdoperad ||
                                                        ' incluiu o campo ' || pr_dsdcampo ||
                                                        ' com o valor ' || pr_vldepois ||
                                                        ' no PA ' || pr_cdagenci);
        ELSE

          IF pr_cddopcao = 'X' THEN
            -- Geral LOG
            BTCH0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratado
                                      ,pr_nmarqlog     => 'cadpac.log'
                                      ,pr_des_log      => TO_CHAR(SYSDATE,'dd/mm/rrrr hh24:mi:ss') ||
                                                          ' --> Operador ' || pr_cdoperad ||
                                                          ' alterou o campo Valor de Aprovacao do Comite Local' ||
                                                          ' de ' || pr_vldantes ||
                                                          ' para ' || pr_vldepois || 
                                                          ' no PA ' || pr_cdagenci);
          END IF;

        END IF;

      END IF;

    END;

  END pc_item_log;

  PROCEDURE pc_grava_pac(pr_cddopcao     IN VARCHAR2 --> Opcao
                        ,pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        ,pr_nmextage     IN crapage.nmextage%TYPE --> Nome da agencia
                        ,pr_nmresage     IN crapage.nmresage%TYPE --> Nome resumido da agencia
                        ,pr_insitage     IN crapage.insitage%TYPE --> Situacao (0-Implantacao,1-Ativo,2-Inativo,3-Temporariamente Indisponivel)
                        ,pr_cdcxaage     IN crapage.cdcxaage%TYPE --> Numero do caixa do posto
                        ,pr_tpagenci     IN crapage.tpagenci%TYPE --> Tipo de agencia: 0-Convencional, 1-Pioneira (IN-PIONEIRA)
                        ,pr_cdccuage     IN crapage.cdccuage%TYPE --> Numero do centro de custo do posto
                        ,pr_cdorgpag     IN crapage.cdorgpag%TYPE --> Codigo identificador do orgao pagador junto ao INSS
                        ,pr_cdagecbn     IN crapage.cdagecbn%TYPE --> Codigo da agencia de relacionamento COBAN
                        ,pr_cdcomchq     IN crapage.cdcomchq%TYPE --> Codigo de compensacao de cheque
                        ,pr_vercoban     IN crapage.vercoban%TYPE --> Consultar as pendencias do COBAN no fechamento do caixa
                        ,pr_cdbantit     IN crapage.cdbantit%TYPE --> Codigo do Banco do Titulo onde sera entregue a COMPE
                        ,pr_cdagetit     IN crapage.cdagetit%TYPE --> Codigo da agencia dos titulos onde sera entregue a COMPE
                        ,pr_cdbanchq     IN crapage.cdbanchq%TYPE --> Codigo do Banco do Cheque onde sera entregue a COMPE
                        ,pr_cdagechq     IN crapage.cdagechq%TYPE --> Codigo da agencia do cheque onde sera entregue a COMPE
                        ,pr_cdbandoc     IN crapage.cdbandoc%TYPE --> Codigo do Banco do DOC onde sera entregue a COMPE
                        ,pr_cdagedoc     IN crapage.cdagedoc%TYPE --> Codigo da agencia do DOC onde sera entregue a COMPE
                        ,pr_flgdsede     IN crapage.flgdsede%TYPE --> PA eh Sede da cooperativa
                        ,pr_cdagepac     IN crapage.cdagepac%TYPE --> Numero da agencia do PA na Central
												,pr_flgutcrm     IN crapage.flgutcrm%TYPE --> Flag de controle de acesso ao CRM
                        ,pr_dsendcop     IN crapage.dsendcop%TYPE --> Endereco do PA
                        ,pr_nrendere     IN crapage.nrendere%TYPE --> Numero (ref. endereco) do PA
                        ,pr_nmbairro     IN crapage.nmbairro%TYPE --> Nome do bairro onde esta localizado o PA
                        ,pr_dscomple     IN crapage.dscomple%TYPE --> Complemento do endereco do PA
                        ,pr_nrcepend     IN crapage.nrcepend%TYPE --> Codigo de enderecamento postal do endereco do PA
                        ,pr_idcidade     IN crapage.idcidade%TYPE --> Código identificador da cidade (crapmun)
                        ,pr_nmcidade     IN crapage.nmcidade%TYPE --> Nome da cidade onde esta localizado o PA
                        ,pr_cdufdcop     IN crapage.cdufdcop%TYPE --> Sigla do estado onde esta localizado o PA
                        ,pr_dsdemail     IN crapage.dsdemail%TYPE --> E-mail do PA
                        ,pr_dsmailbd     IN crapage.dsmailbd%TYPE --> E-mail envio borderos cadastrados via Internet Banking
                        ,pr_dsinform1    IN crapage.dsinform##1%TYPE --> Descricao do endereco do PA a ser impresso no cheque
                        ,pr_dsinform2    IN crapage.dsinform##2%TYPE --> Descricao do endereco do PA a ser impresso no cheque
                        ,pr_dsinform3    IN crapage.dsinform##3%TYPE --> Descricao do endereco do PA a ser impresso no cheque
                        ,pr_hhsicini     IN VARCHAR2 --> Horario inicial pagamento SICREDI
                        ,pr_hhsicfim     IN VARCHAR2 --> Horario final pagamento SICREDI
                        ,pr_hhtitini     IN VARCHAR2 --> Horario inicial pagamento Titulos/Faturas
                        ,pr_hhtitfim     IN VARCHAR2 --> Horario final pagamento Titulos/Faturas
                        ,pr_hhcompel     IN VARCHAR2 --> Horario Cheques
                        ,pr_hhcapini     IN VARCHAR2 --> Horario inicial Capital/Captacao
                        ,pr_hhcapfim     IN VARCHAR2 --> Horario final Capital/Captacao
                        ,pr_hhdoctos     IN VARCHAR2 --> Horario Doctos
                        ,pr_hhtrfini     IN VARCHAR2 --> Horario inicial Transferencia
                        ,pr_hhtrffim     IN VARCHAR2 --> Horario final Transferencia
                        ,pr_hhguigps     IN VARCHAR2 --> Horario Guias GPS
                        ,pr_hhbolini     IN VARCHAR2 --> Horario inicial Geracao/Instrucoes Cob. Registrada
                        ,pr_hhbolfim     IN VARCHAR2 --> Horario final Geracao/Instrucoes Cob. Registrada
                        ,pr_hhenvelo     IN VARCHAR2 --> Horario Deposito TAA
                        ,pr_hhcpaini     IN VARCHAR2 --> Horario inicial Credito Pre-Aprovado
                        ,pr_hhcpafim     IN VARCHAR2 --> Horario final Credito Pre-Aprovado
                        ,pr_hhlimcan     IN VARCHAR2 --> Horario Cancelamento de pagamentos
                        ,pr_hhsiccan     IN VARCHAR2 --> Horario Cancelamento pagamento SICREDI
                        ,pr_nrtelvoz     IN crapage.nrtelvoz%TYPE --> Telefone de voz do PA
                        ,pr_nrtelfax     IN crapage.nrtelfax%TYPE --> Telefone para FAX do PA
                        ,pr_qtddaglf     IN crapage.qtddaglf%TYPE --> Quantidade de dias limite para agendamentos
                        ,pr_qtmesage     IN crapage.qtmesage%TYPE --> Qtd. meses agendados
                        ,pr_qtddlslf     IN crapage.qtddlslf%TYPE --> Quantidade de dias para listar lancamentos futuros
                        ,pr_flsgproc     IN VARCHAR2 --> Flag Processo Manual
                        ,pr_vllimapv     IN crapage.vllimapv%TYPE --> Limite de Aprovacao para o Comite Local
                        ,pr_qtchqprv     IN crapage.qtchqprv%TYPE --> Quantidade maxima de cheques por previa e por caixa
                        ,pr_flgdopgd     IN crapage.flgdopgd%TYPE --> Indica se o pac esta ativo para participar do progrid
                        ,pr_cdageagr     IN crapage.cdageagr%TYPE --> Indica o pac agrupador
                        ,pr_cddregio     IN crapage.cddregio%TYPE --> Codigo da Regional
                        ,pr_tpageins     IN crapage.tpageins%TYPE --> Contem o tipo de agencia (0-Convencional, 1-Pioneira)
                        ,pr_cdorgins     IN crapage.cdorgins%TYPE --> Codigo identificador do orgao pagador junto ao INSS-SICREDI
                        ,pr_vlminsgr     IN crapage.vlminsgr%TYPE --> Contem o valor minimo para efetuar a sangria de caixa
                        ,pr_vlmaxsgr     IN crapage.vlmaxsgr%TYPE --> Contem o valor maximo para efetuar a sangria de caixa
                        ,pr_flmajora     IN crapage.flmajora%TYPE --> Contem o identificador de Majoracao habilitada
                        ,pr_cdagefgt     IN crapage.cdagefgt%TYPE --> Agencia do CAF/FGTS
                        ,pr_hhini_bancoob IN VARCHAR2 --> Horario inicial de pagamento bancoob
                        ,pr_hhfim_bancoob IN VARCHAR2 --> Horario final de pagamento bancoob 
                        ,pr_hhcan_bancoob IN VARCHAR2 --> Horario limite cancelamento de pagamento bancoob 
                        ,pr_vllimpag      IN crapage.vllimpag%TYPE --> Valor limite máximo pagamento sem autorização
                        ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                        ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                        ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                        ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                        ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                        ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_pac
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para incluir/alterar o PA.

    Alteracoes: 08/08/2017 - Adicionado novo parametro pr_flgutcrm. (Projeto 339 - Reinert)
    ..............................................................................*/
    DECLARE

      -- Verifica Banco
      CURSOR cr_crapban(pr_cdbccxlt IN crapban.cdbccxlt%TYPE) IS
        SELECT 1
          FROM crapban
         WHERE crapban.cdbccxlt = pr_cdbccxlt;
      rw_crapban cr_crapban%ROWTYPE;

      -- Procura se ja existe PAC com essa agencia em outras coop
      CURSOR cr_crapage(pr_cdagepac IN crapage.cdagepac%TYPE) IS
        SELECT crapage.cdagenci
          FROM crapage
         WHERE crapage.cdagepac = pr_cdagepac;
      rw_crapage cr_crapage%ROWTYPE;

      -- Cadastro de PA agrupador
      CURSOR cr_crabage(pr_cdcooper IN crapage.cdcooper%TYPE
                       ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
        SELECT crapage.cdageagr
              ,crapage.cdagenci
          FROM crapage
         WHERE crapage.cdcooper = pr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
      rw_crabage cr_crabage%ROWTYPE;

      -- Busca o registro da agencia
      CURSOR cr_crapagb(pr_cddbanco IN crapagb.cddbanco%TYPE
                       ,pr_cdageban IN crapagb.cdageban%TYPE) IS
        SELECT crapagb.cdcidade
          FROM crapagb
         WHERE crapagb.cddbanco = pr_cddbanco
           AND crapagb.cdageban = pr_cdageban;
      rw_crapagb cr_crapagb%ROWTYPE;
      
      -- Cadastro de pracas do sistema financeiro
      CURSOR cr_crapcaf(pr_cdcidade IN crapcaf.cdcidade%TYPE) IS
        SELECT crapcaf.cdcidade
          FROM crapcaf
         WHERE crapcaf.cdcidade = pr_cdcidade;
      rw_crapcaf cr_crapcaf%ROWTYPE;

      -- Cadastro de horas de execucao dos programas
      CURSOR cr_craphec(pr_cdcooper IN craphec.cdcooper%TYPE) IS
        SELECT craphec.hriniexe
          FROM craphec
         WHERE craphec.cdcooper = pr_cdcooper
           AND UPPER(craphec.dsprogra) = UPPER('TAA E INTERNET');
      rw_craphec cr_craphec%ROWTYPE;

      -- Cadastro de Regionais
      CURSOR cr_crapreg(pr_cdcooper IN crapreg.cdcooper%TYPE
                       ,pr_cddregio IN crapreg.cddregio%TYPE) IS
        SELECT 1
          FROM crapreg
         WHERE crapreg.cdcooper = pr_cdcooper
           AND crapreg.cddregio = pr_cddregio;
      rw_crapreg cr_crapreg%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_dsabacmp VARCHAR2(20);
      vr_hhini    NUMBER;
      vr_mmini    NUMBER;
      vr_hhfim    NUMBER;
      vr_mmfim    NUMBER;
      vr_hhsicini VARCHAR2(5);
      vr_hhsicfim VARCHAR2(5);
      vr_hhtitini VARCHAR2(5);
      vr_hhtitfim VARCHAR2(5);
      vr_hhcompel VARCHAR2(5);
      vr_hhcapini VARCHAR2(5);
      vr_hhcapfim VARCHAR2(5);
      vr_hhdoctos VARCHAR2(5);
      vr_hhtrfini VARCHAR2(5);
      vr_hhtrffim VARCHAR2(5);
      vr_hhguigps VARCHAR2(5);
      vr_hhbolini VARCHAR2(5);
      vr_hhbolfim VARCHAR2(5);
      vr_hhenvelo VARCHAR2(5);
      vr_hhcpaini VARCHAR2(5);
      vr_hhcpafim VARCHAR2(5);
      vr_hhlimcan VARCHAR2(5);
      vr_hhsiccan VARCHAR2(5);
      vr_dscnteml VARCHAR2(10000) := '';
      vr_emaildst VARCHAR2(4000);
      vr_dscidnew VARCHAR2(50);

      --Bancoob
      vr_hhini_bancoob VARCHAR2(5);
      vr_hhfim_bancoob VARCHAR2(5);
      vr_hhcan_bancoob VARCHAR2(5);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Vetor para armazenar os dados da tabela
      vr_tab_crapmun CADA0003.typ_tab_crapmun;

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADPAC'
                                ,pr_action => NULL);
      -- Limpa PLTABLE
      vr_tab_crapage.DELETE;

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Se NAO foi informado nome resumido
      IF TRIM(pr_nmresage) IS NULL THEN
        vr_dscritic := 'Informe o nome resumido do PA.###nmresage###0';
        RAISE vr_exc_saida;
      END IF;

	    -- Se NAO foi informado nome extenso
      IF TRIM(pr_nmextage) IS NULL THEN
        vr_dscritic := 'Informe o nome do PA.###nmextage###0';
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO foi informado codigo da COMPE
      IF pr_cdcomchq = 0 THEN
        vr_dscritic := 'Informe o código de compensação.###cdcomchq###0';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica Banco TIT
      OPEN cr_crapban(pr_cdbccxlt => pr_cdbantit);
      FETCH cr_crapban INTO rw_crapban;
      vr_blnfound := cr_crapban%FOUND;
      CLOSE cr_crapban;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 57;
        vr_dsabacmp := '###cdbantit###0';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica Banco CHEQ
      OPEN cr_crapban(pr_cdbccxlt => pr_cdbanchq);
      FETCH cr_crapban INTO rw_crapban;
      vr_blnfound := cr_crapban%FOUND;
      CLOSE cr_crapban;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 57;
        vr_dsabacmp := '###cdbanchq###0';
        RAISE vr_exc_saida;
      END IF;

      -- Verifica Banco DOC
      OPEN cr_crapban(pr_cdbccxlt => pr_cdbandoc);
      FETCH cr_crapban INTO rw_crapban;
      vr_blnfound := cr_crapban%FOUND;
      CLOSE cr_crapban;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 57;
        vr_dsabacmp := '###cdbandoc###0';
        RAISE vr_exc_saida;
      END IF;
      
      -- Se NAO foi informado UF
      IF TRIM(pr_cdufdcop) IS NULL THEN
        vr_cdcritic := 33;
        vr_dsabacmp := '###cdufdcop###1';
        RAISE vr_exc_saida;
      END IF;

      -- Se for alteracao
      IF pr_cddopcao = 'A' THEN

        -- Carrega os dados da agencia
        pc_carrega_dados(pr_cdcooper    => vr_cdcooper
                        ,pr_cdagenci    => pr_cdagenci
                        ,pr_tab_crapage => vr_tab_crapage
                        ,pr_cdcritic    => vr_cdcritic
                        ,pr_dscritic    => vr_dscritic);

        -- Se houve retorno de erro
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Se possuia valor informado e foi passado zero
        IF vr_tab_crapage(pr_cdagenci).cdagepac <> 0 AND pr_cdagepac = 0 THEN
          vr_dscritic := 'Agência do PA deve ser diferente de zero.###cdagepac###0';
          RAISE vr_exc_saida;
        END IF;

      END IF;

      -- Se foi informado Agencia do PA
      IF pr_cdagepac <> 0 THEN

        -- Procura se ja existe PAC com essa agencia em outras coop
        OPEN cr_crapage(pr_cdagepac => pr_cdagepac);
        FETCH cr_crapage INTO rw_crapage;
        vr_blnfound := cr_crapage%FOUND;
        CLOSE cr_crapage;
        -- Se encontrar
        IF vr_blnfound THEN
          IF rw_crapage.cdagenci <> pr_cdagenci THEN
            vr_dscritic := 'Agência do PA deve ser única.###cdagepac###0';
            RAISE vr_exc_saida;
          END IF;
        END IF;
        
        -- Selecionar a cooperativa
        OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        CLOSE cr_crapcop;

        -- Busca o registro da agencia
        OPEN cr_crapagb(pr_cddbanco => rw_crapcop.cdbcoctl
                       ,pr_cdageban => pr_cdagepac);
        FETCH cr_crapagb INTO rw_crapagb;
        vr_blnfound := cr_crapagb%FOUND;
        CLOSE cr_crapagb;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          vr_dscritic := 'Agência do PA não cadastrada no CAF.###cdagepac###0';
          RAISE vr_exc_saida;
        END IF;
        
        -- Cadastro de pracas do sistema financeiro
        OPEN cr_crapcaf(pr_cdcidade => rw_crapagb.cdcidade);
        FETCH cr_crapcaf INTO rw_crapcaf;
        vr_blnfound := cr_crapcaf%FOUND;
        CLOSE cr_crapcaf;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
          vr_dscritic := 'Agência do PA não cadastrada no CAF.###cdagepac###0';
          RAISE vr_exc_saida;
        END IF;

      END IF; -- pr_cdagepac <> 0

      -- Horario SICREDI
      vr_hhsicini := TO_CHAR(TO_DATE(pr_hhsicini,'HH24:MI'),'SSSSS');
      vr_hhsicfim := TO_CHAR(TO_DATE(pr_hhsicfim,'HH24:MI'),'SSSSS');
      -- Horario Titulos/Faturas
      vr_hhtitini := TO_CHAR(TO_DATE(pr_hhtitini,'HH24:MI'),'SSSSS');
      vr_hhtitfim := TO_CHAR(TO_DATE(pr_hhtitfim,'HH24:MI'),'SSSSS');
      -- Horario Cheques
      vr_hhcompel := TO_CHAR(TO_DATE(pr_hhcompel,'HH24:MI'),'SSSSS');
      -- Horario Plano Capital/Captacao
      vr_hhcapini := TO_CHAR(TO_DATE(pr_hhcapini,'HH24:MI'),'SSSSS');
      vr_hhcapfim := TO_CHAR(TO_DATE(pr_hhcapfim,'HH24:MI'),'SSSSS');
      -- Horario Doctos
      vr_hhdoctos := TO_CHAR(TO_DATE(pr_hhdoctos,'HH24:MI'),'SSSSS');
      -- Horario Transferencia
      vr_hhtrfini := TO_CHAR(TO_DATE(pr_hhtrfini,'HH24:MI'),'SSSSS');
      vr_hhtrffim := TO_CHAR(TO_DATE(pr_hhtrffim,'HH24:MI'),'SSSSS');
      -- Horario Guias GPS
      vr_hhguigps := TO_CHAR(TO_DATE(pr_hhguigps,'HH24:MI'),'SSSSS');
      -- Horario Geracao/Instrucoes Cob. Registrada
      vr_hhbolini := TO_CHAR(TO_DATE(pr_hhbolini,'HH24:MI'),'SSSSS');
      vr_hhbolfim := TO_CHAR(TO_DATE(pr_hhbolfim,'HH24:MI'),'SSSSS');
      -- Horario Deposito TAA
      vr_hhenvelo := TO_CHAR(TO_DATE(pr_hhenvelo,'HH24:MI'),'SSSSS');
      -- Horario Credito Pre-Aprovado
      vr_hhcpaini := TO_CHAR(TO_DATE(pr_hhcpaini,'HH24:MI'),'SSSSS');
      vr_hhcpafim := TO_CHAR(TO_DATE(pr_hhcpafim,'HH24:MI'),'SSSSS');
      -- Horario Cancelamento de pagamentos
      vr_hhlimcan := TO_CHAR(TO_DATE(pr_hhlimcan,'HH24:MI'),'SSSSS');
      -- Horario Cancelamento pagamento SICREDI
      vr_hhsiccan := TO_CHAR(TO_DATE(pr_hhsiccan,'HH24:MI'),'SSSSS');

      -- Seleciona operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      CLOSE cr_crapope;
      
      -- Caso seja da 4-COMPE ou 20-TI
      IF rw_crapope.cddepart IN (4,20) THEN

        -- Horario SICREDI
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhsicini,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhsicini,4,2));
        vr_hhfim    := TO_NUMBER(SUBSTR(pr_hhsicfim,1,2));
        vr_mmfim    := TO_NUMBER(SUBSTR(pr_hhsicfim,4,2));

        -- Valida hora inicial do pagamento SICREDI
        IF vr_hhini > 23 THEN
          vr_dscritic := 'Hora inválida.###hhsicini###2';
          RAISE vr_exc_saida;
        END IF;

        -- Valida minutos iniciais do pagamento SICREDI
        IF vr_mmini > 59 THEN
          vr_dscritic := 'Minutos inválidos.###hhsicini###2';
          RAISE vr_exc_saida;
        END IF;

        -- Valida hora final do pagamento SICREDI
        IF vr_hhfim > 23 THEN
          vr_dscritic := 'Hora inválida.###hhsicfim###2';
          RAISE vr_exc_saida;
        END IF;

        -- Valida minutos finais do pagamento SICREDI
        IF vr_mmfim > 59 THEN
          vr_dscritic := 'Minutos inválidos.###hhsicfim###2';
          RAISE vr_exc_saida;
        END IF;

        -- Valida se foi informado valor
        IF vr_hhini = 0 AND vr_mmini = 0 AND
           vr_hhfim = 0 AND vr_mmfim = 0 THEN
           vr_dscritic := 'Horário para pagamento SICREDI não pode ser nulo.###hhsicini###2';
           RAISE vr_exc_saida;
        END IF;

        -- Valida se hora inicial eh maior que final
        IF vr_hhsicini >= vr_hhsicfim THEN
          vr_cdcritic := 687;
          vr_dsabacmp := '###hhsicini###2';
          RAISE vr_exc_saida;
        END IF;

        -- Horario Cancelamento pagamento SICREDI
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhsiccan,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhsiccan,4,2));

        -- Se NAO foi informado algum valor
        IF vr_hhini = 0 AND vr_mmini = 0 THEN
          vr_dscritic := 'Horário para cancelamento de pagamento SICREDI não pode ser nulo.###hhsiccan###2';
          RAISE vr_exc_saida;
        END IF;

        -- Horario limite para cancelamento de pagamento Sicredi 19:24
        IF vr_hhsiccan >= 69900 THEN
          vr_cdcritic := 687;
          vr_dsabacmp := '###hhsiccan###2';
          RAISE vr_exc_saida;
        END IF;

        -- Horario Deposito TAA
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhenvelo,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhenvelo,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 THEN

          -- Valida hora inicial Deposito TAA
          IF vr_hhini < 0 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhenvelo###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto Deposito TAA
          IF vr_hhini = 23 AND vr_mmini > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhenvelo###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto Deposito TAA
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhenvelo###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Deposito TAA

      END IF; -- rw_crapope.cddepart IN (4,20)
      
      --> Validar horarios Bancoob
      BEGIN
        
        BEGIN
          vr_hhini_bancoob := to_char(to_date(pr_hhini_bancoob,'HH24:MI'),'SSSSS');
          
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Hora inválida.###hhini_bancoob###2';
            RAISE vr_exc_saida;
        END;
        
        BEGIN
          vr_hhfim_bancoob := to_char(to_date(pr_hhfim_bancoob,'HH24:MI'),'SSSSS');
          
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Hora inválida.###hhfim_bancoob###2';
            RAISE vr_exc_saida;
        END;
        
        -- Valida se hora inicial eh maior que final
        IF vr_hhini_bancoob >= vr_hhfim_bancoob THEN
          vr_cdcritic := 687;
          vr_dsabacmp := '###hhini_bancoob###2';
          RAISE vr_exc_saida;
        END IF;
        
        BEGIN
          vr_hhcan_bancoob := to_char(to_date(pr_hhcan_bancoob,'HH24:MI'),'SSSSS');
          
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Hora inválida.###hhcan_bancoob###2';
            RAISE vr_exc_saida;
        END;
        
      EXCEPTION
        WHEN vr_exc_saida THEN
          RAISE vr_exc_saida;
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao validar horario bancoob: '||SQLERRM;
          RAISE vr_exc_saida;
          
      END;
      
      
      -- Se for INTERNET BANK ou TAA
      IF pr_cdagenci = 90 OR pr_cdagenci = 91 THEN

        -- Horario Titulos/Faturas
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhtitini,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhtitini,4,2));
        vr_hhfim    := TO_NUMBER(SUBSTR(pr_hhtitfim,1,2));
        vr_mmfim    := TO_NUMBER(SUBSTR(pr_hhtitfim,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 OR vr_hhfim <> 0 OR vr_mmfim <> 0 THEN

          -- Valida hora inicial do pagamento Titulos/Faturas
          IF vr_hhini < 0 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora final do pagamento Titulos/Faturas
          IF vr_hhfim < 0 OR vr_hhfim > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto final do pagamento Titulos/Faturas
          IF vr_hhfim = 23 AND vr_mmfim > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto inicial do pagamento Titulos/Faturas
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto final do pagamento Titulos/Faturas
          IF vr_mmfim > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida se hora inicial eh maior que final
          IF vr_hhtitini >= vr_hhtitfim THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitini###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Titulos/Faturas

        -- Horario Cheques
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhcompel,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhcompel,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 THEN

          -- Valida hora inicial Cheques
          IF vr_hhini < 0 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcompel###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto Cheques
          IF vr_hhini = 23 AND vr_mmini > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcompel###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto Cheques
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcompel###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Cheques

        -- Horario Plano Capital/Captacao
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhcapini,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhcapini,4,2));
        vr_hhfim    := TO_NUMBER(SUBSTR(pr_hhcapfim,1,2));
        vr_mmfim    := TO_NUMBER(SUBSTR(pr_hhcapfim,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 OR vr_hhfim <> 0 OR vr_mmfim <> 0 THEN

          -- Valida hora inicial Plano Capital/Captacao
          IF vr_hhini < 6 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcapini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora final Plano Capital/Captacao
          IF vr_hhfim < 6 OR vr_hhfim > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcapfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto Plano Capital/Captacao
          IF vr_hhfim = 23 AND vr_mmfim > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcapfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto inicial Plano Capital/Captacao
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcapini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto final Plano Capital/Captacao
          IF vr_mmfim > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcapfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida se hora inicial eh maior que final
          IF vr_hhcapini >= vr_hhcapfim THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcapini###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Plano Capital/Captacao

        -- Horario Doctos
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhdoctos,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhdoctos,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 THEN

          -- Valida hora inicial Doctos
          IF vr_hhini < 0 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhdoctos###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto Doctos
          IF vr_hhini = 23 AND vr_mmini > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhdoctos###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto Doctos
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhdoctos###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Doctos

        -- Horario Transferencia
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhtrfini,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhtrfini,4,2));
        vr_hhfim    := TO_NUMBER(SUBSTR(pr_hhtrffim,1,2));
        vr_mmfim    := TO_NUMBER(SUBSTR(pr_hhtrffim,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 OR vr_hhfim <> 0 OR vr_mmfim <> 0 THEN

          -- Valida hora inicial Transferencia
          IF vr_hhini < 6 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtrfini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora final Transferencia
          IF vr_hhfim < 6 OR vr_hhfim > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtrffim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto Transferencia
          IF vr_hhfim = 23 AND vr_mmfim > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtrffim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto inicial Transferencia
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtrfini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto final Transferencia
          IF vr_mmfim > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtrffim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida se hora inicial eh maior que final
          IF vr_hhtrfini >= vr_hhtrffim THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtrfini###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Transferencia

        -- Horario Guias GPS
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhguigps,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhguigps,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 THEN

          -- Valida hora inicial Guias GPS
          IF vr_hhini < 0 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhguigps###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto Guias GPS
          IF vr_hhini = 23 AND vr_mmini > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhguigps###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto Guias GPS
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhguigps###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Guias GPS

        -- Horario Geracao/Instrucoes Cob. Registrada
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhbolini,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhbolini,4,2));
        vr_hhfim    := TO_NUMBER(SUBSTR(pr_hhbolfim,1,2));
        vr_mmfim    := TO_NUMBER(SUBSTR(pr_hhbolfim,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 OR vr_hhfim <> 0 OR vr_mmfim <> 0 THEN

          -- Valida hora inicial Geracao/Instrucoes Cob. Registrada
          IF vr_hhini < 6 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhbolini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora final Geracao/Instrucoes Cob. Registrada
          IF vr_hhfim < 6 OR vr_hhfim > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhbolfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora/minuto Geracao/Instrucoes Cob. Registrada
          IF vr_hhfim = 23 AND vr_mmfim > 0  THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhbolfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto inicial Geracao/Instrucoes Cob. Registrada
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhbolini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto final Geracao/Instrucoes Cob. Registrada
          IF vr_mmfim > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhbolfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida se hora inicial eh maior que final
          IF vr_hhbolini >= vr_hhbolfim THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhbolini###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Geracao/Instrucoes Cob. Registrada

        -- Horario Credito Pre-Aprovado
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhcpaini,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhcpaini,4,2));
        vr_hhfim    := TO_NUMBER(SUBSTR(pr_hhcpafim,1,2));
        vr_mmfim    := TO_NUMBER(SUBSTR(pr_hhcpafim,4,2));

        -- Se NAO foi informado algum valor
        IF vr_hhini = 0 AND vr_mmini = 0 AND vr_hhfim = 0 AND vr_mmfim = 0 THEN
          vr_dscritic := 'Horário para contratação do Crédito Pré-Aprovado não pode ser nulo.###hhcpaini###2';
          RAISE vr_exc_saida;
        ELSE

          -- Valida hora inicial Credito Pre-Aprovado
          IF vr_hhini < 0 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcpaini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida hora final Credito Pre-Aprovado
          IF vr_hhfim < 0 OR vr_hhfim > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcpafim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto inicial Credito Pre-Aprovado
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitini###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto final Credito Pre-Aprovado
          IF vr_mmfim > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhtitfim###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida se hora inicial eh maior que final
          IF vr_hhcpaini >= vr_hhcpafim THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhcpaini###2';
            RAISE vr_exc_saida;
          END IF;

        END IF; -- Fim Credito Pre-Aprovado

        -- Horario Cancelamento de pagamentos
        vr_hhini    := TO_NUMBER(SUBSTR(pr_hhlimcan,1,2));
        vr_mmini    := TO_NUMBER(SUBSTR(pr_hhlimcan,4,2));

        -- Se foi informado algum valor
        IF vr_hhini <> 0 OR vr_mmini <> 0 THEN

          -- Valida hora inicial Cancelamento de pagamentos
          IF vr_hhini < 0 OR vr_hhini > 23 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhlimcan###2';
            RAISE vr_exc_saida;
          END IF;

          -- Valida minuto Cancelamento de pagamentos
          IF vr_mmini > 59 THEN
            vr_cdcritic := 687;
            vr_dsabacmp := '###hhlimcan###2';
            RAISE vr_exc_saida;
          END IF;
          
          -- Cadastro de horas de execucao dos programas
          OPEN cr_craphec(pr_cdcooper => vr_cdcooper);
          FETCH cr_craphec INTO rw_craphec;
          vr_blnfound := cr_craphec%FOUND;
          CLOSE cr_craphec;
          -- Se encontrar
          IF vr_blnfound THEN
            -- Horario de cancelamento deve ser menor que o parametrizado na tela HRCOMP
            IF vr_hhlimcan >= rw_craphec.hriniexe THEN
              vr_cdcritic := 687;
              vr_dsabacmp := '###hhlimcan###2';
              RAISE vr_exc_saida;
            END IF;
          END IF;

        END IF; -- Fim Cancelamento de pagamentos

      END IF; -- pr_cdagenci = 90 OR pr_cdagenci = 91

      -- Se NAO foi informado quantidade de meses
      IF pr_qtmesage = 0 THEN
         vr_dscritic := 'Quantidade de meses para agendamento não pode ser nulo.###qtmesage###2';
         RAISE vr_exc_saida;
      END IF;

      -- Se foi informado Regional
      IF pr_cddregio > 0 THEN
        -- Cadastro de Regionais
        OPEN cr_crapreg(pr_cdcooper => vr_cdcooper
                       ,pr_cddregio => pr_cddregio);
        FETCH cr_crapreg INTO rw_crapreg;
        vr_blnfound := cr_crapreg%FOUND;
        CLOSE cr_crapreg;
        -- Se NAO encontrar
        IF NOT vr_blnfound THEN
           vr_dscritic := 'Código da Regional não cadastrado.###cddregio###3';
           RAISE vr_exc_saida;
        END IF;
      END IF;

      -- Valor maximo nao pode ser superior a 200.000,00
      IF pr_vlmaxsgr > 200000 THEN
         vr_dscritic := 'ATENÇÃO, limite máximo permitido R$ 200.000,00.###vlmaxsgr###3';
         RAISE vr_exc_saida;
      END IF;

      -- Valor maximo menor que minimo
      IF pr_vlmaxsgr < pr_vlminsgr THEN
         vr_dscritic := 'Valor máximo não pode ser menor que valor mínimo.###vlmaxsgr###3';
         RAISE vr_exc_saida;
      END IF;

      -- Se NAO estiver 1-Ativo ou 3-Temporariamente Indisponivel
      IF pr_insitage NOT IN (1,3) THEN

        -- Se estiver ativo para participar do Progrid
        IF pr_flgdopgd = 1 THEN
          vr_dscritic := 'Somente podem participar PAs com situação ativo.###flgdopgd###3';
          RAISE vr_exc_saida;
        END IF;

        -- Se foi informado PA agrupador
        IF pr_cdageagr <> 0 THEN
          vr_dscritic := 'PA NAO participante do progrid.###cdageagr###3';
          RAISE vr_exc_saida;
        END IF;

      ELSE

        -- Se estiver ativo para participar do Progrid e NAO foi informado PA agrupador
        IF pr_flgdopgd = 1 AND pr_cdageagr = 0 THEN
          vr_dscritic := 'Informe o PA agrupador.###cdageagr###3';
          RAISE vr_exc_saida;
        END IF;

        -- Se estiver inativo para participar do Progrid e foi informado PA agrupador
        IF pr_flgdopgd = 0 AND pr_cdageagr <> 0 THEN
          vr_dscritic := 'Indique PA participante como SIM.###flgdopgd###3';
          RAISE vr_exc_saida;
        END IF;

        -- Se estiver ativo para participar do Progrid e PA agrupador for diferente de seu codigo
        IF pr_flgdopgd = 1 AND pr_cdageagr <> pr_cdagenci THEN

          -- Cadastro de PA agrupador
          OPEN cr_crabage(pr_cdcooper => vr_cdcooper
                         ,pr_cdagenci => pr_cdageagr);
          FETCH cr_crabage INTO rw_crabage;
          vr_blnfound := cr_crabage%FOUND;
          CLOSE cr_crabage;
          -- Se NAO encontrar
          IF NOT vr_blnfound THEN
            vr_dscritic := 'O PA agrupador informado não existe.###cdageagr###3';
            RAISE vr_exc_saida;
          END IF;

          -- Se PA agrupador for diferente de seu codigo
          IF rw_crabage.cdageagr <> rw_crabage.cdagenci THEN
            vr_dscritic := 'O PA agrupador informado, deverá ter seu agrupador com seu próprio código.###cdageagr###3';
            RAISE vr_exc_saida;
          END IF;

        END IF;

      END IF; -- pr_insitage <> 1
      
      BEGIN
        -- Inclui o Horario SICREDI
        INSERT INTO craptab
                   (cdcooper
                   ,nmsistem
                   ,tptabela
                   ,cdempres
                   ,cdacesso
                   ,tpregist
                   ,dstextab)
             VALUES(vr_cdcooper  -- cdcooper
                   ,'CRED'       -- nmsistem
                   ,'GENERI'     -- tptabela
                   ,0            -- cdempres
                   ,'HRPGSICRED' -- cdacesso
                   ,pr_cdagenci  -- tpregist
                   ,TO_CHAR(vr_hhsicini) || ' ' ||
                    TO_CHAR(vr_hhsicfim) || ' ' ||
                    TO_CHAR(vr_hhsiccan) || ' ' || pr_flsgproc); -- dstextab
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir HRPGSICRED: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Se for INTERNET BANK ou TAA
      IF pr_cdagenci = 90 OR pr_cdagenci = 91 THEN

        BEGIN
          -- Inclui o Horario Plano Capital/Captacao
          INSERT INTO craptab
                     (cdcooper
                     ,nmsistem
                     ,tptabela
                     ,cdempres
                     ,cdacesso
                     ,tpregist
                     ,dstextab)
               VALUES(vr_cdcooper   -- cdcooper
                     ,'CRED'        -- nmsistem
                     ,'GENERI'      -- tptabela
                     ,0             -- cdempres
                     ,'HRPLANCAPI'  -- cdacesso
                     ,pr_cdagenci   -- tpregist
                     -- dstextab
                     ,'1'     || ' ' || -- processado
                      '64800' || ' ' || -- hhcapfim
                      '21600');         -- hhcapini
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir HRPLANCAPI: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          -- Inclui o Horario Transferencia
          INSERT INTO craptab
                     (cdcooper
                     ,nmsistem
                     ,tptabela
                     ,cdempres
                     ,cdacesso
                     ,tpregist
                     ,dstextab)
               VALUES(vr_cdcooper   -- cdcooper
                     ,'CRED'        -- nmsistem
                     ,'GENERI'      -- tptabela
                     ,0             -- cdempres
                     ,'HRTRANSFER'  -- cdacesso
                     ,pr_cdagenci   -- tpregist
                     -- dstextab
                     ,'1'     || ' ' || -- processado
                      '64800' || ' ' || -- hhtrffim
                      '21600' || ' ' || -- hhtrfini
                      pr_flsgproc);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir HRTRANSFER: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          -- Inclui o Horario Credito Pre-Aprovado
          INSERT INTO craptab
                     (cdcooper
                     ,nmsistem
                     ,tptabela
                     ,cdempres
                     ,cdacesso
                     ,tpregist
                     ,dstextab)
               VALUES(vr_cdcooper     -- cdcooper
                     ,'CRED'          -- nmsistem
                     ,'GENERI'        -- tptabela
                     ,0               -- cdempres
                     ,'HRCTRPREAPROV' -- cdacesso
                     ,pr_cdagenci     -- tpregist
                     -- dstextab
                     ,'21600' || ' ' || -- hhcpaini
                      '86340');         -- hhcpafim
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir HRCTRPREAPROV: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          -- Inclui o Horario Geracao/Instrucoes Cob. Registrada
          INSERT INTO craptab
                     (cdcooper
                     ,nmsistem
                     ,tptabela
                     ,cdempres
                     ,cdacesso
                     ,tpregist
                     ,dstextab)
               VALUES(vr_cdcooper  -- cdcooper
                     ,'CRED'       -- nmsistem
                     ,'GENERI'     -- tptabela
                     ,0            -- cdempres
                     ,'HRCOBRANCA' -- cdacesso
                     ,pr_cdagenci  -- tpregist
                     -- dstextab
                     ,'64800' || ' ' || -- hhbolfim
                      '21600');         -- hhbolini
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir HRCOBRANCA: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF; -- pr_cdagenci = 90 OR pr_cdagenci = 91

      BEGIN
        -- Inclui o Horario Titulos/Faturas
        INSERT INTO craptab
                   (cdcooper
                   ,nmsistem
                   ,tptabela
                   ,cdempres
                   ,cdacesso
                   ,tpregist
                   ,dstextab)
             VALUES(vr_cdcooper   -- cdcooper
                   ,'CRED'        -- nmsistem
                   ,'GENERI'      -- tptabela
                   ,0             -- cdempres
                   ,'HRTRTITULO'  -- cdacesso
                   ,pr_cdagenci   -- tpregist
                   -- dstextab
                   ,'1'     || ' ' || -- processado
                    '64800' || ' ' || -- hhtitfim
                    '21600' || ' ' || -- hhtitini
                    pr_flsgproc);
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir HRTRTITULO: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      BEGIN
        -- Inclui o Horario Cheques
        INSERT INTO craptab
                   (cdcooper
                   ,nmsistem
                   ,tptabela
                   ,cdempres
                   ,cdacesso
                   ,tpregist
                   ,dstextab)
             VALUES(vr_cdcooper   -- cdcooper
                   ,'CRED'        -- nmsistem
                   ,'GENERI'      -- tptabela
                   ,0             -- cdempres
                   ,'HRTRCOMPEL'  -- cdacesso
                   ,pr_cdagenci   -- tpregist
                   -- dstextab
                   ,'1' || ' ' || -- processado
                    '58500');     -- hhcompel
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir HRTRCOMPEL: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      BEGIN
        -- Inclui o Horario Guias GPS
        INSERT INTO craptab
                   (cdcooper
                   ,nmsistem
                   ,tptabela
                   ,cdempres
                   ,cdacesso
                   ,tpregist
                   ,dstextab)
             VALUES(vr_cdcooper   -- cdcooper
                   ,'CRED'        -- nmsistem
                   ,'GENERI'      -- tptabela
                   ,0             -- cdempres
                   ,'HRGUIASGPS'  -- cdacesso
                   ,pr_cdagenci   -- tpregist
                   -- dstextab
                   ,'1' || ' ' || -- processado
                    '64800');     -- hhguigps
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir HRGUIASGPS: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      BEGIN
        -- Inclui o Horario Deposito TAA
        INSERT INTO craptab
                   (cdcooper
                   ,nmsistem
                   ,tptabela
                   ,cdempres
                   ,cdacesso
                   ,tpregist
                   ,dstextab)
             VALUES(vr_cdcooper  -- cdcooper
                   ,'CRED'       -- nmsistem
                   ,'GENERI'     -- tptabela
                   ,0            -- cdempres
                   ,'HRTRENVELO' -- cdacesso
                   ,pr_cdagenci  -- tpregist
                    -- dstextab
                   ,'57600');    -- hhenvelo
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir HRTRENVELO: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      BEGIN
        -- Inclui o Horario Doctos
        INSERT INTO craptab
                   (cdcooper
                   ,nmsistem
                   ,tptabela
                   ,cdempres
                   ,cdacesso
                   ,tpregist
                   ,dstextab)
             VALUES(vr_cdcooper   -- cdcooper
                   ,'CRED'        -- nmsistem
                   ,'GENERI'      -- tptabela
                   ,0             -- cdempres
                   ,'HRTRDOCTOS'  -- cdacesso
                   ,pr_cdagenci   -- tpregist
                   -- dstextab
                   ,'1' || ' ' || -- processado
                    '58500');     -- hhdoctos
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          NULL;
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao incluir HRTRDOCTOS: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Se for alteracao
      IF pr_cddopcao = 'A' THEN

        BEGIN
          -- Altera o PA
          UPDATE crapage
             SET crapage.nmextage = pr_nmextage
                ,crapage.nmresage = pr_nmresage
                ,crapage.insitage = pr_insitage
                ,crapage.cdcxaage = pr_cdcxaage
                ,crapage.tpagenci = pr_tpagenci
                ,crapage.cdccuage = pr_cdccuage
                ,crapage.cdorgpag = pr_cdorgpag
                ,crapage.cdagecbn = pr_cdagecbn
                ,crapage.cdcomchq = pr_cdcomchq
                ,crapage.vercoban = pr_vercoban
                ,crapage.cdbantit = pr_cdbantit
                ,crapage.cdagetit = pr_cdagetit
                ,crapage.cdbanchq = pr_cdbanchq
                ,crapage.cdagechq = pr_cdagechq
                ,crapage.cdbandoc = pr_cdbandoc
                ,crapage.cdagedoc = pr_cdagedoc
                ,crapage.flgdsede = pr_flgdsede
                ,crapage.cdagepac = pr_cdagepac
								,crapage.flgutcrm = pr_flgutcrm
                ,crapage.cdagefgt = pr_cdagefgt
                ,crapage.dsendcop = NVL(pr_dsendcop,' ')
                ,crapage.nrendere = pr_nrendere
                ,crapage.nmbairro = NVL(pr_nmbairro,' ')
                ,crapage.dscomple = NVL(pr_dscomple,' ')
                ,crapage.nrcepend = pr_nrcepend
                ,crapage.idcidade = pr_idcidade
                ,crapage.nmcidade = NVL(pr_nmcidade,' ')
                ,crapage.cdufdcop = NVL(pr_cdufdcop,' ')
                ,crapage.dsdemail = NVL(pr_dsdemail,' ')
                ,crapage.dsmailbd = NVL(pr_dsmailbd,' ')
                ,crapage.dsinform##1 = NVL(pr_dsinform1,' ')
                ,crapage.dsinform##2 = NVL(pr_dsinform2,' ')
                ,crapage.dsinform##3 = NVL(pr_dsinform3,' ')
                ,crapage.hrcancel = vr_hhlimcan
                ,crapage.nrtelvoz = NVL(pr_nrtelvoz,' ')
                ,crapage.nrtelfax = NVL(pr_nrtelfax,' ')
                ,crapage.qtddaglf = pr_qtddaglf
                ,crapage.qtmesage = pr_qtmesage
                ,crapage.qtddlslf = pr_qtddlslf
                ,crapage.vllimapv = pr_vllimapv
                ,crapage.qtchqprv = pr_qtchqprv
                ,crapage.flgdopgd = pr_flgdopgd
                ,crapage.cdageagr = pr_cdageagr
                ,crapage.cddregio = pr_cddregio
                ,crapage.tpageins = pr_tpageins
                ,crapage.cdorgins = pr_cdorgins
                ,crapage.vlminsgr = pr_vlminsgr
                ,crapage.vlmaxsgr = pr_vlmaxsgr
                ,crapage.flmajora = pr_flmajora
                ,crapage.vllimpag = pr_vllimpag
           WHERE crapage.cdcooper = vr_cdcooper
             AND crapage.cdagenci = pr_cdagenci;

          -- Altera o Horario SICREDI
          UPDATE craptab
             SET craptab.dstextab = TO_CHAR(vr_hhsicini) || ' ' ||
                                    TO_CHAR(vr_hhsicfim) || ' ' ||
                                    TO_CHAR(vr_hhsiccan) || ' ' || 
                                    pr_flsgproc
           WHERE craptab.cdcooper        = vr_cdcooper
             AND UPPER(craptab.nmsistem) = 'CRED'
             AND UPPER(craptab.tptabela) = 'GENERI'
             AND craptab.cdempres        = 0
             AND UPPER(craptab.cdacesso) = 'HRPGSICRED'
             AND craptab.tpregist        = pr_cdagenci;

          --> Begin
          IF vr_hhini_bancoob > 0 OR vr_hhfim_bancoob > 0 THEN
          
            BEGIN
            -- Altera o Horario SICREDI
            UPDATE craptab
               SET craptab.dstextab = TO_CHAR(vr_hhini_bancoob) || ' ' ||
                                      TO_CHAR(vr_hhfim_bancoob) || ' ' ||
                                      TO_CHAR(vr_hhcan_bancoob)
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRPGBANCOOB'
               AND craptab.tpregist        = pr_cdagenci;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar horario Bancoob: '||SQLERRM;
                RAISE vr_exc_saida;
            END;
            
            IF SQL%ROWCOUNT = 0 THEN
              BEGIN
                INSERT INTO craptab
                            ( nmsistem, 
                              tptabela, 
                              cdempres, 
                              cdacesso, 
                              tpregist, 
                              dstextab, 
                              cdcooper) 
                     VALUES ( 'CRED',        --> nmsistem
                              'GENERI',      --> tptabela
                              0,             --> cdempres
                              'HRPGBANCOOB', --> cdacesso
                              pr_cdagenci,   --> tpregist
                              TO_CHAR(vr_hhini_bancoob) || ' ' ||TO_CHAR(vr_hhfim_bancoob) || ' ' ||TO_CHAR(vr_hhcan_bancoob), --> dstextab
                              vr_cdcooper);  --> cdcooper       

              EXCEPTION
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel incluir horario Bancoob: '||SQLERRM;
                  RAISE vr_exc_saida;
              END;
            
            END IF;
            
          END IF;


          -- Se for INTERNET BANK ou TAA
          IF pr_cdagenci = 90 OR pr_cdagenci = 91 THEN

            -- Altera o Horario Plano Capital/Captacao
            UPDATE craptab
               SET craptab.dstextab = SUBSTR(craptab.dstextab,1,1) || ' ' ||
                                      vr_hhcapfim || ' ' ||
                                      vr_hhcapini
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRPLANCAPI'
               AND craptab.tpregist        = pr_cdagenci;

            -- Altera o Horario Titulos/Faturas
            UPDATE craptab
               SET craptab.dstextab = SUBSTR(craptab.dstextab,1,1) || ' ' ||
                                      vr_hhtitfim || ' ' ||
                                      vr_hhtitini || ' ' ||
                                      pr_flsgproc
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRTRTITULO'
               AND craptab.tpregist        = pr_cdagenci;

            -- Altera o Horario Cheques
            UPDATE craptab
               SET craptab.dstextab = SUBSTR(craptab.dstextab,1,1) || ' ' ||
                                      vr_hhcompel
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRTRCOMPEL'
               AND craptab.tpregist        = pr_cdagenci;

            -- Altera o Horario Guias GPS
            UPDATE craptab
               SET craptab.dstextab = SUBSTR(craptab.dstextab,1,1) || ' ' ||
                                      vr_hhguigps
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRGUIASGPS'
               AND craptab.tpregist        = pr_cdagenci;

            -- Altera o Horario Doctos
            UPDATE craptab
               SET craptab.dstextab = SUBSTR(craptab.dstextab,1,1) || ' ' ||
                                      vr_hhdoctos
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRTRDOCTOS'
               AND craptab.tpregist        = pr_cdagenci;

            -- Altera o Horario Transferencia
            UPDATE craptab
               SET craptab.dstextab = SUBSTR(craptab.dstextab,1,1) || ' ' ||
                                      vr_hhtrffim || ' ' ||
                                      vr_hhtrfini || ' ' ||
                                      pr_flsgproc
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRTRANSFER'
               AND craptab.tpregist        = pr_cdagenci;

            -- Altera o Horario Geracao/Instrucoes Cob. Registrada
            UPDATE craptab
               SET craptab.dstextab = vr_hhbolfim || ' ' ||
                                      vr_hhbolini
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRCOBRANCA'
               AND craptab.tpregist        = pr_cdagenci;

            -- Altera o Horario Credito Pre-Aprovado
            UPDATE craptab
               SET craptab.dstextab = vr_hhcpaini || ' ' ||
                                      vr_hhcpafim
             WHERE craptab.cdcooper        = vr_cdcooper
               AND UPPER(craptab.nmsistem) = 'CRED'
               AND UPPER(craptab.tptabela) = 'GENERI'
               AND craptab.cdempres        = 0
               AND UPPER(craptab.cdacesso) = 'HRCTRPREAPROV'
               AND craptab.tpregist        = pr_cdagenci;

          END IF; -- pr_cdagenci = 90 OR pr_cdagenci = 91

          -- Altera o Horario Deposito TAA
          UPDATE craptab
             SET craptab.dstextab = vr_hhenvelo
           WHERE craptab.cdcooper        = vr_cdcooper
             AND UPPER(craptab.nmsistem) = 'CRED'
             AND UPPER(craptab.tptabela) = 'GENERI'
             AND craptab.cdempres        = 0
             AND UPPER(craptab.cdacesso) = 'HRTRENVELO'
             AND craptab.tpregist        = pr_cdagenci;

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao alterar PA: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      ELSE -- Inclusao

        BEGIN
          -- Inclui o PA
          INSERT INTO crapage
                     (cdcooper
                     ,cdagenci
                     ,nmextage
                     ,nmresage
                     ,insitage
                     ,cdcxaage
                     ,tpagenci
                     ,cdccuage
                     ,cdorgpag
                     ,cdagecbn
                     ,cdcomchq
                     ,vercoban
                     ,cdbantit
                     ,cdagetit
                     ,cdbanchq
                     ,cdagechq
                     ,cdbandoc
                     ,cdagedoc
                     ,flgdsede
                     ,cdagepac
										 ,flgutcrm
                     ,dsendcop
                     ,nrendere
                     ,nmbairro
                     ,dscomple
                     ,nrcepend
                     ,idcidade
                     ,nmcidade
                     ,cdufdcop
                     ,dsdemail
                     ,dsmailbd
                     ,dsinform##1
                     ,dsinform##2
                     ,dsinform##3
                     ,hrcancel
                     ,nrtelvoz
                     ,nrtelfax
                     ,qtddaglf
                     ,qtmesage
                     ,qtddlslf
                     ,vllimapv
                     ,qtchqprv
                     ,flgdopgd
                     ,cdageagr
                     ,cddregio
                     ,tpageins
                     ,cdorgins
                     ,vlminsgr
                     ,vlmaxsgr
                     ,nrordage
                     ,cddsenha
                     ,dtaltsnh
                     ,flmajora)
               VALUES(vr_cdcooper
                     ,pr_cdagenci
                     ,pr_nmextage
                     ,pr_nmresage
                     ,pr_insitage
                     ,pr_cdcxaage
                     ,pr_tpagenci
                     ,pr_cdccuage
                     ,pr_cdorgpag
                     ,pr_cdagecbn
                     ,pr_cdcomchq
                     ,pr_vercoban
                     ,pr_cdbantit
                     ,pr_cdagetit
                     ,pr_cdbanchq
                     ,pr_cdagechq
                     ,pr_cdbandoc
                     ,pr_cdagedoc
                     ,pr_flgdsede
                     ,pr_cdagepac
										 ,pr_flgutcrm
                     ,NVL(pr_dsendcop,' ')
                     ,pr_nrendere
                     ,NVL(pr_nmbairro,' ')
                     ,NVL(pr_dscomple,' ')
                     ,pr_nrcepend
                     ,pr_idcidade
                     ,NVL(pr_nmcidade,' ')
                     ,NVL(pr_cdufdcop,' ')
                     ,NVL(pr_dsdemail,' ')
                     ,NVL(pr_dsmailbd,' ')
                     ,NVL(pr_dsinform1,' ')
                     ,NVL(pr_dsinform2,' ')
                     ,NVL(pr_dsinform3,' ')
                     ,vr_hhlimcan
                     ,NVL(pr_nrtelvoz,' ')
                     ,NVL(pr_nrtelfax,' ')
                     ,pr_qtddaglf
                     ,pr_qtmesage
                     ,pr_qtddlslf
                     ,pr_vllimapv
                     ,pr_qtchqprv
                     ,pr_flgdopgd
                     ,pr_cdageagr
                     ,pr_cddregio
                     ,pr_tpageins
                     ,pr_cdorgins
                     ,pr_vlminsgr
                     ,pr_vlmaxsgr
                     ,pr_cdagenci
                     ,pr_cdagenci
                     ,TRUNC(SYSDATE)
                     ,pr_flmajora);

        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir PA: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          -- Inclui o Horario Pagamento INSS
          INSERT INTO craptab
                     (cdcooper
                     ,nmsistem
                     ,tptabela
                     ,cdempres
                     ,cdacesso
                     ,tpregist
                     ,dstextab)
               VALUES(vr_cdcooper  -- cdcooper
                     ,'CRED'       -- nmsistem
                     ,'GENERI'     -- tptabela
                     ,0            -- cdempres
                     ,'HRPGTOINSS' -- cdacesso
                     ,pr_cdagenci  -- tpregist
                     ,'58500');    -- dstextab
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            -- Se ja existir atualiza
            BEGIN
              UPDATE craptab
                 SET dstextab        = '58500'
               WHERE cdcooper        = vr_cdcooper
                 AND UPPER(nmsistem) = 'CRED'
                 AND UPPER(tptabela) = 'GENERI'
                 AND cdempres        = 0
                 AND UPPER(cdacesso) = 'HRPGTOINSS'
                 AND tpregist        = pr_cdagenci;
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar PA: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir PA: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

        BEGIN
          -- Inclui Truncagem - COMPE por imagem
          INSERT INTO craptab
                     (cdcooper
                     ,nmsistem
                     ,tptabela
                     ,cdempres
                     ,cdacesso
                     ,tpregist
                     ,dstextab)
               VALUES(vr_cdcooper    -- cdcooper
                     ,'CRED'         -- nmsistem
                     ,'GENERI'       -- tptabela
                     ,0              -- cdempres
                     ,'EXETRUNCAGEM' -- cdacesso
                     ,pr_cdagenci    -- tpregist
                     ,'NAO');        -- dstextab
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            -- Se ja existir atualiza
            BEGIN
              UPDATE craptab
                 SET dstextab        = 'NAO'
               WHERE cdcooper        = vr_cdcooper
                 AND UPPER(nmsistem) = 'CRED'
                 AND UPPER(tptabela) = 'GENERI'
                 AND cdempres        = 0
                 AND UPPER(cdacesso) = 'EXETRUNCAGEM'
                 AND tpregist        = pr_cdagenci;
        EXCEPTION
          WHEN OTHERS THEN
                vr_dscritic := 'Erro ao atualizar PA: ' || SQLERRM;
                RAISE vr_exc_saida;
            END;
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir PA: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;

      END IF; -- pr_cddopcao = 'A'

      -- Faz a geracao do LOG
      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'nome resumido'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).nmresage ELSE '-' END)
                 ,pr_vldepois => pr_nmresage);

     pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'nome'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).nmextage ELSE '-' END)
                 ,pr_vldepois => pr_nmextage);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'situacao'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).insitage) ELSE '-' END)
                 ,pr_vldepois => pr_insitage);

       pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'codigo caixa'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdcxaage) ELSE '-' END)
                 ,pr_vldepois => pr_cdcxaage);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'agencia pioneira'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).tpagenci) ELSE '-' END)
                 ,pr_vldepois => pr_tpagenci);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'centro custo'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdccuage) ELSE '-' END)
                 ,pr_vldepois => pr_cdccuage);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'orgao pagador'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdorgpag) ELSE '-' END)
                 ,pr_vldepois => pr_cdorgpag);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'agencia coban'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdagecbn) ELSE '-' END)
                 ,pr_vldepois => pr_cdagecbn);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'codigo compe'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdcomchq) ELSE '-' END)
                 ,pr_vldepois => pr_cdcomchq);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'ver.pendencia coban'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).vercoban) ELSE '-' END)
                 ,pr_vldepois => pr_vercoban);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'banco compe titulos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdbantit) ELSE '-' END)
                 ,pr_vldepois => pr_cdbantit);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'agencia compe titulos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdagetit) ELSE '-' END)
                 ,pr_vldepois => pr_cdagetit);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'banco compe cheques'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdbanchq) ELSE '-' END)
                 ,pr_vldepois => pr_cdbanchq);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'agencia compe cheques'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdagechq) ELSE '-' END)
                 ,pr_vldepois => pr_cdagechq);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'banco compe docs'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdbandoc) ELSE '-' END)
                 ,pr_vldepois => pr_cdbandoc);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'agencia compe docs'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdagedoc) ELSE '-' END)
                 ,pr_vldepois => pr_cdagedoc);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'PA sede'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).flgdsede) ELSE '-' END)
                 ,pr_vldepois => pr_flgdsede);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Agencia do PA'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdagepac) ELSE '-' END)
                 ,pr_vldepois => pr_cdagepac);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Agencia CAF/FGTS'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdagefgt) ELSE '-' END)
                 ,pr_vldepois => pr_cdagefgt);


      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Habilitar acesso CRM'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).flgutcrm) ELSE '-' END)
                 ,pr_vldepois => pr_flgutcrm);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'endereco'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).dsendcop ELSE '-' END)
                 ,pr_vldepois => NVL(pr_dsendcop, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'complemento'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).dscomple ELSE '-' END)
                 ,pr_vldepois => NVL(pr_dscomple, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'numero'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).nrendere) ELSE '-' END)
                 ,pr_vldepois => pr_nrendere);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'bairro'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).nmbairro ELSE '-' END)
                 ,pr_vldepois => NVL(pr_nmbairro, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'cep'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).nrcepend) ELSE '-' END)
                 ,pr_vldepois => pr_nrcepend);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'UF'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).cdufdcop ELSE '-' END)
                 ,pr_vldepois => pr_cdufdcop);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'codigo cidade'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).idcidade) ELSE '-' END)
                 ,pr_vldepois => pr_idcidade);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'cidade'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).nmcidade ELSE '-' END)
                 ,pr_vldepois => NVL(pr_nmcidade, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'e-mail'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).dsdemail ELSE '-' END)
                 ,pr_vldepois => NVL(pr_dsdemail, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'e-mail bordero'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).dsmailbd ELSE '-' END)
                 ,pr_vldepois => NVL(pr_dsmailbd, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'dados impressao cheques 1'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).dsinform1 ELSE '-' END)
                 ,pr_vldepois => NVL(pr_dsinform1, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'dados impressao cheques 2'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).dsinform2 ELSE '-' END)
                 ,pr_vldepois => NVL(pr_dsinform2, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'dados impressao cheques 3'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).dsinform3 ELSE '-' END)
                 ,pr_vldepois => NVL(pr_dsinform3, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Horario inicio pagamentos faturas sicredi'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhsicini ELSE '-' END)
                 ,pr_vldepois => pr_hhsicini);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Horario fim pagamentos faturas sicredi'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhsicfim ELSE '-' END)
                 ,pr_vldepois => pr_hhsicfim);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Horario inicio pagamentos bancoob'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhini_bancoob ELSE '-' END)
                 ,pr_vldepois => pr_hhini_bancoob);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Horario fim pagamentos bancoob'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhfim_bancoob ELSE '-' END)
                 ,pr_vldepois => pr_hhfim_bancoob);
                 
      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Horario limite canc. pagamentos bancoob'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhcan_bancoob ELSE '-' END)
                 ,pr_vldepois => pr_hhcan_bancoob);
                 
      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario inicial titulos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhtitini ELSE '-' END)
                 ,pr_vldepois => pr_hhtitini);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario final titulos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhtitfim ELSE '-' END)
                 ,pr_vldepois => pr_hhtitfim);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario cheques'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhcompel ELSE '-' END)
                 ,pr_vldepois => pr_hhcompel);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario inicial capital/captacao'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhcapini ELSE '-' END)
                 ,pr_vldepois => pr_hhcapini);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario final capital/captacao'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhcapfim ELSE '-' END)
                 ,pr_vldepois => pr_hhcapfim);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario doctos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhdoctos ELSE '-' END)
                 ,pr_vldepois => pr_hhdoctos);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario inicial transferencia'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhtrfini ELSE '-' END)
                 ,pr_vldepois => pr_hhtrfini);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario final transferencia'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhtrffim ELSE '-' END)
                 ,pr_vldepois => pr_hhtrffim);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario gps'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhguigps ELSE '-' END)
                 ,pr_vldepois => pr_hhguigps);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario inicial geracao boletos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhbolini ELSE '-' END)
                 ,pr_vldepois => pr_hhbolini);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario final geracao boletos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhbolfim ELSE '-' END)
                 ,pr_vldepois => pr_hhbolfim);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario envelopes'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhenvelo ELSE '-' END)
                 ,pr_vldepois => pr_hhenvelo);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario inicial pre-aprovado'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhcpaini ELSE '-' END)
                 ,pr_vldepois => pr_hhcpaini);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario final pre-aprovado'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhcpafim ELSE '-' END)
                 ,pr_vldepois => pr_hhcpafim);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'horario cancelamento pagamentos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).hhlimcan) ELSE '-' END)
                 ,pr_vldepois => pr_hhlimcan);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'telefone'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).nrtelvoz ELSE '-' END)
                 ,pr_vldepois => NVL(pr_nrtelvoz, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Horario cancelamento faturas sicredi'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).hhsiccan ELSE '-' END)
                 ,pr_vldepois => pr_hhsiccan);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'fax cancelamento pagamentos'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).nrtelfax ELSE '-' END)
                 ,pr_vldepois => NVL(pr_nrtelfax, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'limite dias agendamento'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).qtddaglf) ELSE '-' END)
                 ,pr_vldepois => pr_qtddaglf);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'meses agendamento captacao'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).qtmesage) ELSE '-' END)
                 ,pr_vldepois => pr_qtmesage);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'limite dias lancto.futuros'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).qtddlslf) ELSE '-' END)
                 ,pr_vldepois => pr_qtddlslf);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'processo manual'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN vr_tab_crapage(pr_cdagenci).flsgproc ELSE '-' END)
                 ,pr_vldepois => pr_flsgproc);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'valor aprovacao comite'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).vllimapv,'FM999G999G999G990D00') ELSE '-' END)
                 ,pr_vldepois => TO_CHAR(pr_vllimapv,'FM999G999G999G990D00'));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'qtd. max. de cheques por previa'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).qtchqprv) ELSE '-' END)
                 ,pr_vldepois => pr_qtchqprv);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'participa progrid'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).flgdopgd) ELSE '-' END)
                 ,pr_vldepois => pr_flgdopgd);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'pa agrupador progrid'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdageagr) ELSE '-' END)
                 ,pr_vldepois => pr_cdageagr);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Codigo da Regional'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cddregio) ELSE '-' END)
                 ,pr_vldepois => pr_cddregio);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Convenio Sicredi: Agencia pioneira'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).tpageins) ELSE '-' END)
                 ,pr_vldepois => pr_tpageins);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Orgao pagador'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).cdorgins) ELSE '-' END)
                 ,pr_vldepois => pr_cdorgins);

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Valor minimo sangria'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).vlminsgr,'FM999G999G999G990D00') ELSE '-' END)
                 ,pr_vldepois => TO_CHAR(pr_vlminsgr,'FM999G999G999G990D00'));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Valor maximo sangria'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).vlmaxsgr,'FM999G999G999G990D00') ELSE '-' END)
                 ,pr_vldepois => TO_CHAR(pr_vlmaxsgr,'FM999G999G999G990D00'));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'Flag Majoracao'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).flmajora) ELSE '-' END)
                 ,pr_vldepois => TO_CHAR(pr_flmajora));
      -- Se NAO encontrou registro, cria um vazio
      IF NOT vr_tab_crapage.EXISTS(pr_cdagenci) THEN
        vr_tab_crapage(pr_cdagenci).nmresage := ' ';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).dsendcop, ' ') <> NVL(pr_dsendcop, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Endereço:</b> de ''' || vr_tab_crapage(pr_cdagenci).dsendcop
                    || ''' para ''' || pr_dsendcop || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).dscomple, ' ') <> NVL(pr_dscomple, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Complemento:</b> de ''' || vr_tab_crapage(pr_cdagenci).dscomple
                    || ''' para ''' || pr_dscomple || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).nrendere, '0') <> NVL(pr_nrendere, '0') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Número:</b> de ''' || vr_tab_crapage(pr_cdagenci).nrendere
                    || ''' para ''' || pr_nrendere || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).nmbairro, ' ') <> NVL(pr_nmbairro, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Bairro:</b> de ''' || vr_tab_crapage(pr_cdagenci).nmbairro
                    || ''' para ''' || pr_nmbairro || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).nrcepend, '0') <> NVL(pr_nrcepend, '0') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>CEP:</b> de ''' || vr_tab_crapage(pr_cdagenci).nrcepend
                    || ''' para ''' || pr_nrcepend || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).cdufdcop, ' ') <> NVL(pr_cdufdcop, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>UF:</b> de ''' || vr_tab_crapage(pr_cdagenci).cdufdcop
                    || ''' para ''' || pr_cdufdcop || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).idcidade, '0') <> NVL(pr_idcidade, '0') THEN

        IF pr_idcidade > 0 THEN
          -- Busca o nome da cidade
          CADA0003.pc_busca_cidades(pr_idcidade    => pr_idcidade
                                   ,pr_cdcidade    => 0
                                   ,pr_dscidade    => ''
                                   ,pr_cdestado    => ''
                                   ,pr_infiltro    => 1 -- CETIP
                                   ,pr_intipnom    => 1 -- SEM ACENTUACAO
                                   ,pr_tab_crapmun => vr_tab_crapmun
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic);
          -- Se retornou erro
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
          -- Se encontrou
          IF vr_tab_crapmun.COUNT > 0 THEN
            vr_dscidnew := vr_tab_crapmun(1).dscidade;
          END IF;
        END IF;

        vr_dscnteml := vr_dscnteml
                    || '<b>Cidade:</b> de ''' || vr_tab_crapage(pr_cdagenci).nmcidade
                    || ''' para ''' || vr_dscidnew || '''<br>';
      END IF;

      -- Caso algum campo foi alterado
      IF TRIM(vr_dscnteml) IS NOT NULL THEN

        -- Selecionar a cooperativa
        OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        CLOSE cr_crapcop;

        -- Destinatarios das alteracoes dos dados para o site
        vr_emaildst :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => vr_cdcooper
                                                 ,pr_cdacesso => 'EMAIL_ALT_DADOS_SITE_PA');

        -- Adiciona cooperativa e pac
        vr_dscnteml := '<b>' || rw_crapcop.nmrescop ||'</b><br>'
                    || '<b>PA:</b> ' || pr_cdagenci || '-' || vr_tab_crapage(pr_cdagenci).nmresage
                    || '<br><br>' || vr_dscnteml;

        -- Faz a solicitacao do envio do email
        GENE0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                  ,pr_cdprogra        => vr_nmdatela
                                  ,pr_des_destino     => vr_emaildst
                                  ,pr_des_assunto     => 'Alteração de dados do PA'
                                  ,pr_des_corpo       => vr_dscnteml
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_erro        => vr_dscritic);

        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      END IF; -- TRIM(vr_dscnteml) IS NOT NULL

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                         || vr_dsabacmp;
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_pac;

  PROCEDURE pc_grava_valor_comite(pr_cddopcao     IN VARCHAR2 --> Opcao
                                 ,pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        	       ,pr_vllimapv     IN crapage.vllimapv%TYPE --> Limite de Aprovacao para o Comite Local
                                 ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                                 ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                                 ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                                 ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                                 ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                                 ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_valor_comite
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar valor do comite.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'TELA_CADPAC'
                                ,pr_action => NULL);
      -- Limpa PLTABLE
      vr_tab_crapage.DELETE;

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Carrega os dados da agencia
      pc_carrega_dados(pr_cdcooper    => vr_cdcooper
                      ,pr_cdagenci    => pr_cdagenci
                      ,pr_tab_crapage => vr_tab_crapage
                      ,pr_cdcritic    => vr_cdcritic
                      ,pr_dscritic    => vr_dscritic);

      BEGIN
        -- Altera o PA
        UPDATE crapage
           SET crapage.vllimapv = pr_vllimapv
         WHERE crapage.cdcooper = vr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar Valor Limite Comite Local: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Faz a geracao do LOG
      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => pr_cddopcao
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'valor aprovacao comite'
                 ,pr_vldantes => (CASE WHEN vr_tab_crapage.EXISTS(pr_cdagenci) THEN TO_CHAR(vr_tab_crapage(pr_cdagenci).vllimapv,'FM999G999G999G990D00') ELSE '-' END)
                 ,pr_vldepois => TO_CHAR(pr_vllimapv,'FM999G999G999G990D00'));

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_valor_comite;

  PROCEDURE pc_valida_caixa(pr_cdagenci     IN crapbcx.cdagenci%TYPE --> Codigo da agencia
                        	 ,pr_nrdcaixa     IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                           ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                           ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                           ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                           ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                           ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                           ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_valida_caixa
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para validar cadastramento de caixa.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Cadastro de boletim de caixa
      CURSOR cr_crapbcx(pr_cdcooper IN crapbcx.cdcooper%TYPE
                       ,pr_cdagenci IN crapbcx.cdagenci%TYPE
                       ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE) IS
        SELECT /*+ INDEX_ASC(crapbcx crapbcx##crapbcx4) */
               crapbcx.cdopecxa
              ,crapbcx.dtmvtolt
              ,crapbcx.ROWID
          FROM crapbcx
         WHERE crapbcx.cdcooper = pr_cdcooper
           AND crapbcx.dtmvtolt IS NOT NULL
           AND crapbcx.cdagenci = pr_cdagenci
           AND crapbcx.nrdcaixa = pr_nrdcaixa
           AND crapbcx.nrseqdig > 0;
      rw_crapbcx cr_crapbcx%ROWTYPE;

      -- Cadastro de lancamento de boletim de caixa
      CURSOR cr_craplcx(pr_cdcooper IN craplcx.cdcooper%TYPE
                       ,pr_cdagenci IN craplcx.cdagenci%TYPE
                       ,pr_nrdcaixa IN craplcx.nrdcaixa%TYPE) IS
        SELECT /*+ INDEX_ASC(craplcx craplcx##craplcx3) */
               1
          FROM craplcx
         WHERE craplcx.cdcooper = pr_cdcooper
           AND craplcx.dtmvtolt IS NOT NULL
           AND craplcx.cdagenci = pr_cdagenci
           AND craplcx.nrdcaixa = pr_nrdcaixa;
      rw_craplcx cr_craplcx%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_dsabacmp VARCHAR2(20);

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Se NAO foi informado caixa
      IF pr_nrdcaixa = 0 THEN
        vr_cdcritic := 375;
        vr_dsabacmp := '###nrdcaixa';
        RAISE vr_exc_saida;
      END IF;

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Cadastro de boletim de caixa
      OPEN cr_crapbcx(pr_cdcooper => vr_cdcooper
                     ,pr_cdagenci => pr_cdagenci
                     ,pr_nrdcaixa => pr_nrdcaixa);
      FETCH cr_crapbcx INTO rw_crapbcx;
      CLOSE cr_crapbcx;
      
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'cdopercx'
                            ,pr_tag_cont => rw_crapbcx.cdopecxa
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'dtdcaixa'
                            ,pr_tag_cont => TO_CHAR(rw_crapbcx.dtmvtolt,'DD/MM/RRRR')
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'rowidcxa'
                            ,pr_tag_cont => rw_crapbcx.ROWID
                            ,pr_des_erro => vr_dscritic);

      -- Cadastro de lancamento de boletim de caixa
      OPEN cr_craplcx(pr_cdcooper => vr_cdcooper
                     ,pr_cdagenci => pr_cdagenci
                     ,pr_nrdcaixa => pr_nrdcaixa);
      FETCH cr_craplcx INTO rw_craplcx;
      vr_blnfound := cr_craplcx%FOUND;
      CLOSE cr_craplcx;
      -- Se encontrar
      IF vr_blnfound THEN
        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'dserrocx'
                              ,pr_tag_cont => 'Boletim em uso. Não pode ser alterado.'
                              ,pr_des_erro => vr_dscritic);
      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                         || vr_dsabacmp;
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_valida_caixa;

  PROCEDURE pc_grava_caixa(pr_cdagenci     IN crapbcx.cdagenci%TYPE --> Codigo da agencia
                        	,pr_nrdcaixa     IN crapbcx.nrdcaixa%TYPE --> Numero do caixa
                          ,pr_cdopercx     IN crapbcx.cdopecxa%TYPE --> Codigo do operador
                          ,pr_dtdcaixa     IN VARCHAR2 --> Data do caixa
                          ,pr_rowidcxa     IN ROWID
                          ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                          ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                          ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                          ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                          ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                          ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_caixa
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para cadastramento de caixa.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_dsabacmp VARCHAR2(20);
      vr_dtdcaixa DATE;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

    BEGIN
      -- Se NAO foi informado caixa
      IF pr_nrdcaixa = 0 THEN
        vr_cdcritic := 375;
        vr_dsabacmp := '###nrdcaixa';
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO foi informado operador
      IF TRIM(pr_cdopercx) IS NULL THEN
        vr_cdcritic := 375;
        vr_dsabacmp := '###cdopercx';
        RAISE vr_exc_saida;
      END IF;

      -- Se NAO foi informado operador
      IF TRIM(pr_dtdcaixa) IS NULL THEN
        vr_cdcritic := 375;
        vr_dsabacmp := '###dtdcaixa';
        RAISE vr_exc_saida;
      END IF;

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Seleciona operador
      OPEN cr_crapope(pr_cdcooper => vr_cdcooper
                     ,pr_cdoperad => pr_cdopercx);
      FETCH cr_crapope INTO rw_crapope;
      vr_blnfound := cr_crapope%FOUND;
      CLOSE cr_crapope;
      -- Se NAO encontrar
      IF NOT vr_blnfound THEN
        vr_cdcritic := 67;
        vr_dsabacmp := '###cdopercx';
        RAISE vr_exc_saida;
      END IF;

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Converte data de VARCHAR para DATE
      vr_dtdcaixa := TO_DATE(pr_dtdcaixa,'DD/MM/RRRR');

      -- Se data informada for maior ou igual a data do sistema
      IF vr_dtdcaixa >= rw_crapdat.dtmvtolt THEN
        vr_cdcritic := 13;
        vr_dsabacmp := '###dtdcaixa';
        RAISE vr_exc_saida;
      END IF;

      BEGIN
        -- Se possuir cadastro altera
        IF TRIM(pr_rowidcxa) IS NOT NULL THEN
          UPDATE crapbcx
             SET crapbcx.cdopecxa = pr_cdopercx
                ,crapbcx.dtmvtolt = vr_dtdcaixa
           WHERE crapbcx.ROWID = pr_rowidcxa;
        -- Senao inclui
        ELSE
          INSERT INTO crapbcx
                     (cdcooper
                     ,cdagenci
                     ,dtmvtolt
                     ,cdopecxa
                     ,nrdcaixa
                     ,cdsitbcx
                     ,nrdlacre
                     ,nrdmaqui
                     ,nrseqdig)
               VALUES(vr_cdcooper
                     ,pr_cdagenci
                     ,vr_dtdcaixa
                     ,pr_cdopercx
                     ,pr_nrdcaixa
                     ,2   -- fechado
                     ,pr_nrdcaixa
                     ,pr_nrdcaixa
                     ,1); -- nrseqdig
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar Boletim de Caixa: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                         || vr_dsabacmp;
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_caixa;

  PROCEDURE pc_grava_dados_site(pr_cdagenci     IN crapage.cdagenci%TYPE --> Codigo da agencia
                        	     ,pr_nmpasite     IN crapage.nmpasite%TYPE --> Nome do PA para apresentacao no site da cooperativa
                               ,pr_dstelsit     IN crapage.dstelsit%TYPE --> Telefone do PA para apresentacao no site da cooperativa
                               ,pr_dsemasit     IN crapage.dsemasit%TYPE --> E-mail do PA para apresentacao no site da cooperativa
															 ,pr_hrinipaa     IN VARCHAR2              --> Hora Inicial atendimento
															 ,pr_hrfimpaa     IN VARCHAR2              --> Hora Final atendimento
															 ,pr_indspcxa     IN crapage.indspcxa%TYPE --> Possui Caixa
                               ,pr_nrlatitu     IN crapage.nrlatitu%TYPE --> Latitude da localizacao
                               ,pr_nrlongit     IN crapage.nrlongit%TYPE --> Longitude da localizacao
                               ,pr_xmllog       IN VARCHAR2 --> XML com informacoes de LOG
                               ,pr_cdcritic    OUT PLS_INTEGER --> Codigo da critica
                               ,pr_dscritic    OUT VARCHAR2 --> Descricao da critica
                               ,pr_retxml   IN OUT NOCOPY xmltype --> Arquivo de retorno do XML
                               ,pr_nmdcampo    OUT VARCHAR2 --> Nome do campo com erro
                               ,pr_des_erro    OUT VARCHAR2) IS --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_grava_dados_site
    Sistema : Ayllos Web
    Autor   : Jaison Fernando
    Data    : Julho/2016                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gravar os dados do site.

    Alteracoes: 
    ..............................................................................*/
    DECLARE

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_dscnteml VARCHAR2(10000) := '';
      vr_emaildst VARCHAR2(4000);
			vr_hhini    NUMBER;
      vr_mmini    NUMBER;
      vr_hhfim    NUMBER;
      vr_mmfim    NUMBER;
      vr_hrinipaa VARCHAR2(5);
			vr_hrfimpaa VARCHAR2(5);

    BEGIN
      -- Limpa PLTABLE
      vr_tab_crapage.DELETE;

      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Carrega os dados da agencia
      pc_carrega_dados(pr_cdcooper    => vr_cdcooper
                      ,pr_cdagenci    => pr_cdagenci
                      ,pr_tab_crapage => vr_tab_crapage
                      ,pr_cdcritic    => vr_cdcritic
                      ,pr_dscritic    => vr_dscritic);

			vr_hrinipaa := TO_CHAR(TO_DATE(pr_hrinipaa,'HH24:MI'),'SSSSS');
			vr_hrfimpaa := TO_CHAR(TO_DATE(pr_hrfimpaa,'HH24:MI'),'SSSSS');
									
      -- Horario Atendimento
			vr_hhini    := TO_NUMBER(SUBSTR(pr_hrinipaa,1,2));
			vr_mmini    := TO_NUMBER(SUBSTR(pr_hrinipaa,4,2));
			vr_hhfim    := TO_NUMBER(SUBSTR(pr_hrfimpaa,1,2));
			vr_mmfim    := TO_NUMBER(SUBSTR(pr_hrfimpaa,4,2));

			-- Valida hora inicial do Atendimento
			IF vr_hhini > 23 THEN
				vr_dscritic := 'Hora inválida.';
				RAISE vr_exc_saida;
			END IF;

			-- Valida minutos iniciais do Atendimento
			IF vr_mmini > 59 THEN
				vr_dscritic := 'Minutos inválidos.';
				RAISE vr_exc_saida;
			END IF;

			-- Valida hora final do Atendimento
			IF vr_hhfim > 23 THEN
				vr_dscritic := 'Hora inválida.';
				RAISE vr_exc_saida;
			END IF;

			-- Valida minutos finais do Atendimento
			IF vr_mmfim > 59 THEN
				vr_dscritic := 'Minutos inválidos.';
				RAISE vr_exc_saida;
			END IF;

			-- Valida se foi informado valor
			IF vr_hhini = 0 AND vr_mmini = 0 AND
				 vr_hhfim = 0 AND vr_mmfim = 0 THEN
				 vr_dscritic := 'Horário para atendimento não pode ser nulo.';
				 RAISE vr_exc_saida;
			END IF;

			-- Valida se hora inicial eh maior que final
			IF vr_hrinipaa >= vr_hrfimpaa THEN
				vr_cdcritic := 687;
				RAISE vr_exc_saida;
			END IF;

      BEGIN
        -- Altera o PA
        UPDATE crapage
           SET crapage.nmpasite = nvl(pr_nmpasite,' ')
              ,crapage.dstelsit = nvl(pr_dstelsit,' ')
              ,crapage.dsemasit = nvl(pr_dsemasit,' ')
						  ,crapage.hrinipaa = TO_CHAR(vr_hrinipaa)
							,crapage.hrfimpaa = TO_CHAR(vr_hrfimpaa)
							,crapage.indspcxa = nvl(pr_indspcxa,0)
              ,crapage.nrlatitu = nvl(pr_nrlatitu,0)
              ,crapage.nrlongit = nvl(pr_nrlongit,0)
         WHERE crapage.cdcooper = vr_cdcooper
           AND crapage.cdagenci = pr_cdagenci;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Problema ao gravar dados para o site da cooperativa: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      -- Faz a geracao do LOG
      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'nome para site'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).nmpasite
                 ,pr_vldepois => NVL(pr_nmpasite, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'telefone para site'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).dstelsit
                 ,pr_vldepois => NVL(pr_dstelsit, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'e-mail para site'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).dsemasit
                 ,pr_vldepois => NVL(pr_dsemasit, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'inicio horario de atendimento'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).hrinipaa
                 ,pr_vldepois => NVL(vr_hrinipaa, ' '));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'fim horario de atendimento'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).hrfimpaa
                 ,pr_vldepois => NVL(vr_hrfimpaa, ' '));
								 								 
			pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'possui caixaonline'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).indspcxa
                 ,pr_vldepois => NVL(pr_indspcxa, 0));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'latitude'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).nrlatitu
                 ,pr_vldepois => NVL(pr_nrlatitu, 0));

      pc_item_log(pr_cdcooper => vr_cdcooper
                 ,pr_cddopcao => 'A'
                 ,pr_cdoperad => vr_cdoperad
                 ,pr_cdagenci => pr_cdagenci
                 ,pr_dsdcampo => 'longitude'
                 ,pr_vldantes => vr_tab_crapage(pr_cdagenci).nrlongit
                 ,pr_vldepois => NVL(pr_nrlongit, 0));

      IF NVL(vr_tab_crapage(pr_cdagenci).nmpasite, ' ') <> NVL(pr_nmpasite, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Nome:</b> de ''' || vr_tab_crapage(pr_cdagenci).nmpasite
                    || ''' para ''' || pr_nmpasite || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).dstelsit, ' ') <> NVL(pr_dstelsit, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Telefone:</b> de ''' || vr_tab_crapage(pr_cdagenci).dstelsit
                    || ''' para ''' || pr_dstelsit || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).dsemasit, ' ') <> NVL(pr_dsemasit, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>E-mail:</b> de ''' || vr_tab_crapage(pr_cdagenci).dsemasit
                    || ''' para ''' || pr_dsemasit || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).hrinipaa, ' ') <> NVL(vr_hrinipaa, ' ') THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Horário inicio atendimento:</b> de ''' || vr_tab_crapage(pr_cdagenci).hrinipaa
                    || ''' para ''' || vr_hrinipaa || '''<br>';
      END IF;

			IF NVL(vr_tab_crapage(pr_cdagenci).hrfimpaa, ' ') <> NVL(vr_hrfimpaa, ' ') THEN

        vr_dscnteml := vr_dscnteml
                    || '<b>Horário fim atendimento:</b> de ''' || vr_tab_crapage(pr_cdagenci).hrfimpaa
                    || ''' para ''' || vr_hrfimpaa || '''<br>';
      END IF;

			IF NVL(vr_tab_crapage(pr_cdagenci).indspcxa, 0) <> NVL(pr_indspcxa, 0) THEN

        vr_dscnteml := vr_dscnteml
                    || '<b>Possui Caixa presencial:</b> de ''' || vr_tab_crapage(pr_cdagenci).indspcxa
                    || ''' para ''' || pr_indspcxa || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).nrlatitu, 0) <> NVL(pr_nrlatitu, 0) THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Latitude:</b> de ''' || vr_tab_crapage(pr_cdagenci).nrlatitu
                    || ''' para ''' || pr_nrlatitu || '''<br>';
      END IF;

      IF NVL(vr_tab_crapage(pr_cdagenci).nrlongit, 0) <> NVL(pr_nrlongit, 0) THEN
        vr_dscnteml := vr_dscnteml
                    || '<b>Longitude:</b> de ''' || vr_tab_crapage(pr_cdagenci).nrlongit
                    || ''' para ''' || pr_nrlongit || '''<br>';
      END IF;

      -- Caso algum campo foi alterado
      IF TRIM(vr_dscnteml) IS NOT NULL THEN

        -- Selecionar a cooperativa
        OPEN cr_crapcop(pr_cdcooper => vr_cdcooper);
        FETCH cr_crapcop INTO rw_crapcop;
        CLOSE cr_crapcop;

        -- Destinatarios das alteracoes dos dados para o site
        vr_emaildst :=  GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                 ,pr_cdcooper => vr_cdcooper
                                                 ,pr_cdacesso => 'EMAIL_ALT_DADOS_SITE_PA');

        -- Adiciona cooperativa e pac
        vr_dscnteml := '<b>' || rw_crapcop.nmrescop ||'</b><br>'
                    || '<b>PA:</b> ' || pr_cdagenci || '-' || vr_tab_crapage(pr_cdagenci).nmresage
                    || '<br><br>' || vr_dscnteml;

        -- Faz a solicitacao do envio do email
        GENE0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                  ,pr_cdprogra        => vr_nmdatela
                                  ,pr_des_destino     => vr_emaildst
                                  ,pr_des_assunto     => 'Alteração de dados do PA'
                                  ,pr_des_corpo       => vr_dscnteml
                                  ,pr_des_anexo       => NULL
                                  ,pr_des_erro        => vr_dscritic);

        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

      END IF; -- TRIM(vr_dscnteml) IS NOT NULL

      COMMIT;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_grava_dados_site;

  PROCEDURE pc_lista_pas(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                        ,pr_flgpaaut  IN INTEGER DEFAULT 1  --> Flag que indica se PAs de Auto-Atendimento deverão ser listados
                        ,pr_retxml   OUT NOCOPY xmltype        --> Arquivo de retorno do XML
                        ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo  
  BEGIN

    /* .............................................................................

    Programa: pc_lista_pas
    Sistema : SOA
    Autor   : David
    Data    : Janeiro/2018                 Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para listar os PAs da cooperativa

    Alteracoes: 
    ..............................................................................*/
    DECLARE        
      -- Tratamento de erros
      vr_dscritic  VARCHAR2(10000);
      vr_exc_saida EXCEPTION;
      
      vr_qtregist  NUMBER;     
      
      -- Selecionar os dados
      CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE,
                        pr_flgpaaut IN NUMBER) IS
      SELECT crapage.cdagenci
            ,crapage.nmextage
            ,crapage.nmresage
            ,crapage.nmpasite
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
         AND crapage.insitage NOT IN (0,2)
         AND ((pr_flgpaaut = 1 AND crapage.cdagenci NOT IN (999))
          OR  (pr_flgpaaut = 0 AND crapage.cdagenci NOT IN (90,91,999)));
      rw_crapage cr_crapage%ROWTYPE; 
    BEGIN    
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
      
      gene0007.pc_insere_tag(pr_xml => pr_retxml
                            ,pr_tag_pai => 'Root'
                            ,pr_posicao => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => ''
                            ,pr_des_erro => vr_dscritic);
      
      vr_qtregist := 0;      
      
      FOR rw_crapage IN cr_crapage(pr_cdcooper => pr_cdcooper
                                  ,pr_flgpaaut => pr_flgpaaut) LOOP          
        
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'Dados'
                              ,pr_posicao => 0
                              ,pr_tag_nova => 'PA'
                              ,pr_tag_cont => ''
                              ,pr_des_erro => vr_dscritic);      
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'PA'
                              ,pr_posicao => vr_qtregist
                              ,pr_tag_nova => 'cdagenci'
                              ,pr_tag_cont => TO_CHAR(rw_crapage.cdagenci)
                              ,pr_des_erro => vr_dscritic);          

        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'PA'
                              ,pr_posicao => vr_qtregist
                              ,pr_tag_nova => 'nmextage'
                              ,pr_tag_cont => TO_CHAR(rw_crapage.nmextage)
                              ,pr_des_erro => vr_dscritic);                                                            
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'PA'
                              ,pr_posicao => vr_qtregist
                              ,pr_tag_nova => 'nmresage'
                              ,pr_tag_cont => TO_CHAR(rw_crapage.nmresage)
                              ,pr_des_erro => vr_dscritic);  
                              
        gene0007.pc_insere_tag(pr_xml => pr_retxml
                              ,pr_tag_pai => 'PA'
                              ,pr_posicao => vr_qtregist
                              ,pr_tag_nova => 'nmpasite'
                              ,pr_tag_cont => TO_CHAR(rw_crapage.nmpasite)
                              ,pr_des_erro => vr_dscritic);                                                              
                              
        vr_qtregist := vr_qtregist + 1;                              
        
      END LOOP;    
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'NOK';
        vr_dscritic := 'Erro geral na rotina da tela CADPAC: ' || SQLERRM;

        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><dsmsgerr>' || vr_dscritic || '</dsmsgerr></Root>');
    END;

  END pc_lista_pas;                                                   

END TELA_CADPAC;
/
