CREATE OR REPLACE PACKAGE CECRED.TELA_INTEAS is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : TELA_INTEAS
      Sistema  : Rotinas referentes tela de integra��o com sistema Easy-Way
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Abril/2016.                   Ultima atualizacao: 12/04/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes tela de integra��o com sistema Easy-Way

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Gerar log da easyway
  PROCEDURE pc_gera_log_easyway (pr_nmarqlog IN VARCHAR2,
                                 pr_dsmsglog IN VARCHAR2 );
                                 
  PROCEDURE pc_gera_arq_cadastro_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                      pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                      pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                      pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
                                      pr_dtmvtolt  IN DATE,                    --> Data do movimento
                                      pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                      pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                      ---- OUT ----                                                                               
                                      pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                      pr_dscritic OUT VARCHAR2);              --> Descricao da critica
  
  --> Procedimento responsavel em gerar a movimenta��o das opera��es dos cooperados
  PROCEDURE pc_gera_arq_movimento_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                       
  
  --> Procedimento responsavel em gerar o arquivo com os saldos das opera��es dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_saldo_ope_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                       
  --> Procedimento responsavel em gerar o arquivo dos titulares dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_titulares_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
                                       
  --> Procedimento responsavel em gerar o arquivo com os terceiros vinculados ao cooperados para a Easyway
  PROCEDURE pc_gera_arq_terceiros_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
                                       pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                       pr_nmarqlog  IN VARCHAR2,               --> Nome do log do processo 
                                       pr_dssufarq  IN VARCHAR2,               --> Descricao do sufixo do arquivo a ser gerado
                                       ---- OUT ----                                                                               
                                       pr_cdcritic OUT NUMBER,                 --> Codigo da critica
                                       pr_dscritic OUT VARCHAR2);              --> Descricao da critica
  
  --> Procedimento para chamar rotina pelo ayllosweb
  PROCEDURE pc_trata_param_TELA_INTEAS (pr_tlcdcoop  IN crapcop.cdcooper%TYPE,  --> codigo da cooperativa informado na tela 
                                        pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_dtiniger  IN VARCHAR2,               --> Data In�cio do per�odo de gera��o 
                                        pr_dtfimger  IN VARCHAR2,               --> Data Final  do per�odo de gera��o
                                        pr_dtmvtolt  IN VARCHAR2,               --> Data do movimento
                                        pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado � 0 para todos os arquivos 
                                        pr_xmllog    IN VARCHAR2,               --> XML com informa��es de LOG
                                        ---- OUT ----                                                                                                                         
                                        pr_cdcritic OUT PLS_INTEGER,            --> C�digo da cr�tica
                                        pr_dscritic OUT VARCHAR2,               --> Descri��o da cr�tica
                                        pr_retxml   IN OUT NOCOPY XMLType,      --> Arquivo de retorno do XML
                                        pr_nmdcampo OUT VARCHAR2,               --> Nome do campo com erro
                                        pr_des_erro OUT VARCHAR2);
                                        
  --> Procedimento responsavel por disparar a gera��o dos arquivos de integra��o Easyway
  PROCEDURE pc_gera_arquivos_integracao ( pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                          pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                          pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                          pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
                                          pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                          pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado � 0 para todos os arquivos 
                                          ---- OUT ----                                                                               
                                          pr_nmarqlog OUT VARCHAR2,   --> nome do arquivo de log
                                          pr_cdcritic OUT PLS_INTEGER,            --> C�digo da cr�tica
                                          pr_dscritic OUT VARCHAR2 );               --> Descri��o da cr�tica
                                                                                    
                                                                                   
