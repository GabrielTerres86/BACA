BEGIN

	INSERT INTO tbgen_grupo_municipal_coop
    (idgrupo_municipal, cdcooper, idcidade, dsata_avaliacao, dtinclusao_registro)
    SELECT tbgen_grupo_municipal_coop_seq.nextval
          ,11 --CREDIFOZ
          ,idcidade
          ,'AGO 25.04.2019'
          ,SYSDATE
      FROM crapmun
     WHERE cdestado = 'SC'
       AND dscidesp IN
           ('Balneário Piçarras'
					 ,'Balneário Camboriú'
					 ,'Camboriú'
					 ,'Itajaí'
					 ,'Navegantes'
					 ,'Penha');
					 

INSERT INTO tbgen_grupo_municipal_coop
    (idgrupo_municipal, cdcooper, idcidade, dsata_avaliacao, dtinclusao_registro)
    SELECT tbgen_grupo_municipal_coop_seq.nextval
          ,5 --ACENTRA
          ,idcidade
          ,'AGO 03.04.2019'
          ,SYSDATE
      FROM crapmun
     WHERE cdestado = 'SC'
       AND dscidesp IN ('Araranguá'
                       ,'Balneário Arroio do Silva'
                       ,'Balneário Gaivota'
                       ,'Balneário Rincão'
                       ,'Braço do Norte'
                       ,'Capivari de Baixo'
                       ,'Cocal do Sul'
                       ,'Ermo'
                       ,'Forquilhinha'
                       ,'Gravatal'
                       ,'Içara'
                       ,'Jacinto Machado'
                       ,'Jaguaruna'
                       ,'Laguna'
                       ,'Lauro Muller'
                       ,'Maracajá'
                       ,'Meleiro'
                       ,'Morro da Fumaça'
                       ,'Morro Grande'
                       ,'Nova Veneza'
                       ,'Orleans'
                       ,'Pedras Grandes'
                       ,'Sangão'
                       ,'Santa Rosa do Sul'
                       ,'São Ludgero'
                       ,'Siderópolis'
                       ,'Sombrio'
                       ,'Timbé do Sul'
                       ,'Treviso'
                       ,'Treze de Maio'
                       ,'Tubarão'
                       ,'Turvo'
                       ,'Urussanga');
											 
INSERT INTO tbgen_grupo_municipal_coop
    (idgrupo_municipal, cdcooper, idcidade, dsata_avaliacao, dtinclusao_registro)
    SELECT tbgen_grupo_municipal_coop_seq.nextval
          ,2 --ACREDICOOP
          ,idcidade
          ,'AGO 17.04.2019'
          ,SYSDATE
      FROM crapmun
     WHERE cdestado = 'SC'
       AND dscidesp IN ('Joinville'
												,'Araquari'
												,'Balneário Barra do Sul'
												,'Barra Velha'
												,'Garuva'
												,'Itapoá'
												,'São Francisco do Sul'
												,'São João do Itaperiú');
												
INSERT INTO tbgen_grupo_municipal_coop
    (idgrupo_municipal, cdcooper, idcidade, dsata_avaliacao, dtinclusao_registro)
    SELECT tbgen_grupo_municipal_coop_seq.nextval
          ,14 --EVOLUA
          ,idcidade
          ,'AGO 05.04.2019'
          ,SYSDATE
      FROM crapmun
     WHERE cdestado = 'PR'
       AND dscidesp IN ('Ampére'
                        ,'Barracão'
                        ,'Bela Vista da Caroba'
                        ,'Boa Esperança do Iguaçu'
                        ,'Bom Jesus do Sul'
                        ,'Cruzeiro do Iguaçu'
                        ,'Dois Vizinhos'
                        ,'Enéas Marques'
                        ,'Flor da Serra do Sul'
                        ,'Itapejara do Oeste'
                        ,'Manfrinópolis'
                        ,'Marmeleiro'
                        ,'Nova Prata do Iguaçu'
                        ,'Nova Esperança do Sudoeste'
                        ,'Pato Branco'
                        ,'Pérola d''Oeste'
                        ,'Pinhal de São Bento'
                        ,'Realeza'
                        ,'Renascença'
                        ,'Salgado Filho'
                        ,'Salto do Lontra'
                        ,'Santa Izabel do Oeste'
                        ,'Santo Antônio do Sudoeste'
                        ,'São Jorge d''Oeste'
                        ,'Vitorino'
                        ,'Verê');

INSERT INTO tbgen_grupo_municipal_coop
    (idgrupo_municipal, cdcooper, idcidade, dsata_avaliacao, dtinclusao_registro)
    SELECT tbgen_grupo_municipal_coop_seq.nextval
          ,13 --CIVIA
          ,idcidade
          ,'AGO 11.04.2019'
          ,SYSDATE
      FROM crapmun
     WHERE cdestado = 'PR'
       AND dscidesp IN ('General Carneiro'
												,'Piên'
												,'Rio Negro'
												,'São Mateus do Sul'
												,'União da Vitória');
												
INSERT INTO tbgen_grupo_municipal_coop
    (idgrupo_municipal, cdcooper, idcidade, dsata_avaliacao, dtinclusao_registro)
    SELECT tbgen_grupo_municipal_coop_seq.nextval
          ,13 --CIVIA
          ,idcidade
          ,'AGO 11.04.2019'
          ,SYSDATE
      FROM crapmun
     WHERE cdestado = 'SC'
       AND dscidesp IN ('São Bento do Sul'
												,'Campo Alegre'
												,'Corupá'
												,'Mafra'
												,'Porto União'
												,'Rio Negrinho');												
												
	COMMIT;

END;

												