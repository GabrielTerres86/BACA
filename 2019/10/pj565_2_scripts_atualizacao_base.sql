 --Script para atualização de Campo 'flgvalidavencto' para as empresas que estavam fixas 
 update cecred.gnconve gnconve
     set gnconve.flgvalidavencto= 1
   where gnconve.cdhiscxa in (2258,2271,2275,2262,659,2268,2297,2295,2286,2273);
   
 --Script para atualização de Campo 'nrdias_tolerancia' para empresa 'SANEPAR'
  update cecred.gnconve gnconve
     set gnconve.nrdias_tolerancia = 25
   where gnconve.cdhiscxa = 2262;
   
 --Script para atualização de campo 'flgacata_dup' Unimed(22) e Liberty(55)
  update cecred.gnconve gnconve
     set gnconve.flgacata_dup = 1
   where gnconve.cdconven in (22,55);
   
 --Scrip para atualização campo 'flgdebfacil' SAMAE ILHOTA DA - AGUAS GUARAMIRIM DA - AGUAS SCHROEDER DA
   update cecred.gnconve
set gnconve.flgdebfacil = 1
where gnconve.cdconven in (108,87,126)
  and gnconve.intpconvenio in(2,3) 
  and gnconve.inorigem_inclusao in (1,3) 
   
   