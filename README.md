Remove-Item -Recurse -Force docs
flutter build web
mkdir docs    
cp -r build/web/* docs/
git add .
git commit -m "vercel" 
git push 