<?
/*!
 * FONTE        : altera.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 08/04/2011 
 * OBJETIVO     : Tela para alteração do número da proposta de empréstimo.
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 000: [05/09/2011] Alterado o botão 'Alterar número da proposta' para 'Alterar número do contrato'. Marcelo L. Pereira (GATI)
 * 001: [05/09/2012] Mudar para layout padrao (Gabriel)	
 * 002: [08/09/2014] Projeto Automatização de Consultas em Propostas de Crédito (Jonata-RKAM).
 * 003: [01/03/2016] PRJ Esteira de Credito. (Jaison/Oscar)
 * 004: [06/07/2018] PRJ 438 - Alterado label "Somente o valor da proposta" para "Valor de proposta e data de vencimento". (Mateus Z/Mouts)
 */	
?>
 
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");	
  
  isPostMethod();
	$inobriga = (isset($_POST['inobriga'])) ? $_POST['inobriga'] : '';
  
?>

<table id="altera"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="288px">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">Alterar ?</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divUsoGenerico'),divRotina);"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" onClick=<?php echo "acessaOpcaoAba(".count($opcoesTela).",0,'".$opcoesTela[0]."');"; ?> class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px;">
									<!-- PRJ 438 - Alteração do label "Somente o valor da proposta" para "Valor de proposta e data de vencimento",
												   tamanho da div para 285px e botões para 265px -->
									<div style="width: 285px; height: 190px;" id="divConteudoAltara" class="divBotoes">
												
										<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:265px; " id="todaProp" onClick="fechaAltera('A_NOVA_PROP');return false;">Toda a proposta de empr&eacute;stimo </a>
										<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:265px; " onClick="fechaAltera('A_VALOR');return false;"> Valor de proposta e data de vencimento </a>																
										<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:265px; " onClick="fechaAltera('A_NUMERO');return false;"> Alterar o n&uacute;mero do contrato </a>										
                    <? IF ($inobriga!="S"){?>
                    <a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:265px; " onClick="fechaAltera('CONSULTAS');return false;"> Somente Consultas </a>
                    <?}?>
										<a href="#" class="botao" style="margin: 4px 0px 4px 0px; width:265px; " onClick="fechaAltera('A_AVALISTA');return false;"> Alterar Somente Avalistas </a>
                                        <a href="#" class="botao" style="margin: 6px 0px 0px 0px;" id="btVoltar" onClick="fechaAltera('fechar');return false;"> Voltar </a>
										
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