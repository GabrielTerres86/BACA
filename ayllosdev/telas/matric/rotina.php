<?
/*!
 * FONTE        : rotina.php
 * CRIAÇÃO      : Douglas Quisinski (CECRED)
 * DATA CRIAÇÃO : 09/05/2014
 * OBJETIVO     : Tela do formulario de rotina
 *
 * ALTERACOES   : 30/07/2015 - Alterar o fonte para uso generico de rotinas dentro da MATRIC (Gabriel-RKAM)
				  01/10/2015 - Adicionado nova opção "J" para alteração
							   apenas do cpf/cnpj e removido a possibilidade de
							   alteração pela opção "X", conforme solicitado no 
							   chamado 321572 (Kelvin).
				  18/02/2016 - Incluido operacao LCC e LCD para mostrar titulo para pedir senha do coordenador. (Jorge/Thiago) - SD 394596			   
 */	 
?>

<?
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");
	
	$operacao = $_POST['operacao'];
	if($operacao == 'VX' || $operacao == 'VJ' || $operacao == 'LCD' || $operacao == 'LCC'){
		$titulo = 'PARA CONTINUAR, PEÇA LIBERAÇÃO AO COORDENADOR';
	}
	else{
		$titulo = 'DUPLICAR C/C';
	}
	
?>

<table cellpadding="0" cellspacing="0" border="0" >
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0"  >
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td id="tdTituloRotina" class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml($titulo); ?></td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="btnVoltar();fechaRotina($('#divRotina')); return false;" ><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
										<tr>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nle.gif" width="4" height="21" id="imgAbaEsq0"></td>
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<div id="divConteudoRotina">
																													
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