CREATE OR REPLACE PACKAGE CECRED.CADA0008 is
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CADA0008
  --  Sistema  : Rotinas acessadas pelas telas de cadastros Web
  --  Sigla    : CADA
  --  Autor    : Marcelo Telles Coelho         - Mount´s
  --  Data     : Outubro/2017.                 Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas utilizadas para as telas CADCTA referente a cadastros
  --
  --  Alteracoes:
  --
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Variaveis Globais
  vr_xml xmltype; -- XML qye sera enviado

  -- Buscar dados complementares do titular para cadastramento do titular
	PROCEDURE pc_ret_dados_aval( pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE,
                               pr_nmdavali OUT crapavt.nmdavali%TYPE,
                               pr_tpdocava OUT crapavt.tpdocava%TYPE,
                               pr_nrdocava OUT crapavt.nrdocava%TYPE,
                               pr_nmconjug OUT crapavt.nmconjug%TYPE,
                               pr_nrcpfcjg OUT crapavt.nrcpfcjg%TYPE,
                               pr_tpdoccjg OUT crapavt.tpdoccjg%TYPE,
                               pr_nrdoccjg OUT crapavt.nrdoccjg%TYPE,
                               pr_dsendre1 OUT crapavt.dsendres##1%TYPE,
                               pr_dsendre2 OUT crapavt.dsendres##2%TYPE,
                               pr_nrfonres OUT crapavt.nrfonres%TYPE,
                               pr_dsdemail OUT crapavt.dsdemail%TYPE,
                               pr_nmcidade OUT crapavt.nmcidade%TYPE,
                               pr_cdufresd OUT crapavt.cdufresd%TYPE,
                               pr_nrcepend OUT crapavt.nrcepend%TYPE,
                               pr_dsnacion OUT crapnac.dsnacion%TYPE,
                               pr_vledvmto OUT crapavt.vledvmto%TYPE,
                               pr_vlrenmes OUT crapavt.vlrenmes%TYPE,
                               pr_complend OUT VARCHAR2,
                               pr_nrendere OUT crapavt.nrendere%TYPE,                                       
                               pr_inpessoa OUT crapavt.inpessoa%TYPE,
                               pr_dtnascto OUT crapavt.dtnascto%TYPE,
                               pr_cdnacion OUT crapavt.cdnacion%TYPE,
                               pr_cdufddoc OUT crapavt.cdufddoc%TYPE,
                               pr_dtemddoc OUT crapavt.dtemddoc%TYPE,
                               pr_cdsexcto OUT crapavt.cdsexcto%TYPE,
                               pr_cdestcvl OUT crapavt.cdestcvl%TYPE,
                               pr_cdnatura OUT crapmun.idcidade%TYPE,
                               pr_dsnatura OUT crapnat.dsnatura%TYPE,
                               pr_nmmaecto OUT crapavt.nmmaecto%TYPE,
                               pr_nmpaicto OUT crapavt.nmpaicto%TYPE,
                               pr_inhabmen OUT crapavt.inhabmen%TYPE,
                               pr_dthabmen OUT crapavt.dthabmen%TYPE,  
                               pr_dscritic OUT VARCHAR2);
                                 
  
  -- Buscar dados da pessoa para utilização como avalista - Chamada progress
  PROCEDURE pc_ret_dados_aval_prog
                             ( pr_nrcpfcgc  IN crapttl.nrcpfcgc%TYPE,
                               pr_dsxmlret OUT CLOB,
                               pr_dscritic OUT crapcri.dscritic%TYPE);
                                                              
  
                                                                  
