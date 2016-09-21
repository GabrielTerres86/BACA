<? 
/*!
 * FONTE        : tab_titulares.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 13/06/2011 
 * OBJETIVO     : Tabela que apresenta os titulares
 * --------------
 * ALTERAÇÕES   :
 * 001: 21/01/2013 - Daniel (CECRED) : Implantacao novo layout.
 * --------------
 */	
?>

<div id="divTitulares">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Seq'); ?></th>
					<th><? echo utf8ToHtml('Titular');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $registro ) { ?>
					<tr>
						<td><span><? echo getByTagName($registro->tags,'idseqttl') ?></span>
							      <? echo getByTagName($registro->tags,'idseqttl') ?>
								  <input type="hidden" id="idseqttl" name="idseqttl" value="<? echo getByTagName($registro->tags,'idseqttl') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($registro->tags,'nmextttl') ?></span>
							      <? echo getByTagName($registro->tags,'nmextttl') ?>
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
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaTitular(); return false;" >Continuar</a>
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