BEGIN 
  -- Inserir o parametro de controle do arquivo
  INSERT INTO cecred.crapscb(tparquiv
                            ,dsdsigla
                            ,dsarquiv
                            ,flgretor
                            ,nrseqarq
                            ,dsdirarq)
                      VALUES(18         -- Tipo do arquivo
                            ,'APCS201'  -- Sigla do arquivo
                            ,'Contesta��o de Portabilidade de Conta Sal�rio'
                            ,1 -- Possui retorno
                            ,0
                            ,'/usr/connectSFN/CTC');
  -- Inserir o parametro de controle do arquivo
  INSERT INTO cecred.crapscb(tparquiv
                            ,dsdsigla
                            ,dsarquiv
                            ,flgretor
                            ,nrseqarq
                            ,dsdirarq)
                      VALUES(19         -- Tipo do arquivo
                            ,'APCS202'  -- Sigla do arquivo
                            ,'Informa contesta��o de portabilidade de conta sal�rio ao Participante Folha'
                            ,0 -- Possui retorno
                            ,0
                            ,'/usr/connectSFN/CTC');
							
 -- Inserir o parametro de controle do arquivo
  INSERT INTO cecred.crapscb(tparquiv
                            ,dsdsigla
                            ,dsarquiv
                            ,flgretor
                            ,nrseqarq
                            ,dsdirarq)
                      VALUES(20         -- Tipo do arquivo
                            ,'APCS203'  -- Sigla do arquivo
                            ,'Destinado ao Participante Folha responder as contesta��es de portabilidade de conta sal�rio.'
                            ,1 -- Possui retorno
                            ,0
                            ,'/usr/connectSFN/CTC');
 -- Inserir o parametro de controle do arquivo
  INSERT INTO cecred.crapscb(tparquiv
                            ,dsdsigla
                            ,dsarquiv
                            ,flgretor
                            ,nrseqarq
                            ,dsdirarq)
                      VALUES(21         -- Tipo do arquivo
                            ,'APCS204'  -- Sigla do arquivo
                            ,'Destinado ao PCPS informar e regularizar a situa��o da portabilidade aos Participantes'
                            ,1 -- Possui retorno
                            ,0
                            ,'/usr/connectSFN/CTC');
 -- Inserir o parametro de controle do arquivo
  INSERT INTO cecred.crapscb(tparquiv
                            ,dsdsigla
                            ,dsarquiv
                            ,flgretor
                            ,nrseqarq
                            ,dsdirarq)
                      VALUES(22         -- Tipo do arquivo
                            ,'APCS205'  -- Sigla do arquivo
                            ,'Destinado ao PCPS informar o encerramento da portabilidade falta de resposta do Participante.'
                            ,0 -- Possui retorno
                            ,0
                            ,'/usr/connectSFN/CTC');
 -- Inserir o parametro de controle do arquivo
  INSERT INTO cecred.crapscb(tparquiv
                            ,dsdsigla
                            ,dsarquiv
                            ,flgretor
                            ,nrseqarq
                            ,dsdirarq)
                      VALUES(23         -- Tipo do arquivo
                            ,'APCS301'  -- Sigla do arquivo
                            ,'Destinado ao Participante Folha regularizar as solicita��es de portabilidade de conta sal�rio.'
                            ,1 -- Possui retorno
                            ,1
                            ,'/usr/connectSFN/CTC');
-- Inserir o parametro de controle do arquivo
  INSERT INTO cecred.crapscb(tparquiv
                            ,dsdsigla
                            ,dsarquiv
                            ,flgretor
                            ,nrseqarq
                            ,dsdirarq)
                      VALUES(24         -- Tipo do arquivo
                            ,'APCS302'  -- Sigla do arquivo
                            ,'Destinado ao PCPS informar e regularizar a situa��o da portabilidade aos Participantes envolvidos.'
                            ,0 -- Possui retorno
                            ,0
                            ,'/usr/connectSFN/CTC');

							
 COMMIT;
  
END;
