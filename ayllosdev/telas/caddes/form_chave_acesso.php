<? 
/*!
 * FONTE        : form_chave_acesso.php
 * CRIAÇÃO      : Andrey Formigari - Supero
 * DATA CRIAÇÃO : Fevereiro/2019
 * OBJETIVO     : Formulario para mostrar as credenciais da API.
 */

session_start();
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	

$dschave  		  = ((isset($_POST['dschave']))  ? $_POST['dschave']  : $dschave);
$cddopcao 	      = ((isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : $cddopcao);
$dsusuario_portal = ((isset($_POST['dsusuario_portal'])) ? $_POST['dsusuario_portal'] : $dsusuario_portal);
?>
<form method="post" name="frmChaveAcesso" id="frmChaveAcesso" class="formulario">
	<div id="divDados" class="clsCampos">
		<?php
			// Verifica permissão para Gerenciar a UUID
			if (validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'U',false) == ''){
		?>
		<fieldset style="padding: 5px">
			<legend><? echo utf8ToHtml('Acesso API');?></legend>
			
			<label for="dsuser_portal" style="width: 145px;"><? echo utf8ToHtml('Usuário Portal API:');?></label>
			<input type="text" class="campo" id="dsuser_portal" name="dsuser_portal" style="width: 200px;" value="<?php echo $dsusuario_portal;?>" maxlength="50" />
			
			<br style="clear:both"/>
			
			<label for="dschave" style="width: 145px;padding: 3px 0;"><? echo utf8ToHtml('Chave de Acesso UUID:');?></label>
			<input type="text" class="campo campoTelaSemBorda" id="dschave" name="dschave" style="width: 446px;text-align: center;height: auto;font-size: 14px;font-weight: bold;padding: 5px;" value="<?php echo $dschave;?>" disabled />
			
			<br style="clear:both"/>
			
			<div style="display: block;margin: 0 auto 10px auto;width: 285px;text-align: center;">
				<!--
				<a class="<?=((($cddopcao=="A" || $cddopcao=="I") && $cddesenvolvedor>0 && $dschave=="")?'botao':'botaoDesativado')?>" id="btGerarUUID" href="#" onclick="<?=((($cddopcao=="A" || $cddopcao=="I") && $cddesenvolvedor>0 && $dschave == "")?'gerarUUID(false);':'')?>return false;" style="margin: 10px 5px;float: none;">Gerar UUID</a>
				-->
				<a class="<?=(($cddopcao=="A" && $dschave!="")?'botao':'botaoDesativado')?>" id="btEnviarChaveEmail_1" href="#" onclick="<?=(($cddopcao=="A" && $dschave!="")?'enviarChaveViaEmail(false);':'')?>return false;" style="margin: 10px 5px;float: none;">Enviar via e-mail</a>
				<a class="botao" id="btEnviarChaveEmail_2" href="#" onclick="enviarChaveViaEmail(false);return false;" style="margin: 10px 5px;float: none;display: none;">Enviar via e-mail</a>
			</div>
		</fieldset>
		<?php } ?>
		<div id="divBotoes" style="margin-bottom: 10px;">
			<a class="botao" id="btVoltar" href="#" onclick="estadoInicial(); return false;">Voltar</a>
			
			<? if ($cddopcao == "E") {?>
			<a class="<?=(($cddesenvolvedor>0)?'botao':'botaoDesativado')?>" id="btConfirmar" href="#" onclick="<?=(($cddesenvolvedor>0)?'confirmaExcluirDesenvolvedor(false);':'')?>return false;">Excluir</a>
			<? } ?>
			
			<? if ($cddopcao == "A" && validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'U',false) == '') {?>
			<a class="<?=(($cddesenvolvedor>0)?'botao':'botaoDesativado')?>" id="btConfirmar" href="#" onclick="<?=(($cddesenvolvedor>0)?'confirmaCadastroDesenvolvedor(false);':'')?>return false;">Alterar</a>
			<? } ?>
		</div>
	</div>
</form>