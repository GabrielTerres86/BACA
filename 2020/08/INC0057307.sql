/*
 --#1 ate 12:30 --#2 ate 17:30
*/

update crapprm p
   SET p.dsvlrprm = '03/08/2019#2' 
 WHERE p.cdcooper = 1
   AND p.cdacesso IN (
                      'CTRL_CRPS663_EXEC',
                      'CTRL_CRPS674_EXEC',
                      'CTRL_CRPS688_EXEC',
                      'CTRL_CRPS724_EXEC',
                      'CTRL_CRPS750_EXEC',
                      'CTRL_DEBBAN_EXEC',
                      'CTRL_DEBNET_EXEC',
                      'CTRL_DEBNET_PRIORI_EXEC',
                      'CTRL_DEBSIC_EXEC',
                      'CTRL_DEBSIC_PRIORI_EXEC',
                      'CTRL_DEBUNITAR_EXEC',
                      'CTRL_JOBAGERCEL_EXEC',
                      'CTRL_PREJU_TRF_EXEC'
                     );    
                     
commit;  
                   
