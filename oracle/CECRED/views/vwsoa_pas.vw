CREATE OR REPLACE VIEW CECRED.VWSOA_PAS AS
SELECT    age.cdcooper         
				 ,CASE WHEN age.insitage = 1 AND GENE0002.fn_busca_time BETWEEN age.hrinipaa AND age.hrfimpaa THEN DECODE(NVL(fer.cdcooper, 0), 0, 1, 0)
               ELSE 0
          END AS insitpaa -- Aberto/Fechado
         ,cop.nmrescop
				 ,'Posto de Atendimento' AS dsctpage
         ,age.cdagenci
         ,age.nmresage
         ,age.nmpasite
         ,age.dsendcop
         ,age.dscomple
         ,age.nmbairro
         ,mun.idcidade
         ,mun.cdestado
				 ,DECODE(mun.cdestado, 'SC', 'Santa Catarina', 'PR', 'Paraná', 'RS', 'Rio Grande do Sul') AS dsestado
         ,mun.dscidesp
         ,age.nrendere
         ,age.nrcepend
         ,age.dstelsit
         ,age.dsemasit
         ,GENE0002.fn_converte_time_data(age.hrinipaa) || ' às ' || GENE0002.fn_converte_time_data(age.hrfimpaa) AS dshorsit
				 ,age.indspcxa
				 ,TO_NUMBER(DECODE((SELECT COUNT(*) FROM craptfn tfn
																						JOIN tbsite_taa taa
																							ON taa.cdcooper = tfn.cdcooper
																						 AND taa.nrterfin = tfn.nrterfin
																						 AND taa.flganexo_pa = 1 -- PA possui TAA anexo																			
																					 WHERE tfn.cdcooper = age.cdcooper
																						 AND tfn.cdagenci = age.cdagenci
																				/*	 Não considerar se TAA estão ativos ou não
																						 AND tfn.flsistaa = 1 -- TAA está ativo */
																						 ), 0, '0', '1'))
																							AS indsptaa
         ,age.insitage
         ,case age.insitage
               when 0 then 'Em construção'
               when 1 then 'Ativo'
               when 2 then 'Inativo'
               when 3 then 'Temporariamente Indisponível'
          end dssitage
         ,age.nrlatitu
         ,age.nrlongit				 
     FROM crapage age
		 JOIN crapcop cop
       ON cop.cdcooper = age.cdcooper
		  AND cop.flgativo = 1
LEFT JOIN crapmun mun
       ON mun.idcidade = age.idcidade
LEFT JOIN crapfer fer
       ON fer.cdcooper = age.cdcooper
		  AND fer.dtferiad = TRUNC(SYSDATE)			 
    WHERE age.cdagenci NOT IN (90, 91, 999)
      AND age.insitage not in (0,2)
	  AND trim(age.nmpasite) is not null;
