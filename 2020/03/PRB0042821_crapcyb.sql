UPDATE CRAPCYB CYB
   SET CYB.DTMANCAD = (SELECT D.DTMVTOLT FROM CRAPDAT D WHERE D.CDCOOPER = 3)
 WHERE EXISTS ( SELECT B.*, Y.DTMANCAD
                  FROM CRAPCOP C, CRAPCYB Y,
                       (SELECT 'VIACREDI AV' nmrescop,  2890097 nrdconta, 68236 nrctremp FROM dual union
                        SELECT 'EVOLUA' nmrescop,  79243 nrdconta,  18726 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9343318 nrdconta,  1881987 nrctremp FROM dual union
                        SELECT 'UNILOS' nmrescop,  169145 nrdconta,  225290 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10657703 nrdconta,  1669977 nrctremp FROM dual union
                        SELECT 'ACREDICOOP' nmrescop,  356565 nrdconta,  246558 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9416021 nrdconta,  1874935 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9651209 nrdconta,  1512011 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10164162 nrdconta,  1570742 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10632492 nrdconta,  1895705 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9564357 nrdconta,  1671453 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10406301 nrdconta,  1715960 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10378510 nrdconta,  1905305 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  3513424 nrdconta,  1912511 nrctremp FROM dual union
                        SELECT 'CREVISC' nmrescop,  2860 nrdconta,  18160 nrctremp FROM dual union
                        SELECT 'CREDIFOZ' nmrescop,  347477 nrdconta,  59774 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9783830 nrdconta,  146301 nrctremp FROM dual union
                        SELECT 'TRANSPOCRED' nmrescop,  237671 nrdconta,  14334 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  3639436 nrdconta,  1766143 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  6870805 nrdconta,  1493657 nrctremp FROM dual union
                        SELECT 'CREDCREA' nmrescop,  276898 nrdconta,  31115 nrctremp FROM dual union
                        SELECT 'TRANSPOCRED' nmrescop,  297712 nrdconta,  19796 nrctremp FROM dual union
                        SELECT 'TRANSPOCRED' nmrescop,  239640 nrdconta,  20590 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  514675 nrdconta,  124156 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8763992 nrdconta,  1965860 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8973377 nrdconta,  1067745 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9894640 nrdconta,  1433421 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10514058 nrdconta,  2017724 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9721002 nrdconta,  1704690 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7740441 nrdconta,  1944439 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7281943 nrdconta,  1671732 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  3720837 nrdconta,  1930115 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9538828 nrdconta,  1710008 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8777047 nrdconta,  1668621 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8777047 nrdconta,  1668623 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9771123 nrdconta,  1423773 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10531637 nrdconta,  1821897 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10910271 nrdconta,  1937158 nrctremp FROM dual union
                        SELECT 'EVOLUA' nmrescop,  131806 nrdconta,  131806 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  579521 nrdconta,  1844943 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  383090 nrdconta,  132991 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7444320 nrdconta,  1704829 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9416021 nrdconta,  1883604 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8973377 nrdconta,  1242273 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9902821 nrdconta,  1784254 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10099867 nrdconta,  1801557 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10365591 nrdconta,  1648493 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9783318 nrdconta,  1607978 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10183663 nrdconta,  1890754 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10339574 nrdconta,  1876336 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8757402 nrdconta,  1954875 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8424675 nrdconta,  1820199 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9894640 nrdconta,  1433413 nrctremp FROM dual union
                        SELECT 'ACREDICOOP' nmrescop,  634182 nrdconta,  253759 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10910271 nrdconta,  1904802 nrctremp FROM dual union
                        SELECT 'TRANSPOCRED' nmrescop,  911097 nrdconta,  20600 nrctremp FROM dual union
                        SELECT 'CREVISC' nmrescop,  90018 nrdconta,  9432 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10632492 nrdconta,  1890945 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10134689 nrdconta,  1886113 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10134689 nrdconta,  1895085 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  4059824 nrdconta,  146378 nrctremp FROM dual union
                        SELECT 'CREDIFOZ' nmrescop,  347477 nrdconta,  50415 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  214248 nrdconta,  104834 nrctremp FROM dual union
                        SELECT 'CREDIFOZ' nmrescop,  323349 nrdconta,  59110 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  6489672 nrdconta,  1952364 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7104200 nrdconta,  1946042 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9538976 nrdconta,  1553485 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7302444 nrdconta,  146113 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7042345 nrdconta,  1648759 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10729488 nrdconta,  1945197 nrctremp FROM dual union
                        SELECT 'UNILOS' nmrescop,  89508 nrdconta,  225824 nrctremp FROM dual union
                        SELECT 'UNILOS' nmrescop,  157902 nrdconta,  224025 nrctremp FROM dual union
                        SELECT 'EVOLUA' nmrescop,  79243 nrdconta,  18725 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  607592 nrdconta,  132984 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7058128 nrdconta,  1521214 nrctremp FROM dual union
                        SELECT 'TRANSPOCRED' nmrescop,  1252 nrdconta,  20567 nrctremp FROM dual union
                        SELECT 'CREDICOMIN' nmrescop,  115738 nrdconta,  115738 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10531637 nrdconta,  1859016 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10294490 nrdconta,  1606021 nrctremp FROM dual union
                        SELECT 'CREDIFOZ' nmrescop,  353612 nrdconta,  12172 nrctremp FROM dual union
                        SELECT 'ACREDICOOP' nmrescop,  640387 nrdconta,  252680 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10958690 nrdconta,  1956549 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10648666 nrdconta,  1895194 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8099090 nrdconta,  1997094 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9039058 nrdconta,  1427471 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9215735 nrdconta,  1895626 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  3981924 nrdconta,  1578324 nrctremp FROM dual union
                        SELECT 'CREDIFOZ' nmrescop,  480797 nrdconta,  50206 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8539685 nrdconta,  1156868 nrctremp FROM dual union
                        SELECT 'ACREDICOOP' nmrescop,  740675 nrdconta,  234739 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10845798 nrdconta,  1769985 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  2515938 nrdconta,  2515938 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  6900488 nrdconta,  1074147 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  6509711 nrdconta,  1492588 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10338969 nrdconta,  1459022 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10368507 nrdconta,  1845610 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10498745 nrdconta,  1847270 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7068727 nrdconta,  1686080 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10877550 nrdconta,  1833288 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10368507 nrdconta,  1845614 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9724567 nrdconta,  1166843 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  264660 nrdconta,  93575 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10373373 nrdconta,  1789307 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  3167127 nrdconta,  1668877 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  2479540 nrdconta,  2479540 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  2902419 nrdconta,  1398731 nrctremp FROM dual union
                        SELECT 'CREDIFOZ' nmrescop,  16802 nrdconta,  16802 nrctremp FROM dual union
                        SELECT 'CREDCREA' nmrescop,  118028 nrdconta,  30213 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  47074 nrdconta,  122381 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10498745 nrdconta,  1809365 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9775560 nrdconta,  1678596 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  2171422 nrdconta,  1433315 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9724567 nrdconta,  1166839 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7513836 nrdconta,  1300926 nrctremp FROM dual union
                        SELECT 'TRANSPOCRED' nmrescop,  233889 nrdconta,  13329 nrctremp FROM dual union
                        SELECT 'ACENTRA' nmrescop,  162760 nrdconta,  1785997 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  6047270 nrdconta,  1175168 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  4054318 nrdconta,  1159627 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  254452 nrdconta,  1926453 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  230790 nrdconta,  129232 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10950281 nrdconta,  1863973 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7923660 nrdconta,  965624 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7343191 nrdconta,  1829170 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10311459 nrdconta,  1787601 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  3500420 nrdconta,  1318931 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  4054318 nrdconta,  1159637 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7024096 nrdconta,  924931 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7068727 nrdconta,  1750852 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  8141363 nrdconta,  1205472 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  9720073 nrdconta,  1698118 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10234578 nrdconta,  1823856 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10716467 nrdconta,  1880338 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  7084315 nrdconta,  7084315 nrctremp FROM dual union
                        SELECT 'CREDIFOZ' nmrescop,  449300 nrdconta,  60735 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  254452 nrdconta,  1926451 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  3586766 nrdconta,  123189 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  3675262 nrdconta,  46426 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10498745 nrdconta,  1782529 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  6407404 nrdconta,  1507613 nrctremp FROM dual union
                        SELECT 'EVOLUA' nmrescop,  71242 nrdconta,  7732 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  2331934 nrdconta,  1221264 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  6409997 nrdconta,  1475380 nrctremp FROM dual union
                        SELECT 'CIVIA' nmrescop,  273643 nrdconta,  47932 nrctremp FROM dual union
                        SELECT 'VIACREDI AV' nmrescop,  254452 nrdconta,  1917071 nrctremp FROM dual union
                        SELECT 'VIACREDI' nmrescop,  10197060 nrdconta,  1909045 nrctremp FROM dual) b
                 WHERE C.NMRESCOP = B.NMRESCOP
                   AND C.CDCOOPER = Y.CDCOOPER
                   AND B.NRDCONTA = Y.NRDCONTA
                   AND B.NRCTREMP = Y.NRCTREMP
                   AND CYB.ROWID = Y.ROWID);

COMMIT;
