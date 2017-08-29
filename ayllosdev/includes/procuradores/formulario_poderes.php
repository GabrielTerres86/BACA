<?php
/*!
 * FONTE        : fomulario_poderes.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : 04/07/2013 
 * OBJETIVO     : Exibe dados referente aos poderes de Representantes/Procuradores
 *
 * ALTERACOES   : 25/09/2013 - Mudança de layout referente ao tipo de poder (Jean Michel)
 *
 *                03/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *
 *				  22/08/2017 - Correcao no uso de indices invalidos. (SD 732024 - Carlos Tanholi)	
 *
 */
 
?>

<div class="divRegistros">
		<table>
			<thead>
				<tr>
					<th style="font-size:11px;">Poder</th>
					<th style="font-size:11px;">Isolado</th>
					<th style="font-size:11px;">Em Conjunto</th>
				</tr>		
			</thead>
			<tbody>
			<?php
				
				foreach($registros as $poderes) {
					if(getByTagName($poderes->tags,'cddpoder') == 10 && ($inpessoa == 1 || $idastcjt == 0)) {
						continue;
					}
			?>
				<tr>
					<td style="font-size:11px;">
						<input type="hidden" name="hdnCodPoder" id="hdnCodPoder" value="<?php echo getByTagName($poderes->tags,'cddpoder'); ?>">
						<? echo $arrPoderes[getByTagName($poderes->tags,'cddpoder')-1]; ?>
					</td>					
					<?php
						if(getByTagName($poderes->tags,'cddpoder') != 9){
					?>
					<td>
						<input type="radio" name="radPoder<?php echo(getByTagName($poderes->tags,'cddpoder'));?>" id="radPoderI<?php echo(getByTagName($poderes->tags,'cddpoder'));?>" value="iso" onClick="selecionaPoder('radPoderI<?php echo(getByTagName($poderes->tags,'cddpoder'));?>');"  
							<?php echo getByTagName($poderes->tags,'flgisola') == 'yes' ? "checked=checked" : ""; ?>
							<?php echo getByTagName($poderes->tags,'cddpoder') == 10 ? "disabled=disabled" : ""; ?>
						/>
					</td>
					<td>
						<input type="radio" name="radPoder<?php echo(getByTagName($poderes->tags,'cddpoder'));?>" id="radPoderC<?php echo(getByTagName($poderes->tags,'cddpoder'));?>" value="con" onClick="selecionaPoder('radPoderC<?php echo(getByTagName($poderes->tags,'cddpoder'));?>');"
							<?php echo getByTagName($poderes->tags,'flgconju') == 'yes' ? "checked=checked" : ""; ?>
						/>						
					</td>
					<?php		
						}else{
					?>
						<?php $dsdoutpod = explode("#",getByTagName($poderes->tags,'dsoutpod')); ?>
						<td></td>
						<td></td>
					<?php	
						}
					?>
				</tr>
			<?
				}
			?>	
			</tbody>
		</table>
		<div style="width:100%; text-align:right;">
			<input type="text" id="dsoutpod1" name="dsoutpod1" value="<?php echo (isset($dsdoutpod[0]) ) ? $dsdoutpod[0] : ''; ?>" style="border:1px solid gray; width:340px;" maxlength="48" /><br>
			<input type="text" id="dsoutpod2" name="dsoutpod2" value="<?php echo (isset($dsdoutpod[1]) ) ? $dsdoutpod[1] : ''; ?>" style="border:1px solid gray; width:340px;" maxlength="48" /><br>
			<input type="text" id="dsoutpod3" name="dsoutpod3" value="<?php echo (isset($dsdoutpod[2]) ) ? $dsdoutpod[2] : ''; ?>" style="border:1px solid gray; width:340px;" maxlength="48" /><br>
			<input type="text" id="dsoutpod4" name="dsoutpod4" value="<?php echo (isset($dsdoutpod[3]) ) ? $dsdoutpod[3] : ''; ?>" style="border:1px solid gray; width:340px;" maxlength="48" /><br>
			<input type="text" id="dsoutpod5" name="dsoutpod5" value="<?php echo (isset($dsdoutpod[4]) ) ? $dsdoutpod[4] : ''; ?>" style="border:1px solid gray; width:340px;" maxlength="48" />
		</div>
	<br>
	<div id="divBotoes">
		<?
			if($nmrotina == "Representante/Procurador"){?>
				<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif"    onClick="controlaOperacaoProc('CT');" />
		<?php
			}else{
		?>
				<input type="image" id="btVoltar" src="<? echo $UrlImagens; ?>botoes/voltar.gif" onClick="acessaOpcaoAbaDados(6,2,'@');return false;" />
		<?php
			}
		?>
		<input type="image" id="btSalvar" src="<? echo $UrlImagens; ?>botoes/concluir.gif"  onClick="controlaOperacaoPoderes('SP');" />
	</div>
	<script type="text/javascript">	
		controlaLayoutPoder();		
	</script>
</div>