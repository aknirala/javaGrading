import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;

/**
 * A class to extract author tag and ensure it's correctness.
 * @author aknirala
 *
 */
public class checkAuthor {
	
	/**
	 * A function which will simply extract all the author tags values given the java file.
	 * It simply check each line for @author tag and returns whatever is after that (after trimming it).
	 * @param fPath
	 * @return
	 */
	public static ArrayList<String> getAuthors(File file){
		ArrayList<String> authors = new ArrayList();
		BufferedReader br;
		try {
			br = new BufferedReader(new FileReader(file));
			String line = null;
			while ((line = br.readLine()) != null) {
				if(line.toLowerCase().contains("@author")) {
					line = line.toLowerCase();
					int sIdx = line.indexOf("@author");
					authors.add(line.substring(sIdx + "@author".length()).trim());
				}
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		 
		
		return authors;
	}
	
	/**
	 * As the name states...
	 * @return
	 */
	public static ArrayList<String> ignoreFileList(){
		ArrayList<String> fList = new ArrayList();
		File file = new File("ignoreFiles.txt");
		BufferedReader br;
		try {
			br = new BufferedReader(new FileReader(file));
			String line = null;
			while ((line = br.readLine()) != null) {
				if(line.trim().length() > 0)
					fList.add(line.trim());
			}
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return fList;
	}
	
	public static String getVerdict(ArrayList<String> authors, String fName) {
		StringBuffer sb = new StringBuffer();
		boolean authorFound = false;
		for(String author:authors) {
			author = author.trim();
			boolean allTokenPresent = true;
			for(String aTokens: author.trim().split(" ")) {
				aTokens = aTokens.trim(); 
				if(!fName.contains(aTokens)) {
					allTokenPresent = false;
					break;
				}
			}
			if(allTokenPresent) { sb.append("\nMATCHED: ").append(author); authorFound = true;}
			else sb.append("\nNOT MATCHED: ").append(author);
		}
		sb.append("\n");
		if(authorFound) sb.insert(0, "TAG PRESENT");
		else sb.insert(0, "TAG NOT PRESENT");
		return sb.toString();
	}
	
	public static void main(String []args) {
		if(args == null || args.length < 2) {
			System.out.println("Insufficient parameters passed. Expected two parameters path of the file (wrt tmp folder (package path)) followed by name of the zip."
					+ "\n Taking default parameters.");
			args = new String[] {"/media/aknirala/cf5e501c-8429-4a63-bf7f-b1555b89fca1/PhD/Y02S01Fall18/228/HW/hw03/"
					+ "javaGrading/tmp/edu/iastate/cs228/hw03/",
					"abdelrahmanabdalla_56761_5822275_Abdalla_Abdelrahman_hw03"};
		}
		//From: https://stackoverflow.com/questions/2102952/listing-files-in-a-directory-matching-a-pattern-in-java
		File dir = new File(args[0]);
		File [] files = dir.listFiles(new FilenameFilter() {
		    @Override
		    public boolean accept(File dir, String name) {
		        return name.endsWith(".java");
		    }
		});
		
		ArrayList<String> ignoreList = ignoreFileList();//new ArrayList();//
		String studName = args[1].split("_")[0].toLowerCase();
		for(File file:files) {
			if(!ignoreList.contains(file.getName())) {
				System.out.println(file.getName() +" : "+getVerdict(getAuthors(file), studName));
			}
		}
		
	}
}
