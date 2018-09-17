<?php 

	//**************************************************************************//
	//*** Fonte: obtem_log_spb.php                                           ***//
	//*** Autor: David                                                       ***//
	//*** Data : Novembro/2009                Última Alteração: 28/06/2017   ***//
	//***                                                                    ***//
	//*** Objetivo  : Obter log das transações SPB                           ***//
	//***                                                                    ***//	 
	//*** Alterações: 26/04/2010 - Mostrar conta do remetente no browse de   ***//
	//***                          mensagens processadas (David).            ***//
	//***                                                                    ***//	 
	//***             21/05/2010 - Alterar layout das tabelas (David).       ***//	 
	//***                                                                    ***//	 
	//***             23/07/2010 - Incluido consulta de transações 		     ***//
	//***                          rejeitadas (Elton).     				     ***//
	//***                                                                    ***//
	//***             30/08/2011 - Incluido campos de quantidade e valor     ***//	
	//***                          total (Henrique)			                 ***//	
	//***                                                                    ***//
	//***             18/04/2012 - Adicionado parametros nrdconta,           ***//
	//***                          nriniseq, nrregist na chamada da          ***//
	//***                          procedure obtem-log-spb. Criado           ***//
	//***                          paginacao na consulta                     ***//
	//***                          (divPesquisaRodape). (Fabricio)           ***//
	//*** 		                                                             ***//	  
	//***             02/08/2012 - Inclusão de novos campos na tela de       ***//
	//***						   consulta campoos, agencia/pac, nrdcaixa,  ***//
    //***   					   ndoperad (Lucas R.) 					     ***//
	//***   															     ***//
    //***	          27/03/2013 - Alteração na padronização da tela para    ***//
	//***                          novo layout (David Kruger).     		     ***//
	//***																	 ***//
	//***             05/09/2013 - Alteração da sigla PAC para PA (Carlos)   ***//
	//***																	 ***//
	//***             06/07/2015 - Inclusão do campo ISPB (Vanessa)		     ***//
	//***            														 ***//
	//***			  07/08/2015 - Gestão de TEDs/TECs - melhoria 85 (Lucas Ranghetti)
	//***																	 ***//
	//***		      09/11/2015 - Adicionado campo "Crise" inestcri.		 ***//
	//***						   (Jorge/Andrino)							 ***//
	//***																	 ***//
	//***		      07/10/2016 - Efetuado o envio do parametro cdifconv.   ***//
	//***						   (Adriano)							     ***//
	//***														             ***//
	//***             07/11/2016 - Ajustes para corrigir problemas encontrados ***//
    //***                          durante a homologação da área		     ***//
	//***                          (Adriano - M211)				             ***//
	//***														             ***//
    //***			  31/11/2017 - Ajustes para exibir TEDs estornadas		 ***//
    //***			               devido a analise de fraude                ***//
    //***			               PRJ335 - Analise de fraude(Odirlei-AMcom) ***//
	//***                                                                    ***//
	//***             28/06/2017 - Ajustado mascara dos campos de numero de  ***//
	//***                          conta, pois o tamanho foi aumentado para  ***//
	//***                          20 (Douglas - Chamado 668207)             ***//
	//**************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");	
	
	// Verifica Permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],"","L")) <> "") {
		exibeErro($msgError);
	}		
	
	// Se campos necessários para carregar dados não foram informados
	if (!isset($_POST["flgidlog"]) || !isset($_POST["dtmvtlog"]) || !isset($_POST["numedlog"]) || !isset($_POST["cdsitlog"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
	
	$flgidlog = $_POST["flgidlog"];
	$dtmvtlog = $_POST["dtmvtlog"];
	$numedlog = $_POST["numedlog"];
	$cdsitlog = $_POST["cdsitlog"];	
	$nrdconta = $_POST["nrdconta"];
	$dsorigem = $_POST["dsorigem"];
	$nriniseq = $_POST["nriniseq"];
	$nrregist = $_POST["nrregist"];
	$inestcri = $_POST["inestcri"];
	$vlrdated = $_POST["vlrdated"];
	
	$qtdtotal = 0;
	$vlrtotal = 0;
	
	// Verifica se flag de identificação do log é válida
	if ($flgidlog <> "1" && $flgidlog <> "2" && $flgidlog <> "3") {
		exibeErro("Log inv&aacute;lido.");
	
	}

	// Verifica se data do log é válida
	if (!validaData($dtmvtlog)) {
		exibeErro("Data de log inv&aacute;lida.");
	}
	
	// Verifica se tipo do log é um inteiro válido
	if (!validaInteiro($numedlog)) {
		exibeErro("Tipo de log inv&aacute;lido.");
	}

	// Verifica se situação é válida
	if ($cdsitlog <> "P" && $cdsitlog <> "D" && $cdsitlog <> "T") {
		if ($cdsitlog == "R") {
		    if ($numedlog <> "1"  && $numedlog <> "3"){
				exibeErro("Situa&ccedil;&atilde;o inv&aacute;lida.");
            }
        /* opcao Estorno so podera ser utilizado para Enviadas ou Todos */    
		} else if ($cdsitlog == "E") {
            if ($numedlog <> "1"  && $numedlog <> "4"){
				exibeErro("Situa&ccedil;&atilde;o inv&aacute;lida.");
            }
        } else 
			exibeErro("Situa&ccedil;&atilde;o inv&aacute;lida.");
	}

	// Verifica se flag de identificação de Crise é válida
	if ($inestcri <> "0" && $inestcri <> "1") {
		exibeErro("Crise inv&aacute;lida.");
	}	
	
	// Monta o xml de requisição
	$xmlGetLog  = "";
	$xmlGetLog .= "<Root>";
	$xmlGetLog .= "  <Cabecalho>";
	$xmlGetLog .= "    <Bo>b1wgen0050.p</Bo>";
	$xmlGetLog .= "    <Proc>obtem-log-spb</Proc>";
	$xmlGetLog .= "  </Cabecalho>";
	$xmlGetLog .= "  <Dados>";
	$xmlGetLog .= "    <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetLog .= "    <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlGetLog .= "    <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlGetLog .= "    <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlGetLog .= "    <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlGetLog .= "    <dsorigem>".$dsorigem."</dsorigem>";
	$xmlGetLog .= "    <flgidlog>".$flgidlog."</flgidlog>";
	$xmlGetLog .= "    <dtmvtlog>".$dtmvtlog."</dtmvtlog>";
	$xmlGetLog .= "    <numedlog>".$numedlog."</numedlog>";
	$xmlGetLog .= "    <cdsitlog>".$cdsitlog."</cdsitlog>";
	$xmlGetLog .= "    <nrdconta>".$nrdconta."</nrdconta>";
	$xmlGetLog .= "    <nriniseq>".$nriniseq."</nriniseq>";
	$xmlGetLog .= "    <nrregist>".$nrregist."</nrregist>";
	$xmlGetLog .= "    <inestcri>".$inestcri."</inestcri>";
	$xmlGetLog .= "    <vlrdated>".$vlrdated."</vlrdated>";
	$xmlGetLog .= "  </Dados>";
	$xmlGetLog .= "</Root>";
		
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetLog);

	// Cria objeto para classe de tratamento de XML
	$xmlObjLog = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjLog->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjLog->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} 	
	
	$logDetalhado = $xmlObjLog->roottag->tags[1]->tags;
	$qtLogDetalhado = count($logDetalhado);
	
	$logTotais = $xmlObjLog->roottag->tags[2]->tags;
		//echo $xmlObjLog->roottag->tags[1];
		
	
	echo 'var strHTML = "";';
	
	
	if ($qtLogDetalhado > 0) {

		echo 'detalhes = new Array();';
		
		if ($cdsitlog == "P" && $numedlog != "4") {	
			?>			
			$("#tdMotivoDetalhe").html("DETALHES:&nbsp;");
			$("#divCampoMotivo").css("display","block"); 
			
			strHTML += '<div id="divLogProcessadas" style="overflow-y: scroll; overflow-x: scroll; height: 300px; width: 860px;">';
			strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="0" cellpadding="2" cellspacing="2">';
			strHTML += '				<tr style="background-color: #F4D0C9;">';
			strHTML += '					<td width="110px" class="txtNormalBold">Tipo</td>';
			strHTML += '					<td width="200px" class="txtNormalBold">Número de Controle</td>';
			strHTML += '					<td width="150px" class="txtNormalBold" align="right">Valor</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Hora</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Origem</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Dbt.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Crd.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Crd.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Crd.</td>';
			strHTML += '					<td width="50px" class="txtNormalBold">Caixa</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Operador</td>';
			strHTML += '				</tr>';
			strHTML += '			</table>';
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="1" cellpadding="2" cellspacing="2">';
			<?php 
			$cor = "";
			
			for ($i = 0; $i < $qtLogDetalhado; $i++) { 
				?>				
				objLog   = new Object();				
				objLog.cdbandst = "<?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?>";
				objLog.cdagedst = "<?php echo $logDetalhado[$i]->tags[2]->cdata; ?>";
				objLog.nrctadst = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?>";
				objLog.dsnomdst = "<?php echo $logDetalhado[$i]->tags[4]->cdata; ?>";
				objLog.dscpfdst = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?>";				
				objLog.cdbanrem = "<?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?>";
				objLog.cdagerem = "<?php echo $logDetalhado[$i]->tags[7]->cdata; ?>";
				objLog.nrctarem = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?>";
				objLog.dsnomrem = "<?php echo $logDetalhado[$i]->tags[9]->cdata; ?>";
				objLog.dscpfrem = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?>";								
				objLog.vltransa = "<?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?>";
				objLog.dsmotivo = "<?php echo $logDetalhado[$i]->tags[13]->cdata; ?>";
				objLog.cdispbrem = "<?php echo ($logDetalhado[$i]->tags[6]->cdata != 1 && $logDetalhado[$i]->tags[21]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[21]->cdata, 8, "0", STR_PAD_LEFT); ?>";
				objLog.cdispbdst = "<?php echo ($logDetalhado[$i]->tags[1]->cdata != 1 && $logDetalhado[$i]->tags[22]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[22]->cdata, 8, "0", STR_PAD_LEFT); ?>";
				objLog.dstransa = "<?php echo $logDetalhado[$i]->tags[14]->cdata; ?>";
				objLog.nmevento = "<?php echo $logDetalhado[$i]->tags[25]->cdata; ?>";
				objLog.nrctrlif = "<?php echo $logDetalhado[$i]->tags[26]->cdata; ?>";
				objLog.hrtransa = "<?php echo $logDetalhado[$i]->tags[11]->cdata; ?>";
				detalhes[<?php echo $i; ?>] = objLog;
				<?php
				if ($cor == "#F4F3F0") {
					$cor = "#FFFFFF";
				} else {
					$cor = "#F4F3F0";
				}		
				
				if ($numedlog == "1") {
					$nrctalog = formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-");					
				} else {               
					$nrctalog = formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-");
				}  
			?>
			
			
			strHTML += '				<tr id="trMsgLog<?php echo $i; ?>" style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaMsgLog(<?php echo $i; ?>,<?php echo (strpos($logDetalhado[$i]->tags[14]->cdata,'NAO OK')) ? 1 : 0; ?>);">';
			strHTML += '					<td width="110px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[25]->cdata; ?></td>'; 
			strHTML += '					<td width="200px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[26]->cdata; ?></td>';
			strHTML += '					<td width="150px" class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[11]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[15]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[7]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[9]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[2]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[4]->cdata; ?></td>';
			strHTML += '					<td width="50px" class="txtNormal"  align="left"><?php echo $logDetalhado[$i]->tags[17]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[18]->cdata; ?></td>';
			strHTML += '				</tr>';
			<?php
				$qtdtotal = $qtdtotal + 1;				
				$vlrtotal = $vlrtotal + str_replace(",", ".", $logDetalhado[$i]->tags[12]->cdata);
			} // Fim do for
			?>				
			strHTML += '				</table>';			
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '</table>';
			strHTML += '</div>';
			strHTML += '<div id="divPesquisaRodape" class="divPesquisaRodape">';
			strHTML += '	<table>';
			strHTML += '		<tr>';
			strHTML += '			<td>';
			
			<? 
			
			if ($numedlog == "1"){
				if (isset($logTotais[0]->tags[0]->cdata) and $logTotais[0]->tags[0]->cdata == 0) $nriniseq = 0;
			} else {
				if (isset($logTotais[0]->tags[2]->cdata) and $logTotais[0]->tags[2]->cdata == 0) $nriniseq = 0;
			}
						
			// Se a paginação não está na primeira, exibe botão voltar
			if ($nriniseq > 1) { 
				?> strHTML += '<a class="paginacaoAnt"><<< Anterior</a>'; <? 
			} else {
				?> strHTML += '&nbsp;'; <?
			}
				
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<?
			if (isset($nriniseq)) {
			
				if ($numedlog == "1") {

					if (($nriniseq + $nrregist) > $logTotais[0]->tags[0]->cdata){
					?> 
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo $logTotais[0]->tags[0]->cdata; ?> de <? echo $logTotais[0]->tags[0]->cdata; ?>';
					<?
					}else{
					?>
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo ($nriniseq + $nrregist - 1); ?> de <? echo $logTotais[0]->tags[0]->cdata; ?>';
					<?
					}
				} else{
					if (($nriniseq + $nrregist) > $logTotais[0]->tags[2]->cdata){
					?> 
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo $logTotais[0]->tags[2]->cdata; ?> de <? echo $logTotais[0]->tags[2]->cdata; ?>';
					<?
					}else{
					?>
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo ($nriniseq + $nrregist - 1); ?> de <? echo $logTotais[0]->tags[2]->cdata; ?>';
					<?
					}
				}
			}
			
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<?
			
			// Se a paginação não está na &uacute;ltima página, exibe botão proximo
			if ($numedlog == "1"){
				if ($logTotais[0]->tags[0]->cdata > ($nriniseq + $nrregist - 1)) {
					?> strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>'; <?
				} else {
					?> strHTML += '&nbsp;'; <?
				}
			} else {
				if ($logTotais[0]->tags[2]->cdata > ($nriniseq + $nrregist - 1)) {
					?> strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>'; <?
				} else {
					?> strHTML += '&nbsp;'; <?
				}
			}
			
			?>
			
			strHTML += '			</td>';
			strHTML += '		</tr>';
			strHTML += '	</table>';
			strHTML += '</div>';
			
			strHTML += '<br>';
			strHTML += '<label for="qtdtotal" class="txtNormalBold" style="padding-right: 3px;">Quantidade Total:</label>';
			
			<? if ($numedlog == 1) {
			?>
				strHTML += '<input style="width: 45px;" class="campoTelaSemBorda" type="text" id="qtdtotal" name="qtdtotal" value="<?php echo $logTotais[0]->tags[0]->cdata; ?>" readonly ></input>';
			<?
			} else {
			?>
				strHTML += '<input style="width: 45px;" class="campoTelaSemBorda" type="text" id="qtdtotal" name="qtdtotal" value="<?php echo $logTotais[0]->tags[2]->cdata; ?>" readonly ></input>';
			<?
			}
			?>
			
			strHTML += '<label for="vlrtotal" class="txtNormalBold" style="padding-right: 3px; padding-left: 15px;">Valor Total:</label>';
			
			
			<? if ($numedlog == 1) {
			?>																																
				strHTML += '<input style="width: 100px;" class="campoTelaSemBorda" type="text" id="vlrtotal" name="vlrtotal" value="<?php echo number_format(str_replace(",", ".",$logTotais[0]->tags[1]->cdata),2,",","."); ?>" readonly ></input>';
			<?
			} else {
			?>
				strHTML += '<input style="width: 100px;" class="campoTelaSemBorda" type="text" id="vlrtotal" name="vlrtotal" value="<?php echo number_format(str_replace(",", ".",$logTotais[0]->tags[3]->cdata),2,",","."); ?>" readonly ></input>';
			<?
			}
			
		} elseif ($cdsitlog == "D" && $numedlog != "4") {
			?>						
			$("#tdMotivoDetalhe").html("MOTIVO:&nbsp;");
			$("#divCampoMotivo").css("display","block");
			
			strHTML += '<div id="divLogDevolvidas" style="overflow-y: scroll; overflow-x: scroll; height: 300px; width: 860px;">';
			strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="0" cellpadding="2" cellspacing="2">';
			strHTML += '				<tr style="background-color: #F4D0C9;">';
			strHTML += '					<td width="110px" class="txtNormalBold">Tipo</td>';
			strHTML += '					<td width="200px" class="txtNormalBold">Número de Controle</td>';
			strHTML += '					<td width="150px" class="txtNormalBold" align="right">Valor</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Hora</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Origem</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Dbt.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Crd.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Crd.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Crd.</td>';
			strHTML += '					<td width="50px" class="txtNormalBold">Caixa</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Operador</td>';
			strHTML += '				</tr>';
			strHTML += '			</table>';
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="1" cellpadding="2" cellspacing="2">';
			<?php 
			$cor = "";
			
			for ($i = 0; $i < $qtLogDetalhado; $i++) { 
				?>				
				objLog   = new Object();				
				objLog.cdbandst = "<?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?>";
				objLog.cdagedst = "<?php echo $logDetalhado[$i]->tags[2]->cdata; ?>";
				objLog.nrctadst = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?>";
				objLog.dsnomdst = "<?php echo $logDetalhado[$i]->tags[4]->cdata; ?>";
				objLog.dscpfdst = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?>";				
				objLog.cdbanrem = "<?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?>";
				objLog.cdagerem = "<?php echo $logDetalhado[$i]->tags[7]->cdata; ?>";
				objLog.nrctarem = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?>";
				objLog.dsnomrem = "<?php echo $logDetalhado[$i]->tags[9]->cdata; ?>";
				objLog.dscpfrem = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?>";								
				objLog.vltransa = "<?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?>";
				objLog.dsmotivo = "<?php echo $logDetalhado[$i]->tags[13]->cdata; ?>";
				objLog.cdispbrem = "<?php echo ($logDetalhado[$i]->tags[6]->cdata != 1 && $logDetalhado[$i]->tags[21]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[21]->cdata, 8, "0", STR_PAD_LEFT); ?>";
				objLog.cdispbdst = "<?php echo  ($logDetalhado[$i]->tags[1]->cdata != 1 && $logDetalhado[$i]->tags[22]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[22]->cdata, 8, "0", STR_PAD_LEFT); ?>";
				objLog.dstransa = "<?php echo $logDetalhado[$i]->tags[14]->cdata; ?>";
				objLog.nmevento = "<?php echo $logDetalhado[$i]->tags[25]->cdata; ?>";
				objLog.nrctrlif = "<?php echo $logDetalhado[$i]->tags[26]->cdata; ?>";
				objLog.hrtransa = "<?php echo $logDetalhado[$i]->tags[11]->cdata; ?>";
				detalhes[<?php echo $i; ?>] = objLog;
				<?php			
				if ($cor == "#F4F3F0") {
					$cor = "#FFFFFF";
				} else {
					$cor = "#F4F3F0";
				}					
			?>
			strHTML += '				<tr id="trMsgLog<?php echo $i; ?>" style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaMsgLog(<?php echo $i; ?>,<?php echo (strpos($logDetalhado[$i]->tags[14]->cdata,'NAO OK')) ? 1 : 0; ?>);">';
			strHTML += '					<td width="110px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[25]->cdata; ?></td>'; 
			strHTML += '					<td width="200px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[26]->cdata; ?></td>';
			strHTML += '					<td width="150px" class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[11]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[15]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[7]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[9]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[2]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[4]->cdata; ?></td>';
			strHTML += '					<td width="50px" class="txtNormal"  align="left"><?php echo $logDetalhado[$i]->tags[17]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[18]->cdata; ?></td>';
			strHTML += '				</tr>';
			<?php
				$qtdtotal = $qtdtotal + 1;				
				$vlrtotal = $vlrtotal + str_replace(",", ".", $logDetalhado[$i]->tags[12]->cdata);
			} // Fim do for
			?>				
			strHTML += '				</table>';			
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '</table>';
			strHTML += '</div>';
			strHTML += '<div id="divPesquisaRodape" class="divPesquisaRodape">';
			strHTML += '	<table>';
			strHTML += '		<tr>';
			strHTML += '			<td>';
			
			<? 
			if ($numedlog == 1 ) {
				if (isset($logTotais[0]->tags[4]->cdata) and $logTotais[0]->tags[4]->cdata == 0) $nriniseq = 0;
			} else {
				if (isset($logTotais[0]->tags[6]->cdata) and $logTotais[0]->tags[6]->cdata == 0) $nriniseq = 0;
			}
						
			// Se a paginação não está na primeira, exibe botão voltar
			if ($nriniseq > 1) { 
				?> strHTML += '<a class="paginacaoAnt"><<< Anterior</a>'; <? 
			} else {
				?> strHTML += '&nbsp;'; <?
			}
				
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<?
			if (isset($nriniseq)) {
			
				if ($numedlog == 1 ){
				
					if (($nriniseq + $nrregist) > $logTotais[0]->tags[4]->cdata){
					?> 
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo $logTotais[0]->tags[4]->cdata; ?> de <? echo $logTotais[0]->tags[4]->cdata; ?>';
					<?
					}else{
					?>
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo ($nriniseq + $nrregist - 1); ?> de <? echo $logTotais[0]->tags[4]->cdata; ?>';
					<?
					}
				} else {
				
					if (($nriniseq + $nrregist) > $logTotais[0]->tags[6]->cdata){
					?> 
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo $logTotais[0]->tags[6]->cdata; ?> de <? echo $logTotais[0]->tags[6]->cdata; ?>';
					<?
					}else{
					?>
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo ($nriniseq + $nrregist - 1); ?> de <? echo $logTotais[0]->tags[6]->cdata; ?>';
					<?
					}
				}
			}
			
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<?
			
			// Se a paginação não está na &uacute;ltima página, exibe botão proximo
			if ($numedlog == 1 ) {
				if ($logTotais[0]->tags[4]->cdata > ($nriniseq + $nrregist - 1)) {
					?> strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>'; <?
				} else {
					?> strHTML += '&nbsp;'; <?
				}
			} else {
				if ($logTotais[0]->tags[6]->cdata > ($nriniseq + $nrregist - 1)) {
					?> strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>'; <?
				} else {
					?> strHTML += '&nbsp;'; <?
				}
			}
			
			?>
			
			strHTML += '			</td>';
			strHTML += '		</tr>';
			strHTML += '	</table>';
			strHTML += '</div>';
			strHTML += '<label for="qtdtotal" class="txtNormalBold" style="padding-right: 3px;">Quantidade Total:</label>';
			
			<? if ($numedlog == 1 ) {
			?>
				strHTML += '<input style="width: 45px;" class="campoTelaSemBorda" type="text" id="qtdtotal" name="qtdtotal" value="<?php echo $logTotais[0]->tags[4]->cdata; ?>" readonly ></input>';
			<?
			} else {
			?>
				strHTML += '<input style="width: 45px;" class="campoTelaSemBorda" type="text" id="qtdtotal" name="qtdtotal" value="<?php echo $logTotais[0]->tags[6]->cdata; ?>" readonly ></input>';
			<?
			}
			?>
			
			strHTML += '<label for="vlrtotal" class="txtNormalBold" style="padding-right: 3px; padding-left: 15px;">Valor Total:</label>';
			
			<? if ($numedlog == 1 ) {
			?>
				strHTML += '<input style="width: 100px;" class="campoTelaSemBorda" type="text" id="vlrtotal" name="vlrtotal" value="<?php echo number_format(str_replace(",", ".",$logTotais[0]->tags[5]->cdata),2,",","."); ?>" readonly ></input>';
			<?
			} else {
			?>
				strHTML += '<input style="width: 100px;" class="campoTelaSemBorda" type="text" id="vlrtotal" name="vlrtotal" value="<?php echo number_format(str_replace(",", ".",$logTotais[0]->tags[7]->cdata),2,",","."); ?>" readonly ></input>';
			<?
			}
			
		} 
		 elseif ($cdsitlog == "R" && $numedlog != "4"){ 
			?>						
			$("#tdMotivoDetalhe").html("MOTIVO:&nbsp;");
			$("#divCampoMotivo").css("display","block");
			
			strHTML += '<div id="divLogDevolvidas" style="overflow-y: scroll; overflow-x: scroll; height: 300px; width: 860px;">';
			strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="0" cellpadding="2" cellspacing="2">';
			strHTML += '				<tr style="background-color: #F4D0C9;">';
			strHTML += '					<td width="110px" class="txtNormalBold">Tipo</td>';
			strHTML += '					<td width="200px" class="txtNormalBold">Número de Controle</td>';
			strHTML += '					<td width="150px" class="txtNormalBold" align="right">Valor</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Hora</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Origem</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Dbt.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Crd.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Crd.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Crd.</td>';
			strHTML += '					<td width="50px" class="txtNormalBold">Caixa</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Operador</td>';
			strHTML += '				</tr>';
			strHTML += '			</table>';
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="1" cellpadding="2" cellspacing="2">';
			<?php 
			$cor = "";
			
			for ($i = 0; $i < $qtLogDetalhado; $i++) { 
				?>				
				objLog   = new Object();				
				objLog.cdbandst = "<?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?>";
				objLog.cdagedst = "<?php echo $logDetalhado[$i]->tags[2]->cdata; ?>";
				objLog.nrctadst = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?>";
				objLog.dsnomdst = "<?php echo $logDetalhado[$i]->tags[4]->cdata; ?>";
				objLog.dscpfdst = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?>";				
				objLog.cdbanrem = "<?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?>";
				objLog.cdagerem = "<?php echo $logDetalhado[$i]->tags[7]->cdata; ?>";
				objLog.nrctarem = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?>";
				objLog.dsnomrem = "<?php echo $logDetalhado[$i]->tags[9]->cdata; ?>";
				objLog.dscpfrem = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?>";								
				objLog.vltransa = "<?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?>";
				objLog.dsmotivo = "<?php echo $logDetalhado[$i]->tags[13]->cdata; ?>";
				objLog.cdispbrem = "<?php echo ($logDetalhado[$i]->tags[6]->cdata != 1 && $logDetalhado[$i]->tags[21]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[21]->cdata, 8, "0", STR_PAD_LEFT); ?>";
				objLog.cdispbdst = "<?php echo  ($logDetalhado[$i]->tags[1]->cdata != 1 && $logDetalhado[$i]->tags[22]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[22]->cdata, 8, "0", STR_PAD_LEFT); ?>";
				objLog.dstransa = "<?php echo $logDetalhado[$i]->tags[14]->cdata; ?>";
				objLog.nmevento = "<?php echo $logDetalhado[$i]->tags[25]->cdata; ?>";
				objLog.nrctrlif = "<?php echo $logDetalhado[$i]->tags[26]->cdata; ?>";
				objLog.hrtransa = "<?php echo $logDetalhado[$i]->tags[11]->cdata; ?>";
				detalhes[<?php echo $i; ?>] = objLog;
				<?php			
				if ($cor == "#F4F3F0") {
					$cor = "#FFFFFF";
				} else {
					$cor = "#F4F3F0";
				}					
			?>
			strHTML += '				<tr id="trMsgLog<?php echo $i; ?>" style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaMsgLog(<?php echo $i; ?>,<?php echo (strpos($logDetalhado[$i]->tags[14]->cdata,'NAO OK')) ? 1 : 0; ?>);">';
			strHTML += '					<td width="110px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[25]->cdata; ?></td>'; 
			strHTML += '					<td width="200px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[26]->cdata; ?></td>';
			strHTML += '					<td width="150px" class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[11]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[15]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[7]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[9]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[2]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[4]->cdata; ?></td>';
			strHTML += '					<td width="50px" class="txtNormal"  align="left"><?php echo $logDetalhado[$i]->tags[17]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[18]->cdata; ?></td>';
			strHTML += '				</tr>';
			<?php
				$qtdtotal = $qtdtotal + 1;				
				$vlrtotal = $vlrtotal + str_replace(",", ".", $logDetalhado[$i]->tags[12]->cdata);
			} // Fim do for
			?>				
			strHTML += '				</table>';			
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '</table>';
			strHTML += '</div>';
			strHTML += '<div id="divPesquisaRodape" class="divPesquisaRodape">';
			strHTML += '	<table>';
			strHTML += '		<tr>';
			strHTML += '			<td>';
			
			<? 
			if (isset($logTotais[0]->tags[9]->cdata) and $logTotais[0]->tags[9]->cdata == 0) $nriniseq = 0;
						
			// Se a paginação não está na primeira, exibe botão voltar
			if ($nriniseq > 1) { 
				?> strHTML += '<a class="paginacaoAnt"><<< Anterior</a>'; <? 
			} else {
				?> strHTML += '&nbsp;'; <?
			}
				
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<?
			if (isset($nriniseq)) {
				if (($nriniseq + $nrregist) > $logTotais[0]->tags[9]->cdata){
				?> 
					strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo $logTotais[0]->tags[9]->cdata; ?> de <? echo $logTotais[0]->tags[9]->cdata; ?>';
				<?
				}else{
				?>
					strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo ($nriniseq + $nrregist - 1); ?> de <? echo $logTotais[0]->tags[9]->cdata; ?>';
				<?
				}
			}
			
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<?
			
			// Se a paginação não está na &uacute;ltima página, exibe botão proximo
			if ($logTotais[0]->tags[9]->cdata > ($nriniseq + $nrregist - 1)) {
				?> strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>'; <?
			} else {
				?> strHTML += '&nbsp;'; <?
			}
			
			?>
			
			strHTML += '			</td>';
			strHTML += '		</tr>';
			strHTML += '	</table>';
			strHTML += '</div>';
			strHTML += '<label for="qtdtotal" class="txtNormalBold" style="padding-right: 3px;">Quantidade Total:</label>';
			strHTML += '<input style="width: 45px;" class="campoTelaSemBorda" type="text" id="qtdtotal" name="qtdtotal" value="<?php echo $logTotais[0]->tags[9]->cdata; ?>" readonly ></input>';
			strHTML += '<label for="vlrtotal" class="txtNormalBold" style="padding-right: 3px; padding-left: 15px;">Valor Total:</label>';
			strHTML += '<input style="width: 100px;" class="campoTelaSemBorda" type="text" id="vlrtotal" name="vlrtotal" value="<?php echo number_format(str_replace(",", ".",$logTotais[0]->tags[10]->cdata),2,",","."); ?>" readonly ></input>';
			<?php	 		 
			// Fim $cdsitlog = "R"
		 } elseif (($cdsitlog == "T") || ($cdsitlog == "E") ||($numedlog == "4")){
             
			?>
			
			strHTML += '<div id="divLogProcessadas" style="overflow-y: scroll; overflow-x: scroll; height: 300px; width: 860px;">';
			strHTML += '<table border="0" cellpadding="0" cellspacing="0">';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="0" cellpadding="2" cellspacing="2">';
			strHTML += '				<tr style="background-color: #F4D0C9;">';
			strHTML += '					<td width="110px" class="txtNormalBold">Tipo</td>';
			strHTML += '					<td width="200px" class="txtNormalBold">Número de Controle</td>';
			strHTML += '					<td width="150px" class="txtNormalBold" align="right">Valor</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Hora</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Origem</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Dbt.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Dbt.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Dbt.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Banco Crd.</td>';
			strHTML += '					<td width="100px" class="txtNormalBold" >Agência Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >Conta Crd.</td>';
			strHTML += '					<td width="140px" class="txtNormalBold" >CPF/CNPJ Crd.</td>';
			strHTML += '					<td width="330px" class="txtNormalBold">Nome Crd.</td>';
			strHTML += '					<td width="50px" class="txtNormalBold">Caixa</td>';
			strHTML += '					<td width="100px" class="txtNormalBold">Operador</td>';
			strHTML += '				</tr>';
			strHTML += '			</table>';
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '	<tr>';
			strHTML += '		<td>';
			strHTML += '			<table width="2500px" border="1" cellpadding="2" cellspacing="2">';
			<?php 
			$cor = "";
			
			for ($i = 0; $i < $qtLogDetalhado; $i++) { 
				?>				
				objLog   = new Object();				
				objLog.cdbandst = "<?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?>";
				objLog.cdagedst = "<?php echo $logDetalhado[$i]->tags[2]->cdata; ?>";
				objLog.nrctadst = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?>";
				objLog.dsnomdst = "<?php echo $logDetalhado[$i]->tags[4]->cdata; ?>";
				objLog.dscpfdst = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?>";				
				objLog.cdbanrem = "<?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?>";
				objLog.cdagerem = "<?php echo $logDetalhado[$i]->tags[7]->cdata; ?>";
				objLog.nrctarem = "<?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?>";
				objLog.dsnomrem = "<?php echo $logDetalhado[$i]->tags[9]->cdata; ?>";
				objLog.dscpfrem = "<?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?>";								
				objLog.vltransa = "<?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?>";
				objLog.dsmotivo = "<?php echo $logDetalhado[$i]->tags[13]->cdata; ?>";
				objLog.cdispbrem = "<?php echo ($logDetalhado[$i]->tags[6]->cdata != 1 && $logDetalhado[$i]->tags[21]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[21]->cdata, 8, "0", STR_PAD_LEFT); ?>";
				objLog.cdispbdst = "<?php echo ($logDetalhado[$i]->tags[1]->cdata != 1 && $logDetalhado[$i]->tags[22]->cdata == 0) ? "" : str_pad($logDetalhado[$i]->tags[22]->cdata, 8, "0", STR_PAD_LEFT); ?>";				
				objLog.dstransa = "<?php echo $logDetalhado[$i]->tags[14]->cdata; ?>";
				objLog.nmevento = "<?php echo $logDetalhado[$i]->tags[25]->cdata; ?>";
				objLog.nrctrlif = "<?php echo $logDetalhado[$i]->tags[26]->cdata; ?>";
				objLog.hrtransa = "<?php echo $logDetalhado[$i]->tags[11]->cdata; ?>";
				detalhes[<?php echo $i; ?>] = objLog;
				<?php
				if ($cor == "#F4F3F0") {
					$cor = "#FFFFFF";
				} else {
					$cor = "#F4F3F0";
				}		

				$nrctalog = formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-");
				
			?>
			strHTML += '				<tr id="trMsgLog<?php echo $i; ?>" style="cursor: pointer; background-color: <?php echo $cor; ?>" onClick="selecionaMsgLog(<?php echo $i; ?>,<?php echo (strpos($logDetalhado[$i]->tags[14]->cdata,'NAO OK')) ? 1 : 0; ?>);">';
			strHTML += '					<td width="110px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[25]->cdata; ?></td>'; 
			strHTML += '					<td width="200px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[26]->cdata; ?></td>';
			strHTML += '					<td width="150px" class="txtNormal" align="right"><?php echo number_format(str_replace(",",".",$logDetalhado[$i]->tags[12]->cdata),2,",","."); ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[11]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[15]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[6]->cdata == 0 ? "" : $logDetalhado[$i]->tags[6]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[7]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[8]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[10]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[9]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[1]->cdata == 0 ? "" : $logDetalhado[$i]->tags[1]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[2]->cdata; ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("zzz.zzz.zzz.zzz.zzz.zzz.zzz-9",$logDetalhado[$i]->tags[3]->cdata,".-"); ?></td>';
			strHTML += '					<td width="140px" class="txtNormal" align="left"><?php echo formataNumericos("99999999999999",$logDetalhado[$i]->tags[5]->cdata,""); ?></td>';
			strHTML += '					<td width="330px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[4]->cdata; ?></td>';
			strHTML += '					<td width="50px" class="txtNormal"  align="left"><?php echo $logDetalhado[$i]->tags[17]->cdata; ?></td>';
			strHTML += '					<td width="100px" class="txtNormal" align="left"><?php echo $logDetalhado[$i]->tags[18]->cdata; ?></td>';
			strHTML += '				</tr>';
			<?php
				$qtdtotal = $qtdtotal + 1;
				$vlrtotal = $vlrtotal + str_replace(",", ".", $logDetalhado[$i]->tags[12]->cdata);
			} // Fim do for
			?>				
			strHTML += '			</table>';
			strHTML += '		</td>';
			strHTML += '	</tr>';
			strHTML += '</table>';
			strHTML += '</div>';
			
			strHTML += '<div id="divPesquisaRodape" class="divPesquisaRodape">';
			strHTML += '	<table>';
			strHTML += '		<tr>';
			strHTML += '			<td>';
			
			<? 
			// Somar quantidade e valores totais recebidos da temp-table
			$qtdtate = $logTotais[0]->tags[0]->cdata + 
					   $logTotais[0]->tags[2]->cdata + 
					   $logTotais[0]->tags[4]->cdata + 
					   $logTotais[0]->tags[6]->cdata + 
					   $logTotais[0]->tags[9]->cdata;
					   
			$vlrate = str_replace(",", ".", $logTotais[0]->tags[1]->cdata);
			$vlrate = $vlrate + str_replace(",", ".", $logTotais[0]->tags[3]->cdata);
			$vlrate = $vlrate + str_replace(",", ".", $logTotais[0]->tags[5]->cdata); 
			$vlrate = $vlrate + str_replace(",", ".", $logTotais[0]->tags[7]->cdata); 
			$vlrate = $vlrate + str_replace(",", ".", $logTotais[0]->tags[10]->cdata);
			
						
			// Se a paginação não está na primeira, exibe botão voltar
			if ($nriniseq > 1) { 
				?> strHTML += '<a class="paginacaoAnt"><<< Anterior</a>'; <? 
			} else {
				?> strHTML += '&nbsp;'; <?
			}
				
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<? 
			if (isset($nriniseq)) {
					if (($nriniseq + $nrregist) > $qtdtate){
					?> 
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo $qtdtate; ?> de <? echo $qtdtate; ?>';
					<?
					}else{
					?>
						strHTML += 'Exibindo <? echo $nriniseq; ?> at&eacute; <? echo ($nriniseq + $nrregist - 1); ?> de <? echo $qtdtate; ?>';
					<?
					}
			}
			
			?>
			
			strHTML += '			</td>';
			strHTML += '			<td>';
			
			<?
			
			// Se a paginação não está na &uacute;ltima página, exibe botão proximo
			if ($qtdtate > ($nriniseq + $nrregist - 1)) {
				?> strHTML += '<a class="paginacaoProx">Pr&oacute;ximo >>></a>'; <?
			} else {
				?> strHTML += '&nbsp;'; <?
			}
			?>
			
			strHTML += '			</td>';
			strHTML += '		</tr>';
			strHTML += '	</table>';
			strHTML += '</div>';
			
			strHTML += '<br>';
			strHTML += '<label for="qtdtotal" class="txtNormalBold" style="padding-right: 3px;">Quantidade Total:</label>';
			strHTML += '<input style="width: 45px;" class="campoTelaSemBorda" type="text" id="qtdtotal" name="qtdtotal" value="<?php echo $qtdtate ?>" readonly ></input>';
			strHTML += '<label for="vlrtotal" class="txtNormalBold" style="padding-right: 3px; padding-left: 15px;">Valor Total:</label>';
			strHTML += '<input style="width: 100px;" class="campoTelaSemBorda" type="text" id="vlrtotal" name="vlrtotal" value="<?php echo number_format($vlrate,2,",","."); ?>" readonly ></input>';
			
			<?php 
			
		 }
		 ?>
			strHTML += '&nbsp;&nbsp;&nbsp;&nbsp;';
			strHTML += '<a href="#" class="botao" id="btImpCsv" onClick="ImprimirTodos(1); return false;">CSV</a>';
			strHTML += '&nbsp;&nbsp;&nbsp;&nbsp;';
			strHTML += '<a href="#" class="botao" id="btImpPdf" onClick="ImprimirTodos(2); return false;">PDF</a>';
			strHTML += '<form id="frmImpressao2"></form>';
		 <?php
	}
	
	// Mostra conteúdo do log
	echo '$("#divConteudoLog").html(strHTML);';
	echo '$("#divConteudoLog").css("display","block");';
	
	echo '$("#divPesquisaRodape").formataRodapePesquisa();';
	
	
	echo 'hideMsgAguardo();';	
	
	?>
	
	$('a.paginacaoAnt').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq - $nrregist)."','".$nrregist."'"; ?>);
	});
	$('a.paginacaoProx').unbind('click').bind('click', function() {
		controlaOperacao(<? echo "'".($nriniseq + $nrregist)."','".$nrregist."'"; ?>);
	});	
	
	<?php
	
	function exibeErro($msgErro) {
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - LOGSPB","$(\'#flgidlog\',\'#frmLogSPB\').focus()");';
		exit();	
	}
?>