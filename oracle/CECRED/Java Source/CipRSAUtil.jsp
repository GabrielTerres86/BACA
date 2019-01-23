create or replace and compile java source named CECRED."CipRSAUtil" as
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.KeyFactory;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.Signature;
import java.security.interfaces.RSAPrivateKey;
import java.security.spec.EncodedKeySpec;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.X509EncodedKeySpec;
import java.util.Arrays;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import javax.xml.bind.DatatypeConverter;

/**
 * Rotinas voltadas a Criptografia dos arquivos comunicados com a CIP
 * 
 * @author Renato Darosci - Supero
 */
public class CipRSAUtil {

  private static final String ALGORITHM_CHAVE = "RSA";
  private static final String ALGORITHM_HASH = "SHA256withRSA";
  private static final String ALGORITHM_CIPHER = "DESede/CBC/NoPadding";
  private static final String PROVIDER_CIPHER = "RSA/ECB/PKCS1Padding";

  // Rotina para retornar uma faixa do array
  private static byte[] copyOfArray(byte[] arrBytes, int from, int to) {
    // A posição inicial deve ser ajustada
    return Arrays.copyOfRange(arrBytes, (from - 1), to);
  }

  /**
   * Rotina para realizar a leitura do arquivo indicado, realizando as validações
   * necessárias e realizando a descriptografia.
   * 
   * @author Renato Darosci - Supero
   * @return String - Em caso de erro
   * @throws UnsupportedEncodingException
   */
  public static String leituraArquivoPCPS(String nrSerieCIP, String nrSerieAilos, String privateKey, String publicKey,
      String inputFile, String outputFile) throws UnsupportedEncodingException {

    // Variáveis
    String hexaString = "";

    /* ***** LER O ARQUIVO - BINÁRIO ***** */
    try {
      // input
      InputStream is = new FileInputStream(new File(inputFile));

      int value = 0;

      // Percorrer o arquivo, convertendo o mesmo para hexadecimal
      while ((value = is.read()) != -1) {
        // Convert cada caracter para hexa
        hexaString += String.format("%02X", value);
      }

      // Close
      is.close();

    } catch (FileNotFoundException e) {
      return "Erro ao ler arquivo " + inputFile + ": " + e.getMessage();
    } catch (IOException e) {
      return "Erro converter arquivo para hexadecimal " + inputFile + ": " + e.getMessage();
    }

    /* ***** SEPARAR AS PARTES DO ARQUIVO ***** */
    // Extrair o head de segurança do arquivo - primeiros 588 bytes (1178 = 588*2)
    byte[] hexaHead = DatatypeConverter.parseHexBinary(hexaString.substring(0, 1176));
    // Extrair o corpo do arquivo - byte 589 em diante (1178 = 588*2)
    String stringFile = hexaString.substring(1176);

    // Ler o número de série
    String serieAilos = new String(copyOfArray(hexaHead, 12, 43), "UTF-8");
    String serieCip = new String(copyOfArray(hexaHead, 45, 76), "UTF-8");

    // realizar o pad das séries recebidas
    String paddedSerieAilos = "00000000000000000000000000000000".substring(nrSerieAilos.length()) + nrSerieAilos;
    String paddedSerieCip = "00000000000000000000000000000000".substring(nrSerieCIP.length()) + nrSerieCIP;

    /* ***** VALIDAR OS NÚMEROS DE SÉRIE EXTRAÍDOS ***** */
    // Validar se o número de série da Ailos condiz com o informado no arquivo
    if (!serieAilos.equalsIgnoreCase(paddedSerieAilos)) {
      return "Série do certificado digital do destino, inválida.";
    }

    // Validar se o número de série da CIP condiz com o informado no arquivo
    if (!serieCip.equalsIgnoreCase(paddedSerieCip)) {
      return "Série do certificado digital da emitente, inválida.";
    }

    // Separa a chave simétrica
    String simetricKey = DatatypeConverter.printHexBinary(copyOfArray(hexaHead, 77, 332));

    // Descriptografar a chave simétrica
    try {
      simetricKey = decrypt3DesKey(simetricKey, privateKey);
    } catch (Exception e) {
      return "Erro ao descriptografar chave simétrica: " + e.getMessage();
    }

    // Variável para guardar o conteúdo do arquivo
    String conteudoArquivo = "";

    // Descriptografar o corpo do arquivo
    try {
      conteudoArquivo = decrypt3Des(stringFile, simetricKey);
    } catch (Exception e) {
      return "Erro ao descriptografar conteúdo do arquivo: " + e.getMessage();
    }

    // Extrair o hash da assinatura do head do arquivo
    String hashMessage = DatatypeConverter.printHexBinary(copyOfArray(hexaHead, 333, 588));

    // Assinatura
    boolean verifyHash = false;

    /* ***** VALIDAR A ASSINATURA DO ARQUIVO ***** */
    try {
      verifyHash = verifyHashSHA256(conteudoArquivo, hashMessage, publicKey);
    } catch (Exception e) {
      return "Erro ao verificar assinatura digital do arquivo: " + e.getMessage();
    }

    // Verificar a assinatura do arquivo com o hash
    if (!verifyHash) {
      return "Assinatura da Mensagem inválida ou com Erro.";
    }

    /* ***** DESCOMPACTAR O ARQUIVO ***** */
    conteudoArquivo = CipGZIPCompress.getDecompress(conteudoArquivo);

    try {
      // Gerar o arquivo XML com o conteúdo descriptografado -> UTF-8
      FileOutputStream fileOutput = new FileOutputStream(outputFile);
      OutputStreamWriter outputStream = new OutputStreamWriter(fileOutput, "UTF-8");
      PrintWriter writeXML = new PrintWriter(outputStream);

      // Escrever o arquivo
      writeXML.printf(conteudoArquivo);

      // Salva e fecha o arquivo
      writeXML.close();

    } catch (IOException e) {
      return "Erro ao gerar arquivo XML em " + outputFile + ". " + e.getMessage();
    }

    // Retorna NULL devido a não ocorrencia de erros
    return "";

  }

