declare
  TYPE t_usuario IS RECORD
     ( nrcpf        VARCHAR2(25)
      ,nmvendedor   VARCHAR2(200)
      ,dsemail      VARCHAR2(200)
      ,admin        VARCHAR2(15)
     );

  TYPE tp_usuario IS TABLE OF t_usuario INDEX BY PLS_INTEGER;

  CURSOR cr_loja IS
    SELECT  idcooperado_cdc
    FROM    tbsite_cooperado_cdc
    WHERE cdcooper = 6 -- Unilos
    AND   nrdconta = 243493 -- Lojas Colombo
    and   idmatriz is null;
  vr_idcooperado_cdc      number;

  tb_usuario              tp_usuario;
  vr_nrcpf                VARCHAR2(200);
  vr_fladmin              NUMBER(01);
  vr_dscritic             VARCHAR2(200);
begin
  OPEN cr_loja;
  FETCH  cr_loja
  INTO   vr_idcooperado_cdc;
  CLOSE cr_loja;

  dbms_output.put_line('idcooperado_cdc=' || vr_idcooperado_cdc);
tb_usuario( 1 ) := t_usuario('040.795.779-07','GREICE REGIANE NICHES','colombo@colombo.com.br','Vendedor');
tb_usuario( 2 ) := t_usuario('014.060.649-12','JEAN RONY CATUL','colombo@colombo.com.br','Vendedor');
tb_usuario( 3 ) := t_usuario('003.819.379-50','RODRIGO ALEXANDRE DA CONCEICAO','colombo@colombo.com.br','Vendedor');
tb_usuario( 4 ) := t_usuario('295.196.498-67','JULIO CESAR CASTANHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 5 ) := t_usuario('068.170.201-07','JEMPS GERMEUS','colombo@colombo.com.br','Vendedor');
tb_usuario( 6 ) := t_usuario('096.483.589-40','RENATA DA SILVA IGNACIO','colombo@colombo.com.br','Vendedor');
tb_usuario( 7 ) := t_usuario('772.391.561-68','CATIA REGINA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 8 ) := t_usuario('052.741.209-03','EDIUMAR KUNTZ','colombo@colombo.com.br','Vendedor');
tb_usuario( 9 ) := t_usuario('577.499.579-87','OSVALDO ALVES DE BRITO','colombo@colombo.com.br','Vendedor');
tb_usuario( 10  ) := t_usuario('101.455.889-12','LUIZ FERNANDO MARTINS','colombo@colombo.com.br','Vendedor');
tb_usuario( 11  ) := t_usuario('857.515.969-00','MARIA ADELINA ALVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 12  ) := t_usuario('109.807.009-73','BRUNA NUNES DE ALMEIDA','colombo@colombo.com.br','Vendedor');
tb_usuario( 13  ) := t_usuario('693.323.632-34','DALLAS FERNANDES DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 14  ) := t_usuario('070.296.444-17','NIVIA DE LIMA MORAIS CUNHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 15  ) := t_usuario('016.708.690-16','ADRIANO DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 16  ) := t_usuario('707.416.389-91','EVALDO PIERRI NETO','colombo@colombo.com.br','Vendedor');
tb_usuario( 17  ) := t_usuario('042.661.489-50','FRANCINE DAIANA SERINO CATARINA','colombo@colombo.com.br','Vendedor');
tb_usuario( 18  ) := t_usuario('077.272.929-82','FERNANDO DA CONCEICAO','colombo@colombo.com.br','Vendedor');
tb_usuario( 19  ) := t_usuario('104.967.289-54','SOLANGE DA LUZ BIALESKI','colombo@colombo.com.br','Vendedor');
tb_usuario( 20  ) := t_usuario('015.653.929-22','PEDRO PAULO CARDOSO','colombo@colombo.com.br','Vendedor');
tb_usuario( 21  ) := t_usuario('104.984.369-00','LUCAS DE LIMA','colombo@colombo.com.br','Vendedor');
tb_usuario( 22  ) := t_usuario('103.115.889-80','HERICLES COSTA FARIAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 23  ) := t_usuario('083.885.779-56','MAICON CARDOSO PREIS','colombo@colombo.com.br','Vendedor');
tb_usuario( 24  ) := t_usuario('009.377.019-71','DIEGO CARLOS MARTINS MANSANO','colombo@colombo.com.br','Vendedor');
tb_usuario( 25  ) := t_usuario('063.961.349-77','DANIEL FERNANDES DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 26  ) := t_usuario('800.666.989-95','FRANCY OSIAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 27  ) := t_usuario('014.130.329-82','MAXEN STIVERNE','colombo@colombo.com.br','Vendedor');
tb_usuario( 28  ) := t_usuario('020.045.849-39','SANDRO THEISGES','colombo@colombo.com.br','Vendedor');
tb_usuario( 29  ) := t_usuario('121.056.559-55','BRUNO LUAN MATIAS DOS PASSOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 30  ) := t_usuario('902.458.909-63','LEVI MAES JUNIOR','colombo@colombo.com.br','Vendedor');
tb_usuario( 31  ) := t_usuario('121.478.037-74','LEANDRO SOUZA DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 32  ) := t_usuario('040.723.070-09','JOSIEL DA SILVA MONTEIRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 33  ) := t_usuario('801.040.309-17','EDISSON EUGENE','colombo@colombo.com.br','Vendedor');
tb_usuario( 34  ) := t_usuario('371.508.588-64','ELAINE ANDRADE MATHIAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 35  ) := t_usuario('994.780.300-78','ADRIANO MOREIRA DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 36  ) := t_usuario('058.400.059-67','LUCAS OSCAR SAGAZ','colombo@colombo.com.br','Vendedor');
tb_usuario( 37  ) := t_usuario('077.629.909-33','ALISSON AIRTON DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 38  ) := t_usuario('622.810.709-72','TERESINHA VASCONCELOS DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 39  ) := t_usuario('092.927.409-11','NILSON DE OLIVEIRA JUNIOR','colombo@colombo.com.br','Vendedor');
tb_usuario( 40  ) := t_usuario('095.196.939-04','KAROLINE CARVALHO DE SOUSA BARCELOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 41  ) := t_usuario('801.030.349-60','MIKELITE ABRAHAM','colombo@colombo.com.br','Vendedor');
tb_usuario( 42  ) := t_usuario('030.365.270-52','JUCIMERI VIEIRA DE VIEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 43  ) := t_usuario('001.572.729-74','ADRIANO FRANCISCO PIRES','colombo@colombo.com.br','Vendedor');
tb_usuario( 44  ) := t_usuario('675.897.402-25','MOACIR DA SILVA FERREIRA NASCIMENTO','colombo@colombo.com.br','Vendedor');
tb_usuario( 45  ) := t_usuario('044.915.209-09','LUCILENE NOELI DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 46  ) := t_usuario('800.174.949-58','JEAN ALEX EXUME','colombo@colombo.com.br','Vendedor');
tb_usuario( 47  ) := t_usuario('733.320.542-87','ROSALVO RODRIGUES DA COSTA LOPES','colombo@colombo.com.br','Vendedor');
tb_usuario( 48  ) := t_usuario('016.451.550-05','ANELISE CATARINA SIGLINSKI','colombo@colombo.com.br','Vendedor');
tb_usuario( 49  ) := t_usuario('865.618.552-72','DANIEL SANTOS DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 50  ) := t_usuario('105.088.079-05','DANYELI GONCALVES RODRIGUES','colombo@colombo.com.br','Vendedor');
tb_usuario( 51  ) := t_usuario('040.138.649-08','DENILSON TELES DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 52  ) := t_usuario('011.824.169-93','EMERSON DIAS GONCALVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 53  ) := t_usuario('017.005.410-13','JOHN LENNON ROSA DE PAULA','colombo@colombo.com.br','Vendedor');
tb_usuario( 54  ) := t_usuario('095.655.439-36','MATEUS DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 55  ) := t_usuario('069.305.451-47','CELIDIEU JOSEPH','colombo@colombo.com.br','Vendedor');
tb_usuario( 56  ) := t_usuario('056.869.249-70','CRISTIANE LAURENTINO DA SILVA HEINECK','colombo@colombo.com.br','Vendedor');
tb_usuario( 57  ) := t_usuario('800.736.859-09','JEAN CHARLEMAGNE BAPTISTE','colombo@colombo.com.br','Vendedor');
tb_usuario( 58  ) := t_usuario('800.174.919-32','MAKENSON BEVERLY LOUIS','colombo@colombo.com.br','Vendedor');
tb_usuario( 59  ) := t_usuario('068.893.089-13','ROBSON CARVALHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 60  ) := t_usuario('101.176.574-84','CLAUDIANO JOSE BARBOSA','colombo@colombo.com.br','Vendedor');
tb_usuario( 61  ) := t_usuario('866.948.995-30','GLEISON DE SANTANA FAUSTINO','colombo@colombo.com.br','Vendedor');
tb_usuario( 62  ) := t_usuario('602.499.690-09','JEAN DUKENSON CHERY','colombo@colombo.com.br','Vendedor');
tb_usuario( 63  ) := t_usuario('104.331.369-95','TASSIANO SANTOS DO AMARAL','colombo@colombo.com.br','Vendedor');
tb_usuario( 64  ) := t_usuario('515.725.910-72','AGUINALDO RODRIGUES RIBEIRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 65  ) := t_usuario('058.718.369-17','FRANCIELE DAIANE PEREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 66  ) := t_usuario('006.560.410-56','ANGELICA DE VIANA ANACLETO DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 67  ) := t_usuario('076.561.926-11','DANIEL LIMA SILVA FERREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 68  ) := t_usuario('089.080.899-69','MAIARA TEIXEIRA DE FARIAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 69  ) := t_usuario('022.182.579-71','ANTONIO JOSE BONIN','colombo@colombo.com.br','Vendedor');
tb_usuario( 70  ) := t_usuario('079.105.889-17','CLEBER RANLOW','colombo@colombo.com.br','Vendedor');
tb_usuario( 71  ) := t_usuario('815.657.205-04','JOSEVAL CERQUEIRA DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 72  ) := t_usuario('115.618.729-03','PATRIQUE VIEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 73  ) := t_usuario('709.052.442-65','EBYDORINCE VOLTAIRE','colombo@colombo.com.br','Vendedor');
tb_usuario( 74  ) := t_usuario('801.195.689-26','HENRY CLAUDE MORISSET','colombo@colombo.com.br','Vendedor');
tb_usuario( 75  ) := t_usuario('052.268.819-59','JEFFERSON DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 76  ) := t_usuario('708.042.602-22','JUNIOR WESLY MICHEL','colombo@colombo.com.br','Vendedor');
tb_usuario( 77  ) := t_usuario('708.592.762-36','LEONEL FENELON','colombo@colombo.com.br','Vendedor');
tb_usuario( 78  ) := t_usuario('801.406.229-93','JOHN KELLY ULYSSE','colombo@colombo.com.br','Vendedor');
tb_usuario( 79  ) := t_usuario('165.718.648-27','LUCIANE CHEDID GRANERO','colombo@colombo.com.br','Vendedor');
tb_usuario( 80  ) := t_usuario('703.079.082-08','TENIAS MINGOT','colombo@colombo.com.br','Vendedor');
tb_usuario( 81  ) := t_usuario('025.326.669-60','CIMARA DE CASSIA DA SILVA FERNANDES','colombo@colombo.com.br','Vendedor');
tb_usuario( 82  ) := t_usuario('087.264.569-07','JUSSARA RIBEIRO GONSALVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 83  ) := t_usuario('800.749.869-96','JEAN NATIVE VERTUS','colombo@colombo.com.br','Vendedor');
tb_usuario( 84  ) := t_usuario('025.212.060-40','FABIANO BARROZO DE FREITAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 85  ) := t_usuario('010.476.179-27','DIEGO AMARAL','colombo@colombo.com.br','Vendedor');
tb_usuario( 86  ) := t_usuario('863.495.389-00','IVANA MARA PATZLAFF DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 87  ) := t_usuario('082.225.899-46','JERICO VIEIRA DE FARIAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 88  ) := t_usuario('101.561.569-46','VINICIUS COELHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 89  ) := t_usuario('952.095.659-04','LEANDRO DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 90  ) := t_usuario('083.542.889-35','BRUNO MICHEL DE QUADROS CARNEIRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 91  ) := t_usuario('864.007.700-20','TATIANA DUARTE ROCHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 92  ) := t_usuario('075.785.309-92','JACQUELINE EVELIN DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 93  ) := t_usuario('079.144.359-02','TIAGO POLIS DA ROCHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 94  ) := t_usuario('827.160.560-72','LIEGE DE SOUZA CORREA','colombo@colombo.com.br','Vendedor');
tb_usuario( 95  ) := t_usuario('028.053.849-97','JULIANA DA SILVA HONORATO','colombo@colombo.com.br','Vendedor');
tb_usuario( 96  ) := t_usuario('093.931.119-44','LUANA BORGES JORGE','colombo@colombo.com.br','Vendedor');
tb_usuario( 97  ) := t_usuario('022.475.679-67','EDNA SANTOS DA SILVEIRA KLEIN','colombo@colombo.com.br','Vendedor');
tb_usuario( 98  ) := t_usuario('683.935.399-00','ROBSON LUIZ ARCEGA','colombo@colombo.com.br','Vendedor');
tb_usuario( 99  ) := t_usuario('888.316.479-20','ALEXANDRE ATHOS GOTZ','colombo@colombo.com.br','Vendedor');
tb_usuario( 100 ) := t_usuario('076.032.219-86','RAFAEL SILVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 101 ) := t_usuario('031.445.679-14','GISELLE PRAZERES CARDOSO','colombo@colombo.com.br','Vendedor');
tb_usuario( 102 ) := t_usuario('069.778.089-93','ISRAEL PEREIRA COSTA','colombo@colombo.com.br','Vendedor');
tb_usuario( 103 ) := t_usuario('068.660.295-11','JURACI DOS SANTOS REIS','colombo@colombo.com.br','Vendedor');
tb_usuario( 104 ) := t_usuario('107.577.509-40','WESLLER DOS PASSOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 105 ) := t_usuario('041.882.879-26','RANGEL COSTA IGNACIO','colombo@colombo.com.br','Vendedor');
tb_usuario( 106 ) := t_usuario('100.453.839-10','VICTORIA DA SILVA DIAS MONTEIRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 107 ) := t_usuario('102.599.239-31','PAOLA FONSECA DE BARROS','colombo@colombo.com.br','Vendedor');
tb_usuario( 108 ) := t_usuario('949.656.090-34','DENIZE PERES NUNES','colombo@colombo.com.br','Vendedor');
tb_usuario( 109 ) := t_usuario('049.860.999-57','ROMULO KAIKE PINTO TRAYA','colombo@colombo.com.br','Vendedor');
tb_usuario( 110 ) := t_usuario('101.915.279-63','DOUGLAS JUCELIO FLORES','colombo@colombo.com.br','Vendedor');
tb_usuario( 111 ) := t_usuario('856.884.289-53','JHONES PRESLEY BASE','colombo@colombo.com.br','Vendedor');
tb_usuario( 112 ) := t_usuario('074.656.385-00','ROMARIO DA SILVA VITORIO ESTRELA','colombo@colombo.com.br','Vendedor');
tb_usuario( 113 ) := t_usuario('110.528.479-43','VICTOR FELIPE BORGES JUKOWSKI','colombo@colombo.com.br','Vendedor');
tb_usuario( 114 ) := t_usuario('014.389.589-35','EDILEIA REGINA DA CUNHA MONTAGNA','colombo@colombo.com.br','Vendedor');
tb_usuario( 115 ) := t_usuario('013.595.515-73','AGENOR DOS SANTOS CRUZ FILHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 116 ) := t_usuario('035.309.119-76','DAIANA ARRUDA FRONZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 117 ) := t_usuario('014.422.822-07','VICTOR HUGO LOPES PALHETA','colombo@colombo.com.br','Vendedor');
tb_usuario( 118 ) := t_usuario('846.689.110-20','GEAN CARLOS GONCALVES MACHRY','colombo@colombo.com.br','Vendedor');
tb_usuario( 119 ) := t_usuario('082.452.919-78','ALEXANDRE LOURENCO PIA','colombo@colombo.com.br','Vendedor');
tb_usuario( 120 ) := t_usuario('011.450.890-97','JOAO GABRIEL DA SILVA CARVALHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 121 ) := t_usuario('088.444.809-64','GUSTAVO MEDEIROS DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 122 ) := t_usuario('097.359.969-36','DANIELA CRISTINA DE VARGAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 123 ) := t_usuario('584.292.559-15','EDSON DE SANTIAGO','colombo@colombo.com.br','Vendedor');
tb_usuario( 124 ) := t_usuario('009.431.279-63','GUILHERME MADALENA COLONETTI','colombo@colombo.com.br','Vendedor');
tb_usuario( 125 ) := t_usuario('074.611.819-80','ANELISE RODRIGUES COITINHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 126 ) := t_usuario('750.884.529-34','SONIA APARECIDA MELO DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 127 ) := t_usuario('013.372.749-17','JANETE FERREIRA DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 128 ) := t_usuario('060.329.449-99','MIKAEL MARTINI','colombo@colombo.com.br','Vendedor');
tb_usuario( 129 ) := t_usuario('591.008.939-00','OZAIR DE ARAUJO','colombo@colombo.com.br','Vendedor');
tb_usuario( 130 ) := t_usuario('071.895.145-03','JOELSON SILVA DOS ANJOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 131 ) := t_usuario('004.275.749-51','JORGE LUIZ DA SILVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 132 ) := t_usuario('092.267.869-33','ANDRIELLI DA SILVA CUNHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 133 ) := t_usuario('106.208.729-18','GABRIEL JARDIM MACHADO','colombo@colombo.com.br','Vendedor');
tb_usuario( 134 ) := t_usuario('041.262.169-01','CARLOS FERNANDO BOROWSKI','colombo@colombo.com.br','Vendedor');
tb_usuario( 135 ) := t_usuario('084.524.945-21','DOUGLAS CRISTIANO MENDES CERQUEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 136 ) := t_usuario('096.540.859-09','JACQUESON DE LIMA MARTINS','colombo@colombo.com.br','Vendedor');
tb_usuario( 137 ) := t_usuario('023.054.549-10','MARCOS APARECIDO DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 138 ) := t_usuario('069.357.669-31','SIMONE OLIVEIRA DE FREITAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 139 ) := t_usuario('639.124.492-87','ERICK SCHAEFFER','colombo@colombo.com.br','Vendedor');
tb_usuario( 140 ) := t_usuario('023.622.175-23','JOSUE MENEZES DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 141 ) := t_usuario('697.458.119-04','ITACIR JOSE LIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 142 ) := t_usuario('119.698.719-03','ANA CLARA GRISOTTO MEXIA','colombo@colombo.com.br','Vendedor');
tb_usuario( 143 ) := t_usuario('019.066.650-10','VANESSA RODRIGUES DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 144 ) := t_usuario('983.510.100-06','MARCIO ANDRE PEREIRA DE LIMA','colombo@colombo.com.br','Vendedor');
tb_usuario( 145 ) := t_usuario('071.405.659-61','SUELEN CRISTINA CONRADO DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 146 ) := t_usuario('973.631.540-15','EDER ALVES SEVERINO','colombo@colombo.com.br','Vendedor');
tb_usuario( 147 ) := t_usuario('008.744.070-95','FABIANA NEBENZAHL BAIRROS','colombo@colombo.com.br','Vendedor');
tb_usuario( 148 ) := t_usuario('646.675.109-00','VORLEI CAPISTRANO DA CUNHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 149 ) := t_usuario('083.054.109-86','ANA FRANCISCA RAMOS CARDOSO','colombo@colombo.com.br','Vendedor');
tb_usuario( 150 ) := t_usuario('866.559.579-15','ANDERSON FLAVIO DA COSTA','colombo@colombo.com.br','Vendedor');
tb_usuario( 151 ) := t_usuario('020.144.110-18','CLODOALDO OLIVEIRA PIRES','colombo@colombo.com.br','Vendedor');
tb_usuario( 152 ) := t_usuario('100.050.079-92','JESSICA BROERING','colombo@colombo.com.br','Vendedor');
tb_usuario( 153 ) := t_usuario('028.212.109-90','REGIANE MARIA TAVARES','colombo@colombo.com.br','Vendedor');
tb_usuario( 154 ) := t_usuario('085.963.249-09','YASMIM MARTINS BOING','colombo@colombo.com.br','Vendedor');
tb_usuario( 155 ) := t_usuario('075.700.479-23','LUCAS DIOGO DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 156 ) := t_usuario('124.911.919-70','BEATRIZ ESIQUIEL CABREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 157 ) := t_usuario('728.335.729-72','MARCELO JOSE ANDUJAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 158 ) := t_usuario('075.774.319-66','MERYLIN LOURES DE LIMA','colombo@colombo.com.br','Vendedor');
tb_usuario( 159 ) := t_usuario('091.489.169-35','CAROLLINE GONSALVES DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 160 ) := t_usuario('059.997.951-84','JENYFFER ALISSON SILVEIRA DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 161 ) := t_usuario('099.077.219-56','TCHARLA TAINA RODRIGUES','colombo@colombo.com.br','Vendedor');
tb_usuario( 162 ) := t_usuario('032.678.720-81','ANA CAROLINE SZEFER','colombo@colombo.com.br','Vendedor');
tb_usuario( 163 ) := t_usuario('064.132.199-63','BRUNO ANDRE BAGINSKI','colombo@colombo.com.br','Vendedor');
tb_usuario( 164 ) := t_usuario('098.919.029-35','ERICA CRISTINA DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 165 ) := t_usuario('105.584.189-02','AMANDA APARECIDA PRAIZNER DE FREITAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 166 ) := t_usuario('569.926.619-49','JOAO CARLOS DAL RI','colombo@colombo.com.br','Vendedor');
tb_usuario( 167 ) := t_usuario('022.579.188-94','WILTON FELIPE BEZERRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 168 ) := t_usuario('007.424.433-70','KELVIA MATOS DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 169 ) := t_usuario('110.830.909-76','ANA CAROLINA HONES','colombo@colombo.com.br','Vendedor');
tb_usuario( 170 ) := t_usuario('801.347.219-18','CHRISNO MICHEL','colombo@colombo.com.br','Vendedor');
tb_usuario( 171 ) := t_usuario('040.792.520-13','JULIANA HEVELLIN ZARPELLON DAS NEVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 172 ) := t_usuario('006.178.119-38','KELI CRISTINA NOVAK FAGUNDES','colombo@colombo.com.br','Vendedor');
tb_usuario( 173 ) := t_usuario('096.413.649-01','MONIKE EVER BERNAL SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 174 ) := t_usuario('862.288.635-25','RAFAEL FREITAS LEANDRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 175 ) := t_usuario('088.019.469-37','RICARDO MURILO DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 176 ) := t_usuario('037.102.300-98','RODRIGO COLLARES SHIMIESKI','colombo@colombo.com.br','Vendedor');
tb_usuario( 177 ) := t_usuario('801.006.769-52','ROLDVENS LAZARD','colombo@colombo.com.br','Vendedor');
tb_usuario( 178 ) := t_usuario('611.993.863-08','ROMARIO GOMES RODRIGUES','colombo@colombo.com.br','Vendedor');
tb_usuario( 179 ) := t_usuario('982.027.589-04','JOSIANE BUENO DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 180 ) := t_usuario('084.920.719-31','CAMILA DA SILVA APOLINARIO','colombo@colombo.com.br','Vendedor');
tb_usuario( 181 ) := t_usuario('956.614.849-68','GILSON JOSE FONSECA','colombo@colombo.com.br','Vendedor');
tb_usuario( 182 ) := t_usuario('124.161.449-01','KASSYA EVELYN NIELI DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 183 ) := t_usuario('703.282.112-06','WILLY PIERRE','colombo@colombo.com.br','Vendedor');
tb_usuario( 184 ) := t_usuario('810.002.609-25','ZELIA DO NASCIMENTO STIPP','colombo@colombo.com.br','Vendedor');
tb_usuario( 185 ) := t_usuario('882.820.400-10','MAURO JOSE DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 186 ) := t_usuario('003.670.429-67','CHEILA RAMOS MACIEL ENDER','colombo@colombo.com.br','Vendedor');
tb_usuario( 187 ) := t_usuario('031.577.039-27','RODRIGO DE GODOI','colombo@colombo.com.br','Vendedor');
tb_usuario( 188 ) := t_usuario('539.495.609-04','VICENTE RODRIGUES','colombo@colombo.com.br','Vendedor');
tb_usuario( 189 ) := t_usuario('020.096.829-71','CESAR AUGUSTO DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 190 ) := t_usuario('113.730.439-11','CAROL CRISTINA DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 191 ) := t_usuario('801.645.609-04','EDIMARCO DE MEDEIROS','colombo@colombo.com.br','Vendedor');
tb_usuario( 192 ) := t_usuario('093.825.379-45','JESSICA LOISE PEREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 193 ) := t_usuario('062.153.239-85','KATIA REGINA DA CUNHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 194 ) := t_usuario('868.003.960-87','VINICIUS LOPES DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 195 ) := t_usuario('868.862.400-30','RAISSA PERES ALVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 196 ) := t_usuario('800.885.459-62','YOSVANY SERVIA ABALLI','colombo@colombo.com.br','Vendedor');
tb_usuario( 197 ) := t_usuario('052.210.669-20','MARCELO ALESSANDRE KUHL','colombo@colombo.com.br','Vendedor');
tb_usuario( 198 ) := t_usuario('016.093.809-08','SANDRA ALBERTINA DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 199 ) := t_usuario('033.510.159-33','FRANCIELLI JULIANA PICUR CIRINO','colombo@colombo.com.br','Vendedor');
tb_usuario( 200 ) := t_usuario('019.340.009-06','JAISON ANTONIO PIERRI','colombo@colombo.com.br','Vendedor');
tb_usuario( 201 ) := t_usuario('677.812.332-04','RAFAELA SCARPARO GONSALVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 202 ) := t_usuario('040.810.709-03','VALTECIR MORAIS DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 203 ) := t_usuario('915.716.500-91','DAISA COSTA DE CASTILHOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 204 ) := t_usuario('099.570.864-99','JOEL FERREIRA DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 205 ) := t_usuario('089.668.049-50','MAYKON PEREIRA PEDRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 206 ) := t_usuario('852.398.280-91','RICARDO GOMES FERNANDES','colombo@colombo.com.br','Vendedor');
tb_usuario( 207 ) := t_usuario('066.055.489-57','CHAYNNER LUAN PESSOA','colombo@colombo.com.br','Vendedor');
tb_usuario( 208 ) := t_usuario('811.506.102-63','MARCUS VINICIUS BARROS XAVIER','colombo@colombo.com.br','Vendedor');
tb_usuario( 209 ) := t_usuario('047.316.959-29','PEDRO MULLER JUNIOR','colombo@colombo.com.br','Vendedor');
tb_usuario( 210 ) := t_usuario('749.725.109-00','JOSE CARLOS DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 211 ) := t_usuario('741.323.349-53','LUIZ CESAR GONCALVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 212 ) := t_usuario('091.177.399-18','AMANDA TAINA JUMES','colombo@colombo.com.br','Vendedor');
tb_usuario( 213 ) := t_usuario('083.203.549-19','JENIFFER MORAES DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 214 ) := t_usuario('072.415.199-06','LUAN FERNANDES SIQUEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 215 ) := t_usuario('920.881.120-49','FABIANA MENEGHEL JOAO SANCEVERINO','colombo@colombo.com.br','Vendedor');
tb_usuario( 216 ) := t_usuario('108.023.979-05','STEFANI RUANA DA ROSA','colombo@colombo.com.br','Vendedor');
tb_usuario( 217 ) := t_usuario('912.557.839-15','FABIO ADRIANO MEURER SILVINO','colombo@colombo.com.br','Vendedor');
tb_usuario( 218 ) := t_usuario('011.966.160-86','VOLNEI JUNIOR GOMES DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 219 ) := t_usuario('048.344.519-33','WELINGTON RUDINEI PADILHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 220 ) := t_usuario('068.609.449-27','HIAGO MAURINO DE ESPINDOLA','colombo@colombo.com.br','Vendedor');
tb_usuario( 221 ) := t_usuario('107.025.159-30','LUIS EDUARDO DE ANDRADE','colombo@colombo.com.br','Vendedor');
tb_usuario( 222 ) := t_usuario('052.765.349-77','FRANCIANE DA SILVA LUIZ','colombo@colombo.com.br','Vendedor');
tb_usuario( 223 ) := t_usuario('088.649.399-46','FRANCIELE SCHMITT VILVERT','colombo@colombo.com.br','Vendedor');
tb_usuario( 224 ) := t_usuario('268.421.061-68','JOSE PEREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 225 ) := t_usuario('117.414.699-02','WILLIAN RODRIGUES TRINDADE','colombo@colombo.com.br','Vendedor');
tb_usuario( 226 ) := t_usuario('100.109.439-51','RODRIGO STEIN','colombo@colombo.com.br','Vendedor');
tb_usuario( 227 ) := t_usuario('109.934.899-40','LEONAM DOMINGOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 228 ) := t_usuario('091.170.719-09','RUBENS SANTANA JUNIOR','colombo@colombo.com.br','Vendedor');
tb_usuario( 229 ) := t_usuario('218.934.308-98','AMANDA GUIMARAES DE SOUSA','colombo@colombo.com.br','Vendedor');
tb_usuario( 230 ) := t_usuario('707.387.442-20','JOSE FRANCISCO OJEDA GARCIA','colombo@colombo.com.br','Vendedor');
tb_usuario( 231 ) := t_usuario('035.456.430-77','PABLO DE MORAES CAMPOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 232 ) := t_usuario('042.737.390-54','KARINA AIRES ROJAHN','colombo@colombo.com.br','Vendedor');
tb_usuario( 233 ) := t_usuario('025.376.040-24','BRUNA STEPHANY BORGES BERTE','colombo@colombo.com.br','Vendedor');
tb_usuario( 234 ) := t_usuario('030.939.870-32','LEONARDO MACHADO CHAVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 235 ) := t_usuario('002.925.250-44','RAQUEL FONSECA TEIXEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 236 ) := t_usuario('007.400.799-80','ANA MARIA MEROS DOS SANTOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 237 ) := t_usuario('669.137.729-04','LUIZ CARLOS BELLINI','colombo@colombo.com.br','Vendedor');
tb_usuario( 238 ) := t_usuario('007.335.810-05','WAGNER OLIVEIRA DA ROCHA','colombo@colombo.com.br','Vendedor');
tb_usuario( 239 ) := t_usuario('023.185.099-99','ALEXSSANDRE LIMA TELEGINSKI','colombo@colombo.com.br','Vendedor');
tb_usuario( 240 ) := t_usuario('047.589.749-85','FRANCIELE CRISTINA MORETTO XAVIER','colombo@colombo.com.br','Vendedor');
tb_usuario( 241 ) := t_usuario('105.151.909-85','RAFAELA CRISTINA DA SILVA RIBEIRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 242 ) := t_usuario('334.736.018-45','PRISCILA SALES DE CARVALHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 243 ) := t_usuario('054.368.839-90','JOSIANE MACHADO','colombo@colombo.com.br','Vendedor');
tb_usuario( 244 ) := t_usuario('019.674.310-94','AMANDA DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 245 ) := t_usuario('094.088.509-39','"IZABOHR SOUZA PROENCA  "','colombo@colombo.com.br','Vendedor');
tb_usuario( 246 ) := t_usuario('023.440.169-96','SILVANA BENTA MACHADO DE LIMA','colombo@colombo.com.br','Vendedor');
tb_usuario( 247 ) := t_usuario('074.162.809-07','MARIO JOSE MADEL','colombo@colombo.com.br','Vendedor');
tb_usuario( 248 ) := t_usuario('351.721.238-57','RODRIGO SANTOS DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 249 ) := t_usuario('084.745.669-24','TAIS SANTOS DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 250 ) := t_usuario('014.971.430-04','LEANDRO PEREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 251 ) := t_usuario('009.633.889-08','FERNANDO DA PURIFICACAO','colombo@colombo.com.br','Vendedor');
tb_usuario( 252 ) := t_usuario('093.552.429-05','MARIELE ALEXANDRE DAL PONTE','colombo@colombo.com.br','Vendedor');
tb_usuario( 253 ) := t_usuario('040.651.209-42','CRISLEIA GONCALVES','colombo@colombo.com.br','Vendedor');
tb_usuario( 254 ) := t_usuario('040.548.640-58','VITOR BITTENCOURT ROHDE','colombo@colombo.com.br','Vendedor');
tb_usuario( 255 ) := t_usuario('901.950.439-87','RODRIGO DE SOUZA E SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 256 ) := t_usuario('004.170.729-02','SIMONE DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 257 ) := t_usuario('007.171.700-55','TIAGO MAGNUS FAUSTINO','colombo@colombo.com.br','Vendedor');
tb_usuario( 258 ) := t_usuario('054.187.779-80','GISELE APARECIDA DE FREITAS MOREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 259 ) := t_usuario('020.626.630-80','JAILSON DA COSTA PEREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 260 ) := t_usuario('012.196.569-41','STEFANIE BERGAMO ANDRADE','colombo@colombo.com.br','Vendedor');
tb_usuario( 261 ) := t_usuario('064.337.089-78','GABRIEL DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 262 ) := t_usuario('087.464.249-38','KEITH FERNANDES CARLOS','colombo@colombo.com.br','Vendedor');
tb_usuario( 263 ) := t_usuario('034.306.139-22','FABIO SERAFIM BOEING','colombo@colombo.com.br','Vendedor');
tb_usuario( 264 ) := t_usuario('077.185.639-36','DARASELE FRANCINE MARIA','colombo@colombo.com.br','Vendedor');
tb_usuario( 265 ) := t_usuario('126.370.469-70','NATHALIA DOS SANTOS DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 266 ) := t_usuario('030.846.320-06','BRUNO FERNANDES DA PORCIUNCULA','colombo@colombo.com.br','Vendedor');
tb_usuario( 267 ) := t_usuario('728.397.832-15','EMANUEL MENDONCA PINHEIRO','colombo@colombo.com.br','Vendedor');
tb_usuario( 268 ) := t_usuario('104.915.299-96','GABRIEL ROBERTO DE SOUSA','colombo@colombo.com.br','Vendedor');
tb_usuario( 269 ) := t_usuario('037.365.530-48','JOAO LUIZ DE OLIVEIRA RODRIGUES','colombo@colombo.com.br','Vendedor');
tb_usuario( 270 ) := t_usuario('058.546.679-32','JOSE LUIS FREITAS PAES','colombo@colombo.com.br','Vendedor');
tb_usuario( 271 ) := t_usuario('011.980.529-45','MATEUS DE JESUS STANDT','colombo@colombo.com.br','Vendedor');
tb_usuario( 272 ) := t_usuario('091.996.779-54','MATHEUS MACHADO','colombo@colombo.com.br','Vendedor');
tb_usuario( 273 ) := t_usuario('734.021.769-04','MAURO FRANCISCO RODRIGUES','colombo@colombo.com.br','Vendedor');
tb_usuario( 274 ) := t_usuario('041.154.910-35','MISAEL DA COSTA DOS REIS','colombo@colombo.com.br','Vendedor');
tb_usuario( 275 ) := t_usuario('016.606.422-05','LUAN LUCAS CANDIDO DE ALMEIDA','colombo@colombo.com.br','Vendedor');
tb_usuario( 276 ) := t_usuario('034.147.939-03','TATIANE ROCHA MULAZANI','colombo@colombo.com.br','Vendedor');
tb_usuario( 277 ) := t_usuario('058.603.465-06','JANILSON PEREIRA DE SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 278 ) := t_usuario('097.970.219-47','VINICIUS BECKER DE OLIVEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 279 ) := t_usuario('025.028.922-95','BIANCA WANESSA DA SILVA BANDEIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 280 ) := t_usuario('099.844.309-36','DANIMAR JUNIOR DA SILVA VARGAS','colombo@colombo.com.br','Vendedor');
tb_usuario( 281 ) := t_usuario('079.342.659-64','GABRIELLY JANSEN DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 282 ) := t_usuario('055.212.329-31','MICHELE DA SILVA MIRANDA','colombo@colombo.com.br','Vendedor');
tb_usuario( 283 ) := t_usuario('119.224.389-79','PRISCILA LAYS GOMES','colombo@colombo.com.br','Vendedor');
tb_usuario( 284 ) := t_usuario('112.201.659-05','BRUNO FERREIRA DA CRUZ','colombo@colombo.com.br','Vendedor');
tb_usuario( 285 ) := t_usuario('113.933.589-85','JESSE SAMUEL PANONTIM','colombo@colombo.com.br','Vendedor');
tb_usuario( 286 ) := t_usuario('010.318.181-46','CELSO ROBERTO RANGEL JUNIOR','colombo@colombo.com.br','Vendedor');
tb_usuario( 287 ) := t_usuario('065.276.159-30','JANAINA FABRIS BORGES','colombo@colombo.com.br','Vendedor');
tb_usuario( 288 ) := t_usuario('078.027.199-84','MARCOS FELIPE PAIM','colombo@colombo.com.br','Vendedor');
tb_usuario( 289 ) := t_usuario('113.091.519-03','ELIANE VICTORIA BATISTA','colombo@colombo.com.br','Vendedor');
tb_usuario( 290 ) := t_usuario('068.711.535-35','DENIVY DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 291 ) := t_usuario('077.272.619-12','ARTHUR PEREIRA HERRERA DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 292 ) := t_usuario('148.497.077-26','DAVID ESPINDOLA LINS','colombo@colombo.com.br','Vendedor');
tb_usuario( 293 ) := t_usuario('404.835.648-85','ALLANA RAQUEL ALENCAR LIBORIO','colombo@colombo.com.br','Vendedor');
tb_usuario( 294 ) := t_usuario('013.879.180-52','JULIANO MATEUS DE AQUINO BEULK','colombo@colombo.com.br','Vendedor');
tb_usuario( 295 ) := t_usuario('020.860.809-56','LIZANDRO COSTA NATIVIDADE','colombo@colombo.com.br','Vendedor');
tb_usuario( 296 ) := t_usuario('955.118.650-87','RODRIGO ALBERTO ROST','colombo@colombo.com.br','Vendedor');
tb_usuario( 297 ) := t_usuario('008.933.030-70','JAIME EZEQUIEL CARDOSO MIRANDA','colombo@colombo.com.br','Vendedor');
tb_usuario( 298 ) := t_usuario('071.781.179-40','FERNANDA ROSANA MATOS PEREIRA','colombo@colombo.com.br','Vendedor');
tb_usuario( 299 ) := t_usuario('040.744.799-74','SUELLEN MENDES DAS NEVES ASSIS','colombo@colombo.com.br','Vendedor');
tb_usuario( 300 ) := t_usuario('041.269.929-01','KARINA DOS SANTOS DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 301 ) := t_usuario('053.108.799-94','ANA CLAUDIA CORREA','colombo@colombo.com.br','Vendedor');
tb_usuario( 302 ) := t_usuario('108.668.759-05','MORGANA MACHADO','colombo@colombo.com.br','Vendedor');
tb_usuario( 303 ) := t_usuario('949.604.880-34','ALISSON RAFAEL MENEZES DA SILVA','colombo@colombo.com.br','Vendedor');
tb_usuario( 304 ) := t_usuario('891.841.652-00','GLEYDSON MORAES CARVALHO','colombo@colombo.com.br','Vendedor');
tb_usuario( 305 ) := t_usuario('123.686.979-69','GUSTAVO FERNANDES NASCIMENTO','colombo@colombo.com.br','Vendedor');
tb_usuario( 306 ) := t_usuario('056.136.085-55','HEVERTON SILVA SOUZA','colombo@colombo.com.br','Vendedor');
tb_usuario( 307 ) := t_usuario('031.248.442-97','MARCELINHO SOUZA DE ALMEIDA','colombo@colombo.com.br','Vendedor');
tb_usuario( 308 ) := t_usuario('091.644.279-94','DOUGLAS DE SA','colombo@colombo.com.br','Vendedor');
tb_usuario( 309 ) := t_usuario('006.772.100-19','DEIVID CIEPIELEWSKI','deivid@colombo.com.br','Administrador');
tb_usuario( 310 ) := t_usuario('994.394.090-53','ROSANGELA DE OLIVEIRA','rosangela.oliveira@colombo.com.br','Administrador');
tb_usuario( 311 ) := t_usuario('962.572.880-53','VANDERLEIA MARQUES DAL VESCO','vanderleia.vesco@colombo.com.br','Administrador');
tb_usuario( 312 ) := t_usuario('030.680.340-27','ALANA LODI','alana.lodi@colombo.com.br','Administrador');
tb_usuario( 313 ) := t_usuario('029.014.640-25','BRUNA ZENI','brunaz@colombo.com.br','Administrador');
tb_usuario( 314 ) := t_usuario('012.789.920-06','JUCIANE BAREA','juciane@colombo.com.br','Administrador');
tb_usuario( 315 ) := t_usuario('028.341.290-96','JESSICA HORTENCIA VIEIRA','jessica.vieira@colombo.com.br','Administrador');
tb_usuario( 316 ) := t_usuario('038.911.400-61','LIVIA ALOMA LOPES','livia.lopes@colombo.com.br','Administrador');
tb_usuario( 317 ) := t_usuario('001.570.280-46','FABIANO MASIERO','fabianom@colombo.com.br','Administrador');
tb_usuario( 318 ) := t_usuario('012.685.070-40','KETLIN LUANDA ZINN','ketlin.zinn@colombo.com.br','Administrador');
tb_usuario( 319 ) := t_usuario('012.502.831.83','PAULO TAIRA','paulod@colombo.com.br','Administrador');
tb_usuario( 320 ) := t_usuario('034.760.750-01','DANIELE LIS GEHLEN','daniele@colombo.com.br','Administrador');
tb_usuario( 321 ) := t_usuario('832.421.550-68','MICHELI BORSATO','contasfornecedores@colombo.com.br','Administrador');
tb_usuario( 322 ) := t_usuario('921.271.939-20','ANDR� LUIZ DA SILVA','andre.silva@colombo.com.br','Administrador');

  for ind_usuario in 1..nvl(tb_usuario.last, 0) loop
    tb_usuario(ind_usuario).nrcpf := ltrim(translate(tb_usuario(ind_usuario).nrcpf, ' .-', ' '));
    vr_nrcpf := tb_usuario(ind_usuario).nrcpf;

    IF length(vr_nrcpf) <= 11 THEN
      vr_nrcpf := lpad(vr_nrcpf, 11, '0');
    ELSE
      vr_nrcpf := lpad(vr_nrcpf, 14, '0');
    END IF;

    IF substr(tb_usuario(ind_usuario).admin, 1, 1) = 'A' THEN
      vr_fladmin := 1;
    ELSE
      vr_fladmin := 0;
    END IF;

    EMPR0012.pc_cadastra_usuario(pr_idusuario        => null
                                ,pr_dslogin          => vr_nrcpf
                                ,pr_dssenha          => lower(RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.md5(input => UTL_RAW.cast_to_raw(vr_nrcpf))))
                                ,pr_dtinsori         => null
                                ,pr_flgativo         => 1
                                ,pr_fladmin          => vr_fladmin
                                ,pr_idcooperado_cdc  => vr_idcooperado_cdc
                                ,pr_nmvendedor       => tb_usuario(ind_usuario).nmvendedor
                                ,pr_nrcpf            => to_number(tb_usuario(ind_usuario).nrcpf)
                                ,pr_dsemail          => tb_usuario(ind_usuario).dsemail
                                ,pr_idcomissao       => null
                                ,pr_dscritic         => vr_dscritic
                                );
    IF vr_dscritic is not null THEN
      RAISE_APPLICATION_ERROR(-20501, 'Erro no CPF ' || tb_usuario(ind_usuario).nrcpf || ' : ' || vr_dscritic);
    END IF;
  end loop;
  
  COMMIT;
EXCEPTION
  WHEN others THEN
    RAISE_APPLICATION_ERROR(-20502, 'Erro: ' || SQLERRM);
end;
/
