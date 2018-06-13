CREATE OR REPLACE PROCEDURE CECRED.pc_crps634_i(pr_cdcooper    IN NUMBER                             --> C�digo da cooperativa
                                        ,pr_cdagenci    IN PLS_INTEGER                        --> C�digo da ag�ncia
                                        ,pr_cdoperad    IN VARCHAR2                           --> C�digo do cooperado
                                        ,pr_cdprogra    IN VARCHAR2                           --> C�digo do programa
                                        ,pr_persocio    IN NUMBER                             --> Percentual dos s�cios
                                        ,pr_tab_crapdat IN btch0001.rw_crapdat%TYPE           --> Pool de consulta de datas do sistema
                                        ,pr_impcab      IN VARCHAR2 DEFAULT 'N'               --> Controle de impress�o de cabe�alho
                                        ,pr_cdcritic    OUT PLS_INTEGER                       --> C�digo cr�tica
                                        ,pr_dscritic    OUT VARCHAR2) IS                      --> Descri��o cr�tica
  /* ..........................................................................

   Programa: PC_CRPS634_I   (antigo Includes/crps634.i)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CECRED
   Autor   : Adriano
   Data    : Dezembro/2012                     Ultima atualizacao: 21/03/2018

   Dados referentes ao programa:

   Frequencia: Diario(crps634)/Mensal(crps627).
   Objetivo  : Realiza a formacao do grupo economico.


   Alteracoes: 28/03/2013 - Incluido a passagem do parametro cdprogra na
                            chamada da procedure forma_grupo_economico
                            (Adriano).

               18/04/2013 - Ajustes realizados:
                             - Colocado no-undo nas temp-tables tt-erro,
                               tt-grupo-economico;
                             - Relatorio (crrl628): Invertido a ordem das
                               colunas "PAC GRUPO", alterado o label da coluna
                               "Conta SOC" para "Conta/DV" e pulado uma linha
                               ao final de cada grupo (Adriano).

               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).

               13/09/2013 - Convers�o Progress >> PLSQL (Petter-Supero)

               17/03/2014 - Ajustes na chamada do relat�rio, passando direto
                            o pr_cdrelato e n�o mais o pr_seqabrel (Marcos-Supero)

               13/12/2017 - Padroniza��o mensagens 
                          - Tratamento erros others: cecred.pc_internal_exception
                           (Ana - Envolti - Chamado 813390)

               21/03/2018 - Substitui��o da rotina pc_gera_log_batch pela pc_log_programa
                            para os c�digos 1066 e 1067
                           (Ana - Envolti - Chamado INC0011087)

               13/06/2018 - Substitui��o da rotina pc_gera_log_batch pela pc_log_programa
                            para o c�digo 1194
                           (Ana - Envolti - Chamado REQ0017067)
  ............................................................................. */
