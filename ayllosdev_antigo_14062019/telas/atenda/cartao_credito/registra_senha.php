<?php 

		session_start();
		require_once('../../../includes/config.php');
		require_once('../../../includes/funcoes.php');
		require_once('../../../includes/controla_secao.php');
		require_once('../../../class/xmlfile.php');
		isPostMethod();		
		if((!isset($_POST['nrdconta']))       || 
				( !isset($_POST['nrctrcrd'])) ||
				(!isset($_POST['nrcpf']) )){
			echo "showError(\"error\", \"Erro ao enviar proposta ao bancoob.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
			return;
		}
        function formatnumber($nub){
                if(intval($nub) < 10){
                    return "0".$nub;
                }else{
                    return $nub;
                }
        }
		$funcaoAposErro = 'bloqueiaFundo(divRotina);';	
		$nrdconta = $_POST['nrdconta'];
		$nrctrcrd = $_POST['nrctrcrd'];
		$nrcpf =  $_POST['nrcpf'];
		$nmaprovador =  $_POST['nmaprovador'];
		$glbadc     = $_POST['glbadc'];
		$inpessoa    = $_POST['inpessoa'];
		$dsgraupr   = $_POST['dsgraupr'];
		echo "/* param \n  nm:$nmaprovador      cpf:$nrcpf  \n */";
		if($inpessoa == 1 && $dsgraupr != 5){
			$xml .= "<Root>";
            $xml .= " <Dados>";
            $xml .= "   <nrctrcrd>$nrctrcrd</nrctrcrd>";
            $xml .= "   <nrdconta>$nrdconta</nrdconta>";
            $xml .= " </Dados>";
            $xml .= "</Root>";
            $admresult = mensageria($xml, "ATENDA_CRD", "BUSCAR_ASSINATURA_REPRESENTANTE", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
            $objectResult = simplexml_load_string( $admresult );
			
			foreach($objectResult->Dados->representantes->representante as $representante){
				$nmaprovador = $representante->nome;
				$nrcpf       = $representante->nrcpfcgf;
				echo "/* Novos\n  nm:$nmaprovador      cpf:$nrcpf  \n */";
				break;
			}
			
		}

		$now = getdate();
		$data =formatnumber($now['mday'])."/".formatnumber($now['mon'])."/".$now['year'];
		$hora = formatnumber($now['hours']).":".formatnumber($now['minutes']);
        


        $bancoobXML .= "<Root>";
		$bancoobXML .= " <Dados>";
        $bancoobXML .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
		$bancoobXML .= "   <nrdconta>".$nrdconta."</nrdconta>";
		$bancoobXML .= "   <nrctrcrd>".$nrctrcrd."</nrctrcrd>";
		$bancoobXML .= "   <indtipo_senha>1</indtipo_senha>";
        $bancoobXML .= "   <dtaprovacao>".$data."</dtaprovacao>";
		$bancoobXML .= "   <hraprovacao>".$hora."</hraprovacao>";
		$bancoobXML .= "   <nrcpf>".str_replace("-","",str_replace(".","",$nrcpf))."</nrcpf>";
		$bancoobXML .= "   <nmaprovador>".$nmaprovador."</nmaprovador>";
		$bancoobXML .= " </Dados>";
		$bancoobXML .= "</Root>";
		$admresult = mensageria($bancoobXML, "ATENDA_CRD", "INSERE_APROVADOR_CRD", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$procXML = simplexml_load_string($admresult);
		$xmlObject = getObjectXML($admresult);
		if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata;		
			//echo "error = true;showError(\"error\", \"$msg.\", \"Alerta - Aimaro\", \"blockBackground(parseInt($('#divRotina').css('z-index')))\");";
			//exit();
		}
		
		echo "/*".$admresult."  >". isset($procXML->Erro)."<*/";
		
		
        ?>
		
		
