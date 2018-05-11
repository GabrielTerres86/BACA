<?
/*!
 * FONTE        : imunidade_tributaria.php
 * CRIAÇÃO      : Lucas R (CECRED)
 * DATA CRIAÇÃO : Julho/2013
 * OBJETIVO     : Mostrar rotina de imunidade tributaria da tela CONTAS
 * --------------
 * ALTERAÇÕES   : 20/09/2013 - Corrigindo os campos cddentid e cdsitcad
							   para exibir os dados que vem da base e mostrar corretamente
						       na tela (André Santos/ SUPERO)
							   
				  06/08/2015 - Reformulacao Cadastral (Gabriel-RKAM)		   
 * --------------
 */	
?>

<?
	session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();	
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');

	$flgcadas  = $_POST['flgcadas'];
	
	if (($msgError = validaPermissao($_POST["nmdatela"],$_POST["nmrotina"],'@',false)) <> '') {
		$metodo =  'proximaRotina();';
		exibirErro('error', $msgError ,'Alerta - Ayllos',$metodo,true);
	}
	
	// Carrega permissões do operador
	include("../../../includes/carrega_permissoes.php");	

	setVarSession("opcoesTela",$opcoesTela);

	$qtOpcoesTela = count($opcoesTela);
	
	// Carregas as opções da Rotina de Ativo/Passivo
	$flgAcesso   = (in_array("@", $glbvars["opcoesTela"]));
	$flgAlterar  = (in_array("A", $glbvars["opcoesTela"]));	
?>
<script>
	var dtmvtolt = '<? echo $glbvars['dtmvtolt']?>';
	var cdcooper = '<? echo $glbvars['cdcooper']?>';
</script>

<html>
    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">	
		<meta http-equiv="Pragma" content="no-cache">		
	</head>
<body>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Imunidade Tributária</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina(divRotina);return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%"  border="0" cellspacing="0" cellpadding="0">
							<tr>
								
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoOpcao"></div>
								</td>
							</tr>
												
						</table>			    
					</td> 
					
				</tr>
			</table>
		</td>
	</tr>
</table>
</body>		
</html>	

<script type="text/javascript">	
	var flgAlterar   = "<? echo $flgAlterar;   ?>";
	var qtOpcoesTela = "<? echo $qtOpcoesTela; ?>";		
	var flgcadas     = "<? echo $flgcadas;     ?>";
	
	exibeRotina(divRotina);	
	
	acessaOpcaoAba("<? echo $qtOpcoesTela ?>",0,"<? echo $opcoesTela[0]; ?>");	
</script>