  private static String asciiToHex(String asciiStr) {
    char[] chars = asciiStr.toCharArray();
    StringBuilder hex = new StringBuilder();
    for (char ch : chars) {
      hex.append(Integer.toHexString((int) ch));
    }

    return hex.toString();
  }

  /**
   * Rotina para realizar a escrita do arquivo criptografado, com base no arquivo
   * xml gerado.
   * 
   * @author Renato Darosci - Supero
   * @return String - Em caso de erro
   * @throws UnsupportedEncodingException
   */
  public static String escritaArquivoPCPS(String nrSerieCIP, String nrSerieAilos, String privateKey, String publicKey,
      String inputFile, String outputFile) throws UnsupportedEncodingException {

    // Variáveis
    String fileString = "";

    try {
      // Criar o arquivo
      File arquivo = new File(inputFile);
      FileReader readerArquivo = new FileReader(arquivo);
      BufferedReader leitorArquivo = new BufferedReader(readerArquivo);

      // Ler a linha do arquivo
      String linha = leitorArquivo.readLine();

      // Percorrer todas as linhas
      while (linha != null) {

        // Gravar as linhas
        fileString += linha + "\n";

        // Ler a próxima linha
        linha = leitorArquivo.readLine(); // lê da segunda até a última linha
      }

      // Fechar o arquivo
      readerArquivo.close();

    } catch (IOException e) {
      return "Erro na abertura do arquivo(" + inputFile + "): " + e.getMessage();
    }

    /* ***** COMPACTAR O CONTEÚDO NO ARQUIVO ***** */
    String compactedFile = CipGZIPCompress.getCompress(fileString);

    // Transfer do conteúdo compactado para um array de bytes
    byte[] tempArray = DatatypeConverter.parseHexBinary(compactedFile);

    /* ***** REALIZAR O AJUSTE DO PADDING ***** */
    // Calcula o mod do tamanho do array
    int qtdPadding = (tempArray.length % 8); // O conteúdo deve ser multiplo de 8

    // Se há necessidade de realizar padding
    if (qtdPadding > 0) {
      qtdPadding = 8 - qtdPadding; // Diferença para saber quanto é necessário adicionar
    }

    // Define o tamanho final para o array, considerando o padding
    int tamArray = (tempArray.length + qtdPadding);

    // Cria o array dimensionado ao padding e copia o conteúdo compactado
    byte[] hexaArray = Arrays.copyOf(tempArray, tamArray);

    // Converte o array novamente para String
    compactedFile = DatatypeConverter.printHexBinary(hexaArray);

    /* ***** GERAR A ASSINATURA DIGITAL COM A CHAVE PRIVADA ***** */
    String bufferAutenticacao = "";

    try {
      bufferAutenticacao = CipRSAUtil.signHashSHA256(compactedFile, privateKey);
    } catch (Exception e) {
      return "Erro ao gerar buffer do criptograma de autenticação da mensagem: " + e.getMessage();
    }

    /* ***** FORMATAR OS NÚMEROS DE SÉRIE ***** */
    // realizar o pad das séries recebidas
    String paddedSerieAilos = "00000000000000000000000000000000".substring(nrSerieAilos.length()) + nrSerieAilos;
    String paddedSerieCip = "00000000000000000000000000000000".substring(nrSerieCIP.length()) + nrSerieCIP;

    /* ***** SORTEAR A CHAVE 3DES ***** */
    String tripleDesKey = "";
    try {
      tripleDesKey = CipRSAUtil.get3DESKey();
    } catch (NoSuchAlgorithmException e) {
      return "Erro ao gerar a chave 3DES para criptografia: " + e.getMessage();
    }

    /* ***** ENCRIPTAR A MENSAGEM ***** */
    String encriptedFile = "";
    try {
      encriptedFile = CipRSAUtil.encrypt3Des(compactedFile, tripleDesKey);
    } catch (Exception e) {
      return "Erro ao criptografar xml do arquivo: " + e.getMessage();
    }

    /* ***** ENCRIPTAR A CHAVE 3DES ***** */
    String encripted3DesKey = "";
    try {
      encripted3DesKey = CipRSAUtil.encrypt3DesKey(tripleDesKey, publicKey);
    } catch (Exception e) {
      return "Erro ao criptografar chave 3DES: " + e.getMessage();
    }

    /* ***** CRIAR O HEAD DE SEGURANÇA ***** */
    String stringHead = "";

    // PREENCHER O HEAD CONFORME DOCUMENTAÇÃO CIP
    stringHead += "024C"; // Tamanho total do cabeçalho [C1 - 1..2]
    stringHead += "02"; // Versão do protocolo - Segunda versão - version 2.0 [C2 - 3]
    stringHead += "00"; // Código de erro [C3 - 4]
    stringHead += "08"; // Indicação de tratamento especial [C4 - 5]
    stringHead += "00"; // Reservado para o futuro [C5 - 6]
    stringHead += "02"; // Algoritmo da chave assimétrica do destino - RSA com 2048 bits [C6 - 7]
    stringHead += "01"; // Algoritmo da chave simétrica - Triple-DES com 168 bits (3 x 56 bits) [C7 - 8]
    stringHead += "02"; // Algoritmo da chave assimétrica local - RSA com 2048 bits [C8 - 9]
    stringHead += "03"; // Algoritmo de “hash” - SHA-256 [C9 - 10]
    stringHead += "04"; // PC do certificado digital do destino - SPB-Serasa [C10 - 11]
    stringHead += asciiToHex(paddedSerieCip); // Série do certificado digital do destino [C11 - 12..43]
    stringHead += "04"; // PC do certificado di gital da Instituição [C12 - 44]
    stringHead += asciiToHex(paddedSerieAilos); // Série do certificado digital da Instituição [C13 - 45..76]
    stringHead += encripted3DesKey; // Buffer de criptografia da chave simétrica [C14 - 77..332]
    stringHead += bufferAutenticacao; // Buffer do criptograma de autenticação da mensagem [C15 - 333..588]

    /* ***** CONCATENAR HEAD E MENSAGEM ***** */
    byte[] finalFile = DatatypeConverter.parseHexBinary(stringHead.concat(encriptedFile));

    /* ***** ESCREVER O ARQUIVO FÍSICO ***** */
    try {
      // Instanciar o arquivo
      File fileOutput = new File(outputFile);

      // Criar o arquivo
      BufferedOutputStream outputStream = new BufferedOutputStream(new FileOutputStream(fileOutput));
      // OutputStreamWriter

      // Gravar os bytes no arquivo
      outputStream.write(finalFile);

      // Fechar o Stream salvando o arquivo
      outputStream.close();

    } catch (FileNotFoundException e) {
      return "Erro ao gerar arquivo criptografado em " + outputFile + ". " + e.getMessage();
    } catch (IOException e) {
      return "Erro ao gerar arquivo criptografado em " + outputFile + ". " + e.getMessage();
    }

    return "";
  }

