<?php
/*!
 * FONTE        : dados_pessoais.php
 * CRIAÇÃO      : Gabriel (RKAM)
 * DATA CRIAÇÃO : 01/09/2015 
 * OBJETIVO     : Mostra rotina de Dados Pessoais da tela de CONTAS
 *
 * ALTERACOES   :  Correcao no uso da constante $opcoesTela. SD 479874. (Carlos R.)
 */	 

	session_start();	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	isPostMethod();	
		
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','');
	
	$flgcadas  = $_POST['flgcadas'];

	$vr_opcao = ( isset($opcoesTela[0]) ) ? $opcoesTela[0] : '';

?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="100%">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">DADOS PESSOAIS</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a class="fecharRotina"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?php echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>
									<table border="0" cellspacing="0" cellpadding="0">
										<tr style="height:22px;">
											<!-- Identificacao -->	
											<td width="1px"></td>											
											<td align="center" style="background-color: #C6C8CA; border-radius:3px;" id="imgAbaCen0">
												<a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAbaDados(6,0,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; Identifica&ccedil;&atilde;o &nbsp; </a>
											</td>
											<td width="1px"></td>
											<!-- Responsavel Legal -->
											<td align="center" style="background-color: #C6C8CA; border-radius:3px; " id="imgAbaCen1">
												<a href="#" id="linkAba1" onClick=<?php echo "acessaOpcaoAbaDados(6,1,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; Respons&aacute;vel Legal &nbsp; </a>
											</td>
											<td width="1px"></td>
											<!-- Pessoas de Relacionamento -->
											<td align="center" style="background-color: #C6C8CA; border-radius:3px;" id="imgAbaCen2">
												<a href="#" id="linkAba2" onClick=<?php echo "acessaOpcaoAbaDados(6,2,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; Pessoas de Relacionamento &nbsp;</a>
											</td>
											<td width="1px"></td>
											<!-- Conjuge -->
											<td align="center" style="background-color: #C6C8CA;border-radius:3px;" id="imgAbaCen6">
												<a href="#" id="linkAba6" onClick=<?php echo "acessaOpcaoAbaDados(6,6,'".$vr_opcao."');"; ?> class="txtNormalBold">&nbsp; C&ocirc;njuge &nbsp;</a>
											</td>
											<td width="1px"></td>
										</tr>
									</table>
								</td>
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
<script type="text/javascript">
	// Declara os flags para as opções da Rotina 
	var flgcadas     = "<? echo $flgcadas;     ?>";
	
	exibeRotina(divRotina);

	acessaOpcaoAbaDados(6,0,"<?php echo $vr_opcao; ?>");
</script>