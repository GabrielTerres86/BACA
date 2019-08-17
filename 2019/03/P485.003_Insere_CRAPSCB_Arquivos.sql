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
                            ,'Contestação de Portabilidade de Conta Salário'
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
                            ,'Informa contestação de portabilidade de conta salário ao Participante Folha'
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
                            ,'Destinado ao Participante Folha responder as contestações de portabilidade de conta salário.'
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
                            ,'Destinado ao PCPS informar e regularizar a situação da portabilidade aos Participantes'
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
                            ,'Destinado ao Participante Folha regularizar as solicitações de portabilidade de conta salário.'
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
                            ,'Destinado ao PCPS informar e regularizar a situação da portabilidade aos Participantes envolvidos.'
                            ,0 -- Possui retorno
                            ,0
                            ,'/usr/connectSFN/CTC');

							
 COMMIT;
  
END;
