BEGIN
  UPDATE crapblj blj
     SET blj.dtblqini = '05/09/2022'
        ,blj.vlbloque = 3194333.64
        ,blj.dsresord = 'BLOQUEIO DE VALORES ATE R$ 3.194.333,64'
        ,blj.dtenvres = '05/09/2022'
   WHERE progress_recid = 221737; 

  COMMIT;
END;
