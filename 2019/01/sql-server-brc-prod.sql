/* Sintaxe sql server */

update Assembleia
   set UF = 'SC';
update Assembleia
   set DataHoraInicio = dateadd(minute, -210, DataHoraInicio)
 where Idintegracao in (97085,97073,97074,
                        97098,97099,97100,
                        97131,97132,97195);