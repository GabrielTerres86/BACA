<?php
/* !
 * FONTE        : form_tab052.php
 * CRIAÇÃO      : Leonardo de Freitas Oliveira - GFT
 * DATA CRIAÇÃO : 25/01/2018
 * OBJETIVO     : Formulário de exibição da tela TAB052 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>
<form name="frmTab052" id="frmTab052" class="formulario" style="display:block;">		

    <br style="clear:both" />
	<input type="hidden" id="dsdepart" name="dsdepart" value="<?php echo $glbvars["dsdepart"]; ?>" />
    <input type="hidden" id="idctrlab" name="idctrlaba" value="COOPER" />
	
	
	<fieldset>
		<legend><?php echo utf8ToHtml('Parâmetros') ?></legend>
		
		<label id="tituloO"><?php echo utf8ToHtml('Operacional') ?></label>
		<label id="tituloC"><?php echo utf8ToHtml('Cecred') ?></label>
		
		<br style="clear:both" />
		<table cellspacing="0">
			<tr>
				<!-- vllimite -->
				<td width="300px"><label for="vllimite" class='labelPri'><?php echo utf8ToHtml('Limite Máximo do Contrato:') ?></label></td>
				<td width="170px"><input type="text" id="vllimite" name="vllimite" value="<?php echo $vllimite == 0 ? '' : $vllimite ?>" /></td>
				<td width="170px"><input type="text" id="vllimite_c" name="vllimite_c" value="<?php echo $vllimite_c == 0 ? '' : $vllimite_c ?>" /></td>
			</tr><!-- vl -->
			<tr>
				<!-- vlconsul -->
				<td width="300px"><label for="vlconsul" class='labelPri'><?php echo utf8ToHtml('Consultar CPF/CNPJ (Pagador) Acima de:') ?></label></td>
				<td width="170px"><input type="text" id="vlconsul" name="vlconsul" value="<?php echo $vlconsul == 0 ? '' : $vlconsul ?>" /></td>
				<td width="170px"><input type="text" id="vlconsul_c" name="vlconsul_c" value="<?php echo $vlconsul_c == 0 ? '' : $vlconsul_c ?>" /></td>
			</tr><!-- vl -->


			<tr>
				<!-- vlminsac -->
				<td width="300px"><label for="vlminsac" class='labelPri'><?php echo utf8ToHtml('Valor Mínimo Permitido por Título:') ?></label></td>
				<td width="170px"><input type="text" id="vlminsac" name="vlminsac" value="<?php echo $vlminsac == 0 ? '' : $vlminsac ?>" /></td>
				<td width="170px"><input type="text" id="vlminsac_c" name="vlminsac_c" value="<?php echo $vlminsac_c == 0 ? '' : $vlminsac_c ?>" /></td>
			</tr><!-- vl -->


			<tr class="registerRow">
				<!-- qtremcrt -->
				<td width="300px"><label for="qtremcrt" class='labelPri'><?php echo utf8ToHtml('Qtd. Remessa em Cartório:') ?></label></td>
				<td width="170px"><input type="text" id="qtremcrt" name="qtremcrt" value="<?php echo $qtremcrt == 0 ? '' : $qtremcrt ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtremcrt_c" name="qtremcrt_c" value="<?php echo $qtremcrt_c == 0 ? '' : $qtremcrt_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<tr class="registerRow">
				<!-- qttitprt -->
				<td width="300px"><label for="qttitprt" class='labelPri'><?php echo utf8ToHtml('Qtd. de Títulos Protestados:') ?></label></td>
				<td width="170px"><input type="text" id="qttitprt" name="qttitprt" value="<?php echo $qttitprt == 0 ? '' : $qttitprt ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qttitprt_c" name="qttitprt_c" value="<?php echo $qttitprt_c == 0 ? '' : $qttitprt_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<tr>
				<!-- qtdiavig -->
				<td width="300px"><label for="qtdiavig" class='labelPri'><?php echo utf8ToHtml('Vigência Mínima:') ?></label></td>
				<td width="170px"><input type="text" id="qtdiavig" name="qtdiavig" value="<?php echo $qtdiavig == 0 ? '' : $qtdiavig ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
				<td width="170px"><input type="text" id="qtdiavig_c" name="qtdiavig_c" value="<?php echo $qtdiavig_c == 0 ? '' : $qtdiavig_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
			</tr>


			<tr>
				<!-- qtprzmin -->
				<td width="300px"><label for="qtprzmin" class='labelPri'><?php echo utf8ToHtml('Prazo Mínimo:') ?></label></td>
				<td width="170px"><input type="text" id="qtprzmin" name="qtprzmin" value="<?php echo $qtprzmin == 0 ? '' : $qtprzmin ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
				<td width="170px"><input type="text" id="qtprzmin_c" name="qtprzmin_c" value="<?php echo $qtprzmin_c == 0 ? '' : $qtprzmin_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
			</tr>

			<tr>
				<!-- qtprzmax -->
				<td width="300px"><label for="qtprzmax" class='labelPri'><?php echo utf8ToHtml('Prazo Máximo:') ?></label></td>
				<td width="170px"><input type="text" id="qtprzmax" name="qtprzmax" value="<?php echo $qtprzmax == 0 ? '' : $qtprzmax ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
				<td width="170px"><input type="text" id="qtprzmax_c" name="qtprzmax_c" value="<?php echo $qtprzmax_c == 0 ? '' : $qtprzmax_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
			</tr>

		
			<tr>
				<!-- qtminfil -->
				<td width="300px"><label for="qtminfil" class='labelPri'><?php echo utf8ToHtml('Tempo Mínimo de Filiação:') ?></label></td>
				<td width="170px"><input type="text" id="qtminfil" name="qtminfil" value="<?php echo $qtminfil == 0 ? '' : $qtminfil ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
				<td width="170px"><input type="text" id="qtminfil_c" name="qtminfil_c" value="<?php echo $qtminfil_c == 0 ? '' : $qtminfil_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
			</tr>


			<tr>
				<!-- cardbtit -->
				<td width="300px"><label for="cardbtit" class='labelPri'><?php echo utf8ToHtml('Carência Débito Título Vencido:') ?></label></td>
				<td width="170px"><input type="text" id="cardbtit" name="cardbtit" value="<?php echo $cardbtit == 0 ? '' : $cardbtit ?>" maxlength="3" style="text-align:right;"/>
					<label id="cardbtit-label-compl"><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
				<td width="170px"><input type="text" id="cardbtit_c" name="cardbtit_c" value="<?php echo $cardbtit_c == 0 ? '' : $cardbtit_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
			</tr>

			<tr>
				<!-- nrmespsq -->
				<td width="300px"><label for="nrmespsq" class='labelPri'><?php echo utf8ToHtml('Qtd. de Meses para Pesquisa de Pagador:') ?></label></td>
				<td width="170px"><input type="text" id="nrmespsq" name="nrmespsq" value="<?php echo $nrmespsq == 0 ? '' : $nrmespsq ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="nrmespsq_c" name="nrmespsq_c" value="<?php echo $nrmespsq_c == 0 ? '' : $nrmespsq_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<tr>
				<!-- pctitemi -->
				<td width="300px"><label for="pctitemi" class='labelPri'><?php echo utf8ToHtml('Percentual de Títulos por Pagador:') ?></label></td>
				<td width="170px"><input type="text" id="pctitemi" name="pctitemi" value="<?php echo $pctitemi == 0 ? '' : $pctitemi ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
				<td width="170px"><input type="text" id="pctitemi_c" name="pctitemi_c" value="<?php echo $pctitemi_c == 0 ? '' : $pctitemi_c ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
			</tr>

			<tr>
				<!-- pctolera -->
				<td width="300px"><label for="pctolera" class='labelPri'><?php echo utf8ToHtml('Tolerância para Limite Excedido:') ?></label></td>
				<td width="170px"><input type="text" id="pctolera" name="pctolera" value="<?php echo $pctolera == 0 ? '' : $pctolera ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
				<td width="170px"><input type="text" id="pctolera_c" name="pctolera_c" value="<?php echo $pctolera_c == 0 ? '' : $pctolera_c ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
			</tr>

			<tr>
				<!-- pcdmulta -->
				<td width="300px"><label for="pcdmulta" class='labelPri'><?php echo utf8ToHtml('Percentual de Multa:') ?></label></td>
				<td width="170px"><input type="text" id="pcdmulta" name="pcdmulta" value="<?php echo $pcdmulta == 0 ? '' : $pcdmulta ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
				<td width="170px"><input type="text" id="pcdmulta_c" name="pcdmulta_c" value="<?php echo $pcdmulta_c == 0 ? '' : $pcdmulta_c ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
			</tr>

			<tr>
				<!-- pcnaopag -->
				<td width="300px"><label for="pcnaopag" class='labelPri'><?php echo utf8ToHtml('Perc. de Títulos Não Pagos Beneficiário:') ?></label></td>
				<td width="170px"><input type="text" id="pcnaopag" name="pcnaopag" value="<?php echo $pcnaopag == 0 ? '' : $pcnaopag ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
				<td width="170px"><input type="text" id="pcnaopag_c" name="pcnaopag_c" value="<?php echo $pcnaopag_c == 0 ? '' : $pcnaopag_c ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label></td>
			</tr>

			<tr>
				<!-- qtnaopag -->
				<td width="300px"><label for="qtnaopag" class='labelPri'><?php echo utf8ToHtml('Qtd. de Títulos Não Pagos Pagador:') ?></label></td>
				<td width="170px"><input type="text" id="qtnaopag" name="qtnaopag" value="<?php echo $qtnaopag == 0 ? '' : $qtnaopag ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtnaopag_c" name="qtnaopag_c" value="<?php echo $qtnaopag_c == 0 ? '' : $qtnaopag_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<tr class="registerRow">
				<!-- qtprotes -->
				<td width="300px"><label for="qtprotes" class='labelPri'><?php echo utf8ToHtml('Qtd. de Títulos Protestados-Cooperado:') ?></label></td>
				<td width="170px"><input type="text" id="qtprotes" name="qtprotes" value="<?php echo $qtprotes == 0 ? '' : $qtprotes ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtprotes_c" name="qtprotes_c" value="<?php echo $qtprotes_c == 0 ? '' : $qtprotes_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<!--1 
				Texto: Valor Máximo Dispensa Assinatura Internet Banking
				Nome: vlmxassi (tab019)
			-->
			<tr>
				<!-- vlmxassi -->
				<td width="300px"><label for="vlmxassi" class='labelPri'><?php echo utf8ToHtml('Valor Máximo Dispensa Assinatura Internet Banking:') ?></label></td>
				<td width="170px"><input type="text" id="vlmxassi" name="vlmxassi" value="<?php echo $vlmxassi == 0 ? '' : $vlmxassi ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="vlmxassi_c" name="vlmxassi_c" value="<?php echo $vlmxassi_c == 0 ? '' : $vlmxassi_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>



			<!-- 16
				Texto: Qtd. Máxima de Títulos por Borderô
				Nome: **qtmxtbib
				ou
				Texto: Quantidade máxima de títulos por borderô 
				Nome: **qtmxtbay
			-->
			<tr>
				<!-- qtmxtbib -->
				<td width="300px"><label for="qtmxtbib" class='labelPri'><?php echo utf8ToHtml('Qtd. máxima de títulos por borderô:') ?></label></td>
				<td width="170px"><input type="text" id="qtmxtbib" name="qtmxtbib" value="<?php echo $qtmxtbib == 0 ? '' : $qtmxtbib ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtmxtbib_c" name="qtmxtbib_c" value="<?php echo $qtmxtbib_c == 0 ? '' : $qtmxtbib_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>


			<!--2 
				Texto: Verificar Relacionamento Emitente (Cônjugue/Sócio): 
				Nome: flemipar (tab019)
				Tipo: SIM/ NÃO
				visibilidade: Pessoa Fisica
			
				Texto: É sócio do cooperado ?
				Tipo: SIM/ NÃO
				visibilidade: Pessoa Juridica
			-->
			<tr>
				<!-- flemipar -->
				<td width="300px" class="personForm"><label for="flemipar" class='labelPri'><?php echo utf8ToHtml('Verificar se Emitente é Conjugue do Cooperado:') ?></label></td>
				<td width="300px" class="companyForm"><label for="flemipar" class='labelPri'><?php echo utf8ToHtml('Verificar Relacionamento Emitente (Cônjugue/Sócio):') ?></label></td>
				<td width="170px">
					<select id="flemipar" name="flemipar">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
				<td width="170px">
					<select id="flemipar_c" name="flemipar_c">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
			</tr>


			

			<!--4 
				Texto: Verificar Cooperado Possui Prejuízo na Cooperativa 
					Alternativa: Verificar Prejuízo do Emitente ? (tab019)
				Nome: flpjzemi (tab019)
				tipo: SIM/ NÃO
			-->
			<tr>
				<!-- flpjzemi -->
				<td width="300px"><label for="flpjzemi" class='labelPri'><?php echo utf8ToHtml('Verificar Cooperado Possui Prejuízo na Cooperativa:') ?></label></td>
				<td width="170px">
					<select id="flpjzemi" name="flpjzemi">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
				<td width="170px">
					<select id="flpjzemi_c" name="flpjzemi_c">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
			</tr>

			<!--5 
				Texto: Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador
				Nome **flpdctcp
				tipo: SIM/ NÃO 
			-->
			<tr>
				<!-- flpdctcp -->
				<td width="300px"><label for="flpdctcp" class='labelPri'><?php echo utf8ToHtml('Verificar Cooperado Possui Titulos Descontatos na Conta do Pagador:') ?></label></td>
				<td width="170px">
					<select id="flpdctcp" name="flpdctcp">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
				<td width="170px">
					<select id="flpdctcp_c" name="flpdctcp_c">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
			</tr>

			<!--6 
				Texto: Mínimo de Liquidez do Cedente x Pagador (Qtd. de Títulos) 
				Nome: **qttliqcp
			-->
			<tr>
				<!-- qttliqcp -->
				<td width="300px"><label for="qttliqcp" class='labelPri'><?php echo utf8ToHtml('Mínimo de Liquidez do Cedente x Pagador (Qtd. de Títulos):') ?></label></td>
				<td width="170px"><input type="text" id="qttliqcp" name="qttliqcp" value="<?php echo $qttliqcp == 0 ? '' : $qttliqcp ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qttliqcp_c" name="qttliqcp_c" value="<?php echo $qttliqcp_c == 0 ? '' : $qttliqcp_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<!--7 
				Texto: Mínimo de Liquidez do Cedente x Pagador (Valor dos Títulos) 
				Nome: **vltliqcp
			-->
			<tr>
				<!-- vltliqcp -->
				<td width="300px"><label for="vltliqcp" class='labelPri'><?php echo utf8ToHtml('Mínimo de Liquidez do Cedente x Pagador (Valor dos Títulos):') ?></label></td>
				<td width="170px"><input type="text" id="vltliqcp" name="vltliqcp" value="<?php echo $vltliqcp == 0 ? '' : $vltliqcp ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="vltliqcp_c" name="vltliqcp_c" value="<?php echo $vltliqcp_c == 0 ? '' : $vltliqcp_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>



			<!--8 
				Texto: Mínimo de Liquidez de Titulos Geral do Cedente (Qtd de Títulos) 
				Nome: **qtmintgc
			-->
			<tr>
				<!-- qtmintgc -->
				<td width="300px"><label for="qtmintgc" class='labelPri'><?php echo utf8ToHtml('Mínimo de Liquidez de Títulos Geral do Cedente (Qtd de Títulos):') ?></label></td>
				<td width="170px"><input type="text" id="qtmintgc" name="qtmintgc" value="<?php echo $qtmintgc == 0 ? '' : $qtmintgc ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtmintgc_c" name="qtmintgc_c" value="<?php echo $qtmintgc_c == 0 ? '' : $qtmintgc_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<!--9 
				Texto: Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Títulos)
				Nome: **vlmintgc
			 -->
			<tr>
				<!-- vlmintgc -->
				<td width="300px"><label for="vlmintgc" class='labelPri'><?php echo utf8ToHtml('Mínimo de Liquidez de Titulos Geral do Cedente (Valor dos Títulos):') ?></label></td>
				<td width="170px"><input type="text" id="vlmintgc" name="vlmintgc" value="<?php echo $vlmintgc == 0 ? '' : $vlmintgc ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="vlmintgc_c" name="vlmintgc_c" value="<?php echo $vlmintgc_c == 0 ? '' : $vlmintgc_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>


			<!--10 
				Texto: Qtd. Mínima de Títulos Descontados para Cálculo da Liquidez
				Nome: qtmitdcl
				-->
			<tr>
				<!-- qtmitdcl -->
				<td width="300px"><label for="qtmitdcl" class='labelPri'><?php echo utf8ToHtml('Qtd. Mínima de Títulos Descontados para Cálculo da Liquidez:') ?></label></td>
				<td width="170px"><input type="text" id="qtmitdcl" name="qtmitdcl" value="<?php echo $qtmitdcl == 0 ? '' : $qtmitdcl ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtmitdcl_c" name="qtmitdcl_c" value="<?php echo $qtmitdcl_c == 0 ? '' : $qtmitdcl_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			
			<!--11
				Texto: Valor Mínimo para Cálculo de Liquidez
				Nome: vlmintcl
				-->
			<tr>
				<!-- vlmintcl -->
				<td width="300px"><label for="vlmintcl" class='labelPri'><?php echo utf8ToHtml('Valor Mínimo para Cálculo de Liquidez:') ?></label></td>
				<td width="170px"><input type="text" id="vlmintcl" name="vlmintcl" value="<?php echo $vlmintcl == 0 ? '' : $vlmintcl ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="vlmintcl_c" name="vlmintcl_c" value="<?php echo $vlmintcl == 0 ? '' : $vlmintcl_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>


			<!--12 
				Texto: Período em meses para realizar o cálculo de liquidez 
					Alternativa: Qtd. Meses Cálculo Percentual de Liquidez ?(tab019)
				Nome: qtmesliq
				-->
			<tr>
				<!-- qtmesliq -->
				<td width="300px"><label for="qtmesliq" class='labelPri'><?php echo utf8ToHtml('Período em meses para realizar o cálculo de liquidez:') ?></label></td>
				<td width="170px"><input type="text" id="qtmesliq" name="qtmesliq" value="<?php echo $qtmesliq == 0 ? '' : $qtmesliq ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtmesliq_c" name="qtmesliq_c" value="<?php echo $qtmesliq_c == 0 ? '' : $qtmesliq_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>


			<!--11 
				Texto: Valor máximo permitido por ramo de atividade -> Verificar o valor máximo permitido por ramo de atividade (Cód. CNAE)
				Nome: **vlmxprat
				Tipo:SIM/ NÃO -->
			<tr>
				<!-- flpdctcp -->
				<td width="300px"><label for="vlmxprat" class='labelPri'><?php echo utf8ToHtml('Verificar o valor máximo permitido por ramo de atividade (Cód. CNAE):') ?></label></td>
				<td width="170px">
					<select id="vlmxprat" name="vlmxprat">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
				<td width="170px">
					<select id="vlmxprat_c" name="vlmxprat_c">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
			</tr>



			<!--12  (ordenado)
				Texto: Concentração máxima de títulos por pagador -> Percentual de Títulos por pagador
				Nome: **width="500px"
				 -->
			<tr>
				
				<td width="300px"><label for="pcmxctip" class='labelPri'><?php echo utf8ToHtml('Concentração máxima de títulos por pagador:') ?></label></td>
				<td width="170px"><input type="text" id="pcmxctip" name="pcmxctip" value="<?php echo $pcmxctip == 0 ? '' : $pcmxctip ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="pcmxctip_c" name="pcmxctip_c" value="<?php echo $pcmxctip_c == 0 ? '' : $pcmxctip_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>


			<!--14 
				Texto: Quantidade máxima de dias para envio para Esteira
				Nome: **qtmxdene
			 -->
			 <tr>
				<!-- qtmxdene -->
				<td width="300px"><label for="qtmxdene" class='labelPri'><?php echo utf8ToHtml('Quantidade máxima de dias para envio para Esteira:') ?></label></td>
				<td width="170px"><input type="text" id="qtmxdene" name="qtmxdene" value="<?php echo $qtmxdene == 0 ? '' : $qtmxdene ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtmxdene_c" name="qtmxdene_c" value="<?php echo $qtmxdene_c == 0 ? '' : $qtmxdene_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

			<!--15 
				Texto: Dias para expirar borderô 
				Nome: **qtdiexbo
			-->
			<tr>
				<!-- qtdiexbo -->
				<td width="300px"><label for="qtdiexbo" class='labelPri'><?php echo utf8ToHtml('Dias para expirar borderô:') ?></label></td>
				<td width="170px"><input type="text" id="qtdiexbo" name="qtdiexbo" value="<?php echo $qtdiexbo == 0 ? '' : $qtdiexbo ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtdiexbo_c" name="qtdiexbo_c" value="<?php echo $qtdiexbo_c == 0 ? '' : $qtdiexbo_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>


			<tr>
				<!-- qtmesliq -->
				<td width="300px"><label for="pctitpag" class='labelPri'><?php echo utf8ToHtml('Percentual de Títulos por pagador:') ?></label></td>
				<td width="170px"><input type="text" id="pctitpag" name="pctitpag" value="<?php echo $pctitpag == 0 ? '' : $pctitpag ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="pctitpag_c" name="pctitpag_c" value="<?php echo $pctitpag_c == 0 ? '' : $pctitpag_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

		</table>
    </fieldset>
    
</form>

