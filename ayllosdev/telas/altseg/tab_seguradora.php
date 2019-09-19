<?php
	//*********************************************************************************************//
	//*** Fonte: buscar_seguradora.php                                                       ***//
	//*** Autor: Cristian Filipe                                                                ***//
	//*** Data : setembro/2013                                                                    ***//
	//*** Objetivo  : Efetuar pesquisa de seguradoras					                        ***//
	//***                                                                                       ***//	 
	//*********************************************************************************************//
?>
<div id="divTabSeguradora">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Cod.'); ?></th>
					<th><? echo utf8ToHtml('Seguradora'); ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach($registros as $values){ ?>
					<tr>
						<td><span><? echo getByTagName($values->tags, 'cdsegura'); ?></span>
							      <? echo mascara(getByTagName($values->tags, 'cdsegura'),'###.###.###'); ?>
								  <input type="hidden" value="<? echo mascara(getByTagName($values->tags, 'cdsegura'),'###.###.###');?>" id="hcdsegura">
						</td>
						<td><span><? echo getByTagName($values->tags, 'nmsegura');?></span>
							      <? echo getByTagName($values->tags, 'nmsegura');?>
								  <input type="hidden" value="<? echo getByTagName($values->tags, 'nmsegura');?>" id="hnmsegura">
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoes" >
	<a href="#" class="botao" id="btVoltar"  onClick="fechaRotina($('#divRotina')); return false;">Voltar</a>
</div>