<? 
/* !
 * FONTE        : form_opcao_f.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 12/03/2018
 * OBJETIVO     : Formulario que apresenta a consulta da opcao F da tela TITCTO
 * --------------
 * ALTERACOES   : 23/05/2018 - Insert da validação da permissão para tela - Vitor Shimada Assanuma (GFT)
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
	
	if (($msgError = validaPermissao($glbvars['nmdatela'], $glbvars['nmrotina'], $_POST['cddopcao'], false)) <> '') {
	    exibirErro('error', $msgError, 'Alerta - Ayllos', 'estadoInicial()', true);
	}
?>

<form id="frmOpcao" class="formulario" onSubmit="return false;">

    <fieldset>
        <legend> Associado </legend>	
        
        <label for="nrdconta">Conta:</label>
        <input type="text" id="nrdconta" name="nrdconta" value="<?php echo formataContaDV($nrdconta) ?>"/>
        <a><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif" /></a>

        <label for="nrcpfcgc">CPF/CNPJ:</label>
        <input type="text" id="nrcpfcgc" name="nrcpfcgc" value="<?php echo $nrcpfcgc ?>"/>

        <label for="nmprimtl">Titular:</label>
        <input type="text" id="nmprimtl" name="nmprimtl" value="<?php echo $nmprimtl ?>" />
        
        <div class="tipo_cobranca">
            <label for="tpcobran">Tipo de Cobran&ccedil;a</label>
            <select  id="tpcobran" name="tpcobran">
                <option value="T" <?php echo $tpcobran == 'T' ? 'selected' : '' ?>>Todos</option>
                <option value="R" <?php echo $tpcobran == 'R' ? 'selected' : '' ?>>Cobran&ccedil;a Registrada</option>
                <option value="S" <?php echo $tpcobran == 'S' ? 'selected' : '' ?>>Cobran&ccedil;a S/ Registro</option>
            </select>
        </div>
    </fieldset>
	<fieldset>
		<legend> Registros </legend>
		<label for="dtvencto">Data de Vencimento:</label>
		<input type="text" id="dtvencto" name="dtvencto" value="<?php echo $dtvencto ?>" />
		<a href="#" class="botao" id="btnOk2">Ok</a>
		
		<br style="clear:both" /><br />

		<label for="lqtdedas">Qtde.</label>
		<label for="lvalores">Valor</label>
		
		<br />

		<label for="dstitulo">Titulos Recebidos:</label>
		<label for="qttitulo"></label>
		<input type="text" id="qttitulo" name="qttitulo" value="<?php echo getByTagName($dados->tags,'QTTITULO') ?>" />
		<label for="vltitulo"></label>
		<input type="text" id="vltitulo" name="vltitulo" value="<?php echo getByTagName($dados->tags,'VLTITULO') ?>" />
		
		<br />
		
		<label for="dsderesg">Titulos Resgatados:</label>
		<label for="qtderesg"></label>
		<input type="text" id="qtderesg" name="qtderesg" value="<?php echo getByTagName($dados->tags,'QTDERESG') ?>" />
		<label for="vlderesg"></label>
		<input type="text" id="vlderesg" name="vlderesg" value="<?php echo getByTagName($dados->tags,'VLDERESG') ?>" />

		<br />
		
		<label for="dsdpagto">Titulos Pagos</label>
		<label for="qtdpagto"></label>
		<input type="text" id="qtdpagto" name="qtdpagto" value="<?php echo getByTagName($dados->tags,'QTDPAGTO') ?>" />
		<label for="vldpagto"></label>
		<input type="text" id="vldpagto" name="vldpagto" value="<?php echo getByTagName($dados->tags,'VLDPAGTO') ?>" />

		<br style="clear:both" /><br />
				
		<label for="dscredit">Valor a LIBERAR:</label>
		<label for="qtcredit"></label>
		<input type="text" id="qtcredit" name="qtcredit" value="<?php echo getByTagName($dados->tags,'QTCREDIT') ?>" />
		<label for="vlcredit"></label>
		<input type="text" id="vlcredit" name="vlcredit" value="<?php echo getByTagName($dados->tags,'VLCREDIT') ?>" />
		
	</fieldset>

</form>

<div id="divBotoes" style="padding-bottom:10px">
	<a href="#" class="botao" id="btVoltar" onclick="btnVoltar(); return false;">Voltar</a>
	<a href="#" class="botao" onclick="btnContinuar(); return false;" >Prosseguir</a>
</div>


