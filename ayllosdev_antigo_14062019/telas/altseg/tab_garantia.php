<? 
/*!
 * FONTE        : tab_garantia.php
 * CRIAÇÃO      : Cristian Filipe Fernandes
 * DATA CRIAÇÃO : 26/11/2013								Última alteração: 17/09/2015 
 * OBJETIVO     : Tabela que apresenta as garantias
 * --------------
 * ALTERAÇÕES   : 17/09/2015 - Ajuste para liberação (Adriano).
 * --------------
 */	
 
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
	
?>
<div id="divTabGarantia">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Descri&ccedil;&atilde;o'); ?></th>
					<th><? echo utf8ToHtml('Valor'); ?></th>
					<th><? echo utf8ToHtml('Franquia'); ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach($registros as $values){ ?>
					<tr>  
						<td><span><? echo getByTagName($values->tags, 'dsgarant'); ?></span>
							      <? echo getByTagName($values->tags, 'dsgarant'); ?>
								
						</td>
						<td><span><? echo converteFloat(getByTagName($values->tags, 'vlgarant') ,'MOEDA') ?></span>
							      <? echo formataMoeda(getByTagName($values->tags, 'vlgarant')) ?>
						</td>
						<td><span><? echo getByTagName($values->tags, 'dsfranqu');?></span>
							      <? echo getByTagName($values->tags, 'dsfranqu');?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	<div id="divRegistrosRodape" class="divRegistrosRodape">
		<table>	
			<tr>
				<td>
				</td>
				<td>					
				</td>
				<td>
				</td>
			</tr>
		</table>
	</div>		
</div>

<script text="text/javascript">
		
	$('#divRegistrosRodape','#divTabGarantia').formataRodapePesquisa();
	
</script>