 <? 
/*!
 * FONTE        : manter_fisico.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/06/2010 
 * OBJETIVO     : Rotina para validar/alterar os dados de pessoa da tela MATRIC
 * --------------
 * ALTERAÇÕES	: 24/02/2011 - Tirada validacao de (nrcadast == 0) do campo cad. emp. (Jorge)
 * 				  09/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *				  09/08/2013 - Incluido campo UF de naturalidade. (Reinert)
 *                28/01/2015 - #239097 Ajustes para cadastro de Resp. legal 0 menor/maior (Carlos)
 *                09/07/2015 - Projeto Reformulacao Cadastral (Gabriel-RKAM). 
				  17/06/2016 - M181 - Alterar o CDAGENCI para passar o CDPACTRA (Rafael Maciel - RKAM)
				  25/10/2016 - M310 - Tratamento para abertura de conta com CNAE CPF/CPNJ restrito ou proibidos.
 *                12/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 
 *                17/10/2017 - Ajuste para carregar idade ao validadr dados. PRJ339-CRM (Odirle/AMcom).
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Recebendo as variáveis
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;	
	$nmprimtl = (isset($_POST['nmprimtl'])) ? $_POST['nmprimtl'] : '' ;	
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '' ;
	$dtcnscpf = (isset($_POST['dtcnscpf'])) ? $_POST['dtcnscpf'] : '' ;
	$cdsitcpf = (isset($_POST['cdsitcpf'])) ? $_POST['cdsitcpf'] : '' ;
	$tpdocptl = (isset($_POST['tpdocptl'])) ? $_POST['tpdocptl'] : '' ;
	$nrdocptl = (isset($_POST['nrdocptl'])) ? $_POST['nrdocptl'] : '' ;
	$cdoedptl = (isset($_POST['cdoedptl'])) ? $_POST['cdoedptl'] : '' ;
	$cdufdptl = (isset($_POST['cdufdptl'])) ? $_POST['cdufdptl'] : '' ;
	$dtemdptl = (isset($_POST['dtemdptl'])) ? $_POST['dtemdptl'] : '' ;
	$tpnacion = (isset($_POST['tpnacion'])) ? $_POST['tpnacion'] : '' ;
	$cdnacion = (isset($_POST['cdnacion'])) ? $_POST['cdnacion'] : '' ;
	$dsnatura = (isset($_POST['dsnatura'])) ? $_POST['dsnatura'] : '' ;
	$cdufnatu = (isset($_POST['cdufnatu'])) ? $_POST['cdufnatu'] : '' ;
	$cdsexotl = (isset($_POST['cdsexotl'])) ? $_POST['cdsexotl'] : '' ;
	$cdestcvl = (isset($_POST['cdestcvl'])) ? $_POST['cdestcvl'] : '' ;
	$cdempres = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : '' ;
	$nrcadast = (isset($_POST['nrcadast'])) ? $_POST['nrcadast'] : '' ;
	$cdocpttl = (isset($_POST['cdocpttl'])) ? $_POST['cdocpttl'] : '' ;
	$nmmaettl = (isset($_POST['nmmaettl'])) ? $_POST['nmmaettl'] : '' ;
	$dsendere = (isset($_POST['dsendere'])) ? $_POST['dsendere'] : '' ;
	$nmbairro = (isset($_POST['nmbairro'])) ? $_POST['nmbairro'] : '' ;
	$nrcepend = (isset($_POST['nrcepend'])) ? $_POST['nrcepend'] : '' ;
	$nmcidade = (isset($_POST['nmcidade'])) ? $_POST['nmcidade'] : '' ;
	$cdufende = (isset($_POST['cdufende'])) ? $_POST['cdufende'] : '' ;
	$dtdemiss = (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '' ;
	$dtnasctl = (isset($_POST['dtnasctl'])) ? $_POST['dtnasctl'] : '' ;
	$inhabmen = (isset($_POST['inhabmen'])) ? $_POST['inhabmen'] : '' ;
	$dthabmen = (isset($_POST['dthabmen'])) ? $_POST['dthabmen'] : '' ;
	$idorigee = (isset($_POST['idorigee'])) ? $_POST['idorigee'] : '' ;

	$arrayFilhos = (isset($_POST['arrayFilhos'])) ? $_POST['arrayFilhos'] : '';
	
	if ( ($operacao == 'AV') || ($operacao == 'IV') ) validaDados($glbvars['cdcooper'], $glbvars['cdpactra'], $glbvars['nrdcaixa'], $glbvars['idorigem'], $glbvars['cdoperad']);
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	$inpessoa = 1;
	
	switch($operacao) {
	
		case 'IV': $procedure = 'valida_dados'; $cddopcao = 'I'; break;
		case 'VI': $procedure = 'grava_dados' ; $cddopcao = 'I'; break;
		case 'AV': $procedure = 'valida_dados'; $cddopcao = 'A'; break;
        /* Validação pela include do responsavel legal*/
        case 'AR': $procedure = 'valida_dados'; $cddopcao = 'A'; break;
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = 'A'; break;
		case 'PI': $procedure = 'valida_dados'; $cddopcao = "PI"; break;
		case 'PA': $procedure = 'valida_dados'; $cddopcao = "PA"; break;
		default: return false;
		
	}
	
	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0052.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdpactra'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';    	
	$xml .= '       <idseqttl>1</idseqttl>'; 
	
	// Concatenar os parametros via POST para o XML
	foreach ($_POST as $key => $value) {

		// Desconsiderar certos parametros
		if (in_array($key,array('arrayFilhos'))) {
			continue;
		}
		
		// Retirar caracteres nao desejados
		if ($key == 'complend' || $key == 'dsendere') {
			$array1 = array("=","%","&","#","+","?","'",",",".","/",";","[","]","!","@","$","(",")","*","|",":","<",">","~","{","~","}","~");

			// limpeza dos caracteres nos campos 
			$value = trim(str_replace( $array1, " " , $value));
		}
		
		$xml .= "<$key>$value</$key>";   
		
	} 
	  
	if($procedure == 'valida_dados' || $procedure == 'grava_dados'){

		// Resp. Legal
		foreach ($arrayFilhos as $key => $value) {
			$campospc = "";
			$dadosprc = "";
			$contador = 0;
			
			foreach( $value as $chave => $valor ){
				
				$contador++;
				if($contador == 1){
					$campospc .= $chave;
					$dadosprc .= $valor;
				}else{
					$campospc .= "|".$chave;
					$dadosprc .= ";".$valor;
				}
			}
			$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'RespLegal', 'Responsavel');			
		}
	}
	
	if($procedure == 'grava_dados'){
		$xml .= '       <idorigee>'.$idorigee.'</idorigee>';
		$xml .= '       <nrlicamb>0</nrlicamb>';
	}
	
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';          
	
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	$nrdeanos = $xmlObjeto->roottag->tags[0]->attributes["NRDEANOS"];
	
    if($procedure == 'valida_dados'){
        ?>  		
            nrdeanos = <? if($nrdeanos == null){ echo 0;} else { echo $nrdeanos; } ?>;
        <?
    }  
	 
	// Include do arquivo que analisa o resultado do XML
	include('./manter_resultado.php');		
	
	if($operacao == "PI" || $operacao == "PA"){	
		
		//Data de nascimento
		if ( !validaData( $GLOBALS['dtnasctl'] ) || ( $GLOBALS['dtnasctl'] == '' ) ) exibirErro('error','Data de nascimento inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dtnasctl\',\'frmFisico\');',false);
	
		// Responsabilidade Legal
		if (($inhabmen != 0)&&($inhabmen != 1)&&($inhabmen != 2)) exibirErro('error','Responsabilidade Legal inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'inhabmen\',\'frmFisico\')',false);
		
		// Somente valida a Data de Emancipação quando a Responsabilidade Legal for 1 (Habilitado)
		if (!validaData($dthabmen) && ($inhabmen == 1)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dthabmen\',\'frmFisico\')',false);

		// Data de emancipação não pode ser preenchida para quando a Responsabilidade legal for 0,2.
		if ($dthabmen != '' && ($inhabmen == 0 || $inhabmen == 2)) exibirErro('error','Data de Emancipa&ccedil;&atilde;o n&atilde;o pode ser preenchida.','Alerta - Ayllos','focaCampoErro(\'dthabmen\',\'frmFisico\')',false);
			
		?>  
			nrdeanos = <? echo $xmlObjeto->roottag->tags[0]->attributes["NRDEANOS"]; ?>;
			operacao = aux_operacao;
			controlaBotoes();
			hideMsgAguardo(); 			
		<?
			
	}
	
	// Verificar se nao é um CPF ou CNPJ bloqueado por responsabilidade social
	function verificaCpfCnpjBloqueado($cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad, $inpessoa, $nrcpfcgc){
		
		// Monta o xml de requisição
		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= " <Dados>";
		$xml       .=		"<inpessoa>".$inpessoa."</inpessoa>";
		$xml       .=		"<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
		$xml 	   .= " </Dados>";
		$xml 	   .= "</Root>";		
		
		$xmlResult = mensageria($xml, "COCNPJ", "VERIFICA_CNPJ", $cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad, "</Root>");		
		$xmlObjeto = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
			$nmdcampo = $xmlObjeto->roottag->tags[0]->attributes["NMDCAMPO"];

			if(empty ($nmdcampo)){ 
				$nmdcampo = "nrcpfcgc";
			}
			
			exibirErro('error',utf8_encode($msgErro),'Alerta - Ayllos','focaCampoErro(\''.$nmdcampo.'\',\'frmFisico\');',false);		
						
		} else {
			
			/*aqui manda msg pra tela*/
			$bloqueado = $xmlObjeto->roottag->tags[0]->cdata;
			
			if($bloqueado == 'SIM'){
				return true;
			}else{
				return false;
			}
			

		}
		
		return false;
	}
	
	// Validações em PHP
	function validaDados($cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad){
		
		echo '$("input,select","#frmFisico").removeClass("campoErro");';
		
		//-----------------------------
		//	   Documentos Tilular	  
		//-----------------------------
		
		//Nome do titular
		if ( $GLOBALS['nmprimtl'] == ''  ) exibirErro('error','Nome deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nmprimtl\',\'frmFisico\');',false);
		
		//CPF
		if ( $GLOBALS['nrcpfcgc'] == '' || $GLOBALS['nrcpfcgc'] == 0 ) exibirErro('error','CPF deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmFisico\');',false);
								
        //CPF Responsabilidade social		
		if( verificaCpfCnpjBloqueado($cdcooper, $cdagenci, $nrdcaixa, $idorigem, $cdoperad, 1, $GLOBALS['nrcpfcgc']) == true ){			
			exibirErro('error','CPF n&atilde;o autorizado, conforme previsto na Pol&iacute;tica de Responsabilidade Socioambiental do Sistema CECRED.','Alerta - Ayllos','focaCampoErro(\'nrcpfcgc\',\'frmFisico\');',false);
		} 
			
		//Situação
		if ( $operacao == 'AV' && $GLOBALS['cdsitcpf'] == ''  ) exibirErro('error','Situação deve ser selecionada.','Alerta - Ayllos','focaCampoErro(\'cdsitcpf\',\'frmFisico\');',false);
		
		//Tipo do documento
		if ( $GLOBALS['tpdocptl'] == ''  ) exibirErro('error','Tipo do documento deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'tpdocptl\',\'frmFisico\');',false);
		
		//Nº do documento
		if ( $GLOBALS['nrdocptl'] == ''  ) exibirErro('error','Número do documento deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nrdocptl\',\'frmFisico\');',false);
		
		//Orgão emissor
		if ( $GLOBALS['cdoedptl'] == ''  ) exibirErro('error','Orgão emissor deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'cdoedptl\',\'frmFisico\');',false);
		
		//UF emissor
		if ( $GLOBALS['cdufdptl'] == ''  ) exibirErro('error','UF emissor deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'cdufdptl\',\'frmFisico\');',false);
		
		//Data de emissão do documento
		if ( !validaData( $GLOBALS['dtemdptl'] ) || ( $GLOBALS['dtemdptl'] == '' ) ) exibirErro('error','Data de emissão inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dtemdptl\',\'frmFisico\');',false);
		
		//-----------------------------
		//	 Inf. Complementares	  
		//-----------------------------
		
		//Tipo do nacionalidade
		if ( $GLOBALS['tpnacion'] == ''  ) exibirErro('error','Tipo de nacionalidade deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'tpnacion\',\'frmFisico\');',false);
		
		//Nacionalidade
		if ( $GLOBALS['cdnacion'] == ''  ) exibirErro('error','Nacionalidade deve ser preeenchida.','Alerta - Ayllos','focaCampoErro(\'cdnacion\',\'frmFisico\');',false);
		
		//Data de nascimento
		if ( !validaData( $GLOBALS['dtnasctl'] ) || ( $GLOBALS['dtnasctl'] == '' ) ) exibirErro('error','Data de nascimento inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dtnasctl\',\'frmFisico\');',false);
		
		//Naturalidade
		if ( $GLOBALS['dsnatura'] == ''  ) exibirErro('error','Naturalidade deve ser preeenchida.','Alerta - Ayllos','focaCampoErro(\'dsnatura\',\'frmFisico\');',false);
		
		//UF
		if ( $GLOBALS['cdufnatu'] == ''  ) exibirErro('error','UF de naturalidade deve ser selecionada.','Alerta - Ayllos','focaCampoErro(\'cdufnatu\',\'frmFisico\');',false);
		
		//Sexo
		if ( $GLOBALS['cdsexotl'] == '' ||  settype( $GLOBALS['cdsexotl'] , "integer") != 1 || settype( $GLOBALS['cdsexotl'] , "integer") != 2 ) exibirErro('error','Sexo inválido.','Alerta - Ayllos','focaCampoErro(\'sexoMas\',\'frmFisico\');',false);
		
		//Estado Civil
		if ( $GLOBALS['cdestcvl'] == ''  ) exibirErro('error','Estado civil deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'cdestcvl\',\'frmFisico\');',false);
		
		//Empresa
		if ( $GLOBALS['cdempres'] == ''  ) exibirErro('error','Empresa deve ser selecionada.','Alerta - Ayllos','focaCampoErro(\'cdempres\',\'frmFisico\');',false);
		
		//Cad. emp.
		if ( $GLOBALS['nrcadast'] == ''  ) exibirErro('error','Cad. emp. deve ser preenchida.','Alerta - Ayllos','focaCampoErro(\'nrcadast\',\'frmFisico\');',false);
		
		//Ocupação
		if ( $GLOBALS['cdocpttl'] == ''  ) exibirErro('error','Ocupação deve ser selecionada.','Alerta - Ayllos','focaCampoErro(\'cdocpttl\',\'frmFisico\');',false);
		
		//-----------------------------
		//		     Filiação	  
		//-----------------------------
				
		//Nome da mãe
		if ( $GLOBALS['nmmaettl'] == ''  ) exibirErro('error','Nome da mãe deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nmmaettl\',\'frmFisico\');',false);
		
		//-----------------------------
		//		    Endereço	  
		//-----------------------------

		//CEP
		if ( $GLOBALS['nrcepend'] == '' || $GLOBALS['nrcepend'] == 0 ) exibirErro('error','CEP deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nrcepend\',\'frmFisico\');',false);
		
		//Endereço
		if ( $GLOBALS['dsendere'] == ''  ) exibirErro('error','Endereço deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'dsendere\',\'frmFisico\');',false);
		
		//Bairro
		if ( $GLOBALS['nmbairro'] == ''  ) exibirErro('error','Bairro deve ser preenchido.','Alerta - Ayllos','focaCampoErro(\'nmbairro\',\'frmFisico\');',false);
		
		//U.F.
		if ( $GLOBALS['cdufende'] == ''  ) exibirErro('error','U.F. deve ser selecionado.','Alerta - Ayllos','focaCampoErro(\'cdufende\',\'frmFisico\');',false);

		//Cidade
		if ( $GLOBALS['nmcidade'] == ''  ) exibirErro('error','Cidade deve ser preenchida.','Alerta - Ayllos','focaCampoErro(\'nmcidade\',\'frmFisico\');',false);
		
		
		//-----------------------------
		//   Entrada/Saída Cooperado	  
		//-----------------------------
		
		
		//Data de saída
		if ( ( $GLOBALS['dtdemiss'] != '' ) && !validaData( $GLOBALS['dtdemiss'] ) ) exibirErro('error','Data de sa&iacute;da inv&aacute;lida.','Alerta - Ayllos','focaCampoErro(\'dtdemiss\',\'frmFisico\');',false);
			
		
	}	
?>
