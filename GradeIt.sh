set x
graderFiles="hw_01grading/hw_01grading/src/edu/iastate/cs228/hw01/grading/*.java"
graderClass="edu.iastate.cs228.hw01.grading.AutomatedJUnitRunner"
subPkgFiles="edu/iastate/cs228/hw01/*.java"
junitPath="junit-platform-console-standalone-1.3.0.jar"
tmpFolder="tmp"
subPath="submissions (2)"
grades="grades"
#Splited into two parts as output is multiline which is non-trivial to handle with sed
templateFileFooter="CommentTemplateFooter.txt"
templateFileHeader="CommentTemplateHeader.txt"

counter=1
for subZip in "$subPath"/*.zip
do


echo ".................................................."
echo $counter". Starting with $subZip. Copying to tmp"
counter=$((counter+1))
#This if loop is only there if we need to restart the script. Also it assumes each time files will be picked in same order.
if [ $counter -lt 33 ]; then 
 echo "Already checked so continuing."
 continue
fi

cp "$subZip" "$tmpFolder"/
sName=$(basename "$subZip" ".zip")
unzip "$tmpFolder"/"$sName" -d "$tmpFolder"/

#Students can start their zip file with edu or sth else (need to handle)
isEdu=false
echo "isEdu b4: "$isEdu
for cont in "$tmpFolder"/*
do
  #echo "$cont"
  if [ $cont = "$tmpFolder"/"edu" ]; then
    isEdu=true
  fi
done
echo "isEdu A4: "$isEdu
if $isEdu
then
echo "Packaged correctly"
else
echo "Path does not start with edu :-(. Kindly input the path to take instead of edu/iastate/cs228/hw01/*.java"
read subPkgFiles
fi
 echo "#Compile the submission files into tmp" #Including junit as well for future cases.
 javac -d "$tmpFolder"/ -cp "$junitPath:$tmpFolder"/ "$tmpFolder"/$subPkgFiles
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
 sed -i "s/PLACEHOLDER02/$score/g" "$grades/$sName".txt
 sed -i "s/PLACEHOLDER03/$score/g" "$grades/$sName".txt
 autoComment="Need to focus a bit more on testing."
 if [ $score -gt 80 ]
  then
  autoComment="Nice! Could be better with more testing."
 fi
 if [ $score -gt 90 ]
  then
  autoComment="Good work. Could have been perfect with little more testing."
 fi
 if [ $score -gt 95 ]
  then
  autoComment="Good work!"
 fi
 if [ $score -gt 99 ]
  then
  autoComment="Awesome!"
 fi
 sed -i "s/PLACEHOLDER04/$autoComment/g" "$grades/$sName".txt
 if $isEdu
then
echo "Packaged correctly"
else
 echo "Warning!!! ZIP file not in correct order. On extracting zip, edu folder should be base folder. Please note in future, this may result in non-grading or a penalty." >> "$grades/$sName".txt
fi
 echo "Output added. Now cleaning the tmp folder"
 echo "$score $sName "$((counter-1)) >> "$grades"/scores.txt
 rm -rf $tmpFolder/*
 rm -rf $tmpFolder/.*
 #To delete hidden files.

done

