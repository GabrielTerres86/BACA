PL/SQL Developer Test script 3.0
171
-- Created on 06/12/2019 by F0030367 
declare 

vr_dscritic VARCHAR2(5000);
vr_resultado VARCHAR2(32000);
--
vr_situacao VARCHAR2(50);
vr_tppessoa VARCHAR2(50);
vr_dscpfcnpj VARCHAR2(50);
vr_nomepaga VARCHAR2(100);
vr_dtvencto VARCHAR2(50);
vr_dscodbar VARCHAR2(100);
vr_linhadig VARCHAR2(100); --elton
vr_vlrtitulo VARCHAR2(50);
--
vr_inicio NUMBER;
vr_tamanho NUMBER;
--
vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/INC0085009';
vr_nmarqimp        VARCHAR2(100)  := 'INC0085009-relacao2.csv';
vr_ind_arquiv      utl_file.file_type;

 CURSOR cr_tbcobran_consulta_titulo (pr_dscodbar IN cecred.tbcobran_consulta_titulo.DSCODBAR%TYPE) IS
		SELECT o.cdcooper
		FROM   tbcobran_consulta_titulo o
		WHERE  o.dscodbar = pr_dscodbar;    
 rw_tbcobran_consulta_titulo cr_tbcobran_consulta_titulo%ROWTYPE;
 
 CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
		SELECT s.nrdconta
		FROM   crapass s
		WHERE  s.cdcooper = pr_cdcooper
      AND  s.nrcpfcgc = pr_nrcpfcgc;
 rw_crapass cr_crapass%ROWTYPE;

