<?php
    /*
     * FONTE        : form_importa_arquivo.php
     * CRIAÇÃO      : Lucas Lombardi
     * DATA CRIAÇÃO : 19/07/2016
     * OBJETIVO     : Formulario de Regras.
     * --------------
     * ALTERAÇÕES   :
     * --------------
     */

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');

	$cddopcao   = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
?>
<form id="frmImportaArquivo" name="frmImportaArquivo" class="formulario">
	<div style="margin-top:10px;"></div>

    <label for="nome_arquivo">Arquivo:</label>
	<input type="file" id="nome_arquivo" name="nome_arquivo"  size=100 style="height: 25px;" class="campo" style="margin-bottom: 10px">

    <fieldset style="font-weight: bold;">
        <div>Exemplo layout arquivo .CSV</div><br />
        <div>Cooper; Conta; CNPJ; Regime Tributário</div>
        <div><? echo $glbvars["cdcooper"]; ?>; 10847; 99999999999999; 1</div>
        <div><? echo $glbvars["cdcooper"]; ?>; 20210; 99999999999999; 2</div>
    </fieldset>

	<div id="divBotoes" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btConcluir">Concluir</a>
	</div>

</form>