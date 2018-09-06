<? 
/*!
 * FONTE       : tabela_reaproveitamento.php
 * CRIAÇÃO     : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO: 21/07/2014
 * OBJETIVO    : Tabela que apresenta as informacoes do reaproveitamento de consultas
 *
 * --------------
 * ALTERAÇÕES   : 13/10/2015 - Projeto Reformulacao Cadastral (Tiago Castro - RKAM). 
 				  29/03/2018 - Ajustes para inclusão de novo produto. (Alex Sandro - GFT)
 * --------------
 *				 
 */
 ?>

<form class="formulario">
<fieldset id='tabConteudo'>
	
	<legend><? echo utf8ToHtml('Reaproveitamento de Consultas'); ?></legend>
			
	<div class="divRegistros">
		<table>
			<thead>
				<tr><th style="width:68px;"> <?php echo utf8ToHtml('Produto'); ?></th>
					<th style="width:69px;"> <?php echo utf8ToHtml('Pessoa'); ?> </th>
					<th style="width:60px;"> <?php echo utf8ToHtml('Qtde Dias'); ?> </th>
				</tr>			
			</thead>
			<tbody>
				<? foreach( $registros as $reaproveitamento ) {
					$inprodut =  getByTagName($reaproveitamento->tags,'inprodut');
					
					switch ($inprodut) {
						case 1: { $dsprodut = "Empr&eacute;stimo";         break; }
						case 2: { $dsprodut = "Financiamento";      break; } 
						case 3: { $dsprodut = "Cheque Especial";    break; }
						case 4: { $dsprodut = "Desconto de Cheque"; break; }
						case 5: { $dsprodut = "Desconto de T&iacute;tulos"; break; }
						case 6: { $dsprodut = "Cadastro Conta"; break; }
						case 7: { $dsprodut = "Border&ocirc; de T&iacute;tulos"; break; } 

					}
 					
					$inpessoa =  getByTagName($reaproveitamento->tags,'inpessoa');
					$dspessoa = ($inpessoa == "1") ? "F&iacute;sica" : "Jur&iacute;dica";
					$qtdiarpv =  getByTagName($reaproveitamento->tags,'qtdiarpv');
				?>
					<tr onclick="armazenarReaproveitamento(<?php echo $inprodut; ?> , <?  echo $inpessoa;?> , <? echo $qtdiarpv; ?>); return false;" > 
					    <td style="width:120px;"><? echo $dsprodut; ?></td>
						<td style="width:120px;"><? echo $dspessoa; ?></td>
						<td style="width:120px;"><? echo $qtdiarpv; ?></td>
					</tr>				
				<? } ?>			
			</tbody>
		</table>
	</div> 
</fieldset>
</form>