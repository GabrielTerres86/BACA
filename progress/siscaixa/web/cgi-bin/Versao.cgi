$Versao='$Revision: 1.22 $';
$Versao=~s/^.*(\d+\.\d+)\s.$/$1/;
1;
#
# $Id: Versao.cgi,v 1.22 2005/07/19 02:46:49 fischer Liberado $
#
# $Revision: 1.22 $
#
# $Date: 2005/07/19 02:46:49 $
#
# Adaptados os programas mtged.cgi e pesquisa.cgi para usar a rotina enc.pl
# Ajustes na transferencia do usuario
# Incluido o modulo MTGED.pm
# Ajustes no tratamento da senha
# Liberação intermediária
# Alterada a chamada de comando para usar o ComandosMT.pl
# Incluido tratamento para senhas MD5 (Linux)
# Migrada subrotina ApresentaTelaDeLogin() para o MTGED.pm
# Melhorado tratamento de senhas expiradas
# Incluido o Customiza.pl no RCS
# Incluida a variavel $DiretorioVar para gravacao de logs.
# Definição da variável $cWindowsStatus.
# Login.cfg : Comando sudo colava o $0 quando criptografado.
# Criado controle para que somente apareça o icone de apresenta em PDF se
# o MTPDF esta instalado e configurado.
# Concluído o código que gera a grade para pesquisa.
# Concluído o processamento de pesquisa.
# Incluída a verificação do IP de origem na autenticação.
# Incluída a variável $TotalDiasPesquisa para validar o critério de busca de
# documentos.
# Sufixos .gz permitem 'Salvar como...'
# Default marca todos os niveis para a pesquisa
# Alterado a mensagem do argumento de busca em pesquisa.
# Incluído controle de licenças.
# Incluido o parametro $MTGED::FontSize para a apresentação de documentos.
# Acerto na rotina de upload. Testa se existem os diretorios de upload.
# Incluido controle na abertura dos documentos para manter o cursos na localização
# Incluido self.focus(); na abertura de pasta.
# Incluido tratamento de sufixo .exe para download.
# Incluido tratamento de diretorio na pasta principal da janela.
# MTGED.pm : Forca a criacao do diretorio /tmp/.www.
# Login.cgi : Ajuste no tratamento de $0 para identificar o caminho completo do
# script chamado para validar no sudo
# Na apresentação dos documentos na janela relatorios, é feita a validação de
# permissão no arquivo ${usuario}.cfg.
# Incluido tratamento de CSS
# Incluido logo de cliente
# Criada TabelaDeSufixos para identificar arquivos que nao devem ser convertidos
# para PDF.
