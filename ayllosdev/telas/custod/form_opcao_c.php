<?php 
/*!
 * FONTE        : form_opcao_c.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 30/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao C da tela CUSTOD
 * --------------
 * ALTERAÇÕES   : 01/08/2016 - Corrigi o uso desnecessario da funcao session_start. SD 491672 (Carlos R.)
 *				  16/12/2016 - Alterações referentes ao projeto 300. (Reinert) 
 *
 *				  16/07/2019 - Alterações referentes a RITM0021707.	(Daniel Lombardi Mout'S)
 * --------------
 */
 
 	@session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	include('form_cabecalho.php');
	
	$nrdconta = (isset($nrdconta)) ? formataContaDV($nrdconta) : 0;
	$nmprimtl = (isset($nmprimtl)) ? $nmprimtl : '';
	$dtcusini = (isset($dtcusini)) ? $dtcusini : '';
	$dtcusfim = (isset($dtcusfim)) ? $dtcusfim : '';
	$tpcheque = (isset($tpcheque)) ? $tpcheque : '';
	$cdagenci = (isset($cdagenci)) ? $cdagenci : 0;
	$nrdolote = (isset($nrdolote)) ? $nrdolote : 0;
	$dtlibini = (isset($dtlibini)) ? $dtlibini : '';
	$dtlibfim = (isset($dtlibfim)) ? $dtlibfim : '';
	$dsdocmc7 = (isset($dsdocmc7)) ? $dsdocmc7 : '';
	$nriniseq = (isset($nriniseq)) ? $nriniseq : 1;
	$nrregist = (isset($nrregist)) ? $nrregist : 50;
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

	<fieldset>
		<legend> Filtros </legend>	
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo $nrdconta ?>"/>
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>
		
		<input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
		
		<br/>

		<label for="dtcusini">Data Cust&oacute;dia:</label>
		<input type="text" id="dtcusini" name="dtcusini" value="<?php echo  $dtcusini ?>"/>
		
		<label for="dtcusfim">At&eacute;:</label>
		<input type="text" id="dtcusfim" name="dtcusfim" value="<?php echo $dtcusfim ?>"/>

		<label for="tpcheque">Situa&ccedil;&atilde;o Cheque:</label>
		<select id="tpcheque" name="tpcheque">
		<option value="1" <?php echo $tpcheque == '1' ? 'selected' : '' ?>>1-Resgatado</option>
		<option value="2" <?php echo $tpcheque == '2' ? 'selected' : '' ?>>2-Descontado</option>
		<option value="3" <?php echo $tpcheque == '3' ? 'selected' : '' ?>>3-Custodiado</option>
		<option value="4" <?php echo $tpcheque == '4' ? 'selected' : '' ?>>4-Todos</option>
		</select>
		
		<label for="cdagenci">PA:</label>
		<input type="text" id="cdagenci" name="cdagenci" value="<?php echo $cdagenci ?>"/>
		
		<label for="nrdolote">Lote:</label>
		<input type="text" id="nrdolote" name="nrdolote" value="<?php echo $nrdolote ?>"/>

		<br/>
		
		<label for="dtlibini">Data Libera&ccedil;&atilde;o:</label>
		<input type="text" id="dtlibini" name="dtlibini" value="<?php echo  $dtlibini ?>"/>
		
		<label for="dtlibfim">At&eacute;:</label>
		<input type="text" id="dtlibfim" name="dtlibfim" value="<?php echo $dtlibfim ?>"/>	

		<label for="dsdocmc7">CMC-7:</label>
		<input type="text" id="dsdocmc7" name="dsdocmc7" value="<?php echo $dsdocmc7 ?>" />

		<a href="#" class="botao" id="btnOkC" onclick="btnContinuar(); return false;">Ok</a>

		<br  />
			
	</fieldset>		

	<fieldset>
	<legend> Cheques </legend>
		<div class="divRegistros">	
			<table class="tituloRegistros">
				<thead>
					<tr>
						<th>Liberar</th>
						<th>Banco</th>
						<th>Ag&ecirc;ncia</th>
						<th>Conta</th>
						<th>Cheque</th>
						<th>Valor</th>
						<th>Tipo Cheque</th>
						<th>PA</th>
						<th>Lote</th>
						<th>Data Cust&oacute;dia</th>
						<th>Data Resgate/<br>Devolu&ccedil;&atilde;o</th>						
						<th>Operador Resgate</th>
					</tr>
				</thead>
				<tbody>
					<?php
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
							<td><span><? echo getByTagName($r->tags,'tpdevolu'); ?></span>
									  <? echo getByTagName($r->tags,'tpdevolu'); ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'cdagenci'); ?></span>
									  <? echo getByTagName($r->tags,'cdagenci'); ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'nrdolote'); ?></span>
									  <? echo getByTagName($r->tags,'nrdolote'); ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'dtmvtolt'); ?></span>
									  <? echo getByTagName($r->tags,'dtmvtolt'); ?>
							</td>
							<td><span><? echo dataParaTimestamp(getByTagName($r->tags,'dtdevolu')); ?></span>
									  <? echo getByTagName($r->tags,'dtdevolu'); ?>
							</td>
							<td><span><? echo getByTagName($r->tags,'cdopedev'); ?></span>
									  <? echo getByTagName($r->tags,'cdopedev'); ?>
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
</form>		
<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


<script type="text/javascript">

    $('a.paginacaoAnt').unbind('click').bind('click', function() {
        controlaOperacao('CCC', <?php echo "'" . ($nriniseq - $nrregist) . "','" . $nrregist . "'"; ?>);
    });

    $('a.paginacaoProx').unbind('click').bind('click', function() {
        controlaOperacao('CCC', <?php echo "'" . ($nriniseq + $nrregist) . "','" . $nrregist . "'"; ?>);
    });
	
</script>
