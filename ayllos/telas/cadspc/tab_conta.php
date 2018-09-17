<? 
/*!
 * FONTE        : tab_devedor.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 08/03/2012 
 * OBJETIVO     : Tabela que apresenta os devedores
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<div id="divConta">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta'); ?></th>
					<th><? echo utf8ToHtml('Titular');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
							      <? echo formataContaDV(getByTagName($r->tags,'nrdconta')) ?>
								  <input type="hidden" id="nrdconta" name="nrdconta" value="<? echo formataContaDV(getByTagName($r->tags,'nrdconta')) ?>" />								  
								  <input type="hidden" id="nmprimtl" name="nmprimtl" value="<? echo getByTagName($r->tags,'nmprimtl') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'nmprimtl') ?></span>
							      <? echo getByTagName($r->tags,'nmprimtl') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>

<div id="divBotoesConta" class="divBotoes" style="padding-bottom:7px">
	<a href="#" class="botao" id="btVoltar" onclick="fechaConta(false);return false;">Fechar</a>
	<a href="#" class="botao" onclick="selecionaConta(); return false;" >Continuar</a>
</div>

