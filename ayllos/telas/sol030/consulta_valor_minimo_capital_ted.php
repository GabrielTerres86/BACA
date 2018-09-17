<?php
/*!
 * FONTE        : consulta_valor_minimo_capital_ted.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Julho/2017
 * OBJETIVO     : Responsável por apresentar o valor minimo referente a TED de capital
 * --------------
 * ALTERAÇÕES   :  
 *
 */
?>

<?php

    session_start();
    require_once('../../includes/config.php');
    require_once('../../includes/funcoes.php');
    require_once('../../includes/controla_secao.php');
    require_once('../../class/xmlfile.php');
    isPostMethod();

    // Carrega permissões do operador
    require_once('../../includes/carrega_permissoes.php');

    $cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';

    if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {

        exibirErro('error',$msgError,'Alerta - Ayllos','');
    }
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados/>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SOL030", "BUSCA_VALOR_MINIMO_CAPITAL_TED", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjValorMinimo = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjValorMinimo->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjValorMinimo->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
							
	}
	
	$registros = $xmlObjValorMinimo->roottag->tags[0]->tags[0];
	
?>		 
 
 <form id="frmValorMinimoCapital" name="frmValorMinimoCapital" class="formulario">
	
	<fieldset id="fsetValorMinimoCapital" name="fsetValorMinimoCapital" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Valor m&iacute;nimo"; ?></legend>
		
		<label for="vlminimo"><? echo utf8ToHtml('Valor M&iacute;nimo:') ?></label>
		<input type="text" id="vlminimo" name="vlminimo" value="<?echo getByTagName($registros->tags,'vlminimo');?>"/>
		
		<br style="clear:both" />
	
	</fieldset>	
		
</form>

<div id="divBotoesValorMinimoCapital" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
	<a href="#" class="botao" id="btConcluir" onClick="showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarValorMinimoTedCapital();','$(\'#btVoltar\',\'#divBotoesValorMinimoCapital\').focus();','sim.gif','nao.gif');return false;" >Alterar</a>
	
</div>

<script type="text/javascript">
	
	formataValorMinimoCapital();
	
</script>



