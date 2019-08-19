PL/SQL Developer Test script 3.0
776
-- Created on 17/05/2017 by F0030344 
DECLARE 
  
  -- Variáveis para armazenar as informações em XML
  vr_des_xml       CLOB;
  vr_des_txt       VARCHAR2(32700);
  -- Variável para o caminho e nome do arquivo base
  vr_nom_diretorio VARCHAR2(200);
  vr_nom_arquivo   VARCHAR2(200);
  vr_nrcopias      NUMBER(1) := 1;
  -- PL/Table para armazenar o resumo
  TYPE typ_arquivo IS RECORD (tpdlinha  NUMBER(1),
                              dsdlinha  VARCHAR2(1000));
  TYPE typ_tab_arquivo IS TABLE OF typ_arquivo INDEX BY BINARY_INTEGER;
  vr_arquivo       typ_tab_arquivo;
  vr_ind_arquivo   BINARY_INTEGER;
  
  -- PL/Table para armazenar os dados do seguro
  type typ_cratseg is record (tpregist  number(1),
                              nrdconta  crapass.nrdconta%type,
                              nrctrseg  crapseg.cdsegura%type,
                              tpplaseg  crapseg.tpplaseg%type,
                              cdagenci  crapass.cdagenci%type,
                              nmprimtl  crapass.nmprimtl%type,
                              vlpreseg  crapseg.vlpreseg%type,
                              cdsegura  crapseg.cdsegura%type,
                              dtinivig  crapseg.dtinivig%type,
                              dtfimvig  crapseg.dtfimvig%type,
                              dtcancel  crapseg.dtcancel%type,
                              nrcpfcgc  crapass.nrcpfcgc%type,
                              nrdocptl  crapass.nrdocptl%type,
                              cdoedptl  crapass.cdoedptl%type,
                              dtemdptl  crapass.dtemdptl%type,
                              dtnasctl  crapass.dtnasctl%type,
                              dsendres  crawseg.dsendres%type,
                              nmbairro  crawseg.nmbairro%type,
                              nmcidade  varchar2(50), --crawseg.nmcidade%type, RENATO: Erro...
                              nrcepend  crawseg.nrcepend%type,
                              cdageseg  crapseg.cdagenci%type,
                              cdmotcan  crapseg.cdmotcan%type,
                              flgclabe  crapseg.flgclabe%type,
                              nmbenvid  crapseg.nmbenvid##1%type,
                              tpendcor  crapseg.tpendcor%type,
                              complend  crawseg.complend%type,
                              nrendres  crawseg.nrendres%type,
                              inpessoa  crapass.inpessoa%TYPE,
                              dtprideb  crapseg.dtprideb%TYPE,
                              dtdebito  crapseg.dtdebito%TYPE);
  
  TYPE typ_tab_cratseg IS TABLE OF typ_cratseg INDEX BY VARCHAR2(54);
  vr_cratseg       typ_tab_cratseg;
  -- O índice da pl/table é formado pelos campos cdsegura, dtinivig, tpregist, cdagenci, nrdconta e nrctrseg, garantindo a ordenação do relatório
  vr_ind_cratseg   VARCHAR2(54);
  
  -- Variáveis para processamento do resumo
  vr_nrcpfcgc      VARCHAR2(11);
  vr_nrdocptl      VARCHAR2(12);
  vr_dtemdptl      VARCHAR2(8);
  vr_cdoedptl      VARCHAR2(6);
  vr_cdufresd      VARCHAR2(2);
  vr_tpmovmto      NUMBER(1);
  vr_cdmovmto      VARCHAR2(1);
  vr_dtcancel      VARCHAR2(8);
  vr_nrtelefo      VARCHAR2(28);
  vr_dsdemail      crapcem.dsdemail%TYPE;
  vr_flgclabe      VARCHAR2(1);

  vr_nrcepend      crawseg.nrcepend%TYPE;
  vr_complend      crawseg.complend%TYPE;
  vr_nrendres      crawseg.nrendres%TYPE;

  -- Variáveis para auxiliar a manipulação da pl/table
  vr_cdsegura      crapseg.cdsegura%TYPE;
  vr_dtinivig      crapseg.dtinivig%TYPE;
  vr_tpregist      NUMBER(1);
  vr_dsendres      crawseg.dsendres%TYPE;
  vr_nmbairro      crawseg.nmbairro%TYPE;
  vr_nmcidade      crawseg.nmcidade%TYPE;
  vr_dscidduf      VARCHAR2(50); -- descrição da cidade / UF

  -- Variáveis auxiliares para o arquivo texto
  vr_nrsequen      number(5);
  vr_nmcidaux      varchar2(20);
  vr_sigestad      varchar2(2);

  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%TYPE := 'CRPS439';
  -- Data do movimento
  vr_dtmvtolt      crapdat.dtmvtolt%type;

  -- Tratamento de erros
  vr_exc_saida     exception;
  vr_exc_fimprg    exception;
  vr_cdcritic      pls_integer;
  vr_dscritic      varchar2(4000);

  vr_contareg      NUMBER(5);

  -- ##CURSORES##

  -- Buscar cooperativas
  CURSOR cr_crapcop IS
    SELECT *
      FROM crapcop 
     WHERE crapcop.flgativo = 1
       AND crapcop.cdcooper <> 3;

  -- Buscar informações de seguros
  CURSOR cr_crapseg2 (pr_cdcooper IN crapseg.cdcooper%TYPE) IS
    SELECT crapseg.rowid,
           crapseg.cdcooper,
           crapseg.nrdconta,
           crapseg.cdsegura,
           crapseg.dtcancel,
           crapseg.nrctrseg,
           crapseg.tpplaseg,
           crapseg.cdsitseg,
           crapseg.vlpreseg,
           crapseg.tpseguro,
           crapseg.dtinivig,
           crapseg.dtfimvig,
           crapseg.cdagenci,
           crapseg.cdmotcan,
           crapseg.flgclabe,
           crapseg.nmbenvid##1,
           crapseg.tpendcor,
           crapseg.dtprideb,
           crapseg.dtdebito
      FROM crapseg
     WHERE crapseg.cdcooper = pr_cdcooper
       AND NVL(crapseg.dtmvtolt, to_date('31122999','ddmmyyyy')) <> nvl(crapseg.dtcancel, to_date('31122999','ddmmyyyy'))
       AND  (crapseg.cdsitseg IN (1,3)
         OR  (crapseg.cdsitseg = 2 
          AND crapseg.dtcancel > TO_DATE('31/05/2017','DD/MM/RRRR')))
       AND crapseg.dtfimvig > TO_DATE('31/05/2017','DD/MM/RRRR')
       AND crapseg.tpseguro = 11
     AND crapseg.dtmvtolt < TO_DATE('01/06/2017','DD/MM/RRRR');

  CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                   ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT *
      FROM crapass
     WHERE crapass.cdcooper = pr_cdcooper
       AND crapass.nrdconta = pr_nrdconta;
       
  rw_crapass cr_crapass%ROWTYPE;

  -- Cadastro do titular da conta
  CURSOR cr_crapttl (pr_cdcooper in crapttl.cdcooper%type,
                     pr_nrdconta in crapttl.nrdconta%type) IS 
    SELECT crapttl.nrdocttl
      FROM crapttl
     WHERE crapttl.cdcooper = pr_cdcooper
       AND crapttl.nrdconta = pr_nrdconta
       AND crapttl.idseqttl = 1
       AND crapttl.tpdocttl = 'CI';
       
  rw_crapttl     cr_crapttl%ROWTYPE;
  
  -- Buscar informações de seguros
  CURSOR cr_crawseg (pr_cdcooper IN crawseg.cdcooper%TYPE,
                     pr_cdsegura IN crawseg.cdsegura%TYPE,
                     pr_nrdconta IN crawseg.nrdconta%TYPE,
                     pr_nrctrseg IN crawseg.nrctrseg%TYPE) IS 
    SELECT crawseg.rowid,
           crawseg.vlpreseg,
           crawseg.dsendres,
           crawseg.nrendres,
           crawseg.nmbairro,
           crawseg.nmcidade,
           crawseg.nrcepend,
           crawseg.complend,
           crawseg.cdufresd
      FROM crawseg
     WHERE crawseg.cdcooper = pr_cdcooper
       AND crawseg.cdsegura = pr_cdsegura
       AND crawseg.nrdconta = pr_nrdconta
       AND crawseg.nrctrseg = pr_nrctrseg;
       
  rw_crawseg     cr_crawseg%ROWTYPE;

  -- Buscar informações da seguradora
  CURSOR cr_crapcsg (pr_cdcooper IN crapcsg.cdcooper%TYPE,
                     pr_cdsegura IN crapcsg.cdsegura%TYPE) IS 
    SELECT crapcsg.cdhstcas##2,
           crapcsg.nmsegura
      FROM crapcsg
     WHERE crapcsg.cdcooper = pr_cdcooper
       AND crapcsg.cdsegura = pr_cdsegura;
       
  rw_crapcsg     cr_crapcsg%ROWTYPE;

  -- Buscar o telefone fixo ou celular
  CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE,
                     pr_nrdconta IN craptfc.nrdconta%TYPE) IS 
    SELECT craptfc.nrtelefo
      FROM craptfc
     WHERE craptfc.cdcooper = pr_cdcooper
       AND craptfc.nrdconta = pr_nrdconta
       AND craptfc.tptelefo IN (1,2)
     ORDER BY craptfc.progress_recid;
     
  rw_craptfc     cr_craptfc%ROWTYPE;

  -- Buscar o e-mail do titular
  CURSOR cr_crapcem (pr_cdcooper IN crapcem.cdcooper%TYPE,
                     pr_nrdconta IN crapcem.nrdconta%TYPE) IS 
    SELECT crapcem.dsdemail
      FROM crapcem
     WHERE crapcem.cdcooper = pr_cdcooper
       AND crapcem.nrdconta = pr_nrdconta
       AND crapcem.idseqttl = 1
     ORDER BY crapcem.progress_recid;
     
  rw_crapcem     cr_crapcem%ROWTYPE;
  
  -- Buscar o endereço de correspondência
  CURSOR cr_crapenc (pr_cdcooper IN crapenc.cdcooper%TYPE,
                     pr_nrdconta IN crapenc.nrdconta%TYPE,
                     pr_tpendass IN crapenc.tpendass%TYPE) IS 
    SELECT crapenc.nrcepend,
           crapenc.nmcidade,
           crapenc.nmbairro,
           crapenc.cdufende,
           crapenc.dsendere,
           crapenc.complend,
           crapenc.nrendere
      FROM crapenc
     WHERE crapenc.cdcooper = pr_cdcooper
       AND crapenc.nrdconta = pr_nrdconta
       AND crapenc.tpendass = pr_tpendass;
       
  rw_crapenc     cr_crapenc%ROWTYPE;

  
  rw_craptab     btch0001.cr_craptab%rowtype;
  rw_crapdat     btch0001.cr_crapdat%rowtype;

