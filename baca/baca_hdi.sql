-- Created on 05/06/2019 by F0030248 
declare 
  -- Local variables here
  i integer;
  vr_dslobdev      CLOB;
  vr_dsbufdev      VARCHAR2(32700);  
  vr_dscritic      VARCHAR2(1000);
  vr_nrseq         NUMBER(10) := 1;
  vr_qtdreg01      NUMBER(10) := 0;
  vr_qtdreg04      NUMBER(10) := 0;  
  vr_qtdreg05      NUMBER(10) := 0;    
  vr_nrseq04       NUMBER(10) := 0;    
  vr_flgdigok1     BOOLEAN;
  vr_nrcalcul      NUMBER;
  vr_conta         VARCHAR2(10);
  vr_dvconta       VARCHAR2(1);
  vr_agencia       VARCHAR2(5);
  vr_dvagencia     VARCHAR2(1);
  vr_nrapolice     NUMBER(10);
  vr_nrdocmto      VARCHAR2(11);
  vr_sucursal      VARCHAR2(3);  
  vr_cdcooper      crapcop.cdcooper%TYPE := 8;
  vr_empresa       VARCHAR2(2) := '03'; -- AILOS
  vr_seqailos      NUMBER(10) := 0;
  
  TYPE typ_plano IS RECORD ( cdplano PLS_INTEGER,
                             vl_incendio NUMBER(15,2),
                             vl_respons  NUMBER(15,2),
                             vl_vendaval_apto NUMBER(15,2),
                             vl_vendaval_casa NUMBER(15,2),
                             vl_danos NUMBER(15,2),
                             vl_roubo_apto NUMBER(15,2),
                             vl_roubo_casa NUMBER(15,2),
                             vl_aluguel NUMBER(15,2),
                             vl_especiais NUMBER(15,2),
                             vl_premio NUMBER(15,2),
                             vl_franquia NUMBER(15,2));
                           
  TYPE typ_tab_plano IS TABLE OF typ_plano INDEX BY PLS_INTEGER;  
  vr_tab_plano typ_tab_plano;
  idx_plano pls_integer;
  

  CURSOR cr_crapseg (pr_cdcooper IN crapseg.cdcooper%TYPE,
                     pr_cdsegura IN crapseg.cdsegura%TYPE) IS  
    SELECT seg.rowid    crapseg_rowid
         , seg.cdcooper
         , seg.tpseguro
         , seg.cdsegura
         , SEG.cdsitseg
         , seg.cdagenci
         , seg.nrdconta
         , seg.nrctrseg
         , seg.dtinivig
         , seg.dtfimvig
         , seg.dtcancel
         , seg.vlpreseg
         , seg.dtmvtolt
         , seg.qtprepag
         , seg.dtprideb
         , seg.qtparcel
         , seg.tpplaseg
         , seg.progress_recid
         , nvl(trim(seg.nmbenvid##1),ass.nmprimtl) nmbenvid##1
         , ass.nmprimtl 
         , ass.nrcpfcgc
         , DECODE(ass.inpessoa,1,'F','J') tppessoa
         , ( SELECT sys.stragg(to_char(tfc.nrdddtfc) || to_char(tfc.nrtelefo))
               FROM craptfc tfc
              WHERE tfc.cdcooper = seg.cdcooper
                AND tfc.nrdconta = seg.nrdconta
                AND tfc.prgqfalt = 'I'
                AND tfc.tptelefo = 2 -- celular
                AND ROWNUM = 1
            ) fone
            
         , NVL(( SELECT 'S'
               FROM craptfc tfc
              WHERE tfc.cdcooper = seg.cdcooper
                AND tfc.nrdconta = seg.nrdconta
                AND tfc.prgqfalt = 'I'
                AND tfc.tptelefo = 2 -- celular
                AND ROWNUM = 1
            ),'N') flg_fone            
            
--         , (wseg.dsendres || CASE WHEN NVL(wseg.nrendres,0) > 0 THEN ' ' || to_char(wseg.nrendres) END) endereco
         , wseg.dsendres endereco
         , wseg.nmcidade
         , wseg.nrcepend
         , wseg.cdufresd
         , wseg.complend
         , wseg.nmbairro
         , wseg.nrendres
         , cop.cdagectl
         , v.nrdocumento
         , v.dtemissao_documento
         , v.dtnascimento
         , DECODE(v.tpsexo,1,'M','F') sexo
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
      FROM crapseg seg
         , crapass ass
         , crapcop cop
         , crawseg wseg
         , vwcadast_pessoa_fisica v       
         , tbgen_orgao_expedidor org
     WHERE seg.cdcooper  = pr_cdcooper
       AND seg.cdsegura  = pr_cdsegura
       AND NVL(seg.dtcancel,TO_DATE('01/01/1900','DD/MM/YYYY')) <> seg.dtmvtolt
       AND seg.tpseguro  = 11
       AND seg.cdsitseg  = 3
       AND ass.cdcooper = seg.cdcooper
       AND ass.nrdconta = seg.nrdconta
       AND v.nrcpf = ass.nrcpfcgc
       AND org.idorgao_expedidor = v.idorgao_expedidor
       AND cop.cdcooper = ass.cdcooper
       AND seg.cdcooper = wseg.cdcooper (+)
       AND seg.nrdconta = wseg.nrdconta (+)
       AND seg.nrctrseg = wseg.nrctrseg (+)
       
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
  
  PROCEDURE pc_add_plano (pr_cdplano           IN PLS_INTEGER,
                          pr_vl_incendio       IN NUMBER DEFAULT 0,
                          pr_vl_respons        IN NUMBER DEFAULT 0,
                          pr_vl_vendaval_apto  IN NUMBER DEFAULT 0,
                          pr_vl_vendaval_casa  IN NUMBER DEFAULT 0,
                          pr_vl_danos          IN NUMBER DEFAULT 0,
                          pr_vl_roubo_apto     IN NUMBER DEFAULT 0,
                          pr_vl_roubo_casa     IN NUMBER DEFAULT 0,
                          pr_vl_aluguel        IN NUMBER DEFAULT 0,
                          pr_vl_especiais      IN NUMBER DEFAULT 0,
                          pr_vl_premio         IN NUMBER DEFAULT 0 ) IS
  BEGIN
   /* TYPE typ_plano IS RECORD ( cdplano INTEGER,
                             vl_incendio NUMBER(15,2),
                             vr_respons  NUMBER(15,2),
                             vl_vendaval_apto NUMBER(15,2),
                             vl_vendaval_casa NUMBER(15,2),
                             vl_danos NUMBER(15,2),
                             vr_roubo_apto NUMBER(15,2),
                             vl_roubo_casa NUMBER(15,2),
                             vl_aluguel NUMBER(15,2),
                             vl_especiais NUMBER(15,2),
                             vl_premio NUMBER(15,2));
                             
    TYPE typ_tab_plano IS TABLE OF typ_plano INDEX BY PLS_INTEGER;  
    vr_tab_plano typ_tab_plano;
    idx_plano pls_integer;*/
    
    vr_tab_plano(pr_cdplano).cdplano          := pr_cdplano;
    vr_tab_plano(pr_cdplano).vl_incendio      := nvl(pr_vl_incendio,0);
    vr_tab_plano(pr_cdplano).vl_respons       := nvl(pr_vl_respons,0);
    vr_tab_plano(pr_cdplano).vl_vendaval_apto := nvl(pr_vl_vendaval_apto,0);
    vr_tab_plano(pr_cdplano).vl_vendaval_casa := nvl(pr_vl_vendaval_casa,0);
    vr_tab_plano(pr_cdplano).vl_danos         := nvl(pr_vl_danos,0);
    vr_tab_plano(pr_cdplano).vl_roubo_apto    := nvl(pr_vl_roubo_apto,0);
    vr_tab_plano(pr_cdplano).vl_roubo_casa    := nvl(pr_vl_roubo_casa,0);
    vr_tab_plano(pr_cdplano).vl_aluguel       := nvl(pr_vl_aluguel,0);
    vr_tab_plano(pr_cdplano).vl_especiais     := nvl(pr_vl_especiais,0);
    vr_tab_plano(pr_cdplano).vl_premio        := nvl(pr_vl_premio,0);
    
    IF nvl(pr_vl_vendaval_apto,0) <= 100000 OR 
       nvl(pr_vl_vendaval_casa,0) <= 100000 THEN
       vr_tab_plano(pr_cdplano).vl_franquia := 300.00;
    ELSE
       vr_tab_plano(pr_cdplano).vl_franquia := 400.00;
    END IF;
    
  END pc_add_plano;
  
BEGIN
  
  -- inicializar planos
  pc_add_plano (pr_cdplano => 361, pr_vl_incendio => 60000, pr_vl_respons => 12000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 5.72);
  pc_add_plano (pr_cdplano => 371, pr_vl_incendio => 70000, pr_vl_respons => 14000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 6.42);
  pc_add_plano (pr_cdplano => 381, pr_vl_incendio => 80000, pr_vl_respons => 16000, pr_vl_vendaval_apto => 8000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 7.46);
  pc_add_plano (pr_cdplano => 391, pr_vl_incendio => 90000, pr_vl_respons => 18000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 8.39);
  pc_add_plano (pr_cdplano => 401, pr_vl_incendio => 100000, pr_vl_respons => 20000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 9.08);
  pc_add_plano (pr_cdplano => 411, pr_vl_incendio => 125000, pr_vl_respons => 25000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 10.81);
  pc_add_plano (pr_cdplano => 421, pr_vl_incendio => 150000, pr_vl_respons => 30000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 12.54);
  pc_add_plano (pr_cdplano => 431, pr_vl_incendio => 175000, pr_vl_respons => 35000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 14.27);
  pc_add_plano (pr_cdplano => 441, pr_vl_incendio => 200000, pr_vl_respons => 40000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 16);
  pc_add_plano (pr_cdplano => 451, pr_vl_incendio => 225000, pr_vl_respons => 45000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 17.73);
  pc_add_plano (pr_cdplano => 461, pr_vl_incendio => 250000, pr_vl_respons => 50000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 19.46);
  pc_add_plano (pr_cdplano => 471, pr_vl_incendio => 275000, pr_vl_respons => 55000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 21.19);
  pc_add_plano (pr_cdplano => 481, pr_vl_incendio => 300000, pr_vl_respons => 60000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 25000, pr_vl_premio => 22.92);

  pc_add_plano (pr_cdplano => 362, pr_vl_incendio => 60000, pr_vl_respons => 12000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 6.84);
  pc_add_plano (pr_cdplano => 372, pr_vl_incendio => 70000, pr_vl_respons => 14000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 7.61);
  pc_add_plano (pr_cdplano => 382, pr_vl_incendio => 80000, pr_vl_respons => 16000, pr_vl_vendaval_apto => 8000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 8.39);
  pc_add_plano (pr_cdplano => 392, pr_vl_incendio => 90000, pr_vl_respons => 18000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 9.16);
  pc_add_plano (pr_cdplano => 402, pr_vl_incendio => 100000, pr_vl_respons => 20000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 10.54);
  pc_add_plano (pr_cdplano => 412, pr_vl_incendio => 125000, pr_vl_respons => 25000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 12.48);
  pc_add_plano (pr_cdplano => 422, pr_vl_incendio => 150000, pr_vl_respons => 30000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 14.42);
  pc_add_plano (pr_cdplano => 432, pr_vl_incendio => 175000, pr_vl_respons => 35000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 16.35);
  pc_add_plano (pr_cdplano => 442, pr_vl_incendio => 200000, pr_vl_respons => 40000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 18.89);
  pc_add_plano (pr_cdplano => 452, pr_vl_incendio => 225000, pr_vl_respons => 45000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 20.83);
  pc_add_plano (pr_cdplano => 462, pr_vl_incendio => 250000, pr_vl_respons => 50000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 22.77);
  pc_add_plano (pr_cdplano => 472, pr_vl_incendio => 275000, pr_vl_respons => 55000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_premio => 24.71);
  pc_add_plano (pr_cdplano => 482, pr_vl_incendio => 300000, pr_vl_respons => 60000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 25000, pr_vl_premio => 27.25);

  pc_add_plano (pr_cdplano => 363, pr_vl_incendio => 60000, pr_vl_respons => 12000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 14.84);
  pc_add_plano (pr_cdplano => 373, pr_vl_incendio => 70000, pr_vl_respons => 14000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 16.42);
  pc_add_plano (pr_cdplano => 383, pr_vl_incendio => 80000, pr_vl_respons => 16000, pr_vl_vendaval_apto => 8000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 18);
  pc_add_plano (pr_cdplano => 393, pr_vl_incendio => 90000, pr_vl_respons => 18000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 10000, pr_vl_premio => 19.57);
  pc_add_plano (pr_cdplano => 403, pr_vl_incendio => 100000, pr_vl_respons => 20000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_premio => 23.35);
  
  pc_add_plano (pr_cdplano => 41, pr_vl_incendio => 60000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 6000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 6000, pr_vl_premio => 12.42);
  pc_add_plano (pr_cdplano => 51, pr_vl_incendio => 70000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 7000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 7000, pr_vl_premio => 13.04);
  pc_add_plano (pr_cdplano => 61, pr_vl_incendio => 80000, pr_vl_danos => 2500, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_aluguel => 8000, pr_vl_vendaval_apto => 8000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 8000, pr_vl_premio => 15.37);
  pc_add_plano (pr_cdplano => 71, pr_vl_incendio => 90000, pr_vl_danos => 2500, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_aluguel => 9000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 9000, pr_vl_premio => 16.25);
  pc_add_plano (pr_cdplano => 81, pr_vl_incendio => 100000, pr_vl_danos => 3000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_aluguel => 10000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 10000, pr_vl_premio => 18.54);
  pc_add_plano (pr_cdplano => 91, pr_vl_incendio => 125000, pr_vl_danos => 3000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_aluguel => 12500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 12500, pr_vl_premio => 20.09);
  pc_add_plano (pr_cdplano => 101, pr_vl_incendio => 150000, pr_vl_danos => 5000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_aluguel => 15000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 15000, pr_vl_premio => 24.38);
  pc_add_plano (pr_cdplano => 111, pr_vl_incendio => 175000, pr_vl_danos => 5000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_aluguel => 17500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 17500, pr_vl_premio => 25.92);
  pc_add_plano (pr_cdplano => 121, pr_vl_incendio => 200000, pr_vl_danos => 8000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 20000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 20000, pr_vl_premio => 32.25);
  pc_add_plano (pr_cdplano => 131, pr_vl_incendio => 225000, pr_vl_danos => 8000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 22500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 22500, pr_vl_premio => 33.79);
  pc_add_plano (pr_cdplano => 141, pr_vl_incendio => 250000, pr_vl_danos => 10000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 25000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 25000, pr_vl_premio => 36.76);
  pc_add_plano (pr_cdplano => 151, pr_vl_incendio => 275000, pr_vl_danos => 10000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 27500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 27500, pr_vl_premio => 39.62);
  pc_add_plano (pr_cdplano => 161, pr_vl_incendio => 300000, pr_vl_danos => 15000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 30000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 25000, pr_vl_respons => 30000, pr_vl_premio => 44.73);

  pc_add_plano (pr_cdplano => 42, pr_vl_incendio => 60000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 6000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 6000, pr_vl_premio => 23.03);
  pc_add_plano (pr_cdplano => 52, pr_vl_incendio => 70000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 7000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 7000, pr_vl_premio => 23.73);
  pc_add_plano (pr_cdplano => 62, pr_vl_incendio => 80000, pr_vl_danos => 2500, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_aluguel => 8000, pr_vl_vendaval_apto => 8000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 8000, pr_vl_premio => 27.08);
  pc_add_plano (pr_cdplano => 72, pr_vl_incendio => 90000, pr_vl_danos => 2500, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_aluguel => 9000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 9000, pr_vl_premio => 27.79);
  pc_add_plano (pr_cdplano => 82, pr_vl_incendio => 100000, pr_vl_danos => 3000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_aluguel => 10000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 10000, pr_vl_premio => 32.45);
  pc_add_plano (pr_cdplano => 92, pr_vl_incendio => 125000, pr_vl_danos => 3000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_aluguel => 12500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 12500, pr_vl_premio => 34.21);
  pc_add_plano (pr_cdplano => 102, pr_vl_incendio => 150000, pr_vl_danos => 5000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_aluguel => 15000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 15000, pr_vl_premio => 41.21);
  pc_add_plano (pr_cdplano => 112, pr_vl_incendio => 175000, pr_vl_danos => 5000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_aluguel => 17500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 17500, pr_vl_premio => 42.96);
  pc_add_plano (pr_cdplano => 122, pr_vl_incendio => 200000, pr_vl_danos => 8000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 20000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 20000, pr_vl_premio => 54.57);
  pc_add_plano (pr_cdplano => 132, pr_vl_incendio => 225000, pr_vl_danos => 8000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 22500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 22500, pr_vl_premio => 56.33);
  pc_add_plano (pr_cdplano => 142, pr_vl_incendio => 250000, pr_vl_danos => 10000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 25000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 25000, pr_vl_premio => 60.68);
  pc_add_plano (pr_cdplano => 152, pr_vl_incendio => 275000, pr_vl_danos => 10000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 27500, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 20000, pr_vl_respons => 27500, pr_vl_premio => 62.43);
  pc_add_plano (pr_cdplano => 162, pr_vl_incendio => 300000, pr_vl_danos => 15000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_aluguel => 30000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 25000, pr_vl_respons => 30000, pr_vl_premio => 71.33);

  pc_add_plano (pr_cdplano => 43, pr_vl_incendio => 60000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 6000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 6000, pr_vl_premio => 32.8);
  pc_add_plano (pr_cdplano => 53, pr_vl_incendio => 70000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 7000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 7000, pr_vl_premio => 34.38);
  pc_add_plano (pr_cdplano => 63, pr_vl_incendio => 80000, pr_vl_danos => 2500, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_aluguel => 8000, pr_vl_vendaval_apto => 8000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 8000, pr_vl_premio => 38.95);
  pc_add_plano (pr_cdplano => 73, pr_vl_incendio => 90000, pr_vl_danos => 2500, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_aluguel => 9000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 9000, pr_vl_premio => 40.53);
  pc_add_plano (pr_cdplano => 83, pr_vl_incendio => 100000, pr_vl_danos => 3000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_aluguel => 10000, pr_vl_vendaval_apto => 10000, pr_vl_vendaval_casa => 15000, pr_vl_respons => 10000, pr_vl_premio => 47.89);  
  
  pc_add_plano (pr_cdplano => 201, pr_vl_incendio => 60000, pr_vl_respons => 12000, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_especiais => 6000, pr_vl_premio => 15.6);
  pc_add_plano (pr_cdplano => 211, pr_vl_incendio => 70000, pr_vl_respons => 14000, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_especiais => 7000, pr_vl_premio => 17.35);
  pc_add_plano (pr_cdplano => 221, pr_vl_incendio => 80000, pr_vl_respons => 16000, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_especiais => 8000, pr_vl_premio => 20.13);
  pc_add_plano (pr_cdplano => 231, pr_vl_incendio => 90000, pr_vl_respons => 18000, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_especiais => 9000, pr_vl_premio => 21.87);
  pc_add_plano (pr_cdplano => 241, pr_vl_incendio => 100000, pr_vl_respons => 20000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_especiais => 10000, pr_vl_premio => 24.65);
  pc_add_plano (pr_cdplano => 251, pr_vl_incendio => 125000, pr_vl_respons => 25000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_especiais => 12500, pr_vl_premio => 29.01);
  pc_add_plano (pr_cdplano => 261, pr_vl_incendio => 150000, pr_vl_respons => 30000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_especiais => 15000, pr_vl_premio => 34.41);
  pc_add_plano (pr_cdplano => 271, pr_vl_incendio => 175000, pr_vl_respons => 35000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_especiais => 17500, pr_vl_premio => 38.77);
  pc_add_plano (pr_cdplano => 281, pr_vl_incendio => 200000, pr_vl_respons => 40000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 20000, pr_vl_premio => 45.21);
  pc_add_plano (pr_cdplano => 291, pr_vl_incendio => 225000, pr_vl_respons => 45000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 22500, pr_vl_premio => 49.57);
  pc_add_plano (pr_cdplano => 301, pr_vl_incendio => 250000, pr_vl_respons => 50000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 25000, pr_vl_premio => 53.93);
  pc_add_plano (pr_cdplano => 311, pr_vl_incendio => 275000, pr_vl_respons => 55000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 27500, pr_vl_premio => 59.32);
  pc_add_plano (pr_cdplano => 321, pr_vl_incendio => 300000, pr_vl_respons => 60000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 30000, pr_vl_premio => 63.68);

  pc_add_plano (pr_cdplano => 202, pr_vl_incendio => 60000, pr_vl_respons => 12000, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_especiais => 6000, pr_vl_premio => 25.45);
  pc_add_plano (pr_cdplano => 212, pr_vl_incendio => 70000, pr_vl_respons => 14000, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_especiais => 7000, pr_vl_premio => 27.53);
  pc_add_plano (pr_cdplano => 222, pr_vl_incendio => 80000, pr_vl_respons => 16000, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_especiais => 8000, pr_vl_premio => 32.01);
  pc_add_plano (pr_cdplano => 232, pr_vl_incendio => 90000, pr_vl_respons => 18000, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_especiais => 9000, pr_vl_premio => 34.1);
  pc_add_plano (pr_cdplano => 242, pr_vl_incendio => 100000, pr_vl_respons => 20000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_especiais => 10000, pr_vl_premio => 38.57);
  pc_add_plano (pr_cdplano => 252, pr_vl_incendio => 125000, pr_vl_respons => 25000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_especiais => 12500, pr_vl_premio => 43.79);
  pc_add_plano (pr_cdplano => 262, pr_vl_incendio => 150000, pr_vl_respons => 30000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_especiais => 15000, pr_vl_premio => 51.4);
  pc_add_plano (pr_cdplano => 272, pr_vl_incendio => 175000, pr_vl_respons => 35000, pr_vl_roubo_apto => 7000, pr_vl_roubo_casa => 8000, pr_vl_especiais => 17500, pr_vl_premio => 56.62);
  pc_add_plano (pr_cdplano => 282, pr_vl_incendio => 200000, pr_vl_respons => 40000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 20000, pr_vl_premio => 66.61);
  pc_add_plano (pr_cdplano => 292, pr_vl_incendio => 225000, pr_vl_respons => 45000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 22500, pr_vl_premio => 71.83);
  pc_add_plano (pr_cdplano => 302, pr_vl_incendio => 250000, pr_vl_respons => 50000, pr_vl_roubo_apto => 9000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 25000, pr_vl_premio => 77.05);
  pc_add_plano (pr_cdplano => 312, pr_vl_incendio => 275000, pr_vl_respons => 55000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 27500, pr_vl_premio => 82.27);
  pc_add_plano (pr_cdplano => 322, pr_vl_incendio => 300000, pr_vl_respons => 60000, pr_vl_roubo_apto => 10000, pr_vl_roubo_casa => 10000, pr_vl_especiais => 30000, pr_vl_premio => 87.49);

  pc_add_plano (pr_cdplano => 203, pr_vl_incendio => 60000, pr_vl_respons => 12000, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_especiais => 6000, pr_vl_premio => 36.89);
  pc_add_plano (pr_cdplano => 213, pr_vl_incendio => 70000, pr_vl_respons => 14000, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_especiais => 7000, pr_vl_premio => 40.1);
  pc_add_plano (pr_cdplano => 223, pr_vl_incendio => 80000, pr_vl_respons => 16000, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_especiais => 8000, pr_vl_premio => 46.64);
  pc_add_plano (pr_cdplano => 233, pr_vl_incendio => 90000, pr_vl_respons => 18000, pr_vl_roubo_apto => 5000, pr_vl_roubo_casa => 6000, pr_vl_especiais => 9000, pr_vl_premio => 49.85);
  pc_add_plano (pr_cdplano => 243, pr_vl_incendio => 100000, pr_vl_respons => 20000, pr_vl_roubo_apto => 6000, pr_vl_roubo_casa => 7000, pr_vl_especiais => 10000, pr_vl_premio => 56.39);
  
  pc_add_plano (pr_cdplano => 12, pr_vl_incendio => 30000, pr_vl_danos => 2000, pr_vl_roubo_apto => 2000, pr_vl_roubo_casa => 3000, pr_vl_aluguel => 3000, pr_vl_vendaval_apto => 3000, pr_vl_vendaval_casa => 5000, pr_vl_respons => 3000, pr_vl_premio => 14.31);
  pc_add_plano (pr_cdplano => 22, pr_vl_incendio => 40000, pr_vl_danos => 2000, pr_vl_roubo_apto => 2000, pr_vl_roubo_casa => 3000, pr_vl_aluguel => 4000, pr_vl_vendaval_apto => 3000, pr_vl_vendaval_casa => 5000, pr_vl_respons => 4000, pr_vl_premio => 15.01);
  pc_add_plano (pr_cdplano => 32, pr_vl_incendio => 50000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 5000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 5000, pr_vl_premio => 22.33);

  pc_add_plano (pr_cdplano => 13, pr_vl_incendio => 30000, pr_vl_danos => 2000, pr_vl_roubo_apto => 2000, pr_vl_roubo_casa => 3000, pr_vl_aluguel => 3000, pr_vl_vendaval_apto => 3000, pr_vl_vendaval_casa => 5000, pr_vl_respons => 3000, pr_vl_premio => 19.29);
  pc_add_plano (pr_cdplano => 23, pr_vl_incendio => 40000, pr_vl_danos => 2000, pr_vl_roubo_apto => 2000, pr_vl_roubo_casa => 3000, pr_vl_aluguel => 4000, pr_vl_vendaval_apto => 3000, pr_vl_vendaval_casa => 5000, pr_vl_respons => 4000, pr_vl_premio => 20.86);
  pc_add_plano (pr_cdplano => 33, pr_vl_incendio => 50000, pr_vl_danos => 2500, pr_vl_roubo_apto => 4000, pr_vl_roubo_casa => 5000, pr_vl_aluguel => 5000, pr_vl_vendaval_apto => 5000, pr_vl_vendaval_casa => 10000, pr_vl_respons => 5000, pr_vl_premio => 31.22);
  
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_dslobdev, TRUE);
  dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
  vr_dsbufdev := NULL;
  
  vr_sucursal := to_char(vr_cdcooper,'fm000');
  
  -- registro Prefacio  
  pc_print('00' ||                                -- Tipo de Registro (Constante �00�)
           lpad(to_char(vr_nrseq),9,'0') ||       -- N�mero Sequencial do Registro
           ' '  ||                                -- Espa�o Dispon�vel
           to_char(SYSDATE,'DDMMYY')     ||       -- Data de gera��o do movimento
           to_char(SYSDATE,'HH24MISS')   ||       -- Hora de gera��o do movimento (HHMMSS)
           '01'                          ||       -- C�digo da Empresa da Seguradora ( Tabela a Enviar )
           '003'                         ||       -- C�digo da Sucursal da Seguradora ( Tabela a Enviar )
           LPAD(' ', 471, ' ')
  );    
  
  
  
  FOR rw IN cr_crapseg (pr_cdcooper => vr_cdcooper,
                        pr_cdsegura => 5011) LOOP
                        
    CASE rw.cdcooper
      WHEN 2  THEN vr_nrapolice := 601495;
      WHEN 5  THEN vr_nrapolice := 737408;
      WHEN 7  THEN vr_nrapolice := 737409;
      WHEN 8  THEN vr_nrapolice := 737410;
      WHEN 10 THEN vr_nrapolice := 737411;
      WHEN 6  THEN vr_nrapolice := 737412;
      WHEN 11 THEN vr_nrapolice := 737413;
      WHEN 12 THEN vr_nrapolice := 737414;
      WHEN 14 THEN vr_nrapolice := 737415;
      WHEN 13 THEN vr_nrapolice := 737416;
      WHEN 9  THEN vr_nrapolice := 737417;
      WHEN 1  THEN vr_nrapolice := 147306;
      WHEN 16 THEN vr_nrapolice := 137418;
    END CASE;           

    vr_nrseq    := vr_nrseq + 1;
    vr_nrseq04  := 0;
    vr_qtdreg01 := vr_qtdreg01 + 1;
    vr_seqailos := vr_seqailos + 1;
    
    -- Calcula primeiro digito de controle
    vr_nrcalcul := to_number(to_char(rw.cdagectl,'fm0000') || '0');           
    vr_flgdigok1 := fn_calc_digito (pr_nrcalcul => vr_nrcalcul);
    vr_agencia := to_char(vr_nrcalcul,'fm00000');
    vr_dvagencia := SUBSTR(vr_agencia,LENGTH(vr_agencia)-1,1);
    vr_agencia := SUBSTR(vr_agencia,1,4);
    
    vr_conta   := to_char(rw.nrdconta);
    vr_dvconta := SUBSTR(vr_conta,LENGTH(vr_conta),1);
    
    vr_nrdocmto := lpad('01'  || 
                        '003' ||
                        to_char(vr_seqailos,'fm000000'), 11, '0');
    
    pc_print('01' ||                              -- Tipo de Registro (Constante �01�)
           lpad(to_char(vr_nrseq),9,'0') ||       -- N�mero Sequencial do Registro
           --lpad(to_char(rw.nrctrseg), 11, '0') || -- "N�mero do Documento - (EESSSPPPPPP)
           vr_nrdocmto                         || -- "N�mero do Documento - (EESSSPPPPPP)
                                                  -- EE => Empresa     SSS => Sucursal     PPPPPP => Num. Proposta"
           lpad('0', 6, '0')                   || -- "N�mero da Ap�lice a ser endossada
                                                  -- (Caso seja proposta de ap�lice enviar ZEROS)"
           LPAD('0', 2, '0')                   || -- Codigo da Origem
           'N'                                 || -- Flag Numero Reserva (�S�/�N�)
           LPAD(' ', 5, ' ')                   || -- Espa�o Dispon�vel 
           RPAD(substr(rw.nmprimtl,1,40), 40, ' ') || -- Nome do Segurado
           LPAD(to_char(rw.nrcpfcgc),14,'0')   || -- CGC/CPF do Segurado
           rw.tppessoa                         || -- Tipo de Pessoa ( �F� = F�sica , �J� = Jur�dica, �I� = Isento )
--           Rpad(rw.nmbenvid##1, 40, ' ')       || -- Nome do Benefici�rio
           Rpad(' ', 40, ' ')       || -- Nome do Benefici�rio
           lpad(to_char(rw.dtinivig,'DDMMYY'),6,' ') || -- Data de In�cio de Vig�ncia
           lpad(to_char(rw.dtfimvig,'DDMMYY'),6,' ') || -- Data de In�cio de Vig�ncia            
           'N'                                 || -- Indicador de Renova��o (S/N)
           LPAD('0', 6, '0')                   || -- N�mero da Ap�lice Anterior (Somente para casos de renova��o e Endosso)
           LPAD(' ', 5, ' ')                   || -- Espa�o Dispon�vel
           RPAD('R$', 4, ' ')                  || -- C�digo da Moeda Original (SIGLA)
           '085'                               || -- C�digo do Banco - Carga Inicial
           '01'                                || -- Quantidade de Parcelas
           LPAD('100.00', 12, '0')                || -- Percentual de Cosseguro nossa parte (se 100 = n�o tem cosseguro)   
           LPAD('0', 15, '0')                  || -- Valor do Adicional de Fracionamento
           LPAD('0', 12, '0')                  || -- Percentual de Agravamento/Desconto
           LPAD(to_char(round(rw.vlpreseg - (rw.vlpreseg*0.0738),2),'fm999999999999.90'), 15, '0') ||      -- Valor de Pr�mio L�quido Total
           LPAD(to_char(rw.vlpreseg * 12,'fm999999999999.90'), 15, '0') || -- Valor de Pr�mio Anual Total
           RPAD('0.00', 15, '0')               || -- Valor do Custo de Ap�lice
           RPAD('0', 15, '0')                  || -- Valor do IOF
           'N'                                 || -- C�d. Modo de Pagamento (�N�ormal, �P�r�-fixado)
           '7'                                 || -- C�d. do Tipo de Pagto ( 1 = Sem antecipa��o , 2 = Antecipado )
                                                  -- *	Sem Estipulante: ( 5 = Sem antecipa��o , 6 = Antecipado )
                                                  -- *	Com Estipulante ( 7 = Sem antecipa��o , 8 = Antecipado )
           rpad(nvl(rw.fone, ' '), 12, ' ')              || -- Telefone do Segurado
           '000000'                            || -- Data de Ativa��o Vencimento (somente para CNH)
           LPAD(' ', 12, ' ')                  || -- Espa�o Dispon�vel
           RPAD(substr(rw.endereco,1,40),40,' ') || -- Endere�o do Segurado ( Incluindo o n�mero )
           RPAD(SUBSTR(rw.nmcidade,1,20),20,' ') || -- Cidade do Segurado
           to_char(rw.nrcepend,'fm00000000')  || -- CEP do Segurado
           rpad(SUBSTR(rw.cdufresd,1,2),2,' ') || -- UF do Segurado
           RPAD(' ', 7, ' ')                   || -- C�digo do Segurado � BRANCOS  Texto[007]
           '005'                               || -- C�digo da Carteira (Caso seja proposta gen�rica enviar "999")  Texto[003]
           '00'                                || -- C�digo da Ag�ncia/Franquia/Filial � ZEROS  Inteiro[002]
           RPAD('0',11,'0')                    || -- "Numero da Proposta do Corretor (EESSSCCCCCC)
                                                  -- EE-Empresa    SSS-Sucursal    CCCCCC-Num. Proposta
                                                  -- (Caso seja proposta gen�rica enviar ZEROS)"  Inteiro[011]
           rpad(' ', 5, ' ')                   || -- Espa�o Dispon�vel  Texto[005]
           ' '                                 || -- Identificador de cancelamento de Ap�lice ou Endosso (A/E)  Texto[001]
           ' '                                 || -- "Motivo do Cancelamento
                                                  -- 1 = Falta de Pagto., 2 = Solicit. do Segurado, 3 = Solicit. da Cia"  Texto[001]
           'D'                                 || -- Tipo de Cobran�a  S-Sem Registro / R=Registrada / D=D�bito / P=Cheque / C=Cartao Credito  Texto[001]
           rpad(' ', 21, ' ')                  || -- Espa�o Dispon�vel  Texto[021]
           rpad('0', 7, '0')                   || -- C�digo Matricula 2  Inteiro[007]
           'N'                                 || -- Flag Indicador de PRO-RATA (s/n)  Texto[001]
           'N'                                 || -- Flag Indicador de Data Fixa (s/n)  Texto[001]
           to_char(rw.dtprideb,'DD') || '0819' || -- Data de Vencimento da 1�  parcela  Data
           rpad(' ', 19, ' ')                  || -- No. do Cart�o (sem espa�os e caracteres separadores)  Texto[019]
           lpad(SUBSTR(vr_conta,1,LENGTH(vr_conta)-1),11,'0')   || -- N�mero da Conta p/ D�bito  Texto[011]
--           lpad(to_char(rw.cdagectl),4,'0')    || -- N�mero da Ag�ncia p/ D�bito  Texto[004]
           lpad(' ',4,' ')                     || -- N�mero da Ag�ncia p/ D�bito  Texto[004] *** Enviar branco apos email do Renato ***
           lpad(vr_dvconta,1,'0')              || -- D�gito Verificador da Conta p/ D�bito  Texto[001]
           lpad(vr_dvagencia,1,'0')            || -- D�gito Verificador da Ag�ncia p/ D�bito  Texto[001]
           '1'                                 || -- "Tipo de Opera��o (1-Ap�lice, 2-Renova��o, 3-Endosso, 4-Canc. Endosso, 5-Canc. Ap�lice, 6-Endosso s/ Mov)"  Texto[001]
           ' '                                 || -- Flag Pr�mio M�nimo  Texto[001]
           lpad(' ', 8, ' ')                   || -- C�digo da Vers�o  Texto[008]
           '00'                                || -- Empresa da Ap�lice Anterior  Inteiro[002]
           '00'                                || -- Sucursal da Ap�lice Anterior  Inteiro[002]
           lpad(' ', 3, ' ')                   || -- Carteira da Ap�lice Anterior  Texto[003]
           lpad('0', 2, '0')                   || -- Empresa da Proposta  Inteiro[002]
           lpad('0', 2, '0')                   || -- Sucursal da Proposta  Inteiro[002]
           lpad(' ', 3, ' ')                   || -- Carteira da Proposta  Texto[003]
           lpad('0', 6, '0')                   || -- Numero da Proposta  Inteiro[006]
           rpad(rw.nrdocumento,10,' ')         || -- Numero do Documeto de Identidade (RG)  Texto[010]
           rpad(to_char(rw.dtemissao_documento, 'DDMMYY'), 6, ' ')     || -- Data de Emiss�o do Documento (RG)  DATA 
           rpad(rw.cdorgao_expedidor, 6, ' ')  || -- �rg�o Emissor do Documento (RG)  Texto[006]
           rpad(to_char(rw.nrendres), 5, ' ')  || -- N�mero Endere�o  Texto[005]
           rpad(rw.complend, 10, ' ')          || -- Complemento Endere�o  Texto[010]
           rpad(rw.nmbairro, 30, ' ')          || -- Bairro  Texto[030]
           rpad(' ', 2, ' ')                   || -- D�gito Verificador da Conta p/ D�bito (altera��o HSBC)  Texto[002]
           lpad(to_char(rw.cdagectl),4,'0')    || -- C�digo da Ag�ncia  Inteiro[004]
           lpad(' ', 7, ' ')                   || -- C�digo Matricula  Inteiro[007]
           lpad(' ', 9, ' ')                   || -- C�digo PAB  Inteiro[009]
           'N'                                 || -- Flag Indicador da Renova��o Ativa  Texto[001]
           ' '                                 || -- Flag Indicador do tipo de Altera��o/Exclusao  Texto[001]
           lpad(to_char(rw.nrctrseg), 13, '0') || -- Numero da Proposta do Corretor/Numero da Cotacao property  Texto[013]
           rpad(' ', 15, ' ')                  || -- Inscri��o Estadual  Texto[015]
           rpad(' ', 15, ' ')                  || -- Inscri��o Municipal  Texto[015]
           rpad(' ', 5, ' ')                   || -- Tipo de Classe (campo desativado - enviar branco)  Texto[005]
           rpad(' ', 10, ' ')                  || -- Tipo de Atividade (campo desativado - enviar branco)  Texto[010]
           rpad('0', 10, '0')                  || -- C�digo Revenda  Inteiro[010]
           rpad(' ', 100, ' ')                 || -- Descri��o da Atividade da Empresa  Texto[100]
           rpad(' ', 100, ' ')                 || -- Email usu�rio da proposta  Texto[100]
           rpad(' ', 100, ' ')                 || -- Nome usu�rio da proposta  Texto[100]
           rpad('0', 8, '0')                   || -- Data da Cota��o (DDMMAAAA)  (Moeda Extrangeira)  Data[008]
           rpad(' ', 14, ' ')                  || -- Cota��o da Moeda  Cota��o
           '3'                                 || -- Tipo da Apolice (1 = Sem itens 2 = Com Itens 3 = Normal)  texto[001]
           rpad(' ', 30, ' ')                  || -- N�mero Contrato CNH  Texto[030]
           RPAD('0', 3, '0')                   || -- "Sucursal da Ap�lice Anterior EXPANSAO
                                                  -- Igual ao campo ""Sucursal da Ap�lice Anterior (pos 481 e 482) "" aumentando 1 digito"  Inteiro[003]
           RPAD('0', 3, '0')                   || -- "Sucursal da Proposta EXPANSAO                    
                                                  -- Igual ao campo ""Sucursal da Proposta (pos 488 e 489)"" aumentando 1 digito"  Inteiro[003]
           rpad(' ', 15, ' ')                  || -- CPF-CNPJ de Acesso do usu�rio  texto[015]
           rpad(' ', 12, ' ')                  || -- Telefone Celular - Campo inativado no projeto MR0920 de FEV/2016, pois celular dever� ser enviado em novo formato, de acordo com linha 116. Essas 12 posi��es ser�o desconsideradas na importa��o, ou seja, pode enviar com espa�os em branco.   Texto[012]
           'S'                                 || -- Aceita receber SMS  texto[001]
           '00'                                || -- Codigo do servidor de Origem  Inteiro[002]
           rpad('0', 10, '0')                  || -- Numero da cotacao no servidor de Origem  Inteiro[010]
           rpad(rw.complend, 20, ' ')          || -- Complemento Endere�o  Texto[020]
           rpad(nvl(trim(rw.email), ' '), 60, ' ')             || -- Email do cliente  texto[060]
           rpad(to_char(rw.dtnascimento,'DDMMYYYY'),8,'0') || -- Data de Nascimento do cliente (DDMMAAAA)   Data[008]
           rw.sexo                             || -- Sexo do cliente [F]-Feminino [M]-Masculino  texto[01]
           LPAD(to_char(rw.nrcpfcgc),14,'0')   || -- CPF-CNPJ do Titular da Conta Corrente (28/02/2011)   Inteiro[014]
           RPAD(substr(rw.nmprimtl,1,40), 40, ' ') || -- Nome do Titular da Conta Corrente para D�bito (28/02/2011)  Texto[040]
           rpad('0', 8, '0')                   || -- Validade da Cota��o  Data[008]
           'S'                                 || -- Flag Calculo Autom�tico (S/N)  Texto[001]
           rpad(' ', 10, ' ')                  || -- C�digo Matricula 01 (Permitir CHAR - MR0822 - 12-06-2012)  Texto[010]
           rpad(' ', 10, ' ')                  || -- C�digo Matricula 02 (Permitir CHAR - MR0822 - 12-06-2012)  Texto[010]
           'N'                                 || -- Flg Ciente Nome (S/N)  - Projeto Cliente Serasa  Texto[001]
           'N'                                 || -- Flg Interage Nome (S/N)  - Projeto Cliente Serasa  Texto[001]
           'N'                                 || -- Flg Fechou Nome (S/N)  - Projeto Cliente Serasa  Texto[001]
           'N'                                 || -- Flg Ciente Endere�o (S/N) - Projeto Cliente Serasa  Texto[001]
           'N'                                 || -- Flg Interage Endere�o (S/N) - Projeto Cliente Serasa  Texto[001]
           'N'                                 || -- Flg Fechou Endere�o (S/N)  - Projeto Cliente Serasa  Texto[001]
           rpad(' ', 14, ' ')                  || -- Data Cota��o � Cria��o da Cota��o (Data e Hora) DDMMAAAHHMMSS  Texto[014]
           RPAD(' ', 14, ' ')                  || -- "Telefone Celular - Projeto MR0920 em FEV/2016, corre��o para que o telefone celular seja enviado no formato ""00XX99999-9999"" 
                                                  -- (exemplo: 001197474-5723)"  Texto[014]
           '1'                                 || -- "Tipo do Envio do Kit Boas Vindas - (1-Cliente / 2-Corretor) Projeto MR0925 - ST-163"  Inteiro[001]
           nvl(trim(rw.flg_email),'N')         || -- "Flg Cliente Possu� E-mail (S/N)  Projeto MR0925 - ST-668"  Texto[001]
           rw.flg_fone                         || -- "Flg Cliente Possu� Celular (S/N) Projeto MR0925 - ST-668"  Texto[001]
           'S'                                 || -- "Flg Melhor Data (S/N) ST-1302"  Texto[001]
           RPAD('0', 5, '0')                   || -- "Taxa Melhor Data (99999) ST-1302"  Valor[005]
           RPAD('0', 8, '0')                      -- "Dat-pgtoprim   (DDMMAAAA) ST-1303"  Data[008]           
    ); 


    vr_nrseq := vr_nrseq + 1;
--    vr_qtdreg05 := vr_qtdreg05 + 1;    
--    vr_nrseq05  := vr_nrseq05 + 1;
    
/*    pc_print(    
           '05'                                || -- Tipo de Registro (Constante �05�)   Inteiro[002]
           lpad(to_char(vr_nrseq),9,'0') ||       -- N�mero Sequencial do Registro
           lpad(to_char(rw.nrctrseg), 11, '0') || -- "N�mero do Documento - (EESSSPPPPPP)
                                                  -- EE => Empresa     SSS => Sucursal     PPPPPP => Num. Proposta"
           rpad(' ', 14, ' ')                  || -- Espa�o Dispon�vel   Texto[014]
           '14'                                || -- C�digo do Ramo (  Tabela a Enviar )  Inteiro[002] -- 14 (Compreensivo Residencial)
           '12'                                || -- C�digo da Modalidade ( Tabela a Enviar )  Inteiro[002] **** RENATO/HDI ainda n�o enviou os c�digos ****
           lpad('1', 6, '0')                   || -- N�mero do Local  Inteiro[006] ?????
           lpad('0', 6, '0')                   || -- N�mero do Item  Inteiro[006] ?????
           rpad('RESIDENCIAL', 40, ' ')        || -- Descri��o do Item  Texto[040] ?????
           lpad('0', 12, '0')                  || -- Taxa do Pr�mio ( Somente para proposta gen�rica )  Percentual
           lpad( to_char(vr_tab_plano(rw.tpplaseg).vl_franquia, 'fm999999999999.90'), 15, '0') || -- Valor da Franquia  ( idem )  Valor
           lpad( to_char(vr_tab_plano(rw.tpplaseg).vl_incendio, 'fm999999999999.90'), 15, '0') || -- Valor do Risco  ( idem )  Valor
           lpad( to_char(vr_tab_plano(rw.tpplaseg).vl_incendio, 'fm999999999999.90'), 15, '0') || --Valor da Import�ncia Segurada ( idem )  Valor
           lpad( to_char(vr_tab_plano(rw.tpplaseg).vl_incendio, 'fm999999999999.90'), 15, '0') || --Valor do Limite de Indeniza��o ( idem )  Valor
           lpad( '0', 15, '0') || --Valor do Desconto / Agravamento ( idem )  Valor
           LPAD(to_char(round(rw.vlpreseg - (rw.vlpreseg*0.0738),2),'fm999999999999.90'), 15, '0') || --Valor do Pr�mio L�quido ( idem )  Valor
           'N'                                           || --Flag Diverg�ncia de c�lculo (S/N)  Texto[001]
           LPAD(' ', 304, ' ') --Espa�o Dispon�vel  Texto[306]
    ); */
    
    vr_qtdreg04 := vr_qtdreg04 + 1;    
    vr_nrseq04  := vr_nrseq04 + 1;    
    
    pc_print(    
           '04'                                || -- Tipo de Registro (Constante �04�) 	 Inteiro[002]
           lpad(to_char(vr_nrseq),9,'0') ||       -- N�mero Sequencial do Registro	Inteiro[009]
           vr_nrdocmto                         || -- "N�mero do Documento - (EESSSPPPPPP)
                                                  -- EE => Empresa     SSS => Sucursal     PPPPPP => Num. Proposta"	Texto[011]
           rpad(' ', 14, ' ')                  || -- Espa�o Dispon�vel   Texto[014]
           '14'                                || -- C�digo do Ramo (  Tabela a Enviar )  Inteiro[002] -- 14 (Compreensivo Residencial)
           '12'                                || -- C�digo da Modalidade ( Tabela a Enviar )  Inteiro[002] 
           lpad('1', 6, '0')                   || -- N�mero do Local  Inteiro[006] ?????
           
           LPAD(to_char(rw.vlpreseg,'fm999999999999.90'), 15, '0') || -- Valor do Pr�mio	Valor
           RPAD(substr(rw.endereco,1,40),40,' ') || -- Endere�o do Local	Texto[040]
           RPAD(SUBSTR(rw.nmcidade,1,20),20,' ') || -- Cidade do Local	Texto[020]
           rpad(SUBSTR(rw.cdufresd,1,2),2,' ')   || -- UF do Local	Texto[002]
           to_char(rw.nrcepend,'fm00000000')     || -- CEP do Local	Texto[008]
           
           lpad(' ', 6, ' ')                     || -- C�digo da Atividade ( Somente para proposta gen�rica )	Texto[006]
           rpad('HABITUAL',40, ' ')              || -- Descri��o da Ocupa��o ( Opcional )	Texto[040]
           lpad('0', 12, '0')                    || -- Taxa de Agravamento / Desconto ( Somente Desc. de Fidelidade)	Percentual
           lpad(' ', 6, ' ')                     || -- C�digo da Ocupa��o ( Somente para proposta de produto )	Texto[006]
           lpad('0', 2, '0')                     || -- C�digo da Constru��o ( Somente para proposta de produto )	Inteiro[002]
           'N'                                   || -- Flag Tipo de Risco (N � Nenhum , S � Shopping Center)	Texto[001]
           lpad(' ', 3, ' ')                     || -- C�digo do Munic�pio (somente na exporta��o de renova��o)	Texto[003]
           rpad('0', 4, '0')                     || -- C�digo do Plano (casos Lar Seguro e Empresa Seguro)	Inteiro[004]
           lpad(' ', 3, ' ')                     || -- C�digo do Bem	Texto[003]
           rpad(rw.complend, 20, ' ')            || -- Complemento do Endere�o	Texto[020]
           lpad(' ', 8, ' ')                     || -- C�digo da Ocupa��o2 ( Somente para codigos de produtos com tam. 8)	Texto[008]
           lpad(' ', 264, ' ')                   || -- Espa�o Dispon�vel	Texto[264]
           'N'                                   || -- Flag Indica Vistoria (S/N)	Texto[001]
           lpad(' ', 4, ' ')                     || -- C�digo da Cong�nere de Renova��o	Texto[004]
           rpad(to_char(vr_nrapolice), 30, ' ')  || -- N�mero da Apolice Anterior	Texto[030]
           lpad(' ', 2, ' ')                     || -- C�digo da Empresa Anterior (Renova��o HDI)	Texto[002]
           lpad(' ', 3, ' ')                     || -- C�digo da Sucursal Anterior (Renova��o HDI)	Texto[003]
           lpad(' ', 3, ' ')                     || -- C�digo da Carteira Anterior (Renova��o HDI)	Texto[003]
           lpad('0', 3, '0')                     || -- Quantidade de Anos de Renova��o	Inteiro[003]
           lpad('0', 4, '0')                     || -- Codigo do Pacote de Assist�ncia	Inteiro[004]
           lpad('0', 15, '0')                    || -- Percentual Desconto\Agravo por tipo de Seguro	Valor
           rpad(to_char(rw.nrendres), 5, ' ')    || -- N�mero do Endere�o do Local  [novo]	Texto[005]
           lpad(' ', 30, ' ')                    || -- Contato para Inspe��o	Texto[030]
           lpad(' ', 15, ' ')                    -- telefone contato para Inspe��o	Texto[015]           
    ); 
    
    
                       
  END LOOP;


  vr_nrseq := vr_nrseq + 1;
  -- registro Posfacio
  pc_print('99' ||                                -- Tipo de Registro (Constante �00�)
           lpad(to_char(vr_nrseq),9,'0') ||       -- N�mero Sequencial do Registro
           ' '  ||                                -- Espa�o Dispon�vel
           LPAD(vr_qtdreg01, 10, '0')           ||       -- Quantidade de Registros do Tipo 01
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 02
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 03
           LPAD(vr_qtdreg04, 10, '0')           ||       -- Quantidade de Registros do Tipo 04
           LPAD(vr_qtdreg05, 10, '0')           ||       -- Quantidade de Registros do Tipo 05
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 06
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 07
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 08
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 09
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 10
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 11           
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 12
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 13
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 14
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 15
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 16
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 17
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 18
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 19
           LPAD('0',  10, '0')           ||       -- Quantidade de Registros do Tipo 20
           LPAD(' ', 288, ' ')
  );

  pc_print('',TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/rafael/', 'teste_hdi.txt', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a mem�ria alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);
  
  COMMIT;           
                
end;
