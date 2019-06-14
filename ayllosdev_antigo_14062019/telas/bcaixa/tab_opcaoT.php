<?php
/*!
 * FONTE        : tab_opcaoT.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 07/11/2011 
 * OBJETIVO     : Tabela que apresenta o saldo atual da opção T da tela BCAIXA
 * --------------
 * ALTERAÇÕES   : 25/01/2012 - Alterada margin do "Total" pois sobreescrevia a tela (Tiago).
 *
 *				  16/04/2013 - Incluir PAC no frame, Incluir class em frame para as situacoes 	
 *							   de CAIXA ou COFRE, Ajuste de botao voltar para novo padrao (Lucas R.)
 *                12/08/2013 - Alteração da sigla PAC para PA. (Carlos)
 *				  20/02/2015 - Incluir classe csTotal e seus respectivos valores (Lucas R. #245838 )
 *				  29/07/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 * --------------
 */
 
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	
?>

<form id="frmOpcaoT" name="frmOpcaoT" class="formulario" onSubmit="return false;">

	<fieldset>
	<legend> Saldo Atual </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th class="csCaixa csCofre csTotal csCaiCof"><? echo utf8Tohtml('PA'); ?></th>
					<th class="csCaixa"><? echo utf8ToHtml('Caixa'); ?></th>
					<th class="csCaixa"><? echo utf8ToHtml('Operador');  ?></th>
					<th class="csCaixa csCofre"><? echo utf8ToHtml('Saldo');  ?></th>
					<th class="csCaixa"><? echo utf8ToHtml('Situação');  ?></th>
					<th class="csTotal"><? echo utf8ToHtml('Caixa'); ?></th>
					<th class="csTotal"><? echo utf8ToHtml('Cofre'); ?></th>
					<th class="csCaiCof"><? echo utf8ToHtml('Saldo (Caixa + Cofre)');  ?></th>
					
				</tr>
			</thead>
			<tbody>
				<? 
				foreach( $crapbcx as $r )  { 
				?>
					<tr>
						<td class="csCaixa csCofre csTotal csCaiCof"><span><? echo getByTagName($r->tags,'cdagenci'); ?></span>
							      <? echo getByTagName($r->tags,'cdagenci'); ?>
						</td>
						<td class="csCaixa"><span><? echo getByTagName($r->tags,'nrdcaixa'); ?></span>
							      <? echo getByTagName($r->tags,'nrdcaixa'); ?>
								  
						</td>
						<td class="csCaixa"><span><? echo getByTagName($r->tags,'nmoperad'); ?></span>
							      <? echo stringTabela(getByTagName($r->tags,'nmoperad'),35,'maiuscula'); ?>
						</td>
						<td class="csCaixa csCofre"><span><? echo converteFloat(getByTagName($r->tags,'vldsdtot')); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vldsdtot')); ?>
						</td>
						<td class="csCaixa"><span><? echo getByTagName($r->tags,'csituaca'); ?></span>
							      <? echo getByTagName($r->tags,'csituaca'); ?>
						</td>
						
						<td class="csTotal"><span>  <? echo converteFloat(getByTagName($r->tags,'vltotcai')); ?></span>
							<? echo formataMoeda(getByTagName($r->tags,'vltotcai')); ?>
						</td>
						<td class="csTotal" ><span><? echo converteFloat(getByTagName($r->tags,'vltotcof')); ?></span>
							<? echo formataMoeda(getByTagName($r->tags,'vltotcof')); ?>
						</td>
						
						<td class="csCaiCof" ><span><? echo converteFloat(getByTagName($r->tags,'totcacof'));  ?></span>
							<? echo formataMoeda(getByTagName($r->tags,'totcacof'));  ?>
						</td>
						
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	
	<center style="margin:0px 10px 10px 10px"><b>TOTAL:</b> <? echo formataMoeda($saldot) ?></center>
	
	</fieldset>
	
</form>

<div id="divBotoes" style="margin-bottom:8px; ">
	<a href="#" class="botao" id="btVoltar" onClick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onClick="gera_imp_T(); return false;">Imprimir</a>
</div>