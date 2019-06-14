<?php 
/*!
 * FONTE        : tab_opcaoS.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 07/11/2011  
 * OBJETIVO     : Tabela que apresenta o saldo da opção S da tela BCAIXA
 * --------------
 * ALTERAÇÕES   : 27/01/2012 - Alteracoes para imprimir cabeçalho ou não (Tiago).
 *
 *				  19/04/2013 - Ajustes de layout nos botões (Lucas R).
 *	              12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmOpcaoS" name="frmOpcaoS" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend> Saldos </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th>PA</th>
					<th>Caixa</th>
					<th>Operador</th>
					<th>S</th>
					<th>Saldo Inicial</th>
					<th>Saldo Final</th>
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $boletimcx as $r ) { 
								
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdagenci'); ?></span>
							      <? echo getByTagName($r->tags,'cdagenci'); ?>
								  <input type="hidden" id="nrcrecid" name="nrcrecid" value="<? echo getByTagName($r->tags,'nrcrecid') ?>" />								  
								  <input type="hidden" id="nrdlacre" name="nrdlacre" value="<? echo getByTagName($r->tags,'nrdlacre') ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'nrdcaixa'); ?></span>
							      <? echo getByTagName($r->tags,'nrdcaixa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nmoperad'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'nmoperad'),25,'maiuscula'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdsitbcx'); ?></span>
							      <? echo getByTagName($r->tags,'cdsitbcx'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vldsdini'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldsdini')); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vldsdfin'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldsdfin')); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>

	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:11px">
	
	<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;" >Voltar</a>	
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Boletim'); return false;" >Visualizar</a>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Termo'); return false;" >Imprimir Abertura</a>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Boletim'); return false;" >Imprimir Boletim</a> <br/> <br/>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Fita_Caixa'); return false;" >Imprimir Fita</a>
	<a href="#" class="botao" onClick="$('#tipconsu','#frmImprimir').val('yes');Gera_Impressao('Gera_Depositos_Saques'); return false;" >Imprimir Dep/Saq</a>
	
</div>
