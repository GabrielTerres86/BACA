<? 
/*!
 * FONTE        : tab_beneficiarios.php
 * CRIAÇÃO      : Gabriel Capoia - (DB1)
 * DATA CRIAÇÃO : 25/05/2011 
 * OBJETIVO     : Tabela que apresenta beneficiarios
 * --------------
 * ALTERAÇÕES   : 17/12/2012 - Ajuste para layout padrao (Daniel). 
 * --------------
 */	
?>

<div id="divBeneficiarios">
	<div class="divRegistros">	
		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Nome'); ?></th>
					<th><? echo utf8ToHtml('CPF');  ?></th>
					<th><? echo utf8ToHtml('NB');   ?></th>
					<th><? echo utf8ToHtml('NIT');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $registro ) { ?>
					<tr>
						<td><span><? echo getByTagName($registro->tags,'nmrecben') ?></span>
							      <? echo stringTabela(getByTagName($registro->tags,'nmrecben'),31,'maiuscula') ?>
								  <input type="hidden" id="nmrecben" name="nmrecben" value="<? echo getByTagName($registro->tags,'nmrecben') ?>" />								  
								  <input type="hidden" id="nrcpfcgc" name="nrcpfcgc" value="<? echo getByTagName($registro->tags,'nrcpfcgc') ?>" />								  
								  <input type="hidden" id="nrbenefi" name="nrbenefi" value="<? echo getByTagName($registro->tags,'nrbenefi') ?>" />								  
								  <input type="hidden" id="nrrecben" name="nrrecben" value="<? echo getByTagName($registro->tags,'nrrecben') ?>" />								  
								  <input type="hidden" id="cdaginss" name="cdaginss" value="<? echo getByTagName($registro->tags,'cdaginss') ?>" />								  
								  <input type="hidden" id="nrdconta" name="nrdconta" value="<? echo getByTagName($registro->tags,'nrdconta') ?>" />								  
								  <input type="hidden" id="cdaltcad" name="cdaltcad" value="<? echo getByTagName($registro->tags,'cdaltcad') ?>" />								  
								  <input type="hidden" id="dtatucad" name="dtatucad" value="<? echo getByTagName($registro->tags,'dtatucad') ?>" />								  
								  <input type="hidden" id="tpmepgto" name="tpmepgto" value="<? echo getByTagName($registro->tags,'tpmepgto') ?>" />								  
								  <input type="hidden" id="dtdenvio" name="dtdenvio" value="<? echo getByTagName($registro->tags,'dtdenvio') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($registro->tags,'nrcpfcgc') ?></span>
							      <? echo getByTagName($registro->tags,'nrcpfcgc') ?>
						</td>
						<td><span><? echo getByTagName($registro->tags,'nrbenefi') ?></span>
							      <? echo getByTagName($registro->tags,'nrbenefi') ?>
						</td>
						<td><span><? echo getByTagName($registro->tags,'nrrecben') ?></span>
							      <? echo getByTagName($registro->tags,'nrrecben') ?>
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

<div id="divBotoes" style="margin-bottom:10px;">
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico'));estadoInicial();return false;" >Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaBeneficiario(); return false;" >Continuar</a>
</div>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaBeneficiarios(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaBeneficiarios(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	$('#divPesquisaRodape','#divUsoGenerico').formataRodapePesquisa();
</script>