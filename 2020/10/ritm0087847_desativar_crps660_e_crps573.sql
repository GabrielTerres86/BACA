-- RITM0087847 retirar a geração do arquivo 3040 do processo batch, executando por job ao acessar tela RISCO, opção F (Carlos)

update crapprg
   set crapprg.inlibprg = 2, --Indicador de liberacao do programa (1=lib, 2=bloq e 3=em teste)
       crapprg.nrsolici = 9573
 where crapprg.cdprogra = 'CRPS573';

update crapprg
   set crapprg.inlibprg = 2, --Indicador de liberacao do programa (1=lib, 2=bloq e 3=em teste)
       crapprg.nrsolici = 9660
 where crapprg.cdprogra = 'CRPS660';

COMMIT;
