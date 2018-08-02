CREATE OR REPLACE PACKAGE CECRED.gene0003 AS

  /*..............................................................................

    Programa: GENE0003 ( Antigo b1wgen0011.p )
    Autor   : David
    Data    : Agosto/2006                     Ultima Atualizacao: 24/07/2018

    Dados referentes ao programa:

    Objetivo  : BO para envio de e-mail.

..............................................................................*/

  -- Tipo tabela para montar a lista de destinatarios
  TYPE typ_tab_destinos IS
    TABLE OF VARCHAR2(4000)
      INDEX BY BINARY_INTEGER;

  /* Procedimento que processa os emails pendentes e chama seu envio */
  PROCEDURE pc_process_email_penden(pr_nrseqsol  IN crapsle.nrseqsol%TYPE DEFAULT NULL
                                   ,pr_des_erro OUT VARCHAR2);

  /* Procedimento de agendamento de e-mail com monitora��o em log e lista de destinat�rios em texto */
  procedure pc_solicita_email(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                             ,pr_cdprogra        IN VARCHAR2 --> Programa conectado
                             ,pr_des_destino     IN VARCHAR2 --> Um ou mais detinat�rios separados por ';' ou ','
                             ,pr_des_assunto     IN VARCHAR2 --> Assunto do e-mail
                             ,pr_des_corpo       IN VARCHAR2 --> Corpo (conteudo) do e-mail
                             ,pr_des_anexo       IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                             ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                             ,pr_flg_remete_coop IN VARCHAR2 DEFAULT 'N' --> Se o envio ser� do e-mail da Cooperativa
                             ,pr_des_nome_reply  IN VARCHAR2 DEFAULT NULL--> Nome para resposta ao e-mail
                             ,pr_des_email_reply IN VARCHAR2 DEFAULT NULL --> Endere�o para resposta ao e-mail
                             ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                             ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                             ,pr_des_erro       OUT VARCHAR2);
  
  /* Procedimento de agendamento de e-mail com monitora��o em log e lista de destinat�rios em pltable */
  procedure pc_solicita_email(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                             ,pr_cdprogra        IN VARCHAR2 --> Programa conectado
                             ,pr_tab_destino     IN gene0003.typ_tab_destinos --> Um ou mais detinat�rios na pltable
                             ,pr_des_assunto     IN VARCHAR2 --> Assunto do e-mail
                             ,pr_des_corpo       IN VARCHAR2 --> Corpo (conteudo) do e-mail
                             ,pr_des_anexo       IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                             ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                             ,pr_flg_remete_coop IN VARCHAR2 DEFAULT 'N' --> Se o envio ser� do e-mail da Cooperativa
                             ,pr_des_nome_reply  IN VARCHAR2 DEFAULT NULL--> Nome para resposta ao e-mail
                             ,pr_des_email_reply IN VARCHAR2 DEFAULT NULL --> Endere�o para resposta ao e-mail
                             ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                             ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                             ,pr_des_erro       OUT VARCHAR2);
  
  /* Procedimento de agendamento de e-mail sem monitora��o em log */
  procedure pc_solicita_email(pr_cdprogra    IN VARCHAR2 --> Programa conectado
                             ,pr_des_destino IN VARCHAR2 --> Um ou mais detinat�rios separados por ';' ou ','
                             ,pr_des_assunto IN VARCHAR2 --> Assunto do e-mail
                             ,pr_des_corpo   IN VARCHAR2 --> Corpo (conteudo) do e-mail
                             ,pr_des_anexo   IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                             ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                             ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                             ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                             ,pr_des_erro   OUT VARCHAR2);
  
  /* Procedimento para chamada da rotina de solicita��o de email via Progress */
  procedure pc_solicita_email_prog (pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                   ,pr_cdprogra        IN VARCHAR2 --> Programa conectado
                                   ,pr_des_destino     IN VARCHAR2 --> Um ou mais detinat�rios separados por ';' ou ','
                                   ,pr_des_assunto     IN VARCHAR2 --> Assunto do e-mail
                                   ,pr_des_corpo       IN VARCHAR2 --> Corpo (conteudo) do e-mail
                                   ,pr_des_anexo       IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                                   ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                                   ,pr_flg_remete_coop IN VARCHAR2 DEFAULT 'N' --> Se o envio ser� do e-mail da Cooperativa
                                   ,pr_des_nome_reply  IN VARCHAR2 DEFAULT NULL--> Nome para resposta ao e-mail
                                   ,pr_des_email_reply IN VARCHAR2 DEFAULT NULL --> Endere�o para resposta ao e-mail
                                   ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                                   ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                                   ,pr_des_erro       OUT VARCHAR2);
  
  /* Rotina Respons�vel pela conversao de programa unix para DOS e c�pia a converte */
  PROCEDURE pc_converte_arquivo(pr_cdcooper IN crapdev.cdcooper%TYPE           --> Cooperativa
                               ,pr_nmarquiv IN VARCHAR2                        --> Caminho e nome do arquivo a ser convertido
                               ,pr_nmarqenv IN VARCHAR2                        --> Nome desejado para o arquivo convertido
                               ,pr_des_erro IN OUT VARCHAR2);                  --> C�digo da Retorno do Erro
  
  /* Fun��o validadora do e-mail*/
  FUNCTION fn_valida_email(pr_dsdemail in varchar2) return pls_integer;
  
  /* Rotina para geracao de mensagens para o servico do site */
  PROCEDURE pc_gerar_mensagem(pr_cdcooper IN crapmsg.cdcooper%TYPE
                             ,pr_nrdconta IN crapmsg.nrdconta%TYPE
                             ,pr_idseqttl IN crapmsg.idseqttl%TYPE DEFAULT NULL
                             ,pr_cdprogra IN crapmsg.cdprogra%TYPE
                             ,pr_inpriori IN crapmsg.inpriori%TYPE
                             ,pr_dsdmensg IN crapmsg.dsdmensg%TYPE
                             ,pr_dsdassun IN crapmsg.dsdassun%TYPE
                             ,pr_dsdremet IN crapmsg.dsdremet%TYPE
                             ,pr_dsdplchv IN crapmsg.dsdplchv%TYPE
                             ,pr_cdoperad IN crapmsg.cdoperad%TYPE
                             ,pr_cdcadmsg IN crapmsg.cdcadmsg%TYPE
                             ,pr_dscritic OUT VARCHAR2);
  
  -- Rotina buscar conte�do das mensagens do iBank/SMS
  FUNCTION fn_buscar_mensagem(pr_cdcooper          IN tbgen_mensagem.cdcooper%TYPE
                             ,pr_cdproduto         IN tbgen_mensagem.cdproduto%TYPE
                             ,pr_cdtipo_mensagem   IN tbgen_mensagem.cdtipo_mensagem%TYPE
                             ,pr_sms               IN NUMBER DEFAULT 0 -- Indicador se mensagem � SMS (pois deve cortar em 160 caracteres)
                             ,pr_valores_dinamicos IN VARCHAR2 DEFAULT NULL) -- M�scara #Cooperativa#=1;#Convenio#=123
   RETURN tbgen_mensagem.dsmensagem%TYPE;
   
  -- Rotina para buscar conte�do das mensagens do iBank/SMS - utilizar no progress
  PROCEDURE pc_buscar_mensagem(pr_cdcooper         IN tbgen_mensagem.cdcooper%TYPE
                             ,pr_cdproduto         IN tbgen_mensagem.cdproduto%TYPE
                             ,pr_cdtipo_mensagem   IN tbgen_mensagem.cdtipo_mensagem%TYPE
                             ,pr_sms               IN NUMBER DEFAULT 0 -- Indicador se mensagem � SMS (pois deve cortar em 160 caracteres)
                             ,pr_valores_dinamicos IN VARCHAR2 DEFAULT NULL -- M�scara #Cooperativa#=1;#Convenio#=123
                             ,pr_dsmensagem       OUT tbgen_mensagem.dsmensagem%TYPE); 

