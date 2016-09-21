<?php
/*
 * FONTE        : download_zip.php
 * CRIAÇÃO      : Guilherme/SUPERO
 * DATA CRIAÇÃO : Março/2016
 * OBJETIVO     : Download do Zip com Imagens e Certificados
 * --------------
 * ALTERAÇÕES   :
 * --------------
*/

session_start();

// Obtem SIDLOGIN da sessão para verificar se o usuário está logado
// O parâmetro deve ser passado criptografado para evitar acesso direto pelo Browser
$sidlogin = base64_decode($_GET['sidlogin']);

// Criar a variável POST para alimentar a variável global $glbvars na include config.php
$_POST["sidlogin"] = $sidlogin;

// Includes para variáveis globais de controle, e biblioteca de funções
require_once("../../includes/config.php");
require_once("../../includes/funcoes.php");

// Classe para leitura do xml de retorno
require_once("../../class/xmlfile.php");

// Verifica se o usuário está logado no sistema
if (!isset($glbvars['cdcooper'])) {
    echo "É preciso estar logado ao sistema para salvar o arquivo!";
    exit();
}

if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@",false)) <> "") {
    echo $msgError;
    exit();
}

$zip  = strip_tags($_GET['src']);

$nmArquiv = str_replace(".zip", "*", $zip);

if (!file_exists($zip)) {
    echo "Arquivo ZIP não encontrado.";
    exit();
}

$nm_file = preg_replace('/^(.*\/)/','',$zip);

// cache da imagem 24 horas
$seconds_to_cache = 86400;
$ts = gmdate('D, d M Y H:i:s', time() + $seconds_to_cache) . ' GMT';
header("Expires: $ts");
header('Pragma: cache');
header("Cache-Control: maxage=$seconds_to_cache");
header('Content-Disposition: attachment; filename="'.$nm_file.'"');
@readfile($zip);
flush();


// APAGAR ARQUIVOS DESSE CMC7
foreach (glob($nmArquiv) as $filename) {
   unlink($filename);
}
//unlink($zip);  // ZIP

?>
