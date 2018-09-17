<? 
/*!
 * FONTE        : form_opcao_t.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 30/01/2012 
 * OBJETIVO     : Formulário que apresenta a opcao T da tela CUSTOD
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

	<?php include('form_associado.php') ?>

	<fieldset>
		<legend> Documentos a Pesquisar </legend>	
		
		<label for="cdbanchq">Banco:</label>
		<input type="text" id="cdbanchq" name="cdbanchq" value="<?php echo $cdbanchq ?>"/>
		
		<label for="nrcheque">Cheque:</label>
		<input type="text" id="nrcheque" name="nrcheque" value="<?php echo $nrcheque ?>" />
		
		<label for="vlcheque">Valor:</label>
		<input type="text" id="vlrchequ" name="vlrchequ" value="<?php echo $vlcheque ?>"/>
		
	</fieldset>		
	
	
	<fieldset>
	<legend> Cheques </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Liberação'); ?></th>
					<th><? echo utf8ToHtml('Pesquisa'); ?></th>
					<th><? echo utf8ToHtml('Bco');  ?></th>
					<th><? echo utf8ToHtml('Ag.');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo getByTagName($r->tags,'dtlibera'); ?></span>
							      <? echo getByTagName($r->tags,'dtlibera'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'pesquisa'); ?></span>
							      <? echo getByTagName($r->tags,'pesquisa'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdbanchq'); ?></span>
							      <? echo getByTagName($r->tags,'cdbanchq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdagechq'); ?></span>
							      <? echo getByTagName($r->tags,'cdagechq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctachq'); ?></span>
							      <? echo getByTagName($r->tags,'nrctachq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrcheque'); ?></span>
							      <? echo getByTagName($r->tags,'nrcheque'); ?>
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

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>

