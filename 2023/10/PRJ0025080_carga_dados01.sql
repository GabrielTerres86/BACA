declare 
  type TREG is record ( idproduto         RAW(16)
                      , nmproduto         VARCHAR2(20)
                      , dsmascara_arquivo VARCHAR2(50)
                      , cdproduto         VARCHAR2(3)
                      , dhregistro        DATE );
 
  type TNESTED is table of TREG index by binary_integer;
  
  NTAB TNESTED;  
  
  vseq_tab number;                    

  vtem integer;
  
  cursor C1 (pcdproduto VARCHAR2) is 
    select * 
      from pagamento.TAVANS_PRODUTO 
     where DHINATIVACAO is null
       and cdproduto = pcdproduto;
  R1 C1%rowtype;
  
  cursor C2 (p_nrcnpj number) is 
    select * 
      from pagamento.tbvans_van 
     where DHINATIVACAO is null
       and nrcnpj = p_nrcnpj;
  R2 C2%rowtype;
    
  cursor C3 (p_cdcooperativa number, p_nrconta_corrente number) is 
    select * 
      from pagamento.tbvans_van_cooperado 
     where DHINATIVACAO is null
       and cdcooperativa = p_cdcooperativa 
       and nrconta_corrente = p_nrconta_corrente;
  R3 C3%rowtype;
  
  cursor C5 is
      select *
        from cecred.crapccc
       where cdcooper = 1 
         and nrdconta = 99914492 
         and nrconven = 1;
         
  R5 C5%ROWTYPE;
  
  v_idvan           RAW(16) := null;
  v_idvan_cooperado RAW(16) := null;
  
begin
  open c5;
  fetch c5 into r5;
  if c5%found then
    update cecred.CRAPCCC
       set IdRetorn = 3
     where cdcooper = r5.cdcooper 
         and nrdconta = r5.nrdconta
         and nrconven = r5.nrconven;
  end if;
  close c5;

  open c2 (03813865000165);
  fetch c2 into r2;
  if c2%notfound then 
    v_idvan := SYS_GUID();
    insert into pagamento.tbvans_van (idvan, nmvan, nmrazao_social, nrcnpj, dspasta_envia, dspasta_enviados, 
                    dspasta_recebe, dspasta_recebidos )
    values (v_idvan,'Nexxera','Nexxera Tecnologia e Serviços',03813865000165,'/usr/connect/nexxera/envia','/usr/connect/nexxera/enviados','/usr/connect/nexxera/recebe','/usr/connect/nexxera/recebidos');
  else
    v_idvan := r2.idvan;    
  end if;
  close c2;
  
  open c3 (1,99914492);
  fetch c3 into r3;
  if c3%notfound then 
    v_idvan_cooperado := SYS_GUID();
    
    insert into pagamento.tbvans_van_cooperado (idvan_cooperado, idvan, cdcooperativa, nrconta_corrente)
    values (v_idvan_cooperado,v_idvan,1,99914492);
  else
    v_idvan_cooperado := r3.idvan_cooperado;  
  end if;
  close c3;
 
  vseq_tab := 0;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'Custódia de cheques';
  ntab(vseq_tab).dsmascara_arquivo    := 'CST_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'CST';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'Extrato C/C';
  ntab(vseq_tab).dsmascara_arquivo    := 'EXT_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'EXT';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'TED/Transferência';
  ntab(vseq_tab).dsmascara_arquivo    := 'TED_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'TED';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'Folha de Pagamento';
  ntab(vseq_tab).dsmascara_arquivo    := 'FOL_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'FOL';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'Pagamentos';
  ntab(vseq_tab).dsmascara_arquivo    := 'PGT_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'PGT';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'Cobrança Bancária';
  ntab(vseq_tab).dsmascara_arquivo    := 'CBR_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'CBR';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'Transferência PIX';
  ntab(vseq_tab).dsmascara_arquivo    := 'PIX_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'PIX';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  vseq_tab := vseq_tab + 1;
  ntab(vseq_tab).idproduto            := SYS_GUID();
  ntab(vseq_tab).nmproduto            := 'Recebimento DDA';
  ntab(vseq_tab).dsmascara_arquivo    := 'DDA_XXX_YYYYYYYYYYYYY_ZZZZZZ.RRR';
  ntab(vseq_tab).cdproduto            := 'DDA';
  ntab(vseq_tab).dhregistro           := SYSDATE;
  
  For x in 1..ntab.count loop
    open c1 (ntab(x).cdproduto);
    fetch c1 into r1;
    
    if c1%notfound then
      insert into pagamento.TAVANS_PRODUTO (idproduto , nmproduto, dsmascara_arquivo, cdproduto, dhregistro )
        values (ntab(x).idproduto,ntab(x).nmproduto, ntab(x).dsmascara_arquivo ,ntab(x).cdproduto,ntab(x).dhregistro );
      if ntab(x).cdproduto = 'CST' then
        insert into pagamento.tbvans_van_cooperado_produto (idvan_cooperado, idproduto)
          values (v_idvan_cooperado,ntab(x).idproduto);  
      end if;    
    end if;
    close c1;    
  end loop;
  
  commit;
exception
  when others then
    if c1%isopen then
      close c1;
    end if; 
    if c2%isopen then
      close c2;
    end if;  
    if c3%isopen then
      close c3;
    end if;
    if c5%isopen then
      close c5;
    end if; 

    cecred.pc_internal_exception(pr_compleme => 'PRJ0025080_carga_dados01');

    rollback;
end;
