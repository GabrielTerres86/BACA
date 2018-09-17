<?php
    /*
     * FONTE        : form_exporta_arquivo.php
     * CRIAÇÃO      : Lucas Lombardi
     * DATA CRIAÇÃO : 25/07/2016
     * OBJETIVO     : Tela Bloquear Carga.
     * --------------
     * ALTERAÇÕES   : 
     * --------------
     */
	
    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');	
    require_once('../../class/xmlfile.php');
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	
    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',true);
	}
	
//    // Monta o xml de requisicao
//	$xml  = "";
//	$xml .= "<Root>";
//	$xml .= " <Dados>";
//	$xml .= "  <cddopcao>".$cddopcao."</cddopcao>";
//	$xml .= " </Dados>";
//	$xml .= "</Root>";
//
//    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
//	$xmlResult = mensageria($xml, "TELA_IMPSIM", "IMPSIM_EXPORTA_ARQUIVO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
//	$xmlObjeto = getObjectXML($xmlResult);
//
//	$cargas = $xmlObjeto->roottag->tags[0]->tags;
//	$qtregist = $xmlObjeto->roottag->tags[1]->cdata;
	
?>
<form id="frmImportaArquivo" name="frmImportaArquivo" class="formulario">
	<div style="margin-top:10px;"></div>
	<div id="divImportacaoSIM"></div>

	<div id="divBotoes" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
		<a href="#" class="botao" id="btVoltar">Voltar</a>
		<a href="#" class="botao" id="btExportar">Exportar</a>
	</div>

</form>

<script type="text/javascript">
    $('#btExportar', '#frmImportaArquivo').unbind('click').bind('click', function() {
        exportarArquivo();
    });
</script>