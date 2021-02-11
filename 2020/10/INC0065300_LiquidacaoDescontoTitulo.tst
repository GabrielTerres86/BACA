PL/SQL Developer Test script 3.0
125
DECLARE
  pr_retxml     xmltype;
  pr_saldo      NUMBER(15, 2);
  pr_saldo_char VARCHAR(20);
  pr_iof        NUMBER(15, 2);
  pr_iof_char   VARCHAR(20);
  -- Variável de críticas
  vr_cdcritic crapcri.cdcritic%TYPE; --> Código de Erro
  vr_dscritic VARCHAR2(1000); --> Descrição de Erro
  vr_liquidou PLS_INTEGER;
  vr_nmdcampo VARCHAR2(1000);
  vr_des_erro VARCHAR2(1000);
  vr_erro     EXCEPTION;
  
  
  CURSOR cr_acordo IS
    SELECT DISTINCT a.nracordo,a.cdcooper,a.nrdconta,c.nrborder
      FROM tbrecup_acordo          a
          ,tbrecup_acordo_contrato x
          ,tbdsct_titulo_cyber     c
          ,crapbdt b
          ,craptdb t
     WHERE x.nracordo IN (275732, 275852, 280446)
       AND a.cdcooper = c.cdcooper
       AND a.nrdconta = c.nrdconta
       AND x.cdorigem = 4
       AND x.nrctremp = c.nrctrdsc
       AND a.nracordo = x.nracordo
       AND t.cdcooper = c.cdcooper
       AND t.nrdconta = c.nrdconta
       AND t.nrborder = c.nrborder
       AND t.nrtitulo = c.nrtitulo
       AND b.cdcooper = c.cdcooper
       AND b.nrdconta = c.nrdconta
       AND b.nrborder = c.nrborder;
  
  
  
  
BEGIN
  -- Call the procedure
  BEGIN
    
  
    FOR rw_acordo IN cr_acordo LOOP
  
  
      pr_retxml := xmltype.createXML('<Root> <Dados>   <nrdconta>'||rw_acordo.nrdconta||'</nrdconta>   
                                                       <nrborder>'||rw_acordo.nrborder||'</nrborder> 
                                             </Dados><params><nmprogra>DSCT0003</nmprogra><nmeacao>BUSCA_DADOS_PREJUIZO</nmeacao>
                                                       <cdcooper>'||rw_acordo.cdcooper||'</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>5</idorigem><cdoperad>1</cdoperad><filesphp>/var/www/ayllos/telas/atenda/desc7ontos/titulos/titulos_bordero_pagar_prejuizo.php</filesphp>
                                                       </params><Permissao><nmdatela>ATENDA</nmdatela><nmrotina>DSC TITS - BORDERO</nmrotina><cddopcao>P</cddopcao><idsistem>1</idsistem><inproces>1</inproces><cdagecxa>0</cdagecxa><nrdcaixa>0</nrdcaixa>
                                                       <cdopecxa>1</cdopecxa><idorigem>5</idorigem></Permissao></Root>');
    
      dbms_output.put_line('Processando acordo '||rw_acordo.nracordo||' Bordero '||rw_acordo.nrborder);
      
      -- Muda situação do acordo para cancelado para permitir usar a rotina pc_busca_dados_prejuizo_web
      UPDATE TBRECUP_ACORDO
         SET cdsituacao = 3
       WHERE nracordo = rw_acordo.nracordo;
    
      -- Retorna o Saldo em eberto do bordero
      cecred.DSCT0003.pc_busca_dados_prejuizo_web(pr_nrdconta => rw_acordo.nrdconta,
                                                  pr_nrborder => rw_acordo.nrborder,
                                                  pr_xmllog   => NULL,
                                                  pr_cdcritic => vr_cdcritic,
                                                  pr_dscritic => vr_dscritic,
                                                  pr_retxml   => pr_retxml,
                                                  pr_nmdcampo => vr_nmdcampo,
                                                  pr_des_erro => vr_des_erro);
    
      -- Carrega o saldo
      pr_saldo_char := TRIM(pr_retxml.extract('/root/dados/vlsldatu/text()').getstringval());
      pr_saldo      := to_number(REPLACE(REPLACE(pr_saldo_char, '.', ''), ',', '.'),
                                 '9999999999999999D99',
                                 'NLS_NUMERIC_CHARACTERS=''.,''');
    
      pr_iof_char := TRIM(pr_retxml.extract('/root/dados/toiofprj/text()').getstringval());
      pr_iof      := to_number(REPLACE(REPLACE(pr_iof_char, '.', ''), ',', '.'),
                               '9999999999999999D99',
                               'NLS_NUMERIC_CHARACTERS=''.,''');
                               
     dbms_output.put_line('--> Bordero '||rw_acordo.nrborder||' Saldo: '||pr_saldo); 
     IF nvl(pr_saldo,0) > 0 THEN 
        dbms_output.put_line('--> Bordero '||rw_acordo.nrborder||' Pagar: '||pr_saldo);                       
      
        -- Paga o bordero
        cecred.PREJ0005.pc_pagar_bordero_prejuizo(pr_cdcooper => rw_acordo.cdcooper,
                                                  pr_nrborder => rw_acordo.nrborder,
                                                  pr_vlaboorj => pr_saldo,
                                                  pr_vlpagmto => 0,
                                                  pr_cdoperad => 1,
                                                  pr_cdagenci => 1,
                                                  pr_nrdcaixa => 1,
                                                  pr_cdorigem => 2,
                                                  pr_liquidou => vr_liquidou,
                                                  pr_cdcritic => vr_cdcritic,
                                                  pr_dscritic => vr_dscritic);
        IF nvl(vr_cdcritic,0) > 0 OR 
           TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_erro;
        END IF;   
           
        dbms_output.put_line('--> Bordero '||rw_acordo.nrborder||' pago, Liquidado: '||vr_liquidou);
        
        -- Muda situação do acordo para quitado
        UPDATE TBRECUP_ACORDO
           SET cdsituacao = 2
         WHERE nracordo = rw_acordo.nracordo;
      END IF; 
    END LOOP;
        
    COMMIT;
  
  EXCEPTION
    WHEN vr_erro THEN
       raise_application_error(-20500,vr_cdcritic ||'-'||vr_dscritic) ;  
    WHEN OTHERS THEN
      ROLLBACK;
      vr_dscritic := SQLERRM;
      dbms_output.put_line(vr_dscritic);
       raise_application_error(-20500,vr_cdcritic ||'-'||vr_dscritic) ;
      cecred.pc_internal_exception(pr_compleme => vr_cdcritic || ': ' || vr_dscritic);
  END;
END;
0
0
