<? 
/*!
 * FONTE        : tab_beneficiarios.php
 * CRIAÇÃO      : Rogérius Militão - (DB1)
 * DATA CRIAÇÃO : 01/06/2011 
 * OBJETIVO     : Tabela que apresenta os beneficiarios
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>

<fieldset>
<legend>Nomes</legend>

<div class="divRegistros">	
	<table>
		<thead>
			<tr>
				<th><? echo utf8ToHtml('Nome'); ?></th>
				<th><? echo utf8ToHtml('NB');   ?></th>
				<th><? echo utf8ToHtml('Data Nasc');   ?></th>
				<th><? echo utf8ToHtml('Nome da Mãe');   ?></th>
				<th><? echo utf8ToHtml('Data <br /> Alt Cad');   ?></th>
			</tr>
		</thead>
		<tbody>
			<? foreach( $registros as $registro ) { ?>
				<tr>
					<td><span><? echo getByTagName($registro->tags,'nmrecben') ?></span>
							  <? echo stringTabela(getByTagName($registro->tags,'nmrecben'),31,'maiuscula') ?>
							  <input type="hidden" id="nrbenefi" name="nrbenefi" value="<? echo getByTagName($registro->tags,'nrbenefi') ?>" />								  
							  <input type="hidden" id="nrrecben" name="nrrecben" value="<? echo getByTagName($registro->tags,'nrrecben') ?>" />								  
							  <input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo formatar(getByTagName($registro->tags,'nrcpfcgc'),'cpf') ?>" />								  
							  <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($registro->tags,'cdagenci') ?>" />								  
							  <input type="hidden" id="nmrecben" name="nmrecben" value="<? echo getByTagName($registro->tags,'nmrecben') ?>" />								  
							  <input type="hidden" id="dtnasben" name="dtnasben" value="<? echo getByTagName($registro->tags,'dtnasben') ?>" />								  
							  <input type="hidden" id="nmmaeben" name="nmmaeben" value="<? echo getByTagName($registro->tags,'nmmaeben') ?>" />								  
							  <input type="hidden" id="dsendben" name="dsendben" value="<? echo getByTagName($registro->tags,'dsendben') ?>" />								  
							  <input type="hidden" id="nmbairro" name="nmbairro" value="<? echo getByTagName($registro->tags,'nmbairro') ?>" />								  
							  <input type="hidden" id="nrcepend" name="nrcepend" value="<? echo formataCep(getByTagName($registro->tags,'nrcepend')) ?>" />								  
							  <input type="hidden" id="dtatuend" name="dtatuend" value="<? echo getByTagName($registro->tags,'dtatuend') ?>" />								  
							  <input type="hidden" id="nmresage" name="nmresage" value="<? echo getByTagName($registro->tags,'nmresage') ?>" />								  

							  
					</td>
					<td><span><? echo getByTagName($registro->tags,'nrbenefi') ?></span>
							  <? echo stringTabela(getByTagName($registro->tags,'nrbenefi'), 28, 'palavra') ?>
					</td>
					<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtnasben')) ?></span>
							  <? echo getByTagName($registro->tags,'dtnasben') ?>
					</td>

					<td><span><? echo getByTagName($registro->tags,'nmmaeben') ?></span>
							  <? echo stringTabela(getByTagName($registro->tags,'nmmaeben'), 17, 'palavra') ?>
					</td>

					<td><span><? echo dataParaTimestamp(getByTagName($registro->tags,'dtatucad')) ?></span>
							  <? echo getByTagName($registro->tags,'dtatucad') ?>
					</td>
					
				</tr>
		<? } ?>	
		</tbody>
	</table>
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

</fieldset>


<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaBeneficiarios(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaBeneficiarios(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
		
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>