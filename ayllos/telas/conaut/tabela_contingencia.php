<? 
/*!
 * FONTE       : tabela_contingencia.php
 * CRIAÇÃO     : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO: 18/07/2014
 * OBJETIVO    : Tabela que apresenta as informacoes das contingencias
 *
 */

 ?>

<form class="formulario">
<fieldset id='tabConteudo'>
	
	<legend><? echo utf8ToHtml('Conting&ecirc;ncias'); ?></legend>
			
	<div class="divRegistros">
		<table>
			<thead>
				<tr><th style="width:71px;"> <?php echo utf8ToHtml('Bir&ocirc;'); ?></th>
					<th style="width:60px;"> <?php echo utf8ToHtml('In&iacute;cio'); ?> </th>
				</tr>			
			</thead>
			<tbody>
				<? foreach( $registros as $contingencia ) {
					$cdbircon = getByTagName($contingencia->tags,'cdbircon');
					$dsbircon = getByTagName($contingencia->tags,'dsbircon');
					$dtinicon = getByTagName($contingencia->tags,'dtinicon');
				?>
					<tr onclick="armazenarContingencia(<?php echo $cdbircon; ?> , '<?  echo $dsbircon;?>' , '<? echo $dtinicon; ?>'); return false;" > 
					    <td style="width:120px;"><? echo $dsbircon; ?></td>
						<td style="width:120px;"><? echo $dtinicon; ?></td>
					</tr>				
				<? } ?>			
			</tbody>
		</table>
	</div> 
</fieldset>
</form>