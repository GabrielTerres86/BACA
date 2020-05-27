PL/SQL Developer Test script 3.0
15
-- Created on 25/05/2020 by F0030367 
declare 
  -- Local variables here
  vr_cdestsig tbjur_prm_quebra_sigilo.cdestsig%TYPE;
begin
   vr_cdestsig:= 33; -- CONTA ITG
   
   BEGIN
     INSERT INTO tbjur_prm_quebra_sigilo(cdestsig, nmestsig)VALUES(vr_cdestsig, 'CONTA ITG');
   EXCEPTION
     WHEN OTHERS THEN
       dbms_output.put_line('Erro: '||sqlerrm);
   END;
   COMMIT;
end;
0
0
