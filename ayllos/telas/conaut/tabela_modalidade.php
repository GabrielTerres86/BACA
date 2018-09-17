<? 
/*!
 * FONTE       : tabela_modalidade.php
 * CRIAÇÃO     : Jonata Cardoso (RKAM)
 * DATA CRIAÇÃO: 18/07/2014
 * OBJETIVO    : Tabela que apresenta as informacoes das modalidades
 *
 */

 ?>

<form class="formulario">
<fieldset id='tabConteudo'>
	
	<legend><? echo utf8ToHtml('Modalidades'); ?></legend>
			
	<div class="divRegistros">
		<table>
			<thead>
				<tr><th style="width:48px;"> <?php echo utf8ToHtml('Bir&ocirc;'); ?></th>
					<th style="width:78px;"> <?php echo utf8ToHtml('Descri&ccedil;&atilde;o'); ?></th>
					<th style="width:65px;"> <?php echo utf8ToHtml('Pessoa'); ?> </th>
					<th style="width:50px;"> <?php echo utf8ToHtml('Import&acirc;ncia'); ?> </th>
				</tr>			
			</thead>
			<tbody>
				<? foreach( $registros as $modalidade ) {
					$cdbircon = getByTagName($modalidade->tags,'cdbircon');
					$dsbircon = getByTagName($modalidade->tags,'dsbircon');
					$cdmodbir = getByTagName($modalidade->tags,'cdmodbir');
					$dsmodbir = getByTagName($modalidade->tags,'dsmodbir');
					$inpessoa = (getByTagName($modalidade->tags,'inpessoa') == "1") ? "F&iacute;sica" : "Jur&iacute;dica";
					$nmtagmod = getByTagName($modalidade->tags,'nmtagmod');
					$nrordimp = getByTagName($modalidade->tags,'nrordimp');
				?>
					<tr onclick="armazenarModalidade(<?php echo $cdbircon; ?> , <? echo $cdmodbir; ?> , '<? echo $dsmodbir; ?>', <? echo getByTagName($modalidade->tags,'inpessoa') ?>, '<? echo $nmtagmod ?>', <? echo $nrordimp ?> ); return false;" > 
					    <td style="width:120px;"><? echo $dsbircon; ?></td>
						<td style="width:193px;"><? echo $dsmodbir; ?></td>
						<td style="width:193px;"><? echo $inpessoa; ?></td>
					<!--	<td style="width:193px;"><? echo $nmtagmod; ?></td> -->
						<td style="width:225px;"><? echo $nrordimp; ?></td>
						<td><? echo $nmtagbir; ?></td>
					</tr>				
				<? } ?>			
			</tbody>
		</table>
	</div> 
</fieldset>
</form>