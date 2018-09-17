<? 
/*!
 * FONTE        : tab_endava.php
 * CRIA��O      : Jéssica (DB1)
 * DATA CRIAÇÃo : 30/10/2013
 * OBJETIVO     : Tabela que apresenta os dados dos endere�os da tela ENDAVA
 *
 */	
?>

<?

	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');	
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

?>

<div id="divContrato">
	<div class="divRegistros">	

		<table>
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Contrato'); ?></th>
					<th><? echo utf8ToHtml('Conta/DV');  ?></th>
					<th><? echo utf8ToHtml('Tipo');  ?></th>
				</tr>
			</thead>
			<tbody>
				<? foreach( $registros as $i ) {
					// Recebo todos valores em variáveis
					$nrctremp = getByTagName($i->tags,'nrctremp');
					$nrdconta = getByTagName($i->tags,'nrdconta');
					$tpctrato = getByTagName($i->tags,'tpctrato');
					
					if($tpctrato == 1){
						$dsctrato = "EP - Emprestimo";
					}else if($tpctrato == 2){
						$dsctrato = "DC - Desconto Cheque";
					}else if($tpctrato == 3){
						$dsctrato = "LM - Limite";
					}else if($tpctrato == 4){
						$dsctrato = "CR - Cart�o";
					}
																				
				?>			
					<tr>
						<td><span><? echo $nrctremp ?></span>
							<? echo mascara(getByTagName($i->tags,'nrctremp'),'#.###.###') ?>
						
							<input type="hidden" id="pro_cpfcgc" name="pro_cpfcgc" value="<? echo getByTagName($i->tags,'pro_cpfcgc'); ?>" />
							<input type="hidden" id="nrctremp"   name="nrctremp"   value="<? echo mascara(getByTagName($i->tags,'nrctremp'),'#.###.###') ?>" />
							<input type="hidden" id="nrdconta"   name="nrdconta"   value="<? echo mascara(getByTagName($i->tags,'nrdconta'),'####.###.#') ?>" />
							<input type="hidden" id="tpctrato"   name="tpctrato"   value="<? echo $tpctrato ?>" />
							<input type="hidden" id="nmdaval"    name="nmdaval"    value="<? echo getByTagName($i->tags,'nmdavali'); ?>" />
							<input type="hidden" id="tpdocav"    name="tpdocav"    value="<? echo getByTagName($i->tags,'tpdocava'); ?>" />
							<input type="hidden" id="dscpfav"    name="dscpfav"    value="<? echo getByTagName($i->tags,'nrdocava'); ?>" />
							<input type="hidden" id="nmcjgav"    name="nmcjgav"    value="<? echo getByTagName($i->tags,'nmconjug'); ?>" />
							<input type="hidden" id="cpfccg"     name="cpfccg"     value="<? echo getByTagName($i->tags,'nrcpfcjg'); ?>" />
							<input type="hidden" id="tpdoccj"    name="tpdoccj"    value="<? echo getByTagName($i->tags,'tpdoccjg'); ?>" />
							<input type="hidden" id="dscfcav"    name="dscfcav"    value="<? echo getByTagName($i->tags,'nrdoccjg'); ?>" />
							<input type="hidden" id="nrfonres"   name="nrfonres"   value="<? echo getByTagName($i->tags,'nrfonres'); ?>" />
							<input type="hidden" id="nrcepend"   name="nrcepend"   value="<? echo getByTagName($i->tags,'nrcepend'); ?>" />
							<input type="hidden" id="dsendav1"   name="dsendav1"   value="<? echo getByTagName($i->tags,'dsendres1'); ?>" />
							<input type="hidden" id="nrendere"   name="nrendere"   value="<? echo getByTagName($i->tags,'nrendere'); ?>" />
							<input type="hidden" id="complend"   name="complend"   value="<? echo getByTagName($i->tags,'complend'); ?>" />
							<input type="hidden" id="nrcxapst"   name="nrcxapst"   value="<? echo getByTagName($i->tags,'nrcxapst'); ?>" />
							<input type="hidden" id="dsendav2"   name="dsendav2"   value="<? echo getByTagName($i->tags,'dsendres2'); ?>" />
							<input type="hidden" id="dsdemail"   name="dsdemail"   value="<? echo getByTagName($i->tags,'dsdemail'); ?>" />
							<input type="hidden" id="nmcidade"   name="nmcidade"   value="<? echo getByTagName($i->tags,'nmcidade'); ?>" />
							<input type="hidden" id="cdufresd"   name="cdufresd"   value="<? echo getByTagName($i->tags,'cdufresd'); ?>" />
														
						</td>
										
						<td> <? echo mascara(getByTagName($i->tags,'nrdconta'),'####.###.#') ?> </td>
						<td> <? echo $dsctrato ?> </td>
														    			    
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
	<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divRotina')); cNrctremp.focus(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onClick="selecionaContrato(); return false;">Continuar</a>
</div>

<script type="text/javascript">
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaEndava(<? echo "'".($nriniseq - $nrregist)."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaEndava(<? echo "'".($nriniseq + $nrregist)."'"; ?>);
	});	
	$('#divPesquisaRodape').formataRodapePesquisa();
</script>