PL/SQL Developer Test script 3.0
67
declare 
pr_retxml xmltype;
  pr_saldo NUMBER(15,2);
  pr_saldo_char VARCHAR(20);
    pr_iof NUMBER(15,2);
  pr_iof_char VARCHAR(20);
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
  vr_dscritic VARCHAR2(1000);        --> Descrição de Erro
  vr_liquidou PLS_INTEGER;
  vr_nmdcampo VARCHAR2(1000);
  vr_des_erro VARCHAR2(1000);
begin
   -- Call the procedure
   BEGIN
    pr_retxml := xmltype.createXML('<Root> <Dados>   <nrdconta>216194</nrdconta>   <nrborder>28247</nrborder> </Dados><params><nmprogra>DSCT0003</nmprogra><nmeacao>BUSCA_DADOS_PREJUIZO</nmeacao><cdcooper>7</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>5</idorigem><cdoperad>1</cdoperad><filesphp>/var/www/ayllos/telas/atenda/desc7ontos/titulos/titulos_bordero_pagar_prejuizo.php</filesphp></params><Permissao><nmdatela>ATENDA</nmdatela><nmrotina>DSC TITS - BORDERO</nmrotina><cddopcao>P</cddopcao><idsistem>1</idsistem><inproces>1</inproces><cdagecxa>0</cdagecxa><nrdcaixa>0</nrdcaixa><cdopecxa>1</cdopecxa><idorigem>5</idorigem></Permissao></Root>');
     
   -- Muda situação do acordo para cancelado para permitir usar a rotina pc_busca_dados_prejuizo_web
   update TBRECUP_ACORDO
      set cdsituacao = 3
    where nracordo = 244389;
    
    -- Retorna o Saldo em eberto do bordero
      cecred.DSCT0003.pc_busca_dados_prejuizo_web(pr_nrdconta => 216194,
                                              pr_nrborder => 28247,
                                              pr_xmllog => null,
                                              pr_cdcritic => vr_cdcritic,
                                              pr_dscritic => vr_dscritic,
                                              pr_retxml => pr_retxml,
                                              pr_nmdcampo => vr_nmdcampo,
                                              pr_des_erro => vr_des_erro);
                        
      -- Carrega o saldo
    pr_saldo_char := TRIM(pr_retxml.extract('/root/dados/vlsldatu/text()').getstringval());
    pr_saldo := to_number(replace(replace(pr_saldo_char,'.',''),',','.'), '9999999999999999D99', 'NLS_NUMERIC_CHARACTERS=''.,''');
    
    pr_iof_char := TRIM(pr_retxml.extract('/root/dados/toiofprj/text()').getstringval());
    pr_iof := to_number(replace(replace(pr_iof_char,'.',''),',','.'), '9999999999999999D99', 'NLS_NUMERIC_CHARACTERS=''.,''');

      -- Paga o bordero
    cecred.PREJ0005.pc_pagar_bordero_prejuizo(pr_cdcooper => 7
                     ,pr_nrborder => 28247
                     ,pr_vlaboorj => pr_saldo
                     ,pr_vlpagmto => 0
                     ,pr_cdoperad => 1
                     ,pr_cdagenci => 1
                     ,pr_nrdcaixa => 1
                     ,pr_cdorigem => 2
                     ,pr_liquidou => vr_liquidou
                     ,pr_cdcritic => vr_cdcritic
                     ,pr_dscritic => vr_dscritic);   

     -- Muda situação do acordo para quitado
   update TBRECUP_ACORDO
      set cdsituacao = 2
    where nracordo = 244389;
    
      COMMIT;                  

    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;   
    dbms_output.put_line(vr_dscritic);
      cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' ||
                                                    vr_dscritic);
    END;     
end;
0
0