BEGIN 
  --INICIO DO PROGRAMA
  
  -- Inicialização do contador de registros do arquivo TXT
  vr_contareg := 0;
  
  FOR rw_crapcop IN cr_crapcop LOOP
  
    -- Buscar a data do movimento
    OPEN btch0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Verificar se existe informação, e gerar erro caso não exista
    IF btch0001.cr_crapdat%NOTFOUND THEN 
      -- Fechar o cursor
      CLOSE btch0001.cr_crapdat;
      -- Gerar exceção
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      RAISE vr_exc_saida;
    END IF;
    
    CLOSE btch0001.cr_crapdat;
    vr_dtmvtolt := rw_crapdat.dtmvtolt;  
    
    vr_cratseg.DELETE;
    vr_arquivo.DELETE;
    
    FOR rw_crapseg2 IN cr_crapseg2 (pr_cdcooper => rw_crapcop.cdcooper) LOOP
    
      -- Busca informações do associado
      OPEN cr_crapass (pr_cdcooper => rw_crapcop.cdcooper,
                       pr_nrdconta => rw_crapseg2.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN 
        -- Fecha o cursor, gera mensagem de erro no log e passa ao próximo registro do loop
        CLOSE cr_crapass;
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||' Conta: '||gene0002.fn_mask(rw_crapseg2.nrdconta, 'zzzz,zzz,9');
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper,
                                   pr_ind_tipo_log => 2, -- Erro tratato
                                   pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                   || vr_cdprogra || ' --> '
                                                   || vr_dscritic );
        CONTINUE;
      END IF;
      
      CLOSE cr_crapass;
      
      -- Se for pessoa física, busca o número da carteira de identidade
      rw_crapttl.nrdocttl := rpad(' ',12,' ');
      IF rw_crapass.inpessoa = 1 THEN 
        OPEN cr_crapttl (pr_cdcooper => rw_crapcop.cdcooper,
                         pr_nrdconta => rw_crapseg2.nrdconta);
        FETCH cr_crapttl INTO rw_crapttl;
        CLOSE cr_crapttl;
      END IF;
      
      -- Inicializa variáveis
      vr_tpregist := 0;
      vr_dsendres := ' ';
      vr_nmbairro := ' ';
      vr_dscidduf := ' ';
      vr_nrcepend := 0;
      vr_complend := ' ';
      vr_nrendres := 0;

      OPEN cr_crawseg(pr_cdcooper => rw_crapseg2.cdcooper,
                      pr_cdsegura => rw_crapseg2.cdsegura,
                      pr_nrdconta => rw_crapseg2.nrdconta,
                      pr_nrctrseg =>rw_crapseg2.nrctrseg);
      FETCH cr_crawseg INTO rw_crawseg;
      
      IF cr_crawseg%FOUND THEN 
        
        CLOSE cr_crawseg;
        
        IF rw_crapseg2.dtcancel = vr_dtmvtolt THEN 
          vr_tpregist := 3; -- Cancelado
        ELSIF rw_crapseg2.cdsitseg = 1 THEN 
          vr_tpregist := 1; -- Inclusao
        ELSIF rw_crapseg2.cdsitseg = 3 THEN 
          vr_tpregist := 2; -- Renovado
        END IF;
        
        -- Verifica se existe endereço, e inclui os campos na pl/table
        IF TRIM(rw_crawseg.dsendres) IS NOT NULL THEN
          vr_dsendres := TRIM(rw_crawseg.dsendres);
          vr_nmbairro := rw_crawseg.nmbairro;
          vr_dscidduf := TRIM(rw_crawseg.nmcidade) || '/' || rw_crawseg.cdufresd;
          vr_nrcepend := rw_crawseg.nrcepend;
          vr_complend := rw_crawseg.complend;
          vr_nrendres := TRIM(to_char(rw_crawseg.nrendres));
        END IF;
        
      ELSE
        CLOSE cr_crawseg;  
      END IF;
    
      -- Cria registro na pl/table
      -- O índice vai garantir a ordenação do relatório
      vr_ind_cratseg := to_char(rw_crapseg2.cdsegura, 'fm0000000000')||
                        to_char(rw_crapseg2.dtinivig, 'yyyymmdd')||
                        to_char(vr_tpregist, 'fm0')||
                        to_char(rw_crapseg2.cdagenci, 'fm00000')||
                        to_char(rw_crapseg2.nrdconta, 'fm0000000000')||
                        to_char(rw_crapseg2.nrctrseg, 'fm0000000000')||
                        lpad(cr_crapseg2%rowcount,10,'0');
      --
      vr_cratseg(vr_ind_cratseg).nrdconta := rw_crapseg2.nrdconta;
      vr_cratseg(vr_ind_cratseg).cdsegura := rw_crapseg2.cdsegura;
      vr_cratseg(vr_ind_cratseg).tpplaseg := rw_crapseg2.tpplaseg;
      vr_cratseg(vr_ind_cratseg).cdagenci := rw_crapass.cdagenci;
      vr_cratseg(vr_ind_cratseg).nmprimtl := rw_crapass.nmprimtl;
      vr_cratseg(vr_ind_cratseg).nrctrseg := rw_crapseg2.nrctrseg;
      vr_cratseg(vr_ind_cratseg).vlpreseg := rw_crapseg2.vlpreseg;
      vr_cratseg(vr_ind_cratseg).dtinivig := rw_crapseg2.dtinivig;
      vr_cratseg(vr_ind_cratseg).dtfimvig := rw_crapseg2.dtfimvig;
      vr_cratseg(vr_ind_cratseg).dtcancel := rw_crapseg2.dtcancel;
      vr_cratseg(vr_ind_cratseg).nrcpfcgc := rw_crapass.nrcpfcgc;
      vr_cratseg(vr_ind_cratseg).nrdocptl := rw_crapttl.nrdocttl;
      vr_cratseg(vr_ind_cratseg).cdoedptl := rw_crapass.cdoedptl;
      vr_cratseg(vr_ind_cratseg).dtemdptl := rw_crapass.dtemdptl;
      vr_cratseg(vr_ind_cratseg).dtnasctl := rw_crapass.dtnasctl;
      vr_cratseg(vr_ind_cratseg).cdageseg := rw_crapseg2.cdagenci;
      vr_cratseg(vr_ind_cratseg).cdmotcan := rw_crapseg2.cdmotcan;
      vr_cratseg(vr_ind_cratseg).flgclabe := rw_crapseg2.flgclabe;
      vr_cratseg(vr_ind_cratseg).nmbenvid := rw_crapseg2.nmbenvid##1;
      vr_cratseg(vr_ind_cratseg).tpendcor := rw_crapseg2.tpendcor;
      vr_cratseg(vr_ind_cratseg).tpregist := vr_tpregist;
      vr_cratseg(vr_ind_cratseg).dsendres := vr_dsendres;
      vr_cratseg(vr_ind_cratseg).nmbairro := vr_nmbairro;
      vr_cratseg(vr_ind_cratseg).nmcidade := vr_dscidduf;
      vr_cratseg(vr_ind_cratseg).nrcepend := vr_nrcepend;
      vr_cratseg(vr_ind_cratseg).complend := vr_complend;
      vr_cratseg(vr_ind_cratseg).nrendres := vr_nrendres;
      vr_cratseg(vr_ind_cratseg).inpessoa := rw_crapass.inpessoa;
      vr_cratseg(vr_ind_cratseg).dtprideb := rw_crapseg2.dtprideb;
      vr_cratseg(vr_ind_cratseg).dtdebito := rw_crapseg2.dtdebito;
    
    END LOOP; -- Loop crapseg
  
    -- Busca parâmetro do seguro
    rw_craptab.dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
                                                    ,pr_nmsistem => 'CRED'
                                                    ,pr_tptabela => 'USUARI'
                                                    ,pr_cdempres => 11
                                                    ,pr_cdacesso => 'SEGPRESTAM'
                                                    ,pr_tpregist => 0);
  
    -- INICIO DA IMPRESSAO DO RELATORIO
    -- Busca do diretório base da cooperativa
    vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                              pr_cdcooper => rw_crapcop.cdcooper,
                                              pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  

    -- Geração do XML para o crrl416.lst
    -- Inicializar o CLOB
    vr_des_xml := null;
    -- Inicialização das variáveis de controle de quebra
    vr_cdsegura := 0;
    vr_dtinivig := to_date('01011901','ddmmyyyy');
    vr_tpregist := 0;
    -- Inicialização do contador de registros do arquivo TXT
    vr_contareg := 0;
    -- Leitura da PL/Table e geração do arquivo XML
    vr_ind_cratseg := vr_cratseg.first;


