<? 
/*!
 * FONTE       : tabela_proposta.php
 * CRIAÇÃO     : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO: 21/07/2014
 * OBJETIVO    : Tabela que apresenta as informacoes da proposta
 *
 * --------------
 * ALTERAÇÕES   : 13/10/2015 - Projeto Reformulacao Cadastral (Tiago Castro - RKAM). 
 				  29/03/2018 - Ajustes para inclusão de novo produto. (Alex Sandro - GFT)
 * --------------
 */
 ?>

<form class="formulario">
	<fieldset id="filtro_proposta">
		<table>
			<tr>
				<td><label style="float: right;" for="inprodut">Produto: </label></td>
				<td>
					<select class='campo' id='inprodut' name='inprodut' style="width:160px;">
						<option value='0' selected > Todos  </option>
						<option value='1' <? if ($inprodut == '1') { ?> selected <? } ?> > Empr&eacute;stimo          </option>
						<option value='2' <? if ($inprodut == '2') { ?> selected <? } ?> > Financiamento	            </option>
						<option value='3' <? if ($inprodut == '3') { ?> selected <? } ?> > Cheque Especial            </option>
						<option value='4' <? if ($inprodut == '4') { ?> selected <? } ?> > Desconto de cheque         </option>
						<option value='5' <? if ($inprodut == '5') { ?> selected <? } ?> > Desconto de t&iacute;tulos </option>
						<option value='6' <? if ($inprodut == '6') { ?> selected <? } ?> > Cadastro Conta </option>
					</select>
				</td>
				<td>
					<a href="#" class="botao" id="btOK" name="btnOK" onClick ="cddopcao = 'C'; realizaOperacao();" style = "text-align:right;">OK</a>
				</td>	
			</tr>	
		</table>
	</fieldset>
	<fieldset id='tabConteudo'>	
		<legend><? echo utf8ToHtml('Reaproveitamento de Consultas'); ?></legend>
		<div class="divRegistros">
			<table>
				<thead>
					<tr><th style="width:75px;"> <?php echo utf8ToHtml('Produto'); ?></th>
						<th style="width:75px;"> <?php echo utf8ToHtml('Tipo pessoa'); ?> </th>
						<th style="width:75px;"> <?php echo utf8ToHtml('Valor inicial'); ?> </th>
						<th style="width:70px;"> <?php echo utf8ToHtml('Modalidade'); ?> </th>
					</tr>			
				</thead>
				<tbody>
					<? foreach( $registros as $proposta ) {
						$inprodut =  getByTagName($proposta->tags,'inprodut');
						
						switch ($inprodut) {
							case 1: { $dsprodut = "Empr&eacute;stimo";         break; }
							case 2: { $dsprodut = "Financiamento";      break; } 
							case 3: { $dsprodut = "Cheque Especial";    break; }
							case 4: { $dsprodut = "Des. de Cheque"; break; }
							case 5: { $dsprodut = "Des. de T&iacute;tulos"; break; }
							case 6: { $dsprodut = "Cadastro Conta"; break; }
							case 7: { $dsprodut = "Border&ocirc; de T&iacute;tulos"; break; } 
						}
						
						$inpessoa =  getByTagName($proposta->tags,'inpessoa');
						$dspessoa = ($inpessoa == "1") ? "F&iacute;sica" : "Jur&iacute;dica";
						$vlinicio = formataMoeda(getByTagName($proposta->tags,'vlinicio'));
						$cdbircon = getByTagName($proposta->tags,'cdbircon');
						$dsbircon = getByTagName($proposta->tags,'dsbircon');
						$cdmodbir = getByTagName($proposta->tags,'cdmodbir');
						$dsmodbir = getByTagName($proposta->tags,'dsmodbir');
					?>
						<tr onclick="armazenarParametrizacao(<?php echo $inprodut; ?> , <?  echo $inpessoa;?> , '<? echo $vlinicio; ?>' , <? echo $cdbircon; ?> , '<? echo $dsbircon; ?>', <? echo $cdmodbir; ?>, '<?  echo $dsmodbir; ?>'); return false;" > 
							<td style="width:120px;"><? echo $dsprodut; ?></td>
							<td style="width:120px;"><? echo $dspessoa; ?></td>
							<td style="width:120px;"><? echo $vlinicio; ?></td>
							<td style="width:120px;"><? echo $dsbircon . '-' . $dsmodbir; ?></td>
						</tr>				
					<? } ?>			
				</tbody>
			</table>
		</div> 
	</fieldset>
</form>