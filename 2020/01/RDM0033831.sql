
UPDATE crapsab
   SET nmdsacad = translate( nmdsacad,'ÑÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕÄËÏÖÜÇ()&*<>','NAEIOUAEIOUAEIOUAOAEIOUC')  ;                                          
   
commit;
