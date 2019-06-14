<?php

	//************************************************************************//
	//*** Fonte: pede_senha.php                                            ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2008                 Última Alteração: 16/01/2018 ***//
	//***                                                                  ***//
	//*** Objetivo  : Montar o HTML para pedido de senha (Coordenador ou   ***//
	//***             Gerente)                                             ***//
	//***                                                                  ***//	 
	//*** Alterações: 15/10/2010 - Ajuste no script (visualizacao e botao  ***//
	//***                          de confirmacao) - (David).              ***//
	//***                                                                  ***//
	//***             17/03/2015 - Aumentar largura da tela (Jonata-RKAM)  ***//
	//***																   ***//
	//***			  29/07/2014 - Aumentado tamanho do campo cdoperad     ***//
	//***						   conforme solicitado no chamado 307064   ***//
	//***						   (Kelvin)                                ***//
	//***																   ***//
	//***			  16/01/2018 - Aumentado tamanho do campo de senha 	   ***//
	//***						   para 30 caracteres. (PRJ339 - Reinert)  ***//
	//***																   ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("config.php");
	require_once("funcoes.php");		
	require_once("controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nvopelib"]) || !isset($_POST["nmfuncao"]) || !isset($_POST["nmdivfnc"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	

	$nvopelib = $_POST["nvopelib"];	
	$nmfuncao = $_POST["nmfuncao"];	
	$nmdivfnc = $_POST["nmdivfnc"];	
	
	$dstpoper = $nvopelib == 1 ? "Operador" : $nvopelib == 2 ? "Coordenador" : "Gerente";
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo '<script type="text/javascript">';
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		echo '</script>';
		exit();
	}		
	
?>
<table width="330" border="0" cellpadding="0" cellspacing="0">	
	<tr>
		<td align="center">								
			<table border="0" width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td align="center">
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><?php echo strtoupper($dstpoper); ?> - Informe a senha para continuar</td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>						
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="tdConteudoF2">						
			<table border="0" width="100%" cellpadding="0" cellspacing="0">
				<tr>
					<td align="center">
						<form action="" method="post" name="frmSenhaCoordenador" id="frmSenhaCoordenador" onSubmit="return false;">
						<input type="hidden" name="nvopelib" id="nvopelib" value="<?php echo $nvopelib; ?>">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td class="txtNormalBold" height="23" align="right"><?php echo $dstpoper; ?>:&nbsp;</td>
								<td class="txtNormal"><input type="text" name="cdopelib" id="cdopelib" style="width: 100px;" class="campo" autocomplete="no" maxlength="10"></td>								
							</tr>
							<tr>
								<td class="txtNormalBold" height="23" align="right">Senha:&nbsp;</td>
								<td class="txtNormal"><input type="password" name="cddsenha" id="cddsenha" style="width: 100px;" class="campo" autocomplete="no" maxlength="30"></td>
							</tr>
						</table>
						</form>
					</td>
				</tr>
				<tr>
					<td height="3"></td>
				</tr>													
				<tr>
					<td align="center" height="30">
						<table border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td><input type="image" src="<?php echo $UrlImagens; ?>botoes/cancelar.gif" onClick="cancelaPedeSenhaCoordenador('<?php echo $nmdivfnc; ?>');return false;"></td>
								<td width="20"></td>
								<td><input type="image" id="btnSenhaCoordenador" src="<?php echo $UrlImagens; ?>botoes/continuar.gif" onClick="return false;"></td>
							</tr>
						</table>
					</td>
				</tr>										
			</table>				
		</td>
	</tr>			
</table>						
<script type="text/javascript">
$("#btnSenhaCoordenador").unbind("click");
$("#btnSenhaCoordenador").bind("click",function() {
	confirmaSenhaCoordenador("<?php echo str_replace('"',"'",$nmfuncao); ?>");
	return false;
});

$("#divUsoGenerico").css("visibility","visible");

// Centraliza o div na Tela
$("#divUsoGenerico").setCenterPosition();

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divUsoGenerico").css("z-index")));

$("#cdopelib","#frmSenhaCoordenador").focus();

</script>