  /**
   * Realizar a encriptação do conteúdo do arquivo
   * 
   * @author Renato Darosci - Supero
   * @return String Hexadecimal
   */
  public static String encrypt3Des(String valueToEncrypt, String sortedKey) throws Exception {

    // Leitura a chave
    byte[] tdesKeyData = DatatypeConverter.parseHexBinary(sortedKey);

    // Converter chave
    SecretKeySpec key = new SecretKeySpec(tdesKeyData, "DESede");

    // Gerar o IV
    final IvParameterSpec iv = new IvParameterSpec(Arrays.copyOf(key.getEncoded(), 8));

    // Cifrar o conteudo
    Cipher cipher = Cipher.getInstance(ALGORITHM_CIPHER);
    cipher.init(Cipher.ENCRYPT_MODE, key, iv);

    // Leitura do texto a criptografar
    byte[] bytesToEncrypt = DatatypeConverter.parseHexBinary(valueToEncrypt);

    byte[] encryptedBytes = cipher.doFinal(bytesToEncrypt);

    return DatatypeConverter.printHexBinary(encryptedBytes);
  }

  /**
   * Realizar a encriptação da chave 3Des utilizada para criptografar a mensagem
   * 
   * @author Renato Darosci - Supero
   * @return String Hexadecimal
   */
  public static String encrypt3DesKey(String keyToEncrypt, String publicKey)
      throws IllegalBlockSizeException, BadPaddingException, NoSuchAlgorithmException, InvalidKeySpecException,
      NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, NoSuchProviderException {

    byte[] cipherText;
    byte[] pubKeyArray = CipBase64.decode(publicKey);

    // Leitura da chave a ser criptografada
    byte[] desKeyData = DatatypeConverter.parseHexBinary(keyToEncrypt);

    // Converter chave
    Key key = new SecretKeySpec(desKeyData, ALGORITHM_CIPHER);

    // Definir o RSA cipher object
    Cipher cipher = Cipher.getInstance(PROVIDER_CIPHER);

    // Instanciar a chave com base no texto recebido
    KeyFactory keyFactory = KeyFactory.getInstance(ALGORITHM_CHAVE);
    EncodedKeySpec publicKeySpec = new X509EncodedKeySpec(pubKeyArray);
    PublicKey publicKeyObj = keyFactory.generatePublic(publicKeySpec);

    // Inicializar o Cipher
    cipher.init(Cipher.WRAP_MODE, publicKeyObj);

    // Realizar o embrulho da chave
    cipherText = cipher.wrap(key);

    // Retornar dados criptografados
    return DatatypeConverter.printHexBinary(cipherText);
  }

