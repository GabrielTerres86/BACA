UPDATE CRAPACA
   SET LSTPARAM = LSTPARAM||',pr_nrdddtel,pr_nrtelefo'
 WHERE NMPACKAG = 'CYBE0003'
   AND NMDEACAO = 'PARCYB_MANTER_ASSESSORIAS';
   
COMMIT;   
