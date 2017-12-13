<?php
    /*
     * FONTE        : form_importa_arquivo.php
     * CRIAÇÃO      : Diogo Carlassara
     * DATA CRIAÇÃO : 11/10/2017
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
<form id="frmImportaArquivo" name="frmImportaArquivo" class="formulario" enctype="multipart/form-data">
	<div style="margin-top:10px;"></div>

    <label for="nome_arquivo">Arquivo:</label>
	  <input type="file" id="nome_arquivo" name="nome_arquivo" style="height: 25px;" class="campo" style="margin-bottom: 10px">

    <fieldset style="font-weight: bold;">
        <div>Exemplo layout arquivo .CSV</div><br />
        <div>Cooper; CNPJ; Conta; Simples Nacional?</div>
        <div><? echo $glbvars["cdcooper"]; ?>; 99999999999999; 10847; N</div>
        <div><? echo $glbvars["cdcooper"]; ?>; 99999999999999; 20210; S</div>
    </fieldset>

	<div id="divBotoes" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btConcluir">Concluir</a>
	</div>

</form>