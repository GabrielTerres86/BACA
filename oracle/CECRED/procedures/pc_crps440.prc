CREATE OR REPLACE PROCEDURE CECRED.pc_crps440
                            (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                            ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                            ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                            ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                            ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                            ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada  
BEGIN                            
  /* ............................................................................

   Programa: pc_crps440 (Fontes/crps440.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2005                        Ultima atualizacao: 31/03/2015

   Dados referentes ao programa:

   Frequencia: Mensal (Batch).
   Objetivo  : Listar relatorio com seguros a vencer no mes seguinte
               (tipo >= 11).
               Solicitacao 87, ordem 7
               Emite o relatorio 417.
               
   Alteracoes: 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

               08/04/2008 - Alterado envio de email para BO b1wgen0011
                            (Sidnei - Precise)
                            
               09/04/2008 - Alterado formato do campo "crapseg.qtprepag", de  
                           "z9" para "zz9" - Kbase IT Solutions - Eduardo.
               
               16/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).        
                                                        
               26/11/2013 - Adicionado o nr. proposta na Ordenacao
                            Projeto Oracle (Guilherme).
                            
               31/03/2015 - Conversão Progress --> Oracle (Lucas Ranghetti)
    ............................................................................. */


  DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS440';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);

      -- CLOB xml
      vr_des_xml      CLOB;
      vr_path_arquivo VARCHAR2(1000);
      vr_xml_emails        crapprm.dsvlrprm%TYPE;
     
      
      ------------------------------- CURSORES ---------------------------------

      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
              ,cop.nmextcop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

      -- Cadastro de seguros
      CURSOR cr_crapseg (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_dtinicio IN DATE,
                         pr_dtlimite IN DATE) IS
      SELECT seg.nrdconta
            ,seg.cdcooper
            ,seg.cdsegura
            ,seg.tpseguro
            ,seg.tpplaseg
            ,seg.nrctrseg
            ,seg.cdagenci
            ,seg.vlpreseg
            ,seg.qtprepag
            ,seg.dtinivig
            ,seg.dtfimvig     
             ,row_number() OVER(PARTITION BY cdcooper ORDER BY seg.tpseguro,
                                                               seg.cdsegura,
                                                               seg.cdagenci,
                                                               seg.nrdconta,
                                                               seg.nrctrseg) current_of            
            ,COUNT(*) OVER(PARTITION BY cdcooper) last_of       
        FROM crapseg  seg
       WHERE seg.cdcooper  = pr_cdcooper   
         AND seg.tpseguro >= 11          
         AND seg.dtfimvig >= pr_dtinicio
         AND seg.dtfimvig <= pr_dtlimite
         AND seg.dtcancel IS NULL
             ORDER BY seg.tpseguro,
                      seg.cdsegura,
                      seg.cdagenci,
                      seg.nrdconta,
                      seg.nrctrseg;
      rw_crapseg cr_crapseg%ROWTYPE;
      
      -- Tabela de associados
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.nrdconta
            ,ass.cdcooper
            ,ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
        
      -- Cadastro de Seguradoras
      CURSOR cr_crapcsg (pr_cdcooper IN crapcop.cdcooper%TYPE,
                         pr_cdsegura IN crapseg.cdsegura%TYPE) IS
      SELECT csg.nmsegura
      FROM crapcsg csg
      WHERE csg.cdcooper = pr_cdcooper
        AND csg.cdsegura = pr_cdsegura;
      rw_crapcsg cr_crapcsg%ROWTYPE;                                  
      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      ------------------------------- VARIAVEIS -------------------------------

      vr_dsrefere VARCHAR2(50);
      vr_dsseguro VARCHAR2(50);
      vr_nmresseg VARCHAR2(50);
      vr_mensagem VARCHAR2(50);
      vr_geramsg  NUMBER := 0; 
      vr_qttotpro INTEGER;
      vr_vltotpre NUMBER;
      vr_indice VARCHAR2(20);
      vr_flgremarq VARCHAR2(1);
      vr_flg_impri VARCHAR2(1) := 'S';
      vr_dtinicio DATE;
      vr_dtlimite DATE;
      vr_nmarqimp VARCHAR2(100);

      --------------------------- SUBROTINAS INTERNAS --------------------------

            --Procedure que escreve linha no arquivo CLOB
      PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2) IS
      BEGIN
        --Escrever no arquivo CLOB
        dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);
      END;
      
  BEGIN
    --------------- VALIDACOES INICIAIS -----------------

    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => NULL);
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
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
      -- Montar mensagem de critica
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
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;

    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
    IF to_char(rw_crapdat.dtmvtolt,'mm') = 12 THEN
      -- Primeiro dia do proximo ano
      vr_dtinicio := TRUNC(add_months(rw_crapdat.dtmvtolt,12),'yyyy');
    ELSE
      -- Primeiro dia do mês seguinte
      vr_dtinicio := (TRUNC(add_months(rw_crapdat.dtmvtolt,1),'mm'));
    END IF;

    IF to_char(vr_dtinicio,'mm') = 12 THEN
      -- Ultimo dia do mes seguinte
      vr_dtlimite := (TRUNC(add_months(vr_dtinicio,12),'yyyy')-1);
    ELSE
      -- Ultimo dia do mes seguinte
      vr_dtlimite := (TRUNC(add_months(vr_dtinicio,1),'mm')-1);
    END IF;
    -- gravar informações do relatorio
    -- escrever por extenso mes/ano
    vr_dsrefere := 'SEGUROS A VENCER EM ' ||
                   gene0001.vr_vet_nmmesano(to_char(vr_dtinicio,'mm')) || '/' || to_char(vr_dtinicio,'yyyy');

    -- Zerar variaveis
    vr_qttotpro := 0;
    vr_vltotpre := 0;
        
    -- Inicializar o CLOB
    vr_des_xml := null;
    dbms_lob.createtemporary(vr_des_xml, true);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);

    -------------------------------------------
    -- Iniciando a geração do XML
    -------------------------------------------

    vr_geramsg := 0;
    
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl417>');

    -- Buscar seguros
    FOR rw_crapseg IN cr_crapseg(pr_cdcooper => pr_cdcooper,
                                 pr_dtinicio => vr_dtinicio,
                                 pr_dtlimite => vr_dtlimite) LOOP
      -- verificar se existe associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => rw_crapseg.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- se não existir gera log com a conta
      IF cr_crapass%NOTFOUND THEN

        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic ||
                                                   ' - CONTA = '  ||
                                                   gene0002.fn_mask(rw_crapseg.nrdconta,'zzzz.zzz.9'));
        CLOSE cr_crapass;
        -- Caso não exista, gera log e continua rotina
        CONTINUE;                                                   
      END IF;
      -- Se o cursor estiver aberto, fecha o mesmo
      IF cr_crapass%ISOPEN THEN
        CLOSE cr_crapass;
      END IF;
      -- se for o primeiro, first-of
      IF rw_crapseg.current_of = 1 THEN
        -- buscar seguradora
        OPEN cr_crapcsg(pr_cdcooper => pr_cdcooper,
                        pr_cdsegura => rw_crapseg.cdsegura);
        FETCH cr_crapcsg INTO rw_crapcsg;
        -- se não encontrou seguradora
        IF cr_crapcsg%NOTFOUND THEN
          vr_cdcritic := 556;
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2 -- Erro tratato
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || vr_cdprogra || ' --> '
                                                     || vr_dscritic ||
                                                     ' - SEGURADORA = '  ||
                                                     gene0002.fn_mask(rw_crapseg.cdsegura,'zzz.zzz.zz9'));
          CLOSE cr_crapcsg;
          -- Caso não exista, gera log e continua rotina
          CONTINUE;                                                           
        END IF;        
        -- fechar seguradora
        IF cr_crapcsg%ISOPEN THEN
          CLOSE cr_crapcsg;
        END IF;
        -- gravar nome da seguradora
        vr_nmresseg := SubStr(rw_crapcsg.nmsegura,1,50);
        IF rw_crapseg.tpseguro = 11   THEN
          vr_dsseguro := '** SEGURO RESIDENCIAL **';
        ELSE 
          vr_dsseguro := '';
        END IF;          
        -- Tag conteudo, escrever o titulo
        pc_escreve_xml('<refere>');
          pc_escreve_xml( '<nmresseg>' || SubStr(vr_nmresseg,1,50) || '</nmresseg>' ||
                          '<dsseguro>' || SubStr(vr_dsseguro,1,50) || '</dsseguro>' ||
                          '<dsrefere>' || SubStr(vr_dsrefere,1,50) || '</dsrefere>');
        pc_escreve_xml('</refere>');        
      END IF; -- final do first-of       
      
      vr_indice := to_char(rw_crapseg.nrdconta) || to_char(rw_crapseg.nrctrseg);
      
      -- abrir tag do seguro
      pc_escreve_xml('<seguro>');
      
        -- Gravar XML com as informações
        pc_escreve_xml( '<nrdconta>' || to_char(gene0002.fn_mask(rw_crapseg.nrdconta,'zzzz.zzz.9')) || '</nrdconta>' ||
                        '<nrctrseg>' || to_char(gene0002.fn_mask(rw_crapseg.nrctrseg,'zz.zzz.zz9')) || '</nrctrseg>' ||
                        '<tpplaseg>' || to_char(gene0002.fn_mask(rw_crapseg.tpplaseg,'zz9')) || '</tpplaseg>' ||
                        '<cdagenci>' || to_char(gene0002.fn_mask(rw_crapseg.cdagenci,'zz9')) || '</cdagenci>' ||
                        '<nmprimtl>' || SubStr(rw_crapass.nmprimtl,1,34) || '</nmprimtl>' ||
                        '<vlpreseg>' || to_char(nvl(rw_crapseg.vlpreseg,0),'fm999G999G990D00') || '</vlpreseg>' ||
                        '<qtprepag>' || to_char(gene0002.fn_mask(rw_crapseg.qtprepag,'zz9')) || '</qtprepag>' ||
                        '<dtinivig>' || to_char(rw_crapseg.dtinivig,'DD/MM/YYYY') || '</dtinivig>' ||
                        '<dtfimvig>' || to_char(rw_crapseg.dtfimvig,'DD/MM/YYYY') || '</dtfimvig>');
      pc_escreve_xml('</seguro>');
      -- somar totais
      vr_qttotpro := vr_qttotpro + 1;
      vr_vltotpre := vr_vltotpre + rw_crapseg.vlpreseg;
            
      -- se for o ultimo registro fecha tag xml do seguro
      IF rw_crapseg.current_of = rw_crapseg.last_of THEN
        -- escrever tag total
        pc_escreve_xml('<total>');
          pc_escreve_xml('<qttotpro>'||to_char(gene0002.fn_mask(vr_qttotpro,'zzz.zz9')) || '</qttotpro>' ||
                         '<vltotpre>'|| to_char(nvl(vr_vltotpre,0),'fm999G999G990D00') || '</vltotpre>');
        pc_escreve_xml('</total>');
      END IF;
      
    END LOOP;                                                                      
     
    -- Busca do diretório base da cooperativa e a subpasta de relatórios
    vr_path_arquivo := gene0001.fn_diretorio( pr_tpdireto => 'C' -- /usr/coop
                                             ,pr_cdcooper => pr_cdcooper); --> Gerado no diretorio /rl
    
    -- se tiver informações
    IF NVL(vr_qttotpro,0) > 0 THEN     
      -- caminho do relatório        
      vr_nmarqimp := vr_path_arquivo||'/rl/crrl417';
      
      -- Busca destinatario do relatorio
      vr_xml_emails := GENE0001.fn_param_sistema('CRED',pr_cdcooper,'CRRL417_EMAIL');
      -- Não remove arquivo após envio
      vr_flgremarq := 'N';
    ELSE
      vr_mensagem := 'NAO HA SEGUROS A VENCER PARA O PROXIMO MES';      
      -- Não passar destinatários, o que acaba não gerando o e-mail      
      vr_nmarqimp := vr_path_arquivo||'/arq/'||vr_cdprogra ||'_ANEXO'||GENE0002.fn_busca_time;
      vr_flg_impri := 'N';

      -- Remove arquivo após envio
      vr_flgremarq := 'S';
      -- não envia email
      vr_xml_emails := NULL;
    END IF;

    IF vr_mensagem IS NOT NULL THEN
      -- tag mensagem
      vr_geramsg := 1; -- gera mensagem
      pc_escreve_xml('<mensagem>');        
        pc_escreve_xml('<dsmensag>'||to_char(vr_mensagem)||'</dsmensag>'||
                       '<geramsg>' ||to_char(vr_geramsg)||'</geramsg>');
      pc_escreve_xml('</mensagem>');              
    END IF;
    
    -- Fim da tag crrl417
    pc_escreve_xml('</crrl417>');  
                                  
    -- Submeter o relatório gerando o arquivo de extensão txt, para enviar por e-mail
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                          --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra                          --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt                  --> Data do movimento atual
                               ,pr_dsxml     => vr_des_xml                           --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/crrl417'                           --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl417.jasper'                     --> Arquivo de layout do iReport
                               ,pr_dsparams  => NULL                                 --> Sem parâmetros
                               ,pr_dsarqsaid => vr_nmarqimp||'.lst'                  --> Arquivo final com o path
                               ,pr_qtcoluna  => 132                                  --> 132 colunas
                               ,pr_flg_gerar => 'N'                                  --> Geraçao na hora
                               ,pr_flg_impri => vr_flg_impri                         --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '132col'                             --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                                    --> Número de cópias
                               ,pr_sqcabrel  => 1                                    --> Qual a seq do cabrel
                               ,pr_dspathcop => vr_path_arquivo||'/converte/'        --> Lista sep. por ';' de diretórios a copiar o arquivo
                               ,pr_dsmailcop => vr_xml_emails                        --> Lista sep. por ';' de emails para envio do relatório
                               ,pr_fldosmail => 'S'                                  --> Flag para converter o arquivo gerado em DOS antes do e-mail
                               ,pr_dsassmail => 'SEGUROS A VENCER - '||rw_crapcop.nmrescop --> Assunto do e-mail que enviará o relatório
                               ,pr_dscormail => 'ARQUIVO EM ANEXO.'                  --> HTML corpo do email que enviará o relatório
                               ,pr_dsextmail => 'txt'                                --> Enviar o anexo como txt
                               ,pr_flgremarq => vr_flgremarq                         --> Flag para remover o arquivo após cópia/email
                               ,pr_des_erro  => vr_dscritic);                    --> Saída com erro

    -- Verifica se ocorreram erros na geração do XML
    IF vr_dscritic IS NOT NULL THEN
      pr_dscritic := vr_dscritic;
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;    

    -- Liberando a memória alocada pro CLOB
    -- Finaliza o XML
    dbms_lob.close(vr_des_xml);
    dbms_lob.freetemporary(vr_des_xml);
    
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Salvar informações atualizadas   
    COMMIT;
  EXCEPTION
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic := NVL(vr_cdcritic,0);
      pr_dscritic := vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps440;
/

