BEGIN
    UPDATE CRAPLFT LFT
       SET LFT.DTVENCTO = TO_DATE('03/11/2021', 'DD/MM/YYYY'),
           LFT.INSITFAT = 1 
     WHERE LFT.PROGRESS_RECID IN  (SELECT LFT.PROGRESS_RECID
                                   FROM CRAPLFT LFT
                                    INNER JOIN (SELECT CDCOOPER, CASE CDCONVEN WHEN   67561 THEN   6 WHEN 8460071 THEN  71 WHEN 8480161 THEN 161 
                                                                               WHEN 8480162 THEN 162 WHEN 8480163 THEN 163 WHEN 8480221 THEN 221 ELSE 989 END CDEMPCON
                                                  FROM GNCONTR 
                                                 WHERE DTMVTOLT = TO_DATE('29/10/2021', 'DD/MM/YYYY') AND cdsitret IN (3,4)
                                                   AND NMARQUIV LIKE '%.AILOS%'
                                                   AND CDCONVEN IN (67561, 8460071, 8480161, 8480162, 8480163, 8480221)) ARQ ON ARQ.CDCOOPER = LFT.CDCOOPER AND ARQ.CDEMPCON = LFT.CDEMPCON
                                    WHERE LFT.DTVENCTO = TO_DATE('29/10/2021', 'DD/MM/YYYY') AND LFT.CDSEGMTO = 4);
    
    
    COMMIT;
END;