BEGIN
  DECLARE
    vr_nmarquiv    VARCHAR2(256);             --> Nome do arquivo
    vr_nom_dir     VARCHAR2(400);             --> Path do arquivo
    vr_tab_craterr GENE0001.typ_tab_erro;     --> PL Table de erros do sistema
    vr_tab_crapgrp geco0001.typ_tab_crapgrp;  --> PL Table para grupo economico
    vr_exc_erro    EXCEPTION;                 --> Controle de exce��o
    vr_cdprogra    VARCHAR2(40);              --> Nome do programa
    vr_index       VARCHAR2(100);             --> �ndice para a PL Table
    vr_indexd      VARCHAR2(100);             --> Indice para exclus�o da PL Table
    vr_controle    BOOLEAN := FALSE;          --> Controle se a itera��o acesso a cooperativa correta
    vr_xmlbuffer   VARCHAR2(32767);           --> Buffer para gera��o do XML
    vr_xml         CLOB;                      --> XML para criar relat�rio
    vr_nmformul    VARCHAR2(40);              --> Nome do formul�rio
    vr_nrcopias    NUMBER;                    --> N�mero de c�pias
    vr_dsparam     VARCHAR2(4000);            --> Par�metros da rotina para as mensagens
    vr_dscritic    VARCHAR2(4000);            --> Descri��o da cr�tica
    vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;      

    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS   --> C�digo da cooperativa
      SELECT cop.nmrescop
            ,cop.nrtelura
            ,cop.dsdircop
            ,cop.cdcooper
      FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN
    -- Nome do programa
    vr_cdprogra := 'CRPS634_I';

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS634_I', pr_action => NULL);

    -- Atribui��o de valores iniciais da procedure
    vr_nmformul := '';
    vr_nrcopias := 1;

    -- Capturar o path do arquivo
    vr_nom_dir := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper
                                       ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl

    -- Nome do arquivo
    vr_nmarquiv := 'crrl628';

    -- Verificar dados da cooperativa
    OPEN cr_crapcop(pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;

    -- Verifica se a tupla retorno registro, sen�o gera cr�tica
    IF cr_crapcop%NOTFOUND THEN
      CLOSE cr_crapcop;
      pr_cdcritic := 651;  --Falta registro de controle da cooperativa - ERRO DE SISTEMA
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);

      --Padroniza��o log do erro - Chamado 813390
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper             
                                ,pr_ind_tipo_log  => 2 -- Erro de neg�cio
                                ,pr_nmarqlog      => 'proc_batch.log'          
                                ,pr_dstiplog      => 'E' 
                                ,pr_cdprograma    => vr_cdprogra                      
                                ,pr_tpexecucao    => 1 -- Batch                       
                                ,pr_cdcriticidade => 1                    
                                ,pr_cdmensagem    => pr_cdcritic                      
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                     ||vr_cdprogra||' --> ' ||pr_dscritic);

      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;

    -- Limpar cr�tica
    pr_dscritic := '';

    vr_dsparam := 'cooper:'||rw_crapcop.cdcooper||', cdagenci:'||pr_cdagenci||', nrdcaixa:0'
                  ||', cdoperad:'||pr_cdoperad||', cdprogra:'||pr_cdprogra||', idorigem:1'
                  ||', persocio:'||pr_persocio||', dtmvtolt:'||pr_tab_crapdat.dtmvtolt;

    --Inclusao log para acompanhamento de tempo de execu��o - Chamado 813390
    --Registra o in�cio
    --Substituicao da rotina pc_gera_log_batch pela pc_log_programa - Chamado INC0011087
    CECRED.pc_log_programa(pr_dstiplog      => 'O',
                           pr_cdcooper      => rw_crapcop.cdcooper,
                           pr_tpocorrencia  => 4,  --Mensagem
                           pr_cdprograma    => vr_cdprogra,
                           pr_tpexecucao    => 1, --Batch
                           pr_cdcriticidade => 0,
                           pr_cdmensagem    => 1066, -- Inicio execucao
                           pr_dsmensagem    => gene0001.fn_busca_critica(1066)
                                               ||'pc_forma_grupo_economico '
                                               ||rw_crapcop.nmrescop||'. '||vr_dsparam,
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);

    -- Gerar grupos economicos
    geco0001.pc_forma_grupo_economico(pr_cdcooper    => rw_crapcop.cdcooper
                                     ,pr_cdagenci    => pr_cdagenci
                                     ,pr_nrdcaixa    => 0
                                     ,pr_cdoperad    => pr_cdoperad
                                     ,pr_cdprogra    => LOWER(pr_cdprogra)
                                     ,pr_idorigem    => 1
                                     ,pr_persocio    => pr_persocio
                                     ,pr_tab_crapdat => pr_tab_crapdat
                                     ,pr_tab_grupo   => vr_tab_crapgrp
                                     ,pr_cdcritic    => pr_cdcritic
                                     ,pr_dscritic    => pr_dscritic);

    -- Verifica se ocorreram erros
    IF pr_dscritic <> 'OK' THEN
      -- Verifica se a tabela de forma��o de grupos retornou sem registros
      --Aqui, embora tenha sido cadastrado o c�digo 1195 para a mensagem abaixo,
      --o mesmo n�o � gravado na vr_cdcritic, pois neste caso, omitiria o retorno da 
      --pc_forma_grupo_economico. Por isso o conte�do da vari�vel vr_dscritic tem uma
      --parte fixa concatenada com o retorno da rotina.
      IF vr_tab_crapgrp.count = 0 THEN
        pr_dscritic := '1195 - Nao foi possivel realizar a formacao do grupo economico para a ' || rw_crapcop.nmrescop||'. '||pr_dscritic;
      END IF;
      --Padroniza��o log do erro - Chamado 813390
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper             
                                ,pr_ind_tipo_log  => 2 -- Erro de neg�cio
                                ,pr_nmarqlog      => 'proc_batch.log'          
                                ,pr_dstiplog      => 'E' 
                                ,pr_cdprograma    => vr_cdprogra                      
                                ,pr_tpexecucao    => 1 -- Batch                       
                                ,pr_cdcriticidade => 1                    
                                ,pr_cdmensagem    => pr_cdcritic                      
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                     ||vr_cdprogra||' --> ' ||pr_dscritic);

      RAISE vr_exc_erro;
    ELSE
      --Se executou com sucesso, registra o t�rmino na tabela de logs
      --Inclusao log para acompanhamento de tempo de execu��o - Chamado 813390
      --Substituicao da rotina pc_gera_log_batch pela pc_log_programa - Chamado INC0011087
      CECRED.pc_log_programa(pr_dstiplog      => 'O',
                             pr_cdcooper      => rw_crapcop.cdcooper,
                             pr_tpocorrencia  => 4,  --Mensagem
                             pr_cdprograma    => vr_cdprogra,
                             pr_tpexecucao    => 1, --Batch
                             pr_cdcriticidade => 0,
                             pr_cdmensagem    => 1067, --Termino execucao
                             pr_dsmensagem    => gene0001.fn_busca_critica(1067)
                                                 ||'pc_forma_grupo_economico '
                                                 ||rw_crapcop.nmrescop||'. '||vr_dsparam,
                             pr_idprglog      => vr_idprglog,
                             pr_nmarqlog      => NULL);
    END IF;

    -- Eliminar registros marcadores da PL Table
    vr_index := vr_tab_crapgrp.FIRST;
    LOOP
      EXIT WHEN vr_index IS NULL;

      vr_indexd := vr_index;
      vr_index := vr_tab_crapgrp.NEXT(vr_index);

      IF vr_tab_crapgrp(vr_indexd).nrdgrupo IS NULL AND vr_tab_crapgrp(vr_indexd).nrdconta IS NULL AND vr_tab_crapgrp(vr_indexd).cdagenci IS NULL THEN
        vr_tab_crapgrp.DELETE(vr_indexd);
      END IF;
    END LOOP;

    -- Inicializar CLOB para XML
    dbms_lob.createtemporary(vr_xml, TRUE);
    dbms_lob.open(vr_xml, dbms_lob.lob_readwrite);

    -- Percorrer PL Table para formar relat�rio
    vr_index := vr_tab_crapgrp.first;
    vr_xmlbuffer := '<?xml version="1.0" encoding="utf-8"?><coope>';

    LOOP
      EXIT WHEN vr_index IS NULL;

      -- Verifica se as cooperativas est�o corretas
      IF vr_tab_crapgrp(vr_index).cdcooper = rw_crapcop.cdcooper THEN
        vr_controle := TRUE;

        -- Criar nodo pai
        IF vr_tab_crapgrp.PRIOR(vr_index) IS NOT NULL THEN
          IF vr_tab_crapgrp(vr_index).nrdgrupo <> vr_tab_crapgrp(vr_tab_crapgrp.PRIOR(vr_index)).nrdgrupo THEN
            vr_xmlbuffer := vr_xmlbuffer || '<grupo nr="' || vr_tab_crapgrp(vr_index).nrdgrupo || '">';
          END IF;
        ELSE
          vr_xmlbuffer := vr_xmlbuffer || '<grupo nr="' || vr_tab_crapgrp(vr_index).nrdgrupo || '">';
        END IF;

        vr_xmlbuffer := vr_xmlbuffer || '<registro><cdagenci>' || vr_tab_crapgrp(vr_index).cdagenci || '</cdagenci>' ||
                                        '<nrdgrupo>' || TO_CHAR(vr_tab_crapgrp(vr_index).nrdgrupo, 'FM999G999G990') || '</nrdgrupo>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => FALSE, pr_clob => vr_xml);
        vr_xmlbuffer := vr_xmlbuffer || '<nrctasoc>' || TO_CHAR(vr_tab_crapgrp(vr_index).nrctasoc, 'FM9999G9999G999G9') || '</nrctasoc>' ||
                                        '<dsdrisco>' || vr_tab_crapgrp(vr_index).dsdrisco || '</dsdrisco>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => FALSE, pr_clob => vr_xml);
        vr_xmlbuffer := vr_xmlbuffer || '<vlendivi>' || TO_CHAR(Nvl(vr_tab_crapgrp(vr_index).vlendivi, '0'), 'FM999G999G990D00') || '</vlendivi>' ||
                                        '<dsdrisgp>' || vr_tab_crapgrp(vr_index).dsdrisgp || '</dsdrisgp>' ||
                                        '<vlendigp>' || TO_CHAR(Nvl(vr_tab_crapgrp(vr_index).vlendigp, '0'), 'FM999G999G990D00') || '</vlendigp></registro>';
        gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => FALSE, pr_clob => vr_xml);
      END IF;

      -- Fechar nodo pai
      IF vr_tab_crapgrp.NEXT(vr_index) IS NOT NULL THEN
        IF vr_tab_crapgrp(vr_index).nrdgrupo <> vr_tab_crapgrp(vr_tab_crapgrp.NEXT(vr_index)).nrdgrupo THEN
          vr_xmlbuffer := vr_xmlbuffer || '</grupo>';
        END IF;
      ELSE
        vr_xmlbuffer := vr_xmlbuffer || '</grupo>';
      END IF;

      -- Gerar pr�ximo �ndice
      IF (vr_tab_crapgrp.next(vr_index) IS NOT NULL AND (vr_tab_crapgrp(vr_index).cdcooper = vr_tab_crapgrp(vr_tab_crapgrp.next(vr_index)).cdcooper AND
          vr_controle = TRUE)) OR vr_controle = FALSE THEN
        vr_index := vr_tab_crapgrp.next(vr_index);
      ELSE
        vr_index := NULL;
      END IF;
    END LOOP;

    -- Finalizar TAG XML
    vr_xmlbuffer := vr_xmlbuffer || '</coope>';
    gene0002.pc_clob_buffer(pr_dados => vr_xmlbuffer, pr_gravfim => TRUE, pr_clob => vr_xml);

    -- Gerar arquivo para internet
    gene0002.pc_gera_arquivo_intranet(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => 0
                                     ,pr_dtmvtolt => pr_tab_crapdat.dtmvtolt
                                     ,pr_nmarqimp => vr_nom_dir || '/' || vr_nmarquiv
                                     ,pr_nmformul => '132col'
                                     ,pr_dscritic => pr_cdcritic
                                     ,pr_tab_erro => vr_tab_craterr
                                     ,pr_des_erro => pr_dscritic);

    vr_dsparam := 'cdcooper:'||pr_cdcooper||', cdagenci:0, dtmvtolt:'||pr_tab_crapdat.dtmvtolt
                  ||', nmarqimp:'||vr_nom_dir || '/' || vr_nmarquiv||', nmformul:132col';

    -- Verifica se ocorreram erros
    IF pr_dscritic <> 'OK' THEN
      IF vr_tab_craterr.count = 0 THEN
        pr_dscritic := 'Nao foi possivel gerar o arquivo para a intranet - ' || rw_crapcop.nmrescop
                       ||', '||vr_dsparam;
      ELSE
        pr_dscritic := vr_tab_craterr(vr_tab_craterr.first).dscritic || ' - ' || rw_crapcop.nmrescop
                       ||', '||vr_dsparam;
      END IF;

      --Padroniza��o log do erro - Chamado 813390
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper             
                                ,pr_ind_tipo_log  => 2 -- Erro de neg�cio
                                ,pr_nmarqlog      => 'proc_batch.log'          
                                ,pr_dstiplog      => 'E' 
                                ,pr_cdprograma    => vr_cdprogra                      
                                ,pr_tpexecucao    => 1 -- Batch                       
                                ,pr_cdcriticidade => 1                    
                                ,pr_cdmensagem    => pr_cdcritic                      
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                     ||vr_cdprogra||' --> ' ||pr_dscritic);

    ELSE
      pr_dscritic := NULL;
    END IF;

    -- Criar arquivo princial com dados armazenados
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper
                               ,pr_cdprogra  => pr_cdprogra
                               ,pr_dtmvtolt  => pr_tab_crapdat.dtmvtolt
                               ,pr_dsxml     => vr_xml
                               ,pr_dsxmlnode => '/coope/grupo'
                               ,pr_dsjasper  => 'crrl628.jasper'
                               ,pr_dsparams  => 'PR_IMPCAB##' || pr_impcab
                               ,pr_dsarqsaid => vr_nom_dir || '/' || vr_nmarquiv || '.lst'
                               ,pr_flg_gerar => 'N'
                               ,pr_qtcoluna  => 132
                               ,pr_cdrelato  => 628
                               ,pr_flg_impri => 'S'
                               ,pr_nmformul  => vr_nmformul
                               ,pr_nrcopias  => vr_nrcopias
                               ,pr_dsmailcop => NULL
                               ,pr_dsassmail => NULL
                               ,pr_dscormail => NULL
                               ,pr_flsemqueb => 'N'
                               ,pr_des_erro  => pr_dscritic);
    -- Verificar se ocorreram erros
    IF pr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    -- Incluir nome do m�dulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_CRPS634_I', pr_action => NULL);

    -- Finalizar XML
    dbms_lob.close(vr_xml);
    dbms_lob.freetemporary(vr_xml);

    -- Alimentando a mensagem de sucesso que ser� impressa no log
    vr_dscritic := gene0001.fn_busca_critica(1194); --Grupo Economico formado com sucesso

    -- Gerar mensagem no LOG indicando sucesso
    --Padroniza��o log do erro - Chamado 813390
    --Substituicao da rotina pc_gera_log_batch pela pc_log_programa - Chamado REQ0017067
    CECRED.pc_log_programa(pr_dstiplog      => 'O',
                           pr_cdcooper      => pr_cdcooper,
                           pr_tpocorrencia  => 4,  --Mensagem
                           pr_cdprograma    => vr_cdprogra,
                           pr_tpexecucao    => 1, --Batch
                           pr_cdcriticidade => 0,
                           pr_cdmensagem    => 1194,
                           pr_dsmensagem    => vr_dscritic
                                               ||' '||rw_crapcop.nmrescop||'. '||vr_dsparam,
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Efetuar rollback
      ROLLBACK;
    WHEN others THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Propagar cr�tica
      -- Padroniza��o - Chamado 813390
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic)||'PC_CRPS634_I. '||SQLERRM||'. '||vr_dsparam;

      --Padroniza��o log do erro - Chamado 813390
      btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper             
                                ,pr_ind_tipo_log  => 3 -- Erro nao tratado
                                ,pr_nmarqlog      => 'proc_batch.log'          
                                ,pr_dstiplog      => 'E' 
                                ,pr_cdprograma    => vr_cdprogra                      
                                ,pr_tpexecucao    => 1 -- Batch                       
                                ,pr_cdcriticidade => 2                    
                                ,pr_cdmensagem    => pr_cdcritic                      
                                ,pr_des_log       => to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - ' 
                                                     ||vr_cdprogra||' --> ' ||pr_dscritic);

      -- No caso de erro de programa gravar tabela especifica de log - 13/12/2017 - Chamado 813390
      CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper);

  END;
END PC_CRPS634_I;
/
