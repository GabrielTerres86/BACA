CREATE OR REPLACE PACKAGE CECRED.CRMW0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : CRMW0001
      Sistema  : Rotinas referentes as Filas de Analise de Fraude
      Sigla    : CRMW0
      Autor    : Ricardo Linhares
      Data     : Julho/2017.                   Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotina referente a consulta de dados de contas para o CRM

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

     PROCEDURE pc_consultar_dados_conta(pr_cdcooper  IN INTEGER, --> Cooperativa
                                        pr_nrdconta  IN  NUMBER, --> Número da conta
                                        pr_xmlrespo OUT  xmltype,--> XML de Resposta
                                        pr_cdcritic OUT  NUMBER, --> Código da Crítica
                                        pr_dscritic OUT VARCHAR2,--> Descrição da Crítica
                                        pr_dsdetcri OUT VARCHAR2);--> Detalhe dacritic



END CRMW0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CRMW0001 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : CRMW0001
      Sistema  : Rotinas referentes as Filas de Analise de Fraude
      Sigla    : CRMW0
      Autor    : Ricardo Linhares
      Data     : Julho/2017.                   Ultima atualizacao:

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotina referente a consulta de dados de contas para o CRM

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/

    PROCEDURE pc_consultar_dados_conta(pr_cdcooper  IN INTEGER, --> Cooperativa
                                       pr_nrdconta  IN  NUMBER, --> Número da conta
                                       pr_xmlrespo OUT  xmltype,--> XML de Resposta
                                       pr_cdcritic OUT  NUMBER, --> Código da Crítica
                                       pr_dscritic OUT VARCHAR2,--> Descrição da Crítica
                                       pr_dsdetcri OUT VARCHAR2) IS --> Detalhe dacritic
     BEGIN

       DECLARE
       
         vr_exc_erro EXCEPTION;
         vr_cdcritic crapcri.cdcritic%TYPE;
         vr_dscritic crapcri.dscritic%TYPE;
         vr_xml_clob CLOB;      
         vr_xml_temp VARCHAR2(32726) := '';
       
          -- Buscar os telefones ativos de uma conta
          CURSOR cr_telefones(pr_cdcooper IN craptfc.cdcooper%TYPE
                             ,pr_nrdconta IN craptfc.nrdconta%TYPE
                             ,pr_idseqttl IN craptfc.idseqttl%TYPE) IS 
            SELECT DECODE(t.tptelefo,
                          1,
                          'Residencial',
                          2,
                          'Celular',
                          3,
                          'Comercial',
                          4,
                          'Contato') dstipotelefone,
                   t.tptelefo codigotipotelefone,
                   t.nrdddtfc dddtelefone,
                   t.nrtelefo numerotelefone,
                   t.nmpescto nomepessoacontato
              FROM craptfc t
             WHERE t.cdcooper = pr_cdcooper
               AND t.nrdconta = pr_nrdconta
               AND t.idseqttl = pr_idseqttl               
               AND t.idseqttl = pr_idseqttl
               AND t.idsittfc = 1; -- Telefone ativos
          rw_telefones cr_telefones%ROWTYPE;               

          -- Retorna dados do primeiro titular da conta
          CURSOR cr_titular(pr_cdcooper IN crapttl.cdcooper%TYPE
                           ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
             SELECT a.cdcooper codigocooperativa,
                         t.idseqttl seqtitularidade,
                         a.nrdconta numeroconta,
                         x.cdagenci codigoagencia,
                         a.nrcpfcgc nrcpfcnpj,
                         CASE
                           WHEN a.inpessoa = 1 THEN
                            'F'
                           ELSE
                            'J'
                         END tipopessoa,
                         TO_CHAR(COALESCE(t.dtnasttl, j.dtregemp),'DD/MM/YYYY') dtnascimento,
                         a.nmprimtl nomecompleto,
                         a.dsproftl nomecargo,
                         t.tpdocttl sigla,
                         t.nrdocttl nrdocumento,
                         e.dsendere logradouro,
                         e.nrendere numeroendereco,
                         e.nmbairro nomebairro,
                         e.nmcidade nomecidade,
                         e.cdufende siglaestado,               
                         e.nrcepend cep,
                         e.nrdoapto numeroapto,
                         e.cddbloco bloco,
                         e.complend complemento,
                         t.dsnatura naturalidade,
                         t.nmpaittl nomepai,
                         t.nmmaettl nomemae,
                         z.cdestcvl codigoestadocivil,
                         z.rsestcvl dsestadocivil,
                         j.nmfansia nomefantasia,
                         j.cdseteco codigosetoreco,
                         s.dstextab descricaosetoreco,
                         j.cdrmativ codigoatividade,
                         r.nmrmativ descricaoatividade
                    FROM crapass a
               LEFT JOIN crapass x
                      ON x.cdcooper = a.cdcooper
                     AND x.nrdconta = a.nrdconta
               LEFT JOIN crapttl t
                      ON t.cdcooper = a.cdcooper
                     AND t.nrdconta = a.nrdconta
                     AND t.idseqttl = 1
               LEFT JOIN crapjur j
                      ON j.cdcooper = a.cdcooper
                     AND j.nrdconta = a.nrdconta
               LEFT JOIN crapenc e
                      ON e.cdcooper = a.cdcooper
                     AND e.nrdconta = a.nrdconta
                     AND e.idseqttl = 1               
               LEFT JOIN gnetcvl z
                      ON z.cdestcvl = t.cdestcvl
               LEFT JOIN craptab s
                      ON s.cdcooper = j.cdcooper
                     AND UPPER(s.cdacesso) = 'SETORECONO'
                     AND s.tpregist = j.cdseteco
               LEFT JOIN gnrativ r
                      ON r.cdseteco = j.cdseteco
                     AND r.cdrmativ = j.cdrmativ
                   WHERE a.cdcooper = pr_cdcooper
                     AND a.nrdconta = pr_nrdconta
                     AND e.tpendass = DECODE(a.inpessoa, 1, 10, 2, 9);
          rw_titular cr_titular%ROWTYPE;

          -- Retorna dados dos demais titulares da conta
          CURSOR cr_titulares (pr_cdcooper IN crapttl.cdcooper%TYPE
                              ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS
            SELECT a.cdcooper codigocooperativa,
                   a.idseqttl seqtitularidade,
                   a.nrdconta numeroconta,
                   x.cdagenci codigoagencia,
                   a.nrcpfcgc nrcpfcnpj,
                   CASE
                     WHEN a.inpessoa = 1 THEN
                      'F'
                     ELSE
                      'J'
                   END tipopessoa,
                   to_char(a.dtnasttl,'DD/MM/YYYY') dtnascimento,
                   a.nmextttl nomecompleto,
                   a.dsproftl nomecargo,
                   a.tpdocttl sigla,
                   a.nrdocttl nrdocumento,
                   e.dsendere logradouro,
                   e.nrendere numeroendereco,
                   e.nmbairro nomebairro,
                   e.nmcidade nomecidade,
                   e.cdufende siglaestado,
                   e.nrcepend cep,
                   e.nrdoapto numeroapto,
                   e.cddbloco bloco,
                   e.complend complemento,
                   a.dsnatura naturalidade,
                   a.nmpaittl nomepai,
                   a.nmmaettl nomemae,
                   z.cdestcvl codigoestadocivil,
                   z.rsestcvl dsestadocivil
              FROM crapttl a
         LEFT JOIN crapenc e
                ON e.cdcooper = a.cdcooper
               AND e.nrdconta = a.nrdconta
               AND e.idseqttl = a.idseqttl
         LEFT JOIN crapass x
                ON x.cdcooper = a.cdcooper
               AND x.nrdconta = a.nrdconta
         LEFT JOIN gnetcvl z
                ON z.cdestcvl = a.cdestcvl
             WHERE a.cdcooper = pr_cdcooper
               AND a.nrdconta = pr_nrdconta
               AND e.tpendass = 10 -- Endereço residencial
               AND e.idseqttl > 1; -- Outros titulares
          rw_titulares cr_titulares%ROWTYPE;

          -- Retorna dados dos operadores ativos na conta
          CURSOR cr_operadores(pr_cdcooper IN crapopi.cdcooper%TYPE
                              ,pr_nrdconta IN crapopi.nrdconta%TYPE) IS
            SELECT w.nmoperad nomeoperador,
                   w.nrcpfope cpfoperador,
                   w.dsdcargo cargooperador
              FROM crapopi w
             WHERE w.cdcooper = pr_cdcooper
               AND w.flgsitop = 1 -- Situação do operador (1-Ativo)
               AND w.nrdconta = pr_nrdconta;
          rw_operadores cr_operadores%ROWTYPE;

          -- Buscar os dados do responsavel legal da conta
          CURSOR cr_responsavel(pr_cdcooper IN crapcrl.cdcooper%TYPE
                               ,pr_nrdconta IN crapcrl.nrdconta%TYPE) IS
          
            SELECT COALESCE(x.idseqmen, 1) seqtitularidade,
                   COALESCE(t.cdcooper, x.cdcooper) codigocooperativa,
                   COALESCE(t.nrdconta, x.nrdconta) numeroconta,
                   COALESCE(t.cdagenci, 0) codigoagencia,
                   COALESCE(t.nrcpfcgc, x.nrcpfcgc) nrcpfcnpj,
                   'F' tipopessoa,
                   TO_CHAR(COALESCE(t.dtnasctl, x.dtnascin),'DD/MM/YYYY') dtnascimento,
                   COALESCE(t.nmprimtl, x.nmrespon) nomecompleto,
                   COALESCE(t.dsproftl, '') nomecargo,
                   COALESCE(t.tpdocptl, x.tpdeiden) sigla,
                   COALESCE(t.nrdocptl, x.nridenti) nrdocumento,
                   COALESCE(e.dsendere, x.dsendres) logradouro,
                   COALESCE(e.nrendere, x.nrendres) numeroendereco,
                   COALESCE(e.nmbairro, x.dsbaires) nomebairro,
                   COALESCE(e.nmcidade, x.dscidres) nomecidade,
                   COALESCE(e.cdufende, x.dsdufres) siglaestado,
                   COALESCE(e.nrcepend, x.cdcepres) cep,
                   COALESCE(e.nrdoapto, x.nrcxpost) numeroapto,
                   COALESCE(e.cddbloco, '') bloco,
                   COALESCE(e.complend, x.dscomres) complemento,
                   COALESCE(y.dsnatura, x.dsnatura) naturalidade,
                   COALESCE(y.nmpaittl, x.nmpairsp) nomepai,
                   COALESCE(y.nmmaettl, x.nmmaersp) nomemae,
                   COALESCE(y.cdestcvl, x.cdestciv) codigoestadocivil,
                   COALESCE(d.rsestcvl, z.rsestcvl) dsestadocivil
              FROM crapcrl x
         LEFT JOIN crapass t
                ON t.cdcooper = x.cdcooper
               AND t.nrdconta = x.nrdconta
         LEFT JOIN crapttl y
                ON y.cdcooper = x.cdcooper
               AND y.nrdconta = x.nrdconta
               AND y.idseqttl = 1
         LEFT JOIN gnetcvl z
                ON z.cdestcvl = x.cdestciv
         LEFT JOIN gnetcvl d
                ON d.cdestcvl = y.cdestcvl
         LEFT JOIN crapenc e
                ON e.cdcooper = t.cdcooper
               AND e.nrdconta = t.nrdconta
               AND e.tpendass = 10
             WHERE x.cdcooper = pr_cdcooper
               AND x.nrctamen = pr_nrdconta;
               
          rw_responsavel cr_responsavel%ROWTYPE;

          -- Buscar os dados dos representantes legais da conta
          CURSOR cr_representantes(pr_cdcooper IN crapavt.cdcooper%TYPE
                                  ,pr_nrdconta IN crapavt.nrdconta%TYPE) IS
            SELECT 1 seqtitularidade,
                     COALESCE(x.cdcooper, t.cdcooper) codigocooperativa,
                     t.nrdctato numeroconta,
                     COALESCE(x.cdagenci, t.cdagenci) codigoagencia,
                     COALESCE(x.nrcpfcgc, t.nrcpfcgc) nrcpfcnpj,
                     CASE
                       WHEN x.inpessoa = 1 THEN
                        'F'
                       ELSE
                        'J'
                     END tipopessoa,
                     TO_CHAR(COALESCE(x.dtnasctl, t.dtnascto, y.dtnasttl),'DD/MM/YYYY') dtnascimento,
                     COALESCE(x.nmprimtl, t.nmdavali) nomecompleto,
                     COALESCE(t.dsproftl, x.dsproftl) nomecargo,
                     COALESCE(y.tpdocttl, x.tpdocttl, t.tpdocava) sigla,
                     COALESCE(y.nrdocttl, x.nrdocttl, t.nrdocava) nrdocumento,
                     COALESCE(e.dsendere, t.dsendres##1, t.dsendres##2) logradouro,
                     COALESCE(e.nrendere, t.nrendere) numeroendereco,
                     COALESCE(e.nmbairro, t.nmbairro) nomebairro,
                     COALESCE(e.nmcidade, t.nmcidade) nomecidade,
                     COALESCE(e.cdufende, t.cdufresd) siglaestado,
                     COALESCE(e.nrcepend, t.nrcepend) cep,
                     COALESCE(e.nrdoapto, t.nrcxapst) numeroapto,
                     COALESCE(e.cddbloco, '') bloco,
                     COALESCE(e.complend, t.complend) complemento,
                     COALESCE(y.dsnatura, t.dsnatura) naturalidade,
                     COALESCE(y.nmpaittl, t.nmpaicto) nomepai,
                     COALESCE(y.nmextttl, t.nmmaecto) nomemae,
                     Coalesce(d.cdestcvl, z.cdestcvl) codigoestadocivil,
                     Coalesce(d.rsestcvl, z.rsestcvl) dsestadocivil
                FROM crapavt t
          LEFT JOIN crapenc e
                  ON e.cdcooper = t.cdcooper
                 AND e.nrdconta = t.nrdctato
                 AND e.idseqttl = 1
          LEFT JOIN crapass x
                  ON x.cdcooper = t.cdcooper
                 AND x.nrdconta = t.nrdctato
          LEFT JOIN crapttl y          
                  ON y.cdcooper = t.cdcooper
                 AND y.nrdconta = t.nrdctato
                 AND y.idseqttl = 1
          LEFT JOIN gnetcvl z
                 ON z.cdestcvl = t.cdestcvl
         
          LEFT JOIN gnetcvl d
                 ON d.cdestcvl = y.cdestcvl
         
               WHERE t.cdcooper = pr_cdcooper
                 AND t.tpctrato = 6 -- Representantes legal
                 AND t.nrdconta = pr_nrdconta -- Número da conta
                 AND e.tpendass = 10 -- Endereço residencial
                 AND t.dsproftl IN ('SOCIO/PROPRIETARIO',
                                    'DIRETOR/ADMINISTRADOR',
                                    'PROCURADOR',
                                    'SOCIO COTISTA',
                                    'SOCIO ADMINISTRADOR',
                                    'SINDICO',
                                    'TESOUREIRO',
                                    'ADMINISTRADOR'); -- Responsaveis legais
          rw_representantes cr_representantes%ROWTYPE;                                    

       BEGIN
         
        dbms_lob.createtemporary(vr_xml_clob, TRUE);
        dbms_lob.open(vr_xml_clob, dbms_lob.lob_readwrite);
        
        OPEN cr_titular(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
        FETCH cr_titular INTO rw_titular;
        IF cr_titular%NOTFOUND THEN
          CLOSE cr_titular;
          vr_dscritic := 'Conta não encontrada';
          RAISE vr_exc_erro; 
        END IF;     

        CLOSE cr_titular;          
         
         -- Criar cabecalho do XML
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '<conta>');       
                               
        -- Dados do titular
        gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<titular>' ||
                                '<codigocooperativa>' || rw_titular.codigocooperativa || '</codigocooperativa>' ||
                                '<seqtitularidade>'   || rw_titular.seqtitularidade   || '</seqtitularidade>' ||
                                '<numeroconta>'       || rw_titular.numeroconta       || '</numeroconta>' ||
                                '<codigoagencia>'     || rw_titular.codigoagencia     || '</codigoagencia>' ||
                                '<nrcpfcnpj>'         || rw_titular.nrcpfcnpj         || '</nrcpfcnpj>' ||
                                '<tipopessoa>'        || rw_titular.tipopessoa        || '</tipopessoa>' ||
                                '<dtnascimento>'      || rw_titular.dtnascimento      || '</dtnascimento>' ||
                                '<nomecompleto>'      || rw_titular.nomecompleto      || '</nomecompleto>' ||
                                '<nomefantasia>'      || rw_titular.nomefantasia      || '</nomefantasia>' ||
                                '<nomecargo>'         || rw_titular.nomecargo         || '</nomecargo>' ||
                                '<tipodocumento>'     ||
                                  '<sigla>'           || rw_titular.sigla             || '</sigla>' ||
                                  '<nrdocumento>'     || rw_titular.nrdocumento       || '</nrdocumento>' ||                                  
                                '</tipodocumento>'    ||
                                '<ramoatividade>'     ||
                                  '<codigoatividade>' || rw_titular.codigoatividade   || '</codigoatividade>' ||
                                  '<descricaoatividade>'|| rw_titular.descricaoatividade || '</descricaoatividade>' ||                                  
                                '</ramoatividade>'    ||
                                '<setoreconomico>'    ||
                                  '<codigosetoreco>'  || rw_titular.codigosetoreco       || '</codigosetoreco>' ||
                                  '<descricaosetoreco>' || rw_titular.descricaosetoreco  || '</descricaosetoreco>' ||                                  
                                '</setoreconomico>'   ||
                                '<endereco>'          ||
                                  '<logradouro>'      || rw_titular.logradouro     || '</logradouro>'     ||
                                  '<numeroendereco>'  || rw_titular.numeroendereco || '</numeroendereco>' ||
                                  '<nomebairro>'      || rw_titular.nomebairro     || '</nomebairro>'     ||
                                  '<nomecidade>'      || rw_titular.nomecidade     || '</nomecidade>'     ||
                                  '<siglaestado>'     || rw_titular.siglaestado    || '</siglaestado>'    ||
                                  '<cep>'             || rw_titular.cep            || '</cep>'            ||
                                  '<numeroapto>'      || rw_titular.numeroapto     || '</numeroapto>'     || 
                                  '<bloco>'           || rw_titular.bloco          || '</bloco>'          ||
                                  '<complemento>'     || rw_titular.complemento    || '</complemento>'    ||
                                '</endereco>'         ||
                                '<naturalidade>'      || rw_titular.naturalidade   || '</naturalidade>'   ||
                                '<nomepai>'           || rw_titular.nomepai        || '</nomepai>'        ||
                                '<nomemae>'           || rw_titular.nomemae        || '</nomemae>'        ||
                                '<estadocivil>'       ||
                                  '<codigoestadocivil>' || rw_titular.codigoestadocivil || '</codigoestadocivil>' ||
                                  '<dsestadocivil>'     || rw_titular.dsestadocivil     || '</dsestadocivil>'     ||
                                '</estadocivil>');

          -- Telefones
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     => '<telefones>');
     
          
          FOR rw_telefones IN cr_telefones(pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_idseqttl => 1) LOOP                       
                                            
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                   ,pr_texto_completo => vr_xml_temp      
                                   ,pr_texto_novo     => 
                                   '<telefone>' ||
                                     '<dstipotelefone>'     || rw_telefones.dstipotelefone     || '</dstipotelefone>'     ||
                                     '<codigotipotelefone>' || rw_telefones.codigotipotelefone || '</codigotipotelefone>' ||
                                     '<dddtelefone>'        || rw_telefones.dddtelefone        || '</dddtelefone>'        ||
                                     '<numerotelefone>'     || rw_telefones.numerotelefone     || '</numerotelefone>'     ||
                                     '<nomepessoacontato>'  || rw_telefones.nomepessoacontato  || '</nomepessoacontato>'  ||
                                   '</telefone>');
                                            
          END LOOP;
            
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     => '</telefones></titular>');
                                 
         -- Titulares 
        IF rw_titular.tipopessoa = 'F' THEN

            gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                   ,pr_texto_completo => vr_xml_temp      
                                   ,pr_texto_novo     => '<titulares>');          

            FOR rw_titulares IN cr_titulares(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta) LOOP                       
                                            
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                               ,pr_texto_completo => vr_xml_temp      
                               ,pr_texto_novo     => 
                               '<pessoa>' ||
                                '<codigocooperativa>' || rw_titulares.codigocooperativa || '</codigocooperativa>' ||
                                '<seqtitularidade>'   || rw_titulares.seqtitularidade   || '</seqtitularidade>' ||
                                '<numeroconta>'       || rw_titulares.numeroconta       || '</numeroconta>' ||
                                '<codigoagencia>'     || rw_titulares.codigoagencia     || '</codigoagencia>' ||
                                '<nrcpfcnpj>'         || rw_titulares.nrcpfcnpj         || '</nrcpfcnpj>' ||
                                '<tipopessoa>'        || rw_titulares.tipopessoa        || '</tipopessoa>' ||
                                '<dtnascimento>'      || rw_titulares.dtnascimento      || '</dtnascimento>' ||
                                '<nomecompleto>'      || rw_titulares.nomecompleto      || '</nomecompleto>' ||
                                '<nomecargo>'         || rw_titulares.nomecargo         || '</nomecargo>' ||
                                '<tipodocumento>'     ||
                                  '<sigla>'           || rw_titulares.sigla             || '</sigla>' ||
                                  '<nrdocumento>'     || rw_titulares.nrdocumento       || '</nrdocumento>' ||                                  
                                '</tipodocumento>'    ||
                                '<endereco>'          ||
                                  '<logradouro>'      || rw_titulares.logradouro     || '</logradouro>'     ||
                                  '<numeroendereco>'  || rw_titulares.numeroendereco || '</numeroendereco>' ||
                                  '<nomebairro>'      || rw_titulares.nomebairro     || '</nomebairro>'     ||
                                  '<nomecidade>'      || rw_titulares.nomecidade     || '</nomecidade>'     ||
                                  '<siglaestado>'     || rw_titulares.siglaestado    || '</siglaestado>'    ||
                                  '<cep>'             || rw_titulares.cep            || '</cep>'            ||
                                  '<numeroapto>'      || rw_titulares.numeroapto     || '</numeroapto>'     || 
                                  '<bloco>'           || rw_titulares.bloco          || '</bloco>'          ||
                                  '<complemento>'     || rw_titulares.complemento    || '</complemento>'    ||
                                '</endereco>'         ||
                                '<naturalidade>'      || rw_titulares.naturalidade   || '</naturalidade>'   ||
                                '<nomepai>'           || rw_titulares.nomepai        || '</nomepai>'        ||
                                '<nomemae>'           || rw_titulares.nomemae        || '</nomemae>'        ||
                                '<estadocivil>'       ||
                                  '<codigoestadocivil>' || rw_titulares.codigoestadocivil || '</codigoestadocivil>' ||
                                  '<dsestadocivil>'     || rw_titulares.dsestadocivil     || '</dsestadocivil>'     ||
                                '</estadocivil>');
                                
                                
                -- Telefones
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                       ,pr_texto_completo => vr_xml_temp      
                                       ,pr_texto_novo     => '<telefones>');                              
                                
                FOR rw_telefones IN cr_telefones(pr_cdcooper => pr_cdcooper
                                                ,pr_nrdconta => pr_nrdconta
                                                ,pr_idseqttl => rw_titulares.seqtitularidade) LOOP                       
                                                  
                  gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                         ,pr_texto_completo => vr_xml_temp      
                                         ,pr_texto_novo     => 
                                         '<telefone>' ||
                                           '<dstipotelefone>'     || rw_telefones.dstipotelefone     || '</dstipotelefone>'     ||
                                           '<codigotipotelefone>' || rw_telefones.codigotipotelefone || '</codigotipotelefone>' ||
                                           '<dddtelefone>'        || rw_telefones.dddtelefone        || '</dddtelefone>'        ||
                                           '<numerotelefone>'     || rw_telefones.numerotelefone     || '</numerotelefone>'     ||
                                           '<nomepessoacontato>'  || rw_telefones.nomepessoacontato  || '</nomepessoacontato>'  ||
                                         '</telefone>');
                                                  
                END LOOP;
                  
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                       ,pr_texto_completo => vr_xml_temp      
                                       ,pr_texto_novo     => '</telefones>');  
                                       
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                       ,pr_texto_completo => vr_xml_temp      
                                       ,pr_texto_novo     => '</pessoa>');    
       
            END LOOP;
            
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                   ,pr_texto_completo => vr_xml_temp      
                                   ,pr_texto_novo     => '</titulares>');        
                                 
          END IF;                                  

        -- Operadores
        IF rw_titular.tipopessoa = 'J' THEN                                 
     
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                 ,pr_texto_completo => vr_xml_temp      
                                 ,pr_texto_novo     => '<operadores>'); 
                                 
            FOR rw_operadores IN cr_operadores(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta) LOOP                                                                         
                                              
              gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                     ,pr_texto_completo => vr_xml_temp      
                                     ,pr_texto_novo     => 
                                     '<operador>' ||
                                       '<nomeoperador>'  || rw_operadores.nomeoperador  || '</nomeoperador>'  ||
                                       '<cpfoperador>'   || rw_operadores.cpfoperador   || '</cpfoperador>'   ||
                                       '<cargooperador>' || rw_operadores.cargooperador || '</cargooperador>' ||
                                     '</operador>');                                          
                                              
            END LOOP;
            
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                   ,pr_texto_completo => vr_xml_temp      
                                   ,pr_texto_novo     => '</operadores>');            
        END IF;
                          
        -- Responsável Legal
        IF rw_titular.tipopessoa = 'F' THEN
        
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '<responsavellegal>');
                                 
          FOR rw_responsavel IN cr_responsavel(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta) LOOP
                                            

            gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                   ,pr_texto_completo => vr_xml_temp      
                                   ,pr_texto_novo     => 
                                   '<pessoa>' ||
                                    '<codigocooperativa>' || rw_responsavel.codigocooperativa || '</codigocooperativa>' ||
                                    '<seqtitularidade>'   || rw_responsavel.seqtitularidade   || '</seqtitularidade>' ||
                                    '<numeroconta>'       || rw_responsavel.numeroconta       || '</numeroconta>' ||
                                    '<codigoagencia>'     || rw_responsavel.codigoagencia     || '</codigoagencia>' ||
                                    '<nrcpfcnpj>'         || rw_responsavel.nrcpfcnpj         || '</nrcpfcnpj>' ||
                                    '<tipopessoa>'        || rw_responsavel.tipopessoa        || '</tipopessoa>' ||
                                    '<dtnascimento>'      || rw_responsavel.dtnascimento      || '</dtnascimento>' ||
                                    '<nomecompleto>'      || rw_responsavel.nomecompleto      || '</nomecompleto>' ||
                                    '<nomecargo>'         || rw_responsavel.nomecargo         || '</nomecargo>' ||
                                    '<tipodocumento>'     ||
                                      '<sigla>'           || rw_responsavel.sigla             || '</sigla>' ||
                                      '<nrdocumento>'     || rw_responsavel.nrdocumento       || '</nrdocumento>' ||                                  
                                    '</tipodocumento>'    ||
                                    '<endereco>'          ||
                                      '<logradouro>'      || rw_responsavel.logradouro     || '</logradouro>'     ||
                                      '<numeroendereco>'  || rw_responsavel.numeroendereco || '</numeroendereco>' ||
                                      '<nomebairro>'      || rw_responsavel.nomebairro     || '</nomebairro>'     ||
                                      '<nomecidade>'      || rw_responsavel.nomecidade     || '</nomecidade>'     ||
                                      '<siglaestado>'     || rw_responsavel.siglaestado    || '</siglaestado>'    ||
                                      '<cep>'             || rw_responsavel.cep            || '</cep>'            ||
                                      '<numeroapto>'      || rw_responsavel.numeroapto     || '</numeroapto>'     || 
                                      '<bloco>'           || rw_responsavel.bloco          || '</bloco>'          ||
                                      '<complemento>'     || rw_responsavel.complemento    || '</complemento>'    ||
                                    '</endereco>'         ||
                                    '<naturalidade>'      || rw_responsavel.naturalidade   || '</naturalidade>'   ||
                                    '<nomepai>'           || rw_responsavel.nomepai        || '</nomepai>'        ||
                                    '<nomemae>'           || rw_responsavel.nomemae        || '</nomemae>'        ||
                                    '<estadocivil>'       ||
                                      '<codigoestadocivil>' || rw_responsavel.codigoestadocivil || '</codigoestadocivil>' ||
                                      '<dsestadocivil>'     || rw_responsavel.dsestadocivil     || '</dsestadocivil>'     ||
                                    '</estadocivil>');
                                    
                    -- Telefones
                    gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                           ,pr_texto_completo => vr_xml_temp      
                                           ,pr_texto_novo     => '<telefones>');                              
                                    
                    FOR rw_telefones IN cr_telefones(pr_cdcooper => rw_responsavel.codigocooperativa
                                                    ,pr_nrdconta => rw_responsavel.numeroconta
                                                    ,pr_idseqttl => rw_responsavel.seqtitularidade) LOOP                       
                                                      
                      gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                             ,pr_texto_completo => vr_xml_temp      
                                             ,pr_texto_novo     => 
                                             '<telefone>' ||
                                               '<dstipotelefone>'     || rw_telefones.dstipotelefone     || '</dstipotelefone>'     ||
                                               '<codigotipotelefone>' || rw_telefones.codigotipotelefone || '</codigotipotelefone>' ||
                                               '<dddtelefone>'        || rw_telefones.dddtelefone        || '</dddtelefone>'        ||
                                               '<numerotelefone>'     || rw_telefones.numerotelefone     || '</numerotelefone>'     ||
                                               '<nomepessoacontato>'  || rw_telefones.nomepessoacontato  || '</nomepessoacontato>'  ||
                                             '</telefone>');
                                                      
                    END LOOP;
                      
                    gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                           ,pr_texto_completo => vr_xml_temp      
                                           ,pr_texto_novo     => '</telefones>');
                                           
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                       ,pr_texto_completo => vr_xml_temp
                                       ,pr_texto_novo     => '</pessoa>');                                                                                                                 


          END LOOP;      
      
          gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                 ,pr_texto_completo => vr_xml_temp
                                 ,pr_texto_novo     => '</responsavellegal>');   
        END IF;                               
                              
        -- Representante Legal
        
        IF rw_titular.tipopessoa = 'J' THEN
        
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '<representantelegal>');
                                   
            FOR rw_representantes IN cr_representantes(pr_cdcooper => pr_cdcooper
                                                    ,pr_nrdconta => pr_nrdconta) LOOP

              gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                     ,pr_texto_completo => vr_xml_temp      
                                     ,pr_texto_novo     => 
                                     '<pessoa>' ||
                                      '<codigocooperativa>' || rw_representantes.codigocooperativa || '</codigocooperativa>' ||
                                      '<seqtitularidade>'   || rw_representantes.seqtitularidade   || '</seqtitularidade>' ||
                                      '<numeroconta>'       || rw_representantes.numeroconta       || '</numeroconta>' ||
                                      '<codigoagencia>'     || rw_representantes.codigoagencia     || '</codigoagencia>' ||
                                      '<nrcpfcnpj>'         || rw_representantes.nrcpfcnpj         || '</nrcpfcnpj>' ||
                                      '<tipopessoa>'        || rw_representantes.tipopessoa        || '</tipopessoa>' ||
                                      '<dtnascimento>'      || rw_representantes.dtnascimento      || '</dtnascimento>' ||
                                      '<nomecompleto>'      || rw_representantes.nomecompleto      || '</nomecompleto>' ||
                                      '<nomecargo>'         || rw_representantes.nomecargo         || '</nomecargo>' ||
                                      '<tipodocumento>'     ||
                                        '<sigla>'           || rw_representantes.sigla             || '</sigla>' ||
                                        '<nrdocumento>'     || rw_representantes.nrdocumento       || '</nrdocumento>' ||                                  
                                      '</tipodocumento>'    ||
                                      '<endereco>'          ||
                                        '<logradouro>'      || rw_representantes.logradouro     || '</logradouro>'     ||
                                        '<numeroendereco>'  || rw_representantes.numeroendereco || '</numeroendereco>' ||
                                        '<nomebairro>'      || rw_representantes.nomebairro     || '</nomebairro>'     ||
                                        '<nomecidade>'      || rw_representantes.nomecidade     || '</nomecidade>'     ||
                                        '<siglaestado>'     || rw_representantes.siglaestado    || '</siglaestado>'    ||
                                        '<cep>'             || rw_representantes.cep            || '</cep>'            ||
                                        '<numeroapto>'      || rw_representantes.numeroapto     || '</numeroapto>'     || 
                                        '<bloco>'           || rw_representantes.bloco          || '</bloco>'          ||
                                        '<complemento>'     || rw_representantes.complemento    || '</complemento>'    ||
                                      '</endereco>'         ||
                                      '<naturalidade>'      || rw_representantes.naturalidade   || '</naturalidade>'   ||
                                      '<nomepai>'           || rw_representantes.nomepai        || '</nomepai>'        ||
                                      '<nomemae>'           || rw_representantes.nomemae        || '</nomemae>'        ||
                                      '<estadocivil>'       ||
                                        '<codigoestadocivil>' || rw_representantes.codigoestadocivil || '</codigoestadocivil>' ||
                                        '<dsestadocivil>'     || rw_representantes.dsestadocivil     || '</dsestadocivil>'     ||
                                      '</estadocivil>');
                                      
                -- Telefones
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                       ,pr_texto_completo => vr_xml_temp      
                                       ,pr_texto_novo     => '<telefones>');                              
                                        
                FOR rw_telefones IN cr_telefones(pr_cdcooper => rw_representantes.codigocooperativa
                                                ,pr_nrdconta => rw_representantes.numeroconta
                                                ,pr_idseqttl => rw_representantes.seqtitularidade) LOOP                       
                                                          
                  gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                         ,pr_texto_completo => vr_xml_temp      
                                         ,pr_texto_novo     => 
                                         '<telefone>' ||
                                           '<dstipotelefone>'     || rw_telefones.dstipotelefone     || '</dstipotelefone>'     ||
                                           '<codigotipotelefone>' || rw_telefones.codigotipotelefone || '</codigotipotelefone>' ||
                                           '<dddtelefone>'        || rw_telefones.dddtelefone        || '</dddtelefone>'        ||
                                           '<numerotelefone>'     || rw_telefones.numerotelefone     || '</numerotelefone>'     ||
                                           '<nomepessoacontato>'  || rw_telefones.nomepessoacontato  || '</nomepessoacontato>'  ||
                                         '</telefone>');
                                                          
                END LOOP;
                          
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                       ,pr_texto_completo => vr_xml_temp      
                                       ,pr_texto_novo     => '</telefones>');
                                               
                gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                       ,pr_texto_completo => vr_xml_temp
                                       ,pr_texto_novo     => '</pessoa>');                                                                        


            END LOOP;                               
                                   
            gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                                   ,pr_texto_completo => vr_xml_temp
                                   ,pr_texto_novo     => '</representantelegal>');   
                               
        END IF;                            
                               
        -- fechamento do XML

        gene0002.pc_escreve_xml(pr_xml            => vr_xml_clob
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo     => '</conta>'
                               ,pr_fecha_xml      => TRUE);      

       pr_xmlrespo := xmltype(vr_xml_clob);                              
                               
        EXCEPTION
          WHEN vr_exc_erro THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := vr_dscritic;
            pr_xmlrespo := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
          WHEN OTHERS THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := 'Erro geral (CRMW.pc_consultar_dados_conta): ' || SQLERRM;
            pr_xmlrespo := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Erro>' || pr_dscritic || '</Erro></Root>');
                              
       END;

     END pc_consultar_dados_conta;

END CRMW0001;
/
