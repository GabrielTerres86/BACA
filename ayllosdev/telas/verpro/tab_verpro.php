<?php
/*!
 * FONTE        : tab_verpro.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 25/10/2011 
 * OBJETIVO     : Tabela que apresenta a consulta VERPRO
 * --------------
	* ALTERAÇÕES   : 03/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */ 

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>
<div id="tabVerpro">
	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>Transa&ccedil;&atilde;o</th>
					<th>Hora</th>
					<th>Valor</th>
					<th>Protocolo</th>
					<th>Tipo</th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $registros as $r ) {								
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dttransa')); ?></span>
							      <? echo getByTagName($r->tags,'dttransa'); ?>
  								  <input type="hidden" id="cdtippro" name="cdtippro" value="<? echo getByTagName($r->tags,'cdtippro') ?>" />								  
  								  <input type="hidden" id="nmprepos" name="nmprepos" value="<? echo getByTagName($r->tags,'nmprepos') ?>" />								  
  								  <input type="hidden" id="nmoperad" name="nmoperad" value="<? echo getByTagName($r->tags,'nmoperad') ?>" />								  
  								  <input type="hidden" id="tppgamto" name="tppgamto" value="<? echo getByTagName($r->tags,'tppgamto') ?>" />								  
  								  <input type="hidden" id="dsdbanco" name="dsdbanco" value="<? echo getByTagName($r->tags,'dsdbanco') ?>" />								  
								  <input type="hidden" id="dsageban" name="dsageban" value="<? echo getByTagName($r->tags,'dsageban') ?>" />
								  <input type="hidden" id="nrctafav" name="nrctafav" value="<? echo getByTagName($r->tags,'nrctafav') ?>" />
								  <input type="hidden" id="nmfavore" name="nmfavore" value="<? echo getByTagName($r->tags,'nmfavore') ?>" />
								  <input type="hidden" id="nrcpffav" name="nrcpffav" value="<? echo getByTagName($r->tags,'nrcpffav') ?>" />
								  <input type="hidden" id="dsfinali" name="dsfinali" value="<? echo getByTagName($r->tags,'dsfinali') ?>" />
								  <input type="hidden" id="dstransf" name="dstransf" value="<? echo getByTagName($r->tags,'dstransf') ?>" />
  								  <input type="hidden" id="dscedent" name="dscedent" value="<? echo getByTagName($r->tags,'dscedent') ?>" />								  
  								  <input type="hidden" id="dttransa" name="dttransa" value="<? echo getByTagName($r->tags,'dttransa') ?>" />								  
  								  <input type="hidden" id="hrautenx" name="hrautent" value="<? echo getByTagName($r->tags,'hrautenx') ?>" />								  
  								  <input type="hidden" id="hrautent" name="hrautent" value="<? echo getByTagName($r->tags,'hrautent') ?>" />								  
  								  <input type="hidden" id="dtmvtolt" name="dtmvtolt" value="<? echo getByTagName($r->tags,'dtmvtolt') ?>" />								  
  								  <input type="hidden" id="vldocmto" name="vldocmto" value="<? echo getByTagName($r->tags,'vldocmto') ?>" />								  
  								  <input type="hidden" id="dsprotoc" name="dsprotoc" value="<? echo getByTagName($r->tags,'dsprotoc') ?>" />								  
  								  <input type="hidden" id="cdbarras" name="cdbarras" value="<? echo getByTagName($r->tags,'cdbarras') ?>" />								  
  								  <input type="hidden" id="lndigita" name="lndigita" value="<? echo getByTagName($r->tags,'lndigita') ?>" />								  
  								  <input type="hidden" id="nrseqaut" name="nrseqaut" value="<? echo getByTagName($r->tags,'nrseqaut') ?>" />								  
  								  <input type="hidden" id="nrdocmto" name="nrdocmto" value="<? echo getByTagName($r->tags,'nrdocmto') ?>" />								  
  								  <input type="hidden" id="flgpagto" name="flgpagto" value="<? echo getByTagName($r->tags,'flgpagto') ?>" />								  								  								  

  								  <!-- PRJ 470 -->
  								  <input type="hidden" id="dtinclusao" name="dtinclusao" value="<? echo getByTagName($r->tags,'dtinclusao') ?>" />
  								  <input type="hidden" id="hrinclusao" name="hrinclusao" value="<? echo getByTagName($r->tags,'hrinclusao') ?>" />
  								  <input type="hidden" id="dsfrase" name="dsfrase" value="<? echo getByTagName($r->tags,'dsfrase') ?>" />
  								  <input type="hidden" id="dstippro" name="dstippro" value="<? echo getByTagName($r->tags,'dstippro') ?>" />

								  <!-- bruno - prj 470 - tela autorizacao -->
  								  <input type="hidden" id="dsoperacao" name="dsoperacao" value="<? echo getByTagName($r->tags,'dsoperacao') ?>" />
  								  <input type="hidden" id="cdbanco"    name="cdbanco" value="<? echo getByTagName($r->tags,'cdbanco') ?>" />
  								  <input type="hidden" id="cdagencia"  name="cdagencia" value="<? echo getByTagName($r->tags,'cdagencia') ?>" />
  								  <input type="hidden" id="cdconta"    name="cdconta" value="<? echo getByTagName($r->tags,'cdconta') ?>" />
  								  <input type="hidden" id="nrcheque_i" name="nrcheque_i" value="<? echo getByTagName($r->tags,'nrcheque_i') ?>" />
  								  <input type="hidden" id="nrcheque_f" name="nrcheque_f" value="<? echo getByTagName($r->tags,'nrcheque_f') ?>" />

  								  <input type="hidden" id="dslinha1" name="dslinha1" value="<? echo getByTagName($r->tags[12]->tags,'dsinform.1') ?>" />								  
  								  <input type="hidden" id="dslinha2" name="dslinha2" value="<? echo getByTagName($r->tags[12]->tags,'dsinform.2') ?>" />								  
  								  <input type="hidden" id="dslinha3" name="dslinha3" value="<? echo getByTagName($r->tags[12]->tags,'dsinform.3') ?>" />								  

  								  <input type="hidden" id="terminal" name="terminal" value="<? echo getByTagName($r->tags,'terminax') ?>" />								  
 
						</td>
						<td><span><? echo getByTagName($r->tags,'hrautent'); ?></span>
							      <? echo getByTagName($r->tags,'hrautenx'); ?>
						</td>
						<td><span><? echo converteFloat(getByTagName($r->tags,'vldocmto')); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldocmto')); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dsprotoc'); ?></span>
							      <? echo getByTagName($r->tags,'dsprotoc'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'dstippro'); ?></span>
								  <? echo getByTagName($r->tags,'dstippro'); ?>
								  
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
					// Se a paginação não está na última página, exibe botão proximo
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
<li id="cdbarras"></li>
</ul>
</div>

<div id="linha2">
<ul class="complemento">
<li id="lndigita"></li>
</ul>
</div>

<div id="linha3">
<ul class="complemento">
<li id="terminal"></li>
</ul>
</div>

<div id="divBotoes" style="margin-bottom:10px">
	<a href="#" class="botao" id="btVoltar"    onclick="btnVoltar();return false;">Voltar</a>
	<a href="#" class="botao" id="btDetalhar"  onclick="mostraProtocolo();return false;">Detalhar</a>
</div>

<script type="text/javascript">

	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao('BP', <? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao('BP', <? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	$('#divPesquisaRodape','#divTela').formataRodapePesquisa();

</script>