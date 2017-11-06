<?php
/*!
 * FONTE        : consulta_prazo_desligamento.php                    Última alteração:
 * CRIAÇÃO      : Jonata (RKAM)
 * DATA CRIAÇÃO : Junho/2017
 * OBJETIVO     : Responsável por consultar o prazo de desligamento
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

	$cdoperac = (isset($_POST["cdoperac"])) ? $_POST["cdoperac"] : 0;
	$tpprazo  = (isset($_POST["tpprazo"])) ? $_POST["tpprazo"] : 0;
	$qtddias  = (isset($_POST["qtddias"])) ? $_POST["qtddias"] : 0;
	$flgautori  = (isset($_POST["flgautori"])) ? $_POST["flgautori"] : 0;
	
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "   <Dados/>";
	$xml .= "</Root>";
		
	// Executa script para envio do XML	
	$xmlResult = mensageria($xml, "TELA_SOL030", "BUSCA_PRAZO_DESLIGAMENTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	$xmlObjPrazo = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjPrazo->roottag->tags[0]->name) == "ERRO") {
	
		$msgErro  = $xmlObjPrazo->roottag->tags[0]->tags[0]->tags[4]->cdata;
			 
		exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','estadoInicial();',false);		
							
	}
	
	$registros = $xmlObjPrazo->roottag->tags[0]->tags[0];
	
		
?>		 
 
 <form id="frmPrazoDesligamento" name="frmPrazoDesligamento" class="formulario">
	
	<fieldset id="fsetPrazoDesligamento" name="fsetPrazoDesligamento" style="padding:0px; margin:0px; padding-bottom:10px;">
		
		<legend><? echo "Prazo para desligamento"; ?></legend>
		
		<input name="tpprazo" id="flgNoAto" type="radio" class="radio" style="height: 20px; margin: 3px 5px 3px 250px;" />
		<label for="flgNoAto" class="radio" >No Ato</label>
		
		<br style="clear:both" />
		
		<input name="tpprazo" id="flgAposAgo" type="radio" class="radio" style="height: 20px; margin: 3px 5px 3px 250px;"/>
		<label for="flgAposAgo" class="radio"><? echo utf8ToHtml('Ap&oacute;s AGO') ?></label>
		
		<br />
		
		<label for="qtddias"><? echo utf8ToHtml('Quantidade de dias:') ?></label>
		<input type="text" id="qtddias" name="qtddias" value="<?echo getByTagName($registros->tags,'qtddias');?>"/>
		
		<br style="clear:both" />
	
	</fieldset>
	
</form>

<div id="divBotoesPrazoDesligamento" class="rotulo-linha" style="margin-top:25px; margin-bottom :10px; text-align: center;">
	
	<a href="#" class="botao" id="btVoltar" onClick="estadoInicial(); return false;">Voltar</a>
	<a href="#" class="botao" id="btAlterar" onClick="showConfirmacao('Deseja confirmar a opera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','alterarPrazoDesligamento();','$(\'#btVoltar\',\'#divBotoesPrazoDesligamento\').focus();','sim.gif','nao.gif');return false;" >Alterar</a>
	
</div>

<script type="text/javascript">
	
	<?IF(getByTagName($registros->tags,'tpprazo') == '1' ){?>	
	
		$('#flgNoAto','#frmPrazoDesligamento').prop("checked",true); 
		
	<?}else IF(getByTagName($registros->tags,'tpprazo') == '2' ){?>
	
		$('#flgAposAgo','#frmPrazoDesligamento').prop("checked",true);
		
	<?}?>
	
	formataPrazoDesligamento();
	
</script>



