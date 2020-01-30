DELETE
  FROM tbepr_cdc_log                       
 WHERE idcooperado_cdc = 11293; 



 DELETE
   FROM tbepr_cdc_usuario_vinculo
  WHERE idcooperado_cdc = 11293;


DELETE
  FROM tbepr_cdc_usuario
 WHERE idusuario IN ( 5748, 12157 );


DELETE
  FROM tbepr_cdc_emprestimo
 WHERE CDCOOPER = 1
   AND idvendedor IN ( 5748, 12155 )   ;


 DELETE
   FROM tbepr_cdc_lojista_subseg
  WHERE idcooperado_cdc = 11293;


 DELETE
   FROM tbepr_cdc_vendedor
  WHERE idvendedor IN ( 5748, 12155 );

 
 DELETE
   FROM TBSITE_COOPERADO_CDC
  WHERE CDCOOPER = 1
    AND NRDCONTA IN ( 9731130  )   ;
    
    
	
DELETE
  FROM crapcdr
 WHERE CDCOOPER = 1
   AND NRDCONTA IN ( 9731130 );

   
commit; 
