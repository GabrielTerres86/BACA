CREATE OR REPLACE PACKAGE CECRED.TELA_INTEAS is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : TELA_INTEAS
      Sistema  : Rotinas referentes tela de integração com sistema Easy-Way
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Abril/2016.                   Ultima atualizacao: 16/08/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes tela de integração com sistema Easy-Way

      Alteracoes: 
                  10/04/2018 - Projeto 414 - Regulatório FATCA/CRS
                               (Marcelo Telles Coelho - Mouts). 

                  16/08/2018 - Inclusão da Aplicação Programda - Proj. 411.2 (CIS Corporate)

  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Gerar log da easyway
  PROCEDURE pc_gera_log_easyway (pr_nmarqlog IN VARCHAR2,
                                 pr_dsmsglog IN VARCHAR2 );
                                 
  PROCEDURE pc_gera_arq_cadastro_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                      pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                      pr_dtmvtolt  IN DATE,                    --> Data do movimento
                                      pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                      pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                      ---- OUT ----                                                                               
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica
  
  --> Procedimento responsavel em gerar a movimentação das operações dos cooperados
  PROCEDURE pc_gera_arq_movimento_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                       
  
  --> Procedimento responsavel em gerar o arquivo com os saldos das operações dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_saldo_ope_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                       
  --> Procedimento responsavel em gerar o arquivo dos titulares dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_titulares_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                       
  --> Procedimento responsavel em gerar o arquivo com os terceiros vinculados ao cooperados para a Easyway
  PROCEDURE pc_gera_arq_terceiros_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
  
  --> Procedimento para chamar rotina pelo ayllosweb
  PROCEDURE pc_trata_param_TELA_INTEAS (pr_tlcdcoop  IN crapcop.cdcooper%TYPE,  --> codigo da cooperativa informado na tela 
                                        pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_dtiniger  IN VARCHAR2,               --> Data Início do período de geração 
                                        pr_dtfimger  IN VARCHAR2,               --> Data Final  do período de geração
                                        pr_dtmvtolt  IN VARCHAR2,               --> Data do movimento
                                        pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado – 0 para todos os arquivos 
                                        pr_xmllog    IN VARCHAR2,               --> XML com informações de LOG
                                        ---- OUT ----                                                                                                                         
                                        pr_cdcritic OUT PLS_INTEGER,            --> Código da crítica
                                        pr_dscritic OUT VARCHAR2,               --> Descrição da crítica
                                        pr_retxml   IN OUT NOCOPY XMLType,      --> Arquivo de retorno do XML
                                        pr_nmdcampo OUT VARCHAR2,               --> Nome do campo com erro
                                        pr_des_erro OUT VARCHAR2);
                                        
  --> Procedimento responsavel por disparar a geração dos arquivos de integração Easyway
  PROCEDURE pc_gera_arquivos_integracao ( pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                          pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                          pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                          pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                          pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                          pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado – 0 para todos os arquivos 
                                          ---- OUT ----                                                                               
                                          pr_nmarqlog OUT VARCHAR2,   --> nome do arquivo de log
                                          pr_cdcritic OUT PLS_INTEGER,            --> Código da crítica
                                          pr_dscritic OUT VARCHAR2 );               --> Descrição da crítica
                                                                                    
                                                                                   
