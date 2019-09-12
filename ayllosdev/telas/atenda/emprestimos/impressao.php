<?
/*
   FONTE        : impressao.php
   CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
   DATA CRIAÇÃO : 02/03/2011 
   OBJETIVO     : Mostra a tela com opções para impressão
   ALTERACOES   : 25/10/2011 - Controle de impressão do rating na central (Henrique)
   				  05/09/2012 - Mudar para layout padrao (Gabriel) 	
   				  13/08/2014 - Incluir botão do cet, Projeto CET (Lucas R./Gielow)
                  03/09/2014 - Incluir consultas ao orgaos de protecao de credito (Jonata-RKAM).
  				  12/09/2014 - Projeto Contratos de Emprestimos
							   Retirar botao de impressao "COMPLETA"
							   (Tiago Castro - RKAM).
                  06/11/2014 - Ocultar apenas o botao de  PROPOSTA/NOTA PROMISSORIA/CONTRATO 
                               mantendo as demais opcoes habilitadas e visiveis. (Jaison)
				  09/06/2015 - Revisao de contratos (Gabriel-RKAM).				
                  26/06/2015 - Exibicao ou nao do botao 'Termo Portabilidade'. (Jaison/Diego - SD: 290027)
                  15/03/2016 - Buscar flmail_comite para verificar se deve permitir enviar 
                               email para o comite. PRJ207 - Esteira (Odirlei-AMcom)
                  31/01/2019 - Remover a impressão do Rating Atual conforme estória: Product Backlog Item 13986:
                               Rating - Ajustes em Telas Desabilitar impressão
                               P450 - Luiz Otávio Olinger Momm (AMCOM)
 */	
?>
 
<?
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
		
	if ($glbvars["cdcooper"] == 3) {
		$divBloqueia = "blockBackground(parseInt($('#divRotina').css('z-index')))";
	} else {

	}
	
	$dsiduser = session_id();	

	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
	$xml .= '		<nrdconta>' . $_POST['nrdconta'] . '</nrdconta>';
	$xml .= '		<nrctremp>' . $_POST['nrctremp'] . '</nrctremp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PORTAB_CRED", "POS_PORTAB", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error', $msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)', false);
	}
	
	$portabil = $xmlObjDados->roottag->tags[0]->cdata;
    
    // Buscar informacao se deve permitir o envio de email para o comite
    $xml = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<nrdconta>' . $_POST['nrdconta'] . '</nrdconta>';
	$xml .= '		<nrctremp>' . $_POST['nrctremp'] . '</nrctremp>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "VERF_EMAIL_COMITE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error', $msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)', true);
	}
    
	//Busca se deve mostrar o botão para impressão da declaração de isenção de IOF
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
	$xml .= '		<nrdconta>' . $_POST['nrdconta'] . '</nrdconta>';
	$xml .= '		<nrctrato>' . $_POST['nrctremp'] . '</nrctrato>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "CONS_DEC_ISENC_IOF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error', $msg, 'Alerta - Aimaro', 'bloqueiaFundo(divRotina)', false);
	}
	
	$isencaoIOF = $xmlObjDados->roottag->tags[0]->cdata;
    
?>
<script>
    flmail_comite = "<?php echo $xmlObjDados->roottag->tags[0]->cdata; ?>";
</script>
<table id="tdImp"cellpadding="0" cellspacing="0" border="0" width="100%">
	<tr>
		<td align="center">		
			<table border="0" cellpadding="0" cellspacing="0" width="750">
				<tr>
					<td>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="11"><img src="<?php echo $UrlImagens; ?>background/tit_tela_esquerda.gif" width="11" height="21"></td>
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><? echo utf8ToHtml('Impressão') ?></td>
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
											<td align="center" style="background-color: #C6C8CA;" id="imgAbaCen0"><a href="#" id="linkAba0" class="txtNormalBold">Principal</a></td>
																																					
											<td><img src="<?php echo $UrlImagens; ?>background/mnu_nld.gif" width="4" height="21" id="imgAbaDir0"></td>
											<td width="1"></td>
										</tr>
									</table>
								</td>
							</tr>
							<tr>
								<td align="center" style="border: 2px solid #969FA9; background-color: #F4F3F0; padding: 2px 2px 8px;">
									<div id="divConteudoOpcao">
										<form id="frmNP" />
                                        <div id="divBotoes">
                                        
                                            <?php
                                                // Nao pode ser (3) Internet ou (4) TAA
                                                if ($_POST['cdorigem'] != 3 && $_POST['cdorigem'] != 4) {
                                                    echo '<a href="#" class="botao" onClick="verificaImpressao(2); return false;">Contrato</a>';
													echo '<a href="#" class="botao" onClick="verificaImpressao(8); return false;">Contrato N&atilde;o Negoci&aacute;vel</a>';
                                                }
                                            ?>
											<a href="#" class="botao" onClick="verificaImpressao(6); return false;">CET</a>
                                            <?php
                                                if ($_POST['flgimppr'] == 'yes') {
                                                    echo '<a href="#" class="botao" onClick="verificaImpressao(3); return false;">Proposta</a>';
                                                }
                                                
                                                if ($_POST['flgimpnp'] == 'yes') {
                                                    echo '<a href="#" class="botao" onClick="verificaImpressao(4); return false;">Nota promissoria</a>';
                                                }
                                            ?>

											<a href="#" class="botao" onClick="verificaImpressao(7);return false;">Consultas</a>
                                            <?php
                                                if ($portabil == 'S') {
                                                    echo '<a href="#" class="botao" onClick="verificaImpressao(9); return false;">Termo Portabilidade</a>';
                                                }

                                                if ($isencaoIOF == 'S') {
                                                    echo '<a href="#" class="botao" onClick="verificaImpressao(57);return false;">Declara&ccedil;&atilde;o Financ. Im&oacute;veis</a>';
                                                }
                                            ?>
											<a href="#" class="botao" id="btVoltar" onClick="fechaRotina($('#divUsoGenerico'),divRotina);">Voltar</a>
										</div>
										
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

// Esconde mensagem de aguardo
hideMsgAguardo();

// Bloqueia conteúdo que está átras do div da rotina
blockBackground(parseInt($("#divRotina").css("z-index")));
</script>