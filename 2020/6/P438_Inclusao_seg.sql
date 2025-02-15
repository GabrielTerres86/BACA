--> Cria��o da SEGEMPR para Automovei e Imoveis
declare
  cursor cr_crapcop is
    select *
      from crapcop e
     where e.cdcooper <> 3
       and e.flgativo = 1;
  rw_crapcop cr_crapcop%rowtype; 
 
  cursor cr_segmento (pr_cdcooper number)is 
    select *
      from tbepr_segmento s
     where s.idsegmento = 1
       and s.cdcooper = pr_cdcooper;   
  rw_segmento cr_segmento%rowtype;
  
  vr_cdlincrd VARCHAR2(30);
  vr_tab_lscmdmod gene0002.typ_split;  

begin
  
  for rw_crapcop in cr_crapcop loop
    
    open cr_segmento(pr_cdcooper => rw_crapcop.cdcooper);
    fetch cr_segmento into rw_segmento;
    close cr_segmento;
  
    --> Aquisi��o Autom�vel
    Begin
      insert into tbepr_segmento 
                 (cdcooper, 
                  idsegmento, 
                  dssegmento, 
                  qtsimulacoes_padrao, 
                  nrvariacao_parc, 
                  nrmax_proposta, 
                  nrintervalo_proposta, 
                  dssegmento_detalhada, 
                  qtdias_validade, 
                  tplimite_valor) 
          values (rw_crapcop.cdcooper, 
                  3, --idsegmento, 
                  'Aquisi��o Autom�vel', --dssegmento, 
                  rw_segmento.qtsimulacoes_padrao, 
                  rw_segmento.nrvariacao_parc, 
                  rw_segmento.nrmax_proposta, 
                  rw_segmento.nrintervalo_proposta, 
                  'Para comprar ou trocar de carro, moto ou caminh�o.'||chr(13)||'Financie o seu autom�vel com a praticidade do d�bito em conta no dia escolhido.', 
                  rw_segmento.qtdias_validade, 
                  1 );--tplimite_valor
    
    exception
       when dup_val_on_index then
         null; 
    end; 
    
    --> Aquisi��o Im�vel
    Begin
      insert into tbepr_segmento 
                 (cdcooper, 
                  idsegmento, 
                  dssegmento, 
                  qtsimulacoes_padrao, 
                  nrvariacao_parc, 
                  nrmax_proposta, 
                  nrintervalo_proposta, 
                  dssegmento_detalhada, 
                  qtdias_validade, 
                  tplimite_valor) 
          values (rw_crapcop.cdcooper, 
                  4,                     --idsegmento, 
                  'Aquisi��o Im�vel',    --dssegmento, 
                  rw_segmento.qtsimulacoes_padrao, 
                  rw_segmento.nrvariacao_parc, 
                  rw_segmento.nrmax_proposta, 
                  rw_segmento.nrintervalo_proposta,
                  'Aqui voc� pode simular o financiamento da sua moradia.'||chr(13)||'Para contratar visite um Posto de Atendimento.',
                  rw_segmento.qtdias_validade, 
                  1 );--tplimite_valor
    
    exception
       when dup_val_on_index then
         null; 
    end; 
    
    
    -- Automovel
    Begin
      insert into tbepr_segmento_canais_perm 
                 (cdcooper, 
                  idsegmento, 
                  cdcanal, 
                  tppermissao, 
                  vlmax_autorizado)
          select rw_crapcop.cdcooper,
                 3 idsegmento,
                 t.cdcanal,
                 2 tppermissao,
                 50000
            from tbepr_segmento_canais_perm t
           where t.cdcooper = rw_crapcop.cdcooper
             and t.idsegmento = 1
             and t.cdcanal in (3, 10);
           
    exception
       when dup_val_on_index then
         null; 
    end;  
    
    
    -- Imovel
    Begin
      insert into tbepr_segmento_canais_perm 
                 (cdcooper, 
                  idsegmento, 
                  cdcanal, 
                  tppermissao, 
                  vlmax_autorizado)
          select rw_crapcop.cdcooper,
                 4 idsegmento,
                 t.cdcanal,
                 1 tppermissao,
                 100000
            from tbepr_segmento_canais_perm t
           where t.cdcooper = rw_crapcop.cdcooper
             and t.idsegmento = 1
             and t.cdcanal in (3, 10);
           
    exception
       when dup_val_on_index then
         null; 
    end;
    
    
    -- Automovel Fisico 
    Begin
      insert into tbepr_segmento_tppessoa_perm 
                 (cdcooper, idsegmento,tppessoa)
          values (rw_crapcop.cdcooper,3,1);           
    exception
       when dup_val_on_index then
         null; 
    end;
    --Automovel Juridico 
    Begin
      insert into tbepr_segmento_tppessoa_perm 
                 (cdcooper, idsegmento,tppessoa)
          values (rw_crapcop.cdcooper,3,2);           
    exception
       when dup_val_on_index then
         null; 
    end;
    
    -- Imovel Fisico 
    Begin
      insert into tbepr_segmento_tppessoa_perm 
                 (cdcooper, idsegmento,tppessoa)
          values (rw_crapcop.cdcooper,4,1);           
    exception
       when dup_val_on_index then
         null; 
    end;
    --Imovel Juridico 
    Begin
      insert into tbepr_segmento_tppessoa_perm 
                 (cdcooper, idsegmento,tppessoa)
          values (rw_crapcop.cdcooper,4,2);           
    exception
       when dup_val_on_index then
         null; 
    end;  
    
     select case rw_crapcop.cdcooper 
        when 1 then '15201;15301;15401'
        when 2 then '818;819;0'
        when 3 then '0;0;0'
        when 4 then '0;0;0'
        when 5 then '333;334;335'
        when 6 then '132;133;134'
        when 7 then '0;0;0'
        when 8 then '0;0;0;'
        when 9 then '0;0;0'
        when 10 then '62;63;64'
        when 11 then '379;380;381'
        when 12 then '285;286;287'
        when 13 then '372;373;374'
        when 14 then '1107;1108;1109'
        when 15 then '0;0;0'
        when 16 then '7050;7060;0'
        when 17 then '0;0;0'
        else '0;0;0' end
        into  vr_cdlincrd 
      from dual;   
    
    BEGIN
      
      vr_tab_lscmdmod := gene0002.fn_quebra_string(pr_string => vr_cdlincrd ,pr_delimit => ';');
      
      IF vr_tab_lscmdmod(1) > 0 THEN
        insert into tbepr_subsegmento (CDCOOPER, IDSEGMENTO, IDSUBSEGMENTO, DSSUBSEGMENTO, CDLINHA_CREDITO, FLGGARANTIA, TPGARANTIA, PEMAX_AUTORIZADO, PEEXCEDENTE, VLMAX_PROPOSTA, CDFINALIDADE)
          values (rw_crapcop.cdcooper, 3, 31, 'Novo', vr_tab_lscmdmod(1), 1, 0, 30.00, 5.00, 0.00, 77);
      END IF;
      
      IF vr_tab_lscmdmod(2) > 0 THEN 
        insert into tbepr_subsegmento (CDCOOPER, IDSEGMENTO, IDSUBSEGMENTO, DSSUBSEGMENTO, CDLINHA_CREDITO, FLGGARANTIA, TPGARANTIA, PEMAX_AUTORIZADO, PEEXCEDENTE, VLMAX_PROPOSTA, CDFINALIDADE)
          values (rw_crapcop.cdcooper, 3, 32, 'Usado', vr_tab_lscmdmod(2), 1, 1, 90.00, 10.00, 0.00, 77);
      END IF;
      
      IF vr_tab_lscmdmod(3) > 0 THEN 
        insert into tbepr_subsegmento (CDCOOPER, IDSEGMENTO, IDSUBSEGMENTO, DSSUBSEGMENTO, CDLINHA_CREDITO, FLGGARANTIA, TPGARANTIA, PEMAX_AUTORIZADO, PEEXCEDENTE, VLMAX_PROPOSTA, CDFINALIDADE)
          values (rw_crapcop.cdcooper, 4, 41, 'Imovel', vr_tab_lscmdmod(3), 1, 0, 90.00, 10.00, 0.00, 77);
      END IF;

    exception
       when dup_val_on_index then
         null; 
    END;
    
   
  end loop;

  commit;
end;
