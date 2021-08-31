DECLARE
  -- Loop entre cooperativas 
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop;

  -- Variaveis do script
  vr_nmdatela craptel.nmdatela%TYPE := 'CONPIX'; -- Nome da tela
  vr_tldatela craptel.tldatela%TYPE := 'Conciliações PIX'; -- Titulo da tela
BEGIN
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN
      -- Inserir parametros para acesso da tela hconve
      INSERT INTO craptel
        (nmdatela,nrmodulo,cdopptel,tldatela,tlrestel,flgteldf,flgtelbl,nmrotina,lsopptel
        ,inacesso,cdcooper,idsistem,idevento,nrordrot,nrdnivel,nmrotpai,idambtel)
      VALUES
	  --Nome da tela ,Aimaro ,  Opções da tela , Titulo da tela , Titulo da tela , Permissão , Tela bloqueada ( 1 Liberada ) , Nome da Rotina ( Não precisa ) , Lista de opções
	  -- Indicador de acesso 2 - Durante um processo , Coperativa , 1 Ailos , 0 Não troca , 0 Não troca ( Ordenação ) , Nivel de apresentação da tela ( 0 ) , Nome da rotina pai , Ambiente ailos aonde a tela está disponivel ( 0 ) default;
        (vr_nmdatela,5,'@,C',vr_tldatela,vr_tldatela,0,1,' '
        ,'ACESSO,CONSULTA',0,rw_crapcop.cdcooper,1,0,0,0,' ',0);
    END;
  
    BEGIN
      -- Insere o registro de cadastro do programa
      INSERT INTO crapprg
	  -- CRED ( Default ) , Nome da tela ,  Titulo da tela , Default , default , default , Numero da solicitação implementada , Numero da ordem do programa , 1 ( Default ) ,  0 ,0,0,0,0, , 1 ( default) , Cooperativa
        (nmsistem,cdprogra,dsprogra##1,dsprogra##2,dsprogra##3,dsprogra##4,nrsolici,nrordprg
        ,inctrprg,cdrelato##1,cdrelato##2,cdrelato##3,cdrelato##4,cdrelato##5,inlibprg,cdcooper)
        (SELECT 'CRED',vr_nmdatela,vr_tldatela,'.','.','.',50
               ,(SELECT MAX(crapprg.nrordprg) + 1
                  FROM crapprg
                 WHERE crapprg.cdcooper = crapcop.cdcooper
                   AND crapprg.nrsolici = 50)
               ,1,0,0,0,0,0,1,crapcop.cdcooper
           FROM crapcop
          WHERE cdcooper = rw_crapcop.cdcooper);
    END;
  END LOOP;

  COMMIT;
END;

