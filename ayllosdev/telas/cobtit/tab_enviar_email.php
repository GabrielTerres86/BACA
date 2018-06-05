<?php
/* !
 * FONTE        : tab_enviar_email.php
 * CRIAÇÃO      : Vitor Shimada Assanuma
 * DATA CRIAÇÃO : 04.06.2018
 * OBJETIVO     : Rotina para envio de email.
 */
?>

<?php
session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();

function exibeErro($msgErro) {	
	echo 'hideMsgAguardo();';
	echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","");';
	exit();
}

?>

<form id="frmEnviarEmail" name="frmEnviarEmail" class="formulario" onSubmit="return false;" >

    <br style="clear:both" />		

    <label for="dsdemail"><?php echo utf8ToHtml('E-mail:') ?></label>
    <input type="text" id="dsdemail" class="campo" name="dsdemail" value="<?php echo $dsdemail == 0 ? '' : $dsdemail ?>" />	
    <a style="padding: 3px 0 0 3px;" href="#" onClick="pesquisaEmail(); return false;"><img src="<?php echo $UrlImagens; ?>geral/ico_lupa.gif"/></a>		

    <br style="clear:both" />		

</form>

<div id="divBotoesEnviarEmail" style="margin-bottom: 5px; text-align:center;" >
    <a href="#" class="botao" id="btVoltar"  	onClick="<?php echo 'fechaRotina($(\'#divRotina\')); '; ?> return false;">Voltar</a>
    <a href="#" class="botao" id="btEnviar"  	onClick="<?php echo 'confirmaEnvioEmail(); '; ?> return false;">Enviar</a>
</div>