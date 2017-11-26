<? 
/*!
 * FONTE        : descontos.php
 * CRIAÇÃO      : Guilherme (CECRED)
 * DATA CRIAÇÃO : Novembro/2008
 * OBJETIVO     : Mostrar janela de opções (cheques ou titulos)
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001: [05/05/2011] Rodolpho Telmo  (DB1) : Tratamento para Zoom Endereço e Avalista genérico
 * 002: [11/07/2011] Gabriel Capoia  (DB1) : Alterado para layout padrão
 * 003: [18/11/2011] Jorge I. Hamaguchi (CECRED) : Ajustes em critica quando nao houver permissao de acesso 
 * 004: [23/01/2014] Carlos (CECRED) : Retirada a include de titulos/msg_grupo_economico.php
 * 005: [25/07/2016] Evandro - RKAM : Adicionado classe (SetWindow) - necessaria para navegação com teclado.
 * 006: [26/06/2017] Jonata (RKAM): Ajuste para rotina ser chamada através da tela ATENDA > Produtos (P364).
 */	
?>

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();			
	
	// Se parâmetros necessários não foram informados
	if (!isset($_POST["nmdatela"]) || !isset($_POST["nmrotina"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','');	
	}	
	
	$cdproduto = $_POST['cdproduto'];
    $labelRot = $_POST['labelRot'];	

	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	$glbvars['opcoesTela']  = $opcoesTela;

	if((!in_array("DSC CHQS",$rotinasTela)) && (!in_array("DSC TITS",$rotinasTela))){
		echo "<script type='text/javascript'>hideMsgAguardo();showError('error','Voc&ecirc; n&atilde;o tem permiss&atilde;o de acesso','Alerta - Permiss&otilde;es','');</script>";
		exit();
	}
	
	$dispBtChq = (in_array("DSC CHQS",$rotinasTela)) ? "" : "display:none;";
	$dispBtTlt = (in_array("DSC TITS",$rotinasTela)) ? "" : "display:none;";
	
?>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="350">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="<?php echo $labelRot; ?>" id="tdTitRotina" class="txtBrancoBold ponteiroDrag SetWindow SetFoco" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif">DESCONTOS</td>
								<td width="12" id="tdTitTela" background="<?echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a id="btSair" href="#" onClick="encerraRotina(true);return false;"><img src="<?echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
								<td width="8"><img src="<?echo $UrlImagens; ?>background/tit_tela_direita.gif" width="8" height="21"></td>
							</tr>
						</table>     
					</td> 
				</tr>    
				<tr>
					<td class="tdConteudoTela" align="center">	
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									
									<div id="divOpcoesDaOpcao1"></div>
									<div id="divOpcoesDaOpcao2"></div>
									<div id="divOpcoesDaOpcao3"></div>
									<div id="divOpcoesDaOpcao4"></div>											
									<div id="divConteudoOpcao" style="height: 80px;">
										<!-- Botoes Titulos e Cheque -->
										
										<div id="divBotoes" style="height:80px;">
											<input style="margin:20px 10px 0 0;<?php echo $dispBtChq; ?>" type="image" src="<?echo $UrlImagens; ?>botoes/cheques.gif" onClick="carregaCheques();return false;" />
											<input style="margin:20px 0 0 0;<?php echo $dispBtTlt; ?>" type="image" src="<?echo $UrlImagens; ?>botoes/titulos.gif" onClick="carregaTitulos();return false;" />
										</div>
										
										<!--Botoes Titulos e Cheques -->
									</div>
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

	var cdproduto = <? echo $cdproduto; ?>;
	
	mostraRotina();	
	hideMsgAguardo();	
	bloqueiaFundo(divRotina);
	controlaFoco();
	
	//Se esta tela foi chamada através da rotina "Produtos" então acessa a opção conforme definido pelos responsáveis do projeto P364
	if (executandoProdutos == true) {
	  if (cdproduto == 34 || cdproduto == 36) {
		carregaCheques();
	  }else if (cdproduto == 35 || cdproduto == 37) {
		carregaTitulos();
	  }
	}
	  
</script>