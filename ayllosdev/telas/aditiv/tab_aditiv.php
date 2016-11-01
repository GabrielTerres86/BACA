<? 
/*!
 * FONTE        : tab_aditiv.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 30/09/2011
 * OBJETIVO     : Mostrar tela a tabela ADITIV
 * --------------
 * ALTERAÇÕES   : 22/11/2012 - Alterado botões do tipo tag <input> por
 *							   tag <a> (Daniel).
 * 				  05/01/2015 - Padronizando a mascara do campo nrctremp.
 *					           10 Digitos - Campos usados apenas para visualização
 *				 	 		   8 Digitos - Campos usados para alterar ou incluir novos contratos
 *					 		   (Kelvin - SD 233714)
 * --------------
 */
?>

<div id="tabAditiv">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Contrato');  ?></th>
					<th><? echo utf8ToHtml('Tipo do Aditivo');  ?></th>
					<th><? echo utf8ToHtml('Nro.');  ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $r ) { ?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'nrdconta') ?></span>
								  <? echo formataContaDV(getByTagName($r->tags,'nrdconta')) ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctremp') ?></span>
								  <? echo mascara(getByTagName($r->tags,'nrctremp'),'#.###.###.###') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsaditiv') ?></span>
								  <? echo getByTagName($r->tags,'dsaditiv') ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nraditiv') ?></span>
								  <? echo getByTagName($r->tags,'nraditiv') ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtmvtolt')) ?></span>
								  <? echo getByTagName($r->tags,'dtmvtolt') ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>	
</div>


<div id="divPesquisaRodape" class="divPesquisaRodape">
	<table>	
		<tr>
			<td>
				<?
					
					//
					if (isset($qtregist) and $qtregist == 0) $nriniseq = 0;
					
					// Se a paginação não está na primeira, exibe botão voltar
					if ($nriniseq > 1) { 
						?> <a class='paginacaoAnt'><<< Anterior</a> <? 
					} else {
						?> &nbsp; <?
					}
				?>
			</td>
			<td>
				<?
					if (isset($nriniseq)) { 
						?> Exibindo <? echo $nriniseq; ?> at&eacute; <? if (($nriniseq + $nrregist) > $qtregist) { echo $qtregist; } else { echo ($nriniseq + $nrregist - 1); } ?> de <? echo $qtregist; ?><?
					}
				?>
			</td>
			<td>
				<?
					// Se a paginação não está na &uacute;ltima página, exibe botão proximo
					if ($qtregist > ($nriniseq + $nrregist - 1)) {
						?> <a class='paginacaoProx'>Pr&oacute;ximo >>></a> <?
					} else {
						?> &nbsp; <?
					}
				?>			
			</td>
		</tr>
	</table>
</div>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>
