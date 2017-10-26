create or replace view cecred.vwsoa_taas as
   select taa.cdcooper
         ,DECODE(NVL(age.cdagenci, 0), 0, 'SISTEMA CECRED', cop.nmrescop) nmrescop
         ,taa.nrterfin
         ,taa.nmterminal
				 ,taa.flganexo_pa AS flganexo
         ,nvl(age.dsendcop,taa.dslogradouro) dslogradouro
         ,nvl(age.dscomple,taa.dscomplemento) dscomplemento
         ,mun.idcidade
         ,mun.cdestado
				 ,DECODE(mun.cdestado, 'SC', 'Santa Catarina', 'PR', 'Paraná', 'RS', 'Rio Grande do Sul', 'Não informado') AS dsestado
         ,mun.dscidesp
         ,nvl(age.nmbairro,taa.nmbairro) nmbairro
         ,nvl(age.nrendere,taa.nrendere) nrendere
         ,nvl(age.nrcepend,taa.nrcep) nrcep
         ,nvl(taa.dshorario, 'Não informado') AS dshorario
         ,case when origem.flsistaa = 1
               then 'Ativo'
               else 'Indisponível'
          end dssituac
         ,DECODE(origem.flsistaa, 1, 1, 0) insittaa
				 ,age2.dstelsit -- Obter o telefone SAC do PA vinculado ao TAA
         ,nvl(age.nrlatitu,taa.nrlatitude)  nrlatitude
         ,nvl(age.nrlongit,taa.nrlongitude) nrlongitude
     from(
          /* Agrupar os TAAs com mesmo nome, para que sejam apresentados 
             no site da cooperativa uma única vez. Necessário para
             localizações que possuem mais do que 1 TAA, exemplo
             um PA que possui 3 TAAs não precisa apresentar no site
             3 vezes (Pode ocorrer também para TAAs externo). */
          select taa.cdcooper
                ,min(taa.nrterfin) nrterfin
                ,taa.nmterminal
                ,max(tfn.flsistaa) flsistaa
            from tbsite_taa taa
            join craptfn tfn
              on tfn.cdcooper = taa.cdcooper
             and tfn.nrterfin = taa.nrterfin
           where tfn.cdsitfin <> 8 /* Desativado */
        group by taa.cdcooper, taa.nmterminal) origem
     join tbsite_taa taa
       on taa.cdcooper = origem.cdcooper
      and taa.nrterfin = origem.nrterfin
     join craptfn tfn
       on tfn.cdcooper = taa.cdcooper
      and tfn.nrterfin = taa.nrterfin
		 join crapage age2 -- obter PA vinculado ao TAA, mesmo se não for anexo
       on age2.cdcooper = tfn.cdcooper
      and age2.cdagenci = tfn.cdagenci
left join crapage age
       on age.cdcooper = tfn.cdcooper
      and age.cdagenci = tfn.cdagenci
      /* efetuar o join apenas quando o flganexo_pa = 1 */
      and taa.flganexo_pa = 1
LEFT JOIN crapcop cop
       ON cop.cdcooper = tfn.cdcooper
left join crapmun mun
       on mun.idcidade = nvl(age.idcidade,taa.idcidade)
