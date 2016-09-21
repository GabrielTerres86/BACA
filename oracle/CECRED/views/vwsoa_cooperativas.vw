CREATE OR REPLACE VIEW CECRED.VWSOA_COOPERATIVAS AS
  select origem.cdcooper
        ,origem.nmrescop
        ,mun.idcidade
        ,mun.dscidesp
    from(
          select cop.cdcooper
                ,cop.nmrescop
                 /* A cooperativa s� tem 1 cidade sede,
                    por�m o m�x � para evitar problemas */
                ,(select max(age.idcidade)
                    from crapage age
                   where age.cdcooper = cop.cdcooper
                     and age.flgdsede = 1) idmusede
            from crapcop cop 
           where cop.flgativo = 1
         ) origem
left join crapmun mun
       on mun.idcidade = origem.idmusede
   
