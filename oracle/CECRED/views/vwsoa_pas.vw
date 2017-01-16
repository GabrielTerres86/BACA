CREATE OR REPLACE VIEW CECRED.VWSOA_PAS AS
   SELECT age.cdcooper
         ,age.cdagenci
         ,age.nmresage
         ,age.nmpasite
         ,age.dsendcop
         ,age.dscomple
         ,age.nmbairro
         ,mun.idcidade
         ,mun.cdestado
         ,mun.dscidesp
         ,age.nrendere
         ,age.nrcepend
         ,age.dstelsit
         ,age.dsemasit
         ,age.dshorsit
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
LEFT JOIN crapmun mun
       ON mun.idcidade = age.idcidade
    WHERE age.cdagenci NOT IN (90, 91, 999)
      AND age.insitage not in (0,2)
	  AND trim(age.nmpasite) is not null