END CADA0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CADA0008 IS

  -- Buscar dados da pessoa para utilização como avalista
  PROCEDURE pc_ret_dados_aval( pr_nrcpfcgc     IN crapttl.nrcpfcgc%TYPE,
                               pr_nmdavali OUT crapavt.nmdavali%TYPE,
                               pr_tpdocava OUT crapavt.tpdocava%TYPE,
                               pr_nrdocava OUT crapavt.nrdocava%TYPE,
                               pr_nmconjug OUT crapavt.nmconjug%TYPE,
                               pr_nrcpfcjg OUT crapavt.nrcpfcjg%TYPE,
                               pr_tpdoccjg OUT crapavt.tpdoccjg%TYPE,
                               pr_nrdoccjg OUT crapavt.nrdoccjg%TYPE,
                               pr_dsendre1 OUT crapavt.dsendres##1%TYPE,
                               pr_dsendre2 OUT crapavt.dsendres##2%TYPE,
                               pr_nrfonres OUT crapavt.nrfonres%TYPE,
                               pr_dsdemail OUT crapavt.dsdemail%TYPE,
                               pr_nmcidade OUT crapavt.nmcidade%TYPE,
                               pr_cdufresd OUT crapavt.cdufresd%TYPE,
                               pr_nrcepend OUT crapavt.nrcepend%TYPE,
                               pr_dsnacion OUT crapnac.dsnacion%TYPE,
                               pr_vledvmto OUT crapavt.vledvmto%TYPE,
                               pr_vlrenmes OUT crapavt.vlrenmes%TYPE,
                               pr_complend OUT VARCHAR2,
                               pr_nrendere OUT crapavt.nrendere%TYPE,
                               pr_inpessoa OUT crapavt.inpessoa%TYPE,
                               pr_dtnascto OUT crapavt.dtnascto%TYPE,
                               pr_cdnacion OUT crapavt.cdnacion%TYPE,
                               pr_cdufddoc OUT crapavt.cdufddoc%TYPE,
                               pr_dtemddoc OUT crapavt.dtemddoc%TYPE,
                               pr_cdsexcto OUT crapavt.cdsexcto%TYPE,
                               pr_cdestcvl OUT crapavt.cdestcvl%TYPE,
                               pr_cdnatura OUT crapmun.idcidade%TYPE,
                               pr_dsnatura OUT crapnat.dsnatura%TYPE,
                               pr_nmmaecto OUT crapavt.nmmaecto%TYPE,
                               pr_nmpaicto OUT crapavt.nmpaicto%TYPE,
                               pr_inhabmen OUT crapavt.inhabmen%TYPE,
                               pr_dthabmen OUT crapavt.dthabmen%TYPE,                               
                               pr_dscritic OUT VARCHAR2) IS
    /* ..........................................................................
    --
    --  Programa : pc_ret_dados_aval
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana (AMcom)
    --  Data     : Outubro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados da pessoa para utilização como avalista
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/

    --> Retonar dados da pessoa
    CURSOR cr_pessoa IS
      SELECT a.nmpessoa,
             a.tppessoa,
             a.idpessoa
        FROM tbcadast_pessoa a
       WHERE a.nrcpfcgc       = pr_nrcpfcgc
         AND a.tpcadastro     > 2; -- Somente buscar intermediario ou completo
    rw_pessoa cr_pessoa%ROWTYPE;

    --> Retonar dados da pessoa fisica
    CURSOR cr_pessoa_fisica(pr_idpessoa NUMBER) IS
      SELECT b.tpdocumento,
             b.nrdocumento,
             b.cdnacionalidade,
             n.dsnacion,
             b.dtnascimento,
             d.nrcpf nrcpf_conjuge,
             d.nmpessoa nmpessoa_conjuge,
             d.tpdocumento tpdocumento_conjuge,
             d.nrdocumento nrdocumento_conjuge,
             e.nrcep,
             e.nmlogradouro,
             e.nrlogradouro,
             e.dscomplemento,
             e.nmbairro,
             f.dscidade,
             f.cdestado,
             i.nrtelefone,
             j.dsemail,
             nvl(g.vlrenda,0) + NVL(h.vlrenda,0) vlrenda,
             --             
             b.CDUF_ORGAO_EXPEDIDOR,
             b.DTEMISSAO_DOCUMENTO,
             b.tpsexo,
             b.CDESTADO_CIVIL,
             b.CDNATURALIDADE,
             t.dscidade dsnatura,
             ka.nmpessoa nmpessoa_mae,
             la.nmpessoa nmpessoa_pai,
             b.inhabilitacao_menor,
             b.dthabilitacao_menor
             
        FROM (SELECT idpessoa, SUM(x.vlrenda) vlrenda FROM tbcadast_pessoa_rendacompl x GROUP BY x.idpessoa) h,
             tbcadast_pessoa_email j,
             tbcadast_pessoa_telefone i,
             tbcadast_pessoa_renda g,
             crapmun f,
             tbcadast_pessoa_endereco e,
             vwcadast_pessoa_fisica d, -- Dados do conjuge
             tbcadast_pessoa_relacao c,
             tbcadast_pessoa_fisica b,
             crapnac n,        
             crapmun t,     
             --
             tbcadast_pessoa_relacao k, -- Mãe
             tbcadast_pessoa ka,
             tbcadast_pessoa_relacao l, -- Pai
             tbcadast_pessoa la
       WHERE b.idpessoa       = pr_idpessoa
         AND c.idpessoa  (+)  = b.idpessoa
         AND c.tprelacao (+)  = 1 -- Conjuge
         AND d.idpessoa (+)   = c.idpessoa_relacao
         AND e.idpessoa (+)   = b.idpessoa
         AND e.tpendereco (+) = 10 -- Residencial
         AND f.idcidade (+)   = e.idcidade
         AND g.idpessoa (+)   = b.idpessoa
         AND h.idpessoa (+)   = b.idpessoa
         AND i.idpessoa (+)   = b.idpessoa
         AND j.idpessoa (+)   = b.idpessoa
         AND n.cdnacion (+)   = b.cdnacionalidade
         AND t.idcidade (+)   = b.cdnaturalidade
         --
         AND k.idpessoa       = b.idpessoa
         AND k.tprelacao      = 4 -- Mãe
         AND ka.idpessoa      = k.idpessoa_relacao
         AND l.idpessoa       = b.idpessoa
         AND l.tprelacao      = 3 -- Pai
         AND la.idpessoa      = l.idpessoa_relacao
        ORDER BY i.tptelefone, i.nrseq_telefone, j.nrseq_email;
    rw_pessoa_fisica cr_pessoa_fisica%ROWTYPE;

    --> Retonar dados da pessoa juridica
    CURSOR cr_pessoa_juridica(pr_idpessoa NUMBER) IS
      SELECT e.nrcep,
             e.nmlogradouro,
             e.nrlogradouro,
             e.dscomplemento,
             e.nmbairro,
             f.dscidade,
             f.cdestado,
             i.nrtelefone,
             j.dsemail,
             nvl(g.vlrenda,0) + NVL(h.vlrenda,0) vlrenda
        FROM (SELECT idpessoa, SUM(x.vlrenda) vlrenda FROM tbcadast_pessoa_rendacompl x GROUP BY x.idpessoa) h,
             tbcadast_pessoa_email j,
             tbcadast_pessoa_telefone i,
             tbcadast_pessoa_renda g,
             crapmun f,
             tbcadast_pessoa_endereco e,
             tbcadast_pessoa_juridica b
       WHERE b.idpessoa       = pr_idpessoa
         AND e.idpessoa (+)   = b.idpessoa
         AND e.tpendereco (+) = 9 -- Comercial
         AND f.idcidade (+)   = e.idcidade
         AND g.idpessoa (+)   = b.idpessoa
         AND h.idpessoa (+)   = b.idpessoa
         AND i.idpessoa (+)   = b.idpessoa
         AND j.idpessoa (+)   = b.idpessoa
        ORDER BY i.tptelefone, i.nrseq_telefone, j.nrseq_email;
    rw_pessoa_juridica cr_pessoa_juridica%ROWTYPE;

  BEGIN

    --> Retonar dados da pessoa
    OPEN cr_pessoa;
    FETCH cr_pessoa INTO rw_pessoa;
    CLOSE cr_pessoa;

    IF rw_pessoa.tppessoa = 1 THEN
      --> retonar dados da pessoa fisica
      OPEN cr_pessoa_fisica(pr_idpessoa => rw_pessoa.idpessoa);
      FETCH cr_pessoa_fisica INTO rw_pessoa_fisica;
      IF cr_pessoa_fisica%FOUND THEN
        CLOSE cr_pessoa_fisica;

        pr_nmdavali := rw_pessoa.nmpessoa;

        pr_tpdocava := rw_pessoa_fisica.tpdocumento;
        pr_nrdocava := rw_pessoa_fisica.nrdocumento;
        pr_nmconjug := rw_pessoa_fisica.nmpessoa_conjuge;
        pr_nrcpfcjg := rw_pessoa_fisica.nrcpf_conjuge;
        pr_tpdoccjg := rw_pessoa_fisica.tpdocumento_conjuge;
        pr_nrdoccjg := rw_pessoa_fisica.nrdocumento_conjuge;
        pr_inpessoa := 1;

        pr_dsendre1 := rw_pessoa_fisica.nmlogradouro;
        pr_dsendre2 := rw_pessoa_fisica.nmbairro;

        pr_nrfonres := rw_pessoa_fisica.nrtelefone;
        pr_dsdemail := rw_pessoa_fisica.dsemail;

        pr_nmcidade := rw_pessoa_fisica.dscidade;

        pr_cdufresd := rw_pessoa_fisica.cdestado;

        pr_nrcepend := rw_pessoa_fisica.nrcep;

        pr_dsnacion := rw_pessoa_fisica.dsnacion;
        pr_vledvmto := 0;
        pr_vlrenmes := rw_pessoa_fisica.vlrenda;

        pr_complend := trim(rw_pessoa_fisica.dscomplemento);

        pr_nrendere := rw_pessoa_fisica.nrlogradouro;
        pr_dtnascto := rw_pessoa_fisica.dtnascimento;
        pr_cdnacion := rw_pessoa_fisica.cdnacionalidade;
        
        
        pr_cdufddoc := rw_pessoa_fisica.cduf_orgao_expedidor;
        pr_dtemddoc := rw_pessoa_fisica.dtemissao_documento;
        pr_cdsexcto := rw_pessoa_fisica.tpsexo;
        pr_cdestcvl := rw_pessoa_fisica.cdestado_civil;
        pr_cdnatura := rw_pessoa_fisica.cdnaturalidade;
        pr_dsnatura := rw_pessoa_fisica.dsnatura;
        pr_nmmaecto := rw_pessoa_fisica.nmpessoa_mae;
        pr_nmpaicto := rw_pessoa_fisica.nmpessoa_pai;
        pr_inhabmen := rw_pessoa_fisica.inhabilitacao_menor;
        pr_dthabmen := rw_pessoa_fisica.dthabilitacao_menor;

        
      ELSE
        CLOSE cr_pessoa_fisica;
      END IF;

    ELSE
      --> Retonar dados da pessoa juridica
      OPEN cr_pessoa_juridica(pr_idpessoa => rw_pessoa.idpessoa);
      FETCH cr_pessoa_juridica INTO rw_pessoa_juridica;

      IF cr_pessoa_juridica%FOUND THEN
        CLOSE cr_pessoa_juridica;
        pr_nmdavali := rw_pessoa.nmpessoa;
        pr_tpdocava := NULL;
        pr_nrdocava := NULL;
        pr_nmconjug := NULL;
        pr_nrcpfcjg := NULL;
        pr_tpdoccjg := NULL;
        pr_nrdoccjg := NULL;
        pr_dsendre1 := rw_pessoa_juridica.nmlogradouro;
        pr_dsendre2 := '';
        pr_nrfonres := rw_pessoa_juridica.nrtelefone;
        pr_dsdemail := rw_pessoa_juridica.dsemail;
        pr_nmcidade := rw_pessoa_juridica.dscidade;
        pr_cdufresd := rw_pessoa_juridica.cdestado;
        pr_nrcepend := rw_pessoa_juridica.nrcep;
        pr_dsnacion := NULL;
        pr_vledvmto := 0;
        pr_vlrenmes := rw_pessoa_juridica.vlrenda;
        pr_complend := rw_pessoa_juridica.dscomplemento;
        pr_nrendere := rw_pessoa_juridica.nrlogradouro;
        pr_inpessoa := 2;
        pr_dtnascto := NULL;
        pr_cdnacion := NULL;
      ELSE
        CLOSE cr_pessoa_juridica;
      END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    
      pr_nmconjug := NULL;
      pr_nrcpfcjg := NULL;
      pr_tpdoccjg := NULL;
      pr_nrdoccjg := NULL;
        
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_ret_dados_aval: ' ||
                     SQLERRM;
  END pc_ret_dados_aval;
  
  
  -- Buscar dados da pessoa para utilização como avalista - Chamada progress
  PROCEDURE pc_ret_dados_aval_prog
                             ( pr_nrcpfcgc  IN crapttl.nrcpfcgc%TYPE,
                               pr_dsxmlret OUT CLOB,
                               pr_dscritic OUT crapcri.dscritic%TYPE) IS
    /* ..........................................................................
    --
    --  Programa : pc_ret_dados_aval_prog
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana (AMcom)
    --  Data     : Outubro/2017.                   Ultima atualizacao:
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Buscar dados da pessoa para utilização como avalista - Chamada progress
    --
    --  Alteração :
    --
    --
    -- ..........................................................................*/
    -------> VARIAVEIS <-------
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(2000);
    
    vr_dstexto     VARCHAR2(32767);
		vr_string      VARCHAR2(32767);
    
    vr_nmdavali crapavt.nmdavali%TYPE;
    vr_tpdocava crapavt.tpdocava%TYPE;
    vr_nrdocava crapavt.nrdocava%TYPE;
    vr_nmconjug crapavt.nmconjug%TYPE;
    vr_nrcpfcjg crapavt.nrcpfcjg%TYPE;
    vr_tpdoccjg crapavt.tpdoccjg%TYPE;
    vr_nrdoccjg crapavt.nrdoccjg%TYPE;
    vr_dsendre1 crapavt.dsendres##1%TYPE;
    vr_dsendre2 crapavt.dsendres##2%TYPE;
    vr_nrfonres crapavt.nrfonres%TYPE;
    vr_dsdemail crapavt.dsdemail%TYPE;
    vr_nmcidade crapavt.nmcidade%TYPE;
    vr_cdufresd crapavt.cdufresd%TYPE;
    vr_nrcepend crapavt.nrcepend%TYPE;
    vr_dsnacion crapnac.dsnacion%TYPE;
    vr_vledvmto crapavt.vledvmto%TYPE;
    vr_vlrenmes crapavt.vlrenmes%TYPE;
    vr_complend VARCHAR2(500);
    vr_nrendere crapavt.nrendere%TYPE;
    vr_inpessoa crapavt.inpessoa%TYPE;
    vr_dtnascto crapavt.dtnascto%TYPE;
    vr_cdnacion crapavt.cdnacion%TYPE;
    vr_cdufddoc crapavt.cdufddoc%TYPE;
    vr_dtemddoc crapavt.dtemddoc%TYPE;
    vr_cdsexcto crapavt.cdsexcto%TYPE;
    vr_cdestcvl crapavt.cdestcvl%TYPE;
    vr_cdnatura crapmun.idcidade%TYPE;
    vr_dsnatura crapnat.dsnatura%TYPE;
    vr_nmmaecto crapavt.nmmaecto%TYPE;
    vr_nmpaicto crapavt.nmpaicto%TYPE;
    vr_inhabmen crapavt.inhabmen%TYPE;
    vr_dthabmen crapavt.dthabmen%TYPE; 
    
    
    

  BEGIN
  
    -- Buscar dados da pessoa para utilização como avalista
    pc_ret_dados_aval( pr_nrcpfcgc => pr_nrcpfcgc,
                       pr_nmdavali => vr_nmdavali,
                       pr_tpdocava => vr_tpdocava,
                       pr_nrdocava => vr_nrdocava,
                       pr_nmconjug => vr_nmconjug,
                       pr_nrcpfcjg => vr_nrcpfcjg,
                       pr_tpdoccjg => vr_tpdoccjg,
                       pr_nrdoccjg => vr_nrdoccjg,
                       pr_dsendre1 => vr_dsendre1,
                       pr_dsendre2 => vr_dsendre2,
                       pr_nrfonres => vr_nrfonres,
                       pr_dsdemail => vr_dsdemail,
                       pr_nmcidade => vr_nmcidade,
                       pr_cdufresd => vr_cdufresd,
                       pr_nrcepend => vr_nrcepend,
                       pr_dsnacion => vr_dsnacion,
                       pr_vledvmto => vr_vledvmto,
                       pr_vlrenmes => vr_vlrenmes,
                       pr_complend => vr_complend,
                       pr_nrendere => vr_nrendere,
                       pr_inpessoa => vr_inpessoa,
                       pr_dtnascto => vr_dtnascto,
                       pr_cdnacion => vr_cdnacion,
                       pr_cdufddoc => vr_cdufddoc,
                       pr_dtemddoc => vr_dtemddoc,
                       pr_cdsexcto => vr_cdsexcto,
                       pr_cdestcvl => vr_cdestcvl,
                       pr_cdnatura => vr_cdnatura,
                       pr_dsnatura => vr_dsnatura,
                       pr_nmmaecto => vr_nmmaecto,
                       pr_nmpaicto => vr_nmpaicto,
                       pr_inhabmen => vr_inhabmen,
                       pr_dthabmen => vr_dthabmen,  
                       pr_dscritic => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_nmdavali IS NOT NULL THEN
      -- Criar documento XML
      dbms_lob.createtemporary(pr_dsxmlret, TRUE);
      dbms_lob.open(pr_dsxmlret, dbms_lob.lob_readwrite);
  				
      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => pr_dsxmlret,
                              pr_texto_completo => vr_dstexto,
                              pr_texto_novo     => '<root>');
  				
      vr_string := '<avalista>' || 
                      '<nmdavali>'||    vr_nmdavali  ||'</nmdavali>'||
                      '<tpdocava>'||    vr_tpdocava  ||'</tpdocava>'||
                      '<nrdocava>'||    vr_nrdocava  ||'</nrdocava>'||
                      '<nmconjug>'||    vr_nmconjug  ||'</nmconjug>'||
                      '<nrcpfcjg>'||    vr_nrcpfcjg  ||'</nrcpfcjg>'||
                      '<tpdoccjg>'||    vr_tpdoccjg  ||'</tpdoccjg>'||
                      '<nrdoccjg>'||    vr_nrdoccjg  ||'</nrdoccjg>'||
                      '<dsendre1>'||    vr_dsendre1  ||'</dsendre1>'||
                      '<dsendre2>'||    vr_dsendre2  ||'</dsendre2>'||
                      '<nrfonres>'||    vr_nrfonres  ||'</nrfonres>'||
                      '<dsdemail>'||    vr_dsdemail  ||'</dsdemail>'||
                      '<nmcidade>'||    vr_nmcidade  ||'</nmcidade>'||
                      '<cdufresd>'||    vr_cdufresd  ||'</cdufresd>'||
                      '<nrcepend>'||    vr_nrcepend  ||'</nrcepend>'||
                      '<dsnacion>'||    vr_dsnacion  ||'</dsnacion>'||
                      '<vledvmto>'||    vr_vledvmto  ||'</vledvmto>'||
                      '<vlrenmes>'||    vr_vlrenmes  ||'</vlrenmes>'||
                      '<complend>'||    vr_complend  ||'</complend>'||
                      '<nrendere>'||    vr_nrendere  ||'</nrendere>'||
                      '<inpessoa>'||    vr_inpessoa  ||'</inpessoa>'||
                      '<dtnascto>'||    to_char(vr_dtnascto,'DD/MM/RRRR')  ||'</dtnascto>'||
                      '<cdnacion>'||    vr_cdnacion  ||'</cdnacion>'||   
                      '<cdufddoc>'||    vr_cdufddoc  ||'</cdufddoc>'||   
                      '<dtemddoc>'||    vr_dtemddoc  ||'</dtemddoc>'||   
                      '<cdsexcto>'||    vr_cdsexcto  ||'</cdsexcto>'||   
                      '<cdestcvl>'||    vr_cdestcvl  ||'</cdestcvl>'||   
                      '<cdnatura>'||    vr_cdnatura  ||'</cdnatura>'||   
                      '<dsnatura>'||    vr_dsnatura  ||'</dsnatura>'||   
                      '<nmmaecto>'||    vr_nmmaecto  ||'</nmmaecto>'||   
                      '<nmpaicto>'||    vr_nmpaicto  ||'</nmpaicto>'||   
                      '<inhabmen>'||    vr_inhabmen  ||'</inhabmen>'||   
                      '<dthabmen>'||    to_char(vr_dthabmen,'DD/MM/RRRR')  ||'</dthabmen>'||                                            
                   '</avalista>';
  						
      -- Escrever no XML
      gene0002.pc_escreve_xml(pr_xml            => pr_dsxmlret,
                              pr_texto_completo => vr_dstexto,
                              pr_texto_novo     => vr_string,
                              pr_fecha_xml      => FALSE);
  				
      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => pr_dsxmlret,
                              pr_texto_completo => vr_dstexto,
                              pr_texto_novo     => '</root>',
                              pr_fecha_xml      => TRUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
          
        
      -- Montar descrição de erro não tratado
      pr_dscritic := 'Erro não tratado na pc_ret_dados_aval: ' ||
                     SQLERRM;
  END pc_ret_dados_aval_prog;
  
  
  
END;
/
