-- Created on 09/01/2019 by T0031627 
declare 

  -- Busca titulos para correcao
  cursor cr_titulos (pr_dtmvtoan in crapdat.dtmvtoan%type) is
  select c.dtmvtolt 
       , c.cdcooper
       , c.cdagenci
       , c.nrdconta
       , c.cdpesqbb
       , c.vllanmto
       , d.vldpagto
       , c.cdbccxlt
       , c.nrdolote
    from craplcm c
       , crapcob d
       , craptdb e
       , crapbdt f
       , crapret g
   where c.cdhistor = 591
     and c.dtmvtolt = pr_dtmvtoan--between '01/01/2019' and '08/01/2019'
     --and c.cdcooper = 1 
     --and c.nrdconta = 9740651
     and d.cdcooper = c.cdcooper
     and d.nrdconta = c.nrdconta
     and d.nrdocmto = c.cdpesqbb
     and d.incobran = 5
     and e.cdcooper = d.cdcooper
     and e.nrdconta = d.nrdconta
     and e.nrdocmto = d.nrdocmto
     and e.cdbandoc = d.cdbandoc
     and e.nrdctabb = d.nrdctabb
     and e.nrcnvcob = d.nrcnvcob
     and e.vltitulo = c.vllanmto
     and e.dtvencto = d.dtvencto
     and e.dtdpagto is null
     and e.insittit = 3
     and f.cdcooper = e.cdcooper
     and f.nrborder = e.nrborder
     and f.flverbor = 0
     and g.cdcooper (+) = d.cdcooper
     and g.nrdconta (+) = d.nrdconta
     and g.nrcnvcob (+) = d.nrcnvcob
     and g.nrdocmto (+) = d.nrdocmto
     and g.dtocorre (+) = d.dtdpagto
     and g.cdocorre (+) in (6,17,76,77)
     and g.dtcredit is null;

  -- Busca data da cooperativa
  cursor cr_crapdat is
  select dat.dtmvtolt
       , dat.dtmvtoan
    from crapdat dat
   where dat.cdcooper = 1;
  rw_crapdat cr_crapdat%rowtype;
  
  --Buscar informacoes de lote
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT craplot.nrdolote
          ,craplot.nrseqdig
          ,craplot.cdbccxlt
          ,craplot.dtmvtolt
          ,craplot.cdagenci
          ,craplot.tplotmov
          ,craplot.cdhistor
          ,craplot.rowid
      FROM craplot craplot
     WHERE craplot.cdcooper = pr_cdcooper
       AND craplot.dtmvtolt = pr_dtmvtolt
       AND craplot.cdagenci = pr_cdagenci
       AND craplot.cdbccxlt = pr_cdbccxlt
       AND craplot.nrdolote = pr_nrdolote;
    --FOR UPDATE NOWAIT;
  rw_craplot cr_craplot%ROWTYPE;
  
  vr_cdhistor craphis.cdhistor%type := 362;--977;
  vr_nrdolote craplot.nrdolote%type := 4199;--8463;
  vr_contador number := 0;
  
  -- variável para histórico de débito/crédito
  vr_incrineg       INTEGER;      --> Indicador de crítica de negócio para uso com a "pc_gerar_lancamento_conta"
  vr_tab_retorno    LANC0001.typ_reg_retorno;

  vr_cdcritic pls_integer;
  vr_dscritic varchar2(4000);
  vr_exc_erro exception;
  
  --Tabela de memoria de erros
  vr_tab_erro GENE0001.typ_tab_erro;
     
