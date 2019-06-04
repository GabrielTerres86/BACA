<? 
/*!
 * FONTE        : form_frase_desenvolvedor.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Formulario para mostrar a frase do desenvolvedor.
 */
session_start();
	
// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");		
require_once("../../includes/controla_secao.php");

$dsfrase  		 = ((isset($_POST['dsfrase'])) 		   ? $_POST['dsfrase'] 		   : $dsfrase);
$cddopcao 		 = ((isset($_POST['cddopcao'])) 	   ? $_POST['cddopcao'] 	   : $cddopcao);
$cddesenvolvedor = ((isset($_POST['cddesenvolvedor'])) ? $_POST['cddesenvolvedor'] : $cddesenvolvedor);
$dsuuid 		 = ((isset($_POST['dsuuid'])) 		   ? $_POST['dsuuid'] 		   : '');
?>
<form method="post" name="frmFraseDesenvolvedor" id="frmFraseDesenvolvedor" class="formulario">
	<div id="divDados" class="clsCampos">
		<fieldset style="padding: 5px">
			<legend><? echo utf8ToHtml('Frase do Desenvolvedor');?></legend>
			<div style="display: block;margin: 0 auto 10px auto;width: 285px;text-align: center;">
				<input type="text" class="campo campoTelaSemBorda" id="dsfrase" name="dsfrase" style="text-align: center;height: auto;font-size: 20px;font-weight: bold;padding: 5px;float: none;" value="<?php echo $dsfrase;?>" disabled />
				<br style="clear:both"/>
				<? if ($cddopcao == "E" || $cddopcao == "C"){ ?>
				<a class="botaoDesativado" id="btGerarNovaFrase" href="#" onclick="return false;" style="margin: 10px 5px;float: none;">Gerar nova frase</a>
				<a class="botaoDesativado" id="btEnviarFraseEmail" href="#" onclick="return false;" style="margin: 10px 5px;float: none;">Enviar via e-mail</a>
				<? }else{ ?>
				<a class="<?=(($cddesenvolvedor>0 || $cddopcao == "I")?'botao':'botaoDesativado')?>" id="btGerarNovaFrase" href="#" onclick="<?=(($cddesenvolvedor>0 || $cddopcao == "I")?'gerarNovaFrase(false);':'')?>return false;" style="margin: 10px 5px;float: none;">Gerar nova frase</a>
				<a class="<?=(($cddesenvolvedor>0 || $cddopcao == "I")?'botao':'botaoDesativado')?>" id="btEnviarFraseEmail" href="#" onclick="<?=(($cddesenvolvedor>0 || $cddopcao == "I")?'enviarFraseViaEmail(false);':'')?>return false;" style="margin: 10px 5px;float: none;">Enviar via e-mail</a>
				<? } ?>
			</div>
		</fieldset>
	</div>
</form>
<?php include("form_chave_acesso.php"); ?>