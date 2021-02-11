declare 
  -- Local variables here
  i integer;
    vr_cdcritic  PLS_INTEGER;
    vr_dscritic  VARCHAR2(4000);
    VR_NRPROPOSTA VARCHAR2(40); 
begin
  /*********************************************/
  /* Inicio Conta: 6587917 / Contrato: 2987345 */
  /*********************************************/

  -- Buscar numero de proposta disponivel
  
  begin  
    SELECT SEGU0003.FN_NRPROPOSTA() INTO VR_NRPROPOSTA  FROM DUAL;
    
    -- Atualizar o numero da proposta icatu na crawseg para que dentro do efetiva_proposta_sp busca da crawseg e grave na tbseg_prestamista
    update crawseg g 
       set g.nrproposta = VR_NRPROPOSTA 
     where g.cdcooper = 1 
       and g.nrdconta = 6587917 
       and g.nrctrseg = 573541;
  
    -- Gravar data da utilização da proposta para que nao utilize mais o mesmo numero
    UPDATE TBSEG_NRPROPOSTA 
       SET DTSEGURO = SYSDATE 
     WHERE NRPROPOSTA = VR_NRPROPOSTA; 
  exception
    when others then
      DBMS_OUTPUT.put_line('Erro ao buscar numero de proposta: '||VR_NRPROPOSTA);
  end;
  
  SEGU0003.pc_efetiva_proposta_sp(1, 
                         6587917, --> numero da conta
                         2987345, --> Contrato
                              1,  --> Código da agencia
                              1,  --> Numero do caixa do operador
                              1,  --> Código do Operador
                             'BACA', --> Nome da Tela
                              1, --> Identificador de Origem
                              vr_cdcritic,
                              vr_dscritic
                              );

  if vr_dscritic is not null then
    DBMS_OUTPUT.put_line('Erro na saida da SEGU0003.pc_efetiva_proposta_sp: '||nvl(vr_cdcritic,0)|| ' - ' ||vr_dscritic);
  end if;
  
  /**********************************************/
  /*** FIM Conta: 6587917 / Contrato: 2987345 ***/
  /**********************************************/
  ------------------------------------------------------------------------------------------------------------------------------------------------------------------
  /*********************************************/
  /*** FIM Conta: 2075261 / Contrato: 3234248 ***/
  /*********************************************/

  -- Buscar numero de proposta disponivel
  begin  
    SELECT SEGU0003.FN_NRPROPOSTA() INTO VR_NRPROPOSTA  FROM DUAL;
    
    -- Atualizar o numero da proposta icatu na crawseg para que dentro do efetiva_proposta_sp busca da crawseg e grave na tbseg_prestamista
    update crawseg g 
       set g.nrproposta = VR_NRPROPOSTA 
     where g.cdcooper = 1 
       and g.nrdconta = 2075261 
       and g.nrctrseg = 578089;
  
    -- Gravar data da utilização da proposta para que nao utilize mais o mesmo numero
    UPDATE TBSEG_NRPROPOSTA 
       SET DTSEGURO = SYSDATE 
     WHERE NRPROPOSTA = VR_NRPROPOSTA; 
  exception
    when others then
      DBMS_OUTPUT.put_line('Erro ao buscar numero de proposta: '||VR_NRPROPOSTA);
  end;
  
  SEGU0003.pc_efetiva_proposta_sp(1, 
                        2075261,  --> numero da conta
                         3234248, --> Contrato
                              1,  --> Código da agencia
                              1,  --> Numero do caixa do operador
                              1,  --> Código do Operador
                             'BACA', --> Nome da Tela
                              1, --> Identificador de Origem
                              vr_cdcritic,
                              vr_dscritic
                              );

  if vr_dscritic is not null then
    DBMS_OUTPUT.put_line('Erro na saida da SEGU0003.pc_efetiva_proposta_sp: '||nvl(vr_cdcritic,0)|| ' - ' ||vr_dscritic);
  end if;
  
  /**********************************************/
  /*** FIM Conta: 2075261 / Contrato: 3234248 ***/
  /**********************************************/
  COMMIT; 

end;