--##########################################################################################
    WHILE vr_ind_cratseg IS NOT NULL LOOP 
      
      -- Verifica se mudou a seguradora para incluir a quebra
      IF vr_cratseg(vr_ind_cratseg).cdsegura <> vr_cdsegura THEN 
        
        -- Busca o nome da seguradora. Se não encontrar, gera erro e descarta o registro.
        OPEN cr_crapcsg (pr_cdcooper => rw_crapcop.cdcooper,
                         pr_cdsegura => vr_cratseg(vr_ind_cratseg).cdsegura);
        FETCH cr_crapcsg INTO rw_crapcsg;
        
        IF cr_crapcsg%NOTFOUND THEN
            -- Fecha o cursor, gera mensagem de erro no log e passa ao próximo registro do loop
            CLOSE cr_crapcsg;
            vr_cdcritic := 556; -- Plano Inexistente
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
            -- Envio centralizado de log de erro
            btch0001.pc_gera_log_batch(pr_cdcooper     => rw_crapcop.cdcooper,
                                       pr_ind_tipo_log => 2, -- Erro tratato
                                       pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
            CONTINUE;
        END IF;
        
        CLOSE cr_crapcsg;
        
        -- Atualiza variáveis de controle de quebra
        vr_cdsegura := vr_cratseg(vr_ind_cratseg).cdsegura;
        vr_dtinivig := vr_cratseg(vr_ind_cratseg).dtinivig;
        vr_tpregist := vr_cratseg(vr_ind_cratseg).tpregist;
      ELSE 
        
        -- Verifica se mudou a data ou o tipo para incluir a quebra
        IF vr_cratseg(vr_ind_cratseg).dtinivig <> vr_dtinivig OR 
           vr_cratseg(vr_ind_cratseg).tpregist <> vr_tpregist THEN 
           -- Atualiza variáveis de controle de quebra
           vr_dtinivig := vr_cratseg(vr_ind_cratseg).dtinivig;
           vr_tpregist := vr_cratseg(vr_ind_cratseg).tpregist;
        END IF;
        
      END IF;
      
      -- Geração de informações para o resumo
      IF substr(rw_craptab.dstextab, 85, 2) <> ' ' THEN
         
        -- Se for pessoa física, busca o número da carteira de identidade
        IF vr_cratseg(vr_ind_cratseg).inpessoa = 1 THEN 
          
          vr_nrcpfcgc := gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrcpfcgc,'99999999999');
          vr_nrdocptl := rpad(vr_cratseg(vr_ind_cratseg).nrdocptl, 12, ' ');
          vr_dtemdptl := to_char(vr_cratseg(vr_ind_cratseg).dtemdptl,'ddmmyyyy');
          vr_cdoedptl := rpad(vr_cratseg(vr_ind_cratseg).cdoedptl, 6, ' ');
          
        ELSE 
          
          vr_nrcpfcgc := rpad('0',11,'0');
          vr_nrdocptl := rpad(' ',12,' ');
          vr_dtemdptl := rpad(' ',8,' ');
          vr_cdoedptl := rpad(' ',6,' ');
          
        END IF;
              
        vr_cdmovmto := ' ';
        
        -- Define o tipo de movimento
        IF vr_cratseg(vr_ind_cratseg).tpregist = 3 THEN         
          vr_tpmovmto := 2;  -- Cancelamento
          vr_cdmovmto := to_char(vr_cratseg(vr_ind_cratseg).cdmotcan);        
        ELSIF   vr_cratseg(vr_ind_cratseg).tpregist = 2 THEN 
          vr_tpmovmto := 3;  -- Renovacao
        ELSE 
          vr_tpmovmto := 1;  -- Inclusao
        END IF;
        
        -- Define a data de cancelamento
        IF vr_cratseg(vr_ind_cratseg).dtcancel IS NOT NULL THEN 
          vr_dtcancel := to_char(vr_cratseg(vr_ind_cratseg).dtcancel, 'ddmmyyyy');
        ELSE 
          vr_dtcancel := lpad(' ',8,' ');
        END IF;
        
        -- Busca numero do telefone (Residencial ou Celular)
        OPEN cr_craptfc (pr_cdcooper => rw_crapcop.cdcooper,
                         pr_nrdconta => vr_cratseg(vr_ind_cratseg).nrdconta);
        FETCH cr_craptfc INTO rw_craptfc;
        
        IF cr_craptfc%FOUND THEN 
           CLOSE cr_craptfc;
           vr_nrtelefo := to_char(rw_craptfc.nrtelefo);
        ELSE 
           CLOSE cr_craptfc;
           vr_nrtelefo := ' ';
        END IF;
        
        -- Busca endereço de e-mail
        OPEN cr_crapcem (pr_cdcooper => rw_crapcop.cdcooper,
                         pr_nrdconta => vr_cratseg(vr_ind_cratseg).nrdconta);
        FETCH cr_crapcem INTO rw_crapcem;
        
        IF cr_crapcem%FOUND THEN
           CLOSE cr_crapcem;
           vr_dsdemail := rw_crapcem.dsdemail;
        ELSE 
           CLOSE cr_crapcem;
           vr_dsdemail := ' ';
        END IF;
        
        -- Define o endereço de correspondência
        vr_nrcepend := 0;
        vr_nmcidade := ' ';
        vr_nmbairro := ' ';
        vr_cdufresd := ' ';
        vr_dsendres := ' ';
        vr_complend := ' ';
        vr_nrendres := null;
        
        CASE vr_cratseg(vr_ind_cratseg).tpendcor
          WHEN 1 THEN
            -- Local do Risco (utilizar o endereço segurado)
            vr_nrcepend := vr_cratseg(vr_ind_cratseg).nrcepend;
            vr_nmcidade := substr(rpad(substr(vr_cratseg(vr_ind_cratseg).nmcidade, 1, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')-1), 20, ' '), 1, 20);
            vr_nmbairro := vr_cratseg(vr_ind_cratseg).nmbairro;
            vr_cdufresd := substr(vr_cratseg(vr_ind_cratseg).nmcidade, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')+1, 2);
            vr_dsendres := vr_cratseg(vr_ind_cratseg).dsendres;
            vr_complend := vr_cratseg(vr_ind_cratseg).complend;
            vr_nrendres := vr_cratseg(vr_ind_cratseg).nrendres;
          WHEN 2 THEN 
            -- Busca o endereço residencial
            OPEN cr_crapenc (pr_cdcooper => rw_crapcop.cdcooper,
                             pr_nrdconta => vr_cratseg(vr_ind_cratseg).nrdconta,
                             pr_tpendass => 10);
            FETCH cr_crapenc INTO rw_crapenc;
            
            IF cr_crapenc%FOUND THEN 
              CLOSE cr_crapenc;
              vr_nrcepend := rw_crapenc.nrcepend;
              vr_nmcidade := rw_crapenc.nmcidade;
              vr_nmbairro := rw_crapenc.nmbairro;
              vr_cdufresd := rw_crapenc.cdufende;
              vr_dsendres := rw_crapenc.dsendere;
              vr_complend := rw_crapenc.complend;
              vr_nrendres := rw_crapenc.nrendere;
            ELSE
              CLOSE cr_crapenc;  
            END IF;
            
          WHEN 3 THEN 
            -- Busca o endereço comercial
            OPEN cr_crapenc (pr_cdcooper => rw_crapcop.cdcooper,
                             pr_nrdconta => vr_cratseg(vr_ind_cratseg).nrdconta,
                             pr_tpendass => 9);
            FETCH cr_crapenc INTO rw_crapenc;
            
            IF cr_crapenc%FOUND THEN 
              CLOSE cr_crapenc;
              vr_nrcepend := rw_crapenc.nrcepend;
              vr_nmcidade := rw_crapenc.nmcidade;
              vr_nmbairro := rw_crapenc.nmbairro;
              vr_cdufresd := rw_crapenc.cdufende;
              vr_dsendres := rw_crapenc.dsendere;
              vr_complend := rw_crapenc.complend;
              vr_nrendres := rw_crapenc.nrendere;
            ELSE
              CLOSE cr_crapenc;  
            END IF;
            
          ELSE NULL;
          
        END CASE;
        
        -- Converte o flag de número para texto para incluir no relatório
        IF vr_cratseg(vr_ind_cratseg).flgclabe = 1 THEN 
           vr_flgclabe := 'S';
        ELSE 
           vr_flgclabe := 'N';
        END IF;

        -- Cria a linha de detalhe na pl/table - A primeira linha nesse ponto deve ter indice 2
        IF vr_arquivo.EXISTS(2) THEN
           vr_ind_arquivo := vr_arquivo.last + 1;
        ELSE
           vr_ind_arquivo := 2;
        END IF;

        -- Montar Nome Cidade e sigla do Estado
        IF TRIM(vr_cratseg(vr_ind_cratseg).nmcidade) IS NOT NULL AND
           length(TRIM(vr_cratseg(vr_ind_cratseg).nmcidade)) > 2 AND
           instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/') > 0  THEN
           vr_nmcidaux:= rpad(nvl(substr(vr_cratseg(vr_ind_cratseg).nmcidade, 1, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')-1),' '),20,' '); -- cidade
           vr_sigestad:= rpad(nvl(substr(vr_cratseg(vr_ind_cratseg).nmcidade, instr(vr_cratseg(vr_ind_cratseg).nmcidade, '/')+1,2),' '),2,' ');
        ELSE
           vr_nmcidaux:= rpad(' ',20,' ');
           vr_sigestad:= rpad(' ',2,' ');
        END IF;

        -- vai incluir as linhas intermediárias do arquivo
        vr_arquivo(vr_ind_arquivo).tpdlinha := 2;
        vr_arquivo(vr_ind_arquivo).dsdlinha := to_char(vr_dtmvtolt, 'ddmmyyyy')||
                                               '0000000001'||
                                               substr(rw_craptab.dstextab,59,25)||
                                               gene0002.fn_mask(vr_tpmovmto,'99')||
                                               gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrdconta,'999999999999')||
                                               gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrctrseg,'99999999')||
                                               '00'||
                                               '000000000000'||
                                               to_char(vr_cratseg(vr_ind_cratseg).dtinivig, 'ddmmyyyy')||
                                               to_char(vr_cratseg(vr_ind_cratseg).dtfimvig, 'ddmmyyyy')||
                                               vr_dtcancel||  -- cancelamento
                                               vr_cdmovmto||
                                               rpad(' ', 20, ' ')||
                                               vr_nrcpfcgc||
                                               rpad(vr_cratseg(vr_ind_cratseg).nmprimtl, 60, ' ')||
                                               to_char(vr_cratseg(vr_ind_cratseg).dtnasctl, 'ddmmyyyy')||
                                               rpad(vr_nrdocptl, 12, ' ')||
                                               vr_dtemdptl||
                                               vr_cdoedptl||
                                               gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrdconta,'9999999999')||
                                               gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrcepend,'99999999')||
                                               rpad(vr_cratseg(vr_ind_cratseg).dsendres, 50, ' ')||
                                               rpad(vr_cratseg(vr_ind_cratseg).nrendres, 10, ' ')||
                                               rpad(nvl(vr_cratseg(vr_ind_cratseg).nmbairro,' '), 60, ' ')||
                                               vr_nmcidaux||                 -- cidade
                                               vr_sigestad||                 -- uf
                                               rpad(vr_nrtelefo, 10, ' ')||
                                               gene0002.fn_mask(vr_nrcepend,'99999999')||
                                               rpad(vr_dsendres, 50, ' ')||
                                               rpad(vr_nrendres, 10, ' ')||
                                               rpad(nvl(vr_nmbairro,' '), 60, ' ')||
                                               rpad(nvl(vr_nmcidade,' '), 20, ' ')||   -- cidade
                                               rpad(nvl(vr_cdufresd,' '), 02, ' ')||   -- uf
                                               rpad(nvl(vr_nrtelefo,' '), 10, ' ')||
                                               rpad(nvl(vr_dsdemail,' '), 20, ' ')||
                                               gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).nrdconta,'9999999999')||
                                               gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).cdagenci,'999')||
                                               vr_flgclabe||
                                               rpad(vr_cratseg(vr_ind_cratseg).nmbenvid, 200, ' ')||
                                               gene0002.fn_mask(vr_cratseg(vr_ind_cratseg).tpplaseg,'999')||
                                               rpad(vr_cratseg(vr_ind_cratseg).complend, 40, ' ')||
                                               rpad(vr_complend, 38,' ');
        
        -- se for cancelamento não deve enviar as datas de vencimento das parcelas
        IF TRIM(vr_dtcancel) IS NOT NULL THEN
          vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||
                                                 lpad(' ',96,' ');
        ELSE
          vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||
                                                 to_char(vr_cratseg(vr_ind_cratseg).dtprideb, 'ddmmyyyy')|| -- 1º vencimento
                                                 to_char(vr_cratseg(vr_ind_cratseg).dtdebito, 'ddmmyyyy');  -- 2º vencimento
          -- calcular demais vencimentos 3º ao 12º
          FOR i IN 1..10 LOOP
            vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||
                                                   to_char(add_months(vr_cratseg(vr_ind_cratseg).dtdebito,i), 'ddmmyyyy');
          END LOOP;
        END IF;

        -- finalizar linha
        vr_arquivo(vr_ind_arquivo).dsdlinha := vr_arquivo(vr_ind_arquivo).dsdlinha ||';'||chr(10);
        vr_contareg := vr_contareg + 1;

      END IF;
      
      -- Passa ao próximo registro da pl/table
      vr_ind_cratseg := vr_cratseg.next(vr_ind_cratseg);
      
    END LOOP; -- Fim do while