END TELA_INTEAS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_INTEAS IS
  /* ---------------------------------------------------------------------------------------------------------------


      Programa : TELA_INTEAS
      Sistema  : Rotinas referentes tela de integra��o com sistema Easy-Way
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Abril/2016.                   Ultima atualizacao: 20/10/2016

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes tela de integra��o com sistema Easy-Way

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
                               e a conta ainda possui saldos, j� dtelimin � apos a conta n�o possuir mais movimenta��o
                               e os saldos zerados. (Odirlei-AMcom)
                               
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
  
  /* Qualquer altera��o aqui, por favor, avalir se continua removendo caracteres 
     estranhos como por exemplo: ""
     Em algumas altera��es, deixou de remover este caracter.
     Obs.: Nao utilizar esta funcao sobre a linha completa do arquivo txt,
           pois remove tambem a quebra de linha.
  */
  FUNCTION fn_remove_caract_espec(pr_string IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN REGEXP_REPLACE( gene0007.fn_caract_acento(pr_string,1,'#$&%������*!?<>/\|',
                                                                 '                  ')
                          ,'[^a-zA-Z0-9�@:._ +,();=-]+',' ');
  END fn_remove_caract_espec;
  
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
                                      pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                      pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
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
    
    Altera��o : Alterado para remover os acentos das linhas de exporta��o desse arquivo,
	            por solicita��o do Mathera (10/11/2016).
        
                Alterado para quando os segundo e demais titulares nao tiverem endereco preenchido,
                buscar do primeiro titular. 
                Alterado para quando os procuradores e representantes de menores nao tiverem endereco
                preenchido, buscar da conta principal (17/11/2016).
        
                Ajustado para que a busca pela conta mais atualizada desconsidere as contas que foram
                demitidas antes do per�odo inicial (28/11/2016).
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper
         AND cop.flgativo = 1
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
         AND ass.dtadmiss <= pr_dtfimger   -- Cooperados admitidos at� a data final
         AND (ass.dtelimin IS NULL OR      -- Cooperados n�o eliminacao da conta                       
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
    
    --> Buscar endere�o do cooperado
    CURSOR cr_crapenc ( pr_cdcooper  crapenc.cdcooper%TYPE,
                        pr_nrdconta  crapenc.nrdconta%TYPE,
                        pr_idseqttl  crapenc.idseqttl%TYPE,
                        pr_inpessoa  crapass.inpessoa%TYPE) IS
      SELECT TRIM(substr(enc.dsendere,
                          instr(TRIM(enc.dsendere), ' '),
                          length(enc.dsendere))) AS endereco
             ,enc.nrendere 
             ,enc.complend 
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
                enc.idseqttl = 1 or   /* Ou � o primeiro titular, Ou o endereco esta preenchido */
               (enc.idseqttl > 1 and trim(enc.dsendere) is not null and trim(nmcidade) is not null)
              )
        ORDER BY enc.idseqttl DESC; --Retornar o endere�o do titular passado por param
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
       ORDER BY tfc.idseqttl DESC; --Retornar o endere�o do titular passado por param
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
    
    --> Procuradores Pessoa F�sica
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
    
  -----------> VAIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    vr_idxctrl      VARCHAR2(20);
    
    -- Vari�veis para armazenar as informa��es do arquivo
    vr_dsarquiv        CLOB;
    -- Vari�vel para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    vr_dslinha       VARCHAR2(4000);
    
    vr_idsitcnt      VARCHAR2(1);
    vr_flpriass      BOOLEAN;
  -----------> TEMPTABLES <----------- 
    -- Temptable para controlar se ja processou o cpf/cnpj       
    TYPE typ_tab_nrcpfcnpj IS TABLE OF NUMBER
      INDEX BY VARCHAR2(14);
    
    vr_tab_nrcpfcnpj typ_tab_nrcpfcnpj;
    
    
  -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na vari�vel CLOB
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
      
      --> Buscar endere�o do cooperado
      OPEN cr_crapenc ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => pr_idseqttl,
                        pr_inpessoa => pr_inpessoa);
      FETCH cr_crapenc INTO rw_crapenc;
      IF cr_crapenc%NOTFOUND THEN
        CLOSE cr_crapenc;
        vr_dscritic := 'N�o foi possivel gerar cadastro do associado'||
                       ' CPF/CNPJ ' ||pr_nrcpfcgc||
                       ' cooper '||pr_cdcooper||
                       ' conta ' ||pr_nrdconta||
                       ', endere�o n�o encontrado';
        RAISE vr_exc_erro;            
        
      END IF;
      CLOSE cr_crapenc;
        
      --> Buscar endere�o do cooperado
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
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nrendere,0)), 8,' ')       ||     --> N�mero
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.complend,' ')),40,' ')     ||     --> Complemento
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nrcepend,0)), 8,' ')       ||     --> CEP
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nmbairro,' ')),20,' ')     ||     --> Bairro
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.nmcidade,' ')),30,' ')     ||     --> Descri��o Cidade
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.cdufende,' ')), 2,' ')     ||     --> UF
                    rpad(fn_remove_caract_espec(nvl(rw_craptfc.nrtelefo,' ')),15,' ')     ||     --> Telefone   
                    lpad(nvl(pr_dtnasctl,' '),8,' ')              ||     --> Data de Nascimento
                    rpad(nvl(pr_nrinsmun,' '),20,' ')             ||     --> Inscri��o Municipal
                    lpad(nvl(pr_dtadmiss,' '),8,' ')              ||     --> Data da Inclus�o no sistema de origem
                    lpad(nvl(pr_dtaltera,' '),8,' ')              ||     --> Data �ltima altera��o sistema de origem                    
                    'N'   ||               --> Estrangeiro (sem cpf/cnpj) (N - N�o � estrangeiro; C - Estrangeiro com CPF;S - Estrangeiro sem CPF)
                    rpad(' ', 3,' ')                              ||     --> C�digo do Pa�s
                    rpad(' ',20,' ')                              ||     --> Numero de Identifica��o Fiscal (se estrangeiro)
                    rpad(' ', 3,' ')                              ||     --> Natureza da Rela��o
                    rpad(' ',40,' ')                              ||     --> Descri��o do Estado (se estrangeiro)
                    rpad(fn_remove_caract_espec(nvl(rw_crapcem.dsdemail,' ')),60,' ')     ||     --> Email
                    pr_dspessoa                                   ||     --> PF/PJ(F - PF; J � PJ)
                    rpad(nvl(pr_nrinsest,' '),20,' ')             ||     --> Inscri��o Estadual
                    vr_idsitcnt                                   ||     --> Status do Contribuinte
                    rpad(fn_remove_caract_espec(nvl(rw_crapenc.tp_lograd,' ')),10,' ')    ||     --> Tipo de Logradouro
                    nvl(pr_isento_inscr_estadual,' ')             ||     --> Isento de Inscri��o Estadual
                    lpad(' ',19,' ')                              ||     --> GIIN (Global Intermediary Identification Number)
                    lpad(' ',25,' ')                              ||     --> Numero do Passaporte
                    lpad(' ', 1,' ')                              ||     --> Tipo da Institui��o Financeira (FATCA)
                    lpad(' ',10,' ')                              ||     --> Tipo de declarado
                    chr(13)||chr(10);                                    --> quebrar linha
         
      pc_escreve_clob(vr_dslinha);
      
      /* Gera��o de Log */
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
          vr_dscritic := 'N�o foi possivel gerar cadastro do associado'||
                         ' CPF/CNPJ ' ||pr_nrcpfcgc||
                         ' cooper '||pr_cdcooper||
                         ' conta ' ||pr_nrdconta||
                         ', Dados pessoa juridica n�o encontrado';
          RAISE vr_prox_reg;
        END IF;
        CLOSE cr_crapjur;
      END IF;
        
      --> Buscar menor data de admissao do cpf/cnpj
      OPEN cr_crapass_admiss (pr_nrcpfcgc => pr_nrcpfcgc);
      FETCH cr_crapass_admiss INTO rw_crapass_admiss;
      CLOSE cr_crapass_admiss;
      IF rw_crapass_admiss.dtadmiss IS NULL THEN
        vr_dscritic :='N�o foi possivel gerar cadastro do associado'||
                      ' CPF/CNPJ ' ||pr_nrcpfcgc||
                      ' cooper '||pr_cdcooper||
                      ' conta ' ||pr_nrdconta||
                      ', data de admiss�o n�o encontrada';
        RAISE vr_prox_reg;
      END IF;
        
      IF pr_cdsitdct IN (1, -- normal 
                                 3, -- contas que n�o podem ter movimento de produtos
                                 5, -- cooperado com restri��o
                                 6  -- Normal sem tal�o
                                 )THEN
        vr_idsitcnt := 'A';
      ELSIF pr_cdsitdct IN (4, -- encerrada
                                    2,
                                    9) THEN  -- encerrada por outros motivos
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

        /* Quando n�o for o primeiro titular, pode ser que essa pessoa possua a sua pr�pria conta
            individual. Dessa forma devemos busca-la para termos os dados mais atualizados.
           Obs.: O Ayllos realiza a busca atrav�s do CPF tamb�m, ver CADA0001.pc_busca_conta.  */
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
        pr_dscritic := 'N�o foi possivel gerar cadastro do associado'||
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
                    rpad(fn_remove_caract_espec(nvl(pr_nrendere,' ')), 8,' ')     ||     --> N�mero
                    rpad(fn_remove_caract_espec(nvl(pr_complend,' ')),40,' ')     ||     --> Complemento
                    rpad(fn_remove_caract_espec(nvl(pr_nrcepend,' ')), 8,' ')     ||     --> CEP
                    rpad(fn_remove_caract_espec(nvl(pr_nmbairro,' ')),20,' ')     ||     --> Bairro
                    rpad(fn_remove_caract_espec(nvl(pr_nmcidade,' ')),30,' ')     ||     --> Descri��o Cidade
                    rpad(fn_remove_caract_espec(nvl(pr_cdufende,' ')), 2,' ')     ||     --> UF
                    rpad(' ',15,' ')                      ||     --> Telefone   
                    lpad(nvl(pr_dtnasctl,' '),8,' ')      ||     --> Data de Nascimento
                    rpad(' ',20,' ')                      ||     --> Inscri��o Municipal
                    lpad(nvl(pr_dtmvtolt,' '),8,' ')      ||     --> Data da Inclus�o no sistema de origem
                    lpad(nvl(pr_dtmvtolt,' '),8,' ')      ||     --> Data �ltima altera��o sistema de origem                    
                    'N'                                   ||     --> Estrangeiro (sem cpf/cnpj) (N - N�o � estrangeiro; C - Estrangeiro com CPF;S - Estrangeiro sem CPF)
                    rpad(' ', 3,' ')                      ||     --> C�digo do Pa�s
                    rpad(' ',20,' ')                      ||     --> Numero de Identifica��o Fiscal (se estrangeiro)
                    rpad(' ', 3,' ')                      ||     --> Natureza da Rela��o
                    rpad(' ',40,' ')                      ||     --> Descri��o do Estado (se estrangeiro)
                    rpad(' ',60,' ')                      ||     --> Email
                    pr_dspessoa                           ||     --> PF/PJ(F - PF; J � PJ)
                    rpad(' ',20,' ')                      ||     --> Inscri��o Estadual
                    'A'                                   ||     --> Status do Contribuinte
                    rpad(fn_remove_caract_espec(nvl(pr_tplograd,' ')),10,' ')     ||     --> Tipo de Logradouro
                    ' '                                   ||     --> Isento de Inscri��o Estadual
                    lpad(' ',19,' ')                      ||     --> GIIN (Global Intermediary Identification Number)
                    lpad(' ',25,' ')                      ||     --> Numero do Passaporte
                    lpad(' ', 1,' ')                      ||     --> Tipo da Institui��o Financeira (FATCA)
                    lpad(' ',10,' ')                      ||     --> Tipo de declarado
                    chr(13)||chr(10);                            --> quebrar linha
          
      pc_escreve_clob(vr_dslinha);
      
      /* Gera��o de Log */
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
        pr_dscritic := 'N�o foi possivel gerar cadastro do associado'||
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
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;
    
    -- Incializar variaveis      
    vr_nmarqimp := 'cadast_'||pr_dssufarq||'.txt';        
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da gera��o do arquivo Cadastro de Cooperados,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR'));             
  
    --> Se estiver processando uma cooperativa
    IF nvl(pr_cdcooper,0) > 0 THEN
    
      --> Buscar CNPJ da coop
      OPEN cr_crapcop;
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      
      IF rw_crapcop.nrdocnpj > 0 THEN        
        --> Incluir como ja processado para n�o gerar informacoes da coop no arquivo
        vr_idxctrl := lpad(rw_crapcop.nrdocnpj,14,'0');
        vr_tab_nrcpfcnpj(vr_idxctrl) := rw_crapcop.nrdocnpj;         
      END IF;
    
    END IF;
    
     
    --> Buscar os CPFs/CNPJs a serem enviados para a Easyway
    FOR rw_crapass_nrcpfcgc IN cr_crapass_nrcpfcgc(pr_nrdconta => pr_nrdconta,
                                                   pr_dtiniger => pr_dtiniger,
                                                   pr_dtfimger => pr_dtfimger) LOOP
      
      -- loop para garantir que todas as pessoas sejam enviadas para o arquivo.
      -- Visto que os dados principais do associado devem ser os da conta mais atualizada
      -- caso exista mais de uma conta, assim o loop for�a que primeiro seja enviado a conta mais atualizada
      -- e posteriormente executa todos os selects com a conta original a fim de enviar as pessoas ainda n�o enviadas
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
          -- Qnd n�o for a primeira vez, significa que o associado n�o � a conta
          -- mais atualizada, por�m � necessario for�ar o envio novamente
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
          continue;
        END IF;
        
        -- Sair do loop qnd processar a mesma conta entre os dois cursores
        IF rw_crapass_nrcpfcgc.nrdconta = rw_crapass.nrdconta THEN
          EXIT;
        END IF;
        
      END LOOP;    
    END LOOP; -- Fim  Loop cr_crapass_nrcpfcgc
    

    --> Buscar os Procuradores e Respons�veis dos cooperados enviados para a Easyway
    FOR rw_crapass_nrcpfcgc IN cr_crapass_nrcpfcgc(pr_nrdconta => pr_nrdconta,
                                                   pr_dtiniger => pr_dtiniger,
                                                   pr_dtfimger => pr_dtfimger) LOOP

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
              /* Se n�o tiver data 'cadastro' do responsavel de menor, carrega a data de admissao da conta */
              IF (rw_crapcrl.dtmvtolt IS NULL) THEN
                rw_crapcrl.dtmvtolt := to_char(rw_crapass_nrcpfcgc.dtadmiss,'RRRRMMDD');
              END IF;
              
              /* Se n�o tiver endereco, vamos buscar da conta principal */
              IF (trim(rw_crapcrl.dsendres) IS NULL AND
                  trim(rw_crapcrl.nmcidade) IS NULL) THEN
                OPEN cr_crapenc ( pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                                  pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta,
                                  pr_idseqttl => 1,
                                  pr_inpessoa => rw_crapass_nrcpfcgc.inpessoa);
                FETCH cr_crapenc INTO rw_crapenc;
                IF cr_crapenc%NOTFOUND THEN
                  CLOSE cr_crapenc;
                  vr_dscritic := 'N�o foi possivel gerar o endere�o da conta principal para o procurador/representante da conta. '||
                                 ' Procurador: CPF/CNPJ ' ||rw_crapcrl.nrcpfcgc||
                                 ' cooper '||rw_crapass_nrcpfcgc.cdcooper||
                                 ' conta ' ||rw_crapass_nrcpfcgc.nrdconta||
                                 ', endere�o n�o encontrado';
                  RAISE vr_exc_erro;
                END IF;
                rw_crapcrl.dsendres := rw_crapenc.endereco;
                rw_crapcrl.nrendere := rw_crapenc.nrendere;
                rw_crapcrl.complend := rw_crapenc.complend;
                rw_crapcrl.nrcepend := rw_crapenc.nrcepend;
                rw_crapcrl.nmbairro := rw_crapenc.nmbairro;
                rw_crapcrl.nmcidade := rw_crapenc.nmcidade;
                rw_crapcrl.cdufresd := rw_crapenc.cdufende;
                rw_crapcrl.tplograd := rw_crapenc.tp_lograd;
                CLOSE cr_crapenc;
              END IF;
              
              --> Rotina para montar layout de cadastro do outras pessoas que nao possuem conta
              pc_trata_outro( pr_cdcooper  => rw_crapass_nrcpfcgc.cdcooper,
                              pr_nrcpfcgc  => rw_crapcrl.nrcpfcgc,  
                              pr_inpessoa  => rw_crapcrl.inpessoa,  
                              pr_dspessoa  => rw_crapcrl.dspessoa,  
                              pr_nrdconta  => rw_crapass_nrcpfcgc.nrdconta,  
                              pr_nmprimtl  => rw_crapcrl.nmdavali,    
                              pr_dtnasctl  => rw_crapcrl.dtnascto,  
                              pr_endereco  => rw_crapcrl.dsendres,  
                              pr_nrendere  => rw_crapcrl.nrendere,  
                              pr_complend  => rw_crapcrl.complend,  
                              pr_nrcepend  => rw_crapcrl.nrcepend,  
                              pr_nmbairro  => rw_crapcrl.nmbairro,  
                              pr_nmcidade  => rw_crapcrl.nmcidade,  
                              pr_cdufende  => rw_crapcrl.cdufresd,    
                              pr_tplograd  => rw_crapcrl.tplograd,  
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
              /* Se n�o tiver data 'cadastro' do procurador, carrega a data de admissao da conta */
              IF (rw_crapavt.dtmvtolt IS NULL) THEN
                rw_crapavt.dtmvtolt := to_char(rw_crapass_nrcpfcgc.dtadmiss,'RRRRMMDD');
              END IF;
              
              /* Se n�o tiver endereco, vamos buscar da conta principal */
              IF (trim(rw_crapavt.dsendres) IS NULL AND
                  trim(rw_crapavt.nmcidade) IS NULL) THEN
                OPEN cr_crapenc ( pr_cdcooper => rw_crapass_nrcpfcgc.cdcooper,
                                  pr_nrdconta => rw_crapass_nrcpfcgc.nrdconta,
                                  pr_idseqttl => 1,
                                  pr_inpessoa => rw_crapass_nrcpfcgc.inpessoa);
                FETCH cr_crapenc INTO rw_crapenc;
                IF cr_crapenc%NOTFOUND THEN
                  CLOSE cr_crapenc;
                  vr_dscritic := 'N�o foi possivel gerar o endere�o da conta principal para o procurador da conta. '||
                                 ' Procurador: CPF/CNPJ ' ||rw_crapavt.nrcpfcgc||
                                 ' cooper '||rw_crapass_nrcpfcgc.cdcooper||
                                 ' conta ' ||rw_crapass_nrcpfcgc.nrdconta||
                                 ', endere�o n�o encontrado';
                  RAISE vr_exc_erro;
                END IF;
                rw_crapavt.dsendres := rw_crapenc.endereco;
                rw_crapavt.nrendere := rw_crapenc.nrendere;
                rw_crapavt.complend := rw_crapenc.complend;
                rw_crapavt.nrcepend := rw_crapenc.nrcepend;
                rw_crapavt.nmbairro := rw_crapenc.nmbairro;
                rw_crapavt.nmcidade := rw_crapenc.nmcidade;
                rw_crapavt.cdufresd := rw_crapenc.cdufende;
                rw_crapavt.tplograd := rw_crapenc.tp_lograd;
                CLOSE cr_crapenc;
              END IF;
              
              --> Rotina para montar layout de cadastro do outras pessoas que nao possuem conta
              pc_trata_outro( pr_cdcooper  => rw_crapass_nrcpfcgc.cdcooper,
                              pr_nrcpfcgc  => rw_crapavt.nrcpfcgc,  
                              pr_inpessoa  => rw_crapavt.inpessoa,  
                              pr_dspessoa  => rw_crapavt.dspessoa,  
                              pr_nrdconta  => rw_crapass_nrcpfcgc.nrdconta,  
                              pr_nmprimtl  => rw_crapavt.nmdavali,    
                              pr_dtnasctl  => rw_crapavt.dtnascto,  
                              pr_endereco  => rw_crapavt.dsendres,
                              pr_nrendere  => rw_crapavt.nrendere,  
                              pr_complend  => rw_crapavt.complend,  
                              pr_nrcepend  => rw_crapavt.nrcepend,  
                              pr_nmbairro  => rw_crapavt.nmbairro,  
                              pr_nmcidade  => rw_crapavt.nmcidade,  
                              pr_cdufende  => rw_crapavt.cdufresd,    
                              pr_tplograd  => rw_crapavt.tplograd,  
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
                                       ,pr_flg_impri => 'N'                       --> Chamar a impress�o (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> N�mero de c�pias para impress�o
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviar� o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviar� o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
        
    pc_gera_log_easyway( pr_nmarqlog,'Final da gera��o do arquivo.');
    
    COMMIT;
    
  EXCEPTION
    WHEN vr_exc_erro THEN     
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      --pc_gera_log( 'N�o foi possivel concluir gera��o do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar arquivo de cadstro dos cooperados: '||SQLERRM;
      --pc_gera_log( pr_dscritic);
  END pc_gera_arq_cadastro_ass;
  
  
  --> Procedimento responsavel em gerar o arquivo de movimenta��o das opera��es dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_movimento_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
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
    Data     : Abril/2016.                   Ultima atualizacao: 12/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel em gerar a movimenta��o das opera��es dos cooperados
    
    Altera��o : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper, 0, cop.cdcooper, pr_cdcooper) 
         AND cop.flgativo = 1
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
         AND ass.dtadmiss <= pr_dtfimger -- Cooperados admitidos at� a data final
         AND (ass.dtelimin IS NULL OR    -- Cooperados n�o demitidos                       
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
    
    --> Buscar os totais de lan�amento de aplica��es e poupan�a do periodo         
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
              /* Aplica��es RDCPOS, RDCPRE e RDCA */
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
                 AND lap.cdhistor NOT IN (117,125,124) -- Provis�o e Ajuste Provis�o RDCA
                 /* Os hist�ricos de Provis�o e Revers�o de RDC p�s e pr� ser�o considerados no SQL, pois o rendimento dessas aplica��es s�o 
                    creditadas apenas no vencimento ou no resgate. Dessa forma, a aplica��o ficaria estagnada at� esse momento. Al�m disso,
                    no arquivo de saldo, buscamos os dados da CRAPSDA, que considera as provis�es no c�lculo. */
              UNION ALL
              /* Poupan�a programada */
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
              /* Novos produtos de capta��o */
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
                 AND lac.dtmvtolt BETWEEN pr_dtiniger AND pr_dtfimger
                 AND lac.cdhistor NOT IN (cpc.cdhsprap, -- Provis�o
                                          cpc.cdhsrvap) -- Revers�o
              
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
    
    -- Vari�veis para armazenar as informa��es do arquivo
    vr_dsarquiv        CLOB;
    -- Vari�vel para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
        
    -- Totai
    vr_vltotdeb      NUMBER;
    vr_vltotcre      NUMBER;
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na vari�vel CLOB
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
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- C�digo da empresa
                    lpad(pr_cdcooper, 4,' ')              ||     -- Filial
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ Cooperado
                    lpad(to_char(pr_dtultmes,'RRRRMMDD')  ||
                         lpad(pr_nrdconta||vr_tpdconta,10,'0'),18,' ') ||     -- Numero documento
                    to_char(pr_dtultmes,'RRRRMMDD')       ||     -- Data da Opera��o
                    lpad(nvl(pr_tpoperac,0),40,' ')     ||     -- C�digo da opera��o (101-Conta corrente e 199-Aplica��o)
                    lpad(trunc(pr_vloperac*100),'17','0') ||     -- Valor da opera��o 
                    nvl(pr_indebcre,' ')                  ||     -- Sinal da Opera��o 
                    to_char(pr_dtinclus,'YYYYMMDD')       ||     -- Data Inclus�o
                    'N'                                   ||     -- Tipo Movimento (N/E) - Sempre N-Normal
                    lpad(' ',6,' ')                       ||     -- C�digo do dependente 
                    lpad(nvl(to_char(pr_dtdemiss,'RRRRMMDD'),' '),8,' ') ||     -- Data de encerramento da conta
                    lpad(pr_nrdconta||vr_tpdconta,50,' ') ||     -- Numero da conta
                    lpad(nvl(pr_cdagenci,0),10,' ')       ||     -- N�mero da ag�ncia da conta
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
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;
    
    
        
    vr_nmarqimp := 'movi_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da gera��o do arquivo Movimenta��o das Opera��es dos Cooperados,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR')); 
    pc_gera_log_easyway( pr_nmarqlog,'Cooperativa	      Total Cr�dito	      Total D�bito		       Total');   
      
    FOR rw_crapcop IN cr_crapcop LOOP
      -- inicializar totais por cooperativas
      vr_vltotdeb := 0;
      vr_vltotcre := 0;
      
      --> Buscar cooperados
      FOR rw_crapass IN cr_crapass(pr_cdcooper => rw_crapcop.cdcooper,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_dtiniger => pr_dtiniger,
                                   pr_dtfimger => pr_dtfimger) LOOP
                                    
        --> Tratativa para n�o enviar os dados da propria cooperativa                            
        IF rw_crapass.nrcpfcgc = rw_crapcop.nrdocnpj THEN
          continue;
        END IF;
        
        --> Buscar os totais de lan�amento(debito - credito)
        FOR rw_craplcm IN cr_craplcm (pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_dtiniger => pr_dtiniger,
                                      --> At� o fim do periodo ou ate a data de demissao
                                      pr_dtfimger => nvl(rw_crapass.dtelimin, pr_dtfimger)) LOOP
                                       
                                       
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapass.cdcooper,
                                  pr_nrcpfcgc  => rw_crapass.nrcpfcgc,
                                  pr_inpessoa  => rw_crapass.inpessoa,
                                  pr_nrdconta  => rw_crapass.nrdconta,
                                  pr_dtultmes  => last_day(rw_craplcm.dtmesmvt),
                                  pr_tpoperac  => 101, -- 101-Conta corrente
                                  pr_vloperac  => rw_craplcm.vllanmto,
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
        
        --> Buscar os totais de lan�amento de aplica��es e poupan�a do periodo         
        FOR rw_aplicac IN cr_aplicac (pr_cdcooper => rw_crapass.cdcooper,
                                      pr_nrdconta => rw_crapass.nrdconta,
                                      pr_dtiniger => pr_dtiniger,
                                      --> At� o fim do periodo ou ate a data de demissao
                                      pr_dtfimger => nvl(rw_crapass.dtelimin, pr_dtfimger)) LOOP
                                       
                                       
          -- Montar a linha conforme layout easyway
          pc_escreve_linha_layout(pr_cdcooper  => rw_crapass.cdcooper,
                                  pr_nrcpfcgc  => rw_crapass.nrcpfcgc,
                                  pr_inpessoa  => rw_crapass.inpessoa,
                                  pr_nrdconta  => rw_crapass.nrdconta,
                                  pr_dtultmes  => last_day(rw_aplicac.dtmesmvt),
                                  pr_tpoperac  => 199, -- 199-Aplica��o
                                  pr_vloperac  => rw_aplicac.vllanmto,
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
                                       ,pr_flg_impri => 'N'                       --> Chamar a impress�o (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> N�mero de c�pias para impress�o
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviar� o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviar� o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da gera��o do arquivo.');
     
    -- Liberando a mem�ria alocada pro CLOB
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
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar arquivo de movimentacao dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_movimento_ass;
  
  --> Procedimento responsavel em gerar o arquivo com os saldos das opera��es dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_saldo_ope_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
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
    Data     : Abril/2016.                   Ultima atualizacao: 19/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel em gerar arquivo com os saldos das opera��es dos cooperados
    
    Altera��o : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper, 0, cop.cdcooper, pr_cdcooper) 
         AND cop.flgativo = 1
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
             ,sda.vlsddisp
             ,sda.vlsdrdca + sda.vlsdrdpp AS vlsdapli  -- aplica��o + p. programada
        FROM crapsda sda,
             crapass ass
       WHERE sda.cdcooper = pr_cdcooper
         AND ass.cdcooper = pr_cdcooper
         AND ass.cdcooper = sda.cdcooper
         AND ass.nrdconta = sda.nrdconta
         AND sda.nrdconta = decode(pr_nrdconta,0,sda.nrdconta,pr_nrdconta)
         AND sda.dtmvtolt = pr_dtmvtolt
         --> At� o fim do periodo ou ate a data de demissao
         AND ass.dtadmiss <= nvl(ass.dtelimin, pr_dtfimger) -- Cooperados admitidos at� a data final
         AND (ass.dtelimin IS NULL OR    -- Cooperados n�o demitidos                       
              ass.dtelimin >= pr_dtiniger); -- ou demitidos depois da data inicial;
    
            
    -----------> VAIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    -- Vari�veis para armazenar as informa��es do arquivo
    vr_dsarquiv        CLOB;
    -- Vari�vel para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    
    vr_dtmvtolt      DATE;
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na vari�vel CLOB
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
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- C�digo da empresa
                    lpad(pr_cdcooper, 4,' ')              ||     -- Filial
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ Cooperado
                    lpad(' ',4,' ')                       ||     -- C�digo de rendimento
                    lpad(nvl(pr_tpoperac,0),8,' ')        ||     -- C�digo da opera��o (101-Conta corrente e 199-Aplica��o)
                    to_char(pr_dtultmes,'MM/RRRR')        ||     -- Data da Opera��o
                    lpad(trunc(pr_vlsldmes*100),'17',' ') ||     -- Valor do saldo mensal
                    lpad(' ',10,' ')                      ||     -- C�digo dependente da Aplic. Financeira
                    lpad(nvl(pr_cdagenci,0), 8,' ')       ||     -- Ag�ncia da conta
                    lpad(pr_nrdconta||vr_tpdconta,12,' ') ||     -- Numero da conta
                    lpad(nvl(to_char(pr_dtdemiss,'RRRRMMDD'),' '),8,' ') ||     -- Data de encerramento da conta
                    lpad(' ',14,' ')                      ||     -- C�digo do Intermediario
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
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;
                
    vr_nmarqimp := 'saldos_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da gera��o do arquivo de Saldo das Opera��es dos Cooperados,'||
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
                                       
                                       
          --> Tratativa para n�o enviar os dados da propria cooperativa                            
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
                                  pr_tpoperac  => 199, -- 199-Aplica��o
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
                                       ,pr_flg_impri => 'N'                       --> Chamar a impress�o (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> N�mero de c�pias para impress�o
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviar� o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviar� o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da gera��o do arquivo.');
     
    -- Liberando a mem�ria alocada pro CLOB
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
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar arquivo de saldos dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_saldo_ope_ass;
  
  --> Procedimento responsavel em gerar o arquivo dos titulares dos cooperados para a Easyway
  PROCEDURE pc_gera_arq_titulares_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
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
    
    Altera��o : 
        
  ..........................................................................*/
    -----------> CURSORES <-----------     
    --> Buscar cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper,
             cop.nmrescop,
             cop.nrdocnpj
        FROM crapcop cop
       WHERE cop.cdcooper = decode(pr_cdcooper, 0, cop.cdcooper, pr_cdcooper) 
         AND cop.flgativo = 1
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
         AND ass.dtadmiss <= pr_dtfimger -- Cooperados admitidos at� a data final
         AND (ass.dtelimin IS NULL OR    -- Cooperados n�o demitidos                       
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
         AND ass.dtadmiss <= pr_dtfimger    -- Cooperados admitidos at� a data final
         AND (ass.dtelimin IS NULL OR       -- Cooperados n�o demitidos                       
              ass.dtelimin >= pr_dtiniger); -- ou demitidos depois da data inicial;    
                  
    -----------> VAIAVEIS <-----------        

    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(4000);
    vr_cdcritic     NUMBER;
    
    -- Vari�veis para armazenar as informa��es do arquivo
    vr_dsarquiv        CLOB;
    -- Vari�vel para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na vari�vel CLOB
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
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- C�digo da empresa
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ titular
                    lpad(nvl(pr_tiporegi,0),1,' ')        ||     -- Tipo C-Conta Corrente; P-Poupan�a; O-Outros
                    lpad(nvl(pr_cdagenci,0),10,' ')       ||     -- Ag�ncia da conta
                    lpad(pr_nrdconta||vr_tpdconta,40,' ') ||     -- Numero da conta
                    nvl(pr_prititul,' ')                  ||     -- Primeiro Titular
                    lpad(nvl(to_char(pr_inivigen,'RRRRMMDD'),' '),8,' ') ||     -- In�cio Vig�ncia
                    lpad(nvl(to_char(pr_fimvigen,'RRRRMMDD'),' '),8,' ') ||     -- Final Vig�ncia
                    lpad(nvl(pr_tpoperac,0),10,' ')       ||     -- Codigo da opera��o (101-Conta corrente e 199-Aplica��o)
                    'S'                                   ||     -- Gera evento dos demais titulares,  sempre �S�
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
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;
                
    vr_nmarqimp := 'titulares_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da gera��o do arquivo de Cadastro de Titulares da conta,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR')); 
      
    FOR rw_crapcop IN cr_crapcop LOOP  
      --> PESSOA FISICA                                
      --> Buscar saldos dos cooperados
      FOR rw_crapttl IN cr_crapttl (pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_dtiniger => pr_dtiniger,
                                    pr_dtfimger => pr_dtfimger) LOOP
                                       
        --> Tratativa para n�o enviar os dados da propria cooperativa                            
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
                                pr_tpoperac => 101, -- 101 � Conta Corrente
                                pr_prititul => rw_crapttl.prititul,
                                ----- OUT ----
                                pr_dscritic => vr_dscritic);
                                  
        -- Verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
        
        --> Verificar se cooperado possui aplica��es
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
                                  pr_tpoperac  => 199, -- 199-Aplica��o
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
                                       
                                       
        -- Montar a linha conforme layout easyway
        pc_escreve_linha_layout(pr_cdcooper => rw_crapass.cdcooper,
                                pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                pr_inpessoa => rw_crapass.inpessoa,
                                pr_cdagenci => rw_crapass.cdagenci,
                                pr_nrdconta => rw_crapass.nrdconta,
                                pr_tiporegi => 'C', -- C-Conta Corrente 
                                pr_inivigen => rw_crapass.dtadmiss,
                                pr_fimvigen => rw_crapass.dtelimin,
                                pr_tpoperac => 101, -- 101 � Conta Corrente
                                pr_prititul => rw_crapass.prititul,
                                ----- OUT ----
                                pr_dscritic => vr_dscritic);
                                  
        -- Verificar se retornou critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF; 
        
        --> Verificar se cooperado possui aplica��es
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
                                  pr_tpoperac  => 199, -- 199-Aplica��o
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
                                       ,pr_flg_impri => 'N'                       --> Chamar a impress�o (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> N�mero de c�pias para impress�o
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviar� o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviar� o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da gera��o do arquivo.');
     
    -- Liberando a mem�ria alocada pro CLOB
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
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar arquivo de titulares dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_titulares_ass;
  
  --> Procedimento responsavel em gerar o arquivo com os terceiros vinculados ao cooperados para a Easyway
  PROCEDURE pc_gera_arq_terceiros_ass (pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                       pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                       pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                       pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
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
                
    Altera��o : Ajustado para que na gera��o dos procuradores e responsaveis de menores o sistema ignore
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
         AND cop.flgativo = 1
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
         AND ass.dtadmiss <= pr_dtfimger -- Cooperados admitidos at� a data final
         AND (ass.dtelimin IS NULL OR -- Cooperados n�o demitidos                       
             ass.dtelimin >= pr_dtiniger) -- ou demitidos depois da data inicial
       ORDER BY ass.cdcooper
               ,ass.nrdconta;
                        
    --> Pessoa F�sica
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
            /* Se a vig�ncia for posterior a data final do periodo, 
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
         /* Nao exportar repetir se o CPF j� conter como rep. legal */
         AND NOT EXISTS (SELECT 1
                           FROM crapcrl crl,
                                crapass ass
                          WHERE crl.cdcooper = ass.cdcooper
                            AND crl.nrdconta = ass.nrdconta
                            AND crl.cdcooper = avt.cdcooper
                            AND crl.nrctamen = avt.nrdconta
                            AND nvl(ass.nrcpfcgc,crl.nrcpfcgc) = avt.nrcpfcgc);
    
    --> Pessoa juridica
    CURSOR cr_crapavt (pr_cdcooper crapcop.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      
      SELECT avt.nrcpfcgc
            ,avt.inpessoa
            ,nvl(avt.dtmvtolt, ass.dtadmiss) AS dtadmiss
            /* Se a vig�ncia for posterior a data final do periodo, 
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
    
    -- Vari�veis para armazenar as informa��es do arquivo
    vr_dsarquiv        CLOB;
    -- Vari�vel para armazenar os dados do arquivo antes de incluir no CLOB
    vr_texto_completo  VARCHAR2(32600);
    -- diretorio de geracao do relatorio
    vr_dsdireto      VARCHAR2(100);
    -- Nome do arquivo
    vr_nmarqimp      VARCHAR2(100);
    
    -----------> SUBROTINAS <-----------        
    -- Subrotina para escrever texto na vari�vel CLOB
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
      vr_dslinha := lpad(pr_cdcooper, 5,' ')              ||     -- C�digo da empresa
                    fn_nrcpfcgc_easy(pr_nrcpfcgc,
                                     pr_inpessoa)         ||     -- CPF/CNPJ titular
                    lpad(nvl(pr_tiporegi,' '),1,' ')      ||     -- Tipo C-Conta Corrente; P-Poupan�a; O-Outros                    
                    lpad(nvl(pr_cdagenci,0),10,' ')       ||     -- Ag�ncia da conta
                    lpad(pr_nrdconta||vr_tpdconta,40,' ') ||     -- Numero da conta
                    lpad(nvl(to_char(pr_inivigen,'RRRRMMDD'),' '),8,' ') ||     -- In�cio Vig�ncia
                    lpad(nvl(to_char(pr_inivigen,'RRRRMMDD'),' '),8,' ') ||     -- In�cio Vig�ncia
                    lpad(nvl(to_char(pr_fimvigen,'RRRRMMDD'),' '),8,' ') ||     -- Final Vig�ncia
                    nvl(pr_tiprelac,' ')                  ||     -- Tipo de Rela��o Declarado
                    fn_nrcpfcgc_easy(pr_nrcpfcgc_ter,
                                     pr_inpessoa_ter)     ||     -- CPF/CNPJ do Procurador, Representante Legal, Intermedi�rio ou Benefici�rio Final
                    'S'                                   ||     -- Gera Evento para Terceiro -S-Sim; N-N�o (Gerar todos como �S�)
                    'D'                                   ||     -- Considera Endere�o do Titular - D-Declarado; T-Terceiro  (Gerar todos como �D�)
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
    -- Inicilizar as informa��es do XML
    vr_texto_completo := NULL;
                
    vr_nmarqimp := 'terceiros_'||pr_dssufarq||'.txt';    
    
    pc_gera_log_easyway( pr_nmarqlog,'Inicio da gera��o do arquivo de Cadastro Terceiros Vinculados a Conta,'||
                         ' arquivo: '||vr_nmarqimp); 
    pc_gera_log_easyway( pr_nmarqlog,'Periodo de '|| to_char(pr_dtiniger,'DD/MM/RRRR') ||' ate '|| to_char(pr_dtfimger,'DD/MM/RRRR')); 
      
    FOR rw_crapcop IN cr_crapcop LOOP  
                                      
      --> Buscar cooperados
      FOR rw_crapass IN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_dtiniger => pr_dtiniger,
                                    pr_dtfimger => pr_dtfimger) LOOP
                                       
                                       
        --> Tratativa para n�o enviar os dados da propria cooperativa                            
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
                                       ,pr_flg_impri => 'N'                       --> Chamar a impress�o (Imprim.p)
                                       ,pr_flg_gerar => 'S'                       --> Gerar o arquivo na hora
                                       ,pr_flgremarq => 'N'                       --> remover arquivo apos geracao
                                       ,pr_nrcopias  => 1                         --> N�mero de c�pias para impress�o
                                       ,pr_dspathcop => NULL                      --> Lista sep. por ';' de diret�rios a copiar o arquivo
                                       ,pr_dsmailcop => NULL                      --> Lista sep. por ';' de emails para envio do arquivo
                                       ,pr_dsassmail => NULL                      --> Assunto do e-mail que enviar� o arquivo
                                       ,pr_dscormail => NULL                      --> HTML corpo do email que enviar� o arquivo
                                       ,pr_fldosmail => 'S'                       --> Flag para converter o arquivo gerado em DOS antes do e-mail
                                       ,pr_flappend  => 'S'
                                       ,pr_des_erro  => vr_dscritic);             --> Retorno de Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    pc_gera_log_easyway( pr_nmarqlog,'Final da gera��o do arquivo.');
     
    -- Liberando a mem�ria alocada pro CLOB
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
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar arquivo de terceiros dos cooperados: '||SQLERRM;
      pc_gera_log_easyway( pr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||pr_dscritic);
  END pc_gera_arq_terceiros_ass;
  
  
  --> Procedimento para chamar rotina pelo ayllosweb
  PROCEDURE pc_trata_param_TELA_INTEAS (pr_tlcdcoop  IN crapcop.cdcooper%TYPE,  --> codigo da cooperativa informado na tela 
                                        pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                        pr_dtiniger  IN VARCHAR2,               --> Data In�cio do per�odo de gera��o 
                                        pr_dtfimger  IN VARCHAR2,               --> Data Final  do per�odo de gera��o
                                        pr_dtmvtolt  IN VARCHAR2,               --> Data do movimento
                                        pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado � 0 para todos os arquivos 
                                        pr_xmllog    IN VARCHAR2,               --> XML com informa��es de LOG
                                        ---- OUT ----                                                                                                                         
                                        pr_cdcritic OUT PLS_INTEGER,            --> C�digo da cr�tica
                                        pr_dscritic OUT VARCHAR2,               --> Descri��o da cr�tica
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
    
    Altera��o : 
        
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
        pr_dscritic := 'Data informanda n�o � valida.';
        RAISE vr_exc_erro;
    END;
    
    pc_gera_arquivos_integracao ( pr_cdcooper  => pr_tlcdcoop,  --> Codigo da cooperativa                                        
                                  pr_nrdconta  => pr_nrdconta,  --> Numero da conta do cooperado
                                  pr_dtiniger  => vr_dtiniger,  --> Data In�cio do per�odo de gera��o 
                                  pr_dtfimger  => vr_dtfimger,  --> Data Final  do per�odo de gera��o
                                  pr_dtmvtolt  => vr_dtmvtolt,  --> Data do movimento
                                  pr_inarquiv  => pr_inarquiv,  --> Arquivo a ser exportado � 0 para todos os arquivos                                           
                                  ---- OUT ----                                                                                                                         
                                  pr_nmarqlog => vr_nmarqlog,   --> nome do arquivo de log
                                  pr_cdcritic => pr_cdcritic,   --> C�digo da cr�tica
                                  pr_dscritic => pr_dscritic);  --> Descri��o da cr�tica
  
    IF nvl(pr_cdcritic,0) > 0 OR
       TRIM(pr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;  
    
    -- Criar cabe�alho do XML
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
      -- Se foi retornado apenas c�digo
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
        -- Buscar a descri��o
        pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      END IF;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao gerar arquivo: ' || SQLERRM;

      -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
      -- Existe para satisfazer exig�ncia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      ROLLBACK;
  END pc_trata_param_TELA_INTEAS;
  
  --> Procedimento responsavel por disparar a gera��o dos arquivos de integra��o Easyway
  PROCEDURE pc_gera_arquivos_integracao ( pr_cdcooper  IN crapass.cdcooper%TYPE,  --> Codigo da cooperativa                                        
                                          pr_nrdconta  IN crapass.nrdconta%TYPE,  --> Numero da conta do cooperado
                                          pr_dtiniger  IN DATE,                   --> Data In�cio do per�odo de gera��o 
                                          pr_dtfimger  IN DATE,                   --> Data Final  do per�odo de gera��o
                                          pr_dtmvtolt  IN DATE,                   --> Data do movimento
                                          pr_inarquiv  IN NUMBER,                 --> Arquivo a ser exportado � 0 para todos os arquivos                                           
                                          ---- OUT ----                                                                                                                         
                                          pr_nmarqlog OUT VARCHAR2,                --> nome do arquivo de log
                                          pr_cdcritic OUT PLS_INTEGER,            --> C�digo da cr�tica
                                          pr_dscritic OUT VARCHAR2                --> Descri��o da cr�tica
                                          ) IS
  /* ..........................................................................
    
    Programa : pc_gera_arquivos_integracao        
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Odirlei Busana(Amcom)
    Data     : Abril/2016.                   Ultima atualizacao: 13/04/2016
    
    Dados referentes ao programa:
    
    Frequencia: Sempre que for chamado
    Objetivo  : Procedimento responsavel por disparar a gera��o dos arquivos de integra��o Easyway

                pr_inarquiv 
                [1 � Cadastro de Cooperados]
                [2 � Cadastro de Opera��es de Cooperados]
                [3 � Saldo das Opera��es dos Cooperados]
                [5 � Movimenta��o das Opera��es dos Cooperados]
    Altera��o : 
        
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
                'Preparando gera��o '||
                (CASE pr_inarquiv 
                   WHEN 0 THEN 'de todos os arquivos.'
                   WHEN 1 THEN 'do arquivo de Cadastro de Cooperados.' 
                   WHEN 2 THEN 'do arquivo de Cadastro de Titulares da conta.' 
                   WHEN 3 THEN 'do arquivo de Cadastro Terceiros Vinculados a Conta.' 
                   WHEN 4 THEN 'do arquivo de Saldo das Opera��es dos Cooperados.' 
                   WHEN 5 THEN 'do arquivo de Movimenta��o das Opera��es dos Cooperados.' 
                   ELSE NULL
                  END));
    
    IF pr_dtfimger > trunc(pr_dtmvtolt,'MM') THEN
      vr_dscritic := 'Periodo invalido, data final deve ser menor que o m�s corrente('||to_char(pr_dtmvtolt,'MM/RRRR') ||').';
      RAISE vr_exc_erro;
    END IF;
    
    -- Definir sufixo do nome dos arquivos para facilitar identificacao dos arquivos
    -- pois pode levar certo tempo para a sua geracao
    vr_dssufarq := to_char(systimestamp,'RRRRMMDDHH24MISSFF3');
    
    -- Definir os parametros das rotinas visto que para todas s�o iguais
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
    
    -- Arquivo Saldo das Opera��es dos Cooperados
    IF pr_inarquiv = 4 OR pr_inarquiv = 0 THEN
      --> Procedimento responsavel em gerar o arquivo de Cadastro de Cooperados para a Easyway                          
      vr_dsplsql := vr_dsplsql||' CECRED.TELA_INTEAS.pc_gera_arq_saldo_ope_ass '   ||chr(13)||
                                vr_dsparame ||chr(13);                          
    END IF;
    
    -- Arquivo Movimenta��o das Opera��es dos Cooperados
    IF pr_inarquiv = 5 OR pr_inarquiv = 0 THEN
      --> Procedimento responsavel em gerar o arquivo de movimenta��o das opera��es dos cooperados para a Easyway    
      vr_dsplsql := vr_dsplsql||' CECRED.TELA_INTEAS.pc_gera_arq_movimento_ass '   ||chr(13)||
                                vr_dsparame ||chr(13);   
    END IF;
    
    -- concluir chamada  dos programas
    vr_dsplsql      := vr_dsplsql ||'CECRED.TELA_INTEAS.pc_gera_log_easyway( '''||vr_nmarqlog||''',''Final da execu��o.'');'||chr(13)
                       ||' EXCEPTION WHEN OTHERS THEN '||chr(13)
                       ||'CECRED.TELA_INTEAS.pc_gera_log_easyway( '''||vr_nmarqlog||''',''Erro:''||sqlerrm);'||chr(13)
                       ||' END; ';
    
    -- Montar o prefixo do c�digo do programa para o jobname
    vr_jobname := 'INTEAS$';
    -- Faz a chamada ao programa paralelo atraves de JOB
    GENE0001.pc_submit_job(pr_cdcooper  => 3            --> C�digo da cooperativa
                          ,pr_cdprogra  => 'INTEAS'     --> C�digo do programa
                          ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                          ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                          ,pr_interva   => NULL         --> Sem intervalo de execu��o da fila, ou seja, apenas 1 vez
                          ,pr_jobname   => vr_jobname   --> Nome randomico criado
                          ,pr_des_erro  => pr_dscritic);
    -- Testar saida com erro
    IF pr_dscritic IS NOT NULL THEN
      -- Levantar exce�ao
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
      pc_gera_log_easyway( vr_nmarqlog,'N�o foi possivel concluir gera��o do arquivo, erro: '||vr_dscritic);
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_dscritic := 'N�o foi possivel gerar arquivos: '||SQLERRM;
      pc_gera_log_easyway( vr_nmarqlog,pr_dscritic);
  END pc_gera_arquivos_integracao;
      
  
    
END TELA_INTEAS;
/
