<?php
/* !
 * FONTE        : form_tab019.php
 * CRIAÇÃO      : Daniel Zimmermann/Odirlei Busana - AMcom
 * DATA CRIAÇÃO : 06/04/2016
 * OBJETIVO     : Formulário de exibição da tela TAB019 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
?>
<form name="frmTab019" id="frmTab019" class="formulario" style="display:block;">		

    <br style="clear:both" />
	<input type="hidden" id="dsdepart" name="dsdepart" value="<?php echo $glbvars["dsdepart"]; ?>" />
    <input type="hidden" id="idctrlab" name="idctrlaba" value="COOPER" />
	
	
	<fieldset>
		<legend><?php echo utf8ToHtml('Parâmetros') ?></legend>
		
		<label id="tituloO"><?php echo utf8ToHtml('Operacional') ?></label>
		<label id="tituloC"><?php echo utf8ToHtml('Ailos') ?></label>
		
		<br style="clear:both" />
		<table cellspacing="0">
			<tr>
				<td width="300px"><label for="vllimite" class='labelPri'><?php echo utf8ToHtml('Limite M&aacute;ximo do Contrato:') ?></label></td>
				<td width="170px"><input type="text" id="vllimite" name="vllimite" value="<?php echo $vllimite == 0 ? '' : $vllimite ?>" /></td>
				<td width="170px"><input type="text" id="vllimite_c" name="vllimite_c" value="<?php echo $vllimite_c == 0 ? '' : $vllimite_c ?>" /></td>
			</tr>
			<tr>
				<td width="300px"><label for="vlconchq" class='labelPri'><?php echo utf8ToHtml('Consultar cheques acima de:') ?></label></td>
				<td width="170px"><input type="text" id="vlconchq" name="vlconchq" value="<?php echo $vlconchq == 0 ? '' : $vlconchq ?>" /></td>
				<td width="170px"><input type="text" id="vlconchq_c" name="vlconchq_c" value="<?php echo $vlconchq_c == 0 ? '' : $vlconchq_c ?>" /></td>
			</tr>
			<tr>
				<td width="300px"><label for="vlmaxemi" class='labelPri'><?php echo utf8ToHtml('Valor M&aacute;ximo Permitido por Emitente:') ?></label></td>
				<td width="170px"><input type="text" id="vlmaxemi" name="vlmaxemi" value="<?php echo $vlmaxemi == 0 ? '' : $vlmaxemi ?>" /></td>
				<td width="170px"><input type="text" id="vlmaxemi_c" name="vlmaxemi_c" value="<?php echo $vlmaxemi_c == 0 ? '' : $vlmaxemi_c ?>" /></td>
			</tr>
			<tr>
				<td width="300px"><label for="qtdiavig" class='labelPri'><?php echo utf8ToHtml('Vigencia M&iacute;nima:') ?></label></td>
				<td width="170px">
					<input type="text" id="qtdiavig" name="qtdiavig" value="<?php echo $qtdiavig == 0 ? '' : $qtdiavig ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="qtdiavig_c" name="qtdiavig_c" value="<?php echo $qtdiavig_c == 0 ? '' : $qtdiavig_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="qtprzmin" class='labelPri'><?php echo utf8ToHtml('Prazo M&iacute;nimo:') ?></label></td>
				<td width="170px">
					<input type="text" id="qtprzmin" name="qtprzmin" value="<?php echo $qtprzmin == 0 ? '' : $qtprzmin ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="qtprzmin_c" name="qtprzmin_c" value="<?php echo $qtprzmin_c == 0 ? '' : $qtprzmin_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="qtprzmax" class='labelPri'><?php echo utf8ToHtml('Prazo M&aacute;ximo:') ?></label></td>
				<td width="170px">
					<input type="text" id="qtprzmax" name="qtprzmax" value="<?php echo $qtprzmax == 0 ? '' : $qtprzmax ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="qtprzmax_c" name="qtprzmax_c" value="<?php echo $qtprzmax_c == 0 ? '' : $qtprzmax_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="qtdiasoc" class='labelPri'><?php echo utf8ToHtml('Tempo M&iacute;nimo de Filiação:') ?></label></td>
				<td width="170px">
					<input type="text" id="qtdiasoc" name="qtdiasoc" value="<?php echo $qtdiasoc == 0 ? '' : $qtdiasoc ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="qtdiasoc_c" name="qtdiasoc_c" value="<?php echo $qtdiasoc_c == 0 ? '' : $qtdiasoc_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label> 
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="pcchqemi" class='labelPri'><?php echo utf8ToHtml('Percentual de Cheques por Emitente:') ?></label></td>
				<td width="170px">
					<input type="text" id="pcchqemi" name="pcchqemi" value="<?php echo $pcchqemi == 0 ? '' : $pcchqemi ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="pcchqemi_c" name="pcchqemi_c" value="<?php echo $pcchqemi_c == 0 ? '' : $pcchqemi_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>         	
				 </td>
			</tr>
			<tr>
				<td width="300px"><label for="qtdevchq" class='labelPri'><?php echo utf8ToHtml('Qtd. Cheques Devolvidos por Emitente:') ?></label></td>
				<td width="170px"><input type="text" id="qtdevchq" name="qtdevchq" value="<?php echo $qtdevchq == 0 ? '' : $qtdevchq ?>" maxlength="3" style="text-align:right;"/>	</td>
				<td width="170px"><input type="text" id="qtdevchq_c" name="qtdevchq_c" value="<?php echo $qtdevchq_c == 0 ? '' : $qtdevchq_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>
			<tr>
				<td width="300px"><label for="pcchqloc" class='labelPri'><?php echo utf8ToHtml('Percentual de Cheques da COMPE Local:') ?></label></td>
				<td width="170px">
					<input type="text" id="pcchqloc" name="pcchqloc" value="<?php echo $pcchqloc == 0 ? '' : $pcchqloc ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="pcchqloc_c" name="pcchqloc_c" value="<?php echo $pcchqloc_c == 0 ? '' : $pcchqloc_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="pctollim" class='labelPri'><?php echo utf8ToHtml('Toler&acirc;ncia para Limite Excedido:') ?></label></td>
				<td width="170px">
					<input type="text" id="pctollim" name="pctollim" value="<?php echo $pctollim == 0 ? '' : $pctollim ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="pctollim_c" name="pctollim_c" value="<?php echo $pctollim_c == 0 ? '' : $pctollim_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="txdmulta" class='labelPri'><?php echo utf8ToHtml('Percentual de Multa:') ?></label></td>
				<td width="170px">
					<input type="text" id="txdmulta" name="txdmulta" value="<?php echo $txdmulta == 0 ? '' : $txdmulta ?>" />	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="txdmulta_c" name="txdmulta_c" value="<?php echo $txdmulta_c == 0 ? '' : $txdmulta_c ?>" />
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="qtdiasli" class='labelPri'><?php echo utf8ToHtml('Dias/Hora Limite para Resgate:') ?></label></td>
				<td width="170px">
					<input type="text" id="qtdiasli" name="qtdiasli" value="<?php echo $qtdiasli == 0 ? '' : $qtdiasli ?>" maxlength="2" style="text-align:right;" />	
					<label><?php echo utf8ToHtml('&nbsp;dia(s)&nbsp;/') ?></label>
					<input type="text" id="horalimt" name="horalimt" value="<?php echo $horalimt == 0 ? '' : $horalimt ?>" maxlength="2" />
					<label><?php echo utf8ToHtml('&nbsp;:') ?></label>  
					<input type="text" id="minlimit" name="minlimit" value="<?php echo $minlimit == 0 ? '' : $minlimit ?>" maxlength="2" />
				</td>
				<td width="170px">
					<input type="text" id="qtdiasli_c" name="qtdiasli_c" value="<?php echo $qtdiasli_c == 0 ? '' : $qtdiasli_c ?>" maxlength="2" />	
					<label><?php echo utf8ToHtml('&nbsp;dia(s)&nbsp;/') ?></label>
					<input type="text" id="horalimt_c" name="horalimt_c" value="<?php echo $horalimt_c == 0 ? '' : $horalimt_c ?>" maxlength="2" />
					<label><?php echo utf8ToHtml('&nbsp;:') ?></label>  
					<input type="text" id="minlimit_c" name="minlimit_c" value="<?php echo $minlimit_c == 0 ? '' : $minlimit_c ?>" maxlength="2" />
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="flemipar" id='flemiparL' class='labelPri'><?php echo utf8ToHtml('Verificar se Emitente é Conjugue do Cooperado:') ?></label></td>
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
			<tr>
				<td width="300px"><label for="przmxcmp" class='labelPri'><?php echo utf8ToHtml('Prazo Máximo de Compensação:') ?></label></td>
				<td width="170px">
					<input type="text" id="przmxcmp" name="przmxcmp" value="<?php echo $qtdiavig == 0 ? '' : $qtdiavig ?>" maxlength="4" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="przmxcmp_c" name="przmxcmp_c" value="<?php echo $qtdiavig_c == 0 ? '' : $qtdiavig_c ?>" maxlength="4" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;dia(s)') ?></label>
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="flpjzemi" class='labelPri' > <?php echo utf8ToHtml('Verificar Prejuízo do Emitente:') ?></label></td>
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
			<tr>
				<td width="300px"><label for="flemisol" class='labelPri'><?php echo utf8ToHtml('Verificar Emitente x Conta Solicitante:') ?></label></td>
				<td width="170px">
					<select id="flemisol" name="flemisol">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select>
				</td>
				<td width="170px">
					<select id="flemisol_c" name="flemisol_c">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select> 
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="prcliqui" class='labelPri'><?php echo utf8ToHtml('Percentual de Liquidez:') ?></label></td>
				<td width="170px">
					<input type="text" id="prcliqui" name="prcliqui" value="<?php echo $pcchqloc == 0 ? '' : $pcchqloc ?>" maxlength="3" style="text-align:right;"/>	
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>
				</td>
				<td width="170px">
					<input type="text" id="prcliqui_c" name="prcliqui_c" value="<?php echo $pcchqloc_c == 0 ? '' : $pcchqloc_c ?>" maxlength="3" style="text-align:right;"/>
					<label><?php echo utf8ToHtml('&nbsp;%') ?></label>   
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="qtmesliq" class='labelPri'><?php echo utf8ToHtml('Qtd. Meses Cálculo Percentual de Liquidez:') ?></label></td>
				<td width="170px"><input type="text" id="qtmesliq" name="qtmesliq" value="<?php echo $qtdevchq == 0 ? '' : $qtdevchq ?>" maxlength="3" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtmesliq_c" name="qtmesliq_c" value="<?php echo $qtdevchq_c == 0 ? '' : $qtdevchq_c ?>" maxlength="3" style="text-align:right;"/></td>
			</tr>
			<tr>
				<td width="300px"><label for="vlrenlim" id="vlrenlimL" class='labelPri'>Renda x Limite Desconto</label></td>
				<td width="170px"><input type="text" id="vlrenlim" name="vlrenlim" value="<?php echo $qtdevchq == 0 ? '' : $qtdevchq ?>" maxlength="4" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="vlrenlim_c" name="vlrenlim_c" value="<?php echo $qtdevchq_c == 0 ? '' : $qtdevchq_c ?>" maxlength="4" style="text-align:right;"/></td>
			</tr>
			<tr>
				<td width="300px"><label for="qtmxrede" class='labelPri'><?php echo utf8ToHtml('Qtd. Máxima Redesconto:') ?></label></td>
				<td width="170px"><input type="text" id="qtmxrede" name="qtmxrede" value="<?php echo $qtdevchq == 0 ? '' : $qtdevchq ?>" maxlength="2" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="qtmxrede_c" name="qtmxrede_c" value="<?php echo $qtdevchq_c == 0 ? '' : $qtdevchq_c ?>" maxlength="2" style="text-align:right;"/></td>
			</tr>
			<tr>
				<td width="300px"><label for="fldchqdv" class='labelPri'><?php echo utf8ToHtml('Permitir Desconto Cheque Devolvido:') ?></label></td>
				<td width="170px">
					<select id="fldchqdv" name="fldchqdv">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select> 
				</td>
				<td width="170px">
					<select id="fldchqdv_c" name="fldchqdv_c">
					  <option value=0> <?php echo utf8ToHtml('Não') ?> </option>
					  <option value=1> <?php echo utf8ToHtml('Sim') ?> </option>
					</select> 
				</td>
			</tr>
			<tr>
				<td width="300px"><label for="vlmxassi" class='labelPri'><?php echo utf8ToHtml('Valor Máximo Dispensa Assinatura:') ?></label></td>
				<td width="170px"><input type="text" id="vlmxassi" name="vlmxassi" value="<?php echo $vlmxassi == 0 ? '' : $vlmxassi ?>" style="text-align:right;"/></td>
				<td width="170px"><input type="text" id="vlmxassi_c" name="vlmxassi_c" value="<?php echo $vlmxassi_c == 0 ? '' : $vlmxassi_c ?>" style="text-align:right;"/></td>
			</tr>
		</table>
    </fieldset>
    
</form>