--##########################################################################################
  
--########*************************************************************************#########
    IF vr_cdsegura <> 0 THEN 
      
      -- Geração do relatório
      -- Nome base do arquivo é crrl416
      vr_nom_arquivo := 'crrl416';
      
      -- Se não for da cooperativa 3, gera arquivo texto
      IF substr(rw_craptab.dstextab, 85, 2) <> ' ' THEN 
        
        vr_nrsequen := to_number(substr(rw_craptab.dstextab, 88, 5)) + 1;
        vr_contareg := vr_contareg + 2; -- Header e Trailer
        
        -- Header
        vr_ind_arquivo := 1; -- vai ser a primeira linha do arquivo
        vr_arquivo(vr_ind_arquivo).tpdlinha := 1;
        vr_arquivo(vr_ind_arquivo).dsdlinha := gene0002.fn_mask(vr_nrsequen, '99999') ||
                                               to_char(vr_dtmvtolt, 'ddmmyyyy') ||
                                               substr(rw_craptab.dstextab, 59, 25) ||
                                               gene0002.fn_mask(vr_contareg, '99999') || chr(10);
                                               
        -- Trailer
        vr_ind_arquivo := vr_arquivo.last + 1; -- vai ser a última linha do arquivo
        vr_arquivo(vr_ind_arquivo).tpdlinha := 3;
        vr_arquivo(vr_ind_arquivo).dsdlinha := gene0002.fn_mask(vr_nrsequen, '99999') ||
                                               to_char(vr_dtmvtolt, 'ddmmyyyy') ||
                                               substr(rw_craptab.dstextab, 59, 25) ||
                                               gene0002.fn_mask(vr_contareg, '99999')|| chr(10);
                                               
        -- Inicializar o CLOB
        vr_des_xml := null;
        vr_des_txt := null;
        dbms_lob.createtemporary(vr_des_xml, true);
        dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
        
        -- Leitura da pl/table e geração do arquivo texto
        FOR i IN 1..vr_arquivo.last LOOP
          
          --Se for a ultima linha
          IF i = vr_arquivo.last THEN 
            gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_arquivo(i).dsdlinha,TRUE);
          ELSE 
            gene0002.pc_escreve_xml(vr_des_xml,vr_des_txt,vr_arquivo(i).dsdlinha,FALSE);
          END IF;
          
        END LOOP;
        
        -- Nome do arquivo
        vr_nom_arquivo := 'RM_COMP' ||
                          gene0002.fn_mask(vr_nrsequen, '99999') ||
                          substr(rw_craptab.dstextab, 85, 2) ||
                          to_char(vr_dtmvtolt, 'ddmmyyyy') ||
                          gene0002.fn_mask(vr_contareg, '99999') ||'.txt';
                          
        -- Envia o arquivo por e-mail e move para o diretório "salvar"
        gene0002.pc_solicita_relato_arquivo(pr_cdcooper  => rw_crapcop.cdcooper, --> Cooperativa conectada
                                            pr_cdprogra  => vr_cdprogra,         --> Programa chamador
                                            pr_dtmvtolt  => vr_dtmvtolt,         --> Data do movimento atual
                                            pr_dsxml     => vr_des_xml,          --> Arquivo XML de dados (CLOB)
                                            pr_dsarqsaid => vr_nom_diretorio||'/'||vr_nom_arquivo, --> Arquivo final
                                            pr_flg_impri => 'N',                 --> Chamar a impressão (Imprim.p)
                                            pr_flg_gerar => 'S',                 --> Gerar o arquivo na hora
                                            pr_dspathcop => gene0001.fn_diretorio(pr_tpdireto => 'C', -- /usr/coop
                                                                                  pr_cdcooper => rw_crapcop.cdcooper,
                                                                                  pr_nmsubdir => '/salvar'),    --> Diretórios a copiar o relatório
                                            pr_dsextcop  => 'txt',               --> Extensão para cópia do relatório aos diretórios
  --                                          pr_flgremarq => 'S',                 --> Flag para remover o arquivo após cópia/email
                                            pr_des_erro  => vr_dscritic);        --> Saída com erro
                                            
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_des_xml);
        dbms_lob.freetemporary(vr_des_xml);

        /*
        begin
          update craptab set craptab.dstextab = substr(craptab.dstextab, 1, 87)||
                             gene0002.fn_mask(vr_nrsequen, '99999')||
                             substr(craptab.dstextab, 93)
          where craptab.cdcooper = pr_cdcooper
          and craptab.nmsistem = 'CRED'
          and craptab.tptabela = 'USUARI'
          and craptab.cdempres = 11
          and craptab.cdacesso = 'SEGPRESTAM'
          and craptab.tpregist = 0;
        exception
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar sequencia: '||sqlerrm;
            raise vr_exc_saida;
        end;
        */
      END IF;
      
    END IF;  
--########*************************************************************************#########

  END LOOP; -- Loop crapcop
  
END;
0
0
