<? 
/* !
 * FONTE        : form_opcao_s.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 13/03/2018
 * OBJETIVO     : Formulario que apresenta a consulta da opcao S da tela TITCTO
 * --------------
 * ALTERACOES   :
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
		<legend> <? echo utf8ToHtml('Conciliação Contabil'); ?> </legend>

		<div class="tipo_cobranca">
            <label for="tpcobran">Tipo de Cobran&ccedil;a</label>
            <select  id="tpcobran" name="tpcobran">
                <option value="T" <?php echo $tpcobran == 'T' ? 'selected' : '' ?>>Todos</option>
                <option value="R" <?php echo $tpcobran == 'R' ? 'selected' : '' ?>>Cobran&ccedil;a Registrada</option>
                <option value="S" <?php echo $tpcobran == 'S' ? 'selected' : '' ?>>Cobran&ccedil;a S/ Registro</option>
            </select>
        </div>

		<label for="dsvencto">Saldo Contabil em:</label>
		<label for="dtvencto"></label>
		<input type="text" id="dtvencto" name="dtvencto" value="<?php echo $dtvencto ?>" />
		<a href="#" class="botao" id="btnOk3">Ok</a>

		<br style="clear:both" /><br />

		<label for="lqtdedas">Qtde.</label>
		<label for="lvalores">Valor</label>

		<br />
		
		<label for="dssldant">Saldo Anterior:</label>
		<label for="qtsldant"></label>
		<input type="text" id="qtsldant" name="qtsldant" value="<?php echo getByTagName($dados,'qtsldant') ?>" />
		<label for="vlsldant"></label>
		<input type="text" id="vlsldant" name="vlsldant" value="<?php echo getByTagName($dados,'vlsldant') ?>" />
		
		<br />
		
		<label for="dstitulo">T&iacute;tulos Recebidos:</label>
		<label for="qttitulo"></label>
		<input type="text" id="qttitulo" name="qttitulo" value="<?php echo getByTagName($dados,'qttitulo') ?>" />
		<label for="vltitulo"></label>
		<input type="text" id="vltitulo" name="vltitulo" value="<?php echo getByTagName($dados,'vltitulo') ?>" />


		<br />
		
		<label for="dsvencid">Vencimentos no dia:</label>
		<label for="qtvencid"></label>
		<input type="text" id="qtvencid" name="qtvencid" value="<?php echo getByTagName($dados,'qtvencid') ?>" />
		<label for="vlvencid"></label>
		<input type="text" id="vlvencid" name="vlvencid" value="<?php echo getByTagName($dados,'vlvencid') ?>" />

		<br />
		
		<label for="dsderesg">T&iacute;tulos Resgatados:</label>
		<label for="qtderesg"></label>
		<input type="text" id="qtderesg" name="qtderesg" value="<?php echo getByTagName($dados,'qtderesg') ?>" />
		<label for="vlderesg"></label>
		<input type="text" id="vlderesg" name="vlderesg" value="<?php echo getByTagName($dados,'vlderesg') ?>" />

		<br style="clear:both" /><br />
		
		<label for="dscredit">SALDO ATUAL:</label>
		<label for="qtcredit"></label>
		<input type="text" id="qtcredit" name="qtcredit" value="<?php echo getByTagName($dados,'qtcredit') ?>" />
		<label for="vlcredit"></label>
		<input type="text" id="vlcredit" name="vlcredit" value="<?php echo getByTagName($dados,'vlcredit') ?>" />

	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