END TELA_INTEAS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_INTEAS IS
  /* ---------------------------------------------------------------------------------------------------------------


      Programa : TELA_INTEAS
      Sistema  : Rotinas referentes tela de integração com sistema Easy-Way
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Abril/2016.                   Ultima atualizacao: 20/10/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes tela de integração com sistema Easy-Way

      Alteracoes: 20/10/2016 - Ajuste nas rotinas para garantir posicionamento 
                               dos arquivos(inclusao nvl). (Odirlei-AMcom)
                  
                  14/11/2016 - No arquivo Cadastro foi separada a geracao dos
                               procuradores e responsaveis de menores. Isso porque
                               devemos priorizar a exportacao dos dados das contas, 
                               que, provavelmente, estao mais completas que os dados
                               dos procuradores e responsaveis.
                               
                               Ajustado tambem geracao dos titulares. Quando nao for
                               o primeiro titular, tentaremos buscar uma conta na qual
                               aquela pessoa eh o primeiro titular. Isso para garantir
                               que os dados estejam atualizados e estar de acordo com o 
                               funcionamento do Ayllos Web.
                               
                  18/11/2016 - Ajustado para quando a data de demissao do cooperado for
                               posterior a data final de geracao, exportar como se a conta
                               estivesse ativa (exportando nulo no lugar do dtdemiss).
      
                  05/12/2016 - Alterado dtdemis por dtelimin, pois dtdemiss ainda permite movimentacao da conta
                               e a conta ainda possui saldos, já dtelimin é apos a conta não possuir mais movimentação
                               e os saldos zerados. (Odirlei-AMcom)
                               
                  29/12/2016 - Criado funcao fn_ignora_conta para identificar contas que foram migradas da
                               Transulcred - Transpocred e se o periodo final for ate final de 2016. Na cooperativa
                               9 - Transpocred, soh devemos exportar essas contas apos 2016. Ajustado buscas
                               de cooperativas para trazer alem daquelas ativas, trazer tambem a transulcred. Isso
                               se faz necessario, pois a exportacao da Transulcred ainda ocorrera em janeiro 2017,
                               buscando dados de 2016.
                               Nas proximas alteracoes, remover essas funcoes para evitar deixar lixo no codigo.
                               
                  15/01/2018 - Melhorar o registro do log para situacoes de erro na geracao do arquivo de cadastro.
                               Ajustar estouro dos campos de endereco no arquivo de cadastro, para procuradores
                               e representantes (Anderson SD 832274).
                               
                  30/04/2018 - Alterados codigos de situacao "pr_cdsitdct". PRJ366 (Lombardi).
                               
                  16/08/2018 - Inclusão da Aplicação Programda - Proj. 411.2 (CIS Corporate)

  ---------------------------------------------------------------------------------------------------------------*/  
  --> Function para formatar o cpf/cnpj conforme padrao da easyway
  FUNCTION fn_nrcpfcgc_easy (pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE,
                             pr_inpessoa IN crapass.inpessoa%TYPE) RETURN VARCHAR2 IS
  BEGIN
  
    IF pr_inpessoa IN (1,0) THEN
      --> Completar com zeros o tamanho para CPF(11) 
      --  e completar com espaco conforme o layout easyway
      RETURN lpad(lpad(pr_nrcpfcgc,11,'0'),14,' ');
    ELSE
      RETURN lpad(pr_nrcpfcgc,14,'0');
    END IF;
  
  END fn_nrcpfcgc_easy;
  
  /* Qualquer alteração aqui, por favor, avalir se continua removendo caracteres 
     estranhos como por exemplo: ""
     Em algumas alterações, deixou de remover este caracter.
     Obs.: Nao utilizar esta funcao sobre a linha completa do arquivo txt,
           pois remove tambem a quebra de linha.
  */
  FUNCTION fn_remove_caract_espec(pr_string IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE( gene0007.fn_caract_acento(pr_string,1,'#$&%¹²³ªº°*!?<>/\|',
                                                                 '                  ')
                          ,'[^a-zA-Z0-9Ç@:._ +,();=-]+',' ');
  END fn_remove_caract_espec;
  
  /* Funcao responsavel por verificar se a conta eh migrada da TRANSULCRED - TRANSPOCRED,
     e se o ano de referencia eh 2016. Apos a geracao deste periodo, devemos apagar
     essa funcao e os locais de utilizacao. 
     
     Quando retornar verdadeiro, a conta nao sera gerada nos arquivos txt. */
  FUNCTION fn_ignorar_conta(pr_cdcooper IN crapass.cdcooper%TYPE,
                            pr_nrdconta IN crapass.nrdconta%TYPE,
                            pr_dtiniger IN DATE,
                            pr_dtfimger IN DATE) RETURN BOOLEAN IS
    
    vr_idx PLS_INTEGER;
    CURSOR cr_craptco(pr_cdcooper craptco.cdcooper%TYPE,
                      pr_nrdconta craptco.nrdconta%TYPE) IS
     SELECT 1
       FROM craptco tco
      WHERE tco.cdcooper = 9  /* Transpocred */
        AND tco.cdcopant = 17 /* Transulcred */
        AND tco.cdcooper = pr_cdcooper
        AND tco.nrdconta = pr_nrdconta;
        
  BEGIN
   /* Se nao for Transpocred */
   IF (pr_cdcooper <> 9 ) THEN
     RETURN FALSE;
   END IF;
   
   /* Se o periodo final for menor ou igual a 2016, vamos buscar a conta na CRAPTCO,
      se existir o registro, a conta nao deve ser exportada */
   IF (extract(year from pr_dtfimger) <= 2016) THEN
       
       /* Vamos verificar se a conta foi migrada */
       OPEN cr_craptco (pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta);
       FETCH cr_craptco INTO vr_idx;
       IF cr_craptco%NOTFOUND THEN
         CLOSE cr_craptco;
         RETURN FALSE;
       ELSE
         CLOSE cr_craptco;
         RETURN TRUE;
       END IF;
   ELSE
     RETURN FALSE;
   END IF;
  END fn_ignorar_conta;
  
  --> Gerar log da easyway
  PROCEDURE pc_gera_log_easyway (pr_nmarqlog IN VARCHAR2,
                                 pr_dsmsglog IN VARCHAR2 )IS
                         
    vr_dsdirlog      VARCHAR2(100);
  BEGIN
    
    vr_dsdirlog := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 3, 
                                             pr_cdacesso => 'DIR_EASYWAY');
                                             
    btch0001.pc_gera_log_batch(pr_cdcooper   => 3, 
                             pr_ind_tipo_log => 1, 
                             pr_des_log      => to_char(SYSDATE,'HH24:MI:SS')||' -> '||
                                                pr_dsmsglog, 
                             pr_nmarqlog     => pr_nmarqlog, 
                             pr_flfinmsg     => 'N',
                             pr_dsdirlog => vr_dsdirlog);
    
  END pc_gera_log_easyway;
  
  --> Procedimento responsavel em gerar o arquivo de Cadastro de Cooperados para a Easyway
  PROCEDURE pc_gera_arq_cadastro_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                      pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                      pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                      pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo
                                      pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                      ---- OUT ----                                                                               
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_gera_arq_cadastro_ass        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 10/11/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel em gerar o arquivo de Cadastro de Cooperados para a Easyway
    
    Alteração : Alterado para remover os acentos das linhas de exportação desse arquivo,
	            por solicitação do Mathera (10/11/2016).
        
                Alterado para quando os segundo e demais titulares nao tiverem endereco preenchido,
                buscar do primeiro titular. 
                Alterado para quando os procuradores e representantes de menores nao tiverem endereco
                preenchido, buscar da conta principal (17/11/2016).
                
                Ajustado para que a busca pela conta mais atualizada desconsidere as contas que foram
                demitidas antes do período inicial (28/11/2016).
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper
             /* Ou a cooperativa esta ativa ou eh a Transulcred */
         AND (cop.flgativo = 1 or cop.cdcooper = 17)
       ORDER BY cop.cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
     
    --> Buscar os CPFs/CNPJs a serem enviados para a Easyway
    CURSOR cr_crapass_nrcpfcgc(pr_nrdconta crapass.nrdconta%TYPE,
                               pr_dtiniger DATE,
                               pr_dtfimger DATE ) IS
      SELECT ass.nrcpfcgc
            ,ass.nmprimtl
            ,ass.inpessoa
            ,ass.dtnasctl
            ,ass.nrdconta
            ,ass.cdcooper
            ,ass.cdsitdct
            ,ass.dtadmiss
            ,decode(ass.inpessoa,1,'F','J') dspessoa
            ,to_char(nvl(
             (select max(alt.dtaltera)
                from crapalt alt
               where alt.cdcooper = ass.cdcooper
                 and alt.nrdconta = ass.nrdconta),ass.dtadmiss),'RRRRMMDD') dtaltera
        FROM crapass ass
       WHERE ass.cdcooper = decode(pr_cdcooper, 0, ass.cdcooper, pr_cdcooper) 
         AND ass.nrdconta = decode(pr_nrdconta, 0, ass.nrdconta, pr_nrdconta)
         AND ass.dtadmiss <= pr_dtfimger   -- Cooperados admitidos até a data final
         AND (ass.dtelimin IS NULL OR      -- Cooperados não eliminacao da conta                       
              ass.dtelimin >= pr_dtiniger) -- ou eliminacao depois da data inicial 
       ORDER BY ass.nrcpfcgc;          
    
    --> Buscar informacoes dos cooperados com o cadastro mais atualizado
    CURSOR cr_crapass (pr_nrcpfcgc crapass.nrcpfcgc%TYPE)IS
      SELECT alt.cdcooper
            ,alt.nrdconta
            ,to_char(alt.dtaltera,'RRRRMMDD') dtaltera
            ,ass.inpessoa
            ,ass.nrcpfcgc
            ,ass.cdsitdct
        FROM crapalt alt
            ,crapass ass
       WHERE ass.nrcpfcgc = pr_nrcpfcgc
         AND alt.cdcooper = ass.cdcooper
         AND alt.nrdconta = ass.nrdconta
             /* Considerar apenas as contas nao eliminadas, 
                ou demitidas depois do periodo inicial */
         AND (ass.dtelimin IS NULL OR
              ass.dtelimin >= pr_dtiniger) 
    ORDER BY alt.dtaltera DESC;
    rw_crapass     cr_crapass%ROWTYPE;
    rw_crapass_ttl cr_crapass%ROWTYPE;
    
    --> Buscar titulares
    CURSOR cr_crapttl ( pr_cdcooper  crapttl.cdcooper%TYPE,
                        pr_nrdconta  crapttl.nrdconta%TYPE,
                        pr_idseqttl  crapttl.idseqttl%TYPE) IS
      SELECT nvl(ttl.nmextttl, ass.nmprimtl) nmprimtl
            ,nvl(ttl.inpessoa, ass.inpessoa) inpessoa
            ,to_char(nvl(ttl.dtnasttl, ass.dtnasctl), 'RRRRMMDD') dtnasctl
            ,nvl(ttl.nrcpfcgc, ass.nrcpfcgc) nrcpfcgc
            ,decode(nvl(ttl.inpessoa, ass.inpessoa), 1, 'F', 'J') dspessoa
            ,NVL(ttl.idseqttl, 1) idseqttl
            ,ass.cdcooper
            ,ass.nrdconta
        FROM crapttl ttl
            ,crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = ttl.cdcooper(+)
         AND ass.nrdconta = ttl.nrdconta(+)
         --> Trazer todos os titulares caso prm seja 0 ou apenas do parametro
         AND ttl.idseqttl(+) = decode(pr_idseqttl,0,ttl.idseqttl(+),pr_idseqttl);
    
    --> Buscar endereço do cooperado
    CURSOR cr_crapenc ( pr_cdcooper  crapenc.cdcooper%TYPE,
                        pr_nrdconta  crapenc.nrdconta%TYPE,
                        pr_idseqttl  crapenc.idseqttl%TYPE,
                        pr_inpessoa  crapass.inpessoa%TYPE) IS
      SELECT TRIM(substr(enc.dsendere,
                          instr(TRIM(enc.dsendere), ' '),
                          length(enc.dsendere))) AS endereco
             ,enc.nrendere 
             ,substr(enc.complend,1,47) complend -- Heckmann/Amcom Task 11393 - Conforme sugerido pelo Ornelas/Jaison 
             ,enc.nrcepend 
             ,enc.nmbairro 
             ,enc.nmcidade 
             ,enc.cdufende 
             ,TRIM(substr(enc.dsendere, 1, instr(TRIM(enc.dsendere), ' '))) AS tp_lograd
         FROM crapenc enc
        WHERE enc.cdcooper = pr_cdcooper
          AND enc.nrdconta = pr_nrdconta
          AND enc.idseqttl IN(1,pr_idseqttl)
          AND enc.tpendass = (CASE pr_inpessoa
                                WHEN 1 THEN 10
                                ELSE 9
                              END)
          AND (
                enc.idseqttl = 1 or   /* Ou é o primeiro titular, Ou o endereco esta preenchido */
               (enc.idseqttl > 1 and trim(enc.dsendere) is not null and trim(nmcidade) is not null)
              )
        ORDER BY enc.idseqttl DESC; --Retornar o endereço do titular passado por param
                                    -- caso nao existir retorna do principal
    rw_crapenc cr_crapenc%ROWTYPE;
    
    --> Buscar telefone do cooperado
    CURSOR cr_craptfc ( pr_cdcooper  craptfc.cdcooper%TYPE,
                        pr_nrdconta  craptfc.nrdconta%TYPE,
                        pr_idseqttl  craptfc.idseqttl%TYPE) IS
      SELECT '(' || tfc.nrdddtfc || ') '|| tfc.nrtelefo nrtelefo
        FROM craptfc tfc
       WHERE tfc.cdcooper = pr_cdcooper
         AND tfc.nrdconta = pr_nrdconta
         AND tfc.idseqttl IN (1,pr_idseqttl)
       ORDER BY tfc.idseqttl DESC; --Retornar o endereço do titular passado por param
                                    -- caso nao existir retorna do principal
    rw_craptfc cr_craptfc%ROWTYPE;
    
    --> Buscar email do cooperado
    CURSOR cr_crapcem ( pr_cdcooper  crapcem.cdcooper%TYPE,
                        pr_nrdconta  crapcem.nrdconta%TYPE,
                        pr_idseqttl  crapcem.idseqttl%TYPE) IS
      SELECT cem.dsdemail
        FROM crapcem cem
       WHERE cem.cdcooper = pr_cdcooper
         AND cem.nrdconta = pr_nrdconta
         AND cem.idseqttl IN (1,pr_idseqttl) 
       ORDER BY cem.idseqttl DESC,
                cem.dtmvtolt DESC;       
    rw_crapcem  cr_crapcem%ROWTYPE;
    
    --> Buscar dados pessoa juridica
    CURSOR cr_crapjur ( pr_cdcooper  crapenc.cdcooper%TYPE,
                        pr_nrdconta  crapenc.nrdconta%TYPE) IS
      SELECT to_char(jur.nrinsmun) nrinsmun
            ,to_char(jur.nrinsest) nrinsest
            ,to_char(jur.dtiniatv, 'RRRRMMDD') dtiniatv 
            ,(CASE nvl(jur.nrinsest, 0)
                WHEN 0 THEN 'S'
                ELSE 'N'
              END) AS isento_inscr_estadual
       FROM crapjur jur
      WHERE jur.cdcooper = pr_cdcooper
        AND jur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    --> Buscar menor data de admissao do cpf/cnpj
	/*  Como existem casos que a data de admissao esta maior que a data de demissao,
      no sistema da Easyway foi adicionado um regra para alterar a data de admissao
      para o primeiro dia util do mes. Entao como foi trocado o sistema para a
      geracao da e-financeira, vamos implementar a mesma regra aqui para
      nao gerarmos informacao divergente.  */
    CURSOR cr_crapass_admiss (pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT to_char(MIN(
                gene0005.fn_valida_dia_util(pr_cdcooper => ass.cdcooper
                                           ,pr_dtmvtolt => trunc(nvl(nvl(ass.dtadmiss,ass.dtmvtolt),pr_dtfimger),'MM'))
             ),'RRRRMMDD') dtadmiss
        FROM crapass ass
       WHERE nrcpfcgc = pr_nrcpfcgc;
    rw_crapass_admiss cr_crapass_admiss%ROWTYPE;
    
    --> Procuradores Pessoa Física
    CURSOR cr_crapcrl (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      -- Procurador
      SELECT avt.nrcpfcgc
            ,avt.nrdctato
            ,nvl(ass.inpessoa,avt.inpessoa) inpessoa
            ,ass.cdsitdct
            ,avt.nmdavali
            ,to_char(avt.dtnascto,'RRRRMMDD') dtnascto
            ,TRIM(substr(avt.dsendres##1,
                         instr(TRIM(avt.dsendres##1), ' '),
                         length(avt.dsendres##1))) AS dsendres
            ,avt.nrendere
            ,avt.complend
            ,avt.nrcepend
            ,avt.nmbairro
            ,avt.nmcidade
            ,avt.cdufresd
            ,TRIM(substr(avt.dsendres##1, 1, instr(TRIM(avt.dsendres##1), ' '))) tplograd
            ,to_char(avt.dtmvtolt,'RRRRMMDD') dtmvtolt
            ,decode(nvl(ass.inpessoa,1),1,'F','J') dspessoa
        FROM crapavt avt
            ,crapass ass
       WHERE avt.cdcooper = ass.cdcooper(+)
         AND avt.nrdctato = ass.nrdconta(+)
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.tpctrato = 6
         AND (avt.nrcpfcgc > 0 OR
              avt.nrdctato > 0)
     UNION    
      -- Responsavel legal
      SELECT nvl(ass.nrcpfcgc, crl.nrcpfcgc) AS nrcpfcgc
            ,crl.nrdconta nrdctato
            ,NVL(ass.inpessoa, 1) inpessoa
            ,ass.cdsitdct
            ,crl.nmrespon
            ,to_char(crl.dtnascin,'RRRRMMDD') dtnascin
            ,TRIM(substr(crl.dsendres,
                         instr(TRIM(crl.dsendres), ' '),
                         length(crl.dsendres))) AS dsendres
            ,crl.nrendres
            ,crl.dscomres
            ,crl.cdcepres
            ,crl.dsbaires
            ,crl.dscidres
            ,crl.dsdufres
            ,TRIM(substr(crl.dsendres, 1, instr(TRIM(crl.dsendres), ' '))) tplograd
            ,to_char(crl.dtmvtolt,'RRRRMMDD') dtmvtolt
            ,decode(nvl(ass.inpessoa,1),1,'F','J') dspessoa
        FROM crapcrl crl
            ,crapass ass
       WHERE crl.cdcooper = ass.cdcooper(+)
         AND crl.nrdconta = ass.nrdconta(+)
         AND crl.cdcooper = pr_cdcooper
         AND crl.nrctamen = pr_nrdconta
         AND (crl.nrdconta > 0 OR 
              crl.nrcpfcgc > 0);
    
    --> Socios/Procuradores Pessoa juridica
    CURSOR cr_crapavt (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      
      SELECT avt.nrcpfcgc
            ,avt.nrdconta
            ,avt.nrdctato
            ,nvl(ass.inpessoa,avt.inpessoa) inpessoa
            ,ass.cdsitdct
            ,avt.nmdavali
            ,to_char(avt.dtnascto,'RRRRMMDD') dtnascto 
            ,TRIM(substr(avt.dsendres##1,
                         instr(TRIM(avt.dsendres##1), ' '),
                         length(avt.dsendres##1))) AS dsendres
            ,avt.nrendere
            ,avt.complend
            ,avt.nrcepend
            ,avt.nmbairro
            ,avt.nmcidade
            ,avt.cdufresd
            ,TRIM(substr(avt.dsendres##1, 1, instr(TRIM(avt.dsendres##1), ' '))) tplograd
            ,to_char(avt.dtmvtolt,'RRRRMMDD') dtmvtolt
            ,decode(nvl(ass.inpessoa,1),1,'F','J') dspessoa
        FROM crapavt avt
            ,crapass ass
       WHERE avt.cdcooper = ass.cdcooper(+)
         AND avt.nrdctato = ass.nrdconta(+)
         AND avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.tpctrato = 6
         AND (avt.nrcpfcgc > 0 OR
              avt.nrdctato > 0);
    
    -- Projeto 414 - Marcelo Telles Coelho - Mouts
    --> Verificar se a pessoa é Reportável (FATCA/CRS)
    CURSOR cr_reportavel (pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
    SELECT inreportavel
      FROM tbreportaval_fatca_crs
     WHERE nrcpfcgc = pr_nrcpfcgc;
    rw_reportavel cr_reportavel%ROWTYPE;

    -- Projeto 414 - Marcelo Telles Coelho - Mouts
    --> Buscar endereço do reportavel
    CURSOR cr_dados_reportavel ( pr_nrcpfcgc tbcadast_pessoa.nrcpfcgc%TYPE) IS
    SELECT e.nmlogradouro
          ,e.nrlogradouro
          ,e.dscomplemento
          ,e.nrcep    dscodigo_postal
          ,e.nmbairro dsbairro
          ,f.dscidade
          ,f.cdestado dsuf
          ,a.tppessoa
          ,c.cdpais
          ,b.nridentificacao
          ,d.cdtipo_proprietario
          ,d.cdtipo_declarado
          ,c.cdpais dsnacionalidade
      FROM tbcadast_pessoa a
          ,tbcadast_pessoa_estrangeira b
          ,crapnac c
          ,tbreportaval_fatca_crs d
          ,tbcadast_pessoa_endereco e
          ,crapmun f
     WHERE a.nrcpfcgc     = pr_nrcpfcgc
       AND b.idpessoa     = a.idpessoa
       AND c.cdnacion     = b.cdpais
       AND d.nrcpfcgc     = a.nrcpfcgc
       AND e.idpessoa     = a.idpessoa
       AND e.tpendereco   = DECODE(a.tppessoa,1,10,9)
       AND f.idcidade     = e.idcidade;
    rw_dados_reportavel cr_dados_reportavel%ROWTYPE;

  -----------> VARIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    vr_idxctrl      VARCHAR2(20);
    
    -- Variáveis para armazenar as informações do arquivo
    vr_dsarquiv        CLOB;
    -- Variável para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    vr_dslinha       VARCHAR2(4000);
    
    vr_idsitcnt      VARCHAR2(1);
    vr_flpriass      BOOLEAN;
    vr_logcompl      VARCHAR2(5000);
    
    ---------> VARIAVEIS AUXILIARES PARA ENDERECAMENTO <---------
    vr_aux_endereco  VARCHAR2(1000);
    vr_aux_nrendere  INTEGER;
    vr_aux_complend  VARCHAR2(1000);
    vr_aux_nrcepend  INTEGER;
    vr_aux_nmbairro  VARCHAR2(1000);
    vr_aux_nmcidade  VARCHAR2(1000);
    vr_aux_cdufende  VARCHAR2(100);
    vr_aux_tplograd  VARCHAR2(100);
  -----------> TEMPTABLES <----------- 
    -- Temptable para controlar se ja processou o cpf/cnpj       
    TYPE typ_tab_nrcpfcnpj IS TABLE OF NUMBER
      INDEX BY VARCHAR2(14);
    
    vr_tab_nrcpfcnpj typ_tab_nrcpfcnpj;
    
    
  -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na variável CLOB
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2,
                              pr_fecha_clob IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_clob);
    END pc_escreve_clob;
    
    
    -- Montar a linha conforme layout easyway
    PROCEDURE pc_escreve_linha_layout(pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                      pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,
                                      pr_inpessoa  IN crapass.inpessoa%TYPE,
                                      pr_dspessoa  IN VARCHAR2,
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,
                                      pr_nmprimtl  IN crapass.nmprimtl%TYPE,
                                      pr_idseqttl  IN crapttl.idseqttl%TYPE,
                                      pr_dtnasctl  IN VARCHAR2,
                                      pr_nrinsmun  IN VARCHAR2,
                                      pr_dtadmiss  IN VARCHAR2,
                                      pr_dtaltera  IN VARCHAR2,
                                      pr_nrinsest  IN VARCHAR2,
                                      pr_isento_inscr_estadual IN VARCHAR2,
                                      ----- OUT ----
                                      pr_dscritic OUT VARCHAR2) IS 
      vr_dslinha  VARCHAR2(3200);
      vr_dscritic VARCHAR2(2000);
    BEGIN
      -- Projeto 414 - Marcelo Telles Coelho - Mouts
      --> Buscar reportável FATCA/CRS
      OPEN cr_reportavel ( pr_nrcpfcgc => pr_nrcpfcgc);
      FETCH cr_reportavel INTO rw_reportavel;
      IF cr_reportavel%NOTFOUND THEN
        rw_reportavel.inreportavel := 'N';
      END IF;
      CLOSE cr_reportavel;

      -- Projeto 414 - Marcelo Telles Coelho - Mouts
      IF rw_reportavel.inreportavel = 'S' THEN
        --> Buscar Endereço reportável FATCA/CRS
        OPEN cr_dados_reportavel ( pr_nrcpfcgc => pr_nrcpfcgc);
        FETCH cr_dados_reportavel INTO rw_dados_reportavel;
        IF cr_dados_reportavel%NOTFOUND THEN
          rw_reportavel.inreportavel := 'N';
        END IF;
        CLOSE cr_dados_reportavel;
      END IF;
      
      --> Buscar endereço do cooperado
      OPEN cr_crapenc ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => pr_idseqttl,
                        pr_inpessoa => pr_inpessoa);
      FETCH cr_crapenc INTO rw_crapenc;
      IF cr_crapenc%NOTFOUND THEN
        CLOSE cr_crapenc;
        vr_dscritic := 'Não foi possivel gerar cadastro do associado'||
                       ' CPF/CNPJ ' ||pr_nrcpfcgc||
                       ' cooper '||pr_cdcooper||
                       ' conta ' ||pr_nrdconta||
                       ', endereço não encontrado';
        RAISE vr_exc_erro;            
        
      END IF;
      CLOSE cr_crapenc;
        
      --> Buscar endereço do cooperado
      rw_craptfc := NULL;
      OPEN cr_craptfc ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => pr_idseqttl);
      FETCH cr_craptfc INTO rw_craptfc;
      CLOSE cr_craptfc;
        
      --> Buscar email do cooperado
      rw_crapcem := NULL;
      OPEN cr_crapcem ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => pr_idseqttl);
      FETCH cr_crapcem INTO rw_crapcem;
      CLOSE cr_crapcem;

      --> Montar linha conforme layout easyway
      vr_dslinha := fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)                 ||     --> CPF/CNPJ Cooperado
                    rpad(fn_remove_caract_espec(nvl(pr_nmprimtl,' ')),60,' ')             ||     --> Nome do Contribuinte
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.endereco,' ')),80,' ')     ||     --> Logradouro
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nrendere,0)), 8,' ')       ||     --> Número
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.complend,' ')),40,' ')     ||     --> Complemento
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nrcepend,0)), 8,' ')       ||     --> CEP
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nmbairro,' ')),20,' ')     ||     --> Bairro
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nmcidade,' ')),30,' ')     ||     --> Descrição Cidade
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.cdufende,' ')), 2,' ')     ||     --> UF
                    rpad(fn_remove_caract_espec(nvl(rw_craptfc.nrtelefo,' ')),15,' ')     ||     --> Telefone   
                    lpad(nvl(pr_dtnasctl,' '),8,' ')              ||     --> Data de Nascimento
                    rpad(nvl(pr_nrinsmun,' '),20,' ')             ||     --> Inscrição Municipal
                    lpad(nvl(pr_dtadmiss,' '),8,' ')              ||     --> Data da Inclusão no sistema de origem
                    lpad(nvl(pr_dtaltera,' '),8,' ')              ||     --> Data última alteração sistema de origem                    
                    'N'   ||               --> Estrangeiro (sem cpf/cnpj) (N - Não é estrangeiro; C - Estrangeiro com CPF;S - Estrangeiro sem CPF)
                    rpad(' ', 3,' ')                              ||     --> Código do País
                    rpad(' ',20,' ')                              ||     --> Numero de Identificação Fiscal (se estrangeiro)
                    rpad(' ', 3,' ')                              ||     --> Natureza da Relação
                    rpad(' ',40,' ')                              ||     --> Descrição do Estado (se estrangeiro)
                    rpad(fn_remove_caract_espec(nvl(rw_crapcem.dsdemail,' ')),60,' ')     ||     --> Email
                    pr_dspessoa                                   ||     --> PF/PJ(F - PF; J – PJ)
                    rpad(nvl(pr_nrinsest,' '),20,' ')             ||     --> Inscrição Estadual
                    vr_idsitcnt                                   ||     --> Status do Contribuinte
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.tp_lograd,' ')),10,' ')    ||     --> Tipo de Logradouro
                    nvl(pr_isento_inscr_estadual,' ')             ||     --> Isento de Inscrição Estadual
                    lpad(' ',19,' ')                              ||     --> GIIN (Global Intermediary Identification Number)
                    lpad(' ',25,' ')                              ||     --> Numero do Passaporte
                    lpad(' ', 1,' ')                              ||     --> Tipo da Instituição Financeira (FATCA)
                    lpad(' ',10,' ')                              ||     --> Tipo de declarado
                    chr(13)||chr(10);                                    --> quebrar linha
         
      -- Projeto 414 - Marcelo Telles Coelho - Mouts
      IF rw_reportavel.inreportavel = 'S' THEN
        vr_dslinha := fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                       pr_inpessoa)                 ||     --> CPF/CNPJ Cooperado
        rpad(fn_remove_caract_espec(nvl(pr_nmprimtl,' ')),60,' ')             ||     --> Nome do Contribuinte
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.nmlogradouro,' ')),80,' ')       ||     --> Logradouro
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.nrlogradouro,0)), 8,' ')         ||     --> Número
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.dscomplemento,' ')),40,' ')      ||     --> Complemento
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.dscodigo_postal,0)), 8,' ')      ||     --> CEP
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.dsbairro,' ')),20,' ')           ||     --> Bairro
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.dscidade,' ')),30,' ')           ||     --> Descrição Cidade
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.dsuf,' ')), 2,' ')               ||     --> UF
        rpad(fn_remove_caract_espec(nvl(rw_craptfc.nrtelefo,' ')),15,' ')              ||     --> Telefone
        lpad(nvl(pr_dtnasctl,' '),8,' ')              ||     --> Data de Nascimento
        rpad(nvl(pr_nrinsmun,' '),20,' ')             ||     --> Inscrição Municipal
        lpad(nvl(pr_dtadmiss,' '),8,' ')              ||     --> Data da Inclusão no sistema de origem
        lpad(nvl(pr_dtaltera,' '),8,' ')              ||     --> Data última alteração sistema de origem

        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.tppessoa,0)),1,' ')            ||     --> Tipo número de identificação (1 - CPF, 2 - CNPJ)
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.cdpais,' ')),3,' ')            ||     --> Código do País
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.nridentificacao,' ')),20,' ')  ||     --> Numero de Identificação Fiscal (NIF)
        rpad(' ', 3,' ')                              ||     --> Natureza da Relação
        rpad(' ',40,' ')                              ||     --> Descrição do Estado (se estrangeiro)
        rpad(fn_remove_caract_espec(nvl(rw_crapcem.dsdemail,' ')),60,' ')              ||     --> Email
        pr_dspessoa                                   ||     --> PF/PJ(F - PF; J – PJ)
        rpad(nvl(pr_nrinsest,' '),20,' ')             ||     --> Inscrição Estadual
        vr_idsitcnt                                   ||     --> Status do Contribuinte
        rpad(fn_remove_caract_espec(nvl(rw_crapenc.tp_lograd,' ')),10,' ')             ||     --> Tipo de Logradouro
        nvl(pr_isento_inscr_estadual,' ')             ||     --> Isento de Inscrição Estadual
        lpad(' ',19,' ')                              ||     --> GIIN (Global Intermediary Identification Number)
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.cdtipo_proprietario,' ')),10,' ')||     --> Tipo de Proprietário
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.dsnacionalidade,' ')),2,' ')     ||     --> Nacionalidade
        rpad(fn_remove_caract_espec(nvl(rw_dados_reportavel.cdtipo_declarado,' ')),10,' ')   ||     --> Tipo de Declarado
        chr(13)||chr(10);                                    --> quebrar linha
      END IF;
         
      pc_escreve_clob(vr_dslinha);
      
      /* Geração de Log */
      IF (fn_remove_caract_espec(nvl(rw_crapenc.endereco,' ')) = ' ') then
         pr_dscritic := nvl(pr_dscritic,' ') || 'Sem logradouro cadastrado.';
      END IF;
      IF (nvl(pr_dtadmiss,' ') = ' ') then
         pr_dscritic := pr_dscritic || ' - Sem data de admissao.';
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao montar linha para a conta '||pr_nrdconta||': '|| SQLERRM;
    END pc_escreve_linha_layout;
    
    --> Rotina para montar layout de cadastro do associado a partir da conta
    PROCEDURE pc_trata_conta( pr_cdcooper  IN crapass.cdcooper%TYPE,
                              pr_nrdconta  IN crapass.nrdconta%TYPE,
                              pr_inpessoa  IN crapass.inpessoa%TYPE,
                              pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,
                              pr_cdsitdct  IN crapass.cdsitdct%TYPE,
                              pr_idseqttl  IN crapttl.idseqttl%TYPE,
                              pr_dtaltera  IN VARCHAR2,
                              pr_dscritic OUT VARCHAR2 )IS
    
      vr_prox_reg EXCEPTION;
      vr_dscritic VARCHAR2(2000) := NULL;
      
    BEGIN
      
      IF pr_inpessoa = 2 THEN
        --> Buscar dados pessoa juridica
        OPEN cr_crapjur ( pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => pr_nrdconta);
        FETCH cr_crapjur INTO rw_crapjur;
        IF cr_crapjur%NOTFOUND THEN
          CLOSE cr_crapjur;
          vr_dscritic := 'Não foi possivel gerar cadastro do associado'||
                         ' CPF/CNPJ ' ||pr_nrcpfcgc||
                         ' cooper '||pr_cdcooper||
                         ' conta ' ||pr_nrdconta||
                         ', Dados pessoa juridica não encontrado';
          RAISE vr_prox_reg;
        END IF;
        CLOSE cr_crapjur;
      END IF;
        
      --> Buscar menor data de admissao do cpf/cnpj
      OPEN cr_crapass_admiss (pr_nrcpfcgc => pr_nrcpfcgc);
      FETCH cr_crapass_admiss INTO rw_crapass_admiss;
      CLOSE cr_crapass_admiss;
      IF rw_crapass_admiss.dtadmiss IS NULL THEN
        vr_dscritic :='Não foi possivel gerar cadastro do associado'||
                      ' CPF/CNPJ ' ||pr_nrcpfcgc||
                      ' cooper '||pr_cdcooper||
                      ' conta ' ||pr_nrdconta||
                      ', data de admissão não encontrada';
        RAISE vr_prox_reg;
      END IF;
        
      IF pr_cdsitdct IN (1, -- Operante 
                         2, -- Em prejuízo
                         3, -- Encerrada pela Cooperativa
                         5, -- Inoperante
                         9  -- Em Análise
                                 )THEN
        vr_idsitcnt := 'A';
      ELSIF pr_cdsitdct = 4 THEN -- Encerrada por demissão
        vr_idsitcnt := 'I';        
      END IF;
      
      --> Buscar titulares da conta, no caso de pessoa Jurica retorna os dados da ass
      FOR rw_crapttl IN cr_crapttl ( pr_cdcooper  => pr_cdcooper,
                                     pr_nrdconta  => pr_nrdconta,
                                     pr_idseqttl  => pr_idseqttl) LOOP      
        
        -- Controle para processar apenas uma vez o cpf/cnpj 
        vr_idxctrl := lpad(rw_crapttl.nrcpfcgc,14,'0');
        IF vr_tab_nrcpfcnpj.exists(vr_idxctrl) THEN
          continue;
        ELSE
          --> Incluir como ja processado
          vr_tab_nrcpfcnpj(vr_idxctrl) := rw_crapttl.nrcpfcgc; 
        END IF;

        /* Quando não for o primeiro titular, pode ser que essa pessoa possua a sua própria conta
            individual. Dessa forma devemos busca-la para termos os dados mais atualizados.
           Obs.: O Ayllos realiza a busca através do CPF também, ver CADA0001.pc_busca_conta.  */
        IF (rw_crapttl.idseqttl > 1 AND
            rw_crapttl.inpessoa = 1 /* Fisica */) THEN
          rw_crapass_ttl := NULL;
          --> Buscar informacoes dos cooperados com o cadastro mais atualizado
          OPEN cr_crapass (pr_nrcpfcgc => rw_crapttl.nrcpfcgc);
          FETCH cr_crapass INTO rw_crapass_ttl;
          IF cr_crapass%FOUND THEN         
            -- Se encontrar vamos utilizar esses dados
            rw_crapttl.nrdconta := rw_crapass_ttl.nrdconta;
            rw_crapttl.cdcooper := rw_crapass_ttl.cdcooper;
            rw_crapttl.nrcpfcgc := rw_crapass_ttl.nrcpfcgc;
            rw_crapttl.inpessoa := rw_crapass_ttl.inpessoa;
            rw_crapttl.idseqttl := 1;
          END IF;
          CLOSE cr_crapass;
        END IF;
        
        ----------->>>>> MONTAR LINHA ARQ <<<<<------------
        pc_escreve_linha_layout(pr_cdcooper  => rw_crapttl.cdcooper,
                                pr_nrcpfcgc  => rw_crapttl.nrcpfcgc, 
                                pr_inpessoa  => rw_crapttl.inpessoa,
                                pr_dspessoa  => rw_crapttl.dspessoa,
                                pr_nrdconta  => rw_crapttl.nrdconta,
                                pr_nmprimtl  => rw_crapttl.nmprimtl,
                                pr_idseqttl  => rw_crapttl.idseqttl,
                                pr_dtnasctl  => (CASE WHEN pr_inpessoa = 2 THEN rw_crapjur.dtiniatv
                                                      ELSE rw_crapttl.dtnasctl
                                                 END),     
                                pr_nrinsmun  => rw_crapjur.nrinsmun,
                                pr_dtadmiss  => rw_crapass_admiss.dtadmiss,
                                pr_dtaltera  => pr_dtaltera,
                                pr_nrinsest  => rw_crapjur.nrinsest,
                                pr_isento_inscr_estadual => rw_crapjur.isento_inscr_estadual,
                                ----- OUT --
                                pr_dscritic  => vr_dscritic);
        
        -- Verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Cooper: '|| rw_crapttl.cdcooper || ' Conta: '|| rw_crapttl.nrdconta ||' Titular: '|| rw_crapttl.idseqttl || ' Critica: '|| vr_dscritic;
          pc_gera_log_easyway(pr_nmarqlog, vr_dscritic);
          vr_dscritic := NULL;
          continue;
        END IF; 
        
      END LOOP; --Fim loop crapttl
    EXCEPTION
      WHEN vr_prox_reg THEN
       pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel gerar cadastro do associado'||
                       ' CPF/CNPJ ' ||pr_nrcpfcgc||
                       ' cooper '||pr_cdcooper||
                       ' conta ' ||pr_nrdconta||
                       ': '||SQLERRM;  
    END pc_trata_conta;
    
    --> Rotina para montar layout de cadastro do outras pessoas que nao possuem conta
    PROCEDURE pc_trata_outro( pr_cdcooper  IN crapcop.cdcooper%TYPE,
                              pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,
                              pr_inpessoa  IN crapass.inpessoa%TYPE,
                              pr_dspessoa  IN VARCHAR2,
                              pr_nrdconta  IN crapass.nrdconta%TYPE,
                              pr_nmprimtl  IN crapass.nmprimtl%TYPE,
                              pr_dtnasctl  IN VARCHAR2,
                              pr_endereco  IN VARCHAR2,
                              pr_nrendere  IN VARCHAR2,
                              pr_complend  IN VARCHAR2,
                              pr_nrcepend  IN VARCHAR2,
                              pr_nmbairro  IN VARCHAR2,
                              pr_nmcidade  IN VARCHAR2,
                              pr_cdufende  IN VARCHAR2,
                              pr_tplograd  IN VARCHAR2,
                              pr_dtmvtolt  IN VARCHAR2,
                              ----- OUT ----
                              pr_dscritic OUT VARCHAR2)IS
    
      vr_prox_reg EXCEPTION;
      vr_dscritic VARCHAR2(2000) := NULL;
      
    BEGIN
      -- Controle para processar apenas um cpf/cnpj 
      vr_idxctrl := lpad(pr_nrcpfcgc,14,'0');
      IF vr_tab_nrcpfcnpj.exists(vr_idxctrl) THEN
        RAISE vr_prox_reg;
      ELSE
        vr_tab_nrcpfcnpj(vr_idxctrl) := pr_nrcpfcgc; 
      END IF; 
      
      --> Montar linha conforme layout easyway
      vr_dslinha := fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     --> CPF/CNPJ Cooperado
                    rpad(fn_remove_caract_espec(nvl(pr_nmprimtl,' ')),60,' ')     ||     --> Nome do Contribuinte
                    rpad(fn_remove_caract_espec(nvl(pr_endereco,' ')),80,' ')     ||     --> Logradouro
                    rpad(fn_remove_caract_espec(nvl(pr_nrendere,' ')), 8,' ')     ||     --> Número
                    rpad(fn_remove_caract_espec(nvl(pr_complend,' ')),40,' ')     ||     --> Complemento
                    rpad(fn_remove_caract_espec(nvl(pr_nrcepend,' ')), 8,' ')     ||     --> CEP
                    rpad(fn_remove_caract_espec(nvl(pr_nmbairro,' ')),20,' ')     ||     --> Bairro
                    rpad(fn_remove_caract_espec(nvl(pr_nmcidade,' ')),30,' ')     ||     --> Descrição Cidade
                    rpad(fn_remove_caract_espec(nvl(pr_cdufende,' ')), 2,' ')     ||     --> UF
                    rpad(' ',15,' ')                      ||     --> Telefone   
                    lpad(nvl(pr_dtnasctl,' '),8,' ')      ||     --> Data de Nascimento
                    rpad(' ',20,' ')                      ||     --> Inscrição Municipal
                    lpad(nvl(pr_dtmvtolt,' '),8,' ')      ||     --> Data da Inclusão no sistema de origem
                    lpad(nvl(pr_dtmvtolt,' '),8,' ')      ||     --> Data última alteração sistema de origem                    
                    'N'                                   ||     --> Estrangeiro (sem cpf/cnpj) (N - Não é estrangeiro; C - Estrangeiro com CPF;S - Estrangeiro sem CPF)
                    rpad(' ', 3,' ')                      ||     --> Código do País
                    rpad(' ',20,' ')                      ||     --> Numero de Identificação Fiscal (se estrangeiro)
                    rpad(' ', 3,' ')                      ||     --> Natureza da Relação
                    rpad(' ',40,' ')                      ||     --> Descrição do Estado (se estrangeiro)
                    rpad(' ',60,' ')                      ||     --> Email
                    pr_dspessoa                           ||     --> PF/PJ(F - PF; J – PJ)
                    rpad(' ',20,' ')                      ||     --> Inscrição Estadual
                    'A'                                   ||     --> Status do Contribuinte
                    rpad(fn_remove_caract_espec(nvl(pr_tplograd,' ')),10,' ')     ||     --> Tipo de Logradouro
                    ' '                                   ||     --> Isento de Inscrição Estadual
                    lpad(' ',19,' ')                      ||     --> GIIN (Global Intermediary Identification Number)
                    lpad(' ',25,' ')                      ||     --> Numero do Passaporte
                    lpad(' ', 1,' ')                      ||     --> Tipo da Instituição Financeira (FATCA)
                    lpad(' ',10,' ')                      ||     --> Tipo de declarado
                    chr(13)||chr(10);                            --> quebrar linha
          
      pc_escreve_clob(vr_dslinha);
      
      /* Geração de Log */
      IF (nvl(pr_endereco,' ') = ' ') then
         pr_dscritic := nvl(pr_dscritic,' ') || 'Sem logradouro cadastrado.';
      END IF;
      IF (nvl(pr_dtmvtolt,' ') = ' ') then
         pr_dscritic := pr_dscritic || ' - Sem data de admissao.';
      END IF;
    
    EXCEPTION
      WHEN vr_prox_reg THEN
       pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Não foi possivel gerar cadastro do associado'||
                       ' CPF/CNPJ ' ||pr_nrcpfcgc||
                       ' cooper '||pr_cdcooper||
                       ' conta ' ||pr_nrdconta||
                       ': '||SQLERRM;  
    END pc_trata_outro;
     
    
  BEGIN
    
    -- Inicializar o CLOB
    vr_dsarquiv := NULL;
    dbms_lob.createtemporary(vr_dsarquiv, TRUE);
    dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    
    -- Incializar variaveis      
    vr_nmarqimp := 'cadast_'||pr_dssufarq||'.txt';        
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da geração do arquivo Cadastro de Cooperados,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR'));             
  
    --> Se estiver processando uma cooperativa
    IF nvl(pr_cdcooper,0) > 0 THEN
    
      --> Buscar CNPJ da coop
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      
      IF rw_crapcop.nrdocnpj > 0 THEN        
        --> Incluir como ja processado para não gerar informacoes da coop no arquivo
        vr_idxctrl := lpad(rw_crapcop.nrdocnpj,14,'0');
        vr_tab_nrcpfcnpj(vr_idxctrl) := rw_crapcop.nrdocnpj;         
      END IF;
    
    END IF;
    
    vr_logcompl := 'Início Geração do Arquivo de Cadastro dos Cooperados';    
    --> Buscar os CPFs/CNPJs a serem enviados para a Easyway
    FOR rw_crapass_nrcpfcgc IN cr_crapass_nrcpfcgc(pr_nrdconta => pr_nrdconta,
                                                   pr_dtiniger => pr_dtiniger,
                                                   pr_dtfimger => pr_dtfimger) LOOP
      
      /* Se for conta migrada na incorporacao Transulcred -> Transpocred e 
         o periodo final for igual ou menor que 2016, vamos ignorar a conta. */
      IF (fn_ignorar_conta(pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                           pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta,
                           pr_dtiniger => pr_dtiniger,
                           pr_dtfimger => pr_dtfimger)) THEN
        CONTINUE;
      END IF;
    
      /* Armazena a ultima conta do processamento para caso apresente algum erro, sabermos qual a conta / cpf */
      vr_logcompl := 'Gerando associado, Cooper: ' || rw_crapass_nrcpfcgc.cdcooper || ', Conta: ' || rw_crapass_nrcpfcgc.nrdconta || ', CPF/CNPJ: ' || rw_crapass_nrcpfcgc.nrcpfcgc;
          
      -- loop para garantir que todas as pessoas sejam enviadas para o arquivo.
      -- Visto que os dados principais do associado devem ser os da conta mais atualizada
      -- caso exista mais de uma conta, assim o loop força que primeiro seja enviado a conta mais atualizada
      -- e posteriormente executa todos os selects com a conta original a fim de enviar as pessoas ainda não enviadas
      vr_flpriass := TRUE;
      LOOP
        IF vr_flpriass THEN
          rw_crapass := NULL;
          --> Buscar informacoes dos cooperados com o cadastro mais atualizado
          OPEN cr_crapass (pr_nrcpfcgc => rw_crapass_nrcpfcgc.nrcpfcgc);
          FETCH cr_crapass INTO rw_crapass;
          IF cr_crapass%NOTFOUND THEN         
            CLOSE cr_crapass;
            -- Se nao encontrar deve utilizar da primeira query
            rw_crapass.nrdconta := rw_crapass_nrcpfcgc.nrdconta;
            rw_crapass.cdcooper := rw_crapass_nrcpfcgc.cdcooper;
            rw_crapass.nrcpfcgc := rw_crapass_nrcpfcgc.nrcpfcgc;
            rw_crapass.inpessoa := rw_crapass_nrcpfcgc.inpessoa;
            rw_crapass.cdsitdct := rw_crapass_nrcpfcgc.cdsitdct;              
          ELSE
            CLOSE cr_crapass;
          END IF;
          vr_flpriass := FALSE;
        
        ELSE
          -- Qnd não for a primeira vez, significa que o associado não é a conta
          -- mais atualizada, porém é necessario forçar o envio novamente
          -- com a conta garantir que todas titulares sejam enviado
          rw_crapass.nrdconta := rw_crapass_nrcpfcgc.nrdconta;
          rw_crapass.cdcooper := rw_crapass_nrcpfcgc.cdcooper;
          rw_crapass.nrcpfcgc := rw_crapass_nrcpfcgc.nrcpfcgc;
          rw_crapass.inpessoa := rw_crapass_nrcpfcgc.inpessoa;
          rw_crapass.cdsitdct := rw_crapass_nrcpfcgc.cdsitdct; 
          rw_crapass.dtaltera := rw_crapass.dtaltera;          
        END IF;
        
        --> Rotina para montar layout de cadastro do associado a partir da conta
        pc_trata_conta( pr_cdcooper  => rw_crapass.cdcooper,
                        pr_nrdconta  => rw_crapass.nrdconta,
                        pr_inpessoa  => rw_crapass.inpessoa,
                        pr_nrcpfcgc  => rw_crapass.nrcpfcgc,
                        pr_idseqttl  => 0, --> todos os titulares
                        pr_dtaltera  => rw_crapass.dtaltera,
                        pr_cdsitdct  => rw_crapass.cdsitdct,
                        pr_dscritic  => vr_dscritic);
        
        -- Verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          pc_gera_log_easyway(pr_nmarqlog, vr_dscritic);
          
          -- Mesma condicao de fora do IF, para nao ficar em loop infinito em caso de critica na pc_trata_conta.
          IF rw_crapass_nrcpfcgc.nrdconta = rw_crapass.nrdconta THEN
            EXIT;
          ELSE
            continue;  
          END IF;
          
        END IF;
        
        -- Sair do loop qnd processar a mesma conta entre os dois cursores
        IF rw_crapass_nrcpfcgc.nrdconta = rw_crapass.nrdconta THEN
          EXIT;
        END IF;
        
      END LOOP;    
    END LOOP; -- Fim  Loop cr_crapass_nrcpfcgc
    
    pc_gera_log_easyway(pr_nmarqlog,'Inicio da leitura dos Procuradores e Representantes, arquivo: '||vr_nmarqimp); 
    vr_logcompl := 'Inicio da leitura dos Procuradores e Representantes';
    
    --> Buscar os Procuradores e Responsáveis dos cooperados enviados para a Easyway
    FOR rw_crapass_nrcpfcgc IN cr_crapass_nrcpfcgc(pr_nrdconta => pr_nrdconta,
                                                   pr_dtiniger => pr_dtiniger,
                                                   pr_dtfimger => pr_dtfimger) LOOP

        /* Se for conta migrada na incorporacao Transulcred -> Transpocred e 
         o periodo final for igual ou menor que 2016, vamos ignorar a conta. */
        IF (fn_ignorar_conta(pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                             pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta,
                             pr_dtiniger => pr_dtiniger,
                             pr_dtfimger => pr_dtfimger)) THEN
          CONTINUE;
        END IF;
        
        /* Armazena a ultima conta do processamento para caso apresente algum erro, sabermos qual a conta / cpf */
        vr_logcompl := 'Gerando procurador, Cooper: ' || rw_crapass_nrcpfcgc.cdcooper || ', Conta: ' || rw_crapass_nrcpfcgc.nrdconta || ', CPF/CNPJ: ' || rw_crapass_nrcpfcgc.nrcpfcgc;
        
        --->>> TERCEIROS DOS ASSOCIADOS (PROCURADORES E SOCIOS) <<<---
        IF rw_crapass_nrcpfcgc.inpessoa = 1 THEN
          -- Buscar procuradoes e responsaveis legais da conta
          FOR rw_crapcrl IN  cr_crapcrl (pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                                         pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta) LOOP
              
            IF rw_crapcrl.nrdctato > 0 THEN
              --> Rotina para montar layout de cadastro do associado a partir da conta
              pc_trata_conta( pr_cdcooper  => rw_crapass_nrcpfcgc.cdcooper,
                              pr_nrdconta  => rw_crapcrl.nrdctato,
                              pr_inpessoa  => rw_crapcrl.inpessoa,
                              pr_nrcpfcgc  => rw_crapcrl.nrcpfcgc,
                              pr_idseqttl  => 1, --> apenas o primeiro titular
                              pr_dtaltera  => rw_crapass_nrcpfcgc.dtaltera,
                              pr_cdsitdct  => rw_crapcrl.cdsitdct,
                              pr_dscritic  => vr_dscritic);
              -- Verificar se retornou critica
              IF vr_dscritic IS NOT NULL THEN
                pc_gera_log_easyway(pr_nmarqlog, vr_dscritic);
                continue;
              END IF; 
            -- Outros que nao possuem conta na cooperativa
            ELSE
              /* Se não tiver data 'cadastro' do responsavel de menor, carrega a data de admissao da conta */
              IF (rw_crapcrl.dtmvtolt IS NULL) THEN
                rw_crapcrl.dtmvtolt := to_char(rw_crapass_nrcpfcgc.dtadmiss,'RRRRMMDD');
              END IF;
              
              /* Se não tiver endereco, vamos buscar da conta principal */
              IF (trim(rw_crapcrl.dsendres) IS NULL AND
                  trim(rw_crapcrl.nmcidade) IS NULL) THEN
                OPEN cr_crapenc ( pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                                  pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta,
                                  pr_idseqttl => 1,
                                  pr_inpessoa => rw_crapass_nrcpfcgc.inpessoa);
                FETCH cr_crapenc INTO rw_crapenc;
                IF cr_crapenc%NOTFOUND THEN
                  CLOSE cr_crapenc;
                  vr_dscritic := 'Não foi possivel gerar o endereço da conta principal para o procurador/representante da conta. '||
                                 ' Procurador: CPF/CNPJ ' ||rw_crapcrl.nrcpfcgc||
                                 ' cooper '||rw_crapass_nrcpfcgc.cdcooper||
                                 ' conta ' ||rw_crapass_nrcpfcgc.nrdconta||
                                 ', endereço não encontrado';
                  RAISE vr_exc_erro;
                END IF;
                vr_aux_endereco := rw_crapenc.endereco;
                vr_aux_nrendere := rw_crapenc.nrendere;
                vr_aux_complend := rw_crapenc.complend;
                vr_aux_nrcepend := rw_crapenc.nrcepend;
                vr_aux_nmbairro := rw_crapenc.nmbairro;
                vr_aux_nmcidade := rw_crapenc.nmcidade;
                vr_aux_cdufende := rw_crapenc.cdufende;
                vr_aux_tplograd := rw_crapenc.tp_lograd;
                CLOSE cr_crapenc;
              ELSE
                vr_aux_endereco := rw_crapcrl.dsendres;
                vr_aux_nrendere := rw_crapcrl.nrendere;
                vr_aux_complend := rw_crapcrl.complend;
                vr_aux_nrcepend := rw_crapcrl.nrcepend;
                vr_aux_nmbairro := rw_crapcrl.nmbairro;
                vr_aux_nmcidade := rw_crapcrl.nmcidade;
                vr_aux_cdufende := rw_crapcrl.cdufresd;
                vr_aux_tplograd := rw_crapcrl.tplograd;
              END IF;
              
              --> Rotina para montar layout de cadastro do outras pessoas que nao possuem conta
              pc_trata_outro( pr_cdcooper  => rw_crapass_nrcpfcgc.cdcooper,
                              pr_nrcpfcgc  => rw_crapcrl.nrcpfcgc,  
                              pr_inpessoa  => rw_crapcrl.inpessoa,  
                              pr_dspessoa  => rw_crapcrl.dspessoa,  
                              pr_nrdconta  => rw_crapass_nrcpfcgc.nrdconta,  
                              pr_nmprimtl  => rw_crapcrl.nmdavali,    
                              pr_dtnasctl  => rw_crapcrl.dtnascto,  
                              pr_endereco  => vr_aux_endereco,
                              pr_nrendere  => vr_aux_nrendere,
                              pr_complend  => vr_aux_complend,
                              pr_nrcepend  => vr_aux_nrcepend,
                              pr_nmbairro  => vr_aux_nmbairro,
                              pr_nmcidade  => vr_aux_nmcidade,
                              pr_cdufende  => vr_aux_cdufende,
                              pr_tplograd  => vr_aux_tplograd,
                              pr_dtmvtolt  => rw_crapcrl.dtmvtolt,  
                              ----- OUT ----
                              pr_dscritic  => vr_dscritic);
              -- Verificar se retornou critica
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Procurador/Responsavel - Cooper: '|| rw_crapass_nrcpfcgc.cdcooper || ' Conta: '|| rw_crapass_nrcpfcgc.nrdconta ||' CPF: '|| rw_crapcrl.nrcpfcgc || ' Critica: '|| vr_dscritic;
                pc_gera_log_easyway(pr_nmarqlog, vr_dscritic);
                vr_dscritic := null;
                continue;
              END IF;
            END IF;
              
          END LOOP;
        ELSE
          -- Buscar procuradoes e responsaveis legais da conta
          FOR rw_crapavt IN  cr_crapavt (pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                                         pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta) LOOP
            
            IF rw_crapavt.nrdctato > 0 THEN
              --> Rotina para montar layout de cadastro do associado a partir da conta
              pc_trata_conta( pr_cdcooper  => rw_crapass_nrcpfcgc.cdcooper,
                              pr_nrdconta  => rw_crapavt.nrdctato,
                              pr_inpessoa  => rw_crapavt.inpessoa,
                              pr_nrcpfcgc  => rw_crapavt.nrcpfcgc,
                              pr_idseqttl  => 1, --> apenas o primeiro titular
                              pr_dtaltera  => rw_crapass_nrcpfcgc.dtaltera,
                              pr_cdsitdct  => rw_crapavt.cdsitdct,
                              pr_dscritic  => vr_dscritic);
              -- Verificar se retornou critica
              IF vr_dscritic IS NOT NULL THEN
                pc_gera_log_easyway(pr_nmarqlog, vr_dscritic);
                continue;
              END IF; 
              
            -- Outros que nao possuem conta na cooperativa
            ELSE
              /* Se não tiver data 'cadastro' do procurador, carrega a data de admissao da conta */
              IF (rw_crapavt.dtmvtolt IS NULL) THEN
                rw_crapavt.dtmvtolt := to_char(rw_crapass_nrcpfcgc.dtadmiss,'RRRRMMDD');
              END IF;
              
              /* Se não tiver endereco, vamos buscar da conta principal */
              IF (trim(rw_crapavt.dsendres) IS NULL AND
                  trim(rw_crapavt.nmcidade) IS NULL) THEN
                OPEN cr_crapenc ( pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                                  pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta,
                                  pr_idseqttl => 1,
                                  pr_inpessoa => rw_crapass_nrcpfcgc.inpessoa);
                FETCH cr_crapenc INTO rw_crapenc;
                IF cr_crapenc%NOTFOUND THEN
                  CLOSE cr_crapenc;
                  vr_dscritic := 'Não foi possivel gerar o endereço da conta principal para o procurador da conta. '||
                                 ' Procurador: CPF/CNPJ ' ||rw_crapavt.nrcpfcgc||
                                 ' cooper '||rw_crapass_nrcpfcgc.cdcooper||
                                 ' conta ' ||rw_crapass_nrcpfcgc.nrdconta||
                                 ', endereço não encontrado';
                  RAISE vr_exc_erro;
                END IF;
                vr_aux_endereco := rw_crapenc.endereco;
                vr_aux_nrendere := rw_crapenc.nrendere;
                vr_aux_complend := rw_crapenc.complend;
                vr_aux_nrcepend := rw_crapenc.nrcepend;
                vr_aux_nmbairro := rw_crapenc.nmbairro;
                vr_aux_nmcidade := rw_crapenc.nmcidade;
                vr_aux_cdufende := rw_crapenc.cdufende;
                vr_aux_tplograd := rw_crapenc.tp_lograd;
                CLOSE cr_crapenc;
              ELSE
                vr_aux_endereco := rw_crapavt.dsendres;
                vr_aux_nrendere := rw_crapavt.nrendere;
                vr_aux_complend := rw_crapavt.complend;
                vr_aux_nrcepend := rw_crapavt.nrcepend;
                vr_aux_nmbairro := rw_crapavt.nmbairro;
                vr_aux_nmcidade := rw_crapavt.nmcidade;
                vr_aux_cdufende := rw_crapavt.cdufresd;
                vr_aux_tplograd := rw_crapavt.tplograd;
              END IF;
              
              --> Rotina para montar layout de cadastro do outras pessoas que nao possuem conta
              pc_trata_outro( pr_cdcooper  => rw_crapass_nrcpfcgc.cdcooper,
                              pr_nrcpfcgc  => rw_crapavt.nrcpfcgc,  
                              pr_inpessoa  => rw_crapavt.inpessoa,  
                              pr_dspessoa  => rw_crapavt.dspessoa,  
                              pr_nrdconta  => rw_crapass_nrcpfcgc.nrdconta,  
                              pr_nmprimtl  => rw_crapavt.nmdavali,    
                              pr_dtnasctl  => rw_crapavt.dtnascto,  
                              pr_endereco  => vr_aux_endereco,
                              pr_nrendere  => vr_aux_nrendere,  
                              pr_complend  => vr_aux_complend,  
                              pr_nrcepend  => vr_aux_nrcepend,
                              pr_nmbairro  => vr_aux_nmbairro,  
                              pr_nmcidade  => vr_aux_nmcidade,
                              pr_cdufende  => vr_aux_cdufende,
                              pr_tplograd  => vr_aux_tplograd,
                              pr_dtmvtolt  => rw_crapavt.dtmvtolt,  
                              ----- OUT ----
                              pr_dscritic  => vr_dscritic);
              -- Verificar se retornou critica
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Procurador - Cooper: '|| rw_crapass_nrcpfcgc.cdcooper || ' Conta: '|| rw_crapass_nrcpfcgc.nrdconta ||' CPF: '|| rw_crapavt.nrcpfcgc || ' Critica: '|| vr_dscritic;
                pc_gera_log_easyway(pr_nmarqlog, vr_dscritic);
                vr_dscritic := null;
                continue;
              END IF;
            END IF; 
              
          END LOOP;
        END IF;
    END LOOP;
    
    vr_logcompl := 'Fim do processamento dos registros do arquivo';
    
    IF vr_texto_completo IS NOT NULL THEN
      pc_escreve_clob('',TRUE);
    END IF;
      
    -- busca diretorio
    vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 3, 
                                             pr_cdacesso => 'DIR_ARQ_EASYWAY');
                                             
    --Solicitar geracao do arquivo fisico
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 -- coop Cecred          --> Cooperativa conectada
                                       ,pr_cdprogra  => 'INTEAS'                  --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt       --> Data do movimento atual
                                       ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
        
    pc_gera_log_easyway( pr_nmarqlog,'Final da geração do arquivo.');
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      --pc_gera_log( 'Não foi possivel concluir geração do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
      IF(TRIM(vr_nmarqimp) IS NOT NULL) THEN        
        pc_gera_log_easyway(pr_nmarqlog, 'Não foi possivel gerar arquivo de cadastro dos cooperados: '|| pr_dscritic);
        pc_gera_log_easyway(pr_nmarqlog, 'Ultimo processo:' || vr_logcompl);
      END IF;
      
    WHEN OTHERS THEN      
      IF(TRIM(vr_nmarqimp) IS NOT NULL) THEN
        pc_gera_log_easyway(pr_nmarqlog, 'Não foi possivel gerar arquivo de cadastro dos cooperados: '|| pr_dscritic);
        pc_gera_log_easyway(pr_nmarqlog, 'Ultimo processo:' || vr_logcompl);
      END IF;
      pr_dscritic := 'Não foi possivel gerar arquivo de cadastro dos cooperados: '||SQLERRM;
      --pc_gera_log( pr_dscritic);
  END pc_gera_arq_cadastro_ass;
  
  
  --> Procedimento responsavel em gerar o arquivo de movimentação das operações dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_movimento_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_gera_arq_movimento_ass        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 29/08/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel em gerar a movimentação das operações dos cooperados
    
    Alteração : 29/08/2018 - P450 - Alterado para descontar do saldo da conta corrente, o saldo
                             da conta transitória (Heckmann/AMCom)
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper, 0, cop.cdcooper, pr_cdcooper) 
             /* Ou a cooperativa esta ativa ou eh a Transulcred */
         AND (cop.flgativo = 1 or cop.cdcooper = 17)
       ORDER BY cop.cdcooper;
          
    --> Buscar informacoes dos cooperados
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtiniger DATE,
                       pr_dtfimger DATE )IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nrcpfcgc
            /* Se a conta foi demitida depois do periodo, quer dizer
               que temos que exporta-la como ativa ainda. */
            ,case when ass.dtelimin > pr_dtfimger
                  then null
                  else ass.dtelimin
              end dtelimin
            ,ass.inpessoa
            ,ass.cdagenci
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = decode(pr_nrdconta, 0, ass.nrdconta, pr_nrdconta)
         AND ass.dtadmiss <= pr_dtfimger -- Cooperados admitidos até a data final
         AND (ass.dtelimin IS NULL OR    -- Cooperados não demitidos                       
              ass.dtelimin >= pr_dtiniger) -- ou demitidos depois da data inicial
       ORDER BY ass.cdcooper
               ,ass.nrdconta;
    
    --> Buscar total de lancamento por mes
    CURSOR cr_craplcm (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtiniger DATE,
                       pr_dtfimger DATE )IS
      SELECT lcm.cdcooper,
             lcm.nrdconta,
             TRUNC(lcm.dtmvtolt, 'MM')  as dtmesmvt,
             his.indebcre               as indebcre,
             SUM(lcm.vllanmto)          as vllanmto
        FROM craplcm lcm                  
        join craphis his
          on his.cdcooper = lcm.cdcooper
         and his.cdhistor = lcm.cdhistor
       WHERE lcm.cdcooper = pr_cdcooper
         and lcm.nrdconta = pr_nrdconta
         and lcm.dtmvtolt BETWEEN pr_dtiniger AND pr_dtfimger
       group by lcm.cdcooper,
                lcm.nrdconta,
                his.indebcre,
                TRUNC(lcm.dtmvtolt, 'MM')
       ORDER BY TRUNC(lcm.dtmvtolt, 'MM');
    
    --> Buscar os totais de lançamento de aplicações e poupança do periodo         
    CURSOR cr_aplicac (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtiniger DATE,
                       pr_dtfimger DATE ) IS
      SELECT origem.cdcooper
            ,origem.nrdconta
            ,origem.dtmesmvt
            ,origem.indebcre
            ,SUM(origem.vllanmto) AS vllanmto
        FROM (
              /* Aplicações RDCPOS, RDCPRE e RDCA */
              SELECT  lap.cdcooper
                     ,lap.nrdconta
                     ,TRUNC(lap.dtmvtolt, 'MM') AS dtmesmvt
                     ,his.indebcre
                     ,lap.vllanmto
                FROM craplap lap
                JOIN craphis his
                  ON his.cdcooper = lap.cdcooper
                 AND his.cdhistor = lap.cdhistor
               WHERE lap.cdcooper = pr_cdcooper
                 AND lap.nrdconta = pr_nrdconta
                 AND lap.dtmvtolt BETWEEN pr_dtiniger AND pr_dtfimger
                 AND lap.cdhistor NOT IN (117,125,124) -- Provisão e Ajuste Provisão RDCA
                 /* Os históricos de Provisão e Reversão de RDC pós e pré serão considerados no SQL, pois o rendimento dessas aplicações são 
                    creditadas apenas no vencimento ou no resgate. Dessa forma, a aplicação ficaria estagnada até esse momento. Além disso,
                    no arquivo de saldo, buscamos os dados da CRAPSDA, que considera as provisões no cálculo. */
              UNION ALL
              /* Poupança programada */
              SELECT lpp.cdcooper
                     ,lpp.nrdconta
                     ,TRUNC(lpp.dtmvtolt, 'MM') AS dtmesmvt
                     ,his.indebcre
                     ,lpp.vllanmto
                FROM craplpp lpp
                JOIN craphis his
                  ON his.cdcooper = lpp.cdcooper
                 AND his.cdhistor = lpp.cdhistor
               WHERE lpp.cdcooper = pr_cdcooper
                 AND lpp.nrdconta = pr_nrdconta
                 AND lpp.dtmvtolt BETWEEN pr_dtiniger AND pr_dtfimger
                 AND lpp.cdhistor NOT IN (152) -- Provisao Mes
              UNION ALL
              /* Aplicações Programadas */
              SELECT lac.cdcooper
                     ,lac.nrdconta
                     ,TRUNC(lac.dtmvtolt, 'MM') AS dtmesmvt
                     ,his.indebcre
                     ,lac.vllanmto
                FROM craplac lac
                JOIN craprac rac
                  ON rac.cdcooper = lac.cdcooper
                 AND rac.nrdconta = lac.nrdconta
                 AND rac.nraplica = lac.nraplica
                JOIN crapcpc cpc
                  ON cpc.cdprodut = rac.cdprodut
                JOIN craphis his
                  ON his.cdcooper = lac.cdcooper
                 AND his.cdhistor = lac.cdhistor
               WHERE lac.cdcooper = pr_cdcooper
                 AND lac.nrdconta = pr_nrdconta
                 AND cpc.indplano = 1
                 AND lac.dtmvtolt BETWEEN '01/07/2018' AND '01/08/2018'
                 AND lac.cdhistor NOT IN (cdhsprap) -- Provisão
              UNION ALL
              /* Novos produtos de captação */
              SELECT lac.cdcooper
                     ,lac.nrdconta
                     ,TRUNC(lac.dtmvtolt, 'MM') AS dtmesmvt
                     ,his.indebcre
                     ,lac.vllanmto
                FROM craplac lac
                JOIN craprac rac
                  ON rac.cdcooper = lac.cdcooper
                 AND rac.nrdconta = lac.nrdconta
                 AND rac.nraplica = lac.nraplica
                JOIN crapcpc cpc
                  ON cpc.cdprodut = rac.cdprodut
                JOIN craphis his
                  ON his.cdcooper = lac.cdcooper
                 AND his.cdhistor = lac.cdhistor
               WHERE lac.cdcooper = pr_cdcooper
                 AND lac.nrdconta = pr_nrdconta
                 AND cpc.indplano = 0
                 AND lac.dtmvtolt BETWEEN pr_dtiniger AND pr_dtfimger
                 AND lac.cdhistor NOT IN (cpc.cdhsprap, -- Provisão
                                          cpc.cdhsrvap) -- Reversão
              
              ) origem
       GROUP BY origem.cdcooper
               ,origem.nrdconta
               ,origem.indebcre
               ,origem.dtmesmvt
       ORDER BY origem.dtmesmvt;
            
    -----------> VAIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    -- Variáveis para armazenar as informações do arquivo
    vr_dsarquiv        CLOB;
    -- Variável para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
        
    -- Totai
    vr_vltotdeb      NUMBER;
    vr_vltotcre      NUMBER;
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na variável CLOB
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2,
                              pr_fecha_clob IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_clob);
    END;
    
    -- Montar a linha conforme layout easyway
    PROCEDURE pc_escreve_linha_layout(pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                      pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,
                                      pr_inpessoa  IN crapass.inpessoa%TYPE,
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,
                                      pr_dtultmes  IN DATE,
                                      pr_tpoperac  IN NUMBER,
                                      pr_vloperac  IN NUMBER,
                                      pr_indebcre  IN craphis.indebcre%TYPE,
                                      pr_dtinclus  IN DATE,
                                      pr_dtdemiss  IN crapass.dtdemiss%TYPE,
                                      pr_cdagenci  IN crapass.cdagenci%TYPE,
                                      ----- OUT ----
                                      pr_dscritic OUT VARCHAR2) IS 
      vr_dslinha   VARCHAR2(3200);
      vr_tpdconta  VARCHAR2(1);
      
    BEGIN
      -- Definir tipo de conta para concatenar no nrdconta para evitar duplicidade na EasyWay
      IF pr_tpoperac = 101 THEN
        vr_tpdconta := 'C';
      ELSIF pr_tpoperac = 199 THEN
        vr_tpdconta := 'A';
      END IF;
      
      --> Montar linha conforme layout easyway
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- Código da empresa
                    lpad(pr_cdcooper, 4,' ')              ||     -- Filial
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ Cooperado
                    lpad(to_char(pr_dtultmes,'RRRRMMDD')  ||
                         lpad(pr_nrdconta||vr_tpdconta,10,'0'),18,' ') ||     -- Numero documento
                    to_char(pr_dtultmes,'RRRRMMDD')       ||     -- Data da Operação
                    lpad(nvl(pr_tpoperac,0),40,' ')     ||     -- Código da operação (101-Conta corrente e 199-Aplicação)
                    lpad(trunc(pr_vloperac*100),'17','0') ||     -- Valor da operação 
                    nvl(pr_indebcre,' ')                  ||     -- Sinal da Operação 
                    to_char(pr_dtinclus,'YYYYMMDD')       ||     -- Data Inclusão
                    'N'                                   ||     -- Tipo Movimento (N/E) - Sempre N-Normal
                    lpad(' ',6,' ')                       ||     -- Código do dependente 
                    lpad(nvl(to_char(pr_dtdemiss,'RRRRMMDD'),' '),8,' ') ||     -- Data de encerramento da conta
                    lpad(pr_nrdconta||vr_tpdconta,50,' ') ||     -- Numero da conta
                    lpad(nvl(pr_cdagenci,0),10,' ')       ||     -- Número da agência da conta
                    chr(13)||chr(10);                            -- quebrar linha
       
      pc_escreve_clob(vr_dslinha);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao montar linha para a conta '||pr_nrdconta||': '|| SQLERRM;
    END;    
    
    
  BEGIN
     
    -- Inicializar o CLOB
    vr_dsarquiv := NULL;
    dbms_lob.createtemporary(vr_dsarquiv, TRUE);
    dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
    
    
        
    vr_nmarqimp := 'movi_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da geração do arquivo Movimentação das Operações dos Cooperados,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR')); 
    pc_gera_log_easyway( pr_nmarqlog,'Cooperativa	      Total Crédito	      Total Débito		       Total');   
      
    FOR rw_crapcop IN cr_crapcop LOOP
      -- inicializar totais por cooperativas
      vr_vltotdeb := 0;
      vr_vltotcre := 0;
      
      --> Buscar cooperados
      FOR rw_crapass IN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_dtiniger => pr_dtiniger,
                                   pr_dtfimger => pr_dtfimger) LOOP
                                    
        /* Se for conta migrada na incorporacao Transulcred -> Transpocred e 
         o periodo final for igual ou menor que 2016, vamos ignorar a conta. */
        IF (fn_ignorar_conta(pr_cdcooper => rw_crapass.cdcooper,
                             pr_nrdconta => rw_crapass.nrdconta,
                             pr_dtiniger => pr_dtiniger,
                             pr_dtfimger => pr_dtfimger)) THEN
          CONTINUE;
        END IF;
        
        --> Tratativa para não enviar os dados da propria cooperativa                            
        IF rw_crapass.nrcpfcgc = rw_crapcop.nrdocnpj THEN
          continue;
        END IF;
        
        --> Buscar os totais de lançamento(debito - credito)
        FOR rw_craplcm IN cr_craplcm (pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_dtiniger => pr_dtiniger,
                                      --> Até o fim do periodo ou ate a data de demissao
                                      pr_dtfimger => nvl(rw_crapass.dtelimin, pr_dtfimger)) LOOP
                                       
                                       
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapass.cdcooper,
                                  pr_nrcpfcgc  => rw_crapass.nrcpfcgc,
                                  pr_inpessoa  => rw_crapass.inpessoa,
                                  pr_nrdconta  => rw_crapass.nrdconta,
                                  pr_dtultmes  => last_day(rw_craplcm.dtmesmvt),
                                  pr_tpoperac  => 101, -- 101-Conta corrente
                                  pr_vloperac  => rw_craplcm.vllanmto + PREJ0003.fn_sld_cta_prj(rw_crapass.cdcooper, rw_crapass.nrdconta, 0),
                                  pr_indebcre  => rw_craplcm.indebcre,
                                  pr_dtinclus  => last_day(pr_dtiniger),
                                  pr_dtdemiss  => rw_crapass.dtelimin,
                                  pr_cdagenci  => rw_crapass.cdagenci,
                                  ----- OUT ----
                                  pr_dscritic => vr_dscritic);
                                  
          -- Verificar se retornou critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
          
          -- Incrementar totais
          IF rw_craplcm.indebcre = 'D' THEN
            vr_vltotdeb := vr_vltotdeb + rw_craplcm.vllanmto;
          ELSIF rw_craplcm.indebcre = 'C' THEN  
            vr_vltotcre := vr_vltotcre + rw_craplcm.vllanmto;
          END IF;  
                         
        END LOOP;--> Fim loop craplcm  
        
        --> Buscar os totais de lançamento de aplicações e poupança do periodo         
        FOR rw_aplicac IN cr_aplicac (pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_dtiniger => pr_dtiniger,
                                      --> Até o fim do periodo ou ate a data de demissao
                                      pr_dtfimger => nvl(rw_crapass.dtelimin, pr_dtfimger)) LOOP
                                       
                                       
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapass.cdcooper,
                                  pr_nrcpfcgc  => rw_crapass.nrcpfcgc,
                                  pr_inpessoa  => rw_crapass.inpessoa,
                                  pr_nrdconta  => rw_crapass.nrdconta,
                                  pr_dtultmes  => last_day(rw_aplicac.dtmesmvt),
                                  pr_tpoperac  => 199, -- 199-Aplicação
                                  pr_vloperac  => rw_aplicac.vllanmto + PREJ0003.fn_sld_cta_prj(rw_crapass.cdcooper, rw_crapass.nrdconta, 0),
                                  pr_indebcre  => rw_aplicac.indebcre,
                                  pr_dtinclus  => last_day(pr_dtiniger),
                                  pr_dtdemiss  => rw_crapass.dtelimin,
                                  pr_cdagenci  => rw_crapass.cdagenci,
                                  ----- OUT ----
                                  pr_dscritic => vr_dscritic);
                                  
          -- Verificar se retornou critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF;                
        
          -- Incrementar totais
          IF rw_aplicac.indebcre = 'D' THEN
            vr_vltotdeb := vr_vltotdeb + rw_aplicac.vllanmto;
          ELSIF rw_aplicac.indebcre = 'C' THEN  
            vr_vltotcre := vr_vltotcre + rw_aplicac.vllanmto;
          END IF;
        END LOOP;--> Fim loop cr_aplicac
                                     
      END LOOP;  --> Fim loop crapass
      
      --> gerar log
      pc_gera_log_easyway( pr_nmarqlog,
                   Rpad(rw_crapcop.nmrescop,12,' ')||
                   to_char(vr_vltotcre,'999G999G999G990D00')||
                   to_char(vr_vltotdeb,'999G999G999G990D00')||
                   to_char(vr_vltotcre + vr_vltotdeb,'999G999G999G990D00'));
      
    END LOOP;  --> Fim loop crapcop
    
    IF vr_texto_completo IS NOT NULL THEN
      pc_escreve_clob('',TRUE);
    END IF;
    
    -- busca diretorio
    vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 3, 
                                             pr_cdacesso => 'DIR_ARQ_EASYWAY');
    --Solicitar geracao do arquivo fisico
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 -- coop Cecred          --> Cooperativa conectada
                                       ,pr_cdprogra  => 'INTEAS'                  --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt       --> Data do movimento atual
                                       ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da geração do arquivo.');
     
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsarquiv);
    dbms_lob.freetemporary(vr_dsarquiv); 
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel gerar arquivo de movimentacao dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_movimento_ass;
  
  --> Procedimento responsavel em gerar o arquivo com os saldos das operações dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_saldo_ope_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_gera_arq_saldo_ope_ass        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 29/08/2018
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel em gerar arquivo com os saldos das operações dos cooperados
    
    Alteração : 29/08/2018 - P450 - Alterado para descontar do saldo da conta corrente, o saldo
                             da conta transitória (Heckmann/AMCom)
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper, 0, cop.cdcooper, pr_cdcooper) 
             /* Ou a cooperativa esta ativa ou eh a Transulcred */
         AND (cop.flgativo = 1 or cop.cdcooper = 17)
       ORDER BY cop.cdcooper;
 
    /* Buscar o ultimo dia de cada mes do periodo*/
    CURSOR cr_periodo IS
      SELECT DISTINCT last_day( pr_dtiniger + LEVEL - 1) dtultmes
        FROM dual
      CONNECT BY LEVEL <= pr_dtfimger - pr_dtiniger + 1;
                        
    --> Buscar saldos dos cooperados
    CURSOR cr_crapsda (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtmvtolt DATE,
                       pr_dtiniger DATE,
                       pr_dtfimger DATE )IS
      SELECT ass.cdcooper
             ,ass.nrdconta
             ,ass.nrcpfcgc
             /* Se a conta foi demitida depois do periodo, quer dizer
                que temos que exporta-la como ativa ainda. */
             ,case when ass.dtelimin > pr_dtfimger
                  then null
                  else ass.dtelimin
              end dtelimin
             ,ass.cdagenci
             ,ass.inpessoa 
             ,sda.dtmvtolt
             ,sda.vlsddisp + PREJ0003.fn_sld_cta_prj(ass.cdcooper, ass.nrdconta, 0) AS vlsddisp
             ,sda.vlsdrdca + sda.vlsdrdpp AS vlsdapli  -- aplicação + p. programada
        FROM crapsda sda,
             crapass ass
       WHERE sda.cdcooper = pr_cdcooper
         AND ass.cdcooper = pr_cdcooper
         AND ass.cdcooper = sda.cdcooper
         AND ass.nrdconta = sda.nrdconta
         AND sda.nrdconta = decode(pr_nrdconta,0,sda.nrdconta,pr_nrdconta)
         AND sda.dtmvtolt = pr_dtmvtolt
         --> Até o fim do periodo ou ate a data de demissao
         AND ass.dtadmiss <= nvl(ass.dtelimin, pr_dtfimger) -- Cooperados admitidos até a data final
         AND (ass.dtelimin IS NULL OR    -- Cooperados não demitidos                       
              ass.dtelimin >= pr_dtiniger); -- ou demitidos depois da data inicial;
    
            
    -----------> VAIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    -- Variáveis para armazenar as informações do arquivo
    vr_dsarquiv        CLOB;
    -- Variável para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    
    vr_dtmvtolt      DATE;
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na variável CLOB
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2,
                              pr_fecha_clob IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_clob);
    END;
    
    -- Montar a linha conforme layout easyway
    PROCEDURE pc_escreve_linha_layout(pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                      pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,
                                      pr_inpessoa  IN crapass.inpessoa%TYPE,
                                      pr_cdagenci  IN crapass.cdagenci%TYPE,
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,
                                      pr_dtultmes  IN DATE,
                                      pr_tpoperac  IN NUMBER,
                                      pr_vlsldmes  IN NUMBER,
                                      pr_dtdemiss  IN crapass.dtdemiss%TYPE,
                                      ----- OUT ----
                                      pr_dscritic OUT VARCHAR2) IS 
      vr_dslinha   VARCHAR2(3200);
      vr_tpdconta  VARCHAR2(1);
      
    BEGIN
      -- Definir tipo de conta para concatenar no nrdconta para evitar duplicidade na EasyWay
      IF pr_tpoperac = 101 THEN
        vr_tpdconta := 'C';
      ELSIF pr_tpoperac = 199 THEN
        vr_tpdconta := 'A';
      END IF;
      
      --> Montar linha conforme layout easyway
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- Código da empresa
                    lpad(pr_cdcooper, 4,' ')              ||     -- Filial
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ Cooperado
                    lpad(' ',4,' ')                       ||     -- Código de rendimento
                    lpad(nvl(pr_tpoperac,0),8,' ')        ||     -- Código da operação (101-Conta corrente e 199-Aplicação)
                    to_char(pr_dtultmes,'MM/RRRR')        ||     -- Data da Operação
                    lpad(trunc(pr_vlsldmes*100),'17',' ') ||     -- Valor do saldo mensal
                    lpad(' ',10,' ')                      ||     -- Código dependente da Aplic. Financeira
                    lpad(nvl(pr_cdagenci,0), 8,' ')       ||     -- Agência da conta
                    lpad(pr_nrdconta||vr_tpdconta,12,' ') ||     -- Numero da conta
                    lpad(nvl(to_char(pr_dtdemiss,'RRRRMMDD'),' '),8,' ') ||     -- Data de encerramento da conta
                    lpad(' ',14,' ')                      ||     -- Código do Intermediario
                    chr(13)||chr(10);                            -- quebrar linha
       
      pc_escreve_clob(vr_dslinha);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao montar linha para a conta '||pr_nrdconta||': '|| SQLERRM;
    END pc_escreve_linha_layout;    
    
    
  BEGIN
     
    -- Inicializar o CLOB
    vr_dsarquiv := NULL;
    dbms_lob.createtemporary(vr_dsarquiv, TRUE);
    dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
                
    vr_nmarqimp := 'saldos_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da geração do arquivo de Saldo das Operações dos Cooperados,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR')); 
      
    FOR rw_crapcop IN cr_crapcop LOOP  
      -- Varrer periodo
      FOR rw_periodo IN cr_periodo LOOP
      
        -- buscar o ultimo dia util do mes
        vr_dtmvtolt := gene0005.fn_valida_dia_util (pr_cdcooper => rw_crapcop.cdcooper, 
                                                    pr_dtmvtolt => rw_periodo.dtultmes, 
                                                    pr_tipo     => 'A');                                    
        --> Buscar saldos dos cooperados
        FOR rw_crapsda IN cr_crapsda (pr_cdcooper => rw_crapcop.cdcooper,
                                      pr_nrdconta => pr_nrdconta,
                                      pr_dtmvtolt => vr_dtmvtolt,
                                      pr_dtiniger => pr_dtiniger,
                                      pr_dtfimger => pr_dtfimger) LOOP
                                       
                                       
          /* Se for conta migrada na incorporacao Transulcred -> Transpocred e 
           o periodo final for igual ou menor que 2016, vamos ignorar a conta. */
          IF (fn_ignorar_conta(pr_cdcooper => rw_crapsda.cdcooper,
                               pr_nrdconta => rw_crapsda.nrdconta,
                               pr_dtiniger => pr_dtiniger,
                               pr_dtfimger => pr_dtfimger)) THEN
            CONTINUE;
          END IF;
                                     
          --> Tratativa para não enviar os dados da propria cooperativa                            
          IF rw_crapsda.nrcpfcgc = rw_crapcop.nrdocnpj THEN
            continue;
          END IF;
                                     
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapsda.cdcooper,
                                  pr_nrcpfcgc  => rw_crapsda.nrcpfcgc,
                                  pr_inpessoa  => rw_crapsda.inpessoa,
                                  pr_cdagenci  => rw_crapsda.cdagenci,
                                  pr_nrdconta  => rw_crapsda.nrdconta,
                                  pr_dtultmes  => vr_dtmvtolt,
                                  pr_tpoperac  => 101, -- 101-Conta corrente
                                  pr_vlsldmes  => rw_crapsda.vlsddisp,
                                  pr_dtdemiss  => rw_crapsda.dtelimin, 
                                  ----- OUT ----
                                  pr_dscritic => vr_dscritic);
                                  
          -- Verificar se retornou critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
          
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapsda.cdcooper,
                                  pr_nrcpfcgc  => rw_crapsda.nrcpfcgc,
                                  pr_inpessoa  => rw_crapsda.inpessoa,
                                  pr_cdagenci  => rw_crapsda.cdagenci,
                                  pr_nrdconta  => rw_crapsda.nrdconta,
                                  pr_dtultmes  => vr_dtmvtolt,
                                  pr_tpoperac  => 199, -- 199-Aplicação
                                  pr_vlsldmes  => rw_crapsda.vlsdapli,
                                  pr_dtdemiss  => rw_crapsda.dtelimin, 
                                  ----- OUT ----
                                  pr_dscritic => vr_dscritic);
                                  
          -- Verificar se retornou critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
                         
        END LOOP;--> Fim loop crapsda  
                                     
      END LOOP;  --> Fim loop periodo
      
    END LOOP;  --> Fim loop crapcop
    
    IF vr_texto_completo IS NOT NULL THEN
      pc_escreve_clob('',TRUE);
    END IF;
    
    -- busca diretorio
    vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 3, 
                                             pr_cdacesso => 'DIR_ARQ_EASYWAY');
    --Solicitar geracao do arquivo fisico
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 -- coop Cecred          --> Cooperativa conectada
                                       ,pr_cdprogra  => 'INTEAS'                  --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt       --> Data do movimento atual
                                       ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da geração do arquivo.');
     
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsarquiv);
    dbms_lob.freetemporary(vr_dsarquiv); 
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel gerar arquivo de saldos dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_saldo_ope_ass;
  
  --> Procedimento responsavel em gerar o arquivo dos titulares dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_titulares_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_gera_arq_titulares_ass        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 19/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel em gerar arquivo dos titulares dos cooperados
    
    Alteração : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper, 0, cop.cdcooper, pr_cdcooper) 
             /* Ou a cooperativa esta ativa ou eh a Transulcred */
         AND (cop.flgativo = 1 or cop.cdcooper = 17)
       ORDER BY cop.cdcooper;
                     
    --> Buscar titulares
    CURSOR cr_crapttl (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtiniger DATE,
                       pr_dtfimger DATE )IS
      
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci 
            ,ass.dtadmiss
            /* Se a conta foi demitida depois do periodo, quer dizer
               que temos que exporta-la como ativa ainda. */
            ,case when ass.dtelimin > pr_dtfimger
                  then null
                  else ass.dtelimin
              end dtelimin
            ,ttl.nrcpfcgc
            ,ttl.inpessoa
            ,ttl.idseqttl
            ,decode(ttl.idseqttl,1,'S','N') prititul
            ,CASE
              WHEN EXISTS ( SELECT 1
                              FROM craprda rda
                             WHERE rda.cdcooper = ttl.cdcooper
                               AND rda.nrdconta = ttl.nrdconta) OR EXISTS
                           (SELECT 1
                              FROM craprpp rpp
                             WHERE rpp.cdcooper = ttl.cdcooper
                               AND rpp.nrdconta = ttl.nrdconta) OR EXISTS
                           (SELECT 1
                              FROM craprac rac
                             WHERE rac.cdcooper = ttl.cdcooper
                               AND rac.nrdconta = ttl.nrdconta) THEN
                 1
                ELSE
                 0
             END tem_aplicacao
        FROM crapttl ttl,
             crapass ass
       WHERE ttl.cdcooper = pr_cdcooper
         AND ass.cdcooper = pr_cdcooper
         AND ass.cdcooper = ttl.cdcooper
         AND ass.nrdconta = ttl.nrdconta
         AND ttl.nrdconta = decode(pr_nrdconta,0,ttl.nrdconta,pr_nrdconta)
         AND ass.dtadmiss <= pr_dtfimger -- Cooperados admitidos até a data final
         AND (ass.dtelimin IS NULL OR    -- Cooperados não demitidos                       
              ass.dtelimin >= pr_dtiniger); -- ou demitidos depois da data inicial;
    
    --> Buscar titulares Pessoa Juridica - enviar proprio cadastro da ass
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtiniger DATE,
                       pr_dtfimger DATE )IS
      
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.cdagenci 
            ,ass.dtadmiss
            /* Se a conta foi demitida depois do periodo, quer dizer
               que temos que exporta-la como ativa ainda. */
            ,case when ass.dtelimin > pr_dtfimger
                  then null
                  else ass.dtelimin
              end dtelimin
            ,ass.nrcpfcgc
            ,ass.inpessoa
            ,1   AS idseqttl
            ,'S' AS prititul
            ,CASE
              WHEN EXISTS ( SELECT 1
                              FROM craprda rda
                             WHERE rda.cdcooper = ass.cdcooper
                               AND rda.nrdconta = ass.nrdconta) OR EXISTS
                           (SELECT 1
                              FROM craprpp rpp
                             WHERE rpp.cdcooper = ass.cdcooper
                               AND rpp.nrdconta = ass.nrdconta) OR EXISTS
                           (SELECT 1
                              FROM craprac rac
                             WHERE rac.cdcooper = ass.cdcooper
                               AND rac.nrdconta = ass.nrdconta) THEN
                 1
                ELSE
                 0
             END tem_aplicacao
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = decode(pr_nrdconta,0,ass.nrdconta,pr_nrdconta)
         AND ass.inpessoa <> 1 -- Pessoa juridica e as coops
         AND ass.dtadmiss <= pr_dtfimger    -- Cooperados admitidos até a data final
         AND (ass.dtelimin IS NULL OR       -- Cooperados não demitidos                       
              ass.dtelimin >= pr_dtiniger); -- ou demitidos depois da data inicial;    
                  
    -----------> VAIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    -- Variáveis para armazenar as informações do arquivo
    vr_dsarquiv        CLOB;
    -- Variável para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na variável CLOB
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2,
                              pr_fecha_clob IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_clob);
    END;
    
    -- Montar a linha conforme layout easyway
    PROCEDURE pc_escreve_linha_layout(pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                      pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,
                                      pr_inpessoa  IN crapass.inpessoa%TYPE,
                                      pr_cdagenci  IN crapass.cdagenci%TYPE,
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,                                      
                                      pr_tiporegi  IN VARCHAR2,
                                      pr_inivigen  IN DATE,
                                      pr_fimvigen  IN DATE,
                                      pr_tpoperac  IN NUMBER,
                                      pr_prititul  IN VARCHAR2,
                                      ----- OUT ----
                                      pr_dscritic OUT VARCHAR2) IS 
      vr_dslinha   VARCHAR2(3200);
      vr_tpdconta  VARCHAR2(1);
    BEGIN
    
      IF pr_tiporegi = 'C' THEN
        vr_tpdconta := 'C';
      ELSE
        vr_tpdconta := 'A';
      END IF;
      
      --> Montar linha conforme layout easyway
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- Código da empresa
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ titular
                    lpad(nvl(pr_tiporegi,0),1,' ')        ||     -- Tipo C-Conta Corrente; P-Poupança; O-Outros
                    lpad(nvl(pr_cdagenci,0),10,' ')       ||     -- Agência da conta
                    lpad(pr_nrdconta||vr_tpdconta,40,' ') ||     -- Numero da conta
                    nvl(pr_prititul,' ')                  ||     -- Primeiro Titular
                    lpad(nvl(to_char(pr_inivigen,'RRRRMMDD'),' '),8,' ') ||     -- Início Vigência
                    lpad(nvl(to_char(pr_fimvigen,'RRRRMMDD'),' '),8,' ') ||     -- Final Vigência
                    lpad(nvl(pr_tpoperac,0),10,' ')       ||     -- Codigo da operação (101-Conta corrente e 199-Aplicação)
                    'S'                                   ||     -- Gera evento dos demais titulares,  sempre “S”
                    chr(13)||chr(10);                            -- quebrar linha
       
      pc_escreve_clob(vr_dslinha);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao montar linha para a conta '||pr_nrdconta||': '|| SQLERRM;
    END pc_escreve_linha_layout;    
    
    
  BEGIN
     
    -- Inicializar o CLOB
    vr_dsarquiv := NULL;
    dbms_lob.createtemporary(vr_dsarquiv, TRUE);
    dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
                
    vr_nmarqimp := 'titulares_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da geração do arquivo de Cadastro de Titulares da conta,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR')); 
      
    FOR rw_crapcop IN cr_crapcop LOOP  
      --> PESSOA FISICA                                
      --> Buscar saldos dos cooperados
      FOR rw_crapttl IN cr_crapttl (pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_dtiniger => pr_dtiniger,
                                    pr_dtfimger => pr_dtfimger) LOOP
                                       
        /* Se for conta migrada na incorporacao Transulcred -> Transpocred e 
           o periodo final for igual ou menor que 2016, vamos ignorar a conta. */
        IF (fn_ignorar_conta(pr_cdcooper => rw_crapttl.cdcooper,
                             pr_nrdconta => rw_crapttl.nrdconta,
                             pr_dtiniger => pr_dtiniger,
                             pr_dtfimger => pr_dtfimger)) THEN
          CONTINUE;
        END IF;
        
        --> Tratativa para não enviar os dados da propria cooperativa                            
        IF rw_crapttl.nrcpfcgc = rw_crapcop.nrdocnpj THEN
          continue;
        END IF;                               
                                       
        -- Montar a linha conforme layout easyway
        pc_escreve_linha_layout(pr_cdcooper => rw_crapttl.cdcooper,
                                pr_nrcpfcgc => rw_crapttl.nrcpfcgc,
                                pr_inpessoa => rw_crapttl.inpessoa,
                                pr_cdagenci => rw_crapttl.cdagenci,
                                pr_nrdconta => rw_crapttl.nrdconta,
                                pr_tiporegi => 'C', -- C-Conta Corrente 
                                pr_inivigen => rw_crapttl.dtadmiss,
                                pr_fimvigen => rw_crapttl.dtelimin,
                                pr_tpoperac => 101, -- 101 – Conta Corrente
                                pr_prititul => rw_crapttl.prititul,
                                ----- OUT ----
                                pr_dscritic => vr_dscritic);
                                  
        -- Verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
        
        --> Verificar se cooperado possui aplicações
        IF rw_crapttl.tem_aplicacao = 1 THEN  
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapttl.cdcooper,
                                  pr_nrcpfcgc  => rw_crapttl.nrcpfcgc,
                                  pr_inpessoa  => rw_crapttl.inpessoa,
                                  pr_cdagenci  => rw_crapttl.cdagenci,
                                  pr_nrdconta  => rw_crapttl.nrdconta,
                                  pr_tiporegi  => 'O', -- O-Outros
                                  pr_inivigen => rw_crapttl.dtadmiss,
                                  pr_fimvigen => rw_crapttl.dtelimin,
                                  pr_tpoperac  => 199, -- 199-Aplicação
                                  pr_prititul  => rw_crapttl.prititul,
                                  ----- OUT ----
                                  pr_dscritic => vr_dscritic);
                                    
          -- Verificar se retornou critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
        END IF;
                         
      END LOOP;--> Fim loop crapttl 
      
      --> PESSOA JURIDICA
      --> Buscar titulares Pessoa Juridica - enviar proprio cadastro da ass
      FOR rw_crapass IN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_dtiniger => pr_dtiniger,
                                    pr_dtfimger => pr_dtfimger) LOOP
                                       
                                       
        /* Se for conta migrada na incorporacao Transulcred -> Transpocred e 
           o periodo final for igual ou menor que 2016, vamos ignorar a conta. */
        IF (fn_ignorar_conta(pr_cdcooper => rw_crapass.cdcooper,
                             pr_nrdconta => rw_crapass.nrdconta,
                             pr_dtiniger => pr_dtiniger,
                             pr_dtfimger => pr_dtfimger)) THEN
          CONTINUE;
        END IF;
        
        -- Montar a linha conforme layout easyway
        pc_escreve_linha_layout(pr_cdcooper => rw_crapass.cdcooper,
                                pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                pr_inpessoa => rw_crapass.inpessoa,
                                pr_cdagenci => rw_crapass.cdagenci,
                                pr_nrdconta => rw_crapass.nrdconta,
                                pr_tiporegi => 'C', -- C-Conta Corrente 
                                pr_inivigen => rw_crapass.dtadmiss,
                                pr_fimvigen => rw_crapass.dtelimin,
                                pr_tpoperac => 101, -- 101 – Conta Corrente
                                pr_prititul => rw_crapass.prititul,
                                ----- OUT ----
                                pr_dscritic => vr_dscritic);
                                  
        -- Verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
        
        --> Verificar se cooperado possui aplicações
        IF rw_crapass.tem_aplicacao = 1 THEN  
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapass.cdcooper,
                                  pr_nrcpfcgc  => rw_crapass.nrcpfcgc,
                                  pr_inpessoa  => rw_crapass.inpessoa,
                                  pr_cdagenci  => rw_crapass.cdagenci,
                                  pr_nrdconta  => rw_crapass.nrdconta,
                                  pr_tiporegi  => 'O', -- O-Outros
                                  pr_inivigen => rw_crapass.dtadmiss,
                                  pr_fimvigen => rw_crapass.dtelimin,
                                  pr_tpoperac  => 199, -- 199-Aplicação
                                  pr_prititul  => rw_crapass.prititul,
                                  ----- OUT ----
                                  pr_dscritic => vr_dscritic);
                                    
          -- Verificar se retornou critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro;
          END IF; 
        END IF;
                         
      END LOOP;--> Fim loop crapass
      
    END LOOP;  --> Fim loop crapcop
    
    IF vr_texto_completo IS NOT NULL THEN
      pc_escreve_clob('',TRUE);
    END IF;
    
    -- busca diretorio
    vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 3, 
                                             pr_cdacesso => 'DIR_ARQ_EASYWAY');
    --Solicitar geracao do arquivo fisico
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 -- coop Cecred          --> Cooperativa conectada
                                       ,pr_cdprogra  => 'INTEAS'                  --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt       --> Data do movimento atual
                                       ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da geração do arquivo.');
     
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsarquiv);
    dbms_lob.freetemporary(vr_dsarquiv); 
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel gerar arquivo de titulares dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_titulares_ass;
  
  --> Procedimento responsavel em gerar o arquivo com os terceiros vinculados ao cooperados para a Easyway
  PROCEDURE pc_gera_arq_terceiros_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
    Programa : pc_gera_arq_terceiros_ass        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 20/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel em gerar o arquivo com os terceiros vinculados ao cooperados para a Easyway
                (C19.2)
                
    Alteração : Ajustado para que na geração dos procuradores e responsaveis de menores o sistema ignore
                os registros que sao titulares da conta, pois ja serao exportados no arquivo de titulares (28/11/2016).
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper, 0, cop.cdcooper, pr_cdcooper) 
             /* Ou a cooperativa esta ativa ou eh a Transulcred */
         AND (cop.flgativo = 1 or cop.cdcooper = 17)
       ORDER BY cop.cdcooper;
 
    --> Buscar informacoes dos cooperados
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_dtiniger DATE,
                       pr_dtfimger DATE )IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.nrcpfcgc
            ,ass.cdagenci
            ,ass.inpessoa
            ,(CASE
                WHEN EXISTS
                    (SELECT 1
                       FROM craprda rda
                      WHERE rda.cdcooper = ass.cdcooper
                        AND rda.nrdconta = ass.nrdconta) OR EXISTS
                    (SELECT 1
                       FROM craprpp rpp
                      WHERE rpp.cdcooper = ass.cdcooper
                        AND rpp.nrdconta = ass.nrdconta) OR EXISTS
                    (SELECT 1
                       FROM craprac rac
                      WHERE rac.cdcooper = ass.cdcooper
                        AND rac.nrdconta = ass.nrdconta) THEN
                     1
                ELSE 0
              END) tem_aplicacao
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta =
             decode(pr_nrdconta, 0, ass.nrdconta, pr_nrdconta)
         AND ass.dtadmiss <= pr_dtfimger -- Cooperados admitidos até a data final
         AND (ass.dtelimin IS NULL OR -- Cooperados não demitidos                       
             ass.dtelimin >= pr_dtiniger) -- ou demitidos depois da data inicial
       ORDER BY ass.cdcooper
               ,ass.nrdconta;
                        
    --> Pessoa Física
    CURSOR cr_crapcrl (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      
      SELECT nvl(ass.nrcpfcgc, crl.nrcpfcgc) AS nrcpfcgc
            ,nvl(ass.inpessoa, 1) inpessoa
            ,ass.dtadmiss
            /* Se a conta foi demitida depois do periodo, quer dizer
               que temos que exporta-la como ativa ainda. */
            ,case when ass.dtelimin > pr_dtfimger
                  then null
                  else ass.dtelimin
              end dtelimin
            ,3   AS tipo_relacao -- Representante Legal 
        FROM crapcrl crl
        LEFT JOIN crapass ass
          ON ass.cdcooper = crl.cdcooper
         AND ass.nrdconta = crl.nrdconta
       WHERE crl.cdcooper = pr_cdcooper
         AND crl.nrctamen = pr_nrdconta
         AND (crl.nrdconta > 0 OR 
              crl.nrcpfcgc > 0)
             /* Nao exportar como terceiro se o responsavel for um
                titular daquela conta. */
         AND NOT EXISTS (SELECT 1
                           FROM crapttl ttl
                          WHERE ttl.cdcooper = crl.cdcooper
                            AND ttl.nrdconta = crl.nrctamen
                            AND ttl.nrcpfcgc = nvl(ass.nrcpfcgc, crl.nrcpfcgc))
      UNION
      SELECT avt.nrcpfcgc AS nrcpfcgc
            ,avt.inpessoa AS inpessoa
            ,nvl(avt.dtmvtolt, ass.dtadmiss) AS dtadmiss
            /* Se a vigência for posterior a data final do periodo, 
               vamos exportar vazio, cfme solicitacao Suelen J. */
            ,case when nvl(avt.dtvalida, ass.dtelimin) > pr_dtfimger
                  then null
                  else nvl(avt.dtvalida, ass.dtelimin)
              end dtelimin
            ,2            AS tipo_relacao -- Procurador 
        FROM crapavt avt
   LEFT JOIN crapass ass
          ON ass.cdcooper = avt.cdcooper
		 AND ass.nrdconta  = avt.nrdconta
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND (avt.nrcpfcgc > 0 OR
              avt.nrdctato > 0)
         AND avt.tpctrato = 6
         /* Nao exportar repetir se o CPF já conter como rep. legal */
         AND NOT EXISTS (SELECT 1
                           FROM crapcrl crl
                      LEFT JOIN crapass ass
                             ON crl.cdcooper = ass.cdcooper
                            AND crl.nrdconta = ass.nrdconta
                          WHERE crl.cdcooper = avt.cdcooper
                            AND crl.nrctamen = avt.nrdconta
                            AND nvl(ass.nrcpfcgc,crl.nrcpfcgc) = avt.nrcpfcgc)
         /* Nao exportar como terceiro se o procurador for um titular daquela conta. */
         AND NOT EXISTS (SELECT 1
                           FROM crapttl ttl
                          WHERE ttl.cdcooper = avt.cdcooper
                            AND ttl.nrdconta = avt.nrdconta
                            AND ttl.nrcpfcgc = avt.nrcpfcgc);
    
    --> Pessoa juridica
    CURSOR cr_crapavt (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      
      SELECT avt.nrcpfcgc
            ,avt.inpessoa
            ,nvl(avt.dtmvtolt, ass.dtadmiss) AS dtadmiss
            /* Se a vigência for posterior a data final do periodo, 
               vamos exportar vazio, cfme solicitacao Suelen J. */
            ,case when nvl(avt.dtvalida, ass.dtelimin) > pr_dtfimger
                  then null
                  else nvl(avt.dtvalida, ass.dtelimin)
              end dtelimin
            ,(CASE
                WHEN upper(avt.dsproftl) LIKE '%PROCURADOR%' THEN 2 -- Procurador
                ELSE 3
              END) AS tipo_relacao
        FROM crapavt avt
   LEFT JOIN crapass ass
          ON ass.cdcooper = avt.cdcooper
		 AND ass.nrdconta  = avt.nrdconta
       WHERE avt.cdcooper = pr_cdcooper
         AND avt.nrdconta = pr_nrdconta
         AND avt.tpctrato = 6
         AND (avt.nrcpfcgc > 0 OR
              avt.nrdctato > 0);
                 
    -----------> VAIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    -- Variáveis para armazenar as informações do arquivo
    vr_dsarquiv        CLOB;
    -- Variável para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na variável CLOB
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2,
                              pr_fecha_clob IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_dsarquiv, vr_texto_completo, pr_des_dados, pr_fecha_clob);
    END;
    
    -- Montar a linha conforme layout easyway
    PROCEDURE pc_escreve_linha_layout(pr_cdcooper  IN crapcop.cdcooper%TYPE,
                                      pr_nrcpfcgc  IN crapass.nrcpfcgc%TYPE,
                                      pr_inpessoa  IN crapass.inpessoa%TYPE,
                                      pr_cdagenci  IN crapass.cdagenci%TYPE,
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,
                                      pr_inivigen  IN DATE,
                                      pr_fimvigen  IN DATE,
                                      pr_tiporegi  IN VARCHAR2,
                                      pr_tiprelac  IN VARCHAR2,
                                      pr_nrcpfcgc_ter  IN crapass.nrcpfcgc%TYPE,
                                      pr_inpessoa_ter  IN crapass.inpessoa%TYPE,
                                      ----- OUT ----
                                      pr_dscritic OUT VARCHAR2) IS 
      vr_dslinha  VARCHAR2(3200);
      vr_tpdconta VARCHAR2(1);
      
    BEGIN
      -- Definir tipo de conta para concatenar no nrdconta para evitar duplicidade na EasyWay
      IF pr_tiporegi = 'C' THEN
        vr_tpdconta := 'C';
      ELSE
        vr_tpdconta := 'A';
      END IF;
      
      --> Montar linha conforme layout easyway
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- Código da empresa
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ titular
                    lpad(nvl(pr_tiporegi,' '),1,' ')      ||     -- Tipo C-Conta Corrente; P-Poupança; O-Outros                    
                    lpad(nvl(pr_cdagenci,0),10,' ')       ||     -- Agência da conta
                    lpad(pr_nrdconta||vr_tpdconta,40,' ') ||     -- Numero da conta
                    lpad(nvl(to_char(pr_inivigen,'RRRRMMDD'),' '),8,' ') ||     -- Início Vigência
                    lpad(nvl(to_char(pr_inivigen,'RRRRMMDD'),' '),8,' ') ||     -- Início Vigência
                    lpad(nvl(to_char(pr_fimvigen,'RRRRMMDD'),' '),8,' ') ||     -- Final Vigência
                    nvl(pr_tiprelac,' ')                  ||     -- Tipo de Relação Declarado
                    fn_nrcpfcgc_easy(pr_nrcpfcgc_ter,
                                     pr_inpessoa_ter)     ||     -- CPF/CNPJ do Procurador, Representante Legal, Intermediário ou Beneficiário Final
                    'S'                                   ||     -- Gera Evento para Terceiro -S-Sim; N-Não (Gerar todos como “S”)
                    'D'                                   ||     -- Considera Endereço do Titular - D-Declarado; T-Terceiro  (Gerar todos como “D”)
                    chr(13)||chr(10);                            -- quebrar linha
       
      pc_escreve_clob(vr_dslinha);
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao montar linha para a conta '||pr_nrdconta||': '|| SQLERRM;
    END pc_escreve_linha_layout;    
    
    
  BEGIN
     
    -- Inicializar o CLOB
    vr_dsarquiv := NULL;
    dbms_lob.createtemporary(vr_dsarquiv, TRUE);
    dbms_lob.open(vr_dsarquiv, dbms_lob.lob_readwrite);
    -- Inicilizar as informações do XML
    vr_texto_completo := NULL;
                
    vr_nmarqimp := 'terceiros_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da geração do arquivo de Cadastro Terceiros Vinculados a Conta,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR')); 
      
    FOR rw_crapcop IN cr_crapcop LOOP  
                                      
      --> Buscar cooperados
      FOR rw_crapass IN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_dtiniger => pr_dtiniger,
                                    pr_dtfimger => pr_dtfimger) LOOP
                                       
        /* Se for conta migrada na incorporacao Transulcred -> Transpocred e 
           o periodo final for igual ou menor que 2016, vamos ignorar a conta. */
        IF (fn_ignorar_conta(pr_cdcooper => rw_crapass.cdcooper,
                             pr_nrdconta => rw_crapass.nrdconta,
                             pr_dtiniger => pr_dtiniger,
                             pr_dtfimger => pr_dtfimger)) THEN
          CONTINUE;
        END IF;                               
                                       
        --> Tratativa para não enviar os dados da propria cooperativa                            
        IF rw_crapass.nrcpfcgc = rw_crapcop.nrdocnpj THEN
          continue;
        END IF;  
        
        IF rw_crapass.inpessoa = 1 THEN
          -- Buscar procuradoes e responsaveis legais da conta
          FOR rw_crapcrl IN  cr_crapcrl (pr_cdcooper => rw_crapcop.cdcooper,
                                         pr_nrdconta => rw_crapass.nrdconta) LOOP
          
            -- Montar a linha conforme layout easyway
            pc_escreve_linha_layout(pr_cdcooper     => rw_crapass.cdcooper,
                                    pr_nrcpfcgc     => rw_crapass.nrcpfcgc,
                                    pr_inpessoa     => rw_crapass.inpessoa,
                                    pr_cdagenci     => rw_crapass.cdagenci,
                                    pr_nrdconta     => rw_crapass.nrdconta,
                                    pr_inivigen     => rw_crapcrl.dtadmiss,
                                    pr_fimvigen     => rw_crapcrl.dtelimin,
                                    pr_tiporegi     => 'C', -- C-Conta Corrente 
                                    pr_tiprelac     => rw_crapcrl.tipo_relacao,
                                    pr_nrcpfcgc_ter => rw_crapcrl.nrcpfcgc,    
                                    pr_inpessoa_ter => rw_crapcrl.inpessoa,
                                    ----- OUT ----
                                    pr_dscritic => vr_dscritic);
                                      
            -- Verificar se retornou critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF; 
            
            IF rw_crapass.tem_aplicacao = 1 THEN
              -- Montar a linha conforme layout easyway
              pc_escreve_linha_layout(pr_cdcooper     => rw_crapass.cdcooper,
                                      pr_nrcpfcgc     => rw_crapass.nrcpfcgc,
                                      pr_inpessoa     => rw_crapass.inpessoa,
                                      pr_cdagenci     => rw_crapass.cdagenci,
                                      pr_nrdconta     => rw_crapass.nrdconta,
                                      pr_inivigen     => rw_crapcrl.dtadmiss,
                                      pr_fimvigen     => rw_crapcrl.dtelimin,
                                      pr_tiporegi     => 'O', -- Outros
                                      pr_tiprelac     => rw_crapcrl.tipo_relacao,
                                      pr_nrcpfcgc_ter => rw_crapcrl.nrcpfcgc,  
                                      pr_inpessoa_ter => rw_crapcrl.inpessoa,                                 
                                      ----- OUT ----
                                      pr_dscritic => vr_dscritic);
                                        
              -- Verificar se retornou critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  
            END IF;
          
          END LOOP;                                        
        ELSE
          -- Buscar procuradoes e responsaveis legais da conta
          FOR rw_crapavt IN  cr_crapavt (pr_cdcooper => rw_crapcop.cdcooper,
                                         pr_nrdconta => rw_crapass.nrdconta) LOOP
          
          
            -- Montar a linha conforme layout easyway
            pc_escreve_linha_layout(pr_cdcooper     => rw_crapass.cdcooper,
                                    pr_nrcpfcgc     => rw_crapass.nrcpfcgc,
                                    pr_inpessoa     => rw_crapass.inpessoa,
                                    pr_cdagenci     => rw_crapass.cdagenci,
                                    pr_nrdconta     => rw_crapass.nrdconta,
                                    pr_inivigen     => rw_crapavt.dtadmiss,
                                    pr_fimvigen     => rw_crapavt.dtelimin,
                                    pr_tiporegi     => 'C', -- C-Conta Corrente 
                                    pr_tiprelac     => rw_crapavt.tipo_relacao,
                                    pr_nrcpfcgc_ter => rw_crapavt.nrcpfcgc,     
                                    pr_inpessoa_ter => rw_crapavt.inpessoa,
                                    ----- OUT ----
                                    pr_dscritic => vr_dscritic);
                                      
            -- Verificar se retornou critica
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF; 
            
            IF rw_crapass.tem_aplicacao = 1 THEN
              -- Montar a linha conforme layout easyway
              pc_escreve_linha_layout(pr_cdcooper     => rw_crapass.cdcooper,
                                      pr_nrcpfcgc     => rw_crapass.nrcpfcgc,
                                      pr_inpessoa     => rw_crapass.inpessoa,
                                      pr_cdagenci     => rw_crapass.cdagenci,
                                      pr_nrdconta     => rw_crapass.nrdconta,
                                      pr_inivigen     => rw_crapavt.dtadmiss,
                                      pr_fimvigen     => rw_crapavt.dtelimin,
                                      pr_tiporegi     => 'O', -- Outros
                                      pr_tiprelac     => rw_crapavt.tipo_relacao,
                                      pr_nrcpfcgc_ter => rw_crapavt.nrcpfcgc,
                                      pr_inpessoa_ter => rw_crapavt.inpessoa,                                   
                                      ----- OUT ----
                                      pr_dscritic => vr_dscritic);
                                        
              -- Verificar se retornou critica
              IF vr_dscritic IS NOT NULL THEN
                RAISE vr_exc_erro;
              END IF;  
            END IF;
          END LOOP;        
        END IF;
                         
      END LOOP;--> Fim loop crapass  
      
    END LOOP;  --> Fim loop crapcop
    
    IF vr_texto_completo IS NOT NULL THEN
      pc_escreve_clob('',TRUE);
    END IF;
    
    -- busca diretorio
    vr_dsdireto := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 3, 
                                             pr_cdacesso => 'DIR_ARQ_EASYWAY');
    --Solicitar geracao do arquivo fisico
    GENE0002.pc_solicita_relato_arquivo(pr_cdcooper  => 3 -- coop Cecred          --> Cooperativa conectada
                                       ,pr_cdprogra  => 'INTEAS'                  --> Programa chamador
                                       ,pr_dtmvtolt  => pr_dtmvtolt       --> Data do movimento atual
                                       ,pr_dsxml     => vr_dsarquiv               --> Arquivo XML de dados
                                       ,pr_dsarqsaid => vr_dsdireto||'/'||vr_nmarqimp --> Path/Nome do arquivo PDF gerado
                                       ,pr_flg_impri => 'N'                       --> Chamar a impressão (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> Número de cópias para impressão
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diretórios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviará o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviará o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da geração do arquivo.');
     
    -- Liberando a memória alocada pro CLOB
    dbms_lob.close(vr_dsarquiv);
    dbms_lob.freetemporary(vr_dsarquiv); 
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel gerar arquivo de terceiros dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_terceiros_ass;
  
  
  --> Procedimento para chamar rotina pelo ayllosweb
  PROCEDURE pc_trata_param_TELA_INTEAS (pr_tlcdcoop  IN crapcop.cdcooper%TYPE,  --> codigo da cooperativa informado na tela 
                                        pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_dtiniger  IN VARCHAR2,               --> Data Início do período de geração 
                                        pr_dtfimger  IN VARCHAR2,               --> Data Final  do período de geração
                                        pr_dtmvtolt  IN VARCHAR2,               --> Data do movimento
                                        pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado – 0 para todos os arquivos 
                                        pr_xmllog    IN VARCHAR2,               --> XML com informações de LOG
                                        ---- OUT ----                                                                                                                         
                                        pr_cdcritic OUT PLS_INTEGER,            --> Código da crítica
                                        pr_dscritic OUT VARCHAR2,               --> Descrição da crítica
                                        pr_retxml   IN OUT NOCOPY XMLType,      --> Arquivo de retorno do XML
                                        pr_nmdcampo OUT VARCHAR2,               --> Nome do campo com erro
                                        pr_des_erro OUT VARCHAR2) IS
  /* ..........................................................................
    
    Programa : pc_trata_param_TELA_INTEAS        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 12/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento para chamar rotina pelo ayllosweb
    
    Alteração : 
        
  ..........................................................................*/
    vr_exc_erro EXCEPTION;
  
    -- Variaveis de log
    vr_cdcooper  NUMBER;
    vr_cdoperad  VARCHAR2(100);
    vr_nmdatela  VARCHAR2(100);
    vr_nmeacao   VARCHAR2(100);
    vr_cdagenci  VARCHAR2(100);
    vr_nrdcaixa  VARCHAR2(100);
    vr_idorigem  VARCHAR2(100);
    vr_nmarqlog  VARCHAR2(400);
    vr_dscritic  VARCHAR2(4000);
    vr_dtiniger  DATE;
    vr_dtfimger  DATE;
    vr_dtmvtolt  DATE;
    
    
  BEGIN
  
    --> Extrair dados do xml
    GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);                                                        
  
    BEGIN
      vr_dtiniger := to_date('01/'||pr_dtiniger,'DD/MM/RRRR');
      vr_dtfimger := last_day(to_date('01/'||pr_dtfimger,'DD/MM/RRRR'));
      vr_dtmvtolt := to_date(pr_dtmvtolt,'DD/MM/RRRR');
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Data informanda não é valida.';
        RAISE vr_exc_erro;
    END;
    
    pc_gera_arquivos_integracao ( pr_cdcooper  => pr_tlcdcoop,  --> Codigo da cooperativa                                        
                                  pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                                  pr_dtiniger  => vr_dtiniger,  --> Data Início do período de geração 
                                  pr_dtfimger  => vr_dtfimger,  --> Data Final  do período de geração
                                  pr_dtmvtolt  => vr_dtmvtolt,  --> Data do movimento
                                  pr_inarquiv  => pr_inarquiv,  --> Arquivo a ser exportado – 0 para todos os arquivos                                           
                                  ---- OUT ----                                                                                                                         
                                  pr_nmarqlog => vr_nmarqlog,   --> nome do arquivo de log
                                  pr_cdcritic => pr_cdcritic,   --> Código da crítica
                                  pr_dscritic => pr_dscritic);  --> Descrição da crítica
  
    IF nvl(pr_cdcritic,0) > 0 OR
       TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    -- Criar cabeçalho do XML
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Dados',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);  
                           
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Dados',
                           pr_posicao  => 0,
                           pr_tag_nova => 'nmarqlog',
                           pr_tag_cont => vr_nmarqlog||'.log',
                           pr_des_erro => vr_dscritic);
                                                          
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Se foi retornado apenas código
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        -- Buscar a descrição
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao gerar arquivo: ' || SQLERRM;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_trata_param_TELA_INTEAS;
  
  --> Procedimento responsavel por disparar a geração dos arquivos de integração Easyway
  PROCEDURE pc_gera_arquivos_integracao ( pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                          pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                          pr_dtiniger  IN DATE,                   --> Data Início do período de geração 
                                          pr_dtfimger  IN DATE,                   --> Data Final  do período de geração
                                          pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                          pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado – 0 para todos os arquivos                                           
                                          ---- OUT ----                                                                                                                         
                                          pr_nmarqlog OUT VARCHAR2,                --> nome do arquivo de log
                                          pr_cdcritic OUT PLS_INTEGER,            --> Código da crítica
                                          pr_dscritic OUT VARCHAR2                --> Descrição da crítica
                                          ) IS
  /* ..........................................................................
    
    Programa : pc_gera_arquivos_integracao        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 13/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel por disparar a geração dos arquivos de integração Easyway

                pr_inarquiv 
                [1 – Cadastro de Cooperados]
                [2 – Cadastro de Operações de Cooperados]
                [3 – Saldo das Operações dos Cooperados]
                [5 – Movimentação das Operações dos Cooperados]
    Alteração : 
        
  ..........................................................................*/
    -----------> CURSORES <----------- 
    
    -----------> VAIAVEIS <-----------  
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
          
    --Log    
    vr_nmarqlog      VARCHAR2(100);
    vr_dsplsql       VARCHAR2(32000); 
    vr_dsparame      VARCHAR2(8000); 
    vr_jobname       VARCHAR2(100);
    vr_dssufarq      VARCHAR2(100);
    
  BEGIN
    
    -- Definir variavel de log
    vr_nmarqlog := 'log'||to_char(SYSDATE,'RRRRMMDD_HH24MI');
    
    pc_gera_log_easyway(vr_nmarqlog,
                'Preparando geração '||
                (CASE pr_inarquiv 
                   WHEN 0 THEN 'de todos os arquivos.'
                   WHEN 1 THEN 'do arquivo de Cadastro de Cooperados.' 
                   WHEN 2 THEN 'do arquivo de Cadastro de Titulares da conta.' 
                   WHEN 3 THEN 'do arquivo de Cadastro Terceiros Vinculados a Conta.' 
                   WHEN 4 THEN 'do arquivo de Saldo das Operações dos Cooperados.' 
                   WHEN 5 THEN 'do arquivo de Movimentação das Operações dos Cooperados.' 
                   ELSE NULL
                  END));
    
    IF pr_dtfimger > trunc(pr_dtmvtolt,'MM') THEN
      vr_dscritic := 'Periodo invalido, data final deve ser menor que o mês corrente('||to_char(pr_dtmvtolt,'MM/RRRR') ||').';
      RAISE vr_exc_erro;
    END IF;
    
    -- Definir sufixo do nome dos arquivos para facilitar identificacao dos arquivos
    -- pois pode levar certo tempo para a sua geracao
    vr_dssufarq := to_char(systimestamp,'RRRRMMDDHH24MISSFF3');
    
    -- Definir os parametros das rotinas visto que para todas são iguais
    vr_dsparame := ' (pr_cdcooper  => '|| pr_cdcooper ||chr(13)||
                   ' ,pr_nrdconta  => '|| nvl(pr_nrdconta,0) ||chr(13)||
                   ' ,pr_dtiniger  => to_date('''|| to_char(pr_dtiniger,'DD/MM/RRRR') ||
                                              ''',''DD/MM/RRRR'')'||chr(13)||
                   ' ,pr_dtfimger  => to_date('''|| to_char(pr_dtfimger,'DD/MM/RRRR') ||
                                              ''',''DD/MM/RRRR'')'||chr(13)||
                   ' ,pr_dtmvtolt  => to_date('''|| to_char(pr_dtmvtolt,'DD/MM/RRRR') ||
                                              ''',''DD/MM/RRRR'')'||chr(13)||
                   ' ,pr_nmarqlog  => '''|| vr_nmarqlog||''''||chr(13)||
                   ' ,pr_dssufarq  => '''|| vr_dssufarq||''''||chr(13)||
                   ' /*---- OUT ----*/ '                  ||chr(13)||              
                   ' ,pr_cdcritic  => vr_dscritic'    ||chr(13)|| 
                   ' ,pr_dscritic  => vr_cdcritic);'  ||chr(13);
    
    
    
    -- Montar estrutura sql para executar procedimento via Job
    vr_dsplsql      := 'DECLARE '||chr(13)||
                     ' vr_dscritic varchar2(4000);' ||chr(13)||
                     ' vr_cdcritic number;'        ||chr(13)||
                    'BEGIN '||chr(13); 
    
    -- Arquivo Cadastro de Cooperados
    IF pr_inarquiv = 1 OR pr_inarquiv = 0 THEN
      --> Procedimento responsavel em gerar o arquivo de Cadastro de Cooperados para a Easyway                          
      vr_dsplsql := vr_dsplsql||' CECRED.TELA_INTEAS.pc_gera_arq_cadastro_ass '   ||chr(13)||
                                vr_dsparame ||chr(13);                          
    END IF;
    
    -- Arquivo Cadastro de Titulares da conta
    IF pr_inarquiv = 2 OR pr_inarquiv = 0 THEN
      --> Procedimento responsavel em gerar o arquivo de Cadastro de Cooperados para a Easyway                          
      vr_dsplsql := vr_dsplsql||' CECRED.TELA_INTEAS.pc_gera_arq_titulares_ass '   ||chr(13)||
                                vr_dsparame ||chr(13);                          
    END IF;
    
    -- Arquivo Cadastro Terceiros Vinculados a Conta
    IF pr_inarquiv = 3 OR pr_inarquiv = 0 THEN
      --> Procedimento responsavel em gerar o arquivo de Cadastro de Cooperados para a Easyway                          
      vr_dsplsql := vr_dsplsql||' CECRED.TELA_INTEAS.pc_gera_arq_terceiros_ass '   ||chr(13)||
                                vr_dsparame ||chr(13);                          
    END IF;
    
    -- Arquivo Saldo das Operações dos Cooperados
    IF pr_inarquiv = 4 OR pr_inarquiv = 0 THEN
      --> Procedimento responsavel em gerar o arquivo de Cadastro de Cooperados para a Easyway                          
      vr_dsplsql := vr_dsplsql||' CECRED.TELA_INTEAS.pc_gera_arq_saldo_ope_ass '   ||chr(13)||
                                vr_dsparame ||chr(13);                          
    END IF;
    
    -- Arquivo Movimentação das Operações dos Cooperados
    IF pr_inarquiv = 5 OR pr_inarquiv = 0 THEN
      --> Procedimento responsavel em gerar o arquivo de movimentação das operações dos cooperados para a Easyway    
      vr_dsplsql := vr_dsplsql||' CECRED.TELA_INTEAS.pc_gera_arq_movimento_ass '   ||chr(13)||
                                vr_dsparame ||chr(13);   
    END IF;
    
    -- concluir chamada  dos programas
    vr_dsplsql      := vr_dsplsql ||'CECRED.TELA_INTEAS.pc_gera_log_easyway( '''||vr_nmarqlog||''',''Final da execução.'');'||chr(13)
                       ||' EXCEPTION WHEN OTHERS THEN '||chr(13)
                       ||'CECRED.TELA_INTEAS.pc_gera_log_easyway( '''||vr_nmarqlog||''',''Erro:''||sqlerrm);'||chr(13)
                       ||' END; ';
    
    -- Montar o prefixo do código do programa para o jobname
    vr_jobname := 'INTEAS$';
    -- Faz a chamada ao programa paralelo atraves de JOB
    GENE0001.pc_submit_job(pr_cdcooper  => 3            --> Código da cooperativa
                          ,pr_cdprogra  => 'INTEAS'     --> Código do programa
                          ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                          ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                          ,pr_jobname   => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro  => pr_dscritic);
    -- Testar saida com erro
    IF pr_dscritic IS NOT NULL THEN
      -- Levantar exceçao
      RAISE vr_exc_erro;
    END IF;
    --> retornar nome do log
    pr_nmarqlog := vr_nmarqlog ; 
  
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      pc_gera_log_easyway( vr_nmarqlog,'Não foi possivel concluir geração do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'Não foi possivel gerar arquivos: '||SQLERRM;
      pc_gera_log_easyway( vr_nmarqlog,pr_dscritic);
  END pc_gera_arquivos_integracao;
      
  
    
END TELA_INTEAS;
/