  /**
   * Realizar a decriptação da mensagem utilizando 3Des
   * 
   * @author Renato Darosci - Supero
   * @return String Hexadecimal
   */
  public static String decrypt3Des(String valueToDecrypt, String tDesKey) throws Exception {

    // Leitura da mensagem criptografada
    byte[] bytesToDecrypt = DatatypeConverter.parseHexBinary(valueToDecrypt);

    // Ler a chave utilizada
    byte[] MY_KEY = DatatypeConverter.parseHexBinary(tDesKey); // 24-bytes
    final SecretKeySpec secretKeySpec = new SecretKeySpec(MY_KEY, "DESede");

    // Definir o vetor de Inicialização
    byte[] MY_IV = Arrays.copyOf(MY_KEY, 8); // 8-bytes
    final IvParameterSpec iv = new IvParameterSpec(MY_IV);

    // Define a instancia do algoritmo de cifra
    final Cipher cipher = Cipher.getInstance(ALGORITHM_CIPHER);

    // Inicializa o decriptador com a chave e o iv
    cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, iv);

    // REALIZAR A DESCRIPTOGRAFIA DA MENSAGEM
    final byte[] decrypted = cipher.doFinal(bytesToDecrypt);

    // Converter o retorno
    String retVal = DatatypeConverter.printHexBinary(decrypted);

