<? 
/*!
 * FONTE        : form_opcao_p.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 24/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao P da tela DESCTO
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 
?>

<?php
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();	

	include('form_cabecalho.php');
	
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<?php include('form_associado.php'); ?>

	<fieldset>
		<legend> Dados do Cheque </legend>

		<label for="cdbanchq">Banco:</label>
		<input type="text" id="cdbanchq" name="cdbanchq" value="<?php echo $cdbanchq ?>"/>

		<label for="cdagechq"><? echo utf8ToHtml('Agência:'); ?></label>
		<input type="text" id="cdagechq" name="cdagechq" value="<?php echo $cdagechq ?>"/>

		<label for="nrctachq">Conta:</label>
		<input type="text" id="nrctachq" name="cdagechq" value="<?php echo $nrctachq ?>"/>

		<label for="nrcheque">Nr Cheque:</label>
		<input type="text" id="nrcheque" name="cdagechq" value="<?php echo $nrcheque ?>"/>
		
	</fieldset>

	<fieldset>
	<legend> CMC7 </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Comp'); ?></th>
					<th><? echo utf8ToHtml('Bco'); ?></th>
					<th><? echo utf8ToHtml('Ag.');  ?></th>
					<th><? echo utf8ToHtml('C1');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('C2');  ?></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('C3');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'cdcmpchq'); ?></span>
							      <? echo getByTagName($r->tags,'cdcmpchq'); ?>
								<input type="hidden" id="dspesqui" name="dspesqui" value="<? echo getByTagName($r->tags,'dspesqui'); ?>" />								  
								<input type="hidden" id="dssitchq" name="dssitchq" value="<? echo getByTagName($r->tags,'dssitchq'); ?>" />								  
								<input type="hidden" id="dsdocmc7" name="dsdocmc7" value="<? echo getByTagName($r->tags,'dsdocmc7'); ?>" />								  
								<input type="hidden" id="nrborder" name="nrborder" value="<? echo getByTagName($r->tags,'nrborder'); ?>" />								  
								<input type="hidden" id="nrctrlim" name="nrctrlim" value="<? echo getByTagName($r->tags,'nrctrlim'); ?>" />								  
								<input type="hidden" id="dtlibera" name="dtlibera" value="<? echo getByTagName($r->tags,'dtlibera'); ?>" />								  
								<input type="hidden" id="dsobserv" name="dsobserv" value="<? echo getByTagName($r->tags,'dsobserv'); ?>" />								  
								<input type="hidden" id="nmopedev" name="nmopedev" value="<? echo getByTagName($r->tags,'nmopedev'); ?>" />								  
								  
						</td>
						<td><span><? echo getByTagName($r->tags,'cdbanchq'); ?></span>
							      <? echo getByTagName($r->tags,'cdbanchq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdagechq'); ?></span>
							      <? echo getByTagName($r->tags,'cdagechq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrddigc1'); ?></span>
							      <? echo getByTagName($r->tags,'nrddigc1'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctachq'); ?></span>
							      <? echo getByTagName($r->tags,'nrctachq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrddigc2'); ?></span>
							      <? echo getByTagName($r->tags,'nrddigc2'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrcheque'); ?></span>
							      <? echo getByTagName($r->tags,'nrcheque'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrddigc3'); ?></span>
							      <? echo getByTagName($r->tags,'nrddigc3'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlcheque'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlcheque')); ?>
						</td>
					</tr>
			<? } ?>	
			</tbody>
		</table>
	</div>
	
	</fieldset>

	<div id="complemento">
	
		<div id="linha1">
		<ul class="complemento">
		<li>Pesquisa:</li>
		<li id="dspesqui"></li>
		<li><? echo utf8ToHtml('Situação:'); ?></li>
		<li id="dssitchq"></li>
		</ul>
		</div>

		<div id="linha2">
		<ul class="complemento">
		<li>CMC-7:</li>
		<li id="dsdocmc7"></li>
		</ul>
		</div>

		<div id="linha3">
		<ul class="complemento">
		<li>Bordero:</li>
		<li id="nrborder"></li>
		<li>Contrato:</li>
		<li id="nrctrlim"></li>
		</ul>
		</div>
		
		<div id="linha4">
		<ul class="complemento">
		<li>Liberar para:</li>
		<li id="dtlibera"></li>
		<li id="dsobserv"></li>
		</ul>
		</div>
		
		<div id="linha5">
		<ul class="complemento">
		<li id="nmopedev"></li>
		</ul>
		</div>

	</div>	
	
</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>



