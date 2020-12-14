Updated forked repository from original repository
--------------------------------------------------
git remote -v
git remote add upstream https://github.com/hpc-uk/build-instructions
git remote -v

git fetch upstream
git checkout main
git merge upstream/main


Previewing build-instructions changes
-------------------------------------
cp -r archer2-website archer2-website-staging
jekyll new --force archer2-website-staging
cd archer2-website-staging
bundle exec jekyll serve

Browse to "http://127.0.0.1:4000/
Press ctrl-c to stop

cd ..
rm -rf archer2-website-staging
cd archer2-website

Commit changes


Previewing archer2-docs changes
-------------------------------
. ~/opt/anaconda3/env.sh
cd archer2-docs
make html
Browse to ./_build/html/index.html
