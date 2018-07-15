<?php
/*!
 * FONTE        : tab_extrat.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 01/08/2011 
 * OBJETIVO     : Tabela que apresenta a consulta EXTRAT
 * --------------
 * ALTERAÇÕES   : 17/10/2011 - Incluir o numero do historico na listagem (Gabriel)
 *				  29/10/2012 - Retiradi input image e incluso botões (Daniel)	
 *				  05/08/2013 - Correção listagem (Lucas)
 *                15/08/2013 - Alteração da sigla PAC para PA (Carlos)
 *                27/06/2014 - Incluir o campo COOP (Chamado 163044) - (Jonata - RKAM)
 *				  03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *                30/05/2018 - Concatenar dscomple com historico (Alcemir Mout's - Prj. 467).
 *                11/06/2018 - Ajuste para concatenar dscomple (tags[31]) com historico, o traço deve ficar no front (Douglas - Prj. 467).
 * --------------
 */
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<div id="tabExtrat">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>Data</th>
					<th>Hist&oacute;rico</th>
					<th>Documento</th>
					<th></th>
					<th>Valor</th>
					<th>Saldo</th>
				</tr>
			</thead>
			<tbody>
				<?php
				if ( $qtregist > 0 ) {
				
					if (getByTagName($extrato[0]->tags,'nrsequen') == "0" ) {
						$dshistor = getByTagName($extrato[0]->tags,'dshistor');
					}
					else {          
						$dshistor = formataNumericos('9999',getByTagName($extrato[0]->tags,'cdhistor')) . "-" . getByTagName($extrato[0]->tags,'dshistor');
					}					
				?>
			
				<tr>
					<td>&nbsp;
					<input type="hidden" id="dshistor" name="dshistor" value="<? echo $dshistor ?>" />								  
					<input type="hidden" id="dtliblan" name="dtliblan" value="<? echo getByTagName($extrato[0]->tags,'dtliblan') ?>" />		
					<input type="hidden" id="cdcoptfn" name="cdcoptfn" value="<? echo getByTagName($extrato[0]->tags,'cdcoptfn') ?>" />								  					
					<input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($extrato[0]->tags,'cdagenci') ?>" />								  
					<input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($extrato[0]->tags,'cdbccxlt') ?>" />								  
					<input type="hidden" id="nrdolote" name="nrdolote" value="<? echo getByTagName($extrato[0]->tags,'nrdolote') ?>" />								  
					<input type="hidden" id="dsidenti" name="dsidenti" value="<? echo getByTagName($extrato[0]->tags,'dsidenti') ?>" />								  
					
					</td>
					<td><?php echo $dshistor; ?></td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td><?php echo number_format(str_replace(",",".",getByTagName($extrato[0]->tags,'vlsdtota')),2,",","."); ?></td>
				</tr>
				<?php
				}
				?>
				
				<? 
				for ($i = 1; $i < $qtExtrato; $i++) {
				$vllanmto	= converteFloat(getByTagName($extrato[$i]->tags,'vllanmto'),"MOEDA");
				$vlsdtota	= converteFloat(getByTagName($extrato[$i]->tags,'vlsdtota'),"MOEDA"); 
					
				if (getByTagName($extrato[$i]->tags,'nrsequen') == "0" ) {
					$dshistor = getByTagName($extrato[$i]->tags,'dshistor');
				}
			    else {
					// verificar se existe complemento para ser adicionado ao extrato
					if (strlen(getByTagName($extrato[$i]->tags,'dscomple')) > 0 ) {
						// Exibe o complemento
						$dshistor = formataNumericos('9999',getByTagName($extrato[$i]->tags,'cdhistor')) . "-" . getByTagName($extrato[$i]->tags,'dshistor')." - ".getByTagName($extrato[$i]->tags,'dscomple');
					} else {
						// Exibe apenas o extrato
						$dshistor = formataNumericos('9999',getByTagName($extrato[$i]->tags,'cdhistor')) . "-" . getByTagName($extrato[$i]->tags,'dshistor');
					}
				}
								
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($extrato[$i]->tags,'dtmvtolt')); ?></span>
							      <? echo getByTagName($extrato[$i]->tags,'dtmvtolt'); ?>
  								  <input type="hidden" id="dshistor" name="dshistor" value="<? echo $dshistor ?>" />								  
  								  <input type="hidden" id="dtliblan" name="dtliblan" value="<? echo getByTagName($extrato[$i]->tags,'dtliblan') ?>" />								  
								  <input type="hidden" id="cdcoptfn" name="cdcoptfn" value="<? echo getByTagName($extrato[$i]->tags,'cdcoptfn') ?>" />								  			
								  <input type="hidden" id="cdagenci" name="cdagenci" value="<? echo getByTagName($extrato[$i]->tags,'cdagenci') ?>" />								  
  								  <input type="hidden" id="cdbccxlt" name="cdbccxlt" value="<? echo getByTagName($extrato[$i]->tags,'cdbccxlt') ?>" />								  
  								  <input type="hidden" id="nrdolote" name="nrdolote" value="<? echo getByTagName($extrato[$i]->tags,'nrdolote') ?>" />								  
  								  <input type="hidden" id="dsidenti" name="dsidenti" value="<? echo getByTagName($extrato[$i]->tags,'dsidenti') ?>" />								  

						</td>
						<td><span><? echo $dshistor; ?></span>
							      <? echo stringTabela( $dshistor , 30, 'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($extrato[$i]->tags,'nrdocmto'); ?></span>
							      <? echo getByTagName($extrato[$i]->tags,'nrdocmto'); ?>
						</td>
						<td><span><? echo getByTagName($extrato[$i]->tags,'indebcre'); ?></span>
							      <? echo getByTagName($extrato[$i]->tags,'indebcre'); ?>
						</td>
						<td><span><? echo $vllanmto  ?></span>
							      <? echo $vllanmto != 0 ? formataMoeda(getByTagName($extrato[$i]->tags,'vllanmto')) : ''; ?>
						</td>
						<td><span><? echo $vlsdtota?></span>
								  <? echo $vlsdtota != 0 ? formataMoeda(getByTagName($extrato[$i]->tags,'vlsdtota')) : ''; ?>
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


<div id="linha1">
<ul class="complemento">
<li>Hist&oacute;rico:</li>
<li id="dshistor"></li>
<li>Dt. Libera:</li>
<li id="dtliblan"></li>
</ul>
</div>

<div id="linha2">
<ul class="complemento">
<li>COOP:</li>
<li id="cdcoptfn"></li>
<li>PA:</li>
<li id="cdagenci"></li>
<li>Banco/Caixa:</li>
<li id="cdbccxlt"></li>
<li>Lote:</li>
<li id="nrdolote"></li>
<li id="dsidenti"></li>
</ul>
</div>


<div id="divBotoes" style='margin-top:10px; margin-bottom :10px'>
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" id="btSalvar" onclick="btnContinuar(); return false;">Prosseguir</a>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		buscaExtrato(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		buscaExtrato(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>