    return retVal;
  }

  /**
   * Realizar a decriptação da chave 3Des utilizada para criptografar a mensagem
   * 
   * @author Renato Darosci - Supero
   * @return String Hexadecimal
   */
  public static String decrypt3DesKey(String valueToDecrypt, String privateKey) throws Exception {
    // Leitura do código criptografado da chave
    byte[] wrappedKey = DatatypeConverter.parseHexBinary(valueToDecrypt);

    // Leitura da chave privada
    CipPrivateKeyReader keyReader = new CipPrivateKeyReader(privateKey);
    PrivateKey PrivKey = (PrivateKey) keyReader.getRSAPrivateKey();

    // Definição do Cipher
    Cipher asymCipher = Cipher.getInstance(PROVIDER_CIPHER);

    // Inicialização do Cipher com a chave privada
    asymCipher.init(Cipher.UNWRAP_MODE, PrivKey);

    // Descriptografar a chave
    Key key = asymCipher.unwrap(wrappedKey, ALGORITHM_CIPHER, Cipher.SECRET_KEY);

    // Retornar a chave descriptografada
    return DatatypeConverter.printHexBinary(key.getEncoded());
  }

  /**
   * Gera o hash do dados do arquivo
   * 
   * @author Renato Darosci - Supero
   * @return String Hexadecimal
   */
  public static String signHashSHA256(String valueToEncrypt, String privateKey) throws Exception {

    CipPrivateKeyReader keyReader = new CipPrivateKeyReader(privateKey);
    RSAPrivateKey key = (RSAPrivateKey) keyReader.getRSAPrivateKey();

    // Leitura do hexa a ser assinado
    byte[] byteToEncrypt = DatatypeConverter.parseHexBinary(valueToEncrypt);

    Signature rsa = Signature.getInstance(ALGORITHM_HASH);
    rsa.initSign(key);
    rsa.update(byteToEncrypt);

    // Gerar hash conforme parametrização
    byte[] signature = rsa.sign();

    return DatatypeConverter.printHexBinary(signature);
  }

  /**
   * Verifica o hash do dados do arquivo
   * 
   * @author Renato Darosci - Supero
   * @return Boolean
   */
  public static boolean verifyHashSHA256(String messageText, String signature, String publicKey) throws Exception {

    byte[] publicKeyByteArr = CipBase64.decode(publicKey);
    PublicKey key = KeyFactory.getInstance(ALGORITHM_CHAVE)
        .generatePublic(new X509EncodedKeySpec(publicKeyByteArr));

    byte[] messageByte = DatatypeConverter.parseHexBinary(messageText);

    Signature sig = Signature.getInstance(ALGORITHM_HASH);
    sig.initVerify(key);
    sig.update(messageByte);

    return sig.verify(DatatypeConverter.parseHexBinary(signature));

  }

  // Gerar chave 3DES de 24 bytes - FOR TESTS
  public static String get3DESKey() throws NoSuchAlgorithmException {

    KeyGenerator keygenerator = KeyGenerator.getInstance("DESede");
    SecretKey chaveDES = keygenerator.generateKey();

    return DatatypeConverter.printHexBinary(chaveDES.getEncoded());

  }

  // Gerar código HASH com base no arquivo XML
  public static String getXmlHash(String strXML) throws Exception {

    // Leitura do hexa a ser criptografado
    byte[] byteXml = DatatypeConverter.parseHexBinary(strXML);

    MessageDigest md = MessageDigest.getInstance("SHA-256");
    md.update(byteXml);

		return DatatypeConverter.printHexBinary(md.digest());
	}

}
/
