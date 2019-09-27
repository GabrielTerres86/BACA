declare 
  -- Local variables here
  i integer;
  vr_dslobdev      CLOB;
  vr_dsbufdev      VARCHAR2(32700);  
  
CURSOR cr_crapseg IS  
    SELECT cop.nmrescop
         , ass.nmprimtl
         , ass.nrcpfcgc
		 , ass.nrdconta
         , seg.nrctrseg
         , seg.tpplaseg
	FROM crapseg seg
         , crapass ass
         , crapcop cop
        
     WHERE seg.cdcooper IN (2,6,8,12,13)
       AND seg.cdsegura  = 5011
       AND seg.tpseguro  = 11
       AND seg.cdsitseg  = 2
	   AND seg.dtcancel = trunc(sysdate)
	   AND seg.cdmotcan = 1 
	   AND seg.cdopecnl = '1'
       AND ass.cdcooper = seg.cdcooper
       AND ass.nrdconta = seg.nrdconta  
       AND cop.cdcooper = ass.cdcooper
       
     ORDER BY seg.cdcooper; 	 
	 
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

 
  /* CANCELAR SEGUROS CASA */ 
  UPDATE crapseg
     SET crapseg.cdsitseg = 2
        , crapseg.dtcancel = trunc(sysdate) -- cancelamento ocorrera em 30/09/2019 
     -- , crapseg.dtfimvig = crapseg.dtfimvig
        , crapseg.cdmotcan = 1 -- N�o interesse pelo Seguro 
        , crapseg.cdopeexc = '1'
        , crapseg.cdageexc = 1
        , crapseg.dtinsexc = crapseg.dtcancel 
        , crapseg.cdopecnl = '1'
  
   WHERE crapseg.cdcooper IN (2,6,8,12,13) -- 2-ACREDICOOP, 6-UNILOS, 8-CREDELESC, 12-CREVISC e 13-CIVIA 
     AND crapseg.cdsitseg IN (1,3) -- novo, renovado  
     AND crapseg.tpseguro = 11     -- CASA 
     AND crapseg.cdsegura = 5011;  -- CHUBB  
  
  COMMIT;
  
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_dslobdev, TRUE);
  dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
  vr_dsbufdev := NULL;
  
  pc_print('COOPERATIVA;' 	|| 
           'NOME;'		 	|| 
           'CPF;'		 	|| 
		   'CONTA;'		 	||
           'CONTRATO;' 		|| 
           'PLANO;' 
          );
		  
  FOR rw IN cr_crapseg LOOP	  
  
      pc_print( rw.nmrescop             || ';' || -- COOPERATIVA
				rw.nmprimtl         	|| ';' || -- NOME
			    LPAD(to_char(rw.nrcpfcgc),11,'0')       || ';' || -- CPF
				to_char(rw.nrdconta)    || ';' || -- CONTA
				to_char(rw.nrctrseg)    || ';' || -- CONTRATO
				to_char(rw.tpplaseg)   	|| ';' 
             );
  
  END LOOP;
  
  pc_print('',TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/diego/', 'HDI_migracao_30092019' || '.txt', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a mem�ria alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);
      
  
END;

 
