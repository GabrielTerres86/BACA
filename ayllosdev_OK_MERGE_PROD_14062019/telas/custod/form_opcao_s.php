<? 
/*!
 * FONTE        : form_opcao_s.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 30/01/2012 
 * OBJETIVO     : Formulario que apresenta a opcao S da tela CUSTOD
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
	
		<legend> <? echo utf8ToHtml('Saldo'); ?> </legend>
	
		<label for="dsdopcao">Saldos:</label>
		<select id="dsdopcao" name="dsdopcao">
		<option value="1" <?php echo $dsdopcao == '1' ? 'selected' : '' ?> >Cooper</option>
		<option value="2" <?php echo $dsdopcao == '2' ? 'selected' : '' ?> >Demais Associados</option>
		<option value="3" <?php echo $dsdopcao == '3' ? 'selected' : '' ?> >Conta/dv</option>
		<option value="4" <?php echo $dsdopcao == '4' ? 'selected' : '' ?> >Total Geral</option>
		</select>
		
		<label for="nrdconta">Conta:</label>
		<input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>" />
		<a><img src="<? echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

		<label for="dtlibera">Saldo Contabil em:</label>
		<input type="text" id="dtlibera" name="dtlibera" value="<?php echo $dtlibera ?>" />
		<a href="#" class="botao" id="btnOk3">Ok</a>
	
	</fieldset>

	<fieldset>
		<legend> <? echo utf8ToHtml('Saldo Contabil'); ?> </legend>

		
		<label for="lqtdedas">Qtde.</label>
		<label for="lvalores">Valor</label>

		<br />
		
		<label for="dssldant">Saldo Anterior:</label>
		<label for="qtsldant"></label>
		<input type="text" id="qtsldant" name="qtsldant" value="<?php echo getByTagName($dados,'qtsldant') ?>" />
		<label for="vlsldant"></label>
		<input type="text" id="vlsldant" name="vlsldant" value="<?php echo getByTagName($dados,'vlsldant') ?>" />
		
		<br />
		
		<label for="dscheque">Cheques Recebidos:</label>
		<label for="qtcheque"></label>
		<input type="text" id="qtcheque" name="qtcheque" value="<?php echo getByTagName($dados,'qtcheque') ?>" />
		<label for="vlcheque"></label>
		<input type="text" id="vlchequx" name="vlchequx" value="<?php echo getByTagName($dados,'vlcheque') ?>" />


		<br />
		
		<label for="dslibera">Liberados no dia:</label>
		<label for="qtlibera"></label>
		<input type="text" id="qtlibera" name="qtlibera" value="<?php echo getByTagName($dados,'qtlibera') ?>" />
		<label for="vllibera"></label>
		<input type="text" id="vllibera" name="vllibera" value="<?php echo getByTagName($dados,'vllibera') ?>" />

		<br />
		
		<label for="dschqdev">Cheques Resgatados:</label>
		<label for="qtchqdev"></label>
		<input type="text" id="qtchqdev" name="qtchqdev" value="<?php echo getByTagName($dados,'qtchqdev') ?>" />
		<label for="vlchqdev"></label>
		<input type="text" id="vlchqdev" name="vlchqdev" value="<?php echo getByTagName($dados,'vlchqdev') ?>" />
		
		<br />
		
		<label for="dschqdsc">Cheques Descontados:</label>
		<label for="qtchqdsc"></label>
		<input type="text" id="qtchqdsc" name="qtchqdsc" value="<?php echo getByTagName($dados,'qtchqdsc') ?>" />
		<label for="vlchqdsc"></label>
		<input type="text" id="vlchqdsc" name="vlchqdsc" value="<?php echo getByTagName($dados,'vlchqdsc') ?>" />
		
		<br style="clear:both" /><br />
		
		<label for="dscredit">SALDO ATUAL:</label>
		<label for="qtcredit"></label>
		<input type="text" id="qtcredit" name="qtcredit" value="<?php echo getByTagName($dados,'qtcredit') ?>" />
		<label for="vlcredit"></label>
		<input type="text" id="vlcredit" name="vlcredit" value="<?php echo getByTagName($dados,'vlcredit') ?>" />

		<br style="clear:both" /><br />
		
		<label for="dschqcop"><?php echo getByTagName($dados,'dschqcop') ?></label>
		<label for="qtchqcop"></label>
		<input type="text" id="qtchqcop" name="qtchqcop" value="<?php echo getByTagName($dados,'qtchqcop') ?>" />
		<label for="vlchqcop"></label>
		<input type="text" id="vlchqcop" name="vlchqcop" value="<?php echo getByTagName($dados,'vlchqcop') ?>" />

		<br />
		
		<label for="dschqban">Cheques de Outros Bancos:</label>
		<label for="qtchqban"></label>
		<input type="text" id="qtchqban" name="qtchqban" value="<?php echo getByTagName($dados,'qtchqban') ?>" />
		<label for="vlchqban"></label>
		<input type="text" id="vlchqban" name="vlchqban" value="<?php echo getByTagName($dados,'vlchqban') ?>" />
		
	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