END gene0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.gene0003 AS

  /*..............................................................................

    Programa: GENE0003 ( Antigo b1wgen0011.p )
    Autor   : David
    Data    : Agosto/2006                     Ultima Atualizacao: 24/07/2018

    Dados referentes ao programa:

    Objetivo  : BO para envio de e-mail.

    Alteracoes: 23/11/2006 - Acerto no envio de email quando existir mais de
                             um arquivo para anexo (David).

                23/07/2007 - Modificada mensagem do e-mail para os programas
                             crps217 e crps488 (Diego).

                03/09/2007 - Alterada mensagem de e-mail para informativos
                             (Diego).

                01/11/2007 - Nao logar envio de informativos (Diego).

                20/10/2008 - Tratamento diferenciado na hora de enviar
                             alguns programas do progrid (Gabriel).

                14/11/2008 - Incluir procedure enviar_email_completo
                             (Guilherme).

                26/12/2008 - Alteracao de mtsend.pl para gnusend.pl (Julio)

                23/01/2009 - Incluir condicao para gravar log na procedure
                             enviar_email_completo (David).

                03/02/2009 - Em caso de anexo em branco fechar com ' o
                             parametro do gnusend.pl
                           - procedure enviar_email_completo envia + de 1 anexo
                             (Guilherme).

                17/03/2009 - Criar arquivo com e-mails enviados utilizando em
                             casos de problemas de envio nos processos (David).

                08/05/2009 - Incluida na linha de comando do gnusend.pl o re-
                             direcionamento da saida padrao e de erro (Edson).

                30/08/2010 - Incluido caminho completo no destino dos arquivos
                             de log (Elton).

                27/04/2011 - Emails enviados a partir dos programas crps507
                             e crps395 ter�o remetente rosangela@cecred.coop.br
                             (Irlan).

                13/05/2011 - Nova procedure enviar_email_spool. (Irlan)

                08/11/2011 - Mudanca na descricao dos campos dos email quando
                             informativos (Gabriel).

                10/02/2012 - Nao registrar envio de e-mail no log do processo
                             batch para programas definidos na variavel
                             aux_lsprglog (David).

                02/04/2012 - Alterado diretorio do SpoolMail (Irlan)

                30/08/2012 - Substituido crapcop.nmrescop por crapcop.dsdircop
                             no arquivo "aux_nmarqctg" (Diego).

                29/11/2012 - Convers�o das rotinas de E-mail de Progress > PLSQL
                             (Marcos - Supero)

                03/03/2016 - Adicionado replace no Subject da pc_envia_email pois estava cortando o assunto pela
                             metade, o motivo era que a funcao quebrava linha e nao mostrava o
                             texto completo (Lucas Ranghetti #410456)                             
                             
                21/09/2016 - #523938 Cria��o de log de controle de in�cio, erros e fim de execu��o
                             do job pc_process_email_penden (Carlos)
                             
                26/10/2016 - Logada a execu��o do procedimento pc_process_email_penden apenas quando
                             existirem emails pendentes de envio  (Carlos)
                             
                20/01/2017 - Alteracao na procedure pc_solicita_email para gravacao do log de envio de
                             boletos por e-mail no arquivo PROC_MESSAGE. SD 579741 (Carlos Rafael Tanholi).             
                             
                13/02/2017 - #605926 Inclu�da a valida��o de e-mail no procedimento pc_solicita_email para n�o 
                             inserir e-mails inv�lidos na tabela crapsle; Procedimento pc_process_email_penden
                             atualizado para o novo log pc_log_programa (Carlos)
                             
                21/02/2017 - #584244 Atualizada a rotina pc_process_email_penden para n�o gravar mais os erros
                             de envio no proc_batch, apenas no log proc_envio_email (Carlos)
                             
                19/06/2017 - #642644 Ajustada a rotina pc_solicita_email para gravar a mensagem de 
                             "email enviado" no proc_message, inclusive no ELSE dos anexos (Carlos)

                17/10/2017 - Ajuste na pc_gerar_mensagem para n�o obrigar mais o idseqttl, se este vier nulo, ent�o
                             o o programa vai percorrer todos os usu�rios da conta no ibank (Pabl�o)
                             
                06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
                           - Padroniza��o erros comandos DDL
                           - Pc_set_modulo, cecred.pc_internal_exception
                           - Tratamento erros others
                             Chamado 788828 - Ana Volles (Envolti)

               12/12/2017 - Ajuste na substituicao de caracteres especiais na mensagem enviada. Estava ocasionando problemas
                             na leitura dessas mensagens na Conta Online.
                             Heitor (Mouts) - Chamado 807108

               21/05/2018 - Altera��o no tamanho da variavel de controle de anexos, de VARCHAR2 500 para 4000 
                             Belli (Envolti) - Chamado REQ0014900
                             
               24/07/2018 - Tratar estouro do limite de caracteres do conte�do de e-mail.
                             Belli (Envolti) - Chamado REQ0021124

..............................................................................*/

  /* Sa�da com erro */
  vr_des_erro   VARCHAR2(4000);
  vr_exc_erro   EXCEPTION;
  vr_cdcritic   crapcri.cdcritic%type := 0;
  vr_dscritic   crapcri.dscritic%type := NULL;
  vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;

  -- Busca de informa��es da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdemail
          ,cop.nmrescop
          ,cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Tipo registros e tabela para montar a lista de anexos
  TYPE typ_reg_anexos IS RECORD 
    (dspathan VARCHAR2(4000)
    ,nrseqsol NUMBER);
  TYPE typ_tab_anexos IS
    TABLE OF typ_reg_anexos
      INDEX BY BINARY_INTEGER;
      
  -- Tipo gen�rico para montar listas
  TYPE typ_tab_listas IS
    TABLE OF VARCHAR2(4000)
      INDEX BY BINARY_INTEGER;      

  /* Incluir log de execu��o de e-mail. */
  PROCEDURE pc_gera_log_email(pr_cdcooper IN crapcop.cdcooper%TYPE --> Coop conectada
                             ,pr_des_log IN VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_log_email
    --  Sistema  : Processos Gen�ricos
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 06/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia:
    --   Objetivo  : Prever m�todo centralizado de log de E-mails
    --
    --   Alteracoes: 31/10/2013 - Troca do arquivo de log para salvar a partir
    --                            de agora no diret�rio log das Cooperativas (Marcos-Supero)
    --
    --            06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                       - Padroniza��o erros comandos DDL
    --                       - Pc_set_modulo, cecred.pc_internal_exception
    --                       - Tratamento erros others
    --                         Chamado 788828 - Ana Volles (Envolti)
    -- .............................................................................

    DECLARE
      vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
      vr_cdcritic    INTEGER;
      vr_des_erro    VARCHAR2(4000); -- Descri��o de erro
      vr_exc_saida   EXCEPTION; -- Sa�da com exception
      vr_des_complet VARCHAR2(100);
      vr_des_diretor VARCHAR2(100);
      vr_des_arquivo VARCHAR2(100);
    BEGIN
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_gera_log_email');

      -- Busca o diret�rio de log da Cooperativa
      vr_des_complet := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'log');
      -- Buscar o nome de arquivo de log cfme par�metros de sistema, se n�o vier nada, usa o default
      vr_des_complet := vr_des_complet || '/' || NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MAIL'),'proc_envio_email.log');
      -- Separa o diret�rio e o nome do arquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_des_complet
                                     ,pr_direto  => vr_des_diretor
                                     ,pr_arquivo => vr_des_arquivo);

      -- Tenta abrir o arquivo de log em modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_des_diretor    --> Diret�rio do arquivo
                              ,pr_nmarquiv => vr_des_arquivo      --> Nome do arquivo
                              ,pr_tipabert => 'A'              --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arqlog    --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);

        -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_gera_log_email');
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Adiciona a linha de log
      BEGIN
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,pr_des_log);

        -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_gera_log_email');
      EXCEPTION
        WHEN OTHERS THEN
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_cdcritic := 1044;
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;

          -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
          RAISE vr_exc_saida;
      END;

      -- Libera o arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);

        -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_gera_log_email');
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro
          vr_cdcritic := 1039;
          vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;

          -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
          RAISE vr_exc_saida;
      END;

      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
        gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - '|| 'GENE0003.pc_gera_log_email --> '||vr_des_erro);

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'JBEMAIL_PROCESS_PENDENTES',
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 1, -- erro tratado
                               pr_cdcriticidade => 1, -- media
                               pr_cdmensagem    => nvl(vr_cdcritic,0),
                               pr_dsmensagem    => vr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

      WHEN OTHERS THEN
        -- Temporariamente apenas imprimir na tela
        vr_cdcritic := 9999;
        vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_gera_log_email. '||sqlerrm;

        gene0001.pc_print(pr_des_mensag => to_char(sysdate,'hh24:mi:ss')||' - '
                                           || 'GENE0003.pc_gera_log_email'
                                           || ' --> ' ||gene0001.fn_busca_critica(vr_cdcritic)|| sqlerrm);

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'JBEMAIL_PROCESS_PENDENTES',
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 2, -- erro nao tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => nvl(vr_cdcritic,0),
                               pr_dsmensagem    => vr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END;
  END pc_gera_log_email;

  /* Procedimento que separa as informa��e enviadas com ';' para um vetor */
  PROCEDURE pc_separa_lista(pr_des_orige  IN VARCHAR2
                           ,pr_tab_lista OUT gene0003.typ_tab_listas) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_separa_lista
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 06/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Este procedimento varre a String passada e separa os nomes
    --               �nicos presentes na listagem e separados por ';' ou ',' para o vetor
    --
    --   Alteracoes: 28/05/2014 - Remover inicializa��o da pltable pois houve mudan�a
    --                            na tipagem (Marcos-Supero)
    --
    --            06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                       - Padroniza��o erros comandos DDL
    --                       - Pc_set_modulo, cecred.pc_internal_exception
    --                       - Tratamento erros others
    --                         Chamado 788828 - Ana Volles (Envolti)
    -- .............................................................................
    DECLARE
      -- String tempor�ria
      vr_des_orige VARCHAR2(32000);
      -- Guardar posi��o do ;
      vr_pos INTEGER;
      vr_cdcritic  INTEGER;
      vr_dscritic  VARCHAR2(4000);
    BEGIN
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_separa_lista');

      -- Copia para a tempor�ria a string passada
      vr_des_orige := pr_des_orige;
      -- Troca todas as virgulas por ponto e virgula, para facilitar as buscas abaixo
      vr_des_orige := REPLACE(vr_des_orige,',',';');
      -- Repetir at� n�o existir mais ';'
      LOOP
        -- Procura a posi��o do primeiro ;
        vr_pos := INSTR(vr_des_orige,';');
        -- Sair quando n�o encontrar mais o ';'
        EXIT WHEN nvl(vr_pos,0) = 0;
        -- Copiar a informa��o at� o ';' para o vetor caso exista algo
        IF length(TRIM(SUBSTR(vr_des_orige,1,vr_pos-1))) > 0 THEN
          pr_tab_lista(pr_tab_lista.COUNT) := TRIM(SUBSTR(vr_des_orige,1,vr_pos-1));
        END IF;
        -- Remove da string as informa��es copiadas
        vr_des_orige := nvl(substr(vr_des_orige,vr_pos+1),' ');
      END LOOP;
      -- Remove algum poss�vel ; no final ou no in�cio
      vr_des_orige := TRIM(LTRIM(RTRIM(vr_des_orige,';'),';'));
      -- Adiciona na lista o restante da informa��o que ficou presente
      IF length(vr_des_orige) > 0 THEN
        pr_tab_lista(pr_tab_lista.COUNT) := vr_des_orige;
      END IF;
    END;

    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      --Tratamento de mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_separa_lista. '||sqlerrm;

      -- Log de erro de execucao
      cecred.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => 'GENE000.PC_SEPARA_LISTA3',
                             pr_cdcooper      => 3, 
                             pr_tpexecucao    => 0, -- Outros
                             pr_tpocorrencia  => 2, -- erro nao tratado
                             pr_cdcriticidade => 2, -- alta
                             pr_cdmensagem    => nvl(vr_cdcritic,0),
                             pr_dsmensagem    => vr_dscritic,
                             pr_flgsucesso    => 0,
                             pr_idprglog      => vr_idprglog);

      -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
      CECRED.pc_internal_exception;
  END pc_separa_lista;

  /* Procedimento para envio de e-mail solicitado */
  PROCEDURE pc_envia_email(pr_nrseqsol  IN crapsle.nrseqsol%TYPE
                          ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_envia_email     Antiga sistema/generico/procedures/b1wgen0011.p >> envia_email_completo
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 13/06/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina processa a solicita�ao de e-mail passada e efetua seu envio
    --
    --   Alteracoes: 13/05/2013 - Inclus�o de envio do nome e e-mail de resposta (Reply-to) - Marcos/Supero
    --
    --               13/05/2013 - Gerar Envia*.SH no diretorio "converte" conforme no progress
    --
    --               26/11/2013 - N�o Gerar Envia*.SH no diretorio "converte" caso n�o for informado a cooperativa
    --
    --               10/02/2014 - Nao registrar em logo envio de email referente
    --                            a monitoracao de pagamentos (David).
    --
    --               26/05/2014 - Simplifica��o dos par�metros de teste cfme base, pois n�o teremos
    --                            mais um para cada base, mas somente um gen�rico (Marcos-Supero)
    --
    --               28/05/2014 - Mudan�a na vincula��o dos anexos ao e-mail, agora prevendo
    --                            a tabela associativa CRAPSLV (Marcos-Supero)
    --
    --               11/01/2015 - Alterado forma de incluir NRSEQSOL na mensagem do rodape 
    --                            SD356863 (Odirlei-AMcom)
    --
    --               03/03/2016 - Adicionado replace no Subject pois estava cortando o assunto pela
    --                            metade, o motivo era que a funcao quebrava linha e nao mostrava o
    --                            texto completo (Lucas Ranghetti #410456)
    --                            na tipagem (Marcos-Supero)
    --
    --            06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                       - Padroniza��o erros comandos DDL
    --                       - Pc_set_modulo, cecred.pc_internal_exception
    --                       - Tratamento erros others
    --                         Chamado 788828 - Ana Volles (Envolti)
    --
    --            13/06/2018 - Sincronizar o horario do email com o horario do servidor que hoje se encontra
    --                         divergente. (Kelvin/Saqueta).
    -- .............................................................................

    DECLARE
      -- Busca das informa�oes do e-mail solicitado
      CURSOR cr_crapsle IS
        SELECT sle.cdcooper
              ,sle.cdprogra
              ,sle.dsendere
              ,sle.dsassunt
              ,sle.dscorpoe
              ,sle.dsanexos
              ,sle.flremcop
              ,sle.dsnmrepl
              ,sle.dsemrepl
          FROM crapsle sle
         WHERE sle.nrseqsol = pr_nrseqsol;
      rw_crapsle cr_crapsle%ROWTYPE;
      /* Leitura dos anexos do e-mail */
      CURSOR cr_crapsla IS
        SELECT sla.dspathan
              ,sla.dsnmarqv
              ,sla.blobanex
              ,sla.qttamane
              ,COUNT(1) OVER() AS qtdanexos
              ,rownum
          FROM crapslv slv
              ,crapsla sla
         WHERE slv.nrseqsle = pr_nrseqsol
           AND slv.nrseqsla = sla.nrseqsol
           AND sla.qttamane > 0 --> Somente BLOBs com algum Byte
         ORDER BY slv.nrseqsla;
      /* Configura��o para envio do e-mail */
      vr_porta_smtp INTEGER;
      vr_domain     VARCHAR2(255);
      vr_host_smtp  VARCHAR2(255);
      vr_des_nome   VARCHAR2(255);
      vr_des_remete VARCHAR2(255);
      vr_des_senha  VARCHAR2(50);
      vr_des_quebra VARCHAR2(2)  := UTL_TCP.crlf;
      -- Variaveis auxiliares para montagem do e-mail
      vr_des_limite CONSTANT VARCHAR2(255) := sys_guid();
      vr_conexao    UTL_SMTP.CONNECTION;
      vr_dscorpoe   crapsle.dscorpoe%TYPE;
      vr_dsnmrepl   crapsle.dsnmrepl%TYPE;
      vr_dsemrepl   crapsle.dsemrepl%TYPE;
      --String com os anexos para gravar no .SH
      vr_dsanexos varchar2(4000); -- Aumento do tamanho de 500 para 4000 - Chamado REQ0014900 - 21/05/2018
      --Variavel para montar o comando que ser� salvo no .SH
      vr_dscomdSH varchar2(10000);
      --Diretorio da cooperativa para manter os anexos
      vr_direconv varchar2(100);
      --Variavel para arquivo de dados
      vr_input_file utl_file.file_type;
      -- Vari�veis para trabalhar com os anexos
      vr_pos_bytes    INTEGER;
      vr_buffer       RAW ( 32767 );
      vr_amount_read  PLS_INTEGER := 57; --> Tamanho m�ximo quea UTL_SMTP aceita para WriteRaw (N�o mudar)
    begin
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_envia_email');

      -- Busca das informa�oes do e-mail solicitado
      OPEN cr_crapsle;
      FETCH cr_crapsle
       INTO rw_crapsle;
      -- Somente se encontrar
      IF cr_crapsle%FOUND THEN
        -- Fechar o cursor para continuar
        CLOSE cr_crapsle;
        -- Buscar parametros para o envio
        vr_porta_smtp := gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'SMTP_PORT');
        vr_domain     := gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'SMTP_DOMAIN');
        vr_host_smtp  := gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'SMTP_SERVER');
        vr_des_nome   := gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'SMTP_USER_NAME');
        vr_des_remete := gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'SMTP_USER');
        vr_des_senha  := gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'SMTP_PASSWD');

        -- Buscar nome e e-mail da Cooperativa
        OPEN cr_crapcop(pr_cdcooper => rw_crapsle.cdcooper);
        FETCH cr_crapcop
         INTO rw_crapcop;
        CLOSE cr_crapcop;

        -- Busca do diret�rio base da cooperativa
        vr_direconv := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                            ,pr_cdcooper => rw_crapsle.cdcooper
                                            ,pr_nmsubdir => '/converte');

        -- Se foi solicitado o envio pelo e-mail da Cooperativa
        IF rw_crapsle.flremcop = 'S' THEN
          -- Substitui o remetente e nome padr�o pelo da cooperativa
          vr_des_remete := NVL(rw_crapcop.dsdemail,vr_des_remete);
          vr_des_nome   := NVL(rw_crapcop.nmrescop,vr_des_nome);
        END IF;
        -- Prever envio de nome para resposta(Reply-To)
        IF trim(rw_crapsle.dsnmrepl) IS NOT NULL THEN
          -- Utiliz�-lo
          vr_dsnmrepl := rw_crapsle.dsnmrepl;
        ELSE
          -- Utilizar o nome do remetente
          vr_dsnmrepl := vr_des_nome;
        END IF;
        -- Prever envio de e-mail para resposta(Reply-To)
        IF trim(rw_crapsle.dsemrepl) IS NOT NULL THEN
          -- Utiliz�-lo
          vr_dsemrepl := rw_crapsle.dsemrepl;
        ELSE
          -- Utilizar o nome do remetente
          vr_dsemrepl := vr_des_remete;
        END IF;
        -- Abre conex�o
        vr_conexao  := utl_smtp.open_connection(vr_host_smtp,vr_porta_smtp);
        utl_smtp.helo (vr_conexao,vr_domain);
        -- Se foi enviado usu�rio e senha para login do SMPT
        IF trim(vr_des_remete) IS NOT NULL AND trim(vr_des_senha) IS NOT NULL THEN
          utl_smtp.command(vr_conexao, 'AUTH LOGIN');
          utl_smtp.command(vr_conexao,UTL_RAW.CAST_TO_VARCHAR2(utl_encode.base64_encode(utl_raw.cast_to_raw(vr_des_remete))));
          utl_smtp.command(vr_conexao,UTL_RAW.CAST_TO_VARCHAR2(utl_encode.base64_encode(utl_raw.cast_to_raw(vr_des_senha))));
        END IF;
        -- Enviar o e-mail para o destinat�rio
        utl_smtp.mail(vr_conexao, '<'||vr_des_remete||'>' );
        
        -- Somente enviar para o email correto em produ��o, outras bases ir�o usar o e-mail configurado para testes
        IF gene0001.fn_database_name = gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'DB_NAME_PRODUC') THEN --> Produ��o
          -- Usar o email de destino
          utl_smtp.rcpt( vr_conexao, '<'|| rw_crapsle.dsendere ||'>' );
        ELSE
          -- Usar o email de teste cadastrado nos par�metros
          utl_smtp.rcpt( vr_conexao, '<'|| gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'EMAIL_TESTE') ||'>' );
        END IF;
        
        -- Montar corpo incluindo a mensagem padr�o do sistema
        vr_dscorpoe := rw_crapsle.dscorpoe || '<br><br>' || replace(gene0001.fn_param_sistema('CRED',rw_crapsle.cdcooper,'MSG_RODAPE_EMAIL'),'##NRSEQSOL##', pr_nrseqsol);
        
        -- Incluir log do destin�rio somente em alguns casos espec�ficos
        IF upper(rw_crapsle.cdprogra) <> 'ATENDA'      AND
           upper(rw_crapsle.cdprogra) <> 'B1WNET0002'  AND
           upper(rw_crapsle.dsendere) <> 'MONITORACAODEFRAUDES@AILOS.COOP.BR' THEN
          -- Envia log com o destinat�rio
          pc_gera_log_email(rw_crapsle.cdcooper,to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '|| rw_crapsle.cdprogra || ' --> Coop: '||rw_crapsle.cdcooper||' --> Enviando solicita��o de e-mail n� '||pr_nrseqsol||' para '||rw_crapsle.dsendere||'.');
          -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_envia_email');
        END IF;

        -- Abrir conex�o de dados
        utl_smtp.open_data(vr_conexao);
        -- Enviar header
        utl_smtp.write_data(vr_conexao, 'Date: ' || TO_CHAR(to_timestamp_tz(to_char(CAST(current_timestamp AT TIME ZONE 'AMERICA/SAO_PAULO' AS timestamp),'ddmmyyyyhh24miss')||' AMERICA/SAO_PAULO','ddmmyyyyhh24miss TZR'), 'DD-MON-YYYY HH24:MI:SS') || vr_des_quebra);
        utl_smtp.write_data(vr_conexao, 'MIME-Version: 1.0' || vr_des_quebra);
        utl_smtp.write_data(vr_conexao, 'To: ' || rw_crapsle.dsendere || vr_des_quebra);
        utl_smtp.write_data(vr_conexao, 'From: ' || vr_des_nome || ' <' || vr_des_remete ||'>'|| vr_des_quebra);
        utl_smtp.write_data(vr_conexao, 'Reply-To: ' || vr_dsnmrepl || ' <'||vr_dsemrepl||'>'|| vr_des_quebra);
        utl_smtp.write_data(vr_conexao, 'Subject: ' || replace(UTL_ENCODE.mimeheader_encode(rw_crapsle.dsassunt),UTL_TCP.CRLF, UTL_TCP.CRLF || ' ') || vr_des_quebra);
        utl_smtp.write_data(vr_conexao, 'Content-Type: multipart/mixed; boundary="'||vr_des_limite||'"'|| vr_des_quebra || vr_des_quebra);
        -- Envia  mensagem HTML
        utl_smtp.write_data(vr_conexao, '--' || vr_des_limite || vr_des_quebra);
        utl_smtp.write_data(vr_conexao, 'Content-Type: text/html; charset="iso-8859-1"' || vr_des_quebra || vr_des_quebra);
        utl_smtp.write_data(vr_conexao, GENE0007.fn_acento_xml(vr_dscorpoe) );
        utl_smtp.write_data(vr_conexao, vr_des_quebra || vr_des_quebra);
        -- Adicionando anexos em caso de existir
        FOR rw_crapsla IN cr_crapsla LOOP
          -- Inicia o envio do anexo
          utl_smtp.write_data(vr_conexao, '--' || vr_des_limite || vr_des_quebra);
          utl_smtp.write_data(vr_conexao,'Content-Type: application/octet-stream' || vr_des_quebra);
          utl_smtp.write_data(vr_conexao,'Content-Disposition: attachment; filename="' || rw_crapsla.dsnmarqv || '"' || vr_des_quebra);
          utl_smtp.write_data(vr_conexao,'Content-Transfer-Encoding: base64' || vr_des_quebra||vr_des_quebra);
          -- Posi��o inicial de leitura
          vr_pos_bytes := 1;
          vr_amount_read := 57; --> Tamanho m�ximo que a UTL_SMTP aceita para WriteRaw (N�o mudar)
          /* Escreve o BLOB em por��es */
          WHILE vr_pos_bytes <= rw_crapsla.qttamane LOOP
            -- Se estiver no final
            IF vr_pos_bytes + vr_amount_read - 1 > rw_crapsla.qttamane THEN
              -- Le a diferen�a que falta
              vr_amount_read := rw_crapsla.qttamane-vr_pos_bytes+1;
            END IF;
            -- Le do blob a quantidade
            DBMS_LOB.READ(rw_crapsla.blobanex,vr_amount_read,vr_pos_bytes,vr_buffer);
            -- Envia ao SMTP os bytes lidos
            utl_smtp.write_raw_data(vr_conexao,UTL_ENCODE.BASE64_ENCODE(vr_buffer));
            utl_smtp.write_data(vr_conexao,vr_des_quebra);
            -- Incrementa a nova posi��o a ler do blob
            vr_pos_bytes := vr_pos_bytes + vr_amount_read;
          END LOOP;
          utl_smtp.write_data(vr_conexao, vr_des_quebra || vr_des_quebra );
          -- Envia log com o nome do arquivo e o destinat�rio
          pc_gera_log_email(rw_crapsle.cdcooper,to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' - '|| rw_crapsle.cdprogra || ' --> '||rw_crapsla.dspathan||'/'||rw_crapsla.dsnmarqv||' ENVIADO PARA '||rw_crapsle.dsendere||'.');
          -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_envia_email');

          IF rw_crapsla.rownum = 1 THEN
            -- Inicializar variavel
            vr_dsanexos     := '--anexo=''';
          END IF;

          --Acrescentar anexos na string
          vr_dsanexos := vr_dsanexos||vr_direconv||'/'||rw_crapsla.dsnmarqv;

          IF rw_crapsla.rownum < rw_crapsla.qtdanexos THEN
            vr_dsanexos := vr_dsanexos||';';
          ELSE
            vr_dsanexos := vr_dsanexos||'''';
          END IF;

        END LOOP;
        -- Fechar Email
        utl_smtp.write_data(vr_conexao, '--' || vr_des_limite || '--' || vr_des_quebra );
        utl_smtp.close_data(vr_conexao);
        utl_smtp.quit(vr_conexao);

        --Gerar Envia*.SH no diretorio converte conforme no progress
        IF rw_crapsle.cdprogra not in ('WPGD0014','WPGD0020','WPGD0026B','CRPS217') AND
           NVL(rw_crapsle.cdcooper,0) <> 0 THEN

          --Gerar comando
          vr_dscomdSH := 'gnusend.pl --para='''||rw_crapsle.dsendere||''''||
                                ' --assunto='''||rw_crapsle.dsassunt||''''||
                                '   --corpo='''||replace(vr_dscorpoe,'<br>','\n')||''''||
                                ' --de_nome='''||vr_des_nome||''''||
                                '      --de='''||vr_des_remete||''''||
                              ' --responder='''||vr_dsemrepl||''''||
                              vr_dsanexos||
                              ' > /dev/null 2> /dev/null &';

          -- Tenta abrir o arquivo de dados em modo gravacao
          gene0001.pc_abre_arquivo(pr_nmdireto => vr_direconv    --> Diret�rio do arquivo
                                  ,pr_nmarquiv => 'envia_'||lower(rw_crapcop.dsdircop)||'.sh'    --> Nome do arquivo
                                  ,pr_tipabert => 'A'            --> Modo de abertura (R,W,A)
                                  ,pr_utlfileh => vr_input_file  --> Handle do arquivo aberto
                                  ,pr_des_erro => vr_des_erro);  --> Erro
          IF vr_des_erro IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
          -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_envia_email');

          --Escrever o cabecalho no arquivo
          gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file             --> Handle do arquivo aberto
                                        ,pr_des_text  => vr_dscomdSH);  --> Texto para escrita

          -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_envia_email');

          --Fechar Arquivo dados
          BEGIN
            gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;
          EXCEPTION
            WHEN OTHERS THEN
            -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
            vr_des_erro := gene0001.fn_busca_critica(1039)||' <'||vr_direconv||'/'||'envia_'||lower(rw_crapcop.dsdircop)||'.sh' ||'>: ' || sqlerrm;

            -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
            CECRED.pc_internal_exception;                                                          
            RAISE vr_exc_erro;
          END;

        END IF;

      ELSE
        -- Fechar o cursor
        CLOSE cr_crapsle;
      END IF;

      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN --> Erro tratado
        BEGIN
          utl_smtp.quit( vr_conexao );
        EXCEPTION
          WHEN OTHERS THEN
            -- Apenas tratar pra sempre tentar fechar
            NULL;
        END;
        -- Concatenar o erro previamente montado e retornar
        vr_cdcritic := 1046;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' <'||rw_crapsle.dsendere||'> --> ' || vr_des_erro;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_ENvIA_EMAIL',
                               pr_cdcooper      => 3, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 1, -- erro nao tratado
                               pr_cdcriticidade => 1, -- alta
                               pr_cdmensagem    => nvl(vr_cdcritic,0),
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

      WHEN OTHERS THEN -- Gerar log de erro
        BEGIN
          utl_smtp.quit( vr_conexao );
        EXCEPTION
          WHEN OTHERS THEN
            -- Apenas tratar pra sempre tentar fechar
            NULL;
        END;
        -- Retornar o erro contido na sqlerrm
        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_envia_email. '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_ENvIA_EMAIL',
                               pr_cdcooper      => 3, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 2, -- erro nao tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => nvl(vr_cdcritic,0),
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        CECRED.pc_internal_exception;                                                       
    END;
  END pc_envia_email;

  /* Procedimento que processa os emails pendentes e chama seu envio */
  PROCEDURE pc_process_email_penden(pr_nrseqsol  IN crapsle.nrseqsol%TYPE DEFAULT NULL
                                   ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_process_email_penden
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 06/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina processa tem as seguintes funcionalidades:
    --               1 - Limpar solicita��es de e-mail antigas
    --               2.1 - Processar as <n> ultimas solicita��es pendentes e chamar seu envio
    --               2.2 - Processar somente a solicita�ao passada
    --               3 - Enviar para o log geral os erros encontrados
    --   Obs: A rotina nao para � provcesso em caso de erro na solicita�ao, pois todas devem ser processadas
    --
    --   Alteracoes: 28/05/2014 - Mudan�a na vincula��o dos anexos ao e-mail, agora prevendo
    --                            a tabela associativa CRAPSLV (Marcos-Supero)
    --                            na tipagem (Marcos-Supero)
    --
    --            06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                       - Padroniza��o erros comandos DDL
    --                       - Pc_set_modulo, cecred.pc_internal_exception
    --                       - Tratamento erros others
    --                         Chamado 788828 - Ana Volles (Envolti)
    -- .............................................................................
    DECLARE
      -- Guardar quantidade de dias a manter os emails
      vr_qtddiaemail NUMBER;
      -- Quantidade de de emails a processar no Job
      vr_qtdemailjob NUMBER;
      -- Busca dos e-mails pendentes de envio
      CURSOR cr_crapsle IS
        SELECT sle.cdcooper
              ,sle.nrseqsol
          FROM crapsle sle
         WHERE sle.flenviad ='N' --> Ainda n�o enviado
           AND trim(sle.dserrenv) IS NULL --> Sem erros
           AND ROWNUM <= vr_qtdemailjob --> Somente qtde parametrizada por Job
         ORDER BY sle.nrseqsol; --> Os mais antigos primeiro

      vr_cdprogra    VARCHAR2(40) := 'PC_PROCESS_EMAIL_PENDEN';
      vr_nomdojob    VARCHAR2(40) := 'JBEMAIL_PROCESS_PENDENTES';
      vr_flgerlog    BOOLEAN := FALSE;
      vr_idprglog    tbgen_prglog.idprglog%TYPE := 0;

      --> Controla log proc_batch, para apenas exibir qnd realmente processar informa��o
      PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' in�cio; 'F' fim; 'E' erro
                                      pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_controla_log_batch');
        --> Controlar gera��o de log de execu��o dos jobs 
        BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                                 ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                                 ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                                 ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                                 ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                                 ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
        -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
      END pc_controla_log_batch;

    BEGIN
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_process_email_penden');

      -- Se estiver rodando no processo automatizado
      IF pr_nrseqsol IS NULL THEN

        -- Buscar quantidade de dias que os emails devem ficar armazenados
        BEGIN
          vr_qtddiaemail := NVL(gene0001.fn_param_sistema('CRED',0,'DIAS_ARQUIVO_EMAIL'),7);
        EXCEPTION
          WHEN OTHERS THEN
            -- Ocorreu erro pq o parametros nao era number, ent�o usar qtde padrao (7)
            vr_qtddiaemail := 7;
        END;

        -- Efetuar limpeza das tabelas de e-mais e anexos
        BEGIN
          BEGIN
          -- Eliminar vinculos de e-mails com data inferior aos dias parametrizados
            DELETE FROM crapslv slv
           WHERE EXISTS(SELECT 1
                          FROM crapsle sle
                         WHERE sle.nrseqsol = slv.nrseqsle
                           AND sle.dtsolici < TRUNC(SYSDATE) - vr_qtddiaemail
                           AND sle.flenviad = 'S');
          EXCEPTION
            WHEN OTHERS THEN
              pr_des_erro := gene0001.fn_busca_critica(1037)||'crapslv: '||
                             'com dtsolici:'||SYSDATE ||'-'|| vr_qtddiaemail||
                             ', flenviad:S. '||sqlerrm;
              -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
              CECRED.pc_internal_exception;                                                            
          END;
          BEGIN
          -- Eliminar anexos de e-mails com data inferior aos dias parametrizados
            DELETE FROM crapsla sla
           WHERE EXISTS(SELECT 1
                          FROM crapsle sle
                         WHERE sle.nrseqsol = sla.nrseqsol
                           AND sle.dtsolici < TRUNC(SYSDATE) - vr_qtddiaemail
                           AND sle.flenviad = 'S');
          EXCEPTION
            WHEN OTHERS THEN
              pr_des_erro := gene0001.fn_busca_critica(1037)||'crapsla: '||
                             'com dtsolici:'||TRUNC(SYSDATE) - vr_qtddiaemail||
                             ', flenviad:S. '||sqlerrm;

              -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
              CECRED.pc_internal_exception;                                                        
          END;
          BEGIN
          -- Eliminar emails com data inferior aos dias parametrizados
            DELETE FROM crapsle sle
           WHERE sle.dtsolici < TRUNC(SYSDATE) - vr_qtddiaemail
             AND sle.flenviad = 'S';
        EXCEPTION
          WHEN OTHERS THEN
              pr_des_erro := gene0001.fn_busca_critica(1037)||'crapsle: '||
                             'com dtsolici:'||TRUNC(SYSDATE) - vr_qtddiaemail||
                             ', flenviad:S. '||sqlerrm;

              -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
              CECRED.pc_internal_exception;                                            
          END;

          IF pr_des_erro IS NOT NULL THEN
            -- Log de erro de execucao          
            cecred.pc_log_programa(pr_dstiplog      => 'E', 
                                   pr_cdprograma    => vr_nomdojob, 
                                   pr_cdcooper      => 3, 
                                   pr_tpexecucao    => 0, -- Outros
                                   pr_tpocorrencia  => 2, -- erro nao tratado
                                   pr_cdcriticidade => 2, -- normal
                                   pr_cdmensagem    => 1037,  
                                   pr_dsmensagem    => pr_des_erro,
                                   pr_flgsucesso    => 0,
                                   pr_idprglog      => vr_idprglog);

            -- Log de erro de execucao por email
            pc_gera_log_email(0,to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '||gene0001.fn_busca_critica(1045)
            ||sqlerrm||'.');

            CECRED.pc_internal_exception;                              
          END IF;

        END;
        -- Buscar quantidade de e-mails a processar no Job
        BEGIN
          vr_qtdemailjob := NVL(gene0001.fn_param_sistema('CRED',0,'QTDE_EMAIL_POR_JOB'),500);
        EXCEPTION
          WHEN OTHERS THEN
            -- Ocorreu erro pq o parametros nao era number, ent�o usar qtde padrao (500)
            vr_qtdemailjob := 500;

            -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
            CECRED.pc_internal_exception;                                   
        END;

        -- Busca de todos os emails pendentes de envio
        FOR rw_crapsle IN cr_crapsle LOOP
          
          -- Log de inicio de execucao
          pc_controla_log_batch(pr_dstiplog => 'I');
          -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_process_email_penden');
                    
          -- Chamar o envio
          pc_envia_email(pr_nrseqsol => rw_crapsle.nrseqsol
                        ,pr_des_erro => vr_des_erro);
          -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_process_email_penden');

          -- Atualizar o registro como processado
          BEGIN
            UPDATE crapsle
               SET flenviad = 'S'
                  ,dserrenv = vr_des_erro
             WHERE nrseqsol = rw_crapsle.nrseqsol
               AND flenviad = 'N';

          -- Se houve erro
          IF trim(vr_des_erro) IS NOT NULL THEN
            -- Log de erro de execucao
              cecred.pc_log_programa(pr_dstiplog      => 'E', 
                                     pr_cdprograma    => vr_nomdojob, 
                                     pr_cdcooper      => 3, 
                                     pr_tpexecucao    => 0, -- Outros
                                     pr_tpocorrencia  => 1, -- erro nao tratado
                                     pr_cdcriticidade => 1, -- normal
                                     pr_cdmensagem    => 0,
                                     pr_dsmensagem    => vr_des_erro||', Solicitacao:'||rw_crapsle.nrseqsol,
                                     pr_flgsucesso    => 0,
                                     pr_idprglog      => vr_idprglog);

            -- Adicionar no arquivo de log o problema na execu��o
            pc_gera_log_email(rw_crapsle.cdcooper,to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '||vr_des_erro);
              -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
              GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_process_email_penden');
          END IF;
          END;
        END LOOP;

        -- Log de fim de execucao
        pc_controla_log_batch(pr_dstiplog => 'F');
        -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_process_email_penden');

        -- Commitar os registros processados
        COMMIT;
      ELSE

        -- Processar somente a solicita��o passada
        pc_envia_email(pr_nrseqsol => pr_nrseqsol
                      ,pr_des_erro => vr_des_erro);
        -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_process_email_penden');

        -- Atualizar o registro como processado
        BEGIN
          UPDATE crapsle
             SET flenviad = 'S'
                ,dserrenv = vr_des_erro
           WHERE nrseqsol = pr_nrseqsol
             AND flenviad = 'N';

        -- Se houve erro
        IF trim(vr_des_erro) IS NOT NULL THEN
            -- Log de erro de execucao
            cecred.pc_log_programa(pr_dstiplog      => 'E', 
                                   pr_cdprograma    => vr_nomdojob, 
                                   pr_cdcooper      => 3, 
                                   pr_tpexecucao    => 0, -- Outros
                                   pr_tpocorrencia  => 1, -- erro nao tratado
                                   pr_cdcriticidade => 1, -- normal
                                   pr_cdmensagem    => 0,
                                   pr_dsmensagem    => vr_des_erro||', Solicitacao:'||pr_nrseqsol,
                                   pr_flgsucesso    => 0,
                                   pr_idprglog      => vr_idprglog);

          -- Adicionar no arquivo de log o problema na execu��o
          pc_gera_log_email(0,to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '||vr_des_erro);
            -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_process_email_penden');
        END IF;
        END;
      END IF;
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      WHEN OTHERS THEN
        -- Gravar pois n�o podemos reenviar os e-mails
        COMMIT;

        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_process_email_penden. '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => vr_nomdojob, 
                               pr_cdcooper      => 3, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 2, -- erro nao tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
        CECRED.pc_internal_exception;                                                         

        -- Gerar Log
        pc_gera_log_email(0,to_char(sysdate,'DD/MM/RRRR hh24:mi:ss')||' --> '||gene0001.fn_busca_critica(9999)
                            ||'ao processar emails pendentes --> '|| sqlerrm);
    END;
  END pc_process_email_penden;

  /* Procedimento de agendamento de e-mail com monitora��o em log e lista de destinat�rios em texto */
  procedure pc_solicita_email(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                             ,pr_cdprogra        IN VARCHAR2 --> Programa conectado
                             ,pr_des_destino     IN VARCHAR2 --> Um ou mais detinat�rios separados por ';' ou ','
                             ,pr_des_assunto     IN VARCHAR2 --> Assunto do e-mail
                             ,pr_des_corpo       IN VARCHAR2 --> Corpo (conteudo) do e-mail
                             ,pr_des_anexo       IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                             ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                             ,pr_flg_remete_coop IN VARCHAR2 DEFAULT 'N' --> Se o envio ser� do e-mail da Cooperativa
                             ,pr_des_nome_reply  IN VARCHAR2 DEFAULT NULL--> Nome para resposta ao e-mail
                             ,pr_des_email_reply IN VARCHAR2 DEFAULT NULL --> Endere�o para resposta ao e-mail
                             ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                             ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                             ,pr_des_erro       OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_solicita_email
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 06/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe os par�emtros necessarios para ao envio de um e-mail
    --               e prepara a lita de destinat�rios conforme o tipo gene0003.typ_listas
    -- 
    --   Alteracoes: 13/05/2013 - Prever novos par�metros de reposta ao e-mail (Marcos/Supero)
    --               31/07/2013 - Incluir novo par�metro pr_flg_log_batch que controla se a informa��o
    --                            do anexo vai ou n�o ao arquivo de log (Marcos/Supero)
    --               21/10/2013 - Copiar anexos para o diretorio converte, para manter arq. conforme o progress
    --
    --               26/11/2013 - N�o copiar arquivo para pasta converte caso n�o for passado a cooperativa
    --
    --               28/05/2014 - Remo��o da l�gica principal e apenas separa��o da lista de destinatarios
    --                            em texto para o tipo de pltable e redirecionamento para a rotina principal
    --                            de envio do e-mail (Marcos-Supero)   
    -- 
    --               22/08/2014 - Corre��o da passsagem do par�metro pr_cdprogra, pois indevidamente
    --                            estava sendo enviado a pr_cdcooper (Marcos-Supero)
    --                            na tipagem (Marcos-Supero)
    --
    --              06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                         - Padroniza��o erros comandos DDL
    --                         - Pc_set_modulo, cecred.pc_internal_exception
    --                         - Tratamento erros others
    --                           Chamado 788828 - Ana Volles (Envolti)
    -- .............................................................................
    DECLARE
      -- Guardar a lista gen�rica de destinat�rios
      vr_tab_lista    gene0003.typ_tab_listas;
      vr_tab_destinos gene0003.typ_tab_destinos;
    BEGIN
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email');
      
      -- Chamar rotina para separar da lista enviada todos os destinatarios para o vetor
      pc_separa_lista(pr_des_orige => pr_des_destino
                     ,pr_tab_lista => vr_tab_lista);
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email');

      -- Converter da lista gen�rica para a lista de destinat�rios
      IF vr_tab_lista.COUNT > 0 THEN
        FOR vr_ind IN vr_tab_lista.FIRST..vr_tab_lista.LAST LOOP
          vr_tab_destinos(vr_ind) := vr_tab_lista(vr_ind);
        END LOOP;
      END IF;
      -- Redirecionar para a rotina principal de envio de e-mail
      pc_solicita_email(pr_cdcooper        => pr_cdcooper        --> Cooperativa conectada
                       ,pr_cdprogra        => pr_cdprogra        --> Programa conectado
                       ,pr_tab_destino     => vr_tab_destinos    --> Um ou mais detinat�rios na pltable
                       ,pr_des_assunto     => pr_des_assunto     --> Assunto do e-mail
                       ,pr_des_corpo       => pr_des_corpo       --> Corpo (conteudo) do e-mail
                       ,pr_des_anexo       => pr_des_anexo       --> Um ou mais anexos separados por ';' ou ','
                       ,pr_flg_remove_anex => pr_flg_remove_anex --> Remover os anexos passados
                       ,pr_flg_remete_coop => pr_flg_remete_coop --> Se o envio ser� do e-mail da Cooperativa
                       ,pr_des_nome_reply  => pr_des_nome_reply  --> Nome para resposta ao e-mail
                       ,pr_des_email_reply => pr_des_email_reply --> Endere�o para resposta ao e-mail
                       ,pr_flg_log_batch   => pr_flg_log_batch   --> Incluir no log a informa��o do anexo?
                       ,pr_flg_enviar      => pr_flg_enviar      --> Enviar o e-mail na hora
                       ,pr_des_erro        => pr_des_erro);      --> Possivel erro
      
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

    EXCEPTION
      WHEN vr_exc_erro THEN --> Erro tratado
        -- Concatenar o erro previamente montado e retornar
        pr_des_erro := vr_des_erro;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_SOLICITA_EMAIL', 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 1, -- erro nao tratado
                               pr_cdcriticidade => 1, -- alta
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

      WHEN OTHERS THEN -- Gerar log de erro
        --Tratamento de mensagem
        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_solicita_email. '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_SOLICITA_EMAIL',
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 2, -- erro nao tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END;
  END pc_solicita_email;

  /* Procedimento de agendamento de e-mail com monitora��o em log e lista de destinat�rios em pltable */
  procedure pc_solicita_email(pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                             ,pr_cdprogra        IN VARCHAR2 --> Programa conectado
                             ,pr_tab_destino     IN gene0003.typ_tab_destinos --> Um ou mais detinat�rios na pltable
                             ,pr_des_assunto     IN VARCHAR2 --> Assunto do e-mail
                             ,pr_des_corpo       IN VARCHAR2 --> Corpo (conteudo) do e-mail
                             ,pr_des_anexo       IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                             ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                             ,pr_flg_remete_coop IN VARCHAR2 DEFAULT 'N' --> Se o envio ser� do e-mail da Cooperativa
                             ,pr_des_nome_reply  IN VARCHAR2 DEFAULT NULL--> Nome para resposta ao e-mail
                             ,pr_des_email_reply IN VARCHAR2 DEFAULT NULL --> Endere�o para resposta ao e-mail
                             ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                             ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                             ,pr_des_erro       OUT VARCHAR2) IS
  begin
    -- ..........................................................................
    --
    --  Programa : pc_solicita_email
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 24/07/2018
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina recebe os par�emtros necessarios para ao envio de um e-mail
    --               e grava as informa�oes na tabela CRAPSLE para processamento posterior.
    --               Quando enviados anexos, a rotina copia-os para a tabela CRAPSLA e vincul�-los na CRAPSLV
    --   Obs: Em caso de solicita��o para envio na hora, o mesmo � efetuado j� neste momento.
    --
    --   Alteracoes: 28/05/2014 - Transcri��o da l�gica da rotina anterior para a cria��o desta, e ent�o
    --                            altera��es conforme nova l�gica, onde n�o inserimos os anexos a cada e-mails
    --                            mas sim apenas uma vez quando for o mesmo e depois fazemos o vinculo pela 
    --                            tabela CRAPSLV (Marcos-Supero)
    --                            na tipagem (Marcos-Supero)
    --
    --               06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                          - Padroniza��o erros comandos DDL
    --                          - Pc_set_modulo, cecred.pc_internal_exception
    --                          - Tratamento erros others
    --                            Chamado 788828 - Ana Volles (Envolti)
    --                         
    --               24/07/2018 - Tratar estouro do limite de caracteres do conte�do de e-mail
    --                            Belli (Envolti) - Chamado REQ0021124
    -- .............................................................................
    DECLARE
      -- Guardar a lista de anexos e de destinat�rios
      vr_tab_anexos   gene0003.typ_tab_anexos;
      vr_tab_lista    gene0003.typ_tab_listas;
      -- Caminho e nome do arquivo
      vr_caminho VARCHAR2(4000);
      vr_arquivo VARCHAR2(4000);
      -- Blob gerado
      vr_blob BLOB;
      -- Sequencia gravada na tabela de e-mail
      vr_nrseqsol crapsle.nrseqsol%TYPE;
      -- Sequencia em que processamos os anexos na primeira vez
      vr_nrseqsol_anx crapsle.nrseqsol%TYPE;
      --Diretorio da cooperativa para manter os anexos
      vr_direconv varchar2(100);
      vr_cdcritic integer;
      
      vr_idprglog  tbgen_prglog.idprglog%type;
      --                         
      -- Variaveis para tratar estouro do limite de caracteres do conte�do de e-mail. 24/07/2018 - Chm REQ0021124.      
      vr_dscorpo          VARCHAR2(4000);
      vr_qtmaxcon         NUMBER     (4) := 3660;
      --
    BEGIN
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email 1');

      -- Busca do diret�rio base da cooperativa
      vr_direconv := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => '/converte');
      -- Se a lista estiver vazia
      IF pr_tab_destino.COUNT = 0 THEN
        -- Gerar exce��o
        vr_cdcritic := 1047;
        vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic);
        RAISE vr_exc_erro;
      END IF;
      
      -- Regra para Tratar estouro do limite de caracteres do conte�do de e-mail. 24/07/2018 - Chm REQ0021124. 
      -- Calculo dos 4000 caracteres: Ultima linha padr�o com 195 caracteres, a mensagem 
      -- do trunque com 125 caracteres e o conteudo com 3660 caracteres e sobrou 20 caracteres de seguran�a
      IF LENGTH(pr_des_corpo) > vr_qtmaxcon THEN
        vr_dscorpo := SUBSTR(pr_des_corpo,1,vr_qtmaxcon) || '<br><br>' || 
                      'O conte�do do e-mail foi truncado pelo motivo de exceder o tamanho limite de '||
                      vr_qtmaxcon || ', favor acionar o Help Desk(AILOS).';
        cecred.pc_log_programa(pr_dstiplog      => 'E'
                              ,pr_cdprograma    => 'GENE0003.PC_SOLICITA_EMAIL' 
                              ,pr_cdcooper      => pr_cdcooper 
                              ,pr_tpexecucao    => 0  -- Tipo de execucao (1-Batch/ 2-Job/ 3-Online)
                              ,pr_tpocorrencia  => 1  -- Erro de negocio
                              ,pr_cdcriticidade => 0     -- baixa
                              ,pr_cdmensagem    => 1280 -- O conte�do do e-mail foi truncado pelo motivo de exceder o tamanho limite
                              ,pr_dsmensagem    => gene0001.fn_busca_critica( 1280 ) ||
                                                  ' Pr_cdprogra:'     || pr_cdprogra    || 
                                                  ', pr_des_assunto:' || pr_des_assunto || 
                                                  ', vr_qtmaxcon:'          || vr_qtmaxcon   ||
                                                  ', length(pr_des_corpo):' || LENGTH(pr_des_corpo)
                              ,pr_flgsucesso    => 0
                              ,pr_idprglog      => vr_idprglog);
        -- Retorno nome do m�dulo logado
        gene0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email 1');        
      ELSE
        vr_dscorpo := pr_des_corpo;  
      END IF;  

      -- Chamar rotina para separar da lista enviada de anexos para o vetor
      pc_separa_lista(pr_des_orige => pr_des_anexo
                     ,pr_tab_lista => vr_tab_lista);
      -- Converter da lista gen�rica para a lista de anexos
      IF vr_tab_lista.COUNT > 0 THEN
        FOR vr_ind IN vr_tab_lista.FIRST..vr_tab_lista.LAST LOOP
          vr_tab_anexos(vr_ind).dspathan := vr_tab_lista(vr_ind);
          vr_tab_anexos(vr_ind).nrseqsol := 0;
        END LOOP;
      END IF;        

      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email 1');

      -- Para cada destinat�rio na lista
      FOR vr_ind IN pr_tab_destino.FIRST..pr_tab_destino.LAST LOOP
        -- Limpar sequencia para grava��o
        vr_nrseqsol := NULL;
        -- Criar o registro na tabela de solicita�ao
        BEGIN
          -- Valida��o do e-mail
          IF fn_valida_email(pr_tab_destino(vr_ind)) = 0 THEN
            cecred.pc_log_programa(pr_dstiplog      => 'E', 
                                   pr_cdprograma    => 'GENE0003.PC_SOLICITA_EMAIL', 
                                   pr_cdcooper      => 3, 
                                   pr_tpexecucao    => 3,  -- Tipo de execucao (1-Batch/ 2-Job/ 3-Online)
                                   pr_tpocorrencia  => 3,  -- Alerta
                                   pr_cdcriticidade => 0,  -- baixa
                                   pr_cdmensagem    => 883,
                                   pr_dsmensagem    => gene0001.fn_busca_critica(883)||' '||pr_tab_destino(vr_ind) ||
                                                       ', pr_cdprogra: '    || pr_cdprogra || 
                                                       ', pr_des_assunto: ' || pr_des_assunto,
                                   pr_flgsucesso    => 0,
                                   pr_idprglog      => vr_idprglog);

            CONTINUE;
          END IF;

          -- Cria o registro guardando seu Rowid
          INSERT INTO crapsle(dtsolici
                             ,cdcooper
                             ,cdprogra
                             ,dsendere
                             ,dsassunt
                             ,dscorpoe
                             ,dsanexos
                             ,flremcop
                             ,dsnmrepl
                             ,dsemrepl
                             ,flenviad)
                       VALUES(SYSDATE
                             ,pr_cdcooper
                             ,pr_cdprogra
                             ,pr_tab_destino(vr_ind)
                             ,pr_des_assunto
                             ,vr_dscorpo -- variavel do conte�do de e-mail tratado. 24/07/2018 - Chm REQ0021124.   
                             ,pr_des_anexo 
                             ,pr_flg_remete_coop
                             ,pr_des_nome_reply
                             ,pr_des_email_reply
                             ,'N') --> Ainda nao enviada
                    RETURNING nrseqsol INTO vr_nrseqsol;

          -- Verifica se existem anexos a processar
          IF vr_tab_anexos.COUNT > 0 THEN
            -- Se ja foram processados os anexos para envio
            IF vr_tab_anexos(vr_tab_anexos.FIRST).nrseqsol = 0 THEN
              -- Percorre toda a lista
              FOR vr_ind_a IN vr_tab_anexos.FIRST..vr_tab_anexos.LAST LOOP
                -- Se o arquivo passado existe
                IF gene0001.fn_exis_arquivo(vr_tab_anexos(vr_ind_a).dspathan) THEN
                  -- Chamar rotina que separa o caminho do arquivo
                  gene0001.pc_separa_arquivo_path(pr_caminho => vr_tab_anexos(vr_ind_a).dspathan
                                                 ,pr_direto  => vr_caminho
                                                 ,pr_arquivo => vr_arquivo);
                  -- Se n�o conseguiu montar o caminho e nome corretos
                  IF vr_arquivo IS NULL OR vr_caminho IS NULL THEN
                    -- Gerar erro
                    vr_cdcritic := 1048;
                    vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' <'||vr_tab_anexos(vr_ind).dspathan||'>';
                    RAISE vr_exc_erro;
                  END IF;

                  --Somente copiar o arq anexo se os diretorios forem diferentes, caracterizando que o arq ja n�o esta no dir.
                  IF vr_direconv <> vr_caminho AND
                     nvl(pr_cdcooper,0) <> 0 THEN
                    -- Efetuar chamada shell para copiar o arquivo anexados para a pasta converte, conforme no progress
                    gene0001.pc_oscommand_shell('cp '||vr_tab_anexos(vr_ind_a).dspathan||' '||vr_direconv||'/'||vr_arquivo);
                  END IF;

                  -- Chamar rotina que le um BLOB a partir de um arquivo
                  vr_blob := gene0002.fn_arq_para_blob(pr_caminho => vr_caminho
                                                      ,pr_arquivo => vr_arquivo);
                  -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
                  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email 1');

                  -- Criar o registro na tabela de anexos
                  BEGIN
                    INSERT INTO crapsla(dspathan
                                       ,dsnmarqv
                                       ,qttamane
                                       ,blobanex)
                                 VALUES(vr_caminho
                                       ,vr_arquivo
                                       ,DBMS_LOB.getlength(vr_blob) -- tamanho
                                       ,vr_blob) --Conteudo do arquivo em si
                              RETURNING nrseqsol
                                   INTO vr_nrseqsol_anx;
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic := 1034;
                      pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crapsla:'||
                                    ' dspathan:'||vr_caminho||', dsnmarqv:'||vr_arquivo||
                                    ', qttamane:'||DBMS_LOB.getlength(vr_blob)||'. '||sqlerrm;

                      -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
                      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
                      RAISE vr_exc_erro;
                  END;
                  
                  -- Guardar na pltable o sequencial do anexo
                  vr_tab_anexos(vr_ind_a).nrseqsol := vr_nrseqsol_anx;
                  -- Criar o vinculo deste anexo ao e-mail
                  BEGIN
                    INSERT INTO crapslv(nrseqsle
                                       ,nrseqsla)
                                 VALUES(vr_nrseqsol
                                       ,vr_nrseqsol_anx);
                  EXCEPTION
                    WHEN OTHERS THEN
                      vr_cdcritic := 1034;
                      pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crapslv:'||
                                     ' nrseqsle:'||vr_nrseqsol||', nrseqsla:'||vr_nrseqsol_anx||'. '||sqlerrm;

                      -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
                      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
                      RAISE vr_exc_erro;
                  END;
                  
                  -- Se foi solicitado para remover os anexos
                  IF pr_flg_remove_anex = 'S' THEN
                    -- Efetuar chamada shell para remover o arquivo anexados
                    gene0001.pc_oscommand_shell('rm '||vr_tab_anexos(vr_ind_a).dspathan);
                  END IF;
                  -- Se foi solicitado envio de log
                  IF pr_flg_log_batch = 'S' THEN
                    -- Grava log no PROC_MESSAGE avisando que o anexo ser� enviado para o destinat�rio
                    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                    
                                              ,pr_ind_tipo_log  => 1 -- Processo normal
                                              ,pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                              ,pr_dstiplog      => 'E'
                                              ,pr_cdprograma    => pr_cdprogra                      
                                              ,pr_tpexecucao    => 0 -- Outros                     
                                              ,pr_cdcriticidade => 0 -- Baixa                      
                                              ,pr_cdmensagem    => 0           
                                              ,pr_des_log       => to_char(sysdate,'hh24:mi:ss')||' - '|| pr_cdprogra ||
                                                                    ' --> '||vr_caminho||'/'||vr_arquivo||
                                                                    ' ENVIADO PARA '||pr_tab_destino(vr_ind)||'.');
                  END IF;
                ELSE
                  -- Grava log para avisar que n�o localizou o anexo
                  btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                    
                                            ,pr_ind_tipo_log  => 2 -- Erro Tratado
                                            ,pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                            ,pr_dstiplog      => 'E'
                                            ,pr_cdprograma    => pr_cdprogra                      
                                            ,pr_tpexecucao    => 0 -- Outros                     
                                            ,pr_cdcriticidade => 0 -- Baixa                      
                                            ,pr_cdmensagem    => 1049 --pr_cdmensagem 
                                            ,pr_des_log       => to_char(sysdate,'hh24:mi:ss')||' - '|| pr_cdprogra ||
                                                                ' --> '||gene0001.fn_busca_critica(1049)||' '||
                                                                vr_tab_anexos(vr_ind_a).dspathan);
                END IF;
              END LOOP;
            ELSE
              -- Percorre toda a lista
              FOR vr_ind_a IN vr_tab_anexos.FIRST..vr_tab_anexos.LAST LOOP
                -- Criar o vinculo do e-mail atual com os anexos j� processados
                BEGIN
                  INSERT INTO crapslv(nrseqsle
                                     ,nrseqsla)
                               VALUES(vr_nrseqsol --> Registro sendo processado agora
                                     ,vr_tab_anexos(vr_ind_a).nrseqsol);
                  -- Se foi solicitado envio de log
                  IF pr_flg_log_batch = 'S' THEN
                    -- Grava log para avisar que o anexo ser� enviado para o destinat�rio
                    btch0001.pc_gera_log_batch(pr_cdcooper      => pr_cdcooper                    
                                              ,pr_ind_tipo_log  => 1 -- Processo normal
                                              ,pr_nmarqlog      => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                              ,pr_dstiplog      => 'E'
                                              ,pr_cdprograma    => pr_cdprogra                      
                                              ,pr_tpexecucao    => 0 -- Outros                     
                                              ,pr_cdcriticidade => 0 -- Baixa                      
                                              ,pr_cdmensagem    => 0 -- pr_cdmensagem       
                                              ,pr_des_log       => to_char(sysdate,'hh24:mi:ss')||' - '|| pr_cdprogra || 
                                                                   ' --> '||vr_tab_anexos(vr_ind_a).dspathan||
                                                                   ' ENVIADO PARA '||pr_tab_destino(vr_ind)||'.');
                  END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 1034;
                    pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crapslv:'||
                                   ' nrseqsle:'||vr_nrseqsol||', nrseqsla:'||vr_tab_anexos(vr_ind_a).nrseqsol||'. '||sqlerrm;

                    -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
                    CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
                    RAISE vr_exc_erro;
                END;
              END LOOP;
            END IF;
          END IF;
          -- Se foi solicitado o envio na hora
          IF pr_flg_enviar = 'S' THEN
            -- Solicitar o envio com a sequencia inserida acima
            pc_process_email_penden(pr_nrseqsol => vr_nrseqsol
                                   ,pr_des_erro => vr_des_erro);
            -- Se houve erro
            IF vr_des_erro IS NOT NULL THEN
              -- sair por exce�ao
              RAISE vr_exc_erro;
            END IF;
            -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
            GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email 1');
          END IF;
        EXCEPTION
          WHEN vr_exc_erro THEN
            -- Efetuar raise novamente para a exception ser tratada no bloco de fora
            RAISE vr_exc_erro;
          WHEN OTHERS THEN
            vr_cdcritic := 1034;
            vr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'crapsle:'||
                   ' dtsolici:'||SYSDATE||', cdcooper:'||pr_cdcooper||
                   ', cdprogra:'||pr_cdprogra||', dsendere:'||pr_tab_destino(vr_ind)||
                   ', dsassunt:'||pr_des_assunto||', dscorpoe:'||vr_dscorpo||
                   ', dsanexos:'||pr_des_anexo||', flremcop:'||pr_flg_remete_coop||
                   ', dsnmrepl:'||pr_des_nome_reply||', dsemrepl:'||pr_des_email_reply||
                   ', flenviad:N. '||sqlerrm;

            -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
            RAISE vr_exc_erro;
        END;
      END LOOP;

      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN --> Erro tratado
        -- Concatenar o erro previamente montado e retornar
        vr_cdcritic := nvl(vr_cdcritic,0);
        pr_des_erro := vr_des_erro;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_SOLICITA_EMAIL',
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 1, -- erro nao tratado
                               pr_cdcriticidade => 1, -- alta
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

      WHEN OTHERS THEN -- Gerar log de erro
        --Tratamento de mensagem
        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_solicita_email 1. '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_SOLICITA_EMAIL',
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 2, -- erro nao tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END;
  END pc_solicita_email;

  /* Procedimento de agendamento de de e-mail sem monitora��o em log */
  PROCEDURE pc_solicita_email(pr_cdprogra        IN VARCHAR2 --> Programa conectado
                             ,pr_des_destino     IN VARCHAR2 --> Um ou mais detinat�rios separados por ';' ou ','
                             ,pr_des_assunto     IN VARCHAR2 --> Assunto do e-mail
                             ,pr_des_corpo       IN VARCHAR2 --> Corpo (conteudo) do e-mail
                             ,pr_des_anexo       IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                             ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                             ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                             ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                             ,pr_des_erro       OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_solicita_email
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 06/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Apenas fazer overload do procedimento acima sem necessidade de informarmos a Coop
    --
    --   Alteracoes: 13/05/2013 - Prever novos par�metros de reposta ao e-mail (Marcos/Supero)
    --
    --               31/07/2013 - Incluir novo par�metro pr_flg_log_batch (Marcos/Supero)
    --                            na tipagem (Marcos-Supero)
    --
    --               06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                          - Padroniza��o erros comandos DDL
    --                          - Pc_set_modulo, cecred.pc_internal_exception
    --                          - Tratamento erros others
    --                            Chamado 788828 - Ana Volles (Envolti)
    -- .............................................................................
    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email 2');
    
    pc_solicita_email(pr_cdcooper         => 0
                     ,pr_cdprogra         => pr_cdprogra
                     ,pr_des_destino      => pr_des_destino
                     ,pr_des_assunto      => pr_des_assunto
                     ,pr_des_corpo        => pr_des_corpo
                     ,pr_des_anexo        => pr_des_anexo
                     ,pr_flg_remove_anex  => pr_flg_remove_anex
                     ,pr_flg_remete_coop  => 'N' --> Envia do remetente padr�o
                     ,pr_des_nome_reply   => null
                     ,pr_des_email_reply  => null
                     ,pr_flg_log_batch    => pr_flg_log_batch
                     ,pr_flg_enviar       => pr_flg_enviar
                     ,pr_des_erro         => pr_des_erro);
                     
    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  END pc_solicita_email;

  /* Procedimento para chamada da rotina de solicita��o de email via Progress */
  procedure pc_solicita_email_prog (pr_cdcooper        IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                                   ,pr_cdprogra        IN VARCHAR2 --> Programa conectado
                                   ,pr_des_destino     IN VARCHAR2 --> Um ou mais detinat�rios separados por ';' ou ','
                                   ,pr_des_assunto     IN VARCHAR2 --> Assunto do e-mail
                                   ,pr_des_corpo       IN VARCHAR2 --> Corpo (conteudo) do e-mail
                                   ,pr_des_anexo       IN VARCHAR2 --> Um ou mais anexos separados por ';' ou ','
                                   ,pr_flg_remove_anex IN VARCHAR2 DEFAULT 'S' --> Remover os anexos passados
                                   ,pr_flg_remete_coop IN VARCHAR2 DEFAULT 'N' --> Se o envio ser� do e-mail da Cooperativa
                                   ,pr_des_nome_reply  IN VARCHAR2 DEFAULT NULL--> Nome para resposta ao e-mail
                                   ,pr_des_email_reply IN VARCHAR2 DEFAULT NULL--> Endere�o para resposta ao e-mail
                                   ,pr_flg_log_batch   IN VARCHAR2 DEFAULT 'S' --> Incluir no log a informa��o do anexo?
                                   ,pr_flg_enviar      IN VARCHAR2 DEFAULT 'N' --> Enviar o e-mail na hora
                                   ,pr_des_erro       OUT VARCHAR2) IS
    /* ..........................................................................
    --
    --  Programa : pc_solicita_email_prog
    --  Sistema  : Rotinas gen�ricas
    --  Sigla    : GENE
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Janeiro/2016.                   Ultima atualizacao: 06/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Chamar a rotina pc_solicita_email via progress
    --   
    --   Alteracoes: 06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                          - Padroniza��o erros comandos DDL
    --                          - Pc_set_modulo, cecred.pc_internal_exception
    --                          - Tratamento erros others
    --                            Chamado 788828 - Ana Volles (Envolti)
    -- .............................................................................*/
  BEGIN    
    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_solicita_email_prog');
  
    pc_solicita_email(pr_cdcooper         => pr_cdcooper
                     ,pr_cdprogra         => pr_cdprogra
                     ,pr_des_destino      => pr_des_destino
                     ,pr_des_assunto      => pr_des_assunto
                     ,pr_des_corpo        => pr_des_corpo
                     ,pr_des_anexo        => pr_des_anexo
                     ,pr_flg_remove_anex  => pr_flg_remove_anex
                     ,pr_flg_remete_coop  => pr_flg_remete_coop
                     ,pr_des_nome_reply   => pr_des_nome_reply
                     ,pr_des_email_reply  => nvl(pr_des_email_reply,pr_des_nome_reply)
                     ,pr_flg_log_batch    => pr_flg_log_batch
                     ,pr_flg_enviar       => pr_flg_enviar
                     ,pr_des_erro         => pr_des_erro);
  
    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      vr_cdcritic := 9999;
      pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' gene0003.pc_solicita_email_prog. '||sqlerrm;

      -- Log de erro de execucao
      cecred.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => 'GENE0003.PC_SOLICITA_EMAIL_PROG', 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 0, -- Outros
                             pr_tpocorrencia  => 2, -- erro nao tratado
                             pr_cdcriticidade => 2, -- alta
                             pr_cdmensagem    => vr_cdcritic,
                             pr_dsmensagem    => pr_des_erro,
                             pr_flgsucesso    => 0,
                             pr_idprglog      => vr_idprglog);

      -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_solicita_email_prog;

  /* Rotina Respons�vel pela conversao de programa unix para DOS */
  PROCEDURE pc_converte_arquivo(pr_cdcooper IN crapdev.cdcooper%TYPE           --> Cooperativa
                               ,pr_nmarquiv IN VARCHAR2                        --> Caminho e nome do arquivo a ser convertido
                               ,pr_nmarqenv IN VARCHAR2                        --> Nome desejado para o arquivo convertido
                               ,pr_des_erro IN OUT VARCHAR2) IS                --> Variavel de retorno de erro
  BEGIN
    /* .............................................................................
       Programa: pc_converte_arquivo - Antiga converte_arquivo (sistema/generico/procedures/b1wgen0011.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Alisson (AMcom)
       Data    : Dezembro/2012                          Ultima alteracao: 06/12/2017

       Dados referentes ao programa:

       Frequencia : Diario (Batch)
       Objetivo   : Converter arquivos unix para DOS).
       
       Altera��es : 11/03/2014 - Simplifica��o da rotina - Marcos (Supero)
       
                    06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
                               - Padroniza��o erros comandos DDL
                               - Pc_set_modulo, cecred.pc_internal_exception
                               - Tratamento erros others
                                 Chamado 788828 - Ana Volles (Envolti)
    ............................................................................. */
    DECLARE
      vr_nmdirconv VARCHAR2(300);  --> Diret�rio converte da Cooperativa
      vr_dscomando VARCHAR2(4000); --> Comando completo
      -- Saida da OS Command
      vr_des_erro  VARCHAR2(4000);
      vr_typ_saida VARCHAR2(4000);
    BEGIN
      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_converte_arquivo');

      -- Buscar o diret�rio converte da Cooperativa
      vr_nmdirconv := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_nmsubdir => 'converte');
      -- Executa comando UNIX
      vr_dscomando := 'ux2dos < ' || pr_nmarquiv || ' | tr -d "\032" ' ||
                      ' > ' || vr_nmdirconv ||'/'|| pr_nmarqenv || ' 2>/dev/null';
      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_dscomando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_des_erro);
      IF vr_typ_saida = 'ERR' THEN
        RAISE vr_exc_erro;
      END IF;

      -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    EXCEPTION
      WHEN vr_exc_erro THEN
        vr_cdcritic := 1053;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' gene0003.pc_converte_arquivo. '||vr_des_erro;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_CONVERTE_ARQUIVO', 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 1, -- erro nao tratado
                               pr_cdcriticidade => 1, -- alta
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

      WHEN OTHERS THEN
        vr_cdcritic := 9999;
        pr_des_erro := gene0001.fn_busca_critica(vr_cdcritic)||' gene0003.pc_converte_arquivo. '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_CONVERTE_ARQUIVO', 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 2, -- erro nao tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => vr_cdcritic,
                               pr_dsmensagem    => pr_des_erro,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END;
  END pc_converte_arquivo;
  
  /* Fun��o validadora do e-mail*/
  FUNCTION fn_valida_email(pr_dsdemail in varchar2) return pls_integer IS
    /* .............................................................................

       Programa: fn_valida_email
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Carlos (Cecred)
       Data    : Abril/2014                          Ultima alteracao: 24/01/2018

       Dados referentes ao programa:

       Frequencia : Sempre que chamado
       Objetivo   : Validar o e-mail informado
         
       Altera��es : 24/01/2018 - Ajuste no regex para que seja poss�vel cadastrar e-mails
                                 com apenas um caracter, conforme solicitado no chamado 
                                 830663. (Kelvin)
         
    ............................................................................. */
  BEGIN
    if REGEXP_LIKE (pr_dsdemail, '^[a-zA-Z0-9$''-\_][^*{|\}?]*@[a-zA-Z0-9._-]+\.[a-zA-Z]{2,4}$') then
      return 1;
    else
      return 0;
    end if;
  END fn_valida_email;  

  -- Rotina para geracao de mensagens para o servico do site
  PROCEDURE pc_gerar_mensagem(pr_cdcooper IN crapmsg.cdcooper%TYPE
                             ,pr_nrdconta IN crapmsg.nrdconta%TYPE
                             ,pr_idseqttl IN crapmsg.idseqttl%TYPE DEFAULT NULL
                             ,pr_cdprogra IN crapmsg.cdprogra%TYPE
                             ,pr_inpriori IN crapmsg.inpriori%TYPE
                             ,pr_dsdmensg IN crapmsg.dsdmensg%TYPE
                             ,pr_dsdassun IN crapmsg.dsdassun%TYPE
                             ,pr_dsdremet IN crapmsg.dsdremet%TYPE
                             ,pr_dsdplchv IN crapmsg.dsdplchv%TYPE
                             ,pr_cdoperad IN crapmsg.cdoperad%TYPE
                             ,pr_cdcadmsg IN crapmsg.cdcadmsg%TYPE
                             ,pr_dscritic OUT VARCHAR2) IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_gerar_mensagem        Antigo: sistema/generico/procedures/b1wgen0116.p/gerar-mensagem
    --  Sistema  : BO responsavel pela parte de mensagens no InternetBank.
    --  Sigla    : CRED
    --  Autor    : Andrino Carlos de Souza Junior - RKAM
    --  Data     : Novembro/2013.                   Ultima atualizacao: 04/12/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Geracao de mensagens para o servico do site
    --
    -- Altera��es: 20/10/2016 - Utiliza��o da fn_sequence. (Pabl�o)
    --
    --             16/10/2017 - Altera��o para utilizar a vw_usuarios_internet, e quando n�o
    --                          receber titular, deve gerar mensagem para todos os usu�rios
    --                          (Pabl�o)

    --             06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                        - Padroniza��o erros comandos DDL
    --                        - Pc_set_modulo, cecred.pc_internal_exception
    --                        - Tratamento erros others
    --                          Chamado 788828 - Ana Volles (Envolti)
    ---------------------------------------------------------------------------------------------------------------
    
    
    --Selecionar titulares com senhas ativas
    CURSOR cr_usuarios_internet IS
     SELECT usr.*
           ,cop.nmrescop
       FROM vw_usuarios_internet usr
           ,crapcop              cop
      WHERE usr.cdcooper = cop.cdcooper
        AND usr.cdcooper = pr_cdcooper
        AND usr.nrdconta = pr_nrdconta
        AND (pr_idseqttl IS NULL OR pr_idseqttl = 0 OR usr.idseqttl = pr_idseqttl);
    TYPE typ_usuarios_internet IS TABLE OF cr_usuarios_internet%ROWTYPE INDEX BY PLS_INTEGER;
    vr_usuarios_internet typ_usuarios_internet;
    
    vr_nrdmensg crapmsg.nrdmensg%TYPE := 0;
    vr_dsdmensg crapmsg.dsdmensg%TYPE := ' ';
    
  BEGIN
    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_gerar_mensagem');
  
    /* trocando caracteres especiais */
    vr_dsdmensg := REPLACE(pr_dsdmensg, '<', '%3C');
    vr_dsdmensg := REPLACE(vr_dsdmensg, '>', '%3E');
    vr_dsdmensg := REPLACE(vr_dsdmensg, CHR(38), '%26');

    OPEN cr_usuarios_internet;
   FETCH cr_usuarios_internet BULK COLLECT
    INTO vr_usuarios_internet;
   CLOSE cr_usuarios_internet;

    FOR idx IN 1 .. vr_usuarios_internet.count LOOP

    -- Obt�m o proximo valor da sequence
    vr_nrdmensg := fn_sequence(pr_nmtabela => 'CRAPMSG'
                              ,pr_nmdcampo => 'NRDMENSG'
                              ,pr_dsdchave => pr_cdcooper || ';' || pr_nrdconta
                              ,pr_flgdecre => 'N');

    /* trocando "#cooperado#" pelo nome do cooperado,
      trocando #cooperativa# pelo nome fantasia da cooperativa
      trocando #titular# pelo nome do titular da conta */
      vr_dsdmensg := REPLACE(vr_dsdmensg,'%23cooperado%23',vr_usuarios_internet(idx).nmextttl);
      vr_dsdmensg := REPLACE(vr_dsdmensg,'%23cooperativa%23',vr_usuarios_internet(idx).nmrescop);
  
    BEGIN
      INSERT INTO crapmsg
        (cdcooper
        ,nrdconta
        ,idseqttl
        ,nrdmensg
        ,cdprogra
        ,dtdmensg
        ,hrdmensg
        ,dsdremet
        ,dsdassun
        ,dsdmensg
        ,flgleitu
        ,inpriori
        ,dsdplchv
        ,cdoperad
        ,cdcadmsg)
      VALUES
          (vr_usuarios_internet(idx).cdcooper
          ,vr_usuarios_internet(idx).nrdconta
          ,vr_usuarios_internet(idx).idseqttl
        ,vr_nrdmensg
        ,pr_cdprogra
        ,trunc(SYSDATE)
        ,to_char(SYSDATE, 'sssss')
        ,pr_dsdremet
        ,pr_dsdassun
        ,vr_dsdmensg
        ,0
        ,pr_inpriori
        ,pr_dsdplchv
        ,pr_cdoperad
        ,pr_cdcadmsg);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := gene0001.fn_busca_critica(1034)||'crapmsg:'||
                       ' cdcooper:'||pr_cdcooper||', nrdconta:'||pr_nrdconta||
                       ', idseqttl:'||pr_idseqttl||', nrdmensg:'||vr_nrdmensg||
                       ', cdprogra:'||pr_cdprogra||', dtdmensg:'||trunc(SYSDATE)||
                       ', hrdmensg:'||to_char(SYSDATE, 'sssss')||', dsdremet:'||pr_dsdremet||
                       ', dsdassun:'||pr_dsdassun||', flgleitu:0, inpriori:'||pr_inpriori||
                       ', dsdplchv:'||pr_dsdplchv||', cdoperad:'||pr_cdoperad||
                       ', cdcadmsg:'||pr_cdcadmsg||'. '||sqlerrm;

        -- Log de erro de execucao
        cecred.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdprograma    => 'GENE0003.PC_GERAR_MENSAGEM', 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpexecucao    => 0, -- Outros
                               pr_tpocorrencia  => 2, -- erro nao tratado
                               pr_cdcriticidade => 2, -- alta
                               pr_cdmensagem    => 1034,
                               pr_dsmensagem    => pr_dscritic,
                               pr_flgsucesso    => 0,
                               pr_idprglog      => vr_idprglog);

        -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END;
	END LOOP;

    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      --Tratamento de mensagem
      vr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_gerar_mensagem. '||sqlerrm;

      -- Log de erro de execucao
      cecred.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => 'GENE0003.PC_GERAR_MENSAGEM', 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 0, -- Outros
                             pr_tpocorrencia  => 2, -- erro nao tratado
                             pr_cdcriticidade => 2, -- alta
                             pr_cdmensagem    => vr_cdcritic,
                             pr_dsmensagem    => pr_dscritic,
                             pr_flgsucesso    => 0,
                             pr_idprglog      => vr_idprglog);

      -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_gerar_mensagem;

  -- Rotina para buscar conte�do das mensagens do iBank/SMS
  FUNCTION fn_buscar_mensagem(pr_cdcooper          IN tbgen_mensagem.cdcooper%TYPE
                             ,pr_cdproduto         IN tbgen_mensagem.cdproduto%TYPE
                             ,pr_cdtipo_mensagem   IN tbgen_mensagem.cdtipo_mensagem%TYPE
                             ,pr_sms               IN NUMBER DEFAULT 0       -- Indicador se mensagem � SMS (pois deve cortar em 160 caracteres)
                             ,pr_valores_dinamicos IN VARCHAR2 DEFAULT NULL) -- M�scara #Cooperativa#=1;#Convenio#=123
   RETURN tbgen_mensagem.dsmensagem%TYPE IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : fn_buscar_mensagem
    --  Autor    : Dionathan
    --  Data     : Abril/2016.                   Ultima atualizacao: 06/12/2017
    --
    -- Objetivo  : Buscar as mensagens do iBank/SMS
    --
    -- Altera��es: 06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                        - Padroniza��o erros comandos DDL
    --                        - Pc_set_modulo, cecred.pc_internal_exception
    --                        - Tratamento erros others
    --                          Chamado 788828 - Ana Volles (Envolti)
    ---------------------------------------------------------------------------------------------------------------
  
    /* Busca dos dados do associado */
    CURSOR cr_mensagem IS
      SELECT msg.dsmensagem
        FROM tbgen_mensagem msg
       WHERE msg.cdcooper = pr_cdcooper
         AND msg.cdproduto = pr_cdproduto
         AND msg.cdtipo_mensagem = pr_cdtipo_mensagem;
    vr_dsmensagem tbgen_mensagem.dsmensagem%TYPE;
  
    /*Quebra os valores da string recebida por par�metro*/
    CURSOR cr_parametro IS
      SELECT regexp_substr(parametro, '[^=]+', 1, 1) parametro
            ,regexp_substr(parametro, '[^=]+', 1, 2) valor
        FROM (SELECT regexp_substr(pr_valores_dinamicos, '[^;]+', 1, ROWNUM) parametro
                FROM dual
              CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_valores_dinamicos ,'[^;]+','')) + 1);
  
  BEGIN
    -- Inclu�do pc_set_modulo da fun��o - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.fn_buscar_mensagem');
  
    OPEN cr_mensagem;
    FETCH cr_mensagem
      INTO vr_dsmensagem;
    CLOSE cr_mensagem;
  
    -- Sobrescreve os par�metros
    FOR rw_parametro IN cr_parametro LOOP
      vr_dsmensagem := REPLACE(vr_dsmensagem
                              ,rw_parametro.parametro
                              ,rw_parametro.valor);
    END LOOP;
  
    -- Se for SMS corta em 160 caracteres
    IF pr_sms <> 0 THEN
      vr_dsmensagem := SUBSTR(vr_dsmensagem, 1, 160);
    END IF;
  
    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
    RETURN vr_dsmensagem;
  EXCEPTION
    WHEN OTHERS THEN
      --Tratamento de mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.fn_buscar_mensagem. '||sqlerrm;

      -- Log de erro de execucao
      cecred.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => 'GENE0003.FN_GERAR_MENSAGEM', 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 0, -- Outros
                             pr_tpocorrencia  => 2, -- erro nao tratado
                             pr_cdcriticidade => 2, -- alta
                             pr_cdmensagem    => vr_cdcritic,
                             pr_dsmensagem    => vr_dscritic,
                             pr_flgsucesso    => 0,
                             pr_idprglog      => vr_idprglog);

      -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  
  END fn_buscar_mensagem;
  
  -- Rotina para buscar conte�do das mensagens do iBank/SMS - utilizar no progress
  PROCEDURE pc_buscar_mensagem(pr_cdcooper         IN tbgen_mensagem.cdcooper%TYPE
                             ,pr_cdproduto         IN tbgen_mensagem.cdproduto%TYPE
                             ,pr_cdtipo_mensagem   IN tbgen_mensagem.cdtipo_mensagem%TYPE
                             ,pr_sms               IN NUMBER DEFAULT 0 -- Indicador se mensagem � SMS (pois deve cortar em 160 caracteres)
                             ,pr_valores_dinamicos IN VARCHAR2 DEFAULT NULL -- M�scara #Cooperativa#=1;#Convenio#=123
                             ,pr_dsmensagem       OUT tbgen_mensagem.dsmensagem%TYPE) IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_buscar_mensagem
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Maio/2016.                   Ultima atualizacao: 06/12/2017
    --
    -- Objetivo  : Buscar as mensagens do iBank/SMS, procedure para ser utilizada no progress
    --
    -- Altera��es: 06/12/2017 - Padroniza��o mensagens (crapcri, pc_gera_log (tbgen))
    --                        - Padroniza��o erros comandos DDL
    --                        - Pc_set_modulo, cecred.pc_internal_exception
    --                        - Tratamento erros others
    --                          Chamado 788828 - Ana Volles (Envolti)
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0003.pc_buscar_mensagem');

    -- Buscar conte�do das mensagens do iBank/SMS
    pr_dsmensagem := fn_buscar_mensagem(pr_cdcooper          => pr_cdcooper         
                                       ,pr_cdproduto         => pr_cdproduto        
                                       ,pr_cdtipo_mensagem   => pr_cdtipo_mensagem  
                                       ,pr_sms               => pr_sms              
                                       ,pr_valores_dinamicos => pr_valores_dinamicos);

    -- Inclu�do pc_set_modulo da procedure - Chamado 788828 - 06/12/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);

  EXCEPTION
    WHEN OTHERS THEN
      --Tratamento de mensagem
      vr_cdcritic := 9999;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'gene0003.pc_buscar_mensagem. '||sqlerrm;

      -- Log de erro de execucao
      cecred.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => 'GENE0003.PC_BUSCAR_MENSAGEM', 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 0, -- Outros
                             pr_tpocorrencia  => 2, -- erro nao tratado
                             pr_cdcriticidade => 2, -- alta
                             pr_cdmensagem    => vr_cdcritic,
                             pr_dsmensagem    => vr_dscritic,
                             pr_flgsucesso    => 0,
                             pr_idprglog      => vr_idprglog);

      -- No caso de erro de programa gravar tabela especifica de log - 06/12/2017 - Ch 788828 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
  END pc_buscar_mensagem;
  
END gene0003;
/
