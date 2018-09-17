 <?php
/*!
 * FONTE        : upload.php
 * CRIAÇÃO      : Tiago Machado Flor
 * DATA CRIAÇÃO : 14/09/2017
 * OBJETIVO     : Rotina para upload de arquivo remessa
 * --------------
 * ALTERAÇÕES   : 24/11/2017 - Ajustado validação do nome do arquivo e a validação do inpessoa 
 *                             (Douglas - Melhoria 271.3)
 * --------------
 */?>
<?
	if( !ini_get('safe_mode') ){
		set_time_limit(300);
	}
	session_cache_limiter("private");
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	
	isPostMethod();
	
    $table_erros = "";
	
	// Ler parametros passados via POST
	$cddopcao = (isset($_POST['cddopcao']))  ? $_POST['cddopcao']  : '';
	$file     = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';
	$flglimpa = (isset($_POST['flglimpa'])) ? $_POST['flglimpa'] : '0';
	$nrdconta = (isset($_POST['nudconta'])) ? $_POST['nudconta'] : '0';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '0';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '0';
	$cdcooper = (isset($glbvars['cdcooper'])) ? $glbvars['cdcooper'] : '0';
	$flghomol = (isset($_POST['flghomol'])) ? $_POST['flghomol'] : '0';
	$cdagectl = (isset($_POST['cdagectl'])) ? $_POST['cdagectl'] : '0';
	$nrconven = '1';
	$aux_remessa = 0;
	
	// decode do INPESSOA - Se for 1 "PF" vai continuar com 1, caso contrario eh 2 -"PJ" 
	$inpessoa = ($inpessoa == 1) ? 1 : 2;

	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
    $tempo    = time();
    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	//$nmupload  = "../../upload_files/cocnae." . $tempo . $nrdconta . $cdcooper .".txt";

	// Função que converte a data no formado d/m/y para ymd.
	function converter_data_num($data) {
		$dat = split("/", $data);
		$new_date = $dat[2] . $dat[1] . $dat[0];

		return $new_date;
	}	
	
    function geraLogArqRemessa($pr_dsmsglog, $pr_nrdconta, $pr_cdoperad, $pr_nrremret, $pr_filename){				   
		global $glbvars;
		
		// Monta o xml de requisição		
		$xml  		= "";
		$xml 	   .= "<Root>";
		$xml 	   .= "  <Dados>";
		$xml 	   .= "     <nrdconta>".$pr_nrdconta."</nrdconta>";
		$xml 	   .= "     <nrconven>1</nrconven>";
		$xml 	   .= "     <tpmovimento>1</tpmovimento>";
		$xml 	   .= "     <nrremret>".$pr_nrremret."</nrremret>";
		$xml 	   .= "     <nmoperad_online>".$pr_cdoperad."</nmoperad_online>";
		$xml 	   .= "     <cdprograma>UPPGTO</cdprograma>";
		$xml 	   .= "     <nmtabela>CRAPHPT</nmtabela>";
		$xml 	   .= "     <nmarquivo>".$pr_filename."</nmarquivo>";
		$xml 	   .= "     <dsmsglog>".$pr_dsmsglog."</dsmsglog>";	
		$xml 	   .= "  </Dados>";
		$xml 	   .= "</Root>";
		
		// Executa script para envio do XML	
		$xmlResult = mensageria($xml, "PGTA0001", "GERALOGARQPGTO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObj = getObjectXML($xmlResult);
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObj->roottag->tags[0]->name) == "ERRO") {
		
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
			
			exibirErro('error',$msgErro,'Alerta - Ayllos','estadoInicial();',false);		
			
			return false;
			
		} 

		return true;
    }
	/*Fim do log*/	

	
	// FUNÇÕES PARA CALCULAR DIFERENÇAS DE DATA / HORA
	// Formador Ymd
	// Retorno: valor da diferença em minutos.
	function dif_data($DataI, $DataF) {
		$DataInicial = getdate(strtotime($DataI));
		$DataFinal = getdate(strtotime($DataF));

		// Calcula a Diferença
		$Dif = ($DataFinal[0] - $DataInicial[0]) / 60;

		return $Dif;
	}	
	
	$nmupload  = "uppgto.txt";
	
    // CONVERTER STRING DO NOME PARA MAIUSCULO....
    $file["name"] = strtoupper($file["name"]);
	$aux_nmupload = "/tmp/".$cdcooper.".".$nrdconta.".";

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		$msgError = "Erro ao validar permiss&atilde;o de acesso!";
		$funcao = "msgError('error','".$msgError."','hideMsgAguardo();');";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		exit();
		
	}

	// Instanciar arrays....
	$arrCrit    = array();
	$arrStrFile = array();

	// se destinatario for por upload file
	if($file["error"] > 0){
		switch($file["error"]){
			case 1:	$arrCrit[] = "ATENCAO: Tamanho do arquivo excedeu o permitido.";		break;
			case 2:	$arrCrit[] = "ATENCAO: Tamanho do arquivo deve conter menos de 8 mb.";  break;
			case 3:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER3.";					break;
			case 4:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER4.";					break;
			case 6:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER6.";					break;
			case 7:	$arrCrit[] = "ATENCAO: Falha ao gravar arquivo ER7.";					break;
			case 8:	$arrCrit[] = "ATENCAO: Falha ao enviar arquivo ER8.";					break;
		}
	}

	// Se não encontrar o arquivo...
	if($file == ""){
		$arrCrit[] = "ATENCAO: Arquivo n&atilde;o encontrado.";
	}
	// Verificar o tamanho do arquivo
	if($file["size"] > (1 * (1024 * 1024))){
		$arrCrit[] = "ATENCAO: Tamanho do arquivo deve ser menor que 8 mb.";
	}
	// Validar o arquivo
	if(!is_uploaded_file($file["tmp_name"])){
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL1.";
	}
	if (!move_uploaded_file($file["tmp_name"], $nmupload)) {
		$arrCrit[] = "ATENCAO: Erro ao validar arquivo. *VL2.";
	}
	
	
    // Validar nome do arquivo
	// Validar nome do arquivo
	$file_name = substr($file["name"], 0, 3);
	if ($file_name <> "PGT") { // Não inicia com PGT
		$arrCrit[] = "Nome do arquivo fora do padr&atilde;o!";
	}
	
	// gerar erros criticos
	if(count($arrCrit) > 0){
		$funcao = "msgError('error','".$arrCrit[0]."','hideMsgAguardo();');";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		exit();
	}

    $strFile = file_get_contents($nmupload);	
	$aux_nmarquivo = $file["name"];	
	
	// Definir array dos caracteres a serem substituidos
    $caracteres = array();
    $caracteres[0] = "/\;/";
    $caracteres[1] = "/\"/";
    $caracteres[2] = "/\'/";
    $caracteres[3] = "/\>/";
    $caracteres[4] = "/\</";
    $caracteres[5] = "/\`/";
    $caracteres[6] = "/\´/";
     
    $substituto = array();
    $substituto[0] = ' ';
    $substituto[1] = ' ';
    $substituto[2] = ' ';
    $substituto[3] = ' ';
    $substituto[4] = ' ';
    $substituto[5] = ' ';
    $substituto[6] = ' ';
    
     /* Retirar caracteres especiais da linha do arquivo, pois causam problemas
        ao serem lidos no php ou ambiente unix. */
    $strFile = preg_replace($caracteres,$substituto,$strFile);
	
	// Verificar se os tres primeiros caracteres identificam o arquivo no formato UTF-8
	if ( substr( $strFile ,0 , 3) == "ï»¿") {
		// Descartar os três primeiros caracteres do UTF-8
		$strFile = substr( $strFile, 3);
	}

	// remover o caracter acentuado pelo caracter correspondente sem acento
	$strFile = strtr($strFile, "àáâãäåÀÁÂÃÄÅèéêëÈÉÊËìíîïÌÍÎÏòóôõöøÒÓÔÕÖØùúûüÙÚÛÜçÇñÑÿŸ", 
	                           "aaaaaaAAAAAAeeeeEEEEiiiiIIIIooooooOOOOOOuuuuUUUUcCnNyY");

    // Reescrever o arquivo que fez replace 
    file_put_contents($nmupload, $strFile);
	
	//explode string em um array quando encontrar quebra de linha
	$arrStrFile = explode("\n",$strFile);
    
	
	// Indicadores de HEADER
	$header_arq  = 0;
	$header_lote = 0;
	
	// Indicador de linha de detalhe
	$linha_detalhe = 0;
	
	// Indicadores de TRAILER
	$trailer_arq  = 0;
	$trailer_lote = 0;

	// Inicializar o contador e o total do lote
	$qtd_reg  = 0;
	$valor_total_pagamento = 0;	

	for($i=0;$i<count($arrStrFile);$i++){
		$aux_linha_arq = $arrStrFile[$i];
		
		// ignorar as linhas em branco do arquivo
		if ( strlen (trim($aux_linha_arq) ) == 0 ) {
			continue;
		}
		
	    //verifica se contem numero de caracteres correto
		if((strlen($aux_linha_arq) != 240) && 
		   (!((strlen($aux_linha_arq) == 241) && (substr($aux_linha_arq,240) == "\r"))) &&
		   (!(($i == (count($arrStrFile) - 1)) && (strlen($aux_linha_arq) == 0))) )	{				

				$arrCrit[] = "Tamanho fora do padrão em linha ".($i+1).".";
		}
	
		// Tratamento para HEADER do arquivo
		if ( substr($aux_linha_arq, 7, 1) == "0" ) {
            
			// Verificar se o NSU eh numerico
			if ( !is_numeric(substr($aux_linha_arq,157, 6)) ) {
				$arrCrit[] = "Numero sequencial no header do arquivo invalido: " . substr($aux_linha_arq,157, 6);
			}
			
			// O numero da remessa sera carregado da primeira linha do arquivo
			$aux_remessa = (int) substr($aux_linha_arq, 157, 6);
			
			// 01.0 Codigo do banco na compensacao
			if ( substr($aux_linha_arq, 0, 3) <> "085" ) {
				$arrCrit[] = "Banco de compensação do arquivo divergente do banco de compensação do cooperado! - Header Arquivo: " . substr($aux_linha_arq, 0, 3);
			}
			
			// 02.0 Lote de Servico
			if ( substr($aux_linha_arq, 3, 4) <> "0000" ) {
				$arrCrit[] = "Lote de servico no header do arquivo invalido: ". substr($aux_linha_arq, 3, 4);
			}
			
			// 03.0 Tipo de Registro
			if ( substr($aux_linha_arq, 7, 1) <> "0" ) {
				$arrCrit[] = "Tipo de registro no header do arquivo invalido: " . substr($aux_linha_arq, 7, 1);
			}
			
			// 05.0 Tipo de Inscricao do Cooperado
			if ( substr($aux_linha_arq,17, 1) <> "2" ) { // Pessoa Juridica
				$arrCrit[] = "Tipo de inscricao no header do arquivo invalida: " . substr($aux_linha_arq,17, 1);
			}
			
            // 06.0 Numero de Inscricao do Cooperado
			if ( !is_numeric(substr($aux_linha_arq,18,14)) ) {
				$arrCrit[] = "CPF/CNPJ informado no header do arquivo invalido: " . substr($aux_linha_arq,18,14);
		    } else {
				$aux_nrcpfcgc_arq  = (int) substr($aux_linha_arq,18,14);
				if ( $nrcpfcgc <> $aux_nrcpfcgc_arq ) {
					$arrCrit[] = "CPF/CNPJ no header do arquivo divergente do CPF/CNPJ do cooperado: " . substr($aux_linha_arq,18,14);
				} else {
					if ( substr($aux_linha_arq,17, 1) <> $inpessoa ) {
						$arrCrit[] = "CPF/CNPJ informado no header do arquivo incompativel com tipo inscricao: " . substr($aux_linha_arq,17, 1);
					}
				}
			}
			
			// 07.0 Código do Convênio no Banco
			if ( !is_numeric(trim(substr($aux_linha_arq,32, 20))) ) {
				$arrCrit[] = "Codigo do convenio no header do arquivo invalido: " . trim(substr($aux_linha_arq,32,20));
	        } else {
				$aux_nrconven_arq  = (int) trim(substr($aux_linha_arq,32,20));
				if ( $aux_nrconven_arq <> $nrconven ) {
					$arrCrit[] = "Codigo do convenio no header do arquivo divergente do convenio do cooperado: " . substr($aux_linha_arq,32,20);
				} else {
					if ( $flghomol == 0 ) {
						$arrCrit[] = "Convenio do cooperado pendente de homologacao!";
					}
				}
			}
			
			// 08.0 a 09.0 Agência Mantenedora da Conta
			if ( !is_numeric(substr($aux_linha_arq,52, 5)) ) {
				$arrCrit[] = "Agencia mantenedora da conta no header do arquivo invalida: " . substr($aux_linha_arq,52, 5);
	        } else {
				$aux_cdagectl_arq  = (int) substr($aux_linha_arq,52, 5);
				if ( $aux_cdagectl_arq <> $cdagectl ) {
					$arrCrit[] = "Agencia mantenedora da conta no header do arquivo divergente da agencia mantenedora do cooperado:  " . substr($aux_linha_arq,52, 5);
				}
			}
			
			// 10.0 a 11.0 Conta/DV
            if ( !is_numeric(substr($aux_linha_arq,58,13)) ) {
				$arrCrit[] = "Conta/DV no header do arquivo invalida: " . substr($aux_linha_arq,58,13);
			} else { 
				$aux_nrdconta_arq = (int) substr($aux_linha_arq,58,13);
				if ($aux_nrdconta_arq <> $nrdconta ) {
					$arrCrit[] = "Conta/DV no header do arquivo divergente da conta do cooperado: " . substr($aux_linha_arq,58,13);
				}
			}
			
			// 16.0 Codigo Remessa/Retorno
            if ( substr($aux_linha_arq,142, 1) <> "1" ) { // '1' = Remessa (Cliente -> Banco)
				$arrCrit[] = "Codigo de remessa nao encontrado no header do arquivo: " . substr($aux_linha_arq,142, 1);
			}

			//  17.0 Data de Geracao de Arquivo
			// validação de data -> checkdate ( int $month , int $day , int $year )
			if ( ! checkdate ( substr($aux_linha_arq,145, 2) , substr($aux_linha_arq,143, 2) , substr($aux_linha_arq,147, 4)) ) {
				$arrCrit[] = "Data de geracao no header do arquivo nao esta em um formato valido: " . substr($aux_linha_arq,143, 8);
			}

			// verificar se o arquivo foi gerado a mais de 30 dias
			$dataHeaderArq = substr($aux_linha_arq,143, 2) . '/' . substr($aux_linha_arq,145, 2) . '/' . substr($aux_linha_arq,147, 4);
			$dataAtual     = $_SESSION["datdodia"]; 
			$difMinutos    = dif_data(converter_data_num($dataHeaderArq), converter_data_num($dataAtual)); 
			$difDias       = $difMinutos / 60 / 24;
			if ( $difDias > 30 ) {
				// Se a data de geração do Header do arquivo for superior a 30 dias, nao podemos aceitar o arquivo
				$arrCrit[] = "Data de geracao do arquivo fora do periodo permitido!";
			}
			
			// Controle se arquivo possui Header de Arquivo
			$header_arq = 1;
		}

		// Validações do Header de Lote
		if ( substr($aux_linha_arq, 7, 1) == "1" ) {
			
			// Inicializar o contador e o total do lote
			$qtd_reg  = 1; // A linha de Header de Lote também entra na contagem de registros
			$valor_total_pagamento = 0;
			
			// 01.1 Codigo do banco na compensacao
			if ( substr($aux_linha_arq, 0, 3) <> "085" ) {
				$arrCrit[] = "Banco de compensação do arquivo divergente do banco de compensação do cooperado! - Header lote: " . substr($aux_linha_arq, 0, 3);
			}
			
			// Tipo de Operacao
			if ( substr($aux_linha_arq, 8, 1) <> "C" ) {
				$arrCrit[] = "Tipo de registro header do lote sem tipo de operação C!" . substr($aux_linha_arq, 8, 1);
		    } 
			
			// 09.1 a 10.1  Numero de Inscricao do Cooperado
			if ( !is_numeric(substr($aux_linha_arq,18,14)) ) {
				$arrCrit[] = "CPF/CNPJ informado no header do lote invalido: " . substr($aux_linha_arq,18,14);
		    } else {
				$aux_nrcpfcgc_arq  = (int) substr($aux_linha_arq,18,14);
				if ( $nrcpfcgc <> $aux_nrcpfcgc_arq ) {
					$arrCrit[] = "CPF/CNPJ no header do lote divergente da CPF/CNPJ do cooperado: " . substr($aux_linha_arq,18,14);
				} else {
					if ( substr($aux_linha_arq,17, 1) <> $inpessoa ) {
						$arrCrit[] = "CPF/CNPJ informado no header do lote incompativel com tipo inscricao: " . substr($aux_linha_arq,17, 1);
					}
				}
			}

			// 14.1 a 15.1 Conta/DV
			if ( !is_numeric(substr($aux_linha_arq,58,13)) ) {
				$arrCrit[] = "Conta/DV no header do lote invalida: " . substr($aux_linha_arq,58,13);
			} else { 
				$aux_nrdconta_arq = (int) substr($aux_linha_arq,58,13);
				if ($aux_nrdconta_arq <> $nrdconta ) {
					$arrCrit[] = "Conta/DV no header do lote divergente da conta do cooperado: " . substr($aux_linha_arq,58,13);
				}
			}
             
			// 12.1 Agência Mantenedora da Conta
			if ( !is_numeric(substr($aux_linha_arq,52, 5)) ) {
				$arrCrit[] = "Agencia mantenedora da conta no header do arquivo invalida: " . substr($aux_linha_arq,52, 5);
	        } else {
				$aux_cdagectl_arq  = (int) substr($aux_linha_arq,52, 5);
				if ( $aux_cdagectl_arq <> $cdagectl ) {
					$arrCrit[] = "Agencia mantenedora da conta no header do arquivo divergente da agencia mantenedora do cooperado:  " . substr($aux_linha_arq,52, 5);
				}
			}

			// 11.1 Código do Convênio no Banco
			if ( !is_numeric(trim(substr($aux_linha_arq,32,20))) ) {
				$arrCrit[] = "Codigo do convenio no header do arquivo invalido:  " . trim(substr($aux_linha_arq,32,20));
	        } else {
				$aux_nrconven_arq  = (int) trim(substr($aux_linha_arq,32,20));
				if ( $aux_nrconven_arq <> $nrconven ) {
					$arrCrit[] = "Codigo do convenio no header do arquivo divergente do convenio do cooperado:  " . trim(substr($aux_linha_arq,32,20));
				}
			}
			
			// Controle se arquivo possui Header de Lote
			$header_lote = 1;
		}

		// LINHA REGISTRO DETALHE
		if ( substr($aux_linha_arq, 7, 1) == "3" ) {
			
			// Neste momento, esta liberado apenas INCLUSAO ou EXCLUSAO
			if ( substr($aux_linha_arq,14, 1) <> "0" && substr($aux_linha_arq,14, 1) <> "9" ) { 
				$arrCrit[] = "Tipo de movimento invalido - Linha: " . ($i + 1);
			}
			
			// 07.3J Tipo de Instrução p/ Movimento
            // '00' = Inclusão de Registro Detalhe Liberado
            // '99' = Exclusão do Registro Detalhe Incluído Anteriormente
            if ( substr($aux_linha_arq,15, 2) <> "00" && substr($aux_linha_arq,15, 2) <> "99" ) {
				$arrCrit[] = "Tipo de Instrução p/ Movimento - Linha: " . ($i + 1);
			}
			
			// 01.3 Codigo do banco na compensacao
			if ( substr($aux_linha_arq, 0, 3) <> "085" ) {
				$arrCrit[] = "Banco de compensação do arquivo divergente do banco de compensação do cooperado! - Detalhe linha " . ($i + 1) . ": " . substr($aux_linha_arq, 0, 3);
			}
			
			// Tipo de Operacao
			if ( substr($aux_linha_arq,13, 1) <> "J" ) {
				$arrCrit[] = "Tipo de registro detalhe do arquivo sem segmento J - Linha: " . ($i + 1);
		    } 
			
			// 08.3J Código Barras
			if ( !is_numeric(substr($aux_linha_arq,17,44)) ) {
				$arrCrit[] = "Codigo de barras/digito verificador invalido - Linha:" . ($i + 1);
			}
			
			// 10.3J Data do Vencimento
			// validação de data -> checkdate ( int $month , int $day , int $year )
			if ( !checkdate(substr($aux_linha_arq,93, 2), substr($aux_linha_arq,91, 2), substr($aux_linha_arq,95, 4)) ) {
				$arrCrit[] = "Data lancamento invalido - Linha:" . ($i + 1);
			}
			
			// 11.3J Valor do Titulo (Nominal)
			if ( !is_numeric(substr($aux_linha_arq, 99,15)) ) {
				$arrCrit[] = "Valor do documento invalido - Linha:" . ($i + 1);
			}
			
			// 12.3J Valor do Desconto + Abatimento
			if ( !is_numeric(substr($aux_linha_arq,114,15)) ) {
				$arrCrit[] = "Valor de desconto invalido - Linha:" . ($i + 1);
			}
			
			// 13.3J Valor da Mora + Multa
			if ( !is_numeric(substr($aux_linha_arq,129,15)) ) {
				$arrCrit[] = "Valor de mora invalido - Linha:" . ($i + 1);
			}

			// 14.3J Data do Pagamento
			// validação de data -> checkdate ( int $month , int $day , int $year )
			if ( !checkdate(substr($aux_linha_arq,146, 2), substr($aux_linha_arq,144, 2), substr($aux_linha_arq,148, 4)) ) {
				$arrCrit[] = "Data do pagamento invalida - Linha:" . ($i + 1);
			}

			// 15.3J Valor do Pagamento
			if ( !is_numeric(substr($aux_linha_arq,152,15)) ) {
				$arrCrit[] = "Valor do pagamento invalido - Linha:" . ($i + 1);
			}
			
			// 16.3J Quantidade da Moeda
			if ( !is_numeric(substr($aux_linha_arq,167, 5)) ) {
				$arrCrit[] = "Quantidade da moeda invalido - Linha:" . ($i + 1);
			}
			
			// 19.3J Código da Moeda
			if ( !is_numeric(substr($aux_linha_arq,222, 2)) ) {
				$arrCrit[] = "Codigo da moeda invalido - Linha:" . ($i + 1);
			}
			

			// Incrementar a quantidade de registros e totalizar o valor do lote
			$qtd_reg++;
			$valor_pagamento = (int) substr($aux_linha_arq,152,15);
			$valor_total_pagamento = $valor_total_pagamento + $valor_pagamento;

			$linha_detalhe = 1;
		}

		// Verificar se existe linha com o trailer do lote
		if ( substr($aux_linha_arq, 7, 1) == "5" ) {
			// A linha de Trailer de Lote também entra na contagem de registros
			$qtd_reg++;

			// 01.5 Codigo do banco na compensacao
			if ( substr($aux_linha_arq, 0, 3) <> "085" ) {
				$arrCrit[] = "Banco de compensação do arquivo divergente do banco de compensação do cooperado! - Trailer lote: " . substr($aux_linha_arq, 0, 3);
			}
		
			// validar valor total de lancamentos com o trailer de lote
			if (is_numeric(substr($aux_linha_arq,23,18))) {
				$valor_total_lote = (int) substr($aux_linha_arq,23,18);
				if ($valor_total_lote != $valor_total_pagamento) {
					$arrCrit[] = "Valor total do lote difere do valor total dos lancamentos. " . 
					             " Total Pagamento = " . $valor_total_pagamento .
								 " / Total Lote = " .  $valor_total_lote .
								 " - Linha: " .($i+1).".";
				}
			} else {
				$arrCrit[] = "Valor total do lote invalido - Linha: " .($i+1).".";			
			}
			
		    // validar valor total de lancamentos com o trailer de lote
			if (is_numeric(substr($aux_linha_arq,17,6))) {
				$qtd_lote = (int) substr($aux_linha_arq,17,6);
				if ($qtd_lote != $qtd_reg) {
					$arrCrit[] = "Quantidade total do lote difere do quantidade de lancamentos. " . 
					             " Qtd Pagamentos = " . $qtd_reg .
								 " / Qtd Lote = " .  $qtd_lote .
					             " - Linha: " .($i+1).".";
				}
			} else {
			  	$arrCrit[] = "Quantidade total do lote invalida - Linha: " .($i+1).".";
			}
			
			$trailer_lote = 1;
		}
		
		// Verificar se existe linha com o trailer do arquivo
		if ( substr($aux_linha_arq, 7, 1) == "9" ) {
			// 01.9 Codigo do banco na compensacao
			if ( substr($aux_linha_arq, 0, 3) <> "085" ) {
				$arrCrit[] = "Banco de compensação do arquivo divergente do banco de compensação do cooperado! - Trailer Arquivo: " . substr($aux_linha_arq, 0, 3);
			}
			
			// 02.9 Lote de Servico
			if ( substr($aux_linha_arq, 3, 4) <> "9999" ) {
				$arrCrit[] = "Lote de servico no trailer do arquivo invalido: " . substr($aux_linha_arq, 3, 4);
			}
			
			$trailer_arq = 1;
		} 
	}

	// Incluir tratamento para garantir que arquivo tenha Header de Arquivo
	if ( $header_arq <> 1 ) {
		$arrCrit[] = "Tipo de registro HEADER DE ARQUIVO n&atilde;o encontrado arquivo!";
	}
	
	// Tratamento para garantir que arquivo tenha Header do Lote
	if ( $header_lote <> 1 ) {
		$arrCrit[] = "Tipo de registro HEADER DE LOTE n&atilde;o encontrado arquivo!";
	}

	// Tratamento para garantir que arquivo tenha Detalhe
	if ( $linha_detalhe <> 1 ) {
		$arrCrit[] = "Tipo de registro DETALHE n&atilde;o encontrado arquivo!";
	}

	// Tratamento para garantir que arquivo tenha Trailer do Lote
	if ( $trailer_lote <> 1 ) {
		$arrCrit[] = "Tipo de registro TRAILER DE LOTE n&atilde;o encontrado arquivo!";
	}
	
	// Incluir tratamento para garantir que arquivo tenha Trailer de Arquivo
	if ( $trailer_arq <> 1 ) {
		$arrCrit[] = "Tipo de registro TRAILER DE ARQUIVO n&atilde;o encontrado arquivo!";
	}

		// gerar erros criticos
	if(count($arrCrit) > 0){
		geraLogArqRemessa("Arquivo não enviado. Foram identificadas " . count($arrCrit) . " divergências.", $nrdconta, $cdoperad, $aux_remessa, $file["name"]);
	
		$table_erros  = "<table>";
		$table_erros .= "  <thead>";
		$table_erros .= "    <tr>";
		$table_erros .= "      <th>Seq.</th>";
		$table_erros .= "      <th>Cr&iacute;ticas</th>";
		$table_erros .= "    </tr>";
		$table_erros .= "  </thead>";
		$table_erros .= "  <tbody>";
	
		for($i=0;$i<count($arrCrit);$i++){
			geraLogArqRemessa("Divergência " .($i+1). " - " . $arrCrit[$i], $nrdconta, $cdoperad, $aux_remessa, $file["name"]);
			
			$table_erros .= "<tr>";
			$table_erros .= "  <td>".($i+1)."</td>";
			$table_erros .= "  <td>".$arrCrit[$i]."</td>";
			$table_erros .= "</tr>";			
		}		
		
		$table_erros .= "</tbody></table>";
		//$table_erros = '<table><tr><td>jhonny</td></tr></table>';
		
		//$funcao = "msgError('error','".$arrCrit[0]."','hideMsgAguardo();')";
		$texto = 'criticaOpcaoT(\"'.$table_erros.'\");';
		$funcao = "msgError('error','".$arrCrit[0]."','".$texto."')";
		echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
		exit();
	}
	
	geraLogArqRemessa("Envio do arquivo pelo Internet Banking (Etapa 1 de 3)", $nrdconta, $cdoperad, $aux_remessa, $file["name"]);
	
	/*GNU*/
	/*
	$controle = "OK";
	$tempo     = time();
	$dirArqDne = "../../upload_files/";
	$filename  = "uppgto.". $tempo . '_' . $nrdconta . '_' . $cdcooper . ".txt";
	$filename = $aux_nmarquivo;
	$nmarquiv = $dirArqDne.$filename;
    $Arq       = $nmupload;
		*/

	// Ler parametros passados via POST
	$file      = (isset($_FILES['userfile'])) ? $_FILES['userfile'] : '';
	$flglimpa  = (isset($_POST['flglimpa'])) ? $_POST['flglimpa'] : '0';

	// retorno sera de eval ou html
	$eval     = (isset($_POST['redirect'])) ? true : false;
    $tempo    = time();
    // Local de Upload do arquivo -  Antes de passar pelo "upload_file.php"
	//$nmupload  = "../../upload_files/cocnae." . $tempo . ".txt";

	$nmupload  = "uppgto.txt";

	// Nome do arquivo do upload - Depois de passar pelo "upload_file.php"
	$dirArqDne = "../../upload_files/";
	$filename  = $aux_nmarquivo;
    $Arq       = 'uppgto.txt';

	//encriptacao e envio do arquivo
	require("../../includes/upload_file_conta.php");

    // Caminho que deve ser enviado ao Mensageria / para ORACLE fazer exec do CURL
    $caminhoCompleto = $_SERVER['SERVER_NAME'].'/'.str_replace('../../','',$caminho);
    
    // Apaga o arquivo de UPLOAD que está sem Criptografia
    unlink($Arq);

	// Monta o xml
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";	
	$xml .= "		<dsarquiv>".$NomeArq."</dsarquiv>";	 // Variável $NomeArq vem da gnuclient_upload_file.php
	$xml .= "		<dsdireto>".$caminhoCompleto."</dsdireto>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "PGTA0001", 'IMPORTAARQPGTO', $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);

	//print_r($xmlObjeto);
	
	// Se ocorrer um erro, mostra crítica
 	if ($xmlObjeto->roottag->tags[0]->name == "ERRO") {
		geraLogArqRemessa("Erro no recebimento do arquivo: " . strtoupper(substr($decriptado,1,2)) . " (Etapa 3 de 3)", $nrdconta, $cdoperad, $aux_remessa, $file["name"]);		
		$funcao = "msgError('error','".utf8ToHtml( removeCaracteresInvalidos($xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata))."','hideMsgAguardo();');";
    }else{
		geraLogArqRemessa("Recebido pelo sistema (Etapa 2 de 3)", $nrdconta, $cdoperad, $aux_remessa, $file["name"]);
		$registros = $xmlObjeto->roottag->tags[0]->tags;
		$arr = $xmlObjeto->roottag->tags[0];   // returns an array
		//echo "<script>parent.framePrincipal.eval( 'showError('inform','Arquivo importado com sucesso.','Alerta - Ayllos','',false);' );</script>";
		$funcao = "msgError('inform','".utf8ToHtml("Remessa de Pagamentos de Titulos enviada para processamento!")."','sucessoOpcaoT();');";
	}
	
	echo '<script> parent.framePrincipal.eval("'.$funcao.'"); </script>';
	/*GNU*/
	
	exit();

?>