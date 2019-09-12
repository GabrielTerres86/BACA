PL/SQL Developer Test script 3.0
121
-- Created on 09/09/2019 by F0030344 
DECLARE  
  
  TYPE typ_reg_crd IS
      RECORD (cdcooper crapass.cdcooper%TYPE
             ,nrdconta crapass.nrdconta%TYPE
             ,nrctrcrd crawcrd.nrctrcrd%TYPE
             ,nrcrcard crapcrd.nrcrcard%TYPE);
             
  /* Definicao de tabela que compreende os registros acima declarados */
  TYPE typ_tab_crd IS
    TABLE OF typ_reg_crd
    INDEX BY BINARY_INTEGER;
  /* Vetor com as informacoes de faixas*/
  vr_tb_crd typ_tab_crd;  
  vr_exc_saida EXCEPTION;
  
BEGIN 

  /*Criar tabela temporario com as contas e cartoes a serem cancelados*/  
  vr_tb_crd.DELETE;
  
  vr_tb_crd(1).cdcooper := 2;
  vr_tb_crd(1).nrdconta := 4464;
  vr_tb_crd(1).nrctrcrd := 876;
  vr_tb_crd(1).nrcrcard := 48672694;

  vr_tb_crd(2).cdcooper := 2;
  vr_tb_crd(2).nrdconta := 50369;
  vr_tb_crd(2).nrctrcrd := 1110;
  vr_tb_crd(2).nrcrcard := 53899759;

  vr_tb_crd(3).cdcooper := 2;
  vr_tb_crd(3).nrdconta := 50989;
  vr_tb_crd(3).nrctrcrd := 932;
  vr_tb_crd(3).nrcrcard := 50635650;

  vr_tb_crd(4).cdcooper := 2;
  vr_tb_crd(4).nrdconta := 54020;
  vr_tb_crd(4).nrctrcrd := 4361;
  vr_tb_crd(4).nrcrcard := 61435966;

  vr_tb_crd(5).cdcooper := 2;
  vr_tb_crd(5).nrdconta := 54046;
  vr_tb_crd(5).nrctrcrd := 4281;
  vr_tb_crd(5).nrcrcard := 60986361;

  vr_tb_crd(6).cdcooper := 2;
  vr_tb_crd(6).nrdconta := 77844;
  vr_tb_crd(6).nrctrcrd := 1011;
  vr_tb_crd(6).nrcrcard := 52068036;

  --esse cara tem que ir por aquivo manual
  vr_tb_crd(7).cdcooper := 2;
  vr_tb_crd(7).nrdconta := 163376;
  vr_tb_crd(7).nrctrcrd := 3501;
  vr_tb_crd(7).nrcrcard := 59453778;

  vr_tb_crd(8).cdcooper := 2;
  vr_tb_crd(8).nrdconta := 169790;
  vr_tb_crd(8).nrctrcrd := 3371;
  vr_tb_crd(8).nrcrcard := 59293340;

  vr_tb_crd(9).cdcooper := 2;
  vr_tb_crd(9).nrdconta := 262757;
  vr_tb_crd(9).nrctrcrd := 1135;
  vr_tb_crd(9).nrcrcard := 54835461;

  vr_tb_crd(10).cdcooper := 2;
  vr_tb_crd(10).nrdconta := 264580;
  vr_tb_crd(10).nrctrcrd := 4051;
  vr_tb_crd(10).nrcrcard := 60200831;

  vr_tb_crd(11).cdcooper := 2;
  vr_tb_crd(11).nrdconta := 221813;
  vr_tb_crd(11).nrctrcrd := 847;
  vr_tb_crd(11).nrcrcard := 48349138;
  
  FOR x IN vr_tb_crd.FIRST..vr_tb_crd.LAST LOOP
    
    dbms_output.put_line(vr_tb_crd(x).nrdconta);
    
    --Atualizar proposta
    BEGIN 
      --CDCOOPER, NRDCONTA, NRCTRCRD CHAVE CRAWCRD        
      UPDATE crawcrd crd
         SET crd.insitcrd = 6 --cancelado
            ,crd.dtcancel = SYSDATE
            ,crd.cdmotivo = 4 --pela coop
       WHERE crd.cdcooper = vr_tb_crd(x).cdcooper
         AND crd.nrdconta = vr_tb_crd(x).nrdconta
         AND crd.nrctrcrd = vr_tb_crd(x).nrctrcrd;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE vr_exc_saida;
    END;
    
    --Atualizar cartao
    BEGIN 
     --CDCOOPER, NRDCONTA, NRCRCARD CHAVE CRAPCRD 
     UPDATE crapcrd crd
        SET crd.cdmotivo = 4 --pela coop
           ,crd.dtcancel = SYSDATE
      WHERE crd.cdcooper = vr_tb_crd(x).cdcooper
        AND crd.nrdconta = vr_tb_crd(x).nrdconta
        AND crd.nrcrcard = vr_tb_crd(x).nrcrcard;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE vr_exc_saida;
    END;
    
  END LOOP;
  
  COMMIT;

EXCEPTION
  WHEN vr_exc_saida THEN
    ROLLBACK;
  WHEN OTHERS THEN
    ROLLBACK;  
END; 
0
0
