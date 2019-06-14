<? 
/*!
 * FONTE        : tab_identificadores.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 07/06/2011 
 * OBJETIVO     : Tabela que apresenta identificadores
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */	
?>

<div id="divIdentificadores">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Identificador'); ?></th>
					<th><? echo utf8ToHtml('Cd. Pgto');  ?></th>
					<th><? echo utf8ToHtml('Conta/dv');   ?></th>
					<th><? echo utf8ToHtml('Nome');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $registro ) { ?>
					<tr>
						<td><span><? echo getByTagName($registro->tags,'cdidenti') ?></span>
							      <? echo getByTagName($registro->tags,'cdidenti') ?>
								  <input type="hidden" id="cdidenti" name="cdidenti" value="<? echo getByTagName($registro->tags,'cdidenti') ?>" />								  
								  <input type="hidden" id="cddpagto" name="cddpagto" value="<? echo getByTagName($registro->tags,'cddpagto') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($registro->tags,'cddpagto') ?></span>
							      <? echo getByTagName($registro->tags,'cddpagto') ?>
						</td>
						<td><span><? echo getByTagName($registro->tags,'nrdconta') ?></span>
							      <? echo getByTagName($registro->tags,'nrdconta') == 0 ? 0 : formataContaDV(getByTagName($registro->tags,'nrdconta')) ?>
						</td>
						<td><span><? echo getByTagName($registro->tags,'nmprimtl') ?></span>
							      <? echo stringTabela(getByTagName($registro->tags,'nmprimtl'),41,'maiuscula') ?>
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

<div id="divBotoes">
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaIdentificador(); return false;" >Continuar</a>
</div>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaIdentificadores(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaIdentificadores(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape','#divRotina').formataRodapePesquisa();
</script>