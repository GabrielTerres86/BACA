begin
  begin
    declare
      -- nome da rotina
      wk_rotina varchar2(200) := 'execução arquivos CCR3';
    
      pr_dscritic varchar2(200) := '';
      pr_cdcritic PLS_INTEGER;
      pr_retxml   XMLType := xmltype.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root> <Dados> </Dados><params><nmprogra>CCR3</nmprogra>' ||
                                               '<nmeacao>CRPS672</nmeacao><cdcooper>3</cdcooper><cdagenci>0</cdagenci><nrdcaixa>0</nrdcaixa><idorigem>1</idorigem>' ||
                                               '<cdoperad>1</cdoperad></params></Root>');
      pr_nmdcampo varchar2(200) := '';
      pr_des_erro varchar2(200) := '';
    
      --xml da rotina
      -- Non-scalar parameters require additional processing 
      pr_xmllog varchar2(4000);
    begin
    
      -- seta parametros para executa a rotina antiga de integração;
      update crappco a set a.dsconteu = 'N' where a.cdpartar = 77;
    
      commit;
    
      --seta sequencial de execução
      update crapscb a
         set a.nrseqarq = 1462
       where a.tparquiv = 7
         and a.dsdsigla = 'CCR3';
    
      commit;
    
      --executa rotinia de integração - processa arquivo final xxxx
      -- Call the procedure
      cartao.gerararquivocrps672(pr_xmllog   => pr_xmllog,
                                 pr_cdcritic => pr_cdcritic,
                                 pr_dscritic => pr_dscritic,
                                 pr_retxml   => pr_retxml,
                                 pr_nmdcampo => pr_nmdcampo,
                                 pr_des_erro => pr_des_erro);
    
      commit;
    
      --seta sequencial de execução
      update crapscb a
         set a.nrseqarq = 1463
       where a.tparquiv = 7
         and a.dsdsigla = 'CCR3';
    
      commit;
    
      --executa rotinia de integração - processa arquivo final xxxx
      -- Call the procedure
      cartao.gerararquivocrps672(pr_xmllog   => pr_xmllog,
                                 pr_cdcritic => pr_cdcritic,
                                 pr_dscritic => pr_dscritic,
                                 pr_retxml   => pr_retxml,
                                 pr_nmdcampo => pr_nmdcampo,
                                 pr_des_erro => pr_des_erro);
      commit;
    
      --seta sequencial de execução do arquivo de segunda-feira de 55Mb (161k de linhas)
      update crapscb a
         set a.nrseqarq = 1461
       where a.tparquiv = 7
         and a.dsdsigla = 'CCR3';
    
      commit;
    
      --executa rotinia de integração - processa arquivo final xxxx
      -- Call the procedure
      cartao.gerararquivocrps672(pr_xmllog   => pr_xmllog,
                                 pr_cdcritic => pr_cdcritic,
                                 pr_dscritic => pr_dscritic,
                                 pr_retxml   => pr_retxml,
                                 pr_nmdcampo => pr_nmdcampo,
                                 pr_des_erro => pr_des_erro);
      commit;
    
      --seta sequencial de execução para o número atual para processar os arquivos novos
      update crapscb a
         set a.nrseqarq = 1464
       where a.tparquiv = 7
         and a.dsdsigla = 'CCR3';
    
      commit;
    
      dbms_output.put_line('Sucesso ao executar: ' || wk_rotina);
    exception
      when others then
        dbms_output.put_line('Erro ao executar: ' || wk_rotina ||
                             ' --- detalhes do erro: ' || SQLCODE || ': ' ||
                             SQLERRM);
        ROLLBACK;
    end;
  end;
end;
