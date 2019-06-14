<? 
/*!
 * FONTE        : form_consulta.php
 * CRIAÇÃO      : Rogérius Militao - (DB1)
 * DATA CRIAÇÃO : 17/04/2015
 * OBJETIVO     : Formulario que apresenta o log da consulta
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * [03/12/2014] Jean Reddiga  (RKAM)   : De acordo com a circula 3.656 do Banco Central,substituir nomenclaturas Cedente
 *	             			             por Beneficiário e  Sacado por Pagador  Chamado 229313 (Jean Reddiga - RKAM).
 * [17/04/2015] Lucas Reinert (CECRED) : Adicionado campo Tp. Emissao. (Reinert)
 *
 * [02/06/2015] Adriano (CECRED) : Alterado o label do campo "dtdocmto" para "Data Dcto".
 *
 * 30/12/2015 - Alterações Referente Projeto Negativação Serasa (Daniel)	
 * [11/10/2016] Odirlei Busana(AMcom)  : Inclusao dos campos de aviso por SMS. PRJ319 - SMS Cobrança. 
 * 
 * 17/01/2017 - Recebimento do flag flgdprot para definicao de layout da tela (Heitor - Mouts)
 *
 * 26/06/2017 - Alteração de DDA para Boleto DDD e inclusão de Campo Pagador DDA, Prj. 340 (Jean Michel)
 *
 * 27/09/2017 - Receber o campo qtdiaprt, inserasa como parametro (Douglas - Chamado 754911)
 *
 * 30/05/2018 - Alterações referente ao PRJ352
 */
 
 	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();
	
	$operacao 	= $_POST['operacao'];
	$nrdconta	= $_POST['nrdconta'];
    $nrcnvcob	= $_POST['nrcnvcob'];
    $nrdocmto	= $_POST['nrdocmto'];
    $cdcooper	= $_POST['cdcooper'];
    $cdbandoc	= $_POST['cdbandoc']; 
	$flserasa	= $_POST['flserasa'];
	$qtdianeg   = $_POST['qtdianeg'];
	$inserasa   = $_POST['inserasa'];
	$flgdprot   = $_POST['flgdprot'];
	$qtdiaprt   = $_POST['qtdiaprt'];
	$cdtpinsc   = $_POST['cdtpinsc'];
	$nrinssac   = $_POST['nrinssac'];
	$insitcrt   = $_POST['insitcrt'];
	$dtvencto	= $_POST['dtvencto'];
	$cdufsaca   = $_POST['cdufsaca'];
	
	switch( $operacao ) {
		case 'log':			$procedure = 'buca_log';			break;	
		case 'instrucoes':	$procedure = 'busca_instrucoes';	break;
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0010.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrcnvcob>'.$nrcnvcob.'</nrcnvcob>';	
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';	
	$xml .= '		<cdcoopex>'.$cdcooper.'</cdcoopex>';	
	$xml .= '		<cdbandoc>'.$cdbandoc.'</cdbandoc>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult 	= getDataXML($xml);
	$xmlObjeto 	= getObjectXML($xmlResult);
    
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','fechaRotina( $(\'#divRotina\') )', false);
	} 

	$registro 	= $xmlObjeto->roottag->tags[0]->tags;
	$qtregist	= $xmlObjeto->roottag->tags[0]->attributes['QTREGIST'];
	
	/* MENSAGERIA */
	// Buscar Informacoes de DDA
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <tppessoa>".(($cdtpinsc == 1) ? "F" : "J")."</tppessoa>";
	$xml .= "   <nrcpfcgc>".$nrinssac."</nrcpfcgc>";
	$xml .= " </Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml, "COBRAN", "VERIFICA_SACADO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);

	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	  if ($msgErro == "") {
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
	  }
	  
	  exibirErro('error',$msgErro,'Alerta - Aimaro','fechaRotina( $(\'#divRotina\') )', false);
	  exit();
	}
	
	$flgsacad = ($xmlObj->roottag->tags[0]->cdata == 0) ? "N" : "S";
	
	$nrdconta 	= $_POST['nrdconta'];
	$nrcnvcob 	= $_POST['nrcnvcob'];
	
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrconven>".$nrcnvcob."</nrconven>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "COBRAN", "COBRAN_CONSULTA_LIMITE_DIAS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
  
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	  if ($msgErro == "") {
		  $msgErro = $xmlObj->roottag->tags[0]->cdata;
	  }
	  
	  exibirErro('error',$msgErro,'Alerta - Ayllos','fechaRotina( $(\'#divRotina\') )', false);
	  exit();
	}
			
	$qtlimmip = $xmlObj->roottag->tags[0]->tags[0]->cdata;
	$qtlimaxp = $xmlObj->roottag->tags[0]->tags[1]->cdata;
	
	// Busca parametros
	$xml = "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "PARPRT", "PARPRT_CONSULTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);
	$param = $xmlObj->roottag->tags[0]->tags[0];
  
	if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
	  $msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
	  if ($msgErro == "") {
		  $msgErro = $xmlObj->roottag->tags[0]->cdata;
	  }
	  
	  exibirErro('error',$msgErro,'Alerta - Ayllos','fechaRotina( $(\'#divRotina\') )', false);
	  exit();
	}
			
	$ufs = getByTagName($param->tags, 'dsuf');
	$param_uf = !empty($ufs) ? explode(',', $ufs) : "";
	$ufCadastrado = in_array($cdufsaca, $param_uf) != null;
	
	$dsnegufds = getByTagName($param->tags, 'dsnegufds');
	$param_dsnegufds = !empty($dsnegufds) ? explode(',', $dsnegufds) : "";
	$estaEmDsnegufds = in_array($cdufsaca, $param_dsnegufds) != null;
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
								<td class="txtBrancoBold ponteiroDrag" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif">&nbsp;</td>
								<td width="12" id="tdTitTela" background="<?php echo $UrlImagens; ?>background/tit_tela_fundo.gif"><a href="#" onClick="fechaRotina($('#divRotina')); return false;"><img src="<?php echo $UrlImagens; ?>geral/excluir.jpg" width="12" height="12" border="0"></a></td>
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
									<div id="divConteudo">


										<form id="frmConsulta" class="formulario" onSubmit="return false;">

											<fieldset>
												<legend> <? echo utf8ToHtml('Consulta de Cobrança');  ?> </legend>	
												
												<label for="nrinssac">CPF/CNPJ:</label>
												<input type="text" id="nrinssac" name="nrinssac" value="<?php echo $nrinssac; ?>"/>

												<label for="nrnosnum">Nosso Nr:</label>
												<input type="text" id="nrnosnum" name="nrnosnum" value="<?php echo $nrnosnum; ?>"/>

												<label for="dsdoccop">Nr Doc:</label>
												<input type="text" id="dsdoccop" name="dsdoccop" value="<?php echo $dsdoccop; ?>"/>

												<label for="nmdsacad">Pagador:</label>
												<input type="text" id="nmdsacad" name="nmdsacad" value="<?php echo $nmdsacad; ?>"/>

												<label for="flgregis">Cob.Reg.:</label>
												<input type="text" id="flgregis" name="flgregis" value="<?php echo $flgregis; ?>"/>
												
												</br>
												
												<label for="flgcbdda">Boleto DDA:</label>
												<input type="text" id="flgcbdda" name="flgcbdda" value="<?php echo $flgcbdda; ?>"/>
												
												<label for="flgsacad">Pagador DDA:</label>
												<input type="text" id="flgsacad" name="flgsacad" value="<?php echo $flgsacad; ?>"/>

												</br>
												
												<label for="dsendsac">Ender:</label>
												<input type="text" id="dsendsac" name="dsendsac" value="<?php echo $dsendsac; ?>"/>

												<label for="complend">Complem.:</label>
												<input type="text" id="complend" name="complend" value="<?php echo $complend; ?>"/>

												<label for="nmbaisac">Bairro:</label>
												<input type="text" id="nmbaisac" name="nmbaisac" value="<?php echo $nmbaisac; ?>"/>

												<label for="nmcidsac">Cidade:</label>
												<input type="text" id="nmcidsac" name="nmcidsac" value="<?php echo $nmcidsac; ?>"/>

												<label for="cdufsaca">UF:</label>
												<input type="text" id="cdufsaca" name="cdufsaca" value="<?php echo $cdufsaca; ?>"/>

												<label for="nrcepsac">CEP:</label>
												<input type="text" id="nrcepsac" name="nrcepsac" value="<?php echo $nrcepsac; ?>"/>

												<label for="dscjuros">Juros:</label>
												<input type="text" id="dscjuros" name="dscjuros" value="<?php echo $dscjuros; ?>"/>

												<label for="dscmulta">Multa:</label>
												<input type="text" id="dscmulta" name="dscmulta" value="<?php echo $dscmulta; ?>"/>

												<label for="dscdscto">Descto:</label>
												<input type="text" id="dscdscto" name="dscdscto" value="<?php echo $dscdscto; ?>"/>

												<label for="dtdocmto">Data Dcto:</label>
												<input type="text" id="dtdocmto" name="dtdocmto" value="<?php echo $dtdocmto; ?>"/>

												<label for="dsdespec">Esp Doc:</label>
												<input type="text" id="dsdespec" name="dsdespec" value="<?php echo $dsdespec; ?>"/>

												<label for="flgaceit">Aceite:</label>
												<input type="text" id="flgaceit" name="flgaceit" value="<?php echo $flgaceit; ?>"/>

												<label for="dsemiten">Tp. Emissao:</label>
												<input type="text" id="dsemiten" name="dsemiten" value="<?php echo $dsemiten; ?>"/>
												
												<label for="dssituac">Status:</label>
												<input type="text" id="dssituac" name="dssituac" value="<?php echo $dssituac; ?>"/>

												<label for="dtvencto">Vencto.:</label>
												<input type="text" id="dtvencto" name="dtvencto" value="<?php echo $dtvencto; ?>"/>

												<label for="vltitulo">Vlr Tit:</label>
												<input type="text" id="vltitulo" name="vltitulo" value="<?php echo $vltitulo; ?>"/>

												<label for="vldesabt">Desc/Abat:</label>
												<input type="text" id="vldesabt" name="vldesabt" value="<?php echo $vldesabt; ?>"/>

												<?php
													if (strtoupper($flgdprot) == 'YES') {
														?>
														<label for="qtdiaprt">Prot:</label>
														<input type="text" id="qtdiaprt" name="qtdiaprt" value="<?php echo $qtdiaprt; ?>"/>
														<?php
													} elseif (strtoupper($flserasa) == 'YES') {
														?>
														<label for="qtdianeg">Serasa:</label>
														<input type="text" id="qtdianeg" name="qtdianeg" value="<?php echo $qtdianeg; ?>"/>
														<?php
													} else {
														?>
														<label for="qtdiaprt">Prot:</label>
														<input type="text" id="qtdiaprt" name="qtdiaprt" value="<?php echo 0; ?>"/>
														<?php
													}
												?>

                                                
												<label for="dtdpagto">Pagto:</label>
												<input type="text" id="dtdpagto" name="dtdpagto" value="<?php echo $dtdpagto; ?>"/>

												<label for="vldpagto">Vlr Pag:</label>
												<input type="text" id="vldpagto" name="vldpagto" value="<?php echo $vldpagto; ?>"/>

												<label for="vljurmul">Jur/Multa:</label>
												<input type="text" id="vljurmul" name="vljurmul" value="<?php echo $vljurmul; ?>"/>

												<label for="cdbandoc">Banco:</label>
												<input type="text" id="cdbandoc" name="cdbandoc" value="<?php echo $cdbandoc; ?>"/>
												
												<input type="hidden" id="inserasa" name="inserasa" value="<?php echo $inserasa; ?>"/>
												
												<input type="hidden" id="flserasa" name="flserasa" value="<?php echo $flserasa; ?>"/>
												
                                                <!-- Aviso SMS -->
                                                <label for="dsavisms">SMS:</label>
												<input type="text" id="dsavisms" name="dsavisms" value="<?php echo $dsavisms; ?>"/>
                                                
                                                <label for="dssmsant">1 dia Antes Vct:</label>
												<input type="text" id="dssmsant" name="dssmsant" value="<?php echo $dssmsant; ?>"/>
                                                
                                                <label for="dssmsvct">No vencimento:</label>
												<input type="text" id="dssmsvct" name="dssmsvct" value="<?php echo $dssmsvct; ?>"/>
                                                
                                                <label for="dssmspos"><? echo utf8ToHtml('1 dia Após Vct:') ?> </label>
												<input type="text" id="dssmspos" name="dssmspos" value="<?php echo $dssmspos; ?>"/>
                                                
                                                <!-- Fim Aviso SMS -->
											</fieldset>		
											
											<fieldset>
												
												<? 
												if ( $operacao == 'log' ) {
													echo "<legend>Log do Processo</legend>";
													include("tab_log.php");
												} else if ( $operacao == 'instrucoes' ) {
													echo "<legend>".utf8ToHtml('Executar Instruções:')."</legend>";
													include("form_instrucoes.php");
												}
												?>
												
											</fieldset>
											
										</form>


										<div id="divBotoes" style="padding-bottom:10px">
											<a href="#" class="botao" id="btVoltar" onclick="fechaRotina($('#divRotina')); return false;">Fechar</a>
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
