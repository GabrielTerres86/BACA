<?php
    //*******************************************************************************************************************//
    //*** Fonte: baixar_arquivo.php                                                                                   ***//
    //*** Autor: Guilherme/SUPERO                                                                                     ***//
    //*** Data : Mar�o/2016                   �ltima Altera��o: 12/09/2016                                            ***//
    //***                                                                                                             ***//
    //*** Objetivo  : Buscar Imagens e Certificados do Cheque, gerar ZIP e baixar.                                    ***//
    //***                                                                                                             ***//
    //***                                                                                                             ***//
    //*** Altera��es: 29/07/2016 - Corrigi o uso da funcao split depreciada. SD 480705 (Carlos R.)                    ***//
    //*** Altera��es: 12/09/2016 - Ajustado para efetudar downlaod do arquivo                                         ***//
    //***                          original com extens�o TIF. SD 518443 (Ricardo Linhares)                            ***//
    //***                   //alterar o caminho do servidor                                                                                                 ***//
    //*******************************************************************************************************************//

    session_cache_limiter("private");
    session_start();

    // Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es
    require_once("../../includes/config.php");
    require_once("../../includes/funcoes.php");
    require_once("../../includes/controla_secao.php");

    // Verifica se tela foi chamada pelo m�todo POST
    isPostMethod();

    // Classe para leitura do xml de retorno
    require_once("../../class/xmlfile.php");

    $cdcooper = ( isset($_POST["cdcooper"]) ) ? $_POST["cdcooper"] : '';
    $dtcompen = ( isset($_POST["dtcompen"]) ) ? $_POST["dtcompen"] : '';
    $cdcmpchq = ( isset($_POST["cdcmpchq"]) ) ? $_POST["cdcmpchq"] : '';
    $cdbanchq = ( isset($_POST["cdbanchq"]) ) ? $_POST["cdbanchq"] : '';
    $cdagechq = ( isset($_POST["cdagechq"]) ) ? $_POST["cdagechq"] : '';
    $nrctachq = ( isset($_POST["nrctachq"]) ) ? $_POST["nrctachq"] : '';
    $nrcheque = ( isset($_POST["nrcheque"]) ) ? $_POST["nrcheque"] : '';
    $tpremess = ( isset($_POST["tpremess"]) ) ? $_POST["tpremess"] : '';
    $dsdocmc7 = ( isset($_POST["dsdocmc7"]) ) ? $_POST["dsdocmc7"] : '';

    $DATA = explode('/', $dtcompen);
    $DATA = $DATA[2].'-'.$DATA[1].'-'.$DATA[0];

    $AGENCIAC   = str_pad($cdagechq, 4, '0', STR_PAD_LEFT);
    $REMESSA    = $tpremess == "N" ? "nr" : "sr";

    $arrZipName = array();
    $arrZipFile = array();

    $dirdestino = "/var/www/ayllos/documentos/" . $glbvars["dsdircop"]. "/temp/";

/* ******  ENDERE�O PARA BUSCAR AS IMAGENS NO SERVIDOR - CUIDADO AO ALTERAR E LIBERAR  *********** */
    //$urlOrigem = "http://imagenschequedev.cecred.coop.br"; // DESENV
    $urlOrigem = "http://imagenscheque.cecred.coop.br";    // PRODU��O
