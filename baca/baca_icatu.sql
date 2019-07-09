-- Created on 05/06/2019 by F0030248 
declare 
  -- Local variables here
  i integer;
  vr_dslobdev      CLOB;
  vr_dsbufdev      VARCHAR2(32700);  
  vr_dscritic      VARCHAR2(1000);
  vr_nrseq         NUMBER(10) := 1;
  vr_qtdreg01      NUMBER(10) := 0;
  vr_flgdigok1     BOOLEAN;
  vr_nrcalcul      NUMBER;
  vr_conta         VARCHAR2(10);
  vr_dvconta       VARCHAR2(1);
  vr_agencia       VARCHAR2(5);
  vr_dvagencia     VARCHAR2(1);
  vr_nrdapoli      VARCHAR(7);
  vr_modulo        VARCHAR2(1);
  vr_sub           VARCHAR2(3);
  vr_cdcooper      crapcop.cdcooper%TYPE := 8;

  CURSOR cr_crapseg (pr_cdcooper IN crapseg.cdcooper%TYPE) IS  
    SELECT seg.rowid    crapseg_rowid
         , wseg.nmdsegur
         , wseg.nrcpfcgc
         , seg.cdcooper
         , seg.tpseguro
         , seg.cdsegura
         , SEG.cdsitseg
         , ass.cdagenci
         , seg.nrdconta
         , seg.nrctrseg
         , seg.dtinivig
         , seg.dtfimvig
         , seg.dtcancel
         , seg.vlpreseg * 100 vlpreseg
         , seg.dtmvtolt
         , seg.qtprepag
         , wseg.dtprideb
         , seg.qtparcel
         , seg.tpplaseg
         , seg.progress_recid
         , nvl(trim(seg.nmbenvid##1),ass.nmprimtl) nmbenvid##1
         , ass.nmprimtl 
         , ass.nrcpfcgc cpf_correntista
         , DECODE(ass.inpessoa,1,'F','J') tppessoa
         
         , ( SELECT sys.stragg(to_char(tfc.nrtelefo))
               FROM craptfc tfc
              WHERE tfc.cdcooper = seg.cdcooper
                AND tfc.nrdconta = seg.nrdconta
                AND tfc.prgqfalt = 'I'
                AND tfc.tptelefo = 2 -- celular
                AND ROWNUM = 1
            ) num_celular
            
         , ( SELECT sys.stragg(to_char(tfc.nrdddtfc))
               FROM craptfc tfc
              WHERE tfc.cdcooper = seg.cdcooper
                AND tfc.nrdconta = seg.nrdconta
                AND tfc.prgqfalt = 'I'
                AND tfc.tptelefo = 2 -- celular
                AND ROWNUM = 1
            ) ddd_celular                    

         , ( SELECT sys.stragg(to_char(tfc.nrtelefo))
               FROM craptfc tfc
              WHERE tfc.cdcooper = seg.cdcooper
                AND tfc.nrdconta = seg.nrdconta
                AND tfc.prgqfalt = 'A'
                AND tfc.tptelefo = 1 -- residencial
                AND ROWNUM = 1
            ) num_fone
            
         , ( SELECT sys.stragg(to_char(tfc.nrdddtfc))
               FROM craptfc tfc
              WHERE tfc.cdcooper = seg.cdcooper
                AND tfc.nrdconta = seg.nrdconta
                AND tfc.prgqfalt = 'A'
                AND tfc.tptelefo = 1 -- residencial
                AND ROWNUM = 1
            ) ddd_fone
            
         , NVL(( SELECT 'S'
               FROM craptfc tfc
              WHERE tfc.cdcooper = seg.cdcooper
                AND tfc.nrdconta = seg.nrdconta
                AND tfc.prgqfalt = 'I'
                AND tfc.tptelefo = 2 -- celular
                AND ROWNUM = 1
            ),'N') flg_fone            
            
         , wseg.dsendres endereco
         , wseg.nmcidade
         , wseg.nrcepend
         , wseg.cdufresd
         , wseg.complend
         , wseg.nmbairro
         , decode(wseg.nrendres,0,NULL,wseg.nrendres) nrendres
         , cop.cdagectl
         , v.nrdocumento
         , v.dtemissao_documento
         , wseg.dtnascsg dtnascimento
         --, v.dtnascimento
         , DECODE(wseg.cdsexosg,1,'M','F') sexo
         , org.cdorgao_expedidor
         , (SELECT trim(e.dsemail)
              FROM TBCADAST_PESSOA_EMAIL e
             WHERE e.idpessoa = v.idpessoa
               AND e.nrseq_email = (SELECT MAX(nrseq_email) FROM TBCADAST_PESSOA_EMAIL m
                                     WHERE m.idpessoa = v.idpessoa)) email            
                                     
         ,NVL((SELECT 'S'
              FROM TBCADAST_PESSOA_EMAIL e
             WHERE e.idpessoa = v.idpessoa
               AND e.nrseq_email = (SELECT MAX(nrseq_email) FROM TBCADAST_PESSOA_EMAIL m
                                     WHERE m.idpessoa = v.idpessoa)),'N') flg_email
         , DECODE(v.cdestado_civil, 1, '1' -- solteiro
                                  , 2, '2' -- casado
                                  , 3, '2' -- casado
                                  , 4, '2' -- casado
                                  , 8, '2' -- casado
                                  , 9, '2' -- casado
                                  ,10, '2' -- casado
                                  , 7, '3' -- divorciado
                                  , 5, '4' -- viuvo 
                                  ,'5')    -- outros
                                  estcivil
         , CASE WHEN vrel.nrcpf <> wseg.nrcpfcgc THEN vrel.nmpessoa ELSE NULL END nome_conjuge
         , CASE WHEN vrel.nrcpf <> wseg.nrcpfcgc THEN to_char(vrel.dtnascimento,'DDMMRRRR') ELSE NULL END dtnasc_conjuge
         , CASE WHEN vrel.nrcpf <> wseg.nrcpfcgc THEN vrel.nrcpf ELSE NULL END cpf_conjuge
         , wseg.vlseguro * 100 vlseguro
         , wseg.vlbenefi * 100 vlbenefi
         , tsg.dsmorada
         , tsg.vlmorada
      FROM crapseg seg
         , crapass ass
         , crapcop cop
         , crawseg wseg
         , vwcadast_pessoa_fisica v
         , tbcadast_pessoa_relacao rel    
         , vwcadast_pessoa_fisica vrel
         , tbgen_orgao_expedidor org
         , gnetcvl cvl
         , craptsg tsg
     WHERE seg.cdcooper  = pr_cdcooper
--       AND seg.cdsegura  = pr_cdsegura
--       AND NVL(seg.dtcancel,TO_DATE('01/01/1900','DD/MM/YYYY')) <> seg.dtmvtolt
       AND seg.tpseguro = 3 -- Seguro de vida
       AND seg.cdsitseg  = 1
       AND ass.cdcooper = seg.cdcooper
       AND ass.nrdconta = seg.nrdconta
       AND v.nrcpf = ass.nrcpfcgc
       AND org.idorgao_expedidor = v.idorgao_expedidor
       AND cop.cdcooper = ass.cdcooper
       AND seg.cdcooper = wseg.cdcooper (+)
       AND seg.nrdconta = wseg.nrdconta (+)
       AND seg.nrctrseg = wseg.nrctrseg (+)
       AND cvl.cdestcvl = v.cdestado_civil
       AND rel.idpessoa (+) = v.idpessoa
       AND rel.tprelacao (+) = 1 -- conjuge
       AND vrel.idpessoa (+) = rel.idpessoa_relacao   
       AND tsg.cdcooper = seg.cdcooper
       AND tsg.tpseguro = seg.tpseguro
       AND tsg.tpplaseg = seg.tpplaseg           
     ORDER BY seg.progress_recid; 
     
  /* Calcular o dígito verificador da conta */
  FUNCTION fn_calc_digito(pr_nrcalcul IN OUT NUMBER                               --> Número da conta
                         ,pr_reqweb   IN BOOLEAN DEFAULT FALSE) RETURN BOOLEAN IS --> Identificador se a requisição é da Web
  BEGIN
    -- ..........................................................................
    -- Programa: fn_calc_digito                  Antigo: Fontes/digfun.p
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Deborah/Edson
    -- Data    : Setembro/91                     Ultima atualizacao: 09/12/2005
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que chamado por outros programas.
    -- Objetivo  : Calcular e conferir o digito verificador pelo modulo onze.
    --             Disponibilizar nro calculado digito "X" (Mirtes)
    --
    --   Alteracoes: 09/12/2005 - Eliminada variavel glb_nrcalcul_c (Magui)..
    --               13/12/2012 - Conversão Progress --> Oracle PLSQL (Alisson - AMcom)
    --               29/05/2013 - Incluído parâmetro e consistência para origem da Web (Petter - Supero)
    -- .............................................................................
    DECLARE
      --Variaveis Locais
      vr_digito   INTEGER:= 0;
      vr_posicao  INTEGER:= 0;
      vr_peso     INTEGER:= 9;
      vr_calculo  INTEGER:= 0;
      vr_resto    INTEGER:= 0;

    BEGIN
      -- Trata conta da CONCREDI na CEF
      /*IF pr_nrcalcul = gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'CTA_CONCREDI_CEF') AND pr_reqweb = FALSE THEN
        pr_nrcalcul:= 30035008;
        RETURN(TRUE);
      ELSIF pr_nrcalcul = gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'CTA_CONCREDI_CEF_INTEGRA') AND pr_reqweb = TRUE THEN
        RETURN(TRUE);
      END IF;*/

      -- Se o tamanho da conta for < 2
      IF LENGTH(pr_nrcalcul) < 2 THEN
        return(FALSE);
      END IF;

      -- Percorrer cada numero da conta ignorando o ultimo digito
      FOR idx IN REVERSE 1..(LENGTH(pr_nrcalcul)-1) LOOP
        vr_calculo:= vr_calculo + (TO_NUMBER(SUBSTR(pr_nrcalcul,idx,1)) * vr_peso);
        --Diminuir o peso para calcular proximo
        vr_peso:= vr_peso-1;
        IF vr_peso=1 THEN
          vr_peso:= 9;
        END IF;
      END LOOP;

      --Calcular o resto pelo Modulo 11
      vr_resto:= MOD(vr_calculo,11);

      --Atribuir o valor do resto para o digito
      IF vr_resto > 9 THEN
        vr_digito:= 0;
      ELSE
        vr_digito:= vr_resto;
      END IF;

      --Comparar o digito calculado com o do parametro
      IF vr_digito <> TO_NUMBER(SUBSTR(pr_nrcalcul,LENGTH(pr_nrcalcul),1)) THEN
        --Atribuir ao parametro o digito correto
        pr_nrcalcul:= TO_NUMBER(SUBSTR(pr_nrcalcul,1,LENGTH(pr_nrcalcul)-1)||vr_digito);
        RETURN(FALSE);
      ELSE
        RETURN(TRUE);
      END IF;
    END;
  END fn_calc_digito;      
  
  -- Subrotina para escrever texto na variável CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,  --> Variável CLOB onde será incluído o texto
                           pr_texto_completo in out nocopy varchar2,  --> Variável para armazenar o texto até ser incluído no CLOB
                           pr_texto_novo in varchar2,  --> Texto a incluir no CLOB
                           pr_fecha_xml in boolean default false) is  --> Flag indicando se é o último texto no CLOB
    /*----------------------------------------------------------
      Programa: pc_escreve_xml
      Autor: Daniel Dallagnese (Supero)
      Data: 11/02/2014                               Última atualização: 11/02/2014

      Objetivo: Melhorar a performance dos programas que necessitam escrever muita
                informação em variável CLOB. Exemplo de uso: PC_CRPS086.

      Utilização: Quando houver necessidade de incluir informações em um CLOB, deve-se
                  declarar, instanciar e abrir o CLOB no programa chamador, e passá-lo
                  no parâmetro PR_XML para este procedimento, juntamente com o texto que
                  se deseja incluir no CLOB. Para finalizar a geração do CLOB, deve-se
                  incluir também o parâmetro PR_FECHA_XML com o valor TRUE. Ao final, no
                  programa chamador, deve-se fechar o CLOB e liberar a memória utilizada.

      Alterações: 17/10/2017 - Retirado pc_set_modulo
                              (Ana - Envolti - Chamado 776896)
                  18/10/2017 - Incluído pc_set_modulo com novo padrão
                               (Ana - Envolti - Chamado 776896)
    ----------------------------------------------------------*/
    procedure pc_concatena(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy varchar2,
                           pr_texto_novo varchar2) is
      -- Prodimento para concatenar os textos em um varchar2 antes de incluir no CLOB,
      -- ganhando performance. Somente grava no CLOB quando estourar a capacidade da variável.
    begin
      -- Tenta concatenar o novo texto após o texto antigo (variável global da package)
      pr_texto_completo := pr_texto_completo || pr_texto_novo;
    exception when value_error then
      if pr_xml is null then
        pr_xml := pr_texto_completo;
      else
        dbms_lob.writeappend(pr_xml, length(pr_texto_completo), pr_texto_completo);
        pr_texto_completo := pr_texto_novo;
      end if;
    end;
    --
  begin
    -- Incluir nome do módulo logado - Chamado 660322 18/07/2017
    --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_escreve_xml');
    -- Concatena o novo texto
    pc_concatena(pr_xml, pr_texto_completo, pr_texto_novo);
    -- Se for o último texto do arquivo, inclui no CLOB
    if pr_fecha_xml then
      dbms_lob.writeappend(pr_xml, length(pr_texto_completo), pr_texto_completo);
      pr_texto_completo := null;
    end if;
    -- Alterado pc_set_modulo da procedure - Chamado 776896 - 18/10/2017
    --GENE0001.pc_set_modulo(pr_module =>  NULL, pr_action => NULL);
  end;
  
  
  procedure pc_print(pr_msg VARCHAR2, vr_close BOOLEAN DEFAULT FALSE) is
  begin
    -- Inicilizar as informacoes do XML
    pc_escreve_xml(vr_dslobdev,vr_dsbufdev,pr_msg || CHR(13) || CHR(10), vr_close);    
  end pc_print;
  
BEGIN
  
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_dslobdev, TRUE);
  dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
  vr_dsbufdev := NULL;
  

  
  pc_print('MATRICULA OU Nº CERTIFICADO ANTERIOR;' || 
           'NOME;' || 
           'DATA DE NASC;' || 
           'CPF;' || 
           'Estado Civil;' || 
           'SEXO;' || 
           'NOME CONJUGE;' || 
           'DT NASC CONJUGE;' || 
           'CPF CONJUGE;' || 
           'TIPO DE LOGRADOURO;' || 
           'ENDERECO;' || 
           'Nº ENDERECO;' || 
           'COMPLEMENTO;' || 
           'BAIRRO;' || 
           'CIDADE;' || 
           'UF;' || 
           'CEP;' || 
           'DDD;' || 
           'TELEFONE;' || 
           'DDD CELULAR;' || 
           'TELEFONE CELULAR;' || 
           'EMAIL;' || 
           'CAPITAL TITULAR VG;' || 
           'CAPITAL CONJUGE VG;' || 
           'PREMIO TOTAL VG;' || 
           'BANCO;' || 
           'AGÊNCIA;' || 
           'DV AGÊNCIA;' || 
           'CONTA CORRENTE;' || 
           'DV CONTA CORRENTE;' || 
           'CÓDIGO MÓDULO;' || 
           'CÓDIGO SUB;' || 
           'CÓDIGO PDV (PA);' || 
           'NOME CORRENTISTA;' || 
           'CPF CORRENTISTA;' || 
           'DATA VENCIMENTO;'  ||
           'DATA INICIO VIGENCIA');
  
  FOR rw IN cr_crapseg (pr_cdcooper => vr_cdcooper) LOOP

    vr_nrseq := vr_nrseq + 1;
    vr_qtdreg01 := vr_qtdreg01 + 1;
    
    -- Calcula primeiro digito de controle
    vr_nrcalcul := to_number(to_char(rw.cdagectl,'fm0000') || '0');           
    vr_flgdigok1 := fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
    vr_agencia := to_char(vr_nrcalcul,'fm00000');
    vr_dvagencia := SUBSTR(vr_agencia,LENGTH(vr_agencia)-1,1);
    vr_agencia := SUBSTR(vr_agencia,1,4);
    
    vr_conta   := to_char(rw.nrdconta);
    vr_dvconta := SUBSTR(vr_conta,LENGTH(vr_conta),1);
    vr_conta   := SUBSTR(vr_conta,1,LENGTH(vr_conta)-1);
    
    IF rw.tpplaseg IN (11, 15, 21, 31, 41, 51 , 61) THEN
      vr_nrdapoli := '6142149';
    ELSIF rw.tpplaseg IN (12, 16, 22, 32, 42, 52, 62) THEN
      vr_nrdapoli := '6077071';
    ELSIF rw.tpplaseg IN (13, 17, 23, 33, 43, 53, 63) THEN
      vr_nrdapoli := '6077070';
    ELSIF rw.tpplaseg IN (14, 18, 24, 34, 44, 54, 64) THEN
      vr_nrdapoli := '6077069';
    END IF;
    
    CASE trim(rw.dsmorada)
      WHEN 'M + IPA'                           THEN vr_modulo := '2';
      WHEN 'M + IPA + IFDP'                    THEN vr_modulo := '3';
      WHEN 'M + IPA + IFDP + CONJUGE + FILHOS' THEN vr_modulo := '4';
      WHEN 'M + IPA + IFPD'                    THEN vr_modulo := '3';
      WHEN 'M + IPA + IFPD + CONJUGE + FILHOS' THEN vr_modulo := '4';
      WHEN 'M+IPA'                             THEN vr_modulo := '2';
      WHEN 'M+IPA+IFPD'                        THEN vr_modulo := '3';
      WHEN 'M+IPA+IFPD+CONJUGE+FILHOS'         THEN vr_modulo := '4';
      WHEN 'MA + IPA'                          THEN vr_modulo := '1';
      WHEN 'MA+IPA'                            THEN vr_modulo := '1';
    END CASE;
    
  CASE rw.cdcooper 
    WHEN  1 THEN vr_sub := '013';
    WHEN  2 THEN vr_sub := '008';
    WHEN  5 THEN vr_sub := '001';
    WHEN  6 THEN vr_sub := '010';
    WHEN  7 THEN vr_sub := '002';
    WHEN  8 THEN vr_sub := '009';
    WHEN  9 THEN vr_sub := '006';
    WHEN 10 THEN vr_sub := '003';
    WHEN 11 THEN vr_sub := '004';
    WHEN 12 THEN vr_sub := '011';
    WHEN 13 THEN vr_sub := '012';
    WHEN 14 THEN vr_sub := '005';
    WHEN 16 THEN vr_sub := '007';                    
  END CASE;            
    
    
  pc_print( vr_nrdapoli                         || ';' || -- MATRICULA OU Nº CERTIFICADO ANTERIOR;
           substr(rw.nmdsegur,1,60)             || ';' || -- NOME
           to_char(rw.dtnascimento,'DDMMRRRR')  || ';' || -- DATA DE NASC
           to_char(rw.nrcpfcgc)                 || ';' || -- CPF
           rw.estcivil                          || ';' || -- Estado Civil
           rw.sexo                              || ';' || -- SEXO
           rw.nome_conjuge                      || ';' || -- NOME CONJUGE
           rw.dtnasc_conjuge                    || ';' || -- DT NASC CONJUGE
           rw.cpf_conjuge                       || ';' || -- CPF CONJUGE
           ' '                                  || ';' || -- tipo de logradouro
           substr(rw.endereco,1,40)             || ';' || -- ENDERECO
           to_char(rw.nrendres)                 || ';' || -- Nº ENDERECO           
           substr(rw.complend,1,20)              || ';' || -- COMPLEMENTO
           rw.nmbairro                          || ';' || -- BAIRRO
           substr(rw.nmcidade,1,20)              || ';' || -- CIDADE
           rw.cdufresd                          || ';' || -- UF
           to_char(rw.nrcepend,'fm00000000')    || ';' || -- CEP
           rw.ddd_fone                          || ';' || -- DDD
           rw.num_fone                          || ';' || -- TELEFONE
           rw.ddd_celular                       || ';' || -- DD CELULAR
           rw.num_celular                       || ';' || -- TELEFONE CELULAR
           rw.email                             || ';' || -- EMAIL
           to_char(rw.vlseguro)                 || ';' || -- 'CAPITAL TITULAR VG;' || 
           to_char(rw.vlbenefi)                 || ';' || -- 'CAPITAL CONJUGE VG;' || 
           to_char(rw.vlpreseg)                 || ';' || -- 'PREMIO TOTAL VG;' || 
           '085'                                || ';' || -- 'BANCO;' || 
           vr_agencia                           || ';' || -- 'AGÊNCIA;' || 
           vr_dvagencia                         || ';' || -- 'DV AGÊNCIA;' || 
           vr_conta                             || ';' || -- 'CONTA CORRENTE;' || 
           vr_dvconta                           || ';' || -- 'DV CONTA CORRENTE;' || 
           vr_modulo                            || ';' || -- 'CÓDIGO MÓDULO;' || 
           vr_sub                               || ';' || -- 'CÓDIGO SUB;' || 
           vr_sub || to_char(rw.cdagenci,'fm000') || ';' || -- 'CÓDIGO PDV (PA);' || 
           SUBSTR(rw.nmprimtl,1,40)             || ';' || -- 'NOME CORRENTISTA;' || 
           LPAD(to_char(rw.cpf_correntista),11,'0')    || ';' || -- CPF CORRENTISTA;' || 
           to_char(rw.dtprideb,'DD') || '092019'  || ';' || -- 'DATA VENCIMENTO';
           '01092019'                                     -- 'DATA INICIO VIGENCIA'
    );
    
    /*
    
    
    pc_print('01' ||                              -- Tipo de Registro (Constante ‘01’)
           lpad(to_char(vr_nrseq),9,'0') ||       -- Número Sequencial do Registro
           lpad(to_char(rw.nrctrseg), 11, '0') || -- "Número do Documento - (EESSSPPPPPP)
                                                  -- EE => Empresa     SSS => Sucursal     PPPPPP => Num. Proposta"
           lpad(to_char(rw.nrctrseg),  6, '0') || -- "Número da Apólice a ser endossada
                                                  -- (Caso seja proposta de apólice enviar ZEROS)"
           LPAD('0', 2, '0')                   || -- Codigo da Origem
           'N'                                 || -- Flag Numero Reserva (‘S’/’N’)
           LPAD(' ', 5, ' ')                   || -- Espaço Disponível 
           RPAD(substr(rw.nmprimtl,1,40), 40, ' ') || -- Nome do Segurado
           LPAD(to_char(rw.nrcpfcgc),14,'0')   || -- CGC/CPF do Segurado
           rw.tppessoa                         || -- Tipo de Pessoa ( ‘F’ = Física , ‘J’ = Jurídica, ‘I’ = Isento )
           Rpad(rw.nmbenvid##1, 40, ' ')       || -- Nome do Beneficiário
           lpad(to_char(rw.dtinivig,'DDMMYY'),6,' ') || -- Data de Início de Vigência
           lpad(to_char(rw.dtfimvig,'DDMMYY'),6,' ') || -- Data de Início de Vigência            
           'N'                                 || -- Indicador de Renovação (S/N)
           LPAD('0', 6, '0')                   || -- Número da Apólice Anterior (Somente para casos de renovação e Endosso)
           LPAD(' ', 5, ' ')                   || -- Espaço Disponível
           RPAD('R$', 4, ' ')                  || -- Código da Moeda Original (SIGLA)
           '085'                               || -- Código do Banco - Carga Inicial
           '01'                                || -- Quantidade de Parcelas
           LPAD('100', 12, '0')                || -- Percentual de Cosseguro nossa parte (se 100 = não tem cosseguro)   
           LPAD('0', 15, '0')                  || -- Valor do Adicional de Fracionamento
           LPAD('0', 12, '0')                  || -- Percentual de Agravamento/Desconto
           LPAD(to_char(rw.vlpreseg,'fm999999999999.90'), 15, '0') ||      -- Valor de Prêmio Líquido Total
           LPAD(to_char(rw.vlpreseg * 12,'fm999999999999.90'), 15, '0') || -- Valor de Prêmio Anual Total
           RPAD('0', 15, '0')                  || -- Valor do Custo de Apólice
           RPAD('0', 15, '0')                  || -- Valor do IOF
           'N'                                 || -- Cód. Modo de Pagamento (‘N’ormal, ‘P’ré-fixado)
           '1'                                 || -- Cód. do Tipo de Pagto ( 1 = Sem antecipação , 2 = Antecipado )
           rpad(nvl(rw.fone, ' '), 12, ' ')              || -- Telefone do Segurado
           '000000'                            || -- Data de Ativação Vencimento (somente para CNH)
           LPAD(' ', 12, ' ')                  || -- Espaço Disponível
           RPAD(substr(rw.endereco,1,40),40,' ') || -- Endereço do Segurado ( Incluindo o número )
           RPAD(SUBSTR(rw.nmcidade,1,20),20,' ') || -- Cidade do Segurado
           to_char(rw.nrcepend,'fm00000000')  || -- CEP do Segurado
           rpad(SUBSTR(rw.cdufresd,1,2),2,' ') || -- UF do Segurado
           RPAD(' ', 7, ' ')                   || -- Código do Segurado – BRANCOS	Texto[007]
           '000'                               || -- Código da Carteira (Caso seja proposta genérica enviar "999")	Texto[003]
           '00'                                || -- Código da Agência/Franquia/Filial – ZEROS	Inteiro[002]
           RPAD('0',11,'0')                    || -- "Numero da Proposta do Corretor (EESSSCCCCCC)
                                                  -- EE-Empresa    SSS-Sucursal    CCCCCC-Num. Proposta
                                                  -- (Caso seja proposta genérica enviar ZEROS)"	Inteiro[011]
           rpad(' ', 5, ' ')                   || -- Espaço Disponível	Texto[005]
           ' '                                 || -- Identificador de cancelamento de Apólice ou Endosso (A/E)	Texto[001]
           ' '                                 || -- "Motivo do Cancelamento
                                                  -- 1 = Falta de Pagto., 2 = Solicit. do Segurado, 3 = Solicit. da Cia"	Texto[001]
           'D'                                 || -- Tipo de Cobrança  S-Sem Registro / R=Registrada / D=Débito / P=Cheque / C=Cartao Credito	Texto[001]
           rpad(' ', 21, ' ')                  || -- Espaço Disponível	Texto[021]
           rpad('0', 7, '0')                   || -- Código Matricula 2	Inteiro[007]
           'N'                                 || -- Flag Indicador de PRO-RATA (s/n)	Texto[001]
           'N'                                 || -- Flag Indicador de Data Fixa (s/n)	Texto[001]
           to_char(rw.dtprideb,'DD') || '0819' || -- Data de Vencimento da 1ª  parcela	Data
           rpad(' ', 19, ' ')                  || -- No. do Cartão (sem espaços e caracteres separadores)	Texto[019]
           lpad(SUBSTR(vr_conta,1,LENGTH(vr_conta)-1),11,'0')   || -- Número da Conta p/ Débito	Texto[011]
           lpad(to_char(rw.cdagectl),4,'0')    || -- Número da Agência p/ Débito	Texto[004]
           lpad(vr_dvconta,1,'0')              || -- Dígito Verificador da Conta p/ Débito	Texto[001]
           lpad(vr_dvagencia,1,'0')            || -- Dígito Verificador da Agência p/ Débito	Texto[001]
           '1'                                 || -- "Tipo de Operação (1-Apólice, 2-Renovação, 3-Endosso, 4-Canc. Endosso, 5-Canc. Apólice, 6-Endosso s/ Mov)"	Texto[001]
           ' '                                 || -- Flag Prêmio Mínimo	Texto[001]
           lpad(' ', 8, ' ')                   || -- Código da Versão	Texto[008]
           '00'                                || -- Empresa da Apólice Anterior	Inteiro[002]
           '00'                                || -- Sucursal da Apólice Anterior	Inteiro[002]
           lpad(' ', 3, ' ')                   || -- Carteira da Apólice Anterior	Texto[003]
           lpad('0', 2, '0')                   || -- Empresa da Proposta	Inteiro[002]
           lpad('0', 2, '0')                   || -- Sucursal da Proposta	Inteiro[002]
           lpad(' ', 3, ' ')                   || -- Carteira da Proposta	Texto[003]
           lpad('0', 6, '0')                   || -- Numero da Proposta	Inteiro[006]
           rpad(rw.nrdocumento,10,' ')         || -- Numero do Documeto de Identidade (RG)	Texto[010]
           rpad(to_char(rw.dtemissao_documento, 'DDMMYY'), 6, ' ')     || -- Data de Emissão do Documento (RG)	DATA 
           rpad(rw.cdorgao_expedidor, 6, ' ')  || -- Órgão Emissor do Documento (RG)	Texto[006]
           rpad(to_char(rw.nrendres), 5, ' ')  || -- Número Endereço	Texto[005]
           rpad(rw.complend, 10, ' ')          || -- Complemento Endereço	Texto[010]
           rpad(rw.nmbairro, 30, ' ')          || -- Bairro	Texto[030]
           rpad(' ', 2, ' ')                   || -- Dígito Verificador da Conta p/ Débito (alteração HSBC)	Texto[002]
           lpad(to_char(rw.cdagectl),4,'0')    || -- Código da Agência	Inteiro[004]
           lpad('0', 7, '0')                   || -- Código Matricula	Inteiro[007]
           lpad('0', 9, '0')                   || -- Código PAB	Inteiro[009]
           'N'                                 || -- Flag Indicador da Renovação Ativa	Texto[001]
           ' '                                 || -- Flag Indicador do tipo de Alteração/Exclusao	Texto[001]
           lpad(to_char(rw.nrctrseg), 13, '0') || -- Numero da Proposta do Corretor/Numero da Cotacao property	Texto[013]
           rpad(' ', 15, ' ')                  || -- Inscrição Estadual	Texto[015]
           rpad(' ', 15, ' ')                  || -- Inscrição Municipal	Texto[015]
           rpad(' ', 5, ' ')                   || -- Tipo de Classe (campo desativado - enviar branco)	Texto[005]
           rpad(' ', 10, ' ')                  || -- Tipo de Atividade (campo desativado - enviar branco)	Texto[010]
           rpad('0', 10, '0')                  || -- Código Revenda	Inteiro[010]
           rpad(' ', 100, ' ')                 || -- Descrição da Atividade da Empresa	Texto[100]
           rpad(' ', 100, ' ')                 || -- Email usuário da proposta	Texto[100]
           rpad(' ', 100, ' ')                 || -- Nome usuário da proposta	Texto[100]
           rpad('0', 8, '0')                   || -- Data da Cotação (DDMMAAAA)  (Moeda Extrangeira)	Data[008]
           rpad(' ', 14, ' ')                  || -- Cotação da Moeda	Cotação
           '3'                                 || -- Tipo da Apolice (1 = Sem itens 2 = Com Itens 3 = Normal)	texto[001]
           rpad(' ', 30, ' ')                  || -- Número Contrato CNH	Texto[030]
           RPAD('0', 3, '0')                   || -- "Sucursal da Apólice Anterior EXPANSAO
                                                  -- Igual ao campo ""Sucursal da Apólice Anterior (pos 481 e 482) "" aumentando 1 digito"	Inteiro[003]
           RPAD('0', 3, '0')                   || -- "Sucursal da Proposta EXPANSAO                    
                                                  -- Igual ao campo ""Sucursal da Proposta (pos 488 e 489)"" aumentando 1 digito"	Inteiro[003]
           rpad(' ', 15, ' ')                  || -- CPF-CNPJ de Acesso do usuário	texto[015]
           rpad(' ', 12, ' ')                  || -- Telefone Celular - Campo inativado no projeto MR0920 de FEV/2016, pois celular deverá ser enviado em novo formato, de acordo com linha 116. Essas 12 posições serão desconsideradas na importação, ou seja, pode enviar com espaços em branco. 	Texto[012]
           'S'                                 || -- Aceita receber SMS	texto[001]
           '00'                                || -- Codigo do servidor de Origem	Inteiro[002]
           rpad('0', 10, '0')                  || -- Numero da cotacao no servidor de Origem	Inteiro[010]
           rpad(rw.complend, 20, ' ')          || -- Complemento Endereço	Texto[020]
           rpad(nvl(trim(rw.email), ' '), 60, ' ')             || -- Email do cliente	texto[060]
           rpad(to_char(rw.dtnascimento,'DDMMYYYY'),8,'0') || -- Data de Nascimento do cliente (DDMMAAAA) 	Data[008]
           rw.sexo                             || -- Sexo do cliente [F]-Feminino [M]-Masculino	texto[01]
           RPAD(to_char(rw.nrcpfcgc),14,'0')   || -- CPF-CNPJ do Titular da Conta Corrente (28/02/2011) 	Inteiro[014]
           RPAD(substr(rw.nmprimtl,1,40), 40, ' ') || -- Nome do Titular da Conta Corrente para Débito (28/02/2011)	Texto[040]
           rpad('0', 8, '0')                   || -- Validade da Cotação	Data[008]
           'S'                                 || -- Flag Calculo Automático (S/N)	Texto[001]
           rpad(' ', 10, ' ')                  || -- Código Matricula 01 (Permitir CHAR - MR0822 - 12-06-2012)	Texto[010]
           rpad(' ', 10, ' ')                  || -- Código Matricula 02 (Permitir CHAR - MR0822 - 12-06-2012)	Texto[010]
           'N'                                 || -- Flg Ciente Nome (S/N)  - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Interage Nome (S/N)  - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Fechou Nome (S/N)  - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Ciente Endereço (S/N) - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Interage Endereço (S/N) - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Fechou Endereço (S/N)  - Projeto Cliente Serasa	Texto[001]
           rpad(' ', 14, ' ')                  || -- Data Cotação – Criação da Cotação (Data e Hora) DDMMAAAHHMMSS	Texto[014]
           RPAD(' ', 14, ' ')                  || -- "Telefone Celular - Projeto MR0920 em FEV/2016, correção para que o telefone celular seja enviado no formato ""00XX99999-9999"" 
                                                  -- (exemplo: 001197474-5723)"	Texto[014]
           '1'                                 || -- "Tipo do Envio do Kit Boas Vindas - (1-Cliente / 2-Corretor) Projeto MR0925 - ST-163"	Inteiro[001]
           nvl(trim(rw.flg_email),'N')         || -- "Flg Cliente Possuí E-mail (S/N)  Projeto MR0925 - ST-668"	Texto[001]
           rw.flg_fone                         || -- "Flg Cliente Possuí Celular (S/N) Projeto MR0925 - ST-668"	Texto[001]
           'S'                                 || -- "Flg Melhor Data (S/N) ST-1302"	Texto[001]
           RPAD('0', 5, '0')                   || -- "Taxa Melhor Data (99999) ST-1302"	Valor[005]
           RPAD('0', 8, '0')                      -- "Dat-pgtoprim   (DDMMAAAA) ST-1303"	Data[008]           
    ); 
    
    */
                       
  END LOOP;

  vr_nrseq := vr_nrseq + 1;  

  pc_print('',TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/rafael/', 'icatu_sub_' || vr_sub || '.txt', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);
  
  COMMIT;           
                
end;
