PL/SQL Developer Test script 3.0
122
-- Created on 15/10/2020 by F0030367 
declare 
  -- Local variables here
  i integer;
  
  vr_dstextab craptab.dstextab%TYPE;

  vr_valormin NUMBER  :=0;
  vr_valormax NUMBER  :=0;
  vr_datadvig VARCHAR2(10);
  vr_pgtosegu NUMBER  :=0;
  vr_subestip VARCHAR2(25);
  vr_sglarqui VARCHAR2(2);
  vr_nrsequen varchar2(5):='0';
  vr_vallidps NUMBER  :=0;

  vr_endereco VARCHAR2(100);
  vr_login VARCHAR2(100);
  vr_senha VARCHAR2(100);
  vr_seqarquivo varchar2(5):=0;
  vr_apolice VARCHAR2(16):=0;
  vr_fimvigen VARCHAR2(10);
  vr_taxpermor NUMBER  :=0;
  vr_taxperinv NUMBER :=0;
     
  vr_vlpercmo NUMBER :=0;
  vr_vlpercin NUMBER :=0;
  
  cursor cr_crapcop is
  select cdcooper from crapcop where flgativo = 1;
begin
  -- Test statements here
  
  -- crapaca 
  BEGIN
    UPDATE crapaca aca
       SET aca.lstparam = aca.lstparam || ', pr_fimvigen, pr_taxpermor, pr_taxperinv'
     WHERE aca.nmdeacao = 'TAB049_ALTERAR';
    COMMIT;
  END;
  
  -- Craptab
  BEGIN
    UPDATE craptab tab
       SET tab.dstextab = tab.dstextab || ' 31/01/2021'
     WHERE upper(tab.nmsistem) = 'CRED'
       AND upper(tab.tptabela) = 'USUARI'
       AND tab.cdempres        = 11
       AND upper(tab.cdacesso) = 'SEGPRESTAM'
       AND tab.tpregist        = 0;
    COMMIT;
  END;
  
  for rw_crapcop in cr_crapcop loop
  
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => rw_crapcop.cdcooper
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
        vr_pgtosegu := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
        vr_subestip := SUBSTR(vr_dstextab,59,25);
        vr_sglarqui := SUBSTR(vr_dstextab,85,2);
        vr_nrsequen := SUBSTR(vr_dstextab,88,5);
        vr_vallidps := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,94,12));
        vr_endereco := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => rw_crapcop.cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_ENDERECO');
        vr_login    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => rw_crapcop.cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_LOGIN');
        vr_senha    := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                 pr_cdcooper => rw_crapcop.cdcooper,
                                                 pr_cdacesso => 'PRST_FTP_SENHA');
        vr_seqarquivo := SUBSTR(vr_dstextab,139,5);
        vr_apolice  := SUBSTR(vr_dstextab,144,11);
        vr_fimvigen := SUBSTR(vr_dstextab,156,10);
        vr_taxpermor := vr_vlpercmo;
        vr_taxperinv := vr_vlpercin;
      END IF;

      vr_dstextab := to_char(vr_valormin,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                     to_char(vr_valormax,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                     to_char(vr_valormin,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                     vr_datadvig                                                              || ' ' ||
                     to_char(vr_pgtosegu,   'FM0D00000'     ,'NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                     lpad(vr_subestip,25,'0')                                                 || ' ' ||
                     lpad(vr_sglarqui,2,' ')                                                  || ' ' ||
                     lpad(vr_nrsequen,5,'0')                                                  || ' ' ||
                     to_char(vr_vallidps,   'FM000000000D00','NLS_NUMERIC_CHARACTERS='',.''') || ' ' ||
                     lpad(vr_endereco,16,' ')                                                  || ' ' ||
                     lpad(vr_login,6,' ')                                                      || ' ' ||
                     lpad(vr_senha,7,' ')                                                      || ' ' ||
                     lpad(vr_seqarquivo,5,'0')                                                 || ' ' ||
                     Lpad(vr_apolice,16,'0')                                                   || ' ' ||
                     vr_fimvigen
                     || '';
      BEGIN
        UPDATE craptab tab
           SET tab.dstextab = vr_dstextab
         WHERE tab.cdcooper        = rw_crapcop.cdcooper
           AND upper(tab.nmsistem) = 'CRED'
           AND upper(tab.tptabela) = 'USUARI'
           AND tab.cdempres        = 11
           AND upper(tab.cdacesso) = 'SEGPRESTAM'
           AND tab.tpregist        = 0;
      EXCEPTION
        WHEN OTHERS THEN
          dbms_output.put_line('Erro ao atualizar Parametros do Seguro - craptab');

      END;
  end loop;
  commit;
end;
0
0
