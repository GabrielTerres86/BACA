CREATE OR REPLACE VIEW CECRED.VWSOA_TAAS AS
   select taa.cdcooper
         ,taa.nrterfin
         ,taa.nmterminal
         ,nvl(age.dsendcop,taa.dslogradouro) dslogradouro
         ,nvl(age.dscomple,taa.dscomplemento) dscomplemento
         ,mun.idcidade
         ,mun.cdestado
         ,mun.dscidesp
         ,nvl(age.nmbairro,taa.nmbairro) nmbairro
         ,nvl(age.nrendere,taa.nrendere) nrendere
         ,nvl(age.nrcepend,taa.nrcep) nrcep
         ,taa.dshorario
         ,case when origem.flsistaa = 1
               then 'Ativo'
               else 'Temporariamente Indisponível'
          end dssituac
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
left join crapage age
       on age.cdcooper = tfn.cdcooper
      and age.cdagenci = tfn.cdagenci
      /* efetuar o join apenas quando o flganexo_pa = 1 */
      and taa.flganexo_pa = 1
left join crapmun mun
       on mun.idcidade = nvl(age.idcidade,taa.idcidade)