begin
  
  -- Busca data da cooperativa
  open cr_crapdat;
  fetch cr_crapdat into rw_crapdat;
  close cr_crapdat;
  
  -- Loop em titulos para correcao
  for rw_titulos in cr_titulos (rw_crapdat.dtmvtoan) loop
    
    begin
        
      -- Busca informacoes do lote
      open cr_craplot (pr_cdcooper => rw_titulos.cdcooper
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_cdagenci => rw_titulos.cdagenci
                      ,pr_cdbccxlt => rw_titulos.cdbccxlt
                      ,pr_nrdolote => vr_nrdolote);
      
      -- Posicionar no proximo registro
      fetch cr_craplot into rw_craplot;
      
      -- Se encontrou registro
      if cr_craplot%notfound then

        -- Fechar Cursor 
        close cr_craplot;
        
        -- Criar lote
        begin
          
          insert into craplot
                     (craplot.cdcooper
                     ,craplot.dtmvtolt
                     ,craplot.cdagenci
                     ,craplot.cdbccxlt
                     ,craplot.nrdolote
                     ,craplot.cdoperad
                     ,craplot.tplotmov
                     ,craplot.cdhistor)
               values
                     (rw_titulos.cdcooper
                     ,rw_crapdat.dtmvtolt
                     ,rw_titulos.cdagenci
                     ,rw_titulos.cdbccxlt
                     ,vr_nrdolote
                     ,1
                     ,1
                     ,vr_cdhistor)
                     returning rowid
                     ,craplot.dtmvtolt
                     ,craplot.cdagenci
                     ,craplot.cdbccxlt
                     ,craplot.nrdolote
                     ,craplot.nrseqdig
                     ,craplot.cdhistor
                     into rw_craplot.ROWID
                     ,rw_craplot.dtmvtolt
                     ,rw_craplot.cdagenci
                     ,rw_craplot.cdbccxlt
                     ,rw_craplot.nrdolote
                     ,rw_craplot.nrseqdig
                     ,rw_craplot.cdhistor;
        exception
        
          when Dup_Val_On_Index then
            --Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 59; --Lote ja cadastrado.
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
            raise vr_exc_erro;
          
          when others then
            -- No caso de erro de programa gravar tabela especifica de log - 15/02/2018 - Chamado 851591 
            CECRED.pc_internal_exception (pr_cdcooper => rw_titulos.cdcooper);  
            -- Ajuste mensagem de erro - 15/02/2018 - Chamado 851591 
            vr_cdcritic := 1034;
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic) ||
            'craplot(1):'   ||
            ', cdcooper:'    || rw_titulos.cdcooper || 
            ', dtmvtolt:'    || rw_crapdat.dtmvtolt || 
            ', cdagenci:'    || rw_titulos.cdcooper ||
            ', cdbccxlt:'    || rw_titulos.cdbccxlt ||
            ', nrdolote:'    || rw_titulos.nrdolote || 
            ', cdoperad:'    || '1'                 ||
            ', tplotmov:'    || '1'                 ||
            ', cdhistor:'    || vr_cdhistor         ||
            '. ' ||sqlerrm; 
            raise vr_exc_erro;
            
        end;
        
      end if;

      --Fechar Cursor
      if cr_craplot%isopen then
        close cr_craplot;
      end if;
        
      rw_craplot.nrseqdig:= rw_craplot.nrseqdig + 1; -- projeto ligeirinho

      -- Lancamento em conta e atualizacao de lotes
      lanc0001.pc_gerar_lancamento_conta(pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                        ,pr_cdagenci    => rw_titulos.cdagenci
                                        ,pr_cdbccxlt    => rw_titulos.cdbccxlt
                                        ,pr_nrdolote    => rw_craplot.nrdolote--rw_titulos.nrdolote
                                        ,pr_nrdconta    => rw_titulos.nrdconta
                                        ,pr_nrdctabb    => rw_titulos.nrdconta
                                        ,pr_cdpesqbb    => rw_titulos.cdpesqbb
                                        ,pr_cdcooper    => rw_titulos.cdcooper
                                        ,pr_nrdocmto    => rw_titulos.cdpesqbb--rw_craplot.nrseqdig
                                        ,pr_cdhistor    => vr_cdhistor--rw_craplot.cdhistor
                                        ,pr_nrseqdig    => rw_craplot.nrseqdig
                                        ,pr_vllanmto    => rw_titulos.vllanmto
                                        ,pr_nrautdoc    => 0
                                        ,pr_inprolot    => 1
                                        -- retorno
                                        ,pr_tab_retorno => vr_tab_retorno
                                        ,pr_incrineg    => vr_incrineg
                                        ,pr_cdcritic    => vr_cdcritic
                                        ,pr_dscritic    => vr_dscritic);
      
      -- Aborta em caso de critica
      if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
        raise vr_exc_erro;
      end if;

      if mod(vr_contador,20) = 0 then
        commit;
        null;
      end if;
      
      vr_contador := vr_contador + 1;

    exception
      
      when vr_exc_erro then
        
        vr_dscritic := 'Erro tratado loop: '||sqlerrm||' '||vr_dscritic;
        dbms_output.put_line(vr_dscritic);
        
        gene0001.pc_gera_erro(pr_cdcooper => rw_titulos.cdcooper
                             ,pr_cdagenci => rw_titulos.cdagenci
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1 -- Sequencia
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
                             
      when others then
        
        vr_dscritic := 'Erro geral loop: '||sqlerrm||' '||vr_dscritic;
        dbms_output.put_line(vr_dscritic);
        
        gene0001.pc_gera_erro(pr_cdcooper => rw_titulos.cdcooper
                             ,pr_cdagenci => rw_titulos.cdagenci
                             ,pr_nrdcaixa => 1
                             ,pr_nrsequen => 1 -- Sequencia
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
    
    end;

  end loop;
  
  commit;
  dbms_output.put_line('Sucesso: '||vr_contador);

exception
                             
  when others then
        
    vr_dscritic := 'Erro geral não tratado: '||sqlerrm||' '||vr_dscritic;
    dbms_output.put_line(vr_dscritic);

    gene0001.pc_gera_erro(pr_cdcooper => 0
                         ,pr_cdagenci => 1
                         ,pr_nrdcaixa => 1
                         ,pr_nrsequen => 1 -- Sequencia
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic
                         ,pr_tab_erro => vr_tab_erro);
end;