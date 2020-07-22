declare 
  -- Local variables here
  i integer;
  vr_dslobdev      CLOB;
  vr_dsbufdev      VARCHAR2(32700);  
  vr_sub           VARCHAR2(3);
  
CURSOR cr_crapseg IS  
    SELECT cop.cdcooper
	     , cop.nmrescop
         , ass.nmprimtl
         , ass.nrcpfcgc
		 , ass.nrdconta
         , seg.nrctrseg
         , seg.tpplaseg
	FROM crapseg seg
         , crapass ass
         , crapcop cop
        
     WHERE seg.cdcooper = 1 /*Migracao 31/01: 7, 9, 11, 14 + regionais VIACREDI*/ 
       AND seg.cdsegura  = 5011
       AND seg.tpseguro  = 3
       AND seg.cdsitseg  = 2
	   AND seg.dtcancel = trunc(sysdate)
	  -- AND seg.cdmotcan = 1 
	   AND seg.cdopecnl = '1'
       AND ass.cdcooper = seg.cdcooper
       AND ass.nrdconta = seg.nrdconta 
       AND ass.cdagenci	IN (8,29,32,48,65,70,71,86,197,9,53,58,61,76,196,204,206)
       AND cop.cdcooper = ass.cdcooper
       
     ORDER BY seg.cdcooper; 	 
	 
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

  /* CANCELAR SEGUROS VIDA */ 
   UPDATE crapseg
     SET crapseg.cdsitseg = 2
        , crapseg.dtcancel = trunc(sysdate) /*definir*/
        , crapseg.dtfimvig = trunc(sysdate) /*definir - atribuir mesma data de cancelamento*/
        , crapseg.cdmotcan = 0 /* não é informado para este tipo de seguro */ 
        , crapseg.cdopeexc = '1'
        , crapseg.cdageexc = 1
        , crapseg.dtinsexc = trunc(sysdate) /*definir - atribuir mesma data de cancelamento*/
        , crapseg.cdopecnl = '1'
  
   WHERE crapseg.cdcooper = 1 /* Ajustar - conforme cada migracao */ 
     AND crapseg.cdsitseg = 1 
     AND crapseg.tpseguro = 3       /*VIDA*/
     AND crapseg.cdsegura = 5011   /* CHUBB */ 
	 AND --  Regionais 3 E 9
	 exists (select * from crapass where crapass.cdcooper = crapseg.cdcooper and crapass.nrdconta = crapseg.nrdconta and crapass.cdagenci IN (8,29,32,48,65,70,71,86,197,9,53,58,61,76,196,204,206));
  
  
  COMMIT;
  
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_dslobdev, TRUE);
  dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
  vr_dsbufdev := NULL;
  
  pc_print('COOPERATIVA;' 	|| 
           'SUB;'           ||
           'NOME;'		 	|| 
           'CPF;'		 	|| 
		   'CONTA;'		 	||
           'CONTRATO;' 		|| 
           'PLANO;' 
          );
		  
  FOR rw IN cr_crapseg LOOP	
  
  CASE rw.cdcooper 
    WHEN  1 THEN vr_sub := '13';
    WHEN  2 THEN vr_sub := '08';
    WHEN  5 THEN vr_sub := '01';
    WHEN  6 THEN vr_sub := '10';
    WHEN  7 THEN vr_sub := '02';
    WHEN  8 THEN vr_sub := '09';
    WHEN  9 THEN vr_sub := '06';
    WHEN 10 THEN vr_sub := '03';
    WHEN 11 THEN vr_sub := '04';
    WHEN 12 THEN vr_sub := '11';
    WHEN 13 THEN vr_sub := '12';
    WHEN 14 THEN vr_sub := '05';
    WHEN 16 THEN vr_sub := '07';                    
  END CASE;            
    
    
  
      pc_print( rw.nmrescop             || ';' || -- COOPERATIVA
	            vr_sub                  || ';' || -- SUB  
				rw.nmprimtl         	|| ';' || -- NOME
			    LPAD(to_char(rw.nrcpfcgc),11,'0')       || ';' || -- CPF
				to_char(rw.nrdconta)    || ';' || -- CONTA
				to_char(rw.nrctrseg)    || ';' || -- CONTRATO
				to_char(rw.tpplaseg)   	|| ';' 
             );
  
  END LOOP;
  
  pc_print('',TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/diego/', 'ICATU_cancelados_31012020_regionais_viacredi' || '.txt', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);
      
  
END;

 