/* ******  ENDERE�O PARA BUSCAR AS IMAGENS NO SERVIDOR - CUIDADO AO ALTERAR E LIBERAR  *********** */


    // BUSCAR IMAGEM NO SERVIDOR (FRENTE DO CHEQUE)
    $find = $urlOrigem ."/imagem/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."F.TIF";

    $ch = curl_init($find);

    $tifF = $dirdestino . $dsdocmc7 . "F.TIF";

    $fp = fopen($tifF, "w");

    curl_setopt($ch, CURLOPT_FILE, $fp);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_exec($ch);

    $info = curl_getinfo($ch);

    if  ($info['size_download'] <= 8000) {
            if ($cdcooper == 1) {
                if ($cdagechq == 101) {
                    $cdagechq = 103;
                }
            }
            else {
                if ($cdagechq == 112) {
                    $cdagechq = 114;
                }
            }

        //#200504 Tratamento incorpora��o
        //Se n�o encontrou o cheque, verificar se � cheque da concredi ou credimilsul
        if ($tpremess == "N" && ($cdcooper == 1 || $cdcooper == 13)) {
            if ($cdcooper == 1) {
                if ($cdagechq == 101) {
                    $cdagechq = 103;
                }
            }
            else {
                if ($cdagechq == 112) {
                    $cdagechq = 114;
                }
            }

            $AGENCIAC = str_pad($cdagechq, 4, '0', STR_PAD_LEFT);
            // buscar imagem no servidor (frente do cheque)
            $find     =  $urlOrigem ."/imagem/085/".$DATA."/".$AGENCIAC."/".
                        $REMESSA."/".$dsdocmc7."F.TIF";

            $ch       = curl_init($find);
            $tifF     = $dirdestino . $dsdocmc7 . "F.TIF";
            $fp       = fopen($tifF, "w");
            curl_setopt($ch, CURLOPT_FILE, $fp);
            curl_setopt($ch, CURLOPT_HEADER, 0);
            curl_exec($ch);
            $info     = curl_getinfo($ch);

            if ($info['size_download'] <= 8000){
                curl_close($ch);
                fclose($fp);
                unlink($tifF);
                echo "bGerarPdf.hide();bSalvarImgs.hide();";
                exibeErro("Cheque n&atilde;o encontrado!");
            }
        }
        else {
            curl_close($ch);
            fclose($fp);
            unlink($tifF);
            echo "bGerarPdf.hide();bSalvarImgs.hide();";
            exibeErro("Cheque n&atilde;o encontrado!");
        }
    }

    curl_close($ch);
    fclose($fp);


    // P�e nome do arquivo no Array
    array_push($arrZipName, $dsdocmc7 . "F.TIF");
    array_push($arrZipFile, $tifF);



    // BUSCAR IMAGEM NO SERVIDOR (VERSO DO CHEQUE)
    $find = $urlOrigem ."/imagem/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."V.TIF";

    $ch = curl_init($find);

    $tifV = $dirdestino . $dsdocmc7 . "V.TIF";
	


    $fp = fopen($tifV, "w");
    curl_setopt($ch, CURLOPT_FILE, $fp);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_exec($ch);
    curl_close($ch);
    fclose($fp);

    // P�e nome do arquivo no Array
    array_push($arrZipName, $dsdocmc7 . "V.TIF");
    array_push($arrZipFile, $tifV);

    // BUSCAR CERTIFICADO NO SERVIDOR (FRENTE DO CHEQUE)
    $find = $urlOrigem ."/certificado/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."F.P7S";

    $ch = curl_init($find);
	
	if(!existeArquivo($find)) {
		echo "bGerarPdf.hide();bSalvarImgs.hide();";
		exibeErro("Certificado n&atilde;o encontrado!");
	}		

    $certF = $dirdestino . $dsdocmc7 . "F.P7S";

    $fp = fopen($certF, "w");
    curl_setopt($ch, CURLOPT_FILE, $fp);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_exec($ch);
    curl_close($ch);
    fclose($fp);

    if(!file_exists($certF)){
        echo "bGerarPdf.hide();bSalvarImgs.hide();";
        exibeErro("Certificado n&atilde;o encontrado!");
    }
    // P�e nome do arquivo no Array
    array_push($arrZipName, $dsdocmc7 . "F.P7S");
    array_push($arrZipFile, $certF);

    // BUSCAR CERTIFICADO NO SERVIDOR (VERSO DO CHEQUE)
    $find = $urlOrigem ."/certificado/085/".$DATA."/".$AGENCIAC."/".$REMESSA."/".$dsdocmc7."V.P7S";

    $ch = curl_init($find);
	
	if(!existeArquivo($find)) {
		echo "bGerarPdf.hide();bSalvarImgs.hide();";
		exibeErro("Certificado n&atilde;o encontrado!");
	}			

    $certV = $dirdestino . $dsdocmc7 . "V.P7S";

    $fp = fopen($certV, "w");
    curl_setopt($ch, CURLOPT_FILE, $fp);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    curl_exec($ch);
    curl_close($ch);
    fclose($fp);

    if(!file_exists($certV)){
        echo "bGerarPdf.hide();bSalvarImgs.hide();";
        exibeErro("Cheque n&atilde;o encontrado!");
    }
    // P�e nome do arquivo no Array
    array_push($arrZipName, $dsdocmc7 . "V.P7S");
    array_push($arrZipFile, $certV);



    // GERAR ARQUIVO ZIP NO SERVIDOR
    $zip = new ZipArchive();
    // Criando o arquivo zip
    $criou = $zip->open($dirdestino . $dsdocmc7 . '.zip', ZipArchive::CREATE);
    if ($criou === true) {
        for ($i = 0; $i < count($arrZipName); $i++) {
            $zip->addFile($arrZipFile[$i], $arrZipName[$i]);
        }
        // Salvando o arquivo
        $zip->close();
    }
    // FIM  GERAR ARQUIVO ZIP NO SERVIDOR

    //mostra botao de gerar pdf se chegar ateh aki
    echo "bGerarPdf.show('slow');bSalvarImgs.show('slow');";
    ?>

    nmArqZip = '<? echo $dirdestino . $dsdocmc7 . '.zip'; ?>';
    idlogin  = '<? echo base64_encode($glbvars["sidlogin"]);?>';

    var strHTML = "";


<?php
        echo 'hideMsgAguardo();';
        echo "window.open('download_zip.php?sidlogin=' + idlogin + '&src=' + nmArqZip, '_blank');";


    // Fun��o para exibir erros na tela atrav�s de javascript
    function exibeErro($msgErro) {
        echo 'hideMsgAguardo();';
        echo 'showError("error","'.$msgErro.'","Alerta - Ayllos");';
        exit();
    }
	
	//Verifica se o arquivo existe
	function existeArquivo($url)
	{
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL,$url);
		curl_setopt($ch, CURLOPT_NOBODY, 1);
		curl_setopt($ch, CURLOPT_FAILONERROR, 1);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		if(curl_exec($ch)!==FALSE)
		{
			return true;
		}
		else
		{
			return false;
		}
	}

?>
