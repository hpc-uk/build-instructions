files=$(ls *.F)
for file in $files
do
  echo $file
  sed -i 's/^\s*#/#/' $file
done
