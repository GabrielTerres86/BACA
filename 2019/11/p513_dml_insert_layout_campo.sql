DECLARE 
 widcampo_layout NUMBER;
BEGIN

  INSERT INTO tbgen_layout( idlayout
                        , nmlayout
                        , dslayout
                        , dsdelimitador
                        , dsobservacao)
                  VALUES( 13
                        , 'SEP_ARQUIVO_CONCILIACAO'
                        , 'Arquivo de conciliação da Saque & Pague'
                        , null
                        , null);
 
  COMMIT; 
  
  widcampo_layout := 647;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 1                    -- nrsequencia_campo
                                , 'CDREGISTRO'         -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                    -- nrposicao_inicial
                                , 2                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro' -- dsobservacao
                                , 'A0'                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 2                    -- nrsequencia_campo
                                , 'CDUNIDADE'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 3                    -- nrposicao_inicial
                                , 2                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Unidade Centralizadora' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 3                    -- nrsequencia_campo
                                , 'CDINSTFINAN'        -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 5                    -- nrposicao_inicial
                                , 4                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Instituição Financeira' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 4                    -- nrsequencia_campo
                                , 'INSEPPARCEIRO'      -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 9                   -- nrposicao_inicial
                                , 3                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação Saque e Pague do Parceiro' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 

  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 5                    -- nrsequencia_campo
                                , 'INMEIOTRANSPARQ'    -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 12                   -- nrposicao_inicial
                                , 1                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Meio de Transporte do Arquivo' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  --  Header do Arquivo (A0)
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 6                    -- nrsequencia_campo
                                , 'INVERSAOARQUIVO'    -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 13                   -- nrposicao_inicial
                                , 4                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Versão Arquivo' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  --  Header do Arquivo (A0)
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 7                    -- nrsequencia_campo
                                , 'DTCONTABILREF'    -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 17                   -- nrposicao_inicial
                                , 8                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Versão Arquivo' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
   
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 8                    -- nrsequencia_campo
                                , 'CDNSUREGISTRO'    -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'A0'                 -- tpregistro                              
                                , 9                    -- nrsequencia_campo
                                , 'INEXTENSAO'    -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1                   -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;     
  -- Fim Header do Arquivo (A0)

  -- Header do Serviço (B0)
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 1                    -- nrsequencia_campo
                                , 'CDREGISTRO'    -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2                   -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro' -- dsobservacao
                                , 'B0'                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 2                    -- nrsequencia_campo
                                , 'DTREFERENCIA'    -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 3                   -- nrposicao_inicial
                                , 8                   -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data de Referência' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 3                    -- nrsequencia_campo
                                , 'CDNSA'    -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                   -- nrposicao_inicial
                                , 6                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSA - Número Sequencial do Arquivo' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 4                    -- nrsequencia_campo
                                , 'CDNSP'    -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 17                   -- nrposicao_inicial
                                , 10                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSP - Número Sequencial do Processamento' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 5                    -- nrsequencia_campo
                                , 'INTPPROC'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 27                   -- nrposicao_inicial
                                , 1                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Tipo de Processamento' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 6                    -- nrsequencia_campo
                                , 'INTPTRANS'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 28                   -- nrposicao_inicial
                                , 1                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Tipo de Transmissão' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 7                    -- nrsequencia_campo
                                , 'INFORMTRANS'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 29                   -- nrposicao_inicial
                                , 1                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Formato das Transações Online' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 8                    -- nrsequencia_campo
                                , 'CDMOEDA'          -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 30                   -- nrposicao_inicial
                                , 3                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Moeda'            -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 

  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 9                    -- nrsequencia_campo
                                , 'CDINSTFIN'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 33                   -- nrposicao_inicial
                                , 4                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Instituição Financeira'            -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 10                    -- nrsequencia_campo
                                , 'INTPPARCEIRO'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 37                   -- nrposicao_inicial
                                , 7                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Tipo de Parceiro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 11                    -- nrsequencia_campo
                                , 'INREDECUSTODIA'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 44                   -- nrposicao_inicial
                                , 4                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Rede Custódia'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 12                    -- nrsequencia_campo
                                , 'CDORIGEMOPERACAO'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 48                   -- nrposicao_inicial
                                , 1                  -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Origem da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 12                    -- nrsequencia_campo
                                , 'CDNSUREGISTRO'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6                 -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B0'                 -- tpregistro                              
                                , 13                    -- nrsequencia_campo
                                , 'INEXTENSAO'          -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1                 -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  
  -- Fim Header do Serviço (B0)

  -- Trailer do Serviço (BZ)
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 1                    -- nrsequencia_campo
                                , 'CDREGISTRO'          -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2                 -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'BZ'                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 2                    -- nrsequencia_campo
                                , 'CDNSA'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 3                   -- nrposicao_inicial
                                , 6                 -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSA - Número Sequencial do Arquivo'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 3                    -- nrsequencia_campo
                                , 'CDNSP'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 9                   -- nrposicao_inicial
                                , 10                 -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSP - Número Sequencial do Processamento'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 4                    -- nrsequencia_campo
                                , 'NRTOTALTRANS'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 19                   -- nrposicao_inicial
                                , 6                 -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total de Registros de Transações'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 5                    -- nrsequencia_campo
                                , 'NRTOTALCREEFE'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 25                   -- nrposicao_inicial
                                , 14                -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total de Créditos Efetivados'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 6                    -- nrsequencia_campo
                                , 'NRTOTALDEBEFE'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 39                   -- nrposicao_inicial
                                , 14                -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total de Débitos Efetivados'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 7                    -- nrsequencia_campo
                                , 'NRTOTALREGOCO'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 53                   -- nrposicao_inicial
                                , 6                -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total de Registros de Ocorrências'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 8                    -- nrsequencia_campo
                                , 'NRTOTALTRANS'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 59                   -- nrposicao_inicial
                                , 6                -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total de Transações'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 9                    -- nrsequencia_campo
                                , 'NRTOTALOCORR'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 65                   -- nrposicao_inicial
                                , 6                -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total de Ocorrências'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 10                    -- nrsequencia_campo
                                , 'NRTOTALCONT'          -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 71                   -- nrposicao_inicial
                                , 3               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total de Contestações'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 11                    -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'BZ'                 -- tpregistro                              
                                , 12                    -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  

  -- Fim Trailer do Serviço (BZ)

  -- Trailer do Arquivo (ZZ)
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 1                    -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'ZZ'                  -- dsidentificador_registro                               
                                );
  COMMIT; 

  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 2                    -- nrsequencia_campo
                                , 'CDUNIDADE'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 3                   -- nrposicao_inicial
                                , 2               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Unidade Centralizadora'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 3                   -- nrsequencia_campo
                                , 'CDINSTFINAN'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 5                   -- nrposicao_inicial
                                , 4               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Instituição Financeira'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 4                   -- nrsequencia_campo
                                , 'INSEPPARCEIRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 9                   -- nrposicao_inicial
                                , 3               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação Saque e Pague do Parceiro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 5                   -- nrsequencia_campo
                                , 'NRTOTALREG'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 12                   -- nrposicao_inicial
                                , 8               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total Geral de Registros'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 6                   -- nrsequencia_campo
                                , 'NRTOTALCRE'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 20                   -- nrposicao_inicial
                                , 15               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total Geral de Créditos'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 7                  -- nrsequencia_campo
                                , 'NRTOTALDEB'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 35                   -- nrposicao_inicial
                                , 15               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Total Geral de Débitos'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 8                  -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'ZZ'                 -- tpregistro                              
                                , 9                  -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  -- Fim Trailer do Serviço (BZ)


  -- Registro Principal (B1)
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 1                 -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'B1'                   -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 2                 -- nrsequencia_campo
                                , 'INTERMINAL'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 3                   -- nrposicao_inicial
                                , 8               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 3                 -- nrsequencia_campo
                                , 'CDNSUOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                   -- nrposicao_inicial
                                , 12               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 4                 -- nrsequencia_campo
                                , 'DTOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 23                   -- nrposicao_inicial
                                , 4               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 5                 -- nrsequencia_campo
                                , 'HROPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 27                   -- nrposicao_inicial
                                , 4               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Hora da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 6                 -- nrsequencia_campo
                                , 'DTLANCAMENTO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 31                   -- nrposicao_inicial
                                , 8               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data de Lançamento'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
 
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 7                 -- nrsequencia_campo
                                , 'STOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 39                   -- nrposicao_inicial
                                , 1               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Status da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 8                 -- nrsequencia_campo
                                , 'CDOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 40                   -- nrposicao_inicial
                                , 6               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 9                -- nrsequencia_campo
                                , 'VLOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 46                   -- nrposicao_inicial
                                , 8               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Valor da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 10                -- nrsequencia_campo
                                , 'INCLIENTE'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 54                   -- nrposicao_inicial
                                , 18               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Cliente'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 11                -- nrsequencia_campo
                                , 'INOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 72                   -- nrposicao_inicial
                                , 1               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Modo de Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 12                -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B1'                 -- tpregistro                              
                                , 13                -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  -- Fim Registro Principal (B1)

  -- Registro Principal (B2)
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 1                -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'B2'                  -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 2                -- nrsequencia_campo
                                , 'INTERMINAL'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 3                   -- nrposicao_inicial
                                , 8               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 3               -- nrsequencia_campo
                                , 'INTIPOTERMINAL'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                   -- nrposicao_inicial
                                , 1               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Tipo de Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 4                -- nrsequencia_campo
                                , 'CDNSUOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 12                   -- nrposicao_inicial
                                , 12               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 5                -- nrsequencia_campo
                                , 'DTOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 24                   -- nrposicao_inicial
                                , 4               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 6                -- nrsequencia_campo
                                , 'HROPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 28                   -- nrposicao_inicial
                                , 4               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Hora da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 7                -- nrsequencia_campo
                                , 'CDINSTFINDEST'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 32                   -- nrposicao_inicial
                                , 3               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Instituição Financeira Destino'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 8                -- nrsequencia_campo
                                , 'INSEPPARCEIRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 35                   -- nrposicao_inicial
                                , 3               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação Saque e Pague do Parceiro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 9                -- nrsequencia_campo
                                , 'CDAGENCIADESTINO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 38                   -- nrposicao_inicial
                                , 5               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Agência Destino'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 10                -- nrsequencia_campo
                                , 'NRCONTADESTINO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 43                   -- nrposicao_inicial
                                , 10              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Número da Conta Destino'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 11                -- nrsequencia_campo
                                , 'INTARIFACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 53                   -- nrposicao_inicial
                                , 1              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Tarifação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 12                -- nrsequencia_campo
                                , 'INMODOENTRADA'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 54                   -- nrposicao_inicial
                                , 1              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Modo de Entrada'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 13                -- nrsequencia_campo
                                , 'CDNSUAUTORIZADOR'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 55                   -- nrposicao_inicial
                                , 12              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Autorizador'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 14                -- nrsequencia_campo
                                , 'CDORIGEM'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 67                   -- nrposicao_inicial
                                , 3              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código de Origem'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 15                    -- nrsequencia_campo
                                , 'CDNSUREGISTRO'    -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6                    -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B2'                 -- tpregistro                              
                                , 16                    -- nrsequencia_campo
                                , 'INEXTENSAO'    -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1                   -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão' -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;     
  
  -- Fim Registro Principal (B2)

  -- Registro Principal (B3)
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 1                -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'B3'                  -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 2                -- nrsequencia_campo
                                , 'INTERMINAL'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 3                   -- nrposicao_inicial
                                , 8              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 3                -- nrsequencia_campo
                                , 'CDNSUOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                   -- nrposicao_inicial
                                , 12              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 4                -- nrsequencia_campo
                                , 'DTOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 23                   -- nrposicao_inicial
                                , 4              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 5               -- nrsequencia_campo
                                , 'HROPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 27                   -- nrposicao_inicial
                                , 4              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Hora da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 6                -- nrsequencia_campo
                                , 'NRTXCONVEN'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 31                   -- nrposicao_inicial
                                , 4              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Taxa de Conveniência'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 7               -- nrsequencia_campo
                                , 'CDPERIODOESC'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 35                   -- nrposicao_inicial
                                , 3              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Período Escolhido'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 8                -- nrsequencia_campo
                                , 'INEXTINI'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 38                   -- nrposicao_inicial
                                , 8              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Extrato - Início do Período Escolhido pelo Cliente'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 9                -- nrsequencia_campo
                                , 'INEXTFIM'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 46                   -- nrposicao_inicial
                                , 8              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Extrato - Fim do Período Escolhido pelo Cliente'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 10                -- nrsequencia_campo
                                , 'NRTAMEXTRATO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 54                   -- nrposicao_inicial
                                , 4              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Tamanho do Extrato'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 11                -- nrsequencia_campo
                                , 'QTCHEQDEP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 58                   -- nrposicao_inicial
                                , 2              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Quantidade de Cheques Depositados'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 12                -- nrsequencia_campo
                                , 'QTFOLCHEQIMP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 60                   -- nrposicao_inicial
                                , 2              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Quantidade de Folhas de Cheque Impressas'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 13                -- nrsequencia_campo
                                , 'NRPRICHEQIMP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 62                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Número do Primeiro Cheque Impresso'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 14                -- nrsequencia_campo
                                , 'NRULTCHEQIMP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 68                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Número do Último Cheque Impresso'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 15                -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B3'                 -- tpregistro                              
                                , 16                -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 

  
  -- Fim Registro Principal (B3)

  -- Registro Principal (B4)
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 1                -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'B4'                  -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 2                -- nrsequencia_campo
                                , 'INTERMINAL'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 3                   -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 3                -- nrsequencia_campo
                                , 'NRPROTOCOLO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                   -- nrposicao_inicial
                                , 12             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Protocolo'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
    
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 4                -- nrsequencia_campo
                                , 'DTOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 23                   -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 5                -- nrsequencia_campo
                                , 'HROPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 27                   -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Hora da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 6                -- nrsequencia_campo
                                , 'DTLANCAMENTO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 31                   -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data de Lançamento'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 7                -- nrsequencia_campo
                                , 'CDOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 39                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
   widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 8                -- nrsequencia_campo
                                , 'VLOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 45                   -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Valor da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 9                -- nrsequencia_campo
                                , 'INCLIENTE'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 53                   -- nrposicao_inicial
                                , 18             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Cliente'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 10                -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B4'                 -- tpregistro                              
                                , 11                -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  -- Fim Registro Principal (B4)

  -- Registro Principal (B7)
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 1                -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                   -- nrposicao_inicial
                                , 2             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'B7'                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 2                -- nrsequencia_campo
                                , 'INTERMINAL'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 3                  -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 3                -- nrsequencia_campo
                                , 'CDNSUOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                  -- nrposicao_inicial
                                , 12             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 4                -- nrsequencia_campo
                                , 'DTOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 23                  -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 5                -- nrsequencia_campo
                                , 'HROPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 27                  -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Hora da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 6                -- nrsequencia_campo
                                , 'DTLANCAMENTO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 31                  -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data de Lançamento'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 7                -- nrsequencia_campo
                                , 'CDOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 39                  -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 8                -- nrsequencia_campo
                                , 'VLOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 45                  -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Valor da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 9                -- nrsequencia_campo
                                , 'INCLIENTE'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 53                  -- nrposicao_inicial
                                , 18             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Cliente'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
    
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 10                -- nrsequencia_campo
                                , 'CDOCORRENCIA'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 71                  -- nrposicao_inicial
                                , 2             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Ocorrência'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 11                -- nrsequencia_campo
                                , 'INOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 73                  -- nrposicao_inicial
                                , 1             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Status da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 12                -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                  -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
    
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B7'                 -- tpregistro                              
                                , 13                -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                  -- nrposicao_inicial
                                , 1             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  -- Fim Registro Principal (B7)
  
  -- Registro Principal (B8)
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 1                -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                  -- nrposicao_inicial
                                , 2             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'B8'                    -- dsidentificador_registro                               
                                );
  COMMIT;
   widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 2                -- nrsequencia_campo
                                , 'INTERMINAL'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 3                  -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 3                -- nrsequencia_campo
                                , 'TPTERMINAL'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                  -- nrposicao_inicial
                                , 1             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Tipo de Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 4                -- nrsequencia_campo
                                , 'CDNSUOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 12                  -- nrposicao_inicial
                                , 12             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU de Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
   widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 5                -- nrsequencia_campo
                                , 'DTOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 24                  -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 6                -- nrsequencia_campo
                                , 'HROPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 28                  -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Hora da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 7                -- nrsequencia_campo
                                , 'INMODOENTRADA'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 32                   -- nrposicao_inicial
                                , 1              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Modo de Entrada'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 8                -- nrsequencia_campo
                                , 'CDINSTFINDEST'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 33                   -- nrposicao_inicial
                                , 3               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Instituição Financeira Destino'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 9                -- nrsequencia_campo
                                , 'INSEPPARCEIRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 36                   -- nrposicao_inicial
                                , 3               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação Saque e Pague do Parceiro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 10                -- nrsequencia_campo
                                , 'CDAGENCIADESTINO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 39                   -- nrposicao_inicial
                                , 5               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código da Agência Destino'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 11                -- nrsequencia_campo
                                , 'NRCONTADESTINO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 44                   -- nrposicao_inicial
                                , 10              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Número da Conta Destino'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 12                -- nrsequencia_campo
                                , 'INTARIFACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 54                   -- nrposicao_inicial
                                , 1              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Tarifação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  
  widcampo_layout:=widcampo_layout+1;  
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 13                -- nrsequencia_campo
                                , 'CDNSUAUTORIZADOR'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 55                   -- nrposicao_inicial
                                , 12              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Autorizador'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
   
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 14                -- nrsequencia_campo
                                , 'CDORIGEM'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 67                   -- nrposicao_inicial
                                , 3              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código de Origem'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 15                -- nrsequencia_campo
                                , 'INOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 70                   -- nrposicao_inicial
                                , 1               -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Modo de Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 16                -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
   widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B8'                 -- tpregistro                              
                                , 17                -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  -- Fim Registro Principal (B8)
  
  
  -- Registro Principal (B9)
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 1                -- nrsequencia_campo
                                , 'CDREGISTRO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 1                  -- nrposicao_inicial
                                , 2             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Código do Registro'   -- dsobservacao
                                , 'B9'                  -- dsidentificador_registro                               
                                );
  COMMIT;
   widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 2                -- nrsequencia_campo
                                , 'INTERMINAL'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 3                  -- nrposicao_inicial
                                , 8             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Identificação do Terminal'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 3                -- nrsequencia_campo
                                , 'CDNSUOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 11                  -- nrposicao_inicial
                                , 12             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU de Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
   widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 4                -- nrsequencia_campo
                                , 'DTOPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 23                  -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Data da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  widcampo_layout:=widcampo_layout+1; 
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 5                -- nrsequencia_campo
                                , 'HROPERACAO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 27                  -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Hora da Operação'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
  
  
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 6                -- nrsequencia_campo
                                , 'QTCHEQDEP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 31                   -- nrposicao_inicial
                                , 2              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Quantidade de Cheques Depositados'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 7                -- nrsequencia_campo
                                , 'QTFOLCHEQIMP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 33                   -- nrposicao_inicial
                                , 2              -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Quantidade de Folhas de Cheque Impressas'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT;
    
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 8                -- nrsequencia_campo
                                , 'NRPRICHEQIMP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 35                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Número do Primeiro Cheque Impresso'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 

  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 9                -- nrsequencia_campo
                                , 'NRULTCHEQIMP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 41                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Número do Último Cheque Impresso'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 10                -- nrsequencia_campo
                                , 'NRTOTALRESP'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 47                   -- nrposicao_inicial
                                , 4             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Extrato - Tamanho Total da Resposta'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
    
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 11                -- nrsequencia_campo
                                , 'NRTOTALMSG'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 51                   -- nrposicao_inicial
                                , 5             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Extrato - Quantidade Total de Mensagens'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
  widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 12                -- nrsequencia_campo
                                , 'CDNSUREGISTRO'       -- nmcampo
                                , 'N'                  -- tpdado
                                , null                 -- dsformato
                                , 74                   -- nrposicao_inicial
                                , 6             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'NSU do Registro'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 
  
   widcampo_layout:=widcampo_layout+1;
  INSERT INTO tbgen_layout_campo( idcampo_layout
                                , idlayout
                                , tpregistro
                                , nrsequencia_campo
                                , nmcampo
                                , tpdado
                                , dsformato
                                , nrposicao_inicial
                                , qtdposicoes
                                , qtddecimais
                                , dsobservacao
                                , dsidentificador_registro)
                          VALUES( widcampo_layout                 -- idcampo_layout
                                , 13                   -- idlayout
                                , 'B9'                 -- tpregistro                              
                                , 13                -- nrsequencia_campo
                                , 'INEXTENSAO'       -- nmcampo
                                , 'T'                  -- tpdado
                                , null                 -- dsformato
                                , 80                   -- nrposicao_inicial
                                , 1             -- qtdposicoes
                                , null                 -- qtddecimais
                                , 'Indicador de Extensão'   -- dsobservacao
                                , null                 -- dsidentificador_registro                               
                                );
  COMMIT; 

END;
