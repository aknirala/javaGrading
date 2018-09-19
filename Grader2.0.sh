set x
# You may need to make this file executable (chmod 775 Grader2.0.sh)
# To run just do (./Grader2.0.sh or sh Grader2.0.sh)
#Path for jUnits test cases for grading (U need to change this)
graderFiles="hw02_grading/src/edu/iastate/cs228/hw02/grading/*.java"
#Path for provided solution (U need to change this)
solutionFiles="hw02_grading/src/edu/iastate/cs228/hw02/solution/*.java"


#class which will run the test cases (Do NOT change this, except hw02 part)
graderClass="edu.iastate.cs228.hw02.grading.AutomatedJUnitRunner"

#Submission package files (Do NOT change this, except hw02 part)
subPkgFiles="edu/iastate/cs228/hw02/*.java"

#Do not change this
junitPath="junit-platform-console-standalone-1.3.0.jar"

#This is temp folder: Do not change this
tmpFolder="tmp"

#This is location of students "zip" submissions. (U need to change this)
subPath="submissions"

#Output will be created in this folder. Do not change this.
grades="grades"

#Do NOT change this, except hw02 part 
package="edu/iastate/cs228/hw02/"


#Splited into two parts as output is multiline which is non-trivial to handle with sed
#PLEASE Change contents inside Header (change it to your name)
templateFileFooter="CommentTemplateFooter.txt"
templateFileHeader="CommentTemplateHeader.txt"



#If tmp folder is not there it will create it.
if [ ! -d "$tmpFolder" ]
then  
  mkdir $tmpFolder
fi

if [ ! -d "$grades" ]
then  
  mkdir $grades
fi


counter=1
for subZip in "$subPath"/*.zip
do

  echo ".................................................."
  echo $counter". Starting with $subZip. Copying to tmp"
  counter=$((counter+1))
  #This if loop is only there if we need to restart the script. 
  #Also it assumes each time files will be picked in same order.
  # if [ $counter -lt 33 ]; then 
  #  echo "Already checked so continuing."
  #  continue
  # fi

  cp "$subZip" "$tmpFolder"/
  sName=$(basename "$subZip" ".zip")
  unzip "$tmpFolder"/"$sName" -d "$tmpFolder"/
  
  echo "#Compile the submission files into tmp" #Including junit as well for future cases.
  mkdir -p "$tmpFolder/$package"
  find $tmpFolder -type f -name '*.java' -exec cp {} "$tmpFolder/$package" \;
  javac -d "$tmpFolder"/ -cp "$junitPath:$tmpFolder"/ "$tmpFolder"/$subPkgFiles

  echo "#Now Compile the solution files into tmp"
  javac -d "$tmpFolder"/ -cp "$junitPath:$tmpFolder"/ $solutionFiles

  echo "#Now Compile the grading files into tmp"
  javac -d "$tmpFolder"/ -cp "$junitPath:$tmpFolder"/ $graderFiles

  echo "#Now actually running the test script"
  outpt="$(java -cp $junitPath:$tmpFolder/ $graderClass)"
  scoreW=${outpt##* }
  #https://stackoverflow.com/questions/3162385/how-to-split-a-string-in-shell-and-get-the-last-field
  score=$(cut -d'.' -f1 <<<$scoreW)
  #integer expression expected
  echo "Score is: "$score
  cp $templateFileHeader "$grades/$sName".txt
  echo "Template copied to $grades/$sName".txt
  echo "$outpt" >> "$grades/$sName".txt
  cat $templateFileFooter >> "$grades/$sName".txt
  sed -i '' "s/PLACEHOLDER02/$score/g" "$grades/$sName".txt
  autoComment="Need to focus a bit more on testing."
  if [ $score -lt 50 ]
    then
    autoComment="Put in more effort please."
  fi
  if [ $score -gt 70 ]
  then
    autoComment="Nice! Could be better with more testing."
  fi
  if [ $score -gt 80 ]
  then
    autoComment="Good work. Could have been perfect with little more testing."
  fi
  if [ $score -gt 85 ]
  then
    autoComment="Good work!"
  fi
  if [ $score -gt 89 ]
  then
    autoComment="Awesome!"
  fi
  #Adding a score of 10 by default as most students will do it correctly.
  #But please note u need to change this as per what students have really done.
  score=$((score+10))
  sed -i '' "s/PLACEHOLDER03/$score/g" "$grades/$sName".txt
  sed -i '' "s/PLACEHOLDER04/$autoComment/g" "$grades/$sName".txt
  

  echo "$score $sName "$((counter-1)) >> "$grades"/scores.txt
  echo "Output added. Now checking for tags"

  echo "#Checking the author tag here."
  authorImports="$(java extractStuff $tmpFolder/$package $sName)" 
  echo "Op is: $authorImports"
  echo "$authorImports" >> "$grades/$sName".txt

  echo "Output added. Now cleaning the tmp folder"  

  rm -rf $tmpFolder/*
  rm -rf $tmpFolder/.*
  #To delete hidden files.

done

