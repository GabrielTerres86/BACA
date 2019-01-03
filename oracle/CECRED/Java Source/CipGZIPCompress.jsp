create or replace and compile java source named CECRED."CipGZIPCompress" as
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Clob;
import java.sql.SQLException;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;

import javax.xml.bind.DatatypeConverter;

/**
* Classe dedicada a compressão de conteúdos em formato GZIP
* 
* @author Renato Darosci - Supero
*/
public class CipGZIPCompress {

	// Realizar a compressão da string retornando o array de bytes
	public static byte[] compress(final String str) throws IOException {
		if ((str == null) || (str.length() == 0)) {
			return null;
		}
		System.out.println(GZIPInputStream.GZIP_MAGIC);
		ByteArrayOutputStream obj = new ByteArrayOutputStream();
		GZIPOutputStream gzip = new GZIPOutputStream(obj);
		gzip.write(str.getBytes("UTF-16"));
		gzip.flush();
		gzip.close();
		return obj.toByteArray();
	}

    // Chamar a rotina de compressão, convertendo o retorno para o mesmo que seja String
	public static String getCompress(final String str) {

		try {
			return DatatypeConverter.printHexBinary(compress(str));
		} catch (IOException e) {
			e.printStackTrace();
			return "Erro ao comprimir o arquivo.";
		}

	}

	// Chamar a rotina de decompressão, recebendo o parametros como string
	public static String getDecompress(final String str) {

		try {
			return decompress(DatatypeConverter.parseHexBinary(str));
		} catch (IOException e) {
			e.printStackTrace();
			return "Erro ao descomprimir o arquivo.";
		}

	}

	// Chamar a rotina de decompressão, recebendo o parametros como string
	public static Clob getDecompressCLOB(Clob message) throws SQLException {
		
		String decompressed;
		
		try {
			
			// Converter o Clob para String
			String stringData = CipRSAUtil.ClobToString(message);
			
			// Realizar a descompressão do conteúdo
			decompressed = decompress(DatatypeConverter.parseHexBinary(stringData)); 
			
		} catch (Exception e) {
			e.printStackTrace();
			decompressed = "Erro ao descomprimir o arquivo.";
		}

		// Retornar o Clob com os dados
		return CipRSAUtil.StringToClob(decompressed);
	}

	// Realizar a decompressão do array de bytes retornando a string final
	public static String decompress(final byte[] compressed) throws IOException {
		final StringBuilder outStr = new StringBuilder();
		if ((compressed == null) || (compressed.length == 0)) {
			return "";
		}
		if (isCompressed(compressed)) {

			final GZIPInputStream gis = new GZIPInputStream(new ByteArrayInputStream(compressed));
			final BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(gis, "UTF-16"));

			String line;
      while ((line = bufferedReader.readLine()) != null) {
        outStr.append(line);
      }
    } else {
      outStr.append(compressed);
    }

    return outStr.toString();
  }

  // Verifica se o conteúdo está comprimido no formato GZIP
  public static boolean isCompressed(final byte[] compressed) {
    return (compressed[0] == (byte) (GZIPInputStream.GZIP_MAGIC))
				&& (compressed[1] == (byte) (GZIPInputStream.GZIP_MAGIC >> 8));
	}

}
/
