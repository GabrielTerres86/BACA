<? 
/*!
 * FONTE       : tabela_biro.php
 * CRIAÇÃO     : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO: 17/07/2014
 * OBJETIVO    : Tabela que apresenta as informacoes dos biros
 *
 */

 ?>

<form class="formulario">
<fieldset id='tabConteudo'>
	
	<legend><? echo utf8ToHtml('Bir&ocirc;s'); ?></legend>
			
	<div class="divRegistros">
		<table>
			<thead>
				<tr><th style="width:47px;"> <?php echo utf8ToHtml('C&oacute;digo'); ?></th>
					<th style="width:80px;"> <?php echo utf8ToHtml('Descri&ccedil;&atilde;o'); ?></th>
					<th style="width:60px;"> <?php echo utf8ToHtml('Tag XML'); ?> </th>
				</tr>			
			</thead>
			<tbody>
				<? foreach( $registros as $biro ) {
					$cdbircon = getByTagName($biro->tags,'cdbircon');
					$dsbircon = getByTagName($biro->tags,'dsbircon');
					$nmtagbir = getByTagName($biro->tags,'nmtagbir');
				?>
					<tr onclick="armazenarBiro(<?php echo $cdbircon; ?> , '<? echo $dsbircon; ?>' , '<? echo $nmtagbir; ?>' ); return false;" > 
					    <td style="width:120px;"><? echo $cdbircon; ?></td>
						<td style="width:193px;" ><? echo $dsbircon; ?></td>
						<td><? echo $nmtagbir; ?></td>
					</tr>				
				<? } ?>			
			</tbody>
		</table>
	</div> 
</fieldset>
</form>