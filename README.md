Remove-Item -Recurse -Force docs
flutter build web
mkdir docs    
cp -r build/web/* docs/
git add .
git commit -m "vercel" 
git push

# Alternativa: deploy directo con Vercel CLI (como metalwailers)
# flutter build web --release
# copy vercel.json build\web\
# cd build\web
# vercel --prod