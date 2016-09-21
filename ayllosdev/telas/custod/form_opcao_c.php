<? 
/*!
 * FONTE        : form_opcao_c.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 30/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao C da tela CUSTOD
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

	<fieldset>
		<legend> Associado </legend>	
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="tpcheque">Tipo:</label>
		<select id="tpcheque" name="tpcheque">
		<option value="1" <?php echo $tpcheque == '1' ? 'selected' : '' ?>>1-Resgatado</option>
		<option value="2" <?php echo $tpcheque == '2' ? 'selected' : '' ?>>2-Descontado</option>
		<option value="3" <?php echo $tpcheque == '3' ? 'selected' : '' ?>>3-Custodiado</option>
		<option value="4" <?php echo $tpcheque == '4' ? 'selected' : '' ?>>4-Todos</option>
		</select>

		<label for="dtlibini"><? echo utf8ToHtml('Data Início:') ?></label>
		<input type="text" id="dtlibini" name="dtlibini" value="<?php echo  $dtlibini ?>"/>
		
		<label for="dtlibfim">Data Final:</label>
		<input type="text" id="dtlibfim" name="dtlibfim" value="<?php echo $dtlibfim ?>"/>
		
		<br  />
		
		<label for="nmprimtl">Titular:</label>
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
		
	</fieldset>		


	<fieldset>
	<legend> Cheques </legend>

	<div class="divRegistros">	
		<table class="tituloRegistros">
			<thead>
				<tr>
					<th><? echo utf8ToHtml('Liberar'); ?></th>
					<th><? echo utf8ToHtml('Bco'); ?></th>
					<th><? echo utf8ToHtml('Ag.');  ?></th>
					<th><? echo utf8ToHtml('Conta');  ?></th>
					<th><? echo utf8ToHtml('Cheque');  ?></th>
					<th><? echo utf8ToHtml('Valor');  ?></th>
					<th><? echo utf8ToHtml('Data');  ?></th>
					<th><? echo utf8ToHtml('Tp.Chq.');  ?></th>
					<th><? echo utf8ToHtml('Operador');  ?></th>
				</tr>
			</thead>
			<tbody>
				<?
				foreach ( $registro as $r ) { 
				?>
					<tr>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtlibera')); ?></span>
							      <? echo getByTagName($r->tags,'dtlibera'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdbanchq'); ?></span>
							      <? echo getByTagName($r->tags,'cdbanchq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdagechq'); ?></span>
							      <? echo getByTagName($r->tags,'cdagechq'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrctachq'); ?></span>
							      <? echo mascara(getByTagName($r->tags,'nrctachq'), '###.###.###.#'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'nrcheque'); ?></span>
							      <? echo getByTagName($r->tags,'nrcheque'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'vlcheque'); ?></span>
							      <? echo formataMoeda(getByTagName($r->tags,'vlcheque')); ?>
						</td>
						<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtdevolu')); ?></span>
							      <? echo getByTagName($r->tags,'dtdevolu'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'tpdevolu'); ?></span>
							      <? echo getByTagName($r->tags,'tpdevolu'); ?>
						</td>
						<td><span><? echo getByTagName($r->tags,'cdopedev'); ?></span>
							      <? echo getByTagName($r->tags,'cdopedev'); ?>
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