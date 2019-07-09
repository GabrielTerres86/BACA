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
     
  /* Calcular o d�gito verificador da conta */
  FUNCTION fn_calc_digito(pr_nrcalcul IN OUT NUMBER                               --> N�mero da conta
                         ,pr_reqweb   IN BOOLEAN DEFAULT FALSE) RETURN BOOLEAN IS --> Identificador se a requisi��o � da Web
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
    --               13/12/2012 - Convers�o Progress --> Oracle PLSQL (Alisson - AMcom)
    --               29/05/2013 - Inclu�do par�metro e consist�ncia para origem da Web (Petter - Supero)
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
  
  -- Subrotina para escrever texto na vari�vel CLOB do XML
  procedure pc_escreve_xml(pr_xml in out nocopy clob,  --> Vari�vel CLOB onde ser� inclu�do o texto
                           pr_texto_completo in out nocopy varchar2,  --> Vari�vel para armazenar o texto at� ser inclu�do no CLOB
                           pr_texto_novo in varchar2,  --> Texto a incluir no CLOB
                           pr_fecha_xml in boolean default false) is  --> Flag indicando se � o �ltimo texto no CLOB
    /*----------------------------------------------------------
      Programa: pc_escreve_xml
      Autor: Daniel Dallagnese (Supero)
      Data: 11/02/2014                               �ltima atualiza��o: 11/02/2014

      Objetivo: Melhorar a performance dos programas que necessitam escrever muita
                informa��o em vari�vel CLOB. Exemplo de uso: PC_CRPS086.

      Utiliza��o: Quando houver necessidade de incluir informa��es em um CLOB, deve-se
                  declarar, instanciar e abrir o CLOB no programa chamador, e pass�-lo
                  no par�metro PR_XML para este procedimento, juntamente com o texto que
                  se deseja incluir no CLOB. Para finalizar a gera��o do CLOB, deve-se
                  incluir tamb�m o par�metro PR_FECHA_XML com o valor TRUE. Ao final, no
                  programa chamador, deve-se fechar o CLOB e liberar a mem�ria utilizada.

      Altera��es: 17/10/2017 - Retirado pc_set_modulo
                              (Ana - Envolti - Chamado 776896)
                  18/10/2017 - Inclu�do pc_set_modulo com novo padr�o
                               (Ana - Envolti - Chamado 776896)
    ----------------------------------------------------------*/
    procedure pc_concatena(pr_xml in out nocopy clob,
                           pr_texto_completo in out nocopy varchar2,
                           pr_texto_novo varchar2) is
      -- Prodimento para concatenar os textos em um varchar2 antes de incluir no CLOB,
      -- ganhando performance. Somente grava no CLOB quando estourar a capacidade da vari�vel.
    begin
      -- Tenta concatenar o novo texto ap�s o texto antigo (vari�vel global da package)
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
    -- Incluir nome do m�dulo logado - Chamado 660322 18/07/2017
    --GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'GENE0002.pc_escreve_xml');
    -- Concatena o novo texto
    pc_concatena(pr_xml, pr_texto_completo, pr_texto_novo);
    -- Se for o �ltimo texto do arquivo, inclui no CLOB
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
  

  
  pc_print('MATRICULA OU N� CERTIFICADO ANTERIOR;' || 
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
           'N� ENDERECO;' || 
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
           'AG�NCIA;' || 
           'DV AG�NCIA;' || 
           'CONTA CORRENTE;' || 
           'DV CONTA CORRENTE;' || 
           'C�DIGO M�DULO;' || 
           'C�DIGO SUB;' || 
           'C�DIGO PDV (PA);' || 
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
    
    
  pc_print( vr_nrdapoli                         || ';' || -- MATRICULA OU N� CERTIFICADO ANTERIOR;
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
           to_char(rw.nrendres)                 || ';' || -- N� ENDERECO           
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
           vr_agencia                           || ';' || -- 'AG�NCIA;' || 
           vr_dvagencia                         || ';' || -- 'DV AG�NCIA;' || 
           vr_conta                             || ';' || -- 'CONTA CORRENTE;' || 
           vr_dvconta                           || ';' || -- 'DV CONTA CORRENTE;' || 
           vr_modulo                            || ';' || -- 'C�DIGO M�DULO;' || 
           vr_sub                               || ';' || -- 'C�DIGO SUB;' || 
           vr_sub || to_char(rw.cdagenci,'fm000') || ';' || -- 'C�DIGO PDV (PA);' || 
           SUBSTR(rw.nmprimtl,1,40)             || ';' || -- 'NOME CORRENTISTA;' || 
           LPAD(to_char(rw.cpf_correntista),11,'0')    || ';' || -- CPF CORRENTISTA;' || 
           to_char(rw.dtprideb,'DD') || '092019'  || ';' || -- 'DATA VENCIMENTO';
           '01092019'                                     -- 'DATA INICIO VIGENCIA'
    );
    
    /*
    
    
    pc_print('01' ||                              -- Tipo de Registro (Constante �01�)
           lpad(to_char(vr_nrseq),9,'0') ||       -- N�mero Sequencial do Registro
           lpad(to_char(rw.nrctrseg), 11, '0') || -- "N�mero do Documento - (EESSSPPPPPP)
                                                  -- EE => Empresa     SSS => Sucursal     PPPPPP => Num. Proposta"
           lpad(to_char(rw.nrctrseg),  6, '0') || -- "N�mero da Ap�lice a ser endossada
                                                  -- (Caso seja proposta de ap�lice enviar ZEROS)"
           LPAD('0', 2, '0')                   || -- Codigo da Origem
           'N'                                 || -- Flag Numero Reserva (�S�/�N�)
           LPAD(' ', 5, ' ')                   || -- Espa�o Dispon�vel 
           RPAD(substr(rw.nmprimtl,1,40), 40, ' ') || -- Nome do Segurado
           LPAD(to_char(rw.nrcpfcgc),14,'0')   || -- CGC/CPF do Segurado
           rw.tppessoa                         || -- Tipo de Pessoa ( �F� = F�sica , �J� = Jur�dica, �I� = Isento )
           Rpad(rw.nmbenvid##1, 40, ' ')       || -- Nome do Benefici�rio
           lpad(to_char(rw.dtinivig,'DDMMYY'),6,' ') || -- Data de In�cio de Vig�ncia
           lpad(to_char(rw.dtfimvig,'DDMMYY'),6,' ') || -- Data de In�cio de Vig�ncia            
           'N'                                 || -- Indicador de Renova��o (S/N)
           LPAD('0', 6, '0')                   || -- N�mero da Ap�lice Anterior (Somente para casos de renova��o e Endosso)
           LPAD(' ', 5, ' ')                   || -- Espa�o Dispon�vel
           RPAD('R$', 4, ' ')                  || -- C�digo da Moeda Original (SIGLA)
           '085'                               || -- C�digo do Banco - Carga Inicial
           '01'                                || -- Quantidade de Parcelas
           LPAD('100', 12, '0')                || -- Percentual de Cosseguro nossa parte (se 100 = n�o tem cosseguro)   
           LPAD('0', 15, '0')                  || -- Valor do Adicional de Fracionamento
           LPAD('0', 12, '0')                  || -- Percentual de Agravamento/Desconto
           LPAD(to_char(rw.vlpreseg,'fm999999999999.90'), 15, '0') ||      -- Valor de Pr�mio L�quido Total
           LPAD(to_char(rw.vlpreseg * 12,'fm999999999999.90'), 15, '0') || -- Valor de Pr�mio Anual Total
           RPAD('0', 15, '0')                  || -- Valor do Custo de Ap�lice
           RPAD('0', 15, '0')                  || -- Valor do IOF
           'N'                                 || -- C�d. Modo de Pagamento (�N�ormal, �P�r�-fixado)
           '1'                                 || -- C�d. do Tipo de Pagto ( 1 = Sem antecipa��o , 2 = Antecipado )
           rpad(nvl(rw.fone, ' '), 12, ' ')              || -- Telefone do Segurado
           '000000'                            || -- Data de Ativa��o Vencimento (somente para CNH)
           LPAD(' ', 12, ' ')                  || -- Espa�o Dispon�vel
           RPAD(substr(rw.endereco,1,40),40,' ') || -- Endere�o do Segurado ( Incluindo o n�mero )
           RPAD(SUBSTR(rw.nmcidade,1,20),20,' ') || -- Cidade do Segurado
           to_char(rw.nrcepend,'fm00000000')  || -- CEP do Segurado
           rpad(SUBSTR(rw.cdufresd,1,2),2,' ') || -- UF do Segurado
           RPAD(' ', 7, ' ')                   || -- C�digo do Segurado � BRANCOS	Texto[007]
           '000'                               || -- C�digo da Carteira (Caso seja proposta gen�rica enviar "999")	Texto[003]
           '00'                                || -- C�digo da Ag�ncia/Franquia/Filial � ZEROS	Inteiro[002]
           RPAD('0',11,'0')                    || -- "Numero da Proposta do Corretor (EESSSCCCCCC)
                                                  -- EE-Empresa    SSS-Sucursal    CCCCCC-Num. Proposta
                                                  -- (Caso seja proposta gen�rica enviar ZEROS)"	Inteiro[011]
           rpad(' ', 5, ' ')                   || -- Espa�o Dispon�vel	Texto[005]
           ' '                                 || -- Identificador de cancelamento de Ap�lice ou Endosso (A/E)	Texto[001]
           ' '                                 || -- "Motivo do Cancelamento
                                                  -- 1 = Falta de Pagto., 2 = Solicit. do Segurado, 3 = Solicit. da Cia"	Texto[001]
           'D'                                 || -- Tipo de Cobran�a  S-Sem Registro / R=Registrada / D=D�bito / P=Cheque / C=Cartao Credito	Texto[001]
           rpad(' ', 21, ' ')                  || -- Espa�o Dispon�vel	Texto[021]
           rpad('0', 7, '0')                   || -- C�digo Matricula 2	Inteiro[007]
           'N'                                 || -- Flag Indicador de PRO-RATA (s/n)	Texto[001]
           'N'                                 || -- Flag Indicador de Data Fixa (s/n)	Texto[001]
           to_char(rw.dtprideb,'DD') || '0819' || -- Data de Vencimento da 1�  parcela	Data
           rpad(' ', 19, ' ')                  || -- No. do Cart�o (sem espa�os e caracteres separadores)	Texto[019]
           lpad(SUBSTR(vr_conta,1,LENGTH(vr_conta)-1),11,'0')   || -- N�mero da Conta p/ D�bito	Texto[011]
           lpad(to_char(rw.cdagectl),4,'0')    || -- N�mero da Ag�ncia p/ D�bito	Texto[004]
           lpad(vr_dvconta,1,'0')              || -- D�gito Verificador da Conta p/ D�bito	Texto[001]
           lpad(vr_dvagencia,1,'0')            || -- D�gito Verificador da Ag�ncia p/ D�bito	Texto[001]
           '1'                                 || -- "Tipo de Opera��o (1-Ap�lice, 2-Renova��o, 3-Endosso, 4-Canc. Endosso, 5-Canc. Ap�lice, 6-Endosso s/ Mov)"	Texto[001]
           ' '                                 || -- Flag Pr�mio M�nimo	Texto[001]
           lpad(' ', 8, ' ')                   || -- C�digo da Vers�o	Texto[008]
           '00'                                || -- Empresa da Ap�lice Anterior	Inteiro[002]
           '00'                                || -- Sucursal da Ap�lice Anterior	Inteiro[002]
           lpad(' ', 3, ' ')                   || -- Carteira da Ap�lice Anterior	Texto[003]
           lpad('0', 2, '0')                   || -- Empresa da Proposta	Inteiro[002]
           lpad('0', 2, '0')                   || -- Sucursal da Proposta	Inteiro[002]
           lpad(' ', 3, ' ')                   || -- Carteira da Proposta	Texto[003]
           lpad('0', 6, '0')                   || -- Numero da Proposta	Inteiro[006]
           rpad(rw.nrdocumento,10,' ')         || -- Numero do Documeto de Identidade (RG)	Texto[010]
           rpad(to_char(rw.dtemissao_documento, 'DDMMYY'), 6, ' ')     || -- Data de Emiss�o do Documento (RG)	DATA 
           rpad(rw.cdorgao_expedidor, 6, ' ')  || -- �rg�o Emissor do Documento (RG)	Texto[006]
           rpad(to_char(rw.nrendres), 5, ' ')  || -- N�mero Endere�o	Texto[005]
           rpad(rw.complend, 10, ' ')          || -- Complemento Endere�o	Texto[010]
           rpad(rw.nmbairro, 30, ' ')          || -- Bairro	Texto[030]
           rpad(' ', 2, ' ')                   || -- D�gito Verificador da Conta p/ D�bito (altera��o HSBC)	Texto[002]
           lpad(to_char(rw.cdagectl),4,'0')    || -- C�digo da Ag�ncia	Inteiro[004]
           lpad('0', 7, '0')                   || -- C�digo Matricula	Inteiro[007]
           lpad('0', 9, '0')                   || -- C�digo PAB	Inteiro[009]
           'N'                                 || -- Flag Indicador da Renova��o Ativa	Texto[001]
           ' '                                 || -- Flag Indicador do tipo de Altera��o/Exclusao	Texto[001]
           lpad(to_char(rw.nrctrseg), 13, '0') || -- Numero da Proposta do Corretor/Numero da Cotacao property	Texto[013]
           rpad(' ', 15, ' ')                  || -- Inscri��o Estadual	Texto[015]
           rpad(' ', 15, ' ')                  || -- Inscri��o Municipal	Texto[015]
           rpad(' ', 5, ' ')                   || -- Tipo de Classe (campo desativado - enviar branco)	Texto[005]
           rpad(' ', 10, ' ')                  || -- Tipo de Atividade (campo desativado - enviar branco)	Texto[010]
           rpad('0', 10, '0')                  || -- C�digo Revenda	Inteiro[010]
           rpad(' ', 100, ' ')                 || -- Descri��o da Atividade da Empresa	Texto[100]
           rpad(' ', 100, ' ')                 || -- Email usu�rio da proposta	Texto[100]
           rpad(' ', 100, ' ')                 || -- Nome usu�rio da proposta	Texto[100]
           rpad('0', 8, '0')                   || -- Data da Cota��o (DDMMAAAA)  (Moeda Extrangeira)	Data[008]
           rpad(' ', 14, ' ')                  || -- Cota��o da Moeda	Cota��o
           '3'                                 || -- Tipo da Apolice (1 = Sem itens 2 = Com Itens 3 = Normal)	texto[001]
           rpad(' ', 30, ' ')                  || -- N�mero Contrato CNH	Texto[030]
           RPAD('0', 3, '0')                   || -- "Sucursal da Ap�lice Anterior EXPANSAO
                                                  -- Igual ao campo ""Sucursal da Ap�lice Anterior (pos 481 e 482) "" aumentando 1 digito"	Inteiro[003]
           RPAD('0', 3, '0')                   || -- "Sucursal da Proposta EXPANSAO                    
                                                  -- Igual ao campo ""Sucursal da Proposta (pos 488 e 489)"" aumentando 1 digito"	Inteiro[003]
           rpad(' ', 15, ' ')                  || -- CPF-CNPJ de Acesso do usu�rio	texto[015]
           rpad(' ', 12, ' ')                  || -- Telefone Celular - Campo inativado no projeto MR0920 de FEV/2016, pois celular dever� ser enviado em novo formato, de acordo com linha 116. Essas 12 posi��es ser�o desconsideradas na importa��o, ou seja, pode enviar com espa�os em branco. 	Texto[012]
           'S'                                 || -- Aceita receber SMS	texto[001]
           '00'                                || -- Codigo do servidor de Origem	Inteiro[002]
           rpad('0', 10, '0')                  || -- Numero da cotacao no servidor de Origem	Inteiro[010]
           rpad(rw.complend, 20, ' ')          || -- Complemento Endere�o	Texto[020]
           rpad(nvl(trim(rw.email), ' '), 60, ' ')             || -- Email do cliente	texto[060]
           rpad(to_char(rw.dtnascimento,'DDMMYYYY'),8,'0') || -- Data de Nascimento do cliente (DDMMAAAA) 	Data[008]
           rw.sexo                             || -- Sexo do cliente [F]-Feminino [M]-Masculino	texto[01]
           RPAD(to_char(rw.nrcpfcgc),14,'0')   || -- CPF-CNPJ do Titular da Conta Corrente (28/02/2011) 	Inteiro[014]
           RPAD(substr(rw.nmprimtl,1,40), 40, ' ') || -- Nome do Titular da Conta Corrente para D�bito (28/02/2011)	Texto[040]
           rpad('0', 8, '0')                   || -- Validade da Cota��o	Data[008]
           'S'                                 || -- Flag Calculo Autom�tico (S/N)	Texto[001]
           rpad(' ', 10, ' ')                  || -- C�digo Matricula 01 (Permitir CHAR - MR0822 - 12-06-2012)	Texto[010]
           rpad(' ', 10, ' ')                  || -- C�digo Matricula 02 (Permitir CHAR - MR0822 - 12-06-2012)	Texto[010]
           'N'                                 || -- Flg Ciente Nome (S/N)  - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Interage Nome (S/N)  - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Fechou Nome (S/N)  - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Ciente Endere�o (S/N) - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Interage Endere�o (S/N) - Projeto Cliente Serasa	Texto[001]
           'N'                                 || -- Flg Fechou Endere�o (S/N)  - Projeto Cliente Serasa	Texto[001]
           rpad(' ', 14, ' ')                  || -- Data Cota��o � Cria��o da Cota��o (Data e Hora) DDMMAAAHHMMSS	Texto[014]
           RPAD(' ', 14, ' ')                  || -- "Telefone Celular - Projeto MR0920 em FEV/2016, corre��o para que o telefone celular seja enviado no formato ""00XX99999-9999"" 
                                                  -- (exemplo: 001197474-5723)"	Texto[014]
           '1'                                 || -- "Tipo do Envio do Kit Boas Vindas - (1-Cliente / 2-Corretor) Projeto MR0925 - ST-163"	Inteiro[001]
           nvl(trim(rw.flg_email),'N')         || -- "Flg Cliente Possu� E-mail (S/N)  Projeto MR0925 - ST-668"	Texto[001]
           rw.flg_fone                         || -- "Flg Cliente Possu� Celular (S/N) Projeto MR0925 - ST-668"	Texto[001]
           'S'                                 || -- "Flg Melhor Data (S/N) ST-1302"	Texto[001]
           RPAD('0', 5, '0')                   || -- "Taxa Melhor Data (99999) ST-1302"	Valor[005]
           RPAD('0', 8, '0')                      -- "Dat-pgtoprim   (DDMMAAAA) ST-1303"	Data[008]           
    ); 
    
    */
                       
  END LOOP;

  vr_nrseq := vr_nrseq + 1;  

  pc_print('',TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/rafael/', 'icatu_sub_' || vr_sub || '.txt', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a mem�ria alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);
  
  COMMIT;           
                
end;
