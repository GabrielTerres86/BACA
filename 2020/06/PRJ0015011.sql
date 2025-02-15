
BEGIN

DECLARE   
  CURSOR cr_coops IS     
    SELECT crapcop.cdcooper       
      FROM crapcop;   
  rw_coops cr_coops%ROWTYPE;    
  
  vr_valormin NUMBER  :=0;
  vr_valormax NUMBER  :=0;
  vr_datadvig VARCHAR2(10);      
  vr_pgtosegu VARCHAR2(7);
  vr_subestip VARCHAR2(25);
  vr_sglarqui VARCHAR2(2);
  vr_nrsequen VARCHAR2(5):=0;
  vr_vallidps NUMBER  :=0;    
  
  vr_endereco VARCHAR2(25);
  vr_login    VARCHAR2(25);  
  vr_senha    VARCHAR2(25);
  vr_seqarquivo VARCHAR2(5):=0;
  vr_apolice VARCHAR2(25);
  
  vr_dstextab craptab.dstextab%TYPE; 
  
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
  vr_dscritic VARCHAR2(1000);        --> Desc. Erro

  -- Tratamento de erros
  vr_exc_saida EXCEPTION;
  
  BEGIN

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	values ('CRED', 0, 'DATA_CORTE_PRESTAMISTA', 'Parâmetro que indica a quantidade de dias para corte prestamista', 
	to_date('19-08-2020', 'DD/MM/RRRR') );
	
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'ENVIA_SEG_PRST_EMAIL', 'Email para envio de avisos de erro ao processar pc_envia_arq_seg_prst', 'seguros@ailos.coop.br');

  update crapaca 
  set lstparam = lstparam || ', pr_endereco, pr_login, pr_senha, pr_seqarquivo, pr_apolice'
  where nmdeacao = 'TAB049_ALTERAR';

  FOR rw_coops IN cr_coops LOOP
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	values ('CRED', rw_coops.cdcooper, 'PRST_PERC_MORTE', 'Parâmetro que indica a porcentagem do valor para calculo de premio morte no prestamista', 
	to_char(0.00878));
    
    insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
	values ('CRED', rw_coops.cdcooper, 'PRST_PERC_INVALIDEZ', 'Parâmetro que indica a porcentagem do valor para calculo de premio invalidez no prestamista', 
	to_char(0.00877));
    
    -- Buscar dados da TAB
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_coops.cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'SEGPRESTAM'
                                             ,pr_tpregist => 0);

    --Se encontrou parametro, atribui valor. Caso contrario, mantem Zero 
    IF TRIM(vr_dstextab) IS NOT NULL THEN
      -- EFETUA OS PROCEDIMENTOS COM O DADO RETORNADO DA CRAPTAB
      vr_valormin := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,12));
      vr_valormax := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));        
      vr_datadvig := SUBSTR(vr_dstextab,40,10);
      vr_pgtosegu := to_char(gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7)),'FM0D00000');  
      vr_subestip := SUBSTR(vr_dstextab,59,25);
      vr_sglarqui := SUBSTR(vr_dstextab,85,2);
      vr_nrsequen := SUBSTR(vr_dstextab,88,5);
      vr_vallidps := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,94,12));
      --1363
      vr_endereco   := 'ftp.chubb.com.br';    
      vr_login      := 'cb3040';  
      vr_senha      := 'Ce@FTP1';  
      --????  
      vr_seqarquivo := '1';
      vr_apolice := '8010009';
    END IF;
    
    --dbms_output.put_line(rw_coops.cdcooper || ' - Anti -   ' || vr_dstextab);
    
    vr_dstextab := to_char(vr_valormin,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_valormax,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   to_char(vr_valormin,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||                   
                   vr_datadvig                                                              || ' ' ||                   
                   to_char(vr_pgtosegu,   'FM0D00000'     ,'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||                   
                   lpad(vr_subestip,25,'0')                                                 || ' ' ||                   
                   lpad(vr_sglarqui,2,' ')                                                  || ' ' ||                                                         
                   lpad(vr_nrsequen,5,'0')                                                  || ' ' ||                                                                            
                   to_char(vr_vallidps,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                   lpad(vr_endereco,16,' ')                                                 || ' ' ||      
                   lpad(vr_login,6,' ')                                                     || ' ' ||      
                   lpad(vr_senha,7,' ')                                                     || ' ' ||                                                                    
                   lpad(vr_seqarquivo,5,'0')                                                || ' ' ||
                   lpad(vr_apolice,7,'0')
                   ||'' ;  
                         
     --dbms_output.put_line(rw_coops.cdcooper || ' - Novo -   ' || vr_dstextab);
     
     BEGIN
       UPDATE craptab tab
          SET tab.dstextab = vr_dstextab
        WHERE tab.cdcooper        = rw_coops.cdcooper
          AND upper(tab.nmsistem) = 'CRED'
          AND upper(tab.tptabela) = 'USUARI'
          AND tab.cdempres        = 11
          AND upper(tab.cdacesso) = 'SEGPRESTAM'
          AND tab.tpregist        = 0;
          
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao atualizar Parametros!';
        RAISE vr_exc_saida;

    END;
  
  END LOOP;
  
  COMMIT;
  
  EXCEPTION
    WHEN vr_exc_saida THEN
      IF vr_cdcritic <> 0 THEN
        dbms_output.put_line(GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic));
      ELSE
        dbms_output.put_line(vr_dscritic);
      END IF;
      ROLLBACK;
    WHEN OTHERS THEN
      dbms_output.put_line('Erro geral na rotina da tela - ' || SQLERRM);
      ROLLBACK;
  END;
END;