vr_dssituacao VARCHAR2(100);
vr_cdcooper INTEGER;
vr_nrdconta NUMBER;
BEGIN 
       
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
    dbms_output.put_line('Erro ao criar arquivo');
  END IF;  
  
  gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, 'Coop;Conta;CPF_CNPJ;Tipo_Pagador;Pagador;CodBarras;LinhaDig;Situacao;Valor_Titulo;Vencimento'); 
  
  FOR r001 IN(
  select resultado
    from TBJDNPCRCBLEG_JD2LG_CONS_RET@Jdnpcbisql t
    where STRETJDCONS = 'RC'
      AND DTHRRESULTADO > '20210406151500' -- PROD
  --    AND DTHRRESULTADO = '20191122151523' -- DEV
     ) LOOP
     
     vr_resultado:= r001.resultado;

     --busca situacao
     vr_inicio := instr(vr_resultado,'<SitTitPgto>')+length('<SitTitPgto>');
     vr_tamanho := instr(vr_resultado,'</SitTitPgto>')-vr_inicio;
     vr_situacao:= substr(vr_resultado,vr_inicio,vr_tamanho);
     --
     --busca tppessoa pagador
     vr_inicio := instr(vr_resultado,'<TpPessoaPagdr>')+length('<TpPessoaPagdr>');
     vr_tamanho := instr(vr_resultado,'</TpPessoaPagdr>')-vr_inicio;
     vr_tppessoa:= substr(vr_resultado,vr_inicio,vr_tamanho);
     --busca cnpj pagador
     vr_inicio := instr(vr_resultado,'<CNPJ_CPFPagdr>')+length('<CNPJ_CPFPagdr>');
     vr_tamanho := instr(vr_resultado,'</CNPJ_CPFPagdr>')-vr_inicio;
     vr_dscpfcnpj:= substr(vr_resultado,vr_inicio,vr_tamanho);
     --busca nome pagador 
     vr_inicio := instr(vr_resultado,'<NomFantsPagdr>')+length('<NomFantsPagdr>');
     vr_tamanho := instr(vr_resultado,'</NomFantsPagdr>')-vr_inicio;
     vr_nomepaga:= substr(vr_resultado,vr_inicio,vr_tamanho);
     --busca vencimento 
     vr_inicio := instr(vr_resultado,'<DtVencTit>')+length('<DtVencTit>');
     vr_tamanho := instr(vr_resultado,'</DtVencTit>')-vr_inicio;
     vr_dtvencto:= substr(vr_resultado,vr_inicio,vr_tamanho);
     --busca Cod. Barras 
     vr_inicio := instr(vr_resultado,'<NumCodBarras>')+length('<NumCodBarras>');
     vr_tamanho := instr(vr_resultado,'</NumCodBarras>')-vr_inicio;
     vr_dscodbar:= substr(vr_resultado,vr_inicio,vr_tamanho);
     /*elton*/
          --busca Linha digitavel <NumLinhaDigtvl>
     vr_inicio := instr(vr_resultado,'<NumLinhaDigtvl>')+length('<NumLinhaDigtvl>');
     vr_tamanho := instr(vr_resultado,'</NumLinhaDigtvl>')-vr_inicio;
     vr_linhadig:= substr(vr_resultado,vr_inicio,vr_tamanho);
    /* elton */
     
     --busca Valor Titulo  
     vr_inicio := instr(vr_resultado,'<VlrTit>')+length('<VlrTit>');
     vr_tamanho := instr(vr_resultado,'</VlrTit>')-vr_inicio;
     vr_vlrtitulo:= substr(vr_resultado,vr_inicio,vr_tamanho);
     --
     IF vr_situacao = '01' THEN
        vr_dssituacao := 'Boleto baixado';
     ELSIF vr_situacao = '02' THEN     
        vr_dssituacao := 'Bloqueado para pagamento';
     ELSIF vr_situacao = '03' THEN     
        vr_dssituacao := 'Boleto encontrado na base centralizada e Cliente Beneficiário inapto na Instituição emissora do título.';
     ELSIF vr_situacao = '04' THEN     
        vr_dssituacao := 'Boleto encontrado na base centralizada e Cliente Beneficiário em análise na Instituição emissora do título';              
     ELSIF vr_situacao = '05' THEN     
        vr_dssituacao := 'Boleto encontrado na base centralizada e Cliente Beneficiário em análise na Instituição emissora do título';
     ELSIF vr_situacao = '06' THEN     
        vr_dssituacao := 'Boleto excedeu o limite de pagamentos parciais';
     ELSIF vr_situacao = '07' THEN     
        vr_dssituacao := 'Baixa operacional integral já registrada';
     ELSIF vr_situacao = '08' THEN     
        vr_dssituacao := 'Baixa operacional já registrada para título que não permite pagamento parcial';
     ELSIF vr_situacao = '09' THEN     
        vr_dssituacao := 'Boleto excedeu o valor de saldo para pagamento parcial para o tipo de modelo de cálculo 04';
     ELSIF vr_situacao = '10' THEN     
        vr_dssituacao := 'Boleto encontrado na base centralizada e Cliente Beneficiário inapto em Instituição diferente da emissora.';
     ELSIF vr_situacao = '11' THEN     
        vr_dssituacao := 'Boleto encontrado na base centralizada e Cliente Beneficiário em análise em Instituição diferente da emissora.';
     ELSIF vr_situacao = '12' THEN     
        vr_dssituacao := 'Boleto encontrado na base centralizada e Cliente Beneficiário apto.';
     END IF;
    
      --Dados da Cooperativa
      OPEN cr_tbcobran_consulta_titulo(pr_dscodbar => TRIM(vr_dscodbar));
      FETCH cr_tbcobran_consulta_titulo INTO rw_tbcobran_consulta_titulo;

	    --Se nao encontrou
      IF cr_tbcobran_consulta_titulo%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_tbcobran_consulta_titulo;
          vr_cdcooper:=0;
      ELSE     
        --Fechar Cursor
        CLOSE cr_tbcobran_consulta_titulo;      
        vr_cdcooper:= rw_tbcobran_consulta_titulo.cdcooper; 
      END IF;   

    --Dados da Cooperativa
      OPEN cr_crapass(pr_cdcooper => vr_cdcooper,
                      pr_nrcpfcgc => vr_dscpfcnpj);
      FETCH cr_crapass INTO rw_crapass;

	    --Se nao encontrou
      IF cr_crapass%NOTFOUND THEN
          --Fechar Cursor
          CLOSE cr_crapass;
          vr_nrdconta:=0;
      ELSE     
        --Fechar Cursor
        CLOSE cr_crapass;      
        vr_nrdconta:= rw_crapass.nrdconta;
      END IF;   
    
  -- Escreve no Arquivo CSV
  gene0001.pc_escr_linha_arquivo( vr_ind_arquiv, 
                                  nvl(vr_cdcooper,0)|| ';' || to_char(vr_nrdconta) ||';'''||to_char(vr_dscpfcnpj)||''';'||
                                  vr_tppessoa||';'||replace(vr_nomepaga,';','')||';'''||
                                  to_char(vr_dscodbar)||''';'||  to_char(vr_linhadig)||''';'|| vr_dssituacao||';'||
                                  replace(vr_vlrtitulo,'.',',')||';'||vr_dtvencto||
                                  chr(13)); 
     
  END LOOP;
  
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;   
end;
0
0
