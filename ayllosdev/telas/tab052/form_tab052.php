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


			<tr>
				<!-- vlmaxsac -->
				<td width="300px"><label for="vlmaxsac" class='labelPri'><?php echo utf8ToHtml('Valor Máximo Permitido por Título:') ?></label></td>
				<td width="170px"><input type="text" id="vlmaxsac" name="vlmaxsac" value="<?php echo $vlmaxsac == 0 ? '' : $vlmaxsac ?>" /></td>
				<td width="170px"><input type="text" id="vlmaxsac_c" name="vlmaxsac_c" value="<?php echo $vlmaxsac_c == 0 ? '' : $vlmaxsac_c ?>" /></td>
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
				<!-- qtrenova -->
				<td width="300px"><label for="qtrenova" class='labelPri'><?php echo utf8ToHtml('Qtd. de Renovações:') ?></label></td>
				<td width="170px"><input type="text" id="qtrenova" name="qtrenova" value="<?php echo $qtrenova == 0 ? '' : $qtrenova ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtrenova_c" name="qtrenova_c" value="<?php echo $qtrenova_c == 0 ? '' : $qtrenova_c ?>" maxlength="3" style="text-align:right;"/></td>
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
				<!-- cardbtit -->
				<td width="300px"><label for="cardbtit" class='labelPri'><?php echo utf8ToHtml('Carência Débito Título Vencido:') ?></label></td>
				<td width="170px"><input type="text" id="cardbtit" name="cardbtit" value="<?php echo $cardbtit == 0 ? '' : $cardbtit ?>" maxlength="3" style="text-align:right;"/>
					<label id="cardbtit-label-compl"><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label></td>
				<td width="170px"><input type="text" id="cardbtit_c" name="cardbtit_c" value="<?php echo $cardbtit_c == 0 ? '' : $cardbtit_c ?>" maxlength="3" style="text-align:right;"/>
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
				<!-- nrmespsq -->
				<td width="300px"><label for="nrmespsq" class='labelPri'><?php echo utf8ToHtml('Nr. de Meses para Pesquisa de Pagador:') ?></label></td>
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
				<td width="300px"><label for="qtprotes" class='labelPri'><?php echo utf8ToHtml('Qtd. de Títulos Protestados (Cooperado):') ?></label></td>
				<td width="170px"><input type="text" id="qtprotes" name="qtprotes" value="<?php echo $qtprotes == 0 ? '' : $qtprotes ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtprotes_c" name="qtprotes_c" value="<?php echo $qtprotes_c == 0 ? '' : $qtprotes_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>

		</table>
    </fieldset>
    
</form>

