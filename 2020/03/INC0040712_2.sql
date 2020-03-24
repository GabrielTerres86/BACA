/*Ajustando casos onde foi ativado um novo CDC para o lojista sem desativar o anterior
  fazendo com que o vendedor padrão AILOS MOBILE não fosse criado para o novo convenio */

/*Ajuste para o lojista 80453400000191 - PROMENAC MOTOS LTDA */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 2400 where vendedor.idvendedor = 6985;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 2400 where vinculo.idvendedor = 6985;

/*Ajuste para o lojista 347111000179 - MOTOS E CIA */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 2461 where vendedor.idvendedor = 7022;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 2461 where vinculo.idvendedor = 7022;

/*Ajuste para o lojista 548252000150 - INSTALADORA CERUTTI */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 8250 where vendedor.idvendedor = 11321;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 8250 where vinculo.idvendedor = 11321;

/*Ajuste para o lojista 1125839000119 - EDUARDO MOVEIS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 11100 where vendedor.idvendedor = 11516;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 11100 where vinculo.idvendedor = 11516;

/*Ajuste para o lojista 5513637000103 - M G K AUTOMOVEIS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 14594 where vendedor.idvendedor = 11961;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 14594 where vinculo.idvendedor = 11961;

--/*Ajuste para o lojista 5843864000199 - CONZIMAQ BONATTI */
--update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 1080 where vendedor.idvendedor = 7780;
--update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 1080 where vinculo.idvendedor = 7780;

/*Ajuste para o lojista 8106101000153 - MOLON COLCHOES */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 12556 where vendedor.idvendedor = 10430;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 12556 where vinculo.idvendedor = 10430;

/*Ajuste para o lojista 8628959000188 - AUTHENTICA MULTIMARCAS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 11449 where vendedor.idvendedor = 8751;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 11449 where vinculo.idvendedor = 8751;

/*Ajuste para o lojista 9550907000107 - CAR. RO MULTIMARCAS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 12794 where vendedor.idvendedor = 12926;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 12794 where vinculo.idvendedor = 12926;

/*Ajuste para o lojista 10692711000128 - ASA MOTOS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 572 where vendedor.idvendedor = 7072;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 572 where vinculo.idvendedor = 7072;

/*Ajuste para o lojista 11643724000170 - RALLY SC */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 3159 where vendedor.idvendedor = 9356;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 3159 where vinculo.idvendedor = 9356;

--/*Ajuste para o lojista 16926127000176 - TELHAS GUABIRUBA */
--update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 12414 where vendedor.idvendedor = 12716;
--update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 12414 where vinculo.idvendedor = 12716;

/*Ajuste para o lojista 21757376000115 - CENTRAL RODAS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 5641 where vendedor.idvendedor = 8702;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 5641 where vinculo.idvendedor = 8702;

/*Ajuste para o lojista 25075521000139 - INSTALMANN SOLAR */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 7596 where vendedor.idvendedor = 8371;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 7596 where vinculo.idvendedor = 8371;

/*Ajuste para o lojista 21055722000113 - FORTEC SISTEMAS DE SEGURANCA */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 1591 where vendedor.idvendedor = 7166;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 1591 where vinculo.idvendedor = 7166;

/*Ajuste para o lojista 28671573000166 - DM MULTIMARCAS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 12586 where vendedor.idvendedor = 7176;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 12586 where vinculo.idvendedor = 7176;

/*Ajuste para o lojista 33373373000167 - SOLARIS ENGENHARIA */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 13240 where vendedor.idvendedor = 12640;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 13240 where vinculo.idvendedor = 12640;

/*Ajuste para o lojista 34230857000110 - MONTELAR MOVEIS SOB MEDIDA */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 13690 where vendedor.idvendedor = 12452;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 13690 where vinculo.idvendedor = 12452;

/*Ajuste para o lojista 81557126000163 - ASSISTEC SISTEMAS CONSTRUTIVOS */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 5614 where vendedor.idvendedor = 7888;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 5614 where vinculo.idvendedor = 7888;

/*Ajuste para o lojista 85366417000125 - RIO BONITO MATERIAIS DE CONSTRUCAO */
update tbepr_cdc_vendedor vendedor set vendedor.idcooperado_cdc = 6310 where vendedor.idvendedor = 7004;
update tbepr_cdc_usuario_vinculo vinculo set vinculo.idcooperado_cdc = 6310 where vinculo.idvendedor = 7004;

commit;
